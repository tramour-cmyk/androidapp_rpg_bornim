package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 62c: the marks on the map remind, never lead: a giver only once spoken to, a goal only once seen, done fades. */
class MapMarksTest {
    private fun state() = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun `nothing before a job is taken, a giver only once spoken to`() {
        val s = state()
        s.flags += MapMarks.met("gwenna")
        assertTrue(MapMarks.of(s).isEmpty(), "no job taken")
        Jobs.take(s, Jobs["tusks"])
        assertTrue(MapMarks.of(s).isEmpty(), "Borin not yet spoken to")
        s.flags += MapMarks.met("borin")
        val m = MapMarks.of(s).single()
        assertEquals(MapMarks.Kind.GIVER, m.kind)
        assertEquals("borin", World[m.map].npcs.first { it.x == m.x && it.y == m.y }.id)
    }

    @Test
    fun `the cave chest turns gold only once seen, and fades when done`() {
        val s = state()
        Jobs.take(s, Jobs["ring"])
        assertTrue(MapMarks.of(s).none { it.kind == MapMarks.Kind.GOAL }, "cave not seen")
        val cave = World["cave"]
        val chest = cave.chests.first { it.id == Jobs.RING_CHEST }
        val bits = BooleanArray(cave.width * cave.height); bits[chest.y * cave.width + chest.x] = true
        s.explored["cave"] = bits.toList().chunked(4).joinToString("") { c -> c.withIndex().sumOf { (b, v) -> if (v) 1 shl b else 0 }.toString(16) }
        val goal = MapMarks.of(s).single { it.kind == MapMarks.Kind.GOAL }
        assertEquals(Triple("cave", chest.x, chest.y), Triple(goal.map, goal.x, goal.y))
        assertTrue(!goal.done)
        s.flags += "job_ring_done"
        assertTrue(MapMarks.of(s).single { it.kind == MapMarks.Kind.GOAL }.done)
        assertTrue(MapMarks.visited(s, cave))
    }
}
