package de.bornim.core

import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.test.Test

/** Exports the adaptive launcher icon foreground from the game art. */
class IconExportTest {
    @Test
    fun exportLauncherForeground() {
        val target = File("../app/src/main/res/drawable-nodpi")
        if (!target.isDirectory) return
        val size = 432
        val img = BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB)
        fun blit(p: de.bornim.core.art.PixelImage, ox: Int, oy: Int, s: Int) {
            for (y in 0 until p.height) for (x in 0 until p.width) {
                val c = p[x, y]
                if ((c ushr 24) == 0) continue
                for (sy in 0 until s) for (sx in 0 until s) img.setRGB(ox + x * s + sx, oy + y * s + sy, c)
            }
        }
        // Sun amulet glowing behind the hero.
        blit(IconArt.get(Icon.SUN), (size - 32 * 6) / 2, 92, 6)
        blit(CharacterArt.hero(Race.HUMAN, CharClass.FIGHTER, Facing.DOWN), (size - 32 * 6) / 2, 140, 6)
        ImageIO.write(img, "png", File(target, "ic_launcher_fg.png"))
    }
}
