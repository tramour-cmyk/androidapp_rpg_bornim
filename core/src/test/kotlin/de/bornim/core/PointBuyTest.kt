package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PointBuyTest {
    @Test
    fun costsFollowTheSrd() {
        assertEquals(0, Rules.pointCost(8))
        assertEquals(5, Rules.pointCost(13))
        assertEquals(7, Rules.pointCost(14))
        assertEquals(9, Rules.pointCost(15))
        for (cls in CharClass.entries) assertEquals(Rules.POINT_BUY, Rules.pointsSpent(Hero.suggestedScores(cls)), "$cls")
    }

    @Test
    fun boughtScoresGetTheRaceBonus() {
        val bought = mapOf(
            Ability.STR to 8, Ability.DEX to 15, Ability.CON to 14,
            Ability.INT to 15, Ability.WIS to 8, Ability.CHA to 8,
        )
        assertEquals(25, Rules.pointsSpent(bought))
        assertFalse(Hero.validPointBuy(bought), "one point over budget")
        val ok = bought + (Ability.DEX to 13) // 25 - 9 + 5 = 21
        assertTrue(Hero.validPointBuy(ok))
        val h = Hero.create("X", Race.ELF, CharClass.WIZARD, ok)
        assertEquals(15, h.base[Ability.DEX]) // 13 + elf 2
        assertEquals(15 + (Race.ELF.bonus[Ability.INT] ?: 0), h.base[Ability.INT])
        assertEquals(0, h.spentPoints)
        // Invalid scores fall back to the class suggestion.
        val bad = Hero.create("X", Race.HUMAN, CharClass.WIZARD, bought + (Ability.INT to 17))
        assertEquals(16, bad.base[Ability.INT])
    }

    @Test
    fun oldSavesGetTheirPointsRecalculated() {
        // A level 6 hero of the old rules: standard array and five points spent.
        val s = GameState.newGame("Alt", Race.HUMAN, CharClass.WIZARD)
        val h = s.hero
        h.start.clear()
        Hero.startingScores(h.race, h.cls).forEach { (a, v) -> h.base[a] = v }
        h.level = 6
        h.xp = Rules.xpForLevel[6]
        h.base[Ability.INT] = h.base.getValue(Ability.INT) + 4
        h.base[Ability.CON] = h.base.getValue(Ability.CON) + 1
        s.version = 2
        val loaded = GameState.fromJson(s.toJson())
        val lh = loaded.hero
        assertEquals(2, lh.spentPoints + lh.unspentPoints)
        // Points are taken back from the most raised ability first: INT keeps +1, CON keeps +1.
        val old = Hero.startingScores(lh.race, lh.cls)
        assertEquals(old.getValue(Ability.INT) + 1, lh.base[Ability.INT])
        assertEquals(old.getValue(Ability.CON) + 1, lh.base[Ability.CON])
        assertTrue(GameState.POINTS_REFIT in loaded.flags)
        val g = Game(loaded, Lang.DE)
        g.begin()
        assertTrue(g.mode is Mode.Dialog)
        assertFalse(GameState.POINTS_REFIT in loaded.flags)
    }
}
