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
    fun scroll(p: Offset, dy: Float) { scene.sendPointerEvent(PointerEventType.Scroll, p, scrollDelta = Offset(0f, dy)); frames(2) }
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
    // Character creation, scrolled down to the point buy
    touchShot("55_create_pointbuy", setup = { vm ->
        if (vm.lang != de.bornim.core.Lang.DE) vm.toggleLang()
        vm.screen = de.bornim.game.Screen.CREATE
    }) {
        repeat(30) { scroll(Offset(540f, 1200f), 3f) }
        frames(10)
    }
    if (System.getenv("ONLY") == "55") return
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
    // Monsters walking around in the forest; one has spotted the hero.
    touchShot("34_roamers", setup = { vm ->
        val g = vm.game!!
        g.state.hero.gainXp(de.bornim.core.Rules.xpForLevel[4])
        g.state.place = Place("forest", 10, 20, Facing.UP)
        val near = listOf(7 to 18, 13 to 17, 9 to 23, 14 to 22, 6 to 21)
        g.roamers.take(near.size).forEachIndexed { i, r ->
            r.x = near[i].first; r.y = near[i].second; r.fromX = r.x; r.fromY = r.y
            r.calmUntil = Long.MAX_VALUE
        }
        g.roamers.first().alertUntil = Long.MAX_VALUE
    }) { frames(12) }
    // Life on the map: village by day and by night, forest at night and in the rain.
    touchShot("35_village_day", setup = { vm -> vm.game!!.state.place = village; vm.game!!.state.minutes = 10 * 60 }) { frames(30) }
    touchShot("36_village_night", setup = { vm -> vm.game!!.state.place = village; vm.game!!.state.minutes = 23 * 60 }) { frames(30) }
    touchShot("37_forest_night", setup = { vm ->
        val g = vm.game!!
        g.state.minutes = 22 * 60
        g.state.place = Place("forest", 10, 20, Facing.UP)
        val near = listOf(7 to 18, 9 to 23, 6 to 21)
        g.roamers.take(near.size).forEachIndexed { i, r -> r.x = near[i].first; r.y = near[i].second; r.fromX = r.x; r.fromY = r.y; r.calmUntil = Long.MAX_VALUE }
    }) { frames(30) }
    touchShot("38_forest_rain", setup = { vm ->
        val g = vm.game!!
        g.state.minutes = 15 * 60
        g.state.place = Place("forest", 10, 20, Facing.UP)
        g.cheatRain()
    }) { frames(30) }
    // A kobold pack on the map
    touchShot("40_pack_map", setup = { vm ->
        val g = vm.game!!
        g.state.place = Place("forest", 10, 20, Facing.UP)
        val r = g.roamers.first()
        val pack = de.bornim.core.Roamer(500, "kobold", 8, 18, 8, 18, null, false, de.bornim.core.MonsterLook((1..200).first { de.bornim.core.Monsters.packSize(de.bornim.core.Monsters["kobold"], de.bornim.core.MonsterLook(it)) == 2 }))
        (g.roamers as MutableList).add(pack)
        pack.calmUntil = Long.MAX_VALUE
        r.x = 0; r.y = 0
    }) { frames(12) }
    // Unequipping in the gear tab must redraw the paper doll at once.
    touchShot("41_unequip", setup = { vm ->
        val g = vm.game!!
        g.state.hero.gainXp(de.bornim.core.Rules.xpForLevel[5])
        val cloak = de.bornim.core.Loot.generate(g.state, de.bornim.core.Dice(kotlin.random.Random(3)), 5, de.bornim.core.Rarity.RARE, null, de.bornim.core.GearSlot.CLOAK)
        g.state.equipFromBag(g.state.addGear(cloak))
        vm.menuOpen = true
    }) { vm ->
        tap(Offset(680f, 95f))
        frames(10)
        save("41_unequip_before")
        vm.game!!.state.unequipToBag(de.bornim.core.GearSlot.CLOAK)
        vm.refresh()
        frames(10)
    }
    // Fog of war in the forest and the new deep forest
    touchShot("42_fog_forest", setup = { vm ->
        val g = vm.game!!
        g.state.minutes = 11 * 60
        g.state.place = Place("forest", 10, 20, Facing.UP)
    }) { frames(10) }
    touchShot("43_fog_walked", setup = { vm ->
        val g = vm.game!!
        g.state.minutes = 11 * 60
        g.state.place = Place("forest", 9, 28, Facing.UP)
        // walk up the path, looking around now and then
        for (y in 27 downTo 18) { g.move(Facing.UP); g.afterStep() }
        g.face(Facing.LEFT); g.fog(9, 18); g.face(Facing.RIGHT); g.fog(9, 18); g.face(Facing.UP)
    }) { frames(10) }
    touchShot("44_deep_forest", setup = { vm ->
        val g = vm.game!!
        g.state.minutes = 11 * 60
        g.state.place = Place("deep_forest", 16, 20, Facing.RIGHT)
        for (x in 17..20) { g.move(Facing.RIGHT); g.afterStep() }
        g.face(Facing.UP); g.fog(20, 20); g.face(Facing.DOWN); g.fog(20, 20); g.face(Facing.RIGHT)
    }) { frames(10) }
    touchShot("30_classic", touch = false, setup = { it.game!!.state.place = village }) { frames(10) }
}
