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
import androidx.compose.runtime.Composable
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
