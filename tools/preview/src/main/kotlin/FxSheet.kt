package preview

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
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
