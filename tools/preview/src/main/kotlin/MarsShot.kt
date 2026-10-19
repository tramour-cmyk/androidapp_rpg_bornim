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
    val out = File("build/screens/mars211").apply { deleteRecursively(); mkdirs() }
    val secs = System.getenv("MARS211SEK")?.toInt() ?: 14
    for ((tag, size) in listOf("a56" to Triple(412, 892, 2.625f), "klein" to Triple(360, 740, 2f))) {
        val (wdp, hdp, d) = size
        val vm = GameViewModel(Application())
        vm.ensureLang(Lang.DE)
        vm.newGame("Mira", Race.HUMAN, CharClass.CLERIC)
        vm.game!!.skipDialogs()
        vm.probeFoe = Skirmish.Companion.ProbeFoe.valueOf(spec.uppercase())
        vm.startProbe(CharClass.FIGHTER)
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
