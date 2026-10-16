package de.bornim.core

import de.bornim.core.art.MapSun
import kotlin.test.Test
import kotlin.test.assertEquals

/** 89: the sun's stand for the shadows changes only at a cut, never while one looks. */
class SunStandTest {
    private fun game(minutes: Int) = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).also { it.minutes = minutes }, Lang.DE)

    @Test
    fun aNewOrLoadedGameTakesTheStandFromItsHour() {
        game(8 * 60); assertEquals(MapSun.Stand.MORNING, MapSun.stand)
        game(12 * 60); assertEquals(MapSun.Stand.NOON, MapSun.stand)
        game(17 * 60); assertEquals(MapSun.Stand.EVENING, MapSun.stand)
    }

    @Test
    fun afterMidnightTheShadowsWaitForTheMorningNotTheEvening() {
        assertEquals(MapSun.Stand.MORNING, MapSun.Stand.at(0))
        assertEquals(MapSun.Stand.MORNING, MapSun.Stand.at(3 * 60))
        assertEquals(MapSun.Stand.MORNING, MapSun.Stand.at(9 * 60 + 59))
        assertEquals(MapSun.Stand.NOON, MapSun.Stand.at(10 * 60))
        assertEquals(MapSun.Stand.EVENING, MapSun.Stand.at(15 * 60))
        assertEquals(MapSun.Stand.EVENING, MapSun.Stand.at(23 * 60 + 59))
        assertEquals(MapSun.Stand.MORNING, MapSun.Stand.at(24 * 60 + 30))
    }

    @Test
    fun theClockAloneDoesNotMoveTheShadowsButACutDoes() {
        val g = game(9 * 60 + 59).also { g -> var n = 0; while (g.mode is Mode.Dialog && n++ < 50) g.advance() }
        g.state.minutes = 10 * 60 + 5
        assertEquals(MapSun.Stand.MORNING, MapSun.stand)
        g.cheatWarp(g.state.place)
        assertEquals(MapSun.Stand.NOON, MapSun.stand)
    }

}
