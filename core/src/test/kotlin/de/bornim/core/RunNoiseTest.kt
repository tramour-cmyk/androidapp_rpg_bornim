package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 86.3/84.4: out of breath, the hero rolls initiative with disadvantage; running is loud, monsters hear him sooner. */
class RunNoiseTest {
    private fun forestGame(): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = Place("forest", 10, 20, Facing.UP)
        return g
    }

    /** Whether a wolf just beyond the notice range starts hunting at once. */
    private fun heard(running: Boolean): Boolean {
        val g = forestGame()
        val herd = g.roamers as MutableList<Roamer>
        herd.clear()
        val d = Perks.noticeRange(g.state.hero) + 1
        val wolf = Roamer(99, "wolf", 10, 20 - d, 10, 20 - d, null, false, MonsterLook()).also { herd += it }
        g.state.running = running
        g.update(100)
        return wolf.hunting
    }

    @Test
    fun runningIsHeardSooner() {
        assertFalse(heard(running = false), "heard while walking")
        assertTrue(heard(running = true), "not heard while running")
    }

    @Test
    fun staminaStepTellsWhetherTheHeroRuns() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        Stamina.step(s, 16, moving = true, run = true)
        assertTrue(s.running)
        Stamina.step(s, 16, moving = false, run = true)
        assertFalse(s.running)
        s.winded = true
        Stamina.step(s, 16, moving = true, run = true)
        assertFalse(s.running, "runs while out of breath")
    }

    /** How often the foe acts before the hero, out of 2000 fights. */
    private fun foeFirst(winded: Boolean): Int = (0 until 2000).count { seed ->
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).also { it.winded = winded }
        val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(seed)), 1, false, 1)
        b.start().any { it.text == "${b.foeName(Lang.DE)} ist schneller!" }
    }

    @Test
    fun outOfBreathTheFoeIsFasterMoreOften() {
        val fresh = foeFirst(false)
        val winded = foeFirst(true)
        assertTrue(winded > fresh * 1.2, "winded $winded, fresh $fresh")
    }
}
