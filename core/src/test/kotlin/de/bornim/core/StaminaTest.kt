package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 86.3: breath for running on the map. */
class StaminaTest {
    private fun state() = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)

    /** Runs frames of 20 ms for [ms]; returns how long the hero actually ran. */
    private fun run(s: GameState, ms: Long, moving: Boolean = true, run: Boolean = true): Long {
        var ran = 0L
        var t = 0L
        while (t < ms) { if (Stamina.step(s, 20, moving, run)) ran += 20; t += 20 }
        return ran
    }

    /** Runs until out of breath; returns how long that took. */
    private fun runEmpty(s: GameState): Long {
        var ran = 0L
        while (!s.winded && ran < 120_000) { Stamina.step(s, 20, true, true); ran += 20 }
        return ran
    }

    @Test
    fun aFullStoreLastsAsLongAsConstitutionSays() {
        val s = state()
        val lasts = Stamina.lastsMs(s.hero)
        val ran = runEmpty(s)
        assertTrue(ran in (lasts - 40).toLong()..(lasts + 40).toLong(), "ran $ran ms, store $lasts ms")
        assertTrue(s.winded)
    }

    @Test
    fun outOfBreathTheHeroWalksUntilAQuarterIsBack() {
        val s = state()
        runEmpty(s)
        assertFalse(Stamina.step(s, 20, true, true), "walks while winded")
        // a quarter back: 10 s walking (40 s for all)
        run(s, 9_000, run = false)
        assertTrue(s.winded)
        run(s, 1_100, run = false)
        assertFalse(s.winded)
        assertTrue(Stamina.step(s, 20, true, true))
    }

    @Test
    fun standingRefillsFasterThanWalking() {
        val a = state(); val b = state()
        a.stamina = 0.0; b.stamina = 0.0
        run(a, 10_000, moving = false, run = false)
        run(b, 10_000, moving = true, run = false)
        assertEquals(0.5, a.stamina, 0.01)
        assertEquals(0.25, b.stamina, 0.01)
    }

    @Test
    fun aRestFillsTheStore() {
        val s = state()
        runEmpty(s)
        Stamina.refill(s)
        assertEquals(1.0, s.stamina)
        assertFalse(s.winded)
    }

    @Test
    fun theStoreIsSaved() {
        val s = state()
        s.stamina = 0.4; s.winded = true
        val back = GameState.fromJson(s.toJson())
        assertEquals(0.4, back.stamina, 1e-9)
        assertTrue(back.winded)
    }
}
