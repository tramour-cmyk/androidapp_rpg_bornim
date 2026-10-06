package preview

import de.bornim.core.MonsterLook
import de.bornim.core.art.Act
import de.bornim.core.art.BattleScene
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.argb
import de.bornim.core.art.mix
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Draft only: the elite glow as a shimmering outline around the sprite instead of a round glow. */
fun renderEliteMock() {
    val w = 270; val h = 370
    val traits = listOf("savage" to 0xFF5A3C, "vampiric" to 0xFF3C78, "swift" to 0x40E0FF, "ancient" to 0xB48CFF)
    for ((name, color) in traits) for ((pi, pulse) in listOf(0.0, 1.0).withIndex()) {
        val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DAY, false, 11)
        val img = bg.copy()
        val wolf = MonsterArt.battleFrame("wolf", MonsterLook(3), Act.IDLE, 0, 0)
        val ox = (w * BattleScene.FOE_X - wolf.width / 2).toInt(); val oy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
        // distance from the sprite for every pixel around it (up to 4 pixels)
        val c = argb(color)
        for (y in -5 until wolf.height + 5) for (x in -5 until wolf.width + 5) {
            if (wolf.opaque(x, y)) continue
            var d = 9.0
            for (dy in -4..4) for (dx in -4..4) if (wolf.opaque(x + dx, y + dy)) d = minOf(d, Math.sqrt((dx * dx + dy * dy).toDouble()))
            if (d > 4) continue
            val a = (1 - (d - 1) / (3.0 + pulse)).coerceIn(0.0, 1.0) * (0.55 + 0.3 * pulse)
            val px = ox + x; val py = oy + y
            img.set(px, py, mix(img[px, py], if (d < 1.5) mix(c, argb(0xFFFFFF), 0.35) else c, a))
        }
        for (y in 0 until wolf.height) for (x in 0 until wolf.width) {
            val p = wolf[x, y]
            if ((p ushr 24) < 128) continue
            // a faint tint of the trait color on the edges of the body
            val edge = !wolf.opaque(x - 2, y) || !wolf.opaque(x + 2, y) || !wolf.opaque(x, y - 2)
            img.set(ox + x, oy + y, if (edge) mix(p, c, 0.25 + 0.15 * pulse) else p)
        }
        val crop = PixelImage(200, 110)
        for (y in 0 until 110) for (x in 0 until 200) crop.set(x, y, img[70 + x, 135 + y])
        val out = BufferedImage(800, 440, BufferedImage.TYPE_INT_RGB)
        for (y in 0 until 440) for (x in 0 until 800) out.setRGB(x, y, crop[x / 4, y / 4])
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/elite_mock_${name}_$pi.png"))
    }
    // the sheen wandering over a shimmering wolf, a few moments of one sweep
    val shiny = MonsterArt.battleFrame("wolf", MonsterLook(3, shiny = true), Act.IDLE, 0, 0)
    val phases = listOf(2, 4, 6, 8, 10)
    val out = BufferedImage(shiny.width * 3 * phases.size, shiny.height * 3, BufferedImage.TYPE_INT_RGB)
    for ((i, ph) in phases.withIndex()) {
        val sheen = de.bornim.core.art.Glow.sheen(shiny, ph)
        for (y in 0 until shiny.height * 3) for (x in 0 until shiny.width * 3) {
            val p = shiny[x / 3, y / 3]
            var c = if ((p ushr 24) > 128) p else argb(0x4E6E44)
            val s = sheen[x / 3, y / 3]
            if ((s ushr 24) > 0) c = mix(c, s or (0xFF shl 24), (s ushr 24) / 255.0 * 0.75)
            out.setRGB(i * shiny.width * 3 + x, y, c)
        }
    }
    ImageIO.write(out, "png", File("build/screens/shiny_sheen.png"))
    println("wrote elite mock")
}
