package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Facing
import de.bornim.core.Lang
import de.bornim.core.Ui
import de.bornim.core.World
import de.bornim.core.art.CharacterArt
import de.bornim.game.GameViewModel
import de.bornim.game.Screen
import de.bornim.game.SlotInfo
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** The saved heroes: load one, delete one, or start a new hero in an empty slot. */
@Composable
fun SlotsScreen(vm: GameViewModel) {
    vm.slotsVersion
    val lang = vm.lang
    val de = lang == Lang.DE
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    BackHandler { if (dialog != null) dialog = null else vm.screen = Screen.TITLE }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize().padding(12.dp)) {
            Panel(Modifier.fillMaxWidth()) {
                Txt(if (de) "Spielstände" else "Saved games", size = 22.sp, bold = true)
            }
            Spacer(Modifier.height(10.dp))
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                vm.slots().forEachIndexed { i, info ->
                    val n = i + 1
                    Panel(Modifier.fillMaxWidth()) {
                        if (info == null) {
                            Column {
                                Txt((if (de) "Platz $n · leer" else "Slot $n · empty"), size = 17.sp, bold = true, color = Colors.textDim)
                                Spacer(Modifier.height(8.dp))
                                PixelButton(Ui.newGame(lang), Modifier.fillMaxWidth(), size = 15.sp) {
                                    vm.pendingSlot = n
                                    vm.screen = Screen.CREATE
                                }
                            }
                        } else SlotCard(info, lang,
                            onLoad = { vm.continueGame(n) },
                            onDelete = {
                                dialog = DialogSpec(
                                    title = if (de) "Spielstand löschen?" else "Delete saved game?",
                                    confirm = if (de) "Löschen" else "Delete", cancel = if (de) "Abbrechen" else "Cancel",
                                    onConfirm = { vm.deleteSlot(n) },
                                ) {
                                    Txt(
                                        if (de) "${info.name} (Stufe ${info.level}) wird endgültig gelöscht." else "${info.name} (level ${info.level}) will be deleted for good.",
                                        size = 15.sp,
                                    )
                                }
                            },
                        )
                    }
                }
            }
            Spacer(Modifier.height(10.dp))
            BackRow(Ui.back(lang)) { vm.screen = Screen.TITLE }
        }
        dialog?.let { ConfirmDialog(it) { dialog = null } }
    }
}

/** One saved hero: sprite, name, class, level, where and when. */
@Composable
fun SlotCard(info: SlotInfo, lang: Lang, onLoad: (() -> Unit)? = null, onDelete: (() -> Unit)? = null) {
    val de = lang == Lang.DE
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            PixelImageView(CharacterArt.hero(info.race, info.cls, Facing.DOWN), 64.dp)
            Spacer(Modifier.width(10.dp))
            Column(Modifier.weight(1f)) {
                Txt((if (de) "Platz ${info.slot} · " else "Slot ${info.slot} · ") + info.name, size = 18.sp, bold = true, maxLines = 1)
                Txt("${info.race.title(lang)} · ${info.cls.title(lang)} · ${Ui.level(lang)} ${info.level}", size = 14.sp)
                val place = runCatching { World[info.place].name(lang) }.getOrDefault(info.place)
                Txt("$place · " + (if (de) "Tag " else "Day ") + info.day + " · " + "%02d:%02d".format(info.minutes / 60, info.minutes % 60), size = 13.sp, color = Colors.textDim)
                if (info.savedAt > 0) {
                    val fmt = SimpleDateFormat(if (de) "dd.MM.yyyy, HH:mm" else "yyyy-MM-dd, HH:mm", Locale.getDefault())
                    Txt((if (de) "Gespeichert: " else "Saved: ") + fmt.format(Date(info.savedAt)), size = 12.sp, color = Colors.textDim)
                }
            }
        }
        if (onLoad != null || onDelete != null) {
            Spacer(Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                onDelete?.let { PixelButton(if (de) "Löschen" else "Delete", Modifier.weight(1f), size = 15.sp, onClick = it) }
                onLoad?.let { PixelButton(if (de) "Laden" else "Load", Modifier.weight(2f), size = 15.sp, onClick = it) }
            }
        }
    }
}
