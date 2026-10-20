package de.bornim.core

import de.bornim.core.art.PlaceGlide
import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 249: a change of place in a MARS fight is a glide, never a jump (Sprungtest for Platzwechsel). */
class PlaceGlideTest {
    /** the largest step between two frames 16 ms apart, in metres */
    private fun widest(steps: List<Pair<Double, Double>>) = steps.zipWithNext { p, q -> hypot(q.first - p.first, q.second - p.second) }.max()

    @Test
    fun aSwapOfRowsGlides() {
        val g = PlaceGlide()
        val seen = mutableListOf<Pair<Double, Double>>()
        // stands at the front (-1.0, 0), then belongs at the back (-2.5, 0.8)
        for (t in 0L..600L step 16) seen += if (t < 100) g.at("hero", -1.0, 0.0, t) else g.at("hero", -2.5, 0.8, t)
        val way = hypot(1.5, 0.8)
        // over 350 ms at 16 ms a frame an even glide moves way / 22 a frame; eased, at most 1.5 times that
        assertTrue(widest(seen) < way / 22 * 1.6, "Schritt ${widest(seen)} m zu groß")
        assertEquals(-2.5, seen.last().first, 1e-9)
        assertEquals(0.8, seen.last().second, 1e-9)
    }

    @Test
    fun aChangeOnTheWayStartsWhereItIs() {
        val g = PlaceGlide()
        val seen = mutableListOf<Pair<Double, Double>>()
        for (t in 0L..800L step 16) seen += when {
            t < 100 -> g.at("wolf", 1.0, 0.0, t)
            t < 250 -> g.at("wolf", 2.5, 0.0, t)
            else -> g.at("wolf", 1.5, -0.8, t)
        }
        assertTrue(widest(seen) < 0.12, "Schritt ${widest(seen)} m: Sprung beim zweiten Wechsel")
        assertTrue(!g.moving("wolf", 800))
    }

    @Test
    fun theFirstPlaceIsTakenAtOnce() {
        val g = PlaceGlide()
        assertEquals(Pair(2.0, 1.0), g.at("goblin", 2.0, 1.0, 5000))
        assertTrue(!g.moving("goblin", 5000))
    }
}
