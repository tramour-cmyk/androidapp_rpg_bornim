package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 86.9: drunk on mead, the hero fights as if poisoned after the SRD: disadvantage on attacks and on fleeing. */
class DrunkTest {
    private fun state(cls: CharClass, drunk: Boolean) = GameState.newGame("T", Race.HUMAN, cls).also {
        if (drunk) it.mead = Resting.DRUNK
    }

    /** Damage of the hero's first action over many fights, sober or drunk. */
    private fun firstBlow(cls: CharClass, action: Action, drunk: Boolean): Int {
        var dealt = 0
        for (seed in 0 until 800) {
            val b = Battle(state(cls, drunk), Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.missStreak = MissStreak(on = false)
            b.start()
            if (b.outcome != Outcome.ONGOING) continue
            b.act(action)
            dealt += b.enemyMaxHp - b.enemyHp
        }
        return dealt
    }

    @Test
    fun weaponBlowsLandLessOften() {
        val sober = firstBlow(CharClass.FIGHTER, Action.Attack, drunk = false)
        val drunk = firstBlow(CharClass.FIGHTER, Action.Attack, drunk = true)
        assertTrue(drunk < sober * 0.85, "drunk $drunk, sober $sober")
    }

    @Test
    fun spellAttacksLandLessOften() {
        val bolt = Action.UseSkill(Skill.FIRE_BOLT)
        val sober = firstBlow(CharClass.WIZARD, bolt, drunk = false)
        val drunk = firstBlow(CharClass.WIZARD, bolt, drunk = true)
        assertTrue(drunk < sober * 0.85, "drunk $drunk, sober $sober")
    }

    @Test
    fun fleeingFailsMoreOften() {
        fun fled(drunk: Boolean): Int = (0 until 800).count { seed ->
            val b = Battle(state(CharClass.WIZARD, drunk), Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.start()
            b.outcome == Outcome.ONGOING && b.act(Action.Flee).let { b.outcome == Outcome.FLED }
        }
        val sober = fled(false)
        val drunk = fled(true)
        assertTrue(drunk < sober * 0.85, "drunk $drunk, sober $sober")
    }

    @Test
    fun followsTheMead() {
        val s = state(CharClass.FIGHTER, drunk = true)
        assertTrue(Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(1))).drunk)
        s.mead = 0
        assertFalse(Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(1))).drunk)
    }
}
