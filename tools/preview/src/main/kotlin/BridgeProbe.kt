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
    // round 2 (user 14.10., 09:5x): only the precise one, finer, at eye level, tight on the house, the river and the bridge
    val precise = BridgePainter(detail = true).paint()
    File("build/screens").mkdirs()
    ImageIO.write(precise, "png", File("build/screens/probe69e_r4.png"))
    // with its text below as in the app
    val text = "Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht."
    val w = BridgePainter.W; val h = BridgePainter.H; val box = 170
    val out = BufferedImage(w, h + box, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x101014); g.fillRect(0, 0, out.width, out.height)
    g.drawImage(precise, 0, 0, null)
    g.color = Color(0x96784A); g.drawRect(30, h + 18, w - 60, box - 36)
    g.color = Color(0xEBE1C8); g.font = Font(Font.SANS_SERIF, Font.PLAIN, 34)
    var line = ""; var ly = h + 68
    for (word in text.split(" ")) {
        if (g.fontMetrics.stringWidth("$line $word") > w - 120) { g.drawString(line.trim(), 54, ly); ly += 46; line = "" }
        line += " $word"
    }
    g.drawString(line.trim(), 54, ly)
    ImageIO.write(out, "png", File("build/screens/probe69e_r4_text.png"))
    println("wrote build/screens/probe69e_r4_text.png")
}

private class BridgePainter(val detail: Boolean) {
    companion object { const val W = 1080; const val H = 1200 }

    /** Drawn at twice the size and scaled down, so every edge is fine (round 2: "feiner"). */
    val SS = 2
    val img = BufferedImage(W * SS, H * SS, BufferedImage.TYPE_INT_ARGB)
    val g: Graphics2D = img.createGraphics().apply {
        scale(SS.toDouble(), SS.toDouble())
        setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
        setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY)
        setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE)
    }

    // the camera: the traveller's eyes on the south road, looking north over the bridge
    val hy = 520.0; val f = 1080.0; val eye = 2.5; val cx = W / 2.0
    /** Round 3: the traveller stands a little left on the road and looks along it; the whole bridge leads to the lights. */
    val camX = 0.5; val pan = -80.0
    fun sx(x: Double, z: Double) = cx + f * (x - camX) / z - pan
    fun sy(y: Double, z: Double) = hy + f * (eye - y) / z

    /** The river between its banks. */
    /** Round 4: the banks follow the camera, now at the foot of the bridge. */
    val ZN get() = wz(28.0); val ZF get() = ZN + 7.0

    // the moon, high up on the left, clear of the roof, its chimney and the fir (Sokrates 14.10.: it sat on the chimney)
    val moonX = 120.0; val moonY = 175.0

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
        foreground()
        mist()
        life()
        vignette()
        val small = BufferedImage(W, H, BufferedImage.TYPE_INT_ARGB)
        small.createGraphics().apply {
            setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC)
            setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY)
            drawImage(img.getScaledInstance(W, H, java.awt.Image.SCALE_AREA_AVERAGING), 0, 0, null)
        }
        return small
    }

    /** Round 2: the near bank, close enough to see every blade: reeds at the water, tufts of grass, the road to the bridge. */
    fun foreground() {
        val zb = wz(28.0)
        // reeds along the water's edge, the moon catching their left sides; a few with seed heads
        for (i in 0 until 420) {
            val x = -16 + rnd(i, 801) * 22; if (abs(x) < 2.4) continue
            val z = zb - 0.1 - rnd(i, 802) * 1.0
            val px = sx(x, z); if (px < -20 || px > W + 20) continue
            val py = sy(0.0, z); val h = f * (0.17 + rnd(i, 803) * 0.3) / z
            val lean = (rnd(i, 804) - 0.4) * h * 0.25
            val c = if (rnd(i, 805) > 0.7) Color(0x3A4A38) else Color(0x16201A)
            val p = Path2D.Double(); p.moveTo(px, py); p.quadTo(px + lean * 0.2, py - h * 0.6, px + lean, py - h)
            g.color = c; g.stroke = BasicStroke((1.0 + rnd(i, 806) * 1.6).toFloat(), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(p)
            if (i % 23 == 0) { g.color = Color(0x2A1E16); g.fill(Ellipse2D.Double(px + lean - 2.5, py - h - 2, 5.0, 16.0)) }
        }
        // tufts of grass on the near bank, thick and dark, lighter tips in the moon
        for (i in 0 until 2600) {
            val z = 1.6 + rnd(i, 811).let { it * it } * (zb - 2.0)
            val x = camX + (rnd(i, 812) - 0.5) * z * 1.3
            if (abs(x) < 1.9 && z > 1.6) continue
            val px = sx(x, z); val py = sy(0.0, z); val l = f * (0.053 + rnd(i, 813) * 0.08) / z
            line(alpha(if (rnd(i, 814) > 0.6) Color(0x4A5A40) else Color(0x1A2620), 0.85), maxOf(1.0, f * 0.012 / z), px, py, px + (rnd(i, 815) - 0.5) * l * 0.7, py - l)
        }
        // stones and two ruts on the road up to the bridge
        for (i in 0 until 500) {
            val z = 1.6 + rnd(i, 821) * (zb - 1.6); val x = (rnd(i, 822) - 0.5) * 3.4
            val r = f * (0.01 + rnd(i, 823) * 0.03) / z
            g.color = alpha(if (rnd(i, 824) > 0.5) Color(0x4A4440) else Color(0x16120F), 0.75)
            g.fill(Ellipse2D.Double(sx(x, z) - r, sy(0.0, z) - r * 0.45, r * 2, r * 0.9))
        }
        // rings on the water where something rose
        for ((x, z) in listOf(-7.0 to 7.5, -10.5 to 5.0, 2.8 to 9.5)) for (k in 1..3) {
            val r = f * 0.22 * k / z
            g.color = alpha(Color(0x8A9CB8), 0.35 / k); g.stroke = BasicStroke(1.2f)
            g.draw(Ellipse2D.Double(sx(x, z) - r, sy(0.0, z) - r * 0.18, r * 2, r * 0.36))
        }
    }

    /** Round 2: a little life (fireflies over the bank, smoke from the chimneys, a bat before the moon). */
    fun life() {
        // smoke from the chimney of the near house, drifting off to the right and thinning, its left side in the moon
        for (hs in buildings().filter { it.z < 25 && !it.temple }) {
            val top = hs.wall + hs.roof; val zr = hs.z + hs.d / 2 + 0.5
            val x0 = sx(hs.x - hs.w / 2 + hs.w * 0.72 + 0.35, zr); val y0 = sy(top + 0.8, zr)
            for (k in 0 until 60) {
                val t = k / 60.0
                val x = x0 + t * t * 220 + kotlin.math.sin(t * 9) * 12 * t; val y = y0 - t * 260 - 6
                val r = 10 + t * 60
                glow(x, y, r, Color(0x8A94AC), 0.16 * (1 - t))
                glow(x - r * 0.3, y - r * 0.2, r * 0.6, Color(0xB8C4DC), 0.08 * (1 - t))
            }
        }
        for (i in 0 until 26) {
            val x = rnd(i, 901) * W; val y = sy(0.0, 3.0) + (rnd(i, 902) - 0.3) * 260
            val r = 1.4 + rnd(i, 903) * 1.6
            glow(x, y, r * 7, Color(0xC8E070), 0.35)
            g.color = alpha(Color(0xF0F8B0), 0.9); g.fill(Ellipse2D.Double(x - r / 2, y - r / 2, r, r))
        }
        for ((bx, by, s) in listOf(Triple(moonX + 70, moonY - 60, 1.0), Triple(moonX - 160, moonY - 130, 0.7))) {
            val p = Path2D.Double(); val w = 16 * s
            p.moveTo(bx - w, by - w * 0.3); p.quadTo(bx - w * 0.5, by + w * 0.1, bx - w * 0.15, by - w * 0.05)
            p.lineTo(bx, by + w * 0.12); p.lineTo(bx + w * 0.15, by - w * 0.05)
            p.quadTo(bx + w * 0.5, by + w * 0.1, bx + w, by - w * 0.3); p.quadTo(bx + w * 0.4, by + w * 0.25, bx, by + w * 0.3)
            p.quadTo(bx - w * 0.4, by + w * 0.25, bx - w, by - w * 0.3); p.closePath()
            g.color = Color(0x06080E); g.fill(p)
        }
    }

    // ---- the scene built from the village map (69e): one tile is 2 m, the traveller stands on the south road behind the edge
    val map = de.bornim.core.World["village"]
    val camTx = 18.0; val camTy = 30.5
    fun wx(tx: Double) = (tx - camTx) * 2
    /** Round 2: the river by the bridge drawn twice as wide as its two tiles, so it reads at eye level (user: may differ from the map). */
    /** and the bank behind it narrower, so the half-timbered house stands close behind the water. */
    fun depth(t: Int) = when (t) { 26, 27 -> 5.0; 24 -> 2.4; 23 -> 1.6; 25 -> 1.2; else -> 2.0 }
    fun wz(ty: Double): Double {
        var z = 0.0; var t = ty
        while (t < camTy) { val k = kotlin.math.floor(t).toInt(); val next = minOf(camTy, (k + 1).toDouble()); z += (next - t) * depth(k); t = next }
        while (t > camTy) { val k = kotlin.math.ceil(t).toInt() - 1; val prev = maxOf(camTy, k.toDouble()); z -= (t - prev) * depth(k); t = prev }
        return z
    }
    fun ch(tx: Int, ty: Int): Char = when {
        ty > 31 && tx in 17..18 -> '='          // the south road goes on beyond the edge
        ty > 31 -> '.'
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
        // round 4 (structure in the earth): on the roads and the cobbles, clods, pebbles and a worn pale track, as on the map
        if (detail) for (ty in -30..33) for (tx in -12..48) {
            val c = ch(tx, ty); if (c !in "=.omwnql".toSet() || c == '.' && ty <= 31) continue
            val zN = wz(ty + 1.0); val zF = wz(ty.toDouble()); if (zF <= 0.5 || zF > 60) continue
            val zn = maxOf(zN, 0.5); val cobble = c != '=' && c != '.'
            for (i in 0 until (if (zF < 25) 70 else 20)) {
                val z = zn + (zF - zn) * rnd(i, 1001 + tx * 31 + ty * 7); val x = wx(tx + rnd(i, 1002 + tx * 17 + ty * 11))
                val r = f * (if (cobble) 0.09 + rnd(i, 1003) * 0.06 else 0.02 + rnd(i, 1003) * 0.05) / z
                val v = rnd(i, 1004)
                g.color = alpha(far(night(if (v > 0.55) 0x8A7A62 else 0x2E2418, if (cobble) 1.1 else 1.0), z), if (cobble) 0.55 else 0.6)
                g.fill(Ellipse2D.Double(sx(x, z) - r, sy(0.0, z) - r * 0.4, r * 2, r * 0.8))
            }
        }
        waterLight()
        lightPools()
        mapStrokes()
        // everything standing, far to near
        val items = ArrayList<Pair<Double, () -> Unit>>()
        for (h in buildings()) items += h.z to { house(h, h.temple) }
        for (ty in -30..33) for (tx in -12..48) {
            val c = ch(tx, ty); val x = wx(tx + 0.5); val z = wz(ty + 0.5)
            if (z < 1.0) continue
            when (c) {
                'T' -> items += z to { val hgt = 5.0 + 2 * tileHash(tx, ty, 2)
                    // round 2: the fir before the half-timbered house stands a little east, beside it, not before its window
                    val shift = if (tx == 14 && ty == 24) 2.6 else 0.0
                    val bx = sx(x + shift + (tileHash(tx, ty, 3) - 0.5), z); val by = sy(0.0, z)
                    softShadow(bx, by, f * 2.2 / z)
                    if (shift > 0) firVolume(bx, by, f * hgt * 1.15 / z, f * hgt * 0.68 / z, z)
                    else firShape(bx, by, f * hgt / z, f * hgt * 0.42 / z, far(night(dFir), z), far(night(0x4E7A5A), z), if (detail) 0.7 else 0.5) }
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

    /** Which windows are lit: the half-timbered house in front always (round 2), else every other one by chance. */
    fun litWindow(wcx: Double, z0: Double, temple: Boolean) = temple || z0 < 30 || rnd((wcx * 10).toInt() + 500, (z0 * 10).toInt()) < 0.5

    /** Round 2: warm cones of light from the lit windows and the lanterns on the ground before them, their mirror images
     *  as broken warm streaks on the water, and the moon in the river. */
    fun lightPools() {
        val sources = ArrayList<Triple<Double, Double, Double>>() // x, z, height
        for (hs in buildings()) { val (wins, _) = houseWin[hs] ?: continue
            for (w in wins) if (litWindow(w, hs.z, hs.temple)) sources += Triple(w, hs.z, if (hs.temple) 3.3 else 1.85) }
        for (ty in 0..31) for (tx in 0 until map.width) if (ch(tx, ty) == 'l') sources += Triple(wx(tx + 0.5), wz(ty + 0.5), 2.4)
        // water: the screen band of the river at each x, found from the tiles
        fun waterAt(x: Double, z: Double): Boolean {
            val tx = kotlin.math.floor(x / 2 + camTx).toInt()
            var ty = 31; while (ty > -5 && wz(ty.toDouble()) < z) ty--
            return ch(tx, ty).let { it == '~' || it == 'h' }
        }
        for ((x, z, h) in sources) {
            val px = sx(x, z); val py = sy(0.0, z)
            if (px < -200 || px > W + 200) continue
            // the cone on the ground before the window: a warm ellipse widening towards us
            val r = f * 3.2 / z
            if (!waterAt(x, z - 1.0)) {
                val t = g.transform; g.translate(px, py + r * 0.18); g.scale(1.0, 0.32)
                g.paint = RadialGradientPaint(Point2D.Double(0.0, 0.0), r.toFloat(), floatArrayOf(0f, 0.4f, 1f),
                    arrayOf(alpha(warm, 0.42), alpha(warmDeep, 0.18), alpha(warmDeep, 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
                g.fill(Ellipse2D.Double(-r, -r, r * 2, r * 2)); g.transform = t
            }
            // the mirror image: the light seen in the water straight below it, as far below the horizon line of the bank as it stands above
            val my = sy(-h, z)
            for (j in 0 until 46) {
                val y = py + (my - py) * (0.5 + rnd(j, 700 + (x * 13).toInt()) * 1.4)
                val zz = f * eye / (y - hy).coerceAtLeast(1.0) // the water lying at that line of the screen
                if (!waterAt(camX + (px + pan - cx) * zz / f, zz)) continue
                val l = (3.0 + rnd(j, 701) * 14) * (1 + (y - py) / 120)
                val a = 0.55 * (1 - abs(y - my) / (my - py + 40)).coerceIn(0.0, 1.0)
                line(alpha(if (j % 3 == 0) warmDeep else warm, a), 1.2 + rnd(j, 702) * 1.4, px - l / 2 + (rnd(j, 703) - 0.5) * 6, y, px + l / 2, y)
            }
        }
        // the moon in the river: a soft disc broken by ripples, and a column of glints under it
        val my = 2 * hy - moonY
        for (j in 0 until 220) {
            val y = my + (rnd(j, 721) - 0.5) * 2 * (40 + 160 * rnd(j, 722))
            val zz = f * eye / (y - hy).coerceAtLeast(1.0)
            val x = moonX + (rnd(j, 723) - 0.5) * (30 + abs(y - my) * 0.5)
            if (!waterAt(camX + (x + pan - cx) * zz / f, zz)) continue
            val l = 6.0 + rnd(j, 724) * 30 * (1 - abs(y - my) / 300).coerceAtLeast(0.2)
            val a = 0.75 * (1 - abs(y - my) / 260).coerceIn(0.0, 1.0) * (0.4 + 0.6 * rnd(j, 725))
            line(alpha(if (abs(y - my) < 30) Color(0xF4F0DC) else Color(0xC8D4EC), a), 1.4 + rnd(j, 726) * 1.6, x - l / 2, y, x + l / 2, y)
        }
        if (waterAt(camX + (moonX + pan - cx) * f * eye / (my - hy) / f, f * eye / (my - hy))) glow(moonX, my, 60.0, Color(0xC8D4EC), 0.25)
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
        val k = (n * (b.width * b.height) / 10000.0).toInt().coerceIn(0, 40000)
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
        val wallC = far(if (temple) stone else night(0x4E3A28), z0); val wallLit = far(if (temple) stoneLit else night(0x4E3A28, 1.35), z0)
        // the side we see: the one facing the road; the moon from the left lights left sides
        val sideX = if (hs.x > 0) x0 else x1
        val sideC = if (hs.x > 0) wallLit else wallC
        quad(sideC, sideX, 0.0, z0, sideX, 0.0, z1, sideX, hs.wall, z1, sideX, hs.wall, z0)
        // the gable on that side
        poly(sideC, sx(sideX, z0), sy(hs.wall, z0), sx(sideX, z1), sy(hs.wall, z1), sx(sideX, zr), sy(top, zr))
        // the front
        quad(wallC, x0, 0.0, z0, x1, 0.0, z0, x1, hs.wall, z0, x0, hs.wall, z0)
        if (temple) {
            texture(quadShape(x0, 0.0, z0, x1, 0.0, z0, x1, hs.wall, z0, x0, hs.wall, z0), z0, Color(0x2A2A30), stoneLit, 40, 0.12, 0.5)
            texture(quadShape(sideX, 0.0, z0, sideX, 0.0, z1, sideX, hs.wall, z1, sideX, hs.wall, z0), z0, Color(0x2A2A30), stoneLit, 900, 0.035)
        }
        // round 4 (user 14.10., 13:1x: houses as in the diagonal world): walls of dark upright boards on a footing of field stone
        if (!temple) {
            val fy = 0.7
            fun boards(xa: Double, za: Double, xb: Double, zb: Double, lit: Boolean) {
                val len = Math.hypot(xb - xa, zb - za); val n = (len / 0.28).toInt().coerceAtLeast(1)
                for (k in 0 until n) {
                    val t0 = k / n.toDouble(); val t1 = (k + 1) / n.toDouble()
                    val ax = xa + (xb - xa) * t0; val az = za + (zb - za) * t0; val bx = xa + (xb - xa) * t1; val bz = za + (zb - za) * t1
                    val v = rnd(k, 71 + (xa * 10).toInt())
                    val c = night(if (v > 0.66) 0x5E4632 else if (v > 0.33) 0x4E3A28 else 0x443222, if (lit) 1.35 else 1.0)
                    quad(far(c, za), ax, fy, az, bx, fy, bz, bx, hs.wall, bz, ax, hs.wall, az)
                    if (detail) {
                        // the joint between two boards, and the grain running up each
                        line(far(Color(0x0E0A08), za), maxOf(1.0, f * 0.025 / az), sx(ax, az), sy(fy, az), sx(ax, az), sy(hs.wall, az))
                        for (q in 0 until 3) {
                            val u = 0.2 + 0.6 * rnd(k * 3 + q, 73); val gx = ax + (bx - ax) * u; val gz = az + (bz - az) * u
                            val y0 = fy + (hs.wall - fy) * rnd(k * 3 + q, 74); val y1 = (y0 + 0.4 + rnd(k * 3 + q, 75) * 0.9).coerceAtMost(hs.wall)
                            line(alpha(far(Color(0x1A120C), gz), 0.5), maxOf(0.8, f * 0.01 / gz), sx(gx, gz), sy(y0, gz), sx(gx, gz), sy(y1, gz))
                        }
                    }
                }
            }
            boards(x0, z0, x1, z0, false)
            boards(sideX, z0, sideX, z1, hs.x > 0)
            // the field-stone footing, its stones in two uneven courses
            for ((xa, za, xb, zb) in listOf(listOf(x0, z0, x1, z0), listOf(sideX, z0, sideX, z1))) {
                quad(far(stone, za), xa, 0.0, za, xb, 0.0, zb, xb, fy, zb, xa, fy, za)
                if (!detail) continue
                for (row in 0 until 2) {
                    var t = rnd(row, 81) * 0.1; val ya = fy * row / 2; val yb = fy * (row + 1) / 2
                    val len = Math.hypot(xb - xa, zb - za)
                    while (t < 1) {
                        val t1 = (t + (0.35 + rnd((t * 100).toInt(), 82 + row) * 0.4) / len).coerceAtMost(1.0)
                        val ax = xa + (xb - xa) * t; val az = za + (zb - za) * t; val bx = xa + (xb - xa) * t1; val bz = za + (zb - za) * t1
                        val v = rnd((t * 100).toInt(), 84 + row)
                        quad(far(night(if (v > 0.5) 0x7A766A else 0x66625A, 0.9 + v * 0.35), za), ax + 0.03, ya + 0.03, az, bx - 0.03, ya + 0.03, bz, bx - 0.03, yb - 0.03, bz, ax + 0.03, yb - 0.03, az)
                        t = t1
                    }
                }
            }
            // the corner posts
            val tw = maxOf(1.5, f * 0.16 / z0)
            line(far(timber, z0), tw, sx(x0, z0), sy(fy, z0), sx(x0, z0), sy(hs.wall, z0))
            line(far(timber, z0), tw, sx(x1, z0), sy(fy, z0), sx(x1, z0), sy(hs.wall, z0))
            line(far(timber, z0), tw, sx(sideX, z1), sy(fy, z1), sx(sideX, z1), sy(hs.wall, z1))
        } else if (detail) {
            // ashlar courses on the temple
            for (k in 1..9) { val y = hs.wall * k / 10; line(far(Color(0x22242C), z0), 1.0, sx(x0, z0), sy(y, z0), sx(x1, z0), sy(y, z0)) }
        }
        // the roof: the slope towards us, its eave a little over the wall
        val ov = 0.5
        quad(far(if (temple) night(dSlate) else roof, z0), x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr)
        // moonlight lies on the left part of the slope
        quad(alpha(far(roofLit, z0), 0.55), x0 - ov, hs.wall - 0.3, z0 - ov, x0 + hs.w * 0.35, hs.wall - 0.3, z0 - ov, x0 + hs.w * 0.35, top, zr, x0 - ov, top, zr)
        texture(quadShape(x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr), z0, Color(0x101016), roofLit, 700, 0.05, 0.35)
        // rows of shingles, finer on the near houses, each row's joints set off half a shingle
        val rows = if (z0 < 30) 22 else 8
        if (detail) for (k in 1 until rows) {
            val t = k / rows.toDouble()
            val y = hs.wall - 0.3 + (top - hs.wall + 0.3) * t; val z = z0 - ov + (zr - z0 + ov) * t
            line(far(Color(0x16161C), z0), 1.0, sx(x0 - ov, z), sy(y, z), sx(x1 + ov, z), sy(y, z))
            if (z0 < 30) { val sw = 0.45; var x = x0 - ov + (if (k % 2 == 0) sw / 2 else 0.0)
                val t2 = (k - 1) / rows.toDouble(); val y2 = hs.wall - 0.3 + (top - hs.wall + 0.3) * t2; val z2 = z0 - ov + (zr - z0 + ov) * t2
                while (x < x1 + ov) { line(alpha(far(Color(0x16161C), z0), 0.7), 0.8, sx(x, z), sy(y, z), sx(x, z2), sy(y2, z2)); x += sw * (0.8 + 0.4 * rnd((x * 10).toInt(), k)) } }
        }
        // round 4: moss in patches on the shingles, thicker towards the eave, as on the diagonal world's roofs
        if (detail && !temple) {
            val clip = g.clip; g.clip(quadShape(x0 - ov, hs.wall - 0.3, z0 - ov, x1 + ov, hs.wall - 0.3, z0 - ov, x1 + ov, top, zr, x0 - ov, top, zr))
            for (i in 0 until (hs.w * 14).toInt()) {
                val t = rnd(i, 91 + (hs.x * 10).toInt()).let { it * it }
                val x = x0 - ov + (hs.w + 2 * ov) * rnd(i, 92 + (hs.x * 10).toInt())
                val y = hs.wall - 0.3 + (top - hs.wall + 0.3) * t; val z = z0 - ov + (zr - z0 + ov) * t
                val r = f * (0.12 + rnd(i, 93) * 0.3) / z
                val lit = x < x0 + hs.w * 0.35
                g.color = alpha(far(night(if (rnd(i, 94) > 0.5) 0x5A6A34 else 0x46562A, if (lit) 1.4 else 1.0), z), 0.55)
                g.fill(Ellipse2D.Double(sx(x, z) - r, sy(y, z) - r * 0.4, r * 2, r * 0.8))
            }
            g.clip = clip
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
            val lit = litWindow(wcx, z0, temple)
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

    /** The bridge: flat planks over beams with a railing (round 3); posts stand in the water. */
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
        g.paint = GradientPaint(sx(-hw, ZN).toFloat(), 0f, alpha(plankLit, 0.75), sx(hw, ZN).toFloat(), 0f, alpha(plankLit, 0.1))
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
                // round 4: the grain along each plank and here and there a knot
                for (q in 0 until 5) {
                    val zg = z + (z1 - z0) / n * (0.2 + 0.6 * rnd(k * 5 + q, 63)); val xa = -hw + 2 * hw * rnd(k * 5 + q, 64); val xb = (xa + 0.6 + rnd(k * 5 + q, 65) * 1.6).coerceAtMost(hw)
                    line(alpha(Color(0x1A120C), 0.45), maxOf(0.8, f * 0.008 / zg), sx(xa, zg), sy(y, zg), sx(xb, zg), sy(y, zg))
                }
                if (rnd(k, 66) > 0.6) { val kx = -hw + 2 * hw * rnd(k, 67); val kr = f * 0.035 / zm
                    g.color = alpha(Color(0x140E0A), 0.6); g.fill(Ellipse2D.Double(sx(kx, zm) - kr, sy(y, zm) - kr * 0.35, kr * 2, kr * 0.7)) }
                // nail heads where the planks lie on the beams
                for (x in listOf(-hw + 0.2, hw - 0.2)) g.fill(Ellipse2D.Double(sx(x, zm) - 1.2, sy(y, zm) - 1.2, 2.4, 2.4))
            }
        }
        // the side beams along the deck
        line(Color(0x18120F), maxOf(2.0, f * 0.12 / z0), sx(-hw, z0), sy(y, z0), sx(-hw, z1), sy(y, z1))
        line(Color(0x18120F), maxOf(2.0, f * 0.12 / z0), sx(hw, z0), sy(y, z0), sx(hw, z1), sy(y, z1))
        bridgeLantern(hw, y, z0, z1)
    }

    /** A soft shadow on the ground, falling away from the moon (to the right). */
    fun softShadow(x: Double, y: Double, r: Double) {
        val t = g.transform; g.translate(x + r * 0.25, y); g.scale(1.0, 0.22)
        g.paint = RadialGradientPaint(Point2D.Double(0.0, 0.0), r.toFloat(), floatArrayOf(0f, 0.5f, 1f),
            arrayOf(alpha(Color(0x04060A), 0.55), alpha(Color(0x04060A), 0.25), alpha(Color(0x04060A), 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
        g.fill(Ellipse2D.Double(-r, -r, r * 2, r * 2)); g.transform = t
    }

    /**
     * Round 3: the fir before the house with volume: the trunk shows between the tiers, every tier lit on the moon side (left)
     * and dark on the other, the drooping branches dark underneath where they lie in each other's shadow, needles in fine strokes.
     */
    fun firVolume(x: Double, base: Double, h: Double, w: Double, z: Double) {
        val dark = far(Color(0x070E0C), z); val mid = far(night(dFir, 1.1), z); val lit = far(night(0x9CC4A0, 1.45), z)
        // the trunk, its left edge in the moon
        val tw = maxOf(2.0, w * 0.06)
        line(Color(0x1A1210), tw, x, base, x, base - h * 0.9)
        line(alpha(Color(0x5A4A40), 0.6), maxOf(1.0, tw * 0.3), x - tw * 0.3, base, x - tw * 0.3, base - h * 0.75)
        val tiers = 9; val step = h * 0.92 / tiers
        for (k in 0 until tiers) {
            val t0 = k / tiers.toDouble()
            val yb = base - h * 0.05 - step * k; val yt = yb - step * 1.4
            val half = (w * 0.5 * (1 - t0) * (1 - t0 * 0.15) + w * 0.03) * (0.88 + 0.24 * rnd(k, 939))
            val sag = step * 0.3
            // the upper side of the tier: from the trunk the branches rise a little, then bow down to the hanging tips
            fun upper(u: Double) = yt + (yb - yt) * Math.pow(abs(u), 0.75)
            // the lower side: a thick layer of twigs below, ragged where the fronds hang down
            val thick = step * 0.8
            val teeth = 9
            val path = Path2D.Double(); path.moveTo(x, yt)
            for (j in -teeth..teeth) { val u = j / teeth.toDouble(); path.lineTo(x + half * u, upper(u) - step * 0.08 * (1 - abs(u))) }
            for (j in teeth downTo -teeth) {
                val u = j / teeth.toDouble()
                val frond = if (j % 2 == 0) step * (0.18 + 0.25 * rnd(k * 31 + j, 933)) else 0.0
                val yy = upper(u) + thick * (1 - 0.55 * abs(u)) * (0.35 + 0.65 * (1 - abs(u))) + frond + (rnd(k * 31 + j, 931) - 0.5) * step * 0.12
                path.lineTo(x + half * u * (0.97 + 0.06 * rnd(k * 31 + j, 932)), yy)
            }
            path.closePath()
            // the moon side lit, the far side dark
            g.paint = java.awt.LinearGradientPaint(Point2D.Double(x - half, 0.0), Point2D.Double(x + half + 0.01, 0.0), floatArrayOf(0f, 0.4f, 1f),
                arrayOf(lit, mid, dark))
            g.fill(path)
            // underneath, where the tier above shades it, and deep inside by the trunk, it is darker
            val clip = g.clip; g.clip(path)
            g.paint = GradientPaint(0f, (yb - sag).toFloat(), alpha(dark, 0.0), 0f, yb.toFloat(), alpha(dark, 0.8)); g.fill(path)
            g.paint = RadialGradientPaint(Point2D.Double(x + half * 0.1, yb - sag * 0.6), (half * 0.55).toFloat(), floatArrayOf(0f, 1f),
                arrayOf(alpha(Color(0x040806), 0.6), alpha(Color(0x040806), 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE); g.fill(path)
            // needles: short strokes, light on the moon side
            for (i in 0 until 160) {
                val u = rnd(k * 100 + i, 941) * 2 - 1; val v = rnd(k * 100 + i, 942)
                val px = x + half * u * (1 - v * 0.6); val py = yt + (yb - yt) * (0.35 + v * 0.65) - sag * (1 - u * u) * v
                val c = if (u < -0.15 && rnd(k * 100 + i, 943) > 0.35) alpha(lit, 0.45) else alpha(dark, 0.6)
                line(c, maxOf(0.6, w * 0.006), px, py, px + u * step * 0.12, py + step * 0.1)
            }
            g.clip = clip
            // the moon catches the upper left rim of every tier
            line(alpha(lit, 0.7), maxOf(1.0, w * 0.01), x - half * 0.92, yb - sag * 0.15, x - half * 0.15, yt + step * 0.3)
        }
    }

    /**
     * Round 3: a railing along both edges (posts, a top rail and a middle rail), and a lantern on the near right post,
     * its warm light on the planks, the posts and the water beside the bridge.
     */
    fun bridgeLantern(hw: Double, y: Double, z0: Double, z1: Double) {
        val wood = Color(0x221A14); val woodLit = night(0x7A5C40, 1.3)
        val lx = hw - 0.06; val lz = z0 + 0.1; val lh = y + 1.75
        // the warm pool on the deck and on the water beside the bridge
        // (the lantern sits on the top of the tall near post, its foot on the post: Sokrates 14.10., it floated above it)
        val lpx = sx(lx, lz); val lpy = sy(lh, lz) - f * 0.16 / lz * 0.3
        run {
            val r = f * 2.6 / lz; val t = g.transform; g.translate(sx(lx - 0.7, lz + 1.4), sy(y, lz + 1.4)); g.scale(1.0, 0.3)
            g.paint = RadialGradientPaint(Point2D.Double(0.0, 0.0), r.toFloat(), floatArrayOf(0f, 0.45f, 1f),
                arrayOf(alpha(warm, 0.5), alpha(warmDeep, 0.2), alpha(warmDeep, 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
            g.fill(Ellipse2D.Double(-r, -r, r * 2, r * 2)); g.transform = t
        }
        for (i in 0 until 160) {
            val zz = lz + 0.6 + rnd(i, 951).let { it * it } * 6.0; val xx = hw + 0.2 + rnd(i, 952) * 3.5
            val d = sqrt((xx - lx) * (xx - lx) + (zz - lz) * (zz - lz))
            val a = 0.7 * exp(-d / 2.2) * (0.4 + 0.6 * rnd(i, 953))
            val l = f * (0.08 + rnd(i, 954) * 0.3) / zz
            line(alpha(if (i % 3 == 0) warmDeep else warm, a), maxOf(1.0, f * 0.012 / zz), sx(xx, zz) - l / 2, sy(0.0, zz), sx(xx, zz) + l / 2, sy(0.0, zz))
        }
        // the railings, far posts first
        val posts = 7
        for (side in listOf(-1.0, 1.0)) {
            val x = side * (hw - 0.06)
            val tops = ArrayList<Pair<Double, Double>>()
            for (k in posts downTo 0) {
                val z = z0 + 0.1 + (z1 - z0 - 0.2) * k / posts
                val pw = 0.07; val ph = if (side > 0 && k == 0) 1.75 else 1.0
                val near = 1 - k / posts.toDouble()
                val c = if (side < 0) mix(wood, woodLit, 0.35) else wood
                // the two near posts stand on the bank, down to the ground, where the railings begin
                val foot = if (k == 0) 0.0 else y
                quad(c, x - pw, foot, z, x + pw, foot, z, x + pw, y + ph, z, x - pw, y + ph, z)
                // the moon on the left face, the lantern on the near posts
                line(alpha(woodLit, 0.6), maxOf(1.0, f * 0.012 / z), sx(x - pw, z), sy(y, z), sx(x - pw, z), sy(y + ph, z))
                val warmth = exp(-sqrt((x - lx) * (x - lx) + (z - lz) * (z - lz)) / 2.0)
                if (warmth > 0.05) quad(alpha(warm, 0.45 * warmth), x - pw, y, z, x + pw, y, z, x + pw, y + ph, z, x - pw, y + ph, z)
                tops += z to near
            }
            for (rh in listOf(1.0, 0.5)) {
                val za = z0 + 0.1; val zb = z1 - 0.1
                line(Color(0x1E1712), maxOf(1.5, f * 0.06 / za), sx(x, za), sy(y + rh, za), sx(x, zb), sy(y + rh, zb))
                // the top rail catches light: moon on the left rail, lantern warm near the right
                if (rh == 1.0) {
                    val lc = if (side < 0) alpha(woodLit, 0.55) else alpha(warm, 0.5)
                    val zc = if (side < 0) zb else za + 2.5
                    line(lc, maxOf(1.0, f * 0.015 / za), sx(x, za), sy(y + rh + 0.02, za), sx(x, zc), sy(y + rh + 0.02, zc))
                }
            }
        }
        // the lantern on the tall near post: iron cap, glass with the flame, a ring
        val s = f * 0.16 / lz
        poly(Color(0x14110E), lpx - s * 0.7, lpy - s * 1.0, lpx + s * 0.7, lpy - s * 1.0, lpx + s * 0.35, lpy - s * 1.45, lpx - s * 0.35, lpy - s * 1.45)
        glow(lpx, lpy - s * 0.3, f * 4.0 / lz, warmDeep, 0.32)
        glow(lpx, lpy - s * 0.3, f * 1.0 / lz, warm, 0.7)
        g.color = Color(0xFFD890); g.fill(java.awt.geom.Rectangle2D.Double(lpx - s * 0.5, lpy - s * 1.0, s * 1.0, s * 1.2))
        g.color = Color(0xFFF4D0); g.fill(Ellipse2D.Double(lpx - s * 0.16, lpy - s * 0.65, s * 0.32, s * 0.55))
        g.color = Color(0x14110E)
        for (u in listOf(-0.5, 0.0, 0.5)) g.fill(java.awt.geom.Rectangle2D.Double(lpx + s * u - s * 0.05, lpy - s * 1.0, s * 0.1, s * 1.2))
        g.fill(java.awt.geom.Rectangle2D.Double(lpx - s * 0.6, lpy + s * 0.15, s * 1.2, s * 0.15))
        g.stroke = BasicStroke(maxOf(1.0, s * 0.08).toFloat()); g.draw(Ellipse2D.Double(lpx - s * 0.18, lpy - s * 1.8, s * 0.36, s * 0.4))
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
