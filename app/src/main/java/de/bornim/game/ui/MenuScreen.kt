package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import de.bornim.core.art.MapFigure
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.aspectRatio
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
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.background
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Ability
import de.bornim.core.Perks
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

private enum class Tab { HERO, BAG, GEAR, MAP, SYSTEM, TEST }

/** The previews: the menu opens on the map (Vorrat 8, draft). */
object MenuStart { @Volatile var map = false }

/** 60: the menu in the look of the text box (black, gold rim, serif); a draft until chosen (preview `MENUE=1`). */
object MenuLook {
    @Volatile var draft = true
}

@Composable
fun MenuScreen(vm: GameViewModel, game: Game) {
    if (MenuLook.draft) androidx.compose.runtime.CompositionLocalProvider(LocalVeil provides true) {
        Box(Modifier.fillMaxSize().background(Color.Black)) { MenuBody(vm, game) }
    } else MenuBody(vm, game)
}

@Composable
private fun MenuBody(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    var tab by remember { mutableStateOf(if (MenuStart.map && de.bornim.core.art.MapSheet.draft) Tab.MAP else Tab.HERO) }
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    val back = { if (dialog != null) dialog = null else vm.menuOpen = false }
    BackHandler { back() }
    val ask: (DialogSpec) -> Unit = { dialog = it }
    // 24.12: the game waits while the menu is open, so new gear is drawn for the map at once and at full speed
    val hero = game.hero
    val worn = de.bornim.core.GearSlot.entries.joinToString(",") { sl -> hero.item(sl)?.let { "${it.base}:${it.rarity}" } ?: "-" }
    LaunchedEffect(worn) { MapFigure.prepare(hero, MapFigure.yawOf(game.state.place.facing)) }
    DisposableEffect(Unit) {
        MapFigure.urgent = true
        onDispose { if (!VeilMemory.active) MapFigure.urgent = false }
    }

    Box(Modifier.fillMaxSize()) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(10.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            val labels = mapOf(Tab.HERO to Ui.hero, Tab.BAG to Ui.bag, Tab.GEAR to Ui.gearShort, Tab.MAP to de.bornim.core.T("Karte", "Map"), Tab.SYSTEM to Ui.system, Tab.TEST to de.bornim.core.T("Test", "Test"))
            val tabs = Tab.entries.filter { (it != Tab.TEST || vm.testMode) && (it != Tab.MAP || de.bornim.core.art.MapSheet.draft) }
            tabs.forEach { t ->
                val badge = if (t == Tab.HERO && game.hero.unspentPoints > 0) " ★" else ""
                // 60j (draft): a drawn sign with a small word under it
                if (TabLook.draft && MenuLook.draft) TabButton(TabSign.valueOf(t.name), labels.getValue(t)(lang), Modifier.weight(1f), selected = t == tab, badge = badge.isNotEmpty()) { tab = t }
                else PixelButton(labels.getValue(t)(lang) + badge, Modifier.weight(1f), selected = t == tab, size = if (tabs.size > 4) 11.sp else 13.sp) { tab = t }
            }
        }
        Spacer(Modifier.height(8.dp))
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            // 62c: the map zooms and pans by itself, so it does not sit in the scrolling column
            if (tab == Tab.MAP) MapTab(game, lang)
            else Column(Modifier.verticalScroll(rememberScrollState())) {
                when (tab) {
                    Tab.HERO -> HeroTab(vm, game, lang, ask)
                    Tab.BAG -> BagTab(vm, game, lang, ask)
                    Tab.GEAR -> GearTab(vm, game, lang, ask)
                    Tab.MAP -> {}
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

/**
 * 62 the drawn map of the place, only what the hero has seen. 62c: it opens zoomed in on the hero (a red ring with
 * the way he faces), two fingers zoom, one pans; "Places" lists the places visited so far, tapping one shows its map
 * (no travel). Marks remind, never lead ([de.bornim.core.MapMarks]): tapping one names it.
 */
@Composable
private fun MapTab(game: Game, lang: Lang) {
    val german = lang == Lang.DE
    var shown by remember { mutableStateOf(game.map.id) }
    var overview by remember { mutableStateOf(MapLook.previewOverview) }
    val map = de.bornim.core.World[shown]
    val here = shown == game.map.id
    Column(Modifier.fillMaxSize()) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Txt(if (overview) (if (german) "Besuchte Orte" else "Places visited") else map.name(lang), Modifier.weight(1f), size = 20.sp, bold = true)
            PixelButton(if (german) "Orte" else "Places", Modifier.height(36.dp), selected = overview, size = 13.sp) { overview = !overview }
        }
        Spacer(Modifier.height(6.dp))
        if (overview) PlaceList(game, lang) { shown = it; overview = false }
        else androidx.compose.runtime.key(shown) { MapView(game, lang, map, here) }
    }
}

/** 62c: preview switches. */
object MapLook {
    @Volatile var previewOverview = false
    /** A mark to show named at once, by index in the marks of the shown map (-1 none, -2 the last). */
    @Volatile var previewTip = -1
    @Volatile var previewZoom = 2.5f
}

/** The places the hero has been to, each a small picture of its map; tapping one shows it. */
@Composable
private fun PlaceList(game: Game, lang: Lang, onPick: (String) -> Unit) {
    val s = game.state
    val outdoor = de.bornim.core.World.maps.values.filter { it.kind != de.bornim.core.MapKind.INTERIOR && de.bornim.core.MapMarks.visited(s, it) }
    val places = (if (game.map.kind == de.bornim.core.MapKind.INTERIOR) listOf(game.map) else emptyList()) + outdoor
    Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        places.forEach { m ->
            val img = remember(m.id) { de.bornim.core.art.MapSheet.render(m, { x, y -> seenOn(game, m, x, y) }) }
            Row(Modifier.fillMaxWidth().tap { onPick(m.id) }, verticalAlignment = Alignment.CenterVertically) {
                androidx.compose.foundation.Image(
                    bitmap = Bitmaps.of(img), contentDescription = null,
                    filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
                    modifier = Modifier.height(84.dp).aspectRatio(img.width.toFloat() / img.height),
                )
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Txt(m.name(lang), size = 17.sp, bold = true)
                    if (m.id == game.map.id) Txt(if (lang == Lang.DE) "Hier bist du" else "You are here", size = 13.sp, color = Veil.dim)
                }
            }
        }
    }
}

private fun seenOn(game: Game, m: de.bornim.core.MapDef, x: Int, y: Int): Boolean =
    if (m.id == game.map.id) game.fog(x, y) != de.bornim.core.Fog.HIDDEN else de.bornim.core.MapMarks.seen(game.state, m, x, y)

@Composable
private fun MapView(game: Game, lang: Lang, map: de.bornim.core.MapDef, here: Boolean) {
    val p = game.state.place
    val img = remember(map.id, p.x, p.y) { de.bornim.core.art.MapSheet.render(map, { x, y -> seenOn(game, map, x, y) }) }
    val bmp = Bitmaps.of(img)
    val marks = remember(map.id) { de.bornim.core.MapMarks.of(game.state).filter { it.map == map.id } }
    var tip by remember { mutableStateOf(marks.getOrNull(if (MapLook.previewTip == -2) marks.lastIndex else MapLook.previewTip)) }
    androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxSize().clipToBounds()) {
        val vw = constraints.maxWidth.toFloat(); val vh = constraints.maxHeight.toFloat()
        val fit = minOf(vw / img.width, vh / img.height)
        val density = androidx.compose.ui.platform.LocalDensity.current.density
        // centre of a tile in the picture's pixels
        fun cx(tx: Int) = de.bornim.core.art.MapSheet.PAD + tx * de.bornim.core.art.MapSheet.C + de.bornim.core.art.MapSheet.C / 2f
        fun cy(ty: Int) = de.bornim.core.art.MapSheet.PAD + ty * de.bornim.core.art.MapSheet.C + de.bornim.core.art.MapSheet.C / 2f
        // opens zoomed in on the hero, at least so far that the map fills the frame
        var scale by remember { mutableStateOf(if (here) maxOf(fit * MapLook.previewZoom, maxOf(vw / img.width, vh / img.height)) else fit) }
        fun clampX(o: Float) = if (img.width * scale <= vw) (vw - img.width * scale) / 2 else o.coerceIn(vw - img.width * scale, 0f)
        fun clampY(o: Float) = if (img.height * scale <= vh) (vh - img.height * scale) / 2 else o.coerceIn(vh - img.height * scale, 0f)
        var ox by remember { mutableStateOf(clampX(if (here) vw / 2 - cx(p.x) * scale else 0f)) }
        var oy by remember { mutableStateOf(clampY(if (here) vh / 2 - cy(p.y) * scale else 0f)) }
        androidx.compose.foundation.Canvas(
            Modifier.fillMaxSize()
                .pointerInput(Unit) { detectTransformGestures { centroid, pan, zoom, _ ->
                    val ns = (scale * zoom).coerceIn(fit, fit * 6f)
                    val k = ns / scale
                    scale = ns
                    ox = clampX(centroid.x - (centroid.x - ox) * k + pan.x)
                    oy = clampY(centroid.y - (centroid.y - oy) * k + pan.y)
                } }
                .pointerInput(Unit) { detectTapGestures { at ->
                    tip = marks.minByOrNull { m -> kotlin.math.hypot(ox + cx(m.x) * scale - at.x, oy + cy(m.y) * scale - at.y) }
                        ?.takeIf { m -> kotlin.math.hypot(ox + cx(m.x) * scale - at.x, oy + cy(m.y) * scale - at.y) < 28 * density }
                } }
        ) {
            drawImage(bmp, dstOffset = androidx.compose.ui.unit.IntOffset(ox.toInt(), oy.toInt()),
                dstSize = androidx.compose.ui.unit.IntSize((img.width * scale).toInt(), (img.height * scale).toInt()),
                filterQuality = androidx.compose.ui.graphics.FilterQuality.None)
            val ink = Color(0xFF4A3622)
            for (m in marks) {
                val c = androidx.compose.ui.geometry.Offset(ox + cx(m.x) * scale, oy + cy(m.y) * scale)
                val a = if (m.done) 0.4f else 1f
                val r = 7 * density
                if (m.kind == de.bornim.core.MapMarks.Kind.GIVER) {
                    drawCircle(ink.copy(alpha = a), r + 2 * density, c)
                    drawCircle(Color(0xFF4F86C6).copy(alpha = a), r, c)
                } else if (m.kind == de.bornim.core.MapMarks.Kind.BOARD) {
                    // 62e: the notice board, a small sheet nailed up
                    val tl = androidx.compose.ui.geometry.Offset(c.x - r * 0.85f, c.y - r)
                    val sz = androidx.compose.ui.geometry.Size(r * 1.7f, r * 2f)
                    drawRect(Color(0xFFE8DCC0), tl, sz)
                    drawRect(ink, tl, sz, style = androidx.compose.ui.graphics.drawscope.Stroke(2 * density))
                    for (k in 1..3) drawLine(ink.copy(alpha = 0.6f), androidx.compose.ui.geometry.Offset(tl.x + r * 0.35f, tl.y + r * 0.5f * k),
                        androidx.compose.ui.geometry.Offset(tl.x + sz.width - r * 0.35f, tl.y + r * 0.5f * k), 1.2f * density)
                } else {
                    val path = androidx.compose.ui.graphics.Path().apply {
                        moveTo(c.x, c.y - r * 1.5f); lineTo(c.x + r * 1.1f, c.y); lineTo(c.x, c.y + r * 1.5f); lineTo(c.x - r * 1.1f, c.y); close()
                    }
                    drawPath(path, Color(0xFFD9BC82).copy(alpha = a))
                    drawPath(path, ink.copy(alpha = a), style = androidx.compose.ui.graphics.drawscope.Stroke(2 * density))
                }
            }
            if (here) {
                // the hero: a red ring, a dot, and a small wedge the way he faces
                val c = androidx.compose.ui.geometry.Offset(ox + cx(p.x) * scale, oy + cy(p.y) * scale)
                val red = Color(0xFFB0302A)
                val r = 11 * density
                drawCircle(Color(0x55B0302A), r * 1.6f, c)
                drawCircle(red, r, c, style = androidx.compose.ui.graphics.drawscope.Stroke(3 * density))
                drawCircle(red, r * 0.35f, c)
                val f = p.facing
                val tipAt = androidx.compose.ui.geometry.Offset(c.x + f.dx * r * 1.9f, c.y + f.dy * r * 1.9f)
                val side = androidx.compose.ui.geometry.Offset(-f.dy * r * 0.55f, f.dx * r * 0.55f)
                val base = androidx.compose.ui.geometry.Offset(c.x + f.dx * r * 1.15f, c.y + f.dy * r * 1.15f)
                drawPath(androidx.compose.ui.graphics.Path().apply {
                    moveTo(tipAt.x, tipAt.y); lineTo(base.x + side.x, base.y + side.y); lineTo(base.x - side.x, base.y - side.y); close()
                }, red)
            }
        }
        tip?.let { m ->
            Panel(Modifier.align(Alignment.BottomCenter).padding(8.dp)) {
                Txt(m.label(lang), size = 15.sp, color = if (m.kind == de.bornim.core.MapMarks.Kind.GIVER) Color(0xFF8DB4E2) else Veil.bright)
            }
        }
    }
}

@Composable
private fun HeroTab(vm: GameViewModel, game: Game, lang: Lang, ask: (DialogSpec) -> Unit) {
    vm.tick // redraw after every change
    val h = game.hero
    var pending by remember { mutableStateOf(mapOf<Ability, Int>()) }
    val planned = pending.values.sum()
    Row(verticalAlignment = Alignment.CenterVertically) {
        // the hero as the doll, slowly turning, with everything worn
        val worn = de.bornim.core.GearSlot.entries.joinToString(",") { sl -> h.item(sl)?.let { "${it.base}:${it.rarity}" } ?: "-" }
        HeroTurntable(h, worn + "/" + h.sex + h.build + h.skinTone + h.hairTone, 0.62.dp)
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
            if (lang == Lang.DE) "Höchststufe für Kapitel 1 erreicht. In diesem Kapitel gibt es keine weiteren EP; Kämpfe lohnen sich weiter für Beute und Ausrüstung."
            else "Highest level for chapter 1 reached. No further XP in this chapter; fights still pay in loot and gear.",
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
    Txt(
        if (de) "Tippe auf ein Attribut, um zu sehen, was es bringt." else "Tap an ability to see what it does.",
        size = 12.sp, color = Colors.textDim,
    )
    Ability.entries.forEach { a ->
        val add = pending[a] ?: 0
        Row(Modifier.fillMaxWidth().padding(vertical = 2.dp), verticalAlignment = Alignment.CenterVertically) {
            // Tapping the name explains what the ability does.
            Txt(a.full(lang), Modifier.weight(1f).tap {
                ask(DialogSpec(title = a.full(lang), confirm = "OK", cancel = "", onConfirm = {}) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Perks.describe(a, h, lang).forEachIndexed { i, line ->
                            Txt(line, size = if (i == 0) 15.sp else 14.sp, bold = i == 0)
                        }
                    }
                })
            }, size = if (h.unspentPoints > 0) 14.sp else 16.sp, maxLines = 1)
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
        SupplyPicture(def.id, 36.dp)
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
                title = def.name(lang), icon = def.icon, supply = def.id, titleColor = rarityColor(def.rarity),
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
                title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
                confirm = Ui.equip(lang), cancel = cancel, confirmEnabled = canWear,
                extra = buildList {
                    if (oneHanded && canWear) add((if (de) "Nebenhand" else "Off hand") to {
                        game.state.equipFromBag(g, offHand = true)
                        vm.toast = "${g.name(lang)}: ${Ui.equipped(lang)}"
                        vm.refresh()
                    })
                    add((if (de) "Wegwerfen" else "Discard") to {
                        fun discard() {
                            game.discard(g)
                            vm.toast = if (de) "${g.name(lang)} weggeworfen." else "${g.name(lang)} discarded."
                            vm.refresh()
                        }
                        if (!vm.confirmations) discard()
                        else ask(DialogSpec(
                            title = if (de) "Wirklich wegwerfen?" else "Really discard?", icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
                            confirm = if (de) "Wegwerfen" else "Discard", cancel = cancel, onConfirm = { discard() },
                        ) {
                            Txt("${g.name(lang)} (${g.rarity.title(lang)})", size = 16.sp, bold = true, color = rarityColor(g.rarity))
                            Txt(
                                if (de) "Der Gegenstand ist danach verloren. Beim Händler bekämst du dafür ${game.sellPrice(g)} Gold."
                                else "The item will be gone for good. A trader would pay you ${game.sellPrice(g)} gold for it.",
                                size = 15.sp,
                            )
                        })
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
                title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
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
    JobList(vm, game, lang)
    Spacer(Modifier.height(6.dp))
    // The exact installed version, e.g. for bug reports.
    Txt(
        "Version ${de.bornim.game.BuildConfig.VERSION_NAME} (Build ${de.bornim.game.BuildConfig.VERSION_CODE})",
        size = 13.sp, bold = true, color = Colors.textDim,
    )
    Spacer(Modifier.height(12.dp))
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        PixelButton(Ui.save(lang), Modifier.fillMaxWidth()) {
            vm.save()
            vm.toast = Ui.saved(lang)
        }
        PixelButton(Ui.language(lang), Modifier.fillMaxWidth()) { vm.toggleLang() }
        PixelButton((if (vm.musicOn) Ui.musicOn else Ui.musicOff)(lang), Modifier.fillMaxWidth()) { vm.toggleMusic() }
        PixelButton((if (vm.sfxOn) Ui.sfxOn else Ui.sfxOff)(lang), Modifier.fillMaxWidth()) { vm.toggleSfx() }
        Txt(if (lang == Lang.DE) "Blut bei Treffern" else "Blood on hits", size = 15.sp, bold = true)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            val names = if (lang == Lang.DE) listOf("Aus", "Dezent", "Deutlich") else listOf("Off", "Subtle", "More")
            names.forEachIndexed { i, label -> PixelButton(label, Modifier.weight(1f), selected = vm.bloodLevel == i, size = 15.sp) { vm.changeBlood(i) } }
        }
        Txt(if (lang == Lang.DE) "Kampftempo" else "Battle pace", size = 15.sp, bold = true)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            val names = if (lang == Lang.DE) listOf("Ruhig", "Normal", "Schnell") else listOf("Calm", "Normal", "Fast")
            names.forEachIndexed { i, label -> PixelButton(label, Modifier.weight(1f), selected = vm.battleTempo == i, size = 15.sp) { vm.changeTempo(i) } }
        }
        PixelButton(if (lang == Lang.DE) (if (vm.battleAuto) "Kampftext: weiter automatisch" else "Kampftext: weiter mit Antippen")
            else (if (vm.battleAuto) "Battle text: goes on by itself" else "Battle text: tap to go on"), Modifier.fillMaxWidth()) { vm.toggleBattleAuto() }
        PixelButton((if (vm.touchControls) Ui.controlsTouch else Ui.controlsClassic)(lang), Modifier.fillMaxWidth()) { vm.toggleControls() }
        if (vm.touchControls) Txt(Ui.touchHint(lang), size = 13.sp, color = Colors.textDim)
        PixelButton((if (vm.leftHanded) Ui.actionLeft else Ui.actionRight)(lang), Modifier.fillMaxWidth()) { vm.toggleLeftHanded() }
        PixelButton((if (vm.haptics) Ui.hapticsOn else Ui.hapticsOff)(lang), Modifier.fillMaxWidth()) { vm.toggleHaptics() }
        PixelButton((if (vm.confirmations) Ui.confirmOn else Ui.confirmOff)(lang), Modifier.fillMaxWidth()) { vm.toggleConfirmations() }
        Txt(Ui.confirmHint(lang), size = 13.sp, color = Colors.textDim)
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
