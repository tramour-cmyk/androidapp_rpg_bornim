package de.bornim.game.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** 42 Textkasten (in the game since 42d, 12.10.; preview `TEXTKASTEN=1` shows old and new): the text box in the look of the black screens between places. */
object DialogLook {
    @Volatile var draft = true
}

/** The ink of the black screens (24.1): off-white like old paper, a dull gold. */
private object BoxInk {
    val text = Color(0xFFE6DDCB)
    val gold = Color(0xFFB59A6A)
    val rim = Color(0xAAB59A6A)
}

/**
 * The text box as 42b has it: all black, a thin gold rim, the speaker small and spaced in gold inside the box,
 * the words in off-white serif; told text (no speaker) in italics; the ▼ in gold.
 */
@Composable
fun DialogBoxVeil(speaker: String?, text: String, done: Boolean, modifier: Modifier = Modifier) {
    val time = rememberTime()
    Box(
        modifier
            .fillMaxWidth()
            .height(132.dp)
            .background(Color.Black)
            .border(1.dp, BoxInk.rim)
            .padding(horizontal = 18.dp, vertical = 12.dp),
    ) {
        Column {
            if (speaker != null) {
                Text(speaker.uppercase(), color = BoxInk.gold, style = TextStyle(fontFamily = FontFamily.Serif, fontSize = 12.sp, letterSpacing = 3.sp))
                Spacer(Modifier.height(6.dp))
            }
            Text(
                text, color = BoxInk.text,
                style = TextStyle(
                    fontFamily = FontFamily.Serif, fontSize = 17.sp, lineHeight = 24.sp, letterSpacing = 0.3.sp,
                    fontStyle = if (speaker == null) FontStyle.Italic else FontStyle.Normal,
                ),
            )
        }
        if (done && (time / 400) % 2 == 0L) {
            Text("▼", Modifier.align(Alignment.BottomEnd), color = BoxInk.gold, style = TextStyle(fontSize = 12.sp))
        }
    }
}
