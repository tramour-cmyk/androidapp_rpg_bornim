package de.bornim.core.art

import de.bornim.core.GameState
import de.bornim.core.HouseFeature
import de.bornim.core.HouseStyle
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.RoofKind
import de.bornim.core.Story
import de.bornim.core.Tile
import de.bornim.core.WallKind

/**
 * 32×32 world graphics in a classic three-quarter ("from above at an angle") view.
 *
 * The map is drawn in two layers: [ground] tiles (with auto-tiling against their neighbours,
 * e.g. path borders, shores, cliff faces) and [objects] such as trees, buildings and furniture.
 * Objects are taller than a tile and are depth-sorted with the characters by [Obj.sortY], so the
 * hero can walk behind a tree crown or a roof.
 */
object WorldArt {
    const val T = 32

    /** A drawable at map pixel position ([x], [y]) = top-left, ordered by [sortY]; [density] art pixels per map pixel (2 for the finer new pictures). */
    /** [low]: never tall enough to hide a figure behind it (furniture of the rooms seen diagonally, 13). */
    /** [corner]: seen diagonally, the picture's foot is the tile's front corner (the rooms, [MapRoomIso]), not the middle of its lower edge. */
    class Obj(val img: PixelImage, val x: Int, val y: Int, val sortY: Int, val density: Int = 1, val low: Boolean = false, val corner: Boolean = false)

    private val cache = HashMap<String, PixelImage>()
    private fun cached(key: String, w: Int = T, h: Int = T, block: Pen.() -> Unit) = cache.getOrPut(key) { draw(w, h, block = block) }

    private val SHADOW = alpha(0x0C0E14, 0x70)
    private val SHADOW_SOFT = alpha(0x101020, 0x30)

    // ================================================================== ground layer

    fun ground(map: MapDef, tx: Int, ty: Int, state: GameState, frame: Int): PixelImage {
        val t = map.tile(tx, ty)
        val seed = Math.floorMod(tx * 7 + ty * 13, 4)
        fun at(dx: Int, dy: Int): Tile = if (map.inside(tx + dx, ty + dy)) map.tile(tx + dx, ty + dy) else t
        val kind = map.kind
        return when (t) {
            Tile.GRASS -> {
                // the forest floor near trees: ferns, mushrooms, fallen leaves
                val nearTree = kind == MapKind.FOREST && listOf(0 to -1, 1 to 0, 0 to 1, -1 to 0).any { (dx, dy) -> at(dx, dy) == Tile.TREE }
                val deco = Math.floorMod(tx * 13 + ty * 7 + tx * ty, 5)
                if (nearTree && deco < 3) cached("grassdeco$seed/$deco") { grass(seed); forestFloor(deco) }
                else cached("grass$seed") { grass(seed) }
            }
            Tile.FLOWERS -> cached("flowers$seed/${Math.floorMod(tx * 3 + ty * 5, 3)}") { grass(seed); flowers(seed + Math.floorMod(tx * 3 + ty * 5, 3) * 4) }
            Tile.TALL_GRASS -> {
                fun g(dx: Int, dy: Int) = at(dx, dy) == Tile.TALL_GRASS
                val m = mask(!g(0, -1), !g(1, 0), !g(0, 1), !g(-1, 0))
                cached("tall$seed/$m") { tallGrass(seed, m) }
            }
            Tile.PATH, Tile.BARRIER -> {
                fun p(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.PATH || it == Tile.BARRIER || it == Tile.DOOR || it == Tile.CAVE_ENTRANCE || it in PAVED }
                val m = mask(!p(0, -1), !p(1, 0), !p(0, 1), !p(-1, 0))
                cached("path$m/$seed") { path(m, seed) }
            }
            Tile.WATER, Tile.BRIDGE -> {
                fun w(dx: Int, dy: Int) = at(dx, dy) == Tile.WATER || at(dx, dy) == Tile.BRIDGE
                val m = mask(!w(0, -1), !w(1, 0), !w(0, 1), !w(-1, 0))
                // inner corners: both neighbours are water, the diagonal is land
                val d = (if (w(0, -1) && w(1, 0) && !w(1, -1)) 1 else 0) or (if (w(1, 0) && w(0, 1) && !w(1, 1)) 2 else 0) or
                    (if (w(0, 1) && w(-1, 0) && !w(-1, 1)) 4 else 0) or (if (w(-1, 0) && w(0, -1) && !w(-1, -1)) 8 else 0)
                if (t == Tile.BRIDGE) {
                    val left = at(-1, 0) != Tile.BRIDGE; val right = at(1, 0) != Tile.BRIDGE
                    cached("bridge$m/$d/$frame/$left/$right") { water(m, frame, d); bridge(left, right) }
                } else if (kind == MapKind.CAVE) cached("cavewater$m/$d/$frame") { water(m, frame, d); caveWater() }
                else if (kind == MapKind.FOREST) cached("pond$m/$d/$frame/$seed") { water(m, frame, d); pondLife(m, seed) }
                else cached("water$m/$d/$frame") { water(m, frame, d) }
            }
            Tile.CROPS -> cached("crops$seed") { field(seed) }
            Tile.VEG_BED -> cached("veg$seed") { vegBed(seed) }
            Tile.FENCE, Tile.HAY, Tile.WASHLINE -> cached("grass$seed") { grass(seed) }
            Tile.TREE -> cached("treeground$seed") { grass(seed); blendEllipse(16.0, 26.0, 13.0, 5.0, SHADOW) }
            Tile.ROCK, Tile.SIGN, Tile.CHEST, Tile.CAMPFIRE, Tile.LOG, Tile.MENHIR -> {
                val base = baseGround(kind, seed)
                cached("obj-ground/${kind}/$seed/${t == Tile.CAMPFIRE}") {
                    paste(base)
                    blendEllipse(16.0, 27.0, 12.0, 4.0, SHADOW)
                    if (t == Tile.CAMPFIRE) blendEllipse(16.0, 22.0, 15.0, 10.0, alpha(0xF8B040, 0x30))
                }
            }
            Tile.ROOF, Tile.ROOF_BLUE, Tile.WINDOW -> cached("grass$seed") { grass(seed) }
            Tile.COBBLE, Tile.STALL, Tile.LAMP, Tile.BARREL, Tile.BENCH, Tile.WELL -> {
                // Objects on the square stand on cobbles, elsewhere on grass.
                val onSquare = t == Tile.COBBLE || listOf(0 to -1, 1 to 0, 0 to 1, -1 to 0).any { (dx, dy) -> at(dx, dy) == Tile.COBBLE }
                if (!onSquare) {
                    val base = baseGround(kind, seed)
                    cached("obj-ground/$kind/$seed/false") { paste(base); blendEllipse(16.0, 27.0, 12.0, 4.0, SHADOW) }
                } else {
                    fun c(dx: Int, dy: Int) = at(dx, dy).let { it in PAVED || it == Tile.PATH || it == Tile.WELL || it == Tile.DOOR }
                    val m = mask(!c(0, -1), !c(1, 0), !c(0, 1), !c(-1, 0))
                    cached("cobble$m/$seed/${t != Tile.COBBLE}") {
                        cobble(m, seed)
                        if (t != Tile.COBBLE) blendEllipse(16.0, 27.0, 12.0, 4.0, SHADOW)
                    }
                }
            }
            Tile.WALL, Tile.HEARTH -> when (kind) {
                MapKind.INTERIOR -> if (at(0, 1) != Tile.WALL && map.inside(tx, ty + 1)) cached("iwallface${tx % 3}") { interiorWallFace(tx % 3) } else cached("iwalltop") { interiorWallTop() }
                else -> cached("grass$seed") { grass(seed) }
            }
            Tile.DOOR -> if (kind == MapKind.INTERIOR) cached("doormat") { woodFloor(0); doormat() } else cached("path0/$seed") { path(0, seed) }
            Tile.CAVE_WALL, Tile.TORCH, Tile.CRYSTAL -> {
                fun wall(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.CAVE_WALL || it == Tile.TORCH || it == Tile.CAVE_ENTRANCE || it == Tile.CRYSTAL }
                val face = !wall(0, 1) && map.inside(tx, ty + 1)
                if (face) cached("cliff$seed/$t/$frame/${kind == MapKind.CAVE}") {
                    cliffFace(seed, kind != MapKind.CAVE)
                    if (t == Tile.TORCH) torch(frame)
                    if (t == Tile.CRYSTAL) crystals(seed)
                } else {
                    val m = mask(!wall(0, -1) && map.inside(tx, ty - 1), !wall(1, 0), false, !wall(-1, 0))
                    cached("rocktop$m/$seed") { rockTop(m, seed) }
                }
            }
            Tile.CAVE_ENTRANCE -> cached("caveentrance") { cliffFace(1, true); caveMouth() }
            Tile.CAVE_FLOOR, Tile.GATE, Tile.GLOWSHROOM, Tile.RUBBLE, Tile.BONES, Tile.BEDROLL, Tile.SUPPORT, Tile.SKYLIGHT -> {
                fun wall(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.CAVE_WALL || it == Tile.TORCH || it == Tile.CRYSTAL }
                val m = mask(wall(0, -1), wall(1, 0), false, wall(-1, 0))
                val base = cached("cavefloor$m/$seed") { caveFloor(seed, m) }
                when (t) {
                    Tile.GLOWSHROOM -> cached("shrooms$m/$seed") { paste(base); shrooms(Math.floorMod(tx * 5 + ty * 3, 4)) }
                    Tile.RUBBLE -> cached("rubble$m/$seed") { paste(base); rubble(Math.floorMod(tx * 3 + ty * 7, 5)) }
                    Tile.BONES -> cached("bones$m/$seed") { paste(base); bones(Math.floorMod(tx + ty, 2)) }
                    Tile.BEDROLL -> cached("bedroll$m/$seed") { paste(base); bedroll() }
                    Tile.SKYLIGHT -> cached("skylight$m/$seed") { paste(base); skylight(seed) }
                    else -> base
                }
            }
            Tile.STALAGMITE, Tile.CRATE -> {
                val base = baseGround(kind, seed)
                cached("obj-ground/$kind/$seed/false") { paste(base); blendEllipse(16.0, 27.0, 12.0, 4.0, SHADOW) }
            }
            Tile.CAVE_EXIT -> cached("caveexit") { caveFloor(0, 0); exitLight() }
            Tile.WOOD_FLOOR, Tile.CLUTTER -> {
                val shadow = map.inside(tx, ty - 1) && at(0, -1) == Tile.WALL
                cached("wood$seed/$shadow") { woodFloor(seed); if (shadow) topShadow(7) }
            }
            Tile.RUG -> {
                fun r(dx: Int, dy: Int) = at(dx, dy) == Tile.RUG
                val m = mask(!r(0, -1), !r(1, 0), !r(0, 1), !r(-1, 0))
                cached("rug$m") { rug(m) }
            }
            Tile.COUNTER, Tile.TABLE, Tile.BED, Tile.SHELF, Tile.PLANT, Tile.ALTAR -> {
                val shadow = map.inside(tx, ty - 1) && at(0, -1) == Tile.WALL
                cached("wood$seed/$shadow") { woodFloor(seed); if (shadow) topShadow(7) }
            }
        }
    }

    private fun baseGround(kind: MapKind, seed: Int): PixelImage = when (kind) {
        MapKind.CAVE -> cached("cavefloor0/$seed") { caveFloor(seed, 0) }
        MapKind.INTERIOR -> cached("wood$seed/false") { woodFloor(seed) }
        else -> cached("grass$seed") { grass(seed) }
    }

    private fun mask(n: Boolean, e: Boolean, s: Boolean, w: Boolean) =
        (if (n) 1 else 0) or (if (e) 2 else 0) or (if (s) 4 else 0) or (if (w) 8 else 0)

    private fun Pen.paste(src: PixelImage) {
        for (y in 0 until src.height) for (x in 0 until src.width) raw(x, y, src[x, y])
    }

    /** Alpha-blends [c] over the existing pixel. */
    private fun Pen.blend(x: Int, y: Int, c: Int) {
        val a = (c ushr 24) / 255.0
        val under = img[x, y]
        if ((under ushr 24) == 0) { raw(x, y, c); return }
        raw(x, y, mix(under, c or (0xFF shl 24), a) or (0xFF shl 24))
    }

    private fun Pen.blendEllipse(cx: Double, cy: Double, rx: Double, ry: Double, c: Int) {
        for (y in (cy - ry).toInt() - 1..(cy + ry).toInt() + 1) for (x in (cx - rx).toInt() - 1..(cx + rx).toInt() + 1) {
            val dx = (x + 0.5 - cx) / rx
            val dy = (y + 0.5 - cy) / ry
            if (dx * dx + dy * dy <= 1.0 && x in 0 until img.width && y in 0 until img.height) blend(x, y, c)
        }
    }

    private fun Pen.topShadow(h: Int) {
        for (y in 0 until h) for (x in 0 until T) blend(x, y, alpha(0x201010, (0x70 * (h - y) / h)))
    }

    // ------------------------------------------------------------------ outdoors

    private val G = argb(0x5E7C3C); private val G_D = argb(0x4C6832); private val G_DD = argb(0x3A5228); private val G_L = argb(0x7A9450)

    private fun Pen.grass(seed: Int) {
        fill(G)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 11 + seed) % 100
            // soft darker and lighter patches across the tile, then single flecks
            val patch = (noise(x / 6, y / 5, 13 + seed) % 7)
            if (patch == 0) raw(x, y, G_D) else if (patch == 1 && n < 50) raw(x, y, mix(G, G_L, 0.5))
            if (n < 6) raw(x, y, G_D) else if (n < 9) raw(x, y, G_L) else if (n < 11) raw(x, y, G_DD)
        }
        // a small stone now and then
        if (seed % 2 == 0) { val sx = 6 + noise(seed, 7, 3) % 20; val sy = 6 + noise(7, seed, 3) % 20; raw(sx, sy, argb(0x8A887E)); raw(sx + 1, sy, argb(0x6A685E)); raw(sx, sy + 1, G_DD) }
        // little tufts of blades
        for (i in 0 until 3) {
            val bx = 3 + noise(seed, i, 5) % 24
            val by = 6 + noise(i, seed, 9) % 22
            raw(bx, by, G_DD); raw(bx + 1, by - 1, G_D); raw(bx + 2, by, G_DD); raw(bx + 1, by - 2, G_L)
            raw(bx + 4, by + 1, G_DD); raw(bx + 5, by, G_D)
        }
    }

    /** A dense, colourful meadow that is easy to spot on a phone: twelve big blossoms per tile. */
    private fun Pen.flowers(seed: Int) {
        val colors = listOf(argb(0xA8443C), argb(0xD8D4C4), argb(0xC8A848), argb(0x8A6AA8), argb(0xB87A90), argb(0x6A86A8))
        var i = 0
        // A loose scatter: some spots of the jittered grid stay empty, two colours per tile.
        for (gy in 0 until 3) for (gx in 0 until 4) {
            if (noise(gx, gy, 71 + seed) % 5 < 2) continue
            val x = 4 + gx * 7 + noise(gx, gy, 31 + seed) % 3 + (gy % 2) * 2
            val y = 4 + gy * 9 + noise(gy, gx, 17 + seed) % 3
            val c = colors[(seed + (noise(gx, gy, 5 + seed) + i++) % 2 * 3) % colors.size]
            // stem with a leaf
            raw(x, y + 2, G_DD); raw(x, y + 3, G_DD); raw(x + 1, y + 3, G_D); raw(x - 1, y + 4, G_DD)
            // petals around a golden centre, with longer tips
            for (dy in -1..1) for (dx in -1..1) raw(x + dx, y + dy, c)
            raw(x, y - 2, c); raw(x - 2, y, c); raw(x + 2, y, c)
            raw(x, y, Pal.GOLD_DARK)
            raw(x - 1, y - 1, Pal.WHITE.takeIf { c != Pal.WHITE } ?: Pal.GOLD)
        }
    }

    private val TG = argb(0x46703A); private val TG_D = argb(0x34562E); private val TG_DD = argb(0x243E22); private val TG_L = argb(0x6E9050)

    private fun Pen.tallGrass(seed: Int, m: Int = 0) {
        // where the tall grass ends, short grass shows through and the clumps thin out
        grass(seed)
        for (y in 0 until T) for (x in 0 until T) {
            var edge = 99
            if (m and 1 != 0) edge = minOf(edge, y)
            if (m and 4 != 0) edge = minOf(edge, T - 1 - y)
            if (m and 8 != 0) edge = minOf(edge, x)
            if (m and 2 != 0) edge = minOf(edge, T - 1 - x)
            if (edge > 4 + noise(x, y, 61 + seed) % 4) raw(x, y, TG_D)
        }
        for (row in 0..3) for (col in 0..3) {
            val ox = col * 8 + (row % 2) * 4 - 2
            val oy = row * 8 + 1
            val atEdge = (m and 1 != 0 && row == 0) || (m and 4 != 0 && row == 3) || (m and 8 != 0 && col == 0) || (m and 2 != 0 && col == 3)
            if (atEdge && noise(row, col, 63 + seed) % 2 == 0) continue
            blades(ox, oy, seed + row * 4 + col)
        }
    }

    /** A clump of grass blades, 8 wide and 8 tall, transparent around it. */
    private fun Pen.blades(ox: Int, oy: Int, seed: Int) {
        for (i in 0 until 8) {
            val x = ox + i
            val h = 4 + (noise(i, seed, 3) % 4)
            for (y in oy + 8 - h until oy + 8) {
                val c = when {
                    y == oy + 8 - h -> if (noise(i, seed, 9) % 5 == 0) argb(0xA89A60) else TG_L
                    i % 3 == 0 -> TG_DD
                    else -> TG
                }
                raw(x, y, c)
            }
        }
    }

    /** Front blades only (transparent elsewhere), drawn over the lower half of a character standing in tall grass. */
    fun tallGrassOverlay(): PixelImage = cached("tall-overlay") {
        for (col in 0..4) blades(col * 7 - 2, 22, col + 40)
        for (col in 0..4) blades(col * 7 + 2, 25, col + 50)
    }

    private val P = argb(0x9A8462); private val P_D = argb(0x7E6A4C); private val P_L = argb(0xB29E7A)

    private fun Pen.path(m: Int, seed: Int) {
        fill(P)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 31 + seed) % 100
            if (n < 6) raw(x, y, P_D) else if (n < 10) raw(x, y, P_L)
        }
        // pebbles
        for (i in 0 until 2) {
            val x = 4 + noise(seed, i, 2) % 22; val y = 4 + noise(i, seed, 8) % 22
            raw(x, y, P_D); raw(x + 1, y, P_D); raw(x, y - 1, P_L)
        }
        border(m, G, G_D, seed)
        roundCorners(m, P, G, G_D)
    }

    /** Rounds the corners where two borders meet, so paths bend instead of stepping. */
    private fun Pen.roundCorners(m: Int, inner: Int, outer: Int, edge: Int) {
        fun corner(cx: Int, cy: Int, inX: (Int) -> Boolean, inY: (Int) -> Boolean) {
            for (y in 0 until T) for (x in 0 until T) {
                if (!inX(x) || !inY(y)) continue
                val dd = (x - cx) * (x - cx) + (y - cy) * (y - cy)
                if (dd > 121) raw(x, y, outer) else if (dd > 100) raw(x, y, edge)
            }
        }
        if (m and 1 != 0 && m and 8 != 0) corner(14, 14, { it < 14 }, { it < 14 })
        if (m and 1 != 0 && m and 2 != 0) corner(T - 15, 14, { it > T - 15 }, { it < 14 })
        if (m and 4 != 0 && m and 8 != 0) corner(14, T - 15, { it < 14 }, { it > T - 15 })
        if (m and 4 != 0 && m and 2 != 0) corner(T - 15, T - 15, { it > T - 15 }, { it > T - 15 })
    }

    private val PAVED = setOf(Tile.COBBLE, Tile.STALL, Tile.LAMP, Tile.BARREL, Tile.BENCH)
    private val COB = argb(0x8E877C); private val COB_L = argb(0xA8A094); private val COB_D = argb(0x6C665C); private val MORTAR = argb(0x484440)

    /** Cobblestones in staggered rows, with a grass border where the square ends. */
    private fun Pen.cobble(m: Int, seed: Int) {
        fill(MORTAR)
        for (row in 0 until 6) {
            val y0 = row * 6 - 1
            val shift = if (row % 2 == 0) 0 else 4
            var x0 = -shift
            var k = 0
            while (x0 < T) {
                val w = 6 + noise(row, k + seed * 5, 41) % 3
                val tone = noise(k, row, 43 + seed) % 3
                val c = when (tone) { 0 -> COB; 1 -> mix(COB, COB_D, 0.35); else -> mix(COB, COB_L, 0.4) }
                for (y in y0 + 1 until y0 + 6) for (x in x0 + 1 until x0 + w) {
                    if (x !in 0 until T || y !in 0 until T) continue
                    // rounded corners
                    val corner = (x == x0 + 1 || x == x0 + w - 1) && (y == y0 + 1 || y == y0 + 5)
                    if (!corner) raw(x, y, c)
                }
                // light on top, shade at the bottom of each stone
                for (x in x0 + 2 until x0 + w - 1) { if (x in 0 until T && y0 + 1 in 0 until T) raw(x, y0 + 1, mix(c, COB_L, 0.5)); if (x in 0 until T && y0 + 5 in 0 until T) raw(x, y0 + 5, mix(c, COB_D, 0.5)) }
                x0 += w
                k++
            }
        }
        border(m, G, G_D, seed)
    }

    /** Organic grass border on the sides in mask [m] (N=1, E=2, S=4, W=8). */
    private fun Pen.border(m: Int, c: Int, edge: Int, seed: Int) {
        for (i in 0 until T) {
            val d = 3 + noise(i, seed, 77) % 3
            if (m and 1 != 0) { for (y in 0 until d) raw(i, y, c); raw(i, d, edge) }
            if (m and 4 != 0) { for (y in T - d until T) raw(i, y, c); raw(i, T - d - 1, edge) }
            if (m and 8 != 0) { for (x in 0 until d) raw(x, i, c); raw(d, i, edge) }
            if (m and 2 != 0) { for (x in T - d until T) raw(x, i, c); raw(T - d - 1, i, edge) }
        }
    }

    private val W = argb(0x325E72); private val W_D = argb(0x264C5E); private val W_L = argb(0x82A8B4)

    private fun Pen.water(m: Int, frame: Int, inner: Int = 0) {
        fill(W)
        for (y in 0 until T) for (x in 0 until T) if ((x + y * 3) % 17 == 0) raw(x, y, W_D)
        val sh = frame * 3
        for (row in listOf(5, 14, 23)) for (x in 0 until T) {
            val p = (x + sh + row * 5) % 16
            if (p in 0..4) raw(x, row + if (p == 2) -1 else 0, W_L)
        }
        // banks: grass with a light foam line
        for (i in 0 until T) {
            if (m and 1 != 0) { for (y in 0..3) raw(i, y, G); raw(i, 4, G_DD); raw(i, 5, W_L) }
            if (m and 4 != 0) { for (y in T - 3 until T) raw(i, y, G); raw(i, T - 4, W_L) }
            if (m and 8 != 0) { for (x in 0..3) raw(x, i, G); raw(4, i, G_DD); raw(5, i, W_L) }
            if (m and 2 != 0) { for (x in T - 4 until T) raw(x, i, G); raw(T - 5, i, G_DD); raw(T - 6, i, W_L) }
        }
        // round outer corners where two banks meet
        fun round(cx: Int, cy: Int, inX: (Int) -> Boolean, inY: (Int) -> Boolean) {
            for (y in 0 until T) for (x in 0 until T) {
                if (!inX(x) || !inY(y)) continue
                val dd = (x - cx) * (x - cx) + (y - cy) * (y - cy)
                if (dd > 100) raw(x, y, G) else if (dd > 81) raw(x, y, G_DD) else if (dd > 64) raw(x, y, W_L)
            }
        }
        if (m and 1 != 0 && m and 8 != 0) round(14, 14, { it < 14 }, { it < 14 })
        if (m and 1 != 0 && m and 2 != 0) round(T - 15, 14, { it > T - 15 }, { it < 14 })
        if (m and 4 != 0 && m and 8 != 0) round(14, T - 15, { it < 14 }, { it > T - 15 })
        if (m and 4 != 0 && m and 2 != 0) round(T - 15, T - 15, { it > T - 15 }, { it > T - 15 })
        // small bites of land at inner corners
        fun bite(cx: Int, cy: Int) {
            for (y in 0 until T) for (x in 0 until T) {
                val dd = (x - cx) * (x - cx) + (y - cy) * (y - cy)
                if (dd <= 16) raw(x, y, G) else if (dd <= 25) raw(x, y, G_DD) else if (dd <= 36) raw(x, y, W_L)
            }
        }
        if (inner and 1 != 0) bite(T - 1, 0)
        if (inner and 2 != 0) bite(T - 1, T - 1)
        if (inner and 4 != 0) bite(0, T - 1)
        if (inner and 8 != 0) bite(0, 0)
    }

    /** Wooden planks across the water, with a railing on the outer sides. */
    private fun Pen.bridge(left: Boolean, right: Boolean) {
        val x0 = if (left) 3 else 0
        val x1 = if (right) T - 4 else T - 1
        for (y in 0 until T) {
            val c = if (y % 6 == 5) Pal.WOOD_DARK else if (y % 6 == 0) Pal.WOOD_LIGHT else Pal.WOOD
            for (x in x0..x1) raw(x, y, c)
            if (y % 6 == 2) { raw(x0 + 3, y, Pal.WOOD_DARK); raw(x1 - 3, y, Pal.WOOD_DARK) } // nails
        }
        if (left) { rect(0, 0, 2, T - 1, Pal.WOOD_DARK); rect(0, 0, 0, T - 1, Pal.OUTLINE); for (y in 4 until T step 10) rect(0, y, 3, y + 2, argb(0x4A2E18)) }
        if (right) { rect(T - 3, 0, T - 1, T - 1, Pal.WOOD_DARK); rect(T - 1, 0, T - 1, T - 1, Pal.OUTLINE); for (y in 4 until T step 10) rect(T - 4, y, T - 1, y + 2, argb(0x4A2E18)) }
    }

    private val SOIL = argb(0x5A4028); private val SOIL_D = argb(0x3E2C1A); private val SOIL_L = argb(0x725234)
    private val WHEAT = argb(0xB89A50); private val WHEAT_D = argb(0x8E7436); private val WHEAT_L = argb(0xCCB474)

    /** Ripe grain, dense and golden, with a few darker furrows. */
    private fun Pen.field(seed: Int) {
        fill(WHEAT_D)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 70 + seed) % 10
            raw(x, y, if (n < 5) WHEAT else if (n < 7) WHEAT_D else if (n < 8) WHEAT_L else mix(WHEAT, WHEAT_D, 0.5))
        }
        // furrows
        for (y in listOf(10, 21)) for (x in 0 until T) raw(x, y, mix(WHEAT_D, SOIL, 0.5))
        // ears of grain sticking out
        for (i in 0 until 14) {
            val x = noise(i, seed, 72) % T; val y = 2 + noise(seed, i, 73) % (T - 4)
            raw(x, y, WHEAT_L); raw(x, y + 1, WHEAT_L); raw(x, y + 2, WHEAT_D)
        }
    }

    /** A vegetable bed: dark soil with cabbages and carrot tops. */
    private fun Pen.vegBed(seed: Int) {
        fill(SOIL)
        for (y in 0 until T) for (x in 0 until T) if (noise(x, y, 80 + seed) % 7 == 0) raw(x, y, SOIL_L)
        for (row in 0 until 3) for (col in 0 until 3) {
            val cx = 6 + col * 10 + (row % 2) * 2
            val cy = 6 + row * 10
            if ((row + col + seed) % 2 == 0) {
                ellipse(cx.toDouble(), cy.toDouble(), 4.0, 3.5, argb(0x6AAE4A)); ellipse(cx.toDouble(), cy - 1.0, 2.5, 2.0, argb(0x9AD86E)); raw(cx, cy - 1, argb(0xC8F0A0))
            } else {
                for (k in -2..2) { raw(cx + k, cy - 2 - kotlin.math.abs(k), G_D); raw(cx + k, cy - 1, G) }
                raw(cx, cy + 1, argb(0xF08A2C)); raw(cx + 1, cy + 1, argb(0xF08A2C))
            }
        }
    }

    // ------------------------------------------------------------------ caves and cliffs

    private val R = argb(0x6A5A4C); private val R_D = argb(0x4A3E34); private val R_DD = argb(0x30281F); private val R_L = argb(0x8C7A66)
    private val CF = argb(0x8E7E6A); private val CF_D = argb(0x76674F); private val CF_L = argb(0xA69682)

    private fun Pen.cliffFace(seed: Int, outdoor: Boolean) {
        val base = if (outdoor) argb(0x8A7A68) else R
        val dark = if (outdoor) argb(0x6A5A4A) else R_D
        val light = if (outdoor) argb(0xAA9A86) else R_L
        fill(base)
        // horizontal strata
        for (y in listOf(9, 18, 26)) for (x in 0 until T) {
            raw(x, y + (noise(x / 4, y, seed) % 2), dark)
        }
        for (y in 0 until T) for (x in 0 until T) if (noise(x, y, 19 + seed) % 100 < 7) raw(x, y, if (y < 16) light else dark)
        // vertical cracks
        val cx = 6 + seed * 6
        for (y in 4 until 30) raw(cx + (y / 7) % 2, y, R_DD)
        // lit top rim and darker foot
        for (x in 0 until T) { raw(x, 0, light); raw(x, 1, light); raw(x, T - 1, R_DD); raw(x, T - 2, dark) }
    }

    private fun Pen.rockTop(m: Int, seed: Int) {
        fill(R_DD)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 61 + seed) % 100
            if (n < 10) raw(x, y, R_D) else if (n < 12) raw(x, y, R)
        }
        for (i in 0 until T) {
            if (m and 1 != 0) { raw(i, 0, R_L); raw(i, 1, R) }
            if (m and 8 != 0) { raw(0, i, R_L); raw(1, i, R) }
            if (m and 2 != 0) { raw(T - 1, i, R); raw(T - 2, i, R_D) }
        }
    }

    private fun Pen.caveMouth() {
        ellipse(16.0, 26.0, 12.5, 20.0, R_DD)
        ellipse(16.0, 27.0, 11.0, 18.5, Pal.BLACK)
        for (x in 6..25) if (noise(x, 1, 3) % 3 == 0) raw(x, 9 + noise(x, 2, 4) % 3, R_D)
    }

    private fun Pen.caveFloor(seed: Int, m: Int) {
        fill(CF)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 57 + seed) % 100
            if (n < 6) raw(x, y, CF_D) else if (n < 9) raw(x, y, CF_L)
        }
        if (noise(seed, 3, 1) % 2 == 0) { raw(20, 12, CF_D); raw(21, 12, CF_D); raw(20, 11, CF_L) }
        // ambient occlusion along walls
        if (m and 1 != 0) for (y in 0 until 9) for (x in 0 until T) blend(x, y, alpha(0x100808, 0x90 * (9 - y) / 9))
        if (m and 8 != 0) for (x in 0 until 5) for (y in 0 until T) blend(x, y, alpha(0x100808, 0x60 * (5 - x) / 5))
        if (m and 2 != 0) for (x in T - 5 until T) for (y in 0 until T) blend(x, y, alpha(0x100808, 0x60 * (x - T + 6) / 5))
    }

    private fun Pen.exitLight() {
        for (y in 0 until T) for (x in 0 until T) blend(x, y, alpha(0xFFF4C0, 0x18 + y * 3))
    }

    private fun Pen.torch(frame: Int) {
        rect(14, 16, 17, 26, Pal.WOOD_DARK)
        rect(12, 14, 19, 16, Pal.IRON)
        val h = frame
        ellipse(16.0, 10.0 - h, 4.5, 6.5, Pal.FIRE_DARK)
        ellipse(16.0, 11.0 - h, 3.2, 4.8, Pal.FIRE)
        ellipse(16.0, 12.0 - h, 1.8, 2.8, Pal.FIRE_LIGHT)
        for (y in 0 until T) for (x in 0 until T) {
            val d = (x - 16) * (x - 16) + (y - 12) * (y - 12)
            if (d < 180 && (img[x, y] == R || img[x, y] == R_L || img[x, y] == R_D)) blend(x, y, alpha(0xF8B040, 0x40 * (180 - d) / 180))
        }
    }

    // ------------------------------------------------------------------ cave life

    private val SHROOM = argb(0x48C8C0); private val SHROOM_L = argb(0xB8FFF4); private val SHROOM_D = argb(0x24706E)

    /** Glowing mushrooms in little clusters, each with a soft halo on the floor. */
    private fun Pen.shrooms(v: Int) {
        val clusters = listOf(
            listOf(8 to 22, 12 to 25, 6 to 27, 10 to 28),
            listOf(20 to 11, 24 to 14, 18 to 15, 23 to 18),
            listOf(9 to 12, 13 to 9, 22 to 24, 26 to 21, 19 to 27),
            listOf(15 to 18, 11 to 21, 19 to 22, 14 to 24),
        )[v]
        for ((x, y) in clusters) blendEllipse(x.toDouble(), y - 1.0, 7.0, 4.0, alpha(0x60F0E0, 0x22))
        for ((i, xy) in clusters.withIndex()) {
            val (x, y) = xy
            val r = 2.0 + (i + v) % 3 * 0.7
            for (k in 0 until 3 + i % 2) raw(x, y - k, argb(0xD0CCBC))
            raw(x, y, argb(0x8A8478))
            val top = y - 3 - i % 2
            ellipse(x + 0.5, top + 0.5, r + 0.4, r * 0.6 + 0.3, SHROOM_D)
            ellipse(x + 0.5, top.toDouble(), r, r * 0.55, SHROOM)
            raw(x - 1, top - 1, SHROOM_L); raw(x, top - 1, SHROOM_L)
        }
    }

    private val CRY = argb(0xA078E8); private val CRY_L = argb(0xE8DCFF); private val CRY_D = argb(0x5A3A9A)

    /** Violet crystals growing out of the foot of a cave wall. */
    private fun Pen.crystals(seed: Int) {
        blendEllipse(16.0, 26.0, 14.0, 7.0, alpha(0xB090FF, 0x30))
        val shards = listOf(Triple(9, 13, -3), Triple(15, 19, 0), Triple(21, 11, 3), Triple(12, 9, -6), Triple(24, 8, 6))
        for ((i, sh) in shards.withIndex()) {
            if (i == 4 && seed % 2 == 0) continue
            val (bx, len, lean) = sh
            val by = 30
            val tipX = bx + lean; val tipY = by - len
            tri(bx - 2, by, bx, by, tipX, tipY, CRY_L)
            tri(bx, by, bx + 2, by, tipX, tipY, CRY_D)
            line(bx, by - 1, tipX, tipY + 1, CRY)
        }
        for (x in 4..28) if (noise(x, 31, seed) % 3 == 0) raw(x, 31, R_DD)
    }

    /** A stalagmite rising from the floor: ringed, lit from the left, wet at the tip. */
    private fun Pen.stalagmite(seed: Int) {
        val hgt = 34 + seed * 3
        val base = 47
        for (y in base - hgt..base) {
            val t = (base - y) / hgt.toDouble()
            val half = 1.0 + 9.0 * Math.pow(1 - t, 1.1)
            val ring = (y + seed) % 6 == 0
            for (x in (16 - half).toInt()..(16 + half).toInt()) {
                val u = (x - 16) / half
                val c = when {
                    u < -0.45 -> R_L
                    u > 0.4 -> R_DD
                    else -> R
                }
                raw(x, y, if (ring && u > -0.6) R_D else c)
            }
        }
        raw(16, base - hgt, argb(0xC8D8E0)); raw(15, base - hgt + 1, argb(0xA8B8C0))
    }

    /** Small things on the forest floor near trees: a fern, a few mushrooms or fallen leaves. */
    private fun Pen.forestFloor(v: Int) {
        when (v) {
            0 -> { // fern: fronds from one point
                val bx = 10 + noise(v, 1, 5) % 12; val by = 24
                for (f in 0 until 5) {
                    val ang = -Math.PI / 2 + (f - 2) * 0.45
                    for (k in 0 until 9) {
                        val x = bx + (Math.cos(ang) * k).toInt(); val y = by + (Math.sin(ang) * k).toInt() + k * k / 14
                        raw(x, y, if (f < 2) argb(0x5A8040) else argb(0x3A5A2C))
                        if (k % 2 == 0) { raw(x - 1, y + 1, argb(0x46682E)); raw(x + 1, y + 1, argb(0x2E4A24)) }
                    }
                }
            }
            1 -> for ((mx, my) in listOf(9 to 20, 13 to 23, 22 to 14)) { // brown mushrooms
                raw(mx, my, argb(0xD8CCB0)); raw(mx, my - 1, argb(0xD8CCB0))
                for (dx in -2..2) raw(mx + dx, my - 2, if (dx < 0) argb(0xA87A50) else argb(0x7A5434))
                for (dx in -1..1) raw(mx + dx, my - 3, argb(0xB88A5A))
            }
            else -> for (k in 0 until 7) { // fallen leaves
                val x = 4 + noise(k, 3, 7) % 24; val y = 4 + noise(3, k, 7) % 24
                val c = listOf(argb(0x8A5A26), argb(0xA87A30), argb(0x6A4A22))[k % 3]
                raw(x, y, c); raw(x + 1, y, c); raw(x, y + 1, mix(c, Pal.BLACK, 0.3))
            }
        }
    }

    /** Lily pads on open water and reeds along the banks of forest ponds. */
    private fun Pen.pondLife(m: Int, seed: Int) {
        if (m == 0 && seed % 2 == 0) for ((lx, ly) in listOf(10 to 12, 20 to 20)) {
            ellipse(lx.toDouble(), ly.toDouble(), 3.5, 2.5, argb(0x3E6A34))
            raw(lx, ly, argb(0x325E72)); raw(lx + 1, ly - 1, argb(0x325E72))
            raw(lx - 2, ly - 1, argb(0x5A8848))
            if (seed == 0 && lx == 10) { raw(lx - 1, ly - 2, argb(0xE8D8E0)); raw(lx, ly - 3, argb(0xF0E4EC)) }
        }
        if (m and 5 != 0) for (k in 0 until 6) {
            val x = 4 + k * 5 + noise(k, seed, 11) % 3
            val y0 = if (m and 1 != 0) 8 else 26
            val len = 5 + noise(seed, k, 13) % 5
            for (t in 0 until len) raw(x, y0 - t, if (t == len - 1) argb(0x6A4A2A) else argb(0x4E6A34))
        }
    }

    /** A fallen trunk lying across the ground, mossy on top; [leftEnd]/[rightEnd] show the cut or broken end. */
    private fun Pen.log(leftEnd: Boolean, rightEnd: Boolean) {
        val bark = argb(0x4E3A2A); val barkL = argb(0x6A5038); val barkD = argb(0x2E2218); val moss = argb(0x4E6A30); val mossL = argb(0x6A8A40)
        blendEllipse(16.0, 28.0, 17.0, 3.5, SHADOW)
        val x0 = if (leftEnd) 3 else 0; val x1 = if (rightEnd) 28 else T - 1
        for (x in x0..x1) for (y in 13..27) {
            val u = (y - 20) / 7.0
            var c = when {
                u < -0.6 -> barkL
                u > 0.55 -> barkD
                else -> bark
            }
            if ((x * 7 + y * 3) % 11 == 0) c = barkD
            if (u < -0.35 && noise(x, y, 81) % 3 != 0) c = if (u < -0.75) mossL else moss
            raw(x, y, c)
        }
        fun end(cx: Int) {
            for (y in 13..27) for (x in cx - 3..cx + 3) {
                val d = Math.sqrt(((x - cx) / 3.2).let { it * it } + ((y - 20) / 7.2).let { it * it })
                if (d > 1) continue
                raw(x, y, if ((d * 4).toInt() % 2 == 0) argb(0x9A7A52) else argb(0x7A5E3E))
            }
            raw(cx, 20, argb(0x5A4430))
        }
        if (leftEnd) end(x0 + 1)
        if (rightEnd) {
            // broken end: splinters
            for (k in 0 until 5) line(x1, 14 + k * 3, x1 + 2 + k % 2 * 2, 13 + k * 3, barkL)
        }
        if (!leftEnd && !rightEnd) for (k in 0 until 3) raw(10 + k * 6, 12, moss)
    }

    /** A weathered standing stone, mossy at the foot, with a faded carving. */
    private fun Pen.menhir(seed: Int) {
        val st = argb(0x7A7870); val stL = argb(0x9A988E); val stD = argb(0x4E4C48); val moss = argb(0x4E6A30)
        blendEllipse(16.0, 49.0, 11.0, 3.5, SHADOW)
        val top = 6 + seed * 2
        for (y in top..49) {
            val t = (y - top) / (49.0 - top)
            val half = 6.5 + 2.5 * t - (if (y < top + 4) (top + 4 - y) * 1.2 else 0.0)
            for (x in (16 - half).toInt()..(16 + half).toInt()) {
                val u = (x - 16) / half
                var c = if (u < -0.4) stL else if (u > 0.45) stD else st
                if (noise(x, y, 91 + seed) % 13 == 0) c = stD
                if (y > 40 && noise(x / 2, y, 93) % 3 != 0) c = moss
                raw(x, y, c)
            }
        }
        // a faded spiral carving
        for (k in 0 until 14) {
            val a = k * 0.7; val r = 1 + k * 0.28
            raw((16 + Math.cos(a) * r).toInt(), (24 + Math.sin(a) * r).toInt(), stD)
        }
        outline(Pal.OUTLINE)
    }

    /** Loose stones of different sizes. */
    private fun Pen.rubble(v: Int) {
        val stones = listOf(Triple(8, 20, 4), Triple(14, 24, 3), Triple(22, 15, 5), Triple(25, 25, 2), Triple(11, 10, 2), Triple(18, 28, 2))
        for ((i, st) in stones.withIndex()) {
            if ((i + v) % 4 == 3) continue
            val (x, y, r) = st
            blendEllipse(x + 0.5, y + r * 0.6, r + 1.0, r * 0.45, SHADOW)
            ball(x.toDouble(), y.toDouble(), r.toDouble(), r * 0.75, R, R_L, R_DD)
        }
    }

    /** A skull and some gnawed bones. */
    private fun Pen.bones(v: Int) {
        val bone = argb(0xD8D0BC); val boneD = argb(0x9A9282)
        val sx = if (v == 0) 10 else 21; val sy = if (v == 0) 14 else 22
        ellipse(sx.toDouble(), sy.toDouble(), 4.0, 3.5, bone)
        rect(sx - 2, sy + 2, sx + 2, sy + 4, bone)
        raw(sx - 2, sy, argb(0x2A2420)); raw(sx - 1, sy, argb(0x2A2420)); raw(sx + 1, sy, argb(0x2A2420)); raw(sx + 2, sy, argb(0x2A2420))
        raw(sx - 3, sy - 2, argb(0xF4ECDC))
        for ((x0, y0, x1, y1) in listOf(listOf(4, 25, 13, 21), listOf(18, 8, 27, 12), listOf(15, 27, 24, 25))) {
            line(x0, y0, x1, y1, bone); line(x0, y0 + 1, x1, y1 + 1, boneD)
            raw(x0 - 1, y0, bone); raw(x1 + 1, y1, bone)
        }
    }

    /** A rolled-out fur and blanket somebody sleeps on. */
    private fun Pen.bedroll() {
        val fur = argb(0x7A6650); val furL = argb(0x9A866A); val cloth = argb(0x6A3A2A); val clothL = argb(0x8A5038)
        blendEllipse(16.0, 24.0, 14.0, 6.0, SHADOW)
        for (y in 9..25) for (x in 5..26) {
            val edge = x == 5 || x == 26 || y == 9 || y == 25
            raw(x, y, if (edge) fur else if (y < 15) (if ((x + y) % 3 == 0) furL else fur) else if ((x / 3 + y / 3) % 2 == 0) cloth else clothL)
        }
        ellipse(10.0, 12.0, 4.0, 2.5, argb(0xB0A080))
    }

    /** Old timbers propping up the passage: a post on the wall side and a beam overhead. */
    private fun Pen.support(left: Boolean, right: Boolean) {
        val wood = argb(0x6A4A30); val woodL = argb(0x8A6440); val woodD = argb(0x3E2A1C)
        fun post(x0: Int) {
            for (y in 2..46) for (x in x0 until x0 + 5) raw(x, y, if (x == x0) woodL else if (x == x0 + 4) woodD else if (y % 9 == 0) woodD else wood)
            blendEllipse(x0 + 2.5, 46.0, 5.0, 2.0, SHADOW)
        }
        for (y in 0..5) for (x in 0 until T) raw(x, y, if (y == 0) woodL else if (y == 5) woodD else if ((x + 3) % 11 == 0) woodD else wood)
        if (left) post(1)
        if (right) post(T - 6)
    }

    /** A wooden crate, some with a sack leaning against it. */
    private fun Pen.crate(sack: Boolean) {
        val wood = argb(0x8A6038); val woodL = argb(0xA87A48); val woodD = argb(0x5A3C22)
        blendEllipse(16.0, 37.0, 14.0, 4.0, SHADOW)
        rect(5, 14, 25, 37, wood)
        rect(5, 10, 25, 14, woodL)
        for (x in 5..25) { raw(x, 14, woodD); raw(x, 37, woodD) }
        for (y in 10..37) { raw(5, y, woodD); raw(25, y, woodD); raw(15, y, woodD) }
        line(6, 36, 14, 15, woodD); line(16, 36, 24, 15, woodD)
        if (sack) {
            ellipse(26.0, 31.0, 5.0, 6.5, argb(0xA08A5E))
            ellipse(25.0, 29.0, 3.0, 4.0, argb(0xBCA678))
            rect(25, 23, 27, 25, argb(0x6A5A3A))
        }
    }

    /** Daylight on the floor under a crack in the roof, with a little moss that grows in it. */
    private fun Pen.skylight(seed: Int) {
        blendEllipse(16.0, 16.0, 15.0, 12.0, alpha(0xFFF8E0, 0x30))
        blendEllipse(16.0, 16.0, 10.0, 8.0, alpha(0xFFF8E0, 0x30))
        for (k in 0 until 9) {
            val x = 6 + noise(k, 1, seed) % 20; val y = 6 + noise(k, 2, seed) % 20
            raw(x, y, argb(0x5A7A3A)); raw(x + 1, y, argb(0x4A6A30)); if (k % 3 == 0) raw(x, y - 1, argb(0x7A9A4A))
        }
    }

    /** Recolours outdoor water for a cave: dark water, stone banks instead of grass. */
    private fun Pen.caveWater() {
        for (y in 0 until T) for (x in 0 until T) {
            val c = img[x, y]
            img.set(x, y, when (c) {
                G, G_L -> CF
                G_D, G_DD -> CF_D
                W -> argb(0x24404E)
                W_D -> argb(0x1A3040)
                W_L -> argb(0x6A98A8)
                else -> mix(c, argb(0x24404E), 0.5)
            })
        }
    }

    // ------------------------------------------------------------------ interiors

    private val FL = argb(0xD6A66A); private val FL_D = argb(0xB4864C); private val FL_L = argb(0xE6BC84)

    private fun Pen.woodFloor(seed: Int) {
        fill(FL)
        for (y in 0 until T step 8) {
            for (x in 0 until T) raw(x, y + 7, FL_D)
            val off = if ((y / 8) % 2 == 0) 6 + seed * 2 else 20 - seed
            for (yy in y until y + 7) raw(off, yy, FL_D)
            for (x in 0 until T) if (noise(x, y, seed) % 9 == 0) raw(x, y + 3, FL_L)
        }
    }

    private fun Pen.doormat() {
        rect(4, 6, 27, 31, argb(0x8A2E3C))
        rect(6, 8, 25, 29, argb(0xA83A48))
        for (x in 8..23 step 3) raw(x, 18, Pal.RUG_LIGHT)
        // arrow pointing out
        tri(11, 22, 21, 22, 16, 28, Pal.RUG_LIGHT)
    }

    private fun Pen.interiorWallFace(variant: Int) {
        val paper = argb(0xE8D2A4); val paperD = argb(0xD4BA88)
        fill(paper)
        for (x in 0 until T step 8) for (y in 0 until 20) if ((y + x / 8) % 4 == 0) raw(x + 3, y, paperD)
        rect(0, 0, 31, 2, Pal.BEAM)
        rect(0, 20, 31, 29, Pal.WOOD)
        for (x in 0 until T step 8) rect(x, 20, x, 29, Pal.WOOD_DARK)
        rect(0, 20, 31, 20, Pal.WOOD_LIGHT)
        rect(0, 30, 31, 31, Pal.WOOD_DARK)
        when (variant) {
            1 -> { // window
                rect(8, 5, 23, 17, Pal.BEAM); rect(10, 7, 21, 15, Pal.GLASS)
                rect(15, 7, 16, 15, Pal.BEAM); rect(10, 11, 21, 11, Pal.BEAM)
                raw(11, 8, Pal.WHITE); raw(12, 8, Pal.WHITE); raw(11, 9, Pal.WHITE)
            }
            2 -> { // little picture
                rect(10, 6, 21, 15, Pal.GOLD_DARK); rect(11, 7, 20, 14, argb(0x7AB0D8))
                rect(11, 12, 20, 14, argb(0x5A9A50)); ellipse(17.0, 10.0, 2.0, 2.0, Pal.FIRE_LIGHT)
            }
        }
    }

    private fun Pen.interiorWallTop() {
        fill(argb(0x5A3A24))
        for (x in 0 until T) { raw(x, 0, argb(0x7A5034)); raw(x, T - 1, argb(0x3A2414)) }
    }

    private fun Pen.rug(m: Int) {
        val c = argb(0xB83A48); val d = argb(0x8E2A38)
        fill(c)
        for (y in 0 until T) for (x in 0 until T) if ((x + y) % 8 == 0 && (x / 8 + y / 8) % 2 == 0) raw(x, y, d)
        for (i in 0 until T) {
            if (m and 1 != 0) { raw(i, 0, d); raw(i, 1, Pal.RUG_LIGHT); raw(i, 3, d) }
            if (m and 4 != 0) { raw(i, T - 1, d); raw(i, T - 2, Pal.RUG_LIGHT); raw(i, T - 4, d) }
            if (m and 8 != 0) { raw(0, i, d); raw(1, i, Pal.RUG_LIGHT); raw(3, i, d) }
            if (m and 2 != 0) { raw(T - 1, i, d); raw(T - 2, i, Pal.RUG_LIGHT); raw(T - 4, i, d) }
        }
        if (m == 0) { raw(15, 15, Pal.RUG_LIGHT); raw(16, 16, Pal.RUG_LIGHT); raw(15, 16, Pal.RUG_LIGHT); raw(16, 15, Pal.RUG_LIGHT) }
    }

    // ================================================================== object layer

    private val objCache = HashMap<String, List<Obj>>()

    /** All static objects of a map for the current game state, in no particular order. */
    fun objects(map: MapDef, state: GameState, frame: Int, flicker: Int = 0): List<Obj> {
        val opened = map.chests.filter { it.id in state.openedChests }.joinToString(",") { it.id }
        val key = "${map.id}/$opened/${state.has(Story.GATE_OPEN)}/${state.has(Story.BARRIER_OPEN)}/$frame/${state.has(Story.CHAPTER1_DONE)}/${MapGround.townDraft}/${MapFigure.viewYaw != 0.0}/$flicker"
        return objCache.getOrPut(key) { buildObjects(map, state, frame, flicker) }
    }

    private fun buildObjects(map: MapDef, state: GameState, frame: Int, flicker: Int = 0): List<Obj> {
        val out = mutableListOf<Obj>()
        val seen = HashSet<Pair<Int, Int>>()
        // the woods have new, finer trees, rocks and stones, and undergrowth
        val fine = MapGround.supports(map)
        val cave = map.kind == MapKind.CAVE
        if (fine && !cave && map.kind != MapKind.INTERIOR) out += MapFlora.undergrowth(map)
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val open = map.chestAt(tx, ty)?.id in state.openedChests
            val flora = when {
                !fine -> null
                cave -> MapCave.objects(map, tx, ty, frame, open, state.has(Story.GATE_OPEN))
                // the village in the new style (draft): houses and things, else the trees of the woods
                map.kind == MapKind.TOWN -> MapTown.objects(map, tx, ty) ?: MapFlora.objects(map, tx, ty, frame, open)
                // seen diagonally (13), the rooms' walls and furniture stand upright, turned with the room
                map.kind == MapKind.INTERIOR && MapFigure.viewYaw != 0.0 -> MapRoomIso.objects(map, tx, ty, flicker) ?: MapRoom.objects(map, tx, ty, frame)
                map.kind == MapKind.INTERIOR -> MapRoom.objects(map, tx, ty, frame)
                else -> MapFlora.objects(map, tx, ty, frame, open)
            }
            if (flora != null) { out += flora; continue }
            val t = map.tile(tx, ty)
            val px = tx * T
            val py = ty * T
            val bottom = py + T - 1
            val seed = Math.floorMod(tx * 7 + ty * 13, 4)
            when (t) {
                Tile.TREE -> {
                    // mostly leafy trees, some pines; in the deep forest old gnarled ones
                    val v = Math.floorMod(tx * 5 + ty * 11 + tx * ty, 7)
                    val deep = map.id == "deep_forest"
                    val kind = when {
                        deep && v % 3 == 0 -> TreeKind.GNARLED
                        map.kind == MapKind.FOREST && v >= 5 -> TreeKind.PINE
                        else -> TreeKind.LEAFY
                    }
                    out += Obj(mapTree(kind, v % 4, deep), px - 6, py - 24, bottom)
                }
                Tile.ROCK -> out += Obj(cached("rock") { rock() }, px, py, bottom)
                Tile.SIGN -> out += Obj(cached("sign") { sign() }, px, py, bottom)
                Tile.CHEST -> {
                    val open = map.chestAt(tx, ty)?.id in state.openedChests
                    out += Obj(cached("chest$open") { chest(open) }, px, py, bottom)
                }
                Tile.WELL -> out += Obj(cached("well", T, 48) { well() }, px, py - 16, bottom)
                Tile.CAMPFIRE -> out += Obj(cached("fire$frame") { campfire(frame) }, px, py, bottom)
                Tile.LOG -> {
                    val l = map.tile(tx - 1, ty) == Tile.LOG; val r = map.tile(tx + 1, ty) == Tile.LOG
                    out += Obj(cached("log$l$r") { log(!l, !r) }, px, py, bottom)
                }
                Tile.MENHIR -> out += Obj(cached("menhir$seed", T, 52) { menhir(seed) }, px, py - 20, bottom)
                Tile.STALAGMITE -> out += Obj(cached("stalagmite$seed", T, 48) { stalagmite(seed) }, px, py - 16, bottom)
                Tile.CRATE -> out += Obj(cached("crate${seed % 2}", T, 40) { crate(seed % 2 == 1) }, px, py - 8, bottom)
                Tile.SUPPORT -> {
                    val left = map.tile(tx - 1, ty) == Tile.CAVE_WALL; val right = map.tile(tx + 1, ty) == Tile.CAVE_WALL
                    out += Obj(cached("support$left$right", T, 48) { support(left, right) }, px, py - 16, bottom)
                }
                Tile.GATE -> if (!state.has(Story.GATE_OPEN)) out += Obj(cached("gate", T, 44) { gate() }, px, py - 12, bottom)
                Tile.COUNTER -> {
                    fun c(dx: Int) = map.tile(tx + dx, ty) == Tile.COUNTER
                    out += Obj(cached("counter${c(-1)}${c(1)}", T, 40) { counter(c(-1), c(1)) }, px, py - 8, bottom)
                }
                Tile.TABLE -> out += Obj(cached("table$seed", T, 36) { table(seed) }, px, py - 4, bottom)
                Tile.BED -> out += Obj(cached("bed", T, 40) { bed() }, px, py - 8, bottom)
                Tile.SHELF -> out += Obj(cached("shelf$seed", T, 56) { shelf(seed) }, px, py - 24, bottom)
                Tile.PLANT -> out += Obj(cached("plant", T, 40) { plant() }, px, py - 8, bottom)
                Tile.ALTAR -> {
                    fun a(dx: Int) = map.tile(tx + dx, ty) == Tile.ALTAR
                    val lit = state.has(Story.CHAPTER1_DONE)
                    out += Obj(cached("altar${a(-1)}${a(1)}$lit", T, 44) { altar(a(-1), a(1), lit) }, px, py - 12, bottom)
                }
                Tile.ROOF, Tile.ROOF_BLUE, Tile.WALL, Tile.WINDOW, Tile.DOOR -> {
                    if (map.kind == MapKind.TOWN && (tx to ty) !in seen) building(map, tx, ty, seen)?.let { out += it }
                }
                Tile.STALL -> out += Obj(cached("stall$seed", T, 48) { stall(seed) }, px, py - 16, bottom)
                Tile.LAMP -> out += Obj(cached("lamp", T, 56) { lamp() }, px, py - 24, bottom)
                Tile.BARREL -> out += Obj(cached("barrel", T, 36) { barrel() }, px, py - 4, bottom)
                Tile.BENCH -> out += Obj(cached("bench", T, T) { bench() }, px, py, bottom)
                Tile.FENCE -> {
                    fun f(dx: Int, dy: Int) = map.tile(tx + dx, ty + dy) == Tile.FENCE
                    out += Obj(cached("fence${f(-1, 0)}${f(1, 0)}${f(0, -1)}${f(0, 1)}", T, 40) { fence(f(-1, 0), f(1, 0), f(0, -1), f(0, 1)) }, px, py - 8, bottom)
                }
                Tile.HAY -> out += Obj(cached("hay$seed", T, 36) { hay(seed) }, px, py - 4, bottom)
                Tile.BARRIER -> {
                    val pivot = map.tile(tx - 1, ty) != Tile.BARRIER
                    val open = state.has(Story.BARRIER_OPEN)
                    out += Obj(cached("barrier$pivot$open", T, 64) { barrier(pivot, open) }, px, py - 32, bottom)
                }
                Tile.WASHLINE -> {
                    fun w(dx: Int) = map.tile(tx + dx, ty) == Tile.WASHLINE
                    out += Obj(cached("washline${w(-1)}${w(1)}$seed", T, 48) { washline(w(-1), w(1), seed) }, px, py - 16, bottom)
                }
                else -> {}
            }
        }
        return out
    }

    // ------------------------------------------------------------------ objects: nature

    private val LEAF = argb(0x3A6438); private val LEAF_D = argb(0x2A4C2C); private val LEAF_DD = argb(0x1C3420); private val LEAF_L = argb(0x5A8248)

    /** 32×50 tree whose crown reaches up into the tile above. */
    fun tree(seed: Int, pine: Boolean): PixelImage = cached("tree$seed$pine", T, 50) {
        // trunk
        rect(13, 34, 18, 47, Pal.TRUNK)
        rect(16, 34, 18, 47, Pal.WOOD_DARK)
        raw(12, 47, Pal.TRUNK); raw(19, 47, Pal.WOOD_DARK); raw(11, 48, Pal.TRUNK); raw(20, 48, Pal.WOOD_DARK)
        if (pine) {
            for ((i, top) in listOf(2, 11, 20).withIndex()) {
                val half = 8 + i * 3
                tri(16 - half, top + 16, 16 + half, top + 16, 16, top, LEAF_D)
                tri(16 - half + 2, top + 14, 16, top + 14, 16, top + 2, LEAF)
                for (x in 16 - half until 16 + half) if (noise(x, top, 5) % 4 == 0) raw(x, top + 15, LEAF_DD)
            }
        } else {
            ellipse(16.0, 19.0, 15.5, 16.0, LEAF_DD)
            ellipse(16.0, 18.0, 14.5, 15.0, LEAF_D)
            ellipse(15.0, 16.0, 12.0, 12.5, LEAF)
            // clumps and highlights
            for ((cx, cy) in listOf(9 to 12, 20 to 10, 14 to 6, 22 to 20, 8 to 22)) {
                ellipse(cx.toDouble(), cy.toDouble(), 5.0, 4.5, LEAF)
                ellipse(cx - 1.0, cy - 1.5, 2.6, 2.0, LEAF_L)
            }
            for (y in 0 until 36) for (x in 0 until T) {
                if (img[x, y] == LEAF && noise(x, y, 21 + seed) % 11 == 0) raw(x, y, LEAF_D)
                if (img[x, y] == LEAF_D && x + y > 34 && noise(x, y, 23) % 5 == 0) raw(x, y, LEAF_DD)
            }
            if (seed == 1) { raw(10, 20, Pal.RED); raw(21, 14, Pal.RED); raw(18, 24, Pal.RED) } // apples
        }
        outline(Pal.OUTLINE)
    }

    enum class TreeKind { LEAFY, PINE, GNARLED }

    /** Leaf tones from lit to deep shadow, per kind of wood. */
    private fun leafRamp(kind: TreeKind, deep: Boolean): IntArray = when {
        kind == TreeKind.PINE -> intArrayOf(argb(0x5A7A56), argb(0x3E5E46), argb(0x2C4636), argb(0x1C3026), argb(0x111E18))
        deep -> intArrayOf(argb(0x4E6E3E), argb(0x38552F), argb(0x284026), argb(0x1A2C1A), argb(0x101A12))
        else -> intArrayOf(argb(0x6A8C48), argb(0x4C6E38), argb(0x36542C), argb(0x243C20), argb(0x152416))
    }

    /**
     * A tree for the map, 44 × 56 with its foot at the bottom middle: a lit, clumpy crown with a
     * deep shadow underneath, a barked trunk and roots. Pines in tiers, gnarled old trees with
     * hanging moss in the deep forest.
     */
    fun mapTree(kind: TreeKind, v: Int, deep: Boolean): PixelImage = cached("maptree/$kind/$v/$deep", 44, 56) {
        val ramp = leafRamp(kind, deep)
        val barkL = argb(0x6A5038); val bark = argb(0x4A3828); val barkD = argb(0x2C2018)
        val outline = argb(0x0E1610)
        val cx = 22
        // roots and trunk
        val trunkW = if (kind == TreeKind.GNARLED) 5 else 3
        val trunkTop = if (kind == TreeKind.PINE) 40 else 32
        for (y in trunkTop..53) {
            val flare = if (y > 49) (y - 49) else 0
            val bend = if (kind == TreeKind.GNARLED) (Math.sin(y / 4.0 + v) * 1.5).toInt() else 0
            for (x in cx - trunkW - flare + bend..cx + trunkW + flare + bend) {
                val u = (x - (cx + bend)) / (trunkW + flare + 0.5)
                var c = if (u < -0.4) barkL else if (u > 0.35) barkD else bark
                if ((x * 3 + y) % 7 == 0 && u > -0.6) c = barkD
                raw(x, y, c)
            }
        }
        if (kind == TreeKind.GNARLED) { raw(cx - 2, 40, barkD); raw(cx - 1, 40, barkD); raw(cx - 2, 41, argb(0x1A120C)); raw(cx + 2, 46, barkD) }
        for (k in 0..2) { // roots
            val dir = k - 1
            for (t in 0..5) raw(cx + dir * (trunkW + 1 + t), 53 - (if (t < 2) 1 else 0) + (if (t > 3) 1 else 0), if (dir < 0) barkL else barkD)
        }
        // the crown: overlapping clumps, lit from the upper left
        val clumps = when (kind) {
            TreeKind.PINE -> emptyList()
            TreeKind.GNARLED -> listOf(Triple(14.0, 20.0, 10.0), Triple(28.0, 16.0, 11.0), Triple(22.0, 9.0, 9.0), Triple(9.0, 28.0, 7.0), Triple(34.0, 27.0, 8.0), Triple(22.0, 25.0, 10.0))
            else -> listOf(Triple(22.0, 17.0, 13.0), Triple(13.0, 23.0, 9.5), Triple(31.0, 22.0, 10.0), Triple(17.0, 9.0, 8.5), Triple(28.0, 10.0, 8.0), Triple(22.0, 28.0, 9.0))
        }.mapIndexed { i, c -> Triple(c.first + ((v + i) % 3 - 1) * 1.5, c.second + ((v * 2 + i) % 3 - 1), c.third - (if ((v + i) % 4 == 0) 1.5 else 0.0)) }
        if (kind == TreeKind.PINE) {
            val tiers = 5
            for (t in 0 until tiers) {
                val top = 2 + t * 8.0; val bot = top + 13; val half = 5 + t * 3.4
                for (y in top.toInt()..bot.toInt()) {
                    val q = (y - top) / (bot - top)
                    val hw = half * q + 1
                    for (x in (cx - hw).toInt()..(cx + hw).toInt()) {
                        val jag = (x + y * 2 + t) % 3 == 0 && q > 0.85
                        if (jag) continue
                        val u = (x - cx) / hw
                        val l = 0.3 + u * 0.45 + q * 0.35 + (noise(x, y, 33 + v) % 10) / 40.0
                        raw(x, y, ramp[(l * 4).toInt().coerceIn(0, 4)])
                    }
                }
            }
        } else for (y in 0 until 44) for (x in 0 until 44) {
            var best = 9.0; var bnx = 0.0; var bny = 0.0
            for ((ox, oy, r) in clumps) {
                val dx = (x + 0.5 - ox) / r; val dy = (y + 0.5 - oy) / r
                val d = dx * dx + dy * dy
                if (d < best) { best = d; bnx = dx; bny = dy }
            }
            // ragged leafy edge
            if (best > 1.0 + ((noise(x, y, 41 + v) % 10) - 4) * 0.035) continue
            var l = 0.35 + (bnx * 0.45 + bny * 0.55) * 0.5 + y / 44.0 * 0.4
            // leaf texture: small light and dark flecks in clusters of two
            val n = noise(x / 2, y / 2, 47 + v) % 12
            if (n == 0) l -= 0.25 else if (n == 1) l += 0.22
            raw(x, y, ramp[(l * 4).toInt().coerceIn(0, 4)])
        }
        // hanging moss on old trees
        if (kind == TreeKind.GNARLED) for (k in 0 until 5) {
            val x = 8 + k * 7 + v % 3; val len = 4 + (k + v) % 4
            for (t in 0 until len) if (img[x, 28 + t] != 0) raw(x, 30 + t, argb(0x6A7A4A))
        }
        outline(outline)
    }

    private fun Pen.rock() {
        val st = argb(0x7E7C74); val stL = argb(0x9E9B90); val stD = argb(0x52504A)
        ellipse(16.0, 21.0, 12.5, 9.5, stD)
        ball(15.0, 19.5, 11.5, 8.5, st, stL, stD)
        ellipse(21.0, 23.0, 5.0, 4.0, stD)
        raw(12, 18, stD); raw(13, 19, stD); raw(14, 20, stD)
        // moss on the shaded foot
        for (y in 20..28) for (x in 6..26) if (img[x, y] == stD && noise(x, y, 97) % 3 != 0) raw(x, y, argb(0x4E6A30))
        outline(Pal.OUTLINE)
    }

    private fun Pen.sign() {
        rect(14, 18, 17, 29, Pal.WOOD_DARK)
        rect(4, 5, 27, 19, Pal.WOOD)
        rect(4, 5, 27, 6, Pal.WOOD_LIGHT)
        rect(4, 18, 27, 19, Pal.WOOD_DARK)
        for (y in listOf(9, 12, 15)) rect(8, y, 8 + 12 + (y % 5), y, Pal.WOOD_DARK)
        outline(Pal.OUTLINE)
    }

    private fun Pen.chest(open: Boolean) {
        val wood = argb(0xB0702E); val woodD = argb(0x84501E); val woodL = argb(0xD0904A)
        if (!open) {
            rect(4, 8, 27, 15, woodL) // lid top
            rect(4, 15, 27, 28, wood) // front
            rect(4, 15, 27, 16, woodD)
            rect(4, 8, 27, 8, Pal.WHITE.let { mix(woodL, it, 0.4) })
            for (x in listOf(7, 24)) rect(x, 8, x + 1, 28, Pal.GOLD_DARK)
            rect(14, 14, 17, 19, Pal.GOLD); raw(15, 17, Pal.OUTLINE)
        } else {
            rect(4, 2, 27, 8, woodD) // lid flipped up
            rect(4, 9, 27, 14, Pal.BLACK)
            rect(4, 15, 27, 28, wood)
            rect(4, 15, 27, 16, woodD)
            for (x in listOf(7, 24)) { rect(x, 2, x + 1, 8, Pal.GOLD_DARK); rect(x, 15, x + 1, 28, Pal.GOLD_DARK) }
        }
        outline(Pal.OUTLINE)
    }

    private fun Pen.well() {
        // roof on two posts
        rect(4, 6, 5, 30, Pal.WOOD_DARK); rect(26, 6, 27, 30, Pal.WOOD_DARK)
        tri(0, 8, 31, 8, 16, 0, Pal.ROOF)
        tri(4, 8, 27, 8, 16, 2, mix(Pal.ROOF, Pal.WHITE, 0.15))
        rect(15, 8, 16, 20, argb(0x8A7050)) // rope
        rect(13, 20, 18, 23, Pal.WOOD) // bucket
        // stone ring: top opening and front face
        ellipse(16.0, 30.0, 14.0, 5.5, Pal.STONE_LIGHT)
        ellipse(16.0, 30.0, 10.5, 3.6, Pal.WATER_DARK)
        rect(2, 30, 29, 42, Pal.STONE)
        for (y in listOf(34, 38)) for (x in 2..29) raw(x, y, Pal.STONE_DARK)
        for (x in 2..29 step 6) { raw(x + (if ((x / 6) % 2 == 0) 0 else 3), 31, Pal.STONE_DARK); raw(x + 3, 35, Pal.STONE_DARK); raw(x, 39, Pal.STONE_DARK) }
        ellipse(16.0, 42.0, 13.5, 3.0, Pal.STONE_DARK)
        outline(Pal.OUTLINE)
    }

    private fun Pen.campfire(frame: Int) {
        // stones
        for (i in 0 until 7) {
            val x = 6 + i * 3.4
            ellipse(x, 26.0 + (if (i % 2 == 0) 0 else 1), 2.4, 2.0, Pal.STONE)
        }
        thickLine(8, 24, 22, 19, Pal.TRUNK)
        thickLine(9, 19, 23, 24, Pal.WOOD_DARK)
        val h = frame * 2
        ellipse(16.0, 14.0 - h, 7.0, 10.0, Pal.FIRE_DARK)
        ellipse(16.0, 16.0 - h, 5.0, 7.5, Pal.FIRE)
        ellipse(16.0, 18.0 - h, 2.6, 4.2, Pal.FIRE_LIGHT)
        raw(11, 5 - h, Pal.FIRE); raw(21, 7 + h, Pal.FIRE_LIGHT)
        outline(Pal.OUTLINE)
    }

    private fun Pen.gate() {
        for (x in 3 until T step 6) {
            rect(x, 2, x + 1, 43, Pal.IRON)
            raw(x, 2, Pal.IRON_LIGHT); raw(x, 1, Pal.IRON_LIGHT)
            rect(x, 3, x, 43, Pal.IRON_LIGHT)
        }
        rect(0, 10, 31, 12, Pal.IRON); rect(0, 10, 31, 10, Pal.IRON_LIGHT)
        rect(0, 32, 31, 34, Pal.IRON); rect(0, 32, 31, 32, Pal.IRON_LIGHT)
        rect(13, 20, 18, 26, Pal.GOLD_DARK); raw(15, 23, Pal.OUTLINE); raw(16, 23, Pal.OUTLINE)
        outline(Pal.OUTLINE)
    }

    // ------------------------------------------------------------------ objects: furniture

    private fun Pen.counter(left: Boolean, right: Boolean) {
        val x0 = if (left) 0 else 1
        val x1 = if (right) 31 else 30
        rect(x0, 2, x1, 13, Pal.WOOD_LIGHT) // top
        rect(x0, 2, x1, 3, mix(Pal.WOOD_LIGHT, Pal.WHITE, 0.3))
        rect(x0, 14, x1, 38, Pal.WOOD) // front
        rect(x0, 14, x1, 15, Pal.WOOD_DARK)
        for (x in x0..x1) if ((x + 4) % 10 == 0) rect(x, 16, x, 36, Pal.WOOD_DARK)
        rect(x0, 36, x1, 39, Pal.WOOD_DARK)
        if (!left) { rect(0, 2, 0, 39, Pal.OUTLINE) }
        if (!right) { rect(31, 2, 31, 39, Pal.OUTLINE) }
        rect(x0, 1, x1, 1, Pal.OUTLINE)
        rect(x0, 39, x1, 39, Pal.OUTLINE)
    }

    private fun Pen.table(seed: Int) {
        rect(4, 20, 6, 34, Pal.WOOD_DARK); rect(25, 20, 27, 34, Pal.WOOD_DARK)
        rect(1, 4, 30, 18, Pal.WOOD) // top
        rect(1, 4, 30, 5, Pal.WOOD_LIGHT)
        rect(1, 18, 30, 21, Pal.WOOD_DARK) // edge
        // things on the table
        ellipse(10.0, 11.0, 4.0, 2.6, Pal.WHITE); ellipse(10.0, 11.0, 2.4, 1.4, argb(0xD8C8B0))
        rect(19, 6, 22, 12, if (seed % 2 == 0) Pal.GOLD_DARK else argb(0x70A0D0)); rect(19, 6, 22, 6, Pal.GOLD)
        outline(Pal.OUTLINE)
    }

    private fun Pen.bed() {
        rect(2, 0, 29, 8, Pal.WOOD_DARK) // headboard
        rect(2, 0, 29, 1, Pal.WOOD_LIGHT)
        rect(2, 8, 29, 37, Pal.WOOD)
        rect(4, 8, 27, 16, Pal.WHITE) // pillow
        rect(4, 15, 27, 16, argb(0xD8D8E8))
        rect(3, 17, 28, 35, argb(0x4A6CC0)) // blanket
        rect(3, 17, 28, 19, argb(0x7090E0))
        for (y in 22..34 step 6) rect(3, y, 28, y, argb(0x3A58A8))
        rect(2, 36, 29, 39, Pal.WOOD_DARK)
        outline(Pal.OUTLINE)
    }

    private fun Pen.shelf(seed: Int) {
        rect(1, 0, 30, 55, Pal.WOOD_DARK)
        rect(3, 2, 28, 53, argb(0x5A3A22))
        val items = listOf(Pal.RED, Pal.GOLD, Pal.GLASS, Pal.STONE_LIGHT, Pal.LEAF_LIGHT, argb(0xB070E0), argb(0xE09030))
        for (row in 0..3) {
            val y = 3 + row * 13
            rect(2, y + 11, 29, y + 12, Pal.WOOD_LIGHT)
            var x = 4
            var i = 0
            while (x < 26) {
                val w = 2 + noise(row, i, seed) % 3
                val h = 5 + noise(i, row, seed + 1) % 5
                rect(x, y + 11 - h, x + w, y + 10, items[(row * 3 + i + seed) % items.size])
                raw(x, y + 11 - h, Pal.WHITE)
                x += w + 2
                i++
            }
        }
        rect(27, 0, 30, 55, Pal.OUTLINE.let { mix(Pal.WOOD_DARK, it, 0.5) })
        outline(Pal.OUTLINE)
    }

    private fun Pen.plant() {
        rect(10, 26, 21, 38, Pal.ROOF_DARK)
        rect(9, 26, 22, 28, Pal.ROOF)
        for ((cx, cy) in listOf(16 to 12, 10 to 18, 22 to 17, 16 to 21, 12 to 8, 20 to 8)) {
            ball(cx.toDouble(), cy.toDouble(), 5.0, 4.5, LEAF, LEAF_L, LEAF_D)
        }
        outline(Pal.OUTLINE)
    }

    private fun Pen.altar(left: Boolean, right: Boolean, lit: Boolean) {
        val x0 = if (left) 0 else 2
        val x1 = if (right) 31 else 29
        rect(x0, 12, x1, 22, Pal.STONE_LIGHT) // top
        rect(x0, 22, x1, 41, Pal.STONE) // front
        rect(x0, 39, x1, 43, Pal.STONE_DARK)
        rect(x0, 26, x1, 34, argb(0xB0303C)) // cloth
        for (x in x0..x1 step 4) raw(x, 34, Pal.GOLD)
        if (!left) rect(x0, 12, x0, 43, Pal.OUTLINE)
        if (!right) rect(x1, 12, x1, 43, Pal.OUTLINE)
        rect(x0, 11, x1, 11, Pal.OUTLINE); rect(x0, 43, x1, 43, Pal.OUTLINE)
        if (right && !left) {
            // amulet holder, centred over the pair of altar tiles
            rect(26, 2, 31, 14, Pal.GOLD_DARK)
            if (lit) {
                ellipse(31.0, 6.0, 5.0, 5.0, Pal.FIRE_LIGHT)
                ellipse(31.0, 6.0, 3.0, 3.0, Pal.GOLD)
            }
        }
        if (left && !right) {
            rect(0, 2, 5, 14, Pal.GOLD_DARK)
            if (lit) {
                ellipse(0.0, 6.0, 5.0, 5.0, Pal.FIRE_LIGHT)
                ellipse(0.0, 6.0, 3.0, 3.0, Pal.GOLD)
            }
        }
    }

    // ------------------------------------------------------------------ buildings

    private val PLASTER = argb(0xCFC2A2); private val PLASTER_D = argb(0xAE9F80)
    private val TIMBER = argb(0x4A3220); private val TIMBER_L = argb(0x64462C)

    // ------------------------------------------------------------------ buildings

    private val HOUSE_PARTS = setOf(Tile.ROOF, Tile.ROOF_BLUE, Tile.WALL, Tile.WINDOW, Tile.DOOR)

    /** A building on a town map: its tiles' bounds, façade and look. */
    private class House(val x0: Int, val y0: Int, val w: Int, val h: Int, val facade: List<Tile>, val style: HouseStyle) {
        /** Extra image height above the roof (the temple's bell tower). */
        val extraTop: Int get() = if (style.feature == HouseFeature.BELL_TOWER) 34 else 0
        val over: Int get() = 16 + extraTop
        val chimney: Boolean get() = w >= 4 && style.feature != HouseFeature.BELL_TOWER
        /** Left edge of the chimney in image pixels. */
        val chimneyX: Int get() = if (style.mirrored) 34 else w * T - 44
    }

    private val houseCache = HashMap<String, List<House>>()

    /** All buildings of a town map (flood fill over roof, wall, window and door tiles). */
    private fun houses(map: MapDef): List<House> = houseCache.getOrPut(map.id) {
        if (map.kind != MapKind.TOWN) return@getOrPut emptyList()
        val seen = HashSet<Pair<Int, Int>>()
        val out = mutableListOf<House>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (map.tile(tx, ty) !in HOUSE_PARTS || (tx to ty) in seen) continue
            val cells = mutableListOf<Pair<Int, Int>>()
            val queue = ArrayDeque(listOf(tx to ty))
            seen += tx to ty
            while (queue.isNotEmpty()) {
                val (x, y) = queue.removeFirst()
                cells += x to y
                for ((dx, dy) in listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)) {
                    val n = x + dx to y + dy
                    if (n !in seen && map.inside(n.first, n.second) && map.tile(n.first, n.second) in HOUSE_PARTS) {
                        seen += n
                        queue += n
                    }
                }
            }
            val x0 = cells.minOf { it.first }; val x1 = cells.maxOf { it.first }
            val y0 = cells.minOf { it.second }; val y1 = cells.maxOf { it.second }
            val blue = cells.any { map.tile(it.first, it.second) == Tile.ROOF_BLUE }
            // Houses without an explicit look keep the classic one.
            val style = map.houseStyles[x0 to y0] ?: HouseStyle(if (blue) RoofKind.BLUE else RoofKind.RED, WallKind.TIMBER)
            out += House(x0, y0, x1 - x0 + 1, y1 - y0 + 1, (x0..x1).map { map.tile(it, y1) }, style)
        }
        out
    }

    /** Tops of the chimneys on a town map, in art pixels (for the smoke). */
    fun chimneys(map: MapDef): List<Pair<Int, Int>> =
        houses(map).filter { it.chimney }.map { (it.x0 * T + it.chimneyX + 5) to (it.y0 * T - 16) }

    /** The building whose top-left tile is (x0, y0), drawn as one object with façade and roof. */
    private fun building(map: MapDef, sx: Int, sy: Int, seen: MutableSet<Pair<Int, Int>>): Obj? {
        val house = houses(map).firstOrNull { sx in it.x0 until it.x0 + it.w && sy in it.y0 until it.y0 + it.h } ?: return null
        for (y in house.y0 until house.y0 + house.h) for (x in house.x0 until house.x0 + house.w) seen += x to y
        val s = house.style
        val key = "house/${house.w}/${house.h}/${s.roof}/${s.walls}/${s.mirrored}/${s.feature}/${house.facade.joinToString("") { it.ch.toString() }}"
        val img = cache.getOrPut(key) {
            draw(house.w * T + 6, house.h * T + house.over) { house(house) }
        }
        return Obj(img, house.x0 * T, house.y0 * T - house.over, (house.y0 + house.h) * T - 1)
    }

    private val STONE_WALL = argb(0x9E9686); private val STONE_WALL_D = argb(0x7A7264)
    private val TEMPLE_WALL = argb(0xBCB6A8); private val TEMPLE_WALL_D = argb(0x969082)
    private val PLANK = argb(0xA8743E); private val PLANK_D = argb(0x7A5028); private val PLANK_L = argb(0xC48C50)

    private fun roofColors(r: RoofKind): Pair<Int, Int> = when (r) {
        RoofKind.RED -> argb(0x8A4434) to argb(0x5C2C24)
        RoofKind.BLUE -> argb(0x4A5A74) to argb(0x303C52)
        RoofKind.SLATE -> argb(0x565E6A) to argb(0x383E48)
        RoofKind.SHINGLE -> argb(0x76503A) to argb(0x4C3224)
        RoofKind.STRAW -> argb(0xA48E54) to argb(0x766234)
    }

    private fun Pen.house(h: House) {
        val wTiles = h.w; val hTiles = h.h; val facade = h.facade; val st = h.style
        val over = h.over
        val W = wTiles * T
        val wallTop = over + (hTiles - 1) * T - 10 // a tall façade reads better in this view
        val roofBottom = wallTop + 5 // eave overlaps the façade a little
        val wallBottom = over + hTiles * T - 1
        val temple = st.feature == HouseFeature.BELL_TOWER
        // A pick of shutter colours per house, so neighbours differ.
        val shutter = listOf(argb(0x4E8A4A), argb(0x4A6AA8), argb(0x9A3A2A), argb(0x5A5A6A))[Math.floorMod(W * 7 + hTiles * 3 + st.roof.ordinal, 4)]

        // drop shadow to the right
        for (y in roofBottom - 8..wallBottom) for (x in W until W + 6) raw(x, y, SHADOW_SOFT)

        // ---- façade
        when (st.walls) {
            WallKind.TIMBER -> {
                rect(0, wallTop, W - 1, wallBottom, PLASTER)
                for (y in wallTop..wallBottom) for (x in 0 until W) if (noise(x, y, 5) % 23 == 0) raw(x, y, PLASTER_D)
            }
            WallKind.STONE -> {
                val c = if (temple) TEMPLE_WALL else STONE_WALL
                val d = if (temple) TEMPLE_WALL_D else STONE_WALL_D
                rect(0, wallTop, W - 1, wallBottom, d)
                var row = 0
                var y = wallTop
                while (y < wallBottom - 3) {
                    var x = if (row % 2 == 0) 0 else -5
                    var k = 0
                    while (x < W) {
                        val bw = 9 + noise(row, k, 13) % 4
                        val tone = mix(c, d, (noise(k, row, 17) % 4) * 0.08)
                        for (yy in y + 1 until minOf(y + 6, wallBottom - 3)) for (xx in maxOf(0, x + 1) until minOf(W, x + bw)) raw(xx, yy, tone)
                        for (xx in maxOf(0, x + 1) until minOf(W, x + bw)) if (y + 1 < wallBottom - 3) raw(xx, y + 1, mix(tone, Pal.WHITE, 0.25))
                        x += bw
                        k++
                    }
                    y += 6
                    row++
                }
            }
            WallKind.PLANKS -> {
                rect(0, wallTop, W - 1, wallBottom, PLANK)
                var y = wallTop
                var row = 0
                while (y < wallBottom) {
                    for (x in 0 until W) raw(x, y, PLANK_D)
                    for (x in 0 until W) if (noise(x, row, 21) % 9 == 0) raw(x, y + 2, PLANK_L)
                    // knots
                    val kx = noise(row, W, 23) % W
                    if (y + 2 < wallBottom) { raw(kx, y + 2, PLANK_D); raw(kx + 1, y + 2, PLANK_D) }
                    y += 5
                    row++
                }
            }
        }
        rect(0, wallBottom - 3, W - 1, wallBottom, Pal.STONE) // foundation
        for (x in 0 until W step 5) raw(x, wallBottom - 2, Pal.STONE_DARK)
        val frame = when (st.walls) { WallKind.TIMBER -> TIMBER; WallKind.PLANKS -> PLANK_D; WallKind.STONE -> if (temple) TEMPLE_WALL_D else STONE_WALL_D }
        if (st.walls != WallKind.STONE) {
            rect(0, wallBottom - 4, W - 1, wallBottom - 4, frame)
            rect(0, wallTop, 2, wallBottom - 4, frame); rect(W - 3, wallTop, W - 1, wallBottom - 4, frame)
        } else {
            // corner stones
            for (y in wallTop until wallBottom - 4 step 6) { rect(0, y, 3, y + 4, mix(frame, Pal.WHITE, 0.2)); rect(W - 4, y, W - 1, y + 4, mix(frame, Pal.WHITE, 0.2)) }
        }
        var doorFx = -1
        facade.forEachIndexed { i, t ->
            val fx = i * T
            if (i > 0 && st.walls == WallKind.TIMBER) rect(fx - 1, wallTop, fx, wallBottom - 4, TIMBER)
            when (t) {
                Tile.WINDOW -> {
                    if (temple) {
                        // tall arched window with coloured glass
                        rect(fx + 10, wallTop + 6, fx + 21, wallTop + 24, frame)
                        ellipse(fx + 15.5, wallTop + 8.0, 5.5, 4.0, frame)
                        rect(fx + 12, wallTop + 8, fx + 19, wallTop + 22, argb(0x5A7AC8))
                        ellipse(fx + 15.5, wallTop + 9.0, 3.5, 2.5, argb(0xE8C040))
                        rect(fx + 15, wallTop + 8, fx + 16, wallTop + 22, frame)
                        rect(fx + 12, wallTop + 15, fx + 19, wallTop + 15, frame)
                    } else {
                        rect(fx + 7, wallTop + 9, fx + 24, wallTop + 22, if (st.walls == WallKind.TIMBER) TIMBER else PLANK_D)
                        rect(fx + 9, wallTop + 11, fx + 22, wallTop + 20, Pal.GLASS)
                        rect(fx + 15, wallTop + 11, fx + 16, wallTop + 20, TIMBER)
                        raw(fx + 10, wallTop + 12, Pal.WHITE); raw(fx + 11, wallTop + 12, Pal.WHITE); raw(fx + 10, wallTop + 13, Pal.WHITE)
                        if (st.walls != WallKind.TIMBER) {
                            // shutters
                            rect(fx + 3, wallTop + 9, fx + 6, wallTop + 22, shutter); rect(fx + 25, wallTop + 9, fx + 28, wallTop + 22, shutter)
                            for (y in wallTop + 11 until wallTop + 22 step 3) { raw(fx + 4, y, mix(shutter, Pal.BLACK, 0.3)); raw(fx + 26, y, mix(shutter, Pal.BLACK, 0.3)) }
                        }
                        rect(fx + 6, wallTop + 23, fx + 25, wallTop + 25, Pal.WOOD) // flower box
                        val bloom = listOf(Pal.RED, argb(0xF08CC0), Pal.GOLD, argb(0xB070E0))[Math.floorMod(i + W, 4)]
                        for (x in fx + 7..fx + 24 step 3) { raw(x, wallTop + 22, bloom); raw(x + 1, wallTop + 22, G_D) }
                    }
                }
                Tile.DOOR -> {
                    doorFx = fx
                    if (temple) {
                        rect(fx + 6, wallTop + 4, fx + 25, wallBottom - 4, frame)
                        ellipse(fx + 16.0, wallTop + 6.0, 10.0, 6.0, frame)
                        rect(fx + 8, wallTop + 7, fx + 23, wallBottom - 4, argb(0x7A4A28))
                        ellipse(fx + 16.0, wallTop + 8.0, 8.0, 4.5, argb(0x7A4A28))
                        rect(fx + 15, wallTop + 4, fx + 16, wallBottom - 4, argb(0x5A3418))
                        raw(fx + 13, wallTop + 18, Pal.GOLD); raw(fx + 18, wallTop + 18, Pal.GOLD)
                    } else {
                        rect(fx + 6, wallTop + 6, fx + 25, wallBottom - 4, if (st.walls == WallKind.TIMBER) TIMBER else PLANK_D)
                        rect(fx + 8, wallTop + 8, fx + 23, wallBottom - 4, Pal.WOOD)
                        ellipse(fx + 16.0, wallTop + 9.0, 8.0, 4.0, Pal.WOOD)
                        for (x in fx + 11..fx + 21 step 5) rect(x, wallTop + 8, x, wallBottom - 4, Pal.WOOD_DARK)
                        raw(fx + 21, wallTop + 18, Pal.GOLD); raw(fx + 21, wallTop + 19, Pal.GOLD_DARK)
                    }
                    rect(fx + 5, wallBottom - 3, fx + 26, wallBottom, Pal.STONE_LIGHT) // step
                }
                else -> if (st.walls == WallKind.TIMBER) { // half-timbering cross
                    line(fx + 4, wallTop + 6, fx + 27, wallBottom - 6, TIMBER)
                    line(fx + 27, wallTop + 6, fx + 4, wallBottom - 6, TIMBER)
                } else if (st.walls == WallKind.PLANKS && Math.floorMod(i * 5 + W, 3) == 0) {
                    // firewood stacked against the wall
                    for (r in 0 until 3) for (k in 0 until 4 - r) {
                        val cx = fx + 8 + k * 5 + r * 2; val cy = wallBottom - 7 - r * 4
                        ellipse(cx.toDouble(), cy.toDouble(), 2.4, 2.0, argb(0x8A5A30)); raw(cx, cy, argb(0xD8B078))
                    }
                }
            }
        }

        // ---- roof: front slope seen from above at an angle. It narrows towards the ridge, the
        // slanted gable edges are shaded, and shingle rows get darker towards the top.
        val (c, d) = roofColors(st.roof)
        val l = mix(c, Pal.WHITE, 0.25)
        val straw = st.roof == RoofKind.STRAW
        val roofTop = 2 + h.extraTop
        val span = (roofBottom - roofTop).toDouble()
        for (y in roofTop..roofBottom) {
            val t = (y - roofTop) / span
            val inset = (10 * (1 - t)).toInt()
            val rowFromEave = (roofBottom - y) / 5
            val base = mix(c, d, (1 - t) * 0.45)
            for (x in inset until W - inset) {
                var col = base
                if (straw) {
                    // thatch: streaks running down the slope
                    val n = noise(x, y / 3, 61) % 7
                    if (n == 0) col = mix(base, d, 0.5) else if (n == 1) col = mix(base, Pal.WHITE, 0.2)
                    if ((roofBottom - y) % 7 == 0) col = mix(col, d, 0.35)
                } else {
                    val rowH = if (st.roof == RoofKind.SHINGLE) 4 else 5
                    if ((roofBottom - y) % rowH == 0) col = mix(base, d, 0.6) // shingle row edge
                    else if ((roofBottom - y) % rowH == rowH - 1) col = mix(base, Pal.WHITE, 0.12)
                    val stagger = if (st.roof == RoofKind.SHINGLE) 6 else 8
                    if ((roofBottom - y) % rowH != 0 && (x + rowFromEave * 4) % stagger == 0) col = mix(base, d, 0.45)
                }
                // gable edges
                if (x < inset + 4) col = mix(d, Pal.OUTLINE, 0.25)
                if (x >= W - inset - 4) col = mix(d, Pal.OUTLINE, 0.45)
                raw(x, y, col)
            }
        }
        // ridge cap with highlight
        rect(10, roofTop, W - 11, roofTop + (if (straw) 3 else 2), d)
        for (x in 10 until W - 10) raw(x, roofTop, l)
        // eave board (a thick bundle for thatch) and its shadow on the wall
        if (straw) {
            rect(0, roofBottom - 1, W - 1, roofBottom + 2, mix(c, d, 0.5))
            for (x in 0 until W) if (x % 3 == 0) raw(x, roofBottom + 2, d)
        } else rect(0, roofBottom, W - 1, roofBottom + 1, if (st.roof == RoofKind.SLATE) argb(0x3A404C) else Pal.WOOD_DARK)
        for (y in roofBottom + 2..roofBottom + 5) for (x in 3 until W - 3) blend(x, y, alpha(0x201010, 0x70 - (y - roofBottom) * 12))

        // ---- chimney
        if (h.chimney) {
            val cx = h.chimneyX
            val top = h.extraTop
            val brick = if (st.walls == WallKind.STONE) argb(0x8A8478) else argb(0x9A5A48)
            rect(cx, top, cx + 9, roofTop + 12, brick)
            for (y in top + 2..roofTop + 12 step 4) for (x in cx..cx + 9) if ((x + y) % 5 == 0) raw(x, y, mix(brick, Pal.BLACK, 0.25))
            rect(cx - 1, top, cx + 10, top + 1, Pal.STONE_DARK)
        }

        // ---- special features
        when (st.feature) {
            HouseFeature.INN_SIGN -> if (doorFx >= 0) {
                // a wrought-iron bracket with a hanging board showing a mug
                val bx = doorFx + T + 2
                val by = wallTop + 4
                rect(bx - 2, by, bx + 14, by, Pal.IRON); raw(bx + 14, by + 1, Pal.IRON)
                line(bx - 2, by + 6, bx + 6, by, Pal.IRON)
                raw(bx + 2, by + 1, Pal.IRON); raw(bx + 12, by + 1, Pal.IRON)
                rect(bx, by + 2, bx + 14, by + 13, Pal.WOOD_DARK)
                rect(bx + 1, by + 3, bx + 13, by + 12, Pal.WOOD)
                // mug
                rect(bx + 4, by + 5, bx + 9, by + 10, Pal.GOLD); rect(bx + 4, by + 4, bx + 9, by + 5, Pal.WHITE)
                rect(bx + 10, by + 6, bx + 11, by + 9, Pal.GOLD_DARK)
            }
            HouseFeature.AWNING -> {
                // striped awning over the whole front
                val ay = wallTop + 1
                for (x in 2 until W - 2) {
                    val red = (x / 5) % 2 == 0
                    val col = if (red) argb(0xC83C34) else argb(0xF4ECDC)
                    for (y in ay until ay + 7) raw(x, y, if (y == ay) mix(col, Pal.WHITE, 0.3) else col)
                    // scalloped lower edge
                    if (x % 5 in 1..3) raw(x, ay + 7, col)
                    if (x % 5 == 2) raw(x, ay + 8, col)
                }
                for (x in 2 until W - 2) blend(x, ay + 9, alpha(0x201010, 0x50))
            }
            HouseFeature.BELL_TOWER -> {
                // a stone tower rising from the middle of the roof, with an open belfry and a slate spire
                val tw = 24
                val tx = W / 2 - tw / 2
                val towerBottom = roofTop + 14
                val belfryTop = 14
                rect(tx, belfryTop, tx + tw - 1, towerBottom, TEMPLE_WALL)
                for (y in belfryTop until towerBottom step 5) for (x in tx until tx + tw) raw(x, y, TEMPLE_WALL_D)
                rect(tx, belfryTop, tx + 1, towerBottom, TEMPLE_WALL_D); rect(tx + tw - 2, belfryTop, tx + tw - 1, towerBottom, mix(TEMPLE_WALL_D, Pal.OUTLINE, 0.3))
                // arched opening with a golden bell
                rect(tx + 7, belfryTop + 6, tx + 16, belfryTop + 17, argb(0x2A2638))
                ellipse(tx + 11.5, belfryTop + 6.0, 4.5, 3.5, argb(0x2A2638))
                ball(tx + 11.5, belfryTop + 12.0, 3.5, 3.5, Pal.GOLD, Pal.WHITE, Pal.GOLD_DARK)
                rect(tx + 8, belfryTop + 15, tx + 15, belfryTop + 15, Pal.GOLD_DARK)
                // spire
                val (sc, sd) = roofColors(RoofKind.SLATE)
                for (y in 0 until belfryTop) {
                    val half = (y + 1) * (tw / 2 + 2) / belfryTop
                    for (x in W / 2 - half until W / 2 + half) raw(x, y, if (x < W / 2) mix(sc, Pal.WHITE, 0.15) else sd)
                }
                // a little golden sun on top
                raw(W / 2 - 1, 0, Pal.GOLD); raw(W / 2, 0, Pal.GOLD)
            }
            HouseFeature.NONE -> {}
        }
        outline(Pal.OUTLINE)
    }

    // ------------------------------------------------------------------ objects: village square

    /** A market stall: a wooden table with goods under a striped awning (32×48). */
    private fun Pen.stall(seed: Int) {
        val stripe = listOf(argb(0xC83C34), argb(0x3C7AC8), argb(0x3C9A4C), argb(0xD89A2C))[seed]
        blendEllipse(16.0, 45.0, 15.0, 3.0, SHADOW)
        // posts
        rect(2, 10, 3, 44, Pal.WOOD_DARK); rect(28, 10, 29, 44, Pal.WOOD_DARK)
        // table
        rect(1, 30, 30, 34, Pal.WOOD); rect(1, 30, 30, 30, Pal.WOOD_LIGHT); rect(1, 35, 30, 41, Pal.WOOD_DARK)
        for (x in 4..27 step 6) rect(x, 35, x, 41, mix(Pal.WOOD_DARK, Pal.BLACK, 0.25))
        // goods by stall: apples, cloth, herbs and mushrooms
        when (seed % 3) {
            0 -> for (i in 0 until 6) { val x = 4 + i * 4; ball(x + 1.5, 27.5, 2.0, 2.0, Pal.RED, argb(0xF07070), argb(0x902020)); raw(x + 1, 25, G_DD) }
            1 -> { rect(3, 24, 11, 29, argb(0x7A5AC8)); rect(12, 25, 19, 29, argb(0xE8C040)); rect(20, 23, 28, 29, argb(0x4AA0C8)); for (x in 3..28 step 4) raw(x, 24, Pal.WHITE) }
            else -> for (i in 0 until 4) { val x = 5 + i * 6; ellipse(x + 1.5, 27.0, 3.0, 2.0, if (i % 2 == 0) G_D else argb(0xC8A878)); raw(x + 1, 26, if (i % 2 == 0) G_L else Pal.WHITE) }
        }
        // striped awning with a scalloped edge
        for (y in 6..15) {
            val inset = (15 - y) / 3
            for (x in inset until T - inset) {
                val col = if ((x / 4) % 2 == 0) stripe else argb(0xF4ECDC)
                raw(x, y, if (y == 6) mix(col, Pal.WHITE, 0.3) else if (y >= 14) mix(col, Pal.BLACK, 0.15) else col)
            }
        }
        for (x in 0 until T) if (x % 4 in 1..2) raw(x, 16, if ((x / 4) % 2 == 0) stripe else argb(0xF4ECDC))
        outline(Pal.OUTLINE)
    }

    /** A street lantern on a post (32×56); the glow at night is drawn by the app. */
    private fun Pen.lamp() {
        blendEllipse(16.0, 53.0, 6.0, 2.0, SHADOW)
        rect(15, 18, 16, 52, Pal.IRON); raw(15, 18, Pal.IRON_LIGHT)
        rect(12, 50, 19, 53, Pal.STONE_DARK)
        // lantern head
        rect(11, 8, 20, 18, Pal.IRON)
        rect(12, 9, 19, 17, argb(0xF8D878)); rect(13, 10, 15, 13, argb(0xFFF4C0))
        rect(15, 9, 16, 17, Pal.IRON)
        tri(10, 8, 21, 8, 16, 3, Pal.IRON)
        rect(15, 1, 16, 3, Pal.IRON)
        outline(Pal.OUTLINE)
    }

    /** A wooden barrel with iron hoops (32×36). */
    private fun Pen.barrel() {
        blendEllipse(16.0, 33.0, 10.0, 3.0, SHADOW)
        ball(16.0, 21.0, 9.5, 11.5, argb(0xA06A38), argb(0xC8904E), argb(0x6A4222))
        for (y in listOf(14, 27)) for (x in 7..25) if (kotlin.math.abs(x - 16) < 9.5) raw(x, y, Pal.IRON)
        for (x in 9..23 step 4) for (y in 11..31) if (raw2(x, y)) raw(x, y, argb(0x7A4C28))
        ellipse(16.0, 10.5, 8.0, 3.0, argb(0x8A5A30)); ellipse(16.0, 10.5, 6.0, 2.0, argb(0x6A4222))
        outline(Pal.OUTLINE)
    }

    /** A wooden fence that joins its neighbours (32×40). */
    private fun Pen.fence(left: Boolean, right: Boolean, up: Boolean, down: Boolean) {
        val post = Pal.WOOD_DARK; val rail = Pal.WOOD
        val horizontal = left || right || !(up || down)
        if (horizontal) {
            val x0 = if (left) 0 else 12; val x1 = if (right) T - 1 else 19
            for (y in listOf(16, 26)) { rect(x0, y, x1, y + 2, rail); rect(x0, y, x1, y, Pal.WOOD_LIGHT) }
        }
        if (up || down) {
            val y0 = if (up) 0 else 12; val y1 = if (down) 39 else 30
            rect(14, y0, 17, y1, rail); rect(14, y0, 14, y1, Pal.WOOD_LIGHT)
        }
        // post in the middle
        rect(13, 10, 18, 34, post); rect(13, 10, 18, 11, Pal.WOOD_LIGHT)
        blendEllipse(16.0, 36.0, 8.0, 2.0, SHADOW)
        outline(Pal.OUTLINE)
    }

    /**
     * Barrier pole across a road (32×64, the tile is the lower half). The [pivot] end has the post
     * the pole swings up on, the other end a forked rest; [open] shows the pole raised.
     */
    private fun Pen.barrier(pivot: Boolean, open: Boolean) {
        val red = argb(0xC8402E); val redD = argb(0x8E2A1E); val white = argb(0xF2EEE2); val whiteD = argb(0xC8C2B4)
        val post = Pal.WOOD_DARK
        fun stripe(i: Int) = (i / 5) % 2 == 0
        if (pivot) {
            blendEllipse(8.0, 61.0, 7.0, 2.0, SHADOW)
            rect(4, 38, 9, 61, post); rect(4, 38, 5, 61, Pal.WOOD); rect(3, 37, 10, 38, Pal.WOOD_LIGHT)
            if (open) {
                // pole standing up, counterweight down by the post
                for (y in 4..44) {
                    val c = if (stripe(y)) red else white
                    rect(5, y, 8, y, c); px(8, y, if (stripe(y)) redD else whiteD)
                }
                rect(10, 44, 14, 49, Pal.STONE_DARK); rect(10, 44, 14, 44, Pal.STONE)
            } else {
                rect(0, 42, 3, 47, Pal.STONE_DARK); rect(0, 42, 3, 42, Pal.STONE) // counterweight
                for (x in 6..31) {
                    val c = if (stripe(x)) red else white
                    rect(x, 41, x, 45, c); px(x, 45, if (stripe(x)) redD else whiteD); px(x, 41, if (stripe(x)) red else Pal.WHITE)
                }
                for (x in 6..31) { blend(x, 56, SHADOW_SOFT); blend(x, 57, SHADOW_SOFT) }
            }
            px(6, 43, Pal.IRON_LIGHT); px(7, 43, Pal.IRON)
        } else {
            blendEllipse(26.0, 61.0, 6.0, 2.0, SHADOW)
            rect(24, 46, 28, 61, post); rect(24, 46, 25, 61, Pal.WOOD)
            rect(22, 42, 23, 47, post); rect(29, 42, 30, 47, post) // fork
            if (!open) {
                for (x in 0..27) {
                    val c = if (stripe(x + 32)) red else white
                    rect(x, 41, x, 45, c); px(x, 45, if (stripe(x + 32)) redD else whiteD)
                }
                for (x in 0..27) { blend(x, 56, SHADOW_SOFT); blend(x, 57, SHADOW_SOFT) }
            }
        }
        outline(Pal.OUTLINE)
    }

    /** A round bale of hay (32×36). */
    private fun Pen.hay(seed: Int) {
        blendEllipse(16.0, 33.0, 13.0, 3.0, SHADOW)
        ball(16.0, 20.0, 13.0, 11.0, WHEAT, WHEAT_L, WHEAT_D)
        for (y in 12..30 step 3) for (x in 4..28) if (noise(x, y, 90 + seed) % 4 == 0 && img.opaque(x, y)) raw(x, y, WHEAT_D)
        ellipse(22.0, 20.0, 5.0, 8.0, mix(WHEAT, WHEAT_D, 0.4))
        for (r in 1..4) for (a in 0 until 12) {
            val ang = a * Math.PI / 6
            val x = (22 + kotlin.math.cos(ang) * r * 1.1).toInt(); val y = (20 + kotlin.math.sin(ang) * r * 1.8).toInt()
            if (r % 2 == 0) raw(x, y, WHEAT_D)
        }
        outline(Pal.OUTLINE)
    }

    /** A washing line between two posts, with laundry (32×48). */
    private fun Pen.washline(left: Boolean, right: Boolean, seed: Int) {
        if (!left) { rect(3, 8, 5, 44, Pal.WOOD_DARK); blendEllipse(4.0, 45.0, 4.0, 1.5, SHADOW) }
        if (!right) { rect(T - 6, 8, T - 4, 44, Pal.WOOD_DARK); blendEllipse(T - 5.0, 45.0, 4.0, 1.5, SHADOW) }
        val x0 = if (left) 0 else 4; val x1 = if (right) T - 1 else T - 5
        for (x in x0..x1) raw(x, 10 + (if (x in 8..24) 1 else 0), argb(0xE8E8E8))
        val colors = listOf(Pal.WHITE, argb(0x6A9AE0), argb(0xE07A6A), argb(0xF0D070), argb(0x8AC07A))
        // a shirt and a sheet
        val c1 = colors[seed % colors.size]; val c2 = colors[(seed + 2) % colors.size]
        rect(8, 12, 15, 24, c1); rect(6, 12, 17, 15, c1); rect(8, 12, 15, 12, mix(c1, Pal.WHITE, 0.4))
        rect(19, 12, 26, 28, c2); for (y in 13..28 step 4) rect(19, y, 26, y, mix(c2, Pal.BLACK, 0.12))
        raw(10, 11, Pal.WOOD); raw(14, 11, Pal.WOOD); raw(20, 11, Pal.WOOD); raw(25, 11, Pal.WOOD)
        outline(Pal.OUTLINE)
    }

    private fun Pen.raw2(x: Int, y: Int): Boolean = img.opaque(x, y) && (x + y) % 3 != 0

    /** A wooden bench (32×32). */
    private fun Pen.bench() {
        blendEllipse(16.0, 28.0, 14.0, 3.0, SHADOW)
        rect(4, 20, 5, 27, Pal.WOOD_DARK); rect(26, 20, 27, 27, Pal.WOOD_DARK)
        rect(2, 16, 29, 20, Pal.WOOD); rect(2, 16, 29, 16, Pal.WOOD_LIGHT)
        rect(2, 9, 29, 12, Pal.WOOD); rect(2, 9, 29, 9, Pal.WOOD_LIGHT)
        rect(4, 12, 5, 16, Pal.WOOD_DARK); rect(26, 12, 27, 16, Pal.WOOD_DARK)
        outline(Pal.OUTLINE)
    }

    // ------------------------------------------------------------------ characters

    /** Soft shadow under a character's feet. */
    fun shadow(): PixelImage = cached("char-shadow", 24, 8) { ellipse(12.0, 4.0, 11.0, 3.5, SHADOW) }

    /** A healing herb ready to be picked: a bright light-green plant that stands out of the meadow. */
    fun herb(): PixelImage = cached("herb", 20, 22) {
        val dark = argb(0x3E8A2A); val base = argb(0x8ED84A); val light = argb(0xD2F88A)
        // leaves fanning out from the root
        ball(5.0, 15.0, 4.2, 2.3, base, light, dark)
        ball(15.0, 15.0, 4.2, 2.3, base, light, dark)
        ball(7.0, 11.0, 3.0, 3.8, base, light, dark)
        ball(13.0, 11.0, 3.0, 3.8, base, light, dark)
        ball(10.0, 8.5, 2.6, 4.4, base, light, dark)
        line(10, 19, 10, 7, dark)
        // a small white blossom on top
        ball(10.0, 3.5, 2.0, 2.0, Pal.WHITE, Pal.WHITE, argb(0xD0D0E0))
        raw(10, 3, Pal.GOLD)
        outline(Pal.OUTLINE)
    }
}
