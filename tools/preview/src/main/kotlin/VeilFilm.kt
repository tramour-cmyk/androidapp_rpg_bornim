package preview

import android.app.Application
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.unit.Density
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Mode
import de.bornim.core.Place
import de.bornim.core.Race
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import java.io.File

/**
 * BLENDEFILM=1 (24.1): the black screen between places through the real map screen: start of play in the village,
 * into the inn (first visit), back out (a door, all drawn: a blink), into the inn again, then to the forest with
 * nothing drawn yet. A picture every 80 ms under build/screens/films/veil/, the scene number in the name.
 * As on the phone, the pictures of a new place are drawn in the background while the film runs.
 */
fun veilFilm() {
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    de.bornim.game.ui.MapSight.diagonal = true
    g.state.minutes = 12 * 60
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/veil"); dir.deleteRecursively(); dir.mkdirs()
    var time = 0L
    var n = 0
    fun run(tag: String, ms: Int) {
        var t = 0
        while (t < ms) {
            val img = scene.render(time)
            saveFilmPicture(img, File(dir, "%s_f%03d.png".format(tag, n++)))
            img.close()
            time += 80 * 1_000_000L; t += 80
            // the real time the background needs to draw goes by as on a phone
            Thread.sleep(80)
        }
    }
    run("1start", 4_400)
    for ((tag, place) in listOf(
        "2gasthaus" to Place("inn", 5, 6, Facing.UP),
        "3dorf" to Place("village", 6, 7, Facing.DOWN),
        "4gasthaus" to Place("inn", 5, 6, Facing.UP),
        "5wald" to Place("forest", 10, 20, Facing.UP),
    )) {
        g.cheatWarp(place)
        vm.refresh()
        println("$tag at picture $n")
        run(tag, 4_400)
    }
    scene.close()
}
