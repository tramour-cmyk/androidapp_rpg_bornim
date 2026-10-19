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
    // 211: MARS211BESCHRIFTUNG=A|B|C|D: names over (A, C) or under (B, D), bars for all (A, B) or foes only (C, D); C chosen (211.8)
    System.getenv("MARS211BESCHRIFTUNG")?.let { v ->
        de.bornim.game.ui.MarsLabels.below = v in "BD"; de.bornim.game.ui.MarsLabels.barsOnlyFoes = v in "CD"
    }
    // 211.10: MARS211VERSATZ=1 sets the two of a row apart across the line of the fight; MARS211LINIEN=1 draws the guides
    de.bornim.game.ui.MarsLayout.offset = System.getenv("MARS211VERSATZ") != null
    de.bornim.game.ui.MarsLayout.guides = System.getenv("MARS211LINIEN") != null
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
        // 229.1: MARS211RASTER=1 the grid on, as by the grid sign
        if ((System.getenv("MARS211RASTER") != null) != vm.showGrid) vm.toggleGrid()
        vm.newGame("Mira", Race.HUMAN, CharClass.CLERIC)
        vm.game!!.skipDialogs()
        vm.probeFoe = Skirmish.Companion.ProbeFoe.valueOf(spec.uppercase())
        vm.startProbe(CharClass.FIGHTER)
        // MARS211SEED= the same dice in every run, so variants show the same fight
        System.getenv("MARS211SEED")?.let { vm.probe = Skirmish.probe(vm.game!!.state, CharClass.FIGHTER, Lang.DE, vm.probeFoe, Dice(kotlin.random.Random(it.toInt()))) }
        vm.probe!!.byId("merc").auto = true
        // 211.7: MARS211HINTEN=1 sets the Söldner behind the hero, both alone in their rows
        if (System.getenv("MARS211HINTEN") != null) vm.probe!!.byId("merc").place = Spot(Row.BACK, 0)
        val w = (wdp * d).toInt(); val h = (hdp * d).toInt()
        val scene = ImageComposeScene(w, h, Density(d)) { BornimApp(vm) }
        val t0 = System.nanoTime()
        var tapped = false
        for (s in 0 until secs * 10) {
            val img = scene.render(System.nanoTime() - t0)
            if (s == 30 && !tapped) {
                // the autopilot, the last button of the lower row
                val at = Offset(w - 40 * d, h - 34 * d)
                scene.sendPointerEvent(PointerEventType.Press, at); scene.render(System.nanoTime() - t0)
                scene.sendPointerEvent(PointerEventType.Release, at); tapped = true
            }
            if (s % 10 == 9) File(out, "${tag}_%02d.png".format(s / 10)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
            Thread.sleep(100)
        }
        scene.close()
    }
    println("mars211: ${out.listFiles()!!.size} pictures in ${out.path}")
}
