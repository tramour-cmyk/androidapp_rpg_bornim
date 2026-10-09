package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import de.bornim.core.audio.Sound
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Action
import de.bornim.core.Anim
import de.bornim.core.Battle
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.ItemKind
import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.MapKind
import de.bornim.core.MonsterLook
import de.bornim.core.Outcome
import de.bornim.core.Rules
import de.bornim.core.Skill
import de.bornim.core.SkillCost
import de.bornim.core.Step
import de.bornim.core.Ui
import androidx.compose.ui.layout.onSizeChanged
import de.bornim.core.art.Act
import de.bornim.core.art.BattleArt
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CaveScene
import de.bornim.core.art.Glow
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.Pose
import de.bornim.game.GameViewModel
import androidx.compose.runtime.withFrameMillis
import kotlinx.coroutines.launch
import kotlin.math.sin

private enum class BattleMenu { MAIN, FIGHT, SKILLS, BAG }

/** UI-side state of a battle: plays the log step by step and animates the numbers. */
private class BattleUi(val battle: Battle) {
    val queue = mutableStateListOf<Step>()
    var current by mutableStateOf<Step?>(null)
    var heroHp by mutableIntStateOf(battle.hero.hp)
    var heroSp by mutableIntStateOf(battle.hero.sp)
    var enemyHp by mutableIntStateOf(battle.enemyHp)
    /** The foe's hit points its wounds show: a blow of the hero's that halts as it lands opens them only as it lands. */
    var woundHp by mutableIntStateOf(battle.enemyHp)
    var menu by mutableStateOf(BattleMenu.MAIN)
    var animKey by mutableIntStateOf(0)
    var enemyGone by mutableStateOf(false)
    /** The foe did not fall but fled (turned by the cleric): it shrinks back, draws off and is gone. */
    var foeFled by mutableStateOf(false)
    /** The foe was destroyed by the cleric's holy light: it flares up white and falls to ash. */
    var foeDestroyed by mutableStateOf(false)
    /** A foe built in the round is falling: the next message waits until it lies on the ground. */
    var falling by mutableStateOf(false)
    var heroStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var foeStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var pack by mutableIntStateOf(battle.packSize)
    var packBefore by mutableIntStateOf(battle.packSize)
    var heroGone by mutableStateOf(false)
    /** Which attack animation the foe plays for its current attack. */
    var attackVariant by mutableIntStateOf(0)
    /** Which way the foe takes a blow or turns one aside: picked anew each time, never the same twice running. */
    var reactVariant by mutableIntStateOf(0)
    /** The foe is wound up for its blow and holds it through any word in between (a critical hit, a surprise attack),
     *  until the blow lands or misses. */
    var foePoised by mutableStateOf(false)
    /** A spell of the poised foe that lands (or is turned aside) on the hero without a blow: the wind-up is let go with it. */
    var foeCastLands by mutableStateOf(false)
    /** Counts the leader's howls; [howlStart] is when the latest began, [howlSound] which voice it uses. */
    var howlKey by mutableIntStateOf(0)
    var howlStart = 0L
    var howlSound = Sound.HOWL_1
    private val howls = MonsterArt.isNewStyle(battle.monster.id) && battle.monster.id.contains("wolf")

    /**
     * What the hero's doll is playing: frames [from]..[to] of an act over [ms] from [start], then back to rest unless it
     * [hold]s. A [lead] is played before it starts: the way down out of a held guard. From frame [slowFrom] on each
     * frame takes [slowK] times as long: a blow struck fast, the step back after it taken at ease.
     */
    class HeroMotion(val act: HeroFigure.Act, val strike: HeroFigure.Strike, val variant: Int, val from: Int, val to: Int, val start: Long, val ms: Long, val hold: Boolean = false, val lead: HeroMotion? = null,
        val slowFrom: Int = Int.MAX_VALUE, val slowK: Double = 1.0, val stopAt: Long = Long.MAX_VALUE, val stopMs: Long = 0L) {
        /** The move's own clock: it stands still for [stopMs] from [stopAt], where the blow lands. */
        fun clock(now: Long): Long = when {
            now < stopAt -> now
            now < stopAt + stopMs -> stopAt
            else -> now - stopMs
        }
        /** When the move is played through, its halt on the blow included. */
        val end: Long get() = start + ms + stopMs
        /** The same move, halting for [ms] at [at]. */
        fun halted(at: Long, ms: Long) = HeroMotion(act, strike, variant, from, to, start, this.ms, hold, lead, slowFrom, slowK, at, ms)

        /** The frame shown [now]. */
        fun index(now: Long): Int {
            val el = (clock(now) - start).toDouble()
            if (el <= 0) return from
            // played through: the last frame (a held guard or wind-up stays there)
            if (el >= ms) return to
            // the slow part starts at [slowFrom], or never (then past the end: no overflow from Int.MAX_VALUE)
            val slowStart = slowFrom.coerceIn(from, to + 1)
            val fast = slowStart - from
            val slow = to + 1 - slowStart
            val per = ms / (fast + slow * slowK)
            val i = if (el < fast * per) from + (el / per).toInt() else slowStart + ((el - fast * per) / (per * slowK)).toInt()
            return i.coerceIn(from, to)
        }

        /** How far along [from]..[to] the move is [now], between frames too: for the step in, which glides rather than jumping frame by frame. */
        fun pos(now: Long): Double {
            val el = (clock(now) - start).toDouble()
            if (el <= 0 || to <= from) return from.toDouble()
            if (el >= ms) return to.toDouble()
            val slowStart = slowFrom.coerceIn(from, to + 1)
            val fast = slowStart - from
            val slow = to + 1 - slowStart
            val per = ms / (fast + slow * slowK)
            val f = if (el < fast * per) el / per else fast + (el - fast * per) / (per * slowK)
            // the frames take [from]..[to]+1 between them; the step reaches [to] as the last frame ends, not as it starts
            return from + f * (to - from) / (to + 1 - from)
        }
    }
    var motion by mutableStateOf<HeroMotion?>(null)
    /** The hero's last blow, way of being struck and guard, so the next is another one. */
    private var lastStrike = -1
    private var lastHurt = -1
    private var lastGuard = -1

    /** One of the guards that suit this hero against this foe, not the last one again. */
    private fun guard(): Int {
        val list = HeroBattle.blockVariants(battle.hero, battle.monster.id)
        lastGuard = another(list.size, lastGuard)
        return list[lastGuard]
    }
    /** Which victory pose this fight ends in. */
    val victoryPick = BattleClock.random.nextInt(8)
    /** The swing to sound with a blow, after [swingDelay] ms; set when a blow starts. */
    var swingKey by mutableIntStateOf(0)
    var swingDelay = 0L
    /** A spell or shot let go with this message: from which act it leaves the hero, and how long until it does. */
    var release by mutableStateOf<Pair<HeroFigure.Act, Int>?>(null)
    var fxDelay = 0L
    /** This message's blow halts as it lands (see [HIT_STOP_MS]): its sound comes with the halt. */
    var hitStopped = false
    /** How long it halts: longer for the killing blow. */
    var stopMs = 0L
    /** The message of the killing blow still to come or under way (see [isKillBlow]), and the blow the hero strikes it with. */
    var killStep by mutableStateOf<Step?>(null)
    var killStrike: HeroFigure.Strike? = null
    /** When the killing blow landed (wall clock), 0 before. */
    var killAt by androidx.compose.runtime.mutableLongStateOf(0L)
    /** Counts spells let go, for the flash of light at the staff or hand. */
    var flashKey by mutableIntStateOf(0)

    /** The last frame before a blow lands: a blade still coming down, an arrow still on the string. */
    private fun windUpEnd(strike: HeroFigure.Strike) = HeroBattle.strikeFrame(strike) - (if (strike == HeroFigure.Strike.SHOOT) 1 else 2)

    private fun play(act: HeroFigure.Act, strike: HeroFigure.Strike = HeroFigure.Strike.SLASH, variant: Int = 0, from: Int = 0, to: Int = -1, perFrame: Long = 60, delayMs: Long = 0, hold: Boolean = false,
        slowFrom: Int = Int.MAX_VALUE, slowK: Double = 1.0, pacedDelay: Long = 0) {
        // the pace set in the menu (calm, normal, fast) speeds up or slows down every move; the callers' times are for normal
        // ([pacedDelay] is already at the pace)
        val perFrame = BattlePace.ms(perFrame)
        val delayMs = BattlePace.ms(delayMs) + pacedDelay
        val n = HeroBattle.frameCount(battle.hero, act, strike, variant)
        val end = if (to < 0) n - 1 else to.coerceAtMost(n - 1)
        val now = BattleClock.now()
        // out of a held guard the shield or weapon first comes down smoothly to the rest, then the next move begins;
        // being struck breaks the guard faster
        val m = motion
        val lead = if (m != null && m.hold && m.act == HeroFigure.Act.BLOCK && act != HeroFigure.Act.BLOCK) {
            val last = HeroBattle.frameCount(battle.hero, m.act, m.strike, m.variant) - 1
            val per = BattlePace.ms(if (act == HeroFigure.Act.HURT) 28L else 45L)
            HeroMotion(m.act, m.strike, m.variant, m.to, last, now, (last - m.to + 1) * per)
        } else null
        val start = maxOf(now + delayMs, (lead?.let { it.start + it.ms } ?: 0L))
        val slowN = (end + 1 - maxOf(slowFrom, from)).coerceAtLeast(0)
        val ms = ((end - from + 1 - slowN) * perFrame + slowN * perFrame * slowK).toLong()
        motion = HeroMotion(act, strike, variant, from, end, start, ms, hold, lead, slowFrom, slowK)
    }

    /** Sets the doll going for a new message: blows, spells, hits, blocks, the start of the fight and the victory. */
    private fun moveHero(s: Step) {
        val hero = battle.hero
        val m = motion
        val fx = s.fx
        // a spell with several bolts (the three scorching rays): each further one leaves the same staff or hand,
        // with a short thrust of the spell again
        val again = release?.takeIf { (act, _) -> act == HeroFigure.Act.CAST && fx != null && !fx.onHero && s.anim != Anim.SPELL && s.anim != Anim.HERO_ACT &&
            (fx.kind in FLYING || fx.past in FLYING) }
        release = null
        fxDelay = 0L
        hitStopped = false
        if (again != null) {
            val hit = HeroBattle.strikeFrame(HeroFigure.Strike.CAST)
            play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, again.second, hit - 1, hit + 1, perFrame = CAST_FRAME_MS)
            release = again
            fxDelay = 50L
            flashKey++
            return
        }
        // still waiting for a blow that never came: the hero's own move starts from the rest
        if (m != null && m.act == HeroFigure.Act.AMBUSHED && m.hold && s.anim in HERO_MOVES) motion = null
        when {
            // struck down: the hero falls, in this fight's way, and stays lying where it fell
            s.anim == Anim.HERO_FAINT -> play(HeroFigure.Act.DIE, variant = HeroBattle.diePick(victoryPick), perFrame = 95, hold = true)
            // a draught: from the belt pouch, the cork pulled, drunk in this fight's way; red for healing, green the remedy
            s.anim == Anim.DRINK -> play(HeroFigure.Act.DRINK, variant = HeroBattle.drinkPick(victoryPick) + (if (s.item == "remedy") 3 else 0), perFrame = 75)
            // ambushed: still facing us, the hero is caught from behind by the foe's first blow, staggers and only then
            // turns to it
            m != null && m.act == HeroFigure.Act.AMBUSHED && m.hold &&
                (s.anim == Anim.HERO_HIT || (s.anim == Anim.MISS && fx?.onHero == true)) ->
                play(HeroFigure.Act.AMBUSHED, perFrame = 120)
            s.anim == Anim.HERO_ACT -> {
                // the blow's end is already known: a critical hit that ends the foe is struck as a killing blow
                val result = queue.firstOrNull { it.anim == Anim.ENEMY_HIT || it.anim == Anim.ENEMY_FAINT || it.anim == Anim.MISS }
                val kills = HeroBattle.killStrikes(hero)
                if (result != null && result.isKillBlow()) { killStep = result; killStrike = HeroBattle.killForTest?.takeIf { it in kills } ?: kills.randomOrNull() }
                val strike = killStrike?.takeIf { result != null && result === killStep } ?: HeroBattle.strikes(hero).let { list ->
                    lastStrike = another(list.size, lastStrike)
                    list[lastStrike]
                }
                // while the attack is named, only the wind-up: the blow comes with the hit or the miss; a killing blow is
                // wound up to its height and held there
                play(HeroFigure.Act.ATTACK, strike, 0, 0, if (strike.killing) HeroFigure.killPeak(strike) else windUpEnd(strike), perFrame = ATTACK_FRAME_MS, hold = true)
            }
            (s.anim == Anim.ENEMY_HIT || s.anim == Anim.ENEMY_FAINT || s.anim == Anim.MISS) && fx?.onHero == false &&
                m != null && m.act == HeroFigure.Act.ATTACK && m.hold -> {
                // a killing blow: held a moment longer at its height, then down faster than any other, and out of it slowly
                val killing = m.strike.killing
                val per = if (killing) KILL_FRAME_MS else ATTACK_FRAME_MS
                play(HeroFigure.Act.ATTACK, m.strike, 0, m.to, -1, perFrame = per, delayMs = if (killing) KILL_HOLD_MS else 0L,
                    slowFrom = HeroBattle.strikeFrame(m.strike) + 1, slowK = if (killing) KILL_SLOW else MOVE_SLOW)
                if (m.strike != HeroFigure.Strike.SHOOT) {
                    swingDelay = if (killing) BattlePace.ms(KILL_HOLD_MS) else 0L; swingKey++
                    // a blow that strikes home: hero and foe stand still for a moment as it lands; the foe reels, and
                    // the blood flies, only then
                    if (s.anim == Anim.ENEMY_HIT) motion?.let { b ->
                        val land = b.start + (HeroBattle.strikeFrame(m.strike) - m.to) * BattlePace.ms(per)
                        stopMs = if (s === killStep) KILL_STOP_MS else HIT_STOP_MS
                        motion = b.halted(land, stopMs)
                        fxDelay = (land - BattleClock.now()).coerceAtLeast(0L) + stopMs
                        hitStopped = true
                    }
                }
                // the arrow or bolt leaves the bow on the frame the string is let go
                else { release = HeroFigure.Act.ATTACK to 0; fxDelay = (HeroBattle.strikeFrame(m.strike) - m.to) * BattlePace.ms(ATTACK_FRAME_MS) }
            }
            // a flask: drawn back while it is named, thrown with the next message
            s.anim == Anim.THROW -> play(HeroFigure.Act.THROW, HeroFigure.Strike.CAST, HeroBattle.throwVariant(hero), 0, HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - 1, perFrame = CAST_FRAME_MS, hold = true)
            m != null && m.act == HeroFigure.Act.THROW && m.hold && (fx != null || s.anim != Anim.NONE) -> {
                play(HeroFigure.Act.THROW, HeroFigure.Strike.CAST, m.variant, m.to, -1, perFrame = CAST_FRAME_MS)
                release = HeroFigure.Act.THROW to m.variant
                fxDelay = (HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - m.to) * BattlePace.ms(CAST_FRAME_MS)
            }
            // while the spell is named, it gathers and glows; it is let go with its effect on the next message
            s.anim == Anim.SPELL -> play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, HeroBattle.castVariant(hero), 0, HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - 1, perFrame = CAST_FRAME_MS, hold = true)
            m != null && m.act == HeroFigure.Act.CAST && m.hold && (fx != null || s.anim != Anim.NONE) -> {
                play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, m.variant, m.to, -1, perFrame = CAST_FRAME_MS)
                // the spell leaves the staff, wand or hand on the frame it is let go, in a flash of light
                release = HeroFigure.Act.CAST to m.variant
                fxDelay = (HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - m.to) * BattlePace.ms(CAST_FRAME_MS)
                flashKey++
            }
            // struck through the guard: the guard holds until the hero's next turn, as the defence does; the blow shows
            // in the flash of the hit
            s.anim == Anim.HERO_HIT && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.HERO_HIT -> play(HeroFigure.Act.HURT, variant = another(3, m?.takeIf { it.act == HeroFigure.Act.HURT }?.variant ?: lastHurt).also { lastHurt = it }, perFrame = 95,
                // a new-style foe's blow lands a moment into the message, then halts: the hero flinches only then
                pacedDelay = foeBlowLands(battle, attackVariant, s)?.let { it + HIT_STOP_MS } ?: 0L)
            // the defensive stance: up into the guard, held until the hero's next turn
            // a draught drunk on guard: the guard comes down first
            s.anim == Anim.HERO_HEAL && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> play(HeroFigure.Act.IDLE, from = 0, to = 0)
            // already on guard: it simply stays up
            s.anim == Anim.DEFEND && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.DEFEND -> play(HeroFigure.Act.BLOCK, variant = guard(), from = 0, to = 7, perFrame = 70, hold = true)
            // fended off from the guard: the guard stays up
            s.anim == Anim.MISS && fx?.onHero == true && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.MISS && fx?.onHero == true &&
                (fx.kind == de.bornim.core.FxKind.BLOCK || HeroBattle.outfit(hero).twoHands) ->
                play(HeroFigure.Act.BLOCK, variant = guard(), perFrame = 70)
            enemyGone && s.anim != Anim.ENEMY_FAINT && m?.act != HeroFigure.Act.VICTORY ->
                play(HeroFigure.Act.VICTORY, variant = HeroBattle.variant(hero, HeroFigure.Act.VICTORY, battle.monster.id, victoryPick), perFrame = 70, delayMs = 250, hold = true)
        }
    }

    init {
        // the fight begins with the hero facing us and turning to the foe; in an ambush the hero stays facing us,
        // unaware, until the foe's blow lands from behind
        if (battle.opening == de.bornim.core.Opening.AMBUSHED) play(HeroFigure.Act.AMBUSHED, from = 0, to = 0, hold = true)
        else play(HeroFigure.Act.TURN, perFrame = 90, delayMs = 700)
        push(battle.start())
    }

    fun push(steps: List<Step>) {
        queue.addAll(steps)
        if (current == null) next()
    }

    /** A field at the end of a won fight: what was won, then (a second one) how the hero grew. */
    class EndPanel(val title: String, val lines: List<Step>)
    var panels by mutableStateOf<List<EndPanel>>(emptyList())
    /** The words of the killing blow, held back while the move runs on into the fall. */
    var killWords: String? = null

    /** The foe lies dead: the hero takes up its victory pose. */
    fun victory() {
        if (motion?.act != HeroFigure.Act.VICTORY)
            play(HeroFigure.Act.VICTORY, variant = HeroBattle.variant(battle.hero, HeroFigure.Act.VICTORY, battle.monster.id, victoryPick), perFrame = 70, hold = true)
    }

    /** The rest of the messages gathered into the end fields: the spoils in one, growing stronger in another. */
    fun openPanels(lang: de.bornim.core.Lang) {
        val rest = queue.toList().filter { it.anim != Anim.PACK_FLEE }
        queue.clear()
        rest.lastOrNull()?.let { heroHp = it.heroHp; heroSp = it.heroSp; heroStatus = it.heroStatus }
        pack = 0
        // a foe driven off or destroyed by the cleric's holy power: a plain closing line as the title, like "… was
        // defeated!", and the words of the turning first in the field
        val turnedBy = current?.fx?.kind?.takeIf { it == de.bornim.core.FxKind.TURN || it == de.bornim.core.FxKind.DESTROY }
        val foeName = battle.monster.name(lang)
        val title = when (turnedBy) {
            de.bornim.core.FxKind.TURN -> de.bornim.core.T("{0} wurde vertrieben!", "{0} was driven off!")(lang).replace("{0}", foeName)
            de.bornim.core.FxKind.DESTROY -> de.bornim.core.T("{0} wurde vernichtet!", "{0} was destroyed!")(lang).replace("{0}", foeName)
            else -> current?.text ?: ""
        }
        // the killing blow's words first in the field, then the spoils
        val blow = (if (turnedBy != null) current?.text else killWords)?.let { w -> current?.copy(text = w, anim = Anim.NONE, rarity = null) }
        current = null
        val lvl = rest.indexOfFirst { it.anim == Anim.LEVEL_UP }
        val spoils = if (lvl < 0) rest else rest.subList(0, lvl)
        val grow = if (lvl < 0) emptyList() else rest.subList(lvl, rest.size)
        panels = listOfNotNull(EndPanel(title, listOfNotNull(blow) + spoils), grow.takeIf { it.isNotEmpty() }?.let {
            EndPanel(if (lang == de.bornim.core.Lang.DE) "Stärker geworden" else "Grown stronger", it) })
    }

    /** The message now shown ends a lead-in: its words wait until the blow lands or the spell arrives. */
    var afterLead = false

    /**
     * A shaman on the doll shows what it is about to do, read from the message that follows its wind-up: a fire bolt
     * (it flies, hit or miss), a curse (it lands or is shrugged off, with no blow), or the staff swung as a club.
     */
    private fun shamanMove(after: Step?): Int? {
        if (battle.monster.id != "goblin_shaman" || !MonsterArt.isDoll(battle.monster.id)) return null
        val f = after?.fx
        return when {
            f != null && (f.kind == de.bornim.core.FxKind.FIRE_BOLT || f.past == de.bornim.core.FxKind.FIRE_BOLT) -> de.bornim.core.art.FoeArt.SHAMAN_BOLT
            after?.anim == Anim.NONE && f?.onHero == true -> de.bornim.core.art.FoeArt.SHAMAN_CURSE
            else -> de.bornim.core.art.FoeArt.SHAMAN_STAFF
        }
    }

    /** When the message now shown came up, for moves timed from it while the main motion waits (a bolt in flight). */
    var stepAt = 0L

    /** One of [n] variants at random, but not [last] again (when there is a choice). */
    fun another(n: Int, last: Int): Int {
        if (n <= 1) return 0
        val k = BattleClock.random.nextInt(n - 1)
        return if (k >= last.mod(n)) k + 1 else k
    }

    fun next() {
        stepAt = BattleClock.now()
        afterLead = current?.lead == true
        val s = if (queue.isEmpty()) null else queue.removeAt(0)
        current = s
        if (s != null) {
            heroHp = s.heroHp
            heroSp = s.heroSp
            enemyHp = s.enemyHp
            heroStatus = s.heroStatus
            foeStatus = s.foeStatus
            packBefore = pack
            pack = s.pack
            if (s.anim == Anim.ENEMY_FAINT) { enemyGone = true; foeFled = s.fx?.kind == de.bornim.core.FxKind.TURN; foeDestroyed = s.fx?.kind == de.bornim.core.FxKind.DESTROY }
            if (s.anim == Anim.HERO_FAINT) heroGone = true
            moveHero(s)
            if (!hitStopped) woundHp = s.enemyHp
            foeCastLands = foePoised && s.anim == Anim.NONE && s.fx?.onHero == true
            foePoised = s.anim == Anim.ENEMY_ACT || (foePoised && s.anim == Anim.NONE && s.fx == null)
            if (s.anim == Anim.ENEMY_ACT) attackVariant = shamanMove(queue.firstOrNull()) ?: another(MonsterArt.attackVariants(battle.monster.id), attackVariant)
            if (s.fx?.onHero == false && (s.anim == Anim.ENEMY_HIT || s.anim == Anim.MISS)) reactVariant = another(MonsterArt.reactVariants(battle.monster.id), reactVariant)
            // Wolves howl now and then, not every time: when they appear, and when a pack mate falls or flees.
            val chance = when {
                animKey == 0 -> 0.5
                s.anim == Anim.PACK_FLEE -> 0.6
                else -> 0.0
            }
            if (howls && !enemyGone && BattleClock.random.nextDouble() < chance) {
                howlStart = BattleClock.now()
                howlSound = listOf(Sound.HOWL_1, Sound.HOWL_2, Sound.HOWL_3).random(BattleClock.random)
                howlKey++
            }
            animKey++
        }
    }
}

@Composable
fun BattleScreen(vm: GameViewModel, game: Game, battle: Battle) {
    vm.tick
    val lang = vm.lang
    BattlePace.set(vm.battleTempo)
    val ui = remember(battle) { BattleUi(battle) }
    val step = ui.current
    var revealed by remember(step) { mutableIntStateOf(0) }
    // a killing blow shows no words of its own: the move runs straight on into the fall, and its words come at the
    // end (in the victory field, or before "… collapses")
    val silent = step != null && !step.lead && step.anim != Anim.ENEMY_FAINT && step.anim != Anim.HERO_FAINT &&
        ui.queue.firstOrNull()?.anim.let { it == Anim.ENEMY_FAINT || it == Anim.HERO_FAINT }
    /** The words shown for a message: the hero's fall comes with the words of the blow that felled it. */
    fun words(st: Step): String = if (st.anim == Anim.HERO_FAINT) listOfNotNull(ui.killWords, st.text).joinToString(" ") else st.text
    val textDone = step == null || revealed >= words(step).length

    /** On to the next message; a fall is not cut short, it plays out first. */
    fun goOn() {
        if (ui.falling) return
        ui.next()
        if (ui.current == null && battle.outcome != Outcome.ONGOING) {
            game.endBattle()
            vm.refresh()
        }
    }

    fun advance() {
        if (step != null && !textDone) {
            revealed = words(step).length
            return
        }
        // a fall is not cut short: it plays out before the next message
        if (ui.falling) return
        ui.next()
        if (ui.current == null && battle.outcome != Outcome.ONGOING) {
            game.endBattle()
            vm.refresh()
        }
    }

    LaunchedEffect(step) {
        if (step == null) return@LaunchedEffect
        if (step.lead) {
            // a lead-in has no words of its own: the move starts at once, and its end (the hit or the miss, with all
            // the words) follows by itself as soon as the wind-up is done
            revealed = step.text.length
            val m = ui.motion
            val wait = if (step.anim in HERO_LEADS && m != null) (m.end - BattleClock.now()).coerceAtLeast(0L)
                else if (step.anim == Anim.ENEMY_ACT) (foeTiming(battle, ui.attackVariant)?.windMs ?: WINDUP_MS).toLong() else WINDUP_MS.toLong()
            pause(wait + 40L)
            while (ui.falling) pause(50L)
            if (ui.current === step) goOn()
            return@LaunchedEffect
        }
        // the foe struck dead: it falls and lies there, the hero takes up its victory pose, then the spoils in one field
        if (step.anim == Anim.ENEMY_FAINT) {
            revealed = step.text.length
            pause(250L)
            while (ui.falling) pause(50L)
            pause(if (MonsterArt.isSolid(battle.monster.id)) 250L else 700L)
            ui.victory()
            val m = ui.motion
            pause(((m?.let { it.end - BattleClock.now() }) ?: 0L).coerceIn(0L, 2500L) + 200L)
            if (ui.current === step) {
                ui.openPanels(lang)
                ui.panels.firstOrNull()?.lines?.let { lines -> vm.play(if (lines.any { (it.rarity ?: de.bornim.core.Rarity.COMMON) >= de.bornim.core.Rarity.EPIC }) Sound.LOOT_EPIC else if (lines.any { it.anim == Anim.LOOT }) Sound.LOOT else Sound.COINS) }
            }
            return@LaunchedEffect
        }
        if (silent) {
            revealed = step.text.length
            ui.killWords = step.text
            // the blow or the spell lands, the foe (or the hero) reels; then on into the fall
            val flight = step.fx?.let { if (it.kind in FLYING || it.past in FLYING) BattlePace.ms(260L) else 0L } ?: 0L
            pause(ui.fxDelay + flight + REACT_MS.toLong() + 150L)
            while (ui.falling) pause(50L)
            if (ui.current === step) goOn()
            return@LaunchedEffect
        }
        // the hero struck down: the words come once it lies on the ground
        if (step.anim == Anim.HERO_FAINT) {
            // the fall may not have started yet when this step arrives
            var waited = 0L
            while (ui.motion?.act != HeroFigure.Act.DIE && waited < 1000L) { pause(30L); waited += 30L }
            val m = ui.motion
            pause(((m?.let { it.end - BattleClock.now() }) ?: 0L).coerceIn(0L, 3000L) + 300L)
        }
        val tempo = vm.battleTempo
        val perChar = when (tempo) { 0 -> 22L; 2 -> 9L; else -> 15L }
        // the words of an action come once it lands: the blow struck, the spell or flask arrived
        if (ui.afterLead) pause(160L + ui.fxDelay + (step.fx?.let { if (it.kind in FLYING || it.past in FLYING) BattlePace.ms(260L) else 0L } ?: 0L))
        val shown = words(step)
        // as many letters as the time allows, whatever the frame rate (a wait is at least one frame)
        val typing = BattleClock.now()
        while (revealed < shown.length) {
            pause(perChar)
            revealed = minOf(shown.length, maxOf(revealed + 1, ((BattleClock.now() - typing) / perChar).toInt()))
        }
        // each line waits for a tap, unless the fight is set to go on by itself: then after a pause to read, a tap
        // going on at once. The hero's fall always waits for a tap (the spoils of a won fight wait in their own field).
        if (!vm.battleAuto || step.anim == Anim.HERO_FAINT) return@LaunchedEffect
        val read = when (tempo) { 0 -> 1500L + 28L * step.text.length; 2 -> 500L + 9L * step.text.length; else -> 950L + 18L * step.text.length }
        pause(read)
        while (ui.falling) pause(50L)
        if (ui.current === step) goOn()
    }

    fun act(action: Action) {
        ui.menu = BattleMenu.MAIN
        ui.push(battle.act(action))
        vm.refresh()
    }

    BackHandler { if (ui.menu != BattleMenu.MAIN) ui.menu = BattleMenu.MAIN }

    // the preview's battle films act straight away, without tapping through the menus
    LaunchedEffect(vm.testAction, ui.current, ui.panels) {
        val a = vm.testAction ?: return@LaunchedEffect
        if (ui.current == null && ui.panels.isEmpty() && battle.outcome == Outcome.ONGOING) { pause(300); vm.testAction = null; act(a) }
    }

    // Idle animation: monster and hero breathe in a slow loop of frames.
    var idle by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) {
        while (true) {
            pause(230)
            idle++
        }
    }

    // Hit animations
    val shake = remember { Animatable(0f) }
    // a hit: the one struck darkens towards blood red for a moment, and a critical one shakes the scene
    val hurtGlow = remember { Animatable(0f) }
    var hitOnHero by remember { mutableStateOf(false) }
    val quake = remember { Animatable(0f) }
    var quakeK by remember { androidx.compose.runtime.mutableFloatStateOf(1f) }
    // the killing blow: the scene draws in on hero and foe while it is wound up, and back once it is done
    val killZoom = remember { Animatable(0f) }
    LaunchedEffect(ui.killStep) { if (ui.killStep != null) killZoom.animateTo(1f, tween(BattlePace.ms(550), easing = androidx.compose.animation.core.FastOutSlowInEasing)) }
    LaunchedEffect(ui.killAt) {
        if (ui.killAt == 0L) return@LaunchedEffect
        pause(BattlePace.ms(1800L))
        killZoom.animateTo(0f, tween(BattlePace.ms(700), easing = androidx.compose.animation.core.FastOutSlowInEasing))
    }
    // what the killing blow will do to the foe, cut out ahead while the hero winds up
    var killPlan by remember { mutableStateOf<de.bornim.core.art.KillPlan?>(null) }
    LaunchedEffect(ui.killStep) {
        val k = ui.killStep ?: return@LaunchedEffect
        if (!MonsterArt.isSolid(battle.monster.id)) return@LaunchedEffect
        killPlan = offMain {
            de.bornim.core.art.KillPlan.of(battle.monster.id, battle.look, ui.killStrike, vm.bloodLevel, battle.look.seed * 31 + k.enemyHp)
        }
    }
    // the blood of a hit flies as the blow lands, not as the message begins
    var bloodKey by remember { mutableIntStateOf(0) }
    val bloodT = remember { Animatable(1f) }
    val intro = remember(battle) { Animatable(1f) }
    LaunchedEffect(battle) { intro.animateTo(0f, tween(BattlePace.ms(600))) }
    LaunchedEffect(ui.howlKey) {
        if (ui.howlKey == 0) return@LaunchedEffect
        // the sound starts once the head is raised
        pause(HOWL_RAISE_MS)
        vm.play(ui.howlSound)
    }
    // the swish of a blow, as the weapon comes down: heavier for great weapons and hammers
    LaunchedEffect(ui.swingKey) {
        if (ui.swingKey == 0) return@LaunchedEffect
        pause(ui.swingDelay)
        val w = battle.hero.item(de.bornim.core.GearSlot.MAIN_HAND)?.def
        val heavy = w != null && (w.twoHanded || w.icon == de.bornim.core.Icon.HAMMER || w.icon == de.bornim.core.Icon.MACE)
        vm.play(if (heavy) Sound.SWING_HEAVY else Sound.SWING)
    }
    // the message whose motion [shake] runs: until its effect has started, a new message's motion stands at 0, not at
    // the end of the last one (else its last picture shows for a moment before it starts)
    var shakeFor by remember { mutableIntStateOf(-1) }
    LaunchedEffect(ui.animKey) {
        // a new-style foe's blow on the hero: where it lands, a moment into the message
        val lands = ui.current?.let { foeBlowLands(battle, ui.attackVariant, it) }
        // the sound of a blow that halts as it lands comes with the blow
        if (!ui.hitStopped && lands == null) ui.current?.let { st -> soundFor(st)?.let { vm.play(it) } }
        shake.snapTo(0f)
        shakeFor = ui.animKey
        // the blow lands: the one struck darkens towards blood red, fading; a critical one shakes the scene
        fun landed(onHero: Boolean) {
            hitOnHero = onHero
            bloodKey++
            launch { bloodT.snapTo(0f); bloodT.animateTo(1f, tween(bloodMs(vm.bloodLevel), easing = androidx.compose.animation.core.LinearEasing)) }
            launch { hurtGlow.snapTo(1f); hurtGlow.animateTo(0f, tween(BattlePace.ms(320))) }
            // the killing blow: it strikes home now; the scene shakes harder and longer
            val kill = !onHero && ui.current != null && ui.current === ui.killStep
            if (kill) ui.killAt = BattleClock.now()
            if (!onHero) ui.woundHp = ui.enemyHp
            quakeK = if (kill) 1.8f else 1f
            if (ui.current?.fx?.crit == true) launch { quake.snapTo(1f); quake.animateTo(0f, tween(BattlePace.ms(if (kill) 650 else 420), easing = androidx.compose.animation.core.LinearEasing)) }
        }
        // Projectiles first have to fly; the target reacts when they arrive.
        val flight = when (ui.current?.fx?.let { f -> f.past?.takeIf { it in FLYING && (f.kind == de.bornim.core.FxKind.DODGE || f.kind == de.bornim.core.FxKind.BLOCK) } ?: f.kind }) {
            de.bornim.core.FxKind.FIRE_BOLT, de.bornim.core.FxKind.MISSILES, de.bornim.core.FxKind.ARROW,
            de.bornim.core.FxKind.BOMB_FIRE, de.bornim.core.FxKind.BOMB_HOLY -> 0.5f
            de.bornim.core.FxKind.FIREBALL -> 0.45f
            else -> 0f
        }
        if (ui.hitStopped) {
            // the hero's blow comes down, lands with its sound and halts there; the foe reels after the halt
            pause((ui.fxDelay - ui.stopMs).coerceAtLeast(0L))
            ui.current?.let { st -> soundFor(st)?.let { vm.play(it) } }
            landed(false)
            pause(ui.stopMs)
        } else if (ui.fxDelay > 0) pause(ui.fxDelay)
        if (flight > 0f) pause((fxDuration(ui.current!!.fx!!.kind) * flight).toLong())
        // a foe built in the round falls only once its fall is drawn: the killing blow waits for the first frames of it,
        // the defeat for all of them (drawn now if the background has not got to them yet), so it never just stands and fades
        val foeId = battle.monster.id
        val cur = ui.current
        val fall = cur != null && cur.anim == Anim.ENEMY_FAINT && MonsterArt.isSolid(foeId)
        if (fall) ui.falling = true
        try {
            if (cur != null && MonsterArt.isSolid(foeId) && !ui.foeFled && (cur.anim == Anim.ENEMY_FAINT || (cur.anim == Anim.ENEMY_HIT && cur.enemyHp <= 0))) {
                val dieV = MonsterArt.dieVariant(foeId, battle.look)
                val n = MonsterArt.frameCount(foeId, battle.look, Act.DIE, dieV)
                val upTo = if (cur.anim == Anim.ENEMY_FAINT) n - 1 else DIE_REEL.coerceAtMost(n - 1)
                offMain {
                    for (i in 0..upTo) MonsterArt.battleFrame(foeId, battle.look, Act.DIE, dieV, i)
                }
            }
            val an = ui.current?.anim
            // a new-style foe's blow on the hero and its way back: evenly through its frames, as the hero's moves run
            fun foeBlow(an: Anim?) = (an == Anim.HERO_HIT || an == Anim.MISS) && ui.current?.fx?.onHero == true && !ui.current.isTick() &&
                (ui.current?.packActor ?: -1) < 0 && foeTiming(battle, ui.attackVariant) != null
            // any other hit lands as the message's motion begins (a shot or spell once it has flown); a fall bleeds as it starts
            if (an == Anim.HERO_FAINT || an == Anim.ENEMY_FAINT) {
                bloodKey++
                launch { bloodT.snapTo(0f); bloodT.animateTo(1f, tween(bloodMs(vm.bloodLevel), easing = androidx.compose.animation.core.LinearEasing)) }
            }
            if (lands == null && !ui.hitStopped && ui.current?.fx != null &&
                ((an == Anim.ENEMY_HIT && ui.current?.fx?.onHero == false) || (an == Anim.HERO_HIT && ui.current?.fx?.onHero == true))) landed(an == Anim.HERO_HIT)
            if (lands != null && an == Anim.HERO_HIT) {
                // the foe's blow comes down evenly, lands with its sound and halts there; then the hero flinches and the
                // foe goes back
                val total = foeLandMs(battle, ui.attackVariant, an)
                shake.animateTo((lands.toFloat() / total).coerceIn(0.05f, 1f), tween(lands.toInt(), easing = androidx.compose.animation.core.LinearEasing))
                ui.current?.let { st -> soundFor(st)?.let { vm.play(it) } }
                landed(true)
                pause(HIT_STOP_MS)
                shake.animateTo(1f, tween((total - lands.toInt()).coerceAtLeast(1), easing = androidx.compose.animation.core.LinearEasing))
            } else when (an) {
                Anim.ENEMY_HIT, Anim.HERO_HIT, Anim.SPELL, Anim.LEVEL_UP, Anim.ENEMY_FAINT, Anim.HERO_FAINT, Anim.LOOT, Anim.MISS ->
                    // a foe on the doll takes its time to fall before it fades
                    shake.animateTo(1f, tween(when {
                        an == Anim.ENEMY_FAINT && MonsterArt.isSolid(battle.monster.id) -> BattlePace.ms(1400)
                        an == Anim.ENEMY_FAINT || an == Anim.HERO_FAINT -> BattlePace.ms(700)
                        // being struck, ducking aside and the step back after a blow are taken at ease
                        // the foe's own blow on the hero and its way back, at its own pace
                        foeBlow(an) -> foeLandMs(battle, ui.attackVariant, an)
                        an == Anim.ENEMY_HIT || an == Anim.HERO_HIT || an == Anim.MISS -> REACT_MS
                        else -> BattlePace.ms(450)
                    }, easing = if (foeBlow(an)) androidx.compose.animation.core.LinearEasing else androidx.compose.animation.core.FastOutSlowInEasing))
                // a new-style foe's wind-up runs evenly through its frames, as the hero's does (its frames ease by themselves)
                Anim.ENEMY_ACT -> foeTiming(battle, ui.attackVariant)?.let { shake.animateTo(1f, tween(it.windMs, easing = androidx.compose.animation.core.LinearEasing)) }
                    ?: shake.animateTo(1f, tween(WINDUP_MS))
                Anim.HERO_ACT, Anim.PACK_ACT -> shake.animateTo(1f, tween(WINDUP_MS))
                // a foe's spell let go on the hero (a curse): it lands like a blow
                else -> if (ui.foeCastLands) shake.animateTo(1f, tween(REACT_MS))
            }
        } finally {
            if (fall) ui.falling = false
        }
    }
    val a = step?.anim
    val t = if (shakeFor == ui.animKey) shake.value else 0f

    Column(Modifier.fillMaxSize().background(Colors.night)) {
        // --- Scene
        BoxWithConstraints(
            Modifier
                .fillMaxWidth()
                .weight(1f)
                .tap { advance() }
                // a critical hit shakes the scene, a little larger so its edges never show
                .graphicsLayer {
                    val q = quake.value
                    val z = 1f + 0.13f * killZoom.value
                    if (q > 0f) {
                        translationX = sin(q * 47f) * q * 6.dp.toPx() * quakeK
                        translationY = kotlin.math.cos(q * 31f) * q * 4.dp.toPx() * quakeK
                    }
                    val sc = (1f + 0.035f * q * quakeK) * z
                    if (sc != 1f) {
                        scaleX = sc; scaleY = sc
                        // towards the two of them, between hero and foe
                        transformOrigin = androidx.compose.ui.graphics.TransformOrigin((de.bornim.core.art.BattleScene.HERO_X + de.bornim.core.art.BattleScene.FOE_X) / 2f, 0.72f)
                    }
                }
        ) {
            val sceneW = maxWidth
            val sceneH = maxHeight
            val fx = step?.fx
            // the hero's own start, hop or shake under a foe's blow keeps its usual time, however long the foe takes to
            // go back after it
            val lands = step?.let { foeBlowLands(battle, ui.attackVariant, it) }
            val heroT = when {
                // struck by a new-style foe's blow: from where it lands, after the halt there
                lands != null -> if (t >= 0.99f) 1f else ((t * foeLandMs(battle, ui.attackVariant, a) - lands) / REACT_MS).coerceIn(0f, 1f)
                (a == Anim.HERO_HIT || a == Anim.MISS) && fx?.onHero == true && !step.isTick() && (step?.packActor ?: -1) < 0 ->
                    (t * foeLandMs(battle, ui.attackVariant, a) / REACT_MS).coerceAtMost(1f)
                else -> t
            }
            // A dodging target hops aside.
            fun dodge(onHero: Boolean): androidx.compose.ui.unit.Dp {
                val t = if (onHero) heroT else t
                if (fx?.kind != de.bornim.core.FxKind.DODGE || fx.onHero != onHero || t !in 0.01f..0.99f) return 0.dp
                val side = if (fx.seed % 2 == 0) 1 else -1
                return (sin(t * Math.PI.toFloat()) * 26 * side).dp
            }
            val light = when {
                game.daylight < 0.35f -> BattleArt.Light.NIGHT
                game.daylight < 0.85f -> BattleArt.Light.DUSK
                else -> BattleArt.Light.DAY
            }
            // Forest and cave fights use the new scenes: ground with depth, places, times of day or lights.
            val forest = game.map.kind == MapKind.FOREST
            val cave = game.map.kind == MapKind.CAVE
            val newScene = forest || cave
            val place = game.state.place
            val caveSpot = remember(battle) { if (cave) CaveScene.spotFor(game.map, place.x, place.y) else CaveScene.Spot.HALL }
            val caveLight = remember(battle) { if (cave) CaveScene.lightFor(game.map, place.x, place.y, caveSpot) else CaveScene.Light.TORCH }
            val spot = remember(battle) { BattleScene.spotFor(game.map, place.x, place.y) }
            val sceneSeed = remember(battle) { BattleScene.seedFor(place.x, place.y) }
            val sceneLight = when (light) {
                BattleArt.Light.NIGHT -> BattleScene.Light.NIGHT
                BattleArt.Light.DUSK -> BattleScene.Light.DUSK
                else -> BattleScene.Light.DAY
            }
            val density = androidx.compose.ui.platform.LocalDensity.current
            val sceneScale = with(density) { maxOf(1, kotlin.math.round(sceneW.toPx() / BattleScene.DESIGN_W).toInt()) }
            /** Size of one art pixel of the new scenes, in dp. */
            val artDp = with(density) { sceneScale.toDp() }
            if (forest) ForestBackground(spot, sceneLight, game.map.id == "deep_forest", sceneSeed, sceneScale, Modifier.matchParentSize())
            else if (cave) CaveBackground(caveSpot, caveLight, sceneSeed, light == BattleArt.Light.NIGHT, sceneScale, Modifier.matchParentSize())
            else BattleBackground(game.map.kind, light, Modifier.matchParentSize())
            val foeX = if (newScene) BattleScene.FOE_X else BattleArt.ENEMY_X
            val foeY = if (newScene) BattleScene.FOE_Y else BattleArt.ENEMY_Y
            val heroX = if (newScene) BattleScene.HERO_X else BattleArt.HERO_X
            val heroY = if (newScene) BattleScene.HERO_Y else BattleArt.HERO_Y
            // Monsters and hero stand in the light of the place.
            val shade = when {
                cave -> Color(CaveScene.tint(caveSpot, caveLight, light == BattleArt.Light.NIGHT))
                light == BattleArt.Light.NIGHT -> Color(0xFF9CA6D4)
                light == BattleArt.Light.DUSK -> Color(0xFFF4D2C4)
                else -> null
            }

            val moving = t in 0.01f..0.99f
            // the foe struck: darkened towards blood red, fading
            val foeRed = if (!hitOnHero) hurtGlow.value else 0f
            val lunge = if (moving) sin(t * Math.PI.toFloat()) else 0f

            // Enemy
            val newStyle = MonsterArt.isNewStyle(battle.monster.id)
            val monsterSize = if (battle.monster.boss) 212.dp else 184.dp
            // foes built in the round (on the doll, or wolves) fall in their own way first, then fade; the others fade as they sink
            val dollFoe = MonsterArt.isSolid(battle.monster.id)
            // a turned foe shrinks back from the holy light, draws off into the distance and is gone
            val fleeT = if (ui.foeFled) (if (a == Anim.ENEMY_FAINT) t else 1f) else 0f
            // a destroyed one: it reels, glows white from within and crumbles away
            val crumbleT = if (ui.foeDestroyed) (if (a == Anim.ENEMY_FAINT) t else 1f) else 0f
            val enemyAlpha = when {
                ui.foeFled -> 1f - ((fleeT - 0.3f) / 0.7f).coerceIn(0f, 1f)
                ui.foeDestroyed -> 1f - ((crumbleT - 0.4f) / 0.45f).coerceIn(0f, 1f)
                // foes built in the round fall and stay lying there; the others still fade as they sink
                a == Anim.ENEMY_FAINT -> if (dollFoe) 1f else 1f - t
                ui.enemyGone -> if (dollFoe) 1f else 0f
                else -> 1f
            }
            // the foe's own blow landing on the hero, or missing: the second half of its attack
            // (poison, burning or bleeding eating at the hero is no blow: the foe stays where it is)
            val foeLanding = (a == Anim.HERO_HIT || a == Anim.MISS || a == Anim.HERO_FAINT || ui.foeCastLands) && fx?.onHero == true && !step.isTick() && (step?.packActor ?: -1) < 0
            // how long the foe's blow and way back run, and which share of it the blow takes: it lands as fast as ever
            val foeLandMs = if (ui.foeCastLands && a != Anim.HERO_HIT && a != Anim.MISS && a != Anim.HERO_FAINT) REACT_MS else foeLandMs(battle, ui.attackVariant, a)
            val blowShare = ((foeTiming(battle, ui.attackVariant)?.blowMs ?: BLOW_MS).toFloat() / foeLandMs).coerceIn(0.05f, 1f)
            // old-style foes, like the hero: while the attack is named they leap in and stay poised, then strike and
            // spring back with the hit or the miss
            val leap = if (t >= 0.99f) 1f else (t * t * (3 - 2 * t))
            // wound up and waiting for the blow through a word in between: held where the wind-up ended
            val poised = ui.foePoised && a == Anim.NONE
            val foeIn = when {
                a == Anim.ENEMY_ACT -> leap
                poised -> 1f
                foeLanding -> 1f - leap
                else -> 0f
            }
            val enemyPose = when {
                a == Anim.ENEMY_ACT || poised -> Pose.ATTACK
                foeLanding && t < 0.5f -> Pose.ATTACK
                (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> Pose.HURT
                else -> Pose.IDLE
            }
            // New-style monsters play whole sequences: wind-up while attacking, the rest while the hit shows.
            val id = battle.monster.id
            val variant = ui.attackVariant
            // How badly the foe is hurt: 1 below half its hit points, 2 below a quarter.
            val foeWound = when {
                ui.woundHp * 4 <= battle.enemyMaxHp -> 2
                ui.woundHp * 2 <= battle.enemyMaxHp -> 1
                else -> 0
            }
            // How much of it shows, for foe and hero alike: nothing with blood off, a few stains when subtle, all of them in full
            val woundCap = vm.bloodLevel.coerceIn(0, 2)
            val foeStains = minOf(foeWound, woundCap)
            // Overlays (wounds, glow, sheen) stay while the foe sinks down and fade with it.
            val foeShown = !ui.enemyGone || a == Anim.ENEMY_FAINT || MonsterArt.isSolid(battle.monster.id)
            // Hurt monsters breathe faster. New-style monsters have many more idle frames, shown faster.
            val clockMs = pulseClock()
            // stunned: the body sways, dazed; slowed: its breathing and shifting run slower
            val foeSway = if (de.bornim.core.Status.STUN in ui.foeStatus && !ui.enemyGone) (sin(clockMs / 380f) * 3.5f).dp else 0.dp
            val heroSway = if (de.bornim.core.Status.STUN in ui.heroStatus && !ui.heroGone) (sin(clockMs / 410f + 1f) * 3.5f).dp else 0.dp
            val foeSlow = if (de.bornim.core.Status.SLOW in ui.foeStatus) 1.8 else 1.0
            val idleIdx = (clockMs / ((if (newStyle) 86 else 230) * foeSlow / (1 + 0.6 * foeWound))).toInt()
            // Draw all frames ahead in the background: at the start, and again once the foe is badly hurt.
            LaunchedEffect(battle, foeWound) {
                offMain {
                    MonsterArt.prepare(id, battle.look, foeWound)
                    battle.trait?.let { tr ->
                        if (newStyle) for (act in Act.entries) for (v in 0 until (if (act == Act.ATTACK) MonsterArt.attackVariants(id) else if (act == Act.IDLE || act == Act.HOWL) 1 else MonsterArt.reactVariants(id)))
                            for (i in 0 until MonsterArt.frameCount(id, battle.look, act, v)) {
                                val f = MonsterArt.battleFrame(id, battle.look, act, v, i, foeWound)
                                Glow.halo(f, tr.color and 0xFFFFFF); Glow.rim(f, tr.color and 0xFFFFFF)
                            }
                    }
                    battle.pack?.let { pk -> for (i in 0 until battle.packSize) MonsterArt.prepare(pk.mate, MonsterLook(battle.look.seed + 101 * (i + 1))) }
                }
            }
            val howling = ui.howlKey > 0 && !ui.enemyGone && BattleClock.now() - ui.howlStart < HOWL_MS
            // the leader's own blow: wound up while it is named, then struck with the hit or the miss. A foe on the doll
            // holds its wind-up two frames short of the blow, so the blow itself comes with the result, as the hero's does.
            val foeStrike = if (newStyle) MonsterArt.strikeFrame(id, battle.look, variant) else 0
            val foeN = if (newStyle) MonsterArt.frameCount(id, battle.look, Act.ATTACK, variant) else 0
            val windEnd = if (dollFoe) (foeStrike - 2).coerceAtLeast(0) else foeStrike
            fun span(from: Int, to: Int) = from + ((to - from + 1) * t).toInt().coerceAtMost(to - from)
            // a foe that shoots or casts from where it stands, rather than stepping in with a blow
            val shoots = dollFoe && MonsterArt.isDoll(id) && !de.bornim.core.art.FoeArt.lunges(id, battle.look, variant)
            fun releaseIdx(): Int {
                val per = ((foeTiming(battle, variant)?.blowMs ?: BLOW_MS) / (foeStrike - windEnd + 1).coerceAtLeast(1)).coerceAtLeast(1)
                // read with the clock, so the frames go on while nothing else changes
                val since = if (clockMs >= 0) BattleClock.now() - ui.stepAt else 0L
                return windEnd + (since / per).toInt().coerceIn(0, foeStrike - windEnd)
            }
            val foeAttackIdx: Int? = when {
                !newStyle -> null
                a == Anim.ENEMY_ACT -> span(0, windEnd)
                poised -> windEnd
                // a shot or a spell: let go as the message comes up (timed from it, as it may fly before the rest
                // moves), held in the release, then the way back
                foeLanding && moving && shoots -> if (t < blowShare) releaseIdx()
                    else foeStrike + ((foeN - foeStrike) * (t - blowShare) / (1 - blowShare)).toInt().coerceIn(0, foeN - 1 - foeStrike)
                foeLanding && moving -> {
                    // the blow lands as fast as ever; only the way back takes the longer time
                    val q = blowShare
                    if (t < q) windEnd + ((foeStrike - windEnd + 1) * t / q).toInt().coerceAtMost(foeStrike - windEnd)
                    else foeStrike + ((foeN - foeStrike) * (t - q) / (1 - q)).toInt().coerceIn(0, foeN - 1 - foeStrike)
                }
                // an arrow, bolt or curse in flight: it is let go at once, the bow string or the staff or hand coming
                // through to the release as it leaves, before it arrives
                foeLanding && t < 0.01f && shoots -> releaseIdx()
                // the blow not begun yet: still poised in the wind-up, not back at rest
                foeLanding && t < 0.01f -> windEnd
                else -> null
            }
            // the same between two frames, for the step in, which glides rather than jumping frame by frame
            val foeAttackPos: Double? = when {
                foeAttackIdx == null -> null
                a == Anim.ENEMY_ACT -> windEnd * t.toDouble()
                foeLanding && moving -> {
                    val q = blowShare
                    if (t < q) windEnd + (foeStrike - windEnd) * (t / q).toDouble()
                    else foeStrike + (foeN - 1 - foeStrike) * ((t - q) / (1 - q)).toDouble()
                }
                else -> foeAttackIdx.toDouble()
            }
            val enemyFrame = if (!newStyle) null else {
                fun seq(act: Act, from: Int, to: Int, v: Int = variant) = MonsterArt.shownFrame(id, battle.look, act, v, from + ((to - from + 1) * t).toInt().coerceAtMost(to - from), foeWound)
                val strike = foeStrike
                val n = foeN
                // being hit, dodging and falling come in variants too, taken in turn
                val react = ui.reactVariant.mod(MonsterArt.reactVariants(id))
                fun whole(act: Act) = seq(act, 0, MonsterArt.frameCount(id, battle.look, act, react) - 1, react)
                // one fall for this foe, begun with the killing blow (it reels) and ended with its defeat (it goes down)
                val dieV = MonsterArt.dieVariant(id, battle.look)
                val dieLast = MonsterArt.frameCount(id, battle.look, Act.DIE, dieV) - 1
                val reel = DIE_REEL.coerceAtMost(dieLast)
                when {
                    // the wind-up, held poised until the blow lands with the next message; then the blow
                    foeAttackIdx != null -> MonsterArt.shownFrame(id, battle.look, Act.ATTACK, variant, foeAttackIdx, foeWound)
                    // struck down: it reels with the blow and stays reeling through any further word, never getting up again
                    // (each message's motion starts at 0 and may wait, for a spell to be let go: until it starts, the picture
                    // stays where the last one left it, so nothing jumps ahead to the end and back)
                    dollFoe && ui.enemyHp <= 0 && a != Anim.ENEMY_FAINT && !ui.enemyGone -> when {
                        a != Anim.ENEMY_HIT || t >= 0.99f -> seq(Act.DIE, reel, reel, dieV)
                        t < 0.01f -> seq(Act.DIE, 0, 0, dieV)
                        else -> seq(Act.DIE, 0, reel, dieV)
                    }
                    // lying dead where it fell, to the end of the fight
                    dollFoe && ui.enemyGone && a != Anim.ENEMY_FAINT -> seq(Act.DIE, dieLast, dieLast, dieV)
                    // falling: from the reel on to the ground (from the start if nothing struck it down first), then held while it fades
                    ui.foeDestroyed -> if (a == Anim.ENEMY_FAINT && moving) (if (dollFoe) seq(Act.DIE, 0, reel, dieV) else whole(Act.HURT))
                        else MonsterArt.shownFrame(id, battle.look, Act.IDLE, 0, 0, foeWound)
                    ui.foeFled -> if (a == Anim.ENEMY_FAINT && moving) whole(Act.DODGE)
                        else MonsterArt.shownFrame(id, battle.look, Act.IDLE, 0, idleIdx % MonsterArt.frameCount(id, battle.look, Act.IDLE, 0), foeWound)
                    a == Anim.ENEMY_FAINT && dollFoe -> {
                        val from = reel
                        when {
                            t >= 0.99f -> seq(Act.DIE, dieLast, dieLast, dieV)
                            t < 0.01f -> seq(Act.DIE, from, from, dieV)
                            else -> seq(Act.DIE, from, dieLast, dieV)
                        }
                    }
                    // a blow or a spell turned aside: the foe ducks, steps back or springs aside, or takes it on its shield
                    a == Anim.MISS && fx?.onHero == false && dollFoe && moving -> whole(Act.DODGE)
                    (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> if (dollFoe) whole(Act.HURT) else seq(Act.HURT, 0, MonsterArt.frameCount(id, Act.HURT, 0) - 1)
                    howling -> {
                        val n = MonsterArt.frameCount(id, Act.HOWL, 0)
                        val since = BattleClock.now() - ui.howlStart
                        // raise the head, hold the howl, lower it again
                        val i = when {
                            since < HOWL_RAISE_MS -> (since * 4 / HOWL_RAISE_MS).toInt()
                            since < HOWL_MS - 150 -> 4 + ((since - HOWL_RAISE_MS) * 6 / (HOWL_MS - 150 - HOWL_RAISE_MS)).toInt()
                            else -> n - 1
                        }
                        MonsterArt.shownFrame(id, battle.look, Act.HOWL, 0, i.coerceIn(0, n - 1), foeWound)
                    }
                    else -> MonsterArt.shownFrame(id, battle.look, Act.IDLE, 0, idleIdx % MonsterArt.frameCount(id, battle.look, Act.IDLE, 0), foeWound)
                }
            }
            val enemyDx = when {
                newStyle -> 0.dp
                a == Anim.ENEMY_HIT -> (lunge * 10 * (1 - t)).dp
                else -> -(foeIn * 30).dp
            }
            val enemyDy = if (!newStyle) (foeIn * 16).dp else 0.dp
            /** How wide the foe's body is (a doll's picture is far wider than the doll), for its shadow, effects and the lunge. */
            val body = enemyFrame?.let { MonsterArt.bodySize(id, battle.look, it.width, it.height) }
            val foeW = if (body != null) artDp * body.first.toFloat() else monsterSize
            val foeH = if (enemyFrame != null) artDp * enemyFrame.height else monsterSize
            /** From the top of the picture down to the feet. */
            val foeFeet = if (enemyFrame != null) artDp * MonsterArt.groundLine(id).toFloat() else monsterSize * 0.94f
            /** How tall the foe stands above its feet. */
            val foeTall = if (body != null) artDp * body.second.toFloat() else foeFeet
            /** From the picture's left edge to the feet. */
            val foeAnchor = if (enemyFrame != null) artDp * MonsterArt.anchorX(id, enemyFrame.width).toFloat() else monsterSize / 2
            // Shadows on the ground instead of platforms
            Canvas(Modifier.matchParentSize()) {
                val gx = (sceneW * foeX).toPx(); val gy = (sceneH * foeY).toPx()
                if (foeShown) drawOval(Color.Black.copy(alpha = 0.32f * enemyAlpha), Offset(gx - foeW.toPx() * 0.36f, gy - 7.dp.toPx()), Size(foeW.toPx() * 0.72f, 12.dp.toPx()))
                val hx = (sceneW * heroX).toPx(); val hy = (sceneH * heroY).toPx()
                if (!ui.heroGone) drawOval(Color.Black.copy(alpha = 0.32f), Offset(hx - 70.dp.toPx(), hy - 10.dp.toPx()), Size(140.dp.toPx(), 18.dp.toPx()))
                // a bleeding body's pool lies here on the ground, where it stands, and stays when the body moves
                if (de.bornim.core.Status.BLEED in ui.foeStatus && !ui.enemyGone)
                    drawBloodPool(clockMs / 1000f, gx, gy, (if (newStyle) foeW / 90 else monsterSize / 64).toPx(), vm.bloodLevel)
                if (de.bornim.core.Status.BLEED in ui.heroStatus && !ui.heroGone)
                    drawBloodPool(clockMs / 1000f + 0.7f, hx, hy, (artDp * 78f / 70f).toPx(), vm.bloodLevel)
            }
            // Pack mates stand behind the leader, smaller, and jab when it is their turn.
            val fleeing = a == Anim.PACK_FLEE && moving
            val mateCount = if (fleeing) ui.packBefore else ui.pack
            val packDef = battle.pack
            /** Where the acting mate's arrow leaves its bow, so it flies from the mate and not from the leader. */
            var mateLaunch: androidx.compose.ui.unit.DpOffset? = null
            if (packDef != null) for (i in 0 until mateCount) {
                val acting = a == Anim.PACK_ACT && step?.packActor == i
                // the mate's own hit or miss right after its attack: the strike and the way back
                val landing = (a == Anim.HERO_HIT || a == Anim.MISS || a == Anim.HERO_FAINT) && step?.packActor == i && !step.isTick() && moving
                val mateIn = when { acting -> leap; landing -> 1f - leap; else -> 0f }
                val mateLook = MonsterLook(battle.look.seed + 101 * (i + 1))
                val mateNew = MonsterArt.isNewStyle(packDef.mate)
                val mateFrame = if (!mateNew) null else if (acting || landing) {
                    val n = MonsterArt.frameCount(packDef.mate, mateLook, Act.ATTACK, i)
                    val strike = MonsterArt.strikeFrame(packDef.mate, mateLook, i)
                    val (from, to) = if (acting) 0 to strike else strike to n - 1
                    MonsterArt.shownFrame(packDef.mate, mateLook, Act.ATTACK, i, from + ((to - from + 1) * t).toInt().coerceAtMost(to - from))
                } else MonsterArt.shownFrame(packDef.mate, mateLook, Act.IDLE, 0, (clockMs / 86 + 5 * i + 3).toInt() % MonsterArt.frameCount(packDef.mate, mateLook, Act.IDLE, 0))
                val mateSize = monsterSize * packDef.scale
                val mPx = artDp * packDef.scale
                val mateW = if (mateFrame != null) mPx * mateFrame.width else mateSize
                val mateAnchor = if (mateFrame != null) mPx * MonsterArt.anchorX(packDef.mate, mateFrame.width).toFloat() else mateSize / 2
                val mateFeet = if (mateFrame != null) mPx * MonsterArt.groundLine(packDef.mate).toFloat() else mateSize * 0.94f
                // A boss is big: its guards stand well to the left and just behind its shoulder,
                // so neither is hidden nor cut off by the screen edge.
                val boss = battle.monster.boss
                // New-style animals are wider, so their pack spreads out more and stands further back.
                val baseX = sceneW * foeX + when {
                    mateNew && i == 0 -> if (boss) (-150).dp else (-128).dp
                    mateNew -> if (boss) 96.dp else 78.dp
                    i == 0 -> if (boss) (-150).dp else (-86).dp
                    else -> if (boss) 24.dp else 56.dp
                }
                val baseY = sceneH * foeY - when {
                    mateNew && i == 0 -> if (boss) 22.dp else 30.dp
                    mateNew -> if (boss) 70.dp else 46.dp
                    i == 0 -> if (boss) 14.dp else 20.dp
                    else -> if (boss) 62.dp else 30.dp
                }
                if (step?.packActor == i && fx?.onHero == true) MonsterArt.launch(packDef.mate, mateLook, i)?.let { (lx, ly) ->
                    mateLaunch = androidx.compose.ui.unit.DpOffset(
                        baseX + (intro.value * 260).dp + mPx * (lx - MonsterArt.anchorX(packDef.mate, 0)).toFloat(),
                        baseY + mPx * (ly - MonsterArt.groundLine(packDef.mate)).toFloat(),
                    )
                }
                Box(
                    Modifier.offset(
                        // old-style mates leap in while their attack is named and spring back with the hit or the miss
                        x = baseX - mateAnchor + (intro.value * 260).dp + (if (!mateNew) -(mateIn * 26).dp else 0.dp) + (if (fleeing) (t * 140).dp else 0.dp),
                        y = baseY - mateFeet + (if (!mateNew) (mateIn * 12).dp else 0.dp),
                    )
                ) {
                    val mAlpha = (if (fleeing) 1f - t else 1f) * enemyAlphaBase(a, ui.enemyGone, t)
                    if (mateFrame != null) PixelSprite(mateFrame, mPx, alpha = mAlpha, shade = shade, overflow = true)
                    else PixelImageView(
                        MonsterArt.frame(packDef.mate, mateLook, if (acting || landing && t < 0.5f) Pose.ATTACK else Pose.IDLE, idle + i + 1),
                        mateSize, alpha = mAlpha, shade = shade,
                    )
                }
            }

            val glow = battle.trait?.let { Color(it.color) }
            // a foe on the doll steps in at the hero with its blow, so the weapon lands on the hero, and back again;
            // drawn larger as it comes nearer
            val foeLungeF = if (dollFoe && foeAttackIdx != null) {
                // while it is named it only starts the step; the rest comes with the blow
                // (held poised, it stays where the wind-up left it; the blow takes it on to the full step as it comes down)
                val q = blowShare
                val rest = if (foeLanding && moving) (t / q).coerceIn(0f, 1f).let { it * it * (3 - 2 * it) } else 0f
                MonsterArt.lungeAt(id, battle.look, variant, foeAttackPos!!).toFloat() * (if (a == Anim.ENEMY_ACT || poised || (foeLanding && !moving)) FOE_WIND_STEP else FOE_WIND_STEP + (1f - FOE_WIND_STEP) * rest)
            } else 0f
            val foeLunge = if (foeLungeF <= 0f || enemyFrame == null) androidx.compose.ui.unit.DpOffset.Zero else {
                val (ox, oy) = MonsterArt.lungeOffset(id, battle.look, variant, (sceneW * foeX / artDp).toDouble(), (sceneH * foeY / artDp).toDouble(),
                    (sceneW * heroX / artDp).toDouble() + 8.0, (sceneH * heroY / artDp).toDouble() - 82.0)
                androidx.compose.ui.unit.DpOffset(artDp * (ox * foeLungeF).toFloat(), artDp * (oy * foeLungeF).toFloat())
            }
            val foeScale = 1f + (MonsterArt.LUNGE_SCALE.toFloat() - 1f) * foeLungeF
            // Feet on the ground where the foe stands
            Box(
                Modifier.offset(
                    // a foe on the doll steps aside in its own frames rather than hopping
                    x = sceneW * foeX - foeAnchor + (intro.value * 260).dp + (if (dollFoe) 0.dp else dodge(false)) + enemyDx + foeLunge.x + (fleeT * fleeT * 70).dp + foeSway,
                    // old-style sprites sag a little when badly hurt; new ones change their posture
                    y = sceneH * foeY - foeFeet + enemyDy + (if (a == Anim.ENEMY_FAINT && !dollFoe && !ui.foeFled) (t * 40).dp else 0.dp) - (fleeT * fleeT * 46).dp + (crumbleT * crumbleT * 14).dp + (if (newStyle) 0.dp else (foeWound * 3).dp) + foeLunge.y,
                ).graphicsLayer {
                    val sc = foeScale * (1f - 0.35f * fleeT * fleeT)
                    if (sc != 1f && enemyFrame != null) {
                        scaleX = sc; scaleY = sc
                        transformOrigin = androidx.compose.ui.graphics.TransformOrigin((MonsterArt.anchorX(id, enemyFrame.width) / enemyFrame.width).toFloat(), (MonsterArt.groundLine(id) / enemyFrame.height).toFloat())
                    }
                }
            ) {
                val pulse = rememberPulse()
                val plan = killPlan
                // (read on every tick of the clock, so the pieces move)
                val killT = if (ui.killAt > 0L && plan != null) clockMs.let { killTime((BattleClock.now() - ui.killAt).toFloat()) } else -1f
                val inPieces = killT >= 0f && plan != null && plan.pieces.isNotEmpty()
                // New-style elites shimmer along their outline; the old sprites keep the round aura.
                if (glow != null && foeShown && enemyFrame != null && !inPieces) Box(Modifier.offset(x = -artDp * Glow.PAD, y = -artDp * Glow.PAD)) {
                    PixelSprite(Glow.halo(enemyFrame, battle.trait!!.color and 0xFFFFFF), artDp, alpha = enemyAlpha * (0.55f + 0.4f * pulse), overflow = true)
                } else if (glow != null && foeShown) EliteAura(glow, monsterSize, enemyAlpha)
                // struck dead by a killing blow: in pieces from the moment it lands, with what runs out of it
                if (killT >= 0f && plan != null && enemyFrame != null) Canvas(Modifier.wrapContentSize(androidx.compose.ui.Alignment.TopStart, unbounded = true).size(artDp * enemyFrame.width, artDp * enemyFrame.height)) {
                    drawKillGore(plan, killT, artDp.toPx(), vm.bloodLevel, goreFor(id), MonsterArt.anchorX(id, enemyFrame.width).toFloat(), battle.look.seed, behind = true)
                    if (inPieces) drawKillPieces(plan, killT, artDp.toPx(), shade)
                    drawKillGore(plan, killT, artDp.toPx(), vm.bloodLevel, goreFor(id), MonsterArt.anchorX(id, enemyFrame.width).toFloat(), battle.look.seed, behind = false)
                }
                // without blood it sinks down darkened
                val killDark = if (killT >= 0f && plan?.kind == de.bornim.core.art.KillArt.Kind.DARK) (killT / 500f).coerceIn(0f, 1f) else 0f
                val foeShade = if (killDark > 0f) (shade ?: Color.White).let { c -> Color(c.red * (1 - 0.45f * killDark), c.green * (1 - 0.45f * killDark), c.blue * (1 - 0.45f * killDark)) } else shade
                // a beast at full blood keeps its body, torn open along the blow, as it falls
                val shownFoe = if (killT >= 0f && plan?.kind == de.bornim.core.art.KillArt.Kind.WOUND && enemyFrame != null)
                    remember(enemyFrame) { de.bornim.core.art.KillArt.gash(enemyFrame, plan.cut, battle.look.seed) } else enemyFrame
                if (shownFoe != null && !inPieces) {
                    PixelSprite(
                        shownFoe, artDp, alpha = enemyAlpha,
                        flash = if (ui.foeDestroyed) (crumbleT * 2.2f).coerceAtMost(0.9f) else 0f, shade = foeShade, overflow = true, hurt = foeRed,
                    )
                    if (glow != null && foeShown && !inPieces) PixelSprite(Glow.rim(shownFoe, battle.trait!!.color and 0xFFFFFF), artDp, alpha = enemyAlpha * (0.22f + 0.18f * pulse), overflow = true)
                    if (foeStains > 0 && foeShown) PixelSprite(woundsOf(shownFoe, foeStains, id, battle.look.seed), artDp, alpha = enemyAlpha, shade = foeShade, overflow = true)
                    // a band of light wanders over a shimmering coat every few seconds
                    if (battle.shiny && foeShown) {
                        val steps = 12
                        val phase = ((pulseClock() / 120) % 30).toInt()
                        if (phase < steps) PixelSprite(Glow.sheen(shownFoe, phase, steps), artDp, alpha = enemyAlpha * 0.75f, overflow = true)
                    }
                } else if (enemyFrame == null) {
                    val img = MonsterArt.frame(battle.monster.id, battle.look, enemyPose, if (foeWound > 0) idleIdx else idle)
                    PixelImageView(img, monsterSize, alpha = enemyAlpha, flash = if (ui.foeDestroyed) (crumbleT * 2.2f).coerceAtMost(0.9f) else 0f, shade = shade, hurt = foeRed)
                    if (foeStains > 0 && foeShown) PixelImageView(woundsOf(img, foeStains, id, battle.look.seed), monsterSize, alpha = enemyAlpha, shade = shade)
                }
                if (battle.shiny && foeShown) {
                    // sparkles around the body: centre their square on the wide new-style sprite
                    // foes built in the round stand off-centre in a wide frame: the sparkles go round the body, about its feet
                    if (dollFoe) Box(Modifier.offset(x = foeAnchor - foeW * (if (MonsterArt.isBeast(id)) 0.58f else 0.5f), y = foeFeet - foeTall / 2 - foeW / 2)) { Sparkles(battle.look.seed, foeW, enemyAlpha) }
                    else if (newStyle) Box(Modifier.offset(y = (foeH - foeW) / 2 - foeH * 0.22f)) { Sparkles(battle.look.seed, foeW, enemyAlpha) }
                    else Sparkles(battle.look.seed, monsterSize, enemyAlpha)
                }
                // lasting statuses show on the body as long as they hold (flames, a sickly vapour, dripping blood, frost);
                // drawn in the foe's own frame, they go with it when it lunges, dodges or reels
                if (ui.foeStatus.isNotEmpty() && !ui.enemyGone) Canvas(Modifier.size(1.dp)) {
                    val chest = Offset(foeAnchor.toPx(), (foeFeet - (if (newStyle) foeTall * 0.55f else monsterSize * 0.45f)).toPx())
                    val u = (if (newStyle) foeW / 90 else monsterSize / 64).toPx()
                    for (st in ui.foeStatus.keys) drawStatus(st, clockMs / 1000f, chest, foeFeet.toPx(), u, vm.bloodLevel)
                }
            }
            // Hero (seen from behind)
            val heroAlpha = when {
                // the hero falls and lies where it fell
                a == Anim.HERO_FAINT -> 1f
                ui.heroGone -> 1f
                else -> 1f
            }
            // The hero is the doll, seen from behind over the shoulder, its frames drawn ahead in the background.
            // the hero bleeds like the foe: a few stains below half health, more below a quarter, as far as the blood setting shows
            val heroWound = minOf(woundCap, when {
                ui.heroHp * 4 <= battle.hero.maxHp -> 2
                ui.heroHp * 2 <= battle.hero.maxHp -> 1
                else -> 0
            })
            LaunchedEffect(battle, heroWound) {
                offMain {
                    val job = coroutineContext[kotlinx.coroutines.Job]
                    HeroBattle.prepare(battle.hero, battle.monster.id, battle.opening == de.bornim.core.Opening.AMBUSHED, ui.victoryPick, heroWound,
                        ui.motion?.takeIf { it.hold }?.let { Triple(it.act, it.strike, it.variant) }) { job?.isActive == false }
                }
            }
            val doll = heroDollFrame(ui, if (de.bornim.core.Status.SLOW in ui.heroStatus) (clockMs / 1.8).toLong() else clockMs, heroWound)
            val dollFrame = doll.first
            // a melee blow steps in towards the foe, so the weapon lands on it, and back again
            val lungeF = doll.second.toFloat()
            val lungeOff = if (lungeF <= 0f || ui.motion == null) androidx.compose.ui.unit.DpOffset.Zero
            // the old village and house scenes have their foe far off up the field: only a short step forward there
            else if (!newScene) androidx.compose.ui.unit.DpOffset((lungeF * 30).dp, -(lungeF * 16).dp)
            else {
                val aim = HeroBattle.aimAt((sceneW * foeX / artDp).toDouble(), (sceneH * foeY / artDp).toDouble(), (foeW / artDp).toDouble(), (foeTall / artDp).toDouble())
                val (ox, oy) = HeroBattle.lungeOffset(battle.hero, ui.motion!!.strike, (sceneW * heroX / artDp).toDouble(), (sceneH * heroY / artDp).toDouble(), aim.first, aim.second)
                androidx.compose.ui.unit.DpOffset(artDp * (ox * lungeF).toFloat(), artDp * (oy * lungeF).toFloat())
            }
            val lungeScale = if (newScene) 1f - (1f - HeroBattle.LUNGE_SCALE.toFloat()) * lungeF else 1f
            Box(
                Modifier
                    .offset(
                        x = sceneW * heroX - artDp * HeroBattle.ANCHOR_X.toFloat() - (intro.value * 260).dp + dodge(true) + lungeOff.x + heroSway,
                        y = sceneH * heroY - artDp * HeroBattle.GROUND.toFloat() + lungeOff.y,
                    )
                    .graphicsLayer {
                        scaleX = lungeScale; scaleY = lungeScale
                        transformOrigin = androidx.compose.ui.graphics.TransformOrigin((HeroBattle.ANCHOR_X / HeroBattle.W).toFloat(), (HeroBattle.GROUND / HeroBattle.H).toFloat())
                    }
            ) {
                PixelSprite(dollFrame, artDp, alpha = heroAlpha, shade = shade, hurt = if (hitOnHero) hurtGlow.value else 0f)
                // the killing blow drags a trail of blood red behind the weapon's point, through the foe and out
                ui.motion?.takeIf { it.act == HeroFigure.Act.ATTACK && it.strike.killing && !it.hold }?.let { km ->
                    val hit = HeroBattle.strikeFrame(km.strike)
                    val pos = clockMs.let { km.pos(BattleClock.now()) }
                    val sinceLand = if (ui.killAt > 0L) (BattleClock.now() - ui.killAt).toFloat() else 0f
                    val fade = 1f - (sinceLand / 500f).coerceIn(0f, 1f)
                    if (pos >= hit - 2 && fade > 0f) Canvas(Modifier.size(1.dp)) {
                        drawKillTrail(killTrailPoints(battle.hero, km.strike, hit - 2, minOf(pos, hit + 0.6)), artDp.toPx(), fade)
                    }
                }
                // the hero's lasting statuses, in its own frame so they go with every move
                if (ui.heroStatus.isNotEmpty() && !ui.heroGone) Canvas(Modifier.size(1.dp)) {
                    val feet = (artDp * HeroBattle.GROUND.toFloat()).toPx()
                    val chest = Offset((artDp * HeroBattle.ANCHOR_X.toFloat()).toPx(), feet - (artDp * 78f).toPx())
                    for (st in ui.heroStatus.keys) drawStatus(st, clockMs / 1000f + 0.7f, chest, feet, (artDp * 78f / 70f).toPx(), vm.bloodLevel)
                }
            }
            // Attack and spell effects, and blood
            with(density) {
                val enemyC = Offset((sceneW * foeX).toPx(), (sceneH * foeY - (if (newStyle) foeTall * 0.55f else monsterSize * 0.45f)).toPx())
                // the doll stands about 130 art pixels tall: spells and blows start from its chest
                val heroC = Offset((sceneW * heroX).toPx(), (sceneH * heroY - artDp * 78f).toPx())
                val unit = (if (newStyle) foeW / 90 else monsterSize / 64).toPx()
                // a spell or shot starts where it leaves the hero: the staff's crystal, the wand, the hand, the bow
                val launch = ui.release?.let { (act, v) -> HeroBattle.launch(battle.hero, act, v) }
                val launchC = launch?.let {
                    Offset((sceneW * heroX + artDp * (it.x - HeroBattle.ANCHOR_X).toFloat()).toPx(), (sceneH * heroY + artDp * (it.y - HeroBattle.GROUND).toFloat()).toPx())
                }
                val source = if (launchC != null && fx?.onHero == false) launchC else heroC
                // and a foe's (or a pack mate's) arrow or spell from its bow, the skull on its staff or its hand
                val foeLaunchC = mateLaunch?.let { Offset(it.x.toPx(), it.y.toPx()) } ?: if (shoots && fx?.onHero == true) MonsterArt.launch(id, battle.look, variant)?.let { (x, y) ->
                    Offset((sceneW * foeX + artDp * (x - MonsterArt.anchorX(id, 0)).toFloat()).toPx(), (sceneH * foeY + artDp * (y - MonsterArt.groundLine(id)).toFloat()).toPx())
                } else null
                BattleFxLayer(fx, ui.animKey, enemyC, source, unit, Modifier.matchParentSize(), startDelay = ui.fxDelay, foeGround = (sceneH * foeY).toPx(), heroGround = (sceneH * heroY).toPx(), foeSource = foeLaunchC)
                if (launchC != null && ui.release?.first == HeroFigure.Act.CAST) CastFlash(ui.flashKey, launchC, Color(0xFF000000 or launch.rgb.toLong()), artDp.toPx(), ui.fxDelay, Modifier.matchParentSize())
                BloodLayer(
                    a, fx, bloodKey, bloodT.value, enemyC, (sceneH * foeY).toPx(), heroC, (sceneH * heroY).toPx(), vm.bloodLevel, goreFor(id), (monsterSize / 64).toPx(),
                    foeHurt = 1f - ui.enemyHp.toFloat() / battle.enemyMaxHp, heroHurt = 1f - ui.heroHp.toFloat() / battle.hero.maxHp, modifier = Modifier.matchParentSize(),
                )
            }

            EnemyBox(battle, ui.enemyHp, ui.foeStatus, lang, Modifier.align(Alignment.TopStart).padding(10.dp))
            HeroBox(battle, ui.heroHp, ui.heroSp, ui.heroStatus, lang, Modifier.align(Alignment.BottomEnd).padding(10.dp))

            // Flashes for spells and level ups
            val bigLoot = a == Anim.LOOT && (step?.rarity ?: de.bornim.core.Rarity.COMMON) >= de.bornim.core.Rarity.EPIC
            // (a spell no longer flashes the whole scene white: it lights up at the staff or hand that casts it)
            if ((a == Anim.LEVEL_UP || bigLoot) && t in 0.01f..0.99f) {
                val c = Colors.gold
                Box(Modifier.matchParentSize().graphicsLayer { alpha = (1f - t) * 0.6f }.background(c))
            }
        }

        // --- Message / command area
        Box(
            Modifier
                .fillMaxWidth()
                .height(220.dp)
                .padding(8.dp)
        ) {
            if (ui.panels.isNotEmpty()) {
                val end = ui.panels.first()
                Panel(
                    Modifier
                        .fillMaxSize()
                        .tap {
                            ui.panels = ui.panels.drop(1)
                            if (ui.panels.isEmpty()) { game.endBattle(); vm.refresh() }
                            else if (ui.panels.first().lines.any { it.anim == Anim.LEVEL_UP }) vm.play(Sound.LEVEL_UP)
                        }
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                        Txt(end.title, size = 19.sp, bold = true, color = Colors.accent)
                        for (l in end.lines) Txt(l.text, size = 15.sp, color = l.rarity?.let { rarityColor(it) } ?: Colors.text)
                    }
                    Txt("▼", Modifier.align(Alignment.BottomEnd), size = 16.sp, color = Colors.accent)
                }
            } else if (step != null || battle.outcome != Outcome.ONGOING) {
                Panel(
                    Modifier
                        .fillMaxSize()
                        .tap { advance() }
                ) {
                    Txt(
                        step?.takeIf { !it.lead && it.anim != Anim.ENEMY_FAINT && !silent }?.let { words(it).take(revealed) } ?: "", size = 20.sp,
                        color = step?.rarity?.let { rarityColor(it) } ?: Colors.text,
                    )
                    if (textDone) Txt("▼", Modifier.align(Alignment.BottomEnd), size = 16.sp, color = Colors.accent)
                }
            } else {
                when (ui.menu) {
                    BattleMenu.MAIN -> MainMenu(battle, lang, onAttack = { ui.menu = BattleMenu.FIGHT }, onSkills = { ui.menu = BattleMenu.SKILLS },
                        onBag = { ui.menu = BattleMenu.BAG }, onFlee = { act(Action.Flee) })
                    BattleMenu.FIGHT -> FightMenu(battle, lang, onAttack = { act(Action.Attack) }, onDefend = { act(Action.Defend) }, onBack = { ui.menu = BattleMenu.MAIN })
                    BattleMenu.SKILLS -> SkillMenu(battle, lang, onPick = { act(Action.UseSkill(it)) }, onBack = { ui.menu = BattleMenu.MAIN })
                    BattleMenu.BAG -> BagMenu(game, lang, onPick = { act(Action.UseItem(it)) }, onBack = { ui.menu = BattleMenu.MAIN })
                }
            }
        }
    }
}

@Composable
private fun ForestBackground(spot: BattleScene.Spot, light: BattleScene.Light, deep: Boolean, seed: Int, scale: Int, modifier: Modifier) {
    Canvas(modifier) {
        val w = kotlin.math.ceil(size.width / scale).toInt()
        val h = kotlin.math.ceil(size.height / scale).toInt()
        val img = BattleScene.forest(w, h, spot, light, deep, seed)
        drawImage(
            image = Bitmaps.of(img),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(w, h),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(w * scale, h * scale),
            filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
        )
    }
}

/** The cave is lit pixel by pixel, which takes a moment: it is drawn in the background and fades in. */
@Composable
private fun CaveBackground(spot: CaveScene.Spot, light: CaveScene.Light, seed: Int, night: Boolean, scale: Int, modifier: Modifier) {
    var dims by remember { mutableStateOf(androidx.compose.ui.unit.IntSize.Zero) }
    var img by remember { mutableStateOf<de.bornim.core.art.PixelImage?>(null) }
    LaunchedEffect(dims, spot, light, seed, night) {
        if (dims.width > 0) img = offMain { CaveScene.cave(dims.width, dims.height, spot, light, seed, night) }
    }
    Canvas(modifier.onSizeChanged { dims = androidx.compose.ui.unit.IntSize(kotlin.math.ceil(it.width / scale.toFloat()).toInt(), kotlin.math.ceil(it.height / scale.toFloat()).toInt()) }) {
        drawRect(Color(0xFF07080C))
        val pic = img ?: return@Canvas
        drawImage(
            image = Bitmaps.of(pic),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(pic.width, pic.height),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(pic.width * scale, pic.height * scale),
            filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
        )
    }
}

@Composable
private fun BattleBackground(kind: MapKind, light: BattleArt.Light, modifier: Modifier) {
    Canvas(modifier) {
        // Whole-number zoom for crisp pixels; the backdrop is generated to fill the scene.
        val scale = maxOf(1, (size.width / 170f).toInt())
        val w = kotlin.math.ceil(size.width / scale).toInt()
        val h = kotlin.math.ceil(size.height / scale).toInt()
        val img = BattleArt.background(kind, w, h, light)
        drawImage(
            image = Bitmaps.of(img),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(w, h),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(w * scale, h * scale),
            filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
        )
    }
}

@Composable
private fun EnemyBox(battle: Battle, hp: Int, status: Map<de.bornim.core.Status, Int>, lang: Lang, modifier: Modifier) {
    val frac by animateFloatAsState(hp.toFloat() / battle.enemyMaxHp, tween(500), label = "enemyHp")
    val name = battle.foeName(lang)
    Panel(modifier.width(232.dp)) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(name, Modifier.weight(1f), size = if (name.length > 17) 15.sp else 17.sp, bold = true, maxLines = if (name.length > 20) 2 else 1,
                    color = when {
                        battle.shiny -> Color(0xFF1E9EC8)
                        battle.trait != null -> Color(battle.trait!!.color).let { Color(it.red * 0.75f, it.green * 0.75f, it.blue * 0.75f) }
                        battle.elite -> rarityColor(de.bornim.core.Rarity.EPIC)
                        else -> Colors.text
                    })
                Txt("Lv.${battle.level}", size = 15.sp, bold = true)
            }
            Txt((if (lang == Lang.DE) "HG " else "CR ") + battle.monster.cr, size = 13.sp, color = Colors.textDim)
            Spacer(Modifier.height(3.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(Ui.hp(lang), size = 12.sp, bold = true, color = Colors.accent)
                Spacer(Modifier.width(4.dp))
                Bar(frac, hpColor(frac), Modifier.fillMaxWidth())
            }
            StatusChips(status, lang)
        }
    }
}

/** Small colored tags for active statuses, with the rounds left. */
@Composable
private fun StatusChips(status: Map<de.bornim.core.Status, Int>, lang: Lang) {
    if (status.isEmpty()) return
    Row(Modifier.padding(top = 4.dp), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        status.forEach { (st, turns) ->
            Box(
                Modifier
                    .clip(androidx.compose.foundation.shape.RoundedCornerShape(4.dp))
                    .background(Color(st.color))
                    .padding(horizontal = 5.dp, vertical = 1.dp)
            ) { Txt(if (turns >= de.bornim.core.Status.LASTING) st.short(lang) else "${st.short(lang)} $turns", size = 11.sp, color = Color.White, bold = true, maxLines = 1) }
        }
    }
}

@Composable
private fun HeroBox(battle: Battle, hp: Int, sp: Int, status: Map<de.bornim.core.Status, Int>, lang: Lang, modifier: Modifier) {
    val hero = battle.hero
    val frac by animateFloatAsState(hp.toFloat() / hero.maxHp, tween(500), label = "heroHp")
    val shownHp by animateFloatAsState(hp.toFloat(), tween(500), label = "heroHpNum")
    Panel(modifier.width(210.dp)) {
        Column {
            Row {
                Txt(hero.name, Modifier.weight(1f), size = 17.sp, bold = true, maxLines = 1)
                Txt("Lv.${hero.level}", size = 15.sp, bold = true)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(Ui.hp(lang), size = 12.sp, bold = true, color = Colors.accent)
                Spacer(Modifier.width(4.dp))
                Bar(frac, hpColor(frac), Modifier.fillMaxWidth())
            }
            Txt("${shownHp.toInt()} / ${hero.maxHp}", Modifier.align(Alignment.End), size = 14.sp, bold = true)
            if (hero.maxSp > 0) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Txt(Ui.sp(lang), size = 12.sp, bold = true, color = Colors.sp)
                    Spacer(Modifier.width(4.dp))
                    Bar(sp.toFloat() / hero.maxSp, Colors.sp, Modifier.weight(1f), 6.dp)
                    Spacer(Modifier.width(4.dp))
                    Txt("$sp", size = 12.sp)
                }
            }
            val next = Rules.xpToNext(hero.level)
            val prev = Rules.xpForLevel[hero.level]
            val xpFrac = if (next == null || de.bornim.core.Story.capped(battle.state)) 1f else (hero.xp - prev).toFloat() / (next - prev)
            Bar(xpFrac, Colors.xp, Modifier.fillMaxWidth().padding(top = 3.dp), 4.dp)
            val effects = buildList {
                if (battle.blessed) add(Skill.BLESS.title(lang))
                if (battle.mageArmor) add(Skill.MAGE_ARMOR.title(lang))
                if (battle.spiritualWeapon) add(Skill.SPIRITUAL_WEAPON.title(lang))
                if (battle.guardians) add(Skill.SPIRIT_GUARDIANS.title(lang))
            }
            if (effects.isNotEmpty()) Txt(effects.joinToString(" · "), size = 11.sp, color = Colors.sp)
            StatusChips(status, lang)
        }
    }
}

@Composable
private fun MainMenu(battle: Battle, lang: Lang, onAttack: () -> Unit, onSkills: () -> Unit, onBag: () -> Unit, onFlee: () -> Unit) {
    Panel(Modifier.fillMaxSize()) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Txt(Ui.whatWillDo.f(lang, battle.hero.name), size = 17.sp)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(Ui.fight(lang), Modifier.weight(1f).height(60.dp), onClick = onAttack)
                PixelButton(Ui.skills(lang), Modifier.weight(1f).height(60.dp), onClick = onSkills)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(Ui.bag(lang), Modifier.weight(1f).height(60.dp), onClick = onBag)
                PixelButton(Ui.flee(lang), Modifier.weight(1f).height(60.dp), onClick = onFlee)
            }
        }
    }
}

/** Fighting: strike, or take a defensive stance until the next turn (the foe attacks at a disadvantage; a miss opens a counter). */
@Composable
private fun FightMenu(battle: Battle, lang: Lang, onAttack: () -> Unit, onDefend: () -> Unit, onBack: () -> Unit) {
    val de = lang == Lang.DE
    Panel(Modifier.fillMaxSize()) {
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(if (de) "Angreifen" else "Attack", Modifier.weight(1f).height(56.dp), onClick = onAttack)
                PixelButton(if (de) "Abwehr" else "Defend", Modifier.weight(1f).height(56.dp), onClick = onDefend)
            }
            Txt(
                if (battle.counter) (if (de) "Konter bereit: der nächste Angriff hat Vorteil." else "Counter ready: the next attack has advantage.")
                else if (de) "Abwehr: Bis zum nächsten Zug greift der Gegner mit Nachteil an. Verfehlt er, bietet sich ein Konter: der nächste Angriff hat Vorteil."
                else "Defend: until your next turn the foe attacks at a disadvantage. If it misses, you may counter: your next attack has advantage.",
                size = 13.sp, color = if (battle.counter) Colors.accent else Colors.textDim,
            )
            PixelButton(if (de) "Zurück" else "Back", Modifier.fillMaxWidth().height(40.dp), size = 14.sp, onClick = onBack)
        }
    }
}

@Composable
private fun SkillMenu(battle: Battle, lang: Lang, onPick: (Skill) -> Unit, onBack: () -> Unit) {
    val hero = battle.hero
    val skills = hero.cls.skills().filter { !it.passive && hero.has(it) }
    Panel(Modifier.fillMaxSize()) {
        Column {
            Column(
                Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                skills.forEach { s ->
                    val cost = when (s.cost) {
                        SkillCost.NONE -> Ui.unlimited(lang)
                        SkillCost.SPELL_POINTS -> "${s.amount} ${Ui.sp(lang)}"
                        SkillCost.PER_BATTLE, SkillCost.PER_REST -> Ui.usesLeft.f(lang, battle.usesLeft(s) ?: 0, s.amount)
                        SkillCost.PASSIVE -> ""
                    }
                    val reason = battle.blocked(s)
                    PixelButton("${s.title(lang)}  ·  $cost", Modifier.fillMaxWidth(), enabled = reason == null, size = 16.sp) { onPick(s) }
                }
                Txt(skills.joinToString("\n") { "${it.title(lang)}: ${it.desc(lang)}" }, size = 13.sp, color = Colors.textDim)
            }
            Spacer(Modifier.height(6.dp))
            BackRow(Ui.back(lang), onBack)
        }
    }
}

@Composable
private fun BagMenu(game: Game, lang: Lang, onPick: (String) -> Unit, onBack: () -> Unit) {
    val usable = game.state.inventory.entries.filter { Items[it.key].kind == ItemKind.POTION || Items[it.key].kind == ItemKind.BOMB }
    Panel(Modifier.fillMaxSize()) {
        Column {
            Column(
                Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                if (usable.isEmpty()) Txt(Ui.nothing(lang), color = Colors.textDim)
                usable.forEach { (id, count) ->
                    val def = Items[id]
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        SupplyPicture(def.id, 32.dp)
                        Spacer(Modifier.width(6.dp))
                        PixelButton("${def.name(lang)} ×$count", Modifier.weight(1f), size = 16.sp) { onPick(id) }
                    }
                }
            }
            Spacer(Modifier.height(6.dp))
            BackRow(Ui.back(lang), onBack)
        }
    }
}

/** Mates stay while the leader fades out on its defeat (they flee with their own animation). */
private fun enemyAlphaBase(a: Anim?, gone: Boolean, t: Float): Float = if (gone && a != Anim.ENEMY_FAINT && a != Anim.PACK_FLEE) 0f else 1f

/** Pulsing glow in the elite's trait color behind the monster. */
/** Stains on a hurt monster in the color of what it bleeds; skeletons crack instead. */
private fun woundsOf(img: de.bornim.core.art.PixelImage, wound: Int, id: String, seed: Int): de.bornim.core.art.PixelImage {
    val gore = goreFor(id)
    // the ochre jelly's wounds are holes in the ooze, near black: in its own colour they would not show on it
    val main = if (gore == Gore.SLIME) Color(0xFF241606) else gore.main
    val c = (main.red * 255).toInt() shl 16 or ((main.green * 255).toInt() shl 8) or (main.blue * 255).toInt()
    return Glow.wounds(img, wound, c, seed, cracks = gore == Gore.BONE)
}

/** 0..1 and back, slowly, for glowing things. */
@Composable
private fun rememberPulse(): Float {
    val p by androidx.compose.animation.core.rememberInfiniteTransition(label = "glow").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1100), androidx.compose.animation.core.RepeatMode.Reverse),
        label = "pulse",
    )
    return p
}

/** The frame of a fall at which the foe has taken the killing blow and reels, before it goes down. */
private const val DIE_REEL = 4
/** The ambushed hero's last frame of the stagger, before the turn to the foe begins. */
/** How long being struck, ducking aside and the step back after a blow take, in ms at normal pace. */
private val REACT_MS: Int get() = BattlePace.ms(750)
/** A blow that strikes home halts for a moment as it lands, giving it weight. */
private val HIT_STOP_MS: Long get() = BattlePace.ms(70L)

/** Poison, burning or bleeding eating at someone at the start of a turn: a hurt, but nobody's blow. */
private fun Step?.isTick() = this?.fx?.kind in setOf(de.bornim.core.FxKind.POISON, de.bornim.core.FxKind.BURN, de.bornim.core.FxKind.BLEED)

/** When a new-style foe's blow on the hero lands, into the message ([step] the hit); null for a miss, a shot, a spell, a pack. */
private fun foeBlowLands(battle: Battle, variant: Int, step: Step): Long? {
    if (step.anim != Anim.HERO_HIT || step.fx?.onHero != true || step.isTick() || (step.packActor ?: -1) >= 0) return null
    val id = battle.monster.id
    if (MonsterArt.isDoll(id) && !de.bornim.core.art.FoeArt.lunges(id, battle.look, variant)) return null
    return foeTiming(battle, variant)?.blowMs?.toLong()
}

/** A blow, as the hero strikes it: each frame of the swing and of the way back, at normal pace (play() applies the menu pace). */
private const val ATTACK_FRAME_MS = 92L
/** Each frame of a spell gathered and let go, or a flask drawn back and thrown. */
private const val CAST_FRAME_MS = 74L
/** A foe's wind-up, and how long its blow takes to land. */
private val WINDUP_MS: Int get() = BattlePace.ms(650)
private val BLOW_MS: Int get() = BattlePace.ms(720)
/** The hero's own lead-ins: the move is played from the hero's doll, and its end comes when the wind-up is done. */
private val HERO_LEADS = setOf(Anim.HERO_ACT, Anim.SPELL, Anim.THROW, Anim.DRINK)
/** How much slower than the blow the hero steps back after it. */
private const val MOVE_SLOW = 1.6
/** What the hero does on the hero's own turn. */
private val HERO_MOVES = setOf(Anim.HERO_ACT, Anim.SPELL, Anim.THROW, Anim.DEFEND, Anim.HERO_HEAL)

/**
 * How long a new-style foe's attack takes: the wind-up and the way back frame by frame, at the hero's pace per frame
 * (small beasts quicker, bosses heavier and slower), the blow itself as fast as ever, so the hit lands on the hero
 * just when the hero flinches and the blood flies.
 */
private class FoeTiming(val windMs: Int, val blowMs: Int, val landMs: Int)

private fun foeTiming(battle: Battle, variant: Int): FoeTiming? {
    val id = battle.monster.id
    if (!MonsterArt.isNewStyle(id)) return null
    val strike = MonsterArt.strikeFrame(id, battle.look, variant)
    val n = MonsterArt.frameCount(id, battle.look, Act.ATTACK, variant)
    val windEnd = if (MonsterArt.isSolid(id)) (strike - 2).coerceAtLeast(0) else strike
    val k = when {
        battle.monster.boss -> 1.12
        id in QUICK_FOES -> 0.85
        else -> 1.0
    }
    val per = BattlePace.ms(ATTACK_FRAME_MS) * k
    val blowMs = (strike - windEnd + 1) * BLOW_MS / (n - windEnd).coerceAtLeast(1)
    return FoeTiming(((windEnd + 1) * per).toInt(), blowMs, blowMs + ((n - 1 - strike).coerceAtLeast(0) * per * MOVE_SLOW).toInt())
}

/** Small, quick beasts: their attacks run a little faster than the hero's. */
private val QUICK_FOES = setOf("wolf", "giant_rat")

/** How long the foe's own blow on the hero runs with this message: the blow and the way back, or the hero's fall. */
private fun foeLandMs(battle: Battle, variant: Int, an: Anim?): Int = when {
    an == Anim.HERO_FAINT -> BattlePace.ms(700)
    else -> foeTiming(battle, variant)?.landMs ?: REACT_MS
}

/** How far into its step a foe on the doll goes while its attack is named: the rest of the step comes with the blow. */
private const val FOE_WIND_STEP = 0.45f

/** How long the leader's howl animation runs, and how long it takes to raise its head. */
private val HOWL_MS: Long get() = BattlePace.ms(1900L)
private val HOWL_RAISE_MS: Long get() = BattlePace.ms(330L)

/** Milliseconds that keep counting, to drive slow effects. */
/**
 * The battle's clock. On the phone it is the system clock; the preview sets its own, so a film runs as fast
 * as it can be drawn and the same seed gives the same pictures.
 */
object BattleClock {
    @Volatile var now: () -> Long = { System.currentTimeMillis() }
    /** The screen's own choices (attack variant, victory pose, howl); a film sets a seeded one. */
    @Volatile var random: kotlin.random.Random = kotlin.random.Random
    /** Drawing work running in the background ([offMain]); a film waits for it, so its pictures do not depend on the computer's speed. */
    val busy = java.util.concurrent.atomic.AtomicInteger(0)
}

/** Heavy drawing off the main thread, counted in [BattleClock.busy]. */
private suspend fun <T> offMain(block: () -> T): T {
    BattleClock.busy.incrementAndGet()
    // counted down in the background itself: a film must not wait on a frame it has yet to draw
    return kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
        try { block() } finally { BattleClock.busy.decrementAndGet() }
    }
}

/**
 * Waits [ms] of battle time frame by frame (instead of delay), so every wait of the battle follows
 * [BattleClock]: on the phone within one frame of the old delay, in a film exactly on the film's clock.
 */
private suspend fun pause(ms: Long) {
    if (ms <= 0L) return
    val end = BattleClock.now() + ms
    while (BattleClock.now() < end) withFrameMillis { }
}

private suspend fun pause(ms: Int) = pause(ms.toLong())

@Composable
private fun pulseClock(): Long {
    var now by remember { androidx.compose.runtime.mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        val start = BattleClock.now()
        while (true) {
            pause(33)
            now = BattleClock.now() - start
        }
    }
    return now
}

@Composable
private fun EliteAura(color: Color, size: androidx.compose.ui.unit.Dp, alpha: Float) {
    val pulse by androidx.compose.animation.core.rememberInfiniteTransition(label = "aura").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1100), androidx.compose.animation.core.RepeatMode.Reverse),
        label = "pulse",
    )
    Canvas(Modifier.width(size).height(size)) {
        val c = Offset(this.size.width / 2, this.size.height * 0.58f)
        val r = this.size.width * (0.42f + 0.05f * pulse)
        drawCircle(
            Brush.radialGradient(listOf(color.copy(alpha = (0.55f + 0.25f * pulse) * alpha), color.copy(alpha = 0f)), c, r),
            r, c,
        )
    }
}

/** Twinkling stars around a shimmering monster. */
@Composable
private fun Sparkles(seed: Int, size: androidx.compose.ui.unit.Dp, alpha: Float) {
    val time by androidx.compose.animation.core.rememberInfiniteTransition(label = "sparkle").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1800, easing = androidx.compose.animation.core.LinearEasing)),
        label = "time",
    )
    Canvas(Modifier.width(size).height(size)) {
        val r = kotlin.random.Random(seed)
        val u = this.size.width / 64f
        repeat(6) { i ->
            val x = (12 + r.nextFloat() * 40) * u
            val y = (10 + r.nextFloat() * 44) * u
            val p = (time + i / 6f) % 1f
            val s = sin(p * Math.PI.toFloat()) * 2.6f * u
            if (s <= 0.2f) return@repeat
            val c = listOf(Color.White, Color(0xFFFFF2A0), Color(0xFFA0F0FF))[i % 3].copy(alpha = alpha)
            drawRect(c, Offset(x - s / 4, y - s), Size(s / 2, s * 2))
            drawRect(c, Offset(x - s, y - s / 4), Size(s * 2, s / 2))
        }
    }
}


/**
 * The doll's frame for this moment: the act it is playing, or its rest. A frame not drawn yet is stood in for by the
 * nearest earlier one of the same act, then by the rest, which is drawn at once if need be.
 */
private fun heroDollFrame(ui: BattleUi, clockMs: Long, wounds: Int): Pair<de.bornim.core.art.PixelImage, Double> {
    val hero = ui.battle.hero
    val now = BattleClock.now()
    val m = ui.motion
    // the way down out of a guard, before the next move starts
    m?.lead?.takeIf { now < m.start }?.let { l ->
        val i = (l.from + ((l.to - l.from + 1) * ((now - l.start).toDouble() / l.ms)).toInt()).coerceIn(l.from, l.to)
        for (k in i downTo l.from) HeroBattle.ready(hero, l.act, l.strike, l.variant, k, wounds)?.let { return it to 0.0 }
    }
    if (m != null) {
        val p = (m.clock(now) - m.start).toDouble() / m.ms
        if (p < 1.0 || m.hold) {
            val i = m.index(now)
            // how far the blow has stepped in: between frames too, so the step glides
            val lunge = if (m.act == HeroFigure.Act.ATTACK) HeroBattle.lungeAt(hero, m.strike, m.pos(now)) else 0.0
            // the fall is the last thing of a lost fight and may not be drawn ahead yet: drawn now, frame by frame, so the
            // hero does not stand on while its words wait for it to lie
            if (m.act == HeroFigure.Act.DIE && now >= m.start && HeroBattle.ready(hero, m.act, m.strike, m.variant, i, wounds) == null)
                return HeroBattle.frame(hero, m.act, m.strike, m.variant, i, wounds) to 0.0
            for (k in i downTo m.from) HeroBattle.ready(hero, m.act, m.strike, m.variant, k, wounds)?.let { return it to lunge }
            // a held pose (a guard, a wind-up) or a move under way never falls back to the rest: drawn now if no frame of
            // it is kept (a remedy's green flask, say, that was not drawn ahead)
            if (now >= m.start) return HeroBattle.frame(hero, m.act, m.strike, m.variant, i, wounds) to lunge
        }
    }
    val idle = (clockMs / 110).toInt()
    val img = HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, idle, wounds)
        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0, wounds)
        ?: HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
    return img to 0.0
}


/** A burst of light where a spell leaves the hero: bright at once, then fading and widening. */
@Composable
private fun CastFlash(key: Int, at: Offset, colour: Color, px: Float, delayMs: Long, modifier: Modifier) {
    val p = remember(key) { Animatable(0f) }
    LaunchedEffect(key) {
        pause(delayMs)
        p.animateTo(1f, tween(BattlePace.ms(260), easing = androidx.compose.animation.core.LinearEasing))
    }
    val t = p.value
    if (t <= 0f || t >= 1f) return
    Canvas(modifier) {
        val fade = 1f - t
        drawCircle(colour.copy(alpha = 0.35f * fade), radius = px * (10f + 16f * t), center = at)
        drawCircle(colour.copy(alpha = 0.7f * fade), radius = px * (5f + 6f * t), center = at)
        drawCircle(Color.White.copy(alpha = 0.9f * fade), radius = px * (2.5f + 2f * t), center = at)
    }
}
