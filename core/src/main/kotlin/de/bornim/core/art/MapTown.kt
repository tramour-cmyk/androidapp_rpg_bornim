package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Bornim in the new style (draft, night of 09.10.; only in the previews while [MapGround.townDraft]
 * is off in the game): the houses as single pictures, seen at a slant from above like the woods,
 * timber-framed walls of dirty plaster on a stone footing, small windows with shutters, heavy plank
 * doors, thatched roofs gone grey with moss, the temple under dark slate; and the things about the
 * square. At double resolution like [MapGround] ([S] art pixels per tile).
 */
object MapTown {
    private const val S = MapGround.S
    private const val D = MapGround.D

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
    private fun put(img: PixelImage, x: Int, y: Int, c: Int) { if (x in 0 until img.width && y in 0 until img.height) img.pixels[y * img.width + x] = c }
    private fun get(img: PixelImage, x: Int, y: Int) = img[x, y]
    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }
    private fun ramp(vararg c: Int) = c.map { argb(it) }
    private fun pick(r: List<Int>, t: Double) = r[((1 - t.coerceIn(0.0, 1.0)) * (r.size - 0.01)).toInt().coerceIn(0, r.size - 1)]

    private val PLASTER = ramp(0xA89A7E, 0x8E826A, 0x726854, 0x544C40)
    private val BEAM = ramp(0x5A4434, 0x42322A, 0x2C221C)
    private val STONE = ramp(0x8A847A, 0x6A645C, 0x4E4A44, 0x34302C)
    private val THATCH = ramp(0x8A7A58, 0x6E6046, 0x564A36, 0x3E3628, 0x2A241C)
    private val SLATE = ramp(0x5A6270, 0x464E5A, 0x343A44, 0x24282E)
    private val MOSS = argb(0x4A5A30)
    private val GLASS = argb(0x1A1C20)
    private val WARM = argb(0x8A6A3A)
    private val IRON = argb(0x2A2826)

    /** A picture with its foot point (anchor) in art pixels. */
    class Sprite(val img: PixelImage, val ax: Int, val ay: Int)

    private val cache = HashMap<String, Sprite>()
    private fun cached(key: String, make: () -> Sprite): Sprite = synchronized(cache) { cache[key] } ?: make().also { synchronized(cache) { cache[key] = it } }

    /**
     * A house: [front] is its row of wall tiles from left to right ('#' wall, 'W' window, 'D' door),
     * [roofRows] how many rows of roof lie behind it, [slate] the dark slate of the temple instead of
     * thatch; [seed] varies the weathering and whether a chimney stands on the ridge.
     */
    fun house(front: String, roofRows: Int, slate: Boolean, seed: Int): Sprite = cached("house/$front/$roofRows/$slate/$seed") {
        val n = front.length
        val pad = 8
        val w = n * S + 2 * pad
        val roofH = roofRows * S + 10
        val faceH = S
        val top = 18
        val h = top + roofH + faceH + 6
        val img = PixelImage(w, h)
        val faceTop = top + roofH
        val faceBot = faceTop + faceH
        // ---- the wall: timber frame and plaster on a footing of rough stones
        for (y in faceTop until faceBot) for (x in pad until pad + n * S) {
            val lx = x - pad; val tile = lx / S; val tx = lx % S
            val ly = y - faceTop
            val kind = front[tile]
            var c: Int
            if (ly >= faceH - 10) {
                // footing: rough stones, darker below
                val sx = floor((x + (ly / 5) * 3) / 7.0).toInt(); val sy = ly / 5
                c = pick(STONE, 0.55 - (ly - (faceH - 10)) * 0.05 + (rnd(sx, sy, seed + 1) - 0.5) * 0.4)
                if ((x + (ly / 5) * 3) % 7 == 0 || ly % 5 == 0) c = STONE[3]
            } else {
                var t = 0.62 + (vnoise(x.toDouble(), y.toDouble(), 6.0, seed + 2) - 0.5) * 0.35 - ly * 0.004
                // grime running down from the eaves and up from the ground
                t -= (vnoise(x * 0.4, 0.0, 4.0, seed + 3)) * 0.25 * (1 - ly / faceH.toDouble())
                if (ly > faceH - 22) t -= (ly - (faceH - 22)) * 0.012
                c = pick(PLASTER, t)
                // the frame: posts at the tile edges, a sill beam and a head beam, braces in the plain wall
                val post = tx < 4 || tx >= S - 3
                val beamRow = ly < 6 || (ly in 30..33)
                val brace = kind == '#' && abs((tx - 4) - (ly - 6) * (S - 8) / 46.0) < 2.4 && ly in 6..52
                if (post || beamRow || brace) c = pick(BEAM, 0.55 + (rnd(tile, ly / 3, seed + 4) - 0.5) * 0.3 - (if (tx >= S - 3) 0.3 else 0.0))
            }
            put(img, x, y, c)
        }
        // windows: a small dark opening with a cross of wood, plank shutters folded back, a faint warmth inside
        for ((i, k) in front.withIndex()) if (k == 'W') {
            val cx = pad + i * S + S / 2; val wy = faceTop + 12
            for (y in wy until wy + 18) for (x in cx - 10 until cx + 10) {
                var c = if (vnoise(x.toDouble(), y.toDouble(), 3.0, seed + 5) > 0.7) WARM else GLASS
                if (x == cx || x == cx - 1 || y == wy + 8) c = BEAM[1]
                if (x == cx - 10 || x == cx + 9 || y == wy || y == wy + 17) c = BEAM[2]
                put(img, x, y, c)
            }
            for (side in listOf(-1, 1)) for (y in wy until wy + 18) for (dx in 0 until 7) {
                val x = cx + side * (11 + dx)
                put(img, x, y, if (dx == 0 || dx == 6 || y % 6 == 0) BEAM[2] else BEAM[1])
            }
            for (x in cx - 12 until cx + 12) put(img, x, wy + 18, STONE[1])
        }
        // doors: heavy planks under a lintel, iron straps, a worn step
        for ((i, k) in front.withIndex()) if (k == 'D') {
            val cx = pad + i * S + S / 2; val dTop = faceTop + 10; val dBot = faceBot - 4
            for (y in dTop - 3 until dBot) for (x in cx - 15 until cx + 15) {
                val lx = x - (cx - 15)
                var c = if (y < dTop) BEAM[2] else if (lx < 2 || lx >= 28) BEAM[2] else pick(BEAM, 0.65 - (lx % 6) * 0.05 + (rnd(lx / 6, 0, seed + 6) - 0.5) * 0.3)
                if (y >= dTop && lx >= 2 && lx < 28 && lx % 6 == 0) c = shade(BEAM[2], 0.7)
                if ((y - dTop) in 7..8 || (y - dTop) in 31..32) if (lx in 3..26) c = IRON
                put(img, x, y, c)
            }
            put(img, cx + 9, dTop + 20, argb(0x6A6050)); put(img, cx + 9, dTop + 21, IRON)
            for (y in dBot until faceBot + 3) for (x in cx - 17 until cx + 17) put(img, x, y, pick(STONE, 0.45 + (rnd(x / 6, y, seed + 7) - 0.5) * 0.3))
        }
        // ---- the roof: its slope towards us, from the ridge down to the eaves hanging over the wall
        val eave = faceTop + 7
        val left = 2; val right = w - 2
        for (y in top until eave) for (x in left until right) {
            val ly = y - top
            // the gable ends lean in a little towards the ridge
            val inset = ((roofH - ly) * 0.06).toInt()
            if (x < left + inset || x >= right - inset) continue
            val f = ly / (eave - top).toDouble()
            var c: Int
            if (slate) {
                // slates in staggered rows, a shade darker at each lower edge
                val row = ly / 7; val sx = (x + (if (row % 2 == 0) 0 else 6)) / 12
                var t = 0.5 - f * 0.15 + (rnd(sx, row, seed + 8) - 0.5) * 0.3 - (x - left).toDouble() / w * 0.15
                if (ly % 7 == 6 || (x + (if (row % 2 == 0) 0 else 6)) % 12 == 0) t -= 0.35
                c = pick(SLATE, t)
            } else {
                // thatch: bundles laid in courses, each course a wavy darker line, moss in the damp low parts
                val course = (ly + sin(x * 0.18 + ly * 0.05) * 1.5).toInt() % 9
                var t = 0.55 - f * 0.2 + (vnoise(x.toDouble(), y * 2.0, 4.0, seed + 9) - 0.5) * 0.45 - (x - left).toDouble() / w * 0.2
                if (course == 0) t -= 0.35
                if (abs(sin(x * 1.7 + ly * 0.4)) > 0.9) t -= 0.15
                c = pick(THATCH, t)
                if (f > 0.45 && vnoise(x.toDouble(), y.toDouble(), 7.0, seed + 10) > 0.6) c = mix(c, MOSS, 0.55)
            }
            // the ridge: a darker, thicker cap along the top
            if (ly < 7) c = if (slate) SLATE[3] else pick(THATCH, 0.25 - (if (ly < 2) 0.1 else 0.0))
            // the eave's lower edge
            if (y >= eave - 3) c = shade(c, 0.6)
            put(img, x, y, c)
        }
        // the shadow of the eaves on the wall below
        for (y in eave until eave + 12) for (x in pad until pad + n * S) {
            val k = 0.55 + (y - eave) / 12.0 * 0.45
            put(img, x, y, shade(get(img, x, y), k))
        }
        // a chimney of rough stone on the ridge, on some houses
        if (!slate && hash(seed, n, 11) % 3 != 0) {
            val cx = pad + (n * S * (0.25 + rnd(seed, n, 12) * 0.5)).toInt()
            for (y in 2 until top + 14) for (x in cx - 7 until cx + 7) {
                var c = pick(STONE, 0.6 - (x - (cx - 7)) * 0.03 + (rnd(x / 4, y / 4, seed + 13) - 0.5) * 0.3)
                if (y < 6) c = argb(0x14110E)
                put(img, x, y, c)
            }
        }
        // the temple's little bell turret
        if (slate) {
            val cx = w / 2
            for (y in 0 until top + 10) for (x in cx - 8 until cx + 8) {
                val c = if (y < 8) SLATE[if (x < cx) 1 else 2] else if (y in 12..20 && x in cx - 4 until cx + 4) argb(0x12100E) else pick(PLASTER, 0.4)
                put(img, x, y, c)
            }
        }
        Sprite(img, pad, h - 6)
    }

    // ------------------------------------------------------------------ things about the village

    private val WOOD = ramp(0x7A6046, 0x5E4834, 0x463426, 0x2E2219)
    private val STRAW = ramp(0xA89464, 0x8A7850, 0x6E5E3E, 0x4E422C)
    private val CLOTHS = listOf(0x7A4A3A, 0x8A7A58, 0x4E5A4A, 0x6A6070, 0xA09A88)

    /** An ellipse filled by [paint] (0..1 across, 0..1 down, the distance from the middle). */
    private fun blob(img: PixelImage, cx: Double, cy: Double, rx: Double, ry: Double, paint: (Double, Double, Double) -> Int?) {
        for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
            val nx = (x - cx) / rx; val ny = (y - cy) / ry; val d = nx * nx + ny * ny
            if (d > 1) continue
            paint(nx, ny, d)?.let { put(img, x, y, it) }
        }
    }
    private fun line(img: PixelImage, x0: Double, y0: Double, x1: Double, y1: Double, w: Double, c: Int) {
        val n = maxOf(abs(x1 - x0), abs(y1 - y0)).toInt() + 1
        for (i in 0..n) { val t = i / n.toDouble(); val x = x0 + (x1 - x0) * t; val y = y0 + (y1 - y0) * t
            for (dy in 0 until w.toInt().coerceAtLeast(1)) for (dx in 0 until w.toInt().coerceAtLeast(1)) put(img, (x + dx - w / 2).toInt(), (y + dy - w / 2).toInt(), c) }
    }

    /** An old barrel: dark staves, two iron hoops, the lid a little lighter. */
    fun barrel(v: Int): Sprite = cached("barrel/$v") {
        val w = 30; val h = 40; val img = PixelImage(w, h)
        for (y in 6 until h - 2) for (x in 2 until w - 2) {
            val nx = (x - w / 2.0) / (w / 2.0 - 2); val bulge = 1 - 0.12 * ((y - h / 2.0) / (h / 2.0)).let { it * it }
            if (abs(nx) > bulge) continue
            var t = 0.6 - nx * 0.35 + (rnd(x / 4, v, 20) - 0.5) * 0.2
            if (x % 4 == 0) t -= 0.25
            var c = pick(WOOD, t)
            if (y in 12..14 || y in h - 10..h - 8) c = shade(IRON, 1.2 - nx * 0.3)
            put(img, x, y, c)
        }
        blob(img, w / 2.0, 7.0, w / 2.0 - 3, 4.0) { nx, _, d -> if (d > 0.7) WOOD[3] else pick(WOOD, 0.55 - nx * 0.2) }
        Sprite(img, w / 2, h - 3)
    }

    /** A street lamp: an iron post on a stone, a caged lantern with a dull warm glass. */
    fun lamp(): Sprite = cached("lamp") {
        val w = 24; val h = 92; val img = PixelImage(w, h)
        for (y in 22 until h - 8) for (x in 10..12) put(img, x, y, if (x == 10) shade(IRON, 1.6) else IRON)
        blob(img, 11.5, h - 6.0, 9.0, 5.0) { nx, ny, _ -> pick(STONE, 0.55 - nx * 0.3 - ny * 0.2) }
        for (y in 6 until 22) for (x in 5..18) {
            val edge = x == 5 || x == 18 || y == 6 || y == 21 || x == 11 || x == 12
            put(img, x, y, if (edge) IRON else if (y < 12) argb(0xC89A50) else argb(0xA87838))
        }
        for (x in 3..20) { put(img, x, 5, IRON); put(img, x, 4, shade(IRON, 1.4)) }
        for (x in 8..15) put(img, x, 2, IRON)
        Sprite(img, 11, h - 4)
    }

    /** A market stall: a trestle table of goods under an awning of faded cloth on two poles. */
    fun stall(v: Int): Sprite = cached("stall/$v") {
        val w = 70; val h = 74; val img = PixelImage(w, h)
        val cloth = argb(CLOTHS[v % CLOTHS.size]); val cloth2 = argb(CLOTHS[(v + 2) % CLOTHS.size])
        for (x in listOf(6, w - 8)) for (y in 14 until h - 4) for (dx in 0..2) put(img, x + dx, y, pick(WOOD, 0.5 - dx * 0.15))
        // the table and its goods
        for (y in 42 until 50) for (x in 4 until w - 4) put(img, x, y, pick(WOOD, if (y < 44) 0.75 else 0.4))
        for (y in 50 until h - 6) for (x in 8 until w - 8) if (x % 14 < 3) put(img, x, y, WOOD[3])
        for (k in 0 until 9) {
            val gx = 12.0 + k * 6 + rnd(k, v, 21) * 3; val gy = 39.0 - rnd(k, v, 22) * 4
            val good = listOf(0x6A2A22, 0x4E5A2E, 0x8A6A3A, 0x5A4A3A)[hash(k, v, 23) % 4]
            blob(img, gx, gy, 3.5, 3.0) { nx, ny, _ -> shade(argb(good), 1.1 - nx * 0.2 - ny * 0.3) }
        }
        // the awning, sagging between the poles, its hem cut in tongues
        for (y in 8 until 30) for (x in 2 until w - 2) {
            val sag = sin((x - 2) / (w - 4.0) * Math.PI) * 3
            if (y < 8 + sag || y > 24 + sag + (if ((x / 7) % 2 == 0) 5 else 0)) continue
            var c = if ((x / 9) % 2 == 0) cloth else cloth2
            c = shade(c, 0.8 + (y - 8) * 0.008 - (x / w.toDouble()) * 0.15 + (vnoise(x.toDouble(), y.toDouble(), 5.0, v + 24) - 0.5) * 0.2)
            put(img, x, y, c)
        }
        Sprite(img, w / 2, h - 4)
    }

    /** The well: a ring of mossy stones, black water deep inside, a little shingled roof on two posts, the bucket on its rope. */
    fun well(): Sprite = cached("well") {
        val w = 64; val h = 96; val img = PixelImage(w, h)
        val cy = h - 22.0
        blob(img, 32.0, cy, 26.0, 16.0) { nx, ny, d ->
            if (d < 0.42) (if (d < 0.3) argb(0x0C0E10) else argb(0x1A1C1C))
            else { var c = pick(STONE, 0.55 - nx * 0.3 - ny * 0.35 + (rnd((nx * 9).toInt(), (ny * 6).toInt(), 25) - 0.5) * 0.35); if (ny < -0.3 && rnd((nx * 20).toInt(), (ny * 20).toInt(), 26) < 0.3) c = mix(c, MOSS, 0.6); c }
        }
        for (y in (cy + 4).toInt() until h - 4) for (x in 6 until w - 6) {
            val nx = (x - 32.0) / 26.0; if (abs(nx) > 1) continue
            if (get(img, x, y) == 0) put(img, x, y, pick(STONE, 0.4 - nx * 0.25 - (if ((x + y / 6 * 4) % 9 == 0 || y % 6 == 0) 0.25 else 0.0)))
        }
        for (x in listOf(8, w - 11)) for (y in 18 until (cy + 4).toInt()) for (dx in 0..2) put(img, x + dx, y, pick(WOOD, 0.55 - dx * 0.15))
        for (y in 6 until 22) for (x in 2 until w - 2) {
            val k = (y - 6) / 16.0; val inset = ((1 - k) * 8).toInt(); if (x < 2 + inset || x >= w - 2 - inset) continue
            put(img, x, y, pick(WOOD, 0.6 - k * 0.3 - (if ((y - 6) % 4 == 3) 0.25 else 0.0) - x / w.toDouble() * 0.15))
        }
        line(img, 10.0, 30.0, 53.0, 30.0, 2.0, WOOD[2])
        line(img, 33.0, 31.0, 33.0, 46.0, 1.0, argb(0x8A7A5A))
        for (y in 46 until 54) for (x in 29 until 38) put(img, x, y, if (y == 46 || y == 50) IRON else pick(WOOD, 0.5))
        Sprite(img, 32, h - 6)
    }

    /** A plank bench on four legs. */
    fun bench(): Sprite = cached("bench") {
        val w = 56; val h = 24; val img = PixelImage(w, h)
        for (y in 6 until 12) for (x in 2 until w - 2) put(img, x, y, pick(WOOD, if (y < 8) 0.7 else 0.45))
        for (x in listOf(6, 14, w - 16, w - 8)) for (y in 12 until h - 2) put(img, x, y, WOOD[3])
        Sprite(img, w / 2, h - 3)
    }

    /** A post-and-rail fence for one tile, rails running on to the fence beside it ([l], [r], [u], [d]). */
    fun fence(l: Boolean, r: Boolean, u: Boolean, d: Boolean): Sprite = cached("fence/$l/$r/$u/$d") {
        val w = S; val h = S + 20; val img = PixelImage(w, h)
        val cx = w / 2; val base = h - 14
        val rail = { x0: Int, x1: Int -> for (x in x0 until x1) { put(img, x, base - 20, WOOD[1]); put(img, x, base - 19, WOOD[2]); put(img, x, base - 9, WOOD[1]); put(img, x, base - 8, WOOD[2]) } }
        if (l) rail(0, cx); if (r) rail(cx, w)
        if (u) for (y in 0 until base - 22) { put(img, cx - 1, y, WOOD[1]); put(img, cx + 1, y, WOOD[2]) }
        if (d) for (y in base until h) { put(img, cx - 1, y, WOOD[1]); put(img, cx + 1, y, WOOD[2]) }
        for (y in base - 26 until base) for (x in cx - 2..cx + 2) put(img, x, y, pick(WOOD, 0.6 - (x - cx) * 0.12))
        Sprite(img, w / 2, base)
    }

    /** A field of grain gone dull gold, in rows, the ears heavy. */
    fun crops(tx: Int, ty: Int): Sprite = cached("crops/${hash(tx, ty, 27) % 4}") {
        val v = hash(tx, ty, 27) % 4
        val w = S; val h = S + 16; val img = PixelImage(w, h)
        for (row in 0 until 6) {
            val by = 22 + row * 10
            for (k in 0 until 18) {
                val x = 2 + k * 3.4 + rnd(k, row, 28 + v) * 2; val len = 12 + rnd(k, row, 29 + v) * 6
                val c = pick(STRAW, 0.35 + rnd(k, row, 30 + v) * 0.5)
                line(img, x, by.toDouble(), x + (rnd(k, row, 31) - 0.3) * 3, by - len, 1.0, c)
                put(img, (x + 1).toInt(), (by - len).toInt(), STRAW[0])
            }
        }
        Sprite(img, 0, h - 12)
    }

    /** A vegetable bed: dark furrows and rows of cabbages. */
    fun vegBed(tx: Int, ty: Int): Sprite = cached("veg/${hash(tx, ty, 32) % 3}") {
        val v = hash(tx, ty, 32) % 3
        val w = S; val h = S; val img = PixelImage(w, h)
        for (y in 4 until h - 4) for (x in 2 until w - 2) put(img, x, y, if ((y / 6) % 2 == 0) argb(0x2A2016) else argb(0x3A2C1E))
        for (row in 0 until 4) for (k in 0 until 4) {
            val gx = 9.0 + k * 15 + rnd(k, row, 33 + v) * 3; val gy = 11.0 + row * 13
            blob(img, gx, gy, 5.5, 4.5) { nx, ny, d -> if (d > 0.8) argb(0x2A3A20) else shade(argb(0x4A6236), 1.15 - nx * 0.25 - ny * 0.3) }
        }
        Sprite(img, 0, h - 2)
    }

    /** A haystack, grey-gold, a little slumped. */
    fun hay(): Sprite = cached("hay") {
        val w = 60; val h = 50; val img = PixelImage(w, h)
        blob(img, 30.0, 30.0, 27.0, 19.0) { nx, ny, _ ->
            val t = 0.6 - nx * 0.3 - ny * 0.35 + (rnd(((nx + 1) * 20).toInt(), ((ny + 1) * 25).toInt(), 34) - 0.5) * 0.35
            pick(STRAW, t)
        }
        for (k in 0 until 30) { val x = 6 + rnd(k, 0, 35) * 48; val y = 18 + rnd(k, 0, 36) * 26; line(img, x, y, x + (rnd(k, 0, 37) - 0.5) * 8, y - 2, 1.0, STRAW[3]) }
        Sprite(img, w / 2, h - 3)
    }

    /** A washing line between two posts, greyed linen and a faded shirt hung out to dry. */
    fun washline(n: Int): Sprite = cached("wash/$n") {
        val w = n * S; val h = 70; val img = PixelImage(w, h)
        for (x in listOf(4, w - 7)) for (y in 6 until h - 4) for (dx in 0..2) put(img, x + dx, y, pick(WOOD, 0.55 - dx * 0.15))
        for (x in 6 until w - 6) { val sag = sin((x - 6) / (w - 12.0) * Math.PI) * 5; put(img, x, (10 + sag).toInt(), argb(0x8A8270)) }
        var x = 12
        var k = 0
        while (x < w - 22) {
            val cw = 10 + hash(k, n, 38) % 8; val ch = 14 + hash(k, n, 39) % 12
            val sag = sin((x - 6) / (w - 12.0) * Math.PI) * 5
            val c = argb(CLOTHS[hash(k, n, 40) % CLOTHS.size])
            for (yy in 0 until ch) for (xx in 0 until cw) put(img, x + xx, (11 + sag + yy).toInt(), shade(c, 0.95 - xx * 0.02 - yy * 0.008 + (if (yy == ch - 1) -0.2 else 0.0)))
            x += cw + 4 + hash(k, n, 41) % 6; k++
        }
        Sprite(img, 0, h - 4)
    }

    /** The barricade at the gate: sharpened stakes crossed and lashed, a beam along them. */
    fun barrier(): Sprite = cached("barrier") {
        val w = S; val h = 54; val img = PixelImage(w, h)
        for (k in 0 until 3) {
            val x = 10.0 + k * 22
            line(img, x - 8, h - 6.0, x + 8, 10.0, 3.0, pick(WOOD, 0.55))
            line(img, x + 8, h - 6.0, x - 8, 10.0, 3.0, pick(WOOD, 0.35))
            put(img, (x - 8).toInt(), 9, argb(0xA89470)); put(img, (x + 8).toInt(), 9, argb(0xA89470))
        }
        line(img, 0.0, 32.0, w.toDouble(), 32.0, 4.0, WOOD[2])
        Sprite(img, w / 2, h - 4)
    }

    private val houseTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.DOOR)
    private val roofTiles = setOf(Tile.ROOF, Tile.ROOF_BLUE)

    /** The new pictures for one tile of the village, or null for the former picture. */
    fun objects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        return when (t) {
            in roofTiles -> emptyList()
            in houseTiles -> {
                // one picture for the whole front, given by its first tile; the roof rows above belong to it
                if (map.tile(tx - 1, ty) in houseTiles) return emptyList()
                var n = 0
                while (map.tile(tx + n, ty) in houseTiles) n++
                val front = (0 until n).joinToString("") { when (map.tile(tx + it, ty)) { Tile.WINDOW -> "W"; Tile.DOOR -> "D"; else -> "#" } }
                var rows = 0
                while (rows < 3 && (0 until n).all { map.tile(tx + it, ty - rows - 1) in roofTiles }) rows++
                val slate = rows > 0 && map.tile(tx, ty - 1) == Tile.ROOF_BLUE
                val s = house(front, rows.coerceAtLeast(1), slate, hash(tx, ty, 1) % 997)
                val artX = tx * S.toDouble(); val artY = (ty + 1.0) * S
                val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
                listOf(WorldArt.Obj(s.img, x, y, ((ty + 1) * S / D) - 1, D))
            }
            Tile.BARREL -> listOf(obj(barrel(hash(tx, ty, 2) % 3), (tx + 0.5) * S, (ty + 0.8) * S))
            Tile.LAMP -> listOf(obj(lamp(), (tx + 0.5) * S, (ty + 0.85) * S))
            Tile.STALL -> listOf(obj(stall(hash(tx, ty, 3) % 5), (tx + 0.5) * S, (ty + 0.9) * S))
            Tile.WELL -> listOf(obj(well(), (tx + 0.5) * S, (ty + 0.95) * S))
            Tile.BENCH -> listOf(obj(bench(), (tx + 0.5) * S, (ty + 0.75) * S))
            Tile.HAY -> listOf(obj(hay(), (tx + 0.5) * S, (ty + 0.85) * S))
            Tile.BARRIER -> listOf(obj(barrier(), (tx + 0.5) * S, (ty + 0.8) * S))
            Tile.FENCE -> {
                fun f(x: Int, y: Int) = map.tile(x, y) == Tile.FENCE
                listOf(obj(fence(f(tx - 1, ty), f(tx + 1, ty), f(tx, ty - 1), f(tx, ty + 1)), (tx + 0.5) * S, (ty + 0.75) * S))
            }
            Tile.CROPS -> listOf(obj(crops(tx, ty), tx * S.toDouble(), (ty + 1.0) * S))
            Tile.VEG_BED -> listOf(obj(vegBed(tx, ty), tx * S.toDouble(), (ty + 1.0) * S - 2))
            Tile.WASHLINE -> {
                if (map.tile(tx - 1, ty) == Tile.WASHLINE) return emptyList()
                var n = 0; while (map.tile(tx + n, ty) == Tile.WASHLINE) n++
                listOf(obj(washline(n), tx * S.toDouble(), (ty + 0.9) * S))
            }
            else -> null
        }
    }

    private fun obj(s: Sprite, artX: Double, artY: Double): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
        return WorldArt.Obj(s.img, x, y, (artY / D).toInt(), D)
    }
}
