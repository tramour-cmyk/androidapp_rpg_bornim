package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.foundation.layout.padding
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
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Fighter
import de.bornim.core.Intent
import de.bornim.core.IntentKind
import de.bornim.core.Lang
import de.bornim.core.MonsterLook
import de.bornim.core.Order
import de.bornim.core.Outcome
import de.bornim.core.Reaction
import de.bornim.core.Row as Line
import de.bornim.core.Side
import de.bornim.core.Skirmish
import de.bornim.core.SkirmishEvent
import de.bornim.core.Spot
import de.bornim.core.art.Act
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CaveScene
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
 * Probe 72.10 (DESIGN-KAMPF.md, Beschlüsse 72.11, 72.13, 72v): the hero and a Söldner against Grak on the painted
 * Kampfort (Grak's hall), two rows of two places a side. The fight runs on its own thread; every message comes here
 * and is played one after another, and when Grak's announced blow comes, the fight waits for the tap on the ring.
 */

/** How long the ring takes to close on the figure, and how far off a tap may be for "perfect" and "good". */
private const val RING_MS = 1100L
private const val PERFECT_MS = 90L
private const val GOOD_MS = 260L
/** How long one message stays before the next. */
private const val SAY_MS = 750L
private const val LUNGE_MS = 340L
/** The orders under the scene: the line of who acts and two rows of buttons (48 dp each). */
private val ORDERS_H = 136.dp

/** Where a place stands on the scene, as a share of its width and height: the party lower left, the foes upper right. */
private fun placeAt(side: Side, s: Spot): Pair<Float, Float> = when (side) {
    Side.PARTY -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.33f to 0.80f else 0.48f to 0.93f)
    else (if (s.slot == 0) 0.13f to 0.86f else 0.27f to 0.99f)
    Side.FOES -> if (s.row == Line.FRONT) (if (s.slot == 0) 0.62f to 0.56f else 0.76f to 0.66f)
    else (if (s.slot == 0) 0.75f to 0.42f else 0.89f to 0.51f)
}

/** The back row stands a little further off. */
private fun depth(s: Spot) = if (s.row == Line.BACK) 0.88f else 1f

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

private enum class Pick { MAIN, TARGET, PLACE }

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

    // what the screen shows: the state after the last played message, not the fight's own (it may be further on)
    var shown by remember(sk) {
        mutableStateOf(SkirmishEvent("", hp = sk.fighters.associate { it.id to it.hp }, places = sk.fighters.associate { it.id to it.place }, intents = LinkedHashMap(sk.intents)))
    }
    val lines = remember(sk) { mutableStateListOf<String>() }
    var busy by remember(sk) { mutableStateOf(true) }
    var ring by remember(sk) { mutableStateOf<Beat.Ring?>(null) }
    var ringStart by remember(sk) { mutableLongStateOf(0L) }
    var ringResult by remember(sk) { mutableStateOf<Reaction?>(null) }
    var verdict by remember(sk) { mutableStateOf<String?>(null) }
    var lunge by remember(sk) { mutableStateOf<Pair<String, String>?>(null) }
    var lungeAt by remember(sk) { mutableLongStateOf(0L) }
    val hurtAt = remember(sk) { mutableStateMapOf<String, Long>() }
    var pick by remember(sk) { mutableStateOf(Pick.MAIN) }
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
        run.run { sk.start(run.react) }
        for (b in run.beats) when (b) {
            is Beat.Say -> {
                val e = b.e
                shown = e
                if (e.text.isNotEmpty()) { lines += e.text; while (lines.size > 3) lines.removeAt(0) }
                val now = System.currentTimeMillis()
                val actor = e.actor
                val target = e.target
                if (actor != null && target != null && actor != target) { lunge = actor to target; lungeAt = now }
                if (e.damage > 0 && target != null) {
                    hurtAt[target] = now
                    vm.play(if (sk.byIdOrNull(e.actor)?.side == Side.FOES) Sound.HIT_SMASH else Sound.HIT_SLASH)
                } else if (e.actor != null && e.target != null && e.actor != e.target) vm.play(Sound.MISS, 0.5f)
                delay(SAY_MS)
            }
            is Beat.Ring -> {
                ringResult = null
                ringStart = System.currentTimeMillis()
                ring = b
                vm.play(Sound.SWING_HEAVY, 0.6f)
                val r = withTimeoutOrNull(RING_MS + GOOD_MS + 60) { b.answer.await() }
                    ?: Reaction.NONE.also { b.answer.complete(it) }
                ringResult = r
                verdict = when (r) {
                    Reaction.PERFECT -> t("Perfekt!", "Perfect!")
                    Reaction.GOOD -> t("Gut", "Good")
                    Reaction.NONE -> t("Verpasst", "Missed")
                }
                if (r == Reaction.PERFECT) vm.play(Sound.BLOCK) else if (r == Reaction.GOOD) vm.play(Sound.BLOCK, 0.5f)
                ring = null
                delay(300)
            }
            Beat.Done -> { busy = false; pick = Pick.MAIN }
        }
    }
    LaunchedEffect(verdict) { if (verdict != null) { delay(900); verdict = null } }

    fun order(o: Order) {
        busy = true
        pick = Pick.MAIN
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
            CaveBackground(CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72, false, sceneScale, Modifier.fillMaxSize())
            val shade = Color(CaveScene.tint(CaveScene.Spot.HALL, CaveScene.Light.TORCH, false))
            if (!ready) return@BoxWithConstraints
            val now = System.currentTimeMillis()
            // back to front, so the nearer figures stand before the farther
            val figures = sk.fighters.filter { shown.places[it.id] != null }.sortedBy { placeAt(it.side, shown.places[it.id]!!).second }
            for (f in figures) {
                val spot = shown.places[f.id]!!
                val (px, py) = placeAt(f.side, spot)
                val hp = shown.hp[f.id] ?: f.hp
                val down = hp <= 0
                // a short step towards the one it strikes, and back
                val (dx, dy) = lunge?.takeIf { it.first == f.id && now - lungeAt < LUNGE_MS }?.let { (_, to) ->
                    val tf = sk.byIdOrNull(to) ?: return@let 0f to 0f
                    val tp = shown.places[to] ?: return@let 0f to 0f
                    val (tx, ty) = placeAt(tf.side, tp)
                    val k = sin((now - lungeAt).toFloat() / LUNGE_MS * Math.PI.toFloat()) * 0.22f
                    (tx - px) * k to (ty - py) * k
                } ?: (0f to 0f)
                val hurt = hurtAt[f.id]?.let { (1f - (now - it) / 450f).coerceIn(0f, 1f) } ?: 0f
                val shake = if (hurt > 0f) (sin(now / 30f) * 4f * hurt).dp else 0.dp
                val x = sceneW * (px + dx) + shake
                val y = sceneH * (py + dy)
                val alpha = if (down) 0.35f else 1f
                val hero = f.hero
                val tall: Dp
                if (hero != null) {
                    val s = 0.62f * depth(spot)
                    val px1 = artDp * s
                    val idle = ((clock / 110) % 1000).toInt()
                    val img = HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, idle)
                        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                        ?: HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
                    tall = px1 * 150f
                    Shadow(x, y, px1 * 90f, alpha)
                    Box(Modifier.offset(x = x - px1 * HeroBattle.ANCHOR_X.toFloat(), y = y - px1 * HeroBattle.GROUND.toFloat())) {
                        PixelSprite(img, px1, alpha = alpha, shade = shade, hurt = hurt)
                    }
                } else {
                    val m = f.monster!!
                    val look = MonsterLook(0)
                    val s = (if (f.boss) 0.8f else 0.66f) * depth(spot)
                    val px1 = artDp * s
                    val r = ring
                    // Grak winds up while the ring closes on his target
                    val winding = r != null && shown.actor == f.id
                    val img = if (winding && MonsterArt.isNewStyle(m.id)) {
                        val strike = MonsterArt.strikeFrame(m.id, look, 0)
                        val p = ((now - ringStart).toFloat() / RING_MS).coerceIn(0f, 1f)
                        MonsterArt.shownFrame(m.id, look, Act.ATTACK, 0, (p * (strike - 1).coerceAtLeast(0)).toInt())
                    } else {
                        val n = MonsterArt.frameCount(m.id, look, Act.IDLE, 0).coerceAtLeast(1)
                        MonsterArt.shownFrame(m.id, look, Act.IDLE, 0, ((clock / 86) % n).toInt())
                    }
                    val frameW = if (MonsterArt.isDoll(m.id)) de.bornim.core.art.FoeArt.W else img.width
                    val spr = px1 / MonsterArt.fine(m.id).toFloat()
                    tall = px1 * (MonsterArt.groundLine(m.id).toFloat() * 0.85f)
                    Shadow(x, y, px1 * 70f, alpha)
                    Box(Modifier.offset(x = x - px1 * MonsterArt.anchorX(m.id, frameW).toFloat(), y = y - px1 * MonsterArt.groundLine(m.id).toFloat())) {
                        Box(Modifier.offset(x = spr * img.ox, y = spr * img.oy)) {
                            PixelSprite(img, spr, alpha = alpha, shade = shade, overflow = true, hurt = hurt)
                        }
                    }
                }
                // life bar over the head
                if (!down) LifeBar(x, y - tall - 8.dp, hp, f.maxHp)
                // the announced intent over the foe, the aim over its target
                shown.intents[f.id]?.let { (intent, _) -> IntentSign(x, y - tall - 34.dp, intent, lang) }
                if (!down && shown.intents.values.any { f.id in it.second }) AimMark(x, y - tall - 22.dp)
                // the ring closing on the attacked figure (72.11)
                ring?.takeIf { it.target == f.id }?.let { RingAround(x, y - tall * 0.45f, tall * 0.55f, ((now - ringStart).toFloat() / RING_MS)) }
            }
            verdict?.let { v ->
                Box(Modifier.align(Alignment.TopCenter).padding(top = 18.dp).background(Color.Black.copy(alpha = 0.7f)).border(1.dp, Veil.gold).padding(horizontal = 14.dp, vertical = 6.dp)) {
                    Txt(v, size = 22.sp, color = if (ringResult == Reaction.PERFECT) Veil.bright else if (ringResult == Reaction.GOOD) Veil.text else Veil.warn)
                }
            }
            if (ring != null) Txt(t("Tippen, wenn der Ring sich schließt", "Tap as the ring closes"), Modifier.align(Alignment.BottomCenter).padding(bottom = 6.dp), size = 14.sp, color = Veil.dim)
        }
        // words and orders
        Column(Modifier.fillMaxWidth().background(Color.Black).border(1.dp, Veil.rim).padding(10.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Column(Modifier.fillMaxWidth().height(72.dp)) {
                for (l in lines) Txt(l, size = 14.sp, maxLines = 1)
            }
            val party = sk.fighters.filter { it.side == Side.PARTY }
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                for (p in party) Txt("${p.name(lang)} ${shown.hp[p.id] ?: p.hp}/${p.maxHp}", size = 14.sp, color = if ((shown.hp[p.id] ?: p.hp) <= 0) Veil.warn else Veil.text, pixel = true)
            }
            val merc = party.firstOrNull { it.id == "merc" }
            // the orders keep one height whatever shows, so the scene above never jumps
            Column(Modifier.fillMaxWidth().height(ORDERS_H), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            when {
                !busy && sk.outcome != Outcome.ONGOING -> {
                    val won = sk.outcome == Outcome.WON
                    Txt(if (won) t("Grak ist besiegt.", "Grak is beaten.") else t("Die Probe ist verloren.", "The probe is lost."), size = 18.sp, color = if (won) Veil.bright else Veil.warn)
                    if (sk.knockouts > 0) Txt(t("Söldner bewusstlos: ", "Söldner knocked out: ") + sk.knockouts, size = 14.sp)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        PixelButton(t("Nochmal", "Again"), Modifier.weight(1f), size = 15.sp) { vm.startProbe(vm.probeClass) }
                        PixelButton(t("Zurück", "Back"), Modifier.weight(1f), size = 15.sp) { vm.probe = null }
                    }
                }
                busy -> Txt(t("…", "…"), size = 14.sp, color = Veil.dim)
                else -> {
                    val f = sk.current
                    Txt(t("Am Zug: ", "To act: ") + f.name(lang), size = 15.sp, color = Veil.bright)
                    when (pick) {
                        Pick.MAIN -> Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            val reach = sk.targets(f)
                            PixelButton(t("Angriff", "Attack"), Modifier.weight(1f), enabled = reach.isNotEmpty(), size = 15.sp) {
                                if (reach.size == 1) order(Order.Attack(reach[0].id)) else pick = Pick.TARGET
                            }
                            PixelButton(t("Platz", "Place"), Modifier.weight(1f), size = 15.sp) { pick = Pick.PLACE }
                            PixelButton(t("Abwarten", "Wait"), Modifier.weight(1f), size = 15.sp) { order(Order.Wait) }
                        }
                        Pick.TARGET -> {
                            val reach = sk.targets(f)
                            Choices(reach.map { target -> (target.name(lang) + if (reach.size < 4) "  ${target.hp}/${target.maxHp}" else "") to { order(Order.Attack(target.id)) } } +
                                (t("Zurück", "Back") to { pick = Pick.MAIN }))
                        }
                        Pick.PLACE -> Choices(Spot.ALL.filter { it != f.place }.map { s ->
                            val who = sk.fighters.firstOrNull { it.side == f.side && it.place == s }
                            (spotName(s, lang) + (who?.let { " ⇄ " + it.name(lang) } ?: "")) to { order(Order.Swap(s)) }
                        } + (t("Zurück", "Back") to { pick = Pick.MAIN }))
                    }
                }
            }
            // at the bottom always, so it stays under the finger; while a target or a place is picked, its choices take it
            Spacer(Modifier.weight(1f))
            if (sk.outcome == Outcome.ONGOING && pick == Pick.MAIN) Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                if (merc != null) {
                    var auto by remember(sk) { mutableStateOf(merc.auto) }
                    PixelButton(t("Söldner: ", "Söldner: ") + if (auto) t("Automatik", "auto") else t("selbst", "manual"), Modifier.weight(1f), selected = auto, size = 13.sp) {
                        merc.auto = !merc.auto; auto = merc.auto
                        if (auto && sk.current === merc) goOn()
                    }
                }
                var heroAuto by remember(sk) { mutableStateOf(false) }
                PixelButton(t("Automatik", "Autopilot") + if (heroAuto && sk.autopilot) " ✓" else "", Modifier.weight(1f), enabled = !busy, selected = heroAuto && sk.autopilot, size = 13.sp) {
                    val why = sk.autopilotBlocked()
                    if (sk.autopilot) { sk.setAutopilot(false); heroAuto = false }
                    else if (why != null) vm.toast = why(lang)
                    else { heroAuto = sk.setAutopilot(true); if (heroAuto) goOn() }
                }
            }
            }
        }
    }
}

/** Choices in the two rows of the orders: two side by side, three when there are more than four. */
@Composable
private fun Choices(items: List<Pair<String, () -> Unit>>) {
    val cols = if (items.size > 4) 3 else 2
    for (row in items.chunked(cols)) Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        for ((label, go) in row) PixelButton(label, Modifier.weight(1f), size = 13.sp, onClick = go)
        repeat(cols - row.size) { Spacer(Modifier.weight(1f)) }
    }
}

private fun Skirmish.byIdOrNull(id: String?): Fighter? = fighters.firstOrNull { it.id == id }

private fun spotName(s: Spot, lang: Lang): String {
    val de = lang == Lang.DE
    val row = if (s.row == Line.FRONT) (if (de) "vorn" else "front") else (if (de) "hinten" else "back")
    val side = if (s.slot == 0) (if (de) "links" else "left") else (if (de) "rechts" else "right")
    return "$row $side"
}

@Composable
private fun Shadow(x: Dp, y: Dp, w: Dp, alpha: Float) {
    Canvas(Modifier.offset(x = x - w / 2, y = y - 6.dp).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        drawOval(Color.Black.copy(alpha = 0.32f * alpha), Offset.Zero, androidx.compose.ui.geometry.Size(w.toPx(), 12.dp.toPx()))
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
@Composable
private fun IntentSign(x: Dp, y: Dp, intent: Intent, lang: Lang) {
    val sign = when (intent.kind) {
        IntentKind.STRIKE -> if (intent.strong) "!!" else "!"
        IntentKind.CALL -> "»"
        IntentKind.GATHER -> "+"
    }
    Box(Modifier.offset(x = x - 60.dp, y = y).wrapContentSize(Alignment.TopStart, unbounded = true)) {
        Box(Modifier.background(Color.Black.copy(alpha = 0.75f)).border(1.dp, if (intent.strong) Veil.warn else Veil.gold).padding(horizontal = 6.dp, vertical = 2.dp)) {
            Txt("$sign ${intent.name(lang)}", size = 12.sp, color = if (intent.strong) Veil.warn else Veil.bright, maxLines = 1)
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
