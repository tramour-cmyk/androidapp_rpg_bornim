package de.bornim.core.audio

/**
 * The player's sliders (40, 40a; user 12.10., 10:10): overall, music and effects, each 0–100 %; the sounds of a place
 * count as effects. And the brightness slider beside them (13e.6, user 14.10., 22:1x): it only lifts the black a little
 * for screens that swallow dark tones, matched against a test sign, and never lights up the cave.
 */
object Mix {
    const val FULL = 100
    /** One click of a slider. */
    const val STEP = 5

    /**
     * The factor a sound is played at with [overall] and its own slider [part] (percent). The ear hears loudness
     * roughly by the square, so half way down sounds about half as loud rather than barely quieter.
     */
    fun gain(overall: Int, part: Int): Float {
        val g = clamp(overall) / FULL.toFloat() * (clamp(part) / FULL.toFloat())
        return g * g
    }

    /** A slider's value kept in range and on its steps. */
    fun clamp(percent: Int): Int = ((percent.coerceIn(0, FULL) + STEP / 2) / STEP) * STEP

    /** The most the black is lifted at the slider's top: enough for a dark screen, too little to light the cave. */
    const val LIFT_MAX = 0.10f

    /** How much white is laid over the picture at [brightness] percent: 0 at the start, [LIFT_MAX] at the top. */
    fun lift(brightness: Int): Float = clamp(brightness) / FULL.toFloat() * LIFT_MAX

    /** A channel 0–255 of the picture under the lift [a]: black rises to [a], white stays white. */
    fun lifted(channel: Int, a: Float): Int = Math.round(channel + a * (255 - channel))

    /** The test sign's tone on black (0–255): the darkest a cave's outline is meant to show. */
    const val SIGN = 10
}
