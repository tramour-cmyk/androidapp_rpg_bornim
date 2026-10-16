package de.bornim.core.audio

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.Sex
import de.bornim.core.Stamina
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 95: the hero pants while out of breath, then more slowly and quietly, until he may run again. */
class PantingTest {
    private fun state() = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)

    /** Runs empty, then stands frame by frame (20 ms); returns each breath as (time, loudness). */
    private fun breaths(s: GameState): List<Pair<Long, Float>> {
        while (!s.winded) Stamina.step(s, 20, true, true)
        val b = Panting.Breath()
        val out = mutableListOf<Pair<Long, Float>>()
        var t = 0L
        while (s.winded && t < 60_000) {
            b.due(s, t)?.let { out += t to it }
            Stamina.step(s, 20, false, false); t += 20
        }
        assertNull(b.due(s, t), "no breath once the breath is back")
        return out
    }

    @Test
    fun noBreathHeardWhileTheHeroHasBreath() {
        val s = state()
        val b = Panting.Breath()
        for (t in 0L until 10_000L step 20) { assertNull(b.due(s, t)); Stamina.step(s, 20, true, true); if (s.winded) break }
    }

    @Test
    fun breathAfterBreathAtFirstThenSlowerAndQuieter() {
        val s = state()
        val got = breaths(s)
        assertEquals(0L, got.first().first, "the first breath comes at once")
        assertTrue(got.size >= 3, "breaths: ${got.size}")
        val gaps = got.zipWithNext { a, b -> b.first - a.first }
        assertTrue(gaps.first() <= Panting.breathMs(s.hero.sex) + 200, "at first breath after breath: $gaps")
        assertTrue(gaps.zipWithNext().all { (a, b) -> b >= a }, "the pauses only grow: $gaps")
        assertTrue(got.zipWithNext().all { (a, b) -> b.second <= a.second }, "only quieter")
        assertTrue(got.first().second >= Panting.LOUD - 0.05f && got.last().second < got.first().second)
    }

    @Test
    fun aHeroineBreathesAsAWoman() {
        assertEquals(Sound.PANT_MAN, Panting.sound(Sex.MALE))
        assertEquals(Sound.PANT_WOMAN, Panting.sound(Sex.FEMALE))
        val s = state().also { it.hero.sex = Sex.FEMALE }
        assertNotNull(breaths(s).firstOrNull())
    }
}
