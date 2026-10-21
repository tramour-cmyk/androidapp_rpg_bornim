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
 * [line] null shows only the name (a place visited often, 24i).
 */
@Composable
fun InterludeVeil(name: String, line: String?, veil: Float, words: Float, modifier: Modifier = Modifier) {
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
    const val SMOOTH_MS = 10_000L
}

/**
 * The black screen on starting play and on entering another map (24.1): it stays until the hero can walk every way,
 * the ground around him and the folk standing are drawn, at most about 4 s ([InterludeClock]). Coming back from a
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
    // stays true from the start of a screen to its end, so the black holds while the memory above already moved on
    var showing by remember { mutableStateOf(false) }
    LaunchedEffect(game, mapId) {
        if (!pending) return@LaunchedEffect
        showing = true
        val from = if (VeilMemory.game === game) VeilMemory.map else null
        VeilMemory.game = game; VeilMemory.map = mapId
        val st = game.state; val map = game.map
        fun ready() = MapFigure.ready(st.hero) && MapGround.readyNear(map, st.place.x, st.place.y) && MapFolk.standing(map)
        val seen = "seen:$mapId"
        val kind = InterludeClock.kindFor(from, mapId, firstVisit = !st.has(seen), readyNow = ready())
        st.flags += seen
        val line = if (kind == InterludeClock.Kind.FULL) Interlude.pick(Interlude.placeLines(mapId, st, game.isNight), VeilMemory.last) else null
        if (line != null) VeilMemory.last = line
        words = map.name(game.lang) to line?.invoke(game.lang)
        MapFigure.urgent = true; VeilMemory.active = true; VeilMemory.readyAfterMs = null
        try {
            val clock = withFrameMillis { InterludeClock(kind, it) }
            while (true) {
                val l = withFrameMillis { now ->
                    val r = ready()
                    if (r && VeilMemory.readyAfterMs == null) VeilMemory.readyAfterMs = now - clock.startMs
                    clock.at(now, r, tapped).also { tapped = false }
                }
                look = l
                if (l.done) break
            }
        } finally {
            MapFigure.urgent = false; VeilMemory.active = false; look = null; showing = false
        }
        // 175: how smoothly the map runs right after the screen, for the test tab
        VeilMemory.afterLongestMs = null; VeilMemory.afterSlow = 0; VeilMemory.afterBy = null; VeilMemory.afterGc = null
        var longest = 0L; var slow = 0; var alone = 0
        val by = HashMap<DrawBusy.Kind, Int>()
        val gc0 = de.bornim.game.DeviceInfo.gcNow()
        val t0 = withFrameMillis { it }
        var last = t0
        var mark = DrawBusy.mark()
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
        val gc1 = de.bornim.game.DeviceInfo.gcNow()
        VeilMemory.afterGc = Triple(gc1.first - gc0.first, gc1.second - gc0.second, gc1.third - gc0.third)
        VeilMemory.afterBy = by; VeilMemory.afterAlone = alone
        VeilMemory.afterSlow = slow; VeilMemory.afterLongestMs = longest
    }
    val l = look
    val veil = l?.veil ?: if (pending || showing) 1f else 0f
    if (veil > 0f) InterludeVeil(
        words.first, words.second, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
    )
}
