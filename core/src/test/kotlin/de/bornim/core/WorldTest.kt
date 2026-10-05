package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlin.test.fail

class WorldTest {
    private val anyState = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun mapObjectsMatchTiles() {
        for (map in World.maps.values) {
            for (c in map.chests) assertEquals(Tile.CHEST, map.tile(c.x, c.y), "${map.id} chest ${c.id}")
            for ((pos, _) in map.signs) assertEquals(Tile.SIGN, map.tile(pos.first, pos.second), "${map.id} sign $pos")
            for (y in 0 until map.height) for (x in 0 until map.width) {
                when (map.tile(x, y)) {
                    Tile.CHEST -> assertTrue(map.chestAt(x, y) != null, "${map.id} chest tile without chest at $x,$y")
                    Tile.SIGN -> assertTrue(map.signs.containsKey(x to y), "${map.id} sign tile without text at $x,$y")
                    Tile.DOOR, Tile.CAVE_ENTRANCE, Tile.CAVE_EXIT ->
                        assertTrue(map.warpAt(x, y) != null, "${map.id} exit without warp at $x,$y")
                    else -> {}
                }
            }
            for (npc in map.npcs) {
                assertTrue(map.inside(npc.x, npc.y), "${map.id} npc ${npc.id} outside")
                assertTrue(map.tile(npc.x, npc.y).walkable, "${map.id} npc ${npc.id} on blocked tile")
            }
        }
        val ids = World.maps.values.flatMap { m -> m.chests.map { it.id } }
        assertEquals(ids.size, ids.toSet().size, "duplicate chest ids")
    }

    @Test
    fun warpsLeadToWalkableTiles() {
        for (map in World.maps.values) for (w in map.warps) {
            val target = World[w.to.map]
            assertTrue(target.tile(w.to.x, w.to.y).walkable, "${map.id} warp to ${w.to} lands on ${target.tile(w.to.x, w.to.y)}")
            assertTrue(target.warpAt(w.to.x, w.to.y) == null, "${map.id} warp to ${w.to} lands on another warp")
        }
        assertTrue(World[Story.START.map].tile(Story.START.x, Story.START.y).walkable)
        assertTrue(World[Story.RESPAWN.map].tile(Story.RESPAWN.x, Story.RESPAWN.y).walkable)
    }

    @Test
    fun encounterTablesAreValid() {
        for (map in World.maps.values) map.encounters?.table?.forEach { (id, w) ->
            Monsters[id]
            assertTrue(w > 0)
        }
    }

    /**
     * Plays the whole chapter with a strong hero: walks with BFS, talks to people,
     * fights every battle with the Attack command and checks the chapter can be finished.
     */
    @Test
    fun chapterOneCanBeCompleted() {
        for (cls in CharClass.entries) {
            val state = GameState.newGame("Tester", Race.HUMAN, cls)
            state.hero.gainXp(Rules.xpForLevel[8])
            state.hero.restoreFully()
            val bot = Bot(Game(state, Lang.DE, Dice(Random(42))))
            bot.game.begin()
            bot.settle()
            assertTrue(state.has(Story.INTRO_DONE))

            bot.talkTo("elder", "aldric")
            assertTrue(state.has(Story.QUEST_STARTED), "quest not started")
            bot.talkTo("forest", "wilhelm")
            assertTrue(state.has(Story.HUNTER_MET))
            bot.openChest("cave", "cave_3")
            assertTrue(state.bag.any { it.unique == Story.classWeapon(cls) }, "$cls weapon chest")
            bot.talkTo("cave", "krogg")
            assertTrue(state.has(Story.KROGG_DEFEATED))
            assertEquals(1, state.count("rusty_key"))
            bot.walkTo("cave", 10, 6)
            bot.face(Facing.UP)
            bot.game.interact()
            bot.settle()
            assertTrue(state.has(Story.GATE_OPEN))
            bot.walkTo("cave", 10, 4) // triggers Grak
            assertTrue(state.has(Story.GRAK_DEFEATED), "Grak not defeated")
            assertEquals(1, state.count("sun_amulet"))
            bot.talkTo("cave", "lyra_cave")
            assertTrue(state.has(Story.LYRA_RESCUED))
            bot.talkTo("elder", "aldric")
            assertTrue(state.has(Story.CHAPTER1_DONE), "chapter not finished for $cls")
            assertTrue(state.bag.any { it.unique == "ring_protection" })
            assertEquals(0, state.count("sun_amulet"))
        }
    }
}

/** A tiny autopilot for tests. */
class Bot(val game: Game) {
    private val state get() = game.state
    var battles = 0

    fun settle() {
        var guard = 0
        while (game.mode != Mode.Explore) {
            if (++guard > 10_000) fail("stuck in ${game.mode}")
            when (val m = game.mode) {
                is Mode.Dialog, is Mode.Shop, Mode.ChapterEnd -> game.advance()
                is Mode.Fight -> {
                    battles++
                    val b = m.battle
                    b.start()
                    while (b.outcome == Outcome.ONGOING) {
                        if (state.hero.hp < state.hero.maxHp / 2) state.hero.restoreFully()
                        b.act(Action.Attack)
                    }
                    if (b.outcome == Outcome.LOST) fail("lost against ${b.monster.id}")
                    game.endBattle()
                }
                Mode.Explore -> {}
            }
        }
    }

    fun face(f: Facing) {
        game.move(f) // turning towards a blocked tile only changes facing
        settle()
    }

    /** Travel across maps and walk to a tile. */
    fun walkTo(mapId: String, x: Int, y: Int) {
        enterMap(mapId)
        stepTo(x, y)
    }

    private fun route(from: String, to: String): String? {
        val prev = mutableMapOf(from to from)
        val q = ArrayDeque(listOf(from))
        while (q.isNotEmpty()) {
            val m = q.removeFirst()
            if (m == to) {
                var cur = to
                while (prev[cur] != from) cur = prev[cur]!!
                return cur
            }
            for (w in World[m].warps) if (w.to.map !in prev) {
                prev[w.to.map] = m
                q += w.to.map
            }
        }
        return null
    }

    private fun stepTo(tx: Int, ty: Int) {
        val map = game.map
        var guard = 0
        while (state.place.x != tx || state.place.y != ty) {
            if (++guard > 500) fail("cannot reach $tx,$ty on ${map.id}")
            if (state.place.map != map.id) return
            val path = bfs(tx, ty) ?: fail("no path to $tx,$ty on ${map.id} from ${state.place}")
            val dir = path.first()
            val r = game.move(dir)
            settle()
            if (r is Move.Stepped) {
                game.afterStep()
                settle()
            }
        }
    }

    private fun bfs(tx: Int, ty: Int): List<Facing>? {
        val map = game.map
        val start = state.place.x to state.place.y
        val prev = mutableMapOf<Pair<Int, Int>, Pair<Pair<Int, Int>, Facing>?>(start to null)
        val q = ArrayDeque(listOf(start))
        while (q.isNotEmpty()) {
            val cur = q.removeFirst()
            if (cur == tx to ty) {
                val dirs = mutableListOf<Facing>()
                var c = cur
                while (true) {
                    val p = prev[c] ?: break
                    dirs.add(0, p.second)
                    c = p.first
                }
                return dirs
            }
            for (f in Facing.entries) {
                val n = cur.first + f.dx to cur.second + f.dy
                if (n in prev) continue
                val isTarget = n == tx to ty
                val w = map.warpAt(n.first, n.second)
                if (w != null && !isTarget) continue
                if (!map.walkable(n.first, n.second, state)) continue
                prev[n] = cur to f
                q += n
            }
        }
        return null
    }

    fun talkTo(mapId: String, npcId: String) {
        enterMap(mapId)
        val npc = game.map.npcs.first { it.id == npcId }
        approach(npc.x, npc.y)
        game.interact()
        settle()
    }

    fun openChest(mapId: String, chestId: String) {
        if (state.place.map != mapId) enterMap(mapId)
        val c = game.map.chests.first { it.id == chestId }
        approach(c.x, c.y)
        game.interact()
        settle()
    }

    private fun enterMap(mapId: String) {
        var hops = 0
        while (state.place.map != mapId) {
            if (++hops > 10) fail("cannot reach map $mapId")
            val next = route(state.place.map, mapId) ?: fail("no route")
            val warp = game.map.warps.first { it.to.map == next && (it.requires == null || state.has(it.requires)) }
            stepTo(warp.x, warp.y)
        }
    }

    /** Walk next to (x,y) — or across a counter from it — and face it. */
    private fun approach(x: Int, y: Int) {
        val map = game.map
        val spots = Facing.entries.flatMap { f ->
            listOf(1, 2).map { d -> Triple(x - f.dx * d, y - f.dy * d, f) to d }
        }.filter { (t, d) ->
            val (sx, sy, f) = t
            map.inside(sx, sy) && map.walkable(sx, sy, state) && map.warpAt(sx, sy) == null &&
                (d == 1 || map.tile(sx + f.dx, sy + f.dy) == Tile.COUNTER)
        }
        for ((t, _) in spots) {
            val (sx, sy, f) = t
            if (bfs(sx, sy) != null) {
                stepTo(sx, sy)
                face(f)
                return
            }
        }
        fail("cannot approach $x,$y on ${map.id}")
    }
}
