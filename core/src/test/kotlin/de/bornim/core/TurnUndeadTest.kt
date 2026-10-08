package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

/** Turn Undead: the undead that fails flees; from the cleric's 5th level a weak one (CR 1/2 or lower) is destroyed. */
class TurnUndeadTest {
    private fun outcomes(level: Int, foe: String): Set<Outcome> {
        val seen = mutableSetOf<Outcome>()
        for (seed in 0 until 60) {
            val s = GameState.newGame("T", Race.HUMAN, CharClass.CLERIC)
            s.hero.gainXp(Rules.xpForLevel[level]); s.hero.restoreFully()
            val b = Battle(s, Monsters[foe], Lang.DE, Dice(Random(seed)), 1, false, 1)
            b.start()
            if (b.outcome != Outcome.ONGOING) continue
            val steps = b.act(Action.UseSkill(Skill.TURN_UNDEAD))
            val end = steps.lastOrNull { it.anim == Anim.ENEMY_FAINT } ?: continue
            if (b.outcome == Outcome.WON) assertTrue(end.fx?.kind == FxKind.DESTROY, "destroyed with the crumbling light")
            if (b.outcome == Outcome.ENEMY_FLED) assertTrue(end.fx?.kind == FxKind.TURN, "fled with the turning light")
            seen += b.outcome
        }
        return seen
    }

    @Test
    fun weakUndeadAreDestroyedFromLevelFive() {
        assertTrue(Outcome.WON in outcomes(5, "zombie"))
        assertTrue(Outcome.ENEMY_FLED !in outcomes(5, "zombie"))
        assertTrue(Outcome.ENEMY_FLED in outcomes(4, "zombie"))
        assertTrue(Outcome.WON !in outcomes(4, "skeleton"))
    }

    @Test
    fun strongerUndeadStillFlee() {
        val o = outcomes(6, "ghoul")
        assertTrue(Outcome.ENEMY_FLED in o)
        assertTrue(Outcome.WON !in o)
    }

    @Test
    fun testModeMakesEverySaveFail() {
        Battle.foesFailSaves = true
        try {
            val o = outcomes(4, "zombie")
            assertTrue(o == setOf(Outcome.ENEMY_FLED), "turned every time below level 5: $o")
            assertTrue(outcomes(5, "skeleton") == setOf(Outcome.WON), "destroyed every time from level 5")
        } finally {
            Battle.foesFailSaves = false
        }
    }
}
