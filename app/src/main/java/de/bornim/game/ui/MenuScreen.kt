package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import de.bornim.core.art.MapFigure
import de.bornim.core.art.SupplyArt
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
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.background
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Text
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.drawText
import de.bornim.core.Ability
import de.bornim.core.Perks
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.ItemDef
import de.bornim.core.ItemKind
import de.bornim.core.Items
import de.bornim.core.Light
import de.bornim.core.Lang
import de.bornim.core.Affix
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Rules
import de.bornim.core.Story
import de.bornim.core.Ui
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.game.GameViewModel
import de.bornim.game.Screen

private val gearBlue = Color(0xFF2A62C8)

private enum class Tab { HERO, BAG, GEAR, MAP, CHRONICLE, SYSTEM, TEST }

/** The previews: the menu opens on the map (Vorrat 8, draft). */
object MenuStart { @Volatile var map = false; @Volatile var chronicle = false }

@Composable
fun MenuScreen(vm: GameViewModel, game: Game) {
    // 60: the menu in the look of the text box (black, gold rim, serif)
    androidx.compose.runtime.CompositionLocalProvider(LocalVeil provides true) {
        Box(Modifier.fillMaxSize().background(Color.Black)) { MenuBody(vm, game) }
    }
}

@Composable
private fun MenuBody(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    var tab by remember { mutableStateOf(if (MenuStart.chronicle) Tab.CHRONICLE else if (MenuStart.map || vm.mapDirect) Tab.MAP else Tab.HERO) }
    // 86.2: opened by the map sign, it is only the map until another tab is chosen
    DisposableEffect(Unit) { onDispose { vm.mapDirect = false } }
    // 326 ([326.hinweis], STORY-MENUE.md): once, on the first opening, that a long press on a sign explains it
    LaunchedEffect(Unit) {
        if (!vm.signHintSeen) {
            vm.toast = if (lang == Lang.DE) "Halte ein Zeichen gedrückt, und es erklärt sich." else "Press and hold a sign to see what it does."
            vm.sawSignHint()
        }
    }
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    val back = { if (dialog != null) dialog = null else if (MenuExplain.shown != null) MenuExplain.shown = null else vm.menuOpen = false }
    DisposableEffect(Unit) { onDispose { MenuExplain.shown = null } }
    BackHandler { back() }
    val ask: (DialogSpec) -> Unit = { dialog = it }
    // 24.12: the game waits while the menu is open, so new gear is drawn for the map at once and at full speed
    val hero = game.hero
    val worn = de.bornim.core.GearSlot.entries.joinToString(",") { sl -> hero.item(sl)?.let { "${it.base}:${it.rarity}" } ?: "-" }
    LaunchedEffect(worn) { MapFigure.out = !game.torchBurns; MapFigure.prepare(hero, MapFigure.yawOf(game.state.place.facing)) }
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
        val labels = mapOf(Tab.HERO to Ui.hero, Tab.BAG to Ui.bag, Tab.GEAR to Ui.equipment, Tab.MAP to de.bornim.core.T("Karte", "Map"), Tab.CHRONICLE to de.bornim.core.T("Chronik", "Chronicle"), Tab.SYSTEM to Ui.system, Tab.TEST to de.bornim.core.T("Test", "Test"))
        // 326: the name of the chosen tab large above the signs, in the spaced gold capitals of the main menu's title
        Text(labels.getValue(tab)(lang).uppercase(), Modifier.fillMaxWidth().padding(top = 2.dp, bottom = 8.dp), color = Veil.bright, textAlign = TextAlign.Center,
            style = TextStyle(fontFamily = Serif, fontSize = 20.sp * TypeLook.scale, letterSpacing = 5.sp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            val tabs = Tab.entries.filter { (it != Tab.TEST || vm.testMode) }
            tabs.forEach { t ->
                val badge = if (t == Tab.HERO && game.hero.unspentPoints > 0 || t == Tab.CHRONICLE && tab != Tab.CHRONICLE && de.bornim.core.Chronicle.fresh(game.state)) " ★" else ""
                // 60j: a drawn sign with a small word under it
                TabButton(TabSign.valueOf(t.name), labels.getValue(t)(lang), Modifier.weight(1f), selected = t == tab, badge = badge.isNotEmpty()) {
                    // 86.2: the map tab tapped again, after the map sign opened it: straight back into the game
                    MenuExplain.shown = null
                    if (vm.mapDirect && t == Tab.MAP && tab == Tab.MAP) vm.menuOpen = false
                    else { if (t != Tab.MAP) vm.mapDirect = false; tab = t }
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            // 62c: the map zooms and pans by itself, so it does not sit in the scrolling column
            if (tab == Tab.MAP) MapTab(game, lang) { tab = Tab.CHRONICLE }
            else Column(Modifier.verticalScroll(rememberScrollState())) {
                when (tab) {
                    Tab.HERO -> HeroTab(vm, game, lang, ask)
                    Tab.BAG -> BagTab(vm, game, lang, ask)
                    Tab.GEAR -> GearTab(vm, game, lang, ask)
                    Tab.MAP -> {}
                    Tab.CHRONICLE -> ChronicleTab(game, lang, onIntro = { vm.watchIntro() }, onTemple = { vm.watchTemple() }) { who ->
                        de.bornim.core.MapMarks.of(game.state).firstOrNull { it.who == who }?.let { MapLook.focusMap = it.map; MapLook.focusWho = who }
                        tab = Tab.MAP
                    }
                    Tab.SYSTEM -> SystemTab(vm, game, lang)
                    Tab.TEST -> TestTab(vm, game, lang)
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        BackRow(Ui.close(lang)) { back() }
    }
    // 326: the explanation of a long press lies over the menu, above the close button; nothing below moves
    MenuExplainWindow(Modifier.align(Alignment.BottomCenter).padding(start = 10.dp, end = 10.dp, bottom = 72.dp))
    dialog?.let { ConfirmDialog(it) { dialog = null } }
    }
}

/**
 * 62 the drawn map of the place, only what the hero has seen. 62c: it opens zoomed in on the hero (a red ring with
 * the way he faces), two fingers zoom, one pans; tapping a house or the cave goes a level down, the button up right a
 * level up (62r: ground plan, area map, land map); tapping a place on the land map shows its map (no travel). Marks remind, never lead ([de.bornim.core.MapMarks]): tapping one names it.
 */
@Composable
private fun MapTab(game: Game, lang: Lang, onChronicle: () -> Unit = {}) {
    val german = lang == Lang.DE
    // 64: the chronicle's "On the map" opens the map of the giver's mark
    var shown by remember { mutableStateOf(MapLook.focusMap?.takeIf { de.bornim.core.World.maps.containsKey(it) } ?: game.map.id) }
    var overview by remember { mutableStateOf(MapLook.previewOverview) }
    val map = de.bornim.core.World[shown]
    val here = shown == game.map.id
    // 62f: three switches, all on when new
    var show by remember { mutableStateOf(MapLook.previewShow) }
    Column(Modifier.fillMaxSize()) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Txt(if (overview) (if (MapLook.land != null) (if (german) "Landkarte" else "Map of the land") else if (german) "Besuchte Orte" else "Places visited") else map.name(lang), Modifier.weight(1f), size = 20.sp, bold = true)
            // 62r (Nutzer 13.10., 20:4x: A): one level up, the button naming where it goes; none on the land map
            if (!overview) {
                val up = MapLook.parentOf(shown)
                val label = if (up != null) (if (german) "↑ Gebietskarte" else "↑ Area map") else if (german) "↑ Landkarte" else "↑ Land map"
                PixelButton(label, Modifier.height(36.dp), size = 13.sp) { if (up != null) shown = up else overview = true }
            }
        }
        Spacer(Modifier.height(6.dp))
        if (!overview) {
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                val names = mapOf(
                    de.bornim.core.MapMarks.Group.QUESTS to de.bornim.core.T("Aufträge", "Quests"),
                    de.bornim.core.MapMarks.Group.PEOPLE to de.bornim.core.T("Leute", "People"),
                    de.bornim.core.MapMarks.Group.SERVICES to de.bornim.core.T("Dienste", "Services"),
                )
                for ((g, t) in names) PixelButton(t(lang), Modifier.weight(1f).height(34.dp), selected = g in show, size = 13.sp) {
                    show = if (g in show) show - g else show + g
                }
            }
            Spacer(Modifier.height(6.dp))
        }
        if (overview && MapLook.land != null) LandView(game, lang, MapLook.land!!) { shown = it; overview = false }
        else if (overview) PlaceList(game, lang) { shown = it; overview = false }
        // test of 0.1.676: a switch keeps the zoom and the place on the map (the view used to start afresh)
        else androidx.compose.runtime.key(shown) { MapView(game, lang, map, here, show, onChronicle) { shown = it } }
    }
}

/** 62c: preview switches. */
object MapLook {
    /** 62h: the land map instead of the list of places, on parchment (Nutzer 13.10., 16:3x: "Genauso will ich die Karte sehen"); null: the list. */
    @Volatile var land: de.bornim.core.art.LandSheet.Look? = de.bornim.core.art.LandSheet.Look.PARCHMENT
    /** 64: the map and the person whose mark the map opens on, named and in the middle (from the chronicle); used once. */
    var focusMap: String? = null
    var focusWho: String? = null
    @Volatile var previewOverview = false

    /**
     * 62r: the map one level up from a ground plan (62p): the area map whose entrance leads into it (a house's room,
     * the cave), or null for an area map, whose level up is the land map.
     */
    fun parentOf(id: String): String? {
        val m = de.bornim.core.World.maps[id] ?: return null
        if (m.kind != de.bornim.core.MapKind.INTERIOR && m.kind != de.bornim.core.MapKind.CAVE) return null
        return de.bornim.core.World.maps.values.firstOrNull { o ->
            o.kind != de.bornim.core.MapKind.INTERIOR && o.kind != de.bornim.core.MapKind.CAVE && o.warps.any { it.to.map == id }
        }?.id
    }
    /** A mark to show named at once, by index in the marks of the shown map (-1 none, -2 the last). */
    @Volatile var previewTip = -1
    @Volatile var previewZoom = 2.5f
    /** A mark to show named at once, the first whose German line holds this. */
    @Volatile var previewTipMatch: String? = null
    /** 62f: which switches are on when the map opens. */
    @Volatile var previewShow: Set<de.bornim.core.MapMarks.Group> = de.bornim.core.MapMarks.Group.entries.toSet()
    /** 62g: the handwriting of the house names (Fondamento, OFL). */
    /** 62n (draft, preview `SCHILDER=1` or `=2`): 0 house names in handwriting (62g); 1 small names in the text box's serif, sepia; 2 signs on the houses, the name on tapping. */
    @Volatile var labels = 2
    /** 62n: the serif of the text box (Alegreya, OFL). */
    val serif by lazy { androidx.compose.ui.text.font.FontFamily(androidx.compose.ui.text.font.Font(de.bornim.game.R.font.alegreya_regular, androidx.compose.ui.text.font.FontWeight.Normal)) }
    /** 62n: a house whose name to show at once (preview), the first whose German name holds this. */
    @Volatile var previewHouse: String? = null
    val hand by lazy { androidx.compose.ui.text.font.FontFamily(androidx.compose.ui.text.font.Font(de.bornim.game.R.font.fondamento_regular, androidx.compose.ui.text.font.FontWeight.Normal)) }
}

/**
 * 62h (draft): the land map, the top level of the map: every place as a small drawing, the unknown ones under fog,
 * the names in handwriting, the hero's place marked red. Tapping a known place opens its map; it never travels.
 */
@Composable
private fun LandView(game: Game, lang: Lang, look: de.bornim.core.art.LandSheet.Look, onPick: (String) -> Unit) {
    val s = game.state
    fun known(id: String) = de.bornim.core.World.maps[id]?.let { de.bornim.core.MapMarks.visited(s, it) } == true
    val img = remember(look) { de.bornim.core.art.LandSheet.render(look) { known(it) } }
    val bmp = Bitmaps.of(img)
    val measurer = androidx.compose.ui.text.rememberTextMeasurer()
    val noir = look == de.bornim.core.art.LandSheet.Look.NOIR
    val ink = if (noir) Color(0xFFC9A86A) else Color(0xFF4A3622)
    // where the hero is: the outdoor place, also from inside a house or the cave (62p: a ground plan, not a place of the land)
    val here = game.map.let { m -> when (m.kind) { de.bornim.core.MapKind.INTERIOR -> "village"; de.bornim.core.MapKind.CAVE -> "forest"; else -> m.id } }
    androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxSize().clipToBounds()) {
        val vw = constraints.maxWidth.toFloat(); val vh = constraints.maxHeight.toFloat()
        // the drawing is finer than its map units (LandSheet.S); places sit in map units
        val lw = de.bornim.core.art.LandSheet.W; val lh = de.bornim.core.art.LandSheet.H
        val scale = minOf(vw / lw, vh / lh)
        val ox = (vw - lw * scale) / 2; val oy = (vh - lh * scale) / 2
        val density = androidx.compose.ui.platform.LocalDensity.current.density
        androidx.compose.foundation.Canvas(Modifier.fillMaxSize().pointerInput(Unit) { detectTapGestures { at ->
            de.bornim.core.art.LandSheet.spots.firstOrNull { sp ->
                known(sp.map) && kotlin.math.hypot(ox + sp.x * scale - at.x, oy + sp.y * scale - at.y) < sp.r * scale
            }?.let { onPick(it.map) }
        } }) {
            drawImage(bmp, dstOffset = androidx.compose.ui.unit.IntOffset(ox.toInt(), oy.toInt()),
                dstSize = androidx.compose.ui.unit.IntSize((lw * scale).toInt(), (lh * scale).toInt()),
                filterQuality = androidx.compose.ui.graphics.FilterQuality.Low)
            for (sp in de.bornim.core.art.LandSheet.spots) {
                val name = if (known(sp.map)) de.bornim.core.World[sp.map].name(lang) else "?"
                // a halo of the ground round the letters, so a way or a tree under a name never cuts it
                val halo = androidx.compose.ui.graphics.Shadow(if (noir) Color(0xFF0E0D0B) else Color(0xFFE6D3A8), blurRadius = 6 * density)
                val style = androidx.compose.ui.text.TextStyle(fontFamily = MapLook.hand, fontSize = 16.sp, color = ink, shadow = halo)
                val t = measurer.measure(name, style)
                // D2.8: a long name near the edge moves inwards instead of running over it
                val lx = (ox + sp.labelX * scale - t.size.width / 2f).coerceIn(ox + 4 * density, maxOf(ox + 4 * density, ox + de.bornim.core.art.LandSheet.W * scale - t.size.width - 4 * density))
                drawText(t, topLeft = androidx.compose.ui.geometry.Offset(lx, oy + sp.labelY * scale))
                if (sp.map == here) {
                    val c = androidx.compose.ui.geometry.Offset(ox + sp.x * scale, oy + (sp.y - sp.r * 0.15f) * scale)
                    drawCircle(Color(0x55B0302A), 16 * density, c)
                    drawCircle(Color(0xFFB0302A), 10 * density, c, style = androidx.compose.ui.graphics.drawscope.Stroke(3 * density))
                    drawCircle(Color(0xFFB0302A), 3.5f * density, c)
                }
            }
            // the south road leaves the drawing: an arrow and where it goes
            val style = androidx.compose.ui.text.TextStyle(fontFamily = MapLook.hand, fontSize = 13.sp, color = ink.copy(alpha = 0.8f),
                shadow = androidx.compose.ui.graphics.Shadow(if (noir) Color(0xFF0E0D0B) else Color(0xFFE6D3A8), blurRadius = 6 * density))
            val t = measurer.measure(if (lang == Lang.DE) "nach Süden" else "to the south", style)
            drawText(t, topLeft = androidx.compose.ui.geometry.Offset(ox + 108 * scale, oy + 278 * scale))
        }
    }
}

/** The places the hero has been to, each a small picture of its map; tapping one shows it. */
@Composable
private fun PlaceList(game: Game, lang: Lang, onPick: (String) -> Unit) {
    val s = game.state
    val outdoor = de.bornim.core.World.maps.values.filter { it.kind != de.bornim.core.MapKind.INTERIOR && de.bornim.core.MapMarks.visited(s, it) }
    val places = (if (game.map.kind == de.bornim.core.MapKind.INTERIOR) listOf(game.map) else emptyList()) + outdoor
    Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        places.forEach { m ->
            val gate = game.state.has(de.bornim.core.Story.GATE_OPEN)
            val img = remember(m.id, gate) { de.bornim.core.art.MapSheet.render(m, { x, y -> seenOn(game, m, x, y) }, gateOpen = gate) }
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
    if (m.id == game.map.id) game.fog(x, y, view = false) != de.bornim.core.Fog.HIDDEN else de.bornim.core.MapMarks.seen(game.state, m, x, y)

@Composable
private fun MapView(game: Game, lang: Lang, map: de.bornim.core.MapDef, here: Boolean,
                    show: Set<de.bornim.core.MapMarks.Group> = de.bornim.core.MapMarks.Group.entries.toSet(), onChronicle: () -> Unit = {},
                    onOpen: (String) -> Unit = {}) {
    val p = game.state.place
    val gate = game.state.has(de.bornim.core.Story.GATE_OPEN)
    val img = remember(map.id, p.x, p.y, gate) { de.bornim.core.art.MapSheet.render(map, { x, y -> seenOn(game, map, x, y) }, gateOpen = gate) }
    // 62o: a cave's sheet shows only a fixed window round what is explored
    val win = remember(map.id, p.x, p.y) { de.bornim.core.art.MapSheet.window(map, { x, y -> seenOn(game, map, x, y) }) }
    val bmp = Bitmaps.of(img)
    val marks = remember(map.id, show) {
        val all = de.bornim.core.MapMarks.of(game.state).filter { it.map == map.id && it.kind.group in show }
        // 62f: someone with a quest has the quest's mark; their habits join its line instead of a second mark
        val persons = all.filter { it.kind == de.bornim.core.MapMarks.Kind.PERSON }
        val givers = all.filter { it.kind == de.bornim.core.MapMarks.Kind.GIVER }.mapNotNull { it.who }.toSet()
        all.mapNotNull { m ->
            when {
                m.kind == de.bornim.core.MapMarks.Kind.PERSON && m.who in givers -> null
                m.kind == de.bornim.core.MapMarks.Kind.GIVER -> persons.firstOrNull { it.who == m.who }
                    ?.let { pm -> m.copy(label = de.bornim.core.T(m.label.de + "\n– " + pm.label.de.substringAfter(" – "), m.label.en + "\n– " + pm.label.en.substringAfter(" – "))) } ?: m
                else -> m
            }
        }
    }
    val houses = remember(map.id) { de.bornim.core.MapPeople.houses(game.state).filter { it.map == map.id } }
    var houseTip by remember { mutableStateOf(MapLook.previewHouse?.let { w -> houses.firstOrNull { w in it.name.de } }) }
    val measurer = androidx.compose.ui.text.rememberTextMeasurer()
    val focus = remember { MapLook.focusWho?.let { w -> marks.firstOrNull { it.who == w } }.also { MapLook.focusWho = null; MapLook.focusMap = null } }
    var tip by remember { mutableStateOf(focus ?: MapLook.previewTipMatch?.let { w -> marks.firstOrNull { w in it.label.de } }
        ?: marks.getOrNull(if (MapLook.previewTip == -2) marks.lastIndex else MapLook.previewTip)) }
    androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxSize().clipToBounds()) {
        val vw = constraints.maxWidth.toFloat(); val vh = constraints.maxHeight.toFloat()
        val fit = minOf(vw / img.width, vh / img.height)
        val density = androidx.compose.ui.platform.LocalDensity.current.density
        // centre of a tile in the picture's pixels (the inked sheet is finer than its map pixels, 62h)
        val fine = img.width.toFloat() / (win.w * de.bornim.core.art.MapSheet.C + 2 * de.bornim.core.art.MapSheet.PAD)
        fun cx(tx: Int) = (de.bornim.core.art.MapSheet.PAD + (tx - win.x) * de.bornim.core.art.MapSheet.C + de.bornim.core.art.MapSheet.C / 2f) * fine
        fun cy(ty: Int) = (de.bornim.core.art.MapSheet.PAD + (ty - win.y) * de.bornim.core.art.MapSheet.C + de.bornim.core.art.MapSheet.C / 2f) * fine
        // opens zoomed in on the hero, at least so far that the map fills the frame
        var scale by remember { mutableStateOf(if (map.kind != de.bornim.core.MapKind.INTERIOR && (here || focus != null)) maxOf(fit * MapLook.previewZoom, maxOf(vw / img.width, vh / img.height)) else fit) }
        fun clampX(o: Float) = if (img.width * scale <= vw) (vw - img.width * scale) / 2 else o.coerceIn(vw - img.width * scale, 0f)
        fun clampY(o: Float) = if (img.height * scale <= vh) (vh - img.height * scale) / 2 else o.coerceIn(vh - img.height * scale, 0f)
        var ox by remember { mutableStateOf(clampX(if (focus != null) vw / 2 - cx(focus.x) * scale else if (here) vw / 2 - cx(p.x) * scale else 0f)) }
        var oy by remember { mutableStateOf(clampY(if (focus != null) vh / 2 - cy(focus.y) * scale else if (here) vh / 2 - cy(p.y) * scale else 0f)) }
        androidx.compose.foundation.Canvas(
            Modifier.fillMaxSize()
                .pointerInput(Unit) { detectTransformGestures { centroid, pan, zoom, _ ->
                    val ns = (scale * zoom).coerceIn(fit, fit * 6f)
                    val k = ns / scale
                    scale = ns
                    ox = clampX(centroid.x - (centroid.x - ox) * k + pan.x)
                    oy = clampY(centroid.y - (centroid.y - oy) * k + pan.y)
                } }
                .pointerInput(marks) { detectTapGestures { at ->
                    // 62n: with signs, tapping a house names it; 62s: a house the hero has been in opens its ground plan
                    if (MapLook.labels == 2) houses.firstOrNull { h -> kotlin.math.hypot(ox + cx(h.x) * scale - at.x, oy + cy(h.y - 2) * scale - at.y) < 20 * density }
                        ?.let { h -> h.inside?.let { onOpen(it) } ?: run { houseTip = h; tip = null }; return@detectTapGestures }
                    houseTip = null
                    // 62p: the mouth of a cave the hero has been in opens its ground plan
                    fun near(x: Int, y: Int, r: Float) = kotlin.math.hypot(ox + cx(x) * scale - at.x, oy + cy(y) * scale - at.y) < r * density
                    map.warps.firstOrNull { w ->
                        de.bornim.core.World.maps[w.to.map]?.let { it.kind == de.bornim.core.MapKind.CAVE && de.bornim.core.MapMarks.visited(game.state, it) } == true && near(w.x, w.y, 24f)
                    }?.let { onOpen(it.to.map); return@detectTapGestures }
                    tip = marks.minByOrNull { m -> kotlin.math.hypot(ox + cx(m.x) * scale - at.x, oy + cy(m.y) * scale - at.y) }
                        ?.takeIf { m -> near(m.x, m.y, 28f) }
                    // 62s: the rest of a known house (roof, walls, a door without a mark) opens its ground plan
                    if (tip == null) houses.firstOrNull { h -> h.inside != null && (near(h.x, h.y, 24f) || near(h.x, h.y - 1, 24f) || near(h.x, h.y - 2, 24f)) }
                        ?.let { onOpen(it.inside!!) }
                } }
        ) {
            drawImage(bmp, dstOffset = androidx.compose.ui.unit.IntOffset(ox.toInt(), oy.toInt()),
                dstSize = androidx.compose.ui.unit.IntSize((img.width * scale).toInt(), (img.height * scale).toInt()),
                filterQuality = if (fine > 1f) androidx.compose.ui.graphics.FilterQuality.Low else androidx.compose.ui.graphics.FilterQuality.None)
            val ink = Color(0xFF4A3622)
            // 62g: house names in ink, on the roof above the door; 62n: in sepia serif, or a sign instead
            for (h in houses) {
                if (MapLook.labels == 2) {
                    drawHouseSign(h.name.de, androidx.compose.ui.geometry.Offset(ox + cx(h.x) * scale, oy + cy(h.y - 2) * scale), 9 * density, ink, density)
                    continue
                }
                val sepia = Color(0xFF5A3E26)
                val style = if (MapLook.labels == 1) androidx.compose.ui.text.TextStyle(fontFamily = MapLook.serif, fontSize = (de.bornim.core.art.MapSheet.C * fine * 0.62f * scale / density / fontScale).sp, color = sepia)
                    else androidx.compose.ui.text.TextStyle(fontFamily = MapLook.hand, fontSize = (de.bornim.core.art.MapSheet.C * fine * 0.8f * scale / density / fontScale).sp, color = ink)
                val t = measurer.measure(h.name(lang), style)
                val at = androidx.compose.ui.geometry.Offset(ox + cx(h.x) * scale - t.size.width / 2f, oy + cy(h.y - 2) * scale - t.size.height / 2f)
                drawText(t, topLeft = at)
            }
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
                } else if (m.kind != de.bornim.core.MapMarks.Kind.GOAL) {
                    drawService(m.kind, c, r, ink, density)
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
        houseTip?.let { h -> Panel(Modifier.align(Alignment.BottomCenter).padding(8.dp)) { Txt(h.name(lang), size = 15.sp, color = Veil.bright) } }
        tip?.takeIf { it in marks }?.let { m ->
            Panel(Modifier.align(Alignment.BottomCenter).padding(8.dp)) {
                Column {
                    Txt(m.label(lang), size = 15.sp, color = Veil.bright) // D2.6: gold like every hint
                    // 64: a quest's mark leads to its entry in the chronicle
                    if ((m.kind == de.bornim.core.MapMarks.Kind.GIVER || m.kind == de.bornim.core.MapMarks.Kind.GOAL)) {
                        Spacer(Modifier.height(6.dp))
                        PixelButton(if (lang == Lang.DE) "In der Chronik" else "In the chronicle", Modifier.height(32.dp), size = 13.sp) { onChronicle() }
                    }
                }
            }
        }
    }
}

/**
 * 62n (draft): a small hanging sign over a house's door, drawn in ink like an inn's sign: a bracket from the wall, a
 * board on two short chains, on it what the house is: a mug, a purse, a sun, an anvil, a loaf, a scroll, else a door.
 */
private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawHouseSign(name: String, c: androidx.compose.ui.geometry.Offset, r: Float, ink: Color, density: Float) {
    fun o(x: Float, y: Float) = androidx.compose.ui.geometry.Offset(c.x + x * r, c.y + y * r)
    val line = androidx.compose.ui.graphics.drawscope.Stroke(1.4f * density, cap = androidx.compose.ui.graphics.StrokeCap.Round)
    val w = 1.6f * density
    // the bracket and the chains
    drawLine(ink, o(-1.3f, -1.5f), o(1.2f, -1.5f), w, androidx.compose.ui.graphics.StrokeCap.Round)
    drawLine(ink, o(-1.3f, -1.5f), o(-0.6f, -0.9f), w * 0.8f)
    drawLine(ink, o(-0.75f, -1.5f), o(-0.75f, -1.05f), w * 0.7f); drawLine(ink, o(0.75f, -1.5f), o(0.75f, -1.05f), w * 0.7f)
    // the board
    val tl = o(-1.05f, -1.05f); val sz = androidx.compose.ui.geometry.Size(2.1f * r, 1.75f * r)
    drawRoundRect(Color(0xFFEFE4C8), tl, sz, androidx.compose.ui.geometry.CornerRadius(0.2f * r))
    drawRoundRect(ink, tl, sz, androidx.compose.ui.geometry.CornerRadius(0.2f * r), style = androidx.compose.ui.graphics.drawscope.Stroke(1.6f * density))
    val m = o(0f, -0.18f)
    fun p(x: Float, y: Float) = androidx.compose.ui.geometry.Offset(m.x + x * r, m.y + y * r)
    val sz2 = { a: Float, b: Float -> androidx.compose.ui.geometry.Size(a * r, b * r) }
    when {
        name.startsWith("Schänke") -> {
            drawRect(ink, p(-0.4f, -0.4f), sz2(0.6f, 0.8f), style = line)
            drawArc(ink, -90f, 180f, false, p(0.05f, -0.25f), sz2(0.4f, 0.45f), style = line)
        }
        name.startsWith("Kramladen") -> {
            drawCircle(ink, 0.38f * r, p(0f, 0.08f), style = line)
            drawLine(ink, p(-0.22f, -0.38f), p(0.22f, -0.38f), w)
        }
        name.startsWith("Tempel") -> {
            drawCircle(ink, 0.2f * r, m)
            for (k in 0 until 8) { val a = k * Math.PI / 4; drawLine(ink, p((kotlin.math.cos(a) * 0.3).toFloat(), (kotlin.math.sin(a) * 0.3).toFloat()), p((kotlin.math.cos(a) * 0.5).toFloat(), (kotlin.math.sin(a) * 0.5).toFloat()), w * 0.7f) }
        }
        name.startsWith("Schmied") -> {
            drawLine(ink, p(-0.55f, -0.15f), p(0.5f, -0.15f), w * 1.8f)
            drawLine(ink, p(-0.1f, -0.1f), p(-0.05f, 0.3f), w * 1.4f)
            drawLine(ink, p(-0.35f, 0.38f), p(0.3f, 0.38f), w * 1.4f)
        }
        name.startsWith("Bäcker") -> drawOval(ink, p(-0.5f, -0.25f), sz2(1.0f, 0.55f), style = line)
        name.startsWith("Ältester") -> {
            drawRect(ink, p(-0.35f, -0.4f), sz2(0.7f, 0.8f), style = line)
            for (k in 0..2) drawLine(ink, p(-0.2f, -0.18f + k * 0.2f), p(0.2f, -0.18f + k * 0.2f), w * 0.6f)
        }
        else -> {
            drawRect(ink, p(-0.25f, -0.35f), sz2(0.5f, 0.75f), style = line)
            drawCircle(ink, 0.05f * r, p(0.12f, 0.05f))
        }
    }
}

/**
 * 62f: the marks of people and services, drawn in ink on a round of paper like the rest of the map: a bust for
 * someone the hero knows, a mug for the inn, a coin purse for the shop, a sun for the temple, a flame for a campfire.
 */
private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawService(
    kind: de.bornim.core.MapMarks.Kind, c: androidx.compose.ui.geometry.Offset, r: Float, ink: Color, density: Float,
) {
    val paper = Color(0xFFEFE4C8)
    fun o(x: Float, y: Float) = androidx.compose.ui.geometry.Offset(x, y)
    val line = androidx.compose.ui.graphics.drawscope.Stroke(1.6f * density, cap = androidx.compose.ui.graphics.StrokeCap.Round)
    drawCircle(paper, r * 1.25f, c)
    drawCircle(ink, r * 1.25f, c, style = androidx.compose.ui.graphics.drawscope.Stroke(1.8f * density))
    when (kind) {
        de.bornim.core.MapMarks.Kind.PERSON -> {
            drawCircle(ink, r * 0.36f, o(c.x, c.y - r * 0.32f))
            drawArc(ink, 180f, 180f, true, o(c.x - r * 0.62f, c.y + r * 0.16f), androidx.compose.ui.geometry.Size(r * 1.24f, r * 1.1f))
        }
        de.bornim.core.MapMarks.Kind.INN -> {
            drawRect(ink, o(c.x - r * 0.5f, c.y - r * 0.45f), androidx.compose.ui.geometry.Size(r * 0.75f, r * 1.0f), style = line)
            drawArc(ink, -90f, 180f, false, o(c.x + r * 0.05f, c.y - r * 0.25f), androidx.compose.ui.geometry.Size(r * 0.5f, r * 0.55f), style = line)
            drawLine(ink, o(c.x - r * 0.55f, c.y - r * 0.6f), o(c.x + r * 0.3f, c.y - r * 0.6f), 2.4f * density, androidx.compose.ui.graphics.StrokeCap.Round)
        }
        de.bornim.core.MapMarks.Kind.SHOP -> {
            drawCircle(ink, r * 0.48f, o(c.x, c.y + r * 0.15f), style = line)
            drawLine(ink, o(c.x - r * 0.28f, c.y - r * 0.42f), o(c.x + r * 0.28f, c.y - r * 0.42f), 1.6f * density, androidx.compose.ui.graphics.StrokeCap.Round)
            drawLine(ink, o(c.x - r * 0.18f, c.y - r * 0.62f), o(c.x, c.y - r * 0.42f), 1.4f * density)
            drawLine(ink, o(c.x + r * 0.18f, c.y - r * 0.62f), o(c.x, c.y - r * 0.42f), 1.4f * density)
        }
        de.bornim.core.MapMarks.Kind.TEMPLE -> {
            drawCircle(ink, r * 0.3f, c)
            for (k in 0 until 8) {
                val a = k * Math.PI / 4
                drawLine(ink, o(c.x + (r * 0.45f * kotlin.math.cos(a)).toFloat(), c.y + (r * 0.45f * kotlin.math.sin(a)).toFloat()),
                    o(c.x + (r * 0.78f * kotlin.math.cos(a)).toFloat(), c.y + (r * 0.78f * kotlin.math.sin(a)).toFloat()), 1.4f * density, androidx.compose.ui.graphics.StrokeCap.Round)
            }
        }
        de.bornim.core.MapMarks.Kind.FIRE -> {
            drawPath(androidx.compose.ui.graphics.Path().apply {
                moveTo(c.x, c.y - r * 0.75f)
                cubicTo(c.x + r * 0.55f, c.y - r * 0.2f, c.x + r * 0.5f, c.y + r * 0.45f, c.x, c.y + r * 0.45f)
                cubicTo(c.x - r * 0.5f, c.y + r * 0.45f, c.x - r * 0.55f, c.y - r * 0.1f, c.x - r * 0.15f, c.y - r * 0.35f)
                cubicTo(c.x - r * 0.1f, c.y - r * 0.1f, c.x + r * 0.05f, c.y - r * 0.25f, c.x, c.y - r * 0.75f)
                close()
            }, Color(0xFFA8452A))
            drawLine(ink, o(c.x - r * 0.55f, c.y + r * 0.6f), o(c.x + r * 0.55f, c.y + r * 0.6f), 1.8f * density, androidx.compose.ui.graphics.StrokeCap.Round)
        }
        else -> {}
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
                color = if (add > 0) Color(0xFF2A8A3A) else Colors.text) // D2.6: the green Veil lightens on black
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
                PixelButton("+", Modifier.width(44.dp).height(36.dp), ink = Veil.gold, enabled = planned < h.unspentPoints && h.base.getValue(a) + add < Rules.MAX_SCORE) {
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
    // 171 (Chef 18.10.): the gold is a line of its own, the first, so its count is found outside the shop too
    Row(Modifier.fillMaxWidth().padding(vertical = 3.dp), verticalAlignment = Alignment.CenterVertically) {
        SupplyPicture(SupplyArt.GOLD, 36.dp)
        Spacer(Modifier.width(8.dp))
        Txt(Ui.gold(lang), Modifier.weight(1f), size = 16.sp, bold = true, color = Veil.bright)
        Txt("${game.state.gold}", size = 15.sp)
    }
    // 84.5: the spark burns until the next rest; out is out
    if (game.state.spark) Row(Modifier.fillMaxWidth().padding(vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
        Txt(Items[Light.SPARK_ITEM].name(lang), Modifier.weight(1f), size = 15.sp)
        PixelButton(Light.sparkOut(lang), Modifier.height(36.dp), size = 13.sp) {
            vm.toast = game.putOutSpark()
            vm.refresh()
        }
    }
    if (items.isEmpty()) Txt(Ui.nothing(lang), color = Colors.textDim)
    items.forEach { (id, count) ->
        val def = Items[id]
        ItemRow(def, lang, count) {
            val potion = def.kind == ItemKind.POTION || def.kind == ItemKind.FOOD || def.kind == ItemKind.TONIC
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
                        val lit = Light.torch(game.state)
                        game.state.equipFromBag(g, offHand = true)
                        vm.toast = Light.torchChange(game.state, game.heroInDark, lit)?.invoke(lang) ?: "${g.name(lang)}: ${Ui.equipped(lang)}"
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
                    // 84.1T: lighting the torch in the dark (or putting it away for a shield) says so
                    val lit = Light.torch(game.state)
                    if (game.state.equipFromBag(g)) vm.toast = Light.torchChange(game.state, game.heroInDark, lit)?.invoke(lang) ?: "${g.name(lang)}: ${Ui.equipped(lang)}"
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
    val close = if (de) "Schließen" else "Close"
    // 214 (Chef 19.10.): what in the bag fits [slot]; the off hand also takes one-handed weapons (and the torch, a shield)
    fun fitting(slot: GearSlot) = game.state.bag.filter { it.slot == slot || slot == GearSlot.OFF_HAND && it.def.isWeapon && !it.def.twoHanded }
        .sortedWith(compareByDescending<Gear> { h.canWear(it) }.thenByDescending { it.rarity }.thenByDescending { it.ilvl })
    fun wear(g: Gear, slot: GearSlot) {
        // 84.1T: lighting the torch in the dark (or putting it away for a shield) says so, as in the bag
        val lit = Light.torch(game.state)
        if (game.state.equipFromBag(g, offHand = slot == GearSlot.OFF_HAND && g.slot != GearSlot.OFF_HAND))
            vm.toast = Light.torchChange(game.state, game.heroInDark, lit)?.invoke(lang) ?: "${g.name(lang)}: ${Ui.equipped(lang)}"
        vm.refresh()
    }
    fun choose(slot: GearSlot) {
        val list = fitting(slot)
        ask(DialogSpec(title = slot.title(lang), confirm = close, cancel = "", onConfirm = {}) {
            if (list.isEmpty()) Txt(if (de) "Nichts Passendes im Beutel." else "Nothing in the bag fits.", size = 15.sp, color = Colors.textDim)
            list.forEach { g ->
                val ok = h.canWear(g)
                Column(Modifier.alpha(if (ok) 1f else 0.45f)) {
                    GearRow(g, lang, game, vm.tick) {
                        ask(DialogSpec(
                            title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
                            confirm = Ui.equip(lang), cancel = if (de) "Zurück" else "Back", confirmEnabled = ok,
                            onConfirm = { wear(g, slot) },
                        ) { GearDetails(g, game, lang) })
                    }
                    if (!ok) Txt(if (de) "Als ${h.cls.title(lang)} kannst du das nicht tragen." else "As a ${h.cls.title(lang)} you cannot wear this.", size = 13.sp, color = Colors.textDim)
                }
            }
        })
    }
    PaperDoll(game, lang, vm.tick) { slot ->
        val g = h.item(slot)
        if (g == null) {
            choose(slot)
        } else {
            ask(DialogSpec(
                title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
                confirm = Ui.unequip(lang), cancel = close,
                extra = if (fitting(slot).isNotEmpty()) listOf((if (de) "Wechseln" else "Swap") to { choose(slot) }) else emptyList(),
                onConfirm = {
                    val lit = Light.torch(game.state)
                    game.state.unequipToBag(slot)
                    Light.torchChange(game.state, game.heroInDark, lit)?.let { vm.toast = it(lang) }
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
private fun SystemTab(vm: GameViewModel, game: Game, lang: Lang) = SystemSigns(vm, game, lang)
