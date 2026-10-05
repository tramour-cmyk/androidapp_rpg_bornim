package de.bornim.game.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.EliteTrait
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.Gender
import de.bornim.core.Lang
import de.bornim.core.Monsters
import de.bornim.core.Place
import de.bornim.core.Rarity
import de.bornim.game.GameViewModel

/** Cheats for testing, only visible in test mode (tap the copyright on the title screen 7 times). */
@Composable
fun TestTab(vm: GameViewModel, game: Game, lang: Lang) {
    vm.tick // redraw after every change
    val german = lang == Lang.DE
    fun t(d: String, e: String) = if (german) d else e
    val h = game.hero
    // 0 = normal, 1..6 = elite trait, 7 = shimmering
    var variant by remember { mutableIntStateOf(0) }
    var showMonsters by remember { mutableStateOf(false) }

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Txt(t("Testmodus", "Test mode"), size = 18.sp, bold = true)

        Txt(t("Stufe", "Level") + ": ${h.level}   ·   " + t("Gold", "Gold") + ": ${game.state.gold}", size = 16.sp)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            for (d in listOf(-5, -1, 1, 5)) {
                PixelButton(if (d > 0) "+$d" else "$d", Modifier.weight(1f), size = 15.sp, marker = false) {
                    game.cheatLevel(h.level + d)
                    vm.refresh()
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            PixelButton("+1000 " + t("Gold", "gold"), Modifier.weight(1f), size = 14.sp, marker = false) {
                game.cheatGold(1000)
                vm.refresh()
            }
            PixelButton(t("Heilen", "Heal"), Modifier.weight(1f), size = 14.sp, marker = false) {
                game.cheatHeal()
                vm.refresh()
            }
        }
        PixelButton(t("Bosse zurücksetzen (Krogg, Grak)", "Respawn bosses (Krogg, Grak)"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatRespawnBosses()
            vm.refresh()
            vm.toast = t("Krogg und Grak sind zurück in der Höhle.", "Krogg and Grak are back in the cave.")
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Teleport", "Teleport"), size = 16.sp, bold = true)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            val places = listOf(
                t("Dorf", "Village") to Place("village", 11, 7, Facing.DOWN),
                t("Wald", "Forest") to Place("forest", 10, 20, Facing.UP),
                t("Höhle", "Cave") to Place("cave", 10, 18, Facing.UP),
            )
            for ((label, place) in places) {
                PixelButton(label, Modifier.weight(1f), size = 14.sp, marker = false) {
                    game.cheatWarp(place)
                    vm.menuOpen = false
                    vm.refresh()
                }
            }
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Kampf auslösen", "Start a fight"), size = 16.sp, bold = true)
        val variantLabel = when (variant) {
            0 -> t("Normal", "Normal")
            7 -> t("Schimmernd", "Shimmering")
            else -> "Elite: " + EliteTrait.entries[variant - 1].adjective(lang, Gender.M)
        }
        PixelButton(t("Variante", "Variant") + ": $variantLabel  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            variant = (variant + 1) % 8
        }
        PixelButton(if (showMonsters) t("Monsterliste schließen", "Hide monsters") else t("Monster wählen …", "Choose monster..."), Modifier.fillMaxWidth(), size = 14.sp) {
            showMonsters = !showMonsters
        }
        if (showMonsters) {
            Monsters.all.chunked(2).forEach { pair ->
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    pair.forEach { m ->
                        PixelButton(m.name(lang) + if (m.boss) " ★" else "", Modifier.weight(1f), size = 13.sp, marker = false) {
                            val trait = if (variant in 1..6 && !m.boss) EliteTrait.entries[variant - 1] else null
                            vm.menuOpen = false
                            game.cheatFight(m.id, trait, variant == 7 && !m.boss)
                            vm.refresh()
                        }
                    }
                    if (pair.size == 1) Spacer(Modifier.weight(1f))
                }
            }
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Beute erzeugen", "Create loot"), size = 16.sp, bold = true)
        Rarity.entries.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                row.forEach { r ->
                    PixelButton(r.title(lang), Modifier.weight(1f), size = 12.sp, marker = false) {
                        val g = game.cheatLoot(r)
                        vm.refresh()
                        vm.toast = t("Erhalten: ", "Received: ") + g.name(lang)
                    }
                }
            }
        }
    }
}
