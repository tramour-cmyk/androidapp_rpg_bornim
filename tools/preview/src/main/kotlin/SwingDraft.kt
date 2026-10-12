package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** 17 (draft): the hero's cloak swinging on after a stop, in a few directions, picture by picture (`SWINGBILD=1`). */
fun renderSwingDraft() {
    val F = de.bornim.core.art.MapFigure
    val times = listOf(0L, 120L, 225L, 400L, 675L, 900L, 1400L)
    val heroes = listOf(de.bornim.core.CharClass.FIGHTER to de.bornim.core.Race.HUMAN)
    // seen diagonally the pictures are turned by 45°: slots as the screen shows them
    val slots = listOf(4, 12)
    val z = 4
    val cw = F.W / 2 * z; val ch = F.H / 2 * z
    val img = BufferedImage(cw * times.size, (ch + 16) * slots.size * heroes.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x2E3A2C); g.fillRect(0, 0, img.width, img.height)
    var row = 0
    for ((cls, race) in heroes) {
        val hero = de.bornim.core.GameState.newGame("Alrik", race, cls).hero
        for (slot in slots) {
            val y0 = row * (ch + 16)
            for ((c, t) in times.withIndex()) {
                val lv = F.swingLevel(t)
                val p = F.swingFrameNow(hero, slot, lv)
                // the picture is at density 2: every second art pixel, enlarged z times
                for (y in 0 until ch) for (x in 0 until cw) {
                    val q = p[(x * 2 / z).coerceAtMost(p.width - 1), (y * 2 / z).coerceAtMost(p.height - 1)]
                    if ((q ushr 24) >= 128) img.setRGB(c * cw + x, y0 + 16 + y, q and 0xFFFFFF)
                }
                g.color = java.awt.Color(0xF0E8D8); g.drawString("${t} ms  Stufe $lv", c * cw + 4, y0 + 13)
            }
            row++
        }
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_nachschwingen.png"))
    println("wrote swing draft")
}
