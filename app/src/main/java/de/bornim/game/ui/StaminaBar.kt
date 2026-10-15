package de.bornim.game.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import de.bornim.core.GameState

/**
 * 86.3: the breath for running as an upright bar at the edge of the map, only while it is not full; it fades
 * in and out. Gold like the frame of the text box, a dull red while the hero is out of breath.
 */
@Composable
fun StaminaBar(state: GameState, rev: Int, modifier: Modifier = Modifier) {
    // [rev] changes every frame of walking, so the bar follows the store (95: it must be read here, an unused
    // parameter is left out of the comparison and the bar stood still once it had faded in)
    val stamina = remember(rev) { state.stamina }
    val winded = remember(rev) { state.winded }
    val full = stamina >= 1.0
    val shown by animateFloatAsState(if (full) 0f else 1f, tween(if (full) 900 else 250), label = "stamina")
    if (shown <= 0f) return
    val fill = stamina.toFloat()
    val color = if (winded) Color(0xFF9A4A3A) else Veil.gold
    Canvas(modifier.size(10.dp, 96.dp).alpha(shown)) {
        val r = CornerRadius(2.dp.toPx())
        drawRoundRect(Color(0xCC000000), cornerRadius = r)
        val pad = 2.dp.toPx()
        val h = (size.height - 2 * pad) * fill
        drawRoundRect(color, Offset(pad, size.height - pad - h), Size(size.width - 2 * pad, h), r)
        drawRoundRect(Veil.rim, cornerRadius = r, style = Stroke(1.dp.toPx()))
    }
}
