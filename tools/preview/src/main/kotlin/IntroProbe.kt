package preview

import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.GradientPaint
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
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin
import de.bornim.core.IntroLife

/**
 * 69 (draft): the other intro pictures in the style of the accepted model picture `[69.intro.2]` (69e, [BridgePainter]):
 * `[69.intro.1]` the south road under the moon, `[69.intro.3]` the empty square with torches at the temple,
 * `[69.intro.4]` the warm window of the inn, the door opening, Rowena as a silhouette. Picture 5 is black.
 * Same night colours, same light from visible sources, eye level, tight crop; the hero never appears (70).
 */
fun renderIntroProbe() {
    File("build/screens").mkdirs()
    val texts = mapOf(
        1 to "Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.",
        3 to "Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.",
        4 to "Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.",
    )
    // INTRO69=leben: the layers of picture 3 for the app (70.3 B): the picture under the life and the torch bearers' layer
    if (System.getenv("INTRO69") == "leben") {
        val dir = File("../../app/src/main/assets/intro")
        val base = SquarePainter().apply { part = SquarePainter.Part.BASE }.paint()
        val rgb = BufferedImage(base.width, base.height, BufferedImage.TYPE_INT_RGB).also { it.createGraphics().drawImage(base, 0, 0, null) }
        writeJpeg(rgb, File(dir, "intro_3.jpg"))
        ImageIO.write(SquarePainter().apply { part = SquarePainter.Part.GROUP }.paint(), "png", File(dir, "intro_3_zug.png"))
        println("wrote ${dir.path}/intro_3.jpg, intro_3_zug.png")
        return
    }
    val only = System.getenv("INTRO69")?.toIntOrNull()
    for ((n, painter) in listOf(1 to { RoadPainter() }, 3 to { SquarePainter() }, 4 to { InnPainter() })) {
        if (only != null && only != n) continue
        val img = painter().paint()
        ImageIO.write(img, "png", File("build/screens/intro69_$n.png"))
        ImageIO.write(withText(img, texts.getValue(n)), "png", File("build/screens/intro69_${n}_text.png"))
        println("wrote build/screens/intro69_${n}_text.png")
    }
}

/** A JPEG at a quality that keeps the night's soft gradients free of blocks. */
private fun writeJpeg(img: BufferedImage, file: File) {
    val writer = ImageIO.getImageWritersByFormatName("jpg").next()
    val param = writer.defaultWriteParam.apply { compressionMode = javax.imageio.ImageWriteParam.MODE_EXPLICIT; compressionQuality = 0.9f }
    javax.imageio.stream.FileImageOutputStream(file).use { out -> writer.output = out; writer.write(null, javax.imageio.IIOImage(img, null, null), param) }
    writer.dispose()
}

/** The picture with its text box below, as in the app (same as the model picture). */
private fun withText(img: BufferedImage, text: String): BufferedImage {
    val w = img.width; val h = img.height; val box = 170
    val out = BufferedImage(w, h + box, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x101014); g.fillRect(0, 0, out.width, out.height)
    g.drawImage(img, 0, 0, null)
    g.color = Color(0x96784A); g.drawRect(30, h + 18, w - 60, box - 36)
    g.color = Color(0xEBE1C8); g.font = Font(Font.SANS_SERIF, Font.PLAIN, 34)
    var line = ""; var ly = h + 68
    for (word in text.split(" ")) {
        if (g.fontMetrics.stringWidth("$line $word") > w - 120) { g.drawString(line.trim(), 54, ly); ly += 46; line = "" }
        line += " $word"
    }
    g.drawString(line.trim(), 54, ly)
    return out
}

/** What the three pictures share beyond the model picture's tools: ground pools of light, cobbles, people as silhouettes. */
internal abstract class IntroPainter : BridgePainter(true) {
    /** The ground out to the horizon under everything else, so no gap is left where nothing is drawn. */
    fun backdrop(c: Color) = poly(c, 0.0, hy - 3, W.toDouble(), hy - 3, W.toDouble(), H.toDouble(), 0.0, H.toDouble())

    /** The near ground a little darker, so the eye goes to the light in the middle distance. */
    fun nearDark(a: Double) {
        g.paint = GradientPaint(0f, (H * 0.72).toFloat(), alpha(Color(0x040508), 0.0), 0f, H.toFloat(), alpha(Color(0x040508), a)); g.fillRect(0, (H * 0.72).toInt(), W, H)
    }

    /** A pool of light lying flat on the ground at (x, z). */
    fun groundPool(x: Double, z: Double, r: Double, c: Color, a: Double, flat: Double = 0.3) {
        val px = sx(x, z); val py = sy(0.0, z); val rr = f * r / z
        if (rr < 1) return
        val t = g.transform; g.translate(px, py); g.scale(1.0, flat)
        g.paint = RadialGradientPaint(Point2D.Double(0.0, 0.0), rr.toFloat(), floatArrayOf(0f, 0.45f, 1f),
            arrayOf(alpha(c, a), alpha(c, a * 0.4), alpha(c, 0.0)), MultipleGradientPaint.CycleMethod.NO_CYCLE)
        g.fill(Ellipse2D.Double(-rr, -rr, rr * 2, rr * 2)); g.transform = t
    }

    /**
     * Cobbles as in the village square of the diagonal world: rounded stones of uneven size in loose rows, dark joints with
     * earth between, every stone a little domed (its far side catches the moon, its near side lies in its own shadow);
     * [light] gives extra warm light at a point of the ground (0 = none).
     */
    fun cobbles(x0: Double, x1: Double, z0: Double, z1: Double, light: (Double, Double) -> Double = { _, _ -> 0.0 }) {
        quad(far(night(0x2A2620), (z0 + z1) / 2), x0, 0.0, z0, x1, 0.0, z0, x1, 0.0, z1, x0, 0.0, z1)
        var z = z0; var row = 0
        while (z < z1) {
            val dz = 0.15 + 0.09 * rnd(row, 301)
            if (z > 35) { z += dz * 4; row++; continue }
            var x = x0 - rnd(row, 302) * 0.3
            var k = 0
            while (x < x1) {
                val id = row * 211 + k
                val dx = 0.15 + 0.2 * rnd(id, 303)
                val v = rnd(id, 304)
                val warm = light(x + dx / 2, z + dz / 2)
                var c = night(if (v > 0.7) 0x8A8478 else if (v > 0.35) 0x726C60 else 0x5E584E, 0.7 + 0.35 * rnd(id, 305))
                if (warm > 0.01) c = mix(c, Color(0xB07A40), (warm * 0.9).coerceAtMost(0.8))
                val cxx = x + dx / 2 + (rnd(id, 306) - 0.5) * 0.03; val czz = z + dz / 2 + (rnd(id, 307) - 0.5) * 0.03
                val rx = dx / 2 - 0.02 - 0.015 * rnd(id, 308); val rz = dz / 2 - 0.018
                fun stone(sc: Double, dzOff: Double): Path2D.Double {
                    val p = Path2D.Double()
                    for (j in 0 until 10) {
                        val a = Math.PI * 2 * j / 10
                        val rr = sc * (0.88 + 0.16 * rnd(j, id * 3 + 7))
                        val wx = cxx + cos(a) * rx * rr; val wz = czz + dzOff + sin(a) * rz * rr
                        if (j == 0) p.moveTo(sx(wx, wz), sy(0.0, wz)) else p.lineTo(sx(wx, wz), sy(0.0, wz))
                    }
                    p.closePath(); return p
                }
                g.color = far(c, z); g.fill(stone(1.0, 0.0))
                if (z < 16) {
                    // the dome: lighter on the far half, a dark rim on the near edge
                    g.color = alpha(far(mix(c, Color(0xB8BCC8), 0.25 + 0.3 * warm), z), 0.55); g.fill(stone(0.62, rz * 0.3))
                    g.color = alpha(Color(0x0A0908), 0.35); g.fill(stone(0.95, -rz * 0.35)); g.color = far(c, z); g.fill(stone(0.85, rz * 0.08))
                    g.color = alpha(far(mix(c, Color(0xB8BCC8), 0.2 + 0.3 * warm), z), 0.5); g.fill(stone(0.55, rz * 0.35))
                }
                x += dx; k++
            }
            // earth and a blade of grass here and there in the joints
            if (z < 10) for (q in 0 until 6) {
                val gx = x0 + (x1 - x0) * rnd(row * 13 + q, 309); val l = f * (0.03 + 0.05 * rnd(row * 13 + q, 310)) / z
                line(alpha(night(0x4A5A3A, 1.1), 0.7), maxOf(0.8, f * 0.006 / z), sx(gx, z), sy(0.0, z), sx(gx, z) + l * 0.3, sy(0.0, z) - l)
            }
            z += dz; row++
        }
    }

    /**
     * A person as a silhouette (70.2: recognised by outline, not by face), standing at (x, z), [h] tall:
     * a hooded cloak widening to the hem; [torch] raises a burning torch in the right hand.
     */
    fun cloaked(x: Double, z: Double, h: Double, c: Color, torch: Boolean, lean: Double = 0.0): Pair<Double, Double>? {
        val s = f / z
        val px = sx(x, z); val py = sy(0.0, z)
        val p = Path2D.Double()
        val hw = 0.24 * s; val top = py - h * s
        p.moveTo(px - hw * 1.35, py)
        p.curveTo(px - hw * 1.2, py - h * s * 0.4, px - hw * 1.05, py - h * s * 0.7, px - hw * 0.9 + lean * s, py - h * s * 0.82)
        // the hood, pointed a little back
        p.curveTo(px - hw * 0.75 + lean * s, top - 0.04 * s, px + hw * 0.2 + lean * s, top - 0.08 * s, px + hw * 0.7 + lean * s, py - h * s * 0.86)
        p.curveTo(px + hw * 1.05, py - h * s * 0.7, px + hw * 1.25, py - h * s * 0.4, px + hw * 1.4, py)
        p.closePath()
        g.color = c; g.fill(p)
        if (!torch) return null
        // the arm up, the torch above the hood
        val ax = px + hw * 0.8 + lean * s; val ay = py - h * s * 0.72
        val tx = px + hw * 1.25 + lean * s; val ty = top - 0.25 * s
        line(c, maxOf(1.5, 0.09 * s), ax, ay, tx, ty + 0.12 * s)
        line(Color(0x2A1A10), maxOf(1.2, 0.05 * s), tx - 0.02 * s, ty + 0.5 * s, tx, ty)
        return tx to ty
    }

    /** A torch flame at screen point (x, y), [s] pixels per metre, with its glow. */
    fun flame(x: Double, y: Double, s: Double, seed: Int) {
        glow(x, y, s * 4.5, warmDeep, 0.3)
        glow(x, y, s * 1.3, warm, 0.6)
        for (k in 0 until 3) {
            val w = s * (0.12 - k * 0.03); val hgt = s * (0.32 - k * 0.07) * (0.85 + 0.3 * rnd(seed, 700 + k))
            val p = Path2D.Double(); val lean = (rnd(seed, 710 + k) - 0.3) * w
            p.moveTo(x - w, y); p.quadTo(x - w * 0.8, y - hgt * 0.6, x + lean, y - hgt); p.quadTo(x + w * 0.8, y - hgt * 0.5, x + w, y); p.closePath()
            g.color = listOf(Color(0xE06A20), Color(0xFFB040), Color(0xFFF0B0))[k]; g.fill(p)
        }
    }

    /** Distant rolling hills on the horizon, each ridge lit by the moon on its crest. */
    fun hills(z: Double, amp: Double, seed: Int, c: Color, lit: Color) {
        val p = Path2D.Double(); p.moveTo(0.0, hy + 6)
        val pts = ArrayList<Pair<Double, Double>>()
        for (xi in 0..W step 8) {
            val u = xi / W.toDouble()
            val y = sy(amp * (0.5 + 0.3 * sin(u * 5.1 + seed) + 0.2 * sin(u * 13.7 + seed * 2.3)), z)
            pts += xi.toDouble() to y; p.lineTo(xi.toDouble(), y)
        }
        p.lineTo(W.toDouble(), hy + 6); p.closePath()
        g.color = far(c, z); g.fill(p)
        for (i in 1 until pts.size) line(alpha(far(lit, z), 0.5), 1.2, pts[i - 1].first, pts[i - 1].second, pts[i].first, pts[i].second)
    }
}

/**
 * `[69.intro.1]` The south road under the moon: the traveller's eyes on an empty road that runs north over the heath,
 * the moon ahead above it and mirrored in a puddle in the rut; split-rail fence on the left, a milestone, firs, an owl.
 */
internal class RoadPainter : IntroPainter() {
    override val hy = 560.0; override val eye = 1.7; override val camX = 0.0; override val pan = 0.0
    override val moonX = 720.0; override val moonY = 240.0

    /** The road's middle at depth z: straight near, then a slow bend to the right and back. */
    fun mid(z: Double) = if (z < 10) 0.0 else 0.012 * (z - 10) * (z - 10) / (1 + (z - 10) / 40)
    val half = 1.7

    override fun scene() {
        sky()
        hills(420.0, 26.0, 3, Color(0x141C2A), Color(0x4A5674))
        hills(240.0, 12.0, 7, Color(0x101820), Color(0x3E4A5E))
        forestBand2()
        heath()
        roadBed()
        puddle()
        fence()
        milestone(3.0, 8.0)
        nearFirs()
        verge()
        owlAndBats()
        nearDark(0.35)
        vignette()
    }

    /** A dark band of forest far ahead where the road disappears. */
    fun forestBand2() {
        for (i in 0 until 120) {
            val z = 150.0 + rnd(i, 21) * 50; val x = (rnd(i, 22) - 0.5) * 260
            if (abs(x - mid(z)) < 4) continue
            val hgt = 13.0 + rnd(i, 23) * 9
            firShape(sx(x, z), sy(0.0, z), f * hgt / z, f * hgt * 0.38 / z, far(fir, z), far(firLit, z), 0.35)
        }
    }

    /** The heath on both sides: dark grass, heather, the moon's light lying on the far slopes. */
    fun heath() {
        poly(far(night(dGrass, 0.9), 120.0), 0.0, hy, W.toDouble(), hy, W.toDouble(), H.toDouble(), 0.0, H.toDouble())
        g.paint = GradientPaint(0f, hy.toFloat(), alpha(Color(0x3A4A58), 0.45), 0f, (hy + 160).toFloat(), alpha(Color(0x3A4A58), 0.0))
        g.fillRect(0, hy.toInt(), W, 160)
        // the moon's light lies on the heath below it, a broad pale band towards us
        glow(moonX, hy + 40, 420.0, Color(0x5A6A84), 0.18)
        // dark juniper bushes scattered over the heath, the moon on their tops
        for (i in 0 until 40) {
            val z = 16.0 + rnd(i, 37).let { it * it } * 80; val x = (rnd(i, 38) - 0.5) * z * 1.3
            if (abs(x - mid(z)) < half + 2.5) continue
            val r = f * (0.3 + 0.35 * rnd(i, 39)) / z; val px = sx(x, z); val py = sy(0.0, z)
            for (k in 0 until 5) { val ox = (rnd(i * 5 + k, 40) - 0.5) * r * 1.4; val oy = rnd(i * 5 + k, 41) * r * 0.5; val rr = r * (0.5 + 0.4 * rnd(i * 5 + k, 42))
                g.color = far(Color(0x0C1410), z); g.fill(Ellipse2D.Double(px + ox - rr, py - oy - rr * 1.2, rr * 2, rr * 1.3))
                g.color = alpha(far(night(0x7A9A80, 1.1), z), 0.3); g.fill(Ellipse2D.Double(px + ox - rr * 0.8, py - oy - rr * 1.2, rr * 1.0, rr * 0.35)) }
        }
        for (i in 0 until 5200) {
            val z = 1.5 + rnd(i, 31).let { it * it * it } * 110
            val x = (rnd(i, 32) - 0.5) * z * 1.2
            if (abs(x - mid(z)) < half + 0.1) continue
            val px = sx(x, z); val py = sy(0.0, z); val l = f * (0.08 + rnd(i, 33) * 0.12) / z
            val heather = rnd(i, 34) > 0.82
            val c = if (heather) night(0x6A4A6A, 1.1) else if (rnd(i, 35) > 0.6) night(0x7A8A5A, 1.1) else night(0x2A3A28)
            line(alpha(far(c, z), 0.85), maxOf(0.8, f * 0.014 / z), px, py, px + (rnd(i, 36) - 0.5) * l * 0.6, py - l)
        }
    }

    /** The road: packed earth, two ruts with grass between, lighter towards the moon where the light lies on it. */
    fun roadBed() {
        val zs = ArrayList<Double>(); var z = 1.2
        while (z < 260) { zs += z; z *= 1.04 }
        for (i in 0 until zs.size - 1) {
            val a = zs[i]; val b = zs[i + 1]
            val ma = mid(a); val mb = mid(b)
            val sheen = exp(-abs(sx(mb, b) - moonX) / 260.0) * (b / (b + 25))
            val c = mix(far(night(dEarth, 0.9), b), Color(0x8A8C98), 0.35 * sheen)
            quad(c, ma - half, 0.0, a, ma + half, 0.0, a, mb + half, 0.0, b, mb - half, 0.0, b)
            // the ruts, darker, and the grass strip between them
            for (r in listOf(-0.8, 0.8)) quad(alpha(Color(0x14100E), 0.45), ma + r - 0.16, 0.0, a, ma + r + 0.16, 0.0, a, mb + r + 0.16, 0.0, b, mb + r - 0.16, 0.0, b)
            quad(alpha(far(night(dGrass, 0.8), b), 0.7), ma - 0.35, 0.0, a, ma + 0.35, 0.0, a, mb + 0.35, 0.0, b, mb - 0.35, 0.0, b)
        }
        // pebbles and the grass in the middle strip
        for (i in 0 until 2400) {
            val z = 1.3 + rnd(i, 41).let { it * it } * 40; val m = mid(z)
            val u = rnd(i, 42) * 2 - 1
            val x = m + u * half
            if (abs(u * half) < 0.35) {
                val l = f * (0.05 + rnd(i, 43) * 0.1) / z
                line(alpha(night(if (rnd(i, 44) > 0.5) 0x7A8A5A else 0x3A4A30), 0.8), maxOf(0.8, f * 0.012 / z), sx(x, z), sy(0.0, z), sx(x, z) + (rnd(i, 45) - 0.5) * l, sy(0.0, z) - l)
            } else {
                val r = f * (0.006 + rnd(i, 46) * 0.014) / z
                g.color = alpha(if (rnd(i, 47) > 0.6) Color(0x5A5450) else Color(0x16120F), 0.6)
                g.fill(Ellipse2D.Double(sx(x, z) - r, sy(0.0, z) - r * 0.5, r * 2, r))
            }
        }
    }

    /** A puddle in the left rut near us, the moon mirrored in it (70: reflections). */
    fun puddle() {
        val z0 = 3.6; val z1 = 6.4; val x = 0.8
        val p = Path2D.Double()
        for (j in 0..24) {
            val a = Math.PI * 2 * j / 24
            val wz = (z0 + z1) / 2 + cos(a) * (z1 - z0) / 2 * (0.9 + 0.15 * sin(a * 5)); val wx = x + sin(a) * (0.22 + 0.05 * sin(a * 3) + 0.03 * cos(a * 7))
            if (j == 0) p.moveTo(sx(wx, wz), sy(0.0, wz)) else p.lineTo(sx(wx, wz), sy(0.0, wz))
        }
        p.closePath()
        g.paint = GradientPaint(0f, sy(0.0, z1).toFloat(), Color(0x18223A), 0f, sy(0.0, z0).toFloat(), Color(0x080C16)); g.fill(p)
        val clip = g.clip; g.clip(p)
        // the moon in the water: straight down the line of sight, a little broken
        val mx = sx(x, 5.0); val my = sy(0.0, 5.6)
        glow(mx, my, 70.0, moonCool, 0.3)
        g.color = alpha(Color(0xE8E4D0), 0.75); g.fill(Ellipse2D.Double(mx - 16, my - 9, 32.0, 18.0))
        for (k in 0 until 3) { val yy = my + 14 + k * 9.0
            line(alpha(Color(0xC8CCD8), 0.35 - k * 0.1), 1.4, mx - 18 + k * 3, yy, mx + 14 - k * 2, yy) }
        g.clip = clip
        // wet mud at its rim, the moon's sheen on the far edge
        g.color = alpha(Color(0x1A1612), 0.7); g.stroke = BasicStroke(3f); g.draw(p)
        line(alpha(Color(0x8A96B4), 0.6), 1.4, sx(x - 0.2, z1 - 0.3), sy(0.0, z1 - 0.3), sx(x + 0.18, z1 - 0.2), sy(0.0, z1 - 0.2))
    }

    /** An old split-rail fence along the left side of the road, posts leaning, the moon on their tops. */
    fun fence() {
        val xs = -half - 1.3
        var prev: Pair<Double, Double>? = null
        var z = 2.6; var k = 0
        while (z < 90) {
            val x = xs + mid(z)
            val lean = (rnd(k, 61) - 0.5) * 0.12
            val hgt = 1.15 + 0.15 * rnd(k, 62)
            val c = far(night(dTimber, 1.2), z)
            line(c, maxOf(1.2, f * 0.12 / z), sx(x, z), sy(0.0, z), sx(x + lean, z), sy(hgt, z))
            line(alpha(far(night(0xB0A690, 1.2), z), 0.5), maxOf(0.8, f * 0.02 / z), sx(x - 0.04, z), sy(0.1, z), sx(x + lean - 0.04, z), sy(hgt, z))
            if (prev != null && k % 7 != 4) {
                val (px, pz) = prev
                for (ry in listOf(0.95, 0.5)) line(far(night(dTimber, 1.05), z), maxOf(1.0, f * 0.07 / z), sx(px, pz), sy(ry, pz), sx(x, z), sy(ry - 0.05 * rnd(k, 63), z))
            }
            prev = x to z
            z += 2.4; k++
        }
    }

    /** A milestone at the right edge of the road: a squat block of rough stone, a notch cut in it, moss and grass at its foot. */
    fun milestone(x: Double, z: Double) {
        val s = f / z
        val px = sx(x, z); val py = sy(0.0, z)
        softShadow(px + 0.35 * s, py, 0.55 * s)
        val p = Path2D.Double()
        p.moveTo(px - 0.24 * s, py); p.lineTo(px - 0.26 * s, py - 0.3 * s); p.lineTo(px - 0.2 * s, py - 0.5 * s); p.lineTo(px - 0.05 * s, py - 0.56 * s)
        p.lineTo(px + 0.14 * s, py - 0.52 * s); p.lineTo(px + 0.22 * s, py - 0.4 * s); p.lineTo(px + 0.25 * s, py - 0.12 * s); p.lineTo(px + 0.27 * s, py); p.closePath()
        g.color = night(0x6E6A60, 0.95); g.fill(p)
        texture(p, z, Color(0x1A1C22), night(0xA0A090, 1.3), 1600, 0.012)
        // the top and the left face in the moon, the right in shadow
        poly(alpha(Color(0xB8C0D4), 0.3), px - 0.2 * s, py - 0.5 * s, px - 0.05 * s, py - 0.56 * s, px + 0.14 * s, py - 0.52 * s, px + 0.05 * s, py - 0.46 * s, px - 0.15 * s, py - 0.45 * s)
        g.paint = GradientPaint(px.toFloat(), 0f, alpha(Color(0x05060A), 0.0), (px + 0.27 * s).toFloat(), 0f, alpha(Color(0x05060A), 0.55)); g.fill(p)
        // the notch: a cut mark for the miles, worn
        line(Color(0x1E1E22), maxOf(1.0, 0.03 * s), px - 0.1 * s, py - 0.34 * s, px + 0.06 * s, py - 0.36 * s)
        line(Color(0x1E1E22), maxOf(1.0, 0.03 * s), px - 0.03 * s, py - 0.42 * s, px - 0.02 * s, py - 0.27 * s)
        for (i in 0 until 50) { val xx = px + (rnd(i, 71) - 0.5) * 0.65 * s; val l = (0.05 + rnd(i, 72) * 0.14) * s
            line(alpha(night(if (rnd(i, 74) > 0.5) 0x4A5A3A else 0x2A3A28, 1.2), 0.85), 1.2, xx, py, xx + (rnd(i, 73) - 0.5) * l, py - l) }
    }

    /** Firs on both sides, near ones with volume, a dead pine on the right against the sky. */
    fun nearFirs() {
        val list = listOf(Triple(-14.0, 40.0, 13.0), Triple(-9.0, 58.0, 11.0), Triple(16.0, 34.0, 12.0), Triple(22.0, 46.0, 15.0), Triple(-22.0, 30.0, 14.0), Triple(11.0, 70.0, 10.0))
        for ((x, z, h) in list.sortedByDescending { it.second }) {
            g.color = alpha(Color(0x05080A), 0.5); g.fill(Ellipse2D.Double(sx(x, z) - f * 2.2 / z, sy(0.0, z) - f * 0.5 / z, f * 4.4 / z, f * 1.0 / z))
            firShape(sx(x, z), sy(0.0, z), f * h / z, f * h * 0.42 / z, far(fir, z), far(firLit, z), 0.7)
        }
        // an old leafless oak on the right against the sky: crooked limbs, finer and finer twigs, the moon on their left sides
        val x = 11.5; val z = 26.0; val s = f / z
        val bx = sx(x, z); val by = sy(0.0, z)
        softShadow(bx + 1.2 * s, by, 2.4 * s)
        fun limb(x0: Double, y0: Double, ang: Double, len: Double, w: Double, depth: Int, seed: Int) {
            val x1 = x0 + cos(ang) * len; val y1 = y0 - sin(ang) * len
            // a little bend in every limb
            val mx = (x0 + x1) / 2 + (rnd(seed, 961) - 0.5) * len * 0.25; val my = (y0 + y1) / 2 + (rnd(seed, 962) - 0.5) * len * 0.2
            val p = Path2D.Double(); p.moveTo(x0, y0); p.quadTo(mx, my, x1, y1)
            g.color = Color(0x0C0A0A); g.stroke = BasicStroke(maxOf(0.8f, w.toFloat()), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(p)
            if (w > 3) { val q = Path2D.Double(); q.moveTo(x0 - w * 0.3, y0); q.quadTo(mx - w * 0.3, my, x1 - w * 0.3, y1)
                g.color = alpha(Color(0x6A7088), 0.35); g.stroke = BasicStroke(maxOf(0.8f, (w * 0.18).toFloat())); g.draw(q) }
            if (depth == 0) return
            val n = if (depth > 3) 2 else 3
            for (k in 0 until n) {
                val a = ang + (k - (n - 1) / 2.0) * (0.55 + 0.3 * rnd(seed * 7 + k, 963)) + (rnd(seed * 7 + k, 964) - 0.5) * 0.4
                limb(x1, y1, a, len * (0.62 + 0.2 * rnd(seed * 7 + k, 965)), w * 0.62, depth - 1, seed * 7 + k + 1)
            }
        }
        // the trunk, thick and leaning a little, then the crown
        val trunk = Path2D.Double()
        trunk.moveTo(bx - 0.45 * s, by); trunk.quadTo(bx - 0.2 * s, by - 1.6 * s, bx - 0.3 * s, by - 3.2 * s); trunk.lineTo(bx + 0.1 * s, by - 3.3 * s)
        trunk.quadTo(bx + 0.15 * s, by - 1.6 * s, bx + 0.5 * s, by); trunk.closePath()
        g.color = Color(0x0C0A0A); g.fill(trunk)
        line(alpha(Color(0x6A7088), 0.4), 0.06 * s, bx - 0.36 * s, by - 0.1 * s, bx - 0.26 * s, by - 3.0 * s)
        limb(bx - 0.1 * s, by - 3.2 * s, Math.PI * 0.6, 2.2 * s, 0.32 * s, 6, 3)
        limb(bx - 0.1 * s, by - 3.2 * s, Math.PI * 0.38, 2.0 * s, 0.28 * s, 6, 5)
        limb(bx - 0.2 * s, by - 2.6 * s, Math.PI * 0.75, 1.6 * s, 0.2 * s, 5, 9)
    }

    /** Tall grass and seed heads along the verges right in front of us, dark against the lit road. */
    fun verge() {
        for (i in 0 until 900) {
            val z = 1.25 + rnd(i, 81) * 2.4
            val side = if (rnd(i, 82) > 0.5) 1 else -1
            val x = mid(z) + side * (half + 0.05 + rnd(i, 83) * 1.4)
            val px = sx(x, z); val py = sy(0.0, z); val l = f * (0.18 + rnd(i, 84) * 0.35) / z
            val c = if (rnd(i, 85) > 0.75) Color(0x4A5A40) else Color(0x121A14)
            val p = Path2D.Double(); val lean = (rnd(i, 86) - 0.5) * l * 0.5
            p.moveTo(px, py); p.quadTo(px + lean * 0.2, py - l * 0.6, px + lean, py - l)
            g.color = c; g.stroke = BasicStroke((1.0 + rnd(i, 87) * 1.8).toFloat(), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(p)
            if (i % 19 == 0) { g.color = Color(0x2A2418); g.fill(Ellipse2D.Double(px + lean - 2.5, py - l - 3, 5.0, 14.0)) }
        }
    }

    /** Life: an owl on a fence post looking at us, two bats near the moon. */
    fun owlAndBats() {
        val z = 9.8; val x = -half - 1.3 + mid(z); val s = f / z
        val px = sx(x, z); val py = sy(1.22, z)
        g.color = Color(0x16120E)
        g.fill(Ellipse2D.Double(px - 0.13 * s, py - 0.36 * s, 0.26 * s, 0.38 * s))
        g.fill(Ellipse2D.Double(px - 0.11 * s, py - 0.5 * s, 0.22 * s, 0.2 * s))
        // ear tufts and the moon on the left of the head
        poly(Color(0x16120E), px - 0.1 * s, py - 0.44 * s, px - 0.08 * s, py - 0.56 * s, px - 0.04 * s, py - 0.46 * s)
        poly(Color(0x16120E), px + 0.1 * s, py - 0.44 * s, px + 0.08 * s, py - 0.56 * s, px + 0.04 * s, py - 0.46 * s)
        line(alpha(Color(0x8A90A0), 0.5), 1.2, px - 0.12 * s, py - 0.45 * s, px - 0.13 * s, py - 0.1 * s)
        for (ex in listOf(-0.045, 0.045)) { glow(px + ex * s, py - 0.41 * s, 0.05 * s, Color(0xE0B040), 0.6)
            g.color = Color(0xF0C860); g.fill(Ellipse2D.Double(px + ex * s - 0.018 * s, py - 0.43 * s, 0.036 * s, 0.036 * s)) }
        for ((bx, by, sc) in listOf(Triple(moonX + 90, moonY - 40, 1.0), Triple(moonX - 130, moonY - 95, 0.7))) {
            val p = Path2D.Double(); val w = 16 * sc
            p.moveTo(bx - w, by - w * 0.3); p.quadTo(bx - w * 0.5, by + w * 0.1, bx - w * 0.15, by - w * 0.05)
            p.lineTo(bx, by + w * 0.12); p.lineTo(bx + w * 0.15, by - w * 0.05)
            p.quadTo(bx + w * 0.5, by + w * 0.1, bx + w, by - w * 0.3); p.quadTo(bx + w * 0.4, by + w * 0.25, bx, by + w * 0.3)
            p.quadTo(bx - w * 0.4, by + w * 0.25, bx - w, by - w * 0.3); p.closePath()
            g.color = Color(0x06080E); g.fill(p)
        }
    }
}

/**
 * `[69.intro.3]` re-staged (Sokrates 15.10., 12:0x, after the user's 11:5x): the hero a few steps past the bridge on the north
 * road, looking up it to the sleeping square in the depth, turned a little to the right. On the right the temple at a slant,
 * its south front with the open door towards the lower street as on the village map; a few cloaked figures with torches have
 * come up the path from the street and stand before its steps, their light warm on the stones, their shadows towards us.
 * Laid out in the world (X east, N north, metres; [IntroLife.camX]/[IntroLife.camZ] turn it into the camera's x, z).
 */
internal class SquarePainter : IntroPainter() {
    override val hy = IntroLife.HY.toDouble(); override val eye = IntroLife.EYE.toDouble(); override val camX = 0.0; override val pan = IntroLife.PAN.toDouble()
    override val moonX = 150.0; override val moonY = 115.0

    /**
     * What to paint (70.3 B): [Part.ALL] the whole still; [Part.BASE] the picture the app shows under the life, without the
     * bearers, their flames, their light on the stones and in the puddle, the smoke and the bats; [Part.GROUP] only the
     * bearers (silhouettes, rims, shadows, torch shafts) on a clear ground, the layer the app moves.
     */
    enum class Part { ALL, BASE, GROUP }
    var part = Part.ALL

    // the world and its turn into the camera
    fun cxw(wx: Double, wn: Double) = IntroLife.camX(wx.toFloat(), wn.toFloat()).toDouble()
    fun czw(wx: Double, wn: Double) = IntroLife.camZ(wx.toFloat(), wn.toFloat()).toDouble()
    fun P(wx: Double, y: Double, wn: Double) = Point2D.Double(sx(cxw(wx, wn), czw(wx, wn)), sy(y, czw(wx, wn)))
    fun shape(vararg p: Point2D.Double) = Path2D.Double().apply { moveTo(p[0].x, p[0].y); for (i in 1 until p.size) lineTo(p[i].x, p[i].y); closePath() }
    fun fillW(c: Color, vararg p: Point2D.Double) { g.color = c; g.fill(shape(*p)) }
    /** A flat patch of ground between wx0..wx1 and wn0..wn1. */
    fun patch(wx0: Double, wx1: Double, wn0: Double, wn1: Double) = shape(P(wx0, 0.0, wn0), P(wx1, 0.0, wn0), P(wx1, 0.0, wn1), P(wx0, 0.0, wn1))

    // the temple (map: front "W#D#W#" at x 26..31, the door at 28, the path down to the lower street)
    val tx0 = IntroLife.TEMPLE_X.toDouble(); val tn = IntroLife.TEMPLE_N.toDouble(); val tw = IntroLife.TEMPLE_W.toDouble(); val td = 9.0
    val twall = 6.2; val troof = 4.4; val tdoor = IntroLife.DOOR_A.toDouble()
    /** A point on the temple: [a] metres along its front from the west corner, [y] up, [d] metres behind the front (minus: before it). */
    fun T(a: Double, y: Double, d: Double = 0.0) = P(tx0 + a, y, tn + d)
    fun tz(a: Double, d: Double = 0.0) = czw(tx0 + a, tn + d)
    // the streets: the north road under the hero, the lower street across, the path up to the temple
    val streetN0 = 3.0; val streetN1 = 5.6

    /** The house left beyond the square whose chimney smokes (camera coordinates, as [IntroLife.smokeX] expects). */
    val farLeft = House(-12.0, 26.0, 8.0, 6.0, 3.6, 3.2, listOf(1))
    val farRight = House(-1.5, 36.0, 9.0, 7.0, 3.8, 3.4, listOf(0, 2))
    val farMid = House(-22.0, 34.0, 9.0, 7.0, 3.8, 3.4, listOf(1))

    init {
        houseWin[farLeft] = listOf(-14.5, -10.0) to -12.2
        houseWin[farRight] = listOf(-4.0, 1.2) to -1.4
        houseWin[farMid] = listOf(-24.5) to -21.0
    }

    /** Warm light on the ground at camera (x, z): the open door, and the torches in the full still. */
    fun torchLight(x: Double, z: Double): Double {
        val t = if (part != Part.ALL) 0.0 else IntroLife.bearers.filter { it.torch }.sumOf { b -> 0.6 * exp(-Math.hypot(x - b.x, z - b.z) / 2.0) }
        val d = 0.45 * exp(-Math.hypot((x - IntroLife.doorX) / 1.8, (z - IntroLife.doorZ) / 2.2))
        return t + d
    }

    override fun scene() {
        if (part == Part.GROUP) { torchBearers(); return }
        sky()
        backdrop(far(night(dGrass, 0.8), 80.0))
        forestBand()
        ground()
        // standing things, far to near
        firShape(sx(-30.0, 44.0), sy(0.0, 44.0), f * 12.0 / 44, f * 5.0 / 44, far(fir, 44.0), far(firLit, 44.0), 0.6)
        firShape(sx(-6.0, 46.0), sy(0.0, 46.0), f * 13.0 / 46, f * 5.4 / 46, far(fir, 46.0), far(firLit, 46.0), 0.6)
        firShape(sx(16.0, 40.0), sy(0.0, 40.0), f * 14.0 / 40, f * 5.6 / 40, far(fir, 40.0), far(firLit, 40.0), 0.6)
        house(farRight, false)
        house(farMid, false)
        house(farLeft, false)
        stall(cxw(-7.0, 28.0), czw(-7.0, 28.0))
        well(cxw(-1.0, 24.0), czw(-1.0, 24.0))
        firShape(sx(cxw(-8.0, 17.0), czw(-8.0, 17.0)), sy(0.0, czw(-8.0, 17.0)), f * 9.0 / czw(-8.0, 17.0), f * 3.6 / czw(-8.0, 17.0), far(fir, 14.0), far(firLit, 14.0), 0.65)
        temple()
        if (part == Part.ALL) torchBearers()
        verge()
        if (part == Part.ALL) life2()
        nearDark(0.45)
        vignette()
    }

    /** The ground: grass, the earthen roads with their pebbles and ruts, the cobbles of the square and before the temple. */
    fun ground() {
        // grass everywhere first, darker near
        fillW(night(dGrass, 0.75), P(-60.0, 0.0, 0.6), P(60.0, 0.0, 0.6), P(60.0, 0.0, 60.0), P(-60.0, 0.0, 60.0))
        val clip = g.clip
        // the square and the temple forecourt: cobbles, clipped to their patches
        for ((wx0, wx1, wn0, wn1) in listOf(listOf(-12.0, 10.0, 19.0, 38.0), listOf(tx0 - 1.2, tx0 + tw + 1.0, streetN1, tn))) {
            g.clip(patch(wx0, wx1, wn0, wn1))
            val xs = listOf(cxw(wx0, wn0), cxw(wx1, wn0), cxw(wx1, wn1), cxw(wx0, wn1)); val zs = listOf(czw(wx0, wn0), czw(wx1, wn0), czw(wx1, wn1), czw(wx0, wn1))
            cobbles(xs.min(), xs.max(), maxOf(1.0, zs.min()), zs.max(), ::torchLight)
            g.clip = clip
        }
        // the earthen roads: the north road from the bridge up to the square, the lower street across, the temple path
        val earthC = night(dEarth, 1.0)
        val roads = listOf(listOf(-1.5, 1.5, 0.6, 19.4), listOf(-60.0, 60.0, streetN0, streetN1), listOf(tx0 + tdoor - 1.1, tx0 + tdoor + 1.1, streetN1 - 0.2, tn - 2.4))
        for ((wx0, wx1, wn0, wn1) in roads) { g.color = earthC; g.fill(patch(wx0, wx1, wn0, wn1)) }
        // grass fringes along the road edges, soft
        for ((wx0, wx1, wn0, wn1) in roads) for (e in listOf(wx0, wx1)) if (abs(e) < 50)
            for (k in 0 until 60) { val wn = wn0 + (wn1 - wn0) * rnd(k, 811 + (e * 10).toInt()); val z = czw(e, wn); if (z < 1.2) continue
                val p = P(e + (rnd(k, 812) - 0.5) * 0.3, 0.0, wn); val l = f * (0.08 + 0.12 * rnd(k, 813)) / z
                line(alpha(night(0x6A7650, 0.9), 0.7), maxOf(0.8, f * 0.012 / z), p.x, p.y, p.x + (rnd(k, 814) - 0.5) * l, p.y - l) }
        for (k in 0 until 50) { val wn = streetN0 + (streetN1 - streetN0) * rnd(k, 815); val wx = -30.0 + 60 * rnd(k, 816)
            val edge = if (rnd(k, 817) > 0.5) streetN0 else streetN1; val z = czw(wx, edge); if (z < 1.2 || wx in -1.6..1.6) continue
            val p = P(wx, 0.0, edge); val l = f * (0.08 + 0.12 * rnd(k, 818)) / z
            line(alpha(night(0x6A7650, 0.9), 0.7), maxOf(0.8, f * 0.012 / z), p.x, p.y, p.x + (rnd(k, 819) - 0.5) * l, p.y - l) }
        // pebbles, clods and a pale worn track on the earth
        for ((ax0, ax1, wn0, wn1) in roads) { val wx0 = maxOf(ax0, -12.0); val wx1 = minOf(ax1, 24.0)
          for (i in 0 until ((wx1 - wx0) * (wn1 - wn0) * 60).toInt().coerceAtMost(9000)) {
            val wx = wx0 + (wx1 - wx0) * rnd(i, 821 + (wx0 * 3).toInt()); val wn = wn0 + (wn1 - wn0) * rnd(i, 822 + (wn0 * 7).toInt())
            val z = czw(wx, wn); if (z < 1.6 || z > 50) continue
            val px = sx(cxw(wx, wn), z); if (px < -20 || px > W + 20) continue
            val r = f * (0.012 + 0.026 * rnd(i, 823)) / z; val v = rnd(i, 824)
            g.color = alpha(far(mix(night(if (v > 0.55) 0x9A8A70 else 0x2E2418, if (v > 0.55) 1.05 else 1.0), Color(0xB07A40), (torchLight(cxw(wx, wn), z) * 0.8).coerceAtMost(0.7)), z), 0.6)
            g.fill(Ellipse2D.Double(px - r, sy(0.0, z) - r * 0.4, r * 2, r * 0.8))
        } }
        // wheel ruts along the north road and the lower street
        for (rx in listOf(-0.75, 0.75)) fillW(alpha(night(0x3A2C1E), 0.45), P(rx - 0.14, 0.0, 0.8), P(rx + 0.14, 0.0, 0.8), P(rx + 0.14, 0.0, 19.0), P(rx - 0.14, 0.0, 19.0))
        for (rn in listOf(streetN0 + 0.8, streetN1 - 0.8)) fillW(alpha(night(0x3A2C1E), 0.4), P(-40.0, 0.0, rn - 0.13), P(40.0, 0.0, rn - 0.13), P(40.0, 0.0, rn + 0.13), P(-40.0, 0.0, rn + 0.13))
        // grass blades on the near grass, left of the road and right of it before the street
        for (i in 0 until 4000) {
            val wx = -14.0 + 32 * rnd(i, 831); val wn = 0.6 + 18 * rnd(i, 832)
            if (wx in -1.6..1.6 || wn in streetN0 - 0.1..streetN1 + 0.1 || wx > tx0 - 1.3 && wn > streetN1) continue
            val z = czw(wx, wn); if (z < 1.0) continue
            val p = P(wx, 0.0, wn); if (p.x < -20 || p.x > W + 20) continue
            val l = f * (0.1 + 0.16 * rnd(i, 833)) / z
            line(alpha(night(if (rnd(i, 834) > 0.5) 0x7A8658 else 0x34402A), 0.75), maxOf(0.8, f * 0.014 / z), p.x, p.y, p.x + (rnd(i, 835) - 0.5) * l * 0.6, p.y - l)
        }
        // the door's warm light on the forecourt and the path
        groundPool(IntroLife.doorX.toDouble(), IntroLife.doorZ - 1.8, 3.2, warmDeep, 0.28)
        puddle()
    }

    /**
     * The temple at a slant: dressed stone in courses, the west side with its gable towards us in the moon, a slate roof with a
     * bell gable on the ridge, tall arched windows faintly lit, a porch on two columns before the open door, the sun disc on
     * its gable (the temple of the sun amulet), two broad steps.
     */
    fun temple() {
        val zf = tz(tw / 2)
        val ry = twall + troof; val rd = td / 2
        // the west side and its gable, lit by the moon from the left
        val side = shape(T(0.0, 0.0), T(0.0, 0.0, td), T(0.0, twall, td), T(0.0, twall, 0.0))
        g.color = far(night(0x8A867A, 1.05), zf); g.fill(side)
        texture(side, zf, Color(0x22242C), night(0xB0AC9E, 1.3), 700, 0.05)
        val clip = g.clip
        g.clip(side)
        var yy = 0.0; var c = 0
        while (yy < twall) { val p0 = T(0.0, yy); val p1 = T(0.0, yy, td); line(far(Color(0x2A2A30), zf), 1.0, p0.x, p0.y, p1.x, p1.y); yy += 0.44 + 0.08 * rnd(c++, 641) }
        g.paint = GradientPaint(T(0.0, 0.0).x.toFloat(), 0f, alpha(Color(0xA8B4D0), 0.22), T(0.0, 0.0, td).x.toFloat(), 0f, alpha(Color(0xA8B4D0), 0.0)); g.fill(side)
        g.clip = clip
        val gable = shape(T(0.0, twall - 0.05, -0.5), T(0.0, twall - 0.05, td + 0.5), T(0.0, ry, rd))
        g.color = far(night(0x8A867A, 1.12), zf); g.fill(gable)
        texture(gable, zf, Color(0x22242C), night(0xB0AC9E, 1.3), 500, 0.05)
        // the roof's front slope: slate, rows of it, the moon on the west end, the ridge lit
        val rf = shape(T(-0.5, twall - 0.2, -0.5), T(tw + 0.5, twall - 0.2, -0.5), T(tw + 0.5, ry, rd), T(-0.5, ry, rd))
        g.color = far(night(dSlate, 0.95), zf); g.fill(rf)
        g.clip(rf)
        for (k in 1 until 20) { val t = k / 20.0; val y = twall - 0.2 + (ry - twall + 0.2) * t; val d = -0.5 + (rd + 0.5) * t
            val a = T(-0.5, y, d); val b = T(tw + 0.5, y, d); line(alpha(Color(0x0C0E14), 0.7), 1.0, a.x, a.y, b.x, b.y) }
        texture(rf, zf, Color(0x101016), night(0x8A9AC0), 500, 0.05, 0.35)
        g.paint = GradientPaint(T(-0.5, ry, rd).x.toFloat(), 0f, alpha(Color(0x8A9AC0), 0.28), T(5.0, ry, rd).x.toFloat(), 0f, alpha(Color(0x8A9AC0), 0.0)); g.fill(rf)
        g.clip = clip
        // the verge along the gable, catching the moon
        T(0.0, twall - 0.05, -0.5).let { a -> T(0.0, ry, rd).let { b -> line(far(night(0x8A9AB8, 1.3), zf), 2.0, a.x, a.y, b.x, b.y) } }
        T(-0.5, ry, rd).let { a -> T(tw + 0.5, ry, rd).let { b -> line(far(night(0x8A9AB8, 1.3), zf), 2.0, a.x, a.y, b.x, b.y) } }
        // the bell gable on the ridge above the door: a stone frame, the bell in its arch
        run {
            val bz = tz(tdoor, rd); val s = f / bz
            val bg = shape(T(tdoor - 0.9, ry, rd), T(tdoor - 0.9, ry + 2.0, rd), T(tdoor, ry + 2.8, rd), T(tdoor + 0.9, ry + 2.0, rd), T(tdoor + 0.9, ry, rd))
            g.color = far(night(0x8A867A, 1.05), bz); g.fill(bg)
            val o = T(tdoor, ry + 1.55, rd)
            g.color = far(Color(0x0A0C12), bz); g.fill(java.awt.geom.RoundRectangle2D.Double(o.x - 0.42 * s, o.y - 0.3 * s, 0.84 * s, 1.3 * s, 0.84 * s, 0.84 * s))
            val bell = Path2D.Double(); val bcx = o.x; val bcy = o.y + 0.1 * s
            bell.moveTo(bcx - 0.12 * s, bcy - 0.3 * s); bell.quadTo(bcx - 0.14 * s, bcy, bcx - 0.3 * s, bcy + 0.18 * s); bell.lineTo(bcx + 0.3 * s, bcy + 0.18 * s)
            bell.quadTo(bcx + 0.14 * s, bcy, bcx + 0.12 * s, bcy - 0.3 * s); bell.closePath()
            g.color = far(night(0x9A8050, 1.2), bz); g.fill(bell)
            line(alpha(far(night(0xD0D8E8, 1.2), bz), 0.5), 1.2, bcx - 0.12 * s, bcy - 0.28 * s, bcx - 0.26 * s, bcy + 0.15 * s)
        }
        // the front: dressed stone in courses, the joints set off, the torchlight rising from below
        val front = shape(T(0.0, 0.0), T(tw, 0.0), T(tw, twall), T(0.0, twall))
        g.color = far(night(0x7E7A6E, 0.9), zf); g.fill(front)
        texture(front, zf, Color(0x22242C), night(0xB0AC9E, 1.2), 700, 0.05)
        g.clip(front)
        var y = 0.0; c = 0
        while (y < twall) {
            val hgt = 0.42 + 0.1 * rnd(c, 621)
            T(0.0, y).let { a -> T(tw, y).let { b -> line(far(Color(0x2A2A30), zf), 1.0, a.x, a.y, b.x, b.y) } }
            var a = rnd(c, 622) * 0.8
            while (a < tw) { val p0 = T(a, y); val p1 = T(a, minOf(twall, y + hgt)); line(far(Color(0x2A2A30), zf), 1.0, p0.x, p0.y, p1.x, p1.y); a += 0.7 + 0.5 * rnd((a * 10).toInt(), c) }
            y += hgt; c++
        }
        // the front lies in the shade of the moon (it comes from the left, behind the west side): darker towards the east
        g.paint = GradientPaint(T(0.0, 0.0).x.toFloat(), 0f, alpha(Color(0x05060A), 0.1), T(tw, 0.0).x.toFloat(), 0f, alpha(Color(0x05060A), 0.45)); g.fill(front)
        // the warm light of the door and the torches on the lower stones
        val dl = T(tdoor, 0.0); val s0 = f / tz(tdoor)
        g.paint = java.awt.RadialGradientPaint(Point2D.Double(dl.x, dl.y), (4.5 * s0).toFloat(), floatArrayOf(0f, 0.5f, 1f),
            arrayOf(alpha(Color(0xE08A3A), 0.55), alpha(Color(0xE08A3A), 0.2), alpha(Color(0xE08A3A), 0.0)), java.awt.MultipleGradientPaint.CycleMethod.NO_CYCLE)
        g.fill(front)
        g.clip = clip
        // the corner quoins and a plinth course
        for (a0 in listOf(0.0, tw)) { var qy = 0.0; var k = 0
            while (qy < twall) { val w = if (k % 2 == 0) 0.5 else 0.32
                val aa = if (a0 == 0.0) 0.0 else tw - w
                fillW(far(night(0x9A968A, if (a0 == 0.0) 1.15 else 0.9), zf), T(aa, qy), T(aa + w, qy), T(aa + w, qy + 0.4), T(aa, qy + 0.4))
                if (a0 == 0.0) fillW(far(night(0x9A968A, 1.25), zf), T(0.0, qy, 0.0), T(0.0, qy, w), T(0.0, qy + 0.4, w), T(0.0, qy + 0.4, 0.0))
                qy += 0.42; k++ } }
        fillW(far(night(0x6A665C), zf), T(0.0, 0.0), T(tw, 0.0), T(tw, 0.5), T(0.0, 0.5))
        fillW(far(night(0x7A766A, 1.1), zf), T(0.0, 0.0, 0.0), T(0.0, 0.0, td), T(0.0, 0.5, td), T(0.0, 0.5, 0.0))
        // tall arched windows (map: W at 26 and 30), the candles inside faintly warm
        for (wa in listOf(1.5, 9.0)) {
            val z = tz(wa); val s = f / z
            fun arch(a0: Double, a1: Double, y0: Double, y1: Double): Path2D.Double {
                val p = Path2D.Double(); val r = (a1 - a0) / 2; val m = (a0 + a1) / 2
                T(a0, y0).let { p.moveTo(it.x, it.y) }; T(a0, y1 - r).let { p.lineTo(it.x, it.y) }
                for (j in 1..12) { val t = Math.PI * j / 12; T(m - cos(t) * r, y1 - r + sin(t) * r).let { p.lineTo(it.x, it.y) } }
                T(a1, y0).let { p.lineTo(it.x, it.y) }; p.closePath(); return p
            }
            g.color = far(night(0x6A665C, 1.2), z); g.fill(arch(wa - 0.72, wa + 0.72, 1.7, 4.75))
            val a = arch(wa - 0.55, wa + 0.55, 1.8, 4.6)
            g.color = Color(0xB06A28); g.fill(a)
            val b = a.bounds2D
            g.paint = GradientPaint(0f, b.y.toFloat(), alpha(Color(0xFFC060), 0.6), 0f, (b.y + b.height).toFloat(), alpha(Color(0xFFC060), 0.1)); g.fill(a)
            T(wa, 1.8).let { p -> T(wa, 4.6).let { q -> line(Color(0x2A1A10), 1.5, p.x, p.y, q.x, q.y) } }
            T(wa - 0.55, 3.3).let { p -> T(wa + 0.55, 3.3).let { q -> line(Color(0x2A1A10), 1.2, p.x, p.y, q.x, q.y) } }
            glow(b.centerX, b.centerY, 1.4 * s, warmDeep, 0.25)
        }
        // the open door: warm light inside, an arch of voussoirs, the altar's candles far inside
        run {
            val z = tz(tdoor); val s = f / z
            fun arch(a0: Double, a1: Double, y1: Double): Path2D.Double {
                val p = Path2D.Double(); val r = (a1 - a0) / 2; val m = (a0 + a1) / 2
                T(a0, 0.0).let { p.moveTo(it.x, it.y) }; T(a0, y1 - r).let { p.lineTo(it.x, it.y) }
                for (j in 1..14) { val t = Math.PI * j / 14; T(m - cos(t) * r, y1 - r + sin(t) * r).let { p.lineTo(it.x, it.y) } }
                T(a1, 0.0).let { p.lineTo(it.x, it.y) }; p.closePath(); return p
            }
            g.color = far(night(0x9A968A, 1.15), z); g.fill(arch(tdoor - 1.2, tdoor + 1.2, 3.35))
            val door = arch(tdoor - 0.9, tdoor + 0.9, 3.0); val b = door.bounds2D
            g.paint = GradientPaint(0f, b.y.toFloat(), Color(0x8A4A1C), 0f, (b.y + b.height).toFloat(), Color(0xFFB050)); g.fill(door)
            // the reveal: the door is set into a thick wall, its west jamb seen
            fillW(Color(0x5A3418), T(tdoor - 0.9, 0.0), T(tdoor - 0.9, 0.0, 0.6), T(tdoor - 0.9, 2.1, 0.6), T(tdoor - 0.9, 2.1))
            for (k in -2..2) glow(b.centerX + k * 0.18 * s, b.y + b.height * 0.55, 0.12 * s, Color(0xFFF0C0), 0.9)
            glow(b.centerX, b.y + b.height * 0.6, 1.2 * s, Color(0xFFD080), 0.35)
        }
        // the porch: two columns and a gable over the door, the sun disc on it; two broad steps, warm from the torches
        val pd = -1.6; val pw = 1.7; val ph = 3.9
        val pz = tz(tdoor, pd); val ps = f / pz
        for (k in 0 until 2) {
            val d = pd - 0.9 + k * 0.45; val yb = k * 0.2; val ext = 1.0 - k * 0.3
            fillW(far(mix(night(0x7A766A), Color(0xA06A38), 0.45), pz), T(tdoor - pw - ext, yb, d), T(tdoor + pw + ext, yb, d), T(tdoor + pw + ext, yb + 0.2, d), T(tdoor - pw - ext, yb + 0.2, d))
            fillW(far(mix(night(0x8A867A, 1.1), Color(0xC08848), 0.5), pz), T(tdoor - pw - ext, yb + 0.2, d), T(tdoor + pw + ext, yb + 0.2, d), T(tdoor + pw + ext, yb + 0.2, d + 0.45), T(tdoor - pw - ext, yb + 0.2, d + 0.45))
            // the step's west end, in the moon
            fillW(far(night(0x8A867A, 1.2), pz), T(tdoor - pw - ext, yb, d), T(tdoor - pw - ext, yb, d + 0.45), T(tdoor - pw - ext, yb + 0.2, d + 0.45), T(tdoor - pw - ext, yb + 0.2, d))
        }
        // the porch floor from the steps to the door, and its roof back to the wall
        fillW(far(mix(night(0x7A766A), Color(0xB07A40), 0.5), pz), T(tdoor - pw - 0.4, 0.4, pd), T(tdoor + pw + 0.4, 0.4, pd), T(tdoor + pw + 0.4, 0.4, 0.0), T(tdoor - pw - 0.4, 0.4, 0.0))
        fillW(far(night(0x4A4A52), pz), T(tdoor - pw - 0.4, ph + 0.45, pd), T(tdoor - pw - 0.4, ph + 0.45, 0.0), T(tdoor, ph + 1.6, 0.0), T(tdoor, ph + 1.6, pd))
        for (pa in listOf(tdoor - pw, tdoor + pw)) {
            fillW(far(night(0x9A968A, 1.0), pz), T(pa - 0.26, 0.4, pd), T(pa + 0.26, 0.4, pd), T(pa + 0.26, ph, pd), T(pa - 0.26, ph, pd))
            fillW(far(night(0xA8A498, 1.15), pz), T(pa - 0.26, 0.4, pd), T(pa - 0.26, 0.4, pd + 0.5), T(pa - 0.26, ph, pd + 0.5), T(pa - 0.26, ph, pd))
            T(pa + 0.23, 0.4, pd).let { a -> T(pa + 0.15, ph * 0.6, pd).let { b -> line(alpha(Color(0xFFB060), 0.55), maxOf(1.0, 0.05 * ps), a.x, a.y, b.x, b.y) } }
            fillW(far(night(0x8A867A, 1.1), pz), T(pa - 0.32, ph, pd), T(pa + 0.32, ph, pd), T(pa + 0.32, ph + 0.18, pd), T(pa - 0.32, ph + 0.18, pd))
        }
        fillW(far(night(0x8A867A, 1.05), pz), T(tdoor - pw - 0.4, ph + 0.18, pd), T(tdoor + pw + 0.4, ph + 0.18, pd), T(tdoor + pw + 0.4, ph + 0.45, pd), T(tdoor - pw - 0.4, ph + 0.45, pd))
        fillW(far(night(0x9A968A, 1.05), pz), T(tdoor - pw - 0.5, ph + 0.45, pd), T(tdoor, ph + 1.6, pd), T(tdoor + pw + 0.5, ph + 0.45, pd))
        fillW(alpha(far(night(0x4A5A7A), pz), 0.9), T(tdoor - pw - 0.65, ph + 0.4, pd), T(tdoor, ph + 1.65, pd), T(tdoor, ph + 1.85, pd), T(tdoor - pw - 0.65, ph + 0.6, pd))
        fillW(alpha(far(night(0x4A5A7A, 0.8), pz), 0.9), T(tdoor + pw + 0.65, ph + 0.4, pd), T(tdoor, ph + 1.65, pd), T(tdoor, ph + 1.85, pd), T(tdoor + pw + 0.65, ph + 0.6, pd))
        val sun = T(tdoor, ph + 0.95, pd); val sr = 0.28 * ps
        for (k in 0 until 12) { val a = Math.PI * 2 * k / 12
            line(far(night(0xC8A050, 1.2), pz), 1.6, sun.x + cos(a) * sr * 0.8, sun.y + sin(a) * sr * 0.8, sun.x + cos(a) * sr * 1.4, sun.y + sin(a) * sr * 1.4) }
        g.color = far(night(0xD0A850, 1.3), pz); g.fill(Ellipse2D.Double(sun.x - sr * 0.75, sun.y - sr * 0.75, sr * 1.5, sr * 1.5))
    }

    /** Cloaked figures before the temple steps, torches high; one without a torch in the middle. Long shadows towards us. */
    fun torchBearers() {
        val fires = ArrayList<Triple<Double, Double, Double>>()
        val torches = IntroLife.bearers.filter { it.torch }
        for ((i, b) in IntroLife.bearers.withIndex()) {
            val x = b.x.toDouble(); val z = b.z.toDouble()
            // the shadow, thrown away from the door's light and the torches round it: towards us
            val p = Path2D.Double()
            p.moveTo(sx(x - 0.2, z), sy(0.0, z)); p.lineTo(sx(x + 0.2, z), sy(0.0, z))
            val zz = z - 5.0; val dx = (x - IntroLife.doorX) * 0.7
            p.lineTo(sx(x + dx + 0.4, zz), sy(0.0, zz)); p.lineTo(sx(x + dx - 0.4, zz), sy(0.0, zz)); p.closePath()
            g.paint = GradientPaint(0f, sy(0.0, z).toFloat(), alpha(Color(0x060508), 0.5), 0f, sy(0.0, zz).toFloat(), alpha(Color(0x060508), 0.0)); g.fill(p)
            val s = f / z
            val t = cloaked(x, z, b.h.toDouble(), far(Color(0x0C0908), z), b.torch, lean = b.lean.toDouble())
            // the warm rim of the torches on the cloaks: on the side facing the nearest torch
            val near = torches.filter { it != b }.minByOrNull { Math.hypot((it.x - b.x).toDouble(), (it.z - b.z).toDouble()) }
            val side = if (b.torch) 1.0 else if (near != null && near.x < b.x) -1.0 else 1.0
            line(alpha(warm, 0.5), maxOf(1.0, 0.03 * s), sx(x + 0.3 * side, z), sy(0.1, z), sx(x + 0.22 * side, z), sy(1.35, z))
            line(alpha(warm, 0.35), maxOf(1.0, 0.025 * s), sx(x + 0.2 * side, z), sy(1.4, z), sx(x + 0.08 * side, z), sy(1.62, z))
            if (t != null) fires += Triple(t.first, t.second, s)
        }
        // the flames burn in the app over the moved layer (70.3)
        if (part == Part.ALL) for ((k, fr) in fires.withIndex()) flame(fr.first, fr.second, fr.third * 1.5, k)
    }

    /** The near verge: tall grass and a few stones where the north road meets the lower street, in the dark. */
    fun verge() {
        for (i in 0 until 700) {
            val wx = if (rnd(i, 851) > 0.5) -1.6 - 6 * rnd(i, 852) else 1.6 + 1.2 * rnd(i, 852)
            val wn = 0.7 + 2.2 * rnd(i, 853)
            val z = czw(wx, wn); if (z < 0.9) continue
            val p = P(wx, 0.0, wn); if (p.x < -30 || p.x > W + 30) continue
            val l = f * (0.12 + 0.16 * rnd(i, 854)) / z
            line(alpha(night(if (rnd(i, 855) > 0.6) 0x7A8658 else 0x2A3420, 0.9), 0.85), maxOf(1.0, f * 0.018 / z), p.x, p.y, p.x + (rnd(i, 856) - 0.4) * l * 0.7, p.y - l)
        }
    }

    fun well(x: Double, z: Double) {
        val s = f / z; val r = 0.85
        val px = sx(x, z); val py = sy(0.0, z)
        softShadow(px + 0.6 * s, py, 1.6 * s)
        // posts behind the ring
        val top = 2.35
        for (dx in listOf(-r + 0.1, r - 0.1)) {
            quad(night(dTimber, 1.2), x + dx - 0.08, 0.6, z + 0.1, x + dx + 0.08, 0.6, z + 0.1, x + dx + 0.08, top, z + 0.1, x + dx - 0.08, top, z + 0.1)
            line(alpha(Color(0xA0A8C0), 0.4), 1.2, sx(x + dx - 0.08, z + 0.1), sy(0.6, z + 0.1), sx(x + dx - 0.08, z + 0.1), sy(top, z + 0.1))
        }
        // the winch, its rope down into the well
        line(Color(0x2A1E14), 0.11 * s, sx(x - r + 0.1, z + 0.1), sy(1.55, z + 0.1), sx(x + r - 0.1, z + 0.1), sy(1.55, z + 0.1))
        for (k in 0 until 6) { val wx = x - 0.25 + k * 0.1; line(Color(0x5A4A38), 1.5, sx(wx, z + 0.1), sy(1.5, z + 0.1), sx(wx + 0.05, z + 0.1), sy(1.6, z + 0.1)) }
        line(Color(0x4A3E30), 0.018 * s, sx(x + 0.05, z + 0.1), sy(1.55, z + 0.1), sx(x + 0.05, z + 0.1), sy(0.85, z + 0.1))
        line(Color(0x2A1E14), 0.05 * s, sx(x + r - 0.1, z + 0.1), sy(1.55, z + 0.1), sx(x + r + 0.15, z + 0.1), sy(1.3, z + 0.1))
        // the ring: its top, the dark water, then the stone wall in courses
        val ringTop = Ellipse2D.Double(px - r * s, py - 0.8 * s - 0.17 * s, 2 * r * s, 0.34 * s)
        val ring = Path2D.Double()
        ring.moveTo(px - r * s, py - 0.8 * s); ring.lineTo(px - r * s, py)
        ring.curveTo(px - r * s, py + 0.22 * s, px + r * s, py + 0.22 * s, px + r * s, py)
        ring.lineTo(px + r * s, py - 0.8 * s); ring.curveTo(px + r * s, py - 0.58 * s, px - r * s, py - 0.58 * s, px - r * s, py - 0.8 * s); ring.closePath()
        g.color = night(0x7A766A, 0.9); g.fill(ringTop)
        g.color = Color(0x06080E); g.fill(Ellipse2D.Double(px - r * s * 0.78, py - 0.8 * s - 0.12 * s, 2 * r * s * 0.78, 0.24 * s))
        g.color = night(0x6E6A60, 0.9); g.fill(ring)
        val clip = g.clip; g.clip(ring)
        for (row in 0 until 4) {
            val y0 = 0.8 * row / 4; val y1 = 0.8 * (row + 1) / 4
            var a = -Math.PI / 2 + rnd(row, 631) * 0.3
            while (a < Math.PI / 2) {
                val a1 = a + 0.28 + 0.18 * rnd((a * 100).toInt(), row)
                val xa = px + sin(a) * r * s; val xb = px + sin(minOf(a1, Math.PI / 2)) * r * s
                val v = rnd((a * 100).toInt(), row + 9)
                val ya = py - y1 * s + cos(a) * 0.2 * s; val yb = py - y0 * s + cos(a) * 0.2 * s
                g.color = night(if (v > 0.5) 0x8A867A else 0x726E64, 0.85 + 0.3 * v)
                g.fill(java.awt.geom.RoundRectangle2D.Double(xa + 1.5, ya + 1.5, xb - xa - 3, yb - ya - 3, 8.0, 8.0))
                a = a1
            }
        }
        g.paint = GradientPaint((px - r * s).toFloat(), 0f, alpha(Color(0xC8CCD8), 0.25), (px + r * s * 0.3).toFloat(), 0f, alpha(Color(0xC8CCD8), 0.0)); g.fill(ring)
        g.paint = GradientPaint((px - r * s * 0.2).toFloat(), 0f, alpha(Color(0x04060A), 0.0), (px + r * s).toFloat(), 0f, alpha(Color(0x04060A), 0.5)); g.fill(ring)
        g.clip = clip
        // the bucket on the rim
        val bxp = sx(x - 0.45, z - 0.1); val byp = sy(0.82, z - 0.1)
        poly(night(0x5A4430, 1.1), bxp - 0.13 * s, byp, bxp + 0.13 * s, byp, bxp + 0.15 * s, byp - 0.25 * s, bxp - 0.15 * s, byp - 0.25 * s)
        line(Color(0x1A1818), 0.02 * s, bxp - 0.14 * s, byp - 0.08 * s, bxp + 0.14 * s, byp - 0.08 * s)
        g.color = Color(0x1A1818); g.stroke = BasicStroke((0.015 * s).toFloat()); g.draw(java.awt.geom.Arc2D.Double(bxp - 0.15 * s, byp - 0.42 * s, 0.3 * s, 0.34 * s, 0.0, 180.0, java.awt.geom.Arc2D.OPEN))
        // the roof: two slopes of shingles over the posts, the moon on the left one
        val rl = Path2D.Double(); val rp = { xx: Double, yy: Double -> Point2D.Double(sx(xx, z + 0.1), sy(yy, z + 0.1)) }
        val e1 = rp(x - r - 0.45, top - 0.2); val apex = rp(x, top + 0.75); val e2 = rp(x + r + 0.45, top - 0.2)
        rl.moveTo(e1.x, e1.y); rl.lineTo(apex.x, apex.y); rl.lineTo(apex.x, apex.y + 0.22 * s); rl.lineTo(e1.x, e1.y + 0.22 * s); rl.closePath()
        g.color = night(0x6A645C, 1.3); g.fill(rl)
        val rr = Path2D.Double(); rr.moveTo(e2.x, e2.y); rr.lineTo(apex.x, apex.y); rr.lineTo(apex.x, apex.y + 0.22 * s); rr.lineTo(e2.x, e2.y + 0.22 * s); rr.closePath()
        g.color = night(0x3E3A36); g.fill(rr)
        for (k in 1..5) { val t = k / 6.0
            line(alpha(Color(0x141210), 0.8), 1.0, e1.x + (apex.x - e1.x) * t, e1.y + (apex.y - e1.y) * t, e1.x + (apex.x - e1.x) * t, e1.y + (apex.y - e1.y) * t + 0.22 * s)
            line(alpha(Color(0x141210), 0.8), 1.0, e2.x + (apex.x - e2.x) * t, e2.y + (apex.y - e2.y) * t, e2.x + (apex.x - e2.x) * t, e2.y + (apex.y - e2.y) * t + 0.22 * s) }
        line(alpha(Color(0xC8D0E0), 0.5), 1.5, e1.x, e1.y, apex.x, apex.y)
    }

    /** A market stall closed for the night: posts, the counter, the canvas let down in folds, a roof of boards, crates. */
    fun stall(x: Double, z: Double) {
        val w = 2.8; val d = 1.4; val hgt = 2.2
        softShadow(sx(x, z) + 0.8 * f / z, sy(0.0, z), 2.2 * f / z)
        quad(night(0x2E261E), x - w / 2, 0.0, z + d, x + w / 2, 0.0, z + d, x + w / 2, hgt, z + d, x - w / 2, hgt, z + d)
        quad(night(0x5A4430), x - w / 2, 0.0, z, x + w / 2, 0.0, z, x + w / 2, 0.9, z, x - w / 2, 0.9, z)
        for (k in 0 until 3) line(Color(0x1A120C), 1.2, sx(x - w / 2, z), sy(0.3 * k + 0.2, z), sx(x + w / 2, z), sy(0.3 * k + 0.2, z))
        for (k in 0 until 16) {
            val a = x - w / 2 + w * k / 16; val b = a + w / 16
            val c = if (k % 2 == 0) night(0x8A7A5C, 0.48) else night(0x6A5C46, 0.46)
            val sag = 0.05 * sin(k * 1.3)
            quad(c, a, 0.95, z - 0.02, b, 0.95, z - 0.02, b, hgt - 0.12 + sag, z - 0.02, a, hgt - 0.12 + sag, z - 0.02)
        }
        g.paint = GradientPaint(sx(x - w / 2, z).toFloat(), 0f, alpha(Color(0xC8CCD8), 0.1), sx(x + w / 2, z).toFloat(), 0f, alpha(Color(0x05060A), 0.4))
        g.fill(quadShape(x - w / 2, 0.95, z - 0.02, x + w / 2, 0.95, z - 0.02, x + w / 2, hgt - 0.1, z - 0.02, x - w / 2, hgt - 0.1, z - 0.02))
        // the torches far behind warm the right edge of the canvas a little
        line(alpha(warm, 0.3), 1.5, sx(x + w / 2, z), sy(1.0, z), sx(x + w / 2, z), sy(hgt - 0.1, z))
        quad(night(0x3A2E24, 1.2), x - w / 2 - 0.25, hgt, z - 0.35, x + w / 2 + 0.25, hgt, z - 0.35, x + w / 2 + 0.25, hgt + 0.5, z + d, x - w / 2 - 0.25, hgt + 0.5, z + d)
        line(alpha(Color(0xC8D0E0), 0.4), 1.4, sx(x - w / 2 - 0.25, z - 0.35), sy(hgt, z - 0.35), sx(x + w / 2 + 0.25, z - 0.35), sy(hgt, z - 0.35))
        for (px in listOf(x - w / 2, x + w / 2)) quad(night(dTimber, 1.2), px - 0.07, 0.0, z - 0.03, px + 0.07, 0.0, z - 0.03, px + 0.07, hgt, z - 0.03, px - 0.07, hgt, z - 0.03)
        // stacked crates beside it
        for ((cx, cy, cw) in listOf(Triple(x - w / 2 - 0.85, 0.0, 0.6), Triple(x - w / 2 - 0.75, 0.5, 0.45))) {
            quad(night(0x5A4430, 1.05), cx, cy, z - 0.3, cx + cw, cy, z - 0.3, cx + cw, cy + 0.5, z - 0.3, cx, cy + 0.5, z - 0.3)
            line(Color(0x1A120C), 1.2, sx(cx, z - 0.3), sy(cy + 0.25, z - 0.3), sx(cx + cw, z - 0.3), sy(cy + 0.25, z - 0.3))
            line(alpha(Color(0xC8D0E0), 0.35), 1.2, sx(cx, z - 0.3), sy(cy + 0.5, z - 0.3), sx(cx + cw, z - 0.3), sy(cy + 0.5, z - 0.3))
        }
    }

    /** A lantern post at the corner of the square, its lantern dark: the square sleeps. */
    fun lampPost(x: Double, z: Double) {
        val s = f / z
        softShadow(sx(x, z) + 0.5 * s, sy(0.0, z), 0.7 * s)
        line(Color(0x14120F), 0.12 * s, sx(x, z), sy(0.0, z), sx(x, z), sy(2.9, z))
        line(alpha(Color(0x8A90A0), 0.5), 0.025 * s, sx(x - 0.05, z), sy(0.0, z), sx(x - 0.05, z), sy(2.9, z))
        line(Color(0x14120F), 0.05 * s, sx(x, z), sy(2.75, z), sx(x + 0.35, z), sy(2.9, z))
        val lx = sx(x + 0.35, z); val ly = sy(2.85, z)
        poly(Color(0x14110E), lx - 0.15 * s, ly - 0.02 * s, lx + 0.15 * s, ly - 0.02 * s, lx + 0.08 * s, ly - 0.14 * s, lx - 0.08 * s, ly - 0.14 * s)
        g.color = Color(0x1C2230); g.fill(java.awt.geom.Rectangle2D.Double(lx - 0.11 * s, ly, 0.22 * s, 0.3 * s))
        g.color = alpha(Color(0x8A96B4), 0.4); g.fill(java.awt.geom.Rectangle2D.Double(lx - 0.11 * s, ly, 0.05 * s, 0.3 * s))
        g.color = Color(0x14110E); g.fill(java.awt.geom.Rectangle2D.Double(lx - 0.13 * s, ly + 0.28 * s, 0.26 * s, 0.05 * s))
        for (u in listOf(-0.11, 0.0, 0.11)) g.fill(java.awt.geom.Rectangle2D.Double(lx + u * s - 0.01 * s, ly, 0.02 * s, 0.3 * s))
    }


    /** A puddle in a rut of the lower street: the torches mirrored straight below themselves, the moon's sheen at its rim. */
    fun puddle() {
        val x = IntroLife.PUDDLE_X.toDouble(); val z = IntroLife.PUDDLE_Z.toDouble(); val w = IntroLife.PUDDLE_W.toDouble()
        val p = Path2D.Double()
        for ((j, pt) in IntroLife.puddle().withIndex()) if (j == 0) p.moveTo(pt.first.toDouble(), pt.second.toDouble()) else p.lineTo(pt.first.toDouble(), pt.second.toDouble())
        p.closePath()
        g.color = Color(0x0A0E18); g.fill(p)
        val clip = g.clip; g.clip(p)
        g.paint = GradientPaint(0f, sy(0.0, z + w * 0.4).toFloat(), Color(0x141C30), 0f, sy(0.0, z - w * 0.4).toFloat(), Color(0x080C16)); g.fill(p)
        if (part == Part.ALL) for (b in IntroLife.bearers.filter { it.torch }) {
            val mx = sx(b.x + 0.45, b.z.toDouble())
            val y0 = sy(0.0, z + w * 0.6); val y1 = sy(0.0, z - w * 0.6)
            g.paint = GradientPaint(0f, y0.toFloat(), alpha(warm, 0.7), 0f, y1.toFloat(), alpha(warmDeep, 0.0))
            g.fill(java.awt.geom.Rectangle2D.Double(mx - 4.0, y0, 8.0, y1 - y0))
            glow(mx, y0 + 8, 22.0, warmDeep, 0.3)
            for (k in 1 until 6) { val yy = y0 + (y1 - y0) * k / 6.0; line(alpha(Color(0x0A0E18), 0.6), 1.2, mx - 6, yy, mx + 6, yy + 1) }
        }
        g.clip = clip
        line(alpha(Color(0x8A96B4), 0.5), 1.0, sx(x - w, z), sy(0.0, z), sx(x, z + w * 0.4), sy(0.0, z + w * 0.4))
    }

    /** Life: smoke from the chimney of the house beyond the square, two bats before the moon. */
    fun life2() {
        val x0 = IntroLife.smokeX.toDouble(); val y0 = IntroLife.smokeY.toDouble()
        for (k in 0 until 50) { val t = k / 50.0
            glow(x0 + t * t * 160 + sin(t * 9) * 10 * t, y0 - t * 220 - 6, 8 + t * 50, Color(0x8A94AC), 0.15 * (1 - t)) }
        for ((bx, by, sc) in listOf(Triple(moonX + 70, moonY - 40, 1.0), Triple(moonX + 260, moonY + 30, 0.6))) {
            val w = 15.0 * sc
            val p = Path2D.Double()
            p.moveTo(bx - w, by - w * 0.3); p.quadTo(bx - w * 0.5, by + w * 0.1, bx - w * 0.15, by - w * 0.05)
            p.lineTo(bx, by + w * 0.12); p.lineTo(bx + w * 0.15, by - w * 0.05)
            p.quadTo(bx + w * 0.5, by + w * 0.1, bx + w, by - w * 0.3); p.quadTo(bx + w * 0.4, by + w * 0.25, bx, by + w * 0.3)
            p.quadTo(bx - w * 0.4, by + w * 0.25, bx - w, by - w * 0.3); p.closePath()
            g.color = Color(0x06080E); g.fill(p)
        }
    }
}

/**
 * `[69.intro.4]` The inn close up: its half-timbered front as the village houses have it in the diagonal world (field-stone
 * footing, dark beams, pale daub, shuttered window with a sill, plank door in a frame, eave board, shingles), the warm window
 * with its lead panes, the door opening inwards and in it Rowena as a silhouette against the warm room (sturdy, sleeves rolled
 * up, light apron, a jug in her hand; `LISTE-FIGUREN.md`), her shadow in the wedge of light on the cobbles; the inn's sign on
 * its iron bracket. Beyond the corner the lane goes on under the moon.
 */
internal class InnPainter : IntroPainter() {
    override val hy = 600.0; override val eye = 1.65; override val camX = -0.3; override val pan = 0.0
    override val moonX = 985.0; override val moonY = 108.0

    val z0 = 6.0
    val xL = -7.5; val xR = 1.6
    val win = -2.0; val ww = 0.5; val wy0 = 1.3; val wy1 = 2.45
    val door = 0.0; val dw = 0.55; val dh = 2.15
    val plinth = 0.55; val sill = 0.72; val plate = 3.62; val wall = 3.82

    fun X(x: Double) = sx(x, z0)
    fun Y(y: Double) = sy(y, z0)
    fun rect(x0: Double, y0: Double, x1: Double, y1: Double) = java.awt.geom.Rectangle2D.Double(X(x0), Y(y1), X(x1) - X(x0), Y(y0) - Y(y1))
    fun fill(c: Color, x0: Double, y0: Double, x1: Double, y1: Double) { g.color = c; g.fill(rect(x0, y0, x1, y1)) }

    /** Warm light on the front from the window and the door (0..1). */
    fun warmAt(x: Double, y: Double): Double {
        val a = exp(-Math.hypot((x - win) / 1.3, (y - 1.9) / 1.1)) * 0.9
        val b = exp(-Math.hypot((x - door) / 1.1, (y - 1.0) / 1.4)) * 0.6
        return (a + b).coerceAtMost(1.0)
    }

    override fun scene() {
        sky()
        backdrop(far(night(0x3A3630), 80.0))
        forestBand()
        cobbles(-14.0, 18.0, 2.6, 60.0) { x, z -> doorLight(x, z) + windowLight(x, z) }
        beyond()
        roof()
        facade()
        window()
        doorway()
        rowena()
        spill()
        bench(win)
        barrel(1.05)
        sign(1.15)
        life2()
        nearDark(0.4)
        vignette()
    }

    /** The door's light on the ground: a wedge widening towards us, Rowena's shadow in it. */
    fun doorLight(x: Double, z: Double): Double {
        if (z >= z0) return 0.0
        val d = z0 - z
        val spread = dw + d * 0.35
        val u = (x - door - d * 0.05) / spread
        if (abs(u) > 1) return 0.0
        val edge = ((1 - abs(u)) / 0.35).coerceAtMost(1.0)
        val shadow = if (abs(x - (door + 0.1 + d * 0.06)) < 0.2 + d * 0.07) 0.3 else 1.0
        return 0.7 * exp(-d / 1.8) * edge * shadow
    }
    fun windowLight(x: Double, z: Double): Double {
        if (z >= z0) return 0.0
        return 0.3 * exp(-Math.hypot((x - win) / 1.2, (z0 - 0.9 - z) / 0.9))
    }

    /** Beyond the corner: the lane going on, a neighbour's house with one lit window, a fir, the night. */
    fun beyond() {
        val n = House(9.0, 17.0, 9.0, 7.0, 3.8, 3.4, listOf(0))
        houseWin[n] = listOf(6.0, 11.0) to 8.4
        firShape(sx(4.6, 24.0), sy(0.0, 24.0), f * 11.0 / 24, f * 4.6 / 24, far(fir, 24.0), far(firLit, 24.0), 0.6)
        house(n, false)
    }

    /** The roof seen from below: the eave's underside with the rafter ends, then the shingles up to the ridge, moss low on them. */
    fun roof() {
        val ez = z0 - 0.6; val ey = wall - 0.08; val rz = z0 + 4.6; val ry = 7.1; val x0 = xL - 0.6; val x1 = xR + 0.45
        val slope = quadShape(x0, ey, ez, x1, ey, ez, x1, ry, rz, x0, ry, rz)
        g.color = roof; g.fill(slope)
        val clip = g.clip; g.clip(slope)
        // rows of shingles, each shingle its own shade, the moon on the left part
        val rows = 26
        for (k in 0 until rows) {
            val t0 = k / rows.toDouble(); val t1 = (k + 1) / rows.toDouble()
            val ya = ey + (ry - ey) * t0; val za = ez + (rz - ez) * t0; val yb = ey + (ry - ey) * t1; val zb = ez + (rz - ez) * t1
            var x = x0 + (if (k % 2 == 0) 0.0 else 0.13)
            var j = 0
            while (x < x1) {
                val w = 0.22 + 0.1 * rnd(k * 97 + j, 501)
                val v = rnd(k * 97 + j, 502)
                val lit = 1.0 + 0.35 * exp(-abs(x - xR) / 2.5) + 0.2 * (1 - t0)
                quad(night(if (v > 0.7) 0x5E5850 else if (v > 0.35) 0x4C463E else 0x3A3632, lit), x + 0.01, ya, za, x + w - 0.01, ya, za, x + w - 0.01, yb, zb, x + 0.01, yb, zb)
                // the lower edge of each shingle throws a thin shadow on the row below
                line(alpha(Color(0x0E0C0C), 0.6), 1.2, sx(x, za), sy(ya, za), sx(x + w, za), sy(ya, za))
                x += w; j++
            }
        }
        for (i in 0 until 160) {
            val t = rnd(i, 511).let { it * it } * 0.6; val x = x0 + (x1 - x0) * rnd(i, 512)
            val y = ey + (ry - ey) * t; val z = ez + (rz - ez) * t; val r = f * (0.05 + 0.12 * rnd(i, 513)) / z
            g.color = alpha(night(if (rnd(i, 514) > 0.5) 0x6A7A3A else 0x4A5A2A, 1.3), 0.5)
            g.fill(Ellipse2D.Double(sx(x, z) - r, sy(y, z) - r * 0.35, r * 2, r * 0.7))
        }
        g.clip = clip
        // the chimney of field stone rising out of the roof
        val cz = z0 + 2.6; val cy = ey + (ry - ey) * 2.6 / 4.6 - 0.3
        val chim = quadShape(-4.4, cy, cz, -3.6, cy, cz, -3.6, 9.5, cz, -4.4, 9.5, cz)
        g.color = stone; g.fill(chim); texture(chim, cz, Color(0x22242A), stoneLit, 900, 0.05)
        // the eave: its underside dark, the rafter ends, and the eave board along the edge
        quad(Color(0x120E0C), x0, ey, ez, x1, ey, ez, x1, wall, z0, x0, wall, z0)
        var rx = x0 + 0.2
        while (rx < x1) { quad(night(0x3A2A1E, 1.1), rx, ey + 0.02, ez + 0.05, rx + 0.12, ey + 0.02, ez + 0.05, rx + 0.12, wall, z0, rx, wall, z0); rx += 0.62 }
        quad(night(0x2E2218, 1.2), x0, ey - 0.2, ez, x1, ey - 0.2, ez, x1, ey + 0.02, ez, x0, ey + 0.02, ez)
        line(alpha(Color(0xA8B0C8), 0.35), 1.2, sx(x0, ez), sy(ey + 0.02, ez), sx(x1, ez), sy(ey + 0.02, ez))
        // the verge board up the gable at the corner, the moon behind catching its edge
        line(night(0x2E2218, 1.2), f * 0.2 / z0, sx(x1, ez), sy(ey - 0.1, ez), sx(x1, rz), sy(ry, rz))
        line(alpha(Color(0xC8D0E0), 0.4), 1.5, sx(x1 + 0.05, ez), sy(ey, ez), sx(x1 + 0.05, rz), sy(ry + 0.05, rz))
    }

    /** The front: field-stone footing, then the frame of dark beams with pale daub between, warm where the light falls. */
    fun facade() {
        // daub panels: one pale field, stained, then lit
        val wallShape = rect(xL, sill, xR, plate)
        g.color = night(0xA89C84, 0.72); g.fill(wallShape)
        texture(wallShape, z0, Color(0x2A2620), night(0xD8D0B8, 1.2), 900, 0.018, 0.7)
        texture(wallShape, z0, Color(0x1E1A16), night(0xC8C0A8, 1.1), 40, 0.08, 0.9)
        // cracks and a patch where the daub has fallen and the wattle shows
        g.clip(wallShape)
        for (i in 0 until 26) {
            var x = xL + (xR - xL) * rnd(i, 521); var y = sill + (plate - sill) * rnd(i, 522)
            for (k in 0 until 5) { val nx = x + (rnd(i * 5 + k, 523) - 0.5) * 0.25; val ny = y - 0.05 - rnd(i * 5 + k, 524) * 0.12
                line(alpha(Color(0x1A1612), 0.45), 1.0, X(x), Y(y), X(nx), Y(ny)); x = nx; y = ny }
        }
        fill(night(0x6A5A44), -4.05, 2.7, -3.55, 3.2)
        for (k in 0 until 5) line(night(0x3A2E20), 2.0, X(-4.05), Y(2.75 + k * 0.1), X(-3.55), Y(2.72 + k * 0.1))
        g.clip = null
        // the light on the daub: warm near the window and door, the moon cool and faint from the right
        val wp = Path2D.Double(); wp.append(wallShape, false)
        g.clip(wallShape)
        glowOn(win, 1.9, 2.6, warm, 0.5)
        glowOn(win, 1.9, 1.2, warm, 0.35)
        glowOn(door, 1.2, 2.0, warmDeep, 0.4)
        g.paint = GradientPaint(X(xR).toFloat(), 0f, alpha(Color(0x8A96B8), 0.18), X(xR - 4).toFloat(), 0f, alpha(Color(0x8A96B8), 0.0)); g.fill(wallShape)
        // the eave's shadow on the upper wall
        g.paint = GradientPaint(0f, Y(plate).toFloat(), alpha(Color(0x08080C), 0.6), 0f, Y(plate - 1.1).toFloat(), alpha(Color(0x08080C), 0.0)); g.fill(wallShape)
        g.clip = null
        // the frame: posts, rails, braces
        val posts = listOf(xL + 0.1, -5.6, -4.3, win - ww - 0.2, win + ww + 0.12, door - dw - 0.16, door + dw + 0.04, xR - 0.2)
        val rails = listOf(1.18 to listOf(xL to win - ww - 0.2, win + ww + 0.2 to door - dw - 0.16, door + dw + 0.16 to xR), 2.55 to listOf(xL to xR))
        fun beam(xa: Double, ya: Double, xb: Double, yb: Double, w: Double) {
            val c = night(0x3A2A1E, 1.0 + 0.6 * warmAt((xa + xb) / 2, (ya + yb) / 2))
            line(c, f * w / z0, X(xa), Y(ya), X(xb), Y(yb))
        }
        for ((y, spans) in rails) for ((a, b) in spans) beam(a, y, b, y, 0.15)
        // braces in the bays, leaning to the middle, as the village houses have them
        beam(-5.6, sill + 0.1, -4.3, 2.5, 0.15); beam(-4.3, 2.6, -5.6, plate - 0.05, 0.13)
        beam(xR - 0.2, sill + 0.1, door + dw + 0.2, 1.15, 0.14); beam(door + dw + 0.2, 2.6, xR - 0.2, plate - 0.05, 0.13)
        for (x in posts) {
            fill(night(0x2E2018, 1.0 + 0.6 * warmAt(x, 1.8)), x, sill, x + 0.18, plate)
            // the moon on the right edge of every post, its grain
            line(alpha(Color(0x8A90A8), 0.3), 1.0, X(x + 0.17), Y(sill), X(x + 0.17), Y(plate))
            for (q in 0 until 3) { val gx = x + 0.04 + 0.1 * rnd((x * 10).toInt() + q, 531)
                line(alpha(Color(0x120C08), 0.6), 1.0, X(gx), Y(sill + 0.2), X(gx), Y(plate - 0.2 - rnd(q, 532))) }
        }
        fill(night(0x2E2018, 1.1), xL, sill - 0.02, xR, sill + 0.16)
        fill(night(0x2E2018, 1.1), xL, plate, xR, wall)
        line(alpha(Color(0x8A90A8), 0.3), 1.2, X(xL), Y(wall), X(xR), Y(wall))
        // pegs where the braces and rails meet the posts
        for (x in posts) for (y in listOf(1.18, 2.55)) { g.color = Color(0x120C08); g.fill(Ellipse2D.Double(X(x + 0.09) - 2.5, Y(y) - 2.5, 5.0, 5.0)) }
        // the footing: field stones in two uneven courses, mortar between
        fill(night(0x3A3830), xL, 0.0, xR, plinth + 0.02)
        for (row in 0 until 2) {
            var x = xL + rnd(row, 541) * 0.2; var k = 0
            val ya = plinth * row / 2; val yb = plinth * (row + 1) / 2
            while (x < xR) {
                if (x > door - dw - 0.05 && x < door + dw) { x = door + dw; continue }
                val w = 0.3 + 0.35 * rnd(row * 101 + k, 542)
                val v = rnd(row * 101 + k, 543)
                val st = java.awt.geom.RoundRectangle2D.Double(X(x + 0.025), Y(yb - 0.02), X(minOf(x + w, xR) - 0.025) - X(x + 0.025), Y(ya + 0.02) - Y(yb - 0.02), 18.0, 18.0)
                g.color = mix(night(if (v > 0.5) 0x7A766A else 0x5E5A52, 0.7 + 0.3 * v), Color(0xA06A38), 0.5 * warmAt(x + w / 2, 0.4)); g.fill(st)
                texture(st, z0, Color(0x1E1E22), night(0xB0AC9E, 1.3), 200, 0.025)
                g.color = alpha(Color(0xC8CCD8), 0.1); g.fill(java.awt.geom.Rectangle2D.Double(st.x + 3, st.y + 2, st.width - 6, st.height * 0.25))
                x += w; k++
            }
        }
        g.paint = GradientPaint(0f, Y(plinth).toFloat(), alpha(Color(0x060608), 0.0), 0f, Y(0.0).toFloat(), alpha(Color(0x060608), 0.45)); g.fill(rect(xL, 0.0, xR, plinth))
    }
    fun glowOn(x: Double, y: Double, r: Double, c: Color, a: Double) = glow(X(x), Y(y), f * r / z0, c, a)

    /** The window: a deep frame, a sill board, open shutters of boards, lead panes in diamonds, the warm room behind. */
    fun window() {
        val x0 = win - ww; val x1 = win + ww
        // shutters opened flat against the wall, each of three boards with a Z-brace
        for ((a, b) in listOf(x0 - 0.62 to x0 - 0.14, x1 + 0.14 to x1 + 0.62)) {
            for (k in 0 until 3) { val ba = a + (b - a) * k / 3; val bb = a + (b - a) * (k + 1) / 3
                fill(night(if (k == 1) 0x4E3A28 else 0x46342A, 1.1 + 0.5 * warmAt(ba, 1.9)), ba + 0.006, wy0 - 0.05, bb - 0.006, wy1 + 0.05) }
            val br = night(0x2A1C12)
            line(br, f * 0.06 / z0, X(a), Y(wy0 + 0.15), X(b), Y(wy0 + 0.15)); line(br, f * 0.06 / z0, X(a), Y(wy1 - 0.15), X(b), Y(wy1 - 0.15))
            line(br, f * 0.05 / z0, X(a), Y(wy0 + 0.15), X(b), Y(wy1 - 0.15))
            // iron hinges
            for (hy in listOf(wy0 + 0.15, wy1 - 0.15)) line(Color(0x18181A), f * 0.025 / z0, X(if (a < x0) b - 0.25 else a), Y(hy), X(if (a < x0) b + 0.02 else a + 0.25), Y(hy))
        }
        // the frame and its reveal
        fill(night(0x2E2018, 1.4), x0 - 0.12, wy0 - 0.08, x1 + 0.12, wy1 + 0.12)
        fill(Color(0x2A1608), x0, wy0, x1, wy1)
        // the panes: lead diamonds, each glass a little different, brighter low in the middle where the fire is behind
        val clip = g.clip; g.clip(rect(x0 + 0.04, wy0 + 0.04, x1 - 0.04, wy1 - 0.04))
        val d = 0.13
        var i = 0
        var yy = wy0 - d
        while (yy < wy1 + d) {
            var xx = x0 - d + (if (((yy - wy0) / d).toInt() % 2 == 0) 0.0 else d / 2)
            while (xx < x1 + d) {
                val v = rnd(i, 551); i++
                val heat = exp(-Math.hypot((xx - win) / 0.45, (yy - (wy0 + 0.35)) / 0.5))
                val c = mix(mix(Color(0xD8882C), Color(0xFFC86A), v), Color(0xFFF0C0), heat * 0.7)
                val p = Path2D.Double(); p.moveTo(X(xx), Y(yy + d)); p.lineTo(X(xx + d / 2), Y(yy)); p.lineTo(X(xx), Y(yy - d)); p.lineTo(X(xx - d / 2), Y(yy)); p.closePath()
                g.color = c; g.fill(p)
                g.color = Color(0x3A2410); g.stroke = BasicStroke(maxOf(1f, (f * 0.012 / z0).toFloat())); g.draw(p)
                xx += d
            }
            yy += d
        }
        // shadows inside the room: a chair back and someone's hat on a peg, dark against the glow
        g.color = alpha(Color(0x3A1E0C), 0.55)
        g.fill(rect(win - 0.38, wy0 + 0.04, win - 0.3, wy0 + 0.55)); g.fill(rect(win - 0.38, wy0 + 0.5, win - 0.1, wy0 + 0.56))
        g.fill(Ellipse2D.Double(X(win + 0.18), Y(wy1 - 0.25), f * 0.22 / z0, f * 0.08 / z0))
        g.clip = clip
        // the mullion and transom of the frame, the sill board with a pot of herbs
        fill(night(0x2E2018, 1.5), win - 0.035, wy0, win + 0.035, wy1)
        fill(night(0x2E2018, 1.5), x0, (wy0 + wy1) / 2 + 0.12, x1, (wy0 + wy1) / 2 + 0.18)
        fill(night(0x5A4430, 1.8), x0 - 0.22, wy0 - 0.16, x1 + 0.22, wy0 - 0.06)
        line(alpha(warm, 0.6), 1.5, X(x0 - 0.22), Y(wy0 - 0.06), X(x1 + 0.22), Y(wy0 - 0.06))
        val px = X(win + 0.3); val py = Y(wy0 - 0.06); val s = f / z0
        poly(night(0x8A4A2A, 1.6), px - 0.08 * s, py, px + 0.08 * s, py, px + 0.1 * s, py - 0.14 * s, px - 0.1 * s, py - 0.14 * s)
        for (k in 0 until 14) { val a = -1.2 + 2.4 * k / 13
            line(night(0x5A7A3A, 1.6), 1.6, px, py - 0.14 * s, px + sin(a) * 0.14 * s, py - 0.14 * s - cos(a) * 0.12 * s * (0.6 + rnd(k, 561))) }
        // the light's halo on the wall around the window
        glow(X(win), Y(1.9), f * 1.3 / z0, warm, 0.18)
    }

    /** The open door: frame and lintel, the warm room behind, the leaf swung in on its left hinges, the threshold stone. */
    fun doorway() {
        val x0 = door - dw; val x1 = door + dw
        val clip = g.clip; g.clip(rect(x0, 0.1, x1, dh))
        // the room: a far wall with a shelf of jugs, plank floor running in, the hearth's glow from the right
        val zb = z0 + 4.0
        g.color = Color(0x5A3418); g.fill(rect(x0, 0.0, x1, dh + 0.1))
        quad(Color(0x7A4A22), door - 3.0, 0.0, zb, door + 3.0, 0.0, zb, door + 3.0, 3.2, zb, door - 3.0, 3.2, zb)
        for (k in -10..10) { val x = door + k * 0.2
            quad(if (k % 2 == 0) Color(0x9A6430) else Color(0x8A5828), x, 0.0, z0, x + 0.2, 0.0, z0, x + 0.2, 0.0, zb, x, 0.0, zb)
            line(Color(0x4A2C14), 1.0, sx(x, z0), sy(0.0, z0), sx(x, zb), sy(0.0, zb)) }
        line(Color(0x3A2210), f * 0.05 / zb, sx(door - 2.0, zb), sy(1.55, zb), sx(door + 2.0, zb), sy(1.55, zb))
        for (k in 0 until 7) { val x = door - 1.2 + k * 0.38
            g.color = Color(0x3E2412); g.fill(Ellipse2D.Double(sx(x, zb) - f * 0.08 / zb, sy(1.88, zb), f * 0.16 / zb, f * 0.3 / zb)) }
        quad(Color(0x2A160A), door - 3.0, 2.5, zb - 1.5, door + 3.0, 2.5, zb - 1.5, door + 3.0, 2.7, zb - 1.5, door - 3.0, 2.7, zb - 1.5)
        glow(sx(door + 1.4, zb - 1.0), sy(0.8, zb - 1.0), f * 2.4 / zb, Color(0xFFB050), 0.6)
        glow(sx(door + 0.2, z0 + 1.5), sy(1.3, z0 + 1.5), f * 1.2 / z0, Color(0xFFD890), 0.35)
        g.clip = clip
        // the leaf, open some 70 degrees, its edge catching the room's light
        val ang = Math.toRadians(72.0)
        val ex = x0 + 2 * dw * cos(ang); val ez = z0 + 2 * dw * sin(ang)
        quad(Color(0x24180E), x0, 0.1, z0, ex, 0.1, ez, ex, dh - 0.02, ez, x0, dh - 0.02, z0)
        for (k in 1..4) { val t = k / 5.0; val bx = x0 + (ex - x0) * t; val bz = z0 + (ez - z0) * t
            line(Color(0x120A06), 1.0, sx(bx, bz), sy(0.1, bz), sx(bx, bz), sy(dh - 0.02, bz)) }
        line(alpha(Color(0xFFC060), 0.85), maxOf(1.5, f * 0.035 / ez), sx(ex, ez), sy(0.1, ez), sx(ex, ez), sy(dh - 0.02, ez))
        // the frame and the lintel with a carved band
        fill(night(0x2E2018, 1.6), x0 - 0.16, 0.0, x0, dh + 0.2); fill(night(0x2E2018, 1.6), x1, 0.0, x1 + 0.16, dh + 0.2)
        fill(night(0x2E2018, 1.6), x0 - 0.22, dh, x1 + 0.22, dh + 0.2)
        for (k in 0 until 9) { val x = x0 - 0.1 + k * 0.155
            line(Color(0x140C08), 1.2, X(x), Y(dh + 0.04), X(x + 0.07), Y(dh + 0.16)) }
        line(alpha(Color(0xFFB860), 0.6), 1.5, X(x0), Y(0.1), X(x0), Y(dh))
        line(alpha(Color(0xFFB860), 0.6), 1.5, X(x1), Y(0.1), X(x1), Y(dh))
        // the worn threshold stone, warm on top
        quad(mix(night(0x5A564C, 0.8), Color(0x8A5A30), 0.4), x0 - 0.2, 0.0, z0 - 0.3, x1 + 0.2, 0.0, z0 - 0.3, x1 + 0.2, 0.1, z0 - 0.02, x0 - 0.2, 0.1, z0 - 0.02)
        quad(mix(night(0x4A463E), Color(0x6A4828), 0.35), x0 - 0.2, 0.0, z0 - 0.3, x1 + 0.2, 0.0, z0 - 0.3, x1 + 0.2, -0.04, z0 - 0.3, x0 - 0.2, -0.04, z0 - 0.3)
    }

    /**
     * Rowena in the doorway, dark against the warm room: sturdy, broad in the shoulders, hair bound up, sleeves rolled to the
     * elbow, the light apron over a dark woollen dress; her right hand on the door's edge, a jug in her left. No face (70.2).
     */
    fun rowena() {
        val x = door + 0.06; val z = z0 + 0.35; val s = f / z
        val px = sx(x, z); val py = sy(0.1, z)
        fun P(dx: Double, dy: Double) = Point2D.Double(px + dx * s, py - dy * s)
        val dress = Color(0x1A110C); val skin = Color(0x2E1C12); val rim = Color(0xFFB860)
        val body = Path2D.Double()
        fun mv(dx: Double, dy: Double) = P(dx, dy).let { body.moveTo(it.x, it.y) }
        fun ln(dx: Double, dy: Double) = P(dx, dy).let { body.lineTo(it.x, it.y) }
        fun cv(a: Double, b: Double, c: Double, d: Double, e: Double, ff: Double) { val p1 = P(a, b); val p2 = P(c, d); val p3 = P(e, ff); body.curveTo(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y) }
        // the skirt to the floor, folds at the hem; the waist; the broad shoulders; the neck
        mv(-0.33, 0.0); ln(-0.2, 0.02); ln(-0.1, -0.01); ln(0.02, 0.02); ln(0.14, -0.01); ln(0.26, 0.02); ln(0.33, 0.0)
        cv(0.31, 0.35, 0.25, 0.7, 0.2, 0.92)
        cv(0.24, 1.05, 0.27, 1.22, 0.24, 1.33)
        cv(0.2, 1.38, 0.12, 1.4, 0.06, 1.42)
        ln(0.05, 1.47); ln(-0.05, 1.47); ln(-0.06, 1.42)
        cv(-0.12, 1.4, -0.2, 1.38, -0.24, 1.33)
        cv(-0.27, 1.22, -0.24, 1.05, -0.2, 0.92)
        cv(-0.25, 0.7, -0.31, 0.35, -0.33, 0.0)
        body.closePath()
        g.color = dress; g.fill(body)
        // the head, a little turned, the hair in a knot at the back
        val head = Ellipse2D.Double(px - 0.095 * s, py - 1.66 * s, 0.19 * s, 0.23 * s)
        g.fill(head); g.fill(Ellipse2D.Double(px + 0.02 * s, py - 1.7 * s, 0.12 * s, 0.1 * s))
        // the arms: sleeves to the elbow, then bare forearms
        // right arm (our left) reaching to the door's edge
        val e1 = P(-0.36, 1.08); val h1 = P(-0.52, 1.0)
        line(dress, 0.12 * s, P(-0.22, 1.32).x, P(-0.22, 1.32).y, e1.x, e1.y)
        g.fill(Ellipse2D.Double(e1.x - 0.07 * s, e1.y - 0.05 * s, 0.14 * s, 0.1 * s))
        line(skin, 0.08 * s, e1.x, e1.y, h1.x, h1.y)
        g.color = skin; g.fill(Ellipse2D.Double(h1.x - 0.05 * s, h1.y - 0.06 * s, 0.09 * s, 0.12 * s))
        // left arm (our right) down at her side, the jug hanging from the hand
        val e2 = P(0.3, 1.02); val h2 = P(0.34, 0.76)
        line(dress, 0.12 * s, P(0.22, 1.32).x, P(0.22, 1.32).y, e2.x, e2.y)
        g.color = dress; g.fill(Ellipse2D.Double(e2.x - 0.07 * s, e2.y - 0.05 * s, 0.14 * s, 0.1 * s))
        line(skin, 0.08 * s, e2.x, e2.y, h2.x, h2.y)
        val jx = h2.x + 0.02 * s; val jy = h2.y
        val jug = Path2D.Double()
        jug.moveTo(jx - 0.07 * s, jy); jug.curveTo(jx - 0.13 * s, jy + 0.08 * s, jx - 0.11 * s, jy + 0.22 * s, jx - 0.07 * s, jy + 0.27 * s)
        jug.lineTo(jx + 0.07 * s, jy + 0.27 * s); jug.curveTo(jx + 0.11 * s, jy + 0.22 * s, jx + 0.13 * s, jy + 0.08 * s, jx + 0.07 * s, jy); jug.closePath()
        g.color = Color(0x22160E); g.fill(jug)
        g.color = Color(0x22160E); g.stroke = BasicStroke((0.025 * s).toFloat()); g.draw(java.awt.geom.Arc2D.Double(jx + 0.03 * s, jy + 0.02 * s, 0.1 * s, 0.16 * s, -90.0, 180.0, java.awt.geom.Arc2D.OPEN))
        // the apron: pale linen, but backlit; only the moon touches it a little from the right, its strings at the waist
        val ap = Path2D.Double()
        val a0 = P(-0.19, 0.9); ap.moveTo(a0.x, a0.y)
        listOf(P(0.19, 0.9), P(0.23, 0.5), P(0.26, 0.14), P(0.1, 0.12), P(-0.05, 0.15), P(-0.26, 0.13), P(-0.23, 0.5)).forEach { ap.lineTo(it.x, it.y) }
        ap.closePath()
        g.color = Color(0x4E463C); g.fill(ap)
        g.paint = GradientPaint(P(0.26, 0.0).x.toFloat(), 0f, alpha(Color(0x9AA0B4), 0.35), px.toFloat(), 0f, alpha(Color(0x9AA0B4), 0.0)); g.fill(ap)
        for (k in 0 until 3) { val fx = -0.12 + k * 0.12; line(alpha(Color(0x2A2420), 0.6), 1.2, P(fx, 0.85).x, P(fx, 0.85).y, P(fx * 1.25, 0.16).x, P(fx * 1.25, 0.16).y) }
        line(Color(0x2A2420), 0.035 * s, P(-0.21, 0.92).x, P(-0.21, 0.92).y, P(0.21, 0.92).x, P(0.21, 0.92).y)
        // the rim light: the room behind her draws her outline thin and warm, strongest where the hearth is (our right)
        val clip = g.clip
        g.clip(java.awt.geom.Rectangle2D.Double(px, 0.0, W.toDouble(), H.toDouble()))
        g.color = alpha(rim, 0.6); g.stroke = BasicStroke(maxOf(1.2f, (0.014 * s).toFloat()), BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(body); g.draw(head)
        g.clip = clip
        line(alpha(rim, 0.5), maxOf(1.0, 0.012 * s), e2.x + 0.05 * s, e2.y, h2.x + 0.04 * s, h2.y)
        line(alpha(rim, 0.45), maxOf(1.0, 0.01 * s), jx + 0.1 * s, jy + 0.05 * s, jx + 0.08 * s, jy + 0.25 * s)
    }

    /** The light out of the door hanging in the air before it, and Rowena's shadow over the threshold. */
    fun spill() {
        glow(X(door), Y(1.0), f * 1.6 / z0, warmDeep, 0.12)
    }

    /** A bench under the window: a thick plank on two blocks, the window's light on its seat. */
    fun bench(x: Double) {
        val z = z0 - 0.4; val zb = z0 - 0.05
        for (bx in listOf(x - 0.75, x + 0.6)) {
            quad(night(0x2E2218, 1.3), bx, 0.0, z + 0.05, bx + 0.14, 0.0, z + 0.05, bx + 0.14, 0.42, z + 0.05, bx, 0.42, z + 0.05)
        }
        quad(mix(night(0x5A4430, 1.4), Color(0xB07A40), 0.45), x - 0.95, 0.47, z, x + 0.95, 0.47, z, x + 0.95, 0.47, zb, x - 0.95, 0.47, zb)
        quad(night(0x3A2A1E, 1.3), x - 0.95, 0.4, z, x + 0.95, 0.4, z, x + 0.95, 0.47, z, x - 0.95, 0.47, z)
        line(alpha(warm, 0.5), 1.5, sx(x - 0.95, z), sy(0.47, z), sx(x + 0.95, z), sy(0.47, z))
        // a forgotten mug on the bench
        val mx = sx(x + 0.45, z + 0.15); val my = sy(0.47, z + 0.15); val s = f / (z + 0.15)
        g.color = night(0x6A5A48, 1.6); g.fill(java.awt.geom.Rectangle2D.Double(mx - 0.045 * s, my - 0.12 * s, 0.09 * s, 0.12 * s))
        line(alpha(warm, 0.6), 1.2, mx - 0.045 * s, my - 0.12 * s, mx - 0.045 * s, my)
        g.color = alpha(Color(0x06060A), 0.5)
        g.fill(quadShape(x - 0.95, 0.0, z + 0.1, x + 0.95, 0.0, z + 0.1, x + 1.1, 0.0, z - 0.25, x - 0.8, 0.0, z - 0.25))
    }

    /** A barrel by the door, the door's light on its left side, iron hoops. */
    fun barrel(x: Double) {
        val z = z0 - 0.45; val s = f / z
        val px = sx(x + 0.3, z); val py = sy(0.0, z)
        val p = Path2D.Double()
        p.moveTo(px - 0.25 * s, py); p.curveTo(px - 0.31 * s, py - 0.3 * s, px - 0.31 * s, py - 0.55 * s, px - 0.25 * s, py - 0.8 * s)
        p.lineTo(px + 0.25 * s, py - 0.8 * s); p.curveTo(px + 0.31 * s, py - 0.55 * s, px + 0.31 * s, py - 0.3 * s, px + 0.25 * s, py); p.closePath()
        g.color = night(0x5A4430, 1.1); g.fill(p)
        g.paint = GradientPaint((px - 0.3 * s).toFloat(), 0f, alpha(Color(0xFFB050), 0.45), (px + 0.3 * s).toFloat(), 0f, alpha(Color(0xFFB050), 0.0)); g.fill(p)
        for (k in 0 until 7) { val bx = px - 0.21 * s + k * 0.07 * s; line(alpha(Color(0x140C08), 0.6), 1.0, bx, py - 0.04 * s, bx, py - 0.77 * s) }
        for (hy in listOf(0.1, 0.4, 0.7)) line(Color(0x18161A), 0.035 * s, px - 0.3 * s, py - hy * s, px + 0.3 * s, py - hy * s)
        g.color = night(0x6A5038, 1.3); g.fill(Ellipse2D.Double(px - 0.25 * s, py - 0.85 * s, 0.5 * s, 0.1 * s))
        softShadow(px + 0.2 * s, py, 0.45 * s)
    }

    /**
     * The sign on an iron bracket: a board hanging at right angles to the wall, seen a little from the left; a beast curled in
     * sleep painted on it, its gold faded (the »Schlafender Greif«; our own simple drawing).
     */
    fun sign(x: Double) {
        val y0 = 2.55; val y1 = 3.2; val za = z0 - 0.3; val zb = z0 - 1.2; val arm = 3.42
        val iron = Color(0x121214)
        line(iron, maxOf(1.5, f * 0.045 / za), sx(x, z0), sy(arm, z0), sx(x, zb - 0.12), sy(arm, zb - 0.12))
        // the bracket's brace with a curl
        line(iron, maxOf(1.2, f * 0.03 / za), sx(x, z0), sy(2.95, z0), sx(x, z0 - 0.75), sy(arm, z0 - 0.75))
        val cs = f * 0.12 / (z0 - 0.4)
        g.color = iron; g.stroke = BasicStroke(maxOf(1f, (f * 0.02 / za).toFloat())); g.draw(Ellipse2D.Double(sx(x, z0 - 0.4) - cs / 2, sy(3.2, z0 - 0.4) - cs / 2, cs, cs))
        for (zz in listOf(za, zb)) line(iron, 1.5, sx(x, zz), sy(arm, zz), sx(x, zz), sy(y1, zz))
        val board = quadShape(x, y0, za, x, y0, zb, x, y1, zb, x, y1, za)
        g.color = night(0x5A4430, 1.15); g.fill(board)
        texture(board, z0, Color(0x1A120C), night(0x8A7050, 1.4), 300, 0.02, 0.4)
        val clip = g.clip; g.clip(board)
        // the painted beast, faded: a curled body, a folded wing, the beaked head tucked under it, a tail curling round
        fun B(u: Double, v: Double) = Point2D.Double(sx(x, za + (zb - za) * u), sy(y0 + (y1 - y0) * v, za + (zb - za) * u))
        val gold = night(0xD0A850, 1.35)
        val body = Path2D.Double(); B(0.25, 0.25).let { body.moveTo(it.x, it.y) }
        listOf(B(0.2, 0.55), B(0.4, 0.72), B(0.7, 0.7), B(0.82, 0.45), B(0.72, 0.22), B(0.45, 0.18)).forEach { body.lineTo(it.x, it.y) }
        body.closePath(); g.color = gold; g.fill(body)
        val wing = Path2D.Double(); B(0.35, 0.55).let { wing.moveTo(it.x, it.y) }
        listOf(B(0.5, 0.88), B(0.78, 0.8), B(0.62, 0.55)).forEach { wing.lineTo(it.x, it.y) }
        wing.closePath(); g.color = night(0xA88038, 1.35); g.fill(wing)
        val head = B(0.22, 0.38); g.color = gold; g.fill(Ellipse2D.Double(head.x - 6, head.y - 5, 12.0, 10.0))
        line(night(0x6A4A20, 1.4), 2.0, B(0.82, 0.3).x, B(0.82, 0.3).y, B(0.9, 0.55).x, B(0.9, 0.55).y)
        g.clip = clip
        g.color = night(0x2A1C10); g.stroke = BasicStroke(2f); g.draw(board)
        line(alpha(Color(0xC8D0E0), 0.4), 1.4, sx(x, za), sy(y1, za), sx(x, zb), sy(y1, zb))
    }

    /** Life: moths at the lit window, a thread of smoke from the chimney into the stars. */
    fun life2() {
        for ((dx, dy) in listOf(-0.45 to 0.75, 0.32 to 0.95, 0.1 to 0.55)) {
            val x = X(win + dx); val y = Y(wy1 + dy - 0.6)
            glow(x, y, 7.0, Color(0xFFE0A0), 0.55)
            g.color = Color(0xEAD8B0); g.fill(Ellipse2D.Double(x - 3.5, y - 2.0, 7.0, 4.0))
        }
    }
}
