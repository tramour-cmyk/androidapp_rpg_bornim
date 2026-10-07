package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals

class ClericKitTest {
    /** A save as it was before version 5: the cleric's mace and shield, one plain and in the bag, one bettered. */
    private fun oldSave(cls: CharClass, offHand: Gear, bagged: List<Gear>): String {
        val s = GameState.newGame("Alt", Race.HUMAN, cls)
        s.hero.equip(Gear(101, "mace", Rarity.COMMON, 1))
        s.hero.equip(offHand)
        s.bag.clear(); s.bag += bagged
        s.version = 4
        return s.toJson()
    }

    @Test
    fun newClericsStartWithStaffAndRoundShield() {
        val h = GameState.newGame("Neu", Race.ELF, CharClass.CLERIC).hero
        assertEquals("quarterstaff", h.weapon?.base)
        assertEquals("round_shield", h.item(GearSlot.OFF_HAND)?.base)
    }

    @Test
    fun plainStartingKitIsSwappedInOldSaves() {
        val s = GameState.fromJson(oldSave(CharClass.CLERIC, Gear(102, "shield", Rarity.COMMON, 1),
            listOf(Gear(103, "shield", Rarity.COMMON, 1), Gear(104, "mace", Rarity.UNCOMMON, 2, plus = 1))))
        assertEquals("quarterstaff", s.hero.weapon?.base)
        assertEquals(101L, s.hero.weapon?.uid)
        assertEquals("round_shield", s.hero.item(GearSlot.OFF_HAND)?.base)
        // the plain shield in the bag is swapped too; the bettered mace stays a mace
        assertEquals(listOf("round_shield", "mace"), s.bag.map { it.base })
        assertEquals(GameState.SAVE_VERSION, s.version)
    }

    @Test
    fun betteredShieldAndOtherClassesStay() {
        val cleric = GameState.fromJson(oldSave(CharClass.CLERIC, Gear(102, "shield", Rarity.COMMON, 1, plus = 1), emptyList()))
        assertEquals("shield", cleric.hero.item(GearSlot.OFF_HAND)?.base)
        val fighter = GameState.fromJson(oldSave(CharClass.FIGHTER, Gear(102, "shield", Rarity.COMMON, 1), emptyList()))
        assertEquals("mace", fighter.hero.weapon?.base)
        assertEquals("shield", fighter.hero.item(GearSlot.OFF_HAND)?.base)
    }
}
