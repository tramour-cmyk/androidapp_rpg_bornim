package de.bornim.core

import kotlin.math.abs
import kotlin.math.sqrt

/** How much of a tile the hero knows about. */
enum class Fog { HIDDEN, SEEN, VISIBLE }

/** Tiles that block the view. */
private val opaque = setOf(
    Tile.TREE, Tile.ROCK, Tile.WALL, Tile.CAVE_WALL, Tile.ROOF, Tile.ROOF_BLUE, Tile.WINDOW, Tile.TORCH, Tile.SHELF,
)

/**
 * Sight of the hero: a cone of 160° in the walking direction plus a small circle around, blocked by
 * trees, rocks and walls. Everything ever seen stays explored (and is saved); only what is in sight
 * right now is [Fog.VISIBLE].
 */
class Sight(private val state: GameState) {
    private var key = ""
    private var visible = BooleanArray(0)
    private val explored = HashMap<String, BooleanArray>()

    fun fog(map: MapDef, x: Int, y: Int, night: Boolean): Fog {
        if (!map.inside(x, y)) return Fog.HIDDEN
        update(map, night)
        val i = y * map.width + x
        return when {
            visible[i] -> Fog.VISIBLE
            exploredOf(map)[i] -> Fog.SEEN
            else -> Fog.HIDDEN
        }
    }

    fun known(map: MapDef, x: Int, y: Int, night: Boolean): Boolean = fog(map, x, y, night) != Fog.HIDDEN

    private fun exploredOf(map: MapDef): BooleanArray = explored.getOrPut(map.id) {
        val bits = BooleanArray(map.width * map.height)
        state.explored[map.id]?.let { hex ->
            for (i in bits.indices) {
                val c = i / 4
                if (c < hex.length && (hex[c].digitToInt(16) shr (i % 4)) and 1 == 1) bits[i] = true
            }
        }
        bits
    }

    private fun save(map: MapDef, bits: BooleanArray) {
        val sb = StringBuilder()
        var i = 0
        while (i < bits.size) {
            var v = 0
            for (b in 0 until 4) if (i + b < bits.size && bits[i + b]) v = v or (1 shl b)
            sb.append(v.toString(16))
            i += 4
        }
        state.explored[map.id] = sb.toString()
    }

    private fun update(map: MapDef, night: Boolean) {
        val p = state.place
        val k = "${map.id}/${p.x}/${p.y}/${p.facing}/$night"
        if (k == key) return
        key = k
        visible = BooleanArray(map.width * map.height)
        // A wise hero sees a little further.
        val radius = (if (night || map.kind == MapKind.CAVE) 4.2 else 5.2) + Perks.sightBonus(state.hero)
        val r = radius.toInt() + 1
        for (dy in -r..r) for (dx in -r..r) {
            val x = p.x + dx; val y = p.y + dy
            if (!map.inside(x, y)) continue
            val d = sqrt((dx * dx + dy * dy).toDouble())
            val near = d <= 1.5
            if (!near) {
                if (d > radius) continue
                // within 80° to either side of the walking direction
                val cos = (dx * p.facing.dx + dy * p.facing.dy) / d
                if (cos < 0.17) continue
                if (!lineOfSight(map, p.x, p.y, x, y)) continue
            }
            visible[y * map.width + x] = true
        }
        val bits = exploredOf(map)
        var changed = false
        for (i in visible.indices) if (visible[i] && !bits[i]) {
            bits[i] = true
            changed = true
        }
        if (changed) save(map, bits)
    }

    /** True if nothing opaque lies between the two tiles (the end tile itself may be a tree). */
    private fun lineOfSight(map: MapDef, x0: Int, y0: Int, x1: Int, y1: Int): Boolean {
        var x = x0; var y = y0
        val dx = abs(x1 - x0); val dy = -abs(y1 - y0)
        val sx = if (x0 < x1) 1 else -1
        val sy = if (y0 < y1) 1 else -1
        var err = dx + dy
        while (true) {
            if (x == x1 && y == y1) return true
            if ((x != x0 || y != y0) && map.tile(x, y) in opaque) return false
            val e2 = 2 * err
            if (e2 >= dy) { err += dy; x += sx }
            if (e2 <= dx) { err += dx; y += sy }
        }
    }
}
