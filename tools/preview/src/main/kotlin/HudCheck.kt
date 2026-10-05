package preview

import android.app.Application
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.unit.Density
import de.bornim.core.CharClass
import de.bornim.core.Cmd
import de.bornim.core.Mode
import de.bornim.core.Race
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/** Regression check: the HP chip must update after healing on the world screen. */
fun hudCheck() {
    val vm = GameViewModel(Application())
    vm.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    while (g.mode is Mode.Dialog) g.advance()
    g.hero.hp = 5
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    var t = 0L
    fun frames(n: Int) = repeat(n) { scene.render(t); t += 33_000_000L; Thread.sleep(20) }
    frames(20)
    File("build/screens/hud_before.png").writeBytes(scene.render(t).encodeToData(EncodedImageFormat.PNG)!!.bytes)
    // Same as resting at a campfire or with the priest.
    g.enqueue(listOf(Cmd.Rest))
    vm.refresh()
    frames(20)
    File("build/screens/hud_after.png").writeBytes(scene.render(t).encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("hud check done")
}
