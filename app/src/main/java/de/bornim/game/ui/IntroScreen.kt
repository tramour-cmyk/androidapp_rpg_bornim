package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.withFrameMillis
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Intro
import de.bornim.core.IntroLife
import de.bornim.game.GameViewModel

/** How the intro starts: [auto] plays it for every new hero (the preview turns it off); [fromMs] starts it later (stills). */
object IntroLook {
    var auto = true
    var fromMs = 0L
}

/**
 * The intro (69, form `docs/DESIGN-STIL.md` „Zwischensequenzen“): the pictures one after the other with soft crossfades,
 * each with its sentence in the text box below; the last picture black. A tap anywhere skips it; the chronicle shows it again.
 */
@Composable
fun IntroScreen(vm: GameViewModel) {
    val start = remember { IntroLook.fromMs }
    val ms by produceState(start) {
        val t0 = withFrameMillis { it }
        while (true) withFrameMillis { value = start + it - t0 }
    }
    val f = Intro.at(ms)
    LaunchedEffect(f.picture) { vm.introPicture = f.picture }
    LaunchedEffect(f.done) { if (f.done) vm.endIntro() }
    Box(
        Modifier.fillMaxSize().background(Color.Black)
            .clickable(remember { MutableInteractionSource() }, indication = null) { vm.endIntro() },
        contentAlignment = Alignment.Center,
    ) {
        Column(Modifier.fillMaxWidth().alpha(1f - f.gone), horizontalAlignment = Alignment.CenterHorizontally) {
            // the picture: 1080 × 1200, as wide as the screen allows
            Box(Modifier.fillMaxWidth().aspectRatio(0.9f)) {
                f.under?.let { IntroPicture(vm, it, 1f, ms) }
                IntroPicture(vm, f.picture, f.mix, ms)
            }
            Spacer(Modifier.height(14.dp))
            // the sentence in the text box: black, the thin gold rim, the serif of the black screens
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp).height(124.dp)
                    .alpha(f.text).border(1.dp, Veil.rim).padding(horizontal = 18.dp, vertical = 14.dp),
                contentAlignment = Alignment.CenterStart,
            ) {
                Text(
                    Intro.lines[f.picture](vm.lang), color = Veil.text, textAlign = TextAlign.Start,
                    style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 27.sp, letterSpacing = 0.4.sp),
                )
            }
        }
    }
}

/**
 * One picture at [alpha], [ms] into the intro; the black one is a soft dark vignette, so it does not look like a blank screen.
 * A picture with life (70.3 B) gets it drawn over the painting.
 */
@Composable
private fun IntroPicture(vm: GameViewModel, index: Int, alpha: Float, ms: Long) {
    val img = if (index == Intro.black) null else vm.introArt.get(index)
    if (img != null) Box(Modifier.fillMaxSize().alpha(alpha)) {
        Image(img, null, Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        if (index == IntroLife.SQUARE) {
            val zug = vm.introArt.layer(index)
            Canvas(Modifier.fillMaxSize()) {
                // the picture is 1080 × 1200 and fills the box exactly (same aspect)
                withTransform({ scale(size.width / IntroLife.W, size.width / IntroLife.W, Offset.Zero) }) {
                    clipRect(0f, 0f, IntroLife.W, IntroLife.H) { squareLife(zug, ms - index * Intro.STEP_MS, ms) }
                }
            }
        }
    }
    else Canvas(Modifier.fillMaxSize().alpha(alpha)) {
        drawRect(Brush.radialGradient(
            0f to Color(0xFF0C0A09), 0.6f to Color(0xFF050404), 1f to Color.Black,
            center = Offset(size.width / 2, size.height * 0.5f), radius = maxOf(size.width, size.height) * 0.6f,
        ))
    }
}

private val warm = Color(0xFFFFC060)
private val warmDeep = Color(0xFFE07A28)
private val amber = Color(0xFFB07A40)
private val smoke = Color(0xFF8A94AC)
private val flameColors = listOf(Color(0xFFE06A20), Color(0xFFFFB040), Color(0xFFFFF0B0))

/** A soft round light as the painter's `glow`: [a] in the middle, a third of it at a third of [r], none at the rim. */
private fun DrawScope.glow(x: Float, y: Float, r: Float, c: Color, a: Float) {
    if (r < 1f || a <= 0f) return
    val ac = a.coerceAtMost(1f)
    drawCircle(Brush.radialGradient(0f to c.copy(alpha = ac), 0.35f to c.copy(alpha = ac * 0.35f), 1f to c.copy(alpha = 0f), center = Offset(x, y), radius = r), r, Offset(x, y))
}

/**
 * Life over picture 3, the square (70.3 B), in the picture's own pixels, [u] ms into the picture, [ms] into the intro:
 * the torch bearers' layer walks its last steps to the temple door (once), their light on the stones and in the puddle goes
 * with them, the flames flicker, the candles in the door breathe, the smoke from the left chimney rises.
 */
private fun DrawScope.squareLife(zug: ImageBitmap?, u: Long, ms: Long) {
    val (k, shift) = IntroLife.layer(u)
    val vx = IntroLife.W / 2 - IntroLife.PAN; val vy = IntroLife.HY
    fun mx(x: Float) = vx + (x - vx) * k + shift
    fun my(y: Float) = vy + (y - vy) * k
    val torches = IntroLife.bearers.withIndex().filter { it.value.torch }
    // the smoke from the chimney of the left house: puffs rise, drift off to the right and thin out
    val sway = IntroLife.sway(ms)
    for (i in 0 until IntroLife.SMOKE_PUFFS) {
        val t = IntroLife.puff(i, ms)
        val a = 0.2f * (1 - t) * (t / 0.08f).coerceAtMost(1f)
        glow(IntroLife.smokeX + IntroLife.drift(t, i) + sway * t, IntroLife.smokeY - 6 - t * 220, 8 + t * 50, smoke, a)
    }
    // the candles in the open temple door breathe
    glow(IntroLife.sx(IntroLife.doorX, IntroLife.doorZ), IntroLife.sy(1.65f, IntroLife.doorZ), IntroLife.F * 1.2f / IntroLife.doorZ, Color(0xFFFFD080), 0.12f * (IntroLife.flicker(11, ms) - 0.8f) / 0.4f)
    // the torchlight lying on the stones under each torch, added to the painted stones
    for ((i, b) in torches) {
        val gx = mx(IntroLife.sx(b.x, b.z)); val gy = my(IntroLife.sy(0f, b.z))
        val r = IntroLife.F * 6.6f / b.z * k
        val a = 0.36f * IntroLife.flicker(i, ms)
        withTransform({ scale(1f, IntroLife.EYE / b.z, Offset(gx, gy)) }) {
            drawCircle(
                Brush.radialGradient(0f to amber.copy(alpha = a), 0.33f to amber.copy(alpha = a * 0.37f), 0.67f to amber.copy(alpha = a * 0.135f), 1f to amber.copy(alpha = 0f), center = Offset(gx, gy), radius = r),
                r, Offset(gx, gy), blendMode = BlendMode.Plus,
            )
        }
    }
    // the torches mirrored in the puddle as warm wavering streaks, broken by ripples
    val outline = IntroLife.puddle()
    val pool = Path().apply { outline.forEachIndexed { j, (x, y) -> if (j == 0) moveTo(x, y) else lineTo(x, y) }; close() }
    clipPath(pool) {
        val y0 = IntroLife.sy(0f, IntroLife.PUDDLE_Z + IntroLife.PUDDLE_W * 0.6f); val y1 = IntroLife.sy(0f, IntroLife.PUDDLE_Z - IntroLife.PUDDLE_W * 0.6f)
        for ((i, b) in torches) {
            val x = mx(IntroLife.sx(b.x + 0.45f, b.z)) + 1.5f * kotlin.math.sin(ms / 1000f * 5f + i)
            val fl = IntroLife.flicker(i, ms)
            drawRect(Brush.verticalGradient(0f to warm.copy(alpha = (0.7f * fl).coerceAtMost(1f)), 1f to warmDeep.copy(alpha = 0f), startY = y0, endY = y1), Offset(x - 4, y0), Size(8f, y1 - y0))
            glow(x, y0 + 8, 22f, warmDeep, 0.3f * fl)
            for (q in 1 until 6) { val yy = y0 + (y1 - y0) * q / 6f; drawLine(Color(0x990A0E18), Offset(x - 6, yy), Offset(x + 6, yy + 1), 1.2f) }
        }
    }
    // the torch bearers, painted, walking as one group
    if (zug != null) withTransform({ translate(shift, 0f); scale(k, k, Offset(vx, vy)) }) { drawImage(zug) }
    // the flames on the torch shafts
    for ((i, b) in torches) {
        val fx = mx(IntroLife.sx(b.tipX, b.z)); val fy = my(IntroLife.sy(b.tipY, b.z))
        val s = IntroLife.F / b.z * k * 1.5f
        val fl = IntroLife.flicker(i, ms)
        glow(fx, fy, s * 4.5f, warmDeep, 0.3f * fl)
        glow(fx, fy, s * 1.3f, warm, 0.6f * fl)
        for (q in 0 until 3) {
            val w = s * (0.12f - q * 0.03f)
            val h = s * (0.32f - q * 0.07f) * (0.85f + 0.3f * ((i * 7 + q * 3) % 5) / 4f) * IntroLife.flicker(i * 3 + q + 7, ms)
            val lean = (0.2f + 0.5f * kotlin.math.sin(ms / 1000f * 6.1f + i * 1.3f + q)) * w
            val p = Path().apply { moveTo(fx - w, fy); quadraticBezierTo(fx - w * 0.8f, fy - h * 0.6f, fx + lean, fy - h); quadraticBezierTo(fx + w * 0.8f, fy - h * 0.5f, fx + w, fy); close() }
            drawPath(p, flameColors[q])
        }
    }
}
