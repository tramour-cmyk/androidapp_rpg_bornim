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

class MapFolkWardTest {
    /** The torch scene: brand out of the fire, swung at the beast back and forth, put back; then over. */
    @Test
    fun wardSceneRunsInOrder() {
        val seq = (0L until MapFolk.WARD_MS step 50L).map { MapFolk.wardAt(it)!! }
        assertTrue(seq.first().ward == MapFolk.Ward.GRAB && !seq.first().faceBeast)
        assertTrue(seq.last().ward == MapFolk.Ward.GRAB && !seq.last().faceBeast)
        val swings = seq.filter { it.ward == MapFolk.Ward.LEFT || it.ward == MapFolk.Ward.RIGHT }
        assertTrue(swings.all { it.faceBeast })
        // several changes of side while swinging
        val changes = swings.zipWithNext().count { (a, b) -> a.ward != b.ward }
        assertTrue(changes >= 6, "only $changes swings")
        assertTrue(MapFolk.wardAt(-1) == null && MapFolk.wardAt(MapFolk.WARD_MS) == null)
    }
}

/** Garrick squatting at his fire (10.10., 3): now and then, longer at night, nodding off only at night, never on a beat. */
class MapFolkSquatTest {
    private val g = MapFolk.garrick

    /** The squatting sessions over [hours] of play: (start, length) in ms, and what poses showed. */
    private fun sessions(night: Boolean, hours: Int = 2): Pair<List<Pair<Long, Long>>, Set<MapFolk.Squat>> {
        val out = mutableListOf<Pair<Long, Long>>(); val poses = HashSet<MapFolk.Squat>()
        var from = -1L
        var t = 0L
        while (t < hours * 3_600_000L) {
            val p = MapFolk.squatAt(g, t, night)
            if (p != null) poses += p
            if (p != null && from < 0) from = t
            if (p == null && from >= 0) { out += from to (t - from); from = -1 }
            t += 100
        }
        return out to poses
    }

    @Test
    fun onlyTheFireKeeperSquats() {
        assertTrue(MapFolk.squats(g))
        assertTrue(MapFolk.drafts.none { MapFolk.squats(it) })
    }

    @Test
    fun byDaySometimesStokingNeverDozing() {
        val (s, poses) = sessions(night = false)
        assertTrue(s.size in 30..110, "sessions by day: ${s.size}")
        assertTrue(MapFolk.Squat.DOZE !in poses)
        assertTrue(MapFolk.Squat.STOKE_A in poses && MapFolk.Squat.STOKE_B in poses && MapFolk.Squat.SQUAT in poses)
        assertTrue(s.all { it.second in 8_000L..20_000L }, "lengths: ${s.map { it.second }}")
    }

    @Test
    fun atNightMoreOftenLongerAndHeNodsOff() {
        val (day, _) = sessions(night = false)
        val (night, poses) = sessions(night = true)
        assertTrue(night.size > day.size, "night ${night.size} vs day ${day.size}")
        assertTrue(night.sumOf { it.second } > 2 * day.sumOf { it.second })
        assertTrue(MapFolk.Squat.DOZE in poses)
    }

    /** 10.10., 3a: no pose snaps into the next; between two moments 50 ms apart the body moves only a little. */
    @Test
    fun posesGoOverSmoothly() {
        for (night in listOf(false, true)) {
            var last: HeroFigure.Rig? = null
            var t = 0L
            var down = 0
            while (t < 2 * 3_600_000L) {
                val p = MapFolk.squatPoseAt(g, t, night)
                val rig = if (p == null) null else MapFolk.squatRig(0.0, p)
                if (rig != null && last != null) {
                    assertTrue(kotlin.math.abs(rig.crouch - last.crouch) <= 20.5, "crouch jumps at $t: ${last.crouch} -> ${rig.crouch}")
                    assertTrue(kotlin.math.abs(rig.headDown - last.headDown) <= 8.5, "head jumps at $t night=$night: ${last.headDown} -> ${rig.headDown}; " + (t - 300..t + 100 step 50).joinToString { "$it:" + MapFolk.squatPoseAt(g, it, night) })
                }
                // he starts and ends standing, so no session begins or ends crouched
                if ((rig == null) != (last == null)) assertTrue((rig ?: last)!!.crouch < 1.0, "begins or ends crouched at $t")
                if (rig != null && rig.crouch > 30) down++
                last = rig
                t += 50
            }
            assertTrue(down > 0)
        }
    }

    @Test
    fun neverOnABeat() {
        val (s, _) = sessions(night = true, hours = 3)
        val gaps = s.zipWithNext { a, b -> b.first - (a.first + a.second) }
        assertTrue(gaps.toSet().size > gaps.size / 2, "gaps repeat: $gaps")
        assertTrue(gaps.max() - gaps.min() > 30_000, "gaps too even: $gaps")
    }
}
