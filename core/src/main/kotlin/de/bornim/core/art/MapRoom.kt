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

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW)

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
            if (t in wallTiles) {
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
                c = pick(BOARD, tt)
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
    private fun candle(img: PixelImage, x: Int, y: Int) {
        rect(img, x, y - 6, x + 3, y) { _, _ -> argb(0xC8BCA0) }
        put(img, x + 1, y - 7, FLAME); put(img, x + 1, y - 8, argb(0xFFE0A0))
    }

    /** A tall shelf against the wall: three boards of jars, bottles, books and bundles. */
    fun shelf(v: Int): Sprite = cached("shelf/$v") {
        val w = S - 4; val h = 96; val img = PixelImage(w, h)
        rect(img, 0, 6, w, h - 2) { x, _ -> if (x < 4 || x >= w - 4) BEAM[1] else BEAM[2] }
        for (k in 0 until 3) {
            val by = 30 + k * 22
            rect(img, 2, by, w - 2, by + 4) { _, y -> if (y == by) BEAM[0] else BEAM[1] }
            var x = 6
            var i = 0
            while (x < w - 10) {
                val kind = hash(i, k, v) % 4
                val iw = 5 + hash(i, k, v + 1) % 6; val ih = 8 + hash(i, k, v + 2) % 9
                val col = listOf(0x4A3A2E, 0x2E3A3A, 0x5A2A22, 0x6A6048, 0x3A4A2A)[hash(i, k, v + 3) % 5]
                when (kind) {
                    0 -> rect(img, x, by - ih, x + iw, by) { xx, _ -> shade(argb(col), if (xx == x) 1.3 else 1.0) }
                    1 -> { rect(img, x + 1, by - ih, x + iw - 1, by) { xx, yy -> shade(argb(0x3A4A46), if (xx == x + 1) 1.6 else 1.0) }; put(img, x + 2, by - ih + 2, argb(0xA8B0A8)) }
                    2 -> blob(img, x + iw / 2.0, by - ih / 2.0, iw / 2.0, ih / 2.0) { nx, ny -> shade(argb(0x7A5A3A), 1.1 - nx * 0.2 - ny * 0.3) }
                    else -> rect(img, x, by - ih, x + 3, by) { _, _ -> argb(col) }
                }
                x += iw + 2; i++
            }
        }
        Sprite(img, w / 2, h - 4)
    }

    /** A bed: a plank frame, a straw mattress, a rough wool blanket and a bolster. */
    fun bed(v: Int = 0): Sprite = cached("bed/$v") {
        val w = S - 6; val h = 80; val img = PixelImage(w, h)
        val blanket = listOf(ramp(0x6A3A30, 0x542E26, 0x3E221C), ramp(0x4A5260, 0x3A404C, 0x2A2E38), CLOTH)[v % 3]
        // the headboard, then the frame with the mattress, a bolster, the blanket thrown over with folds
        rect(img, 2, 2, w - 2, 14) { x, y -> if (y < 4) BEAM[0] else pick(BEAM, 0.5 - (if (x % 9 == 0) 0.3 else 0.0)) }
        rect(img, 2, 14, w - 2, h - 6) { x, _ -> if (x < 5 || x >= w - 5) BEAM[1] else argb(0x8A7A58) }
        rect(img, 2, h - 12, w - 2, h - 6) { _, y -> if (y == h - 12) BEAM[0] else BEAM[2] }
        blob(img, w / 2.0, 21.0, w / 2.0 - 9, 5.5) { nx, ny -> shade(argb(0xB8AC90), 1.05 - nx * 0.1 - ny * 0.25) }
        rect(img, 6, 30, w - 6, h - 13) { x, y -> pick(blanket, 0.6 - (x - 6) / w.toDouble() * 0.3 + (vnoise(x.toDouble(), y * 0.5, 5.0, 13 + v) - 0.5) * 0.5 - (if (y == 30) 0.0 else 0.0)) }
        rect(img, 6, 30, w - 6, 33) { _, _ -> shade(blanket[0], 1.15) }
        Sprite(img, w / 2, h - 4)
    }

    /** One tile of the counter: thick planks, the top worn, a mug or a jug on it. */
    fun counter(l: Boolean, r: Boolean, v: Int): Sprite = cached("counter/$l/$r/$v") {
        val w = S; val h = 60; val img = PixelImage(w, h)
        val x0 = if (l) 0 else 3; val x1 = if (r) w else w - 3
        rect(img, x0, 14, x1, 24) { x, y -> pick(BEAM.map { shade(it, 1.6) }, 0.6 - (y - 14) * 0.04 + (rnd(x / 5, y, 14) - 0.5) * 0.2) }
        rect(img, x0, 24, x1, h - 4) { x, _ -> if ((x - x0) % 11 == 0) BEAM[2] else pick(BEAM, 0.55) }
        if (v % 2 == 0) { rect(img, 22, 6, 30, 16) { x, _ -> if (x == 22) argb(0x9A8E78) else argb(0x7A6E5A) }; put(img, 31, 9, argb(0x7A6E5A)); put(img, 31, 12, argb(0x7A6E5A)) }
        else blob(img, 40.0, 10.0, 6.0, 7.0) { nx, ny -> shade(argb(0x6A4A30), 1.1 - nx * 0.3 - ny * 0.2) }
        Sprite(img, w / 2, h - 4)
    }

    /** A rough table on trestles: a candle, a bowl, a mug, a heel of bread. */
    fun table(v: Int): Sprite = cached("table/$v") {
        val w = S - 4; val h = 60; val img = PixelImage(w, h)
        // the top seen from above, boards running across, then its front edge and the legs
        rect(img, 2, 8, w - 2, 34) { x, y -> pick(BEAM.map { shade(it, 1.6) }, 0.6 - (y - 8) * 0.012 + (if ((y - 8) % 7 == 0) -0.35 else 0.0) + (rnd(x / 9, (y - 8) / 7, 15 + v) - 0.5) * 0.2) }
        rect(img, 2, 34, w - 2, 39) { _, y -> if (y == 34) BEAM[0] else BEAM[2] }
        for (x in listOf(5, w - 9)) rect(img, x, 39, x + 4, h - 4) { xx, _ -> if (xx == x) BEAM[0] else BEAM[1] }
        candle(img, 10 + v * 7 % 20, 22)
        blob(img, 38.0, 20.0, 8.0, 5.0) { nx, ny -> if (nx * nx + ny * ny < 0.4) argb(0x3A2A1E) else shade(argb(0x8A7458), 1.1 - ny * 0.3) }
        if (v % 2 == 1) blob(img, 24.0, 28.0, 6.0, 3.5) { nx, ny -> shade(argb(0x9A7A48), 1.1 - nx * 0.2 - ny * 0.2) }
        else rect(img, 22, 23, 28, 31) { x, _ -> if (x == 22) argb(0x9A8E78) else argb(0x7A6E5A) }
        Sprite(img, w / 2, h - 4)
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
            // the sun: a dull golden disc with rays, standing at the inner end
            val cx = (x1 - 6).toDouble(); val cy = 14.0
            for (k in 0 until 8) { val a = k * Math.PI / 4; for (i in 7..11) put(img, (cx + kotlin.math.cos(a) * i).toInt(), (cy + kotlin.math.sin(a) * i).toInt(), GOLD[1]) }
            blob(img, cx, cy, 6.0, 6.0) { nx, ny -> pick(GOLD, 0.7 - nx * 0.3 - ny * 0.3) }
        }
        Sprite(img, w / 2, h - 4)
    }

    private fun obj(s: Sprite, artX: Double, artY: Double): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - s.ax, D); val y = Math.floorDiv(artY.toInt() - s.ay, D)
        return WorldArt.Obj(s.img, x, y, (artY / D).toInt(), D)
    }

    /** The furniture for one tile of a room, or null for the former picture. */
    fun objects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val cx = (tx + 0.5) * S; val bottom = (ty + 0.95) * S
        fun same(dx: Int) = map.tile(tx + dx, ty) == map.tile(tx, ty)
        return when (map.tile(tx, ty)) {
            Tile.SHELF -> listOf(obj(shelf(hash(tx, ty, 1) % 5), cx, (ty + 0.7) * S))
            Tile.BED -> listOf(obj(bed(hash(tx, ty, 4) % 3), cx, bottom))
            Tile.COUNTER -> listOf(obj(counter(same(-1), same(1), hash(tx, ty, 2) % 4), cx, bottom))
            Tile.TABLE -> listOf(obj(table(hash(tx, ty, 3) % 4), cx, bottom))
            Tile.PLANT -> listOf(obj(plant(), cx, bottom))
            Tile.ALTAR -> listOf(obj(altar(same(-1), same(1)), cx, (ty + 0.8) * S))
            Tile.WALL, Tile.WINDOW, Tile.DOOR, Tile.WOOD_FLOOR, Tile.RUG -> emptyList()
            else -> null
        }
    }
}
