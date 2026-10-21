package de.bornim.core

import de.bornim.core.InterludeClock.Kind
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 24.1: the black screen between places ends once all is drawn, never before it can be read; 267.1: it waits for the drawing, a bar shows a long wait. */
class InterludeClockTest {

    /** Runs a screen of [kind] in steps of 16 ms (one picture); [readyAt] when everything is drawn, [tapAt] a tap. */
    private fun run(kind: Kind, readyAt: Long, tapAt: Long? = null, long: Boolean = false, readMs: Long = 0): Pair<Long, List<InterludeClock.Look>> {
        val c = InterludeClock(kind, 1_000, readMs)
        val looks = mutableListOf<InterludeClock.Look>()
        var t = 0L
        while (true) {
            val l = c.at(1_000 + t, t >= readyAt, tapAt != null && t in tapAt until tapAt + 16, long)
            looks += l
            if (l.done) return t to looks
            t += 16
            check(t < InterludeClock.HOLD_MS + 10_000) { "never ends" }
        }
    }

    @Test fun everyScreenWaitsForTheDrawingButNotForever() {
        for (k in Kind.entries) {
            val (end, _) = run(k, readyAt = Long.MAX_VALUE)
            assertTrue(end <= InterludeClock.HOLD_MS + 16, "$k ends at $end ms")
            assertTrue(end >= InterludeClock.HOLD_MS - 32, "$k waits as long as it may, ends at $end ms")
        }
        val (end, _) = run(Kind.NAME, readyAt = 30_000)
        assertTrue(end in 30_000L..31_000L, "drawn after 30 s (the tablet): over at $end ms")
    }

    @Test fun aFightScreenStaysLongEnoughToReadItsWords() {
        // Rückläufer t63.1: drawn at once, the words still stay until they can be read; a tap ends it sooner
        val read = InterludeClock.readMs(80)
        assertTrue(read in 4_000L..5_000L, "80 letters: $read ms")
        val (end, looks) = run(Kind.FIGHT_SHORT, readyAt = 0, readMs = read)
        assertTrue(looks[((read - 100) / 16).toInt()].words == 1f, "the words are still there just before $read ms")
        assertTrue(end >= read, "over at $end ms")
        val (tapped, _) = run(Kind.FIGHT_SHORT, readyAt = 0, tapAt = 500, readMs = read)
        assertTrue(tapped < read - 2_000, "a tap ends it early, at $tapped ms")
    }

    @Test fun theBarShowsOnlyForALongWait() {
        assertTrue(run(Kind.FULL, readyAt = 2_500).second.all { it.bar == 0f }, "drawn within 3 s: no bar")
        val late = run(Kind.FULL, readyAt = 8_000).second
        assertEquals(0f, late[(2_900 / 16)].bar, "not yet at 2.9 s")
        assertEquals(1f, late[(3_400 / 16)].bar, "in after 3 s")
        val long = run(Kind.FULL, readyAt = 20_000, long = true).second
        assertEquals(1f, long[(400 / 16)].bar, "foreseen long: at once")
        assertTrue(run(Kind.BLINK, readyAt = 8_000).second.all { it.bar == 0f }, "a blink has no bar")
        for ((a, b) in long.zipWithNext()) assertTrue(kotlin.math.abs(b.bar - a.bar) < 0.15f, "the bar never jumps")
        assertEquals(0f, long.last().bar, "gone with the words")
    }

    @Test fun aWholeSentenceStaysLongEnoughToBeRead() {
        val c = InterludeClock(Kind.FULL, 0)
        c.at(0, ready = true)
        for (t in 0L..1_800L step 16) assertEquals(1f, c.at(t, ready = true).veil, "map hidden at $t ms")
        assertEquals(1f, c.at(1_000, ready = true).words)
        val (end, _) = run(Kind.FULL, readyAt = 0)
        assertTrue(end in 2_400L..3_000L, "drawn at once: over after ${end} ms")
    }

    @Test fun itLeavesSoonAfterAllIsDrawn() {
        val (end, _) = run(Kind.FULL, readyAt = 2_500)
        assertTrue(end in 2_500L..3_400L, "drawn at 2.5 s, over at $end ms")
    }

    @Test fun aTapSkipsButNotBeforeAllIsDrawn() {
        assertTrue(run(Kind.FULL, readyAt = 0, tapAt = 300).first < 1_200, "tap while drawn ends early")
        val (end, _) = run(Kind.FULL, readyAt = 2_000, tapAt = 300)
        assertTrue(end in 2_000L..2_800L, "tap before drawn waits for it, then goes at once: $end ms")
    }

    @Test fun theMapRisesOnlyAfterTheWordsFadeAndNothingJumps() {
        for (k in Kind.entries) for (ready in listOf(0L, 1_500L, Long.MAX_VALUE)) {
            val looks = run(k, ready).second
            for ((a, b) in looks.zipWithNext()) {
                assertTrue(b.veil <= a.veil, "$k: the veil never comes back")
                assertTrue(kotlin.math.abs(b.veil - a.veil) < 0.15f && kotlin.math.abs(b.words - a.words) < 0.15f, "$k: no jump between two pictures")
            }
            assertTrue(looks.all { it.veil >= 0.99f || it.words <= 0.5f }, "$k: the map shows only once the words are mostly gone")
        }
    }

    @Test fun aLongWaitTurnsTheSentenceIntoASayingThatCanBeRead() {
        val long = run(Kind.FULL, readyAt = 20_000, long = true).second
        assertEquals(0f, long[(3_400 / 16)].quote, "the sentence first")
        assertEquals(1f, long[(5_000 / 16)].quote, "then the saying")
        for ((a, b) in long.zipWithNext()) assertTrue(b.quote >= a.quote && b.quote - a.quote < 0.15f, "it turns slowly, never back")
        assertTrue(run(Kind.FULL, readyAt = 20_000).second.all { it.quote == 0f }, "no saying without a long wait")
        assertTrue(run(Kind.FULL, readyAt = 3_000, long = true).second.all { it.quote == 0f }, "drawn before: no saying, no longer wait")
        val (end, _) = run(Kind.FULL, readyAt = 4_000, long = true)
        assertTrue(end >= InterludeClock.QUOTE_AFTER_MS + InterludeClock.QUOTE_READ_MS, "the saying stays to be read: over at $end ms")
        assertTrue(run(Kind.FULL, readyAt = 4_000, tapAt = 5_000, long = true).first < 6_000, "a tap still ends it")
    }

    @Test fun whichScreenWhere() {
        assertEquals(Kind.FULL, InterludeClock.kindFor(null, "village", firstVisit = false, readyNow = true))
        assertEquals(Kind.FULL, InterludeClock.kindFor("village", "forest", firstVisit = true, readyNow = true))
        assertEquals(Kind.BLINK, InterludeClock.kindFor("village", "inn", firstVisit = false, readyNow = true))
        assertEquals(Kind.NAME, InterludeClock.kindFor("village", "inn", firstVisit = false, readyNow = false))
        assertEquals(Kind.NAME, InterludeClock.kindFor("forest", "village", firstVisit = false, readyNow = true))
    }
}
