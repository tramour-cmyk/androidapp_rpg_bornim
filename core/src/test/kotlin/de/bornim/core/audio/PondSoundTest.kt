package de.bornim.core.audio

import de.bornim.core.Story
import de.bornim.core.art.PondLife
import de.bornim.core.art.WorldArt
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 27j: the pond is heard from what is there: calls of sitting frogs by nearness, dragonflies only close by and by day. */
class PondSoundTest {
    private fun life() = PondLife.of(Story.forest)

    /** Runs a minute with the hero standing at map pixel ([hx], [hy]); the frogs see him as when drawn. */
    private fun minute(hx: Float, hy: Float, dusk: Boolean, flying: Boolean): List<Pair<Sound, Float>> {
        val l = life(); val ear = PondSound.Ear(l); val out = ArrayList<Pair<Sound, Float>>()
        for (t in 0L until 60_000L step 100) {
            for (f in l.frogs) f.at(t, hx, hy, dusk)
            out += ear.hear(t, hx, hy, dusk, flying)
        }
        return out
    }

    @Test
    fun farAwayIsSilent() {
        val f = life().frogs.first()
        assertTrue(minute(f.x + 12 * WorldArt.T, f.y, dusk = true, flying = true).isEmpty())
    }

    @Test
    fun sittingFrogsCallNowAndThenLouderAtDusk() {
        val f = life().frogs.first()
        val hx = f.x + 3 * WorldArt.T; val hy = f.y
        val day = minute(hx, hy, dusk = false, flying = false).filter { it.first == Sound.FROG }
        val dusk = minute(hx, hy, dusk = true, flying = false).filter { it.first == Sound.FROG }
        assertTrue(day.isNotEmpty(), "no call by day")
        assertTrue(dusk.size > day.size, "dusk ${dusk.size} vs day ${day.size}")
        // never a din: at most one call per frog and slot
        assertTrue(dusk.size <= life().frogs.size * (60_000 / PondLife.CROAK_MS + 1))
        assertTrue(dusk.all { it.second <= PondSound.FROG_MAX })
    }

    @Test
    fun aFrogInTheWaterIsSilent() {
        val l = life(); val f = l.frogs.first(); val ear = PondSound.Ear(l)
        var calls = 0
        for (t in 0L until 6_000L step 100) {
            // the hero stands right by this frog: it has leapt in and stays under
            f.at(t, f.x, f.y, true)
            calls += ear.hear(t, f.x, f.y, dusk = true, flying = false).count { it.first == Sound.FROG && it.second >= PondSound.frogVolume(0.0) }
        }
        assertEquals(false, f.sitting)
        assertEquals(0, calls)
    }

    @Test
    fun dragonfliesOnlyCloseAndWhenOut() {
        val fly = life().flies.first(); val a = fly.at(0)
        val near = minute(a.x, a.y, dusk = false, flying = true).count { it.first == Sound.DRAGONFLY }
        val inside = minute(a.x, a.y, dusk = false, flying = false).count { it.first == Sound.DRAGONFLY }
        assertTrue(near > 0, "no whirr close by")
        assertEquals(0, inside)
    }

    @Test
    fun chorusOnlyAtDusk() {
        val f = life().frogs.first()
        assertEquals(0f, PondSound.chorusTarget(life(), f.x + 3 * WorldArt.T, f.y, dusk = false))
    }
}
