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
 * 72.10: films the probe against Grak through the real UI (PROBE=held:söldner, e.g. fighter:rogue; PROBELEVEL=3).
 * PROBETAPS=x,y,ms[,L];x,y,ms;… taps (L: a long press) at (x, y) of the 540 × 1170 screen after waiting ms each; frames every 80 ms into
 * build/screens/probe (PROBESAVE=all, else only every fifth and those right after a tap).
 */
@OptIn(ExperimentalComposeUiApi::class)
fun probeFilm(spec: String) {
    val (heroCls, mercCls) = spec.split(":").map { CharClass.valueOf(it.uppercase()) }
    val out = File("build/screens/probe").apply { deleteRecursively(); mkdirs() }
    val vm = GameViewModel(Application())
    vm.newGame("Test", Race.HUMAN, heroCls)
    val g = vm.game!!
    System.getenv("PROBELEVEL")?.toInt()?.let { lv -> g.state.hero.gainXp(Rules.xpForLevel[lv] - g.state.hero.xp); g.state.hero.hp = g.state.hero.maxHp }
    vm.startProbe(mercCls)
    val scene = ImageComposeScene(540, 1170, Density(1.375f)) { BornimApp(vm) }
    val t0 = System.nanoTime()
    var n = 0
    val all = System.getenv("PROBESAVE") == "all"
    fun frames(ms: Long, tag: String) {
        val until = System.nanoTime() + ms * 1_000_000L
        var k = 0
        while (System.nanoTime() < until) {
            val begun = System.nanoTime()
            val img = scene.render(begun - t0)
            if (all || k % 5 == 0 || k < 3) File(out, "p_%03d_%s_%05d.png".format(n++, tag, (begun - t0) / 1_000_000L)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
            k++
            Thread.sleep(maxOf(0L, 80L - (System.nanoTime() - begun) / 1_000_000L))
        }
    }
    frames(4000, "w")
    for ((i, t) in (System.getenv("PROBETAPS") ?: "").split(";").filter { it.isNotBlank() }.withIndex()) {
        val (x, y, ms) = t.split(",")
        val at = Offset(x.toFloat(), y.toFloat())
        scene.sendPointerEvent(PointerEventType.Press, at)
        // a fourth field "L": a long press (204)
        if (t.split(",").getOrNull(3) == "L") frames(800, "l$i")
        scene.sendPointerEvent(PointerEventType.Release, at)
        frames(ms.toLong(), "t$i")
    }
    scene.close()
    println("probe film: $n frames in ${out.path}")
}
