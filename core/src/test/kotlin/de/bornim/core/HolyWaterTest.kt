package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** Holy water only harms undead, 2d6 radiant as in the SRD (35); against anything else it stays in the bag. */
class HolyWaterTest {
    private fun state(): GameState {
        val s = GameState.newGame("K", Race.HUMAN, CharClass.FIGHTER)
        s.hero.restoreFully()
        s.add("holy_water", 2)
        return s
    }

    @Test
    fun keptAgainstTheLiving() {
        val s = state()
        val b = Battle(s, Monsters["giant_rat"], Lang.DE, Dice(Random(1)), 1, false, 1)
        b.start()
        assertNotNull(b.blockedItem("holy_water"))
        assertNull(b.blockedItem("alchemist_fire"))
        val hp = b.enemyHp
        val steps = b.act(Action.UseItem("holy_water"))
        assertEquals(2, s.count("holy_water"))
        assertEquals(hp, b.enemyHp)
        assertTrue(steps.any { "nur gegen Untote" in it.text })
    }

    /** 2d6 (+ throw bonus), then the house rule for radiant against undead: half again (3–18 for a plain hero). */
    @Test
    fun twoD6AgainstUndead() {
        val bonus = Perks.throwBonus(state().hero)
        val hits = (1..300).map { seed ->
            val s = state()
            val b = Battle(s, Monsters["zombie"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.start()
            assertNull(b.blockedItem("holy_water"))
            val text = b.act(Action.UseItem("holy_water")).joinToString(" ") { it.text }
            Regex("Zombie erleidet (\\d+) Schaden").find(text)!!.groupValues[1].toInt()
        }
        val lo = (2 + bonus).let { it + it / 2 }
        val hi = (12 + bonus).let { it + it / 2 }
        assertTrue(hits.all { it in lo..hi }, "Schaden ${hits.min()}..${hits.max()}")
        assertEquals(hi, hits.max())
    }
}
