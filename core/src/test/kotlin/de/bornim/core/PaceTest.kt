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
    fun walkingIsAboutOnePointEightTilesASecond() {
        assertEquals(1.8, FreeWalk.pace(hero(), run = false), 0.1)
        // 220: running twice as fast as walking (2.6 times looked too fast against walking)
        assertEquals(2.0, FreeWalk.pace(hero(), run = true) / FreeWalk.pace(hero(), run = false), 0.01)
    }

    /** 131.1: walking and running blend into each other over a moment, no jump. */
    @Test
    fun paceEasesBetweenWalkingAndRunning() {
        var p = FreeWalk.WALK
        var ms = 0
        while (p < FreeWalk.RUN) { p = FreeWalk.ease(p, FreeWalk.RUN, 16); ms += 16 }
        assertTrue(ms in 500..700, "zum Rennen $ms ms")
        ms = 0
        while (p > FreeWalk.WALK) { p = FreeWalk.ease(p, FreeWalk.WALK, 16); ms += 16 }
        assertTrue(ms in 300..500, "zum Gehen $ms ms")
        assertEquals(FreeWalk.WALK, FreeWalk.ease(0.0, FreeWalk.RUN, 16), 1e-9)
        assertEquals(0.0, FreeWalk.ease(FreeWalk.RUN, 0.0, 16), 1e-9)
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
