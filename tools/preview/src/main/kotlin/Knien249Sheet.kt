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
 * KNIEN249=1 (249, Chef 21.10., 16:21 abknien, 18:06 aufstehen): each class and each of the three ways down
 * ([HeroFigure.Act.KNEEL] 0, 1, 2) in every other frame, then getting up again ([HeroFigure.Act.RISE]).
 */
fun renderKnien249() {
    val rows = listOf(CharClass.FIGHTER, CharClass.CLERIC, CharClass.ROGUE, CharClass.WIZARD).flatMap { cls ->
        val hero = GameState.newGame("T", Race.HUMAN, cls).hero
        (0..2).map { v ->
            val kn = HeroBattle.frameCount(hero, HeroFigure.Act.KNEEL, HeroFigure.Strike.SLASH, v)
            val rn = HeroBattle.frameCount(hero, HeroFigure.Act.RISE, HeroFigure.Strike.SLASH, v)
            "${cls.name.lowercase()} $v" to ((0 until kn step 2).map { HeroBattle.frame(hero, HeroFigure.Act.KNEEL, HeroFigure.Strike.SLASH, v, it) } +
                (0 until rn step 2).map { HeroBattle.frame(hero, HeroFigure.Act.RISE, HeroFigure.Strike.SLASH, v, it) })
        }
    }
    var x0 = Int.MAX_VALUE; var y0 = Int.MAX_VALUE; var x1 = 0; var y1 = 0
    for ((_, pics) in rows) for (p in pics) for (y in 0 until p.height) for (x in 0 until p.width) if ((p[x, y] ushr 24) > 0) {
        x0 = minOf(x0, x); y0 = minOf(y0, y); x1 = maxOf(x1, x); y1 = maxOf(y1, y)
    }
    val cw = x1 - x0 + 5; val ch = y1 - y0 + 5; val label = 70
    val cols = rows.maxOf { it.second.size }
    val img = BufferedImage(label + cw * cols, ch * rows.size + 18, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x3a4a2e); g.fillRect(0, 0, img.width, img.height)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11); g.color = Color(0xd8c48a)
    g.drawString("Abknien (0 links, 1 rechts, 2 beide Knie), dann Aufstehen; jedes zweite Bild", label + 4, 13)
    for ((r, row) in rows.withIndex()) {
        val oy = 18 + r * ch
        g.color = Color(0xd8c48a); g.drawString(row.first, 6, oy + ch / 2)
        g.color = Color(0x2e3a24); g.drawLine(label, oy + ch - 4, img.width, oy + ch - 4)
        for ((c, p) in row.second.withIndex()) for (y in y0..y1) for (x in x0..x1) {
            val px = p[x, y]
            if ((px ushr 24) > 0) img.setRGB(label + c * cw + x - x0, oy + y - y0, px or (0xff shl 24))
        }
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/knien249.png"))
    println("knien249: ${img.width} × ${img.height}")
}
