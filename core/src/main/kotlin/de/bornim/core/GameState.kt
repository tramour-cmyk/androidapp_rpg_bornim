package de.bornim.core

import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@Serializable
enum class Facing(val dx: Int, val dy: Int) {
    DOWN(0, 1), UP(0, -1), LEFT(-1, 0), RIGHT(1, 0);

    val opposite: Facing
        get() = when (this) {
            DOWN -> UP
            UP -> DOWN
            LEFT -> RIGHT
            RIGHT -> LEFT
        }
}

@Serializable
data class Place(val map: String, val x: Int, val y: Int, val facing: Facing = Facing.DOWN)

@Serializable
class GameState(
    val hero: Hero,
    var gold: Int,
    val inventory: MutableMap<String, Int> = linkedMapOf(),
    val flags: MutableSet<String> = mutableSetOf(),
    val openedChests: MutableSet<String> = mutableSetOf(),
    var place: Place,
    var respawn: Place,
    var steps: Int = 0,
    var battlesWon: Int = 0,
    var version: Int = SAVE_VERSION,
    /** Equipment in the bag. */
    val bag: MutableList<Gear> = mutableListOf(),
    var uidCounter: Long = 0,
    /** Shop stock already bought, as "batch:uid". */
    val shopSold: MutableSet<String> = mutableSetOf(),
    /** Time of day in minutes (0..1439) and the day counter; one real second is one game minute. */
    var minutes: Int = 8 * 60,
    var day: Int = 1,
    /** Explored tiles per map (fog of war), as hex-encoded bits, row by row. */
    val explored: MutableMap<String, String> = mutableMapOf(),
    /**
     * Statuses the hero carries out of a fight, by [Status] name: poison and bleeding with the
     * rounds they still last (they tick on the map), a curse ([Status.WEAK]) until it is cured.
     */
    val ailments: MutableMap<String, Int> = linkedMapOf(),
    /** Flower patches already picked, as "map:x:y" to the day they were picked. */
    val picked: MutableMap<String, Int> = mutableMapOf(),
    /** A good meal: a small bonus in the next fight. */
    var wellFed: Boolean = false,
) {
    init {
        hero.chapter = Story.chapter(this)
    }

    fun nextUid(): Long = ++uidCounter

    fun ailment(st: Status): Int = ailments[st.name] ?: 0
    fun has(flag: String) = flag in flags
    fun count(item: String) = inventory[item] ?: 0

    fun add(item: String, n: Int = 1) {
        require(Items.exists(item)) { "Unknown item $item" }
        inventory[item] = count(item) + n
    }

    fun remove(item: String, n: Int = 1): Boolean {
        val c = count(item)
        if (c < n) return false
        if (c == n) inventory.remove(item) else inventory[item] = c - n
        return true
    }

    fun addGear(g: Gear): Gear {
        val owned = if (g.uid <= 0) g.copy(uid = nextUid()) else g
        bag += owned
        return owned
    }

    /** Equip gear from the bag; replaced items go back into the bag. */
    fun equipFromBag(g: Gear, offHand: Boolean = false): Boolean {
        if (!hero.canWear(g) || !bag.remove(g)) return false
        val removed = if (offHand) hero.equipOffHand(g) else hero.equip(g)
        bag += removed
        return true
    }

    fun unequipToBag(slot: GearSlot): Boolean {
        val g = hero.unequip(slot) ?: return false
        bag += g
        return true
    }

    /** Converts version 1 saves (item ids for equipment) to gear. */
    private fun migrate() {
        if (hero.legacyEquipment.isNotEmpty()) {
            val old = hero.legacyEquipment.values.toList()
            hero.legacyEquipment.clear()
            old.mapNotNull { Legacy.convert(it, nextUid()) }.forEach { hero.equip(it).forEach { r -> bag += r } }
        }
        for (id in inventory.keys.toList()) {
            if (Items.exists(id)) continue
            val n = inventory.remove(id) ?: 0
            repeat(n) { Legacy.convert(id, nextUid())?.let { bag += it } }
        }
        if (version < 3) {
            // Version 3: ability points only at levels 4, 8, 12, 16 and 19 (two each) …
            if (hero.fitPoints()) flags += POINTS_REFIT
            // … and the story items of chapter 1 were toned down.
            fun refresh(g: Gear) = g.unique?.takeIf { Uniques.exists(it) }?.let { Uniques.make(it, g.uid, g.ilvl) } ?: g
            for (slot in hero.gear.keys.toList()) hero.gear[slot] = refresh(hero.gear.getValue(slot))
            bag.replaceAll { refresh(it) }
        }
        if (version < 4) {
            // Version 4: a barrier on the north road, raised by Jorin. Heroes already on the quest find it open.
            if (Story.QUEST_STARTED in flags) flags += Story.BARRIER_OPEN
        }
        if (version < 5) {
            // Version 5: clerics start with a quarterstaff and a round shield. Plain starting mace and shield are
            // swapped for them; anything found, bought or bettered stays as it is.
            if (hero.cls == CharClass.CLERIC) {
                fun plain(g: Gear) = g.rarity == Rarity.COMMON && g.plus == 0 && g.rolls.isEmpty() && g.unique == null
                fun swap(g: Gear) = when {
                    !plain(g) -> g
                    g.base == "mace" -> g.copy(base = "quarterstaff")
                    g.base == "shield" -> g.copy(base = "round_shield")
                    else -> g
                }
                for (slot in hero.gear.keys.toList()) hero.gear[slot] = swap(hero.gear.getValue(slot))
                bag.replaceAll { swap(it) }
            }
        }
        version = SAVE_VERSION
        hero.clamp()
    }

    fun toJson(): String = json.encodeToString(this)

    companion object {
        const val SAVE_VERSION = 5
        /** Set when loading recalculated the hero's ability points; the game tells the player once. */
        const val POINTS_REFIT = "points_refit"
        private val json = Json { ignoreUnknownKeys = true; encodeDefaults = true; allowStructuredMapKeys = true }

        fun fromJson(s: String): GameState = json.decodeFromString(serializer(), s).also { it.migrate() }

        fun newGame(name: String, race: Race, cls: CharClass, bought: Map<Ability, Int>? = null): GameState {
            var uid = 0L
            val hero = Hero.create(name, race, cls, bought) { ++uid }
            val state = GameState(hero, cls.startGold, place = Story.START, respawn = Story.RESPAWN, uidCounter = uid)
            cls.startItems.forEach { id -> if (Items.exists(id)) state.add(id) }
            return state
        }
    }
}
