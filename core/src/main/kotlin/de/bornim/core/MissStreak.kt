package de.bornim.core

/**
 * Softens the hero's runs of bad luck within one fight: after three misses in a row the next
 * attack gets +2, each further miss +1 more, at most +4; a hit starts over. Unseen, since the
 * battle lines show no rolls. A natural 1 still misses and crits are untouched (the bonus only
 * adds to the total). Off, it only counts (for the balance comparison).
 */
class MissStreak(private val on: Boolean = true) {
    var misses = 0
        private set

    /** Longest run of misses in this fight, for the balance checks. */
    var longest = 0
        private set

    val bonus: Int get() = if (!on || misses < START) 0 else minOf(MAX, misses - 1)

    fun miss() {
        misses++
        longest = maxOf(longest, misses)
    }

    fun hit() {
        misses = 0
    }

    companion object {
        const val START = 3
        const val MAX = 4
    }
}
