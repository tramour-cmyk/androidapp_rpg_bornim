package de.bornim.core

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import java.io.File

/**
 * 390 (Held fuer Laden und Rast): what the Godot game needs to work out a hero like [Hero] (`godot/skripte/heldwerte.gd`),
 * as JSON (`godot/daten/held.json`): the rule tables, races, classes, skills by class and level, the gear bases; and
 * "proben": heroes of every race and class at several levels and with several kits, each with the numbers [Hero] gives,
 * which `godot/tests/held_golden.gd` compares with the port. Run: `./gradlew -p core exportHero -Pout=<file> [-Pproben=<file>]`.
 */
object HeroExport {
    const val VERSION = 1

    private fun j(v: Any?): JsonElement = when (v) {
        null -> JsonNull
        is JsonElement -> v
        is Number -> JsonPrimitive(v)
        is Boolean -> JsonPrimitive(v)
        is String -> JsonPrimitive(v)
        is Enum<*> -> JsonPrimitive(v.name)
        is T -> buildJsonObject { put("de", v.de); put("en", v.en) }
        is DiceExpr -> JsonArray(listOf(j(v.count), j(v.sides), j(v.bonus)))
        is IntArray -> JsonArray(v.map { j(it) })
        is Map<*, *> -> JsonObject(v.entries.associate { (k, x) -> (if (k is Enum<*>) k.name else k.toString()) to j(x) })
        is Iterable<*> -> JsonArray(v.map { j(it) })
        else -> error("no JSON for $v")
    }

    private fun base(b: GearBase) = mapOf(
        "de" to b.de, "en" to b.en, "geschlecht" to b.gender, "slot" to b.slot, "art" to b.kind, "preis" to b.price,
        "ab_stufe" to b.minLevel, "gewicht" to b.weight, "ruestung" to b.armor, "schaden" to b.damage, "schadensart" to b.damageType,
        "finesse" to b.finesse, "fern" to b.ranged, "zweihaendig" to b.twoHanded, "fokus" to b.focus, "vielseitig" to b.versatile,
        "reichweite" to b.reach,
    )

    fun gear(g: Gear) = mapOf("uid" to g.uid, "base" to g.base, "rarity" to g.rarity, "ilvl" to g.ilvl, "plus" to g.plus,
        "rolls" to g.rolls.map { listOf(it.affix.name, it.value) }, "unique" to g.unique)

    /** What [h] is, as the port takes it in. */
    fun input(h: Hero) = mapOf("name" to h.name, "volk" to h.race, "klasse" to h.cls, "stufe" to h.level, "ep" to h.xp,
        "basis" to h.base, "start" to h.startScores, "tp" to h.hp, "zp" to h.sp, "offen" to h.unspentPoints, "kapitel" to h.chapter,
        "ausruestung" to h.gear.mapValues { gear(it.value) })

    /** The numbers [Hero] works out for [h]. */
    fun expect(h: Hero) = mapOf(
        "werte" to Ability.entries.associateWith { h.score(it) }, "mods" to Ability.entries.associateWith { h.mod(it) },
        "max_tp" to h.maxHp, "max_zp" to h.maxSp, "uebung" to h.proficiency, "rk" to h.armorClass, "rk_magier" to h.armorClass(true),
        "angriff" to h.attackBonus, "schaden" to h.weaponDamage, "neben_schaden" to h.offHandWeapon?.let { h.weaponDamage(it, true) },
        "beide_haende" to h.bothHands(), "zauberangriff" to h.spellAttack, "zauber_sg" to h.spellDc, "krit_ab" to h.critFrom,
        "lebensraub" to h.lifeSteal, "schadensminderung" to h.damageReduction, "standhaft" to h.tenacity,
        "faehigkeiten" to Skill.entries.filter { h.has(it) }.map { it.name },
        "boni" to Affix.entries.associateWith { h.bonus(it) },
    )

    /** Sample heroes: every race and class, levels 1, 3, 7, 20, the start kit and two other kits (one over the chapter's caps). */
    fun samples(): List<Hero> {
        var uid = 100L
        val out = mutableListOf<Hero>()
        val kits = listOf(
            emptyList(),
            listOf(Gear(1, "greataxe", Rarity.RARE, 5, 1, listOf(Roll(Affix.STR, 2), Roll(Affix.DAMAGE, 3))), Gear(2, "plate", Rarity.UNCOMMON, 9, 2, listOf(Roll(Affix.AC, 2))),
                Gear(3, "ring", Rarity.EPIC, 9, 0, listOf(Roll(Affix.ALL_STATS, 2), Roll(Affix.CRIT, 2), Roll(Affix.HP, 12), Roll(Affix.LIFESTEAL, 40)))),
            listOf(Gear(4, "rapier", Rarity.UNCOMMON, 3, 0, listOf(Roll(Affix.DEX, 1))), Gear(5, "dagger", Rarity.COMMON, 1),
                Gear(6, "leather", Rarity.RARE, 3, 1, listOf(Roll(Affix.TENACITY, 70), Roll(Affix.RESIST, 2))), Gear(7, "wand", Rarity.UNCOMMON, 2, 0, listOf(Roll(Affix.SPELL, 3), Roll(Affix.SP, 5)))),
            listOf(Gear(8, "longsword", Rarity.COMMON, 1), Gear(9, "half_plate", Rarity.COMMON, 6), Gear(10, "amulet", Rarity.RARE, 4, 0, listOf(Roll(Affix.CON, 1), Roll(Affix.FIRE, 3)))),
        )
        for (race in Race.entries) for (cls in CharClass.entries) for ((ki, kit) in kits.withIndex()) for (lvl in listOf(1, 3, 7, 20)) {
            val h = Hero.create("Probe", race, cls, newUid = { uid++ })
            if (ki > 0) h.gear.clear()
            for (g in kit) if (GearBases.exists(g.base)) { if (g.base == "dagger" && h.weapon != null) h.equipOffHand(g) else h.equip(g) }
            if (lvl > 1) h.gainXp(Rules.xpForLevel[lvl])
            h.chapter = if (lvl == 20) 2 else 1
            h.clamp()
            out += h
        }
        return out
    }

    /** [proben]: the sample heroes too (for the test, not the game). */
    fun json(proben: Boolean = true): JsonObject = buildJsonObject {
        put("version", VERSION)
        put("regeln", j(mapOf(
            "max_stufe" to Rules.MAX_LEVEL, "max_wert" to Rules.MAX_SCORE, "ep_fuer_stufe" to Rules.xpForLevel,
            "standard" to Rules.standardArray, "vorschlag" to Rules.suggestedArray, "attributstufen" to Rules.abilityLevels,
            "punktkauf" to Rules.POINT_BUY, "punktkauf_min" to Rules.POINT_BUY_MIN, "punktkauf_max" to Rules.POINT_BUY_MAX,
            "zauberpunkte" to (0..Rules.MAX_LEVEL).map { if (it == 0) 0 else Rules.spellPoints(it) },
            // Obergrenze je Affix im Kapitel k: k + Wert; fehlt der Affix, keine Grenze (Rules.gearCap)
            "deckel" to Affix.entries.mapNotNull { a -> Rules.gearCap(a, 0)?.let { a.name to it } }.toMap(),
        )))
        put("voelker", j(Race.entries.associate { it.name to mapOf("name" to it.title, "bonus" to it.bonus) }))
        put("klassen", j(CharClass.entries.associate { c -> c.name to mapOf("name" to c.title, "trefferwuerfel" to c.hitDie, "haupt" to c.primary,
            "reihenfolge" to c.priority, "ruestung" to c.armor, "schilde" to c.shields, "waffen" to c.weapons?.toList(), "start" to c.startItems,
            "startgold" to c.startGold, "zauberer" to c.caster) }))
        put("faehigkeiten", j(Skill.entries.associate { it.name to mapOf("klasse" to it.cls, "stufe" to it.level, "name" to it.title) }))
        put("grundformen", j(GearBases.all.associate { it.id to base(it) }))
        put("affixe", j(Affix.entries.map { it.name }))
        if (proben) put("proben", JsonArray(samples().map { h -> buildJsonObject { put("held", j(input(h))); put("soll", j(expect(h))) } }))
    }

    @JvmStatic
    fun main(args: Array<String>) {
        // args: <held.json fuers Spiel> [<datei mit Proben fuer den Test>]
        val dateien = if (args.isEmpty()) listOf("held.json") else args.toList()
        for ((i, a) in dateien.withIndex()) {
            val out = File(a)
            out.absoluteFile.parentFile.mkdirs()
            out.writeText(Json { prettyPrint = false }.encodeToString(JsonObject.serializer(), json(proben = i > 0)))
            println("Held${if (i > 0) " mit ${samples().size} Proben" else ""} -> ${out.path} (${out.length()} Bytes)")
        }
    }
}
