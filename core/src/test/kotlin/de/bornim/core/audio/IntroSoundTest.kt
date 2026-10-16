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
}
