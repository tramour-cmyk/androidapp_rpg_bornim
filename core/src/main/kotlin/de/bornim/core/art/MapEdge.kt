package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind

/**
 * The edge of a map outdoors (27/5.5, draft): instead of a straight black slant where the map ends, the wood goes on
 * for a few rows of trees beyond it and fades into the dark. Only in the preview until the user has seen it.
 */
object MapEdge {
    @Volatile var draft = false

    /** How many tiles beyond the edge the wood is drawn. */
    const val RING = 6

    /** Trees beyond the edge are chosen as if they stood this far away, where every tile is wood and nothing must stay in sight. */
    private const val OFF = 1000

    fun applies(map: MapDef) = draft && (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN)

    /** The trees standing in the ring beyond the edge of [map]. */
    fun trees(map: MapDef): List<WorldArt.Obj> {
        val out = ArrayList<WorldArt.Obj>()
        val T = WorldArt.T
        for (ty in -RING until map.height + RING) for (tx in -RING until map.width + RING) {
            if (map.inside(tx, ty)) continue
            val far = MapFlora.objects(map, tx + OFF, ty + OFF) ?: continue
            for (o in far) out += WorldArt.Obj(o.img, o.x - OFF * T, o.y - OFF * T, o.sortY - OFF * T, o.density, o.low, o.corner, o.group, o.glow, o.area)
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
