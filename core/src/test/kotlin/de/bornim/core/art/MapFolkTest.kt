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
        assertTrue(kinds == setOf(MapFolk.Idle.WARM, MapFolk.Idle.PEER))
        println("pauses ${gaps.min()}..${gaps.max()} ms, loops ${lengths.min()}..${lengths.max()} ms")
    }
}

class MapFolkWatchTest {
    /** The folk look at a hero nearby (3 tiles), but not once it has stood still for 10 s (5la.3); moving wakes their interest again. */
    @Test
    fun loseInterestAfterTenSeconds() {
        val still = MapFolk.Stillness()
        assertTrue(MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 0L)))
        assertTrue(MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 9_900L)))
        assertTrue(!MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 10_000L)))
        assertTrue(!MapFolk.watches(-2.0, 0.0, still.forMs(64, 288, 45_000L)))
        // one step, and he looks again
        assertTrue(MapFolk.watches(-1.0, 0.0, still.forMs(96, 288, 45_100L)))
        // too far away, or standing on his own spot
        assertTrue(MapFolk.watches(-3.0, 0.0, 0L))
        assertTrue(!MapFolk.watches(-4.0, 0.0, 0L))
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

    /** 55.2: Borin at his table moves from pose to pose without a jump, and does something now and then, never on a beat. */
    @Test
    fun seatedPosesGoOverSmoothly() {
        val b = MapFolk.borin
        var last: HeroFigure.Rig? = null
        var t = 0L
        val starts = ArrayList<Long>()
        var was = MapFolk.Seat.REST
        while (t < 3_600_000L) {
            val p = MapFolk.seatPoseAt(b, t)
            val rig = MapFolk.seatRig(0.0, p)
            if (last != null) {
                fun d(x: HeroFigure.V, y: HeroFigure.V) = kotlin.math.sqrt((x.r - y.r) * (x.r - y.r) + (x.u - y.u) * (x.u - y.u) + (x.f - y.f) * (x.f - y.f))
                assertTrue(d(rig.lh, last.lh) <= 7.0 && d(rig.rh, last.rh) <= 7.0, "hand jumps at $t: $p")
                assertTrue(kotlin.math.abs(rig.headTurn - last.headTurn) <= 12.0, "head jumps at $t: $p")
            }
            // every block begins and ends at rest
            val resting = p.from in setOf(MapFolk.Seat.REST, MapFolk.Seat.BREATHE) && p.to in setOf(MapFolk.Seat.REST, MapFolk.Seat.BREATHE)
            if (t % MapFolk.SEAT_BLOCK_MS == 0L) assertTrue(resting, "block starts at $t in $p")
            if (was == MapFolk.Seat.REST && !resting) starts += t
            was = if (resting) MapFolk.Seat.REST else MapFolk.Seat.DRINK
            last = rig
            t += 50
        }
        // something is done several times a minute on the whole, but the gaps differ
        assertTrue(starts.size in 60..360, "${starts.size} actions in an hour")
        val gaps = starts.zipWithNext { a, c -> c - a }
        assertTrue(gaps.toSet().size > gaps.size / 2, "the gaps repeat: $gaps")
    }

    @Test
    fun neverOnABeat() {
        val (s, _) = sessions(night = true, hours = 3)
        val gaps = s.zipWithNext { a, b -> b.first - (a.first + a.second) }
        assertTrue(gaps.toSet().size > gaps.size / 2, "gaps repeat: $gaps")
        assertTrue(gaps.max() - gaps.min() > 30_000, "gaps too even: $gaps")
    }

    /** 239.1 (Chef 20.10., t45: the first time Garrick "ist immer in die Ausgangsbilder zurückgesprungen"): a step not drawn yet shows the nearest drawn one, never standing. */
    @Test
    fun anUndrawnSquatStepShowsTheNearestDrawnOne() {
        val f = MapFolk.garrick
        val slot = 3
        val stand = MapFolk.frame(f, slot, 0) ?: MapFolk.draw(f, slot, 0)
        val p4 = MapFolk.SquatPose(null, MapFolk.Squat.SQUAT, 4)
        var drawn: PixelImage? = null
        val until = System.currentTimeMillis() + 60_000
        while (System.currentTimeMillis() < until) {
            val img = MapFolk.squatFrame(f, slot, p4)
            if (img != null && img !== stand && img !== MapFolk.frame(f, slot, 0)) { drawn = img; break }
            Thread.sleep(20)
        }
        assertTrue(drawn != null, "step 4 never drawn")
        // step 6 is not drawn yet: step 4 stands in, not the standing picture
        val p6 = MapFolk.SquatPose(null, MapFolk.Squat.SQUAT, 6)
        val img = MapFolk.squatFrame(f, slot, p6)
        assertTrue(img != null && img !== MapFolk.frame(f, slot, 0) && img !== stand, "standing instead of a step of the squat")
    }

    /**
     * 297 (Chef 22.10.: Rowena's raised hand "sehr abgehackt"): a gesture shows only once all its pictures are drawn,
     * not before the figure stands still, and then whole, in the direction it began in, without a moment missing.
     */
    @Test
    fun gestureOnlyWhole() {
        val f = MapFolk.of("pim")!!
        val len = MapFolk.gestureMs(MapFolk.gesture(f))
        val gate = MapFolk.GestureGate()
        assertTrue(gate.frame(f, 3, 0, free = true) == null, "shown before its pictures are drawn")
        val until = System.currentTimeMillis() + 120_000
        while (!MapFolk.gestureReady(f, 3) && System.currentTimeMillis() < until) Thread.sleep(50)
        assertTrue(MapFolk.gestureReady(f, 3), "pictures not drawn in time")
        // still in a stance: it waits
        gate.frame(f, 3, null, free = true)
        assertTrue(gate.frame(f, 3, 0, free = false) == null, "begun while not standing still")
        // free a moment later: it begins then, and plays whole, though the figure turns on
        assertTrue(gate.frame(f, 3, 60, free = true) != null, "not begun once free")
        for (t in 80L until 60 + len step 20L) assertTrue(gate.frame(f, 5, t, free = true) != null, "a moment missing at $t ms")
        assertTrue(gate.frame(f, 5, 60 + len, free = true) == null, "goes on after its end")
        // too late to end with the sign: not at all
        gate.frame(f, 3, null, free = true)
        assertTrue(gate.frame(f, 3, de.bornim.core.Hail.SHOW_MS - len + 20, free = true) == null, "begun too late")
    }
}
