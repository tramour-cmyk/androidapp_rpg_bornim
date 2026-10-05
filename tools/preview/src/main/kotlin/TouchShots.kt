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
import de.bornim.core.World
import de.bornim.core.route
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

private class Driver(val scene: ImageComposeScene) {
    var time = 0L
    fun frames(n: Int) = repeat(n) {
        scene.render(time)
        time += 33_000_000L
        Thread.sleep(20)
    }
    fun press(p: Offset) { scene.sendPointerEvent(PointerEventType.Press, p); frames(1) }
    fun move(p: Offset) { scene.sendPointerEvent(PointerEventType.Move, p); frames(1) }
    fun release(p: Offset) { scene.sendPointerEvent(PointerEventType.Release, p); frames(1) }
    fun tap(p: Offset) { press(p); release(p) }
    fun save(name: String) {
        File("build/screens/$name.png").writeBytes(scene.render(time).encodeToData(EncodedImageFormat.PNG)!!.bytes)
        println("wrote $name")
    }
}

@OptIn(ExperimentalComposeUiApi::class)
private fun touchShot(name: String, touch: Boolean = true, setup: (GameViewModel) -> Unit, act: Driver.(GameViewModel) -> Unit) {
    val vm = GameViewModel(Application())
    if (vm.touchControls != touch) vm.toggleControls()
    vm.newGame("Mira", Race.ELF, CharClass.WIZARD)
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    setup(vm)
    vm.refresh()
    val d = Driver(ImageComposeScene(1080, 2340, Density(2.75f)) { BornimApp(vm) })
    d.frames(40)
    d.act(vm)
    d.save(name)
    d.scene.close()
}

fun touchShots() {
    val village = Place("village", 11, 7, Facing.DOWN)
    // Next to a villager: the action button shows a speech bubble.
    touchShot("26_touch_action", setup = { vm ->
        val g = vm.game!!
        g.state.place = village
        val npc = g.map.npcs.first { it.visible(g.state) }
        val r = g.route(npc.x, npc.y)!!
        r.steps.forEach { g.move(it); g.afterStep() }
        r.face?.let { g.face(it) }
    }) { frames(20) }
    // Dragging: joystick under the finger, the hero walks right.
    touchShot("27_touch_drag", setup = { it.game!!.state.place = village }) {
        val start = Offset(700f, 1500f)
        press(start)
        for (i in 1..8) move(Offset(700f + i * 22f, 1500f + i * 3f))
        frames(25)
    }
    // Tapping a spot: the hero walks there, the target tile is marked.
    touchShot("28_touch_tap", setup = { it.game!!.state.place = village }) {
        tap(Offset(540f + 96f * 3, 1170f + 96f * 2))
        frames(12)
    }
    // Tapping a person further away: walk there and talk.
    touchShot("29_touch_talk", setup = { it.game!!.state.place = village }) { vm ->
        val g = vm.game!!
        val npc = g.map.npcs.filter { it.visible(g.state) }.maxBy { kotlin.math.abs(it.x - 11) + kotlin.math.abs(it.y - 7) }
        // same camera math as the game: zoom 3, a map smaller than the view is centred
        val scale = 3
        val viewW = 1080f / scale; val viewH = 2340f / scale
        val mapW = g.map.width * 32f; val mapH = g.map.height * 32f
        val camX = if (mapW <= viewW) (mapW - viewW) / 2 else (11 * 32 + 16 - viewW / 2).coerceIn(0f, mapW - viewW)
        val camY = if (mapH <= viewH) (mapH - viewH) / 2 else (7 * 32 + 16 - viewH / 2).coerceIn(0f, mapH - viewH)
        println("tap npc ${npc.id} at ${npc.x},${npc.y}")
        tap(Offset((npc.x * 32 + 16 - camX) * scale, (npc.y * 32 + 16 - camY) * scale))
        frames(150)
    }
    touchShot("30_classic", touch = false, setup = { it.game!!.state.place = village }) { frames(10) }
}
