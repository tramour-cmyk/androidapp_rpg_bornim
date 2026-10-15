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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Intro
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
                f.under?.let { IntroPicture(vm, it, 1f) }
                IntroPicture(vm, f.picture, f.mix)
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

/** One picture at [alpha]; the black one is a soft dark vignette, so it does not look like a blank screen. */
@Composable
private fun IntroPicture(vm: GameViewModel, index: Int, alpha: Float) {
    val img = if (index == Intro.black) null else vm.introArt.get(index)
    if (img != null) Image(img, null, Modifier.fillMaxSize().alpha(alpha), contentScale = ContentScale.Crop)
    else Canvas(Modifier.fillMaxSize().alpha(alpha)) {
        drawRect(Brush.radialGradient(
            0f to Color(0xFF0C0A09), 0.6f to Color(0xFF050404), 1f to Color.Black,
            center = Offset(size.width / 2, size.height * 0.5f), radius = maxOf(size.width, size.height) * 0.6f,
        ))
    }
}
