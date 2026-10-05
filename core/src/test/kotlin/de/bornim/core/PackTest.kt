package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PackTest {
    @Test
    fun packSizes() {
        val wolves = (1..200).map { Packs.size("wolf", MonsterLook(it)) }.toSet()
        assertEquals(setOf(1, 2), wolves, "a wolf brings one or two young wolves")
        assertTrue((1..200).all { Packs.size("goblin", MonsterLook(it)) == 1 }, "a goblin always has a scout")
        assertTrue((1..200).all { Packs.size("dire_wolf", MonsterLook(it)) == 2 }, "Grimfang has two guards")
        assertEquals(0, Packs.size("giant_rat", MonsterLook(1)))
    }

    @Test
    fun companionsAttackAndFleeWhenTheLeaderFalls() {
        for (id in listOf("wolf", "goblin", "dire_wolf")) {
            var attacked = false
            repeat(20) { seed ->
                val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
                s.hero.gainXp(Rules.xpForLevel[6])
                s.hero.restoreFully()
                val b = Battle(s, Monsters[id], Lang.DE, Dice(Random(seed)), 2, false, 2, look = MonsterLook(seed))
                val steps = b.start().toMutableList()
                var n = 0
                while (b.outcome == Outcome.ONGOING && n++ < 40) {
                    s.hero.hp = s.hero.maxHp
                    steps += b.act(Action.Attack)
                }
                assertEquals(Outcome.WON, b.outcome, id)
                assertEquals(0, b.packLeft, "$id: companions are gone after the win")
                assertTrue(steps.any { it.anim == Anim.PACK_FLEE }, "$id: companions flee")
                if (steps.any { it.anim == Anim.PACK_ACT }) attacked = true
            }
            assertTrue(attacked, "$id: companions attack")
        }
    }
}
