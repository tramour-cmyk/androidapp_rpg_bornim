package de.bornim.core.audio

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.max
import kotlin.math.min

/**
 * The fire's crackle and the cave's drops (18h, 18i): the crackle swells as the hero walks up to a campfire or a hearth
 * and fades as he leaves it, never starting at full strength; one take loops without a seam until it has faded out (18k); the drops fall in the cave on their own, fire or not.
 */
object Ambience {
    /** Beyond this many tiles from a fire its crackle is gone. */
    const val FIRE_FAR = 6.0
    /** Within this many tiles the crackle is at its loudest. */
    const val FIRE_NEAR = 1.0
    const val FIRE_MAX = 0.5f
    /** Time to swell from silence to full, or to fade back (entering, leaving, a fight starting). */
    const val FADE_MS = 1000.0

    /** Drops in the cave, a pause of 4–10 s between them, a little quieter the louder the fire. */
    const val DRIP_MIN_MS = 4000L
    const val DRIP_SPAN_MS = 6000L
    const val DRIP_VOLUME = 0.45f

    /** Walls the crackle does not pass: it comes round them by the open way, or not at all (D1.9). */
    private val WALLS = setOf(Tile.WALL, Tile.CAVE_WALL, Tile.CRYSTAL, Tile.TORCH, Tile.WINDOW, Tile.ROOF, Tile.ROOF_BLUE)

    /**
     * Distance in tiles from ([x], [y]) to the nearest campfire or hearth by the open way, round walls and never
     * through them (D1.9), or null if none is within reach. Steps go straight or diagonally, a diagonal only where
     * neither side is wall.
     */
    fun nearestFire(map: MapDef, x: Int, y: Int): Double? {
        val r = FIRE_FAR.toInt() + 1
        val n = 2 * r + 1
        val dist = DoubleArray(n * n) { Double.MAX_VALUE }
        fun open(tx: Int, ty: Int) = map.inside(tx, ty) && map.tile(tx, ty) !in WALLS
        fun fire(tx: Int, ty: Int) = map.tile(tx, ty).let { it == Tile.CAMPFIRE || it == Tile.HEARTH }
        val queue = java.util.PriorityQueue<Pair<Double, Int>>(compareBy { it.first })
        dist[r * n + r] = 0.0; queue += 0.0 to (r * n + r)
        while (queue.isNotEmpty()) {
            val (d, k) = queue.poll()
            if (d > dist[k] || d >= FIRE_FAR) continue
            val cx = k % n - r; val cy = k / n - r
            if (fire(x + cx, y + cy)) return d
            // the fire stands in the way of walking, not of sound; other things that cannot be walked on carry it on
            for (dy in -1..1) for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                val nx = cx + dx; val ny = cy + dy
                if (nx < -r || nx > r || ny < -r || ny > r || !open(x + nx, y + ny)) continue
                if (dx != 0 && dy != 0 && (!open(x + cx + dx, y + cy) || !open(x + cx, y + cy + dy))) continue
                val nd = d + if (dx != 0 && dy != 0) Math.sqrt(2.0) else 1.0
                val nk = (ny + r) * n + nx + r
                if (nd < dist[nk]) { dist[nk] = nd; queue += nd to nk }
            }
        }
        return null
    }

    /** How loud the crackle should be at [dist] tiles from the fire: silent far off, swelling smoothly towards it. */
    fun fireTarget(dist: Double?): Float {
        if (dist == null || dist >= FIRE_FAR) return 0f
        val t = ((FIRE_FAR - dist) / (FIRE_FAR - FIRE_NEAR)).coerceIn(0.0, 1.0)
        return (FIRE_MAX * t * t * (3 - 2 * t)).toFloat()
    }

    /** Moves [cur] towards [target], at most a full swell per [FADE_MS]: the crackle never jumps. */
    fun approach(cur: Float, target: Float, dtMs: Long): Float {
        val step = (FIRE_MAX * dtMs / FADE_MS).toFloat()
        return if (target > cur) min(target, cur + step) else max(target, cur - step)
    }

    /** Volume of a drop while the crackle is at [fire]. */
    fun dripVolume(fire: Float): Float = DRIP_VOLUME * (1f - 0.6f * fire / FIRE_MAX)
}
