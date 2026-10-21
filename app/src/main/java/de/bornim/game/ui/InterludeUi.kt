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
 * (only for the preview: the player sees the bar alone, Chef 21.10. "ohne Zahl").
 */
@Composable
fun InterludeVeil(
    name: String, line: String?, veil: Float, words: Float, modifier: Modifier = Modifier,
    parts: Pair<Int, Int>? = null, count: Boolean = false, bar: Float = 1f,
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
            if (line != null) {
                Spacer(Modifier.height(14.dp))
                Canvas(Modifier.width(44.dp).height(1.dp)) { drawRect(VeilInk.rule) }
                Spacer(Modifier.height(18.dp))
                Text(
                    line, color = VeilInk.text, textAlign = TextAlign.Center,
                    style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 28.sp, letterSpacing = 0.6.sp),
                )
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
private fun LoadBar(parts: Pair<Int, Int>, count: Boolean, modifier: Modifier = Modifier) {
    val (done, all) = parts
    val f = if (all <= 0) 1f else (done.toFloat() / all).coerceIn(0f, 1f)
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
}

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
    // stays true from the start of a screen to its end, so the black holds while the memory above already moved on
    var showing by remember { mutableStateOf(false) }
    LaunchedEffect(game, mapId) {
        if (!pending) return@LaunchedEffect
        showing = true
        val from = if (VeilMemory.game === game) VeilMemory.map else null
        VeilMemory.game = game; VeilMemory.map = mapId
        val st = game.state; val map = game.map
        fun ready() = MapFigure.ready(st.hero) && MapGround.readyNear(map, st.place.x, st.place.y) && MapFolk.standing(map)
        // the hero must be drawn anew (after an update, a new hero or new gear): a long wait, the bar shows at once
        var long = false
        fun count(): Pair<Int, Int> {
            val h = MapFigure.parts(st.hero)
            if (h != null && h.first < h.second) long = true
            val g = MapGround.partsNear(map, st.place.x, st.place.y); val f = MapFolk.partsStanding(map)
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
        parts = 0 to 1
        try {
            val clock = withFrameMillis { InterludeClock(kind, it) }
            var seenParts: Pair<Int, Int>? = null
            var movedMs = clock.startMs
            while (true) {
                val l = withFrameMillis { now ->
                    val r = ready()
                    if (r && VeilMemory.readyAfterMs == null) VeilMemory.readyAfterMs = now - clock.startMs
                    val c = count()
                    if (c != seenParts) { seenParts = c; movedMs = now }
                    parts = maxOf(c.first, minOf(parts.first, c.second)) to c.second
                    // nothing drawn for a long while: something is amiss, better to go on than to wait for ever
                    val stuck = now - movedMs > STUCK_MS
                    clock.at(now, r || stuck, tapped, long).also { tapped = false }
                }
                look = l
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
        }
    }
    val l = look
    val veil = l?.veil ?: if (pending || showing) 1f else 0f
    if (veil > 0f) InterludeVeil(
        words.first, words.second, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
        parts = parts.takeIf { (l?.bar ?: 0f) > 0f }, bar = l?.bar ?: 0f,
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
    var look by remember(battle) { mutableStateOf<InterludeClock.Look?>(null) }
    var words by remember(battle) { mutableStateOf<Interlude.FightWords?>(null) }
    var tapped by remember(battle) { mutableStateOf(false) }
    var parts by remember(battle) { mutableStateOf(0 to 1) }
    val ambushed = battle.opening == de.bornim.core.Opening.AMBUSHED
    val boss = battle.monster.boss
    LaunchedEffect(battle) {
        if (FightVeilMemory.off) { state.up = false; return@LaunchedEffect }
        val hero = battle.hero
        fun count(): Pair<Int, Int> {
            val h = de.bornim.core.art.HeroBattle.openingReady(hero, ambushed, walkIn)
            return (h.first + if (state.foeDrawn) 1 else 0) to (h.second + 1)
        }
        val first = de.bornim.core.art.HeroBattle.openingReady(hero, ambushed, walkIn)
        // the hero must be drawn anew (after an update, a new hero or new gear): a long wait, the bar shows at once
        val long = first.first < first.second
        val kind = InterludeClock.fightKind(ambushed, boss, readyNow = !long)
        val w = Interlude.fightWords(battle.opening, battle.pack != null && battle.packSize > 0, battle.monster.id, boss,
            full = kind != InterludeClock.Kind.FIGHT_SHORT, last = FightVeilMemory.last, lastFoe = FightVeilMemory.lastFoe)
        FightVeilMemory.last = w.start; w.foe?.let { FightVeilMemory.lastFoe = it }
        words = w
        try {
            val clock = withFrameMillis { InterludeClock(kind, it) }
            var seenParts: Pair<Int, Int>? = null
            var movedMs = clock.startMs
            while (true) {
                val l = withFrameMillis { now ->
                    val c = count()
                    if (c != seenParts) { seenParts = c; movedMs = now }
                    parts = maxOf(c.first, minOf(parts.first, c.second)) to c.second
                    val ready = state.heroDrawn && state.foeDrawn
                    // nothing drawn for a long while: better to fight than to wait for ever
                    clock.at(now, ready || now - movedMs > STUCK_MS, tapped, long).also { tapped = false }
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
        w?.start?.invoke(lang) ?: "", battle.monster.name(lang), w?.foe?.invoke(lang), boss, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
        parts = parts.takeIf { (l?.bar ?: 0f) > 0f }, bar = l?.bar ?: 0f,
    )
}

/**
 * 24.6: the words of the screen before a fight (docs/DESIGN-BLENDE.md 7): the sentence, the foe's name in dull gold
 * as a title (larger for a boss), the foe's own line smaller below; the same ground and bar as between places.
 */
@Composable
fun FightVeilBox(
    start: String, name: String, foe: String?, boss: Boolean, veil: Float, words: Float, modifier: Modifier = Modifier,
    parts: Pair<Int, Int>? = null, count: Boolean = false, bar: Float = 1f,
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
        if (parts != null) LoadBar(parts, count, Modifier.align(Alignment.BottomCenter).padding(bottom = 120.dp).alpha(bar))
    }
}
