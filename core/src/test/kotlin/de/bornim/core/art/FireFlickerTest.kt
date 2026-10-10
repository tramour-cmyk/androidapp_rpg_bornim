package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

/** The fire in a room's hearth seen diagonally (13n): picture after picture, never a jump, each standing an uneven while. */
class FireFlickerTest {
    @Test
    fun neverJumpsAndStandsUnevenly() {
        var last = MapRoomIso.fireFrame(0)
        var since = 0L
        val stands = mutableSetOf<Long>()
        for (t in 1L..120_000L) {
            val f = MapRoomIso.fireFrame(t)
            if (f != last) {
                assertTrue(Math.floorMod(f - last, MapRoomIso.FIRE_FRAMES) == 1, "jump from $last to $f at $t ms")
                stands += t - since
                since = t
                last = f
            }
            assertTrue(f in 0 until MapRoomIso.FIRE_FRAMES)
        }
        assertTrue(stands.size >= 6, "too even: ${stands.sorted()}")
        assertTrue(stands.all { it in 60..170 }, "too short or long: ${stands.sorted()}")
    }
}
