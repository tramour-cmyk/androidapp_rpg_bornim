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
 * BLENDEFILM=1 (24.1): the black screen between places through the real map screen: start of play in the inn,
 * out to the village (first visit), back in (a door, all drawn: a blink), out again, then to the forest with
 * nothing drawn yet. A picture every 80 ms under build/screens/films/veil/, the scene number in the name.
 * As on the phone, the pictures of a new place are drawn in the background while the film runs.
 */
fun veilFilm() {
    val vm = GameViewModel(Application())
    vm.ensureLang(de.bornim.core.Lang.DE)
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    de.bornim.game.ui.MapSight.follow()
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
    println("start: ${g.state.place.map}, mode ${g.mode::class.simpleName}")
    for ((tag, place) in listOf(
        "2dorf" to Place("village", 6, 7, Facing.DOWN),
        "3gasthaus" to Place("inn", 5, 6, Facing.UP),
        "4dorf" to Place("village", 6, 7, Facing.DOWN),
        "5wald" to Place("forest", 10, 20, Facing.UP),
    )) {
        g.skipDialogs()
        g.cheatWarp(place)
        vm.refresh()
        println("$tag at picture $n: ${g.state.place.map}, mode ${g.mode::class.simpleName}")
        run(tag, 4_400)
    }
    scene.close()
}

/**
 * LADEBALKEN=1 (267.1): the black screen of the start of play with the loading bar, as drafts for the Chef: the bar
 * early, half and nearly full, with and without the count, under build/screens/ladebalken/.
 */
fun loadBarDraft() {
    val vm = GameViewModel(Application())
    vm.ensureLang(de.bornim.core.Lang.DE)
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    val line = de.bornim.core.Interlude.pick(de.bornim.core.Interlude.placeLines("inn", g.state, false), null)?.invoke(g.lang)
    val name = g.map.name(g.lang)
    val dir = File("build/screens/ladebalken"); dir.deleteRecursively(); dir.mkdirs()
    for (count in listOf(true, false)) for (done in listOf(14, 77, 151)) {
        val scene = ImageComposeScene(1080, 2340, Density(2.75f)) {
            de.bornim.game.ui.InterludeVeil(name, line, 1f, 1f, parts = done to 160, count = count)
        }
        val img = scene.render(0)
        saveFilmPicture(img, File(dir, "%s_%03d.png".format(if (count) "zahl" else "ohne", done)))
        img.close(); scene.close()
    }
}
