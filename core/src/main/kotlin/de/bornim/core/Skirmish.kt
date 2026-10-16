package de.bornim.core

/*
 * Probe 72.10: the hero and a Söldner against one foe, in two rows of two places (72.11, 72v).
 * Stands beside [Battle] and does not replace it; option A stays the fallback (72.11).
 *
 * Decided and built here: two rows instead of near/far, lineup fixed at the start, a place swap costs the
 * figure's turn, the ring only for the attacked figure and only on an announced intent, small hits without
 * input, autopilot after 72.13 (only "gut", stops below a third of LP or on a strong intent, never on bosses,
 * only weapon attacks), a downed Söldner is out, not dead (72.8), knockouts counted per fight (72r), winded
 * means disadvantage on initiative (86.3).
 *
 * Provisional until the combat document is readable here: Grak's three intents ([Intents.grak]) and what
 * a ring grade does to the damage ([Reaction.share]).
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

/** What a foe announces for its next turn. [strong] stops the autopilot (72p.1); [ring] lets the target react. */
data class Intent(
    val id: String,
    val name: T,
    /** Damage dice added to the foe's own weapon damage. */
    val extra: DiceExpr? = null,
    /** Hits every standing figure of the front row instead of one. */
    val sweep: Boolean = false,
    val strong: Boolean = false,
    val ring: Boolean = true,
)

object Intents {
    /** Provisional (see the file head): a blow, a heavy blow, a sweep across the front row. */
    val grak = listOf(
        Intent("blow", T("Hieb", "Blow")),
        Intent("heavy", T("Wuchtschlag", "Heavy blow"), extra = dice(2, 6), strong = true),
        Intent("sweep", T("Rundumschlag", "Sweep"), sweep = true),
    )
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

    fun name(lang: Lang): String = hero?.name ?: monster!!.name(lang)
}

/** One message of the probe, with who acted and who was hit, for the screen. */
data class SkirmishEvent(val text: String, val actor: String? = null, val target: String? = null, val damage: Int = 0)

sealed interface Order {
    data class Attack(val target: String) : Order
    /** Moves to [to]; a figure standing there takes the old place. Costs the turn (72.11). */
    data class Swap(val to: Spot) : Order
    data object Wait : Order
}

class Skirmish(
    party: List<Fighter>,
    foes: List<Fighter>,
    var lang: Lang,
    private val dice: Dice = Dice(),
    /** The hero is out of breath: disadvantage on initiative (86.3). */
    winded: Boolean = false,
) {
    val fighters: List<Fighter> = party + foes
    /** Knocked-out Söldner in this fight (72r). */
    var knockouts = 0
        private set
    var outcome = Outcome.ONGOING
        private set
    /** The foes' announced next moves, by foe id. */
    val intents = LinkedHashMap<String, Pair<Intent, List<String>>>()
    var autopilot = false
        private set
    private val order: List<Fighter>
    private var turn = 0
    private val log = mutableListOf<SkirmishEvent>()

    init {
        require(fighters.map { it.id }.toSet().size == fighters.size) { "ids must be unique" }
        require(fighters.groupBy { it.side to it.place }.all { it.value.size == 1 }) { "one figure per place" }
        for (f in fighters) {
            val dex = f.hero?.mod(Ability.DEX) ?: f.monster!!.dexSave
            f.initiative = dice.d20(if (winded && f === party.first()) -1 else 0) + dex
        }
        order = fighters.sortedWith(compareByDescending<Fighter> { it.initiative }.thenBy { it.side })
        foes.forEach { announce(it) }
    }

    /** Whose turn it is; a party figure waits for an [Order] (or the autopilot). */
    val current: Fighter get() = order[turn % order.size]

    fun byId(id: String): Fighter = fighters.first { it.id == id }

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

    /** Starts the fight: foes that are quicker than the whole party act first. */
    fun start(react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }): List<SkirmishEvent> {
        for ((foe, plan) in intents) say(Msg72.announces.f(lang, byId(foe).name(lang), plan.first.name(lang)), foe)
        skipToChoice(react)
        return log.toList().also { log.clear() }
    }

    private fun advance(react: (Fighter, Intent) -> Reaction) {
        turn++
        skipToChoice(react)
    }

    private fun skipToChoice(react: (Fighter, Intent) -> Reaction) {
        while (outcome == Outcome.ONGOING) {
            val f = current
            when {
                !f.standing -> turn++
                f.side == Side.FOES -> { foeTurn(f, react); turn++ }
                autopilot && autopilotBlocked() != null -> {
                    autopilot = false
                    say(Msg72.autopilotStops(lang))
                    return
                }
                autopilot -> {
                    val t = targets(f).minByOrNull { it.hp }
                    perform(f, if (t != null) Order.Attack(t.id) else Order.Wait)
                    turn++
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
        }
    }

    private fun weaponAttack(f: Fighter, t: Fighter) {
        val h = f.hero!!
        val roll = dice.d20()
        val crit = roll >= h.critFrom
        if (roll == 1 || (!crit && roll + h.attackBonus(h.weapon) < t.ac)) {
            say(Msg72.misses.f(lang, f.name(lang), t.name(lang)), f.id, t.id)
            return
        }
        val base = h.weaponDamage(h.weapon)
        val dmg = maxOf(1, dice.roll(if (crit) base.copy(count = base.count * 2) else base))
        hurt(t, dmg, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), dmg))
    }

    private fun foeTurn(foe: Fighter, react: (Fighter, Intent) -> Reaction) {
        val (intent, aimed) = intents.remove(foe.id) ?: return
        val m = foe.monster!!
        // the target may have moved or fallen since the announcement: then the nearest one takes it
        val reach = targets(foe)
        val hit = if (intent.sweep) reach.filter { it.place.row == Row.FRONT }.ifEmpty { reach.take(1) }
        else listOfNotNull(reach.firstOrNull { it.id in aimed } ?: reach.firstOrNull())
        say(Msg72.foeUses.f(lang, foe.name(lang), intent.name(lang)), foe.id)
        for (t in hit) {
            val roll = dice.d20()
            if (roll == 1 || (roll != 20 && roll + m.attackBonus < t.ac)) {
                say(Msg72.misses.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
                continue
            }
            var dmg = dice.roll(if (roll == 20) m.damage.copy(count = m.damage.count * 2) else m.damage)
            intent.extra?.let { dmg += dice.roll(it) }
            val r = if (!intent.ring) Reaction.NONE else if (autopilot) Reaction.GOOD else react(t, intent)
            if (r != Reaction.NONE) say(Msg72.reacts(r).f(lang, t.name(lang)), t.id)
            dmg = (dmg * r.share).toInt()
            if (dmg > 0) hurt(t, dmg, foe.id, Msg72.hits.f(lang, foe.name(lang), t.name(lang), dmg))
            if (outcome != Outcome.ONGOING) return
        }
        announce(foe)
        intents[foe.id]?.let { say(Msg72.announces.f(lang, foe.name(lang), it.first.name(lang)), foe.id) }
    }

    /** The foe picks its next move and its target, and says it (72.11: the ring follows only on these). */
    private fun announce(foe: Fighter) {
        if (!foe.standing || outcome != Outcome.ONGOING) return
        val intent = dice.pick(Intents.grak)
        val reach = targets(foe)
        val aimed = if (intent.sweep) reach.filter { it.place.row == Row.FRONT }.map { it.id } else listOfNotNull(dice.pick(reach).id)
        intents[foe.id] = intent to aimed
    }

    private fun hurt(t: Fighter, dmg: Int, by: String, text: String) {
        t.hp = (t.hp - dmg).coerceAtLeast(0)
        say(text, by, t.id, dmg)
        if (t.standing) return
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

    private fun say(text: String, actor: String? = null, target: String? = null, damage: Int = 0) {
        log += SkirmishEvent(text, actor, target, damage)
    }

    companion object {
        /** The probe's lineup: hero in front, a Söldner of [cls] behind (ranged) or beside (melee), Grak opposite. */
        fun grakProbe(state: GameState, cls: CharClass, lang: Lang, dice: Dice = Dice()): Skirmish {
            val hero = state.hero
            val merc = Hero.create("Söldner", Race.HUMAN, cls)
            if (hero.level > 1) merc.gainXp(Rules.xpForLevel[hero.level] - merc.xp)
            val mercBack = merc.weapon?.def?.ranged == true || cls.caster
            val grak = Monsters["hobgoblin_captain"]
            return Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = hero, hp = hero.hp),
                    Fighter("merc", Side.PARTY, if (mercBack) Spot(Row.BACK, 0) else Spot(Row.FRONT, 1), hero = merc, hp = merc.maxHp),
                ),
                listOf(Fighter("grak", Side.FOES, Spot(Row.FRONT, 0), monster = grak, hp = dice.roll(grak.hp))),
                lang, dice, winded = state.winded,
            )
        }
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
    val autopilotStops = T("Automatik hält an.", "Autopilot stops.")
    private val good = T("{0} fängt den Schlag halb ab.", "{0} half catches the blow.")
    private val perfect = T("{0} weicht dem Schlag ganz aus.", "{0} evades the blow entirely.")
    fun reacts(r: Reaction) = if (r == Reaction.PERFECT) perfect else good
}
