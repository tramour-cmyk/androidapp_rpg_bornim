package de.bornim.core.art

import de.bornim.core.World
import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The village hens (83b): on the ground beside the bales, never in a wall, off when the hero comes, back after. */
class MapHenTest {
    private val village = World["village"]

    private fun walkable(x: Float, y: Float) = village.tile(Math.floorDiv(x.toInt(), WorldArt.T), Math.floorDiv(y.toInt(), WorldArt.T)).walkable

    @Test
    fun twoByEachBaleInAllThreePlumages() {
        val hens = MapHen.of(village)
        assertEquals(6, hens.size)
        assertEquals(setOf(0, 1, 2), hens.map { it.variant }.toSet())
        for (h in hens) assertTrue(walkable(h.homeX, h.homeY), "hen at ${h.homeX},${h.homeY} not on free ground")
    }

    @Test
    fun theyStayOnFreeGroundAndNeverJump() {
        val bad = mutableListOf<String>()
        for (h in MapHen.of(village).map { MapHen.Hen(it.homeX, it.homeY, it.seed, it.variant) }) {
            var lx = h.x; var ly = h.y; var lyaw = Double.NaN
            // ten minutes alone, in steps of 40 ms
            for (t in 0L..600_000L step 40L) {
                val a = h.at(t, 0f, 0f, village)
                if (!walkable(a.x, a.y)) bad += "${t}ms: in ${a.x},${a.y}"
                if (MapHen.nearWater(village, a.x, a.y)) bad += "${t}ms: on the river bank ${a.x},${a.y}"
                if (hypot(a.x - lx, a.y - ly) > 2f) bad += "${t}ms: jump ${lx},${ly} -> ${a.x},${a.y}"
                if (hypot(a.x - h.homeX, a.y - h.homeY) > MapHen.ROAM + 12f) bad += "${t}ms: strayed to ${a.x},${a.y}"
                // it turns, never snaps round: at most 240° a second while not running, in steps of 40 ms
                if (!lyaw.isNaN()) { var d = (a.yaw - lyaw) % 360.0; if (d > 180) d -= 360.0 else if (d < -180) d += 360.0; if (kotlin.math.abs(d) > 10.0) bad += "${t}ms: turned ${d}°" }
                lx = a.x; ly = a.y; lyaw = a.yaw
            }
        }
        assertTrue(bad.isEmpty(), bad.take(10).joinToString("\n"))
    }

    @Test
    fun theyRunOffFromTheHeroAndComeBack() {
        for (src in MapHen.of(village)) {
            val h = MapHen.Hen(src.homeX, src.homeY, src.seed, src.variant)
            h.at(0, 0f, 0f, village)
            // the hero walks up to it from the west
            val hx = h.x - 30f; val hy = h.y
            var ran = false
            var lyaw = h.at(0, 0f, 0f, village).yaw
            for (t in 40L..3_000L step 40L) {
                val a = h.at(t, hx, hy, village)
                if (a.key == "run") ran = true
                var d = (a.yaw - lyaw) % 360.0; if (d > 180) d -= 360.0 else if (d < -180) d += 360.0
                assertTrue(kotlin.math.abs(d) <= 29.0, "hen at ${src.homeX},${src.homeY} snapped round ${d}° at ${t}ms")
                lyaw = a.yaw
            }
            assertTrue(ran, "hen at ${src.homeX},${src.homeY} did not run")
            val away = hypot(h.x - hx, h.y - hy)
            assertTrue(away > 40f, "hen at ${src.homeX},${src.homeY} only got $away px away")
            // the hero gone, it goes back to its business near home
            for (t in 3_040L..90_000L step 40L) h.at(t, 0f, 0f, village)
            val a = h.at(90_040L, 0f, 0f, village)
            assertTrue(a.key != "run", "still running")
            assertTrue(hypot(a.x - src.homeX, a.y - src.homeY) < MapHen.ROAM + 12f, "hen at ${src.homeX},${src.homeY} not back: ${a.x},${a.y}")
        }
    }

    /**
     * 129 (Chef 16.10.: the white and the brown hen on one place): two hens never share a spot, not at home, not
     * strolling, not chased by the hero, not going in under the trees or coming out again; only for a moment.
     */
    @Test
    fun neverTwoOnOneSpot() {
        val hens = MapHen.flocked(MapHen.of(village).map { MapHen.Hen(it.homeX, it.homeY, it.seed, it.variant) })
        for (a in hens) for (b in hens) if (a !== b) assertTrue(hypot(a.homeX - b.homeX, a.homeY - b.homeY) >= MapHen.GAP, "homes ${a.homeX},${a.homeY} and ${b.homeX},${b.homeY} too close")
        var close = 0; var steps = 0
        for (t in 0L..900_000L step 40L) {
            val minute = t / 60_000L
            val away = minute % 5 == 3L
            // now and then the hero walks through the hens of one bale after the other
            val chased = if (minute % 5 == 1L) hens[((t / 10_000L) % hens.size).toInt()] else null
            val at = hens.map { h -> h.at(t, (chased?.homeX ?: 0f) - 20f, chased?.homeY ?: 0f, village, away) }
            steps++
            for (i in at.indices) for (j in i + 1 until at.size) {
                val x = at[i]; val y = at[j]
                if (x.shown > 0f && y.shown > 0f && hypot(x.x - y.x, x.y - y.y) < MapHen.GAP * 0.6f) close++
            }
        }
        assertTrue(close * 100 < steps, "two hens on one spot in $close of $steps steps")
    }

    /** 94: the drawn river bank reaches over its tiles; even running from the hero a hen keeps off it. */
    @Test
    fun neverOnTheRiver() {
        for (src in MapHen.of(village)) {
            assertTrue(!MapHen.nearWater(village, src.homeX, src.homeY), "hen at ${src.homeX},${src.homeY} by the water")
            val h = MapHen.Hen(src.homeX, src.homeY, src.seed, src.variant)
            // the hero comes from every side in turn, the hen is chased about for two minutes
            for (t in 0L..120_000L step 40L) {
                val ang = (t / 6_000L) * 1.1
                val a = h.at(t, h.x + kotlin.math.sin(ang).toFloat() * 30f, h.y + kotlin.math.cos(ang).toFloat() * 30f, village)
                assertTrue(!MapHen.nearWater(village, a.x, a.y), "hen from ${src.homeX},${src.homeY} by the water at ${a.x},${a.y}, ${t}ms")
            }
        }
    }

    /** D7.1: in the rain and at dusk the hens hurry off under the trees and are gone there, never on the spot; then out again. */
    @Test
    fun underTheTreesInTheRainAndOutAgain() {
        // with the others of the flock at home (129: each its own side of the trees)
        val flock = MapHen.flocked(MapHen.of(village).map { MapHen.Hen(it.homeX, it.homeY, it.seed, it.variant) })
        for (src in MapHen.of(village)) {
            val h = flock.first { it.seed == src.seed && it.homeX == src.homeX }
            for (t in 0L..2_000L step 40L) h.at(t, 0f, 0f, village)
            val sx = h.x; val sy = h.y
            var lx = h.x; var ly = h.y; var ls = 1f; var goneAt = -1L
            for (t in 2_040L..40_000L step 40L) {
                val a = h.at(t, 0f, 0f, village, away = true)
                assertTrue(hypot(a.x - lx, a.y - ly) <= 2f, "hen from ${src.homeX},${src.homeY} jumped at ${t}ms")
                assertTrue(ls - a.shown <= 0.05f, "hen from ${src.homeX},${src.homeY} vanished at ${t}ms (${ls} -> ${a.shown})")
                if (a.shown <= 0f && goneAt < 0) goneAt = t
                lx = a.x; ly = a.y; ls = a.shown
            }
            assertTrue(goneAt > 0, "hen from ${src.homeX},${src.homeY} never went in")
            assertTrue(hypot(lx - sx, ly - sy) > 10f, "hen from ${src.homeX},${src.homeY} went in on the spot")
            assertTrue(village.tile(Math.floorDiv(lx.toInt(), WorldArt.T), Math.floorDiv(ly.toInt(), WorldArt.T)) == de.bornim.core.Tile.TREE ||
                hypot(lx - h.homeX, ly - h.homeY) > 0f, "hen from ${src.homeX},${src.homeY} not under trees")
            // dry again: it comes out softly and goes home
            for (t in 40_040L..120_000L step 40L) {
                val a = h.at(t, 0f, 0f, village)
                assertTrue(a.shown - ls <= 0.05f, "hen from ${src.homeX},${src.homeY} popped up at ${t}ms")
                assertTrue(hypot(a.x - lx, a.y - ly) <= 2f, "hen from ${src.homeX},${src.homeY} jumped coming out at ${t}ms")
                lx = a.x; ly = a.y; ls = a.shown
            }
            assertEquals(1f, ls)
            assertTrue(hypot(lx - src.homeX, ly - src.homeY) < MapHen.ROAM + 12f, "hen from ${src.homeX},${src.homeY} not home again: ${lx},${ly}")
        }
    }

    /**
     * 94 (test of 0.1.752: the hens flickered): every picture half an hour among the hens calls for fits on their own
     * shelf, so none is pushed out and drawn again while a hen waits for it (on the villagers' 360 they did not fit).
     */
    @Test
    fun theirPicturesFitOnTheirShelf() {
        val keys = HashSet<String>()
        val hens = MapHen.of(village).map { MapHen.Hen(it.homeX, it.homeY, it.seed, it.variant) }
        val cx = hens.map { it.homeX }.average().toFloat(); val cy = hens.map { it.homeY }.average().toFloat()
        for (t in 0L..1_800_000L step 40L) {
            // the hero comes by now and then, round and through the yard
            val a = t / 9_000.0
            val r = if ((t / 30_000) % 2 == 0L) 30f else 160f
            val hx = cx + (kotlin.math.cos(a) * r).toFloat(); val hy = cy + (kotlin.math.sin(a) * r).toFloat()
            val away = (t / 120_000) % 4 == 3L
            for (h in hens) { val at = h.at(t, hx, hy, village, away); if (at.shown > 0f) keys += MapHen.key(at, MapFigure.slot(at.yaw)) }
        }
        println("hen pictures in 30 minutes: ${keys.size}")
        assertTrue(keys.size > 360, "the test no longer shows the old trouble (${keys.size})")
        assertTrue(keys.size <= MapHen.SHELF, "${keys.size} pictures, room for ${MapHen.SHELF}")
    }
}
