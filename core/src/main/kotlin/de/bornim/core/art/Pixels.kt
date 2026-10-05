package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.max

/** An ARGB pixel image. Platform independent; the app turns it into a bitmap. */
class PixelImage(val width: Int, val height: Int, val pixels: IntArray = IntArray(width * height)) {
    operator fun get(x: Int, y: Int): Int = if (x in 0 until width && y in 0 until height) pixels[y * width + x] else 0

    fun set(x: Int, y: Int, c: Int) {
        if (x in 0 until width && y in 0 until height) pixels[y * width + x] = c
    }

    fun opaque(x: Int, y: Int) = (get(x, y) ushr 24) != 0

    fun copy() = PixelImage(width, height, pixels.copyOf())

    fun mirrored(): PixelImage {
        val out = PixelImage(width, height)
        for (y in 0 until height) for (x in 0 until width) out.set(width - 1 - x, y, get(x, y))
        return out
    }
}

/**
 * Small drawing toolkit for procedural pixel art.
 * Shapes are given in logical coordinates; with [k] > 1 they are rasterized at k-times the
 * resolution, which gives smoother curves and finer shading at the same proportions.
 */
class Pen(val img: PixelImage, val k: Int = 1) {
    /** Logical size. */
    val w get() = img.width / k
    val h get() = img.height / k

    fun raw(x: Int, y: Int, c: Int) = img.set(x, y, c)

    /** Whether the logical pixel (x, y) is painted. */
    fun isSet(x: Int, y: Int) = img.opaque(x * k + k / 2, y * k + k / 2)

    /** Color of the logical pixel (x, y). */
    fun at(x: Int, y: Int) = img[x * k + k / 2, y * k + k / 2]

    /** One logical pixel (a k×k block). */
    fun px(x: Int, y: Int, c: Int) {
        for (dy in 0 until k) for (dx in 0 until k) img.set(x * k + dx, y * k + dy, c)
    }

    fun fill(c: Int) = img.pixels.fill(c)

    /** Inclusive rectangle. */
    fun rect(x0: Int, y0: Int, x1: Int, y1: Int, c: Int) {
        for (y in minOf(y0, y1) * k until (maxOf(y0, y1) + 1) * k) for (x in minOf(x0, x1) * k until (maxOf(x0, x1) + 1) * k) img.set(x, y, c)
    }

    private inline fun forEllipse(cx: Double, cy: Double, rx: Double, ry: Double, f: (Int, Int, Double, Double) -> Unit) {
        val kx = cx * k; val ky = cy * k; val krx = rx * k; val kry = ry * k
        for (y in (ky - kry).toInt() - 1..(ky + kry).toInt() + 1) for (x in (kx - krx).toInt() - 1..(kx + krx).toInt() + 1) {
            val dx = (x + 0.5 - kx) / krx
            val dy = (y + 0.5 - ky) / kry
            if (dx * dx + dy * dy <= 1.0) f(x, y, dx, dy)
        }
    }

    fun ellipse(cx: Double, cy: Double, rx: Double, ry: Double, c: Int) = forEllipse(cx, cy, rx, ry) { x, y, _, _ -> img.set(x, y, c) }

    /** Ellipse with a lighter top-left and darker bottom-right, like hand-shaded sprites. */
    fun ball(cx: Double, cy: Double, rx: Double, ry: Double, base: Int, light: Int, dark: Int) =
        forEllipse(cx, cy, rx, ry) { x, y, dx, dy ->
            val lx = dx + 0.45
            val ly = dy + 0.45
            val c = when {
                lx * lx + ly * ly < 0.18 -> light
                dx + dy > 0.75 -> dark
                k > 1 && dx + dy > 0.45 -> mix(base, dark, 0.5)
                k > 1 && lx * lx + ly * ly < 0.36 -> mix(base, light, 0.45)
                else -> base
            }
            img.set(x, y, c)
        }

    fun line(x0: Int, y0: Int, x1: Int, y1: Int, c: Int) {
        // Rasterize at full resolution; each step paints a k×k block centred on the path.
        val ax = x0 * k; val ay = y0 * k; val bx = x1 * k; val by = y1 * k
        var x = ax; var y = ay
        val dx = abs(bx - ax); val dy = -abs(by - ay)
        val sx = if (ax < bx) 1 else -1
        val sy = if (ay < by) 1 else -1
        var err = dx + dy
        while (true) {
            for (oy in 0 until k) for (ox in 0 until k) img.set(x + ox, y + oy, c)
            if (x == bx && y == by) break
            val e2 = 2 * err
            if (e2 >= dy) { err += dy; x += sx }
            if (e2 <= dx) { err += dx; y += sy }
        }
    }

    fun thickLine(x0: Int, y0: Int, x1: Int, y1: Int, c: Int) {
        line(x0, y0, x1, y1, c)
        line(x0 + 1, y0, x1 + 1, y1, c)
    }

    /** Filled triangle. */
    fun tri(ax: Int, ay: Int, bx: Int, by: Int, cx: Int, cy: Int, c: Int) {
        val pts = listOf(ax, ay, bx, by, cx, cy).map { it * k.toDouble() }
        val (x0, y0, x1, y1, x2) = pts
        val y2 = pts[5]
        // Vertices sit on pixel corners at k=1 (as before); at higher k on block centres.
        val o = if (k == 1) 0.0 else k / 2.0
        fun edge(px0: Double, py0: Double, px1: Double, py1: Double, x: Double, y: Double) = (px1 - px0) * (y - py0) - (py1 - py0) * (x - px0)
        val minX = minOf(x0, x1, x2).toInt(); val maxX = maxOf(x0, x1, x2).toInt() + k
        val minY = minOf(y0, y1, y2).toInt(); val maxY = maxOf(y0, y1, y2).toInt() + k
        for (y in minY..maxY) for (x in minX..maxX) {
            val fx = x + 0.5 - o
            val fy = y + 0.5 - o
            val e0 = edge(x0, y0, x1, y1, fx, fy)
            val e1 = edge(x1, y1, x2, y2, fx, fy)
            val e2 = edge(x2, y2, x0, y0, fx, fy)
            if ((e0 >= 0 && e1 >= 0 && e2 >= 0) || (e0 <= 0 && e1 <= 0 && e2 <= 0)) img.set(x, y, c)
        }
    }

    /** Adds a 1px outline (in image pixels) around all opaque pixels. */
    fun outline(c: Int) {
        val src = img.copy()
        for (y in 0 until img.height) for (x in 0 until img.width) {
            if (src.opaque(x, y)) continue
            if (src.opaque(x - 1, y) || src.opaque(x + 1, y) || src.opaque(x, y - 1) || src.opaque(x, y + 1)) img.set(x, y, c)
        }
    }

    /** Deterministic pseudo-random noise for texture. */
    fun noise(x: Int, y: Int, seed: Int): Int {
        var n = x * 374761393 + y * 668265263 + seed * 2147483647
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7fffffff
    }

    fun speckle(c: Int, chance: Int, seed: Int, x0: Int = 0, y0: Int = 0, x1: Int = img.width - 1, y1: Int = img.height - 1) {
        for (y in y0..y1) for (x in x0..x1) if (noise(x, y, seed) % 100 < chance) img.set(x, y, c)
    }
}

/** Linear blend of two ARGB colors. */
fun mix(a: Int, b: Int, t: Double): Int {
    fun ch(c: Int, s: Int) = (c ushr s) and 0xFF
    fun m(s: Int) = (ch(a, s) + (ch(b, s) - ch(a, s)) * t).toInt().coerceIn(0, 255)
    return (m(24) shl 24) or (m(16) shl 16) or (m(8) shl 8) or m(0)
}

/** Same color with a new alpha (0–255). */
fun alpha(c: Int, a: Int): Int = (a shl 24) or (c and 0xFFFFFF)

fun draw(w: Int, h: Int, k: Int = 1, block: Pen.() -> Unit): PixelImage = PixelImage(w * k, h * k).also { Pen(it, k).block() }

fun argb(rgb: Int): Int = (0xFF shl 24) or rgb

object Pal {
    val OUTLINE = argb(0x24202A)
    val BLACK = argb(0x101018)
    val WHITE = argb(0xF8F8F8)
    val EYE = argb(0x282830)

    val GRASS = argb(0x78C850)
    val GRASS_DARK = argb(0x58A838)
    val GRASS_LIGHT = argb(0x98E070)
    val TALL = argb(0x3E9A3A)
    val TALL_DARK = argb(0x2A7030)
    val TALL_LIGHT = argb(0x70C858)
    val LEAF = argb(0x2F8A3A)
    val LEAF_DARK = argb(0x1E6030)
    val LEAF_LIGHT = argb(0x58B850)
    val TRUNK = argb(0x7A5030)
    val PATH = argb(0xDCC088)
    val PATH_DARK = argb(0xC8A468)
    val PATH_LIGHT = argb(0xECD8A8)
    val WATER = argb(0x4C8EF0)
    val WATER_LIGHT = argb(0x90C4F8)
    val WATER_DARK = argb(0x3070D0)
    val STONE = argb(0xA8A8B0)
    val STONE_DARK = argb(0x78788A)
    val STONE_LIGHT = argb(0xD0D0D8)
    val ROOF = argb(0xC84838)
    val ROOF_DARK = argb(0x983028)
    val ROOF_BLUE = argb(0x4868C8)
    val ROOF_BLUE_DARK = argb(0x3048A0)
    val PLASTER = argb(0xF0E0B8)
    val BEAM = argb(0x8A5A30)
    val WOOD = argb(0xB07840)
    val WOOD_DARK = argb(0x80542C)
    val WOOD_LIGHT = argb(0xD09858)
    val FLOOR = argb(0xD8A868)
    val FLOOR_DARK = argb(0xB88848)
    val RUG = argb(0xB83A48)
    val RUG_LIGHT = argb(0xE0B040)
    val GLASS = argb(0x88C8F0)
    val GOLD = argb(0xF0C040)
    val GOLD_DARK = argb(0xB08820)
    val CAVE_WALL = argb(0x5A4A40)
    val CAVE_WALL_DARK = argb(0x3A302A)
    val CAVE_WALL_LIGHT = argb(0x7A6858)
    val CAVE_FLOOR = argb(0x8C7C68)
    val CAVE_FLOOR_DARK = argb(0x75664F)
    val CAVE_FLOOR_LIGHT = argb(0xA49480)
    val FIRE = argb(0xF89830)
    val FIRE_LIGHT = argb(0xF8E060)
    val FIRE_DARK = argb(0xD84020)
    val IRON = argb(0x50505C)
    val IRON_LIGHT = argb(0x8A8A98)
    val RED = argb(0xD83030)
    val PINK = argb(0xF0A0B0)
}
