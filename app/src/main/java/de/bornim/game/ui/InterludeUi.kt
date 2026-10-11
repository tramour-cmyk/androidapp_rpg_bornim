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
import androidx.compose.ui.text.font.FontFamily
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
 * The black screen between two places (24.1, docs/ZWISCHENBILD.md): the place's name small and spaced above,
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
                style = TextStyle(fontFamily = FontFamily.Serif, fontSize = 13.sp, letterSpacing = 4.sp),
            )
            if (line != null) {
                Spacer(Modifier.height(14.dp))
                Canvas(Modifier.width(44.dp).height(1.dp)) { drawRect(VeilInk.rule) }
                Spacer(Modifier.height(18.dp))
                Text(
                    line, color = VeilInk.text, textAlign = TextAlign.Center,
                    style = TextStyle(fontFamily = FontFamily.Serif, fontSize = 19.sp, lineHeight = 28.sp, letterSpacing = 0.6.sp),
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
}

/**
 * The black screen on starting play and on entering another map (24.1): it stays until the hero can walk every way,
 * the ground around him and the folk standing are drawn, at most about 4 s ([InterludeClock]). Coming back from a
 * fight or the menu to the same map shows nothing.
 */
@Composable
fun MapVeil(game: Game) {
    val mapId = game.state.place.map
    // black from the very first picture, so the new map never flashes up before the screen begins
    val pending = VeilMemory.game !== game || VeilMemory.map != mapId
    var look by remember { mutableStateOf<InterludeClock.Look?>(null) }
    var words by remember { mutableStateOf<Pair<String, String?>>("" to null) }
    var tapped by remember { mutableStateOf(false) }
    LaunchedEffect(game, mapId) {
        if (!pending) return@LaunchedEffect
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
            MapFigure.urgent = false; VeilMemory.active = false; look = null
        }
    }
    val l = look
    val veil = l?.veil ?: if (pending) 1f else 0f
    if (veil > 0f) InterludeVeil(
        words.first, words.second, veil, l?.words ?: 0f,
        Modifier.pointerInput(Unit) { detectTapGestures { tapped = true } },
    )
}
