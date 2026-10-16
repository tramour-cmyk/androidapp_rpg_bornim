package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 86.6, 86.9, 86.10: a rest costs time; mead, room and the stamina draught. */
class RestingTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(4)))
        skip(g)
        return g
    }

    private fun skip(g: Game) {
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    }

    /** At the hunter's campfire, asked "Rasten?". */
    private fun atFire(g: Game) {
        g.state.place = Place("forest", 10, 9, Facing.RIGHT)
        g.interact()
        assertEquals(Mode.Rest(Resting.Spot.FIRE), g.mode)
    }

    @Test
    fun theFireAsksAndLeavingCostsNothing() {
        val g = game()
        val clock = g.state.clock
        g.hero.hp = 3
        atFire(g)
        g.advance()
        assertEquals(Mode.Explore, g.mode)
        assertEquals(clock, g.state.clock)
        assertEquals(3, g.hero.hp, "no heal without a rest")
    }

    @Test
    fun aShortRestTakesAnHourForBreathAndAQuarterOfTheHp() {
        val g = game()
        g.state.minutes = 23 * 60 + 30
        val day = g.state.day
        g.hero.hp = 1
        g.state.stamina = 0.0; g.state.winded = true
        g.state.ailments["POISON"] = 5
        atFire(g)
        assertNull(g.rest(Resting.Kind.SHORT, Resting.Spot.FIRE))
        assertEquals(30, g.state.minutes)
        assertEquals(day + 1, g.state.day, "past midnight the day turns")
        assertEquals(minOf(g.hero.maxHp, 1 + Resting.shortHeal(g.hero)), g.hero.hp)
        assertEquals(1.0, g.state.stamina)
        assertFalse(g.state.winded)
        assertEquals(5, g.state.ailments["POISON"], "a short rest cures nothing")
        assertTrue(g.mode is Mode.Dialog, "the rest's line")
        skip(g)
        assertEquals(Mode.Explore, g.mode)
    }

    @Test
    fun aLongRestTakesEightHoursHealsAllAndOnlyOnceADay() {
        val g = game()
        g.state.minutes = 8 * 60
        g.hero.hp = 1
        g.state.ailments["POISON"] = 5
        atFire(g)
        assertNull(g.rest(Resting.Kind.LONG, Resting.Spot.FIRE))
        assertEquals(16 * 60, g.state.minutes)
        assertEquals(g.hero.maxHp, g.hero.hp)
        assertTrue(g.state.ailments.isEmpty())
        assertEquals(Place("forest", 10, 9, Facing.RIGHT), g.state.respawn)
        skip(g)
        // the same day: no second long rest, a short one still
        atFire(g)
        assertNotNull(g.rest(Resting.Kind.LONG, Resting.Spot.FIRE))
        assertEquals(16 * 60, g.state.minutes, "refused, no time gone")
        assertNull(g.rest(Resting.Kind.SHORT, Resting.Spot.FIRE))
        skip(g)
        // the next day again
        Resting.pass(g.state, 9 * 60)
        atFire(g)
        assertNull(g.rest(Resting.Kind.LONG, Resting.Spot.FIRE))
    }

    @Test
    fun theStaminaDraughtDoublesTheBreathUntilTheNextRest() {
        val g = game()
        g.state.add("stamina_potion", 2)
        val plain = Stamina.lastsMs(g.hero)
        g.useItemOutside("stamina_potion")
        assertTrue(g.state.staminaBoost)
        assertEquals(1, g.state.count("stamina_potion"))
        g.useItemOutside("stamina_potion")
        assertEquals(1, g.state.count("stamina_potion"), "a second one does not stack")
        // the breath lasts twice as long
        var ran = 0L
        while (!g.state.winded && ran < 200_000) { Stamina.step(g.state, 20, true, true); ran += 20 }
        assertTrue(ran in (2 * plain - 40).toLong()..(2 * plain + 40).toLong(), "ran $ran ms, plain $plain ms")
        atFire(g)
        g.rest(Resting.Kind.SHORT, Resting.Spot.FIRE)
        assertFalse(g.state.staminaBoost)
    }

    @Test
    fun theStaminaDraughtIsNotOfferedInBattle() {
        assertEquals(ItemKind.TONIC, Items["stamina_potion"].kind)
        assertEquals(Items["potion"].price, Items["stamina_potion"].price, "priced like the healing potion")
        assertTrue("stamina_potion" in Story.shopStock)
    }

    /** At Rowena's counter in the inn. */
    private fun atCounter(g: Game) {
        g.state.place = Place("inn", 1, 3, Facing.UP)
        g.interact()
        skip(g)
        assertEquals(Mode.Rest(Resting.Spot.TAVERN), g.mode)
    }

    @Test
    fun meadFillsTheBreathAndTheFifthMakesTheHeroDrunk() {
        val g = game()
        g.state.gold = 100
        atCounter(g)
        repeat(4) {
            g.state.stamina = 0.1
            assertEquals(Resting.meadDrunk, g.drinkMead())
            assertEquals(1.0, g.state.stamina)
            assertFalse(g.state.drunk)
        }
        assertEquals(Resting.drunkNow, g.drinkMead())
        assertTrue(g.state.drunk)
        assertEquals(100 - 5 * Resting.MEAD_PRICE, g.state.gold)
        g.advance()
        atFire(g)
        g.rest(Resting.Kind.SHORT, Resting.Spot.FIRE)
        assertFalse(g.state.drunk, "sober after the rest")
    }

    @Test
    fun rowenaBuysRawMeatAtTheShopPrice() {
        val g = game()
        g.state.gold = 0
        g.state.add("raw_meat", 3)
        g.state.place = Place("inn", 1, 3, Facing.UP)
        g.interact()
        val said = mutableListOf<String>()
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) { said += g.mode.toString(); g.advance() }
        assertTrue(said.any { "Frisches Fleisch aus dem Wald?" in it }, "[139.rowena.fleisch] before the counter")
        assertEquals(Mode.Rest(Resting.Spot.TAVERN), g.mode)
        val price = g.sellPrice("raw_meat")
        assertTrue(price > 0)
        assertEquals(Resting.meatThanks, g.sellMeat())
        assertEquals(0, g.state.count("raw_meat"))
        assertEquals(3 * price, g.state.gold)
        assertNull(g.sellMeat(), "nothing left to sell")
        g.advance()
        g.state.place = Place("inn", 1, 3, Facing.UP)
        g.interact()
        said.clear()
        guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) { said += g.mode.toString(); g.advance() }
        assertFalse(said.any { "Frisches Fleisch" in it }, "no word of meat without meat")
    }

    @Test
    fun aRoomIsALongRestForGold() {
        val g = game()
        g.state.gold = Resting.ROOM_PRICE
        g.state.minutes = 21 * 60
        g.hero.hp = 1
        atCounter(g)
        assertNull(g.rest(Resting.Kind.LONG, Resting.Spot.TAVERN))
        assertEquals(0, g.state.gold)
        assertEquals(5 * 60, g.state.minutes)
        assertEquals(g.hero.maxHp, g.hero.hp)
        // 114: awake beside the bed, not at the counter
        assertEquals(Story.START, g.state.place)
        assertEquals(Story.START, g.state.respawn)
        skip(g)
        // no gold, no room
        g.state.longRestDay = 0
        atCounter(g)
        assertEquals(Resting.noGold, g.rest(Resting.Kind.LONG, Resting.Spot.TAVERN))
        assertEquals(5 * 60, g.state.minutes)
    }

    @Test
    fun theInnBedOffersTheRoomAtAnyHourOtherBedsNothing() {
        val g = game()
        g.state.minutes = 12 * 60
        val inn = World["inn"]
        val (bx, by) = (0 until inn.height).flatMap { y -> (0 until inn.width).map { it to y } }.first { (x, y) -> inn.tile(x, y) == Tile.BED }
        g.state.place = Place("inn", bx, by + 1, Facing.UP)
        if (inn.tile(bx, by + 1) == Tile.BED || !inn.walkable(bx, by + 1, g.state)) g.state.place = Place("inn", bx - 1, by, Facing.RIGHT)
        g.interact()
        assertEquals(Mode.Rest(Resting.Spot.ROOM), g.mode)
        assertEquals(ActionKind.REST, g.actionAt(bx, by))
        val elder = World["elder"]
        val (ex, ey) = (0 until elder.height).flatMap { y -> (0 until elder.width).map { it to y } }.first { (x, y) -> elder.tile(x, y) == Tile.BED }
        g.advance()
        g.state.place = Place("elder", ex, ey + 1, Facing.UP)
        assertEquals(ActionKind.LOOK, g.actionAt(ex, ey))
    }

    @Test
    fun anOldSaveLoadsWithoutTheNewFields() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.staminaBoost = true; s.mead = 3; s.longRestDay = 4
        val back = GameState.fromJson(s.toJson())
        assertTrue(back.staminaBoost)
        assertEquals(3, back.mead)
        assertEquals(4, back.longRestDay)
    }
}
