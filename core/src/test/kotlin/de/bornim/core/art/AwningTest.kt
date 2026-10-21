package de.bornim.core.art

import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertTrue

/** 278 (Chef, Build 53: "Held steht in Markise"): the shop's awning is sorted by its own front edge, not by the house's front wall. */
class AwningTest {
    @Test
    fun theAwningLiesInFrontOfAHeroUnderIt() {
        val village = World["village"]
        val f = MapTownIso.houses(village).map { it.first }.first { it.x == 26 && it.top == 3 }
        val objs = MapTownIso.houseObjects(village, f.x, f.y)!!
        val house = f.x * 1000 + f.y + 1
        fun depth(o: WorldArt.Obj) = o.sortY + o.x + o.img.width / o.density / 2
        val walls = objs.filter { it.group == house }.associateBy { it.x }
        val cloth = objs.filter { it.group == house + 500_000 }
        assertTrue(cloth.size >= f.n, "awning in ${cloth.size} strips")
        for (o in cloth) {
            assertTrue(o.area == null && o.low, "awning strip bound to the house's area or fading")
            val wall = walls[o.x] ?: continue
            // a hero 0.3 tiles in front of the wall on this strip's line sorts 0.6 tiles behind the wall's strip;
            // the awning reaches 0.7 out (0.55 at its east end), so it sorts later still
            assertTrue(depth(o) - depth(wall) >= WorldArt.T / 2, "strip at ${o.x}: awning only ${depth(o) - depth(wall)} px past the wall")
        }
    }
}
