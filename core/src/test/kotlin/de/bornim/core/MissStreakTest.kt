package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Topic 18: the hero's runs of bad luck are softened, unseen, within one fight. */
class MissStreakTest {
    @Test
    fun bonusStartsAfterThreeMissesAndStopsAtFour() {
        val s = MissStreak()
        val bonuses = (1..7).map { s.miss(); s.bonus }
        assertEquals(listOf(0, 0, 2, 3, 4, 4, 4), bonuses)
        assertEquals(7, s.longest)
    }

    @Test
    fun aHitStartsOver() {
        val s = MissStreak()
        repeat(4) { s.miss() }
        s.hit()
        assertEquals(0, s.bonus)
        s.miss(); s.miss()
        assertEquals(0, s.bonus)
        assertEquals(4, s.longest)
    }

    @Test
    fun offOnlyCounts() {
        val s = MissStreak(on = false)
        repeat(5) { s.miss() }
        assertEquals(0, s.bonus)
        assertEquals(5, s.longest)
    }

    @Test
    fun eachFightStartsWithoutStreak() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        val b = Battle(s, Monsters["goblin"], Lang.EN, Dice(Random(1)))
        assertEquals(0, b.missStreak.misses)
    }

    /** Every class against an early foe and a harder one: longest runs of misses with and without the help. */
    @Test
    fun longRunsBecomeRarer() {
        val report = StringBuilder()
        var longOff = 0
        var longOn = 0
        for (cls in listOf(CharClass.FIGHTER, CharClass.WIZARD, CharClass.ROGUE, CharClass.CLERIC)) {
            for (m in listOf("goblin", "bugbear")) {
                val off = runs(cls, m, on = false)
                val on = runs(cls, m, on = true)
                report.appendLine("${cls.name.padEnd(8)} ${m.padEnd(8)} ohne: ${off.line()}   mit: ${on.line()}")
                longOff += off.atLeast4
                longOn += on.atLeast4
            }
        }
        println(report)
        assertTrue(longOn < longOff, "runs of four misses or more should become rarer ($longOn vs $longOff)")
    }

    private class Result(val wins: Int, val atLeast4: Int, val atLeast5: Int, val longest: Int, val n: Int) {
        fun line() = "Sieg ${pct(wins)}  ≥4 in Folge ${pct(atLeast4)}  ≥5 ${pct(atLeast5)}  längste $longest"
        private fun pct(k: Int) = "%3.0f%%".format(k * 100.0 / n)
    }

    private fun runs(cls: CharClass, monster: String, on: Boolean, n: Int = 400): Result {
        val rng = Random(cls.ordinal * 1000 + monster.hashCode())
        var wins = 0; var a4 = 0; var a5 = 0; var longest = 0
        repeat(n) {
            val s = GameState.newGame("X", Race.HUMAN, cls)
            if (monster == "bugbear") s.hero.gainXp(Rules.xpForLevel[3])
            s.hero.restoreFully()
            val b = Battle(s, Monsters[monster], Lang.EN, Dice(rng))
            b.missStreak = MissStreak(on)
            b.start()
            var turns = 0
            while (b.outcome == Outcome.ONGOING && turns++ < 50) {
                b.act(if (cls == CharClass.WIZARD) Action.UseSkill(Skill.FIRE_BOLT) else Action.Attack)
            }
            if (b.outcome == Outcome.WON) wins++
            val l = b.missStreak.longest
            if (l >= 4) a4++
            if (l >= 5) a5++
            longest = maxOf(longest, l)
        }
        return Result(wins, a4, a5, longest, n)
    }
}
