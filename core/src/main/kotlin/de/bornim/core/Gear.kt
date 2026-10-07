package de.bornim.core

import kotlinx.serialization.Serializable

@Serializable
enum class Rarity(val title: T, val color: Long, val affixes: Int) {
    COMMON(T("gewöhnlich", "common"), 0xFF9A9AA6, 0),
    UNCOMMON(T("ungewöhnlich", "uncommon"), 0xFF3FB24F, 1),
    RARE(T("selten", "rare"), 0xFF3C7DE0, 2),
    VERY_RARE(T("sehr selten", "very rare"), 0xFF9A4FE0, 3),
    EPIC(T("episch", "epic"), 0xFFE8841A, 4),
    DIVINE(T("göttlich", "divine"), 0xFFE8C030, 5),
}

@Serializable
enum class GearSlot(val title: T) {
    HEAD(T("Kopf", "Head")),
    CHEST(T("Oberkörper", "Chest")),
    ARMS(T("Arme", "Arms")),
    LEGS(T("Beine", "Legs")),
    CLOAK(T("Umhang", "Cloak")),
    AMULET(T("Amulett", "Amulet")),
    RING(T("Ring", "Ring")),
    MAIN_HAND(T("Haupthand", "Main hand")),
    OFF_HAND(T("Nebenhand", "Off hand")),
}

/** How heavy a piece of armor is; decides which classes can wear it. CLOTH and NONE fit everyone. */
enum class Weight(val title: T) {
    NONE(T("", "")),
    CLOTH(T("Stoff", "cloth")),
    LIGHT(T("leicht", "light")),
    MEDIUM(T("mittel", "medium")),
    HEAVY(T("schwer", "heavy")),
}

/** German grammatical gender, for adjective endings in generated names. P = plural (gloves, boots). */
enum class Gender(val ending: String) { M("er"), F("e"), N("es"), P("e") }

enum class BaseKind { ARMOR, WEAPON, SHIELD, FOCUS, JEWELRY }

/** A type of equipment (Langschwert, Helm, …) from which concrete [Gear] is rolled. */
class GearBase(
    val id: String,
    val de: String,
    val gender: Gender,
    val en: String,
    val slot: GearSlot,
    val kind: BaseKind,
    val icon: Icon,
    val price: Int,
    /** Lowest item level at which this base drops. */
    val minLevel: Int = 1,
    val weight: Weight = Weight.NONE,
    /** Chest armor: SRD base AC. Shields: AC bonus. */
    val armor: Int = 0,
    val damage: DiceExpr? = null,
    val damageType: DamageType = DamageType.BLUDGEONING,
    val finesse: Boolean = false,
    val ranged: Boolean = false,
    val twoHanded: Boolean = false,
    /** Spell attack and spell DC bonus of foci, wands and staves. */
    val focus: Int = 0,
    /** SRD versatile: the damage when held in both hands (nothing in the other one), or null. */
    val versatile: DiceExpr? = null,
) {
    val name: T get() = T(de, en)
    val isWeapon: Boolean get() = kind == BaseKind.WEAPON
}

@Serializable
enum class Affix(val title: T, val prefixDe: String, val prefixEn: String, val suffixDe: String, val suffixEn: String, val percent: Boolean = false) {
    STR(T("Stärke", "Strength"), "Kräftig", "Mighty", "der Bärenkraft", "of the Bear"),
    DEX(T("Geschicklichkeit", "Dexterity"), "Flink", "Swift", "des Fuchses", "of the Fox"),
    CON(T("Konstitution", "Constitution"), "Robust", "Sturdy", "des Berges", "of the Mountain"),
    INT(T("Intelligenz", "Intelligence"), "Klug", "Clever", "des Gelehrten", "of the Scholar"),
    WIS(T("Weisheit", "Wisdom"), "Weis", "Wise", "der Eule", "of the Owl"),
    CHA(T("Charisma", "Charisma"), "Edl", "Noble", "des Königs", "of the King"),
    ALL_STATS(T("alle Attribute", "all abilities"), "Erhaben", "Exalted", "der Vollkommenheit", "of Perfection"),
    AC(T("Rüstungsklasse", "Armor Class"), "Schützend", "Warding", "der Bastion", "of the Bastion"),
    ATTACK(T("Angriff", "Attack"), "Präzis", "Precise", "der Präzision", "of Precision"),
    DAMAGE(T("Schaden", "Damage"), "Grausam", "Brutal", "des Gemetzels", "of Slaughter"),
    SPELL(T("Zauberkraft", "Spell power"), "Arkan", "Arcane", "der Magie", "of Sorcery"),
    HP(T("Trefferpunkte", "Hit points"), "Vital", "Vital", "des Lebens", "of Life"),
    SP(T("Zauberpunkte", "Spell points"), "Mystisch", "Mystic", "der Sterne", "of the Stars"),
    CRIT(T("Kritischer Bereich", "Critical range"), "Tödlich", "Deadly", "des Henkers", "of the Executioner"),
    FIRE(T("Feuerschaden", "Fire damage"), "Flammend", "Flaming", "der Glut", "of Embers"),
    RADIANT(T("Gleißender Schaden", "Radiant damage"), "Heilig", "Holy", "der Dämmerung", "of Dawn"),
    LIFESTEAL(T("Lebensraub", "Life steal"), "Blutdürstig", "Bloodthirsty", "des Vampirs", "of the Vampire", percent = true),
    RESIST(T("Schadensreduktion", "Damage reduction"), "Gehärtet", "Hardened", "des Steins", "of Stone"),
    GOLD_FIND(T("Goldfund", "Gold find"), "Gierig", "Greedy", "des Händlers", "of the Merchant", percent = true),
    MAGIC_FIND(T("Magiefund", "Magic find"), "Glücklich", "Lucky", "des Glücks", "of Fortune", percent = true),
    XP(T("Erfahrung", "Experience"), "Lehrreich", "Studious", "des Lernens", "of Learning", percent = true),
    POISON_HIT(T("Giftchance", "Poison chance"), "Giftig", "Venomous", "der Viper", "of the Viper", percent = true),
    BLEED_HIT(T("Blutungschance", "Bleed chance"), "Reißend", "Serrated", "der Wunden", "of Wounds", percent = true),
    STUN_HIT(T("Betäubungschance", "Stun chance"), "Betäubend", "Stunning", "des Donners", "of Thunder", percent = true),
    TENACITY(T("Standhaftigkeit", "Tenacity"), "Standhaft", "Steadfast", "des Ankers", "of the Anchor", percent = true),
    ;

    fun line(lang: Lang, value: Int): String = when (this) {
        CRIT -> if (lang == Lang.DE) "Kritisch ab ${20 - value}" else "Critical from ${20 - value}"
        FIRE, RADIANT -> "+$value ${title(lang)}"
        else -> "+$value${if (percent) "%" else ""} ${title(lang)}"
    }
}

@Serializable
data class Roll(val affix: Affix, val value: Int)

/** One concrete piece of equipment. */
@Serializable
data class Gear(
    val uid: Long,
    val base: String,
    val rarity: Rarity,
    val ilvl: Int,
    /** Enhancement bonus (+1, +2, +3) on weapons, chest armor and shields. */
    val plus: Int = 0,
    val rolls: List<Roll> = emptyList(),
    val nameSeed: Int = 0,
    /** Hand-made story items have a fixed name. */
    val unique: String? = null,
) {
    val def: GearBase get() = GearBases[base]
    val slot: GearSlot get() = def.slot

    fun total(a: Affix): Int = rolls.filter { it.affix == a }.sumOf { it.value }

    fun name(lang: Lang): String {
        unique?.let { return Uniques.name(it)(lang) }
        val d = def
        val de = lang == Lang.DE
        val baseName = if (de) d.de else d.en
        return when (rarity) {
            Rarity.COMMON -> baseName
            Rarity.EPIC -> epicName(lang)
            Rarity.DIVINE -> {
                val god = gods[Math.floorMod(nameSeed, gods.size)]
                if (de) "Göttlich${d.gender.ending} $baseName ${god.de}" else "Divine $baseName ${god.en}"
            }
            else -> {
                val first = rolls.getOrNull(0)?.affix
                val second = rolls.getOrNull(1)?.affix
                val prefix = first?.let { if (de) it.prefixDe + d.gender.ending else it.prefixEn }
                val suffix = (second ?: if (rarity == Rarity.UNCOMMON) null else first)?.let { if (de) it.suffixDe else it.suffixEn }
                when {
                    rarity == Rarity.UNCOMMON && nameSeed % 2 == 0 && first != null -> (if (de) first.suffixDe else first.suffixEn).let { "$baseName $it" }
                    suffix != null && prefix != null && second != null -> "$prefix $baseName $suffix"
                    prefix != null -> "$prefix $baseName"
                    else -> baseName
                }
            }
        }
    }

    private fun epicName(lang: Lang): String {
        val a = Math.floorMod(nameSeed, epicFirst.size)
        val b = Math.floorMod(nameSeed / 7, epicSecond.size)
        return if (lang == Lang.DE) epicFirst[a].de + epicSecond[b].de else epicFirst[a].en + epicSecond[b].en
    }

    /**
     * The line under the name in the bag and the shop: what it is (only when the name does not say so already), where
     * it is worn and the number that matters most. Rarity and two hands are not repeated: the picture shows them.
     */
    fun listLine(lang: Lang): String {
        val de = lang == Lang.DE
        val type = def.name(lang)
        val shown = name(lang)
        val parts = mutableListOf<String>()
        if (!shown.contains(type, ignoreCase = true)) parts += type + (if (plus > 0) " +$plus" else "")
        val where = when {
            def.isWeapon && def.ranged -> if (de) "Fernwaffe" else "Ranged weapon"
            def.isWeapon -> if (de) "Waffe" else "Weapon"
            else -> def.slot.title(lang)
        }
        if (!shown.contains(where, ignoreCase = true) && !type.equals(where, ignoreCase = true)) parts += where
        keyValue(lang)?.let { parts += it }
        return parts.joinToString(" · ")
    }

    /** The one number that tells most about it: a weapon's damage, armour's or a shield's AC, a focus's spell power. */
    fun keyValue(lang: Lang): String? {
        val de = lang == Lang.DE
        val dmg = def.damage
        return when {
            dmg != null -> dmg.copy(bonus = dmg.bonus + plus).label(lang) + (def.versatile?.let { "/" + it.copy(bonus = it.bonus + plus).label(lang) } ?: "") + " " + def.damageType.title(lang)
            def.slot == GearSlot.CHEST && def.armor > 0 -> (if (de) "RK " else "AC ") + (def.armor + plus)
            def.kind == BaseKind.SHIELD -> (if (de) "RK +" else "AC +") + (def.armor + plus)
            def.focus > 0 -> (if (de) "Zauberkraft +" else "Spell power +") + def.focus
            else -> null
        }
    }

    /**
     * The rarity in words once, at the head of its details, with the base type unless the name says it already:
     * "Epischer Topfhelm" for "Eisenbrecher", "Ungewöhnlich" for "Streitkolben des Donners"; nothing when the name
     * says both ("Göttliche Kettenbeinlinge des Morgenlichts").
     */
    fun kindLine(lang: Lang): String? {
        val plusText = if (plus > 0) " +$plus" else ""
        val r = rarity.title(lang).replaceFirstChar { it.uppercase() }
        val shown = name(lang)
        val hasType = shown.contains(def.name(lang), ignoreCase = true)
        return when {
            hasType && shown.contains(rarity.title(lang), ignoreCase = true) -> null
            hasType -> r + plusText
            lang == Lang.DE -> r + def.gender.ending + " " + def.de + plusText
            else -> "$r ${def.en}$plusText"
        }
    }

    /** Where it goes: "Haupt- oder Nebenhand", "Beide Hände", "Kopf" … */
    fun wearLine(lang: Lang): String {
        val de = lang == Lang.DE
        return when {
            def.isWeapon && def.twoHanded -> if (de) "Beide Hände" else "Both hands"
            def.versatile != null -> if (de) "Vielseitig: eine oder beide Hände" else "Versatile: one or both hands"
            def.isWeapon -> if (de) "Haupt- oder Nebenhand" else "Main or off hand"
            else -> def.slot.title(lang)
        }
    }

    val price: Int
        get() {
            val mult = when (rarity) {
                Rarity.COMMON -> 1.0
                Rarity.UNCOMMON -> 3.0
                Rarity.RARE -> 8.0
                Rarity.VERY_RARE -> 20.0
                Rarity.EPIC -> 50.0
                Rarity.DIVINE -> 150.0
            }
            return ((def.price + 10) * mult * (1 + ilvl / 5.0)).toInt()
        }

    companion object {
        private val epicFirst = listOf(
            T("Sturm", "Storm"), T("Schatten", "Shadow"), T("Seelen", "Soul"), T("Drachen", "Dragon"), T("Blut", "Blood"),
            T("Frost", "Frost"), T("Donner", "Thunder"), T("Aschen", "Ash"), T("Eisen", "Iron"), T("Sternen", "Star"),
            T("Nacht", "Night"), T("Greifen", "Griffin"),
        )
        private val epicSecond = listOf(
            T("wache", "ward"), T("brecher", "breaker"), T("fang", "fang"), T("ruf", "call"), T("zorn", "wrath"),
            T("hüter", "keeper"), T("biss", "bite"), T("schwur", "oath"), T("glanz", "gleam"), T("schneide", "edge"),
            T("herz", "heart"), T("sang", "song"),
        )
        private val gods = listOf(
            T("des Morgenlichts", "of the Dawnlight"), T("der Ewigen Flamme", "of the Eternal Flame"),
            T("des Sturmvaters", "of the Stormfather"), T("der Sternenmutter", "of the Star Mother"),
            T("des Eisernen Richters", "of the Iron Judge"), T("der Stillen Jägerin", "of the Silent Huntress"),
        )
    }
}

object GearBases {
    private fun armor(id: String, de: String, g: Gender, en: String, slot: GearSlot, icon: Icon, price: Int, weight: Weight, minLevel: Int = 1, ac: Int = 0) =
        GearBase(id, de, g, en, slot, BaseKind.ARMOR, icon, price, minLevel, weight, ac)

    private fun weapon(
        id: String, de: String, g: Gender, en: String, icon: Icon, price: Int, dmg: DiceExpr, type: DamageType,
        minLevel: Int = 1, finesse: Boolean = false, ranged: Boolean = false, twoHanded: Boolean = false, focus: Int = 0, versatile: DiceExpr? = null,
    ) = GearBase(id, de, g, en, GearSlot.MAIN_HAND, BaseKind.WEAPON, icon, price, minLevel, Weight.NONE, 0, dmg, type, finesse, ranged, twoHanded, focus, versatile)

    val all: List<GearBase> = listOf(
        // Head
        armor("hood", "Kapuze", Gender.F, "Hood", GearSlot.HEAD, Icon.HOOD, 2, Weight.CLOTH),
        armor("circlet", "Stirnreif", Gender.M, "Circlet", GearSlot.HEAD, Icon.CIRCLET, 15, Weight.CLOTH, 2),
        armor("leather_cap", "Lederkappe", Gender.F, "Leather Cap", GearSlot.HEAD, Icon.HELMET, 5, Weight.LIGHT),
        armor("helmet", "Helm", Gender.M, "Helmet", GearSlot.HEAD, Icon.HELMET, 15, Weight.MEDIUM, 2),
        armor("great_helm", "Topfhelm", Gender.M, "Great Helm", GearSlot.HEAD, Icon.HELMET, 40, Weight.HEAVY, 4),
        // Chest (SRD armor)
        armor("robe", "Robe", Gender.F, "Robe", GearSlot.CHEST, Icon.ROBE, 5, Weight.CLOTH),
        armor("leather", "Lederrüstung", Gender.F, "Leather Armor", GearSlot.CHEST, Icon.ARMOR, 10, Weight.LIGHT, ac = 11),
        armor("studded_leather", "Nietenleder", Gender.N, "Studded Leather", GearSlot.CHEST, Icon.ARMOR, 45, Weight.LIGHT, 2, ac = 12),
        armor("chain_shirt", "Kettenhemd", Gender.N, "Chain Shirt", GearSlot.CHEST, Icon.ARMOR, 50, Weight.MEDIUM, ac = 13),
        armor("scale_mail", "Schuppenpanzer", Gender.M, "Scale Mail", GearSlot.CHEST, Icon.ARMOR, 50, Weight.MEDIUM, 2, ac = 14),
        armor("breastplate", "Brustplatte", Gender.F, "Breastplate", GearSlot.CHEST, Icon.ARMOR, 400, Weight.MEDIUM, 4, ac = 14),
        armor("half_plate", "Halbplatte", Gender.F, "Half Plate", GearSlot.CHEST, Icon.ARMOR, 750, Weight.MEDIUM, 6, ac = 15),
        armor("chain_mail", "Kettenpanzer", Gender.M, "Chain Mail", GearSlot.CHEST, Icon.ARMOR, 75, Weight.HEAVY, 2, ac = 16),
        armor("splint", "Schienenpanzer", Gender.M, "Splint Armor", GearSlot.CHEST, Icon.ARMOR, 200, Weight.HEAVY, 4, ac = 17),
        armor("plate", "Plattenpanzer", Gender.M, "Plate Armor", GearSlot.CHEST, Icon.ARMOR, 1500, Weight.HEAVY, 7, ac = 18),
        // Arms
        armor("wraps", "Armwickel", Gender.P, "Arm Wraps", GearSlot.ARMS, Icon.BRACERS, 2, Weight.CLOTH),
        armor("gloves", "Lederhandschuhe", Gender.P, "Leather Gloves", GearSlot.ARMS, Icon.GLOVES, 5, Weight.LIGHT),
        armor("bracers", "Armschienen", Gender.P, "Bracers", GearSlot.ARMS, Icon.BRACERS, 20, Weight.MEDIUM, 2),
        armor("gauntlets", "Panzerhandschuhe", Gender.P, "Gauntlets", GearSlot.ARMS, Icon.GLOVES, 40, Weight.HEAVY, 3),
        // Legs
        armor("leggings", "Beinkleider", Gender.P, "Leggings", GearSlot.LEGS, Icon.LEGS, 2, Weight.CLOTH),
        armor("boots", "Lederstiefel", Gender.P, "Leather Boots", GearSlot.LEGS, Icon.BOOTS, 5, Weight.LIGHT),
        armor("chain_leggings", "Kettenbeinlinge", Gender.P, "Chain Leggings", GearSlot.LEGS, Icon.LEGS, 20, Weight.MEDIUM, 2),
        armor("greaves", "Beinschienen", Gender.P, "Greaves", GearSlot.LEGS, Icon.BOOTS, 40, Weight.HEAVY, 3),
        // Cloak and jewelry
        armor("cloak", "Umhang", Gender.M, "Cloak", GearSlot.CLOAK, Icon.CLOAK, 5, Weight.NONE),
        armor("mantle", "Mantel", Gender.M, "Mantle", GearSlot.CLOAK, Icon.CLOAK, 30, Weight.NONE, 3),
        GearBase("amulet", "Amulett", Gender.N, "Amulet", GearSlot.AMULET, BaseKind.JEWELRY, Icon.AMULET, 25),
        GearBase("talisman", "Talisman", Gender.M, "Talisman", GearSlot.AMULET, BaseKind.JEWELRY, Icon.AMULET, 60, 3),
        GearBase("ring", "Ring", Gender.M, "Ring", GearSlot.RING, BaseKind.JEWELRY, Icon.RING, 25),
        GearBase("signet", "Siegelring", Gender.M, "Signet Ring", GearSlot.RING, BaseKind.JEWELRY, Icon.RING, 60, 3),
        // One-handed weapons (SRD)
        weapon("dagger", "Dolch", Gender.M, "Dagger", Icon.DAGGER, 2, dice(1, 4), DamageType.PIERCING, finesse = true),
        weapon("shortsword", "Kurzschwert", Gender.N, "Shortsword", Icon.DAGGER, 10, dice(1, 6), DamageType.PIERCING, finesse = true),
        weapon("scimitar", "Krummsäbel", Gender.M, "Scimitar", Icon.SWORD, 25, dice(1, 6), DamageType.SLASHING, finesse = true),
        weapon("handaxe", "Handbeil", Gender.N, "Handaxe", Icon.AXE, 5, dice(1, 6), DamageType.SLASHING),
        weapon("mace", "Streitkolben", Gender.M, "Mace", Icon.MACE, 5, dice(1, 6), DamageType.BLUDGEONING),
        weapon("spear", "Speer", Gender.M, "Spear", Icon.SPEAR, 1, dice(1, 6), DamageType.PIERCING, versatile = dice(1, 8)),
        weapon("quarterstaff", "Kampfstab", Gender.M, "Quarterstaff", Icon.STAFF, 1, dice(1, 6), DamageType.BLUDGEONING, versatile = dice(1, 8)),
        weapon("rapier", "Rapier", Gender.N, "Rapier", Icon.SWORD, 25, dice(1, 8), DamageType.PIERCING, 2, finesse = true),
        weapon("longsword", "Langschwert", Gender.N, "Longsword", Icon.SWORD, 15, dice(1, 8), DamageType.SLASHING, versatile = dice(1, 10)),
        weapon("battleaxe", "Streitaxt", Gender.F, "Battleaxe", Icon.AXE, 10, dice(1, 8), DamageType.SLASHING, versatile = dice(1, 10)),
        weapon("warhammer", "Kriegshammer", Gender.M, "Warhammer", Icon.HAMMER, 15, dice(1, 8), DamageType.BLUDGEONING, 2, versatile = dice(1, 10)),
        weapon("wand", "Zauberstab", Gender.M, "Wand", Icon.WAND, 30, dice(1, 4), DamageType.FORCE, 2, focus = 1),
        // Two-handed weapons
        weapon("greatsword", "Zweihänder", Gender.M, "Greatsword", Icon.SWORD, 50, dice(2, 6), DamageType.SLASHING, 3, twoHanded = true),
        weapon("greataxe", "Großaxt", Gender.F, "Greataxe", Icon.AXE, 30, dice(1, 12), DamageType.SLASHING, 3, twoHanded = true),
        weapon("maul", "Zweihandhammer", Gender.M, "Maul", Icon.HAMMER, 10, dice(2, 6), DamageType.BLUDGEONING, 4, twoHanded = true),
        weapon("halberd", "Hellebarde", Gender.F, "Halberd", Icon.SPEAR, 20, dice(1, 10), DamageType.SLASHING, 2, twoHanded = true),
        weapon("staff", "Magierstab", Gender.M, "Arcane Staff", Icon.STAFF, 40, dice(1, 6), DamageType.BLUDGEONING, 2, twoHanded = true, focus = 2),
        weapon("shortbow", "Kurzbogen", Gender.M, "Shortbow", Icon.BOW, 25, dice(1, 6), DamageType.PIERCING, ranged = true, twoHanded = true),
        weapon("longbow", "Langbogen", Gender.M, "Longbow", Icon.BOW, 50, dice(1, 8), DamageType.PIERCING, 3, ranged = true, twoHanded = true),
        weapon("light_crossbow", "Armbrust", Gender.F, "Light Crossbow", Icon.CROSSBOW, 25, dice(1, 8), DamageType.PIERCING, 2, ranged = true, twoHanded = true),
        // Off-hand only
        GearBase("shield", "Schild", Gender.M, "Shield", GearSlot.OFF_HAND, BaseKind.SHIELD, Icon.SHIELD, 10, armor = 2),
        GearBase("round_shield", "Rundschild", Gender.M, "Round Shield", GearSlot.OFF_HAND, BaseKind.SHIELD, Icon.SHIELD, 10, armor = 2),
        GearBase("tower_shield", "Turmschild", Gender.M, "Tower Shield", GearSlot.OFF_HAND, BaseKind.SHIELD, Icon.SHIELD, 60, 5, armor = 3),
        GearBase("orb", "Zauberkugel", Gender.F, "Orb", GearSlot.OFF_HAND, BaseKind.FOCUS, Icon.ORB, 20, 1, focus = 1),
        GearBase("tome", "Foliant", Gender.M, "Tome", GearSlot.OFF_HAND, BaseKind.FOCUS, Icon.TOME, 25, 2, focus = 1),
        GearBase("holy_symbol", "Heiligensymbol", Gender.N, "Holy Symbol", GearSlot.OFF_HAND, BaseKind.FOCUS, Icon.SYMBOL, 5, 1, focus = 1),
    )

    private val byId = all.associateBy { it.id }
    operator fun get(id: String): GearBase = byId[id] ?: error("Unknown gear base $id")
    fun exists(id: String) = id in byId

    /** Which affixes can appear on which kind of item. */
    fun affixesFor(b: GearBase): List<Affix> {
        val stats = listOf(Affix.STR, Affix.DEX, Affix.CON, Affix.INT, Affix.WIS, Affix.CHA)
        return when {
            b.isWeapon && b.focus > 0 -> listOf(Affix.INT, Affix.WIS, Affix.SPELL, Affix.SP, Affix.ATTACK, Affix.DAMAGE, Affix.FIRE, Affix.CRIT, Affix.STUN_HIT)
            b.isWeapon -> listOf(
                Affix.STR, Affix.DEX, Affix.ATTACK, Affix.DAMAGE, Affix.CRIT, Affix.FIRE, Affix.RADIANT, Affix.LIFESTEAL,
                Affix.POISON_HIT, Affix.BLEED_HIT, Affix.STUN_HIT,
            )
            b.kind == BaseKind.SHIELD -> listOf(Affix.AC, Affix.HP, Affix.RESIST, Affix.CON, Affix.STR)
            b.kind == BaseKind.FOCUS -> listOf(Affix.SPELL, Affix.SP, Affix.INT, Affix.WIS, Affix.CHA, Affix.HP)
            b.slot == GearSlot.HEAD -> stats + listOf(Affix.AC, Affix.HP, Affix.SP, Affix.SPELL, Affix.MAGIC_FIND, Affix.XP)
            b.slot == GearSlot.CHEST -> listOf(Affix.AC, Affix.HP, Affix.RESIST, Affix.STR, Affix.DEX, Affix.CON, Affix.TENACITY)
            b.slot == GearSlot.ARMS -> listOf(Affix.STR, Affix.DEX, Affix.ATTACK, Affix.DAMAGE, Affix.CRIT, Affix.AC, Affix.LIFESTEAL, Affix.BLEED_HIT, Affix.POISON_HIT)
            b.slot == GearSlot.LEGS -> listOf(Affix.DEX, Affix.CON, Affix.AC, Affix.HP, Affix.RESIST, Affix.GOLD_FIND, Affix.TENACITY)
            b.slot == GearSlot.CLOAK -> listOf(Affix.AC, Affix.RESIST, Affix.DEX, Affix.CHA, Affix.HP, Affix.MAGIC_FIND, Affix.TENACITY)
            b.slot == GearSlot.AMULET -> stats + listOf(Affix.SPELL, Affix.HP, Affix.SP, Affix.XP, Affix.MAGIC_FIND, Affix.RESIST, Affix.TENACITY)
            else -> stats + listOf(Affix.ATTACK, Affix.DAMAGE, Affix.CRIT, Affix.SPELL, Affix.GOLD_FIND, Affix.MAGIC_FIND, Affix.LIFESTEAL, Affix.SP)
        }
    }
}

/** Hand-made story items. */
object Uniques {
    class Unique(val name: T, val base: String, val rarity: Rarity, val plus: Int, val rolls: List<Roll>)

    private val all = mapOf(
        // Chapter 1 story items are rare: special, but not stronger than the chapter allows.
        "ring_protection" to Unique(T("Ring des Ältesten", "Elder's Ring"), "ring", Rarity.RARE, 0,
            listOf(Roll(Affix.AC, 1), Roll(Affix.HP, 6))),
        "gauntlets_ogre" to Unique(T("Handschuhe der Ogerkraft", "Gauntlets of Ogre Power"), "gloves", Rarity.RARE, 0,
            listOf(Roll(Affix.STR, 1), Roll(Affix.DAMAGE, 1))),
        "greataxe_grak" to Unique(T("Graks Kriegsaxt", "Grak's War Axe"), "greataxe", Rarity.RARE, 1,
            listOf(Roll(Affix.STR, 1), Roll(Affix.DAMAGE, 2))),
        "longsword_oakford" to Unique(T("Klinge von Bornim", "Blade of Bornim"), "longsword", Rarity.RARE, 1,
            listOf(Roll(Affix.STR, 1), Roll(Affix.RADIANT, 2))),
        "staff_of_embers" to Unique(T("Glutstab", "Staff of Embers"), "staff", Rarity.RARE, 1,
            listOf(Roll(Affix.INT, 1), Roll(Affix.FIRE, 2))),
        "rapier_whisper" to Unique(T("Flüsterklinge", "Whisperblade"), "rapier", Rarity.RARE, 1,
            listOf(Roll(Affix.DEX, 1), Roll(Affix.CRIT, 1))),
        "mace_of_dawn" to Unique(T("Morgenröte", "Dawnbringer"), "mace", Rarity.RARE, 1,
            listOf(Roll(Affix.WIS, 1), Roll(Affix.RADIANT, 2))),
        "amulet_grimfang" to Unique(T("Grimmzahns Fang", "Grimfang's Tooth"), "amulet", Rarity.RARE, 0,
            listOf(Roll(Affix.DEX, 1), Roll(Affix.BLEED_HIT, 15), Roll(Affix.HP, 6))),
        "cloak_protection" to Unique(T("Umhang des Schutzes", "Cloak of Protection"), "cloak", Rarity.RARE, 0,
            listOf(Roll(Affix.AC, 1), Roll(Affix.RESIST, 1))),
    )

    fun name(id: String): T = all[id]?.name ?: T(id, id)
    fun exists(id: String) = id in all
    fun make(id: String, uid: Long, ilvl: Int): Gear {
        val u = all.getValue(id)
        return Gear(uid, u.base, u.rarity, ilvl, u.plus, u.rolls, 0, id)
    }
}
