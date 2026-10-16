package de.bornim.core.audio

import de.bornim.core.Intro
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class IntroSoundTest {
    @Test
    fun loopsSwellInAndNeverJump() {
        assertEquals(0f, IntroSound.loops(0).wind)
        var last = IntroSound.loops(0)
        for (t in 50L..Intro.totalMs step 50L) {
            val m = IntroSound.loops(t)
            assertTrue(kotlin.math.abs(m.wind - last.wind) < 0.02f && kotlin.math.abs(m.river - last.river) < 0.02f, "jump at $t ms: $last → $m")
            assertTrue(m.wind <= 0.3f && m.river <= 0.25f, "too loud at $t ms: $m")
            last = m
        }
    }

    @Test
    fun riverAtTheBridgeWindOnTheRoadSilentWhenBlack() {
        val hold = Intro.FADE_MS + 2000
        val road = IntroSound.loops(hold)
        val bridge = IntroSound.loops(Intro.STEP_MS + hold)
        val inn = IntroSound.loops(3 * Intro.STEP_MS + hold)
        val black = IntroSound.loops(Intro.black * Intro.STEP_MS + hold)
        assertEquals(0f, road.river)
        assertTrue(road.wind > 0f && inn.wind > 0f)
        assertTrue(bridge.river > bridge.wind, "the river is the bridge's sound: $bridge")
        assertEquals(0f, inn.river)
        assertEquals(0f, black.wind); assertEquals(0f, black.river)
    }

    @Test
    fun cricketsUnevenOnlyUnderThePaintedPictures() {
        val c = IntroSound.chirps(7, Intro.totalMs)
        assertTrue(c.size >= 6, "too few chirps: ${c.size}")
        assertTrue(c.all { it.first < Intro.black * Intro.STEP_MS }, "a chirp under the black picture")
        assertTrue(c.all { it.second in 0.05f..0.3f })
        val gaps = c.zipWithNext { a, b -> b.first - a.first }
        assertTrue(gaps.distinct().size > gaps.size / 2, "chirps too even: $gaps")
        assertEquals(c, IntroSound.chirps(7, Intro.totalMs))
    }

    @Test
    fun theNightOnlyUnderTheBlackPicture() {
        val black = Intro.black * Intro.STEP_MS
        assertEquals(0f, IntroSound.bell(black - 1))
        assertEquals(0f, IntroSound.loops(3 * Intro.STEP_MS + 3000).bell)
        val held = IntroSound.bell(black + IntroSound.BELL_IN_MS + 500)
        assertEquals(IntroSound.BELL, held)
        assertEquals(held, IntroSound.loops(black + IntroSound.BELL_IN_MS + 500).bell)
        assertTrue(IntroSound.bell(black + 1000) in 0.001f..held, "the bell swells in")
        assertTrue(IntroSound.bell(Intro.totalMs - 200) < held / 5, "the bell dies away with the end")
        assertEquals(0f, IntroSound.bell(Intro.totalMs))
        var last = 0f
        for (t in black..Intro.totalMs step 50L) { val b = IntroSound.bell(t); assertTrue(kotlin.math.abs(b - last) < 0.01f, "bell jumps at $t"); last = b }
    }

    @Test
    fun shoutsThenOneScreamBeforeTheEnd() {
        for (seed in 1L..20L) {
            val n = IntroSound.night(seed)
            val black = Intro.black * Intro.STEP_MS
            assertEquals(listOf(Sound.FAR_SHOUT, Sound.FAR_SHOUT, Sound.FAR_SHOUT, Sound.FAR_SCREAM), n.map { it.sound })
            assertTrue(n.zipWithNext().all { (a, b) -> b.ms > a.ms }, "in order: $n")
            assertTrue(n.all { it.ms > black + Intro.FADE_MS && it.ms < (Intro.black + 1) * Intro.STEP_MS }, "under the black picture: $n")
            assertEquals(setOf(0, 1, 2), n.take(3).map { it.take }.toSet(), "three different voices")
            assertTrue(n.all { it.volume in 0.05f..0.15f }, "far off and muffled: $n")
            assertEquals(n, IntroSound.night(seed))
        }
    }
}
