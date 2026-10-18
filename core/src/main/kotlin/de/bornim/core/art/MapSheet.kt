package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile

/**
 * The map of a place as a drawing for the menu (Vorrat 8, draft): ink and a little watercolour on old parchment,
 * made from the map's tiles like the travel map of the draft „Wege“ (C), but in pixels so it runs on the device.
 * Only what the hero has seen is drawn; the rest stays bare parchment, the edge between frayed. The hero is a
 * red mark, the ways out small red arrows.
 */
object MapSheet {
    /** 62h/62n (draft, preview `KARTENTUSCHE=1`): drawn like the land map, [MapInk.S] times finer ([MapInk]). */
    @Volatile var ink = true

    /** Pixels per tile, and the margin of bare parchment round the map. */
    const val C = 8
    const val PAD = 10

    private const val PARCH = 0xFFE6D3A8.toInt()
    private const val INK = 0xFF4A3622.toInt()
    private const val INK_SOFT = 0xFF7A6248.toInt()
    private const val RED = 0xFFA8322A.toInt()

    private fun hash(x: Int, y: Int, s: Int): Int {
        var h = x * 374761393 + y * 668265263 + s * 2147483629
        h = (h xor (h ushr 13)) * 1274126177
        return (h xor (h ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun mix(a: Int, b: Int, t: Double): Int {
        fun ch(c: Int, s: Int) = (c shr s) and 0xFF
        fun m(s: Int) = (ch(a, s) + (ch(b, s) - ch(a, s)) * t.coerceIn(0.0, 1.0)).toInt()
        return (0xFF shl 24) or (m(16) shl 16) or (m(8) shl 8) or m(0)
    }

    /**
     * The drawing of [map]; [seen] says which tiles the hero knows, ([heroX], [heroY]) where it stands (negative:
     * not on this map).
     */
    /** The part of the map the sheet shows, in tiles: x, y, width, height. All of it, except a cave in ink (62o):
     *  a sheet of one fixed size, the explored part in its middle, so the sheet never tells how big the cave is. */
    class Window(val x: Int, val y: Int, val w: Int, val h: Int)
    const val CAVE_SHEET = 30
    fun window(map: MapDef, seen: (Int, Int) -> Boolean): Window {
        if (!ink || map.kind != MapKind.CAVE) return Window(0, 0, map.width, map.height)
        var x0 = Int.MAX_VALUE; var y0 = Int.MAX_VALUE; var x1 = -1; var y1 = -1
        for (y in 0 until map.height) for (x in 0 until map.width) if (seen(x, y)) { x0 = minOf(x0, x); y0 = minOf(y0, y); x1 = maxOf(x1, x); y1 = maxOf(y1, y) }
        if (x1 < 0) return Window(0, 0, CAVE_SHEET, CAVE_SHEET)
        // grows only in whole sheets, so even a long cave does not show its size to the tile
        fun size(n: Int) = ((n + 4 + CAVE_SHEET - 1) / CAVE_SHEET) * CAVE_SHEET
        val w = size(x1 - x0 + 1); val h = size(y1 - y0 + 1)
        return Window((x0 + x1 + 1) / 2 - w / 2, (y0 + y1 + 1) / 2 - h / 2, w, h)
    }

    fun render(map: MapDef, seen: (Int, Int) -> Boolean, heroX: Int = -1, heroY: Int = -1, gateOpen: Boolean = false): PixelImage {
        if (ink) return MapInk.render(map, seen, gateOpen)
        val w = map.width * C + 2 * PAD; val h = map.height * C + 2 * PAD
        val img = PixelImage(w, h)
        // parchment: warm, blotchy, darker towards the edges
        for (y in 0 until h) for (x in 0 until w) {
            val blot = rnd(x / 6, y / 6, 1) * 0.5 + rnd(x / 3, y / 3, 2) * 0.3 + rnd(x, y, 3) * 0.2
            val edge = minOf(minOf(x, w - 1 - x), minOf(y, h - 1 - y)).toDouble()
            val dark = (1.0 - edge / 14.0).coerceIn(0.0, 1.0) * 0.35 + (blot - 0.5) * 0.12
            img.set(x, y, mix(PARCH, 0xFF9A7A50.toInt(), dark))
        }
        // how much of each tile is known: frayed at the edge between known and not, so the edge is no staircase
        fun known(tx: Int, ty: Int) = map.inside(tx, ty) && seen(tx, ty)
        fun px(tx: Int, ty: Int) = PAD + tx * C
        fun py(tx: Int, ty: Int) = PAD + ty * C
        fun wash(tx: Int, ty: Int, color: Int, k: Double) {
            for (y in 0 until C) for (x in 0 until C) {
                val ax = px(tx, ty) + x; val ay = py(tx, ty) + y
                img.set(ax, ay, mix(img[ax, ay], color, k * (0.85 + rnd(ax, ay, 9) * 0.3)))
            }
        }
        fun dot(x: Int, y: Int, c: Int) { img.set(x, y, c) }
        fun line(x0: Int, y0: Int, x1: Int, y1: Int, c: Int, dashed: Boolean = false) {
            val n = maxOf(kotlin.math.abs(x1 - x0), kotlin.math.abs(y1 - y0), 1)
            for (i in 0..n) {
                if (dashed && (i / 2) % 2 == 1) continue
                dot(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n, c)
            }
        }
        fun isPath(t: Tile) = t == Tile.PATH || t == Tile.CAVE_ENTRANCE || t == Tile.BRIDGE || t == Tile.DOOR || t == Tile.CAVE_EXIT
        fun house(t: Tile) = t == Tile.ROOF || t == Tile.ROOF_BLUE || t == Tile.WALL || t == Tile.WINDOW
        val room = map.kind == MapKind.INTERIOR
        val cave = map.kind == MapKind.CAVE

        // 1) washes of colour: grass, water, houses, cobbles, rock
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (!known(tx, ty)) continue
            when (val t = map.tile(tx, ty)) {
                Tile.GRASS, Tile.FLOWERS, Tile.TALL_GRASS -> wash(tx, ty, 0xFFB8C088.toInt(), if (t == Tile.TALL_GRASS) 0.45 else 0.3)
                Tile.TREE -> wash(tx, ty, 0xFF8EA06A.toInt(), 0.35)
                Tile.WATER -> wash(tx, ty, 0xFF8EB0BA.toInt(), 0.6)
                Tile.COBBLE -> wash(tx, ty, 0xFFC4B898.toInt(), 0.5)
                Tile.ROOF, Tile.ROOF_BLUE, Tile.WALL, Tile.WINDOW ->
                    if (room) wash(tx, ty, 0xFF6A5440.toInt(), 0.75)
                    else wash(tx, ty, if (t == Tile.ROOF_BLUE) 0xFF7A8AA0.toInt() else 0xFFB0644A.toInt(), 0.6)
                Tile.CAVE_WALL, Tile.ROCK -> wash(tx, ty, 0xFF8A7A66.toInt(), if (cave) 0.55 else 0.4)
                Tile.WOOD_FLOOR, Tile.RUG, Tile.CLUTTER, Tile.HANGING -> wash(tx, ty, if (t == Tile.RUG) 0xFFB06048.toInt() else 0xFFC8A878.toInt(), 0.35)
                Tile.CROPS, Tile.VEG_BED -> wash(tx, ty, 0xFF98A858.toInt(), 0.5)
                else -> {}
            }
        }
        // 2) ink: outlines of houses and walls, the ways, trees, signs
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (!known(tx, ty)) continue
            val t = map.tile(tx, ty)
            val x0 = px(tx, ty); val y0 = py(tx, ty); val cx = x0 + C / 2; val cy = y0 + C / 2
            // a wall's or a house's edge where it meets open ground
            if (house(t) || t == Tile.CAVE_WALL) {
                val open = { ax: Int, ay: Int -> map.inside(ax, ay) && !house(map.tile(ax, ay)) && map.tile(ax, ay) != Tile.CAVE_WALL }
                if (open(tx, ty - 1)) line(x0, y0, x0 + C - 1, y0, INK)
                if (open(tx, ty + 1)) line(x0, y0 + C - 1, x0 + C - 1, y0 + C - 1, INK)
                if (open(tx - 1, ty)) line(x0, y0, x0, y0 + C - 1, INK)
                if (open(tx + 1, ty)) line(x0 + C - 1, y0, x0 + C - 1, y0 + C - 1, INK)
                // hatching on rock and roofs
                if (!room) for (k in 0 until C step 3) line(x0 + k, y0 + C - 1, x0 + minOf(C - 1, k + 2), y0 + C - 3, INK_SOFT)
            }
            when (t) {
                Tile.TREE -> {
                    // a small crown with a darker under side and a trunk, a little off the middle each
                    val ox = cx + (rnd(tx, ty, 4) * 3).toInt() - 1; val oy = cy + (rnd(tx, ty, 5) * 3).toInt() - 2
                    for (y in -3..2) for (x in -3..3) if (x * x + y * y * 1.3 <= 9.5)
                        img.set(ox + x, oy + y, mix(img[ox + x, oy + y], if (y > 0) 0xFF4E6238.toInt() else 0xFF6E8448.toInt(), 0.8))
                    for (y in -3..2) for (x in -3..3) if (x * x + y * y * 1.3 in 7.0..9.5 && y >= -1) dot(ox + x, oy + y, INK)
                    dot(ox, oy + 3, INK); dot(ox, oy + 4, INK)
                }
                Tile.TALL_GRASS -> { line(x0 + 2, y0 + 5, x0 + 2, y0 + 3, INK_SOFT); line(x0 + 5, y0 + 6, x0 + 5, y0 + 4, INK_SOFT) }
                Tile.FLOWERS -> { dot(x0 + 2, y0 + 3, RED); dot(x0 + 5, y0 + 5, 0xFFC8A030.toInt()); dot(x0 + 4, y0 + 2, RED) }
                Tile.WATER -> {
                    // little waves
                    val wy = y0 + 3 + (tx % 2) * 2
                    dot(x0 + 1, wy, INK_SOFT); dot(x0 + 2, wy - 1, INK_SOFT); dot(x0 + 3, wy, INK_SOFT); dot(x0 + 4, wy - 1, INK_SOFT)
                }
                Tile.ROCK -> for (y in -2..2) for (x in -3..3) if (x * x + y * y * 2 in 6..10) dot(cx + x, cy + y, INK)
                Tile.CAMPFIRE, Tile.HEARTH -> {
                    line(cx - 2, cy + 2, cx + 2, cy - 2, INK); line(cx - 2, cy - 2, cx + 2, cy + 2, INK)
                    dot(cx, cy - 1, RED); dot(cx - 1, cy, RED); dot(cx + 1, cy, RED); dot(cx, cy, 0xFFD87830.toInt())
                }
                Tile.CHEST, Tile.TRUNK -> { for (y in 0..2) line(cx - 2, cy - 1 + y, cx + 2, cy - 1 + y, 0xFF8A5A30.toInt()); line(cx - 2, cy - 2, cx + 2, cy - 2, INK) }
                Tile.SIGN, Tile.NOTICE -> { line(cx, cy - 2, cx, cy + 3, INK); line(cx - 2, cy - 2, cx + 2, cy - 2, INK); line(cx - 2, cy - 1, cx + 2, cy - 1, INK) }
                Tile.WELL, Tile.FONT -> for (y in -2..2) for (x in -2..2) if (x * x + y * y in 3..5) dot(cx + x, cy + y, INK)
                Tile.FENCE -> line(x0, cy, x0 + C - 1, cy, INK, dashed = true)
                Tile.GATE -> line(x0, cy, x0 + C - 1, cy, RED)
                Tile.CROPS, Tile.VEG_BED -> for (k in 1 until C step 3) line(x0 + 1, y0 + k, x0 + C - 2, y0 + k, 0xFF5E7030.toInt(), dashed = true)
                Tile.TABLE, Tile.COUNTER, Tile.BED, Tile.SHELF, Tile.DESK, Tile.STALL, Tile.BENCH, Tile.RACK, Tile.ALTAR, Tile.ARMCHAIR -> {
                    for (y in 1 until C - 1) for (x in 1 until C - 1) img.set(x0 + x, y0 + y, mix(img[x0 + x, y0 + y], 0xFF8A6440.toInt(), 0.55))
                    line(x0 + 1, y0 + 1, x0 + C - 2, y0 + 1, INK); line(x0 + 1, y0 + C - 2, x0 + C - 2, y0 + C - 2, INK)
                }
                Tile.BARREL, Tile.PLANT, Tile.CANDLES, Tile.LAMP, Tile.TORCH, Tile.YARD -> for (y in -1..1) for (x in -1..1) if (x * x + y * y <= 1) dot(cx + x, cy + y, INK)
                else -> {}
            }
        }
        // 3) the ways: a brown line from each way tile to the way tiles beside it, dashed in the woods
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (!known(tx, ty) || !isPath(map.tile(tx, ty))) continue
            val cx = px(tx, ty) + C / 2; val cy = py(tx, ty) + C / 2
            var any = false
            for ((dx, dy) in listOf(1 to 0, 0 to 1, 1 to 1, -1 to 1)) {
                val nx = tx + dx; val ny = ty + dy
                if (!known(nx, ny) || !isPath(map.tile(nx, ny))) continue
                // a diagonal only where the straight way round is not taken
                if (dx != 0 && dy != 0 && (isPath(map.tile(tx + dx, ty)) || isPath(map.tile(tx, ty + dy)))) continue
                any = true
                for (k in 0..1) line(cx + k, cy, cx + dx * C + k, cy + dy * C, 0xFF8A6238.toInt(), dashed = map.kind == MapKind.FOREST)
            }
            if (!any) dot(cx, cy, 0xFF8A6238.toInt())
        }
        // 4) the ways out: small red arrows pointing off the map or into the door
        for (wp in map.warps) {
            if (!known(wp.x, wp.y)) continue
            val cx = px(wp.x, wp.y) + C / 2; val cy = py(wp.x, wp.y) + C / 2
            // 62p: a cave is a ground plan of its own; its mouth is drawn where the way goes in (tapping it opens the plan)
            if (de.bornim.core.World.maps[wp.to.map]?.kind == MapKind.CAVE && map.kind != MapKind.CAVE) {
                for (y in -4..3) for (x in -5..5) {
                    val d = x * x / 25.0 + (y + 1) * (y + 1) / 16.0
                    if (y <= 2 && d <= 1.0) img.set(cx + x, cy + y, mix(img[cx + x, cy + y], if (d > 0.7) INK else 0xFF2A2018.toInt(), 0.9))
                }
                for (x in -6..6) img.set(cx + x, cy + 3, INK_SOFT)
                continue
            }
            val (dx, dy) = when {
                wp.y == 0 -> 0 to -1; wp.y == map.height - 1 -> 0 to 1
                wp.x == 0 -> -1 to 0; wp.x == map.width - 1 -> 1 to 0
                else -> 0 to -1
            }
            for (k in 0..3) { dot(cx + dx * k - dy * (3 - k) / 2, cy + dy * k - dx * (3 - k) / 2, RED); dot(cx + dx * k + dy * (3 - k) / 2, cy + dy * k + dx * (3 - k) / 2, RED) }
        }
        // 5) the unknown: bare parchment, the edge frayed into the known tiles
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (known(tx, ty)) continue
            for (y in -2 until C + 2) for (x in -2 until C + 2) {
                val ax = px(tx, ty) + x; val ay = py(tx, ty) + y
                val inside = x in 0 until C && y in 0 until C
                if (inside || rnd(ax, ay, 7) < 0.45) {
                    val blot = rnd(ax / 6, ay / 6, 1) * 0.5 + rnd(ax / 3, ay / 3, 2) * 0.3 + rnd(ax, ay, 3) * 0.2
                    img.set(ax, ay, mix(PARCH, 0xFF9A7A50.toInt(), (blot - 0.5) * 0.12))
                }
            }
        }
        // 6) the hero: a red ring with a dot
        if (map.inside(heroX, heroY)) {
            val cx = px(heroX, heroY) + C / 2; val cy = py(heroX, heroY) + C / 2
            for (y in -4..4) for (x in -4..4) {
                val d = x * x + y * y
                if (d in 10..17 || d <= 2) img.set(cx + x, cy + y, RED)
            }
        }
        // a thin double frame of ink
        for (x in 3 until w - 3) { img.set(x, 3, INK); img.set(x, h - 4, INK); img.set(x, 5, INK_SOFT); img.set(x, h - 6, INK_SOFT) }
        for (y in 3 until h - 3) { img.set(3, y, INK); img.set(w - 4, y, INK); img.set(5, y, INK_SOFT); img.set(w - 6, y, INK_SOFT) }
        return img
    }
}
