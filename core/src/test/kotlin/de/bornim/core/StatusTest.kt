package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class StatusTest {
    /** A fighter whose weapon always poisons. */
    private fun poisoner(seed: Int): GameState {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.hero.gainXp(Rules.xpForLevel[5])
        val w = s.hero.weapon!!
        s.hero.gear[GearSlot.MAIN_HAND] = w.copy(rolls = w.rolls + Roll(Affix.POISON_HIT, 100))
        s.hero.restoreFully()
        return s
    }

    private fun fight(s: GameState, monster: String, seed: Int, rounds: Int = 30): List<Step> {
        val b = Battle(s, Monsters[monster], Lang.DE, Dice(Random(seed)), 3, false, 3)
        val steps = b.start().toMutableList()
        var n = 0
        while (b.outcome == Outcome.ONGOING && n++ < rounds) {
            if (s.hero.hp < s.hero.maxHp / 2) s.hero.restoreFully()
            steps += b.act(Action.Attack)
        }
        return steps
    }

    @Test
    fun poisonTakesHoldAndTicks() {
        var seen = false
        var ticked = false
        for (seed in 0 until 20) {
            val steps = fight(poisoner(seed), "zombie", seed)
            if (steps.any { Status.POISON in it.foeStatus }) seen = true
            if (steps.any { it.text.startsWith("Das Gift zehrt") }) ticked = true
        }
        // zombies are immune to poison
        assertFalse(seen, "zombie got poisoned")
        for (seed in 0 until 20) {
            val steps = fight(poisoner(seed), "goblin_shaman", seed)
            if (steps.any { Status.POISON in it.foeStatus }) seen = true
            if (steps.any { it.text.startsWith("Das Gift zehrt") }) ticked = true
        }
        assertTrue(seen, "poison never applied")
        assertTrue(ticked, "poison never ticked")
    }

    @Test
    fun ghoulStunsAndRemedyCures() {
        var stunned = false
        for (seed in 0 until 40) {
            val s = GameState.newGame("T", Race.HUMAN, CharClass.WIZARD)
            s.hero.gainXp(Rules.xpForLevel[6])
            s.hero.restoreFully()
            s.add("remedy", 3)
            val b = Battle(s, Monsters["ghoul"], Lang.DE, Dice(Random(seed)), 3, false, 3)
            b.start()
            var n = 0
            while (b.outcome == Outcome.ONGOING && n++ < 30) {
                if (s.hero.hp < s.hero.maxHp / 2) s.hero.restoreFully()
                val steps = if (b.heroStatus.isNotEmpty() && s.count("remedy") > 0) {
                    b.act(Action.UseItem("remedy")).also { assertTrue(b.heroStatus.isEmpty() || b.outcome != Outcome.ONGOING || it.any { st -> st.heroStatus.isEmpty() }) }
                } else {
                    b.act(Action.UseSkill(Skill.FIRE_BOLT))
                }
                if (steps.any { it.text.contains("betäubt und kann nicht") }) stunned = true
            }
        }
        assertTrue(stunned, "ghoul never stunned")
    }

    @Test
    fun elvesAreNeverStunnedByGhouls() {
        for (seed in 0 until 20) {
            val s = GameState.newGame("T", Race.ELF, CharClass.WIZARD)
            s.hero.gainXp(Rules.xpForLevel[6])
            s.hero.restoreFully()
            val steps = fight(s, "ghoul", seed)
            assertFalse(steps.any { it.text.contains("ist betäubt und kann nicht") && it.text.startsWith("T ") }, "elf stunned by ghoul")
        }
    }
}
