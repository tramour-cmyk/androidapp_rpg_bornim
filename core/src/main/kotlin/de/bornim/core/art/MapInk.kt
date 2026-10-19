package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * 62h/62n (draft): the map of a place drawn like the land map ([LandSheet]): ink and watercolour on parchment, three
 * times finer than [MapSheet], soft strokes instead of steps. Washes blend from tile to tile, so nothing shows the
 * grid; water and houses get an inked edge where they meet the ground, trees are small drawings, the ways wander.
 * Only what the hero has seen is drawn; the rest is bare parchment, the edge between frayed. Same layout as
 * [MapSheet] ([MapSheet.C] map pixels a tile, [MapSheet.PAD] round it), every map pixel [S] × [S] pixels.
 */
object MapInk {
    const val S = 3
    private const val C = MapSheet.C
    private const val PAD = MapSheet.PAD

    private const val GROUND = 0xFFE6D3A8.toInt()
    private const val STAIN = 0xFF9A7A50.toInt()
    private const val INK = 0xFF4A3622.toInt()
    private const val SOFT = 0xFF7A6248.toInt()
    private const val RED = 0xFFA8322A.toInt()
    private const val WATER = 0xFF7E98A0.toInt()
    private const val GREEN = 0xFF8EA06A.toInt()
    private const val DEEP = 0xFF5E7350.toInt()

    private fun hash(x: Int, y: Int, s: Int): Int {
        var h = x * 374761393 + y * 668265263 + s * 2147483629
        h = (h xor (h ushr 13)) * 1274126177
        return (h xor (h ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun mix(a: Int, b: Int, t: Double): Int {
        fun ch(c: Int, s: Int) = (c shr s) and 0xFF
        fun m(s: Int) = (ch(a, s) + (ch(b, s) - ch(a, s)) * t.coerceIn(0.0, 1.0)).toInt()
        return (0xFF shl 24) or (m(16) shl 16) or (m(8) shl 8) or m(0)
    }

    private fun noise(x: Double, y: Double, cell: Double, seed: Int): Double {
        val gx = x / cell; val gy = y / cell
        val ix = floor(gx).toInt(); val iy = floor(gy).toInt()
        val fx = gx - ix; val fy = gy - iy
        val sx = fx * fx * (3 - 2 * fx); val sy = fy * fy * (3 - 2 * fy)
        val a = rnd(ix, iy, seed) * (1 - sx) + rnd(ix + 1, iy, seed) * sx
        val b = rnd(ix, iy + 1, seed) * (1 - sx) + rnd(ix + 1, iy + 1, seed) * sx
        return a * (1 - sy) + b * sy
    }

    private fun isPath(t: Tile) = t == Tile.PATH || t == Tile.CAVE_ENTRANCE || t == Tile.BRIDGE || t == Tile.DOOR || t == Tile.CAVE_EXIT
    private fun isHouse(t: Tile) = t == Tile.ROOF || t == Tile.ROOF_BLUE || t == Tile.WALL || t == Tile.WINDOW
    private fun isRock(t: Tile) = t == Tile.CAVE_WALL || t == Tile.CRYSTAL || t == Tile.TORCH

    fun render(map: MapDef, seen: (Int, Int) -> Boolean, gateOpen: Boolean = false): PixelImage {
        val win = MapSheet.window(map, seen)
        val mw = win.w * C + 2 * PAD; val mh = win.h * C + 2 * PAD
        val pw = mw * S; val ph = mh * S
        val img = PixelImage(pw, ph)
        val room = map.kind == MapKind.INTERIOR
        val cave = map.kind == MapKind.CAVE
        fun known(tx: Int, ty: Int) = map.inside(tx, ty) && seen(tx, ty)
        fun dot(x: Int, y: Int, c: Int, a: Double = 1.0) { if (x in 0 until pw && y in 0 until ph && a > 0) img.set(x, y, mix(img[x, y], c, a.coerceAtMost(1.0))) }

        // a field over the tiles, smooth between their middles (tile units in, 0..1 out)
        fun field(f: (Int, Int) -> Double): (Double, Double) -> Double = { u, v ->
            val fx = u - 0.5; val fy = v - 0.5
            val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
            var a = fx - ix; var b = fy - iy
            a = a * a * (3 - 2 * a); b = b * b * (3 - 2 * b)
            (f(ix, iy) * (1 - a) + f(ix + 1, iy) * a) * (1 - b) + (f(ix, iy + 1) * (1 - a) + f(ix + 1, iy + 1) * a) * b
        }
        fun clamp(tx: Int, ty: Int) = Pair(tx.coerceIn(0, map.width - 1), ty.coerceIn(0, map.height - 1))
        fun tileIs(p: (Tile) -> Boolean): (Int, Int) -> Double = { x, y -> val (cx, cy) = clamp(x, y); if (p(map.tile(cx, cy))) 1.0 else 0.0 }
        val knownF = field { x, y -> if (known(x, y)) 1.0 else 0.0 }
        // D2.10: the water from a blurred grid and with a slight wander, so a bank runs in curves, not in steps of tiles
        val wet = tileIs { it == Tile.WATER }
        val kern = doubleArrayOf(1.0, 4.0, 6.0, 4.0, 1.0)
        val waterGrid = Array(map.height + 4) { y -> DoubleArray(map.width + 4) { x ->
            var sum = 0.0
            for (j in 0..4) for (i in 0..4) sum += kern[i] * kern[j] * wet(x - 2 + i - 2, y - 2 + j - 2)
            sum / 256.0
        } }
        val waterBlur = field { x, y -> waterGrid[(y + 2).coerceIn(0, map.height + 3)][(x + 2).coerceIn(0, map.width + 3)] }
        val waterSharp = field(wet)
        val waterF: (Double, Double) -> Double = { u, v ->
            val wu = u + (noise(u, v, 2.5, 31) - 0.5) * 0.5; val wv = v + (noise(u, v, 2.5, 37) - 0.5) * 0.5
            // a brook one tile wide would blur away: its middle stays from the sharp field
            maxOf(waterBlur(wu, wv), waterSharp(wu, wv) * 0.62)
        }
        val houseF = field(tileIs(::isHouse))
        val rockF = field(tileIs { isRock(it) || (!cave && it == Tile.ROCK) })
        val treeF = field(tileIs { it == Tile.TREE })
        val fieldF = field(tileIs { it == Tile.CROPS || it == Tile.VEG_BED })
        val cobbleF = field(tileIs { it == Tile.COBBLE })
        val floorF = field(tileIs { it == Tile.WOOD_FLOOR || it == Tile.RUG || it == Tile.CLUTTER || it == Tile.HANGING })
        // in the village the ways are broad: a wash of trodden earth with a soft edge, not strokes (strokes made ladders)
        val town = map.kind == MapKind.TOWN
        val pathF = field(tileIs { town && (it == Tile.PATH || it == Tile.BRIDGE) })

        // 1) the parchment and the washes, all in one pass: each pixel knows where on the map it lies
        val deepWood = map.id == "deep_forest"
        for (y in 0 until ph) for (x in 0 until pw) {
            val mx = x.toDouble() / S; val my = y.toDouble() / S
            val blot = noise(mx, my, 22.0, 1) * 0.55 + noise(mx, my, 7.0, 2) * 0.3 + rnd(x, y, 3) * 0.15
            val edge = minOf(minOf(mx, mw - mx), minOf(my, mh - my))
            var c = mix(GROUND, STAIN, (1.0 - edge / 16.0).coerceIn(0.0, 1.0) * 0.45 + (blot - 0.5) * 0.16)
            val u = (mx - PAD) / C + win.x; val v = (my - PAD) / C + win.y
            if (u >= 0 && v >= 0 && u < map.width && v < map.height) {
                // known: frayed with noise, so the edge to the bare parchment is torn, not stepped
                val k = ((knownF(u, v) - 0.5 + (noise(mx, my, 3.0, 5) - 0.5) * 0.5) * 4 + 0.5).coerceIn(0.0, 1.0)
                if (k > 0) {
                    val grain = (noise(mx, my, 5.0, 7) - 0.5) * 0.25
                    var w = c
                    if (!room && !cave) w = mix(w, mix(GREEN, GROUND, 0.45), 0.35 + grain)
                    if (!room && !cave) w = mix(w, if (deepWood) DEEP else GREEN, treeF(u, v) * (0.5 + grain))
                    w = mix(w, 0xFF98A858.toInt(), fieldF(u, v) * 0.55)
                    w = mix(w, 0xFFC4B898.toInt(), cobbleF(u, v) * 0.6)
                    if (town) w = mix(w, 0xFFC8A47A.toInt(), ((pathF(u, v) - 0.3) * 2.2 + grain).coerceIn(0.0, 0.7))
                    if (!room) w = mix(w, 0xFFC8A878.toInt(), floorF(u, v) * 0.45)
                    if (!room) w = mix(w, mix(STAIN, 0xFFB0644A.toInt(), 0.5), houseF(u, v) * 0.55)
                    if (cave || room) {
                        // 62o: a sketched ground plan, the floor washed, the rock (or a room's walls) left bare but hatched along the wall
                        val r = if (cave) rockF(u, v) else houseF(u, v)
                        w = mix(w, 0xFFCFB386.toInt(), ((0.5 - r) * 4).coerceIn(0.0, 1.0) * (0.55 + grain))
                        if (r > 0.5) {
                            val band = (1 - (r - 0.5) / 0.42).coerceIn(0.0, 1.0)
                            if ((mx + my + noise(mx, my, 4.0, 9) * 1.2) % 2.6 < 0.6) w = mix(w, SOFT, band * 0.7)
                        }
                    } else w = mix(w, 0xFF8A7A66.toInt(), (rockF(u, v) - 0.3).coerceIn(0.0, 1.0) * 0.6)
                    val wa = waterF(u, v)
                    if (wa > 0.35) w = mix(w, mix(WATER, GROUND, 0.25), ((wa - 0.35) * 4).coerceIn(0.0, 0.85))
                    c = mix(c, w, k)
                    // inked edges where water, houses and rock meet the ground: a thin line along the 0.5 contour
                    for ((f, a) in listOf(waterF to 0.55, houseF to 0.9, rockF to 0.75)) {
                        val d = abs(f(u, v) - 0.5)
                        val wd = if (f === waterF) 0.035 else 0.06 // the blurred water rises slower: a thinner band keeps its line fine
                        if (d < wd) c = mix(c, if (f === waterF) SOFT else INK, a * k * (1 - d / wd))
                    }
                }
            }
            img.set(x, y, c)
        }

        // strokes and shapes, in map pixels
        fun stroke(x0: Double, y0: Double, x1: Double, y1: Double, c: Int, w: Double = 0.6, a: Double = 1.0) {
            val r = w * S / 2
            val ax = x0 * S; val ay = y0 * S; val bx = x1 * S; val by = y1 * S
            val dx = bx - ax; val dy = by - ay; val len2 = (dx * dx + dy * dy).coerceAtLeast(1e-6)
            for (yy in (minOf(ay, by) - r - 1).toInt()..(maxOf(ay, by) + r + 1).toInt()) for (xx in (minOf(ax, bx) - r - 1).toInt()..(maxOf(ax, bx) + r + 1).toInt()) {
                val t = (((xx + 0.5 - ax) * dx + (yy + 0.5 - ay) * dy) / len2).coerceIn(0.0, 1.0)
                val ex = ax + dx * t - xx - 0.5; val ey = ay + dy * t - yy - 0.5
                val cov = (r + 0.5 - sqrt(ex * ex + ey * ey)).coerceIn(0.0, 1.0)
                if (cov > 0) dot(xx, yy, c, a * cov)
            }
        }
        fun disc(cx: Double, cy: Double, r: Double, c: Int, a: Double = 1.0, sy: Double = 1.0) {
            for (yy in ((cy - r * sy) * S - 1).toInt()..((cy + r * sy) * S + 1).toInt()) for (xx in ((cx - r) * S - 1).toInt()..((cx + r) * S + 1).toInt()) {
                val ex = (xx + 0.5) / S - cx; val ey = ((yy + 0.5) / S - cy) / sy
                val cov = ((r - sqrt(ex * ex + ey * ey)) * S + 0.5).coerceIn(0.0, 1.0)
                if (cov > 0) dot(xx, yy, c, a * cov)
            }
        }
        fun ring(cx: Double, cy: Double, r: Double, c: Int, w: Double = 0.4, a: Double = 1.0, sy: Double = 1.0, from: Int = 0, to: Int = 16) {
            for (i in from until to) {
                val a0 = Math.PI * 2 * i / 16; val a1 = Math.PI * 2 * (i + 1) / 16
                stroke(cx + cos(a0) * r, cy + sin(a0) * r * sy, cx + cos(a1) * r, cy + sin(a1) * r * sy, c, w, a)
            }
        }
        fun tri(ax: Double, ay: Double, bx: Double, by: Double, cx: Double, cy: Double, left: Int, right: Int) {
            val x0 = (minOf(ax, bx, cx) * S).toInt() - 1; val x1 = (maxOf(ax, bx, cx) * S).toInt() + 1
            val y0 = (minOf(ay, by, cy) * S).toInt() - 1; val y1 = (maxOf(ay, by, cy) * S).toInt() + 1
            fun side(px: Double, py: Double, qx: Double, qy: Double, rx: Double, ry: Double) = (px - rx) * (qy - ry) - (qx - rx) * (py - ry)
            for (yy in y0..y1) for (xx in x0..x1) {
                val px = (xx + 0.5) / S; val py = (yy + 0.5) / S
                val d1 = side(px, py, ax, ay, bx, by); val d2 = side(px, py, bx, by, cx, cy); val d3 = side(px, py, cx, cy, ax, ay)
                if ((d1 < 0 || d2 < 0 || d3 < 0) && (d1 > 0 || d2 > 0 || d3 > 0)) continue
                val t = ((px - minOf(ax, bx, cx)) / (maxOf(ax, bx, cx) - minOf(ax, bx, cx)).coerceAtLeast(0.1)).coerceIn(0.0, 1.0)
                dot(xx, yy, mix(left, right, t))
            }
        }
        fun mx(tx: Int) = PAD + (tx - win.x) * C + C / 2.0
        fun my(ty: Int) = PAD + (ty - win.y) * C + C / 2.0
        val leaf = mix(GREEN, GROUND, 0.2); val leafDark = mix(GREEN, INK, 0.35)
        val fir = mix(DEEP, GROUND, 0.1); val firDark = mix(DEEP, INK, 0.45)

        // 2) the ways: soft brown strokes from tile to tile, bent a little, dashed in the woods
        val wayC = 0xFF8A6238.toInt()
        // a way's point is the mean of the way tiles around it, so steps along the grid round off into a bend
        fun wayAt(tx: Int, ty: Int): Pair<Double, Double> {
            var sx = 0.0; var sy = 0.0; var n = 0
            for (dy in -1..1) for (dx in -1..1) {
                val qx = tx + dx; val qy = ty + dy
                if (map.inside(qx, qy) && isPath(map.tile(qx, qy))) { sx += mx(qx); sy += my(qy); n++ }
            }
            val j = (rnd(tx, ty, 13) - 0.5) * 1.2
            return Pair(sx / n + j, sy / n + j * 0.6)
        }
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (town || !known(tx, ty) || !isPath(map.tile(tx, ty))) continue
            for ((dx, dy) in listOf(1 to 0, 0 to 1, 1 to 1, -1 to 1)) {
                val nx = tx + dx; val ny = ty + dy
                if (!known(nx, ny) || !isPath(map.tile(nx, ny))) continue
                if (dx != 0 && dy != 0 && (isPath(map.tile(tx + dx, ty)) || isPath(map.tile(tx, ty + dy)))) continue
                val (ax, ay) = wayAt(tx, ty); val (bx, by) = wayAt(nx, ny)
                if (map.kind == MapKind.FOREST) {
                    for (k in 0 until 3) if (k != 1) stroke(ax + (bx - ax) * k / 3, ay + (by - ay) * k / 3, ax + (bx - ax) * (k + 1) / 3, ay + (by - ay) * (k + 1) / 3, wayC, 1.0, 0.85)
                } else stroke(ax, ay, bx, by, wayC, if (map.kind == MapKind.TOWN) 2.2 else 1.2, 0.55)
            }
        }

        // 3) the things, back ones first, so a tree in front overlaps the one behind
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (!known(tx, ty)) continue
            val cx = mx(tx); val cy = my(ty)
            when (map.tile(tx, ty)) {
                Tile.TREE -> {
                    val ox = cx + (rnd(tx, ty, 4) - 0.5) * 3; val oy = cy + (rnd(tx, ty, 5) - 0.5) * 3
                    if (deepWood || rnd(tx, ty, 6) < 0.35) {
                        val h = 7.5 + rnd(tx, ty, 8) * 2.5; val w = h * 0.36; val dark = deepWood
                        stroke(ox, oy + 1, ox, oy + 2.2, INK, 0.6)
                        tri(ox - w, oy + 1, ox, oy + 1 - h, ox + w, oy + 1, if (dark) fir else leaf, if (dark) firDark else leafDark)
                        stroke(ox - w, oy + 1, ox, oy + 1 - h, INK, 0.45); stroke(ox, oy + 1 - h, ox + w, oy + 1, INK, 0.45)
                        stroke(ox - w, oy + 1, ox + w, oy + 1, INK, 0.4, 0.7)
                    } else {
                        val r = 3.0 + rnd(tx, ty, 9) * 0.9
                        stroke(ox, oy + 2.5, ox, oy, INK, 0.6)
                        disc(ox, oy - r * 0.5, r, leaf)
                        disc(ox + r * 0.35, oy - r * 0.35, r * 0.7, leafDark, 0.55)
                        ring(ox, oy - r * 0.5, r, INK, 0.4, 0.8)
                    }
                }
                // a tuft: three blades fanning out of one root, here and there
                Tile.TALL_GRASS -> if (rnd(tx, ty, 21) < 0.4) {
                    val gx = cx + (rnd(tx, ty, 22) - 0.5) * 4; val gy = cy + 1.5 + (rnd(tx, ty, 23) - 0.5) * 3
                    for (k in -1..1) stroke(gx + k * 0.4, gy, gx + k * 1.1, gy - 3.0 + abs(k) * 1.2, SOFT, 0.35, 0.8)
                }
                Tile.FLOWERS -> { disc(cx - 2, cy - 1, 0.6, RED); disc(cx + 1.5, cy + 1, 0.6, 0xFFC8A030.toInt()); disc(cx + 0.5, cy - 2, 0.55, RED) }
                Tile.WATER -> if ((tx + ty) % 2 == 0) { stroke(cx - 2, cy, cx - 0.5, cy - 0.7, SOFT, 0.35, 0.6); stroke(cx - 0.5, cy - 0.7, cx + 1, cy, SOFT, 0.35, 0.6) }
                Tile.ROCK -> if (!cave) { disc(cx, cy, 2.8, 0xFFA89880.toInt(), 0.9, 0.75); disc(cx + 0.8, cy + 0.4, 1.8, 0xFF847460.toInt(), 0.5, 0.75); ring(cx, cy, 2.8, INK, 0.4, 0.9, 0.75) }
                Tile.CAMPFIRE, Tile.HEARTH -> {
                    ring(cx, cy + 1, 2.5, SOFT, 0.5, 0.9, 0.6)
                    stroke(cx - 2, cy + 1.5, cx + 2, cy - 0.5, INK, 0.6); stroke(cx - 2, cy - 0.5, cx + 2, cy + 1.5, INK, 0.6)
                    tri(cx - 1.3, cy + 0.6, cx, cy - 3, cx + 1.3, cy + 0.6, 0xFFD87830.toInt(), RED)
                }
                Tile.CHEST, Tile.TRUNK -> { disc(cx, cy, 2.2, 0xFF8A5A30.toInt(), 0.9, 0.7); stroke(cx - 2.2, cy - 0.3, cx + 2.2, cy - 0.3, INK, 0.45) }
                Tile.SIGN, Tile.NOTICE -> { stroke(cx, cy - 2, cx, cy + 3, INK, 0.5); stroke(cx - 2.2, cy - 2, cx + 2.2, cy - 2, INK, 0.9); stroke(cx - 2, cy - 0.8, cx + 2, cy - 0.8, SOFT, 0.5) }
                Tile.WELL, Tile.FONT -> { disc(cx, cy, 2.4, WATER, 0.7); ring(cx, cy, 2.4, INK, 0.55) }
                Tile.FENCE -> { stroke(cx - C / 2.0, cy, cx + C / 2.0, cy, INK, 0.4, 0.8); for (k in -1..1) stroke(cx + k * 2.6, cy - 1, cx + k * 2.6, cy + 1, INK, 0.5) }
                // D2.9: a red bar while shut; drawn up, only its stubs at the sides
                Tile.GATE -> if (!gateOpen) stroke(cx - C / 2.0, cy, cx + C / 2.0, cy, RED, 0.8)
                    else { stroke(cx - C / 2.0, cy, cx - C / 2.0 + 1.6, cy, INK, 0.6); stroke(cx + C / 2.0 - 1.6, cy, cx + C / 2.0, cy, INK, 0.6) }
                Tile.CROPS, Tile.VEG_BED -> for (k in 0..2) stroke(cx - 3.2, cy - 2.5 + k * 2.5, cx + 3.2, cy - 2.5 + k * 2.5, 0xFF5E7030.toInt(), 0.4, 0.7)
                Tile.TABLE, Tile.COUNTER, Tile.BED, Tile.SHELF, Tile.DESK, Tile.STALL, Tile.BENCH, Tile.RACK, Tile.ALTAR, Tile.ARMCHAIR -> {
                    // one piece over several tiles: run on to the next tile of the same kind, outline only the outer sides
                    val t0 = map.tile(tx, ty)
                    fun same(dx: Int, dy: Int) = map.inside(tx + dx, ty + dy) && map.tile(tx + dx, ty + dy) == t0
                    val inset = when (t0) { Tile.BENCH, Tile.SHELF, Tile.RACK -> 2.2; Tile.ARMCHAIR -> 1.4; else -> 0.6 }
                    val l = if (same(-1, 0)) cx - C / 2.0 else cx - C / 2.0 + inset
                    val r = if (same(1, 0)) cx + C / 2.0 else cx + C / 2.0 - inset
                    val tp = if (same(0, -1)) cy - C / 2.0 else cy - C / 2.0 + inset
                    val bt = if (same(0, 1)) cy + C / 2.0 else cy + C / 2.0 - inset
                    val fill = when (t0) {
                        Tile.BED -> 0xFFC2B494.toInt(); Tile.ALTAR -> 0xFFB0A48C.toInt(); Tile.COUNTER -> 0xFF7A5434.toInt()
                        Tile.SHELF, Tile.RACK -> 0xFF6E5038.toInt(); Tile.STALL -> 0xFFA07040.toInt(); else -> 0xFF957048.toInt()
                    }
                    // half-open on the shared sides, so two tiles of one piece leave no darker seam
                    for (yy in (tp * S).toInt() until (bt * S).toInt() + (if (same(0, 1)) 0 else 1))
                        for (xx in (l * S).toInt() until (r * S).toInt() + (if (same(1, 0)) 0 else 1)) dot(xx, yy, fill, 0.75)
                    if (!same(0, -1)) stroke(l, tp, r, tp, INK, 0.45)
                    if (!same(0, 1)) stroke(l, bt, r, bt, INK, 0.45)
                    if (!same(-1, 0)) stroke(l, tp, l, bt, INK, 0.45)
                    if (!same(1, 0)) stroke(r, tp, r, bt, INK, 0.45)
                    when (t0) {
                        // the bed's pillow at its head (the end without more bed above), the table's planks, the altar's cloth
                        Tile.BED -> if (!same(0, -1)) for (yy in ((tp + 0.8) * S).toInt()..((tp + 2.6) * S).toInt()) for (xx in ((l + 1) * S).toInt()..((r - 1) * S).toInt()) dot(xx, yy, GROUND, 0.9)
                        Tile.TABLE, Tile.DESK, Tile.COUNTER -> stroke(l + 0.6, (tp + bt) / 2, r - 0.6, (tp + bt) / 2, INK, 0.25, 0.45)
                        Tile.ALTAR -> stroke(l + (if (same(-1, 0)) 0.0 else 0.8), (tp + bt) / 2, r - (if (same(1, 0)) 0.0 else 0.8), (tp + bt) / 2, RED, 0.9, 0.8)
                        else -> {}
                    }
                }
                Tile.BARREL, Tile.PLANT, Tile.CANDLES, Tile.LAMP, Tile.CRATE, Tile.YARD -> { disc(cx, cy, 1.6, 0xFF8A6440.toInt(), 0.7); ring(cx, cy, 1.6, INK, 0.4) }
                Tile.TORCH -> disc(cx, cy, 1.1, 0xFFD87830.toInt())
                Tile.STALAGMITE -> tri(cx - 1.6, cy + 1.5, cx, cy - 2.5, cx + 1.6, cy + 1.5, 0xFFA89880.toInt(), 0xFF6E6252.toInt())
                Tile.GLOWSHROOM -> { disc(cx - 1, cy, 0.9, 0xFF5AA8A0.toInt()); disc(cx + 1.2, cy + 0.8, 0.7, 0xFF5AA8A0.toInt()) }
                Tile.CRYSTAL -> tri(cx - 1.2, cy + 1.5, cx, cy - 2.5, cx + 1.2, cy + 1.5, 0xFF9A88C8.toInt(), 0xFF5A4A88.toInt())
                else -> {}
            }
            // hatching on roofs and on rock, a few slanted strokes inside the shape
            val t = map.tile(tx, ty)
            if (isHouse(t) && !room) for (k in 0..2) {
                val hx = cx - 3 + k * 2.6
                stroke(hx, cy + 2.6, hx + 1.8, cy - 1.6, SOFT, 0.35, 0.7)
            }
        }

        // 4) the ways out: small red arrows; a cave's mouth drawn where the way goes in (62p)
        for (wp in map.warps) {
            if (!known(wp.x, wp.y)) continue
            val cx = mx(wp.x); val cy = my(wp.y)
            if (de.bornim.core.World.maps[wp.to.map]?.kind == MapKind.CAVE && !cave) {
                disc(cx, cy - 0.5, 3.4, 0xFF2A2018.toInt(), 0.95, 0.9)
                ring(cx, cy - 0.5, 3.4, INK, 0.6, 1.0, 0.9, 8, 16)
                stroke(cx - 4.5, cy + 2.4, cx + 4.5, cy + 2.4, SOFT, 0.5)
                continue
            }
            val (dx, dy) = when {
                wp.y == 0 -> 0 to -1; wp.y == map.height - 1 -> 0 to 1
                wp.x == 0 -> -1 to 0; wp.x == map.width - 1 -> 1 to 0
                else -> 0 to -1
            }
            val tx = cx + dx * 3.0; val ty = cy + dy * 3.0
            stroke(cx - dx * 1.5, cy - dy * 1.5, tx, ty, RED, 0.7)
            stroke(tx, ty, tx - dx * 2 - dy * 1.8, ty - dy * 2 - dx * 1.8, RED, 0.7)
            stroke(tx, ty, tx - dx * 2 + dy * 1.8, ty - dy * 2 + dx * 1.8, RED, 0.7)
        }

        // the edge of the sheet: a double line with corner knots, as on the land map
        val e0 = 3.0; val e1 = 5.0
        stroke(e0, e0, mw - e0, e0, INK, 0.7); stroke(e0, mh - e0, mw - e0, mh - e0, INK, 0.7)
        stroke(e0, e0, e0, mh - e0, INK, 0.7); stroke(mw - e0, e0, mw - e0, mh - e0, INK, 0.7)
        stroke(e1, e1, mw - e1, e1, SOFT, 0.4); stroke(e1, mh - e1, mw - e1, mh - e1, SOFT, 0.4)
        stroke(e1, e1, e1, mh - e1, SOFT, 0.4); stroke(mw - e1, e1, mw - e1, mh - e1, SOFT, 0.4)
        for ((cx, cy) in listOf(e0 to e0, mw - e0 to e0, e0 to mh - e0, mw - e0 to mh - e0)) { disc(cx, cy, 1.6, GROUND); disc(cx, cy, 1.1, INK) }
        return img
    }
}
