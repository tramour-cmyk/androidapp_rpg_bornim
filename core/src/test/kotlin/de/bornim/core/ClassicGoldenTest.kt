package de.bornim.core

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import java.io.File
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * 390 (Umzug Godot): records fights of the old, classic battle (`Battle.kt`) as golden cases for the GDScript port
 * (`godot/regeln/klassisch.gd`), as `MarsGoldenTest` does for MARS: every number the dice give, the hero's derived numbers,
 * the monster and its pack, every action and every step with the numbers after it. Elites and shimmering foes are not
 * recorded yet. The gear a won fight drops (`Loot.drops`) is written down by name; the port takes it from the case.
 * Writes only with CLASSIC_GOLDEN=<dir> set; otherwise it plays the cases and checks they end.
 */
class ClassicGoldenTest {
    /** A random source that writes down every number it hands out; a chance is a number in 0 until 1000 (wuerfel.gd). */
    private class Tape(seed: Int) : Random() {
        private val inner = Random(seed)
        val log = mutableListOf<Int>()
        override fun nextBits(bitCount: Int): Int = error("not taped: nextBits")
        override fun nextInt(until: Int): Int = inner.nextInt(until).also { log += it }
        override fun nextInt(from: Int, until: Int): Int = inner.nextInt(from, until).also { log += it }
        override fun nextDouble(): Double = nextInt(1000) / 1000.0
    }

    private fun j(v: Any?): JsonElement = when (v) {
        null -> JsonNull
        is JsonElement -> v
        is Number -> JsonPrimitive(v)
        is Boolean -> JsonPrimitive(v)
        is String -> JsonPrimitive(v)
        is Map<*, *> -> JsonObject(v.entries.associate { (k, x) -> k.toString() to j(x) })
        is List<*> -> JsonArray(v.map { j(it) })
        else -> JsonPrimitive(v.toString())
    }

    private fun dice(d: DiceExpr) = listOf(d.count, d.sides, d.bonus)
    private fun t(x: T) = mapOf("de" to x.de, "en" to x.en)

    private fun weapon(h: Hero, w: Gear?, offHand: Boolean = false): Map<String, Any?> = mapOf(
        "id" to (w?.base ?: ""), "de" to (w?.name(Lang.DE) ?: ""), "en" to (w?.name(Lang.EN) ?: ""),
        "atk" to h.attackBonus(w), "dmg" to dice(h.weaponDamage(w, offHand)),
        "ranged" to (w?.def?.ranged == true), "finesse" to (w?.def?.finesse == true),
        "type" to (w?.def?.damageType ?: DamageType.BLUDGEONING).name,
    )

    /** What the battle reads from the hero, as numbers. */
    private fun hero(h: Hero): Map<String, Any?> = mapOf(
        "name" to h.name, "race" to h.race.name, "cls" to h.cls.name, "level" to h.level, "xp" to h.xp,
        "hp" to h.hp, "maxHp" to h.maxHp, "sp" to h.sp, "maxSp" to h.maxSp,
        "mods" to Ability.entries.associate { it.name to h.mod(it) }, "scores" to Ability.entries.associate { it.name to h.score(it) },
        "prof" to h.proficiency, "crit" to h.critFrom, "spellAtk" to h.spellAttack, "spellDc" to h.spellDc,
        "ac" to h.armorClass(false), "acMage" to h.armorClass(true), "chestArmor" to (h.item(GearSlot.CHEST)?.def?.armor ?: 0),
        "lifeSteal" to h.lifeSteal, "reduction" to h.damageReduction, "tenacity" to h.tenacity,
        "bonus" to listOf(Affix.POISON_HIT, Affix.BLEED_HIT, Affix.STUN_HIT, Affix.XP, Affix.GOLD_FIND).associate { it.name to h.bonus(it) },
        "skills" to Skill.entries.filter { h.has(it) }.map { it.name }, "spent" to h.spent.mapKeys { it.key.name },
        "main" to weapon(h, h.weapon), "off" to h.offHandWeapon?.let { weapon(h, it, offHand = true) },
        "shield" to (h.item(GearSlot.OFF_HAND)?.def?.kind == BaseKind.SHIELD),
        "saves" to Battle.savingThrows.getValue(h.cls).map { it.name },
    )

    private fun monster(m: MonsterDef) = mapOf(
        "id" to m.id, "de" to m.name.de, "en" to m.name.en, "ac" to m.ac, "hp" to dice(m.hp), "attack" to t(m.attackName),
        "atk" to m.attackBonus, "dmg" to dice(m.damage), "type" to m.damageType.name, "xp" to m.xp, "gold" to dice(m.gold),
        "dex" to m.dexSave, "con" to m.conSave, "wis" to m.wisSave,
        "loot" to m.loot.map { mapOf("item" to it.item, "chance" to it.chance, "exists" to Items.exists(it.item), "unique" to Uniques.exists(it.item)) },
        "undead" to m.undead, "vulnerable" to m.vulnerable.map { it.name }, "resistant" to m.resistant.map { it.name },
        "immune" to m.immune.map { it.name }, "statusImmune" to Status.entries.filter { Status.immune(m, it) }.map { it.name },
        "special" to m.special.name, "potions" to m.potions, "boss" to m.boss, "cr" to m.cr, "fx" to m.attackFx.name, "poison" to dice(m.poison),
    )

    private fun pack(p: PackDef) = mapOf(
        "chance" to p.chance, "shift" to p.attackShift, "dmg" to dice(p.damage), "fx" to p.fx.name, "xpShare" to p.xpShare,
        "intro" to t(p.intro), "attack" to t(p.attack), "one" to t(p.one), "flee" to t(p.flee), "burned" to t(p.burned),
    )

    private fun step(s: Step): Map<String, Any?> = buildMap {
        put("t", s.text)
        put("n", "${s.heroHp} ${s.enemyHp} ${s.heroSp} ${s.pack} ${s.packActor}")
        if (s.anim != Anim.NONE) put("a", s.anim.name)
        if (s.lead) put("lead", true)
        if (s.heavy) put("heavy", true)
        s.fx?.let { put("fx", listOfNotNull(it.kind.name, if (it.onHero) "hero" else "foe", if (it.crit) "crit" else null, it.past?.name)) }
        s.rarity?.let { put("rar", it.name) }
        s.item?.let { put("item", it) }
        s.roll?.let { r -> put("r", listOf(r.d20, r.bonus, r.versus, r.success, r.mode)) }
        if (s.heroStatus.isNotEmpty()) put("sh", s.heroStatus.entries.joinToString(" ") { "${it.key.name}=${it.value}" })
        if (s.foeStatus.isNotEmpty()) put("sf", s.foeStatus.entries.joinToString(" ") { "${it.key.name}=${it.value}" })
    }

    private fun action(a: Action): List<Any?> = when (a) {
        Action.Attack -> listOf("attack")
        Action.Defend -> listOf("defend")
        Action.EndTurn -> listOf("wait")
        Action.Flee -> listOf("flee")
        is Action.UseSkill -> listOf("skill", a.skill.name)
        is Action.UseItem -> listOf("item", a.item)
    }

    /** What a player could do now; attacking weighs most (fleeing is tried now and then, see [record]). */
    private fun choices(b: Battle, s: GameState): List<Action> {
        val out = mutableListOf<Action>(Action.Attack, Action.Attack, Action.Attack, Action.Defend)
        if (b.hero.level == 1) out += Action.EndTurn
        for (sk in b.hero.cls.skills()) if (b.blocked(sk) == null) { out += Action.UseSkill(sk); out += Action.UseSkill(sk) }
        for (id in listOf("potion", "remedy", "alchemist_fire", "holy_water")) if (s.count(id) > 0 && b.blockedItem(id) == null) {
            if (id == "potion" && b.hero.hp >= b.hero.maxHp) continue
            out += Action.UseItem(id)
        }
        return out
    }

    private data class Case(val name: String, val cls: CharClass, val race: Race, val foe: String, val seed: Int, val level: Int, val opening: Opening)

    private val cases: List<Case> = buildList {
        val classes = CharClass.entries
        val races = Race.entries
        val foes = listOf("giant_rat", "wolf", "goblin", "kobold", "boar", "giant_spider", "giant_bat", "goblin_shaman", "skeleton", "zombie",
            "stirge", "giant_centipede", "ghoul", "ochre_jelly", "hobgoblin_captain", "dire_wolf", "bugbear")
        var n = 0
        for ((fi, foe) in foes.withIndex()) for ((ci, cls) in classes.withIndex()) {
            if ((fi + ci) % 2 == 1 && foe !in listOf("bugbear", "hobgoblin_captain", "dire_wolf")) continue
            val m = Monsters[foe]
            val level = if (m.boss) 3 + (ci % 2) else 1 + (n % 3)
            add(Case("$foe-${cls.name.lowercase()}", cls, races[n % races.size], foe, 1000 + n, level, Opening.entries[n % 3]))
            n++
        }
    }

    private fun record(c: Case): Map<String, Any?> {
        val tape = Tape(c.seed)
        val policy = Random(c.seed * 7 + 1)
        val state = GameState.newGame("Ansgar", c.race, c.cls)
        state.hero.gainXp(Rules.xpForLevel[c.level], Story.CHAPTER1_LEVEL_CAP)
        state.hero.restoreFully()
        state.add("potion", 2)
        if (c.seed % 3 == 0) state.add("alchemist_fire")
        if (c.cls == CharClass.CLERIC) state.add("holy_water")
        if (c.seed % 4 == 1) state.add("remedy")
        if (c.foe == "bugbear" && c.seed % 2 == 0) state.add(Story.SMOKE_BUNDLE)
        if (c.seed % 5 == 2) state.wellFed = true
        if (c.seed % 7 == 3) state.mead = Resting.DRUNK
        if (c.seed % 6 == 4) state.ailments["POISON"] = 2
        if (c.seed % 9 == 5) state.winded = true
        val m = Monsters[c.foe]
        val area = if (m.boss) c.level - 1 else c.level
        val look = MonsterLook(c.seed)
        val heroBefore = hero(state.hero)
        val stateBefore = mapOf(
            "ailments" to state.ailments.toMap(), "drunk" to state.drunk, "wellFed" to state.wellFed, "winded" to state.winded,
            "mageArmorOn" to state.mageArmorOn, "inventory" to state.inventory.toMap(), "levelCap" to Story.levelCap(state),
        )
        val b = Battle(state, m, Lang.DE, Dice(tape), c.level, false, area, look = look, opening = c.opening)
        val steps = mutableListOf<Map<String, Any?>>()
        steps += mapOf("do" to listOf("start"), "st" to b.start().map { step(it) })
        var guard = 0
        while (b.outcome == Outcome.ONGOING && guard++ < 120) {
            val all = choices(b, state)
            // one in many: fleeing is tried, may be refused (a boss) or fail
            val a = if (policy.nextInt(16) == 0) Action.Flee else all[policy.nextInt(all.size)]
            steps += mapOf("do" to action(a), "st" to b.act(a).map { step(it) })
        }
        if (b.outcome == Outcome.ONGOING) steps += mapOf("do" to listOf("testEnd", true), "st" to b.testEnd(true).map { step(it) })
        val r = b.rewards
        return mapOf(
            "name" to c.name, "level" to c.level, "area" to area, "opening" to c.opening.name, "look" to c.seed,
            "hero" to heroBefore, "state" to stateBefore, "monster" to monster(m), "pack" to b.pack?.let { pack(it) }, "packSize" to b.packSize,
            "kitAttack" to MonsterKits.of(m.id, look.seed)?.attack?.let { t(it) },
            "dice" to tape.log, "steps" to steps, "outcome" to b.outcome.name,
            "gear" to (r?.gear ?: emptyList()).map { mapOf("de" to it.name(Lang.DE), "en" to it.name(Lang.EN), "rarity" to it.rarity.name, "rarDe" to it.rarity.title.de, "rarEn" to it.rarity.title.en) },
            "after" to mapOf("level" to state.hero.level, "maxHp" to state.hero.maxHp, "maxSp" to state.hero.maxSp, "xp" to state.hero.xp, "gold" to state.gold),
        )
    }

    @Test
    fun goldenCases() {
        val recorded = cases.map { record(it) }
        assertTrue(recorded.all { it["outcome"] != Outcome.ONGOING.name })
        val dir = System.getenv("CLASSIC_GOLDEN") ?: return
        val tables = mapOf(
            "items" to Items.all.map { mapOf("id" to it.id, "de" to it.name.de, "en" to it.name.en, "kind" to it.kind.name,
                "heal" to it.heal?.let { d -> dice(d) }, "damage" to it.damage?.let { d -> dice(d) }, "type" to it.damageType.name, "cures" to it.cures) },
            "skills" to Skill.entries.filter { !it.mars }.map { mapOf("id" to it.name, "cls" to it.cls.name, "level" to it.level, "de" to it.title.de, "en" to it.title.en, "cost" to it.cost.name, "amount" to it.amount) },
            "damageTypes" to DamageType.entries.associate { it.name to t(it.title) },
            "statusTitles" to Status.entries.associate { it.name to t(it.title) },
            "xpForLevel" to Rules.xpForLevel.toList(), "abilityLevels" to Rules.abilityLevels.toList(), "maxLevel" to Rules.MAX_LEVEL,
        )
        File(dir).mkdirs()
        File(dir, "klassisch.json").writeText(j(mapOf("tables" to tables, "cases" to recorded)).toString())
    }
}
