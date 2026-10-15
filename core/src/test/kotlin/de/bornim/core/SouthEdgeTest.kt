package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 67: the south road out of Bornim turns the hero back, with a line by how far the story is. */
class SouthEdgeTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        return g
    }

    private fun tryLeave(g: Game): String? {
        g.state.place = Place("village", 17, 30, Facing.DOWN)
        g.notices.clear()
        assertEquals(Move.Blocked, g.move(Facing.DOWN))
        assertEquals(Place("village", 17, 30, Facing.DOWN), g.state.place)
        assertEquals(Facing.UP, g.stepBack)
        g.stepBack = null
        val said = (g.mode as? Mode.Dialog)?.text
        if (said != null) g.advance() else assertEquals(1, g.notices.size)
        return said ?: g.notices.first()(Lang.DE)
    }

    @Test
    fun turnsBackLongOnceThenShortInEachPart() {
        val g = game()
        val v = World["village"]
        assertTrue(v.walkable(17, 29, g.state) && v.signs.containsKey(19 to 29))
        assertTrue(tryLeave(g)!!.startsWith("Du bist von Süden gekommen"))
        assertEquals("Erst willst du wissen, was in Bornim geschehen ist.", tryLeave(g))
        g.state.flags += Story.QUEST_STARTED
        assertEquals("Lyra ist irgendwo im Norden. Der Weg nach Süden kann warten.", tryLeave(g))
        assertEquals("Der Weg nach Süden kann warten.", tryLeave(g))
        g.state.flags += Story.CHAPTER1_DONE
        assertTrue(tryLeave(g)!!.startsWith("Der Brief mit dem grauen Siegel"))
        assertEquals("Die Antwort liegt nicht im Süden.", tryLeave(g))
        assertEquals(Mode.Explore, g.mode)
        // 68p: after Lyra spoke of the camp in the south the edge says plainly that the road comes later
        g.state.flags += Story.CAMP_TOLD
        assertEquals("Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.", tryLeave(g))
        assertEquals("Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.", tryLeave(g))
        assertEquals(Mode.Explore, g.mode)
    }
}
