package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 354: a hard blow (Grak's gap in the guard, the boar's charge, Krogg's brutal first blow) is warned of before the player chooses. */
class HardBlowWarningTest {
    private fun isWarning(s: Step) = s.text.startsWith("[354.1")

    /** Each flush of a fight against [id], the hero attacking and defending in turn. */
    private fun fight(id: String, seed: Int, opening: Opening): List<List<Step>> {
        val s = GameState.newGame("K", Race.HUMAN, CharClass.FIGHTER)
        s.hero.restoreFully()
        val b = Battle(s, Monsters[id], Lang.DE, Dice(Random(seed)), 4, false, 3, opening = opening)
        val turns = mutableListOf(b.start())
        var n = 0
        while (b.outcome == Outcome.ONGOING && n < 12) turns += b.act(if (n++ % 2 == 0) Action.Defend else Action.Attack)
        return turns
    }

    @Test
    fun `every warned blow comes, every hard blow the player could see coming is warned`() {
        var warned = 0
        for (id in listOf("hobgoblin_captain", "bugbear", "boar")) for (opening in Opening.entries) for (seed in 1..40) {
            val turns = fight(id, seed, opening)
            for ((i, t) in turns.withIndex()) {
                val warns = t.count(::isWarning)
                assertTrue(warns <= 1, "$id $opening $seed: one warning at most")
                if (warns == 1) {
                    warned++
                    assertTrue(isWarning(t.last()), "$id $opening $seed: the warning is the last line before the choice")
                    val next = turns.getOrNull(i + 1) ?: continue
                    // the blow follows, unless the foe falls or flees first, or drinks a potion instead
                    val drinks = next.any { it.anim == Anim.ENEMY_HEAL }
                    val gone = next.any { it.anim == Anim.ENEMY_FAINT } || next.last().let { it.enemyHp <= 0 }
                    if (!drinks && !gone && next.any { it.anim == Anim.ENEMY_ACT })
                        assertTrue(next.first { it.anim == Anim.ENEMY_ACT }.heavy, "$id $opening $seed turn $i: the warned blow is the hard one")
                }
                // a hard blow after the player's own choice was warned of in the turn before
                if (i > 0 && t.any { it.heavy }) assertEquals(1, turns[i - 1].count(::isWarning), "$id $opening $seed turn $i: hard blow without warning")
            }
        }
        assertTrue(warned > 100, "warnings seen: $warned")
    }

    @Test
    fun `no warning against a foe without hard blows`() {
        for (seed in 1..20) assertTrue(fight("goblin", seed, Opening.NORMAL).flatten().none(::isWarning))
    }
}
