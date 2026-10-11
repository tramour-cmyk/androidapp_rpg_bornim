package de.bornim.core.audio

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.Story
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 24.8: every place has its sound, only from what is there; the inn has no crowd, the bed never jumps. */
class PlaceSoundTest {
    private val st = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun eachPlaceItsSound() {
        assertEquals(Sound.WIND, PlaceSound.bed(PlaceSound.kindOf(Story.village)))
        assertEquals(Sound.WIND, PlaceSound.bed(PlaceSound.kindOf(Story.forest)))
        assertEquals(Sound.HALL, PlaceSound.bed(PlaceSound.kindOf(Story.temple)))
        assertEquals(null, PlaceSound.bed(PlaceSound.kindOf(Story.inn)))
        assertEquals(null, PlaceSound.bed(PlaceSound.kindOf(Story.cave)))
        // nothing but drops in the cave, nothing in the temple's stone hall
        assertTrue(PlaceSound.events(PlaceSound.kindOf(Story.cave), emptyList()).isEmpty())
        assertTrue(PlaceSound.events(PlaceSound.kindOf(Story.temple), listOf("priest")).isEmpty())
    }

    @Test
    fun theInnSoundsOfTheTwoWhoAreThere() {
        val present = PlaceSound.present(Story.inn, st)
        assertTrue("innkeeper" in present && "dwarf" in present, "Rowena und Borin: $present")
        val ev = PlaceSound.events(PlaceSound.Kind.TAVERN, present).map { it.first }.toSet()
        assertEquals(setOf(Sound.WIPE, Sound.POUR, Sound.CUP, Sound.CHAIR, Sound.COUGH, Sound.CREAK), ev)
        // without the innkeeper nobody wipes or pours; an empty inn only creaks
        val guests = PlaceSound.events(PlaceSound.Kind.TAVERN, listOf("dwarf")).map { it.first }
        assertTrue(Sound.WIPE !in guests && Sound.POUR !in guests)
        assertEquals(listOf(Sound.CREAK), PlaceSound.events(PlaceSound.Kind.TAVERN, emptyList()).map { it.first })
    }

    @Test
    fun coughRareNeverTwiceInARowGapsUneven() {
        val ev = PlaceSound.events(PlaceSound.Kind.TAVERN, listOf("innkeeper", "dwarf"))
        val rnd = Random(7)
        var last: Sound? = null
        var coughs = 0
        repeat(2000) {
            val s = PlaceSound.pick(ev, last, rnd)!!
            assertTrue(s != last, "zweimal $s hintereinander")
            if (s == Sound.COUGH) coughs++
            last = s
        }
        assertTrue(coughs in 40..200, "Husten $coughs von 2000 (selten, etwa jedes 10.–20.)")
        val gaps = List(200) { PlaceSound.gapMs(PlaceSound.Kind.TAVERN, rnd) }
        assertTrue(gaps.all { it in 3000L..8000L } && gaps.toSet().size > 50)
        assertTrue(PlaceSound.firstMs(PlaceSound.Kind.TAVERN, rnd) < 2500L)
    }

    @Test
    fun bedSwellsWithoutAJump() {
        var v = 0f
        var t = 0L
        while (v < PlaceSound.BED_VOLUME) {
            val n = PlaceSound.approach(v, PlaceSound.BED_VOLUME, 100)
            assertTrue(n - v <= PlaceSound.BED_VOLUME * 100 / PlaceSound.BED_FADE_MS.toFloat() + 1e-6f)
            v = n; t += 100
        }
        assertTrue(t in PlaceSound.BED_FADE_MS.toLong()..PlaceSound.BED_FADE_MS.toLong() + 100, "voll nach $t ms")
    }
}
