package de.bornim.core.art

/**
 * The warm edge a flame puts on a figure standing near it (09.10.): on the side facing the fire the
 * outline catches the light, and the whole figure warms a little, more the nearer and the darker it
 * is. Worked on the finished map picture, so it fits every figure, the hero and the folk alike.
 *
 * Directions are kept to [DIRS] ways and strengths to [LEVELS] steps, so a figure by a fire needs only
 * a handful of lit pictures, kept in a small store.
 */
object MapGlow {
    const val DIRS = 8
    const val LEVELS = 4
    private const val FIRE = 0xFFB060

    /** The direction (0 until [DIRS], 0 = towards the right, counting clockwise on screen) from a figure towards a light [dx], [dy] away. */
    fun dir(dx: Double, dy: Double): Int =
        Math.floorMod(Math.round(Math.atan2(dy, dx) / (2 * Math.PI) * DIRS).toInt(), DIRS)

    /**
     * How strongly a flame [dist] tiles away lights a figure at [daylight] (1 full day, 0 night):
     * 0 (not at all) to [LEVELS]; within [reach] tiles, fading with distance and with the day.
     */
    fun level(dist: Double, daylight: Double, reach: Double = 3.0): Int {
        if (dist >= reach) return 0
        val k = (1 - dist / reach) * (1 - daylight * 0.85)
        return Math.round(k * LEVELS).toInt().coerceIn(0, LEVELS)
    }

    /** [img] lit by a flame in direction [dir] at strength [level]. */
    fun lit(img: PixelImage, dir: Int, level: Int): PixelImage {
        if (level <= 0) return img
        val a = dir * 2 * Math.PI / DIRS
        val lx = Math.cos(a); val ly = Math.sin(a)
        val k = level.toDouble() / LEVELS
        val out = PixelImage(img.width, img.height, img.pixels.copyOf())
        val fr = (FIRE shr 16) and 0xFF; val fg = (FIRE shr 8) and 0xFF; val fb = FIRE and 0xFF
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val c = img[x, y]
            if ((c ushr 24) < 128) continue
            // on the lit side: one of the next pixels towards the light is empty
            var edge = 0.0
            for (d in 1..2) {
                val q = img[x + Math.round(lx * d).toInt(), y + Math.round(ly * d).toInt()]
                if ((q ushr 24) < 128) { edge = 1.0 - (d - 1) * 0.4; break }
            }
            val t = (0.05 + 0.55 * edge) * k
            val r = (c shr 16) and 0xFF; val g = (c shr 8) and 0xFF; val b = c and 0xFF
            // the edge brightens towards the flame's colour, the rest only warms
            // the edge takes on the flame's colour; the rest only a breath of warmth (its own brightness, tinted)
            val lum = (r * 0.3 + g * 0.59 + b * 0.11)
            fun ch(v: Int, f: Int) = (v + ((if (edge > 0) f.toDouble() else lum * f / 200.0) - v) * t).toInt().coerceIn(0, 255)
            out.pixels[y * img.width + x] = (c and 0xFF000000.toInt()) or (ch(r, fr) shl 16) or (ch(g, fg) shl 8) or ch(b, fb)
        }
        return out
    }

    private val cache = object : LinkedHashMap<Any, PixelImage>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<Any, PixelImage>?) = size > 96
    }

    /** [lit] kept: the same picture, direction and strength are worked only once. */
    fun litCached(img: PixelImage, dir: Int, level: Int): PixelImage {
        if (level <= 0) return img
        val key = Triple(img, dir, level)
        synchronized(cache) { cache[key]?.let { return it } }
        val out = lit(img, dir, level)
        synchronized(cache) { cache[key] = out }
        return out
    }
}
