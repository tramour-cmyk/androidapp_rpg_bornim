package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.alpha
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.Animatable
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.layout.layout
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Aim
import de.bornim.core.CharClass
import de.bornim.core.Effect
import de.bornim.core.Fighter
import de.bornim.core.Intent
import de.bornim.core.Items
import de.bornim.core.IntentKind
import de.bornim.core.Lang
import de.bornim.core.Moves
import de.bornim.core.MonsterLook
import de.bornim.core.Order
import de.bornim.core.Outcome
import de.bornim.core.Reaction
import de.bornim.core.RollInfo
import de.bornim.core.RollKind
import de.bornim.core.Row as Line
import de.bornim.core.Side
import de.bornim.core.Skill
import de.bornim.core.SkillCost
import de.bornim.core.Skirmish
import de.bornim.core.SkirmishEvent
import de.bornim.core.Spot
import de.bornim.core.art.PlaceGlide
import de.bornim.core.art.Act
import de.bornim.core.art.Breath
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CaveScene
import de.bornim.core.art.FightCamera
import de.bornim.core.art.Kampfort
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MonsterArt
import de.bornim.core.audio.MarsSound
import de.bornim.core.audio.Sound
import de.bornim.game.GameViewModel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.math.abs
import kotlin.math.sin

/*
 * MARS (72.10) (DESIGN-KAMPF.md, Beschlüsse 72.11, 72.13, 72v): the hero and a Söldner against Grak on the painted
 * Kampfort (Grak's hall), two rows of two places a side. The fight runs on its own thread; every message comes here
 * and is played one after another, and when Grak's announced blow comes, the fight waits for the tap on the ring.
 * 72.10a: "Können" and "Tasche" under the scene, the line of turns above it, the figure acting marked by a ring on
 * the ground, reachable targets lit while aiming, every roll with its numbers briefly over its target.
 */

/** Keys among the insights seen (210): the first intent with a ring explained, the first ring's word to tap (219). */
private const val RING_SEEN = "ring"
private const val RING_TAP_SEEN = "ringtap"
/** 223: the insight on the first melee blow from the back row. */
private const val BACK_SEEN = "back"

/** How long the ring takes to close on the figure, and how far off a tap may be for "perfect" and "good". */
private const val RING_MS = 1100L
private const val PERFECT_MS = 90L
private const val GOOD_MS = 260L
/** How long one message stays before the next. */
private const val SAY_MS = 1100L
private const val LUNGE_MS = 340L
/** 249: a hero's or mercenary's blow in a lunge: a short wind-up to the blow at the lunge's furthest, then the follow-through */
private const val SWING_IN_MS = LUNGE_MS / 2
/** 19e (Rückläufer t49.2 „Wolf greift nicht an, rückt nur vor“): an animal's bite takes longer and leaps up to its target */
private const val BEAST_LUNGE_MS = 800L
private const val BEAST_REACH = 0.6f
private fun smooth(t: Float) = t.coerceIn(0f, 1f).let { it * it * (3 - 2 * it) }
private const val SWING_OUT_FRAME_MS = 70L
/** 249: one frame of a spell's gesture, as in the classic fight (`BattleScreen.CAST_FRAME_MS`). */
private const val CAST_FRAME_MS = 74L
/** 205: how long a foe takes to topple over, and then to fade away. */
private const val FALL_MS = 900L
private const val FADE_MS = 600L
/** The orders under the scene: the line of who acts and two rows of buttons (211: 52 and 48 dp, 6 dp apart). */
private val ORDERS_H = 136.dp
/** 211: the log, five lines of 15 sp. */
// 211.15: the golden line "Am Zug" is gone, its room goes to the log (232: but for the second line of the boxes)
private val LOG_H = 116.dp

/**
 * Where a place stands on the scene, as a share of its width and height: the party lower left, the foes upper right.
 * 211.7 (Chef 18:46): a figure [alone] in its row stands in the middle of the row's two places, so one in front and one
 * behind stand on one line to the foe.
 */
private fun placeAt(side: Side, s: Spot, alone: Boolean = false, aspect: Float = 1.4f): Pair<Float, Float> {
    val (ax, ay) = slotAt(side, Spot(s.row, 0))
    val (bx, by) = slotAt(side, Spot(s.row, 1))
    val cx = (ax + bx) / 2
    val cy = (ay + by) / 2
    if (alone) return cx to cy
    if (!MarsLayout.offset) return slotAt(side, s)
    // 211.10: the two of a row set apart across the line from the party to the foes, as far apart as side by side
    val (ox, oy) = acrossAxis(aspect)
    val k = (bx - ax) / 2 * (if (s.slot == 0) -1f else 1f)
    return cx + ox * k to cy + oy * k / aspect
}

/** 211.10: a unit step across the line of the fight (front row to front row), in shares of the scene's width; [aspect] is height by width. */
private fun acrossAxis(aspect: Float): Pair<Float, Float> {
    val (p0, p1) = slotAt(Side.PARTY, Spot(Line.FRONT, 0)) to slotAt(Side.PARTY, Spot(Line.FRONT, 1))
    val (f0, f1) = slotAt(Side.FOES, Spot(Line.FRONT, 0)) to slotAt(Side.FOES, Spot(Line.FRONT, 1))
    val dx = (f0.first + f1.first - p0.first - p1.first) / 2
    val dy = (f0.second + f1.second - p0.second - p1.second) / 2 * aspect
    val n = kotlin.math.sqrt(dx * dx + dy * dy)
    return -dy / n to dx / n
}

/** 211.9 (Chef 20:15): the two places of a row stand side by side at one height, so they never look one behind the other. */
private fun slotAt(side: Side, s: Spot): Pair<Float, Float> = if (MarsLayout.straight) straightAt(side, s) else when (side) {
    Side.PARTY -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.29f to 0.865f else 0.51f to 0.865f)
    else (if (s.slot == 0) 0.11f to 0.93f else 0.27f to 0.93f)
    Side.FOES -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.61f to 0.61f else 0.79f to 0.61f)
    else (if (s.slot == 0) 0.74f to 0.465f else 0.90f to 0.465f)
}

/** 211.10 (Chef 21:39): a straight line of the fight, as the cave is drawn from the front: foes above the party, rows level. */
private fun straightAt(side: Side, s: Spot): Pair<Float, Float> = when (side) {
    Side.PARTY -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.34f to 0.78f else 0.66f to 0.78f)
    else (if (s.slot == 0) 0.34f to 0.96f else 0.66f to 0.96f)
    Side.FOES -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.36f to 0.56f else 0.64f to 0.56f)
    else (if (s.slot == 0) 0.42f to 0.42f else 0.58f to 0.42f)
}

/** 211.10 (Chef 21:08): the back row is never drawn smaller than the front; on the straight line all a fifth smaller, so four rows fit. */
@Suppress("UNUSED_PARAMETER")
private fun depth(s: Spot) = if (MarsLayout.straight) 0.8f else 1f

private sealed interface Beat {
    data class Say(val e: SkirmishEvent) : Beat
    data class Ring(val target: String, val intent: Intent, val answer: CompletableDeferred<Reaction>) : Beat
    data object Done : Beat
}

/** The fight on its thread, and what it says, in order. */
private class ProbeRun(val sk: Skirmish) {
    val beats = Channel<Beat>(Channel.UNLIMITED)
    private val thread = java.util.concurrent.Executors.newSingleThreadExecutor()

    val react: (Fighter, Intent) -> Reaction = { t, i ->
        val d = CompletableDeferred<Reaction>()
        beats.trySend(Beat.Ring(t.id, i, d))
        kotlinx.coroutines.runBlocking { d.await() }
    }

    init {
        sk.listener = { beats.trySend(Beat.Say(it)) }
    }

    fun run(block: () -> Unit) = thread.execute {
        try { block() } finally { beats.trySend(Beat.Done) }
    }

    fun close() = thread.shutdownNow()
}

private sealed interface Pick {
    data object Main : Pick
    data object Target : Pick
    data object Place : Pick
    data object Skills : Pick
    data object Bag : Pick
    data class SkillAt(val skill: Skill) : Pick
    data class DrinkAt(val item: String) : Pick
}

/** One choice of the orders; [enabled] false greys it out. */
private class Opt(val label: String, val enabled: Boolean = true, val tip: String? = null, val go: () -> Unit)

/** How long a roll with its numbers stays over its target (72.10a.10). */
// 260 (Chef 18:04): a roll stays 2.5 s, then fades in SOFT_MS, as names, verdict and tips do
private const val ROLL_MS = 2500L
private const val SOFT_MS = 400L
/** 260: how far a thing shown until [until] has faded: 1 while it stands, down to 0 in the last [SOFT_MS]. */
private fun softAlpha(now: Long, until: Long): Float = ((until - now).toFloat() / SOFT_MS).coerceIn(0f, 1f)

/** How long the explanation of a button pressed long stays (204). */
private const val TIP_MS = 6000L

@Composable
fun SkirmishScreen(vm: GameViewModel, sk: Skirmish) {
    CompositionLocalProvider(LocalVeil provides true) { SkirmishBody(vm, sk) }
}

@Composable
private fun SkirmishBody(vm: GameViewModel, sk: Skirmish) {
    val lang = vm.lang
    fun t(d: String, e: String) = if (lang == Lang.DE) d else e
    val run = remember(sk) { ProbeRun(sk) }
    DisposableEffect(run) { onDispose { run.close() } }
    BackHandler { vm.probe = null }
    val rollShown = remember(sk) { mutableStateOf<Triple<String, RollInfo, Long>?>(null) }

    // what the screen shows: the state after the last played message, not the fight's own (it may be further on)
    var shown by remember(sk) {
        mutableStateOf(SkirmishEvent("", hp = sk.fighters.associate { it.id to it.hp }, places = sk.fighters.associate { it.id to it.place }, intents = LinkedHashMap(sk.intents), queue = sk.queue(), sp = sk.fighters.associate { it.id to it.sp }))
    }
    val lines = remember(sk) { mutableStateListOf<String>() }
    // 211: the whole log of the fight over the scene, to leaf back
    var fullLog by remember(sk) { mutableStateOf(false) }
    val linesScroll = androidx.compose.foundation.rememberScrollState()
    LaunchedEffect(lines.size, linesScroll.maxValue) { linesScroll.scrollTo(linesScroll.maxValue) }
    var busy by remember(sk) { mutableStateOf(true) }
    // 272: a win or loss asked for while the fight plays; it comes as soon as the fight is idle
    var endAsked by remember(sk) { mutableStateOf<Boolean?>(null) }
    // 241.2: the hero's automatic as shown; the fight may stop it on its own (below a third, a strong intent)
    var heroAuto by remember(sk) { mutableStateOf(sk.autopilot) }
    var ring by remember(sk) { mutableStateOf<Beat.Ring?>(null) }
    var ringStart by remember(sk) { mutableLongStateOf(0L) }
    var ringResult by remember(sk) { mutableStateOf<Reaction?>(null) }
    var verdict by remember(sk) { mutableStateOf<String?>(null) }
    // 219.3: the class's answer to a perfect ring, shown under the verdict
    var answer by remember(sk) { mutableStateOf<String?>(null) }
    // 219: the first ring of a save game says when to tap
    var ringHelp by remember(sk) { mutableStateOf(false) }
    val glide = remember(sk) { PlaceGlide(PlaceGlide.MS * MarsLayout.slow) }
    // 19e: each foe breathes on its own time and begins again after each move
    val breaths = remember(sk) { HashMap<String, Breath>() }
    var lunge by remember(sk) { mutableStateOf<Pair<String, String>?>(null) }
    var lungeAt by remember(sk) { mutableLongStateOf(0L) }
    // 249 (Chef 18:12, t47: „der Magier … beim Zaubern mit seinem Stab zuschlägt“): a spell is cast where one stands
    var casting by remember(sk) { mutableStateOf(false) }
    val hurtAt = remember(sk) { mutableStateMapOf<String, Long>() }
    // 249 (Zoom, Erschütterung wie im klassischen Kampf): a critical blow or the last one jolts the scene once in the
    // blow's direction and draws it in towards the one struck while the blow halts
    val jolt = remember(sk) { Animatable(1f) }
    val hitZoom = remember(sk) { Animatable(0f) }
    var hit by remember(sk) { mutableStateOf<Triple<String, String, de.bornim.core.HitWeight>?>(null) }
    var hitKey by remember(sk) { mutableIntStateOf(0) }
    // where each figure's feet stood in the last picture (parts of the scene), for the jolt's direction and the zoom
    val feetSeen = remember(sk) { HashMap<String, Pair<Float, Float>>() }
    // and how tall it was drawn, for where the blood flies from
    val tallSeen = remember(sk) { HashMap<String, Dp>() }
    // Rückläufer t50 („Zauber startet nicht am richtigen Punkt“): each hero's size per art pixel, for where a spell leaves it
    val pxSeen = remember(sk) { HashMap<String, Dp>() }
    // 249 (Zaubereffekte wie im klassischen Kampf): the spell of a message, from the caster to its target, as there
    var spellFx by remember(sk) { mutableStateOf<Triple<de.bornim.core.Fx, String, String>?>(null) }
    var spellKey by remember(sk) { mutableIntStateOf(0) }
    // 249 (Blut wie im klassischen Kampf): a blow, bite or shot that lands draws blood, away from the one striking
    var bleed by remember(sk) { mutableStateOf<Bleed?>(null) }
    val bloodT = remember(sk) { Animatable(1f) }
    LaunchedEffect(bleed) {
        if (bleed == null) return@LaunchedEffect
        bloodT.snapTo(0f); bloodT.animateTo(1f, tween(bloodMs(vm.bloodLevel) * MarsLayout.slow.toInt(), easing = LinearEasing))
    }
    LaunchedEffect(hitKey) {
        val w = hit?.third ?: return@LaunchedEffect
        val sl = MarsLayout.slow.toInt()
        launch { jolt.snapTo(0f); jolt.animateTo(1f, tween(w.joltMs.toInt() * sl, easing = LinearEasing)) }
        val kill = w == de.bornim.core.HitWeight.KILL
        hitZoom.snapTo(0f)
        hitZoom.animateTo(1f, tween((if (kill) 220 else 110) * sl, easing = FastOutSlowInEasing))
        delay((if (kill) 900L else w.stopMs) * sl)
        hitZoom.animateTo(0f, tween((if (kill) 700 else 450) * sl, easing = FastOutSlowInEasing))
    }
    /** 205: when each figure fell; friends lie there, foes topple over and are gone. */
    val downAt = remember(sk) { mutableStateMapOf<String, Long>() }
    var pick by remember(sk) { mutableStateOf<Pick>(Pick.Main) }
    /** 204: the explanation of a button pressed long; it goes after a while, or with a tap on it. */
    var tip by remember(sk) { mutableStateOf<String?>(null) }
    // 211.15: names over the figures show while a target is picked, and for a while after a long press
    var namesUntil by remember(sk) { mutableStateOf(0L) }
    // 260: hints and verdict fade out softly
    val tipAlpha = remember(sk) { Animatable(1f) }
    LaunchedEffect(tip) { tipAlpha.snapTo(1f); if (tip != null) { delay(TIP_MS); tipAlpha.animateTo(0f, tween(SOFT_MS.toInt())); tip = null } }
    var ready by remember(sk) { mutableStateOf(false) }
    // 259 (3): a light fight waits at its start for "Kämpfen" or "Schnell"; what a quick fight brought, for the board
    var opened by remember(sk) { mutableStateOf(!sk.easy) }
    var quickDone by remember(sk) { mutableStateOf<Skirmish.QuickResult?>(null) }
    val scope = rememberCoroutineScope()

    // the figures standing ready before the fight starts (about a second); the rest of Grak's and the goblins' frames
    // follow in the background (about six seconds), shown as soon as each is drawn
    LaunchedEffect(sk) {
        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
            for (f in sk.fighters) f.hero?.let { HeroBattle.prepareAct(it, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0); HeroBattle.prepareAct(it, HeroFigure.Act.STEP, HeroFigure.Strike.SLASH, 0) }
            MonsterArt.shownFrame(Skirmish.GRAK, MonsterLook(0), Act.IDLE, 0, 0)
        }
        launch(kotlinx.coroutines.Dispatchers.Default) {
            // 19e (Rückläufer t46.6 „Der Wolf atmet nicht“): every kind in the fight, not only Grak and his goblins; an
            // animal left unprepared showed one still frame. The dolls first: preparing a doll forgets the animals' frames
            // 249 (Rückläufer t52 „zauberanimation läuft beim ersten Mal nach Trefferanimation“): the gesture and the
            // blows drawn ahead too; drawn only when first needed, they lagged behind the spell and the hit they lead to
            for (f in sk.fighters) f.looks?.let { h ->
                if (h.cls.caster) HeroBattle.prepareAct(h, HeroFigure.Act.CAST, HeroFigure.Strike.CAST, HeroBattle.castVariant(h)) { !isActive }
                for (s in HeroBattle.strikes(h)) HeroBattle.prepareAct(h, HeroFigure.Act.ATTACK, s, 0) { !isActive }
            }
            val kinds = sk.fighters.mapNotNull { it.monster?.id }.toMutableSet()
            if (Skirmish.GRAK in kinds) kinds += Skirmish.CALLED
            for (id in kinds.sortedBy { if (MonsterArt.isDoll(it)) 0 else 1 }) MonsterArt.prepare(id, MonsterLook(0)) { !isActive }
        }
        ready = true
        // the one sentence that shows what the rows do, in the first fight only (72.10a.6)
        if (!vm.rowHintSeen) {
            lines += t("Nahkampf erreicht nur die vordere Reihe.", "Melee reaches only the front row.")
            vm.markRowHintSeen()
        }
        // 256: wolves now and then howl as they appear, as in the old fight
        if (sk.fighters.any { it.monster?.id == Skirmish.WOLF } && kotlin.random.Random.nextDouble() < 0.5) vm.play(Sound.HOWL)
        if (!opened) snapshotFlow { opened }.first { it }
        if (!sk.started) run.run { sk.start(run.react) }
        for (b in run.beats) when (b) {
            is Beat.Say -> {
                val e = b.e
                shown = e
                // 223: before the first melee blow from the back row of a figure the player steers, the hero's insight
                if (BACK_SEEN !in vm.insightsSeen && e.roll?.fromBack == true && sk.byIdOrNull(e.actor)?.let { it.side == Side.PARTY && !it.auto } == true) {
                    lines += MarsTips.backInsight(lang); vm.markInsightSeen(BACK_SEEN)
                }
                if (e.text.isNotEmpty()) { lines += e.text; while (lines.size > 300) lines.removeAt(0) }
                // 210: an intent seen for the first time, the hero's insight on how to meet it
                for ((intent, _) in e.intents.values) if (intent.id !in vm.insightsSeen) MarsTips.insight(intent.id, lang)?.let { lines += it; vm.markInsightSeen(intent.id) }
                // 219: the first intent with a ring against a figure the player steers, before the blow
                if (RING_SEEN !in vm.insightsSeen && e.intents.values.any { (intent, aimed) -> intent.ring && aimed.any { id -> sk.byIdOrNull(id)?.let { it.side == Side.PARTY && !it.auto } == true } }) {
                    lines += MarsTips.firstRing(lang); vm.markInsightSeen(RING_SEEN)
                }
                if (e.answer && verdict != null) answer = e.text
                // 219.4: good, but the blow missed anyway: only the word ([219.4T.gut]), the log says "verfehlt"
                if (ringResult == Reaction.GOOD && verdict != null && e.roll?.success == false && sk.byIdOrNull(e.actor)?.side == Side.FOES) verdict = t("Gut", "Good")
                val now = System.currentTimeMillis()
                val actor = e.actor
                val target = e.target
                if (actor != null && target != null && actor != target && sk.byIdOrNull(actor)?.side != sk.byIdOrNull(target)?.side) { lunge = actor to target; lungeAt = now; casting = e.spell != null; MarsLayout.onHit?.invoke("lunge $actor>$target") }
                if (e.roll != null && target != null) rollShown.value = Triple(target, e.roll!!, now)
                e.spell?.let { kind ->
                    if (actor == null || target == null) return@let
                    // went wide or was dodged: drawn going by, and the target springs aside
                    val miss = e.roll != null && e.damage == 0
                    spellKey++
                    spellFx = Triple(de.bornim.core.Fx(if (miss) de.bornim.core.FxKind.DODGE else kind, onHero = false,
                        crit = !miss && e.roll?.let { it.kind == de.bornim.core.RollKind.ATTACK && it.d20 == 20 } == true, seed = spellKey * 7919,
                        past = if (miss) kind else null), actor, target)
                    MarsLayout.onHit?.invoke("${spellFx!!.first.kind}/${kind} $actor>$target")
                }
                for ((id, hp) in e.hp) if (hp <= 0) { if (id !in downAt) downAt[id] = now } else downAt.remove(id)
                if (e.damage > 0 && target != null) {
                    hurtAt[target] = now
                    val struck = sk.byIdOrNull(target)
                    val w = de.bornim.core.HitWeight.of(e.roll?.let { it.success && it.d20 == 20 } == true, e.damage, struck?.maxHp ?: 0, kill = (e.hp[target] ?: 1) <= 0)
                    if (actor != null && w.joltDp > 0f && MarsLayout.look249) { hit = Triple(actor, target, w); hitKey++; MarsLayout.onHit?.invoke("$w $actor>$target") }
                    if (actor != null && e.wound && vm.bloodLevel > 0 && MarsLayout.look249) bleed = Bleed(actor, target, w == de.bornim.core.HitWeight.CRIT || (w == de.bornim.core.HitWeight.KILL && e.roll?.d20 == 20),
                        1f - (e.hp[target] ?: 0).toFloat() / (struck?.maxHp ?: 1).coerceAtLeast(1), (bleed?.seed ?: 0) + 1,
                        struck?.monster?.id?.let { goreFor(it) } ?: Gore.BLOOD)
                }
                // 256: the sounds as in the old fight, the blow's as it lands, the cry just after
                for (c in MarsSound.of(e, sk)) launch {
                    delay(c.atMs * MarsLayout.slow)
                    c.sound?.let { vm.play(it, c.volume) }
                    c.voice?.let { v -> vm.voice(c.monster!!, v, c.volume) }
                }
                // 272: a win or loss asked for: what is still to come runs through without waiting
                if (endAsked == null) delay(SAY_MS)
            }
            is Beat.Ring -> if (endAsked != null) b.answer.complete(Reaction.GOOD) else {
                ringResult = null
                answer = null
                ringHelp = RING_TAP_SEEN !in vm.insightsSeen
                ringStart = System.currentTimeMillis()
                ring = b
                vm.play(Sound.SWING_HEAVY, 0.6f)
                val r = withTimeoutOrNull(RING_MS + GOOD_MS + 60) { b.answer.await() }
                    ?: Reaction.NONE.also { b.answer.complete(it) }
                ringResult = r
                if (ringHelp) vm.markInsightSeen(RING_TAP_SEEN)
                ringHelp = false
                // 219.2: the result with what it does
                verdict = when (r) {
                    Reaction.PERFECT -> t("Perfekt: ausgewichen", "Perfect: dodged")
                    Reaction.GOOD -> t("Gut: halber Schaden", "Good: half damage")
                    Reaction.NONE -> t("Verpasst", "Missed")
                }
                if (r == Reaction.PERFECT) vm.play(Sound.BLOCK) else if (r == Reaction.GOOD) vm.play(Sound.BLOCK, 0.5f)
                ring = null
                delay(300)
            }
            Beat.Done -> {
                // the fight is idle now: the line of turns and the spell points are as it stands
                shown = shown.copy(queue = sk.queue(), sp = sk.fighters.associate { it.id to it.sp })
                busy = false
                pick = Pick.Main
                heroAuto = sk.autopilot
                endAsked?.let { win -> if (sk.outcome == Outcome.ONGOING) { busy = true; run.run { sk.testEnd(win) } }; endAsked = null }
                // 241: the autopilot hands back after each of its turns; it plays on while it is still on
                if (!busy && sk.pilotNext) { busy = true; run.run { sk.proceed(run.react) } }
            }
        }
    }
    val verdictAlpha = remember(sk) { Animatable(1f) }
    LaunchedEffect(verdict) { verdictAlpha.snapTo(1f); if (verdict != null) { delay(if (ringResult == Reaction.PERFECT) 2200 else 1200); verdictAlpha.animateTo(0f, tween(SOFT_MS.toInt())); verdict = null; answer = null } }

    /** 259 (2, 3): the light fight played through without pictures; the scene shows where it stands, the board what it brought. */
    fun quick() {
        if (!sk.easy || sk.outcome != Outcome.ONGOING) return
        busy = true
        scope.launch {
            val r = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) { sk.quick() }
            val now = System.currentTimeMillis()
            for (f in sk.fighters) if (f.hp <= 0) downAt.getOrPut(f.id) { now - FALL_MS - FADE_MS }
            shown = SkirmishEvent("", hp = sk.fighters.associate { it.id to it.hp }, places = sk.fighters.associate { it.id to it.place }, intents = LinkedHashMap(sk.intents), queue = sk.queue(), sp = sk.fighters.associate { it.id to it.sp })
            lines += r.events.map { it.text }.filter { it.isNotEmpty() }
            while (lines.size > 300) lines.removeAt(0)
            quickDone = r
            heroAuto = false
            pick = Pick.Main
            if (r.stopped) tip = t("Schnell hält an: unter einem Drittel der Lebenspunkte. Du übernimmst.", "Quick stops: below a third of life points. You take over.")
            busy = false
            opened = true
        }
    }

    fun order(o: Order) {
        busy = true
        pick = Pick.Main
        run.run { sk.act(o, run.react) }
    }

    /** 272 (test mode): the fight won or lost at once, its falls played as usual. */
    fun testEnd(win: Boolean) {
        if (sk.outcome != Outcome.ONGOING) return
        if (busy) { endAsked = win; return }
        busy = true
        pick = Pick.Main
        run.run { sk.testEnd(win) }
    }

    /** A figure on its turn was just put on automatic: it plays now. */
    fun goOn() {
        if (busy || sk.outcome != Outcome.ONGOING) return
        busy = true
        run.run { sk.proceed(run.react) }
    }

    /** A tap anywhere on the scene while the ring closes. */
    fun tap() {
        val r = ring ?: return
        if (r.answer.isCompleted) return
        val off = abs(System.currentTimeMillis() - (ringStart + RING_MS))
        r.answer.complete(when {
            off <= PERFECT_MS -> Reaction.PERFECT
            off <= GOOD_MS -> Reaction.GOOD
            else -> Reaction.NONE
        })
    }

    val clock = rememberTime()
    // 211: on a small phone (under 800 dp high) the log keeps four lines and the buttons stand lower, so the scene keeps its room
    BoxWithConstraints(Modifier.fillMaxSize()) {
    val compact = maxHeight < 800.dp
    val logH = if (compact) LOG_H - 20.dp else LOG_H
    val mainH = if (compact) 48.dp else 52.dp
    val lowH = if (compact) 44.dp else 48.dp
    Column(Modifier.fillMaxSize().background(Color.Black)) {
        BoxWithConstraints(
            Modifier.fillMaxWidth().weight(1f)
                // the zoom stays within the scene, never over the report below
                .clipToBounds()
                .graphicsLayer {
                    val (by, on, w) = hit ?: return@graphicsLayer
                    val to = feetSeen[on] ?: return@graphicsLayer
                    val from = feetSeen[by] ?: to
                    // the blow's direction, from the one striking to the one struck, on the screen
                    val dx = (to.first - from.first) * size.width; val dy = (to.second - from.second) * size.height
                    val d = kotlin.math.hypot(dx, dy).coerceAtLeast(1f)
                    val j = de.bornim.core.HitWeight.jolt(jolt.value) * w.joltDp.dp.toPx()
                    translationX = j * dx / d; translationY = j * dy / d
                    // in by a little more than in the old fight for a kill: the scene of MARS is wider
                    val z = 1f + hitZoom.value * (if (w == de.bornim.core.HitWeight.KILL) 0.10f else de.bornim.core.HitWeight.CRIT.zoom) +
                        0.03f * de.bornim.core.HitWeight.jolt(jolt.value)
                    if (z != 1f) { scaleX = z; scaleY = z; transformOrigin = TransformOrigin(to.first, to.second) }
                }
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { tap() }
        ) {
            val sceneW = maxWidth
            val sceneH = maxHeight
            val density = LocalDensity.current
            val sceneScale = with(density) { maxOf(1, kotlin.math.round(sceneW.toPx() / BattleScene.DESIGN_W).toInt()) }
            val artDp = with(density) { sceneScale.toDp() }
            // 211: on a short scene the figures shrink a little, so the names over the party never meet those of the foes
            val fit = (sceneH / 560.dp).coerceIn(0.7f, 1f)
            // and the foes stand a little higher, so the names under their feet stay clear of those over the party
            // Chef 20.10., 22:29 („mitten in die Sterbeanimation“): a fallen foe holds its place until it has sunk down and
            // faded, only then the rest of the row closes up
            val nowMs = System.currentTimeMillis()
            fun present(f: Fighter) = (shown.hp[f.id] ?: f.hp) > 0 || (f.side == Side.FOES && downAt[f.id]?.let { nowMs - it < FALL_MS + FADE_MS } == true)
            fun alone(side: Side, s: Spot) = sk.fighters.count { it.side == side && shown.places[it.id]?.row == s.row && present(it) } <= 1
            val aspect = sceneH / sceneW
            // 211.13: a still from one camera (preview only): the Kampfort with its figures, the screen lays only what goes over them
            val still = MarsLayout.still?.let { st ->
                val wPx = with(density) { sceneW.roundToPx() }; val hPx = with(density) { sceneH.roundToPx() }
                remember(wPx, hPx, shown.places) { st.draw(wPx, hPx, sk, shown.places) }
            }
            // 211.13: the Kampfort and its figures seen by one camera; the backdrop drawn once a fight, ahead
            val wPx = with(density) { sceneW.roundToPx() }; val hPx = with(density) { sceneH.roundToPx() }
            val cam = if (MarsLayout.camera && still == null) remember(wPx, hPx) { FightCamera(wPx, hPx) } else null
            val wood = vm.probeFoe == Skirmish.Companion.ProbeFoe.WOLVES
            fun stand(side: Side, s: Spot) = FightCamera.stand(side == Side.FOES, s.row == de.bornim.core.Row.BACK, s.slot, alone(side, s)).let { (a, b) ->
                // 242.3 (Chef 13:47 „Mobs stehen sehr eng in einer Linie aufeinander“): a foe alone in the front row with one
                // behind it on the line steps nearer the heroes, so the two stand clear of each other
                val behind = de.bornim.core.Spot(de.bornim.core.Row.BACK, 0)
                if (side == Side.FOES && s.row == de.bornim.core.Row.FRONT && alone(side, s) && alone(side, behind) &&
                    sk.fighters.any { it.side == side && shown.places[it.id]?.row == de.bornim.core.Row.BACK && present(it) }) Pair(a - ALONE_FOE_PULL, b)
                else Pair(a, b)
            }
            // 249 (Chef 14:01 „sehr sprunghaft“): a figure whose place changes glides there instead of jumping
            fun ground(id: String, side: Side, s: Spot) = stand(side, s).let { (a, b) -> glide.at(id, a, b, System.currentTimeMillis()) }
            fun at(id: String, side: Side, s: Spot): Pair<Float, Float> = if (cam != null) ground(id, side, s).let { (a, b) -> cam.feet(a, b) }.let { (x, y) -> (x / wPx).toFloat() to (y / hPx).toFloat() }
                else placeAt(side, s, alone(side, s), aspect).let { (x, y) -> if (side == Side.FOES) x to y - (1f - fit) * 0.3f else x to y }
                    .let { (x, y) -> glide.at(id, x.toDouble(), y.toDouble(), System.currentTimeMillis()).let { (gx, gy) -> gx.toFloat() to gy.toFloat() } }
            if (still != null) Canvas(Modifier.fillMaxSize()) { drawImage(Bitmaps.of(still.img)) }
            else if (cam != null) {
                val backdrop by produceState<de.bornim.core.art.PixelImage?>(null, wPx, hPx, wood) {
                    value = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
                        if (wood) Kampfort.forest(wPx, hPx, BattleScene.Spot.CLEARING, BattleScene.Light.DAY, false, 0)
                        else Kampfort.cave(wPx, hPx, CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72)
                    }
                }
                backdrop?.let { b -> Canvas(Modifier.fillMaxSize()) { drawImage(Bitmaps.of(b)) } }
            }
            else CaveBackground(CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72, false, sceneScale, Modifier.fillMaxSize())
            val shade = if (cam != null && wood) null else Color(CaveScene.tint(CaveScene.Spot.HALL, CaveScene.Light.TORCH, false))
            val grid = MarsLayout.grid || (MarsLayout.gridSwitch && vm.showGrid)
            if (cam != null) { if (grid) CamGrid(cam) }
            else if (MarsLayout.guides || grid) Guides(aspect, fit, grid)
            if (!ready) return@BoxWithConstraints
            val now = System.currentTimeMillis()
            // while a target is picked, those who can be picked light up and the others dim (72.10a.6)
            // (the fight's own state is only read while it waits for an order, never while it runs on its thread)
            val aimed: Set<String> = if (busy || sk.outcome != Outcome.ONGOING) emptySet() else {
                val me = sk.current
                when (val p = pick) {
                    Pick.Target -> sk.targets(me).map { it.id }.toSet()
                    is Pick.SkillAt -> sk.aimAt(me, p.skill).map { it.id }.toSet()
                    is Pick.DrinkAt -> sk.fighters.filter { it.side == me.side && it.standing }.map { it.id }.toSet()
                    else -> emptySet()
                }
            }
            val actingId = if (sk.outcome == Outcome.ONGOING) shown.queue.firstOrNull() else null
            // back to front, so the nearer figures stand before the farther
            val figures = sk.fighters.filter { shown.places[it.id] != null }.sortedBy { at(it.id, it.side, shown.places[it.id]!!).second }
            // 229.3 (Chef 14:50: kein Ring überdeckt eine Figur): all rings on the ground first, under every figure
            for (f in figures) {
                val spot = shown.places[f.id]!!
                val down = (shown.hp[f.id] ?: f.hp) <= 0
                // the figure acting: a golden ring on the ground (72.10a.4); a target that can be picked: a pale one
                // 242 (Chef 11:52): under the camera the place's circle as the camera sees it, under the figure, which stands on it
                val ringColor = (if (down) null else if (f.id == actingId) Veil.bright else if (f.id in aimed) Veil.text
                    else if (MarsLayout.heroRings && f.side == Side.PARTY) friendColor(sk, f).copy(alpha = 0.8f) else null)
                    ?: continue
                // 242.1 (Chef 12:32): an animal longer than the place gets a ring that all four paws stand inside
                val span = f.monster?.id?.takeIf { MonsterArt.isBeast(it) }?.let { de.bornim.core.art.BeastArt.footSpan(it, MonsterLook(0)) * FightCamera.FOE_SIZE * (if (f.boss) 1.0 else 0.88) }
                val ringR = span?.let { maxOf(RING_M, it / 200 + PAW_ROOM_M) } ?: RING_M
                val thick = if (f.id == actingId) 2.5.dp else 2.dp
                if (cam != null) ground(f.id, f.side, spot).let { (a, b) -> CamRing(cam, a, b, ringColor, thick, ringR) }
                else {
                    val (px, py) = still?.feet?.get(f.id) ?: at(f.id, f.side, spot)
                    GroundRing(sceneW * px, sceneH * py, 74.dp, ringColor, thick)
                }
            }
            val signs = mutableListOf<Sign>()
            // 260: the roll is drawn last of the scene, over the intents
            var rollAt: Triple<Dp, Dp, RollInfo>? = null
            for (f in figures) {
                val spot = shown.places[f.id]!!
                val (px, py) = still?.feet?.get(f.id) ?: at(f.id, f.side, spot)
                feetSeen[f.id] = px to py
                val hp = shown.hp[f.id] ?: f.hp
                val down = hp <= 0
                // a short step towards the one it strikes, and back
                val beast = f.monster?.id?.let { MonsterArt.isBeast(it) } == true
                val lungeMs = (if (beast) BEAST_LUNGE_MS else LUNGE_MS) * MarsLayout.slow
                val (dx, dy) = lunge?.takeIf { it.first == f.id && !casting && now - lungeAt < lungeMs }?.let { (_, to) ->
                    val tf = sk.byIdOrNull(to) ?: return@let 0f to 0f
                    val tp = shown.places[to] ?: return@let 0f to 0f
                    val (tx, ty) = at(tf.id, tf.side, tp)
                    val p = (now - lungeAt).toFloat() / lungeMs
                    // an animal leaps out to the bite at half the time and draws back; others take a short step
                    val k = if (beast) BEAST_REACH * (if (p < 0.5f) smooth(p * 2) else 1f - smooth((p - 0.5f) * 2))
                        else sin(p * Math.PI.toFloat()) * 0.22f
                    (tx - px) * k to (ty - py) * k
                } ?: (0f to 0f)
                val hurt = hurtAt[f.id]?.let { (1f - (now - it) / 450f).coerceIn(0f, 1f) } ?: 0f
                val shake = if (hurt > 0f) (sin(now / 30f) * 4f * hurt).dp else 0.dp
                val x = sceneW * (px + dx) + shake
                val y = sceneH * (py + dy)
                // 205: a friend who falls lies there; a foe topples over and fades away
                val fellFor = if (down) now - (downAt[f.id] ?: 0L) else 0L
                val gone = if (down && f.side == Side.FOES) ((fellFor - FALL_MS).toFloat() / FADE_MS).coerceIn(0f, 1f) else 0f
                if (gone >= 1f) continue
                // 208: a foe in the shadows is seen only dimly, but can still be struck
                val alpha = if (down) 1f - gone else if (f.hidden) 0.4f else if (aimed.isNotEmpty() && f.id !in aimed) 0.55f else 1f
                // 72.10a.11: drawn with the weapon in hand
                val hero = f.looks
                // 242.1: how far an animal's paws reach, for its shadow
                val span = f.monster?.id?.takeIf { MonsterArt.isBeast(it) }?.let { de.bornim.core.art.BeastArt.footSpan(it, MonsterLook(0)) * FightCamera.FOE_SIZE * (if (f.boss) 1.0 else 0.88) }
                var tall: Dp
                if (still != null) tall = with(density) { (still.tall[f.id] ?: 0f).toDp() }
                else if (hero != null) {
                    val s = 0.62f * depth(spot) * fit
                    // 211.13: as large as its distance from the camera makes it
                    val px1 = cam?.let { c -> ground(f.id, f.side, spot).let { (a, b) -> with(density) { (c.perCm(a, b) / HeroBattle.PX).toFloat().toDp() } } } ?: (artDp * s)
                    val idle = ((clock / 110) % 1000).toInt()
                    val img = if (down) {
                        val n = HeroBattle.frameCount(hero, HeroFigure.Act.DIE).coerceAtLeast(1)
                        val i = (fellFor / 95L).toInt().coerceAtMost(n - 1)
                        HeroBattle.ready(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, 0, i) ?: HeroBattle.frame(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, 0, i)
                    } else (if (casting) castFrame(hero, lunge?.takeIf { it.first == f.id }?.let { now - lungeAt })
                        else swingFrame(hero, lunge?.takeIf { it.first == f.id }?.let { now - lungeAt }, lungeAt))
                        // 249 (Chef 16:37 „Schritte als nächster Teil“): stepping to the new place, one whole stride on the way
                        ?: glide.since(f.id, System.currentTimeMillis())?.takeIf { MarsLayout.look249 }?.let { t -> HeroBattle.ready(hero, HeroFigure.Act.STEP, HeroFigure.Strike.SLASH, 0, (t * HeroFigure.STEP_FRAMES / glide.ms).toInt()) }
                        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, idle)
                        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                        ?: HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                    // 211.13: under the camera the name stands just over the head (the frame leaves room for the raised weapon)
                    tall = px1 * (if (cam != null) 140f else 150f)
                    pxSeen[f.id] = px1
                    Shadow(x, y, px1 * 90f, alpha, flat = cam != null)
                    Box(Modifier.offset(x = x - px1 * HeroBattle.ANCHOR_X.toFloat(), y = y - px1 * HeroBattle.GROUND.toFloat())) {
                        PixelSprite(img, px1, alpha = alpha, shade = shade, hurt = hurt)
                    }
                } else {
                    val m = f.monster!!
                    val look = MonsterLook(0)
                    val s = (if (f.boss) 0.8f else 0.66f) * depth(spot) * fit
                    // 211.13: foes 1.5 times true to life (animals on top of their own 0.88), at their distance
                    val px1 = cam?.let { c -> ground(f.id, f.side, spot).let { (a, b) -> with(density) { (c.perCm(a, b) * FightCamera.FOE_SIZE * (if (f.boss) 1.0 else 0.88) / 0.66).toFloat().toDp() } } } ?: (artDp * s)
                    val r = ring
                    // Grak winds up while the ring closes on his target
                    val winding = r != null && shown.actor == f.id
                    val dies = if (down) MonsterArt.frameCount(m.id, look, Act.DIE, 0) else 0
                    val img = if (dies > 0) {
                        MonsterArt.shownFrame(m.id, look, Act.DIE, 0, (fellFor * dies / FALL_MS).toInt().coerceAtMost(dies - 1))
                    } else if (lunge?.first == f.id && now - lungeAt < lungeMs && MonsterArt.frameCount(m.id, look, Act.ATTACK, 0) > 1) {
                        // 19e (Rückläufer t46.6 „Einen Biss sehe ich nicht“): the attack's own frames over the step forward,
                        // landing at its far end, as in the old fight
                        val n = MonsterArt.frameCount(m.id, look, Act.ATTACK, 0)
                        val strike = MonsterArt.strikeFrame(m.id, look, 0).coerceIn(1, n - 1)
                        val p = (now - lungeAt).toFloat() / lungeMs
                        val i = if (p < 0.5f) (p * 2 * strike).toInt() else strike + ((p - 0.5f) * 2 * (n - 1 - strike)).toInt()
                        MonsterArt.shownFrame(m.id, look, Act.ATTACK, 0, i.coerceIn(0, n - 1))
                    } else if (winding && MonsterArt.isNewStyle(m.id)) {
                        val strike = MonsterArt.strikeFrame(m.id, look, 0)
                        val p = ((now - ringStart).toFloat() / RING_MS).coerceIn(0f, 1f)
                        MonsterArt.shownFrame(m.id, look, Act.ATTACK, 0, (p * (strike - 1).coerceAtLeast(0)).toInt())
                    } else {
                        val n = MonsterArt.frameCount(m.id, look, Act.IDLE, 0).coerceAtLeast(1)
                        MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, breaths.getOrPut(f.id) { Breath(Breath.offset(f.id)) }.index(clock, 86.0) % n)
                    }.also { if (dies > 0 || winding || (lunge?.first == f.id && now - lungeAt < lungeMs)) breaths.getOrPut(f.id) { Breath(Breath.offset(f.id)) }.moving(clock) }
                    val frameW = if (MonsterArt.isDoll(m.id)) de.bornim.core.art.FoeArt.W else img.width
                    val spr = px1 / MonsterArt.fine(m.id).toFloat()
                    // 211: names and bars at the head, not at the top of the frame (Grak's frame leaves room for the raised club)
                    tall = px1 * (MonsterArt.groundLine(m.id).toFloat() * 0.85f).let { t ->
                        // 211.13: under the camera the head is where the standing frame's first drawn row is
                        if (cam != null) MonsterArt.groundLine(m.id).toFloat() - headRow(m.id, MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, 0)) / MonsterArt.fine(m.id).toFloat() + 2f
                        else if (MonsterArt.isDoll(m.id)) minOf(t, MonsterArt.groundLine(m.id).toFloat() - MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, 0).oy / MonsterArt.fine(m.id).toFloat() + 2f) else t
                    }
                    // 242.1: an animal's shadow as long as it stands, from its front paws to its hind ones
                    val paws = if (MarsLayout.hardShadow) 0.dp else px1 * ((span ?: 0.0) / FightCamera.FOE_SIZE / (if (f.boss) 1.0 else 0.88) / de.bornim.core.art.BeastArt.PX * 2).toFloat()
                    Shadow(x, y, maxOf(px1 * 70f, paws), alpha, flat = cam != null)
                    Box(Modifier.offset(x = x - px1 * MonsterArt.anchorX(m.id, frameW).toFloat(), y = y - px1 * MonsterArt.groundLine(m.id).toFloat())) {
                        Box(Modifier.offset(x = spr * img.ox, y = spr * img.oy)) {
                            PixelSprite(img, spr, alpha = alpha, shade = shade, overflow = true, hurt = hurt)
                        }
                    }
                }
                tallSeen[f.id] = tall
                // life bar over the head; 211: one rule for all names, over the head or under the feet (MarsLabels)
                val above = !MarsLabels.below
                val bar = !down && !(MarsLabels.barsOnlyFoes && f.side == Side.PARTY)
                if (bar) LifeBar(x, y - tall - 8.dp, hp, f.maxHp)
                // 240.1 (Chef 13:44 „Namen sind jetzt wieder dauerhaft an“): while picking, only those that can be picked carry their name
                if (!down && (f.id in aimed || now < namesUntil)) NameTag(x, if (above) y - tall - (if (bar) 28.dp else 24.dp) else y + 6.dp, sk.label(f, lang), f.id == actingId,
                    if (f.id in aimed) 1f else softAlpha(now, namesUntil))
                // 211.15: a long press on the figure tells who it is (a friend: class and weapon; a foe: its intent with the target);
                // never while the ring wants its tap anywhere
                if (!down && ring == null) Box(Modifier.offset(x = x - 24.dp, y = y - tall).size(48.dp, maxOf(tall, 48.dp)).pointerInput(f.id) {
                    detectTapGestures(onLongPress = { tip = whoIs(sk, f, shown.intents[f.id], lang); namesUntil = System.currentTimeMillis() + NAMES_MS })
                })
                // the roll with its numbers, briefly at its target (72.10a.10)
                rollShown.value?.takeIf { vm.showRolls && it.first == f.id && now - it.third < ROLL_MS + SOFT_MS }?.let { (_, info, _) ->
                    rollAt = Triple(x, y - tall - (if (above) 78.dp else 62.dp), info)
                }
                // the announced intent over the foe, the aim over its target
                // 211: with its target ("!! Schwerer Hieb → Mira")
                // 211.9: two side by side at one height; the right one's sign stands a line higher, so the two never overlap
                val lift = if (spot.slot == 1 && !MarsLayout.offset && !alone(f.side, spot)) 24.dp else 0.dp
                // 211.15: short ("! Anspringen"), in the color of the friend it is aimed at (211.16), the target in the log and on a long press
                shown.intents[f.id]?.let { (intent, at) ->
                    val aim = at.firstOrNull()?.let { sk.byIdOrNull(it) }
                    val color = aim?.let { friendColor(sk, it) }
                    val more = aim?.let { "${sk.label(f, lang)}: ${intent.name(lang)} → ${sk.label(it, lang)}" }
                    // 211.13: under the camera laid out after all figures, so no two overlap (Sokrates 23:31, 1)
                    if (cam != null) signs += Sign(x, y - tall - (if (above) 52.dp else 36.dp), intent, color, more)
                    else IntentSign(x, maxOf(y - tall - (if (above) 52.dp else 36.dp) - lift, 34.dp), sceneW, intent, color, more, lang) { tip = it }
                }
                // 242 (Chef 11:52): just over the head, over the name while names show
                val named = aimed.isNotEmpty() || now < namesUntil
                if (!down && !MarsLayout.heroRings && shown.intents.values.any { f.id in it.second }) {
                    // 242 (Chef 12:01 „Dreieck unten“): lying on the ground in front of the feet, inside the ring, the same for every height
                    if (cam != null) ground(f.id, f.side, spot).let { (a, b) -> CamAim(cam, a, b, friendColor(sk, f)) }
                    else AimMark(x, if (named && above) y - tall - 36.dp else y - tall * HEAD_SHARE, friendColor(sk, f))
                }
                // the ring closing on the attacked figure (72.11)
                ring?.takeIf { it.target == f.id }?.let { RingAround(x, y - tall * 0.45f, tall * 0.55f, ((now - ringStart).toFloat() / RING_MS)) }
                // 219: on the first ring, a word over it
                if (ringHelp) ring?.takeIf { it.target == f.id }?.let {
                    Box(Modifier.offset(x = x - 80.dp, y = y - tall - 64.dp).wrapContentSize(Alignment.TopStart, unbounded = true)
                        .background(Color.Black.copy(alpha = 0.8f)).border(1.dp, Veil.gold).padding(horizontal = 8.dp, vertical = 3.dp)) {
                        Txt(MarsTips.tapNow(lang), size = 14.sp, color = Veil.bright)
                    }
                }
            }
            bleed?.let { b ->
                val to = feetSeen[b.on] ?: return@let
                val from = feetSeen[b.by] ?: to
                val tall = tallSeen[b.on] ?: return@let
                Canvas(Modifier.matchParentSize()) {
                    val fx = to.first * size.width; val fy = to.second * size.height
                    // from its chest, away from the one striking (on the screen), a little upwards as in the old fight
                    val dx = fx - from.first * size.width; val dy = (fy - from.second * size.height) * 0.5f - 0.3f * kotlin.math.hypot(fx - from.first * size.width, fy - from.second * size.height)
                    val base = if (dx == 0f && dy == 0f) -25.0 else Math.toDegrees(kotlin.math.atan2(dy.toDouble(), dx.toDouble()))
                    // the old fight's drops are sized for its 184 dp frame, in which a wolf stands some 40 units tall
                    drawBloodSpray(b.seed * 31, bloodT.value, Offset(fx, fy - tall.toPx() * 0.55f), fy, vm.bloodLevel, b.gore, tall.toPx() / 40f, b.crit, b.hurt.coerceIn(0f, 1f), base)
                }
            }
            spellFx?.let { (fx, by, on) ->
                val to = feetSeen[on] ?: return@let
                val from = feetSeen[by] ?: to
                val tallTo = tallSeen[on] ?: return@let
                val tallFrom = tallSeen[by] ?: tallTo
                with(density) {
                    val tx = (sceneW * to.first).toPx(); val ty = (sceneH * to.second).toPx()
                    val sx = (sceneW * from.first).toPx(); val sy = (sceneH * from.second).toPx()
                    // a hero's spell leaves from the staff's crystal, the wand or the hand, on the frame that lets it go,
                    // as in the classic fight; anything else from chest to chest. Sized like the blood by the one it falls on.
                    val px = pxSeen[by]?.toPx()
                    val launch = sk.byIdOrNull(by)?.looks?.takeIf { px != null }?.let { HeroBattle.launch(it, HeroFigure.Act.CAST, HeroBattle.castVariant(it)) }
                    val source = launch?.let { Offset(sx + px!! * (it.x - HeroBattle.ANCHOR_X).toFloat(), sy + px * (it.y - HeroBattle.GROUND).toFloat()) }
                        ?: Offset(sx, sy - tallFrom.toPx() * 0.55f)
                    BattleFxLayer(fx, spellKey, Offset(tx, ty - tallTo.toPx() * 0.55f), source, tallTo.toPx() / 40f,
                        Modifier.matchParentSize(), startDelay = if (launch != null) HeroBattle.strikeFrame(HeroFigure.Strike.CAST) * CAST_FRAME_MS * MarsLayout.slow else 0L,
                        foeGround = ty, heroGround = sy)
                }
            }
            for ((sign, y) in layOut(signs, sceneW, lang)) IntentSign(sign.x, y, sceneW, sign.intent, sign.color, sign.more, lang) { tip = it }
            rollAt?.let { (x, y, info) -> RollTag(x, y, sceneW, info, lang, softAlpha(now, rollShown.value!!.third + ROLL_MS + SOFT_MS)) }
            TurnBar(sk, shown.queue, shown.hp, lang, Modifier.align(Alignment.TopStart).padding(6.dp))
            verdict?.let { v ->
                Box(Modifier.align(Alignment.TopCenter).padding(top = 44.dp).alpha(verdictAlpha.value).background(Color.Black.copy(alpha = 0.7f)).border(1.dp, Veil.gold).padding(horizontal = 14.dp, vertical = 6.dp)) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Txt(v, size = 22.sp, color = if (ringResult == Reaction.PERFECT) Veil.bright else if (ringResult == Reaction.GOOD) Veil.text else Veil.warn)
                        answer?.let { Txt(it, size = 15.sp, color = Veil.gold) }
                    }
                }
            }
            // 229.1: the grid sign, lower right, half seen; away while the ring wants a tap anywhere or a tip is shown
            if (MarsLayout.gridSwitch && ring == null && tip == null && verdict == null) {
                GridSwitch(vm.showGrid, Modifier.align(Alignment.BottomEnd).padding(4.dp)) { vm.toggleGrid() }
                // 260 (Chef 18:04): the rolls on and off, left of the grid sign
                RollSwitch(vm.showRolls, Modifier.align(Alignment.BottomEnd).padding(end = 52.dp, bottom = 4.dp)) { vm.toggleRolls() }
            }
            // 272: lose or win at once, test mode only, left of the rolls sign in the same row
            if (vm.testMode && opened && sk.outcome == Outcome.ONGOING && ring == null && tip == null && verdict == null)
                TestEndSwitches(endAsked, Modifier.align(Alignment.BottomEnd).padding(end = 100.dp, bottom = 4.dp)) { testEnd(it) }
            // 259 (2): "Schnell" in a light fight on the party's turn, lower left, half seen like the grid sign
            if (sk.easy && opened && !busy && sk.outcome == Outcome.ONGOING && ring == null && tip == null && verdict == null) {
                Box(Modifier.align(Alignment.BottomStart).padding(4.dp).background(Color.Black.copy(alpha = 0.35f)).border(1.dp, Veil.gold.copy(alpha = 0.6f))
                    .pointerInput(Unit) { detectTapGestures(onTap = { quick() }, onLongPress = { tip = MarsTips.quick(lang) }) }.padding(horizontal = 10.dp, vertical = 8.dp)) {
                    Txt(t("Schnell ›", "Quick ›"), size = 14.sp, color = Veil.gold)
                }
            }
            if (ring != null) Txt(t("Tippen, wenn der große Ring auf dem kleinen liegt", "Tap when the large ring lies on the small one"), Modifier.align(Alignment.BottomCenter).padding(bottom = 6.dp), size = 14.sp, color = Veil.dim)
            // 204: the explanation of a button pressed long, over the lower edge of the scene, so the orders keep their place
            tip?.takeIf { ring == null }?.let { text ->
                Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth().padding(8.dp).alpha(tipAlpha.value).background(Color.Black.copy(alpha = 0.85f)).border(1.dp, Veil.gold).clickable { tip = null }.padding(horizontal = 10.dp, vertical = 6.dp)) {
                    Txt(text, size = 15.sp)
                }
            }
            // 211: the whole log, a tap closes it
            if (fullLog) {
                val all = androidx.compose.foundation.rememberScrollState()
                LaunchedEffect(Unit) { all.scrollTo(all.maxValue) }
                Column(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.92f)).border(1.dp, Veil.gold).clickable { fullLog = false }.padding(10.dp)) {
                    Txt(t("Kampfbericht", "Battle log"), size = 16.sp, color = Veil.gold)
                    Column(Modifier.weight(1f).verticalScroll(all)) { for (l in lines) LogLine(l, true) }
                    Txt(t("Tippen schließt", "Tap to close"), size = 13.sp, color = Veil.dim)
                }
            }
        }
        // words and orders
        Column(Modifier.fillMaxWidth().background(Color.Black).border(1.dp, Veil.rim).padding(10.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            // 211: five lines that wrap, the newest at the bottom and bright, the older dimmed, damage in gold; a tap opens the whole log
            Column(Modifier.fillMaxWidth().height(logH).border(1.dp, Veil.rim.copy(alpha = 0.35f)).clickable { fullLog = true }.padding(horizontal = 6.dp, vertical = 2.dp)) {
                Column(Modifier.weight(1f).verticalScroll(linesScroll)) {
                    for ((i, l) in lines.withIndex()) LogLine(l, i == lines.lastIndex)
                }
                if (lines.size > 3) Txt(t("▴ ganzer Bericht", "▴ whole log"), Modifier.align(Alignment.End), size = 11.sp, color = Veil.gold)
            }
            // 211: each of the party in a box: name, bar, life and spell points
            val party = sk.fighters.filter { it.side == Side.PARTY }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                for (p in party) PartyBox(p.name(lang), shown.hp[p.id] ?: p.hp, p.maxHp, if (p.hero!!.maxSp > 0) shown.sp[p.id] ?: p.sp else null, p.hero!!.maxSp, lang,
                    friendColor(sk, p), Modifier.weight(1f).pointerInput(p.id) {
                        detectTapGestures(onLongPress = { tip = whoIs(sk, p, null, lang); namesUntil = System.currentTimeMillis() + NAMES_MS })
                    })
            }
            val merc = party.firstOrNull { it.id == "merc" }
            // the orders keep one height whatever shows, so the scene above never jumps
            Column(Modifier.fillMaxWidth().height(if (compact) ORDERS_H - 8.dp else ORDERS_H), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            when {
                // 259 (3): "Schnell" already at the start of a light fight
                !opened && quickDone == null -> {
                    Txt(t("Leichter Kampf: Stufe %d gegen Herausforderungsgrad %s.", "Light fight: level %d against challenge rating %s.")
                        .format(party.first().hero!!.level, sk.fighters.filter { it.side == Side.FOES }.maxBy { Skirmish.crValue(it.monster!!.cr) }.monster!!.cr), size = 14.sp)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        PixelButton(t("Kämpfen", "Fight"), Modifier.weight(1f), enabled = ready && !sk.started, size = 15.sp, height = mainH) { opened = true }
                        PixelButton(t("Schnell", "Quick"), Modifier.weight(1f), enabled = ready && !sk.started, size = 15.sp, height = mainH, onLongClick = { tip = MarsTips.quick(lang) }) { quick() }
                    }
                }
                !busy && sk.outcome != Outcome.ONGOING -> {
                    val won = sk.outcome == Outcome.WON
                    // 256: a won fight, the victory piece, as in the old fight
                    LaunchedEffect(won) { if (won) vm.music.victory() }
                    // 259: "Grak" only against Grak (the other probe foes said so too); placeholder for the others, final with Homer
                    Txt(if (won && sk.fighters.any { it.monster?.id == Skirmish.GRAK }) t("Grak ist besiegt.", "Grak is beaten.") else if (won) t("Sieg.", "Victory.") else t("Der Kampf ist verloren.", "The fight is lost."), size = 18.sp, color = if (won) Veil.bright else Veil.warn)
                    if (sk.knockouts > 0) Txt(t("Söldner bewusstlos: ", "Mercenaries knocked out: ") + sk.knockouts, size = 14.sp)
                    // 259 (2, 4): the board of a quick fight; the probe gives no loot and no experience
                    quickDone?.let { r ->
                        Txt(party.joinToString(" · ") { p -> p.name(lang) + " −" + (r.lost[p.id] ?: 0) + t(" LP", " HP") } +
                            t(" · Probekampf: keine Beute, keine EP", " · trial fight: no loot, no XP"), size = 13.sp, color = Veil.dim)
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        PixelButton(t("Nochmal", "Again"), Modifier.weight(1f), size = 15.sp) { vm.startProbe(vm.probeClass) }
                        PixelButton(t("Zurück", "Back"), Modifier.weight(1f), size = 15.sp) { vm.probe = null }
                    }
                }
                busy -> Txt(t("…", "…"), size = 14.sp, color = Veil.dim)
                else -> {
                    val f = sk.current
                    if (sk.fighters.any { it.side != f.side && it.standing } && sk.targets(f).isEmpty())
                        Txt(t("Kein Ziel in Sicht: der Gegner ist in den Schatten verschwunden. Abwehr.", "No target in sight: the foe has vanished into the shadows. Defend."), size = 14.sp, color = Veil.warn)
                    val back = Opt(t("Zurück", "Back")) { pick = Pick.Main }
                    when (val p = pick) {
                        Pick.Main -> Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            val reach = sk.targets(f)
                            PixelButton(t("Angriff", "Attack"), Modifier.weight(1f), enabled = reach.isNotEmpty(), size = 15.sp, height = mainH, onLongClick = { tip = MarsTips.attack(lang) }) {
                                if (reach.size == 1) order(Order.Attack(reach[0].id)) else pick = Pick.Target
                            }
                            PixelButton(t("Können", "Skills"), Modifier.weight(1f), enabled = sk.moves(f).isNotEmpty(), size = 15.sp, height = mainH, onLongClick = { tip = MarsTips.skills(lang) }) { pick = Pick.Skills }
                            PixelButton(t("Tasche", "Bag"), Modifier.weight(1f), enabled = sk.drinkable().isNotEmpty(), size = 15.sp, height = mainH, onLongClick = { tip = MarsTips.bag(lang) }) { pick = Pick.Bag }
                            // 72.10a.8: a swap is half a turn, once per turn; 72.10a.11: so is drawing the other weapon
                            PixelButton(t("Wechsel", "Switch"), Modifier.weight(1f), enabled = sk.canSwap(f) || sk.canDraw(f), size = 15.sp, height = mainH, onLongClick = { tip = MarsTips.place(lang) }) { pick = Pick.Place }
                        }
                        Pick.Target -> Choices(sk.targets(f).map { target -> Opt(targetLabel(sk, target, lang)) { order(Order.Attack(target.id)) } } + back, height = lowH)
                        // 182: only the rows count (the place within a row changes nothing); each choice says who stands there now
                        Pick.Place -> {
                            val spots = Spot.ALL.filter { it.row != f.place.row }.filter { s ->
                                // two free places of a row read alike: offer one
                                sk.fighters.any { it.side == f.side && it.place == s && it.standing } ||
                                    Spot.ALL.first { it.row == s.row && sk.fighters.none { o -> o.side == f.side && o.place == it && o.standing } } == s
                            }
                            // 72.10a.11: the other weapon alone, or on the way to the other row in the same half turn
                            val spare = f.spare?.takeIf { sk.canDraw(f) }?.name(lang)
                            Choices(spots.flatMap { s ->
                                val who = sk.fighters.firstOrNull { it.side == f.side && it.place == s && it.standing }
                                val label = spotName(s, lang) + (who?.let { " ⇄ " + it.name(lang) } ?: t(" (frei)", " (free)"))
                                listOfNotNull(
                                    Opt(label, sk.canSwap(f)) { order(Order.Swap(s)) },
                                    spare?.let { w -> Opt("$label + $w", sk.canSwap(f)) { order(Order.Swap(s, draw = true)) } },
                                )
                            } + listOfNotNull(spare?.let { w -> Opt(t("Waffe: ", "Weapon: ") + w) { order(Order.Draw) } }) + back, height = lowH)
                        }
                        Pick.Skills -> Choices(onTip = { tip = it }, items = sk.moves(f).map { sk1 ->
                            val extra = when (sk1.cost) {
                                SkillCost.SPELL_POINTS -> " ${sk1.amount}"
                                SkillCost.PER_BATTLE, SkillCost.PER_REST -> " ×${f.uses[sk1] ?: 0}"
                                else -> ""
                            }
                            Opt(sk1.title(lang) + extra, sk.blocked(f, sk1) == null, MarsTips.skill(sk1, lang)) {
                                val reach = sk.aimAt(f, sk1)
                                if (Moves.aim(sk1) == Aim.SELF) order(Order.Use(sk1, f.id))
                                else if (reach.size == 1) order(Order.Use(sk1, reach[0].id))
                                else pick = Pick.SkillAt(sk1)
                            }
                        } + back, height = lowH)
                        is Pick.SkillAt -> Choices(sk.aimAt(f, p.skill).map { target ->
                            val row = if (Moves.aim(p.skill) == Aim.ROW) (if (target.place.row == Line.FRONT) t("Reihe vorn: ", "Front row: ") else t("Reihe hinten: ", "Back row: ")) else ""
                            Opt(row + targetLabel(sk, target, lang)) { order(Order.Use(p.skill, target.id)) }
                        } + back, height = lowH)
                        Pick.Bag -> Choices(sk.drinkable().map { id ->
                            Opt("${Items[id].name(lang)} ×${sk.potions[id]}", tip = MarsTips.item(id, lang)) { pick = Pick.DrinkAt(id) }
                        } + back, onTip = { tip = it }, height = lowH)
                        is Pick.DrinkAt -> Choices(sk.fighters.filter { it.side == f.side && it.standing }.map { target ->
                            Opt(target.display(lang) + "  ${target.hp}/${target.maxHp}") { order(Order.Drink(p.item, target.id)) }
                        } + back, height = lowH)
                    }
                }
            }
            // at the bottom always, so it stays under the finger; while a target or a place is picked, its choices take it
            Spacer(Modifier.weight(1f))
            if (opened && sk.outcome == Outcome.ONGOING && pick == Pick.Main) Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                PixelButton(t("Abwehr", "Defend"), Modifier.weight(1f), enabled = !busy, size = 14.sp, height = lowH, onLongClick = { tip = MarsTips.defend(lang) }) { order(Order.Wait) }
                // 72.10a.9: the fighter's role, drawing the announced blows onto himself
                if (!busy && sk.current.hero?.cls == CharClass.FIGHTER)
                    PixelButton(t("Decken", "Cover"), Modifier.weight(1f), enabled = sk.guardable(sk.current).isNotEmpty(), size = 14.sp, height = lowH, onLongClick = { tip = MarsTips.cover(lang) }) { order(Order.Guard) }
                if (merc != null) {
                    var auto by remember(sk) { mutableStateOf(merc.auto) }
                    PixelButton(t("Söldner ", "Söldner ") + if (auto) t("Auto", "auto") else t("selbst", "manual"), Modifier.weight(1f), selected = auto, size = 14.sp, height = lowH, onLongClick = { tip = MarsTips.merc(lang) }) {
                        merc.auto = !merc.auto; auto = merc.auto
                        if (auto && sk.current === merc) goOn()
                    }
                }
                // 241.2 (Chef 15:14): like the Söldner's button: always live, framed while on, its words saying which;
                // switched off it takes hold before the hero's next turn, even while the foes play
                PixelButton(t("Held ", "Hero ") + if (heroAuto) t("Auto", "auto") else t("selbst", "manual"), Modifier.weight(1f), selected = heroAuto, size = 14.sp, height = lowH, onLongClick = { tip = MarsTips.autopilot(lang) }) {
                    // 241.2 (Chef 17:56): judged by the life points the bar shows, not the ones the fight has already reached
                    val lead = sk.fighters.first { it.side == Side.PARTY }
                    val hp = shown.hp[lead.id] ?: lead.hp
                    val why = sk.autopilotBlocked(hp)
                    if (heroAuto) { sk.setAutopilot(false); heroAuto = false }
                    // 211: why not, at the lower edge of the scene like a long press (a toast covered the line of turns)
                    else if (why != null) tip = why(lang)
                    else { heroAuto = sk.setAutopilot(true, hp); if (heroAuto && sk.pilotNext) goOn() }
                }
            }
            }
        }
    }
    }
}

/** Choices in the two rows of the orders: two side by side, three when there are more than four. */
@Composable
private fun Choices(items: List<Opt>, onTip: (String) -> Unit = {}, height: Dp = 48.dp) {
    val cols = if (items.size > 4) 3 else 2
    for (row in items.chunked(cols)) Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        for (o in row) PixelButton(o.label, Modifier.weight(1f), enabled = o.enabled, size = 14.sp, height = height, onLongClick = o.tip?.let { tip -> { onTip(tip) } }, onClick = o.go)
        repeat(cols - row.size) { Spacer(Modifier.weight(1f)) }
    }
}

/** 211.16: each friend's own color, for the intents and aims at it; as many colors as friends, none gold or red. */
private val FRIEND_COLORS = listOf(Color(0xFF7FB6E8), Color(0xFFCB9BE3), Color(0xFF6FCFC0))

private fun friendColor(sk: Skirmish, f: Fighter): Color {
    val i = sk.fighters.filter { it.side == Side.PARTY }.indexOf(f)
    return if (i < 0) Veil.bright else FRIEND_COLORS[i % FRIEND_COLORS.size]
}

/** 242: where a hero's head is, as a share of its frame's height over the feet (the frame leaves room for the raised weapon). */
private const val HEAD_SHARE = 0.85f

/** How long the names stay after a long press. */
private const val NAMES_MS = 3_000L

/**
 * 211.15: who a figure is, on a long press: a friend with class, weapon in hand, spell points and a half turn left
 * (what the golden line said); a foe with its announced intent and target.
 */
private fun whoIs(sk: Skirmish, f: Fighter, intent: Pair<Intent, List<String>>?, lang: Lang): String {
    val de = lang == Lang.DE
    val h = f.hero ?: return sk.label(f, lang) + (intent?.let { (i, at) ->
        ": " + i.name(lang) + (at.firstOrNull()?.let { sk.byIdOrNull(it) }?.let { " → " + sk.label(it, lang) } ?: "")
    } ?: "")
    return f.name(lang) + " · " + h.cls.title(lang) + (f.weapon?.let { " · " + it.name(lang) } ?: "") +
        (if (h.maxSp > 0) " · ${if (de) "ZP" else "SP"} ${f.sp}/${h.maxSp}" else "") +
        // 72.10a.8: after a swap, half the turn is left
        (if (sk.outcome == Outcome.ONGOING && sk.current === f && !sk.canSwap(f)) (if (de) " · halber Zug" else " · half a turn") else "")
}

/** A target in a list: its name, where it stands, how it is (the foes' count is never hidden when there are few). */
private fun targetLabel(sk: Skirmish, f: Fighter, lang: Lang): String {
    val who = f.display(lang)
    val at = spotName(f.place, lang)
    val life = " ${f.hp}/${f.maxHp}"
    return if (sk.fighters.count { it.side == f.side && it.standing } > 2) "$who · $at$life" else who + life
}

private fun Skirmish.byIdOrNull(id: String?): Fighter? = fighters.firstOrNull { it.id == id }

/** 211: a foe's name, numbered when more of its kind are in the fight ("Wolf 1", 240: the number is the fighter's own); friends by name. */
private fun Skirmish.label(f: Fighter, lang: Lang): String = f.name(lang)

/** 211: a line of the log, wrapping; the newest bright, the older dimmed; "7 Schaden" in gold. */
@Composable
private fun LogLine(text: String, newest: Boolean) {
    val base = if (newest) Veil.text else Veil.dim
    val styled = androidx.compose.ui.text.buildAnnotatedString {
        append(text)
        addStyle(androidx.compose.ui.text.SpanStyle(color = base), 0, text.length)
        for (m in DAMAGE.findAll(text)) addStyle(androidx.compose.ui.text.SpanStyle(color = if (newest) Veil.bright else Veil.gold), m.range.first, m.range.last + 1)
    }
    androidx.compose.material3.Text(styled, style = androidx.compose.ui.text.TextStyle(fontFamily = Serif, fontFeatureSettings = "lnum"),
        fontSize = 15.sp * 0.95f * TypeLook.scale, lineHeight = 15.sp * 1.3f, letterSpacing = 0.2.sp)
}

private val DAMAGE = Regex("""\d+ (Schaden|damage)""")

/** 211: one of the party: name and life in numbers, a bar, the spell points when it has any. */
@Composable
private fun PartyBox(name: String, hp: Int, max: Int, sp: Int?, maxSp: Int, lang: Lang, color: Color, modifier: Modifier) {
    Column(modifier.border(1.dp, Veil.rim).padding(horizontal = 6.dp, vertical = 3.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            // 211.16: the friend's own color, as on the intents aimed at it
            Box(Modifier.size(8.dp).background(color))
            Spacer(Modifier.width(5.dp))
            // 232: the name has the line to itself, so twelve letters fit (the numbers went under it)
            Txt(name, Modifier.weight(1f), size = 13.sp, color = if (hp <= 0) Veil.warn else Veil.text, maxLines = 1)
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Canvas(Modifier.weight(1f).height(4.dp)) {
                drawRect(Color.White.copy(alpha = 0.12f))
                val share = (hp.toFloat() / max).coerceIn(0f, 1f)
                drawRect(if (share > 0.5f) Veil.good else if (share > 0.25f) Veil.gold else Veil.warn, Offset.Zero, androidx.compose.ui.geometry.Size(size.width * share, size.height))
            }
            Spacer(Modifier.width(6.dp))
            Txt("$hp/$max" + (sp?.let { "  ${if (lang == Lang.DE) "ZP" else "SP"} $it/$maxSp" } ?: ""), size = 12.sp, color = if (hp <= 0) Veil.warn else Veil.text, maxLines = 1, pixel = true)
        }
    }
}

private fun spotName(s: Spot, lang: Lang): String {
    val de = lang == Lang.DE
    val row = if (s.row == Line.FRONT) (if (de) "vorn" else "front") else (if (de) "hinten" else "back")
    // 182: just the row; "left/right" (72v) and "upper/lower" (174) both read wrong on the diagonal
    return row
}

/** 242: the soft shadow in this many ovals. */
private const val SOFT_STEPS = 7
/** 242.2: each oval's darkness (seven make about 0.7 at the middle) and the shadow's width as a share of the old oval. */
private const val SOFT_ALPHA = 0.16f
private const val SOFT_WIDTH = 0.5f

@Composable
private fun Shadow(x: Dp, y: Dp, w0: Dp, alpha: Float, flat: Boolean = false) {
    // 242 (Chef 12:05: „wie eine Figur von einem Brettspiel mit einem Standfuß“): under the camera a soft contact shadow,
    // half as wide, dark under the feet and fading out to nothing at its edge, no rim; the ring is the only sign on the ground
    val soft = flat && !MarsLayout.hardShadow
    // 242.2 (Chef 13:44 „Schatten kann ich im Ring nicht erkennen“): wider and darker, still fading to nothing at its edge
    val w = if (soft) w0 * SOFT_WIDTH else w0
    // 211.13: on the camera's ground a shadow is as deep as the ground is seen from above (25°: under half its width)
    val h = if (flat) w * 0.42f else 12.dp
    Canvas(Modifier.offset(x = x - w / 2, y = y - h / 2).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        if (soft) {
            // ovals one inside the other, each a little dark: darkest at the middle, nothing at the edge
            val ww = w.toPx(); val hh = h.toPx()
            for (k in 1..SOFT_STEPS) {
                val f = 1f - (k - 1f) / SOFT_STEPS
                drawOval(Color.Black.copy(alpha = SOFT_ALPHA * alpha), Offset(ww * (1 - f) / 2, hh * (1 - f) / 2), androidx.compose.ui.geometry.Size(ww * f, hh * f))
            }
        } else drawOval(Color.Black.copy(alpha = 0.32f * alpha), Offset.Zero, androidx.compose.ui.geometry.Size(w.toPx(), h.toPx()))
    }
}

@Composable
private fun LifeBar(x: Dp, y: Dp, hp: Int, max: Int) {
    val w = 44.dp
    Canvas(Modifier.offset(x = x - w / 2, y = y).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        val ww = w.toPx(); val h = 4.dp.toPx()
        drawRect(Color.Black.copy(alpha = 0.7f), Offset(-1f, -1f), androidx.compose.ui.geometry.Size(ww + 2f, h + 2f))
        val share = (hp.toFloat() / max).coerceIn(0f, 1f)
        drawRect(if (share > 0.5f) Veil.good else if (share > 0.25f) Veil.gold else Veil.warn, Offset.Zero, androidx.compose.ui.geometry.Size(ww * share, h))
    }
}

/** The announced intent: a small sign and its name, never numbers (combat document, Baustein 1). */
private val heads = java.util.concurrent.ConcurrentHashMap<String, Int>()

/** 211.13: the first drawn row of a foe's standing frame (its frame row, counting its offset), once per kind and camera. */
private fun headRow(id: String, img: de.bornim.core.art.PixelImage): Int = heads.getOrPut("$id/${de.bornim.core.art.BeastArt.pitch}") {
    img.oy + ((0 until img.height).firstOrNull { y -> (0 until img.width).any { x -> (img[x, y] ushr 24) >= 128 } } ?: 0)
}

/** 211.13: an announced intent waiting to be laid out: over [x], ideally at [y]. */
private class Sign(val x: Dp, val y: Dp, val intent: Intent, val color: Color?, val more: String?)

/**
 * 211.13 (Sokrates 23:31, 1): the intents laid out by where the camera puts their foes: each as near over its foe as it
 * can stand; one that would cover another moves up a line, and where the top is reached, down under the lowest.
 * Widths are estimated from the words (14 sp), as [IntentSign] places them (70 dp left of the foe, inside the scene).
 */
private fun layOut(signs: List<Sign>, sceneW: Dp, lang: Lang): List<Pair<Sign, Dp>> {
    val line = 26.dp; val top = 34.dp
    val placed = mutableListOf<Triple<Dp, Dp, Dp>>()
    val out = mutableListOf<Pair<Sign, Dp>>()
    for (s in signs.sortedByDescending { it.y }) {
        val chars = s.intent.name(lang).length + 2
        val w = (chars * 7.6f).dp + (if (s.intent.ring) 18.dp else 0.dp) + 14.dp
        val x0 = (s.x - 70.dp).coerceAtMost(sceneW - w - 4.dp).coerceAtLeast(4.dp); val x1 = x0 + w
        fun clash(y: Dp) = placed.any { (a, b, py) -> a < x1 && x0 < b && abs((y - py).value) < line.value }
        var y = maxOf(s.y, top)
        while (clash(y) && y - line >= top) y -= line
        if (clash(y)) y = (placed.filter { (a, b, _) -> a < x1 && x0 < b }.maxOf { it.third }) + line
        placed += Triple(x0, x1, y); out += s to y
    }
    return out
}

@Composable
private fun IntentSign(x: Dp, y: Dp, sceneW: Dp, intent: Intent, aimColor: Color?, more: String?, lang: Lang, onTip: (String) -> Unit) {
    val sign = when (intent.kind) {
        IntentKind.STRIKE -> if (intent.strong) "!!" else "!"
        IntentKind.CALL -> "»"
        // 242: the circle is a blow of the whole pack, not a gathering
        IntentKind.GATHER -> if (intent.effect == Effect.CIRCLE) "!" else "+"
    }
    // 211.9: never past the right edge of the scene ("Netz werfen → Bertram" over the spider at the back)
    Box(Modifier.offset(y = y).layout { m, c ->
        val p = m.measure(c.copy(minWidth = 0, maxWidth = Constraints.Infinity))
        val w = sceneW.roundToPx()
        layout(w, p.height) { p.place((x - 70.dp).roundToPx().coerceAtMost(w - p.width - 4.dp.roundToPx()).coerceAtLeast(4.dp.roundToPx()), 0) }
    }) {
        // 210: a long press explains it
        // 211.15: with who strikes whom first
        val explain = listOfNotNull(more, MarsTips.intent(intent.id, lang)).joinToString("\n").ifEmpty { null }
        val press = if (explain == null) Modifier else Modifier.pointerInput(intent.id, explain) { detectTapGestures(onLongPress = { onTip(explain) }) }
        // 211.16: a strong blow keeps its red frame, twice as thick; the words in the target's color
        val frame = if (intent.strong) Veil.warn else aimColor ?: Veil.gold
        Row(press.background(Color.Black.copy(alpha = 0.75f)).border(if (intent.strong && aimColor != null) 2.dp else 1.dp, frame).padding(horizontal = 6.dp, vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically) {
            val color = aimColor ?: if (intent.strong) Veil.warn else Veil.bright
            Txt("$sign ", size = 14.sp, color = color, maxLines = 1)
            // 219.1: a blow with a ring carries a small golden ring, drawn like the real one (Homer, 219T)
            if (intent.ring) {
                Canvas(Modifier.size(13.dp)) { drawCircle(Veil.gold, radius = size.minDimension / 2 - 1.dp.toPx(), style = androidx.compose.ui.graphics.drawscope.Stroke(1.5.dp.toPx())) }
                Txt(" ", size = 14.sp, maxLines = 1)
            }
            Txt(intent.name(lang), size = 14.sp, color = color, maxLines = 1)
        }
    }
}

/** A small point over the figure the foe aims at, in that friend's color (211.16). */
@Composable
private fun AimMark(x: Dp, y: Dp, color: Color) {
    Canvas(Modifier.offset(x = x, y = y).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        val s = 6.dp.toPx()
        val p = Path().apply { moveTo(-s, -s); lineTo(s, -s); lineTo(0f, s * 0.6f); close() }
        drawPath(p, color)
        drawPath(p, Color.Black.copy(alpha = 0.8f), style = Stroke(1.dp.toPx()))
    }
}

/** The golden ring: from wide it closes on the figure; at [p] = 1 it lies on the thin mark, the moment to tap. */
@Composable
private fun RingAround(x: Dp, y: Dp, r: Dp, p: Float) {
    Canvas(Modifier.offset(x = x, y = y).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        val rr = r.toPx()
        drawCircle(Veil.gold.copy(alpha = 0.55f), radius = rr, center = Offset.Zero, style = Stroke(1.5.dp.toPx()))
        val k = (1f - p).coerceAtLeast(-0.25f)
        val now = rr * (1f + 1.6f * k)
        if (now > 0f) drawCircle(Veil.bright.copy(alpha = (1f - abs(k) * 0.4f).coerceIn(0.3f, 1f)), radius = now, center = Offset.Zero, style = Stroke(4.dp.toPx()))
    }
}

/** 242.3: how much nearer the heroes a foe alone in the front row stands when one stands behind it, in m. */
private const val ALONE_FOE_PULL = 0.6

/** 242: a place's ring, in m. */
private const val RING_M = 0.55
/** 242.1: room round an animal's paws inside its ring, in m. */
private const val PAW_ROOM_M = 0.3

/** 242: a ring of [r] m around (a, b) on the camera's ground, drawn before the figure so its feet stand on it. */
@Composable
private fun CamRing(cam: FightCamera, a: Double, b: Double, color: Color, thick: Dp, r: Double = RING_M) {
    Canvas(Modifier.fillMaxSize()) {
        val sx = size.width / cam.w; val sy = size.height / cam.h
        val (x0, d0) = cam.ground(a, b)
        val path = Path()
        for (k in 0..48) {
            val t = k * Math.PI / 24
            val (px, py) = cam.screen(x0 + r * kotlin.math.cos(t), d0 + r * kotlin.math.sin(t))
            if (k == 0) path.moveTo(px.toFloat() * sx, py.toFloat() * sy) else path.lineTo(px.toFloat() * sx, py.toFloat() * sy)
        }
        drawPath(path, Color.Black.copy(alpha = 0.5f), style = Stroke(thick.toPx() + 2.dp.toPx()))
        drawPath(path, color, style = Stroke(thick.toPx()))
    }
}

/** 242 (preview): the aim lying flat on the camera's ground in front of (a, b), pointing at the feet. */
@Composable
private fun CamAim(cam: FightCamera, a: Double, b: Double, color: Color) {
    Canvas(Modifier.fillMaxSize()) {
        val sx = size.width / cam.w; val sy = size.height / cam.h
        val (x0, d0) = cam.ground(a, b)
        fun pt(x: Double, d: Double) = cam.screen(x0 + x, d0 + d).let { (px, py) -> Offset(px.toFloat() * sx, py.toFloat() * sy) }
        val p = Path().apply { pt(0.0, -0.22).let { moveTo(it.x, it.y) }; pt(-0.2, -0.5).let { lineTo(it.x, it.y) }; pt(0.2, -0.5).let { lineTo(it.x, it.y) }; close() }
        drawPath(p, color)
        drawPath(p, Color.Black.copy(alpha = 0.8f), style = Stroke(1.dp.toPx()))
    }
}

/** A ring on the ground under a figure: gold for the one acting, pale for one that can be picked (72.10a.4, .6). */
@Composable
private fun GroundRing(x: Dp, y: Dp, w: Dp, color: Color, thick: Dp, flat: Boolean = false) {
    val h = if (flat) w * 0.42f else 18.dp
    Canvas(Modifier.offset(x = x - w / 2, y = y - h / 2).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        drawOval(color, Offset.Zero, androidx.compose.ui.geometry.Size(w.toPx(), h.toPx()), style = Stroke(thick.toPx()))
    }
}

/**
 * 211: where names and life bars stand; the Chef chose C (211.8): names over the head, bars only over foes, friends'
 * in their boxes below. The preview shows the other variants (MARS211BESCHRIFTUNG).
 */
/** 229.1: a small grid of three by three, half seen; brighter while the grid is on. */
@Composable
private fun GridSwitch(on: Boolean, modifier: Modifier, onTap: () -> Unit) {
    // 229.2: the sign stays 40 dp, the finger finds it on 48 dp (Android's least)
    Box(modifier.size(48.dp).clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { onTap() }, contentAlignment = Alignment.Center) {
        Canvas(Modifier.size(40.dp).background(Color.Black.copy(alpha = 0.35f)).border(1.dp, Veil.gold.copy(alpha = if (on) 0.8f else 0.4f)).padding(9.dp)) {
            val c = Veil.gold.copy(alpha = if (on) 0.9f else 0.5f)
            val w = 1.5.dp.toPx()
            for (i in 0..3) {
                val k = i / 3f
                drawLine(c, Offset(size.width * k, 0f), Offset(size.width * k, size.height), w)
                drawLine(c, Offset(0f, size.height * k), Offset(size.width, size.height * k), w)
            }
        }
    }
}

/** 260 (Chef 18:04): the sign for the rolls, a die beside the grid sign, brighter while on. */
@Composable
private fun RollSwitch(on: Boolean, modifier: Modifier, onTap: () -> Unit) {
    Box(modifier.size(48.dp).clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { onTap() }, contentAlignment = Alignment.Center) {
        Canvas(Modifier.size(40.dp).background(Color.Black.copy(alpha = 0.35f)).border(1.dp, Veil.gold.copy(alpha = if (on) 0.8f else 0.4f)).padding(9.dp)) {
            val c = Veil.gold.copy(alpha = if (on) 0.9f else 0.5f)
            drawRect(c, style = androidx.compose.ui.graphics.drawscope.Stroke(1.5.dp.toPx()))
            val r = 1.8.dp.toPx()
            for ((a, b) in listOf(0.25f to 0.25f, 0.75f to 0.25f, 0.5f to 0.5f, 0.25f to 0.75f, 0.75f to 0.75f)) drawCircle(c, r, Offset(size.width * a, size.height * b))
        }
    }
}

/** 249: the blood of one hit: [by] struck [on]; [seed] tells one hit from the next. */
private data class Bleed(val by: String, val on: String, val crit: Boolean, val hurt: Float, val seed: Int, val gore: Gore)

/** 211.10: the two of a row side by side (now) or set apart across the line of the fight; guides only for the preview. */
object MarsLayout {
    /** 249: steps, zoom with jolt and blood (passed, Chef 20.10., 22:43); off only in the preview, for comparison */
    var look249 = true
    /** 249: slow motion of glides and blows, preview only (the preview draws too slowly to catch 350 ms) */
    var slow = 1L
    /** 249: told of each blow that jolts the scene, preview only (to find it in a film). */
    var onHit: ((String) -> Unit)? = null
    var offset = false
    /** 211.10 (Chef 21:39): the straight line of the fight, foes above the party (preview only until chosen). */
    var straight = false
    var guides = false
    /** 211.10, Chefsache 229: the places of both sides as faint outlines on the ground. */
    var grid = false
    /** 242 (preview only until chosen): each hero's ring in its color instead of the triangles over the head. */
    var heroRings = false
    /** 242 (Chef 12:05, preview only): the old hard oval under the figures, for comparison with the soft contact shadow. */
    var hardShadow = false
    /** 229.2 (Chef 22:09 „229 passt“): the grid sign in the game, for every player. */
    var gridSwitch = true
    /** 211.13: the Kampfort and its figures from one camera, for the pattern still (preview only until built). */
    var still: MarsStill? = null
    /**
     * 211.13 (Muster „passt, mit Mitte 0,68“, Sokrates 23:31): the one camera, for MARS and the classic fight; false shows
     * the old scenes, for comparison (with [FightCamera.see] false, the figures too).
     */
    var camera = true
}

/** 211.13: draws the Kampfort with its figures [w]×[h] pixels; where each figure's feet stand (shares) and how tall it is (pixels). */
interface MarsStill {
    fun draw(w: Int, h: Int, sk: Skirmish, places: Map<String, Spot>): Shot
    class Shot(val img: de.bornim.core.art.PixelImage, val feet: Map<String, Pair<Float, Float>>, val tall: Map<String, Float>)
}

/** 211.10: the line of the fight and the line of each row, faint, for the comparison pictures. */
@Composable
private fun CamGrid(cam: FightCamera) {
    // 229 under the camera (211.13): the places as circles of 0.55 m on the ground, as the camera sees them
    Canvas(Modifier.fillMaxSize()) {
        val sx = size.width / cam.w; val sy = size.height / cam.h
        for (foe in listOf(false, true)) for (back in listOf(false, true)) for (slot in listOf(0, 1)) {
            val (a, b) = FightCamera.stand(foe, back, slot, false)
            val path = androidx.compose.ui.graphics.Path()
            val (x0, d0) = cam.ground(a, b)
            for (k in 0..32) {
                val t = k * Math.PI / 16
                val (px, py) = cam.screen(x0 + 0.55 * kotlin.math.cos(t), d0 + 0.55 * kotlin.math.sin(t))
                if (k == 0) path.moveTo(px.toFloat() * sx, py.toFloat() * sy) else path.lineTo(px.toFloat() * sx, py.toFloat() * sy)
            }
            // 229.3 (Chef „Rastereinblendung schwer erkennbar“): a dark ground under a brighter gold line, seen on grass and stone
            drawPath(path, Color.Black.copy(alpha = 0.18f))
            drawPath(path, Color.Black.copy(alpha = 0.55f), style = Stroke(4.dp.toPx()))
            drawPath(path, Veil.gold.copy(alpha = 0.9f), style = Stroke(2.dp.toPx()))
        }
    }
}

@Composable
private fun Guides(aspect: Float, fit: Float, grid: Boolean) {
    Canvas(Modifier.fillMaxSize()) {
        val c = Color.White.copy(alpha = 0.35f)
        fun pt(side: Side, s: Spot) = placeAt(side, s, false, aspect).let { (x, y) -> Offset(size.width * x, size.height * (if (side == Side.FOES) y - (1f - fit) * 0.3f else y)) }
        fun mid(side: Side, row: Line) = placeAt(side, Spot(row, 0), true, aspect).let { (x, y) -> Offset(size.width * x, size.height * (if (side == Side.FOES) y - (1f - fit) * 0.3f else y)) }
        if (MarsLayout.guides) {
            drawLine(c, mid(Side.PARTY, Line.BACK), mid(Side.FOES, Line.BACK), 1.5.dp.toPx())
            for (side in Side.entries) for (row in listOf(Line.FRONT, Line.BACK)) drawLine(c, pt(side, Spot(row, 0)), pt(side, Spot(row, 1)), 1.dp.toPx())
        }
        // the places, and where one stands alone, the middle of its row
        if (grid) for (side in Side.entries) for (s in Spot.ALL) {
            val o = pt(side, s)
            val w = 64.dp.toPx(); val h = 16.dp.toPx()
            drawOval(Veil.gold.copy(alpha = 0.45f), Offset(o.x - w / 2, o.y - h / 2), androidx.compose.ui.geometry.Size(w, h), style = Stroke(1.5.dp.toPx()))
        }
    }
}

object MarsLabels {
    var below = false
    var barsOnlyFoes = true
}

/** A figure's name on a dark ground; the one acting in gold. */
@Composable
private fun NameTag(x: Dp, y: Dp, text: String, acting: Boolean, alpha: Float = 1f) {
    if (alpha <= 0f) return
    Box(Modifier.offset(x = x - 70.dp, y = y).width(140.dp).alpha(alpha), contentAlignment = Alignment.Center) {
        Box(Modifier.background(Color.Black.copy(alpha = 0.7f)).padding(horizontal = 5.dp, vertical = 1.dp)) {
            Txt(text, size = 12.sp, color = if (acting) Veil.bright else Veil.text, maxLines = 1)
        }
    }
}

/** The roll behind a blow or a spell, with its numbers: "12 + 5 = 17 gegen RK 16" (72.10a.10). */
@Composable
private fun RollTag(x: Dp, y: Dp, sceneW: Dp, r: RollInfo, lang: Lang, alpha: Float = 1f) {
    val de = lang == Lang.DE
    val sum = r.d20 + r.bonus
    val bonus = if (r.bonus < 0) "− ${-r.bonus}" else "+ ${r.bonus}"
    val mode = if (r.mode > 0) (if (de) " (Vorteil)" else " (advantage)") else if (r.mode < 0) (if (de) " (Nachteil)" else " (disadvantage)") else ""
    val text = if (r.kind == RollKind.ATTACK) {
        "${r.d20}$mode $bonus = $sum ${if (de) "gegen RK" else "vs AC"} ${r.versus} · " +
            if (r.d20 == 20) (if (de) "kritisch" else "critical") else if (r.success) (if (de) "Treffer" else "hit") else (if (de) "daneben" else "miss")
    } else {
        "${if (de) "RW" else "Save"} ${r.d20} $bonus = $sum ${if (de) "gegen SG" else "vs DC"} ${r.versus} · " + if (r.success) (if (de) "geschafft" else "made") else (if (de) "misslungen" else "failed")
    }
    // 260: wide enough for the outcome at the end ("· daneben" was cut off at 240 dp), kept inside the scene
    val w = minOf(340.dp, sceneW - 8.dp)
    Box(Modifier.offset(x = (x - w / 2).coerceIn(4.dp, sceneW - w - 4.dp), y = y).width(w).alpha(alpha), contentAlignment = Alignment.Center) {
        Box(Modifier.background(Color.Black.copy(alpha = 0.8f)).border(1.dp, if (r.success == (r.kind == RollKind.ATTACK)) Veil.bright else Veil.dim).padding(horizontal = 6.dp, vertical = 2.dp)) {
            Txt(text, size = 13.sp, color = Veil.text, maxLines = 2, pixel = true)
        }
    }
}

/**
 * The line of turns: tags in the order of acting, the one acting first with ▶ and framed in gold (72.10a.4); 211: 13 sp,
 * whole names, foes of a kind numbered, and after a stroke the start of the next round.
 */
@OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@Composable
private fun TurnBar(sk: Skirmish, queue: List<String>, hp: Map<String, Int>, lang: Lang, modifier: Modifier) {
    val alive = queue.filter { id -> sk.byIdOrNull(id)?.let { (hp[id] ?: it.hp) > 0 } == true }
    androidx.compose.foundation.layout.FlowRow(modifier, horizontalArrangement = Arrangement.spacedBy(3.dp), verticalArrangement = Arrangement.spacedBy(3.dp)) {
        for ((i, id) in (alive + alive.take(1)).withIndex()) {
            val f = sk.byIdOrNull(id) ?: continue
            val next = i == alive.size
            if (next) Box(Modifier.padding(horizontal = 2.dp)) { Txt("|", size = 13.sp, color = Veil.dim) }
            val frame = if (i == 0) Veil.bright else if (f.side == Side.FOES) Veil.warn else Veil.rim
            val color = if (next) Veil.dim else if (i == 0) Veil.bright else if (f.side == Side.FOES) Veil.warn else Veil.text
            Box(Modifier.background(Color.Black.copy(alpha = 0.78f)).border(if (i == 0) 2.dp else 1.dp, if (next) Veil.dim.copy(alpha = 0.5f) else frame).padding(horizontal = 5.dp, vertical = 2.dp)) {
                Txt((if (i == 0) "▶ " else "") + sk.label(f, lang) + if (next) " …" else "", size = 13.sp, color = color, maxLines = 1)
            }
        }
    }
}

/** 249 (Chef 18:12): the frame of a spell cast [since] ms ago, with the gesture of the classic fight, or null when it is over. */
private fun castFrame(hero: de.bornim.core.Hero, since: Long?): de.bornim.core.art.PixelImage? {
    if (since == null || since < 0) return null
    val v = HeroBattle.castVariant(hero)
    val n = HeroBattle.frameCount(hero, HeroFigure.Act.CAST, HeroFigure.Strike.CAST, v)
    val i = (since / (CAST_FRAME_MS * MarsLayout.slow)).toInt()
    if (i >= n) return null
    return HeroBattle.ready(hero, HeroFigure.Act.CAST, HeroFigure.Strike.CAST, v, i) ?: HeroBattle.frame(hero, HeroFigure.Act.CAST, HeroFigure.Strike.CAST, v, i)
}

/**
 * 249 (Chef 14:41 „MARS sieht und fühlt sich an wie der klassische Kampf“): the frame of a hero's or mercenary's blow
 * [since] ms into the lunge (as in the classic fight, with the weapon in hand), or null when it is over. The last frames
 * of the wind-up lead to the blow at the lunge's furthest, the rest of the blow follows; which blow goes by when it began.
 */
private fun swingFrame(hero: de.bornim.core.Hero, since: Long?, began: Long): de.bornim.core.art.PixelImage? {
    if (since == null || since < 0) return null
    val strikes = HeroBattle.strikes(hero)
    val strike = strikes[(began / 7 % strikes.size).toInt()]
    val n = HeroBattle.frameCount(hero, HeroFigure.Act.ATTACK, strike)
    val inMs = SWING_IN_MS * MarsLayout.slow; val outMs = SWING_OUT_FRAME_MS * MarsLayout.slow
    val hit = HeroBattle.strikeFrame(strike).coerceAtMost(n - 1)
    val from = (hit - 4).coerceAtLeast(0)
    val i = if (since < inMs) from + ((hit - from) * since / inMs).toInt()
        else hit + ((since - inMs) / outMs).toInt()
    if (i >= n) return null
    return HeroBattle.ready(hero, HeroFigure.Act.ATTACK, strike, 0, i) ?: HeroBattle.frame(hero, HeroFigure.Act.ATTACK, strike, 0, i)
}
