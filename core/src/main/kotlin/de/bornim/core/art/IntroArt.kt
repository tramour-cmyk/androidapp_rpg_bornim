package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The pictures of the intro (69, draft): the traveller's arrival at Bornim by night, seen through his eyes. Painted like
 * the battle scenes ([BattleScene]): a sky with moon and stars, layered backdrops, a ground plane with depth, light only
 * from what is seen (the moon, windows, torches). Four pictures, one per text `[69.intro.1]`–`[69.intro.4]`; the fifth is black.
 */
object IntroArt {
    /** Width the pictures are designed for, as the battle scenes. */
    const val W = 270
    const val H = 300

    enum class Shot { ROAD, BRIDGE, SQUARE, INN }

    fun paint(shot: Shot, w: Int = W, h: Int = H): PixelImage = Painter(w, h).apply {
        when (shot) {
            Shot.ROAD -> road()
            Shot.BRIDGE -> bridge()
            Shot.SQUARE -> square()
            Shot.INN -> inn()
        }
        vignette()
    }.img

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun vnoise(x: Double, s: Int): Double {
        val i = floor(x).toInt(); val f = x - i
        val u = f * f * (3 - 2 * f)
        return rnd(i, 0, s) * (1 - u) + rnd(i + 1, 0, s) * u
    }

    private val bayer = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)
    private fun dith(x: Int, y: Int) = bayer[(y and 3) * 4 + (x and 3)] / 16.0

    private val skyTop = argb(0x05081A)
    private val skyLow = argb(0x24304E)
    private val moonLit = argb(0xF2EEDA)
    private val moonGlow = argb(0xB8C6E8)
    private val hill = argb(0x121A30)
    private val field = argb(0x0E1618)
    private val fieldLit = argb(0x2A3A44)
    private val dark = argb(0x070A12)
    private val warm = argb(0xFFC060)
    private val warmDeep = argb(0xE07A28)
    private val wood = argb(0x2A2026)
    private val woodLit = argb(0x4E4248)
    private val stone = argb(0x2C3240)
    private val stoneLit = argb(0x4C566C)
    private val roof = argb(0x1A1C2A)

    private class Painter(val w: Int, val h: Int) {
        val img = PixelImage(w, h)
        fun set(x: Int, y: Int, c: Int) = img.set(x, y, c)
        fun blend(x: Int, y: Int, c: Int, a: Double) {
            if (x in 0 until w && y in 0 until h) img.set(x, y, mix(img[x, y], c, a.coerceIn(0.0, 1.0)))
        }
        fun rect(x0: Double, y0: Double, x1: Double, y1: Double, c: Int) {
            for (y in y0.toInt() until y1.toInt()) for (x in x0.toInt() until x1.toInt()) set(x, y, c)
        }
        /** A filled polygon (even-odd), points as x, y pairs. */
        fun poly(c: Int, vararg p: Double, shade: ((Int, Int) -> Int)? = null) {
            val n = p.size / 2
            val ys = (0 until n).map { p[it * 2 + 1] }
            for (y in floor(ys.min()).toInt()..ys.max().toInt()) {
                val yc = y + 0.5
                val xs = mutableListOf<Double>()
                for (i in 0 until n) {
                    val ax = p[i * 2]; val ay = p[i * 2 + 1]; val bx = p[(i + 1) % n * 2]; val by = p[(i + 1) % n * 2 + 1]
                    if ((ay <= yc) != (by <= yc)) xs += ax + (yc - ay) / (by - ay) * (bx - ax)
                }
                xs.sort()
                for (k in 0 until xs.size - 1 step 2) for (x in xs[k].toInt() until xs[k + 1].toInt()) set(x, y, shade?.invoke(x, y) ?: c)
            }
        }
        /** Soft light round ([cx], [cy]), as a lamp or the moon throws it. */
        fun glow(cx: Double, cy: Double, r: Double, c: Int, a: Double, squash: Double = 1.0) {
            for (y in (cy - r * 3 / squash).toInt()..(cy + r * 3 / squash).toInt()) for (x in (cx - r * 3).toInt()..(cx + r * 3).toInt()) {
                val d = sqrt((x - cx).pow(2) + ((y - cy) * squash).pow(2))
                blend(x, y, c, exp(-d / r) * a + (dith(x, y) - 0.5) * 0.02)
            }
        }

        fun sky(horizon: Int, moonX: Double, moonY: Double, full: Boolean = true) {
            for (y in 0 until horizon) for (x in 0 until w) {
                val t = y / horizon.toDouble() + (dith(x, y) - 0.5) * 0.05
                set(x, y, mix(skyTop, skyLow, t.coerceIn(0.0, 1.0).pow(1.6)))
            }
            for (i in 0 until w * horizon / 70) {
                val x = (rnd(i, 1, 7) * w).toInt(); val y = (rnd(i, 2, 7) * horizon * 0.85).toInt()
                val dm = sqrt((x - moonX).pow(2) + (y - moonY).pow(2))
                if (dm > 26) set(x, y, if (i % 11 == 0) Pal.WHITE else mix(img[x, y], argb(0xA8B4D8), 0.4 + rnd(i, 3, 7) * 0.5))
            }
            glow(moonX, moonY, 18.0, moonGlow, 0.45)
            for (y in (moonY - 9).toInt()..(moonY + 9).toInt()) for (x in (moonX - 9).toInt()..(moonX + 9).toInt()) {
                val d1 = (x + 0.5 - moonX).pow(2) + (y + 0.5 - moonY).pow(2)
                val d2 = (x + 0.5 - moonX - 4.0).pow(2) + (y + 0.5 - moonY + 2.5).pow(2)
                if (d1 <= 56 && (full || d2 > 42)) {
                    // a few grey seas on the full moon
                    val sea = full && rnd(x / 2, y / 2, 3) < 0.22
                    set(x, y, if (sea) argb(0xC8C4B4) else moonLit)
                }
            }
            // thin clouds lit from below by the moon
            for (k in 0 until 3) {
                val cy = horizon * (0.3 + k * 0.17); val cx = w * (0.2 + 0.31 * k)
                for (y in (cy - 4).toInt()..(cy + 4).toInt()) for (x in (cx - 46).toInt()..(cx + 46).toInt()) {
                    val q = ((x - cx) / 46.0).pow(2) + ((y - cy) / 4.0).pow(2)
                    if (q < 1 && y in 0 until horizon) blend(x, y, argb(0x3A4666), (1 - q) * 0.5 * (0.6 + vnoise(x / 9.0, k) * 0.6))
                }
            }
        }

        fun hills(horizon: Int, height: Double, s: Int, c: Int) {
            for (x in 0 until w) {
                val top = horizon - height * (0.4 + 0.6 * vnoise(x / 40.0, s)) - 4 * vnoise(x / 8.0, s + 1)
                for (y in top.toInt() until horizon) set(x, y, mix(c, skyLow, 0.25 * (1 - (y - top) / height).coerceIn(0.0, 1.0)))
            }
        }

        /** A dark tree against the sky: a poplar ([tall]) or a round crown. */
        fun tree(cx: Double, base: Double, ht: Double, tall: Boolean, s: Int) {
            rect(cx - 1, base - ht * 0.3, cx + 1, base, dark)
            val rx = if (tall) ht * 0.13 else ht * 0.32; val ry = if (tall) ht * 0.48 else ht * 0.36
            val cy = base - ht + ry
            for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx - 2).toInt()..(cx + rx + 2).toInt()) {
                val q = ((x - cx) / rx).pow(2) + ((y - cy) / ry).pow(2)
                if (q < 1 + (rnd(x, y, s) - 0.5) * 0.5) set(x, y, if (x > cx + rx * 0.3 && rnd(x / 2, y / 2, s) < 0.35) argb(0x161E2C) else dark)
            }
        }

        /** Ground from [horizon] down, shaded darker toward the viewer, a little lit by the moon in the distance. */
        fun ground(horizon: Int, c: Int, lit: Int, s: Int) {
            for (y in horizon until h) for (x in 0 until w) {
                val d = (y - horizon) / (h - horizon).toDouble()
                val n = vnoise(x / (6.0 + d * 20), s + y / 3) * 0.3
                var col = mix(lit, c, (d * 1.4 + n - 0.15 + (dith(x, y) - 0.5) * 0.12).coerceIn(0.0, 1.0))
                // grass: short dark and pale strokes, longer toward the viewer
                val r = rnd(x, (y / (1 + d * 4)).toInt(), s)
                if (r < 0.12) col = mix(col, dark, 0.5) else if (r > 0.95) col = mix(col, argb(0x4A5E6A), 0.35 * (1 - d))
                set(x, y, col)
            }
        }

        /** A house seen from afar: a black block with a roof and [lights] warm windows. */
        fun farHouse(x0: Double, base: Double, wd: Double, ht: Double, lights: Int, s: Int) {
            rect(x0, base - ht, x0 + wd, base, argb(0x0C1020))
            poly(argb(0x0A0E1A), x0 - 2, base - ht, x0 + wd / 2, base - ht - wd * 0.45, x0 + wd + 2, base - ht)
            for (i in 0 until lights) {
                val lx = x0 + 2 + rnd(i, s, 2) * (wd - 4); val ly = base - ht * (0.35 + rnd(i, s, 3) * 0.35)
                glow(lx, ly, 3.0, warm, 0.5)
                rect(lx - 0.5, ly - 1, lx + 1.5, ly + 1, warm)
            }
        }

        fun vignette() {
            for (y in 0 until h) for (x in 0 until w) {
                val dx = (x - w / 2.0) / (w / 2.0); val dy = (y - h / 2.0) / (h / 2.0)
                blend(x, y, argb(0x020306), ((dx * dx + dy * dy) - 0.45).coerceAtLeast(0.0) * 0.55)
            }
        }

        // ---------------------------------------------------------- 69.intro.1: the south road under the moon

        fun road() {
            val hz = (h * 0.46).toInt()
            sky(hz, w * 0.7, h * 0.14)
            hills(hz, 24.0, 3, hill)
            ground(hz, field, fieldLit, 5)
            // the road narrowing to the north, its ruts catching the moonlight
            val vx = w * 0.47
            poly(argb(0x2A2C34), vx - 2, hz.toDouble(), vx + 2, hz.toDouble(), w * 0.86, h.toDouble(), w * 0.10, h.toDouble()) { x, y ->
                val d = (y - hz) / (h - hz).toDouble()
                val half = 2 + (w * 0.38 - 2) * d
                val u = (x - (vx + (w * 0.48 - vx) * d)) / half
                val rut = abs(abs(u) - 0.45) < 0.06 + 0.02 * d
                val base = mix(argb(0x4A4C56), argb(0x24262E), d)
                when {
                    rut -> mix(base, argb(0x14161C), 0.7)
                    abs(u) < 0.3 && rnd(x, y, 4) < 0.025 -> mix(base, argb(0x6A6C78), 0.5)
                    else -> mix(base, argb(0x1C1E24), (vnoise(x / 3.0, y) * 0.4 + (dith(x, y) - 0.5) * 0.15).coerceIn(0.0, 1.0))
                }
            }
            // poplars along the road, smaller with distance
            for (i in 0 until 6) {
                val d = 0.08 + i * i * 0.05
                val y = hz + (h - hz) * d
                val off = 6 + (w * 0.44) * d
                tree(vx - off - 4, y, 14 + 160 * d, true, i)
                if (i % 2 == 1) tree(vx + off + 6, y, 12 + 150 * d, true, i + 9)
            }
            // a milestone at the roadside
            poly(argb(0x3A4050), w * 0.80, h * 0.80, w * 0.85, h * 0.80, w * 0.85, h * 0.70, w * 0.825, h * 0.68, w * 0.80, h * 0.70)
            poly(argb(0x5A6478), w * 0.80, h * 0.80, w * 0.81, h * 0.80, w * 0.81, h * 0.69, w * 0.80, h * 0.70)
            grassFront(5)
        }

        /** Dark grass blades along the bottom edge. */
        fun grassFront(s: Int) {
            for (i in 0 until w / 2) {
                val x0 = rnd(i, 1, s) * w; val len = 6 + rnd(i, 2, s) * 18; val lean = (rnd(i, 3, s) - 0.5) * 8
                for (k in 0 until len.toInt()) set((x0 + lean * k / len).toInt(), h - 1 - k, if (rnd(i, 4, s) < 0.2) argb(0x22303E) else dark)
            }
        }

        // ---------------------------------------------------------- 69.intro.2: river and bridge, Bornim's lights beyond

        fun bridge() {
            val hz = (h * 0.42).toInt()
            sky(hz, w * 0.22, h * 0.12)
            hills(hz, 18.0, 8, hill)
            ground(hz, field, fieldLit, 9)
            // the village on the far bank: roofs and a few lit windows, the temple tower among them
            val bank = hz + 10.0
            for ((i, x) in listOf(0.12, 0.24, 0.36, 0.58, 0.70, 0.82).withIndex()) farHouse(w * x, bank, 16.0 + i % 3 * 4, 9.0 + i % 2 * 3, if (i % 2 == 0) 2 else 1, i)
            rect(w * 0.47, bank - 30, w * 0.47 + 7, bank, argb(0x0C1020))
            poly(argb(0x0A0E1A), w * 0.47 - 1, bank - 30, w * 0.47 + 3.5, bank - 40, w * 0.47 + 8, bank - 30)
            tree(w * 0.05, bank, 26.0, false, 3); tree(w * 0.93, bank, 30.0, false, 4)
            // the river, the moon's light broken on it
            val r0 = bank + 2; val r1 = h * 0.66
            for (y in r0.toInt() until r1.toInt()) for (x in 0 until w) {
                val d = (y - r0) / (r1 - r0)
                var c = mix(argb(0x1A2440), argb(0x0C1222), d)
                if (y % 3 == 0 && rnd(x / (4 + (d * 10).toInt()), y, 5) < 0.18) c = mix(c, argb(0x3A4A6E), 0.6)
                if (abs(x - w * 0.22) < 4 + d * 14 && rnd(x / 2, y, 6) < 0.55 - d * 0.3) c = mix(c, moonLit, 0.55 - d * 0.3)
                // the windows on the water, long and broken
                for (lx in listOf(0.14, 0.26, 0.60, 0.72, 0.84)) if (abs(x - (w * lx + 4)) < 1.2 && rnd(x, y, 8) < 0.5 - d * 0.5) c = mix(c, warm, 0.5)
                set(x, y, c)
            }
            // the bridge from the near bank across: planks in perspective, rails both sides
            val bx = w * 0.5
            poly(woodLit, bx - 10, r0 + 4, bx + 10, r0 + 4, bx + 60, h.toDouble(), bx - 60, h.toDouble()) { x, y ->
                val d = (y - r0) / (h - r0)
                val plank = ((1 / (d + 0.12)) * 3.0).let { it - floor(it) } < 0.06 + d * 0.04
                val base = mix(argb(0x46404A), argb(0x241E24), d)
                if (plank) mix(base, argb(0x0E0C10), 0.6) else mix(base, argb(0x5E5864), rnd(x / 3, y, 3) * 0.25)
            }
            for (side in listOf(-1, 1)) {
                // rail and posts
                for (t in 0..60) {
                    val d = t / 60.0
                    val y = r0 + 4 + (h - r0 - 4) * d
                    val x = bx + side * (10 + 50 * d)
                    val top = y - (6 + 40 * d)
                    set(x.toInt(), top.toInt(), woodLit); set(x.toInt(), top.toInt() + 1, wood)
                }
                for (k in 0..5) {
                    val d = (k / 5.0).pow(1.6)
                    val y = r0 + 4 + (h - r0 - 4) * d; val x = bx + side * (10 + 50 * d)
                    rect(x - 0.5 - d * 2, y - (6 + 40 * d), x + 0.5 + d * 2, y, wood)
                }
            }
            grassFront(11)
        }

        // ---------------------------------------------------------- 69.intro.3: the sleeping square, torches at the temple

        fun square() {
            val hz = (h * 0.38).toInt()
            sky(hz, w * 0.82, h * 0.1, full = false)
            // cobbles in perspective, faintly lit by the moon
            for (y in hz until h) for (x in 0 until w) {
                val d = (y - hz) / (h - hz).toDouble()
                val sz = 1.5 + d * 6
                val cx = floor((x - w / 2.0) / (sz * 1.4) + (floor(y / sz) % 2) * 0.5)
                val gap = ((x - w / 2.0) / (sz * 1.4) + (floor(y / sz) % 2) * 0.5 - cx) < 0.14 + rnd(cx.toInt(), (y / sz).toInt(), 6) * 0.1 || (y / sz - floor(y / sz)) < 0.18
                val base = mix(argb(0x3A3E4A), argb(0x16181E), d)
                set(x, y, if (gap) mix(base, dark, 0.6) else mix(base, argb(0x4E5262), rnd(cx.toInt(), (y / sz).toInt(), 2) * 0.3 * (1 - d)))
            }
            // houses round the square, dark; the temple to the right with its tower
            for ((i, x) in listOf(0.0, 0.17).withIndex()) {
                rect(w * x, hz - 34.0, w * x + 44, hz + 4.0, argb(0x101420))
                poly(roof, w * x - 3, hz - 34.0, w * x + 22, hz - 52.0, w * x + 47, hz - 34.0)
                if (i == 1) { rect(w * x + 10, hz - 22.0, w * x + 15, hz - 15.0, mix(warm, dark, 0.55)) }
            }
            val tx = w * 0.56
            for (y in (hz - 46) until hz + 6) for (x in tx.toInt() until (tx + 90).toInt()) set(x, y, mix(argb(0x1E222E), stone, rnd(x / 6, y / 3, 11) * 0.5))
            poly(roof, tx - 4, hz - 46.0, tx + 45, hz - 70.0, tx + 94, hz - 46.0)
            rect(tx + 62, hz - 96.0, tx + 82, hz - 40.0, mix(stone, dark, 0.2))
            poly(roof, tx + 59, hz - 96.0, tx + 72, hz - 118.0, tx + 85, hz - 96.0)
            rect(tx + 68, hz - 86.0, tx + 76, hz - 74.0, dark)
            // the door with a pointed arch, ajar and warm
            poly(argb(0x0A0A10), tx + 30, hz + 6.0, tx + 30, hz - 18.0, tx + 36, hz - 26.0, tx + 42, hz - 18.0, tx + 42, hz + 6.0)
            rect(tx + 36, hz - 18.0, tx + 39, hz + 6.0, mix(warm, warmDeep, 0.4))
            // torches: two by the door, one carried, their light on the stone and the cobbles
            val torches = listOf(tx + 22 to hz - 14.0, tx + 50 to hz - 14.0, tx + 4 to hz + 4.0)
            for ((x, y) in torches) {
                glow(x, y + 10, 16.0, warmDeep, 0.35, 0.8)
                glow(x, y, 6.0, warm, 0.7)
                rect(x - 0.5, y, x + 1.5, y + 10, wood)
                poly(warm, x - 2, y, x + 0.5, y - 6, x + 3, y)
                set(x.toInt(), y.toInt() - 2, Pal.WHITE)
            }
            // shadows of people by the torches, long and still
            for ((k, x) in listOf(tx + 8, tx + 14, tx - 4).withIndex()) {
                val base = hz + 8.0 + k
                // the shadow toward the viewer, the torches behind them
                poly(argb(0x0A0B10), x - 1, base, x + 5, base, x + 7 - k * 3.0, base + 12, x + 1 - k * 3.0, base + 12)
                poly(argb(0x06070C), x - 1.5, base, x + 5.5, base, x + 4, base - 9, x + 3.5, base - 12, x + 0.5, base - 12, x, base - 9)
                for (y in (base - 15).toInt()..(base - 11).toInt()) for (xx in x.toInt()..(x + 4).toInt()) if ((xx + 0.5 - x - 2).pow(2) + (y + 0.5 - base + 13).pow(2) < 4.5) set(xx, y, argb(0x06070C))
                // the torchlight on the edge of the hood
                set((x + 3.5).toInt(), (base - 13).toInt(), mix(warmDeep, dark, 0.3))
            }
            // the well, near and dark, its rim lit by the moon
            val wx = w * 0.18; val wy = h * 0.82
            for (y in (wy - 16).toInt()..wy.toInt()) for (x in (wx - 26).toInt()..(wx + 26).toInt()) {
                val q = ((x - wx) / 26.0).pow(2)
                if (q < 1) set(x, y, if (y < wy - 13) stoneLit else mix(stone, dark, (y - wy + 13) / 13.0 * 0.6 + rnd(x / 3, y / 2, 4) * 0.2))
            }
            rect(wx - 24, wy - 50, wx - 20, wy - 14, wood); rect(wx + 20, wy - 50, wx + 24, wy - 14, wood)
            poly(roof, wx - 32, wy - 46, wx, wy - 64, wx + 32, wy - 46, wx + 28, wy - 42, wx - 28, wy - 42)
            grassFront(13)
        }

        // ---------------------------------------------------------- 69.intro.4: the inn's warm window, the door opening

        fun inn() {
            val hz = (h * 0.16).toInt()
            sky(hz, w * 0.88, h * 0.06)
            // the facade fills the picture: stone below, timber above, the roof cut by the top
            val gy = h * 0.84
            rect(0.0, hz.toDouble(), w.toDouble(), gy, argb(0x1E1A22))
            for (y in hz until gy.toInt()) for (x in 0 until w) {
                val stoneRow = y > h * 0.55
                val c = if (stoneRow) {
                    val bh = 7; val bw = 14; val off = (y / bh % 2) * bw / 2
                    if (y % bh == 0 || (x + off) % bw == 0) argb(0x0E0C12) else mix(stone, argb(0x242632), rnd((x + off) / bw, y / bh, 3) * 0.5)
                } else mix(argb(0x2C2830), argb(0x221E26), rnd(x / 4, y / 4, 5))
                set(x, y, c)
            }
            // timber frame
            for (bx in listOf(0.0, 0.3, 0.62, 0.94)) rect(w * bx, hz.toDouble(), w * bx + 6, h * 0.56, wood)
            rect(0.0, h * 0.54, w.toDouble(), h * 0.565, wood)
            rect(0.0, hz.toDouble(), w.toDouble(), hz + 5.0, wood)
            for ((a, b) in listOf(0.0 to 0.3, 0.62 to 0.94)) for (t in 0..40) {
                val x = w * (a + (b - a) * t / 40.0); val y = hz + 5 + (h * 0.54 - hz - 5) * t / 40.0
                rect(x, y, x + 4, y + 2, wood)
            }
            // the warm window, panes and a figure's shadow behind it
            val wx = w * 0.38; val wy = h * 0.26
            glow(wx + 26, wy + 20, 22.0, warmDeep, 0.35)
            rect(wx - 3, wy - 3, wx + 55, wy + 43, wood)
            for (y in wy.toInt() until (wy + 40).toInt()) for (x in wx.toInt() until (wx + 52).toInt()) {
                val pane = ((x - wx).toInt() % 13 == 0) || ((y - wy).toInt() % 20 == 0)
                val inside = mix(warm, warmDeep, ((y - wy) / 40.0) * 0.6 + rnd(x / 3, y / 3, 7) * 0.15)
                set(x, y, if (pane) argb(0x2A1A10) else inside)
            }
            rect(wx + 16, wy + 14, wx + 24, wy + 40, mix(warmDeep, dark, 0.45))
            for (y in (wy + 7).toInt()..(wy + 14).toInt()) for (x in (wx + 15).toInt()..(wx + 25).toInt()) if ((x - wx - 20).pow(2) + (y - wy - 11).pow(2) < 14) set(x, y, mix(warmDeep, dark, 0.45))
            // the door ajar, light spilling out and over the ground
            val dx = w * 0.70; val dTop = h * 0.50
            rect(dx - 4, dTop - 4, dx + 44, gy, wood)
            rect(dx, dTop, dx + 40, gy, argb(0x14100E))
            poly(warm, dx + 6, dTop, dx + 40, dTop, dx + 40, gy, dx + 6, gy) { x, y -> mix(warm, warmDeep, (y - dTop) / (gy - dTop) * 0.5 + (x - dx) / 40.0 * 0.2) }
            poly(woodLit, dx, dTop, dx + 6, dTop + 2, dx + 6, gy, dx, gy)
            // the hostess in the doorway, a shape against the light
            poly(argb(0x2A1810), dx + 18, gy, dx + 34, gy, dx + 31, dTop + 24, dx + 21, dTop + 24)
            for (y in (dTop + 12).toInt()..(dTop + 25).toInt()) for (x in (dx + 19).toInt()..(dx + 33).toInt()) if ((x - dx - 26).pow(2) + ((y - dTop - 18) * 1.1).pow(2) < 30) set(x, y, argb(0x2A1810))
            // the sign of the Sleeping Griffin on its bracket
            rect(w * 0.10, h * 0.30, w * 0.24, h * 0.31, dark)
            rect(w * 0.12, h * 0.31, w * 0.22, h * 0.40, woodLit)
            rect(w * 0.125, h * 0.317, w * 0.215, h * 0.393, wood)
            poly(argb(0x8A7048), w * 0.14, h * 0.38, w * 0.16, h * 0.34, w * 0.19, h * 0.33, w * 0.20, h * 0.36, w * 0.18, h * 0.38)
            // the ground: packed earth, the door's light laid on it
            for (y in gy.toInt() until h) for (x in 0 until w) {
                val d = (y - gy) / (h - gy)
                set(x, y, mix(argb(0x22202A), argb(0x0E0E14), d + rnd(x / 3, y / 2, 9) * 0.2))
            }
            for (y in gy.toInt() until h) {
                val d = (y - gy) / (h - gy)
                for (x in (dx + 6 - d * 20).toInt() until (dx + 40 + d * 30).toInt()) blend(x, y, warm, 0.55 * (1 - d))
            }
            glow(dx + 22, gy, 26.0, warmDeep, 0.25, 1.6)
            // a barrel by the wall
            val bx = w * 0.08; val by = gy + 6
            for (y in (by - 30).toInt()..by.toInt()) {
                val t = (y - by + 30) / 30.0
                val half = 12 + sin(t * Math.PI) * 2.5
                for (x in (bx - half).toInt()..(bx + half).toInt()) set(x, y, if (abs(t - 0.2) < 0.04 || abs(t - 0.8) < 0.04) argb(0x2E3038) else mix(woodLit, wood, (x - bx + half) / (2 * half)))
            }
            grassFront(17)
        }
    }

}
