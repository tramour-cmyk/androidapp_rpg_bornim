package preview

import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.World
import de.bornim.core.art.Doll
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapFlora
import de.bornim.core.art.MapGround
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.geom.AffineTransform
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 348.1: a piece of the woods with the hero, as today (ground, trees and hero at 64 art pixels a tile) beside the same
 * drawers at twice the fineness (128 a tile) with the line of ink; seen diagonally and placed as on the map
 * (WorldScreen's Cam), at the phone's scale. Bushes, ferns, stumps and the shadows of the sun are left out on both
 * sides (the undergrowth's drawer cannot draw finer yet). Prints how long each drawing takes and what it holds.
 * VERGLEICH348=1, pictures under build/screens/vergleich348*.png.
 */
fun renderVergleich348() {
    val map = World["forest"]
    val hx = (System.getenv("V348X") ?: "9").toInt(); val hy = (System.getenv("V348Y") ?: "19").toInt()
    val hero = GameState.newGame("Grom", Race.HALF_ORC, CharClass.FIGHTER).hero
    val slot = MapFigure.slot(MapFigure.yawOf(Facing.DOWN))
    val T = WorldArt.T
    val reach = 7
    val tx0 = hx - reach; val ty0 = hy - reach; val tx1 = hx + reach; val ty1 = hy + reach
    val pw = 540; val ph = 600
    val report = StringBuilder()
    // where the hero's head is in the panel (the first row he is drawn in), for the enlarged middle below
    var heroTop = 0

    fun side(fine: Int, ink: Boolean): BufferedImage {
        Doll.ink = ink; Doll.inkScale = fine.toDouble()
        val dens = MapGround.D * fine
        val ch = MapGround.CH
        // 1) the ground: the chunks of the piece in one picture, then turned as on the map
        val c0x = Math.floorDiv(tx0, ch); val c0y = Math.floorDiv(ty0, ch); val c1x = Math.floorDiv(tx1, ch); val c1y = Math.floorDiv(ty1, ch)
        val cs = ch * MapGround.S * fine
        val ground = BufferedImage((c1x - c0x + 1) * cs, (c1y - c0y + 1) * cs, BufferedImage.TYPE_INT_ARGB)
        var groundMs = 0L; var groundBytes = 0L
        for (cy in c0y..c1y) for (cx in c0x..c1x) {
            val t0 = System.nanoTime()
            val img = MapGround.drawFine(map, cx, cy, fine)
            groundMs += (System.nanoTime() - t0) / 1_000_000
            groundBytes += img.pixels.size * 4L
            ground.setRGB((cx - c0x) * cs, (cy - c0y) * cs, img.width, img.height, img.pixels, 0, img.width)
        }
        // 2) the trees, drawn anew for this fineness
        val t1 = System.nanoTime()
        val objs = ArrayList<WorldArt.Obj>()
        for (ty in ty0 - 3..ty1 + 3) for (tx in tx0 - 3..tx1 + 3) if (map.inside(tx, ty)) objs += MapFlora.treesFine(map, tx, ty, fine, ink)
        val treeMs = (System.nanoTime() - t1) / 1_000_000
        val treeBytes = objs.map { it.img }.distinct().sumOf { it.pixels.size * 4L }
        // 3) the hero, standing, facing us
        val t2 = System.nanoTime()
        val pic = MapFigure.draw(hero, slot, 0, moving = false, fine = fine)
        val heroMs = (System.nanoTime() - t2) / 1_000_000
        report.append("fein $fine (${T * dens} je Kachel): Boden ${(c1x - c0x + 1) * (c1y - c0y + 1)} Stücke ${groundMs} ms, ${groundBytes / 1024} KB; " +
            "Bäume ${objs.size} ${treeMs} ms, ${treeBytes / 1024} KB; Held ${heroMs} ms, ${pic.pixels.size * 4 / 1024} KB je Bild\n")

        // the camera: the hero's feet in the middle of the panel
        val s = 5f; val k = 0.703125f
        val footX = (hx * T + T / 2f) * s; val footY = (hy * T + T - 3) * s - T / 2f * s
        val ox = pw / 2f - k * (footX - footY); val oy = ph * 0.62f - k / 2 * (footX + footY)
        fun scrX(px: Float, py: Float) = k * (px - py) + ox
        fun scrY(px: Float, py: Float) = k / 2 * (px + py) + oy

        val out = BufferedImage(pw, ph, BufferedImage.TYPE_INT_ARGB)
        val g = out.createGraphics()
        g.color = Color(10, 10, 12); g.fillRect(0, 0, pw, ph)
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR)
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY)
        val m = AffineTransform(k.toDouble(), k / 2.0, -k.toDouble(), k / 2.0, ox.toDouble(), oy.toDouble())
        m.scale(s.toDouble(), s.toDouble())
        m.translate((c0x * ch * T).toDouble(), (c0y * ch * T).toDouble())
        m.scale(1.0 / dens, 1.0 / dens)
        g.drawImage(ground, m, null)

        class Put(val depth: Float, val img: PixelImage, val x: Int, val y: Int, val d: Int)
        val puts = ArrayList<Put>()
        for (o in objs) puts += Put(o.sortY + o.x + o.img.width / o.density / 2f, o.img, o.x, o.y, o.density)
        val heroX = hx * T + T / 2 - pic.width / 2 / dens
        val heroY = hy * T + T - 3 - (pic.height - MapFigure.FOOT_BELOW * fine) / dens
        puts += Put((hy * T + T - 1) + (hx * T + T / 2f), pic, heroX, heroY, dens)
        puts.sortBy { it.depth }
        // the hero's soft shadow on the ground, as WorldArt.shadow, at his feet
        for (p in puts) {
            if (p.img === pic) {
                val fx = scrX(footX, footY); val fy = scrY(footX, footY)
                g.color = Color(10, 8, 6, 110); g.fillOval((fx - 9 * s / 2).toInt(), (fy - 2.2f * s / 2).toInt(), (9 * s).toInt(), (2.2f * s).toInt())
            }
            val dw = p.img.width * s / p.d; val dh = p.img.height * s / p.d
            val sx = (p.x * s); val sy = (p.y * s)
            val fx = sx + dw / 2f; val fy = sy + dh - T / 2f * s
            val bi = BufferedImage(p.img.width, p.img.height, BufferedImage.TYPE_INT_ARGB)
            bi.setRGB(0, 0, p.img.width, p.img.height, p.img.pixels, 0, p.img.width)
            g.drawImage(bi, (scrX(fx, fy) - dw / 2f).toInt(), (scrY(fx, fy) - dh).toInt(), dw.toInt(), dh.toInt(), null)
            if (p.img === pic) {
                val row = (0 until pic.height).first { y -> (0 until pic.width).any { x -> pic.opaque(x, y) } }
                heroTop = (scrY(fx, fy) - dh + row * s / p.d).toInt()
            }
        }
        g.dispose()
        return out
    }

    // a first run warms the drawers up, so the times measured are those of a running game; with the ink the other way
    // round, so the trees measured after are drawn anew (they are kept by fineness and ink)
    side(1, true); side(2, false)
    report.setLength(0)
    val alt = side(1, false)
    val neu = side(2, true)
    Doll.ink = false; Doll.inkScale = 1.0

    val bar = 40; val gap = 12
    val zoom = 2; val zw = pw / zoom
    val zh0 = (ph * 0.62f).toInt() + 14 - (heroTop - 10)
    val sheet = BufferedImage(pw * 2 + gap, bar + ph + bar + zh0 * zoom, BufferedImage.TYPE_INT_RGB)
    val g = sheet.createGraphics()
    g.color = Color(18, 16, 20); g.fillRect(0, 0, sheet.width, sheet.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font("DejaVu Sans", Font.BOLD, 19)
    g.color = Color(226, 220, 206)
    g.drawString("ALT – wie heute (64 je Kachel)", 12, 27)
    g.drawString("NEU – 128 je Kachel, mit Tusche", pw + gap + 12, 27)
    g.drawImage(alt, 0, bar, null); g.drawImage(neu, pw + gap, bar, null)
    // below: the middle around the hero, twice as large, pixel for pixel
    g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR)
    // the hero from head to feet
    val zh = zh0
    val zx = pw / 2 - zw / 2; val zy = heroTop - 10
    for ((i, img) in listOf(alt, neu).withIndex()) {
        val x = i * (pw + gap)
        g.drawImage(img, x, bar + ph + bar, x + zw * zoom, bar + ph + bar + zh * zoom, zx, zy, zx + zw, zy + zh, null)
    }
    g.font = Font("DejaVu Sans", Font.PLAIN, 17); g.color = Color(200, 194, 180)
    g.drawString("Mitte zweifach vergrößert", 12, bar + ph + 27)
    g.drawString("Mitte zweifach vergrößert", pw + gap + 12, bar + ph + 27)
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(sheet, "png", File("build/screens/vergleich348.png"))
    ImageIO.write(alt, "png", File("build/screens/vergleich348_alt.png"))
    ImageIO.write(neu, "png", File("build/screens/vergleich348_neu.png"))
    // the whole map, if every chunk of its ground were kept as in the game (MapGround), and all hero pictures (MapFigure)
    val chunks = ((map.width + MapGround.CH - 1) / MapGround.CH) * ((map.height + MapGround.CH - 1) / MapGround.CH)
    for (f in 1..2) {
        val gr = chunks.toLong() * (MapGround.CH * MapGround.S * f).let { it.toLong() * it } * 4
        val he = MapFigure.YAWS.toLong() * MapFigure.PICS * MapFigure.W * MapFigure.H * f * f * 4
        report.append("fein $f, ganze Karte ${map.width}×${map.height}: Boden ${gr / 1024 / 1024} MB, alle Heldenbilder ${he / 1024 / 1024} MB\n")
    }
    print(report)
    File("build/screens/vergleich348.txt").writeText(report.toString())
}
