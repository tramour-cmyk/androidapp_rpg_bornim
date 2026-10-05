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

    @Test
    fun sleepingInTheInnAtNight() {
        val g = game(Place("inn", 7, 2, Facing.DOWN))
        val inn = g.map
        // find a bed and a free tile next to it
        val (bx, by) = (0 until inn.height).flatMap { y -> (0 until inn.width).map { it to y } }.first { (x, y) -> inn.tile(x, y) == Tile.BED }
        val r = g.route(bx, by)!!
        r.steps.forEach { g.move(it) }
        g.face(r.face!!)
        g.state.hero.hp = 1
        g.state.minutes = 23 * 60
        assertEquals(ActionKind.REST, g.actionAhead())
        val day = g.state.day
        g.interact()
        var guard = 0
        while (g.mode != Mode.Explore && guard++ < 20) g.advance()
        assertEquals(7 * 60, g.state.minutes)
        assertEquals(day + 1, g.state.day)
        assertEquals(g.state.hero.maxHp, g.state.hero.hp)
        g.state.minutes = 12 * 60
        assertEquals(ActionKind.LOOK, g.actionAhead())
    }

    @Test
    fun villagersStrollButStayNearTheirSpot() {
        val g = game(Place("village", 11, 7, Facing.DOWN))
        val finn = g.map.npcs.first { it.id == "finn" }
        val start = g.walkerOf(finn)!!.x to g.walkerOf(finn)!!.y
        var moved = false
        var t = 1000L
        repeat(600) {
            t += 100
            g.update(t)
            val w = g.walkerOf(finn)!!
            if ((w.x to w.y) != start) moved = true
            assertTrue(kotlin.math.abs(w.x - finn.x) + kotlin.math.abs(w.y - finn.y) <= finn.wander)
            assertTrue(!(w.x == g.state.place.x && w.y == g.state.place.y))
        }
        assertTrue(moved, "Finn never moved")
        // he can still be found and talked to where he is now
        val w = g.walkerOf(finn)!!
        assertEquals(finn, g.npcAt(w.x, w.y))
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
