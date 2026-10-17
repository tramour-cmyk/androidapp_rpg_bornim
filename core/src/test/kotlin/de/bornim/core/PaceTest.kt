package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 131: walking is half as fast as before, by folk, armor and Dexterity; running is short. */
class PaceTest {
    private fun hero(race: Race = Race.HUMAN, dex: Int = 10, con: Int = 10, str: Int = 10): Hero {
        val h = GameState.newGame("T", race, CharClass.FIGHTER).hero
        h.base[Ability.DEX] = dex; h.base[Ability.CON] = con; h.base[Ability.STR] = str
        h.gear.remove(GearSlot.CHEST)
        return h
    }

    private fun mail(h: Hero) = h.apply { gear[GearSlot.CHEST] = Gear(0, "chain_mail", Rarity.COMMON, 1) }

    @Test
    fun walkingIsAboutOneAndAHalfTilesASecond() {
        assertEquals(1.5, FreeWalk.pace(hero(), run = false), 0.1)
        assertTrue(FreeWalk.pace(hero(), run = true) > 3 * FreeWalk.pace(hero(), run = false))
    }

    @Test
    fun dwarvesAndHalflingsAreSlowerAndDexterityCountsFivePercentAPoint() {
        assertEquals(25.0 / 30, FreeWalk.speed(hero(Race.DWARF)), 1e-9)
        assertEquals(25.0 / 30, FreeWalk.speed(hero(Race.HALFLING)), 1e-9)
        assertEquals(1.0, FreeWalk.speed(hero(Race.ELF)), 1e-9)
        assertEquals(1.10, FreeWalk.speed(hero(dex = 14)), 1e-9)
        assertEquals(0.95, FreeWalk.speed(hero(dex = 8)), 1e-9)
    }

    @Test
    fun heavyArmorWithoutTheStrengthSlowsAllButDwarves() {
        assertEquals(20.0 / 30, FreeWalk.speed(mail(hero())), 1e-9)
        assertEquals(1.0, FreeWalk.speed(mail(hero(str = 13))), 1e-9)
        assertEquals(25.0 / 30, FreeWalk.speed(mail(hero(Race.DWARF))), 1e-9)
    }

    @Test
    fun runningLastsSixSecondsAtConstitutionTen() {
        assertEquals(6_000.0, Stamina.lastsMs(hero()))
        assertEquals(10_000.0, Stamina.lastsMs(hero(con = 14)))
        assertEquals(4_000.0, Stamina.lastsMs(hero(con = 8)))
        assertEquals(7_000.0, Stamina.lastsMs(hero().apply { level = 3 }))
        assertEquals(3_000.0, Stamina.lastsMs(mail(hero())))
        assertEquals(12_000.0, Stamina.lastsMs(hero(), boost = true))
    }
}
