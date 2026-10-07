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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import de.bornim.game.Look
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
    var sex by remember { mutableStateOf(de.bornim.core.Sex.MALE) }
    var build by remember { mutableStateOf(de.bornim.core.Build.AVERAGE) }
    var skin by remember { mutableStateOf(1) }
    var hair by remember { mutableStateOf(0) }
    val time = rememberTime()
    // With all save slots taken, the player picks the hero to replace.
    var chooseSlot by remember { mutableStateOf(false) }
    BackHandler {
        when {
            chooseSlot -> chooseSlot = false
            else -> vm.screen = if (vm.pendingSlot != null) Screen.SLOTS else Screen.TITLE
        }
    }

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
                    val preview = Hero.create(name.ifBlank { "?" }, race, cls, bought).also { it.sex = sex; it.build = build; it.skin = skin; it.hair = hair }
                    HeroTurntable(preview, "$race/$cls/$sex/$build/$skin/$hair", 0.75.dp, fill = false)
                    Spacer(Modifier.width(12.dp))
                    HeroSummary(preview, lang)
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

            // how the hero looks: body form, build, and the skin and hair tones of the chosen people
            Txt(if (lang == Lang.DE) "Aussehen" else "Appearance", color = Colors.textLight, bold = true)
            Choices(de.bornim.core.Sex.entries, sex, { it.title(lang) }) { sex = it }
            Choices(de.bornim.core.Build.entries, build, { it.title(lang) }) { build = it }
            ToneChoices(if (lang == Lang.DE) "Haut" else "Skin", de.bornim.core.Appearance.skins(race), skin, lang) { skin = it }
            ToneChoices(if (lang == Lang.DE) "Haar" else "Hair", de.bornim.core.Appearance.hairs(race), hair, lang) { hair = it }

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
                // A free (or chosen empty) slot starts right away; with all slots taken, pick one to replace.
                if (vm.pendingSlot != null || vm.freeSlot != null) vm.newGame(name.trim(), race, cls, bought, look = Look(sex, build, skin, hair))
                else chooseSlot = true
            }
        }
    }
    if (chooseSlot) SlotChooser(vm, lang, onCancel = { chooseSlot = false }) { n ->
        chooseSlot = false
        vm.newGame(name.trim(), race, cls, bought, into = n, look = Look(sex, build, skin, hair))
    }
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

/** A row of colour swatches with their names, one picked. */
@Composable
private fun ToneChoices(label: String, tones: List<de.bornim.core.Appearance.Tone>, selected: Int, lang: Lang, onPick: (Int) -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        Txt(label, Modifier.width(52.dp), size = 14.sp, color = Colors.textLight)
        tones.forEachIndexed { i, t ->
            Column(Modifier.weight(1f).tap { onPick(i) }, horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    Modifier
                        .size(34.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .border(if (i == selected) 3.dp else 1.dp, if (i == selected) Colors.accent else Colors.border, RoundedCornerShape(6.dp))
                        .background(androidx.compose.ui.graphics.Color(0xFF000000 or t.rgb.toLong()))
                )
                Txt(t.title(lang), size = 11.sp, color = if (i == selected) Colors.accent else Colors.textDim, maxLines = 1)
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

/** All slots are taken: pick the hero the new one replaces (that hero is lost). */
@Composable
private fun SlotChooser(vm: GameViewModel, lang: Lang, onCancel: () -> Unit, onPick: (Int) -> Unit) {
    val de = lang == Lang.DE
    Box(
        Modifier
            .fillMaxSize()
            .background(androidx.compose.ui.graphics.Color(0xD0000000))
            .tap(onCancel),
        contentAlignment = Alignment.Center,
    ) {
        Panel(Modifier.padding(16.dp).fillMaxWidth().tap {}) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Txt(if (de) "Alle Spielstand-Plätze sind belegt" else "All save slots are taken", size = 19.sp, bold = true)
                Txt(
                    if (de) "Welchen Helden soll der neue ersetzen? Der gewählte Spielstand geht dabei verloren."
                    else "Which hero should the new one replace? That saved game will be lost.",
                    size = 14.sp, color = Colors.accent,
                )
                vm.slots().filterNotNull().forEach { info ->
                    Panel(Modifier.fillMaxWidth().tap { onPick(info.slot) }) { SlotCard(info, lang) }
                }
                PixelButton(if (de) "Abbrechen" else "Cancel", Modifier.fillMaxWidth(), size = 15.sp, onClick = onCancel)
            }
        }
    }
}
