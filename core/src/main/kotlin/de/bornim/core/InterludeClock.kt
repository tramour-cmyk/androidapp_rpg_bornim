package de.bornim.core

/**
 * When the black screen between places (24.1) shows what, as plain numbers so a test can run it in no time
 * (times in docs/DESIGN-BLENDE.md). The screen cuts to black at once, the words come in, stay until the pictures
 * of the new place are drawn (at least long enough to be read), then fade, and the map rises out of the black.
 * 267.1 (Chef 21.10.: "lieber mal beim Zwischenbildschirm oder Startbildschirm ein bisschen länger warten, aber dafür
 * läuft's"): it waits until everything is drawn, only [HOLD_MS] at the very most; while a long wait is foreseen, or
 * once it has waited [BAR_AFTER_MS], a loading bar shows ([Look.bar]). A tap ends it early, but not before everything is drawn.
 */
class InterludeClock(val kind: Kind, val startMs: Long) {

    /** [FULL] a whole sentence (first visit, start of play), [NAME] only the place's name, [BLINK] a short dark blink. */
    enum class Kind(val wordsInMs: Long, val leastMs: Long, val wordsOutMs: Long, val veilOutMs: Long) {
        FULL(400, 1_900, 300, 600),
        NAME(200, 800, 250, 500),
        BLINK(0, 0, 0, 500),
        /**
         * 24.6, before a fight (docs/DESIGN-BLENDE.md 5): [FIGHT] the words come in quietly, [FIGHT_SHORT] when all is drawn
         * already (about 1 s, so many fights in a row stay quick), [AMBUSH] the words there at once, [BOSS] stays longer.
         */
        FIGHT(350, 1_700, 300, 450),
        FIGHT_SHORT(200, 650, 200, 350),
        AMBUSH(0, 1_200, 250, 300),
        BOSS(500, 2_800, 400, 600),
    }

    /**
     * The veil over the map, the words and the loading bar on it, all 0..1, and whether it is over; [quote] how far
     * the place's sentence has given way to a saying (267.1T), 0..1.
     */
    data class Look(val veil: Float, val words: Float, val done: Boolean, val bar: Float = 0f, val quote: Float = 0f)

    /** When the screen began to leave, null while it still waits. */
    var leaveMs: Long? = null
        private set

    /** The player tapped: the screen leaves as soon as everything is drawn, even before the words could be read. */
    private var skip = false

    /** When the loading bar began to come in, null while it is not wanted. */
    private var barMs: Long? = null

    /** 267.1T: when the saying began to come in, null while none is wanted. */
    private var quoteMs: Long? = null

    /**
     * Moves on to [nowMs]; [ready] whether everything needed is drawn; [tapped] the player tapped the screen; [long] a
     * long wait is foreseen (the hero is drawn anew), so the bar shows at once.
     */
    fun at(nowMs: Long, ready: Boolean, tapped: Boolean = false, long: Boolean = false): Look {
        val t = nowMs - startMs
        if (tapped) skip = true
        if (barMs == null && leaveMs == null && kind != Kind.BLINK && (long || (!ready && t >= BAR_AFTER_MS))) barMs = t
        // 267.1T: a long wait still waiting once the sentence is read gives way to a saying, which then stays to be read too
        if (quoteMs == null && leaveMs == null && kind != Kind.BLINK && long && !ready && t >= QUOTE_AFTER_MS) quoteMs = t
        if (leaveMs == null) {
            val read = t >= kind.leastMs && (quoteMs?.let { t >= it + QUOTE_READ_MS } ?: true)
            if ((ready && (read || skip)) || t >= latestLeave()) leaveMs = t
        }
        val go = leaveMs?.let { 1f - ((t - it).toFloat() / maxOf(1L, kind.wordsOutMs)).coerceIn(0f, 1f) } ?: 1f
        val words = if (kind == Kind.BLINK) 0f else {
            val come = if (kind.wordsInMs == 0L) 1f else (t.toFloat() / kind.wordsInMs).coerceIn(0f, 1f)
            smooth(minOf(come, go))
        }
        val bar = barMs?.let { smooth(minOf(((t - it).toFloat() / BAR_IN_MS).coerceIn(0f, 1f), go)) } ?: 0f
        // the map rises once the words are nearly gone
        val veil = leaveMs?.let { 1f - smooth(((t - it - kind.wordsOutMs * 2 / 3).toFloat() / kind.veilOutMs).coerceIn(0f, 1f)) } ?: 1f
        val quote = quoteMs?.let { smooth(((t - it).toFloat() / QUOTE_IN_MS).coerceIn(0f, 1f)) } ?: 0f
        return Look(veil, words, veil <= 0f, bar, quote)
    }

    /** The latest moment the screen starts to leave, so all of it is over within [HOLD_MS]. */
    fun latestLeave(): Long = HOLD_MS - kind.wordsOutMs * 2 / 3 - kind.veilOutMs

    private fun smooth(x: Float) = x * x * (3 - 2 * x)

    companion object {
        /**
         * No black screen lasts longer than this, drawn or not: only against a fault that never lets it be ready
         * (24.1 had 4 s; 267.1 waits for the drawing, on the tablet the hero took up to 50 s in all).
         */
        const val HOLD_MS = 120_000L

        /** 267.1: not drawn after this long, the bar shows even when no long wait was foreseen ("nur bei absehbar über 3 s"). */
        const val BAR_AFTER_MS = 3_000L

        /** How long the bar takes to come in. */
        const val BAR_IN_MS = 300L

        /** 267.1T: the place's sentence stands this long before a saying takes its place, at one spot, mid-screen. */
        const val QUOTE_AFTER_MS = 3_500L

        /** How long the sentence takes to turn into the saying. */
        const val QUOTE_IN_MS = 1_200L

        /** Once it began, the saying stays at least this long (a tap still ends it once all is drawn). */
        const val QUOTE_READ_MS = 4_000L

        /** The village and the houses one walks into from it: a door there only blinks once all is drawn (24i). */
        val VILLAGE = setOf("village", "inn", "shop", "elder", "temple")

        /**
         * What to show on entering [to] from [from] (null at the start of play): the whole sentence on a first visit and
         * at the start, a door in the village only blinks when all is already drawn, otherwise only the name.
         */
        /** 24.6: the screen before a fight: a boss long, an ambush at once, a short one when everything is drawn already. */
        fun fightKind(ambushed: Boolean, boss: Boolean, readyNow: Boolean): Kind = when {
            boss -> Kind.BOSS
            ambushed -> Kind.AMBUSH
            readyNow -> Kind.FIGHT_SHORT
            else -> Kind.FIGHT
        }

        fun kindFor(from: String?, to: String, firstVisit: Boolean, readyNow: Boolean): Kind = when {
            from == null || firstVisit -> Kind.FULL
            readyNow && from in VILLAGE && to in VILLAGE -> Kind.BLINK
            else -> Kind.NAME
        }
    }
}
