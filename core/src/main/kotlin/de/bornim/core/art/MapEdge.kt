package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile

/**
 * The edge of a map outdoors (27m): instead of a straight black slant where the map ends, the wood goes on
 * for a few rows of trees beyond it and fades into the dark.
 */
object MapEdge {
    /** How many tiles beyond the edge the wood is drawn. */
    const val RING = 6

    /** Trees beyond the edge are chosen as if they stood this far away, where every tile is wood and nothing must stay in sight. */
    private const val OFF = 1000
    private const val OFF2 = 2017

    /** Off only in the preview, to measure what the ring costs (RANDZEIT). */
    var on = true

    fun applies(map: MapDef) = on && (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN)

    /** The trees standing in the ring beyond the edge of [map]. */
    fun trees(map: MapDef): List<WorldArt.Obj> {
        val out = ArrayList<WorldArt.Obj>()
        val T = WorldArt.T
        for (ty in -RING until map.height + RING) for (tx in -RING until map.width + RING) {
            if (map.inside(tx, ty)) continue
            // the ground goes on as the edge tile next to it (a road, a river, the grass of a way out): no tree stands
            // there or one tile beside it, so the way out stays open and nothing grows out of the water
            val cx = tx.coerceIn(0, map.width - 1); val cy = ty.coerceIn(0, map.height - 1)
            val alongX = ty < 0 || ty >= map.height
            if ((-1..1).any { k -> (if (alongX) map.tile((cx + k).coerceIn(0, map.width - 1), cy) else map.tile(cx, (cy + k).coerceIn(0, map.height - 1))) != Tile.TREE }) continue
            val far = MapFlora.objects(map, tx + OFF, ty + OFF) ?: continue
            for (o in far) out += WorldArt.Obj(o.img, o.x - OFF * T, o.y - OFF * T, o.sortY - OFF * T, o.density, o.low, o.corner, o.group, o.glow, o.area)
            // denser than the wood inside (user 14.10.: more trees round the map): on every other tile a second tree,
            // taken from another far place and set half a tile off, so no gap shows between the trunks
            if (Math.floorMod(tx + ty, 2) == 0) MapFlora.objects(map, tx + OFF2, ty + OFF2)?.let { more ->
                val dx = OFF2 * T - T / 2; val dy = OFF2 * T - T / 2
                for (o in more) out += WorldArt.Obj(o.img, o.x - dx, o.y - dy, o.sortY - dy, o.density, o.low, o.corner, o.group, o.glow, o.area)
            }
        }
        return out
    }

    /** How much light is left at map pixel ([px], [py]): 1 inside the map, fading to 0 over the ring beyond its edge. */
    fun fade(map: MapDef, px: Float, py: Float): Float {
        val T = WorldArt.T
        val d = maxOf(0f, -px, px - map.width * T, -py, py - map.height * T)
        if (d <= 0f) return 1f
        val u = (1f - d / (RING * T * 0.9f)).coerceIn(0f, 1f)
        return u * u * (3 - 2 * u)
    }
}
