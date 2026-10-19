package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertTrue

/** 226: `fun x(lang: Lang) = x(lang)` meant the text `x` but called itself (StackOverflowError at fight start, Build 36). */
class SelfCallTest {
    private val selfCall = Regex("""\bfun\s+(\w+)\(([^)]*)\)[^={]*=\s*\1\(([^()]*)\)\s*$""")

    /** Only a call that passes on exactly its own parameters; overloads like `roll(expr) = roll(expr.count, …)` are fine. */
    private fun callsItself(line: String): Boolean {
        val m = selfCall.find(line) ?: return false
        val params = m.groupValues[2].split(',').map { it.substringBefore(':').trim() }.filter { it.isNotEmpty() }
        val args = m.groupValues[3].split(',').map { it.trim() }.filter { it.isNotEmpty() }
        return params == args
    }

    @Test
    fun noExpressionFunctionCallsItself() {
        val bad = mutableListOf<String>()
        for (root in listOf("../app/src/main", "src/main")) {
            val dir = java.io.File(root)
            if (!dir.isDirectory) continue
            dir.walkTopDown().filter { it.extension == "kt" }.forEach { f ->
                f.readLines().forEachIndexed { i, line ->
                    if (callsItself(line)) bad += "${f.path}:${i + 1}: ${line.trim()}"
                }
            }
        }
        assertTrue(bad.isEmpty(), "function calls itself:\n" + bad.joinToString("\n"))
    }
}
