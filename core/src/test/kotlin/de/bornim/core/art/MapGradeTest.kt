package de.bornim.core.art

import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Idea 11 (draft): the colour mood of each place and hour points the right way and stays gentle. */
class MapGradeTest {
    private fun warmth(g: MapGrade.Grade) = g.red - g.blue

    @Test fun moods() {
        val cave = MapGrade.grade(World["cave"], 1f)
        val inn = MapGrade.grade(World["inn"], 1f)
        val noon = MapGrade.grade(World["village"], 1f)
        val dusk = MapGrade.grade(World["village"], 0.5f)
        val night = MapGrade.grade(World["village"], 0f)
        // the cave cold and greenish, the inn warm
        assertTrue(cave.green > cave.red && cave.blue < cave.green, "cave: green over red")
        assertTrue(warmth(inn) > 40, "inn warm: ${warmth(inn)}")
        // the dusk violet: blue above green, more tinted than noon
        assertTrue(dusk.blue > dusk.green && dusk.red > dusk.green, "dusk violet")
        assertTrue(dusk.amount > noon.amount && dusk.vignette > noon.vignette)
        assertTrue(warmth(night) < 0, "night cold")
        // never too strong: no channel tinted below about half, corners never black
        for (g in listOf(cave, inn, noon, dusk, night)) {
            assertTrue(g.amount <= 0.7f && g.vignette <= 0.45f, "gentle: $g")
            assertTrue(1 - g.amount * (1 - minOf(g.red, g.green, g.blue) / 255f) > 0.75f, "tint kept light: $g")
        }
    }

    @Test fun offLeavesThePictureAlone() {
        MapGrade.draft = false
        val g = MapGrade.of(World["cave"], 1f)
        val img = PixelImage(8, 8, IntArray(64) { 0xFF808080.toInt() })
        assertEquals(img.pixels.toList(), MapGrade.apply(img, g).pixels.toList())
        // on, the middle keeps its brightness while the corner darkens
        val on = MapGrade.apply(img, MapGrade.grade(World["cave"], 1f))
        assertTrue((on.pixels[4 * 8 + 4] and 0xFF) > (on.pixels[0] and 0xFF))
    }
}
