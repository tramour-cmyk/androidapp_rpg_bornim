package de.bornim.core.art

import java.util.concurrent.atomic.AtomicInteger

/**
 * 267: which drawing in the background is under way, for the test tab: a picture of the map that came late
 * is put down to what drew at the time, so a stutter can be traced to its cause on the device.
 */
object DrawBusy {
    enum class Kind(val de: String, val en: String) {
        GROUND("Boden", "ground"), FOLK("Leute", "folk"), HERO("Held", "hero"), LOOT("Beute", "loot"),
        REST("Atmen", "breath"), SUN("Schatten", "shadow"), FIGHT("Kampf", "fight"),
    }

    private val running = Array(Kind.entries.size) { AtomicInteger() }
    /** Counts every start and end, so a drawing that came and went between two looks is seen too. */
    private val touched = Array(Kind.entries.size) { AtomicInteger() }

    /** Runs [body] counted as drawing of [kind]. */
    fun <R> during(kind: Kind, body: () -> R): R {
        val i = kind.ordinal
        running[i].incrementAndGet(); touched[i].incrementAndGet()
        try { return body() } finally { running[i].decrementAndGet(); touched[i].incrementAndGet() }
    }

    /** A mark to compare with: how often each kind started or ended so far. */
    fun mark(): IntArray = IntArray(touched.size) { touched[it].get() }

    /** The kinds that drew at some time since [since] (a [mark]), or draw now. */
    fun since(since: IntArray): List<Kind> =
        Kind.entries.filter { running[it.ordinal].get() > 0 || touched[it.ordinal].get() != since[it.ordinal] }
}
