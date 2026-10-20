package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.CharClass
import de.bornim.core.Battle
import de.bornim.core.Dice
import de.bornim.core.EliteTrait
import de.bornim.core.MonsterLook
import de.bornim.core.Monsters
import de.bornim.core.GearSlot
import de.bornim.core.Loot
import de.bornim.core.Rarity
import de.bornim.core.Rules
import de.bornim.core.Cmd
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.Lang
import de.bornim.core.Mode
import de.bornim.core.Place
import de.bornim.core.Race
import de.bornim.core.Story
import de.bornim.game.GameViewModel
import de.bornim.game.Screen
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import org.jetbrains.skia.Image
import java.io.File

private const val W = 1080
private const val H = 2340
private val out = File("build/screens").apply { mkdirs() }

internal fun GameViewModel.ensureLang(l: Lang) {
    if (lang != l) toggleLang()
}

internal fun Game.skipDialogs() {
    var guard = 0
    while (mode is Mode.Dialog && guard++ < 50) advance()
}

@OptIn(ExperimentalComposeUiApi::class)
private fun shot(name: String, lang: Lang = Lang.DE, taps: List<Offset> = emptyList(), lastFrames: Int = 30,
                 over: (@androidx.compose.runtime.Composable () -> Unit)? = null, settle: Int = 10, setup: (GameViewModel) -> Unit) {
    System.getenv("ONLY")?.let { if (!name.startsWith(it)) return }
    val vm = GameViewModel(Application())
    vm.ensureLang(lang)
    setup(vm)
    val scene = ImageComposeScene(W, H, Density(2.75f)) { androidx.compose.foundation.layout.Box { BornimApp(vm); over?.invoke() } }
    var time = 0L
    var img: Image? = null
    fun frames(n: Int) = repeat(n) {
        img = scene.render(time)
        time += 33_000_000L
        Thread.sleep(25)
    }
    frames(40)
    for ((i, p) in taps.withIndex()) {
        scene.sendPointerEvent(PointerEventType.Press, p)
        frames(2)
        scene.sendPointerEvent(PointerEventType.Release, p)
        frames(if (i == taps.lastIndex) lastFrames else 30)
    }
    if (taps.isEmpty()) frames(settle)
    // RANDZEIT=1: how long a picture of the scene takes to draw, averaged over 30 (27m: the ring beyond the edge)
    if (System.getenv("RANDZEIT") != null) {
        val t0 = System.nanoTime()
        repeat(30) { img = scene.render(time); time += 33_000_000L }
        println("zeit $name: ${"%.1f".format((System.nanoTime() - t0) / 1e6 / 30)} ms je Bild, Rand ${if (de.bornim.core.art.MapEdge.on) "an" else "aus"}")
    }
    File(out, "$name.png").writeBytes(img!!.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote $name")
}

fun geared(vm: GameViewModel, cls: CharClass, race: Race = Race.DWARF) {
    vm.newGame("Thora", race, cls)
    val g = vm.game!!
    g.skipDialogs()
    val s = g.state
    s.hero.gainXp(Rules.xpForLevel[9])
    val dice = Dice(kotlin.random.Random(4))
    for (slot in GearSlot.entries) {
        val r = Rarity.entries[(slot.ordinal * 2) % 6]
        val item = Loot.generate(s, dice, 9, r, cls, slot)
        if (s.hero.canWear(item)) s.equipFromBag(s.addGear(item))
    }
    repeat(14) { i -> s.addGear(Loot.generate(s, dice, 9, Rarity.entries[i % 6], if (i % 3 == 0) null else cls)) }
    s.hero.restoreFully()
}

fun main() {
    // 69: new heroes in the stills start in the world, not in the intro; INTROBILD=ms,ms,… shows the intro at those times
    de.bornim.game.ui.IntroLook.auto = false
    // TEMPELBILD=ms,ms,…: the temple scene (68) in the app at those times, as watched again from the chronicle
    System.getenv("TEMPELBILD")?.let { list ->
        for (ms in list.split(",").map { it.trim().toLong() }) {
            de.bornim.game.ui.IntroLook.fromMs = maxOf(0L, ms - 1600L)
            shot("tempel_${ms}_de", Lang.DE) { vm -> vm.newGame("Thora", Race.HUMAN, CharClass.FIGHTER); vm.watchTemple() }
        }
        System.exit(0)
    }
    System.getenv("INTROBILD")?.let { list ->
        for (ms in list.split(",").map { it.trim().toLong() }) for (lang in listOf(Lang.DE, Lang.EN)) {
            if (lang == Lang.EN && System.getenv("INTROEN") == null) continue
            de.bornim.game.ui.IntroLook.auto = true
            de.bornim.game.ui.IntroLook.fromMs = maxOf(0L, ms - 1600L)
            shot("intro_${ms}_${lang.name.lowercase()}", lang) { vm -> vm.newGame("Thora", Race.HUMAN, CharClass.FIGHTER) }
        }
        System.exit(0)
    }
    System.getenv("FILM")?.let { fightFilm(it); System.exit(0) }
    System.getenv("PROBE")?.let { probeFilm(it); System.exit(0) }
    System.getenv("MARS211")?.let { marsShot(it); System.exit(0) }
    // MUSTER211=1: 211.11: the four pattern pictures in true perspective
    if (System.getenv("MUSTER211") != null) { musterShot(); System.exit(0) }
    System.getenv("FILMBATCH")?.let { fightBatch(it); System.exit(0) }
    if (System.getenv("KARTENBLATT") != null) { renderMapSheets(); System.exit(0) }
    // KARTE62=1: the map tab of 62c, zoomed in on the hero, with quest marks and the list of places
    if (System.getenv("KARTE62") != null) {
        if (System.getenv("KARTENTUSCHE") != null) de.bornim.core.art.MapSheet.ink = true
        System.getenv("SCHILDER")?.toIntOrNull()?.let { de.bornim.game.ui.MapLook.labels = it }
        System.getenv("HAUSNAME")?.let { de.bornim.game.ui.MapLook.previewHouse = it }
        fun setup(vm: GameViewModel, mapId: String, x: Int, y: Int, facing: Facing) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
            g.takeJob("ring"); g.takeJob("stones"); g.takeJob("pelts")
            val st = g.state
            st.flags += de.bornim.core.MapMarks.met("gwenna"); st.flags += de.bornim.core.MapMarks.met("jorin")
            // 62e: the main quest given, the board read
            st.flags += de.bornim.core.Story.QUEST_STARTED; de.bornim.core.Jobs.read(st)
            // the forest seen along the way from the village to the standing stones
            val f = de.bornim.core.World["forest"]
            val stones = (0 until f.height).flatMap { yy -> (0 until f.width).filter { xx -> f.tile(xx, yy) == de.bornim.core.Tile.MENHIR }.map { it to yy } }
            val sx = stones.sumOf { it.first } / stones.size; val sy = stones.sumOf { it.second } / stones.size
            val way = (0..30).map { k -> 9 + (sx - 9) * k / 30 to 29 + (sy - 29) * k / 30 }
            val bits = BooleanArray(f.width * f.height) { i -> val xx = i % f.width; val yy = i / f.width; way.any { (wx, wy) -> (xx - wx) * (xx - wx) + (yy - wy) * (yy - wy) <= 26 } }
            st.explored["forest"] = bits.toList().chunked(4).joinToString("") { c -> c.withIndex().sumOf { (b, v) -> if (v) 1 shl b else 0 }.toString(16) }
            st.place = Place(mapId, if (mapId == "forest") sx + 1 else x, if (mapId == "forest") sy + 2 else y, facing)
            vm.menuOpen = true; vm.refresh()
        }
        de.bornim.game.ui.MenuStart.map = true
        // KARTE62=1 ONLY=62r: 62r the button one level up, from the inn's ground plan and from the village
        if (System.getenv("ONLY") == "62r") {
            de.bornim.game.ui.MapLook.previewTip = -1
            shot("62r_schaenke", settle = 30) { vm -> setup(vm, "inn", 4, 4, Facing.UP) }
            shot("62r_dorf", settle = 30) { vm -> setup(vm, "village", 17, 6, Facing.DOWN) }
            System.exit(0)
        }
        de.bornim.game.ui.MapLook.previewTip = 0
        shot("62c_wald", settle = 30) { vm -> setup(vm, "forest", 0, 0, Facing.UP) }
        de.bornim.game.ui.MapLook.previewZoom = 1.6f
        shot("62c_dorf", settle = 30) { vm -> setup(vm, "village", 17, 6, Facing.DOWN) }
        // 62e: the elder's mark at his door, the notice board (the last mark named)
        de.bornim.game.ui.MapLook.previewTip = -2
        shot("62e_dorf", settle = 30) { vm -> setup(vm, "village", 10, 17, Facing.DOWN) }
        // KARTE62=1 ONLY=64: 64 (draft) the chronicle, tasks and "so far", the hero half through chapter 1 with a job
        if (System.getenv("ONLY") == "64") {
            de.bornim.game.ui.MenuStart.chronicle = true
            fun story(vm: GameViewModel) {
                setup(vm, "village", 17, 6, Facing.DOWN)
                val st = vm.game!!.state
                for (f in listOf(de.bornim.core.Story.BARRIER_OPEN, de.bornim.core.Story.HUNTER_MET, de.bornim.core.Story.KROGG_DEFEATED)) st.flags += f
                st.explored["cave"] = "0"
                de.bornim.core.Jobs.take(st, de.bornim.core.Jobs.all.first()); de.bornim.core.Jobs.take(st, de.bornim.core.Jobs["stones"])
                vm.refresh()
            }
            // "On the map" from Thessa's job: the map opens on her mark, named
            de.bornim.game.ui.MenuStart.chronicle = false
            de.bornim.game.ui.MapLook.previewTip = -1
            shot("64_karte", settle = 30) { vm -> story(vm); vm.game!!.state.flags += de.bornim.core.MapMarks.met("thessa"); de.bornim.game.ui.MapLook.focusMap = "village"; de.bornim.game.ui.MapLook.focusWho = "thessa"; vm.menuOpen = false; vm.refresh(); vm.menuOpen = true; vm.refresh() }
            de.bornim.game.ui.MenuStart.chronicle = true
            for (sofar in listOf(false, true)) {
                de.bornim.game.ui.ChronicleLook.previewSoFar = sofar
                shot(if (sofar) "64_bisher" else "64_auftraege", settle = 30) { vm -> story(vm) }
            }
            System.exit(0)
        }
        // KARTE62=1 ONLY=d41: D4.1 Garrick's hint to Morwen under "Aufträge", and once the bundle is given, among the done
        if (System.getenv("ONLY") == "d41") {
            de.bornim.game.ui.MenuStart.chronicle = true
            de.bornim.game.ui.ChronicleLook.previewSoFar = false
            for (given in listOf(false, true)) shot(if (given) "d41_erledigt" else "d41_auftrag", settle = 30) { vm ->
                setup(vm, "forest", 10, 10, Facing.UP)
                val st = vm.game!!.state
                st.flags += setOf(de.bornim.core.Story.BARRIER_OPEN, de.bornim.core.Story.HUNTER_MET, de.bornim.core.Story.KROGG_HINT)
                if (given) { st.flags += de.bornim.core.Story.SMOKE_GIVEN; st.add(de.bornim.core.Story.SMOKE_BUNDLE, 1) }
                vm.refresh()
            }
            System.exit(0)
        }
        // KARTE62=1 ONLY=62h: 62h (draft) the land map in both looks, from the woods (cave and deep woods not yet seen)
        if (System.getenv("ONLY") == "62h") {
            de.bornim.game.ui.MapLook.previewOverview = true
            for (look in de.bornim.core.art.LandSheet.Look.entries) {
                de.bornim.game.ui.MapLook.land = look
                shot("62h_${look.name.lowercase()}", settle = 30) { vm -> setup(vm, "forest", 0, 0, Facing.UP) }
            }
            System.exit(0)
        }
        // KARTE62=1 KARTENTUSCHE=1 ONLY=62n: 62n (draft) house names in sepia serif, or signs with the name on a tap
        if (System.getenv("ONLY") == "62n") {
            de.bornim.game.ui.MapLook.previewZoom = 1.15f
            for (v in 1..2) {
                de.bornim.game.ui.MapLook.labels = v
                de.bornim.game.ui.MapLook.previewTip = -9
                de.bornim.game.ui.MapLook.previewHouse = if (v == 2) "Schänke" else null
                shot("62n_v$v", settle = 30) { vm ->
                    setup(vm, "village", 9, 12, Facing.DOWN)
                    val st = vm.game!!.state
                    for (id in listOf("rowena", "borin", "thessa", "osric", "bram", "pim")) st.flags += de.bornim.core.MapMarks.met(id)
                    for (i in listOf("inn", "shop", "elder")) st.flags += de.bornim.core.MapPeople.been(i)
                    vm.refresh()
                }
            }
            System.exit(0)
        }
        // KARTE62=1 KARTENTUSCHE=1 ONLY=62o: 62o (draft) the cave's ground plan, the hero a little way in from the mouth
        if (System.getenv("ONLY") == "62o") {
            de.bornim.game.ui.MapLook.previewTip = -9
            for (deep in listOf(8, 16)) shot("62o_hoehle_$deep", settle = 30) { vm ->
                setup(vm, "village", 9, 12, Facing.DOWN)
                val st = vm.game!!.state; val c = de.bornim.core.World["cave"]
                val mouth = c.warps.first()
                // walk in from the mouth along open floor, so far, and mark what lies within 4 tiles of that way as seen
                val seen = HashSet<Pair<Int, Int>>(); var at = mouth.x to mouth.y; val way = mutableListOf(at)
                val open = { x: Int, y: Int -> c.inside(x, y) && c.tile(x, y) != de.bornim.core.Tile.CAVE_WALL }
                repeat(deep * 3) {
                    val next = listOf(0 to -1, 1 to 0, -1 to 0, 0 to 1).map { (dx, dy) -> at.first + dx to at.second + dy }
                        .filter { (x, y) -> open(x, y) && (x to y) !in way }.maxByOrNull { (x, y) -> (x - mouth.x) * (x - mouth.x) + (y - mouth.y) * (y - mouth.y) }
                    if (next != null && way.size < deep) { at = next; way += at }
                }
                for ((wx, wy) in way) for (y in wy - 4..wy + 4) for (x in wx - 4..wx + 4) if (c.inside(x, y) && (x - wx) * (x - wx) + (y - wy) * (y - wy) <= 16) seen += x to y
                val bits = BooleanArray(c.width * c.height) { i -> (i % c.width to i / c.width) in seen }
                st.explored["cave"] = bits.toList().chunked(4).joinToString("") { k -> k.withIndex().sumOf { (b, v) -> if (v) 1 shl b else 0 }.toString(16) }
                st.place = Place("cave", at.first, at.second, Facing.UP)
                vm.refresh(); vm.menuOpen = false; vm.refresh(); vm.menuOpen = true; vm.refresh()
            }
            System.exit(0)
        }
        // KARTE62=1 KARTENTUSCHE=1 ONLY=62r: the ground plans of the rooms in ink, the hero inside
        if (System.getenv("ONLY") == "62r") {
            de.bornim.game.ui.MapLook.previewTip = -9
            for (room in (System.getenv("RAEUME") ?: "inn,shop,elder,temple").split(",")) {
                val m = de.bornim.core.World[room]
                val d = m.warps.first()
                shot("62r_$room", settle = 30) { vm ->
                    setup(vm, "village", 9, 12, Facing.DOWN)
                    vm.game!!.state.place = Place(room, d.x, (d.y - 1).coerceAtLeast(0), Facing.UP)
                    vm.refresh(); vm.menuOpen = false; vm.refresh(); vm.menuOpen = true; vm.refresh()
                }
            }
            System.exit(0)
        }
        if (System.getenv("ONLY") == "62e") System.exit(0)
        // KARTE62=1 ONLY=62f: 62f/62g, people at their usual place, services, house names in handwriting
        if (System.getenv("ONLY") == "62f") {
            val grp = de.bornim.core.MapMarks.Group.entries
            fun known(vm: GameViewModel) {
                val st = vm.game!!.state
                for (id in listOf("rowena", "borin", "thessa", "osric", "bram", "pim", "liska", "garrick")) st.flags += de.bornim.core.MapMarks.met(id)
                st.flags += de.bornim.core.MapPeople.seenAt("bram", "evening"); st.flags += de.bornim.core.MapPeople.seenAt("pim", "square")
                for (i in listOf("inn", "shop", "elder")) st.flags += de.bornim.core.MapPeople.been(i)
                st.flags += de.bornim.core.MapPeople.heard(12, 5); st.flags += de.bornim.core.MapPeople.heard(13, 22)
                vm.refresh()
            }
            de.bornim.game.ui.MapLook.previewZoom = 1.15f
            de.bornim.game.ui.MapLook.previewTip = -1
            de.bornim.game.ui.MapLook.previewTipMatch = "Rowena"
            shot("62f_dorf_alle", settle = 30) { vm -> setup(vm, "village", 9, 12, Facing.DOWN); known(vm) }
            de.bornim.game.ui.MapLook.previewTipMatch = "Thessa"
            shot("62f_dorf_rechts", settle = 30) { vm -> setup(vm, "village", 27, 12, Facing.DOWN); known(vm) }
            de.bornim.game.ui.MapLook.previewTipMatch = "Wache Jorin"
            shot("62f_dorf_jorin", settle = 30) { vm -> setup(vm, "village", 17, 6, Facing.DOWN); known(vm) }
            de.bornim.game.ui.MapLook.previewTipMatch = "Bauer Bram"
            de.bornim.game.ui.MapLook.previewShow = setOf(grp[1])
            shot("62f_dorf_leute", settle = 30) { vm -> setup(vm, "village", 17, 24, Facing.DOWN); known(vm) }
            de.bornim.game.ui.MapLook.previewTipMatch = null
            de.bornim.game.ui.MapLook.previewShow = setOf(grp[2])
            shot("62f_dorf_dienste", settle = 30) { vm -> setup(vm, "village", 9, 12, Facing.DOWN); known(vm) }
            de.bornim.game.ui.MapLook.previewShow = grp.toSet()
            de.bornim.game.ui.MapLook.previewTipMatch = "Garrick"
            shot("62f_wald", settle = 30) { vm ->
                setup(vm, "forest", 0, 0, Facing.UP); known(vm)
                // the camp seen as well
                val st = vm.game!!.state; val f = de.bornim.core.World["forest"]
                val old = st.explored["forest"]!!
                val bits = BooleanArray(f.width * f.height) { i -> val c = old.getOrNull(i / 4)?.digitToInt(16) ?: 0
                    (c shr (i % 4)) and 1 == 1 || (i % f.width - 12) * (i % f.width - 12) + (i / f.width - 9) * (i / f.width - 9) <= 30 || (i % f.width - 10) in -2..2 && i / f.width in 9..30 }
                st.explored["forest"] = bits.toList().chunked(4).joinToString("") { c -> c.withIndex().sumOf { (b, v) -> if (v) 1 shl b else 0 }.toString(16) }
                vm.refresh()
            }
            System.exit(0)
        }
        de.bornim.game.ui.MapLook.previewTip = -1
        de.bornim.game.ui.MapLook.previewOverview = true
        shot("62c_orte", settle = 30) { vm -> setup(vm, "forest", 0, 0, Facing.UP) }
        // D2.8: with the Deep Whisperwood known, its long name by the right edge
        shot("62c_orte_tief", settle = 30) { vm -> setup(vm, "deep_forest", 20, 20, Facing.UP) }
        System.exit(0)
    }
    if (System.getenv("WEGE") != null) { renderWayDrafts(); System.exit(0) }
    // SONNE=morgen|mittag|abend: the shadows at that stand of the sun (89); SONNE=1 in the map shots: by the hour
    System.getenv("SONNE")?.let { s ->
        de.bornim.core.art.MapSun.stand = when (s) { "morgen" -> de.bornim.core.art.MapSun.Stand.MORNING; "abend" -> de.bornim.core.art.MapSun.Stand.EVENING; else -> de.bornim.core.art.MapSun.Stand.NOON }
    }
    System.getenv("FLORA")?.let { renderFloraSheet(it); System.exit(0) }
    if (System.getenv("HOEHLEDINGE") != null) { renderCaveThings(); System.exit(0) }
    if (System.getenv("ISODRAFT") != null) { renderIsoDraft(); System.exit(0) }
    if (System.getenv("ISODINGE") != null) { renderIsoThings(); System.exit(0) }
    if (System.getenv("FEUER") != null) { renderIsoFire(); System.exit(0) }
    if (System.getenv("SQUATBLEND") != null) { renderSquatBlend(); System.exit(0) }
    if (System.getenv("MAPFIG") != null) { renderMapFigureDraft(); System.exit(0) }
    if (System.getenv("MAPFIGYAWS") != null) { renderMapFigureYaws(); System.exit(0) }
    if (System.getenv("SHIELDWALK") != null) { renderShieldWalk(); System.exit(0) }
    if (System.getenv("MAPFOE") != null) { renderMapFoeDraft(); System.exit(0) }
    if (System.getenv("NPCDRAFT") != null) { renderNpcDraft(); System.exit(0) }
    if (System.getenv("NPCIDLE") != null) { renderNpcIdle(); System.exit(0) }
    if (System.getenv("NPCREST") != null) { renderNpcRest(); System.exit(0) }
    if (System.getenv("NPCTORCH") != null) { renderNpcTorch(); System.exit(0) }
    if (System.getenv("VILLAGEDRAFT") != null) { renderVillageDraft(); System.exit(0) }
    if (System.getenv("SITDRAFT") != null) { renderSitDraft(); System.exit(0) }
    if (System.getenv("SQUATDRAFT") != null) { renderSquatDraft(); System.exit(0) }
    System.getenv("GESTEN")?.let { renderGestures(it); System.exit(0) }
    System.getenv("GESTENFILM")?.let { gestureFilm(it); System.exit(0) }
    System.getenv("WALKFILM")?.let { walkFilm(it); System.exit(0) }
    if (System.getenv("BLENDEFILM") != null) { veilFilm(); System.exit(0) }
    System.getenv("IDLEFILM")?.let { idleFilm(it); System.exit(0) }
    if (System.getenv("FOEFILM") != null) { foeFilm(); System.exit(0) }
    if (System.getenv("WARDFILM") != null) { wardFilm(); System.exit(0) }
    if (System.getenv("FIREFLIES") != null) {
        // where the fireflies are, how many show at once in a view, and on which nights
        for (id in listOf("forest", "deep_forest", "village")) {
            val m = de.bornim.core.World[id]
            val flies = de.bornim.game.ui.Fireflies.of(m)
            val T = de.bornim.core.art.WorldArt.T
            val kinds = flies.groupingBy { f -> val (x, y) = f.at(0); m.tile((x / T).toInt(), (y / T).toInt()).name }.eachCount()
            // a view of 6 x 11 tiles moved over the map: how many glow at one moment, on average and at most
            var sum = 0; var most = 0; var views = 0
            for (vy in 0 until m.height - 11 step 3) for (vx in 0 until m.width - 6 step 3) for (clock in 0L until 20000L step 250L) {
                val n = flies.count { f -> val (x, y) = f.at(clock); x / T in vx.toFloat()..(vx + 6f) && y / T in vy.toFloat()..(vy + 11f) && f.glow(clock) > 0.3f }
                sum += n; most = maxOf(most, n); views++
            }
            println("$id: ${flies.size} fireflies, under them: $kinds; lit at once in a view: avg ${"%.2f".format(sum.toDouble() / views)}, most $most")
        }
        println("nights with fireflies (day 1..20): " + (1..20).filter { de.bornim.game.ui.Fireflies.tonight(it, 23 * 60) })
        System.exit(0)
    }
    if (System.getenv("BLENDE") != null) {
        // 24.1: the black screen between places, at full strength, with only the name, and half faded over the map
        fun village(vm: GameViewModel, minutes: Int) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
            val g = vm.game!!; g.skipDialogs()
            de.bornim.game.ui.MapSight.follow()
            g.state.place = Place("village", 11, 7, Facing.UP); g.state.minutes = minutes
            val m = de.bornim.core.World["village"]
            g.state.explored["village"] = "f".repeat((m.width * m.height + 3) / 4)
            de.bornim.core.art.MapGround.prepareNow(m); de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
            vm.refresh()
        }
        shot("blende_1_bornim", over = { de.bornim.game.ui.InterludeVeil("Bornim", "Du kehrst nach Bornim zurück. Niemand fragt, woher das Blut an deinem Mantel stammt.", 1f, 1f) }) { village(it, 12 * 60) }
        shot("blende_2_hoehle", over = { de.bornim.game.ui.InterludeVeil("Blutzahnhöhle", "Der Eingang der Blutzahnhöhle gähnt wie ein Maul.", 1f, 1f) }) { village(it, 12 * 60) }
        shot("blende_3_kurz", over = { de.bornim.game.ui.InterludeVeil("Thessas Kramladen", null, 1f, 1f) }) { village(it, 12 * 60) }
        shot("blende_4_auftauchen", over = { de.bornim.game.ui.InterludeVeil("Bornim", "Bornim schläft. Nur hinter wenigen Fenstern brennt noch Licht.", 0.55f, 0f) }) { village(it, 23 * 60) }
        System.exit(0)
    }
    if (System.getenv("KARTENZOOM") != null) {
        // RANDAUS=1: without the ring beyond the edge, to compare (27m)
        if (System.getenv("RANDAUS") != null) de.bornim.core.art.MapEdge.on = false
        // STANDORT=1: frame rate and the hero's place over the map, as the test tab shows them (86.1)
        if (System.getenv("STANDORT") != null) { de.bornim.game.ui.FrameMeter.on = true; de.bornim.game.ui.PlaceMeter.on = true }
        // the map near (new) and far (former), at noon and at night, in the forest, the village, an inn and the cave
        fun place(vm: GameViewModel, map: String, x: Int, y: Int, minutes: Int, facing: Facing = Facing.UP) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
            val g = vm.game!!; g.skipDialogs()
            g.state.place = Place(map, x, y, facing); g.state.minutes = minutes
            // the sun's stand by the hour of the shot, or the one SONNE= names (89)
            g.sunCut()
            when (System.getenv("SONNE")) { "morgen" -> de.bornim.core.art.MapSun.Stand.MORNING; "mittag" -> de.bornim.core.art.MapSun.Stand.NOON; "abend" -> de.bornim.core.art.MapSun.Stand.EVENING; else -> null }
                ?.let { de.bornim.core.art.MapSun.stand = it }
            // LICHT=fackel|funke|beide: the hero carries a torch in the off hand, a spark of light, or both (84.1, 84.5)
            System.getenv("LICHT")?.let { l ->
                if (l == "fackel" || l == "beide") g.hero.equip(de.bornim.core.Loot.torch(990))
                if (l == "funke" || l == "beide") g.state.spark = true
            }
            // AUSDAUER=0.4[:w]: the breath for running that low, ":w" out of breath (86.3)
            System.getenv("AUSDAUER")?.split(":")?.let { a -> g.state.stamina = a[0].toDouble(); g.state.winded = a.getOrNull(1) == "w" }
            // everything explored, so the shots show the ground; the new ground drawn right away
            val m = de.bornim.core.World[map]
            // UNERKUNDET=1: nothing explored yet, so the edge of the sight shows against the black (13e)
            if (System.getenv("UNERKUNDET") == null) g.state.explored[map] = "f".repeat((m.width * m.height + 3) / 4)
            de.bornim.core.art.MapGround.prepareNow(m)
            val t0 = System.currentTimeMillis()
            de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
            de.bornim.core.art.MapFolk.prepareNow(de.bornim.core.art.MapFolk.garrick)
            println("map figure: ${System.currentTimeMillis() - t0} ms for 64 pictures")
            // RAIN=1: it pours, at full strength at once
            de.bornim.core.Weather.mode = if (System.getenv("RAIN") != null) de.bornim.core.Weather.Mode.ALWAYS else de.bornim.core.Weather.Mode.NEVER
            g.settleWeather()
            // the shots show the map, not the black screen of arriving (24.1)
            de.bornim.game.ui.VeilMemory.game = g; de.bornim.game.ui.VeilMemory.map = map
            vm.refresh()
        }
        for (near in listOf(true, false)) {
            de.bornim.game.ui.MapZoom.near = near
            // SWINGDRAFT=1: the cloak swings on when the hero stops (17, draft)
            // SWINGMORE=1: long hair and the quiver swing on too (17 Rest, draft)
            if (System.getenv("SWINGMORE") != null) de.bornim.core.art.Dress.SWING_MORE = true
            // KATZEINN=ms with the inn shots: the cat (draft), that far into its round
            if (System.getenv("KATZEINN") != null) { de.bornim.core.art.MapCat.draft = true; de.bornim.game.ui.HeroSwing.now = true; de.bornim.core.art.MapCat.shift = System.getenv("KATZEINN").toLongOrNull() ?: 0L }
            // HUNDDORF=ms with the village shots: the dog (draft, D29.3), that far into its round
            if (System.getenv("HUNDDORF") != null) { de.bornim.core.art.MapDog.draft = System.getenv("HUNDDORF") != "aus"; de.bornim.game.ui.HeroSwing.now = true; de.bornim.core.art.MapDog.shift = System.getenv("HUNDDORF").toLongOrNull() ?: 0L }
            if (System.getenv("SWINGDRAFT") != null) { de.bornim.core.art.MapFigure.swingDraft = true; de.bornim.game.ui.HeroSwing.now = true }
            // PONDLIFE=1: frogs on the bank and dragonflies over the forest pond (27.6, draft)
            if (System.getenv("PONDLIFE") != null) de.bornim.core.art.PondLife.draft = true
            // ZOOMSTUFE=1|2: the in-between zoom steps for the near shots (6.15)
            System.getenv("ZOOMSTUFE")?.let { if (near) de.bornim.game.ui.MapZoom.level = it.toInt() }
            val z = if (near) "nah" else "weit"
            // HELDORT=karte:x:y[:richtung];…: the hero anywhere, at noon (test of 0.1.590: lost under several crowns)
            System.getenv("HELDORT")?.split(";")?.forEach { s ->
                val p = s.split(":")
                val f = p.getOrNull(3)?.let { d -> Facing.entries.first { it.name.startsWith(d.uppercase()) } } ?: Facing.DOWN
                // optional fifth field: the hour (e.g. 23 for night)
                val hour = p.getOrNull(4)?.toInt() ?: 12
                shot("zoom_${z}_p_${p[0]}_${p[1]}_${p[2]}" + (if (p.size > 4) "_$hour" else "")) { place(it, p[0], p[1].toInt(), p[2].toInt(), hour * 60, f) }
            }
            // ZEICHEN=1: 134.1, Aldric with news hails the hero, by day in his house and by Garrick's fire at night
            if (System.getenv("ZEICHEN") != null) for ((k, at) in listOf("haus" to Triple("elder", 7 to 5, 12), "feuer" to Triple("forest", 12 to 9, 23))) {
                shot("zoom_${z}_zeichen_$k") {
                    place(it, at.first, at.second.first, at.second.second, at.third * 60, Facing.UP)
                    val g = it.game!!
                    val who = g.map.npcs.first { n -> n.id == "aldric" || n.id == "garrick" }
                    g.state.flags += de.bornim.core.MapMarks.met(who.id)
                    g.state.heard[who.id] = listOf(0)
                    g.update(1_000)
                }
            }
            shot("zoom_${z}_1_wald_tag") { place(it, "forest", 9, 10, 12 * 60) }
            shot("zoom_${z}_2_wald_nacht") { place(it, "forest", 9, 10, 23 * 60) }
            shot("zoom_${z}_3_dorf") { place(it, "village", 11, 7, 12 * 60) }
            shot("zoom_${z}_4_gasthaus") { place(it, "inn", 5, 6, 12 * 60) }
            shot("zoom_${z}_4b_gasthaus_abend") { place(it, "inn", 5, 3, 21 * 60, Facing.DOWN) }
            shot("zoom_${z}_5_hoehle") { place(it, "cave", 10, 5, 12 * 60) }
            if (near) {
                // 13e: the cave seen diagonally, room by room (entrance, both side halls, Krogg, the pool, Grak's hall)
                for ((k, at) in listOf("1_eingang" to (10 to 17), "2_westhalle" to (4 to 9), "3_krogg" to (15 to 10), "4_suedost" to (16 to 15), "5_weiher" to (5 to 15), "6_grak" to (10 to 3), "7_schacht" to (15 to 8), "8_fackel" to (8 to 2), "9_tropfstein" to (15 to 13))) {
                    shot("zoom_${z}_c${k}") { place(it, "cave", at.first, at.second, 12 * 60) }
                }
                // SPURDRAFT=1: traces that stay a while (idea 7, draft): blood, footprints after the rain, dust, mud carried in
                if (System.getenv("SPURDRAFT") != null) {
                    de.bornim.core.Tracks.draft = true
                    /** Walks the hero freely ([dist] tiles each way of [legs]) from [t0] ms of the app clock on. */
                    fun walkFree(g: de.bornim.core.Game, legs: List<Pair<Double, Double>>, dist: Double, run: Boolean = false, t0: Long = 0L) {
                        val fw = g.freeWalk; fw.sync()
                        var t = t0
                        for ((vx, vy) in legs) {
                            val w0 = fw.walked
                            var guard = 0
                            while (fw.walked - w0 < dist && guard++ < 400) { fw.walk(vx, vy, 40, if (run) de.bornim.core.FreeWalk.RUN else de.bornim.core.FreeWalk.WALK, t); t += 40 }
                        }
                    }
                    shot("zoom_${z}_s1_blut") {
                        place(it, "forest", 9, 9, 12 * 60, Facing.UP)
                        val tr = it.game!!.tracks
                        tr.blood("forest", 10.3, 10.6, 0, 3)
                        tr.blood("forest", 7.8, 9.4, -150_000, 11)
                        tr.blood("forest", 12.5, 11.6, -280_000, 5)
                    }
                    shot("zoom_${z}_s2_nach_regen") {
                        // towards the onlooker down the way, so the prints lie behind the hero and nothing stands in front of them
                        place(it, "forest", 9, 18, 12 * 60, Facing.DOWN)
                        it.game!!.tracks.settle(1f)
                        walkFree(it.game!!, listOf(0.0 to 1.0), 2.6)
                    }
                    shot("zoom_${z}_s2b_im_regen") {
                        place(it, "forest", 9, 18, 12 * 60, Facing.DOWN)
                        de.bornim.core.Weather.mode = de.bornim.core.Weather.Mode.ALWAYS; it.game!!.settleWeather()
                        walkFree(it.game!!, listOf(0.0 to 1.0), 2.6)
                    }
                    shot("zoom_${z}_s3_staub") {
                        place(it, "forest", 9, 18, 12 * 60, Facing.DOWN)
                        walkFree(it.game!!, listOf(0.0 to 1.0), 2.4, run = true, t0 = 1000L)
                    }
                    shot("zoom_${z}_s4_schlamm_schaenke") {
                        place(it, "inn", 2, 6, 12 * 60, Facing.RIGHT)
                        val g = it.game!!
                        // the boots muddy from the wet village, then into the inn
                        g.tracks.settle(1f)
                        for (k in 0..40) g.tracks.walked("village", 5.5, 5.0 + k * 0.05, 0.0, de.bornim.core.Tile.GRASS, true, false, 0L)
                        g.tracks.settle(0f)
                        walkFree(g, listOf(1.0 to 0.0), 2.2)
                    }
                }
                shot("zoom_${z}_6_weiher") { place(it, "forest", 7, 15, 12 * 60) }
                shot("zoom_${z}_7_steinkreis") { place(it, "forest", 10, 25, 17 * 60 + 30) }
                shot("zoom_${z}_7b_steinkreis_mitte") { place(it, "forest", 15, 26, 12 * 60) }
                shot("zoom_${z}_7c_schild_sued") { place(it, "forest", 11, 27, 12 * 60, Facing.DOWN) }
                shot("zoom_${z}_8_tiefer_wald") { place(it, "deep_forest", 22, 6, 12 * 60) }
                shot("zoom_${z}_9_hinter_baum") { place(it, "forest", 12, 10, 12 * 60) }
                shot("zoom_${z}_d1_dorf_markt") { place(it, "village", 17, 13, 12 * 60, Facing.UP) }
                shot("zoom_${z}_d2_dorf_haeuser") { place(it, "village", 8, 7, 17 * 60 + 30, Facing.UP) }
                shot("zoom_${z}_d3_dorf_nacht") { place(it, "village", 28, 15, 23 * 60, Facing.UP) }
                shot("zoom_${z}_d4_schaenke_tuer") { place(it, "village", 6, 6, 17 * 60 + 30, Facing.UP) }
                shot("zoom_${z}_d5_hinter_haus") { place(it, "village", 5, 2, 12 * 60, Facing.DOWN) }
                shot("zoom_${z}_d6_tempel") { place(it, "village", 28, 21, 12 * 60, Facing.UP) }
                // 25b: the houses' windows lit at night, and in the dusk as they wake
                shot("zoom_${z}_d7_haeuser_nacht") { place(it, "village", 8, 7, 23 * 60, Facing.UP) }
                shot("zoom_${z}_d8_haeuser_daemmerung") { place(it, "village", 8, 7, 20 * 60 + 15, Facing.UP) }
                // 29: the notice board before the inn, by day and at night
                shot("zoom_${z}_d9_brett_tag") { place(it, "village", 6, 8, 12 * 60, Facing.LEFT) }
                shot("zoom_${z}_d10_schlagbaum") { place(it, "village", 17, 4, 12 * 60, Facing.UP) }
                // 5.6: the barrier opened, and the garden's fence in the south west
                shot("zoom_${z}_d10b_schlagbaum_offen") { place(it, "village", 17, 4, 12 * 60, Facing.UP); it.game!!.state.flags += de.bornim.core.Story.BARRIER_OPEN; it.refresh() }
                shot("zoom_${z}_d12_zaun") { place(it, "village", 6, 27, 12 * 60, Facing.DOWN) }
                // test of 0.1.590: the hero behind Thessa's counter, the counter stays solid; beside it in front
                shot("zoom_${z}_l9_tresen_hinten") { place(it, "shop", 5, 2, 12 * 60, Facing.LEFT) }
                shot("zoom_${z}_l9b_tresen_vorn") { place(it, "shop", 4, 4, 12 * 60, Facing.UP) }
                // 27d: the hero pushed against the shop's front wall (free walking stops him 0.3 tiles before it), at its
                // left end, middle and right end: the house stays solid
                for ((n, hx) in listOf("links" to 26, "mitte" to 29, "rechts" to 30)) shot("zoom_${z}_d11_laden_$n") {
                    place(it, "village", hx, 6, 12 * 60, Facing.UP)
                    it.game!!.freeWalk.apply { sync(); repeat(20) { k -> walk(0.0, -1.0, 50, 1.0, k * 50L) } }
                }
                shot("zoom_${z}_d9b_brett_nacht") { place(it, "village", 6, 8, 23 * 60, Facing.LEFT) }
                shot("zoom_${z}_i1_schaenke_tag") { place(it, "inn", 4, 5, 12 * 60, Facing.UP) }
                shot("zoom_${z}_i2_schaenke_abend") { place(it, "inn", 6, 3, 21 * 60, Facing.LEFT) }
                shot("zoom_${z}_i3_aeltester") { place(it, "elder", 4, 4, 12 * 60, Facing.UP) }
                shot("zoom_${z}_i3b_aeltester_abend") { place(it, "elder", 4, 4, 21 * 60, Facing.UP) }
                // 13q.4: three floor plans of the elder's house, by day and in the evening (drafts, only here)
                elderDrafts()
                for ((k, at) in listOf("a" to (6 to 3), "b" to (5 to 3), "c" to (5 to 3))) {
                    shot("zoom_${z}_e${k}1_aeltester_tag") { place(it, "elder_$k", at.first, at.second, 12 * 60, Facing.UP) }
                    shot("zoom_${z}_e${k}2_aeltester_abend") { place(it, "elder_$k", at.first, at.second, 21 * 60, Facing.UP) }
                }
                shopDrafts()
                for (k in listOf("a", "b", "c")) {
                    shot("zoom_${z}_l${k}1_laden_tag") { place(it, "shop_$k", 5, 4, 12 * 60, Facing.UP) }
                    shot("zoom_${z}_l${k}2_laden_abend") { place(it, "shop_$k", 5, 4, 21 * 60, Facing.UP) }
                }
                templeDrafts()
                for (k in listOf("a", "b", "c")) {
                    shot("zoom_${z}_t${k}1_tempel_tag") { place(it, "temple_$k", 4, 4, 12 * 60, Facing.UP) }
                    shot("zoom_${z}_t${k}2_tempel_abend") { place(it, "temple_$k", 4, 4, 21 * 60, Facing.UP) }
                }
                shot("zoom_${z}_ea3_aeltester_bett") { place(it, "elder_a", 4, 2, 21 * 60, Facing.LEFT) }
                shot("zoom_${z}_i4_laden") { place(it, "shop", 4, 5, 12 * 60, Facing.UP) }
                shot("zoom_${z}_i5_tempel") { place(it, "temple", 4, 4, 12 * 60, Facing.UP) }
                shot("zoom_${z}_i4b_laden_abend") { place(it, "shop", 4, 5, 21 * 60, Facing.UP) }
                shot("zoom_${z}_i5b_tempel_abend") { place(it, "temple", 4, 4, 21 * 60, Facing.UP) }
                shot("zoom_${z}_t1_hohes_gras") { place(it, "forest", 16, 20, 12 * 60, Facing.DOWN) }
                shot("zoom_${z}_h1_hoehleneingang") { place(it, "forest", 10, 2, 12 * 60, Facing.UP) }
                shot("zoom_${z}_h2_hoehleneingang_nacht") { place(it, "forest", 10, 2, 23 * 60, Facing.UP) }
                shot("zoom_${z}_g1_garrick_tag") { place(it, "forest", 10, 9, 12 * 60, Facing.RIGHT) }
                shot("zoom_${z}_g2_garrick_nacht") { place(it, "forest", 10, 10, 23 * 60, Facing.RIGHT) }
                shot("zoom_${z}_g3_garrick_fern") { place(it, "forest", 9, 13, 12 * 60, Facing.UP) }
                for (f in Facing.entries) shot("zoom_${z}_r_${f.name.lowercase()}") { place(it, "forest", 9, 12, 12 * 60, f) }
            }
        }
        System.exit(0)
    }
    if (System.getenv("BEASTDRAFT") != null) { renderBeastDrafts(); System.exit(0) }
    if (System.getenv("WOLFANSICHT") != null) { renderWolfView(); System.exit(0) }
    if (System.getenv("SWINGBILD") != null) { renderSwingDraft(); System.exit(0) }
    if (System.getenv("KATZE") != null) { renderCatDraft(); System.exit(0) }
    if (System.getenv("HUND") != null) { renderDogDraft(); System.exit(0) }
    if (System.getenv("HUEHNER") != null) { renderHenDraft(); System.exit(0) }
    if (System.getenv("HUEHNERFILM") != null) { renderHenFilm(); System.exit(0) }
    if (System.getenv("DOLLDRAFT") != null) { renderShamanGhoulDrafts(); System.exit(0) }
    if (System.getenv("SHAMANDRAFT") != null) { renderShamanDraft(); System.exit(0) }
    if (System.getenv("VERMINDRAFT") != null) { renderVerminDrafts(); System.exit(0) }
    if (System.getenv("VERMINSHEET") != null) { renderVerminSheet(); System.exit(0) }
    if (System.getenv("VERMINANIM") != null) { renderVerminAnim(); System.exit(0) }
    if (System.getenv("KILLDRAFT") != null) { renderKillDrafts(); System.exit(0) }
    if (System.getenv("KILLSHEET") != null) { renderKillSheet(); System.exit(0) }
    if (System.getenv("KILLTIPS") != null) { renderKillTips(); System.exit(0) }
    if (System.getenv("JELLYWOUND") != null) { renderJellyWounds(); System.exit(0) }
    if (System.getenv("VERMINCLOSE") != null) { renderVerminClose(); System.exit(0) }
    if (System.getenv("DRINKDRAFT") != null) { renderDrinkDrafts(); System.exit(0) }
    if (System.getenv("HEROFALL") != null) { renderHeroFallDrafts(); System.exit(0) }
    if (System.getenv("RUNS") != null) {
        battleRuns()
        System.exit(0)
    }
    if (System.getenv("SHEET") != null) { renderHeroSheet(); System.exit(0) }
    if (System.getenv("SCENES") != null) { renderSceneSheet(); System.exit(0) }
    if (System.getenv("CAVES") != null) { renderCaveSheet(); System.exit(0) }
    if (System.getenv("HEROES") != null) { renderHeroDrafts(); System.exit(0) }
    if (System.getenv("DOLL") != null) { renderDollSheet(); System.exit(0) }
    if (System.getenv("DOLL3D") != null) { renderDollModels(); System.exit(0) }
    if (System.getenv("DRESS") != null) { renderDollDressed(); System.exit(0) }
    if (System.getenv("CLASH") != null) { checkClashes(); System.exit(0) }
    if (System.getenv("CAST") != null) { renderCastViews(); System.exit(0) }
    if (System.getenv("STANCE") != null) { renderStanceViews(); System.exit(0) }
    if (System.getenv("ARMS") != null) { renderArmsAndCloak(); System.exit(0) }
    if (System.getenv("TREESHEET") != null) { renderTreeSheet(); System.exit(0) }
    if (System.getenv("BENCH") != null) { benchRender(); System.exit(0) }
    if (System.getenv("RUN") != null) { renderBattleRun(); System.exit(0) }
    if (System.getenv("PORTRAIT") != null) { renderPortraits(); System.exit(0) }
    if (System.getenv("REACH") != null) { measureReach(); System.exit(0) }
    if (System.getenv("LAUNCH") != null) { renderLaunch(); System.exit(0) }
    if (System.getenv("WOUNDS") != null) { renderWounds(); System.exit(0) }
    if (System.getenv("TURN") != null) { renderTurntable(); System.exit(0) }
    if (System.getenv("TITLE") != null) { renderTitleHeroes(); System.exit(0) }
    if (System.getenv("CLERIC") != null) { renderClericShield(); System.exit(0) }
    if (System.getenv("FOELUNGE") != null) { renderFoeLunge(); System.exit(0) }
    if (System.getenv("FOEFALLS") != null) { renderFoeFalls(); System.exit(0) }
    if (System.getenv("FOEANIM") != null) { renderFoeAnims(); System.exit(0) }
    if (System.getenv("FOESHOT") != null) { renderFoeShot(); System.exit(0) }
    if (System.getenv("NEWFALLS") != null) { renderNewFalls(); System.exit(0) }
    if (System.getenv("CREATURES") != null) { renderCreatureDrafts(); System.exit(0) }
    if (System.getenv("SUPPLIES") != null) { renderSupplySheet(); System.exit(0) }
    if (System.getenv("SHIELDTURN") != null) { checkShieldTurn(); System.exit(0) }
    if (System.getenv("VERSHOW") != null) { renderVersatile(); System.exit(0) }
    if (System.getenv("VERSATILE") != null) { checkVersatile(); System.exit(0) }
    if (System.getenv("XBOW") != null) { renderCrossbowProbe(); System.exit(0) }
    if (System.getenv("ITEMS") != null) { renderItemSheet(); System.exit(0) }
    if (System.getenv("HEROSPEAR") != null) { renderHeroSpear(); System.exit(0) }
    if (System.getenv("SPEERSTUFEN") != null) { renderSpearSteps(); System.exit(0) }
    System.getenv("SPEERRF")?.let { renderSpearGrid(it.toInt()); System.exit(0) }
    if (System.getenv("ARMS3D") != null) { renderArms3d(); System.exit(0) }
    if (System.getenv("BEAST") != null) { renderBeastDraft(); System.exit(0) }
    if (System.getenv("BEASTSCENE") != null) { renderBeastScene(); System.exit(0) }
    if (System.getenv("BEASTANIM") != null) { renderBeastAnims(); System.exit(0) }
    System.getenv("SOUNDS")?.let { writeSounds(it.split(",")); System.exit(0) }
    System.getenv("KLANGPROBEN")?.let { writeSoundProposals(it); System.exit(0) }
    System.getenv("RAUMPROBEN")?.let { writeRoomProbes(); System.exit(0) }
    if (System.getenv("RAUMKLANG") == "spiel") { bakeRoomVersions(); System.exit(0) }
    if (System.getenv("FOECLASH") != null) { checkFoeClashes(); System.exit(0) }
    if (System.getenv("HEROVAR") != null) { checkHeroVariants(); System.exit(0) }
    if (System.getenv("FOEKITS") != null) { renderFoeKits(); System.exit(0) }
    if (System.getenv("FOESCENE") != null) { renderFoeInScene(); System.exit(0) }
    if (System.getenv("FOES") != null) { renderFoeDrafts(); System.exit(0) }
    if (System.getenv("FOECLOSE") != null) { renderFoeClose(); System.exit(0) }
    if (System.getenv("FLAMEDODGE") != null) { renderFlameDodge(); System.exit(0) }
    if (System.getenv("FXFOES") != null) { renderFxOnFoes(); System.exit(0) }
    if (System.getenv("ABILITYFX") != null) { renderAbilityFx(); System.exit(0) }
    if (System.getenv("STATUSFX") != null) { renderStatusFx(); System.exit(0) }
    System.getenv("FALLSEQ")?.let { renderFallSequence(it); System.exit(0) }
    if (System.getenv("MAPSHIELD") != null) { renderMapShields(); System.exit(0) }
    if (System.getenv("PORTFILL") != null) { renderPortraitFill(); System.exit(0) }
    if (System.getenv("CLERICSUN") != null) { renderClericSun(); System.exit(0) }
    if (System.getenv("HALFBLOCK") != null) { renderHalflingBlock(); System.exit(0) }
    if (System.getenv("CLERICCLASH") != null) { checkClericStaff(); System.exit(0) }
    if (System.getenv("CLERICSTAFF") != null) { renderClericStaff(); System.exit(0) }
    System.getenv("DUMP")?.let { dumpFrames(it); System.exit(0) }
    if (System.getenv("WEAPONS") != null) { measureWeapons(); renderWeaponSizes(); System.exit(0) }
    if (System.getenv("REACT") != null) { renderReactViews(); System.exit(0) }
    if (System.getenv("DOLLANIM") != null) { renderDollAnims(); System.exit(0) }
    if (System.getenv("BLOCKVIEW") != null) { renderBlockViews(); System.exit(0) }
    if (System.getenv("SPRUNGBILD") != null) { renderJumpStills(); System.exit(0) }
    if (System.getenv("TREFFERBILD") != null) { renderHitStills(); System.exit(0) }
    // INTROBILD=1: the painted pictures of the cutscenes (70, draft): intro (69) and temple (68), with their texts
    if (System.getenv("INTROBILD") != null) { renderIntroSheet(); System.exit(0) }
    // BRUECKE69E=1: the probe of the intro bridge at full resolution, precise and slightly abstracted (69e, draft)
    if (System.getenv("BRUECKE69E") != null) { renderBridgeProbe(); System.exit(0) }
    // INTRO69=1 (or 3, 4; anything else: all): the other intro pictures in the style of the model picture (69, draft)
    if (System.getenv("INTRO69") != null) { renderIntroProbe(); System.exit(0) }
    // TEMPEL68=1..5 (anything else: all): the temple scene at the end of chapter 1 in the style of the intro (68, draft)
    if (System.getenv("TEMPEL68") != null) { renderTempleProbe(); System.exit(0) }
    if (System.getenv("BACKVIEW") != null) { renderBackViews(); System.exit(0) }
    if (System.getenv("ATTACKVIEW") != null) { renderAttackViews(); System.exit(0) }
    if (System.getenv("RANGED") != null) { renderRangedViews(); System.exit(0) }
    if (System.getenv("WEAPONS") != null) { renderWeaponSheet(); System.exit(0) }
    if (System.getenv("WOLFANIM") != null) { renderWolfAnim(); System.exit(0) }
    if (System.getenv("ELITE") != null) { renderEliteMock(); System.exit(0) }
    if (System.getenv("ABOUT") != null) {
        shot("31_about") { it.screen = Screen.ABOUT }
        shot("31_about_en", lang = Lang.EN) { it.screen = Screen.ABOUT }
        // 60k: the saved games and a short note in the new look too
        shot("31_slots") { vm -> geared(vm, CharClass.FIGHTER); vm.save(); vm.toTitle(); vm.screen = Screen.SLOTS }
        shot("31_toast") { vm -> vm.screen = Screen.TITLE; vm.toast = "Testmodus aktiviert" }
        System.exit(0)
    }
    // TEXTKASTEN=1: the text box old and as drafted for 42 (black, gold rim, serif), with a speaker and told text
    if (System.getenv("TEXTKASTEN") != null) {
        fun opened(vm: GameViewModel, spoken: Boolean) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!
            var guard = 0
            while (guard++ < 80) {
                val m = g.mode
                if (m is Mode.Dialog && (m.speaker != null) == spoken) break
                g.advance()
            }
            vm.refresh()
        }
        if (System.getenv("TEXTKASTEN") != "96") for (draft in listOf(false, true)) {
            de.bornim.game.ui.DialogLook.draft = draft
            val tag = if (draft) "neu" else "alt"
            shot("42_gespraech_$tag", settle = 150) { vm -> opened(vm, spoken = true) }
            shot("42_erzaehlt_$tag", settle = 150) { vm -> opened(vm, spoken = false) }
        }
        // 96 (TEXTKASTEN=96: only this): Garrick's long warning, the box grows, nothing is cut
        de.bornim.game.ui.DialogLook.draft = true
        shot("96_lang", settle = 300) { vm -> opened(vm, spoken = true); de.bornim.core.Game::class.java.getDeclaredField("mode").apply { isAccessible = true }.set(vm.game!!, Mode.Dialog("Jäger Garrick", "Und ehrlich, Mira: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald, dann reden wir weiter.")); vm.refresh() }
        System.exit(0)
    }
    // SCHRIFT=1: 60b/60.4: the free serifs on trial in the text box, the shop and the title (SCHRIFT=titel: only the title faces)
    if (System.getenv("SCHRIFT") != null) {
        for (b in de.bornim.core.GearBases.all) for (r in Rarity.entries) de.bornim.core.art.ItemArt.get(b.id, r)
        val tags = listOf("geraet", "garamond", "alegreya", "fell")
        val only = System.getenv("SCHRIFT")
        de.bornim.game.ui.DialogLook.draft = true
        for ((i, tag) in tags.withIndex()) {
            de.bornim.game.ui.TypeLook.choice = i; de.bornim.game.ui.TypeLook.title = 0
            shot("60_titel_$tag") { it.screen = Screen.TITLE }
            if (only == "titel") continue
            shot("60_gespraech_$tag", settle = 150) { vm -> vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!
                var guard = 0; while (guard++ < 80) { val m = g.mode; if (m is Mode.Dialog && m.speaker != null) break; g.advance() }; vm.refresh() }
            de.bornim.game.ui.ShopLook.previewTab = 0; de.bornim.game.ui.ShopLook.previewDialog = 0
            shot("60_laden_$tag", settle = 60) { vm -> geared(vm, CharClass.WIZARD, Race.ELF); val g = vm.game!!; g.state.gold = 640
                g.enqueue(listOf(Cmd.OpenShop(Story.shopStock))); vm.refresh() }
        }
        // the title in the faces made as capitals, with the body in Alegreya
        de.bornim.game.ui.TypeLook.choice = 2
        for ((t, tag) in listOf(1 to "cinzel", 2 to "alegreya_sc")) { de.bornim.game.ui.TypeLook.title = t; shot("60_titel_$tag") { it.screen = Screen.TITLE } }
        System.exit(0)
    }
    // MENUE=1: 60: the menu old and in the look of the text box, each tab (MENUE=neu: only the new)
    if (System.getenv("MENUE") != null) {
        for (b in de.bornim.core.GearBases.all) for (r in Rarity.entries) de.bornim.core.art.ItemArt.get(b.id, r)
        for (it in de.bornim.core.Items.all) de.bornim.core.art.SupplyArt.get(it.id)
        de.bornim.core.art.SupplyArt.get(de.bornim.core.art.SupplyArt.GOLD) // 171: the gold line of the bag
        de.bornim.game.ui.TypeLook.choice = 2
        // MENUE=reiter (60j, draft): the tabs as signs with a small word, beside the words alone
        if (System.getenv("MENUE") == "reiter") {
            for (signs in listOf(true)) {
                fun open(vm: GameViewModel) { geared(vm, CharClass.FIGHTER); if (!vm.testMode) vm.toggleTestMode(); vm.game!!.hero.unspentPoints = 1; vm.menuOpen = true }
                shot("60j_reiter_" + (if (signs) "symbol" else "wort")) { vm -> open(vm) }
                shot("60j_reiter_beutel_" + (if (signs) "symbol" else "wort"), taps = listOf(Offset(410f, 95f))) { vm -> open(vm) }
            }
            System.exit(0)
        }
        // D1.16: only the look of the text box is left; "alt" is gone with its switch
        run {
            val tag = "neu"
            fun open(vm: GameViewModel) { geared(vm, CharClass.FIGHTER)
                val st = vm.game!!.state; for (it in listOf("greater_potion", "remedy", "herbs", "wolf_pelt")) st.add(it, 2); if (System.getenv("MENUE") == "neu" && !vm.testMode) vm.toggleTestMode(); vm.menuOpen = true }
            // D2.11: the tabs share the width evenly (Held, Tasche, Ausrüstung, Karte, Chronik, System, and Test only with "neu")
            val n = if (System.getenv("MENUE") == "neu") 7 else 6
            fun tab(i: Int) = Offset(W * (i + 0.5f) / n, 95f)
            shot("60_menue_held_$tag") { vm -> open(vm) }
            shot("60_menue_beutel_$tag", taps = listOf(tab(1))) { vm -> open(vm) }
            shot("60_menue_beutel_fenster_$tag", taps = listOf(tab(1), Offset(540f, 340f))) { vm -> open(vm) }
            shot("60_menue_ausruestung_$tag", taps = listOf(tab(2))) { vm -> open(vm) }
            shot("60_menue_chronik_$tag", taps = listOf(tab(4))) { vm -> open(vm) }
            shot("60_menue_system_$tag", taps = listOf(tab(5))) { vm -> open(vm) }
        }
        System.exit(0)
    }
    // KAPITELENDE=1: D2.1/D2.2: the end of the chapter and the notice board in the look of the text box
    if (System.getenv("KAPITELENDE") != null) {
        de.bornim.game.ui.TypeLook.choice = 2
        shot("d2_kapitelende") { vm -> geared(vm, CharClass.FIGHTER); val g = vm.game!!; g.enqueue(listOf(Cmd.ChapterEnd)); vm.refresh() }
        shot("d2_anschlagbrett") { vm -> geared(vm, CharClass.FIGHTER); val g = vm.game!!; val m = de.bornim.core.World["village"]
            val (nx, ny) = (0 until m.height).firstNotNullOf { y -> (0 until m.width).firstOrNull { x -> m.tile(x, y) == de.bornim.core.Tile.NOTICE }?.let { it to y } }
            g.state.place = Place("village", nx, ny + 1, Facing.UP); g.interact(); vm.refresh() }
        System.exit(0)
    }
    // HELDENBAU=1: 60: the hero's making old and in the look of the text box, top and scrolled down
    if (System.getenv("HELDENBAU") != null) {
        de.bornim.game.ui.TypeLook.choice = 2
        shot("60_heldenbau_neu") { it.screen = Screen.CREATE }
        System.exit(0)
    }
    // KAMPF60=1: 60: the fight's boxes old and in the look of the text box: opening line, the menu, a blow with its number
    if (System.getenv("KAMPF60") != null) {
        de.bornim.game.ui.TypeLook.choice = 2
        val setup: (GameViewModel) -> Unit = { vm -> vm.newGame("Borin", Race.DWARF, CharClass.CLERIC); val g = vm.game!!; g.skipDialogs()
            g.state.place = Place("forest", 10, 20, Facing.UP); g.enqueue(listOf(Cmd.Fight("goblin"))); vm.refresh() }
        val msgBox = Offset(W / 2f, H - 300f)
        for (draft in listOf(false, true)) {
            de.bornim.game.ui.BattleLook.draft = draft
            val tag = if (draft) "neu" else "alt"
            shot("60_kampf_$tag", setup = setup)
            shot("60_kampf_menue_$tag", taps = List(2) { msgBox }, setup = setup)
        }
        de.bornim.game.ui.BattleLook.pixelNumbers = false
        shot("60_kampf_menue_serif", taps = List(2) { msgBox }, setup = setup)
        System.exit(0)
    }
    // KAMPF172=1: 172: the hero's turn with attack, guard and flight one tap away (taps on the top line of the box, never a button)
    if (System.getenv("KAMPF172") != null) {
        de.bornim.game.ui.TypeLook.choice = 2
        val setup: (GameViewModel) -> Unit = { vm -> vm.newGame("Borin", Race.DWARF, CharClass.CLERIC); val g = vm.game!!; g.skipDialogs()
            g.state.place = Place("forest", 10, 20, Facing.UP); g.enqueue(listOf(Cmd.Fight("goblin"))); vm.refresh() }
        shot("172_kampf_menue", taps = List(8) { Offset(W / 2f, H - 560f) }, setup = setup)
        System.exit(0)
    }
    // KAMPFWOLF=1: 211.10: the classic fight against a wolf, the battle camera as today and from higher above
    if (System.getenv("KAMPFWOLF") != null) {
        de.bornim.game.ui.TypeLook.choice = 2
        val setup: (GameViewModel) -> Unit = { vm -> vm.newGame("Borin", Race.DWARF, CharClass.CLERIC); val g = vm.game!!; g.skipDialogs()
            g.state.place = Place("forest", 10, 20, Facing.UP); g.enqueue(listOf(Cmd.Fight("wolf"))); vm.refresh() }
        for ((tag, cam) in listOf("heute" to (15.0 to null), "oben" to (35.0 to null), "vorn" to (35.0 to -30.0))) {
            de.bornim.core.art.BeastArt.pitch = cam.first; de.bornim.core.art.BeastArt.yaw = cam.second
            shot("kampfwolf_$tag", setup = setup)
        }
        System.exit(0)
    }
    // KAMPF211=1: 211.13: the classic fight from the one camera: a wolf, a goblin and kobolds with their pack in the wood
    // and the cave (KAMPF211=alt: the old scenes, for comparison)
    System.getenv("KAMPF211")?.let { v ->
        de.bornim.game.ui.TypeLook.choice = 2
        if (v == "alt") { de.bornim.game.ui.MarsLayout.camera = false; de.bornim.core.art.FightCamera.see(false) }
        for ((map, foe) in listOf("forest" to "wolf", "forest" to "goblin", "cave" to "kobold", "cave" to "goblin")) {
            val setup: (GameViewModel) -> Unit = { vm -> vm.newGame("Borin", Race.DWARF, CharClass.CLERIC); val g = vm.game!!; g.skipDialogs()
                g.state.place = Place(map, if (map == "cave") 12 else 10, if (map == "cave") 10 else 20, Facing.UP); g.enqueue(listOf(Cmd.Fight(foe))); vm.refresh() }
            shot("211_kampf_${map}_${foe}_$v", settle = 40, setup = setup)
        }
        System.exit(0)
    }
    // MARS201=1: 201: the MARS rules page from the system menu, top and scrolled to the end
    if (System.getenv("MARS201") != null) {
        val setup: (GameViewModel) -> Unit = { vm -> vm.newGame("Borin", Race.DWARF, CharClass.CLERIC); vm.game!!.skipDialogs(); vm.marsRules = true; vm.refresh() }
        shot("201_mars_regeln", setup = setup)
        shot("201_mars_regeln_ende", taps = emptyList(), setup = { vm -> setup(vm); vm.probeFoe = de.bornim.core.Skirmish.Companion.ProbeFoe.WOLVES; vm.probeClass = CharClass.WIZARD })
        System.exit(0)
    }
    // HAENDLER=1: the shop old and as drafted for 59 (black like the text box, overview when selling, comparison when buying)
    if (System.getenv("HAENDLER") != null) {
        for (b in de.bornim.core.GearBases.all) for (r in Rarity.entries) de.bornim.core.art.ItemArt.get(b.id, r)
        for (it in de.bornim.core.Items.all) de.bornim.core.art.SupplyArt.get(it.id)
        fun shop(vm: GameViewModel) {
            geared(vm, CharClass.WIZARD, Race.ELF); val g = vm.game!!
            g.state.gold = 640
            for (it in listOf("potion", "remedy", "wolf_pelt", "boar_tusk", "herbs")) g.state.add(it, 3)
            g.enqueue(listOf(Cmd.OpenShop(Story.shopStock))); vm.refresh()
        }
        if (System.getenv("HAENDLER") == "morwen") {
            de.bornim.game.ui.ShopLook.previewTab = 0; de.bornim.game.ui.ShopLook.previewDialog = -1
            shot("59_morwen_neu", settle = 60) { vm -> shop(vm); val g = vm.game!!; g.advance(); g.enqueue(listOf(Cmd.OpenShop(listOf("potion", "remedy"), brewing = true))); vm.refresh() }
            System.exit(0)
        }
        if (System.getenv("HAENDLER") == "alle") {
            // 59e: selling all of a supply, then the safety question after "Sell"
            de.bornim.game.ui.ShopLook.previewTab = 1; de.bornim.game.ui.ShopLook.previewDialog = 101
            shot("59e_verkauf_alle", settle = 60) { vm -> shop(vm) }
            shot("59e_verkauf_alle_frage", settle = 60, taps = (System.getenv("TAPY") ?: "1530").let { listOf(Offset(774f, it.toFloat())) }) { vm -> shop(vm) }
            System.exit(0)
        }
        run {
            val tag = "neu"
            for ((name, tab, dlg) in listOf(Triple("kauf", 0, -1), Triple("verkauf", 1, -1), Triple("kauf_ruestung", 0, 0),
                    Triple("kauf_vorrat", 0, 100), Triple("verkauf_rueckkauf", 2, -1))) {
                de.bornim.game.ui.ShopLook.previewTab = tab; de.bornim.game.ui.ShopLook.previewDialog = dlg
                shot("59_${name}_$tag", settle = 60) { vm -> shop(vm)
                    if (tab == 1) { val g = vm.game!!; val st = g.state; val d = Dice(kotlin.random.Random(9))
                        val keep = st.bag.filter { st.hero.canWear(it) }.take(3)
                        st.bag.clear(); st.bag += keep; st.inventory.keys.toList().forEach { if (it != "potion") st.inventory.remove(it) }
                        listOf(GearSlot.CHEST, GearSlot.OFF_HAND, GearSlot.MAIN_HAND).forEach { sl ->
                            var x = Loot.generate(st, d, 9, Rarity.RARE, CharClass.FIGHTER, sl); var k = 0
                            while (st.hero.canWear(x) && k++ < 30) x = Loot.generate(st, d, 9, Rarity.RARE, CharClass.FIGHTER, sl)
                            st.addGear(x) }
                        vm.refresh() }
                    if (tab == 2) { val g = vm.game!!; g.state.bag.take(3).toList().forEach { g.sellGear(it) }; g.sell("wolf_pelt", 3); vm.refresh() } }
            }
        }
        System.exit(0)
    }
    // BRETT=1: the notice board's window and the odd jobs in the menu (29)
    if (System.getenv("BRETT") != null) {
        fun jobs(vm: GameViewModel) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
            g.takeJob("ring"); g.takeJob("pelts"); g.state.add("wolf_pelt", 3)
        }
        shot("40_brett") { vm -> jobs(vm); val g = vm.game!!
            g.state.place = Place("village", 5, 7, Facing.LEFT); g.interact(); vm.refresh() }
        shot("41_brett_menue", taps = listOf(Offset(950f, 95f))) { vm -> jobs(vm); vm.menuOpen = true; vm.refresh() }
        System.exit(0)
    }
    // RAST=1: 86.9/86.10 the "Rasten?" window by a campfire, Rowena's counter, the room, and after a rest
    if (System.getenv("RAST") != null) {
        fun at(vm: GameViewModel, place: Place, minutes: Int) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
            g.state.gold = 37; g.state.minutes = minutes; g.state.place = place; g.interact()
            // the map is the one already shown: no black screen of arrival over the world
            de.bornim.game.ui.VeilMemory.game = g; de.bornim.game.ui.VeilMemory.map = place.map
            g.mapChanged = true; vm.refresh()
        }
        shot("50_rast_feuer", lastFrames = 150) { vm -> at(vm, Place("forest", 10, 9, Facing.RIGHT), 20 * 60) }
        shot("51_rast_feuer_lang_heute", lastFrames = 150) { vm -> at(vm, Place("forest", 10, 9, Facing.RIGHT), 20 * 60); vm.game!!.state.longRestDay = vm.game!!.state.day; vm.refresh() }
        shot("52_rast_schaenke", lastFrames = 150) { vm -> at(vm, Place("inn", 1, 3, Facing.UP), 20 * 60); val g = vm.game!!; while (g.mode is Mode.Dialog) g.advance(); vm.refresh() }
        // 139: with raw meat Rowena asks for it first, then the counter offers the sale
        shot("54_rast_fleisch_wort", lastFrames = 150) { vm -> at(vm, Place("inn", 1, 3, Facing.UP), 20 * 60); val g = vm.game!!; while (g.mode is Mode.Dialog) g.advance(); g.advance(); g.state.add("raw_meat", 3); g.state.place = Place("inn", 1, 3, Facing.UP); g.interact(); g.advance(); vm.refresh() }
        shot("55_rast_fleisch_theke", lastFrames = 150) { vm -> at(vm, Place("inn", 1, 3, Facing.UP), 20 * 60); val g = vm.game!!; while (g.mode is Mode.Dialog) g.advance(); g.state.add("raw_meat", 3); g.state.place = Place("inn", 1, 3, Facing.UP); g.advance(); g.interact(); while (g.mode is Mode.Dialog) g.advance(); vm.refresh() }
        // 86: drunk, Rowena sends the hero to bed
        shot("56_rast_betrunken", lastFrames = 150) { vm -> at(vm, Place("inn", 1, 3, Facing.UP), 20 * 60); val g = vm.game!!; g.state.mead = de.bornim.core.Resting.DRUNK; while (g.mode is Mode.Dialog) g.advance(); vm.refresh() }
        shot("53_rast_nachher", lastFrames = 150) { vm -> at(vm, Place("forest", 10, 9, Facing.RIGHT), 20 * 60); val g = vm.game!!; g.hero.hp = 2; g.rest(de.bornim.core.Resting.Kind.SHORT, de.bornim.core.Resting.Spot.FIRE); vm.refresh() }
        System.exit(0)
    }
    if (System.getenv("GEARSHOTS") != null) {
        // drawn ahead, so the shots show the built pictures rather than the stand-ins
        for (b in de.bornim.core.GearBases.all) for (r in Rarity.entries) de.bornim.core.art.ItemArt.get(b.id, r)
        for (it in de.bornim.core.Items.all) de.bornim.core.art.SupplyArt.get(it.id)
        shot("10_shop") { vm -> vm.newGame("Mira", Race.ELF, CharClass.WIZARD); val g = vm.game!!; g.skipDialogs(); g.enqueue(listOf(Cmd.OpenShop(Story.shopStock))); vm.refresh() }
        shot("15b_bag_supplies", taps = listOf(Offset(410f, 95f))) { vm -> geared(vm, CharClass.FIGHTER)
            val st = vm.game!!.state; for (it in listOf("greater_potion", "remedy", "alchemist_fire", "holy_water", "raw_meat", "roast_meat", "herbs", "wolf_pelt", "boar_tusk", "bat_wing")) st.add(it, 2)
            vm.menuOpen = true }
        shot("34_gear_halfling", taps = listOf(Offset(680f, 95f))) { vm -> geared(vm, CharClass.CLERIC, Race.HALFLING); vm.menuOpen = true }
        shot("15_bag_tab", taps = listOf(Offset(410f, 95f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
        shot("16_bag_dialog", taps = listOf(Offset(410f, 95f), Offset(540f, 560f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
        shot("16b_bag_dialog", taps = listOf(Offset(410f, 95f), Offset(540f, 760f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
        shot("16c_bag_dialog", taps = listOf(Offset(410f, 95f), Offset(540f, 1200f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
        System.exit(0)
    }
    if (System.getenv("NEWFOES") != null) {
        fun fight(vm: GameViewModel, id: String, map: String, x: Int, y: Int) {
            vm.newGame("Borin", Race.HUMAN, CharClass.FIGHTER)
            val g = vm.game!!; g.skipDialogs(); g.hero.gainXp(Rules.xpForLevel[4])
            g.state.place = Place(map, x, y, Facing.UP); g.state.minutes = 12 * 60
            g.enqueue(listOf(Cmd.Fight(id))); vm.refresh()
        }
        for ((id, map) in listOf("kobold" to "forest", "zombie" to "forest", "bugbear" to "cave", "hobgoblin_captain" to "cave"))
            shot("90_neu_$id", taps = listOf(Offset(5f, 5f)), lastFrames = 120) { vm -> fight(vm, id, map, 10, 20) }
        System.exit(0)
    }
    hudCheck()
    if (System.getenv("TOUCH") != null) {
        touchShots()
        System.exit(0)
    }
    if (System.getenv("QUICK") != null) System.exit(0)
    renderFxSheet()
    shot("01_title") {}
    shot("02_create") { it.screen = Screen.CREATE }
    shot("03_intro") { it.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER) }
    shot("04_village") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place("village", 11, 7, Facing.DOWN)
        vm.refresh()
    }
    shot("05_forest_en", lang = Lang.EN) { vm ->
        vm.newGame("Tess", Race.HALFLING, CharClass.ROGUE)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place("forest", 10, 20, Facing.UP)
        vm.refresh()
    }
    val battleSetup: (GameViewModel) -> Unit = { vm ->
        vm.newGame("Borin", Race.DWARF, CharClass.CLERIC)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place("forest", 10, 20, Facing.UP)
        g.enqueue(listOf(Cmd.Fight("goblin")))
        vm.refresh()
    }
    shot("06_battle", setup = battleSetup)
    val msgBox = Offset(W / 2f, H - 300f)
    shot("07_battle_menu", taps = List(4) { msgBox }, setup = battleSetup)
    shot("08_cave_boss") { vm ->
        vm.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.flags += Story.GATE_OPEN
        g.state.place = Place("cave", 10, 5, Facing.UP)
        vm.refresh()
    }
    // Cave map: light, things lying around, small life
    for ((n, pos) in listOf("lake" to (5 to 14), "camp" to (15 to 14), "glow" to (4 to 9), "krogg" to (16 to 10), "corridor" to (10 to 12), "grak" to (10 to 3), "exit" to (11 to 17))) {
        shot("80_cavemap_$n") { vm ->
            vm.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER)
            val g = vm.game!!
            g.skipDialogs()
            g.state.flags += Story.GATE_OPEN
            g.state.explored["cave"] = "f".repeat(Story.cave.width * Story.cave.height / 4 + 1)
            g.state.place = Place("cave", pos.first, pos.second, Facing.DOWN)
            vm.refresh()
        }
    }
    // Fog of war in the cave: Grak's hall behind the wall, never seen and once seen, the hero facing away
    for ((n, known) in listOf("fresh" to false, "known" to true)) {
        shot("82_cavefog_$n") { vm ->
            vm.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER)
            val g = vm.game!!
            g.skipDialogs()
            g.state.flags += Story.GATE_OPEN
            g.state.minutes = 2 * 60
            // seen once: the hero stood in the doorway looking up into the hall, then walked on
            if (known) { g.state.place = Place("cave", 16, 12, Facing.UP); g.fog(16, 12) }
            g.state.place = Place("cave", 19, 14, Facing.DOWN)
            vm.refresh()
        }
    }
    // Chapter 1 maps in their new light
    for ((n, spec) in listOf(
        "forest_day" to Triple("forest", 15 to 26, 12 * 60), "forest_dusk" to Triple("forest", 4 to 19, 19 * 60 + 30), "forest_night" to Triple("forest", 11 to 9, 23 * 60),
        "deep_day" to Triple("deep_forest", 8 to 15, 12 * 60), "deep_night" to Triple("deep_forest", 23 to 31, 23 * 60),
        "village_day" to Triple("village", 17 to 12, 12 * 60), "village_dusk" to Triple("village", 17 to 12, 19 * 60 + 30), "village_night" to Triple("village", 17 to 12, 23 * 60),
        "inn_day" to Triple("inn", 5 to 5, 12 * 60), "temple_night" to Triple("temple", 5 to 5, 23 * 60),
    )) {
        shot("81_map_$n") { vm ->
            vm.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER)
            val g = vm.game!!
            g.skipDialogs()
            val m = de.bornim.core.World[spec.first]
            g.state.explored[m.id] = "f".repeat(m.width * m.height / 4 + 1)
            g.state.place = Place(m.id, spec.second.first, spec.second.second, Facing.DOWN)
            g.state.minutes = spec.third
            vm.refresh()
        }
    }
    shot("09_menu") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        vm.game!!.skipDialogs()
        vm.game!!.hero.gainXp(500)
        vm.menuOpen = true
    }
    shot("10_shop") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        val g = vm.game!!
        g.skipDialogs()
        g.enqueue(listOf(Cmd.OpenShop(Story.shopStock)))
        vm.refresh()
    }
    shot("11_shop_dialog", taps = listOf(Offset(W / 2f, 700f))) { vm ->
        vm.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.gold = 100
        g.enqueue(listOf(Cmd.OpenShop(Story.shopStock.drop(10))))
        vm.refresh()
    }
    shot("12_points", taps = listOf(Offset(985f, 1550f), Offset(985f, 1655f))) { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        vm.game!!.skipDialogs()
        vm.game!!.hero.gainXp(500)
        vm.menuOpen = true
    }
    shot("13_battle_skills", taps = List(4) { Offset(W / 2f, H - 300f) } + listOf(Offset(810f, 2010f))) { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place("forest", 10, 20, Facing.UP)
        g.enqueue(listOf(Cmd.Fight("wolf")))
        vm.refresh()
    }
    shot("32_hero_gear") { vm -> geared(vm, CharClass.WIZARD); vm.menuOpen = true }
    shot("33_hero_halfling") { vm -> geared(vm, CharClass.CLERIC, Race.HALFLING); vm.menuOpen = true }
    shot("34_gear_halfling", taps = listOf(Offset(680f, 95f))) { vm -> geared(vm, CharClass.CLERIC, Race.HALFLING); vm.menuOpen = true }
    if (System.getenv("HERO") != null) System.exit(0)
    shot("14_gear_tab", taps = listOf(Offset(680f, 95f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
    shot("15_bag_tab", taps = listOf(Offset(410f, 95f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
    shot("16_bag_dialog", taps = listOf(Offset(410f, 95f), Offset(540f, 560f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
    shot("17_shop_gear") { vm ->
        geared(vm, CharClass.ROGUE)
        vm.game!!.state.gold = 3000
        vm.game!!.enqueue(listOf(Cmd.OpenShop(Story.shopStock)))
        vm.refresh()
    }
    for ((i, f) in listOf(6, 9, 12).withIndex()) {
        shot("18_fx_$i", taps = List(4) { Offset(W / 2f, H - 300f) } + listOf(Offset(810f, 2010f), Offset(540f, 1830f), Offset(W / 2f, H - 300f)), lastFrames = f) { vm ->
            vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
            val g = vm.game!!
            g.skipDialogs()
            g.state.place = Place("forest", 10, 20, Facing.UP)
            g.enqueue(listOf(Cmd.Fight("wolf")))
            vm.refresh()
        }
    }
    // New battle look: forest scenes by time of day, the deep forest, and hits with blood
    fun wolfFight(vm: GameViewModel, map: String, x: Int, y: Int, minutes: Int, id: String = "wolf", cls: CharClass = CharClass.FIGHTER, seed: Int = 0) {
        vm.newGame("Borin", Race.DWARF, cls)
        val g = vm.game!!
        g.skipDialogs()
        g.hero.gainXp(Rules.xpForLevel[4])
        g.state.place = Place(map, x, y, Facing.UP); g.state.minutes = minutes
        g.enqueue(listOf(Cmd.Fight(id)))
        vm.refresh()
    }
    shot("70_battle_day") { vm -> wolfFight(vm, "forest", 10, 20, 12 * 60) }
    shot("70_battle_dusk") { vm -> wolfFight(vm, "forest", 4, 9, 19 * 60 + 40) }
    shot("70_battle_night") { vm -> wolfFight(vm, "forest", 16, 14, 23 * 60) }
    shot("70_battle_deep") { vm -> wolfFight(vm, "deep_forest", 22, 6, 12 * 60, id = "dire_wolf") }
    shot("70_battle_cave") { vm -> wolfFight(vm, "cave", 10, 14, 12 * 60, id = "skeleton") }
    for ((n, pos) in listOf("entrance" to (10 to 17), "tunnel" to (10 to 6), "camp" to (16 to 14), "hall" to (4 to 9), "boss" to (12 to 2), "right" to (17 to 13))) {
        shot("70_cave_$n") { vm -> wolfFight(vm, "cave", pos.first, pos.second, 12 * 60) }
    }
    shot("70_cave_entrance_night") { vm -> wolfFight(vm, "cave", 10, 17, 23 * 60) }
    shot("70_battle_menu", taps = List(4) { msgBox }) { vm -> wolfFight(vm, "forest", 10, 20, 12 * 60) }
    val fightBtn0 = Offset(300f, 1975f)
    // fights in the village and in a house (test fights only): the hero is the doll there too
    shot("77_town", lastFrames = 60, taps = List(4) { msgBox }) { vm -> wolfFight(vm, "village", 12, 12, 12 * 60, id = "goblin", cls = CharClass.CLERIC) }
    shot("77_inn", lastFrames = 60, taps = List(4) { msgBox }) { vm -> wolfFight(vm, "inn", 5, 5, 20 * 60, id = "giant_rat") }
    for ((i, f) in listOf(2, 5, 8, 12).withIndex()) {
        shot("77_town_lunge_$i", taps = List(4) { msgBox } + listOf(fightBtn0, fightBtn0, msgBox, msgBox), lastFrames = f) { vm -> wolfFight(vm, "village", 12, 12, 12 * 60, id = "goblin") }
    }
    // foes on the doll in battle: goblins in the forest, the dead in the cave, every kit
    fun dollFight(vm: GameViewModel, id: String, map: String, x: Int, y: Int, seed: Int, minutes: Int = 12 * 60): Battle {
        vm.newGame("Borin", Race.HUMAN, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place(map, x, y, Facing.UP); g.state.minutes = minutes
        val b = Battle(g.state, Monsters[id], g.lang, Dice(kotlin.random.Random(seed)), 2, false, 2, look = MonsterLook(seed))
        g.fight(b)
        vm.refresh()
        return b
    }
    for (seed in 0..2) {
        shot("79_goblin_$seed", lastFrames = 40, taps = List(3) { msgBox }) { vm -> dollFight(vm, "goblin", "forest", 10, 20, seed) }
        shot("79_skeleton_$seed", lastFrames = 40, taps = List(3) { msgBox }) { vm -> dollFight(vm, "skeleton", "cave", 10, 14, seed) }
    }
    shot("79_archer", lastFrames = 40, taps = List(3) { msgBox }) { vm -> dollFight(vm, "goblin_archer", "forest", 10, 20, 4) }
    val attackBtn = Offset(300f, 1870f)
    for ((i, f) in listOf(5, 10, 16).withIndex()) {
        // the hero's blow and the goblin's answer
        shot("80_goblin_hit_$i", taps = List(3) { msgBox } + listOf(fightBtn0, attackBtn, msgBox, msgBox), lastFrames = f) { vm -> dollFight(vm, "goblin", "forest", 10, 20, 0) }
        shot("80_goblin_foe_$i", taps = List(3) { msgBox } + listOf(fightBtn0, attackBtn, msgBox, msgBox, msgBox, msgBox), lastFrames = f) { vm -> dollFight(vm, "goblin", "forest", 10, 20, 0) }
    }
    // the goblin's blow reaching the hero: the step in, the strike, the way back
    for ((i, f) in listOf(2, 5, 8, 11, 15).withIndex()) {
        shot("81_lunge_$i", taps = List(4) { msgBox }, lastFrames = f) { vm -> dollFight(vm, "goblin", "forest", 10, 20, 0) }
        shot("81_lunge_skel_$i", taps = List(4) { msgBox }, lastFrames = f) { vm -> dollFight(vm, "skeleton", "cave", 10, 14, 2) }
    }
    shot("77_town_fightmenu", taps = List(4) { msgBox } + listOf(fightBtn0)) { vm -> wolfFight(vm, "village", 12, 12, 12 * 60, id = "goblin", cls = CharClass.CLERIC) }
    // 35: holy water greyed out against the living, with the reason beneath
    shot("77_town_bag", taps = List(4) { msgBox } + listOf(Offset(300f, 2150f))) { vm -> wolfFight(vm, "village", 12, 12, 12 * 60, id = "goblin", cls = CharClass.CLERIC); vm.game!!.state.add("holy_water", 2) }
    val fightBtn = Offset(300f, 1975f)
    for ((i, f) in listOf(3, 6, 10, 16).withIndex()) {
        shot("71_hit_$i", taps = List(4) { msgBox } + listOf(fightBtn, msgBox), lastFrames = f) { vm -> vm.changeBlood(2); wolfFight(vm, "forest", 10, 20, 12 * 60) }
    }
    for (extra in 2..4) for ((i, f) in listOf(4, 9, 14, 20).withIndex()) {
        shot("72_foe_${extra}_$i", taps = List(4) { msgBox } + listOf(fightBtn) + List(extra) { msgBox }, lastFrames = f) { vm -> vm.changeBlood(1); wolfFight(vm, "forest", 10, 20, 12 * 60) }
    }
    // New battle sprites: elites, shimmering variants and the cave monsters
    fun fight(vm: GameViewModel, id: String, place: Place, trait: EliteTrait? = null, shiny: Boolean = false, seed: Int = 3) {
        vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = place
        g.fight(Battle(g.state, Monsters[id], g.lang, Dice(), 3, trait != null, 3, trait, shiny, MonsterLook(seed, shiny, trait?.color)))
        vm.refresh()
    }
    val cave = Place("cave", 10, 20, Facing.UP)
    // a pond fight at dusk with a pack, to check nobody stands in the water
    for ((n, tr) in listOf("savage" to EliteTrait.SAVAGE, "vampiric" to EliteTrait.VAMPIRIC, "swift" to EliteTrait.SWIFT, "ancient" to EliteTrait.ANCIENT)) {
        shot("74_elite_$n") { fight(it, "wolf", Place("forest", 10, 20, Facing.UP), trait = tr, seed = 3); it.game!!.state.minutes = 12 * 60 }
    }
    shot("74_shiny") { fight(it, "wolf", Place("forest", 10, 20, Facing.UP), shiny = true, seed = 3); it.game!!.state.minutes = 12 * 60 }
    // hurt foes: posture, wounds and faster breathing at half and a quarter of their hit points
    fun hurtFight(vm: GameViewModel, id: String, place: Place, share: Double, blood: Int = 1) {
        vm.changeBlood(blood)
        vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = place; g.state.minutes = 12 * 60
        val b = Battle(g.state, Monsters[id], g.lang, Dice(), 3, false, 3, null, false, MonsterLook(3))
        Battle::class.java.getDeclaredField("enemyHp").apply { isAccessible = true }.setInt(b, maxOf(1, (b.enemyMaxHp * share).toInt()))
        g.fight(b)
        vm.refresh()
    }
    for ((n, share) in listOf("full" to 1.0, "half" to 0.45, "quarter" to 0.2)) {
        shot("75_hurt_wolf_$n") { hurtFight(it, "wolf", Place("forest", 10, 20, Facing.UP), share) }
        shot("75_hurt_goblin_$n") { hurtFight(it, "goblin", Place("forest", 10, 20, Facing.UP), share) }
        shot("75_hurt_skeleton_$n") { hurtFight(it, "skeleton", Place("cave", 10, 14, Facing.UP), share) }
    }
    shot("75_hurt_wolf_off") { hurtFight(it, "wolf", Place("forest", 10, 20, Facing.UP), 0.2, blood = 0) }
    shot("73_pond_pack") { vm ->
        val seed = (1..300).first { Monsters.packSize(Monsters["wolf"], MonsterLook(it)) == 2 }
        val m = de.bornim.core.World["forest"]
        val (wx, wy) = (0 until m.height).flatMap { y -> (0 until m.width).map { it to y } }.first { (x, y) -> m.tile(x, y) == de.bornim.core.Tile.GRASS && (-3..3).any { d -> m.tile(x + d, y) == de.bornim.core.Tile.WATER } }
        fight(vm, "wolf", Place("forest", wx, wy, Facing.UP), seed = seed)
        vm.game!!.state.minutes = 19 * 60 + 40
        vm.refresh()
    }
    for ((name, minutes) in listOf("45_battle_day" to 12 * 60, "45_battle_dusk" to 19 * 60 + 50, "46_battle_night" to 23 * 60)) {
        shot(name) { vm -> fight(vm, "wolf", Place("forest", 10, 20, Facing.UP)); vm.game!!.state.minutes = minutes }
    }
    val packSeed = (1..200).first { Monsters.packSize(Monsters["kobold"], MonsterLook(it)) == 2 }
    val woods = Place("forest", 10, 20, Facing.UP)
    shot("39_pack") { fight(it, "kobold", woods, seed = packSeed) }
    for ((i, f) in listOf(5, 9).withIndex()) {
        // tap through the messages until a pack mate jabs
        shot("39_pack_jab_$i", taps = List(3) { msgBox } + listOf(Offset(270f, 2010f)) + List(2) { msgBox }, lastFrames = f) { fight(it, "kobold", woods, seed = packSeed) }
    }
    shot("33_status") { vm ->
        fight(vm, "giant_spider", cave, EliteTrait.VENOMOUS)
        val b = (vm.game!!.mode as Mode.Fight).battle
        b.heroStatus[de.bornim.core.Status.POISON] = 3
        b.heroStatus[de.bornim.core.Status.SLOW] = 2
        b.foeStatus[de.bornim.core.Status.BURN] = 2
        b.foeStatus[de.bornim.core.Status.BLEED] = 3
    }
    val forest = Place("forest", 10, 20, Facing.UP)
    shot("19_elite") { fight(it, "wolf", forest, EliteTrait.VENOMOUS) }
    shot("20_shiny") { fight(it, "goblin_shaman", cave, shiny = true) }
    shot("21_ghoul") { fight(it, "ghoul", cave, EliteTrait.BURNING, seed = 8) }
    shot("22_bat") { fight(it, "giant_bat", cave) }
    shot("23_boar_geared", taps = List(3) { msgBox }) { vm -> geared(vm, CharClass.FIGHTER); vm.game!!.state.place = forest; vm.game!!.enqueue(listOf(Cmd.Fight("boar"))); vm.refresh() }
    for ((i, f) in listOf(3, 7).withIndex()) {
        shot("24_attack_$i", taps = List(6) { msgBox } + listOf(Offset(270f, 2010f)), lastFrames = f) { vm -> fight(vm, "kobold", forest) }
    }
    shot("25_test_tab", taps = listOf(Offset(965f, 95f))) { vm ->
        if (!vm.testMode) vm.toggleTestMode()
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        vm.game!!.skipDialogs()
        vm.menuOpen = true
    }
    val wolfSeed = (1..200).first { Monsters.packSize(Monsters["wolf"], MonsterLook(it)) == 2 }
    shot("49_wolf_pack") { fight(it, "wolf", woods, seed = wolfSeed) }
    shot("49_wolf_pack_bite", taps = List(3) { msgBox } + listOf(Offset(270f, 2010f)) + List(2) { msgBox }, lastFrames = 7) { fight(it, "wolf", woods, seed = wolfSeed) }
    shot("49_goblin_scout") { fight(it, "goblin", woods) }
    shot("49_grimfang") { fight(it, "dire_wolf", Place("deep_forest", 22, 7, Facing.UP)) }
    shot("50_map_packs") { vm ->
        vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.place = Place("deep_forest", 22, 8, Facing.UP)
        g.roamers.forEach { it.x = 0; it.y = 0 }
        val list = g.roamers as MutableList
        for ((id, x, y) in listOf(Triple("wolf", 19, 6), Triple("goblin", 25, 6))) {
            val seed = (1..200).first { Monsters.packSize(Monsters[id], MonsterLook(it)) == 2 || id == "goblin" }
            list += de.bornim.core.Roamer(600 + x, id, x, y, x, y, null, false, MonsterLook(seed)).also { it.calmUntil = Long.MAX_VALUE }
        }
        vm.refresh()
    }
    shot("51_menu_cap") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        val g = vm.game!!
        g.skipDialogs()
        g.hero.gainXp(9200, de.bornim.core.Story.levelCap(g.state))
        // gear that would give more than chapter 1 allows
        g.state.equipFromBag(g.state.addGear(de.bornim.core.Gear(0, "amulet", de.bornim.core.Rarity.RARE, 6, 0, listOf(de.bornim.core.Roll(de.bornim.core.Affix.INT, 2), de.bornim.core.Roll(de.bornim.core.Affix.CON, 1)))))
        g.hero.restoreFully()
        g.state.place = Place("forest", 10, 20, Facing.UP)
        vm.menuOpen = true
    }
    val stocked: (GameViewModel) -> Unit = { vm ->
        vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.gold = 80
        for ((id, n) in listOf("herbs" to 5, "raw_meat" to 2, "roast_meat" to 1, "wolf_pelt" to 2, "boar_tusk" to 1, "spider_gland" to 1, "bat_wing" to 1)) g.state.add(id, n)
        g.state.place = Place("deep_forest", 24, 30, Facing.RIGHT)
    }
    shot("52_hedda_brew", taps = listOf(Offset(900f, 250f))) { vm ->
        stocked(vm)
        vm.game!!.enqueue(listOf(Cmd.OpenShop(listOf("potion", "greater_potion", "remedy", "holy_water"), brewing = true)))
        vm.refresh()
    }
    shot("52_hedda_sell", taps = listOf(Offset(540f, 250f))) { vm ->
        stocked(vm)
        vm.game!!.enqueue(listOf(Cmd.OpenShop(listOf("potion", "greater_potion", "remedy", "holy_water"), brewing = true)))
        vm.refresh()
    }
    for ((name, y) in listOf("54_brew_potion" to 690f, "54_brew_remedy" to 904f)) {
        shot(name, taps = listOf(Offset(900f, 250f), Offset(400f, y))) { vm ->
            stocked(vm)
            vm.game!!.enqueue(listOf(Cmd.OpenShop(listOf("potion", "greater_potion", "remedy", "holy_water"), brewing = true)))
            vm.refresh()
        }
    }
    shot("53_bag_ingredients", taps = listOf(Offset(410f, 95f))) { vm -> stocked(vm); vm.menuOpen = true }
    for ((name, place) in listOf("56_flowers" to Place("forest", 6, 22, Facing.LEFT), "56_flowers_deep" to Place("deep_forest", 21, 18, Facing.UP))) {
        shot(name) { vm ->
            vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER)
            val g = vm.game!!
            g.skipDialogs()
            g.state.place = place
            g.state.day = 3
            vm.refresh()
        }
    }
    for ((name, y) in listOf("57_info_cha" to 1740f, "57_info_wis" to 1630f)) {
        shot(name, taps = listOf(Offset(150f, y))) { vm ->
            vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
            val g = vm.game!!
            g.skipDialogs()
            g.hero.gainXp(9200, de.bornim.core.Story.levelCap(g.state))
            g.hero.base[de.bornim.core.Ability.CHA] = 14
            g.hero.base[de.bornim.core.Ability.WIS] = 14
            g.hero.restoreFully()
            vm.menuOpen = true
        }
    }
    shot("58_system_version", taps = listOf(Offset(930f, 95f))) { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        vm.game!!.skipDialogs()
        vm.menuOpen = true
    }
    for ((name, place, minutes) in listOf(
        Triple("60_village_north", Place("village", 15, 8, Facing.DOWN), 10 * 60),
        Triple("60_village_inn", Place("village", 6, 9, Facing.UP), 10 * 60),
        Triple("60_village_shop", Place("village", 29, 9, Facing.UP), 10 * 60),
        Triple("60_village_square", Place("village", 18, 10, Facing.DOWN), 10 * 60),
        Triple("60_village_south", Place("village", 17, 21, Facing.DOWN), 10 * 60),
        Triple("60_village_night", Place("village", 18, 10, Facing.DOWN), 22 * 60),
        Triple("61_village_brook", Place("village", 17, 25, Facing.DOWN), 11 * 60),
        Triple("61_village_farm", Place("village", 26, 27, Facing.DOWN), 11 * 60),
        Triple("61_village_wash", Place("village", 8, 13, Facing.UP), 11 * 60),
    )) {
        shot(name, lastFrames = 45) { vm ->
            vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
            val g = vm.game!!
            g.skipDialogs()
            g.state.place = place
            g.state.minutes = minutes
            vm.refresh()
        }
    }
    shot("62_discard_confirm", taps = listOf(Offset(410f, 95f), Offset(540f, 560f), Offset(538f, 1716f))) { vm -> geared(vm, CharClass.FIGHTER); vm.menuOpen = true }
    shot("63_system_confirm", taps = listOf(Offset(930f, 95f))) { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        vm.game!!.skipDialogs()
        vm.menuOpen = true
    }
    // Save slots: three heroes saved, then the title and the slot list
    val savedHeroes: (GameViewModel) -> Unit = { vm ->
        for ((n, hero) in listOf(Triple("Alrik", Race.HUMAN, CharClass.WIZARD), Triple("Thora", Race.DWARF, CharClass.FIGHTER), Triple("Mira", Race.ELF, CharClass.ROGUE)).withIndex()) {
            vm.newGame(hero.first, hero.second, hero.third, into = n + 1)
            val g = vm.game!!
            g.skipDialogs()
            g.hero.gainXp(Rules.xpForLevel[2 + n * 2], de.bornim.core.Story.levelCap(g.state))
            g.state.place = Place(listOf("village", "forest", "deep_forest")[n], 17, 8, Facing.DOWN)
            vm.save()
        }
        vm.toTitle()
    }
    shot("65_map_geared") { vm -> geared(vm, CharClass.FIGHTER); vm.game!!.state.place = Place("village", 17, 12, Facing.LEFT); vm.refresh() }
    shot("65_slots_geared") { vm ->
        geared(vm, CharClass.FIGHTER); vm.save()
        vm.newGame("Mira", Race.ELF, CharClass.ROGUE, into = 2); vm.game!!.skipDialogs(); vm.save()
        vm.toTitle(); vm.screen = de.bornim.game.Screen.SLOTS
    }
    for ((i, spot) in listOf(10 to 1, 9 to 4).withIndex()) {
        shot("67_cave_entrance_$i") { vm ->
            vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
            g.state.flags += Story.QUEST_STARTED; g.state.flags += Story.BARRIER_OPEN
            g.state.place = Place("forest", spot.first, spot.second, Facing.UP); g.state.minutes = 17 * 60 + 30
            vm.refresh()
        }
    }
    shot("68_status_max") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD); val g = vm.game!!; g.skipDialogs()
        g.state.flags += Story.QUEST_STARTED; g.state.flags += Story.BARRIER_OPEN
        g.hero.gainXp(Rules.xpForLevel[4])
        g.hero.hp = g.hero.maxHp / 2
        for (st in listOf("POISON", "BLEED", "WEAK")) g.state.ailments[st] = 9
        g.state.wellFed = true
        g.state.place = Place("forest", 9, 4, Facing.UP); g.state.minutes = 17 * 60 + 30
        vm.refresh()
    }
    shot("68_status_fighter") { vm ->
        vm.newGame("Thora", Race.DWARF, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
        g.state.flags += Story.QUEST_STARTED; g.state.flags += Story.BARRIER_OPEN
        g.hero.gainXp(Rules.xpForLevel[4])
        for (st in listOf("POISON", "BLEED", "WEAK")) g.state.ailments[st] = 9
        g.state.wellFed = true
        g.state.place = Place("forest", 9, 4, Facing.UP); g.state.minutes = 17 * 60 + 30
        vm.refresh()
    }
    shot("66_barrier_closed") { vm -> vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER); vm.game!!.skipDialogs(); vm.game!!.state.place = Place("village", 17, 6, Facing.UP); vm.refresh() }
    shot("66_barrier_bump") { vm ->
        vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs()
        g.state.flags += Story.QUEST_STARTED
        g.state.place = Place("village", 18, 3, Facing.UP); g.move(Facing.UP); vm.refresh()
    }
    shot("66_barrier_jorin") { vm -> vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs(); g.state.place = Place("village", 15, 6, Facing.UP); vm.refresh() }
    shot("66_barrier_open") { vm -> vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER); val g = vm.game!!; g.skipDialogs(); g.state.flags += Story.QUEST_STARTED; g.state.flags += Story.BARRIER_OPEN; g.state.place = Place("village", 17, 6, Facing.UP); vm.refresh() }
    shot("64_title_slots", setup = savedHeroes)
    shot("64_slots", setup = { vm -> savedHeroes(vm); vm.screen = de.bornim.game.Screen.SLOTS })
    shot("64_slots_full", taps = listOf(Offset(760f, 2250f))) { vm -> savedHeroes(vm); vm.screen = de.bornim.game.Screen.CREATE }
    shot("47_hud_ailments") { vm ->
        vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
        val g = vm.game!!
        g.skipDialogs()
        g.cheatLevel(3)
        g.hero.gainXp(150)
        g.hero.hp = g.hero.maxHp * 2 / 3
        g.hero.sp = g.hero.maxSp / 2
        g.state.ailments[de.bornim.core.Status.POISON.name] = 4
        g.state.ailments[de.bornim.core.Status.WEAK.name] = de.bornim.core.Status.LASTING
        g.state.wellFed = true
        g.state.place = Place("forest", 10, 20, Facing.UP)
        vm.refresh()
    }
    shot("48_hud_fighter_en", lang = Lang.EN) { vm ->
        vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER)
        val g = vm.game!!
        g.skipDialogs()
        g.state.ailments[de.bornim.core.Status.BLEED.name] = 2
        g.state.place = Place("village", 11, 7, Facing.DOWN)
        vm.refresh()
    }
    System.exit(0)
}

/** Floor plans for the elder's house (13q.4), smaller than the old one, with his own things; only in the previews. */
private fun elderDrafts() {
    fun def(id: String, rows: List<String>, ax: Int, ay: Int) {
        de.bornim.core.World.drafts[id] = de.bornim.core.MapDef(id, de.bornim.core.T("Haus des Ältesten", "Elder's House"), de.bornim.core.MapKind.INTERIOR, rows,
            npcs = listOf(de.bornim.core.Npc("aldric", ax, ay, "elder", Facing.DOWN) { emptyList() }))
    }
    // A: study and bed, the bed against the back wall beside the hearth, the sun of Bornim by the desk
    def("elder_a", listOf(
        "####ZZ#W#",
        "#BBskkVd#",
        "#BBkkkka#",
        "#akRRRkk#",
        "#kkRRRkk#",
        "####D####",
    ), 6, 2)
    // B: a low parlour, books and desk by the window, the bed in the far corner
    def("elder_b", listOf(
        "#W#ZZ####",
        "#dQkksBB#",
        "#kkkkkBB#",
        "#kkRRRka#",
        "#kkRRRkk#",
        "####D####",
    ), 4, 2)
    // C: the smallest, everything within reach
    def("elder_c", listOf(
        "###ZZW##",
        "#BBkkdQ#",
        "#BBkkka#",
        "#kkRRkk#",
        "#kkRRkk#",
        "###D####",
    ), 4, 2)
}

/** Floor plans for Thessa's shop (13q.4), smaller than the old one, crammed with goods; only in the previews. */
private fun shopDrafts() {
    fun def(id: String, rows: List<String>, ax: Int, ay: Int) {
        de.bornim.core.World.drafts[id] = de.bornim.core.MapDef(id, de.bornim.core.T("Thessas Kramladen", "Thessa's General Store"), de.bornim.core.MapKind.INTERIOR, rows,
            npcs = listOf(de.bornim.core.Npc("thessa", ax, ay, "merchant", Facing.DOWN) { emptyList() }))
    }
    // A: shelves along the back, the counter across the room, Thessa behind it, a stove in the corner
    def("shop_a", listOf(
        "##ZZ#W###",
        "#kkkQQQU#",
        "#bkkkkkk#",
        "#bKKKKkJ#",
        "#kkkkkku#",
        "#ukkkkkJ#",
        "####D####",
    ), 4, 2)
    // B: the counter by the door on the right, crates of goods on the left
    def("shop_b", listOf(
        "###ZZ#W##",
        "#QQkkkQU#",
        "#kkkkkkk#",
        "#uukkKKK#",
        "#bkkkkkJ#",
        "####D####",
    ), 6, 2)
    // C: the smallest, everything heaped up
    def("shop_c", listOf(
        "###ZZW##",
        "#QQkkkU#",
        "#bkKKkJ#",
        "#ukkkku#",
        "#bkkkkJ#",
        "###D####",
    ), 4, 1)
}

/** Floor plans for the temple of the Dawnlight (13q.4): altar, candles, pews facing it, a font by the door; only in the previews. */
private fun templeDrafts() {
    fun def(id: String, rows: List<String>, ax: Int, ay: Int) {
        de.bornim.core.World.drafts[id] = de.bornim.core.MapDef(id, de.bornim.core.T("Tempel des Morgenlichts", "Temple of the Dawnlight"), de.bornim.core.MapKind.INTERIOR, rows,
            npcs = listOf(de.bornim.core.Npc("osric", ax, ay, "priest", Facing.DOWN) { emptyList() }))
    }
    // A: a broad altar between two candlesticks, two blocks of pews with an aisle, the lectern beside the altar
    def("temple_a", listOf(
        "####W####",
        "#kNAAANk#",
        "#kkkkdkk#",
        "#nnnknnn#",
        "#nnnknnn#",
        "#kk&kkkk#",
        "####D####",
    ), 4, 2)
    // B: a single altar stone, candles standing free, a font on each side of the door
    def("temple_b", listOf(
        "###WWW###",
        "#kkkAkkk#",
        "#kNkkkNk#",
        "#nnkkknn#",
        "#nnkkknn#",
        "#&kkkkk&#",
        "####D####",
    ), 4, 2)
    // C: the smallest, the altar in the corner light
    def("temple_c", listOf(
        "###WW###",
        "#NAAAkd#",
        "#kkkkkN#",
        "#nnkknn#",
        "#&kkkkk#",
        "###D####",
    ), 3, 2)
}
