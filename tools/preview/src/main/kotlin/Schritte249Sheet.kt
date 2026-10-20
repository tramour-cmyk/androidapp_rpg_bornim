package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * SCHRITTE249=1 (249, Chef 20.10., 16:37 „Schritte als nächster Teil“): each class under the MARS camera, first at rest,
 * then the pictures of one stride as a change of place shows them ([HeroFigure.Act.STEP], one stride over the way).
 */
fun renderSchritte249() {
    val rows = listOf(CharClass.FIGHTER, CharClass.CLERIC, CharClass.ROGUE, CharClass.WIZARD).map { cls ->
        val hero = GameState.newGame("T", Race.HUMAN, cls).hero
        cls.name to (listOf(HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)) +
            (0 until HeroFigure.STEP_FRAMES).map { HeroBattle.frame(hero, HeroFigure.Act.STEP, HeroFigure.Strike.SLASH, 0, it) })
    }
    // the part of the frames anything is drawn in
    var x0 = Int.MAX_VALUE; var y0 = Int.MAX_VALUE; var x1 = 0; var y1 = 0
    for ((_, pics) in rows) for (p in pics) for (y in 0 until p.height) for (x in 0 until p.width) if ((p[x, y] ushr 24) > 0) {
        x0 = minOf(x0, x); y0 = minOf(y0, y); x1 = maxOf(x1, x); y1 = maxOf(y1, y)
    }
    val cw = x1 - x0 + 7; val ch = y1 - y0 + 5; val label = 70
    val img = BufferedImage(label + cw * rows[0].second.size, ch * rows.size + 18, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x3a4a2e); g.fillRect(0, 0, img.width, img.height)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11); g.color = Color(0xd8c48a)
    g.drawString("Ruhe", label + 4, 13)
    g.drawString("Schritte beim Platzwechsel (ein Schritt links, einer rechts)", label + cw + 4, 13)
    for ((r, row) in rows.withIndex()) {
        val oy = 18 + r * ch
        g.color = Color(0xd8c48a); g.drawString(row.first.lowercase(), 6, oy + ch / 2)
        for ((c, p) in row.second.withIndex()) for (y in y0..y1) for (x in x0..x1) {
            val px = p[x, y]
            if ((px ushr 24) > 0) img.setRGB(label + c * cw + x - x0, oy + y - y0, px or (0xff shl 24))
        }
        g.color = Color(0x2e3a24); g.drawLine(label + cw - 3, oy, label + cw - 3, oy + ch)
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/schritte249.png"))
    println("schritte249: ${img.width} × ${img.height}")
}
