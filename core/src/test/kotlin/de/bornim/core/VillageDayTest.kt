package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.test.fail

/** 5l Leben im Dorf: every place of the day can be reached, and the villagers get there in time. */
class VillageDayTest {
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

    /** 5la (Nutzer 13.10., 21:1x): Pim stood outside at four in the morning; at night he is indoors, in the morning out again. */
    @Test
    fun pimIsInBedAtNight() {
        val g = game()
        val pim = g.map.npcs.first { it.id == "pim" }
        g.state.minutes = 19 * 60
        var t = 1000L
        g.update(t)
        val seen = mutableMapOf<Int, Boolean>()
        // from seven in the evening to noon the next day, one game minute a second
        repeat(17 * 60 * 10) {
            t += 100
            g.update(t)
            val min = g.state.minutes
            if (min == 4 * 60 || min == 23 * 60 || min == 11 * 60) seen[min] = g.indoors(pim)
        }
        assertTrue(seen[23 * 60] == true, "Pim um 23 Uhr drinnen")
        assertTrue(seen[4 * 60] == true, "Pim um 4 Uhr drinnen (im Bett)")
        assertTrue(seen[11 * 60] == false, "Pim um 11 Uhr draußen")
        val home = VillageDay.stopAt("pim", 4 * 60)!!
        assertTrue(home.inside)
    }

    /** 330 (Chef 23.10.: not only at right angles): across on open ground, never round a corner. */
    @Test
    fun theWayGoesAcrossButNotRoundCorners() {
        val open = { _: Int, _: Int -> true }
        val d = VillageDay.firstStep(0, 0, 3, 3, 8, 8, open = open)!!
        assertTrue(d.dx == 1 && d.dy == 1, "across on open ground: $d")
        // a wall at (1, 0): no step across from (0, 0) to (1, 1) past its corner
        val walled = { x: Int, y: Int -> !(x == 1 && y == 0) }
        val e = VillageDay.firstStep(0, 0, 1, 1, 8, 8, open = walled)!!
        assertTrue(e.dx == 0 && e.dy == 1, "round the corner: $e")
        // a walker stepping across goes √2 tiles and takes longer for it
        val w = Walker(Npc("t", 5, 5, "guard", Facing.DOWN, talk = { emptyList() }))
        w.step(1, 1, 0)
        assertTrue(w.across && w.stepMs > w.moveMs && kotlin.math.abs(w.walked - Walker.SQRT2) < 1e-9)
        assertTrue(kotlin.math.abs(w.stepYaw - 45.0) < 1e-9 && w.facing == Facing.RIGHT)
    }

    /** 330 (film of 23.10.): of the shortest ways the one with the fewest bends, not a zigzag on the grid; the bridge straight on. */
    @Test
    fun theWayKeepsOnAndTheBridgeIsCrossedStraight() {
        val open = { _: Int, _: Int -> true }
        var x = 0; var y = 0; var prev: VillageDay.Step? = null; var bends = 0
        while (x != 6 || y != 14) {
            val d = VillageDay.firstStep(x, y, 6, 14, 20, 20, prev, open = open)!!
            if (prev != null && d != prev) bends++
            prev = d; x += d.dx; y += d.dy
        }
        assertTrue(bends <= 1, "one bend at most on open ground: $bends")
        val g = game()
        val m = g.map
        val bridge = (0 until m.width).flatMap { a -> (0 until m.height).map { b -> a to b } }.filter { (a, b) -> m.tile(a, b) == Tile.BRIDGE }
        assertTrue(bridge.isNotEmpty())
        for ((bx, by) in bridge) for (gx in listOf(bx - 3, bx + 3)) for (gy in listOf(by - 4, by + 4)) {
            if (!m.walkable(gx, gy, g.state)) continue
            val d = VillageDay.firstStep(bx, by, gx, gy, m.width, m.height, null, { a, b -> m.tile(a, b) == Tile.BRIDGE }) { a, b -> m.walkable(a, b, g.state) } ?: continue
            assertTrue(d.dx == 0 || d.dy == 0, "off the bridge at $bx,$by straight: $d")
        }
        // on the bridge, two tiles wide, the folk keep to its middle
        val (bx, by) = bridge.first { (a, b) -> m.tile(a + 1, b) == Tile.BRIDGE }
        assertTrue(g.bridgeShift(bx, by) > 0 && g.bridgeShift(bx + 1, by) < 0 && g.bridgeShift(bx, by - 2) == 0.0)
        // turned right round: first on the spot, then off
        val w = Walker(Npc("t", 5, 5, "guard", Facing.DOWN, talk = { emptyList() }))
        w.step(0, -1, 1000)
        assertTrue(w.movedAt > 1000 + 300, "half a turn first: ${w.movedAt - 1000} ms")
    }
}
