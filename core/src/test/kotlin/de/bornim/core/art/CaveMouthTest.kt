package de.bornim.core.art

import de.bornim.core.MapKind
import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** D1.6: beyond the edge of the cave the rock goes on, and the passage of the mouth runs straight out. */
class CaveMouthTest {
    private val cave = World.maps.values.first { it.kind == MapKind.CAVE }

    @Test
    fun insideTheMapNothingChanges() {
        for (y in 0 until cave.height) for (x in 0 until cave.width) assertEquals(cave.tile(x, y), MapCave.caveTile(cave, x, y), "$x,$y")
    }

    @Test
    fun theMouthRunsOutAndTheRockGoesOn() {
        val mouths = (0 until cave.width).filter { cave.tile(it, cave.height - 1) == Tile.CAVE_EXIT }
        assertTrue(mouths.isNotEmpty(), "kein Ausgang am unteren Rand")
        for (x in mouths) for (k in 1..MapCave.MOUTH) assertEquals(Tile.CAVE_EXIT, MapCave.caveTile(cave, x, cave.height - 1 + k), "Gang $x,+$k")
        for (x in mouths) assertEquals(Tile.CAVE_WALL, MapCave.caveTile(cave, x, cave.height + MapCave.MOUTH), "Gang endet")
        assertEquals(Tile.CAVE_WALL, MapCave.caveTile(cave, mouths.first() - 1, cave.height + 1), "Fels neben dem Gang")
        assertEquals(Tile.CAVE_WALL, MapCave.caveTile(cave, -1, -1), "Ecke")
        // the fade into the dark spares the passage, not the rock beside it
        val T = WorldArt.T
        assertEquals(1f, MapEdge.fade(cave, (mouths.first() + 0.5f) * T, (cave.height + 2.5f) * T))
        assertTrue(MapEdge.fade(cave, (mouths.first() - 3.5f) * T, (cave.height + 2.5f) * T) < 1f)
    }
}
