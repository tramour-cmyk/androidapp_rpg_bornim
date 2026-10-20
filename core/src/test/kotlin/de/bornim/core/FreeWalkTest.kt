package de.bornim.core

import kotlin.math.floor
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
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
        g.freeWalk.x = p.x + 0.9
        val w = g.map.npcs.filter { it.moves }.firstNotNullOf { g.walkerOf(it) }
        w.x = p.x + 1; w.y = p.y; w.fromX = w.x; w.fromY = w.y
        assertTrue(!g.free(p.x + 1, p.y), "the villager stands beside the hero")
        val x0 = g.freeWalk.x
        g.go(-1.0, 0.0, 300)
        assertTrue(g.freeWalk.x < x0 - 0.2, "walked away: ${g.freeWalk.x}")
        // but never further into them
        g.freeWalk.x = p.x + 0.9; g.state.place = p
        g.go(1.0, 0.0, 300)
        assertTrue(g.freeWalk.x <= p.x + 0.9 + 1e-9, "not into the villager: ${g.freeWalk.x}")
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
        // 215 (Rückläufer Build 38): walking against it knocks no more, only the action button does
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
            assertFalse(knocked, "no knocking by walking at ${d.x},${d.y}")
            assertEquals(d.y + 1, g.state.place.y, "still before the door ${d.x},${d.y}")
            assertTrue(g.freeWalk.y >= d.y + 1 + FreeWalk.RADIUS - 1e-6, "body outside the door ${d.x},${d.y}: ${g.freeWalk.y}")
            assertEquals(ActionKind.ENTER, g.actionAhead(), "the button offers the door ${d.x},${d.y}")
            assertEquals(null, g.actionPlace(), "no place named for a shut door ${d.x},${d.y}")
            g.interact()
            assertTrue(g.mode is Mode.Dialog, "the button knocks at ${d.x},${d.y}")
            assertEquals("village", g.state.place.map)
        }
    }

    /**
     * 152 (Chef, Build 16 and 17: from the west far off; "Ein gleichmäßiges und nahes Umrunden ist nicht möglich"):
     * the hero comes as near to Garrick from every side, and walking round him keeps the same distance.
     */
    @Test
    fun garrickIsAsNearFromEverySideAndCanBeWalkedRound() {
        val g = game("forest")
        val npc = World["forest"].npcAt(10, 9, g.state)!!
        val gx = 10.5 + de.bornim.core.art.MapFolk.nudge(npc, World["forest"]).first / 32.0
        val gy = 9.5
        fun dist() = kotlin.math.hypot(g.freeWalk.x - gx, g.freeWalk.y - gy)
        // up to him from seven sides (east is his fire)
        val near = listOf(-1 to 0, -1 to 1, 0 to 1, 1 to 1, 1 to -1, 0 to -1, -1 to -1).map { (dx, dy) ->
            g.state.place = Place("forest", 10 + dx * 2, 9 + dy * 2, Facing.DOWN)
            g.freeWalk.sync()
            var t = 1_000L
            repeat(150) { g.freeWalk.walk(gx - g.freeWalk.x, gy - g.freeWalk.y, 16, FreeWalk.WALK, t); t += 16 }
            dist()
        }
        // 216: nearer, 0.62 straight on, the 0.71 of the tile's corners on the slant
        assertTrue(near.all { it in 0.6..0.75 }, "Abstände $near")
        // round him from the west through south to north-east: always pressing inward a little
        g.state.place = Place("forest", 9, 9, Facing.DOWN)
        g.freeWalk.sync()
        var t = 1_000L
        repeat(60) { g.freeWalk.walk(gx - g.freeWalk.x, gy - g.freeWalk.y, 16, FreeWalk.WALK, t); t += 16 }
        val seen = mutableListOf<Double>()
        repeat(200) {
            val rx = g.freeWalk.x - gx; val ry = g.freeWalk.y - gy
            // west, south, on to the fire in the east: the tangent plus a fifth inward
            g.freeWalk.walk(ry - rx * 0.2, -rx - ry * 0.2, 16, FreeWalk.WALK, t); t += 16
            seen += dist()
        }
        val angle = Math.toDegrees(kotlin.math.atan2(g.freeWalk.y - gy, g.freeWalk.x - gx))
        assertTrue(seen.min() > 0.6 && seen.max() < 0.78, "beim Umrunden ${seen.min()}..${seen.max()}")
        assertTrue(angle in 0.0..75.0, "nicht bis vor das Feuer herumgekommen, Winkel $angle")
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

    /** 216: the action button reaches someone on the slant, ahead of the hero but not on the tile straight ahead. */
    @Test
    fun actionReachesSomeoneOnTheSlant() {
        val g = game("forest")
        // Garrick at (10, 9), his fire east of him: the hero south-west of him, near the corner of his tile, looking north-east
        g.state.place = Place("forest", 9, 10, Facing.UP)
        g.freeWalk.sync()
        g.freeWalk.x = 9.8; g.freeWalk.y = 10.2
        assertEquals(null, g.actionAt(9, 9), "nothing straight ahead")
        g.freeWalk.yaw = 160.0
        assertEquals(ActionKind.TALK, g.actionAhead(), "Garrick on the slant")
        assertEquals(10 to 9, g.actionTarget())
        g.interact()
        assertTrue(g.mode is Mode.Dialog, "talks: ${g.mode}")
        assertEquals(Facing.UP, g.state.place.facing)
    }

    /** 216: people before things: beside Garrick's fire the button talks to him, the fire comes second. */
    @Test
    fun actionPrefersPeopleToThings() {
        val g = game("forest")
        // north of the gap between Garrick (10, 9) and his fire (11, 9), looking down at both
        g.state.place = Place("forest", 10, 8, Facing.DOWN)
        g.freeWalk.sync()
        g.freeWalk.x = 10.95; g.freeWalk.y = 8.6; g.freeWalk.yaw = 0.0
        assertEquals(10 to 9, g.actionTarget())
        // straight over the fire, Garrick out of the fan: the fire
        g.state.place = Place("forest", 11, 8, Facing.DOWN)
        g.freeWalk.sync()
        assertEquals(11 to 9, g.actionTarget())
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

/** 216.3 (Chef 20.10.: "Näher komme ich nicht an die Lampe ran"): things under the open sky stop the hero at what is drawn, not a whole tile away. */
class OutsideThingsTest {
    private fun game(): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        return g
    }

    /** Puts the hero in the middle of ([x], [y]) on [map] and walks towards (vx, vy) for two seconds; true if a free start. */
    private fun Game.approach(map: String, x: Int, y: Int, vx: Double, vy: Double): Boolean {
        val m = World[map]
        if (!m.walkable(x, y, state) || m.warpAt(x, y) != null || walkerAt(x, y) || m.npcAt(x, y, state) != null) return false
        state.place = Place(map, x, y, Facing.DOWN)
        (roamers as? MutableList<Roamer>)?.clear()
        freeWalk.sync()
        var t = 1_000L
        repeat(125) { if (mode == Mode.Explore && state.place.map == map) freeWalk.walk(vx, vy, 16, FreeWalk.WALK, t); t += 16 }
        return mode == Mode.Explore && state.place.map == map
    }

    @Test
    fun theHeroComesUpToALampHalfATileFromItsPost() {
        val g = game()
        val m = World["village"]
        var tried = 0
        for (ty in 0 until m.height) for (tx in 0 until m.width) {
            if (m.tile(tx, ty) != Tile.LAMP || !m.walkable(tx, ty + 1, g.state)) continue
            if (!g.approach("village", tx, ty + 2, 0.0, -1.0)) continue
            // someone walking about in the way
            if (g.state.place.x != tx || g.walkerAt(tx, ty + 1)) continue
            tried++
            val d = kotlin.math.hypot(g.freeWalk.x - (tx + 0.5), g.freeWalk.y - (ty + 0.5))
            assertTrue(d < 0.56, "lamp at $tx/$ty: the hero stops ${"%.2f".format(d)} from its post")
            assertEquals(ty + 1, floor(g.freeWalk.y).toInt(), "never into the lamp's tile")
        }
        assertTrue(tried > 0, "no lamp to walk up to")
    }

    /** t45 (Chef 20.10.: "Näher an das Feuer … komme ich aus dieser Richtung nicht ran"): to the right on the screen is slantwise on the map. */
    @Test
    fun theHeroComesUpToGarricksFireSlantwise() {
        val g = game()
        val m = World["forest"]
        var tried = 0
        for (ty in 0 until m.height) for (tx in 0 until m.width) {
            if (m.tile(tx, ty) != Tile.CAMPFIRE) continue
            if (!g.approach("forest", tx + 2, ty - 2, -1.0, 1.0)) continue
            tried++
            val d = kotlin.math.hypot(g.freeWalk.x - (tx + 0.5), g.freeWalk.y - (ty + 0.5))
            assertTrue(d < 0.75, "fire at $tx/$ty: the hero stops ${"%.2f".format(d)} from its middle")
            assertFalse(floor(g.freeWalk.x).toInt() == tx && floor(g.freeWalk.y).toInt() == ty, "never into the fire's tile")
        }
        assertTrue(tried > 0, "no fire to walk up to")
    }

    @Test
    fun noThingOutsideIsEnteredFromAnySide() {
        val g = game()
        for (map in listOf("village", "forest", "deep_forest", "cave")) {
            val m = World[map]
            g.state.place = Place(map, 0, 0, Facing.DOWN)
            for (ty in 1 until m.height - 1) for (tx in 1 until m.width - 1) {
                val t = m.tile(tx, ty)
                if (t.walkable) continue
                g.state.place = Place(map, tx, ty, Facing.DOWN)
                val f = g.freeWalk.footprint(tx, ty)
                assertTrue(f[0] >= 0.0 && f[1] >= 0.0 && f[2] <= 1.0 && f[3] <= 1.0 && f[0] < f[2] && f[1] < f[3], "$map $tx/$ty $t: ${f.toList()}")
                for ((dx, dy) in listOf(0 to 1, 0 to -1, 1 to 0, -1 to 0)) {
                    if (!g.approach(map, tx + dx, ty + dy, -dx.toDouble(), -dy.toDouble())) continue
                    assertFalse(floor(g.freeWalk.x).toInt() == tx && floor(g.freeWalk.y).toInt() == ty, "$map: into $t at $tx/$ty from $dx/$dy")
                }
            }
        }
    }
}

/** 215 (Rückläufer Build 38, Chef: "Betreten von Häusern nicht, da der Held \"ins Haus\" läuft"): an open door stops the hero in front of it; the button takes it. */
class OpenDoorTest {
    @Test
    fun theHeroStopsBeforeTheInnDoorAndTheButtonTakesIt() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE)
        val d = World["village"].warps.first { it.to.map == "inn" }
        s.place = Place("village", d.x, d.y + 1, Facing.UP)
        g.freeWalk.sync()
        var t = 50_000L
        repeat(80) { g.freeWalk.walk(0.0, -1.0, 16, FreeWalk.WALK, t); t += 16 }
        assertEquals(Place("village", d.x, d.y + 1, Facing.UP), g.state.place, "before the door, not in it")
        assertTrue(g.freeWalk.y >= d.y + 1 + FreeWalk.RADIUS - 1e-6, "body outside the wall: ${g.freeWalk.y}")
        assertEquals(ActionKind.ENTER, g.actionAhead())
        assertEquals(World["inn"].name, g.actionPlace())
        g.interact()
        assertEquals("inn", g.state.place.map)
        // and out again: the door inside stops the hero as well
        val back = World["inn"].warps.single()
        assertEquals(null, World["inn"].warpAt(s.place.x, s.place.y))
        assertTrue(g.door(back.x, back.y))
    }
}
