package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Trees, rocks, fallen trunks, standing stones and undergrowth of the woods in the new style
 * (09.10.), at double resolution like [MapGround]: seen at a slant from above, lit from the upper
 * left. Oaks with a trunk, roots and a lumpy crown; spruces in drooping tiers; dead grey trees with
 * bare branches; boulders with a shaded front and moss; bushes, ferns and dry branches on the
 * ground near the trees. Each kind comes in several variants, drawn once and kept.
 *
 * The pictures are [WorldArt.Obj]s with density [MapGround.D]; their shadows on the ground are a
 * layer of their own ([shadows]), drawn under the characters and faded by the time of day.
 */
object MapFlora {
    private const val D = MapGround.D
    private const val S = MapGround.S
    private const val T = WorldArt.T

    // ------------------------------------------------------------------ noise

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun vnoise(x: Double, y: Double, cell: Double, s: Int): Double {
        val fx = x / cell; val fy = y / cell
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var v = fy - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    private fun ramp(vararg c: Int) = IntArray(c.size) { argb(c[it]) }

    private val LEAF = ramp(0x66733F, 0x4A5A33, 0x37472A, 0x28361F, 0x1A2414, 0x0F160C)
    private val LEAF_DEEP = ramp(0x56643A, 0x3E4E2E, 0x2E3C24, 0x202C19, 0x141C10, 0x0A1009)
    private val PINE = ramp(0x4E6A52, 0x36503E, 0x24382C, 0x16241C, 0x0C1610)
    private val BARK = ramp(0x6A5644, 0x4A3A2E, 0x2A221C)
    private val DEAD = ramp(0x8A8072, 0x5E564C, 0x342E2A)
    private val STONE = ramp(0x9A9484, 0x767062, 0x524C44, 0x34302C)
    private val MOSS = argb(0x4A5A30)
    private val SHADOW_RGB = 0x080C06

    // ------------------------------------------------------------------ drawing helpers

    private fun put(img: PixelImage, x: Int, y: Int, c: Int) { if (x in 0 until img.width && y in 0 until img.height) img.pixels[y * img.width + x] = c }

    private fun disc(img: PixelImage, cx: Double, cy: Double, r: Double, c: Int) {
        for (y in (cy - r).toInt()..(cy + r).toInt() + 1) for (x in (cx - r).toInt()..(cx + r).toInt() + 1)
            if ((x + 0.5 - cx) * (x + 0.5 - cx) + (y + 0.5 - cy) * (y + 0.5 - cy) <= r * r) put(img, x, y, c)
    }

    /** A thick line, round at the ends. */
    private fun stroke(img: PixelImage, x0: Double, y0: Double, x1: Double, y1: Double, w: Double, c: Int) {
        val steps = max(1, (max(abs(x1 - x0), abs(y1 - y0)) * 1.5).toInt())
        for (i in 0..steps) { val t = i / steps.toDouble(); disc(img, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, w / 2, c) }
    }

    /**
     * A leafy crown at a slant: a lumpy dome lit from the upper left, with leaf texture, its
     * underside in its own shade. [squash] flattens it (bushes).
     */
    private fun crown(img: PixelImage, cx: Double, cy: Double, r: Double, tones: IntArray, seed: Int, squash: Double = 0.85) {
        val ph = DoubleArray(9) { rnd(seed, it, 7) * 6.28 }
        for (y in (cy - r * squash * 1.4).toInt()..(cy + r * squash * 1.4).toInt()) for (x in (cx - r * 1.4).toInt()..(cx + r * 1.4).toInt()) {
            if (x !in 0 until img.width || y !in 0 until img.height) continue
            val nx = (x - cx) / r; val ny = (y - cy) / (r * squash)
            val ang = atan2(ny, nx)
            var lump = 0.0
            for (k in 3..8) lump += cos(ang * k + ph[k]) * (0.09 / (1 + k * 0.25))
            val leaf = vnoise(x.toDouble(), y.toDouble(), 3.0, seed) * 0.6 + vnoise(x.toDouble(), y.toDouble(), 7.0, seed + 1) * 0.4
            val dd = sqrt(nx * nx + ny * ny) - lump - (leaf - 0.5) * 0.18
            if (dd >= 1) continue
            val dome = sqrt((1 - dd * dd).coerceAtLeast(0.0))
            var t = 0.42 + dome * 0.32 - (nx * 0.42 + ny * 0.5) + (leaf - 0.5) * 0.65
            t -= (ny - 0.2).coerceAtLeast(0.0) * 0.55
            val i = ((1 - t.coerceIn(0.0, 1.0)) * (tones.size - 0.01)).toInt().coerceIn(0, tones.size - 1)
            img.pixels[y * img.width + x] = tones[i]
        }
    }

    /** A trunk from its foot ([bx], [by]) up to [top], wider at the foot, with roots. */
    private fun trunk(img: PixelImage, bx: Double, by: Double, top: Double, width: Double, seed: Int, bark: IntArray = BARK) {
        for (y in top.toInt() until by.toInt()) {
            val f = (y - top) / max(1.0, by - top)
            val half = width / 2 * (1 + f * f * 0.9)
            val sway = sin(f * 2.4 + seed) * 2
            for (x in (bx - half + sway).toInt()..(bx + half + sway).toInt()) {
                val e = (x - (bx + sway)) / max(1.0, half)
                var c = if (e < -0.35) bark[0] else if (e > 0.35) bark[2] else bark[1]
                if (rnd(x, y, seed + 9) < 0.18) c = mix(c, argb(0x000000), 0.2)
                // grooves of the bark
                if (abs(sin(x * 1.3 + y * 0.12 + seed)) > 0.93) c = mix(c, bark[2], 0.6)
                put(img, x, y, c)
            }
        }
        for (k in 0 until 4) {
            val a = -0.4 + k * 0.27 * PI + rnd(seed, k, 11) * 0.3
            val len = width * 1.3
            stroke(img, bx, by - 3, bx + cos(a) * len, by - 3 + abs(sin(a)) * len * 0.25, max(1.5, width * 0.22), bark[2])
        }
    }

    // ------------------------------------------------------------------ the kinds

    enum class Kind { OAK, SPRUCE, DEAD, BUSH }

    /** A picture with its foot point (anchor) in art pixels. */
    class Sprite(val img: PixelImage, val ax: Int, val ay: Int)

    private val cache = HashMap<String, Sprite>()

    private fun cached(key: String, make: () -> Sprite): Sprite = synchronized(cache) { cache[key] } ?: make().also { synchronized(cache) { cache[key] = it } }

    /** An oak-like tree; [size] 0..2 small to large, [deep] the darker, older wood. */
    fun oak(variant: Int, size: Int, deep: Boolean): Sprite = cached("oak/$variant/$size/$deep") {
        val r = S * (0.66 + size * 0.17) + variant % 3 * 2
        val w = (r * 2.6).toInt(); val h = (r * 3.6).toInt()
        val img = PixelImage(w, h)
        val base = h - 4.0
        val cy = h - r * 2.15
        trunk(img, w / 2.0, base, cy, r * (if (deep) 0.26 else 0.22), variant * 31 + size)
        crown(img, w / 2.0, cy, r, if (deep) LEAF_DEEP else LEAF, variant * 131 + size * 7 + (if (deep) 3 else 0))
        Sprite(img, w / 2, base.toInt())
    }

    /** A spruce in drooping tiers. */
    fun spruce(variant: Int, size: Int): Sprite = cached("spruce/$variant/$size") {
        val r = S * (0.5 + size * 0.13) + variant % 2 * 2
        val w = (r * 2.1).toInt(); val h = (r * 4.2).toInt()
        val img = PixelImage(w, h)
        val base = h - 4.0
        trunk(img, w / 2.0, base, base - r * 0.7, r * 0.16, variant * 17)
        val cx = w / 2.0
        val tiers = 5
        for (k in 0 until tiers) {
            val f = k / (tiers - 1.0)
            val ty = base - r * 0.55 - k * r * 0.62
            val half = r * (0.95 - f * 0.6)
            val hh = r * 0.95
            for (y in (ty - hh).toInt()..ty.toInt()) for (x in (cx - half - 3).toInt()..(cx + half + 3).toInt()) {
                if (x !in 0 until w || y !in 0 until h) continue
                val rel = (ty - y) / hh
                val edge = half * (1 - rel) * (1 + 0.12 * sin(x * 0.9 + k * 3 + variant))
                if (abs(x - cx) > edge) continue
                var t = 0.55 - (x - cx) / (half * 2.2) + rel * 0.25 + (vnoise(x.toDouble(), y.toDouble(), 3.0, variant * 7 + k) - 0.5) * 0.5
                if (y > ty - hh * 0.25) t -= 0.25
                val i = ((1 - t.coerceIn(0.0, 1.0)) * 4.99).toInt().coerceIn(0, 4)
                img.pixels[y * w + x] = PINE[i]
            }
        }
        Sprite(img, w / 2, base.toInt())
    }

    /** A dead tree, grey and bare, its branches reaching up. */
    fun deadTree(variant: Int): Sprite = cached("dead/$variant") {
        val r = S * 0.8
        val w = (r * 2.6).toInt(); val h = (r * 3.6).toInt()
        val img = PixelImage(w, h)
        var n = 0
        fun branch(x: Double, y: Double, a: Double, len: Double, wd: Double) {
            if (len < 5 || wd < 1) return
            val x2 = x + cos(a) * len; val y2 = y + sin(a) * len
            stroke(img, x, y, x2, y2, wd, DEAD[2])
            stroke(img, x - wd * 0.2, y, x2 - wd * 0.2, y2, max(1.0, wd * 0.45), DEAD[1])
            stroke(img, x - wd * 0.3, y, x2 - wd * 0.3, y2, max(1.0, wd * 0.18), DEAD[0])
            for (k in 0..1) { n++; branch(x2, y2, a + (rnd(variant, n, 21) - 0.5) * 1.1, len * 0.66, wd * 0.6) }
        }
        branch(w / 2.0, h - 4.0, -PI / 2, r * 1.15, r * 0.22)
        trunk(img, w / 2.0, h - 4.0, h - 4.0 - r * 0.5, r * 0.24, variant * 5, DEAD)
        Sprite(img, w / 2, h - 4)
    }

    /** A low bush. */
    fun bush(variant: Int): Sprite = cached("bush/$variant") {
        val r = S * (0.22 + (variant % 3) * 0.06)
        val w = (r * 2.7).toInt(); val h = (r * 2.3).toInt()
        val img = PixelImage(w, h)
        crown(img, w / 2.0, h - r * 1.05, r, LEAF, variant * 53 + 5, squash = 0.7)
        Sprite(img, w / 2, h - 3)
    }

    /** A fern: fronds fanning out from the ground. */
    fun fern(variant: Int): Sprite = cached("fern/$variant") {
        val w = 44; val h = 26
        val img = PixelImage(w, h)
        val fx = w / 2.0; val fy = h - 3.0
        for (k in 0 until 7) {
            val a = -PI * (0.1 + 0.8 * k / 6) + (rnd(variant, k, 31) - 0.5) * 0.2
            val len = 12 + rnd(variant, k, 32) * 8
            val x2 = fx + cos(a) * len * 1.3; val y2 = fy + sin(a) * len * 0.8
            stroke(img, fx, fy, x2, y2, 2.6, argb(0x22341A))
            stroke(img, fx, fy - 1, x2, y2 - 1, 1.0, argb(0x54683A))
        }
        Sprite(img, w / 2, h - 3)
    }

    /** A cluster of boulders with a shaded front and moss on the north side. */
    fun boulders(variant: Int): Sprite = cached("rock/$variant") {
        val w = 112; val h = 78
        val img = PixelImage(w, h)
        val stones = listOf(Triple(0.0, 0.0, 29.0), Triple(-22.0, 10.0, 17.0), Triple(23.0, 8.0, 15.0))
        for ((i, s) in stones.withIndex()) {
            val (ox, oy, r) = s
            val cx = w / 2.0 + ox + (rnd(variant, i, 41) - 0.5) * 8; val cy = h - 20.0 + oy
            for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in (cx - r * 1.1).toInt()..(cx + r * 1.1).toInt()) {
                val nx = (x - cx) / (r * 1.1); val ny = (y - cy) / r
                val front = ny > 0.1
                val d = nx * nx + (if (front) (ny - 0.1) * (ny - 0.1) * 1.6 else ny * ny * 1.4)
                val bump = (vnoise(x.toDouble(), y.toDouble(), 5.0, variant + i) - 0.5) * 0.25
                if (d + bump > 0.9) continue
                var t = 0.6 - nx * 0.4 - ny * 0.5 + (vnoise(x.toDouble(), y.toDouble(), 3.0, variant * 3 + i) - 0.5) * 0.4
                if (front) t -= 0.45
                var c = STONE[((1 - t.coerceIn(0.0, 1.0)) * 3.99).toInt().coerceIn(0, 3)]
                // moss on the shaded north and in the cracks
                if (!front && ny < -0.25 && vnoise(x.toDouble(), y.toDouble(), 6.0, variant + 40) > 0.48) c = mix(c, MOSS, 0.75)
                put(img, x, y, c)
            }
        }
        Sprite(img, w / 2, h - 6)
    }

    /** A fallen trunk lying across the ground, moss on top, the end cut open. */
    fun log(left: Boolean, right: Boolean): Sprite = cached("log/$left/$right") {
        val w = S + 8; val h = 40
        val img = PixelImage(w, h)
        val x0 = if (left) 6.0 else 0.0; val x1 = if (right) w - 6.0 else w.toDouble()
        val cy = h - 16.0; val r = 11.0
        for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in x0.toInt() until x1.toInt()) {
            val ny = (y - cy) / r
            var c = if (ny < -0.4) BARK[0] else if (ny > 0.35) BARK[2] else BARK[1]
            if (abs(sin(x * 0.7 + y * 0.2)) > 0.92) c = mix(c, BARK[2], 0.5)
            if (ny < -0.45 && vnoise(x.toDouble(), y.toDouble(), 5.0, 3) > 0.45) c = mix(c, MOSS, 0.8)
            put(img, x, y, c)
        }
        if (left) { for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in 0..12) { val dx = (x - 6.0) / 6.0; val dy = (y - cy) / r; if (dx * dx + dy * dy < 1) put(img, x, y, if (dx * dx + dy * dy < 0.4) argb(0x9A7A54) else argb(0x6A5038)) } }
        Sprite(img, w / 2, h - 5)
    }

    /** A tall, weathered standing stone with lichen. */
    fun menhir(variant: Int): Sprite = cached("menhir/$variant") {
        val w = 40; val h = 96
        val img = PixelImage(w, h)
        val cx = w / 2.0; val base = h - 6.0; val top = 10.0
        for (y in top.toInt()..base.toInt()) {
            val f = (y - top) / (base - top)
            val half = 9 + f * 6 + sin(f * 5 + variant) * 1.5 - (if (f < 0.12) (0.12 - f) * 40 else 0.0)
            for (x in (cx - half).toInt()..(cx + half).toInt()) {
                val e = (x - cx) / half
                var t = 0.62 - e * 0.45 + (vnoise(x.toDouble(), y.toDouble(), 4.0, variant + 50) - 0.5) * 0.5
                if (y > base - 8) t -= 0.25
                var c = STONE[((1 - t.coerceIn(0.0, 1.0)) * 3.99).toInt().coerceIn(0, 3)]
                if (vnoise(x.toDouble(), y.toDouble(), 3.0, variant + 51) > 0.8) c = mix(c, argb(0x8A8E62), 0.55)
                put(img, x, y, c)
            }
        }
        Sprite(img, w / 2, h - 6)
    }

    // ------------------------------------------------------------------ on the map

    private fun obj(s: Sprite, artX: Double, artY: Double): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
        return WorldArt.Obj(s.img, x, y, (artY / D).toInt(), D)
    }

    /** The new pictures for one tile, or null if this tile keeps its old picture. */
    fun objects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val deep = map.id == "deep_forest"
        val cx = (tx + 0.5) * S; val cy = (ty + 0.5) * S
        return when (map.tile(tx, ty)) {
            Tile.TREE -> {
                val out = ArrayList<WorldArt.Obj>()
                val count = if (hash(tx, ty, 1) % 3 == 0) 2 else 1
                for (k in 0 until count) {
                    val kind = hash(tx, ty, k * 7 + 2) % 10
                    val size = if (k == 1) 0 else hash(tx, ty, 3) % 3
                    // trees stand within their tile, a little off the middle
                    val px = cx + (rnd(tx, ty, k * 5 + 4) - 0.5) * S * (if (k == 1) 0.6 else 0.35)
                    val py = cy + S * 0.3 + (rnd(tx, ty, k * 5 + 5) - 0.5) * S * 0.3 - k * S * 0.25
                    val s = when {
                        kind < 3 -> spruce(hash(tx, ty, 6) % 6, size)
                        kind == 3 && (deep || rnd(tx, ty, 9) < 0.35) -> deadTree(hash(tx, ty, 8) % 4)
                        else -> oak(hash(tx, ty, 7) % 10, size, deep)
                    }
                    out += obj(s, px, py)
                }
                out
            }
            Tile.ROCK -> listOf(obj(boulders(hash(tx, ty, 12) % 4), cx, cy + S * 0.25))
            Tile.LOG -> listOf(obj(log(map.tile(tx - 1, ty) != Tile.LOG, map.tile(tx + 1, ty) != Tile.LOG), cx, cy + S * 0.2))
            Tile.MENHIR -> listOf(obj(menhir(hash(tx, ty, 13) % 4), cx, cy + S * 0.3))
            else -> null
        }
    }

    /** Bushes, ferns and dry branches on open ground, thicker near the trees; never on the path or water. */
    fun undergrowth(map: MapDef): List<WorldArt.Obj> {
        val out = ArrayList<WorldArt.Obj>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val t = map.tile(tx, ty)
            if (t != Tile.GRASS && t != Tile.TALL_GRASS && t != Tile.FLOWERS) continue
            if (listOf(-1 to 0, 1 to 0, 0 to -1, 0 to 1).any { (dx, dy) -> map.tile(tx + dx, ty + dy) == Tile.PATH }) continue
            var near = 0
            for (dy in -1..1) for (dx in -1..1) if (map.tile(tx + dx, ty + dy) == Tile.TREE) near++
            for (k in 0 until 2) {
                if (rnd(tx, ty, k * 3 + 41) > 0.05 + near * 0.07) continue
                val px = (tx + 0.15 + rnd(tx, ty, k * 3 + 42) * 0.7) * S; val py = (ty + 0.2 + rnd(tx, ty, k * 3 + 43) * 0.7) * S
                val s = if (rnd(tx, ty, k + 44) < 0.55) bush(hash(tx, ty, k + 45) % 6) else fern(hash(tx, ty, k + 46) % 5)
                out += obj(s, px, py)
            }
        }
        return out
    }

    // ------------------------------------------------------------------ shadows

    /** A soft shadow on the ground: an ellipse fading at its rim. */
    private fun shadowImage(rx: Int, ry: Int, a: Double): PixelImage = synchronized(cache) {
        val key = "shadow/$rx/$ry/${(a * 100).toInt()}"
        cache[key]?.img ?: PixelImage(rx * 2, ry * 2).also { img ->
            for (y in 0 until ry * 2) for (x in 0 until rx * 2) {
                val dx = (x + 0.5 - rx) / rx; val dy = (y + 0.5 - ry) / ry
                val d = dx * dx + dy * dy
                if (d >= 1) continue
                val k = a * (1 - d).let { it * (2 - it) }
                img.pixels[y * img.width + x] = ((k * 255).toInt().coerceIn(0, 255) shl 24) or SHADOW_RGB
            }
            cache[key] = Sprite(img, rx, ry)
        }
    }

    private val shadowCache = HashMap<String, List<WorldArt.Obj>>()

    /**
     * The shadows of trees, rocks and stones on the ground, falling to the lower right (the light
     * comes from the upper left). Drawn under everything that stands, faded by the time of day.
     */
    fun shadows(map: MapDef): List<WorldArt.Obj> = synchronized(shadowCache) {
        shadowCache.getOrPut(map.id) {
            val out = ArrayList<WorldArt.Obj>()
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                val list = objects(map, tx, ty) ?: continue
                for (o in list) {
                    val w = o.img.width; val h = o.img.height
                    val footX = o.x * D + w / 2; val footY = (o.sortY) * D
                    val (rx, ry, ox) = when (map.tile(tx, ty)) {
                        Tile.TREE -> Triple(w * 0.42, w * 0.22, w * 0.3)
                        Tile.MENHIR -> Triple(22.0, 9.0, 18.0)
                        else -> Triple(w * 0.45, 12.0, 8.0)
                    }
                    val img = shadowImage(rx.toInt(), ry.toInt(), if (map.tile(tx, ty) == Tile.TREE) 0.42 else 0.36)
                    out += WorldArt.Obj(img, Math.floorDiv(footX + ox.toInt() - rx.toInt(), D), Math.floorDiv(footY - ry.toInt() + 2, D), 0, D)
                }
            }
            out
        }
    }
}
