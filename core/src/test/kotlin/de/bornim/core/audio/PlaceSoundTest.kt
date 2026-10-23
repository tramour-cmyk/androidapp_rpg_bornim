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
        // at chance only a cough and the wood; wiping, pouring, cup and chair come with the movements (D1.10)
        val ev = PlaceSound.events(PlaceSound.Kind.TAVERN, present).map { it.first }.toSet()
        assertEquals(setOf(Sound.COUGH, Sound.CREAK), ev)
        assertEquals(listOf(Sound.CREAK), PlaceSound.events(PlaceSound.Kind.TAVERN, emptyList()).map { it.first })
        // over ten minutes both of them are heard at work: Rowena wipes and pours, Borin sets down his flask and shifts
        val heard = PlaceSound.folk(Story.inn, st, 0L, 600_000L, 8, 8, 0L).toSet()
        assertEquals(setOf(Sound.WIPE, Sound.POUR, Sound.CUP, Sound.CHAIR), heard)
    }

    @Test
    fun theInnSoundsComeWithTheMovements() {
        val rowena = de.bornim.core.art.MapFolk.of("rowena")!!
        val borin = de.bornim.core.art.MapFolk.of("borin")!!
        var wipes = 0; var pours = 0; var cups = 0; var chairs = 0
        // stepping the clock as the game does: each sound once, at the moment its movement begins (or the flask goes down)
        for (t in 0L until 1_200_000L step 100L) {
            for (s in de.bornim.core.art.MapFolk.sounds(rowena, t, t + 100)) {
                val d = de.bornim.core.art.MapFolk.doing(rowena, t + 100)
                when (s) {
                    Sound.WIPE -> { wipes++; assertEquals(de.bornim.core.art.MapFolk.Idle.WIPE, d?.idle, "Wischen ohne Bewegung bei $t") }
                    Sound.POUR -> { pours++; assertEquals(de.bornim.core.art.MapFolk.Idle.POUR, d?.idle, "Einschenken ohne Krug bei $t") }
                    else -> error("Rowena: $s")
                }
            }
            for (s in de.bornim.core.art.MapFolk.sounds(borin, t, t + 100)) {
                val before = de.bornim.core.art.MapFolk.seatPoseAt(borin, t - 200)
                when (s) {
                    Sound.CUP -> { cups++; assertTrue(before.from == de.bornim.core.art.MapFolk.Seat.DRINK || before.to == de.bornim.core.art.MapFolk.Seat.DRINK, "Becher ohne Trinken bei $t: $before") }
                    Sound.CHAIR -> { chairs++; assertEquals(de.bornim.core.art.MapFolk.Seat.LOOK, de.bornim.core.art.MapFolk.seatPoseAt(borin, t + 500).to, "Stuhl ohne Umdrehen bei $t") }
                    else -> error("Borin: $s")
                }
            }
        }
        assertTrue(wipes > 20 && pours > 15 && cups > 5 && chairs > 5, "Wischen $wipes, Einschenken $pours, Becher $cups, Stuhl $chairs in 20 min")
        // a hero standing right before her counter: she looks at him and does not work, so nothing is heard of her
        val near = PlaceSound.folk(Story.inn, st, 0L, 600_000L, 1, 3, 0L)
        assertTrue(Sound.WIPE !in near && Sound.POUR !in near)
    }

    @Test
    fun coughNeverTwiceInARowGapsUneven() {
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
        assertTrue(coughs in 900..1100, "Husten $coughs von 2000 (im Wechsel mit dem Knarren, bei 12–30 s Pause etwa jede dreiviertel Minute)")
        val gaps = List(200) { PlaceSound.gapMs(PlaceSound.Kind.TAVERN, rnd) }
        assertTrue(gaps.all { it in 12000L..30000L } && gaps.toSet().size > 50)
        assertTrue(PlaceSound.firstMs(PlaceSound.Kind.TAVERN, rnd) < 2500L)
    }

    /** 334 (Chef, B81): back from the menu in the inn, no creak or cough at once; only arriving brings the first one soon. */
    @Test
    fun backFromTheMenuIsNoArrival() {
        val rnd = Random(3)
        for (k in PlaceSound.Kind.entries) repeat(50) {
            assertTrue(PlaceSound.firstMs(k, rnd, arrived = false) >= 12000L, "$k: gleich nach dem Menü ein Geräusch")
            assertTrue(PlaceSound.firstMs(k, rnd, arrived = true) < 5000L, "$k: beim Ankommen zu spät")
        }
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

    @Test
    fun leavingDiesAwayWithoutAJump() {
        for (from in listOf(PlaceSound.BED_VOLUME, 0.5f, 0.05f)) {
            var v = from
            var t = 0L
            while (v > 0f) {
                t += 50
                val n = PlaceSound.leaving(from, t)
                assertTrue(n <= v && v - n <= from * 50 / PlaceSound.LEAVE_FADE_MS + 1e-6f, "Sprung bei $t ms")
                v = n
            }
            assertTrue(t == PlaceSound.LEAVE_FADE_MS, "still nach $t ms")
        }
    }
}
