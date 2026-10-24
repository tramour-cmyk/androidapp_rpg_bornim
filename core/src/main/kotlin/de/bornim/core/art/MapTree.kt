package de.bornim.core.art

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Trees with volume (27.4): the crowns of oaks are heaped from lit clumps of leaves around a round
 * body, so they bulge towards the light (upper right) and fall into shade underneath and inside; the
 * trunk is a round column with bark, roots spreading on the ground and boughs reaching into the
 * crown, shaded where the crown hangs over it. Spruces stand in drooping tiers of needles, each tier
 * shading the one below. Dead trees are bare round limbs. Every shape is lit from its surface
 * normal and dithered to a small ramp, like [Sculpt]; a depth buffer lets clumps and boughs cover
 * each other the way they stand.
 *
 * Same sizes and foot points as the flat pictures before, so the trees stand where they stood.
 */
internal object MapTree {
    private const val S = MapGround.S

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun vnoise(x: Double, y: Double, cell: Double, s: Int): Double {
        val fx = x / cell; val fy = y / cell
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var v = fy - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    private fun ramp(vararg c: Int) = IntArray(c.size) { argb(c[it]) }

    // deep shade (a little blue) to sunlit leaf (a little yellow)
    private val LEAF = ramp(0x0A110B, 0x132012, 0x1D2E17, 0x2A401F, 0x3A5427, 0x506A30, 0x6C8040)
    private val LEAF_DEEP = ramp(0x070D0A, 0x0F1911, 0x172618, 0x22341F, 0x2F4627, 0x40582F, 0x56693A)
    private val LEAF_OLIVE = ramp(0x0C110A, 0x172010, 0x232F16, 0x31421D, 0x425526, 0x566A2E, 0x6C7A3A)
    private val PINE = ramp(0x060E0B, 0x0C1812, 0x13241A, 0x1C3223, 0x27422D, 0x365539, 0x4A6A48)
    private val BARK = ramp(0x17110E, 0x261D17, 0x382B21, 0x4D3C2D, 0x65503C, 0x7C6650)
    private val DEAD = ramp(0x1C1A18, 0x2E2A26, 0x433D36, 0x5A5248, 0x736A5D, 0x8A8172)

    // light from the upper right and a little in front, as on the houses and everything else on the map (D6.6)
    private val L = norm(0.55, -0.7, 0.55)

    private fun norm(x: Double, y: Double, z: Double): DoubleArray {
        val l = sqrt(x * x + y * y + z * z).coerceAtLeast(1e-9)
        return doubleArrayOf(x / l, y / l, z / l)
    }

    private val bayer = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)

    /** A picture with a depth for every pixel (towards the viewer is larger). */
    private class Canvas(val w: Int, val h: Int) {
        val img = PixelImage(w, h)
        val z = DoubleArray(w * h) { Double.NEGATIVE_INFINITY }
        /** 348.1: how lit each pixel is (0..1), for the line of ink ([ink]). */
        val lit = DoubleArray(w * h)

        /** Lit, dithered pixel: [i] brightness 0..1 into [tones]; only if in front of what is there. */
        fun plot(x: Int, y: Int, depth: Double, i: Double, tones: IntArray) {
            if (x !in 0 until w || y !in 0 until h) return
            val k = y * w + x
            if (depth < z[k]) return
            z[k] = depth
            lit[k] = i.coerceIn(0.0, 1.0)
            val steps = tones.size - 1
            val d = (bayer[(y and 3) * 4 + (x and 3)] / 16.0 - 0.47) * 0.8
            img.pixels[k] = tones[floor(i * steps + 0.5 + d).toInt().coerceIn(0, steps)]
        }
    }

    private fun light(nx: Double, ny: Double, nz: Double) = max(0.0, nx * L[0] + ny * L[1] + nz * L[2])

    /**
     * 348.1 (Signatur 2, preview only): the line of ink drawn with the tree, just inside its outline, from how lit the
     * drawer made each pixel ([Canvas.lit]): heavy where the shape lies in shade, fine where the sun meets it. No lines
     * inside; the light of the place comes after, over it. [fine] as in [oak].
     */
    private fun ink(c: Canvas, fine: Int) {
        val w = c.w; val h = c.h; val px = c.img.pixels
        val R = 3 * fine
        fun solid(x: Int, y: Int) = (px[y * w + x] ushr 24) != 0
        val out = px.copyOf()
        for (y in 0 until h) for (x in 0 until w) {
            if (!solid(x, y)) continue
            var best = Double.MAX_VALUE
            for (yy in max(0, y - R)..min(h - 1, y + R)) for (xx in max(0, x - R)..min(w - 1, x + R)) {
                if (solid(xx, yy)) continue
                val d = sqrt(((xx - x) * (xx - x) + (yy - y) * (yy - y)).toDouble())
                if (d < best) best = d
            }
            if (best > R) continue
            // single leaves standing free get no ink: they would turn into black specks
            var near = 0
            for (yy in max(0, y - 1)..min(h - 1, y + 1)) for (xx in max(0, x - 1)..min(w - 1, x + 1)) if (solid(xx, yy)) near++
            if (near < 5) continue
            val wd = (0.35 + 2.0 * (1 - c.lit[y * w + x]).let { it * it }) * fine
            val a = (wd - best + 0.5).coerceIn(0.0, 1.0)
            if (a > 0) out[y * w + x] = mix(px[y * w + x], INK, a * 0.92)
        }
        System.arraycopy(out, 0, px, 0, px.size)
    }

    private val INK = argb(0x0D0809)

    /**
     * A round limb from (ax, ay, az) to (bx, by, bz) with radii [ra] to [rb]: shaded like a cylinder
     * across, bark grooves along. [shade] darkens it (inside a crown).
     */
    private fun limb(c: Canvas, ax: Double, ay: Double, az: Double, bx: Double, by: Double, bz: Double,
                     ra: Double, rb: Double, tones: IntArray, seed: Int, f: Int = 1, shade: (Int, Int) -> Double = { _, _ -> 0.0 }) {
        val dx = bx - ax; val dy = by - ay
        val len2 = (dx * dx + dy * dy).coerceAtLeast(1e-6)
        val len = sqrt(len2)
        // across the limb, in the picture
        val px = -dy / len; val py = dx / len
        val r = max(ra, rb) + 1
        for (y in floor(min(ay, by) - r).toInt()..(max(ay, by) + r).toInt()) for (x in floor(min(ax, bx) - r).toInt()..(max(ax, bx) + r).toInt()) {
            val qx = x + 0.5 - ax; val qy = y + 0.5 - ay
            val t = ((qx * dx + qy * dy) / len2).coerceIn(0.0, 1.0)
            val rad = ra + (rb - ra) * t
            val ex = qx - dx * t; val ey = qy - dy * t
            val d = sqrt(ex * ex + ey * ey)
            if (d > rad) continue
            val e = ((ex * px + ey * py) / rad).coerceIn(-1.0, 1.0)
            val nz = sqrt(1 - e * e)
            val nx = px * e; val ny = py * e
            var i = 0.16 + 0.85 * light(nx, ny - 0.15, nz) - shade(x, y)
            // grooves running along the limb
            val along = t * len / f
            val groove = vnoise(e * 4.0 + seed, along * 0.35, 1.0, seed)
            if (groove < 0.3) i -= 0.18
            i += (rnd(x, y, seed + 3) - 0.5) * 0.12
            c.plot(x, y, az + (bz - az) * t + nz * rad, i, tones)
        }
    }

    /** The trunk standing from the foot up to [top], with roots on the ground; [crownShade] darkens it under the crown. */
    private fun trunk(c: Canvas, bx: Double, by: Double, top: Double, width: Double, seed: Int, tones: IntArray, crownShade: Double, fine: Int = 1) {
        val shade: (Int, Int) -> Double = { _, y -> if (y < crownShade) 0.4 else ((crownShade + width * 1.5 - y) / (width * 1.5)).coerceIn(0.0, 1.0) * 0.4 }
        // the column, a little crooked, widening towards the foot
        val n = 8
        var x0 = bx; var y0 = by - 2 * fine
        for (k in 1..n) {
            val f = k / n.toDouble()
            val x1 = bx + sin(f * 2.2 + seed) * width * 0.25
            val y1 = by - 2 * fine - (by - 2 * fine - top) * f
            val r0 = width / 2 * (1 + (1 - (k - 1) / n.toDouble()).let { it * it * it * it * it * it } * 0.8)
            val r1 = width / 2 * (1 + (1 - f).let { it * it * it * it * it * it } * 0.8)
            limb(c, x0, y0, 0.0, x1, y1, 0.0, r0, r1, tones, seed, fine, shade)
            x0 = x1; y0 = y1
        }
        // roots: towards the viewer they reach down the picture, to the sides along the ground
        for (k in 0 until 5) {
            val a = PI * (0.05 + k * 0.225) + (rnd(seed, k, 11) - 0.5) * 0.3
            val len = width * (1.1 + rnd(seed, k, 12) * 0.6)
            val ex = bx + cos(a) * len; val ey = by - 2 * fine + sin(a) * len * 0.3
            limb(c, bx + cos(a) * width * 0.3, by - width * 0.5, 0.0, ex, ey, sin(a) * len * 0.5, width * 0.3, width * 0.07, tones, seed + k, fine)
        }
    }

    /**
     * A leafy crown heaped from clumps: [cx], [cy] its middle, [r] its radius; the clumps lie on a
     * round body, those in front cover those behind, each lit by its own bulge and the body's.
     */
    private fun crown(c: Canvas, cx: Double, cy: Double, r: Double, tones: IntArray, seed: Int, squash: Double = 0.82, clumps: Int = 26, fine: Int = 1) {
        data class Clump(val x: Double, val y: Double, val z: Double, val r: Double, val w: Double)
        val list = ArrayList<Clump>()
        for (k in 0 until clumps) {
            // a direction on the front half of the body, a few inside for depth
            val u = rnd(seed, k, 1) * 2 - 1
            val v = rnd(seed, k, 2) * 2 - 1
            val l = sqrt(u * u + v * v)
            if (l > 1) continue
            val w = sqrt(1 - l * l)
            val depth = 0.75 + rnd(seed, k, 3) * 0.25
            val cr = r * (0.3 + rnd(seed, k, 4) * 0.16)
            list += Clump(cx + u * r * 0.78 * depth, cy + v * r * squash * 0.78 * depth, w * r * 0.6 * depth, cr, w)
        }
        // one clump on top and the ones at the rim, so the outline stays round
        for (k in 0 until 10) {
            val a = k / 10.0 * 2 * PI + rnd(seed, k, 5) * 0.4
            list += Clump(cx + cos(a) * r * 0.72, cy + sin(a) * r * squash * 0.72, 0.0, r * (0.28 + rnd(seed, k, 6) * 0.1), 0.0)
        }
        for (cl in list) {
            val rr = cl.r * 1.25
            for (y in (cl.y - rr).toInt()..(cl.y + rr).toInt()) for (x in (cl.x - rr).toInt()..(cl.x + rr).toInt()) {
                val ux = (x + 0.5 - cl.x) / cl.r; val uy = (y + 0.5 - cl.y) / cl.r
                // the rim of a clump frays into leaves
                val leaf = vnoise(x.toDouble(), y.toDouble(), 2.2 * fine, seed + 17) * 0.55 + vnoise(x.toDouble(), y.toDouble(), 5.0 * fine, seed + 18) * 0.45
                val q = ux * ux + uy * uy
                val edge = 0.78 + leaf * 0.42
                if (q > edge * edge) continue
                val lz = sqrt((1 - q / (edge * edge)).coerceAtLeast(0.0))
                // the body's own round
                val gx = (x + 0.5 - cx) / r; val gy = (y + 0.5 - cy) / (r * squash)
                val gz = sqrt((1 - gx * gx - gy * gy).coerceAtLeast(0.0))
                val n = norm(ux * 0.55 + gx * 0.6, uy * 0.55 + gy * 0.6, lz * 0.55 + gz * 0.6 + 0.1)
                var i = 0.1 + 0.9 * light(n[0], n[1], n[2])
                // inside and underneath lies in the crown's own shade
                i -= (1 - cl.w) * 0.12
                i -= (gy - 0.3).coerceAtLeast(0.0) * 0.3
                // single leaves catch the light or fall dark
                i += (leaf - 0.5) * 0.5 + (rnd(x, y, seed + 21) - 0.5) * 0.12
                c.plot(x, y, cl.z + lz * cl.r * 0.6, i, tones)
            }
        }
    }

    /** An oak, as [MapFlora.oak]; [fine] times as many pixels each way, [ink] with the line of ink (348.1, preview only). */
    fun oak(variant: Int, size: Int, deep: Boolean, fine: Int = 1, ink: Boolean = false): MapFlora.Sprite {
        val r = (S * (0.95 + size * 0.17) + variant % 3 * 3) * fine
        val w = (r * 2.6).toInt(); val h = (r * 3.4).toInt() + 8 * fine
        val c = Canvas(w, h)
        val base = h - 12.0 * fine
        val cy = h - r * 1.9
        val seed = variant * 131 + size * 7 + (if (deep) 3 else 0)
        val cx = w / 2.0 + (rnd(seed, 1, 30) - 0.5) * r * 0.2
        val tw = r * (if (deep) 0.24 else 0.2)
        val crownBottom = cy + r * 0.7
        trunk(c, w / 2.0, base, cy + r * 0.2, tw, variant * 31 + size, BARK, crownBottom, fine)
        // boughs from the top of the trunk into the crown, seen in its gaps
        for (k in 0 until 4) {
            val a = -PI / 2 + (k - 1.5) * 0.55 + (rnd(seed, k, 31) - 0.5) * 0.3
            val ax = w / 2.0; val ay = cy + r * 0.35
            limb(c, ax, ay, -r * 0.1, ax + cos(a) * r * 0.75, ay + sin(a) * r * 0.65, -r * 0.2 + rnd(seed, k, 32) * r * 0.3,
                tw * 0.32, tw * 0.1, BARK, seed + k, fine) { _, _ -> 0.35 }
        }
        val tones = when { deep -> LEAF_DEEP; variant % 4 == 3 -> LEAF_OLIVE; else -> LEAF }
        // some oaks wide and low, some tall
        val squash = 0.74 + (variant % 3) * 0.07
        crown(c, cx, cy, r, tones, seed, squash, fine = fine)
        if (ink) ink(c, fine)
        return MapFlora.Sprite(c.img, w / 2, base.toInt())
    }

    /** A spruce in drooping tiers, as [MapFlora.spruce]. */
    fun spruce(variant: Int, size: Int, young: Boolean, fine: Int = 1, ink: Boolean = false): MapFlora.Sprite {
        val r = (if (young) S * (0.38 + size * 0.06) + variant % 2 * 2 else S * (0.78 + size * 0.14) + variant % 2 * 3) * fine
        val w = (r * 2.1).toInt(); val h = (r * 3.9).toInt()
        val c = Canvas(w, h)
        val base = h - 5.0 * fine
        val cx = w / 2.0
        val seed = variant * 17 + size * 3 + (if (young) 50 else 0)
        trunk(c, cx, base, base - r * 0.9, r * 0.17, seed, BARK, base - r * 0.5, fine)
        val tiers = if (young) 4 else 6
        val topY = base - r * 3.55
        // from the bottom up: each tier above hangs over the one below
        for (k in 0 until tiers) {
            val f = k / (tiers - 1.0)
            val ty = base - r * 0.42 - f * (base - r * 0.42 - topY - r * 0.75)
            val half = r * (1.0 - f * 0.72) * (0.92 + rnd(seed, k, 1) * 0.16)
            val hh = r * (0.95 - f * 0.25)
            val apexY = ty - hh
            for (y in (apexY - 2 * fine).toInt()..(ty + r * 0.18).toInt()) for (x in (cx - half - 4 * fine).toInt()..(cx + half + 4 * fine).toInt()) {
                val rel = ((y + 0.5 - apexY) / hh)
                if (rel < 0) continue
                // the skirt widens downwards and hangs in tips at its rim
                val tip = (sin((x - cx) / fine * 0.75 + seed + k * 1.7) * 0.5 + 0.5).let { it * it } * r * 0.16
                val bottom = ty + tip * (abs(x - cx) / half).coerceIn(0.3, 1.0)
                if (y + 0.5 > bottom) continue
                val edge = half * min(1.0, rel) * (1 + 0.1 * sin((y.toDouble() / fine) * 0.9 + k * 3 + variant))
                val e = (x + 0.5 - cx) / edge
                if (abs(e) > 1) continue
                val nzc = sqrt(1 - e * e)
                // the needles hang: near the rim the tier faces the viewer, near the trunk the sky
                val droop = rel.coerceAtMost(1.0)
                val n = norm(e * 0.85, -0.65 + droop * 0.9, nzc * 0.7 + 0.25)
                var i = 0.12 + 0.88 * light(n[0], n[1], n[2])
                // needle strands running down and outwards
                val strand = vnoise(((x - cx) * 1.6 - y * 0.6 * (if (x < cx) -1 else 1)) / fine, y * 0.4 / fine, 1.7, seed + k)
                i += (strand - 0.5) * 0.55
                // under the tier above lies shade
                if (k < tiers - 1 && rel < 0.45) i -= (0.45 - rel) * 0.6
                i -= (1 - f) * 0.06
                c.plot(x, y, k * 1000.0 + nzc * edge, i, PINE)
            }
        }
        if (ink) ink(c, fine)
        return MapFlora.Sprite(c.img, w / 2, base.toInt())
    }

    /** A dead tree, grey and bare, as [MapFlora.deadTree]. */
    fun deadTree(variant: Int, fine: Int = 1, ink: Boolean = false): MapFlora.Sprite {
        val r = S * 1.0 * fine
        val w = (r * 2.6).toInt(); val h = (r * 3.4).toInt() + 8 * fine
        val c = Canvas(w, h)
        val base = h - 12.0 * fine
        val seed = variant * 5 + 900
        var n = 0
        fun branch(x: Double, y: Double, z: Double, a: Double, len: Double, wd: Double, depth: Int) {
            if (len < 5 * fine || wd < 1.0 * fine || depth > 6) return
            val az = (rnd(seed, n, 22) - 0.5) * len * 0.8
            val x2 = x + cos(a) * len; val y2 = y + sin(a) * len
            limb(c, x, y, z, x2, y2, z + az, wd / 2, wd * 0.36, DEAD, seed + n, fine)
            val forks = if (rnd(seed, n, 23) < 0.25) 1 else 2
            for (k in 0 until forks) {
                n++
                // now and then a bough broken off short
                val broken = depth > 0 && rnd(seed, n, 24) < 0.1
                val turn = (if (forks == 1) (rnd(seed, n, 21) - 0.5) * 0.6 else (if (k == 0) -1 else 1) * (0.35 + rnd(seed, n, 21) * 0.4))
                branch(x2, y2, z + az, a + turn, if (broken) len * 0.3 else len * 0.8, wd * 0.7, if (broken) 9 else depth + 1)
            }
        }
        val topY = base - r * 0.75
        trunk(c, w / 2.0, base, topY, r * 0.2, seed, DEAD, -1.0, fine)
        branch(w / 2.0, topY + 4 * fine, 0.0, -PI / 2 + (rnd(seed, 0, 25) - 0.5) * 0.4, r * 0.5, r * 0.19, 0)
        n += 40
        branch(w / 2.0, base - r * 0.55, 0.0, -PI / 2 + (if (variant % 2 == 0) -1 else 1) * 0.9, r * 0.45, r * 0.11, 2)
        if (ink) ink(c, fine)
        return MapFlora.Sprite(c.img, w / 2, base.toInt())
    }
}
