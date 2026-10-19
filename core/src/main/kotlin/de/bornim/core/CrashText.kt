package de.bornim.core

/**
 * 227: a crash report folded for reading. A runaway recursion fills the stack with the same line (or the same few lines)
 * hundreds of times; they are shown once with "… n× gleich" under them, so the caller further down stays in view.
 */
object CrashText {
    /** Folds runs of a block of 1 to [maxBlock] lines repeated at least [minRepeats] times in a row. */
    fun fold(text: String, maxBlock: Int = 4, minRepeats: Int = 3): String {
        val lines = text.lines()
        val out = ArrayList<String>()
        var i = 0
        while (i < lines.size) {
            var best = 0; var bestRepeats = 1
            for (p in 1..maxBlock) {
                if (i + p > lines.size) break
                var r = 1
                while (i + (r + 1) * p <= lines.size && (0 until p).all { lines[i + r * p + it] == lines[i + it] }) r++
                // the shortest block that repeats wins: a line repeated 6 times is not a block of 2 repeated 3 times
                if (r >= minRepeats && best == 0) { best = p; bestRepeats = r }
            }
            if (best == 0) { out += lines[i]; i++; continue }
            for (k in 0 until best) out += lines[i + k]
            out += "\t… ${bestRepeats}× gleich" + if (best > 1) " ($best Zeilen)" else ""
            i += best * bestRepeats
        }
        return out.joinToString("\n")
    }
}
