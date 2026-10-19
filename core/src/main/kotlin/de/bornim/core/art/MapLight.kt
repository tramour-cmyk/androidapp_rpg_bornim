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
    /** 13e.6 (user 15.10.: passt): in a cave what was seen once sinks this far into the dark out of sight (outdoors 0.5). */
    const val CAVE_SEEN_DIM = 0.45f

    /** Map pixels per light grid cell. */
    const val CELL = 8

    /** Map pixels per pixel of the finished light image. */
    const val RES = 2

    enum class Kind { TORCH, FIRE, SHROOM, CRYSTAL, SKY, EXIT, LAMP, WINDOW, CANDLE, DOOR }

    /**
     * When a light shines. [SUN] and [MOON] are the open sky falling in through a shaft or a cave's mouth (27o): by day
     * white daylight, at night cool moonlight, also in a cave, where the place's own lights shine all the time.
     */
    enum class When { ALWAYS, NIGHT, DAY, SUN, MOON }

    /** The colour of moonlight falling into a cave (27o), the cool blue of the night outdoors (D3.14). */
    const val MOON_RGB = 0xA4B6E4

    /** A light at map pixel ([x], [y]); [reach] in map pixels. */
    class Source(val x: Double, val y: Double, val kind: Kind, val color: Int, val reach: Double, val power: Double, val shines: When = When.ALWAYS)

    private const val T = WorldArt.T
    private val opaque = setOf(Tile.CAVE_WALL, Tile.TORCH, Tile.CRYSTAL, Tile.WALL, Tile.ROOF, Tile.ROOF_BLUE, Tile.WINDOW)
    private val lanternColor = argb(0xFFD4A8)
    private val torchColor = argb(0xFFB868)
    private val sparkColor = argb(0xDCE8FF)

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
                    // 27o: daylight by day, at night a weaker, cooler moonlight; between them they fade at dawn and dusk
                    Tile.SKYLIGHT -> {
                        out += Source(cx, cy, Kind.SKY, argb(0xE8F0FF), T * 3.0, 1.15, When.SUN)
                        out += Source(cx, cy, Kind.SKY, argb(MOON_RGB), T * 2.6, 0.5, When.MOON)
                    }
                    Tile.CAVE_EXIT -> {
                        out += Source(cx, cy, Kind.EXIT, argb(0xFFF4D8), T * 3.4, 1.0, When.SUN)
                        out += Source(cx, cy, Kind.EXIT, argb(MOON_RGB), T * 3.0, 0.45, When.MOON)
                    }
                    Tile.LAMP -> out += Source(cx, ty * T + 8.0, Kind.LAMP, argb(0xFFD49A), T * 2.6, 0.95, When.NIGHT)
                    // light falls out of a lit window onto the ground in front of the house
                    Tile.WINDOW -> if (!indoor && map.tile(tx, ty + 1).walkable) out += Source(cx, ty * T + T + 6.0, Kind.WINDOW, argb(0xFFC880), T * 1.6, 0.7, When.NIGHT)
                        // indoors, a window lets in grey daylight, onto the floor on the room's side of its wall (5h.1: also in the front walls)
                        // D1.3: also in a room without a fire (the temple's windows)
                        else if (indoor) {
                            val (lx, ly) = when {
                                map.tile(tx, ty + 1).walkable -> cx to ty * T + T + 8.0
                                map.tile(tx, ty - 1).walkable -> cx to ty * T - 8.0
                                map.tile(tx - 1, ty).walkable -> tx * T - 8.0 to cy
                                else -> tx * T + T + 8.0 to cy
                            }
                            out += Source(lx, ly, Kind.WINDOW, argb(0xD8E0EC), T * 2.6, 0.55, When.DAY)
                        }
                    // a fire in the back wall: the light comes out of its mouth onto the floor in front
                    Tile.HEARTH -> {
                        if (map.tile(tx - 1, ty) != Tile.HEARTH) out += Source((tx + 1) * T.toDouble(), (ty + 1) * T + 4.0, Kind.FIRE, argb(0xFF9046), T * 3.6, 1.05)
                        // D1.3: a candle on the mantel shelf gives its own small light, a paler yellow beside the fire's orange
                        if (MapRoomIso.smallFlame(map, tx, ty)) out += Source(cx, (ty + 1) * T + 4.0, Kind.CANDLE, argb(0xFFC070), T * 1.4, 0.4)
                    }
                    // a candle on a table: a small warm island, the dark close about it (10.10., 6.8)
                    Tile.TABLE -> if (indoor) out += Source(cx, cy, Kind.CANDLE, argb(0xFFB870), T * (if (hasHearth(map)) 1.7 else 2.8), if (hasHearth(map)) 0.62 else 0.6)
                    Tile.CANDLES -> out += Source(cx, cy - 10, Kind.CANDLE, argb(0xFFC880), T * 2.2, 0.7)
                    Tile.DESK -> out += Source(cx, cy - 6, Kind.CANDLE, argb(0xFFB870), T * 1.8, 0.6)
                    Tile.ALTAR -> out += Source(cx, cy, Kind.CANDLE, argb(0xFFE0A0), T * 3.2, 0.75)
                    Tile.COUNTER -> if (indoor) out += Source(cx, cy, Kind.CANDLE, argb(0xFFB870), T * (if (hasHearth(map)) 1.5 else 2.4), if (hasHearth(map)) 0.5 else 0.45)
                    Tile.DOOR -> if (indoor) out += Source(cx, cy - 4, Kind.DOOR, argb(0xE8ECF0), T * 3.0, 0.6, When.DAY)
                    // D1.3: a small flame drawn on a thing (candlestick on a trunk, candle in the font) gives its small light
                    Tile.TRUNK, Tile.FONT -> if (indoor && MapRoomIso.smallFlame(map, tx, ty)) out += Source(cx, cy - 8, Kind.CANDLE, argb(0xFFC070), T * 1.5, 0.45)
                    else -> {}
                }
            }
            // 80a: old Kael's lantern on its plinth by his door, a small dull amber island at night
            // 69e: the lantern at the south end of the bridge, the crossing lit on the way to the inn
            if (map.id == "village") MapTownIso.bridgeLanternAt().let { (lx, ly) -> out += Source(lx, ly, Kind.LAMP, argb(0xFFD49A), T * 2.4, 0.8, When.NIGHT) }
            if (map.id == "village") MapTownIso.KAEL_LANTERN.let { (lx, ly) -> out += Source(lx * T + 6.0, ly * T + 6.0, Kind.CANDLE, argb(0xE09A50), T * 1.2, 0.3, When.NIGHT) }
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
            // seen diagonally a cave's low walls (about a metre) let the light of a fire over them (13e, test of 0.1.689)
            // 176a (Chef 18.10.): outdoors the rock round a cave's mouth is a low outcrop the light falls onto and over,
            // not a wall throwing a sharp wedge of shadow
            val t = map.tile(tx, ty)
            if (t == Tile.CAVE_WALL && map.kind != MapKind.CAVE) continue
            if (t in opaque && !(map.kind == MapKind.CAVE && MapCaveIso.low(map, tx, ty))) return false
        }
        return true
    }

    /** Whether [s] lights map pixel ([x], [y]), i.e. no rock or wall lies between. */
    fun reaches(map: MapDef, s: Source, x: Double, y: Double) = clear(map, s.x, s.y, x, y)

    /** How strongly a light of the given timing shines at [daylight] (0 night … 1 day). */
    fun strength(map: MapDef, shines: When, daylight: Float): Double = when {
        shines == When.SUN -> daylight.toDouble().coerceIn(0.0, 1.0)
        shines == When.MOON -> ((0.7 - daylight) / 0.5).coerceIn(0.0, 1.0)
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
    private class Static(val always: DoubleArray, val night: DoubleArray, val day: DoubleArray, val sun: DoubleArray, val moon: DoubleArray, val shade: DoubleArray)

    private fun static(map: MapDef): Static = synchronized(staticCache) {
        staticCache.getOrPut(map.id) {
            val gw = map.width * T / CELL; val gh = map.height * T / CELL
            val always = DoubleArray(gw * gh * 3); val night = DoubleArray(gw * gh * 3); val day = DoubleArray(gw * gh * 3)
            val sun = DoubleArray(gw * gh * 3); val moon = DoubleArray(gw * gh * 3)
            for (s in sources(map)) add(map, when (s.shines) { When.ALWAYS -> always; When.NIGHT -> night; When.DAY -> day; When.SUN -> sun; When.MOON -> moon }, gw, gh, s, 1.0)
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
            Static(always, night, day, sun, moon, shade)
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
            // 13e.6: away from visible sources nearly black, only outlines
            MapKind.CAVE -> doubleArrayOf(0.05, 0.05, 0.075)
            // a room with a fire (new style, 10.10.) is darker about its corners: the fire lights it, the window a little
            MapKind.INTERIOR -> if (hasHearth(map)) mix(doubleArrayOf(0.13, 0.115, 0.125), doubleArrayOf(0.31, 0.29, 0.285), daylight.toDouble())
                // D1.2: no fire, so at night only candles and a little moonlight: dark like the other rooms, a shade colder
                else mix(doubleArrayOf(0.13, 0.13, 0.17), doubleArrayOf(0.62, 0.58, 0.52), daylight.toDouble())
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

    /**
     * D3.13a (user 15.10., 20:0x: the cot's roof at night half bright, half dark): the light image lies on the ground and
     * is laid over everything, so a roof showed the light of the ground behind its house (seen diagonally a point [z]
     * high stands where the ground [z] · ZS / TH tiles further back would). Where a house covers the ground on screen its
     * walls and roof take the light in front of its door row instead, along the house the way it falls there, fading a
     * towards the ambient light as they rise (at the ridge 60 %).
     */
    private class Cover(val x0: Int, val y0: Int, val w: Int, val h: Int, val frontY: Double, val at: FloatArray, val fade: FloatArray, val depth: FloatArray, val weight: FloatArray, val eaveFade: Double, val home: Box)
    /** A rectangle in map pixels. */
    private class Box(val left: Double, val top: Double, val right: Double, val bottom: Double)

    /**
     * How far (light image pixels) inside its outline the light of a house runs soft into the ground light there: at the
     * outline it changed at a line before, which showed as hard strokes beside the cot and between houses (user 15.10., 20:5x).
     */
    private const val SOFT = 10

    /**
     * How much of the house's light each pixel takes: 1 [SOFT] inside its outline and further in, down to 0 at the
     * outline and outside, where the ground keeps its own.
     */
    private fun soften(bw: Int, bh: Int, at: FloatArray): FloatArray {
        val inside = BooleanArray(bw * bh) { !at[it].isNaN() }
        // the share: the inside averaged over a square 2·SOFT+1 wide, eased (two passes, rows then columns)
        val r = SOFT
        val rows = FloatArray(bw * bh)
        for (v in 0 until bh) {
            var sum = 0
            for (u in -r - 1 until bw) {
                if (u + r < bw && u + r >= 0 && inside[v * bw + u + r]) sum++
                if (u - r - 1 >= 0 && inside[v * bw + u - r - 1]) sum--
                if (u >= 0) rows[v * bw + u] = sum.toFloat()
            }
        }
        val share = FloatArray(bw * bh)
        for (u in 0 until bw) {
            var sum = 0f
            for (v in -r - 1 until bh) {
                if (v + r < bh && v + r >= 0) sum += rows[(v + r) * bw + u]
                if (v - r - 1 >= 0) sum -= rows[(v - r - 1) * bw + u]
                if (v >= 0 && inside[v * bw + u]) {
                    // inside only: the ground round the house keeps its own light, the house blends into it at its outline
                    val t = ((sum / ((2 * r + 1) * (2 * r + 1)) - 0.5f) * 2f).coerceIn(0f, 1f)
                    share[v * bw + u] = t * t * (3 - 2 * t)
                }
            }
        }
        return share
    }

    private val coverCache = HashMap<String, List<Cover>>()

    private fun covers(map: MapDef): List<Cover> = synchronized(coverCache) {
        coverCache.getOrPut(map.id) {
            if (map.kind == MapKind.CAVE || map.kind == MapKind.INTERIOR) return@getOrPut emptyList()
            val zs = MapRoomIso.ZS / MapRoomIso.TH
            MapTownIso.houses(map).map { (f, _) ->
                val g = MapTownIso.shape(map, f)
                val o = g.overhang
                val x0 = f.x - o; val x1 = f.x + f.n + o; val y0 = f.top - o; val y1 = f.y + 1 + o; val ym = (f.top + f.y + 1) / 2.0
                val run = ym - y0
                fun height(x: Double, y: Double) = if (x < x0 || x > x1 || y < y0 || y > y1) -1.0 else g.ridge - kotlin.math.abs(y - ym) / run * (g.ridge - g.eave)
                val reach = g.ridge * zs
                // the ground (in light image pixels) the house can stand before on screen
                val bx0 = floor((x0 - reach) * T / RES).toInt(); val by0 = floor((y0 - reach) * T / RES).toInt()
                val bw = kotlin.math.ceil(x1 * T / RES).toInt() - bx0; val bh = kotlin.math.ceil(y1 * T / RES).toInt() - by0
                val at = FloatArray(bw * bh) { Float.NaN }; val fade = FloatArray(bw * bh); val depth = FloatArray(bw * bh)
                val steps = (reach * 16).toInt() + 1
                for (v in 0 until bh) for (u in 0 until bw) {
                    val gx = ((bx0 + u) * RES + RES / 2.0) / T; val gy = ((by0 + v) * RES + RES / 2.0) / T
                    // along the line of sight from the viewer down to this ground point: the first point inside the house
                    for (k in steps downTo 0) {
                        val sft = reach * k / steps
                        val z = sft / zs
                        val hz = height(gx + sft, gy + sft)
                        if (hz < 0 || z > hz) continue
                        at[v * bw + u] = ((gx + sft).coerceIn(f.x + 0.0, f.x + f.n + 0.0) * T).toFloat()
                        fade[v * bw + u] = (0.6 * z / g.ridge).toFloat()
                        depth[v * bw + u] = sft.toFloat()
                        break
                    }
                }
                val weight = soften(bw, bh, at)
                Cover(bx0, by0, bw, bh, (f.y + 1.15) * T, at, fade, depth, weight, 0.6 * g.eave / g.ridge, Box(x0 * T, y0 * T, x1 * T, y1 * T))
            }
        }
    }

    /**
     * How much a house stands before the ground at map pixel ([px], [py]) on screen: 1 hidden, 0 in sight, soft at
     * its outline. A lamp behind the temple threw its glow onto the roof (D3.13a, night picture of 15.10.).
     */
    fun behindHouse(map: MapDef, px: Double, py: Double): Float {
        val lx = floor(px / RES).toInt(); val ly = floor(py / RES).toInt()
        val houses = covers(map)
        // a window or a lamp on a house, or just before it, is in sight, even where a neighbour stands before its foot
        if (houses.any { c -> px >= c.home.left - T * 0.6 && px <= c.home.right + T * 0.6 && py >= c.home.top - T * 0.6 && py <= c.home.bottom + T * 0.6 }) return 0f
        var most = 0f
        for (c in houses) {
            val u = lx - c.x0; val v = ly - c.y0
            if (u < 0 || v < 0 || u >= c.w || v >= c.h) continue
            most = maxOf(most, c.weight[v * c.w + u])
        }
        return most
    }

    /** The light the hero carries (84.1, 84.5). */
    enum class Carried { NONE, SPARK, TORCH }

    /**
     * The light the hero carries as a source at map pixel ([x], [y]), or null. 176 (Chef 18.10.: "leuchtet nicht richtig
     * aus"): the light reaches about as far as the hero sees with it ([de.bornim.core.Light.TORCH_SIGHT] 6.5 tiles, the
     * spark 5.5), still a third bright at 5 tiles, instead of fading out at 4 while the fog showed 6.5; the spark stays weaker.
     */
    fun carriedSource(carried: Carried, x: Double, y: Double): Source? = when (carried) {
        Carried.TORCH -> Source(x, y, Kind.TORCH, torchColor, T * 6.2, 1.35)
        Carried.SPARK -> Source(x, y, Kind.TORCH, sparkColor, T * 5.2, 1.05)
        Carried.NONE -> null
    }

    /** Whether the map needs a light image at all (a village at noon does not). */
    fun needed(map: MapDef, daylight: Float): Boolean = map.kind != MapKind.TOWN || daylight < 0.85f

    /**
     * The light image for the map region from map pixel ([x0], [y0]), [w] × [h] map pixels, one
     * pixel per [RES] map pixels, with the hero's lantern at map pixel ([heroX], [heroY]) — the
     * middle of the hero. White is full light, black is darkness. [carried] is the light the hero carries (84.1/84.5).
     */
    fun lightmap(map: MapDef, daylight: Float, heroX: Int, heroY: Int, x0: Int, y0: Int, w: Int, h: Int, carried: Carried = Carried.NONE): PixelImage {
        val st = static(map)
        val mgw = map.width * T / CELL; val mgh = map.height * T / CELL
        // the grid cells under the region, one more on each side for smoothing
        val cx0 = floor(x0.toDouble() / CELL).toInt() - 1; val cy0 = floor(y0.toDouble() / CELL).toInt() - 1
        val gw = w / CELL + 3; val gh = h / CELL + 3
        val amb = ambient(map, daylight)
        val kn = strength(map, When.NIGHT, daylight); val kd = strength(map, When.DAY, daylight)
        val ks = strength(map, When.SUN, daylight); val km = strength(map, When.MOON, daylight)
        val g = DoubleArray(gw * gh * 3)
        for (gy in 0 until gh) for (gx in 0 until gw) {
            val mx = (cx0 + gx).coerceIn(0, mgw - 1); val my = (cy0 + gy).coerceIn(0, mgh - 1)
            val m = my * mgw + mx
            val o = (gy * gw + gx) * 3
            for (c in 0..2) g[o + c] = amb[c] * st.shade[m] + st.always[m * 3 + c] + st.night[m * 3 + c] * kn + st.day[m * 3 + c] * kd +
                st.sun[m * 3 + c] * ks + st.moon[m * 3 + c] * km
        }
        // the lantern: outdoors only when it gets dark; never in a cave, which is lit only by its own fires, torches,
        // shafts and mushrooms (13e.6 = B, user 14.10.: no light round the hero without a source)
        val lantern = when (map.kind) {
            MapKind.CAVE -> 0.0
            MapKind.INTERIOR -> 0.0
            // in the village the street lamps and windows light the way, the lantern stays small
            MapKind.TOWN -> 0.4 * kn
            else -> 0.9 * kn
        }
        // the light without the hero's lantern, for the roofs: carried at the hip it lights the walls, not the roof (D3.13a)
        val unlit = g.copyOf()
        add(map, g, gw, gh, Source(heroX.toDouble(), heroY.toDouble(), Kind.TORCH, lanternColor, T * (if (map.kind == MapKind.TOWN) 2.2 else 3.4), 1.0), lantern, cx0, cy0)
        // 84.1: a torch in the hand, warm and further than the lantern, also in a cave and indoors; 84.5: the spark
        // overhead, cool white, smaller than the torch (Vorgangsarchiv 84.5: the spark stays weaker)
        val dark = if (map.kind == MapKind.CAVE) 1.0 else kn
        carriedSource(carried, heroX.toDouble(), heroY.toDouble())?.let { add(map, g, gw, gh, it, dark, cx0, cy0) }
        // 13e.6: the hero in the dark of a cave as an outline with a faint rim, no light on the ground round him
        if (map.kind == MapKind.CAVE) add(map, g, gw, gh, Source(heroX.toDouble(), heroY.toDouble(), Kind.TORCH, argb(0xA8B4D0), T * 0.55, 0.16), 1.0, cx0, cy0)
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
        val houses = covers(map)
        for (y in 0 until oh) for (x in 0 until ow) {
            val px = x0 + x * RES + RES / 2.0; val py = y0 + y * RES + RES / 2.0
            // a house standing before this ground on screen: the light in front of it (D3.13a), soft at its outline
            var cover: Cover? = null; var ci = 0
            val lx = Math.floorDiv(x0, RES) + x; val ly = Math.floorDiv(y0, RES) + y
            for (c in houses) {
                val u = lx - c.x0; val v = ly - c.y0
                if (u < 0 || v < 0 || u >= c.w || v >= c.h) continue
                val i = v * c.w + u
                if (c.at[i].isNaN() || c.weight[i] <= 0f) continue
                val b = cover
                if (b != null && (b.weight[ci] > c.weight[i] || b.weight[ci] == c.weight[i] && b.depth[ci] >= c.depth[i])) continue
                cover = c; ci = i
            }
            // in caves the top of a rock mass (rock below it too) gets little light, shading off between the tile
            // centres (test 13.10.: by whole tiles it showed as hard straight edges and bands across the rock)
            val roof = if (map.kind != MapKind.CAVE) 0.0 else {
                val rx = px / T - 0.5; val ry = py / T - 0.5
                val tx = floor(rx).toInt(); val ty = floor(ry).toInt()
                val ux = rx - tx; val uy = ry - ty
                fun top(ax: Int, ay: Int) = if (map.tile(ax, ay) in opaque && map.tile(ax, ay + 1) in opaque) 1.0 else 0.0
                (top(tx, ty) * (1 - ux) + top(tx + 1, ty) * ux) * (1 - uy) + (top(tx, ty + 1) * (1 - ux) + top(tx + 1, ty + 1) * ux) * uy
            }
            fun ground(qx: Double, qy: Double, c: Int, src: DoubleArray = g): Double {
                val gx = qx / CELL - 0.5 - cx0; val gy = qy / CELL - 0.5 - cy0
                val ix = floor(gx).toInt().coerceIn(0, gw - 2); val iy = floor(gy).toInt().coerceIn(0, gh - 2)
                val fx = (gx - ix).coerceIn(0.0, 1.0); val fy = (gy - iy).coerceIn(0.0, 1.0)
                fun at(ax: Int, ay: Int) = src[(ay * gw + ax) * 3 + c]
                val a = at(ix, iy) * (1 - fx) + at(ix + 1, iy) * fx
                val b = at(ix, iy + 1) * (1 - fx) + at(ix + 1, iy + 1) * fx
                return a * (1 - fy) + b * fy
            }
            fun ch(c: Int): Int {
                var v = ground(px, py, c) * (1.0 - 0.5 * roof)
                val k = cover
                if (k != null) {
                    val fade = k.fade[ci].toDouble(); val share = k.weight[ci].toDouble()
                    // the lantern's share fades out up the wall, gone at the eaves
                    val up = (fade / k.eaveFade).coerceIn(0.0, 1.0)
                    val front = ground(k.at[ci].toDouble(), k.frontY, c) * (1 - up) + ground(k.at[ci].toDouble(), k.frontY, c, unlit) * up
                    val lit = front * (1 - fade) + amb[c] * fade
                    v = v * (1 - share) + lit * share
                }
                return (v.coerceIn(0.0, 1.0) * 255).toInt()
            }
            img.pixels[y * ow + x] = (0xFF shl 24) or (ch(0) shl 16) or (ch(1) shl 8) or ch(2)
        }
        return img
    }
}
