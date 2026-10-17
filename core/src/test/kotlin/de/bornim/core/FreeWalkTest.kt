package de.bornim.core

import kotlin.math.floor
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Free walking (13g): any direction, sliding along walls, tiles entered through the old step. */
class FreeWalkTest {
    /** A game with the hero on an open spot of [map] (all eight neighbours walkable). */
    private fun game(map: String): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        val m = World[map]
        val spot = (0 until m.height).flatMap { y -> (0 until m.width).map { x -> x to y } }.first { (x, y) ->
            (-1..1).all { dy -> (-1..1).all { dx -> m.walkable(x + dx, y + dy, s) && m.warpAt(x + dx, y + dy) == null } }
        }
        s.place = Place(map, spot.first, spot.second, Facing.DOWN)
        g.roamersOff()
        return g
    }

    private fun Game.roamersOff() { (roamers as? MutableList<Roamer>)?.clear() }

    /** Walks [ms] in direction (vx, vy) in frames of 16 ms. */
    private fun Game.go(vx: Double, vy: Double, ms: Int) {
        var t = 1_000L
        repeat(ms / 16) { freeWalk.walk(vx, vy, 16, FreeWalk.WALK, t); t += 16 }
    }

    @Test
    fun walksSlantedAndCountsTheTilesAsSteps() {
        // the inn's floor: open boards in the middle
        val g = game("village")
        val steps = g.state.steps
        g.freeWalk.sync()
        val x0 = g.freeWalk.x; val y0 = g.freeWalk.y
        g.go(1.0, 1.0, 800)
        assertTrue(g.freeWalk.x > x0 + 0.3 && g.freeWalk.y > y0 + 0.3, "moved slanted: ${g.freeWalk.x}, ${g.freeWalk.y}")
        // the tile in the game follows the feet
        assertEquals(floor(g.freeWalk.x).toInt(), g.state.place.x)
        assertEquals(floor(g.freeWalk.y).toInt(), g.state.place.y)
        assertTrue(g.state.steps > steps)
    }

    @Test
    fun walksAwayFromSomeoneWhoSteppedCloseBy() {
        // 5la (test 0.1.650): Bram stepped onto the tile beside the hero while its body reached into it;
        // the hero could then move no more, in no direction
        val g = game("village")
        g.freeWalk.sync()
        val p = g.state.place
        g.freeWalk.x = p.x + 0.85
        val w = g.map.npcs.filter { it.moves }.firstNotNullOf { g.walkerOf(it) }
        w.x = p.x + 1; w.y = p.y; w.fromX = w.x; w.fromY = w.y
        assertTrue(!g.free(p.x + 1, p.y), "the villager stands beside the hero")
        val x0 = g.freeWalk.x
        g.go(-1.0, 0.0, 300)
        assertTrue(g.freeWalk.x < x0 - 0.2, "walked away: ${g.freeWalk.x}")
        // but never further into them
        g.freeWalk.x = p.x + 0.85; g.state.place = p
        g.go(1.0, 0.0, 300)
        assertTrue(g.freeWalk.x <= p.x + 0.85 + 1e-9, "not into the villager: ${g.freeWalk.x}")
    }

    @Test
    fun neverInsideAWallAndSlidesAlongIt() {
        val g = game("village")
        g.freeWalk.sync()
        // walk long against the room's walls in every slanting direction: the feet never stand on a blocked tile
        for ((vx, vy) in listOf(-1.0 to -0.4, 0.4 to -1.0, 1.0 to 0.3, -0.3 to 1.0)) {
            repeat(120) {
                g.go(vx, vy, 16)
                val tx = floor(g.freeWalk.x).toInt(); val ty = floor(g.freeWalk.y).toInt()
                assertTrue(g.map.walkable(tx, ty, g.state), "inside a wall at ${g.freeWalk.x}, ${g.freeWalk.y}")
                if (g.mode != Mode.Explore) return
            }
        }
    }

    @Test
    fun pushingAgainstAWallAtASlantKeepsMoving() {
        val g = game("village")
        g.freeWalk.sync()
        // straight up to the back wall, then slanting into it: the hero slides sideways along it
        g.go(0.0, -1.0, 3_000)
        val x0 = g.freeWalk.x
        g.go(0.6, -1.0, 600)
        assertTrue(g.freeWalk.x > x0 + 0.2 || g.mode != Mode.Explore, "slid along the wall: $x0 -> ${g.freeWalk.x}")
    }

    @Test
    fun aShutDoorKnocksAndTheHeroStaysOutside() {
        // 82 (test 14.10.): at Pim's door the hero vanished behind the wall while the words from inside were read
        val g = game("village")
        val doors = g.map.warps.filter { it.requires != null && !it.turnBack && !g.state.has(it.requires) && it.knock != null }
        assertTrue(doors.isNotEmpty(), "locked doors in the village")
        var t = 50_000L
        for (d in doors) {
            t += 5_000
            g.state.place = Place("village", d.x, d.y + 1, Facing.UP)
            while (g.mode is Mode.Dialog) g.advance()
            g.freeWalk.sync()
            var knocked = false
            repeat(80) {
                g.freeWalk.walk(0.0, -1.0, 16, FreeWalk.WALK, t); t += 16
                if (g.mode is Mode.Dialog) knocked = true
            }
            assertTrue(knocked, "knocking at ${d.x},${d.y}")
            assertEquals(d.y + 1, g.state.place.y, "still before the door ${d.x},${d.y}")
            assertTrue(g.freeWalk.y >= d.y + 1 + FreeWalk.RADIUS - 1e-6, "body outside the door ${d.x},${d.y}: ${g.freeWalk.y}")
        }
    }

    /** 152 (Chef, Build 16): Garrick can be come up to about as near from the west as from the south. */
    @Test
    fun garrickIsAsNearFromEverySide() {
        val g = game("forest")
        assertTrue(World["forest"].npcAt(10, 9, g.state) != null)
        // where he is drawn, close to his fire
        val gx = 10.5 + de.bornim.core.art.MapFolk.nudge(World["forest"].npcAt(10, 9, g.state)!!, World["forest"]).first / 32.0
        fun near(from: Place, vx: Double, vy: Double): Double {
            g.state.place = from
            g.freeWalk.sync()
            g.go(vx, vy, 2_000)
            return kotlin.math.hypot(g.freeWalk.x - gx, g.freeWalk.y - 9.5)
        }
        val west = near(Place("forest", 8, 9, Facing.RIGHT), 1.0, 0.0)
        val south = near(Place("forest", 10, 11, Facing.UP), 0.0, -1.0)
        assertTrue(west < 0.95 && south < 0.95 && kotlin.math.abs(west - south) < 0.3, "von Westen $west, von Süden $south")
    }

    /** 151 (Chef, Build 16): over the bridge and left towards the elder, nothing unseen stops the hero below Pim's house. */
    @Test
    fun fromTheBridgeLeftTowardsTheElderNothingUnseenStopsTheHero() {
        val g = game("village")
        g.state.place = Place("village", 17, 25, Facing.LEFT)
        g.freeWalk.sync()
        g.go(-1.0, -0.2, 3_000)
        assertTrue(g.freeWalk.x < 13.0, "hängen geblieben bei ${g.freeWalk.x}, ${g.freeWalk.y}")
    }
}

/** 13p.5: the floor before the counter at the wall (1,4), beside the barrel in the corner, can be stepped on. */
class InnCornerTest {
    @Test
    fun floorBeforeTheCounterCanBeEntered() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.place = Place("inn", 2, 4, Facing.LEFT)
        (g.roamers as? MutableList<Roamer>)?.clear()
        g.freeWalk.sync()
        var t = 1_000L
        repeat(60) { g.freeWalk.walk(-1.0, 0.0, 16, FreeWalk.WALK, t); t += 16 }
        assertEquals(1 to 4, g.state.place.x to g.state.place.y, "at ${g.freeWalk.x}, ${g.freeWalk.y}, mode ${g.mode}")
    }

    @Test
    fun rowenaCanBeSpokenToOverTheCounter() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.place = Place("inn", 1, 4, Facing.UP)
        assertEquals(ActionKind.TALK, g.actionAhead())
    }

    @Test
    fun theHeroComesUpToTheShelfAgainstTheWall() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        // behind the counter, below the shelf at (2,1): the hero's middle comes up to the shelf's tile, never into it
        s.place = Place("inn", 2, 2, Facing.UP)
        (g.roamers as? MutableList<Roamer>)?.clear()
        g.freeWalk.sync()
        var t = 1_000L
        repeat(80) { g.freeWalk.walk(0.0, -1.0, 16, FreeWalk.WALK, t); t += 16 }
        assertEquals(2 to 2, g.state.place.x to g.state.place.y)
        assertTrue(g.freeWalk.y < 2.05, "stops at ${g.freeWalk.y}")
        assertEquals(ActionKind.LOOK, g.actionAhead())
    }

}
