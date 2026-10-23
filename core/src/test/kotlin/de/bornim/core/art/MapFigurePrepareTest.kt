package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.GearSlot
import de.bornim.core.Race
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotSame
import kotlin.test.assertSame
import kotlin.test.assertTrue

/** 24.2/24.3: the order the hero's map pictures are drawn in, when they count as ready, and old gear walking on. */
class MapFigurePrepareTest {

    @Test fun orderStandsAllRoundThenWalksWhereItFaces() {
        val (jobs, first) = MapFigure.order(5)
        assertEquals(MapFigure.YAWS * MapFigure.PICS, jobs.toSet().size, "every picture once")
        assertEquals(MapFigure.YAWS * MapFigure.PICS, jobs.size)
        // 245: the runs come last, after every picture of the walk
        assertTrue(jobs.takeLast(MapFigure.YAWS * MapFigure.RUN_STEPS).all { it.second >= MapFigure.STEPS })
        assertTrue(jobs.take(MapFigure.YAWS).all { it.second == 0 }, "standing in every direction first")
        assertEquals(5, jobs.first().first, "the direction it faces first")
        val near = jobs.subList(MapFigure.YAWS, first)
        assertEquals((2 * MapFigure.FIRST_SIDE + 1) * (MapFigure.STEPS - 1), near.size)
        assertTrue(near.all { (s, _) -> minOf(Math.floorMod(s - 5, 16), Math.floorMod(5 - s, 16)) <= MapFigure.FIRST_SIDE })
    }

    @Test fun aRunGoesOnFromTheWalkWithoutAJump() {
        // 245: walking, the walk's pictures; running, the run's; the stride goes on where it was
        val st = MapFigure.Stride()
        var w = 0.0
        var pic = st.at(w, false)
        repeat(30) { w += 0.05; pic = st.at(w, false); assertTrue(pic < MapFigure.STEPS) }
        val phase = st.phase
        w += 0.05
        val run = st.at(w, true)
        assertTrue(run >= MapFigure.STEPS)
        assertTrue(kotlin.math.abs(st.phase - phase) < 0.03, "the stride goes on")
        assertEquals((st.phase * MapFigure.RUN_STEPS).toInt(), run - MapFigure.STEPS)
    }

    @Test fun readyAndOldGearWalksOnUntilTheNewIsDrawn() {
        val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
        MapFigure.prepare(hero, 0.0)
        assertTrue(waitFor { MapFigure.ready(hero) }, "ready in time")
        val slot = MapFigure.slot(0.0)
        assertTrue(waitFor { MapFigure.frame(hero, Math.floorMod(slot + 8, 16), 7) != null }, "all drawn in the end")
        val old = MapFigure.frame(hero, slot, 3)!!
        // change of gear: the old pictures stand in until the new ones are there
        val armour = hero.unequip(GearSlot.entries.first { hero.item(it) != null })
        MapFigure.prepare(hero, 0.0)
        val shown = MapFigure.frameNow(hero, slot, 3)
        if (MapFigure.frame(hero, slot, 3) == null) assertSame(old, shown, "old gear walks on")
        assertTrue(waitFor { MapFigure.ready(hero) })
        assertTrue(armour != null)
    }

    @Test fun standingWaitsForTheNewGearToo() {
        // 322: standing, breathing or swinging the hero showed the new gear in some directions while walking showed the old
        val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
        MapFigure.prepareNow(hero)
        val slot = 4
        assertTrue(!MapFigure.changing())
        try {
            MapFigure.hold = true
            hero.unequip(GearSlot.entries.first { hero.item(it) != null })
            MapFigure.prepare(hero, 0.0)
            assertTrue(MapFigure.changing(), "the old gear stands in")
            val rest = MapRest.Rest.entries.first { it != MapRest.Rest.NEUTRAL }
            // asked again and again, a picture drawn in the background would come within a moment
            assertTrue(!waitFor(3_000) { MapFigure.restFrame(hero, slot, rest, 1) != null || MapFigure.swingFrame(hero, slot, 3) != null },
                "no new standing or swinging picture before all walk")
        } finally { MapFigure.hold = false }
        assertTrue(waitFor { !MapFigure.changing() }, "all change at once in the end")
    }

    @Test fun theNewGearShowsOnceItWalksNotAfterTheRuns() {
        // 332: the old gear stood in until the runs were drawn too, about three times as long as the walk
        val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
        MapFigure.prepareNow(hero)
        hero.unequip(GearSlot.entries.first { hero.item(it) != null })
        MapFigure.prepare(hero, 0.0)
        assertTrue(waitFor { !MapFigure.changing() })
        assertTrue(MapFigure.ready(hero), "walks in every direction")
        assertTrue(MapFigure.lastFullMs == null, "the runs still to come")
        assertTrue(waitFor(60_000) { MapFigure.lastFullMs != null })
    }

    @Test fun anotherHeroNeverWalksInTheOldPictures() {
        val mage = GameState.newGame("Mira", Race.ELF, CharClass.WIZARD).hero
        val fighter = GameState.newGame("Bran", Race.HUMAN, CharClass.FIGHTER).hero
        MapFigure.prepareNow(mage)
        val slot = 4
        val old = (0 until MapFigure.STEPS).map { MapFigure.frame(mage, slot, it)!! }
        try {
            MapFigure.hold = true
            MapFigure.prepare(fighter, 0.0) // another save game: nothing of the mage may show
            for (st in 0 until MapFigure.STEPS) {
                val shown = MapFigure.frameNow(fighter, slot, st)
                assertTrue(old.none { it === shown }, "step $st shows the mage")
            }
        } finally { MapFigure.hold = false }
    }

    @Test fun readyOnlyWhenItWalksInEveryDirection() {
        val hero = GameState.newGame("Ready", Race.DWARF, CharClass.CLERIC).hero
        MapFigure.prepare(hero, 0.0)
        assertTrue(waitFor { MapFigure.ready(hero) }, "ready in time")
        for (s in 0 until MapFigure.YAWS) for (st in 0 until MapFigure.STEPS)
            assertTrue(MapFigure.frame(hero, s, st) != null, "24.10: direction $s step $st drawn when ready")
    }

    @Test fun allDirectionsChangeGearAtOnce() {
        val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
        MapFigure.prepareNow(hero)
        val old = (0 until MapFigure.YAWS).map { s -> (0 until MapFigure.STEPS).map { MapFigure.frame(hero, s, it)!! } }
        try {
            MapFigure.hold = true
            assertTrue(hero.unequip(GearSlot.entries.first { hero.item(it) != null }) != null)
            MapFigure.prepare(hero, 0.0)
            // one direction wholly drawn anew: still every direction in the old gear
            for (st in 0 until MapFigure.STEPS) MapFigure.drawOne(hero, 6, st)
            for (s in 0 until MapFigure.YAWS) for (st in 0 until MapFigure.STEPS)
                assertSame(old[s][st], MapFigure.frameNow(hero, s, st), "direction $s step $st")
        } finally { MapFigure.hold = false }
        // all drawn: every direction in the new gear
        assertTrue(waitFor { (0 until MapFigure.YAWS).all { s -> MapFigure.frameNow(hero, s, 3) !== old[s][3] } })
        for (s in 0 until MapFigure.YAWS) for (st in 0 until MapFigure.STEPS) {
            assertNotSame(old[s][st], MapFigure.frameNow(hero, s, st))
            assertSame(MapFigure.frame(hero, s, st), MapFigure.frameNow(hero, s, st))
        }
    }

    private fun waitFor(ms: Long = 60_000, ok: () -> Boolean): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) { if (ok()) return true; Thread.sleep(20) }
        return ok()
    }
}
