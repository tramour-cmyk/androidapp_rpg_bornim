package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

/** The inn's cat (draft): it never jumps, and it walks only from spot to spot. */
class MapCatTest {
    @Test
    fun theCatNeverJumps() {
        var last = MapCat.at(0)
        val jumps = mutableListOf<String>()
        // two rounds in steps of 20 ms
        for (t in 20L..400_000L step 20L) {
            val a = MapCat.at(t)
            val d = kotlin.math.abs(a.x - last.x) + kotlin.math.abs(a.y - last.y)
            if (d > 0.05) jumps += "${t}ms: ${last.x},${last.y} -> ${a.x},${a.y}"
            // a blend moves at most one step of eight per picture, and only within the same move
            if (a.key == last.key && '>' in a.key && kotlin.math.abs(a.k - last.k) > 1) jumps += "${t}ms: ${a.key} ${last.k} -> ${a.k}"
            last = a
        }
        assertTrue(jumps.isEmpty(), jumps.take(10).joinToString("\n"))
    }
}
