package de.bornim.core.art

import de.bornim.core.GameState
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Story
import de.bornim.core.Tile

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

    /** A drawable at map pixel position ([x], [y]) = top-left, ordered by [sortY]. */
    class Obj(val img: PixelImage, val x: Int, val y: Int, val sortY: Int)

    private val cache = HashMap<String, PixelImage>()
    private fun cached(key: String, w: Int = T, h: Int = T, block: Pen.() -> Unit) = cache.getOrPut(key) { draw(w, h, block = block) }

    private val SHADOW = alpha(0x101020, 0x55)
    private val SHADOW_SOFT = alpha(0x101020, 0x30)

    // ================================================================== ground layer

    fun ground(map: MapDef, tx: Int, ty: Int, state: GameState, frame: Int): PixelImage {
        val t = map.tile(tx, ty)
        val seed = Math.floorMod(tx * 7 + ty * 13, 4)
        fun at(dx: Int, dy: Int): Tile = if (map.inside(tx + dx, ty + dy)) map.tile(tx + dx, ty + dy) else t
        val kind = map.kind
        return when (t) {
            Tile.GRASS -> cached("grass$seed") { grass(seed) }
            Tile.FLOWERS -> cached("flowers$seed") { grass(seed); flowers(seed) }
            Tile.TALL_GRASS -> cached("tall$seed") { tallGrass(seed) }
            Tile.PATH -> {
                fun p(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.PATH || it == Tile.DOOR || it == Tile.CAVE_ENTRANCE }
                val m = mask(!p(0, -1), !p(1, 0), !p(0, 1), !p(-1, 0))
                cached("path$m/$seed") { path(m, seed) }
            }
            Tile.WATER -> {
                fun w(dx: Int, dy: Int) = at(dx, dy) == Tile.WATER
                val m = mask(!w(0, -1), !w(1, 0), !w(0, 1), !w(-1, 0))
                cached("water$m/$frame") { water(m, frame) }
            }
            Tile.TREE -> cached("treeground$seed") { grass(seed); blendEllipse(16.0, 26.0, 13.0, 5.0, SHADOW) }
            Tile.ROCK, Tile.SIGN, Tile.CHEST, Tile.WELL, Tile.CAMPFIRE -> {
                val base = baseGround(kind, seed)
                cached("obj-ground/${kind}/$seed/${t == Tile.CAMPFIRE}") {
                    paste(base)
                    blendEllipse(16.0, 27.0, 12.0, 4.0, SHADOW)
                    if (t == Tile.CAMPFIRE) blendEllipse(16.0, 22.0, 15.0, 10.0, alpha(0xF8B040, 0x30))
                }
            }
            Tile.ROOF, Tile.ROOF_BLUE, Tile.WINDOW -> cached("grass$seed") { grass(seed) }
            Tile.WALL -> when (kind) {
                MapKind.INTERIOR -> if (at(0, 1) != Tile.WALL && map.inside(tx, ty + 1)) cached("iwallface${tx % 3}") { interiorWallFace(tx % 3) } else cached("iwalltop") { interiorWallTop() }
                else -> cached("grass$seed") { grass(seed) }
            }
            Tile.DOOR -> if (kind == MapKind.INTERIOR) cached("doormat") { woodFloor(0); doormat() } else cached("path0/$seed") { path(0, seed) }
            Tile.CAVE_WALL, Tile.TORCH -> {
                fun wall(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.CAVE_WALL || it == Tile.TORCH || it == Tile.CAVE_ENTRANCE }
                val face = !wall(0, 1) && map.inside(tx, ty + 1)
                if (face) cached("cliff$seed/${t == Tile.TORCH}/$frame/${kind == MapKind.CAVE}") {
                    cliffFace(seed, kind != MapKind.CAVE)
                    if (t == Tile.TORCH) torch(frame)
                } else {
                    val m = mask(!wall(0, -1) && map.inside(tx, ty - 1), !wall(1, 0), false, !wall(-1, 0))
                    cached("rocktop$m/$seed") { rockTop(m, seed) }
                }
            }
            Tile.CAVE_ENTRANCE -> cached("caveentrance") { cliffFace(1, true); caveMouth() }
            Tile.CAVE_FLOOR, Tile.GATE -> {
                fun wall(dx: Int, dy: Int) = at(dx, dy).let { it == Tile.CAVE_WALL || it == Tile.TORCH }
                val m = mask(wall(0, -1), wall(1, 0), false, wall(-1, 0))
                cached("cavefloor$m/$seed") { caveFloor(seed, m) }
            }
            Tile.CAVE_EXIT -> cached("caveexit") { caveFloor(0, 0); exitLight() }
            Tile.WOOD_FLOOR -> {
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

    private val G = argb(0x7CC85A); private val G_D = argb(0x5EAA44); private val G_DD = argb(0x4A9038); private val G_L = argb(0x9ADC72)

    private fun Pen.grass(seed: Int) {
        fill(G)
        for (y in 0 until T) for (x in 0 until T) {
            val n = noise(x, y, 11 + seed) % 100
            if (n < 6) raw(x, y, G_D) else if (n < 9) raw(x, y, G_L)
        }
        // little tufts of blades
        for (i in 0 until 3) {
            val bx = 3 + noise(seed, i, 5) % 24
            val by = 6 + noise(i, seed, 9) % 22
            raw(bx, by, G_DD); raw(bx + 1, by - 1, G_D); raw(bx + 2, by, G_DD); raw(bx + 1, by - 2, G_L)
            raw(bx + 4, by + 1, G_DD); raw(bx + 5, by, G_D)
        }
    }

    private fun Pen.flowers(seed: Int) {
        val colors = listOf(Pal.RED, Pal.WHITE, Pal.GOLD, argb(0xB070E0))
        listOf(6 to 7, 22 to 5, 13 to 20, 25 to 23).forEachIndexed { i, (x, y) ->
            val c = colors[(i + seed) % colors.size]
            raw(x, y + 3, G_DD); raw(x, y + 2, G_DD)
            raw(x, y - 1, c); raw(x - 1, y, c); raw(x + 1, y, c); raw(x, y + 1, c)
            raw(x, y, Pal.GOLD_DARK)
        }
    }

    private val TG = argb(0x3E9E42); private val TG_D = argb(0x2A7434); private val TG_DD = argb(0x1E5A2A); private val TG_L = argb(0x76CC5E)

    private fun Pen.tallGrass(seed: Int) {
        fill(TG_D)
        for (row in 0..3) for (col in 0..3) {
            val ox = col * 8 + (row % 2) * 4 - 2
            val oy = row * 8 + 1
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
                    y == oy + 8 - h -> TG_L
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

    private val P = argb(0xDCC28E); private val P_D = argb(0xC4A472); private val P_L = argb(0xECD8AC)

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

    private val W = argb(0x4A8EEC); private val W_D = argb(0x346FCC); private val W_L = argb(0x9ACCF8)

    private fun Pen.water(m: Int, frame: Int) {
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
    fun objects(map: MapDef, state: GameState, frame: Int): List<Obj> {
        val opened = map.chests.filter { it.id in state.openedChests }.joinToString(",") { it.id }
        val key = "${map.id}/$opened/${state.has(Story.GATE_OPEN)}/$frame/${state.has(Story.CHAPTER1_DONE)}"
        return objCache.getOrPut(key) { buildObjects(map, state, frame) }
    }

    private fun buildObjects(map: MapDef, state: GameState, frame: Int): List<Obj> {
        val out = mutableListOf<Obj>()
        val seen = HashSet<Pair<Int, Int>>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val t = map.tile(tx, ty)
            val px = tx * T
            val py = ty * T
            val bottom = py + T - 1
            val seed = Math.floorMod(tx * 7 + ty * 13, 4)
            when (t) {
                Tile.TREE -> out += Obj(tree(seed, map.kind == MapKind.FOREST && seed == 3), px, py - 18, bottom)
                Tile.ROCK -> out += Obj(cached("rock") { rock() }, px, py, bottom)
                Tile.SIGN -> out += Obj(cached("sign") { sign() }, px, py, bottom)
                Tile.CHEST -> {
                    val open = map.chestAt(tx, ty)?.id in state.openedChests
                    out += Obj(cached("chest$open") { chest(open) }, px, py, bottom)
                }
                Tile.WELL -> out += Obj(cached("well", T, 48) { well() }, px, py - 16, bottom)
                Tile.CAMPFIRE -> out += Obj(cached("fire$frame") { campfire(frame) }, px, py, bottom)
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
                    if (map.kind == MapKind.TOWN && (tx to ty) !in seen) out += building(map, tx, ty, seen)
                }
                else -> {}
            }
        }
        return out
    }

    // ------------------------------------------------------------------ objects: nature

    private val LEAF = argb(0x3C9440); private val LEAF_D = argb(0x2A6E30); private val LEAF_DD = argb(0x1C4E24); private val LEAF_L = argb(0x6EC458)

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

    private fun Pen.rock() {
        ellipse(16.0, 21.0, 12.5, 9.5, Pal.STONE_DARK)
        ball(15.0, 19.5, 11.5, 8.5, Pal.STONE, Pal.STONE_LIGHT, Pal.STONE_DARK)
        ellipse(21.0, 23.0, 5.0, 4.0, Pal.STONE_DARK)
        raw(12, 18, Pal.STONE_DARK); raw(13, 19, Pal.STONE_DARK); raw(14, 20, Pal.STONE_DARK)
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

    private val PLASTER = argb(0xF2E4C0); private val PLASTER_D = argb(0xD8C49C)
    private val TIMBER = argb(0x6E4626); private val TIMBER_L = argb(0x8A5E36)

    /** Finds the whole building containing (sx, sy) and draws it as one object with façade and roof. */
    private fun building(map: MapDef, sx: Int, sy: Int, seen: MutableSet<Pair<Int, Int>>): Obj {
        val parts = setOf(Tile.ROOF, Tile.ROOF_BLUE, Tile.WALL, Tile.WINDOW, Tile.DOOR)
        val queue = ArrayDeque(listOf(sx to sy))
        val cells = mutableListOf<Pair<Int, Int>>()
        seen += sx to sy
        while (queue.isNotEmpty()) {
            val (x, y) = queue.removeFirst()
            cells += x to y
            for ((dx, dy) in listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)) {
                val n = x + dx to y + dy
                if (n !in seen && map.inside(n.first, n.second) && map.tile(n.first, n.second) in parts) {
                    seen += n
                    queue += n
                }
            }
        }
        val x0 = cells.minOf { it.first }; val x1 = cells.maxOf { it.first }
        val y0 = cells.minOf { it.second }; val y1 = cells.maxOf { it.second }
        val wTiles = x1 - x0 + 1
        val hTiles = y1 - y0 + 1
        val blue = cells.any { map.tile(it.first, it.second) == Tile.ROOF_BLUE }
        val facade = (x0..x1).map { map.tile(it, y1) }
        val key = "house/$wTiles/$hTiles/$blue/${facade.joinToString("") { it.ch.toString() }}"
        val over = 16 // roof reaches this far into the tile row above
        val img = cache.getOrPut(key) {
            draw(wTiles * T + 6, hTiles * T + over) { house(wTiles, hTiles, blue, facade, over) }
        }
        return Obj(img, x0 * T, y0 * T - over, (y1 + 1) * T - 1)
    }

    private fun Pen.house(wTiles: Int, hTiles: Int, blue: Boolean, facade: List<Tile>, over: Int) {
        val W = wTiles * T
        val wallTop = over + (hTiles - 1) * T - 10 // a tall façade reads better in this view
        val roofBottom = wallTop + 5 // eave overlaps the façade a little
        val wallBottom = over + hTiles * T - 1

        // drop shadow to the right
        for (y in roofBottom - 8..wallBottom) for (x in W until W + 6) raw(x, y, SHADOW_SOFT)

        // façade
        rect(0, wallTop, W - 1, wallBottom, PLASTER)
        for (y in wallTop..wallBottom) for (x in 0 until W) if (noise(x, y, 5) % 23 == 0) raw(x, y, PLASTER_D)
        rect(0, wallBottom - 3, W - 1, wallBottom, Pal.STONE) // foundation
        for (x in 0 until W step 5) raw(x, wallBottom - 2, Pal.STONE_DARK)
        rect(0, wallBottom - 4, W - 1, wallBottom - 4, TIMBER)
        rect(0, wallTop, 2, wallBottom - 4, TIMBER); rect(W - 3, wallTop, W - 1, wallBottom - 4, TIMBER)
        facade.forEachIndexed { i, t ->
            val fx = i * T
            if (i > 0) rect(fx - 1, wallTop, fx, wallBottom - 4, TIMBER)
            when (t) {
                Tile.WINDOW -> {
                    rect(fx + 7, wallTop + 9, fx + 24, wallTop + 22, TIMBER)
                    rect(fx + 9, wallTop + 11, fx + 22, wallTop + 20, Pal.GLASS)
                    rect(fx + 15, wallTop + 11, fx + 16, wallTop + 20, TIMBER)
                    raw(fx + 10, wallTop + 12, Pal.WHITE); raw(fx + 11, wallTop + 12, Pal.WHITE); raw(fx + 10, wallTop + 13, Pal.WHITE)
                    rect(fx + 6, wallTop + 23, fx + 25, wallTop + 25, Pal.WOOD) // flower box
                    for (x in fx + 7..fx + 24 step 3) { raw(x, wallTop + 22, Pal.RED); raw(x + 1, wallTop + 22, G_D) }
                }
                Tile.DOOR -> {
                    rect(fx + 6, wallTop + 6, fx + 25, wallBottom - 4, TIMBER)
                    rect(fx + 8, wallTop + 8, fx + 23, wallBottom - 4, Pal.WOOD)
                    ellipse(fx + 16.0, wallTop + 9.0, 8.0, 4.0, Pal.WOOD)
                    for (x in fx + 11..fx + 21 step 5) rect(x, wallTop + 8, x, wallBottom - 4, Pal.WOOD_DARK)
                    raw(fx + 21, wallTop + 18, Pal.GOLD); raw(fx + 21, wallTop + 19, Pal.GOLD_DARK)
                    rect(fx + 5, wallBottom - 3, fx + 26, wallBottom, Pal.STONE_LIGHT) // step
                }
                else -> { // half-timbering cross
                    line(fx + 4, wallTop + 6, fx + 27, wallBottom - 6, TIMBER)
                    line(fx + 27, wallTop + 6, fx + 4, wallBottom - 6, TIMBER)
                }
            }
        }

        // roof: front slope seen from above at an angle. It narrows towards the ridge, the
        // slanted gable edges are shaded, and shingle rows get darker towards the top.
        val c = if (blue) Pal.ROOF_BLUE else Pal.ROOF
        val d = if (blue) Pal.ROOF_BLUE_DARK else Pal.ROOF_DARK
        val l = mix(c, Pal.WHITE, 0.25)
        val roofTop = 2
        val span = (roofBottom - roofTop).toDouble()
        for (y in roofTop..roofBottom) {
            val t = (y - roofTop) / span
            val inset = (10 * (1 - t)).toInt()
            val rowFromEave = (roofBottom - y) / 5
            val base = mix(c, d, (1 - t) * 0.45)
            for (x in inset until W - inset) {
                var col = base
                if ((roofBottom - y) % 5 == 0) col = mix(base, d, 0.6) // shingle row edge
                else if ((roofBottom - y) % 5 == 4) col = mix(base, Pal.WHITE, 0.12)
                if ((roofBottom - y) % 5 != 0 && (x + rowFromEave * 4) % 8 == 0) col = mix(base, d, 0.45)
                // gable edges
                if (x < inset + 4) col = mix(d, Pal.OUTLINE, 0.25)
                if (x >= W - inset - 4) col = mix(d, Pal.OUTLINE, 0.45)
                raw(x, y, col)
            }
        }
        // ridge cap with highlight
        rect(10, roofTop, W - 11, roofTop + 2, d)
        for (x in 10 until W - 10) raw(x, roofTop, l)
        // eave board and its shadow on the wall
        rect(0, roofBottom, W - 1, roofBottom + 1, Pal.WOOD_DARK)
        for (y in roofBottom + 2..roofBottom + 5) for (x in 3 until W - 3) blend(x, y, alpha(0x201010, 0x70 - (y - roofBottom) * 12))
        // chimney
        if (wTiles >= 4) {
            val cx = W - 44
            rect(cx, 0, cx + 9, roofTop + 12, argb(0x9A5A48))
            for (y in 2..roofTop + 12 step 4) for (x in cx..cx + 9) if ((x + y) % 5 == 0) raw(x, y, argb(0x7A4434))
            rect(cx - 1, 0, cx + 10, 1, Pal.STONE_DARK)
        }
        outline(Pal.OUTLINE)
    }

    // ------------------------------------------------------------------ characters

    /** Soft shadow under a character's feet. */
    fun shadow(): PixelImage = cached("char-shadow", 24, 8) { ellipse(12.0, 4.0, 11.0, 3.5, SHADOW) }
}
