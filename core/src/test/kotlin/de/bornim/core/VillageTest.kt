package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class VillageTest {
    private fun game(place: Place): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE)
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.place = place
        return g
    }

    @Test
    fun everyDoorAndPersonCanBeReached() {
        val g = game(Place("village", 17, 2, Facing.DOWN))
        val map = g.map
        for (w in map.warps.filter { it.y > 0 && it.requires != Story.LOCKED }) {
            assertNotNull(g.route(w.x, w.y), "door at ${w.x},${w.y}")
        }
        for (npc in map.npcs) assertTrue(map.walkable(npc.x, npc.y, g.state) || map.npcAt(npc.x, npc.y, g.state) != null, npc.id)
        // Interiors lead back onto a free tile in front of their door.
        for (id in listOf("inn", "shop", "elder", "temple")) {
            val back = World[id].warps.single().to
            assertTrue(map.walkable(back.x, back.y, g.state), "$id exit ${back.x},${back.y}")
        }
    }

    @Test
    fun lockedHomesStayShut() {
        val g = game(Place("village", 12, 6, Facing.UP))
        g.move(Facing.UP)
        assertEquals(Place("village", 12, 6, Facing.UP), g.state.place)
        assertTrue(g.mode is Mode.Dialog)
    }

    @Test
    fun oldSavesInsideANewHouseAreMovedOut() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.place = Place("village", 4, 4, Facing.DOWN) // now the roof of the inn
        val g = Game(s, Lang.DE)
        g.begin()
        assertTrue(g.map.walkable(s.place.x, s.place.y, s))
    }
}
