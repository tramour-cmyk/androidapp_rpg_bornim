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
 * Shadows with the time of day (89, draft, only in the preview SONNE=…): on the maps under the open sky everything
 * that stands throws its shadow by one sun, cast from its shape and height: the houses (walls, eaves, ridge), the
 * trees (trunk and crown, dappled), wells, stalls, lamps, signs, the notice board, the barrier, fences, hay and the
 * washing lines. Three fixed stands of the sun, changed only at a cut (a change of map, the fade after a rest): in
 * the morning long to the west, at noon short towards the viewer (as before), in the evening long to the east.
 * Low things (bushes, beds, benches, barrels, the corn) keep the small shadow in their own picture.
 *
 * The shadows are one soft layer on the ground of the whole map, [R] pixels a tile, cut into pieces of [CH] tiles,
 * drawn where [MapFlora.shadows] is (under everything that stands, faded by the time of day).
 */
object MapSun {
    /** Whether the shadows come from here; else each picture brings its own and the trees' lie under them (D6.1). */
    @Volatile var on = false

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
            /** The stand for the minute of the day [minutes] (at night that of the evening; the moon follows with D3.14). */
            fun at(minutes: Int): Stand = when (Math.floorMod(minutes, 24 * 60) / 60) {
                in 5 until 10 -> MORNING
                in 10 until 15 -> NOON
                else -> EVENING
            }
        }
    }

    /** The stand the shadows show; set at a cut. */
    @Volatile var stand = Stand.NOON

    private const val R = 32            // layer pixels a tile (one to a world pixel)
    private const val CH = 8            // tiles a piece
    private const val ALPHA = 0.46
    private const val SHADOW_RGB = 0x0A0806
    /** Upright drawing units a tile (as [MapTownIso]: 57 to the metre, a tile 116 cm). */
    private const val ZT = 66.0

    private val cache = HashMap<String, List<WorldArt.Obj>>()

    /** The shadow layer of [map] for [stand], or nothing under a roof or underground. */
    fun shadows(map: MapDef, stand: Stand = this.stand): List<WorldArt.Obj> = synchronized(cache) {
        if (map.kind != MapKind.FOREST && map.kind != MapKind.TOWN) return emptyList()
        cache.getOrPut("${map.id}/$stand") { Layer(map, stand).also { it.cast(map) }.pieces() }
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
            if (map.kind == MapKind.TOWN) things(map)
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

        /** The things of the village that stand higher than a knee; places as in [MapTownIso] (i, j from −1 to 0 on a tile). */
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
                        // a fence is a thin wall about a metre high: from the post in the middle to each fence beside it
                        val m = -0.5; val top = u(50.0)
                        fun run(i0: Double, j0: Double, i1: Double, j1: Double) = solid(listOf(
                            doubleArrayOf(bx + i0, by + j0, 0.0), doubleArrayOf(bx + i1, by + j1, 0.0),
                            doubleArrayOf(bx + i0, by + j0, top), doubleArrayOf(bx + i1, by + j1, top),
                            doubleArrayOf(bx + i0 + 0.03, by + j0 + 0.03, 0.0), doubleArrayOf(bx + i1 + 0.03, by + j1 + 0.03, top)), alpha = 0.36, soft = 0.05)
                        post(m, m, 56.0, 0.05)
                        if (map.tile(tx - 1, ty) == Tile.FENCE) run(-1.0, m, m, m)
                        if (map.tile(tx + 1, ty) == Tile.FENCE) run(m, m, 0.0, m)
                        if (map.tile(tx, ty - 1) == Tile.FENCE) run(m, -1.0, m, m)
                        if (map.tile(tx, ty + 1) == Tile.FENCE) run(m, m, m, 0.0)
                    }
                    t == Tile.HAY -> {
                        // a heap: its foot a ring, its top a point
                        val (r, hh) = MapWoodIso.hayShape(tx, ty)
                        solid((0 until 12).map { k -> doubleArrayOf(bx - 0.5 + r * cos(k * Math.PI / 6), by - 0.5 + r * sin(k * Math.PI / 6), 0.0) } +
                            listOf(doubleArrayOf(bx - 0.5, by - 0.5, u(hh))) +
                            (0 until 8).map { k -> doubleArrayOf(bx - 0.5 + r * 0.7 * cos(k * Math.PI / 4), by - 0.5 + r * 0.7 * sin(k * Math.PI / 4), u(hh * 0.5)) }, soft = 0.1)
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
                    rod(fx, fy, 0.0, fx, fy, hc - rc * 0.6, 0.05)
                    val c = fall(fx, fy, hc)
                    val stretch = rc * (sqrt(1 + s.len * s.len) - 1) * 0.8
                    blob(c[0] - ux * stretch, c[1] - uy * stretch, c[0] + ux * stretch, c[1] + uy * stretch, rc, 0.44, soft = rc * 0.45, dapple = tx * 31 + ty * 17)
                }
            }
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
