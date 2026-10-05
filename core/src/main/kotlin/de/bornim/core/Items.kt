package de.bornim.core

/** Stackable items: potions, throwables and story items. Equipment is [Gear]. */
enum class ItemKind { POTION, BOMB, KEY }

/** Icon shapes the app knows how to draw. */
enum class Icon {
    SWORD, DAGGER, AXE, MACE, HAMMER, SPEAR, STAFF, WAND, BOW, CROSSBOW,
    ARMOR, ROBE, SHIELD, ORB, TOME, SYMBOL, HELMET, HOOD, CIRCLET, GLOVES, BRACERS, LEGS, BOOTS,
    RING, AMULET, CLOAK, POTION, BIG_POTION, FLASK, KEY, SUN, NOTE,
}

data class ItemDef(
    val id: String,
    val name: T,
    val desc: T,
    val kind: ItemKind,
    val price: Int,
    val icon: Icon,
    val rarity: Rarity = Rarity.COMMON,
    val damage: DiceExpr? = null,
    val damageType: DamageType = DamageType.BLUDGEONING,
    val heal: DiceExpr? = null,
    /** Removes negative battle statuses (poison, burning, stun …). */
    val cures: Boolean = false,
) {
    val sellable: Boolean get() = kind != ItemKind.KEY && price > 0

    fun stats(lang: Lang): String = buildList {
        damage?.let { add("${it.label(lang)} ${damageType.title(lang)}") }
        heal?.let { add((if (lang == Lang.DE) "heilt " else "heals ") + it.label(lang)) }
    }.joinToString(" · ")
}

object Items {
    val all: List<ItemDef> = listOf(
        ItemDef("potion", T("Heiltrank", "Potion of Healing"), T("Heilt 2W4+2 TP.", "Heals 2d4+2 HP."),
            ItemKind.POTION, 25, Icon.POTION, heal = dice(2, 4, 2)),
        ItemDef("greater_potion", T("Großer Heiltrank", "Greater Healing Potion"), T("Heilt 4W4+4 TP.", "Heals 4d4+4 HP."),
            ItemKind.POTION, 75, Icon.BIG_POTION, Rarity.UNCOMMON, heal = dice(4, 4, 4)),
        ItemDef("superior_potion", T("Überragender Heiltrank", "Superior Healing Potion"), T("Heilt 8W4+8 TP.", "Heals 8d4+8 HP."),
            ItemKind.POTION, 200, Icon.BIG_POTION, Rarity.RARE, heal = dice(8, 4, 8)),
        ItemDef("remedy", T("Kräutertrank", "Herbal Remedy"), T("Heilt Vergiftung, Brand, Blutung, Betäubung und Flüche sowie 1W4 TP.", "Cures poison, burning, bleeding, stun and curses, and heals 1d4 HP."),
            ItemKind.POTION, 20, Icon.FLASK, heal = dice(1, 4), cures = true),
        ItemDef("alchemist_fire", T("Alchemistenfeuer", "Alchemist's Fire"), T("Wurfgeschoss: 2W6 Feuerschaden, trifft immer.", "Thrown: 2d6 fire damage, always hits."),
            ItemKind.BOMB, 30, Icon.FLASK, damage = dice(2, 6), damageType = DamageType.FIRE),
        ItemDef("holy_water", T("Weihwasser", "Holy Water"), T("Wurfgeschoss: 2W6 gleißender Schaden, 4W6 gegen Untote.", "Thrown: 2d6 radiant damage, 4d6 against undead."),
            ItemKind.BOMB, 25, Icon.FLASK, damage = dice(2, 6), damageType = DamageType.RADIANT),

        // Story items
        ItemDef("rusty_key", T("Rostiger Schlüssel", "Rusty Key"), T("Er gehörte Krogg dem Grobian.", "It belonged to Krogg the Brute."),
            ItemKind.KEY, 0, Icon.KEY),
        ItemDef("sun_amulet", T("Sonnenamulett", "Sun Amulet"), T("Das heilige Amulett aus dem Tempel von Bornim. Es ist warm.", "The holy amulet of the Bornim temple. It feels warm."),
            ItemKind.KEY, 0, Icon.SUN, Rarity.DIVINE),
        ItemDef("prophet_letter", T("Versiegelter Brief", "Sealed Letter"), T("Gezeichnet mit einem grauen Auge.", "Marked with a grey eye."),
            ItemKind.KEY, 0, Icon.NOTE),
    )

    private val byId = all.associateBy { it.id }
    operator fun get(id: String): ItemDef = byId[id] ?: error("Unknown item $id")
    fun exists(id: String) = id in byId
}

/** Maps item ids of save games from version 1 to the new gear system. */
object Legacy {
    class Conversion(val base: String, val rarity: Rarity = Rarity.COMMON, val plus: Int = 0, val unique: String? = null)

    val gear: Map<String, Conversion> = mapOf(
        "dagger" to Conversion("dagger"), "quarterstaff" to Conversion("quarterstaff"), "mace" to Conversion("mace"),
        "shortsword" to Conversion("shortsword"), "scimitar" to Conversion("scimitar"), "rapier" to Conversion("rapier"),
        "longsword" to Conversion("longsword"), "battleaxe" to Conversion("battleaxe"), "warhammer" to Conversion("warhammer"),
        "greatsword" to Conversion("greatsword"), "shortbow" to Conversion("shortbow"), "light_crossbow" to Conversion("light_crossbow"),
        "leather" to Conversion("leather"), "studded_leather" to Conversion("studded_leather"), "chain_shirt" to Conversion("chain_shirt"),
        "scale_mail" to Conversion("scale_mail"), "chain_mail" to Conversion("chain_mail"), "shield" to Conversion("shield"),
        "elven_chain" to Conversion("chain_shirt", Rarity.RARE, 1),
        "shield_plus1" to Conversion("shield", Rarity.UNCOMMON, 1),
        "longsword_plus1" to Conversion("longsword", unique = "longsword_oakford"),
        "rapier_plus1" to Conversion("rapier", unique = "rapier_whisper"),
        "shortsword_plus1" to Conversion("shortsword", Rarity.UNCOMMON, 1),
        "mace_of_dawn" to Conversion("mace", unique = "mace_of_dawn"),
        "staff_of_embers" to Conversion("staff", unique = "staff_of_embers"),
        "greataxe_grak" to Conversion("greataxe", unique = "greataxe_grak"),
        "ring_protection" to Conversion("ring", unique = "ring_protection"),
        "cloak_protection" to Conversion("cloak", unique = "cloak_protection"),
        "gauntlets_ogre" to Conversion("gloves", unique = "gauntlets_ogre"),
        "amulet_health" to Conversion("amulet", Rarity.RARE),
        "headband_intellect" to Conversion("circlet", Rarity.RARE),
        "periapt_wisdom" to Conversion("amulet", Rarity.RARE),
        "boots_elvenkind" to Conversion("boots", Rarity.RARE),
    )

    /** Fixed rolls for converted magic trinkets that had a single bonus. */
    val rolls: Map<String, List<Roll>> = mapOf(
        "amulet_health" to listOf(Roll(Affix.CON, 2), Roll(Affix.HP, 6)),
        "headband_intellect" to listOf(Roll(Affix.INT, 2), Roll(Affix.SPELL, 1)),
        "periapt_wisdom" to listOf(Roll(Affix.WIS, 2), Roll(Affix.SP, 2)),
        "boots_elvenkind" to listOf(Roll(Affix.DEX, 2), Roll(Affix.AC, 1)),
        "elven_chain" to listOf(Roll(Affix.DEX, 1), Roll(Affix.AC, 1)),
    )

    fun convert(id: String, uid: Long): Gear? {
        val c = gear[id] ?: return null
        c.unique?.let { return Uniques.make(it, uid, 3) }
        return Gear(uid, c.base, c.rarity, 3, c.plus, rolls[id] ?: emptyList())
    }
}
