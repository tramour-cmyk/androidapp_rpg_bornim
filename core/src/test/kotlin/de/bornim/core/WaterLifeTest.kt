package de.bornim.core

import de.bornim.core.art.MapGround
import de.bornim.core.art.MapLight
import de.bornim.core.art.WaterLife
import de.bornim.core.audio.RiverSound
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 221: life on the water lies only on open water; the river's glints drift with it; the night's streaks need the dark. */
class WaterLifeTest {
    private val village = Story.village
    private val forest = Story.forest

    private fun whole(map: MapDef) = intArrayOf(0, 0, map.width - 1, map.height - 1)

    @Test
    fun theVillageRiverRunsEastAndThePondLiesStill() {
        for ((x, y) in RiverSound.running(village).filter { (x, y) -> (-1..1).all { d -> village.tile(x, y + d) == Tile.WATER && village.tile(x + d, y) == Tile.WATER } }) {
            val (fx, fy) = WaterLife.flow(village, x, y)
            assertTrue(fx > 0.9f && abs(fy) < 0.45f, "flow at $x,$y: $fx,$fy")
        }
        for (y in 0 until forest.height) for (x in 0 until forest.width) if (forest.tile(x, y) == Tile.WATER && (x to y) !in RiverSound.running(forest).toSet())
            assertEquals(0f to 0f, WaterLife.flow(forest, x, y))
    }

    @Test
    fun glintsAndRingsLieOnOpenWaterOnly() {
        for (map in listOf(village, forest)) {
            val (x0, y0, x1, y1) = whole(map).toList()
            var glints = 0
            for (t in 0L until 20_000L step 700) for (l in WaterLife.glints(map, t, x0, y0, x1, y1, 1f)) {
                glints++
                for (s in listOf(-1f, 1f)) assertTrue(MapGround.water(map, l.x + s * l.ux * l.half, l.y + s * l.uy * l.half) > WaterLife.OPEN, "glint on the bank in ${map.id}")
            }
            assertTrue(glints > 50, "${map.id}: only $glints glints")
            assertTrue(WaterLife.rings(map, 0f, 1000L, x0, y0, x1, y1).isEmpty())
            val rings = WaterLife.rings(map, 1f, 1000L, x0, y0, x1, y1)
            assertTrue(rings.isNotEmpty())
            for (r in rings) assertTrue(MapGround.water(map, r.x, r.y) > WaterLife.OPEN)
        }
    }

    @Test
    fun glintsDriftSlowlyWithTheRiver() {
        val (x, y) = RiverSound.running(village).first { (x, y) -> WaterLife.flow(village, x, y).first > 0.9f }
        val a = WaterLife.glints(village, 1000L, x, y, x, y, 1f)
        val b = WaterLife.glints(village, 1100L, x, y, x, y, 1f)
        for (g in a) b.firstOrNull { abs(it.y - g.y) < 0.5f && it.x > g.x }?.let { assertTrue(it.x - g.x < 2f, "drifts too fast") }
    }

    @Test
    fun streaksOnlyAtNightAndOnOpenWater() {
        val (x0, y0, x1, y1) = whole(village).toList()
        val lights = MapLight.sources(village)
        val mid = village.width * 16.0 to village.height * 16.0
        assertTrue(WaterLife.streaks(village, lights, 1f, 0L, x0, y0, x1, y1, mid.first, mid.second).isEmpty())
        val night = WaterLife.streaks(village, lights, 0f, 0L, x0, y0, x1, y1, mid.first, mid.second)
        assertTrue(night.isNotEmpty())
        for (l in night) assertTrue(MapGround.water(village, l.x - 0.8f, l.y) > 0.6f || MapGround.water(village, l.x + 0.8f, l.y) > 0.6f)
    }
}
