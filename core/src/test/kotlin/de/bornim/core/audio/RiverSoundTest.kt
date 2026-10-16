package de.bornim.core.audio

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** D6.4: the river by the village is heard, loudest on the bridge; still water (the forest pond) stays silent. */
class RiverSoundTest {
    private val village = World.maps.getValue("village")

    @Test
    fun theVillageRiverRuns() {
        val river = RiverSound.running(village)
        assertTrue(river.size > 40, "Fluss am Dorf nicht gefunden: ${river.size} Felder")
        // on the bridge the rush is at its loudest
        val bridge = (0 until village.height).flatMap { y -> (0 until village.width).map { it to y } }
            .first { (x, y) -> village.tile(x, y) == Tile.BRIDGE }
        assertEquals(RiverSound.MAX, RiverSound.target(RiverSound.nearest(village, bridge.first, bridge.second)))
        // up on the square, far from the bank, nothing
        assertNull(RiverSound.nearest(village, 17, 5))
    }

    @Test
    fun stillWaterIsSilent() {
        for (m in World.maps.values) {
            val running = RiverSound.running(m).toSet()
            val water = (0 until m.height).flatMap { y -> (0 until m.width).map { it to y } }.filter { (x, y) -> m.tile(x, y) == Tile.WATER }
            // every running tile is water reaching the edge; the pond lies within its map and is not heard
            assertTrue(running.all { it in water }, "${m.id}: Fluss auf trockenem Feld")
            if (m.id != "village") assertTrue(running.isEmpty(), "${m.id}: stilles Wasser rauscht: ${running.size} Felder")
        }
    }

    @Test
    fun rushSwellsAndFadesWithoutAJump() {
        val tick = 100L
        val dists = (9 downTo 0).flatMap { d -> List(3) { d.toDouble() } } + List(20) { 0.0 } + (0..9).flatMap { d -> List(3) { d.toDouble() } }
        var cur = 0f
        val levels = dists.map { cur = RiverSound.approach(cur, RiverSound.target(it), tick); cur }
        val maxStep = levels.zipWithNext { a, b -> kotlin.math.abs(b - a) }.max()
        assertTrue(maxStep <= RiverSound.MAX * tick / Ambience.FADE_MS + 1e-6, "Sprung im Rauschen: $maxStep")
        assertEquals(0f, levels.first())
        assertEquals(RiverSound.MAX, levels[40])
        assertEquals(0f, levels.last(), "verklingt nicht")
    }
}
