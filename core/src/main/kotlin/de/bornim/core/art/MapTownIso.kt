package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/**
 * Bornim's houses seen diagonally (5.1, draft, only in the preview ISODINGE=dorf): a house stands on its
 * footprint of n tiles along the map's x (i, down right) and d tiles along its y (j, down left); its front
 * with the door faces +j (down left), its east side +i (down right), the roof's ridge runs along i, a gable
 * at either end. Timber frame and weathered plaster on a footing of field stones, thatch gone grey with moss
 * (or the temple's slate), a stone chimney where the hearth stands inside.
 * Same projection and heights as the rooms ([MapRoomIso]): 90 × 45 art pixels a tile, 57 to a metre upright.
 */
object MapTownIso {
    private const val TW = MapRoomIso.TW
    private const val TH = MapRoomIso.TH
    private const val ZS = MapRoomIso.ZS
    /** Upright drawing units per tile (a tile is 116 cm, 57 units to the metre). */
    private const val ZT = 66.0

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0
    private fun frac(v: Double) = v - floor(v)
    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }
    private fun vnoise(x: Double, y: Double, s: Int): Double {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        var u = x - ix; var v = y - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    /** One of three looks of a plain house (the temple has its own). */
    class Look(
        val plaster: Int, val plasterDark: Int, val timber: Int, val thatch: Int, val moss: Double,
        /** the ground floor of field stone up to this height (0: only the footing) */
        val stoneTo: Double,
        /** the gables boarded instead of framed */
        val boards: Boolean,
    )
    val looks = listOf(
        Look(0x8C8270, 0x332D25, 0x3E2E22, 0x7A6C4E, 0.55, 0.0, false),
        Look(0x82745A, 0x2E271E, 0x2C2018, 0x6A5C42, 0.3, 0.0, true),
        Look(0x86807A, 0x302C28, 0x3A2C22, 0x5E5644, 0.75, 70.0, false),
    )

    /**
     * A house picture. [front] the wall along the front, one letter a tile ('#' wall, 'W' window, 'D' door);
     * [side] the east wall the same way; [d] tiles deep; [chimney] the tile along i over which the chimney stands
     * (−1: none); [night] lit windows. The front corner of the footprint (i = n, j = d) lies at ([anchorX], height).
     */
    class Picture(val img: PixelImage, val anchorX: Int)

    fun house(front: String, side: String, d: Int, look: Int, seed: Int, chimney: Int = -1, night: Boolean = false, slate: Boolean = false): Picture {
        val n = front.length
        val lk = looks[look % looks.size]
        val eave = 150.0                           // eaves at 2.6 m
        val o = 0.28                               // the roof hangs over the walls
        val pitch = if (slate) 1.05 else 1.25      // rise per run: thatch steeper than slate
        val ridge = eave + (d / 2.0 + o) * ZT * pitch
        val chimTop = ridge + 46
        // the picture: from the back corner (0, 0) at the top of the ridge to the front corner (n, d) on the ground
        val left = d + o + 0.2; val right = n + o + 0.2
        val w = ((left + right) * TW / 2).toInt() + 4
        val topZ = max(ridge + (if (slate) 96 else 0), if (chimney >= 0) chimTop else 0.0) + 8
        val h = ((n + d) * TH / 2 + topZ * ZS + o * TH + 12).toInt()
        val img = PixelImage(w, h)
        val ox = left * TW / 2 + 2                // screen x of i = j = 0
        val oy = h - 8 - (n + d) * TH / 2         // screen y of i = j = 0 on the ground
        fun sx(i: Double, j: Double) = ox + (i - j) * TW / 2
        fun sy(i: Double, j: Double, z: Double) = oy + (i + j) * TH / 2 - z * ZS

        /** Fills the plane through p0 spanned by a (u 0..1) and b (v 0..1), in (i, j, z), each pixel by [tex]. */
        fun plane(p0: DoubleArray, a: DoubleArray, b: DoubleArray, tex: (Double, Double) -> Int?) {
            val x0 = sx(p0[0], p0[1]); val y0 = sy(p0[0], p0[1], p0[2])
            val ax = (a[0] - a[1]) * TW / 2; val ay = (a[0] + a[1]) * TH / 2 - a[2] * ZS
            val bx = (b[0] - b[1]) * TW / 2; val by = (b[0] + b[1]) * TH / 2 - b[2] * ZS
            val det = ax * by - ay * bx
            if (abs(det) < 1e-6) return
            val xs = listOf(x0, x0 + ax, x0 + bx, x0 + ax + bx); val ys = listOf(y0, y0 + ay, y0 + by, y0 + ay + by)
            for (py in max(0, floor(ys.min()).toInt()) until min(h, ys.max().toInt() + 1))
                for (px in max(0, floor(xs.min()).toInt()) until min(w, xs.max().toInt() + 1)) {
                    val dx = px + 0.5 - x0; val dy = py + 0.5 - y0
                    val u = (dx * by - dy * bx) / det; val v = (ax * dy - ay * dx) / det
                    if (u < 0 || u > 1 || v < 0 || v > 1) continue
                    tex(u, v)?.let { img.set(px, py, it) }
                }
        }
        fun p(i: Double, j: Double, z: Double) = doubleArrayOf(i, j, z)

        // ---- a soft shadow on the ground, falling down left of the house (the sun stands up right)
        for (py in 0 until h) for (px in 0 until w) {
            val aa = (px + 0.5 - ox) / (TW / 2); val bb = (py + 0.5 - oy) / (TH / 2)
            val i = (aa + bb) / 2; val j = (bb - aa) / 2
            val di = max(-0.2 - i, i - n - 0.1); val dj = max(-0.2 - j, j - d - 0.55)
            val e = max(di, dj)
            if (e > 0.35) continue
            val k = ((0.35 - e) / 0.35).coerceIn(0.0, 1.0) * 0.55
            img.set(px, py, ((k * 255).toInt() shl 24) or 0x0A0806)
        }

        // ---- the walls: the front (j = d, down left, in the house's own shade) and the east side (i = n, in the sun)
        val litFront = 0.72; val litSide = 1.0
        fun wall(u: Double, z: Double, len: Int, letters: String, face: Double, s: Int, gableTop: Double): Int? {
            val tile = floor(u).toInt().coerceIn(0, len - 1); val f = u - tile
            val kind = letters.getOrElse(tile) { '#' }
            if (kind == 'D') (if (slate) archDoor(f, z, face, s) else door(f, z, face, s))?.let { return it }
            if (kind == 'W') (if (slate) archWindow(f, z, face, night) else window(f, z, face, night, s + tile))?.let { return it }
            if (slate) return ashlarTex(u, z, face, s)
            return wallTex(u, z, face, s, lk, gableTop)
        }
        plane(p(0.0, d.toDouble(), 0.0), p(n.toDouble(), 0.0, 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * n, v * eave, n, front, litFront, seed, eave) }
        plane(p(n.toDouble(), 0.0, 0.0), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * d, v * eave, d, side, litSide, seed + 31, eave) }
        // the east gable: a triangle over the side wall, up to the ridge in the middle
        plane(p(n.toDouble(), 0.0, eave), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, ridge - eave)) { u, v ->
            val z = v * (ridge - eave)
            val half = 1 - z / (ridge - eave)
            if (abs(u - 0.5) > half * 0.5) null
            else if (lk.boards || slate) boards(u * d, eave + z, litSide * 0.94, seed + 7, slate)
            else wallTex(u * d, eave + z, litSide, seed + 31, lk, ridge)
        }

        // ---- the roof: the slope towards us, from the ridge down to the eaves hanging over the front
        val run = d / 2.0 + o
        val ri0 = -o; val ri1 = n + o
        fun roofTex(u: Double, v: Double): Int {
            // u along the ridge 0..1, v down the slope 0..1
            val along = u * (ri1 - ri0); val down = v * run
            if (slate) return slateTex(along, down, run, seed)
            return thatchTex(along, down, run, lk, seed)
        }
        // the edge of the thatch, thick at the eaves and along the gable: a band under the slope
        val thick = if (slate) 4.0 else 16.0
        plane(p(ri0, d + o, eave - thick), p(ri1 - ri0, 0.0, 0.0), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * (ri1 - ri0), v, slate, lk, seed) }
        plane(p(ri1, d / 2.0, ridge - thick), p(0.0, run, eave - ridge), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * run * 2, v, slate, lk, seed + 3) }
        plane(p(ri0, d / 2.0, ridge), p(ri1 - ri0, 0.0, 0.0), p(0.0, run, eave - ridge)) { u, v -> roofTex(u, v) }
        // the ridge itself: a rolled band of thatch (or ridge tiles) along the top
        plane(p(ri0 + 0.05, d / 2.0 - 0.06, ridge + 5), p(ri1 - ri0 - 0.1, 0.0, 0.0), p(0.0, 0.16, -10.0)) { u, v ->
            val t = 0.5 + 0.3 * (1 - v) + (rnd(floor(u * 60).toInt(), 0, seed + 9) - 0.5) * 0.15
            if (slate) shade(argb(0x2A2E34), 0.8 + t * 0.4) else shade(mix(argb(0x2A2418), argb(lk.thatch), t), 0.9)
        }

        // ---- the chimney: rough stones, a dark mouth, soot down its face
        if (chimney >= 0) {
            val ci0 = chimney + 0.32; val ci1 = ci0 + 0.36
            val cj0 = d / 2.0 - 0.1; val cj1 = cj0 + 0.36
            val zBase = ridge - (cj1 - d / 2.0) / run * (ridge - eave) - 4
            plane(p(ci0, cj1, zBase), p(ci1 - ci0, 0.0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (ci1 - ci0), zBase + v * (chimTop - zBase), litFront, seed + 41, chimTop), 0.75 - 0.25 * v) }
            plane(p(ci1, cj0, zBase), p(0.0, cj1 - cj0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (cj1 - cj0) + 3, zBase + v * (chimTop - zBase), litSide, seed + 43, chimTop), 0.75 - 0.25 * v) }
            plane(p(ci0, cj0, chimTop), p(ci1 - ci0, 0.0, 0.0), p(0.0, cj1 - cj0, 0.0)) { u, v ->
                val rim = u < 0.18 || u > 0.82 || v < 0.18 || v > 0.82
                if (rim) shade(argb(0x6A645A), 0.9 + rnd(floor(u * 9).toInt(), floor(v * 9).toInt(), seed) * 0.2) else argb(0x0E0C0A)
            }
        }
        // ---- the temple: a small bell cote of stone on the ridge over the east gable, the bell dark in its arch
        if (slate) {
            val bi0 = n - 0.55; val bi1 = n - 0.1; val bj0 = d / 2.0 - 0.22; val bj1 = d / 2.0 + 0.22
            val z0 = ridge - 20; val z1 = ridge + 70
            plane(p(bi0, bj1, z0), p(bi1 - bi0, 0.0, 0.0), p(0.0, 0.0, z1 - z0)) { u, v ->
                val z = z0 + v * (z1 - z0)
                val open = abs(u - 0.5) < 0.28 && z > ridge + 12 && z < ridge + 44 + 10 * Math.sqrt((1 - ((u - 0.5) / 0.28).let { it * it }).coerceAtLeast(0.0))
                if (open) { if (abs(u - 0.5) < 0.14 && z > ridge + 22 && z < ridge + 44) shade(argb(0x5A4A2E), 0.7 + (z - ridge - 22) / 60) else argb(0x0C0A0A) }
                else ashlarTex(u * 0.45, z, litFront, seed + 51)
            }
            plane(p(bi1, bj0, z0), p(0.0, bj1 - bj0, 0.0), p(0.0, 0.0, z1 - z0)) { u, v -> ashlarTex(u * 0.44 + 2, z0 + v * (z1 - z0), litSide, seed + 53) }
            // its little pointed cap
            plane(p(bi0 - 0.05, bj1 + 0.05, z1), p(bi1 - bi0 + 0.1, 0.0, 0.0), p(0.0, -(bj1 - bj0 + 0.1) / 2, 26.0)) { u, v -> if (abs(u - 0.5) > 0.5 * (1 - v)) null else shade(argb(0x3A3E44), 0.7 + v * 0.3) }
            plane(p(bi1 + 0.05, bj1 + 0.05, z1), p(0.0, -(bj1 - bj0 + 0.1), 0.0), p(-(bi1 - bi0 + 0.1) / 2, 0.0, 26.0)) { u, v -> if (abs(u - 0.5) > 0.5 * (1 - v)) null else shade(argb(0x4A4E54), 0.8 + v * 0.2) }
        }
        return Picture(img, sx(n.toDouble(), d.toDouble()).toInt())
    }

    // ------------------------------------------------------------------ textures

    /** Timber frame and weathered plaster, a footing of field stone (or a ground floor of it, [Look.stoneTo]). */
    private fun wallTex(u: Double, z: Double, face: Double, seed: Int, lk: Look, top: Double): Int {
        val footing = max(16.0, lk.stoneTo)
        if (z < footing) return stoneTex(u, z, face, seed, footing)
        // posts at every tile's edge and in its middle, a rail at the sill, braces in every other panel
        val pu = u * 2
        val post = abs(pu - Math.round(pu)) * 2 < 0.07
        val sill = z < footing + 6
        val rail = abs(z - 92) < 3.5
        val plate = z > 142 && z < 150
        val panel = floor(pu).toInt()
        val f = frac(pu)
        val braceUp = hash(panel, seed, 7) % 3
        val zz = (z - footing) / (92 - footing)
        val brace = braceUp != 0 && z < 92 && abs((if (braceUp == 1) f else 1 - f) - zz * 0.9 - 0.05) < 0.045
        if (post || sill || rail || plate || brace) {
            var v = 0.5 + (rnd(floor(u * 30).toInt(), floor(z / 3).toInt(), seed) - 0.5) * 0.35
            if (rail && z > 93 || plate && z > 148) v += 0.3
            return shade(mix(argb(0x150F0B), argb(lk.timber), v.coerceIn(0.0, 1.4)), face)
        }
        var v = 0.62 + (vnoise(u * 9, z / 9, seed + 1) - 0.5) * 0.28 + (rnd(floor(u * 50).toInt(), floor(z / 2).toInt(), seed + 2) - 0.5) * 0.08
        // rain runs down from the eaves, damp creeps up from the ground
        v -= 0.2 * vnoise(u * 14, 0.0, seed + 3) * ((z - 100) / 50).coerceIn(0.0, 1.0)
        v -= 0.25 * exp(-(z - footing) / 12)
        // the plaster has fallen off here and there, the wattle shows
        if (hash(panel, floor(z / 46).toInt(), seed + 4) % 5 == 0 && vnoise(u * 8, z / 7, seed + 5) > 0.68)
            return shade(if ((floor(z / 3).toInt() + floor(u * 24).toInt()) % 2 == 0) argb(0x4A3A28) else argb(0x2E2418), face)
        return shade(mix(argb(lk.plasterDark), argb(lk.plaster), v.coerceIn(0.0, 1.0)), face)
    }

    /** Field stones laid in rough courses, mortar dark in the joints, moss low down. */
    private fun stoneTex(u: Double, z: Double, face: Double, seed: Int, top: Double): Int {
        val course = floor(z / 9).toInt()
        val off = rnd(course, 1, seed) * 0.4
        val bw = 0.16 + rnd(course, 2, seed) * 0.08
        val block = floor(u / bw + off).toInt()
        var v = 0.5 + (rnd(block, course, seed + 3) - 0.5) * 0.4 + (rnd(floor(u * 60).toInt(), floor(z / 2).toInt(), seed + 4) - 0.5) * 0.1
        val jz = z % 9; val ju = frac(u / bw + off)
        if (jz < 1.4 || ju < 0.07) v -= 0.32
        else v += (1 - jz / 9) * 0.12           // the top of each stone catches light
        if (z > top - 2) v += 0.12
        val c = mix(argb(0x201E1A), argb(0x8A8478), v.coerceIn(0.0, 1.0))
        val moss = z < 10 && vnoise(u * 10, z / 4, seed + 5) > 0.55
        return shade(if (moss) mix(c, argb(0x3E4A26), 0.55) else c, face)
    }

    /** Dressed grey stone of the temple, larger blocks, soot and damp. */
    private fun ashlarTex(u: Double, z: Double, face: Double, seed: Int): Int {
        val course = floor(z / 13).toInt()
        val off = rnd(course, 3, seed) * 0.5
        val bw = 0.34 + rnd(course, 4, seed) * 0.1
        val block = floor(u / bw + off).toInt()
        var v = 0.5 + (rnd(block, course, seed + 11) - 0.5) * 0.22 + (rnd(floor(u * 50).toInt(), floor(z / 2).toInt(), seed + 12) - 0.5) * 0.08
        if (z % 13 < 1.5 || frac(u / bw + off) < 0.04) v -= 0.3
        v -= 0.2 * exp(-z / 14)
        v -= 0.15 * vnoise(u * 10, 0.0, seed + 13) * ((z - 90) / 60).coerceIn(0.0, 1.0)
        return shade(mix(argb(0x1E1C1A), argb(0x7E7A72), v.coerceIn(0.0, 1.0)), face)
    }

    /** The temple's tall window under a round arch: deep reveal, leaded panes; at night candlelight. */
    private fun archWindow(f: Double, z: Double, face: Double, night: Boolean): Int? {
        val r = 0.16; val spring = 104.0
        if (f < 0.5 - r || f > 0.5 + r || z < 46) return null
        val top = spring + 22 * Math.sqrt((1 - ((f - 0.5) / r).let { it * it }).coerceAtLeast(0.0))
        if (z > top) return null
        val inner = abs(f - 0.5) < r - 0.04 && z > 51 && z < top - 5
        if (!inner) return shade(argb(0x18161A), face)
        val a = (f - 0.5) * 34; val b = (z - 90) / 7
        if (abs(frac(a + b) - 0.5) > 0.44 || abs(frac(a - b) - 0.5) > 0.44) return argb(0x16161A)
        return if (night) mix(argb(0x6A3A14), argb(0xE8A858), 0.6 + frac(a * 0.37 + b * 0.21) * 0.4)
        else mix(argb(0x1A2028), argb(0x4A5666), ((z - 51) / 90).coerceIn(0.0, 1.0) * 0.7)
    }

    /** The temple's door: two leaves of dark oak under a round arch of stone. */
    private fun archDoor(f: Double, z: Double, face: Double, seed: Int): Int? {
        val r = 0.3
        if (abs(f - 0.5) > r || z > 128) return null
        val top = 92 + 34 * Math.sqrt((1 - ((f - 0.5) / r).let { it * it }).coerceAtLeast(0.0))
        if (z > top) return null
        if (z > top - 8 || abs(f - 0.5) > r - 0.05) return shade(argb(0x4A4640), face * (0.8 + rnd(floor(f * 14).toInt(), floor(z / 8).toInt(), seed) * 0.3))
        if (abs(f - 0.5) < 0.012) return shade(argb(0x0E0A08), face)
        val plank = floor(f * 20).toInt()
        var v = 0.45 + (rnd(plank, 0, seed + 1) - 0.5) * 0.25
        if (frac(f * 20) < 0.12) v -= 0.25
        if (abs(z - 34) < 2.5 || abs(z - 92) < 2.5) return shade(argb(0x24201C), face)
        return shade(mix(argb(0x120C08), argb(0x4A3426), v.coerceIn(0.0, 1.0)), face * 0.9)
    }

    /** Weathered boards on the gable (or the temple's stone gable). */
    private fun boards(u: Double, z: Double, face: Double, seed: Int, stone: Boolean): Int {
        if (stone) return ashlarTex(u, z, face, seed)
        val b = floor(u * 7).toInt()
        var v = 0.45 + (rnd(b, 0, seed) - 0.5) * 0.3 + (rnd(b, floor(z / 3).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(u * 7) < 0.12) v -= 0.3
        return shade(mix(argb(0x1A140E), argb(0x5E4A38), v.coerceIn(0.0, 1.0)), face)
    }

    /** A small window: deep reveal, a cross of wood, shutters folded back; at night warm light inside. */
    private fun window(f: Double, z: Double, face: Double, night: Boolean, seed: Int): Int? {
        if (z < 56 || z > 112 || f < 0.16 || f > 0.84) return null
        val shutter = f < 0.27 || f > 0.73
        if (shutter) {
            val v = 0.42 + (if (frac(f * 30) < 0.15) -0.2 else 0.0) + (rnd(floor(f * 30).toInt(), 0, seed) - 0.5) * 0.15
            return shade(mix(argb(0x14100C), argb(0x5A4636), v), face)
        }
        val frame = f < 0.31 || f > 0.69 || z < 61 || z > 107
        if (frame) return shade(if (z > 105 || f < 0.3) argb(0x18120E) else argb(0x3A2C20), face)
        if (abs(f - 0.5) < 0.018 || abs(z - 84) < 1.6) return shade(argb(0x2A2018), face)
        if (night) {
            val t = 0.7 + vnoise(f * 12, z / 6, seed) * 0.3
            return mix(argb(0x6A3A14), argb(0xF0B060), t)
        }
        // by day the glass is dark, with a little sky in its upper panes
        val t = ((z - 61) / 46).coerceIn(0.0, 1.0)
        return mix(argb(0x14181C), argb(0x4A5866), t * 0.6)
    }

    /** A heavy plank door under a lintel, iron straps, a worn step in front. */
    private fun door(f: Double, z: Double, face: Double, seed: Int): Int? {
        if (f < 0.24 || f > 0.76 || z > 118) return null
        val lintel = z > 110
        val jamb = f < 0.29 || f > 0.71
        if (lintel || jamb) return shade(mix(argb(0x150F0B), argb(0x46342A), 0.4 + rnd(floor(f * 20).toInt(), floor(z / 4).toInt(), seed) * 0.3), face)
        val plank = floor((f - 0.29) / 0.42 * 5).toInt()
        var v = 0.5 + (rnd(plank, 0, seed + 1) - 0.5) * 0.3 + (rnd(plank, floor(z / 2).toInt(), seed + 2) - 0.5) * 0.1
        if (frac((f - 0.29) / 0.42 * 5) < 0.1) v -= 0.3
        val strap = abs(z - 30) < 2.5 || abs(z - 86) < 2.5
        if (strap) return shade(argb(0x26221E), face * (0.9 + rnd(floor(f * 40).toInt(), 0, seed) * 0.2))
        if (abs(f - 0.64) < 0.02 && abs(z - 58) < 3) return shade(argb(0x6A6050), face)
        return shade(mix(argb(0x150F0B), argb(0x5A4232), v.coerceIn(0.0, 1.0)), face * (1 - 0.25 * (z / 118)))
    }

    /** Old thatch: bundles of reed in wavy courses down the slope, grey on top, moss in the hollows, a darker eave line. */
    private fun thatchTex(along: Double, down: Double, run: Double, lk: Look, seed: Int): Int {
        // courses about every 0.3 tiles down, their edges wavy where the bundles were tied
        val wave = (vnoise(along * 3.0, 0.0, seed + 6) - 0.5) * 0.12 + (vnoise(along * 11.0, 0.0, seed + 7) - 0.5) * 0.05
        val dd = down + wave
        val course = floor(dd / 0.3).toInt()
        val fc = frac(dd / 0.3)
        // single stalks: thin streaks down the slope, each its own shade
        val sx = along * 46 + rnd(course, 0, seed) * 7
        val stalk = rnd(floor(sx).toInt(), course, seed + 1)
        val streak = vnoise(sx * 0.5, dd * 9, seed + 8)
        var v = 0.46 + (stalk - 0.5) * 0.34 + (streak - 0.5) * 0.25 - fc * 0.16
        // the slope weathered grey towards the ridge, browner and wetter at the eaves
        v += (vnoise(along * 1.4, down * 1.8, seed + 2) - 0.5) * 0.2
        var c = mix(argb(0x17130D), argb(lk.thatch), v.coerceIn(0.0, 1.0))
        c = mix(c, argb(0x6A665C), 0.25 * (1 - down / run))
        // moss: fine clumps where the courses lie in shadow and on the lower, wetter half
        val m1 = vnoise(along * 4.0, down * 5.0, seed + 4); val m2 = rnd(floor(along * 30).toInt(), floor(down * 30).toInt(), seed + 5)
        val mossy = m1 * (0.55 + 0.7 * down / run) + (m2 - 0.5) * 0.35 + (1 - fc) * 0.1
        if (mossy > 1.15 - lk.moss * 0.4) c = mix(c, if (m2 > 0.6) argb(0x56602E) else argb(0x323E1C), 0.6)
        // shadow just under each course's edge, and the eave darker where the rain drips
        if (fc > 0.9) c = shade(c, 0.8)
        if (down > run - 0.1) c = shade(c, 0.78)
        return shade(c, 0.9)
    }

    /** Slate, small grey plates in rows, a few cracked or slipped. */
    private fun slateTex(along: Double, down: Double, run: Double, seed: Int): Int {
        val row = floor(down / 0.16).toInt()
        val off = if (row % 2 == 0) 0.0 else 0.5
        val col = floor(along / 0.2 + off).toInt()
        var v = 0.5 + (rnd(col, row, seed) - 0.5) * 0.25 + (rnd(floor(along * 60).toInt(), floor(down * 60).toInt(), seed + 1) - 0.5) * 0.08
        if (frac(down / 0.16) > 0.86) v -= 0.3
        if (frac(along / 0.2 + off) < 0.06) v -= 0.22
        if (hash(col, row, seed + 2) % 23 == 0) v -= 0.25
        val lichen = vnoise(along * 3, down * 3, seed + 3) * 0.7 + rnd(floor(along * 45).toInt(), floor(down * 45).toInt(), seed + 4) * 0.5 > 0.95
        val c = mix(argb(0x141618), argb(0x585C62), v.coerceIn(0.0, 1.0))
        return if (lichen) mix(c, argb(0x7A7A5A), 0.4) else c
    }

    /** The cut edge of the thatch (or slate): ragged stalk ends in shadow. */
    private fun edgeTex(u: Double, v: Double, slate: Boolean, lk: Look, seed: Int): Int? {
        if (slate) return shade(argb(0x22262C), 0.8 + v * 0.3)
        // the stalk ends hang ragged under the edge
        val ragged = rnd(floor(u * 40).toInt(), 0, seed) * 0.35
        if (v < ragged) return null
        val t = 0.25 + (rnd(floor(u * 50).toInt(), floor(v * 6).toInt(), seed + 1) - 0.5) * 0.25 + v * 0.25
        return mix(argb(0x14100A), argb(lk.thatch), t.coerceIn(0.0, 1.0))
    }

    /** The sample sheet (ISODINGE=dorf): three looks of a house by day and at night, and the temple. */
    fun sheet(): List<Pair<String, List<PixelImage>>> = listOf(
        "Haus Tag" to (0 until 3).map { house("#WDW#", "#W#", 3, it, 401 + it, chimney = 1 + it).img },
        "Haus Nacht" to (0 until 3).map { house("#WDW#", "#W#", 3, it, 401 + it, chimney = 1 + it, night = true).img },
        "Klein, Tempel" to listOf(
            house("WD#", "#W", 2, 0, 411, chimney = 2).img,
            house("#DW", "W#", 2, 1, 412, chimney = 0).img,
            house("#WDW#", "#WW#", 4, 2, 413, slate = true).img,
        ),
    )
}
