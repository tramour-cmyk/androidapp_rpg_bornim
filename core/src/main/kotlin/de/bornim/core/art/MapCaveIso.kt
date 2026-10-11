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
 * Back walls (the floor lies before them, towards +i or +j) rise to a rough face of rock in layers; front walls (the
 * floor behind them) stay a low rim, so they never hide the hero. Everything else still comes from [MapCave].
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

    private val rockLight = argb(0x6A6258)
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
        var t = 0.46 + dy * 0.22 + dx * (if (face == 0) -0.1 else 0.1) + (hh - 0.5) * 0.25
        t += (rnd(floor(u * 90).toInt(), floor(z * 1.8).toInt(), seed + 1) - 0.5) * 0.06
        // cracks: where two lumps meet, a dark seam
        if (abs(vnoise(x * 1.6, y * 1.6, seed + 2) - 0.5) < 0.018) t -= 0.22
        // wet streaks where water runs down
        if (vnoise(u * 11, z / 160, seed + 3) > 0.74) t -= 0.07
        // the foot darker, the head lost in the dark
        t -= max(0.0, 1 - z / 12) * 0.15
        t -= max(0.0, (z - top * 0.55) / (top * 0.45)) * 0.3
        return shade(mix(rockDark, rockLight, t.coerceIn(0.0, 1.0)), k)
    }

    private val tallCache = HashMap<String, PixelImage>()

    /**
     * A wall of [height] units: rock in layers, each a little in or out, so the face is rough and no tile like the next;
     * the top layer breaks off unevenly and has no lid (above it the dark, or the rock seen from above when low).
     */
    private fun wallOf(v: Int, height: Double, seed: Int): PixelImage {
        val c = Tile1(TH.toInt() + (height * ZS).toInt() + 30)
        var z = 0.0
        var k = 0
        val layer = height / 2.6
        while (z < height - 1) {
            val z1 = min(height, z + layer * (0.7 + rnd(v, k, seed) * 0.6))
            val last = z1 >= height - 1
            val ii = (rnd(v, k, seed + 1) - 0.45) * 0.1
            val jj = (rnd(v, k, seed + 2) - 0.45) * 0.1
            val zz = z
            // the broken top: up and down along the face, higher in the middle of the tile
            fun edge(u: Double) = z1 + (vnoise(u * 5, k.toDouble(), seed + 4) - 0.5) * layer * 1.2 + kotlin.math.sin(u * Math.PI) * layer * 0.3
            c.box(-1.0, -1.0, -ii.coerceAtMost(0.07), -jj.coerceAtMost(0.07), zz, if (last) z1 + layer * 0.9 else z1) { f, u, w ->
                val zAt = zz + w * ((if (last) z1 + layer * 0.9 else z1) - zz)
                when {
                    f == 2 && last && height > MID -> null
                    f == 2 -> rock(2, u, w, seed + k, height)
                    last && zAt > edge(u) -> null
                    else -> rock(f, u, zAt, seed + k, height)
                }
            }
            z = z1; k++
        }
        return c.img
    }

    private fun tallWall(v: Int) = wallOf(v, TALL, 3100 + v * 17)
    private fun midWall(v: Int) = wallOf(v, MID, 3150 + v * 17)

    /** A front wall: a low rim of broken rock, so the hero behind it stays in sight. */
    private fun lowWall(v: Int): PixelImage {
        val c = Tile1(TH.toInt() + (RIM * ZS).toInt() + 20)
        val seed = 3200 + v * 17
        c.box(-1.0, -1.0, -0.04, -0.04, 0.0, RIM * (0.7 + rnd(v, 0, seed) * 0.5)) { f, u, w -> rock(f, u, w * RIM, seed, TALL) }
        // a few loose stones on the rim
        for (k in 0 until 2) {
            val i = -0.8 + rnd(v, k, seed + 1) * 0.6; val j = -0.8 + rnd(v, k, seed + 2) * 0.6
            val s = 0.08 + rnd(v, k, seed + 3) * 0.06
            c.box(i - s, j - s, i + s, j + s, RIM * 0.9, RIM * 0.9 + 9) { f, u, w -> rock(f, u, w * 9, seed + k, 200.0) }
        }
        return c.img
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
        fun open(x: Int, y: Int) = !isRock(map.tile(x, y))
        val back = open(tx + 1, ty) || open(tx, ty + 1) || open(tx + 1, ty + 1)
        val front = open(tx - 1, ty) || open(tx, ty - 1) || open(tx - 1, ty - 1) || open(tx + 1, ty - 1) || open(tx - 1, ty + 1)
        val wall = when {
            back && front -> thing(map, tx, ty, "mid/$v") { midWall(v) }
            back -> thing(map, tx, ty, "tall/$v") { tallWall(v) }
            front -> thing(map, tx, ty, "low/$v") { lowWall(v) }
            else -> return if (t == Tile.CAVE_WALL) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen)
        }
        // a crystal or a torch in the rock keeps its old picture, in front of the wall
        val rest = if (t == Tile.CAVE_WALL) emptyList() else MapCave.objects(map, tx, ty, frame, chestOpen, gateOpen).orEmpty()
        return listOf(wall) + rest
    }
}
