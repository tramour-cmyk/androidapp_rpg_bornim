package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

/** 19e: breathing begins again after each move; each figure keeps its own time. */
class BreathTest {
    @Test
    fun afterAMoveTheBreathingBeginsAtTheFirstPicture() {
        val b = Breath(500)
        assertEquals(17, b.index(1000, 86.0))
        for (t in 1000L..1400L step 16) b.moving(t)
        assertEquals(0, b.index(1400, 86.0))
        assertEquals(1, b.index(1500, 86.0))
    }

    @Test
    fun aPackDoesNotBreatheAsOne() {
        val wolves = listOf("wolf1", "wolf2", "wolf3").map { Breath(Breath.offset(it)) }
        val at = wolves.map { it.index(3000, 86.0) % 14 }
        assertNotEquals(1, at.toSet().size, "alle Wölfe im Gleichtakt: $at")
    }
}
