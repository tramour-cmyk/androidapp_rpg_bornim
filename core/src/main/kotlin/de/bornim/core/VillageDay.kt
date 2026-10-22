package de.bornim.core

/**
 * 5l Leben im Dorf: the villagers go about their day. Each has a few places,
 * one from each hour on: in the morning to work, at noon home or to the square, in the evening to the inn,
 * at night to their own door. They walk there along the paths (a step at a time, waiting for the hero and
 * for each other) and stroll about there as before.
 */
object VillageDay {
    /** From minute [from] of the day on, stroll [wander] tiles around ([x], [y]); [inside]: once at the door, gone in for the night. */
    data class Stop(val from: Int, val x: Int, val y: Int, val wander: Int, val inside: Boolean = false)

    private fun at(h: Int, x: Int, y: Int, wander: Int, m: Int = 0, inside: Boolean = false) = Stop(h * 60 + m, x, y, wander, inside)

    /** The day of each villager who has one, in order of the hour. */
    val plans: Map<String, List<Stop>> = mapOf(
        // Pim plays on the square, eats at home, runs down to the river in the afternoon
        // 5la (Nutzer 13.10., 21:1x: Pim at four in the morning outside, he belongs in bed): from nine in the evening indoors
        "pim" to listOf(at(7, 15, 14, 3), at(12, 13, 23, 0), at(13, 17, 24, 2), at(17, 15, 14, 3), at(20, 13, 23, 0), at(21, 13, 23, 0, inside = true)),
        // Bram on his field from dawn, eats on the square, in the evening at the inn, at night by his fence
        "bram" to listOf(at(5, 20, 29, 1), at(12, 14, 15, 1), at(13, 32, 29, 1), at(19, 7, 8, 1), at(22, 10, 29, 0)),
        // Gwenna at the well in the morning, washing at the river, at the market, home at dusk
        "gwenna" to listOf(at(6, 16, 13, 1), at(9, 8, 24, 2), at(16, 14, 13, 1), at(20, 5, 15, 0), at(22, 5, 15, 0, inside = true)),
        // Liska sweeps in front of the inn, goes to Thessa's, hangs out the washing, back to the inn
        "liska" to listOf(at(6, 8, 7, 1), at(10, 25, 8, 0), at(11, 10, 12, 1), at(15, 8, 10, 1), at(22, 8, 7, 0), at(23, 8, 7, 0, inside = true)),
    )

    /** Where [id] should be at [minutes] of the day, null for those without a day. */
    fun stopAt(id: String, minutes: Int): Stop? {
        val p = plans[id] ?: return null
        return p.lastOrNull { it.from <= minutes } ?: p.last()
    }

    /** Whether ([x], [y]) is within [s]'s strolling ground. */
    fun near(s: Stop, x: Int, y: Int) = kotlin.math.abs(x - s.x) + kotlin.math.abs(y - s.y) <= s.wander

    /** 330: one step on the way, straight or across to a corner neighbour. */
    data class Step(val dx: Int, val dy: Int)

    private val STEPS = listOf(Step(0, 1), Step(0, -1), Step(-1, 0), Step(1, 0), Step(1, 1), Step(1, -1), Step(-1, 1), Step(-1, -1))

    /**
     * The first step from ([fx], [fy]) on the shortest way to ([tx], [ty]) over [open] tiles, or null when
     * there is none (or already there). 330: across too (Chef 23.10.: not only at right angles), but never
     * round a corner: both tiles beside a step across must be open. Straight 5, across 7 (≈ √2).
     */
    fun firstStep(fx: Int, fy: Int, tx: Int, ty: Int, w: Int, h: Int, open: (Int, Int) -> Boolean): Step? {
        if (fx == tx && fy == ty) return null
        val cost = IntArray(w * h) { Int.MAX_VALUE }
        val from = IntArray(w * h) { -1 }
        val q = java.util.PriorityQueue<Long>()
        val start = fy * w + fx
        cost[start] = 0
        from[start] = start
        q.add(start.toLong())
        fun pass(x: Int, y: Int) = x in 0 until w && y in 0 until h && (open(x, y) || (x == tx && y == ty))
        while (q.isNotEmpty()) {
            val e = q.poll()
            val c = (e and 0xFFFFFFFFL).toInt()
            if ((e ushr 32).toInt() > cost[c]) continue
            val cx = c % w; val cy = c / w
            if (cx == tx && cy == ty) {
                // walk back to the step after the start
                var n = c
                while (from[n] != start) n = from[n]
                return Step(n % w - fx, n / w - fy)
            }
            for (d in STEPS) {
                val nx = cx + d.dx; val ny = cy + d.dy
                if (!pass(nx, ny)) continue
                val diag = d.dx != 0 && d.dy != 0
                if (diag && !(open(cx + d.dx, cy) && open(cx, cy + d.dy))) continue
                val k = ny * w + nx
                val nc = cost[c] + if (diag) 7 else 5
                if (nc >= cost[k]) continue
                cost[k] = nc
                from[k] = c
                q.add((nc.toLong() shl 32) or k.toLong())
            }
        }
        return null
    }
}
