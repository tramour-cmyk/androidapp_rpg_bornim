package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Ability
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Hero
import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.Race
import de.bornim.core.Rules
import de.bornim.core.Ui
import de.bornim.core.art.CharacterArt
import de.bornim.game.GameViewModel
import de.bornim.game.Screen

@Composable
fun CreateScreen(vm: GameViewModel) {
    val lang = vm.lang
    var name by remember { mutableStateOf(Ui.defaultName(lang)) }
    var race by remember { mutableStateOf(Race.HUMAN) }
    var cls by remember { mutableStateOf(CharClass.FIGHTER) }
    // Point buy before the race bonus; a new class starts from its suggestion.
    var bought by remember { mutableStateOf(Hero.suggestedScores(CharClass.FIGHTER)) }
    val time = rememberTime()
    // Starting over replaces the saved game, so that always needs a yes.
    var overwrite by remember { mutableStateOf<DialogSpec?>(null) }
    BackHandler { if (overwrite != null) overwrite = null else vm.screen = Screen.TITLE }

    Box(Modifier.fillMaxSize()) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(12.dp)
    ) {
        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            // Preview
            Panel(Modifier.fillMaxWidth()) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    val facing = Facing.entries[((time / 900) % 4).toInt()]
                    val step = ((time / 220) % 4).toInt().let { if (it == 1) 1 else if (it == 3) 2 else 0 }
                    PixelImageView(CharacterArt.hero(race, cls, facing, step), 96.dp)
                    Spacer(Modifier.width(12.dp))
                    HeroSummary(Hero.create(name.ifBlank { "?" }, race, cls, bought), lang)
                }
            }

            Txt(Ui.yourName(lang), color = Colors.textLight, bold = true)
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .border(3.dp, Colors.border, RoundedCornerShape(8.dp))
                    .background(Colors.panel)
                    .padding(12.dp)
            ) {
                BasicTextField(
                    value = name,
                    onValueChange = { name = it.take(12) },
                    singleLine = true,
                    textStyle = BaseText.copy(fontSize = 28.sp),
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Done),
                    modifier = Modifier.fillMaxWidth(),
                )
            }

            Txt(Ui.chooseRace(lang), color = Colors.textLight, bold = true)
            Choices(Race.entries, race, { it.title(lang) }) { race = it }
            Panel(Modifier.fillMaxWidth()) {
                Column {
                    Txt(race.desc(lang), size = 15.sp)
                    Spacer(Modifier.height(4.dp))
                    val bonus = race.bonus.entries.joinToString("  ") { "${it.key.short(lang)} ${Rules.signed(it.value)}" }
                    Txt(bonus, size = 15.sp, bold = true)
                    Txt(race.trait(lang), size = 15.sp, color = Colors.border)
                }
            }

            Txt(Ui.chooseClass(lang), color = Colors.textLight, bold = true)
            Choices(CharClass.entries, cls, { it.title(lang) }) {
                cls = it
                bought = Hero.suggestedScores(it)
            }
            Panel(Modifier.fillMaxWidth()) {
                Column {
                    Txt(cls.desc(lang), size = 15.sp)
                    Spacer(Modifier.height(4.dp))
                    Txt("${Ui.hitDie(lang)}: ${if (lang == Lang.DE) "W" else "d"}${cls.hitDie} · ${Ui.primary(lang)}: ${cls.primary.full(lang)}", size = 15.sp, bold = true)
                    val armor = if (cls.armor.isEmpty()) "—" else cls.armor.joinToString(", ") { it.title(lang) }
                    Txt("${Ui.armorProf(lang)}: $armor${if (cls.shields) " + " + de.bornim.core.GearBases["shield"].name(lang) else ""}", size = 15.sp)
                    Spacer(Modifier.height(6.dp))
                    cls.skills().filter { it.level == 1 }.forEach {
                        Txt("• ${it.title(lang)}", size = 15.sp, bold = true)
                        Txt(it.desc(lang), size = 14.sp, color = Colors.textDim)
                    }
                }
            }

            PointBuy(bought, race, cls, lang) { bought = it }
        }
        Spacer(Modifier.height(10.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            PixelButton(Ui.back(lang), Modifier.weight(1f)) { vm.screen = Screen.TITLE }
            PixelButton(Ui.start(lang), Modifier.weight(2f)) {
                if (!vm.hasSave) vm.newGame(name.trim(), race, cls, bought)
                else {
                    val de = lang == Lang.DE
                    overwrite = DialogSpec(
                        title = if (de) "Spielstand überschreiben?" else "Overwrite saved game?",
                        confirm = if (de) "Neu beginnen" else "Start over", cancel = if (de) "Abbrechen" else "Cancel",
                        onConfirm = { vm.newGame(name.trim(), race, cls, bought) },
                    ) {
                        Txt(
                            if (de) "Es gibt bereits einen gespeicherten Helden. Ein neues Spiel ersetzt ihn – der alte Spielstand ist danach verloren."
                            else "There is already a saved hero. A new game replaces it – the old save will be lost.",
                            size = 15.sp,
                        )
                    }
                }
            }
        }
    }
    overwrite?.let { ConfirmDialog(it) { overwrite = null } }
    }
}

/** Distributes the point-buy budget; values shown include the race bonus. */
@Composable
private fun PointBuy(bought: Map<Ability, Int>, race: Race, cls: CharClass, lang: Lang, onChange: (Map<Ability, Int>) -> Unit) {
    val de = lang == Lang.DE
    val left = Rules.POINT_BUY - Rules.pointsSpent(bought)
    Row(verticalAlignment = Alignment.CenterVertically) {
        Txt(if (de) "Attribute verteilen" else "Assign abilities", Modifier.weight(1f), color = Colors.textLight, bold = true)
        PixelButton(if (de) "Vorschlag" else "Suggest", Modifier.height(36.dp), size = 13.sp) { onChange(Hero.suggestedScores(cls)) }
    }
    Panel(Modifier.fillMaxWidth()) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Txt(
                (if (de) "Punkte übrig: " else "Points left: ") + "$left / ${Rules.POINT_BUY}",
                size = 15.sp, bold = true, color = if (left > 0) Colors.accent else Colors.text,
            )
            Txt(
                if (de) "Werte 8–15 vor Volksbonus. Höhere Werte kosten mehr (14: 7 Punkte, 15: 9 Punkte)."
                else "Scores 8–15 before race bonus. High scores cost more (14: 7 points, 15: 9 points).",
                size = 12.sp, color = Colors.textDim,
            )
            Ability.entries.forEach { a ->
                val v = bought.getValue(a)
                val bonus = race.bonus[a] ?: 0
                val up = v < Rules.POINT_BUY_MAX && Rules.pointCost(v + 1) - Rules.pointCost(v) <= left
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Txt(a.full(lang) + if (a == cls.primary) " ★" else "", Modifier.weight(1f), size = 14.sp, maxLines = 1)
                    Txt("${v + bonus}", Modifier.width(30.dp), size = 16.sp, bold = true)
                    Txt(if (bonus > 0) "+$bonus" else "", Modifier.width(30.dp), size = 12.sp, color = Colors.border)
                    Txt("(${Rules.signed(Rules.mod(v + bonus))})", Modifier.width(40.dp), size = 13.sp, color = Colors.textDim)
                    PixelButton("−", Modifier.width(44.dp).height(36.dp), enabled = v > Rules.POINT_BUY_MIN) { onChange(bought + (a to v - 1)) }
                    Spacer(Modifier.width(6.dp))
                    PixelButton("+", Modifier.width(44.dp).height(36.dp), enabled = up) { onChange(bought + (a to v + 1)) }
                }
            }
        }
    }
}

@Composable
private fun <E> Choices(items: List<E>, selected: E, label: (E) -> String, onPick: (E) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        items.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                row.forEach { item ->
                    PixelButton(label(item), Modifier.weight(1f), selected = item == selected, size = 15.sp) { onPick(item) }
                }
                repeat(3 - row.size) { Spacer(Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
fun HeroSummary(hero: Hero, lang: Lang) {
    Column {
        Txt(hero.name, size = 20.sp, bold = true)
        Txt("${hero.race.title(lang)} · ${hero.cls.title(lang)} · ${Ui.level(lang)} ${hero.level}", size = 14.sp)
        Txt("${Ui.hp(lang)} ${hero.maxHp}   ${Ui.ac(lang)} ${hero.armorClass}" + if (hero.maxSp > 0) "   ${Ui.sp(lang)} ${hero.maxSp}" else "", size = 15.sp, bold = true)
        Spacer(Modifier.height(4.dp))
        Ability.entries.chunked(2).forEach { row ->
            Row {
                row.forEach { a ->
                    Txt("${a.short(lang)} ${hero.score(a)} (${Rules.signed(hero.mod(a))})", Modifier.width(104.dp), size = 13.sp, maxLines = 1)
                }
            }
        }
    }
}
