package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * 62h (draft): the land map, the top of the three levels of the map. All places of the land as small drawings
 * (Bornim by the river, the Whisperwood, the deep woods, the Bloodfang cave in the hills), joined by their ways;
 * what the hero has not been to lies under fog. Two looks to choose from: ink on parchment like the maps of the
 * places, or gold on black like the rest of the menu. The names are written over it by the app.
 */
object LandSheet {
    enum class Look { PARCHMENT, NOIR }

    const val W = 200
    const val H = 300

    /** A place on the land map: its map, where its drawing sits and what it is called. */
    class Spot(val map: String, val x: Int, val y: Int, val r: Int, val labelY: Int = y + r * 3 / 4, val labelX: Int = x)

    val spots = listOf(
        // the names beside the way between Bornim and the wood, not across it
        Spot("village", 100, 226, 26, labelY = 214, labelX = 60),
        Spot("forest", 92, 140, 40, labelY = 174, labelX = 54),
        Spot("deep_forest", 166, 112, 28),
        Spot("cave", 84, 56, 22),
    )

    private class Ink(val ground: Int, val stain: Int, val ink: Int, val soft: Int, val water: Int, val green: Int, val deep: Int, val fog: Int)

    private fun inks(look: Look) = when (look) {
        Look.PARCHMENT -> Ink(0xFFE6D3A8.toInt(), 0xFF9A7A50.toInt(), 0xFF4A3622.toInt(), 0xFF7A6248.toInt(),
            0xFF7E98A0.toInt(), 0xFF8EA06A.toInt(), 0xFF5E7350.toInt(), 0xFFD8C69E.toInt())
        Look.NOIR -> Ink(0xFF0E0D0B.toInt(), 0xFF2A241A.toInt(), 0xFFC9A86A.toInt(), 0xFF7A6440.toInt(),
            0xFF3A4A52.toInt(), 0xFF3C4A30.toInt(), 0xFF283222.toInt(), 0xFF16140F.toInt())
    }

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

    /** The drawing is made this many times finer than [W] × [H], so its strokes are drawn, not stepped (62h, 16:08: "noch nicht schön"). */
    const val S = 3

    /** Smooth noise between 0 and 1, [cell] map units across. */
    private fun noise(x: Double, y: Double, cell: Double, seed: Int): Double {
        val gx = x / cell; val gy = y / cell
        val ix = kotlin.math.floor(gx).toInt(); val iy = kotlin.math.floor(gy).toInt()
        val fx = gx - ix; val fy = gy - iy
        val sx = fx * fx * (3 - 2 * fx); val sy = fy * fy * (3 - 2 * fy)
        val a = rnd(ix, iy, seed) * (1 - sx) + rnd(ix + 1, iy, seed) * sx
        val b = rnd(ix, iy + 1, seed) * (1 - sx) + rnd(ix + 1, iy + 1, seed) * sx
        return a * (1 - sy) + b * sy
    }

    /** The drawing, [W]·[S] × [H]·[S] pixels; [known] says which places (map ids) the hero has been to. */
    fun render(look: Look, known: (String) -> Boolean): PixelImage {
        val k = inks(look)
        val pw = W * S; val ph = H * S
        val img = PixelImage(pw, ph)
        // the ground: soft blotches, browner towards the edge, a stain or two
        for (y in 0 until ph) for (x in 0 until pw) {
            val ux = x.toDouble() / S; val uy = y.toDouble() / S
            val blot = noise(ux, uy, 22.0, 1) * 0.55 + noise(ux, uy, 7.0, 2) * 0.3 + rnd(x, y, 3) * 0.15
            val edge = minOf(minOf(ux, W - ux), minOf(uy, H - uy))
            val ring = abs(sqrt((ux - 150) * (ux - 150) + (uy - 40) * (uy - 40)) - 13) < 0.8
            img.set(x, y, mix(k.ground, k.stain, (1.0 - edge / 22.0).coerceIn(0.0, 1.0) * 0.5 + (blot - 0.5) * 0.16 + (if (ring) 0.08 else 0.0)))
        }
        fun dot(x: Int, y: Int, c: Int, a: Double = 1.0) { if (x in 0 until pw && y in 0 until ph && a > 0) img.set(x, y, mix(img[x, y], c, a.coerceAtMost(1.0))) }
        /** A stroke of ink [w] map units wide, its edge smooth. */
        fun stroke(x0: Double, y0: Double, x1: Double, y1: Double, c: Int, w: Double = 0.7, a: Double = 1.0) {
            val r = w * S / 2
            val ax = x0 * S; val ay = y0 * S; val bx = x1 * S; val by = y1 * S
            val dx = bx - ax; val dy = by - ay; val len2 = (dx * dx + dy * dy).coerceAtLeast(1e-6)
            for (y in (minOf(ay, by) - r - 1).toInt()..(maxOf(ay, by) + r + 1).toInt()) for (x in (minOf(ax, bx) - r - 1).toInt()..(maxOf(ax, bx) + r + 1).toInt()) {
                val t = (((x + 0.5 - ax) * dx + (y + 0.5 - ay) * dy) / len2).coerceIn(0.0, 1.0)
                val ex = ax + dx * t - x - 0.5; val ey = ay + dy * t - y - 0.5
                val cov = (r + 0.5 - sqrt(ex * ex + ey * ey)).coerceIn(0.0, 1.0)
                if (cov > 0) dot(x, y, c, a * cov)
            }
        }
        /** A filled disc, its edge smooth (map units). */
        fun disc(cx: Double, cy: Double, r: Double, c: Int, a: Double = 1.0, sy: Double = 1.0, upper: Boolean = false) {
            for (y in ((cy - r * sy) * S - 1).toInt()..(if (upper) (cy * S).toInt() else ((cy + r * sy) * S + 1).toInt())) for (x in ((cx - r) * S - 1).toInt()..((cx + r) * S + 1).toInt()) {
                val ex = (x + 0.5) / S - cx; val ey = ((y + 0.5) / S - cy) / sy
                val cov = ((r - sqrt(ex * ex + ey * ey)) * S + 0.5).coerceIn(0.0, 1.0)
                if (cov > 0) dot(x, y, c, a * cov)
            }
        }
        /** A filled triangle (map units), shaded from its left to its right. */
        fun tri(ax: Double, ay: Double, bx: Double, by: Double, cx: Double, cy: Double, left: Int, right: Int, a: Double = 1.0) {
            val x0 = (minOf(ax, bx, cx) * S).toInt() - 1; val x1 = (maxOf(ax, bx, cx) * S).toInt() + 1
            val y0 = (minOf(ay, by, cy) * S).toInt() - 1; val y1 = (maxOf(ay, by, cy) * S).toInt() + 1
            fun side(px: Double, py: Double, qx: Double, qy: Double, rx: Double, ry: Double) = (px - rx) * (qy - ry) - (qx - rx) * (py - ry)
            for (y in y0..y1) for (x in x0..x1) {
                val px = (x + 0.5) / S; val py = (y + 0.5) / S
                val d1 = side(px, py, ax, ay, bx, by); val d2 = side(px, py, bx, by, cx, cy); val d3 = side(px, py, cx, cy, ax, ay)
                if ((d1 < 0 || d2 < 0 || d3 < 0) && (d1 > 0 || d2 > 0 || d3 > 0)) continue
                val t = ((px - minOf(ax, bx, cx)) / (maxOf(ax, bx, cx) - minOf(ax, bx, cx)).coerceAtLeast(0.1)).coerceIn(0.0, 1.0)
                dot(x, y, mix(left, right, t), a)
            }
        }
        fun wash(cx: Double, cy: Double, r: Double, c: Int, a: Double, seed: Int) {
            for (y in ((cy - r - 4) * S).toInt()..((cy + r + 4) * S).toInt()) for (x in ((cx - r - 4) * S).toInt()..((cx + r + 4) * S).toInt()) {
                val ux = (x + 0.5) / S; val uy = (y + 0.5) / S
                val d = sqrt((ux - cx) * (ux - cx) + (uy - cy) * (uy - cy)) / r
                val edge = 1.0 - d + (noise(ux, uy, 6.0, seed) - 0.5) * 0.45
                if (edge > 0) dot(x, y, c, a * minOf(1.0, edge * 4))
            }
        }
        // a way that wanders a little between two points, dashed
        fun way(x0: Double, y0: Double, x1: Double, y1: Double, seed: Int) {
            val n = 40
            var px = x0; var py = y0
            for (i in 1..n) {
                val t = i.toDouble() / n
                val bend = sin(t * Math.PI) * (rnd(seed, 0, 11) - 0.5) * 10 + sin(t * Math.PI * 3) * 1.2
                val len = sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)).coerceAtLeast(1.0)
                val nx = x0 + (x1 - x0) * t + bend * (y1 - y0) / len; val ny = y0 + (y1 - y0) * t - bend * (x1 - x0) / len
                if (i % 3 != 0) stroke(px, py, nx, ny, k.soft, 0.8, 0.9)
                px = nx; py = ny
            }
        }
        val leaf = mix(k.green, k.ground, 0.25); val leafDark = mix(k.green, k.ink, 0.35)
        val fir = mix(k.deep, k.ground, 0.1); val firDark = mix(k.deep, k.ink, 0.45)
        /** A fir: a cone, light on the left, its outline in ink, a stroke of trunk. */
        fun firTree(x: Double, y: Double, h: Double, dark: Boolean) {
            val w = h * 0.36
            stroke(x, y, x, y + 1.2, k.ink, 0.6)
            tri(x - w, y, x, y - h, x + w, y, if (dark) fir else leaf, if (dark) firDark else leafDark)
            stroke(x - w, y, x, y - h, k.ink, 0.45); stroke(x, y - h, x + w, y, k.ink, 0.45); stroke(x - w, y, x + w, y, k.ink, 0.4, 0.7)
            stroke(x - w * 0.5, y - h * 0.45, x + w * 0.2, y - h * 0.38, k.ink, 0.3, 0.5)
        }
        /** A broad-leaved tree: a round crown, shaded on the right, ringed in ink. */
        fun leafTree(x: Double, y: Double, r: Double) {
            stroke(x, y, x, y - r * 0.6, k.ink, 0.6)
            disc(x, y - r * 1.25, r, leaf)
            disc(x + r * 0.35, y - r * 1.1, r * 0.7, leafDark, 0.55)
            for (i in 0 until 18) {
                val a0 = Math.PI * 2 * i / 18; val a1 = Math.PI * 2 * (i + 1) / 18
                stroke(x + cos(a0) * r, y - r * 1.25 + sin(a0) * r, x + cos(a1) * r, y - r * 1.25 + sin(a1) * r, k.ink, 0.4, if (i in 2..7) 0.9 else 0.55)
            }
        }
        fun house(x: Double, y: Double, w: Double, h: Double) {
            tri(x - 0.6, y - h, x + w / 2, y - h - h * 0.95, x + w + 0.6, y - h, mix(k.stain, k.ground, 0.25), mix(k.stain, k.ink, 0.3))
            for (yy in ((y - h) * S).toInt()..(y * S).toInt()) for (xx in (x * S).toInt()..((x + w) * S).toInt()) dot(xx, yy, mix(k.ground, k.stain, 0.12))
            stroke(x, y, x + w, y, k.ink, 0.5); stroke(x, y - h, x, y, k.ink, 0.5); stroke(x + w, y - h, x + w, y, k.ink, 0.5)
            stroke(x - 0.6, y - h, x + w / 2, y - h - h * 0.95, k.ink, 0.5); stroke(x + w / 2, y - h - h * 0.95, x + w + 0.6, y - h, k.ink, 0.5)
            stroke(x + w / 2, y, x + w / 2, y - h * 0.5, k.ink, 0.7)
        }

        // the river through the south, from west to east, banks in ink, and the bridge
        fun river(x: Double) = 246 + sin(x / 17.0) * 4 + sin(x / 7.0 + 1) * 1.5
        for (x in 0 until pw) {
            val ux = (x + 0.5) / S; val ry = river(ux)
            for (y in ((ry - 4) * S).toInt()..((ry + 4) * S).toInt()) {
                val d = abs((y + 0.5) / S - ry)
                if (d < 2.6) dot(x, y, mix(k.water, k.ground, (d / 2.6) * 0.4), (2.9 - d).coerceIn(0.0, 0.85))
            }
        }
        var lx = 0.0
        while (lx < W) { val nx = lx + 1.5; stroke(lx, river(lx) - 2.9, nx, river(nx) - 2.9, k.soft, 0.5, 0.85); stroke(lx, river(lx) + 2.9, nx, river(nx) + 2.9, k.soft, 0.5, 0.85); lx = nx }
        for (i in 0 until 14) { val wx = 8.0 + i * 14 + rnd(i, 5, 41) * 6; val wy = river(wx); stroke(wx, wy - 0.4, wx + 2.5, wy - 0.9, k.ink, 0.35, 0.45) }
        stroke(96.5, river(101.0) - 4.2, 105.5, river(101.0) - 4.2, k.ink, 0.6); stroke(96.5, river(101.0) + 4.2, 105.5, river(101.0) + 4.2, k.ink, 0.6)
        for (i in 0..4) stroke(97.5 + i * 2.0, river(101.0) - 3.8, 97.5 + i * 2.0, river(101.0) + 3.8, mix(k.stain, k.ink, 0.4), 0.9, 0.8)
        // the ways: Bornim to the woods, through them to the cave and to the deep woods, and south over the bridge;
        // they stop short of the names (the app writes those), so no line runs through a word
        way(100.0, 208.0, 95.0, 179.0, 1)
        way(93.0, 104.0, 86.0, 74.0, 2)
        way(122.0, 130.0, 145.0, 117.0, 3)
        way(101.0, 252.0, 102.0, 294.0, 4)

        // the hills in the north: humps with shade and hatching to the east, the dark mouth of the cave at the foot
        for (hh in listOf(Triple(44.0, 62.0, 15.0), Triple(124.0, 64.0, 14.0), Triple(68.0, 52.0, 19.0), Triple(100.0, 54.0, 17.0))) {
            val (hx, hy, r) = hh
            disc(hx, hy, r, mix(k.ground, k.stain, 0.2), 1.0, 0.72, upper = true)
            disc(hx + r * 0.35, hy, r * 0.62, mix(k.ground, k.stain, 0.34), 0.6, 0.72, upper = true)
            var a = 0
            while (a < 36) { val t0 = Math.PI * a / 36; val t1 = Math.PI * (a + 1) / 36; stroke(hx - cos(t0) * r, hy - sin(t0) * r * 0.72, hx - cos(t1) * r, hy - sin(t1) * r * 0.72, k.ink, 0.6); a++ }
            for (s in 0..5) { val sx = hx + r * 0.15 + s * r * 0.13; stroke(sx, hy - r * 0.45 + s * 0.6, sx - 1.6, hy - 0.5, k.soft, 0.35, 0.8) }
            stroke(hx - r * 0.55, hy - r * 0.2, hx - r * 0.35, hy - r * 0.45, k.soft, 0.35, 0.6)
        }
        disc(84.0, 58.5, 4.2, k.ink, if (look == Look.NOIR) 0.45 else 0.9, 1.15)
        disc(84.0, 61.0, 4.6, mix(k.ground, k.stain, 0.18), 1.0, 0.5)
        stroke(78.5, 61.0, 89.5, 61.0, k.ink, 0.5, 0.8)
        // the Whisperwood: broad-leaved trees and firs round a clearing with its pond, back ones first
        wash(92.0, 140.0, 38.0, k.green, 0.3, 21)
        disc(78.0, 151.0, 5.5, k.water, 0.75, 0.7)
        var ring = 0
        while (ring < 24) { val t0 = Math.PI * 2 * ring / 24; val t1 = Math.PI * 2 * (ring + 1) / 24; stroke(78 + cos(t0) * 5.5, 151 + sin(t0) * 3.85, 78 + cos(t1) * 5.5, 151 + sin(t1) * 3.85, k.soft, 0.45); ring++ }
        val wood = (0 until 64).map { i ->
            val a = rnd(i, 1, 21) * Math.PI * 2; val d = sqrt(rnd(i, 2, 21)) * 36
            Triple(92 + cos(a) * d * 1.05, 142 + sin(a) * d * 0.95, i)
        }.filter { (x, y, _) -> !(abs(x - 78) < 9 && abs(y - 150) < 7) && !(abs(x - 95) < 9 && abs(y - 148) < 6) }.sortedBy { it.second }
        for ((x, y, i) in wood) if (i % 3 == 0) firTree(x, y, 6.5 + rnd(i, 3, 21) * 2, false) else leafTree(x, y, 2.2 + rnd(i, 4, 21) * 0.8)
        // the deep woods: firs only, close together and dark
        wash(166.0, 112.0, 27.0, k.deep, 0.5, 23)
        val deep = (0 until 60).map { i ->
            val a = rnd(i, 3, 23) * Math.PI * 2; val d = sqrt(rnd(i, 4, 23)) * 24
            Pair(166 + cos(a) * d, 116 + sin(a) * d * 0.9)
        }.sortedBy { it.second }
        for ((i, t) in deep.withIndex()) firTree(t.first, t.second, 7.5 + rnd(i, 5, 23) * 2.5, true)
        // Bornim: houses round the square and its well, the temple's tower, fields south of the river
        disc(100.0, 222.0, 3.0, mix(k.ground, k.stain, 0.2), 1.0, 0.6)
        disc(100.0, 222.0, 0.9, k.ink, 0.8)
        for ((hx, hy, w) in listOf(Triple(80.0, 216.0, 7.0), Triple(93.0, 213.0, 6.0), Triple(106.0, 215.0, 7.5), Triple(84.0, 232.0, 6.0), Triple(109.0, 232.0, 7.0), Triple(96.0, 236.0, 5.5))) house(hx, hy, w, 4.0)
        tri(119.0, 220.0, 122.0, 209.0, 125.0, 220.0, mix(k.stain, k.ground, 0.2), mix(k.stain, k.ink, 0.3))
        for (yy in (220 * S)..(232 * S)) for (xx in (119 * S)..(125 * S)) dot(xx, yy, mix(k.ground, k.stain, 0.12))
        stroke(119.0, 220.0, 119.0, 232.0, k.ink, 0.5); stroke(125.0, 220.0, 125.0, 232.0, k.ink, 0.5); stroke(119.0, 232.0, 125.0, 232.0, k.ink, 0.5)
        stroke(119.0, 220.0, 122.0, 209.0, k.ink, 0.5); stroke(122.0, 209.0, 125.0, 220.0, k.ink, 0.5); stroke(122.0, 209.0, 122.0, 206.5, k.ink, 0.4)
        stroke(122.0, 224.0, 122.0, 227.0, k.ink, 0.8)
        for ((fx, fy) in listOf(110.0 to 258.0, 124.0 to 262.0, 112.0 to 268.0, 78.0 to 260.0)) {
            for (r in 0..4) stroke(fx, fy + r * 1.4, fx + 11, fy + r * 1.4 - 1.5, if (r % 2 == 0) k.soft else leafDark, 0.4, 0.75)
            stroke(fx, fy - 0.6, fx + 11, fy - 2.1, k.ink, 0.35, 0.6); stroke(fx, fy + 6.2, fx + 11, fy + 4.7, k.ink, 0.35, 0.6)
        }
        // a wind rose in the north-east corner
        val (rx, ry) = 176.0 to 30.0
        for (i in 0 until 8) {
            val ang = Math.PI / 4 * i - Math.PI / 2; val len = if (i % 2 == 0) 11.0 else 6.0
            val tx = rx + cos(ang) * len; val ty = ry + sin(ang) * len
            val sx = rx + cos(ang + Math.PI / 2) * 1.6; val sy = ry + sin(ang + Math.PI / 2) * 1.6
            val qx = rx + cos(ang - Math.PI / 2) * 1.6; val qy = ry + sin(ang - Math.PI / 2) * 1.6
            tri(sx, sy, tx, ty, rx, ry, k.ink, k.ink, 0.85); tri(qx, qy, tx, ty, rx, ry, k.ground, k.ground, 0.9)
            stroke(qx, qy, tx, ty, k.ink, 0.35); stroke(sx, sy, tx, ty, k.ink, 0.35)
        }
        var cr = 0
        while (cr < 32) { val t0 = Math.PI * 2 * cr / 32; val t1 = Math.PI * 2 * (cr + 1) / 32; stroke(rx + cos(t0) * 7.5, ry + sin(t0) * 7.5, rx + cos(t1) * 7.5, ry + sin(t1) * 7.5, k.soft, 0.35); cr++ }
        // N above it, drawn in strokes
        stroke(174.0, 14.0, 174.0, 9.0, k.ink, 0.5); stroke(174.0, 9.0, 178.0, 14.0, k.ink, 0.5); stroke(178.0, 14.0, 178.0, 9.0, k.ink, 0.5)
        // the edge of the drawing: a double line with small corner knots
        stroke(4.0, 4.0, W - 4.0, 4.0, k.ink, 0.8); stroke(4.0, H - 4.0, W - 4.0, H - 4.0, k.ink, 0.8)
        stroke(4.0, 4.0, 4.0, H - 4.0, k.ink, 0.8); stroke(W - 4.0, 4.0, W - 4.0, H - 4.0, k.ink, 0.8)
        stroke(6.5, 6.5, W - 6.5, 6.5, k.soft, 0.45); stroke(6.5, H - 6.5, W - 6.5, H - 6.5, k.soft, 0.45)
        stroke(6.5, 6.5, 6.5, H - 6.5, k.soft, 0.45); stroke(W - 6.5, 6.5, W - 6.5, H - 6.5, k.soft, 0.45)
        for ((cx, cy) in listOf(4.0 to 4.0, W - 4.0 to 4.0, 4.0 to H - 4.0, W - 4.0 to H - 4.0)) { disc(cx, cy, 2.0, k.ground); disc(cx, cy, 1.4, k.ink) }

        // fog over what the hero has not been to: soft clouds, curled at their edge
        for (sp in spots) if (!known(sp.map)) {
            val r = sp.r + 10.0
            for (y in ((sp.y - r) * S).toInt()..((sp.y + r) * S).toInt()) for (x in ((sp.x - r) * S).toInt()..((sp.x + r) * S).toInt()) {
                val ux = (x + 0.5) / S; val uy = (y + 0.5) / S
                val d = sqrt((ux - sp.x) * (ux - sp.x) + (uy - sp.y) * (uy - sp.y)) / r
                val curl = noise(ux, uy, 7.0, 31) * 0.35 + noise(ux, uy, 3.0, 32) * 0.12
                val a = ((1.0 - d) * 2.6 + curl - 0.3).coerceIn(0.0, 0.96)
                if (a > 0) dot(x, y, k.fog, a)
            }
        }
        return img
    }
}
