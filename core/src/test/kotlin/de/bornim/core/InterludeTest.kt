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

    @Test fun everyFightStartAndEveryFoeHasLinesInBothLanguages() {
        for (st in Interlude.Start.values()) {
            val lines = Interlude.openings[st].orEmpty()
            assertTrue(lines.size >= 11, "$st: at least eleven sentences (290)")
            for (l in lines) assertTrue(l.de.isNotBlank() && l.en.isNotBlank(), "$st: ${l.de}")
        }
        for (m in Monsters.all) {
            val lines = Interlude.foes[m.id].orEmpty()
            assertTrue(lines.size >= 5, "${m.id}: at least five sentences")
            for (l in lines) assertTrue(l.de.isNotBlank() && l.en.isNotBlank() && '{' !in l.de && '{' !in l.en, "${m.id}: ${l.de}")
        }
        for (id in Interlude.foes.keys) Monsters[id]
    }

    /** 24.6: the first line fits how the fight begins; the foe's own line only face to face while waiting, a boss always. */
    @Test fun fightWordsFollowTheStart() {
        val r = kotlin.random.Random(6)
        val amb = Interlude.fightWords(Opening.AMBUSHED, pack = false, foeId = "wolf", boss = false, full = true, random = r)
        assertTrue(amb.start in Interlude.openings.getValue(Interlude.Start.AMBUSH)); assertEquals(null, amb.foe)
        val first = Interlude.fightWords(Opening.HERO_FIRST, false, "goblin", false, true, random = r)
        assertTrue(first.start in Interlude.openings.getValue(Interlude.Start.HERO_FIRST)); assertEquals(null, first.foe)
        val pack = Interlude.fightWords(Opening.NORMAL, true, "wolf", false, true, random = r)
        assertTrue(pack.start in Interlude.openings.getValue(Interlude.Start.PACK)); assertTrue(pack.foe in Interlude.foes.getValue("wolf"))
        assertEquals(null, Interlude.fightWords(Opening.NORMAL, false, "goblin", false, full = false, random = r).foe, "short: no third line")
        val boss = Interlude.fightWords(Opening.AMBUSHED, false, "bugbear", boss = true, full = false, random = r)
        assertTrue(boss.foe in Interlude.foes.getValue("bugbear"), "a boss always has its line")
        // never the same sentence twice in a row
        var last: T? = null
        repeat(40) { val w = Interlude.fightWords(Opening.NORMAL, false, "goblin", false, false, last, random = r); assertTrue(w.start != last); last = w.start }
    }

    /** 24.6: a fight whose pictures are all drawn is over in about a second; one that waits holds, a boss is long. */
    @Test fun fightScreenTimes() {
        fun total(kind: InterludeClock.Kind, readyAt: Long): Long {
            val c = InterludeClock(kind, 0)
            var t = 0L
            while (!c.at(t, t >= readyAt).done) t += 16
            return t
        }
        assertEquals(InterludeClock.Kind.FIGHT_SHORT, InterludeClock.fightKind(ambushed = false, boss = false, readyNow = true))
        assertEquals(InterludeClock.Kind.AMBUSH, InterludeClock.fightKind(ambushed = true, boss = false, readyNow = true))
        assertEquals(InterludeClock.Kind.BOSS, InterludeClock.fightKind(ambushed = true, boss = true, readyNow = true))
        assertEquals(InterludeClock.Kind.FIGHT, InterludeClock.fightKind(ambushed = false, boss = false, readyNow = false))
        assertTrue(total(InterludeClock.Kind.FIGHT_SHORT, 0) in 900L..1_300L, "short: about a second")
        assertTrue(total(InterludeClock.Kind.FIGHT, 6_000) >= 6_000, "waits for the pictures")
        assertTrue(total(InterludeClock.Kind.BOSS, 0) > total(InterludeClock.Kind.FIGHT, 0))
        // the ambush's words are there at once
        assertEquals(1f, InterludeClock(InterludeClock.Kind.AMBUSH, 0).at(0, false).words)
    }

    @Test fun nothingToPickGivesNull() = assertEquals(null, Interlude.pick(emptyList(), null))
}
