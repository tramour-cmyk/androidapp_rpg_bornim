package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.sqrt

/**
 * The ground of the woods in the new style (09.10.): drawn at double resolution ([D] art pixels
 * per map pixel, so [S] per tile) and without a visible grid. Meadow, tall grass, flowers, water and
 * the edge of the wood blend into each other along uneven lines; the path is a winding band of
 * trodden earth with two ruts, laid as a curve over the tiles. Where one can walk still follows the
 * tiles, as before.
 *
 * The ground is drawn in chunks of [CH] × [CH] tiles, ahead of time in the background
 * ([prepare]); until a chunk is ready, the map shows the old tiles there. Tiles this ground does not
 * draw (cliffs, cave mouths and the like) keep their old picture on top ([keepsOldTile]).
 */
object MapGround {
    /** Art pixels per map pixel. */
    const val D = 2

    /** Art pixels per tile. */
    const val S = WorldArt.T * D

    /** Tiles per chunk side. */
    const val CH = 4

    /** Whether this map has the new ground. */
    fun supports(map: MapDef) = map.kind == MapKind.FOREST

    /** Tiles drawn by this ground; anything else keeps its old picture on top. */
    private val drawn = setOf(
        Tile.GRASS, Tile.TALL_GRASS, Tile.FLOWERS, Tile.PATH, Tile.TREE, Tile.WATER,
        Tile.ROCK, Tile.LOG, Tile.MENHIR, Tile.SIGN, Tile.CHEST, Tile.CAMPFIRE,
    )

    fun keepsOldTile(tile: Tile) = tile !in drawn

    private val chunks = HashMap<String, PixelImage>()
    private val preparing = HashSet<String>()

    /** The chunk ([cx], [cy]) of [map], or null while it is not drawn yet. */
    fun chunk(map: MapDef, cx: Int, cy: Int): PixelImage? = synchronized(chunks) { chunks["${map.id}/$cx/$cy"] }

    /** Draws all chunks of [map] in the background, nearest to ([nearX], [nearY]) first (tiles). */
    fun prepare(map: MapDef, nearX: Int = 0, nearY: Int = 0) {
        if (!supports(map)) return
        synchronized(preparing) { if (!preparing.add(map.id)) return }
        val t = Thread {
            for ((cx, cy) in order(map, nearX, nearY)) {
                val k = "${map.id}/$cx/$cy"
                if (synchronized(chunks) { k in chunks }) continue
                val img = draw(map, cx, cy)
                synchronized(chunks) { chunks[k] = img }
            }
        }
        t.isDaemon = true
        t.priority = Thread.MIN_PRIORITY
        t.start()
    }

    /** Draws all chunks of [map] right away (for previews and tests). */
    fun prepareNow(map: MapDef) {
        if (!supports(map)) return
        for ((cx, cy) in order(map, 0, 0)) {
            val k = "${map.id}/$cx/$cy"
            if (synchronized(chunks) { k in chunks }) continue
            val img = draw(map, cx, cy)
            synchronized(chunks) { chunks[k] = img }
        }
    }

    private fun order(map: MapDef, nx: Int, ny: Int): List<Pair<Int, Int>> {
        val w = (map.width + CH - 1) / CH; val h = (map.height + CH - 1) / CH
        val all = (0 until h).flatMap { y -> (0 until w).map { x -> x to y } }
        return all.sortedBy { (x, y) -> abs(x * CH + CH / 2 - nx) + abs(y * CH + CH / 2 - ny) }
    }

    // ------------------------------------------------------------------ noise

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    /** Smooth value noise with bumps about [cell] art pixels apart, 0..1. */
    private fun vnoise(x: Double, y: Double, cell: Double, s: Int): Double {
        val fx = x / cell; val fy = y / cell
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var v = fy - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    private fun fbm(x: Double, y: Double, cell: Double, s: Int, octaves: Int = 3): Double {
        var sum = 0.0; var amp = 1.0; var tot = 0.0; var c = cell
        for (o in 0 until octaves) { sum += vnoise(x, y, c, s + o * 17) * amp; tot += amp; amp *= 0.5; c = maxOf(2.0, c / 2) }
        return sum / tot
    }

    // ------------------------------------------------------------------ colors

    private fun rgb(c: Int) = intArrayOf((c shr 16) and 0xFF, (c shr 8) and 0xFF, c and 0xFF)
    private val MOSS_D = rgb(0x2C3A20); private val MOSS_L = rgb(0x56683A)
    private val EARTH_D = rgb(0x3A2E22); private val EARTH_L = rgb(0x6A5840)
    private val LITTER = rgb(0x5E4426)
    private val TALL_D = rgb(0x1A2412); private val TALL_BLADE_D = rgb(0x1E2A16); private val TALL_BLADE_L = rgb(0x6E7A44)
    private val PATH_D = rgb(0x4E3E2C); private val PATH_L = rgb(0x806A4C); private val PATH_HI = rgb(0x948062); private val VERGE = rgb(0x4A4630); private val PUDDLE = rgb(0x1E2224); private val RUT = rgb(0x2E241A); private val CREEP = rgb(0x3A4A26)
    private val WATER_S = rgb(0x2A3A3C); private val WATER_D = rgb(0x0E1A1E); private val GLINT = rgb(0x7A8E90); private val MUD = rgb(0x2A2218)

    private fun mixInto(out: DoubleArray, c: IntArray, t: Double) {
        val k = t.coerceIn(0.0, 1.0)
        for (i in 0..2) out[i] += (c[i] - out[i]) * k
    }

    private fun lerp(a: IntArray, b: IntArray, t: Double, out: DoubleArray) {
        val k = t.coerceIn(0.0, 1.0)
        for (i in 0..2) out[i] = a[i] + (b[i] - a[i]) * k
    }

    // ------------------------------------------------------------------ the shape of things

    /**
     * How much of a kind of ground lies at art pixel ([x], [y]): its tiles counted 1, others 0,
     * blended smoothly between the tile centres. Above 0.5 (shifted by noise) is that ground.
     */
    private fun field(map: MapDef, x: Double, y: Double, test: (Tile) -> Boolean): Double {
        val fx = x / S - 0.5; val fy = y / S - 0.5
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var v = fy - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        fun at(tx: Int, ty: Int): Double {
            val t = if (map.inside(tx, ty)) map.tile(tx, ty) else map.tile(tx.coerceIn(0, map.width - 1), ty.coerceIn(0, map.height - 1))
            return if (test(t)) 1.0 else 0.0
        }
        return (at(ix, iy) * (1 - u) + at(ix + 1, iy) * u) * (1 - v) + (at(ix, iy + 1) * (1 - u) + at(ix + 1, iy + 1) * u) * v
    }

    private val tallTiles: (Tile) -> Boolean = { it == Tile.TALL_GRASS || it == Tile.LOG || it == Tile.CHEST }
    private val waterTiles: (Tile) -> Boolean = { it == Tile.WATER }
    private val treeTiles: (Tile) -> Boolean = { it == Tile.TREE }
    private val flowerTiles: (Tile) -> Boolean = { it == Tile.FLOWERS }

    private fun tallAt(map: MapDef, x: Double, y: Double) =
        field(map, x, y, tallTiles) + (fbm(x, y, 40.0, 4) - 0.5) * 0.9 + (vnoise(x, y, 10.0, 5) - 0.5) * 0.35 > 0.55

    private fun waterAt(map: MapDef, x: Double, y: Double) = field(map, x, y, waterTiles) + (fbm(x, y, 48.0, 11) - 0.5) * 0.55

    // ------------------------------------------------------------------ the path

    /** The path as curves in art pixels: one point per row in the middle of the trodden strip. */
    private val curveCache = HashMap<String, List<DoubleArray>>()

    private fun curves(map: MapDef): List<DoubleArray> = synchronized(curveCache) {
        curveCache.getOrPut(map.id) {
            fun isPath(x: Int, y: Int) = map.inside(x, y) && (map.tile(x, y) == Tile.PATH || map.tile(x, y) == Tile.CAVE_ENTRANCE)
            fun cx(tx: Double) = (tx + 0.5) * S
            fun cy(ty: Int) = (ty + 0.5) * S
            val chains = mutableListOf<MutableList<Pair<Double, Double>>>()
            var open = listOf<Pair<MutableList<Pair<Double, Double>>, IntRange>>()
            for (y in 0 until map.height) {
                val runs = mutableListOf<IntRange>()
                var x = 0
                while (x < map.width) { if (isPath(x, y)) { val a = x; while (x < map.width && isPath(x, y)) x++; runs += a until x } else x++ }
                val next = mutableListOf<Pair<MutableList<Pair<Double, Double>>, IntRange>>()
                for (r in runs) {
                    if (r.count() >= 4) {
                        // a way off to the side: from its inner end to the edge of the map and beyond
                        val left = r.first == 0; val right = r.last == map.width - 1
                        val a = if (left) -1.5 else r.first.toDouble(); val b = if (right) map.width + 0.5 else r.last.toDouble()
                        chains += mutableListOf(cx(a) to cy(y), cx((a + b) / 2) to cy(y) + S * 0.08, cx(b) to cy(y))
                        continue
                    }
                    val mid = (cx(r.first.toDouble()) + cx(r.last.toDouble())) / 2 to cy(y)
                    val prev = open.firstOrNull { (_, pr) -> r.first <= pr.last + 1 && r.last >= pr.first - 1 }
                    val chain = prev?.first ?: mutableListOf<Pair<Double, Double>>().also { chains += it }
                    // a path running off the top of the map goes on beyond it
                    if (chain.isEmpty() && y == 0) chain += mid.first to -S.toDouble()
                    chain += mid
                    next += chain to r
                }
                open = next
            }
            for (c in chains) if (c.size >= 2 && c.last().second >= cy(map.height - 1) - 1) c += c.last().first to (map.height + 1.0) * S
            chains.filter { it.size >= 2 }.map { c ->
                // a gentle average, so a staircase of tiles becomes a bend, then a smooth curve through it
                val sm = if (c.size < 4) c else c.indices.map { i ->
                    val a = c[maxOf(i - 1, 0)]; val b = c[minOf(i + 1, c.size - 1)]
                    (a.first + c[i].first * 2 + b.first) / 4 to c[i].second
                }
                catmull(sm)
            }
        }
    }

    /** Catmull-Rom through the points, sampled densely; returned as x0, y0, x1, y1, … */
    private fun catmull(p: List<Pair<Double, Double>>, n: Int = 10): DoubleArray {
        val out = ArrayList<Double>()
        for (i in 0 until p.size - 1) {
            val p0 = p[maxOf(i - 1, 0)]; val p1 = p[i]; val p2 = p[i + 1]; val p3 = p[minOf(i + 2, p.size - 1)]
            for (k in 0 until n) {
                val t = k / n.toDouble(); val t2 = t * t; val t3 = t2 * t
                fun c(a: Double, b: Double, cc: Double, d: Double) = 0.5 * (2 * b + (-a + cc) * t + (2 * a - 5 * b + 4 * cc - d) * t2 + (-a + 3 * b - 3 * cc + d) * t3)
                out += c(p0.first, p1.first, p2.first, p3.first); out += c(p0.second, p1.second, p2.second, p3.second)
            }
        }
        out += p.last().first; out += p.last().second
        return out.toDoubleArray()
    }

    private fun segDist(px: Double, py: Double, ax: Double, ay: Double, bx: Double, by: Double): Double {
        val dx = bx - ax; val dy = by - ay
        val l2 = dx * dx + dy * dy
        val t = if (l2 == 0.0) 0.0 else (((px - ax) * dx + (py - ay) * dy) / l2).coerceIn(0.0, 1.0)
        val qx = ax + dx * t - px; val qy = ay + dy * t - py
        return sqrt(qx * qx + qy * qy)
    }

    // ------------------------------------------------------------------ drawing a chunk

    private fun draw(map: MapDef, cx: Int, cy: Int): PixelImage {
        val size = CH * S
        val ox = cx * size; val oy = cy * size
        val img = PixelImage(size, size)
        // the parts of the path near this chunk
        val margin = 80.0
        val segs = ArrayList<DoubleArray>()
        for (c in curves(map)) {
            var i = 0
            while (i + 3 < c.size) {
                val ax = c[i]; val ay = c[i + 1]; val bx = c[i + 2]; val by = c[i + 3]
                if (maxOf(ax, bx) >= ox - margin && minOf(ax, bx) <= ox + size + margin && maxOf(ay, by) >= oy - margin && minOf(ay, by) <= oy + size + margin)
                    segs += doubleArrayOf(ax, ay, bx, by)
                i += 2
            }
        }
        val col = DoubleArray(3); val tmp = DoubleArray(3)
        val tall = BooleanArray(size * size)
        val pathK = DoubleArray(size * size)
        for (yy in 0 until size) for (xx in 0 until size) {
            val x = (ox + xx).toDouble(); val y = (oy + yy).toDouble()
            // forest floor: moss, bare earth and old leaves
            val n1 = fbm(x, y, 96.0, 1); val n2 = fbm(x, y, 24.0, 2); val n3 = vnoise(x, y, 4.0, 3) * 0.6 + vnoise(x, y, 9.0, 33) * 0.4
            lerp(MOSS_D, MOSS_L, n2 * 0.9 + n3 * 0.35 - 0.1, col)
            val earthy = ((n1 - 0.55) * 4).coerceIn(0.0, 1.0)
            lerp(EARTH_D, EARTH_L, n3, tmp)
            for (i in 0..2) col[i] += (tmp[i] - col[i]) * earthy * 0.7
            if (n3 > 0.68 && n2 > 0.45) mixInto(col, LITTER, 0.55)
            // darker under the edge of the wood
            val trees = field(map, x, y, treeTiles)
            for (i in 0..2) col[i] *= 1 - trees * 0.35
            // tall grass: a dark, dense ground; the blades come afterwards
            if (tallAt(map, x, y)) {
                mixInto(col, TALL_D, 0.45)
                tall[yy * size + xx] = true
            }
            // the path: a broad cart track about a tile wide, a trampled verge of flattened grass
            // beside it, lighter where feet go in the middle, two ruts with puddles here and there
            if (segs.isNotEmpty()) {
                var d = Double.MAX_VALUE
                for (s in segs) { val dd = segDist(x, y, s[0], s[1], s[2], s[3]); if (dd < d) d = dd }
                val edge = 33 + (fbm(x, y, 26.0, 9) - 0.5) * 18
                val verge = ((edge + 9 - d) / 9).coerceIn(0.0, 1.0)
                if (verge > 0) { mixInto(col, VERGE, verge * 0.45) }
                val p = ((edge - d) / 6).coerceIn(0.0, 1.0)
                if (p > 0) {
                    lerp(PATH_D, PATH_L, n3 * 0.8 + n2 * 0.3, tmp)
                    // the middle, between the ruts, is trodden lighter; the ruts are deep and dark
                    val mid = (1 - d / 10).coerceIn(0.0, 1.0)
                    for (i in 0..2) tmp[i] += (PATH_HI[i] - tmp[i]) * mid * 0.35
                    val rut = abs(d - 14) < 2.4 + (vnoise(x, y, 14.0, 19) - 0.5) * 1.6
                    if (rut) {
                        if (vnoise(x, y, 30.0, 20) > 0.72) { for (i in 0..2) tmp[i] = PUDDLE[i].toDouble(); if (vnoise(x, y, 3.0, 21) > 0.8) for (i in 0..2) tmp[i] += (GLINT[i] - tmp[i]) * 0.4 }
                        else for (i in 0..2) tmp[i] += (RUT[i] - tmp[i]) * 0.6
                    }
                    for (i in 0..2) col[i] += (tmp[i] - col[i]) * p
                    if (p < 0.85 && n3 > 0.5) mixInto(col, CREEP, 0.6)
                    pathK[yy * size + xx] = p
                }
            }
            // water: grey-green at the rim, black where it is deep, thin glints of the sky
            val w = waterAt(map, x, y)
            if (w > 0.5) {
                lerp(WATER_S, WATER_D, (w - 0.5) * 3.2, col)
                if (abs(kotlin.math.sin(y * 0.35 + fbm(x, y, 30.0, 12) * 6)) > 0.985 && vnoise(x, y, 16.0, 13) > 0.55) mixInto(col, GLINT, 0.45)
                tall[yy * size + xx] = false
                pathK[yy * size + xx] = 1.0
            } else if (w > 0.36) mixInto(col, MUD, 0.7)
            img.pixels[yy * size + xx] = (0xFF shl 24) or (col[0].toInt().coerceIn(0, 255) shl 16) or (col[1].toInt().coerceIn(0, 255) shl 8) or col[2].toInt().coerceIn(0, 255)
        }
        // blades, tufts, flowers and pebbles, from every tile near the chunk so they cross its edges
        val pen = Pen(img)
        val tx0 = cx * CH - 1; val ty0 = cy * CH - 1
        for (ty in ty0..ty0 + CH + 1) for (tx in tx0..tx0 + CH + 1) {
            val t = if (map.inside(tx, ty)) map.tile(tx, ty) else Tile.TREE
            // short grass all over the open ground
            for (k in 0 until 26) {
                val bx = tx * S + rnd(tx, ty, k * 3 + 1) * S - ox; val by = ty * S + rnd(tx, ty, k * 3 + 2) * S - oy
                val ix = bx.toInt(); val iy = by.toInt()
                if (ix !in 0 until size || iy !in 0 until size || tall[iy * size + ix] || pathK[iy * size + ix] > 0.4) continue
                val light = rnd(tx, ty, k * 3 + 3) < 0.5
                val len = 3 + hash(tx, ty, k + 90) % 4
                blade(img, ix, iy, len, (hash(tx, ty, k + 91) % 3) - 1, if (light) 0x60703E else 0x1A2214, 0.6)
            }
            if (t == Tile.TALL_GRASS || t == Tile.LOG || t == Tile.CHEST) for (k in 0 until 110) {
                val bx = tx * S + rnd(tx, ty, k * 5 + 7) * S - ox; val by = ty * S + rnd(tx, ty, k * 5 + 8) * S - oy
                val ix = bx.toInt(); val iy = by.toInt()
                if (ix !in 0 until size || iy !in 0 until size || !tall[iy * size + ix]) continue
                val b = rnd(tx, ty, k * 5 + 9)
                val c = (0..2).map { (TALL_BLADE_D[it] + (TALL_BLADE_L[it] - TALL_BLADE_D[it]) * b).toInt() }
                val len = 7 + hash(tx, ty, k + 300) % 9
                val lean = 2 + hash(tx, ty, k + 301) % 3
                blade(img, ix, iy, len, lean, (c[0] shl 16) or (c[1] shl 8) or c[2], 1.0)
            }
            if (t == Tile.FLOWERS) for (k in 0 until 20) {
                val ix = (tx * S + rnd(tx, ty, k * 7 + 40) * S - ox).toInt(); val iy = (ty * S + rnd(tx, ty, k * 7 + 41) * S - oy).toInt()
                if (ix !in 1 until size - 1 || iy !in 1 until size - 1) continue
                if (field(map, (ox + ix).toDouble(), (oy + iy).toDouble(), flowerTiles) + (vnoise((ox + ix).toDouble(), (oy + iy).toDouble(), 20.0, 6) - 0.5) * 0.7 < 0.5) continue
                val c = argb(listOf(0xB8A8C0, 0x9A5A50, 0xC8B88A)[k % 3])
                pen.raw(ix, iy, c); pen.raw(ix + 1, iy, c); pen.raw(ix, iy + 1, c); pen.raw(ix + 1, iy + 1, mix(c, argb(0x101010), 0.4))
            }
            // stones on the path
            for (k in 0 until 18) {
                val ix = (tx * S + rnd(tx, ty, k * 9 + 60) * S - ox).toInt(); val iy = (ty * S + rnd(tx, ty, k * 9 + 61) * S - oy).toInt()
                if (ix !in 0 until size - 3 || iy !in 0 until size - 3 || pathK[iy * size + ix] < 0.6 || pathK[iy * size + ix] >= 1.0) continue
                val r = 1 + hash(tx, ty, k + 70) % 2
                val c = if (rnd(tx, ty, k + 71) < 0.6) argb(0x8A7C6A) else argb(0x5A5048)
                for (dy in 0..r) for (dx in 0..r + 1) pen.raw(ix + dx, iy + dy, if (dy == r) mix(c, argb(0x201810), 0.5) else c)
            }
        }
        return img
    }

    /** A blade of grass from its foot ([x], [y]) up, leaning [lean] pixels to the side. */
    private fun blade(img: PixelImage, x: Int, y: Int, len: Int, lean: Int, rgb: Int, alpha: Double) {
        for (i in 0 until len) {
            val px = x + (lean * i) / len; val py = y - i
            if (px !in 0 until img.width || py !in 0 until img.height) continue
            val old = img.pixels[py * img.width + px]
            img.pixels[py * img.width + px] = if (alpha >= 1.0) argb(rgb) else mix(old, argb(rgb), alpha)
        }
    }
}
