package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 62c: the marks on the map remind, never lead: a giver only once spoken to, a goal only once seen, done fades. */
class MapMarksTest {
    private fun state() = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    private fun quests(s: GameState) = MapMarks.of(s) - (MapPeople.marks(s) + MapPeople.services(s)).toSet()

    @Test
    fun `nothing before a job is taken, a giver only once spoken to`() {
        val s = state()
        s.flags += MapMarks.met("gwenna")
        assertTrue(quests(s).isEmpty(), "no job taken")
        Jobs.take(s, Jobs["tusks"])
        assertTrue(quests(s).isEmpty(), "Borin not yet spoken to")
        s.flags += MapMarks.met("borin")
        // in the inn, and (62e) at the inn's door in the village
        val (inside, door) = quests(s).partition { World[it.map].kind == MapKind.INTERIOR }
        val m = inside.single()
        assertEquals(MapMarks.Kind.GIVER, m.kind)
        assertEquals("borin", World[m.map].npcs.first { it.x == m.x && it.y == m.y }.id)
        assertEquals(MapMarks.door(m.map), door.single().let { Triple(it.map, it.x, it.y) })
    }

    @Test
    fun `62e the elder's quest at his door, the board once read`() {
        val s = state()
        assertTrue(quests(s).isEmpty(), "nothing before the elder speaks")
        s.flags += Story.QUEST_STARTED
        val elder = quests(s).filter { it.kind == MapMarks.Kind.GIVER }
        assertEquals(setOf("elder", "village"), elder.map { it.map }.toSet())
        assertEquals(MapMarks.door("elder"), elder.single { it.map == "village" }.let { Triple(it.map, it.x, it.y) })
        assertTrue(quests(s).none { it.kind == MapMarks.Kind.BOARD }, "board not read")
        Jobs.read(s)
        val b = quests(s).single { it.kind == MapMarks.Kind.BOARD }
        assertEquals(Tile.NOTICE, World[b.map].tile(b.x, b.y))
        s.flags += Story.CHAPTER1_DONE
        assertTrue(quests(s).filter { it.kind == MapMarks.Kind.GIVER }.all { it.done })
    }

    @Test
    fun `the cave chest turns gold only once seen, and fades when done`() {
        val s = state()
        Jobs.take(s, Jobs["ring"])
        assertTrue(quests(s).none { it.kind == MapMarks.Kind.GOAL }, "cave not seen")
        val cave = World["cave"]
        val chest = cave.chests.first { it.id == Jobs.RING_CHEST }
        val bits = BooleanArray(cave.width * cave.height); bits[chest.y * cave.width + chest.x] = true
        s.explored["cave"] = bits.toList().chunked(4).joinToString("") { c -> c.withIndex().sumOf { (b, v) -> if (v) 1 shl b else 0 }.toString(16) }
        val goal = quests(s).single { it.kind == MapMarks.Kind.GOAL }
        assertEquals(Triple("cave", chest.x, chest.y), Triple(goal.map, goal.x, goal.y))
        assertTrue(!goal.done)
        s.flags += "job_ring_done"
        assertTrue(quests(s).single { it.kind == MapMarks.Kind.GOAL }.done)
        assertTrue(MapMarks.visited(s, cave))
    }

    @Test
    fun `62f people once met, habits once come upon there, houses once inside or heard`() {
        val s = state()
        assertTrue(MapPeople.marks(s).isEmpty(), "nobody met")
        s.flags += MapMarks.met("bram")
        val bram = MapPeople.marks(s).single()
        assertEquals(Triple("village", 20, 29), Triple(bram.map, bram.x, bram.y))
        assertTrue("mittags" !in bram.label.de)
        // at noon on the square, and only there
        val noon = VillageDay.plans.getValue("bram")[1]
        assertEquals("noon", MapPeople.habitNow("bram", noon.from + 10, false, noon.x, noon.y))
        assertEquals(null, MapPeople.habitNow("bram", noon.from + 10, false, 2, 2))
        assertEquals(null, MapPeople.habitNow("bram", VillageDay.plans.getValue("bram")[0].from + 10, false, 20, 29))
        s.flags += MapPeople.seenAt("bram", "noon")
        assertTrue("mittags" in MapPeople.marks(s).single().label.de)
        // Jorin at night, wherever on his round
        assertEquals("night", MapPeople.habitNow("jorin", 0, true, 17, 3))
        assertEquals(null, MapPeople.habitNow("jorin", 12 * 60, false, 17, 3))
        // houses: none at first, the inn once inside, the baker once knocked
        assertTrue(MapPeople.houses(s).isEmpty())
        s.flags += MapPeople.been("inn"); s.flags += MapPeople.heard(12, 5)
        assertEquals(setOf("Schänke", "Bäcker"), MapPeople.houses(s).map { it.name.de }.toSet())
        // an older hero who already talked to Thessa knows her shop
        s.flags += MapMarks.met("thessa")
        assertTrue(MapPeople.houses(s).any { it.name.de == "Kramladen" })
    }

    @Test
    fun `62g knocking at a locked door names the house`() {
        val w = World["village"].warps.first { it.x == 12 && it.y == 5 }
        assertTrue(w.denied.any { it == Cmd.SetFlag(MapPeople.heard(12, 5)) })
    }

    @Test
    fun `62h the ground plan of the temple shows Osric and Lyra where they stand, 62s its house knows the way in`() {
        val s = state()
        s.flags += MapMarks.met("osric"); s.flags += MapMarks.met("lyra_temple")
        val inside = MapPeople.marks(s).filter { it.map == "temple" }
        val temple = World["temple"]
        assertEquals(setOf("osric", "lyra_temple"), inside.mapNotNull { it.who }.toSet())
        for (m in inside) assertTrue(temple.npcs.any { it.id == m.who && it.x == m.x && it.y == m.y }, "${m.who} at their place")
        // outside, both at the temple's door, one mark
        assertEquals(1, MapPeople.marks(s).count { it.map == "village" && ("Osric" in it.label.de) && ("Lyra" in it.label.de) })
        assertEquals("temple", MapPeople.houses(s).single { it.name.de == "Tempel" }.inside)
    }
}
