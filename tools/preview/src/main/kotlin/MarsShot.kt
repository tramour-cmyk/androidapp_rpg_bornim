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
    for ((tag, size) in listOf("a56" to Triple(412, 892, 2.625f), "klein" to Triple(360, 740, 2f))) {
        if (only != null && only != tag) continue
        val (wdp, hdp, d) = size
        val vm = GameViewModel(Application())
        vm.ensureLang(Lang.DE)
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
