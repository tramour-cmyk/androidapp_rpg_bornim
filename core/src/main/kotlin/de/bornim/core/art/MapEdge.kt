package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile

/**
 * The edge of a map outdoors (27m): instead of a straight black slant where the map ends, the wood goes on
 * for a few rows of trees beyond it and fades into the dark. In the cave the rock goes on, and the passage of the
 * mouth runs out towards the daylight (D1.6).
 */
object MapEdge {
    /** How many tiles beyond the edge the wood is drawn. */
    const val RING = 6

    /** How many tiles beyond the edge the wood closes over a way out (27m.1). */
    const val CLOSE = 5

    /** Trees beyond the edge are chosen as if they stood this far away, where every tile is wood and nothing must stay in sight. */
    private const val OFF = 1000
    private const val OFF2 = 2017

    /** Off only in the preview, to measure what the ring costs (RANDZEIT). */
    var on = true

    fun applies(map: MapDef) = on && (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN || map.kind == MapKind.CAVE)

    /** What stands on a tile of the ring beyond the edge (348.6: also for the export to the new engine). */
    enum class Spot { NONE, LOW, TALL_OPEN, TALL, TALL2 }

    fun spot(map: MapDef, tx: Int, ty: Int): Spot {
        if (map.inside(tx, ty)) return Spot.NONE
        // the ground goes on as the edge tile next to it (a road, a river, the grass of a way out): no tree stands
        // there or one tile beside it, so the way out stays open and nothing grows out of the water
        val cx = tx.coerceIn(0, map.width - 1); val cy = ty.coerceIn(0, map.height - 1)
        val alongX = ty < 0 || ty >= map.height
        // seen diagonally the trees further along an edge stand in front (27m.4, test of 0.1.729: the way east hid
        // under the crowns until they faded), so three more beside a way out on that side stay away
        val open = (-3..1).any { k -> (if (alongX) map.tile((cx + k).coerceIn(0, map.width - 1), cy) else map.tile(cx, (cy + k).coerceIn(0, map.height - 1))) != Tile.TREE }
        // 27m.1 (user 14.10., test of 0.1.729: the way south just ended): a few tiles out the wood closes over a way
        // out, with crowns that never turn see-through, as the hero cannot come so far; water runs on into the dark
        val depth = maxOf(-tx, tx - map.width + 1, -ty, ty - map.height + 1)
        val wet = map.tile(cx, cy) == Tile.WATER || map.tile(cx, cy) == Tile.BRIDGE
        if (open && (depth < CLOSE || wet)) return Spot.NONE
        // in the village the fields and beds behind the edge stay in sight (83): no tall crowns in front of them,
        // a hedge in the first two rows beyond the edge and open ground behind it
        if (map.kind == MapKind.TOWN && MapFlora.shades(map, tx, ty)) return if (depth <= 2) Spot.LOW else Spot.NONE
        if (open) return Spot.TALL_OPEN
        // denser than the wood inside (user 14.10.: more trees round the map): on every other tile a second tree
        return if (Math.floorMod(tx + ty, 2) == 0) Spot.TALL2 else Spot.TALL
    }

    /** The trees standing in the ring beyond the edge of [map]. */
    fun trees(map: MapDef): List<WorldArt.Obj> {
        if (map.kind == MapKind.CAVE) return rock(map)
        val out = ArrayList<WorldArt.Obj>()
        val T = WorldArt.T
        for (ty in -RING until map.height + RING) for (tx in -RING until map.width + RING) {
            val spot = spot(map, tx, ty)
            if (spot == Spot.NONE) continue
            if (spot == Spot.LOW) { out += MapFlora.shrubs(map, tx, ty); continue }
            val open = spot == Spot.TALL_OPEN
            val far = MapFlora.objects(map, tx + OFF, ty + OFF) ?: continue
            for (o in far) out += WorldArt.Obj(o.img, o.x - OFF * T, o.y - OFF * T, o.sortY - OFF * T, o.density, o.low || open, o.corner, o.group, o.glow, o.area)
            // taken from another far place and set half a tile off, so no gap shows between the trunks
            if (spot == Spot.TALL2) MapFlora.objects(map, tx + OFF2, ty + OFF2)?.let { more ->
                val dx = OFF2 * T - T / 2; val dy = OFF2 * T - T / 2
                for (o in more) out += WorldArt.Obj(o.img, o.x - dx, o.y - dy, o.sortY - dy, o.density, o.low, o.corner, o.group, o.glow, o.area)
            }
        }
        return out
    }

    /** The rock beyond the edge of a cave: the faces along the passage of the mouth (D1.6). */
    private fun rock(map: MapDef): List<WorldArt.Obj> {
        val out = ArrayList<WorldArt.Obj>()
        for (ty in -RING until map.height + RING) for (tx in -RING until map.width + RING) {
            if (map.inside(tx, ty)) continue
            MapCaveIso.objects(map, tx, ty, 0, chestOpen = false, gateOpen = false)?.let { out += it }
        }
        return out
    }

    /** How much light is left at map pixel ([px], [py]): 1 inside the map, fading to 0 over the ring beyond its edge. */
    fun fade(map: MapDef, px: Float, py: Float): Float {
        val T = WorldArt.T
        // 27m.3/27m.5 (test of 0.1.729: little wood round the forest, at dusk round the village too): the first rows
        // beyond the edge keep their light, so the wood shows there by day and at dusk alike, then it fades
        val keep = if (map.kind == MapKind.CAVE) 0f else 2f * T
        val d = maxOf(0f, -px, px - map.width * T, -py, py - map.height * T) - keep
        if (d <= 0f) return 1f
        // the passage out of the cave stays lit: the daylight comes in from there
        if (map.kind == MapKind.CAVE && MapCave.caveTile(map, Math.floorDiv(px.toInt(), T), Math.floorDiv(py.toInt(), T)) == Tile.CAVE_EXIT) return 1f
        val u = (1f - d / ((RING * 0.9f * T) - keep)).coerceIn(0f, 1f)
        return u * u * (3 - 2 * u)
    }
}
