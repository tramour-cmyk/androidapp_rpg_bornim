package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

/** 59e.1: Thessa's wares change with the story and the level, and each stock has a piece that suits the hero. */
class ShopStockTest {
    private fun state(cls: CharClass, level: Int = 3): GameState {
        val s = GameState.newGame("X", Race.HUMAN, cls)
        s.hero.gainXp(Rules.xpForLevel[level], Story.levelCap(s))
        return s
    }

    private fun look(gear: List<Gear>) = gear.map { Triple(it.base, it.rarity, it.rolls) }

    @Test
    fun winningFightsDoesNotChangeTheStock() {
        val s = state(CharClass.FIGHTER)
        val before = look(Loot.shopGear(s))
        s.battlesWon += 16
        assertEquals(before, look(Loot.shopGear(s)))
    }

    @Test
    fun aStepOfTheStoryOrALevelBringsNewWares() {
        val s = state(CharClass.FIGHTER)
        val start = Loot.shopBatch(s)
        s.flags += Story.KROGG_DEFEATED
        assertNotEquals(start, Loot.shopBatch(s))
        val afterKrogg = Loot.shopBatch(s)
        s.hero.gainXp(Rules.xpForLevel[4], Story.levelCap(s))
        assertNotEquals(afterKrogg, Loot.shopBatch(s))
    }

    @Test
    fun aPieceSoldIsGoneOnlyUntilTheNextStock() {
        val g = Game(state(CharClass.ROGUE), Lang.DE)
        val piece = g.shopGear().last()
        g.state.gold = 100_000
        g.buyGear(piece)
        assertTrue(g.shopGear().none { it.uid == piece.uid }, "sold out")
        g.state.flags += Story.HUNTER_MET
        assertEquals(look(Loot.shopGear(g.state)), look(g.shopGear()), "the next stock is whole again")
    }

    @Test
    fun onePieceSuitsTheHerosClassAndHisWeakestSlot() {
        for (cls in CharClass.entries) for (seed in 0 until 20) {
            val s = state(cls)
            val main = Affix.valueOf(cls.primary.name)
            val g = Loot.forHero(s, Dice(Random(seed)), 3, Rarity.UNCOMMON)!!
            assertTrue(Loot.suits(cls, g.def), "$cls: ${g.base} passt nicht")
            assertTrue(g.def.slot !in s.hero.gear.keys, "$cls: ${g.def.slot} ist schon belegt, ein leerer Platz geht vor")
            if (main in GearBases.affixesFor(g.def)) assertTrue(g.rolls.any { it.affix == main }, "$cls: ${g.base} ohne $main")
        }
    }

    @Test
    fun theShopCarriesThatPiece() {
        val s = state(CharClass.WIZARD)
        val main = Affix.valueOf(CharClass.WIZARD.primary.name)
        val magic = Loot.shopGear(s).filter { it.rarity > Rarity.COMMON }
        assertEquals(5, magic.size)
        assertTrue(Loot.suits(CharClass.WIZARD, magic.first().def))
        if (main in GearBases.affixesFor(magic.first().def)) assertTrue(magic.first().rolls.any { it.affix == main })
    }
}
