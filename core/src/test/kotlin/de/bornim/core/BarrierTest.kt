package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class BarrierTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(2)))
        skip(g)
        return g
    }

    private fun skip(g: Game): List<String> {
        val texts = mutableListOf<String>()
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) {
            (g.mode as Mode.Dialog).let { texts += it.toString() }
            g.advance()
        }
        return texts
    }

    @Test
    fun barrierBlocksTheNorthRoadUntilJorinRaisesIt() {
        val g = game()
        val village = World["village"]
        val barrier = (0 until village.width).filter { village.tile(it, 2) == Tile.BARRIER }
        assertEquals(listOf(17, 18), barrier)
        // No way around it: the forest exits cannot be reached while it is down.
        g.state.place = Place("village", 17, 5, Facing.UP)
        assertEquals(null, g.route(17, 0))
        g.state.place = Place("village", 17, 3, Facing.UP)
        assertTrue(g.move(Facing.UP) is Move.Blocked)
        assertTrue(g.mode is Mode.Dialog, "walking into the barrier explains it")
        skip(g)

        // With the quest it is still down until Jorin is asked.
        g.state.flags += Story.QUEST_STARTED
        assertTrue(g.move(Facing.UP) is Move.Blocked)
        skip(g)
        assertEquals("Lass dir von Wache Jorin den Schlagbaum am Nordweg öffnen.", Story.objective(g.state).de)

        val jorin = village.npcs.first { it.id == "jorin" }
        g.state.place = Place("village", jorin.x + 1, jorin.y, Facing.LEFT)
        g.interact()
        skip(g)
        assertTrue(g.state.has(Story.BARRIER_OPEN))
        g.state.place = Place("village", 17, 3, Facing.UP)
        assertTrue(g.move(Facing.UP) is Move.Stepped)
        g.state.place = Place("village", 17, 5, Facing.UP)
        assertNotNull(g.route(17, 0))
    }

    @Test
    fun jorinWalksHisRound() {
        val g = game()
        g.state.place = Place("village", 30, 20, Facing.DOWN) // far away
        val jorin = g.map.npcs.first { it.id == "jorin" }
        val seen = mutableSetOf<Pair<Int, Int>>()
        var t = 1000L
        repeat(1200) {
            t += 100
            g.update(t)
            val w = g.walkerOf(jorin)!!
            seen += w.x to w.y
            assertEquals(3, w.y, "stays on his line")
            assertEquals(jorin, g.npcAt(w.x, w.y))
        }
        assertTrue((10 to 3) in seen && (24 to 3) in seen, "patrol covered $seen")
    }

    @Test
    fun oldSavesOnTheQuestFindTheBarrierOpen() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.flags += Story.QUEST_STARTED
        s.version = 3
        val loaded = GameState.fromJson(s.toJson())
        assertTrue(loaded.has(Story.BARRIER_OPEN))
        val fresh = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        fresh.flags += Story.QUEST_STARTED
        assertFalse(GameState.fromJson(fresh.toJson()).has(Story.BARRIER_OPEN))
    }
}
