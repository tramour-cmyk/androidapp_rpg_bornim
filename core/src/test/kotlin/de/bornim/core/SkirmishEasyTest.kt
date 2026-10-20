package de.bornim.core

import de.bornim.core.Skirmish.Companion.ProbeFoe
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 259: light fights in MARS: the autopilot is free of strong intents, "Schnell" plays the fight through, damage staggered. */
class SkirmishEasyTest {
    private fun probe(seed: Int, foe: ProbeFoe, level: Int, cls: CharClass = CharClass.FIGHTER, merc: CharClass = CharClass.FIGHTER): Skirmish {
        val s = GameState.newGame("T", Race.HUMAN, cls)
        return Skirmish.probe(s, merc, Lang.DE, foe, Dice(Random(seed)), level)
    }

    @Test
    fun lightOnlyFourLevelsAboveTheStrongestFoeAndNeverAgainstABoss() {
        // wolves are 1/4: level 4 stands 3.75 above, level 5 4.75
        assertFalse(probe(1, ProbeFoe.WOLVES, 4).easy)
        assertTrue(probe(1, ProbeFoe.WOLVES, 5).easy)
        assertFalse(probe(1, ProbeFoe.WOLVES, Skirmish.PROBE_LEVEL).easy)
        assertFalse(probe(1, ProbeFoe.GRAK, 20).easy)
    }

    @Test
    fun damageIsStaggeredByTheGap() {
        assertEquals(1.0, probe(1, ProbeFoe.WOLVES, 6).quickHarm)
        assertEquals(0.5, probe(1, ProbeFoe.WOLVES, 8).quickHarm)
        assertEquals(0.0, probe(1, ProbeFoe.WOLVES, 11).quickHarm)
        assertEquals(1.0, probe(1, ProbeFoe.WOLVES, 3).quickHarm)
    }

    @Test
    fun aStrongIntentStopsTheAutopilotOnlyInAHardFight() {
        for (seed in 0 until 40) {
            val easy = probe(seed, ProbeFoe.WOLVES, 6)
            if (easy.intents.values.any { it.first.strong }) assertNull(easy.autopilotBlocked())
            val hard = probe(seed, ProbeFoe.WOLVES, 3)
            if (hard.intents.values.any { it.first.strong }) assertTrue(hard.autopilotBlocked() != null)
        }
    }

    @Test
    fun quickAtTheStartEndsOrStopsBelowAThird() {
        for (foe in listOf(ProbeFoe.WOLVES, ProbeFoe.SPIDER, ProbeFoe.SCOUT)) for (seed in 0 until 60) {
            val sk = probe(seed, foe, 6)
            if (!sk.easy) continue
            val r = sk.quick()
            val hero = sk.fighters.first()
            if (r.stopped) {
                assertEquals(Outcome.ONGOING, sk.outcome)
                assertTrue(hero.hp * 3 < hero.maxHp, "stops only below a third")
                assertFalse(sk.autopilot)
            } else assertTrue(sk.outcome != Outcome.ONGOING)
            assertEquals(hero.maxHp - hero.hp, r.lost.getValue("hero"))
            assertFalse(sk.byId("merc").auto, "the Söldner as set before")
        }
    }

    /** The screen hears nothing of a quick fight (it played every line afterwards, found in the preview); the lines come with the result. */
    @Test
    fun aQuickFightIsNotPlayedOnTheScreen() {
        val sk = probe(3, ProbeFoe.WOLVES, 8)
        var heard = 0
        sk.listener = { heard++ }
        val r = sk.quick()
        assertEquals(0, heard)
        assertTrue(r.events.isNotEmpty())
    }

    @Test
    fun noDamageFromTenLevelsUp() {
        for (seed in 0 until 40) {
            val sk = probe(seed, ProbeFoe.WOLVES, 11)
            val r = sk.quick()
            assertEquals(Outcome.WON, sk.outcome)
            assertTrue(r.lost.values.all { it == 0 })
        }
    }

    @Test
    fun quickInTheMiddleOfAFight() {
        val sk = probe(3, ProbeFoe.WOLVES, 6)
        sk.start()
        if (sk.outcome == Outcome.ONGOING) sk.act(Order.Wait)
        if (sk.outcome == Outcome.ONGOING && sk.fighters.first().hp * 3 >= sk.fighters.first().maxHp) sk.quick()
        assertTrue(sk.started)
    }

    /**
     * 259: the limit "4" checked with the simulation (Sokrates: victory almost always, under a quarter of the life
     * points lost): every class against each light probe foe from the lowest light level up, full damage. Prints the table.
     */
    @Test
    fun simulationOfTheLimit() {
        val rows = mutableListOf<String>()
        for (foe in listOf(ProbeFoe.WOLVES, ProbeFoe.SPIDER, ProbeFoe.SCOUT)) for (cls in CharClass.entries) {
            val cr = when (foe) { ProbeFoe.SPIDER -> Monsters[Skirmish.SPIDER].cr; else -> "1/4" }
            val first = kotlin.math.ceil(Skirmish.crValue(cr) + Skirmish.EASY_GAP).toInt()
            for (level in first..first + 3) {
            var won = 0; var stopped = 0; var lostShare = 0.0
            val n = 200
            for (seed in 0 until n) {
                val sk = probe(seed, foe, level, cls)
                val r = sk.quick()
                if (sk.outcome == Outcome.WON) won++
                if (r.stopped) stopped++
                lostShare += r.lost.getValue("hero").toDouble() / sk.fighters.first().maxHp
            }
            rows += "259 sim: %-7s %-8s Stufe %2d: Sieg %3d%%, angehalten %3d%%, LP-Verlust Held %3d%%".format(foe, cls, level, won * 100 / n, stopped * 100 / n, (lostShare * 100 / n).toInt())
            }
        }
        rows.forEach(::println)
    }
}
