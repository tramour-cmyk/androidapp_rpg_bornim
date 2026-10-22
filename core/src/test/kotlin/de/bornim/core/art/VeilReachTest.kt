package de.bornim.core.art

import de.bornim.core.MapKind
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals

class VeilReachTest {
    /** 267.2: in the woods the black screen waits for every piece of the ground, wherever the hero comes in; elsewhere for those about him. */
    @Test
    fun woodsWaitForAllTheGround() {
        for (m in World.maps.values) {
            val all = ((m.width + MapGround.CH - 1) / MapGround.CH) * ((m.height + MapGround.CH - 1) / MapGround.CH)
            for ((x, y) in listOf(0 to 0, m.width - 1 to m.height - 1, 0 to m.height - 1, m.width / 2 to m.height / 2)) {
                val n = MapGround.partsNear(m, x, y, MapGround.veilReach(m)).second
                if (m.kind == MapKind.FOREST) assertEquals(all, n, "${m.id} at $x,$y")
                else assertEquals(MapGround.partsNear(m, x, y).second, n, "${m.id} at $x,$y")
            }
        }
    }
}
