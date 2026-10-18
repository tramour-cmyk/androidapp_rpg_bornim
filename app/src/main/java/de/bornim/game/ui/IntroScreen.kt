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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Intro
import de.bornim.core.IntroLife
import de.bornim.core.Lang
import de.bornim.core.Reel
import de.bornim.core.TempleLife
import de.bornim.core.TempleScene
import de.bornim.game.GameViewModel

/** How the intro starts: [auto] plays it for every new hero (the preview turns it off); [fromMs] starts it later (stills). */
object IntroLook {
    var auto = true
    var fromMs = 0L
}

/**
 * The intro (69, form `docs/DESIGN-STIL.md` „Zwischensequenzen“): the pictures one after the other with soft crossfades,
 * each with its sentence in the text box below; the last picture black. A tap asks whether to skip it (104); the chronicle shows it again.
 */
@Composable
fun IntroScreen(vm: GameViewModel) {
    ReelScreen(vm, Intro, onPicture = { vm.introPicture = it }, onEnd = { vm.endIntro() }) { index, alpha, ms -> IntroPicture(vm, index, alpha, ms) }
}

/**
 * The temple scene at the end of chapter 1 (68), built like the intro: five painted pictures with their sentences, the music
 * „Ancient Legend“ under it. A tap asks whether to skip it (104); afterwards the morning goes on (or, watched again, the chronicle comes back).
 */
@Composable
fun TempleSceneScreen(vm: GameViewModel) {
    ReelScreen(vm, TempleScene, onPicture = {}, onEnd = { vm.endTemple() }) { index, alpha, ms ->
        val img = vm.introArt.temple(index)
        if (img != null) Box(Modifier.fillMaxSize().alpha(alpha)) {
            Image(img, null, Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
            val life = vm.introArt.templeLife
            Canvas(Modifier.fillMaxSize()) {
                withTransform({ scale(size.width / TempleLife.W, size.width / TempleLife.W, Offset.Zero) }) {
                    clipRect(0f, 0f, TempleLife.W, TempleLife.H) { drawTempleLife(life, index + 1, ms) }
                }
            }
        }
    }
}

/**
 * Life over a temple picture (112, 7), in the picture's own pixels: every painted candle flame flickers and the light round it
 * breathes; in picture 4 the dust drifts in the sun shaft. The flame is drawn again over the painted one, a little larger at
 * its brightest, so the painted one never shows beside it.
 */
private fun DrawScope.drawTempleLife(life: TempleLife.Life, pic: Int, ms: Long) {
    for ((i, fl) in life.flames(pic).withIndex()) {
        val k = TempleLife.flicker(i, ms)
        val s = fl.s
        glow(fl.x, fl.y, s * 4.5f, warmDeep, 0.12f * (k - 0.8f) * 2.5f)
        glow(fl.x, fl.y, s * 1.3f, warm, 0.3f * k)
        for (q in 0 until 3) {
            val w = s * (0.13f - q * 0.03f)
            val h = s * (0.34f - q * 0.07f) * (0.9f + 0.3f * (k - 0.8f) * 2.5f) * TempleLife.flicker(i * 3 + q + 7, ms)
            val lean = 0.35f * kotlin.math.sin(ms / 1000f * 5.3f + i * 1.7f + q) * w
            val p = Path().apply { moveTo(fl.x - w, fl.y); quadraticBezierTo(fl.x - w * 0.8f, fl.y - h * 0.6f, fl.x + lean, fl.y - h); quadraticBezierTo(fl.x + w * 0.8f, fl.y - h * 0.5f, fl.x + w, fl.y); close() }
            drawPath(p, flameColors[q])
        }
    }
    life.shafts[pic]?.let { shaft ->
        for (m in TempleLife.motes(shaft, ms)) drawCircle(Color(0xFFFFE6B0).copy(alpha = m.a), m.r, Offset(m.x, m.y))
    }
}

/** A cutscene on screen: [reel]'s clock, the picture (drawn by [picture]) over the one before, the sentence below. */
@Composable
private fun ReelScreen(vm: GameViewModel, reel: Reel, onPicture: (Int) -> Unit, onEnd: () -> Unit, picture: @Composable (Int, Float, Long) -> Unit) {
    val start = remember { IntroLook.fromMs }
    val ms by produceState(start) {
        val t0 = withFrameMillis { it }
        while (true) withFrameMillis { value = start + it - t0 }
    }
    val f = reel.at(ms)
    LaunchedEffect(f.picture) { onPicture(f.picture) }
    LaunchedEffect(f.done) { if (f.done) onEnd() }
    // 104 (Chef 16.10.): a stray tap on the phone must not end the scene, so a tap only asks; the scene runs on meanwhile
    var asking by remember { mutableStateOf(false) }
    Box(Modifier.fillMaxSize()) {
    Box(
        Modifier.fillMaxSize().background(Color.Black)
            .clickable(remember { MutableInteractionSource() }, indication = null) { asking = true },
        contentAlignment = Alignment.Center,
    ) {
        Column(Modifier.fillMaxWidth().alpha(1f - f.gone), horizontalAlignment = Alignment.CenterHorizontally) {
            // the picture: 1080 × 1200, as wide as the screen allows
            Box(Modifier.fillMaxWidth().aspectRatio(0.9f)) {
                f.under?.let { picture(it, 1f, ms) }
                picture(f.picture, f.mix, ms)
            }
            Spacer(Modifier.height(14.dp))
            // the sentence in the text box: black, the thin gold rim, the serif of the black screens
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp).height(124.dp)
                    .alpha(f.text).border(1.dp, Veil.rim).padding(horizontal = 18.dp, vertical = 14.dp),
                contentAlignment = Alignment.CenterStart,
            ) {
                Text(
                    reel.lines[f.picture](vm.lang), color = Veil.text, textAlign = TextAlign.Start,
                    style = TextStyle(fontFamily = Serif, fontSize = 19.sp * TypeLook.scale, lineHeight = 27.sp, letterSpacing = 0.4.sp),
                )
            }
        }
    }
    if (asking) {
        val de = vm.lang == Lang.DE
        ConfirmDialog(DialogSpec(
            title = if (de) "Überspringen?" else "Skip?",
            confirm = if (de) "Überspringen" else "Skip",
            cancel = if (de) "Weiter ansehen" else "Keep watching",
            onConfirm = onEnd,
        ) { Txt(if (de) "Die Zwischensequenz endet, du kannst sie in der Chronik wieder ansehen." else "The scene ends; you can watch it again in the chronicle.", size = 16.sp) }) { asking = false }
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
            val vorn = vm.introArt.front(index)
            Canvas(Modifier.fillMaxSize()) {
                // the picture is 1080 × 1200 and fills the box exactly (same aspect)
                withTransform({ scale(size.width / IntroLife.W, size.width / IntroLife.W, Offset.Zero) }) {
                    clipRect(0f, 0f, IntroLife.W, IntroLife.H) { squareLife(zug, vorn, ms - index * Intro.STEP_MS, ms) }
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
private val flameColors = listOf(Color(0xFFE06A20), Color(0xFFFFB040), Color(0xFFFFF0B0))

/** A soft round light as the painter's `glow`: [a] in the middle, a third of it at a third of [r], none at the rim. */
private fun DrawScope.glow(x: Float, y: Float, r: Float, c: Color, a: Float) {
    if (r < 1f || a <= 0f) return
    val ac = a.coerceAtMost(1f)
    drawCircle(Brush.radialGradient(0f to c.copy(alpha = ac), 0.35f to c.copy(alpha = ac * 0.35f), 1f to c.copy(alpha = 0f), center = Offset(x, y), radius = r), r, Offset(x, y))
}

/**
 * Life over picture 3, the square (70.3 B, 70.6 A), in the picture's own pixels, [u] ms into the picture, [ms] into the intro:
 * the torch bearers walk along the lower street and up the temple path, each a painted cut-out from the sheet [zug] carried
 * along its way; their light on the street and in the puddle goes with them, the flames flicker; the temple [vorn] is laid
 * over them last, so they disappear behind its corner one after the other.
 */
private fun DrawScope.squareLife(zug: ImageBitmap?, vorn: ImageBitmap?, u: Long, ms: Long) {
    val torches = IntroLife.bearers.withIndex().filter { it.value.torch }
    val pos = IntroLife.bearers.indices.map { IntroLife.at(it, u) }
    // the torchlight lying on the street under each torch, added to the painted ground
    for ((i, _) in torches) {
        val (x, z) = pos[i]
        if (IntroLife.behindTemple(x, z)) continue
        val gx = IntroLife.sx(x, z); val gy = IntroLife.sy(0f, z)
        val r = IntroLife.F * 3.6f / z
        val a = 0.3f * IntroLife.flicker(i, ms)
        withTransform({ scale(1f, 0.3f, Offset(gx, gy)) }) {
            drawCircle(
                Brush.radialGradient(0f to amber.copy(alpha = a), 0.45f to amber.copy(alpha = a * 0.4f), 1f to amber.copy(alpha = 0f), center = Offset(gx, gy), radius = r),
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
            val (bx, bz) = pos[i]
            if (IntroLife.behindTemple(bx, bz)) continue
            val x = IntroLife.sx(bx + IntroLife.tipX(b), bz) + 1.5f * kotlin.math.sin(ms / 1000f * 5f + i)
            val fl = IntroLife.flicker(i, ms)
            drawRect(Brush.verticalGradient(0f to warm.copy(alpha = (0.7f * fl).coerceAtMost(1f)), 1f to warmDeep.copy(alpha = 0f), startY = y0, endY = y1), Offset(x - 3, y0), Size(6f, y1 - y0))
            glow(x, y0 + 6, 16f, warmDeep, 0.3f * fl)
            for (q in 1 until 6) { val yy = y0 + (y1 - y0) * q / 6f; drawLine(Color(0x990A0E18), Offset(x - 5, yy), Offset(x + 5, yy + 1), 1.2f) }
        }
    }
    // the bearers, far ones first: each cut-out from its slot on the sheet, scaled to its depth, feet on its place on the way
    val box = IntroLife.BOX
    if (zug != null) for (i in IntroLife.bearers.indices.sortedByDescending { pos[it].second }) {
        val (x, z) = pos[i]
        val k = IntroLife.SHEET_Z / z
        val fx = IntroLife.sx(x, z); val fy = IntroLife.sy(0f, z)
        val sl = IntroLife.slotX(i); val st = IntroLife.slotY
        drawImage(
            zug,
            srcOffset = IntOffset((sl + box[0]).toInt(), (st + box[1]).toInt()), srcSize = IntSize((box[2] - box[0]).toInt(), (box[3] - box[1]).toInt()),
            dstOffset = IntOffset((fx + box[0] * k).toInt(), (fy + box[1] * k).toInt()), dstSize = IntSize(((box[2] - box[0]) * k).toInt(), ((box[3] - box[1]) * k).toInt()),
        )
    }
    // the flames on the torch shafts
    for ((i, b) in torches) {
        val (x, z) = pos[i]
        val fx = IntroLife.sx(x + IntroLife.tipX(b), z); val fy = IntroLife.sy(IntroLife.tipY(b), z)
        val s = IntroLife.F / z * 1.5f
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
    // the temple in front of everything that walks behind it
    if (vorn != null) drawImage(vorn)
}
