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
    fun fightWithKitOpeningAndWeapons() {
        val g = game()
        for (k in 0 until 3) {
            g.cheatFight("skeleton", null, false, Opening.AMBUSHED, k)
            val b = (g.mode as Mode.Fight).battle
            assertEquals(Opening.AMBUSHED, b.opening)
            assertEquals(MonsterKits.of("skeleton", k), MonsterKits.of("skeleton", b.look.seed))
            g.endBattle()
        }
        // whatever the opening, the hero never moves on its own before the player has chosen
        for (o in Opening.entries) {
            g.cheatFight("goblin", null, false, o)
            val steps = (g.mode as Mode.Fight).battle.start()
            assertTrue(steps.none { it.anim == Anim.HERO_ACT || it.anim == Anim.SPELL || it.anim == Anim.THROW || it.anim == Anim.DEFEND }, "$o")
            g.endBattle()
        }
        g.cheatWeapon("greatsword")
        assertEquals("greatsword", g.hero.item(GearSlot.MAIN_HAND)?.base)
        g.cheatOffHand("round_shield")
        assertEquals("round_shield", g.hero.item(GearSlot.OFF_HAND)?.base)
        // a shield on the arm leaves no hand for a two-handed sword
        assertEquals(null, g.hero.item(GearSlot.MAIN_HAND))
        g.cheatWeapon("spear")
        g.cheatOffHand(null)
        assertEquals("spear", g.hero.item(GearSlot.MAIN_HAND)?.base)
        assertEquals(null, g.hero.item(GearSlot.OFF_HAND))
    }

    @Test
    fun loot() {
        val g = game()
        val item = g.cheatLoot(Rarity.DIVINE)
        assertEquals(Rarity.DIVINE, item.rarity)
        assertTrue(g.state.bag.any { it.uid == item.uid })
    }

    @Test
    fun suppliesFilledToTen() {
        val g = game()
        g.state.add("potion", 14)
        g.cheatSupplies(10)
        for (d in Items.all.filter { it.kind != ItemKind.KEY }) kotlin.test.assertTrue(g.state.count(d.id) >= 10, d.id)
        kotlin.test.assertTrue(g.state.count("potion") >= 14, "more than ten stays")
        for (d in Items.all.filter { it.kind == ItemKind.KEY }) assertEquals(0, g.state.count(d.id), "no keys")
    }
}
