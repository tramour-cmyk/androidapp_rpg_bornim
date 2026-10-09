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

    /**
     * What one of the folk does while standing about (09.10.): [WARM] holds both hands out to the fire
     * and rubs them, [PEER] shades the eyes with the right hand and looks slowly from side to side.
     * Each is a short loop of [frames] pictures, shown [frameMs] apiece.
     */
    enum class Idle(val frames: Int, val frameMs: Long) { WARM(4, 260), PEER(5, 420) }

    /** The pose of [idle] at picture [i], the body turned to [yaw]. */
    fun idleRig(yaw: Double, idle: Idle, i: Int): HeroFigure.Rig {
        val base = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE)
        return when (idle) {
            Idle.WARM -> {
                // palms to the flames at belly height, the elbows bent; rubbing: the hands slide past each other
                val k = listOf(0.0, 1.0, 0.0, -1.0)[Math.floorMod(i, 4)]
                base.copy(
                    lean = 0.1, headDown = 2.5, spread = 7.0,
                    rh = HeroFigure.V(7.0 + k * 1.2, 64.0 + k * 1.2, 19.0),
                    lh = HeroFigure.V(-7.0 + k * 1.2, 64.0 - k * 1.2, 19.0),
                )
            }
            Idle.PEER -> {
                // the right hand flat over the brow, the head sweeping slowly left and right
                val turn = listOf(-28.0, -12.0, 4.0, 18.0, 30.0)[Math.floorMod(i, 5)]
                base.copy(
                    headDown = -1.5, headTurn = turn, twist = turn * 0.2,
                    rh = HeroFigure.V(2.0, 95.0, 9.0), elbowUp = 0.7, elbowAt = HeroFigure.V(24.0, 86.0, 6.0),
                    lh = HeroFigure.V(-16.0, 54.0, 6.0),
                )
            }
        }
    }

    /** One idle picture of [f] turned to [slot]. */
    fun drawIdle(f: Folk, slot: Int, idle: Idle, i: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, idleRig(slot * 360.0 / MapFigure.YAWS, idle, i))

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
