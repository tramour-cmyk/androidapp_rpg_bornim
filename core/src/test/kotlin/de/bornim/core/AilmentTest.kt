package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class AilmentTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(3)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.cheatLevel(6)
        return g
    }

    private fun walk(g: Game, steps: Int) = repeat(steps) {
        g.state.steps++
        g.afterStep()
    }

    @Test
    fun poisonTicksOnTheMapButNeverKills() {
        val g = game()
        g.hero.hp = 3
        g.state.ailments[Status.POISON.name] = 10
        walk(g, 4 * 10)
        assertEquals(1, g.hero.hp)
        assertFalse(Status.POISON.name in g.state.ailments, "poison wears off")
        assertTrue(g.notices.isNotEmpty())
    }

    @Test
    fun poisonHurtsEveryFewSteps() {
        val g = game()
        val full = g.hero.maxHp
        g.state.ailments[Status.BLEED.name] = 3
        walk(g, Game.AILMENT_STEPS - 1)
        assertEquals(full, g.hero.hp)
        walk(g, 1)
        assertTrue(g.hero.hp < full)
        assertEquals(2, g.state.ailment(Status.BLEED))
    }

    @Test
    fun curseStaysUntilCured() {
        val g = game()
        g.state.ailments[Status.WEAK.name] = Status.LASTING
        walk(g, 100)
        assertEquals(Status.LASTING, g.state.ailment(Status.WEAK))
        // It goes into the next fight and does not wear off there.
        val b = Battle(g.state, Monsters["giant_rat"], Lang.DE, Dice(Random(5)), 1, false, 1)
        b.start()
        g.hero.hp = 999
        repeat(2) { if (b.outcome == Outcome.ONGOING) b.act(Action.Attack) }
        assertEquals(Status.LASTING, b.heroStatus[Status.WEAK])
        // A remedy cures it outside of battle, even with full HP.
        g.hero.restoreFully()
        g.state.add("remedy")
        g.useItemOutside("remedy")
        assertTrue(g.state.ailments.isEmpty())
    }

    @Test
    fun restCuresEverything() {
        val g = game()
        g.state.ailments[Status.WEAK.name] = Status.LASTING
        g.state.ailments[Status.POISON.name] = 5
        g.hero.hp = 5
        g.enqueue(listOf(Cmd.Rest))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 20) g.advance()
        assertEquals(g.hero.maxHp, g.hero.hp)
        assertTrue(g.state.ailments.isEmpty())
    }

    @Test
    fun poisonOutlastsTheFight() {
        val g = game()
        val b = Battle(g.state, Monsters["giant_rat"], Lang.DE, Dice(Random(9)), 1, false, 1)
        b.start()
        b.heroStatus[Status.POISON] = 40
        b.heroStatus[Status.STUN] = 1
        g.fight(b)
        var n = 0
        while (b.outcome == Outcome.ONGOING && n++ < 30) b.act(Action.Attack)
        assertEquals(Outcome.WON, b.outcome)
        g.endBattle()
        assertTrue(g.state.ailment(Status.POISON) > 0)
        assertFalse(Status.STUN.name in g.state.ailments)
    }
}
