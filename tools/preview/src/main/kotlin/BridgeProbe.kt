package preview

import java.awt.AlphaComposite
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.GradientPaint
import java.awt.Graphics2D
import java.awt.MultipleGradientPaint
import java.awt.RadialGradientPaint
import java.awt.RenderingHints
import java.awt.geom.Ellipse2D
import java.awt.geom.Path2D
import java.awt.geom.Point2D
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.sqrt

/**
 * 69e probe (draft): the intro picture `[69.intro.2]` (river and bridge, the lights of Bornim beyond) at full resolution,
 * seen through the traveller's eyes from the south road, twice: (1) precise, with the forms and colours of the diagonal
 * world (flat plank bridge, half-timbered houses on a stone base, firs, the wheat field, the signpost); (2) the same picture
 * slightly abstracted: fewer details, calmer forms, a touch of paint. Only a probe for the user's choice, not in the game.
 */
fun renderBridgeProbe() {
    val precise = BridgePainter(detail = true).paint()
    val abstracted = brush(kuwahara(BridgePainter(detail = false).paint(), 7))
    File("build/screens").mkdirs()
    ImageIO.write(precise, "png", File("build/screens/probe69e_1_praezise.png"))
    ImageIO.write(abstracted, "png", File("build/screens/probe69e_2_abstrahiert.png"))
    // both side by side, each with its text below as in the app
    val text = "Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht."
    val w = BridgePainter.W; val h = BridgePainter.H; val box = 170
    val out = BufferedImage(w * 2 + 30, h + box, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x101014); g.fillRect(0, 0, out.width, out.height)
    for ((i, img) in listOf(precise, abstracted).withIndex()) {
        val ox = i * (w + 30)
        g.drawImage(img, ox, 0, null)
        g.color = Color(0x96784A); g.drawRect(ox + 30, h + 18, w - 60, box - 36)
        g.color = Color(0xEBE1C8); g.font = Font(Font.SANS_SERIF, Font.PLAIN, 34)
        var line = ""; var ly = h + 68
        for (word in text.split(" ")) {
            if (g.fontMetrics.stringWidth("$line $word") > w - 120) { g.drawString(line.trim(), ox + 54, ly); ly += 46; line = "" }
            line += " $word"
        }
        g.drawString(line.trim(), ox + 54, ly)
    }
    ImageIO.write(out, "png", File("build/screens/probe69e_beide.png"))
    println("wrote build/screens/probe69e_beide.png")
}

private class BridgePainter(val detail: Boolean) {
    companion object { const val W = 1080; const val H = 1200 }

    val img = BufferedImage(W, H, BufferedImage.TYPE_INT_ARGB)
    val g: Graphics2D = img.createGraphics().apply {
        setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
        setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY)
        setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE)
    }

    // the camera: the traveller's eyes on the south road, looking north over the bridge
    val hy = 640.0; val f = 1400.0; val eye = 1.7; val cx = W / 2.0
    /** The traveller stands at the left edge of the road and looks a little to the right, at the bridge. */
    val camX = -1.4; val pan = f * 1.4 / 12.0
    fun sx(x: Double, z: Double) = cx + f * (x - camX) / z - pan
    fun sy(y: Double, z: Double) = hy + f * (eye - y) / z

    /** The river between its banks. */
    val ZN = 9.0; val ZF = 16.0

    // the moon, high up on the left
    val moonX = 250.0; val moonY = 190.0

    // the night colours of the diagonal world (village at 23:00)
    val skyTop = Color(0x060A1C); val skyLow = Color(0x2A3654)
    val grass = Color(0x1C2824); val grassLit = Color(0x2E3E36)
    val earth = Color(0x34302E); val earthLit = Color(0x4A4440)
    val water = Color(0x0B1520); val waterLit = Color(0x1E2C3E)
    val plank = Color(0x2E2622); val plankLit = Color(0x4C4038)
    val plaster = Color(0x3C3E4A); val plasterLit = Color(0x5A5C68)
    val timber = Color(0x1A1616); val stone = Color(0x2A2C34); val stoneLit = Color(0x40424C)
    val roof = Color(0x1E1E26); val roofLit = Color(0x34343E)
    val fir = Color(0x0E1A18); val firLit = Color(0x22362E)
    val wheat = Color(0x4A4430); val wheatLit = Color(0x6E6646)
    val warm = Color(0xFFC060); val warmDeep = Color(0xE07A28)
    val moonCool = Color(0xA8BCE0)

    fun rnd(i: Int, s: Int): Double {
        var n = i * 374761393 + s * 668265263
        n = (n xor (n ushr 13)) * 1274126177
        return ((n xor (n ushr 16)) and 0x7FFFFFFF) % 100000 / 100000.0
    }

    fun mix(a: Color, b: Color, t: Double): Color {
        val u = t.coerceIn(0.0, 1.0)
        return Color((a.red + (b.red - a.red) * u).toInt(), (a.green + (b.green - a.green) * u).toInt(), (a.blue + (b.blue - a.blue) * u).toInt())
    }
    fun alpha(c: Color, a: Double) = Color(c.red, c.green, c.blue, (a.coerceIn(0.0, 1.0) * 255).toInt())
    /** Far things sink into the night air. */
    fun far(c: Color, z: Double) = mix(c, Color(0x1A2238), 1 - exp(-z / 160.0))

    fun poly(c: Color, vararg p: Double) {
        val path = Path2D.Double()
        path.moveTo(p[0], p[1])
        for (i in 2 until p.size step 2) path.lineTo(p[i], p[i + 1])
        path.closePath()
        g.color = c; g.fill(path)
    }
    /** A quad in the world: four corners (x, y, z). */
    fun quad(c: Color, vararg q: Double) =
        poly(c, sx(q[0], q[2]), sy(q[1], q[2]), sx(q[3], q[5]), sy(q[4], q[5]), sx(q[6], q[8]), sy(q[7], q[8]), sx(q[9], q[11]), sy(q[10], q[11]))
    fun line(c: Color, w: Double, x0: Double, y0: Double, x1: Double, y1: Double) {
        g.color = c; g.stroke = BasicStroke(w.toFloat(), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
        g.draw(java.awt.geom.Line2D.Double(x0, y0, x1, y1))
    }
    fun glow(x: Double, y: Double, r: Double, c: Color, a: Double) {
        if (r < 1) return
        g.paint = RadialGradientPaint(Point2D.Double(x, y), r.toFloat(), floatArrayOf(0f, 0.35f, 1f),
            arrayOf(alpha(c, a), alpha(c, a * 0.35), alpha(c, 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
        g.fill(Ellipse2D.Double(x - r, y - r, r * 2, r * 2))
    }

    fun paint(): BufferedImage {
        sky()
        forestBand()
        // the north bank, then the village from far to near
        poly(far(grass, 60.0), 0.0, hy, W.toDouble(), hy, W.toDouble(), sy(0.0, ZF), 0.0, sy(0.0, ZF))
        groundStrokes(ZF, 120.0, grassLit, 900)
        lane(ZF, 60.0)
        houses()
        river()
        bridge()
        mist()
        southBank()
        field()
        road()
        trees()
        signpost()
        vignette()
        return img
    }

    fun sky() {
        g.paint = GradientPaint(0f, 0f, skyTop, 0f, hy.toFloat(), skyLow); g.fillRect(0, 0, W, hy.toInt() + 2)
        // stars, fewer near the moon and near the horizon
        val n = if (detail) 520 else 160
        for (i in 0 until n) {
            val x = rnd(i, 1) * W; val y = rnd(i, 2) * hy * 0.85
            val dm = sqrt((x - moonX) * (x - moonX) + (y - moonY) * (y - moonY))
            if (dm < 110) continue
            val b = 0.35 + rnd(i, 3) * 0.6 * (1 - y / hy)
            val r = if (i % 17 == 0) 2.4 else 1.0 + rnd(i, 4) * 0.9
            g.color = alpha(Color(0xDCE4F8), b); g.fill(Ellipse2D.Double(x - r / 2, y - r / 2, r, r))
            if (i % 17 == 0) glow(x, y, 7.0, Color(0xC8D4F0), 0.25)
        }
        glow(moonX, moonY, 210.0, moonCool, 0.32)
        glow(moonX, moonY, 70.0, Color(0xDCE4F4), 0.5)
        g.color = Color(0xF2EEDA); g.fill(Ellipse2D.Double(moonX - 34, moonY - 34, 68.0, 68.0))
        if (detail) for ((dx, dy, r) in listOf(Triple(-10.0, -6.0, 11.0), Triple(9.0, 8.0, 8.0), Triple(-4.0, 14.0, 6.0))) {
            g.color = Color(0xD2CEBC); g.fill(Ellipse2D.Double(moonX + dx - r, moonY + dy - r, r * 2, r * 2))
        }
        // thin clouds lit from below
        for (k in 0 until 4) {
            val y = hy * (0.22 + k * 0.15); val x = W * (0.15 + 0.27 * k)
            val wd = 260.0 + k * 40
            g.paint = RadialGradientPaint(Point2D.Double(x, y), wd.toFloat(), floatArrayOf(0f, 1f),
                arrayOf(alpha(Color(0x3E4A6C), 0.55), alpha(Color(0x3E4A6C), 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
            val t = g.transform; g.translate(x, y); g.scale(1.0, 0.07); g.translate(-x, -y)
            g.fill(Ellipse2D.Double(x - wd, y - wd, wd * 2, wd * 2)); g.transform = t
        }
    }

    /** The Whisperwood beyond the village: a dark band of firs on the horizon. */
    fun forestBand() {
        for (i in 0 until 90) {
            val x = rnd(i, 11) * W; val z = 140.0 + rnd(i, 12) * 60
            val hgt = 14.0 + rnd(i, 13) * 10
            firShape(x, sy(0.0, z), f * hgt / z, f * hgt * 0.36 / z, far(fir, z), far(firLit, z), 0.4)
        }
        poly(far(fir, 150.0), 0.0, sy(0.0, 150.0) - 6, W.toDouble(), sy(0.0, 150.0) - 6, W.toDouble(), hy + 4, 0.0, hy + 4)
    }

    fun firShape(x: Double, base: Double, h: Double, w: Double, c: Color, lit: Color, litA: Double) {
        val tiers = 6
        for (k in 0 until tiers) {
            val t0 = k / tiers.toDouble(); val t1 = (k + 1.6) / tiers
            val yb = base - h * 0.12 - h * 0.88 * t0; val yt = base - h * 0.12 - h * 0.88 * t1.coerceAtMost(1.0)
            val half = w * (1 - t0 * 0.85) * 0.5
            // the tier's lower edge is ragged with twigs hanging down
            val pts = ArrayList<Double>()
            pts += listOf(x, yt)
            pts += listOf(x + half, yb)
            val teeth = if (detail) 7 else 3
            for (j in teeth downTo -teeth) {
                val tx = x + half * j / teeth
                pts += listOf(tx, yb - h * 0.035 * (1 - abs(j.toDouble()) / teeth) - (if (j % 2 == 0) 0.0 else h * 0.03))
            }
            pts += listOf(x - half, yb)
            poly(c, *pts.toDoubleArray())
            // the moon is on the left: the left edge of every tier catches it
            if (litA > 0) poly(alpha(lit, litA), x - half, yb, x, yt, x - half * 0.5, yb - h * 0.05, x - half * 0.75, yb - h * 0.01)
        }
        line(Color(0x141010), maxOf(1.0, w * 0.06), x, base, x, base - h * 0.14)
    }

    fun groundStrokes(z0: Double, z1: Double, c: Color, n: Int) {
        if (!detail) return
        for (i in 0 until n) {
            val z = z0 + (z1 - z0) * rnd(i, 21).let { it * it }
            val x = camX + pan * z / f + (rnd(i, 22) - 0.5) * z * W / f * 1.1
            val l = f * 0.25 / z
            val px = sx(x, z); val py = sy(0.0, z)
            line(alpha(far(c, z), 0.6), maxOf(0.8, f * 0.03 / z), px, py, px + (rnd(i, 23) - 0.5) * l, py - l)
        }
    }

    /** The village street beyond the bridge, packed earth. */
    fun lane(z0: Double, z1: Double) {
        quad(far(earth, 40.0), -1.6, 0.0, z0, 1.6, 0.0, z0, 1.4, 0.0, z1, -1.4, 0.0, z1)
    }

    data class House(val x: Double, val z: Double, val w: Double, val d: Double, val wall: Double, val roof: Double, val lit: List<Int>, val temple: Boolean = false)

    val houseList = listOf(
        House(-30.0, 58.0, 9.0, 7.0, 3.8, 3.4, listOf(1)),
        House(33.0, 62.0, 10.0, 7.0, 3.8, 3.6, listOf()),
        House(2.0, 72.0, 13.0, 10.0, 6.0, 5.0, listOf(0, 2), temple = true),
        House(-18.0, 42.0, 9.0, 7.0, 3.8, 3.4, listOf(0)),
        House(20.0, 45.0, 10.0, 7.0, 3.8, 3.6, listOf(2)),
        House(-7.5, 30.0, 8.0, 6.0, 3.6, 3.2, listOf(1)),
        House(9.0, 32.0, 8.5, 6.0, 3.6, 3.2, listOf(0, 2)),
    )
    /** Firs between the houses on the north bank (x, z, height). */
    val northFirs = listOf(Triple(-14.0, 26.0, 10.0), Triple(17.0, 27.0, 12.0), Triple(-3.5, 48.0, 10.0), Triple(10.0, 56.0, 11.0), Triple(-26.0, 50.0, 13.0), Triple(24.0, 22.0, 9.0))

    fun houses() {
        val items = houseList.map { it.z to { house(it, it.temple) } } +
            northFirs.map { (x, z, h) -> z + 3 to { firShape(sx(x, z), sy(0.0, z), f * h / z, f * h * 0.42 / z, far(fir, z), far(firLit, z), 0.6) } }
        for ((_, draw) in items.sortedByDescending { it.first }) draw()
    }

    /** Fine surface: stains and grain inside [shape], as the diagonal world's plaster, stone and shingles have them. */
    fun texture(shape: java.awt.Shape, z: Double, dark: Color, light: Color, n: Int, size: Double, flat: Double = 1.0) {
        if (!detail) return
        val clip = g.clip; g.clip(shape)
        val b = shape.bounds2D
        val k = (n * (b.width * b.height) / 10000.0).toInt().coerceIn(0, 6000)
        for (i in 0 until k) {
            val x = b.x + rnd(i, 201 + b.x.toInt()) * b.width; val y = b.y + rnd(i, 202 + b.y.toInt()) * b.height
            val r = (size * f / z) * (0.4 + rnd(i, 203))
            g.color = alpha(far(if (rnd(i, 204) > 0.5) light else dark, z), 0.1 + 0.14 * rnd(i, 205))
            g.fill(Ellipse2D.Double(x - r, y - r * flat, r * 2, r * 2 * flat))
        }
        g.clip = clip
    }
    fun quadShape(vararg q: Double) = Path2D.Double().apply {
        moveTo(sx(q[0], q[2]), sy(q[1], q[2])); for (i in 3 until 12 step 3) lineTo(sx(q[i], q[i + 2]), sy(q[i + 1], q[i + 2])); closePath()
    }

    fun house(hs: House, temple: Boolean) {
        val x0 = hs.x - hs.w / 2; val x1 = hs.x + hs.w / 2; val z0 = hs.z; val z1 = hs.z + hs.d
        val zr = (z0 + z1) / 2; val top = hs.wall + hs.roof
        val wallC = far(if (temple) stone else plaster, z0); val wallLit = far(if (temple) stoneLit else plasterLit, z0)
        // the side we see: the one facing the road; the moon from the left lights left sides
        val sideX = if (hs.x > 0) x0 else x1
        val sideC = if (hs.x > 0) wallLit else wallC
        quad(sideC, sideX, 0.0, z0, sideX, 0.0, z1, sideX, hs.wall, z1, sideX, hs.wall, z0)
        // the gable on that side
        poly(sideC, sx(sideX, z0), sy(hs.wall, z0), sx(sideX, z1), sy(hs.wall, z1), sx(sideX, zr), sy(top, zr))
        // the front
        quad(wallC, x0, 0.0, z0, x1, 0.0, z0, x1, hs.wall, z0, x0, hs.wall, z0)
        texture(quadShape(x0, 0.0, z0, x1, 0.0, z0, x1, hs.wall, z0, x0, hs.wall, z0), z0, Color(0x2A2A30), plasterLit, 40, if (temple) 0.12 else 0.18, if (temple) 0.5 else 1.0)
        texture(quadShape(sideX, 0.0, z0, sideX, 0.0, z1, sideX, hs.wall, z1, sideX, hs.wall, z0), z0, Color(0x2A2A30), plasterLit, 40, 0.18)
        // the stone base and the timber frame
        if (!temple) {
            quad(far(stone, z0), x0, 0.0, z0, x1, 0.0, z0, x1, 0.6, z0, x0, 0.6, z0)
            texture(quadShape(x0, 0.0, z0, x1, 0.0, z0, x1, 0.6, z0, x0, 0.6, z0), z0, Color(0x16181E), stoneLit, 260, 0.14, 0.6)
            if (detail) {
                val tw = maxOf(1.2, f * 0.22 / z0)
                val tc = far(timber, z0)
                line(tc, tw, sx(x0, z0), sy(0.6, z0), sx(x1, z0), sy(0.6, z0))
                line(tc, tw, sx(x0, z0), sy(hs.wall * 0.55, z0), sx(x1, z0), sy(hs.wall * 0.55, z0))
                line(tc, tw, sx(x0, z0), sy(hs.wall, z0), sx(x1, z0), sy(hs.wall, z0))
                val n = (hs.w / 1.6).toInt()
                for (k in 0..n) {
                    val x = x0 + hs.w * k / n
                    line(tc, tw, sx(x, z0), sy(0.6, z0), sx(x, z0), sy(hs.wall, z0))
                    if (k < n && k % 2 == 0) line(tc, tw * 0.8, sx(x, z0), sy(0.6, z0), sx(x + hs.w / n, z0), sy(hs.wall * 0.55, z0))
                }
                // the frame on the side
                if (abs(sx(sideX, z1) - sx(sideX, z0)) > 90) for (k in 0..3) { val z = z0 + hs.d * k / 3; line(tc, tw * 0.9, sx(sideX, z), sy(0.6, z), sx(sideX, z), sy(hs.wall, z)) }
            } else {
                // only the main beams
                val tw = maxOf(1.2, f * 0.26 / z0)
                line(far(timber, z0), tw, sx(x0, z0), sy(hs.wall * 0.55, z0), sx(x1, z0), sy(hs.wall * 0.55, z0))
            }
        } else if (detail) {
            // ashlar courses on the temple
            for (k in 1..9) { val y = hs.wall * k / 10; line(far(Color(0x22242C), z0), 1.0, sx(x0, z0), sy(y, z0), sx(x1, z0), sy(y, z0)) }
        }
        // the roof: the slope towards us, its eave a little over the wall
        val ov = 0.5
        quad(far(roof, z0), x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr)
        // moonlight lies on the left part of the slope
        quad(alpha(far(roofLit, z0), 0.55), x0 - ov, hs.wall - 0.3, z0 - ov, x0 + hs.w * 0.35, hs.wall - 0.3, z0 - ov, x0 + hs.w * 0.35, top, zr, x0 - ov, top, zr)
        texture(quadShape(x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr), z0, Color(0x101016), roofLit, 120, 0.12, 0.35)
        if (detail) for (k in 1..7) {
            val t = k / 8.0
            val y = hs.wall - 0.3 + (top - hs.wall + 0.3) * t; val z = z0 - ov + (zr - z0 + ov) * t
            line(far(Color(0x16161C), z0), 1.0, sx(x0 - ov, z), sy(y, z), sx(x1 + ov, z), sy(y, z))
        }
        // the ridge catches the moon
        line(far(roofLit, z0), maxOf(1.0, f * 0.12 / zr), sx(x0 - ov, zr), sy(top, zr), sx(x1 + ov, zr), sy(top, zr))
        // a chimney on the houses
        if (!temple) {
            val chx = x0 + hs.w * 0.72
            quad(far(stone, z0), chx, top - 1.2, zr + 0.5, chx + 0.7, top - 1.2, zr + 0.5, chx + 0.7, top + 0.8, zr + 0.5, chx, top + 0.8, zr + 0.5)
        }
        // windows: three slots on the front, some lit
        val wy0 = if (temple) 2.0 else 1.3; val wy1 = if (temple) 4.6 else 2.4
        for (k in 0 until 3) {
            if (temple && k == 1) continue
            val wx = x0 + hs.w * (0.2 + 0.3 * k) - 0.45; val wx1 = wx + 0.9
            val lit = k in hs.lit
            if (lit) {
                val mx = sx((wx + wx1) / 2, z0); val my = sy((wy0 + wy1) / 2, z0)
                glow(mx, my, f * 3.2 / z0, warmDeep, 0.35)
                glow(mx, my, f * 1.2 / z0, warm, 0.5)
            }
            quad(if (lit) warm else far(Color(0x0C0E16), z0), wx, wy0, z0, wx1, wy0, z0, wx1, wy1, z0, wx, wy1, z0)
            if (detail) {
                val tw = maxOf(1.0, f * 0.08 / z0)
                val wc = far(timber, z0)
                line(wc, tw, sx((wx + wx1) / 2, z0), sy(wy0, z0), sx((wx + wx1) / 2, z0), sy(wy1, z0))
                line(wc, tw, sx(wx, z0), sy((wy0 + wy1) / 2, z0), sx(wx1, z0), sy((wy0 + wy1) / 2, z0))
            }
        }
        // the door
        if (temple) {
            val dx = hs.x - 1.0
            quad(far(Color(0x0A0A10), z0), dx, 0.0, z0, dx + 2.0, 0.0, z0, dx + 2.0, 3.2, z0, dx, 3.2, z0)
            for (tx in listOf(dx - 0.8, dx + 2.8)) {
                glow(sx(tx, z0), sy(2.6, z0), f * 2.4 / z0, warmDeep, 0.4)
                glow(sx(tx, z0), sy(2.6, z0), f * 0.6 / z0, warm, 0.9)
            }
        } else {
            val dx = x0 + hs.w * 0.5 - 0.5
            quad(far(Color(0x241A16), z0), dx, 0.0, z0, dx + 1.0, 0.0, z0, dx + 1.0, 2.1, z0, dx, 2.1, z0)
        }
    }

    /** The river: still, dark, the moon and the windows mirrored in it. */
    fun river() {
        val zn = ZN; val zf = ZF
        val yN = sy(0.0, zn); val yF = sy(0.0, zf)
        g.paint = GradientPaint(0f, yF.toFloat(), mix(water, skyLow, 0.35), 0f, yN.toFloat(), water)
        g.fill(java.awt.Rectangle(0, yF.toInt() - 1, W, (yN - yF).toInt() + 3))
        // the far bank: a dark line of earth and reeds
        poly(far(Color(0x161C1A), 24.0), 0.0, yF - 3, W.toDouble(), yF - 3, W.toDouble(), yF + 2, 0.0, yF + 2)
        // the bridge's dark mirror image under it
        quad(alpha(Color(0x04070A), 0.7), -1.6, 0.0, zn, 1.6, 0.0, zn, 1.6, 0.0, zf, -1.6, 0.0, zf)
        // the moon on the water: a broken column of light
        val n = if (detail) 140 else 50
        for (i in 0 until n) {
            val t = rnd(i, 31)
            val z = zf - (zf - zn) * t
            val y = sy(0.0, z)
            val spread = 14.0 + 50 * t
            val x = moonX + (rnd(i, 32) - 0.5) * spread * 2
            val l = (8.0 + rnd(i, 33) * 22) * (0.6 + t)
            line(alpha(Color(0xD8E0F0), 0.25 + 0.5 * (1 - t) * rnd(i, 34)), 1.0 + 1.5 * t, x - l / 2, y, x + l / 2, y)
        }
        // ripples as in the diagonal world: short light strokes
        if (detail) for (i in 0 until 260) {
            val t = rnd(i, 41); val z = zf - (zf - zn) * t; val y = sy(0.0, z)
            val x = rnd(i, 42) * W; val l = 6.0 + 26 * t
            line(alpha(waterLit, 0.7), 1.0 + t, x, y, x + l, y + (rnd(i, 43) - 0.5) * 2)
        }
        // the lit windows mirrored: warm dashes under each glow
        for (hs in houseList) for (k in hs.lit) {
            val z = hs.z; val wx = hs.x - hs.w / 2 + hs.w * (0.2 + 0.3 * k)
            val x = sx(wx, z)
            // the mirror image of a window lies as far below the water line as the window stands above the bank
            val depth = (sy(0.0, z) - sy(2.0, z)) * 1.4
            val m = if (detail) 8 else 4
            for (j in 0 until m) {
                val t = j / m.toDouble()
                val y = yF + 3 + depth * t + rnd(j, (wx * 10).toInt()) * 3
                if (y > yN - 2) break
                val l = (4.0 + rnd(j, 51 + (wx * 3).toInt()) * 9) * (1 + t)
                line(alpha(warm, 0.5 * (1 - t)), 1.6, x - l / 2, y, x + l / 2, y)
            }
        }
    }

    /** The bridge: flat planks over beams, no railing, as in the diagonal world; posts stand in the water. */
    fun bridge() {
        val z0 = ZN - 0.5; val z1 = ZF + 0.7; val y = 0.32; val hw = 1.5
        // posts into the water, far ones first
        for (z in listOf(15.0, 12.6, 10.4)) for (x in listOf(-hw + 0.15, hw - 0.15)) {
            quad(Color(0x1A1412), x - 0.13, -0.4, z, x + 0.13, -0.4, z, x + 0.13, y, z, x - 0.13, y, z)
            line(alpha(Color(0x8090A8), 0.35), 1.4, sx(x - 0.3, z), sy(-0.02, z), sx(x + 0.3, z), sy(-0.02, z))
        }
        // the edge beam (we see its face on both sides), then the deck
        quad(Color(0x1E1816), -hw, y - 0.18, z0, hw, y - 0.18, z0, hw, y, z0, -hw, y, z0)
        quad(plank, -hw, y, z0, hw, y, z0, hw, y, z1, -hw, y, z1)
        // the moon from the left lights the deck faintly, more on the left
        g.paint = GradientPaint(sx(-hw, 9.0).toFloat(), 0f, alpha(plankLit, 0.75), sx(hw, 9.0).toFloat(), 0f, alpha(plankLit, 0.1))
        val deck = Path2D.Double().apply {
            moveTo(sx(-hw, z0), sy(y, z0)); lineTo(sx(hw, z0), sy(y, z0)); lineTo(sx(hw, z1), sy(y, z1)); lineTo(sx(-hw, z1), sy(y, z1)); closePath()
        }
        g.fill(deck)
        // planks across, with gaps; every plank a little different
        val n = if (detail) 34 else 10
        for (k in 0..n) {
            val z = z0 + (z1 - z0) * k / n
            line(Color(0x120E0C), if (detail) maxOf(1.0, f * 0.03 / z) else 1.5, sx(-hw, z), sy(y, z), sx(hw, z), sy(y, z))
            if (detail && k < n) {
                val zm = z + (z1 - z0) / n / 2
                val shade = rnd(k, 61)
                if (shade > 0.6) quad(alpha(Color(0x5A4C44), 0.25), -hw, y, z + 0.02, hw, y, z + 0.02, hw, y, zm + 0.1, -hw, y, zm + 0.1)
                // nail heads where the planks lie on the beams
                for (x in listOf(-hw + 0.2, hw - 0.2)) g.fill(Ellipse2D.Double(sx(x, zm) - 1.2, sy(y, zm) - 1.2, 2.4, 2.4))
            }
        }
        // the side beams along the deck
        line(Color(0x18120F), maxOf(2.0, f * 0.12 / z0), sx(-hw, z0), sy(y, z0), sx(-hw, z1), sy(y, z1))
        line(Color(0x18120F), maxOf(2.0, f * 0.12 / z0), sx(hw, z0), sy(y, z0), sx(hw, z1), sy(y, z1))
    }

    /** A breath of mist over the water, lit by the moon. */
    fun mist() {
        val y0 = sy(1.2, ZF); val y1 = sy(0.0, ZN)
        g.paint = GradientPaint(0f, y0.toFloat(), alpha(Color(0x6A7896), 0.0), 0f, ((y0 + y1) / 2).toFloat(), alpha(Color(0x6A7896), 0.16))
        g.fillRect(0, y0.toInt(), W, ((y1 - y0) / 2).toInt() + 1)
        g.paint = GradientPaint(0f, ((y0 + y1) / 2).toFloat(), alpha(Color(0x6A7896), 0.16), 0f, y1.toFloat(), alpha(Color(0x6A7896), 0.0))
        g.fillRect(0, ((y0 + y1) / 2).toInt(), W, ((y1 - y0) / 2).toInt() + 1)
    }

    /** The south bank: grass in the moonlight, reeds at the water. */
    fun southBank() {
        val yN = sy(0.0, ZN)
        // a ragged bank line
        val p = Path2D.Double(); p.moveTo(0.0, H.toDouble())
        for (x in 0..W step 12) p.lineTo(x.toDouble(), yN - 2 + 6 * kotlin.math.sin(x / 37.0) + 4 * rnd(x, 71))
        p.lineTo(W.toDouble(), H.toDouble()); p.closePath()
        g.paint = GradientPaint(0f, yN.toFloat(), mix(grass, grassLit, 0.4), 0f, H.toFloat(), grass); g.fill(p)
        groundStrokes(3.4, ZN, grassLit, 1400)
        if (detail) for (i in 0 until 160) {
            val x = rnd(i, 72) * W; if (x in sx(-2.0, ZN)..sx(2.0, ZN)) continue
            val y = yN + rnd(i, 73) * 10; val hgt = 14.0 + rnd(i, 74) * 26
            line(alpha(Color(0x2A3830), 0.9), 1.6, x, y, x + (rnd(i, 75) - 0.5) * 10, y - hgt)
        } else for (i in 0 until 40) {
            val x = rnd(i, 72) * W; if (x in sx(-2.0, ZN)..sx(2.0, ZN)) continue
            line(Color(0x22302A), 5.0, x, yN + 4, x + 3, yN - 22)
        }
    }

    /** The wheat field on the right, silver-gold under the moon. */
    fun field() {
        val x0 = 3.6; val x1 = 30.0; val z0 = 1.8; val z1 = ZN - 0.6; val top = 1.05
        quad(wheat, x0, top, z0, x1, top, z0, x1, top, z1, x0, top, z1)
        g.paint = GradientPaint(sx(x0, 8.0).toFloat(), sy(top, z1).toFloat(), alpha(wheatLit, 0.5), sx(x0, 8.0).toFloat(), sy(top, z0).toFloat(), alpha(wheatLit, 0.0))
        val path = Path2D.Double().apply {
            moveTo(sx(x0, z0), sy(top, z0)); lineTo(sx(x1, z0), sy(top, z0)); lineTo(sx(x1, z1), sy(top, z1)); lineTo(sx(x0, z1), sy(top, z1)); closePath()
        }
        g.fill(path)
        val n = if (detail) 2600 else 500
        for (i in 0 until n) {
            val z = z0 + (z1 - z0) * rnd(i, 81)
            val x = x0 + (minOf(x1, z * 1.1) - x0) * rnd(i, 82).let { it * it }
            val px = sx(x, z); val py = sy(0.0, z)
            val l = f * top * (0.85 + 0.2 * rnd(i, 84)) / z
            val c = if (rnd(i, 83) > 0.5) wheatLit else Color(0x3A3424)
            line(alpha(c, 0.8), if (detail) maxOf(1.0, f * 0.025 / z) else maxOf(2.0, f * 0.06 / z), px, py, px - l * 0.15, py - l)
            if (detail && i % 3 == 0) { g.color = alpha(Color(0x8A8058), 0.7); g.fill(Ellipse2D.Double(px - l * 0.17 - 1.2, py - l - 3, 2.4, 5.0)) }
        }
    }

    /** The road from the south: packed earth with two wheel ruts and grass in the middle. */
    fun road() {
        val z0 = 3.2; val z1 = ZN - 0.4
        quad(earth, -1.7, 0.0, z0, 1.7, 0.0, z0, 1.55, 0.0, z1, -1.55, 0.0, z1)
        g.paint = GradientPaint(sx(-1.7, 4.0).toFloat(), 0f, alpha(earthLit, 0.6), sx(1.7, 4.0).toFloat(), 0f, alpha(earthLit, 0.0))
        val p = Path2D.Double().apply {
            moveTo(sx(-1.7, z0), sy(0.0, z0)); lineTo(sx(1.7, z0), sy(0.0, z0)); lineTo(sx(1.55, z1), sy(0.0, z1)); lineTo(sx(-1.55, z1), sy(0.0, z1)); closePath()
        }
        g.fill(p)
        for (x in listOf(-0.75, 0.75)) quad(alpha(Color(0x221E1C), 0.25), x - 0.14, 0.0, z0, x + 0.14, 0.0, z0, x + 0.12, 0.0, z1, x - 0.12, 0.0, z1)
        if (detail) for (i in 0 until 900) {
            val z = z0 + (z1 - z0) * rnd(i, 91).let { it * it }
            val x = (rnd(i, 92) - 0.5) * 3.2
            val r = f * (0.008 + rnd(i, 93) * 0.018) / z
            g.color = alpha(if (rnd(i, 94) > 0.5) Color(0x5A5450) else Color(0x1E1A18), 0.7)
            g.fill(Ellipse2D.Double(sx(x, z) - r, sy(0.0, z) - r * 0.5, r * 2, r))
        }
    }

    fun trees() {
        // firs flanking the road on the south bank, near ones last
        val list = listOf(
            Triple(5.6, 8.7, 11.0),
        ).sortedByDescending { it.second }
        for ((x, z, h) in list) {
            val bx = sx(x, z); val by = sy(0.0, z)
            // a shadow pool under it
            g.color = alpha(Color(0x05080A), 0.5); g.fill(Ellipse2D.Double(bx - f * 2.2 / z, by - f * 0.5 / z, f * 4.4 / z, f * 1.0 / z))
            firShape(bx, by, f * h / z, f * h * 0.42 / z, fir, firLit, if (detail) 0.75 else 0.55)
            if (detail) for (i in 0 until 40) {
                // needle tufts along the tiers
                val t = rnd(i + (x * 7).toInt(), 101); val yy = by - f * h / z * (0.15 + 0.8 * t)
                val half = f * h * 0.42 / z * 0.5 * (1 - t * 0.85)
                val xx = bx - half + 2 * half * rnd(i, 102)
                line(alpha(if (xx < bx) firLit else Color(0x0A1412), 0.8), 1.3, xx, yy, xx + (rnd(i, 103) - 0.5) * 8, yy + 6)
            }
        }
    }

    /** The signpost at the bridge (67): a post with one board, dark wood, the moon on its left edge. */
    fun signpost() {
        val x = -2.9; val z = 8.1
        val px = sx(x, z); val base = sy(0.0, z); val top = sy(1.6, z)
        line(Color(0x1E1714), f * 0.12 / z, px, base, px, top)
        line(alpha(Color(0x5A4C44), 0.8), 1.4, px - f * 0.06 / z, base, px - f * 0.06 / z, top)
        val bw = f * 1.1 / z; val bh = f * 0.38 / z; val by = sy(1.4, z)
        poly(Color(0x2A201C), px - bw * 0.15, by, px + bw, by - bh * 0.1, px + bw + bh * 0.4, by + bh * 0.4, px + bw, by + bh * 0.9, px - bw * 0.15, by + bh)
        line(alpha(Color(0x6A5C50), 0.8), 1.4, px - bw * 0.15, by, px + bw, by - bh * 0.1)
        if (detail) for (k in 0 until 3) line(Color(0x161210), 1.4, px + bw * (0.05 + 0.25 * k), by + bh * 0.4, px + bw * (0.2 + 0.25 * k), by + bh * 0.42)
    }

    fun vignette() {
        g.paint = RadialGradientPaint(Point2D.Double(cx, H * 0.48), (H * 0.8).toFloat(), floatArrayOf(0.45f, 1f),
            arrayOf(Color(0, 0, 0, 0), Color(0, 0, 0, 170)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
        g.composite = AlphaComposite.SrcOver
        g.fillRect(0, 0, W, H)
    }
}

/** Brush strokes in the picture's own colours: short, soft, mostly lying with the ground, so the surfaces look painted. */
private fun brush(src: BufferedImage): BufferedImage {
    val w = src.width; val h = src.height
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
    g.drawImage(src, 0, 0, null)
    fun rnd(i: Int, s: Int): Double {
        var n = i * 374761393 + s * 668265263
        n = (n xor (n ushr 13)) * 1274126177
        return ((n xor (n ushr 16)) and 0x7FFFFFFF) % 100000 / 100000.0
    }
    for (i in 0 until 26000) {
        val x = rnd(i, 1) * w; val y = rnd(i, 2) * h
        val c = src.getRGB(x.toInt().coerceIn(0, w - 1), y.toInt().coerceIn(0, h - 1))
        // the colour a little further along the stroke, so strokes never smear across an edge
        val len = 10.0 + rnd(i, 3) * 18
        val ang = (rnd(i, 4) - 0.5) * 0.5 + (if (y < h * 0.42) 0.0 else (rnd(i, 5) - 0.5) * 0.6)
        val ex = x + kotlin.math.cos(ang) * len; val ey = y + kotlin.math.sin(ang) * len
        val c2 = src.getRGB(ex.toInt().coerceIn(0, w - 1), ey.toInt().coerceIn(0, h - 1))
        val d = abs((c shr 16 and 0xFF) - (c2 shr 16 and 0xFF)) + abs((c shr 8 and 0xFF) - (c2 shr 8 and 0xFF)) + abs((c and 0xFF) - (c2 and 0xFF))
        if (d > 24) continue
        val jit = ((rnd(i, 6) - 0.5) * 14).toInt()
        val col = Color(((c shr 16 and 0xFF) + jit).coerceIn(0, 255), ((c shr 8 and 0xFF) + jit).coerceIn(0, 255), ((c and 0xFF) + jit).coerceIn(0, 255), 90)
        g.color = col; g.stroke = BasicStroke((3.0 + rnd(i, 7) * 4).toFloat(), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
        g.draw(java.awt.geom.Line2D.Double(x, y, ex, ey))
    }
    return out
}

/** A painter's filter: every pixel takes the mean colour of the calmest of the four squares around it (Kuwahara). */
private fun kuwahara(src: BufferedImage, r: Int): BufferedImage {
    val w = src.width; val h = src.height
    val px = src.getRGB(0, 0, w, h, null, 0, w)
    val sw = w + 1
    val sr = DoubleArray(sw * (h + 1)); val sg = DoubleArray(sw * (h + 1)); val sb = DoubleArray(sw * (h + 1)); val sl = DoubleArray(sw * (h + 1))
    for (y in 0 until h) for (x in 0 until w) {
        val c = px[y * w + x]
        val rr = (c shr 16 and 0xFF).toDouble(); val gg = (c shr 8 and 0xFF).toDouble(); val bb = (c and 0xFF).toDouble()
        val l = 0.3 * rr + 0.59 * gg + 0.11 * bb
        val i = (y + 1) * sw + x + 1
        sr[i] = rr + sr[i - 1] + sr[i - sw] - sr[i - sw - 1]
        sg[i] = gg + sg[i - 1] + sg[i - sw] - sg[i - sw - 1]
        sb[i] = bb + sb[i - 1] + sb[i - sw] - sb[i - sw - 1]
        sl[i] = l * l + sl[i - 1] + sl[i - sw] - sl[i - sw - 1]
    }
    // the luminance sum is needed for the variance too
    val sL = DoubleArray(sw * (h + 1))
    for (y in 0 until h) for (x in 0 until w) {
        val i = (y + 1) * sw + x + 1
        val l = 0.3 * (sr[i] - sr[i - 1] - sr[i - sw] + sr[i - sw - 1]) + 0.59 * (sg[i] - sg[i - 1] - sg[i - sw] + sg[i - sw - 1]) + 0.11 * (sb[i] - sb[i - 1] - sb[i - sw] + sb[i - sw - 1])
        sL[i] = l + sL[i - 1] + sL[i - sw] - sL[i - sw - 1]
    }
    fun box(a: DoubleArray, x0: Int, y0: Int, x1: Int, y1: Int) = a[(y1 + 1) * sw + x1 + 1] - a[y0 * sw + x1 + 1] - a[(y1 + 1) * sw + x0] + a[y0 * sw + x0]
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    val o = IntArray(w * h)
    for (y in 0 until h) for (x in 0 until w) {
        var best = Double.MAX_VALUE; var cr = 0.0; var cg = 0.0; var cb = 0.0
        for (q in 0 until 4) {
            val x0 = (if (q and 1 == 0) x - r else x).coerceIn(0, w - 1); val x1 = (if (q and 1 == 0) x else x + r).coerceIn(0, w - 1)
            val y0 = (if (q < 2) y - r else y).coerceIn(0, h - 1); val y1 = (if (q < 2) y else y + r).coerceIn(0, h - 1)
            val n = ((x1 - x0 + 1) * (y1 - y0 + 1)).toDouble()
            val m = box(sL, x0, y0, x1, y1) / n
            val v = box(sl, x0, y0, x1, y1) / n - m * m
            if (v < best) { best = v; cr = box(sr, x0, y0, x1, y1) / n; cg = box(sg, x0, y0, x1, y1) / n; cb = box(sb, x0, y0, x1, y1) / n }
        }
        o[y * w + x] = (0xFF shl 24) or (cr.toInt().coerceIn(0, 255) shl 16) or (cg.toInt().coerceIn(0, 255) shl 8) or cb.toInt().coerceIn(0, 255)
    }
    out.setRGB(0, 0, w, h, o, 0, w)
    return out
}
