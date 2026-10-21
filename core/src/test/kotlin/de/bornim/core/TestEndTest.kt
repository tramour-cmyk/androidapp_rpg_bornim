package de.bornim.core

import de.bornim.core.Skirmish.Companion.ProbeFoe
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/** 272: the test switches end a fight at once, through its usual end. */
class TestEndTest {
    private fun battle(seed: Int): Battle {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        return Battle(s, Monsters["wolf"], Lang.DE, Dice(Random(seed)), 1, false, 1).also { it.start() }
    }

    private fun skirmish(seed: Int) =
        Skirmish.probe(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), CharClass.FIGHTER, Lang.DE, ProbeFoe.WOLVES, Dice(Random(seed)))
            .also { it.start() }

    @Test
    fun aWonFightBringsItsSpoils() {
        val b = battle(1)
        val xp = b.hero.xp
        val steps = b.testEnd(win = true)
        assertEquals(Outcome.WON, b.outcome)
        assertEquals(Anim.ENEMY_FAINT, steps.first().anim)
        assertEquals(0, b.enemyHp)
        assertNotNull(b.rewards)
        assertTrue(b.hero.xp > xp)
    }

    @Test
    fun aLostFightFellsTheHero() {
        val b = battle(2)
        val steps = b.testEnd(win = false)
        assertEquals(Outcome.LOST, b.outcome)
        assertEquals(0, b.hero.hp)
        assertTrue(steps.any { it.anim == Anim.HERO_FAINT })
    }

    @Test
    fun marsFellsEveryFoeOrTheHero() {
        val won = skirmish(3)
        val foes = won.fighters.count { it.side == Side.FOES && it.standing }
        val events = won.testEnd(win = true)
        assertEquals(Outcome.WON, won.outcome)
        assertTrue(won.fighters.none { it.side == Side.FOES && it.standing })
        assertEquals(foes, events.count { it.cue == SkirmishCue.FOE_FALLS })
        val lost = skirmish(4)
        lost.testEnd(win = false)
        assertEquals(Outcome.LOST, lost.outcome)
        assertEquals(0, lost.fighters.first().hp)
    }
}
