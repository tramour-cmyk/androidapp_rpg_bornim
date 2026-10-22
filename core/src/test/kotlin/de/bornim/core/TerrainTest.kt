package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TerrainTest {
    @Test
    fun pathIsQuickTallGrassIsSlow() {
        assertTrue(Terrain.stepFactor(Tile.PATH) < Terrain.stepFactor(Tile.GRASS))
        assertTrue(Terrain.stepFactor(Tile.TALL_GRASS) > Terrain.stepFactor(Tile.FLOWERS))
        assertEquals(1.0, Terrain.stepFactor(Tile.GRASS))
        assertEquals(1.0, Terrain.stepFactor(Tile.WOOD_FLOOR))
    }

    /** 291 (Chef 21.10.): the low bushes south of the deep forest's path are walked through, slowly; a young spruce still stops. */
    @Test
    fun lowBushIsWalkedThroughSlowly() {
        val map = World.maps.getValue("deep_forest")
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        for ((x, y) in listOf(0 to 19, 1 to 19)) {
            assertEquals(Tile.TREE, map.tile(x, y))
            assertTrue(map.walkable(x, y, s), "bush at $x,$y")
            assertEquals(Terrain.stepFactor(Tile.TALL_GRASS), Terrain.stepFactor(map, x, y))
        }
        assertTrue(map.tile(2, 20) == Tile.TREE && !map.walkable(2, 20, s), "young spruce stops")
    }
}
