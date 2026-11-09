package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class LifeTest {
    private fun game(place: Place): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.CLERIC), Lang.DE, Dice(Random(5)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.place = place
        return g
    }

    private fun run(g: Game, seconds: Int, from: Long = 1000) {
        var t = from
        g.update(t)
        repeat(seconds * 10) {
            t += 100
            g.update(t)
        }
    }

    @Test
    fun clockRunsAndWrapsAtMidnight() {
        val g = game(Place("village", 11, 7, Facing.DOWN))
        g.state.minutes = 23 * 60 + 30
        val day = g.state.day
        run(g, 60)
        assertEquals(30, g.state.minutes)
        assertEquals(day + 1, g.state.day)
        assertTrue(g.isNight)
        g.state.minutes = 12 * 60
        assertEquals(1f, g.daylight)
    }

    /** 86.9: a room at Rowena's counter costs gold, a long rest of 8 hours; 604: upstairs, the taproom has no bed. */
    @Test
    fun sleepingInTheInnCostsARoom() {
        val g = game(Place("inn", 1, 3, Facing.UP))
        g.state.hero.hp = 1
        g.state.gold = 10
        g.state.minutes = 23 * 60
        val day = g.state.day
        g.interact()
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        assertEquals(Mode.Rest(Resting.Spot.TAVERN), g.mode)
        g.rest(Resting.Kind.LONG, Resting.Spot.TAVERN)
        val said = mutableListOf<String>()
        guard = 0
        while (g.mode != Mode.Explore && guard++ < 20) { said += g.mode.toString(); g.advance() }
        assertTrue(said.any { "Du steigst die Treppe hinauf" in it }, "[604.zimmerfertig] after the room")
        assertEquals(7 * 60, g.state.minutes)
        assertEquals(day + 1, g.state.day)
        assertEquals(g.state.hero.maxHp, g.state.hero.hp)
        assertEquals(10 - Resting.ROOM_PRICE, g.state.gold)
    }

    @Test
    fun villagersStrollButStayNearTheirSpot() {
        val g = game(Place("village", 11, 7, Facing.DOWN))
        val pim = g.map.npcs.first { it.id == "pim" }
        val start = g.walkerOf(pim)!!.x to g.walkerOf(pim)!!.y
        var moved = false
        var t = 1000L
        repeat(600) {
            t += 100
            g.update(t)
            val w = g.walkerOf(pim)!!
            if ((w.x to w.y) != start) moved = true
            assertTrue(kotlin.math.abs(w.x - pim.x) + kotlin.math.abs(w.y - pim.y) <= pim.wander)
            assertTrue(!(w.x == g.state.place.x && w.y == g.state.place.y))
        }
        assertTrue(moved, "Pim never moved")
        // he can still be found and talked to where he is now
        val w = g.walkerOf(pim)!!
        assertEquals(pim, g.npcAt(w.x, w.y))
    }

    @Test
    fun undeadComeOutAtNight() {
        val g = game(Place("forest", 10, 20, Facing.UP))
        g.state.minutes = 23 * 60
        val night = g.map.encounters!!.night!!.map { it.first }.toSet()
        assertTrue(g.roamers.isNotEmpty())
        assertTrue(g.roamers.all { it.monster in night })
    }
}
