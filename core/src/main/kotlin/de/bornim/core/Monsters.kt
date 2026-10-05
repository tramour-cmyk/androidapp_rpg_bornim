package de.bornim.core

enum class MonsterSpecial {
    NONE,
    /** Wolf: on a hit the target must make a STR save or is knocked prone (next attack at disadvantage). */
    KNOCKDOWN,
    /** Giant spider: extra poison damage, CON save for half. */
    POISON,
    /** Hobgoblin: deals extra damage every third turn, starting with the first. */
    MARTIAL_ADVANTAGE,
    /** Zombie: CON save to drop to 1 HP instead of 0, unless the damage was radiant or a critical. */
    UNDEAD_FORTITUDE,
    /** Bugbear: the first hit of the battle deals extra damage. */
    SURPRISE_ATTACK,
    /** Boar: the first hit deals extra damage, and once per fight it stays standing at 1 HP. */
    CHARGE,
    /** Stirge: a hit drains extra blood and heals the stirge. */
    BLOOD_DRAIN,
    /** Kobold: comes with one or two pack mates that jab from behind until the leader falls. */
    PACK_TACTICS,
    /** Ghoul: a hit can paralyze (CON save, elves are immune); the ghoul then strikes again. */
    PARALYZE,
    /** Giant bat: flutters out of the way of some melee attacks. */
    EVASIVE,
    /** Ochre jelly: extra acid damage that also eats away at the hero's armor. */
    ACID,
    /** Goblin shaman: heals itself when hurt and alternates fire bolts with staff blows. */
    SHAMAN,
}

/** Elite monsters get one of these traits: a name, an aura color and a real effect in battle. */
enum class EliteTrait(private val de: String, private val en: String, val color: Int, val desc: T) {
    SAVAGE("Wild", "Savage", 0xFFFF5A3C.toInt(), T("Er schlägt mit roher Wucht zu.", "It strikes with raw force.")),
    ANCIENT("Uralt", "Ancient", 0xFFB48CFF.toInt(), T("Er ist zäh wie altes Holz.", "It is tough as old oak.")),
    SWIFT("Flink", "Swift", 0xFF40E0FF.toInt(), T("Er ist blitzschnell und schwer zu treffen.", "It is lightning fast and hard to hit.")),
    VENOMOUS("Giftig", "Venomous", 0xFF96F046.toInt(), T("Seine Angriffe sind vergiftet.", "Its attacks are poisoned.")),
    BURNING("Glühend", "Burning", 0xFFFFA028.toInt(), T("Er brennt vor unheiliger Glut.", "It burns with an unholy glow.")),
    VAMPIRIC("Blutdurstig", "Bloodthirsty", 0xFFFF3C78.toInt(), T("Er nährt sich von deinem Blut.", "It feeds on your blood.")),
    ;

    fun adjective(lang: Lang, g: Gender): String = if (lang == Lang.EN) en else de + ending(g)

    companion object {
        fun ending(g: Gender) = g.ending
        fun shiny(lang: Lang, g: Gender) = if (lang == Lang.EN) "Shimmering" else "Schimmernd" + ending(g)
    }
}

/** A fixed drop: a stackable item id or the id of a unique piece of gear. */
data class LootEntry(val item: String, val chance: Double)

data class MonsterDef(
    val id: String,
    val name: T,
    val ac: Int,
    val hp: DiceExpr,
    val attackName: T,
    val attackBonus: Int,
    val damage: DiceExpr,
    val damageType: DamageType,
    val xp: Int,
    val gold: DiceExpr,
    val dexSave: Int,
    val conSave: Int,
    val wisSave: Int,
    val loot: List<LootEntry> = emptyList(),
    val undead: Boolean = false,
    val vulnerable: Set<DamageType> = emptySet(),
    val resistant: Set<DamageType> = emptySet(),
    val immune: Set<DamageType> = emptySet(),
    val special: MonsterSpecial = MonsterSpecial.NONE,
    /** Bosses drink a potion once when below half HP. */
    val potions: Int = 0,
    val boss: Boolean = false,
    val cr: String,
    /** How the monster's attack looks on screen. */
    val attackFx: FxKind = FxKind.SLASH,
    val gender: Gender = Gender.M,
    /** Damage per round of the poison from [MonsterSpecial.POISON] (CON save avoids it). */
    val poison: DiceExpr = dice(1, 6),
)

/** Monster statistics follow the SRD 5.1, slightly simplified. */
object Monsters {
    val all = listOf(
        MonsterDef(
            "giant_rat", T("Riesenratte", "Giant Rat"), 12, dice(2, 6), T("Biss", "Bite"), 4, dice(1, 4, 2), DamageType.PIERCING,
            25, dice(1, 4), 2, 0, 0, listOf(LootEntry("potion", 0.08)), attackFx = FxKind.BITE, cr = "1/8", gender = Gender.F,
        ),
        MonsterDef(
            "wolf", T("Wolf", "Wolf"), 13, dice(2, 8, 2), T("Biss", "Bite"), 4, dice(2, 4, 2), DamageType.PIERCING,
            50, dice(1, 6), 2, 1, 1, listOf(LootEntry("potion", 0.12)),
            special = MonsterSpecial.KNOCKDOWN, attackFx = FxKind.BITE, cr = "1/4",
        ),
        MonsterDef(
            "goblin", T("Goblin", "Goblin"), 15, dice(2, 6), T("Krummsäbel", "Scimitar"), 4, dice(1, 6, 2), DamageType.SLASHING,
            50, dice(2, 6), 2, 0, -1,
            listOf(LootEntry("potion", 0.15), LootEntry("alchemist_fire", 0.06)),
            cr = "1/4",
        ),
        MonsterDef(
            "goblin_archer", T("Goblin-Späher", "Goblin Scout"), 13, dice(2, 6, 1), T("Kurzbogen", "Shortbow"), 4, dice(1, 6, 2), DamageType.PIERCING,
            50, dice(2, 8), 2, 0, 0,
            listOf(LootEntry("potion", 0.15), LootEntry("alchemist_fire", 0.05)),
            attackFx = FxKind.ARROW, cr = "1/4",
        ),
        MonsterDef(
            "skeleton", T("Skelett", "Skeleton"), 13, dice(2, 8, 4), T("Kurzschwert", "Shortsword"), 4, dice(1, 6, 2), DamageType.PIERCING,
            50, dice(1, 8), 2, 2, -1,
            listOf(LootEntry("potion", 0.08), LootEntry("holy_water", 0.04)),
            undead = true, vulnerable = setOf(DamageType.BLUDGEONING), immune = setOf(DamageType.POISON), attackFx = FxKind.PIERCE, cr = "1/4",
            gender = Gender.N,
        ),
        MonsterDef(
            "zombie", T("Zombie", "Zombie"), 8, dice(3, 8, 9), T("Hieb", "Slam"), 3, dice(1, 6, 1), DamageType.BLUDGEONING,
            50, dice(1, 6), -2, 3, -2,
            listOf(LootEntry("potion", 0.10), LootEntry("holy_water", 0.06)),
            undead = true, immune = setOf(DamageType.POISON), special = MonsterSpecial.UNDEAD_FORTITUDE, attackFx = FxKind.SMASH, cr = "1/4",
        ),
        MonsterDef(
            "giant_spider", T("Riesenspinne", "Giant Spider"), 14, dice(4, 10, 4), T("Biss", "Bite"), 5, dice(1, 8, 3), DamageType.PIERCING,
            200, dice(2, 10), 3, 1, 0,
            listOf(LootEntry("greater_potion", 0.15), LootEntry("cloak_protection", 0.03)),
            special = MonsterSpecial.POISON, attackFx = FxKind.BITE, cr = "1", gender = Gender.F,
        ),
        MonsterDef(
            "bugbear", T("Krogg der Grobian", "Krogg the Brute"), 16, dice(5, 8, 5), T("Morgenstern", "Morningstar"), 4, dice(2, 8, 2), DamageType.PIERCING,
            200, dice(4, 10), 2, 1, 0,
            listOf(LootEntry("rusty_key", 1.0), LootEntry("gauntlets_ogre", 1.0)),
            special = MonsterSpecial.SURPRISE_ATTACK, boss = true, attackFx = FxKind.SMASH, cr = "1",
        ),
        MonsterDef(
            "hobgoblin_captain", T("Hauptmann Grak", "Captain Grak"), 16, dice(6, 10, 6), T("Kriegsaxt", "War Axe"), 5, dice(1, 10, 3), DamageType.SLASHING,
            450, dice(8, 10), 1, 2, 1,
            listOf(LootEntry("sun_amulet", 1.0), LootEntry("prophet_letter", 1.0), LootEntry("greataxe_grak", 1.0)),
            special = MonsterSpecial.MARTIAL_ADVANTAGE, potions = 1, boss = true, cr = "2",
        ),
        MonsterDef(
            "boar", T("Wildschwein", "Boar"), 11, dice(2, 8, 2), T("Hauer", "Tusk"), 3, dice(1, 6, 1), DamageType.SLASHING,
            50, dice(1, 3), 0, 2, -1, listOf(LootEntry("potion", 0.08)),
            special = MonsterSpecial.CHARGE, attackFx = FxKind.SMASH, cr = "1/4", gender = Gender.N,
        ),
        MonsterDef(
            "stirge", T("Stirge", "Stirge"), 14, dice(2, 4, 1), T("Rüssel", "Proboscis"), 5, dice(1, 4, 2), DamageType.PIERCING,
            25, dice(1, 3), 3, 0, -1, listOf(LootEntry("potion", 0.06)),
            special = MonsterSpecial.BLOOD_DRAIN, attackFx = FxKind.PIERCE, cr = "1/8", gender = Gender.F,
        ),
        MonsterDef(
            "giant_centipede", T("Riesen-Hundertfüßer", "Giant Centipede"), 13, dice(2, 6, 1), T("Biss", "Bite"), 4, dice(1, 4, 2), DamageType.PIERCING,
            50, dice(1, 3), 2, 1, -2, listOf(LootEntry("potion", 0.1)),
            special = MonsterSpecial.POISON, poison = dice(1, 4), attackFx = FxKind.BITE, cr = "1/4",
        ),
        MonsterDef(
            "kobold", T("Kobold", "Kobold"), 12, dice(2, 6, 1), T("Speer", "Spear"), 4, dice(1, 4, 2), DamageType.PIERCING,
            25, dice(2, 4), 2, -1, -2, listOf(LootEntry("potion", 0.12), LootEntry("alchemist_fire", 0.04)),
            special = MonsterSpecial.PACK_TACTICS, attackFx = FxKind.PIERCE, cr = "1/8",
        ),
        MonsterDef(
            "goblin_shaman", T("Goblin-Schamane", "Goblin Shaman"), 12, dice(4, 6), T("Stab", "Staff"), 3, dice(1, 6), DamageType.BLUDGEONING,
            100, dice(3, 6), 2, 0, 2, listOf(LootEntry("potion", 0.25), LootEntry("greater_potion", 0.06)),
            special = MonsterSpecial.SHAMAN, attackFx = FxKind.SMASH, cr = "1/2",
        ),
        MonsterDef(
            "giant_bat", T("Riesenfledermaus", "Giant Bat"), 13, dice(4, 10), T("Biss", "Bite"), 4, dice(1, 6, 2), DamageType.PIERCING,
            50, dice(1, 4), 3, 0, 1, listOf(LootEntry("potion", 0.1)),
            special = MonsterSpecial.EVASIVE, attackFx = FxKind.BITE, cr = "1/4", gender = Gender.F,
        ),
        MonsterDef(
            "ghoul", T("Ghul", "Ghoul"), 12, dice(5, 8), T("Klauen", "Claws"), 4, dice(2, 4, 2), DamageType.SLASHING,
            200, dice(2, 8), 2, 0, 0, listOf(LootEntry("greater_potion", 0.15), LootEntry("holy_water", 0.06)),
            undead = true, immune = setOf(DamageType.POISON), special = MonsterSpecial.PARALYZE, attackFx = FxKind.SLASH, cr = "1",
        ),
        MonsterDef(
            "ochre_jelly", T("Ockergallerte", "Ochre Jelly"), 8, dice(5, 10, 5), T("Scheinfuß", "Pseudopod"), 4, dice(1, 8, 2), DamageType.BLUDGEONING,
            450, dice(3, 10), -2, 2, -4, listOf(LootEntry("greater_potion", 0.2)),
            resistant = setOf(DamageType.SLASHING, DamageType.ACID), special = MonsterSpecial.ACID, attackFx = FxKind.SMASH, cr = "2",
            gender = Gender.F,
        ),
    )

    /** Number of pack mates a pack monster brings along; fixed per look, so map and battle agree. */
    fun packSize(m: MonsterDef, look: MonsterLook): Int = if (m.special == MonsterSpecial.PACK_TACTICS) 1 + look.pick(2, 50) else 0

    private val byId = all.associateBy { it.id }
    operator fun get(id: String): MonsterDef = byId[id] ?: error("Unknown monster $id")
}
