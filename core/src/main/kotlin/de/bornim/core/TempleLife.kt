package de.bornim.core

import kotlin.math.floor
import kotlin.math.sin

/**
 * 112 (7): quiet life over the temple scene's painted pictures, as the intro's (70.3 B): only what is light or air moves.
 * The candle flames flicker and the light round them breathes; in picture 4 the dust drifts in the sun shaft. Nothing walks.
 *
 * The painter (`tools/preview` `TempleProbe.kt`, `TEMPEL68=app`) writes where it put each flame and the shaft into
 * `assets/tempel/leben.txt` next to the pictures, in the pictures' own pixels (1080 × 1200), so app and painter agree:
 * `flamme <picture 1..5> <x> <y> <size>` and `strahl <picture> <x> <y> <x> <y> …` (the shaft's outline).
 */
object TempleLife {
    const val W = 1080f
    const val H = 1200f

    /** A painted candle flame: its foot at ([x], [y]) in picture [pic] (1-based), [s] the painter's flame size. */
    data class Flame(val pic: Int, val x: Float, val y: Float, val s: Float)
    /** What moves in the five pictures. */
    data class Life(val flames: List<Flame>, val shafts: Map<Int, List<Pair<Float, Float>>>) {
        fun flames(pic: Int) = flames.filter { it.pic == pic }
    }

    /** Reads `leben.txt`; lines it does not know are left out, so an old file never breaks the scene. */
    fun parse(text: String): Life {
        val flames = ArrayList<Flame>(); val shafts = HashMap<Int, List<Pair<Float, Float>>>()
        for (raw in text.lineSequence()) {
            val w = raw.trim().split(Regex("\\s+"))
            if (w.size < 2 || w[0].startsWith("#")) continue
            val v = w.drop(1).mapNotNull { it.toFloatOrNull() }
            if (v.size != w.size - 1) continue
            when (w[0]) {
                "flamme" -> if (v.size == 4) flames += Flame(v[0].toInt(), v[1], v[2], v[3])
                "strahl" -> if (v.size >= 7 && v.size % 2 == 1) shafts[v[0].toInt()] = v.drop(1).chunked(2) { it[0] to it[1] }
            }
        }
        return Life(flames, shafts)
    }

    /** How bright flame [i] burns at [ms] (about 0.8 .. 1.2), the intro's flicker. */
    fun flicker(i: Int, ms: Long) = IntroLife.flicker(i + 40, ms)

    /** A mote of dust: where it is, how big, how bright (0..1). */
    data class Mote(val x: Float, val y: Float, val r: Float, val a: Float)

    /**
     * [n] motes in the [shaft] at [ms]: each drifts slowly down the light and sways a little, fades in and out at the ends
     * of its way, and starts again; only those inside the shaft's outline are given.
     */
    fun motes(shaft: List<Pair<Float, Float>>, ms: Long, n: Int = 140): List<Mote> {
        if (shaft.size < 3) return emptyList()
        val x0 = shaft.minOf { it.first }; val x1 = shaft.maxOf { it.first }
        val y0 = shaft.minOf { it.second }; val y1 = shaft.maxOf { it.second }
        val t = ms / 1000f
        val out = ArrayList<Mote>()
        for (i in 0 until n) {
            val period = 9f + 7f * h(i, 1)
            val phase = t / period + h(i, 2)
            val p = phase - floor(phase)
            val x = x0 + (x1 - x0) * frac(h(i, 3) + p * 0.25f) + 6f * sin(t * (0.6f + h(i, 4)) + i)
            val y = y0 + (y1 - y0) * frac(h(i, 5) + p * 0.35f) + 4f * sin(t * (0.5f + h(i, 6)) + i * 2)
            if (!inside(shaft, x, y)) continue
            val fade = minOf(p, 1 - p) * 4f
            out += Mote(x, y, 0.8f + 1.6f * h(i, 7), (0.25f + 0.55f * h(i, 8)) * fade.coerceAtMost(1f))
        }
        return out
    }

    private fun frac(v: Float) = v - floor(v)
    private fun h(i: Int, s: Int): Float {
        var k = i * 374761393 + s * 668265263
        k = (k xor (k ushr 13)) * 1274126177
        return ((k xor (k ushr 16)) and 0x7FFFFFFF) % 100000 / 100000f
    }

    /** Whether (x, y) lies inside the outline [poly] (even-odd). */
    fun inside(poly: List<Pair<Float, Float>>, x: Float, y: Float): Boolean {
        var c = false; var j = poly.size - 1
        for (i in poly.indices) {
            val (xi, yi) = poly[i]; val (xj, yj) = poly[j]
            if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) c = !c
            j = i
        }
        return c
    }
}
