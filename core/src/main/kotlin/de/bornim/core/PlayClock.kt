package de.bornim.core

/**
 * 132: counts the real time a hero is played, while the game shows and the app is in front.
 * Times come from the caller (a monotonic clock in milliseconds), so the count can be tested.
 */
class PlayClock {
    /** When the count last started or was booked, or null while it stands. */
    private var since: Long? = null

    val running: Boolean get() = since != null

    fun start(now: Long) {
        if (since == null) since = now
    }

    /** Adds the time since the last start or booking to [state]. */
    fun book(state: GameState, now: Long) {
        val s = since ?: return
        if (now > s) state.playedMs += now - s
        since = now
    }

    fun stop(state: GameState, now: Long) {
        book(state, now)
        since = null
    }

    /** Stops without booking, for a game left without saving (a new one or another hero loads). */
    fun drop() {
        since = null
    }

    companion object {
        /** „Gespielt: 2 Std. 14 Min.“ for the card of a saved game. */
        fun played(ms: Long, lang: Lang): String {
            val min = (ms / 60_000).coerceAtLeast(0)
            val h = min / 60
            val m = min % 60
            val de = lang == Lang.DE
            val time = when {
                h == 0L -> if (de) "$m Min." else "$m min"
                else -> if (de) "$h Std. $m Min." else "$h h $m min"
            }
            return (if (de) "Gespielt: " else "Played: ") + time
        }
    }
}
