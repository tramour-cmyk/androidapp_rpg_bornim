package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class FogTest {
    private fun game(place: Place): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.ROGUE), Lang.DE, Dice(Random(2)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        g.state.place = place
        g.state.minutes = 12 * 60
        return g
    }

    @Test
    fun coneInFrontCircleAroundNothingBehind() {
        val g = game(Place("forest", 10, 20, Facing.UP))
        assertEquals(Fog.VISIBLE, g.fog(10, 16), "ahead")
        assertEquals(Fog.VISIBLE, g.fog(10, 21), "right behind")
        assertEquals(Fog.HIDDEN, g.fog(10, 24), "far behind")
        assertEquals(Fog.HIDDEN, g.fog(10, 10), "too far ahead")
    }

    @Test
    fun treesBlockTheView() {
        // In the forest a row of trees stands at (11..13, 12); the hero looks north at it from (12, 14).
        val g = game(Place("forest", 12, 14, Facing.UP))
        assertEquals(Tile.TREE, g.map.tile(12, 12))
        assertEquals(Fog.VISIBLE, g.fog(12, 13), "in front of the trees")
        assertEquals(Fog.VISIBLE, g.fog(12, 12), "the tree itself")
        assertEquals(Fog.HIDDEN, g.fog(12, 11), "behind the tree")
    }

    @Test
    fun exploredStaysSeenAndIsSaved() {
        val g = game(Place("forest", 10, 20, Facing.UP))
        assertEquals(Fog.VISIBLE, g.fog(10, 16))
        g.face(Facing.DOWN)
        assertEquals(Fog.SEEN, g.fog(10, 16))
        val loaded = GameState.fromJson(g.state.toJson())
        val g2 = Game(loaded, Lang.DE)
        loaded.place = Place("forest", 10, 26, Facing.DOWN)
        assertEquals(Fog.SEEN, g2.fog(10, 16))
        assertEquals(Fog.HIDDEN, g2.fog(17, 4))
    }

    @Test
    fun villagesHaveNoFogAndHiddenPlacesCannotBeTapped() {
        assertEquals(Fog.VISIBLE, game(Place("village", 11, 7, Facing.DOWN)).fog(0, 0))
        val g = game(Place("forest", 10, 20, Facing.UP))
        assertNull(g.route(10, 26))
        assertTrue(g.route(10, 17) != null)
    }
}
