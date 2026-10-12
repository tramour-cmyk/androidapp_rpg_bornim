package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/**
 * The cave seen diagonally (13e, draft, only in the preview CAVEDRAFT=1): the rock stands up around the floor instead of
 * lying flat in it, the gate and the old timber supports stand across their passage in the slant.
 * The rock comes from the cave's plan alone (48b), so a cave made by chance needs no work by hand: each rock tile next
 * to the floor is a height field whose foot is the ground's edge of rock; back walls (the floor before them, towards +i
 * or +j) rise to a rough face, front walls (the floor behind them) stay a low rim, so they never hide the hero. Everything else still comes from [MapCave].
 * Same projection and heights as the rooms and the village ([MapRoomIso], [MapTownIso]): 90 × 45 art pixels a tile.
 */
object MapCaveIso {
    /** Off in the game; the preview turns it on. */
    @Volatile var draft = false

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

    private fun rockCell(map: MapDef, x: Int, y: Int) = isRock(map.tile(x, y))

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
        val c = Tile1(TH.toInt() + (TALL * 1.15 * ZS).toInt() + 20)
        val img = c.img
        val w = c.w; val h = c.h
        fun hAt(i: Double, j: Double): Double {
            // i, j in −1..0 over the tile; the grid has one point of margin on each side
            val x = (i + 1) * n + 1; val y = (j + 1) * n + 1
            val ix = floor(x).toInt().coerceIn(0, n + 1); val iy = floor(y).toInt().coerceIn(0, n + 1)
            val u = (x - ix).coerceIn(0.0, 1.0); val v = (y - iy).coerceIn(0.0, 1.0)
            return (hs[ix][iy] * (1 - u) + hs[ix + 1][iy] * u) * (1 - v) + (hs[ix][iy + 1] * (1 - u) + hs[ix + 1][iy + 1] * u) * v
        }
        val lx = 0.64; val ly = 0.46; val lz = 0.5
        val seed = 3600
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
                    val e = 2.5 / n
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
                        t -= max(0.0, (z - TALL * 0.45) / (TALL * 0.4)) * 0.75
                        img.set(px, py, shade(mix(rockDark, rockLight, t.coerceIn(0.0, 1.0)), 1.0))
                    }
                    ymin = kotlin.math.ceil(top)
                }
                s -= 0.5 / TH
            }
        }
        return img
    }

    // ------------------------------------------------------------------ timber and iron

    private fun wood(face: Int, u: Double, v: Double, seed: Int, rgb: Int = 0x4A3826): Int {
        val k = when (face) { 0 -> 0.55; 1 -> 0.9; else -> 1.0 }
        var t = 0.5 + (rnd(floor(v * 6).toInt(), floor(u * 18).toInt(), seed) - 0.5) * 0.25 + (rnd(floor(u * 60).toInt(), floor(v * 40).toInt(), seed + 1) - 0.5) * 0.14
        if (frac(v * 6) < 0.1) t -= 0.25
        return shade(mix(argb(0x120C08), argb(rgb), t.coerceIn(0.0, 1.0)), k)
    }

    private fun iron(face: Int, u: Double, v: Double, seed: Int): Int {
        val k = when (face) { 0 -> 0.5; 1 -> 0.85; else -> 0.95 }
        val rust = vnoise(u * 8, v * 14, seed) > 0.62
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

    /** One tile of the iron gate across the passage before Grak's hall: bars, two cross bands, the post at its end. */
    private fun gate(left: Boolean): PixelImage {
        val c = Tile1(TH.toInt() + (140 * ZS).toInt() + 20)
        val seed = 3400
        val j = -0.5
        val n = 5
        for (k in 0 until n) {
            val i = -1.0 + (k + 0.5) / n
            c.box(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 0.0, 116.0) { f, u, w -> iron(f, u, w, seed + k) }
            // the spike on top
            c.box(i - 0.015, j - 0.015, i + 0.015, j + 0.015, 116.0, 126.0) { f, u, w -> iron(f, u, w, seed + k) }
        }
        for (z in doubleArrayOf(24.0, 92.0)) c.box(-1.0, j - 0.03, 0.0, j + 0.03, z, z + 6) { f, u, w -> iron(f, u, w, seed + 11) }
        // the stone post the gate is set in, at the passage's end
        val pi = if (left) -0.95 else -0.05
        c.box(pi - 0.07, j - 0.1, pi + 0.07, j + 0.1, 0.0, 132.0) { f, u, w -> rock(f, u, w * 132, seed + 20, 260.0) }
        return c.img
    }

    // ------------------------------------------------------------------ the tiles

    private fun isRock(t: Tile) = t == Tile.CAVE_WALL || t == Tile.CRYSTAL || t == Tile.TORCH

    private fun thing(map: MapDef, tx: Int, ty: Int, key: String, make: () -> PixelImage): WorldArt.Obj {
        val img = synchronized(tallCache) { tallCache.getOrPut(key, make) }
        val T = WorldArt.T
        val wx = (tx + 1) * T; val wy = (ty + 1) * T
        return WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, false, corner = true)
    }

    /** The cave's tiles seen diagonally, or null for those still drawn by [MapCave]. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int, chestOpen: Boolean, gateOpen: Boolean): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        val v = Math.floorMod(hash(tx, ty, 41), 3)
        when (t) {
            Tile.SUPPORT -> {
                val left = map.tile(tx - 1, ty) != Tile.SUPPORT
                val sv = Math.floorMod(hash(if (left) tx else tx - 1, ty, 43), 3)
                return listOf(thing(map, tx, ty, "support/$left/$sv") { support(left, sv) })
            }
            Tile.GATE -> {
                if (gateOpen) return emptyList()
                val left = map.tile(tx - 1, ty) != Tile.GATE
                return listOf(thing(map, tx, ty, "gate/$left") { gate(left) })
            }
            else -> {}
        }
        if (!isRock(t)) return null
        val edge = (-1..1).any { a -> (-1..1).any { b -> !isRock(map.tile(tx + a, ty + b)) } }
        if (!edge) return if (t == Tile.CAVE_WALL) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen)
        val wall = thing(map, tx, ty, "${map.id}/rock/$tx/$ty") { rockTile(map, tx, ty) }
        // a crystal or a torch in the rock keeps its old picture, in front of the wall
        val rest = if (t == Tile.CAVE_WALL) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen).orEmpty()
        return listOf(wall) + rest
    }
}
