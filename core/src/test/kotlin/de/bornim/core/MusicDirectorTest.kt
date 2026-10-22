package de.bornim.core

import de.bornim.core.audio.MusicDirector
import de.bornim.core.audio.MusicLib
import de.bornim.core.audio.MusicScene
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** The choice of music per scene (28.1): no piece twice in a row, silence between pieces, fades, victory, cave bed. */
class MusicDirectorTest {
    @Test
    fun neverTheSamePieceTwiceAndQuietBetween() {
        for (seed in 0L until 50L) {
            val d = MusicDirector(seed)
            var t = 0L
            var w = d.update(MusicScene.FOREST, t)
            var prev = assertNotNull(w.music).name
            assertTrue(prev in MusicLib.forest)
            repeat(20) {
                t += 180_000 // the piece runs out
                w = d.update(MusicScene.FOREST, t, finished = prev)
                assertNull(w.music, "silence after a piece")
                // 10–30 s of silence
                assertNull(d.update(MusicScene.FOREST, t + MusicDirector.QUIET_MIN_MS - 1).music)
                t += MusicDirector.QUIET_MAX_MS
                val next = assertNotNull(d.update(MusicScene.FOREST, t).music).name
                assertNotEquals(prev, next, "seed $seed: same piece twice")
                assertTrue(next in MusicLib.forest)
                prev = next
            }
        }
    }

    @Test
    fun allPiecesComeUp() {
        val d = MusicDirector(1)
        val heard = HashSet<String>()
        var t = 0L
        var cur = d.update(MusicScene.VILLAGE, t).music!!.name
        heard += cur
        repeat(60) {
            t += 200_000; d.update(MusicScene.VILLAGE, t, finished = cur)
            t += 40_000; cur = d.update(MusicScene.VILLAGE, t).music!!.name; heard += cur
        }
        assertEquals(MusicLib.village.toSet(), heard)
    }

    @Test
    fun placeCrossfadesFightCutsInVictoryThenPlace() {
        val d = MusicDirector(7)
        val town = d.update(MusicScene.VILLAGE, 0)
        assertEquals(MusicDirector.PLACE_FADE_MS, town.fadeMs)
        val forest = d.update(MusicScene.FOREST, 1000)
        assertEquals(MusicDirector.PLACE_FADE_MS, forest.fadeMs)
        assertTrue(forest.music!!.name in MusicLib.forest)
        val fight = d.update(MusicScene.BATTLE, 2000)
        assertEquals(MusicDirector.FIGHT_FADE_MS, fight.fadeMs)
        assertTrue(fight.music!!.name in MusicLib.battle && fight.music!!.loop)
        d.victory()
        val won = d.update(MusicScene.FOREST, 60_000)
        assertEquals(MusicLib.victory, won.music)
        // victory runs out: silence, then the forest again
        assertNull(d.update(MusicScene.FOREST, 120_000, finished = MusicLib.victory.name).music)
        assertTrue(d.update(MusicScene.FOREST, 120_000 + MusicDirector.QUIET_MAX_MS).music!!.name in MusicLib.forest)
        // a fled fight: no victory piece
        d.update(MusicScene.BOSS, 300_000)
        assertNull(d.update(MusicScene.FOREST, 310_000).music)
    }

    @Test
    fun fightPiecesDifferFightToFight() {
        val d = MusicDirector(3)
        var t = 0L
        var prev: String? = null
        repeat(30) {
            val f = d.update(MusicScene.BATTLE, t).music!!.name
            assertNotEquals(prev, f)
            prev = f
            t += 1000; d.victory(); d.update(MusicScene.FOREST, t); t += 1000
        }
    }

    @Test
    fun caveHasABedAndMusicOnlyNowAndThen() {
        val d = MusicDirector(11)
        d.update(MusicScene.FOREST, 0)
        val inCave = d.update(MusicScene.CAVE, 1000)
        val bed = assertNotNull(inCave.bed)
        assertTrue(bed in MusicLib.caveBeds)
        assertNull(inCave.music, "the cave starts with the bed alone")
        assertNull(d.update(MusicScene.CAVE, 1000 + MusicDirector.CAVE_FIRST_MIN_MS - 1).music)
        val m = assertNotNull(d.update(MusicScene.CAVE, 1000 + MusicDirector.CAVE_FIRST_MAX_MS).music)
        assertTrue(m.name in MusicLib.cave)
        assertEquals(bed, d.update(MusicScene.CAVE, 100_000).bed, "the bed stays")
        // a fight: bed off; after it, the same bed again
        assertNull(d.update(MusicScene.BATTLE, 200_000).bed)
        d.victory()
        val after = d.update(MusicScene.CAVE, 230_000)
        assertEquals(bed, after.bed)
        assertEquals(MusicLib.victory, after.music)
        // out of the cave: bed off
        assertNull(d.update(MusicScene.FOREST, 300_000).bed)
    }

    @Test
    fun titleAndChapterEnd() {
        val d = MusicDirector(5)
        assertEquals(MusicLib.title, d.update(MusicScene.TITLE, 0).music)
        assertEquals(MusicLib.chapterEnd, d.update(MusicScene.CHAPTER_END, 10).music)
        // the chapter end plays once, then stays silent
        assertNull(d.update(MusicScene.CHAPTER_END, 200_000, finished = MusicLib.chapterEnd.name).music)
        assertNull(d.update(MusicScene.CHAPTER_END, 900_000).music)
    }

    @Test
    fun everyPieceIsInTheAssets() {
        val dir = java.io.File("../app/src/main/assets/music")
        if (!dir.isDirectory) return
        for (n in MusicLib.all) assertTrue(java.io.File(dir, "$n.ogg").isFile, "missing $n.ogg")
    }

    @Test
    fun theTitleMusicCarriesTheIntro() {
        // 69f: the title music goes on from the hero's making, quietly under the pictures, fuller with the black one
        val d = MusicDirector(3)
        assertEquals(1f, d.update(MusicScene.TITLE, 0).level)
        for (t in 0L..30_000L step 500L) {
            val w = d.update(MusicScene.INTRO, 1_000 + t)
            assertEquals(MusicLib.title, w.music, "the same piece runs on")
            assertEquals(MusicDirector.INTRO_LEVEL, w.level)
        }
        val black = d.update(MusicScene.TITLE, 40_000)
        assertEquals(MusicLib.title, black.music)
        assertEquals(1f, black.level)
        // in the inn: it dies away over about 6 s, only then the inn's music
        val inn = d.update(MusicScene.VILLAGE, 41_000)
        assertNull(inn.music)
        assertEquals(MusicDirector.TITLE_OUT_MS, inn.fadeMs)
        assertNull(d.update(MusicScene.VILLAGE, 41_000L + MusicDirector.TITLE_OUT_MS - 1).music)
        val later = d.update(MusicScene.VILLAGE, 41_000L + MusicDirector.TITLE_OUT_MS)
        assertTrue(later.music!!.name in MusicLib.village)
        assertEquals(MusicDirector.PLACE_FADE_MS, later.fadeMs)
    }

    @Test
    fun theIntroFromTheChronicleStartsTheTitleMusicQuietly() {
        // 69f: not playing (village music before) → the title music from the top, quietly
        val d = MusicDirector(4)
        d.update(MusicScene.VILLAGE, 0)
        val w = d.update(MusicScene.INTRO, 5_000)
        assertEquals(MusicLib.title, w.music)
        assertEquals(MusicDirector.INTRO_LEVEL, w.level)
        // skipped before the black picture: it dies away just the same
        assertNull(d.update(MusicScene.VILLAGE, 8_000).music)
        // a saved game in the cave: the bed at once, the music only after a while as always
        val c = MusicDirector(5)
        c.update(MusicScene.TITLE, 0)
        val cave = c.update(MusicScene.CAVE, 1_000)
        assertNotNull(cave.bed)
        assertNull(c.update(MusicScene.CAVE, 1_000 + MusicDirector.CAVE_FIRST_MIN_MS - 1).music)
    }

    @Test
    fun silentUnderTheFirmThenTheTitleMusic() {
        // 292.1 (Chef 22.10., 17:57): the firm's sound alone, a pause, then the title music with the game's name
        val d = MusicDirector(1)
        for (t in 0L..3_600L step 100) assertNull(d.update(MusicScene.PRELUDE, t).music, "silent at $t")
        assertEquals(MusicLib.title, d.update(MusicScene.TITLE, 3_700).music)
    }
}
