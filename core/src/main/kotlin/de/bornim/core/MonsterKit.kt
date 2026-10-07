package de.bornim.core

/**
 * What a foe of the new style wears and carries: a look only, its numbers stay those of its [MonsterDef]. Every kind
 * has at least three kits, picked by the foe's look seed, so no goblin looks like the one before. A kit may name its
 * own attack (a hand axe instead of the scimitar), always of the same kind of damage.
 */
data class MonsterKit(
    val items: Map<GearSlot, String>,
    /** The attack's name when it differs from the monster's own. */
    val attack: T? = null,
    /** Old iron: brown and flaking. */
    val rusty: Boolean = false,
    /** A shield of bare nailed planks rather than a painted one. */
    val crude: Boolean = false,
    /** A mangy pelt over the shoulders. */
    val pelt: Boolean = false,
)

object MonsterKits {
    private val S = GearSlot.MAIN_HAND
    private val O = GearSlot.OFF_HAND
    private val C = GearSlot.CHEST
    private val H = GearSlot.HEAD

    private val KITS: Map<String, List<MonsterKit>> = mapOf(
        // SRD goblin: scimitar, leather armour, shield; the hand axe cuts the same
        "goblin" to listOf(
            MonsterKit(mapOf(S to "scimitar", O to "round_shield", C to "leather"), rusty = true, crude = true, pelt = true),
            MonsterKit(mapOf(S to "handaxe", C to "leather", H to "leather_cap"), attack = T("Handbeil", "Hand Axe"), rusty = true, pelt = true),
            // two blades, the scimitar and a dagger in the other hand
            MonsterKit(mapOf(S to "scimitar", O to "dagger", H to "helmet"), rusty = true),
        ),
        // the goblin scout keeps to the shortbow
        "goblin_archer" to listOf(
            MonsterKit(mapOf(S to "shortbow", C to "leather", H to "hood"), rusty = true),
            MonsterKit(mapOf(S to "shortbow", H to "leather_cap"), rusty = true, pelt = true),
            MonsterKit(mapOf(S to "shortbow", C to "leather"), rusty = true, pelt = true),
        ),
        // SRD skeleton: shortsword, scraps of armour; the spear pierces the same
        "skeleton" to listOf(
            MonsterKit(mapOf(S to "shortsword", H to "helmet"), rusty = true),
            MonsterKit(mapOf(S to "shortsword", O to "round_shield"), rusty = true, crude = true),
            // armour laid over bare bones reads as a body: the dead keep only helm and weapon
            MonsterKit(mapOf(S to "spear", H to "helmet"), attack = T("Speer", "Spear"), rusty = true),
        ),
    )

    /** How many kits a kind of foe has; 0 for foes still drawn the old way. */
    fun variants(id: String): Int = KITS[id]?.size ?: 0

    /** The kit of one foe, chosen by its look seed. */
    fun of(id: String, seed: Int): MonsterKit? = KITS[id]?.let { it[seed.mod(it.size)] }

    /** The skin, hide or bone tone of one foe, chosen apart from its kit so the two vary on their own. */
    fun tone(seed: Int): Int = (seed / 3).mod(4)

    private fun mixed(seed: Int, salt: Int): Int {
        var n = seed * 374761393 + salt * 668265263
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    /**
     * How tall one foe stands against the usual height of its kind, within the SRD's size: goblins 98–118 cm
     * (Small, 3–4 ft), the risen dead as tall as the people they were, about 160–185 cm.
     */
    fun size(id: String, seed: Int): Double {
        val t = (mixed(seed, 7) % 1000) / 999.0
        return when (id) {
            "goblin", "goblin_archer" -> 0.91 + 0.18 * t
            "skeleton" -> 0.93 + 0.145 * t
            else -> 1.0
        }
    }

    /** Slim, average or strong, apart from size and kit. */
    fun build(seed: Int): Build = Build.entries[mixed(seed, 11) % Build.entries.size]
}
