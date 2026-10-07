package de.bornim.core.art

import kotlin.math.sqrt

/**
 * Overlays that follow a sprite's shape: the shimmering outline of elite monsters, a tint on the
 * edges of their body, and the sheen that wanders over a shimmering monster's coat.
 */
object Glow {
    /** Extra pixels around the sprite that the halo needs. */
    const val PAD = 4

    private val cache = object : LinkedHashMap<String, PixelImage>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 400
    }

    private fun cached(key: String, make: () -> PixelImage): PixelImage {
        synchronized(cache) { cache[key]?.let { return it } }
        val img = make()
        synchronized(cache) { cache[key] = img }
        return img
    }

    /** A soft halo around [src] in [color], [PAD] pixels bigger on every side; brightest right at the edge. */
    fun halo(src: PixelImage, color: Int): PixelImage = cached("halo/${System.identityHashCode(src)}/$color") {
        val out = PixelImage(src.width + 2 * PAD, src.height + 2 * PAD)
        val bright = mix(argb(color), argb(0xFFFFFF), 0.35)
        for (y in 0 until out.height) for (x in 0 until out.width) {
            val sx = x - PAD; val sy = y - PAD
            if (src.opaque(sx, sy)) continue
            var d = 9.0
            for (dy in -PAD..PAD) for (dx in -PAD..PAD) if (src.opaque(sx + dx, sy + dy)) d = minOf(d, sqrt((dx * dx + dy * dy).toDouble()))
            if (d > PAD) continue
            val a = ((1 - (d - 1) / (PAD - 0.5)).coerceIn(0.0, 1.0) * 255).toInt()
            if (a > 0) out.set(x, y, alpha(if (d < 1.5) bright else argb(color), a))
        }
        out
    }

    /** The outer two pixels of the body in [color], to lay over the sprite with some transparency. */
    fun rim(src: PixelImage, color: Int): PixelImage = cached("rim/${System.identityHashCode(src)}/$color") {
        val out = PixelImage(src.width, src.height)
        for (y in 0 until src.height) for (x in 0 until src.width) {
            if (!src.opaque(x, y)) continue
            if (!src.opaque(x - 2, y) || !src.opaque(x + 2, y) || !src.opaque(x, y - 2) || !src.opaque(x, y + 2)) out.set(x, y, argb(color))
        }
        out
    }

    /**
     * Wounds on the body of a hurt monster: a few dark stains ([level] 1) or more with drips
     * ([level] 2), in [color]. With [cracks] they are thin dark fissures instead (bone).
     * Positions are fractions of the sprite's bounding box, so they move with the body.
     */
    fun wounds(src: PixelImage, level: Int, color: Int, seed: Int, cracks: Boolean = false): PixelImage =
        cached("wounds/${System.identityHashCode(src)}/$level/$color/$seed/$cracks") {
            val out = PixelImage(src.width, src.height)
            var x0 = src.width; var x1 = 0; var y0 = src.height; var y1 = 0
            for (y in 0 until src.height) for (x in 0 until src.width) if (src.opaque(x, y)) {
                x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y)
            }
            if (x1 <= x0) return@cached out
            fun rnd(i: Int, k: Int): Double {
                var n = i * 374761393 + k * 668265263 + seed * 1442695041
                n = (n xor (n ushr 13)) * 1274126177
                return ((n xor (n ushr 16)) and 0xFFFF) / 65535.0
            }
            fun inside(x: Int, y: Int) = src.opaque(x, y) && src.opaque(x - 1, y) && src.opaque(x + 1, y) && src.opaque(x, y - 1) && src.opaque(x, y + 1)
            val dark = mix(argb(color), argb(0x000000), 0.35)
            val count = if (level >= 2) 7 else 3
            var placed = 0
            var tries = 0
            while (placed < count && tries < 80) {
                tries++
                // stains sit on the upper body, not on thin legs
                val cx = x0 + ((x1 - x0) * (0.2 + 0.65 * rnd(tries, 1))).toInt()
                val cy = y0 + ((y1 - y0) * (0.15 + 0.4 * rnd(tries, 2))).toInt()
                if (!inside(cx, cy)) continue
                placed++
                if (cracks) {
                    var px = cx; var py = cy
                    for (k in 0 until 6 + level * 3) {
                        if (inside(px, py)) out.set(px, py, argb(0x14100C))
                        if (k % 3 == 0 && inside(px + 1, py)) out.set(px + 1, py, argb(0x5A5248))
                        px += if (rnd(placed, k) < 0.5) 1 else -1; py += if (rnd(placed, k + 9) < 0.6) 1 else 0
                    }
                    continue
                }
                val r = 1.2 + rnd(placed, 3) * (if (level >= 2) 1.6 else 1.0)
                for (dy in -2..2) for (dx in -3..3) {
                    val d = kotlin.math.sqrt((dx * dx).toDouble() + (dy * dy * 1.6))
                    if (d > r + rnd(dx + 7, dy + 7) * 0.8) continue
                    val x = cx + dx; val y = cy + dy
                    if (inside(x, y)) out.set(x, y, if (d < r * 0.5) dark else argb(color))
                }
                // fresh blood runs down
                if (level >= 2 && rnd(placed, 5) < 0.7) for (k in 1..(2 + (rnd(placed, 6) * 3).toInt())) {
                    if (inside(cx, cy + 1 + k)) out.set(cx, cy + 1 + k, argb(color))
                }
            }
            out
        }

    /**
     * A diagonal band of light across the body at [phase] (0..1 sweeps from left to right),
     * to lay over a shimmering monster.
     */
    fun sheen(src: PixelImage, phase: Int, steps: Int = 12): PixelImage = cached("sheen/${System.identityHashCode(src)}/$phase/$steps") {
        val out = PixelImage(src.width, src.height)
        // the band crosses the body itself, not the whole picture: a foe may stand in a frame far wider than it is
        var x0 = src.width; var x1 = 0; var y0 = src.height; var y1 = 0
        for (y in 0 until src.height) for (x in 0 until src.width) if (src.opaque(x, y)) {
            x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y)
        }
        if (x1 < x0) return@cached out
        val centre = x0 + y0 * 0.6 - 6 + ((x1 - x0) + (y1 - y0) * 0.6 + 12) * phase / (steps - 1)
        for (y in 0 until src.height) for (x in 0 until src.width) {
            if (!src.opaque(x, y)) continue
            val d = kotlin.math.abs(x + y * 0.6 - centre)
            if (d < 9) out.set(x, y, alpha(if (d < 3) argb(0xFFFFFF) else argb(0xC8F0FF), ((1 - d / 9) * 230).toInt()))
        }
        out
    }
}
