package preview

import de.bornim.core.MonsterLook
import de.bornim.core.art.Beast
import de.bornim.core.art.BeastArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 211.10 (Chef 21:42, 21:47): the battle wolf as today (turned -60°, seen from 15° above) beside other cameras, so it
 * can be told whether a steeper look from above, or turning it towards the heroes, fixes the legs seen in profile.
 * WOLFANSICHT=1 → build/screens/wolfansicht.png
 */
fun renderWolfView() {
    val views = listOf("heute: -60°, 15° oben" to (-60.0 to 15.0), "-60°, 35° oben" to (-60.0 to 35.0),
        "Dreiviertel vorn: -30°, 15°" to (-30.0 to 15.0), "Dreiviertel vorn: -30°, 35°" to (-30.0 to 35.0))
    val cw = 300; val ch = 230; val px = 1.7
    val out = BufferedImage(cw * views.size, ch, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x2E2A26); g.fillRect(0, 0, out.width, out.height)
    val wolf = BeastArt.beast("wolf", MonsterLook(0))
    for ((i, v) in views.withIndex()) {
        val (yaw, pitch) = v.second
        val im = wolf.render(cw, ch, cw / 2.0 + 30, ch - 30.0, px, BeastArt.STAND.copy(yaw = yaw), pitch)
        for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(i * cw + x, y, q and 0xFFFFFF) }
        g.color = java.awt.Color(0xF0E8D8); g.drawString(v.first, i * cw + 6, 16)
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/wolfansicht.png"))
    println("wrote wolfansicht")
}
