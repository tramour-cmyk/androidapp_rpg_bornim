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
    run(System.getenv("WALKWAIT")?.toInt() ?: 800, false)
    val c = Offset(540f, 1500f)
    scene.sendPointerEvent(PointerEventType.Press, c)
    run(50, false)
    // WALKREACH: how far the finger is dragged, in pixels (131: past the ring, about 430, the hero runs)
    val r = System.getenv("WALKREACH")?.toFloat() ?: 140f
    for ((dx, dy) in listOf(-r to 0f, 0f to r, r to 0f, 0f to -r)) {
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
    // LEUTE=1 (330): everyone on the map drawn ahead, walking too
    if (System.getenv("LEUTE") != null) for (npc in m.npcs) de.bornim.core.art.MapFolk.of(npc.id)?.let { de.bornim.core.art.MapFolk.prepareNow(it) }
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

/**
 * FOEFILM=1: by day a wolf and a goblin (9) come at the hero, who stands still on the path south of Garrick's camp.
 * A picture every STEPMS (120 ms) under build/screens/films/foe/, cut to CROP. NOPREP: drawn in the background as on the phone.
 */
@OptIn(ExperimentalComposeUiApi::class)
fun foeFilm() {
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    g.state.flags += de.bornim.core.Story.QUEST_STARTED
    g.state.place = Place("forest", 10, 18, Facing.DOWN)
    g.state.minutes = (System.getenv("MINUTES") ?: "${12 * 60}").toInt()
    val m = de.bornim.core.World["forest"]
    g.state.explored["forest"] = "f".repeat((m.width * m.height + 3) / 4)
    de.bornim.core.art.MapGround.prepareNow(m)
    de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
    de.bornim.core.art.MapFolk.prepareNow(de.bornim.core.art.MapFolk.garrick)
    val herd = g.roamers as MutableList<de.bornim.core.Roamer>
    herd.clear()
    // FOEIDS=giant_spider,giant_bat: other kinds in place of the wolf and the goblin (9i)
    val ids = (System.getenv("FOEIDS") ?: "wolf,goblin").split(",")
    val wolf = de.bornim.core.Roamer(98, ids[0], 12, if (System.getenv("FOEIDLE") != null) 20 else 22, 12, 22, null, false, de.bornim.core.MonsterLook(1))
    val gob = de.bornim.core.Roamer(99, ids.getOrElse(1) { "goblin" }, 7, if (System.getenv("FOEIDLE") != null) 20 else 22, 7, 22, null, false, de.bornim.core.MonsterLook(0))
    // FOEIDLE=1: they ignore the hero and stroll about their homes, standing between steps (9d)
    val idle = System.getenv("FOEIDLE") != null
    for (r in listOf(wolf, gob)) { if (idle) r.calmUntil = Long.MAX_VALUE else r.hunting = true; herd += r
        if (System.getenv("NOPREP") == null) de.bornim.core.art.MapFoe.prepareNow(r.monster, r.look) }
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/foe"); dir.deleteRecursively(); dir.mkdirs()
    val stepMs = System.getenv("STEPMS")?.toInt() ?: 120
    val total = (System.getenv("FOEMS") ?: "4000").toInt()
    var time = 0L; var n = 0; var t = 0
    while (t < total) {
        val img = scene.render(time)
        saveFilmPicture(img, File(dir, "f%03d.png".format(n++)))
        img.close()
        time += stepMs * 1_000_000L; t += stepMs
        Thread.sleep(2)
    }
    scene.close()
    println("wrote foe film ($n pictures)")
}

/**
 * GESTENFILM=person (134.2): the hero, met with them before, comes towards someone with news, first two tiles beyond
 * noticing (the gesture is drawn ahead), then near: the golden sign and the gesture, then both once again. A picture
 * every STEPMS (80 ms) under build/screens/films/gesten/, cut to CROP.
 */
@OptIn(ExperimentalComposeUiApi::class)
fun gestureFilm(who: String) {
    val vm = GameViewModel(Application())
    vm.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    val m = de.bornim.core.World.maps.values.first { mp -> mp.npcs.any { it.id == who } }
    val npc = m.npcs.first { it.id == who }
    g.state.flags += de.bornim.core.MapMarks.met(who)
    g.state.heard[who] = listOf(0)
    g.state.minutes = (System.getenv("MINUTES") ?: "${12 * 60}").toInt()
    g.state.explored[m.id] = "f".repeat((m.width * m.height + 3) / 4)
    // first out of reach on the free side before them (behind the name of the place), then close
    val range = de.bornim.core.Perks.noticeRange(g.state.hero)
    val tiles = (0 until m.width).flatMap { x -> (0 until m.height).map { y -> x to y } }.filter { (x, y) -> m.walkable(x, y, g.state) }
    fun dist(x: Int, y: Int) = kotlin.math.abs(x - npc.x) + kotlin.math.abs(y - npc.y)
    // as far off as the room allows up to two tiles beyond noticing, then two tiles off (or the nearest there is)
    val farT = tiles.filter { (x, y) -> dist(x, y) in range + 1..range + 2 }.minByOrNull { (x, y) -> -dist(x, y) * 100 + kotlin.math.abs(x - npc.x) } ?: tiles.maxBy { (x, y) -> dist(x, y) }
    val nearT = tiles.filter { (x, y) -> dist(x, y) >= 1 }.minBy { (x, y) -> kotlin.math.abs(dist(x, y) - 2) * 100 + dist(x, y) - (if (y > npc.y) 50 else 0) }
    val far = dist(farT.first, farT.second); val near = dist(nearT.first, nearT.second)
    g.state.place = Place(m.id, farT.first, farT.second, Facing.UP)
    de.bornim.core.art.MapGround.prepareNow(m)
    de.bornim.core.art.MapFigure.prepareNow(g.state.hero)
    de.bornim.core.art.MapFolk.of(who)?.let { de.bornim.core.art.MapFolk.prepareNow(it) }
    vm.refresh()
    val scene = ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) }
    val dir = File("build/screens/films/gesten"); dir.deleteRecursively(); dir.mkdirs()
    val stepMs = System.getenv("STEPMS")?.toInt() ?: 80
    var time = 0L; var n = 0; var t = 0
    while (t < 9_000) {
        if (t == 3_200) { g.state.place = Place(m.id, nearT.first, nearT.second, Facing.UP); vm.refresh() }
        val img = scene.render(time)
        saveFilmPicture(img, File(dir, "f%03d.png".format(n++)))
        img.close()
        time += stepMs * 1_000_000L; t += stepMs
    }
    scene.close()
    println("wrote gesture film ($n pictures, far $far, near $near)")
}
