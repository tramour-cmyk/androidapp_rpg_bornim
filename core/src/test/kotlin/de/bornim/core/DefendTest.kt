package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

class DefendTest {
    /** How often the foe's attack lands in one round, defending or not, over many fights. */
    private fun hitRate(defend: Boolean): Double {
        var hits = 0; var tries = 0
        for (seed in 0 until 600) {
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
            val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.start()
            if (b.outcome != Outcome.ONGOING) continue
            val steps = b.act(Action.Defend)
            val foe = steps.indexOfFirst { it.anim == Anim.ENEMY_ACT }
            if (foe < 0) continue
            tries++
            if (steps.drop(foe).any { it.anim == Anim.HERO_HIT || it.anim == Anim.HERO_FAINT }) hits++
        }
        return hits.toDouble() / tries
    }

    @Test
    fun defendingGivesTheFoeDisadvantage() {
        val open = run {
            // without defending: the hero attacks, then the foe answers
            var hits = 0; var tries = 0
            for (seed in 0 until 600) {
                val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
                val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
                b.start()
                if (b.outcome != Outcome.ONGOING) continue
                val steps = b.act(Action.Attack)
                val foe = steps.indexOfFirst { it.anim == Anim.ENEMY_ACT }
                if (foe < 0) continue
                tries++
                if (steps.drop(foe).any { it.anim == Anim.HERO_HIT || it.anim == Anim.HERO_FAINT }) hits++
            }
            hits.toDouble() / tries
        }
        val guarded = hitRate(defend = true)
        assertTrue(guarded < open * 0.85, "defending should cut the foe's hits clearly: open $open, defending $guarded")
    }

    @Test
    fun aMissedFoeOpensACounter() {
        var countered = false
        for (seed in 0 until 200) {
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
            val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.start()
            if (b.outcome != Outcome.ONGOING) continue
            val first = b.act(Action.Defend)
            if (b.outcome != Outcome.ONGOING || !b.counter) continue
            assertTrue(first.any { it.text.contains("Lücke") })
            val next = b.act(Action.Attack)
            assertTrue(next.any { it.text.contains("nutzt die Lücke") }, "the counter is used on the next attack")
            assertTrue(!b.counter)
            countered = true
            break
        }
        assertTrue(countered, "some fight should give a counter")
    }
}
