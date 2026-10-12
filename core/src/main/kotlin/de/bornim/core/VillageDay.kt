package de.bornim.core

/**
 * 5l Leben im Dorf (draft, `DORFTAG=1`, test tab): the villagers go about their day. Each has a few places,
 * one from each hour on: in the morning to work, at noon home or to the square, in the evening to the inn,
 * at night to their own door. They walk there along the paths (a step at a time, waiting for the hero and
 * for each other) and stroll about there as before. Off: everyone keeps to their one spot.
 */
object VillageDay {
    @Volatile var draft = false

    /** From minute [from] of the day on, stroll [wander] tiles around ([x], [y]). */
    data class Stop(val from: Int, val x: Int, val y: Int, val wander: Int)

    private fun at(h: Int, x: Int, y: Int, wander: Int, m: Int = 0) = Stop(h * 60 + m, x, y, wander)

    /** The day of each villager who has one, in order of the hour. */
    val plans: Map<String, List<Stop>> = mapOf(
        // Pim plays on the square, eats at home, runs down to the river in the afternoon
        "pim" to listOf(at(7, 15, 14, 3), at(12, 13, 23, 0), at(13, 17, 24, 2), at(17, 15, 14, 3), at(20, 13, 23, 0)),
        // Bram on his field from dawn, eats on the square, in the evening at the inn, at night by his fence
        "bram" to listOf(at(5, 20, 29, 1), at(12, 14, 15, 1), at(13, 32, 29, 1), at(19, 7, 8, 1), at(22, 10, 29, 0)),
        // Gwenna at the well in the morning, washing at the river, at the market, home at dusk
        "gwenna" to listOf(at(6, 16, 13, 1), at(9, 8, 24, 2), at(16, 14, 13, 1), at(20, 5, 15, 0)),
        // Liska sweeps in front of the inn, goes to Thessa's, hangs out the washing, back to the inn
        "liska" to listOf(at(6, 8, 7, 1), at(10, 25, 8, 0), at(11, 10, 12, 1), at(15, 8, 10, 1), at(22, 8, 7, 0)),
    )

    /** Where [id] should be at [minutes] of the day, null for those without a day. */
    fun stopAt(id: String, minutes: Int): Stop? {
        val p = plans[id] ?: return null
        return p.lastOrNull { it.from <= minutes } ?: p.last()
    }

    /** Whether ([x], [y]) is within [s]'s strolling ground. */
    fun near(s: Stop, x: Int, y: Int) = kotlin.math.abs(x - s.x) + kotlin.math.abs(y - s.y) <= s.wander

    /**
     * The first step from ([fx], [fy]) on the shortest way to ([tx], [ty]) over [open] tiles, or null when
     * there is none (or already there). Breadth first; on a village of 36×32 tiles that is quick.
     */
    fun firstStep(fx: Int, fy: Int, tx: Int, ty: Int, w: Int, h: Int, open: (Int, Int) -> Boolean): Facing? {
        if (fx == tx && fy == ty) return null
        val from = IntArray(w * h) { -1 }
        val q = ArrayDeque<Int>()
        val start = fy * w + fx
        from[start] = start
        q.add(start)
        while (q.isNotEmpty()) {
            val c = q.removeFirst()
            val cx = c % w; val cy = c / w
            if (cx == tx && cy == ty) {
                // walk back to the step after the start
                var n = c
                while (from[n] != start) n = from[n]
                val nx = n % w; val ny = n / w
                return Facing.entries.first { it.dx == nx - fx && it.dy == ny - fy }
            }
            for (d in Facing.entries) {
                val nx = cx + d.dx; val ny = cy + d.dy
                if (nx !in 0 until w || ny !in 0 until h) continue
                val k = ny * w + nx
                if (from[k] >= 0 || !(open(nx, ny) || (nx == tx && ny == ty))) continue
                from[k] = c
                q.add(k)
            }
        }
        return null
    }
}
