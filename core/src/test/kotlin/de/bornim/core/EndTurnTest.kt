package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** "Zug beenden" (34): the hero does nothing, the foe acts at once; nothing is spent. */
class EndTurnTest {
    @Test
    fun foeActsAndNothingIsSpent() {
        val s = GameState.newGame("K", Race.HUMAN, CharClass.FIGHTER)
        s.hero.restoreFully()
        val b = Battle(s, Monsters["giant_rat"], Lang.DE, Dice(Random(5)), 1, false, 1)
        b.start()
        val foeHp = b.enemyHp
        val sp = s.hero.sp
        val bag = s.inventory.toMap()
        val text = b.act(Action.EndTurn).map { it.text }
        assertTrue(text.first().contains("wartet ab"), text.toString())
        assertTrue(text.any { "Riesenratte" in it && it != text.first() }, text.toString())
        assertEquals(foeHp, b.enemyHp)
        assertEquals(sp, s.hero.sp)
        assertEquals(bag, s.inventory.toMap())
        assertTrue(!b.defending)
    }

    /** Ending turn after turn, a plain hero loses a fight quickly (what the button is also for: losing test fights). */
    @Test
    fun endingEveryTurnLoses() {
        val s = GameState.newGame("K", Race.HUMAN, CharClass.WIZARD)
        s.hero.restoreFully()
        val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(7)), 1, false, 1)
        b.start()
        var turns = 0
        while (b.outcome == Outcome.ONGOING && turns < 200) { b.act(Action.EndTurn); turns++ }
        assertEquals(Outcome.LOST, b.outcome)
    }
}
