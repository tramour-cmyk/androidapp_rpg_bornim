package de.bornim.game.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Chronicle
import de.bornim.core.Game
import de.bornim.core.Items
import de.bornim.core.Jobs
import de.bornim.core.Lang
import de.bornim.core.MapMarks
import de.bornim.core.Story

/** 64 (draft): the chronicle as a tab of its own; preview switch. */
object ChronicleLook {
    @Volatile var draft = false
    /** Which part opens: false the tasks, true "so far". */
    @Volatile var previewSoFar = false
}

/**
 * 64 (draft): the chronicle, two parts. "Tasks": the main task on top in gold, then the odd jobs carried, each with
 * who gave it, what to do in a sentence, how far along from the bag, the reward and where to hand it in, and a way
 * to the giver's mark on the map (named, in the middle); done ones folded away at the bottom. "So far": the chronicler's entries, newest on top.
 */
@Composable
fun ChronicleTab(game: Game, lang: Lang, onMap: (String) -> Unit) {
    val de = lang == Lang.DE
    val s = game.state
    var soFar by remember { mutableStateOf(ChronicleLook.previewSoFar) }
    var showDone by remember { mutableStateOf(false) }
    androidx.compose.runtime.LaunchedEffect(Unit) { Chronicle.markRead(s) }
    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        PixelButton(if (de) "Aufträge" else "Tasks", Modifier.weight(1f).height(36.dp), selected = !soFar, size = 14.sp) { soFar = false }
        PixelButton(if (de) "Bisher geschehen" else "So far", Modifier.weight(1f).height(36.dp), selected = soFar, size = 14.sp) { soFar = true }
    }
    Spacer(Modifier.height(10.dp))
    if (soFar) {
        val name = game.hero.name
        for ((i, e) in Chronicle.sofar(s).withIndex()) {
            if (i > 0) Spacer(Modifier.height(12.dp))
            Txt(e.title(lang), size = 17.sp, bold = true, color = if (i == 0) Veil.bright else Veil.gold)
            Txt(e.text(lang).replace("{name}", name), size = 15.sp, color = if (i == 0) Veil.text else Veil.dim)
        }
        return
    }
    // the main task, in gold
    Column(Modifier.fillMaxWidth().border(1.dp, Veil.rim).padding(horizontal = 12.dp, vertical = 8.dp)) {
        Txt(if (de) "Hauptauftrag" else "Main task", size = 13.sp, color = Veil.gold)
        Txt(Story.objective(s)(lang), size = 16.sp, bold = true, color = Veil.bright)
    }
    val carried = Jobs.carried(s)
    if (carried.isNotEmpty()) {
        Spacer(Modifier.height(12.dp))
        Txt(if (de) "Nebenaufträge" else "Odd jobs", size = 15.sp, color = Veil.gold)
    }
    for (j in carried) {
        Spacer(Modifier.height(8.dp))
        val have = Jobs.progress(s, j)
        val ready = have >= j.count
        Column(Modifier.fillMaxWidth().border(1.dp, Veil.rim).padding(horizontal = 12.dp, vertical = 8.dp)) {
            Txt(j.title(lang), size = 16.sp, bold = true, color = Veil.text)
            Txt((if (de) "von " else "from ") + j.giverName(lang), size = 13.sp, color = Veil.dim)
            Txt(j.note(lang), size = 14.sp, color = Veil.text)
            val what = Items[j.item].name(lang)
            Txt(if (ready) (if (de) "Bereit zur Abgabe – bei ${j.giverName(lang)}" else "Ready to hand in – to ${j.giverName(lang)}")
                else "$have ${if (de) "von" else "of"} ${j.count} · $what", size = 14.sp, color = if (ready) Veil.good else Veil.gold)
            Txt((if (de) "Lohn: " else "Reward: ") + j.reward(lang), size = 13.sp, color = Veil.dim)
            // only where the map has a mark of the giver (someone the hero has met, or who waits with the reward)
            if (MapMarks.of(s).any { it.who == j.giver })
                PixelButton(if (de) "Auf der Karte" else "On the map", Modifier.height(32.dp), size = 13.sp) { onMap(j.giver) }
        }
    }
    val done = Jobs.all.filter { Jobs.isDone(s, it) }
    if (done.isNotEmpty()) {
        Spacer(Modifier.height(12.dp))
        PixelButton((if (de) "Erledigt (${done.size})" else "Done (${done.size})") + if (showDone) " ▴" else " ▾", Modifier.fillMaxWidth().height(32.dp), size = 13.sp) { showDone = !showDone }
        if (showDone) for (j in done) Txt("✓ " + j.title(lang) + " · " + j.giverName(lang), size = 14.sp, color = Veil.dim)
    }
}
