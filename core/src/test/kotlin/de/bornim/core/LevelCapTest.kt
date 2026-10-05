package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class LevelCapTest {
    @Test
    fun chapterOneStopsAtLevelSixAndBanksTheRest() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val cap = Story.levelCap(s)
        assertEquals(6, cap)
        s.hero.gainXp(Rules.xpForLevel[9], cap)
        assertEquals(6, s.hero.level)
        assertEquals(Rules.xpForLevel[9], s.hero.xp, "the XP are kept")
        assertEquals(2, s.hero.unspentPoints)
        assertTrue(Story.capped(s))

        // From chapter 2 on the banked XP count.
        s.flags += Story.CHAPTER2_STARTED
        assertFalse(Story.capped(s))
        val g = Game(s, Lang.DE, Dice(Random(1)))
        g.begin()
        assertEquals(9, s.hero.level)
        assertEquals(4, s.hero.unspentPoints)
    }

    @Test
    fun battleSaysWhenTheCapIsReached() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.hero.gainXp(Rules.xpForLevel[6] + 100, Story.levelCap(s))
        s.hero.restoreFully()
        val b = Battle(s, Monsters["giant_rat"], Lang.DE, Dice(Random(2)), 1, false, 1)
        val steps = b.start().toMutableList()
        var n = 0
        while (b.outcome == Outcome.ONGOING && n++ < 30) steps += b.act(Action.Attack)
        assertEquals(6, s.hero.level)
        assertTrue(steps.any { "Höchststufe für Kapitel 1" in it.text })
    }
}
