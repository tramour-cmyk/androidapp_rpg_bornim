package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * 221 (Chef 19.10.: das Wasser wirkt "langweilig"): life on the water above the still ground image ([MapGround]), all
 * in map pixels, drawn flat on the ground. By day short glints drift slowly, on the river with its flow; in the rain
 * drops ring the water; at night the lamps, lit windows, the hero's light and the moon lie on it as trembling streaks.
 * Only open water gets them, never the bank's earthen step.
 */
object WaterLife {
    private const val T = WorldArt.T

    /** [MapGround.water] above this is open water, clear of the bank's step (which reaches to 0.7). */
    const val OPEN = 0.72

    fun open(map: MapDef, x: Double, y: Double) = MapGround.water(map, x.toFloat(), y.toFloat()) > OPEN

    // ------------------------------------------------------------------ flow

    private val flowCache = HashMap<String, FloatArray>()

    /**
     * The way the water runs on tile ([tx], [ty]), as a unit vector, or (0, 0) on still water: a river ([de.bornim.core.audio.RiverSound.running])
     * runs along its length, towards the east or the south (the river of Bornim from the west).
     */
    fun flow(map: MapDef, tx: Int, ty: Int): Pair<Float, Float> {
        if (!map.inside(tx, ty)) return 0f to 0f
        val f = synchronized(flowCache) { flowCache.getOrPut(map.id) { flowOf(map) } }
        val k = (ty * map.width + tx) * 2
        return f[k] to f[k + 1]
    }

    private fun flowOf(map: MapDef): FloatArray {
        val w = map.width; val h = map.height
        val out = FloatArray(w * h * 2)
        val running = de.bornim.core.audio.RiverSound.running(map).toSet()
        for ((tx, ty) in running) {
            // the long axis of the water about the tile: the main direction of the water tiles within 3
            var sxx = 0.0; var syy = 0.0; var sxy = 0.0
            for (dy in -3..3) for (dx in -3..3) if ((tx + dx to ty + dy) in running) { sxx += dx * dx; syy += dy * dy; sxy += dx * dy }
            val a = 0.5 * atan2(2 * sxy, sxx - syy)
            var ux = cos(a); var uy = sin(a)
            if (ux + uy < 0) { ux = -ux; uy = -uy }
            out[(ty * w + tx) * 2] = ux.toFloat(); out[(ty * w + tx) * 2 + 1] = uy.toFloat()
        }
        return out
    }

    // ------------------------------------------------------------------ glints

    /** A short bright line on the water at map pixel ([x], [y]), [half] long each way along ([ux], [uy]). */
    class Line(val x: Float, val y: Float, val ux: Float, val uy: Float, val half: Float, val alpha: Float, val color: Int = GLINT)

    const val GLINT = 0xC8D8D8
    /** How long a glint lives, ms, and how fast it drifts with the river, map pixels a second. */
    const val GLINT_MS = 2600L
    const val DRIFT = 9f

    private fun hash(a: Int, b: Int, c: Int): Int {
        var n = a * 374761393 + b * 668265263 + c * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun unit(a: Int, b: Int, c: Int) = (hash(a, b, c) % 10000) / 10000f

    /**
     * The glints on the water tiles from ([tx0], [ty0]) to ([tx1], [ty1]) at [clock]: two to a tile, each fading in and
     * out over [GLINT_MS] at its own spot, drifting with the [flow], crosswise to it like the crest of a little wave;
     * on still water they lie every way and only sway. [day] 0 … 1 dims them towards the night.
     */
    fun glints(map: MapDef, clock: Long, tx0: Int, ty0: Int, tx1: Int, ty1: Int, day: Float): List<Line> {
        val out = ArrayList<Line>()
        val bright = 0.15f + 0.85f * day.coerceIn(0f, 1f)
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (!map.inside(tx, ty) || map.tile(tx, ty) != Tile.WATER) continue
            val (fx, fy) = flow(map, tx, ty)
            val runs = fx != 0f || fy != 0f
            for (i in 0 until 2) {
                val life = GLINT_MS + hash(tx, ty, 300 + i) % 1200
                val t = clock + hash(tx, ty, 310 + i) % life
                val cycle = (t / life).toInt()
                val ph = (t % life) / life.toFloat()
                var x = tx * T + unit(tx * 7 + cycle, ty, 320 + i) * T
                var y = ty * T + unit(tx, ty * 7 + cycle, 330 + i) * T
                val ux: Float; val uy: Float
                if (runs) {
                    val s = ph * life / 1000f * DRIFT
                    x += fx * s; y += fy * s
                    ux = -fy; uy = fx
                } else {
                    val a = unit(tx, ty, 340 + i + cycle) * PI.toFloat()
                    x += sin(ph * 2 * PI.toFloat() + i) * 1.5f
                    ux = cos(a); uy = sin(a)
                }
                val half = 1.5f + unit(tx, ty, 350 + i + cycle) * 2.5f
                if (!open(map, (x - ux * half).toDouble(), (y - uy * half).toDouble()) || !open(map, (x + ux * half).toDouble(), (y + uy * half).toDouble())) continue
                out += Line(x, y, ux, uy, half, sin(ph * PI.toFloat()) * 0.42f * bright)
            }
        }
        return out
    }

    // ------------------------------------------------------------------ rain

    /** A ring on the water at map pixel ([x], [y]), [r] wide, as a drop leaves it. */
    class Ring(val x: Float, val y: Float, val r: Float, val alpha: Float)

    const val RING_MS = 900L

    /**
     * The rings the rain ([level] 0 … 1) makes on the water tiles in view: up to three to a tile at a time, each spreading
     * over [RING_MS], with a fainter second ring inside it after a moment.
     */
    fun rings(map: MapDef, level: Float, clock: Long, tx0: Int, ty0: Int, tx1: Int, ty1: Int): List<Ring> {
        if (level <= 0.01f) return emptyList()
        val out = ArrayList<Ring>()
        val n = (level * 3).toInt().coerceAtLeast(1)
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (!map.inside(tx, ty) || map.tile(tx, ty) != Tile.WATER) continue
            for (i in 0 until n) {
                val life = RING_MS + hash(tx, ty, 400 + i) % 500
                val t = clock + hash(tx, ty, 410 + i) % life
                val cycle = (t / life).toInt()
                // a light rain leaves some tiles still for a while
                if (unit(tx + cycle, ty, 420 + i) > level * 1.6f) continue
                val ph = (t % life) / life.toFloat()
                val x = tx * T + unit(tx * 5 + cycle, ty, 430 + i) * T
                val y = ty * T + unit(tx, ty * 5 + cycle, 440 + i) * T
                if (!open(map, x.toDouble(), y.toDouble())) continue
                out += Ring(x, y, 1f + ph * 7f, (1 - ph) * 0.5f)
                if (ph > 0.3f) out += Ring(x, y, 1f + (ph - 0.3f) * 6f, (1 - ph) * 0.3f)
            }
        }
        return out
    }

    // ------------------------------------------------------------------ night

    private val STREAK_KINDS = setOf(MapLight.Kind.LAMP, MapLight.Kind.WINDOW, MapLight.Kind.TORCH, MapLight.Kind.FIRE)
    const val MOON = 0xD8E4F4

    /**
     * At night, the lights by the water lie on it as streaks of short crosswise lines towards the viewer (down the
     * screen: map direction (1, 1)), trembling and broken, brightest near the light. [lights] are the map's lights and
     * the hero's; [day] 0 night … 1 day. The moon's streak runs through map pixel ([moonX], [moonY]) the whole way
     * down the view, from ([tx0], [ty0]) to ([tx1], [ty1]); null under clouds.
     */
    fun streaks(
        map: MapDef, lights: List<MapLight.Source>, day: Float, clock: Long,
        tx0: Int, ty0: Int, tx1: Int, ty1: Int, moonX: Double?, moonY: Double?,
    ): List<Line> {
        val out = ArrayList<Line>()
        val night = ((0.6f - day) / 0.4f).coerceIn(0f, 1f)
        if (night <= 0f) return out
        val x0 = tx0 * T.toDouble(); val y0 = ty0 * T.toDouble(); val x1 = (tx1 + 1) * T.toDouble(); val y1 = (ty1 + 1) * T.toDouble()
        val d = 1 / sqrt(2.0)
        fun streak(sx: Double, sy: Double, from: Double, to: Double, width: Float, alpha: Float, color: Int, seed: Int, fades: Boolean = true) {
            var s = from
            var k = 0
            while (s < to) {
                val x = sx + s * d; val y = sy + s * d
                k++
                s += 2.5
                if (fades && (s - from) / (to - from) > 0.95) break
                if (x < x0 - T || y < y0 - T || x > x1 + T || y > y1 + T) continue
                if (!open(map, x, y)) continue
                // each line trembles: its width and brightness waver on their own, some go out for a moment
                val wob = sin(clock / 190.0 + k * 1.7 + seed).toFloat() * 0.5f + sin(clock / 77.0 + k * 3.1).toFloat() * 0.25f
                val fade = if (fades) (1 - ((s - from) / (to - from)).toFloat()).coerceIn(0f, 1f) else 1f
                val a = alpha * night * fade * (0.55f + 0.45f * wob)
                if (a < 0.03f) continue
                val half = width * (0.6f + 0.4f * fade) * (0.75f + 0.35f * wob)
                out += Line((x + sin(clock / 260.0 + k) * 0.8).toFloat(), y.toFloat(), d.toFloat(), (-d).toFloat(), half, a, color)
            }
        }
        for (s in lights) {
            if (s.kind !in STREAK_KINDS) continue
            val k = MapLight.strength(map, s.shines, day).toFloat()
            if (k <= 0f) continue
            // only near water: within the light's reach down the screen
            val reach = s.reach * 0.9
            val tx = (s.x / T).toInt(); val ty = (s.y / T).toInt()
            val r = (reach / T).toInt() + 1
            if ((0..r).none { i -> map.inside(tx + i, ty + i) && map.tile(tx + i, ty + i) == Tile.WATER }) continue
            streak(s.x, s.y, 4.0, reach, 3.5f, 0.55f * k * s.power.toFloat().coerceAtMost(1.2f), s.color and 0xFFFFFF, (s.x + s.y).toInt())
        }
        if (moonX != null && moonY != null) {
            // from the top of the view to its foot, along (1, 1) through the moon's column
            val back = ((moonX - x0) + (moonY - y0)) * d
            val ahead = ((x1 - moonX) + (y1 - moonY)) * d
            streak(moonX - back * d, moonY - back * d, 0.0, back + ahead, 4.5f, 0.32f, MOON, 7, fades = false)
        }
        return out
    }
}
