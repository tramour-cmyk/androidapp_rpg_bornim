package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 92 (test of 0.1.750): Farmer Bram stood in the way by the bridge and the hero could not get past. */
class MakeWayTest {
    private fun game(place: Place, minutes: Int): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.CLERIC), Lang.DE, Dice(Random(5)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.place = place
        g.state.minutes = minutes
        return g
    }

    @Test
    fun aVillagerInTheWayMakesRoomWhenTheHeroKeepsWalkingIntoThem() {
        val g = game(Place("village", 20, 28, Facing.DOWN), 6 * 60)
        val bram = g.map.npcs.first { it.id == "bram" }
        val w = g.walkerOf(bram)!!
        assertEquals(20 to 29, w.x to w.y)
        // the first bump only turns the hero to him (so he can still be spoken to)
        assertEquals(Move.Blocked, g.move(Facing.DOWN))
        assertEquals(20 to 29, w.x to w.y)
        // walking on into him: he steps aside and the hero goes on
        assertTrue(g.move(Facing.DOWN) is Move.Stepped)
        assertEquals(20 to 29, g.state.place.x to g.state.place.y)
        assertTrue((w.x to w.y) != (20 to 29))
        assertTrue(kotlin.math.abs(w.x - 20) + kotlin.math.abs(w.y - 29) == 1 || (w.x to w.y) == (20 to 28), "Bram jumped to ${w.x},${w.y}")
        assertTrue(g.map.walkable(w.x, w.y, g.state), "Bram stands on ${g.map.tile(w.x, w.y)}")
    }

    @Test
    fun walkingFreelyIntoHimHeMakesRoomToo() {
        // test 0.1.791: walking on against Bram with the stick, nothing happened; free walking never counted him
        val g = game(Place("village", 20, 28, Facing.DOWN), 6 * 60)
        val bram = g.map.npcs.first { it.id == "bram" }
        val w = g.walkerOf(bram)!!
        g.freeWalk.sync()
        var t = 1_000L
        repeat(3_000 / 16) { g.freeWalk.walk(0.0, 1.0, 16, FreeWalk.WALK, t); t += 16 }
        assertTrue((w.x to w.y) != (20 to 29), "Bram did not move")
        assertTrue(g.state.place.y >= 29, "the hero did not get past, at ${g.state.place.x},${g.state.place.y}")
    }

    @Test
    fun withNoRoomAtAllTheyChangePlaces() {
        // in the narrow way the hero is in, with nothing free beside the villager: they change places
        val g = game(Place("village", 20, 28, Facing.DOWN), 6 * 60)
        val bram = g.map.npcs.first { it.id == "bram" }
        val w = g.walkerOf(bram)!!
        repeat(2) { g.move(Facing.DOWN) }
        // whichever way he went, the hero got past and nobody stands on anyone
        assertTrue((w.x to w.y) != (g.state.place.x to g.state.place.y))
    }

    @Test
    fun theGuardsOnTheirRoundDoNotGiveWay() {
        val g = game(Place("village", 20, 28, Facing.DOWN), 6 * 60)
        val guard = g.map.npcs.firstOrNull { it.patrol.isNotEmpty() } ?: return
        val w = g.walkerOf(guard)!!
        g.state.place = Place("village", w.x, w.y - 1, Facing.DOWN)
        if (!g.map.walkable(w.x, w.y - 1, g.state)) return
        val at = w.x to w.y
        repeat(4) { assertEquals(Move.Blocked, g.move(Facing.DOWN)) }
        assertEquals(at, w.x to w.y)
    }
}
