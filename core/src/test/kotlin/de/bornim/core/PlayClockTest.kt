package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse

/** 132: the played time counts only while the clock runs, is saved with the game, and old saves start at 0. */
class PlayClockTest {
    private fun state() = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun countsOnlyWhileRunning() {
        val s = state()
        val c = PlayClock()
        c.book(s, 1_000)
        assertEquals(0, s.playedMs)
        c.start(1_000)
        c.book(s, 61_000)
        assertEquals(60_000, s.playedMs)
        c.stop(s, 91_000)
        assertEquals(90_000, s.playedMs)
        assertFalse(c.running)
        c.book(s, 500_000)
        assertEquals(90_000, s.playedMs, "app in the background: no count")
        c.start(600_000)
        c.start(700_000)
        c.stop(s, 610_000)
        assertEquals(100_000, s.playedMs, "a second start does not reset the count")
        c.start(700_000)
        c.drop()
        c.book(s, 900_000)
        assertEquals(100_000, s.playedMs)
    }

    @Test
    fun savedWithTheGame() {
        val s = state()
        s.playedMs = 8_040_000
        assertEquals(8_040_000, GameState.fromJson(s.toJson()).playedMs)
        val old = s.toJson().replace("\"playedMs\":8040000", "\"playedMs\":0").replace(",\"playedMs\":0", "")
        assertFalse("playedMs" in old)
        assertEquals(0, GameState.fromJson(old).playedMs)
    }

    @Test
    fun shownInHoursAndMinutes() {
        assertEquals("Gespielt: 2 Std. 14 Min.", PlayClock.played((2 * 60 + 14) * 60_000L + 59_000, Lang.DE))
        assertEquals("Gespielt: 0 Min.", PlayClock.played(0, Lang.DE))
        assertEquals("Gespielt: 45 Min.", PlayClock.played(45 * 60_000L, Lang.DE))
        assertEquals("Played: 1 h 0 min", PlayClock.played(60 * 60_000L, Lang.EN))
    }
}
