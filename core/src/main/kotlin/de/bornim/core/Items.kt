package de.bornim.core

/** Stackable items: potions, throwables and story items. Equipment is [Gear]. */
/** [TONIC]: drunk outside a fight only (86.6). */
enum class ItemKind { POTION, BOMB, KEY, FOOD, INGREDIENT, TONIC }

/** Icon shapes the app knows how to draw. */
enum class Icon {
    SWORD, DAGGER, AXE, MACE, HAMMER, SPEAR, STAFF, WAND, BOW, CROSSBOW,
    ARMOR, ROBE, SHIELD, ORB, TOME, SYMBOL, HELMET, HOOD, CIRCLET, GLOVES, BRACERS, LEGS, BOOTS,
    RING, AMULET, CLOAK, TORCH, POTION, BIG_POTION, FLASK, KEY, SUN, NOTE,
    MEAT, ROAST, PELT, TUSK, GLAND, WING, HERB,
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
        ItemDef("potion", T("Heiltrank", "Potion of Healing"), T("Ein klassischer roter Heiltrank. Wirkt sofort, auch im Kampf.", "A classic red healing potion. Works at once, also in battle."),
            ItemKind.POTION, 25, Icon.POTION, heal = dice(2, 4, 2)),
        ItemDef("greater_potion", T("Großer Heiltrank", "Potion of Greater Healing"), T("Doppelt so stark wie der einfache Heiltrank. Wirkt sofort, auch im Kampf.", "Twice as strong as the plain healing potion. Works at once, also in battle."),
            ItemKind.POTION, 75, Icon.BIG_POTION, Rarity.UNCOMMON, heal = dice(4, 4, 4)),
        ItemDef("superior_potion", T("Überragender Heiltrank", "Potion of Superior Healing"), T("Ein seltenes Elixier für schwere Wunden. Wirkt sofort, auch im Kampf.", "A rare elixir for grave wounds. Works at once, also in battle."),
            ItemKind.POTION, 200, Icon.BIG_POTION, Rarity.RARE, heal = dice(8, 4, 8)),
        ItemDef("remedy", T("Kräutertrank", "Herbal Remedy"), T("Heilt alle Zustände: Vergiftung, Brand, Blutung, Betäubung, Flüche. Auch mit vollen TP trinkbar.", "Cures every condition: poison, burning, bleeding, stun, curses. Can be drunk even at full HP."),
            ItemKind.POTION, 20, Icon.FLASK, heal = dice(1, 4), cures = true),
        // 86.6: priced like the healing potion
        ItemDef("stamina_potion", T("Ausdauertrank", "Stamina Draught"), T("Bis zur nächsten Rast reicht der Atem beim Rennen doppelt so lange. Nicht im Kampf.", "Until the next rest, your breath for running lasts twice as long. Not in battle."),
            ItemKind.TONIC, 25, Icon.FLASK),
        // 84.5 (Chef 18.10.): priced like the stamina draught; brewed by Morwen, sold by Thessa; [84.5.laden] (84.1T)
        ItemDef("spark_potion", T("Leuchtfunke", "Lightspark"), T("Ein Fläschchen, von Morwen gebraut. Getrunken steigt ein Funke auf und leuchtet über dir bis zur nächsten Rast. Im Dunkeln siehst du weiter, aber Monster bemerken dich früher. Nicht im Kampf.", "A flask brewed by Morwen. Drink it, and a spark rises to glow above you until your next rest. In the dark you see further, but monsters notice you sooner. Not in battle."),
            ItemKind.TONIC, 25, Icon.FLASK),
        ItemDef("alchemist_fire", T("Alchemistenfeuer", "Alchemist's Fire"), T("Wurfgeschoss, trifft immer und setzt den Gegner in Brand.", "Thrown, always hits and sets the foe on fire."),
            ItemKind.BOMB, 30, Icon.FLASK, damage = dice(2, 6), damageType = DamageType.FIRE),
        ItemDef("holy_water", T("Weihwasser", "Holy Water"), T("Wurfgeschoss, trifft immer. Wirkt nur gegen Untote: 2W6 gleißender Schaden.", "Thrown, always hits. Only harms undead: 2d6 radiant damage."),
            ItemKind.BOMB, 25, Icon.FLASK, damage = dice(2, 6), damageType = DamageType.RADIANT),

        // Food and ingredients: sold, roasted at a campfire or brewed into potions by Morwen.
        ItemDef("raw_meat", T("Rohes Fleisch", "Raw Meat"), T("Am Lagerfeuer lässt es sich braten. Oder man verkauft es.", "Can be roasted at a campfire. Or sold."),
            ItemKind.INGREDIENT, 6, Icon.MEAT),
        ItemDef("roast_meat", T("Gebratenes Fleisch", "Roast Meat"), T("Stärkt für den nächsten Kampf: +1 auf Angriffe und Schaden.", "Fortifies for the next fight: +1 to attacks and damage."),
            ItemKind.FOOD, 16, Icon.ROAST, heal = dice(2, 4, 2)),
        ItemDef("herbs", T("Heilkräuter", "Healing Herbs"), T("Wachsen auf Blumenwiesen in der Wildnis. Morwen braut daraus Tränke.", "Grow in wild flower meadows. Morwen brews potions from them."),
            ItemKind.INGREDIENT, 8, Icon.HERB),
        ItemDef("wolf_pelt", T("Wolfsfell", "Wolf Pelt"), T("Ein dichtes graues Fell. Händler zahlen gut dafür.", "A thick gray pelt. Traders pay well for it."),
            ItemKind.INGREDIENT, 24, Icon.PELT),
        ItemDef("boar_tusk", T("Keilerhauer", "Boar Tusk"), T("Ein gebogener Hauer. Händler zahlen gut dafür.", "A curved tusk. Traders pay well for it."),
            ItemKind.INGREDIENT, 20, Icon.TUSK),
        ItemDef("spider_gland", T("Giftdrüse", "Venom Gland"), T("Aus einer Riesenspinne. Morwen kann daraus Alchemistenfeuer mischen.", "From a giant spider. Morwen can mix alchemist's fire from it."),
            ItemKind.INGREDIENT, 30, Icon.GLAND),
        ItemDef("bat_wing", T("Fledermausflügel", "Bat Wing"), T("Ledrig und zäh. Eine Zutat für starke Heiltränke.", "Leathery and tough. An ingredient for strong healing potions."),
            ItemKind.INGREDIENT, 16, Icon.WING),

        // Story items
        ItemDef("gwenna_ring", T("Gwennas Ring", "Gwenna's Ring"), T("Ein schmaler Ring aus angelaufenem Silber. Gwenna wartet am Fluss darauf.", "A slim ring of tarnished silver. Gwenna is waiting for it by the river."),
            ItemKind.KEY, 0, Icon.RING),
        ItemDef("grey_rag", T("Grauer Fetzen", "Gray Rag"), T("Grobes graues Tuch, ein offenes Auge hineingestickt. Jorin will es sehen.", "Coarse gray cloth, an open eye stitched into it. Jorin wants to see it."),
            ItemKind.KEY, 0, Icon.CLOAK),
        // D4.1: [D4.1.rauch.tasche]
        ItemDef("smoke_bundle", T("Rauchbündel", "Smoke Bundle"), T("Ein Bündel beißender Kräuter von Morwen. Krogg vor die Füße werfen: Der Rauch nimmt ihm den ersten Hieb. Nur im Kampf.", "A bundle of acrid herbs from Morwen. Throw it at Krogg's feet: the smoke takes away his first blow. Only in battle."),
            ItemKind.KEY, 0, Icon.HERB),
        ItemDef("rusty_key", T("Rostiger Schlüssel", "Rusty Key"), T("Er gehörte Krogg dem Grobian.", "It belonged to Krogg the Brute."),
            ItemKind.KEY, 0, Icon.KEY),
        ItemDef("sun_amulet", T("Sonnenamulett", "Sun Amulet"), T("Das heilige Amulett aus dem Tempel von Bornim. Es ist warm.", "The holy amulet of the Bornim temple. It feels warm."),
            ItemKind.KEY, 0, Icon.SUN, Rarity.DIVINE),
        ItemDef("prophet_letter", T("Versiegelter Brief", "Sealed Letter"), T("Gezeichnet mit einem grauen Auge.", "Marked with a gray eye."),
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
