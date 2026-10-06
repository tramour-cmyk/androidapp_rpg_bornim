package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * A color ramp from deep shadow to highlight. Shadows drift towards blue-violet and highlights
 * towards warm yellow, the way pixel artists build their palettes, so even grey looks alive.
 */
class Ramp(private val c: IntArray) {
    val size: Int get() = c.size
    operator fun get(i: Int): Int = c[i.coerceIn(0, c.size - 1)]
    val dark: Int get() = c[0]
    val mid: Int get() = c[3]
    val light: Int get() = c[c.size - 1]

    companion object {
        /** [hue] rotates the base color (degrees), [sat] scales its saturation, [value] its brightness. */
        fun of(rgb: Int, hue: Double = 0.0, sat: Double = 1.0, value: Double = 1.0): Ramp {
            val hsv = toHsv(rgb)
            val h0 = (hsv[0] + hue + 360) % 360
            val s0 = (hsv[1] * sat).coerceIn(0.0, 1.0)
            val v0 = (hsv[2] * value).coerceIn(0.0, 1.0)
            val out = IntArray(6) { i ->
                val d = i / 5.0 - 0.6
                val v = if (d < 0) v0 * (1 + d * 1.15) else v0 + (1 - v0) * d * 1.3 + v0 * d * 0.25
                val s = if (d < 0) s0 * (1 - d * 0.45) + 0.04 else s0 * (1 - d * 1.3)
                val h = if (d < 0) towards(h0, 255.0, -d * 45) else towards(h0, 55.0, d * 50)
                fromHsv(h, s.coerceIn(0.0, 1.0), v.coerceIn(0.0, 1.0))
            }
            return Ramp(out)
        }

        private fun towards(h: Double, target: Double, amount: Double): Double {
            var diff = (target - h + 540) % 360 - 180
            if (abs(diff) < amount) return target
            diff = if (diff > 0) amount else -amount
            return (h + diff + 360) % 360
        }

        fun toHsv(rgb: Int): DoubleArray {
            val r = ((rgb shr 16) and 0xFF) / 255.0
            val g = ((rgb shr 8) and 0xFF) / 255.0
            val b = (rgb and 0xFF) / 255.0
            val mx = max(r, max(g, b)); val mn = min(r, min(g, b))
            val d = mx - mn
            val h = when {
                d == 0.0 -> 0.0
                mx == r -> 60 * (((g - b) / d) % 6)
                mx == g -> 60 * ((b - r) / d + 2)
                else -> 60 * ((r - g) / d + 4)
            }
            return doubleArrayOf((h + 360) % 360, if (mx == 0.0) 0.0 else d / mx, mx)
        }

        fun fromHsv(h: Double, s: Double, v: Double): Int {
            val c = v * s
            val x = c * (1 - abs((h / 60) % 2 - 1))
            val m = v - c
            val (r, g, b) = when ((h / 60).toInt() % 6) {
                0 -> Triple(c, x, 0.0); 1 -> Triple(x, c, 0.0); 2 -> Triple(0.0, c, x)
                3 -> Triple(0.0, x, c); 4 -> Triple(x, 0.0, c); else -> Triple(c, 0.0, x)
            }
            fun ch(f: Double) = ((f + m) * 255).toInt().coerceIn(0, 255)
            return argb((ch(r) shl 16) or (ch(g) shl 8) or ch(b))
        }

        /** Shifts the hue of a single color. */
        fun hueShift(rgb: Int, hue: Double, sat: Double = 1.0, value: Double = 1.0): Int {
            val hsv = toHsv(rgb)
            return (rgb and (0xFF shl 24)) or (fromHsv((hsv[0] + hue + 360) % 360, (hsv[1] * sat).coerceIn(0.0, 1.0), (hsv[2] * value).coerceIn(0.0, 1.0)) and 0xFFFFFF)
        }
    }
}

/** Options for how a shape is lit. */
data class Mat(
    val ramp: Ramp,
    /** Specular strength: 0 for fur and skin, ~0.6 for metal, 1 for slime and eyes. */
    val shine: Double = 0.0,
    /** Random brightness noise for fur, scales or stone. */
    val grain: Double = 0.0,
    /** Shifts the brightness, e.g. negative for limbs on the far side. */
    val bias: Double = 0.0,
    /** Dark line where the shape overlaps something already drawn. */
    val inline: Boolean = true,
)

/**
 * Procedural sprite painter with real lighting: shapes carry surface normals, are lit from the
 * top left, quantized to their [Ramp] with ordered dithering and finished with a colored outline.
 * Coordinates are sprite pixels (doubles); [moveTo]/[scale] transform everything that follows.
 */
class Sculpt(val w: Int, val h: Int, private val seed: Int = 0) {
    val img = PixelImage(w, h)
    private val lx: Double; private val ly: Double; private val lz: Double
    private val hx: Double; private val hy: Double; private val hz: Double

    init {
        val l = norm(-0.55, -0.7, 0.55)
        lx = l[0]; ly = l[1]; lz = l[2]
        val hv = norm(lx, ly, lz + 1)
        hx = hv[0]; hy = hv[1]; hz = hv[2]
    }

    // ---------------------------------------------------------------- transform

    private var dx = 0.0
    private var dy = 0.0
    private var sx = 1.0
    private var sy = 1.0
    private var px = w / 2.0
    private var py = h.toDouble()

    /** Everything drawn afterwards is shifted by (x, y) and scaled around the pivot (feet). */
    fun transform(x: Double = 0.0, y: Double = 0.0, scaleX: Double = 1.0, scaleY: Double = scaleX, pivotX: Double = w / 2.0, pivotY: Double = h - 2.0) {
        dx = x; dy = y; sx = scaleX; sy = scaleY; px = pivotX; py = pivotY
    }

    private fun tx(x: Double) = px + (x + dx - px) * sx
    private fun ty(y: Double) = py + (y + dy - py) * sy

    // ---------------------------------------------------------------- shading core

    private fun norm(x: Double, y: Double, z: Double): DoubleArray {
        val l = sqrt(x * x + y * y + z * z).coerceAtLeast(1e-9)
        return doubleArrayOf(x / l, y / l, z / l)
    }

    private val bayer = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)

    private fun noise(x: Int, y: Int, s: Int): Double {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return ((n xor (n ushr 16)) and 0xFFFF) / 65535.0
    }

    /** Brightness 0..1 of a surface normal. */
    private fun intensity(nx: Double, ny: Double, nz: Double, m: Mat, x: Int, y: Int): Double {
        val d = nx * lx + ny * ly + nz * lz
        var i = 0.12 + 0.8 * max(0.0, d) + 0.1 * nz + m.bias
        if (m.shine > 0) i += m.shine * max(0.0, nx * hx + ny * hy + nz * hz).pow(24) * 0.9
        if (m.grain > 0) i += (noise(x, y, seed + 7) - 0.5) * m.grain
        return i
    }

    private fun quantize(i: Double, ramp: Ramp, x: Int, y: Int): Int {
        val steps = ramp.size - 1
        val dither = (bayer[(y and 3) * 4 + (x and 3)] / 16.0 - 0.47) * 0.7
        return floor(i * steps + 0.5 + dither).toInt().coerceIn(0, steps)
    }

    /**
     * Paints all pixels for which [normal] returns true. The callback receives the pixel centre in
     * sprite coordinates and stores the unit normal into [n].
     */
    private inline fun paint(x0: Double, y0: Double, x1: Double, y1: Double, m: Mat, crossinline normal: (Double, Double, DoubleArray) -> Boolean) {
        val n = DoubleArray(3)
        val probe = DoubleArray(3)
        val minX = floor(min(x0, x1)).toInt().coerceAtLeast(0)
        val maxX = floor(max(x0, x1)).toInt().coerceAtMost(w - 1)
        val minY = floor(min(y0, y1)).toInt().coerceAtLeast(0)
        val maxY = floor(max(y0, y1)).toInt().coerceAtMost(h - 1)
        for (y in minY..maxY) for (x in minX..maxX) {
            val cx = x + 0.5; val cy = y + 0.5
            if (!normal(cx, cy, n)) continue
            var idx = quantize(intensity(n[0], n[1], n[2], m, x, y), m.ramp, x, y)
            if (m.inline) {
                // Where this shape ends on top of something else, draw a soft inner line.
                val edge = (!normal(cx + 1, cy, probe) && img.opaque(x + 1, y)) ||
                    (!normal(cx, cy + 1, probe) && img.opaque(x, y + 1)) ||
                    (!normal(cx - 1, cy, probe) && img.opaque(x - 1, y)) ||
                    (!normal(cx, cy - 1, probe) && img.opaque(x, y - 1))
                if (edge) idx = min(idx, 1)
            }
            img.set(x, y, m.ramp[idx])
        }
    }

    /** Ramp index of a surface with normal (nx right, ny down, nz towards us) at pixel (x, y), lit and dithered like every shape. */
    fun litIndex(x: Int, y: Int, nx: Double, ny: Double, nz: Double, m: Mat): Int = quantize(intensity(nx, ny, nz, m, x, y), m.ramp, x, y)

    // ---------------------------------------------------------------- shapes

    /** Ellipsoid, optionally rotated by [rot] radians. [depth] < 1 flattens it (rounder light falloff). */
    fun blob(cx: Double, cy: Double, rx: Double, ry: Double, m: Mat, rot: Double = 0.0, depth: Double = 1.0) {
        val ccx = tx(cx); val ccy = ty(cy); val rrx = rx * sx; val rry = ry * sy
        val c = cos(rot); val s = sin(rot)
        val r = max(rrx, rry) + 1
        paint(ccx - r, ccy - r, ccx + r, ccy + r, m) { x, y, n ->
            val ux = ((x - ccx) * c + (y - ccy) * s) / rrx
            val uy = (-(x - ccx) * s + (y - ccy) * c) / rry
            val q = ux * ux + uy * uy
            if (q > 1) return@paint false
            val nz = sqrt(1 - q) * depth
            // rotate the normal back
            val nx = ux * c - uy * s
            val ny = ux * s + uy * c
            val l = sqrt(nx * nx + ny * ny + nz * nz).coerceAtLeast(1e-9)
            n[0] = nx / l; n[1] = ny / l; n[2] = nz / l
            true
        }
    }

    /** A rounded cone from (ax, ay) with radius [ra] to (bx, by) with radius [rb]: limbs, tails, horns. */
    fun limb(ax: Double, ay: Double, bx: Double, by: Double, ra: Double, rb: Double, m: Mat) {
        val x0 = tx(ax); val y0 = ty(ay); val x1 = tx(bx); val y1 = ty(by)
        val s = (sx + sy) / 2
        val r0 = ra * s; val r1 = rb * s
        val vx = x1 - x0; val vy = y1 - y0
        val len2 = (vx * vx + vy * vy).coerceAtLeast(1e-9)
        val r = max(r0, r1) + 1
        paint(min(x0, x1) - r, min(y0, y1) - r, max(x0, x1) + r, max(y0, y1) + r, m) { x, y, n ->
            val t = (((x - x0) * vx + (y - y0) * vy) / len2).coerceIn(0.0, 1.0)
            val cx = x0 + vx * t; val cy = y0 + vy * t
            val rr = r0 + (r1 - r0) * t
            val ex = x - cx; val ey = y - cy
            val d2 = ex * ex + ey * ey
            if (d2 > rr * rr) return@paint false
            val nz = sqrt(1 - d2 / (rr * rr))
            n[0] = ex / rr; n[1] = ey / rr; n[2] = nz
            true
        }
    }

    /** A chain of limbs through the given points (x, y, radius triples): tails, tentacles, bodies. */
    fun chain(m: Mat, vararg p: Double) {
        var i = 0
        while (i + 5 < p.size) {
            limb(p[i], p[i + 1], p[i + 3], p[i + 4], p[i + 2], p[i + 5], m)
            i += 3
        }
    }

    /**
     * A polygon (x, y pairs). It faces the direction ([tiltX], [tiltY]); edges are rounded over
     * [bevel] pixels, which makes blades, armor plates and ears look solid.
     */
    fun poly(m: Mat, vararg pts: Double, tiltX: Double = 0.0, tiltY: Double = 0.0, bevel: Double = 1.5) {
        val n = pts.size / 2
        val xs = DoubleArray(n) { tx(pts[it * 2]) }
        val ys = DoubleArray(n) { ty(pts[it * 2 + 1]) }
        val bz = sqrt((1 - tiltX * tiltX - tiltY * tiltY).coerceAtLeast(0.05))
        // orientation, to know which side of an edge is outside
        var area = 0.0
        for (i in 0 until n) { val j = (i + 1) % n; area += xs[i] * ys[j] - xs[j] * ys[i] }
        val sign = if (area > 0) 1.0 else -1.0
        paint(xs.min() - 1, ys.min() - 1, xs.max() + 1, ys.max() + 1, m) { x, y, out ->
            var inside = false
            var j = n - 1
            for (i in 0 until n) {
                if ((ys[i] > y) != (ys[j] > y) && x < (xs[j] - xs[i]) * (y - ys[i]) / (ys[j] - ys[i]) + xs[i]) inside = !inside
                j = i
            }
            if (!inside) return@paint false
            var best = Double.MAX_VALUE; var ox = 0.0; var oy = 0.0
            for (i in 0 until n) {
                val k = (i + 1) % n
                val ex = xs[k] - xs[i]; val ey = ys[k] - ys[i]
                val l2 = (ex * ex + ey * ey).coerceAtLeast(1e-9)
                val t = (((x - xs[i]) * ex + (y - ys[i]) * ey) / l2).coerceIn(0.0, 1.0)
                val qx = x - (xs[i] + ex * t); val qy = y - (ys[i] + ey * t)
                val d = sqrt(qx * qx + qy * qy)
                if (d < best) {
                    best = d
                    val l = sqrt(l2)
                    ox = sign * ey / l; oy = -sign * ex / l
                }
            }
            var nx = tiltX; var ny = tiltY; var nz = bz
            if (bevel > 0 && best < bevel) {
                val f = (1 - best / bevel) * 0.85
                nx += ox * f; ny += oy * f; nz -= f * 0.4
            }
            val l = sqrt(nx * nx + ny * ny + nz * nz).coerceAtLeast(1e-9)
            out[0] = nx / l; out[1] = ny / l; out[2] = nz / l
            true
        }
    }

    /** A thin line in a fixed color (whiskers, strings, cracks). */
    fun line(ax: Double, ay: Double, bx: Double, by: Double, c: Int) {
        val x0 = tx(ax); val y0 = ty(ay); val x1 = tx(bx); val y1 = ty(by)
        val steps = max(abs(x1 - x0), abs(y1 - y0)).toInt().coerceAtLeast(1) * 2
        for (i in 0..steps) {
            val t = i.toDouble() / steps
            img.set(floor(x0 + (x1 - x0) * t).toInt(), floor(y0 + (y1 - y0) * t).toInt(), c)
        }
    }

    fun dot(x: Double, y: Double, c: Int) = img.set(floor(tx(x)).toInt(), floor(ty(y)).toInt(), c)

    /** Unlit filled ellipse in one color (glows, pupils, markings). */
    fun flat(cx: Double, cy: Double, rx: Double, ry: Double, c: Int) {
        val ccx = tx(cx); val ccy = ty(cy); val rrx = rx * sx; val rry = ry * sy
        for (y in floor(ccy - rry).toInt()..floor(ccy + rry).toInt()) for (x in floor(ccx - rrx).toInt()..floor(ccx + rrx).toInt()) {
            val ux = (x + 0.5 - ccx) / rrx; val uy = (y + 0.5 - ccy) / rry
            if (ux * ux + uy * uy <= 1) img.set(x, y, c)
        }
    }

    /** A glossy eye: iris color, dark pupil and a white glint. */
    fun eye(x: Double, y: Double, r: Double, iris: Int, pupil: Boolean = true) {
        flat(x, y, r, r, iris)
        if (pupil && r >= 1.2) flat(x + r * 0.25, y + r * 0.1, r * 0.5, r * 0.6, argb(0x141018))
        dot(x - r * 0.35, y - r * 0.4, Pal.WHITE)
    }

    /** Recolors already painted pixels inside an ellipse by blending with [c] (war paint, scars, glows). */
    fun tint(cx: Double, cy: Double, rx: Double, ry: Double, c: Int, a: Double) {
        val ccx = tx(cx); val ccy = ty(cy); val rrx = rx * sx; val rry = ry * sy
        for (y in floor(ccy - rry).toInt()..floor(ccy + rry).toInt()) for (x in floor(ccx - rrx).toInt()..floor(ccx + rrx).toInt()) {
            val ux = (x + 0.5 - ccx) / rrx; val uy = (y + 0.5 - ccy) / rry
            if (ux * ux + uy * uy <= 1 && img.opaque(x, y)) img.set(x, y, mix(img[x, y], c, a))
        }
    }

    // ---------------------------------------------------------------- finishing

    /** A cool light from behind on the right edges, which separates the sprite from the backdrop. */
    fun rim(c: Int = argb(0xBFE4FF), a: Double = 0.35) {
        val src = img.copy()
        for (y in 0 until h) for (x in 0 until w) {
            if (!src.opaque(x, y)) continue
            if (!src.opaque(x + 1, y) || !src.opaque(x + 1, y - 1)) img.set(x, y, mix(src[x, y], c, a))
        }
    }

    /** Selective outline: a darkened version of the neighbouring color instead of plain black. */
    fun outline(dark: Int = Pal.OUTLINE) {
        val src = img.copy()
        for (y in 0 until h) for (x in 0 until w) {
            if (src.opaque(x, y)) continue
            val n = when {
                src.opaque(x, y + 1) -> src[x, y + 1] to 0.62
                src.opaque(x + 1, y) -> src[x + 1, y] to 0.62
                src.opaque(x - 1, y) -> src[x - 1, y] to 0.78
                src.opaque(x, y - 1) -> src[x, y - 1] to 0.8
                else -> null
            } ?: continue
            img.set(x, y, mix(n.first or (0xFF shl 24), dark, n.second))
        }
    }

    companion object {
        /** Point at [len] from (x, y) in direction [deg] (0 = right, 90 = down). */
        fun polarX(x: Double, len: Double, deg: Double) = x + cos(Math.toRadians(deg)) * len
        fun polarY(y: Double, len: Double, deg: Double) = y + sin(Math.toRadians(deg)) * len
        fun angle(ax: Double, ay: Double, bx: Double, by: Double) = Math.toDegrees(atan2(by - ay, bx - ax))
    }
}
