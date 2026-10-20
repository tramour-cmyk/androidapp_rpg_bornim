package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The cave seen diagonally (13e): the rock stands up around the floor instead of
 * lying flat in it, the gate and the old timber supports stand across their passage in the slant.
 * The rock comes from the cave's plan alone (48b), so a cave made by chance needs no work by hand: each rock tile next
 * to the floor is a height field whose foot is the ground's edge of rock; back walls (the floor before them, towards +i
 * or +j) rise to a rough face, front walls (the floor behind them) stay a low rim, so they never hide the hero. Everything else still comes from [MapCave].
 * Same projection and heights as the rooms and the village ([MapRoomIso], [MapTownIso]): 90 × 45 art pixels a tile.
 */
object MapCaveIso {
    private const val TW = MapRoomIso.TW
    private const val TH = MapRoomIso.TH
    private const val ZS = MapRoomIso.ZS

    /** A back wall's height in upright units (57 to the metre): about 2.4 m, the ceiling lost in the dark above. */
    private const val TALL = 138.0
    /** A front wall's rim. */
    private const val RIM = 22.0
    /** A thin wall between two rooms: the back of the one, the front of the other; about a metre, so it neither hides nor vanishes. */
    private const val MID = 58.0

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

    /** One tile's picture: its front corner (i = j = 0) at the bottom middle, the tile from −1 to 0 in i and j. */
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
        /** A box: its faces towards +j (0, down left, in shade), +i (1, down right) and its top (2). */
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

    // ------------------------------------------------------------------ rock

    private val rockLight = argb(0x8A8072)
    private val rockDark = argb(0x1C1916)

    /**
     * Damp rock: [face] 0 shade, 1 the side towards the light, 2 the top; ([u], [v]) on the face, [z] its height in
     * units. Grainy, with cracks running down and wet streaks; darker towards the top, where the ceiling begins.
     */
    private fun rock(face: Int, u: Double, z: Double, seed: Int, top: Double): Int {
        if (face == 2) return shade(mix(rockDark, rockLight, 0.12 + vnoise(u * 9, z * 0.05, seed) * 0.1), 0.6)
        val k = if (face == 0) 0.55 else 0.85
        // the face bulges: a height field of big lumps and smaller knobs, lit from above and from the side
        val x = u * 2.2; val y = z / 26
        fun hf(px: Double, py: Double) = vnoise(px, py, seed) * 0.6 + vnoise(px * 2.7, py * 2.7, seed + 7) * 0.3 + vnoise(px * 7, py * 7, seed + 8) * 0.1
        val hh = hf(x, y)
        val dx = (hf(x + 0.04, y) - hh) / 0.04; val dy = (hf(x, y + 0.04) - hh) / 0.04
        var t = 0.55 + dy * 0.22 + dx * (if (face == 0) -0.1 else 0.1) + (hh - 0.5) * 0.25
        t += (rnd(floor(u * 90).toInt(), floor(z * 1.8).toInt(), seed + 1) - 0.5) * 0.06
        // cracks: where two lumps meet, a dark seam
        if (abs(vnoise(x * 1.6, y * 1.6, seed + 2) - 0.5) < 0.018) t -= 0.22
        // wet streaks where water runs down
        if (vnoise(u * 11, z / 160, seed + 3) > 0.74) t -= 0.07
        // the foot darker, the head lost in the dark
        t -= max(0.0, 1 - z / 12) * 0.15
        t -= max(0.0, (z - top * 0.6) / (top * 0.4)) * 0.22
        return shade(mix(rockDark, rockLight, t.coerceIn(0.0, 1.0)), k)
    }

    private val tallCache = HashMap<String, PixelImage>()

    /** Art pixels of the ground a tile ([MapCave.rockAt] works in them). */
    private const val GS = MapGround.S.toDouble()
    /** One tile's length in upright units, for the slope of the rock (a tile about 1.4 m). */
    private const val TILE_Z = 80.0

    private fun rockCell(map: MapDef, x: Int, y: Int) = isRock(MapCave.caveTile(map, x, y))

    /**
     * How high the rock may stand in cell ([x], [y]), from the cave's plan alone (48b: no tile drawn by hand, so a cave
     * made by chance works the same): rock behind the floor (the floor towards the camera, +x or +y) stands tall, rock
     * between the floor and the camera stays a low rim so it never hides the hero, a thin wall with floor on both sides
     * stands a metre. Rock further off follows the nearest floor.
     */
    private fun capCell(map: MapDef, x: Int, y: Int): Double {
        fun floorAt(dx: Int, dy: Int) = !rockCell(map, x + dx, y + dy)
        val back = floorAt(1, 0) || floorAt(0, 1) || floorAt(1, 1)
        val front = floorAt(-1, 0) || floorAt(0, -1) || floorAt(-1, -1)
        // a wall two tiles thick between two rooms counts as thin: floor two tiles off on the other side
        val back2 = back || floorAt(2, 0) || floorAt(0, 2) || floorAt(2, 2) || floorAt(2, 1) || floorAt(1, 2)
        val front2 = front || floorAt(-2, 0) || floorAt(0, -2) || floorAt(-2, -2) || floorAt(-2, -1) || floorAt(-1, -2)
        return when {
            back && front2 || front && back2 -> MID
            back -> TALL
            front -> RIM
            (0..2).any { a -> (0..2).any { b -> (a + b > 0) && floorAt(a, b) } } -> TALL
            (-2..0).any { a -> (-2..0).any { b -> (a + b < 0) && floorAt(a, b) } } -> RIM
            else -> TALL
        }
    }

    /**
     * Whether the rock of cell ([x], [y]) is drawn no higher than about a metre (a thin wall between two rooms, or the
     * low rim towards the camera), so the hero looks over it (13e, test of 0.1.689: the room beyond a low wall stayed dark).
     */
    fun low(map: MapDef, x: Int, y: Int): Boolean = map.inside(x, y) && rockCell(map, x, y) && capCell(map, x, y) <= MID

    /** The cap between the cells' middles, blended over the rock cells only (the floor has none). */
    private fun capAt(map: MapDef, gi: Double, gj: Double, caps: HashMap<Long, Double>): Double {
        val fx = gi - 0.5; val fy = gj - 0.5
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var w = fy - iy
        u = u * u * (3 - 2 * u); w = w * w * (3 - 2 * w)
        var sum = 0.0; var tot = 0.0
        for ((dx, dy, k) in listOf(Triple(0, 0, (1 - u) * (1 - w)), Triple(1, 0, u * (1 - w)), Triple(0, 1, (1 - u) * w), Triple(1, 1, u * w))) {
            val x = ix + dx; val y = iy + dy
            if (!rockCell(map, x, y) || k <= 0) continue
            sum += caps.getOrPut(x.toLong() * 100_000 + y) { capCell(map, x, y) } * k; tot += k
        }
        return if (tot > 0) sum / tot else RIM
    }

    /** Whether the floor touches cell ([x], [y]) (it then has a wall), blended between the cells' middles. */
    private fun edgeAt(map: MapDef, gi: Double, gj: Double): Double {
        val fx = gi - 0.5; val fy = gj - 0.5
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var w = fy - iy
        u = u * u * (3 - 2 * u); w = w * w * (3 - 2 * w)
        fun e(x: Int, y: Int) = if (!rockCell(map, x, y) || (-1..1).any { a -> (-1..1).any { b -> !rockCell(map, x + a, y + b) } }) 1.0 else 0.0
        return (e(ix, iy) * (1 - u) + e(ix + 1, iy) * u) * (1 - w) + (e(ix, iy + 1) * (1 - u) + e(ix + 1, iy + 1) * u) * w
    }

    /**
     * The rock of tile ([tx], [ty]) as a height field: zero where the floor reaches into the tile, from its foot
     * ([MapCave.rockAt], the same edge the ground draws) rising steeply in rounded bulges to the cap of the place.
     */
    private fun heights(map: MapDef, tx: Int, ty: Int, n: Int): Array<DoubleArray> {
        val caps = HashMap<Long, Double>()
        val seed = 3500
        return Array(n + 3) { a ->
            DoubleArray(n + 3) { b ->
                val gi = tx + (a - 1).toDouble() / n; val gj = ty + (b - 1).toDouble() / n
                val f = MapCave.rockAt(map, gi * GS, gj * GS) - 0.5
                if (f <= 0) 0.0 else {
                    val cap = capAt(map, gi, gj, caps)
                    // steep from the foot, the rim a little rounded; knobs on the top so no edge runs straight
                    val ramp = Math.pow((f / 0.16).coerceAtMost(1.0), 0.45)
                    val knob = vnoise(gi * 1.7, gj * 1.7, seed) * 0.75 + vnoise(gi * 4.5, gj * 4.5, seed + 1) * 0.25
                    // towards the rock no floor touches (drawn flat by the ground) the mass sinks to the ground, so no
                    // tile ends in a cut face
                    val sink = ((edgeAt(map, gi, gj) - 0.5) * 2.2).coerceIn(0.0, 1.0)
                    max(0.0, cap * ramp * (0.8 + 0.28 * knob) * Math.sqrt(sink))
                }
            }
        }
    }

    /**
     * One rock tile seen diagonally: its height field drawn column by column from the front backwards, each column of
     * screen pixels filled only above what stands before it. Lit from the front right, the faces darker towards the
     * ceiling, cracks and wet streaks running down.
     */
    private fun rockTile(map: MapDef, tx: Int, ty: Int): PixelImage {
        val n = 40
        val hs = heights(map, tx, ty, n)
        fun hAt(i: Double, j: Double): Double {
            // i, j in −1..0 over the tile; the grid has one point of margin on each side
            val x = (i + 1) * n + 1; val y = (j + 1) * n + 1
            val ix = floor(x).toInt().coerceIn(0, n + 1); val iy = floor(y).toInt().coerceIn(0, n + 1)
            val u = (x - ix).coerceIn(0.0, 1.0); val v = (y - iy).coerceIn(0.0, 1.0)
            return (hs[ix][iy] * (1 - u) + hs[ix + 1][iy] * u) * (1 - v) + (hs[ix][iy + 1] * (1 - u) + hs[ix + 1][iy + 1] * u) * v
        }
        return relief(tx, ty, TALL * 1.15, 2.5 / n, 3600, rockDark, rockLight, TALL, ::hAt)
    }

    /**
     * A height field over one tile ([hAt] in upright units, i and j in −1..0) drawn column by column from the front
     * backwards, each column of screen pixels filled only above what stands before it. Lit from the front right, lumps
     * and knobs on the faces, cracks and wet streaks running down; the foot darker, and from [fade] up lost in the dark.
     */
    private fun relief(
        tx: Int, ty: Int, maxZ: Double, e: Double, seed: Int, dark: Int, light: Int, fade: Double,
        hAt: (Double, Double) -> Double,
    ): PixelImage {
        val c = Tile1(TH.toInt() + (maxZ * ZS).toInt() + 20)
        val img = c.img
        val w = c.w; val h = c.h
        val lx = 0.64; val ly = 0.46; val lz = 0.5
        for (px in 0 until w) {
            val cc = 2 * (px + 0.5 - w / 2.0) / TW
            if (abs(cc) >= 1) continue
            var ymin = h.toDouble()
            var s = -abs(cc)
            val sEnd = -2 + abs(cc)
            while (s >= sEnd) {
                val i = (s + cc) / 2; val j = (s - cc) / 2
                val gy = h + s * TH / 2
                val hh = hAt(i, j)
                if (hh < 0.4) { ymin = min(ymin, kotlin.math.ceil(gy)); s -= 0.5 / TH; continue }
                val top = gy - hh * ZS
                if (top < ymin) {
                    val dhi = (hAt(i + e, j) - hAt(i - e, j)) / (2 * e) / TILE_Z
                    val dhj = (hAt(i, j + e) - hAt(i, j - e)) / (2 * e) / TILE_Z
                    val nl = Math.sqrt(dhi * dhi + dhj * dhj + 1)
                    val lam = max(0.0, (-dhi * lx - dhj * ly + lz) / nl)
                    val gi = tx + 1 + i; val gj = ty + 1 + j
                    // lumps and knobs on the face (a bump only in the light, the shape stays): big ones a third of a
                    // tile, small ones a hand wide, stretched a little downwards as water shaped them
                    fun bump(u: Double, v: Double, z: Double) =
                        vnoise(u * 2.6 + z / 40, v * 2.6 + z / 40, seed + 6) * 0.62 + vnoise(u * 7 + z / 16, v * 7 + z / 16, seed + 7) * 0.28 +
                            vnoise(u * 20 + z / 6, v * 20 + z / 6, seed + 8) * 0.1
                    for (py in max(0, kotlin.math.ceil(top).toInt()) until min(h, ymin.toInt())) {
                        val z = (gy - py) / ZS
                        val b0 = bump(gi, gj, z)
                        val bx = bump(gi + 0.02, gj - 0.02, z) - b0
                        val bz = bump(gi, gj, z + 2.5) - b0
                        var l = lam + bx * 3.0 + bz * 2.2
                        // hollows between the lumps hold the dark
                        l -= max(0.0, 0.4 - b0) * 0.45
                        var t = 0.08 + max(0.0, l) * 0.66
                        t += (rnd(floor(gi * 70).toInt() + floor(gj * 70).toInt() * 7919, floor(z * 1.3).toInt(), seed + 1) - 0.5) * 0.08
                        // cracks running down, wet streaks
                        if (abs(vnoise(gi * 2.4 + gj * 2.4 + z / 300, z / 90, seed + 2) - 0.5) < 0.016) t -= 0.25
                        if (vnoise((gi - gj) * 9, z / 200, seed + 3) > 0.74) t -= 0.07
                        // the foot in the dust darker, the head lost in the dark of the ceiling
                        t -= max(0.0, 1 - z / 14) * 0.2
                        t -= max(0.0, (z - fade * 0.45) / (fade * 0.4)) * 0.75
                        img.set(px, py, shade(mix(dark, light, t.coerceIn(0.0, 1.0)), 1.0))
                    }
                    ymin = kotlin.math.ceil(top)
                }
                s -= 0.5 / TH
            }
        }
        return img
    }

    // ------------------------------------------------------------------ dripstone and rubble (13e.4)

    private val dripLight = argb(0xA89A84)
    private val dripDark = argb(0x1E1A16)

    /** The cones of [stalagmites] on ([tx], [ty]): middle (i, j), radius at the foot, height. */
    private fun stalagmiteCones(tx: Int, ty: Int): List<DoubleArray> {
        val k = 2 + hash(tx, ty, 4401) % 3
        return List(k) { q ->
            val ci = -0.5 + (rnd(tx, ty * 7 + q, 4402) - 0.5) * 0.5; val cj = -0.5 + (rnd(tx * 5 + q, ty, 4403) - 0.5) * 0.5
            val big = q == 0
            doubleArrayOf(ci, cj, (if (big) 0.28 else 0.16) + rnd(q, tx + ty, 4404) * 0.08, (if (big) 80.0 else 30.0) + rnd(tx, q, 4405) * (if (big) 30 else 40))
        }
    }

    /**
     * 216.3: the part of the tile (x0, y0, x1, y1 within it) the stalagmites on ([tx], [ty]) stand on: their cones with
     * the knobs (radius up to 1.18 times), and the middle of the mound, where it is more than ankle high.
     */
    fun stalagmiteSpot(tx: Int, ty: Int): DoubleArray {
        val cs = stalagmiteCones(tx, ty)
        val m = 0.24
        return doubleArrayOf(minOf(cs.minOf { 1 + it[0] - it[2] * 1.18 }, 0.5 - m), minOf(cs.minOf { 1 + it[1] - it[2] * 1.18 }, 0.5 - m),
            maxOf(cs.maxOf { 1 + it[0] + it[2] * 1.18 }, 0.5 + m), maxOf(cs.maxOf { 1 + it[1] + it[2] * 1.18 }, 0.5 + m)).also {
            for (q in 0..1) it[q] = it[q].coerceAtLeast(0.0)
            for (q in 2..3) it[q] = it[q].coerceAtMost(1.0)
        }
    }

    /** 216.3: the part of the tile the crates on ([tx], [ty]) fill as [crates] draws them: two stacked, one smashed with a sack, or a barrel. */
    fun crateSpot(tx: Int, ty: Int): DoubleArray = when ((hash(tx, ty, 41) / 7) % 3) {
        0 -> doubleArrayOf(0.14, 0.14, 0.86, 0.86)
        1 -> doubleArrayOf(0.16, 0.16, 0.84, 0.84)
        else -> doubleArrayOf(0.18, 0.18, 0.82, 0.82)
    }

    /**
     * Stalagmites on one tile, as a height field like the walls: two to four cones grown from a common mound, the
     * tallest about 1.5 m, each a little bent and knobbed where the drops ran down; wet and paler than the rock.
     */
    private fun stalagmites(tx: Int, ty: Int): PixelImage {
        val cones = stalagmiteCones(tx, ty)
        fun hAt(i: Double, j: Double): Double {
            var best = 0.0
            for (c in cones) {
                val d = Math.hypot(i - c[0], j - c[1])
                // the knobs: the radius swells and narrows as rings down the cone
                val r = c[2] * (1 + (vnoise(i * 9 + tx, j * 9 + ty, 4406) - 0.5) * 0.35)
                if (d >= r) continue
                best = max(best, c[3] * (1 - d / r).pow(1.15))
            }
            // the mound they grew from
            val m = Math.hypot(i + 0.5, j + 0.5)
            if (m < 0.42) best = max(best, 12 * (1 - m / 0.42).pow(0.8))
            return best
        }
        return relief(tx, ty, 140.0, 0.02, 4410 + hash(tx, ty, 4407) % 50, dripDark, dripLight, 600.0, ::hAt)
    }

    /** Fallen stones on one tile, walked over: eight to twelve rounded lumps, the biggest knee high. */
    private fun rubbleTile(tx: Int, ty: Int): PixelImage {
        val k = 8 + hash(tx, ty, 4501) % 5
        val lumps = List(k) { q ->
            doubleArrayOf(-0.88 + rnd(tx, ty * 3 + q, 4502) * 0.76, -0.88 + rnd(tx * 3 + q, ty, 4503) * 0.76,
                0.06 + rnd(q, tx, 4504) * (if (q < 3) 0.14 else 0.07), 0.0)
        }.onEach { it[3] = it[2] * (45 + rnd(it[0].hashCode(), 1, 4505) * 35) }
        fun hAt(i: Double, j: Double): Double {
            var best = 0.0
            for (c in lumps) {
                val d = Math.hypot(i - c[0], (j - c[1]) * 1.15)
                if (d >= c[2]) continue
                best = max(best, c[3] * sqrt(1 - (d / c[2]) * (d / c[2])) * (0.85 + vnoise(i * 14, j * 14, 4506) * 0.3))
            }
            return best
        }
        return relief(tx, ty, 30.0, 0.012, 4520, rockDark, rockLight, 600.0, ::hAt)
    }

    /** A boulder fallen from the roof (13e, in place of the old flat one): one big rounded block, hip high, with one or two smaller ones leaning on it. */
    private fun boulderTile(tx: Int, ty: Int): PixelImage {
        val k = 1 + hash(tx, ty, 4531) % 3
        val lumps = List(k) { q ->
            val big = q == 0
            val ci = -0.5 + (if (big) 0.0 else (rnd(tx, ty * 3 + q, 4532) - 0.5) * 0.6)
            val cj = -0.5 + (if (big) 0.0 else 0.18 + rnd(tx * 3 + q, ty, 4533) * 0.15)
            val r = if (big) 0.36 + rnd(tx, ty, 4534) * 0.06 else 0.14 + rnd(q, tx, 4535) * 0.06
            doubleArrayOf(ci, cj, r, r * (if (big) 95.0 else 110.0))
        }
        fun hAt(i: Double, j: Double): Double {
            var best = 0.0
            for (c in lumps) {
                // a block, not an egg: flatter on top, broken faces
                val d = Math.hypot(i - c[0], (j - c[1]) * 1.1) * (0.9 + vnoise(i * 6 + tx, j * 6 + ty, 4536) * 0.25)
                if (d >= c[2]) continue
                val q = d / c[2]
                best = max(best, c[3] * (1 - q.pow(3.0)).pow(0.6))
            }
            return best
        }
        return relief(tx, ty, 70.0, 0.012, 4540 + hash(tx, ty, 4537) % 30, rockDark, rockLight, 600.0, ::hAt)
    }

    // ------------------------------------------------------------------ timber and iron

    private fun wood(face: Int, u: Double, v: Double, seed: Int, rgb: Int = 0x4A3826): Int {
        val k = when (face) { 0 -> 0.55; 1 -> 0.9; else -> 1.0 }
        var t = 0.5 + (rnd(floor(v * 6).toInt(), floor(u * 18).toInt(), seed) - 0.5) * 0.25 + (rnd(floor(u * 60).toInt(), floor(v * 40).toInt(), seed + 1) - 0.5) * 0.14
        if (frac(v * 6) < 0.1) t -= 0.25
        return shade(mix(argb(0x120C08), argb(rgb), t.coerceIn(0.0, 1.0)), k)
    }

    private fun iron(face: Int, u: Double, v: Double, seed: Int, rusty: Double = 0.62): Int {
        val k = when (face) { 0 -> 0.5; 1 -> 0.85; else -> 0.95 }
        val rust = vnoise(u * 8, v * 14, seed) > rusty
        val t = 0.45 + (rnd(floor(u * 40).toInt(), floor(v * 50).toInt(), seed + 1) - 0.5) * 0.2
        return shade(mix(argb(0x14120F), if (rust) argb(0x6A3A1E) else argb(0x4A4844), t), k)
    }

    /**
     * One tile of a timber support across a passage two tiles wide ([left]: the tile at the passage's left end): a post
     * at its outer end, half the beam over the way. [v] one of three: straight, sagging with wedges, a cramp and a charm.
     */
    private fun support(left: Boolean, v: Int): PixelImage {
        val c = Tile1(TH.toInt() + (150 * ZS).toInt() + 20)
        val seed = 3300 + v * 13
        val j = -0.5
        val top = 122.0
        val pi = if (left) -0.94 else -0.06
        c.shadow(pi, j + 0.1, 0.18, 0.4)
        c.box(pi - 0.06, j - 0.06, pi + 0.06, j + 0.06, 0.0, top) { f, u, w -> wood(f, w, u, seed) }
        val sag = if (v == 1) 6.0 else 0.0
        // the beam: its inner end lower where it sags, drawn in four short lengths
        for (s in 0 until 4) {
            val i0 = -1.0 + s * 0.25; val i1 = i0 + 0.25
            val mid = if (left) (i0 + 1.0) else -i1
            val z0 = top - sag * mid
            c.box(i0, j - 0.08, i1, j + 0.08, z0, z0 + 16) { f, u, w -> wood(f, u, w, seed + 5) }
        }
        if (v == 2 && left) c.box(pi - 0.07, j - 0.09, pi + 0.07, j + 0.09, top - 4, top + 6) { f, u, w -> iron(f, u, w, seed + 7) }
        if (v == 1) {
            // wedges driven in over the beam
            val wi = if (left) -0.7 else -0.3
            c.box(wi - 0.05, j - 0.06, wi + 0.05, j + 0.06, top + 16 - sag * 0.4, top + 24) { f, u, w -> wood(f, u, w, seed + 9, 0x5A4630) }
        }
        return c.img
    }

    /**
     * One tile of the iron gate across the passage before Grak's hall: bars, cross bands, the post at its end. [v] one of
     * three, the same all across the gate (D1.11): straight bars with two bands; old and rusted, three bands, a bar bent
     * and spikes broken off; patched by the goblins, a bar replaced by a sharpened stake and the top band a rope lashing.
     * The two halves differ in which bar is bent or patched, so the gate is not one picture twice.
     */
    private fun gate(left: Boolean, v: Int = 0): PixelImage {
        val c = Tile1(TH.toInt() + (140 * ZS).toInt() + 20)
        val seed = 3400 + v * 17 + (if (left) 0 else 5)
        val j = -0.5
        val n = 5
        val odd = if (left) 1 else 3
        for (k in 0 until n) {
            val i = -1.0 + (k + 0.5) / n
            val rust = if (v == 1) 0.48 else 0.62
            when {
                v == 2 && k == odd -> {
                    // a stake of rough wood in place of a lost bar, cut to a point and taller than the iron
                    c.box(i - 0.05, j - 0.05, i + 0.05, j + 0.05, 0.0, 120.0) { f, u, w -> wood(f, u, w, seed + k, 0x7A5C3A) }
                    c.box(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 120.0, 134.0) { f, u, w -> wood(f, u, w, seed + k, 0x7A5C3A) }
                }
                v == 1 && k == odd -> {
                    // bent: the lower half stands, the upper leans aside, joined by a short crooked piece
                    c.box(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 0.0, 58.0) { f, u, w -> iron(f, u, w, seed + k, rust) }
                    for (q in 0 until 4) c.box(i - 0.025 + q * 0.03, j - 0.025, i + 0.025 + q * 0.03, j + 0.025, 58.0 + q * 3, 62.0 + q * 3) { f, u, w -> iron(f, u, w, seed + k, rust) }
                    c.box(i + 0.075, j - 0.025, i + 0.125, j + 0.025, 70.0, 108.0) { f, u, w -> iron(f, u, w, seed + k, rust) }
                }
                else -> {
                    val h = if (v == 2) 110.0 + (k * 7 + (if (left) 3 else 0)) % 4 * 3 else 116.0
                    c.box(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 0.0, h) { f, u, w -> iron(f, u, w, seed + k, rust) }
                    // the spike on top; on the old gate some are broken off
                    if (v != 1 || (k + odd) % 3 != 0) c.box(i - 0.015, j - 0.015, i + 0.015, j + 0.015, h, h + 10) { f, u, w -> iron(f, u, w, seed + k, rust) }
                }
            }
        }
        val bands = when (v) { 1 -> doubleArrayOf(18.0, 56.0, 94.0); else -> doubleArrayOf(24.0, 92.0) }
        for (z in bands) {
            if (v == 2 && z > 50) {
                // the top band lost, the bars lashed with rope instead: a thick cord sagging a little between them
                c.box(-1.0, j - 0.035, -0.5, j + 0.035, z + 1, z + 6) { f, u, w -> wood(f, u, w, seed + 13, 0x6A5A3C) }
                c.box(-0.5, j - 0.035, 0.0, j + 0.035, z - 1, z + 4) { f, u, w -> wood(f, u, w, seed + 14, 0x6A5A3C) }
            } else c.box(-1.0, j - 0.03, 0.0, j + 0.03, z, z + 6) { f, u, w -> iron(f, u, w, seed + 11, if (v == 1) 0.48 else 0.62) }
        }
        // the stone post the gate is set in, at the passage's end
        val pi = if (left) -0.95 else -0.05
        c.box(pi - 0.07, j - 0.1, pi + 0.07, j + 0.1, 0.0, 132.0) { f, u, w -> rock(f, u, w * 132, seed + 20, 260.0) }
        return c.img
    }

    // ------------------------------------------------------------------ goblin loot: chests, crates, sleeping places (13e.2)

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, sat: Double = 1.0, value: Double = 1.0, bias: Double = 0.0) =
        Mat(Ramp.of(argb(rgb), sat = sat, value = value), shine, grain, bias)

    // the same rough, smoke-dark stuff as the cave's things seen straight ([MapCave])
    private val plank = m(0x5E4C3A, grain = 0.12, sat = 0.75, value = 0.82)
    private val plankTop = m(0x6A5640, grain = 0.1, sat = 0.75, value = 0.82, bias = -0.25)
    private val plankDark = m(0x40322A, grain = 0.12, sat = 0.75, value = 0.85)
    private val ironMat = m(0x3E3A36, shine = 0.35, grain = 0.25, sat = 0.5)
    private val rope = m(0x6A5A3C, grain = 0.4, sat = 0.6, value = 0.7)
    private val sackMat = m(0x6E5E44, grain = 0.2, sat = 0.7, value = 0.6, bias = -0.25)
    private val hideMat = m(0x5A5046, grain = 0.2, sat = 0.7, value = 0.7, bias = -0.25)
    private val hideDarkMat = m(0x3A322C, grain = 0.3, sat = 0.7)
    private val strawMat = m(0x9A8452, grain = 0.35, sat = 0.75, value = 0.75)
    private val boneMat = m(0xA89A7C, shine = 0.08, grain = 0.22, sat = 0.75)
    private val hole = argb(0x120E0C)
    private val seamC = argb(0x2A1E14)

    /** A picture of one tile for [Sculpt]: front corner at the bottom middle, the tile from −1 to 0 in i and j. */
    private class Canvas(val h: Int, seed: Int, val w: Int = 100) {
        val s = Sculpt(w, h, seed)
        val img: PixelImage get() = s.img
        /** The shadow on the floor: kept apart, so the outline does not run round it, and laid under at [done]. */
        private val under = PixelImage(w, h)
        fun x(i: Double, j: Double) = w / 2.0 + (i - j) * TW / 2
        fun y(i: Double, j: Double, z: Double = 0.0) = h + (i + j) * TH / 2 - z * ZS
        fun done(): PixelImage {
            s.outline(argb(0x0E0C0A))
            for (py in 0 until h) for (px in 0 until w) {
                val u = under[px, py]; if (u ushr 24 == 0) continue
                val c = img[px, py]; val a = c ushr 24
                if (a == 0) img.set(px, py, u) else if (a < 255) img.set(px, py, mix(u or (0xFF shl 24), c or (0xFF shl 24), a / 255.0))
            }
            return img
        }
        fun box(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, top: Mat, left: Mat = top, right: Mat = left, bevel: Double = 1.0) {
            s.poly(left, x(i0, j1), y(i0, j1, z0), x(i1, j1), y(i1, j1, z0), x(i1, j1), y(i1, j1, z1), x(i0, j1), y(i0, j1, z1), tiltX = -0.55, tiltY = 0.3, bevel = bevel)
            s.poly(right, x(i1, j0), y(i1, j0, z0), x(i1, j1), y(i1, j1, z0), x(i1, j1), y(i1, j1, z1), x(i1, j0), y(i1, j0, z1), tiltX = 0.55, tiltY = 0.3, bevel = bevel)
            s.poly(top, x(i0, j0), y(i0, j0, z1), x(i1, j0), y(i1, j0, z1), x(i1, j1), y(i1, j1, z1), x(i0, j1), y(i0, j1, z1), tiltY = -0.72, bevel = bevel * 0.6)
        }
        /** A soft shadow round the footprint, laid first: an ellipse on the floor (2:1 on the screen, D1.5), not a lozenge. */
        fun shadow(i0: Double, j0: Double, i1: Double, j1: Double, a: Double = 0.5, pad: Double = 0.06, edge: Double = 1.0) {
            val ci = (i0 + i1) / 2; val cj = (j0 + j1) / 2
            val ri = (i1 - i0) / 2 * 1.2 + pad; val rj = (j1 - j0) / 2 * 1.2 + pad
            // a wide shadow may reach over the front edges of the tile, where the floor is still seen
            val reach = if (pad > 0.06) 0.25 else 0.0
            for (py in 0 until h) for (px in 0 until w) {
                val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
                val i = (aa + bb) / 2; val j = (bb - aa) / 2
                val d = Math.hypot((i - ci) / ri, (j - cj) / rj)
                if (d >= 1.0 || i < -1 || j < -1 || i > reach || j > reach) continue
                under.set(px, py, ((minOf(1.0, (1 - d) * edge) * a * 255).toInt().coerceIn(0, 255) shl 24) or 0x0A0806)
            }
        }
        /** Fills the level rectangle between (i0, j0) and (i1, j1) at height [z] with [c]: the dark inside of a box. */
        fun fill(i0: Double, j0: Double, i1: Double, j1: Double, z: Double, c: Int) {
            for (py in 0 until h) for (px in 0 until w) {
                val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h + z * ZS) / (TH / 2)
                val i = (aa + bb) / 2; val j = (bb - aa) / 2
                if (i in i0..i1 && j in j0..j1) img.set(px, py, c)
            }
        }
        /** A line on the face j = [j] (towards +j) or i = [i] at height z, between two points of the floor plan. */
        fun seam(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double = z0, c: Int = argb(0x2A1E14)) =
            s.line(x(i0, j0), y(i0, j0, z0), x(i1, j1), y(i1, j1, z1), c)
    }

    /** Planks on a box: seams across both faces, a batten down the corner, now and then a nail head. */
    private fun Canvas.planks(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, rows: Int, seed: Int) {
        for (k in 1 until rows) {
            val z = z0 + (z1 - z0) * k / rows + (rnd(k, 1, seed) - 0.5) * 2
            seam(i0, j1, i1, j1, z, z + (rnd(k, 2, seed) - 0.5) * 2)
            seam(i1, j0, i1, j1, z)
        }
        seam(i1, j1, i1, j1, z0, z1, argb(0x1A120C))
        for (k in 0 until rows) {
            val z = z0 + (z1 - z0) * (k + 0.5) / rows
            s.dot(x(i0 + 0.04, j1), y(i0 + 0.04, j1, z), argb(0x8A8070))
            s.dot(x(i1, j1 - 0.04), y(i1, j1 - 0.04, z), argb(0x8A8070))
        }
    }

    /**
     * A chest, as the goblins keep their loot (13e.2), along the map's x: [v] 0 an iron-banded chest taken from the
     * village, its lock broken and tied up with rope; 1 a box of rough planks lashed with rope; 2 banded, a red goblin
     * hand daubed on the front and a skull on the lid. [open]: the lid thrown back, the box empty but for straw.
     */
    private fun chest(v: Int, open: Boolean): PixelImage {
        val c = Canvas(TH.toInt() + 80, 4100 + v, w = 140)
        val i0 = -0.84; val i1 = -0.16; val j0 = -0.74; val j1 = -0.32
        val zb = 27.0; val zl = 35.0
        val wood = if (v == 1) plankDark else plank
        // reaching well out round the box, so it shows on the dark floor (D1.5, test of 0.1.741: no shadow to be seen)
        c.shadow(i0, j0, i1, j1, 0.9, pad = 0.22, edge = 3.5)
        if (open) c.box(i0, j0 - 0.06, i1, j0, zb, zb + 32, plankDark, plankDark, wood)
        c.box(i0, j0, i1, j1, 0.0, zb, plankTop, wood, wood)
        if (open) {
            // the inside: the far walls in shade, the bottom lost in the dark
            c.fill(i0 + 0.03, j0 + 0.03, i1 - 0.03, j1 - 0.03, zb, argb(0x2A2018))
            c.fill(i0 + 0.03, j0 + 0.1, i1 - 0.1, j1 - 0.03, zb, hole)
        }
        c.planks(i0, j0, i1, j1, 0.0, zb, if (v == 1) 4 else 3, 4100 + v)
        if (open) {
            // what is left: a few wisps of straw in the dark
            for (k in 0..3) {
                val x = c.x(-0.7 + k * 0.14, -0.5 + rnd(k, v, 9) * 0.1); val y = c.y(-0.7 + k * 0.14, -0.5, zb - 2)
                c.s.line(x - 3, y, x + 3, y - 1, argb(0x6A5A38))
            }
        } else {
            c.box(i0 - 0.02, j0 - 0.02, i1 + 0.02, j1 + 0.02, zb, zb + 4, plankTop, wood, wood)
            c.box(i0, j0 + 0.05, i1, j1 - 0.05, zb + 4, zl, plankTop, wood, wood)
        }
        val zt = if (open) zb else zl
        if (v != 1) {
            // iron bands round the box and over the lid
            for (i in listOf(i0 + 0.1, i1 - 0.1)) {
                c.box(i - 0.025, j1 - 0.002, i + 0.025, j1 + 0.012, 0.0, zt, ironMat, ironMat, ironMat, bevel = 0.4)
                if (!open) c.box(i - 0.025, j0 + 0.03, i + 0.025, j1 + 0.012, zt - 1, zt + 1, ironMat, ironMat, ironMat, bevel = 0.3)
            }
            c.box(i1 - 0.002, j0 + 0.1, i1 + 0.012, j0 + 0.14, 0.0, zt, ironMat, ironMat, ironMat, bevel = 0.4)
            // the lock plate, bent; on the shut ones a rope tied round where the lock was broken
            c.box(-0.55, j1, -0.45, j1 + 0.016, zb - 10, zb + 1, ironMat, ironMat, ironMat, bevel = 0.4)
            c.s.dot(c.x(-0.5, j1 + 0.016), c.y(-0.5, j1 + 0.016, zb - 5), hole)
        }
        if (!open && v != 2) {
            for (i in listOf(-0.62, -0.38)) {
                c.s.line(c.x(i, j1 + 0.01), c.y(i, j1 + 0.01, 0.0), c.x(i, j1 + 0.01), c.y(i, j1 + 0.01, zl), argb(0x4A3E2A))
                c.s.line(c.x(i, j1 + 0.01), c.y(i, j1 + 0.01, zl), c.x(i, j0), c.y(i, j0, zl), argb(0x4A3E2A))
            }
            val x = c.x(-0.5, j1 + 0.01); val y = c.y(-0.5, j1 + 0.01, zl - 2)
            c.s.blob(x, y, 2.6, 2.0, rope, depth = 0.5)
            c.s.limb(x, y + 1, x - 2, y + 8, 0.9, 0.7, rope)
            c.s.limb(x + 1, y + 1, x + 3, y + 7, 0.9, 0.7, rope)
        }
        if (v == 2) {
            // a red hand daubed on the front, a skull on the lid
            val x = c.x(-0.68, j1); val y = c.y(-0.68, j1, zb * 0.5)
            c.s.tint(x, y, 4.0, 4.5, argb(0x7A1E14), 0.75)
            for (k in -1..2) c.s.line(x + k * 2.0, y - 4, x + k * 2.4, y - 8, argb(0x6A1A12))
            if (!open) {
                val sx = c.x(-0.4, -0.55); val sy = c.y(-0.4, -0.55, zl)
                c.s.blob(sx, sy - 4, 4.6, 4.0, boneMat, depth = 0.8)
                c.s.blob(sx, sy - 0.5, 3.0, 1.8, boneMat, depth = 0.5)
                c.s.flat(sx - 1.6, sy - 4, 1.1, 1.2, hole); c.s.flat(sx + 1.6, sy - 4, 1.1, 1.2, hole)
            }
        }
        // scuffs where it was dragged in
        for (k in 0..3) c.s.tint(c.x(i0 + 0.12 + k * 0.16, j1 + 0.03), c.y(i0 + 0.12 + k * 0.16, j1 + 0.03), 3.0, 1.0, argb(0x6A5E4A), 0.2)
        return c.done()
    }

    /** Crates and a barrel (13e.2): [v] 0 two crates, the small one on the big; 1 a smashed crate, a sack against it; 2 a barrel, its lid askew. */
    private fun crates(v: Int): PixelImage {
        val c = Canvas(TH.toInt() + 96, 4200 + v)
        fun crate(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, seed: Int, smashed: Boolean = false) {
            c.box(i0, j0, i1, j1, z0, z1, plankTop, plank, plank)
            c.planks(i0, j0, i1, j1, z0, z1, 3, seed)
            // battens across the faces
            c.box(i0 + 0.03, j1, i0 + 0.08, j1 + 0.012, z0, z1, plankDark, plankDark, plankDark, bevel = 0.4)
            c.box(i1, j0 + 0.03, i1 + 0.012, j0 + 0.08, z0, z1, plankDark, plankDark, plankDark, bevel = 0.4)
            if (smashed) {
                val x = c.x((i0 + i1) / 2, j1); val y = c.y((i0 + i1) / 2, j1, (z0 + z1) / 2)
                c.s.poly(Mat(Ramp.of(hole), inline = false), x - 7, y - 5, x + 6, y - 3, x + 4, y + 6, x - 5, y + 4, bevel = 0.0)
                c.s.limb(x - 6, y + 4, x + 2, y + 12, 1.6, 1.4, plank)
                c.s.blob(x, y + 8, 7.0, 3.0, strawMat, depth = 0.5)
                c.s.blob(x - 4, y + 11, 5.0, 2.0, strawMat, depth = 0.4)
            }
        }
        when (v) {
            0 -> {
                c.shadow(-0.88, -0.88, -0.12, -0.12)
                crate(-0.86, -0.86, -0.14, -0.14, 0.0, 38.0, 4210)
                crate(-0.74, -0.8, -0.28, -0.34, 38.0, 64.0, 4211)
            }
            1 -> {
                c.shadow(-0.85, -0.85, -0.15, -0.15)
                crate(-0.84, -0.84, -0.3, -0.3, 0.0, 32.0, 4212, smashed = true)
                // a sack slumped against its front
                val x = c.x(-0.2, -0.36); val y = c.y(-0.2, -0.36)
                c.s.blob(x, y - 9, 11.0, 10.0, sackMat, depth = 0.8)
                c.s.blob(x + 1, y - 18, 8.0, 6.0, sackMat, depth = 0.8)
                c.s.limb(x + 1, y - 22, x + 3, y - 28, 2.0, 1.4, sackMat)
                c.s.line(x - 1, y - 22, x + 4, y - 23, argb(0x3A3024))
            }
            else -> {
                c.shadow(-0.82, -0.82, -0.18, -0.18)
                val x = c.x(-0.5, -0.5); val y = c.y(-0.5, -0.5)
                val zt = 50.0
                c.s.chain(plank, x, y - 3, 15.0, x, y - zt * ZS * 0.5, 17.5, x, y - zt * ZS + 3, 15.0)
                for (k in -3..3) c.s.line(x + k * 4.4, y - zt * ZS + 4, x + k * 4.9, y - 3, seamC)
                for ((hz, r) in listOf(5.0 to 15.4, 25.0 to 17.8, 45.0 to 15.4)) {
                    val hy = y - hz * ZS
                    c.s.poly(ironMat, x - r, hy - 1.4, x + r, hy - 1.4, x + r, hy + 1.4, x - r, hy + 1.4, tiltY = 0.1, bevel = 0.8)
                }
                c.s.blob(x, y - zt * ZS, 14.6, 7.0, plankDark, depth = 0.2)
                c.s.flat(x + 2, y - zt * ZS, 10.0, 4.6, hole)
                // the lid knocked half off
                c.s.poly(plankTop, x - 6, y - zt * ZS - 4, x + 16, y - zt * ZS - 9, x + 20, y - zt * ZS - 3, x - 2, y - zt * ZS + 3, tiltY = -0.6, bevel = 1.0)
            }
        }
        return c.done()
    }

    /** A goblin's sleeping place on the floor (13e.2), flat, walked over: [v] 0 a heap of rags, 1 a wolf's hide on straw, 2 a blanket half unrolled, a bundle by it. */
    private fun bedroll(v: Int): PixelImage {
        val c = Canvas(TH.toInt() + 30, 4300 + v)
        when (v) {
            0 -> {
                c.shadow(-0.86, -0.8, -0.14, -0.22, 0.35)
                val cloths = listOf(m(0x5E5040, grain = 0.2, sat = 0.6, value = 0.6, bias = -0.25), m(0x6A5E4C, grain = 0.2, sat = 0.5, value = 0.65, bias = -0.25),
                    m(0x5A3428, grain = 0.2, sat = 0.55, value = 0.55, bias = -0.25), m(0x4E4438, grain = 0.2, sat = 0.5, value = 0.6, bias = -0.25))
                for ((k, mat) in cloths.withIndex()) {
                    val ci = -0.5 + (rnd(k, 1, 4300) - 0.5) * 0.3; val cj = -0.5 + (rnd(k, 2, 4300) - 0.5) * 0.3
                    val pts = ArrayList<Double>()
                    for (q in 0 until 9) {
                        val a = q * 2 * Math.PI / 9 + rnd(k, q, 4301) * 0.4
                        val r = (0.3 - k * 0.03) * (1 + (rnd(k, q, 4302) - 0.5) * 0.35)
                        val ii = ci + Math.cos(a) * r; val jj = cj + Math.sin(a) * r * 0.75
                        pts += c.x(ii, jj); pts += c.y(ii, jj, 3.0 + k * 3)
                    }
                    c.s.poly(mat, *pts.toDoubleArray(), tiltY = -0.6, bevel = 3.0)
                }
                // a rolled rag for a pillow
                c.s.limb(c.x(-0.75, -0.6), c.y(-0.75, -0.6, 12.0), c.x(-0.6, -0.78), c.y(-0.6, -0.78, 12.0), 4.0, 3.6, cloths[1])
            }
            1 -> {
                // straw spread out, the hide laid on it, legs splayed, head at the back
                c.shadow(-0.92, -0.85, -0.08, -0.15, 0.3)
                for (k in 0 until 28) {
                    val ii = -0.88 + rnd(k, 1, 4310) * 0.76; val jj = -0.82 + rnd(k, 2, 4310) * 0.66
                    val x = c.x(ii, jj); val y = c.y(ii, jj, 1.0)
                    c.s.line(x - 3, y + rnd(k, 3, 4310) * 2 - 1, x + 3, y - rnd(k, 4, 4310) * 2 + 1, if (k % 3 == 0) argb(0x5E4E30) else argb(0x9A8452))
                }
                val pts = doubleArrayOf(-0.78, -0.62, -0.5, -0.74, -0.28, -0.66, -0.2, -0.42, -0.3, -0.24, -0.56, -0.22, -0.76, -0.36)
                val xy = ArrayList<Double>()
                for (q in pts.indices step 2) { xy += c.x(pts[q], pts[q + 1]); xy += c.y(pts[q], pts[q + 1], 3.0) }
                c.s.poly(hideMat, *xy.toDoubleArray(), tiltY = -0.7, bevel = 2.5)
                // legs, head, the dark stripe down the back
                for ((a, b) in listOf((-0.78 to -0.62) to (-0.92 to -0.72), (-0.28 to -0.66) to (-0.22 to -0.82), (-0.3 to -0.24) to (-0.16 to -0.14), (-0.76 to -0.36) to (-0.9 to -0.26)))
                    c.s.limb(c.x(a.first, a.second), c.y(a.first, a.second, 3.0), c.x(b.first, b.second), c.y(b.first, b.second, 2.0), 2.4, 1.4, hideMat)
                c.s.blob(c.x(-0.52, -0.82), c.y(-0.52, -0.82, 5.0), 6.0, 4.0, hideDarkMat, depth = 0.6)
                c.s.limb(c.x(-0.52, -0.7), c.y(-0.52, -0.7, 4.0), c.x(-0.48, -0.3), c.y(-0.48, -0.3, 4.0), 2.6, 2.0, hideDarkMat)
            }
            else -> {
                c.shadow(-0.86, -0.7, -0.14, -0.3, 0.35)
                // the flat part with folds
                val a = doubleArrayOf(-0.84, -0.66, -0.4, -0.66, -0.4, -0.34, -0.84, -0.34)
                val xy = ArrayList<Double>()
                for (q in a.indices step 2) { xy += c.x(a[q], a[q + 1]); xy += c.y(a[q], a[q + 1], 2.0) }
                c.s.poly(sackMat, *xy.toDoubleArray(), tiltY = -0.7, bevel = 2.0)
                for (k in 0 until 3) c.seam(-0.78 + k * 0.13, -0.64, -0.76 + k * 0.13, -0.36, 3.0)
                for (k in 0 until 6) c.s.dot(c.x(-0.82 + k * 0.08, -0.34), c.y(-0.82 + k * 0.08, -0.34, 1.0), argb(0x5E5040))
                // the rest still rolled, tied
                c.s.limb(c.x(-0.34, -0.68), c.y(-0.34, -0.68, 7.0), c.x(-0.34, -0.32), c.y(-0.34, -0.32, 7.0), 6.0, 6.0, sackMat)
                c.s.blob(c.x(-0.34, -0.32), c.y(-0.34, -0.32, 7.0), 4.0, 5.4, sackMat, depth = 0.3)
                c.s.flat(c.x(-0.34, -0.32), c.y(-0.34, -0.32, 7.0), 2.4, 3.4, argb(0x3A3024))
                c.seam(-0.34, -0.5, -0.34, -0.5, 1.0, 13.0, argb(0x2A2016))
                // a bundle of hide by it
                val x = c.x(-0.2, -0.78); val y = c.y(-0.2, -0.78)
                c.s.blob(x, y - 5, 8.0, 6.0, hideDarkMat)
                c.s.limb(x, y - 10, x + 2, y - 15, 2.0, 1.2, hideDarkMat)
            }
        }
        return c.done()
    }

    /**
     * Bones on the floor (13e), in the hero's scale: a skull about as big as his head, not bigger. Three looks as in
     * [MapCave.bones]: a heap pushed together with two skulls, what scavengers left of a beast (a spine pulled apart,
     * ribs, the long skull), what is left of a goblin (scattered bones, the small skull, a dented cap, a broken blade).
     */
    private fun bones(v: Int): PixelImage {
        val c = Canvas(TH.toInt() + 24, 4400 + v)
        val bone = boneMat; val dark = m(0x7A6C54, grain = 0.25, sat = 0.75)
        fun at(i: Double, j: Double, z: Double = 0.0) = c.x(i, j) to c.y(i, j, z)
        when (v) {
            0 -> {
                c.shadow(-0.78, -0.78, -0.22, -0.22, 0.3)
                for (k in 0 until 11) {
                    val a = rnd(k, 1, 4401) * 2 * Math.PI; val r = Math.sqrt(rnd(k, 2, 4401)) * 0.24
                    val (x, y) = at(-0.5 + Math.cos(a) * r, -0.5 + Math.sin(a) * r, 1.0 + rnd(k, 3, 4401) * 3)
                    MapCave.boneAt(c.s, x, y, rnd(k, 4, 4401) * 180, 7 + rnd(k, 5, 4401) * 7, 0.9 + rnd(k, 6, 4401) * 0.4, if (k % 3 == 0) dark else bone)
                }
                at(-0.56, -0.46, 6.0).let { (x, y) -> MapCave.skull(c.s, x, y, 0.55) }
                at(-0.42, -0.6, 4.0).let { (x, y) -> MapCave.skull(c.s, x, y, 0.5) }
            }
            1 -> {
                c.shadow(-0.86, -0.72, -0.14, -0.28, 0.25)
                var i = -0.8; var j = -0.42; var a = -0.75
                val spine = ArrayList<Pair<Double, Double>>()
                for (k in 0 until 11) {
                    a += (rnd(k, 1, 4410) - 0.5) * 0.35
                    i += Math.cos(a) * 0.055; j -= Math.sin(a) * 0.055
                    spine += at(i, j, 1.5)
                }
                for (k in 2 until 9) {
                    val (sx, sy) = spine[k]
                    for (side in intArrayOf(-1, 1)) {
                        if (rnd(k, side, 4411) < 0.25) continue
                        val len = (4 + rnd(k, side, 4412) * 4) * if (rnd(k, side, 4413) < 0.3) 0.55 else 1.0
                        c.s.chain(if (side < 0) bone else dark, sx, sy, 0.8, sx + 1.5, sy + side * len * 0.55, 0.7, sx + 1.0, sy + side * len, 0.5)
                    }
                }
                for ((k, p) in spine.withIndex()) c.s.blob(p.first, p.second, 1.8 - k * 0.04, 1.4, bone)
                spine.last().let { (x, y) -> MapCave.skull(c.s, x + 5, y + 1, 0.55, beast = true) }
                at(-0.72, -0.7, 1.0).let { (x, y) -> MapCave.boneAt(c.s, x, y, 25.0, 11.0, 1.1) }
            }
            else -> {
                c.shadow(-0.8, -0.8, -0.2, -0.2, 0.25)
                for (k in 0 until 6) {
                    val (x, y) = at(-0.75 + rnd(k, 1, 4420) * 0.5, -0.75 + rnd(k, 2, 4420) * 0.5, 1.0)
                    MapCave.boneAt(c.s, x, y, rnd(k, 3, 4420) * 180, 5 + rnd(k, 4, 4420) * 6, 0.8, if (k % 2 == 0) bone else dark)
                }
                at(-0.36, -0.58, 3.0).let { (x, y) -> MapCave.skull(c.s, x, y, 0.42) }
                // the dented iron cap, rolled aside
                at(-0.66, -0.36, 3.0).let { (x, y) -> c.s.blob(x, y, 5.0, 3.6, m(0x5A3E2C, shine = 0.15, grain = 0.35, sat = 0.8, value = 0.85)); c.s.line(x - 3, y - 2, x, y, hole) }
                // a broken blade
                val (bx, by) = at(-0.3, -0.3, 0.5); val (ex, ey) = at(-0.3, -0.62, 0.5)
                c.s.limb(bx, by, ex, ey, 1.1, 0.8, ironMat)
                c.s.limb(bx - 1, by + 1, bx + 2, by + 3, 1.3, 1.3, plankDark)
            }
        }
        return c.done()
    }

    // ------------------------------------------------------------------ things that glow: mushrooms and crystals (13e)

    private val stemMat = m(0x8C9A90, grain = 0.15, sat = 0.5)
    private val capMat = m(0x2E8C88, shine = 0.4, grain = 0.12, value = 0.95)
    private val gillMat = m(0x1E5450, grain = 0.2, sat = 0.8)
    private val stumpMat = m(0x3A2E26, grain = 0.1, sat = 0.55, value = 0.8)
    private val mossMat = m(0x34402A, grain = 0.12, sat = 0.6, value = 0.6)
    private val crystalMat = m(0x6A5296, shine = 0.7, grain = 0.12, sat = 0.75, value = 0.82)
    private val crystalDarkMat = m(0x3E2E5E, shine = 0.45, grain = 0.12, sat = 0.75)
    private val rockMat = m(0x4A443C, grain = 0.26, sat = 0.7)
    private val glowCap = argb(0xB8FFF4)
    private val glowCrystal = argb(0xD8C8FF)

    /** A horizontal circle of radius 1 tile seen diagonally: half axes in art pixels (2:1). */
    private val RX = TW / sqrt(2.0)
    private val RY = TH / sqrt(2.0)

    /**
     * One glowing mushroom standing at ([i], [j]): a stem of [hgt] units, a cap of radius [r] (in tiles) seen from
     * above at a slant, its rim dark with gills below, a pale glow on the crown. [lean] tips the cap sideways in pixels.
     */
    private fun Canvas.mushroom(i: Double, j: Double, r: Double, hgt: Double, lean: Double) {
        val bx = x(i, j); val by = y(i, j)
        val tx = bx + lean; val ty = y(i, j, hgt)
        val rx = r * RX; val ry = r * RY
        s.limb(bx, by, tx, ty + ry * 0.3, rx * 0.22, rx * 0.16, stemMat)
        // the underside first (the gills, in shadow), then the dome over it
        s.blob(tx, ty + ry * 0.35, rx, ry * 0.9, gillMat, depth = 0.4)
        s.blob(tx, ty - ry * 0.25, rx * 0.97, ry + rx * 0.28, capMat, depth = 0.7)
        s.flat(tx - rx * 0.28, ty - ry * 0.55, rx * 0.32, ry * 0.3, glowCap)
    }

    /**
     * Glowing mushrooms on one tile (13e, in place of the old flat ones), seen diagonally, three ways: a crowd of small
     * ones on a mossy hump, three or four tall ones bent towards each other, shelf fungi up a rotting stump. Ankle to
     * knee high, so the hero is never hidden; walked over.
     */
    private fun mushrooms(v: Int, seed: Int): PixelImage {
        val c = Canvas(110, 4600 + v)
        when (v) {
            0 -> {
                c.shadow(-0.82, -0.82, -0.18, -0.18, 0.3)
                c.s.blob(c.x(-0.5, -0.5), c.y(-0.5, -0.5, 1.5), 0.2 * RX, 0.2 * RY + 1.5, mossMat, depth = 0.25)
                val items = List(9) { k ->
                    val a = rnd(k, seed, 4601) * 2 * PI; val d = sqrt(rnd(k, seed, 4602)) * 0.27
                    doubleArrayOf(-0.5 + cos(a) * d, -0.5 + sin(a) * d, 0.035 + rnd(k, seed, 4603) * 0.03, 9 + rnd(k, seed, 4604) * 9)
                }.sortedBy { it[0] + it[1] }
                for ((k, it) in items.withIndex()) c.mushroom(it[0], it[1], it[2], it[3], (rnd(k, seed, 4605) - 0.5) * 3)
            }
            1 -> {
                c.shadow(-0.86, -0.86, -0.14, -0.14, 0.3)
                val items = List(3 + seed % 2) { k ->
                    val a = (k + rnd(k, seed, 4611) * 0.6) * 2 * PI / 3.5; val d = 0.12 + rnd(k, seed, 4612) * 0.14
                    doubleArrayOf(-0.5 + cos(a) * d, -0.5 + sin(a) * d, 0.07 + rnd(k, seed, 4613) * 0.05, 16 + rnd(k, seed, 4614) * 14, cos(a) - sin(a))
                }.sortedBy { it[0] + it[1] }
                // the tall ones lean out from the middle of the clump
                for (it in items) c.mushroom(it[0], it[1], it[2], it[3], it[4] * 3)
            }
            else -> {
                c.shadow(-0.8, -0.8, -0.2, -0.2, 0.35)
                val bx = c.x(-0.5, -0.5); val by = c.y(-0.5, -0.5)
                // a stump, broken off, black with rot; roots into the floor
                for (k in 0 until 4) {
                    val a = k * PI / 2 + 0.6
                    c.s.limb(bx, by - 4, bx + cos(a) * 16, by + sin(a) * 6, 4.0, 1.5, stumpMat)
                }
                c.s.limb(bx, by - 2, bx + 1, by - 30, 10.0, 8.0, stumpMat)
                c.s.blob(bx + 1, by - 30, 8.0, 3.5, m(0x4A3C30, grain = 0.15, sat = 0.6, value = 0.8), depth = 0.3)
                // shelves stepping up round the stump, on the half the camera sees
                for (k in 0 until 6) {
                    val a = ((k * 0.62 + seed * 0.37) % 1.0 - 0.5) * 2.4
                    val ox = sin(a) * 8.5; val oy = cos(a) * 3.0
                    val y = by - 6 - k * 4.0 + oy; val r = 6.0 - k * 0.45
                    c.s.blob(bx + ox, y + 1.4, r, 2.0, gillMat, depth = 0.4)
                    c.s.blob(bx + ox, y, r, 2.6, capMat, depth = 0.5)
                    c.s.flat(bx + ox - 1.5, y - 0.8, r * 0.35, 0.8, glowCap)
                }
                for (k in 0 until 3) c.mushroom(-0.32 - rnd(k, seed, 4621) * 0.12, -0.28 - rnd(k, seed, 4622) * 0.1, 0.03, 6.0 + k * 2, 0.0)
            }
        }
        return c.done()
    }

    /**
     * Crystals growing out of the foot of the rock face that turns to the floor (the floor at [di], [dj] from the
     * tile, one of them ±1): five to eight six-sided shards from a broken base, leaning out into the room, each a real
     * prism with a pointed tip, lit faces paler, tips glowing; three looks from [v].
     */
    private fun crystals(v: Int, di: Int, dj: Int, seed: Int): PixelImage {
        val c = Canvas(170, 4700 + v)
        // the foot of the face: along the tile's side towards the floor
        fun foot(t: Double): DoubleArray = when {
            di > 0 -> doubleArrayOf(-0.12, -1 + t)
            dj > 0 -> doubleArrayOf(-1 + t, -0.12)
            di < 0 -> doubleArrayOf(-0.88, -1 + t)
            else -> doubleArrayOf(-1 + t, -0.88)
        }
        val n = when (v) { 0 -> 7; 1 -> 4; else -> 9 }
        class Shard(val b: DoubleArray, val d: DoubleArray, val len: Double, val r: Double)
        val shards = List(n) { k ->
            val t = if (v == 1) 0.3 + k * 0.14 + (rnd(k, seed, 4701) - 0.5) * 0.1 else 0.1 + (k + rnd(k, seed, 4701)) / n * 0.8
            val b = foot(t)
            // mostly up, leaning out into the room and a little sideways
            val out = 0.12 + rnd(k, seed, 4702) * 0.3; val side = (rnd(k, seed, 4703) - 0.5) * 0.6
            var dx = di * out + (if (di == 0) side else 0.0); var dy = dj * out + (if (dj == 0) side else 0.0); var dz = 1.0
            val l = sqrt(dx * dx + dy * dy + dz * dz); dx /= l; dy /= l; dz /= l
            val big = if (v == 1) k == 1 else k == 0
            val len = (if (big) 95.0 else 32.0 + rnd(k, seed, 4704) * 40) * (if (v == 2) 0.7 else 1.0)
            Shard(b, doubleArrayOf(dx, dy, dz), len, (if (big) 0.12 else 0.06 + rnd(k, seed, 4705) * 0.04) * TILE_Z)
        }.sortedBy { it.b[0] + it.b[1] }
        // the broken rock they grow from
        val mid = foot(0.5)
        c.shadow(mid[0] - 0.35, mid[1] - 0.35, mid[0] + 0.35, mid[1] + 0.35, 0.3)
        // the view and the light, in tiles with z in units / TILE_Z
        val vx = 0.612; val vy = 0.612; val vz = 0.5
        fun px(p: DoubleArray) = c.x(p[0], p[1]) to c.y(p[0], p[1], p[2])
        for ((k, sh) in shards.withIndex()) {
            val d = sh.d
            // two directions across the shard
            var ux = -d[1]; var uy = d[0]; var uz = 0.0
            val ul = sqrt(ux * ux + uy * uy).coerceAtLeast(1e-6); ux /= ul; uy /= ul
            val wx = d[1] * uz - d[2] * uy; val wy = d[2] * ux - d[0] * uz; val wz = d[0] * uy - d[1] * ux
            val r = sh.r / TILE_Z; val len = sh.len / TILE_Z
            val turn = rnd(k, seed, 4706) * PI
            fun ring(t: Double, a: Double) = doubleArrayOf(
                sh.b[0] + d[0] * t + r * (cos(a) * ux + sin(a) * wx),
                sh.b[1] + d[1] * t + r * (cos(a) * uy + sin(a) * wy),
                (d[2] * t + r * (cos(a) * uz + sin(a) * wz)) * TILE_Z)
            val apex = doubleArrayOf(sh.b[0] + d[0] * len, sh.b[1] + d[1] * len, d[2] * len * TILE_Z)
            for (f in 0 until 6) {
                val a0 = turn + f * PI / 3; val a1 = a0 + PI / 3; val am = a0 + PI / 6
                // the face's normal: outwards across the shard
                val nx = cos(am) * ux + sin(am) * wx; val ny = cos(am) * uy + sin(am) * wy; val nz = cos(am) * uz + sin(am) * wz
                val facing = nx * vx + ny * vy + nz * vz
                if (facing <= 0) continue
                // to the picture: right (1, −1, 0)/√2, up (−1, −1, 2·0.866)/…, towards us the view
                val sxn = (nx - ny) * 0.707; val syn = -(-0.354 * nx - 0.354 * ny + 0.866 * nz)
                val lit = sxn > -0.1
                val p0 = px(ring(0.0, a0)); val p1 = px(ring(0.0, a1)); val q1 = px(ring(len * 0.78, a1)); val q0 = px(ring(len * 0.78, a0)); val ap = px(apex)
                c.s.poly(if (lit) crystalMat else crystalDarkMat, p0.first, p0.second, p1.first, p1.second, q1.first, q1.second, q0.first, q0.second,
                    tiltX = sxn * 0.8, tiltY = syn * 0.8, bevel = 0.6)
                c.s.poly(if (lit) crystalMat else crystalDarkMat, q0.first, q0.second, q1.first, q1.second, ap.first, ap.second,
                    tiltX = sxn * 0.7, tiltY = syn * 0.7 - 0.25, bevel = 0.5)
                // an edge catching the glow
                if (lit) c.s.line(q0.first, q0.second, ap.first, ap.second, glowCrystal)
            }
            val ap = px(apex); c.s.dot(ap.first, ap.second, glowCrystal)
        }
        // broken stone and grit round their feet
        for (k in 0 until 5) {
            val p = foot(0.15 + rnd(k, seed, 4710) * 0.7)
            val (x, y) = px(doubleArrayOf(p[0] + di * 0.1 * rnd(k, seed, 4711), p[1] + dj * 0.1 * rnd(k, seed, 4711), 1.5))
            val rr = 2.0 + rnd(k, seed, 4712) * 4.0
            c.s.blob(x, y, rr, rr * 0.6, rockMat, depth = 0.6)
        }
        return c.done()
    }

    // ------------------------------------------------------------------ the tiles

    private fun isRock(t: Tile) = t == Tile.CAVE_WALL || t == Tile.CRYSTAL || t == Tile.TORCH

    private fun thing(map: MapDef, tx: Int, ty: Int, key: String, flat: Boolean = false, low: Boolean = flat, make: () -> PixelImage): WorldArt.Obj {
        val img = synchronized(tallCache) { tallCache.getOrPut(key, make) }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        val depth = if (flat) (tx + ty) * T else (tx + ty) * T + T * 3 / 2 - 1
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, depth - wx, 2, low, corner = true)
    }

    /**
     * Where a torch in the rock hangs, in map pixels: on the face it turns to the floor, if that face is a back wall
     * (the floor lies at +x or +y, so the face stands up towards the viewer); null otherwise.
     */
    fun torchFace(map: MapDef, tx: Int, ty: Int): Pair<Double, Double>? {
        val T = WorldArt.T.toDouble()
        val east = !isRock(MapCave.caveTile(map, tx + 1, ty)); val south = !isRock(MapCave.caveTile(map, tx, ty + 1))
        return when {
            east && south -> (tx + 1) * T - 1 to (ty + 1) * T - 1
            east -> (tx + 1) * T - 1 to (ty + 0.5) * T
            south -> (tx + 0.5) * T to (ty + 1) * T - 1
            else -> null
        }
    }

    /**
     * Which of three looks the gate has (D1.11), the same all across it: from its leftmost tile. The seed is picked so
     * the one gate of chapter 1 (Grak's hall) is the one the goblins patched; the old look stays for later caves.
     */
    fun gateLook(map: MapDef, tx: Int, ty: Int): Int {
        var x0 = tx
        while (MapCave.caveTile(map, x0 - 1, ty) == Tile.GATE) x0--
        return Math.floorMod(hash(x0, ty, 50), 3)
    }

    /**
     * Which of three looks a torch in the rock has (D1.11): an iron bracket, an iron ring on a longer arm, or no iron at
     * all, the stick wedged into a crack with stones. Neighbouring torches on one face never share a look.
     */
    fun torchLook(map: MapDef, tx: Int, ty: Int): Int {
        var n = 0
        for (y in 0 until map.height) for (x in 0 until map.width) if (map.tile(x, y) == Tile.TORCH && (y < ty || (y == ty && x < tx))) n++
        return Math.floorMod(n + hash(map.width, map.height, 53), 3)
    }

    /** Frames of [flame]; the screen steps through them about twelve times a second. */
    const val FLAMES = 32
    /** The flame's root in [flame]'s picture (2 art pixels to the map pixel). */
    const val FLAME_X = 10
    const val FLAME_Y = 28
    private val flames = arrayOfNulls<PixelImage>(FLAMES)

    /**
     * A torch's flame, frame [k] of [FLAMES] (13e.3, 10: finer than the old two pictures): a teardrop of heat whose
     * height breathes and whose tip sways, torn at its edges by noise rising through it, so tongues lick up and part;
     * pale core, orange body, deep red rim, the rim half seen through.
     */
    fun flame(k: Int): PixelImage = flames[Math.floorMod(k, FLAMES)] ?: synchronized(flames) {
        val f = Math.floorMod(k, FLAMES)
        flames[f] ?: run {
            val w = 20; val h = 34
            val img = PixelImage(w, h)
            val p = f * 2 * PI / FLAMES
            val tall = 1.0 + 0.12 * sin(p * 3) + 0.06 * sin(p * 7 + 1)
            for (y in 0 until h) for (x in 0 until w) {
                val ny = (FLAME_Y - y - 0.5) / (24.0 * tall)
                if (ny < -0.08 || ny > 1.25) continue
                val sway = ny.coerceAtLeast(0.0).let { it * sqrt(it) } * (2.2 * sin(p) + 1.1 * sin(2 * p + 1.0) + 0.6 * sin(5 * p))
                val nx = x + 0.5 - FLAME_X - sway
                val q = ny.coerceIn(0.0, 1.0)
                val half = 8.5 * sqrt(q + 0.06) * (1 - q).pow(0.7) + 0.5
                // noise rising through the flame (it moves up by a full cell per loop and a half)
                val n = vnoise(x * 0.42, (y + f * 0.9) * 0.3, 77) - 0.5
                val v = 1 - abs(nx) / half - n * (0.25 + 0.9 * q) - (if (ny > 1) (ny - 1) * 3 else 0.0)
                if (v <= 0.04) continue
                val c = when {
                    v > 0.62 && q < 0.55 -> argb(0xFFF4C0)
                    v > 0.45 -> argb(0xFFC860)
                    v > 0.22 -> argb(0xF08A2A)
                    else -> argb(0xB8401A)
                }
                val a = when { v > 0.22 -> 255; v > 0.12 -> 210; else -> 130 }
                img.set(x, y, (a shl 24) or (c and 0xFFFFFF))
            }
            img.also { flames[f] = it }
        }
    }

    /** One thing alone, for the preview's gallery (13e.2). */
    internal fun sample(t: Tile, v: Int, open: Boolean = false): PixelImage = when (t) {
        Tile.CHEST -> chest(v, open)
        Tile.CRATE -> crates(v)
        // the gate's two halves: [open] stands for the right one here
        Tile.GATE -> gate(!open, v)
        else -> bedroll(v)
    }

    /** The cave's tiles seen diagonally, or null for those still drawn by [MapCave]. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int, chestOpen: Boolean, gateOpen: Boolean): List<WorldArt.Obj>? {
        val t = MapCave.caveTile(map, tx, ty)
        val v = (hash(tx, ty, 41) / 7) % 3
        when (t) {
            Tile.SUPPORT -> {
                val left = MapCave.caveTile(map, tx - 1, ty) != Tile.SUPPORT
                val sv = Math.floorMod(hash(if (left) tx else tx - 1, ty, 43), 3)
                return listOf(thing(map, tx, ty, "support/$left/$sv") { support(left, sv) })
            }
            Tile.GATE -> {
                if (gateOpen) return emptyList()
                val left = MapCave.caveTile(map, tx - 1, ty) != Tile.GATE
                val gv = gateLook(map, tx, ty)
                return listOf(thing(map, tx, ty, "gate/$left/$gv") { gate(left, gv) })
            }
            Tile.CHEST -> return listOf(thing(map, tx, ty, "chest/$v/$chestOpen", low = true) { chest(v, chestOpen) })
            Tile.CRATE -> return listOf(thing(map, tx, ty, "crates/$v") { crates(v) })
            // walked over: sorted behind the hero, from the tile's back corner
            Tile.BEDROLL -> return listOf(thing(map, tx, ty, "bed/$v", flat = true) { bedroll(v) })
            Tile.BONES -> return listOf(thing(map, tx, ty, "bones/$v", flat = true) { bones(v) })
            // the goblins' fire: the one from the woods (27.5), stones, ash, spit or kettle, flames swaying
            Tile.CAMPFIRE -> {
                val fv = Math.floorMod(hash(tx, ty, 44), 3); val f = Math.floorMod(frame, 4)
                return listOf(thing(map, tx, ty, "fire/$fv/$f", low = true) { MapWoodIso.campfire(fv, f, 720 + fv) })
            }
            Tile.STALAGMITE -> return listOf(thing(map, tx, ty, "${map.id}/stal/$tx/$ty") { stalagmites(tx, ty) })
            Tile.RUBBLE -> return listOf(thing(map, tx, ty, "${map.id}/rubble/$tx/$ty", flat = true) { rubbleTile(tx, ty) })
            // the roots hung from the roof in the old view; seen diagonally there is no roof, and they stood on the
            // floor like poles in the light (test of 0.1.667: the beam looked false where it lands)
            Tile.SKYLIGHT -> return emptyList()
            Tile.ROCK -> return listOf(thing(map, tx, ty, "${map.id}/boulder/$tx/$ty") { boulderTile(tx, ty) })
            Tile.GLOWSHROOM -> {
                val sv = Math.floorMod(hash(tx, ty, 46), 3)
                return listOf(thing(map, tx, ty, "shrooms/$sv/${(tx * 7 + ty) % 5}", flat = true) { mushrooms(sv, (tx * 7 + ty) % 5) })
            }
            else -> {}
        }
        if (!isRock(t)) return null
        val edge = (-1..1).any { a -> (-1..1).any { b -> !isRock(MapCave.caveTile(map, tx + a, ty + b)) } }
        if (!edge) return if (t == Tile.CAVE_WALL) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen)
        val wall = thing(map, tx, ty, "${map.id}/rock/$tx/$ty") { rockTile(map, tx, ty) }
        // crystals grow from the face towards the floor (13e); a torch on a back face is drawn live by the screen
        // (13e.3, 10: [torchFace]), one with no back face to hang on keeps its old picture, in front of the wall
        if (t == Tile.CRYSTAL) {
            val (di, dj) = listOf(0 to 1, 1 to 0, 0 to -1, -1 to 0).firstOrNull { (a, b) -> !isRock(MapCave.caveTile(map, tx + a, ty + b)) } ?: return listOf(wall)
            val cv = Math.floorMod(hash(tx, ty, 47), 3)
            return listOf(wall, thing(map, tx, ty, "crystals/$cv/$di/$dj/${(tx + ty * 3) % 4}") { crystals(cv, di, dj, (tx + ty * 3) % 4) })
        }
        val rest = if (t == Tile.CAVE_WALL || (t == Tile.TORCH && torchFace(map, tx, ty) != null)) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen).orEmpty()
        return listOf(wall) + rest
    }
}
