package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The things of the woods drawn for the diagonal view (27.5, in the game since 27f): a fallen trunk lying along the
 * ground in the slant, the camp fire in its ring of stones, each in three looks, the rock face with the cave's mouth,
 * and the signpost (the village's, [MapTownIso.signpost]). Like the village's things ([MapTownIso]) one
 * picture per tile, the tile's front corner on the middle of its bottom edge; local coordinates run from (−1, −1) at
 * the tile's back corner to (0, 0) at its front corner. Drawn from many small points with a depth buffer, so round
 * bodies cover themselves rightly.
 */
object MapWoodIso {
    private const val TW = MapRoomIso.TW
    private const val TH = MapRoomIso.TH
    private const val ZS = MapRoomIso.ZS
    /** Height units to one tile's length: the hero (about 100 units) stands a little over a tile tall. */
    private const val ZT = 84.0

    private val menhirOrder = HashMap<String, Map<Int, Int>>()

    /** How many standing stones come before ([tx], [ty]) on [map], row by row. */
    private fun menhirIndex(map: MapDef, tx: Int, ty: Int): Int = synchronized(menhirOrder) {
        menhirOrder.getOrPut(map.id) {
            val out = HashMap<Int, Int>()
            for (y in 0 until map.height) for (x in 0 until map.width) if (map.tile(x, y) == Tile.MENHIR) out[y * map.width + x] = out.size
            out
        }[ty * map.width + tx] ?: 0
    }

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun frac(v: Double) = v - floor(v)
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0
    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }
    private fun vnoise(x: Double, y: Double, s: Int): Double {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        val fx = x - ix; val fy = y - iy
        val ux = fx * fx * (3 - 2 * fx); val uy = fy * fy * (3 - 2 * fy)
        val a = rnd(ix, iy, s); val b = rnd(ix + 1, iy, s); val c = rnd(ix, iy + 1, s); val d = rnd(ix + 1, iy + 1, s)
        return a + (b - a) * ux + (c - a) * uy + (a - b - c + d) * ux * uy
    }

    /** Light from above and the right (+i, −j), as on the houses: faces towards +j lie in shade. */
    private val LIGHT = doubleArrayOf(0.45, -0.35, 0.82).let { v -> val l = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]); DoubleArray(3) { v[it] / l } }
    private fun lit(ni: Double, nj: Double, nz: Double) = 0.5 + 0.55 * max(0.0, ni * LIGHT[0] + nj * LIGHT[1] + nz * LIGHT[2])

    /** One tile's canvas with a depth buffer: a point nearer the camera (larger i + j, higher) wins. */
    private class Canvas(val h: Int, val w: Int = 100) {
        val img = PixelImage(w, h)
        private val depth = DoubleArray(w * h) { Double.NEGATIVE_INFINITY }
        fun sx(i: Double, j: Double) = w / 2.0 + (i - j) * TW / 2
        fun sy(i: Double, j: Double, z: Double) = h + (i + j) * TH / 2 - z * ZS
        fun pt(i: Double, j: Double, z: Double, c: Int) {
            val px = floor(sx(i, j)).toInt(); val py = floor(sy(i, j, z)).toInt()
            if (px !in 0 until w || py !in 0 until h) return
            val d = i + j + z * ZS * 2 / TH
            val k = py * w + px
            if (d < depth[k]) return
            depth[k] = d; img.set(px, py, c)
        }
        /** A soft shadow on the ground, an ellipse of radii [ri] and [rj] tiles. */
        fun shadow(ci: Double, cj: Double, ri: Double, rj: Double, a: Double = 0.45) {
            for (py in 0 until h) for (px in 0 until w) {
                val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
                val i = (aa + bb) / 2; val j = (bb - aa) / 2
                val di = (i - ci) / ri; val dj = (j - cj) / rj
                val d = sqrt(di * di + dj * dj)
                if (d >= 1) continue
                img.set(px, py, (((1 - d) * (1 - d) * a * 255).toInt() shl 24) or 0x0A0806)
            }
        }
    }

    // ------------------------------------------------------------------ the fallen trunk

    /** Bark, moss and fungus of the three trunks: oak brown, grey beech under moss, dark spruce with broken stubs. */
    private class Trunk(val bark: Int, val furrow: Int, val moss: Int, val mossy: Double, val stubs: Boolean, val fungus: Boolean)
    private val trunks = listOf(
        Trunk(0x5C4632, 0x2E2218, 0x4E5A2C, 0.45, stubs = false, fungus = false),
        Trunk(0x7A766A, 0x4A463E, 0x5A6A30, 0.15, stubs = false, fungus = true),
        Trunk(0x3E3026, 0x1E1610, 0x46522A, 0.6, stubs = true, fungus = false),
    )

    /**
     * One tile of a fallen trunk lying along i (a run of [Tile.LOG] across the map's row): round in its cross-section,
     * moss along its top, the sawn or broken end showing its rings where the run ends towards the camera (+i); [l] and
     * [r] tell whether the run ends at this tile's back (−i) or front (+i).
     */
    fun log(v: Int, l: Boolean, r: Boolean, seed: Int): PixelImage {
        val c = Canvas(90)
        val tk = trunks[v % trunks.size]
        val cj = -0.5; val rr = 0.17 + (v % 2) * 0.02; val rz = rr * ZT
        val i0 = if (l) -0.86 else -1.03; val i1 = if (r) -0.14 else 0.03
        c.shadow((i0 + i1) / 2, cj + 0.06, (i1 - i0) / 2 + 0.08, rr + 0.1, 0.5)
        val steps = 220
        var i = i0
        while (i <= i1) {
            for (k in 0..steps) {
                // the half towards the camera and the top: from straight down behind, over the top, to the front
                val th = -0.35 * PI + 1.6 * PI * k / steps
                val nj = cos(th); val nz = sin(th)
                val j = cj + rr * nj; val z = rz * (1 + nz)
                val ii = i + (if (r) 0.0 else 0.0)
                // furrows run along the trunk; a little moss and lichen where the rain falls
                val fur = vnoise(th * 9.0, ii * 14.0, seed + v)
                var col = mix(argb(tk.bark), argb(tk.furrow), if (fur > 0.62) 0.75 else fur * 0.35)
                if (nz > 0.35 && vnoise(ii * 9.0, th * 4.0, seed + 7) > 1 - tk.mossy) col = mix(col, argb(tk.moss), 0.85)
                // the bark burst off in places: pale wood under it
                if (vnoise(ii * 5.0, th * 2.5, seed + 11) > 0.86) col = mix(argb(0x9A8466), argb(0x7A6448), vnoise(ii * 30.0, th * 6.0, seed + 12))
                c.pt(ii, j, z, shade(col, lit(0.0, nj, nz)))
            }
            i += 0.004
        }
        // broken branch stubs on the spruce, a few bracket fungi on the beech
        if (tk.stubs) for (s in 0 until 2) {
            val si = -0.8 + rnd(seed, s, 3) * 0.6
            if (si < i0 + 0.05 || si > i1 - 0.05) continue
            val ang = 0.2 + rnd(seed, s, 4) * 1.2
            for (t in 0..60) {
                val f = t / 60.0
                val j = cj + cos(ang) * (rr + f * 0.12); val z = rz * (1 + sin(ang)) + f * 10 * sin(ang) + f * 6
                for (a in 0 until 12) { val q = a * PI / 6; c.pt(si + 0.025 * cos(q), j, z + 2.2 * sin(q), shade(argb(tk.bark), lit(cos(q), 0.0, sin(q)))) }
            }
        }
        if (tk.fungus) for (s in 0 until 3) {
            val si = -0.85 + rnd(seed, s, 5) * 0.7
            if (si < i0 + 0.05 || si > i1 - 0.05) continue
            val zf = rz * (0.7 + rnd(seed, s, 6) * 0.6)
            for (a in 0..40) for (rad in 0..8) {
                val q = -PI / 2 + PI * a / 40; val e = rad / 8.0 * 0.06
                c.pt(si + e * sin(q), cj + rr * 0.95 + e * cos(q) * 0.9, zf, shade(mix(argb(0xC8B48A), argb(0x8A6A44), rad / 8.0), 0.9 + 0.2 * (1 - rad / 8.0)))
            }
        }
        // the end towards the camera: a cut face with its rings and a crack, or splintered where it broke
        if (r) {
            for (a in 0..240) for (rad in 0..40) {
                val q = 2 * PI * a / 240; val e = rad / 40.0
                val ring = sin(e * 34 + vnoise(q * 3, e * 4, seed + 21) * 3)
                var col = mix(argb(0xB49A72), argb(0x8A6E4E), 0.5 + 0.5 * ring)
                if (e > 0.9) col = argb(tk.furrow)
                if (abs(q - 1.2 - v) < 0.03 && e > 0.25) col = argb(0x2A2016)
                if (v == 2) col = mix(col, argb(0x4A3A2A), 0.45)
                c.pt(i1 + 0.001, cj + rr * e * cos(q), rz * (1 + e * sin(q)), shade(col, 1.02))
            }
            if (v == 2) for (s in 0 until 9) {
                // splinters standing off the broken end
                val q = 2 * PI * s / 9 + rnd(seed, s, 8); val e = 0.4 + rnd(seed, s, 9) * 0.5
                val len = 0.04 + rnd(seed, s, 10) * 0.06
                for (t in 0..30) { val f = t / 30.0; c.pt(i1 + f * len, cj + rr * e * cos(q), rz * (1 + e * sin(q)) + f * 3, shade(argb(0x8A7050), 0.9 + f * 0.2)) }
            }
        }
        return c.img
    }

    // ------------------------------------------------------------------ the camp fire

    /**
     * The camp fire (27.5): a ring of soot-blackened field stones round a bed of ash, wood burning in it and flames
     * swaying with [frame]. Three looks: logs leant together, two logs crossed under a spit on forked sticks, and a
     * tripod with a kettle hanging over the fire.
     */
    fun campfire(v: Int, frame: Int, seed: Int): PixelImage {
        val c = Canvas(170)
        val ci = -0.5; val cj = -0.5
        c.shadow(ci, cj, 0.42, 0.42, 0.35)
        // the bed of ash and embers
        for (a in 0..360) for (rad in 0..60) {
            val q = 2 * PI * a / 360; val e = rad / 60.0
            val i = ci + 0.25 * e * cos(q); val j = cj + 0.25 * e * sin(q)
            val n = vnoise(i * 40, j * 40, seed + 1)
            var col = mix(argb(0x3A3430), argb(0x1C1816), n)
            if (e < 0.55 && n > 0.62) col = mix(argb(0xC04A18), argb(0xFFA040), (n - 0.62) * 2.4 + (if ((frame + (n * 10).toInt()) % 2 == 0) 0.2 else 0.0))
            c.pt(i, j, 0.8 - e * 0.6, col)
        }
        // the ring of stones, each a rounded lump, sooty inside and lit warm by the fire
        val stones = 11 + v % 2
        for (s in 0 until stones) {
            val q = 2 * PI * s / stones + rnd(seed, s, 2) * 0.25
            val si = ci + cos(q) * 0.31; val sj = cj + sin(q) * 0.31
            val r = 0.055 + rnd(seed, s, 3) * 0.025; val hz = 7.0 + rnd(seed, s, 4) * 5
            for (a in 0..80) for (b in 0..20) {
                val az = 2 * PI * a / 80; val el = PI / 2 * b / 20
                val ni = cos(az) * cos(el); val nj = sin(az) * cos(el); val nz = sin(el)
                val bump = 1 + (vnoise(az * 3 + s * 7, el * 3, seed + 5) - 0.5) * 0.3
                val i = si + r * ni * bump; val j = sj + r * nj * bump; val z = hz * nz * bump
                // inside towards the fire: blackened and lit orange
                val inward = -(ni * cos(q) + nj * sin(q))
                var col = mix(argb(0x8A847A), argb(0x5A564E), vnoise(i * 60, j * 60 + z * 0.1, seed + 6))
                if (inward > 0.2) col = mix(col, argb(0x1E1A16), 0.6 * inward)
                var k = lit(ni, nj, nz)
                if (inward > 0.3) col = mix(col, argb(0xD07038), 0.3 * inward)
                c.pt(i, j, z, shade(col, k))
            }
        }
        // the wood
        fun stick(a0: DoubleArray, a1: DoubleArray, rad: Double, charFrom: Double, bark: Int) {
            val len = sqrt((a1[0] - a0[0]).let { it * it } + (a1[1] - a0[1]).let { it * it } + ((a1[2] - a0[2]) / ZT).let { it * it })
            val n = (len * 500).toInt().coerceAtLeast(20)
            for (t in 0..n) {
                val f = t / n.toDouble()
                val i = a0[0] + (a1[0] - a0[0]) * f; val j = a0[1] + (a1[1] - a0[1]) * f; val z = a0[2] + (a1[2] - a0[2]) * f
                for (a in 0 until 16) {
                    val q = 2 * PI * a / 16
                    val nj = cos(q); val nz = sin(q)
                    val charred = f > charFrom
                    val col = if (charred) (if (vnoise(f * 30, q, seed + 9) > 0.7) argb(0xB0401A) else argb(0x1E1612)) else argb(bark)
                    c.pt(i + rad * nj * 0.3, j + rad * nj, z + rad * ZT * nz, shade(col, if (charred) 1.0 else lit(0.0, nj, nz)))
                }
            }
        }
        val mid = doubleArrayOf(ci, cj, 4.0)
        when (v) {
            0 -> for (s in 0 until 4) {
                // logs leant together over the middle
                val q = PI / 4 + 2 * PI * s / 4 + rnd(seed, s, 12) * 0.4
                stick(doubleArrayOf(ci + cos(q) * 0.24, cj + sin(q) * 0.24, 1.0), doubleArrayOf(ci + cos(q) * 0.02, cj + sin(q) * 0.02, 26.0), 0.028, 0.55, 0x5A4430)
            }
            else -> {
                // two logs crossed in the embers
                stick(doubleArrayOf(ci - 0.22, cj - 0.06, 3.0), doubleArrayOf(ci + 0.22, cj + 0.06, 3.0), 0.035, 0.3, 0x5A4430)
                stick(doubleArrayOf(ci - 0.05, cj - 0.22, 5.0), doubleArrayOf(ci + 0.05, cj + 0.22, 5.0), 0.032, 0.3, 0x4E3A28)
            }
        }
        // the flames: tongues from deep red to a pale core, swaying with the frame; drawn over the wood
        fun flames(low: Double = 1.0) {
            val bx = c.sx(ci, cj); val by = c.sy(ci, cj, 4.0)
            val tongues = listOf(-7.0 to 24.0, -2.5 to 36.0, 3.0 to 30.0, 7.5 to 20.0, 0.5 to 42.0, -5.0 to 16.0)
            for ((k, tg) in tongues.withIndex()) {
                val (ox, hgt0) = tg
                val hgt = low * hgt0 * (if ((k + frame) % 2 == 0) 1.0 else 0.82) * (0.9 + rnd(k, frame % 4, seed + 13) * 0.2)
                for (yy in 0 until hgt.toInt()) {
                    val f = yy / hgt
                    val half = ((1 - f) * (6.0 - abs(ox) * 0.3) + 0.6).coerceAtLeast(0.6)
                    val sway = sin(f * 3.2 + ox + frame * 1.7) * 2.8 * f
                    var x = -half
                    while (x <= half) {
                        val e = abs(x) / half
                        val col = when {
                            e < 0.35 && f < 0.55 -> mix(argb(0xFFF2B0), argb(0xFFD060), f * 1.6)
                            e < 0.7 && f < 0.8 -> mix(argb(0xFFB030), argb(0xF06A18), f)
                            else -> mix(argb(0xD0401A), argb(0x8A2410), f)
                        }
                        val px = floor(bx + ox + x + sway).toInt(); val py = floor(by - yy).toInt()
                        if (px in 0 until c.w && py in 0 until c.h) c.img.set(px, py, col)
                        x += 0.5
                    }
                }
            }
            // a few sparks above
            for (s in 0 until 5) {
                val px = floor(bx + (rnd(s, frame % 4, seed + 14) - 0.5) * 18).toInt()
                val py = floor(by - 46 * low - rnd(s, frame % 4, seed + 15) * 30).toInt()
                if (px in 0 until c.w && py in 0 until c.h) c.img.set(px, py, argb(0xFFC060))
            }
        }
        when (v) {
            1 -> {
                // a spit on two forked sticks across the fire, along j, a rabbit skewered on it
                for (sj in listOf(cj - 0.34, cj + 0.34)) {
                    stick(doubleArrayOf(ci, sj, 0.0), doubleArrayOf(ci, sj, 46.0), 0.016, 2.0, 0x4A3828)
                    stick(doubleArrayOf(ci, sj, 40.0), doubleArrayOf(ci + 0.03, sj, 52.0), 0.01, 2.0, 0x4A3828)
                }
                flames()
                stick(doubleArrayOf(ci, cj - 0.4, 44.0), doubleArrayOf(ci, cj + 0.4, 44.0), 0.012, 2.0, 0x6A5038)
                for (a in 0..60) for (b in 0..30) {
                    val q = 2 * PI * a / 60; val t = b / 30.0
                    val j = cj - 0.12 + t * 0.24; val rad = 0.05 * sin(PI * (0.1 + 0.8 * t))
                    c.pt(ci + rad * 0.3 * cos(q), j, 44.0 + rad * ZT * sin(q), shade(mix(argb(0x8A4A22), argb(0x5A2C14), vnoise(t * 10, q, seed + 16)), lit(0.0, cos(q), sin(q))))
                }
            }
            2 -> {
                // a tripod of three poles over the fire, a kettle hanging from it on a chain
                val top = doubleArrayOf(ci, cj, 100.0)
                for (s in 0 until 3) {
                    val q = -PI / 2 + 2 * PI * s / 3
                    val foot = doubleArrayOf(ci + cos(q) * 0.38, cj + sin(q) * 0.38, 0.0)
                    if (s == 0) stick(foot, top, 0.014, 2.0, 0x4A3828)
                }
                flames(0.62)
                for (z in 62 until 100) c.pt(ci, cj, z.toDouble(), argb(0x2A2826))
                for (a in 0..80) for (zz in 0..30) {
                    val q = 2 * PI * a / 80; val z = 42.0 + zz * 0.65
                    val bulge = 0.075 + 0.02 * sin(PI * zz / 30.0)
                    val nj = sin(q); val ni = cos(q)
                    c.pt(ci + bulge * ni, cj + bulge * nj, z, shade(argb(0x2A2826), lit(ni, nj, 0.2)))
                }
                for (s in 1 until 3) {
                    val q = -PI / 2 + 2 * PI * s / 3
                    stick(doubleArrayOf(ci + cos(q) * 0.38, cj + sin(q) * 0.38, 0.0), top, 0.014, 2.0, 0x4A3828)
                }
            }
            else -> flames()
        }
        return c.img
    }

    // ------------------------------------------------------------------ the rock face with the cave's mouth

    /**
     * One tile of the rock face along the north edge of the wood (27.5), standing in the slant along i: rough grey rock
     * in ledges and cracks, moss and grass on its top, roots hanging over the edge; [mouth] the tile of the cave's
     * mouth (a ragged arch into darkness, bones before it, a skull on a stake beside it); [r] where the face ends
     * towards the camera (+i), its lit side shows.
     */
    fun cliff(mouth: Boolean, l: Boolean, r: Boolean, tx: Int, seed: Int): PixelImage {
        val c = Canvas(250)
        val gi = tx.toDouble()
        fun top(i: Double) = 128.0 + (vnoise((gi + i) * 2.2, 0.5, seed) - 0.5) * 34
        fun face(i: Double, z: Double) = -0.62 + (vnoise((gi + i) * 3.0, z / 26.0, seed + 1) - 0.5) * 0.16 + (vnoise((gi + i) * 9.0, z / 9.0, seed + 2) - 0.5) * 0.05 +
            (if (z < 18) (18 - z) / 18 * 0.08 else 0.0)
        val i0 = if (l) -0.8 else -1.02; val i1 = if (r) -0.2 else 0.02
        fun arch(i: Double, z: Double): Double {
            if (!mouth) return 9.0
            val w = 0.34 + z / 800.0
            val e = ((i + 0.5) / w).let { it * it } + (z / 104.0).let { it * it }
            return e + (vnoise(i * 30, z / 8, seed + 3) - 0.5) * 0.16
        }
        c.shadow((i0 + i1) / 2, -0.45, (i1 - i0) / 2 + 0.1, 0.3, 0.5)
        var i = i0
        while (i <= i1) {
            val ht = top(i)
            var z = 0.0
            while (z <= ht) {
                val j = face(i, z)
                val dj = face(i + 0.01, z) - j
                // ledges: the rock lies in rough beds; cracks between them, and where the face turns towards the light
                val bed = (z + vnoise((gi + i) * 2.5, z / 40.0, seed + 4) * 26) % 24
                var col = mix(argb(0xA49E90), argb(0x6A655A), vnoise((gi + i) * 14, z / 6, seed + 5))
                if (bed < 1.4 && vnoise((gi + i) * 6, z / 30, seed + 12) > 0.35) col = mix(col, argb(0x2A2622), 0.55)
                if (vnoise((gi + i) * 7, z / 14, seed + 6) > 0.7 && z < ht - 6) col = mix(col, argb(0x46522A), 0.7)
                if (ht - z < 8) col = mix(col, argb(0x3E4A24), 0.8)
                var k = 0.78 + (dj * 9).coerceIn(-0.25, 0.35) + (if (bed > 21) 0.15 else 0.0)
                val e = arch(i, z)
                if (e < 1) { col = mix(argb(0x0A0908), argb(0x1E1A16), (1 - e) * 0.0 + e * 0.6); k = 1.0 }
                else if (e < 1.18) { col = mix(argb(0xB8B2A4), argb(0x7A7468), vnoise(i * 40, z / 5, seed + 13)); k = 1.0 }
                c.pt(i, j, z, shade(col, k))
                z += 0.7
            }
            // the top: grass and moss running back into the wood, roots hanging over the edge
            var jj = face(i, ht) - 0.01
            while (jj >= -1.05) {
                val g = vnoise((gi + i) * 12, jj * 12, seed + 7)
                c.pt(i, jj, ht + g * 3, shade(mix(argb(0x4E5A2C), argb(0x2E3A1C), g), 0.85 + g * 0.3))
                jj -= 0.006
            }
            if (rnd((i * 200).toInt() + tx * 1000, 0, seed + 8) < 0.04) {
                val len = 10 + rnd((i * 200).toInt(), 1, seed + 8) * 28
                for (zz in 0 until (len / 0.7).toInt()) { val z = ht - zz * 0.7; c.pt(i, face(i, z) + 0.012 + zz * 0.0004, z, argb(0x3A2C1E)) }
            }
            i += 0.0035
        }
        // the side where the face ends towards the camera: lit rock
        if (r) {
            var z = 0.0
            while (z <= top(i1)) {
                var j = -1.05
                val jf = face(i1, z)
                while (j <= jf) {
                    val col = mix(argb(0x9A9488), argb(0x5A564C), vnoise(j * 20, z / 6, seed + 9))
                    c.pt(i1 + (vnoise(j * 6, z / 20, seed + 10) - 0.5) * 0.04, j, z, shade(col, 1.05))
                    j += 0.006
                }
                z += 0.7
            }
        }
        if (mouth) {
            // bones before the mouth, and a skull on a stake beside it
            for (k in 0 until 5) {
                val bi = -0.5 + (rnd(k, 1, seed + 11) - 0.5) * 0.5; val bj = -0.35 + rnd(k, 2, seed + 11) * 0.25
                val a = rnd(k, 3, seed + 11) * PI
                for (t in 0..20) { val f = t / 20.0 - 0.5; c.pt(bi + cos(a) * f * 0.09, bj + sin(a) * f * 0.09, 1.5, shade(argb(0xC8BCA0), 0.9 + f * 0.2)) }
            }
            val si = -0.9; val sj = -0.22
            for (z in 0 until 78) for (q in 0 until 8) { val a = q * PI / 4; c.pt(si + 0.012 * cos(a), sj + 0.012 * sin(a), z.toDouble(), shade(argb(0x4A3828), lit(cos(a), sin(a), 0.0))) }
            for (a in 0..40) for (b in 0..20) {
                val az = 2 * PI * a / 40; val el = -PI / 2 + PI * b / 20
                val ni = cos(az) * cos(el); val nj = sin(az) * cos(el); val nz = sin(el)
                var col = argb(0xC8BCA0)
                // the empty eyes look towards the path (+j)
                if (nj > 0.55 && nz > -0.1 && nz < 0.45 && abs(ni) > 0.12 && abs(ni) < 0.55) col = argb(0x1A1410)
                c.pt(si + 0.05 * ni, sj + 0.05 * nj, 84.0 + 7 * nz, shade(col, lit(ni, nj, nz)))
            }
        }
        return c.img
    }

    // ------------------------------------------------------------------ fields and beds in the village

    /**
     * One tile of a vegetable bed seen diagonally (test of 0.1.590: the former tiles looked like boxes): earth heaped in
     * ridges running along i straight through the bed, no edge between its tiles; on the ridges a row of cabbages, of
     * leeks or of turnip tops, the kind by the row of the bed ([v]).
     */
    fun vegBed(v: Int, tx: Int, ty: Int): PixelImage {
        val c = Canvas(80)
        val seed = 760 + tx * 7 + ty * 13
        val ridges = 3
        // D6.7: the plants set by hand, not in a grid: unevenly spaced, now and then one missing, each of its own size
        class Plant(val i: Double, val j: Double, val sc: Double, val ps: Int, val k: Int)
        val plants = ArrayList<Plant>()
        for (r in 0 until ridges) {
            val rj = -1 + (r + 0.5) / ridges
            for (k in 0 until 4) {
                if (rnd(tx * 4 + k, ty * 3 + r, seed + 2) < 0.12) continue
                plants += Plant(-1 + (k + 0.5) / 4 + (rnd(tx * 4 + k, ty * 3 + r, seed) - 0.5) * 0.16,
                    rj + (rnd(tx * 4 + k, ty * 3 + r, seed + 1) - 0.5) * 0.07,
                    0.8 + rnd(tx * 4 + k, ty * 3 + r, seed + 3) * 0.4, seed + r * 31 + k * 7, k)
            }
        }
        // D6.1: each plant's soft shadow on the earth, falling down left (+j) like the houses', longer for the leeks
        fun shadowAt(i: Double, j: Double): Double {
            var s = 0.0
            for (p in plants) {
                val len = if (v == 1) 0.11 else 0.07
                val di = (i - p.i - 0.015) / (0.08 * p.sc); val dj = (j - p.j - len * p.sc) / ((0.06 + len) * p.sc)
                val d = di * di + dj * dj
                if (d < 1) s = max(s, (1 - d) * (1 - d))
            }
            return s
        }
        // the earth: ridges along i, furrows between, clods
        var i = -1.02
        while (i <= 0.02) {
            var j = -1.02
            while (j <= 0.02) {
                val ph = ((j + 1) * ridges) % 1.0
                val z = 4.0 * sin(PI * ph) + (vnoise((tx + i) * 30, (ty + j) * 30, seed) - 0.5) * 1.2
                val nj = -cos(PI * ph) * 0.6
                val col = mix(argb(0x4A3A28), argb(0x2A2016), vnoise((tx + i) * 50, (ty + j) * 50, 761))
                c.pt(i, j, z, shade(col, lit(0.0, nj, 1.0) * (1 - 0.4 * shadowAt(i, j))))
                j += 0.004
            }
            i += 0.004
        }
        for (pl in plants) {
            run {
                val pi = pl.i; val pj = pl.j; val sc = pl.sc; val ps = pl.ps; val k = pl.k
                when (v) {
                    0 -> for (a in 0..60) for (b in 0..18) {
                        // a cabbage: a round head in loose outer leaves
                        val az = 2 * PI * a / 60; val el = PI / 2 * b / 18
                        val ni = cos(az) * cos(el); val nj = sin(az) * cos(el); val nz = sin(el)
                        val rad = 0.095 * sc * (1 + (vnoise(az * 2, el * 3, ps) - 0.5) * 0.25)
                        val vein = abs(sin(az * 5 + el * 2)) > 0.94
                        val col = if (vein) argb(0x9AB07A) else mix(argb(0x6A8A4A), argb(0x3E5A2E), 1 - nz)
                        c.pt(pi + rad * ni, pj + rad * nj, 5 + 9 * sc * nz, shade(col, lit(ni, nj, nz)))
                    }
                    1 -> for (l in 0 until 5) {
                        // a leek: pale stem, dark blue-green leaves fanning
                        val a = l * PI * 2 / 5 + rnd(k, l, ps) * 0.6
                        for (t in 0..40) {
                            val f = t / 40.0
                            val z = 4 + f * 26 * sc; val off = f * f * 0.07 * sc
                            val col = if (f < 0.35) argb(0xD8D8B8) else mix(argb(0x5A7A5A), argb(0x3A5A44), f)
                            for (w in -1..1) c.pt(pi + cos(a) * off + w * 0.004, pj + sin(a) * off, z, shade(col, 0.9 + 0.1 * w))
                        }
                    }
                    else -> for (l in 0 until 7) {
                        // turnip tops: a tuft of broad leaves over a pale root
                        val a = l * PI * 2 / 7 + rnd(k, l, ps) * 0.5
                        for (t in 0..24) for (w in -3..3) {
                            val f = t / 24.0
                            val bw = sin(PI * f) * 0.02 * (w / 3.0)
                            val z = 5 + (f * 14 - f * f * 6) * sc
                            c.pt(pi + cos(a) * f * 0.09 * sc - sin(a) * bw, pj + sin(a) * f * 0.09 * sc + cos(a) * bw, z, shade(mix(argb(0x5E8040), argb(0x3A5A2A), f), 0.85 + 0.25 * (1 - abs(w) / 3.0)))
                        }
                        for (a2 in 0..20) c.pt(pi + 0.02 * cos(a2 * 0.3), pj + 0.02 * sin(a2 * 0.3), 3.5, argb(0xD8C8D0))
                    }
                }
            }
        }
        return c.img
    }

    /**
     * One tile of a cornfield seen diagonally (test of 0.1.590: the former strokes looked like rain): hundreds of
     * stalks standing hip high, each leaning a little its own way and all a little with the wind, a golden ear on each;
     * thinner and lower where the field ends ([edges]: back i, front i, back j, front j).
     */
    fun corn(tx: Int, ty: Int, edges: BooleanArray): PixelImage {
        val c = Canvas(110)
        val seed = 790 + tx * 7 + ty * 13
        c.shadow(-0.5, -0.5, 0.6, 0.6, 0.25)
        for (k in 0 until 520) {
            val si = -1 + rnd(k, tx, seed); val sj = -1 + rnd(k, ty, seed + 1)
            val edge = listOf(si + 1, -si, sj + 1, -sj).withIndex().minOf { (n, d) -> if (edges[n]) d else 9.0 }
            if (edge < 0.08 && rnd(k, 3, seed) < 0.6) continue
            val h = (46 + rnd(k, 4, seed) * 14) * (if (edge < 0.2) 0.85 else 1.0)
            val li = 0.05 + (rnd(k, 5, seed) - 0.5) * 0.06; val lj = (rnd(k, 6, seed) - 0.5) * 0.06
            val dry = rnd(k, 7, seed)
            val n = (h / 1.2).toInt()
            for (t in 0..n) {
                val f = t / n.toDouble()
                val i = si + li * f * f; val j = sj + lj * f * f; val z = h * f
                val col = mix(argb(0x6A5A2E), mix(argb(0xC8A852), argb(0xA88A3E), dry), f)
                c.pt(i, j, z, shade(col, 0.75 + 0.3 * f))
            }
            // the ear: a slim golden head bending with the stalk, lit on its right
            for (t in 0..10) for (q in 0 until 6) {
                val f = t / 10.0; val a = q * PI / 3
                val i = si + li * (1 + f * 0.4) + 0.008 * cos(a); val j = sj + lj * (1 + f * 0.4) + 0.008 * sin(a)
                val col = mix(argb(0xE8C870), argb(0xB08A3A), dry * 0.6 + f * 0.2)
                c.pt(i, j, h + f * 9, shade(col, lit(cos(a), sin(a), 0.3)))
            }
        }
        return c.img
    }


    /**
     * A healing herb seen diagonally (56, draft): a low rosette of broad ribbed leaves like plantain, muted green, and
     * over it two or three stalks of yarrow with flat white umbels, so it is told from the grass by its flowers, not by
     * a loud green. Three looks ([v]); [sway] in −1..1 bends the stalks a little with the wind.
     */
    fun herb(v: Int, sway: Double): PixelImage {
        val c = Canvas(64)
        val seed = 810 + v * 17
        val ci = -0.5; val cj = -0.5
        c.shadow(ci, cj, 0.26, 0.22, 0.35)
        // the rosette: leaves lying outwards, rising a little and curling down at the tip
        val leaves = 7 + v
        for (l in 0 until leaves) {
            val a = 2 * PI * l / leaves + rnd(l, v, seed) * 0.5
            val len = 0.17 + rnd(l, v, seed + 1) * 0.07
            for (t in 0..40) for (w in -6..6) {
                val f = t / 40.0
                val half = sin(PI * f.coerceAtMost(0.98)) * 0.035 * (0.6 + 0.4 * f)
                val q = w / 6.0
                val r = f * len
                val i = ci + cos(a) * r - sin(a) * half * q
                val j = cj + sin(a) * r + cos(a) * half * q
                val z = 2 + 9 * sin(PI * f * 0.8) - 2 * f * f - abs(q) * 1.5
                // the ribs run along the leaf, the midrib pale
                val rib = abs(q) < 0.12 || abs(abs(q) - 0.55) < 0.06
                val base = mix(argb(0x5E7A3C), argb(0x3C5428), f * 0.6 + rnd(l, t, seed + 2) * 0.15)
                val col = if (rib) mix(base, argb(0x9AAE70), 0.45) else base
                c.pt(i, j, z, shade(col, lit(-sin(a) * q * 0.5, cos(a) * q * 0.5 - 0.2, 1.0)))
            }
        }
        // the yarrow: thin stalks, feathery leaves low on them, a flat umbel of tiny white flowers on top
        val stalks = 2 + v % 2
        for (s in 0 until stalks) {
            val a = 2 * PI * s / stalks + 0.7 + v
            val si = ci + cos(a) * 0.05; val sj = cj + sin(a) * 0.05
            val h = 30.0 + rnd(s, v, seed + 3) * 10
            val bi = 0.03 * sway + (rnd(s, v, seed + 4) - 0.5) * 0.04; val bj = -0.02 * sway
            val n = (h / 0.8).toInt()
            for (t in 0..n) {
                val f = t / n.toDouble()
                val i = si + bi * f * f; val j = sj + bj * f * f
                c.pt(i, j, 4 + h * f, shade(argb(0x5A6E3A), 0.8 + 0.25 * f))
                if (f in 0.15..0.55 && t % 3 == 0) for (k in 1..4) {
                    // the feathery leaf: short side strokes on both sides
                    val side = if (t % 6 == 0) 1 else -1
                    c.pt(i + side * k * 0.008, j - side * k * 0.004, 4 + h * f + k * 0.6, shade(argb(0x6A844A), 0.9))
                }
            }
            val ti = si + bi; val tj = sj + bj; val tz = 4 + h
            for (k in 0 until 26) {
                val r = sqrt(rnd(k, s, seed + 5)) * 0.045; val b = rnd(k, s, seed + 6) * 2 * PI
                val fi = ti + cos(b) * r; val fj = tj + sin(b) * r
                val fz = tz + 2.5 - r * 30
                val white = mix(argb(0xEDE8D6), argb(0xC8C2AE), rnd(k, s, seed + 7) * 0.6)
                c.pt(fi, fj, fz, white); c.pt(fi + 0.005, fj, fz, white); c.pt(fi, fj, fz + 0.8, shade(white, 1.05))
                if (k % 7 == 0) c.pt(fi, fj, fz + 1.2, argb(0xC8B070))
            }
        }
        return c.img
    }


    /**
     * A chest left in the woods seen diagonally (56, draft): a box of weathered planks along i with a rounded lid,
     * two iron bands over it and a lock at the front (+j); moss and leaves on its foot. Three looks of wood ([v]:
     * oak, grey, dark); [open] the lid stands up at the back and the inside is dark and empty.
     */
    fun chest(v: Int, open: Boolean): PixelImage {
        val c = Canvas(76)
        val seed = 830 + v * 11
        val i0 = -0.80; val i1 = -0.22; val j0 = -0.70; val j1 = -0.34
        val zb = 22.0
        val rj = (j1 - j0) / 2; val jm = (j0 + j1) / 2; val rz = 12.0
        val wood = listOf(0x6A4A30, 0x6E665A, 0x3E2E22)[v]
        val iron = argb(0x2A2826)
        c.shadow((i0 + i1) / 2, jm, 0.42, 0.3, 0.5)
        fun bandAt(i: Double) = abs(i - (i0 + 0.12)) < 0.035 || abs(i - (i1 - 0.12)) < 0.035
        fun plank(i: Double, z: Double, along: Double, k: Int): Int {
            val seam = frac(along * 5.0) < 0.07
            val grain = vnoise(i * 40, z / 3.0 + k, seed) * 0.35
            var col = mix(argb(wood), argb(0x1E1610), (if (seam) 0.55 else 0.0) + grain * 0.4)
            if (z < 5 && vnoise(i * 30, along * 9, seed + 3) > 0.45) col = mix(col, argb(0x4E5A2C), 0.7)
            return col
        }
        val step = 0.004
        // front (+j) and back faces, the two ends (±i)
        var i = i0
        while (i <= i1) {
            var z = 0.0
            while (z <= zb) {
                val band = bandAt(i)
                val lock = abs(i - (i0 + i1) / 2) < 0.04 && z in zb - 9..zb - 1
                val col = when { lock -> argb(0x8A7A4A); band -> iron; else -> plank(i, z, z / zb, 0) }
                c.pt(i, j1, z, shade(col, lit(0.0, 1.0, 0.0)))
                c.pt(i, j0, z, shade(if (lock) plank(i, z, z / zb, 0) else col, lit(0.0, -1.0, 0.0)))
                z += 0.35
            }
            i += step
        }
        var j = j0
        while (j <= j1) {
            var z = 0.0
            while (z <= zb) {
                val col = if (abs(z - zb + 2) < 1.5 || abs(z - 2) < 1.5) iron else plank(j, z, (j - j0) / (j1 - j0), 1)
                c.pt(i1, j, z, shade(col, lit(1.0, 0.0, 0.0)))
                c.pt(i0, j, z, shade(col, lit(-1.0, 0.0, 0.0)))
                z += 0.35
            }
            j += step
        }
        if (!open) {
            // the rounded lid: a half cylinder along i
            i = i0
            while (i <= i1) {
                var a = 0.0
                while (a <= PI) {
                    val nj = cos(a); val nz = sin(a)
                    val col = if (bandAt(i)) iron else plank(i, zb + nz * rz, a / PI, 2)
                    c.pt(i, jm + nj * rj, zb + nz * rz, shade(col, lit(0.0, nj, nz)))
                    a += 0.02
                }
                i += step
            }
            for (k in listOf(i0, i1)) {
                var jj = j0
                while (jj <= j1) {
                    val top = sqrt(max(0.0, 1 - ((jj - jm) / rj).let { it * it })) * rz
                    var z = zb
                    while (z <= zb + top) { c.pt(k, jj, z, shade(plank(jj, z, 0.3, 3), lit(if (k == i1) 1.0 else -1.0, 0.0, 0.0))); z += 0.35 }
                    jj += step
                }
            }
        } else {
            // the inside: dark and empty; the lid stands up behind, its inner side showing
            i = i0 + 0.02
            while (i <= i1 - 0.02) {
                var jj = j0 + 0.02
                while (jj <= j1 - 0.02) { c.pt(i, jj, 4.0, argb(0x120C08)); jj += step }
                i += step
            }
            i = i0
            while (i <= i1) {
                var a = 0.0
                while (a <= PI) {
                    // the lid swung back about the back edge: its curve now rises behind the box
                    val z = zb + (1 - cos(a)) / 2 * 2 * rj * ZT * 0.85
                    val jj = j0 - sin(a) * rz / ZT - 0.01
                    val col = if (bandAt(i)) iron else mix(plank(i, z, a / PI, 4), argb(0x1A120C), 0.35)
                    c.pt(i, jj, z, shade(col, lit(0.0, 1.0, 0.3)))
                    a += 0.02
                }
                i += step
            }
        }
        return c.img
    }


    /**
     * Boulders in the woods seen diagonally (56, draft): one big stone half sunk in the ground with one or two smaller
     * ones beside it, each a lumpy round body (not a ball: flattened, dented by noise), grey with a brown cast, moss
     * thick on the tops and the shaded north, pale spots of lichen. Three looks ([v]).
     */
    /** The stones of the rocks' look [v]: centre (i, j), radii (tile, tile, height units). */
    private fun stones(v: Int) = when (v) {
        0 -> listOf(doubleArrayOf(-0.52, -0.5, 0.30, 0.26, 34.0), doubleArrayOf(-0.2, -0.3, 0.13, 0.12, 14.0), doubleArrayOf(-0.8, -0.24, 0.11, 0.1, 11.0))
        1 -> listOf(doubleArrayOf(-0.5, -0.56, 0.34, 0.22, 26.0), doubleArrayOf(-0.24, -0.22, 0.15, 0.14, 18.0))
        else -> listOf(doubleArrayOf(-0.46, -0.48, 0.27, 0.25, 32.0), doubleArrayOf(-0.78, -0.62, 0.14, 0.12, 16.0), doubleArrayOf(-0.3, -0.18, 0.09, 0.08, 9.0))
    }

    /** The rocks on ([tx], [ty]) for their sun shadow (D29.4): each stone (i, j, radius i, radius j) and its height in tiles. */
    fun rockShape(tx: Int, ty: Int): List<DoubleArray> = stones(Math.floorMod(hash(tx, ty, 36), 3)).map { doubleArrayOf(it[0], it[1], it[2], it[3], it[4] / ZT) }

    fun boulders(v: Int): PixelImage {
        val c = Canvas(84)
        val seed = 850 + v * 13
        val stones = stones(v)
        for ((k, st) in stones.withIndex()) c.shadow(st[0] + 0.05, st[1] + 0.03, st[2] * 1.15, st[3] * 1.15, 0.5)
        val base = listOf(0x6E6A62, 0x75705F, 0x5E5E5A)[v]
        for ((k, st) in stones.withIndex()) {
            val (ci, cj, ri, rj, rz) = st.toList()
            val ks = seed + k * 7
            var a = 0.0
            while (a < 2 * PI) {
                var e = -0.35
                while (e <= PI / 2) {
                    val ni = cos(a) * cos(e); val nj = sin(a) * cos(e); val nz = sin(e)
                    val bump = 1 + (vnoise(a * 2.2 + k, e * 2.5, ks) - 0.5) * 0.35 + (vnoise(a * 7, e * 7, ks + 1) - 0.5) * 0.08
                    // flattened on top, a little wider at the foot
                    val flat = 1 - 0.18 * max(0.0, nz - 0.6)
                    val i = ci + ri * ni * bump; val j = cj + rj * nj * bump; val z = rz * (nz * flat * bump + 0.25) - 6
                    if (z >= -0.5) {
                        val n = vnoise(a * 3.5, e * 3.5, ks + 2) * 0.8 + vnoise(a * 10, e * 10, ks + 7) * 0.2
                        var col = mix(argb(base), argb(0x3A3832), n * 0.4)
                        // moss on the tops and the shaded north (−i, +j lies in shade), lichen in pale spots elsewhere
                        val mossy = nz * 0.8 + max(0.0, nj) * 0.35 - max(0.0, ni) * 0.2 + (vnoise(a * 4, e * 4, ks + 3) - 0.5) * 0.7
                        if (mossy > 0.62) col = mix(col, argb(if (vnoise(a * 5, e * 5, ks + 4) > 0.5) 0x56662E else 0x46552A), 0.85)
                        else if (vnoise(a * 6, e * 6, ks + 5) > 0.74) col = mix(col, argb(0xA8A890), 0.55)
                        // a crack or two
                        if (abs(vnoise(a * 3, e * 6, ks + 6) - 0.5) < 0.015) col = shade(col, 0.55)
                        c.pt(i, j, max(0.0, z), shade(col, lit(ni, nj, nz)))
                    }
                    e += 0.012
                }
                a += 0.008
            }
        }
        return c.img
    }


    /**
     * A standing stone of the circle seen diagonally (56, draft): a tall slab, thicker one way than the other, tapering
     * to a rounded, broken top and leaning a little; weathered grey with pale lichen, moss creeping up from the foot,
     * and on its broad face a worn spiral cut long ago. Four looks ([v]), each slab turned its own way.
     */
    /** 89: the height (upright units) and the turn of the menhir on ([tx], [ty]), for its shadow ([MapSun]). */
    fun menhirShape(map: MapDef, tx: Int, ty: Int): Pair<Double, Double> = menhirSize(Math.floorMod(menhirIndex(map, tx, ty), 4))
    private fun menhirSize(v: Int) = (104.0 + (v * 9) % 22) to listOf(0.3, 1.2, -0.4, 0.8)[v % 4]

    fun menhir(v: Int): PixelImage {
        val c = Canvas(170)
        val seed = 870 + v * 19
        val ci = -0.5; val cj = -0.5
        val (h, turn) = menhirSize(v)
        val lean = listOf(0.04, -0.03, 0.06, 0.0)[v % 4]
        // a rounded box in cross-section (superellipse), broad along u, thin along w
        val ru0 = 0.32; val rw0 = 0.17
        var z = 0.0
        while (z <= h) {
            val f = z / h
            val taper = 1 - 0.3 * f - (if (f > 0.85) (f - 0.85) * 2.2 else 0.0)
            val top = f > 0.85
            val ru = ru0 * taper * (1 + (vnoise(f * 4, 0.5, seed) - 0.5) * 0.2); val rw = rw0 * taper
            val oi = lean * f * f; val oj = -lean * 0.5 * f * f
            var a = 0.0
            while (a < 2 * PI) {
                val ca = cos(a); val sa = sin(a)
                // superellipse of power 4: flat faces, rounded edges
                val px = Math.signum(ca) * Math.pow(abs(ca), 0.5); val py = Math.signum(sa) * Math.pow(abs(sa), 0.5)
                val bump = 1 + (vnoise(a * 3, z / 14.0, seed + 1) - 0.5) * 0.16
                val u = px * ru * bump; val w = py * rw * bump
                val i = ci + oi + u * cos(turn) - w * sin(turn)
                val j = cj + oj + u * sin(turn) + w * cos(turn)
                // the normal, roughly: across the flat faces mostly along w
                val nu = Math.signum(ca) * Math.pow(abs(ca), 1.5); val nw = Math.signum(sa) * Math.pow(abs(sa), 1.5) * 1.6
                val nl = sqrt(nu * nu + nw * nw)
                val ni = (nu * cos(turn) - nw * sin(turn)) / nl; val nj = (nu * sin(turn) + nw * cos(turn)) / nl
                var col = mix(argb(0x8A867A), argb(0x4E4A44), vnoise(a * 4, z / 10.0, seed + 2) * 0.55)
                if (vnoise(a * 6, z / 7.0, seed + 3) > 0.72) col = mix(col, argb(0xB4B49A), 0.6)
                if (z < 22 * (0.5 + vnoise(a * 3, 0.0, seed + 4)) ) col = mix(col, argb(0x4E5C2A), 0.8)
                // the spiral on the broad face towards the camera (+w side)
                if (sa > 0.8) {
                    val su = u / ru0; val sz = (z - h * 0.55) / (h * 0.18)
                    val r = sqrt(su * su + sz * sz); val th = Math.atan2(sz, su)
                    if (r < 1.0 && abs(frac((r * 3 - th / (2 * PI))) - 0.5) < 0.09) col = shade(col, 0.6)
                }
                c.pt(i, j, z, shade(col, lit(ni, nj, if (top) 0.6 else 0.0)))
                a += 0.01
            }
            z += 0.5
        }
        // the rounded top: a cap of points over the last ring
        val f = 1.0; val oi = lean; val oj = -lean * 0.5
        for (k in 0 until 2400) {
            val u = (rnd(k, v, seed + 5) * 2 - 1) * ru0 * 0.55; val w = (rnd(k, v, seed + 6) * 2 - 1) * rw0 * 0.55
            if ((u / (ru0 * 0.55)).let { it * it * it * it } + (w / (rw0 * 0.55)).let { it * it * it * it } > 1) continue
            val i = ci + oi + u * cos(turn) - w * sin(turn); val j = cj + oj + u * sin(turn) + w * cos(turn)
            val col = mix(argb(0x8A867A), argb(0x5A564E), vnoise(u * 30, w * 30, seed + 7) * 0.6)
            c.pt(i, j, h + 1 - (abs(u) / ru0) * 6 * f, shade(col, lit(0.0, 0.0, 1.0)))
        }
        return c.img
    }


    /**
     * A bush of the undergrowth seen diagonally (56, draft): a few overlapping clumps of small leaves, lit from above
     * and the right, dark within, the rim broken into single leaves so it is not a blob; a twig showing here and there.
     * Three kinds by [v] % 3: hazel (fresh green, round), holly (dark, glossy, red berries), bramble (low and wide,
     * dull green, dark berries); [v] / 3 gives a second shape of each.
     */
    fun bush(v: Int): PixelImage {
        val c = Canvas(64)
        val seed = 890 + v * 23
        val kind = v % 3
        val (light, dark) = when (kind) {
            0 -> argb(0x7E9A4A) to argb(0x2E4220)
            1 -> argb(0x5A7448) to argb(0x1A2A1A)
            else -> argb(0x6E7A44) to argb(0x2A3420)
        }
        val ci = -0.5; val cj = -0.5
        val wide = if (kind == 2) 1.35 else 1.0
        val hgt = if (kind == 2) 0.7 else 1.0
        c.shadow(ci + 0.06, cj + 0.03, 0.26 * wide, 0.22 * wide, 0.45)
        val balls = 5 + (v / 3) % 2 * 2 + (if (kind == 2) 2 else 0)
        for (b in 0 until balls) {
            val a = 2 * PI * b / balls + rnd(b, v, seed) * 0.8
            val off = if (b == 0) 0.0 else (0.1 + rnd(b, v, seed + 11) * 0.07) * wide
            val bi = ci + cos(a) * off; val bj = cj + sin(a) * off
            val r = (0.08 + rnd(b, v, seed + 1) * 0.05) * (if (b == 0) 1.3 else 1.0) * (if (kind == 2) 0.9 else 1.0)
            val rz = r * 84 * hgt * 0.8
            val bz = rz * 0.7 + (if (b == 0) 8.0 else rnd(b, v, seed + 12) * 6) * hgt
            for (k in 0 until 1400) {
                // a point on or a little inside the clump; leaves stick out at the rim
                val u = rnd(k, b, seed + 2) * 2 - 1; val th = rnd(k, b, seed + 3) * 2 * PI
                val sq = sqrt(1 - u * u)
                val ni = sq * cos(th); val nj = sq * sin(th); val nz = u
                val depth = 0.75 + rnd(k, b, seed + 4) * 0.3 + (if (rnd(k, b, seed + 13) < 0.06) 0.3 else 0.0)
                val ruff = 1 + (vnoise(th * 4 + b, u * 4, seed + 5) - 0.5) * 0.5
                val z = bz + nz * rz * depth * ruff
                if (z < 1) continue
                val i = bi + ni * r * depth * ruff; val j = bj + nj * r * depth * ruff
                val inner = (1.08 - depth) * 2.5
                var col = mix(light, dark, (0.55 - nz * 0.35 + max(0.0, nj) * 0.25 - max(0.0, ni) * 0.15 + inner * 0.3 + rnd(k, b, seed + 6) * 0.2).coerceIn(0.0, 1.0))
                if (kind == 1 && rnd(k, b, seed + 7) < 0.05 && nz > -0.2) col = shade(col, 1.35)
                // a leaf: two or three pixels along a little tilt
                val li = cos(th + 1.0) * 0.012; val lj = sin(th + 1.0) * 0.012
                val lc = shade(col, lit(ni, nj, nz) * 0.85 + 0.25)
                c.pt(i, j, z, lc); c.pt(i + li, j + lj, z + 0.6, lc); c.pt(i - li, j - lj, z - 0.6, shade(lc, 0.9))
            }
            // berries on holly and bramble
            if (kind != 0) for (k in 0 until 9) {
                val u = rnd(k, b, seed + 8) * 0.9; val th = rnd(k, b, seed + 9) * 2 * PI
                val sq = sqrt(1 - u * u)
                val bc = if (kind == 1) argb(0xB02A1E) else argb(0x2A1A2E)
                val i = bi + sq * cos(th) * r * 1.02; val j = bj + sq * sin(th) * r * 1.02; val z = bz + u * rz * 1.02
                c.pt(i, j, z, bc); c.pt(i + 0.006, j, z, bc); c.pt(i, j, z + 0.8, shade(bc, 1.5))
            }
        }
        // a twig or two at the foot
        for (t in 0 until 2) {
            val a = rnd(t, v, seed + 10) * 2 * PI
            for (q in 0..20) {
                val f = q / 20.0
                c.pt(ci + cos(a) * (0.08 + f * 0.14 * wide), cj + sin(a) * (0.08 + f * 0.14 * wide), 3 + f * 6, argb(0x3A2C20))
            }
        }
        return c.img
    }

    /** A bush standing with its foot at ([fx], [fy]) in world pixels, as an upright thing sorted like a figure there. */
    fun bushObj(fx: Int, fy: Int, v: Int): WorldArt.Obj {
        val img = synchronized(cache) { cache.getOrPut("bush/$v") { bush(v) } }
        val T = WorldArt.T
        val wx = fx + T / 2; val wy = fy + T / 2
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, fx + fy - T + T * 3 / 2 - 1 - wx, 2, true, corner = true)
    }


    /**
     * A fern of the undergrowth seen diagonally (56, draft): fronds rising from one crown in an arch and drooping at
     * the tip, each a stalk with leaflets on both sides that shorten towards the tip; lit from above and the right.
     * Three kinds by [v] % 3: male fern (fresh green), a dark dense one, bracken going brown at the tips; [v] / 3 gives
     * more fronds.
     */
    fun fern(v: Int): PixelImage {
        val c = Canvas(56)
        val seed = 930 + v * 29
        val kind = v % 3
        val (light, dark) = when (kind) {
            0 -> argb(0x7C9A48) to argb(0x2C4222)
            1 -> argb(0x5E7A40) to argb(0x1C2C18)
            else -> argb(0x8E8E48) to argb(0x3A3C20)
        }
        val ci = -0.5; val cj = -0.5
        c.shadow(ci + 0.04, cj + 0.03, 0.22, 0.18, 0.4)
        val fronds = 6 + (v / 3) * 2 + hash(v, 1, seed) % 2
        for (f in 0 until fronds) {
            val a = 2 * PI * f / fronds + (rnd(f, v, seed) - 0.5) * 0.7
            val len = 0.17 + rnd(f, v, seed + 1) * 0.08
            val rise = 24 + rnd(f, v, seed + 2) * 12
            val ca = cos(a); val sa = sin(a)
            val n = 70
            for (q in 0..n) {
                val t = q.toDouble() / n
                val r = len * t
                // up from the crown, the highest a little past the middle, the tip bent down again
                val z = 1 + rise * (2.4 * t - 1.9 * t * t)
                val ri = ci + ca * r; val rj = cj + sa * r
                var base = mix(light, dark, (0.7 - t * 0.5 + rnd(q, f, seed + 3) * 0.12).coerceIn(0.0, 1.0))
                if (kind == 2 && t > 0.65) base = mix(base, argb(0x8A6232), (t - 0.65) * 2.2)
                c.pt(ri, rj, z, shade(base, 0.7))
                if (q % 3 != 0 || t < 0.08) continue
                // the leaflets: longest a third along, angled forwards, drooping a little
                val ll = 0.055 * (1 - t) * (0.55 + 0.45 * sin(PI * t)) + 0.008
                for (s in listOf(-1.0, 1.0)) {
                    for (m in 1..9) {
                        val u = m / 9.0
                        val li = ri + (-sa * s + ca * 0.45) * ll * u; val lj = rj + (ca * s + sa * 0.45) * ll * u
                        val lz = z - u * 3.5 * (0.5 + t)
                        val ni = -sa * s * 0.45 + ca * 0.2; val nj = ca * s * 0.45 + sa * 0.2
                        val col = shade(mix(base, dark, u * 0.25), lit(ni, nj, 0.85) * 0.85 + 0.2)
                        c.pt(li, lj, lz, col); c.pt(li, lj, lz + 0.7, col)
                    }
                }
            }
        }
        return c.img
    }

    /** A fern standing with its foot at ([fx], [fy]) in world pixels, sorted like a bush there. */
    fun fernObj(fx: Int, fy: Int, v: Int): WorldArt.Obj {
        val img = synchronized(cache) { cache.getOrPut("fern/$v") { fern(v) } }
        val T = WorldArt.T
        val wx = fx + T / 2; val wy = fy + T / 2
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, fx + fy - T + T * 3 / 2 - 1 - wx, 2, true, corner = true)
    }

    // ------------------------------------------------------------------ the small life of the forest floor (D29.3)

    /**
     * The small things lying on the forest floor (D29.3), seen diagonally like the bushes: [v] % 3 the kind, [v] / 3
     * one of three looks of it. Mushrooms (brown boletes, a clump of honey fungus, two dull red fly agarics on a patch
     * of moss); cones in a patch of fallen needles; a dead branch with its twigs (grey and bare, mossy, with dry
     * leaves). All low: the hero steps over them.
     */
    fun litter(v: Int): PixelImage {
        val c = Canvas(40)
        val seed = 1110 + v * 41
        val look = (v / 3) % 3
        val ci = -0.5; val cj = -0.5
        when (v % 3) {
            0 -> {
                // a patch of moss or leaf mould under the clump
                for (k in 0 until 1400) {
                    val r = sqrt(rnd(k, v, seed)) * 0.11; val a = rnd(k, v, seed + 1) * 2 * PI
                    val col = if (look == 2) mix(argb(0x4A5A2A), argb(0x2E3A1C), rnd(k, v, seed + 2)) else mix(argb(0x5A4630), argb(0x3A2C1E), rnd(k, v, seed + 2))
                    c.pt(ci + cos(a) * r, cj + sin(a) * r * 0.9, 0.3 + rnd(k, v, seed + 3) * 0.8, col)
                }
                val n = when (look) { 0 -> 3; 1 -> 6; else -> 2 }
                for (m in 0 until n) {
                    val a = 2 * PI * m / n + rnd(m, v, seed + 4) * 0.9
                    val off = if (m == 0 && look != 1) 0.0 else 0.06 + rnd(m, v, seed + 5) * 0.06
                    val mi = ci + cos(a) * off; val mj = cj + sin(a) * off
                    // stem height and cap radius in height units and tiles; boletes stout, honey fungus slender in a tuft
                    val (sh, cr) = when (look) {
                        0 -> (8.0 + rnd(m, v, seed + 6) * 6) to (0.042 + rnd(m, v, seed + 7) * 0.02)
                        1 -> (6.0 + rnd(m, v, seed + 6) * 7) to (0.024 + rnd(m, v, seed + 7) * 0.012)
                        else -> (12.0 + rnd(m, v, seed + 6) * 5) to (0.045 + rnd(m, v, seed + 7) * 0.014)
                    }
                    val sr = cr * (if (look == 0) 0.55 else 0.3)
                    val stem = when (look) { 0 -> argb(0xC8B896); 1 -> argb(0xB8A47A); else -> argb(0xD8D0BC) }
                    val cap = when (look) { 0 -> argb(0x6A4024); 1 -> argb(0x8A6A3A); else -> argb(0x8E2A1C) }
                    val tilt = (rnd(m, v, seed + 8) - 0.5) * 0.02
                    for (q in 0..(sh * 3).toInt()) for (s in 0 until 14) {
                        val z = q / 3.0; val th = 2 * PI * s / 14
                        val bulge = if (look == 0) 1.0 + 0.35 * (1 - z / sh) else 1.0
                        c.pt(mi + cos(th) * sr * bulge + tilt * z / sh, mj + sin(th) * sr * bulge, z, shade(stem, lit(cos(th), sin(th), 0.2) * 0.9))
                    }
                    // the cap: a flattened dome, darker at its rim, the agaric's flecked white
                    for (q in 0 until 260) {
                        val u = rnd(q, m, seed + 9); val th = rnd(q, m, seed + 10) * 2 * PI
                        val e = sqrt(u)
                        val i = mi + tilt + cos(th) * cr * e; val j = mj + sin(th) * cr * e
                        val z = sh + (1 - e * e) * cr * 120 * (if (look == 1) 0.6 else 0.8)
                        var col = mix(cap, shade(cap, 0.6), e * e * 0.7)
                        if (look == 2 && rnd(q, m, seed + 11) < 0.08) col = argb(0xD8CCB0)
                        c.pt(i, j, z, shade(col, lit(cos(th) * e, sin(th) * e, 1 - e * 0.6)))
                    }
                }
                c.shadow(ci + 0.03, cj + 0.02, 0.12, 0.1, 0.3)
            }
            1 -> {
                // fallen needles: a brown patch of short strokes
                val pr = 0.16 + look * 0.03
                for (k in 0 until 380) {
                    // a ragged edge, thinning out towards it, so the patch never reads as a ring
                    val a = rnd(k, v, seed + 1) * 2 * PI
                    val r = sqrt(rnd(k, v, seed)) * pr * (0.55 + vnoise(a * 1.6, look.toDouble(), seed + 12) * 0.7)
                    val i = ci + cos(a) * r; val j = cj + sin(a) * r * 0.85
                    val d = rnd(k, v, seed + 2) * PI
                    val col = mix(argb(0x5E4630), argb(0x3A2C1C), rnd(k, v, seed + 3))
                    for (t in 0..3) c.pt(i + cos(d) * t * 0.004, j + sin(d) * t * 0.004, 0.3, col)
                }
                // the cones: scaled spindles lying on their side
                val n = 2 + look
                for (m in 0 until n) {
                    val a = rnd(m, v, seed + 4) * 2 * PI; val r = sqrt(rnd(m, v, seed + 5)) * pr * 0.8
                    val mi = ci + cos(a) * r; val mj = cj + sin(a) * r * 0.85
                    val d = rnd(m, v, seed + 6) * PI
                    val len = 0.11 + rnd(m, v, seed + 7) * 0.03; val rad = len * 0.38
                    val base = if (look == 1) argb(0x7A5232) else argb(0x684426)
                    for (q in 0..40) for (s in 0 until 16) {
                        val f = q / 40.0 - 0.5; val th = 2 * PI * s / 16
                        val rr = rad * sqrt((1 - 4 * f * f).coerceAtLeast(0.0)) * (if (f > 0) 0.85 else 1.0)
                        if (th > PI * 1.1) continue
                        val scale = sin(f * 60 + th * 3) > 0.3
                        val col = shade(if (scale) shade(base, 1.35) else shade(base, 0.8), lit(-sin(d) * cos(th), cos(d) * cos(th), sin(th)))
                        c.pt(mi + cos(d) * f * len * 2 - sin(d) * cos(th) * rr, mj + sin(d) * f * len * 2 + cos(d) * cos(th) * rr, rr * 84 * sin(th) + rr * 84, col)
                    }
                }
            }
            else -> {
                // a dead branch: a crooked rod lying along the ground, twigs off it
                val d = rnd(v, 1, seed) * PI
                val len = 0.5 + look * 0.06
                val bark = when (look) { 0 -> argb(0x8A8478); 1 -> argb(0x5A4632); else -> argb(0x6A5038) }
                fun rod(i0: Double, j0: Double, z0: Double, dir: Double, l: Double, r0: Double, rise: Double, key: Int) {
                    val n = (l * 300).toInt()
                    for (q in 0..n) {
                        val f = q.toDouble() / n
                        val wob = (vnoise(f * 5, key.toDouble(), seed + 1) - 0.5) * 0.05
                        val i = i0 + cos(dir + wob * 4) * f * l; val j = j0 + sin(dir + wob * 4) * f * l
                        val rr = r0 * (1 - f * 0.6)
                        for (s in 0 until 10) {
                            val th = PI * s / 9
                            var col = bark
                            if (look == 1 && sin(th) > 0.8 && vnoise(f * 12, key.toDouble(), seed + 2) > 0.62) col = argb(0x4E5A2C)
                            c.pt(i - sin(dir) * cos(th) * rr, j + cos(dir) * cos(th) * rr, z0 + rise * f + rr * 84 * sin(th), shade(col, lit(-sin(dir) * cos(th), cos(dir) * cos(th), sin(th))))
                        }
                    }
                }
                val i0 = ci - cos(d) * len / 2; val j0 = cj - sin(d) * len / 2
                c.shadow(ci + 0.02, cj + 0.02, 0.22, 0.1, 0.28)
                rod(i0, j0, 0.0, d, len, 0.032, 0.0, 0)
                for (t in 0 until 3 + look) {
                    val f = 0.2 + rnd(t, v, seed + 3) * 0.7
                    val side = if (t % 2 == 0) 1 else -1
                    rod(i0 + cos(d) * f * len, j0 + sin(d) * f * len, 1.0, d + side * (0.5 + rnd(t, v, seed + 4) * 0.5), 0.1 + rnd(t, v, seed + 5) * 0.1, 0.012, 1.0 + rnd(t, v, seed + 6) * 4, t + 1)
                }
                // dry leaves round about
                if (look == 2) for (k in 0 until 14) {
                    val a = rnd(k, v, seed + 7) * 2 * PI; val r = 0.04 + rnd(k, v, seed + 8) * 0.14
                    val col = mix(argb(0x7E5C32), argb(0x5A3A22), rnd(k, v, seed + 9))
                    val li = ci + cos(a) * r; val lj = cj + sin(a) * r * 0.8
                    for (p in 0 until 18) { val e = rnd(p, k, seed + 10); val g = rnd(p, k, seed + 11) - 0.5; c.pt(li + e * 0.02, lj + g * 0.014 * (1 - e), 0.5, shade(col, 0.9 + e * 0.2)) }
                }
            }
        }
        return c.img
    }

    /** A thing of the forest floor ([litter]) with its middle at ([fx], [fy]) in world pixels; flat, so drawn under the figures. */
    fun litterObj(fx: Int, fy: Int, v: Int): WorldArt.Obj {
        val img = synchronized(cache) { cache.getOrPut("litter/$v") { litter(v) } }
        val T = WorldArt.T
        val wx = fx + T / 2; val wy = fy + T / 2
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, fy - T, 2, true, corner = true)
    }

    /**
     * A tree stump with its roots (D29.3): sawn flat and showing its rings, or broken off and splintered, moss on the
     * north side; roots running out into the ground. Three looks by [v]; it stands where a tree would, so one cannot
     * walk through it.
     */
    fun stump(v: Int): PixelImage {
        val c = Canvas(64)
        val seed = 1180 + v * 43
        val ci = -0.5; val cj = -0.5
        val r = 0.11 + v * 0.015; val h = 18.0 + v * 5
        val bark = when (v) { 0 -> argb(0x5C4632); 1 -> argb(0x6E6A5E); else -> argb(0x3E3026) }
        val moss = argb(0x4E5A2C)
        c.shadow(ci + 0.05, cj + 0.03, r * 1.9, r * 1.6, 0.45)
        // the roots: thick at the trunk, dwindling into the ground
        for (k in 0 until 4 + v) {
            val a = 2 * PI * k / (4 + v) + rnd(k, v, seed) * 0.6
            val len = 0.09 + rnd(k, v, seed + 1) * 0.07
            for (q in 0..80) {
                val f = q / 80.0
                val rr = r * 0.4 * (1 - f * 0.8)
                val i = ci + cos(a) * (r * 0.8 + f * len); val j = cj + sin(a) * (r * 0.8 + f * len)
                val top = (1 - f) * 7
                for (s in 0 until 10) {
                    val th = PI * s / 9
                    c.pt(i - sin(a) * cos(th) * rr, j + cos(a) * cos(th) * rr, top * sin(th), shade(bark, lit(-sin(a) * cos(th), cos(a) * cos(th), sin(th)) * 0.95))
                }
            }
        }
        // the trunk: a ring of bark, uneven at the top where it broke ([v] 1)
        fun topAt(th: Double) = if (v == 1) h + (vnoise(th * 2.5, 0.5, seed + 2) - 0.5) * 14 else h
        for (s in 0 until 220) {
            val th = 2 * PI * s / 220
            val ni = cos(th); val nj = sin(th)
            val tz = topAt(th)
            var z = 0.0
            while (z <= tz) {
                val fur = vnoise(th * 10, z / 5, seed + 3)
                var col = mix(bark, shade(bark, 0.55), if (fur > 0.62) 0.8 else fur * 0.3)
                if (nj < -0.2 && ni < 0.3 && vnoise(th * 3, z / 7, seed + 4) > 0.45) col = mix(col, moss, 0.8)
                c.pt(ci + ni * r, cj + nj * r, z, shade(col, lit(ni, nj, 0.0)))
                z += 0.5
            }
        }
        // the top: rings on a sawn face, a dark rotten heart or splinters where it broke
        for (a in 0..200) for (q in 0..30) {
            val th = 2 * PI * a / 200; val e = q / 30.0
            val z = if (v == 1) topAt(th) * (0.75 + 0.25 * e) else h
            val ring = sin(e * 30 + vnoise(th * 3, e * 4, seed + 5) * 3)
            var col = mix(argb(0xB49A72), argb(0x8A6E4E), 0.5 + 0.5 * ring)
            if (v == 2) col = mix(col, argb(0x3A2A1C), (1 - e).coerceAtLeast(0.0) * 0.8)
            if (e > 0.92) col = shade(bark, 0.7)
            c.pt(ci + cos(th) * r * e, cj + sin(th) * r * e, z, shade(col, if (v == 1) 0.85 + e * 0.2 else 1.02))
        }
        return c.img
    }

    /** A stump ([stump]) standing with its foot at ([fx], [fy]) in world pixels, sorted like a bush there. */
    fun stumpObj(fx: Int, fy: Int, v: Int): WorldArt.Obj {
        val img = synchronized(cache) { cache.getOrPut("stump/$v") { stump(v) } }
        val T = WorldArt.T
        val wx = fx + T / 2; val wy = fy + T / 2
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, fx + fy - T + T * 3 / 2 - 1 - wx, 2, true, corner = true)
    }


    /**
     * A clump of reeds standing in the water at ([ci], [cj]) (27.5, draft): thin blades rising and bending a little,
     * olive green going straw-coloured at the tips, with the brown heads of bulrushes in [v] % 3 == 1; [v] / 3 a fuller
     * clump.
     */
    fun reeds(v: Int, ci: Double, cj: Double): PixelImage {
        val c = Canvas(110)
        val seed = 1020 + v * 37
        val kind = v % 3
        val blades = 44 + (v / 3) * 18 + kind * 6
        val green = argb(if (kind == 2) 0x6A7440 else 0x5A6E3A); val straw = argb(0xA89A62); val dark = argb(0x2A3420)
        for (b in 0 until blades) {
            val r = sqrt(rnd(b, v, seed)) * 0.14; val a = rnd(b, v, seed + 1) * 2 * PI
            val bi = ci + cos(a) * r; val bj = cj + sin(a) * r * 0.8
            val hgt = 40 + rnd(b, v, seed + 2) * 38
            val lean = 0.03 + rnd(b, v, seed + 3) * 0.12
            // they fan out from the clump, a little wind bending all the same way
            val la = a + (rnd(b, v, seed + 4) - 0.5) * 0.8
            val n = (hgt * 2).toInt()
            for (q in 0..n) {
                val f = q.toDouble() / n
                val bend = lean * f * f
                val i = bi + cos(la) * bend; val j = bj + sin(la) * bend
                val col = mix(mix(dark, green, (f * 2.2).coerceAtMost(1.0)), straw, ((f - 0.6) * 2).coerceIn(0.0, 0.8))
                c.pt(i, j, f * hgt, shade(col, lit(cos(la) * 0.5, sin(la) * 0.5, 0.4) + rnd(b, q, seed + 5) * 0.08))
            }
            // the bulrush's head: a brown spindle below the tip
            if (kind == 1 && b % 4 == 0) {
                val i = bi + cos(la) * lean * 0.6; val j = bj + sin(la) * lean * 0.6
                for (q in 0..20) for (k in 0 until 6) {
                    val an = k * PI / 3; val z = hgt * 0.72 + q * 0.5
                    c.pt(i + cos(an) * 0.012, j + sin(an) * 0.012, z, shade(argb(0x5A3A22), lit(cos(an), sin(an), 0.2)))
                }
            }
        }
        // the ring of ripples at the clump's foot
        for (k in 0 until 90) {
            val a = k * 2 * PI / 90
            if (vnoise(a * 2.5, 0.0, seed + 6) < 0.5) continue
            val rr = 1 + (vnoise(a * 4.0, 1.0, seed + 7) - 0.5) * 0.3
            c.pt(ci + cos(a) * 0.17 * rr, cj + sin(a) * 0.14 * rr, 0.0, argb(0x3E4C4E))
        }
        return c.img
    }

    // ------------------------------------------------------------------ the yards of the village (56, draft)


    /**
     * A haystack seen diagonally (56, draft), in three looks by [v]: a rick built round a pole whose end sticks out
     * (weathered grey at the top, golden below), a low loose heap with a pitchfork stuck in it, a round cock. Straws run
     * down the sides, single ones stick out; lit from above and the right.
     */
    /** 89: the radius (tiles) and height (upright units) of the hay on ([tx], [ty]), for its shadow ([MapSun]). */
    fun hayShape(tx: Int, ty: Int): Pair<Double, Double> = haySize(Math.floorMod(hash(tx, ty, 38), 3))
    private fun haySize(v: Int) = when (v) { 0 -> 0.38; 1 -> 0.42; else -> 0.34 } to when (v) { 0 -> 100.0; 1 -> 55.0; else -> 78.0 }

    fun hay(v: Int): PixelImage {
        val c = Canvas(140)
        val seed = 960 + v * 31
        val ci = -0.5; val cj = -0.5
        val (R, H) = haySize(v)
        val bulge = when (v) { 0 -> 2.0; 1 -> 0.9; else -> 2.8 }
        val gold = argb(0xC4A866); val straw = argb(0x9A8048); val deep = argb(0x5E4A26); val grey = argb(0x8A8270)
        // the side: radius by height, slumped a little to one side
        fun rad(u: Double) = R * (1 - u.pow(bulge)).coerceAtLeast(0.0).pow(0.55)
        for (k in 0 until 60000) {
            val u = rnd(k, v, seed) ; val th = rnd(k, v, seed + 1) * 2 * PI
            val r = rad(u) * (0.97 + rnd(k, v, seed + 2) * 0.05)
            val i = ci + cos(th) * r * (if (v == 1) 1.1 else 1.0); val j = cj + sin(th) * r * 0.92
            val z = u * H
            // the normal: outwards, tilting up where the side flattens
            val dr = (rad((u + 0.02).coerceAtMost(1.0)) - rad(u)) / 0.02 / H * ZT
            val nl = sqrt(1 + dr * dr)
            val ni = cos(th) / nl; val nj = sin(th) / nl; val nz = -dr / nl
            val streak = vnoise(th * 22.0, u * 3.0, seed + 3)
            var col = mix(gold, straw, (0.25 + streak * 0.5 + rnd(k, v, seed + 4) * 0.2).coerceIn(0.0, 1.0))
            if (streak > 0.8) col = mix(col, deep, 0.45)
            // rain has greyed the top of the rick and the cock
            if (v != 1 && u > 0.55) col = mix(col, grey, ((u - 0.55) * 1.6 * vnoise(th * 3.0, u * 5.0, seed + 5)).coerceIn(0.0, 0.8))
            // the foot lies in its own shade
            if (u < 0.08) col = shade(col, 0.75 + u * 3)
            c.pt(i, j, z, shade(col, lit(ni, nj, nz) * 1.15 - 0.12))
        }
        // single straws sticking out
        for (k in 0 until 28) {
            val u = 0.05 + rnd(k, v, seed + 6) * 0.85; val th = rnd(k, v, seed + 7) * 2 * PI
            val r = rad(u); val len = 0.02 + rnd(k, v, seed + 8) * 0.03
            val tilt = (rnd(k, v, seed + 9) - 0.5) * 1.4
            for (q in 0..12) {
                val f = q / 12.0
                c.pt(ci + cos(th + tilt * f * 0.3) * (r + len * f), cj + sin(th + tilt * f * 0.3) * (r + len * f) * 0.92, u * H - f * 4, shade(straw, 1.05 - f * 0.2))
            }
        }
        fun stick(i0: Double, j0: Double, z0: Double, i1: Double, j1: Double, z1: Double, rr: Double, col: Int) {
            val n = 240
            for (q in 0..n) {
                val f = q.toDouble() / n
                val i = i0 + (i1 - i0) * f; val j = j0 + (j1 - j0) * f; val z = z0 + (z1 - z0) * f
                for (a in 0 until 6) {
                    val an = a * PI / 3
                    c.pt(i + cos(an) * rr, j + sin(an) * rr, z, shade(col, lit(cos(an), sin(an), 0.0)))
                }
            }
        }
        when (v) {
            // the pole of the rick
            0 -> stick(ci, cj, H * 0.8, ci + 0.01, cj, H + 18, 0.012, argb(0x5A4430))
            // a pitchfork stuck into the heap, its handle leaning out to the front right
            1 -> {
                stick(ci + 0.04, cj + 0.0, 32.0, ci + 0.34, cj - 0.2, 84.0, 0.011, argb(0x7A5E3E))
                for (t in -1..1) stick(ci + 0.05 + t * 0.02, cj + 0.02 - t * 0.02, 30.0, ci + 0.0 + t * 0.02, cj - 0.01 - t * 0.02, 18.0, 0.004, argb(0x3A3A3E))
            }
            else -> {}
        }
        return c.img
    }

    private val cloths = intArrayOf(0xC8C0AC, 0x8A9AA8, 0xB09A6A, 0x8A5A44, 0xD0CCBE, 0x6A7A5A)

    /**
     * One tile of a washing line running along i (a run of [Tile.WASHLINE] across the map's row) seen diagonally (56,
     * draft): a post at each end, the rope sagging between them over the whole run, linen sheets, shirts and small
     * cloths hung on it; [k] is this tile's place in the run of [n] tiles.
     */
    fun washline(k: Int, n: Int, seed: Int): PixelImage {
        val c = Canvas(140)
        val cj = -0.5
        val top = 105.0
        val g0 = 0.12; val g1 = n - 0.12
        // where along the whole run (0..n) a point of this tile lies
        fun i(g: Double) = g - k - 1
        fun rope(g: Double) = top - 6 - 12 * sin(PI * ((g - g0) / (g1 - g0)).coerceIn(0.0, 1.0))
        fun inTile(g: Double) = g >= k - 0.02 && g <= k + 1.02
        val wood = argb(0x5A4430)
        for (g in listOf(g0, g1)) if (inTile(g)) {
            for (zz in 0..(top * 3).toInt()) for (a in 0 until 8) {
                val an = a * PI / 4; val z = zz / 3.0
                c.pt(i(g) + cos(an) * 0.025, cj + sin(an) * 0.025, z, shade(mix(wood, argb(0x3A2C20), vnoise(z / 6, an, seed)), lit(cos(an), sin(an), 0.0)))
            }
        }
        // the rope
        var g = g0
        while (g <= g1) { if (inTile(g)) c.pt(i(g), cj, rope(g), argb(0x9A9280)); c.pt(i(g), cj, rope(g) - 0.6, argb(0x7A7262)); g += 0.003 }
        // the washing: along the rope, each piece by its own lot
        var at = g0 + 0.15; var p = 0
        while (at < g1 - 0.2) {
            val kind = hash(p, n, seed) % 3
            val w = when (kind) { 0 -> 0.32 + rnd(p, n, seed + 1) * 0.12; 1 -> 0.24; else -> 0.1 + rnd(p, n, seed + 2) * 0.05 }
            val hh = when (kind) { 0 -> 42.0 + rnd(p, n, seed + 3) * 12; 1 -> 34.0; else -> 18.0 + rnd(p, n, seed + 4) * 8 }
            val col = argb(cloths[hash(p, n, seed + 5) % cloths.size])
            if (at + w > g1 - 0.1) break
            var gg = at
            while (gg <= at + w) {
                if (inTile(gg)) {
                    val f = (gg - at) / w
                    val z0 = rope(gg)
                    // a shirt: sleeves hang only at the shoulders, the body narrower
                    val drop = if (kind == 1) (if (f < 0.22 || f > 0.78) hh * 0.4 else hh) else hh
                    val wave = sin(f * PI * 3 + p) * 0.012
                    val nI = cos(f * PI * 3 + p) * 0.4
                    var zz = 0.0
                    while (zz <= drop) {
                        val fold = 0.88 + 0.12 * sin(gg * 90 + zz * 0.08)
                        val col2 = shade(col, (lit(nI, 0.9, 0.1) * 1.05 + 0.08) * fold - (if (zz > drop - 1.5) 0.15 else 0.0))
                        c.pt(i(gg), cj + 0.01 + wave, z0 - 1 - zz, col2)
                        zz += 0.6
                    }
                }
                gg += 0.003
            }
            at += w + 0.06 + rnd(p, n, seed + 6) * 0.1; p++
        }
        return c.img
    }

    /** The herb on ([tx], [ty]) as an upright thing sorted like the others of the woods; the wind sways it a little. */
    fun herbObj(tx: Int, ty: Int, clock: Long): WorldArt.Obj {
        val v = Math.floorMod(hash(tx, ty, 34), 3)
        val step = Math.floorMod(clock / 600 + tx + ty, 4L).toInt()
        val sway = listOf(0.0, 0.6, 0.0, -0.6)[step]
        val img = synchronized(cache) { cache.getOrPut("herb/$v/$step") { herb(v, sway) } }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, true, corner = true)
    }

    private val fieldCache = HashMap<String, PixelImage>()

    /** The village's beds and fields seen diagonally, or null for other tiles. */
    fun fieldObjects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        val key: Pair<String, () -> PixelImage> = when (t) {
            Tile.VEG_BED -> {
                var y0 = ty; while (map.tile(tx, y0 - 1) == Tile.VEG_BED) y0--
                val v = Math.floorMod(ty - y0 + hash(tx / 8, y0, 33), 3)
                "veg/$tx/$ty/$v" to { vegBed(v, tx, ty) }
            }
            Tile.CROPS -> {
                val e = booleanArrayOf(map.tile(tx - 1, ty) != t, map.tile(tx + 1, ty) != t, map.tile(tx, ty - 1) != t, map.tile(tx, ty + 1) != t)
                "corn/$tx/$ty" to { corn(tx, ty, e) }
            }
            Tile.HAY -> Math.floorMod(hash(tx, ty, 38), 3).let { v -> "hay/$v" to { hay(v) } }
            // D6.3: reeds along the river in the village too, as in the woods, but not beside the bridge
            Tile.WATER -> return if ((-1..1).any { d -> map.tile(tx + d, ty) == Tile.BRIDGE || map.tile(tx, ty + d) == Tile.BRIDGE }) null
                else objects(map, tx, ty, 0)
            Tile.WASHLINE -> {
                var x0 = tx; while (map.tile(x0 - 1, ty) == Tile.WASHLINE) x0--
                var n = 0; while (map.tile(x0 + n, ty) == Tile.WASHLINE) n++
                "wash/$x0/$ty/$tx" to { washline(tx - x0, n, 990 + x0 + ty * 7) }
            }
            else -> return null
        }
        val img = synchronized(fieldCache) { fieldCache.getOrPut(key.first) { key.second() } }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, t != Tile.HAY && t != Tile.WASHLINE, corner = true))
    }

    // ------------------------------------------------------------------ on the map

    private val cache = HashMap<String, PixelImage>()

    /** The new pictures for one tile of the woods seen diagonally, or null where the former ones stay. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int, open: Boolean = false): List<WorldArt.Obj>? {
        // D6.3: the village asks only for the reeds along its river
        if (map.kind != MapKind.FOREST && !(map.kind == MapKind.TOWN && map.tile(tx, ty) == Tile.WATER)) return null
        val t = map.tile(tx, ty)
        val key: Pair<String, () -> PixelImage> = when (t) {
            Tile.LOG -> {
                // one look for the whole trunk, by the tile where it begins
                var x0 = tx; while (map.tile(x0 - 1, ty) == Tile.LOG) x0--
                val v = Math.floorMod(hash(x0, ty, 31), 3)
                val l = map.tile(tx - 1, ty) != Tile.LOG; val r = map.tile(tx + 1, ty) != Tile.LOG
                "log/$v/$l/$r/$x0/$ty" to { log(v, l, r, 700 + x0 * 13 + ty) }
            }
            Tile.CAVE_WALL, Tile.CAVE_ENTRANCE -> {
                fun rock(x: Int) = map.tile(x, ty).let { it == Tile.CAVE_WALL || it == Tile.CAVE_ENTRANCE }
                val m = t == Tile.CAVE_ENTRANCE; val l = !rock(tx - 1); val r = !rock(tx + 1)
                "cliff/$tx/$ty/$m/$l/$r" to { cliff(m, l, r, tx, 740 + ty) }
            }
            Tile.CAMPFIRE -> {
                val v = Math.floorMod(hash(tx, ty, 32), 3)
                "fire/$v/${frame % 4}" to { campfire(v, frame % 4, 720 + v) }
            }
            // the signs of the woods: the village's signposts, a board on one post or on two; not the look with the
            // arrow, which would point along +i whatever the way
            // D3.7: by its place in the map's order, so the stones of a circle follow one another through the four looks
            // (by hash three of four were alike in both circles)
            Tile.MENHIR -> Math.floorMod(menhirIndex(map, tx, ty), 4).let { v -> "menhir/$v" to { menhir(v) } }
            Tile.ROCK -> Math.floorMod(hash(tx, ty, 36), 3).let { v -> "rock/$v" to { boulders(v) } }
            Tile.CHEST -> Math.floorMod(hash(tx, ty, 35), 3).let { v -> "chest/$v/$open" to { chest(v, open) } }
            // D3.7: three looks and the grain of each its own, so no two signs of the woods are alike
            Tile.SIGN -> Math.floorMod(hash(tx, ty, 33), 3).let { k ->
                val v = intArrayOf(0, 1, 3)[k]; val seed = 71 + 13 * Math.floorMod(hash(tx, ty, 34), 5)
                "sign/$v/$seed" to { MapTownIso.signpost(v, seed) }
            }
            // reeds along the far bank (27.5): where land lies behind the water, now and then a clump near it
            Tile.WATER -> {
                val west = map.tile(tx - 1, ty) != Tile.WATER; val north = map.tile(tx, ty - 1) != Tile.WATER
                if (!(west || north) || hash(tx, ty, 39) % 4 == 3) return emptyList()
                val v = hash(tx, ty, 40) % 6
                val ci = if (west) -0.82 else -0.3 - rnd(tx, ty, 41) * 0.4; val cj = if (north) -0.82 else -0.3 - rnd(tx, ty, 42) * 0.4
                "reeds/$v/$tx/$ty" to { reeds(v, ci, cj) }
            }
            else -> return null
        }
        val img = synchronized(cache) { cache.getOrPut(key.first) { key.second() } }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        // the hero stepping into the cave's mouth stands in front of the face
        val sort = (tx + ty) * T + T * 3 / 2 - 1 - wx - (if (t == Tile.CAVE_WALL || t == Tile.CAVE_ENTRANCE) T / 2 else 0)
        return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, sort, 2, t == Tile.LOG, corner = true))
    }

    /** All looks side by side for the preview sheet: each trunk as a run of three tiles, the fires in two frames. */
    fun sheet(): List<Pair<String, List<PixelImage>>> {
        fun run(v: Int): PixelImage {
            val parts = listOf(log(v, true, false, 700 + v), log(v, false, false, 700 + v), log(v, false, true, 700 + v))
            val out = PixelImage(100 + 90, 90 + 45)
            for ((k, p) in parts.withIndex()) {
                val ox = (k * TW / 2).toInt(); val oy = (k * TH / 2).toInt()
                for (y in 0 until p.height) for (x in 0 until p.width) { val c = p[x, y]; if ((c ushr 24) == 255 || (c ushr 24) > (out[ox + x, oy + y] ushr 24)) out.set(ox + x, oy + y, c) }
            }
            return out
        }
        return listOf(
            "Stamm" to (0 until 3).map { run(it) },
            "Feuer" to (0 until 3).map { campfire(it, 0, 720 + it) },
            "Feuer2" to (0 until 3).map { campfire(it, 1, 720 + it) },
            "Truhe" to (0 until 3).map { chest(it, false) },
            "Truhe offen" to (0 until 3).map { chest(it, true) },
            "Kraut" to (0 until 3).map { herb(it, 0.0) },
            "Steine" to (0 until 3).map { boulders(it) },
            "Menhir" to (0 until 3).map { menhir(it) },
            "Busch" to (0 until 3).map { bush(it) },
            "Busch2" to (3 until 6).map { bush(it) },
            "Farn" to (0 until 3).map { fern(it) },
            "Farn2" to (3 until 5).map { fern(it) },
            "Pilze" to listOf(0, 3, 6).map { litter(it) },
            "Zapfen" to listOf(1, 4, 7).map { litter(it) },
            "Äste" to listOf(2, 5, 8).map { litter(it) },
            "Stumpf" to (0 until 3).map { stump(it) },
            "Heu" to (0 until 3).map { hay(it) },
            "Leine" to (0 until 3).map { washline(it, 3, 990) },
        )
    }
}
