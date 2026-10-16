package de.bornim.core.audio

import de.bornim.core.MapKind
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The rain is heard (D3.10): out of doors as heavy as it falls, never indoors or in the cave, never jumping. */
class RainSoundTest {
    @Test
    fun outdoorsAsHeavyAsItFalls() {
        assertEquals(RainSound.MAX, RainSound.target(MapKind.FOREST, 1f, calm = true))
        assertEquals(RainSound.MAX / 2, RainSound.target(MapKind.TOWN, 0.5f, calm = true))
        assertEquals(0f, RainSound.target(MapKind.FOREST, 0f, calm = true))
    }

    @Test
    fun notUnderARoofNorInAFight() {
        assertEquals(0f, RainSound.target(MapKind.INTERIOR, 1f, calm = true))
        assertEquals(0f, RainSound.target(MapKind.CAVE, 1f, calm = true))
        assertEquals(0f, RainSound.target(MapKind.FOREST, 1f, calm = false))
    }

    @Test
    fun swellsAndFadesWithoutAJump() {
        var v = 0f
        var steps = 0
        while (v < RainSound.MAX) { val next = RainSound.approach(v, RainSound.MAX, 100); assertTrue(next - v <= RainSound.MAX / 10 + 1e-6f); v = next; steps++ }
        assertEquals(10, steps)
        assertEquals(0f, RainSound.approach(0.01f, 0f, 100))
    }

    @Test
    fun rainAndThunderFromRecordings() {
        assertTrue(Sound.RAIN in Sfx.RECORDED_ONLY)
        assertEquals(3, Recorded.TAKES[Sound.RAIN])
        assertEquals(3, Recorded.TAKES[Sound.THUNDER])
    }
}
