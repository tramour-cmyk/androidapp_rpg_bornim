package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.*
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/**
 * 211: the MARS screen on the Samsung A56 (412 × 892 dp) and a small phone (360 × 740 dp): MARS211=foes (grak, wolves,
 * spider, scout), hero a cleric, Söldner a fighter on automatic; the autopilot plays the hero, a picture every second
 * into build/screens/mars211 (MARS211SEK= seconds, 14 by default).
 */
@OptIn(ExperimentalComposeUiApi::class)
fun marsShot(spec: String) {
    val out = File("build/screens/mars211" + (System.getenv("MARS211BESCHRIFTUNG")?.let { "_$it" } ?: "")).apply { deleteRecursively(); mkdirs() }
    val only = System.getenv("MARS211FORMAT")
    val secs = System.getenv("MARS211SEK")?.toInt() ?: 14
    // 249: MARS211FILM=von-bis (Sekunden) every frame in that time, one each MARS211TAKT ms (40 by default)
    val film = System.getenv("MARS211FILM")?.split("-")?.let { it[0].toDouble() to it[1].toDouble() }
    // 249: MARS211ZEITLUPE=n glides and blows n times slower
    de.bornim.game.ui.MarsLayout.slow = System.getenv("MARS211ZEITLUPE")?.toLong() ?: 1L
    // 320: MARS211RING=GOOD|PERFECT|NONE the party's turns played by themselves and each ring answered so (no autopilot)
    de.bornim.game.ui.MarsLayout.probeRing = System.getenv("MARS211RING")?.let { de.bornim.core.Reaction.valueOf(it) }
    // 249: steps, zoom and blood as on the pictures for the Chef; MARS211OHNE249=1 as in the build
    de.bornim.game.ui.MarsLayout.look249 = System.getenv("MARS211OHNE249") == null
    // and the spell effects with them
    de.bornim.game.ui.BattlePace.factor = de.bornim.game.ui.MarsLayout.slow.toDouble()
    val tick = if (film != null) System.getenv("MARS211TAKT")?.toLong() ?: 40L else 100L
    // 211: MARS211BESCHRIFTUNG=A|B|C|D: names over (A, C) or under (B, D), bars for all (A, B) or foes only (C, D); C chosen (211.8)
    System.getenv("MARS211BESCHRIFTUNG")?.let { v ->
        de.bornim.game.ui.MarsLabels.below = v in "BD"; de.bornim.game.ui.MarsLabels.barsOnlyFoes = v in "CD"
    }
    // 211.10: MARS211VERSATZ=1 sets the two of a row apart across the line of the fight; MARS211LINIEN=1 draws the guides
    de.bornim.game.ui.MarsLayout.offset = System.getenv("MARS211VERSATZ") != null
    de.bornim.game.ui.MarsLayout.guides = System.getenv("MARS211LINIEN") != null
    // 242: MARS211RINGE=1 each hero's ring in its color instead of the triangles
    de.bornim.game.ui.MarsLayout.heroRings = System.getenv("MARS211RINGE") != null
    // 242: MARS211SCHATTEN=hart the old hard oval under the figures, for comparison
    de.bornim.game.ui.MarsLayout.hardShadow = System.getenv("MARS211SCHATTEN") == "hart"
    de.bornim.game.ui.MarsLayout.straight = System.getenv("MARS211GERADE") != null
    // 211.10: MARS211WOLFKAMERA=pitch[,yaw] the battle animals from higher above, and turned
    System.getenv("MARS211WOLFKAMERA")?.split(",")?.let { c -> de.bornim.core.art.BeastArt.pitch = c[0].toDouble(); de.bornim.core.art.BeastArt.yaw = c.getOrNull(1)?.toDouble() }
    // 211.13: MARS211STILL=1 the Kampfort and its figures from the pattern's one camera (MUSTER211… as for the pattern)
    if (System.getenv("MARS211STILL") != null) de.bornim.game.ui.MarsLayout.still = object : de.bornim.game.ui.MarsStill {
        override fun draw(w: Int, h: Int, sk: Skirmish, places: Map<String, Spot>): de.bornim.game.ui.MarsStill.Shot {
            val near = System.getenv("MUSTER211NAH")?.toDouble() ?: 0.0
            var wolf = 0
            val stands = sk.fighters.filter { it.hp > 0 && places[it.id] != null }.map { f ->
                val sp = places[f.id]!!
                val alone = sk.fighters.count { it.side == f.side && it.hp > 0 && places[it.id]?.row == sp.row } <= 1
                val row = if (sp.row == Row.FRONT) FRONT_M else BACK_M
                val b = if (alone) 0.0 else if (sp.slot == 0) -HALF_M else HALF_M
                if (f.side == Side.PARTY) Stand(-row - near, b, f.looks, id = f.id) else Stand(row, b, wolf = wolf++, id = f.id)
            }
            val pic = draw(w, h, true, false, "", w / 412.0, stands, still = true)
            val px = IntArray(w * h).also { pic.img.getRGB(0, 0, w, h, it, 0, w) }
            return de.bornim.game.ui.MarsStill.Shot(de.bornim.core.art.PixelImage(w, h, px),
                pic.feet.mapValues { (_, p) -> (p.first / w).toFloat() to (p.second / h).toFloat() }, pic.tall.mapValues { it.value.toFloat() })
        }
    }
    for ((tag, size) in listOf("a56" to Triple(412, 892, 2.625f), "klein" to Triple(360, 740, 2f))) {
        if (only != null && only != tag) continue
        val (wdp, hdp, d) = size
        val vm = GameViewModel(Application())
        vm.ensureLang(Lang.DE)
        de.bornim.game.ui.MarsLayout.gridSwitch = true
        // 272: MARS211TEST=1 test mode on, so the signs "lose/win at once" show
        if ((System.getenv("MARS211TEST") != null) != vm.testMode) vm.toggleTestMode()
        // 229.1: MARS211RASTER=1 the grid on, as by the grid sign
        if ((System.getenv("MARS211RASTER") != null) != vm.showGrid) vm.toggleGrid()
        // 232: MARS211NAME= another name for the hero (twelve letters at most, as at the start of a game)
        // 336: MARS211HELD=, MARS211SOELDNER= the classes of hero and Söldner (CLERIC and FIGHTER by default)
        val mercCls = System.getenv("MARS211SOELDNER")?.let { CharClass.valueOf(it) } ?: CharClass.FIGHTER
        vm.newGame(System.getenv("MARS211NAME") ?: "Mira", Race.HUMAN, System.getenv("MARS211HELD")?.let { CharClass.valueOf(it) } ?: CharClass.CLERIC)
        // 249: MARS211BLUT=0|1|2 the blood setting (off, subtle, full)
        System.getenv("MARS211BLUT")?.let { vm.changeBlood(it.toInt()) }
        vm.game!!.skipDialogs()
        vm.probeFoe = Skirmish.Companion.ProbeFoe.valueOf(spec.uppercase())
        // 259: MARS211STUFE= the level of hero and Söldner, as in the test tab (8 against wolves: a light fight, half damage)
        System.getenv("MARS211STUFE")?.let { vm.probeLevel = it.toInt() }
        vm.startProbe(mercCls)
        // MARS211SEED= the same dice in every run, so variants show the same fight
        System.getenv("MARS211SEED")?.let { vm.probe = Skirmish.probe(vm.game!!.state, mercCls, Lang.DE, vm.probeFoe, Dice(kotlin.random.Random(it.toInt())), vm.probeLevel) }
        // 336: MARS211SOELDNERSELBST=1 the Söldner steered by the player, so his rings are answered as MARS211RING says
        vm.probe!!.byId("merc").auto = System.getenv("MARS211SOELDNERSELBST") == null
        // 249: MARS211HELDAUTO=1 the hero on automatic from the start
        if (System.getenv("MARS211HELDAUTO") != null) vm.probe!!.setAutopilot(true)
        // 211.7: MARS211HINTEN=1 sets the Söldner behind the hero, both alone in their rows
        if (System.getenv("MARS211HINTEN") != null) vm.probe!!.byId("merc").place = Spot(Row.BACK, 0)
        // 242.3: MARS211EINZELN=1 the second foe of the front row already down, so one stands alone before the one behind
        if (System.getenv("MARS211EINZELN") != null) vm.probe!!.fighters.firstOrNull { it.side == Side.FOES && it.place == Spot(Row.FRONT, 1) }?.let { f -> Fighter::class.java.getDeclaredField("hp").apply { isAccessible = true }.setInt(f, 0) }
        // 249: MARS211LETZT=1 every foe on 1 hit point, so the first blow that lands is the last (zoom, jolt)
        if (System.getenv("MARS211LETZT") != null) vm.probe!!.fighters.filter { it.side == Side.FOES }.forEach { f -> Fighter::class.java.getDeclaredField("hp").apply { isAccessible = true }.setInt(f, 1) }
        val w = (wdp * d).toInt(); val h = (hdp * d).toInt()
        val scene = ImageComposeScene(w, h, Density(d)) { BornimApp(vm) }
        val t0 = System.nanoTime()
        de.bornim.game.ui.MarsLayout.onHit = { println("mars211: %.2f s %s".format((System.nanoTime() - t0) / 1e9, it)) }
        var tapped = false
        var s = 0
        // 249: MARS211TIPPS=sek:x:y,… taps at those seconds on those points (dp)
        val taps = System.getenv("MARS211TIPPS")?.split(",")?.map { it.split(":").map(String::toDouble) }?.toMutableList() ?: mutableListOf()
        while (System.nanoTime() - t0 < secs * 1_000_000_000L) {
            val img = scene.render(System.nanoTime() - t0)
            val sec = (System.nanoTime() - t0) / 1e9
            if (film != null && sec >= film.first && sec <= film.second) File(out, "${tag}_f%05d.png".format((sec * 1000).toInt())).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
            taps.firstOrNull { sec >= it[0] }?.let { tp ->
                taps.remove(tp)
                val at = Offset((tp[1] * d).toFloat(), (tp[2] * d).toFloat())
                scene.sendPointerEvent(PointerEventType.Press, at); scene.render(System.nanoTime() - t0)
                scene.sendPointerEvent(PointerEventType.Release, at)
                File(out, "${tag}_tipp%05d.png".format((sec * 1000).toInt())).writeBytes(scene.render(System.nanoTime() - t0).encodeToData(EncodedImageFormat.PNG)!!.bytes)
            }
            if (sec >= 3.0 && !tapped && System.getenv("MARS211HELDAUTO") == null && System.getenv("MARS211TEST") == null && System.getenv("MARS211RING") == null) {
                // the autopilot, the last button of the lower row
                val at = Offset(w - 40 * d, h - 34 * d)
                scene.sendPointerEvent(PointerEventType.Press, at); scene.render(System.nanoTime() - t0)
                scene.sendPointerEvent(PointerEventType.Release, at); tapped = true
            }
            if (film == null && s % 10 == 9) File(out, "${tag}_%02d.png".format(s / 10)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
            s++
            Thread.sleep(tick)
        }
        scene.close()
        // 259: where the fight stands at the end, to check "Schnell" without reading the pictures
        vm.probe?.let { sk -> println("mars211: Ausgang ${sk.outcome}, begonnen ${sk.started}, Held ${sk.byId("hero").hp}/${sk.byId("hero").maxHp}") }
    }
    println("mars211: ${out.listFiles()!!.size} pictures in ${out.path}")
}
