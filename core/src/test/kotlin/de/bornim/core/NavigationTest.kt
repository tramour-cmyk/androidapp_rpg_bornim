package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class NavigationTest {
    private fun game(place: Place): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(kotlin.random.Random(3)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.flags += Story.QUEST_STARTED
        g.state.flags += Story.BARRIER_OPEN
        g.state.place = place
        return g
    }

    private fun walk(g: Game, r: Route) {
        for (d in r.steps) {
            assertTrue(g.move(d) is Move.Stepped, "step $d blocked")
            g.afterStep()
        }
        r.face?.let { g.face(it) }
    }

    @Test
    fun tapOnEveryVillagerTalksToThem() {
        var talked = 0
        for (mapId in listOf("village", "shop", "inn", "temple")) {
            val m = World[mapId]
            val probe = game(Place(mapId, 0, 0, Facing.UP))
            val w = m.warps.first()
            val (sx, sy) = Facing.entries.map { (w.x + it.dx) to (w.y + it.dy) }
                .first { (x, y) -> m.walkable(x, y, probe.state) && m.warpAt(x, y) == null }
            val start = Place(mapId, sx, sy, Facing.UP)
            for (npc in m.npcs) {
                val g = game(start)
                if (!npc.visible(g.state)) continue
                val r = g.route(npc.x, npc.y)
                println("$mapId ${npc.id} route=${r?.steps?.size}")
                if (r == null) continue
                walk(g, r)
                assertTrue(r.interact)
                assertEquals(ActionKind.TALK, g.actionAhead(), "$mapId ${npc.id}")
                g.interact()
                assertTrue(g.mode is Mode.Dialog || g.mode is Mode.Shop, "$mapId ${npc.id}: ${g.mode}")
                talked++
            }
        }
        println("talked to $talked npcs")
        assertTrue(talked >= 6, "only $talked npcs reached")
    }

    @Test
    fun tapOnFloorWalksThere() {
        val g = game(Place("village", 11, 7, Facing.DOWN))
        val m = g.map
        var tested = 0
        for (y in 0 until m.height) for (x in 0 until m.width) {
            if (!g.free(x, y) || m.warpAt(x, y) != null || (x == 11 && y == 7)) continue
            val r = g.route(x, y) ?: continue
            val copy = game(Place("village", 11, 7, Facing.DOWN))
            for (d in r.steps) assertTrue(copy.move(d) is Move.Stepped)
            assertEquals(x to y, copy.state.place.x to copy.state.place.y)
            tested++
        }
        assertTrue(tested > 50, "only $tested reachable tiles")
    }

    @Test
    fun wallsHaveNoRouteAndNothingAheadInOpenField() {
        val g = game(Place("village", 11, 7, Facing.DOWN))
        val m = g.map
        val wall = (0 until m.height).flatMap { y -> (0 until m.width).map { it to y } }
            .first { (x, y) -> !m.walkable(x, y, g.state) && g.actionAt(x, y) == null }
        assertNull(g.route(wall.first, wall.second))
        assertNotNull(Facing.entries)
    }
}
