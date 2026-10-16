package de.bornim.core.art

import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** D9.2: the shadow layer is drawn in the background; asking for it while drawing never waits. */
class SunLayerTest {
    @Test
    fun theLayerComesFromTheBackgroundAndMatchesTheOneDrawnAtOnce() {
        val map = World["deep_forest"]
        val stand = MapSun.Stand.EVENING
        MapSun.trim(); MapSun.trim()
        val t0 = System.nanoTime()
        val first = MapSun.ready(map, stand)
        val asked = (System.nanoTime() - t0) / 1_000_000
        // asked before it was drawn: nothing yet, and at once (drawing it takes far longer)
        if (first == null) assertTrue(asked < 50, "asking waited $asked ms")
        var r = first
        val until = System.currentTimeMillis() + 30_000
        while (r == null && System.currentTimeMillis() < until) { Thread.sleep(20); r = MapSun.ready(map, stand) }
        assertNotNull(r)
        assertTrue(r.pieces.isNotEmpty())
        assertEquals(r.pieces, MapSun.shadows(map, stand))
    }

    @Test
    fun underARoofThereIsNoLayer() {
        val inside = World.maps.values.first { it.kind != de.bornim.core.MapKind.FOREST && it.kind != de.bornim.core.MapKind.TOWN }
        assertNull(MapSun.ready(inside))
        assertTrue(MapSun.shadows(inside).isEmpty())
    }
}

/** 89: a person in the shadow of a house is drawn darker, in the sun as bright as ever. */
class FigureShadeTest {
    @Test
    fun aPersonInAHousesShadowIsDarkerThanInTheSun() {
        val map = World["village"]
        val r = assertNotNull(MapSun.drawn(map, MapSun.Stand.EVENING))
        // evening: long shadows to the east, so just east of a house's wall lies in its shadow
        val (f, _) = MapTownIso.houses(map).first()
        val shade = MapSun.bright(r, f.x + f.n + 0.6, f.y + 0.5)
        assertTrue(shade < 0.75f, "beside the house $shade")
        val bright = (0 until map.height).flatMap { y -> (0 until map.width).map { x -> MapSun.bright(r, x + 0.5, y + 0.5) } }.max()
        assertEquals(1f, bright, 0.001f)
    }
}
