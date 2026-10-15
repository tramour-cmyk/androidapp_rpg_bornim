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
}
