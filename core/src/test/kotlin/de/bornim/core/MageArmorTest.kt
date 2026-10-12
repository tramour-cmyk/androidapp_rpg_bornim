package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/** Mage Armor holds 8 hours of game time (26.1): cast once, it guards the fights that follow from their first round. */
class MageArmorTest {
    private fun wizard(): GameState {
        val s = GameState.newGame("M", Race.HUMAN, CharClass.WIZARD)
        s.hero.restoreFully()
        return s
    }

    private fun battle(s: GameState) = Battle(s, Monsters["giant_rat"], Lang.DE, Dice(Random(3)), 1, false, 1)

    @Test
    fun castOnceItHoldsInTheNextFight() {
        val s = wizard()
        val bare = s.hero.armorClass
        val first = battle(s)
        first.start()
        assertFalse(first.mageArmor)
        first.act(Action.UseSkill(Skill.MAGE_ARMOR))
        assertTrue(first.mageArmor)
        assertEquals(s.clock + Battle.MAGE_ARMOR_MINUTES, s.mageArmorUntil)

        val next = battle(s)
        assertTrue(next.mageArmor)
        assertTrue(next.heroAc > bare - 1)
        assertEquals(s.hero.armorClass(mageArmor = true), next.heroAc)
        assertTrue(next.start().any { "Magierrüstung" in it.text && "hält noch" in it.text })
        // already up: casting again does nothing and costs nothing
        assertNotNull(next.blocked(Skill.MAGE_ARMOR))
    }

    @Test
    fun goneAfterEightHours() {
        val s = wizard()
        s.mageArmorUntil = s.clock + Battle.MAGE_ARMOR_MINUTES
        s.minutes += 7 * 60 + 59
        assertTrue(s.mageArmorOn)
        s.minutes += 1
        assertFalse(s.mageArmorOn)
        assertFalse(battle(s).mageArmor)
    }

    @Test
    fun holdsOverMidnight() {
        val s = wizard()
        s.minutes = 22 * 60
        s.mageArmorUntil = s.clock + Battle.MAGE_ARMOR_MINUTES
        s.day++; s.minutes = 5 * 60
        assertTrue(s.mageArmorOn)
        s.minutes = 6 * 60
        assertFalse(s.mageArmorOn)
    }
}
