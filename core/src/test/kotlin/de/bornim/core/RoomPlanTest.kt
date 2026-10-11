package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The rooms in their new floor plans (13q.6, 13q.8, 13q.9): from the door the hero reaches everyone to talk to and the way out. */
class RoomPlanTest {
    private fun game(): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(kotlin.random.Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        (g.roamers as? MutableList<Roamer>)?.clear()
        return g
    }

    /** The tiles the hero can walk to from [from] on [map]. */
    private fun reach(g: Game, map: MapDef, from: Pair<Int, Int>): Set<Pair<Int, Int>> {
        val seen = mutableSetOf(from)
        val todo = ArrayDeque(listOf(from))
        while (todo.isNotEmpty()) {
            val (x, y) = todo.removeFirst()
            for (f in Facing.entries) {
                val n = x + f.dx to y + f.dy
                if (n !in seen && map.walkable(n.first, n.second, g.state)) { seen += n; todo += n }
            }
        }
        return seen
    }

    @Test
    fun everyoneAndTheDoorCanBeReachedFromTheDoor() {
        for (id in listOf("inn", "elder", "shop", "temple")) {
            val g = game()
            // Lyra stands in the temple once she is home
            g.state.flags += Story.LYRA_RESCUED
            val map = World[id]
            val entry = World["village"].warps.single { it.to.map == id }.to
            assertTrue(map.walkable(entry.x, entry.y, g.state), "$id: the hero comes in on ($entry)")
            val tiles = reach(g, map, entry.x to entry.y)
            val exit = map.warps.single()
            assertTrue((exit.x to exit.y) in tiles, "$id: the door out")
            assertEquals(map.height - 1, exit.y, "$id: the door lies in the front wall")
            for (npc in map.npcs.filter { it.visible(g.state) }) {
                val spots = tiles.flatMap { t -> Facing.entries.map { t to it } }.filter { (t, f) ->
                    g.state.place = Place(id, t.first, t.second, f)
                    g.actionAhead() == ActionKind.TALK && run {
                        val ax = t.first + f.dx; val ay = t.second + f.dy
                        val bx = if (map.tile(ax, ay) == Tile.COUNTER) ax + f.dx else ax
                        val by = if (map.tile(ax, ay) == Tile.COUNTER) ay + f.dy else ay
                        bx == npc.x && by == npc.y
                    }
                }
                assertTrue(spots.isNotEmpty(), "$id: nobody can talk to ${npc.id} at (${npc.x}, ${npc.y})")
            }
        }
    }

    @Test
    fun respawnLiesOnTheTemplesFloor() {
        val g = game()
        val p = Story.RESPAWN
        assertTrue(World[p.map].walkable(p.x, p.y, g.state), "respawn at (${p.x}, ${p.y})")
    }
}
