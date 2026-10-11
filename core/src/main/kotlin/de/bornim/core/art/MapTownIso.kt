package de.bornim.core.art

import de.bornim.core.HouseFeature
import de.bornim.core.HouseStyle
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.RoofKind
import de.bornim.core.Tile
import de.bornim.core.WallKind
import de.bornim.core.World
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
     * A house picture: [front] the wall along the front, one letter a tile ('#' wall, 'W' window, 'D' door); [side]
     * the east wall the same way; [d] tiles deep; [roof], [walls] and [feature] from the map's [HouseStyle];
     * [chimney] the middle of the chimney along i (null: none), standing at the back wall over the hearth inside;
     * [night] lit windows. The ground under i = j = 0 lies at ([ox], [oy]) of the picture.
     */
    class Picture(val img: PixelImage, val ox: Double, val oy: Double)

    fun house(
        front: String, side: String, d: Int, roof: RoofKind, walls: WallKind, feature: HouseFeature, seed: Int,
        chimney: Double? = null, night: Boolean = false,
    ): Picture {
        val n = front.length
        val lk = looks[Math.floorMod(seed, looks.size)]
        val temple = feature == HouseFeature.BELL_TOWER
        val thatch = roof == RoofKind.STRAW
        val eave = if (temple) 176.0 else 150.0     // eaves at 2.6 m, the temple higher
        val o = 0.28                                // the roof hangs over the walls
        val pitch = if (thatch) 1.25 else 1.0       // rise per run: thatch steeper
        val run = d / 2.0 + o
        val ridge = eave + run * ZT * pitch
        // the chimney at the back wall rises far enough to show a good part over the ridge
        val cjMid = 0.22
        val chimTop = ridge - (d / 2.0 - cjMid) * TH / 2 / ZS + 52
        val towerTop = ridge + 92
        // the picture: from the back corner (0, 0) at the top to the front corner (n, d) on the ground
        val left = d + o + 0.3; val right = n + o + 0.3
        val w = (floor((left + right) * TW / 2 / 4).toInt() + 2) * 4
        val topZ = maxOf(ridge, if (chimney != null) chimTop else 0.0, if (temple) towerTop + 50 else 0.0) + 8
        val h = ((n + d) * TH / 2 + topZ * ZS + 24).toInt() / 2 * 2
        val img = PixelImage(w, h)
        val ox = floor(left * TW / 2) + 2.5         // screen x of i = j = 0 (a half pixel, so strip middles are whole)
        val oy = h - 16 - (n + d) * TH / 2          // screen y of i = j = 0 on the ground
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
            val di = max(-0.2 - i, i - n - 0.1); val dj = max(-0.2 - j, j - d - 0.5)
            val e = max(di, dj)
            if (e > 0.3) continue
            val k = ((0.3 - e) / 0.3).coerceIn(0.0, 1.0) * 0.5
            img.set(px, py, ((k * 255).toInt() shl 24) or 0x0A0806)
        }

        // ---- the walls: the front (j = d, down left, in the house's own shade) and the east side (i = n, in the sun)
        val litFront = 0.72; val litSide = 1.0
        fun surface(u: Double, z: Double, face: Double, s: Int, top: Double): Int = when {
            temple -> ashlarTex(u, z, face, s)
            walls == WallKind.STONE -> stoneTex(u, z, face, s, top)
            walls == WallKind.PLANKS -> planksTex(u, z, face, s)
            else -> wallTex(u, z, face, s, lk, top)
        }
        fun wall(u: Double, z: Double, len: Int, letters: String, face: Double, s: Int): Int? {
            val tile = floor(u).toInt().coerceIn(0, len - 1); val f = u - tile
            val kind = letters.getOrElse(tile) { '#' }
            if (kind == 'D') (if (temple) archDoor(f, z, face, s) else door(f, z, face, s))?.let { return it }
            if (kind == 'W') (if (temple) archWindow(f, z, face, night) else window(f, z, face, night, s + tile))?.let { return it }
            return surface(u, z, face, s, eave)
        }
        plane(p(0.0, d.toDouble(), 0.0), p(n.toDouble(), 0.0, 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * n, v * eave, n, front, litFront, seed) }
        plane(p(n.toDouble(), 0.0, 0.0), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * d, v * eave, d, side, litSide, seed + 31) }
        // the east gable: a triangle over the side wall, up to the ridge in the middle; boarded on plank and stone houses
        plane(p(n.toDouble(), 0.0, eave), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, ridge - eave)) { u, v ->
            val z = v * (ridge - eave)
            val half = 1 - z / (ridge - eave)
            if (abs(u - 0.5) > half * 0.5) null
            else if (temple) ashlarTex(u * d, eave + z, litSide, seed + 31)
            else if (lk.boards || walls != WallKind.TIMBER) boards(u * d, eave + z, litSide * 0.94, seed + 7, false)
            else wallTex(u * d, eave + z, litSide, seed + 31, lk, ridge)
        }

        // ---- the chimney at the back wall: rough stones, soot towards the top; the roof in front hides its foot
        if (chimney != null) {
            val ci0 = chimney - 0.19; val ci1 = chimney + 0.19
            val cj0 = cjMid - 0.19; val cj1 = cjMid + 0.19
            val zBase = eave - 10
            plane(p(ci0, cj1, zBase), p(ci1 - ci0, 0.0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (ci1 - ci0), zBase + v * (chimTop - zBase), litFront, seed + 41, chimTop), 0.8 - 0.3 * v) }
            plane(p(ci1, cj0, zBase), p(0.0, cj1 - cj0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (cj1 - cj0) + 3, zBase + v * (chimTop - zBase), litSide, seed + 43, chimTop), 0.8 - 0.3 * v) }
            plane(p(ci0, cj0, chimTop), p(ci1 - ci0, 0.0, 0.0), p(0.0, cj1 - cj0, 0.0)) { u, v ->
                val rim = u < 0.18 || u > 0.82 || v < 0.18 || v > 0.82
                if (rim) shade(argb(0x5A544C), 0.85 + rnd(floor(u * 9).toInt(), floor(v * 9).toInt(), seed) * 0.2) else argb(0x0E0C0A)
            }
        }

        // ---- the roof: the slope towards us, from the ridge down to the eaves hanging over the front
        val ri0 = -o; val ri1 = n + o
        fun roofTex(u: Double, v: Double): Int {
            val along = u * (ri1 - ri0); val down = v * run
            return when (roof) {
                RoofKind.STRAW -> thatchTex(along, down, run, lk, seed)
                RoofKind.SHINGLE -> shingleTex(along, down, run, seed)
                RoofKind.RED -> clayTex(along, down, run, seed)
                RoofKind.BLUE -> slateTex(along, down, run, seed, 0x4E5A6E)
                RoofKind.SLATE -> slateTex(along, down, run, seed, 0x585C62)
            }
        }
        // the edge of the roof, thick thatch at the eaves and along the gable: a band under the slope
        val thick = if (thatch) 16.0 else 5.0
        plane(p(ri0, d + o, eave - thick), p(ri1 - ri0, 0.0, 0.0), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * (ri1 - ri0), v, !thatch, lk, seed) }
        plane(p(ri1, d / 2.0, ridge - thick), p(0.0, run, eave - ridge), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * run * 2, v, !thatch, lk, seed + 3) }
        plane(p(ri0, d / 2.0, ridge), p(ri1 - ri0, 0.0, 0.0), p(0.0, run, eave - ridge)) { u, v -> roofTex(u, v) }
        // the ridge itself: a rolled band of thatch (or ridge tiles) along the top
        plane(p(ri0 + 0.05, d / 2.0 - 0.06, ridge + 5), p(ri1 - ri0 - 0.1, 0.0, 0.0), p(0.0, 0.16, -10.0)) { u, v ->
            val t = 0.5 + 0.3 * (1 - v) + (rnd(floor(u * 60).toInt(), 0, seed + 9) - 0.5) * 0.15
            when (roof) {
                RoofKind.STRAW -> shade(mix(argb(0x2A2418), argb(lk.thatch), t), 0.9)
                RoofKind.RED -> shade(argb(0x4A2A1E), 0.8 + t * 0.4)
                RoofKind.SHINGLE -> shade(argb(0x3A3028), 0.8 + t * 0.4)
                else -> shade(argb(0x2A2E34), 0.8 + t * 0.4)
            }
        }

        // ---- the temple's bell tower (5g): a square stone tower rising over the east end, a belfry, a pointed cap
        if (temple) {
            val ti0 = n - 1.15; val ti1 = n - 0.1; val tj0 = d / 2.0 - 0.52; val tj1 = d / 2.0 + 0.52
            fun roofZ(j: Double) = ridge - abs(j - d / 2.0) / run * (ridge - eave)
            fun belfry(u: Double, z: Double): Boolean {
                val c = abs(u - 0.5)
                return c < 0.24 && z > towerTop - 58 && z < towerTop - 22 + 9 * Math.sqrt((1 - (c / 0.24) * (c / 0.24)).coerceAtLeast(0.0))
            }
            val z0 = roofZ(tj1) - 6
            plane(p(ti0, tj1, z0), p(ti1 - ti0, 0.0, 0.0), p(0.0, 0.0, towerTop - z0)) { u, v ->
                val z = z0 + v * (towerTop - z0)
                if (belfry(u, z)) { if (abs(u - 0.5) < 0.1 && z > towerTop - 48 && z < towerTop - 28) shade(argb(0x5A4A2E), 0.6 + (z - towerTop + 48) / 50) else argb(0x0C0A0A) }
                else ashlarTex(u * (ti1 - ti0), z, litFront, seed + 51)
            }
            plane(p(ti1, tj0, z0 - 40), p(0.0, tj1 - tj0, 0.0), p(0.0, 0.0, towerTop - z0 + 40)) { u, v ->
                val z = z0 - 40 + v * (towerTop - z0 + 40)
                if (z < roofZ(tj0 + u * (tj1 - tj0)) + 4) null
                else if (belfry(u, z)) argb(0x0C0A0A)
                else ashlarTex(u * (tj1 - tj0) + 2, z, litSide, seed + 53)
            }
            // a cornice, then the pointed cap of slate
            val ci0 = ti0 - 0.06; val ci1 = ti1 + 0.06; val cj0 = tj0 - 0.06; val cj1 = tj1 + 0.06
            plane(p(ci0, cj1, towerTop - 4), p(ci1 - ci0, 0.0, 0.0), p(0.0, 0.0, 6.0)) { _, _ -> shade(argb(0x5A564E), 0.7) }
            plane(p(ci1, cj0, towerTop - 4), p(0.0, cj1 - cj0, 0.0), p(0.0, 0.0, 6.0)) { _, _ -> shade(argb(0x5A564E), 0.95) }
            val capH = 50.0
            plane(p(ci0, cj1, towerTop + 2), p(ci1 - ci0, 0.0, 0.0), p((ci1 - ci0) / 2, -(cj1 - cj0) / 2, capH)) { u, v ->
                if (abs(u - 0.5) > 0.5 * (1 - v)) null else slateTex(u * 1.2, v * 0.8, 0.8, seed + 55, 0x585C62).let { shade(it, 0.75) }
            }
            plane(p(ci1, cj1, towerTop + 2), p(0.0, -(cj1 - cj0), 0.0), p(-(ci1 - ci0) / 2, -(cj1 - cj0) / 2 + (cj1 - cj0) / 2, capH)) { u, v ->
                if (abs(u - 0.5) > 0.5 * (1 - v)) null else slateTex(u * 1.2, v * 0.8, 0.8, seed + 57, 0x585C62)
            }
        }

        // ---- the shop's awning: dull striped cloth on two poles over the front, its hem ragged
        if (feature == HouseFeature.AWNING) {
            val a0 = 0.15; val a1 = n - 0.15; val out = 0.7
            plane(p(a0, d.toDouble(), 128.0), p(a1 - a0, 0.0, 0.0), p(0.0, out, -26.0)) { u, v ->
                val stripe = floor(u * (a1 - a0) * 4).toInt() % 2 == 0
                val c = if (stripe) argb(0x5A3A2A) else argb(0x7A6E58)
                shade(mix(c, argb(0x1A140E), 0.15 + (rnd(floor(u * 80).toInt(), floor(v * 10).toInt(), seed + 61) - 0.5) * 0.2), 0.8 + 0.25 * v)
            }
            plane(p(a0, d + out, 102.0), p(a1 - a0, 0.0, 0.0), p(0.0, 0.0, 12.0)) { u, v ->
                if (v < 0.35 * rnd(floor(u * 40).toInt(), 1, seed + 62) || (u * (a1 - a0) * 8) % 1.0 < 0.08 && v < 0.5) null
                else shade(if (floor(u * (a1 - a0) * 4).toInt() % 2 == 0) argb(0x4A3022) else argb(0x665C4A), 0.7)
            }
            for (pi in listOf(a0 + 0.05, a1 - 0.05)) plane(p(pi - 0.03, d + out, 0.0), p(0.06, 0.0, 0.0), p(0.0, 0.0, 102.0)) { _, v -> shade(argb(0x2E2218), 0.7 + v * 0.3) }
        }

        // ---- the inn's sign: an iron bracket out of the front wall, a board hanging from it
        if (feature == HouseFeature.INN_SIGN) {
            val door = front.indexOf('D').coerceAtLeast(0)
            val si = door + 1.15
            plane(p(si, d.toDouble(), 128.0), p(0.0, 0.62, 0.0), p(0.0, 0.0, 3.0)) { _, _ -> argb(0x1E1C1A) }
            plane(p(si, d + 0.12, 100.0), p(0.0, 0.42, 0.0), p(0.0, 0.0, 24.0)) { u, v ->
                val edge = u < 0.06 || u > 0.94 || v < 0.1 || v > 0.9
                // a tankard burnt into the board
                val mug = abs(u - 0.45) < 0.14 && v in 0.25..0.75 || (abs(u - 0.66) < 0.06 && v in 0.35..0.6)
                if (edge) argb(0x2A1E14) else if (mug) argb(0x1A120C) else shade(argb(0x5A4430), 0.85 + rnd(floor(u * 20).toInt(), floor(v * 6).toInt(), seed + 63) * 0.2)
            }
        }
        return Picture(img, ox, oy)
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
    private fun slateTex(along: Double, down: Double, run: Double, seed: Int, rgb: Int = 0x585C62): Int {
        val row = floor(down / 0.16).toInt()
        val off = if (row % 2 == 0) 0.0 else 0.5
        val col = floor(along / 0.2 + off).toInt()
        var v = 0.5 + (rnd(col, row, seed) - 0.5) * 0.25 + (rnd(floor(along * 60).toInt(), floor(down * 60).toInt(), seed + 1) - 0.5) * 0.08
        if (frac(down / 0.16) > 0.86) v -= 0.3
        if (frac(along / 0.2 + off) < 0.06) v -= 0.22
        if (hash(col, row, seed + 2) % 23 == 0) v -= 0.25
        val lichen = vnoise(along * 3, down * 3, seed + 3) * 0.7 + rnd(floor(along * 45).toInt(), floor(down * 45).toInt(), seed + 4) * 0.5 > 0.95
        val c = mix(argb(0x141618), argb(rgb), v.coerceIn(0.0, 1.0))
        return if (lichen) mix(c, argb(0x7A7A5A), 0.4) else c
    }

    /** Wooden shingles, grey and split, in short overlapping rows, here and there one missing. */
    private fun shingleTex(along: Double, down: Double, run: Double, seed: Int): Int {
        val row = floor(down / 0.12).toInt()
        val off = rnd(row, 0, seed) * 0.3
        val col = floor(along / 0.11 + off).toInt()
        var v = 0.48 + (rnd(col, row, seed + 1) - 0.5) * 0.3 + (rnd(floor(along * 70).toInt(), floor(down * 30).toInt(), seed + 2) - 0.5) * 0.12
        if (frac(down / 0.12) > 0.82) v -= 0.3
        if (frac(along / 0.11 + off) < 0.08) v -= 0.25
        if (hash(col, row, seed + 3) % 31 == 0) v -= 0.35
        var c = mix(argb(0x16120E), argb(0x6A5E50), v.coerceIn(0.0, 1.0))
        if (vnoise(along * 3, down * 4, seed + 4) * (0.6 + 0.6 * down / run) > 0.8) c = mix(c, argb(0x3A4622), 0.45)
        return c
    }

    /** Old clay tiles, dark red-brown and dulled by soot and lichen, in rounded rows. */
    private fun clayTex(along: Double, down: Double, run: Double, seed: Int): Int {
        val row = floor(down / 0.14).toInt()
        val col = floor(along / 0.14).toInt()
        val fu = frac(along / 0.14)
        var v = 0.5 + (rnd(col, row, seed) - 0.5) * 0.25 + (0.5 - abs(fu - 0.5)) * 0.35 - 0.12
        if (frac(down / 0.14) > 0.84) v -= 0.3
        if (fu < 0.06) v -= 0.25
        val c = mix(argb(0x1E100C), argb(0x7A4A36), v.coerceIn(0.0, 1.0))
        val lichen = vnoise(along * 3, down * 3, seed + 3) * 0.7 + rnd(floor(along * 45).toInt(), floor(down * 45).toInt(), seed + 4) * 0.5 > 0.98
        return if (lichen) mix(c, argb(0x6E6A4A), 0.4) else c
    }

    /** Walls of vertical planks, tarred dark at the foot, a footing of stones. */
    private fun planksTex(u: Double, z: Double, face: Double, seed: Int): Int {
        if (z < 16) return stoneTex(u, z, face, seed, 16.0)
        val b = floor(u * 6).toInt()
        var v = 0.45 + (rnd(b, 0, seed) - 0.5) * 0.25 + (rnd(b, floor(z / 3).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(u * 6) < 0.1) v -= 0.3
        if (abs(z - 92) < 3) v += 0.1
        v -= 0.25 * exp(-(z - 16) / 14)
        return shade(mix(argb(0x14100C), argb(0x5E4C3A), v.coerceIn(0.0, 1.0)), face)
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

    // ------------------------------------------------------------------ small things standing on one tile (5.2)

    /**
     * A picture of one tile's thing: the tile's front corner lies on the middle of the bottom edge; local
     * coordinates run from (−1, −1) at the tile's back corner to (0, 0) at its front corner, as in [MapRoomIso].
     */
    private class Tile1(val h: Int, val w: Int = 100) {
        val img = PixelImage(w, h)
        fun sx(i: Double, j: Double) = w / 2.0 + (i - j) * TW / 2
        fun sy(i: Double, j: Double, z: Double) = h + (i + j) * TH / 2 - z * ZS
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
        /** A box: its faces towards +j (down left, in shade), +i (down right, lit) and its top. */
        fun box(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, tex: (face: Int, u: Double, v: Double) -> Int?) {
            plane(doubleArrayOf(i0, j1, z0), doubleArrayOf(i1 - i0, 0.0, 0.0), doubleArrayOf(0.0, 0.0, z1 - z0)) { u, v -> tex(0, u, v) }
            plane(doubleArrayOf(i1, j0, z0), doubleArrayOf(0.0, j1 - j0, 0.0), doubleArrayOf(0.0, 0.0, z1 - z0)) { u, v -> tex(1, u, v) }
            plane(doubleArrayOf(i0, j0, z1), doubleArrayOf(i1 - i0, 0.0, 0.0), doubleArrayOf(0.0, j1 - j0, 0.0)) { u, v -> tex(2, u, v) }
        }
        fun shadow(ci: Double, cj: Double, r: Double, a: Double = 0.45) {
            for (py in 0 until h) for (px in 0 until w) {
                val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
                val i = (aa + bb) / 2; val j = (bb - aa) / 2
                val d = Math.hypot(i - ci, j - cj) / r
                if (d >= 1) continue
                img.set(px, py, (((1 - d) * a * 255).toInt() shl 24) or 0x0A0806)
            }
        }
    }

    /** Weathered wood: [face] 0 shade, 1 lit, 2 top; [u] along the grain. */
    private fun wood(face: Int, u: Double, v: Double, seed: Int, rgb: Int = 0x5A4430): Int {
        val k = when (face) { 0 -> 0.62; 1 -> 0.95; else -> 1.05 }
        var t = 0.5 + (rnd(floor(v * 7).toInt(), floor(u * 18).toInt(), seed) - 0.5) * 0.25 + (rnd(floor(u * 60).toInt(), floor(v * 40).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(v * 7) < 0.1) t -= 0.25
        return shade(mix(argb(0x140E0A), argb(rgb), t.coerceIn(0.0, 1.0)), k)
    }

    /**
     * A signpost (5.2): a weathered board on its post(s), facing the way along the map's y (seen from the front and
     * from the right), letters burnt into it as dark strokes. Three looks: one post, two posts, an arrow board.
     */
    fun signpost(v: Int, seed: Int): PixelImage {
        val c = Tile1(150)
        c.shadow(-0.45, -0.35, 0.42)
        val j0 = -0.42; val j1 = -0.36
        val (i0, i1) = if (v == 1) -0.86 to -0.14 else -0.82 to -0.18
        val z0 = if (v == 1) 54.0 else 70.0; val z1 = z0 + 30
        fun post(i: Double, top: Double) = c.box(i - 0.04, j0 - 0.07, i + 0.04, j0 + 0.0, 0.0, top) { f, u, w -> wood(f, w, u, seed + 3, 0x4A3828) }
        when (v) {
            1 -> { post(i0 + 0.05, z1 + 2); post(i1 - 0.05, z1 + 2) }
            else -> post(-0.5, z1 + 10)
        }
        // the board: an arrow points along +i on the third look
        c.box(i0, j0, i1, j1, z0, z1) { f, u, w ->
            if (v == 2 && f != 1) {
                val tip = (u - 0.82) / 0.18
                if (tip > 0 && abs(w - 0.5) > 0.5 * (1 - tip)) return@box null
            }
            if (f == 0) {
                // burnt letters: two rows of short strokes
                val row = if (abs(w - 0.68) < 0.08) 0 else if (abs(w - 0.36) < 0.08) 1 else -1
                if (row >= 0 && u in 0.12..(if (v == 2) 0.74 else 0.88) && hash(floor(u * 26).toInt(), row, seed + 5) % 4 != 0 && frac(u * 26) < 0.7)
                    return@box argb(0x150E0A)
            }
            wood(f, u, w, seed + 7)
        }
        return c.img
    }

    /** Splats a round body (cylinder) of radius [r] tiles at (ci, cj) from z0 to z1: its side towards us, then its top by [top]. */
    private fun Tile1.cylinder(ci: Double, cj: Double, r: Double, z0: Double, z1: Double, side: (ang: Double, z: Double, lit: Double) -> Int?, top: ((Double, Double) -> Int?)? = null) {
        val steps = (r * 900).toInt().coerceAtLeast(60)
        var z = z0
        while (z <= z1) {
            for (k in 0..steps) {
                // the half facing the camera (towards +i and +j), lit from the right (+i, −j)
                val ang = -Math.PI / 4 + Math.PI * k / steps
                val i = ci + r * Math.cos(ang); val j = cj + r * Math.sin(ang)
                val lit = 0.6 + 0.4 * ((Math.cos(ang) - Math.sin(ang)) / Math.sqrt(2.0) + 1) / 2
                side(ang, z, lit)?.let { img.set(floor(sx(i, j)).toInt(), floor(sy(i, j, z)).toInt(), it) }
            }
            z += 0.6
        }
        if (top != null) for (py in 0 until h) for (px in 0 until w) {
            val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h + z1 * ZS) / (TH / 2)
            val i = (aa + bb) / 2 - ci; val j = (bb - aa) / 2 - cj
            val d = Math.hypot(i, j) / r
            if (d <= 1) top(d, Math.atan2(j, i))?.let { img.set(px, py, it) }
        }
    }

    private fun stoneRing(ang: Double, z: Double, lit: Double, seed: Int): Int {
        val course = floor(z / 10).toInt()
        val block = floor(ang * 4 + rnd(course, 0, seed) * 2).toInt()
        var t = 0.5 + (rnd(block, course, seed + 1) - 0.5) * 0.35
        if (z % 10 < 1.5 || frac(ang * 4 + rnd(course, 0, seed) * 2) < 0.06) t -= 0.3
        if (z < 8 && rnd(block, 9, seed) > 0.5) return shade(mix(argb(0x2A3218), argb(0x4E5A2E), t), lit)
        return shade(mix(argb(0x1E1C1A), argb(0x7E786C), t.coerceIn(0.0, 1.0)), lit)
    }

    /**
     * The village well (5.2): a ring of field stones knee high, dark water deep down, two posts and a little roof over
     * a windlass with its rope and bucket. Three looks: shingle roof, thatch roof, a plain crossbeam with a pulley.
     */
    fun well(v: Int, seed: Int): PixelImage {
        val c = Tile1(230)
        c.shadow(-0.5, -0.5, 0.5)
        val r = 0.36
        fun post(i: Double, j: Double) = c.box(i - 0.035, j - 0.035, i + 0.035, j + 0.035, 30.0, 150.0) { f, u, w -> wood(f, w, u, seed + 2, 0x4A3828) }
        // the back post stands behind the ring, the front one before it
        post(-0.5, -0.86)
        c.cylinder(-0.5, -0.5, r, 0.0, 44.0, { a, z, lit -> stoneRing(a, z, lit, seed) }) { d, _ ->
            if (d > 0.8) shade(argb(0x6A645A), 0.9 + rnd(floor(d * 20).toInt(), 0, seed) * 0.2)
            else mix(argb(0x050607), argb(0x10161A), (1 - d) * 0.6)
        }
        post(-0.5, -0.14)
        // the windlass across, rope down to a bucket hanging a little inside the ring
        c.box(-0.53, -0.86, -0.47, -0.14, 118.0, 124.0) { f, u, w -> wood(f, u, w, seed + 3, 0x3E2E22) }
        for (z in 70 until 118) c.img.set(floor(c.sx(-0.5, -0.46)).toInt(), floor(c.sy(-0.5, -0.46, z.toDouble())).toInt(), argb(0x3A3024))
        c.cylinder(-0.5, -0.46, 0.08, 56.0, 72.0, { _, z, lit -> shade(if (abs(z - 60) < 1.5 || abs(z - 69) < 1.5) argb(0x2A2826) else argb(0x5A4430), lit) })
        when (v) {
            0, 1 -> {
                // a little gable roof along j
                val ridge = 190.0; val eave = 150.0
                c.plane(doubleArrayOf(-0.5, -0.98, ridge), doubleArrayOf(0.0, 0.96, 0.0), doubleArrayOf(0.4, 0.0, eave - ridge)) { u, w ->
                    if (v == 0) shingleTex(u * 1.2, w * 0.5, 0.5, seed + 4) else thatchTex(u * 1.2, w * 0.5, 0.5, looks[0], seed + 4)
                }
                c.plane(doubleArrayOf(-0.1, -0.98, eave - 4), doubleArrayOf(0.0, 0.96, 0.0), doubleArrayOf(0.0, 0.0, 4.0)) { _, _ -> argb(0x1A140E) }
                // the gable towards the front: boards under the roof's edge
                c.plane(doubleArrayOf(-0.9, -0.06, eave), doubleArrayOf(0.8, 0.0, 0.0), doubleArrayOf(0.0, 0.0, ridge - eave)) { u, w ->
                    if (abs(u - 0.5) > 0.5 * (1 - w)) null else wood(0, u, w, seed + 6, 0x4A3828)
                }
            }
            else -> c.box(-0.53, -0.92, -0.47, -0.08, 150.0, 158.0) { f, u, w -> wood(f, u, w, seed + 5, 0x4A3828) }
        }
        return c.img
    }

    /**
     * A market stall (5.2): a trestle table of planks under a cloth roof on four poles, wares on it. Three looks with
     * their own cloth and wares: apples and cabbages, loaves and sacks, pots and a string of onions.
     */
    fun stall(v: Int, seed: Int): PixelImage {
        val c = Tile1(220)
        c.shadow(-0.5, -0.45, 0.55, 0.4)
        val i0 = -0.9; val i1 = -0.1; val j0 = -0.72; val j1 = -0.28
        for ((pi, pj) in listOf(i0 to j0, i1 to j0, i0 to j1, i1 to j1))
            c.box(pi - 0.025, pj - 0.025, pi + 0.025, pj + 0.025, 0.0, if (pj == j0) 130.0 else 112.0) { f, u, w -> wood(f, w, u, seed + 1, 0x3E2E22) }
        c.box(i0, j0, i1, j1, 42.0, 48.0) { f, u, w -> wood(f, u, w, seed + 2, 0x5A4430) }
        // the wares: little round heaps on the board
        val wares = when (v) { 0 -> listOf(0x7A2A1E, 0x5A6E2E, 0x8A3A22); 1 -> listOf(0x8A6A3A, 0x9A7A46, 0x6E5E44); else -> listOf(0x6A4A34, 0x4E5A4E, 0x8A7A5E) }
        for (k in 0 until 9) {
            val wi = i0 + 0.1 + (k % 3) * 0.27 + (rnd(k, 1, seed) - 0.5) * 0.06; val wj = j0 + 0.1 + (k / 3) * 0.12
            val rr = if (v == 1) 0.07 else 0.05
            val col = wares[hash(k, 2, seed) % wares.size]
            c.cylinder(wi, wj, rr, 48.0, 48.0 + rr * 90, { _, z, lit -> shade(argb(col), lit * (0.7 + 0.3 * (z - 48) / (rr * 90))) })
        }
        // the cloth: sloping from the back poles down to the front, striped, its hem hanging ragged
        val cloth = when (v) { 0 -> 0x5A3A2A to 0x7A6E58; 1 -> 0x3E4A3A to 0x6E6A52; else -> 0x4A3A4E to 0x7A7060 }
        c.plane(doubleArrayOf(i0 - 0.06, j0 - 0.04, 132.0), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, j1 - j0 + 0.16, -26.0)) { u, w ->
            val stripe = floor(u * 6).toInt() % 2 == 0
            shade(mix(argb(if (stripe) cloth.first else cloth.second), argb(0x140E0A), 0.15 + (rnd(floor(u * 60).toInt(), floor(w * 8).toInt(), seed + 3) - 0.5) * 0.2), 0.85 + 0.2 * w)
        }
        c.plane(doubleArrayOf(i0 - 0.06, j1 + 0.12, 96.0), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, 0.0, 10.0)) { u, w ->
            if (w < 0.4 * rnd(floor(u * 30).toInt(), 1, seed + 4)) null else shade(argb(if (floor(u * 6).toInt() % 2 == 0) cloth.first else cloth.second), 0.65)
        }
        return c.img
    }

    /** A street lamp (5.2): a lantern of iron and horn on a post of oak or iron; three looks. */
    fun lamp(v: Int, seed: Int): PixelImage {
        val c = Tile1(240)
        c.shadow(-0.5, -0.5, 0.2, 0.35)
        val iron = v == 2
        c.box(-0.54, -0.54, -0.46, -0.46, 0.0, 6.0) { f, _, _ -> shade(argb(0x4A463E), if (f == 0) 0.6 else 0.9) }
        c.box(-0.52, -0.52, -0.48, -0.48, 0.0, 170.0) { f, u, w -> if (iron) shade(argb(0x262422), if (f == 0) 0.7 else 1.0) else wood(f, w, u, seed, 0x3E2E22) }
        // an arm out towards the front, the lantern hanging from it on the first look; else sitting on top
        val (li, lj, lz) = if (v == 0) Triple(-0.5, -0.3, 136.0) else Triple(-0.5, -0.5, 170.0)
        if (v == 0) c.box(-0.52, -0.52, -0.48, -0.26, 160.0, 164.0) { f, u, w -> wood(f, u, w, seed + 1, 0x3E2E22) }
        c.box(li - 0.07, lj - 0.07, li + 0.07, lj + 0.07, lz, lz + 22) { f, u, w ->
            val frame = u < 0.15 || u > 0.85 || w < 0.1 || w > 0.9
            if (f == 2) argb(0x1E1C1A) else if (frame) shade(argb(0x2A2826), if (f == 0) 0.7 else 1.0) else mix(argb(0x6A5030), argb(0xC09050), w * 0.5)
        }
        c.plane(doubleArrayOf(li - 0.09, lj + 0.09, lz + 22), doubleArrayOf(0.18, 0.0, 0.0), doubleArrayOf(0.09, -0.09, 10.0)) { u, w -> if (abs(u - 0.5) > 0.5 * (1 - w)) null else argb(0x24221F) }
        return c.img
    }

    /** A bench (5.2): a thick plank on two blocks or trestles, along the map's x; three looks. */
    fun bench(v: Int, seed: Int): PixelImage {
        val c = Tile1(120)
        c.shadow(-0.5, -0.5, 0.42, 0.35)
        val j0 = -0.62; val j1 = -0.4
        for (li in listOf(-0.84, -0.22)) {
            if (v == 1) c.box(li - 0.06, j0 + 0.02, li + 0.06, j1 - 0.02, 0.0, 24.0) { f, _, _ -> shade(argb(0x6A645A), if (f == 0) 0.6 else if (f == 1) 0.9 else 1.0) }
            else c.box(li - 0.03, j0 + 0.03, li + 0.03, j1 - 0.03, 0.0, 24.0) { f, u, w -> wood(f, w, u, seed, 0x3E2E22) }
        }
        c.box(-0.92, j0, -0.08, j1, 24.0, 30.0) { f, u, w -> wood(f, u, w, seed + 1, if (v == 2) 0x4A3A2E else 0x5A4430) }
        if (v == 2) c.box(-0.92, j0 - 0.04, -0.08, j0, 30.0, 62.0) { f, u, w -> wood(f, u, w, seed + 2, 0x4A3A2E) }
        return c.img
    }

    /** The things on the square, three looks each (preview ISODINGE=platz). */
    fun squareSheet(): List<Pair<String, List<PixelImage>>> = listOf(
        "Marktstand" to (0 until 3).map { stall(it, 501 + it) },
        "Brunnen" to (0 until 3).map { well(it, 511 + it) },
        "Laterne" to (0 until 3).map { lamp(it, 521 + it) },
        "Bank" to (0 until 3).map { bench(it, 531 + it) },
        "Wegweiser" to (0 until 3).map { signpost(it, 541 + it) },
    )

    // ------------------------------------------------------------------ the houses of a town map

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.DOOR)
    private val roofTiles = setOf(Tile.ROOF, Tile.ROOF_BLUE)

    /** Where a house stands: its front row of wall tiles at [y] from [x], [n] wide, [d] tiles deep (roof rows and the front row). */
    data class Footprint(val x: Int, val y: Int, val n: Int, val d: Int) {
        val top get() = y - d + 1
    }

    /**
     * The windows of a house as seen outside, from its room (5h.1): the room's windows in its south wall and in its
     * east wall, each put on the tile of the outer wall at the same share of its length; the door stays where the
     * map has it. Null when the house has no room.
     */
    fun windowsFromRoom(room: MapDef, n: Int, d: Int, door: Int): Pair<String, String> {
        val w = room.width; val h = room.height
        val front = CharArray(n) { '#' }
        if (door in 0 until n) front[door] = 'D'
        // the room's inner tiles (between its corner walls) laid over the outer wall's tiles
        for (x in 1 until w - 1) if (room.tile(x, h - 1) == Tile.WINDOW) {
            var k = floor((x - 0.5) / (w - 2) * n).toInt().coerceIn(0, n - 1)
            if (k == door) k = if (x + 0.5 < w / 2.0) (k - 1).coerceAtLeast(0) else (k + 1).coerceAtMost(n - 1)
            front[k] = 'W'
        }
        val side = CharArray(d) { '#' }
        for (y in 1 until h - 1) if (room.tile(w - 1, y) == Tile.WINDOW) side[floor((y - 0.5) / (h - 2) * d).toInt().coerceIn(0, d - 1)] = 'W'
        return String(front) to String(side)
    }

    /** The room a house's door leads into, if any. */
    fun roomOf(map: MapDef, f: Footprint): MapDef? {
        val warp = map.warps.firstOrNull { it.y == f.y && it.x in f.x until f.x + f.n } ?: return null
        return World.maps[warp.to.map]?.takeIf { it.kind == MapKind.INTERIOR }
    }

    /** Every house of a town map with how to draw it (by day or at night). */
    fun houses(map: MapDef): List<Pair<Footprint, (Boolean) -> Picture>> {
        val out = mutableListOf<Pair<Footprint, (Boolean) -> Picture>>()
        for (y in 0 until map.height) {
            var x = 0
            while (x < map.width) {
                if (map.tile(x, y) !in wallTiles || (x > 0 && map.tile(x - 1, y) in wallTiles)) { x++; continue }
                var n = 0; while (map.tile(x + n, y) in wallTiles) n++
                var rows = 0; while (rows < 3 && (0 until n).all { map.tile(x + it, y - rows - 1) in roofTiles }) rows++
                val f = Footprint(x, y, n, rows + 1)
                out += f to { night -> picture(map, f, night) }
                x += n
            }
        }
        return out
    }

    private fun picture(map: MapDef, f: Footprint, night: Boolean): Picture {
        val style = map.houseStyles[f.x to f.top] ?: HouseStyle(if (map.tile(f.x, f.top) == Tile.ROOF_BLUE) RoofKind.SLATE else RoofKind.STRAW, WallKind.TIMBER)
        val letters = (0 until f.n).joinToString("") { when (map.tile(f.x + it, f.y)) { Tile.WINDOW -> "W"; Tile.DOOR -> "D"; else -> "#" } }
        val door = letters.indexOf('D')
        val seed = hash(f.x, f.y, 5) % 997
        val room = roomOf(map, f)
        val (front, side) = room?.let { windowsFromRoom(it, f.n, f.d, door) }
            ?: (letters to (if (f.d >= 3) "#W#" else if (seed % 2 == 0) "W#" else "#W"))
        // the chimney over the hearth inside, at the same share of the length; houses without a room: towards one end
        val chimney: Double? = when {
            style.feature == HouseFeature.BELL_TOWER -> null
            room != null -> (0 until room.width).filter { room.tile(it, 0) == Tile.HEARTH }.takeIf { it.isNotEmpty() }
                ?.let { hs -> (hs.average() + 0.5) / room.width * f.n }
            else -> if (style.mirrored) f.n * 0.25 + 0.1 else f.n * 0.75 - 0.1
        }
        return house(front, side, f.d, style.roof, style.walls, style.feature, seed, chimney, night)
    }

    private val sliceCache = HashMap<String, List<WorldArt.Obj>>()
    private val thingCache = HashMap<String, PixelImage>()

    /**
     * The upright pictures of a town's houses seen diagonally (5.1), or null for anything else: each house cut into
     * strips one tile of the diagonal wide, each sorted by the frontmost point of the house in it, so a figure stands
     * in front of a wall it is in front of and behind one it is behind.
     */
    fun objects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        // the things on the square (5.2): one picture on the tile, its front corner at the foot, sorted like a figure there
        val v = Math.floorMod(hash(tx, ty, 15), 3)
        val thing: Pair<String, () -> PixelImage>? = when (t) {
            Tile.SIGN -> "sign/$v" to { signpost(v, 71) }
            Tile.STALL -> "stall/$v" to { stall(v, 501 + v) }
            Tile.WELL -> "well/$v" to { well(v, 511 + v) }
            Tile.LAMP -> "lamp/$v" to { lamp(v, 521 + v) }
            Tile.BENCH -> "bench/$v" to { bench(v, 531 + v) }
            Tile.BARREL -> "barrel/$v" to { MapRoomIso.barrelOutside(v, 551 + v) }
            else -> null
        }
        if (thing != null) {
            val T = WorldArt.T
            val img = synchronized(sliceCache) { thingCache.getOrPut(thing.first) { thing.second() } }
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, t == Tile.BENCH, corner = true))
        }
        if (t in roofTiles) return emptyList()
        if (t !in wallTiles) return null
        if (tx > 0 && map.tile(tx - 1, ty) in wallTiles) return emptyList()
        val key = "${map.id}/$tx/$ty"
        synchronized(sliceCache) { sliceCache[key] }?.let { return it }
        var n = 0; while (map.tile(tx + n, ty) in wallTiles) n++
        var rows = 0; while (rows < 3 && (0 until n).all { map.tile(tx + it, ty - rows - 1) in roofTiles }) rows++
        val f = Footprint(tx, ty, n, rows + 1)
        val out = slices(picture(map, f, false), f)
        synchronized(sliceCache) { sliceCache[key] = out }
        return out
    }

    private fun slices(pic: Picture, f: Footprint): List<WorldArt.Obj> {
        val T = WorldArt.T
        val img = pic.img
        val n = f.n; val d = f.d
        // every strip's foot lies on the same diagonal row in front of the whole house, so all strips share their bottom
        val s = n + d + 1
        val bottom = pic.oy + s * TH / 2
        val hh = (Math.ceil(bottom).toInt() + 1) / 2 * 2
        val out = mutableListOf<WorldArt.Obj>()
        val kMin = floor((0.5 - pic.ox) / (TW / 2)).toInt(); val kMax = floor((img.width - 0.5 - pic.ox) / (TW / 2)).toInt()
        for (k in kMin..kMax) {
            val c = k + 0.5
            val mid = (pic.ox + c * TW / 2).toInt()     // a whole pixel: ox lies on a half
            val strip = PixelImage(92, hh)
            var any = false
            for (y in 0 until img.height) for (x in max(0, mid - 46) until min(img.width, mid + 46)) {
                if (floor((x + 0.5 - pic.ox) / (TW / 2)).toInt() != k) continue
                val col = img[x, y]
                if (col ushr 24 == 0) continue
                strip.set(x - (mid - 46), y + (hh - Math.round(bottom).toInt()), col); any = true
            }
            if (!any) continue
            // drop the empty rows on top, so the strip's box (see-through test) holds only what is drawn
            var top = 0
            while (top < hh - 2 && (0 until 92).none { strip.opaque(it, top) }) top++
            top -= top % 2
            val img2 = if (top == 0) strip else PixelImage(92, hh - top).also { o -> for (y in 0 until hh - top) for (x in 0 until 92) o.set(x, y, strip[x, y + top]) }
            // the foot: on this strip's middle line, on the row in front of the house; sorted by the frontmost point of the footprint on it
            val qi = (s + c) / 2; val qj = (s - c) / 2
            val cc = c.coerceIn(-d.toDouble(), n.toDouble())
            val pi = min(n.toDouble(), d + cc); val pj = pi - cc
            val wx = Math.round((f.x + qi) * T).toInt(); val wy = Math.round((f.top + qj) * T).toInt()
            val depth = ((f.x + f.top + pi + pj) * T).toInt() + T / 2 - 1
            out += WorldArt.Obj(img2, wx - 23, wy - img2.height / 2, depth - wx, 2, false, corner = true, group = 1 + f.x * 1000 + f.y)
        }
        return out
    }

    /** The sample sheet (ISODINGE=dorf): the village's houses by day and at night. */
    fun sheet(): List<Pair<String, List<PixelImage>>> {
        val map = de.bornim.core.World["village"]
        val all = houses(map).map { it.second }
        return all.chunked(3).flatMapIndexed { k, row ->
            listOf("Häuser ${k + 1}" to row.map { it(false).img }, "nachts ${k + 1}" to row.map { it(true).img })
        }
    }
}
