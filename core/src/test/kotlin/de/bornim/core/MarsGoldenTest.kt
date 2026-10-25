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
 * 348.7 (Umzug Godot): records MARS fights as golden cases for the GDScript port (`godot/regeln/`). Every number the dice
 * and the wordings give is written down, with the orders, the rings and every message with the state after it; the port
 * replays the same numbers and must say the same, line for line (`godot/tests/mars_golden.gd`).
 * Writes only with MARS_GOLDEN=<dir> set (`tools/mars-golden.sh`); otherwise it plays the cases and checks they end.
 */
class MarsGoldenTest {
    /** A random source that writes down every number it hands out. */
    private class Tape(seed: Int) : Random() {
        private val inner = Random(seed)
        val log = mutableListOf<Int>()
        override fun nextBits(bitCount: Int): Int = error("not taped: nextBits")
        override fun nextInt(until: Int): Int = inner.nextInt(until).also { log += it }
        override fun nextInt(from: Int, until: Int): Int = inner.nextInt(from, until).also { log += it }
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

    private fun weapon(h: Hero, w: Gear?): Map<String, Any?> = mapOf(
        "id" to (w?.base ?: ""),
        "de" to (w?.name(Lang.DE) ?: ""), "en" to (w?.name(Lang.EN) ?: ""),
        "atk" to h.attackBonus(w), "dmg" to dice(h.weaponDamage(w)),
        "ranged" to (w?.def?.ranged == true), "reach" to (w?.def?.reach == true), "two" to (w?.def?.twoHanded == true),
    )

    /** What the fight reads from a figure: the derived numbers of the hero, the table entry of a monster. */
    private fun sheet(f: Fighter): Map<String, Any?> {
        val base = mapOf("id" to f.id, "side" to f.side.name, "row" to f.place.row.name, "slot" to f.place.slot, "hp" to f.maxHp)
        val h = f.hero ?: return base + mapOf("monster" to f.monster!!.id)
        val shield = h.item(GearSlot.OFF_HAND)?.takeIf { it.def.kind == BaseKind.SHIELD }
        val acDrawn = if (f.second?.def?.twoHanded == true && shield != null) h.armorClass - shield.def.armor - shield.plus else h.armorClass
        return base + mapOf(
            "hero" to mapOf(
                "name" to h.name, "cls" to h.cls.name, "level" to h.level, "dex" to h.mod(Ability.DEX), "wis" to h.mod(Ability.WIS),
                "ac" to h.armorClass, "acDrawn" to acDrawn, "crit" to h.critFrom, "spellAtk" to h.spellAttack, "spellDc" to h.spellDc,
                "sp" to h.sp, "skills" to Skill.entries.filter { h.has(it) }.map { it.name },
                "main" to weapon(h, h.weapon), "second" to f.second?.let { weapon(h, it) },
            ),
        )
    }

    private fun monster(m: MonsterDef) = mapOf(
        "id" to m.id, "de" to m.name.de, "en" to m.name.en, "ac" to m.ac, "hp" to dice(m.hp), "atk" to m.attackBonus,
        "dmg" to dice(m.damage), "dex" to m.dexSave, "boss" to m.boss, "cr" to m.cr,
    )

    private fun spot(s: Spot) = "${s.row.name[0]}${s.slot}"

    private fun event(e: SkirmishEvent): Map<String, Any?> = buildMap {
        put("t", e.text)
        e.actor?.let { put("a", it) }
        e.target?.let { put("g", it) }
        if (e.damage != 0) put("d", e.damage)
        e.roll?.let { r -> put("r", listOf(r.kind.name, r.d20, r.bonus, r.versus, r.success, r.mode, r.fromBack)) }
        if (e.answer) put("ans", true)
        if (e.wound) put("w", true)
        e.spell?.let { put("fx", it.name) }
        e.cue?.let { put("cue", it.name) }
        put("s", e.hp.keys.joinToString(" ") { "$it=${e.hp[it]}@${spot(e.places.getValue(it))}" })
        put("i", e.intents.entries.joinToString(" ") { (k, v) -> "$k>${v.first.id}:${v.second.joinToString(",")}" })
        put("q", e.queue.joinToString(" "))
        if (e.sp.values.any { it > 0 }) put("sp", e.sp.entries.joinToString(" ") { "${it.key}=${it.value}" })
    }

    private fun order(o: Order): List<Any?> = when (o) {
        is Order.Attack -> listOf("attack", o.target)
        is Order.Swap -> listOf("swap", spot(o.to), o.draw)
        Order.Draw -> listOf("draw")
        Order.Wait -> listOf("wait")
        Order.Guard -> listOf("guard")
        is Order.Use -> listOf("use", o.skill.name, o.target)
        is Order.Drink -> listOf("drink", o.item, o.target)
    }

    /** The orders a player could give now. */
    private fun choices(sk: Skirmish): List<Order> {
        val f = sk.current
        val out = mutableListOf<Order>()
        sk.targets(f).forEach { out += Order.Attack(it.id); out += Order.Attack(it.id) }
        out += Order.Wait
        if (sk.canSwap(f)) Spot.ALL.filter { it != f.place }.forEach { out += Order.Swap(it, draw = sk.canDraw(f) && it.row != f.place.row) }
        if (sk.canDraw(f)) out += Order.Draw
        if (sk.guardable(f).isNotEmpty()) out += Order.Guard
        for (s in sk.moves(f)) if (sk.blocked(f, s) == null) {
            val aim = sk.aimAt(f, s)
            if (Moves.aim(s) == Aim.SELF) out += Order.Use(s) else aim.forEach { out += Order.Use(s, it.id) }
        }
        if (sk.drinkable().isNotEmpty()) sk.fighters.filter { it.side == Side.PARTY && it.standing && it.hp < it.maxHp }.forEach { out += Order.Drink("potion", it.id) }
        return out
    }

    private data class Case(val name: String, val cls: CharClass, val merc: CharClass, val foe: Skirmish.Companion.ProbeFoe, val seed: Int, val level: Int = Skirmish.PROBE_LEVEL)

    private val cases: List<Case> = buildList {
        val classes = CharClass.entries
        for ((i, cls) in classes.withIndex()) for (s in 0 until 3) {
            add(Case("wolves-${cls.name.lowercase()}-$s", cls, classes[(i + s + 1) % classes.size], Skirmish.Companion.ProbeFoe.WOLVES, 100 + i * 10 + s))
        }
        for (foe in listOf(Skirmish.Companion.ProbeFoe.GRAK, Skirmish.Companion.ProbeFoe.SPIDER, Skirmish.Companion.ProbeFoe.SCOUT)) for ((i, cls) in classes.withIndex()) {
            add(Case("${foe.name.lowercase()}-${cls.name.lowercase()}", cls, classes[(i + 2) % classes.size], foe, 500 + foe.ordinal * 10 + i))
        }
        add(Case("wolves-easy", CharClass.FIGHTER, CharClass.CLERIC, Skirmish.Companion.ProbeFoe.WOLVES, 900, level = 8))
    }

    private fun record(c: Case): Map<String, Any?> {
        val tape = Tape(c.seed)
        val words = Tape(279)
        val policy = Random(c.seed * 7 + 1)
        val state = GameState.newGame("Ansgar", Race.HUMAN, c.cls)
        val sk = Skirmish.probe(state, c.merc, Lang.DE, c.foe, Dice(tape), c.level)
        Skirmish::class.java.getDeclaredField("wordings").apply { isAccessible = true }.set(sk, words)
        val fighters = sk.fighters.map { sheet(it) }
        val events = mutableListOf<SkirmishEvent>()
        sk.listener = { events += it }
        val rings = mutableListOf<String>()
        val react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.entries[policy.nextInt(3)].also { rings += it.name } }
        val steps = mutableListOf<Map<String, Any?>>()
        fun step(kind: List<Any?>, run: () -> Unit) {
            val from = events.size
            run()
            steps += mapOf("do" to kind, "ev" to events.subList(from, events.size).map { event(it) })
        }
        val merc = sk.byId("merc")
        merc.auto = c.seed % 2 == 0
        val mercAuto = merc.auto
        if (sk.easy) {
            step(listOf("quick")) { events += sk.quick().events }
        }
        if (!sk.started) step(listOf("start")) { sk.start(react) }
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 400) {
            if (sk.pilotNext) { step(listOf("proceed")) { sk.proceed(react) }; continue }
            when (policy.nextInt(20)) {
                0 -> { val on = !merc.auto; merc.auto = on; steps += mapOf("do" to listOf("auto", "merc", on), "ev" to emptyList<Any>()); continue }
                1 -> { val on = !sk.autopilot; step(listOf("pilot", on)) { sk.setAutopilot(on) }; continue }
            }
            val all = choices(sk)
            val o = all[policy.nextInt(all.size)]
            step(listOf("act") + order(o)) { sk.act(o, react) }
        }
        if (sk.outcome == Outcome.ONGOING) step(listOf("testEnd", true)) { sk.testEnd(true) }
        return mapOf(
            "name" to c.name, "level" to c.level, "fighters" to fighters, "potions" to sk.potions.toMap(),
            "dice" to tape.log, "words" to words.log, "rings" to rings, "steps" to steps,
            "outcome" to sk.outcome.name, "knockouts" to sk.knockouts, "mercAuto" to mercAuto,
        )
    }

    @Test
    fun goldenCases() {
        val recorded = cases.map { record(it) }
        assertTrue(recorded.all { it["outcome"] != Outcome.ONGOING.name })
        val dir = System.getenv("MARS_GOLDEN") ?: return
        // 348.7: the probe's hero and Söldner of each class, for the Kampfort until the hero's part is ported
        val probe = CharClass.entries.associate { cls ->
            val sk = Skirmish.probe(GameState.newGame("Ansgar", Race.HUMAN, cls), cls, Lang.DE, Skirmish.Companion.ProbeFoe.WOLVES, Dice(Random(1)))
            cls.name to mapOf("hero" to sheet(sk.byId("hero")), "merc" to sheet(sk.byId("merc")))
        }
        val potion = Items["potion"]
        val tables = mapOf(
            "monsters" to listOf(Skirmish.WOLF, Skirmish.GRAK, Skirmish.CALLED, Skirmish.SCOUT, Skirmish.SPIDER).map { monster(Monsters[it]) },
            "items" to listOf(mapOf("id" to potion.id, "de" to potion.name.de, "en" to potion.name.en, "heal" to dice(potion.heal!!))),
            "probe" to probe,
            "skills" to Skill.entries.map { mapOf("id" to it.name, "cls" to it.cls.name, "level" to it.level, "de" to it.title.de, "en" to it.title.en, "cost" to it.cost.name, "amount" to it.amount) },
        )
        File(dir).mkdirs()
        File(dir, "../../regeln/tabellen.json").writeText(j(tables).toString())
        File(dir, "kaempfe.json").writeText(j(recorded).toString())
    }
}
