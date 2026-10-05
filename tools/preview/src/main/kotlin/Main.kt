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

fun main() {
    if (System.getenv("RUNS") != null) {
        battleRuns()
        System.exit(0)
    }
    System.getenv("OVERVIEW")?.let { id ->
        renderMapOverview(id, "map_$id")
        System.exit(0)
    }
    if (System.getenv("ABOUT") != null) {
        shot("31_about") { it.screen = Screen.ABOUT }
        shot("31_about_en", lang = Lang.EN) { it.screen = Screen.ABOUT }
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
    fun geared(vm: GameViewModel, cls: CharClass) {
        vm.newGame("Thora", Race.DWARF, cls)
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
    shot("32_hero_gear") { vm -> geared(vm, CharClass.WIZARD); vm.menuOpen = true }
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
