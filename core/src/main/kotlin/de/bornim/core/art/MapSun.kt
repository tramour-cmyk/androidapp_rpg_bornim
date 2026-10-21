package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Shadows with the time of day (89): on the maps under the open sky everything
 * that stands throws its shadow by one sun, cast from its shape and height: the houses (walls, eaves, ridge), the
 * trees (trunk and crown, dappled), wells, stalls, lamps, signs, the notice board, the barrier, fences, hay and the
 * washing lines, the benches, barrels and the rocks of the woods, the bridge's railing (D29.4), the things of a yard (D29.3). Three fixed stands of the sun, changed only at a cut (a change of map, the fade after a rest): in
 * the morning long to the west, at noon short towards the viewer (as before), in the evening long to the east.
 * Low things (bushes, ferns, beds, the corn, the small things of the forest floor) keep the small shadow in their own picture.
 *
 * The shadows are one soft layer on the ground of the whole map, [R] pixels a tile, cut into pieces of [CH] tiles,
 * drawn where [MapFlora.shadows] is (under everything that stands, faded by the time of day).
 */
object MapSun {
    /**
     * Where the sun stands: ([dx], [dy]) the way the shadows fall on the map (x east, y south), [len] how long a
     * shadow is for each tile of height.
     */
    enum class Stand(val dx: Double, val dy: Double, val len: Double) {
        /** the sun low in the east: long shadows to the west (up left on the screen) */
        MORNING(-1.0, -0.2, 1.2),
        /** the sun high: short shadows, falling down left towards the viewer as the houses' always did */
        NOON(0.15, 1.0, 0.35),
        /** the sun low in the west: long shadows to the east (down right) */
        EVENING(1.0, -0.2, 1.2);

        companion object {
            /**
             * The stand for the minute of the day [minutes]: after midnight already that of the morning to come, from
             * 15 o'clock that of the evening (D9.3; at night the moon follows with D3.14).
             */
            fun at(minutes: Int): Stand = when (Math.floorMod(minutes, 24 * 60) / 60) {
                in 0 until 10 -> MORNING
                in 10 until 15 -> NOON
                else -> EVENING
            }
        }
    }

    /** The stand the shadows show; set at a cut. */
    @Volatile var stand = Stand.NOON

    private const val R = 32            // layer pixels a tile (one to a world pixel)
    private const val CH = 8            // tiles a piece
    private const val G = 4             // shade samples a tile (89)
    private const val ALPHA = 0.46
    private const val SHADOW_RGB = 0x0A0806
    /** Upright drawing units a tile (as [MapTownIso]: 57 to the metre, a tile 116 cm). */
    private const val ZT = 66.0

    /**
     * A drawn layer and when it was done ([System.nanoTime]), so it can fade in; with [shade], how dark the ground lies
     * in shadow, [G] samples a tile, each the mean of its pixels (89: the people standing in it darken with it).
     */
    class Ready(val pieces: List<WorldArt.Obj>, val at: Long, private val shade: ByteArray = ByteArray(0), private val sw: Int = 0) {
        private val sh = if (sw == 0) 0 else shade.size / sw

        /** How dark the shadow lies at ([x], [y]) in tiles, 0 in the sun, up to about half; smooth between the samples. */
        fun at(x: Double, y: Double): Float {
            if (sw == 0) return 0f
            val gx = (x * G - 0.5).coerceIn(0.0, sw - 1.0); val gy = (y * G - 0.5).coerceIn(0.0, sh - 1.0)
            val ix = min(gx.toInt(), sw - 2).coerceAtLeast(0); val iy = min(gy.toInt(), sh - 2).coerceAtLeast(0)
            val u = (gx - ix).coerceIn(0.0, 1.0); val v = (gy - iy).coerceIn(0.0, 1.0)
            fun s(i: Int, j: Int) = (shade[min(j, sh - 1) * sw + min(i, sw - 1)].toInt() and 0xFF) / 255.0
            val k = (s(ix, iy) * (1 - u) + s(ix + 1, iy) * u) * (1 - v) + (s(ix, iy + 1) * (1 - u) + s(ix + 1, iy + 1) * u) * v
            return k.toFloat()
        }
    }

    /** The layers drawn, the last used last; only [KEEP] are kept (30.2). */
    private val cache = LinkedHashMap<String, Ready>(8, 0.75f, true)
    private const val KEEP = 4
    private val drawing = HashSet<String>()

    private fun applies(map: MapDef) = map.kind == MapKind.FOREST || map.kind == MapKind.TOWN

    private fun build(map: MapDef, stand: Stand) = Layer(map, stand).also { it.cast(map) }.let { Ready(it.pieces(), System.nanoTime(), it.shade(), map.width * G) }

    private fun keep(key: String, drawn: Ready): Ready = synchronized(cache) {
        cache.getOrPut(key) { drawn }.also {
            while (cache.size > KEEP) cache.remove(cache.keys.first())
        }
    }

    /** The shadow layer of [map] for [stand], or nothing under a roof or underground; drawn now if need be (previews, tests). */
    fun shadows(map: MapDef, stand: Stand = this.stand): List<WorldArt.Obj> {
        if (!applies(map)) return emptyList()
        val key = "${map.id}/$stand"
        synchronized(cache) { cache[key] }?.let { return it.pieces }
        return keep(key, build(map, stand)).pieces
    }

    /** The layer of [map] for [stand] with its shade, drawn now if need be (previews, tests). */
    fun drawn(map: MapDef, stand: Stand = this.stand): Ready? {
        if (!applies(map)) return null
        shadows(map, stand)
        return synchronized(cache) { cache["${map.id}/$stand"] }
    }

    /**
     * D9.2: the layer of [map] for [stand] if it is drawn, else null and it is drawn in the background (in the Tiefer
     * Wald it takes over half a second, too long for one picture); the shadows come in a moment later, at a cut
     * usually still under the fade.
     */
    fun ready(map: MapDef, stand: Stand = this.stand): Ready? {
        if (!applies(map)) return null
        val key = "${map.id}/$stand"
        synchronized(cache) { cache[key] }?.let { return it }
        prepare(map, stand)
        return null
    }

    /**
     * 89: how bright a person standing with the feet at ([x], [y]) tiles is drawn, 1 in the sun: in the shadow of a
     * house or a crown as dark as the ground there, a little lighter (the open sky still lights an upright body).
     */
    fun bright(r: Ready, x: Double, y: Double): Float = 1f - 0.85f * r.at(x, y)

    /** Starts drawing the layer of [map] for [stand] in the background, if it is not there yet. */
    fun prepare(map: MapDef, stand: Stand = this.stand) {
        if (!applies(map)) return
        val key = "${map.id}/$stand"
        synchronized(cache) { if (key in cache || !drawing.add(key)) return }
        worker.execute {
            try {
                de.bornim.core.Guard.run("Schatten $key") { keep(key, DrawBusy.during(DrawBusy.Kind.SUN) { build(map, stand) }) }
            } finally {
                synchronized(cache) { drawing.remove(key) }
            }
        }
    }

    /** 30.2: memory short: only the layer used last is kept. */
    fun trim() = synchronized(cache) { while (cache.size > 1) cache.remove(cache.keys.first()) }

    private val worker = java.util.concurrent.Executors.newSingleThreadExecutor { r ->
        Thread(r, "map-sun").also { it.isDaemon = true; it.priority = Thread.NORM_PRIORITY - 1 }
    }

    /**
     * The shadow a person throws by the sun at [stand], lying on the ground (map pixels, [WorldArt.T] a tile, drawn
     * under the turned mapping): narrow at the feet, as wide as the shoulders further out, the head at the end.
     * ([fx], [fy]) is where the feet stand in [img].
     */
    class Figure(val img: PixelImage, val fx: Int, val fy: Int)

    private val figures = HashMap<Stand, Figure>()

    /** A person's shadow for [stand]; [Figure.img] faded with the day like the layer. */
    fun figure(stand: Stand = this.stand): Figure = synchronized(figures) {
        figures.getOrPut(stand) {
            val t = WorldArt.T.toDouble()
            val n = sqrt(stand.dx * stand.dx + stand.dy * stand.dy)
            val ux = stand.dx / n; val uy = stand.dy / n
            // a person of 1.70 m on tiles of 1.16 m; shoulders 0.45 m across, feet together about 0.25 m
            val len = stand.len * 1.47 * t
            val rFoot = 0.11 * t; val rBody = 0.19 * t; val rHead = 0.1 * t
            val pad = (rBody + 2).toInt()
            val ex = ux * len; val ey = uy * len
            val x0 = floor(min(0.0, ex)).toInt() - pad; val x1 = (max(0.0, ex)).toInt() + pad
            val y0 = floor(min(0.0, ey)).toInt() - pad; val y1 = (max(0.0, ey)).toInt() + pad
            val img = PixelImage(x1 - x0 + 1, y1 - y0 + 1)
            for (py in 0 until img.height) for (px in 0 until img.width) {
                val x = px + x0 + 0.5; val y = py + y0 + 0.5
                // along the shadow (0 at the feet, 1 at the top of the head) and across it
                val a = ((x * ux + y * uy) / len)
                val c = kotlin.math.abs(-x * uy + y * ux)
                val k = when {
                    a < 0 -> rFoot - sqrt(x * x + y * y)
                    // the legs widen to the hips, the body to the shoulders, then the neck narrows
                    a <= 0.82 -> (rFoot + (rBody - rFoot) * smooth(a / 0.7)) - c
                    else -> {
                        // the head: a round end over the neck
                        val hx = x - ux * len * 0.9; val hy = y - uy * len * 0.9
                        max(rHead - sqrt(hx * hx + hy * hy), (rBody * (1 - (a - 0.82) / 0.06).coerceAtLeast(0.0)) - c)
                    }
                }
                if (k <= 0) continue
                val alpha = ALPHA * smooth(k / 1.5)
                img.pixels[py * img.width + px] = ((alpha * 255).toInt().coerceIn(0, 255) shl 24) or SHADOW_RGB
            }
            Figure(img, -x0, -y0)
        }
    }

    /** The soft layer: how dark each pixel lies in shadow, the darkest caster winning (no shadow on a shadow). */
    private class Layer(val map: MapDef, val s: Stand) {
        val w = map.width * R; val h = map.height * R
        val a = FloatArray(w * h)
        val n = sqrt(s.dx * s.dx + s.dy * s.dy)
        val ux = s.dx / n; val uy = s.dy / n
        /** The ground point the shadow of (x, y) at height [z] tiles falls on. */
        fun fall(x: Double, y: Double, z: Double) = doubleArrayOf(x + ux * s.len * z, y + uy * s.len * z)

        private fun put(px: Int, py: Int, k: Double) {
            if (px !in 0 until w || py !in 0 until h) return
            val i = py * w + px
            if (k > a[i]) a[i] = k.toFloat()
        }

        /** The shadow of a convex body given by its corners (x, y, z in tiles): the hull of where they fall. */
        fun solid(pts: List<DoubleArray>, alpha: Double = ALPHA, soft: Double = 0.08) {
            val hull = hull(pts.map { fall(it[0], it[1], it[2]) })
            if (hull.size < 3) return
            val x0 = floor(hull.minOf { it[0] } * R).toInt() - 1; val x1 = (hull.maxOf { it[0] } * R).toInt() + 1
            val y0 = floor(hull.minOf { it[1] } * R).toInt() - 1; val y1 = (hull.maxOf { it[1] } * R).toInt() + 1
            for (py in max(0, y0)..min(h - 1, y1)) for (px in max(0, x0)..min(w - 1, x1)) {
                val x = (px + 0.5) / R; val y = (py + 0.5) / R
                // inside a counter-clockwise hull every edge has the point on its left: the least distance to an edge
                var d = Double.MAX_VALUE
                for (k in hull.indices) {
                    val p = hull[k]; val q = hull[(k + 1) % hull.size]
                    val ex = q[0] - p[0]; val ey = q[1] - p[1]; val el = sqrt(ex * ex + ey * ey).coerceAtLeast(1e-9)
                    d = min(d, (ex * (y - p[1]) - ey * (x - p[0])) / el)
                }
                if (d <= 0) continue
                put(px, py, alpha * smooth(d / soft))
            }
        }

        /** The shadow of a round rod from (x0, y0, z0) to (x1, y1, z1) of radius [r] tiles. */
        fun rod(x0: Double, y0: Double, z0: Double, x1: Double, y1: Double, z1: Double, r: Double, alpha: Double = ALPHA) {
            val p = fall(x0, y0, z0); val q = fall(x1, y1, z1)
            blob(p[0], p[1], q[0], q[1], r, alpha, soft = r * 0.6)
        }

        /** A soft capsule on the ground from (ax, ay) to (bx, by), radius [r]; [dapple] lets light through like leaves. */
        fun blob(ax: Double, ay: Double, bx: Double, by: Double, r: Double, alpha: Double, soft: Double, dapple: Int = -1) {
            val x0 = floor((min(ax, bx) - r) * R).toInt(); val x1 = ((max(ax, bx) + r) * R).toInt() + 1
            val y0 = floor((min(ay, by) - r) * R).toInt(); val y1 = ((max(ay, by) + r) * R).toInt() + 1
            val ex = bx - ax; val ey = by - ay; val el2 = (ex * ex + ey * ey).coerceAtLeast(1e-9)
            for (py in max(0, y0)..min(h - 1, y1)) for (px in max(0, x0)..min(w - 1, x1)) {
                val x = (px + 0.5) / R; val y = (py + 0.5) / R
                val t = (((x - ax) * ex + (y - ay) * ey) / el2).coerceIn(0.0, 1.0)
                val dx = x - ax - ex * t; val dy = y - ay - ey * t
                val d = r - sqrt(dx * dx + dy * dy)
                if (d <= 0) continue
                var k = alpha * smooth(d / soft)
                // leaves: patches of light through the crown, larger and smaller
                if (dapple >= 0) k *= 0.62 + 0.38 * noise(x * 3.1, y * 3.1, dapple) * (0.6 + 0.4 * noise(x * 7.3, y * 7.3, dapple + 1))
                put(px, py, k)
            }
        }

        fun cast(map: MapDef) {
            houses(map)
            things(map)
            trees(map)
        }

        /** Each house: the hull of its footprint, its eaves and the ends of its ridge, where they fall. */
        private fun houses(map: MapDef) {
            for ((f, _) in MapTownIso.houses(map)) {
                val g = MapTownIso.shape(map, f)
                val x0 = f.x.toDouble(); val x1 = (f.x + f.n).toDouble(); val y0 = f.top.toDouble(); val y1 = (f.y + 1).toDouble()
                val o = g.overhang; val eave = g.eave / ZT; val ridge = g.ridge / ZT; val ym = (y0 + y1) / 2
                solid(listOf(
                    doubleArrayOf(x0, y0, 0.0), doubleArrayOf(x1, y0, 0.0), doubleArrayOf(x0, y1, 0.0), doubleArrayOf(x1, y1, 0.0),
                    doubleArrayOf(x0 - o, y0 - o, eave), doubleArrayOf(x1 + o, y0 - o, eave), doubleArrayOf(x0 - o, y1 + o, eave), doubleArrayOf(x1 + o, y1 + o, eave),
                    doubleArrayOf(x0 - o, ym, ridge), doubleArrayOf(x1 + o, ym, ridge),
                ), alpha = 0.52, soft = 0.1)
                g.towerI?.let { ti -> solid(box(x1 + ti - 0.5, ym - 0.5, x1 + ti + 0.5, ym + 0.5, 0.0, g.towerTop / ZT), alpha = 0.52, soft = 0.1) }
            }
        }

        /** The corners of a box between (x0, y0) and (x1, y1), from [z0] up to [z1] tiles. */
        private fun box(x0: Double, y0: Double, x1: Double, y1: Double, z0: Double, z1: Double) = listOf(
            doubleArrayOf(x0, y0, z0), doubleArrayOf(x1, y0, z0), doubleArrayOf(x0, y1, z0), doubleArrayOf(x1, y1, z0),
            doubleArrayOf(x0, y0, z1), doubleArrayOf(x1, y0, z1), doubleArrayOf(x0, y1, z1), doubleArrayOf(x1, y1, z1))

        /** The things of the village and the woods that stand higher than a knee; places as in [MapTownIso] (i, j from −1 to 0 on a tile). */
        private fun things(map: MapDef) {
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                // a point on the tile: local (i, j) as the pictures have it
                val bx = tx + 1.0; val by = ty + 1.0
                fun u(z: Double) = z / ZT
                fun post(i: Double, j: Double, top: Double, r: Double = 0.04) = rod(bx + i, by + j, 0.0, bx + i, by + j, u(top), r)
                val t = map.tile(tx, ty)
                when {
                    t == Tile.WELL -> {
                        solid(box(bx - 0.85, by - 0.85, bx - 0.15, by - 0.15, 0.0, u(40.0)))
                        post(-0.5, -0.86, 150.0); post(-0.5, -0.14, 150.0)
                        solid(listOf(doubleArrayOf(bx - 0.8, by - 0.92, u(118.0)), doubleArrayOf(bx - 0.2, by - 0.92, u(118.0)),
                            doubleArrayOf(bx - 0.8, by - 0.08, u(118.0)), doubleArrayOf(bx - 0.2, by - 0.08, u(118.0)),
                            doubleArrayOf(bx - 0.5, by - 0.92, u(158.0)), doubleArrayOf(bx - 0.5, by - 0.08, u(158.0))))
                    }
                    t == Tile.STALL -> {
                        val west = map.tile(tx - 1, ty) == Tile.STALL; val east = map.tile(tx + 1, ty) == Tile.STALL
                        val i0 = if (west) -1.0 else -0.9; val i1 = if (east) 0.0 else -0.1
                        solid(box(bx + i0, by - 0.72, bx + i1, by - 0.28, u(42.0), u(48.0)))
                        if (!west) { post(i0, -0.72, 130.0, 0.03); post(i0, -0.28, 112.0, 0.03) }
                        if (!east) { post(i1, -0.72, 130.0, 0.03); post(i1, -0.28, 112.0, 0.03) }
                        // the cloth roof, sloping from the back poles to the front
                        solid(listOf(doubleArrayOf(bx + i0 - 0.06, by - 0.76, u(132.0)), doubleArrayOf(bx + i1 + 0.06, by - 0.76, u(132.0)),
                            doubleArrayOf(bx + i0 - 0.06, by - 0.12, u(106.0)), doubleArrayOf(bx + i1 + 0.06, by - 0.12, u(106.0))))
                    }
                    t == Tile.LAMP || (map.id == "village" && tx == MapTownIso.BRIDGE_LANTERN.first && ty == MapTownIso.BRIDGE_LANTERN.second) -> {
                        val bridge = t != Tile.LAMP
                        val (ci, cj) = if (bridge) MapTownIso.bridgeLanternLocal() else -0.5 to -0.5
                        post(ci, cj, 170.0, 0.035)
                        solid(box(bx + ci - 0.08, by + cj - 0.08, bx + ci + 0.08, by + cj + 0.08, u(140.0), u(192.0)))
                    }
                    t == Tile.MENHIR -> {
                        // a slab, broad along its turn, thin across, narrower towards the top
                        val (hh, turn) = MapWoodIso.menhirShape(map, tx, ty)
                        val ca = cos(turn); val sa = sin(turn)
                        fun corner(u: Double, w: Double, z: Double, k: Double) =
                            doubleArrayOf(bx - 0.5 + (u * ca - w * sa) * k, by - 0.5 + (u * sa + w * ca) * k, z)
                        solid(listOf(-1.0, 1.0).flatMap { su -> listOf(-1.0, 1.0).flatMap { sw ->
                            listOf(corner(su * 0.32, sw * 0.17, 0.0, 1.0), corner(su * 0.32, sw * 0.17, u(hh), 0.6)) } }, soft = 0.07)
                    }
                    t == Tile.SIGN -> {
                        post(-0.5, -0.4, 110.0)
                        solid(box(bx - 0.82, by - 0.42, bx - 0.18, by - 0.36, u(70.0), u(100.0)))
                    }
                    t == Tile.NOTICE -> {
                        post(-0.88, -0.41, 146.0, 0.05); post(-0.12, -0.41, 146.0, 0.05)
                        solid(box(bx - 0.94, by - 0.44, bx - 0.06, by - 0.38, u(52.0), u(118.0)))
                    }
                    t == Tile.BARRIER -> {
                        if (map.tile(tx - 1, ty) != Tile.BARRIER) post(-0.8, -0.54, 84.0, 0.07)
                        rod(bx - 1.0, by - 0.5, u(70.0), bx, by - 0.5, u(70.0), 0.04)
                    }
                    t == Tile.FENCE -> {
                        // a fence is a thin wall about a metre high: from the post to each fence beside it (93: a garden's on its edge)
                        val (mi, mj) = MapTownIso.fenceSpot(map, tx, ty); val top = u(50.0)
                        fun run(i0: Double, j0: Double, i1: Double, j1: Double) = solid(listOf(
                            doubleArrayOf(bx + i0, by + j0, 0.0), doubleArrayOf(bx + i1, by + j1, 0.0),
                            doubleArrayOf(bx + i0, by + j0, top), doubleArrayOf(bx + i1, by + j1, top),
                            doubleArrayOf(bx + i0 + 0.03, by + j0 + 0.03, 0.0), doubleArrayOf(bx + i1 + 0.03, by + j1 + 0.03, top)), alpha = 0.36, soft = 0.05)
                        post(mi, mj, 56.0, 0.05)
                        if (map.tile(tx - 1, ty) == Tile.FENCE) run(-1.0, mj, mi, mj)
                        if (map.tile(tx + 1, ty) == Tile.FENCE) run(mi, mj, 0.0, mj)
                        if (map.tile(tx, ty - 1) == Tile.FENCE) run(mi, -1.0, mi, mj)
                        if (map.tile(tx, ty + 1) == Tile.FENCE) run(mi, mj, mi, 0.0)
                    }
                    t == Tile.HAY -> {
                        // a heap: its foot a ring, its top a point
                        val (r, hh) = MapWoodIso.hayShape(tx, ty)
                        solid((0 until 12).map { k -> doubleArrayOf(bx - 0.5 + r * cos(k * Math.PI / 6), by - 0.5 + r * sin(k * Math.PI / 6), 0.0) } +
                            listOf(doubleArrayOf(bx - 0.5, by - 0.5, u(hh))) +
                            (0 until 8).map { k -> doubleArrayOf(bx - 0.5 + r * 0.7 * cos(k * Math.PI / 4), by - 0.5 + r * 0.7 * sin(k * Math.PI / 4), u(hh * 0.5)) }, soft = 0.1)
                    }
                    // D29.4: the bench (its back on the third look), the barrel and the rocks of the woods
                    t == Tile.BENCH -> {
                        solid(box(bx - 0.92, by - 0.62, bx - 0.08, by - 0.4, 0.0, u(30.0)), soft = 0.06)
                        if (MapTownIso.look(tx, ty) == 2) solid(box(bx - 0.92, by - 0.66, bx - 0.08, by - 0.62, u(30.0), u(62.0)), soft = 0.06)
                    }
                    t == Tile.BARREL -> solid((0 until 12).flatMap { k ->
                        val ci = bx - 0.5 + 0.25 * cos(k * Math.PI / 6); val cj = by - 0.5 + 0.25 * sin(k * Math.PI / 6)
                        listOf(doubleArrayOf(ci, cj, 0.0), doubleArrayOf(ci, cj, u(50.0)))
                    }, soft = 0.06)
                    t == Tile.ROCK && map.kind == MapKind.FOREST -> for (st in MapWoodIso.rockShape(tx, ty)) {
                        // a stone: its foot an ellipse, its top a smaller one, flattened
                        solid((0 until 12).flatMap { k ->
                            val c = cos(k * Math.PI / 6); val sn = sin(k * Math.PI / 6)
                            listOf(doubleArrayOf(bx + st[0] + st[2] * c, by + st[1] + st[3] * sn, 0.0),
                                doubleArrayOf(bx + st[0] + st[2] * 0.55 * c, by + st[1] + st[3] * 0.55 * sn, st[4] * 0.85))
                        }, alpha = 0.4, soft = 0.07)
                    }
                    // D29.3: the things of a yard, as [MapTownIso.yard] draws them
                    t == Tile.YARD -> when (MapTownIso.yardKind(map, tx, ty)) {
                        0 -> solid(box(bx - 0.94, by - 0.78, bx - 0.08, by - 0.36, 0.0, u(if (MapTownIso.look(tx, ty) == 0) 90.0 else 64.0)), soft = 0.06)
                        1 -> solid(box(bx - 0.72, by - 0.68, bx - 0.16, by - 0.32, u(20.0), u(if (MapTownIso.look(tx, ty) == 0) 52.0 else 66.0)), soft = 0.06)
                        2 -> solid((0 until 12).flatMap { k ->
                            val ci = bx - 0.55 + 0.28 * cos(k * Math.PI / 6); val cj = by - 0.55 + 0.24 * sin(k * Math.PI / 6)
                            listOf(doubleArrayOf(ci, cj, 0.0), doubleArrayOf(ci, cj, u(30.0)))
                        }, alpha = 0.4, soft = 0.06)
                        else -> {
                            val bar = if (MapTownIso.look(tx, ty) == 1) 64.0 else 122.0
                            post(-0.86, -0.5, bar + 6, 0.03); post(-0.14, -0.5, bar + 6, 0.03)
                            rod(bx - 0.86, by - 0.5, u(bar), bx - 0.14, by - 0.5, u(bar), 0.02)
                            // the net: a thin, see-through sheet
                            solid(listOf(doubleArrayOf(bx - 0.84, by - 0.5, u(bar * 0.2)), doubleArrayOf(bx - 0.16, by - 0.5, u(bar * 0.2)),
                                doubleArrayOf(bx - 0.84, by - 0.5, u(bar)), doubleArrayOf(bx - 0.16, by - 0.5, u(bar)),
                                doubleArrayOf(bx - 0.84, by - 0.48, u(bar)), doubleArrayOf(bx - 0.16, by - 0.48, u(bar * 0.2))), alpha = 0.16, soft = 0.05)
                        }
                    }
                    // D29.4: the low railing along both sides of the village's bridge, as [MapTownIso] draws it
                    t == Tile.BRIDGE && map.id == "village" -> for (west in listOf(true, false)) {
                        if (map.tile(if (west) tx - 1 else tx + 1, ty) == Tile.BRIDGE) continue
                        val i = if (west) -0.94 else -0.06
                        rod(bx + i, by - 1.0, u(45.0), bx + i, by, u(45.0), 0.03, alpha = 0.4)
                        rod(bx + i, by - 1.0, u(22.0), bx + i, by, u(22.0), 0.02, alpha = 0.3)
                        post(i, -0.5, 50.0, 0.035)
                    }
                    t == Tile.WASHLINE && map.tile(tx - 1, ty) != Tile.WASHLINE -> {
                        var n = 0; while (map.tile(tx + n, ty) == Tile.WASHLINE) n++
                        val g0 = tx + 0.12; val g1 = tx + n - 0.12; val y = ty + 0.5
                        rod(g0, y, 0.0, g0, y, u(105.0), 0.03); rod(g1, y, 0.0, g1, y, u(105.0), 0.03)
                        rod(g0, y, u(99.0), g1, y, u(99.0), 0.012, alpha = 0.3)
                    }
                }
            }
        }

        /** The trees and young spruces: the trunk a rod, the crown a ball whose shadow is stretched along the fall. */
        private fun trees(map: MapDef) {
            val D = MapGround.D; val S = MapGround.S.toDouble()
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                if (map.tile(tx, ty) != Tile.TREE) continue
                for (o in MapFlora.objects(map, tx, ty) ?: continue) {
                    if (o.corner) continue
                    val wpx = o.img.width; val hpx = o.img.height
                    val fx = (o.x * D + wpx / 2) / S; val fy = o.sortY * D / S
                    // the picture's height in tiles (upright, ZS art pixels a unit), the crown about its upper two thirds
                    val hT = hpx / (ZT * MapRoomIso.ZS)
                    val rc = wpx / 2.0 / (MapRoomIso.TW / sqrt(2.0)) * 0.85
                    val hc = (hT - rc * 0.9).coerceAtLeast(rc)
                    rod(fx, fy, 0.0, fx, fy, hc - rc * 0.6, 0.05, alpha = 0.32)
                    val c = fall(fx, fy, hc)
                    val stretch = rc * (sqrt(1 + s.len * s.len) - 1) * 0.8
                    blob(c[0] - ux * stretch, c[1] - uy * stretch, c[0] + ux * stretch, c[1] + uy * stretch, rc, 0.44, soft = rc * 0.45, dapple = tx * 31 + ty * 17)
                }
            }
        }

        /** How dark each [G]th of a tile lies, the mean of its pixels (so the leaves' patches do not flicker on a figure). */
        fun shade(): ByteArray {
            val sw = map.width * G; val sh = map.height * G; val b = R / G
            val out = ByteArray(sw * sh)
            for (gy in 0 until sh) for (gx in 0 until sw) {
                var sum = 0f
                for (y in gy * b until (gy + 1) * b) for (x in gx * b until (gx + 1) * b) sum += a[y * w + x]
                out[gy * sw + gx] = (sum / (b * b) * 255).toInt().coerceIn(0, 255).toByte()
            }
            return out
        }

        /** The layer cut into pieces, empty ones left out. */
        fun pieces(): List<WorldArt.Obj> {
            val out = ArrayList<WorldArt.Obj>()
            val step = CH * R
            for (y0 in 0 until h step step) for (x0 in 0 until w step step) {
                val pw = min(step, w - x0); val ph = min(step, h - y0)
                val img = PixelImage(pw, ph)
                var any = false
                for (y in 0 until ph) for (x in 0 until pw) {
                    val k = a[(y0 + y) * w + x0 + x]
                    if (k <= 0.004f) continue
                    img.pixels[y * pw + x] = ((k * 255).toInt().coerceIn(0, 255) shl 24) or SHADOW_RGB
                    any = true
                }
                if (any) out += WorldArt.Obj(img, x0 * WorldArt.T / R, y0 * WorldArt.T / R, 0, R / WorldArt.T)
            }
            return out
        }
    }

    private fun smooth(t: Double): Double { val k = t.coerceIn(0.0, 1.0); return k * k * (3 - 2 * k) }

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0
    private fun noise(x: Double, y: Double, s: Int): Double {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        var u = x - ix; var v = y - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    /** The convex hull of [pts], counter-clockwise (x right, y down: so every inside point lies left of each edge). */
    private fun hull(pts: List<DoubleArray>): List<DoubleArray> {
        val p = pts.sortedWith(compareBy({ it[0] }, { it[1] }))
        if (p.size < 3) return p
        fun cross(o: DoubleArray, a: DoubleArray, b: DoubleArray) = (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
        val lower = ArrayList<DoubleArray>(); val upper = ArrayList<DoubleArray>()
        for (q in p) { while (lower.size >= 2 && cross(lower[lower.size - 2], lower.last(), q) <= 0) lower.removeAt(lower.size - 1); lower += q }
        for (q in p.asReversed()) { while (upper.size >= 2 && cross(upper[upper.size - 2], upper.last(), q) <= 0) upper.removeAt(upper.size - 1); upper += q }
        lower.removeAt(lower.size - 1); upper.removeAt(upper.size - 1)
        return lower + upper
    }

}
