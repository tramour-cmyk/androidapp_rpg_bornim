package de.bornim.core

import kotlin.math.atan2
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * 70.3 B / 70.6 A: the procession walks once along the lower street and up the temple path, every bearer is seen at the start
 * and gone behind the temple's corner before the next picture fades in; flames flicker within bounds.
 */
class IntroLifeTest {
    private val left = atan2(-(IntroLife.W / 2), IntroLife.F); private val right = -left

    private fun seen(x: Float, z: Float) = z > 0 && atan2(x, z) in left..right && !IntroLife.behindTemple(x, z)

    @Test
    fun everyBearerIsSeenAtTheStartAndGoneBeforeTheNextPicture() {
        for ((i, b) in IntroLife.bearers.withIndex()) {
            val (x0, z0) = IntroLife.at(i, 0L)
            assertTrue(seen(x0, z0) && seen(x0 + IntroLife.tipX(b), z0), "bearer $i seen at the start")
            val (x1, z1) = IntroLife.at(i, Intro.STEP_MS - 400)
            // the whole figure: its left and right edge and the torch beside it
            for (dx in listOf(-0.3f, 0.3f, IntroLife.tipX(b) + 0.1f)) assertTrue(IntroLife.behindTemple(x1 + dx, z1), "bearer $i hidden at the end (dx $dx)")
        }
    }

    @Test
    fun theyWalkOnTheWayAndNeverBack() {
        for (i in IntroLife.bearers.indices) {
            var last = Float.MAX_VALUE
            for (u in 0L..Intro.STEP_MS step 100) {
                val (x, z) = IntroLife.at(i, u)
                val a = atan2(x, z)
                assertTrue(a <= last + 1e-4f, "bearer $i keeps going towards the temple (left in the picture)")
                last = a
            }
        }
    }

    @Test
    fun theCutOutsDoNotOverlapOnTheSheet() {
        for (i in 1 until IntroLife.bearers.size)
            assertTrue(IntroLife.slotX(i - 1) + IntroLife.BOX[2] <= IntroLife.slotX(i) + IntroLife.BOX[0], "slots $i")
        assertTrue(IntroLife.slotX(IntroLife.bearers.size - 1) + IntroLife.BOX[2] <= IntroLife.W)
    }

    @Test
    fun flamesFlickerGently() {
        for (seed in 0 until 20) for (ms in 0L..20_000L step 37) {
            val f = IntroLife.flicker(seed, ms)
            assertTrue(f in 0.78f..1.22f, "flicker $f")
        }
    }
}
