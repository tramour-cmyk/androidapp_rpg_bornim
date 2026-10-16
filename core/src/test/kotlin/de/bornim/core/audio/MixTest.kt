package de.bornim.core.audio

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MixTest {
    @Test
    fun fullIsAsBefore() = assertEquals(1f, Mix.gain(100, 100))

    @Test
    fun zeroOnEitherSliderIsSilent() {
        assertEquals(0f, Mix.gain(0, 100))
        assertEquals(0f, Mix.gain(100, 0))
    }

    @Test
    fun gainRisesWithEverySlider() {
        var last = -1f
        for (p in 0..100 step Mix.STEP) {
            val g = Mix.gain(100, p)
            assertTrue(g > last, "$p")
            assertEquals(g, Mix.gain(p, 100))
            last = g
        }
    }

    @Test
    fun halfWayIsAQuarterOfTheLevel() = assertEquals(0.25f, Mix.gain(50, 100))

    @Test
    fun clampKeepsRangeAndSteps() {
        assertEquals(0, Mix.clamp(-20))
        assertEquals(100, Mix.clamp(140))
        assertEquals(45, Mix.clamp(44))
        assertEquals(40, Mix.clamp(42))
    }

    @Test
    fun brightnessAtStartChangesNothing() {
        assertEquals(0f, Mix.lift(0))
        for (c in 0..255) assertEquals(c, Mix.lifted(c, Mix.lift(0)))
    }

    @Test
    fun liftRaisesBlackButLeavesWhite() {
        val a = Mix.lift(100)
        assertEquals(255, Mix.lifted(255, a))
        assertTrue(Mix.lifted(0, a) > 0)
        // never more than a dark grey: the cave stays dark (13e.6)
        assertTrue(Mix.lifted(0, a) <= 26, "${Mix.lifted(0, a)}")
        // the sign keeps standing apart from its black
        assertTrue(Mix.lifted(Mix.SIGN, a) > Mix.lifted(0, a))
    }
}
