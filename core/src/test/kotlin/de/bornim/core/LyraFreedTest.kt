package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 356.1: Lyra chained in Grak's hall; Grak's key frees her, her blessing heals fully, then she walks out of the hall. */
class LyraFreedTest {
    private fun game(): Pair<Game, Bot> {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(7)))
        val bot = Bot(g)
        bot.settle()
        g.state.flags += listOf(Story.INTRO_DONE, Story.QUEST_STARTED, Story.BARRIER_OPEN, Story.KROGG_DEFEATED, Story.GATE_OPEN, Story.GRAK_DEFEATED, "cave_seen")
        g.state.place = Place("cave", 9, 2, Facing.LEFT)
        return g to bot
    }

    @Test
    fun graksLootHoldsTheKey() {
        assertTrue(Monsters["hobgoblin_captain"].loot.any { it.item == "grak_key" && it.chance >= 1.0 })
        assertFalse(Items["grak_key"].sellable)
    }

    @Test
    fun theKeyFreesHerTheBlessingHealsAndSheWalksOut() {
        val (g, bot) = game()
        g.state.add("grak_key", 1)
        g.hero.hp = 1
        val lyra = g.map.npcs.first { it.id == "lyra_cave" }
        bot.talkTo("cave", "lyra_cave")
        assertTrue(g.state.has(Story.LYRA_RESCUED))
        assertEquals(0, g.state.count("grak_key"), "the key stays in the lock")
        assertEquals(2, g.state.count("holy_water"))
        assertEquals(g.hero.maxHp, g.hero.hp, "the blessing heals fully")
        assertFalse(g.state.respawn == g.state.place, "the blessing is no rest: the respawn point stays")
        // she walks, visibly, to the hall's way out, and is gone there
        val w = g.walkerOf(lyra)!!
        var t = 1_000L
        var steps = 0
        var last = w.x to w.y
        while (!g.state.has(Story.LYRA_GONE) && t < 60_000L) {
            g.update(t); t += 50
            if (g.mode != Mode.Explore) bot.settle()
            if ((w.x to w.y) != last) { steps++; last = w.x to w.y }
        }
        assertTrue(g.state.has(Story.LYRA_GONE), "Lyra still at ${w.x},${w.y}")
        assertEquals(10 to 7, w.x to w.y)
        assertTrue(steps >= 3, "she walked $steps steps")
        assertTrue(g.map.npcs.filter { it.visible(g.state) }.none { it.id == "lyra_cave" })
    }

    @Test
    fun aGameSavedBetweenGrakAndLyraHasNoKeyAndStillFreesHer() {
        val (g, bot) = game()
        bot.talkTo("cave", "lyra_cave")
        assertTrue(g.state.has(Story.LYRA_RESCUED))
    }

    @Test
    fun beforeGrakFallsSheStaysChained() {
        val (g, _) = game()
        g.state.flags -= Story.GRAK_DEFEATED
        val w = g.walkerOf(g.map.npcs.first { it.id == "lyra_cave" })!!
        var t = 1_000L
        while (t < 10_000L) { g.update(t); t += 50 }
        assertEquals(8 to 1, w.x to w.y)
    }
}
