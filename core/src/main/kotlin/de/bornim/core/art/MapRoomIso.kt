package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * The rooms seen diagonally (13, step 2): every tile's walls and furniture drawn upright in the
 * diagonal view, turned with the room, painted with [Sculpt] like the gear and the things of the cave.
 *
 * The two walls at the back (the top row and the left column of the room) stand full height, timber
 * and smoky plaster, with the hearth and the window in them and things hanging on them; the walls at
 * the front are cut off knee-high with a dark top (13l), so the room can be seen. Every tile is its own
 * picture whose front corner stands on the tile's front corner on the map, sorted along the diagonal
 * like the figures, so the hero walks behind and in front of things properly.
 *
 * Pictures are art pixels at density [D]; a tile's diamond is [TW] × [TH], heights [z] in art pixels
 * (about 57 to a metre, the hero's scale). Light comes from the game's light layer, as for everything.
 */
object MapRoomIso {
    const val D = 2
    private const val T = WorldArt.T
    /** A tile's diamond, art pixels. */
    const val TW = 90.0
    const val TH = 45.0
    /** The back walls, about 2.4 m. */
    const val WALL = 136.0
    /** The front walls, cut off knee-high (13l). */
    const val STUMP = 26.0
    /**
     * Heights on the screen per height in the drawings (13p.6): the drawings count about 57 art pixels to a
     * metre, the hero seen at the map's angle stands 0.43 to a centimetre (0.55 × cos 38°); so every height
     * is drawn at 0.76 of its number, and a table 42 high stands 75 cm next to the hero, not 97.
     */
    const val ZS = 0.76
    /** Width of every tile's picture (a multiple of 4, so its middle lies on a whole map pixel). */
    private const val W = 100

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.HEARTH)

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0
    private fun frac(v: Double) = v - floor(v)

    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, sat: Double = 1.0, value: Double = 1.0, bias: Double = 0.0) =
        Mat(Ramp.of(argb(rgb), sat = sat, value = value), shine, grain, bias)

    // the inn's oak, as for the furniture seen straight (RoomThings)
    private val oak = m(0x5A4030, grain = 0.16, sat = 0.95, value = 0.8)
    private val oakTop = m(0x6A4A32, grain = 0.12, sat = 0.98, value = 0.8, bias = -0.3)
    private val oakDark = m(0x3A2A1E, grain = 0.16, sat = 0.9, value = 0.9)
    private val oakBack = m(0x2E241C, grain = 0.18, sat = 0.7, bias = -0.08)
    private val bark = m(0x3E2E20, grain = 0.22, sat = 0.85, value = 0.7, bias = -0.2)
    private val barkBirch = m(0x6A6458, grain = 0.26, sat = 0.35, value = 0.75, bias = -0.25)
    private val splitFace = m(0x8A6C48, grain = 0.3, sat = 0.85, value = 0.85)
    private val iron = m(0x3E3A36, shine = 0.35, grain = 0.25, sat = 0.5)
    private val pewter = m(0x76726A, shine = 0.5, grain = 0.15, sat = 0.3, value = 0.9)
    private val clay = m(0x7A4E34, shine = 0.1, grain = 0.18, sat = 0.78, value = 0.9)
    private val clayPale = m(0x8E7A5E, shine = 0.08, grain = 0.2, sat = 0.55, value = 0.85)
    private val clayGlaze = m(0x4E5A4E, shine = 0.45, grain = 0.12, sat = 0.6, value = 0.85)
    private val glass = m(0x34463C, shine = 0.75, grain = 0.06, sat = 0.7, value = 0.9)
    private val glassBrown = m(0x4A3222, shine = 0.7, grain = 0.06, sat = 0.75, value = 0.9)
    private val wax = m(0xC4B494, shine = 0.15, grain = 0.1, sat = 0.55, value = 0.92)
    private val linen = m(0x6E5E44, grain = 0.26, sat = 0.62, value = 0.74)
    private val linenPale = m(0x8A7E66, grain = 0.22, sat = 0.5, value = 0.8)
    private val wool = m(0x6A3A2E, grain = 0.34, sat = 0.7, value = 0.8)

    private val straw = m(0x9A8450, grain = 0.45, sat = 0.7, value = 0.85)
    private val bread = m(0x9A7040, grain = 0.3, sat = 0.82, value = 0.9)
    private val stoneMat = m(0x6A645A, grain = 0.3, sat = 0.4, value = 0.85)

    private val outlineColor = argb(0x0E0C0A)
    private val ale = argb(0x2A1A0E)
    private val flame = argb(0xF0B050)
    private val flameHot = argb(0xFFF0B0)
    private val cobweb = argb(0x8A8478)
    private val seam = argb(0x221810)

    /**
     * One picture: the tile's front corner lies on the middle of its bottom edge, at continuous (W/2, h).
     * Local coordinates of the tile run from (−1, −1) at its back corner to (0, 0) at its front corner;
     * i along the map's x (down right on the screen), j along its y (down left).
     */
    private class Canvas(val h: Int, seed: Int) {
        val s = Sculpt(W, h, seed)
        val img: PixelImage get() = s.img
        fun x(i: Double, j: Double) = W / 2.0 + (i - j) * TW / 2
        fun y(i: Double, j: Double, z: Double = 0.0) = h + (i + j) * TH / 2 - z * ZS
    }

    /** A box between (i0, j0) and (i1, j1), from z0 up to z1: its face towards +j (down left), towards +i (down right) and its top. */
    private fun Canvas.box(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, top: Mat, left: Mat = top, right: Mat = left, bevel: Double = 1.0) {
        s.poly(left, x(i0, j1), y(i0, j1, z0), x(i1, j1), y(i1, j1, z0), x(i1, j1), y(i1, j1, z1), x(i0, j1), y(i0, j1, z1), tiltX = -0.55, tiltY = 0.3, bevel = bevel)
        s.poly(right, x(i1, j0), y(i1, j0, z0), x(i1, j1), y(i1, j1, z0), x(i1, j1), y(i1, j1, z1), x(i1, j0), y(i1, j0, z1), tiltX = 0.55, tiltY = 0.3, bevel = bevel)
        s.poly(top, x(i0, j0), y(i0, j0, z1), x(i1, j0), y(i1, j0, z1), x(i1, j1), y(i1, j1, z1), x(i0, j1), y(i0, j1, z1), tiltY = -0.72, bevel = bevel * 0.6)
    }

    /** A soft shadow on the floor under a footprint, laid before the thing itself. */
    private fun Canvas.floorShadow(i0: Double, j0: Double, i1: Double, j1: Double, a: Double = 0.5) {
        val ci = (i0 + i1) / 2; val cj = (j0 + j1) / 2
        val ri = (i1 - i0) / 2 + 0.08; val rj = (j1 - j0) / 2 + 0.08
        for (py in 0 until h) for (px in 0 until W) {
            val aa = (px + 0.5 - W / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
            val i = (aa + bb) / 2; val j = (bb - aa) / 2
            val di = (i - ci) / ri; val dj = (j - cj) / rj
            val d = max(abs(di), abs(dj))
            if (d >= 1.0 || i < -1 || j < -1 || i > 0 || j > 0) continue
            val k = (1 - d) * a
            img.set(px, py, ((k * 255).toInt().coerceIn(0, 255) shl 24) or 0x0A0806)
        }
    }

    /** Fills the footprint between (i0, j0) and (i1, j1) on the floor with [c]: the ground outside the room. */
    private fun Canvas.floorFill(i0: Double, j0: Double, i1: Double, j1: Double, c: Int) {
        for (py in 0 until h) for (px in 0 until W) {
            val aa = (px + 0.5 - W / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
            val i = (aa + bb) / 2; val j = (bb - aa) / 2
            if (i < i0 || j < j0 || i > i1 || j > j1) continue
            img.set(px, py, c)
        }
    }

    /** Lays [src] with its anchor at (x, y) of the canvas. */
    private fun Canvas.paste(src: PixelImage, ax: Int, ay: Int, x: Double, y: Double) {
        val x0 = floor(x).toInt() - ax; val y0 = floor(y).toInt() - ay
        for (yy in 0 until src.height) for (xx in 0 until src.width) {
            val c = src[xx, yy]; val a = c ushr 24
            if (a == 0) continue
            val tx = x0 + xx; val ty = y0 + yy
            if (tx !in 0 until W || ty !in 0 until h) continue
            img.set(tx, ty, if (a == 255) c else mix(img[tx, ty], c or (0xFF shl 24), a / 255.0))
        }
    }

    // ------------------------------------------------------------------ textured faces of the walls

    /** Paints the face j = [j] between i0 and i1, z0 and z1, each pixel by [tex] (local i, z). */
    private fun Canvas.faceJ(j: Double, i0: Double, i1: Double, z0: Double, z1: Double, tex: (Double, Double) -> Int?) {
        for (py in 0 until h) for (px in 0 until W) {
            val i = (px + 0.5 - W / 2.0) / (TW / 2) + j
            if (i < i0 || i > i1) continue
            val z = (h + (i + j) * TH / 2 - (py + 0.5)) / ZS
            if (z < z0 || z > z1) continue
            tex(i, z)?.let { img.set(px, py, it) }
        }
    }

    /** Paints the face i = [i] between j0 and j1, z0 and z1, each pixel by [tex] (local j, z). */
    private fun Canvas.faceI(i: Double, j0: Double, j1: Double, z0: Double, z1: Double, tex: (Double, Double) -> Int?) {
        for (py in 0 until h) for (px in 0 until W) {
            val j = i - (px + 0.5 - W / 2.0) / (TW / 2)
            if (j < j0 || j > j1) continue
            val z = (h + (i + j) * TH / 2 - (py + 0.5)) / ZS
            if (z < z0 || z > z1) continue
            tex(j, z)?.let { img.set(px, py, it) }
        }
    }

    /** Timber framing and smoky plaster at (u along the wall in tiles, z), [face] its brightness. */
    private fun timber(u: Double, z: Double, seed: Int, face: Double, top: Double): Int {
        val pu = u / 2.0
        val post = abs(pu - Math.round(pu)) * 2 < 0.075
        val sill = z < 9
        val rail = z in 88.0..96.0
        val plate = z > top - 8
        // a brace in every other panel, from the post's foot up to the rail
        val panel = floor(pu).toInt()
        val f = frac(pu)
        val brace = hash(panel, seed, 7) % 3 == 0 && z in 9.0..88.0 && abs(f - (0.08 + (z - 9) / 79 * 0.32)) < 0.03
        val c = if (post || sill || rail || plate || brace) {
            val g = rnd(floor(u * 24).toInt(), floor(z / 3).toInt(), seed)
            var v = 0.42 + (g - 0.5) * 0.3
            if (rail && z < 89.5 || plate && z < top - 6.5) v += 0.25     // the upper edge of a beam catches light
            mix(argb(0x1A130F), argb(0x4E3A2A), v.coerceIn(0.0, 1.0))
        } else {
            var v = 0.56 + (rnd(floor(u * 40).toInt(), floor(z / 2).toInt(), seed + 1) - 0.5) * 0.1 +
                (rnd(floor(u * 6).toInt(), floor(z / 14).toInt(), seed + 2) - 0.5) * 0.12
            v -= 0.28 * ((z - 30) / (top - 30)).coerceIn(0.0, 1.0)            // smoke, darker up high
            v -= 0.14 * exp(-(z - 9) / 10).coerceAtMost(1.0)                    // damp along the sill
            // now and then a crack, and a patch where the plaster has fallen off the wattle
            val crack = abs(frac(u * 3.1 + z * 0.012 + rnd(panel, 1, seed) * 3) - 0.5) < 0.008 && z in 30.0..70.0 && hash(panel, 2, seed) % 2 == 0
            if (crack) v -= 0.3
            val patch = hash(panel, 3, seed) % 4 == 0 && abs(f - 0.62) < 0.1 && z in 34.0..52.0
            if (patch) return shade(if ((floor(z / 3).toInt() + floor(u * 30).toInt()) % 2 == 0) argb(0x3A2A1C) else argb(0x2A1E14), face)
            mix(argb(0x2C261E), argb(0x8E8068), v.coerceIn(0.0, 1.0))
        }
        return shade(c, face)
    }

    /** The hearth in the back wall: rough stone breast, mantel beam, sooty arched mouth (fire is a picture of its own). */
    private fun hearth(u: Double, z: Double, h0: Double, hw: Double, face: Double, seed: Int): Int? {
        val hu = u - h0
        if (hu < 0 || hu > hw) return null
        val mid = hw / 2
        if (z in 80.0..89.0) {
            val v = 0.45 + (rnd(floor(u * 24).toInt(), floor(z / 3).toInt(), seed) - 0.5) * 0.3 + (if (z > 87) 0.25 else 0.0)
            return shade(mix(argb(0x1A130F), argb(0x4E3A2A), v.coerceIn(0.0, 1.0)), face)
        }
        val inBreast = hu in 0.06..(hw - 0.06) && z < WALL - 8
        if (!inBreast) return null
        // the mouth
        val mw = hw * 0.31
        val dx = (hu - mid) / mw
        val arch = 46 + 12 * sqrt((1 - dx * dx).coerceAtLeast(0.0))
        if (abs(dx) < 1 && z < arch) return firebox(hu, z, mid, mw, seed)
        // stones: courses of 10 pixels, each stone its own shade; the edges of the breast and the arch darker
        val course = floor(z / 10).toInt()
        val off = rnd(course, 0, 21)
        val sw = 0.16 + rnd(course, 1, 23) * 0.06
        val bx = floor(hu / sw + off).toInt()
        var t = 0.5 + (rnd(bx, course, 22) - 0.5) * 0.4
        if (z % 10 < 1.3 || frac(hu / sw + off) < 0.07) t -= 0.35
        if (hu < 0.1 || hu > hw - 0.1) t -= 0.25
        if (abs(dx) < 1.12 && z < arch + 4) t -= 0.25
        // soot rising from the mouth, widening upwards
        val soot = (1 - abs(hu - mid) / (mw + (z - 50).coerceAtLeast(0.0) / 120)).coerceAtLeast(0.0) * ((z - 40) / 60).coerceIn(0.0, 1.0)
        t -= soot * 0.45
        return shade(mix(argb(0x2A2622), argb(0x8A8070), t.coerceIn(0.0, 1.0)), face)
    }

    /** How deep the hearth's fire box reaches into the wall, in tiles. */
    private const val FIREBOX = 0.38

    /**
     * Seen through the hearth's mouth at (hu along the hearth, z): the inside of the fire box in true
     * perspective. Looking in, the view runs back and down (−i, −j, −z): it meets the sooty back wall,
     * the stone side on the left (which faces the fire and catches its glow) or the hearthstone.
     */
    private fun firebox(hu: Double, z: Double, mid: Double, mw: Double, seed: Int): Int {
        val left = mid - mw
        val tBack = FIREBOX
        val tSide = hu - left
        val tFloor = z / TH
        val t = minOf(tBack, tSide, tFloor)
        val u = hu - t; val j = -t; val zz = z - TH * t
        // the fire burns in the middle, a little back: its glow on whatever the view meets
        val gd = (u - mid) * (u - mid) / 0.09 + (j + 0.2) * (j + 0.2) / 0.05 + (zz / 34) * (zz / 34)
        val glow = exp(-gd) * 1.1
        val c = when (t) {
            tFloor -> {
                // hearthstone under ash and embers
                val slab = (floor(u / 0.22).toInt() + floor(j / 0.2).toInt() * 3)
                var v = 0.35 + (rnd(slab, 1, seed) - 0.5) * 0.2 + (rnd(floor(u * 60).toInt(), floor(j * 60).toInt(), seed + 3) - 0.5) * 0.15
                if (frac(u / 0.22) < 0.05 || frac(j / 0.2) < 0.06) v -= 0.2
                mix(argb(0x141210), argb(0x6A645C), v.coerceIn(0.0, 1.0))
            }
            tSide -> {
                val course = floor(zz / 9).toInt()
                var v = 0.42 + (rnd(floor(j / 0.13).toInt(), course, seed + 5) - 0.5) * 0.3
                if (zz % 9 < 1.2 || frac(j / 0.13 + course * 0.5) < 0.08) v -= 0.25
                v -= 0.25 * (zz / 50).coerceIn(0.0, 1.0)
                mix(argb(0x1A1714), argb(0x7A7268), v.coerceIn(0.0, 1.0))
            }
            else -> {
                // the back wall, black with soot above the fire
                val course = floor(zz / 9).toInt()
                var v = 0.3 + (rnd(floor(u / 0.15 + course * 0.5).toInt(), course, seed + 7) - 0.5) * 0.25
                if (zz % 9 < 1.2) v -= 0.18
                v -= 0.25 * (zz / 30).coerceIn(0.0, 1.0)
                mix(argb(0x100E0C), argb(0x5A544C), v.coerceIn(0.0, 1.0))
            }
        }
        return mix(c, argb(0xC0602A), (glow * 0.75).coerceIn(0.0, 0.8))
    }

    /** A window with small leaded panes in a deep reveal, local u 0..1 of its tile. */
    private fun window(f: Double, z: Double, face: Double): Int? {
        if (f !in 0.2..0.8 || z !in 46.0..98.0) return null
        val frame = f < 0.26 || f > 0.74 || z < 51 || z > 93
        if (frame) {
            // the reveal: the top and the left side lie in shadow, the deep wall
            val inner = f < 0.23 || z > 96
            return shade(if (inner) argb(0x1A1410) else argb(0x3E2E22), face)
        }
        // leaded diamonds
        val a = (f - 0.5) * 30; val b = (z - 72) / 6
        val lead = abs(frac(a + b) - 0.5) > 0.44 || abs(frac(a - b) - 0.5) > 0.44
        if (abs(f - 0.5) < 0.012 || abs(z - 72) < 1.2) return shade(argb(0x2A2018), face)
        if (lead) return argb(0x1E1C1A)
        val t = (z - 51) / 42
        return mix(argb(0x2E3A4A), argb(0x6A7A8A), t * 0.7 + 0.15)
    }

    /** A wall thing ([MapRoom.wallThing]) hung on a stretch of wall: its color at local u 0..1 and height z, or null. */
    private fun hanging(thing: MapRoom.Sprite?, f: Double, z: Double, face: Double): Int? {
        if (thing == null) return null
        val px = floor(f * thing.img.width).toInt(); val py = floor(100 - z).toInt()
        if (py !in 0 until thing.img.height) return null
        val c = thing.img[px, py]
        if (c ushr 24 == 0) return null
        return shade(c, face * 0.95)
    }

    private fun wallThing(map: MapDef, tx: Int, ty: Int, west: Boolean): MapRoom.Sprite? {
        fun at(dx: Int, dy: Int) = if (map.inside(tx + dx, ty + dy)) map.tile(tx + dx, ty + dy) else Tile.WALL
        val before = if (west) at(1, 0) else at(0, 1)
        if (before in wallTiles || before == Tile.DOOR || before == Tile.SHELF || before == Tile.BED || before == Tile.HEARTH || before == Tile.CRATE) return null
        return MapRoom.wallThing(hash(tx, ty, if (west) 57 else 55) % 7)
    }

    // ------------------------------------------------------------------ walls

    /** How thick the walls are, in tiles: they stand on the room's side of their tiles. */
    private const val THICK = 0.24

    /** Full height for the walls at the back (the top row and the left column), knee-high at the front (13l). */
    private fun tall(map: MapDef, tx: Int, ty: Int) = (ty == 0 || tx == 0) && ty < map.height - 1 && tx < map.width - 1

    private fun room(map: MapDef, tx: Int, ty: Int) = map.inside(tx, ty) && map.tile(tx, ty) !in wallTiles

    private fun beam(u: Double, z: Double, seed: Int, face: Double) =
        shade(mix(argb(0x1A130F), argb(0x4E3A2A), 0.4 + (rnd(floor(u * 24).toInt(), floor(z / 3).toInt(), seed) - 0.5) * 0.3), face)

    /** Paints the top of a wall over its footprint at height [z], dark with an edge where the cut catches a little light. */
    private fun Canvas.wallTop(i0: Double, j0: Double, i1: Double, j1: Double, z: Double, seed: Int) {
        for (py in 0 until h) for (px in 0 until W) {
            val a = (px + 0.5 - W / 2.0) / (TW / 2); val b = (py + 0.5 - h + z * ZS) / (TH / 2)
            val i = (a + b) / 2; val j = (b - a) / 2
            if (i < i0 || j < j0 || i > i1 || j > j1) continue
            var v = 0.5 + (rnd(px / 2, py, seed) - 0.5) * 0.3
            if (i > i1 - 0.035 || j > j1 - 0.035) v += 0.45
            img.set(px, py, mix(argb(0x120E0C), argb(0x3A2E24), v.coerceIn(0.0, 1.0)))
        }
    }

    /**
     * One tile of the walls: a slab along every side where the room lies, on the room's side of the
     * tile, and a post where two of them meet at a corner. The faces into the room carry the
     * timber and plaster, the hearth, the window and what hangs on the wall.
     */
    private fun walls(map: MapDef, tx: Int, ty: Int): PixelImage? {
        val full = tall(map, tx, ty)
        val top = if (full) WALL else STUMP
        val h = (top + TH + 4).toInt().let { it + it % 2 }
        val c = Canvas(h, tx * 31 + ty)
        val seed = map.id.hashCode()
        val tile = map.tile(tx, ty)
        var h0 = tx; while (h0 > 0 && map.tile(h0 - 1, ty) == Tile.HEARTH) h0--
        var h1 = tx; while (h1 < map.width - 1 && map.tile(h1 + 1, ty) == Tile.HEARTH) h1++
        val e = THICK
        var any = false
        // outside the room it is dark
        val outside = argb(0x0A0807)
        if (!full) c.floorFill(-1.0, -1.0, 0.0, 0.0, outside)
        // slabs as boxes (i0, j0, i1, j1), back to front; which face looks into the room
        fun slab(i0: Double, j0: Double, i1: Double, j1: Double, inner: Char) {
            any = true
            // its face towards +j (down left) and towards +i (down right); the top
            c.faceJ(j1, i0, i1, 0.0, top) { i, z ->
                val u = tx + 1 + i
                val f = i - i0
                if (inner != 'S') return@faceJ if (j1 - j0 < 0.5 || i1 - i0 > 0.5) timber(u, z, seed + 1, 0.9, if (full) top else 400.0) else beam(u, z, seed, 0.9)
                val face = 0.95
                when {
                    !full -> timber(u, z, seed, face, 400.0)
                    tile == Tile.HEARTH -> hearth(u, z, h0.toDouble(), (h1 - h0 + 1).toDouble(), face, seed) ?: timber(u, z, seed, face, WALL)
                    tile == Tile.WINDOW -> window(f, z, face) ?: timber(u, z, seed, face, WALL)
                    else -> hanging(wallThing(map, tx, ty, false), f, z, face) ?: timber(u, z, seed, face, WALL)
                }
            }
            c.faceI(i1, j0, j1, 0.0, top) { j, z ->
                val u = ty + 1 + j
                val f = j - j0
                if (inner != 'E') return@faceI if (i1 - i0 < 0.5 || j1 - j0 > 0.5) timber(u, z, seed + 9, 0.74, if (full) top else 400.0) else beam(u, z, seed + 5, 0.74)
                val face = 0.74
                when {
                    !full -> timber(u, z, seed + 9, face, 400.0)
                    else -> hanging(wallThing(map, tx, ty, true), f, z, face) ?: timber(u, z, seed + 9, face, WALL)
                }
            }
            c.wallTop(i0, j0, i1, j1, top, seed)
        }
        // the room to the top (−j) or to the left (−i): slabs at the back of the tile, seen from outside
        if (room(map, tx, ty - 1)) slab(-1.0, -1.0, 0.0, -1.0 + e, 'N')
        if (room(map, tx - 1, ty)) slab(-1.0, -1.0, -1.0 + e, 0.0, 'W')
        if (room(map, tx - 1, ty - 1) && !room(map, tx, ty - 1) && !room(map, tx - 1, ty)) slab(-1.0, -1.0, -1.0 + e, -1.0 + e, 'c')
        if (room(map, tx + 1, ty - 1) && !room(map, tx, ty - 1) && !room(map, tx + 1, ty)) slab(-e, -1.0, 0.0, -1.0 + e, 'c')
        if (room(map, tx - 1, ty + 1) && !room(map, tx, ty + 1) && !room(map, tx - 1, ty)) slab(-1.0, -e, -1.0 + e, 0.0, 'c')
        // the room below (+j) or to the right (+i): slabs at the front of the tile, their faces into the room
        if (room(map, tx, ty + 1)) slab(-1.0, if (tile == Tile.HEARTH) -0.44 else -e, 0.0, 0.0, 'S')
        if (room(map, tx + 1, ty)) slab(-e, -1.0, 0.0, 0.0, 'E')
        if (room(map, tx + 1, ty + 1) && !room(map, tx, ty + 1) && !room(map, tx + 1, ty)) slab(-e, -e, 0.0, 0.0, 'c')
        if (!any) return if (full) null else c.img
        if (full && room(map, tx, ty + 1)) {
            // a window has a sill board standing out a little
            if (tile == Tile.WINDOW) c.box(-0.82, -0.04, -0.18, 0.06, 41.0, 46.0, oakTop, oak, oak)
            // the hearth's mantel shelf with a few things on it
            if (tile == Tile.HEARTH) {
                c.box(-1.0, -0.06, 0.0, 0.08, 89.0, 92.0, oakTop, oak, oak)
                val v = hash(tx, ty, 61)
                val x = c.x(-0.5, 0.01); val y = c.y(-0.5, 0.01, 92.0)
                when (v % 3) {
                    0 -> { c.s.limb(x - 8, y - 1, x - 8, y - 9, 2.8, 2.4, clay); c.s.limb(x + 6, y - 1, x + 6, y - 6, 2.4, 2.2, pewter) }
                    1 -> { c.s.limb(x, y - 1, x, y - 8, 1.3, 1.1, wax); c.s.flat(x, y - 10, 0.9, 1.8, flame); c.s.blob(x + 10, y - 3, 4.0, 3.0, clayGlaze) }
                    else -> { c.s.blob(x - 4, y - 4, 4.5, 4.0, clayPale); c.s.limb(x + 9, y - 1, x + 9, y - 10, 2.0, 1.4, glassBrown) }
                }
            }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /** The door in the front wall: a worn threshold between the cut-off walls. */
    private fun door(tx: Int, ty: Int): PixelImage {
        val c = Canvas((8 + TH + 4).toInt().let { it + it % 2 }, tx + ty)
        // the step outside: trodden earth, fading into the dark
        for (py in 0 until c.h) for (px in 0 until W) {
            val aa = (px + 0.5 - W / 2.0) / (TW / 2); val bb = (py + 0.5 - c.h) / (TH / 2)
            val i = (aa + bb) / 2; val j = (bb - aa) / 2
            if (i < -1 || j < -1 || i > 0 || j > 0) continue
            val k = (1 - (j + 1) / 1.0).coerceIn(0.0, 1.0)
            c.img.set(px, py, mix(argb(0x0A0807), argb(0x3A3024), k * 0.7 + (rnd(px / 2, py, 77) - 0.5) * 0.1))
        }
        c.box(-1.0, -1.0, 0.0, -1.0 + THICK, 0.0, 4.0, oakTop, oakDark, oakDark)
        c.s.outline(outlineColor)
        return c.img
    }

    // ------------------------------------------------------------------ furniture

    /** Tall shelves against the top wall, open towards the room (+j); three looks: full, half-empty and dusty, a sagging board. */
    private fun shelf(v: Int, joinL: Boolean, joinR: Boolean, seed: Int): PixelImage {
        val zt = 110.0
        val c = Canvas((zt + TH + 8).toInt().let { it + it % 2 }, seed)
        val i0 = if (joinL) -1.0 else -0.96; val i1 = if (joinR) 0.0 else -0.04
        val j0 = -1.0; val j1 = -0.58
        c.floorShadow(i0, j0, i1, j1 + 0.1, 0.45)
        // the back boards
        c.s.poly(oakBack, c.x(i0, j0), c.y(i0, j0), c.x(i1, j0), c.y(i1, j0), c.x(i1, j0), c.y(i1, j0, zt), c.x(i0, j0), c.y(i0, j0, zt), tiltX = -0.5, tiltY = 0.3, bevel = 0.0)
        for (k in 1..3) { val ii = i0 + (i1 - i0) * k / 4 + 0.03 * (k % 2); c.s.line(c.x(ii, j0), c.y(ii, j0, 2.0), c.x(ii, j0), c.y(ii, j0, zt - 2), seam) }
        if (!joinL) c.box(i0, j0, i0 + 0.06, j1, 0.0, zt, oakTop, oak, oak)
        val heights = doubleArrayOf(3.0, 27.0, 50.0, 73.0, 96.0)
        for ((k, z0) in heights.withIndex()) {
            val sag = v == 2 && k == 2
            if (sag) {
                // the board bows in the middle under its load
                val mi = (i0 + i1) / 2
                c.s.poly(oakTop, c.x(i0, j0), c.y(i0, j0, z0 + 3), c.x(mi, j0), c.y(mi, j0, z0 - 1), c.x(i1, j0), c.y(i1, j0, z0 + 3),
                    c.x(i1, j1), c.y(i1, j1, z0 + 3), c.x(mi, j1), c.y(mi, j1, z0 - 1), c.x(i0, j1), c.y(i0, j1, z0 + 3), tiltY = -0.72, bevel = 0.6)
                c.s.poly(oak, c.x(i0, j1), c.y(i0, j1, z0), c.x(mi, j1), c.y(mi, j1, z0 - 4), c.x(i1, j1), c.y(i1, j1, z0),
                    c.x(i1, j1), c.y(i1, j1, z0 + 3), c.x(mi, j1), c.y(mi, j1, z0 - 1), c.x(i0, j1), c.y(i0, j1, z0 + 3), tiltX = -0.55, tiltY = 0.3, bevel = 0.8)
            } else c.box(i0, j0, i1, j1, z0, z0 + 3, oakTop, oak, oak)
            if (k == heights.size - 1) break
            // what stands on the board, lined up along i; half-empty: gaps, dust and a cobweb
            var i = i0 + 0.1
            var n = 0
            while (i < i1 - 0.1) {
                val gap = v == 1 && hash(k, n, seed) % 3 != 0
                if (!gap) {
                    val jj = -0.82 + (hash(k, n, seed + 1) % 3) * 0.05
                    val sagZ = if (sag) -4 * (1 - abs((i - (i0 + i1) / 2) / ((i1 - i0) / 2))) else 0.0
                    val x = c.x(i, jj); val y = c.y(i, jj, z0 + 3 + sagZ)
                    when (hash(k, n, seed + 2) % 7) {
                        0 -> { c.s.limb(x, y - 1, x, y - 10, 3.4, 3.0, clay); c.s.blob(x, y - 11, 3.2, 1.5, linen, depth = 0.5) }
                        1 -> { c.s.limb(x, y - 1, x, y - 7, 2.4, 2.3, glass); c.s.limb(x, y - 7, x, y - 11, 1.0, 0.9, glass) }
                        2 -> { c.s.blob(x, y - 4, 5.0, 4.2, clay); c.s.blob(x, y - 7.6, 3.4, 1.2, clay, depth = 0.4) }
                        3 -> { c.s.blob(x, y - 4, 4.6, 4.4, linen, depth = 0.8); c.s.limb(x, y - 8, x + 1, y - 10.5, 1.3, 0.9, linen) }
                        4 -> c.s.limb(x, y - 1, x, y - 6, 2.6, 2.4, pewter)
                        5 -> { c.s.limb(x, y - 1, x, y - 9, 2.2, 2.0, glassBrown); c.s.limb(x, y - 9, x, y - 13, 0.9, 0.8, glassBrown) }
                        else -> { c.s.blob(x, y - 3, 5.5, 3.0, clayGlaze, depth = 0.6); c.s.blob(x, y - 5, 4.0, 1.2, clayGlaze, depth = 0.3) }
                    }
                } else if (k > 0) {
                    // dust on the bare board
                    val x = c.x(i, -0.8); val y = c.y(i, -0.8, z0 + 3)
                    c.s.tint(x, y, 4.0, 1.2, argb(0x7A7062), 0.35)
                }
                i += 0.19 + (n % 3) * 0.035
                n++
            }
        }
        if (v == 1) {
            // a cobweb in the upper corner
            val x0 = c.x(i0 + 0.06, j1); val y0 = c.y(i0 + 0.06, j1, 96.0)
            for (k in 0..4) { val a = Math.toRadians(-90.0 + k * 22); c.s.line(x0, y0, x0 + kotlin.math.cos(a) * 14, y0 + kotlin.math.sin(a) * 12 + 14, cobweb) }
            for (r in listOf(5.0, 9.0, 13.0)) for (k in 0..3) {
                val a0 = Math.toRadians(-90.0 + k * 22); val a1 = Math.toRadians(-90.0 + (k + 1) * 22)
                c.s.line(x0 + kotlin.math.cos(a0) * r, y0 + kotlin.math.sin(a0) * r * 0.85 + r, x0 + kotlin.math.cos(a1) * r, y0 + kotlin.math.sin(a1) * r * 0.85 + r, cobweb)
            }
        }
        c.box(i0, j0, i1, j1, zt, zt + 4, oakTop, oak, oak)
        if (!joinR) c.box(i1 - 0.06, j0, i1, j1, 0.0, zt + 4, oakTop, oak, oak)
        c.s.outline(outlineColor)
        return c.img
    }

    /** The counter along the room's x, its front towards the room (+j), things on its top. */
    private fun counter(v: Int, joinL: Boolean, joinR: Boolean, seed: Int): PixelImage {
        val zt = 54.0
        val c = Canvas((zt + TH + 24).toInt().let { it + it % 2 }, seed)
        val i0 = if (joinL) -1.0 else -0.94; val i1 = if (joinR) 0.0 else -0.06
        c.floorShadow(i0, -0.64, i1, -0.1, 0.5)
        c.box(i0, -0.62, i1, -0.14, 0.0, 4.0, oakDark, oakDark, oakDark)
        c.box(i0 + 0.02, -0.6, i1 - (if (joinR) 0.0 else 0.02), -0.12, 4.0, zt - 5, oakTop, oak, oak)
        // planks of the front, a kick-worn foot, a darker band where hands rest
        var ii = i0 + 0.17
        while (ii < i1 - 0.05) { c.s.line(c.x(ii, -0.12), c.y(ii, -0.12, 5.0), c.x(ii, -0.12), c.y(ii, -0.12, zt - 6), seam); ii += 0.17 + (hash(floor(ii * 10).toInt(), 0, seed) % 3) * 0.02 }
        for (k in 0..30) { val t = k / 30.0; val i = i0 + (i1 - i0) * t; c.s.tint(c.x(i, -0.12), c.y(i, -0.12, 9.0), 2.0, 2.0, argb(0x7A6A50), 0.18) }
        // the ends that are not joined: a framed panel, so the counter reads as one long piece, not as cupboards
        if (!joinR) {
            val ie = i1 - (if (joinR) 0.0 else 0.02)
            for (jj in listOf(-0.52, -0.2)) c.s.line(c.x(ie, jj), c.y(ie, jj, 8.0), c.x(ie, jj), c.y(ie, jj, zt - 9), seam)
            c.s.line(c.x(ie, -0.52), c.y(ie, -0.52, zt - 9), c.x(ie, -0.2), c.y(ie, -0.2, zt - 9), seam)
            c.s.line(c.x(ie, -0.52), c.y(ie, -0.52, 8.0), c.x(ie, -0.2), c.y(ie, -0.2, 8.0), seam)
        }
        // a rail along the top of the front, rubbed pale by knees and boots below it
        c.s.line(c.x(i0, -0.12), c.y(i0, -0.12, zt - 7), c.x(i1, -0.12), c.y(i1, -0.12, zt - 7), argb(0x2A1C12))
        c.box(i0, -0.68, i1, -0.06, zt - 5, zt, oakTop, oak, oak)
        // a long worn ring of wet mugs
        c.s.tint(c.x((i0 + i1) / 2 + 0.1, -0.32), c.y((i0 + i1) / 2 + 0.1, -0.32, zt), 6.0, 2.4, argb(0x2A1C12), 0.35)
        fun at(i: Double, j: Double) = c.x(i, j) to c.y(i, j, zt)
        when (v % 3) {
            0 -> {
                at(-0.75, -0.4).let { (x, y) -> c.s.limb(x, y - 1, x, y - 8, 2.8, 2.5, pewter); c.s.flat(x, y - 8.2, 2.2, 0.9, ale) }
                at(-0.35, -0.5).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.6, 2.3, clay) }
                at(-0.3, -0.25).let { (x, y) -> c.s.blob(x, y - 1, 3.5, 1.2, linen, depth = 0.4) }
                at(-0.55, -0.55).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 1.3, 1.1, wax); c.s.flat(x, y - 9, 0.9, 1.8, flame); c.s.dot(x, y - 9.5, flameHot) }
            }
            1 -> {
                at(-0.6, -0.42).let { (x, y) -> c.s.limb(x, y - 1, x, y - 12, 4.0, 3.2, clay); c.s.limb(x + 4, y - 9, x + 6, y - 5, 1.2, 1.0, clay); c.s.limb(x, y - 12, x, y - 14, 2.2, 2.0, clay) }
                at(-0.25, -0.35).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.6, 2.4, pewter); c.s.flat(x, y - 7.2, 2.0, 0.8, ale) }
                at(-0.85, -0.55).let { (x, y) -> c.s.limb(x, y - 1, x, y - 5, 1.6, 1.4, wax); c.s.flat(x, y - 7, 1.0, 1.8, flame); c.s.dot(x, y - 7.5, flameHot) }
            }
            else -> {
                at(-0.7, -0.45).let { (x, y) -> c.s.limb(x, y - 1, x, y - 9, 1.4, 1.2, wax); c.s.flat(x, y - 11, 1.0, 2.0, flame); c.s.dot(x, y - 11.5, flameHot) }
                at(-0.4, -0.3).let { (x, y) -> c.s.blob(x, y - 2, 6.0, 2.6, clayPale, depth = 0.5); c.s.flat(x, y - 3, 4.2, 1.2, argb(0x4A2E1A)) }
                at(-0.15, -0.5).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.4, 2.2, pewter) }
            }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /** A trestle table along the room's x, things on its top; three looks of what is left on it. */
    private fun table(v: Int, joinL: Boolean, joinR: Boolean, seed: Int): PixelImage {
        val zt = 42.0
        val c = Canvas((zt + TH + 24).toInt().let { it + it % 2 }, seed)
        val i0 = if (joinL) -1.0 else -0.94; val i1 = if (joinR) 0.0 else -0.06
        val j0 = -0.84; val j1 = -0.16
        c.floorShadow(i0, j0, i1, j1, 0.4)
        // trestles at the ends that are not joined: an upright board on a foot, under the top
        fun trestle(i: Double) {
            c.box(i - 0.04, j0 + 0.02, i + 0.04, j1 - 0.02, 0.0, 4.0, oakDark, oakDark, oakDark)
            c.box(i - 0.025, j0 + 0.2, i + 0.025, j1 - 0.2, 4.0, zt - 5, oak, oak, oak)
        }
        if (!joinL) trestle(i0 + 0.12)
        if (!joinR) trestle(i1 - 0.12)
        // a stretcher along the table where it is long
        if (joinL || joinR) c.box(i0, -0.53, i1, -0.47, 14.0, 18.0, oakDark, oakDark, oakDark)
        c.box(i0, j0, i1, j1, zt - 5, zt, oakTop, oak, oak)
        for (k in 1..2) { val jj = j0 + (j1 - j0) * k / 3; c.s.line(c.x(i0, jj), c.y(i0, jj, zt), c.x(i1, jj), c.y(i1, jj, zt), seam) }
        // knife marks and a ring of a wet mug
        c.s.tint(c.x(-0.5, -0.4), c.y(-0.5, -0.4, zt), 4.0, 1.6, argb(0x2A1C12), 0.3)
        fun at(i: Double, j: Double) = c.x(i, j) to c.y(i, j, zt)
        when (v % 3) {
            0 -> {
                at(-0.7, -0.6).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.6, 2.4, pewter); c.s.flat(x, y - 7.2, 2.0, 0.8, ale) }
                at(-0.35, -0.38).let { (x, y) -> c.s.blob(x, y - 1.6, 6.0, 2.8, clay, depth = 0.5); c.s.flat(x, y - 2.6, 4.2, 1.4, argb(0x4A2E1A)) }
                at(-0.2, -0.65).let { (x, y) -> c.s.limb(x, y - 1, x, y - 8, 1.3, 1.1, wax); c.s.flat(x, y - 10, 0.9, 2.0, flame) }
            }
            1 -> {
                at(-0.55, -0.5).let { (x, y) -> c.s.blob(x, y - 2.4, 5.6, 3.2, bread, depth = 0.8); c.s.line(x - 3, y - 3, x + 2, y - 4, argb(0x5A3A1E)) }
                at(-0.25, -0.3).let { (x, y) -> c.s.limb(x - 6, y - 1, x + 6, y - 2, 0.7, 0.5, iron) }
                at(-0.45, -0.68).let { (x, y) -> c.s.limb(x, y - 1, x, y - 6, 1.3, 1.1, wax); c.s.flat(x, y - 8, 0.9, 1.8, flame); c.s.dot(x, y - 8.5, flameHot) }
                // a tipped-over mug and a puddle of ale
                at(-0.8, -0.3).let { (x, y) -> c.s.flat(x + 3, y, 5.0, 1.6, ale); c.s.limb(x - 3, y - 2, x + 3, y - 1, 2.4, 2.2, clay) }
            }
            else -> {
                at(-0.6, -0.65).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.6, 2.4, clay); c.s.flat(x, y - 7.2, 2.0, 0.8, ale) }
                at(-0.4, -0.35).let { (x, y) -> c.s.limb(x, y - 1, x, y - 7, 2.6, 2.4, pewter) }
                at(-0.75, -0.4).let { (x, y) -> c.s.limb(x, y - 1, x, y - 4, 1.6, 1.5, wax); c.s.flat(x, y - 6, 0.9, 1.6, flame) }
                // dice and a few coins
                at(-0.2, -0.5).let { (x, y) -> c.s.flat(x, y - 1, 1.3, 1.0, argb(0xC8B898)); c.s.flat(x + 4, y, 1.3, 1.0, argb(0xC8B898)); c.s.flat(x - 5, y + 1, 1.6, 0.8, argb(0xA88A4A)) }
            }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /**
     * A bench along the room's x. Beside a table it is a settle (13p.1): the seat towards the table, a high
     * back of planks on the side away from it ([back] +1 at the front, −1 at the back, 0 none), so it reads
     * as something in the way and not as a board on the floor to step over.
     */
    private fun bench(joinL: Boolean, joinR: Boolean, seed: Int, back: Int = 0): PixelImage {
        val zt = 26.0
        val zb = 56.0
        val c = Canvas(((if (back != 0) zb else zt) + TH + 8).toInt().let { it + it % 2 }, seed)
        val i0 = if (joinL) -1.0 else -0.92; val i1 = if (joinR) 0.0 else -0.08
        // the seat lies towards the table, the back stands on the far side
        val j0 = when (back) { 1 -> -0.84; -1 -> -0.56; else -> -0.66 }
        val j1 = j0 + 0.36
        c.floorShadow(i0, j0, i1, j1 + if (back == 1) 0.08 else 0.0, 0.4)
        fun leg(i: Double) = c.box(i - 0.03, j0 + 0.04, i + 0.03, j1 - 0.04, 0.0, zt - 4, oakDark, oak, oak)
        fun backBoard() {
            val b0 = if (back == 1) j1 else j0 - 0.08
            val b1 = b0 + 0.08
            c.box(i0, b0, i1, b1, 0.0, zb, oakDark, oak, oakDark)
            // planks and a rubbed top rail
            var k = i0 + 0.16
            while (k < i1 - 0.05) { c.s.line(c.x(k, b1), c.y(k, b1, 3.0), c.x(k, b1), c.y(k, b1, zb - 5), seam); k += 0.16 }
            c.box(i0, b0 - 0.01, i1, b1 + 0.01, zb - 4, zb, oakTop, oak, oak)
        }
        if (back == -1) backBoard()
        if (!joinL) leg(i0 + 0.1)
        if (!joinR) leg(i1 - 0.1)
        c.box(i0, j0, i1, j1, zt - 4, zt, oakTop, oak, oak)
        c.s.line(c.x(i0, (j0 + j1) / 2), c.y(i0, (j0 + j1) / 2, zt), c.x(i1, (j0 + j1) / 2), c.y(i1, (j0 + j1) / 2, zt), seam)
        if (back == 1) backBoard()
        c.s.outline(outlineColor)
        return c.img
    }

    /** A bed along the room's y, its head against the wall (−j); [head]/[foot] which part of it this tile holds. */
    private fun bed(v: Int, head: Boolean, foot: Boolean, seed: Int): PixelImage {
        val c = Canvas((52 + TH + 8).toInt().let { it + it % 2 }, seed)
        val i0 = -0.86; val i1 = -0.14
        val j0 = if (head) -0.96 else -1.0; val j1 = if (foot) -0.06 else 0.0
        c.floorShadow(i0, j0, i1, j1, 0.45)
        if (head) c.box(i0, -1.0, i1, -0.93, 0.0, 50.0, oakTop, oak, oak)
        c.box(i0, j0, i1, j1, 0.0, 16.0, oakTop, oakDark, oakDark)
        c.box(i0 + 0.03, j0, i1 - 0.03, j1 - 0.02, 16.0, 24.0, m(0x6E5E44, grain = 0.14, sat = 0.6, value = 0.7, bias = -0.5), linen, linen)
        val blanket = when (v % 3) {
            0 -> m(0x6A3A2E, grain = 0.12, sat = 0.75, value = 0.75, bias = -0.55)
            1 -> m(0x3E4632, grain = 0.12, sat = 0.6, value = 0.8, bias = -0.55)
            else -> m(0x4A3A2C, grain = 0.14, sat = 0.6, value = 0.8, bias = -0.55)
        }
        // the blanket over the lower part, thrown back from the pillow
        val bj0 = if (head) -0.6 else -1.0
        c.box(i0 + 0.01, bj0, i1 - 0.01, j1, 22.0, 27.0, blanket, blanket, blanket, bevel = 2.0)
        // folds in the blanket
        for (k in 0..2) { val jj = bj0 + 0.2 + k * 0.27 + rnd(k, v, seed) * 0.06; if (jj < j1 - 0.05) c.s.line(c.x(i0 + 0.1, jj), c.y(i0 + 0.1, jj, 27.0), c.x(i1 - 0.15, jj + 0.05), c.y(i1 - 0.15, jj + 0.05, 27.0), argb(0x24140E)) }
        if (head) {
            val x = c.x(-0.5, -0.8); val y = c.y(-0.5, -0.8, 26.0)
            c.s.blob(x, y, 12.0, 5.0, m(0x8A7E66, grain = 0.1, sat = 0.5, value = 0.75, bias = -0.15), depth = 0.6)
            c.s.line(x - 6, y - 1, x + 5, y - 2, argb(0x4E4434))
        }
        if (foot) {
            c.box(i0, -0.08, i1, 0.0, 0.0, 32.0, oakTop, oak, oak)
            // a pair of boots or a bag by the foot
            if (v % 3 == 1) { val x = c.x(-0.2, 0.08); val y = c.y(-0.2, 0.08); c.s.limb(x, y - 1, x, y - 9, 2.6, 2.4, oakDark); c.s.limb(x + 6, y - 1, x + 6, y - 9, 2.6, 2.4, oakDark) }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /** Crates: one with a lid, a stack of two, a broken one spilling straw. */
    private fun crates(v: Int, seed: Int): PixelImage {
        val c = Canvas((80 + TH + 8).toInt().let { it + it % 2 }, seed)
        fun crate(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, broken: Boolean = false) {
            c.box(i0, j0, i1, j1, z0, z1, oakTop, oak, oak)
            // planks: seams on both faces, battens at the corners
            for (k in 1..2) {
                val zz = z0 + (z1 - z0) * k / 3
                c.s.line(c.x(i0, j1), c.y(i0, j1, zz), c.x(i1, j1), c.y(i1, j1, zz), seam)
                c.s.line(c.x(i1, j0), c.y(i1, j0, zz), c.x(i1, j1), c.y(i1, j1, zz), seam)
            }
            c.s.line(c.x(i1, j1), c.y(i1, j1, z0), c.x(i1, j1), c.y(i1, j1, z1), argb(0x2A1C12))
            if (broken) {
                // a kicked-in plank and straw coming out
                val x = c.x((i0 + i1) / 2, j1); val y = c.y((i0 + i1) / 2, j1, (z0 + z1) / 2)
                c.s.poly(m(0x120C08), x - 6, y - 4, x + 5, y - 2, x + 3, y + 5, x - 4, y + 3, bevel = 0.0)
                c.s.blob(x, y + 6, 6.0, 3.0, straw, depth = 0.5)
                c.s.blob(x - 3, y + 9, 5.0, 2.0, straw, depth = 0.4)
            }
        }
        when (v % 3) {
            0 -> { c.floorShadow(-0.85, -0.85, -0.15, -0.15); crate(-0.82, -0.82, -0.18, -0.18, 0.0, 34.0); c.box(-0.84, -0.84, -0.16, -0.16, 34.0, 37.0, oakTop, oak, oak) }
            1 -> { c.floorShadow(-0.88, -0.88, -0.12, -0.12); crate(-0.86, -0.86, -0.14, -0.14, 0.0, 36.0); crate(-0.72, -0.78, -0.26, -0.32, 36.0, 62.0) }
            else -> { c.floorShadow(-0.85, -0.85, -0.15, -0.15); crate(-0.8, -0.8, -0.2, -0.2, 0.0, 32.0, broken = true) }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /** Firewood by the fire, logs along the room's x with their cut ends towards +i; three looks. */
    private fun firewood(v: Int, seed: Int): PixelImage {
        val c = Canvas((60 + TH + 8).toInt().let { it + it % 2 }, seed)
        c.floorShadow(-0.92, -0.85, -0.1, -0.2, 0.45)
        fun log(i0: Double, i1: Double, j: Double, z: Double, r: Double, k: Int) {
            val mat = if (hash(k, 0, seed) % 7 == 0) barkBirch else bark
            c.s.limb(c.x(i0, j), c.y(i0, j, z), c.x(i1, j), c.y(i1, j, z), r, r * 0.95, mat)
            // the cut end, pale with rings
            val x = c.x(i1, j); val y = c.y(i1, j, z)
            c.s.blob(x, y, r * 0.75, r * 0.95, splitFace, depth = 0.3)
            c.s.flat(x, y, r * 0.3, r * 0.4, argb(0x6A4E32))
        }
        val r = 4.6
        val rows = if (v % 3 == 2) 2 else 3
        var k = 0
        for (row in 0 until rows) {
            val n = 4 - row
            for (q in 0 until n) {
                val j = -0.78 + (q + row * 0.5) * 0.15
                val i0 = -0.86 + rnd(row, q, seed) * 0.08
                val i1 = -0.22 - rnd(q, row, seed) * 0.1
                log(i0, i1, j, r + row * 2 * r * 0.85, r, k++)
            }
        }
        when (v % 3) {
            1 -> {
                // an axe leaning against the stack
                val x = c.x(-0.1, -0.2); val y = c.y(-0.1, -0.2)
                c.s.limb(x, y - 1, x - 8, y - 30, 1.2, 1.0, oak)
                c.s.poly(iron, x - 10, y - 34, x - 3, y - 31, x - 4, y - 26, x - 9, y - 28, tiltX = -0.3)
            }
            2 -> {
                // a chopping block with chips about it
                val x = c.x(-0.25, -0.3); val y = c.y(-0.25, -0.3)
                c.s.limb(x, y - 2, x, y - 14, 7.0, 7.0, bark)
                c.s.blob(x, y - 14, 7.0, 3.2, splitFace, depth = 0.3)
                for (q in 0 until 5) c.s.flat(x - 10 + q * 5 + rnd(q, 1, seed) * 3, y + rnd(q, 2, seed) * 3, 1.4, 0.7, argb(0x8A6C48))
            }
        }
        c.s.outline(outlineColor)
        return c.img
    }

    /** How many pictures the fire in a hearth flickers through ([fireFrame]). */
    const val FIRE_FRAMES = 6

    /** How long each picture of the fire stands, ms: irregular, and 13 of them against 6 pictures, so it never repeats in step. */
    private val FIRE_MS = intArrayOf(110, 80, 150, 95, 130, 70, 120, 160, 90, 105, 140, 75, 125)
    private val FIRE_CYCLE = FIRE_MS.sum()

    /**
     * The picture of the fire at [clock] ms: always the next one after the last, never a jump (the pictures are
     * made so that the last leads into the first), but each one standing for its own, uneven while.
     */
    fun fireFrame(clock: Long): Int {
        val cycle = Math.floorDiv(clock, FIRE_CYCLE.toLong())
        var t = Math.floorMod(clock, FIRE_CYCLE.toLong()).toInt()
        var step = 0
        while (t >= FIRE_MS[step]) { t -= FIRE_MS[step]; step++ }
        return Math.floorMod(cycle * FIRE_MS.size + step, FIRE_FRAMES.toLong()).toInt()
    }

    private val charred = m(0x2A1C14, grain = 0.3, sat = 0.6, value = 0.8)

    /**
     * The fire in a hearth's fire box, picture [f] of [FIRE_FRAMES], seen diagonally: a bed of embers, two
     * charred logs crossed on the fire dogs, tongues of flame of their own heights and sway, and the kettle
     * on its chain over them. The tongues move on a circle of phases, so picture after picture changes only a
     * little and the last leads back into the first. The front corner of the picture is the middle of the
     * mouth on the face of the wall; the fire burns 0.2 tiles back (local j −0.2).
     */
    private fun fire(f: Int, seed: Int): PixelImage {
        val c = Canvas(96, seed)
        val ph = f * 2 * Math.PI / FIRE_FRAMES
        val fj = -0.2
        // embers: a glowing bed, pulsing a little from picture to picture
        for (py in 0 until c.h) for (px in 0 until W) {
            val a = (px + 0.5 - W / 2.0) / (TW / 2); val b = (py + 0.5 - c.h) / (TH / 2)
            val i = (a + b) / 2; val j = (b - a) / 2
            val d = (i / 0.32) * (i / 0.32) + ((j - fj) / 0.13) * ((j - fj) / 0.13)
            if (d >= 1) continue
            val n = rnd(px / 2, py, seed + 11)
            val pulse = 0.5 + 0.5 * kotlin.math.sin(ph + n * 6.28)
            val hot = (1 - d) * (0.55 + 0.45 * pulse)
            c.img.set(px, py, when {
                n < 0.18 -> argb(0x2A2420)                          // ash
                hot > 0.62 -> argb(0xFFC860)
                hot > 0.38 -> argb(0xF08A30)
                hot > 0.18 -> argb(0xA8401A)
                else -> argb(0x4A1E10)
            })
        }
        // the fire dogs
        for (si in listOf(-0.3, 0.3)) {
            val x = c.x(si, -0.06); val y = c.y(si, -0.06)
            c.s.limb(x, y - 1, x, y - 11, 1.4, 1.2, iron)
            c.s.blob(x, y - 12, 1.8, 1.8, iron)
        }
        // two charred logs, crossed, cracks glowing
        fun log(i0: Double, j0: Double, z0: Double, i1: Double, j1: Double, z1: Double, r: Double) {
            c.s.limb(c.x(i0, j0), c.y(i0, j0, z0), c.x(i1, j1), c.y(i1, j1, z1), r, r * 0.9, charred)
            for (k in 1..4) {
                val t = k / 5.0 + (rnd(k, f, seed) - 0.5) * 0.04
                val x = c.x(i0 + (i1 - i0) * t, j0 + (j1 - j0) * t); val y = c.y(i0 + (i1 - i0) * t, j0 + (j1 - j0) * t, z0 + (z1 - z0) * t)
                c.s.flat(x, y + r * 0.3, 1.2, 0.6, if ((k + f) % 3 == 0) argb(0xFFB040) else argb(0xC0501C))
            }
        }
        log(-0.36, -0.26, 5.0, 0.32, -0.16, 7.0, 3.6)
        log(-0.3, -0.12, 9.0, 0.36, -0.27, 6.0, 3.2)
        // the kettle on its chain, from the top of the mouth
        run {
            val x = c.x(0.0, fj); val top = c.y(0.0, fj, 56.0); val k = c.y(0.0, fj, 31.0)
            var y = top
            while (y < k) { c.s.dot(x + (if (((y - top) / 2).toInt() % 2 == 0) 0.0 else 1.0), y, argb(0x2A2622)); y += 1.0 }
            c.s.blob(x, c.y(0.0, fj, 24.0), 9.0, 7.0, iron)
            c.s.limb(x - 9, c.y(0.0, fj, 29.0), x + 9, c.y(0.0, fj, 29.0), 1.2, 1.2, iron)
            c.s.blob(x, c.y(0.0, fj, 31.0), 5.5, 1.6, iron, depth = 0.4)
        }
        // the tongues of flame, outer ones first: each its own height, rhythm and sway
        val n = 7
        val order = listOf(0, 6, 1, 5, 2, 4, 3)
        for (k in order) {
            val ti = -0.27 + k * 0.09
            val centre = 1 - abs(k - 3) / 3.5
            val m1 = 1 + hash(k, 1, seed) % 2; val m2 = 1 + hash(k, 2, seed) % 2
            val o1 = rnd(k, 3, seed) * 6.28; val o2 = rnd(k, 4, seed) * 6.28
            val hgt = (9 + 19 * centre) * (0.62 + 0.38 * kotlin.math.sin(ph * m1 + o1)) * ZS
            val sway = 2.4 * kotlin.math.sin(ph * m2 + o2)
            val hw = 2.6 + 2.4 * centre
            val bx = c.x(ti, fj + (k % 2) * 0.04); val by = c.y(ti, fj + (k % 2) * 0.04, 8.0)
            var r = 0
            while (r < hgt) {
                val t = r / hgt
                val half = hw * Math.pow(1 - t, 0.8) * (1 + 0.25 * kotlin.math.sin(t * 3.0 + ph))
                val cx = bx + sway * t * t
                val y = by - r
                var x = floor(cx - half)
                while (x <= cx + half) {
                    val edge = abs(x + 0.5 - cx) / half.coerceAtLeast(0.5)
                    val heat = t + edge * 0.35
                    val col = when { heat < 0.32 -> argb(0xFFF0B0); heat < 0.58 -> argb(0xFFC860); heat < 0.82 -> argb(0xF08A30); else -> argb(0xC04E1C) }
                    c.img.set(x.toInt(), y.toInt(), col)
                    x += 1.0
                }
                r++
            }
        }
        return c.img
    }

    // ------------------------------------------------------------------ round things (13p.3)

    /** Upright art pixels per centimetre, the scale of the room's heights. */
    private const val ZCM = 0.57 * ZS
    /** A tile's side in centimetres, at the hero's scale. */
    private const val TILE_CM = 116.0

    private val hoopIron = m(0x4A4640, shine = 0.35, grain = 0.2, sat = 0.45)
    private val wicker = m(0x8A7448, grain = 0.4, sat = 0.7, value = 0.85)
    private val sackcloth = m(0x6E5E44, grain = 0.32, sat = 0.62, value = 0.72)
    private val turnip = m(0xB8A8B0, shine = 0.15, grain = 0.12, sat = 0.5, value = 0.9)
    private val turnipTop = m(0x6E4A6E, grain = 0.1, sat = 0.6, value = 0.8)
    private val leaf = m(0x3A5230, grain = 0.25, sat = 0.7, value = 0.8)
    private val leafDark = m(0x26361F, grain = 0.2, sat = 0.6, value = 0.8)
    private val water = argb(0x1C2426)

    /** A radius in centimetres on the floor as the half width of its ellipse on the screen; the height is half of it. */
    private fun rx(cm: Double) = cm / TILE_CM * TW / sqrt(2.0)

    /** The middle of the tile on the floor. */
    private fun Canvas.mid() = x(-0.5, -0.5) to y(-0.5, -0.5)

    /** A soft round shadow on the floor around (ox, oy): a circle, so an ellipse twice as wide as high; laid after the outline, under the thing. */
    private fun Canvas.roundShadow(ox: Double, oy: Double, rcm: Double, a: Double = 0.5) {
        val r = rx(rcm) + 3
        for (py in 0 until h) for (px in 0 until W) {
            val u = (px + 0.5 - ox) / r; val v = (py + 0.5 - oy) / (r / 2)
            val d = sqrt(u * u + v * v)
            if (d >= 1.0 || img.opaque(px, py)) continue
            val k = (1 - d * d) * a
            img.set(px, py, ((k * 255).toInt().coerceIn(0, 255) shl 24) or 0x0A0806)
        }
    }

    /**
     * An upright round body standing on (ox, oy), from [z0] to [z0] + [hcm] centimetres, its radius [r] at
     * the share t (0 at the foot, 1 at the top) of its height: lit as a cylinder, seen from above at the
     * room's angle, so its foot is the front half of an ellipse 2:1.
     */
    private fun Canvas.round(ox: Double, oy: Double, hcm: Double, m: Mat, z0: Double = 0.0, r: (Double) -> Double) {
        val rMax = (0..20).maxOf { r(it / 20.0) }
        val top = oy - (z0 + hcm) * ZCM - rx(rMax) / 2 - 1
        s.surface(ox - rx(rMax) - 1, top, ox + rx(rMax) + 1, oy - z0 * ZCM + rx(rMax) / 2 + 1, m) { x, y, n ->
            var z = (oy - y) / ZCM - z0
            var u = 0.0
            for (k in 0 until 3) {
                val rr = rx(r((z / hcm).coerceIn(0.0, 1.0)))
                u = (x - ox) / rr
                if (abs(u) > 1) return@surface false
                z = (oy - z0 * ZCM + rr / 2 * sqrt(1 - u * u) - y) / ZCM
            }
            if (z < 0 || z > hcm) return@surface false
            // the slope of the side: a body swelling outwards faces a little down below its middle, up above it
            val t = z / hcm
            val slope = (r((t + 0.05).coerceAtMost(1.0)) - r((t - 0.05).coerceAtLeast(0.0))) / (hcm * 0.1)
            val nz = sqrt((1 - u * u).coerceAtLeast(0.0))
            val ny = slope * 0.8
            val l = sqrt(u * u + ny * ny + nz * nz)
            n[0] = u / l; n[1] = ny / l; n[2] = nz / l
            true
        }
    }

    /** A flat round top at [zcm] (a lid, a seat, the water in a bucket), lit from above. */
    private fun Canvas.disc(ox: Double, oy: Double, zcm: Double, rcm: Double, m: Mat) {
        val a = rx(rcm); val y0 = oy - zcm * ZCM
        val pts = ArrayList<Double>()
        for (k in 0 until 32) { val t = k * Math.PI * 2 / 32; pts += ox + a * kotlin.math.cos(t); pts += y0 + a / 2 * kotlin.math.sin(t) }
        s.poly(m, *pts.toDoubleArray(), tiltY = -0.72, bevel = 1.2)
    }

    /** The front half of a ring round a body at [zcm] (a hoop, a rim), [w] pixels thick. */
    private fun Canvas.hoop(ox: Double, oy: Double, zcm: Double, rcm: Double, m: Mat, w: Double = 1.2, from: Double = 0.0, to: Double = Math.PI) {
        val a = rx(rcm); val y0 = oy - zcm * ZCM
        val n = 18
        for (k in 0 until n) {
            val t0 = from + (to - from) * k / n; val t1 = from + (to - from) * (k + 1) / n
            s.limb(ox + a * kotlin.math.cos(t0), y0 + a / 2 * kotlin.math.sin(t0), ox + a * kotlin.math.cos(t1), y0 + a / 2 * kotlin.math.sin(t1), w, w, m)
        }
    }

    /** A line down the side of a round body at the angle [ang] (0 straight at us), following its swell. */
    private fun Canvas.stave(ox: Double, oy: Double, hcm: Double, ang: Double, c: Int, z0: Double = 0.0, r: (Double) -> Double) {
        val u = kotlin.math.sin(ang); val v = kotlin.math.cos(ang)
        var px = 0.0; var py = 0.0
        for (k in 0..12) {
            val t = k / 12.0
            val rr = rx(r(t))
            val x = ox + rr * u; val y = oy - (z0 + t * hcm) * ZCM + rr / 2 * v
            if (k > 0) s.line(px, py, x, y, c)
            px = x; py = y
        }
    }

    /** A barrel on its foot, three looks: with a tap, with a tankard and a rag on the lid, open with ale and a ladle. */
    private fun barrel(v: Int, seed: Int): PixelImage {
        val hcm = 88.0
        val c = Canvas((hcm * ZCM + TH / 2 + 16).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val r = { t: Double -> 26.0 + 5.0 * kotlin.math.sin(t * Math.PI) }
        c.round(ox, oy, hcm, oak, r = r)
        for (k in -3..3) c.stave(ox, oy, hcm, k * 0.42 + (v % 2) * 0.2, argb(0x2E2016), r = r)
        // one stave darker, the grime of the foot
        c.s.tint(ox - rx(18.0), oy - hcm * ZCM * 0.5, 2.4, hcm * ZCM * 0.45, argb(0x2A1E16), 0.3)
        c.s.tint(ox, oy - 3, rx(30.0), 4.0, argb(0x14100C), 0.45)
        // hoops at foot, belly and head, rust running from them
        for ((k, t) in doubleArrayOf(0.1, 0.36, 0.64, 0.9).withIndex()) {
            val drop = if (v % 3 == 2 && k == 3) -2.0 else 0.0
            c.hoop(ox, oy, t * hcm + drop, r(t), hoopIron, 1.0, 0.12, Math.PI - 0.12)
            c.s.tint(ox + (rnd(k, v, 1) - 0.5) * 20, oy - t * hcm * ZCM + 6, 2.5, 3.0, argb(0x5A3418), 0.3)
        }
        // the head: a rim round the lid
        c.disc(ox, oy, hcm, r(1.0) + 0.4, oakDark)
        when (v % 3) {
            2 -> {
                c.disc(ox, oy, hcm - 1.5, r(1.0) - 3.0, oakBack)
                c.s.flat(ox, oy - (hcm - 2) * ZCM + 1, rx(r(1.0) - 5.0), rx(r(1.0) - 5.0) / 2, ale)
                c.s.dot(ox - 4.0, oy - hcm * ZCM + 1, argb(0x5A3A1E))
                // the ladle hanging over the rim
                c.s.limb(ox + 3.0, oy - hcm * ZCM, ox + rx(r(1.0)) + 3, oy - hcm * ZCM - 8, 1.0, 0.9, oak)
                c.s.blob(ox + 1.0, oy - hcm * ZCM + 1, 3.0, 1.5, oakTop, depth = 0.3)
            }
            else -> {
                c.disc(ox, oy, hcm + 0.6, r(1.0) - 2.0, oakTop)
                // boards across the lid, along the ellipse
                for (k in -1..1) {
                    val off = k * rx(r(1.0)) * 0.36
                    c.s.line(ox - rx(r(1.0)) * 0.8 + off * 0.5, oy - (hcm + 0.6) * ZCM + off * 0.5 - 2, ox + rx(r(1.0)) * 0.8 + off * 0.5, oy - (hcm + 0.6) * ZCM + off * 0.5 + 2, seam)
                }
                if (v % 3 == 1) {
                    val ty = oy - (hcm + 0.6) * ZCM
                    c.s.limb(ox - 4.0, ty, ox - 4.0, ty - 7, 2.6, 2.4, pewter); c.s.flat(ox - 4.0, ty - 7.2, 2.0, 0.8, ale)
                    c.s.blob(ox + 6.0, ty + 1, 5.0, 2.0, linen, depth = 0.6)
                } else {
                    // the tap, and ale that ran down the staves and soaked in
                    val ty = oy - hcm * ZCM * 0.2 + rx(r(0.2)) / 2
                    c.s.tint(ox + 1.0, ty + 6, 2.6, 9.0, ale, 0.45)
                    c.s.limb(ox, ty - 4, ox + 1.0, ty + 1.5, 1.6, 1.2, iron)
                    c.s.limb(ox - 1.6, ty - 5, ox + 1.6, ty - 5.5, 0.8, 0.8, iron)
                    c.s.dot(ox + 1.0, ty + 2.5, ale)
                }
            }
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 34.0, 0.55)
        return c.img
    }

    /** A three-legged stool, three looks: bare, a mug left on it, a rag thrown over it. */
    private fun stool(v: Int, seed: Int): PixelImage {
        val zt = 46.0
        val c = Canvas((zt * ZCM + TH / 2 + 14).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val turn = rnd(seed, v, 5) * 2
        // the legs splay out from under the seat; those at the back first
        val legs = (0 until 3).map { turn + it * Math.PI * 2 / 3 }.sortedBy { kotlin.math.sin(it) }
        for (a in legs) {
            val tx = ox + rx(10.0) * kotlin.math.cos(a); val ty = oy - (zt - 4) * ZCM + rx(10.0) / 2 * kotlin.math.sin(a)
            val bx = ox + rx(19.0) * kotlin.math.cos(a); val by = oy + rx(19.0) / 2 * kotlin.math.sin(a)
            c.s.limb(tx, ty, bx, by, 1.3, 1.1, if (kotlin.math.sin(a) < 0) oakDark else oak)
        }
        c.round(ox, oy, 4.0, oak, z0 = zt - 4) { 17.0 }
        c.disc(ox, oy, zt, 17.0, oakTop)
        c.s.line(ox - rx(12.0), oy - zt * ZCM - 1, ox + rx(12.0), oy - zt * ZCM + 1, seam)
        when (v % 3) {
            1 -> { val ty = oy - zt * ZCM; c.s.limb(ox + 2, ty, ox + 2, ty - 6, 2.4, 2.2, clay); c.s.flat(ox + 2, ty - 6.2, 1.8, 0.7, ale) }
            2 -> { val ty = oy - zt * ZCM; c.s.blob(ox - 2, ty + 1, rx(13.0), 3.4, linenPale, depth = 0.4); c.s.limb(ox + rx(14.0) - 2, ty + 2, ox + rx(15.0), ty + 9, 2.0, 1.4, linenPale) }
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 22.0, 0.45)
        return c.img
    }

    /** A wooden bucket with iron hoops and a rope handle, three looks: water and a ladle, empty and tipped a little, a brush in it. */
    private fun bucket(v: Int, seed: Int): PixelImage {
        val hcm = 32.0
        val c = Canvas((hcm * ZCM + TH / 2 + 26).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val r = { t: Double -> 14.0 + 3.0 * t }
        c.round(ox, oy, hcm, oak, r = r)
        for (k in -3..3) c.stave(ox, oy, hcm, k * 0.45, seam, r = r)
        c.hoop(ox, oy, 5.0, r(5 / hcm) + 0.5, hoopIron, 1.1)
        c.hoop(ox, oy, hcm - 6, r(1 - 6 / hcm) + 0.5, hoopIron, 1.1)
        c.disc(ox, oy, hcm, r(1.0), oakDark)
        c.disc(ox, oy, hcm - 0.3, r(1.0) - 2.0, if (v % 3 == 0) m(0x1C2426, shine = 0.6, sat = 0.6) else oakBack)
        val ty = oy - hcm * ZCM
        // the rope handle over the top, from side to side
        var hx = ox - rx(r(1.0)); var hy = ty
        for (k in 1..8) {
            val t = k / 8.0
            val nx = ox + rx(r(1.0)) * (2 * t - 1); val ny = ty - 12 * kotlin.math.sin(t * Math.PI) - 2 * t
            c.s.limb(hx, hy, nx, ny, 0.7, 0.7, linen); hx = nx; hy = ny
        }
        when (v % 3) {
            0 -> { c.s.limb(ox + 2, ty + 1, ox + rx(r(1.0)) + 4, ty - 10, 0.9, 0.8, oak); c.s.flat(ox - 3, ty + 1, 2.0, 0.8, argb(0x3A4A4E)) }
            2 -> { c.s.limb(ox - 3, ty + 1, ox - 9, ty - 9, 1.1, 1.0, oak); c.s.blob(ox - 1.5, ty + 1.5, 3.4, 1.6, straw, depth = 0.4) }
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 20.0, 0.45)
        return c.img
    }

    /** A wicker basket of turnips, three looks: full, half, tipped over with turnips rolled out. */
    private fun basket(v: Int, seed: Int): PixelImage {
        val hcm = 30.0
        val c = Canvas((hcm * ZCM + TH / 2 + 18).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val r = { t: Double -> 20.0 + 3.0 * t }
        c.round(ox, oy, hcm, wicker, r = r)
        // the weave: rows round the basket and the uprights
        for (k in 1..5) c.hoop(ox, oy, k * hcm / 6, r(k / 6.0) + 0.2, m(0x5A4A2E, grain = 0.3, sat = 0.6), 0.5)
        for (k in -4..4) c.stave(ox, oy, hcm, k * 0.36, argb(0x4A3C24), r = r)
        c.disc(ox, oy, hcm, r(1.0), m(0x6A5636, grain = 0.3, sat = 0.7))
        c.disc(ox, oy, hcm - 0.5, r(1.0) - 2.5, oakBack)
        val ty = oy - hcm * ZCM
        val n = if (v % 3 == 1) 4 else 7
        for (k in 0 until n) {
            val a = k * 2.4 + v; val d = if (k == 0) 0.0 else rx(10.0) * (0.5 + 0.5 * (k % 2))
            val x = ox + d * kotlin.math.cos(a); val y = ty + d / 2 * kotlin.math.sin(a) - (if (v % 3 == 1) -2.0 else 2.0)
            c.s.blob(x, y, 3.8, 3.4, turnip); c.s.blob(x + 0.6, y + 1.4, 2.6, 1.6, turnipTop, depth = 0.5)
            c.s.limb(x - 0.5, y - 3.0, x - 2.0, y - 7.0, 0.7, 0.4, leaf)
        }
        c.hoop(ox, oy, hcm, r(1.0), m(0x6A5636, grain = 0.3, sat = 0.7), 1.0)
        if (v % 3 == 2) for (k in 0 until 3) {
            val x = ox + rx(26.0) + k * 6 - 6; val y = oy + 2 + k * 2
            c.s.blob(x, y - 3, 3.8, 3.4, turnip); c.s.limb(x - 0.5, y - 6, x + 3, y - 9, 0.7, 0.4, leaf)
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 26.0, 0.45)
        return c.img
    }

    /** Sacks of grain against each other, three looks: two standing, one tipped over and spilling, three. */
    private fun sacks(v: Int, seed: Int): PixelImage {
        val c = Canvas((60 * ZCM + TH / 2 + 12).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        fun sack(x: Double, y: Double, hcm: Double, wcm: Double, lean: Double) {
            val hh = hcm * ZCM; val ww = rx(wcm)
            val sl = kotlin.math.sin(lean) * hh
            // slumped: wide and round at the foot where the grain settles, narrowing to a gathered neck
            val pts = doubleArrayOf(
                x - ww * 1.05, y - hh * 0.06, x - ww * 1.1, y - hh * 0.32, x - ww * 0.9 + sl * 0.5, y - hh * 0.62,
                x - ww * 0.45 + sl * 0.8, y - hh * 0.8, x + ww * 0.45 + sl * 0.8, y - hh * 0.8,
                x + ww * 0.9 + sl * 0.5, y - hh * 0.62, x + ww * 1.1, y - hh * 0.32, x + ww * 1.05, y - hh * 0.06,
                x + ww * 0.6, y + ww * 0.28, x - ww * 0.6, y + ww * 0.28,
            )
            c.s.poly(sackcloth, *pts, tiltX = 0.1, tiltY = 0.05, bevel = ww * 0.8)
            val nx = x + sl * 0.85; val ny = y - hh * 0.82
            c.s.limb(nx, ny + 1, nx + sl * 0.1, ny - 4, ww * 0.32, ww * 0.18, sackcloth)
            // the cord, the frayed top, folds down the side
            c.s.line(nx - ww * 0.3, ny, nx + ww * 0.3, ny + 0.5, argb(0x2A2016))
            c.s.limb(nx + sl * 0.1, ny - 4, nx + sl * 0.12 + 2, ny - 7, 1.4, 0.5, sackcloth)
            c.s.line(x - ww * 0.35 + sl * 0.5, y - hh * 0.6, x - ww * 0.6, y - hh * 0.15, argb(0x40362A))
            c.s.line(x + ww * 0.25 + sl * 0.5, y - hh * 0.55, x + ww * 0.45, y - hh * 0.2, argb(0x40362A))
        }
        when (v % 3) {
            0 -> { sack(ox - 8, oy - 3, 58.0, 20.0, -0.1); sack(ox + 7, oy + 3, 52.0, 20.0, 0.15) }
            1 -> {
                sack(ox - 7, oy - 2, 58.0, 20.0, -0.08)
                // one lying on its side, grain run out on the floor
                c.s.blob(ox + 14, oy + 3, rx(26.0), 7.0, sackcloth, rot = 0.42, depth = 0.85)
                for (k in 0 until 14) c.s.dot(ox + 24 + rnd(k, v, 9) * 12, oy + 8 + rnd(k, v, 10) * 5, if (k % 3 == 0) argb(0x6A5A38) else argb(0x84704A))
            }
            else -> { sack(ox - 12, oy - 4, 56.0, 18.0, -0.12); sack(ox + 10, oy - 2, 50.0, 18.0, 0.1); sack(ox - 1, oy + 5, 46.0, 19.0, 0.04) }
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 38.0, 0.5)
        return c.img
    }

    /** A heap of straw on the floor, three looks: a pitchfork lying across, a fork stuck in it, trodden flat. */
    private fun straw(v: Int, seed: Int): PixelImage {
        val c = Canvas((30 * ZCM + TH / 2 + 30).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val hh = (if (v % 3 == 2) 14.0 else 26.0) * ZCM
        val a = rx(38.0)
        // a mound of loose clumps, the ones at the back first
        val clumps = (0 until 9).map { k ->
            val ang = k * 2.4 + v; val d = if (k == 0) 0.0 else a * (0.35 + 0.4 * rnd(k, v, 54))
            Triple(ox + d * kotlin.math.cos(ang), oy + d / 2 * kotlin.math.sin(ang), k)
        }.sortedBy { it.second }
        for ((x, y, k) in clumps) {
            val rr = a * (if (k == 0) 0.62 else 0.42) * (0.8 + 0.4 * rnd(k, v, 55))
            val hz = hh * (if (k == 0) 1.0 else 0.6) * (0.7 + 0.5 * rnd(k, v, 56))
            c.s.blob(x, y - hz * 0.45, rr, hz * 0.55 + rr * 0.25, straw, depth = 0.7)
        }
        for (k in 0 until 26) {
            val x = ox + (rnd(k, v, 50) - 0.5) * a * 1.5; val y = oy - hh * 0.5 + (rnd(k, v, 51) - 0.5) * hh * 0.8
            c.s.line(x, y, x + (rnd(k, v, 52) - 0.5) * 8, y + (rnd(k, v, 53) - 0.5) * 3, if (k % 2 == 0) argb(0xC8B070) else argb(0x6A5630))
        }
        when (v % 3) {
            0 -> { c.s.limb(ox - a - 4, oy + 4, ox + a * 0.6, oy - hh * 0.6, 0.9, 0.9, oak); for (k in -1..1) c.s.line(ox + a * 0.6, oy - hh * 0.6 + k * 2, ox + a * 0.6 + 8, oy - hh * 0.6 - 3 + k * 2, argb(0x3E3A36)) }
            1 -> { c.s.limb(ox + 3, oy - hh * 0.8, ox + 10, oy - hh - 26, 0.9, 0.9, oak); for (k in -1..1) c.s.line(ox + 3 + k * 2, oy - hh * 0.8, ox + 2 + k * 2.5, oy - hh * 0.8 + 6, argb(0x3E3A36)) }
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 42.0, 0.35)
        return c.img
    }

    /** A plant in a clay pot, three looks: a fern in clay, a glazed pot of herbs, a pale pot with a wilting bush. */
    private fun plant(v: Int, seed: Int): PixelImage {
        val hcm = 32.0
        val c = Canvas((90 * ZCM + TH / 2 + 10).toInt().let { it + it % 2 }, seed)
        val (ox, oy) = c.mid()
        val r = { t: Double -> 13.0 + 4.0 * t }
        val pot = listOf(clay, clayGlaze, clayPale)[v % 3]
        c.round(ox, oy, hcm, pot, r = r)
        c.hoop(ox, oy, hcm - 3, r(1.0) + 0.6, pot, 1.6)
        c.disc(ox, oy, hcm, r(1.0) - 1.0, m(0x2A1E14, grain = 0.4, sat = 0.6))
        val ty = oy - hcm * ZCM
        // leaves out of the soil, the ones at the back first, each a tapering stroke curving out
        val n = 15
        val ks = (0 until n).sortedBy { kotlin.math.sin(it * 2.39 + v) }
        for (k in ks) {
            val a = k * 2.39 + v
            val len = (if (v % 3 == 2) 14.0 else 20.0) + rnd(k, v, 16) * 12
            val out = rx(if (v % 3 == 1) 22.0 else 34.0) * (0.6 + rnd(k, v, 17) * 0.5)
            val bx = ox + out * kotlin.math.cos(a); val by = ty + out / 2 * kotlin.math.sin(a) - len * (if (v % 3 == 2) 0.1 else 0.35)
            val mx = ox + (bx - ox) * 0.45; val my = ty + (by - ty) * 0.45 - len * 0.7
            val mat = if (kotlin.math.sin(a) < 0) leafDark else leaf
            c.s.limb(ox, ty, mx, my, 1.2, 1.6, mat)
            c.s.limb(mx, my, bx, by + (if (v % 3 == 2) len * 0.3 else 0.0), 1.6, 0.5, mat)
        }
        c.s.outline(outlineColor)
        c.roundShadow(ox, oy, 22.0, 0.45)
        return c.img
    }

    // ------------------------------------------------------------------ the tiles

    private val cache = HashMap<String, PixelImage>()
    private fun cached(key: String, make: () -> PixelImage): PixelImage =
        synchronized(cache) { cache[key] } ?: trimTop(make()).also { synchronized(cache) { cache[key] = it } }

    /** Drops the empty rows at the top (heights are drawn lower than the pictures were made for, 13p.6); keeps the height even. */
    private fun trimTop(img: PixelImage): PixelImage {
        var top = 0
        while (top < img.height - 2 && (0 until img.width).none { img.opaque(it, top) }) top++
        top -= top % 2
        if (top == 0) return img
        val out = PixelImage(img.width, img.height - top)
        System.arraycopy(img.pixels, top * img.width, out.pixels, 0, out.pixels.size)
        return out
    }

    /** A picture whose front corner (middle of its bottom edge) stands at map pixel ([wx], [wy]), drawn in order of [depth]. */
    private fun obj(img: PixelImage, wx: Int, wy: Int, depth: Int, low: Boolean = false): WorldArt.Obj {
        val w = img.width / D; val h = img.height / D
        return WorldArt.Obj(img, wx - w / 2, wy - h, depth - wx, D, low, corner = true)
    }

    /** Sorted along the diagonal like a figure standing on the tile (hero: x + y + 1.5 tiles − ½ pixel). */
    private fun depth(tx: Int, ty: Int) = (tx + ty) * T + T * 3 / 2 - 1

    /** The upright pictures of one tile of a room seen diagonally, or null for the pictures seen straight. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int = 0): List<WorldArt.Obj>? {
        fun at(dx: Int, dy: Int) = if (map.inside(tx + dx, ty + dy)) map.tile(tx + dx, ty + dy) else Tile.WALL
        fun same(dx: Int) = at(dx, 0) == map.tile(tx, ty)
        val v = hash(tx, ty, 3)
        val seed = tx * 131 + ty * 17
        val key = "${map.id}/$tx/$ty"
        val fx = (tx + 1) * T; val fy = (ty + 1) * T
        val d = depth(tx, ty)
        fun one(k: String, low: Boolean = true, make: () -> PixelImage) = listOf(obj(cached("$key/$k", make), fx, fy, d, low))
        return when (map.tile(tx, ty)) {
            Tile.WALL, Tile.WINDOW, Tile.HEARTH -> {
                val out = mutableListOf<WorldArt.Obj>()
                // the walls at the back stand behind everything in the room: sorted a diagonal earlier
                val wd = if (tall(map, tx, ty)) d - T else d
                walls(map, tx, ty)?.let { img -> out += obj(cached("$key/wall") { img }, fx, fy, wd, !tall(map, tx, ty)) }
                // the fire burns in the hearth's fire box, in front of its middle, flickering through [FIRE_FRAMES] pictures
                if (map.tile(tx, ty) == Tile.HEARTH && at(-1, 0) != Tile.HEARTH && room(map, tx, ty + 1)) {
                    var w = 1; while (at(w, 0) == Tile.HEARTH) w++
                    val f = Math.floorMod(frame, FIRE_FRAMES)
                    val img = cached("${map.id}/fire/$f/$w") { fire(f, seed) }
                    // the mouth's middle lies on the face of the wall, w/2 tiles along it
                    out += obj(img, tx * T + w * T / 2, (ty + 1) * T, depth(tx + w - 1, ty) - T + 1)
                }
                out
            }
            Tile.DOOR -> if (ty == map.height - 1) one("door") { door(tx, ty) } else emptyList()
            Tile.SHELF -> one("shelf", low = false) { shelf(hash(tx, ty, 1) % 3, same(-1), same(1), seed) }
            Tile.COUNTER -> one("counter", low = false) { counter(hash(tx, ty, 2), same(-1), same(1), seed) }
            Tile.TABLE -> one("table") { table(v, same(-1), same(1), seed) }
            Tile.BENCH -> {
                // a settle beside a table: its back away from the table (13p.1)
                val back = when { at(0, -1) == Tile.TABLE -> 1; at(0, 1) == Tile.TABLE -> -1; else -> 0 }
                one("bench", low = back == 0) { bench(same(-1), same(1), seed, back) }
            }
            Tile.BED -> one("bed") { bed(hash(if (at(0, -1) == Tile.BED) tx else tx, if (at(0, -1) == Tile.BED) ty - 1 else ty, 4), at(0, -1) != Tile.BED, at(0, 1) != Tile.BED, seed) }
            Tile.CRATE -> one("crates") { crates(v, seed) }
            Tile.BARREL -> one("barrel") { barrel(v, seed) }
            Tile.CLUTTER -> {
                val byFire = (-1..1).any { dx -> (-1..0).any { dy -> at(dx, dy) == Tile.HEARTH } }
                val byTable = (-1..1).any { dx -> at(dx, 0) == Tile.TABLE }
                val kind = if (byFire) 0 else if (byTable) 3 else listOf(1, 2, 4, 5)[hash(tx, ty, 56) % 4]
                // low things: the hero stepping over them is drawn in front of them
                listOf(obj(cached("$key/clutter") { when (kind) {
                    0 -> firewood(v, seed)
                    1 -> sacks(v, seed)
                    2 -> basket(v, seed)
                    3 -> stool(v, seed)
                    4 -> bucket(v, seed)
                    else -> straw(v, seed)
                } }, fx, fy, d - T / 2, true))
            }
            Tile.PLANT -> one("plant") { plant(v, seed) }
            Tile.WOOD_FLOOR, Tile.RUG -> emptyList()
            else -> null
        }
    }

    /** Every look of every thing (preview ISODINGE=1): a row per kind, three looks each. */
    fun sheet(): List<Pair<String, List<PixelImage>>> = listOf(
        "Regal" to (0 until 3).map { shelf(it, false, false, 11 + it) },
        "Theke" to (0 until 3).map { counter(it, false, false, 21 + it) },
        "Tisch" to (0 until 3).map { table(it, false, false, 31 + it) },
        "Bank" to listOf(bench(false, false, 71, 1), bench(false, false, 72, -1), bench(false, false, 73, 0)),
        "Bett" to (0 until 3).map { bed(it, true, true, 41 + it) },
        "Kisten" to (0 until 3).map { crates(it, 51 + it) },
        "Brennholz" to (0 until 3).map { firewood(it, 61 + it) },
        "Fass" to (0 until 3).map { barrel(it, 81 + it) },
        "Hocker" to (0 until 3).map { stool(it, 91 + it) },
        "Eimer" to (0 until 3).map { bucket(it, 101 + it) },
        "Korb" to (0 until 3).map { basket(it, 111 + it) },
        "Säcke" to (0 until 3).map { sacks(it, 121 + it) },
        "Stroh" to (0 until 3).map { straw(it, 131 + it) },
        "Pflanze" to (0 until 3).map { plant(it, 141 + it) },
    )
}
