package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

class MapFolkTest {
    /** The idle loops come at uneven times (20:53), never closer than 2 s apart, and both kinds show up. */
    @Test
    fun idleTimesVary() {
        val f = MapFolk.garrick
        val gaps = mutableListOf<Long>(); val lengths = mutableListOf<Long>()
        var was: MapFolk.Doing? = null
        var since = 0L
        val kinds = mutableSetOf<MapFolk.Idle>()
        for (t in 0L until 600_000L step 50L) {
            val d = MapFolk.doing(f, t)
            if ((d == null) != (was == null)) {
                if (d != null) { if (t > 0) gaps += t - since } else lengths += t - since
                since = t
            }
            d?.let { kinds += it.idle }
            was = d
        }
        assertTrue(gaps.size > 20, "too few loops: ${gaps.size}")
        assertTrue(gaps.min() >= 2_000, "loops too close: ${gaps.min()}")
        assertTrue(gaps.max() - gaps.min() > 8_000, "pauses too even: ${gaps.min()}..${gaps.max()}")
        assertTrue(lengths.max() - lengths.min() > 1_500, "loops too even: ${lengths.min()}..${lengths.max()}")
        assertTrue(kinds == MapFolk.Idle.entries.toSet())
        println("pauses ${gaps.min()}..${gaps.max()} ms, loops ${lengths.min()}..${lengths.max()} ms")
    }
}

class MapFolkWatchTest {
    /** The folk look at a hero nearby, but not once it has stood still for 20 s; moving wakes their interest again. */
    @Test
    fun loseInterestAfterTwentySeconds() {
        val still = MapFolk.Stillness()
        assertTrue(MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 0L)))
        assertTrue(MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 19_900L)))
        assertTrue(!MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 20_000L)))
        assertTrue(!MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 45_000L)))
        // one step, and he looks again
        assertTrue(MapFolk.watches(-1.0, 0.0, still.forMs(96, 288, 45_100L)))
        // too far away, or standing on his own spot
        assertTrue(!MapFolk.watches(-5.0, 0.0, 0L))
        assertTrue(!MapFolk.watches(0.0, 0.0, 0L))
    }
}
