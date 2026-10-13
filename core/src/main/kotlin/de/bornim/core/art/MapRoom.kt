package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.sqrt

/**
 * The floor of the rooms of Bornim (the inn, the shop, the elder's house and the temple), drawn in chunks like
 * [MapGround]: dark oak boards worn pale where feet go, rugs, the hearth's glow. Walls and furniture stand upright on
 * it ([MapRoomIso]); here are also the fire in the hearth ([fire]) and what hangs on the walls ([wallThing]).
 * At double resolution ([S] art pixels per tile).
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
    private val STRAW = ramp(0xB09A60, 0x8E7A48, 0x6A5A36)
    private val ASH = ramp(0x8A8480, 0x5E5A56, 0x34302C)
    private val FIRE = ramp(0xFFF0B0, 0xFFC860, 0xF08A30, 0xC04E1C, 0x6A2010)
    private val IRON_R = ramp(0x5A5650, 0x3A3632, 0x221F1C)

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.HEARTH)

    /** Things standing on the floor: the boards about them lie in their shade. */
    private val furniture = setOf(Tile.TABLE, Tile.BED, Tile.SHELF, Tile.COUNTER, Tile.BARREL, Tile.CRATE, Tile.BENCH, Tile.CLUTTER, Tile.PLANT, Tile.ALTAR, Tile.DESK, Tile.TRUNK, Tile.ARMCHAIR, Tile.RACK, Tile.CANDLES, Tile.FONT)

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
                // behind the counter, out of the light
                if (map.inside(tx, ty + 1) && map.tile(tx, ty + 1) == Tile.COUNTER) tt -= 0.12 + (ly / S.toDouble()) * 0.1
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

    private fun jug(img: PixelImage, x: Int, y: Int) {
        blob(img, x + 4.0, y - 5.0, 4.5, 5.0) { nx, ny -> shade(argb(0x8A5A38), 1.15 - nx * 0.35 - ny * 0.15) }
        rect(img, x + 2, y - 12, x + 6, y - 9) { xx, _ -> if (xx == x + 2) argb(0x9A6A44) else argb(0x7A4A2E) }
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
}
