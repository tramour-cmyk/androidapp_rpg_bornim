package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

/** Monte-Carlo check that early fights are winnable but not trivial. */
class BalanceTest {
    private fun winRate(cls: CharClass, monster: String, level: Int, runs: Int = 400, geared: Boolean = Monsters[monster].boss): Double {
        val rng = Random(cls.ordinal * 1000 + monster.hashCode())
        var wins = 0
        repeat(runs) {
            val s = GameState.newGame("X", Race.HUMAN, cls)
            if (level > 1) s.hero.gainXp(Rules.xpForLevel[level])
            if (geared) {
                s.equipFromBag(s.addGear(Uniques.make(Story.classWeapon(cls), 0, 3)))
                s.equipFromBag(s.addGear(Uniques.make("cloak_protection", 0, 3)))
                s.add("potion", 3); s.add("greater_potion", 1)
            }
            s.hero.restoreFully()
            val b = Battle(s, Monsters[monster], Lang.EN, Dice(rng))
            b.start()
            var turns = 0
            while (b.outcome == Outcome.ONGOING && turns++ < 50) {
                val h = s.hero
                val action = when {
                    h.hp < h.maxHp * 0.35 && s.count("greater_potion") > 0 -> Action.UseItem("greater_potion")
                    h.hp < h.maxHp * 0.35 && s.count("potion") > 0 -> Action.UseItem("potion")
                    cls == CharClass.FIGHTER && h.hp < h.maxHp / 2 && b.blocked(Skill.SECOND_WIND) == null -> Action.UseSkill(Skill.SECOND_WIND)
                    cls == CharClass.WIZARD && b.blocked(Skill.MAGE_ARMOR) == null -> Action.UseSkill(Skill.MAGE_ARMOR)
                    cls == CharClass.WIZARD && b.blocked(Skill.MAGIC_MISSILE) == null -> Action.UseSkill(Skill.MAGIC_MISSILE)
                    cls == CharClass.WIZARD -> Action.UseSkill(Skill.FIRE_BOLT)
                    cls == CharClass.CLERIC && h.hp < h.maxHp / 2 && b.blocked(Skill.CURE_WOUNDS) == null -> Action.UseSkill(Skill.CURE_WOUNDS)
                    cls == CharClass.ROGUE && b.blocked(Skill.FEINT) == null -> Action.UseSkill(Skill.FEINT)
                    else -> Action.Attack
                }
                b.act(action)
            }
            if (b.outcome == Outcome.WON) wins++
        }
        return wins.toDouble() / runs
    }

    @Test
    fun earlyFightsAreFair() {
        val report = StringBuilder()
        for (cls in CharClass.entries) {
            val line = listOf("giant_rat" to 1, "wolf" to 1, "goblin" to 1, "skeleton" to 2, "giant_spider" to 3, "bugbear" to 3, "hobgoblin_captain" to 4)
                .joinToString("  ") { (m, l) -> "$m@L$l=${"%.0f".format(winRate(cls, m, l) * 100)}%" }
            report.appendLine("${cls.name.padEnd(8)} $line")
        }
        println(report)
        for (cls in CharClass.entries) assertTrue(winRate(cls, "goblin", 1) > 0.6, "$cls too weak vs goblin")
    }
}
