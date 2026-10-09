package de.bornim.core.art

import de.bornim.core.Build
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Sex

/**
 * The folk about the map as dolls, like the hero ([MapFigure]): same size, same slant from above,
 * turning smoothly in [MapFigure.YAWS] directions. Each has a doll and an outfit of its own; folk
 * without one here are still drawn as the former little figures.
 *
 * Pictures are drawn ahead in the background ([prepare]) and kept by person, direction and pose.
 */
object MapFolk {
    class Folk(val id: String, val doll: Doll, val outfit: Outfit)

    private fun kit(vararg bases: String): Map<GearSlot, Gear> =
        bases.associate { b -> Gear(0, b, Rarity.COMMON, 1).let { it.def.slot to it } }

    /**
     * Garrick, the hunter at the fire in the woods (09.10.): a broad man with a short full beard,
     * a hood and cloak of dark olive wool, dark leather, the longbow slung across his back over
     * the quiver, both hands free.
     */
    val garrick = Folk(
        "garrick",
        Doll(Race.HUMAN, Sex.MALE, Build.STRONG, skin = 2, hairTone = 1, beard = true),
        Outfit(CharClass.ROGUE, kit("hood", "leather", "gloves", "boots", "cloak", "longbow"),
            cloakRgb = 0x36402A, bowOnBack = true, leatherRgb = 0x4A3826),
    )

    private val all = listOf(garrick).associateBy { it.id }

    /** The doll for the person [npcId], or null when that one is still drawn the former way. */
    fun of(npcId: String): Folk? = all[npcId]

    /** Standing still or walking: [step] as in [MapFigure.STEPS]. */
    fun draw(f: Folk, slot: Int, step: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, MapFigure.rig(slot * 360.0 / MapFigure.YAWS, step, MapFigure.Carry.FREE))

    private val cache = HashMap<String, PixelImage>()
    private val preparing = HashSet<String>()

    /** The picture of [f] turned to [slot] at [step], or null while it is not drawn yet. */
    fun frame(f: Folk, slot: Int, step: Int): PixelImage? =
        synchronized(cache) { cache["${f.id}|$slot|${Math.floorMod(step, MapFigure.STEPS)}"] }

    /** The picture to show now, never nothing (see [MapFigure.frameNow]). */
    fun frameNow(f: Folk, slot: Int, step: Int): PixelImage {
        frame(f, slot, step)?.let { return it }
        frame(f, slot, 0)?.let { return it }
        for (d in 1..2) for (s in listOf(slot - d, slot + d)) frame(f, Math.floorMod(s, MapFigure.YAWS), 0)?.let { return it }
        val img = draw(f, slot, 0)
        synchronized(cache) { cache["${f.id}|$slot|0"] = img }
        return img
    }

    /** Starts drawing the folk standing on [map] in the background, each facing its own way first. */
    fun prepareFor(map: de.bornim.core.MapDef) {
        for (npc in map.npcs) of(npc.id)?.let { prepare(it, MapFigure.slot(MapFigure.yawOf(npc.facing))) }
    }

    /** Draws every picture of [f] in the background, the directions nearest to [nearSlot] first. */
    fun prepare(f: Folk, nearSlot: Int = 0) {
        synchronized(cache) { if (!preparing.add(f.id)) return }
        val n = MapFigure.YAWS
        val order = (0 until n).sortedBy { minOf(Math.floorMod(it - nearSlot, n), Math.floorMod(nearSlot - it, n)) }
        val t = Thread {
            for (s in order) for (st in 0 until MapFigure.STEPS) {
                val k = "${f.id}|$s|$st"
                if (synchronized(cache) { k in cache }) continue
                val img = draw(f, s, st)
                synchronized(cache) { cache[k] = img }
            }
        }
        t.isDaemon = true
        t.priority = Thread.MIN_PRIORITY + 1
        t.start()
    }

    /** Draws every picture of [f] right away (previews and tests). */
    fun prepareNow(f: Folk) {
        synchronized(cache) { preparing += f.id }
        for (s in 0 until MapFigure.YAWS) for (st in 0 until MapFigure.STEPS) {
            val k = "${f.id}|$s|$st"
            if (synchronized(cache) { k in cache }) continue
            val img = draw(f, s, st)
            synchronized(cache) { cache[k] = img }
        }
    }
}
