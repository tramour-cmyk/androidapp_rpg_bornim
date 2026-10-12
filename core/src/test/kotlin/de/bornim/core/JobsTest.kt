package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** The odd jobs of the notice board (29): take up, carry, give up, hand in, the ring in the cave. */
class JobsTest {
    private fun state() = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun `three notes on the board, none taken at first`() {
        val s = state()
        assertEquals(listOf("pelts", "ring", "tusks"), Jobs.onBoard(s).map { it.id })
        assertTrue(Jobs.carried(s).isEmpty())
    }

    @Test
    fun `take up, count, hand in`() {
        val s = state()
        val j = Jobs["pelts"]
        Jobs.take(s, j)
        assertEquals(listOf("pelts"), Jobs.carried(s).map { it.id })
        s.add("wolf_pelt", 3)
        assertEquals(3, Jobs.progress(s, j))
        assertNull(Jobs.handIn(s, "thessa"), "not enough pelts yet")
        s.add("wolf_pelt", 4)
        assertEquals(5, Jobs.progress(s, j))
        val cmds = Jobs.handIn(s, "thessa")!!
        assertTrue(Cmd.Take("wolf_pelt", 5) in cmds && Cmd.GiveGold(60) in cmds)
        assertNull(Jobs.handIn(s, "borin"), "only the giver takes it back")
    }

    @Test
    fun `a finished job leaves the board and the menu`() {
        val s = state()
        val game = Game(s, Lang.DE)
        game.takeJob("tusks")
        s.add("boar_tusk", 3)
        val gold = s.gold
        game.enqueue(Jobs.handIn(s, "borin")!!)
        while (game.mode != Mode.Explore) game.advance()
        assertEquals(gold + 50, s.gold)
        assertEquals(0, s.count("boar_tusk"))
        assertTrue(Jobs.isDone(s, Jobs["tusks"]))
        assertFalse("tusks" in Jobs.onBoard(s).map { it.id })
        assertTrue(Jobs.carried(s).isEmpty())
        assertNull(Jobs.handIn(s.apply { add("boar_tusk", 3) }, "borin"), "no second payment")
    }

    @Test
    fun `given up, the job goes back on the board`() {
        val s = state()
        Jobs.take(s, Jobs["ring"])
        Jobs.drop(s, Jobs["ring"])
        assertTrue(Jobs.carried(s).isEmpty())
        assertFalse(Jobs.isTaken(s, Jobs["ring"]))
        assertTrue("ring" in Jobs.onBoard(s).map { it.id })
    }

    @Test
    fun `the ring lies in the cave chest only while the job is taken, also when emptied before`() {
        val s = state()
        assertFalse(Jobs.ringIn(s, Jobs.RING_CHEST))
        s.openedChests += Jobs.RING_CHEST
        Jobs.take(s, Jobs["ring"])
        assertTrue(Jobs.ringIn(s, Jobs.RING_CHEST))
        assertFalse(Jobs.ringIn(s, "cave_1"))
        s.add(Jobs.RING)
        assertFalse(Jobs.ringIn(s, Jobs.RING_CHEST), "only one ring")
    }

    @Test
    fun `the board stands before the inn, every giver lives in the world`() {
        assertEquals(Tile.NOTICE, World["village"].tile(4, 7))
        val npcs = World.maps.values.flatMap { m -> m.npcs.map { it.id } }.toSet()
        for (j in Jobs.all) {
            assertTrue(j.giver in npcs, j.giver)
            Items[j.item]
        }
        assertTrue(World["cave"].chests.any { it.id == Jobs.RING_CHEST })
    }

    @Test
    fun `the second wave comes after Krogg, with a fresh note until read`() {
        val s = state()
        assertTrue(Jobs.freshNote(s), "the first notes are new too")
        Jobs.read(s)
        assertFalse(Jobs.freshNote(s))
        assertFalse(Jobs.onBoard(s).any { it.id == "glands" || it.id == "stones" })
        s.flags += Story.KROGG_DEFEATED
        assertEquals(listOf("pelts", "ring", "tusks", "glands", "stones"), Jobs.onBoard(s).map { it.id })
        assertTrue(Jobs.freshNote(s))
        Jobs.read(s)
        assertFalse(Jobs.freshNote(s))
    }

    @Test
    fun `Morwen pays gold and two remedies`() {
        val s = state().apply { flags += Story.KROGG_DEFEATED }
        Jobs.take(s, Jobs["glands"])
        s.add("spider_gland", 3)
        val cmds = Jobs.handIn(s, "morwen")!!
        assertTrue(Cmd.GiveGold(50) in cmds && Cmd.Give("remedy", 2) in cmds && Cmd.Take("spider_gland", 3) in cmds)
    }

    @Test
    fun `Jorin's rag lies at the standing stones while his job is taken, a helmet for it`() {
        val s = state().apply { flags += Story.KROGG_DEFEATED }
        val game = Game(s, Lang.DE)
        assertNull(Jobs.findAt(s, "forest", Tile.MENHIR), "nothing before the job")
        game.takeJob("stones")
        assertNull(Jobs.findAt(s, "forest", Tile.ROCK))
        assertNull(Jobs.findAt(s, "village", Tile.MENHIR))
        game.enqueue(Jobs.findAt(s, "forest", Tile.MENHIR)!!)
        while (game.mode != Mode.Explore) game.advance()
        assertEquals(1, s.count(Jobs.RAG))
        assertNull(Jobs.findAt(s, "forest", Tile.MENHIR), "only one rag")
        val gear = s.bag.size
        game.enqueue(Jobs.handIn(s, "jorin")!!)
        while (game.mode != Mode.Explore) game.advance()
        assertEquals(0, s.count(Jobs.RAG))
        assertEquals(gear + 1, s.bag.size)
        assertEquals(GearSlot.HEAD, GearBases[s.bag.last().base].slot)
        assertTrue(Jobs.isDone(s, Jobs["stones"]))
    }

    @Test
    fun `the forest has standing stones for the rag`() {
        val f = World[Jobs.RAG_MAP]
        assertTrue((0 until f.height).any { y -> (0 until f.width).any { x -> f.tile(x, y) == Tile.MENHIR } })
    }
}
