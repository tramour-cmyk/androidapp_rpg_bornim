package de.bornim.core

import java.io.PrintWriter
import java.io.StringWriter
import java.util.concurrent.atomic.AtomicInteger

/**
 * 30: errors on the threads that draw in the background are caught here instead of ending the app. Whatever is being
 * drawn then simply stays missing (the figure shows its standing picture). Each error is written down for the test
 * tab, the app passes them on to a file ([sink]).
 */
object Guard {
    /** How many errors were caught since the start. */
    val caught = AtomicInteger()

    /** The last one caught, as text ([describe]); null while none. */
    @Volatile var last: String? = null
        private set

    /** Where the app keeps what was caught (a file); called on the thread that failed. */
    @Volatile var sink: ((String) -> Unit)? = null

    /** What the app adds to every report: version, screen, memory. */
    @Volatile var about: () -> Map<String, String> = { emptyMap() }

    /** Runs [block], catching anything it throws, out of memory too. True when it ran through. */
    inline fun run(where: String, block: () -> Unit): Boolean =
        try { block(); true } catch (t: Throwable) { note(where, t); false }

    /** What frees memory (pictures kept): called once an error is out of memory. */
    @Volatile var onOutOfMemory: (() -> Unit)? = null

    /** Writes [t] down as caught at [where]. Never throws. */
    fun note(where: String, t: Throwable) {
        caught.incrementAndGet()
        if (t is OutOfMemoryError) try { onOutOfMemory?.invoke() } catch (_: Throwable) {}
        val text = try { describe(t, where, about()) } catch (_: Throwable) { "$where: $t" }
        last = text
        try { sink?.invoke(text) } catch (_: Throwable) {}
    }

    /** The memory of this process, the same on any JVM: what the heap may take, holds and has free, in MB. */
    fun heap(): Map<String, String> {
        val r = Runtime.getRuntime()
        fun mb(b: Long) = "${b / (1024 * 1024)} MB"
        return linkedMapOf("Heap max" to mb(r.maxMemory()), "Heap belegt" to mb(r.totalMemory() - r.freeMemory()),
            "Heap frei" to mb(r.maxMemory() - (r.totalMemory() - r.freeMemory())))
    }

    /** A report of [t]: where, on which thread, [info] line by line, then the stack trace (causes included). */
    fun describe(t: Throwable, where: String, info: Map<String, String>, thread: String = Thread.currentThread().name): String {
        val sw = StringWriter()
        PrintWriter(sw).use { t.printStackTrace(it) }
        // 227: a recursion's equal lines folded first, so the cut after MAX_LINES keeps where it came from
        val trace = CrashText.fold(sw.toString()).lines().take(MAX_LINES).joinToString("\n")
        return buildString {
            append("Wo: ").append(where).append('\n')
            append("Faden: ").append(thread).append('\n')
            for ((k, v) in info) append(k).append(": ").append(v).append('\n')
            append(trace.trimEnd())
        }
    }

    /** Stack traces are cut after this many lines, enough for the cause and where it came from. */
    const val MAX_LINES = 80
}
