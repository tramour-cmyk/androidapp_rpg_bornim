package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

class MapRestTest {
    /** Everyone breathes and now and then shifts, glances or rests the hands, never in step with a neighbour. */
    @Test
    fun restingVariesAndKeepsNoBeat() {
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
        assertTrue(seen == MapRest.Rest.entries.toSet(), "missing: ${MapRest.Rest.entries - seen}")
        assertTrue(same * 4 < total, "two figures move together too often: $same of $total")
        // about one breath in 4 s, in and out
        assertTrue(breaths in 250..350, "breaths: $breaths")
    }
}
