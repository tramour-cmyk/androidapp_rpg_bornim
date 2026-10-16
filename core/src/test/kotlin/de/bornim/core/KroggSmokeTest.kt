package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** D4.1: Garrick sends the hero to Morwen before Krogg, she gives a smoke bundle once, the chronicle keeps the task. */
class KroggSmokeTest {
    private fun state() = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    private fun talk(s: GameState, map: String, who: String) = World[map].npcs.first { it.id == who }.talk(s)
    private fun lines(cmds: List<Cmd>) = cmds.filterIsInstance<Cmd.Say>().map { it.text.de }

    @Test
    fun `Garrick points to Morwen and warns a weak hero`() {
        val s = state().apply { flags += Story.HUNTER_MET }
        val said = lines(talk(s, "forest", "garrick"))
        assertTrue(said.any { it.startsWith("Ich habe Goblins belauscht. Ihr Grottenschrat Krogg") })
        assertTrue(said.any { it.startsWith("Geh nicht mit leeren Händen") })
        assertTrue(said.any { it.startsWith("Und ehrlich") }, "level 1: warned")
        assertTrue(Cmd.SetFlag(Story.KROGG_HINT) in talk(s, "forest", "garrick"))
        s.hero.level = Story.KROGG_WARN_BELOW
        assertFalse(lines(talk(s, "forest", "garrick")).any { it.startsWith("Und ehrlich") }, "level 3: no warning")
    }

    @Test
    fun `Morwen gives the smoke bundle once, only while Krogg lives`() {
        val s = state()
        assertFalse(Cmd.Give(Story.SMOKE_BUNDLE, 1) in talk(s, "deep_forest", "morwen"), "not before Garrick")
        s.flags += Story.HUNTER_MET
        val first = talk(s, "deep_forest", "morwen")
        assertTrue(Cmd.Give(Story.SMOKE_BUNDLE, 1) in first, "first meeting brings it too")
        s.flags += Story.HERBALIST_MET
        assertTrue(Cmd.Give(Story.SMOKE_BUNDLE, 1) in talk(s, "deep_forest", "morwen"), "later visit before it was given")
        s.flags += Story.SMOKE_GIVEN
        assertFalse(Cmd.Give(Story.SMOKE_BUNDLE, 1) in talk(s, "deep_forest", "morwen"), "only once")
        val late = state().apply { flags += setOf(Story.HUNTER_MET, Story.HERBALIST_MET, Story.KROGG_DEFEATED) }
        assertFalse(Cmd.Give(Story.SMOKE_BUNDLE, 1) in talk(late, "deep_forest", "morwen"), "not after Krogg fell")
    }

    @Test
    fun `the chronicle carries the task until the bundle or Krogg's fall`() {
        val s = state()
        assertTrue(Chronicle.openTasks(s).isEmpty())
        s.flags += Story.KROGG_HINT
        assertEquals(listOf("rauch"), Chronicle.openTasks(s).map { it.id })
        assertTrue(Chronicle.fresh(s))
        Chronicle.markRead(s)
        assertFalse(Chronicle.fresh(s))
        s.flags += Story.SMOKE_GIVEN
        assertTrue(Chronicle.openTasks(s).isEmpty())
        assertEquals(listOf("rauch"), Chronicle.doneTasks(s).map { it.id })
        val fell = state().apply { flags += setOf(Story.KROGG_HINT, Story.KROGG_DEFEATED) }
        assertTrue(Chronicle.openTasks(fell).isEmpty())
    }

    @Test
    fun `the whole talk with Morwen puts the bundle in the bag`() {
        val s = state().apply { flags += Story.HUNTER_MET }
        val game = Game(s, Lang.DE)
        game.enqueue(talk(s, "deep_forest", "morwen"))
        repeat(40) { if (game.mode is Mode.Dialog) game.advance() }
        assertEquals(1, s.count(Story.SMOKE_BUNDLE))
        assertTrue(s.has(Story.SMOKE_GIVEN))
    }

    @Test
    fun `the bag shows the freed text`() {
        assertEquals("Ein Bündel beißender Kräuter von Morwen. Krogg vor die Füße werfen: Der Rauch nimmt ihm den ersten Hieb. Nur im Kampf.",
            Items[Story.SMOKE_BUNDLE].desc.de)
    }
}
