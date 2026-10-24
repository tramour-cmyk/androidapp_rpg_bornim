package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * 292.3: the main menu's figures in the light of a fire: no dither, every colour as it is lit; a point light with soft
 * shadows, a cool light from behind on the edges (so the outline does not sink into the night), and lines of ink
 * round the figure and where a nearer part overlaps a farther one, heavy in the dark and fine where the fire falls.
 */
class TitleLight(
    /** The fire in view space from the figure's feet (x right, y up, z towards the viewer), in the body's units (cm). */
    val fire: P3,
    val fireRgb: Int = 0xFFA850,
    val fireK: Double = 1.45,
    /** How far the fire's light carries before it is half as strong. */
    val reach: Double = 160.0,
    /** The night from behind and above: cool, on the edges turned away from the viewer. */
    val rimRgb: Int = 0x6C88C4,
    val rimK: Double = 1.0,
    val ambientRgb: Int = 0x30344A,
    val ambientK: Double = 1.0,
    /** How soft a shadow's edge is: lower is softer. */
    val soft: Double = 7.0,
    /** Ink widths in pixels are multiplied by this (2 for a picture drawn twice as fine). */
    val ink: Double = 1.0,
    /** The groups of the face and of the hair: hair casts no shadow on the face. */
    val faceGroup: Int = Doll.HEAD,
    val hairGroup: Int = Doll.HAIR,
    /** Pupil and the light caught in it; off, the eye is lid, white and iris only, no dot that stares (292.3, Entwurf A). */
    val eyeDots: Boolean = true,
    /** The fire's highlight is multiplied by this: 0 for none, so no white spot sits on a shield (292.3, Chef 16:39). */
    val shineK: Double = 1.0,
    /** How much nearer (cm) a part must be to draw a line of ink where it overlaps a farther one. */
    val inkJump: Double = 3.0,
    /** How much heavier the outline grows in the dark: low keeps it thin and even. */
    val inkDark: Double = 1.4,
    /** Lines of ink inside the figure where a nearer part overlaps a farther one; off, only the outline (302.1: the map's small figures). */
    val inkInside: Boolean = true,
) {
    private fun rgb(c: Int) = doubleArrayOf(((c shr 16) and 0xFF) / 255.0, ((c shr 8) and 0xFF) / 255.0, (c and 0xFF) / 255.0)
    private val fireC = rgb(fireRgb)
    private val rimC = rgb(rimRgb)
    private val ambC = rgb(ambientRgb)
    private val rimDir = P3(-0.35, 0.55, -0.76).norm()

    /**
     * The light at a point with view-space normal [n], [dist] from the fire along view-space direction [toFire],
     * [shadow] 0 (in shadow) to 1, into [out] as red, green, blue; gives the fire's highlight for a material of [shine].
     */
    fun light(n: P3, toFire: P3, dist: Double, shadow: Double, shine: Double, out: DoubleArray, at: Int): Double {
        val fall = 1.0 / (1.0 + (dist / reach).pow(2))
        // wrapped a little round the form, so the turn into shadow is soft
        val d = max(0.0, ((n dot toFire) + 0.15) / 1.15)
        val f = fireK * fall * d * shadow
        val back = max(0.0, n dot rimDir)
        val edge = (1 - abs(n.z)).coerceIn(0.0, 1.0).pow(3)
        val r = rimK * (back * 0.7 + edge * 0.6)
        val a = ambientK * (0.55 + 0.45 * max(0.0, n.y))
        val half = (toFire + P3.Z).norm()
        val sp = if (shine > 0 && shineK > 0) shineK * shine * max(0.0, n dot half).pow(40) * 0.6 * fall * shadow else 0.0
        for (c in 0..2) out[at * 3 + c] = fireC[c] * f + rimC[c] * r + ambC[c] * a
        return sp
    }

    /** The lit colour: [albedo] (the material's own) times the light, plus the fire's highlight. */
    fun shade(albedo: Int, light: DoubleArray, at: Int, sp: Double, bias: Double = 0.0): Int {
        val k = (1 + 1.5 * bias).coerceIn(0.2, 2.0)
        fun ch(s: Int) = ((albedo shr s) and 0xFF) / 255.0 * k
        val r = ch(16) * light[at * 3] + sp * fireC[0]
        val g = ch(8) * light[at * 3 + 1] + sp * fireC[1]
        val b = ch(0) * light[at * 3 + 2] + sp * fireC[2]
        return argb(tone(r) shl 16 or (tone(g) shl 8) or tone(b))
    }

    /** Soft roll-off into the brightest: the fire burns highlights warm, not flat white. */
    private fun tone(v: Double): Int = (255 * (1 - kotlin.math.exp(-1.25 * v)) / (1 - kotlin.math.exp(-1.25))).toInt().coerceIn(0, 255)

    /**
     * Ink over the finished picture: an outline outside the figure and fine inner lines where a nearer part overlaps
     * a farther one, each heavy where it is dark and fine where it is lit.
     */
    fun inkLines(img: DepthImage, lum: DoubleArray) {
        val w = img.img.width; val h = img.img.height
        val px = img.img.pixels
        val depth = img.depth
        val inkC = 0x0D0809
        val seedIn = BooleanArray(w * h)
        val solid = BooleanArray(w * h) { (px[it] ushr 24) != 0 && depth[it].isFinite() }
        for (y in 0 until h) for (x in 0 until w) {
            val at = y * w + x
            if (!solid[at]) continue
            for ((dx, dy) in NEIGH) {
                val xx = x + dx; val yy = y + dy
                if (xx !in 0 until w || yy !in 0 until h) continue
                val b = yy * w + xx
                if (solid[b] && depth[at] - depth[b] > inkJump) { seedIn[at] = true; break }
            }
        }
        val R = (3.5 * ink).toInt() + 1
        // 302.1: only near the figure is there ink (the map's figures leave most of their picture empty)
        var x0 = w; var x1 = -1; var y0 = h; var y1 = -1
        for (y in 0 until h) for (x in 0 until w) if (solid[y * w + x]) { x0 = min(x0, x); x1 = max(x1, x); y0 = min(y0, y); y1 = max(y1, y) }
        if (x1 < 0) return
        val out = px.copyOf()
        for (y in max(0, y0 - R)..min(h - 1, y1 + R)) for (x in max(0, x0 - R)..min(w - 1, x1 + R)) {
            val at = y * w + x
            var aOut = 0.0; var aIn = 0.0
            if (!solid[at]) {
                // outside: how near the figure, and how lit it is there
                var best = Double.MAX_VALUE; var bl = 0.0
                for (yy in max(0, y - R)..min(h - 1, y + R)) for (xx in max(0, x - R)..min(w - 1, x + R)) {
                    val b = yy * w + xx
                    if (!solid[b]) continue
                    val d = sqrt(((xx - x) * (xx - x) + (yy - y) * (yy - y)).toDouble())
                    if (d < best) { best = d; bl = lum[b] }
                }
                if (best == Double.MAX_VALUE) continue
                val wd = ink * (0.8 + inkDark * (1 - (bl * 1.5).coerceIn(0.0, 1.0)))
                aOut = (wd - best + 0.5).coerceIn(0.0, 1.0)
                if (aOut <= 0) continue
                out[at] = alpha(inkC, (aOut * 255).toInt())
                continue
            }
            if (!inkInside) continue
            var best = Double.MAX_VALUE
            for (yy in max(0, y - R)..min(h - 1, y + R)) for (xx in max(0, x - R)..min(w - 1, x + R)) {
                val b = yy * w + xx
                if (!seedIn[b]) continue
                val d = sqrt(((xx - x) * (xx - x) + (yy - y) * (yy - y)).toDouble())
                if (d < best) best = d
            }
            if (best == Double.MAX_VALUE) continue
            val wd = ink * (0.45 + 1.1 * (1 - (lum[at] * 1.8).coerceIn(0.0, 1.0)))
            aIn = ((wd - best + 0.5).coerceIn(0.0, 1.0)) * 0.9
            if (aIn > 0) out[at] = mix(px[at], argb(inkC), aIn)
        }
        System.arraycopy(out, 0, px, 0, out.size)
    }

    companion object {
        private val NEIGH = listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)
    }
}
