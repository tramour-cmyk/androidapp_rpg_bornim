package de.bornim.core

import de.bornim.core.audio.Sfx
import de.bornim.core.audio.Sound
import kotlin.random.Random
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** The weather switch, rain setting in slowly, and sheet lightning with its thunder (10.10., 1). */
class WeatherTest {
    private fun game(map: String = "forest"): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(3)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = when (map) { "forest" -> Place("forest", 10, 20, Facing.UP); "village" -> Place("village", 11, 7, Facing.DOWN); else -> Place(map, 8, 2, Facing.DOWN) }
        return g
    }

    /** Runs the game for [ms] of play in frames of 50 ms, starting at app time [from]. */
    private fun Game.run(from: Long, ms: Long): Long {
        var t = from
        while (t < from + ms) { update(t); t += 50 }
        return t
    }

    @AfterTest fun reset() { Weather.mode = Weather.Mode.RANDOM }

    @Test
    fun switchNeverMeansNoRainEvenWhenItWouldRain() {
        val g = game()
        g.cheatRain() // chance -> always
        assertEquals(Weather.Mode.ALWAYS, Weather.mode)
        assertTrue(g.raining)
        g.cheatRain() // always -> never
        assertEquals(Weather.Mode.NEVER, Weather.mode)
        assertFalse(g.raining)
        // hours of play: it never starts to rain
        g.run(1, 3 * 3600_000L / 60)
        assertFalse(g.raining)
        assertEquals(0f, g.rainLevel)
        g.cheatRain()
        assertEquals(Weather.Mode.RANDOM, Weather.mode)
    }

    @Test
    fun rainSetsInAndStopsSlowly() {
        val g = game()
        Weather.mode = Weather.Mode.ALWAYS
        var t = g.run(1, 2000)
        assertTrue(g.rainLevel in 0.1f..0.4f, "after 2 s: ${g.rainLevel}")
        t = g.run(t, 9000)
        assertEquals(1f, g.rainLevel)
        Weather.mode = Weather.Mode.NEVER
        t = g.run(t, 3000)
        assertTrue(g.rainLevel in 0.5f..0.8f, "3 s after stopping: ${g.rainLevel}")
        g.run(t, 9000)
        assertEquals(0f, g.rainLevel)
    }

    @Test
    fun thunderFollowsTheFlashSecondsLaterOnlyOutdoors() {
        val g = game()
        var t = g.run(1, 500)
        g.cheatFlash(); g.releaseFlash()
        g.sounds.clear()
        t = g.run(t, Weather.THUNDER_DELAY.first - 200)
        assertFalse(Sound.THUNDER in g.sounds, "thunder too early")
        g.run(t, Weather.THUNDER_DELAY.last - Weather.THUNDER_DELAY.first + 600)
        assertTrue(Sound.THUNDER in g.sounds)
        // indoors the flash is not seen and the thunder not heard
        val inn = game("inn")
        val t2 = inn.run(1, 500)
        inn.cheatFlash(); inn.releaseFlash(); inn.sounds.clear()
        inn.run(t2, Weather.THUNDER_DELAY.last + 600)
        assertFalse(Sound.THUNDER in inn.sounds)
    }

    @Test
    fun lightningIsRare() {
        // heavy rain all the time: over two hours of play only a handful of flashes (in the village: no beasts to interrupt)
        val g = game("village")
        Weather.mode = Weather.Mode.ALWAYS
        var flashes = 0
        var last = g.flashAt
        var t = 1L
        repeat(120) {
            t = g.run(t, 60_000)
            if (g.flashAt != last) { flashes++; last = g.flashAt }
        }
        assertTrue(flashes in 1..60, "flashes: $flashes")
    }

    @Test
    fun thunderIsALowRumbleNotSilentNotClipped() {
        val pcm = Sfx.render(Sound.THUNDER, 0)
        val peak = pcm.maxOf { kotlin.math.abs(it.toInt()) }
        assertTrue(peak > 3000, "too quiet: $peak")
        val clipped = pcm.count { kotlin.math.abs(it.toInt()) >= 32767 }
        assertTrue(clipped < pcm.size / 1000, "clipped: $clipped")
    }
}

class FlashReleaseTest {
    @Test
    fun theTestFlashWaitsUntilTheMapIsSeen() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(3)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.place = Place("village", 11, 7, Facing.DOWN)
        g.update(1000)
        val before = g.flashAt
        g.cheatFlash()
        g.update(5000)
        assertEquals(before, g.flashAt, "flashed while the menu was open")
        g.releaseFlash()
        assertEquals(5000, g.flashAt)
    }
}
