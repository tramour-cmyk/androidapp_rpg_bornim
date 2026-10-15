package de.bornim.core.audio

import de.bornim.core.art.MapHen
import de.bornim.core.art.WorldArt
import kotlin.math.hypot

/**
 * The sound of the village hens (83c): only what a hen is doing is heard, and only near it. A bout of pecking or
 * scratching now and then begins with quiet clucking, each rake of the foot is heard on the ground, and when the hero
 * comes close it runs off cackling with beating wings. Never in time: each hen on its own lot.
 */
object HenSound {
    /** Beyond this many tiles a hen is not heard; within [NEAR] at its loudest. */
    const val FAR = 6.0
    const val NEAR = 1.5
    const val CLUCK_MAX = 0.3f
    const val SCRATCH_MAX = 0.12f
    const val ALARM_MAX = 0.45f
    const val FLAP_MAX = 0.3f

    private fun smooth(dist: Double, max: Float): Float {
        if (dist >= FAR) return 0f
        val t = ((FAR - dist) / (FAR - NEAR)).coerceIn(0.0, 1.0)
        return (max * t * t * (3 - 2 * t)).toFloat()
    }

    /** Listens to the hens of one place: remembers what each was last heard doing, so every sound comes once. */
    class Ear(private val hens: List<MapHen.Hen>) {
        private val fled = IntArray(hens.size) { -1 }
        private val bouts = LongArray(hens.size) { Long.MIN_VALUE }
        private val rakes = LongArray(hens.size) { Long.MIN_VALUE }

        /** What to play with the hero at map pixel ([hx], [hy]), with its volume. */
        fun hear(hx: Float, hy: Float): List<Pair<Sound, Float>> {
            val out = ArrayList<Pair<Sound, Float>>(2)
            for ((i, h) in hens.withIndex()) {
                val d = hypot(h.x - hx, h.y - hy) / WorldArt.T.toDouble()
                val first = fled[i] == -1
                if (h.fled != fled[i]) {
                    val was = fled[i]; fled[i] = h.fled
                    if (!first && was >= 0) { smooth(d, ALARM_MAX).let { if (it > 0.01f) { out += Sound.HEN_ALARM to it; out += Sound.HEN_FLAP to smooth(d, FLAP_MAX) } } }
                }
                if (h.heardBout != bouts[i]) {
                    val was = bouts[i]; bouts[i] = h.heardBout
                    // one bout in two of pecking or scratching begins with clucking
                    if (was != Long.MIN_VALUE && h.heardKind != 2 && Math.floorMod(h.heardBout * 31 + h.seed, 2L) == 0L)
                        smooth(d, CLUCK_MAX).let { if (it > 0.01f) out += Sound.HEN_CLUCK to it }
                }
                if (h.heardRake != rakes[i]) {
                    val was = rakes[i]; rakes[i] = h.heardRake
                    if (was != Long.MIN_VALUE && h.heardKind == 1) smooth(d, SCRATCH_MAX).let { if (it > 0.01f) out += Sound.HEN_SCRATCH to it }
                }
            }
            return out
        }
    }
}
