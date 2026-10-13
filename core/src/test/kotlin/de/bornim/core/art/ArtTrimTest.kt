package de.bornim.core.art

import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertTrue

/** 30.2: the ground of only two maps is kept, the folk drawn on two threads in all, memory short lets go of more. */
class ArtTrimTest {
    private fun waitFor(ms: Long, ok: () -> Boolean): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) { if (ok()) return true; Thread.sleep(50) }
        return ok()
    }

    @Test fun groundOfTwoMapsKept() {
        val a = World["village"]; val b = World["forest"]; val c = World["cave"]
        for (m in listOf(a, b, c)) {
            MapGround.prepare(m, 5, 5)
            assertTrue(waitFor(60_000) { MapGround.readyNear(m, 5, 5) }, "${m.id} drawn")
        }
        assertTrue(MapGround.chunk(a, 0, 0) == null, "the first map let go")
        assertTrue(MapGround.chunk(b, 0, 0) != null, "the one before kept")
        MapGround.trim()
        assertTrue(MapGround.chunk(b, 0, 0) == null, "memory short: only the last")
        assertTrue(MapGround.readyNear(c, 5, 5))
        // back to the first: drawn again
        MapGround.prepare(a, 5, 5)
        assertTrue(waitFor(60_000) { MapGround.readyNear(a, 5, 5) })
    }

    @Test fun everyoneStandsAndOnlyTwoThreadsDraw() {
        // Garrick at his fire in the forest (the village folk are dolls only on the sheet so far)
        val map = World["forest"]
        MapFolk.prepareFor(map)
        var most = 0
        assertTrue(waitFor(120_000) {
            most = maxOf(most, Thread.getAllStackTraces().keys.count { it.name == "map-folk" && it.isAlive })
            MapFolk.standing(map)
        }, "everyone drawn standing")
        assertTrue(most <= 2, "at most two threads for the folk, were $most")
        val folk = map.npcs.mapNotNull { MapFolk.of(it.id) }
        assertTrue(folk.isNotEmpty())
        MapFolk.keepOnly(emptySet())
        assertTrue(folk.all { MapFolk.frame(it, 0, 0) == null }, "let go")
    }
}
