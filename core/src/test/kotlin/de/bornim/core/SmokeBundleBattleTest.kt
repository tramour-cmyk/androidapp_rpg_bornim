package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** D4.1: Morwen's smoke bundle takes Krogg's first blow: thrown by itself as he shows up, his first attack goes astray. */
class SmokeBundleBattleTest {
    private fun state(smoke: Boolean): GameState {
        val s = GameState.newGame("K", Race.HUMAN, CharClass.FIGHTER)
        s.hero.restoreFully()
        if (smoke) s.add(Story.SMOKE_BUNDLE, 1)
        return s
    }

    private fun fight(seed: Int, smoke: Boolean, opening: Opening = Opening.NORMAL): Pair<Battle, List<Step>> {
        val s = state(smoke)
        val b = Battle(s, Monsters["bugbear"], Lang.DE, Dice(Random(seed)), 1, false, 1, opening = opening)
        val steps = b.start().toMutableList()
        // the hero only defends, so every blow that lands is Krogg's own
        while (b.outcome == Outcome.ONGOING && steps.count { it.anim == Anim.ENEMY_ACT } < 3) steps += b.act(Action.Defend)
        return b to steps
    }

    @Test
    fun `thrown at the start, used up, first blow goes astray`() {
        for (opening in Opening.entries) for (seed in 1..60) {
            val (b, steps) = fight(seed, smoke = true, opening)
            assertTrue(b.smokeThrown)
            assertEquals(0, b.state.count(Story.SMOKE_BUNDLE))
            val throwAt = steps.indexOfFirst { it.anim == Anim.THROW && it.fx?.kind == FxKind.SMOKE }
            // an ambush is named with the foe's move first; his blow follows the throw
            assertTrue(throwAt >= 0 && steps[throwAt].heroHp == b.hero.maxHp, "$opening $seed: thrown before his first blow")
            val firstBlow = (throwAt until steps.size).first { steps[it].anim == Anim.ENEMY_ACT }
            assertEquals(Anim.MISS, steps[firstBlow + 1].anim, "$opening $seed: first blow goes astray")
            assertFalse(steps.any { "brutal" in it.text.lowercase() || "wuchtig" in it.text.lowercase() }, "no brutal first hit later")
            assertFalse(Status.STUN in steps.last().heroStatus, "no stun from the first hit")
        }
    }

    @Test
    fun `without the bundle nothing changes`() {
        val (b, steps) = fight(3, smoke = false)
        assertFalse(b.smokeThrown)
        assertFalse(steps.any { it.fx?.kind == FxKind.SMOKE })
    }

    @Test
    fun `only against Krogg`() {
        val s = state(smoke = true)
        val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(1)), 1, false, 1)
        b.start()
        assertFalse(b.smokeThrown)
        assertEquals(1, s.count(Story.SMOKE_BUNDLE))
    }
}
