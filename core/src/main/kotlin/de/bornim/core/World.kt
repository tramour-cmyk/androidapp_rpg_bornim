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
    // village
    COBBLE('o', true),
    STALL('m', false),
    LAMP('l', false),
    BARREL('b', false),
    BENCH('n', false),
    BRIDGE('h', true),
    FENCE('x', false),
    CROPS('c', false),
    VEG_BED('v', false),
    HAY('y', false),
    WASHLINE('q', false),
    /** Barrier pole across a road; passable once [Story.BARRIER_OPEN] is set. */
    BARRIER('z', false),
    // cave life: things that light the cave, things that lie around
    GLOWSHROOM('g', true),
    /** Crystals growing out of a cave wall; glow violet. */
    CRYSTAL('G', false),
    STALAGMITE('i', false),
    RUBBLE('%', true),
    BONES('j', true),
    CRATE('u', false),
    BEDROLL('e', true),
    /** Wooden supports on the sides of a cave passage. */
    SUPPORT('H', true),
    /** Daylight falls through a crack in the cave roof. */
    SKYLIGHT('*', true),
    // forest places that also appear as battle scenes
    /** A fallen, mossy tree trunk. */
    LOG('O', false),
    /** A standing stone of an old stone circle. */
    MENHIR('I', false),
    ;

    companion object {
        private val byChar = entries.associateBy { it.ch }
        fun of(c: Char): Tile = byChar[c] ?: error("Unknown tile '$c'")
    }
}

enum class MapKind { TOWN, INTERIOR, FOREST, CAVE }

enum class RoofKind { RED, BLUE, SLATE, STRAW, SHINGLE }
enum class WallKind { TIMBER, STONE, PLANKS }
enum class HouseFeature { NONE, INN_SIGN, AWNING, BELL_TOWER }

/** Look of a house on a town map; [mirrored] puts the chimney on the left. */
data class HouseStyle(
    val roof: RoofKind,
    val walls: WallKind,
    val mirrored: Boolean = false,
    val feature: HouseFeature = HouseFeature.NONE,
)

data class Warp(val x: Int, val y: Int, val to: Place, val requires: String? = null, val denied: List<Cmd> = emptyList())

data class Chest(val id: String, val x: Int, val y: Int, val item: String? = null, val count: Int = 1, val gold: Int = 0)

/**
 * Monsters of an area. [roamers] of them walk around visibly; [rate] is the (small) chance per
 * step on [tiles] to be ambushed by one that was hiding.
 */
data class Encounters(
    val rate: Double,
    val table: List<Pair<String, Int>>,
    val tiles: Set<Tile>,
    val roamers: Int = 0,
    /** Monsters that come out at night instead of [table]. */
    val night: List<Pair<String, Int>>? = null,
)

/**
 * An area monsters will not enter: around camps and exits. A hunting monster that sees the hero
 * reach it gives up and goes home; [notice] is shown when that happens.
 */
data class SafeZone(val x: Int, val y: Int, val radius: Int, val notice: T? = null) {
    fun contains(px: Int, py: Int) = kotlin.math.abs(px - x) + kotlin.math.abs(py - y) <= radius
}

data class Trigger(val x: Int, val y: Int, val condition: (GameState) -> Boolean, val script: (GameState) -> List<Cmd>)

class Npc(
    val id: String,
    val x: Int,
    val y: Int,
    /** Sprite key understood by the app, e.g. "elder" or "monster:bugbear". */
    val look: String,
    val facing: Facing = Facing.DOWN,
    val visible: (GameState) -> Boolean = { true },
    /** How far this person strolls around their spot (0 = stands still). */
    val wander: Int = 0,
    /** Points this person walks between in a loop, pausing at each (a guard on patrol). */
    val patrol: List<Pair<Int, Int>> = emptyList(),
    val talk: (GameState) -> List<Cmd>,
) {
    /** Strolls or patrols, so the game tracks where they are. */
    val moves: Boolean get() = wander > 0 || patrol.isNotEmpty()
}

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
    val safeZones: List<SafeZone> = emptyList(),
    /** Looks of the houses, by the top-left tile of their roof; others get one from their position. */
    val houseStyles: Map<Pair<Int, Int>, HouseStyle> = emptyMap(),
) {
    fun safe(x: Int, y: Int) = safeZones.any { it.contains(x, y) }

    val width = rows.first().length
    val height = rows.size
    val tiles: Array<Array<Tile>> = Array(height) { y ->
        require(rows[y].length == width) { "Map $id row $y has length ${rows[y].length}, expected $width" }
        Array(width) { x -> Tile.of(rows[y][x]) }
    }

    fun inside(x: Int, y: Int) = x in 0 until width && y in 0 until height
    fun tile(x: Int, y: Int): Tile = if (inside(x, y)) tiles[y][x] else defaultTile
    val defaultTile: Tile get() = if (kind == MapKind.CAVE) Tile.CAVE_WALL else if (kind == MapKind.INTERIOR) Tile.WALL else Tile.TREE

    /** People standing still at ([x], [y]); strolling ones are tracked by the [Game]. */
    fun npcAt(x: Int, y: Int, state: GameState): Npc? = npcs.firstOrNull { !it.moves && it.x == x && it.y == y && it.visible(state) }
    fun chestAt(x: Int, y: Int): Chest? = chests.firstOrNull { it.x == x && it.y == y }
    fun warpAt(x: Int, y: Int): Warp? = warps.firstOrNull { it.x == x && it.y == y }

    fun walkable(x: Int, y: Int, state: GameState): Boolean {
        if (!inside(x, y)) return false
        val t = tile(x, y)
        val ok = t.walkable || (t == Tile.GATE && state.has(Story.GATE_OPEN)) || (t == Tile.BARRIER && state.has(Story.BARRIER_OPEN))
        return ok && npcAt(x, y, state) == null
    }
}

object World {
    val maps: Map<String, MapDef> by lazy {
        listOf(Story.village, Story.inn, Story.shop, Story.elderHouse, Story.temple, Story.forest, Story.deepForest, Story.cave).associateBy { it.id }
    }

    operator fun get(id: String): MapDef = maps[id] ?: error("Unknown map $id")
}
