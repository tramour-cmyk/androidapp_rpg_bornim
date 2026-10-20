package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Loot
import de.bornim.core.Race
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapRest
import de.bornim.core.art.PixelImage
import java.awt.Color
import java.awt.Font
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * FACKEL255=1 (255, Chef 20.10.: "255 1 und 2"): the hero with the torch, above burning (night outdoors, cave), below
 * held out (room, outdoors by day); standing in three directions and two steps of the walk, three times the map size.
 */
fun renderFackel255() {
    val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
    hero.equip(Loot.torch(1))
    val slots = listOf(1, 2, 3)
    fun row(out: Boolean): List<PixelImage> {
        MapFigure.out = out
        return slots.map { MapFigure.drawRest(hero, it, MapRest.Rest.NEUTRAL, 0, flame = 0, held = out) } +
            listOf(2, 5).map { MapFigure.draw(hero, 2, it) }
    }
    val rows = listOf("brennt (Höhle, nachts)" to row(false), "gelöscht (Raum, Tag)" to row(true))
    MapFigure.out = false
    val z = 3
    val cw = rows.flatMap { it.second }.maxOf { it.width } * z
    val ch = rows.flatMap { it.second }.maxOf { it.height } * z
    val top = 22
    val img = BufferedImage(cw * rows[0].second.size, (ch + top) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 15)
    for ((r, pair) in rows.withIndex()) {
        val (label, pics) = pair
        val y0 = r * (ch + top)
        g.color = if (r == 0) Color(0x16141C) else Color(0x8A6E4E)
        g.fillRect(0, y0, img.width, ch + top)
        g.color = Color(0xF0C850)
        g.drawString(label, 6, y0 + 16)
        for ((c, p) in pics.withIndex()) for (y in 0 until p.height) for (x in 0 until p.width) {
            val px = p[x, y]
            if ((px ushr 24) < 0x40) continue
            for (dy in 0 until z) for (dx in 0 until z) img.setRGB(c * cw + (cw - p.width * z) / 2 + x * z + dx, y0 + top + y * z + dy, px or (0xff shl 24))
        }
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/fackel255.png"))
    println("wrote build/screens/fackel255.png")
}
