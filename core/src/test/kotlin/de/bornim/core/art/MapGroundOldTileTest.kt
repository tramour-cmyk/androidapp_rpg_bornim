package de.bornim.core.art

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertTrue

class MapGroundOldTileTest {
    /** The cliff about the cave mouth in the woods keeps its picture; inside the cave the new ground draws the walls (23:04). */
    @Test
    fun caveWallsKeptInTheWoodsOnly() {
        val forest = World["forest"]
        val cave = World["cave"]
        assertTrue(MapGround.keepsOldTile(forest, Tile.CAVE_WALL), "cliff in the woods lost")
        assertTrue(MapGround.keepsOldTile(forest, Tile.CAVE_ENTRANCE))
        assertTrue(!MapGround.keepsOldTile(cave, Tile.CAVE_WALL))
        assertTrue(!MapGround.keepsOldTile(forest, Tile.GRASS))
        // and the woods do have such cliff tiles about the mouth
        assertTrue((0 until forest.height).any { y -> (0 until forest.width).any { x -> forest.tile(x, y) == Tile.CAVE_WALL } })
    }
}
