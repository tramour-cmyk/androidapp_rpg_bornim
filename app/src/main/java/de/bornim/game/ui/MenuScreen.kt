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
import androidx.compose.foundation.layout.size
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Ability
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.ItemDef
import de.bornim.core.ItemKind
import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.Affix
import de.bornim.core.Gear
import de.bornim.core.Rules
import de.bornim.core.Story
import de.bornim.core.Ui
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.game.GameViewModel
import de.bornim.game.Screen

private val gearBlue = Color(0xFF2A62C8)

private enum class Tab { HERO, BAG, GEAR, SYSTEM, TEST }

@Composable
fun MenuScreen(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    var tab by remember { mutableStateOf(Tab.HERO) }
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    val back = { if (dialog != null) dialog = null else vm.menuOpen = false }
    BackHandler { back() }
    val ask: (DialogSpec) -> Unit = { dialog = it }

    Box(Modifier.fillMaxSize()) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(10.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            val labels = mapOf(Tab.HERO to Ui.hero, Tab.BAG to Ui.bag, Tab.GEAR to Ui.gearShort, Tab.SYSTEM to Ui.system, Tab.TEST to de.bornim.core.T("Test", "Test"))
            val tabs = Tab.entries.filter { it != Tab.TEST || vm.testMode }
            tabs.forEach { t ->
                val badge = if (t == Tab.HERO && game.hero.unspentPoints > 0) " ★" else ""
                PixelButton(labels.getValue(t)(lang) + badge, Modifier.weight(1f), selected = t == tab, size = if (tabs.size > 4) 11.sp else 13.sp, marker = false) { tab = t }
            }
        }
        Spacer(Modifier.height(8.dp))
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                when (tab) {
                    Tab.HERO -> HeroTab(vm, game, lang, ask)
                    Tab.BAG -> BagTab(vm, game, lang, ask)
                    Tab.GEAR -> GearTab(vm, game, lang, ask)
                    Tab.SYSTEM -> SystemTab(vm, game, lang)
                    Tab.TEST -> TestTab(vm, game, lang)
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        BackRow(Ui.close(lang)) { back() }
    }
    dialog?.let { ConfirmDialog(it) { dialog = null } }
    }
}

@Composable
private fun HeroTab(vm: GameViewModel, game: Game, lang: Lang, ask: (DialogSpec) -> Unit) {
    vm.tick // redraw after every change
    val h = game.hero
    var pending by remember { mutableStateOf(mapOf<Ability, Int>()) }
    val planned = pending.values.sum()
    Row(verticalAlignment = Alignment.CenterVertically) {
        PixelImageView(CharacterArt.hero(h.race, h.cls, Facing.DOWN), 80.dp)
        Spacer(Modifier.width(10.dp))
        Column {
            Txt(h.name, size = 22.sp, bold = true)
            Txt("${h.race.title(lang)} · ${h.cls.title(lang)}", size = 15.sp)
            Txt("${Ui.level(lang)} ${h.level}   ${Ui.gold(lang)}: ${game.state.gold}", size = 15.sp, bold = true)
        }
    }
    Spacer(Modifier.height(8.dp))
    LabeledBar(Ui.hp(lang), h.hp, h.maxHp, hpColor(h.hp.toFloat() / h.maxHp))
    if (h.maxSp > 0) LabeledBar(Ui.sp(lang), h.sp, h.maxSp, Colors.sp)
    val next = Rules.xpToNext(h.level)
    val prev = Rules.xpForLevel[h.level]
    if (de.bornim.core.Story.capped(game.state)) {
        // At the chapter's level cap the XP keep counting for later.
        LabeledBar(Ui.xp(lang), 1, 1, Colors.xp, "${h.xp}")
        Txt(
            if (lang == Lang.DE) "Höchststufe für Kapitel 1 erreicht. Weitere EP werden ab Kapitel 2 angerechnet."
            else "Highest level for chapter 1 reached. Further XP count from chapter 2 on.",
            size = 13.sp, color = Colors.textDim,
        )
    } else if (next != null) LabeledBar(Ui.xp(lang), h.xp - prev, next - prev, Colors.xp, "${h.xp} / $next")
    Spacer(Modifier.height(8.dp))
    val weapon = h.weapon
    Txt("${Ui.ac(lang)} ${h.armorClass}   ${Ui.attack(lang)} ${Rules.signed(h.attackBonus)}   ${Ui.damage(lang)} ${h.weaponDamage.label(lang)}", size = 15.sp, bold = true)
    Txt("${Ui.proficiency(lang)} ${Rules.signed(h.proficiency)}" + (weapon?.let { " · ${it.name(lang)}" } ?: ""), size = 14.sp, color = Colors.textDim)
    if (h.cls.caster) Txt((if (lang == Lang.DE) "Zauberangriff " else "Spell attack ") + Rules.signed(h.spellAttack) + (if (lang == Lang.DE) "   Zauber-SG " else "   Spell DC ") + h.spellDc, size = 14.sp, color = Colors.textDim)

    Spacer(Modifier.height(10.dp))
    val de = lang == Lang.DE
    if (h.unspentPoints > 0) {
        Txt(Ui.points.f(lang, h.unspentPoints - planned), size = 15.sp, bold = true, color = Colors.accent)
    }
    Ability.entries.forEach { a ->
        val add = pending[a] ?: 0
        Row(Modifier.fillMaxWidth().padding(vertical = 2.dp), verticalAlignment = Alignment.CenterVertically) {
            Txt(a.full(lang), Modifier.weight(1f), size = if (h.unspentPoints > 0) 14.sp else 16.sp, maxLines = 1)
            val score = h.score(a) + add
            Txt(if (add > 0) "${h.score(a)}→$score" else "$score", Modifier.width(56.dp), size = 16.sp, bold = true,
                color = if (add > 0) Color(0xFF2E8B3E) else Colors.text)
            // Part of the score that comes from equipped gear, shown separately.
            val fromGear = h.gearBonus(a)
            // A star marks gear that would give more than the chapter allows.
            Txt(if (fromGear != 0) Rules.signed(fromGear) + (if (h.gearCapped(a)) "*" else "") else "", Modifier.width(30.dp), size = 14.sp, bold = true, color = gearBlue)
            Txt("(${Rules.signed(Rules.mod(score))})", Modifier.width(44.dp), size = 15.sp, color = Colors.textDim)
            if (h.unspentPoints > 0) {
                PixelButton("−", Modifier.width(44.dp).height(36.dp), enabled = add > 0) {
                    pending = (pending + (a to add - 1)).filterValues { it > 0 }
                }
                Spacer(Modifier.width(4.dp))
                PixelButton("+", Modifier.width(44.dp).height(36.dp), enabled = planned < h.unspentPoints && h.base.getValue(a) + add < Rules.MAX_SCORE) {
                    pending = pending + (a to add + 1)
                }
            }
        }
    }
    if (Ability.entries.any { h.gearBonus(it) != 0 }) {
        Txt(if (lang == Lang.DE) "Blau: Bonus durch Ausrüstung (im Wert enthalten)" else "Blue: bonus from gear (included in the score)", size = 12.sp, color = gearBlue)
        val cap = h.chapter
        Txt(
            if (lang == Lang.DE) "In Kapitel $cap gibt Ausrüstung insgesamt höchstens +$cap je Attribut, auf Angriff, Zauberangriff und RK sowie +${cap + 1} Schaden. * = Deine Ausrüstung könnte mehr."
            else "In chapter $cap, all gear together adds at most +$cap to each ability, attack, spell attack and AC, and +${cap + 1} damage. * = your gear could give more.",
            size = 12.sp, color = Colors.textDim,
        )
    }
    if (planned > 0) {
        Row(Modifier.padding(top = 6.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PixelButton(if (de) "Zurücksetzen" else "Reset", Modifier.weight(1f), size = 15.sp) { pending = emptyMap() }
            PixelButton(if (de) "Übernehmen" else "Apply", Modifier.weight(1f), size = 15.sp) {
                val chosen = pending
                ask(DialogSpec(
                    title = if (de) "Punkte verteilen?" else "Spend points?",
                    confirm = if (de) "Ja, verteilen" else "Yes, spend",
                    cancel = if (de) "Nein" else "No",
                    onConfirm = {
                        h.applyPoints(chosen)
                        pending = emptyMap()
                        vm.save()
                        vm.refresh()
                    },
                ) {
                    chosen.forEach { (a, n) ->
                        Txt("${a.full(lang)}: ${h.score(a)} → ${h.score(a) + n}", size = 17.sp, bold = true)
                    }
                    Spacer(Modifier.height(6.dp))
                    Txt(if (de) "Das kann nicht rückgängig gemacht werden." else "This can't be undone.", size = 14.sp, color = Colors.textDim)
                })
            }
        }
    }

    Spacer(Modifier.height(10.dp))
    Txt(Ui.skills(lang), size = 18.sp, bold = true)
    Txt(h.race.trait(lang), size = 14.sp, color = Colors.border)
    h.cls.skills().forEach { s ->
        val unlocked = h.has(s)
        val tag = if (!unlocked) "  (${Ui.fromLevel.f(lang, s.level)})" else if (s.passive) "  (${Ui.passive(lang)})" else ""
        Txt(s.title(lang) + tag, size = 15.sp, bold = true, color = if (unlocked) Colors.text else Colors.textDim)
        Txt(s.desc(lang), size = 13.sp, color = Colors.textDim)
    }
}

@Composable
private fun LabeledBar(label: String, value: Int, max: Int, color: Color, text: String = "$value / $max") {
    Row(Modifier.padding(vertical = 2.dp), verticalAlignment = Alignment.CenterVertically) {
        Txt(label, Modifier.width(36.dp), size = 14.sp, bold = true)
        Bar(value.toFloat() / maxOf(1, max), color, Modifier.weight(1f), 10.dp)
        Spacer(Modifier.width(8.dp))
        Txt(text, Modifier.width(96.dp), size = 14.sp)
    }
}

@Composable
private fun ItemRow(def: ItemDef, lang: Lang, count: Int?, onClick: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .padding(vertical = 3.dp)
            .tap(onClick),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PixelImageView(IconArt.get(def.icon), 36.dp)
        Spacer(Modifier.width(8.dp))
        Column(Modifier.weight(1f)) {
            Txt(def.name(lang), size = 16.sp, bold = true, color = rarityColor(def.rarity))
            val stats = def.stats(lang)
            if (stats.isNotEmpty()) Txt(stats, size = 13.sp, color = Colors.textDim)
        }
        if (count != null) Txt("×$count", size = 15.sp)
    }
}

@Composable
private fun BagTab(vm: GameViewModel, game: Game, lang: Lang, ask: (DialogSpec) -> Unit) {
    vm.tick // redraw after every change
    val de = lang == Lang.DE
    val cancel = if (de) "Abbrechen" else "Cancel"
    val items = game.state.inventory.entries.toList()
    Txt(if (de) "Vorräte" else "Supplies", size = 18.sp, bold = true)
    if (items.isEmpty()) Txt(Ui.nothing(lang), color = Colors.textDim)
    items.forEach { (id, count) ->
        val def = Items[id]
        ItemRow(def, lang, count) {
            val potion = def.kind == ItemKind.POTION || def.kind == ItemKind.FOOD
            ask(DialogSpec(
                title = def.name(lang), icon = def.icon, titleColor = rarityColor(def.rarity),
                confirm = if (def.kind == ItemKind.FOOD) (if (de) "Essen" else "Eat") else if (potion) Ui.use(lang) else "OK", cancel = cancel,
                onConfirm = {
                    if (potion) {
                        vm.toast = game.useItemOutside(id)
                        vm.refresh()
                    }
                },
            ) { ItemDetails(def, lang) })
        }
    }
    Spacer(Modifier.height(10.dp))
    val gear = game.state.bag.sortedWith(compareByDescending<Gear> { it.rarity }.thenBy { it.slot.ordinal }.thenByDescending { it.ilvl })
    Txt((if (de) "Ausrüstung" else "Equipment") + " (${gear.size})", size = 18.sp, bold = true)
    if (gear.isEmpty()) Txt(if (de) "Besiege Monster und öffne Truhen, um Ausrüstung zu finden." else "Defeat monsters and open chests to find equipment.", size = 14.sp, color = Colors.textDim)
    gear.forEach { g ->
        GearRow(g, lang, game, vm.tick) {
            val canWear = game.hero.canWear(g)
            val oneHanded = g.def.isWeapon && !g.def.twoHanded
            ask(DialogSpec(
                title = g.name(lang), icon = g.def.icon, titleColor = rarityColor(g.rarity),
                confirm = Ui.equip(lang), cancel = cancel, confirmEnabled = canWear,
                extra = buildList {
                    if (oneHanded && canWear) add((if (de) "Nebenhand" else "Off hand") to {
                        game.state.equipFromBag(g, offHand = true)
                        vm.toast = "${g.name(lang)}: ${Ui.equipped(lang)}"
                        vm.refresh()
                    })
                    add((if (de) "Wegwerfen" else "Discard") to {
                        game.discard(g)
                        vm.refresh()
                    })
                },
                onConfirm = {
                    if (game.state.equipFromBag(g)) vm.toast = "${g.name(lang)}: ${Ui.equipped(lang)}"
                    vm.refresh()
                },
            ) { GearDetails(g, game, lang) })
        }
    }
}

@Composable
private fun GearTab(vm: GameViewModel, game: Game, lang: Lang, ask: (DialogSpec) -> Unit) {
    vm.tick // redraw after every change
    val de = lang == Lang.DE
    val h = game.hero
    PaperDoll(game, lang, vm.tick) { slot ->
        val g = h.item(slot)
        if (g == null) {
            vm.toast = slot.title(lang) + ": " + Ui.empty(lang)
        } else {
            ask(DialogSpec(
                title = g.name(lang), icon = g.def.icon, titleColor = rarityColor(g.rarity),
                confirm = Ui.unequip(lang), cancel = if (de) "Schließen" else "Close",
                onConfirm = {
                    game.state.unequipToBag(slot)
                    vm.refresh()
                },
            ) { GearDetails(g, game, lang) })
        }
    }
    Spacer(Modifier.height(10.dp))
    Txt(if (de) "Kampfwerte" else "Combat stats", size = 18.sp, bold = true)
    @Composable
    fun stat(label: String, value: String) {
        Row(Modifier.fillMaxWidth().padding(vertical = 1.dp)) {
            Txt(label, Modifier.weight(1f), size = 15.sp)
            Txt(value, size = 15.sp, bold = true)
        }
    }
    stat(if (de) "Rüstungsklasse" else "Armor Class", "${h.armorClass}")
    stat(if (de) "Angriff" else "Attack", Rules.signed(h.attackBonus))
    stat(if (de) "Schaden" else "Damage", h.weaponDamage.label(lang))
    h.offHandWeapon?.let { stat(if (de) "Nebenhand" else "Off hand", "${Rules.signed(h.attackBonus(it))} · ${h.weaponDamage(it, true).label(lang)}") }
    stat(if (de) "Kritisch ab" else "Critical from", "${h.critFrom}")
    if (h.cls.caster) stat(if (de) "Zauberangriff / SG" else "Spell attack / DC", "${Rules.signed(h.spellAttack)} / ${h.spellDc}")
    if (h.lifeSteal > 0) stat(Affix.LIFESTEAL.title(lang), "${h.lifeSteal}%")
    if (h.damageReduction > 0) stat(Affix.RESIST.title(lang), "${h.damageReduction}")
    listOf(Affix.MAGIC_FIND, Affix.GOLD_FIND, Affix.XP).forEach { a ->
        val v = h.bonus(a)
        if (v > 0) stat(a.title(lang), "+$v%")
    }
}

@Composable
private fun SystemTab(vm: GameViewModel, game: Game, lang: Lang) {
    vm.tick // redraw after every change
    Txt(Ui.quest(lang), size = 18.sp, bold = true)
    Txt(Story.objective(game.state)(lang), size = 16.sp)
    Spacer(Modifier.height(16.dp))
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        PixelButton(Ui.save(lang), Modifier.fillMaxWidth()) {
            vm.save()
            vm.toast = Ui.saved(lang)
        }
        PixelButton(Ui.language(lang), Modifier.fillMaxWidth()) { vm.toggleLang() }
        PixelButton((if (vm.musicOn) Ui.musicOn else Ui.musicOff)(lang), Modifier.fillMaxWidth()) { vm.toggleMusic() }
        PixelButton((if (vm.sfxOn) Ui.sfxOn else Ui.sfxOff)(lang), Modifier.fillMaxWidth()) { vm.toggleSfx() }
        PixelButton((if (vm.touchControls) Ui.controlsTouch else Ui.controlsClassic)(lang), Modifier.fillMaxWidth()) { vm.toggleControls() }
        if (vm.touchControls) Txt(Ui.touchHint(lang), size = 13.sp, color = Colors.textDim)
        PixelButton((if (vm.leftHanded) Ui.actionLeft else Ui.actionRight)(lang), Modifier.fillMaxWidth()) { vm.toggleLeftHanded() }
        PixelButton((if (vm.haptics) Ui.hapticsOn else Ui.hapticsOff)(lang), Modifier.fillMaxWidth()) { vm.toggleHaptics() }
        PixelButton(Ui.about(lang), Modifier.fillMaxWidth()) {
            vm.toTitle()
            vm.screen = Screen.ABOUT
        }
        PixelButton(Ui.toTitle(lang), Modifier.fillMaxWidth()) { vm.toTitle() }
    }
    Spacer(Modifier.height(16.dp))
    val s = game.state
    Txt((if (lang == Lang.DE) "Schritte: " else "Steps: ") + s.steps + (if (lang == Lang.DE) " · Siege: " else " · Victories: ") + s.battlesWon, size = 13.sp, color = Colors.textDim)
    Box(Modifier.size(1.dp))
}
