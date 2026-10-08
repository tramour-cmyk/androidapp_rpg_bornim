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
 * Films a fight through the real UI in real time: a frame every ~80 ms after each tap, for checking that the hero's
 * moves run as meant (FILM=cleric:zombie, FILMWAIT=ms before the first tap, FILMSEED=dice seed).
 */
@OptIn(ExperimentalComposeUiApi::class)
fun fightFilm(spec: String) {
    val (clsName, foe) = spec.split(":")
    val out = File("build/screens/film").apply { deleteRecursively(); mkdirs() }
    val vm = GameViewModel(Application())
    vm.newGame("Test", Race.HUMAN, CharClass.valueOf(clsName.uppercase()))
    if (System.getenv("FILMAUTO") != null && !vm.battleAuto) vm.toggleBattleAuto()
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    System.getenv("FILMLEVEL")?.toInt()?.let { g.state.hero.gainXp(Rules.xpForLevel[it]); g.state.hero.restoreFully() }
    g.state.place = Place("forest", 10, 20, Facing.UP); g.state.minutes = 12 * 60
    val seed = System.getenv("FILMSEED")?.toInt() ?: 1
    val battle = Battle(g.state, Monsters[foe], g.lang, Dice(kotlin.random.Random(seed)), 1, false, 1, null, false, MonsterLook(seed))
    g.fight(battle)
    vm.refresh()
    val scene = ImageComposeScene(540, 1170, Density(1.375f)) { BornimApp(vm) }
    var time = 0L
    var n = 0
    fun frames(k: Int, tag: String, save: Boolean) = repeat(k) {
        val img = scene.render(time); time += 80_000_000L
        if (save) File(out, "f_%03d_%s.png".format(n++, tag)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
        Thread.sleep(80)
    }
    val wait = (System.getenv("FILMWAIT")?.toLong() ?: 4000L) / 80
    frames(wait.toInt(), "w", false)
    // F: Fight, A: Attack, D: Defend, S: the scene (next message)
    val where = mapOf('F' to Offset(135f, 990f), 'A' to Offset(150f, 940f), 'D' to Offset(390f, 940f), 'S' to Offset(270f, 400f), 'B' to Offset(150f, 1085f), 'I' to Offset(270f, 935f), 'K' to Offset(390f, 990f))
    val plan = System.getenv("FILMTAPS") ?: "FASSSS"
    for ((t, c) in plan.withIndex()) {
        // W: no tap, only wait and film
        if (c != 'W') {
            val tap = where.getValue(c)
            scene.sendPointerEvent(PointerEventType.Press, tap); frames(1, "t$t$c", true)
            scene.sendPointerEvent(PointerEventType.Release, tap)
        }
        frames(28, "t$t$c", true)
    }
    scene.close()
    println("filmed $n frames")
}
