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

    /**
     * Warding off a beast with a brand from the fire (09.10.): [GRAB] bent over the fire, the torch
     * end in the flames; [HOLD] the torch raised before the chest; [LEFT] and [RIGHT] swung high to
     * either side, back and forth at the beast.
     */
    enum class Ward { GRAB, HOLD, LEFT, RIGHT }

    /** Pictures of the flame per stance, flickering in turn. */
    const val FLICKERS = 3

    /** The pose of [ward], the body turned to [yaw], the flame in its [flicker]th shape. */
    fun wardRig(yaw: Double, ward: Ward, flicker: Int): HeroFigure.Rig {
        val base = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE).copy(torch = 1.0, flicker = flicker, aim = 1.0, grip = 10.0)
        return when (ward) {
            Ward.GRAB -> base.copy(lean = 0.45, crouch = 7.0, stride = 6.0, headDown = 3.0,
                rh = HeroFigure.V(8.0, 48.0, 22.0), weapon = HeroFigure.V(0.05, -0.6, 0.8), lh = HeroFigure.V(-14.0, 52.0, 12.0))
            Ward.HOLD -> base.copy(lean = 0.05, stride = 5.0,
                rh = HeroFigure.V(12.0, 78.0, 22.0), weapon = HeroFigure.V(0.1, 0.85, 0.5), lh = HeroFigure.V(-15.0, 56.0, 8.0))
            Ward.LEFT -> base.copy(lean = 0.12, stride = 8.0, twist = -14.0, headDown = -1.0,
                rh = HeroFigure.V(0.0, 84.0, 28.0), weapon = HeroFigure.V(-0.7, 0.45, 0.55), lh = HeroFigure.V(-18.0, 66.0, 14.0))
            Ward.RIGHT -> base.copy(lean = 0.12, stride = 8.0, twist = 14.0, headDown = -1.0,
                rh = HeroFigure.V(26.0, 84.0, 22.0), weapon = HeroFigure.V(0.75, 0.42, 0.5), lh = HeroFigure.V(-16.0, 62.0, 16.0))
        }
    }

    /** One warding picture of [f] turned to [slot]. */
    fun drawWard(f: Folk, slot: Int, ward: Ward, flicker: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, wardRig(slot * 360.0 / MapFigure.YAWS, ward, flicker), WARD_W, WARD_H)

    /** Warding pictures are wider and taller: the torch reaches far out and up. */
    const val WARD_W = 152
    const val WARD_H = 150

    /** How near (in tiles each way) the hero must be for the folk to look at it. */
    const val WATCH_TILES = 4.0

    /** After the hero has stood this long on one spot, the folk lose interest and go back to what they did (20:56). */
    const val BORED_MS = 20_000L

    /** Whether one of the folk looks at a hero [dx], [dy] tiles away who has stood still for [stillMs]. */
    fun watches(dx: Double, dy: Double, stillMs: Long): Boolean =
        kotlin.math.abs(dx) <= WATCH_TILES && kotlin.math.abs(dy) <= WATCH_TILES && (dx != 0.0 || dy != 0.0) && stillMs < BORED_MS

    /** How long the hero has stood on one spot: [forMs] restarts whenever the position changes. */
    class Stillness {
        private var x = Int.MIN_VALUE
        private var y = Int.MIN_VALUE
        private var since = 0L
        fun forMs(px: Int, py: Int, now: Long): Long {
            if (px != x || py != y || now < since) { x = px; y = py; since = now }
            return now - since
        }
    }

    /** What the folk do at [clockMs]: null while standing still, else the loop, its picture and which way the body turns. */
    class Doing(val idle: Idle, val frame: Int, val slotOffset: Int)

    /** Directions, in slots from the home direction, a peering one turns to: away from the fire, a little to either side. */
    val PEER_OFFSETS = listOf(7, 9)

    /**
     * Garrick's day at the fire, never on a beat (20:53: a steady rhythm looks like a machine). Time
     * is cut into blocks of [BLOCK_MS]; in each, chance picks whether he does anything at all, when he
     * starts, for how long, and what: mostly warming his hands, now and then peering into the woods,
     * and how fast his loop runs. So the pauses between run from about 2½ s to over half a minute.
     */
    fun doing(f: Folk, clockMs: Long): Doing? {
        val n = Math.floorDiv(clockMs, BLOCK_MS)
        val t = clockMs - n * BLOCK_MS
        val r = java.util.Random(n * 1_000_003L + f.id.hashCode())
        if (r.nextDouble() < 0.2) return null
        val start = 2_000L + (r.nextDouble() * 7_000).toLong()
        val length = 3_500L + (r.nextDouble() * 3_000).toLong()
        val idle = if (r.nextDouble() < 0.35) Idle.PEER else Idle.WARM
        val pace = 0.8 + r.nextDouble() * 0.45
        val off = PEER_OFFSETS[r.nextInt(PEER_OFFSETS.size)]
        if (t < start || t >= start + length) return null
        val step = ((t - start) / (idle.frameMs * pace)).toInt()
        // peering sweeps there and back; warming loops
        val frame = if (idle == Idle.PEER) { val m = 2 * (idle.frames - 1); val q = Math.floorMod(step, m); if (q < idle.frames) q else m - q }
            else Math.floorMod(step, idle.frames)
        return Doing(idle, frame, if (idle == Idle.PEER) off else 0)
    }

    const val BLOCK_MS = 16_000L

    /** [f] standing in [rest], breathing in or out: drawn in the background when first wanted, null until then. */
    fun restFrame(f: Folk, slot: Int, rest: MapRest.Rest, breath: Int): PixelImage? =
        if (rest == MapRest.Rest.NEUTRAL && breath == 0) frame(f, slot, 0)
        else MapRest.picture("folk|${f.id}|$slot|$rest|$breath") { drawRest(f, slot, rest, breath) }

    /** One resting picture of [f], drawn now. */
    fun drawRest(f: Folk, slot: Int, rest: MapRest.Rest, breath: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, MapRest.rig(MapFigure.rig(slot * 360.0 / MapFigure.YAWS, 0, MapFigure.Carry.FREE), rest, breath))

    /** The idle picture, or null while it is not drawn yet. */
    fun idleFrame(f: Folk, slot: Int, idle: Idle, i: Int): PixelImage? = synchronized(cache) { cache["${f.id}|$slot|$idle|$i"] }

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

    /** Starts drawing the folk standing on [map] in the background, each facing its own way first, then their idle loops. */
    fun prepareFor(map: de.bornim.core.MapDef) {
        for (npc in map.npcs) of(npc.id)?.let { prepare(it, MapFigure.slot(MapFigure.yawOf(npc.facing))) }
    }

    /** Draws the idle loops of [f] about its home direction [homeSlot] in the background (after its walk). */
    private fun prepareIdle(f: Folk, homeSlot: Int) {
        val n = MapFigure.YAWS
        val jobs = buildList {
            for (i in 0 until Idle.WARM.frames) add(Triple(homeSlot, Idle.WARM, i))
            for (o in PEER_OFFSETS) for (i in 0 until Idle.PEER.frames) add(Triple(Math.floorMod(homeSlot + o, n), Idle.PEER, i))
        }
        for ((s, idle, i) in jobs) {
            val k = "${f.id}|$s|$idle|$i"
            if (synchronized(cache) { k in cache }) continue
            val img = drawIdle(f, s, idle, i)
            synchronized(cache) { cache[k] = img }
        }
    }

    /** Draws every picture of [f] in the background, the directions nearest to [nearSlot] first. */
    fun prepare(f: Folk, nearSlot: Int = 0) {
        synchronized(cache) { if (!preparing.add(f.id)) return }
        val n = MapFigure.YAWS
        val order = (0 until n).sortedBy { minOf(Math.floorMod(it - nearSlot, n), Math.floorMod(nearSlot - it, n)) }
        val t = Thread {
            // standing pictures all round first, then the walk, then the idle loops
            for (st in listOf(0, 1, 2, 3)) for (s in order) {
                val k = "${f.id}|$s|$st"
                if (synchronized(cache) { k in cache }) continue
                val img = draw(f, s, st)
                synchronized(cache) { cache[k] = img }
            }
            prepareIdle(f, nearSlot)
        }
        t.isDaemon = true
        t.priority = Thread.MIN_PRIORITY + 1
        t.start()
    }

    /** Draws every picture of [f] right away (previews and tests), the idle loops about [homeSlot]. */
    fun prepareNow(f: Folk, homeSlot: Int = MapFigure.slot(270.0)) {
        synchronized(cache) { preparing += f.id }
        for (s in 0 until MapFigure.YAWS) for (st in 0 until MapFigure.STEPS) {
            val k = "${f.id}|$s|$st"
            if (synchronized(cache) { k in cache }) continue
            val img = draw(f, s, st)
            synchronized(cache) { cache[k] = img }
        }
        prepareIdle(f, homeSlot)
    }
}
