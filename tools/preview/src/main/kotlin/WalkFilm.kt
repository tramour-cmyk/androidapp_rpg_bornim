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
 * Saves one film picture, cut to CROP=x0:y0:x1:y1 when given (only the part that is looked at is
 * encoded, which is most of the cost of a picture).
 */
internal fun saveFilmPicture(img: org.jetbrains.skia.Image, file: File) {
    val c = System.getenv("CROP")?.split(":")?.map { it.toInt() }
    val out = if (c == null) img else {
        val bmp = org.jetbrains.skia.Bitmap()
        bmp.allocN32Pixels(c[2] - c[0], c[3] - c[1])
        img.readPixels(bmp, c[0], c[1])
        org.jetbrains.skia.Image.makeFromBitmap(bmp)
    }
    file.writeBytes(out.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    if (out !== img) out.close()
}

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
    // MINUTES / DAY: walk at another time, e.g. a night with fireflies (DAY=3 MINUTES=1380)
    g.state.minutes = System.getenv("MINUTES")?.toInt() ?: (12 * 60)
    System.getenv("DAY")?.let { g.state.day = it.toInt() }
    val m = de.bornim.core.World[map]
    g.state.explored[map] = "f".repeat((m.width * m.height + 3) / 4)
    if (System.getenv("NOPREP") == null) de.bornim.core.art.MapGround.prepareNow(m)
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
    // only the pictures that are kept are drawn: one every 80 ms of game time (was every 16 ms, five times the work)
    val stepMs = 80
    fun run(ms: Int, save: Boolean = true) {
        var t = 0
        while (t < ms) {
            val img = scene.render(time)
            if (save) saveFilmPicture(img, File(dir, "f%03d.png".format(n++)))
            img.close()
            time += stepMs * 1_000_000L; t += stepMs
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
 * their idle loops; a picture every STEPMS (250 ms) under build/screens/films/idle/, from FROM seconds on,
 * cut to CROP.
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
    // one picture every STEPMS (default 250 ms) of game time, nothing drawn in between (turning copes
    // with jumps of up to 200 ms per picture, so keep STEPMS at most 250); FROM=s skips ahead without drawing
    val stepMs = System.getenv("STEPMS")?.toInt() ?: 250
    val from = (System.getenv("FROM")?.toDouble() ?: 0.0).times(1000).toInt()
    scene.render(0L).close()
    var t = from
    time = from * 1_000_000L
    while (t < total) {
        val img = scene.render(time)
        saveFilmPicture(img, File(dir, "f%03d.png".format(n++)))
        img.close()
        time += stepMs * 1_000_000L; t += stepMs
    }
    scene.close()
    println("wrote idle film ($n pictures)")
}

/**
 * WARDFILM=1: a wolf hunts the hero, who stands at Garrick's camp; Garrick takes a brand from the fire
 * and wards it off. A picture every STEPMS (150 ms) under build/screens/films/ward/, cut to CROP.
 */
@OptIn(ExperimentalComposeUiApi::class)
fun wardFilm() {
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    g.state.flags += de.bornim.core.Story.QUEST_STARTED
    g.state.place = Place("forest", 12, 11, Facing.DOWN)
    g.state.minutes = (System.getenv("MINUTES") ?: "${22 * 60}").toInt()
    val m = de.bornim.core.World["forest"]
    g.state.explored["forest"] = "f".repeat((m.width * m.height + 3) / 4)
    de.bornim.core.art.MapGround.prepareNow(m)
    de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
    val gk = de.bornim.core.art.MapFolk.garrick
    de.bornim.core.art.MapFolk.prepareNow(gk)
    de.bornim.core.art.MapFolk.prepareWardNow(gk)
    val herd = g.roamers as MutableList<de.bornim.core.Roamer>
    herd.clear()
    val wolf = de.bornim.core.Roamer(99, "wolf", 12, 14, 12, 18, null, false, de.bornim.core.MonsterLook())
    wolf.hunting = true
    herd += wolf
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/ward"); dir.deleteRecursively(); dir.mkdirs()
    val stepMs = System.getenv("STEPMS")?.toInt() ?: 150
    var time = 0L; var n = 0; var t = 0
    while (t < 6_500) {
        val img = scene.render(time)
        saveFilmPicture(img, File(dir, "f%03d.png".format(n++)))
        img.close()
        time += stepMs * 1_000_000L; t += stepMs
    }
    scene.close()
    println("wrote ward film ($n pictures), ward at ${g.lastWardOff?.atMs}")
}
