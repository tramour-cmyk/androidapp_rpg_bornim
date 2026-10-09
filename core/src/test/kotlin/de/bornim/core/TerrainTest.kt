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
}
