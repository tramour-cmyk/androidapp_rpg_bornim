package de.bornim.core.audio

import de.bornim.core.World
import de.bornim.core.art.MapHen
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The hens are heard only near and only for what they do (83c): clucks now and then, alarm and wings when they run. */
class HenSoundTest {
    private val village = World["village"]

    @Test
    fun cluckingNowAndThenNeverInTimeAndAlarmOnceWhenTheyRun() {
        val src = MapHen.of(village).first()
        val h = MapHen.Hen(src.homeX, src.homeY, src.seed, src.variant)
        val ear = HenSound.Ear(listOf(h))
        val clucks = mutableListOf<Long>()
        // a minute and a half with the hero two tiles off: some clucks, not all bouts, never on one beat
        val near = src.homeX - 70f
        for (t in 0L..90_000L step 40L) {
            h.at(t, near - 200f, src.homeY, village)
            for ((s, _) in ear.hear(near, src.homeY)) if (s == Sound.HEN_CLUCK) clucks += t
        }
        assertTrue(clucks.size in 4..25, "clucks: ${clucks.size}")
        assertTrue(clucks.zipWithNext { a, b -> b - a }.toSet().size > 2, "clucks on a beat: $clucks")
        // the hero walks up: one alarm and one beat of wings, not more
        val heard = mutableListOf<Sound>()
        for (t in 90_040L..93_000L step 40L) {
            h.at(t, src.homeX - 30f, src.homeY, village)
            heard += ear.hear(src.homeX - 30f, src.homeY).map { it.first }
        }
        assertEquals(1, heard.count { it == Sound.HEN_ALARM })
        assertEquals(1, heard.count { it == Sound.HEN_FLAP })
        // far off nothing is heard
        val far = HenSound.Ear(listOf(h))
        far.hear(0f, 0f)
        for (t in 93_040L..150_000L step 40L) { h.at(t, 0f, 0f, village); assertTrue(far.hear(0f, 0f).isEmpty()) }
    }
}
