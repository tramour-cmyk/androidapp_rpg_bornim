package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.art.MapFigure
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * GANG245=1 (245, Chef 20.10.: der Held läuft "robotermäßig"): the hero walking and running, seen from the side and at
 * three-quarters, each before and after, a picture for each step as the game shows them; below, a half turn every 40 ms.
 */
fun renderGang245() {
    val hero = GameState.newGame("Alrik", Race.HUMAN, CharClass.FIGHTER).hero
    val walkMs = 340.0 * MapFigure.WALK_TILES / MapFigure.STEPS
    val runMs = 170.0
    data class Row(val label: String, val ms: Double, val pics: List<java.awt.image.BufferedImage?>)
    fun pic(slot: Int, step: Int, run: Double, moving: Boolean) = MapFigure.draw(hero, slot, step, run, moving)
    val rows = ArrayList<Row>()
    for ((slot, side) in listOf(4 to "Seite", 2 to "schräg")) {
        rows += Row("Gehen $side vorher", walkMs, (0 until MapFigure.STEPS).map { toImg(pic(slot, it, 0.0, false)) })
        rows += Row("Gehen $side jetzt", walkMs, (0 until MapFigure.STEPS).map { toImg(pic(slot, it, 0.0, true)) })
        // before, a run was the walk played twice as fast
        rows += Row("Rennen $side vorher", runMs * MapFigure.WALK_TILES / MapFigure.STEPS, (0 until MapFigure.STEPS).map { toImg(pic(slot, it, 0.0, false)) })
        rows += Row("Rennen $side jetzt", runMs * MapFigure.RUN_TILES / MapFigure.RUN_STEPS, (0 until MapFigure.RUN_STEPS).map { toImg(pic(slot, it, 1.0, true)) })
    }
    // a half turn, from looking down to looking up, a picture every 40 ms
    fun turning(next: (Double, Long) -> Double): List<BufferedImage?> {
        var yaw = 0.0
        return (0 until 12).map { i ->
            if (i > 0) repeat(40 / 8) { yaw = next(yaw, 8) }
            toImg(pic(MapFigure.slot(yaw), 0, 0.0, false))
        }
    }
    rows += Row("Drehung vorher", 40.0, turning { y, dt -> val d = ((179.0 - y) % 360 + 540) % 360 - 180; if (kotlin.math.abs(d) <= dt * 0.75) 179.0 else y + kotlin.math.sign(d) * dt * 0.75 })
    rows += Row("Drehung jetzt", 40.0, turning { y, dt -> MapFigure.turnStep(y, 179.0, dt) })

    val cols = rows.maxOf { it.pics.size }
    val cx0 = 10; val cx1 = 86; val cy0 = 22; val cy1 = 130
    val cw = cx1 - cx0; val ch = cy1 - cy0
    val label = 150
    val img = BufferedImage(label + cw * cols, (ch + 16) * rows.size + 4, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x2a2a26); g.fillRect(0, 0, img.width, img.height)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    for ((r, row) in rows.withIndex()) {
        val y0 = 4 + r * (ch + 16)
        g.color = if (r % 2 == 0) Color(0x9a9080) else Color(0xd8c48a)
        g.drawString(row.label, 6, y0 + ch / 2)
        g.drawString("je ${Math.round(row.ms)} ms", 6, y0 + ch / 2 + 14)
        for ((c, p) in row.pics.withIndex()) {
            p ?: continue
            for (y in cy0 until minOf(cy1, p.height)) for (x in cx0 until minOf(cx1, p.width)) {
                val px = p.getRGB(x, y)
                if ((px ushr 24) > 0) img.setRGB(label + c * cw + x - cx0, y0 + y - cy0, px or (0xff shl 24))
            }
        }
        g.color = Color(0x3a3a34); g.drawLine(0, y0 + ch + 8, img.width, y0 + ch + 8)
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/gang245.png"))
    // 245.1: each picture of a run towards the viewer, from the side and at three-quarters, for a moving picture
    File("build/screens/rennen").apply { deleteRecursively(); mkdirs() }.let { d ->
        for (slot in listOf(0, 2, 4)) for (i in 0 until MapFigure.RUN_STEPS)
            toImg(pic(slot, i, 1.0, true))?.let { ImageIO.write(it, "png", File(d, "r${slot}_%02d.png".format(i))) }
    }
    println("wrote build/screens/gang245.png")
}

private fun toImg(p: de.bornim.core.art.PixelImage): BufferedImage {
    val b = BufferedImage(p.width, p.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until p.height) for (x in 0 until p.width) b.setRGB(x, y, p[x, y])
    return b
}
