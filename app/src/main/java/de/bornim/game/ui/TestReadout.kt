package de.bornim.game.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Game

/** Test tab (86.1): the hero's tile and map over the map, to name a place when reporting. */
object PlaceMeter {
    var on by mutableStateOf(false)

    /** "Dorf · x 33, y 28" for [game]'s hero; the map's id when it has no name in [game]'s language. */
    fun text(game: Game): String {
        val p = game.state.place
        val name = game.map.name(game.lang).ifBlank { p.map }
        return "$name · x ${p.x}, y ${p.y}"
    }
}

/**
 * Test tab (27m, 86.1): frame rate and the hero's place, top left over the map, in the light text of the
 * black windows on a nearly opaque ground, so they can be read in daylight and over a bright map
 * (Nutzer 14.10.: "wenn ich es einblende, will ich es auch sehen und lesen können").
 */
@Composable
fun TestReadout(game: Game, rev: Int, modifier: Modifier = Modifier) {
    // [rev] changes with every step, so the place follows the hero
    if (!FrameMeter.on && !PlaceMeter.on) return
    CompositionLocalProvider(LocalVeil provides true) {
        Column(modifier.background(Color(0xE6000000)).padding(horizontal = 8.dp, vertical = 4.dp)) {
            if (FrameMeter.on) Txt(FrameMeter.text, size = 16.sp, color = Colors.textLight, bold = true)
            if (PlaceMeter.on) Txt(PlaceMeter.text(game), size = 16.sp, color = Colors.textLight, bold = true)
        }
    }
}

/**
 * 86.4, 131: how far the finger is dragged before the hero walks, and the ring beyond which he runs, in dp, for the
 * menu's three joystick settings: 0 fine, 1 normal (about 2.5 cm), 2 calm. Inside the ring the hero walks.
 */
object StickFeel {
    fun walkAt(feel: Int): Int = intArrayOf(10, 14, 18)[feel.coerceIn(0, 2)]
    /** 2, 2.5 and 3 cm (160 dp to the inch). */
    fun runAt(feel: Int): Int = intArrayOf(126, 157, 189)[feel.coerceIn(0, 2)]
}
