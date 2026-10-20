package de.bornim.core.art

/**
 * 19e (Chef 20.10., 16:22 „1 und 3“): which standing picture a figure in battle shows. Each figure breathes on its own
 * time from the start ([offsetMs], so a pack never breathes as one); after each of its moves its breathing begins again
 * at the first standing picture, where every move ends, so the way back is soft.
 */
class Breath(private val offsetMs: Long) {
    private var restAt = -offsetMs

    /** the figure is in a move at [now] (called on every picture of it) */
    fun moving(now: Long) { restAt = now }

    /** the standing picture at [now], one each [periodMs]; count it round with the number of standing pictures */
    fun index(now: Long, periodMs: Double): Int = ((now - restAt).coerceAtLeast(0) / periodMs).toInt()

    companion object {
        /** a figure's own time, from a name or a number: up to [spanMs] */
        fun offset(key: Any, spanMs: Long = 2000): Long = (key.hashCode().toLong() * 2654435761L).mod(spanMs)
    }
}
