package de.bornim.game.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Icon
import de.bornim.core.ItemDef
import de.bornim.core.Lang
import de.bornim.core.art.IconArt

/** A question with a confirm and a cancel button (plus optional extra actions), shown on top of the current screen. */
class DialogSpec(
    val title: String,
    val confirm: String,
    val cancel: String,
    val confirmEnabled: Boolean = true,
    val icon: Icon? = null,
    /** A piece of gear to show instead of [icon], as it looks when worn. */
    val gear: de.bornim.core.Gear? = null,
    val titleColor: Color? = null,
    /** Further buttons, e.g. "Off hand" or "Discard". */
    val extra: List<Pair<String, () -> Unit>> = emptyList(),
    val onConfirm: () -> Unit,
    val body: @Composable () -> Unit,
)

@Composable
fun ConfirmDialog(spec: DialogSpec, onDismiss: () -> Unit) {
    Box(
        Modifier
            .fillMaxSize()
            .background(Color(0xB0000000))
            .tap(onDismiss),
        contentAlignment = Alignment.Center,
    ) {
        Panel(
            Modifier
                .padding(16.dp)
                .fillMaxWidth()
                .tap {} // keep taps inside the box from closing it
        ) {
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (spec.gear != null) {
                        GearPicture(spec.gear.base, spec.gear.rarity, 48.dp)
                        Spacer(Modifier.width(10.dp))
                    } else spec.icon?.let {
                        PixelImageView(IconArt.get(it), 48.dp)
                        Spacer(Modifier.width(10.dp))
                    }
                    Txt(spec.title, size = 20.sp, bold = true, color = spec.titleColor ?: Colors.text)
                }
                Spacer(Modifier.height(8.dp))
                Column(
                    Modifier
                        .heightIn(max = 520.dp)
                        .verticalScroll(rememberScrollState())
                ) { spec.body() }
                Spacer(Modifier.height(12.dp))
                if (spec.extra.isNotEmpty()) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        spec.extra.forEach { (label, action) ->
                            // Close first, so the action may open a follow-up dialog (e.g. a safety question).
                            PixelButton(label, Modifier.weight(1f), size = 15.sp) {
                                onDismiss()
                                action()
                            }
                        }
                    }
                    Spacer(Modifier.height(8.dp))
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    // Information dialogs have no cancel button, only "OK".
                    if (spec.cancel.isNotEmpty()) PixelButton(spec.cancel, Modifier.weight(1f), size = 15.sp, onClick = onDismiss)
                    PixelButton(spec.confirm, Modifier.weight(1f), enabled = spec.confirmEnabled, size = 15.sp) {
                        onDismiss()
                        spec.onConfirm()
                    }
                }
            }
        }
    }
}

/** Description of a potion, bomb or story item. */
@Composable
fun ItemDetails(def: ItemDef, lang: Lang) {
    Txt(def.rarity.title(lang), size = 14.sp, color = rarityColor(def.rarity))
    val stats = def.stats(lang)
    if (stats.isNotEmpty()) Txt(stats, size = 16.sp, bold = true)
    Spacer(Modifier.height(4.dp))
    Txt(def.desc(lang), size = 16.sp)
}
