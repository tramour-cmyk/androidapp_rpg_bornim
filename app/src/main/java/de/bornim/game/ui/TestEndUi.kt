package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.unit.dp

/**
 * 272 (Chef 20.10., test mode only): two half seen signs like the grid sign, in both fights: the cross loses the fight
 * at once, the tick wins it; the fight ends as it always does (the fall, the spoils). [asked]: the one tapped while the
 * fight still plays, framed brightly until it comes.
 */
@Composable
fun TestEndSwitches(asked: Boolean?, modifier: Modifier, onEnd: (win: Boolean) -> Unit) {
    Row(modifier) {
        TestEndSign(win = false, asked == false) { onEnd(false) }
        TestEndSign(win = true, asked == true) { onEnd(true) }
    }
}

@Composable
private fun TestEndSign(win: Boolean, on: Boolean, onTap: () -> Unit) {
    Box(Modifier.size(48.dp).clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { onTap() }, contentAlignment = Alignment.Center) {
        Canvas(Modifier.size(40.dp).background(Color.Black.copy(alpha = 0.35f)).border(1.dp, Veil.gold.copy(alpha = if (on) 0.9f else 0.4f)).padding(10.dp)) {
            val c = (if (win) Veil.gold else Veil.warn).copy(alpha = if (on) 1f else 0.7f)
            val w = 2.dp.toPx()
            if (win) {
                drawLine(c, Offset(0f, size.height * 0.55f), Offset(size.width * 0.38f, size.height * 0.9f), w, StrokeCap.Round)
                drawLine(c, Offset(size.width * 0.38f, size.height * 0.9f), Offset(size.width, size.height * 0.1f), w, StrokeCap.Round)
            } else {
                drawLine(c, Offset(0f, 0f), Offset(size.width, size.height), w, StrokeCap.Round)
                drawLine(c, Offset(size.width, 0f), Offset(0f, size.height), w, StrokeCap.Round)
            }
        }
    }
}
