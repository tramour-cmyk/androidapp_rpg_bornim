package de.bornim.core

import de.bornim.core.audio.Sound
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** D3.1: the door creaks only where there is a door; cave mouths, paths and map edges stay silent. */
class DoorSoundTest {
    private fun crossing(map: String, x: Int, y: Int): Pair<String, Boolean> {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(2)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.place = Place(map, x, y, Facing.UP)
        g.sounds.clear()
        g.afterStep()
        // 215: a way out is taken with the action button, not by the step onto it
        assertEquals(map, g.state.place.map, "$map ($x,$y): the step alone does not leave")
        g.interact()
        return g.state.place.map to (Sound.DOOR in g.sounds)
    }

    @Test
    fun onlyDoorsCreak() {
        for ((id, m) in World.maps) for (w in m.warps) {
            val (now, door) = crossing(id, w.x, w.y)
            assertEquals(w.to.map, now, "$id (${w.x},${w.y}) leads on")
            assertEquals(m.tile(w.x, w.y) == Tile.DOOR, door, "$id (${w.x},${w.y}) ${m.tile(w.x, w.y)}")
        }
        assertTrue(crossing("inn", 4, 7).second, "leaving the inn creaks")
        assertFalse(crossing("forest", 10, 0).second, "the cave mouth has no door")
    }

    /** 215: the hero never arrives standing on a way out, so the button does not at once offer the way back. */
    @Test
    fun noWayLeadsOntoAnother() {
        for ((id, m) in World.maps) for (w in m.warps) {
            assertEquals(null, World[w.to.map].warpAt(w.to.x, w.to.y)?.let { "${w.to.map} (${w.to.x},${w.to.y})" }, "$id (${w.x},${w.y})")
        }
    }
}
