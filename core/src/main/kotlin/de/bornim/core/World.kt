package de.bornim.core

enum class Tile(val ch: Char, val walkable: Boolean) {
    GRASS('.', true),
    TALL_GRASS(',', true),
    FLOWERS('f', true),
    PATH('=', true),
    TREE('T', false),
    WATER('~', false),
    ROCK('r', false),
    ROOF('^', false),
    ROOF_BLUE('M', false),
    WALL('#', false),
    WINDOW('W', false),
    DOOR('D', true),
    SIGN('S', false),
    CHEST('C', false),
    WELL('w', false),
    CAMPFIRE('F', false),
    CAVE_WALL('X', false),
    CAVE_FLOOR('_', true),
    CAVE_ENTRANCE('E', true),
    CAVE_EXIT('+', true),
    TORCH('t', false),
    GATE('L', false),
    WOOD_FLOOR('k', true),
    RUG('R', true),
    COUNTER('K', false),
    TABLE('Y', false),
    BED('B', false),
    SHELF('Q', false),
    PLANT('P', false),
    ALTAR('A', false),
    ;

    companion object {
        private val byChar = entries.associateBy { it.ch }
        fun of(c: Char): Tile = byChar[c] ?: error("Unknown tile '$c'")
    }
}

enum class MapKind { TOWN, INTERIOR, FOREST, CAVE }

data class Warp(val x: Int, val y: Int, val to: Place, val requires: String? = null, val denied: List<Cmd> = emptyList())

data class Chest(val id: String, val x: Int, val y: Int, val item: String? = null, val count: Int = 1, val gold: Int = 0)

data class Encounters(val rate: Double, val table: List<Pair<String, Int>>, val tiles: Set<Tile>)

data class Trigger(val x: Int, val y: Int, val condition: (GameState) -> Boolean, val script: (GameState) -> List<Cmd>)

class Npc(
    val id: String,
    val x: Int,
    val y: Int,
    /** Sprite key understood by the app, e.g. "elder" or "monster:bugbear". */
    val look: String,
    val facing: Facing = Facing.DOWN,
    val visible: (GameState) -> Boolean = { true },
    val talk: (GameState) -> List<Cmd>,
)

class MapDef(
    val id: String,
    val name: T,
    val kind: MapKind,
    rows: List<String>,
    val warps: List<Warp> = emptyList(),
    val npcs: List<Npc> = emptyList(),
    val chests: List<Chest> = emptyList(),
    val signs: Map<Pair<Int, Int>, T> = emptyMap(),
    val encounters: Encounters? = null,
    val triggers: List<Trigger> = emptyList(),
    val onEnter: (GameState) -> List<Cmd> = { emptyList() },
    /** Baseline monster and item level of this area. */
    val areaLevel: Int = 1,
) {
    val width = rows.first().length
    val height = rows.size
    val tiles: Array<Array<Tile>> = Array(height) { y ->
        require(rows[y].length == width) { "Map $id row $y has length ${rows[y].length}, expected $width" }
        Array(width) { x -> Tile.of(rows[y][x]) }
    }

    fun inside(x: Int, y: Int) = x in 0 until width && y in 0 until height
    fun tile(x: Int, y: Int): Tile = if (inside(x, y)) tiles[y][x] else defaultTile
    val defaultTile: Tile get() = if (kind == MapKind.CAVE) Tile.CAVE_WALL else if (kind == MapKind.INTERIOR) Tile.WALL else Tile.TREE

    fun npcAt(x: Int, y: Int, state: GameState): Npc? = npcs.firstOrNull { it.x == x && it.y == y && it.visible(state) }
    fun chestAt(x: Int, y: Int): Chest? = chests.firstOrNull { it.x == x && it.y == y }
    fun warpAt(x: Int, y: Int): Warp? = warps.firstOrNull { it.x == x && it.y == y }

    fun walkable(x: Int, y: Int, state: GameState): Boolean {
        if (!inside(x, y)) return false
        val t = tile(x, y)
        val ok = t.walkable || (t == Tile.GATE && state.has(Story.GATE_OPEN))
        return ok && npcAt(x, y, state) == null
    }
}

object World {
    val maps: Map<String, MapDef> by lazy {
        listOf(Story.village, Story.inn, Story.shop, Story.elderHouse, Story.temple, Story.forest, Story.cave).associateBy { it.id }
    }

    operator fun get(id: String): MapDef = maps[id] ?: error("Unknown map $id")
}
