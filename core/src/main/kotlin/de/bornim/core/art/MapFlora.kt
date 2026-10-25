package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile

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


    // ------------------------------------------------------------------ the kinds

    enum class Kind { OAK, SPRUCE, DEAD, BUSH }

    /** A picture with its foot point (anchor) in art pixels. */
    class Sprite(val img: PixelImage, val ax: Int, val ay: Int)

    private val cache = HashMap<String, Sprite>()

    private fun cached(key: String, make: () -> Sprite): Sprite = synchronized(cache) { cache[key] } ?: make().also { synchronized(cache) { cache[key] = it } }

    /** An oak-like tree; [size] 0..2 small to large, [deep] the darker, older wood. */
    fun oak(variant: Int, size: Int, deep: Boolean): Sprite = cached("oak/$variant/$size/$deep") { MapTree.oak(variant, size, deep) }

    /** A spruce in drooping tiers. */
    fun spruce(variant: Int, size: Int, young: Boolean = false): Sprite = cached("spruce/$variant/$size/$young") { MapTree.spruce(variant, size, young) }

    /** A dead tree, grey and bare, its branches reaching up. */
    fun deadTree(variant: Int): Sprite = cached("dead/$variant") { MapTree.deadTree(variant) }











    /** 353 (draft, preview `WEGSICHT=n`): how many tiles in front of a way of the deep forest only young spruces grow; 0 off. */
    @Volatile var wayDraft = 0

    /** Whether a tall crown on tile ([tx], [ty]) would hide something that must stay in sight (43). */
    fun shades(map: MapDef, tx: Int, ty: Int): Boolean {
        val deep = map.id == "deep_forest"
        // a chest just north of this tree must stay visible: a slim young spruce instead of a broad crown
        // the tall crowns reach up to three tiles north: where they would hide something one needs to
        // find (a chest, the fire, a sign, someone to talk to, a way out), a young spruce stands instead
        fun important(x: Int, y: Int) = map.tile(x, y).let { it == Tile.CHEST || it == Tile.CAMPFIRE || it == Tile.SIGN || it == Tile.CAVE_ENTRANCE ||
            // in the village: the fields and yards behind the edge of the wood stay in sight
            (map.kind == de.bornim.core.MapKind.TOWN && (it == Tile.CROPS || it == Tile.VEG_BED || it == Tile.HAY || it == Tile.FENCE || it == Tile.WASHLINE)) } ||
            map.npcs.any { it.x == x && it.y == y } || map.warpAt(x, y) != null
        // seen diagonally (43), a tall crown hides what lies up to eight tiles behind it towards the top of the screen
        // (north and west): there the stones of the circle count too, but a chest may stay hidden under the trees
        fun seen(x: Int, y: Int) = map.inside(x, y) && (map.tile(x, y) == Tile.MENHIR || (important(x, y) && map.tile(x, y) != Tile.CHEST))
        // the old oaks of the deep forest (27.6) stand so close that a crown twelve steps in front still reaches
        // over Morwen's fire: there the reach goes as high as the tallest crown (about 12 half tiles)
        val reach = if (deep) 12 else 8
        // 353 (draft, Chef 24.10.: "der Weg ist unter den Baumkronen nicht zu sehen"): just in front of a way of the deep
        // forest only young spruces, so the way and the hero on it stay in sight
        if (deep && wayDraft > 0 && (1..wayDraft).any { n -> (0..n).any { bx -> kotlin.math.abs(bx - (n - bx)) <= 1 && map.inside(tx - bx, ty - n + bx) && map.tile(tx - bx, ty - n + bx) == Tile.PATH } }) return true
        return (0..reach).any { bx -> (0..reach).any { by -> bx + by in 1..reach && kotlin.math.abs(bx - by) <= 2 && seen(tx - bx, ty - by) } }
    }

    /**
     * 216.3 (Chef, Build 51: "Ist es der Busch?"): where a tree tile is drawn as one low bush ([shrubs]), the part of
     * the tile it fills, (x0, y0, x1, y1) within the tile, its shadow round the foot at the lower edge; else null.
     */
    fun bushSpot(map: MapDef, tx: Int, ty: Int): DoubleArray? {
        if (map.tile(tx, ty) != Tile.TREE || !shades(map, tx, ty)) return null
        val town = map.kind == de.bornim.core.MapKind.TOWN
        val pick = hash(tx, ty, 17) % 10
        val lone = closeBehind(map, tx, ty) || ((town || map.id == "deep_forest") && pick < (if (town) 6 else 3))
        if (!lone) return null
        val wide = if (hash(tx, ty, 19) % 6 % 3 == 2) 1.35 else 1.0
        val mx = 0.5 + (rnd(tx, ty, 22) - 0.5) * 0.5 + 0.06
        return doubleArrayOf((mx - 0.26 * wide).coerceAtLeast(0.0), 1.0 - 0.22 * wide, (mx + 0.26 * wide).coerceAtMost(1.0), 1.0)
    }

    /** D6.2: someone (or a door) just behind, towards the top of the screen, where only a low bush may stand. */
    private fun closeBehind(map: MapDef, tx: Int, ty: Int) =
        (0..3).any { bx -> (0..3).any { by -> bx + by in 1..3 && (map.npcs.any { it.x == tx - bx && it.y == ty - by } || map.warpAt(tx - bx, ty - by) != null) } }

    /** The low growth on a tile where a tall crown would hide something ([shades]); also beyond the edge (83). */
    fun shrubs(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj> {
        val deep = map.id == "deep_forest"
        val cx = (tx + 0.5) * S; val cy = (ty + 0.5) * S
        // set off a little each, some two small ones side by side; in the village mostly bushes, a hedge in front
        // of the fields and beds (83, user 14.10.); D3.3: in the deep forest the young ones grow in three heights and stand further apart within their tile,
        // so that a run of such tiles never reads as one row
        fun young(k: Int) = obj(spruce(hash(tx, ty, 6 + k) % 6, if (deep) hash(tx, ty, 24 + k) % 3 else 1, young = true),
            cx + (rnd(tx, ty, 18 + k) - 0.5) * S * (if (deep) 0.9 else 0.6),
            cy + S * (if (deep) 0.2 + rnd(tx, ty, 20 + k) * 0.75 else 0.45 + rnd(tx, ty, 20 + k) * 0.3))
        return when (lowKind(map, tx, ty)) {
            Low.BUSH -> listOf(MapWoodIso.bushObj(((cx + (rnd(tx, ty, 22) - 0.5) * S * 0.5) / D).toInt(), ((cy + S * 0.5) / D).toInt(), hash(tx, ty, 19) % 6))
            Low.YOUNG2 -> listOf(young(0), young(1))
            Low.YOUNG -> listOf(young(0))
        }
    }

    /** What low growth [shrubs] puts on a tile (348.6: also for the export to the new engine). */
    enum class Low { BUSH, YOUNG, YOUNG2 }

    fun lowKind(map: MapDef, tx: Int, ty: Int): Low {
        val pick = hash(tx, ty, 17) % 10
        val town = map.kind == de.bornim.core.MapKind.TOWN
        val deep = map.id == "deep_forest"
        return when {
            // D6.2: someone (or a door) just behind, towards the top of the screen, would still be half hidden by young
            // spruces taller than a person: there only a low bush
            closeBehind(map, tx, ty) -> Low.BUSH
            // D3.3: in the woods too set off a little each, now and then two side by side, never in rows
            !town && !deep -> if (pick < 3) Low.YOUNG2 else Low.YOUNG
            // the bush in the slant like those of the undergrowth (56)
            pick < (if (town) 6 else 3) -> Low.BUSH
            pick < (if (town) 8 else 6) -> Low.YOUNG2
            else -> Low.YOUNG
        }
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
                if (shades(map, tx, ty)) return shrubs(map, tx, ty)
                val count = if (hash(tx, ty, 1) % 3 == 0) 2 else 1
                for (k in 0 until count) {
                    // D29.3: now and then the small second tree of the woods is a stump with its roots
                    // (not beside the path, where it would seem to stand on it)
                    if (k == 1 && map.kind == de.bornim.core.MapKind.FOREST && hash(tx, ty, 47) % 3 == 0 &&
                        listOf(-1 to 0, 1 to 0, 0 to -1, 0 to 1).none { (dx, dy) -> map.tile(tx + dx, ty + dy) == Tile.PATH }) {
                        val px = cx + (rnd(tx, ty, 48) - 0.5) * S * 0.4; val py = cy + S * 0.4
                        out += MapWoodIso.stumpObj((px / D).toInt(), (py / D).toInt(), hash(tx, ty, 49) % 3)
                        continue
                    }
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

    /** Bushes, ferns and in the woods the small things of the floor ([MapWoodIso.litter]) on open ground, thicker near the trees; never on the path or water. */
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
            // D29.3: mushrooms, cones and fallen branches on the forest floor, more of them under the trees
            if (map.kind == de.bornim.core.MapKind.FOREST && rnd(tx, ty, 50) < 0.04 + near * 0.04) {
                val px = (tx + 0.2 + rnd(tx, ty, 51) * 0.6) * S; val py = (ty + 0.2 + rnd(tx, ty, 52) * 0.6) * S
                out += MapWoodIso.litterObj((px / D).toInt(), (py / D).toInt(), hash(tx, ty, 53) % 9)
            }
        }
        return out
    }

    // ------------------------------------------------------------------ shadows

    /** The shadows of all that stands under the open sky, by the sun ([MapSun], 89); drawn under it, faded by the time of day. */
    fun shadows(map: MapDef): List<WorldArt.Obj> = MapSun.shadows(map)

    /** The same without waiting (D9.2): null while the layer is still drawn in the background. */
    fun shadowsReady(map: MapDef): MapSun.Ready? = MapSun.ready(map)
}
