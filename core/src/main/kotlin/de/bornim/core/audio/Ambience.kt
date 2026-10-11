package de.bornim.core.audio

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.hypot
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

    /** Distance in tiles from ([x], [y]) to the nearest campfire or hearth, or null if none is within reach. */
    fun nearestFire(map: MapDef, x: Int, y: Int): Double? {
        val r = FIRE_FAR.toInt() + 1
        var best: Double? = null
        for (dy in -r..r) for (dx in -r..r) {
            val t = map.tile(x + dx, y + dy)
            if (t != Tile.CAMPFIRE && t != Tile.HEARTH) continue
            val d = hypot(dx.toDouble(), dy.toDouble())
            if (best == null || d < best) best = d
        }
        return best
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
