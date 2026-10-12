package de.bornim.core

/**
 * When the black screen between places (24.1) shows what, as plain numbers so a test can run it in no time
 * (times in docs/ZWISCHENBILD.md). The screen cuts to black at once, the words come in, stay until the pictures
 * of the new place are drawn (at least long enough to be read), then fade, and the map rises out of the black.
 * It never stays longer than [CAP_MS]; a tap ends it early, but not before everything is drawn.
 */
class InterludeClock(val kind: Kind, val startMs: Long) {

    /** [FULL] a whole sentence (first visit, start of play), [NAME] only the place's name, [BLINK] a short dark blink. */
    enum class Kind(val wordsInMs: Long, val leastMs: Long, val wordsOutMs: Long, val veilOutMs: Long) {
        FULL(400, 1_900, 300, 600),
        NAME(200, 800, 250, 500),
        BLINK(0, 0, 0, 500),
    }

    /** The veil over the map and the words on it, both 0..1, and whether it is over. */
    data class Look(val veil: Float, val words: Float, val done: Boolean)

    /** When the screen began to leave, null while it still waits. */
    var leaveMs: Long? = null
        private set

    /** The player tapped: the screen leaves as soon as everything is drawn, even before the words could be read. */
    private var skip = false

    /** Moves on to [nowMs]; [ready] whether everything needed is drawn; [tapped] the player tapped the screen. */
    fun at(nowMs: Long, ready: Boolean, tapped: Boolean = false): Look {
        val t = nowMs - startMs
        if (tapped) skip = true
        if (leaveMs == null) {
            val read = t >= kind.leastMs
            if ((ready && (read || skip)) || t >= latestLeave()) leaveMs = t
        }
        val words = if (kind == Kind.BLINK) 0f else {
            val come = if (kind.wordsInMs == 0L) 1f else (t.toFloat() / kind.wordsInMs).coerceIn(0f, 1f)
            val go = leaveMs?.let { 1f - ((t - it).toFloat() / kind.wordsOutMs).coerceIn(0f, 1f) } ?: 1f
            smooth(minOf(come, go))
        }
        // the map rises once the words are nearly gone
        val veil = leaveMs?.let { 1f - smooth(((t - it - kind.wordsOutMs * 2 / 3).toFloat() / kind.veilOutMs).coerceIn(0f, 1f)) } ?: 1f
        return Look(veil, words, veil <= 0f)
    }

    /** The latest moment the screen starts to leave, so all of it is over within [CAP_MS]. */
    fun latestLeave(): Long = CAP_MS - kind.wordsOutMs * 2 / 3 - kind.veilOutMs

    private fun smooth(x: Float) = x * x * (3 - 2 * x)

    companion object {
        /** No black screen lasts longer than this, drawn or not (24.1). */
        const val CAP_MS = 4_000L

        /** The village and the houses one walks into from it: a door there only blinks once all is drawn (24i). */
        val VILLAGE = setOf("village", "inn", "shop", "elder", "temple")

        /**
         * What to show on entering [to] from [from] (null at the start of play): the whole sentence on a first visit and
         * at the start, a door in the village only blinks when all is already drawn, otherwise only the name.
         */
        fun kindFor(from: String?, to: String, firstVisit: Boolean, readyNow: Boolean): Kind = when {
            from == null || firstVisit -> Kind.FULL
            readyNow && from in VILLAGE && to in VILLAGE -> Kind.BLINK
            else -> Kind.NAME
        }
    }
}
