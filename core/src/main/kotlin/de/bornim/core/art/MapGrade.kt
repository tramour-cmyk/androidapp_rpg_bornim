package de.bornim.core.art

import kotlin.math.exp
import kotlin.math.sqrt

/**
 * Brings the map into the look of the battle scenes: the bright, toy-like colors of the map tiles
 * are moved to the muted, earthy colors of the battle backdrops (the same grass, path, water, bark
 * and stone), and the black outlines give way to a darker shade of each thing's own color.
 *
 * Every map picture passes through [grade] once, when it is drawn; the time of day comes on top as
 * light (see [MapLight]), as before.
 *
 * How a color is moved: a set of key colors (old map color → battle color) pulls each color by the
 * weighted shift of the keys near it. Colors far from every key are muted in a general way (less
 * saturated, a little darker and warmer). Light sources (fire, glowing mushrooms, crystals) keep
 * their color, so they still shine out of the dark.
 */
object MapGrade {
    /** Old map color to its battle-scene counterpart (day light). */
    private val keys: List<Pair<Int, Int>> = listOf(
        // grass, as on the battle ground between middle and near
        0x78C850 to 0x52703A, 0x58A838 to 0x3C5A2C, 0x98E070 to 0x6E8A4C,
        0x3E9A3A to 0x37552C, 0x2A7030 to 0x24391E, 0x70C858 to 0x587A3A,
        // leaves and bark
        0x2F8A3A to 0x3A6034, 0x1E6030 to 0x263E24, 0x58B850 to 0x56763E, 0x7A5030 to 0x5E4636,
        // paths: trodden earth instead of sand
        0xDCC088 to 0x9C8464, 0xC8A468 to 0x7E664A, 0xECD8A8 to 0xB29C7A,
        // water: grey-blue and deep
        0x4C8EF0 to 0x416C88, 0x90C4F8 to 0x88A8B8, 0x3070D0 to 0x2C4E68,
        // stone
        0xA8A8B0 to 0x8A877E, 0x78788A to 0x5C5A56, 0xD0D0D8 to 0xA8A498,
        // roofs: rusty tiles and slate instead of red and blue
        0xC84838 to 0x7C3E2E, 0x983028 to 0x542A20, 0x4868C8 to 0x4A5460, 0x3048A0 to 0x30383F,
        // plaster, beams, wood
        0xF0E0B8 to 0xB8A88C, 0x8A5A30 to 0x5A4030, 0xB07840 to 0x7C5C40, 0x80542C to 0x553E2C, 0xD09858 to 0x9A7852,
        // indoors
        0xD8A868 to 0xA4825A, 0xB88848 to 0x7E6242, 0xB83A48 to 0x742C30, 0xE0B040 to 0xA88A44,
        // metal, glass, small accents
        0xF0C040 to 0xC09A42, 0xB08820 to 0x7E6626, 0x88C8F0 to 0x7894A0, 0xD83030 to 0x8C2C24, 0xF0A0B0 to 0xA87882,
        0xF8F8F8 to 0xD8D4C8,
        // light sources keep their color
        0xF89830 to 0xF89830, 0xF8E060 to 0xF8E060, 0xD84020 to 0xD84020,
        0x48C8C0 to 0x48C8C0, 0xB8FFF4 to 0xB8FFF4, 0x24706E to 0x24706E,
        0xA078E8 to 0xA078E8, 0xE8DCFF to 0xE8DCFF, 0x5A3A9A to 0x5A3A9A,
    )

    /** The outline colors that are replaced by a darker shade of the neighbouring color. */
    private val outlines = setOf(Pal.OUTLINE and 0xFFFFFF, Pal.BLACK and 0xFFFFFF, 0x0E1610)

    /** Width of a key's pull in RGB distance: wide enough for the shading around a key color, narrow
     *  enough that colors which are already muted (caves, the newer trees) are left mostly alone. */
    private const val REACH = 24.0

    private val memo = HashMap<Int, Int>()

    /** The graded color (alpha kept). */
    fun color(c: Int): Int {
        val rgb = c and 0xFFFFFF
        val out = synchronized(memo) { memo[rgb] } ?: shift(rgb).also { synchronized(memo) { memo[rgb] = it } }
        return (c and 0xFF000000.toInt()) or out
    }

    private fun shift(rgb: Int): Int {
        val r = (rgb shr 16) and 0xFF; val g = (rgb shr 8) and 0xFF; val b = rgb and 0xFF
        // the shift is a mix of the keys' shifts, the nearest weighing most (an exact key keeps its
        // own target); how much of it applies depends on how near any key is at all
        var wSum = 0.0; var near = 0.0; var dr = 0.0; var dg = 0.0; var db = 0.0
        for ((from, to) in keys) {
            val fr = (from shr 16) and 0xFF; val fg = (from shr 8) and 0xFF; val fb = from and 0xFF
            val d2 = ((r - fr) * (r - fr) + (g - fg) * (g - fg) + (b - fb) * (b - fb)).toDouble()
            val e = exp(-d2 / (REACH * REACH))
            if (e < 1e-4) continue
            val w = e / (d2 + 1)
            near += e; wSum += w
            dr += w * (((to shr 16) and 0xFF) - fr); dg += w * (((to shr 8) and 0xFF) - fg); db += w * ((to and 0xFF) - fb)
        }
        // near a key: its shift; far from all keys: a general muting; in between a blend
        val k = near.coerceAtMost(1.0)
        val kr: Double; val kg: Double; val kb: Double
        if (wSum > 0) { kr = r + dr / wSum; kg = g + dg / wSum; kb = b + db / wSum } else { kr = r.toDouble(); kg = g.toDouble(); kb = b.toDouble() }
        val (mr, mg, mb) = mute(r, g, b)
        fun ch(a: Double, m: Double) = (m + (a - m) * k).toInt().coerceIn(0, 255)
        return (ch(kr, mr) shl 16) or (ch(kg, mg) shl 8) or ch(kb, mb)
    }

    /** General muting: less saturation, a touch darker, slightly warm and earthy; the more colorful
     *  a color is, the more it is muted, so earthy colors stay as they are. */
    private fun mute(r: Int, g: Int, b: Int): Triple<Double, Double, Double> {
        val lum = 0.3 * r + 0.59 * g + 0.11 * b
        val st = ((maxOf(r, g, b) - minOf(r, g, b)) / 110.0).coerceAtMost(1.0)
        val sat = 1 - 0.4 * st
        val dark = 1 - 0.14 * st
        fun m(c: Int, warm: Double) = ((lum + (c - lum) * sat) * dark + warm * st).coerceIn(0.0, 255.0)
        return Triple(m(r, 2.0), m(g, 0.0), m(b, -4.0))
    }

    /**
     * The graded picture: every color moved, every outline pixel replaced by a darker shade of the
     * colors next to it, so edges stay readable without the black line of a cartoon.
     */
    fun grade(src: PixelImage): PixelImage {
        val w = src.width; val h = src.height
        val out = PixelImage(w, h)
        fun isLine(p: Int) = (p ushr 24) != 0 && (p and 0xFFFFFF) in outlines
        for (i in 0 until w * h) { val p = src.pixels[i]; if ((p ushr 24) != 0 && !isLine(p)) out.pixels[i] = color(p) }
        for (y in 0 until h) for (x in 0 until w) {
            val p = src[x, y]
            if (!isLine(p)) continue
            // average of the own colors around it, darkened
            var n = 0; var sr = 0; var sg = 0; var sb = 0
            for (dy in -1..1) for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                val q = src[x + dx, y + dy]
                if ((q ushr 24) == 0 || isLine(q)) continue
                val c = out[x + dx, y + dy]
                // direct neighbours count double
                val wgt = if (dx == 0 || dy == 0) 2 else 1
                sr += ((c shr 16) and 0xFF) * wgt; sg += ((c shr 8) and 0xFF) * wgt; sb += (c and 0xFF) * wgt; n += wgt
            }
            val a = p and 0xFF000000.toInt()
            out.pixels[y * w + x] = if (n == 0) a or 0x1A1614
            else {
                val base = (sr / n shl 16) or (sg / n shl 8) or (sb / n)
                a or (mix(argb(base), argb(0x120E0C), 0.62) and 0xFFFFFF)
            }
        }
        return out
    }

    /** Distance helper for tests: how far two colors lie apart in RGB. */
    fun distance(a: Int, b: Int): Double {
        val dr = ((a shr 16) and 0xFF) - ((b shr 16) and 0xFF)
        val dg = ((a shr 8) and 0xFF) - ((b shr 8) and 0xFF)
        val db = (a and 0xFF) - (b and 0xFF)
        return sqrt((dr * dr + dg * dg + db * db).toDouble())
    }
}
