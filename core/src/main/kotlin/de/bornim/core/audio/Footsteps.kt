package de.bornim.core.audio

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.floor

/**
 * The hero's steps (74, user 14.10., 20:4x): one sound each time a foot sets down, by what lies under it; running,
 * the steps come closer together and a little quieter (74a).
 */
object Footsteps {
    /** The sound of a step on [tile] of [map]. */
    fun sound(map: MapDef, tile: Tile): Sound = when {
        map.kind == MapKind.CAVE -> Sound.STEP_STONE
        // the temple's floor is of stone slabs (13)
        map.kind == MapKind.INTERIOR && map.id == "temple" -> Sound.STEP_COBBLE
        map.kind == MapKind.INTERIOR -> Sound.STEP_WOOD
        tile == Tile.BRIDGE -> Sound.STEP_WOOD
        tile == Tile.COBBLE -> Sound.STEP_COBBLE
        tile == Tile.PATH || tile == Tile.DOOR || tile == Tile.CAVE_ENTRANCE -> Sound.STEP_EARTH
        else -> Sound.STEP_GRASS
    }

    /** How loud a step is: quieter running (74a), muffled on a rug. */
    fun volume(tile: Tile, running: Boolean): Float = (if (running) 0.3f else 0.42f) * (if (tile == Tile.RUG) 0.6f else 1f)

    /**
     * When a foot sets down: the walk's pictures stride furthest at a quarter and three quarters of their round, which
     * is every whole tile walked plus a half ([de.bornim.core.art.MapFigure.STEPS] pictures over two tiles).
     */
    class Feet {
        private var last = Long.MIN_VALUE

        /** True when a foot has set down since the last call, with [walked] the distance walked so far, in tiles. */
        fun fell(walked: Double): Boolean {
            val n = floor(walked - 0.5).toLong()
            val fell = last != Long.MIN_VALUE && n != last
            last = n
            return fell
        }
    }
}
