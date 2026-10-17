package de.bornim.core

/*
 * Probe 72.10: the hero and a Söldner against one foe, in two rows of two places (72.11, 72v).
 * Stands beside [Battle] and does not replace it; option A stays the fallback (72.11).
 *
 * Decided and built here: two rows instead of near/far, lineup fixed at the start, a place swap costs the
 * figure's turn, the ring only for the attacked figure and only on an announced intent, small hits without
 * input, autopilot after 72.13 (only "gut", stops below a third of LP or on a strong intent, never on bosses,
 * only weapon attacks and cantrips), a downed Söldner is out, not dead (72.8), knockouts counted per fight (72r),
 * winded means disadvantage on initiative (86.3).
 *
 * 72.10a (MARS): abilities and spells ([Moves], aimed by rows: area spells hit a whole row, rays and darts any foe,
 * healing any friend; .1, .3), potions from a shared stock (.12), the line of who acts next (.4), every roll
 * with its numbers for a short sight at the target (.10), Söldner with names from a list (.5), hero and Söldner
 * fixed on level 3 (.10).
 *
 * Grak's three intents follow the combat document (DESIGN-KAMPF.md, "Magier gegen Grak": heavy blow, call the
 * pack, gather strength). Provisional numbers for the probe: what a ring grade does to the damage ([Reaction.share]),
 * how often Grak picks which intent ([Skirmish.pickIntent]), how much a hit must take to break an intent
 * ([Skirmish.BREAK_SHARE]), how much gathering heals and how many goblins answer the call.
 */

enum class Row { FRONT, BACK }

/** A place in a side's lineup: two rows of two (72v). */
data class Spot(val row: Row, val slot: Int) {
    companion object {
        val ALL = listOf(Spot(Row.FRONT, 0), Spot(Row.FRONT, 1), Spot(Row.BACK, 0), Spot(Row.BACK, 1))
    }
}

enum class Side { PARTY, FOES }

/** How well the attacked figure met the ring (72.11). The autopilot always gets [GOOD], never [PERFECT] (72m). */
enum class Reaction(val share: Double) { NONE(1.0), GOOD(0.5), PERFECT(0.0) }

enum class IntentKind { STRIKE, CALL, GATHER }

/** What a roll was, for its short sight at the target (72.10a.10). */
enum class RollKind { ATTACK, SAVE }

/** A d20 with its numbers: [success] is a hit for an attack, a held save for a save. */
data class RollInfo(val kind: RollKind, val d20: Int, val bonus: Int, val versus: Int, val success: Boolean)

/** Whom a move is aimed at: one foe, the whole row of a foe, oneself, a friend (72.10a.3). */
enum class Aim { FOE, ROW, SELF, ALLY }

/** The abilities and spells the new fight knows (72.10a.1); the rest of a class waits for later. */
object Moves {
    fun aim(s: Skill): Aim? = when (s) {
        Skill.FIRE_BOLT, Skill.MAGIC_MISSILE, Skill.SCORCHING_RAY, Skill.SACRED_FLAME, Skill.FEINT, Skill.ACTION_SURGE -> Aim.FOE
        Skill.FIREBALL -> Aim.ROW
        Skill.SECOND_WIND, Skill.BLESS -> Aim.SELF
        Skill.CURE_WOUNDS -> Aim.ALLY
        else -> null
    }

    /** Weapon moves reach like a weapon; spells reach every foe. */
    fun weapon(s: Skill) = s == Skill.FEINT || s == Skill.ACTION_SURGE
}

/**
 * What a foe announces for its next turn. [strong] stops the autopilot (72p.1); [ring] lets the target react;
 * [breakable]: a hard enough hit before the foe's turn foils it (72.11, interrupting an announced blow).
 */
data class Intent(
    val id: String,
    val name: T,
    val kind: IntentKind = IntentKind.STRIKE,
    /** Damage dice added to the foe's own weapon damage. */
    val extra: DiceExpr? = null,
    val strong: Boolean = false,
    val ring: Boolean = true,
    val breakable: Boolean = false,
)

object Intents {
    val heavy = Intent("heavy", T("Schwerer Hieb", "Heavy blow"), extra = dice(2, 6), strong = true, breakable = true)
    val call = Intent("call", T("Rudel rufen", "Call the pack"), IntentKind.CALL, ring = false)
    val gather = Intent("gather", T("Kraft sammeln", "Gather strength"), IntentKind.GATHER, ring = false, breakable = true)
    /** Grak's three intents (combat document). */
    val grak = listOf(heavy, call, gather)
    /** A plain stab, as a pack's small hits: no ring (72.11). */
    val stab = Intent("stab", T("Stich", "Stab"), ring = false)
}

/** One figure in the fight: the hero, a Söldner (a [Hero] that does not level up, 72t) or a foe. */
class Fighter(
    val id: String,
    val side: Side,
    var place: Spot,
    val hero: Hero? = null,
    val monster: MonsterDef? = null,
    hp: Int,
) {
    val maxHp: Int = hp
    var hp: Int = hp
        internal set
    val standing: Boolean get() = hp > 0
    var initiative = 0
        internal set
    val ac: Int get() = hero?.armorClass ?: monster!!.ac
    val ranged: Boolean get() = hero?.weapon?.def?.ranged == true
    val boss: Boolean get() = monster?.boss == true
    /** A Söldner the game plays for the player (72.7); it meets the ring with "gut" (72.11). */
    var auto = false
    /** Damage taken since this foe announced its intent, to tell whether the intent breaks. */
    internal var takenSinceAnnounce = 0
    /** Spell points left in this fight (72.10a.1). */
    var sp: Int = hero?.sp ?: 0
        internal set
    /** Uses left of the per-fight and per-rest abilities; per rest counts per fight here. */
    val uses: MutableMap<Skill, Int> = mutableMapOf<Skill, Int>().also { m ->
        hero?.let { h ->
            Skill.entries.filter { h.has(it) && (it.cost == SkillCost.PER_BATTLE || it.cost == SkillCost.PER_REST) }.forEach { m[it] = it.amount }
        }
    }
    var blessed = false
        internal set
    internal var sneaked = false

    fun name(lang: Lang): String = hero?.name ?: monster!!.name(lang)

    /** Name for the figure and the line of turns: a Söldner with his class (72.10a.5). */
    fun display(lang: Lang): String = if (hero != null && id != "hero") "${hero.name} (${hero.cls.title(lang)})" else name(lang)
}

/**
 * One message of the probe, with who acted and who was hit, and how things stood right after it, for the screen:
 * the screen plays the messages one after another while the fight itself may be further on.
 */
data class SkirmishEvent(
    val text: String,
    val actor: String? = null,
    val target: String? = null,
    val damage: Int = 0,
    val hp: Map<String, Int> = emptyMap(),
    val places: Map<String, Spot> = emptyMap(),
    /** Each foe's announced intent and the figures it aims at. */
    val intents: Map<String, Pair<Intent, List<String>>> = emptyMap(),
    /** The roll behind this message, with its numbers, for a short sight at [target] (72.10a.10). */
    val roll: RollInfo? = null,
    /** Who stands in the line of turns, the one acting now first (72.10a.4). */
    val queue: List<String> = emptyList(),
    val sp: Map<String, Int> = emptyMap(),
)

sealed interface Order {
    data class Attack(val target: String) : Order
    /** Moves to [to]; a figure standing there takes the old place. Costs the turn (72.11). */
    data class Swap(val to: Spot) : Order
    data object Wait : Order
    /** An ability or spell (72.10a.1); [target] by its [Aim]: a figure's id, any figure of the foe's row for a row spell, none for oneself. */
    data class Use(val skill: Skill, val target: String? = null) : Order
    /** A potion from the shared stock for [target], oneself or a friend; costs the turn (72.10a.12). */
    data class Drink(val item: String, val target: String) : Order
}

class Skirmish(
    party: List<Fighter>,
    foes: List<Fighter>,
    var lang: Lang,
    private val dice: Dice = Dice(),
    /** The hero is out of breath: disadvantage on initiative (86.3). */
    winded: Boolean = false,
) {
    private val all = java.util.concurrent.CopyOnWriteArrayList(party + foes)
    val fighters: List<Fighter> get() = all
    /** Knocked-out Söldner in this fight (72r). */
    var knockouts = 0
        private set
    var outcome = Outcome.ONGOING
        private set
    /** The foes' announced next moves, by foe id. */
    val intents = LinkedHashMap<String, Pair<Intent, List<String>>>()
    var autopilot = false
        private set
    private val order = mutableListOf<Fighter>()
    /** Index into [order] of the figure whose turn it is. */
    private var turn = 0
    private fun nextTurn() { turn = (turn + 1) % order.size }
    private val log = mutableListOf<SkirmishEvent>()
    /** Hears every message as it is said, before [act] returns; the screen plays them while a ring waits for a tap. */
    var listener: ((SkirmishEvent) -> Unit)? = null
    /** The party's shared stock of potions, item id to count (72.10a.12). */
    val potions = linkedMapOf<String, Int>()

    init {
        require(fighters.map { it.id }.toSet().size == fighters.size) { "ids must be unique" }
        require(fighters.groupBy { it.side to it.place }.all { it.value.size == 1 }) { "one figure per place" }
        for (f in fighters) {
            val dex = f.hero?.mod(Ability.DEX) ?: f.monster!!.dexSave
            f.initiative = dice.d20(if (winded && f === party.first()) -1 else 0) + dex
        }
        order += fighters.sortedWith(compareByDescending<Fighter> { it.initiative }.thenBy { it.side })
        foes.forEach { announce(it) }
    }

    /** Whose turn it is; a party figure waits for an [Order] (or the autopilot). */
    val current: Fighter get() = order[turn]

    fun byId(id: String): Fighter = fighters.first { it.id == id }

    /** The standing figures in the order of turns, the one acting now first (72.10a.4). */
    fun queue(): List<String> {
        val n = order.size
        return (0 until n).map { order[(turn + it) % n] }.filter { it.standing }.map { it.id }
    }

    /** The abilities and spells [f] can use in this fight (72.10a.1). */
    fun moves(f: Fighter): List<Skill> = f.hero?.let { h -> h.cls.skills().filter { h.has(it) && Moves.aim(it) != null } } ?: emptyList()

    /** Why [f] cannot use [s] now, or null. */
    fun blocked(f: Fighter, s: Skill): T? = when {
        s.cost == SkillCost.SPELL_POINTS && f.sp < s.amount -> Msg72.noSp
        (s.cost == SkillCost.PER_BATTLE || s.cost == SkillCost.PER_REST) && (f.uses[s] ?: 0) <= 0 -> Msg72.noUses
        else -> null
    }

    /** Whom [f] can pick for [s]; a row spell picks any foe and hits that foe's row (72.10a.3). */
    fun aimAt(f: Fighter, s: Skill): List<Fighter> = when (Moves.aim(s)) {
        Aim.FOE -> if (Moves.weapon(s)) targets(f) else fighters.filter { it.side != f.side && it.standing }
        Aim.ROW -> fighters.filter { it.side != f.side && it.standing }
        Aim.SELF -> listOf(f)
        Aim.ALLY -> fighters.filter { it.side == f.side && it.standing }
        null -> emptyList()
    }

    /** The potions still in the stock. */
    fun drinkable(): List<String> = potions.filter { it.value > 0 }.keys.toList()

    /** What the game plays for a figure on automatic: heal a friend below half, else a cantrip, else the weapon (72.13). */
    private fun autoOrder(f: Fighter): Order {
        val friend = fighters.filter { it.side == f.side && it.standing && it.hp * 2 < it.maxHp }.minByOrNull { it.hp.toFloat() / it.maxHp }
        val can = moves(f)
        if (friend != null && Skill.CURE_WOUNDS in can && blocked(f, Skill.CURE_WOUNDS) == null) return Order.Use(Skill.CURE_WOUNDS, friend.id)
        val cantrip = listOf(Skill.FIRE_BOLT, Skill.SACRED_FLAME).firstOrNull { it in can }
        val foes = fighters.filter { it.side != f.side && it.standing }
        if (cantrip != null && foes.isNotEmpty()) return Order.Use(cantrip, foes.minByOrNull { it.hp }!!.id)
        val t = targets(f).minByOrNull { it.hp }
        return if (t != null) Order.Attack(t.id) else Order.Wait
    }

    /** Whom [f] can strike: melee reaches the front row while anyone stands there, ranged reaches all (72.11). */
    fun targets(f: Fighter): List<Fighter> {
        val other = fighters.filter { it.side != f.side && it.standing }
        if (f.ranged) return other
        val front = other.filter { it.place.row == Row.FRONT }
        return front.ifEmpty { other }
    }

    /** Why the autopilot cannot run now, or null (72p.1). */
    fun autopilotBlocked(): T? {
        val lead = fighters.first { it.side == Side.PARTY }
        return when {
            fighters.any { it.side == Side.FOES && it.boss } -> T("Nicht gegen Bosse.", "Not against bosses.")
            lead.hp * 3 < lead.maxHp -> T("Unter einem Drittel der Lebenspunkte.", "Below a third of life points.")
            intents.values.any { it.first.strong } -> T("Starke Absicht angekündigt.", "Strong intent announced.")
            else -> null
        }
    }

    fun setAutopilot(on: Boolean): Boolean {
        autopilot = on && autopilotBlocked() == null
        return autopilot
    }

    /**
     * Plays the party figure's [order], then every following turn until a party figure must choose again
     * (or the autopilot plays it). [react] gives the ring result for a party figure hit by an intent;
     * under autopilot, and for figures the player does not steer, it is [Reaction.GOOD].
     */
    fun act(order: Order, react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }): List<SkirmishEvent> {
        check(outcome == Outcome.ONGOING) { "Skirmish is over" }
        val f = current
        check(f.side == Side.PARTY && f.standing)
        perform(f, order)
        advance(react)
        return log.toList().also { log.clear() }
    }

    /** Plays on without an order: after the autopilot or a Söldner's automatic was switched on during its turn. */
    fun proceed(react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }): List<SkirmishEvent> {
        check(outcome == Outcome.ONGOING) { "Skirmish is over" }
        skipToChoice(react)
        return log.toList().also { log.clear() }
    }

    /** Starts the fight: foes that are quicker than the whole party act first. */
    fun start(react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }): List<SkirmishEvent> {
        for ((foe, plan) in intents) say(Msg72.announces.f(lang, byId(foe).name(lang), plan.first.name(lang)), foe)
        skipToChoice(react)
        return log.toList().also { log.clear() }
    }

    private fun advance(react: (Fighter, Intent) -> Reaction) {
        nextTurn()
        skipToChoice(react)
    }

    private fun skipToChoice(react: (Fighter, Intent) -> Reaction) {
        while (outcome == Outcome.ONGOING) {
            val f = current
            when {
                !f.standing -> nextTurn()
                f.side == Side.FOES -> { foeTurn(f, react); nextTurn() }
                autopilot && autopilotBlocked() != null -> {
                    autopilot = false
                    say(Msg72.autopilotStops(lang))
                    return
                }
                autopilot || f.auto -> {
                    perform(f, autoOrder(f))
                    nextTurn()
                }
                else -> return
            }
        }
    }

    private fun perform(f: Fighter, o: Order) {
        when (o) {
            Order.Wait -> say(Msg72.waits.f(lang, f.name(lang)), f.id)
            is Order.Swap -> {
                val other = fighters.firstOrNull { it.side == f.side && it.place == o.to && it !== f }
                other?.place = f.place
                f.place = o.to
                say(Msg72.swaps.f(lang, f.name(lang)), f.id)
            }
            is Order.Attack -> {
                val t = byId(o.target)
                require(t in targets(f)) { "${f.id} cannot reach ${t.id}" }
                weaponAttack(f, t)
            }
            is Order.Use -> {
                require(blocked(f, o.skill) == null) { "${f.id} cannot use ${o.skill}" }
                val t = o.target?.let { byId(it) }
                require(t == null || t in aimAt(f, o.skill)) { "${f.id} cannot aim ${o.skill} at ${t?.id}" }
                useSkill(f, o.skill, t)
            }
            is Order.Drink -> drink(f, o.item, byId(o.target))
        }
    }

    /** A target left standing for the next blow of a multiple move, the same one while it stands. */
    private fun again(f: Fighter, t: Fighter, weapon: Boolean): Fighter? {
        if (t.standing) return t
        return (if (weapon) targets(f) else fighters.filter { it.side != f.side && it.standing }).firstOrNull()
    }

    private fun cantripDice(h: Hero) = 1 + listOf(5, 11, 17).count { h.level >= it }

    private fun useSkill(f: Fighter, s: Skill, t: Fighter?) {
        val h = f.hero!!
        when (s.cost) {
            SkillCost.SPELL_POINTS -> f.sp -= s.amount
            SkillCost.PER_BATTLE, SkillCost.PER_REST -> f.uses[s] = f.uses.getValue(s) - 1
            else -> {}
        }
        say(Msg72.uses.f(lang, f.name(lang), s.title(lang)), f.id)
        when (s) {
            Skill.SECOND_WIND -> heal(f, f, dice.roll(1, 10) + h.level)
            Skill.ACTION_SURGE -> {
                var tt: Fighter? = t
                repeat(2) { tt = tt?.let { again(f, it, true) }; tt?.let { weaponAttack(f, it) } }
            }
            Skill.FEINT -> weaponAttack(f, t!!, advantage = true)
            Skill.FIRE_BOLT -> spellAttack(f, t!!, dice(cantripDice(h), 10))
            Skill.MAGIC_MISSILE -> {
                val dmg = (1..3).sumOf { dice.roll(dice(1, 4, 1)) }
                hurt(t!!, dmg, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), dmg))
            }
            Skill.SCORCHING_RAY -> {
                var tt: Fighter? = t
                repeat(3) { tt = tt?.let { again(f, it, false) }; if (outcome == Outcome.ONGOING) tt?.let { spellAttack(f, it, dice(2, 6)) } }
            }
            Skill.FIREBALL -> {
                val amount = dice.roll(dice(8, 6))
                val row = t!!.place.row
                for (g in fighters.filter { it.side == t.side && it.standing && it.place.row == row }) {
                    if (outcome == Outcome.ONGOING) saveSpell(f, g, amount, half = true)
                }
            }
            Skill.SACRED_FLAME -> saveSpell(f, t!!, dice.roll(dice(cantripDice(h), 8)), half = false)
            Skill.CURE_WOUNDS -> heal(f, t!!, dice.roll(1 + h.level / 2, 8) + h.mod(Ability.WIS))
            Skill.BLESS -> {
                f.blessed = true
                say(Msg72.blessed.f(lang, f.name(lang)), f.id)
            }
            else -> {}
        }
    }

    private fun bless(f: Fighter) = if (f.blessed) dice.roll(1, 4) else 0

    /** A spell attack against the armor class; a 20 doubles the dice (72.10a.1). */
    private fun spellAttack(f: Fighter, t: Fighter, dmg: DiceExpr) {
        val h = f.hero!!
        val roll = dice.d20()
        val bonus = h.spellAttack + bless(f)
        val crit = roll == 20
        val hit = roll != 1 && (crit || roll + bonus >= t.ac)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, hit)
        if (!hit) {
            say(Msg72.misses.f(lang, f.name(lang), t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val n = maxOf(1, dice.roll(if (crit) dmg.copy(count = dmg.count * 2) else dmg))
        hurt(t, n, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), n), info)
    }

    /** A save against the caster's spell DC: held, half or nothing; failed, the full damage (72.10a.1). */
    private fun saveSpell(f: Fighter, t: Fighter, amount: Int, half: Boolean) {
        val dc = f.hero!!.spellDc
        val mod = t.hero?.mod(Ability.DEX) ?: t.monster!!.dexSave
        val roll = dice.d20()
        val saved = roll + mod >= dc
        val info = RollInfo(RollKind.SAVE, roll, mod, dc, saved)
        if (saved && !half) {
            say(Msg72.dodges.f(lang, t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val n = maxOf(1, if (saved) amount / 2 else amount)
        hurt(t, n, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), n), info)
    }

    private fun heal(f: Fighter, t: Fighter, amount: Int) {
        val n = minOf(t.maxHp - t.hp, amount).coerceAtLeast(0)
        t.hp += n
        say(if (f === t) Msg72.healsSelf.f(lang, f.name(lang), n) else Msg72.heals.f(lang, f.name(lang), t.name(lang), n), f.id, t.id)
    }

    private fun drink(f: Fighter, item: String, t: Fighter) {
        require((potions[item] ?: 0) > 0 && t.standing && t.side == f.side) { "${f.id} cannot give $item to ${t.id}" }
        potions[item] = potions.getValue(item) - 1
        val def = Items[item]
        val n = minOf(t.maxHp - t.hp, dice.roll(def.heal!!)).coerceAtLeast(0)
        t.hp += n
        say(if (f === t) Msg72.drinks.f(lang, f.name(lang), def.name(lang), n) else Msg72.gives.f(lang, f.name(lang), t.name(lang), def.name(lang), n), f.id, t.id)
    }

    private fun weaponAttack(f: Fighter, t: Fighter, advantage: Boolean = false) {
        val h = f.hero!!
        val roll = dice.d20(if (advantage) 1 else 0)
        val crit = roll >= h.critFrom
        val bonus = h.attackBonus(h.weapon) + bless(f)
        val hit = roll != 1 && (crit || roll + bonus >= t.ac)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, hit)
        if (!hit) {
            say(Msg72.misses.f(lang, f.name(lang), t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val base = h.weaponDamage(h.weapon)
        var dmg = dice.roll(if (crit) base.copy(count = base.count * 2) else base)
        // sneak attack: the first hit of the fight and every hit with advantage (SRD, as in the old fight)
        if (h.has(Skill.SNEAK_ATTACK) && (advantage || !f.sneaked)) dmg += dice.roll(maxOf(1, h.level / 2), 6)
        f.sneaked = true
        dmg = maxOf(1, dmg)
        hurt(t, dmg, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), dmg), info)
    }

    private fun foeTurn(foe: Fighter, react: (Fighter, Intent) -> Reaction) {
        val plan = intents.remove(foe.id)
        if (plan == null) {
            // its intent was broken: it gathers itself and announces anew
            announce(foe)
            intents[foe.id]?.let { say(Msg72.announces.f(lang, foe.name(lang), it.first.name(lang)), foe.id) }
            return
        }
        val (intent, aimed) = plan
        val m = foe.monster!!
        say(Msg72.foeUses.f(lang, foe.name(lang), intent.name(lang)), foe.id)
        when (intent.kind) {
            IntentKind.CALL -> summon(foe)
            IntentKind.GATHER -> {
                val heal = minOf(foe.maxHp - foe.hp, dice.roll(GATHER_HEAL))
                foe.hp += heal
                say(Msg72.gathers.f(lang, foe.name(lang), heal), foe.id, foe.id)
            }
            IntentKind.STRIKE -> {}
        }
        // the target may have moved or fallen since the announcement: then the nearest one takes it
        val reach = targets(foe)
        val hit = if (intent.kind != IntentKind.STRIKE) emptyList() else listOfNotNull(reach.firstOrNull { it.id in aimed } ?: reach.firstOrNull())
        for (t in hit) {
            // the ring comes with the blow, before anyone knows whether it lands
            val r = if (!intent.ring) Reaction.NONE else if (autopilot || t.auto) Reaction.GOOD else react(t, intent)
            val roll = dice.d20()
            val info = RollInfo(RollKind.ATTACK, roll, m.attackBonus, t.ac, !(roll == 1 || (roll != 20 && roll + m.attackBonus < t.ac)))
            if (!info.success) {
                say(Msg72.misses.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, roll = info)
                continue
            }
            var dmg = dice.roll(if (roll == 20) m.damage.copy(count = m.damage.count * 2) else m.damage)
            intent.extra?.let { dmg += dice.roll(it) }
            if (r != Reaction.NONE) say(Msg72.reacts(r).f(lang, t.name(lang)), t.id)
            dmg = (dmg * r.share).toInt()
            if (dmg > 0) hurt(t, dmg, foe.id, Msg72.hits.f(lang, foe.name(lang), t.name(lang), dmg), info)
            if (outcome != Outcome.ONGOING) return
        }
        announce(foe)
        intents[foe.id]?.let { say(Msg72.announces.f(lang, foe.name(lang), it.first.name(lang)), foe.id) }
    }

    /** The foe picks its next move and its target, and says it (72.11: the ring follows only on these). */
    private fun announce(foe: Fighter) {
        if (!foe.standing || outcome != Outcome.ONGOING) return
        val intent = pickIntent(foe)
        val reach = targets(foe)
        val aimed = if (intent.kind != IntentKind.STRIKE || reach.isEmpty()) emptyList() else listOf(dice.pick(reach).id)
        foe.takenSinceAnnounce = 0
        intents[foe.id] = intent to aimed
    }

    private fun freeFoeSpot(): Spot? = Spot.ALL.firstOrNull { s -> fighters.none { it.side == Side.FOES && it.place == s && it.standing } }

    /** Provisional: Grak strikes half the time or more, calls while goblins may still come, gathers below half his life. */
    private fun pickIntent(foe: Fighter): Intent {
        if (foe.monster?.id != GRAK) return Intents.stab
        val can = buildList {
            add(Intents.heavy); add(Intents.heavy)
            if (called < CALL_MAX && freeFoeSpot() != null) add(Intents.call)
            if (foe.hp * 2 < foe.maxHp) add(Intents.gather)
        }
        return dice.pick(can)
    }

    private var called = 0

    /** A goblin answers the call: to the first free place, front first; it acts right after its caller. */
    private fun summon(by: Fighter) {
        val spot = freeFoeSpot() ?: return
        fighters.firstOrNull { it.side == Side.FOES && it.place == spot }?.let { gone ->
            if (order.indexOf(gone) < turn) turn--
            all.remove(gone); order.remove(gone)
        }
        val m = Monsters[CALLED]
        called++
        val g = Fighter("gob$called", Side.FOES, spot, monster = m, hp = dice.roll(m.hp))
        g.initiative = dice.d20() + m.dexSave
        all += g
        order.add(order.indexOf(by) + 1, g)
        say(Msg72.answers.f(lang, m.name(lang)), g.id)
        announce(g)
    }

    private fun hurt(t: Fighter, dmg: Int, by: String, text: String, roll: RollInfo? = null) {
        t.hp = (t.hp - dmg).coerceAtLeast(0)
        say(text, by, t.id, dmg, roll)
        if (t.standing) {
            val plan = intents[t.id] ?: return
            t.takenSinceAnnounce += dmg
            if (plan.first.breakable && t.takenSinceAnnounce * BREAK_SHARE >= t.maxHp) {
                intents.remove(t.id)
                say(Msg72.broken.f(lang, t.name(lang), plan.first.name(lang)), target = t.id)
            }
            return
        }
        if (t.side == Side.FOES) {
            intents.remove(t.id)
            say(Msg72.falls.f(lang, t.name(lang)), target = t.id)
        } else if (t === fighters.first()) {
            say(Msg72.heroFalls.f(lang, t.name(lang)), target = t.id)
            outcome = Outcome.LOST
            return
        } else {
            // a Söldner is knocked out, not killed (72.8)
            knockouts++
            say(Msg72.knockedOut.f(lang, t.name(lang)), target = t.id)
        }
        if (fighters.none { it.side == Side.FOES && it.standing }) outcome = Outcome.WON
    }

    private fun say(text: String, actor: String? = null, target: String? = null, damage: Int = 0, roll: RollInfo? = null) {
        val e = SkirmishEvent(
            text, actor, target, damage, fighters.associate { it.id to it.hp }, fighters.associate { it.id to it.place }, LinkedHashMap(intents),
            roll, queue(), fighters.associate { it.id to it.sp },
        )
        log += e
        listener?.invoke(e)
    }

    companion object {
        const val GRAK = "hobgoblin_captain"
        const val CALLED = "goblin"
        /** Provisional: a hit taking a fifth of the foe's life points or more breaks a breakable intent. */
        const val BREAK_SHARE = 5
        /** Provisional: Grak calls at most two goblins per fight. */
        const val CALL_MAX = 2
        /** Provisional: what gathering strength heals. */
        val GATHER_HEAL = dice(2, 10)

        /** The level of hero and Söldner in the probe, fixed so the fight tests the fight and not the character (72.10a.10). */
        const val PROBE_LEVEL = 3

        /** Söldner names, the next free one for each (STORY-BLENDE.md `[72.10a.5.namen]`); never the hero's. */
        val MERC_NAMES = listOf("Bertram", "Hagen", "Edric", "Tamsin", "Wulf", "Ilsa", "Corwin", "Maren", "Odo", "Fenna", "Rurik", "Sela")

        private val json = kotlinx.serialization.json.Json { ignoreUnknownKeys = true; encodeDefaults = true; allowStructuredMapKeys = true }

        /** A copy of the hero on [PROBE_LEVEL], hit points and spell points full; the real hero stays as he is. */
        private fun atProbeLevel(real: Hero): Hero {
            val h = json.decodeFromString(Hero.serializer(), json.encodeToString(Hero.serializer(), real))
            h.chapter = real.chapter
            h.level = PROBE_LEVEL
            h.restoreFully()
            return h
        }

        /** The probe's lineup: hero in front, a Söldner of [cls] behind (ranged) or beside (melee), Grak opposite. */
        fun grakProbe(state: GameState, cls: CharClass, lang: Lang, dice: Dice = Dice()): Skirmish {
            val hero = atProbeLevel(state.hero)
            val merc = Hero.create(MERC_NAMES.first { !it.equals(hero.name, ignoreCase = true) }, Race.HUMAN, cls)
            merc.level = PROBE_LEVEL
            merc.restoreFully()
            val mercBack = merc.weapon?.def?.ranged == true || cls.caster
            val grak = Monsters[GRAK]
            return Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = hero, hp = hero.hp),
                    Fighter("merc", Side.PARTY, if (mercBack) Spot(Row.BACK, 0) else Spot(Row.FRONT, 1), hero = merc, hp = merc.maxHp),
                ),
                listOf(Fighter("grak", Side.FOES, Spot(Row.FRONT, 0), monster = grak, hp = dice.roll(grak.hp))),
                lang, dice, winded = state.winded,
            ).also { it.potions["potion"] = PROBE_POTIONS }
        }

        /** Healing potions in the probe's stock; the real bag stays untouched. */
        const val PROBE_POTIONS = 2
    }
}

/** Texts of the probe; placeholders for the build, final wording with Kreativ (41). */
private object Msg72 {
    val announces = T("{0} kündigt an: {1}.", "{0} announces: {1}.")
    val foeUses = T("{0}: {1}!", "{0}: {1}!")
    val hits = T("{0} trifft {1}: {2} Schaden.", "{0} hits {1}: {2} damage.")
    val misses = T("{0} verfehlt {1}.", "{0} misses {1}.")
    val waits = T("{0} wartet ab.", "{0} waits.")
    val swaps = T("{0} tauscht den Platz.", "{0} changes places.")
    val falls = T("{0} fällt.", "{0} falls.")
    val heroFalls = T("{0} bricht zusammen.", "{0} collapses.")
    val knockedOut = T("{0} geht zu Boden, bewusstlos.", "{0} goes down, unconscious.")
    val gathers = T("{0} sammelt Kraft: {1} Lebenspunkte zurück.", "{0} gathers strength: {1} life points back.")
    val answers = T("Ein {0} eilt herbei.", "A {0} comes running.")
    val broken = T("{0} taumelt, {1} vereitelt.", "{0} staggers, {1} foiled.")
    val autopilotStops = T("Automatik hält an.", "Autopilot stops.")
    val uses = T("{0} wirkt {1}.", "{0} uses {1}.")
    val blessed = T("{0} ist gesegnet.", "{0} is blessed.")
    val dodges = T("{0} weicht aus.", "{0} dodges.")
    val heals = T("{0} heilt {1}: {2} Lebenspunkte.", "{0} heals {1}: {2} life points.")
    val healsSelf = T("{0} erholt sich: {1} Lebenspunkte.", "{0} recovers: {1} life points.")
    val drinks = T("{0} trinkt {1}: {2} Lebenspunkte.", "{0} drinks {1}: {2} life points.")
    val gives = T("{0} gibt {1} {2}: {3} Lebenspunkte.", "{0} gives {1} {2}: {3} life points.")
    val noSp = T("Nicht genug Zauberpunkte.", "Not enough spell points.")
    val noUses = T("Für diesen Kampf erschöpft.", "Spent for this fight.")
    private val good = T("{0} fängt den Schlag halb ab.", "{0} half catches the blow.")
    private val perfect = T("{0} weicht dem Schlag ganz aus.", "{0} evades the blow entirely.")
    fun reacts(r: Reaction) = if (r == Reaction.PERFECT) perfect else good
}
