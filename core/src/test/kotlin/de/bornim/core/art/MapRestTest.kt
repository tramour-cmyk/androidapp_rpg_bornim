package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MapRestTest {
    /** Everyone breathes and now and then shifts, glances or rests the hands, never in step with a neighbour. */
    @Test
    fun restingVariesAndKeepsNoBeat() {
        // the draft switch is shared with other tests and on in the game: off here, then back as it was
        val was = MapRest.draft
        MapRest.draft = false
        try { resting() } finally { MapRest.draft = was }
    }

    private fun resting() {
        val seen = mutableSetOf<MapRest.Rest>()
        var same = 0; var total = 0; var breaths = 0; var lastBreath = 0
        for (t in 0L until 600_000L step 100L) {
            val (a, ba) = MapRest.at(11, t, handsFree = true, mayLook = true)
            val (b, _) = MapRest.at(12, t, handsFree = true, mayLook = true)
            seen += a
            if (a != MapRest.Rest.NEUTRAL || b != MapRest.Rest.NEUTRAL) { total++; if (a == b) same++ }
            if (ba != lastBreath) { breaths++; lastBreath = ba }
            // a hero with a weapon never puts its hands to the belt; one watching never glances away
            val (h, _) = MapRest.at(11, t, handsFree = false, mayLook = false)
            assertTrue(!h.handsFree && !h.looks)
        }
        // the arms crossed and the hands behind the back only with the draft (55.1), the spear grounded only by a spear bearer (55.1b)
        val drafted = setOf(MapRest.Rest.ARMS, MapRest.Rest.BACK, MapRest.Rest.SPEAR)
        assertTrue(seen == MapRest.Rest.entries.toSet() - drafted, "missing: ${MapRest.Rest.entries - drafted - seen}, unexpected: ${seen intersect drafted}")
        MapRest.draft = true
        try {
            val more = (0L until 600_000L step 100L).map { MapRest.at(11, it, handsFree = true, mayLook = true).first }.toSet()
            assertTrue(more == MapRest.Rest.entries.toSet() - MapRest.Rest.SPEAR, "with the draft missing: ${MapRest.Rest.entries - MapRest.Rest.SPEAR - more}")
            // a spear bearer keeps his hands on the spear: grounds it now and then, never to the belt
            val guard = (0L until 600_000L step 100L).map { MapRest.at(11, it, handsFree = false, mayLook = true, spear = true).first }.toSet()
            assertTrue(MapRest.Rest.SPEAR in guard && guard.none { it.handsFree }, "guard: $guard")
        } finally { MapRest.draft = false }
        assertTrue(same * 4 < total, "two figures move together too often: $same of $total")
        // about one breath in 4 s, in and out
        assertTrue(breaths in 250..350, "breaths: $breaths")
    }

    @Test
    fun aGuardGroundsHisSpearAtEachLongWatch() {
        // 55.1b (test of 0.1.662): no chance about it at a long stop; eased in and out without a jump; not at short stops
        val watch = 12_000L
        assertEquals(null, MapRest.spearWatch(3_000, 1_000, 4_000, 0))
        var last = 0
        for (t in 0L..watch step 20) {
            val p = MapRest.spearWatch(t, watch - t, watch, 0)!!
            val lv = if (p.rest == MapRest.Rest.SPEAR) p.level else 0
            assertTrue(kotlin.math.abs(lv - last) <= 1, "jump at $t ms: $last to $lv")
            last = lv
        }
        assertEquals(MapRest.Rest.SPEAR, MapRest.spearWatch(watch / 2, watch / 2, watch, 0)!!.rest)
        assertEquals(MapRest.LEVELS, MapRest.spearWatch(watch / 2, watch / 2, watch, 0)!!.level)
        assertEquals(0, last)
    }

    @Test
    fun theSpearLeavesTheShoulderStepByStep() {
        // 330 (film of 23.10.): every step between held the spear fully in the hand, so it fell onto the shoulder in one picture
        val base = HeroFigure.Rig()
        val aims = (0..MapRest.LEVELS).map { MapRest.rig(base, MapRest.Rest.SPEAR, 0, it).aim }
        assertEquals(base.aim, MapRest.rig(base, MapRest.Rest.SPEAR, 0, 0).aim)
        for (i in 1..MapRest.LEVELS) assertTrue(aims[i] > aims[i - 1] && aims[i] - aims[i - 1] <= 0.5, "aim by level: $aims")
    }
}
