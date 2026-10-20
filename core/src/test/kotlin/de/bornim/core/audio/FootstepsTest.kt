package de.bornim.core.audio

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** The hero's steps (74): the right ground, one sound a footfall, quieter running. */
class FootstepsTest {
    @Test
    fun theGroundDecides() {
        val village = World["village"]
        assertEquals(Sound.STEP_GRASS, Footsteps.sound(village, Tile.GRASS))
        assertEquals(Sound.STEP_EARTH, Footsteps.sound(village, Tile.PATH))
        assertEquals(Sound.STEP_COBBLE, Footsteps.sound(village, Tile.COBBLE))
        assertEquals(Sound.STEP_WOOD, Footsteps.sound(village, Tile.BRIDGE))
        assertEquals(Sound.STEP_WOOD, Footsteps.sound(World["inn"], Tile.WOOD_FLOOR))
        assertEquals(Sound.STEP_COBBLE, Footsteps.sound(World["temple"], Tile.WOOD_FLOOR))
        assertEquals(Sound.STEP_STONE, Footsteps.sound(World["cave"], Tile.CAVE_FLOOR))
        assertTrue(Footsteps.volume(Tile.GRASS, running = true) < Footsteps.volume(Tile.GRASS, running = false))
    }

    @Test
    fun oneSoundEachFootfall() {
        val feet = Footsteps.Feet()
        assertFalse(feet.fell(0.0))
        var n = 0; var w = 0.0
        // ten tiles in small steps: ten footfalls, never two at once
        while (w < 10.0) { w += 0.03; if (feet.fell(w)) n++ }
        assertEquals(10, n)
        // standing still, nothing
        repeat(20) { assertFalse(feet.fell(w)) }
        // 245: running, the stride reaches further: nine tiles, six footfalls
        n = 0; val from = w
        while (w < from + 9.0 - 1e-9) { w += 0.03; if (feet.fell(w, run = true)) n++ }
        assertEquals(6, n)
    }
}
