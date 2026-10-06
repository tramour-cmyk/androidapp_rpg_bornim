package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.exp
import kotlin.math.sqrt

/**
 * Light on cave maps: the cave is dark, and torches, fires, glowing mushrooms, crystals, cracks of
 * daylight and the hero's lantern light it. Rock walls stop the light. The result is a coarse grid
 * of light colours ([CELL] map pixels per cell) that is laid over the map, multiplied and smoothed.
 */
object CaveLight {
    const val CELL = 8

    enum class Kind { TORCH, FIRE, SHROOM, CRYSTAL, SKY, EXIT }

    /** A light at map pixel ([x], [y]); [reach] in map pixels. */
    class Source(val x: Double, val y: Double, val kind: Kind, val color: Int, val reach: Double, val power: Double)

    private const val T = WorldArt.T
    private val opaque = setOf(Tile.CAVE_WALL, Tile.TORCH, Tile.CRYSTAL)
    private val ambient = doubleArrayOf(0.13, 0.13, 0.18)
    private val lantern = argb(0xFFD4A8)

    private val sourceCache = HashMap<String, List<Source>>()
    private val baseCache = HashMap<String, DoubleArray>()

    fun sources(map: MapDef): List<Source> = synchronized(sourceCache) {
        sourceCache.getOrPut(map.id) {
            val out = mutableListOf<Source>()
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                val cx = tx * T + T / 2.0; val cy = ty * T + T / 2.0
                when (map.tile(tx, ty)) {
                    Tile.TORCH -> out += Source(cx, ty * T + 12.0, Kind.TORCH, argb(0xFFB060), T * 3.6, 1.15)
                    Tile.CAMPFIRE -> out += Source(cx, cy, Kind.FIRE, argb(0xFF9A48), T * 4.4, 1.35)
                    Tile.GLOWSHROOM -> out += Source(cx, cy, Kind.SHROOM, argb(0x60E8D8), T * 2.4, 0.8)
                    Tile.CRYSTAL -> out += Source(cx, ty * T + 26.0, Kind.CRYSTAL, argb(0xB088FF), T * 2.6, 0.85)
                    Tile.SKYLIGHT -> out += Source(cx, cy, Kind.SKY, argb(0xE8F0FF), T * 3.0, 1.15)
                    Tile.CAVE_EXIT -> out += Source(cx, cy, Kind.EXIT, argb(0xFFF4D8), T * 3.4, 1.0)
                    else -> {}
                }
            }
            out
        }
    }

    /** Whether light from ([sx], [sy]) reaches ([x], [y]) without passing through rock. */
    private fun clear(map: MapDef, sx: Double, sy: Double, x: Double, y: Double): Boolean {
        val stx = (sx / T).toInt(); val sty = (sy / T).toInt()
        val dtx = (x / T).toInt(); val dty = (y / T).toInt()
        val dist = sqrt((x - sx) * (x - sx) + (y - sy) * (y - sy))
        val steps = (dist / 5).toInt()
        for (i in 1 until steps) {
            val f = i / steps.toDouble()
            val tx = ((sx + (x - sx) * f) / T).toInt(); val ty = ((sy + (y - sy) * f) / T).toInt()
            if ((tx == stx && ty == sty) || (tx == dtx && ty == dty)) continue
            if (map.tile(tx, ty) in opaque) return false
        }
        return true
    }

    /** Whether [s] lights map pixel ([x], [y]), i.e. no rock lies between. */
    fun reaches(map: MapDef, s: Source, x: Double, y: Double) = clear(map, s.x, s.y, x, y)

    private fun add(map: MapDef, out: DoubleArray, w: Int, s: Source, h: Int) {
        val r = s.reach * 1.5
        val c0 = ((s.x - r) / CELL).toInt().coerceAtLeast(0); val c1 = ((s.x + r) / CELL).toInt().coerceAtMost(w - 1)
        val r0 = ((s.y - r) / CELL).toInt().coerceAtLeast(0); val r1 = ((s.y + r) / CELL).toInt().coerceAtMost(h - 1)
        val cr = ((s.color shr 16) and 0xFF) / 255.0; val cg = ((s.color shr 8) and 0xFF) / 255.0; val cb = (s.color and 0xFF) / 255.0
        for (cy in r0..r1) for (cx in c0..c1) {
            val x = cx * CELL + CELL / 2.0; val y = cy * CELL + CELL / 2.0
            val d = sqrt((x - s.x) * (x - s.x) + (y - s.y) * (y - s.y))
            if (d > r) continue
            val k = s.power * exp(-(d / s.reach) * (d / s.reach) * 2.0)
            if (k < 0.01 || !clear(map, s.x, s.y, x, y)) continue
            val i = (cy * w + cx) * 3
            out[i] += cr * k; out[i + 1] += cg * k; out[i + 2] += cb * k
        }
    }

    /** The light from everything that stays in place, computed once per map. */
    private fun base(map: MapDef): DoubleArray = synchronized(baseCache) {
        baseCache.getOrPut(map.id) {
            val w = map.width * T / CELL; val h = map.height * T / CELL
            val out = DoubleArray(w * h * 3)
            for (i in 0 until w * h) { out[i * 3] = ambient[0]; out[i * 3 + 1] = ambient[1]; out[i * 3 + 2] = ambient[2] }
            for (s in sources(map)) add(map, out, w, s, h)
            out
        }
    }

    /** Map pixels per pixel of the finished light image. */
    const val RES = 4

    /**
     * The light over the map with the hero's lantern at map pixel ([heroX], [heroY]) — the middle
     * of the hero. One pixel per [RES] map pixels, smoothed between the grid cells; white is full
     * light, black is darkness. Rock above the walls stays dark.
     */
    fun lightmap(map: MapDef, heroX: Int, heroY: Int): PixelImage {
        val gw = map.width * T / CELL; val gh = map.height * T / CELL
        val light = base(map).copyOf()
        add(map, light, gw, Source(heroX.toDouble(), heroY.toDouble(), Kind.TORCH, lantern, T * 3.4, 0.9), gh)
        val w = map.width * T / RES; val h = map.height * T / RES
        val img = PixelImage(w, h)
        for (y in 0 until h) for (x in 0 until w) {
            val gx = (x + 0.5) * RES / CELL - 0.5; val gy = (y + 0.5) * RES / CELL - 0.5
            val x0 = kotlin.math.floor(gx).toInt(); val y0 = kotlin.math.floor(gy).toInt()
            val fx = gx - x0; val fy = gy - y0
            fun l(cx: Int, cy: Int, c: Int) = light[((cy.coerceIn(0, gh - 1)) * gw + cx.coerceIn(0, gw - 1)) * 3 + c]
            val tx = x * RES / T; val ty = y * RES / T
            // the top of a rock mass (rock below it too) gets little light
            val roof = map.tile(tx, ty) in opaque && map.tile(tx, ty + 1) in opaque
            fun ch(c: Int): Int {
                val a = l(x0, y0, c) * (1 - fx) + l(x0 + 1, y0, c) * fx
                val b = l(x0, y0 + 1, c) * (1 - fx) + l(x0 + 1, y0 + 1, c) * fx
                val v = (a * (1 - fy) + b * fy) * (if (roof) 0.35 else 1.0)
                return (v.coerceAtMost(1.0) * 255).toInt()
            }
            img.pixels[y * w + x] = (0xFF shl 24) or (ch(0) shl 16) or (ch(1) shl 8) or ch(2)
        }
        return img
    }
}
