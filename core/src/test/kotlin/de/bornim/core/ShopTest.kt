package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 59: buying and selling several supplies at once, buying back the last five sales until the shop closes. */
class ShopTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(1)))
        g.state.gold = 1000
        g.enqueue(listOf(Cmd.OpenShop(Story.shopStock)))
        return g
    }

    @Test
    fun buysAndSellsMany() {
        val g = game()
        val before = g.state.count("potion")
        val price = g.buyPrice("potion")
        g.buy("potion", 5)
        assertEquals(before + 5, g.state.count("potion"))
        assertEquals(1000 - 5 * price, g.state.gold)
        val gold = g.state.gold
        g.sell("potion", 3)
        assertEquals(before + 2, g.state.count("potion"))
        assertEquals(gold + 3 * g.sellPrice("potion"), g.state.gold)
        // more than in hand: nothing happens
        g.sell("potion", 99)
        assertEquals(before + 2, g.state.count("potion"))
        assertEquals(g.state.gold / price, g.canBuy("potion"))
    }

    @Test
    fun buysBackLastFiveForWhatTheyFetched() {
        val g = game()
        repeat(7) { g.state.addGear(Loot.roll(0, GearBases.all.first(), 1, Rarity.COMMON, Dice(Random(it)))) }
        val first = g.state.bag.toList()
        first.forEach { g.sellGear(it) }
        assertEquals(5, g.buyback.size)
        assertEquals(first.last(), g.buyback.first().gear)
        val s = g.buyback.first()
        val gold = g.state.gold
        g.buyBack(s)
        assertEquals(gold - s.price, g.state.gold)
        assertTrue(s.gear in g.state.bag)
        assertEquals(4, g.buyback.size)
        // supplies come back in the same number
        g.buy("potion", 4); g.sell("potion", 4)
        val p = g.buyback.first()
        val n = g.state.count("potion")
        g.buyBack(p)
        assertEquals(n + 4, g.state.count("potion"))
        // a new visit starts afresh
        g.advance(); g.enqueue(listOf(Cmd.OpenShop(Story.shopStock)))
        assertTrue(g.buyback.isEmpty())
    }
}
