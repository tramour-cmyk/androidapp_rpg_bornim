@file:OptIn(ExperimentalComposeUiApi::class, InternalComposeUiApi::class)

package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.InternalComposeUiApi
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsNode
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getAllSemanticsNodes
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.unit.Density
import de.bornim.core.Affix
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.Gear
import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.Mode
import de.bornim.core.Place
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Resting
import de.bornim.core.Roll
import de.bornim.core.Rules
import de.bornim.core.Story
import de.bornim.core.Ui
import de.bornim.game.GameViewModel
import de.bornim.game.Screen
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import org.jetbrains.skia.Image
import java.io.File

// 512b (Chef 04.11.: „512b ja“): every menu screen of the old version in the states the Godot test godot/tests/menues_512b.gd
// shows, with what each opens (windows, safety questions, swap lists); names alike on both sides, for the comparison sheets
// (tools/menues_512b_blatt.py). Taps go to a text the screen shows (found in the semantics, so no coordinates guessed);
// next to each picture <name>.txt lists every text with its place. MENUE512B=1, ONLY=<prefix> narrows; pictures in build/screens/512b.

private const val BW = 1080
private const val BH = 2340
private val aus512 = File("build/screens/512b").apply { mkdirs() }
private val dt = Lang.DE

/** Drives one scene: frames, taps on shown texts, scrolling through the semantics. */
class Fahrer(val scene: ImageComposeScene, val name: String) {
    var time = 0L
    var img: Image? = null
    fun frames(n: Int) = repeat(n) {
        img = scene.render(time)
        time += 33_000_000L
        Thread.sleep(10)
    }
    fun nodes(): List<SemanticsNode> = scene.roots.flatMap { it.semanticsOwner.getAllSemanticsNodes(false) }
    fun text(n: SemanticsNode): String {
        val t = n.config.getOrNull(SemanticsProperties.Text)?.joinToString(" ") { it.text } ?: ""
        val e = n.config.getOrNull(SemanticsProperties.EditableText)?.text ?: ""
        val c = n.config.getOrNull(SemanticsProperties.ContentDescription)?.joinToString(" ") ?: ""
        return listOf(t, e, c).filter { it.isNotEmpty() }.joinToString(" ")
    }
    /** mode '=' whole text, '<' begins with, '~' contains; all without case. nth: -1 the last (the window on top). */
    fun find(t: String, mode: Char = '=', nth: Int = -1): SemanticsNode? {
        val u = t.uppercase()
        val hits = nodes().filter { n ->
            val x = text(n).uppercase().replace("ß", "SS")
            val v = u.replace("ß", "SS")
            when (mode) { '<' -> x.startsWith(v); '~' -> x.contains(v); else -> x == v }
        }
        return if (hits.isEmpty()) null else if (nth < 0) hits[hits.size + nth] else hits.getOrNull(nth)
    }
    fun tap(p: Offset, frames: Int = 30) {
        scene.sendPointerEvent(PointerEventType.Press, p)
        frames(2)
        scene.sendPointerEvent(PointerEventType.Release, p)
        frames(frames)
    }
    private fun scrollerOf(n: SemanticsNode): SemanticsNode? {
        var p: SemanticsNode? = n.parent
        while (p != null) {
            if (p.config.getOrNull(SemanticsActions.ScrollBy) != null) return p
            p = p.parent
        }
        return null
    }
    /** Where a node lies, also when it is scrolled out of sight (its bounds in the root are then empty). */
    private fun mitte(n: SemanticsNode): Offset = n.positionInRoot + Offset(n.size.width / 2f, n.size.height / 2f)
    /** Taps the middle of a text; first scrolls it into the middle of its scrolling box if it lies outside. */
    fun tapText(t: String, mode: Char = '=', nth: Int = -1) {
        var n = find(t, mode, nth) ?: error("$name: Text „$t“ nicht da")
        val s = scrollerOf(n)
        if (s != null) {
            val box = s.boundsInRoot
            val c = mitte(n).y
            if (c < box.top + 30f || c > box.bottom - 30f) {
                s.config.getOrNull(SemanticsActions.ScrollBy)?.action?.invoke(0f, c - box.center.y)
                frames(45)
                n = find(t, mode, nth) ?: error("$name: Text „$t“ nach dem Rollen weg")
            }
        }
        println("  $name: tippe „${text(n)}“ bei ${mitte(n)}")
        tap(mitte(n))
    }
    /** Scrolls the largest scrolling box ([which] = index by size, 0 the largest) by [dy] pixels (huge: to the end). */
    fun scroll(dy: Float, which: Int = 0) {
        val s = nodes().filter { it.config.getOrNull(SemanticsActions.ScrollBy) != null }
            .sortedByDescending { it.boundsInRoot.width * it.boundsInRoot.height }.getOrNull(which) ?: error("$name: nichts zum Rollen")
        s.config.getOrNull(SemanticsActions.ScrollBy)?.action?.invoke(0f, dy)
        frames(45)
    }
    /** Scrolls the box holding [t] so the text stands near the top of it. */
    fun scrollTo(t: String, mode: Char = '=', nth: Int = 0) {
        val n = find(t, mode, nth) ?: error("$name: Text „$t“ nicht da")
        val s = scrollerOf(n) ?: return
        s.config.getOrNull(SemanticsActions.ScrollBy)?.action?.invoke(0f, n.positionInRoot.y - s.boundsInRoot.top - 8f)
        frames(45)
    }
    fun dump(): String = nodes().mapNotNull { n -> text(n).takeIf { it.isNotBlank() }?.let { "${n.boundsInRoot.left.toInt()},${n.boundsInRoot.top.toInt()},${n.boundsInRoot.right.toInt()},${n.boundsInRoot.bottom.toInt()}\t$it" } }.joinToString("\n")
}

private fun bild512(name: String, setup: (GameViewModel) -> Unit, steps: Fahrer.(GameViewModel) -> Unit = {}) {
    System.getenv("ONLY")?.let { if (!name.startsWith(it)) return }
    if (System.getenv("WEITER") != null && File(aus512, "$name.png").exists()) return   // 882.1, wie shot()
    val vm = GameViewModel(Application())
    vm.ensureLang(dt)
    vm.prelude = false
    setup(vm)
    val scene = ImageComposeScene(BW, BH, Density(2.75f)) { BornimApp(vm) }
    val f = Fahrer(scene, name)
    try {
        f.frames(40)
        f.steps(vm)
        f.frames(20)
        File(aus512, "$name.png").writeBytes(f.img!!.encodeToData(EncodedImageFormat.PNG)!!.bytes)
        File(aus512, "$name.txt").writeText(f.dump() + "\n")
        println("wrote 512b/$name")
    } catch (e: Throwable) {
        println("FEHLER 512b/$name: ${e.message}")
        File(aus512, "$name.txt").writeText("FEHLER ${e.message}\n" + f.dump() + "\n")
    } finally {
        scene.close()
    }
    weiterVoll()
}

private fun mode(g: Game, m: Mode) {
    Game::class.java.getDeclaredField("mode").apply { isAccessible = true }.set(g, m)
}

/** The example hero of both sides: Thora, human fighter, level 3, day 3, 137 gold, a mixed bag, the quest begun, one job. */
fun held512(vm: GameViewModel, name: String = "Thora", race: Race = Race.HUMAN, cls: CharClass = CharClass.FIGHTER, into: Int? = null) {
    vm.newGame(name, race, cls, into = into)
    val g = vm.game!!
    g.skipDialogs()
    val s = g.state
    s.hero.gainXp(Rules.xpForLevel[3])
    s.inventory.clear()
    for ((id, n) in listOf("potion" to 3, "greater_potion" to 1, "herbs" to 2, "wolf_pelt" to 2)) s.add(id, n)
    s.bag.clear()
    s.addGear(Gear(0, "hood", Rarity.COMMON, 3))
    s.addGear(Gear(0, "greatsword", Rarity.UNCOMMON, 3, rolls = listOf(Roll(Affix.STR, 1))))
    s.addGear(Gear(0, "ring", Rarity.RARE, 3, rolls = listOf(Roll(Affix.DEX, 1), Roll(Affix.CON, 1))))
    s.gold = 137; s.day = 3; s.minutes = 14 * 60 + 20
    s.flags += listOf(Story.QUEST_STARTED, Story.BARRIER_OPEN, Story.KROGG_HINT, "job_tusks", "job_tusks_done")
    g.takeJob("pelts")
    s.hero.restoreFully()
    vm.save()
    vm.refresh()
}

private fun geoeffnet(vm: GameViewModel, test: Boolean = false, place: Place = Place("village", 17, 13, Facing.UP)) {
    held512(vm)
    val g = vm.game!!
    g.state.place = place
    g.mapChanged = true
    if (vm.testMode != test) vm.toggleTestMode()
    vm.refresh()
    vm.menuOpen = true
}

/** The world behind a window (rest, text) without the black screen of arrival. */
private fun dort(vm: GameViewModel, place: Place, minutes: Int) {
    held512(vm)
    val g = vm.game!!
    g.state.minutes = minutes; g.state.place = place
    de.bornim.game.ui.VeilMemory.game = g; de.bornim.game.ui.VeilMemory.map = place.map
    g.mapChanged = true; vm.refresh()
}

private fun laden512(vm: GameViewModel, brewing: Boolean = false) {
    held512(vm)
    val g = vm.game!!
    de.bornim.game.ui.ShopLook.previewTab = 0; de.bornim.game.ui.ShopLook.previewDialog = -1
    mode(g, Mode.Shop(if (brewing) listOf("potion", "greater_potion", "remedy", "stamina_potion", "holy_water") else Story.shopStock, brewing))
    vm.refresh()
}

fun menue512b() {
    for (b in de.bornim.core.GearBases.all) for (r in Rarity.entries) de.bornim.core.art.ItemArt.get(b.id, r)
    for (it in Items.all) de.bornim.core.art.SupplyArt.get(it.id)
    de.bornim.core.art.SupplyArt.get(de.bornim.core.art.SupplyArt.GOLD)
    de.bornim.game.ui.TypeLook.choice = 2
    val n = { id: String -> Items[id].name(dt) }

    // ---- Hauptmenü, Über
    bild512("01_hauptmenue_leer", { it.screen = Screen.MENU })
    bild512("02_hauptmenue_stand", { vm -> held512(vm); vm.toMenu() })
    bild512("03_hauptmenue_testmodus", { vm -> held512(vm); vm.toMenu(); if (!vm.testMode) vm.toggleTestMode() })
    bild512("04_ueber_oben", { it.screen = Screen.ABOUT })
    bild512("05_ueber_unten", { it.screen = Screen.ABOUT }) { scroll(100000f) }
    // 06_ueber_lizenzen: nur neu (Knopf „Lizenzen der Engine“)

    // ---- Spielstände
    val vier = { vm: GameViewModel ->
        held512(vm, into = 1)
        for ((i, h) in listOf(Triple("Mira", Race.ELF, CharClass.WIZARD), Triple("Borin", Race.DWARF, CharClass.CLERIC), Triple("Ilse", Race.HALFLING, CharClass.ROGUE)).withIndex()) {
            vm.newGame(h.first, h.second, h.third, into = i + 2); vm.game!!.skipDialogs(); vm.save()
        }
        vm.toMenu()
    }
    bild512("07_spielstaende_eins", { vm -> held512(vm); vm.toMenu(); vm.screen = Screen.SLOTS })
    bild512("08_spielstaende_voll", { vm -> vier(vm); vm.screen = Screen.SLOTS })
    bild512("09_spielstaende_loeschen", { vm -> held512(vm); vm.toMenu(); vm.screen = Screen.SLOTS }) { tapText("Löschen") }

    // ---- Erschaffung
    val neu = { vm: GameViewModel -> vm.screen = Screen.CREATE }
    bild512("10_erschaffung_oben", neu)
    for ((i, r) in listOf(Race.ELF, Race.DWARF, Race.HALFLING, Race.HALF_ORC).withIndex())
        bild512("1${i + 1}_erschaffung_volk_${r.name.lowercase()}", neu) { tapText(r.title(dt)) }
    bild512("15_erschaffung_aussehen", neu) { tapText(de.bornim.core.Sex.FEMALE.title(dt)); tapText(de.bornim.core.Build.STRONG.title(dt)); scrollTo("Aussehen", '=', 0) }
    for ((i, c) in listOf(CharClass.WIZARD, CharClass.ROGUE, CharClass.CLERIC).withIndex())
        bild512("1${i + 6}_erschaffung_klasse_${c.name.lowercase()}", neu) { tapText(c.title(dt)); scrollTo(Ui.chooseClass(dt), '=', 0) }
    bild512("19_erschaffung_punkte", neu) { scrollTo("Attribute verteilen", '~', 0) }
    bild512("20_erschaffung_unten", neu) { scroll(100000f) }
    bild512("21_erschaffung_platzwahl", { vm -> vier(vm); vm.pendingSlot = null; vm.screen = Screen.CREATE }) { tapText(Ui.start(dt)) }
    // 22–24 Erschaffung nach BRS: nur neu

    // ---- Spielermenü (Reiter über ihre Namen, die Zeichen tragen sie als Beschreibung)
    val m = { vm: GameViewModel -> geoeffnet(vm) }
    bild512("25_held_oben", m)
    bild512("26_held_unten", m) { scroll(100000f) }
    bild512("27_held_erklaerung", m) { tapText(de.bornim.core.Ability.STR.full(dt)) }
    val punkte = { vm: GameViewModel -> geoeffnet(vm); vm.game!!.hero.unspentPoints = 2; vm.refresh() }
    bild512("28_held_punkte", punkte) { tapText("+", '=', 0) }
    bild512("29_held_verteilen", punkte) { tapText("+", '=', 0); tapText("Übernehmen") }
    bild512("30_tasche_oben", m) { tapText(Ui.bag(dt)) }
    bild512("31_tasche_unten", m) { tapText(Ui.bag(dt)); scroll(100000f) }
    bild512("32_tasche_trank", m) { tapText(Ui.bag(dt)); tapText(n("potion")) }
    bild512("33_tasche_pelz", m) { tapText(Ui.bag(dt)); tapText(n("wolf_pelt")) }
    val schwert = { vm: GameViewModel -> vm.game!!.state.bag.first { it.base == "greatsword" }.name(dt) }
    bild512("34_tasche_stueck", m) { vm -> tapText(Ui.bag(dt)); tapText(schwert(vm), '<') }
    bild512("35_tasche_wegwerfen", m) { vm -> tapText(Ui.bag(dt)); tapText(schwert(vm), '<'); tapText("Wegwerfen") }
    bild512("36_tasche_leer", { vm -> geoeffnet(vm); vm.game!!.state.inventory.clear(); vm.game!!.state.bag.clear(); vm.refresh() }) { tapText(Ui.bag(dt)) }
    bild512("37_ausruestung", m) { tapText(Ui.equipment(dt)) }
    bild512("38_ausruestung_fach", m) { tapText(Ui.equipment(dt)); tapText(de.bornim.core.GearSlot.MAIN_HAND.title(dt)) }
    bild512("39_ausruestung_wechsel", m) { tapText(Ui.equipment(dt)); tapText(de.bornim.core.GearSlot.MAIN_HAND.title(dt)); tapText("Wechseln") }
    bild512("40_ausruestung_wechsel_stueck", m) { vm -> tapText(Ui.equipment(dt)); tapText(de.bornim.core.GearSlot.MAIN_HAND.title(dt)); tapText("Wechseln"); tapText(schwert(vm), '<') }
    bild512("41_ausruestung_leerplatz", m) { tapText(Ui.equipment(dt)); tapText(de.bornim.core.GearSlot.AMULET.title(dt)) }
    bild512("42_karte", m) { tapText("Karte") }
    bild512("43_chronik", m) { tapText("Chronik") }
    bild512("44_chronik_erledigt", m) { tapText("Chronik"); tapText("Erledigt", '<') }
    bild512("45_chronik_bisher", m) { tapText("Chronik"); tapText("Bisher geschehen") }
    bild512("46_system_oben", m) { tapText(Ui.system(dt)) }
    bild512("47_system_unten", m) { tapText(Ui.system(dt)); scroll(100000f) }
    de.bornim.game.ui.MenuExplain.preview = "Tempo"
    bild512("48_system_erklaerung", m) { tapText(Ui.system(dt)) }
    de.bornim.game.ui.MenuExplain.preview = null
    bild512("49_system_anleitung", { vm -> held512(vm); vm.guide = true; vm.refresh() })
    val t = { vm: GameViewModel -> geoeffnet(vm, test = true) }
    bild512("50_test_oben", t) { tapText("Test") }
    bild512("51_test_unten", t) { tapText("Test"); scroll(100000f) }

    // ---- Laden (Thessa) und Morwen
    val shop = { vm: GameViewModel -> laden512(vm) }
    val gearKauf = { vm: GameViewModel -> vm.game!!.shopGear().first { vm.game!!.hero.canWear(it) }.name(dt) }
    bild512("52_laden_kaufen", shop)
    bild512("53_laden_kaufen_unten", shop) { scroll(100000f) }
    bild512("54_laden_menge_kauf", shop) { tapText(n("potion")) }
    bild512("55_laden_stueck_kauf", shop) { vm -> tapText(gearKauf(vm), '~') }
    bild512("56_laden_verkaufen", shop) { tapText(Ui.sell(dt)) }
    bild512("57_laden_verkaufen_unten", shop) { tapText(Ui.sell(dt)); scroll(100000f) }
    bild512("58_laden_menge_verkauf", shop) { tapText(Ui.sell(dt)); tapText(n("wolf_pelt"), '<') }
    bild512("59_laden_alle_verkaufen_frage", shop) { tapText(Ui.sell(dt)); tapText(n("wolf_pelt"), '<'); tapText("Alle"); tapText(Ui.sell(dt), '<') }
    bild512("60_laden_gewoehnliche_frage", shop) { tapText(Ui.sell(dt)); tapText("Gewöhnliche verkaufen") }
    val ring = { vm: GameViewModel -> vm.game!!.state.bag.first { it.base == "ring" }.name(dt) }
    bild512("61_laden_verkauf_selten_frage", shop) { vm -> tapText(Ui.sell(dt)); tapText(ring(vm), '~'); tapText(Ui.sell(dt) + " ·", '<') }
    bild512("62_laden_zurueckkaufen", { vm -> laden512(vm); vm.game!!.sell("wolf_pelt", 1); vm.game!!.sellGear(vm.game!!.state.bag.first { it.base == "hood" }); vm.refresh() }) { tapText(Ui.sell(dt)) }
    val morwen = { vm: GameViewModel -> laden512(vm, brewing = true) }
    bild512("63_morwen_kaufen", morwen)
    bild512("64_morwen_brauen", morwen) { tapText("Brauen") }
    bild512("65_morwen_brauen_fenster", morwen) { tapText("Brauen"); tapText(n(de.bornim.core.Recipes.all.first().output), '<') }

    // ---- Rast
    val feuer = { vm: GameViewModel -> dort(vm, Place("forest", 10, 9, Facing.RIGHT), 20 * 60); mode(vm.game!!, Mode.Rest(Resting.Spot.FIRE)); vm.refresh() }
    bild512("66_rast_feuer", feuer)
    bild512("67_rast_feuer_lang_vergeben", { vm -> feuer(vm); vm.game!!.state.longRestDay = vm.game!!.state.day; vm.refresh() })
    val schenke = { vm: GameViewModel -> dort(vm, Place("inn", 1, 3, Facing.UP), 20 * 60); mode(vm.game!!, Mode.Rest(Resting.Spot.TAVERN)); vm.refresh() }
    bild512("68_rast_schenke", schenke)
    bild512("69_rast_schenke_met", schenke) { vm -> tapText(Resting.meadBuy.f(dt, Resting.meadPrice(vm.game!!.state))) }
    bild512("70_rast_zimmer", { vm -> dort(vm, Place("inn", 8, 3, Facing.UP), 21 * 60); mode(vm.game!!, Mode.Rest(Resting.Spot.ROOM)); vm.refresh() })

    // ---- Anschlagbrett
    val brett = { vm: GameViewModel -> dort(vm, Place("village", 5, 7, Facing.LEFT), 12 * 60); mode(vm.game!!, Mode.Board); vm.refresh() }
    bild512("71_brett", brett)
    bild512("72_brett_angenommen", brett) { tapText("Annehmen", '=', 0) }
    bild512("73_brett_leer", { vm -> brett(vm); vm.game!!.state.flags += listOf("job_pelts_done", "job_ring_done", "job_tusks_done"); vm.refresh() })

    // ---- Textkasten, Kapitelende
    val text = { vm: GameViewModel, wer: String?, satz: String -> dort(vm, Place("inn", 4, 5, Facing.UP), 12 * 60); mode(vm.game!!, Mode.Dialog(wer, satz)); vm.refresh() }
    bild512("74_text_sprecher", { vm -> text(vm, "Jäger Garrick", "Und ehrlich, Thora: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald, dann reden wir weiter.") })
    bild512("75_text_erzaehlt", { vm -> text(vm, null, "Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit.") })
    bild512("76_kapitelende", { vm -> held512(vm); mode(vm.game!!, Mode.ChapterEnd); vm.refresh() })
}
