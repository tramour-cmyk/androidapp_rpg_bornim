package preview

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.offset
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp
import de.bornim.core.Fx
import de.bornim.core.FxKind
import de.bornim.game.ui.drawFx
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/** Contact sheet of every battle effect at three moments, with two different seeds. */
fun renderFxSheet() {
    val kinds = FxKind.entries
    val frames = listOf(0.2f, 0.45f, 0.7f)
    val cell = 120
    val scene = ImageComposeScene(cell * 6, cell * kinds.size, Density(1f)) {
        Column(Modifier.background(Color(0xFF2A3A2A))) {
            kinds.forEach { k ->
                Row {
                    for (seed in listOf(11, 4242)) for (p in frames) {
                        Canvas(Modifier.size(cell.dp).background(if (seed == 11) Color(0xFF3A5A3A) else Color(0xFF34503A))) {
                            val onHero = k in setOf(FxKind.BITE, FxKind.POISON, FxKind.HEAL, FxKind.BLESS, FxKind.MAGE_ARMOR, FxKind.BLOCK, FxKind.GUARDIANS)
                            val enemy = Offset(size.width * 0.72f, size.height * 0.32f)
                            val hero = Offset(size.width * 0.25f, size.height * 0.75f)
                            drawCircle(Color(0x55FFFFFF), 10f, enemy)
                            drawCircle(Color(0x55FFFFFF), 10f, hero)
                            drawFx(Fx(k, onHero, crit = seed == 4242, seed = seed), p, if (onHero) enemy else hero, if (onHero) hero else enemy, 1.2f)
                        }
                    }
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/fx_sheet.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote fx_sheet")
}

/** Grimfang springing out of a sacred flame (the save made) and caught in one (the save failed), as the battle shows it. */
fun renderFlameDodge() {
    val id = "dire_wolf"
    val look = de.bornim.core.MonsterLook(3)
    val frame = de.bornim.core.art.MonsterArt.battleFrame(id, look, de.bornim.core.art.Act.IDLE, 0, 0)
    val px = 1.6f
    val ts = listOf(0.15f, 0.35f, 0.55f, 0.75f)
    val cw = 330; val ch = 300
    val scene = ImageComposeScene(cw * ts.size, ch * 2, Density(1f)) {
        Column(Modifier.background(Color(0xFF2A3A2A))) {
            for (saved in listOf(true, false)) Row {
                for (t in ts) androidx.compose.foundation.layout.Box(Modifier.size(cw.dp, ch.dp).background(Color(0xFF3A5A3A))) {
                    val feetX = cw * 0.5f; val feetY = ch * 0.85f
                    val seed = 11
                    val side = if (seed % 2 == 0) 1 else -1
                    val hop = if (saved) (kotlin.math.sin(t * Math.PI.toFloat()) * 26 * side) else 0f
                    val fw = frame.width * px; val feet = (de.bornim.core.art.MonsterArt.groundLine(id) * px).toFloat()
                    androidx.compose.foundation.layout.Box(Modifier.offset((feetX - fw / 2 + hop).dp, (feetY - feet).dp)) {
                        de.bornim.game.ui.PixelSprite(frame, px.dp)
                    }
                    Canvas(Modifier.size(cw.dp, ch.dp)) {
                        val enemy = Offset(feetX, feetY - feet * 0.55f)
                        val hero = Offset(20f, ch.toFloat())
                        val u = fw / 90
                        if (saved) {
                            val away = if (seed % 2 == 0) -1f else 1f
                            drawFx(Fx(FxKind.SACRED_FLAME, false, false, seed), t, hero, Offset(enemy.x + away * 30 * u, enemy.y), u)
                            drawFx(Fx(FxKind.DODGE, false, false, seed, FxKind.SACRED_FLAME), t, hero, enemy, u)
                        } else drawFx(Fx(FxKind.SACRED_FLAME, false, false, seed), t, hero, enemy, u)
                    }
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/flame_dodge.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote flame_dodge")
}
