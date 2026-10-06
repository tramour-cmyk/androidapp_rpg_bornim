package de.bornim.core

import de.bornim.core.art.CaveScene
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class CaveSceneTest {
    private val cave = Story.cave

    @Test
    fun placesFollowTheMap() {
        assertEquals(CaveScene.Spot.ENTRANCE, CaveScene.spotFor(cave, 10, 17))
        assertEquals(CaveScene.Spot.CAMP, CaveScene.spotFor(cave, 16, 14))
        assertEquals(CaveScene.Spot.TUNNEL, CaveScene.spotFor(cave, 10, 6))
        assertEquals(CaveScene.Light.TORCH, CaveScene.lightFor(cave, 8, 2, CaveScene.spotFor(cave, 8, 2)))
    }

    @Test
    fun everyPlaceAndLightDraws() {
        for (spot in CaveScene.Spot.entries) for (light in CaveScene.Light.entries) for (night in listOf(false, true)) {
            val img = CaveScene.cave(270, 400, spot, light, 3, night)
            // no black holes from bad maths: most of the picture has some light
            val lit = img.pixels.count { ((it shr 16) and 0xFF) + ((it shr 8) and 0xFF) + (it and 0xFF) > 24 }
            assertTrue(lit > img.pixels.size / 3, "$spot $light $night too dark: $lit")
        }
    }
}
