package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ChapterLootTest {
    private fun state(level: Int): GameState {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        s.hero.gainXp(Rules.xpForLevel[level], Story.levelCap(s))
        return s
    }

    @Test
    fun chapterOneLootStaysModest() {
        val dice = Dice(Random(3))
        val beginner = state(1)
        repeat(500) { assertEquals(Rarity.COMMON, Loot.rarityFor(beginner, dice, 1, special = false)) }

        val s = state(6)
        val normal = List(3000) { Loot.rarityFor(s, dice, 5, special = false) }
        assertTrue(normal.all { it <= Rarity.UNCOMMON })
        val share = normal.count { it == Rarity.UNCOMMON } / 3000.0
        assertTrue(share in 0.1..0.2, "uncommon share $share")

        val drops = List(300) { Loot.drops(s, dice, 5, boss = true, elite = false) }.flatten() +
            List(300) { Loot.drops(s, dice, 5, boss = false, elite = true) }.flatten()
        assertTrue(drops.all { it.rarity <= Rarity.RARE }, "${drops.map { it.rarity }.toSet()}")
        assertTrue(drops.any { it.rarity == Rarity.RARE })
        assertTrue(Loot.shopGear(s).all { it.rarity <= Rarity.UNCOMMON })
    }

    @Test
    fun laterChaptersUnlockBetterLoot() {
        val s = state(6)
        s.flags += Story.CHAPTER2_STARTED
        val dice = Dice(Random(5))
        val rarities = List(3000) { Loot.rarityFor(s, dice, 8, special = true, floor = Rarity.UNCOMMON) }.toSet()
        assertTrue(Rarity.VERY_RARE in rarities)
        assertTrue(rarities.all { it <= Rarity.VERY_RARE })
    }

    @Test
    fun storyItemsOfOldSavesAreToneDown() {
        val s = GameState.newGame("Alt", Race.HUMAN, CharClass.FIGHTER)
        val strong = Gear(77, "greataxe", Rarity.EPIC, 5, 1, listOf(Roll(Affix.STR, 2), Roll(Affix.DAMAGE, 3)), 0, "greataxe_grak")
        s.bag += strong
        s.version = 2
        val loaded = GameState.fromJson(s.toJson())
        val axe = loaded.bag.single { it.unique == "greataxe_grak" }
        assertEquals(Rarity.RARE, axe.rarity)
        assertEquals(77, axe.uid)
        assertEquals(1, axe.total(Affix.STR))
    }
}
