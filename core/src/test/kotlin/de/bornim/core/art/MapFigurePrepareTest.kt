package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.GearSlot
import de.bornim.core.Race
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertSame
import kotlin.test.assertTrue

/** 24.2/24.3: the order the hero's map pictures are drawn in, when they count as ready, and old gear walking on. */
class MapFigurePrepareTest {

    @Test fun orderStandsAllRoundThenWalksWhereItFaces() {
        val (jobs, first) = MapFigure.order(5)
        assertEquals(MapFigure.YAWS * MapFigure.STEPS, jobs.toSet().size, "every picture once")
        assertEquals(MapFigure.YAWS * MapFigure.STEPS, jobs.size)
        assertTrue(jobs.take(MapFigure.YAWS).all { it.second == 0 }, "standing in every direction first")
        assertEquals(5, jobs.first().first, "the direction it faces first")
        val near = jobs.subList(MapFigure.YAWS, first)
        assertEquals((2 * MapFigure.FIRST_SIDE + 1) * (MapFigure.STEPS - 1), near.size)
        assertTrue(near.all { (s, _) -> minOf(Math.floorMod(s - 5, 16), Math.floorMod(5 - s, 16)) <= MapFigure.FIRST_SIDE })
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

    private fun waitFor(ms: Long = 60_000, ok: () -> Boolean): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) { if (ok()) return true; Thread.sleep(20) }
        return ok()
    }
}
