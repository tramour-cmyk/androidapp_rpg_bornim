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
 * on a perfect ring, steps into the foe's back and strikes at once with advantage (336); the cleric heals across the rows and
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
    /** 223: the disadvantage of a melee blow from the back row past a friend was in it. */
    val fromBack: Boolean = false,
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
    /** 268: a two-handed second weapon in hand puts the shield away, so it no longer counts (SRD: a shield needs a free hand). */
    val ac: Int get() = (hero?.let { h ->
        val shield = h.item(GearSlot.OFF_HAND)?.takeIf { drawn && second?.def?.twoHanded == true && it.def.kind == BaseKind.SHIELD }
        h.armorClass - (shield?.let { it.def.armor + it.plus } ?: 0)
    } ?: (monster!!.ac + acShift)) - (if (Status.SLOW in status) 2 else 0)
    /** 296.2: the statuses of the old fight with the turns they still last (poisoned, burning, bleeding, stunned …). */
    val status = LinkedHashMap<Status, Int>()
    /** 296.2: the die of the poison in it, the poisoner's own. */
    internal var poisonDie: DiceExpr = dice(1, 4)
    /** 296.2: turns after a stun in which it cannot be stunned again (no stun-lock, as in the old fight). */
    internal var stunGuard = 0
    /** 296.2: its statuses have acted at the start of this turn. */
    internal var ticked = false
    /** 296.2: a foe's attack and damage above its kind's, from its level over the area, elite or shimmer (the old fight's). */
    internal var attackShift = 0
    internal var acShift = 0
    internal var damageShift = 0
    /** 296.2: has landed a blow in this fight (a surprise attack stuns only with the first). */
    internal var hasHit = false
    /** The weapon in hand: the main one, or the second after drawing it (72.10a.11). */
    val weapon: Gear? get() = if (drawn && second != null) second else hero?.weapon
    /** The weapon not in hand, the one a draw takes up. */
    val spare: Gear? get() = if (drawn) hero?.weapon else second
    /** Holds the second weapon. */
    var drawn = false
        internal set
    /** The foes whose blows he drew onto himself by covering, until his next turn (72.10a.9): they come with the ring (Test 34.6). */
    var coverFrom: Set<String> = emptySet()
        internal set
    /**
     * How the figure is drawn: the hero, or after a draw the same hero with the second weapon in the hand (72.10a.11,
     * Chef 19.10. at test 34.7: "sehe ich nicht am Avatar"); a one-handed one leaves the shield on the arm. Only for the pictures.
     * 268 (Chef 20.10., Build 49: "Wechsel auf Armbrust, ist aber Zweihänder"): a two-handed one takes the other hand
     * too, so the torch or shield in it is put away, as when it is worn ([Hero.equip]).
     */
    val looks: Hero? get() {
        val h = hero ?: return null
        val w = second?.takeIf { drawn } ?: return h
        return drawnLook ?: Hero(h.name, h.race, h.cls, h.level, base = h.base.toMutableMap(), gear = h.gear.toMutableMap().also {
                it[GearSlot.MAIN_HAND] = w
                if (w.def.twoHanded) it.remove(GearSlot.OFF_HAND)
            },
            sex = h.sex, build = h.build, skin = h.skin, hair = h.hair).also { drawnLook = it }
    }
    private var drawnLook: Hero? = null
    val ranged: Boolean get() = weapon?.def?.ranged == true || monster?.id == Skirmish.SCOUT || monster?.id == Skirmish.SPIDER
    /** 223: holds a weapon with reach (spear, halberd), no disadvantage from the back row. */
    val reach: Boolean get() = weapon?.def?.reach == true
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
    /** Thrown down by a pounce, lying until the turn it loses (Rückläufer t53). */
    var prone = false
        internal set
    /** Waited since the foes last acted: ducks a scout's arrow (130.3). */
    internal var waited = false
    /** In the shadows until its next turn (the scout): attacks on it have disadvantage (208). */
    var hidden = false
        internal set
    /** Swapped places on this turn: half of it is spent, a second swap is not allowed (72.10a.8). */
    var moved = false
        internal set

    /** 240: numbered when more of its kind are in the fight ("Wolf 1"), the same in the log, the tags and the buttons. */
    var nr = 0
        internal set

    fun name(lang: Lang): String = hero?.name ?: (monster!!.name(lang) + if (nr > 0) " $nr" else "")

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
    /** The class's answer to a perfect ring (219.3): the screen shows it with the ring's result. */
    val answer: Boolean = false,
    /** 249: the damage came from a blow, a bite or a shot, not a spell: it draws blood, as in the old fight. */
    val wound: Boolean = false,
    /** 249: the spell or ability this message is part of, for its effect as in the old fight ([FxKind]); null for blows. */
    val spell: FxKind? = null,
    /** 256: what the message is beyond a blow or a spell, for its sound as in the old fight; null for the rest. */
    val cue: SkirmishCue? = null,
    /** 296.2: the statuses of each figure that has any, with the turns left, for their signs on the screen. */
    val status: Map<String, Map<Status, Int>> = emptyMap(),
)

/** 256: messages that sound as in the old fight, beyond blows and spells ([de.bornim.core.audio.MarsSound]). */
enum class SkirmishCue {
    /** 296.2: a status takes hold, or a stun costs the turn. */
    STATUS,
    /** A foe sets about its announced blow: its voice as it winds up. */
    FOE_STRIKES,
    /** A wolf closes the circle: the pack howls. */
    CIRCLE,
    HEAL, DRINK,
    /** A foe gathers strength and heals itself. */
    GATHER,
    VENOM, WEB,
    FOE_FALLS, HERO_FALLS, KNOCKED_OUT,
    /** 249 (Rückläufer t53 „reißt zu Boden wäre gut, wenn Held dann stürzt“): a pounce throws the target down; it gets up as it loses the turn. */
    POUNCED, RISES,
    /** Rückläufer t58 („wenn der Späher aus dem Schatten kommt, sieht man keinen Pfeil“): the target ducked the aimed arrow; it flies past. */
    DUCKED,
    /** 336 (Chef 23.10., 13:54 „er soll hinter Grak treten“): the rogue slips behind the foe; his stab comes from there. */
    BEHIND,
}

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
    /** 296.2: the party tries to get away, as in the old fight; costs the turn, never against a boss. */
    data object Flee : Order
}

class Skirmish(
    party: List<Fighter>,
    foes: List<Fighter>,
    var lang: Lang,
    private val dice: Dice = Dice(),
    /** The hero is out of breath: disadvantage on initiative (86.3). */
    private val winded: Boolean = false,
    /** 296.2: who strikes first, as on the map: ambushed, the foes act before the party; from behind, the party first and the foes lose their first turn. */
    private val opening: Opening = Opening.NORMAL,
) {
    private val all = java.util.concurrent.CopyOnWriteArrayList(party + foes)
    /** 279: which wording each line had last; its own chance, so the dice fall as before. */
    private val lastWording = HashMap<Lines, Int>()
    private val wordings = kotlin.random.Random(279)
    /** 279: a wording of [l] at random, never the one it had last time. */
    private fun pick(l: Lines): T {
        val last = lastWording[l]
        val i = if (l.all.size < 2) 0 else (0 until l.all.size).filter { it != last }.random(wordings)
        lastWording[l] = i
        return l.all[i]
    }
    /** 279: a wolf's own lines in place of the general ones. */
    private fun wolf(f: Fighter, own: Lines, general: Lines) = pick(if (f.monster?.id == "wolf") own else general)
    val fighters: List<Fighter> get() = all

    /** 240: the highest number given to a kind, so a fallen one's number is not given again. */
    private val numbered = mutableMapOf<String, Int>()

    init {
        foes.groupBy { it.monster?.id }.values.filter { it.size > 1 }.forEach { kin -> kin.forEachIndexed { i, f -> f.nr = i + 1 }; kin[0].monster?.let { numbered[it.id] = kin.size } }
    }
    /**
     * 259 (Chef 20.10.): how many levels the hero stands above the strongest foe's challenge rating when the fight is
     * light (at least [EASY_GAP], never against a boss), else null; judged once, on the foes at the start.
     */
    val easyGap: Double? = party.first().hero?.level?.let { lv ->
        if (foes.isEmpty() || foes.any { it.boss }) null
        else (lv - foes.maxOf { crValue(it.monster!!.cr) }).takeIf { it >= EASY_GAP }
    }
    val easy: Boolean get() = easyGap != null
    /** 259 (5): the share of its damage the party takes in a quick fight: 4 to 6 levels above all, 7 to 9 half, from 10 none. */
    val quickHarm: Double get() = easyGap?.let { if (it < 7) 1.0 else if (it < 10) 0.5 else 0.0 } ?: 1.0
    /** A quick fight is being played ([quick]): the party takes only [quickHarm] of the damage. */
    private var quickRun = false
    /** The fight has begun ([start] or [quick]). */
    var started = false
        private set

    /** Knocked-out Söldner in this fight (72r). */
    var knockouts = 0
        private set
    var outcome = Outcome.ONGOING
        private set
    /** The foes' announced next moves, by foe id. */
    val intents = LinkedHashMap<String, Pair<Intent, List<String>>>()
    /** 296.2: the lines the fight opens with (how the foe appeared), before the intents; empty in the probe. */
    var intro: List<String> = emptyList()
    /** 296.2: the foes caught from behind, each losing its first turn. */
    private val surprised = mutableSetOf<String>()

    @Volatile var autopilot = false
        private set
    private val order = mutableListOf<Fighter>()
    /** Index into [order] of the figure whose turn it is. */
    private var turn = 0
    private fun nextTurn() { order[turn].moved = false; order[turn].ticked = false; turn = (turn + 1) % order.size }
    private val log = mutableListOf<SkirmishEvent>()
    /** Hears every message as it is said, before [act] returns; the screen plays them while a ring waits for a tap. */
    var listener: ((SkirmishEvent) -> Unit)? = null
    /** The party's shared stock of potions, item id to count (72.10a.12). */
    val potions = linkedMapOf<String, Int>()
    /** Where the target of a pounce stood when the wolf announced it (130.3). */
    private val aimSpot = mutableMapOf<String, Spot>()

    /** 301: the foes whose announced blow had to be aimed anew, at one in front ([reaim]); they strike with disadvantage. */
    val retargeted = mutableSetOf<String>()

    /**
     * 301 (Chef 22.10., 12:37, Vorgangsarchiv 301): a blow announced on one figure that has stepped back out of the
     * foe's reach goes to one it can reach, and the mark moves with it; adjusting its aim gives the foe disadvantage.
     * Not for the attacks on the lineup (breakthrough, flank, circle) nor the pounce, which aims at a place.
     */
    private fun reaim(): List<Pair<Fighter, Fighter>> {
        val out = mutableListOf<Pair<Fighter, Fighter>>()
        for ((id, plan) in intents.toList()) {
            val (intent, aimed) = plan
            if (intent.kind != IntentKind.STRIKE || intent.effect in NO_REAIM) continue
            val foe = fighters.firstOrNull { it.id == id }?.takeIf { it.standing } ?: continue
            val reach = targets(foe)
            if (reach.isEmpty() || reach.any { it.id in aimed }) continue
            if (aimed.none { a -> fighters.any { it.id == a && it.standing } }) continue
            val now = reach.first()
            intents[id] = intent to listOf(now.id)
            aimSpot[id] = now.place
            retargeted += id
            out += foe to now
        }
        return out
    }

    init {
        require(fighters.map { it.id }.toSet().size == fighters.size) { "ids must be unique" }
        require(fighters.groupBy { it.side to it.place }.all { it.value.size == 1 }) { "one figure per place" }
        for (f in fighters) {
            val dex = f.hero?.mod(Ability.DEX) ?: f.monster!!.dexSave
            f.initiative = dice.d20(if (winded && f === party.first()) -1 else 0) + dex
        }
        val byInitiative = fighters.sortedWith(compareByDescending<Fighter> { it.initiative }.thenBy { it.side })
        order += when (opening) {
            Opening.AMBUSHED -> byInitiative.sortedBy { it.side != Side.FOES }
            Opening.HERO_FIRST -> byInitiative.sortedBy { it.side != Side.PARTY }
            Opening.NORMAL -> byInitiative
        }
        if (opening == Opening.HERO_FIRST) surprised += foes.map { it.id }
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

    /**
     * Why the autopilot cannot run now, or null (72p.1). [hp] is the hero's life points to judge by: the screen passes
     * the ones it shows, since the fight runs ahead of its lines (241.2, Chef 17:56: bar near half, refused as below a third).
     */
    fun autopilotBlocked(hp: Int = fighters.first { it.side == Side.PARTY }.hp): T? {
        val lead = fighters.first { it.side == Side.PARTY }
        return when {
            fighters.any { it.side == Side.FOES && it.boss } -> T("Nicht gegen Bosse.", "Not against bosses.")
            hp * 3 < lead.maxHp -> T("Unter einem Drittel der Lebenspunkte.", "Below a third of life points.")
            // 259 (1): in a light fight a strong intent does not stop it (lifts 72p.1 there)
            !easy && intents.values.any { it.first.strong } -> T("Starke Absicht angekündigt.", "Strong intent announced.")
            else -> null
        }
    }

    /** Whether [f] may still swap places on this turn (72.10a.8: once, for half the turn). */
    fun canSwap(f: Fighter): Boolean = !f.moved

    /** Whether [f] may take up its other weapon now (72.10a.11): once per turn, in the half a swap would take. */
    fun canDraw(f: Fighter): Boolean = !f.moved && f.spare != null

    /** 241.1 (Chef 13:50): the autopilot plays the hero only; a Söldner the player steers waits for its order. */
    private fun piloted(f: Fighter) = autopilot && f === fighters.first { it.side == Side.PARTY }

    /** 241.1: whether an automatic party turn is up (the hero's autopilot or a Söldner on automatic), so the screen plays on. */
    val pilotNext: Boolean get() = outcome == Outcome.ONGOING && current.standing && (piloted(current) || (current.side == Side.PARTY && current.auto))

    /** Switches the autopilot; the true life points stop it again before the hero's turn once the lines have shown them. */
    fun setAutopilot(on: Boolean, hp: Int = fighters.first { it.side == Side.PARTY }.hp): Boolean {
        autopilot = on && autopilotBlocked(hp) == null
        // 296.2: handing the fight to the autopilot is the player's choice; else the 231 guard kept the hero alive for good
        if (autopilot) chosen = true
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
        chosen = true
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

    /** 272 (test mode only): ends the fight at once: [win] fells every foe still standing, otherwise the hero falls. */
    fun testEnd(win: Boolean): List<SkirmishEvent> {
        check(outcome == Outcome.ONGOING) { "Skirmish is over" }
        chosen = true
        if (win) {
            for (f in fighters.filter { it.side == Side.FOES && it.standing }) {
                f.hp = 0
                intents.remove(f.id)
                say(wolf(f, Msg279.wolfFalls, Msg72.falls).f(lang, f.name(lang)), target = f.id, cue = SkirmishCue.FOE_FALLS)
            }
            outcome = Outcome.WON
        } else {
            val h = fighters.first()
            h.hp = 0
            say(pick(Msg72.heroFalls).f(lang, h.name(lang)), target = h.id, cue = SkirmishCue.HERO_FALLS)
            outcome = Outcome.LOST
        }
        return log.toList().also { log.clear() }
    }

    /** Starts the fight: foes that are quicker than the whole party act first. */
    fun start(react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }): List<SkirmishEvent> {
        opening()
        skipToChoice(react)
        return log.toList().also { log.clear() }
    }

    private fun opening() {
        started = true
        intro.forEach { say(it) }
        if (winded) say(Msg72.winded.f(lang, fighters.first { it.side == Side.PARTY }.name(lang)))
        for (foe in intents.keys.toList()) sayAnnounce(byId(foe))
    }

    /** What a quick fight brought: the life points each of the party lost, and whether it stopped below a third. */
    data class QuickResult(val lost: Map<String, Int>, val stopped: Boolean, val events: List<SkirmishEvent>)

    /**
     * 259 (2, 3): plays a light fight through in one go, at its start or on a party turn: the same rolls, the autopilot
     * for the hero and every Söldner, rings met with "gut"; the party takes only [quickHarm] of the damage (5). Stops when
     * the hero falls below a third of the life points; the player then takes over, the Söldner as they were set.
     */
    fun quick(): QuickResult {
        check(easy && outcome == Outcome.ONGOING) { "no quick fight" }
        val party = fighters.filter { it.side == Side.PARTY }
        val before = party.associate { it.id to it.hp }
        val wasAuto = party.associate { it.id to it.auto }
        val events = mutableListOf<SkirmishEvent>()
        quickRun = true
        try {
            if (!started) opening()
            chosen = true
            autopilot = autopilotBlocked() == null
            party.drop(1).forEach { it.auto = true }
            while (outcome == Outcome.ONGOING && autopilot) {
                skipToChoice { _, _ -> Reaction.GOOD }
                events += log; log.clear()
            }
        } finally {
            quickRun = false
            party.forEach { it.auto = wasAuto.getValue(it.id) }
        }
        events += log; log.clear()
        val stopped = outcome == Outcome.ONGOING
        autopilot = false
        return QuickResult(party.associate { it.id to before.getValue(it.id) - it.hp }, stopped, events)
    }

    private fun advance(react: (Fighter, Intent) -> Reaction) {
        nextTurn()
        skipToChoice(react)
    }

    private fun skipToChoice(react: (Fighter, Intent) -> Reaction) {
        // 241: an automatic party turn (autopilot or Söldner) is played only once the screen has shown all before it:
        // it hands back first, so a switch flipped while the lines play counts at once (241.2, Rückläufer t46)
        while (outcome == Outcome.ONGOING) {
            val f = current
            when {
                !f.standing -> nextTurn()
                // 296.2: poison, burning and bleeding hurt at the start of the turn, a stun costs it
                !f.ticked && (f.status.isNotEmpty() || f.stunGuard > 0) -> { f.ticked = true; if (tick(f)) nextTurn() }
                f.held -> { f.held = false; say(pick(if (f.prone) Msg279.rises else Msg130.loses).f(lang, f.name(lang)), f.id, cue = if (f.prone) SkirmishCue.RISES else null); f.prone = false; nextTurn() }
                f.side == Side.FOES && surprised.remove(f.id) -> { say(Msg296.stillSurprised.f(lang, f.name(lang)), f.id); nextTurn() }
                f.side == Side.FOES -> { foeTurn(f, react); nextTurn() }
                autopilot && autopilotBlocked() != null -> {
                    autopilot = false
                    say(Msg72.autopilotStops(lang))
                    return
                }
                (piloted(f) || f.auto) && log.isNotEmpty() -> return
                piloted(f) || f.auto -> {
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
        f.coverFrom = emptySet()
        when (o) {
            Order.Wait -> say(pick(Msg72.waits).f(lang, f.name(lang)), f.id)
            Order.Guard -> {
                val drawn = guardable(f)
                require(drawn.isNotEmpty()) { "${f.id} cannot cover" }
                f.coverFrom = drawn.toSet()
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
                val aimedAnew = reaim()
                say(pick(Msg72.swaps).f(lang, f.name(lang)), f.id)
                // 301: the foe has to aim anew, in words of its own (Homer 301.1)
                for ((foe, t) in aimedAnew) say(pick(Msg301.reaims).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id)
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
            Order.Flee -> flee(f)
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
        casting = fxOf(s)
        try { cast(f, h, s, t) } finally { casting = null }
    }

    /** 249: the spell being cast, set on each of its messages ([SkirmishEvent.spell]). */
    private var casting: FxKind? = null

    private fun fxOf(s: Skill): FxKind? = when (s) {
        Skill.FIRE_BOLT -> FxKind.FIRE_BOLT
        Skill.MAGIC_MISSILE -> FxKind.MISSILES
        Skill.SCORCHING_RAY -> FxKind.RAYS
        Skill.FIREBALL, Skill.BURNING_HANDS -> FxKind.FIREBALL
        Skill.SACRED_FLAME -> FxKind.SACRED_FLAME
        Skill.CURE_WOUNDS, Skill.SECOND_WIND -> FxKind.HEAL
        Skill.BLESS -> FxKind.BLESS
        else -> null
    }

    private fun cast(f: Fighter, h: Hero, s: Skill, t: Fighter?) {
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
                hurt(t!!, dmg, f.id, wolf(f, Msg279.wolfHits, Msg72.hits).f(lang, f.name(lang), t.name(lang), dmg))
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
                say(Msg72.blessed.f(lang, f.name(lang)), f.id, f.id)
            }
            else -> {}
        }
    }

    /**
     * What the rows do to an attack roll (72.10a.7): a figure in the back row is covered while a friend stands in front
     * of it (disadvantage); a ranged weapon shot from the front row into the front row is at point-blank range
     * (disadvantage); the mirror (223): a melee blow from the back row past a friend in front (disadvantage), unless the
     * weapon has reach or the move slips past ([cover] false, the feint). Spells that need no attack roll are not
     * touched. [extra] is +1 for an advantage of the move itself.
     */
    private fun rowMode(f: Fighter, t: Fighter, weapon: Boolean, extra: Int = 0, cover: Boolean = true): Int {
        var dis = 0
        if (cover && t.place.row == Row.BACK && fighters.any { it.side == t.side && it.standing && it.place.row == Row.FRONT }) dis++
        if (weapon && f.ranged && f.place.row == Row.FRONT && t.place.row == Row.FRONT) dis++
        if (weapon && cover && fromBack(f)) dis++
        // 203: Abwehr is the SRD Dodge, attacks on the figure have disadvantage until its next turn
        if (t.waited) dis++
        // 208: a foe in the shadows can be struck, but at a disadvantage
        if (t.hidden) dis++
        // 296.2: blinded or drunk, attacks at a disadvantage (as in the old fight)
        if (Status.BLIND in f.status || Status.DRUNK in f.status) dis++
        return (extra - dis).coerceIn(-1, 1)
    }

    /** 223: [f] strikes in melee from the back row past a friend in front, without reach. */
    fun fromBack(f: Fighter) = !f.ranged && !f.reach && covers(f)

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
            say(wolf(f, Msg279.wolfMisses, Msg72.misses).f(lang, f.name(lang), t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val n = maxOf(1, dice.roll(if (crit) dmg.copy(count = dmg.count * 2) else dmg))
        hurt(t, n, f.id, wolf(f, Msg279.wolfHits, Msg72.hits).f(lang, f.name(lang), t.name(lang), n), info)
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
        hurt(t, n, f.id, wolf(f, Msg279.wolfHits, Msg72.hits).f(lang, f.name(lang), t.name(lang), n), info)
    }

    private fun heal(f: Fighter, t: Fighter, amount: Int) {
        val n = minOf(t.maxHp - t.hp, amount).coerceAtLeast(0)
        t.hp += n
        say(if (f === t) Msg72.healsSelf.f(lang, f.name(lang), n) else Msg72.heals.f(lang, f.name(lang), t.name(lang), n), f.id, t.id, cue = SkirmishCue.HEAL)
    }

    private fun draw(f: Fighter) {
        require(f.spare != null) { "${f.id} has no other weapon" }
        f.drawn = !f.drawn
        say(Msg72.draws.f(lang, f.name(lang), f.weapon!!.name(lang)), f.id)
    }

    /** 296.2: the party can try to get away: a hero of the party, no boss among the foes (as in the old fight). */
    fun canFlee(f: Fighter): Boolean = f.side == Side.PARTY && f.hero != null && fighters.none { it.side == Side.FOES && it.standing && it.boss }

    /**
     * 296.2: the roll of the old fight ([Battle] flee): d20 + Dexterity (+2 for an elf) against 10 + the quickest
     * standing foe's Dexterity save; cunning action always gets away. On success the fight ends as [Outcome.FLED].
     */
    private fun flee(f: Fighter) {
        require(canFlee(f)) { "${f.id} cannot flee" }
        val h = f.hero!!
        val elf = if (h.race == Race.ELF) 2 else 0
        val dc = 10 + fighters.filter { it.side == Side.FOES && it.standing }.maxOf { it.monster!!.dexSave }
        if (h.has(Skill.CUNNING_ACTION) || dice.d20() + h.mod(Ability.DEX) + elf >= dc) {
            say(Msg296.fled.f(lang, f.name(lang)), f.id)
            outcome = Outcome.FLED
        } else say(Msg296.cantFlee(lang), f.id)
    }

    private fun drink(f: Fighter, item: String, t: Fighter) {
        require((potions[item] ?: 0) > 0 && t.standing && t.side == f.side) { "${f.id} cannot give $item to ${t.id}" }
        potions[item] = potions.getValue(item) - 1
        val def = Items[item]
        val n = minOf(t.maxHp - t.hp, dice.roll(def.heal!!)).coerceAtLeast(0)
        t.hp += n
        say(if (f === t) Msg72.drinks.f(lang, f.name(lang), def.name(lang), n) else Msg72.gives.f(lang, f.name(lang), t.name(lang), def.name(lang), n), f.id, t.id, cue = SkirmishCue.DRINK)
    }

    private fun weaponAttack(f: Fighter, t: Fighter, advantage: Boolean = false, cover: Boolean = true) {
        val h = f.hero!!
        val mode = rowMode(f, t, weapon = true, extra = if (advantage) 1 else 0, cover = cover)
        val roll = dice.d20(mode)
        val crit = roll >= h.critFrom
        val bonus = h.attackBonus(f.weapon) + bless(f) - penalty(f)
        val hit = roll != 1 && (crit || roll + bonus >= t.ac)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, hit, mode, fromBack = cover && fromBack(f))
        if (!hit) {
            say(wolf(f, Msg279.wolfMisses, Msg72.misses).f(lang, f.name(lang), t.name(lang)), f.id, t.id, roll = info)
            return
        }
        val base = h.weaponDamage(f.weapon)
        var dmg = dice.roll(if (crit) base.copy(count = base.count * 2) else base)
        // sneak attack: the first hit of the fight and every hit with advantage (SRD, as in the old fight)
        if (h.has(Skill.SNEAK_ATTACK) && (advantage || !f.sneaked)) dmg += dice.roll(maxOf(1, h.level / 2), 6)
        f.sneaked = true
        dmg = maxOf(1, dmg - weakness(f))
        hurt(t, dmg, f.id, wolf(f, Msg279.wolfHits, Msg72.hits).f(lang, f.name(lang), t.name(lang), dmg), info, wound = true)
        if (outcome != Outcome.ONGOING || !t.standing) return
        // 296.2: critical hits wound as in the old fight, blades make bleed, blunt weapons can stun; and the weapon's own
        val type = f.weapon?.def?.damageType ?: DamageType.BLUDGEONING
        if (crit && type == DamageType.SLASHING) inflict(t, Status.BLEED, 3)
        if (crit && type == DamageType.BLUDGEONING && dice.chance(0.5)) inflict(t, Status.STUN, 1)
        for ((affix, st) in listOf(Affix.POISON_HIT to Status.POISON, Affix.BLEED_HIT to Status.BLEED, Affix.STUN_HIT to Status.STUN)) {
            val chance = h.bonus(affix)
            if (chance > 0 && outcome == Outcome.ONGOING && t.standing && st !in t.status && dice.chance(chance / 100.0)) inflict(t, st, if (st == Status.STUN) 1 else 3)
        }
    }

    /** 296.2: slowed or weakened, −2 on the attack each (the old fight). */
    private fun penalty(f: Fighter) = (if (Status.SLOW in f.status) 2 else 0) + (if (Status.WEAK in f.status) 2 else 0)
    private fun weakness(f: Fighter) = if (Status.WEAK in f.status) 2 else 0

    /**
     * 296.2: a status on [t] for [turns] of its turns, as in the old fight: a hero may resist with a save, his tenacity or
     * a dwarf's toughness against poison; a foe immune to it takes none, a boss shakes off a stun half the time.
     */
    private fun inflict(t: Fighter, st: Status, turns: Int, save: Pair<Ability, Int>? = null, die: DiceExpr? = null): Boolean {
        if (outcome != Outcome.ONGOING || !t.standing) return false
        if (st == Status.STUN && t.stunGuard > 0) return false
        val who = t.name(lang)
        val h = t.hero
        if (h != null) {
            if (save != null && dice.d20() + h.mod(save.first) + (if (save.first in Battle.savingThrows.getValue(h.cls)) h.proficiency else 0) >= save.second) {
                say(StatusLines.shrugs.f(lang, who), target = t.id)
                return false
            }
            if (h.tenacity > 0 && dice.chance(h.tenacity / 100.0)) {
                say(StatusLines.steadfast.f(lang, who), target = t.id)
                return false
            }
            if (st == Status.POISON && h.race == Race.DWARF && dice.chance(0.5)) {
                say(StatusLines.dwarfPoison.f(lang, who), target = t.id)
                return false
            }
        } else {
            val m = t.monster!!
            if (Status.immune(m, st)) return false
            if (m.boss && st == Status.STUN && dice.chance(0.5)) {
                say(StatusLines.shakesOff.f(lang, who), target = t.id)
                return false
            }
        }
        t.status[st] = maxOf(t.status[st] ?: 0, turns)
        if (st == Status.POISON && die != null) t.poisonDie = die
        if (st == Status.STUN) t.stunGuard = 3
        say(StatusLines.gained.getValue(st).f(lang, who), target = t.id, cue = SkirmishCue.STATUS)
        return true
    }

    /**
     * 296.2: the start of [f]'s turn, as in the old fight: poison, burning and bleeding hurt, then every status counts
     * down a turn. True when the turn is lost (stunned).
     */
    private fun tick(f: Fighter): Boolean {
        if (f.stunGuard > 0) f.stunGuard--
        val who = f.name(lang)
        // the hero's level grows the harm of what he put on the foes
        val scale = if (f.side == Side.FOES) (fighters.first().hero?.level ?: 0) / 3 else 0
        // counted down first, so the lines that follow show the turns now left
        val hurting = listOf(Status.POISON, Status.BURN, Status.BLEED).filter { it in f.status }
        val stunned = Status.STUN in f.status
        val ended = mutableListOf<Status>()
        for (st in f.status.keys.toList()) {
            val turns = f.status.getValue(st)
            if (turns >= Status.LASTING) continue
            if (turns <= 1) { f.status.remove(st); ended += st } else f.status[st] = turns - 1
        }
        for (st in hurting) {
            if (outcome != Outcome.ONGOING || !f.standing) break
            if (f.monster != null && Status.immune(f.monster, st)) continue
            var dmg = dice.roll(when (st) { Status.POISON -> f.poisonDie; Status.BURN -> dice(1, 6); else -> dice(1, 4) }) + scale
            if (st == Status.POISON && f.hero?.race == Race.DWARF) dmg = (dmg + 1) / 2
            dmg = maxOf(1, dmg)
            hurt(f, dmg, null, StatusLines.hurts.getValue(st).f(lang, who) + " " + Msg296.damage.f(lang, dmg))
        }
        if (outcome != Outcome.ONGOING || !f.standing) return false
        if (stunned) say(StatusLines.stunned.f(lang, who), f.id, cue = SkirmishCue.STATUS)
        for (st in ended) if (st != Status.STUN) say(StatusLines.ends.f(lang, who, st.title(lang).lowercase()), target = f.id)
        return stunned
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
        say(Msg72.foeUses.f(lang, foe.name(lang), intent.name(lang)), foe.id, cue = when {
            intent.effect == Effect.CIRCLE -> SkirmishCue.CIRCLE
            intent.kind == IntentKind.STRIKE -> SkirmishCue.FOE_STRIKES
            else -> null
        })
        if (intent.effect == Effect.SHADOW) {
            foe.hidden = true
            say(pick(Msg130.gone).f(lang, foe.name(lang)), foe.id)
            announce(foe)
            sayAnnounce(foe)
            return
        }
        when (intent.kind) {
            IntentKind.CALL -> summon(foe)
            // 242: the circle is the pack's bite ([210T.circle]), the wolf that calls it does not gather strength
            IntentKind.GATHER -> if (intent.effect != Effect.CIRCLE) {
                val heal = minOf(foe.maxHp - foe.hp, dice.roll(GATHER_HEAL))
                foe.hp += heal
                say(Msg72.gathers.f(lang, foe.name(lang), heal), foe.id, foe.id, cue = SkirmishCue.GATHER)
            }
            IntentKind.STRIKE -> {}
        }
        // the target may have moved or fallen since the announcement: then the nearest one takes it
        val reach = targets(foe)
        val hit = if (intent.kind != IntentKind.STRIKE) emptyList() else listOfNotNull(reach.firstOrNull { it.id in aimed } ?: reach.firstOrNull())
        if (intent.effect == Effect.CIRCLE) {
            val t = reach.firstOrNull { it.id in aimed } ?: reach.firstOrNull()
            if (t != null) {
                say(pick(Msg130.circleClosed).f(lang, foe.name(lang)), foe.id)
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
                say(pick(Msg130.pounceEmpty).f(lang, foe.name(lang)), foe.id)
                continue
            }
            if (intent.effect == Effect.AIM && t.waited) {
                say(pick(Msg130.ducks).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, cue = SkirmishCue.DUCKED)
                continue
            }
            // the ring comes with the blow, before anyone knows whether it lands
            val r = if (!intent.ring && foe.id !in t.coverFrom) Reaction.NONE else if (piloted(t) || t.auto) Reaction.GOOD else react(t, intent)
            strike(foe, t, intent, r, retarget = foe.id in retargeted)
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
        // 34.6 (Chef 19.10.: "Decken konnte gewählt werden, aber Ring kam nicht"): the fighter covering takes the blow
        // drawn onto him as it was meant, with the ring, so a perfect ring strikes back
        if (foe.id in t.coverFrom) {
            val r = if (piloted(t) || t.auto) Reaction.GOOD else react(t, intent)
            strike(foe, t, intent, r, cover = false)
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
        val r = if (piloted(t) || t.auto) Reaction.GOOD else react(t, intent)
        strike(foe, t, intent, r)
    }

    /** One blow of [foe] on [t] with [intent]: the roll, the ring's share, the special effect on a hit. */
    private fun strike(foe: Fighter, t: Fighter, intent: Intent, r: Reaction, cover: Boolean = true, retarget: Boolean = false) {
        val m = foe.monster!!
        val mode = rowMode(foe, t, weapon = true, extra = if (retarget) -1 else 0, cover = cover)
        val roll = dice.d20(mode)
        val bonus = m.attackBonus + foe.attackShift - penalty(foe)
        val info = RollInfo(RollKind.ATTACK, roll, bonus, t.ac, !(roll == 1 || (roll != 20 && roll + bonus < t.ac)), mode, fromBack = cover && fromBack(foe))
        // 285: the roll as from the back row, then the leap lands the wolf in front, whether it bites or not
        if (intent.effect == Effect.POUNCE) leapForward(foe)
        // 219.4: a perfect ring counts every time, even when the roll would have missed: one line, and the class answers
        if (r == Reaction.PERFECT) {
            perfectAnswer(t, foe, info)
            return
        }
        if (!info.success) {
            say(wolf(foe, Msg279.wolfMisses, Msg72.misses).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, roll = info)
            return
        }
        var dmg = dice.roll(if (roll == 20) m.damage.copy(count = m.damage.count * 2) else m.damage) + foe.damageShift
        intent.extra?.let { dmg += dice.roll(it) }
        if (r != Reaction.NONE) say(pick(Msg72.reacts(r)).f(lang, t.name(lang)), t.id)
        dmg = (dmg * r.share).toInt()
        if (dmg > 0) dmg = maxOf(1, dmg - weakness(foe))
        if (intent.id == "venom") say(pick(Msg130.venomHits).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, cue = SkirmishCue.VENOM)
        if (dmg > 0) hurt(t, dmg, foe.id, wolf(foe, Msg279.wolfHits, Msg72.hits).f(lang, foe.name(lang), t.name(lang), dmg), info, wound = true)
        if (outcome != Outcome.ONGOING || !t.standing) return
        foeWounds(foe, t, roll == 20)
        if (outcome != Outcome.ONGOING || !t.standing) return
        when (intent.effect) {
            Effect.POUNCE -> { t.held = true; t.prone = true; say(pick(Msg130.pounceHits).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, cue = SkirmishCue.POUNCED) }
            Effect.WEB -> { t.held = true; say(pick(Msg130.webHolds).f(lang, foe.name(lang), t.name(lang)), foe.id, t.id, cue = SkirmishCue.WEB) }
            else -> {}
        }
    }

    /**
     * What a perfect ring gives besides the blow caught, by class (72.10a.9); the wizard answers with a fire bolt at the
     * attacker (219.3, provisional like the others). The line is marked as the answer, so the screen shows it (219.3).
     * 219.4: exactly one line for the dodge; the class line says it, else "{0} weicht dem Schlag ganz aus" ([219.4T.aus]).
     */
    private fun perfectAnswer(t: Fighter, foe: Fighter, info: RollInfo) {
        val h = t.hero
        val answers = when (h?.cls) {
            CharClass.FIGHTER, CharClass.ROGUE, CharClass.CLERIC -> true
            CharClass.WIZARD -> Skill.FIRE_BOLT in moves(t)
            else -> false
        }
        if (h == null || !answers) {
            say(pick(Msg72.evades).f(lang, t.name(lang)), foe.id, t.id, roll = info)
            return
        }
        when (h.cls) {
            CharClass.FIGHTER -> {
                say(Msg72.strikesBack.f(lang, t.name(lang), foe.name(lang)), t.id, foe.id, answer = true)
                weaponAttack(t, foe)
            }
            // 336 (Chef 23.10., 07:57 „ich schleiche mich hinter ihn, aber ich mache keinen Angriff“): the step into the
            // foe's back ends in a stab there and then, with advantage and without cover, so the sneak attack comes with it
            CharClass.ROGUE -> {
                say(Msg72.stepsBehind.f(lang, t.name(lang), foe.name(lang)), t.id, foe.id, answer = true, cue = SkirmishCue.BEHIND)
                weaponAttack(t, foe, advantage = true, cover = false)
            }
            CharClass.CLERIC -> {
                say(Msg72.prays.f(lang, t.name(lang)), t.id, answer = true)
                heal(t, t, dice.roll(Moves.PRAYER_HEAL))
            }
            CharClass.WIZARD -> {
                say(Msg72.flamesBack.f(lang, t.name(lang), foe.name(lang)), t.id, foe.id, answer = true)
                spellAttack(t, foe, dice(cantripDice(h), 10))
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
        retargeted -= foe.id
        aimed.firstOrNull()?.let { aimSpot[foe.id] = byId(it).place }
    }

    /** The party's figures in the back row with a friend standing in front of them: what the lineup intents aim at (72.10a.8). */
    private fun covered(): List<Fighter> {
        val party = fighters.filter { it.side == Side.PARTY && it.standing }
        return if (party.none { it.place.row == Row.FRONT }) emptyList() else party.filter { it.place.row == Row.BACK }
    }

    /**
     * 285 (Chef 21.10., 18:11 „der übersprungene vordere Wolf wird der hintere Wolf … der hintere Wolf, der gesprungen ist
     * … wird dann der vordere Wolf“): a pounce from the back row ends in front; the friend leapt over, the one ahead of it
     * (else any standing in front), steps back into its place; with nobody standing in front, it takes a free front place.
     */
    private fun leapForward(foe: Fighter) {
        if (foe.place.row != Row.BACK) return
        val ahead = fighters.filter { it.side == foe.side && it !== foe && it.standing && it.place.row == Row.FRONT }
        val over = ahead.firstOrNull { it.place.slot == foe.place.slot } ?: ahead.firstOrNull()
        val to = over?.place ?: Spot(Row.FRONT, foe.place.slot).takeIf { s -> fighters.none { it.side == foe.side && it.place == s && it.standing } }
            ?: Spot.ALL.firstOrNull { s -> s.row == Row.FRONT && fighters.none { it.side == foe.side && it.place == s && it.standing } } ?: return
        // a fallen friend lying there gives up the place
        fighters.firstOrNull { it.side == foe.side && it !== foe && it !== over && it.place == to }?.place = foe.place
        over?.place = foe.place
        foe.place = to
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
                // 231: never the circle at the opening, before the player had a choice
                return dice.pick(buildList { add(Intents.pounce); add(Intents.pounce); if (others >= 2 && !circling && chosen) add(Intents.circle) })
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
        Msg130.sign(intent)?.let { say(pick(it).f(lang, foe.name(lang), "", target), foe.id) }
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
        // 240: a second of its kind: both get their numbers, the next one the one after the highest so far
        val kin = all.filter { it.monster?.id == m.id }
        if (kin.isNotEmpty()) {
            kin.filter { it.nr == 0 }.forEach { it.nr = 1 }
            g.nr = maxOf(numbered[m.id] ?: 0, kin.maxOf { it.nr }) + 1
        }
        numbered[m.id] = maxOf(numbered[m.id] ?: 0, g.nr)
        all += g
        order.add(order.indexOf(by) + 1, g)
        say(Msg72.answers.f(lang, m.name(lang)), g.id)
        announce(g)
    }

    private val AT_TARGET = setOf(Effect.POUNCE, Effect.AIM, Effect.BREAKTHROUGH, Effect.FLANK)

    /**
     * 231 (Vorgangsarchiv): whether the player has had a choice yet. Until then every hit leaves a friend at least 1 hit
     * point, so no one falls before the player could do anything.
     */
    var chosen = false
        private set

    /** 296.2: what a foe's landed blow does besides the damage, as in the old fight: a critical one wounds, and its kind's own special (unless MARS gives it intents of its own). */
    private fun foeWounds(foe: Fighter, t: Fighter, crit: Boolean) {
        val m = foe.monster!!
        val first = !foe.hasHit
        foe.hasHit = true
        if (crit && m.damageType == DamageType.SLASHING) inflict(t, Status.BLEED, 2)
        if (crit && m.damageType == DamageType.BLUDGEONING) inflict(t, Status.STUN, 1, Ability.CON to 12)
        // the kinds with intents of their own in MARS (130.3, 72.10a) keep those instead
        if (m.id in OWN_INTENTS) return
        when (m.special) {
            MonsterSpecial.POISON -> inflict(t, Status.POISON, 3, Ability.CON to 11, m.poison)
            MonsterSpecial.SURPRISE_ATTACK -> if (first) inflict(t, Status.STUN, 1, Ability.CON to 12)
            MonsterSpecial.EVASIVE -> if (dice.chance(0.2)) inflict(t, Status.BLIND, 2, Ability.CON to 10)
            MonsterSpecial.BLOOD_DRAIN -> if (dice.chance(0.3)) inflict(t, Status.BLEED, 2)
            else -> {}
        }
    }

    /** [by] null: no one's blow (296.2, a status hurting at the turn's start); it breaks no intent. */
    private fun hurt(t: Fighter, full: Int, by: String?, text: String, roll: RollInfo? = null, wound: Boolean = false) {
        // 259 (5): a quick light fight costs the party less, the further the hero stands above the foes
        val dmg = if (quickRun && t.side == Side.PARTY) (full * quickHarm).toInt() else full
        t.hp = (t.hp - dmg).coerceAtLeast(if (!chosen && t.side == Side.PARTY && t.hp > 0) 1 else 0)
        say(text, by, t.id, dmg, roll, wound = wound)
        if (t.standing) {
            val plan = intents[t.id] ?: return
            if (by == null) return
            t.takenSinceAnnounce += dmg
            if ((plan.first.breakable && t.takenSinceAnnounce * BREAK_SHARE >= t.maxHp) || (plan.first.breakOnAnyHit && dmg > 0)) {
                intents.remove(t.id)
                say(pick(Msg72.broken).f(lang, t.name(lang), plan.first.name(lang)), target = t.id)
            }
            return
        }
        if (t.side == Side.FOES) {
            intents.remove(t.id)
            say(wolf(t, Msg279.wolfFalls, Msg72.falls).f(lang, t.name(lang)), target = t.id, cue = SkirmishCue.FOE_FALLS)
        } else if (t === fighters.first()) {
            say(pick(Msg72.heroFalls).f(lang, t.name(lang)), target = t.id, cue = SkirmishCue.HERO_FALLS)
            outcome = Outcome.LOST
            return
        } else {
            // a mercenary is knocked out, not killed (72.8)
            knockouts++
            say(pick(Msg72.knockedOut).f(lang, t.name(lang)), target = t.id, cue = SkirmishCue.KNOCKED_OUT)
        }
        if (fighters.none { it.side == Side.FOES && it.standing }) outcome = Outcome.WON
    }

    private fun say(text: String, actor: String? = null, target: String? = null, damage: Int = 0, roll: RollInfo? = null, answer: Boolean = false, wound: Boolean = false, cue: SkirmishCue? = null) {
        val e = SkirmishEvent(
            text, actor, target, damage, fighters.associate { it.id to it.hp }, fighters.associate { it.id to it.place }, LinkedHashMap(intents),
            roll, queue(), fighters.associate { it.id to it.sp }, answer, wound, casting, cue,
            fighters.filter { it.status.isNotEmpty() }.associate { it.id to LinkedHashMap(it.status) },
        )
        log += e
        // 259: a quick fight is not played on the screen; its lines come with its result
        if (!quickRun) listener?.invoke(e)
    }

    companion object {
        /** 301: the intents never aimed anew when their target steps back (they aim at the lineup or a place). */
        private val NO_REAIM = setOf(Effect.BREAKTHROUGH, Effect.FLANK, Effect.CIRCLE, Effect.POUNCE)
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
        /** 259: levels the hero must stand above the strongest foe's challenge rating for a light fight (provisional, 259 check). */
        const val EASY_GAP = 4.0

        /** A challenge rating as a number: "1/4" is 0.25. */
        fun crValue(cr: String): Double = cr.split("/").let { if (it.size == 2) it[0].toDouble() / it[1].toDouble() else it[0].toDouble() }

        /** Söldner names, the next free one for each (STORY-BLENDE.md `[72.10a.5.namen]`); never the hero's. */
        val MERC_NAMES = listOf("Bertram", "Hagen", "Edric", "Tamsin", "Wulf", "Ilsa", "Corwin", "Maren", "Odo", "Fenna", "Rurik", "Sela")

        private val json = kotlinx.serialization.json.Json { ignoreUnknownKeys = true; encodeDefaults = true; allowStructuredMapKeys = true }

        /** A copy of the hero on [PROBE_LEVEL], hit points and spell points full; the real hero stays as he is. */
        private fun atProbeLevel(real: Hero, level: Int): Hero {
            val h = json.decodeFromString(Hero.serializer(), json.encodeToString(Hero.serializer(), real))
            h.chapter = real.chapter
            h.level = level
            h.restoreFully()
            return h
        }

        /** The foes of the probe (130.3): each asks for a different answer. */
        enum class ProbeFoe { GRAK, WOLVES, SPIDER, SCOUT }

        /** The probe's lineup: hero in front, a Söldner of [cls] behind (ranged) or beside (melee), Grak opposite. */
        fun grakProbe(state: GameState, cls: CharClass, lang: Lang, dice: Dice = Dice()): Skirmish = probe(state, cls, lang, ProbeFoe.GRAK, dice)

        /** Hero and Söldner against the chosen foes (130.3); everything else as in [grakProbe]. [level] for the test tab (259). */
        fun probe(state: GameState, cls: CharClass, lang: Lang, foe: ProbeFoe, dice: Dice = Dice(), level: Int = PROBE_LEVEL): Skirmish {
            val hero = atProbeLevel(state.hero, level)
            val merc = Hero.create(MERC_NAMES.first { !it.equals(hero.name, ignoreCase = true) }, Race.HUMAN, cls)
            merc.level = level
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

        /** 296.2: the kinds whose specials MARS plays through their own intents, not the old fight's. */
        val OWN_INTENTS = setOf(GRAK, CALLED, SCOUT, WOLF, SPIDER)
        /** 296.2: the id of the hero in every fight. */
        const val HERO = "hero"
        /** 296.2: at most this many of a leader's pack come into a fight in MARS: four places a side, the leader takes one. */
        const val PACK_MAX = 3

        /**
         * 296.2: a fight of the game in MARS, the same foe the old fight [b] rolled (kind, life points, pack): the hero
         * as he is (life and spell points, uses left since the last rest, his own weapons), the healing potions from the
         * bag; how they met on the map decides who strikes first. [Battle.closeMars] carries the end back into the game.
         */
        fun fromBattle(b: Battle, dice: Dice = Dice()): Skirmish {
            val st = b.state
            val hero = st.hero
            val leader = Fighter("foe", Side.FOES, Spot(Row.FRONT, 0), monster = b.monster, hp = b.enemyMaxHp).also {
                it.attackShift = b.enemyAttack - b.monster.attackBonus
                it.damageShift = b.enemyDamageBonus
                it.acShift = b.baseEnemyAc - b.monster.ac
            }
            val places = listOf(Spot(Row.FRONT, 1), Spot(Row.BACK, 0), Spot(Row.BACK, 1))
            val mates = b.pack?.let { p ->
                (0 until minOf(b.packSize, PACK_MAX)).map { i -> Fighter("mate${i + 1}", Side.FOES, places[i], monster = Monsters[p.mate], hp = dice.roll(Monsters[p.mate].hp))
                    .also { it.attackShift = -b.firstLevelEase } }
            }.orEmpty()
            val me = Fighter(HERO, Side.PARTY, Spot(Row.FRONT, 0), hero = hero, hp = hero.hp, second = secondWeapon(hero, st.bag))
            me.status.putAll(b.heroStatus)
            me.uses.keys.filter { it.cost == SkillCost.PER_REST }.forEach { me.uses[it] = (it.amount - (hero.spent[it] ?: 0)).coerceAtLeast(0) }
            return Skirmish(listOf(me), listOf(leader) + mates, b.lang, dice, winded = st.winded, opening = b.opening).also { sk ->
                Items.all.filter { it.heal != null && st.count(it.id) > 0 }.forEach { sk.potions[it.id] = st.count(it.id) }
                sk.intro = b.marsIntro()
            }
        }
    }
}

/** Texts of MARS; placeholders for the build, final wording with Kreativ (41). */
private object Msg72 {
    val announces = T("{0} kündigt an: {1}.", "{0} announces: {1}.")
    val foeUses = T("{0}: {1}!", "{0}: {1}!")
    // 279 (STORY-SPIEL.md `[279.…]`, Homer): three wordings of each line
    val hits = Lines(T("{0} trifft {1}: {2} Schaden.", "{0} hits {1}: {2} damage."), T("{0} erwischt {1}: {2} Schaden.", "{0} catches {1}: {2} damage."),
        T("{0} landet einen Treffer bei {1}: {2} Schaden.", "{0} lands a blow on {1}: {2} damage."))
    val misses = Lines(T("{0} verfehlt {1}.", "{0} misses {1}."), T("Der Angriff von {0} geht an {1} vorbei.", "{0}'s attack goes wide of {1}."),
        T("{0} zielt auf {1}, doch daneben.", "{0} goes for {1}, but misses."))
    val waits = Lines(T("{0} geht in Abwehrhaltung.", "{0} takes a defensive stance."), T("{0} hebt die Deckung.", "{0} raises a guard."),
        T("{0} wartet in Abwehr.", "{0} waits on guard."))
    val swaps = Lines(T("{0} wechselt die Reihe.", "{0} switches rows."), T("{0} tauscht die Reihe.", "{0} trades rows."),
        T("{0} geht in die andere Reihe.", "{0} moves to the other row."))
    /** 72.10a.11: provisional wording, final with Homer (72.10a.11T). */
    val draws = T("{0} wechselt die Waffe: {1}.", "{0} switches weapons: {1}.")
    val falls = Lines(T("{0} fällt.", "{0} falls."), T("{0} bricht zusammen.", "{0} collapses."), T("{0} rührt sich nicht mehr.", "{0} lies still."))
    val heroFalls = Lines(T("{0} bricht zusammen.", "{0} collapses."), T("{0} sinkt nieder, die Kraft ist fort.", "{0} sinks down, strength gone."),
        T("{0} geht zu Boden und kommt nicht mehr hoch.", "{0} goes down and does not rise."))
    val knockedOut = Lines(T("{0} geht zu Boden, bewusstlos.", "{0} goes down, unconscious."), T("{0} sinkt bewusstlos nieder.", "{0} sinks down, senseless."),
        T("{0} bricht zusammen, ohne Bewusstsein.", "{0} collapses, out cold."))
    val gathers = T("{0} sammelt Kraft: +{1} TP.", "{0} gathers strength: +{1} HP.")
    val answers = T("Verstärkung: {0} eilt herbei.", "Reinforcement: {0} comes running.")
    val broken = Lines(T("{0} taumelt: {1} vereitelt.", "{0} staggers: {1} foiled."), T("{0} gerät ins Wanken: {1} vereitelt.", "{0} reels: {1} foiled."),
        T("{0} strauchelt: {1} vereitelt.", "{0} stumbles: {1} foiled."))
    /** `[86.9.atem]` (309) */
    val winded = T("{0} kommt keuchend an und braucht einen Augenblick, bis die Waffe oben ist.", "{0} arrives gasping and needs a moment to get the weapon up.")
    val autopilotStops = T("Automatik hält an.", "Autopilot stops.")
    val breaksThrough = T("{0} bricht durch und stößt {1} nach hinten.", "{0} breaks through and shoves {1} back.")
    val braced = T("{1} stellt sich {0} vorn entgegen. Kein Durchkommen.", "{1} meets {0} at the front. No way through.")
    /** 72.10a.9: provisional wording, final with Homer (72.10a.9T). */
    val covers = T("{0} stellt sich vor die anderen und zieht jeden Schlag auf sich.", "{0} stands before the others and draws every blow.")
    val strikesBack = T("{0} weicht dem Schlag aus und schlägt zurück.", "{0} evades the blow and strikes back.")
    /** `[72.10a.9.ruecken]` (309) */
    val stepsBehind = T("{0} weicht aus und gleitet {1} in den Rücken, wo die Deckung offen ist.", "{0} dodges and slips behind {1}, where the guard is open.")
    val prays = T("{0} weicht aus und murmelt ein Gebet.", "{0} dodges and murmurs a prayer.")
    /** 219.3: provisional wording, final with Homer (219.3T). */
    val flamesBack = T("{0} weicht aus und schleudert {1} einen Feuerpfeil entgegen.", "{0} dodges and hurls a fire bolt back at {1}.")
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
    private val good = Lines(T("{0} fängt den Schlag halb ab.", "{0} half catches the blow."), T("{0} nimmt dem Schlag die halbe Wucht.", "{0} takes half the force out of the blow."),
        T("{0} lenkt den Schlag halb ab.", "{0} turns the blow half aside."))
    /** 219.4T: a perfect ring without an answer of the class ([219.4T.aus], [279.ganz]). */
    val evades = Lines(T("{0} weicht dem Schlag ganz aus.", "{0} evades the blow entirely."), T("{0} dreht sich weg, der Schlag geht ins Leere.", "{0} twists away; the blow finds nothing."),
        T("{0} ist fort, bevor der Schlag ankommt.", "{0} is gone before the blow lands."))
    fun reacts(r: Reaction) = if (r == Reaction.PERFECT) evades else good
}

/** Texts of 130.3 (STORY-SPIEL.md `[130.3.…]`, Homer); the signs follow the announcement. */
private object Msg130 {
    val at = T("(auf {0})", "(at {0})")
    // 279: fassung 1 from 130.3, 2 and 3 from `[279.…]`
    val loses = Lines(T("{0} verliert den Zug.", "{0} loses the turn."), T("{0} muss diesen Zug aussetzen.", "{0} must sit this turn out."),
        T("Für {0} ist dieser Zug verloren.", "This turn is lost for {0}."))
    val gone = Lines(T("Er ist verschwunden. Der nächste Pfeil kommt von irgendwo.", "He is gone. The next arrow comes from somewhere."),
        T("Von ihm keine Spur. Irgendwo wartet ein Pfeil.", "No trace of him. Somewhere, an arrow waits."),
        T("Er ist fort. Woher der nächste Pfeil kommt, weiß keiner.", "He is gone. No one knows where the next arrow will come from."))
    val circleClosed = Lines(T("Der Kreis schließt sich. Die Wölfe greifen gemeinsam an.", "The circle closes. The wolves strike together."),
        T("Der Kreis ist zu. Das Rudel greift an, alle auf einmal.", "The circle is shut. The pack attacks, all at once."),
        T("Ein Heulen, dann stürzt sich das ganze Rudel zugleich vor.", "A howl, and the whole pack surges in at once."))
    val pounceEmpty = Lines(T("Der Sprung geht ins Leere.", "The pounce lands on nothing."), T("{0} springt ins Leere.", "{0} leaps at empty ground."),
        T("{0} landet auf leerem Boden und knurrt.", "{0} lands on bare ground, growling."))
    /** `[279.wolf.sprung.um]` (Chef 16:21: „zu Boden“ heißt abknien), in place of `[130.3.wolf.sprung.um]`. */
    val pounceHits = Lines(T("{0} springt {1} an. {1} geht zu Boden.", "{0} leaps at {1}. {1} goes down."),
        T("{0} prallt gegen {1}. {1} sinkt nieder.", "{0} slams into {1}. {1} sinks down."),
        T("{0} wirft sich auf {1}. {1} geht in die Knie.", "{0} throws itself at {1}. {1} is driven to the knees."))
    val ducks = Lines(T("{1} duckt sich, der Pfeil zischt vorbei.", "{1} ducks; the arrow hisses past."),
        T("{1} duckt sich, der Pfeil pfeift über den Kopf.", "{1} ducks; the arrow whistles overhead."),
        T("{1} duckt sich weg, der Pfeil verfehlt.", "{1} ducks away; the arrow misses."))
    val venomHits = Lines(T("Ein Strahl Gift trifft {1}.", "A jet of venom strikes {1}."), T("Gift spritzt auf {1}.", "Venom spatters {1}."),
        T("{1} bekommt einen Schwall Gift ab.", "{1} takes a splash of venom."))
    val webHolds = Lines(T("{1} hängt im Netz fest und verliert den nächsten Zug.", "{1} is caught in the web and loses the next turn."),
        T("Das Netz legt sich um {1}, der nächste Zug ist verloren.", "The web wraps around {1}; the next turn is lost."),
        T("{1} zappelt in den Fäden und verliert den nächsten Zug.", "{1} struggles in the threads and loses the next turn."))
    private val signs = mapOf(
        // 280: Grak carries a war axe (`[130.3.grak.hieb]`)
        "heavy" to Lines(T("Er reißt die Axt hinter den Kopf.", "He hauls the axe back behind his head."),
            T("Er hebt die Axt mit beiden Händen hoch über den Kopf.", "He lifts the axe high over his head with both hands."),
            T("Er holt weit aus, die Axt hinter dem Kopf.", "He winds up, the axe behind his head.")),
        "call" to Lines(T("Er stampft und brüllt nach seinem Rudel. Irgendwo antwortet Kreischen.", "He stamps and bellows for his pack. Somewhere, shrieks answer."),
            T("Er stampft auf und brüllt. Von weiter weg kreischt es zurück.", "He stamps and roars. From farther off, a shriek answers."),
            T("Er stampft zweimal und reißt das Maul auf. Ein Kreischen antwortet.", "He stamps twice and throws his jaws wide. A shriek answers.")),
        "gather" to Lines(T("Er weicht zurück und atmet schwer, die Narben glühen.", "He falls back, breathing hard, his scars aglow."),
            T("Er tritt zurück, die Brust hebt und senkt sich, die Narben glimmen.", "He steps back, chest heaving, his scars smouldering."),
            T("Er zieht sich einen Schritt zurück und schnauft, seine Narben leuchten auf.", "He backs off a step and snorts; his scars flare.")),
        "pounce" to Lines(T("Er duckt sich flach, die Augen auf {2}.", "He crouches low, eyes on {2}."),
            T("Er drückt sich an den Boden, die Augen auf {2}.", "He presses himself to the ground, eyes on {2}."),
            T("Er geht tief, die Hinterläufe gespannt, den Blick auf {2}.", "He sinks low, hind legs tensed, gaze on {2}.")),
        "circle" to Lines(T("Die Wölfe ziehen auseinander, einer bleibt zurück und knurrt.", "The wolves spread out; one hangs back, growling."),
            T("Das Rudel fächert sich auf, einer hält sich hinten und knurrt.", "The pack fans out; one keeps back, growling."),
            T("Die Wölfe verteilen sich, nur einer bleibt zurück, die Lefzen hochgezogen.", "The wolves scatter wide; only one stays back, lips curled.")),
        "venom" to Lines(T("Gift tropft von ihren Kieferklauen, sie zielt auf {2}.", "Venom drips from her fangs; she takes aim at {2}."),
            T("Ihre Kieferklauen glänzen nass, sie richtet sich auf {2} aus.", "Her fangs glisten wet; she turns toward {2}."),
            T("Ein Tropfen Gift fällt von ihren Kieferklauen. Sie wendet sich {2} zu.", "A drop of venom falls from her fangs. She turns to {2}.")),
        "web" to Lines(T("Sie hebt den Hinterleib, ein Faden spannt sich.", "She raises her abdomen; a thread pulls taut."),
            T("Ihr Hinterleib hebt sich, Spinnfäden glänzen.", "Her abdomen rises; silk glints."),
            T("Sie reckt den Hinterleib in die Höhe, ein Faden zittert.", "She lifts her abdomen high; a thread trembles.")),
        "aim" to Lines(T("Die Sehne knarrt. Die Pfeilspitze sucht {2}.", "The bowstring creaks. The arrowhead seeks {2}."),
            T("Er spannt den Bogen und zielt auf {2}.", "He draws the bow and aims at {2}."),
            T("Er zieht die Sehne bis ans Ohr, die Spitze auf {2}.", "He draws the string to his ear, the point on {2}.")),
        // `[279.spaeher.schatten]` (309): the intent, he still stands there
        "shadow" to Lines(T("Sein Blick wandert zum Dunkel hinter ihm.", "His eyes slide to the dark behind him."),
            T("Er tastet sich rückwärts, dem Dunkel entgegen.", "He edges backwards, toward the dark."),
            T("Er sucht den nächsten Schatten; einen Atemzug noch, dann ist er fort.", "He looks for the nearest shadow; one breath more and he is gone.")),
        // 72.10a.8 (STORY-SPIEL.md `[72.10a.8.bruch]`, `[72.10a.8.flanke]`)
        "breakthrough" to Lines(T("Er senkt die Schulter. Sein Blick geht an der vorderen Reihe vorbei, zu {2}.", "He lowers his shoulder. His eyes slide past the front row to {2}."),
            T("Er zieht den Kopf ein und starrt über die vordere Reihe hinweg auf {2}.", "He ducks his head and stares past the front row at {2}."),
            T("Er stemmt die Füße in den Boden, den Blick auf {2} hinter der vorderen Reihe.", "He plants his feet, eyes on {2} behind the front row.")),
        "flank" to Lines(T("Er löst sich aus der Reihe und schleicht seitlich auf {2} zu.", "He slips out of the line and creeps sideways toward {2}."),
            T("Er tritt zur Seite und pirscht sich an {2} heran.", "He steps aside and stalks toward {2}."),
            T("Er verlässt die Reihe und schleicht außen herum auf {2} zu.", "He leaves the line and creeps round the outside toward {2}.")),
    )
    fun sign(i: Intent): Lines? = signs[i.id]
}

/** 279: one line in several wordings (STORY-SPIEL.md „Varianten der Kampfzeilen“); [Skirmish] picks one. */
class Lines(vararg val all: T)

/** 301: a foe aims its announced blow anew at one in front, {0} the foe, {1} the new target; the lines are Homer's (301.1). */
private object Msg301 {
    /** `[301.stattdessen]` */
    val reaims = Lines(
        T("{0} knurrt wütend und fährt ungelenk zu {1} herum.", "{0} snarls with rage and wheels clumsily round on {1}."),
        T("{0} faucht dem verlorenen Ziel nach und wendet sich zu spät {1} zu.", "{0} hisses after the lost mark and turns to {1} too late."),
        T("Verärgert sucht {0} ein neues Ziel und geht {1} hastig an.", "Annoyed, {0} casts about for a new mark and goes hastily for {1}."),
        T("{0} schnaubt vor Wut und kommt aus dem Tritt; jetzt muss {1} herhalten.", "{0} snorts with fury, thrown off stride; now {1} will have to do."),
        T("Um das Ziel betrogen, geht {0} blindlings auf {1} los.", "Cheated of the mark, {0} lunges blindly at {1}."),
    )
}

/** 279: lines of their own (STORY-SPIEL.md `[279.…]`). */
private object Msg279 {
    /** `[279.auf]`: the turn lost, getting up again (Chef 16:24: aufstützen, durchatmen). */
    val rises = Lines(T("{0} stützt sich ab und kommt wieder hoch: Zug verloren.", "{0} pushes up and gets back to their feet: turn lost."),
        T("{0} atmet durch und steht wieder auf: Zug verloren.", "{0} draws a breath and stands again: turn lost."),
        T("{0} rappelt sich auf: Zug verloren.", "{0} scrambles up: turn lost."))
    val wolfHits = Lines(T("{0} beißt {1}: {2} Schaden.", "{0} bites {1}: {2} damage."), T("{0} schnappt zu und erwischt {1}: {2} Schaden.", "{0} snaps and catches {1}: {2} damage."),
        T("{0} schlägt die Zähne in {1}: {2} Schaden.", "{0} sinks its teeth into {1}: {2} damage."), T("{0} reißt an {1}: {2} Schaden.", "{0} tears at {1}: {2} damage."))
    val wolfMisses = Lines(T("{0} schnappt nach {1} und verfehlt.", "{0} snaps at {1} and misses."), T("{0} beißt daneben.", "{0} bites at nothing."),
        T("Die Zähne von {0} schlagen ins Leere.", "{0}'s teeth close on air."))
    val wolfFalls = Lines(T("{0} fällt.", "{0} falls."), T("{0} jault auf und bleibt liegen.", "{0} yelps and stays down."), T("{0} sackt winselnd zusammen.", "{0} slumps, whimpering."))
}

/** 296.2: the lines of the old fight, the same words in MARS. */
private object Msg296 {
    val stillSurprised = T("{0} ist noch überrascht und kann nicht reagieren!", "{0} is still caught off guard!")
    val fled = T("{0} ist entkommen!", "{0} got away safely!")
    val cantFlee = T("Die Flucht misslingt!", "Couldn't get away!")
    val damage = T("{0} Schaden.", "{0} damage.")
}
