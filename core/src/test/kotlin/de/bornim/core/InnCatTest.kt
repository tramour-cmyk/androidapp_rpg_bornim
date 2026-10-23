package de.bornim.core

import de.bornim.core.art.MapCat
import kotlin.test.Test
import kotlin.test.assertTrue

/** 87.1 (test of 0.1.740): the inn's cat walked through the table in front of the bar. */
class InnCatTest {
    private val MAPS = listOf(Story.village, Story.inn, Story.shop, Story.temple, Story.forest, Story.cave)

    @Test
    fun theCatWalksOnlyOverFreeFloor() {
        val inn = Story.inn
        val bad = ArrayList<String>()
        for (n in MapCat.SPOTS.indices) {
            var (x, y) = MapCat.SPOTS[n].let { it.first.toInt() to it.second.toInt() }
            for ((tx, ty) in MapCat.WAYS[n]) {
                val ex = tx.toInt(); val ey = ty.toInt()
                assertTrue(ex == x || ey == y || kotlin.math.abs(ex - x) == kotlin.math.abs(ey - y), "Weg $n: nur gerade oder genau schräge Strecken")
                while (x != ex || y != ey) {
                    val sx = Integer.signum(ex - x); val sy = Integer.signum(ey - y)
                    // 330: across never round a corner: both tiles beside the step open
                    if (sx != 0 && sy != 0 && !(inn.tile(x + sx, y).walkable && inn.tile(x, y + sy).walkable)) bad += "Weg $n schneidet die Ecke bei $x/$y"
                    x += sx; y += sy
                    if (!inn.tile(x, y).walkable) bad += "Weg $n über $x/$y (${inn.tile(x, y)})"
                }
            }
            assertTrue(MapCat.SPOTS[(n + 1) % MapCat.SPOTS.size] == (x.toDouble() to y.toDouble()), "Weg $n endet am nächsten Platz")
        }
        assertTrue(bad.isEmpty(), bad.joinToString())
    }

    /** 87.2: Rowena (and Thessa) stand up to their counters, so the cloth reaches the board; nobody else is moved by it. */
    @Test
    fun rowenaStandsAtHerCounter() {
        val rowena = Story.inn.npcs.first { it.id == "rowena" }
        assertTrue(de.bornim.core.art.MapFolk.nudge(rowena, Story.inn).second > 0)
        val moved = MAPS.flatMap { m -> m.npcs.filter { de.bornim.core.art.MapFolk.nudge(it, m) != (0 to 0) }.map { it.id } }.toSet()
        println("verschoben: $moved")
        // 152: Garrick no longer, so he is as near from every side
        assertTrue(moved == setOf("rowena", "thessa"), "verschoben: $moved")
    }
}
