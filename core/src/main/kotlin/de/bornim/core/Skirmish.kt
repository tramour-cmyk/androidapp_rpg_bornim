package de.bornim.core

/*
 * MARS (72.10): the hero and a Söldner against one foe, in two rows of two places (72.11, 72v).
 * Stands beside [Battle] and does not replace it; option A stays the fallback (72.11).
 *
 * Decided and built here: two rows instead of near/far, lineup fixed at the start, a place swap costs the
 * figure's turn, the ring only for the attacked figure and only on an announced intent, small hits without
 * input, autopilot after 72.13 (only "gut", stops below a third of LP or on a strong intent, never on bosses,
 * only weapon attacks and cantrips), a downed Söldner is out, not dead (72.8), knockouts counted per fight (72r),
 * winded means disadvantage on initiative (86.3). Rows give cover and point-blank disadvantage (72.10a.7).
 * Intents that attack the lineup (72.10a.8): Grak breaks through the front row, a goblin flanks it; a place swap
 * costs only half a turn, so moving is an answer and not a loss.
 * A role and a reaction for each class (72.10a.9, idea paper 72.10a): the fighter covers (draws the announced
 * blows onto himself) and strikes back on a perfect ring; the rogue feints from the back row past the front and,
 * on a perfect ring, steps into the foe's back (next blow with advantage); the cleric heals across the rows and
 * prays on a perfect ring (a small heal); the wizard's area spells from behind stay as they are, his shield waits (.2).
 * Two weapons (72.10a.11): each figure carries a main and a second weapon (one melee, one ranged); drawing the other
 * is half a turn like a place swap, or rides along with the swap, so a change of row with a change of weapon costs no blow.
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
data class RollInfo(
    val kind: RollKind, val d20: Int, val bonus: Int, val versus: Int, val success: Boolean,
    /** +1 advantage, -1 disadvantage from the rows (72.10a.7), 0 neither. */
    val mode: Int = 0,
)

/** Whom a move is aimed at: one foe, the whole row of a foe, oneself, a friend (72.10a.3). */
enum class Aim { FOE, ROW, SELF, ALLY }

/** The abilities and spells the new fight knows (72.10a.1); the rest of a class waits for later. */
object Moves {
    fun aim(s: Skill): Aim? = when (s) {
        Skill.FIRE_BOLT, Skill.MAGIC_MISSILE, Skill.SCORCHING_RAY, Skill.SACRED_FLAME, Skill.FEINT, Skill.ACTION_SURGE -> Aim.FOE
        Skill.FIREBALL, Skill.BURNING_HANDS -> Aim.ROW
        Skill.SECOND_WIND, Skill.BLESS -> Aim.SELF
        Skill.CURE_WOUNDS -> Aim.ALLY
        else -> null
    }

    /** Weapon moves reach like a weapon; spells reach every foe. */
    fun weapon(s: Skill) = s == Skill.FEINT || s == Skill.ACTION_SURGE

    /** Provisional (72.10a.9): the cleric's small heal on a perfect ring. */
    val PRAYER_HEAL = dice(1, 6)
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
    /** What the intent does besides damage (130.3). */
    val effect: Effect? = null,
    /** Any hit foils it, however light (the pack leader, the scout's retreat). */
    val breakOnAnyHit: Boolean = false,
    /** Short sight of the intent, shown under the name (130.3 "Zeichen"). */
    val sign: T? = null,
)

/** The special effects of the announced intents of 130.3. */
enum class Effect {
    /** Wolf: the target loses the next turn if it still stands where it stood; a changed place makes the pounce miss. */
    POUNCE,
    /** Wolf: every wolf strikes the same target together. */
    CIRCLE,
    /** Scout: if the target waited since the announcement, the arrow misses. */
    AIM,
    /** Scout: it slips away and cannot be struck until its next turn. */
    SHADOW,
    /** Spider: a hit holds the target, it loses its next turn. */
    WEB,
    /** Grak (72.10a.8): aims at the back row, shoves the front figure before it back and strikes the target, now in front. */
    BREAKTHROUGH,
    /** Goblin (72.10a.8): runs past the front row at a figure behind it, without cover; a changed place makes it miss. */
    FLANK,
}

object Intents {
    val heavy = Intent("heavy", T("Schwerer Hieb", "Heavy blow"), extra = dice(2, 6), strong = true, breakable = true)
    val call = Intent("call", T("Rudel rufen", "Call the pack"), IntentKind.CALL, ring = false)
    val gather = Intent("gather", T("Kraft sammeln", "Gather strength"), IntentKind.GATHER, ring = false, breakable = true)
    /** Grak's three intents (combat document). */
    val grak = listOf(heavy, call, gather)
    /** A plain stab, as a pack's small hits: no ring (72.11). */
    val stab = Intent("stab", T("Stich", "Stab"), ring = false)

    /** 130.3: the wolf, the spider and the scout each have two intents that ask for different answers. */
    val pounce = Intent("pounce", T("Anspringen", "Pounce"), ring = false, effect = Effect.POUNCE)
    val circle = Intent("circle", T("Einkreisen", "Circle"), IntentKind.GATHER, ring = false, effect = Effect.CIRCLE, breakOnAnyHit = true)
    val venom = Intent("venom", T("Gift sammeln", "Gather venom"), extra = dice(2, 6), strong = true, ring = false, breakable = true)
    val web = Intent("web", T("Netz werfen", "Cast web"), effect = Effect.WEB)
    val aim = Intent("aim", T("Anlegen", "Take aim"), extra = dice(1, 6), ring = false, effect = Effect.AIM)
    val shadow = Intent("shadow", T("In den Schatten", "Into the shadows"), IntentKind.GATHER, ring = false, effect = Effect.SHADOW, breakOnAnyHit = true)
    /** 72.10a.8: intents against the lineup; names from the idea paper, signs and final wording with Homer (41). */
    val breakthrough = Intent("breakthrough", T("Durchbrechen", "Break through"), extra = dice(1, 6), breakable = true, effect = Effect.BREAKTHROUGH)
    val flank = Intent("flank", T("Flanke", "Flank"), ring = false, effect = Effect.FLANK, breakOnAnyHit = true)
    val wolf = listOf(pounce, circle)
    val spider = listOf(venom, web)
    val scout = listOf(aim, shadow)
}

/** One figure in the fight: the hero, a Söldner (a [Hero] that does not level up, 72t) or a foe. */
class Fighter(
    val id: String,
    val side: Side,
    var place: Spot,
    val hero: Hero? = null,
    val monster: MonsterDef? = null,
    hp: Int,
    /** The second weapon (72.10a.11): the other kind than the main one, melee or ranged; null when there is none. */
    val second: Gear? = null,
) {
    val maxHp: Int = hp
    var hp: Int = hp
        internal set
    val standing: Boolean get() = hp > 0
    var initiative = 0
        internal set
    val ac: Int get() = hero?.armorClass ?: monster!!.ac
    /** The weapon in hand: the main one, or the second after drawing it (72.10a.11). */
    val weapon: Gear? get() = if (drawn && second != null) second else hero?.weapon
    /** The weapon not in hand, the one a draw takes up. */
    val spare: Gear? get() = if (drawn) hero?.weapon else second
    /** Holds the second weapon. */
    var drawn = false
        internal set
    /**
     * How the figure is drawn: the hero, or after a draw the same hero with the second weapon in the hand (72.10a.11,
     * Chef 19.10. at test 34.7: "sehe ich nicht am Avatar"); the shield stays on the arm. Only for the pictures.
     */
    val looks: Hero? get() {
        val h = hero ?: return null
        val w = second?.takeIf { drawn } ?: return h
        return drawnLook ?: Hero(h.name, h.race, h.cls, h.level, base = h.base.toMutableMap(), gear = h.gear.toMutableMap().also { it[GearSlot.MAIN_HAND] = w },
            sex = h.sex, build = h.build, skin = h.skin, hair = h.hair).also { drawnLook = it }
    }
    private var drawnLook: Hero? = null
    val ranged: Boolean get() = weapon?.def?.ranged == true || monster?.id == Skirmish.SCOUT || monster?.id == Skirmish.SPIDER
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
    /** Loses its next turn (wolf pounce, web; 130.3). */
    var held = false
        internal set
    /** Waited since the foes last acted: ducks a scout's arrow (130.3). */
    internal var waited = false
    /** In the shadows until its next turn (the scout): attacks on it have disadvantage (208). */
    var hidden = false
        internal set
    /** Swapped places on this turn: half of it is spent, a second swap is not allowed (72.10a.8). */
    var moved = false
        internal set
    /** Stepped into a foe's back on a perfect ring: the next weapon blow has advantage (rogue, 72.10a.9). */
    var opening = false
        internal set

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
    /**
     * Moves to [to]; a figure standing there takes the old place. Costs half the turn, once per turn (72.10a.8).
     * [draw]: takes up the other weapon on the way, in the same half (72.10a.11).
     */
    data class Swap(val to: Spot, val draw: Boolean = false) : Order
    /** Takes up the other weapon; half the turn, as a swap, and not both in one turn unless together (72.10a.11). */
    data object Draw : Order
    data object Wait : Order
    /** The fighter in the front row draws every announced blow aimed at a friend onto himself; costs the turn (72.10a.9). */
    data object Guard : Order
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
    private val winded: Boolean = false,
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
    private fun nextTurn() { order[turn].moved = false; turn = (turn + 1) % order.size }
    private val log = mutableListOf<SkirmishEvent>()
    /** Hears every message as it is said, before [act] returns; the screen plays them while a ring waits for a tap. */
    var listener: ((SkirmishEvent) -> Unit)? = null
    /** The party's shared stock of potions, item id to count (72.10a.12). */
    val potions = linkedMapOf<String, Int>()
    /** Where the target of a pounce stood when the wolf announced it (130.3). */
    private val aimSpot = mutableMapOf<String, Spot>()

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
    fun moves(f: Fighter): List<Skill> = f.hero?.let { h -> Skill.entries.filter { it.cls == h.cls && h.has(it) && Moves.aim(it) != null } } ?: emptyList()

    /** Why [f] cannot use [s] now, or null. */
    fun blocked(f: Fighter, s: Skill): T? = when {
        s.cost == SkillCost.SPELL_POINTS && f.sp < s.amount -> Msg72.noSp
        s.cost == SkillCost.PER_BATTLE && (f.uses[s] ?: 0) <= 0 -> Msg72.noBattle
        s.cost == SkillCost.PER_REST && (f.uses[s] ?: 0) <= 0 -> Msg72.noRest
        aimAt(f, s).isEmpty() -> Msg72.noTarget
        else -> null
    }

    /** Whom [f] can pick for [s]; a row spell picks any foe and hits that foe's row (72.10a.3). */
    fun aimAt(f: Fighter, s: Skill): List<Fighter> = when (Moves.aim(s)) {
        Aim.FOE -> if (Moves.weapon(s) && !feintsPast(f, s)) targets(f) else fighters.filter { it.side != f.side && it.standing }
        Aim.ROW -> fighters.filter { it.side != f.side && it.standing }
        Aim.SELF -> listOf(f)
        Aim.ALLY -> fighters.filter { it.side == f.side && it.standing }
        null -> emptyList()
    }

    /** A feint from the back row with a friend in front slips past the front and reaches every foe (72.10a.9). */
    private fun feintsPast(f: Fighter, s: Skill) = s == Skill.FEINT && covers(f)

    /** [f] stands in the back row with a friend standing in front. */
    private fun covers(f: Fighter) = f.place.row == Row.BACK && fighters.any { it.side == f.side && it.standing && it.place.row == Row.FRONT }

    /** The announced blows [f] can draw onto himself by covering: a fighter in the front row, blows aimed at a friend (72.10a.9). */
    fun guardable(f: Fighter): List<String> {
        if (f.hero?.cls != CharClass.FIGHTER || f.place.row != Row.FRONT || !f.standing) return emptyList()
        return intents.filter { (_, plan) -> plan.second.any { it != f.id } }.keys.toList()
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
        // shoved to the front with a bow in hand (Grak's breakthrough): take up the melee weapon first (72.10a.11)
        if (canDraw(f) && f.place.row == Row.FRONT && f.weapon?.def?.ranged == true && f.spare?.def?.ranged == false) return Order.Draw
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

    /** Whether [f] may still swap places on this turn (72.10a.8: once, for half the turn). */
    fun canSwap(f: Fighter): Boolean = !f.moved

    /** Whether [f] may take up its other weapon now (72.10a.11): once per turn, in the half a swap would take. */
    fun canDraw(f: Fighter): Boolean = !f.moved && f.spare != null

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
        // a swap or a draw is half a turn: the same figure acts once more (72.10a.8, 72.10a.11)
        if (order is Order.Swap || order is Order.Draw) f.moved = true else advance(react)
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
        if (winded) say(Msg72.winded.f(lang, fighters.first { it.side == Side.PARTY }.name(lang)))
        for (foe in intents.keys.toList()) sayAnnounce(byId(foe))
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
                f.held -> { f.held = false; say(Msg130.loses.f(lang, f.name(lang)), f.id); nextTurn() }
                f.side == Side.FOES -> { foeTurn(f, react); nextTurn() }
                autopilot && autopilotBlocked() != null -> {
                    autopilot = false
                    say(Msg72.autopilotStops(lang))
                    return
                }
                autopilot || f.auto -> {
                    val o = autoOrder(f)
                    perform(f, o)
                    // the draw was half the turn: the blow follows with the other weapon (72.10a.11)
                    if (o is Order.Draw && outcome == Outcome.ONGOING) { f.moved = true; perform(f, autoOrder(f)) }
                    nextTurn()
                }
                else -> return
            }
        }
    }

    private fun perform(f: Fighter, o: Order) {
        f.waited = o is Order.Wait
        when (o) {
            Order.Wait -> say(Msg72.waits.f(lang, f.name(lang)), f.id)
            Order.Guard -> {
                val drawn = guardable(f)
                require(drawn.isNotEmpty()) { "${f.id} cannot cover" }
                for (id in drawn) {
                    intents[id] = intents.getValue(id).first to listOf(f.id)
                    aimSpot[id] = f.place
                }
                say(Msg72.covers.f(lang, f.name(lang)), f.id)
            }
            is Order.Swap -> {
                require(!f.moved && o.to != f.place) { "${f.id} cannot swap to ${o.to}" }
                val other = fighters.firstOrNull { it.side == f.side && it.place == o.to && it !== f }
                other?.place = f.place
                f.place = o.to
                say(Msg72.swaps.f(lang, f.name(lang)), f.id)
                if (o.draw) draw(f)
            }
            Order.Draw -> {
                require(canDraw(f)) { "${f.id} cannot draw" }
                draw(f)
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
        val spell = s.cost == SkillCost.SPELL_POINTS || s.cost == SkillCost.NONE
        say((if (spell) Msg72.casts else Msg72.uses).f(lang, f.name(lang), s.title(lang)), f.id)
        when (s) {
            Skill.SECOND_WIND -> heal(f, f, dice.roll(1, 10) + h.level)
            Skill.ACTION_SURGE -> {
                var tt: Fighter? = t
                repeat(2) { tt = tt?.let { again(f, it, true) }; tt?.let { weaponAttack(f, it) } }
            }
            Skill.FEINT -> weaponAttack(f, t!!, advantage = true, cover = !feintsPast(f, s))
            Skill.FIRE_BOLT -> spellAttack(f, t!!, dice(cantripDice(h), 10))
            Skill.MAGIC_MISSILE -> {
                val dmg = (1..3).sumOf { dice.roll(dice(1, 4, 1)) }
                hurt(t!!, dmg, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), dmg))
            }
            Skill.SCORCHING_RAY -> {
                var tt: Fighter? = t
                repeat(3) { tt = tt?.let { again(f, it, false) }; if (outcome == Outcome.ONGOING) tt?.let { spellAttack(f, it, dice(2, 6)) } }
            }
            Skill.FIREBALL, Skill.BURNING_HANDS -> {
                // 207: Burning Hands is the small fireball of level 1, 3d6 on a row
                val amount = dice.roll(if (s == Skill.BURNING_HANDS) dice(3, 6) else dice(8, 6))
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

    /**
     * What the rows do to an attack roll (72.10a.7): a figure in the back row is covered while a friend stands in front
     * of it (disadvantage); a ranged weapon shot from the front row into the front row is at point-blank range
     * (disadvantage). Spells that need no attack roll are not touched. [extra] is +1 for an advantage of the move itself.
     */
    private fun rowMode(f: Fighter, t: Fighter, weapon: Boolean, extra: Int = 0, cover: Boolean = true): Int {
        var dis = 0
        if (cover && t.place.row == Row.BACK && fighters.any { it.side == t.side && it.standing && it.place.row == Row.FRONT }) dis++
        if (weapon && f.ranged && f.place.row == Row.FRONT && t.place.row == Row.FRONT) dis++
        // 203: Abwehr is the SRD Dodge, attacks on the figure have disadvantage until its next turn
        if (t.waited) dis++
        // 208: a foe in the shadows can be struck, but at a disadvantage
        if (t.hidden) dis++
        return (extra - dis).coerceIn(-1, 1)
    }

    private fun bless(f: Fighter) = if (f.blessed) dice.roll(1, 4) else 0

    /** A spell attack against the armor class; a 20 doubles the dice (72.10a.1). */
    private fun spellAttack(f: Fighter, t: Fighter, dmg: DiceExpr) {
        val h = f.hero!!
        val mode = rowMode(f, t, weapon = false)
        val roll = dice.d20(mode)
        val bonus = h.spellAttack + bless(f)
        val crit = roll == 20
        val hit = roll != 1 && (crit || roll + bonus >= t.ac)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, hit, mode)
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
        // 203: in Abwehr (SRD Dodge) Dexterity saves have advantage
        val roll = dice.d20(if (t.waited) 1 else 0)
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

    private fun draw(f: Fighter) {
        require(f.spare != null) { "${f.id} has no other weapon" }
        f.drawn = !f.drawn
        say(Msg72.draws.f(lang, f.name(lang), f.weapon!!.name(lang)), f.id)
    }

    private fun drink(f: Fighter, item: String, t: Fighter) {
        require((potions[item] ?: 0) > 0 && t.standing && t.side == f.side) { "${f.id} cannot give $item to ${t.id}" }
        potions[item] = potions.getValue(item) - 1
        val def = Items[item]
        val n = minOf(t.maxHp - t.hp, dice.roll(def.heal!!)).coerceAtLeast(0)
        t.hp += n
        say(if (f === t) Msg72.drinks.f(lang, f.name(lang), def.name(lang), n) else Msg72.gives.f(lang, f.name(lang), t.name(lang), def.name(lang), n), f.id, t.id)
    }

    private fun weaponAttack(f: Fighter, t: Fighter, advantage: Boolean = false, cover: Boolean = true) {
        val h = f.hero!!
        // the rogue's step into the foe's back after a perfect ring (72.10a.9)
        val adv = advantage || f.opening
        f.opening = false
        val mode = rowMode(f, t, weapon = true, extra = if (adv) 1 else 0, cover = cover)
        val roll = dice.d20(mode)
        val crit = roll >= h.critFrom
        val bonus = h.attackBonus(f.weapon) + bless(f)
        val hit = roll != 1 && (crit || roll + bonus >= t.ac)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, hit, mode)
        if (!hit) {
            say(Msg72.misses.f(lang, f.name(lang), t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val base = h.weaponDamage(f.weapon)
        var dmg = dice.roll(if (crit) base.copy(count = base.count * 2) else base)
        // sneak attack: the first hit of the fight and every hit with advantage (SRD, as in the old fight)
        if (h.has(Skill.SNEAK_ATTACK) && (adv || !f.sneaked)) dmg += dice.roll(maxOf(1, h.level / 2), 6)
        f.sneaked = true
        dmg = maxOf(1, dmg)
        hurt(t, dmg, f.id, Msg72.hits.f(lang, f.name(lang), t.name(lang), dmg), info)
    }

    private fun foeTurn(foe: Fighter, react: (Fighter, Intent) -> Reaction) {
        val plan = intents.remove(foe.id)
        if (plan == null) {
            // its intent was broken: it gathers itself and announces anew
            announce(foe)
            sayAnnounce(foe)
            return
        }
        val (intent, aimed) = plan
        val m = foe.monster!!
        foe.hidden = false
        say(Msg72.foeUses.f(lang, foe.name(lang), intent.name(lang)), foe.id)
        if (intent.effect == Effect.SHADOW) {
            foe.hidden = true
            say(Msg130.gone.f(lang, foe.name(lang)), foe.id)
            announce(foe)
            sayAnnounce(foe)
            return
        }
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
        if (intent.effect == Effect.CIRCLE) {
            val t = reach.firstOrNull { it.id in aimed } ?: reach.firstOrNull()
            if (t != null) {
                say(Msg130.circleClosed.f(lang, foe.name(lang)), foe.id)
                for (w in fighters.filter { it.side == Side.FOES && it.standing && it.monster?.id == WOLF }) {
                    if (outcome != Outcome.ONGOING || !t.standing) break
                    strike(w, t, Intents.stab, Reaction.NONE)
                }
            }
        }
        if (intent.effect == Effect.BREAKTHROUGH || intent.effect == Effect.FLANK) {
            lineupAttack(foe, intent, aimed, react)
            if (outcome != Outcome.ONGOING) return
            announce(foe)
            sayAnnounce(foe)
            return
        }
        for (t in hit) {
            if (intent.effect == Effect.POUNCE && t.place != aimSpot[foe.id]) {
                say(Msg130.pounceEmpty.f(lang, foe.name(lang)), foe.id)
                continue
            }
            if (intent.effect == Effect.AIM && t.waited) {
                say(Msg130.ducks.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
                continue
            }
            // the ring comes with the blow, before anyone knows whether it lands
            val r = if (!intent.ring) Reaction.NONE else if (autopilot || t.auto) Reaction.GOOD else react(t, intent)
            strike(foe, t, intent, r)
            if (outcome != Outcome.ONGOING) return
        }
        announce(foe)
        sayAnnounce(foe)
    }

    /**
     * The intents against the lineup (72.10a.8). Breakthrough: is the target still behind a friend, that friend is shoved
     * back into its place and the target, now in front, takes the blow with the ring; did it step forward itself, the
     * breakthrough comes to an ordinary blow. Flank: hits the target past the front row, without cover, unless it has
     * changed its place since the announcement. A fallen target: the nearest one takes an ordinary blow.
     */
    private fun lineupAttack(foe: Fighter, intent: Intent, aimed: List<String>, react: (Fighter, Intent) -> Reaction) {
        val t = aimed.firstOrNull()?.let { byId(it) }?.takeIf { it.standing }
        if (t == null) {
            targets(foe).firstOrNull()?.let { strike(foe, it, Intents.stab, Reaction.NONE) }
            return
        }
        if (intent.effect == Effect.FLANK) {
            if (t.place != aimSpot[foe.id]) say(Msg72.flankEmpty.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
            else strike(foe, t, intent, Reaction.NONE, cover = false)
            return
        }
        if (t.place.row == Row.FRONT) {
            say(Msg72.braced.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
            strike(foe, t, Intents.stab, Reaction.NONE)
            return
        }
        val front = fighters.filter { it.side == t.side && it.standing && it.place.row == Row.FRONT }
        val shoved = front.firstOrNull { it.place.slot == t.place.slot } ?: front.firstOrNull()
        if (shoved != null) {
            val spot = shoved.place
            shoved.place = t.place
            t.place = spot
            say(Msg72.breaksThrough.f(lang, foe.name(lang), shoved.name(lang)), foe.id, shoved.id)
        }
        val r = if (autopilot || t.auto) Reaction.GOOD else react(t, intent)
        strike(foe, t, intent, r)
    }

    /** One blow of [foe] on [t] with [intent]: the roll, the ring's share, the special effect on a hit. */
    private fun strike(foe: Fighter, t: Fighter, intent: Intent, r: Reaction, cover: Boolean = true) {
        val m = foe.monster!!
        val mode = rowMode(foe, t, weapon = true, cover = cover)
        val roll = dice.d20(mode)
        val info = RollInfo(RollKind.ATTACK, roll, m.attackBonus, t.ac, !(roll == 1 || (roll != 20 && roll + m.attackBonus < t.ac)), mode)
        if (!info.success) {
            say(Msg72.misses.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, roll = info)
            return
        }
        var dmg = dice.roll(if (roll == 20) m.damage.copy(count = m.damage.count * 2) else m.damage)
        intent.extra?.let { dmg += dice.roll(it) }
        if (r != Reaction.NONE) say(Msg72.reacts(r).f(lang, t.name(lang)), t.id)
        dmg = (dmg * r.share).toInt()
        if (intent.id == "venom") say(Msg130.venomHits.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
        if (dmg > 0) hurt(t, dmg, foe.id, Msg72.hits.f(lang, foe.name(lang), t.name(lang), dmg), info)
        if (outcome != Outcome.ONGOING || !t.standing) return
        if (r == Reaction.PERFECT) perfectAnswer(t, foe)
        if (outcome != Outcome.ONGOING || !t.standing) return
        when (intent.effect) {
            Effect.POUNCE -> { t.held = true; say(Msg130.pounceHits.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id) }
            Effect.WEB -> if (r != Reaction.PERFECT) { t.held = true; say(Msg130.webHolds.f(lang, foe.name(lang), t.name(lang)), foe.id, t.id) }
            else -> {}
        }
    }

    /** What a perfect ring gives besides the blow caught, by class (72.10a.9); the wizard's shield waits (72.10a.2). */
    private fun perfectAnswer(t: Fighter, foe: Fighter) {
        when (t.hero?.cls) {
            CharClass.FIGHTER -> if (foe.standing) {
                say(Msg72.strikesBack.f(lang, t.name(lang), foe.name(lang)), t.id, foe.id)
                weaponAttack(t, foe)
            }
            CharClass.ROGUE -> {
                t.opening = true
                say(Msg72.stepsBehind.f(lang, t.name(lang), foe.name(lang)), t.id, foe.id)
            }
            CharClass.CLERIC -> {
                say(Msg72.prays.f(lang, t.name(lang)), t.id)
                heal(t, t, dice.roll(Moves.PRAYER_HEAL))
            }
            else -> {}
        }
    }

    /** The foe picks its next move and its target, and says it (72.11: the ring follows only on these). */
    private fun announce(foe: Fighter) {
        if (!foe.standing || outcome != Outcome.ONGOING) return
        val intent = pickIntent(foe)
        val reach = if (intent.effect == Effect.BREAKTHROUGH || intent.effect == Effect.FLANK) covered() else targets(foe)
        val aimed = if ((intent.kind != IntentKind.STRIKE && intent.effect != Effect.CIRCLE) || reach.isEmpty()) emptyList() else listOf(dice.pick(reach).id)
        foe.takenSinceAnnounce = 0
        intents[foe.id] = intent to aimed
        aimed.firstOrNull()?.let { aimSpot[foe.id] = byId(it).place }
    }

    /** The party's figures in the back row with a friend standing in front of them: what the lineup intents aim at (72.10a.8). */
    private fun covered(): List<Fighter> {
        val party = fighters.filter { it.side == Side.PARTY && it.standing }
        return if (party.none { it.place.row == Row.FRONT }) emptyList() else party.filter { it.place.row == Row.BACK }
    }

    private fun freeFoeSpot(back: Boolean = false): Spot? {
        val free = Spot.ALL.filter { s -> fighters.none { it.side == Side.FOES && it.place == s && it.standing } }
        return (if (back) free.firstOrNull { it.row == Row.BACK } else null) ?: free.firstOrNull()
    }

    /** Provisional: Grak strikes half the time or more, calls while goblins may still come, gathers below half his life. */
    private fun pickIntent(foe: Fighter): Intent {
        when (foe.monster?.id) {
            WOLF -> {
                val others = fighters.count { it.side == Side.FOES && it.standing && it.monster?.id == WOLF }
                val circling = intents.values.any { it.first.effect == Effect.CIRCLE }
                return dice.pick(buildList { add(Intents.pounce); add(Intents.pounce); if (others >= 2 && !circling) add(Intents.circle) })
            }
            SPIDER -> return dice.pick(Intents.spider)
            // 208: never twice into the shadows in a row
            SCOUT -> return if (foe.hidden) Intents.aim else dice.pick(listOf(Intents.aim, Intents.aim, Intents.shadow))
        }
        val lineup = covered().isNotEmpty()
        if (foe.monster?.id == CALLED) return dice.pick(buildList { add(Intents.stab); add(Intents.stab); if (lineup) add(Intents.flank) })
        if (foe.monster?.id != GRAK) return Intents.stab
        val can = buildList {
            add(Intents.heavy); add(Intents.heavy)
            if (lineup) add(Intents.breakthrough)
            if (called < CALL_MAX && freeFoeSpot() != null) add(Intents.call)
            if (foe.hp * 2 < foe.maxHp) add(Intents.gather)
        }
        return dice.pick(can)
    }

    private var called = 0

    /** The announcement line, with the intent's sign right after it (130.3). */
    private fun sayAnnounce(foe: Fighter) {
        val (intent, aimed) = intents[foe.id] ?: return
        val target = aimed.firstOrNull()?.let { byId(it).name(lang) } ?: ""
        val name = if (intent.effect in AT_TARGET) "${intent.name(lang)} ${Msg130.at.f(lang, target)}" else intent.name(lang)
        say(Msg72.announces.f(lang, foe.name(lang), name), foe.id)
        Msg130.sign(intent)?.let { say(it.f(lang, foe.name(lang), "", target), foe.id) }
    }

    /** A goblin answers the call: to the first free place, front first; it acts right after its caller. */
    private fun summon(by: Fighter) {
        // the first call brings a goblin, the next a scout who shoots from the back row (72.10a.7)
        val scout = called >= 1
        val spot = freeFoeSpot(back = scout) ?: return
        fighters.firstOrNull { it.side == Side.FOES && it.place == spot }?.let { gone ->
            if (order.indexOf(gone) < turn) turn--
            all.remove(gone); order.remove(gone)
        }
        val m = Monsters[if (scout) SCOUT else CALLED]
        called++
        val g = Fighter("gob$called", Side.FOES, spot, monster = m, hp = dice.roll(m.hp))
        g.initiative = dice.d20() + m.dexSave
        all += g
        order.add(order.indexOf(by) + 1, g)
        say(Msg72.answers.f(lang, m.name(lang)), g.id)
        announce(g)
    }

    private val AT_TARGET = setOf(Effect.POUNCE, Effect.AIM, Effect.BREAKTHROUGH, Effect.FLANK)

    private fun hurt(t: Fighter, dmg: Int, by: String, text: String, roll: RollInfo? = null) {
        t.hp = (t.hp - dmg).coerceAtLeast(0)
        say(text, by, t.id, dmg, roll)
        if (t.standing) {
            val plan = intents[t.id] ?: return
            t.takenSinceAnnounce += dmg
            if ((plan.first.breakable && t.takenSinceAnnounce * BREAK_SHARE >= t.maxHp) || (plan.first.breakOnAnyHit && dmg > 0)) {
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
            // a mercenary is knocked out, not killed (72.8)
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
        /** Goblin-Schütze (72.10a.7): ranged, answers the second call. */
        const val SCOUT = "goblin_archer"
        const val WOLF = "wolf"
        const val SPIDER = "giant_spider"
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

        /** The foes of the probe (130.3): each asks for a different answer. */
        enum class ProbeFoe { GRAK, WOLVES, SPIDER, SCOUT }

        /** The probe's lineup: hero in front, a Söldner of [cls] behind (ranged) or beside (melee), Grak opposite. */
        fun grakProbe(state: GameState, cls: CharClass, lang: Lang, dice: Dice = Dice()): Skirmish = probe(state, cls, lang, ProbeFoe.GRAK, dice)

        /** Hero and Söldner against the chosen foes (130.3); everything else as in [grakProbe]. */
        fun probe(state: GameState, cls: CharClass, lang: Lang, foe: ProbeFoe, dice: Dice = Dice()): Skirmish {
            val hero = atProbeLevel(state.hero)
            val merc = Hero.create(MERC_NAMES.first { !it.equals(hero.name, ignoreCase = true) }, Race.HUMAN, cls)
            merc.level = PROBE_LEVEL
            merc.restoreFully()
            val mercBack = merc.weapon?.def?.ranged == true || cls.caster
            // 72.10a.11: the hero's second weapon from the bag, the Söldner's from his class
            val foes = when (foe) {
                ProbeFoe.GRAK -> listOf(Fighter("grak", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters[GRAK], hp = dice.roll(Monsters[GRAK].hp)))
                ProbeFoe.WOLVES -> listOf(Spot(Row.FRONT, 0), Spot(Row.FRONT, 1), Spot(Row.BACK, 0)).mapIndexed { i, sp ->
                    Fighter("wolf${i + 1}", Side.FOES, sp, monster = Monsters[WOLF], hp = dice.roll(Monsters[WOLF].hp))
                }
                ProbeFoe.SPIDER -> listOf(
                    Fighter("wolf1", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters[WOLF], hp = dice.roll(Monsters[WOLF].hp)),
                    Fighter("spider", Side.FOES, Spot(Row.BACK, 0), monster = Monsters[SPIDER], hp = dice.roll(Monsters[SPIDER].hp)),
                )
                ProbeFoe.SCOUT -> listOf(
                    Fighter("gob1", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters[CALLED], hp = dice.roll(Monsters[CALLED].hp)),
                    Fighter("scout", Side.FOES, Spot(Row.BACK, 0), monster = Monsters[SCOUT], hp = dice.roll(Monsters[SCOUT].hp)),
                )
            }
            return Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = hero, hp = hero.hp, second = secondWeapon(hero, state.bag)),
                    Fighter("merc", Side.PARTY, if (mercBack) Spot(Row.BACK, 0) else Spot(Row.FRONT, 1), hero = merc, hp = merc.maxHp, second = secondWeapon(merc, emptyList())),
                ),
                foes,
                lang, dice, winded = state.winded,
            ).also { it.potions["potion"] = PROBE_POTIONS }
        }

        /**
         * The second weapon for [h] (72.10a.11): the best one in [bag] of the other kind than the main one (ranged for a
         * melee hand, melee for a bow) that the class can use; without one, the plainest the class knows. A wand or staff
         * counts as melee, as in the fight.
         */
        fun secondWeapon(h: Hero, bag: List<Gear>): Gear? {
            val ranged = h.weapon?.def?.ranged != true
            val fits = { d: GearBase -> d.isWeapon && d.ranged == ranged && Loot.proficient(h.cls, d) }
            bag.filter { fits(it.def) }.maxByOrNull { h.weaponDamage(it).average + h.attackBonus(it) }?.let { return it }
            val plain = if (ranged) listOf("light_crossbow", "shortbow") else listOf("shortsword", "dagger", "mace", "quarterstaff")
            return plain.firstOrNull { GearBases.exists(it) && fits(GearBases[it]) }?.let { Gear(-1L - plain.indexOf(it), it, Rarity.COMMON, 1) }
        }

        /** Healing potions in the probe's stock; the real bag stays untouched. */
        const val PROBE_POTIONS = 2
    }
}

/** Texts of MARS; placeholders for the build, final wording with Kreativ (41). */
private object Msg72 {
    val announces = T("{0} kündigt an: {1}.", "{0} announces: {1}.")
    val foeUses = T("{0}: {1}!", "{0}: {1}!")
    val hits = T("{0} trifft {1}: {2} Schaden.", "{0} hits {1}: {2} damage.")
    val misses = T("{0} verfehlt {1}.", "{0} misses {1}.")
    val waits = T("{0} geht in Abwehrhaltung.", "{0} takes a defensive stance.")
    val swaps = T("{0} tauscht den Platz.", "{0} changes places.")
    /** 72.10a.11: provisional wording, final with Homer (72.10a.11T). */
    val draws = T("{0} wechselt die Waffe: {1}.", "{0} switches weapons: {1}.")
    val falls = T("{0} fällt.", "{0} falls.")
    val heroFalls = T("{0} bricht zusammen.", "{0} collapses.")
    val knockedOut = T("{0} geht zu Boden, bewusstlos.", "{0} goes down, unconscious.")
    val gathers = T("{0} sammelt Kraft: +{1} TP.", "{0} gathers strength: +{1} HP.")
    val answers = T("Verstärkung: {0} eilt herbei.", "Reinforcement: {0} comes running.")
    val broken = T("{0} taumelt: {1} vereitelt.", "{0} staggers: {1} foiled.")
    val winded = T("{0} ist außer Atem: Initiative mit Nachteil.", "{0} is out of breath: initiative at a disadvantage.")
    val autopilotStops = T("Automatik hält an.", "Autopilot stops.")
    val breaksThrough = T("{0} bricht durch und stößt {1} nach hinten.", "{0} breaks through and shoves {1} back.")
    val braced = T("{1} stellt sich {0} vorn entgegen. Kein Durchkommen.", "{1} meets {0} at the front. No way through.")
    /** 72.10a.9: provisional wording, final with Homer (72.10a.9T). */
    val covers = T("{0} stellt sich vor die anderen und zieht jeden Schlag auf sich.", "{0} stands before the others and draws every blow.")
    val strikesBack = T("{0} fängt den Schlag ab und schlägt zurück.", "{0} catches the blow and strikes back.")
    val stepsBehind = T("{0} gleitet {1} in den Rücken: der nächste Schlag hat Vorteil.", "{0} slips behind {1}: the next blow has advantage.")
    val prays = T("{0} murmelt ein Gebet.", "{0} murmurs a prayer.")
    val flankEmpty = T("{0} schleicht um die Reihe, doch {1} ist nicht mehr dort.", "{0} creeps round the line, but {1} is gone.")
    val casts = T("{0} wirkt {1}.", "{0} casts {1}.")
    val uses = T("{0} setzt {1} ein.", "{0} uses {1}.")
    val blessed = T("{0} ist gesegnet.", "{0} is blessed.")
    val dodges = T("{0} entgeht dem Zauber.", "{0} escapes the spell.")
    val heals = T("{0} heilt {1}: +{2} TP.", "{0} heals {1}: +{2} HP.")
    val healsSelf = T("{0} heilt sich: +{1} TP.", "{0} heals: +{1} HP.")
    val drinks = T("{0} trinkt ({1}): +{2} TP.", "{0} drinks a {1}: +{2} HP.")
    val gives = T("{0} reicht {1} einen Trank ({2}): +{3} TP.", "{0} hands {1} a {2}: +{3} HP.")
    val noSp = T("Nicht genug Zauberpunkte.", "Not enough spell points.")
    val noTarget = T("Kein Ziel in Sicht.", "No target in sight.")
    val noBattle = T("In diesem Kampf schon genutzt.", "Already used in this fight.")
    val noRest = T("Erst nach einer Rast wieder.", "Not again until you rest.")
    private val good = T("{0} fängt den Schlag halb ab.", "{0} half catches the blow.")
    private val perfect = T("{0} weicht dem Schlag ganz aus.", "{0} evades the blow entirely.")
    fun reacts(r: Reaction) = if (r == Reaction.PERFECT) perfect else good
}

/** Texts of 130.3 (STORY-SPIEL.md `[130.3.…]`, Homer); the signs follow the announcement. */
private object Msg130 {
    val at = T("(auf {0})", "(at {0})")
    val loses = T("{0} verliert den Zug.", "{0} loses the turn.")
    val gone = T("Er ist verschwunden. Der nächste Pfeil kommt von irgendwo.", "He is gone. The next arrow comes from somewhere.")
    val circleClosed = T("Der Kreis schließt sich. Die Wölfe greifen gemeinsam an.", "The circle closes. The wolves strike together.")
    val pounceEmpty = T("Der Sprung geht ins Leere.", "The pounce lands on nothing.")
    val pounceHits = T("{0} reißt {1} zu Boden.", "{0} drags {1} to the ground.")
    val ducks = T("{1} duckt sich, der Pfeil schlägt ins Holz.", "{1} ducks; the arrow thuds into wood.")
    val venomHits = T("Ein Strahl Gift trifft {1}.", "A jet of venom strikes {1}.")
    val webHolds = T("{1} hängt im Netz fest und verliert den nächsten Zug.", "{1} is caught in the web and loses the next turn.")
    private val signs = mapOf(
        "heavy" to T("Er reißt die Keule hinter den Kopf.", "He hauls the club back behind his head."),
        "call" to T("Er stampft, brüllt in den Wald. Irgendwo antwortet Kreischen.", "He stamps and roars into the woods. Somewhere, shrieks answer."),
        "gather" to T("Er weicht zurück und atmet schwer, die Narben glühen.", "He falls back, breathing hard, his scars aglow."),
        "pounce" to T("Er duckt sich flach, die Augen auf {2}.", "He crouches low, eyes on {2}."),
        "circle" to T("Die Wölfe ziehen auseinander, einer bleibt zurück und knurrt.", "The wolves spread out; one hangs back, growling."),
        "venom" to T("Gift tropft von ihren Kieferklauen, sie zielt auf {2}.", "Venom drips from her fangs; she takes aim at {2}."),
        "web" to T("Sie hebt den Hinterleib, ein Faden spannt sich.", "She raises her abdomen; a thread pulls taut."),
        "aim" to T("Die Sehne knarrt. Die Pfeilspitze sucht {2}.", "The bowstring creaks. The arrowhead seeks {2}."),
        "shadow" to T("Er huscht zurück, zwischen die Bäume.", "He slips back between the trees."),
        // 72.10a.8 (STORY-SPIEL.md `[72.10a.8.bruch]`, `[72.10a.8.flanke]`)
        "breakthrough" to T("Er senkt die Schulter. Sein Blick geht an der vorderen Reihe vorbei, zu {2}.", "He lowers his shoulder. His eyes slide past the front row to {2}."),
        "flank" to T("Er löst sich aus der Reihe und schleicht seitlich auf {2} zu.", "He slips out of the line and creeps sideways toward {2}."),
    )
    fun sign(i: Intent): T? = signs[i.id]
}
