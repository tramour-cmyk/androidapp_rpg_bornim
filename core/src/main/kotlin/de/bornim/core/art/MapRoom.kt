package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.sqrt

/**
 * The rooms of Bornim in the new style (draft, night of 09.10.; only in the previews while
 * [MapGround.townDraft] is off in the game): the inn, the shop, the elder's house and the temple,
 * seen at a slant from above. Dark oak boards worn pale where feet go, the back wall a face of
 * smoke-stained plaster between beams, the other walls their thick dark tops, a doorway of light;
 * and the furniture as pictures of its own. At double resolution ([S] art pixels per tile).
 */
object MapRoom {
    private const val S = MapGround.S
    private const val D = MapGround.D
    private const val CH = MapGround.CH

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
    private fun ramp(vararg c: Int) = c.map { argb(it) }
    private fun pick(r: List<Int>, t: Double) = r[((1 - t.coerceIn(0.0, 1.0)) * (r.size - 0.01)).toInt().coerceIn(0, r.size - 1)]
    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }

    private val BOARD = ramp(0x6A5038, 0x56402C, 0x443222, 0x32241A, 0x22180F)
    private val PLASTER = ramp(0x8E8068, 0x766A56, 0x5E5444, 0x463E32)
    private val BEAM = ramp(0x4A382A, 0x362820, 0x241A14)
    private val STONE = ramp(0x7A746A, 0x5E5A52, 0x46423C, 0x2E2A26)
    private val RUG = ramp(0x7A3A2E, 0x5E2C24, 0x46201C)
    private val RUG_B = ramp(0x8A7650, 0x6A5A3C, 0x4E422C)
    private val CLOTH = ramp(0x7A7062, 0x5E564A, 0x463F36)
    private val IRON = argb(0x2A2826)
    private val FLAME = argb(0xF0C060)
    private val GOLD = ramp(0xA88A4A, 0x86703A, 0x5E4E2A)
    private val STRAW = ramp(0xB09A60, 0x8E7A48, 0x6A5A36)
    private val ASH = ramp(0x8A8480, 0x5E5A56, 0x34302C)
    private val OAK = BEAM.map { shade(it, 1.6) }
    private val FIRE = ramp(0xFFF0B0, 0xFFC860, 0xF08A30, 0xC04E1C, 0x6A2010)
    private val IRON_R = ramp(0x5A5650, 0x3A3632, 0x221F1C)

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.HEARTH)

    /** Things standing on the floor: the boards about them lie in their shade. */
    private val furniture = setOf(Tile.TABLE, Tile.BED, Tile.SHELF, Tile.COUNTER, Tile.BARREL, Tile.CRATE, Tile.BENCH, Tile.CLUTTER, Tile.PLANT, Tile.ALTAR)

    /** How tall the back wall's face stands, in art pixels, drawn on the row below its top. */
    private const val FACE = 40

    /** A chunk of a room's floor and walls. */
    fun ground(map: MapDef, cx: Int, cy: Int): PixelImage {
        val size = CH * S
        val ox = cx * size; val oy = cy * size
        val img = PixelImage(size, size)
        for (yy in 0 until size) for (xx in 0 until size) {
            val x = ox + xx; val y = oy + yy
            val tx = Math.floorDiv(x, S); val ty = Math.floorDiv(y, S)
            val t = if (map.inside(tx, ty)) map.tile(tx, ty) else Tile.WALL
            val lx = x - tx * S; val ly = y - ty * S
            var c: Int
            if (t == Tile.HEARTH) {
                c = hearthFace(map, tx, ty, x, y, lx, ly)
            } else if (t in wallTiles) {
                // the wall: the back wall shows its face on the floor row below it; all walls show a thick dark top
                val below = if (map.inside(tx, ty + 1)) map.tile(tx, ty + 1) else Tile.WALL
                c = if (below !in wallTiles && below != Tile.DOOR && ly >= S - FACE) {
                    // the face: plaster between beams, a stone footing, soot towards the top
                    val fy = ly - (S - FACE)
                    if (fy >= FACE - 7) pick(STONE, 0.5 + (rnd((x + fy / 4 * 3) / 6, fy / 4, 3) - 0.5) * 0.4 - (if ((x + fy / 4 * 3) % 6 == 0 || fy % 4 == 0) 0.3 else 0.0))
                    else if (lx < 4 || fy < 4 || fy in 18..20) pick(BEAM, 0.55 - (if (lx < 2) 0.3 else 0.0))
                    else pick(PLASTER, 0.5 + (vnoise(x.toDouble(), y.toDouble(), 6.0, 4) - 0.5) * 0.35 - (1 - fy / FACE.toDouble()) * 0.3)
                } else {
                    // the top of the wall: near black, a beam along its edge towards the room
                    fun open(dx: Int, dy: Int) = map.inside(tx + dx, ty + dy) && map.tile(tx + dx, ty + dy) !in wallTiles
                    val edge = (open(1, 0) && lx >= S - 5) || (open(-1, 0) && lx < 5) || (open(0, 1) && ly >= S - 5) || (open(0, -1) && ly < 5)
                    if (edge) pick(BEAM, 0.6 - (if (lx % 16 == 0 || ly % 16 == 0) 0.3 else 0.0)) else shade(argb(0x16120E), 0.9 + (vnoise(x.toDouble(), y.toDouble(), 12.0, 5) - 0.5) * 0.3)
                }
                if (t == Tile.WINDOW && ly >= S - FACE && ly < S - 14 && lx in 18..45) c = if (lx in 31..32 || ly == S - 27) BEAM[1] else argb(0x6A7078)
            } else if (t == Tile.DOOR) {
                // the doorway: the threshold and grey daylight falling in
                c = if (ly < 8) BEAM[2] else if (lx < 8 || lx >= S - 8) BEAM[1] else shade(argb(0x8A8270), 0.7 + ly / S.toDouble() * 0.3)
            } else {
                // oak boards running across, each its own shade, the joints dark, worn pale in the middle of the room
                val board = Math.floorDiv(y, 9)
                val shift = (rnd(board, 0, 6) * 80).toInt()
                val seg = Math.floorDiv(x + shift, 70 + (rnd(board, 1, 7) * 40).toInt())
                var tt = 0.45 + (rnd(board, seg, 8) - 0.5) * 0.3 + (vnoise(x * 0.15, y.toDouble(), 3.0, 9) - 0.5) * 0.25
                val mx = (x - map.width * S / 2.0) / (map.width * S / 2.0); val my = (y - map.height * S / 2.0) / (map.height * S / 2.0)
                tt += (1 - sqrt(mx * mx + my * my)).coerceAtLeast(0.0) * 0.15
                if (y % 9 == 0) tt -= 0.4
                if ((x + shift) % (70 + (rnd(board, 1, 7) * 40).toInt()) == 0) tt -= 0.35
                if (rnd(x / 3, y / 3, 10) < 0.01) tt -= 0.3
                // dark stains here and there: spilt beer, soot, the damp under the walls
                if (vnoise(x.toDouble(), y.toDouble(), 22.0, 33) > 0.74) tt -= 0.08
                val shadeK = wallShade(map, tx, ty, lx, ly)
                tt -= shadeK
                if (t in furniture) tt -= 0.18
                c = pick(BOARD, tt)
                // straw trodden in, more of it towards the walls
                val sx = Math.floorDiv(x, 7); val sy = Math.floorDiv(y, 7)
                if (rnd(sx, sy, 31) < 0.012 + shadeK * 0.08) {
                    val dx = Math.floorMod(x, 7); val dy = Math.floorMod(y, 7)
                    val on = if (rnd(sx, sy, 32) < 0.5) dx == dy else dx == 6 - dy
                    if (on && dx in 1..5) c = shade(pick(STRAW, 0.4 + rnd(sx, sy, 34) * 0.4), 0.7)
                }
                // the hearthstone before the fire: worn slabs, ash and a few embers
                if (map.inside(tx, ty - 1) && map.tile(tx, ty - 1) == Tile.HEARTH && ly < 20) {
                    val sh = if (ly < 10) 0 else 9
                    var st = 0.45 + (rnd(Math.floorDiv(x + sh, 18), ly / 10, 35) - 0.5) * 0.3 - (if (Math.floorMod(x + sh, 18) == 0 || ly == 10 || ly == 19) 0.35 else 0.0)
                    if (ly < 6) st -= 0.25
                    c = pick(STONE, st)
                    if (ly < 8 && rnd(x / 2, y / 2, 36) < 0.3) c = pick(ASH, rnd(x, y, 37))
                    if (ly < 5 && rnd(x, y, 38) < 0.04) c = argb(0xD86A28)
                }
                if (t == Tile.RUG) {
                    // a woven rug: a red field, a pale border, the pattern of lozenges, fringes at the ends
                    fun rug(dx: Int, dy: Int) = map.inside(tx + dx, ty + dy) && map.tile(tx + dx, ty + dy) == Tile.RUG
                    val edgeL = !rug(-1, 0) && lx < 6; val edgeR = !rug(1, 0) && lx >= S - 6
                    val edgeT = !rug(0, -1) && ly < 6; val edgeB = !rug(0, 1) && ly >= S - 6
                    val border = (!rug(-1, 0) && lx < 12) || (!rug(1, 0) && lx >= S - 12) || (!rug(0, -1) && ly < 12) || (!rug(0, 1) && ly >= S - 12)
                    c = if (edgeL || edgeR) (if (y % 3 == 0) RUG_B[1] else c) else if (edgeT || edgeB) RUG_B[2]
                        else if (border) pick(RUG_B, 0.5 + (rnd(x / 2, y / 2, 11) - 0.5) * 0.3)
                        else { val d = (abs((lx + 16) % 32 - 16) + abs((ly + 16) % 32 - 16)); pick(RUG, if (d in 9..11) 1.0 else 0.5 + (rnd(x / 2, y / 2, 12) - 0.5) * 0.3) }
                }
            }
            put(img, xx, yy, c)
        }
        return img
    }

    /** How much the boards at ([lx], [ly]) of tile ([tx], [ty]) lie in the shade of the walls about them. */
    private fun wallShade(map: MapDef, tx: Int, ty: Int, lx: Int, ly: Int): Double {
        fun wall(dx: Int, dy: Int) = !map.inside(tx + dx, ty + dy) || map.tile(tx + dx, ty + dy) in wallTiles
        var k = 0.0
        if (wall(-1, 0)) k = maxOf(k, (1 - lx / 16.0).coerceAtLeast(0.0) * 0.3)
        if (wall(1, 0)) k = maxOf(k, (1 - (S - 1 - lx) / 16.0).coerceAtLeast(0.0) * 0.3)
        if (wall(0, -1)) k = maxOf(k, (1 - ly / 22.0).coerceAtLeast(0.0) * 0.38)
        if (wall(0, 1)) k = maxOf(k, (1 - (S - 1 - ly) / 10.0).coerceAtLeast(0.0) * 0.2)
        return k
    }

    /**
     * The fireplace in the back wall: a breast of rough stones from the floor to the beams, black
     * with soot above the mouth, and the mouth itself, an arch of dark soot where the fire burns
     * (the fire is a picture of its own, [fire]).
     */
    private fun hearthFace(map: MapDef, tx: Int, ty: Int, x: Int, y: Int, lx: Int, ly: Int): Int {
        val hl = map.tile(tx - 1, ty) == Tile.HEARTH; val hr = map.tile(tx + 1, ty) == Tile.HEARTH
        val left = if (hl) tx - 1 else tx
        val hw = (if (hl || hr) 2 else 1) * S
        val hx = x - left * S
        // the mouth: an arch in the lower part of the breast
        val mcx = hw / 2.0; val mw = hw * 0.32
        val dx = (hx - mcx) / mw
        val top = S - 34 + 9 * dx * dx
        if (abs(dx) < 1 && ly >= top) {
            val depth = (ly - top) / (S - top)
            return shade(argb(0x1A120C), 0.6 + depth * 0.8 + (rnd(x / 2, y / 2, 39) - 0.5) * 0.2)
        }
        // the stones: courses of 9 pixels, each stone its own shade; the edge of the breast and the arch darker
        val course = Math.floorDiv(y, 9); val off = (rnd(course, 0, 21) * 20).toInt()
        val bx = Math.floorDiv(x + off, 15 + (rnd(course, 1, 23) * 6).toInt())
        var tt = 0.5 + (rnd(bx, course, 22) - 0.5) * 0.4
        if (Math.floorMod(y, 9) == 0 || Math.floorMod(x + off, 15 + (rnd(course, 1, 23) * 6).toInt()) == 0) tt -= 0.35
        if (hx < 3 || hx >= hw - 3) tt -= 0.3
        if (abs(dx) < 1.15 && ly >= top - 3) tt -= 0.25
        // soot rising from the mouth, widening upwards
        val soot = (1 - abs(hx - mcx) / (mw + (S - ly) * 0.4)).coerceAtLeast(0.0) * (1 - ly / S.toDouble()).coerceAtLeast(0.0)
        tt -= soot * 0.5
        // the breast stands out of the wall: lit a little at its left, shadowed at its right
        tt += (0.5 - hx / hw.toDouble()) * 0.12
        return pick(STONE, tt)
    }

    // ------------------------------------------------------------------ furniture

    class Sprite(val img: PixelImage, val ax: Int, val ay: Int)
    private val cache = HashMap<String, Sprite>()
    private fun cached(key: String, make: () -> Sprite): Sprite = synchronized(cache) { cache[key] } ?: make().also { synchronized(cache) { cache[key] = it } }

    private fun rect(img: PixelImage, x0: Int, y0: Int, x1: Int, y1: Int, c: (Int, Int) -> Int) { for (y in y0 until y1) for (x in x0 until x1) put(img, x, y, c(x, y)) }
    private fun blob(img: PixelImage, cx: Double, cy: Double, rx: Double, ry: Double, paint: (Double, Double) -> Int) {
        for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
            val nx = (x - cx) / rx; val ny = (y - cy) / ry; if (nx * nx + ny * ny > 1) continue
            put(img, x, y, paint(nx, ny))
        }
    }
    private fun line(img: PixelImage, x0: Double, y0: Double, x1: Double, y1: Double, c: Int) {
        val n = maxOf(abs(x1 - x0), abs(y1 - y0)).toInt() + 1
        for (i in 0..n) { val t = i / n.toDouble(); put(img, (x0 + (x1 - x0) * t).toInt(), (y0 + (y1 - y0) * t).toInt(), c) }
    }
    /** A soft shadow on the floor under a thing, part of its picture. */
    private fun floorShadow(img: PixelImage, cx: Double, cy: Double, rx: Double, ry: Double, a: Int = 0x60) {
        for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
            val nx = (x - cx) / rx; val ny = (y - cy) / ry; val d = nx * nx + ny * ny
            if (d > 1 || img[x, y] ushr 24 != 0) continue
            put(img, x, y, ((a * (1 - d)).toInt().coerceIn(0, 255) shl 24) or 0x0A0806)
        }
    }
    private fun candle(img: PixelImage, x: Int, y: Int, tall: Int = 6) {
        rect(img, x - 1, y - 1, x + 4, y + 1) { _, _ -> IRON_R[1] }
        rect(img, x, y - tall, x + 3, y - 1) { xx, _ -> if (xx == x) argb(0xD8CCB0) else argb(0xB8AC90) }
        put(img, x + 1, y - tall - 1, FIRE[1]); put(img, x + 1, y - tall - 2, FIRE[0])
    }
    private fun mug(img: PixelImage, x: Int, y: Int) {
        rect(img, x, y - 7, x + 5, y) { xx, yy -> if (yy == y - 7) argb(0x2A1E14) else if (xx == x) argb(0x9A8E78) else argb(0x7A6E5A) }
        put(img, x + 5, y - 5, argb(0x6A5E4A)); put(img, x + 6, y - 4, argb(0x6A5E4A)); put(img, x + 5, y - 3, argb(0x6A5E4A))
    }
    private fun bowl(img: PixelImage, x: Double, y: Double) =
        blob(img, x, y, 6.5, 3.5) { nx, ny -> if (nx * nx + ny * ny < 0.35 && ny < 0.3) argb(0x4A3420) else shade(argb(0x8A6E50), 1.1 - ny * 0.4 - nx * 0.1) }
    private fun bread(img: PixelImage, x: Double, y: Double) =
        blob(img, x, y, 5.5, 3.0) { nx, ny -> shade(argb(0xA07A44), 1.15 - nx * 0.2 - ny * 0.35) }
    private fun jug(img: PixelImage, x: Int, y: Int) {
        blob(img, x + 4.0, y - 5.0, 4.5, 5.0) { nx, ny -> shade(argb(0x8A5A38), 1.15 - nx * 0.35 - ny * 0.15) }
        rect(img, x + 2, y - 12, x + 6, y - 9) { xx, _ -> if (xx == x + 2) argb(0x9A6A44) else argb(0x7A4A2E) }
    }

    /** A tall shelf against the wall: four boards of jars, bottles, crocks and bundles, taller than a man. */
    fun shelf(v: Int): Sprite = cached("shelf/$v") {
        val w = S - 4; val h = 116; val img = PixelImage(w, h)
        rect(img, 0, 4, w, h - 2) { x, _ -> if (x < 4 || x >= w - 4) BEAM[1] else BEAM[2] }
        rect(img, 0, 2, w, 6) { _, y -> if (y == 2) BEAM[0] else BEAM[1] }
        for (k in 0 until 4) {
            val by = 28 + k * 22
            rect(img, 2, by, w - 2, by + 4) { _, y -> if (y == by) BEAM[0] else BEAM[1] }
            var x = 6
            var i = 0
            while (x < w - 10) {
                val kind = hash(i, k, v) % 5
                val iw = 5 + hash(i, k, v + 1) % 7; val ih = 7 + hash(i, k, v + 2) % 10
                val col = listOf(0x4A3A2E, 0x2E3A3A, 0x5A2A22, 0x6A6048, 0x3A4A2A)[hash(i, k, v + 3) % 5]
                when (kind) {
                    0 -> rect(img, x, by - ih, x + iw, by) { xx, _ -> shade(argb(col), if (xx == x) 1.3 else 1.0) }
                    1 -> { rect(img, x + 1, by - ih, x + iw - 1, by) { xx, _ -> shade(argb(0x3A4A46), if (xx == x + 1) 1.6 else 1.0) }; put(img, x + 2, by - ih + 2, argb(0xA8B0A8)) }
                    2 -> blob(img, x + iw / 2.0, by - ih / 2.0, iw / 2.0, ih / 2.0) { nx, ny -> shade(argb(0x7A5A3A), 1.1 - nx * 0.2 - ny * 0.3) }
                    3 -> { blob(img, x + iw / 2.0, by - 4.0, iw / 2.0 + 1, 4.0) { nx, ny -> shade(argb(0x6A5A40), 1.1 - nx * 0.3 - ny * 0.2) } }
                    else -> rect(img, x, by - ih, x + 3, by) { _, _ -> argb(col) }
                }
                x += iw + 2 + hash(i, k, v + 4) % 3; i++
            }
        }
        Sprite(img, w / 2, h - 4)
    }

    /** A bed of one tile, as drawn before (rooms whose beds stand side by side). */
    fun bed(v: Int = 0): Sprite = cached("bed/$v") {
        val w = S - 6; val h = 80; val img = PixelImage(w, h)
        val blanket = blankets[v % 3]
        rect(img, 2, 2, w - 2, 14) { x, y -> if (y < 4) BEAM[0] else pick(BEAM, 0.5 - (if (x % 9 == 0) 0.3 else 0.0)) }
        rect(img, 2, 14, w - 2, h - 6) { x, _ -> if (x < 5 || x >= w - 5) BEAM[1] else argb(0x8A7A58) }
        rect(img, 2, h - 12, w - 2, h - 6) { _, y -> if (y == h - 12) BEAM[0] else BEAM[2] }
        blob(img, w / 2.0, 21.0, w / 2.0 - 9, 5.5) { nx, ny -> shade(argb(0xB8AC90), 1.05 - nx * 0.1 - ny * 0.25) }
        rect(img, 6, 30, w - 6, h - 13) { x, y -> pick(blanket, 0.6 - (x - 6) / w.toDouble() * 0.3 + (vnoise(x.toDouble(), y * 0.5, 5.0, 13 + v) - 0.5) * 0.5) }
        rect(img, 6, 30, w - 6, 33) { _, _ -> shade(blanket[0], 1.15) }
        Sprite(img, w / 2, h - 4)
    }
    private val blankets = listOf(ramp(0x6A3A30, 0x542E26, 0x3E221C), ramp(0x4A5260, 0x3A404C, 0x2A2E38), CLOTH)
    /** Blankets for the long beds: madder red, undyed wool, a faded green. */
    private val woolens = listOf(ramp(0x8A4A38, 0x6E3A2C, 0x502A20), ramp(0x8E7E68, 0x706250, 0x524838), ramp(0x5E6A4A, 0x4A5438, 0x363E2A))

    /**
     * A bed two tiles long, its head against the wall: a plank frame with corner posts, a straw
     * mattress, a bolster, a rough blanket thrown back in folds, and a fur at its foot.
     */
    fun longBed(v: Int): Sprite = cached("longbed/$v") {
        val w = S - 8; val h = S + 76; val img = PixelImage(w, h)
        val blanket = woolens[v % 3]
        floorShadow(img, w / 2.0, h - 6.0, w / 2.0 + 2, 6.0)
        // the headboard and its posts
        rect(img, 1, 0, w - 1, 20) { x, y -> if (x < 5 || x >= w - 5) (if (x == 1 || x == w - 5) BEAM[0] else BEAM[1]) else if (y < 3) BEAM[0] else pick(BEAM, 0.5 - (if ((x - 5) % 9 == 0) 0.3 else 0.0)) }
        // the frame and the straw mattress
        rect(img, 1, 20, w - 1, h - 14) { x, y -> if (x < 5 || x >= w - 5) BEAM[1] else pick(STRAW, 0.45 + (rnd(x / 2, y / 3, 40 + v) - 0.5) * 0.3) }
        // the bolster: pale linen, a crease where the head lay
        blob(img, w / 2.0, 28.0, w / 2.0 - 8, 6.5) { nx, ny -> shade(argb(0xC4B89C), 1.06 - nx * 0.14 - ny * 0.22 - (if (abs(nx) < 0.25 && ny > -0.2) 0.1 else 0.0)) }
        // the blanket: wool, falling over the sides of the frame, broad soft folds, lit from the left
        for (y in 38 until h - 16) for (x in 3 until w - 3) {
            val side = (if (x < 8) (8 - x) / 5.0 else if (x >= w - 8) (x - (w - 9)) / 5.0 else 0.0)
            var t = 0.62 - (x - 3) / w.toDouble() * 0.22 - side * 0.35
            t += kotlin.math.sin(y * 0.11 + x * 0.06 + v * 2) * 0.09 + kotlin.math.sin(y * 0.23 - x * 0.09) * 0.05
            if ((x + y) % 2 == 0) t += 0.04
            put(img, x, y, pick(blanket, t))
        }
        // turned back at the top, the linen sheet showing beneath
        rect(img, 6, 36, w - 6, 40) { x, _ -> shade(argb(0xB8AC90), 1.0 - (x - 6) / w.toDouble() * 0.2) }
        rect(img, 4, 40, w - 4, 44) { x, y -> pick(blanket, (if (y == 40) 0.9 else 0.5) - (x - 4) / w.toDouble() * 0.2) }
        // a second blanket folded at the foot
        rect(img, 5, h - 32, w - 5, h - 18) { x, y -> pick(woolens[(v + 1) % 3], 0.6 - (x - 5) / w.toDouble() * 0.25 - (if (y == h - 32) -0.2 else 0.0) - (if (y == h - 25) 0.3 else 0.0) - (if (y >= h - 20) 0.15 else 0.0)) }
        // the foot board
        rect(img, 1, h - 14, w - 1, h - 4) { x, y -> if (y == h - 14) BEAM[0] else if (x < 5 || x >= w - 5) BEAM[1] else BEAM[2] }
        Sprite(img, w / 2, h - 4)
    }

    /** One tile of the counter, joined to the next ([l], [r]): a heavy top, a front of upright planks, waist high. */
    fun counter(l: Boolean, r: Boolean, v: Int): Sprite = cached("counter/$l/$r/$v") {
        val w = S; val h = 84; val img = PixelImage(w, h)
        val x0 = if (l) 0 else 3; val x1 = if (r) w else w - 3
        floorShadow(img, w / 2.0, h - 6.0, w / 2.0 + 4, 5.0)
        rect(img, x0, 16, x1, 30) { x, y -> pick(OAK, 0.6 - (y - 16) * 0.03 + (rnd(x / 7, y / 5, 14) - 0.5) * 0.2 + (if ((y - 16) % 5 == 0) -0.2 else 0.0)) }
        rect(img, x0, 30, x1, 33) { _, y -> if (y == 30) BEAM[0] else BEAM[2] }
        rect(img, x0, 33, x1, h - 4) { x, y -> if ((x - x0) % 11 == 0) BEAM[2] else pick(BEAM, 0.55 - (y - 33) * 0.004 + (rnd((x - x0) / 11, 0, 42) - 0.5) * 0.2) }
        rect(img, x0, h - 9, x1, h - 4) { _, _ -> BEAM[2] }
        when (v % 4) {
            0 -> { mug(img, 14, 26); mug(img, 22, 27); jug(img, 40, 27) }
            1 -> { candle(img, 12, 26, 8); bowl(img, 36.0, 23.0) }
            2 -> { rect(img, 10, 18, 30, 27) { x, y -> if (y == 18 || x == 10) argb(0xB8AC90) else argb(0x9A8E74) }; line(img, 13.0, 21.0, 27.0, 21.0, argb(0x5A4E3E)); line(img, 13.0, 24.0, 24.0, 24.0, argb(0x5A4E3E)); mug(img, 40, 27) }
            else -> { jug(img, 12, 27); bread(img, 38.0, 24.0) }
        }
        Sprite(img, w / 2, h - 4)
    }

    /** One tile of a long trestle table, joined to the next ([l], [r]), hip high: plates, mugs, a candle. */
    fun table(l: Boolean, r: Boolean, v: Int): Sprite = cached("table/$l/$r/$v") {
        val w = S; val h = 76; val img = PixelImage(w, h)
        val x0 = if (l) 0 else 4; val x1 = if (r) w else w - 4
        // the table's shadow on the floor between the legs
        rect(img, x0 + 2, h - 10, x1 - 2, h - 3) { _, y -> ((0x58 - (y - (h - 10)) * 6) shl 24) or 0x0A0806 }
        // the top seen from above, boards running along
        rect(img, x0, 6, x1, 32) { x, y -> pick(OAK, 0.58 - (y - 6) * 0.01 + (if ((y - 6) % 8 == 0) -0.35 else 0.0) + (rnd((x + (y - 6) / 8 * 17) / 23, (y - 6) / 8, 15 + v) - 0.5) * 0.22) }
        rect(img, x0, 32, x1, 37) { _, y -> if (y == 32) BEAM[0] else BEAM[2] }
        // legs at the outer ends, a trestle in the middle of a long table
        val legs = buildList { if (!l) add(x0 + 3); if (!r) add(x1 - 8); if (l && r && v % 2 == 0) add(w / 2 - 2) }
        for (lx in legs) rect(img, lx, 37, lx + 5, h - 4) { xx, _ -> if (xx == lx) BEAM[0] else BEAM[1] }
        if (!l || !r) rect(img, x0 + 4, h - 22, x1 - 4, h - 19) { _, _ -> BEAM[2] }
        when (v % 4) {
            0 -> { candle(img, 10, 22, 7); bowl(img, 36.0, 18.0); bread(img, 26.0, 27.0) }
            1 -> { mug(img, 12, 26); mug(img, 20, 20); bowl(img, 42.0, 24.0) }
            2 -> { jug(img, 14, 26); bread(img, 34.0, 15.0); bowl(img, 44.0, 25.0) }
            else -> { candle(img, 40, 20, 5); mug(img, 16, 24) }
        }
        Sprite(img, w / 2, h - 4)
    }

    /** One tile of a plank bench, joined to the next ([l], [r]), knee high. */
    fun bench(l: Boolean, r: Boolean): Sprite = cached("bench/$l/$r") {
        val w = S; val h = 36; val img = PixelImage(w, h)
        val x0 = if (l) 0 else 5; val x1 = if (r) w else w - 5
        rect(img, x0 + 2, h - 8, x1 - 2, h - 3) { _, y -> ((0x50 - (y - (h - 8)) * 8) shl 24) or 0x0A0806 }
        rect(img, x0, 8, x1, 16) { x, y -> pick(OAK, 0.55 - (y - 8) * 0.02 + (rnd(x / 13, 0, 43) - 0.5) * 0.2) }
        rect(img, x0, 16, x1, 19) { _, y -> if (y == 16) BEAM[0] else BEAM[2] }
        for (lx in buildList { if (!l) add(x0 + 3); if (!r) add(x1 - 7) }) rect(img, lx, 19, lx + 4, h - 4) { xx, _ -> if (xx == lx) BEAM[0] else BEAM[1] }
        Sprite(img, w / 2, h - 4)
    }

    /** An oak barrel, waist high, staves and three iron hoops, a tap at the front. */
    fun barrel(v: Int): Sprite = cached("barrel/$v") {
        val w = 40; val h = 58; val img = PixelImage(w, h)
        floorShadow(img, w / 2.0, h - 6.0, w / 2.0, 5.0)
        for (y in 8 until h - 4) for (x in 2 until w - 2) {
            val nx = (x - w / 2.0) / (w / 2.0 - 2); val bulge = 1 - 0.14 * ((y - h / 2.0) / (h / 2.0)).let { it * it }
            if (abs(nx) > bulge) continue
            var t = 0.6 - nx * 0.35 + (rnd(x / 5, v, 44) - 0.5) * 0.2
            if (x % 5 == 0) t -= 0.25
            var c = pick(BEAM.map { shade(it, 1.35) }, t)
            if (y in 13..15 || y in h / 2 - 1..h / 2 + 1 || y in h - 13..h - 11) c = shade(IRON_R[1], 1.3 - nx * 0.4)
            put(img, x, y, c)
        }
        blob(img, w / 2.0, 9.0, w / 2.0 - 3, 5.0) { nx, ny -> if (nx * nx + ny * ny > 0.75) BEAM[2] else pick(OAK, 0.5 - nx * 0.2 + (if (((nx + 1) * 6).toInt() % 3 == 0) -0.2 else 0.0)) }
        if (v % 2 == 0) { rect(img, w / 2 - 2, h / 2 + 4, w / 2 + 2, h / 2 + 8) { _, _ -> IRON_R[0] }; put(img, w / 2, h / 2 + 9, IRON_R[1]) }
        else mug(img, w / 2 + 3, 10)
        Sprite(img, w / 2, h - 5)
    }

    /** Two crates stacked askew, a sack slumped against them. */
    fun crates(v: Int): Sprite = cached("crates/$v") {
        val w = S - 4; val h = 70; val img = PixelImage(w, h)
        floorShadow(img, w / 2.0, h - 6.0, w / 2.0, 5.0)
        fun crate(x0: Int, y0: Int, cw: Int, ch: Int, k: Double) {
            val top = ch / 3
            rect(img, x0, y0, x0 + cw, y0 + top) { x, y -> pick(OAK.map { shade(it, k) }, 0.55 + (if ((y - y0) % 5 == 0) -0.3 else 0.0) + (rnd(x / 6, y / 5, 45) - 0.5) * 0.15) }
            rect(img, x0, y0 + top, x0 + cw, y0 + ch) { x, y -> if (x == x0 || x == x0 + cw - 1 || y == y0 + top || y == y0 + ch - 1) BEAM[2] else if ((y - y0 - top) % 7 == 0) BEAM[2] else pick(BEAM.map { shade(it, k * 1.3) }, 0.55 - (x - x0) * 0.008) }
            line(img, x0 + 1.0, y0 + top + 1.0, x0 + cw - 2.0, y0 + ch - 2.0, BEAM[2])
        }
        crate(4, 26, 38, 40, 1.0)
        crate(10 + v % 3 * 2, 2, 30, 30, 1.1)
        blob(img, w - 12.0, h - 18.0, 9.0, 13.0) { nx, ny -> shade(argb(0x8A7A5A), 1.12 - nx * 0.25 - ny * 0.2 + (if (abs(nx + ny * 0.3) < 0.08) -0.2 else 0.0)) }
        Sprite(img, w / 2, h - 5)
    }

    /**
     * Odds and ends on the floor that one steps over: firewood by the hearth, else sacks of
     * grain, a basket of turnips, a stool, a bucket, a heap of straw. Low, so they hide no one.
     */
    fun clutter(kind: Int, v: Int): Sprite = cached("clutter/$kind/$v") {
        val w = S; val h = 44; val img = PixelImage(w, h)
        val base = h - 6
        when (kind) {
            0 -> {
                // firewood: split logs stacked, their cut ends towards us, an axe leaning
                floorShadow(img, 30.0, base.toDouble(), 26.0, 5.0)
                for (row in 0 until 3) for (k in 0 until 4 - row) {
                    val cx = 12.0 + k * 11 + row * 5.5; val cy = base - 5.0 - row * 9
                    blob(img, cx, cy, 5.5, 5.0) { nx, ny -> val d = nx * nx + ny * ny
                        if (d > 0.6) shade(argb(0x4A3624), 1.0 - ny * 0.2) else pick(listOf(argb(0xB89A6A), argb(0x9A7E54), argb(0x7A6040)), 0.6 - d * 0.6 + (if (abs(d - 0.25) < 0.05) -0.3 else 0.0)) }
                }
                line(img, 52.0, base.toDouble(), 58.0, base - 26.0, BEAM[0]); rect(img, 54, base - 30, 61, base - 25) { x, _ -> if (x == 54) IRON_R[0] else IRON_R[1] }
            }
            1 -> {
                // sacks of grain, one tipped over
                floorShadow(img, 32.0, base.toDouble(), 26.0, 5.0)
                blob(img, 22.0, base - 13.0, 12.0, 14.0) { nx, ny -> shade(argb(0x8E7E5C), 1.15 - nx * 0.3 - ny * 0.15 + (if (abs(nx * 0.5 + ny) < 0.06) -0.18 else 0.0)) }
                rect(img, 19, base - 30, 25, base - 25) { x, _ -> if (x == 19) argb(0x9E8E6A) else argb(0x6E5E44) }
                blob(img, 42.0, base - 7.0, 13.0, 8.0) { nx, ny -> shade(argb(0x847454), 1.12 - nx * 0.2 - ny * 0.3) }
                for (k in 0 until 6) put(img, 54 + hash(k, v, 46) % 6, base - 2 - hash(k, v, 47) % 3, STRAW[0])
            }
            2 -> {
                // a wicker basket of turnips
                floorShadow(img, 30.0, base.toDouble(), 18.0, 4.0)
                for (k in 0 until 6) blob(img, 22.0 + (k % 3) * 7, base - 18.0 + (k / 3) * 3, 4.0, 3.5) { nx, ny -> if (ny < -0.6 && abs(nx) < 0.3) argb(0x4E6A36) else shade(argb(0xC8B8C0), 1.05 - nx * 0.2 - ny * 0.3).let { if (ny > 0.2) shade(argb(0x8A5A8A), 1.0) else it } }
                rect(img, 15, base - 15, 45, base) { x, y -> pick(STRAW, 0.6 - (x - 15) * 0.012 + (if ((x + (y / 3) * 2) % 4 == 0) -0.35 else 0.0) + (if ((y - (base - 15)) % 3 == 0) -0.15 else 0.0)) }
                rect(img, 15, base - 15, 45, base - 13) { _, _ -> STRAW[1] }
            }
            3 -> {
                // a three-legged stool
                floorShadow(img, 32.0, base.toDouble(), 14.0, 4.0)
                for (lx in listOf(23, 39)) line(img, lx + 2.0, base - 16.0, lx.toDouble(), base.toDouble(), BEAM[1])
                line(img, 31.0, base - 16.0, 32.0, base - 2.0, BEAM[2])
                blob(img, 32.0, base - 19.0, 12.0, 4.5) { nx, ny -> pick(OAK, 0.6 - nx * 0.2 - ny * 0.2) }
                rect(img, 20, base - 19, 45, base - 16) { _, y -> if (y == base - 19) BEAM[0] else BEAM[2] }
                blob(img, 32.0, base - 19.0, 12.0, 4.5) { nx, ny -> pick(OAK, 0.62 - nx * 0.2 - ny * 0.15) }
            }
            4 -> {
                // a wooden bucket with a rope handle, a ladle in it
                floorShadow(img, 30.0, base.toDouble(), 14.0, 4.0)
                rect(img, 21, base - 20, 40, base) { x, y -> val nx = (x - 30.5) / 9.5
                    if (y in base - 16..base - 15 || y in base - 6..base - 5) shade(IRON_R[1], 1.3 - nx * 0.4) else pick(BEAM.map { shade(it, 1.3) }, 0.6 - nx * 0.35 + (if (x % 4 == 0) -0.2 else 0.0)) }
                blob(img, 30.5, base - 20.0, 9.5, 3.0) { nx, ny -> if (nx * nx + ny * ny < 0.6) argb(0x2A3436) else BEAM[0] }
                line(img, 21.0, base - 20.0, 30.0, base - 31.0, argb(0x7A6A4A)); line(img, 30.0, base - 31.0, 40.0, base - 20.0, argb(0x7A6A4A))
                line(img, 33.0, base - 21.0, 41.0, base - 33.0, BEAM[0])
            }
            else -> {
                // a heap of straw, a pitchfork lying across
                floorShadow(img, 32.0, base.toDouble(), 26.0, 5.0)
                for (y in base - 16 until base) for (x in 6 until 58) {
                    val nx = (x - 32) / 26.0; val ny = (y - (base - 2)) / 14.0
                    if (nx * nx + ny * ny > 1 + (rnd(x, 0, 48) - 0.5) * 0.3) continue
                    put(img, x, y, pick(STRAW, 0.55 - ny * 0.3 + (if ((x * 3 + y) % 5 == 0) -0.3 else 0.0) + (rnd(x, y, 49) - 0.5) * 0.3))
                }
                line(img, 4.0, base - 3.0, 52.0, base - 13.0, BEAM[0])
                for (k in 0 until 3) line(img, 52.0, base - 13.0 + k * 2 - 2, 60.0, base - 15.0 + k * 2 - 2, IRON_R[0])
            }
        }
        Sprite(img, w / 2, base)
    }

    /** A clay pot of dark herbs. */
    fun plant(): Sprite = cached("plant") {
        val w = 34; val h = 50; val img = PixelImage(w, h)
        for (k in 0 until 14) {
            val a = -1.4 + k * 0.2; val len = 14 + rnd(k, 0, 16) * 10
            for (i in 0 until len.toInt()) put(img, (17 + kotlin.math.sin(a) * i * 0.8).toInt(), (30 - kotlin.math.cos(a) * i).toInt(), if (i > len - 4) argb(0x4E6A36) else argb(0x2E4022))
        }
        rect(img, 9, 30, 25, h - 4) { x, y -> shade(argb(0x7A4A30), 1.15 - (x - 9) * 0.03 - (if (y == 30) -0.2 else 0.0)) }
        Sprite(img, w / 2, h - 4)
    }

    /** One tile of the altar: a block of pale stone under a cloth, candles, and on the middle the sun of the dawnlight. */
    fun altar(l: Boolean, r: Boolean): Sprite = cached("altar/$l/$r") {
        val w = S; val h = 72; val img = PixelImage(w, h)
        val x0 = if (l) 0 else 4; val x1 = if (r) w else w - 4
        rect(img, x0, 28, x1, h - 4) { x, y -> pick(STONE.map { shade(it, 1.25) }, 0.55 - (y - 28) * 0.01 + (rnd(x / 6, y / 5, 17) - 0.5) * 0.25 - (if ((y - 28) % 10 == 0) 0.3 else 0.0)) }
        rect(img, x0, 24, x1, 34) { _, y -> if (y < 26) argb(0xC8BCA0) else argb(0xA89C82) }
        candle(img, if (l) 40 else 12, 24)
        candle(img, if (l) 50 else 22, 24)
        if (!l) {
            val cx = (x1 - 6).toDouble(); val cy = 14.0
            for (k in 0 until 8) { val a = k * Math.PI / 4; for (i in 7..11) put(img, (cx + kotlin.math.cos(a) * i).toInt(), (cy + kotlin.math.sin(a) * i).toInt(), GOLD[1]) }
            blob(img, cx, cy, 6.0, 6.0) { nx, ny -> pick(GOLD, 0.7 - nx * 0.3 - ny * 0.3) }
        }
        Sprite(img, w / 2, h - 4)
    }

    /**
     * The fire in the hearth's mouth, [frame] 0 or 1: two logs on the irons, embers, tongues of
     * flame, and a sooty kettle hanging on its chain over them.
     */
    fun fire(frame: Int, width: Int): Sprite = cached("fire/$frame/$width") {
        val w = width; val h = 46; val img = PixelImage(w, h)
        val cx = w / 2.0; val base = h - 3
        // the glow on the back of the mouth
        for (y in 0 until base) for (x in 0 until w) {
            val nx = (x - cx) / (w * 0.5); val ny = (base - y) / 34.0
            val d = nx * nx + ny * ny
            if (d < 1) put(img, x, y, ((0x90 * (1 - d) * (1 - d)).toInt() shl 24) or 0xC0501C)
        }
        // embers and the logs
        for (x in (cx - 22).toInt()..(cx + 22).toInt()) for (y in base - 3..base) put(img, x, y, if (rnd(x, y + frame, 50) < 0.35) FIRE[2] else FIRE[4])
        line(img, cx - 20, base - 3.0, cx + 14, base - 7.0, argb(0x2A1C12)); line(img, cx - 20, base - 4.0, cx + 14, base - 8.0, argb(0x3A2818))
        line(img, cx - 12, base - 8.0, cx + 20, base - 3.0, argb(0x3A2818)); line(img, cx - 12, base - 9.0, cx + 20, base - 4.0, argb(0x4A3220))
        // the flames: tongues of different height, their tips swaying between the two pictures
        for (x in (cx - 20).toInt()..(cx + 20).toInt()) {
            val k = (x - cx) / 20.0
            val tongue = 0.5 + 0.5 * kotlin.math.sin(x * 0.55 + frame * 2.1) * kotlin.math.cos(x * 0.21 - frame * 1.3)
            val hgt = (6 + 16 * (1 - k * k) * (0.45 + 0.55 * tongue)).toInt()
            for (i in 0 until hgt) {
                val t = i / hgt.toDouble()
                val c = when { t < 0.25 -> FIRE[0]; t < 0.5 -> FIRE[1]; t < 0.78 -> FIRE[2]; else -> FIRE[3] }
                put(img, x + (if (t > 0.6) (frame * 2 - 1) * ((t - 0.6) * 4).toInt() else 0), base - 6 - i, c)
            }
        }
        // the kettle on its chain
        for (y in 0 until 14) put(img, cx.toInt() + (if (y % 2 == 0) 0 else 1), y, IRON_R[1])
        blob(img, cx, 20.0, 10.0, 8.0) { nx, ny -> if (ny < -0.6) IRON_R[0] else shade(IRON_R[1], 1.1 - nx * 0.4 - ny * 0.2 + (if (ny > 0.4) 0.25 else 0.0)) }
        rect(img, cx.toInt() - 10, 13, cx.toInt() + 11, 15) { _, _ -> IRON_R[2] }
        Sprite(img, w / 2, base)
    }

    /**
     * What hangs on a stretch of back wall ([v]): bunches of herbs drying from a peg rail, a cloak
     * and a bag on pegs, a pan and a ladle, a small board of crocks, a pair of antlers; or nothing.
     */
    fun wallThing(v: Int): Sprite? {
        if (v >= 5) return null
        return cached("wall/$v") {
            val w = S; val h = 36; val img = PixelImage(w, h)
            when (v) {
                0 -> {
                    rect(img, 6, 2, w - 6, 5) { _, y -> if (y == 2) BEAM[0] else BEAM[1] }
                    for (k in 0 until 4) {
                        val x = 12 + k * 12 + hash(k, v, 51) % 4; val len = 12 + hash(k, v, 52) % 8
                        line(img, x.toDouble(), 5.0, x.toDouble(), 9.0, argb(0x7A6A4A))
                        for (i in 0 until len) for (dx in -(i / 3).coerceAtMost(4)..(i / 3).coerceAtMost(4))
                            if (rnd(x + dx, i, 53) < 0.7) put(img, x + dx, 9 + i, pick(listOf(argb(0x6A7A4A), argb(0x4E5A36), argb(0x6A5A3A)), 0.5 + (rnd(x + dx, i, 54) - 0.5) * 0.9))
                    }
                }
                1 -> {
                    rect(img, 8, 3, w - 8, 6) { _, y -> if (y == 3) BEAM[0] else BEAM[1] }
                    // a cloak hanging from a peg, a bag beside it
                    for (y in 6 until h) { val half = 4 + (y - 6) / 3; rect(img, 22 - half, y, 22 + half, y + 1) { x, _ -> pick(CLOTH, 0.6 - (x - 22) * 0.03 + (if ((x + y / 4) % 6 == 0) -0.3 else 0.0)) } }
                    line(img, 44.0, 6.0, 40.0, 16.0, argb(0x5A4632)); line(img, 44.0, 6.0, 48.0, 16.0, argb(0x5A4632))
                    blob(img, 44.0, 22.0, 7.0, 7.0) { nx, ny -> shade(argb(0x6A4A30), 1.1 - nx * 0.3 - ny * 0.2) }
                }
                2 -> {
                    // a pan and a ladle on nails
                    blob(img, 22.0, 18.0, 10.0, 10.0) { nx, ny -> val d = nx * nx + ny * ny; if (d > 0.75) IRON_R[0] else shade(IRON_R[1], 0.9 - nx * 0.2 - ny * 0.2) }
                    rect(img, 21, 2, 24, 9) { _, _ -> BEAM[1] }
                    line(img, 44.0, 4.0, 44.0, 24.0, IRON_R[0]); blob(img, 44.0, 27.0, 4.0, 3.0) { nx, _ -> shade(IRON_R[0], 1.2 - nx * 0.3) }
                }
                3 -> {
                    // a small board of crocks and a jug
                    rect(img, 8, 22, w - 8, 26) { _, y -> if (y == 22) BEAM[0] else BEAM[1] }
                    line(img, 12.0, 26.0, 16.0, 32.0, BEAM[2]); line(img, w - 12.0, 26.0, w - 16.0, 32.0, BEAM[2])
                    blob(img, 18.0, 16.0, 5.0, 6.0) { nx, ny -> shade(argb(0x7A5A3A), 1.1 - nx * 0.3 - ny * 0.2) }
                    blob(img, 30.0, 17.0, 4.0, 5.0) { nx, ny -> shade(argb(0x5A6A5E), 1.1 - nx * 0.3 - ny * 0.2) }
                    jug(img, 38, 22)
                }
                else -> {
                    // a pair of antlers on a board
                    blob(img, 32.0, 14.0, 5.0, 6.0) { nx, ny -> pick(BEAM, 0.6 - nx * 0.2 - ny * 0.2) }
                    for (s in listOf(-1, 1)) {
                        line(img, 32.0 + s * 3, 10.0, 32.0 + s * 16, 2.0, argb(0xB0A080))
                        line(img, 32.0 + s * 9, 6.0, 32.0 + s * 10, 0.0, argb(0xB0A080))
                        line(img, 32.0 + s * 13, 4.0, 32.0 + s * 20, 6.0, argb(0xA09070))
                    }
                }
            }
            Sprite(img, w / 2, h - 1)
        }
    }

    private fun obj(s: Sprite, artX: Double, artY: Double, sortY: Double = artY): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
        return WorldArt.Obj(s.img, x, y, (sortY / D).toInt(), D)
    }

    /** The furniture for one tile of a room, or null for the former picture. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int = 0): List<WorldArt.Obj>? {
        val cx = (tx + 0.5) * S; val bottom = (ty + 0.95) * S
        fun at(dx: Int, dy: Int) = if (map.inside(tx + dx, ty + dy)) map.tile(tx + dx, ty + dy) else Tile.WALL
        fun same(dx: Int) = at(dx, 0) == map.tile(tx, ty)
        val v = hash(tx, ty, 3)
        return when (map.tile(tx, ty)) {
            Tile.SHELF -> listOf(obj(shelf(hash(tx, ty, 1) % 5), cx, (ty + 0.7) * S))
            Tile.BED -> when {
                at(0, -1) == Tile.BED -> listOf(obj(longBed(hash(tx, ty, 4) % 3), cx, bottom))
                at(0, 1) == Tile.BED -> emptyList()
                else -> listOf(obj(bed(hash(tx, ty, 4) % 3), cx, bottom))
            }
            Tile.COUNTER -> listOf(obj(counter(same(-1), same(1), hash(tx, ty, 2) % 4), cx, bottom))
            Tile.TABLE -> listOf(obj(table(same(-1), same(1), v % 4), cx, bottom))
            Tile.BENCH -> listOf(obj(bench(same(-1), same(1)), cx, (ty + 0.55) * S))
            Tile.BARREL -> listOf(obj(barrel(v % 2), cx + (v % 7 - 3), (ty + 0.85) * S))
            Tile.CRATE -> listOf(obj(crates(v % 3), cx, (ty + 0.9) * S))
            Tile.CLUTTER -> {
                // by the fire lies firewood; elsewhere whatever gathers in a room
                val byFire = (-1..1).any { dx -> (-1..0).any { dy -> at(dx, dy) == Tile.HEARTH } }
                // beside a table stands a stool; elsewhere sacks, a basket, a bucket or straw, each room its own mix
                val byTable = (-1..1).any { dx -> at(dx, 0) == Tile.TABLE }
                val kind = if (byFire) 0 else if (byTable) 3 else listOf(1, 2, 4, 5)[hash(tx, ty, 56) % 4]
                listOf(obj(clutter(kind, v % 3), cx + (v % 9 - 4), (ty + 0.8) * S))
            }
            Tile.PLANT -> listOf(obj(plant(), cx, bottom))
            Tile.ALTAR -> listOf(obj(altar(same(-1), same(1)), cx, (ty + 0.8) * S))
            Tile.HEARTH -> if (at(-1, 0) == Tile.HEARTH) emptyList() else {
                val wide = at(1, 0) == Tile.HEARTH
                val mouth = ((if (wide) 2 else 1) * S * 0.64).toInt()
                listOf(obj(fire(frame, mouth), if (wide) (tx + 1.0) * S else cx, (ty + 1.0) * S - 1))
            }
            Tile.WALL -> {
                // on the back wall, where nothing tall stands before it, something hangs
                val below = at(0, 1)
                if (ty + 1 >= map.height || below in wallTiles || below == Tile.DOOR || below == Tile.SHELF || below == Tile.BED || below == Tile.HEARTH) emptyList()
                else wallThing(hash(tx, ty, 55) % 7)?.let { listOf(obj(it, cx, (ty + 1.0) * S - 6)) } ?: emptyList()
            }
            Tile.WINDOW, Tile.DOOR, Tile.WOOD_FLOOR, Tile.RUG -> emptyList()
            else -> null
        }
    }
}
