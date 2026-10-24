package de.bornim.core.audio

import de.bornim.core.Story
import de.bornim.core.art.MapBirds
import de.bornim.core.art.WorldArt
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** What lives at a place but is not in sight (84, D3.15): no birds in the deep forest, far sounds rare and from one side. */
class WildSoundTest {
    @Test
    fun noBirdsInTheDeepForest() {
        val kind = WildSound.kindOf(Story.deepForest)
        assertEquals(WildSound.Kind.DEEP_WOOD, kind)
        val rnd = Random(1)
        repeat(200) {
            for (night in listOf(false, true)) {
                val s = WildSound.life(kind, night, false, rnd)
                assertTrue(s != Sound.BIRD && s != Sound.OWL, "Vogel im Tiefen Wald: $s")
            }
        }
        assertFalse(MapBirds.out(Story.deepForest, 1f, false), "pickende Vögel im Tiefen Wald")
        // the other wood still has its birds by day
        assertEquals(Sound.BIRD, WildSound.life(WildSound.kindOf(Story.forest), false, false, rnd))
        assertTrue(MapBirds.out(Story.forest, 1f, false))
    }

    @Test
    fun farSoundsOnlyInTheDeepForestAndTheCaveAndRare() {
        assertEquals(Sound.WOLF_FAR, WildSound.far(WildSound.Kind.DEEP_WOOD))
        assertEquals(Sound.RUMBLE, WildSound.far(WildSound.kindOf(Story.cave)))
        assertNull(WildSound.far(WildSound.kindOf(Story.forest)))
        assertNull(WildSound.far(WildSound.kindOf(Story.village)))
        val rnd = Random(2)
        repeat(500) {
            assertTrue(WildSound.firstFarMs(rnd) >= 20_000L)
            for (k in listOf(WildSound.Kind.DEEP_WOOD, WildSound.Kind.CAVE)) for (night in listOf(false, true))
                assertTrue(WildSound.farGapMs(k, night, rnd) >= 60_000L, "zu häufig: $k")
            assertTrue(WildSound.farVolume(Sound.WOLF_FAR, rnd) <= 0.35f)
        }
    }

    @Test
    fun smallLifeIsQuietAndNeverTwiceAlike() {
        val rnd = Random(5)
        val v = List(200) { WildSound.lifeVolume(rnd) }
        assertTrue(v.all { it in 0.2f..0.45f }, "zu laut oder zu leise")
        assertTrue(v.toSet().size > 150, "immer gleich laut (D29.1)")
    }

    @Test
    fun farSoundsComeFromOneSide() {
        val rnd = Random(3)
        repeat(200) {
            val side = WildSound.side(rnd)
            assertTrue(kotlin.math.abs(side) in 0.35f..0.85f, "nicht von der Seite: $side")
            val (l, r) = WildSound.speakers(0.3f, side)
            assertTrue(l > 0f && r > 0f && l <= 0.3f && r <= 0.3f)
            assertTrue(if (side > 0) r > l else l > r)
        }
    }

    @Test
    fun aBirdIsHeardOnceAsItFliesUp() {
        val map = Story.forest
        // a bird on the map with open ground to its west, from where the hero walks up to it
        var bird: Pair<Int, Int>? = null
        for (ty in 2 until map.height - 2) for (tx in 8 until map.width - 2) if (bird == null && MapBirds.at(map, tx, ty)) bird = tx to ty
        val (tx, ty) = assertNotNull(bird)
        val ear = WildSound.BirdEar(map)
        val by = (MapBirds.y(tx, ty) - 16).toInt()
        val far = (MapBirds.x(tx, ty) - 16 - 6 * WorldArt.T).toInt()
        assertTrue(ear.hear(0L, far, by, true).isEmpty(), "die erste Messung ist still")
        var flaps = 0
        var x = far
        var clock = 0L
        while (x < MapBirds.x(tx, ty) - 16) {
            clock += 100; x += 4
            flaps += ear.hear(clock, x, by, true).count { it.first == Sound.BIRD_FLAP && it.second > 0f }
        }
        assertTrue(flaps >= 1, "kein Flügelschlag beim Auffliegen")
        // a bird that is already up is not heard again, however long the hero stands there
        repeat(50) { clock += 100; assertTrue(ear.hear(clock, x, by, true).none { it.first == Sound.BIRD_FLAP }) }
        // not by night or in the rain
        assertTrue(ear.hear(clock + 100, far, by, false).isEmpty())
    }
}
