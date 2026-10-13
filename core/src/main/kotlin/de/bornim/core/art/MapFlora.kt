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
 * The trees of the woods and the village's edge (09.10.), at double resolution like [MapGround]: oaks with a trunk,
 * roots and a lumpy crown; spruces in drooping tiers; dead grey trees with bare branches. Each kind comes in several
 * variants, drawn once and kept. Also where the undergrowth grows ([undergrowth], drawn by [MapWoodIso]); trunks,
 * rocks, stones, the fire, chests and signs of the woods are [MapWoodIso]'s.
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

    /** The trees with volume (27.4); false draws the flat ones before (preview TREESHEET=1 compares). */
    @Volatile var treeDraft = true

    /** An oak-like tree; [size] 0..2 small to large, [deep] the darker, older wood. */
    fun oak(variant: Int, size: Int, deep: Boolean): Sprite = cached("oak/$variant/$size/$deep/$treeDraft") {
        if (treeDraft) return@cached MapTree.oak(variant, size, deep)
        // tall enough beside the hero: an old oak stands about two and a half times as tall as a man
        val r = S * (0.95 + size * 0.17) + variant % 3 * 3
        val w = (r * 2.6).toInt(); val h = (r * 3.4).toInt()
        val img = PixelImage(w, h)
        val base = h - 4.0
        val cy = h - r * 2.05
        trunk(img, w / 2.0, base, cy, r * (if (deep) 0.28 else 0.24), variant * 31 + size)
        crown(img, w / 2.0, cy, r, if (deep) LEAF_DEEP else LEAF, variant * 131 + size * 7 + (if (deep) 3 else 0))
        Sprite(img, w / 2, base.toInt())
    }

    /** A spruce in drooping tiers. */
    fun spruce(variant: Int, size: Int, young: Boolean = false): Sprite = cached("spruce/$variant/$size/$young/$treeDraft") {
        if (treeDraft) return@cached MapTree.spruce(variant, size, young)
        // a young spruce stays small (beside chests); grown ones tower over the hero
        val r = if (young) S * 0.44 + variant % 2 * 2 else S * (0.78 + size * 0.14) + variant % 2 * 3
        val w = (r * 2.1).toInt(); val h = (r * 3.9).toInt()
        val img = PixelImage(w, h)
        val base = h - 4.0
        trunk(img, w / 2.0, base, base - r * 0.7, r * 0.16, variant * 17)
        val cx = w / 2.0
        val tiers = 5
        for (k in 0 until tiers) {
            val f = k / (tiers - 1.0)
            val ty = base - r * 0.5 - k * r * 0.55
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
    fun deadTree(variant: Int): Sprite = cached("dead/$variant/$treeDraft") {
        if (treeDraft) return@cached MapTree.deadTree(variant)
        val r = S * 1.0
        val w = (r * 2.6).toInt(); val h = (r * 3.4).toInt()
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











    // ------------------------------------------------------------------ on the map

    private fun obj(s: Sprite, artX: Double, artY: Double): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
        return WorldArt.Obj(s.img, x, y, (artY / D).toInt(), D)
    }

    /** The new pictures for one tile, or null if this tile keeps its old picture. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int = 0, chestOpen: Boolean = false): List<WorldArt.Obj>? {
        val deep = map.id == "deep_forest"
        val cx = (tx + 0.5) * S; val cy = (ty + 0.5) * S
        return when (map.tile(tx, ty)) {
            Tile.TREE -> {
                val out = ArrayList<WorldArt.Obj>()
                // a chest just north of this tree must stay visible: a slim young spruce instead of a broad crown
                // the tall crowns reach up to three tiles north: where they would hide something one needs to
                // find (a chest, the fire, a sign, someone to talk to, a way out), a young spruce stands instead
                fun important(x: Int, y: Int) = map.tile(x, y).let { it == Tile.CHEST || it == Tile.CAMPFIRE || it == Tile.SIGN || it == Tile.CAVE_ENTRANCE ||
                    // in the village: the fields and yards behind the edge of the wood stay in sight
                    (map.kind == de.bornim.core.MapKind.TOWN && (it == Tile.CROPS || it == Tile.VEG_BED || it == Tile.HAY || it == Tile.FENCE || it == Tile.WASHLINE)) } ||
                    map.npcs.any { it.x == x && it.y == y } || map.warpAt(x, y) != null
                // seen diagonally (43), a tall crown hides what lies up to eight tiles behind it towards the top of the screen
                // (north and west): there the stones of the circle count too, but a chest may stay hidden under the trees
                fun seen(x: Int, y: Int) = map.tile(x, y) == Tile.MENHIR || (important(x, y) && map.tile(x, y) != Tile.CHEST)
                // the old oaks of the deep forest (27.6) stand so close that a crown twelve steps in front still reaches
                // over Morwen's fire: there the reach goes as high as the tallest crown (about 12 half tiles)
                val reach = if (deep) 12 else 8
                val shades = (0..reach).any { bx -> (0..reach).any { by -> bx + by in 1..reach && kotlin.math.abs(bx - by) <= 2 && seen(tx - bx, ty - by) } }
                if (shades) {
                    // a row of them at the edge of the village is no hedge (test of 0.1.590): set off a little each, some
                    // a bush instead, some two small ones side by side
                    val pick = hash(tx, ty, 17) % 10
                    fun young(k: Int) = obj(spruce(hash(tx, ty, 6 + k) % 6, 0, young = true),
                        cx + (rnd(tx, ty, 18 + k) - 0.5) * S * 0.6, cy + S * (0.45 + rnd(tx, ty, 20 + k) * 0.3))
                    return when {
                        map.kind != de.bornim.core.MapKind.TOWN && !deep -> listOf(obj(spruce(hash(tx, ty, 6) % 6, 0, young = true), cx, cy + S * 0.6))
                        // the bush in the slant like those of the undergrowth (56)
                        pick < 3 -> listOf(MapWoodIso.bushObj(((cx + (rnd(tx, ty, 22) - 0.5) * S * 0.5) / D).toInt(), ((cy + S * 0.5) / D).toInt(), hash(tx, ty, 19) % 6))
                        pick < 5 -> listOf(young(0), young(1))
                        else -> listOf(young(0))
                    }
                }
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
                val isBush = rnd(tx, ty, k + 44) < 0.55
                // the bushes and ferns in the slant like the other things of the woods (56)
                out += if (isBush) MapWoodIso.bushObj((px / D).toInt(), (py / D).toInt(), hash(tx, ty, k + 45) % 6)
                    else MapWoodIso.fernObj((px / D).toInt(), (py / D).toInt(), hash(tx, ty, k + 46) % 5)
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
        // no sun in the cave: the things there have their shadows in the ground
        if (map.kind != de.bornim.core.MapKind.FOREST) return emptyList()
        shadowCache.getOrPut(map.id) {
            val out = ArrayList<WorldArt.Obj>()
            for (ty in 0 until map.height) for (tx in 0 until map.width) {
                val list = objects(map, tx, ty) ?: continue
                for (o in list) {
                    val w = o.img.width; val h = o.img.height
                    val footX = o.x * D + w / 2; val footY = (o.sortY) * D
                    val (rx, ry, ox) = when (map.tile(tx, ty)) {
                        Tile.TREE -> Triple(w * 0.42, w * 0.22, w * 0.3)
                        Tile.CAMPFIRE -> continue
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
