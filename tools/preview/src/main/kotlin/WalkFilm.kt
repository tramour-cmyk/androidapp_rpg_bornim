package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Mode
import de.bornim.core.Place
import de.bornim.core.Race
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/**
 * WALKFILM=map:x:y: walks the hero through the real map screen with the touch stick — left, down,
 * right, up, through tall grass and over the path — and saves a picture every 80 ms (real time of
 * the game clock), cut to the hero's surroundings, under build/screens/films/walk/.
 */
@OptIn(ExperimentalComposeUiApi::class)
fun walkFilm(spec: String) {
    val p = spec.split(":")
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    val map = p.getOrElse(0) { "forest" }
    g.state.place = Place(map, p.getOrElse(1) { "9" }.toInt(), p.getOrElse(2) { "12" }.toInt(), Facing.UP)
    g.state.minutes = 12 * 60
    val m = de.bornim.core.World[map]
    g.state.explored[map] = "f".repeat((m.width * m.height + 3) / 4)
    de.bornim.core.art.MapGround.prepareNow(m)
    // NOPREP: as on the phone, the dolls are drawn in the background while the film runs
    if (System.getenv("NOPREP") == null) {
        de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
        de.bornim.core.art.MapFolk.prepareNow(de.bornim.core.art.MapFolk.garrick)
    }
    vm.refresh()
    val W = 1080; val H = 2340
    val scene = ImageComposeScene(W, H, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/walk"); dir.deleteRecursively(); dir.mkdirs()
    var time = 0L
    var n = 0
    val frameNs = 16_000_000L
    fun run(ms: Int, save: Boolean = true) {
        var t = 0
        while (t < ms) {
            val img = scene.render(time)
            if (save && t % 80 < 16) {
                val bytes = img.encodeToData(EncodedImageFormat.PNG)!!.bytes
                File(dir, "f%03d.png".format(n++)).writeBytes(bytes)
            }
            time += frameNs; t += 16
            Thread.sleep(2)
        }
    }
    run(800, false)
    val c = Offset(540f, 1500f)
    scene.sendPointerEvent(PointerEventType.Press, c)
    run(50, false)
    for ((dx, dy) in listOf(-140f to 0f, 0f to 140f, 140f to 0f, 0f to -140f)) {
        scene.sendPointerEvent(PointerEventType.Move, c + Offset(dx, dy))
        run(System.getenv("WALKMS")?.toInt() ?: 1400)
    }
    scene.sendPointerEvent(PointerEventType.Release, c)
    run(600)
    scene.close()
    println("wrote walk film ($n pictures)")
}

/**
 * IDLEFILM=map:x:y:seconds:minutes: the hero stands still at (x, y) while the folk nearby go about
 * their idle loops; a picture every 250 ms under build/screens/films/idle/.
 */
@OptIn(ExperimentalComposeUiApi::class)
fun idleFilm(spec: String) {
    val p = spec.split(":")
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    val map = p.getOrElse(0) { "forest" }
    g.state.place = Place(map, p.getOrElse(1) { "10" }.toInt(), p.getOrElse(2) { "14" }.toInt(), Facing.UP)
    g.state.minutes = p.getOrElse(4) { "${12 * 60}" }.toInt()
    val m = de.bornim.core.World[map]
    g.state.explored[map] = "f".repeat((m.width * m.height + 3) / 4)
    de.bornim.core.art.MapGround.prepareNow(m)
    de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
    de.bornim.core.art.MapFolk.prepareNow(de.bornim.core.art.MapFolk.garrick)
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/idle"); dir.deleteRecursively(); dir.mkdirs()
    var time = 0L
    var n = 0
    val total = p.getOrElse(3) { "24" }.toInt() * 1000
    var t = 0
    while (t < total) {
        val img = scene.render(time)
        if (t % 250 < 40) File(dir, "f%03d.png".format(n++)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
        img.close()
        time += 40_000_000L; t += 40
    }
    scene.close()
    println("wrote idle film ($n pictures)")
}
