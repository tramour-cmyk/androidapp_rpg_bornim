package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameMillis
import androidx.compose.ui.input.pointer.pointerInput
import de.bornim.core.Game
import de.bornim.core.Interlude
import de.bornim.core.InterludeClock
import de.bornim.core.T
import de.bornim.core.art.DrawBusy
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapFolk
import de.bornim.core.art.MapGround
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** The colours of the black screen between places (24.1): an off-white like old paper, a dull gold for the name. */
private object VeilInk {
    val text = Color(0xFFE6DDCB)
    val name = Color(0xFFB59A6A)
    val rule = Color(0x66B59A6A)
    val core = Color(0xFF15110E)
    val edge = Color(0xFF000000)
}

/**
 * The black screen between two places (24.1, docs/DESIGN-BLENDE.md): the place's name small and spaced above,
 * the sentence in a serif below, a breath of vignette so the black does not look like a crash.
 * [veil] is how much of the screen behind is hidden, [words] how far the words have come in; both 0..1.
 * [line] null shows only the name (a place visited often, 24i). [parts] (267.1) the pictures drawn and all that are
 * needed, shown as a thin gold bar low on the screen while a long wait is foreseen; [count] adds them as figures
 * (only for the preview: the player sees the bar alone, Chef 21.10. "ohne Zahl"). [quote] (267.1T) a saying and who said it,
 * which the sentence turns into at the same spot, mid-screen, as [turn] goes from 0 to 1.
 */
@Composable
fun InterludeVeil(
    name: String, line: String?, veil: Float, words: Float, modifier: Modifier = Modifier,
    parts: Pair<Int, Int>? = null, count: Boolean = false, bar: Float = 1f,
    quote: Pair<String, String>? = null, turn: Float = 0f,
) {
    Box(modifier.fillMaxSize().alpha(veil), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            drawRect(Brush.radialGradient(
                0f to VeilInk.core, 0.55f to Color(0xFF0A0807), 1f to VeilInk.edge,
                center = Offset(size.width / 2, size.height * 0.46f), radius = maxOf(size.width, size.height) * 0.62f,
            ))
        }
        Column(Modifier.fillMaxWidth().padding(horizontal = 36.dp).alpha(words), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                name.uppercase(), color = VeilInk.name, textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, letterSpacing = 4.sp),
            )
            val q = quote?.takeIf { turn > 0f }
            if (line != null || q != null) {
                Spacer(Modifier.height(14.dp))
                Canvas(Modifier.width(44.dp).height(1.dp)) { drawRect(VeilInk.rule) }
                Spacer(Modifier.height(18.dp))
                // one spot for both, so the sentence turns into the saying without anything moving
                Box(contentAlignment = Alignment.Center) {
                    if (line != null) Text(
                        line, Modifier.alpha(1f - turn), color = VeilInk.text, textAlign = TextAlign.Center,
                        style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 28.sp, letterSpacing = 0.6.sp),
                    )
                    if (q != null) Column(Modifier.alpha(turn), horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            q.first, color = VeilInk.text, textAlign = TextAlign.Center,
                            style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 28.sp, letterSpacing = 0.6.sp),
                        )
                        Spacer(Modifier.height(12.dp))
                        Text(
                            q.second, color = VeilInk.name, textAlign = TextAlign.Center,
                            style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, letterSpacing = 1.sp),
                        )
                    }
                }
            }
        }
        if (parts != null) LoadBar(parts, count, Modifier.align(Alignment.BottomCenter).padding(bottom = 120.dp).alpha(bar))
    }
}

/**
 * 267.1 (Chef 21.10.: "Wichtig ist, dass er sieht, dass passiert was und er kann halbwegs abschätzen, wie lange es noch
 * dauert"): a thin rule in dull gold that fills from the left with the pictures drawn, a soft glow at its head;
 * it counts pictures, never guesses time.
 */
@Composable
private fun LoadBar(parts: Pair<Int, Int>, count: Boolean, modifier: Modifier = Modifier, fill: Float? = null) {
    val (done, all) = parts
    // Rückläufer t66.1: before a fight the bar runs smoothly by the clock ([InterludeClock.Look.fill])
    val f = fill ?: if (all <= 0) 1f else (done.toFloat() / all).coerceIn(0f, 1f)
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Canvas(Modifier.width(180.dp).height(9.dp)) {
            val y = size.height / 2; val h = 1.dp.toPx() * 1.5f
            drawRect(VeilInk.rule, Offset(0f, y - h / 2), androidx.compose.ui.geometry.Size(size.width, h))
            val x = size.width * f
            drawRect(VeilInk.name, Offset(0f, y - h / 2), androidx.compose.ui.geometry.Size(x, h))
            drawCircle(Brush.radialGradient(listOf(VeilInk.name.copy(alpha = 0.55f), Color.Transparent), Offset(x, y), size.height), size.height, Offset(x, y))
        }
        // without the count the bar still stands where it would with it
        Spacer(Modifier.height(8.dp))
        Text(
            "$done / $all", color = if (count) VeilInk.rule else Color.Transparent, textAlign = TextAlign.Center,
            style = TextStyle(fontFamily = Serif, fontSize = 11.sp * TypeLook.scale, letterSpacing = 2.sp),
        )
    }
}

/** What the black screen remembers beyond one screen: the game and map it last showed, its last sentence (24.1). */
object VeilMemory {
    var game: Game? = null
    var map: String? = null
    var last: T? = null
    /** While it stands the hero does not walk on behind it. */
    @Volatile var active = false
    /** How long the last screen waited until everything was drawn, in ms, for the test tab; null while it waits. */
    @Volatile var readyAfterMs: Long? = null
    /** 299: when the hero, the ground and the folk each were drawn, in ms from the start of the screen; null while waiting. */
    @Volatile var heroAfterMs: Long? = null
    @Volatile var groundAfterMs: Long? = null
    @Volatile var folkAfterMs: Long? = null
    /** 299: the longest wait between two pictures while the screen stood (a hang hides the screen itself). */
    @Volatile var veilLongestMs: Long? = null
    /** 299: when „Weiter“ or „Neues Spiel“ was tapped (wall clock), and how long until the screen showed its first picture. */
    @Volatile var askedAtMs: Long? = null
    @Volatile var shownAfterMs: Long? = null
    /** 175: in the first [SMOOTH_MS] after the screen, the longest wait between two pictures and how many waited over 50 ms; null while measured. */
    @Volatile var afterLongestMs: Long? = null
    @Volatile var afterSlow = 0
    /** 267: in those [SMOOTH_MS], for each kind of drawing in the background how many of the slow pictures it drew during. */
    @Volatile var afterBy: Map<de.bornim.core.art.DrawBusy.Kind, Int>? = null
    /** 267: how many slow pictures came while nothing drew in the background. */
    @Volatile var afterAlone = 0
    /** 267: the runtime's collections of garbage in those [SMOOTH_MS]: all, those that held every thread, and how long these held. */
    @Volatile var afterGc: Triple<Long, Long, Long>? = null
    /** 267: when the map left the screen before [SMOOTH_MS] were up, after how long; the readings above then cover only that. */
    @Volatile var afterCutMs: Long? = null
    const val SMOOTH_MS = 10_000L

    /** 267.1T: the saying on the last long screen, kept across starts by the app (null: none ever, so Aldric's comes). */
    var lastQuote: String? = null
    var keepQuote: (String) -> Unit = {}

    /** 299: when hero, ground and folk were each drawn, for the test tab and the report. */
    fun parts(): String = (shownAfterMs?.let { "erschienen nach %.1f s, ".format(it / 1000f) } ?: "") + listOf("Held" to heroAfterMs, "Boden" to groundAfterMs, "Leute" to folkAfterMs)
        .joinToString(", ") { (k, v) -> k + " " + (v?.let { "%.1f s".format(it / 1000f) } ?: "–") }

    fun nextQuote(): Interlude.Quote = Interlude.quoteFor(lastQuote).also { lastQuote = it.id; keepQuote(it.id) }
}

/** 299: a wait between two pictures this long, in the black screen or after it, is kept beyond the next screen. */
private const val SLOW_KEEP_MS = 1_000L
/** 299: a screen that waited this long for its pictures is kept as well (B78: 7,3 s on the A56 went unkept at 8 s). */
private const val READY_KEEP_MS = 5_000L

/** 267.1: a black screen that sees no picture drawn for this long leaves even though not all is there. */
private const val STUCK_MS = 10_000L

/**
 * The black screen on starting play and on entering another map (24.1): it stays until the hero can walk every way,
 * the ground around him and the folk standing are drawn, at most [InterludeClock.HOLD_MS], with a loading bar for a long wait (267.1). Coming back from a
 * fight or the menu to the same map shows nothing. [mapId] is passed on its own: the [Game] object never changes,
 * so Compose would otherwise skip this on a map change.
 */
@Composable
fun MapVeil(game: Game, mapId: String) {
    // black from the very first picture, so the new map never flashes up before the screen begins
    val pending = VeilMemory.game !== game || VeilMemory.map != mapId
    var look by remember { mutableStateOf<InterludeClock.Look?>(null) }
    var words by remember { mutableStateOf<Pair<String, String?>>("" to null) }
    var tapped by remember { mutableStateOf(false) }
    // 267.1: the pictures drawn and all that are needed, for the loading bar; the count only grows
    var parts by remember { mutableStateOf(0 to 1) }
    // 267.1T: the saying of this screen, chosen when it begins to show
    var quote by remember { mutableStateOf<Interlude.Quote?>(null) }
    // stays true from the start of a screen to its end, so the black holds while the memory above already moved on
    var showing by remember { mutableStateOf(false) }
    LaunchedEffect(game, mapId) {
        if (!pending) return@LaunchedEffect
        showing = true
        val from = if (VeilMemory.game === game) VeilMemory.map else null
        VeilMemory.game = game; VeilMemory.map = mapId
        val st = game.state; val map = game.map
        // 267.2: in the woods the whole ground
        val reach = MapGround.veilReach(map)
        fun heroReady() = MapFigure.ready(st.hero)
        fun groundReady() = MapGround.readyNear(map, st.place.x, st.place.y, reach)
        fun folkReady() = MapFolk.standing(map)
        fun ready() = heroReady() && groundReady() && folkReady()
        // the hero must be drawn anew (after an update, a new hero or new gear): a long wait, the bar shows at once
        var long = false
        fun count(): Pair<Int, Int> {
            val h = MapFigure.parts(st.hero)
            if (h != null && h.first < h.second) long = true
            val g = MapGround.partsNear(map, st.place.x, st.place.y, reach); val f = MapFolk.partsStanding(map)
            val hero = h ?: (0 to MapFigure.YAWS * MapFigure.STEPS)
            return (hero.first + g.first + f.first) to (hero.second + g.second + f.second)
        }
        val seen = "seen:$mapId"
        val kind = InterludeClock.kindFor(from, mapId, firstVisit = !st.has(seen), readyNow = ready())
        st.flags += seen
        val line = if (kind == InterludeClock.Kind.FULL) Interlude.pick(Interlude.placeLines(mapId, st, game.isNight), VeilMemory.last) else null
        if (line != null) VeilMemory.last = line
        words = map.name(game.lang) to line?.invoke(game.lang)
        MapFigure.urgent = true; VeilMemory.active = true; VeilMemory.readyAfterMs = null
        VeilMemory.shownAfterMs = null; VeilMemory.heroAfterMs = null; VeilMemory.groundAfterMs = null; VeilMemory.folkAfterMs = null; VeilMemory.veilLongestMs = null
        var veilLongest = 0L
        parts = 0 to 1
        quote = null
        try {
            val clock = withFrameMillis { InterludeClock(kind, it) }
            VeilMemory.shownAfterMs = VeilMemory.askedAtMs?.let { System.currentTimeMillis() - it }; VeilMemory.askedAtMs = null
            var seenParts: Pair<Int, Int>? = null
            var movedMs = clock.startMs
            var lastFrame = clock.startMs
            while (true) {
                val l = withFrameMillis { now ->
                    // 299: the longest wait between two pictures while the screen stood (a hang hides the screen itself)
                    veilLongest = maxOf(veilLongest, now - lastFrame); lastFrame = now
                    VeilMemory.veilLongestMs = veilLongest
                    val at = now - clock.startMs
                    if (VeilMemory.heroAfterMs == null && heroReady()) VeilMemory.heroAfterMs = at
                    if (VeilMemory.groundAfterMs == null && groundReady()) VeilMemory.groundAfterMs = at
                    if (VeilMemory.folkAfterMs == null && folkReady()) VeilMemory.folkAfterMs = at
                    val r = ready()
                    if (r && VeilMemory.readyAfterMs == null) VeilMemory.readyAfterMs = at
                    val c = count()
                    if (c != seenParts) { seenParts = c; movedMs = now }
                    parts = maxOf(c.first, minOf(parts.first, c.second)) to c.second
                    // nothing drawn for a long while: something is amiss, better to go on than to wait for ever
                    val stuck = now - movedMs > STUCK_MS
                    clock.at(now, r || stuck, tapped, long).also { tapped = false }
                }
                look = l
                if (l.quote > 0f && quote == null) quote = VeilMemory.nextQuote()
                if (l.done) break
            }
        } finally {
            MapFigure.urgent = false; VeilMemory.active = false; look = null; showing = false
        }
        // 175: how smoothly the map runs right after the screen, for the test tab
        VeilMemory.afterLongestMs = null; VeilMemory.afterSlow = 0; VeilMemory.afterBy = null; VeilMemory.afterGc = null
        VeilMemory.afterCutMs = null
        var longest = 0L; var slow = 0; var alone = 0
        val by = HashMap<DrawBusy.Kind, Int>()
        val gc0 = de.bornim.game.DeviceInfo.gcNow()
        val t0 = withFrameMillis { it }
        var last = t0
        var mark = DrawBusy.mark()
        // t59.1: going to the menu or a fight ends this early; what was measured until then is kept and marked as cut short
        try {
            while (last - t0 < VeilMemory.SMOOTH_MS) {
                val now = withFrameMillis { it }
                val gap = now - last
                if (gap > longest) longest = gap
                if (gap > 50) {
                    slow++
                    val drew = DrawBusy.since(mark)
                    if (drew.isEmpty()) alone++ else for (k in drew) by[k] = (by[k] ?: 0) + 1
                }
                mark = DrawBusy.mark()
                last = now
            }
        } finally {
            if (last - t0 < VeilMemory.SMOOTH_MS) VeilMemory.afterCutMs = last - t0
            val gc1 = de.bornim.game.DeviceInfo.gcNow()
            VeilMemory.afterGc = Triple(gc1.first - gc0.first, gc1.second - gc0.second, gc1.third - gc0.third)
            VeilMemory.afterBy = by; VeilMemory.afterAlone = alone
            VeilMemory.afterSlow = slow; VeilMemory.afterLongestMs = longest
            // 299 (Chef 22.10., 11:52 „Es kam keine Blende“; die Werte waren beim nächsten Ortswechsel weg): a screen that
            // stood still or waited long is kept in the report of errors caught, which outlasts the next screen
            val ready = VeilMemory.readyAfterMs
            if (veilLongest > SLOW_KEEP_MS || longest > SLOW_KEEP_MS || (VeilMemory.shownAfterMs ?: 0L) > SLOW_KEEP_MS || (ready ?: Long.MAX_VALUE) > READY_KEEP_MS) de.bornim.game.CrashLog.note(
                "Blende $mapId (${if (from == null) "Spielbeginn" else "von $from"}): bereit nach " + (ready?.let { "%.1f s".format(it / 1000f) } ?: "–") + " (" + VeilMemory.parts() + ")" +
                    ", längste Bildpause in der Blende $veilLongest ms, danach $longest ms" + (VeilMemory.afterCutMs?.let { " (abgebrochen nach %.1f s)".format(it / 1000f) } ?: "") +
                    ", langsam während: " + (by.entries.sortedByDescending { it.value }.joinToString(", ") { (k, n) -> "${k.de} $n" } + ", nichts $alone"),
            )
        }
    }
    val l = look
    val veil = l?.veil ?: if (pending || showing) 1f else 0f
    if (veil > 0f) InterludeVeil(
        words.first, words.second, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
        parts = parts.takeIf { (l?.bar ?: 0f) > 0f }, bar = l?.bar ?: 0f,
        quote = quote?.let { it.text(game.lang) to it.who(game.lang) }, turn = l?.quote ?: 0f,
    )
}

/**
 * 24.6 (Chef 21.10., 17:29: „24.6 ja als Muss analog Blende mit Ladebalken bei Spielstart“): what the black screen
 * before a fight and the fight behind it share. The fight tells when its opening pictures are drawn; while the screen
 * is [up], the fight's words, moves and taps wait.
 */
class FightVeilState {
    /** The hero can walk in, face the foe and stand (the opening frames are drawn); set from the drawing threads. */
    @Volatile var heroDrawn = false
    /** The foe's frames (and its pack's) are drawn. */
    @Volatile var foeDrawn = false
    var up by mutableStateOf(true)
}

/** 24.6: the last sentences before a fight, so the next fight shows others; [off] only in the preview's battle films. */
object FightVeilMemory {
    var last: T? = null
    var lastFoe: T? = null
    var off = false
}

/**
 * 24.6, the black screen before a fight (docs/DESIGN-BLENDE.md 5, 7): the first line by how the fight begins, the foe's
 * name large below it, on a face-to-face start while the pictures are drawn (and against a boss always) a line of the
 * foe's own. It stays until the hero's opening frames and the foe are drawn, with the loading bar of 267.1 when the
 * hero must be drawn anew; all drawn already, it is over in about a second.
 */
@Composable
fun FightVeil(battle: de.bornim.core.Battle, lang: de.bornim.core.Lang, state: FightVeilState, walkIn: Boolean) {
    val ambushed = battle.opening == de.bornim.core.Opening.AMBUSHED
    val hero = battle.hero
    FightVeil(battle, lang, state, battle.opening, battle.pack != null && battle.packSize > 0, battle.monster.id, battle.monster.name(lang), battle.monster.boss,
        // the hero must be drawn anew (after an update, a new hero or new gear): a long wait, the bar shows at once
        long = { de.bornim.core.art.HeroBattle.openingReady(hero, ambushed, walkIn).let { it.first < it.second } },
        count = {
            val h = de.bornim.core.art.HeroBattle.openingReady(hero, ambushed, walkIn)
            (h.first + if (state.foeDrawn) 1 else 0) to (h.second + 1)
        })
}

/**
 * 24.6 for both fights (Chef 22.10., 07:43 „Neuerungen in beide Systeme“): the black screen before a fight keyed by
 * [key], for the foe [foeId] called [foeName]; [long] whether a long wait is foreseen, [count] the pictures drawn and
 * all needed. It goes once [FightVeilState.heroDrawn] and [FightVeilState.foeDrawn] are set.
 */
@Composable
fun FightVeil(
    key: Any, lang: de.bornim.core.Lang, state: FightVeilState, opening: de.bornim.core.Opening, pack: Boolean,
    foeId: String, foeName: String, boss: Boolean, long: () -> Boolean, count: () -> Pair<Int, Int>,
) {
    var look by remember(key) { mutableStateOf<InterludeClock.Look?>(null) }
    var words by remember(key) { mutableStateOf<Interlude.FightWords?>(null) }
    var tapped by remember(key) { mutableStateOf(false) }
    var parts by remember(key) { mutableStateOf(0 to 1) }
    val ambushed = opening == de.bornim.core.Opening.AMBUSHED
    LaunchedEffect(key) {
        if (FightVeilMemory.off) { state.up = false; return@LaunchedEffect }
        val long = long()
        val kind = InterludeClock.fightKind(ambushed, boss, readyNow = !long)
        val w = Interlude.fightWords(opening, pack, foeId, boss,
            full = kind != InterludeClock.Kind.FIGHT_SHORT, last = FightVeilMemory.last, lastFoe = FightVeilMemory.lastFoe)
        FightVeilMemory.last = w.start; w.foe?.let { FightVeilMemory.lastFoe = it }
        words = w
        try {
            val chars = w.start(lang).length + foeName.length + (w.foe?.invoke(lang)?.length ?: 0)
            val clock = withFrameMillis { InterludeClock(kind, it, InterludeClock.readMs(chars)) }
            var seenParts: Pair<Int, Int>? = null
            var movedMs = clock.startMs
            // Rückläufer t66 (Chef 21.10., 23:04 „fing nicht vorne an, sondern irgendwo“): the bar counts only what was
            // still to draw when the screen came, so it always fills from the left
            val before = count().first
            while (true) {
                val l = withFrameMillis { now ->
                    val c0 = count()
                    val c = (c0.first - before).coerceAtLeast(0) to (c0.second - before).coerceAtLeast(1)
                    if (c != seenParts) { seenParts = c; movedMs = now }
                    parts = maxOf(c.first, minOf(parts.first, c.second)) to c.second
                    val ready = state.heroDrawn && state.foeDrawn
                    // nothing drawn for a long while: better to fight than to wait for ever
                    clock.at(now, ready || now - movedMs > STUCK_MS, tapped, long, parts.first.toFloat() / parts.second).also { tapped = false }
                }
                look = l
                // the fight begins to show as the black lifts, so the walk-in is under way when it is gone
                if (l.veil < 0.5f) state.up = false
                if (l.done) break
            }
        } finally {
            state.up = false; look = null
        }
    }
    val w = words
    val l = look
    val veil = l?.veil ?: if (state.up && !FightVeilMemory.off) 1f else 0f
    if (veil > 0f) FightVeilBox(
        w?.start?.invoke(lang) ?: "", foeName, w?.foe?.invoke(lang), boss, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
        parts = parts.takeIf { (l?.bar ?: 0f) > 0f }, bar = l?.bar ?: 0f, fill = l?.fill,
    )
}

/**
 * 24.6: the words of the screen before a fight (docs/DESIGN-BLENDE.md 7): the sentence, the foe's name in dull gold
 * as a title (larger for a boss), the foe's own line smaller below; the same ground and bar as between places.
 */
@Composable
fun FightVeilBox(
    start: String, name: String, foe: String?, boss: Boolean, veil: Float, words: Float, modifier: Modifier = Modifier,
    parts: Pair<Int, Int>? = null, count: Boolean = false, bar: Float = 1f, fill: Float? = null,
) {
    Box(modifier.fillMaxSize().alpha(veil), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            drawRect(Brush.radialGradient(
                0f to VeilInk.core, 0.55f to Color(0xFF0A0807), 1f to VeilInk.edge,
                center = Offset(size.width / 2, size.height * 0.46f), radius = maxOf(size.width, size.height) * 0.62f,
            ))
        }
        Column(Modifier.fillMaxWidth().padding(horizontal = 36.dp).alpha(words), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                start, color = VeilInk.text, textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 28.sp, letterSpacing = 0.6.sp),
            )
            Spacer(Modifier.height(18.dp))
            Canvas(Modifier.width(44.dp).height(1.dp)) { drawRect(VeilInk.rule) }
            Spacer(Modifier.height(16.dp))
            Text(
                name.uppercase(), color = VeilInk.name, textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = Serif, fontSize = (if (boss) 30.sp else 24.sp) * TypeLook.scale, letterSpacing = 5.sp),
            )
            if (foe != null) {
                Spacer(Modifier.height(16.dp))
                Text(
                    foe, color = VeilInk.text.copy(alpha = 0.8f), textAlign = TextAlign.Center,
                    style = TextStyle(fontFamily = Serif, fontSize = 16.sp * TypeLook.scale, lineHeight = 24.sp, letterSpacing = 0.4.sp),
                )
            }
        }
        if (parts != null) LoadBar(parts, count, Modifier.align(Alignment.BottomCenter).padding(bottom = 120.dp).alpha(bar), fill)
    }
}
