package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class CheatTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.WIZARD), Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        return g
    }

    @Test
    fun levelUpAndDown() {
        val g = game()
        g.cheatLevel(8)
        assertEquals(8, g.hero.level)
        assertEquals(4, g.hero.unspentPoints) // two each at levels 4 and 8
        assertEquals(g.hero.maxHp, g.hero.hp)
        g.cheatLevel(5)
        assertEquals(5, g.hero.level)
        assertEquals(2, g.hero.unspentPoints)
        assertEquals(Rules.xpForLevel[5], g.hero.xp)
        g.cheatLevel(99)
        assertEquals(Rules.MAX_LEVEL, g.hero.level)
    }

    @Test
    fun levelDownTakesBackSpentPoints() {
        val g = game()
        val start = g.hero.startScores
        g.cheatLevel(12)
        assertTrue(g.hero.applyPoints(mapOf(Ability.INT to 2, Ability.CON to 2, Ability.DEX to 1)))
        assertEquals(1, g.hero.unspentPoints)
        g.cheatLevel(4)
        assertEquals(2, g.hero.spentPoints)
        assertEquals(0, g.hero.unspentPoints)
        assertTrue(Ability.entries.all { g.hero.base.getValue(it) >= start.getValue(it) })
        g.cheatLevel(1)
        assertEquals(start, g.hero.base.toMap())
        assertEquals(0, g.hero.unspentPoints)
        assertEquals(69 + 6, g.hero.base.values.sum()) // 24-point suggestion, human: +1 to all six
    }

    @Test
    fun fightsAndBosses() {
        val g = game()
        g.state.flags += Story.KROGG_DEFEATED
        g.state.flags += Story.GRAK_DEFEATED
        g.cheatRespawnBosses()
        assertFalse(g.state.has(Story.KROGG_DEFEATED))
        assertFalse(g.state.has(Story.GRAK_DEFEATED))
        g.cheatFight("ghoul", EliteTrait.BURNING, false)
        val b = (g.mode as Mode.Fight).battle
        assertEquals(EliteTrait.BURNING, b.trait)
        assertTrue(b.elite)
        g.endBattle()
        g.cheatFight("kobold", null, true)
        assertTrue((g.mode as Mode.Fight).battle.shiny)
    }

    @Test
    fun loot() {
        val g = game()
        val item = g.cheatLoot(Rarity.DIVINE)
        assertEquals(Rarity.DIVINE, item.rarity)
        assertTrue(g.state.bag.any { it.uid == item.uid })
    }
}
