package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.Battle
import de.bornim.core.CharClass
import de.bornim.core.Dice
import de.bornim.core.EliteTrait
import de.bornim.core.Facing
import de.bornim.core.Mode
import de.bornim.core.MonsterLook
import de.bornim.core.Monsters
import de.bornim.core.Place
import de.bornim.core.Race
import de.bornim.core.Rules
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/** Plays whole battles through the real UI by tapping "Fight" until they end. Reports crashes and outcomes. */
@OptIn(ExperimentalComposeUiApi::class)
fun battleRuns() {
    val out = File("build/screens/runs").apply { mkdirs() }
    val scenarios = Monsters.all.filter { !it.boss }.flatMap { m ->
        listOf(m.id to null as EliteTrait?) + (if (m.id in setOf("wolf", "ghoul", "stirge")) EliteTrait.entries.map { m.id to it } else emptyList())
    } + listOf("bugbear" to null, "hobgoblin_captain" to null)
    var failures = 0
    for ((i, sc) in scenarios.withIndex()) {
        val (id, trait) = sc
        val cls = CharClass.entries[i % 4]
        val race = Race.entries[i % Race.entries.size]
        val vm = GameViewModel(Application())
        try {
            vm.newGame("Test", race, cls)
            val g = vm.game!!
            var guard = 0
            while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
            g.state.hero.gainXp(Rules.xpForLevel[4])
            g.state.hero.restoreFully()
            g.state.place = Place(if (i % 2 == 0) "forest" else "cave", 10, 20, Facing.UP)
            val shiny = i % 7 == 3
            val battle = Battle(g.state, Monsters[id], g.lang, Dice(), 4, trait != null, 3, trait, shiny, MonsterLook(i * 31, shiny, trait?.color))
            g.fight(battle)
            vm.refresh()
            val scene = ImageComposeScene(540, 1170, Density(1.375f)) { BornimApp(vm) }
            var time = 0L
            fun frames(n: Int) = repeat(n) { scene.render(time); time += 33_000_000L }
            frames(30)
            val tap = Offset(135f, 1005f)
            var taps = 0
            while (vm.game?.mode is Mode.Fight && taps < 400) {
                scene.sendPointerEvent(PointerEventType.Press, tap); frames(1)
                scene.sendPointerEvent(PointerEventType.Release, tap); frames(if (taps % 3 == 0) 4 else 2)
                taps++
                if (taps == 9 && i % 5 == 0) {
                    File(out, "run_${i}_$id.png").writeBytes(scene.render(time).encodeToData(EncodedImageFormat.PNG)!!.bytes)
                }
            }
            val ended = vm.game?.mode !is Mode.Fight
            println("${if (ended) "OK  " else "HANG"} ${id.padEnd(18)} ${(trait?.name ?: if (shiny) "SHINY" else "-").padEnd(9)} ${cls.name.padEnd(8)} ${battle.outcome} taps=$taps")
            if (!ended) failures++
            scene.close()
        } catch (e: Throwable) {
            failures++
            println("CRASH $id $trait $cls: $e")
            e.printStackTrace()
        }
    }
    println("battle runs done, failures=$failures")
}
