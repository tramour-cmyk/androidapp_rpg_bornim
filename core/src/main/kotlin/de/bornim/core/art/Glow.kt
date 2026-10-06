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
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 120
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
     * A diagonal band of light across the body at [phase] (0..1 sweeps from left to right),
     * to lay over a shimmering monster.
     */
    fun sheen(src: PixelImage, phase: Int, steps: Int = 12): PixelImage = cached("sheen/${System.identityHashCode(src)}/$phase/$steps") {
        val out = PixelImage(src.width, src.height)
        val centre = -6 + (src.width + src.height * 0.6 + 12) * phase / (steps - 1)
        for (y in 0 until src.height) for (x in 0 until src.width) {
            if (!src.opaque(x, y)) continue
            val d = kotlin.math.abs(x + y * 0.6 - centre)
            if (d < 9) out.set(x, y, alpha(if (d < 3) argb(0xFFFFFF) else argb(0xC8F0FF), ((1 - d / 9) * 230).toInt()))
        }
        out
    }
}
