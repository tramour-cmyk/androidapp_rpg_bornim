package de.bornim.core

import de.bornim.core.art.MapGrade
import de.bornim.core.art.Pal
import de.bornim.core.art.PixelImage
import de.bornim.core.art.argb
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

class MapGradeTest {
    private fun sat(c: Int): Int {
        val r = (c shr 16) and 0xFF; val g = (c shr 8) and 0xFF; val b = c and 0xFF
        return maxOf(r, g, b) - minOf(r, g, b)
    }

    @Test
    fun brightMapColorsBecomeMuted() {
        for (c in listOf(Pal.GRASS, Pal.WATER, Pal.ROOF, Pal.ROOF_BLUE, Pal.PATH, Pal.PLASTER)) {
            val g = MapGrade.color(c)
            assertTrue(sat(g) < sat(c), "color ${Integer.toHexString(c)} should lose saturation")
        }
        // the map grass lands close to the battle grass
        assertTrue(MapGrade.distance(MapGrade.color(Pal.GRASS), argb(0x52703A)) < 12)
    }

    @Test
    fun lightSourcesKeepTheirColor() {
        for (c in listOf(Pal.FIRE, Pal.FIRE_LIGHT, argb(0x48C8C0), argb(0xA078E8)))
            assertTrue(MapGrade.distance(MapGrade.color(c), c) < 12, "light ${Integer.toHexString(c)} must keep shining")
    }

    @Test
    fun outlinesTakeTheDarkenedOwnColor() {
        val img = PixelImage(3, 1)
        img.set(0, 0, Pal.OUTLINE); img.set(1, 0, Pal.GRASS); img.set(2, 0, 0)
        val g = MapGrade.grade(img)
        assertNotEquals(Pal.OUTLINE, g[0, 0])
        // darker than the grass beside it, and greenish rather than the old grey-violet line
        val line = g[0, 0]; val grass = g[1, 0]
        assertTrue((line shr 8 and 0xFF) < (grass shr 8 and 0xFF))
        assertTrue((line shr 8 and 0xFF) >= (line and 0xFF))
        assertEquals(0, g[2, 0])
    }
}
