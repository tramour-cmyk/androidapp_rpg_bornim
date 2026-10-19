package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals

class CrashTextTest {
    @Test
    fun foldsARepeatedLineAndKeepsTheCaller() {
        val text = (listOf("java.lang.StackOverflowError") + List(100) { "\tat t1.C2.a(Unknown Source:5)" } + listOf("\tat t1.Q.start(Unknown Source:9)")).joinToString("\n")
        assertEquals("java.lang.StackOverflowError\n\tat t1.C2.a(Unknown Source:5)\n\t… 100× gleich\n\tat t1.Q.start(Unknown Source:9)", CrashText.fold(text))
    }

    @Test
    fun foldsATwoLineCycle() {
        val text = (List(5) { "a\nb" } + listOf("c")).joinToString("\n")
        assertEquals("a\nb\n\t… 5× gleich (2 Zeilen)\nc", CrashText.fold(text))
    }

    @Test
    fun leavesShortRepeatsAlone() {
        assertEquals("x\nx\ny", CrashText.fold("x\nx\ny"))
    }
}

class GuardFoldTest {
    private fun down(n: Int): Int = if (n == 0) throw IllegalStateException("tief") else down(n - 1) + 1
    private fun caller(): Int = down(300)

    @Test
    fun aDeepRecursionKeepsItsCaller() {
        val e = runCatching { caller() }.exceptionOrNull()!!
        val text = Guard.describe(e, "Test", emptyMap())
        kotlin.test.assertTrue("caller" in text, text)
        kotlin.test.assertTrue("× gleich" in text, text)
    }
}
