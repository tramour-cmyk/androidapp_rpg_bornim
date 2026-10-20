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
import androidx.compose.ui.Alignment
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
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
import de.bornim.core.art.Act
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CaveScene
import de.bornim.core.art.FightCamera
import de.bornim.core.art.Kampfort
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MonsterArt
import de.bornim.core.audio.Sound
import de.bornim.game.GameViewModel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
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
/** 205: how long a foe takes to topple over, and then to fade away. */
private const val FALL_MS = 900L
private const val FADE_MS = 600L
/** The orders under the scene: the line of who acts and two rows of buttons (211: 52 and 48 dp, 6 dp apart). */
private val ORDERS_H = 136.dp
/** 211: the log, five lines of 15 sp. */
private val LOG_H = 108.dp

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
private const val ROLL_MS = 1500L

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
    var ring by remember(sk) { mutableStateOf<Beat.Ring?>(null) }
    var ringStart by remember(sk) { mutableLongStateOf(0L) }
    var ringResult by remember(sk) { mutableStateOf<Reaction?>(null) }
    var verdict by remember(sk) { mutableStateOf<String?>(null) }
    // 219.3: the class's answer to a perfect ring, shown under the verdict
    var answer by remember(sk) { mutableStateOf<String?>(null) }
    // 219: the first ring of a save game says when to tap
    var ringHelp by remember(sk) { mutableStateOf(false) }
    var lunge by remember(sk) { mutableStateOf<Pair<String, String>?>(null) }
    var lungeAt by remember(sk) { mutableLongStateOf(0L) }
    val hurtAt = remember(sk) { mutableStateMapOf<String, Long>() }
    /** 205: when each figure fell; friends lie there, foes topple over and are gone. */
    val downAt = remember(sk) { mutableStateMapOf<String, Long>() }
    var pick by remember(sk) { mutableStateOf<Pick>(Pick.Main) }
    /** 204: the explanation of a button pressed long; it goes after a while, or with a tap on it. */
    var tip by remember(sk) { mutableStateOf<String?>(null) }
    LaunchedEffect(tip) { if (tip != null) { delay(TIP_MS); tip = null } }
    var ready by remember(sk) { mutableStateOf(false) }

    // the figures standing ready before the fight starts (about a second); the rest of Grak's and the goblins' frames
    // follow in the background (about six seconds), shown as soon as each is drawn
    LaunchedEffect(sk) {
        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
            for (f in sk.fighters) f.hero?.let { HeroBattle.prepareAct(it, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0) }
            MonsterArt.shownFrame(Skirmish.GRAK, MonsterLook(0), Act.IDLE, 0, 0)
        }
        launch(kotlinx.coroutines.Dispatchers.Default) {
            MonsterArt.prepare(Skirmish.GRAK, MonsterLook(0)) { !isActive }
            MonsterArt.prepare(Skirmish.CALLED, MonsterLook(0)) { !isActive }
        }
        ready = true
        // the one sentence that shows what the rows do, in the first fight only (72.10a.6)
        if (!vm.rowHintSeen) {
            lines += t("Nahkampf erreicht nur die vordere Reihe.", "Melee reaches only the front row.")
            vm.markRowHintSeen()
        }
        run.run { sk.start(run.react) }
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
                if (actor != null && target != null && actor != target && sk.byIdOrNull(actor)?.side != sk.byIdOrNull(target)?.side) { lunge = actor to target; lungeAt = now }
                if (e.roll != null && target != null) rollShown.value = Triple(target, e.roll!!, now)
                for ((id, hp) in e.hp) if (hp <= 0) { if (id !in downAt) downAt[id] = now } else downAt.remove(id)
                if (e.damage > 0 && target != null) {
                    hurtAt[target] = now
                    vm.play(if (sk.byIdOrNull(e.actor)?.side == Side.FOES) Sound.HIT_SMASH else Sound.HIT_SLASH)
                } else if (e.actor != null && e.target != null && e.actor != e.target) vm.play(Sound.MISS, 0.5f)
                delay(SAY_MS)
            }
            is Beat.Ring -> {
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
            }
        }
    }
    LaunchedEffect(verdict) { if (verdict != null) { delay(if (ringResult == Reaction.PERFECT) 2200 else 1200); verdict = null; answer = null } }

    fun order(o: Order) {
        busy = true
        pick = Pick.Main
        run.run { sk.act(o, run.react) }
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
            fun alone(side: Side, s: Spot) = sk.fighters.count { it.side == side && shown.places[it.id]?.row == s.row && (shown.hp[it.id] ?: it.hp) > 0 } <= 1
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
            fun ground(side: Side, s: Spot) = FightCamera.stand(side == Side.FOES, s.row == de.bornim.core.Row.BACK, s.slot, alone(side, s))
            fun at(side: Side, s: Spot): Pair<Float, Float> = if (cam != null) ground(side, s).let { (a, b) -> cam.feet(a, b) }.let { (x, y) -> (x / wPx).toFloat() to (y / hPx).toFloat() }
                else placeAt(side, s, alone(side, s), aspect).let { (x, y) -> if (side == Side.FOES) x to y - (1f - fit) * 0.3f else x to y }
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
            val figures = sk.fighters.filter { shown.places[it.id] != null }.sortedBy { at(it.side, shown.places[it.id]!!).second }
            val signs = mutableListOf<Sign>()
            for (f in figures) {
                val spot = shown.places[f.id]!!
                val (px, py) = still?.feet?.get(f.id) ?: at(f.side, spot)
                val hp = shown.hp[f.id] ?: f.hp
                val down = hp <= 0
                // a short step towards the one it strikes, and back
                val (dx, dy) = lunge?.takeIf { it.first == f.id && now - lungeAt < LUNGE_MS }?.let { (_, to) ->
                    val tf = sk.byIdOrNull(to) ?: return@let 0f to 0f
                    val tp = shown.places[to] ?: return@let 0f to 0f
                    val (tx, ty) = at(tf.side, tp)
                    val k = sin((now - lungeAt).toFloat() / LUNGE_MS * Math.PI.toFloat()) * 0.22f
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
                var tall: Dp
                if (still != null) tall = with(density) { (still.tall[f.id] ?: 0f).toDp() }
                else if (hero != null) {
                    val s = 0.62f * depth(spot) * fit
                    // 211.13: as large as its distance from the camera makes it
                    val px1 = cam?.let { c -> ground(f.side, spot).let { (a, b) -> with(density) { (c.perCm(a, b) / HeroBattle.PX).toFloat().toDp() } } } ?: (artDp * s)
                    val idle = ((clock / 110) % 1000).toInt()
                    val img = if (down) {
                        val n = HeroBattle.frameCount(hero, HeroFigure.Act.DIE).coerceAtLeast(1)
                        val i = (fellFor / 95L).toInt().coerceAtMost(n - 1)
                        HeroBattle.ready(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, 0, i) ?: HeroBattle.frame(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, 0, i)
                    } else HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, idle)
                        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                        ?: HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                    // 211.13: under the camera the name stands just over the head (the frame leaves room for the raised weapon)
                    tall = px1 * (if (cam != null) 140f else 150f)
                    Shadow(x, y, px1 * 90f, alpha, flat = cam != null)
                    Box(Modifier.offset(x = x - px1 * HeroBattle.ANCHOR_X.toFloat(), y = y - px1 * HeroBattle.GROUND.toFloat())) {
                        PixelSprite(img, px1, alpha = alpha, shade = shade, hurt = hurt)
                    }
                } else {
                    val m = f.monster!!
                    val look = MonsterLook(0)
                    val s = (if (f.boss) 0.8f else 0.66f) * depth(spot) * fit
                    // 211.13: foes 1.5 times true to life (animals on top of their own 0.88), at their distance
                    val px1 = cam?.let { c -> ground(f.side, spot).let { (a, b) -> with(density) { (c.perCm(a, b) * FightCamera.FOE_SIZE * (if (f.boss) 1.0 else 0.88) / 0.66).toFloat().toDp() } } } ?: (artDp * s)
                    val r = ring
                    // Grak winds up while the ring closes on his target
                    val winding = r != null && shown.actor == f.id
                    val dies = if (down) MonsterArt.frameCount(m.id, look, Act.DIE, 0) else 0
                    val img = if (dies > 0) {
                        MonsterArt.shownFrame(m.id, look, Act.DIE, 0, (fellFor * dies / FALL_MS).toInt().coerceAtMost(dies - 1))
                    } else if (winding && MonsterArt.isNewStyle(m.id)) {
                        val strike = MonsterArt.strikeFrame(m.id, look, 0)
                        val p = ((now - ringStart).toFloat() / RING_MS).coerceIn(0f, 1f)
                        MonsterArt.shownFrame(m.id, look, Act.ATTACK, 0, (p * (strike - 1).coerceAtLeast(0)).toInt())
                    } else {
                        val n = MonsterArt.frameCount(m.id, look, Act.IDLE, 0).coerceAtLeast(1)
                        MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, ((clock / 86) % n).toInt())
                    }
                    val frameW = if (MonsterArt.isDoll(m.id)) de.bornim.core.art.FoeArt.W else img.width
                    val spr = px1 / MonsterArt.fine(m.id).toFloat()
                    // 211: names and bars at the head, not at the top of the frame (Grak's frame leaves room for the raised club)
                    tall = px1 * (MonsterArt.groundLine(m.id).toFloat() * 0.85f).let { t ->
                        // 211.13: under the camera the head is where the standing frame's first drawn row is
                        if (cam != null) MonsterArt.groundLine(m.id).toFloat() - headRow(m.id, MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, 0)) / MonsterArt.fine(m.id).toFloat() + 2f
                        else if (MonsterArt.isDoll(m.id)) minOf(t, MonsterArt.groundLine(m.id).toFloat() - MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, 0).oy / MonsterArt.fine(m.id).toFloat() + 2f) else t
                    }
                    Shadow(x, y, px1 * 70f, alpha, flat = cam != null)
                    Box(Modifier.offset(x = x - px1 * MonsterArt.anchorX(m.id, frameW).toFloat(), y = y - px1 * MonsterArt.groundLine(m.id).toFloat())) {
                        Box(Modifier.offset(x = spr * img.ox, y = spr * img.oy)) {
                            PixelSprite(img, spr, alpha = alpha, shade = shade, overflow = true, hurt = hurt)
                        }
                    }
                }
                // the figure acting: a golden ring on the ground (72.10a.4); a target that can be picked: a pale one
                // 211.13: under the camera a ring of the place's size, lying on the ground
                val ringW = cam?.let { c -> ground(f.side, spot).let { (a, b) -> with(density) { (c.perCm(a, b) * 110).toFloat().toDp() } } } ?: 74.dp
                if (!down && f.id == actingId) GroundRing(x, y, ringW, Veil.bright, 2.5.dp, flat = cam != null)
                else if (!down && f.id in aimed) GroundRing(x, y, ringW, Veil.text, 2.dp, flat = cam != null)
                // life bar over the head; 211: one rule for all names, over the head or under the feet (MarsLabels)
                val above = !MarsLabels.below
                val bar = !down && !(MarsLabels.barsOnlyFoes && f.side == Side.PARTY)
                if (bar) LifeBar(x, y - tall - 8.dp, hp, f.maxHp)
                if (!down) NameTag(x, if (above) y - tall - (if (bar) 28.dp else 24.dp) else y + 6.dp, sk.label(f, lang), f.id == actingId)
                // the roll with its numbers, briefly at its target (72.10a.10)
                rollShown.value?.takeIf { vm.showRolls && it.first == f.id && now - it.third < ROLL_MS }?.let { (_, info, _) ->
                    RollTag(x, y - tall - (if (above) 78.dp else 62.dp), info, lang)
                }
                // the announced intent over the foe, the aim over its target
                // 211: with its target ("!! Schwerer Hieb → Mira")
                // 211.9: two side by side at one height; the right one's sign stands a line higher, so the two never overlap
                val lift = if (spot.slot == 1 && !MarsLayout.offset && !alone(f.side, spot)) 24.dp else 0.dp
                shown.intents[f.id]?.let { (intent, at) ->
                    val aim = at.firstOrNull()?.let { sk.byIdOrNull(it) }?.let { sk.label(it, lang) }
                    // 211.13: under the camera laid out after all figures, so no two overlap (Sokrates 23:31, 1)
                    if (cam != null) signs += Sign(x, y - tall - (if (above) 52.dp else 36.dp), intent, aim)
                    else IntentSign(x, maxOf(y - tall - (if (above) 52.dp else 36.dp) - lift, 34.dp), sceneW, intent, aim, lang) { tip = it }
                }
                if (!down && shown.intents.values.any { f.id in it.second }) AimMark(x, y - tall - (if (above) 36.dp else 22.dp))
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
            for ((sign, y) in layOut(signs, sceneW, lang)) IntentSign(sign.x, y, sceneW, sign.intent, sign.target, lang) { tip = it }
            TurnBar(sk, shown.queue, shown.hp, lang, Modifier.align(Alignment.TopStart).padding(6.dp))
            verdict?.let { v ->
                Box(Modifier.align(Alignment.TopCenter).padding(top = 44.dp).background(Color.Black.copy(alpha = 0.7f)).border(1.dp, Veil.gold).padding(horizontal = 14.dp, vertical = 6.dp)) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Txt(v, size = 22.sp, color = if (ringResult == Reaction.PERFECT) Veil.bright else if (ringResult == Reaction.GOOD) Veil.text else Veil.warn)
                        answer?.let { Txt(it, size = 15.sp, color = Veil.gold) }
                    }
                }
            }
            // 229.1: the grid sign, lower right, half seen; away while the ring wants a tap anywhere or a tip is shown
            if (MarsLayout.gridSwitch && ring == null && tip == null && verdict == null) GridSwitch(vm.showGrid, Modifier.align(Alignment.BottomEnd).padding(4.dp)) { vm.toggleGrid() }
            if (ring != null) Txt(t("Tippen, wenn der große Ring auf dem kleinen liegt", "Tap when the large ring lies on the small one"), Modifier.align(Alignment.BottomCenter).padding(bottom = 6.dp), size = 14.sp, color = Veil.dim)
            // 204: the explanation of a button pressed long, over the lower edge of the scene, so the orders keep their place
            tip?.takeIf { ring == null }?.let { text ->
                Box(Modifier.align(Alignment.BottomCenter).fillMaxWidth().padding(8.dp).background(Color.Black.copy(alpha = 0.85f)).border(1.dp, Veil.gold).clickable { tip = null }.padding(horizontal = 10.dp, vertical = 6.dp)) {
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
                for (p in party) PartyBox(p.name(lang), shown.hp[p.id] ?: p.hp, p.maxHp, if (p.hero!!.maxSp > 0) shown.sp[p.id] ?: p.sp else null, p.hero!!.maxSp, lang, Modifier.weight(1f))
            }
            val merc = party.firstOrNull { it.id == "merc" }
            // the orders keep one height whatever shows, so the scene above never jumps
            Column(Modifier.fillMaxWidth().height(if (compact) ORDERS_H - 8.dp else ORDERS_H), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            when {
                !busy && sk.outcome != Outcome.ONGOING -> {
                    val won = sk.outcome == Outcome.WON
                    Txt(if (won) t("Grak ist besiegt.", "Grak is beaten.") else t("Der Kampf ist verloren.", "The fight is lost."), size = 18.sp, color = if (won) Veil.bright else Veil.warn)
                    if (sk.knockouts > 0) Txt(t("Söldner bewusstlos: ", "Mercenaries knocked out: ") + sk.knockouts, size = 14.sp)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        PixelButton(t("Nochmal", "Again"), Modifier.weight(1f), size = 15.sp) { vm.startProbe(vm.probeClass) }
                        PixelButton(t("Zurück", "Back"), Modifier.weight(1f), size = 15.sp) { vm.probe = null }
                    }
                }
                busy -> Txt(t("…", "…"), size = 14.sp, color = Veil.dim)
                else -> {
                    val f = sk.current
                    val spells = f.hero!!.maxSp > 0
                    Txt(t("Am Zug: ", "To act: ") + f.display(lang) + (if (spells) "  ${t("ZP", "SP")} ${f.sp}/${f.hero!!.maxSp}" else "") +
                        // 72.10a.8: after a swap, half the turn is left
                        (if (!sk.canSwap(f)) t("  · halber Zug", "  · half a turn") else "") +
                        // 72.10a.11: the weapon in hand
                        (f.weapon?.let { "  · " + it.name(lang) } ?: ""), size = 15.sp, color = Veil.bright)
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
            if (sk.outcome == Outcome.ONGOING && pick == Pick.Main) Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
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
                var heroAuto by remember(sk) { mutableStateOf(false) }
                PixelButton(t("Automatik", "Autopilot") + if (heroAuto && sk.autopilot) " ✓" else "", Modifier.weight(1f), enabled = !busy, selected = heroAuto && sk.autopilot, size = 14.sp, height = lowH, onLongClick = { tip = MarsTips.autopilot(lang) }) {
                    val why = sk.autopilotBlocked()
                    if (sk.autopilot) { sk.setAutopilot(false); heroAuto = false }
                    // 211: why not, at the lower edge of the scene like a long press (a toast covered the line of turns)
                    else if (why != null) tip = why(lang)
                    else { heroAuto = sk.setAutopilot(true); if (heroAuto) goOn() }
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

/** A target in a list: its name, where it stands, how it is (the foes' count is never hidden when there are few). */
private fun targetLabel(sk: Skirmish, f: Fighter, lang: Lang): String {
    val who = f.display(lang)
    val at = spotName(f.place, lang)
    val life = " ${f.hp}/${f.maxHp}"
    return if (sk.fighters.count { it.side == f.side && it.standing } > 2) "$who · $at$life" else who + life
}

private fun Skirmish.byIdOrNull(id: String?): Fighter? = fighters.firstOrNull { it.id == id }

/** 211: a foe's name, numbered when more of its kind are in the fight ("Wolf 1"); friends by name. */
private fun Skirmish.label(f: Fighter, lang: Lang): String {
    val m = f.monster ?: return f.name(lang)
    val kin = fighters.filter { it.monster?.id == m.id }
    return if (kin.size > 1) "${f.name(lang)} ${kin.indexOf(f) + 1}" else f.name(lang)
}

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
private fun PartyBox(name: String, hp: Int, max: Int, sp: Int?, maxSp: Int, lang: Lang, modifier: Modifier) {
    Column(modifier.border(1.dp, Veil.rim).padding(horizontal = 6.dp, vertical = 3.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Txt(name, Modifier.weight(1f), size = 13.sp, color = if (hp <= 0) Veil.warn else Veil.text, maxLines = 1)
            Txt("$hp/$max" + (sp?.let { "  ${if (lang == Lang.DE) "ZP" else "SP"} $it/$maxSp" } ?: ""), size = 13.sp, color = if (hp <= 0) Veil.warn else Veil.text, maxLines = 1, pixel = true)
        }
        Canvas(Modifier.fillMaxWidth().height(4.dp)) {
            drawRect(Color.White.copy(alpha = 0.12f))
            val share = (hp.toFloat() / max).coerceIn(0f, 1f)
            drawRect(if (share > 0.5f) Veil.good else if (share > 0.25f) Veil.gold else Veil.warn, Offset.Zero, androidx.compose.ui.geometry.Size(size.width * share, size.height))
        }
    }
}

private fun spotName(s: Spot, lang: Lang): String {
    val de = lang == Lang.DE
    val row = if (s.row == Line.FRONT) (if (de) "vorn" else "front") else (if (de) "hinten" else "back")
    // 182: just the row; "left/right" (72v) and "upper/lower" (174) both read wrong on the diagonal
    return row
}

@Composable
private fun Shadow(x: Dp, y: Dp, w: Dp, alpha: Float, flat: Boolean = false) {
    // 211.13: on the camera's ground a shadow is as deep as the ground is seen from above (25°: under half its width)
    val h = if (flat) w * 0.42f else 12.dp
    Canvas(Modifier.offset(x = x - w / 2, y = y - h / 2).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        drawOval(Color.Black.copy(alpha = 0.32f * alpha), Offset.Zero, androidx.compose.ui.geometry.Size(w.toPx(), h.toPx()))
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
private class Sign(val x: Dp, val y: Dp, val intent: Intent, val target: String?)

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
        val chars = s.intent.name(lang).length + (s.target?.let { it.length + 3 } ?: 0) + 2
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
private fun IntentSign(x: Dp, y: Dp, sceneW: Dp, intent: Intent, target: String?, lang: Lang, onTip: (String) -> Unit) {
    val sign = when (intent.kind) {
        IntentKind.STRIKE -> if (intent.strong) "!!" else "!"
        IntentKind.CALL -> "»"
        IntentKind.GATHER -> "+"
    }
    // 211.9: never past the right edge of the scene ("Netz werfen → Bertram" over the spider at the back)
    Box(Modifier.offset(y = y).layout { m, c ->
        val p = m.measure(c.copy(minWidth = 0, maxWidth = Constraints.Infinity))
        val w = sceneW.roundToPx()
        layout(w, p.height) { p.place((x - 70.dp).roundToPx().coerceAtMost(w - p.width - 4.dp.roundToPx()).coerceAtLeast(4.dp.roundToPx()), 0) }
    }) {
        // 210: a long press explains it
        val explain = MarsTips.intent(intent.id, lang)
        val press = if (explain == null) Modifier else Modifier.pointerInput(intent.id) { detectTapGestures(onLongPress = { onTip(explain) }) }
        Row(press.background(Color.Black.copy(alpha = 0.75f)).border(1.dp, if (intent.strong) Veil.warn else Veil.gold).padding(horizontal = 6.dp, vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically) {
            val color = if (intent.strong) Veil.warn else Veil.bright
            Txt("$sign ", size = 14.sp, color = color, maxLines = 1)
            // 219.1: a blow with a ring carries a small golden ring, drawn like the real one (Homer, 219T)
            if (intent.ring) {
                Canvas(Modifier.size(13.dp)) { drawCircle(Veil.gold, radius = size.minDimension / 2 - 1.dp.toPx(), style = androidx.compose.ui.graphics.drawscope.Stroke(1.5.dp.toPx())) }
                Txt(" ", size = 14.sp, maxLines = 1)
            }
            Txt(intent.name(lang) + (target?.let { " → $it" } ?: ""), size = 14.sp, color = color, maxLines = 1)
        }
    }
}

/** A small red point over the figure the foe aims at. */
@Composable
private fun AimMark(x: Dp, y: Dp) {
    Canvas(Modifier.offset(x = x, y = y).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        val s = 6.dp.toPx()
        val p = Path().apply { moveTo(-s, -s); lineTo(s, -s); lineTo(0f, s * 0.6f); close() }
        drawPath(p, Veil.warn)
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

/** 211.10: the two of a row side by side (now) or set apart across the line of the fight; guides only for the preview. */
object MarsLayout {
    var offset = false
    /** 211.10 (Chef 21:39): the straight line of the fight, foes above the party (preview only until chosen). */
    var straight = false
    var guides = false
    /** 211.10, Chefsache 229: the places of both sides as faint outlines on the ground. */
    var grid = false
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
private fun NameTag(x: Dp, y: Dp, text: String, acting: Boolean) {
    Box(Modifier.offset(x = x - 70.dp, y = y).width(140.dp), contentAlignment = Alignment.Center) {
        Box(Modifier.background(Color.Black.copy(alpha = 0.7f)).padding(horizontal = 5.dp, vertical = 1.dp)) {
            Txt(text, size = 12.sp, color = if (acting) Veil.bright else Veil.text, maxLines = 1)
        }
    }
}

/** The roll behind a blow or a spell, with its numbers: "12 + 5 = 17 gegen RK 16" (72.10a.10). */
@Composable
private fun RollTag(x: Dp, y: Dp, r: RollInfo, lang: Lang) {
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
    Box(Modifier.offset(x = x - 120.dp, y = y).width(240.dp), contentAlignment = Alignment.Center) {
        Box(Modifier.background(Color.Black.copy(alpha = 0.8f)).border(1.dp, if (r.success == (r.kind == RollKind.ATTACK)) Veil.bright else Veil.dim).padding(horizontal = 6.dp, vertical = 2.dp)) {
            Txt(text, size = 13.sp, color = Veil.text, maxLines = 1, pixel = true)
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
