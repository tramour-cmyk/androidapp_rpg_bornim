package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.sqrt

/**
 * Light on every map, in the same spirit as the battle scenes: the time of day sets the light of
 * the place (warm at dusk, cold and dark at night), forests lie in the shade of their crowns, and
 * the things on the map shine — torches, fires, mushrooms, crystals, cracks of daylight, street
 * lamps and windows at night, candles indoors, and the hero's lantern in the dark. Walls stop the
 * light. The result is a light image that is multiplied over the map.
 */
object MapLight {
    /** Map pixels per light grid cell. */
    const val CELL = 8

    /** Map pixels per pixel of the finished light image. */
    const val RES = 2

    enum class Kind { TORCH, FIRE, SHROOM, CRYSTAL, SKY, EXIT, LAMP, WINDOW, CANDLE, DOOR }

    /** When a light shines. */
    enum class When { ALWAYS, NIGHT, DAY }

    /** A light at map pixel ([x], [y]); [reach] in map pixels. */
    class Source(val x: Double, val y: Double, val kind: Kind, val color: Int, val reach: Double, val power: Double, val shines: When = When.ALWAYS)

    private const val T = WorldArt.T
    private val opaque = setOf(Tile.CAVE_WALL, Tile.TORCH, Tile.CRYSTAL, Tile.WALL, Tile.ROOF, Tile.ROOF_BLUE, Tile.WINDOW)
    private val lanternColor = argb(0xFFD4A8)

    private val sourceCache = HashMap<String, List<Source>>()
    private val staticCache = HashMap<String, Static>()

    fun sources(map: MapDef): List<Source> = synchronized(sourceCache) {
        sourceCache.getOrPut(map.id) {
            val out = mutableListOf<Source>()
            val indoor = map.kind == MapKind.INTERIOR
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                val cx = tx * T + T / 2.0; val cy = ty * T + T / 2.0
                when (map.tile(tx, ty)) {
                    Tile.TORCH -> out += Source(cx, ty * T + 12.0, Kind.TORCH, argb(0xFFB060), T * 3.6, 1.15)
                    Tile.CAMPFIRE -> out += Source(cx, cy, Kind.FIRE, argb(0xFF9A48), T * 4.4, 1.35)
                    Tile.GLOWSHROOM -> out += Source(cx, cy, Kind.SHROOM, argb(0x60E8D8), T * 2.4, 0.8)
                    Tile.CRYSTAL -> out += Source(cx, ty * T + 26.0, Kind.CRYSTAL, argb(0xB088FF), T * 2.6, 0.85)
                    Tile.SKYLIGHT -> out += Source(cx, cy, Kind.SKY, argb(0xE8F0FF), T * 3.0, 1.15)
                    Tile.CAVE_EXIT -> out += Source(cx, cy, Kind.EXIT, argb(0xFFF4D8), T * 3.4, 1.0)
                    Tile.LAMP -> out += Source(cx, ty * T + 8.0, Kind.LAMP, argb(0xFFD49A), T * 2.6, 0.95, When.NIGHT)
                    // light falls out of a lit window onto the ground in front of the house
                    Tile.WINDOW -> if (!indoor && map.tile(tx, ty + 1).walkable) out += Source(cx, ty * T + T + 6.0, Kind.WINDOW, argb(0xFFC880), T * 1.6, 0.7, When.NIGHT)
                        // indoors, a window lets in grey daylight
                        else if (indoor && hasHearth(map)) out += Source(cx, ty * T + T + 8.0, Kind.WINDOW, argb(0xD8E0EC), T * 2.6, 0.55, When.DAY)
                    // a fire in the back wall: the light comes out of its mouth onto the floor in front
                    Tile.HEARTH -> if (map.tile(tx - 1, ty) != Tile.HEARTH) out += Source((tx + 1) * T.toDouble(), (ty + 1) * T + 4.0, Kind.FIRE, argb(0xFF9A48), T * 5.0, 1.45)
                    Tile.TABLE -> if (indoor) out += Source(cx, cy, Kind.CANDLE, argb(0xFFC078), T * 2.8, 0.6)
                    Tile.ALTAR -> out += Source(cx, cy, Kind.CANDLE, argb(0xFFE0A0), T * 3.2, 0.75)
                    Tile.COUNTER -> if (indoor) out += Source(cx, cy, Kind.CANDLE, argb(0xFFC078), T * 2.4, 0.45)
                    Tile.DOOR -> if (indoor) out += Source(cx, cy - 4, Kind.DOOR, argb(0xE8ECF0), T * 3.0, 0.6, When.DAY)
                    else -> {}
                }
            }
            out
        }
    }

    /** Whether light from ([sx], [sy]) reaches ([x], [y]) without passing through rock or walls. */
    private fun clear(map: MapDef, sx: Double, sy: Double, x: Double, y: Double): Boolean {
        val stx = (sx / T).toInt(); val sty = (sy / T).toInt()
        val dtx = (x / T).toInt(); val dty = (y / T).toInt()
        val dist = sqrt((x - sx) * (x - sx) + (y - sy) * (y - sy))
        val steps = (dist / 5).toInt()
        // in a cave the light falls a little way onto the rock it meets (about a tile deep), so the rock
        // round a room is lit with it instead of standing black; only for rock, never through a wall
        val intoRock = map.kind == MapKind.CAVE && map.tile(dtx, dty) in opaque
        for (i in 1 until steps) {
            val f = i / steps.toDouble()
            val tx = ((sx + (x - sx) * f) / T).toInt(); val ty = ((sy + (y - sy) * f) / T).toInt()
            if ((tx == stx && ty == sty) || (tx == dtx && ty == dty)) continue
            if (intoRock && dist * (1 - f) < T * 1.3) continue
            if (map.tile(tx, ty) in opaque) return false
        }
        return true
    }

    /** Whether [s] lights map pixel ([x], [y]), i.e. no rock or wall lies between. */
    fun reaches(map: MapDef, s: Source, x: Double, y: Double) = clear(map, s.x, s.y, x, y)

    /** How strongly a light of the given timing shines at [daylight] (0 night … 1 day). */
    fun strength(map: MapDef, shines: When, daylight: Float): Double = when {
        map.kind == MapKind.CAVE -> if (shines == When.DAY) 0.0 else 1.0
        shines == When.ALWAYS -> 1.0
        shines == When.NIGHT -> ((0.7 - daylight) / 0.5).coerceIn(0.0, 1.0)
        else -> daylight.toDouble().coerceIn(0.0, 1.0)
    }

    private fun add(map: MapDef, out: DoubleArray, gw: Int, gh: Int, s: Source, k0: Double, cx0: Int = 0, cy0: Int = 0) {
        if (k0 <= 0.0) return
        val r = s.reach * 1.5
        val c0 = ((s.x - r) / CELL).toInt().coerceAtLeast(cx0); val c1 = ((s.x + r) / CELL).toInt().coerceAtMost(cx0 + gw - 1)
        val r0 = ((s.y - r) / CELL).toInt().coerceAtLeast(cy0); val r1 = ((s.y + r) / CELL).toInt().coerceAtMost(cy0 + gh - 1)
        val cr = ((s.color shr 16) and 0xFF) / 255.0; val cg = ((s.color shr 8) and 0xFF) / 255.0; val cb = (s.color and 0xFF) / 255.0
        for (cy in r0..r1) for (cx in c0..c1) {
            val x = cx * CELL + CELL / 2.0; val y = cy * CELL + CELL / 2.0
            val d = sqrt((x - s.x) * (x - s.x) + (y - s.y) * (y - s.y))
            if (d > r) continue
            val k = k0 * s.power * exp(-(d / s.reach) * (d / s.reach) * 2.0)
            if (k < 0.01 || !clear(map, s.x, s.y, x, y)) continue
            val i = ((cy - cy0) * gw + (cx - cx0)) * 3
            out[i] += cr * k; out[i + 1] += cg * k; out[i + 2] += cb * k
        }
    }

    /** Everything that does not move, per grid cell: each kind of light, and the shade of tree crowns. */
    private class Static(val always: DoubleArray, val night: DoubleArray, val day: DoubleArray, val shade: DoubleArray)

    private fun static(map: MapDef): Static = synchronized(staticCache) {
        staticCache.getOrPut(map.id) {
            val gw = map.width * T / CELL; val gh = map.height * T / CELL
            val always = DoubleArray(gw * gh * 3); val night = DoubleArray(gw * gh * 3); val day = DoubleArray(gw * gh * 3)
            for (s in sources(map)) add(map, when (s.shines) { When.ALWAYS -> always; When.NIGHT -> night; When.DAY -> day }, gw, gh, s, 1.0)
            val shade = DoubleArray(gw * gh) { 1.0 }
            if (map.kind == MapKind.FOREST) {
                val deep = map.id == "deep_forest"
                for (cy in 0 until gh) for (cx in 0 until gw) {
                    // the more crowns around, the deeper the shade; light patches drift through
                    val x = (cx + 0.5) * CELL / T; val y = (cy + 0.5) * CELL / T
                    var crowns = 0.0
                    for (dy in -2..2) for (dx in -2..2) {
                        val tx = floor(x).toInt() + dx; val ty = floor(y).toInt() + dy
                        if (map.tile(tx, ty) != Tile.TREE) continue
                        val d = sqrt((tx + 0.5 - x) * (tx + 0.5 - x) + (ty + 0.5 - y) * (ty + 0.5 - y))
                        crowns += exp(-d * d / 2.2)
                    }
                    val dapple = noise(x / 2.7, y / 2.7, map.id.hashCode()) - 0.5
                    shade[cy * gw + cx] = (1 - (if (deep) 0.09 else 0.07) * crowns + dapple * 0.12).coerceIn(if (deep) 0.45 else 0.6, 1.05)
                }
            }
            Static(always, night, day, shade)
        }
    }

    private fun noise(x: Double, y: Double, s: Int): Double {
        fun h(ix: Int, iy: Int): Double {
            var n = ix * 374761393 + iy * 668265263 + s * 1442695041
            n = (n xor (n ushr 13)) * 1274126177
            return ((n xor (n ushr 16)) and 0xFFFF) / 65535.0
        }
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        val fx = x - ix; val fy = y - iy
        val u = fx * fx * (3 - 2 * fx); val v = fy * fy * (3 - 2 * fy)
        return (h(ix, iy) * (1 - u) + h(ix + 1, iy) * u) * (1 - v) + (h(ix, iy + 1) * (1 - u) + h(ix + 1, iy + 1) * u) * v
    }

    /** The light of the place itself at [daylight]: warm at dusk, cold at night, shaded in deep woods. */
    fun ambient(map: MapDef, daylight: Float): DoubleArray {
        val deep = map.id == "deep_forest"
        fun mix(a: DoubleArray, b: DoubleArray, t: Double) = DoubleArray(3) { a[it] + (b[it] - a[it]) * t.coerceIn(0.0, 1.0) }
        return when (map.kind) {
            MapKind.CAVE -> doubleArrayOf(0.13, 0.13, 0.18)
            // a room with a fire (new style, 10.10.) is darker about its corners: the fire lights it, the window a little
            MapKind.INTERIOR -> if (hasHearth(map)) mix(doubleArrayOf(0.16, 0.14, 0.15), doubleArrayOf(0.42, 0.4, 0.38), daylight.toDouble())
                else mix(doubleArrayOf(0.36, 0.32, 0.3), doubleArrayOf(0.7, 0.64, 0.56), daylight.toDouble())
            else -> {
                val day = if (deep) doubleArrayOf(0.8, 0.86, 0.8) else if (map.kind == MapKind.FOREST) doubleArrayOf(0.96, 0.98, 0.93) else doubleArrayOf(1.0, 0.99, 0.96)
                val dusk = if (deep) doubleArrayOf(0.64, 0.5, 0.5) else doubleArrayOf(0.88, 0.68, 0.6)
                val night = if (deep) doubleArrayOf(0.13, 0.16, 0.27) else if (map.kind == MapKind.TOWN) doubleArrayOf(0.16, 0.19, 0.32) else doubleArrayOf(0.2, 0.24, 0.38)
                val d = daylight.toDouble()
                if (d >= 0.85) day else if (d >= 0.35) mix(dusk, day, (d - 0.35) / 0.5) else mix(night, dusk, (d / 0.35) * (d / 0.35))
            }
        }
    }

    private fun hasHearth(map: MapDef) = (0 until map.height).any { y -> (0 until map.width).any { x -> map.tile(x, y) == Tile.HEARTH } }

    /** Whether the map needs a light image at all (a village at noon does not). */
    fun needed(map: MapDef, daylight: Float): Boolean = map.kind != MapKind.TOWN || daylight < 0.85f

    /**
     * The light image for the map region from map pixel ([x0], [y0]), [w] × [h] map pixels, one
     * pixel per [RES] map pixels, with the hero's lantern at map pixel ([heroX], [heroY]) — the
     * middle of the hero. White is full light, black is darkness.
     */
    fun lightmap(map: MapDef, daylight: Float, heroX: Int, heroY: Int, x0: Int, y0: Int, w: Int, h: Int): PixelImage {
        val st = static(map)
        val mgw = map.width * T / CELL; val mgh = map.height * T / CELL
        // the grid cells under the region, one more on each side for smoothing
        val cx0 = floor(x0.toDouble() / CELL).toInt() - 1; val cy0 = floor(y0.toDouble() / CELL).toInt() - 1
        val gw = w / CELL + 3; val gh = h / CELL + 3
        val amb = ambient(map, daylight)
        val kn = strength(map, When.NIGHT, daylight); val kd = strength(map, When.DAY, daylight)
        val g = DoubleArray(gw * gh * 3)
        for (gy in 0 until gh) for (gx in 0 until gw) {
            val mx = (cx0 + gx).coerceIn(0, mgw - 1); val my = (cy0 + gy).coerceIn(0, mgh - 1)
            val m = my * mgw + mx
            val o = (gy * gw + gx) * 3
            for (c in 0..2) g[o + c] = amb[c] * st.shade[m] + st.always[m * 3 + c] + st.night[m * 3 + c] * kn + st.day[m * 3 + c] * kd
        }
        // the lantern: always in caves, outdoors only when it gets dark
        val lantern = when (map.kind) {
            MapKind.CAVE -> 0.9
            MapKind.INTERIOR -> 0.0
            // in the village the street lamps and windows light the way, the lantern stays small
            MapKind.TOWN -> 0.4 * kn
            else -> 0.9 * kn
        }
        add(map, g, gw, gh, Source(heroX.toDouble(), heroY.toDouble(), Kind.TORCH, lanternColor, T * (if (map.kind == MapKind.TOWN) 2.2 else 3.4), 1.0), lantern, cx0, cy0)
        // in a cave the light stops at the rock tile by tile; softened, the edge of the light is round, not a staircase
        if (map.kind == MapKind.CAVE) repeat(2) {
            val src = g.copyOf()
            for (gy in 0 until gh) for (gx in 0 until gw) for (c in 0..2) {
                var sum = 0.0; var n = 0
                for (dy in -2..2) for (dx in -2..2) {
                    val x = (gx + dx).coerceIn(0, gw - 1); val y = (gy + dy).coerceIn(0, gh - 1)
                    sum += src[(y * gw + x) * 3 + c]; n++
                }
                g[(gy * gw + gx) * 3 + c] = sum / n
            }
        }
        val ow = w / RES; val oh = h / RES
        val img = PixelImage(ow, oh)
        for (y in 0 until oh) for (x in 0 until ow) {
            val px = x0 + x * RES + RES / 2.0; val py = y0 + y * RES + RES / 2.0
            val gx = px / CELL - 0.5 - cx0; val gy = py / CELL - 0.5 - cy0
            val ix = floor(gx).toInt().coerceIn(0, gw - 2); val iy = floor(gy).toInt().coerceIn(0, gh - 2)
            val fx = (gx - ix).coerceIn(0.0, 1.0); val fy = (gy - iy).coerceIn(0.0, 1.0)
            val tx = floor(px / T).toInt(); val ty = floor(py / T).toInt()
            // in caves the top of a rock mass (rock below it too) gets little light
            val roof = map.kind == MapKind.CAVE && map.tile(tx, ty) in opaque && map.tile(tx, ty + 1) in opaque
            fun ch(c: Int): Int {
                fun at(ax: Int, ay: Int) = g[(ay * gw + ax) * 3 + c]
                val a = at(ix, iy) * (1 - fx) + at(ix + 1, iy) * fx
                val b = at(ix, iy + 1) * (1 - fx) + at(ix + 1, iy + 1) * fx
                val v = (a * (1 - fy) + b * fy) * (if (roof) 0.5 else 1.0)
                return (v.coerceIn(0.0, 1.0) * 255).toInt()
            }
            img.pixels[y * ow + x] = (0xFF shl 24) or (ch(0) shl 16) or (ch(1) shl 8) or ch(2)
        }
        return img
    }
}
