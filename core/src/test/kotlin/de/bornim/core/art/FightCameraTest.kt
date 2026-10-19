package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 211.13: the one camera of the Kampfort, with the values of the pattern Sokrates passed (23:31). */
class FightCameraTest {
    /** The MARS scene on the A56: 412 dp wide at 2.625, the room above the log and the orders. */
    private val cam = FightCamera(1081, 1470)

    @Test
    fun theMiddleOfTheFightSitsWhereThePatternPutsIt() {
        val (x, y) = cam.feet(0.0, 0.0)
        assertEquals(cam.w / 2.0, x, 1.0)
        assertEquals(cam.h * 0.68, y, 1.0)
    }

    @Test
    fun everyPlaceIsInThePictureAndNearerMeansLower() {
        for (foe in listOf(false, true)) for (back in listOf(false, true)) for (slot in 0..1) for (alone in listOf(false, true)) {
            val (a, b) = FightCamera.stand(foe, back, slot, alone)
            val (x, y) = cam.feet(a, b)
            // 211.13 (Sokrates 23:31, 3): a hero alone in its row keeps clear of the left edge
            assertTrue(x > cam.w * 0.12 && x < cam.w * 0.9 && y > cam.h * 0.3 && y < cam.h * 0.97, "$foe $back $slot $alone at $x, $y")
        }
        val hero = FightCamera.stand(false, false, 0, true).let { (a, b) -> cam.feet(a, b) }
        val foe = FightCamera.stand(true, false, 0, true).let { (a, b) -> cam.feet(a, b) }
        assertTrue(hero.second > foe.second && hero.first < foe.first, "heroes lower left, foes upper right")
        val near = FightCamera.stand(false, false, 0, true).let { (a, b) -> cam.perCm(a, b) }
        val far = FightCamera.stand(true, true, 0, true).let { (a, b) -> cam.perCm(a, b) }
        assertTrue(near > far * 1.3, "the heroes nearer, so larger: $near against $far")
    }

    @Test
    fun theTwoSidesFaceEachOther() {
        val h = cam.yaw(-FightCamera.FRONT_M - FightCamera.NEAR_M, 0.0, false)
        val f = cam.yaw(FightCamera.FRONT_M, 0.0, true)
        // the heroes show us their backs half turned, the wolves their fronts
        assertTrue(kotlin.math.abs(h) > 120, "heroes $h")
        assertTrue(kotlin.math.abs(f) < 60, "foes $f")
        assertEquals(FightCamera.PITCH, cam.look(0.0, 0.0), 0.01)
    }

    @Test
    fun theKampforteAreDrawnInGoodTime() {
        // drawn once a fight, off the main thread; on the A56 about three times as long as here
        for (light in BattleScene.Light.entries) {
            val t0 = System.nanoTime()
            val img = Kampfort.forest(cam.w, cam.h, BattleScene.Spot.entries[light.ordinal * 2], light, false, 0)
            val ms = (System.nanoTime() - t0) / 1_000_000
            assertEquals(cam.w * cam.h, img.pixels.size)
            assertTrue(img.pixels.all { (it ushr 24) == 0xFF }, "every pixel covered")
            println("211.13 wood ${light}: $ms ms")
        }
        for (spot in CaveScene.Spot.entries) {
            val t0 = System.nanoTime()
            val img = Kampfort.cave(cam.w, cam.h, spot, CaveScene.Light.entries[spot.ordinal % 4], 72)
            println("211.13 cave $spot: ${(System.nanoTime() - t0) / 1_000_000} ms")
            assertTrue(img.pixels.all { (it ushr 24) == 0xFF })
        }
    }
}
