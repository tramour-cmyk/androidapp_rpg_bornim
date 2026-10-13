package de.bornim.core

import kotlin.random.Random
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.test.fail

/** 5l Leben im Dorf (draft): every place of the day can be reached, and the villagers get there in time. */
class VillageDayTest {
    @AfterTest fun off() { VillageDay.draft = false }

    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.CLERIC), Lang.DE, Dice(Random(5)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        // the hero stands aside, out of everyone's way
        g.state.place = Place("village", 34, 10, Facing.DOWN)
        return g
    }

    @Test
    fun everyPlaceOfTheDayIsOpenAndReachable() {
        val g = game()
        val m = g.map
        for ((id, plan) in VillageDay.plans) {
            assertTrue(m.npcs.any { it.id == id && it.moves }, "$id strolls in the village")
            for (s in plan) {
                assertTrue(m.walkable(s.x, s.y, g.state) && m.warpAt(s.x, s.y) == null, "$id: ${s.x},${s.y} is open")
                for (t in plan) if (t != s) {
                    // follow the first steps all the way
                    var x = s.x; var y = s.y; var n = 0
                    while (x != t.x || y != t.y) {
                        val d = VillageDay.firstStep(x, y, t.x, t.y, m.width, m.height) { a, b -> m.walkable(a, b, g.state) && m.warpAt(a, b) == null }
                            ?: fail("$id: no way from ${s.x},${s.y} to ${t.x},${t.y}")
                        x += d.dx; y += d.dy
                        if (++n > 200) fail("$id: lost on the way to ${t.x},${t.y}")
                    }
                }
            }
        }
    }

    @Test
    fun villagersGetToEachPlaceInTime() {
        VillageDay.draft = true
        val g = game()
        g.state.minutes = 0
        var t = 1000L
        g.update(t)
        val late = mutableListOf<String>()
        // a whole day and a bit, one game minute a second, in steps of 100 ms
        repeat(25 * 60 * 10) {
            t += 100
            g.update(t)
            if (it % 10 != 0) return@repeat
            val min = g.state.minutes
            for (npc in g.map.npcs) {
                val plan = VillageDay.plans[npc.id] ?: continue
                val stop = VillageDay.stopAt(npc.id, min)!!
                // checked three quarters of an hour after setting out (a game minute is a second: the longest way, field to inn, takes half a minute)
                if (min - stop.from != 45) continue
                val w = g.walkerOf(npc)!!
                if (!VillageDay.near(stop, w.x, w.y)) late += "${npc.id} um ${min / 60}:${"%02d".format(min % 60)} bei ${w.x},${w.y}, soll ${stop.x},${stop.y}"
            }
        }
        assertTrue(late.isEmpty(), late.joinToString("\n"))
    }
}
