package de.bornim.core.art

import de.bornim.core.GameState
import de.bornim.core.Jobs
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Story
import de.bornim.core.Tile

/**
 * What all maps share: the [Obj] pictures standing on them, sorted with the figures by [Obj.sortY], and what shines
 * by itself at night ([Glow]). Every map is seen diagonally (13); the straight pictures are gone (13t). Each place
 * draws its own: the woods [MapWoodIso] and [MapFlora], the village [MapTownIso], the rooms [MapRoomIso], the cave
 * [MapCaveIso]; the ground under them is [MapGround].
 */
object WorldArt {
    const val T = 32

    /** A drawable at map pixel position ([x], [y]) = top-left, ordered by [sortY]; [density] art pixels per map pixel (2 for the finer new pictures). */
    /** [low]: never tall enough to hide a figure behind it (furniture of the rooms seen diagonally, 13). */
    /** [corner]: seen diagonally, the picture's foot is the tile's front corner (the rooms, [MapRoomIso]), not the middle of its lower edge. */
    /** [area]: the footprint of the house a strip belongs to (5.1), so the see-through test can ask whether the hero stands behind it. */
    class Obj(val img: PixelImage, val x: Int, val y: Int, val sortY: Int, val density: Int = 1, val low: Boolean = false, val corner: Boolean = false, val group: Int = 0,
              val glow: Glow? = null, val area: MapTownIso.Footprint? = null)

    /**
     * What of a picture shines by itself at night (25.1: a street lamp's glass; 25b: lit windows): [img] the same size
     * as the picture, only the shining pixels; ([cx], [cy]) the middle of the light in it, [halo] how strong a glow
     * around it; the tile ([tx], [ty]) decides whether the hero has seen it. Drawn over the light of the place.
     */
    class Glow(val img: PixelImage, val cx: Int, val cy: Int, val tx: Int = 0, val ty: Int = 0, val halo: Float = 1f) {
        fun at(tx: Int, ty: Int) = Glow(img, cx, cy, tx, ty, halo)
    }

    private val cache = HashMap<String, PixelImage>()
    private fun cached(key: String, w: Int = T, h: Int = T, block: Pen.() -> Unit) = cache.getOrPut(key) { draw(w, h, block = block) }

    private val SHADOW = alpha(0x0C0E14, 0x70)

    private val objCache = HashMap<String, List<Obj>>()

    /** All pictures standing on [map], drawn diagonally. */
    fun objects(map: MapDef, state: GameState, frame: Int, flicker: Int = 0): List<Obj> {
        val opened = map.chests.filter { it.id in state.openedChests }.joinToString(",") { it.id }
        val key = "${map.id}/$opened/${state.has(Story.GATE_OPEN)}/${state.has(Story.BARRIER_OPEN)}/$frame/${state.has(Story.CHAPTER1_DONE)}/$flicker/${map.kind == MapKind.TOWN && Jobs.freshNote(state)}"
        return objCache.getOrPut(key) { buildObjects(map, state, frame, flicker) }
    }

    private fun buildObjects(map: MapDef, state: GameState, frame: Int, flicker: Int = 0): List<Obj> {
        val out = mutableListOf<Obj>()
        // the woods' and the village's undergrowth
        if (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) out += MapFlora.undergrowth(map)
        // beyond the edge the wood goes on (27m)
        if (MapEdge.applies(map)) out += MapEdge.trees(map)
        val freshNote = map.kind == MapKind.TOWN && Jobs.freshNote(state)
        val gate = state.has(Story.GATE_OPEN)
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val open = map.chestAt(tx, ty)?.id in state.openedChests
            out += when (map.kind) {
                MapKind.CAVE -> MapCaveIso.objects(map, tx, ty, frame, open, gate) ?: MapCave.objects(map, tx, ty, frame, open, gate)
                // the houses stand in the slant, cut into strips sorted along the diagonal (5.1); else the trees of the woods
                MapKind.TOWN -> MapTownIso.objects(map, tx, ty, freshNote, state.has(Story.BARRIER_OPEN)) ?: MapWoodIso.fieldObjects(map, tx, ty)
                    // 355: the village's chests look like the woods'
                    ?: (if (map.tile(tx, ty) == Tile.CHEST) MapWoodIso.objects(map, tx, ty, frame, open) else null)
                    ?: MapFlora.objects(map, tx, ty, frame, open)
                // the rooms' walls and furniture stand upright, turned with the room
                MapKind.INTERIOR -> MapRoomIso.objects(map, tx, ty, flicker)
                // the trunks, the fire, the rock face and the signs of the woods stand in the slant too (27.5)
                MapKind.FOREST -> MapWoodIso.objects(map, tx, ty, frame, open) ?: MapTownIso.houseObjects(map, tx, ty) ?: MapFlora.objects(map, tx, ty, frame, open)
            } ?: continue
        }
        return out
    }

    // ------------------------------------------------------------------ the woods behind a fight ([BattleArt])

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

    // ------------------------------------------------------------------ characters

    // ------------------------------------------------------------------ characters

    /** Soft shadow under a character's feet: a level circle, so 2:1 in the diagonal view (D1.5). */
    fun shadow(): PixelImage = cached("char-shadow", 24, 8) { ellipse(12.0, 4.0, 7.8, 3.9, SHADOW) }

    /** D3.6: under an animal a shadow as wide as the picture of it seen now, [w] map pixels (a person's is 24). */
    fun shadow(w: Int): PixelImage {
        val ww = w.coerceIn(8, 56) / 2 * 2; val h = maxOf(6, ww / 3)
        return cached("char-shadow-$ww", ww, h) { ellipse(ww / 2.0, h / 2.0, ww * 0.325, h * 0.4875, SHADOW) }
    }

    /** The same under something small, a hen or a cat (83b). */
    fun smallShadow(): PixelImage = cached("small-shadow", 12, 6) { ellipse(6.0, 3.0, 4.4, 2.2, SHADOW) }
}
