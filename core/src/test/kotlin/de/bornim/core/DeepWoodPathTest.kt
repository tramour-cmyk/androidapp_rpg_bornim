package de.bornim.core

import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * 353 (Chef 24.10.: an manchen Wegen im Tiefen Wald hängen bleiben, „rumeiern“): someone following each way of the deep
 * forest from the way in, steering at a spot three tiles ahead on it as one does with the stick, cutting the bends,
 * glides round the trees there and never stands still.
 */
class DeepWoodPathTest {
    @Test
    fun everyWayIsWalkedWithoutCatchingOnATree() {
        val m = World["deep_forest"]
        val path = (0 until m.height).flatMap { y -> (0 until m.width).map { x -> x to y } }.filter { (x, y) -> m.tile(x, y) == Tile.PATH }.toSet()
        fun nb(p: Pair<Int, Int>) = listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1).map { p.first + it.first to p.second + it.second }.filter { it in path }
        val start = 0 to 18
        fun route(to: Pair<Int, Int>): List<Pair<Int, Int>> {
            val prev = HashMap<Pair<Int, Int>, Pair<Int, Int>>(); val q = ArrayDeque(listOf(start)); prev[start] = start
            while (q.isNotEmpty()) { val c = q.removeFirst(); if (c == to) break; for (n in nb(c)) if (n !in prev) { prev[n] = c; q.add(n) } }
            if (to !in prev) return emptyList()
            val r = mutableListOf(to); while (r.last() != start) r.add(prev[r.last()]!!); return r.reversed()
        }
        val ends = path.filter { nb(it).size == 1 && it != start }
        assertTrue(ends.size >= 4, "Wegenden: $ends")
        val stuck = mutableListOf<String>()
        for (end in ends) {
            val r = route(end)
            if (r.size < 3) continue
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
            val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
            var guard = 0
            while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
            (g.roamers as? MutableList<Roamer>)?.clear()
            s.place = Place("deep_forest", r[1].first, r[1].second, Facing.RIGHT); g.freeWalk.sync()
            val pts = r.drop(1).map { it.first + 0.5 to it.second + 0.5 }
            var t = 1_000L; var i = 0; var frames = 0
            var lx = g.freeWalk.x; var ly = g.freeWalk.y
            while (i < pts.size - 1 && frames < 3_000 && g.mode is Mode.Explore) {
                val hx = g.freeWalk.x; val hy = g.freeWalk.y
                while (i < pts.size - 1 && hypot(pts[i + 1].first - hx, pts[i + 1].second - hy) < hypot(pts[i].first - hx, pts[i].second - hy) + 0.01) i++
                val aim = pts[minOf(i + 3, pts.size - 1)]
                g.freeWalk.walk(aim.first - hx, aim.second - hy, 16, FreeWalk.WALK, t); t += 16; frames++
                // half a second: at walking pace the hero comes about 0.8 tiles; under half of that he hangs or wobbles
                if (frames % 30 == 0) {
                    if (hypot(g.freeWalk.x - lx, g.freeWalk.y - ly) < 0.4) stuck += "Weg nach $end bei (%.1f, %.1f)".format(g.freeWalk.x, g.freeWalk.y)
                    lx = g.freeWalk.x; ly = g.freeWalk.y
                }
            }
            if (i < pts.size - 1 && g.mode is Mode.Explore) stuck += "Weg nach $end nicht zu Ende"
        }
        assertTrue(stuck.isEmpty(), "hängen geblieben: ${stuck.distinct()}")
    }
}
