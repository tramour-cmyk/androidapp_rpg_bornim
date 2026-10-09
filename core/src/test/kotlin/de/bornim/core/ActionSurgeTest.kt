package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/** Action Surge, as the SRD has it: once per rest, not once per fight. */
class ActionSurgeTest {
    @Test
    fun actionSurgeLastsUntilTheNextRest() {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(3)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.cheatLevel(6)
        g.hero.hp = 999
        val first = Battle(g.state, Monsters["bugbear"], Lang.DE, Dice(Random(5)), 1, false, 1)
        first.start()
        assertNull(first.blocked(Skill.ACTION_SURGE))
        first.act(Action.UseSkill(Skill.ACTION_SURGE))
        assertEquals(0, first.usesLeft(Skill.ACTION_SURGE))
        // the next fight: still spent
        val second = Battle(g.state, Monsters["bugbear"], Lang.DE, Dice(Random(6)), 1, false, 1)
        second.start()
        assertNotNull(second.blocked(Skill.ACTION_SURGE))
        // after a rest it is there again
        g.hero.restoreFully()
        val third = Battle(g.state, Monsters["bugbear"], Lang.DE, Dice(Random(7)), 1, false, 1)
        third.start()
        assertEquals(1, third.usesLeft(Skill.ACTION_SURGE))
        assertNull(third.blocked(Skill.ACTION_SURGE))
    }
}
