package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PerksTest {
    private fun hero(a: Ability, score: Int): GameState {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        s.hero.base[a] = score
        return s
    }

    @Test
    fun charismaChangesPrices() {
        val g = Game(hero(Ability.CHA, 16), Lang.DE, Dice(Random(1))) // +3
        assertEquals(85, Perks.buyPrice(g.hero, 100))
        assertEquals(115, Perks.sellPrice(g.hero, 100))
        assertEquals(Perks.buyPrice(g.hero, Items["potion"].price), g.buyPrice("potion"))
        val poor = Game(hero(Ability.CHA, 8), Lang.DE) // −1
        assertEquals(105, Perks.buyPrice(poor.hero, 100))
        // Never more than 20 %.
        assertEquals(80, Perks.buyPrice(hero(Ability.CHA, 30).hero, 100))
    }

    @Test
    fun intelligenceRevealsWeaknesses() {
        val s = hero(Ability.INT, 14)
        val steps = Battle(s, Monsters["skeleton"], Lang.DE, Dice(Random(1))).start()
        assertTrue(steps.any { "erkennt" in it.text && "verwundbar" in it.text }, steps.joinToString { it.text })
        val dull = hero(Ability.INT, 10)
        assertTrue(Battle(dull, Monsters["skeleton"], Lang.DE, Dice(Random(1))).start().none { "erkennt" in it.text })
    }

    @Test
    fun smallEffectsGrowWithTheModifier() {
        assertEquals(4, Perks.noticeRange(hero(Ability.DEX, 12).hero))
        assertEquals(3, Perks.noticeRange(hero(Ability.DEX, 14).hero))
        assertEquals(2, Perks.noticeRange(hero(Ability.DEX, 20).hero))
        assertEquals(1.0, Perks.sightBonus(hero(Ability.WIS, 14).hero))
        assertEquals(0.4, Perks.ambushFactor(hero(Ability.WIS, 30).hero))
        assertEquals(3, Perks.throwBonus(hero(Ability.STR, 16).hero))
        assertEquals(0, Perks.throwBonus(hero(Ability.STR, 8).hero))
        assertEquals(1.06, Perks.xpFactor(hero(Ability.INT, 14).hero), 1e-9)
    }

    @Test
    fun everyAbilityIsExplained() {
        val h = GameState.newGame("X", Race.HUMAN, CharClass.CLERIC).hero
        for (lang in Lang.entries) for (a in Ability.entries) {
            val lines = Perks.describe(a, h, lang)
            assertTrue(lines.size >= 3, "$a $lang: $lines")
        }
    }
}
