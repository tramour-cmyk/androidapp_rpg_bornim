package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class IngredientTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(4)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        return g
    }

    private fun skip(g: Game) {
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    }

    @Test
    fun animalsDropIngredients() {
        val drops = mutableSetOf<String>()
        for (id in listOf("wolf", "boar", "giant_spider", "giant_bat")) repeat(15) { seed ->
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
            s.hero.gainXp(Rules.xpForLevel[6])
            val b = Battle(s, Monsters[id], Lang.DE, Dice(Random(seed)), 2, false, 2)
            b.start()
            var n = 0
            while (b.outcome == Outcome.ONGOING && n++ < 40) {
                s.hero.hp = s.hero.maxHp
                b.act(Action.Attack)
            }
            drops += s.inventory.keys
        }
        assertTrue(drops.containsAll(listOf("raw_meat", "wolf_pelt", "boar_tusk", "spider_gland", "bat_wing")), "$drops")
    }

    @Test
    fun campfireRoastsMeatAndEatingFortifies() {
        val g = game()
        g.state.add("raw_meat", 3)
        g.state.place = Place("forest", 10, 9, Facing.RIGHT) // the hunter's campfire
        g.interact()
        skip(g)
        assertEquals(0, g.state.count("raw_meat"))
        assertEquals(3, g.state.count("roast_meat"))

        g.hero.hp = 3
        g.useItemOutside("roast_meat")
        assertTrue(g.hero.hp > 3)
        assertTrue(g.state.wellFed)
        // The bonus lasts for exactly one fight.
        val b = Battle(g.state, Monsters["giant_rat"], Lang.DE, Dice(Random(1)), 1, false, 1)
        assertTrue(b.wellFed)
        assertFalse(g.state.wellFed)
        assertTrue(b.start().any { "gestärkt" in it.text })
    }

    @Test
    fun heddaBrewsFromHerbs() {
        val g = game()
        val potion = Recipes.all.first { it.output == "potion" }
        assertFalse(potion.affordable(g.state.also { it.gold = 100 }))
        g.state.add("herbs", 2)
        assertTrue(potion.affordable(g.state))
        g.brew(potion)
        assertEquals(0, g.state.count("herbs"))
        assertEquals(100 - potion.gold, g.state.gold)
        assertTrue(g.state.count("potion") >= 1)
    }

    @Test
    fun flowerMeadowsHoldHerbsOnceADay() {
        val g = game()
        g.state.place = Place("forest", 3, 6, Facing.UP)
        assertEquals(Tile.FLOWERS, g.map.tile(3, 6))
        var days = 0
        while (g.state.count("herbs") == 0 && days++ < 30) {
            g.state.day++
            g.state.steps++
            g.afterStep()
        }
        assertTrue(g.state.count("herbs") > 0)
        // Picked today: nothing more until tomorrow.
        val n = g.state.count("herbs")
        repeat(5) { g.state.steps++; g.afterStep() }
        assertEquals(n, g.state.count("herbs"))
    }
}
