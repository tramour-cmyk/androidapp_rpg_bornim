package de.bornim.core

/**
 * 292: the opening at a cold start of the app (`DESIGN-BLENDE.md` "Vorspann und Hauptmenü"): first the firm, then the
 * game's name, out of which the main menu grows. Times in milliseconds since the start; a tap skips it.
 */
object Prelude {
    const val fadeIn = 400L
    const val hold = 1200L
    const val fadeOut = 600L

    /** The firm's logo: in, standing, out. */
    const val firmEnd = fadeIn + hold + fadeOut
    /** The game's name comes in after the firm and stays. */
    const val nameStart = firmEnd
    /** Then the heroes and the buttons of the main menu come in round it. */
    const val menuStart = nameStart + fadeIn + hold
    const val end = menuStart + fadeIn

    /** How much the firm's logo shows, 0 to 1. */
    fun firm(t: Long): Float = when {
        t < fadeIn -> ramp(t, 0, fadeIn)
        t < fadeIn + hold -> 1f
        else -> 1f - ramp(t, fadeIn + hold, firmEnd)
    }

    /** How much the game's name shows. */
    fun name(t: Long): Float = ramp(t, nameStart, nameStart + fadeIn)

    /** How much the rest of the main menu shows. */
    fun menu(t: Long): Float = ramp(t, menuStart, end)

    private fun ramp(t: Long, from: Long, to: Long): Float = ((t - from).toFloat() / (to - from)).coerceIn(0f, 1f)
}
