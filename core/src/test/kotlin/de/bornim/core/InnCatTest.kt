package de.bornim.core

import de.bornim.core.art.MapCat
import kotlin.test.Test
import kotlin.test.assertTrue

/** 87.1 (test of 0.1.740): the inn's cat walked through the table in front of the bar. */
class InnCatTest {

    @Test
    fun theCatWalksOnlyOverFreeFloor() {
        val inn = Story.inn
        val bad = ArrayList<String>()
        for (n in MapCat.SPOTS.indices) {
            var (x, y) = MapCat.SPOTS[n].let { it.first.toInt() to it.second.toInt() }
            for ((tx, ty) in MapCat.WAYS[n]) {
                val ex = tx.toInt(); val ey = ty.toInt()
                assertTrue(ex == x || ey == y, "Weg $n: nur gerade Strecken")
                while (x != ex || y != ey) {
                    x += Integer.signum(ex - x); y += Integer.signum(ey - y)
                    if (!inn.tile(x, y).walkable) bad += "Weg $n über $x/$y (${inn.tile(x, y)})"
                }
            }
            assertTrue(MapCat.SPOTS[(n + 1) % MapCat.SPOTS.size] == (x.toDouble() to y.toDouble()), "Weg $n endet am nächsten Platz")
        }
        assertTrue(bad.isEmpty(), bad.joinToString())
    }
}
