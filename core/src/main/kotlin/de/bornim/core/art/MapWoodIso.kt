package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
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

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
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
        // the earth: ridges along i, furrows between, clods
        var i = -1.02
        while (i <= 0.02) {
            var j = -1.02
            while (j <= 0.02) {
                val ph = ((j + 1) * ridges) % 1.0
                val z = 4.0 * sin(PI * ph) + (vnoise((tx + i) * 30, (ty + j) * 30, seed) - 0.5) * 1.2
                val nj = -cos(PI * ph) * 0.6
                val col = mix(argb(0x4A3A28), argb(0x2A2016), vnoise((tx + i) * 50, (ty + j) * 50, 761))
                c.pt(i, j, z, shade(col, lit(0.0, nj, 1.0)))
                j += 0.004
            }
            i += 0.004
        }
        for (r in 0 until ridges) {
            val rj = -1 + (r + 0.5) / ridges
            for (k in 0 until 4) {
                val pi = -1 + (k + 0.5) / 4 + (rnd(tx * 4 + k, ty * 3 + r, seed) - 0.5) * 0.06
                val pj = rj + (rnd(tx * 4 + k, ty * 3 + r, seed + 1) - 0.5) * 0.04
                val ps = seed + r * 31 + k * 7
                when (v) {
                    0 -> for (a in 0..60) for (b in 0..18) {
                        // a cabbage: a round head in loose outer leaves
                        val az = 2 * PI * a / 60; val el = PI / 2 * b / 18
                        val ni = cos(az) * cos(el); val nj = sin(az) * cos(el); val nz = sin(el)
                        val rad = 0.095 * (1 + (vnoise(az * 2, el * 3, ps) - 0.5) * 0.25)
                        val vein = abs(sin(az * 5 + el * 2)) > 0.94
                        val col = if (vein) argb(0x9AB07A) else mix(argb(0x6A8A4A), argb(0x3E5A2E), 1 - nz)
                        c.pt(pi + rad * ni, pj + rad * nj, 5 + 9 * nz, shade(col, lit(ni, nj, nz)))
                    }
                    1 -> for (l in 0 until 5) {
                        // a leek: pale stem, dark blue-green leaves fanning
                        val a = l * PI * 2 / 5 + rnd(k, l, ps) * 0.6
                        for (t in 0..40) {
                            val f = t / 40.0
                            val z = 4 + f * 26; val off = f * f * 0.07
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
                            val z = 5 + f * 14 - f * f * 6
                            c.pt(pi + cos(a) * f * 0.09 - sin(a) * bw, pj + sin(a) * f * 0.09 + cos(a) * bw, z, shade(mix(argb(0x5E8040), argb(0x3A5A2A), f), 0.85 + 0.25 * (1 - abs(w) / 3.0)))
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
            else -> return null
        }
        val img = synchronized(fieldCache) { fieldCache.getOrPut(key.first) { key.second() } }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, true, corner = true))
    }

    // ------------------------------------------------------------------ on the map

    private val cache = HashMap<String, PixelImage>()

    /** The new pictures for one tile of the woods seen diagonally, or null where the former ones stay. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int): List<WorldArt.Obj>? {
        if (map.kind != MapKind.FOREST) return null
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
            Tile.SIGN -> Math.floorMod(hash(tx, ty, 33), 2).let { v -> "sign/$v" to { MapTownIso.signpost(v, 71) } }
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
        )
    }
}
