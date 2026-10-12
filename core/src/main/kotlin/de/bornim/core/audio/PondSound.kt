package de.bornim.core.audio

import de.bornim.core.art.PondLife
import de.bornim.core.art.WorldArt
import kotlin.math.hypot

/**
 * The sound of the forest pond (27j, takes chosen 27k): a frog calls when its throat swells on the bank, louder the
 * nearer the hero is, and falls silent once it has leapt into the water; a dragonfly whirrs only when it darts close by,
 * by day; at dusk the sitting frogs' quiet chorus. Only what is there is heard: at most three frogs and two dragonflies.
 */
object PondSound {
    /** Beyond this many tiles a frog's call is gone; within [FROG_NEAR] it is at its loudest. */
    const val FROG_FAR = 7.0
    const val FROG_NEAR = 1.5
    const val FROG_MAX = 0.4f
    /** A dragonfly is heard only within this many tiles. */
    const val FLY_FAR = 2.5
    const val FLY_MAX = 0.2f
    /** The chorus at dusk, from the nearest sitting frog. */
    const val CHORUS_FAR = 8.0
    const val CHORUS_NEAR = 2.0
    const val CHORUS_MAX = 0.14f

    private fun smooth(dist: Double, far: Double, near: Double, max: Float): Float {
        if (dist >= far) return 0f
        val t = ((far - dist) / (far - near)).coerceIn(0.0, 1.0)
        return (max * t * t * (3 - 2 * t)).toFloat()
    }

    fun frogVolume(tiles: Double): Float = smooth(tiles, FROG_FAR, FROG_NEAR, FROG_MAX)
    fun flyVolume(tiles: Double): Float = smooth(tiles, FLY_FAR, 0.5, FLY_MAX)

    /** How loud the chorus should be with the hero at map pixel ([hx], [hy]): only at dusk and with a frog on the bank. */
    fun chorusTarget(life: PondLife.Life, hx: Float, hy: Float, dusk: Boolean): Float {
        if (!dusk) return 0f
        val d = life.frogs.filter { it.sitting }.minOfOrNull { hypot(it.x - hx, it.y - hy) / WorldArt.T.toDouble() } ?: return 0f
        return smooth(d, CHORUS_FAR, CHORUS_NEAR, CHORUS_MAX)
    }

    /** Listens to one pond: remembers each frog's call slot and each dragonfly's dash, so every call and dart sounds once. */
    class Ear(private val life: PondLife.Life) {
        private val slots = LongArray(life.frogs.size) { Long.MIN_VALUE }
        private val dashes = LongArray(life.flies.size) { Long.MIN_VALUE }

        /**
         * What to play at [clock] with the hero at map pixel ([hx], [hy]), with its volume: the calls that have just
         * begun and the dragonflies that have just darted near. [flying]: the dragonflies are out (by day, no rain).
         */
        fun hear(clock: Long, hx: Float, hy: Float, dusk: Boolean, flying: Boolean): List<Pair<Sound, Float>> {
            val out = ArrayList<Pair<Sound, Float>>(2)
            for ((i, f) in life.frogs.withIndex()) {
                val slot = PondLife.croakSlot(f.seed, clock)
                val was = slots[i]; slots[i] = slot
                if (was == Long.MIN_VALUE || slot == was || !f.sitting || !PondLife.croaks(f.seed, slot, dusk)) continue
                val v = frogVolume(hypot(f.x - hx, f.y - hy) / WorldArt.T.toDouble())
                if (v > 0.01f) out += Sound.FROG to v
            }
            for ((i, fly) in life.flies.withIndex()) {
                val dash = fly.dash(clock)
                val was = dashes[i]; dashes[i] = dash
                if (was == Long.MIN_VALUE || dash == was || !flying) continue
                val a = fly.at(clock + 300)
                val v = flyVolume(hypot(a.x - hx, a.y - hy) / WorldArt.T.toDouble())
                if (v > 0.01f) out += Sound.DRAGONFLY to v
            }
            return out
        }
    }
}
