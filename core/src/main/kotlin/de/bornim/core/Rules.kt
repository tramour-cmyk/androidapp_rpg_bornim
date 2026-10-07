package de.bornim.core

import kotlinx.serialization.Serializable

@Serializable
enum class Ability(val short: T, val full: T) {
    STR(T("STÄ", "STR"), T("Stärke", "Strength")),
    DEX(T("GES", "DEX"), T("Geschicklichkeit", "Dexterity")),
    CON(T("KON", "CON"), T("Konstitution", "Constitution")),
    INT(T("INT", "INT"), T("Intelligenz", "Intelligence")),
    WIS(T("WEI", "WIS"), T("Weisheit", "Wisdom")),
    CHA(T("CHA", "CHA"), T("Charisma", "Charisma")),
}

enum class ArmorCategory(val title: T) {
    LIGHT(T("leicht", "light")),
    MEDIUM(T("mittel", "medium")),
    HEAVY(T("schwer", "heavy")),
}

enum class DamageType(val title: T) {
    SLASHING(T("Hieb", "slashing")),
    PIERCING(T("Stich", "piercing")),
    BLUDGEONING(T("Wucht", "bludgeoning")),
    FIRE(T("Feuer", "fire")),
    FORCE(T("Energie", "force")),
    RADIANT(T("gleißend", "radiant")),
    POISON(T("Gift", "poison")),
    ACID(T("Säure", "acid")),
}

object Rules {
    const val MAX_LEVEL = 20
    const val MAX_SCORE = 20

    /** Halved SRD experience thresholds (index = level). */
    val xpForLevel = intArrayOf(
        0, 0, 150, 450, 1350, 3250, 7000, 11500, 17000, 24000, 32000,
        42500, 50000, 60000, 70000, 82500, 97500, 112500, 132500, 152500, 177500,
    )

    /** Standard array from the SRD: the starting scores of heroes created before point buy. */
    val standardArray = intArrayOf(15, 14, 13, 12, 10, 8)

    /** Point buy at character creation: a budget a little below the SRD's 27, scores 8–15 before race. */
    const val POINT_BUY = 24
    const val POINT_BUY_MIN = 8
    const val POINT_BUY_MAX = 15

    /** SRD point-buy cost of a score. */
    fun pointCost(score: Int): Int = when (score) {
        in POINT_BUY_MIN..13 -> score - POINT_BUY_MIN
        14 -> 7
        15 -> 9
        else -> error("Score $score outside point buy")
    }

    fun pointsSpent(scores: Map<Ability, Int>): Int = scores.values.sumOf { pointCost(it) }

    /** A sensible 24-point spread, assigned in class priority order. */
    val suggestedArray = intArrayOf(15, 14, 12, 10, 10, 8)

    /** Levels that bring ability points, two each (SRD ability score improvements). */
    val abilityLevels = intArrayOf(4, 8, 12, 16, 19)

    /**
     * Most that all equipped gear together may add to [a] in [chapter], or null for no limit:
     * keeps loot from outgrowing the monsters of a chapter.
     */
    fun gearCap(a: Affix, chapter: Int): Int? = when (a) {
        Affix.STR, Affix.DEX, Affix.CON, Affix.INT, Affix.WIS, Affix.CHA, Affix.ALL_STATS,
        Affix.ATTACK, Affix.SPELL, Affix.AC -> chapter
        Affix.DAMAGE, Affix.FIRE, Affix.RADIANT -> chapter + 1
        else -> null
    }

    /** Ability points a hero of [level] has earned in total. */
    fun abilityPoints(level: Int): Int = 2 * abilityLevels.count { it <= level }

    /** Spell points variant (SRD-compatible spell slot alternative), by caster level. */
    private val spellPoints = intArrayOf(0, 4, 6, 14, 17, 27, 32, 38, 44, 57, 64, 73, 73, 83, 83, 94, 94, 107, 114, 123, 133)

    fun mod(score: Int): Int = Math.floorDiv(score - 10, 2)
    fun proficiency(level: Int): Int = 2 + (level - 1) / 4
    fun spellPoints(level: Int): Int = spellPoints[level.coerceIn(1, MAX_LEVEL)]

    fun xpToNext(level: Int): Int? = if (level >= MAX_LEVEL) null else xpForLevel[level + 1]

    fun levelForXp(xp: Int): Int {
        var lvl = 1
        while (lvl < MAX_LEVEL && xp >= xpForLevel[lvl + 1]) lvl++
        return lvl
    }

    fun signed(n: Int): String = if (n >= 0) "+$n" else "$n"
}

enum class Race(
    val title: T,
    val desc: T,
    val trait: T,
    val bonus: Map<Ability, Int>,
) {
    HUMAN(
        T("Mensch", "Human"),
        T("Anpassungsfähig und ehrgeizig. Menschen sind in allem ein wenig begabt.", "Adaptable and ambitious. Humans are a little gifted at everything."),
        T("Vielseitig: +1 auf alle Attribute.", "Versatile: +1 to all abilities."),
        Ability.entries.associateWith { 1 },
    ),
    ELF(
        T("Elf", "Elf"),
        T("Anmutig und wachsam, mit scharfen Sinnen und einem langen Gedächtnis.", "Graceful and watchful, with keen senses and a long memory."),
        T("Scharfe Sinne: +2 auf Initiative und Flucht.", "Keen Senses: +2 to initiative and fleeing."),
        mapOf(Ability.DEX to 2, Ability.INT to 1),
    ),
    DWARF(
        T("Zwerg", "Dwarf"),
        T("Zäh wie der Fels, aus dem ihre Hallen gehauen sind.", "Tough as the rock their halls are carved from."),
        T("Zwergische Widerstandskraft: halber Giftschaden.", "Dwarven Resilience: half poison damage."),
        mapOf(Ability.CON to 2, Ability.STR to 1),
    ),
    HALFLING(
        T("Halbling", "Halfling"),
        T("Klein, flink und unverschämt vom Glück verfolgt.", "Small, nimble and outrageously lucky."),
        T("Glückspilz: Eine gewürfelte 1 beim Angriff wird neu gewürfelt.", "Lucky: a natural 1 on an attack roll is rerolled."),
        mapOf(Ability.DEX to 2, Ability.CHA to 1),
    ),
    HALF_ORC(
        T("Halbork", "Half-Orc"),
        T("Stark und unbeugsam. Was sie umwirft, muss erst einmal kommen.", "Strong and unyielding. Whatever knocks them down has yet to arrive."),
        T("Unerbittlich: Einmal pro Kampf bleibst du mit 1 TP stehen.", "Relentless Endurance: once per battle you stay up at 1 HP."),
        mapOf(Ability.STR to 2, Ability.CON to 1),
    ),
}

enum class CharClass(
    val title: T,
    val desc: T,
    val hitDie: Int,
    val primary: Ability,
    /** Order in which the standard array is assigned. */
    val priority: List<Ability>,
    val armor: Set<ArmorCategory>,
    val shields: Boolean,
    /** Weapon ids the class is proficient with; null means all weapons. */
    val weapons: Set<String>?,
    val startItems: List<String>,
    val startGold: Int,
    val caster: Boolean,
) {
    FIGHTER(
        T("Kämpfer", "Fighter"),
        T("Meister von Waffe und Rüstung. Robust, verlässlich und schwer zu Fall zu bringen.", "Master of weapon and armor. Sturdy, reliable and hard to bring down."),
        10, Ability.STR,
        listOf(Ability.STR, Ability.CON, Ability.DEX, Ability.WIS, Ability.CHA, Ability.INT),
        setOf(ArmorCategory.LIGHT, ArmorCategory.MEDIUM, ArmorCategory.HEAVY), true, null,
        listOf("longsword", "chain_shirt", "shield", "potion", "potion"), 15, false,
    ),
    WIZARD(
        T("Magier", "Wizard"),
        T("Gelehrter der arkanen Künste. Zerbrechlich, aber mit verheerenden Zaubern.", "Scholar of the arcane arts. Fragile, but armed with devastating spells."),
        6, Ability.INT,
        listOf(Ability.INT, Ability.CON, Ability.DEX, Ability.WIS, Ability.CHA, Ability.STR),
        emptySet(), false, setOf("dagger", "quarterstaff", "light_crossbow", "wand", "staff"),
        listOf("quarterstaff", "robe", "potion", "potion", "potion"), 20, true,
    ),
    ROGUE(
        T("Schurke", "Rogue"),
        T("Flink und gerissen. Trifft dort, wo es am meisten wehtut.", "Quick and cunning. Strikes where it hurts the most."),
        8, Ability.DEX,
        listOf(Ability.DEX, Ability.CON, Ability.WIS, Ability.INT, Ability.CHA, Ability.STR),
        setOf(ArmorCategory.LIGHT), false,
        setOf("dagger", "shortsword", "rapier", "longsword", "scimitar", "handaxe", "mace", "spear", "quarterstaff", "shortbow", "light_crossbow"),
        listOf("shortsword", "leather", "potion", "potion"), 25, false,
    ),
    CLERIC(
        T("Kleriker", "Cleric"),
        T("Diener der Götter. Heilt Verbündete und straft Untote mit heiligem Licht.", "Servant of the gods. Heals allies and smites the undead with holy light."),
        8, Ability.WIS,
        listOf(Ability.WIS, Ability.CON, Ability.STR, Ability.DEX, Ability.CHA, Ability.INT),
        setOf(ArmorCategory.LIGHT, ArmorCategory.MEDIUM), true,
        setOf("dagger", "handaxe", "mace", "spear", "quarterstaff", "light_crossbow", "shortbow", "wand", "staff"),
        listOf("mace", "chain_shirt", "round_shield", "potion"), 15, true,
    ),
    ;

    fun skills(): List<Skill> = Skill.entries.filter { it.cls == this }
}

/** How a skill is paid for. */
enum class SkillCost { NONE, PER_BATTLE, SPELL_POINTS, PASSIVE }

enum class Skill(
    val cls: CharClass,
    val level: Int,
    val title: T,
    val desc: T,
    val cost: SkillCost,
    /** Uses per battle for PER_BATTLE skills, spell point cost for SPELL_POINTS skills. */
    val amount: Int = 0,
    val heals: Boolean = false,
) {
    // Fighter
    FIGHTING_STYLE(CharClass.FIGHTER, 1, T("Kampfstil: Verteidigung", "Fighting Style: Defense"),
        T("+1 RK, solange du Rüstung trägst.", "+1 AC while wearing armor."), SkillCost.PASSIVE),
    SECOND_WIND(CharClass.FIGHTER, 1, T("Zweiter Atem", "Second Wind"),
        T("Heilt 1W10 + Stufe TP. Einmal pro Kampf.", "Heals 1d10 + level HP. Once per battle."), SkillCost.PER_BATTLE, 1, heals = true),
    ACTION_SURGE(CharClass.FIGHTER, 2, T("Tatendrang", "Action Surge"),
        T("Du greifst zweimal hintereinander an. Einmal pro Kampf.", "You attack twice in a row. Once per battle."), SkillCost.PER_BATTLE, 1),
    IMPROVED_CRITICAL(CharClass.FIGHTER, 3, T("Verbesserter kritischer Treffer", "Improved Critical"),
        T("Kritische Treffer schon bei einer 19 oder 20.", "Critical hits on a 19 or 20."), SkillCost.PASSIVE),
    EXTRA_ATTACK(CharClass.FIGHTER, 5, T("Zusätzlicher Angriff", "Extra Attack"),
        T("Deine Angriffsaktion besteht aus zwei Angriffen.", "Your Attack action consists of two attacks."), SkillCost.PASSIVE),

    // Wizard
    FIRE_BOLT(CharClass.WIZARD, 1, T("Feuerpfeil", "Fire Bolt"),
        T("Zaubertrick. Zauberangriff, 1W10 Feuerschaden (+1W10 auf Stufe 5, 11 und 17).", "Cantrip. Spell attack, 1d10 fire damage (+1d10 at levels 5, 11 and 17)."), SkillCost.NONE),
    MAGIC_MISSILE(CharClass.WIZARD, 1, T("Magisches Geschoss", "Magic Missile"),
        T("Drei Geschosse treffen automatisch, je 1W4+1 Energieschaden.", "Three darts hit automatically, 1d4+1 force damage each."), SkillCost.SPELL_POINTS, 2),
    MAGE_ARMOR(CharClass.WIZARD, 1, T("Magierrüstung", "Mage Armor"),
        T("Deine RK wird für diesen Kampf 13 + GES-Mod.", "Your AC becomes 13 + DEX mod for this battle."), SkillCost.SPELL_POINTS, 2),
    SCORCHING_RAY(CharClass.WIZARD, 3, T("Sengender Strahl", "Scorching Ray"),
        T("Drei Strahlen, je ein Zauberangriff mit 2W6 Feuerschaden.", "Three rays, each a spell attack for 2d6 fire damage."), SkillCost.SPELL_POINTS, 3),
    FIREBALL(CharClass.WIZARD, 5, T("Feuerball", "Fireball"),
        T("8W6 Feuerschaden, GES-Rettungswurf halbiert. Verjagt Begleiter, die ihren Rettungswurf nicht schaffen. Einmal pro Kampf.", "8d6 fire damage, DEX save for half. Drives off companions that fail their save. Once per battle."), SkillCost.SPELL_POINTS, 5),

    // Rogue
    SNEAK_ATTACK(CharClass.ROGUE, 1, T("Hinterhältiger Angriff", "Sneak Attack"),
        T("Dein erster Treffer im Kampf und Treffer mit Vorteil verursachen zusätzlich (Stufe/2)W6 Schaden.", "Your first hit in a battle and hits with advantage deal an extra (level/2)d6 damage."), SkillCost.PASSIVE),
    FEINT(CharClass.ROGUE, 1, T("Finte", "Feint"),
        T("Angriff mit Vorteil – löst Hinterhältigen Angriff aus. Zweimal pro Kampf.", "Attack with advantage, triggering Sneak Attack. Twice per battle."), SkillCost.PER_BATTLE, 2),
    CUNNING_ACTION(CharClass.ROGUE, 2, T("Raffinierte Aktion", "Cunning Action"),
        T("Die Flucht gelingt immer (außer vor Bossen).", "Fleeing always succeeds (except from bosses)."), SkillCost.PASSIVE),
    UNCANNY_DODGE(CharClass.ROGUE, 3, T("Unglaubliches Ausweichen", "Uncanny Dodge"),
        T("Der erste Treffer gegen dich in jedem Kampf macht nur halben Schaden, ab Stufe 5 in jeder Runde.", "The first hit against you each battle deals only half damage, from level 5 on each round."), SkillCost.PASSIVE),

    // Cleric
    SACRED_FLAME(CharClass.CLERIC, 1, T("Heilige Flamme", "Sacred Flame"),
        T("Zaubertrick. GES-Rettungswurf oder 1W8 gleißender Schaden (+1W8 auf Stufe 5, 11 und 17).", "Cantrip. DEX save or 1d8 radiant damage (+1d8 at levels 5, 11 and 17)."), SkillCost.NONE),
    CURE_WOUNDS(CharClass.CLERIC, 1, T("Wunden heilen", "Cure Wounds"),
        T("Heilt 1W8 + WEI-Mod TP (+1W8 pro 2 Stufen).", "Heals 1d8 + WIS mod HP (+1d8 per 2 levels)."), SkillCost.SPELL_POINTS, 2, heals = true),
    BLESS(CharClass.CLERIC, 1, T("Segnen", "Bless"),
        T("Für diesen Kampf +1W4 auf deine Angriffswürfe.", "+1d4 to your attack rolls for this battle."), SkillCost.SPELL_POINTS, 2),
    TURN_UNDEAD(CharClass.CLERIC, 2, T("Untote vertreiben", "Turn Undead"),
        T("Ein Untoter muss einen WEI-Rettungswurf bestehen oder flieht. Einmal pro Kampf.", "An undead must succeed on a WIS save or flee. Once per battle."), SkillCost.PER_BATTLE, 1),
    SPIRITUAL_WEAPON(CharClass.CLERIC, 3, T("Spirituelle Waffe", "Spiritual Weapon"),
        T("Eine schwebende Waffe greift jede Runde zusätzlich an (1W8 + WEI-Mod).", "A floating weapon attacks every round as well (1d8 + WIS mod)."), SkillCost.SPELL_POINTS, 3),
    SPIRIT_GUARDIANS(CharClass.CLERIC, 5, T("Geisterwächter", "Spirit Guardians"),
        T("Geister umkreisen dich: jede Runde 3W8 gleißender Schaden, WEI-Rettungswurf halbiert.", "Spirits circle you: 3d8 radiant damage each round, WIS save for half."), SkillCost.SPELL_POINTS, 5),
    ;

    val passive: Boolean get() = cost == SkillCost.PASSIVE
}
