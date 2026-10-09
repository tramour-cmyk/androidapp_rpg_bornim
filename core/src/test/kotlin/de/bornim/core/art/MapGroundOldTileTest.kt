package de.bornim.core.art

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertTrue

class MapGroundOldTileTest {
    /** The cliff about the cave mouth in the woods is drawn as a rock face of its own (1b); inside the cave the new ground draws the walls (23:04). */
    @Test
    fun caveWallsKeptInTheWoodsOnly() {
        val forest = World["forest"]
        val cave = World["cave"]
        // every rock tile in the woods is covered by the new rock face
        for (y in 0 until forest.height) for (x in 0 until forest.width) if (forest.tile(x, y) == Tile.CAVE_WALL || forest.tile(x, y) == Tile.CAVE_ENTRANCE) {
            val firstOfRun = (0..x).reversed().first { forest.tile(it - 1, y).let { t -> t != Tile.CAVE_WALL && t != Tile.CAVE_ENTRANCE } }
            assertTrue(!MapFlora.objects(forest, firstOfRun, y).isNullOrEmpty(), "no rock face at $x,$y")
        }
        assertTrue(!MapGround.keepsOldTile(forest, Tile.CAVE_WALL))
        assertTrue(!MapGround.keepsOldTile(cave, Tile.CAVE_WALL))
        assertTrue(!MapGround.keepsOldTile(forest, Tile.GRASS))
        // and the woods do have such cliff tiles about the mouth
        assertTrue((0 until forest.height).any { y -> (0 until forest.width).any { x -> forest.tile(x, y) == Tile.CAVE_WALL } })
    }
}
