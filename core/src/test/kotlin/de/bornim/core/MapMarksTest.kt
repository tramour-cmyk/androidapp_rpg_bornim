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
        // in the inn, and (62e) at the inn's door in the village
        val (inside, door) = MapMarks.of(s).partition { World[it.map].kind == MapKind.INTERIOR }
        val m = inside.single()
        assertEquals(MapMarks.Kind.GIVER, m.kind)
        assertEquals("borin", World[m.map].npcs.first { it.x == m.x && it.y == m.y }.id)
        assertEquals(MapMarks.door(m.map), door.single().let { Triple(it.map, it.x, it.y) })
    }

    @Test
    fun `62e the elder's quest at his door, the board once read`() {
        val s = state()
        assertTrue(MapMarks.of(s).isEmpty(), "nothing before the elder speaks")
        s.flags += Story.QUEST_STARTED
        val elder = MapMarks.of(s).filter { it.kind == MapMarks.Kind.GIVER }
        assertEquals(setOf("elder", "village"), elder.map { it.map }.toSet())
        assertEquals(MapMarks.door("elder"), elder.single { it.map == "village" }.let { Triple(it.map, it.x, it.y) })
        assertTrue(MapMarks.of(s).none { it.kind == MapMarks.Kind.BOARD }, "board not read")
        Jobs.read(s)
        val b = MapMarks.of(s).single { it.kind == MapMarks.Kind.BOARD }
        assertEquals(Tile.NOTICE, World[b.map].tile(b.x, b.y))
        s.flags += Story.CHAPTER1_DONE
        assertTrue(MapMarks.of(s).filter { it.kind == MapMarks.Kind.GIVER }.all { it.done })
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
