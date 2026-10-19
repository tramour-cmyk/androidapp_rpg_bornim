package de.bornim.core

import de.bornim.core.art.MapDog
import kotlin.test.Test
import kotlin.test.assertTrue

/** D29.3: the village dog trots only over open ground, from spot to spot, and never jumps. */
class VillageDogTest {
    @Test
    fun theDogWalksOnlyOverFreeGround() {
        val v = Story.village
        val bad = ArrayList<String>()
        for (n in MapDog.SPOTS.indices) {
            var (x, y) = MapDog.SPOTS[n].let { it.first.toInt() to it.second.toInt() }
            if (!v.tile(x, y).walkable) bad += "Platz $n auf $x/$y (${v.tile(x, y)})"
            for ((tx, ty) in MapDog.WAYS[n]) {
                val ex = tx.toInt(); val ey = ty.toInt()
                assertTrue(ex == x || ey == y, "Weg $n: nur gerade Strecken")
                while (x != ex || y != ey) {
                    x += Integer.signum(ex - x); y += Integer.signum(ey - y)
                    if (!v.tile(x, y).walkable || v.warps.any { it.x == x && it.y == y }) bad += "Weg $n über $x/$y (${v.tile(x, y)})"
                }
            }
            assertTrue(MapDog.SPOTS[(n + 1) % MapDog.SPOTS.size] == (x.toDouble() to y.toDouble()), "Weg $n endet am nächsten Platz")
        }
        assertTrue(bad.isEmpty(), bad.joinToString())
    }

    @Test
    fun theDogNeverJumps() {
        var last = MapDog.at(0)
        val jumps = mutableListOf<String>()
        for (t in 20L..400_000L step 20L) {
            val a = MapDog.at(t)
            val d = kotlin.math.abs(a.x - last.x) + kotlin.math.abs(a.y - last.y)
            if (d > 0.05) jumps += "${t}ms: ${last.x},${last.y} -> ${a.x},${a.y}"
            if (a.key == last.key && '>' in a.key && kotlin.math.abs(a.k - last.k) > 1) jumps += "${t}ms: ${a.key} ${last.k} -> ${a.k}"
            last = a
        }
        assertTrue(jumps.isEmpty(), jumps.take(10).joinToString("\n"))
    }
}
