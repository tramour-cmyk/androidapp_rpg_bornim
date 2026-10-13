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
    class Spot(val map: String, val x: Int, val y: Int, val r: Int, val labelY: Int = y + r * 3 / 4)

    val spots = listOf(
        Spot("village", 100, 226, 26, labelY = 192),
        Spot("forest", 92, 140, 40),
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

    /** The drawing; [known] says which places (map ids) the hero has been to. */
    fun render(look: Look, known: (String) -> Boolean): PixelImage {
        val k = inks(look)
        val img = PixelImage(W, H)
        // the ground: blotchy, darker towards the edge
        for (y in 0 until H) for (x in 0 until W) {
            val blot = rnd(x / 7, y / 7, 1) * 0.5 + rnd(x / 3, y / 3, 2) * 0.3 + rnd(x, y, 3) * 0.2
            val edge = minOf(minOf(x, W - 1 - x), minOf(y, H - 1 - y)).toDouble()
            img.set(x, y, mix(k.ground, k.stain, (1.0 - edge / 18.0).coerceIn(0.0, 1.0) * 0.45 + (blot - 0.5) * 0.14))
        }
        fun dot(x: Int, y: Int, c: Int, a: Double = 1.0) { if (x in 0 until W && y in 0 until H) img.set(x, y, mix(img[x, y], c, a)) }
        fun wash(cx: Int, cy: Int, r: Int, c: Int, a: Double) {
            for (y in cy - r..cy + r) for (x in cx - r..cx + r) {
                val d = sqrt(((x - cx) * (x - cx) + (y - cy) * (y - cy)).toDouble()) / r
                val edge = 1.0 - d + (rnd(x / 2, y / 2, 7) - 0.5) * 0.35
                if (edge > 0) dot(x, y, c, a * minOf(1.0, edge * 3))
            }
        }
        fun line(x0: Double, y0: Double, x1: Double, y1: Double, c: Int, dash: Int = 0, width: Int = 1) {
            val n = maxOf(abs(x1 - x0), abs(y1 - y0)).toInt().coerceAtLeast(1)
            for (i in 0..n) {
                if (dash > 0 && (i / dash) % 2 == 1) continue
                val x = (x0 + (x1 - x0) * i / n).toInt(); val y = (y0 + (y1 - y0) * i / n).toInt()
                for (w in 0 until width) dot(x + w, y, c)
            }
        }
        // a way that wanders a little between two points
        fun way(x0: Int, y0: Int, x1: Int, y1: Int, seed: Int) {
            var px = x0.toDouble(); var py = y0.toDouble()
            val n = 8
            for (i in 1..n) {
                val t = i.toDouble() / n
                val bend = if (i == n) 0.0 else (rnd(i, seed, 11) - 0.5) * 8
                val nx = x0 + (x1 - x0) * t + bend * (y1 - y0) / 100.0; val ny = y0 + (y1 - y0) * t - bend * (x1 - x0) / 100.0
                line(px, py, nx, ny, k.soft, dash = 3)
                px = nx; py = ny
            }
        }
        fun tree(x: Int, y: Int, c: Int, dark: Boolean) {
            // a small fir: three tiers of ink, a stroke of trunk
            for (t in 0..2) {
                val ty = y - 6 + t * 2; val half = 1 + t
                line((x - half).toDouble(), (ty + 1).toDouble(), x.toDouble(), (ty - 1).toDouble(), k.ink)
                line(x.toDouble(), (ty - 1).toDouble(), (x + half).toDouble(), (ty + 1).toDouble(), k.ink)
                if (dark) for (xx in x - half + 1 until x + half) dot(xx, ty + 1, c, 0.8)
            }
            dot(x, y, k.ink); dot(x, y - 1, k.ink)
        }
        fun house(x: Int, y: Int, big: Boolean) {
            val w = if (big) 7 else 5; val h = 4
            for (xx in x..x + w) { dot(xx, y, k.ink); dot(xx, y - h, k.ink) }
            for (yy in y - h..y) { dot(x, yy, k.ink); dot(x + w, yy, k.ink) }
            // the roof
            val top = y - h - 4
            line(x - 1.0, (y - h).toDouble(), x + w / 2.0, top.toDouble(), k.ink)
            line(x + w / 2.0, top.toDouble(), x + w + 1.0, (y - h).toDouble(), k.ink)
            dot(x + w / 2, y - 1, k.ink); dot(x + w / 2, y - 2, k.ink)
        }

        // the river through the south, from west to east, and the bridge
        for (x in 0 until W) {
            val ry = 246 + (sin(x / 17.0) * 4 + sin(x / 7.0 + 1) * 1.5).toInt()
            for (d in -2..2) dot(x, ry + d, k.water, if (abs(d) == 2) 0.45 else 0.8)
            dot(x, ry - 3, k.soft, 0.6); dot(x, ry + 3, k.soft, 0.6)
        }
        // the ways: Bornim to the woods, through them to the cave and to the deep woods, and south over the bridge
        way(100, 210, 94, 178, 1)
        way(94, 108, 86, 76, 2)
        way(118, 132, 146, 116, 3)
        way(100, 238, 102, 292, 4)
        for (x in 97..105) { dot(x, 244, k.ink); dot(x, 250, k.ink) }

        // the hills in the north, with the mouth of the cave
        for (h in listOf(46 to 60, 70 to 48, 98 to 52, 124 to 62)) {
            val (hx, hy) = h
            for (a in 0..40) {
                val t = Math.PI * a / 40
                dot((hx - cos(t) * 16).toInt(), (hy - sin(t) * 12).toInt(), k.ink)
            }
            for (s in 0..4) line(hx - 6.0 + s * 3, hy - 4.0, hx - 8.0 + s * 3, hy.toDouble(), k.soft)
        }
        for (y in 54..60) for (x in 79..89) {
            val dx = (x - 84) / 5.0; val dy = (y - 60) / 6.0
            if (dx * dx + dy * dy <= 1.0) dot(x, y, k.ink, if (look == Look.NOIR) 0.35 else 0.9)
        }
        // the Whisperwood: firs scattered round its clearing and pond
        wash(92, 140, 40, k.green, 0.35)
        wash(78, 150, 6, k.water, 0.7)
        for (i in 0 until 70) {
            val a = rnd(i, 1, 21) * Math.PI * 2; val d = sqrt(rnd(i, 2, 21)) * 38
            val x = (92 + cos(a) * d * 1.05).toInt(); val y = (142 + sin(a) * d * 0.95).toInt()
            if (abs(x - 78) < 8 && abs(y - 150) < 7) continue
            tree(x, y, k.green, false)
        }
        // the deep woods: dense and dark
        wash(166, 112, 28, k.deep, 0.6)
        for (i in 0 until 55) {
            val a = rnd(i, 3, 23) * Math.PI * 2; val d = sqrt(rnd(i, 4, 23)) * 25
            tree((166 + cos(a) * d).toInt(), (114 + sin(a) * d).toInt(), k.deep, true)
        }
        // Bornim: houses round the square, the tower of the temple, fields to the south of the river
        for ((hx, hy, big) in listOf(Triple(82, 214, true), Triple(96, 212, false), Triple(108, 214, true), Triple(84, 230, false), Triple(110, 230, true), Triple(96, 234, false))) house(hx, hy, big)
        line(120.0, 230.0, 120.0, 218.0, k.ink); line(124.0, 230.0, 124.0, 218.0, k.ink); line(119.0, 218.0, 122.0, 213.0, k.ink); line(122.0, 213.0, 125.0, 218.0, k.ink)
        for (r in 0..3) line(112.0, 260.0 + r * 3, 136.0, 260.0 + r * 3, k.soft, dash = 2)
        // the edge of the drawing: a double line
        for (x in 3 until W - 3) { dot(x, 3, k.ink); dot(x, H - 4, k.ink); dot(x, 5, k.soft); dot(x, H - 6, k.soft) }
        for (y in 3 until H - 3) { dot(3, y, k.ink); dot(W - 4, y, k.ink); dot(5, y, k.soft); dot(W - 6, y, k.soft) }

        // fog over what the hero has not been to: soft clouds, frayed at their edge
        for (s in spots) if (!known(s.map)) {
            val r = s.r + 10
            for (y in s.y - r..s.y + r) for (x in s.x - r..s.x + r) {
                val d = sqrt(((x - s.x) * (x - s.x) + (y - s.y) * (y - s.y)).toDouble()) / r
                val curl = rnd(x / 5, y / 4, 31) * 0.25 + rnd(x / 2, y / 2, 32) * 0.12
                val a = ((1.0 - d) * 2.6 + curl - 0.2).coerceIn(0.0, 0.97)
                if (a > 0) dot(x, y, k.fog, a)
            }
        }
        return img
    }
}
