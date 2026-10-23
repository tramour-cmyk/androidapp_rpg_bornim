package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

class MapFolkWalkTest {
    /** 330 (Chef 23.10.: „Moonwalk“): the folk are drawn in every picture of the walk, not half of it, wherever they walk. */
    @Test
    fun theWholeWalkIsDrawn() {
        val f = MapFolk.garrick
        MapFolk.prepare(f, 0)
        val walk = (0 until MapFigure.YAWS).map { MapFolk.walkSlot(it) }.distinct()
        assertTrue(walk.size == 8, "eight directions of walking: $walk")
        val until = System.currentTimeMillis() + 120_000
        fun all() = walk.all { s -> (0 until MapFigure.STEPS).all { st -> MapFolk.frame(f, s, st) != null } }
        while (!all() && System.currentTimeMillis() < until) Thread.sleep(100)
        assertTrue(all(), "every step of the walk in each walking direction")
    }
}
