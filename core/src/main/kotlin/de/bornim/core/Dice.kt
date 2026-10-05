package de.bornim.core

import kotlin.random.Random

/** A dice expression such as 2d6+3. */
data class DiceExpr(val count: Int, val sides: Int, val bonus: Int = 0) {
    val average: Int get() = (count * (sides + 1)) / 2 + bonus
    val max: Int get() = count * sides + bonus

    fun label(lang: Lang): String {
        val d = if (lang == Lang.DE) "W" else "d"
        val b = when {
            bonus > 0 -> "+$bonus"
            bonus < 0 -> "$bonus"
            else -> ""
        }
        return "$count$d$sides$b"
    }
}

fun dice(count: Int, sides: Int, bonus: Int = 0) = DiceExpr(count, sides, bonus)

class Dice(private val rng: Random = Random.Default) {
    fun d(sides: Int): Int = rng.nextInt(1, sides + 1)
    fun d20(): Int = d(20)
    fun roll(count: Int, sides: Int): Int = (1..count).sumOf { d(sides) }
    fun roll(expr: DiceExpr): Int = roll(expr.count, expr.sides) + expr.bonus
    fun chance(p: Double): Boolean = rng.nextDouble() < p
    fun <E> pick(list: List<E>): E = list[rng.nextInt(list.size)]

    fun <E> weighted(entries: List<Pair<E, Int>>): E {
        var r = rng.nextInt(entries.sumOf { it.second })
        for ((e, w) in entries) {
            if (r < w) return e
            r -= w
        }
        return entries.last().first
    }

    /** d20 with advantage (+1), disadvantage (-1) or neither (0). */
    fun d20(mode: Int): Int = when {
        mode > 0 -> maxOf(d20(), d20())
        mode < 0 -> minOf(d20(), d20())
        else -> d20()
    }
}
