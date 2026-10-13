package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 64: the chronicle's entries come with the story, newest first, and the dot at the tab goes once read. */
class ChronicleTest {
    @Test
    fun entriesFollowTheStoryAndTheDotGoesOnceRead() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        assertEquals(listOf("greif"), Chronicle.sofar(s).map { it.id })
        assertTrue(Chronicle.fresh(s))
        Chronicle.markRead(s)
        assertFalse(Chronicle.fresh(s))
        s.flags += Story.QUEST_STARTED; s.flags += Story.BARRIER_OPEN
        assertEquals(listOf("schlagbaum", "auftrag", "greif"), Chronicle.sofar(s).map { it.id })
        assertTrue(Chronicle.fresh(s))
        Chronicle.markRead(s)
        Jobs.take(s, Jobs["stones"])
        assertTrue(Chronicle.fresh(s))
        for (e in Chronicle.entries) assertFalse(e.text.de.contains("  ") || e.text.en.isBlank())
    }
}
