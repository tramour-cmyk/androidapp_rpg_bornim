package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * 609 (Chef 07.11., Build 268: „Hinter Schänke ist ein Baum, der verhindert, dass man um das Haus rumlaufen kann Richtung Schranke,
 * der muss weg. Dann gleich prüfen, ob man an allen Häusern auf der Waldseite passieren kann“): behind every house of the northern
 * row (the inn, the two cottages, the shop) one walks from its west side to its east side without stepping south of the roofs.
 */
class VillageRoundTest {
    @Test
    fun behindEveryNorthernHouseOneCanPass() {
        val m = World["village"]
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val roofs = (0 until 8).flatMap { y -> (0 until m.width).map { x -> x to y } }.filter { (x, y) -> m.tile(x, y) == Tile.ROOF }
        // houses of the northern row: runs of roof on their top line
        val top = roofs.groupBy { it.second }.minOf { it.key }
        val houses = mutableListOf<IntRange>()
        for (x in 0 until m.width) {
            val roof = (top..top + 1).any { m.tile(x, it) == Tile.ROOF }
            if (roof && (houses.isEmpty() || houses.last().last != x - 1)) houses.add(x..x)
            else if (roof) houses[houses.size - 1] = houses.last().first..x
        }
        assertTrue(houses.size >= 4, "Häuser der Nordreihe: $houses")
        val stuck = mutableListOf<String>()
        for (h in houses) {
            val y0 = (top downTo 1).first { y -> h.all { x -> m.tile(x, y) != Tile.ROOF } }
            // from the free tile west of the house to the free tile east of it, only rows above the roof
            val from = ((h.first - 1) downTo 0).map { it to y0 }.firstOrNull { (x, y) -> m.walkable(x, y, s) }
            val to = ((h.last + 1) until m.width).map { it to y0 }.firstOrNull { (x, y) -> m.walkable(x, y, s) }
            if (from == null || to == null) { stuck.add("Haus $h: kein freies Feld neben dem Dach in Zeile $y0"); continue }
            val seen = hashSetOf(from); val q = ArrayDeque(listOf(from))
            while (q.isNotEmpty()) {
                val (x, y) = q.removeFirst()
                for ((dx, dy) in listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)) {
                    val n = x + dx to y + dy
                    if (n.second > y0 || n in seen || !m.walkable(n.first, n.second, s)) continue
                    seen.add(n); q.add(n)
                }
            }
            if (to !in seen) stuck.add("Haus $h: von $from nicht nach $to hinter dem Dach")
        }
        assertTrue(stuck.isEmpty(), stuck.joinToString("; "))
    }
}
