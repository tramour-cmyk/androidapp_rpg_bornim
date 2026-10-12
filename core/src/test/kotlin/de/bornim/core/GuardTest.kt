package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class GuardTest {
    @Test
    fun anErrorOnABackgroundThreadIsCaughtAndWrittenDown() {
        val got = ArrayList<String>()
        Guard.sink = { synchronized(got) { got += it } }
        Guard.about = { linkedMapOf("Version" to "0.1.test", "Bildschirm" to "Karte") }
        val before = Guard.caught.get()
        var ended = false
        val t = Thread {
            Guard.run("Held Karte") { throw OutOfMemoryError("zu groß") }
            ended = true
        }
        var uncaught: Throwable? = null
        t.setUncaughtExceptionHandler { _, e -> uncaught = e }
        t.start(); t.join()
        assertTrue(ended, "the thread goes on after the error")
        assertEquals(null, uncaught)
        assertEquals(before + 1, Guard.caught.get())
        val text = synchronized(got) { got.single() }
        assertTrue("Wo: Held Karte" in text)
        assertTrue("Version: 0.1.test" in text)
        assertTrue("OutOfMemoryError: zu groß" in text)
        assertEquals(text, Guard.last)
        Guard.sink = null
        Guard.about = { emptyMap() }
    }

    @Test
    fun runSaysWhetherTheBlockRanThrough() {
        assertTrue(Guard.run("gut") {})
        assertFalse(Guard.run("schlecht") { error("x") })
    }

    @Test
    fun aFailingSinkDoesNotThrow() {
        Guard.sink = { error("Datei voll") }
        Guard.note("irgendwo", IllegalStateException("x"))
        Guard.sink = null
    }

    @Test
    fun aDeepTraceIsCut() {
        fun deep(n: Int): Nothing = if (n == 0) throw IllegalStateException("tief") else deep(n - 1)
        val e = runCatching { deep(500) }.exceptionOrNull()!!
        val text = Guard.describe(e, "Test", Guard.heap())
        assertTrue("Heap max:" in text)
        assertTrue(text.lines().size <= Guard.MAX_LINES + 2 + 3 + 1)
    }
}
