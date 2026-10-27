package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Lang
import de.bornim.core.audio.Mix
import de.bornim.core.audio.Sound
import de.bornim.game.GameViewModel

/** 13e.6: lays [a] of white over what is drawn: the black rises a little, the light stays as it is. */
fun Modifier.liftBlack(a: Float): Modifier = if (a <= 0f) this else drawWithContent {
    drawContent()
    drawRect(Color.White.copy(alpha = a))
}

/** 40, 13e.6: the three volume sliders and the brightness with its test sign, on the system tab. */
@Composable
fun SoundAndLight(vm: GameViewModel, lang: Lang) {
    val de = lang == Lang.DE
    val off = if (de) "Aus" else "Off"
    Column(verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(4.dp)) {
        Txt(if (de) "Lautstärke" else "Volume", size = 15.sp, bold = true)
        GoldSlider(if (de) "Gesamt" else "Overall", vm.volumeAll, off, { vm.changeVolumeAll(it) }) { vm.play(Sound.CLICK) }
        GoldSlider(if (de) "Musik" else "Music", if (vm.musicOn) vm.volumeMusic else 0, off, { vm.changeVolumeMusic(it) })
        // 40a: the sounds of a place go with the effects; on letting go one click shows how loud they are now
        GoldSlider(if (de) "Effekte und Ortsklang" else "Effects and ambience", if (vm.sfxOn) vm.volumeFx else 0, off, { vm.changeVolumeFx(it) }) { vm.play(Sound.CLICK) }
        Txt(if (de) "Helligkeit" else "Brightness", size = 15.sp, bold = true)
        GoldSlider(if (de) "Dunkle Töne" else "Shadows", vm.brightness, off, { vm.changeBrightness(it) })
        BrightnessSign()
        Txt(if (de) "So einstellen, dass das Zeichen gerade noch zu sehen ist. Die Höhle bleibt dunkel."
            else "Adjust until the sign is barely visible. The cave stays dark.", size = 13.sp, color = Colors.textDim)
    }
}

/** A slider in the black and gold look: name and value above, a gold line below; tap or drag, in steps of [Mix.STEP]. */
@Composable
private fun GoldSlider(label: String, value: Int, off: String, onChange: (Int) -> Unit, onDone: () -> Unit = {}) {
    val change by rememberUpdatedState(onChange)
    val done by rememberUpdatedState(onDone)
    Column(Modifier.fillMaxWidth()) {
        Row(Modifier.fillMaxWidth()) {
            Txt(label, Modifier.weight(1f), size = 14.sp)
            Txt(if (value == 0) off else "$value %", size = 14.sp, bold = true)
        }
        Box(
            Modifier.fillMaxWidth().height(36.dp)
                .pointerInput(Unit) {
                    fun at(x: Float) = Mix.clamp(Math.round(x / size.width * Mix.FULL))
                    detectTapGestures { change(at(it.x)); done() }
                }
                .pointerInput(Unit) {
                    fun at(x: Float) = Mix.clamp(Math.round(x / size.width * Mix.FULL))
                    detectHorizontalDragGestures(onDragEnd = { done() }) { c, _ -> change(at(c.position.x)) }
                },
            contentAlignment = Alignment.Center,
        ) {
            Canvas(Modifier.fillMaxWidth().height(36.dp)) {
                val y = size.height / 2
                val knob = 7.dp.toPx()
                val x = knob + (size.width - 2 * knob) * value / Mix.FULL
                drawLine(Veil.rim, Offset(knob, y), Offset(size.width - knob, y), 2.dp.toPx())
                drawLine(Veil.gold, Offset(knob, y), Offset(x, y), 3.dp.toPx())
                drawRect(Color.Black, Offset(x - knob, y - knob * 1.6f), Size(knob * 2, knob * 3.2f))
                drawRect(Veil.bright, Offset(x - knob, y - knob * 1.6f), Size(knob * 2, knob * 3.2f), style = Stroke(1.5.dp.toPx()))
            }
        }
    }
}

/**
 * The test sign (13e.6): a ring with a flame stroke in [Mix.SIGN] of 255 on pure black, as dark as a cave's outline.
 * It sits in the lifted picture like everything else, so the slider moves it.
 */
@Composable
private fun BrightnessSign() {
    val tone = Mix.SIGN / 255f
    Box(Modifier.fillMaxWidth().height(96.dp).background(Color.Black).border(1.dp, Veil.rim), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxWidth().height(96.dp)) {
            val c = Color(tone, tone, tone)
            val mid = Offset(size.width / 2, size.height / 2)
            val r = 28.dp.toPx()
            drawCircle(c, r, mid, style = Stroke(5.dp.toPx()))
            drawLine(c, Offset(mid.x, mid.y - r * 0.6f), Offset(mid.x, mid.y + r * 0.6f), 6.dp.toPx())
        }
    }
}
