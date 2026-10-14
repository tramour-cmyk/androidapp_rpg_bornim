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
    val hy = 700.0; val f = 1100.0; val eye = 1.7; val cx = W / 2.0
    /** The traveller stands at the left edge of the road and looks a little to the right, at the bridge. */
    val camX = 0.0; val pan = 0.0
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
    val plank get() = night(0x6A5038); val plankLit get() = night(0x6A5038, 1.5)
    val plaster get() = night(0xB0A690); val plasterLit get() = night(0xB0A690, 1.35)
    val timber get() = night(0x3A2A1E); val stone get() = night(0x7A766A); val stoneLit get() = night(0x7A766A, 1.35)
    val roof get() = night(0x4C463E); val roofLit get() = night(0x4C463E, 1.5)
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
        mapScene()
        mist()
        vignette()
        return img
    }

    // ---- the scene built from the village map (69e): one tile is 2 m, the traveller stands on the south road behind the edge
    val map = de.bornim.core.World["village"]
    val camTx = 18.0; val camTy = 34.0
    fun wx(tx: Double) = (tx - camTx) * 2
    fun wz(ty: Double) = (camTy - ty) * 2
    fun ch(tx: Int, ty: Int): Char = when {
        ty > 31 && tx in 15..20 -> '='          // the south road goes on beyond the edge
        !map.inside(tx, ty) -> if (ty < 0 && (tx * 7 + ty * 13) % 3 == 0 || ty >= 0 && (tx * 7 + ty * 13) % 5 == 0) 'T' else '.'
        else -> map.tile(tx, ty).ch
    }
    /** Day colours of the diagonal world, darkened and cooled for the night as its light does at 23:00. */
    fun night(day: Int, k: Double = 1.0): Color {
        val r = (day shr 16 and 0xFF) * 0.34 * k; val g2 = (day shr 8 and 0xFF) * 0.38 * k; val b = (day and 0xFF) * 0.52 * k
        return Color(r.toInt().coerceIn(0, 255), g2.toInt().coerceIn(0, 255), b.toInt().coerceIn(0, 255))
    }
    val dGrass = 0x56603A; val dEarth = 0x7A6448; val dWater = 0x16262E; val dSoil = 0x4A3A2A; val dCobble = 0x6E665A
    val dPlaster = 0xB0A690; val dTimber = 0x3A2A1E; val dRoof = 0x4C463E; val dSlate = 0x46566E; val dStone = 0x7A766A
    val dPlank = 0x6A5038; val dFir = 0x24402E; val dWheat = 0xB89850; val dHay = 0xA88E50

    fun tileHash(tx: Int, ty: Int, s: Int) = rnd(tx * 131 + ty * 7919, s)

    fun mapScene() {
        // the ground, far rows first, on a backdrop that reaches the horizon
        poly(far(night(dGrass), 120.0), 0.0, hy - 2, W.toDouble(), hy - 2, W.toDouble(), H.toDouble(), 0.0, H.toDouble())
        for (ty in -30..33) for (tx in -12..48) {
            val zN = wz(ty + 1.0); val zF = wz(ty.toDouble())
            if (zF <= 0.5) continue
            val zn = maxOf(zN, 0.5)
            val c = ch(tx, ty)
            val base = when (c) {
                '=' -> dEarth; '~', 'h' -> dWater; 'c', 'v' -> dSoil; 'o', 'w', 'm', 'n', 'q', 'l' -> dCobble
                else -> dGrass
            }
            val j = 0.92 + 0.16 * tileHash(tx, ty, 1)
            val col = if (c == '~' || c == 'h') night(base) else night(base, j)
            quad(far(col, zn), wx(tx - 0.02), 0.0, zn, wx(tx + 1.02), 0.0, zn, wx(tx + 1.02), 0.0, zF + 0.04, wx(tx - 0.02), 0.0, zF + 0.04)
        }
        // soft edges: the banks get a rim of wet earth, the road a fringe of grass
        for (ty in 0..33) for (tx in -12..48) {
            val zN = wz(ty + 1.0); val zF = wz(ty.toDouble()); if (zF <= 0.5) continue
            val c = ch(tx, ty); val water = c == '~' || c == 'h'
            if (!water) continue
            val zn = maxOf(zN, 0.5)
            fun land(x: Int, y: Int) = ch(x, y).let { it != '~' && it != 'h' }
            val rim = far(night(0x3A3024), zn)
            if (land(tx, ty - 1)) line(rim, maxOf(2.0, f * 0.2 / zF), sx(wx(tx.toDouble()), zF), sy(0.0, zF), sx(wx(tx + 1.0), zF), sy(0.0, zF))
            if (land(tx, ty + 1)) line(rim, maxOf(2.0, f * 0.25 / zn), sx(wx(tx.toDouble()), zn), sy(0.0, zn), sx(wx(tx + 1.0), zn), sy(0.0, zn))
            if (land(tx - 1, ty)) line(rim, 3.0, sx(wx(tx.toDouble()), zn), sy(0.0, zn), sx(wx(tx.toDouble()), zF), sy(0.0, zF))
            if (land(tx + 1, ty)) line(rim, 3.0, sx(wx(tx + 1.0), zn), sy(0.0, zn), sx(wx(tx + 1.0), zF), sy(0.0, zF))
        }
        waterLight()
        mapStrokes()
        // everything standing, far to near
        val items = ArrayList<Pair<Double, () -> Unit>>()
        for (h in buildings()) items += h.z to { house(h, h.temple) }
        for (ty in -30..33) for (tx in -12..48) {
            val c = ch(tx, ty); val x = wx(tx + 0.5); val z = wz(ty + 0.5)
            if (z < 1.0) continue
            when (c) {
                'T' -> items += z to { val hgt = 5.0 + 2 * tileHash(tx, ty, 2); val bx = sx(x + (tileHash(tx, ty, 3) - 0.5), z); val by = sy(0.0, z)
                    g.color = alpha(Color(0x04060A), 0.45); g.fill(Ellipse2D.Double(bx - f * 1.8 / z, by - f * 0.4 / z, f * 3.6 / z, f * 0.8 / z))
                    firShape(bx, by, f * hgt / z, f * hgt * 0.42 / z, far(night(dFir), z), far(night(0x4E7A5A), z), if (detail) 0.7 else 0.5) }
                'c' -> items += z to { wheatTile(tx, ty) }
                'y' -> items += z to { hay(x, z) }
                'x' -> items += z to { fence(tx, ty) }
                'S' -> items += z to { signpost(x, z) }
                'l' -> items += z to { lamp(x, z) }
                'f' -> items += z to { flowers(tx, ty) }
            }
        }
        items += wz(28.0) - 0.01 to { bridge() }
        for ((_, draw) in items.sortedByDescending { it.first }) draw()
    }

    /** Blades of grass on the grass tiles, pebbles and ruts on the road. */
    fun mapStrokes() {
        if (!detail) return
        for (i in 0 until 9000) {
            val ty = -2 + (rnd(i, 601) * 36).toInt(); val tx = -12 + (rnd(i, 602) * 60).toInt()
            val z = wz(ty + rnd(i, 603)); if (z < 3.5) continue
            val x = wx(tx + rnd(i, 604)); val px = sx(x, z); if (px < -20 || px > W + 20) continue
            val py = sy(0.0, z)
            when (ch(tx, ty)) {
                '.', ',', 'f' -> { val l = f * 0.22 / z
                    line(alpha(far(night(if (rnd(i, 605) > 0.5) 0x8A9660 else 0x3A4428), z), 0.7), maxOf(0.8, f * 0.02 / z), px, py, px + (rnd(i, 606) - 0.5) * l * 0.6, py - l) }
                '=' -> { val r = f * (0.02 + 0.03 * rnd(i, 607)) / z
                    g.color = alpha(far(night(if (rnd(i, 608) > 0.5) 0xA89478 else 0x4A3A28), z), 0.7); g.fill(Ellipse2D.Double(px - r, py - r * 0.4, r * 2, r * 0.8)) }
            }
        }
        // wheel ruts along the south road
        for (rx in listOf(-0.8, 0.8)) quad(alpha(night(0x4A3A28), 0.45), rx - 0.15, 0.0, 3.5, rx + 0.15, 0.0, 3.5, rx + 0.15, 0.0, wz(28.0), rx - 0.15, 0.0, wz(28.0))
    }

    /** The moon and the lit windows mirrored on the water tiles. */
    fun waterLight() {
        val n = if (detail) 500 else 160
        for (i in 0 until n) {
            val tx = -12 + (rnd(i, 301) * 60).toInt(); val ty = 24 + (rnd(i, 302) * 5).toInt()
            if (ch(tx, ty) != '~') continue
            val z = wz(ty + rnd(i, 303)); val x = wx(tx + rnd(i, 304))
            val px = sx(x, z); val py = sy(0.0, z)
            val nearMoon = abs(px - moonX) < 60 + 900 / z
            val l = (if (nearMoon) 18.0 else 8.0) * (8.0 / z)
            line(alpha(if (nearMoon) Color(0xD8E0F0) else night(0x9AB0C0, 1.6), if (nearMoon) 0.55 else 0.35), maxOf(1.0, 10 / z), px - l, py, px + l, py)
        }
    }

    data class Building(val x0: Double, val x1: Double, val z: Double, val d: Double, val windows: List<Double>, val door: Double?, val temple: Boolean, val lit: Boolean)

    /** The houses of the map: a row of wall tiles (# W D) is a front, the roof tiles (^ M) behind it are its body. */
    fun buildings(): List<House> {
        val out = ArrayList<House>()
        for (ty in 0..31) {
            var tx = 0
            while (tx < map.width) {
                if (ch(tx, ty) !in "#WD") { tx++; continue }
                val a = tx; while (tx < map.width && ch(tx, ty) in "#WD") tx++
                val b = tx
                var top = ty; while (top > 0 && (a until b).any { ch(it, top - 1) in "^M" }) top--
                val temple = (a until b).any { ch(it, ty - 1) == 'M' }
                val wins = (a until b).filter { ch(it, ty) == 'W' }
                val lit = wins.filter { tileHash(it, ty, 9) < 0.45 || temple }.map { (it - a) }
                val w = (b - a) * 2.0; val d = (ty + 1 - top) * 2.0
                out += House(wx((a + b) / 2.0), wz(ty + 1.0), w, d, if (temple) 6.0 else 3.8, if (temple) 4.6 else 3.4, lit, temple)
                    .also { h -> houseWin[h] = wins.map { wx(it + 0.5) } to (a until b).firstOrNull { ch(it, ty) == 'D' }?.let { wx(it + 0.5) } }
            }
        }
        return out
    }
    val houseWin = HashMap<House, Pair<List<Double>, Double?>>()

    fun wheatTile(tx: Int, ty: Int) {
        val n = if (detail) 70 else 18
        for (i in 0 until n) {
            val z = wz(ty + rnd(i, 401 + tx)); val x = wx(tx + rnd(i, 402 + ty))
            if (z < 1.0) continue
            val px = sx(x, z); val py = sy(0.0, z); val l = f * (0.9 + 0.25 * rnd(i, 403)) / z
            val c = if (rnd(i, 404) > 0.45) night(dWheat, 1.25) else night(dWheat, 0.8)
            line(alpha(far(c, z), 0.85), maxOf(1.0, f * (if (detail) 0.03 else 0.07) / z), px, py, px - l * 0.12, py - l)
            if (detail && i % 2 == 0) { g.color = alpha(far(night(dWheat, 1.5), z), 0.8); g.fill(Ellipse2D.Double(px - l * 0.14 - f * 0.02 / z, py - l - f * 0.06 / z, f * 0.04 / z, f * 0.12 / z)) }
        }
    }
    fun hay(x: Double, z: Double) {
        val px = sx(x, z); val py = sy(0.0, z); val r = f * 1.0 / z
        g.color = far(night(dHay), z); g.fill(Ellipse2D.Double(px - r, py - r * 1.3, r * 2, r * 1.5))
        g.color = alpha(far(night(dHay, 1.5), z), 0.6); g.fill(Ellipse2D.Double(px - r * 0.9, py - r * 1.25, r * 0.9, r * 1.0))
    }
    fun fence(tx: Int, ty: Int) {
        val z = wz(ty + 0.5); val x0 = wx(tx.toDouble()); val x1 = wx(tx + 1.0)
        val c = far(night(dTimber, 1.4), z)
        line(c, maxOf(1.0, f * 0.06 / z), sx(x0, z), sy(0.8, z), sx(x1, z), sy(0.8, z))
        line(c, maxOf(1.0, f * 0.06 / z), sx(x0, z), sy(0.45, z), sx(x1, z), sy(0.45, z))
        line(c, maxOf(1.0, f * 0.1 / z), sx(x0, z), sy(0.0, z), sx(x0, z), sy(1.0, z))
    }
    fun lamp(x: Double, z: Double) {
        line(far(Color(0x14120F), z), maxOf(1.0, f * 0.1 / z), sx(x, z), sy(0.0, z), sx(x, z), sy(2.4, z))
        glow(sx(x, z), sy(2.4, z), f * 3.0 / z, warmDeep, 0.35); glow(sx(x, z), sy(2.4, z), f * 0.5 / z, warm, 0.9)
    }
    fun flowers(tx: Int, ty: Int) {
        if (!detail) return
        for (i in 0 until 14) {
            val z = wz(ty + rnd(i, 501 + tx)); val x = wx(tx + rnd(i, 502 + ty)); if (z < 1.0) continue
            val r = f * 0.05 / z
            g.color = alpha(far(night(if (i % 3 == 0) 0xD8D0E8 else 0xC8A0C0, 1.3), z), 0.8); g.fill(Ellipse2D.Double(sx(x, z) - r, sy(0.25, z) - r, r * 2, r * 2))
        }
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
        quad(far(if (temple) night(dSlate) else roof, z0), x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr)
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
        // windows and the door where the map has them; some windows lit
        val (wins, door) = houseWin[hs] ?: (emptyList<Double>() to null)
        val wy0 = if (temple) 2.0 else 1.3; val wy1 = if (temple) 4.6 else 2.4
        for ((k, wcx) in wins.withIndex()) {
            val wx = wcx - 0.45; val wx1 = wx + 0.9
            val lit = temple || rnd((wcx * 10).toInt() + 500, (z0 * 10).toInt()) < 0.5
            if (lit) {
                val mx = sx(wcx, z0); val my = sy((wy0 + wy1) / 2, z0)
                glow(mx, my, f * 3.2 / z0, warmDeep, 0.35)
                glow(mx, my, f * 1.2 / z0, warm, 0.5)
            }
            quad(if (lit) warm else far(Color(0x0C0E16), z0), wx, wy0, z0, wx1, wy0, z0, wx1, wy1, z0, wx, wy1, z0)
            if (detail) {
                val tw = maxOf(1.0, f * 0.08 / z0)
                val wc = far(timber, z0)
                line(wc, tw, sx(wcx, z0), sy(wy0, z0), sx(wcx, z0), sy(wy1, z0))
                line(wc, tw, sx(wx, z0), sy((wy0 + wy1) / 2, z0), sx(wx1, z0), sy((wy0 + wy1) / 2, z0))
            }
        }
        if (door != null) {
            val dw = if (temple) 1.0 else 0.55; val dh = if (temple) 3.2 else 2.1
            quad(far(Color(if (temple) 0x0A0A10 else 0x241A16), z0), door - dw, 0.0, z0, door + dw, 0.0, z0, door + dw, dh, z0, door - dw, dh, z0)
            if (temple) for (tx in listOf(door - dw - 0.7, door + dw + 0.7)) {
                glow(sx(tx, z0), sy(2.6, z0), f * 2.4 / z0, warmDeep, 0.4)
                glow(sx(tx, z0), sy(2.6, z0), f * 0.6 / z0, warm, 0.9)
            }
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
        val z0 = wz(28.0) - 0.3; val z1 = wz(26.0) + 0.3; val y = 0.18; val hw = 2.0
        // posts into the water, far ones first
        if (false) for (z in listOf(wz(26.3), wz(27.0), wz(27.7))) for (x in listOf(-hw + 0.15, hw - 0.15)) {
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
    /** The sign at the bridge, as in the diagonal world: a square board of planks on one post set in its middle. */
    fun signpost(x: Double, z: Double) {
        val bx0 = x - 0.55; val bx1 = x + 0.55; val by0 = 1.0; val by1 = 1.7
        // the post, from the ground up into the board
        quad(night(dTimber, 1.1), x - 0.07, 0.0, z, x + 0.07, 0.0, z, x + 0.07, by1 - 0.05, z, x - 0.07, by1 - 0.05, z)
        line(alpha(night(dPlank, 1.8), 0.7), maxOf(1.0, f * 0.02 / z), sx(x - 0.07, z), sy(0.0, z), sx(x - 0.07, z), sy(by0, z))
        // the board: three planks, the moon on its upper and left edges
        quad(night(dPlank), bx0, by0, z, bx1, by0, z, bx1, by1, z, bx0, by1, z)
        if (detail) for (k in 1..2) { val y = by0 + (by1 - by0) * k / 3
            line(night(0x1E140C), maxOf(1.0, f * 0.015 / z), sx(bx0, z), sy(y, z), sx(bx1, z), sy(y, z)) }
        line(alpha(night(dPlank, 1.9), 0.8), maxOf(1.0, f * 0.025 / z), sx(bx0, z), sy(by1, z), sx(bx1, z), sy(by1, z))
        line(alpha(night(dPlank, 1.6), 0.7), maxOf(1.0, f * 0.02 / z), sx(bx0, z), sy(by0, z), sx(bx0, z), sy(by1, z))
        // carved letters, too far to read
        if (detail) for (k in 0 until 2) for (m in 0 until 4) {
            val y = by0 + (by1 - by0) * (0.68 - 0.36 * k); val xa = bx0 + 0.15 + m * 0.21
            line(night(0x140E0A), maxOf(1.0, f * 0.012 / z), sx(xa, z), sy(y, z), sx(xa + 0.14, z), sy(y, z))
        }
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
