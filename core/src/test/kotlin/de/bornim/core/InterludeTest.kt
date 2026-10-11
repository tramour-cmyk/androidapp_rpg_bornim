package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class InterludeTest {
    private fun state() = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)

    @Test fun everyPlaceHasLinesInBothLanguages() {
        for (id in World.maps.keys) {
            val lines = Interlude.places[id] ?: continue
            assertTrue(lines.size >= 5, "$id: at least five sentences")
            for (l in lines) assertTrue(l.text.de.isNotBlank() && l.text.en.isNotBlank(), "$id: ${l.text.de}")
        }
        for (id in Interlude.places.keys) assertTrue(id in World.maps, "unknown map $id")
    }

    @Test fun neverTheSameSentenceTwiceInARow() {
        val r = Random(3)
        val lines = Interlude.placeLines("village", state(), isNight = false)
        var last: T? = null
        repeat(200) { val p = Interlude.pick(lines, last, r)!!; assertTrue(p != last); last = p }
    }

    @Test fun nightAndStoryLines() {
        val s = state()
        val night = Interlude.places.getValue("village").first { it.night == true }.text
        assertTrue(night !in Interlude.placeLines("village", s, isNight = false))
        assertTrue(night in Interlude.placeLines("village", s, isNight = true))
        val bare = Interlude.places.getValue("temple").first { it.needs != null }.text
        assertTrue(bare !in Interlude.placeLines("temple", s, false))
        s.flags += Story.QUEST_STARTED
        assertTrue(bare in Interlude.placeLines("temple", s, false))
        s.flags += Story.LYRA_RESCUED
        assertTrue(bare !in Interlude.placeLines("temple", s, false))
    }

    @Test fun nothingToPickGivesNull() = assertEquals(null, Interlude.pick(emptyList(), null))
}
