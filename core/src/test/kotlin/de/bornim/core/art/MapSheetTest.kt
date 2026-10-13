package de.bornim.core.art

import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The drawn map for the menu (Vorrat 8, draft). */
class MapSheetTest {
    private fun red(c: Int) = ((c shr 16) and 0xFF) > 150 && ((c shr 8) and 0xFF) < 80

    @Test
    fun everyPlaceIsDrawnWithTheHeroInRed() {
        // the former pixel sheet (the ink sheet, on since 62h/62o, has no hero mark of its own: the menu draws it)
        MapSheet.ink = false
        try { for (id in listOf("village", "inn", "shop", "elder", "temple", "forest", "deep_forest", "cave")) {
            val m = World[id]
            val img = MapSheet.render(m, { _, _ -> true }, 2, 2)
            assertEquals(m.width * MapSheet.C + 2 * MapSheet.PAD, img.width)
            val c = MapSheet.PAD + 2 * MapSheet.C + MapSheet.C / 2
            assertTrue(red(img[c, c]), "$id: hero mark")
        } } finally { MapSheet.ink = true }
    }

    @Test
    fun unknownGroundStaysBareParchment() {
        val m = World["forest"]
        MapSheet.ink = false
        val known = MapSheet.render(m, { _, _ -> true })
        val none = MapSheet.render(m, { _, _ -> false })
        MapSheet.ink = true
        // a tree tile far from the frame: drawn when known, bare parchment when not
        val x = MapSheet.PAD + 0 * MapSheet.C + MapSheet.C / 2; val y = MapSheet.PAD + 10 * MapSheet.C + MapSheet.C / 2
        assertTrue(known[x, y] != none[x, y])
        val parch = (0 until MapSheet.C).all { k -> val p = none[MapSheet.PAD + 10 * MapSheet.C + k, y]; ((p shr 16) and 0xFF) > 150 }
        assertTrue(parch)
    }
}
