package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 70.3 B: the torch bearers walk once and stand at the door before the next picture; flames flicker within bounds. */
class IntroLifeTest {
    @Test
    fun theWalkHappensOnceAndEndsAtTheDoor() {
        assertEquals(0f, IntroLife.walk(0L))
        assertEquals(1f, IntroLife.walk(IntroLife.WALK_TO))
        assertTrue(IntroLife.WALK_TO < Intro.STEP_MS, "stands still before the next picture fades in")
        val (dx, dz) = IntroLife.offset(Intro.STEP_MS + Intro.FADE_MS)
        assertEquals(0f, dx, 1e-6f); assertEquals(0f, dz, 1e-6f)
        var last = -1f
        for (u in 0L..Intro.STEP_MS step 50) { val w = IntroLife.walk(u); assertTrue(w >= last); last = w }
    }

    @Test
    fun theLayerSitsWhereItWasPaintedAtTheEnd() {
        val (k, shift) = IntroLife.layer(IntroLife.WALK_TO)
        assertEquals(1f, k, 1e-6f)
        assertEquals(0f, shift, 1e-6f)
        val (k0, shift0) = IntroLife.layer(0L)
        assertTrue(k0 > 1f && shift0 < 0f, "starts nearer and further left")
    }

    @Test
    fun flamesFlickerGently() {
        for (seed in 0 until 20) for (ms in 0L..20_000L step 37) {
            val f = IntroLife.flicker(seed, ms)
            assertTrue(f in 0.78f..1.22f, "flicker $f")
        }
        for (k in 0 until IntroLife.SMOKE_PUFFS) for (ms in 0L..30_000L step 101) assertTrue(IntroLife.puff(k, ms) in 0f..1f)
    }
}
