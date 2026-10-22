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
 * ([prepare]); until a chunk is ready, the map stays dark there. Every tile of every map is drawn by it
 * or by the pictures standing on it ([keepsOldTile] tells a tile that would be missing).
 */
object MapGround {
    /** Art pixels per map pixel. */
    const val D = 2

    /** Art pixels per tile. */
    const val S = WorldArt.T * D

    /** Tiles per chunk side. */
    const val CH = 4

    /*
     * 27.5 (27g ja): the water lies a little below the grass. Where the bank faces the camera (land behind the water, towards
     * −x and −y) its earthen step shows, with roots and the bank's shadow on the water; under the near bank the water is
     * darker. Drawn for the diagonal view.
     */
    private val BANK_L = intArrayOf(0x76, 0x5E, 0x40); private val BANK_D = intArrayOf(0x26, 0x1E, 0x14); private val ROOT = intArrayOf(0x18, 0x12, 0x0C)

    /** 27l (user 14.10.): puddles in the ruts are few, soft and earthen, not hard blue-black dashes. */
    private val PUDDLE_SOFT = rgb(0x2C2A24)

    /** Tiles drawn by this ground; anything else keeps its old picture on top. */
    private val drawn = setOf(
        Tile.GRASS, Tile.TALL_GRASS, Tile.FLOWERS, Tile.PATH, Tile.TREE, Tile.WATER,
        Tile.ROCK, Tile.LOG, Tile.MENHIR, Tile.SIGN, Tile.NOTICE, Tile.CHEST, Tile.CAMPFIRE,
        // the rock face about the cave mouth in the woods ([MapWoodIso] cliff, 1b)
        Tile.CAVE_WALL, Tile.CAVE_ENTRANCE,
        // a lone hut in the woods (D3.13, Morwen's): the house's strips stand on the ground drawn under it
        Tile.ROOF, Tile.WALL, Tile.WINDOW, Tile.DOOR,
    )

    /** Tiles drawn by the cave's ground ([MapCave]); only inside the cave (09.10., 23:04: the cliff about the cave mouth in the woods is still the former one). */
    private val caveDrawn = setOf(
        Tile.CAVE_WALL, Tile.CAVE_FLOOR, Tile.CAVE_EXIT, Tile.RUBBLE, Tile.BONES, Tile.GLOWSHROOM, Tile.CRYSTAL,
        Tile.STALAGMITE, Tile.CRATE, Tile.BEDROLL, Tile.SUPPORT, Tile.SKYLIGHT, Tile.TORCH, Tile.GATE,
    )

    /** Tiles the village draft draws: its own ground, and the houses and things of [MapTown]. */
    val townDrawn = mutableSetOf(Tile.COBBLE, Tile.BRIDGE, Tile.ROOF, Tile.ROOF_BLUE, Tile.WALL, Tile.WINDOW, Tile.DOOR,
        Tile.BARREL, Tile.LAMP, Tile.STALL, Tile.WELL, Tile.BENCH, Tile.HAY, Tile.BARRIER, Tile.FENCE, Tile.CROPS, Tile.VEG_BED, Tile.WASHLINE, Tile.YARD)

    /** Whether nothing would draw [tile] on [map]: the former straight pictures are gone (13t), so this stays false on every map (MapGroundOldTileTest). */
    fun keepsOldTile(map: MapDef, tile: Tile) = map.kind != MapKind.INTERIOR && tile !in drawn && (map.kind != MapKind.CAVE || tile !in caveDrawn) &&
        (map.kind != MapKind.TOWN || tile !in townDrawn)

    private val chunks = HashMap<String, PixelImage>()
    private val preparing = HashSet<String>()

    /** The chunk ([cx], [cy]) of [map], or null while it is not drawn yet. */
    fun chunk(map: MapDef, cx: Int, cy: Int): PixelImage? = synchronized(chunks) { chunks["${map.id}/$cx/$cy"] }

    /** Whether the ground around ([x], [y]) on [map] is drawn: the hero's chunk and those [reach] chunks about it (24.1). */
    fun readyNear(map: MapDef, x: Int, y: Int, reach: Int = 1): Boolean {
        val w = (map.width + CH - 1) / CH; val h = (map.height + CH - 1) / CH
        val hx = Math.floorDiv(x, CH); val hy = Math.floorDiv(y, CH)
        for (cy in maxOf(0, hy - reach)..minOf(h - 1, hy + reach)) for (cx in maxOf(0, hx - reach)..minOf(w - 1, hx + reach))
            if (chunk(map, cx, cy) == null) return false
        return true
    }

    /**
     * 267.2 (Chef 22.10.: "im Tiefenwald ... eher ruckelig ... dass die wichtigen Dinge erstmal vorgezeichnet sind"): how
     * far about the hero the black screen waits for the ground. In the woods all of it: drawn behind the screen, nothing
     * of the ground is left to draw while he walks (21.10. on the tablet 20 of 22 slow pictures came with the ground).
     */
    fun veilReach(map: MapDef): Int = if (map.kind == de.bornim.core.MapKind.FOREST) maxOf(map.width, map.height) / CH + 1 else 1

    /** 267.1: of the chunks [readyNear] waits for, how many are drawn and how many in all. */
    fun partsNear(map: MapDef, x: Int, y: Int, reach: Int = 1): Pair<Int, Int> {
        val w = (map.width + CH - 1) / CH; val h = (map.height + CH - 1) / CH
        val hx = Math.floorDiv(x, CH); val hy = Math.floorDiv(y, CH)
        var done = 0; var all = 0
        for (cy in maxOf(0, hy - reach)..minOf(h - 1, hy + reach)) for (cx in maxOf(0, hx - reach)..minOf(w - 1, hx + reach)) {
            all++
            if (chunk(map, cx, cy) != null) done++
        }
        return done to all
    }

    /** The chunk ([cx], [cy]) of [map], drawn right away when it is not ready yet (a brief pause, once), so the former tiles never show. */
    fun chunkNow(map: MapDef, cx: Int, cy: Int): PixelImage? {
        val r = if (MapEdge.applies(map)) 1 else 0
        if (cx < -r || cy < -r || cx * CH >= map.width + r * CH || cy * CH >= map.height + r * CH) return null
        chunk(map, cx, cy)?.let { return it }
        val img = draw(map, cx, cy)
        synchronized(chunks) { chunks.getOrPut("${map.id}/$cx/$cy") { img } }
        return chunk(map, cx, cy)
    }

    /** Draws all chunks of [map] in the background, nearest to ([nearX], [nearY]) first (tiles). */
    fun prepare(map: MapDef, nearX: Int = 0, nearY: Int = 0) {
        synchronized(preparing) {
            // 30.2: only this map's ground and the one before are kept, the others drawn again when visited
            recent.remove(map.id); recent.addLast(map.id)
            while (recent.size > KEEP_MAPS) forget(recent.removeFirst())
            if (!preparing.add(map.id)) return
        }
        // on several cores at once, nearest first (23:04: so the ground is there almost as soon as the map shows)
        for ((cx, cy) in order(map, nearX, nearY)) {
            queued.incrementAndGet()
            workers.execute {
                try {
                    val k = "${map.id}/$cx/$cy"
                    if (synchronized(chunks) { k in chunks }) return@execute
                    de.bornim.core.Guard.run("Boden ${map.id}") {
                        val img = DrawBusy.during(DrawBusy.Kind.GROUND) { draw(map, cx, cy) }
                        synchronized(preparing) { if (map.id in preparing) synchronized(chunks) { chunks.getOrPut(k) { img } } }
                    }
                } finally { queued.decrementAndGet() }
            }
        }
    }

    private val queued = java.util.concurrent.atomic.AtomicInteger()

    /** t65.6: whether ground is still being drawn in the background, so the fight drawn ahead waits for it. */
    fun drawing() = queued.get() > 0

    /** How many maps keep their ground drawn (30.2). */
    const val KEEP_MAPS = 2
    private val recent = ArrayDeque<String>()

    /** Lets go of the ground of [mapId]. Under [preparing]'s lock. */
    private fun forget(mapId: String) {
        preparing.remove(mapId)
        synchronized(chunks) { chunks.keys.removeAll { it.startsWith("$mapId/") } }
    }

    /** 30.2: memory short: only the map shown last keeps its ground. */
    fun trim() = synchronized(preparing) { while (recent.size > 1) forget(recent.removeFirst()) }

    private val workers = java.util.concurrent.Executors.newFixedThreadPool(
        (Runtime.getRuntime().availableProcessors() - 1).coerceIn(2, 4),
    ) { r -> Thread(r, "map-ground").also { it.isDaemon = true; it.priority = Thread.NORM_PRIORITY - 1 } }

    /** Draws all chunks of [map] right away (for previews and tests). */
    fun prepareNow(map: MapDef) {
        for ((cx, cy) in order(map, 0, 0)) {
            val k = "${map.id}/$cx/$cy"
            if (synchronized(chunks) { k in chunks }) continue
            val img = draw(map, cx, cy)
            synchronized(chunks) { chunks[k] = img }
        }
    }

    private fun order(map: MapDef, nx: Int, ny: Int): List<Pair<Int, Int>> {
        val w = (map.width + CH - 1) / CH; val h = (map.height + CH - 1) / CH
        val r = if (MapEdge.applies(map)) 1 else 0
        val all = (-r until h + r).flatMap { y -> (-r until w + r).map { x -> x to y } }
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
    private val PATH_D = rgb(0x4E3E2C); private val PATH_L = rgb(0x806A4C); private val PATH_HI = rgb(0x948062); private val VERGE = rgb(0x4A4630); private val RUT = rgb(0x2E241A); private val CREEP = rgb(0x3A4A26)
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
    private val cobbleTiles: (Tile) -> Boolean = { it == Tile.COBBLE || it == Tile.STALL || it == Tile.WELL || it == Tile.LAMP || it == Tile.BENCH }
    private val yardTiles: (Tile) -> Boolean = { it == Tile.ROOF || it == Tile.ROOF_BLUE || it == Tile.WALL || it == Tile.WINDOW || it == Tile.DOOR || it == Tile.BARREL || it == Tile.HAY || it == Tile.CROPS || it == Tile.VEG_BED || it == Tile.YARD }
    private val COBBLE_D = rgb(0x3E3A34); private val COBBLE_L = rgb(0x7A7262); private val MORTAR = rgb(0x26221C)
    private val PLANK_D = rgb(0x3A2A1E); private val PLANK_L = rgb(0x6A5038)

    private val COBBLE_WARM = rgb(0x8A7254); private val COBBLE_COOL = rgb(0x5E6066); private val JOINT = rgb(0x2E261C)

    /**
     * The village's cobbles (5.4, the middle way the user chose 12.10., 18:4x): the joints dark earth, not black; each
     * stone leaning a little warm (ochre, brown) or cool (grey), lighter on top; a slow wash of worn lanes; moss in the
     * joints here and there, now and then a stone gone. [into] gets the colour, the result whether there is a stone.
     */
    private fun cobble(x: Double, y: Double, into: DoubleArray): Boolean {
        val cell = 6.2
        val gx = floor(x / cell).toInt(); val gy = floor(y / cell).toInt()
        var d1 = 99.0; var d2 = 99.0; var id = 0
        for (dy in -1..1) for (dx in -1..1) {
            val cx = gx + dx; val cy = gy + dy
            val px = (cx + 0.2 + rnd(cx, cy, 61) * 0.6) * cell; val py = (cy + 0.2 + rnd(cx, cy, 62) * 0.6) * cell
            val d = sqrt((x - px) * (x - px) + (y - py) * (y - py) * 1.3)
            if (d < d1) { d2 = d1; d1 = d; id = hash(cx, cy, 63) } else if (d < d2) d2 = d
        }
        if (d2 - d1 < 1.0 || id % 37 == 0) {
            val moss = vnoise(x, y, 11.0, 67) > 0.6
            for (i in 0..2) into[i] = (if (moss) MOSS_D[i] * 0.8 + JOINT[i] * 0.2 else JOINT[i].toDouble())
            return false
        }
        val wash = (fbm(x, y, 60.0, 68) - 0.5) * 0.4
        val t = 0.3 + (id % 100) / 330.0 + (1 - d1 / cell) * 0.3 + wash + (vnoise(x, y, 3.0, 64) - 0.5) * 0.12
        lerp(COBBLE_D, COBBLE_L, t, into)
        // each stone its own hue: some warm, some cool, most in between
        val hue = ((id / 100) % 100) / 100.0
        val tint = if (hue < 0.5) COBBLE_WARM else COBBLE_COOL
        val k = abs(hue - 0.5) * 0.7
        for (i in 0..2) into[i] = into[i] * (1 - k) + tint[i] * into[i] / 110.0 * k
        return true
    }

    private fun tallAt(map: MapDef, x: Double, y: Double) =
        field(map, x, y, tallTiles) + (fbm(x, y, 40.0, 4) - 0.5) * 0.9 + (vnoise(x, y, 10.0, 5) - 0.5) * 0.35 > 0.55

    /** How much water lies at map pixel ([x], [y]): above 0.5 is the pond (the same shore the ground is drawn with). */
    fun water(map: MapDef, x: Float, y: Float): Double = waterAt(map, x * D.toDouble(), y * D.toDouble())

    private fun waterAt(map: MapDef, x: Double, y: Double) = field(map, x, y, waterTiles) + (fbm(x, y, 48.0, 11) - 0.5) * 0.55

    // ------------------------------------------------------------------ the path

    /**
     * The path as a network of short pieces in art pixels, made from the path tiles: narrow
     * stretches (up to three tiles across a row) become one point in their middle, long runs
     * across a row one point per tile; points whose tiles touch are joined. Then every point that
     * just continues the way (two neighbours) is moved towards the middle of its neighbours a few
     * times, so a staircase of tiles becomes a bend, while crossings and ends stay where they are.
     * Ends at the edge of the map go on beyond it; other ends fade out. Each piece is
     * ax, ay, bx, by, a-is-a-dead-end, b-is-a-dead-end.
     */
    private val pathCache = HashMap<String, List<DoubleArray>>()

    private fun pathPieces(map: MapDef): List<DoubleArray> = synchronized(pathCache) {
        pathCache.getOrPut(map.id) {
            fun isPath(x: Int, y: Int) = map.inside(x, y) && (map.tile(x, y) == Tile.PATH || map.tile(x, y) == Tile.CAVE_ENTRANCE)
            // nodes: position and the tiles they stand for
            val px = ArrayList<Double>(); val py = ArrayList<Double>(); val tiles = ArrayList<IntRange>(); val rows = ArrayList<Int>()
            val nodeAt = HashMap<Long, Int>()
            fun key(x: Int, y: Int) = x.toLong() * 100000 + y
            for (y in 0 until map.height) {
                var x = 0
                while (x < map.width) {
                    if (!isPath(x, y)) { x++; continue }
                    val a = x; while (x < map.width && isPath(x, y)) x++
                    val run = a until x
                    val parts = if (run.count() <= 3) listOf(run) else run.map { it..it }
                    for (r in parts) {
                        val i = px.size
                        px += (r.first + r.last + 1) / 2.0 * S; py += (y + 0.5) * S; tiles += r; rows += y
                        for (t in r) nodeAt[key(t, y)] = i
                    }
                }
            }
            // links between nodes whose tiles touch (also across a corner)
            val links = HashSet<Long>()
            val nb = Array(px.size) { ArrayList<Int>() }
            fun link(i: Int, j: Int) {
                if (i == j) return
                val k = minOf(i, j).toLong() * 1_000_000 + maxOf(i, j)
                if (links.add(k)) { nb[i] += j; nb[j] += i }
            }
            for (i in px.indices) for (t in tiles[i]) for (dy in -1..1) for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                val j = nodeAt[key(t + dx, rows[i] + dy)] ?: continue
                // a corner link only where the two are not already joined straight
                if (dx != 0 && dy != 0 && (nodeAt[key(t + dx, rows[i])] != null || nodeAt[key(t, rows[i] + dy)] != null)) continue
                link(i, j)
            }
            // smoothing: points that only continue the way move towards their neighbours
            repeat(4) {
                val nx = px.toDoubleArray(); val ny = py.toDoubleArray()
                for (i in px.indices) if (nb[i].size == 2) {
                    val (a, b) = nb[i]
                    nx[i] = px[i] * 0.5 + (px[a] + px[b]) * 0.25
                    ny[i] = py[i] * 0.5 + (py[a] + py[b]) * 0.25
                }
                for (i in px.indices) { px[i] = nx[i]; py[i] = ny[i] }
            }
            val out = ArrayList<DoubleArray>()
            fun deadEnd(i: Int) = nb[i].size <= 1
            for (k in links) {
                val i = (k / 1_000_000).toInt(); val j = (k % 1_000_000).toInt()
                out += doubleArrayOf(px[i], py[i], px[j], py[j], if (deadEnd(i)) 1.0 else 0.0, if (deadEnd(j)) 1.0 else 0.0)
            }
            // ends at the edge of the map run on beyond it
            for (i in px.indices) if (deadEnd(i)) {
                val r = tiles[i]; val y = rows[i]
                val ex = when { r.first == 0 -> -1.5 * S; r.last == map.width - 1 -> (map.width + 1.5) * S; else -> null }
                val ey = when { y == 0 -> -1.5 * S; y == map.height - 1 -> (map.height + 1.5) * S; else -> null }
                if (ex != null || ey != null) out += doubleArrayOf(px[i], py[i], ex ?: px[i], ey ?: py[i], 0.0, 0.0)
                // a lone point (a path of one tile) still shows as a small patch
                if (nb[i].isEmpty() && ex == null && ey == null) out += doubleArrayOf(px[i], py[i], px[i], py[i], 1.0, 1.0)
            }
            out
        }
    }

    /** Distance to the piece from a to b; where along it the nearest point lies (0 start, 1 end) goes into [where]. */
    private fun segDist(px: Double, py: Double, ax: Double, ay: Double, bx: Double, by: Double, where: DoubleArray): Double {
        val dx = bx - ax; val dy = by - ay
        val l2 = dx * dx + dy * dy
        val t = if (l2 == 0.0) 0.0 else (((px - ax) * dx + (py - ay) * dy) / l2).coerceIn(0.0, 1.0)
        where[0] = t
        val qx = ax + dx * t - px; val qy = ay + dy * t - py
        return sqrt(qx * qx + qy * qy)
    }

    // ------------------------------------------------------------------ drawing a chunk

    private fun draw(map: MapDef, cx: Int, cy: Int): PixelImage {
        if (map.kind == MapKind.CAVE) return MapCave.ground(map, cx, cy)
        if (map.kind == MapKind.INTERIOR) return MapRoom.ground(map, cx, cy)
        val size = CH * S
        val ox = cx * size; val oy = cy * size
        val img = PixelImage(size, size)
        // the parts of the path near this chunk
        val margin = 80.0
        val segs = ArrayList<DoubleArray>()
        for (s in pathPieces(map)) {
            val ax = s[0]; val ay = s[1]; val bx = s[2]; val by = s[3]
            if (maxOf(ax, bx) >= ox - margin && minOf(ax, bx) <= ox + size + margin && maxOf(ay, by) >= oy - margin && minOf(ay, by) <= oy + size + margin) segs += s
        }
        val col = DoubleArray(3); val tmp = DoubleArray(3); val where = DoubleArray(1)
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
                var d = Double.MAX_VALUE; var cap = false; var near: DoubleArray? = null
                for (s in segs) {
                    val dd = segDist(x, y, s[0], s[1], s[2], s[3], where)
                    if (dd < d) { d = dd; near = s; cap = (s[4] > 0 && where[0] <= 0.0) || (s[5] > 0 && where[0] >= 1.0) }
                }
                // at crossings and where the way is wider than one track, no ruts: they would run in rings
                var other = Double.MAX_VALUE
                val n0 = near
                if (n0 != null) for (s in segs) {
                    if (s === n0) continue
                    val touches = (s[0] == n0[0] && s[1] == n0[1]) || (s[0] == n0[2] && s[1] == n0[3]) || (s[2] == n0[0] && s[3] == n0[1]) || (s[2] == n0[2] && s[3] == n0[3])
                    if (touches) {
                        // a piece that continues this one only counts if it bends away sharply
                        val ax = n0[2] - n0[0]; val ay = n0[3] - n0[1]; val bx = s[2] - s[0]; val by = s[3] - s[1]
                        val la = sqrt(ax * ax + ay * ay); val lb = sqrt(bx * bx + by * by)
                        if (la == 0.0 || lb == 0.0 || abs(ax * bx + ay * by) / (la * lb) > 0.5) continue
                    }
                    val dd = segDist(x, y, s[0], s[1], s[2], s[3], where)
                    if (dd < other) other = dd
                }
                // past the end of the path: the track narrows and fades into the grass
                if (cap) d *= 1.6
                val edge = 33 + (fbm(x, y, 26.0, 9) - 0.5) * 18
                val verge = ((edge + 9 - d) / 9).coerceIn(0.0, 1.0)
                if (verge > 0) { mixInto(col, VERGE, verge * 0.45) }
                val p = ((edge - d) / 6).coerceIn(0.0, 1.0)
                if (p > 0) {
                    lerp(PATH_D, PATH_L, n3 * 0.8 + n2 * 0.3, tmp)
                    // the middle, between the ruts, is trodden lighter; the ruts are deep and dark
                    val mid = (1 - d / 10).coerceIn(0.0, 1.0)
                    for (i in 0..2) tmp[i] += (PATH_HI[i] - tmp[i]) * mid * 0.35
                    // 5.5 (test 00:40: hard dark strokes ruled along the tracks): each rut wanders a little, its edges
                    // soft, deeper here and shallower there, almost gone in places, as wheels press it into the earth
                    val off = abs(d - 14 - (vnoise(x, y, 46.0, 23) - 0.5) * 3.0)
                    val half = 2.8 + (vnoise(x, y, 14.0, 19) - 0.5) * 1.6
                    val r = (1 - off / half).coerceIn(0.0, 1.0)
                    if (!cap && other > 46 && r > 0) {
                        val k = r * r * (3 - 2 * r) * (0.2 + 0.55 * fbm(x, y, 36.0, 24))
                        for (i in 0..2) tmp[i] += (RUT[i] - tmp[i]) * k
                        val wet = vnoise(x, y, 30.0, 20)
                        if (wet > 0.78) {
                            // a shallow puddle: the rut's earth darkened toward its middle, a faint sheen, no hard edge
                            val q = ((wet - 0.78) / 0.1).coerceIn(0.0, 1.0) * (1 - off / 3.2).coerceIn(0.0, 1.0)
                            for (i in 0..2) tmp[i] += (PUDDLE_SOFT[i] - tmp[i]) * q * 0.7
                            if (vnoise(x, y, 3.0, 21) > 0.86) for (i in 0..2) tmp[i] += (GLINT[i] - tmp[i]) * 0.15 * q
                        }
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
                // D6.3: the bank in the village as in the woods
                if (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) {
                    val gx = waterAt(map, x + 3, y) - waterAt(map, x - 3, y); val gy = waterAt(map, x, y + 3) - waterAt(map, x, y - 3)
                    val gl = sqrt(gx * gx + gy * gy)
                    if (gl > 1e-4) {
                        // +1 where the water deepens towards the camera: the bank behind it faces us
                        val facing = ((gx + gy) / gl / sqrt(2.0)).coerceIn(-1.0, 1.0)
                        val band = 0.2 * facing.coerceAtLeast(0.0)
                        if (w < 0.5 + band) {
                            val f = (w - 0.5) / band
                            lerp(BANK_L, BANK_D, f * 0.75 + (vnoise(x, y, 5.0, 70) - 0.5) * 0.4, tmp)
                            if (vnoise(x * 3, y * 3, 9.0, 71) > 0.76) mixInto(tmp, ROOT, 0.7)
                            for (i in 0..2) col[i] = tmp[i]
                        } else if (facing > 0 && w < 0.5 + band + 0.06) mixInto(col, BANK_D, 0.45)
                        else if (facing < -0.3 && w < 0.56) mixInto(col, BANK_D, 0.3)
                    }
                }
                tall[yy * size + xx] = false
                pathK[yy * size + xx] = 1.0
            } else if (w > 0.36) mixInto(col, MUD, 0.7)
            if (map.kind == MapKind.TOWN) {
                // trodden earth about the houses and in the yards
                val yard = field(map, x, y, yardTiles) + (fbm(x, y, 22.0, 52) - 0.5) * 0.5
                if (yard > 0.45) { lerp(EARTH_D, PATH_D, n3, tmp); for (i in 0..2) col[i] += (tmp[i] - col[i]) * ((yard - 0.45) * 3).coerceIn(0.0, 0.85); tall[yy * size + xx] = false; pathK[yy * size + xx] = 1.0 }
                // the square: cobbles, their edge broken into the earth
                val cob = field(map, x, y, cobbleTiles) + (fbm(x, y, 18.0, 51) - 0.5) * 0.45
                if (cob > 0.5) {
                    if (cobble(x, y, tmp)) for (i in 0..2) col[i] = tmp[i] else for (i in 0..2) col[i] += (tmp[i] - col[i]) * 0.8
                    tall[yy * size + xx] = false; pathK[yy * size + xx] = 1.0
                }
                // the bridge: planks across the river, gaps between them, dark at the edges
                val tx = floor(x / S).toInt(); val ty = floor(y / S).toInt()
                if (map.tile(tx, ty) == Tile.BRIDGE) {
                    // D6.3: the planks counted over the whole bridge, each one board across its width, not again in every tile
                    val ly = y - floor(y / 8) * 8
                    val plank = floor(y / 8).toInt()
                    lerp(PLANK_D, PLANK_L, 0.35 + rnd(plank, 0, 65) * 0.4 + (vnoise(x * 0.2, y, 4.0, 66) - 0.5) * 0.3, tmp)
                    if (ly < 1.2) for (i in 0..2) tmp[i] = MORTAR[i] * 0.6
                    val lx = x - tx * S
                    val side = map.tile(tx - 1, ty) != Tile.BRIDGE && lx < 5 || map.tile(tx + 1, ty) != Tile.BRIDGE && lx > S - 5
                    if (side) for (i in 0..2) tmp[i] = PLANK_D[i] * 0.7
                    for (i in 0..2) col[i] = tmp[i]
                    tall[yy * size + xx] = false; pathK[yy * size + xx] = 1.0
                }
            }
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
