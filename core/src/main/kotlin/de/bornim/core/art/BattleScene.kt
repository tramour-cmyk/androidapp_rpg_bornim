package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Forest battle scenes in the new style: a ground plane with depth instead of platforms, layered
 * backdrops, light and weather by time of day, and several kinds of places so fights do not all
 * look the same. Coordinates are art pixels; the scene is drawn for any size, laid out by fractions.
 */
object BattleScene {
    /** Kinds of places in the woods. */
    enum class Spot { CLEARING, EDGE, POND, FALLEN_TREE, ROCKS, STONE_CIRCLE }

    enum class Light { DAY, DUSK, NIGHT }

    /** Where the foe stands and where the hero stands, as fractions of the scene. */
    const val FOE_X = 0.63f
    const val FOE_Y = 0.60f
    const val HERO_X = 0.28f
    const val HERO_Y = 0.985f

    /** Width the scene is designed for; the app picks a whole-number zoom close to it. */
    const val DESIGN_W = 270

    /** The kind of place for a fight at ([x], [y]) on [map]: water and rocks nearby count, otherwise it varies by area. */
    fun spotFor(map: MapDef, x: Int, y: Int): Spot {
        fun near(t: Tile, r: Int) = (-r..r).any { dy -> (-r..r).any { dx -> map.tile(x + dx, y + dy) == t } }
        if (near(Tile.WATER, 4)) return Spot.POND
        if (near(Tile.ROCK, 3)) return Spot.ROCKS
        val h = hash(x / 5, y / 5, map.id.hashCode()) % 100
        return when {
            h < 30 -> Spot.CLEARING
            h < 58 -> Spot.EDGE
            h < 84 -> Spot.FALLEN_TREE
            else -> Spot.STONE_CIRCLE
        }
    }

    /** A number for small variations (tree positions, mirrored props) that stays the same within a few tiles. */
    fun seedFor(x: Int, y: Int): Int = hash(x / 3, y / 3, 17) % 1000

    private val cache = object : LinkedHashMap<String, PixelImage>(8, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 6
    }

    fun forest(w: Int, h: Int, spot: Spot, light: Light, deep: Boolean, seed: Int): PixelImage {
        val key = "$w/$h/$spot/$light/$deep/$seed"
        synchronized(cache) { cache[key]?.let { return it } }
        val img = Painter(w, h, spot, light, deep, seed).paint()
        synchronized(cache) { cache[key] = img }
        return img
    }

    // ---------------------------------------------------------------- noise helpers

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

    private fun shade(r: Ramp, t: Double, x: Int, y: Int): Int {
        val steps = r.size - 1
        return r[floor(t * steps + dith(x, y) * 0.9 - 0.45 + 0.5).toInt().coerceIn(0, steps)]
    }

    /** Colors of one time of day. */
    private class Palette(val light: Light, deep: Boolean) {
        val day = light == Light.DAY
        val dusk = light == Light.DUSK
        val night = light == Light.NIGHT
        fun pick(d: Int, e: Int, n: Int) = argb(if (day) d else if (dusk) e else n)
        val skyTop = pick(0x4A7CBC, 0x2A2A52, 0x070B1E)
        val skyMid = pick(0x9CC0DE, 0x9A5A72, 0x16203E)
        val skyLow = pick(0xE8EAD8, 0xF4AE6A, 0x2E3A5A)
        val glow = pick(0xFFF8E4, 0xFFD49A, 0xC8D4F0)
        val cloudLit = pick(0xFFFFFF, 0xFFC89A, 0x4A5470)
        val cloudShade = pick(0xB8C6DA, 0x7A5070, 0x1C2238)
        val haze = pick(0xB2C4D6, 0xB07080, 0x26304C)
        val mtn = pick(0x7A92AE, 0x6A4A6A, 0x1A2238)
        val ridge = pick(0xD8E4F0, 0xF4A878, 0x3A4668)
        val rowFar = if (day) Triple(argb(0x5E8278), argb(0x7A9E8A), argb(0x4A6A66)) else if (dusk) Triple(argb(0x4A3C5A), argb(0x6A4E62), argb(0x382E48)) else Triple(argb(0x18203A), argb(0x243050), argb(0x10162C))
        val rowNear = if (day) Triple(argb(0x37604A), argb(0x5A8458), argb(0x284638)) else if (dusk) Triple(argb(0x2E2A3C), argb(0x52404E), argb(0x201C2C)) else Triple(argb(0x0E1628), argb(0x1C2840), argb(0x0A101E))
        val grassFar = pick(0x92AE6C, 0x6E6A50, 0x2A3A44)
        val grassMid = pick(0x5E8C40, 0x4E5636, 0x1E2C32)
        val grassNear = pick(0x2A4C22, 0x232C1A, 0x0E161A)
        val grassHi = pick(0xD0E890, 0xC8A878, 0x5A7088)
        val pool = pick(0xF6F0A8, 0xF4A462, 0x8EA8D8)
        val poolA = if (day) 0.2 else if (dusk) 0.34 else 0.22
        val pathNear = pick(0xBCA27C, 0x8C6C56, 0x3A4252)
        val pathFar = pick(0x846A4C, 0x4A382E, 0x1C2230)
        val bark = pick(0x5E4636, 0x463632, 0x1E1C26)
        val leaf = pick(0x3A6A34, 0x34442E, 0x16242A)
        val moss = pick(0x5A7A30, 0x3A4A2A, 0x1E3028)
        val stone = pick(0x8C8A82, 0x6E5E62, 0x2E3442)
        val water = pick(0x4A7898, 0x6A5070, 0x10203A)
        val waterHi = pick(0xC8E0F0, 0xF4B080, 0x7088B8)
        val fern = pick(0x1A3016, 0x121810, 0x060A0C)
        val fernLit = pick(0x3A5C28, 0x2C3820, 0x142030)
        val shaft = pick(0xFFFCE4, 0xFFC488, 0xA8B8E8)
        val shaftA = if (day) 0.15 else if (dusk) 0.2 else 0.08
        val vignette = pick(0x08120A, 0x100818, 0x020408)
        val vignetteA = if (night) 0.75 else 0.55
        val fog = if (deep) pick(0xC8D4CC, 0xC09AA0, 0x2A3448) else 0
    }

    private class Painter(val w: Int, val h: Int, val spot: Spot, val light: Light, val deep: Boolean, val seed: Int) {
        val img = PixelImage(w, h)
        val p = Palette(light, deep)
        val horizon = (h * if (spot == Spot.EDGE || deep) 0.36 else 0.40).toInt()
        /** Props go to the left or the right, mirrored by the seed. */
        val flip = seed % 2 == 1
        fun fx(f: Double) = (if (flip) 1 - f else f) * w
        /** Props stand left of the foe, a little shifted by the seed. */
        fun px(f: Double) = (f + (seed % 7 - 3) * 0.008) * w
        /** A height in the ground plane: 0 at the horizon, 1 at the bottom. */
        fun gy(d: Double) = horizon + (h - horizon) * d

        fun set(x: Int, y: Int, c: Int) = img.set(x, y, c)
        fun blend(x: Int, y: Int, c: Int, a: Double) {
            if (x in 0 until w && y in 0 until h) img.set(x, y, mix(img[x, y], c, a.coerceIn(0.0, 1.0)))
        }
        /** 0 at the horizon, 1 at the bottom edge. */
        fun depth(y: Int) = ((y - horizon) / (h - horizon).toDouble()).coerceIn(0.0, 1.0)

        fun paint(): PixelImage {
            sky()
            if (!deep) mountains()
            forestEdge()
            ground()
            when (spot) {
                Spot.POND -> pond()
                Spot.FALLEN_TREE -> fallenTree()
                Spot.ROCKS -> rocks()
                Spot.STONE_CIRCLE -> stoneCircle()
                else -> {}
            }
            path()
            tufts()
            if (deep) mushrooms()
            frame()
            if (deep) canopy()
            shafts()
            if (deep) fog()
            if (p.night) fireflies() else motes()
            ferns()
            vignette()
            return img
        }

        // ------------------------------------------------------------ sky

        fun sky() {
            for (y in 0 until horizon) for (x in 0 until w) {
                val t = y / horizon.toDouble() + (dith(x, y) - 0.5) * 0.04
                set(x, y, if (t < 0.55) mix(p.skyTop, p.skyMid, t / 0.55) else mix(p.skyMid, p.skyLow, (t - 0.55) / 0.45))
            }
            val sunX = fx(if (p.dusk) 0.36 else if (p.night) 0.78 else 0.26)
            val sunY = horizon * (if (p.dusk) 0.72 else if (p.night) 0.22 else 0.36)
            for (y in 0 until horizon) for (x in 0 until w) {
                val d = sqrt((x - sunX).pow(2) + ((y - sunY) * 1.3).pow(2))
                blend(x, y, p.glow, exp(-d / (if (p.dusk) 42.0 else 30.0)) * (if (p.dusk) 0.8 else if (p.night) 0.35 else 0.55))
            }
            if (p.dusk) for (y in 0 until horizon) for (x in 0 until w) {
                if ((x - sunX).pow(2) + (y - sunY).pow(2) < 64) set(x, y, argb(0xFFEAC0))
            }
            if (p.night) {
                for (i in 0 until w * horizon / 90) {
                    val x = (rnd(i, 1, seed + 3) * w).toInt(); val y = (rnd(i, 2, seed + 3) * horizon * 0.9).toInt()
                    set(x, y, if (i % 9 == 0) Pal.WHITE else argb(0xA8B4D8))
                }
                // crescent moon
                for (y in (sunY - 8).toInt()..(sunY + 8).toInt()) for (x in (sunX - 8).toInt()..(sunX + 8).toInt()) {
                    val d1 = (x + 0.5 - sunX).pow(2) + (y + 0.5 - sunY).pow(2)
                    val d2 = (x + 0.5 - sunX - 3.5).pow(2) + (y + 0.5 - sunY + 2.5).pow(2)
                    if (d1 <= 49 && d2 > 36) set(x, y, argb(0xF0ECD8))
                }
            }
            clouds()
        }

        fun clouds() {
            val list = listOf(Triple(0.64, 0.25, 1.0), Triple(0.88, 0.47, 0.7), Triple(0.42, 0.52, 0.55), Triple(0.15, 0.2, 0.6))
            for ((i, c) in list.withIndex()) {
                if (rnd(i, seed, 5) < 0.3) continue
                val cx = fx(c.first); val cy = horizon * c.second; val size = c.third * w / 270.0
                for (k in 0 until 7) {
                    val px = cx + (k - 3) * 9 * size + (rnd(k, i, seed) - 0.5) * 6
                    val py = cy - sin(k / 6.0 * PI) * 7 * size
                    val r = (7 + 5 * sin(k / 6.0 * PI)) * size
                    for (y in (py - r).toInt()..(py + r * 0.7).toInt()) for (x in (px - r).toInt()..(px + r).toInt()) {
                        val q = ((x - px) / r).pow(2) + ((y - py) / r).pow(2)
                        if (q > 1 || y !in 0 until horizon || x !in 0 until w) continue
                        val l = 0.5 - (y - py) / r * 0.5
                        val col = mix(p.cloudShade, p.cloudLit, (l + dith(x, y) * 0.25).coerceIn(0.0, 1.0))
                        set(x, y, mix(img[x, y], col, if (q > 0.85) 0.5 else 0.92))
                    }
                }
            }
        }

        fun mountains() {
            for (x in 0 until w) {
                val top = horizon - 50 + 16 * vnoise(x / 30.0, 5 + seed) + 6 * vnoise(x / 9.0, 6) - 14 * exp(-((x - fx(0.74)) / 22.0).pow(2))
                for (y in top.toInt() until horizon) set(x, y, mix(p.mtn, p.haze, ((y - top) / 34.0).coerceIn(0.0, 1.0) * 0.8))
                set(x, top.toInt(), mix(p.mtn, p.ridge, 0.55))
            }
        }

        // ------------------------------------------------------------ trees

        fun pine(cx: Double, baseY: Double, ht: Double, col: Int, lit: Int, dark: Int) {
            for (t in 0 until 4) {
                val top = baseY - ht + t * ht * 0.2
                val bot = top + ht * 0.38
                for (y in top.toInt()..bot.toInt()) {
                    val u = (y - top) / (bot - top)
                    val half = (1 + t * 0.5) * ht * 0.13 * u + 0.5
                    for (x in (cx - half).toInt()..(cx + half).toInt()) {
                        if (x !in 0 until w || y !in 0 until h) continue
                        val side = (x - cx) / half
                        set(x, y, when {
                            u > 0.85 && rnd(x, y, 5) < 0.5 -> dark
                            side < -0.35 -> lit
                            side > 0.45 -> dark
                            else -> col
                        })
                    }
                }
            }
        }

        fun broadleaf(cx: Double, baseY: Double, r: Double, col: Int, lit: Int, dark: Int, s: Int) {
            for (k in 0 until 9) {
                val px = cx + (rnd(k, 1, s) - 0.5) * r * 1.3
                val py = baseY - r * 1.1 - rnd(k, 2, s) * r * 0.9
                val rr = r * (0.45 + rnd(k, 3, s) * 0.3)
                for (y in (py - rr).toInt()..(py + rr).toInt()) for (x in (px - rr).toInt()..(px + rr).toInt()) {
                    val dx = (x - px) / rr; val dy = (y - py) / rr
                    if (dx * dx + dy * dy > 1 || x !in 0 until w || y !in 0 until h) continue
                    val l = 0.55 - (dx * 0.6 + dy * 0.8) * 0.45 + (rnd(x / 2, y / 2, s) - 0.5) * 0.35
                    set(x, y, if (l > 0.72) lit else if (l < 0.32) dark else col)
                }
            }
        }

        fun forestEdge() {
            val rows = listOf(p.rowFar, p.rowNear)
            // undergrowth so no sky shows between the trunks
            for (x in 0 until w) {
                val top = horizon - 10 + 5 * vnoise(x / 6.0, 44 + seed)
                for (y in top.toInt()..horizon + 5) set(x, y, mix(p.rowNear.third, p.rowFar.first, ((horizon + 5 - y) / 16.0).coerceIn(0.0, 0.5)))
            }
            val big = if (spot == Spot.EDGE || deep) 1.5 else 1.0
            for ((ri, row) in rows.withIndex()) {
                var x = -10.0
                var k = 0
                while (x < w + 10) {
                    val ht = (if (ri == 0) 22.0 else 34.0) * big * (0.75 + rnd(k, ri, 40 + seed) * 0.5)
                    val baseY = horizon + (if (ri == 0) -2.0 else 4.0)
                    if (rnd(k, ri, 41 + seed) < (if (deep) 0.15 else 0.35)) broadleaf(x, baseY, ht * 0.42, row.first, row.second, row.third, k * 7 + ri + seed)
                    else pine(x, baseY, ht, row.first, row.second, row.third)
                    x += ((if (ri == 0) 6.0 else 9.0) + rnd(k, ri, 42 + seed) * 5) * (if (deep) 0.8 else 1.0)
                    k++
                }
            }
            // forest edge: a few big trees near the clearing on one side
            if (spot == Spot.EDGE) for (i in 0 until 4) {
                val cx = fx(0.06 + i * 0.09 + rnd(i, 3, seed) * 0.03)
                broadleaf(cx, horizon + 10.0 + i * 2, 26.0 - i * 3, p.rowNear.first, p.rowNear.second, p.rowNear.third, 90 + i + seed)
                for (y in horizon - 4 until horizon + 12 + i * 2) for (x in (cx - 2).toInt()..(cx + 2).toInt()) set(x, y, mix(p.bark, Pal.BLACK, 0.3))
            }
        }

        // ------------------------------------------------------------ ground

        fun ground() {
            for (y in horizon + 4 until h) {
                val d = depth(y)
                for (x in 0 until w) {
                    var c = if (d < 0.45) mix(p.grassFar, p.grassMid, d / 0.45) else mix(p.grassMid, p.grassNear, (d - 0.45) / 0.55)
                    val patch = vnoise(x / (18.0 + d * 30), (y / (4.0 + d * 10)).toInt() + 70 + seed)
                    c = mix(c, if (patch > 0.5) mix(c, Pal.WHITE, 0.15) else mix(c, Pal.BLACK, 0.2), abs(patch - 0.5) * 1.2)
                    val streak = rnd(x, (y / (1 + d * 4)).toInt(), 7)
                    if (streak < 0.14) c = mix(c, Pal.BLACK, 0.22) else if (streak > 0.9) c = mix(c, p.grassHi, 0.3)
                    set(x, y, c)
                }
            }
            for (y in horizon until horizon + 14) for (x in 0 until w) blend(x, y, argb(0x0C1810), 0.4 * (1 - (y - horizon) / 14.0))
            // a pool of light where the foe stands
            val fxp = w * FOE_X; val fyp = h * FOE_Y
            for (y in horizon until h) for (x in 0 until w) {
                val d = ((x - fxp) / (w * 0.39)).pow(2) + ((y - fyp) / (h * 0.11)).pow(2)
                blend(x, y, p.pool, exp(-d) * p.poolA)
            }
        }

        fun path() {
            val top = horizon + 4
            for (y in top until h) {
                val d = depth(y)
                val cx = w * (0.59 - d * 0.245) + 9 * sin(d * 5.0 + seed)
                val half = 2.5 + d * d * w * 0.155 + 3 * vnoise(y / 6.0, 9 + seed)
                for (x in (cx - half - 2).toInt()..(cx + half + 2).toInt()) {
                    if (x !in 0 until w) continue
                    val e = 1 - abs(x - cx) / half
                    if (e < -0.05) continue
                    var c = mix(p.pathNear, p.pathFar, (1 - d) * 0.3 + d * 0.55)
                    val n = rnd(x, (y / (1 + d * 2)).toInt(), 13)
                    if (n < 0.1) c = mix(c, Pal.BLACK, 0.25) else if (n > 0.93) c = mix(c, Pal.WHITE, 0.2)
                    if (d > 0.3 && abs(abs(x - cx) - half * 0.45) < 0.6 + d) c = mix(c, Pal.BLACK, 0.15)
                    blend(x, y, c, if (e < 0.08) 0.55 else if (spot == Spot.POND && d < 0.5) 0.0 else 1.0)
                }
            }
        }

        fun tufts() {
            for (i in 0 until w * h / 800) {
                val y = horizon + 8 + ((h - horizon - 10) * rnd(i, 1, 30 + seed).pow(0.75)).toInt()
                val x = (w * rnd(i, 2, 30 + seed)).toInt()
                val d = depth(y)
                val size = 1 + d * 5
                if (i % 11 == 0) {
                    val r = size * 0.9
                    for (yy in -r.toInt()..0) for (xx in (-r * 1.4).toInt()..(r * 1.4).toInt()) {
                        if ((xx / (r * 1.4)).pow(2) + (yy / r).pow(2) > 1) continue
                        set(x + xx, y + yy, if (yy < -r * 0.5 && xx < 0) mix(p.stone, Pal.WHITE, 0.35) else if (yy > -1) mix(p.stone, Pal.BLACK, 0.45) else p.stone)
                    }
                } else {
                    val col = mix(mix(p.grassNear, p.grassMid, 0.5), p.grassNear, d * 0.5)
                    for (b in -3..3) {
                        val len = size * (1.3 + rnd(i, b, 31) * 1.2)
                        val lean = b * 0.3 + (rnd(i, 9, 32) - 0.5)
                        for (k in 0 until len.toInt()) set(x + b + (k * lean * 0.3).toInt(), y - k, if (k > len * 0.7 && b == -1) mix(col, p.grassHi, 0.5) else col)
                    }
                }
            }
        }

        // ------------------------------------------------------------ places

        fun pond() {
            val cx = px(0.2); val cy = gy(0.3)
            val rx = w * 0.24; val ry = (h - horizon) * 0.11
            for (y in (cy - ry - 2).toInt()..(cy + ry + 2).toInt()) for (x in (cx - rx - 3).toInt()..(cx + rx + 3).toInt()) {
                val wob = 1 + 0.12 * sin(x / 5.0 + seed) + 0.08 * sin(y * 1.3)
                val q = ((x - cx) / (rx * wob)).pow(2) + ((y - cy) / ry).pow(2)
                if (q > 1.25 || x !in 0 until w || y !in 0 until h) continue
                if (q > 1) { set(x, y, mix(p.pathFar, Pal.BLACK, 0.2)); continue } // muddy bank
                var c = mix(p.water, p.skyLow, ((cy - y) / ry * 0.3 + 0.3).coerceIn(0.0, 0.6))
                if (rnd(x / 3, y, 61) < 0.07) c = p.waterHi
                set(x, y, c)
            }
            // reeds along the far bank
            for (i in 0 until 16) {
                val x = (cx - rx + rnd(i, 1, 62) * rx * 2).toInt()
                val base = (cy - ry * 0.8 + rnd(i, 2, 62) * 3).toInt()
                val len = 5 + (rnd(i, 3, 62) * 6).toInt()
                for (k in 0 until len) set(x + if (k > len - 2) 1 else 0, base - k, if (k == len - 1) mix(p.pathFar, Pal.BLACK, 0.4) else mix(p.grassMid, Pal.BLACK, 0.25))
            }
        }

        fun fallenTree() {
            val y0 = gy(0.24)
            val x0 = px(-0.02); val x1 = px(0.4)
            val r = 8.5
            val bark = Ramp.of(p.bark)
            val steps = abs(x1 - x0).toInt()
            for (i in 0..steps) {
                val t = i / steps.toDouble()
                val x = x0 + (x1 - x0) * t
                val yc = y0 + t * 6
                val rr = r * (1 - t * 0.25)
                for (y in (yc - rr).toInt()..(yc + rr).toInt()) {
                    val u = (y - yc) / rr
                    val l = 0.75 - u * 0.5 + (rnd(x.toInt(), y / 2, 71) - 0.5) * 0.3
                    val moss = u < -0.3 && rnd(x.toInt() / 2, y, 72) < 0.6
                    set(x.toInt(), y, if (moss) mix(shade(bark, l, x.toInt(), y), p.moss, 0.7) else shade(bark, l.coerceIn(0.0, 1.0), x.toInt(), y))
                }
            }
            // broken end with rings, and a stub of a branch
            val ex = x1; val ey = y0 + 6
            for (y in (ey - r * 0.75).toInt()..(ey + r * 0.75).toInt()) for (x in (ex - 2).toInt()..(ex + 2).toInt()) {
                val d = sqrt(((x - ex) / 2.0).pow(2) + ((y - ey) / (r * 0.75)).pow(2))
                if (d <= 1) set(x, y, if ((d * 4).toInt() % 2 == 0) argb(0xB89A6A) else argb(0x8A6E48))
            }
            val bxp = (x0 + (x1 - x0) * 0.4).toInt()
            for (k in 0 until 8) set(bxp + k / 3, (y0 - r - k).toInt(), mix(p.bark, Pal.BLACK, 0.2))
            for (x in x0.toInt().coerceAtMost(x1.toInt())..x0.toInt().coerceAtLeast(x1.toInt())) blend(x, (y0 + r + 1).toInt(), Pal.BLACK, 0.35)
        }

        fun boulder(cx: Double, by: Double, r: Double, s: Int) {
            val stone = Ramp.of(p.stone)
            for (y in (by - r * 1.4).toInt()..by.toInt()) for (x in (cx - r * 1.3).toInt()..(cx + r * 1.3).toInt()) {
                val dx = (x - cx) / (r * 1.3); val dy = (y - (by - r * 0.6)) / (r * 0.85)
                val wob = 1 + 0.15 * sin(atan(dx, dy) * 3 + s)
                val q = dx * dx + dy * dy
                if (q > wob || x !in 0 until w || y !in 0 until h) continue
                var l = 0.7 - dx * 0.35 - dy * 0.45 + (rnd(x, y, s) - 0.5) * 0.15
                if (rnd(x / 2, y / 2, s + 1) < 0.08) l -= 0.3
                val c = shade(stone, l.coerceIn(0.0, 1.0), x, y)
                set(x, y, if (dy < -0.4 && rnd(x / 2, y, s + 2) < 0.4) mix(c, p.moss, 0.5) else c)
            }
            for (x in (cx - r * 1.3).toInt()..(cx + r * 1.3).toInt()) blend(x, by.toInt() + 1, Pal.BLACK, 0.35)
        }

        private fun atan(x: Double, y: Double) = kotlin.math.atan2(y, x)

        fun rocks() {
            val by = gy(0.3)
            boulder(px(0.17), by, 19.0, 81 + seed)
            boulder(px(0.34), by + 6, 11.0, 82 + seed)
            boulder(px(0.05), by + 9, 10.0, 83 + seed)
            boulder(px(0.88), gy(0.08), 7.0, 84 + seed)
        }

        fun stoneCircle() {
            val stone = Ramp.of(mix(p.stone, Pal.BLACK, 0.1))
            val cx = px(0.22); val cy = gy(0.2)
            for (i in 0 until 6) {
                val a = PI * (0.1 + i * 0.16)
                val sx = cx + cos(a) * w * 0.2; val sy = cy - sin(a) * (h - horizon) * 0.1 + 6
                val near = (sy - horizon) / (h - horizon).toDouble()
                val sh = (20 + rnd(i, 1, 85) * 12) * (0.7 + near * 1.6); val sw = (3.5 + rnd(i, 2, 85) * 2) * (0.7 + near * 1.6)
                val broken = rnd(i, 3, 85) < 0.3
                for (y in (sy - (if (broken) sh * 0.5 else sh)).toInt()..sy.toInt()) for (x in (sx - sw).toInt()..(sx + sw).toInt()) {
                    val u = (x - sx) / sw
                    val l = 0.65 - u * 0.4 + (rnd(x, y / 2, 86) - 0.5) * 0.2
                    set(x, y, shade(stone, l.coerceIn(0.0, 1.0), x, y))
                }
                for (x in (sx - sw - 1).toInt()..(sx + sw + 1).toInt()) blend(x, sy.toInt() + 1, Pal.BLACK, 0.35)
            }
        }

        fun mushrooms() {
            for (i in 0 until 10) {
                val y = horizon + 10 + (rnd(i, 1, 95) * (h - horizon) * 0.5).toInt()
                val x = (rnd(i, 2, 95) * w).toInt()
                if (abs(x - w * FOE_X) < w * 0.2) continue
                val d = depth(y); val r = 1.5 + d * 3
                for (k in 0 until (r * 1.2).toInt()) set(x, y - k, argb(0xD8D0B8))
                for (yy in -r.toInt()..0) for (xx in (-r).toInt()..r.toInt()) {
                    if (xx * xx + yy * yy * 3 > r * r) continue
                    set(x + xx, (y - r * 1.2 + yy).toInt(), if (rnd(xx, yy, i) < 0.2) Pal.WHITE else if (p.night) argb(0x6A8AC8) else argb(0xA83A2A))
                }
            }
        }

        // ------------------------------------------------------------ framing and light

        fun frame() {
            fun trunk(cx: Double, r: Double, s: Int) {
                val bark = Ramp.of(p.bark)
                for (y in 0 until h - 6) {
                    val flare = if (y > h - 40) (y - (h - 40)) * 0.35 else 0.0
                    val rr = r + flare
                    for (x in (cx - rr).toInt()..(cx + rr).toInt()) {
                        if (x !in 0 until w) continue
                        val u = (x - cx) / rr
                        val nz = sqrt((1 - u * u).coerceAtLeast(0.0))
                        var l = 0.2 + 0.65 * (nz * 0.7 - u * 0.5).coerceAtLeast(0.0)
                        if (vnoise(x * 0.9 + vnoise(y / 14.0, s) * 3, s + 3) < 0.3) l -= 0.25
                        if (rnd(x, y / 2, s) < 0.08) l += 0.15
                        val c = shade(bark, l.coerceIn(0.0, 1.0), x, y)
                        val moss = u > 0.2 && y > h - 120 && rnd(x / 2, y / 3, s + 5) < 0.45
                        set(x, y, if (moss) mix(c, p.moss, 0.6) else c)
                    }
                }
            }
            trunk(4.0 + (seed % 5), 13.0, 41 + seed)
            trunk(w - 3.0 - (seed % 3), 14.0, 42 + seed)
            val leafR = Ramp.of(p.leaf)
            val count = if (deep) 700 else 420
            for (i in 0 until count) {
                val left = i % 2 == 0
                val spread = rnd(i, 1, 50 + seed)
                val reach = if (deep) 150.0 else 105.0
                val cx = if (left) spread * reach - 6 else w + 6 - spread * reach
                val cy = rnd(i, 2, 50 + seed).pow(1.6) * ((if (deep) 70 else 52) - spread * 30) - 6 + spread * 4
                val r = 2.0 + rnd(i, 3, 50) * 3.0
                for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in (cx - r).toInt()..(cx + r).toInt()) {
                    val dx = (x - cx) / r; val dy = (y - cy) / r
                    if (dx * dx + dy * dy > 1 || x !in 0 until w || y !in 0 until h) continue
                    val dp = 1 - cy / 60.0
                    set(x, y, shade(leafR, ((0.62 - (dx + dy) * 0.3) * (0.6 + dp * 0.4)).coerceIn(0.0, 1.0), x, y))
                }
            }
        }

        /** Deep forest: the crowns close overhead and the whole place lies in shadow. */
        fun canopy() {
            val dark = if (p.night) argb(0x04060A) else if (p.dusk) argb(0x140E18) else argb(0x0E1A10)
            for (y in 0 until h) for (x in 0 until w) blend(x, y, dark, 0.32)
            val leafR = Ramp.of(mix(p.leaf, Pal.BLACK, 0.25))
            for (i in 0 until w * 3) {
                val cx = rnd(i, 1, 70 + seed) * w
                val cy = rnd(i, 2, 70 + seed).pow(2.2) * horizon * 0.75 - 4
                val r = 2.5 + rnd(i, 3, 70) * 3.5
                for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in (cx - r).toInt()..(cx + r).toInt()) {
                    val dx = (x - cx) / r; val dy = (y - cy) / r
                    if (dx * dx + dy * dy > 1 || x !in 0 until w || y !in 0 until h) continue
                    set(x, y, shade(leafR, ((0.55 - (dx + dy) * 0.3) * (1 - cy / horizon * 0.5)).coerceIn(0.0, 1.0), x, y))
                }
            }
        }

        fun shafts() {
            for (y in 0 until h) for (x in 0 until w) {
                val sv = (if (flip) w - x else x) * 0.5 - y * 0.8 + 40 + seed
                val band = (sin(sv / 10.0) * 0.5 + 0.5).pow(8) * (sin(sv / 27.0 + 2) * 0.5 + 0.5)
                blend(x, y, p.shaft, band * (1 - y / h.toDouble()) * p.shaftA * (if (deep) 1.5 else 1.0))
            }
        }

        fun fog() {
            for (y in horizon - 30 until horizon + 50) for (x in 0 until w) {
                val f = exp(-((y - horizon - 6) / 22.0).pow(2)) * (0.3 + 0.25 * vnoise(x / 20.0 + y / 9.0, 99))
                blend(x, y, p.fog, f)
            }
        }

        fun motes() {
            for (i in 0 until 40) blend((rnd(i, 1, 90) * w).toInt(), (h * 0.1 + rnd(i, 2, 90) * h * 0.55).toInt(), p.shaft, 0.7)
        }

        fun fireflies() {
            for (i in 0 until 26) {
                val x = (rnd(i, 1, 91) * w).toInt(); val y = (horizon + rnd(i, 2, 91) * (h - horizon) * 0.7).toInt()
                set(x, y, argb(0xE8F890))
                for ((dx, dy) in listOf(-1 to 0, 1 to 0, 0 to -1, 0 to 1)) blend(x + dx, y + dy, argb(0xC8E870), 0.45)
            }
        }

        fun ferns() {
            for ((bxf, side) in listOf(0.05 to 1, 0.13 to 1, 0.94 to -1, 0.85 to -1, 0.74 to -1)) {
                val bx = bxf * w
                for (f in 0 until 6) {
                    val ang = -PI / 2 + side * (f - 1.5) * 0.32
                    val len = 30.0 + rnd(bx.toInt(), f, 62 + seed) * 26
                    for (k in 0 until len.toInt()) {
                        val t = k / len
                        val px = bx + cos(ang) * k + side * t * t * 12
                        val py = h + 6 + sin(ang) * k + t * t * 18
                        val lw = (1 - t) * 6 + 1
                        for (sgn in listOf(-1, 1)) for (q in 0 until lw.toInt()) {
                            if ((k + q) % 3 == 2) continue
                            set((px + sgn * q).toInt(), (py + q * 0.7).toInt(), if (sgn < 0) p.fernLit else p.fern)
                        }
                    }
                }
            }
        }

        fun vignette() {
            for (y in 0 until h) for (x in 0 until w) {
                val dx = (x - w / 2.0) / (w / 2.0); val dy = (y - h * 0.55) / (h * 0.62)
                val v = ((dx * dx + dy * dy) - 0.5).coerceAtLeast(0.0) * 0.5 + (if (p.night) 0.12 else 0.0)
                if (v > 0) blend(x, y, p.vignette, v.coerceAtMost(p.vignetteA))
            }
        }
    }
}
