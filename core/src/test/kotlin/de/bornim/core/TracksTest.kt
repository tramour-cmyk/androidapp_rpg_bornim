package de.bornim.core

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Traces that stay a while (idea 7, draft): blood, footprints after rain, dust. */
class TracksTest {
    @BeforeTest fun on() { Tracks.draft = true }
    @AfterTest fun off() { Tracks.draft = false }

    /** Walks [tiles] down the map from (5.5, 5.5) on [ground], 0.05 tiles a frame of 16 ms. */
    private fun Tracks.walk(tiles: Double, ground: Tile, outdoors: Boolean = true, running: Boolean = false, map: String = "forest", t0: Long = 0L): Long {
        var t = t0
        var y = 5.5
        walked(map, 5.5, y, 0.0, ground, outdoors, running, t)
        while (y < 5.5 + tiles) { y += 0.05; t += 16; walked(map, 5.5, y, 0.0, ground, outdoors, running, t) }
        return t
    }

    @Test
    fun nothingWithoutTheSwitch() {
        Tracks.draft = false
        val tr = Tracks()
        tr.settle(1f)
        tr.walk(4.0, Tile.GRASS)
        tr.blood("forest", 3.5, 3.5, 0, 1)
        assertTrue(tr.marks.isEmpty())
    }

    @Test
    fun dryGrassKeepsNoPrintsWetGrassDoesLeftAndRight() {
        val dry = Tracks()
        dry.walk(4.0, Tile.GRASS)
        assertTrue(dry.marks.none { it.kind == Tracks.Kind.PRINT })
        val wet = Tracks()
        wet.settle(1f)
        wet.walk(4.0, Tile.GRASS)
        val prints = wet.marks.filter { it.kind == Tracks.Kind.PRINT }
        // one print a step of 0.42 tiles
        assertTrue(prints.size in 8..10, "prints: ${prints.size}")
        // the feet alternate, set beside the line walked
        assertTrue(prints.zipWithNext().all { (a, b) -> a.left != b.left })
        assertTrue(prints.all { kotlin.math.abs(it.x - 5.5) in 0.05..0.09 })
    }

    @Test
    fun theGroundDriesSlowlyAfterTheRain() {
        val tr = Tracks()
        tr.weather(1f, 1000)
        assertEquals(1f, tr.wet)
        tr.weather(0f, (Tracks.DRY_MS / 2).toLong())
        assertTrue(tr.wet in 0.45f..0.55f)
        tr.weather(0f, Tracks.DRY_MS.toLong())
        assertEquals(0f, tr.wet)
    }

    @Test
    fun muddyBootsLeaveAFewFadingPrintsIndoors() {
        val tr = Tracks()
        tr.settle(1f)
        val t = tr.walk(1.0, Tile.GRASS)
        assertEquals(Tracks.MUD_STEPS, tr.mud)
        tr.settle(0f)
        tr.walk(6.0, Tile.WOOD_FLOOR, outdoors = false, map = "inn", t0 = t)
        val inside = tr.marks.filter { it.map == "inn" }
        assertEquals(Tracks.MUD_STEPS, inside.size)
        assertTrue(inside.zipWithNext().all { (a, b) -> b.strength < a.strength })
        assertTrue(inside.first().strength <= Tracks.CARRIED)
        assertEquals(0, tr.mud)
    }

    @Test
    fun dustOnlyRunningOnADryWay() {
        val walk = Tracks()
        walk.walk(4.0, Tile.PATH)
        assertTrue(walk.marks.isEmpty())
        val run = Tracks()
        run.walk(4.0, Tile.PATH, running = true)
        assertTrue(run.marks.count { it.kind == Tracks.Kind.DUST } >= 3)
        val wet = Tracks()
        wet.settle(1f)
        wet.walk(4.0, Tile.PATH, running = true)
        assertTrue(wet.marks.none { it.kind == Tracks.Kind.DUST })
        val grass = Tracks()
        grass.walk(4.0, Tile.GRASS, running = true)
        assertTrue(grass.marks.isEmpty())
    }

    @Test
    fun bloodStaysAWhileThenFades() {
        val tr = Tracks()
        tr.blood("forest", 3.5, 3.5, 0, 7)
        val m = tr.on("forest", 1000).single()
        assertEquals(1f, m.alpha(1000))
        assertEquals(1f, m.alpha((Tracks.BLOOD_MS * 0.5).toLong()))
        assertTrue(m.alpha((Tracks.BLOOD_MS * 0.9).toLong()) in 0.1f..0.5f)
        assertTrue(tr.on("forest", Tracks.BLOOD_MS).isEmpty())
        assertTrue(tr.on("village", 1000).isEmpty())
    }

    @Test
    fun keepsAtMostMaxAndBloodLongest() {
        val tr = Tracks()
        tr.blood("forest", 3.5, 3.5, 0, 7)
        tr.settle(1f)
        tr.walk(200.0, Tile.GRASS)
        assertTrue(tr.marks.size <= Tracks.MAX)
        assertTrue(tr.marks.any { it.kind == Tracks.Kind.BLOOD })
    }

    @Test
    fun aWonFightLeavesBloodWhereTheFoeStood() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = Place("forest", 10, 20, Facing.UP)
        val r = g.roamers.first()
        g.roamers.drop(1).forEach { it.x = 0; it.y = 0 }
        r.x = 10; r.y = 19
        s.hero.gainXp(Rules.xpForLevel[10])
        g.move(Facing.UP)
        val b = (g.mode as Mode.Fight).battle
        b.start()
        while (b.outcome == Outcome.ONGOING) { s.hero.restoreFully(); b.act(Action.Attack) }
        assertEquals(Outcome.WON, b.outcome)
        g.endBattle()
        val m = g.tracks.marks.single()
        assertEquals(Tracks.Kind.BLOOD, m.kind)
        assertEquals("forest", m.map)
        assertEquals(10.5, m.x); assertEquals(19.5, m.y)
    }

    @Test
    fun villagersLeavePrintsOfTheirOwn() {
        // 61 (test of 0.1.662): in the rain the folk leave prints too, each walker with his own stride
        val tr = Tracks()
        tr.settle(1f)
        var t = 0L; var y = 5.5
        while (y < 9.5) {
            tr.walked("village", 5.5, y, 0.0, Tile.GRASS, true, false, t)
            tr.walked("village", 8.5, y + 0.2, 0.0, Tile.GRASS, true, false, t, who = "bram")
            y += 0.05; t += 16
        }
        val prints = tr.marks.filter { it.kind == Tracks.Kind.PRINT }
        val hero = prints.filter { kotlin.math.abs(it.x - 5.5) < 0.2 }; val bram = prints.filter { kotlin.math.abs(it.x - 8.5) < 0.2 }
        assertTrue(hero.size in 8..10 && bram.size in 8..10, "hero ${hero.size}, bram ${bram.size}")
        assertTrue(bram.zipWithNext().all { (a, b) -> a.left != b.left })
    }
}
