package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Game
import de.bornim.core.Jobs
import de.bornim.core.Lang
import de.bornim.game.GameViewModel

/**
 * The notice board before the inn (29): one window with every note, each taken up by its own button and nothing
 * asked twice (33). Taken notes stay on the board, marked, until the job is handed in.
 */
@Composable
fun BoardScreen(vm: GameViewModel, game: Game) {
    // D2.2: in the look of the text box (60), black with a thin gold rim like menu and shop
    androidx.compose.runtime.CompositionLocalProvider(LocalVeil provides true) {
        androidx.compose.foundation.layout.Box(Modifier.fillMaxSize().background(Color.Black)) { BoardBody(vm, game) }
    }
}

@Composable
private fun BoardBody(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    val de = lang == Lang.DE
    fun close() {
        game.advance()
        vm.refresh()
    }
    BackHandler { close() }
    Column(
        Modifier
            .fillMaxSize()
            .padding(10.dp)
    ) {
        Panel(Modifier.fillMaxWidth()) {
            Txt(if (de) "Anschlagbrett" else "Notice board", size = 22.sp, bold = true, color = Veil.gold)
        }
        Spacer(Modifier.height(8.dp))
        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            val notes = Jobs.onBoard(game.state)
            if (notes.isEmpty()) Panel(Modifier.fillMaxWidth()) {
                Txt(if (de) "Nur verblichene Nägel und Papierfetzen. Kein Aushang." else "Only faded nails and scraps of paper. No notices.", size = 16.sp)
            }
            for (j in notes) Panel(Modifier.fillMaxWidth()) {
                Column {
                    Txt(j.title(lang), size = 18.sp, bold = true)
                    Txt(j.note(lang), size = 15.sp)
                    Spacer(Modifier.height(4.dp))
                    Txt((if (de) "Lohn: " else "Reward: ") + j.reward(lang), size = 15.sp, color = Colors.textDim)
                    Spacer(Modifier.height(6.dp))
                    val taken = Jobs.isTaken(game.state, j)
                    PixelButton(
                        if (taken) (if (de) "Angenommen" else "Accepted") else (if (de) "Annehmen" else "Accept"),
                        Modifier.fillMaxWidth(), enabled = !taken,
                    ) {
                        game.takeJob(j.id)
                        vm.save()
                        vm.refresh()
                    }
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        PixelButton(if (de) "Zurück" else "Back", Modifier.fillMaxWidth()) { close() }
    }
}

/** The jobs the hero carries, for the menu (29): how far along each is, and a button to give it up (29e). */
@Composable
fun JobList(vm: GameViewModel, game: Game, lang: Lang) {
    val carried = Jobs.carried(game.state)
    if (carried.isEmpty()) return
    val de = lang == Lang.DE
    Spacer(Modifier.height(6.dp))
    Txt(if (de) "Nebenaufträge" else "Side quests", size = 18.sp, bold = true)
    for (j in carried) {
        Txt("${j.title(lang)}: ${Jobs.progress(game.state, j)}/${j.count} · ${j.giverName(lang)}", size = 16.sp)
        PixelButton(if (de) "Aufgeben" else "Give up", Modifier.fillMaxWidth(), size = 15.sp) {
            game.dropJob(j.id)
            vm.save()
            vm.refresh()
        }
    }
}
