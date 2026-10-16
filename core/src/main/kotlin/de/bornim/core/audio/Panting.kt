package de.bornim.core.audio

import de.bornim.core.GameState
import de.bornim.core.Sex
import de.bornim.core.Stamina

/**
 * The hero out of breath (95, to 86.3; user 15.10., 16:5x: the breath is shown but not heard). While
 * [GameState.winded], the hero pants: breath after breath at first, then with growing pauses and more quietly as the
 * breath comes back, until he may run again ([Stamina.AGAIN]). A man's or a woman's breath, by the hero.
 */
object Panting {
    /** Loudness right after running empty and just before the breath is back. */
    const val LOUD = 0.6f
    const val QUIET = 0.3f
    /** The pause after a breath once the breath is nearly back, in ms; none right after running empty. */
    const val PAUSE_MS = 1400.0

    fun sound(sex: Sex): Sound = if (sex == Sex.FEMALE) Sound.PANT_WOMAN else Sound.PANT_MAN

    /** How long one breath of [sex] lasts (the takes cut by tools/klang/atem.py), in ms. */
    fun breathMs(sex: Sex): Long = if (sex == Sex.FEMALE) 1600L else 1420L

    /** When the hero next draws breath, frame by frame. */
    class Breath {
        private var next = 0L

        /** At [now] ms: the loudness of a breath to play now, or null. */
        fun due(state: GameState, now: Long): Float? {
            if (!state.winded) { next = 0L; return null }
            if (now < next) return null
            // 0 just run empty, 1 the breath is back
            val back = (state.stamina / Stamina.AGAIN).coerceIn(0.0, 1.0)
            next = now + breathMs(state.hero.sex) + (PAUSE_MS * back).toLong()
            return LOUD + (QUIET - LOUD) * back.toFloat()
        }
    }
}
