package de.bornim.core

/**
 * 62c: marks on the drawn map in the menu. They remind, they never lead (33): a quest giver is blue once the hero has
 * spoken to them (tapping shows their name and the quest), the place a quest is about turns gold only once the hero
 * has seen it himself; what is done fades. Nothing is set up by itself; the marks only follow what the hero has done.
 * The same facts will feed the quest log (64).
 */
object MapMarks {
    enum class Kind { GIVER, GOAL }

    /** The flag set once the hero has spoken to [npc]. */
    fun met(npc: String) = "met_$npc"

    data class Mark(val map: String, val x: Int, val y: Int, val kind: Kind, val done: Boolean, val label: T)

    /** Where a job's errand leads, if it leads to one place: Gwenna's ring in the cave's chest, Jorin's rag at the stones. */
    private fun goal(j: Jobs.Job): Pair<String, Pair<Int, Int>>? = when (j.id) {
        "ring" -> World.maps["cave"]?.chests?.firstOrNull { it.id == Jobs.RING_CHEST }?.let { "cave" to (it.x to it.y) }
        "stones" -> World.maps[Jobs.RAG_MAP]?.let { m ->
            val stones = (0 until m.height).flatMap { y -> (0 until m.width).filter { x -> m.tile(x, y) == Tile.MENHIR }.map { it to y } }
            if (stones.isEmpty()) null else Jobs.RAG_MAP to (stones.sumOf { it.first } / stones.size to stones.sumOf { it.second } / stones.size)
        }
        else -> null
    }

    /** True once the hero has seen this tile of a wild map; towns and rooms are known as soon as one is there. */
    fun seen(s: GameState, map: MapDef, x: Int, y: Int): Boolean {
        if (map.kind != MapKind.FOREST && map.kind != MapKind.CAVE) return true
        val hex = s.explored[map.id] ?: return false
        val i = y * map.width + x
        val c = i / 4
        return c < hex.length && (hex[c].digitToInt(16) shr (i % 4)) and 1 == 1
    }

    /** True once the hero has been on [map]. */
    fun visited(s: GameState, map: MapDef): Boolean =
        s.place.map == map.id || map.kind == MapKind.TOWN || map.kind == MapKind.INTERIOR || s.explored.containsKey(map.id)

    fun of(s: GameState): List<Mark> {
        val out = ArrayList<Mark>()
        for (j in Jobs.all) {
            val taken = Jobs.isTaken(s, j)
            val done = Jobs.isDone(s, j)
            if (!taken && !done) continue
            if (s.has(met(j.giver))) for (m in World.maps.values) m.npcs.firstOrNull { it.id == j.giver }?.let { n ->
                out += Mark(m.id, n.x, n.y, Kind.GIVER, done, T("${j.giverName.de}: ${j.title.de}", "${j.giverName.en}: ${j.title.en}"))
            }
            goal(j)?.let { (mapId, at) ->
                val m = World.maps[mapId] ?: return@let
                if (seen(s, m, at.first, at.second)) out += Mark(mapId, at.first, at.second, Kind.GOAL, done, j.title)
            }
        }
        return out
    }
}
