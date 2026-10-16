package de.bornim.core.audio

import de.bornim.core.MapKind

/**
 * The rain (D3.10): out of doors it rustles as heavy as it falls, setting in and dying away with the rain itself
 * ([de.bornim.core.Game.rainLevel]); under a roof and in the cave it is not heard. One take loops without a seam like
 * the river (D6.4); a fight or the menu hush it like the other loops of a place.
 */
object RainSound {
    /** How loud the rain is at its heaviest: below the river by the bank, above the small life it silences. */
    const val MAX = 0.22f

    /** Whether rain is heard on maps of [kind]: only under the open sky. */
    fun heard(kind: MapKind) = kind == MapKind.FOREST || kind == MapKind.TOWN

    /** How loud the rain should be with rain at [level] (0 to 1) on a map of [kind]; [calm] false in a fight or menu. */
    fun target(kind: MapKind, level: Float, calm: Boolean): Float =
        if (calm && heard(kind)) MAX * level.coerceIn(0f, 1f) else 0f

    /** Moves [cur] towards [target], at most from silence to the heaviest rain per [Ambience.FADE_MS]: it never jumps. */
    fun approach(cur: Float, target: Float, dtMs: Long): Float {
        val step = (MAX * dtMs / Ambience.FADE_MS).toFloat()
        return if (target > cur) minOf(target, cur + step) else maxOf(target, cur - step)
    }
}
