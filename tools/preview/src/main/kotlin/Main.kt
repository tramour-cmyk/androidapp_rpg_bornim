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

private fun GameViewModel.ensureLang(l: Lang) {
    if (lang != l) toggleLang()
}

private fun Game.skipDialogs() {
    var guard = 0
    while (mode is Mode.Dialog && guard++ < 50) advance()
}

@OptIn(ExperimentalComposeUiApi::class)
private fun shot(name: String, lang: Lang = Lang.DE, taps: List<Offset> = emptyList(), lastFrames: Int = 30, setup: (GameViewModel) -> Unit) {
    System.getenv("ONLY")?.let { if (!name.startsWith(it)) return }
    val vm = GameViewModel(Application())
    vm.ensureLang(lang)
    setup(vm)
    val scene = ImageComposeScene(W, H, Density(2.75f)) { BornimApp(vm) }
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
    if (taps.isEmpty()) frames(10)
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
    System.getenv("FILM")?.let { fightFilm(it); System.exit(0) }
    System.getenv("FILMBATCH")?.let { fightBatch(it); System.exit(0) }
    if (System.getenv("WEGE") != null) { renderWayDrafts(); System.exit(0) }
    System.getenv("FLORA")?.let { renderFloraSheet(it); System.exit(0) }
    if (System.getenv("MAPFIG") != null) { renderMapFigureDraft(); System.exit(0) }
    if (System.getenv("MAPFIGYAWS") != null) { renderMapFigureYaws(); System.exit(0) }
    if (System.getenv("NPCDRAFT") != null) { renderNpcDraft(); System.exit(0) }
    if (System.getenv("NPCIDLE") != null) { renderNpcIdle(); System.exit(0) }
    if (System.getenv("NPCREST") != null) { renderNpcRest(); System.exit(0) }
    System.getenv("WALKFILM")?.let { walkFilm(it); System.exit(0) }
    System.getenv("IDLEFILM")?.let { idleFilm(it); System.exit(0) }
    if (System.getenv("KARTENZOOM") != null) {
        // the map near (new) and far (former), at noon and at night, in the forest, the village, an inn and the cave
        fun place(vm: GameViewModel, map: String, x: Int, y: Int, minutes: Int, facing: Facing = Facing.UP) {
            vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
            val g = vm.game!!; g.skipDialogs()
            g.state.place = Place(map, x, y, facing); g.state.minutes = minutes
            // everything explored, so the shots show the ground; the new ground drawn right away
            val m = de.bornim.core.World[map]
            g.state.explored[map] = "f".repeat((m.width * m.height + 3) / 4)
            de.bornim.core.art.MapGround.prepareNow(m)
            val t0 = System.currentTimeMillis()
            de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
            de.bornim.core.art.MapFolk.prepareNow(de.bornim.core.art.MapFolk.garrick)
            println("map figure: ${System.currentTimeMillis() - t0} ms for 64 pictures")
            vm.refresh()
        }
        for (near in listOf(true, false)) {
            de.bornim.game.ui.MapZoom.near = near
            val z = if (near) "nah" else "weit"
            shot("zoom_${z}_1_wald_tag") { place(it, "forest", 9, 10, 12 * 60) }
            shot("zoom_${z}_2_wald_nacht") { place(it, "forest", 9, 10, 23 * 60) }
            shot("zoom_${z}_3_dorf") { place(it, "village", 11, 7, 12 * 60) }
            shot("zoom_${z}_4_gasthaus") { place(it, "inn", 5, 6, 12 * 60) }
            shot("zoom_${z}_5_hoehle") { place(it, "cave", 10, 5, 12 * 60) }
            if (near) {
                shot("zoom_${z}_6_weiher") { place(it, "forest", 7, 15, 12 * 60) }
                shot("zoom_${z}_7_steinkreis") { place(it, "forest", 10, 25, 17 * 60 + 30) }
                shot("zoom_${z}_8_tiefer_wald") { place(it, "deep_forest", 22, 6, 12 * 60) }
                shot("zoom_${z}_9_hinter_baum") { place(it, "forest", 12, 10, 12 * 60) }
                shot("zoom_${z}_g1_garrick_tag") { place(it, "forest", 10, 9, 12 * 60, Facing.RIGHT) }
                shot("zoom_${z}_g2_garrick_nacht") { place(it, "forest", 10, 10, 23 * 60, Facing.RIGHT) }
                shot("zoom_${z}_g3_garrick_fern") { place(it, "forest", 9, 13, 12 * 60, Facing.UP) }
                for (f in Facing.entries) shot("zoom_${z}_r_${f.name.lowercase()}") { place(it, "forest", 9, 12, 12 * 60, f) }
            }
        }
        System.exit(0)
    }
    if (System.getenv("BEASTDRAFT") != null) { renderBeastDrafts(); System.exit(0) }
    if (System.getenv("DOLLDRAFT") != null) { renderShamanGhoulDrafts(); System.exit(0) }
    if (System.getenv("SHAMANDRAFT") != null) { renderShamanDraft(); System.exit(0) }
    if (System.getenv("VERMINDRAFT") != null) { renderVerminDrafts(); System.exit(0) }
    if (System.getenv("VERMINSHEET") != null) { renderVerminSheet(); System.exit(0) }
    if (System.getenv("VERMINANIM") != null) { renderVerminAnim(); System.exit(0) }
    if (System.getenv("JELLYWOUND") != null) { renderJellyWounds(); System.exit(0) }
    if (System.getenv("VERMINCLOSE") != null) { renderVerminClose(); System.exit(0) }
    if (System.getenv("DRINKDRAFT") != null) { renderDrinkDrafts(); System.exit(0) }
    if (System.getenv("HEROFALL") != null) { renderHeroFallDrafts(); System.exit(0) }
    if (System.getenv("RUNS") != null) {
        battleRuns()
        System.exit(0)
    }
    System.getenv("OVERVIEW")?.let { id ->
        renderMapOverview(id, "map_$id")
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
    if (System.getenv("NEWFALLS") != null) { renderNewFalls(); System.exit(0) }
    if (System.getenv("CREATURES") != null) { renderCreatureDrafts(); System.exit(0) }
    if (System.getenv("SUPPLIES") != null) { renderSupplySheet(); System.exit(0) }
    if (System.getenv("SHIELDTURN") != null) { checkShieldTurn(); System.exit(0) }
    if (System.getenv("VERSHOW") != null) { renderVersatile(); System.exit(0) }
    if (System.getenv("VERSATILE") != null) { checkVersatile(); System.exit(0) }
    if (System.getenv("XBOW") != null) { renderCrossbowProbe(); System.exit(0) }
    if (System.getenv("ITEMS") != null) { renderItemSheet(); System.exit(0) }
    if (System.getenv("HEROSPEAR") != null) { renderHeroSpear(); System.exit(0) }
    if (System.getenv("ARMS3D") != null) { renderArms3d(); System.exit(0) }
    if (System.getenv("BEAST") != null) { renderBeastDraft(); System.exit(0) }
    if (System.getenv("BEASTSCENE") != null) { renderBeastScene(); System.exit(0) }
    if (System.getenv("BEASTANIM") != null) { renderBeastAnims(); System.exit(0) }
    System.getenv("SOUNDS")?.let { writeSounds(it.split(",")); System.exit(0) }
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
    if (System.getenv("BACKVIEW") != null) { renderBackViews(); System.exit(0) }
    if (System.getenv("ATTACKVIEW") != null) { renderAttackViews(); System.exit(0) }
    if (System.getenv("RANGED") != null) { renderRangedViews(); System.exit(0) }
    if (System.getenv("WEAPONS") != null) { renderWeaponSheet(); System.exit(0) }
    if (System.getenv("CAVEMAP") != null) { renderCaveMap(); System.exit(0) }
    System.getenv("MAPS")?.let { ids ->
        for (id in ids.split(",")) for ((t, d) in listOf("day" to 1f, "dusk" to 0.55f, "night" to 0.1f)) renderMapOverview(de.bornim.core.World[id], daylight = d, name = "${id}_$t")
        System.exit(0)
    }
    if (System.getenv("WOLFANIM") != null) { renderWolfAnim(); System.exit(0) }
    if (System.getenv("ELITE") != null) { renderEliteMock(); System.exit(0) }
    if (System.getenv("ABOUT") != null) {
        shot("31_about") { it.screen = Screen.ABOUT }
        shot("31_about_en", lang = Lang.EN) { it.screen = Screen.ABOUT }
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
        "deep_day" to Triple("deep_forest", 8 to 15, 12 * 60), "deep_night" to Triple("deep_forest", 22 to 21, 23 * 60),
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
        g.state.place = Place("deep_forest", 23, 21, Facing.RIGHT)
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
