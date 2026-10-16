package de.bornim.core.audio

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.hypot

/**
 * The river (D6.4): running water rushes, louder the nearer the hero is, loudest on the bridge, and fades as he walks
 * off; one take loops without a seam like the fire's crackle (18k). Only water that runs is heard: a river comes in at
 * one edge of the map and leaves at another, a pond lies still within it and has its frogs instead (27j).
 */
object RiverSound {
    /** Beyond this many tiles from running water the rush is gone; within [NEAR] it is at its loudest. */
    const val FAR = 8.0
    const val NEAR = 1.0
    const val MAX = 0.25f

    private val cache = HashMap<String, List<Pair<Int, Int>>>()

    /** The water tiles of [map] that belong to a river: those joined, side by side, to water at the map's edge. */
    fun running(map: MapDef): List<Pair<Int, Int>> = synchronized(cache) { cache.getOrPut(map.id) { find(map) } }

    private fun find(map: MapDef): List<Pair<Int, Int>> {
        val w = map.width; val h = map.height
        fun water(x: Int, y: Int) = map.inside(x, y) && map.tile(x, y) == Tile.WATER
        val seen = BooleanArray(w * h)
        val queue = ArrayDeque<Int>()
        for (y in 0 until h) for (x in 0 until w) {
            if ((x == 0 || y == 0 || x == w - 1 || y == h - 1) && water(x, y) && !seen[y * w + x]) { seen[y * w + x] = true; queue += y * w + x }
        }
        val out = mutableListOf<Pair<Int, Int>>()
        while (queue.isNotEmpty()) {
            val k = queue.removeFirst(); val x = k % w; val y = k / w
            out += x to y
            for ((dx, dy) in listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)) {
                val nx = x + dx; val ny = y + dy
                if (water(nx, ny) && !seen[ny * w + nx]) { seen[ny * w + nx] = true; queue += ny * w + nx }
            }
        }
        return out
    }

    /** Distance in tiles from ([x], [y]) to the nearest running water, or null if there is none within [FAR]. */
    fun nearest(map: MapDef, x: Int, y: Int): Double? =
        running(map).minOfOrNull { (wx, wy) -> hypot((wx - x).toDouble(), (wy - y).toDouble()) }?.takeIf { it < FAR }

    /** How loud the rush should be at [dist] tiles: silent far off, swelling smoothly towards the bank. */
    fun target(dist: Double?): Float {
        if (dist == null || dist >= FAR) return 0f
        val t = ((FAR - dist) / (FAR - NEAR)).coerceIn(0.0, 1.0)
        return (MAX * t * t * (3 - 2 * t)).toFloat()
    }

    /** Moves [cur] towards [target], at most a full swell per [Ambience.FADE_MS]: the rush never jumps. */
    fun approach(cur: Float, target: Float, dtMs: Long): Float {
        val step = (MAX * dtMs / Ambience.FADE_MS).toFloat()
        return if (target > cur) minOf(target, cur + step) else maxOf(target, cur - step)
    }
}
