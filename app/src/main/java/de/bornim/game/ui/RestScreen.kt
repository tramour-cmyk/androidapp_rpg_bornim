package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Game
import de.bornim.core.Items
import de.bornim.core.Resting
import de.bornim.core.Ui
import de.bornim.game.GameViewModel
import kotlinx.coroutines.delay

/**
 * 86.10/86.9: "Rasten?" by a campfire (short or long), Rowena's counter (mead, a room), the bed of the inn (a room).
 * In the look of the text box (60), black with a thin gold rim like the notice board. Over the dimmed world; a rest fades to
 * black, says how much time goes by, then the world is back with the rest's line.
 */
@Composable
fun RestScreen(vm: GameViewModel, game: Game, spot: Resting.Spot) {
    // the world stays in sight behind, dimmed and out of reach, as behind the text box
    Box(Modifier.fillMaxSize()) {
        WorldScreen(vm, game)
        CompositionLocalProvider(LocalVeil provides true) {
            Box(Modifier.fillMaxSize().background(Color(0x99000000)).tap {}) { RestBody(vm, game, spot) }
        }
    }
}

@Composable
private fun RestBody(vm: GameViewModel, game: Game, spot: Resting.Spot) {
    vm.tick
    val lang = vm.lang
    val s = game.state
    var note by remember { mutableStateOf<String?>(null) }
    // the rest chosen: the panel gives way to the time going by
    var passing by remember { mutableStateOf<Resting.Kind?>(null) }
    fun close() {
        game.advance()
        vm.refresh()
    }
    BackHandler(enabled = passing == null) { close() }

    passing?.let { kind ->
        val shown = remember { Animatable(0f) }
        LaunchedEffect(kind) {
            delay(400)
            shown.animateTo(1f, tween(500))
            delay(1300)
            shown.animateTo(0f, tween(400))
            val why = game.rest(kind, spot)
            if (why != null) { note = why(lang); passing = null }
            vm.refresh()
        }
        // the fade: from the dimmed world to black, the time going by, then the world again with the rest's line
        val dark = remember { Animatable(0f) }
        LaunchedEffect(kind) { dark.animateTo(1f, tween(500)) }
        Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = dark.value)), contentAlignment = Alignment.Center) {
            Txt(
                (if (kind == Resting.Kind.SHORT) Resting.hourGone else Resting.hoursGone)(lang),
                Modifier.alpha(shown.value), size = 20.sp, color = Veil.gold,
            )
        }
        return
    }

    Column(Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.Bottom) {
        Panel(Modifier.fillMaxWidth()) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                val title = when (spot) {
                    Resting.Spot.FIRE -> Resting.ask
                    Resting.Spot.TAVERN -> Resting.tavern
                    Resting.Spot.ROOM -> Resting.room
                }
                Txt(title(lang), size = 22.sp, bold = true, color = Veil.gold)
                if (spot != Resting.Spot.FIRE) Txt("${Ui.gold(lang)}: ${s.gold}", size = 15.sp, color = Colors.textDim)
                // 86: Rowena's word as the inn's panel opens, the mead or the room by chance, "enough" while drunk
                if (spot == Resting.Spot.TAVERN) {
                    val second = remember { kotlin.random.Random.nextBoolean() }
                    Txt(Resting.rowenaSays(s, game.hero.name, second)(lang), size = 15.sp)
                }
                val longOk = Resting.longAllowed(s)
                if (spot == Resting.Spot.FIRE) {
                    RestChoice(Resting.short(lang), Resting.shortDoes(lang)) { passing = Resting.Kind.SHORT }
                    RestChoice(Resting.long(lang), if (longOk) Resting.longDoes(lang) else Resting.longDone(lang), longOk) { passing = Resting.Kind.LONG }
                } else {
                    if (spot == Resting.Spot.TAVERN) {
                        val price = Resting.meadPrice(s)
                        // 173: no more mead once the hero is drunk; Rowena's "enough" above says why
                        if (!s.drunk) RestChoice(Resting.meadBuy.f(lang, price), Resting.meadDoes(lang), s.gold >= price) {
                            note = game.drinkMead()(lang)
                            vm.save()
                            vm.refresh()
                        }
                        // 139: Rowena buys raw meat, only while the hero carries some
                        val meat = s.count("raw_meat")
                        if (meat > 0) RestChoice(Resting.meatSell.f(lang, meat * game.sellPrice("raw_meat")), "${meat}× ${Items["raw_meat"].name(lang)}") {
                            note = game.sellMeat()?.invoke(lang)
                            vm.save()
                            vm.refresh()
                        }
                    }
                    val roomOk = longOk && s.gold >= Resting.ROOM_PRICE
                    RestChoice(Resting.roomBuy.f(lang, Resting.ROOM_PRICE), if (longOk) Resting.roomDoes(lang) else Resting.longDone(lang), roomOk) {
                        passing = Resting.Kind.LONG
                    }
                }
                note?.let { Txt(it, size = 15.sp) }
                Spacer(Modifier.height(2.dp))
                PixelButton(Resting.leave(lang), Modifier.fillMaxWidth()) { close() }
            }
        }
    }
}

/** One way to rest: the button, and underneath in dim letters what it does or why it cannot be had. */
@Composable
private fun RestChoice(label: String, does: String, enabled: Boolean = true, act: () -> Unit) {
    Column {
        PixelButton(label, Modifier.fillMaxWidth(), enabled = enabled) { act() }
        Txt(does, size = 14.sp, color = Colors.textDim)
    }
}
