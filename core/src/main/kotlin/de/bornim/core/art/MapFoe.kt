package de.bornim.core.art

import de.bornim.core.GearSlot
import de.bornim.core.MonsterKits
import de.bornim.core.MonsterLook
import de.bornim.core.art.HeroFigure.V
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * Monsters on the map built from their battle models (10.10., 9, draft): seen at a slant from above at the same
 * scale and angle as the hero's doll ([MapFigure]), in [YAWS] directions, each with [STEPS] pictures of a walk.
 * Four-legged animals ([BeastArt]) walk with their legs one after another, the hind leg leading the front one on
 * the same side; foes on the doll ([FoeArt]) walk stooped in their own manner with the weapon in hand.
 *
 * Pictures are [W] × [H] art pixels at density 2, the feet (for an animal: the middle of the body) at
 * ([ANCHOR_X], [GROUND]). Not yet used in the game.
 */
object MapFoe {
    const val W = 150
    const val H = 150
    const val ANCHOR_X = 75
    const val GROUND = 110

    const val YAWS = MapFigure.YAWS
    /** Pictures of a walk, one full cycle of all four legs. */
    const val STEPS = 8

    /** Art pixels per centimetre and the angle from above, as for the hero. */
    private const val PX = 0.55
    private const val PITCH = 38.0

    // ---------------------------------------------------------------- animals

    /**
     * An animal on the prowl: the head carried low and forward, ears up, the lips just off the fangs, the tail low.
     * Hungry, not yet attacking.
     */
    private val PROWL = Beast.Rig(neck = -14.0, nod = 6.0, mouth = 0.12, snarl = 0.35, ears = 0.4, tail = -0.35)

    /**
     * The walk: each paw is on the ground three quarters of the cycle, sliding back under the body, and swings
     * forward in the last quarter, lifted. The order is hind left, front left, hind right, front right, a quarter
     * apart, as a dog or wolf walks. [stride] is the reach of one paw forward and back in cm.
     */
    private fun paw(phase: Double, stride: Double, lift: Double): V {
        val p = ((phase % 1.0) + 1.0) % 1.0
        return if (p < 0.75) {
            // on the ground: from forward to back
            V(0.0, 0.0, stride * (1 - 2 * p / 0.75))
        } else {
            // in the air: back to forward, lifted in an arc
            val t = (p - 0.75) / 0.25
            V(0.0, lift * sin(t * PI), stride * (-1 + 2 * (1 - cos(t * PI)) / 2))
        }
    }

    /** The walking animal at [step] of [STEPS], facing [yaw]. */
    fun beastRig(id: String, yaw: Double, step: Int): Beast.Rig {
        val t = Math.floorMod(step, STEPS) / STEPS.toDouble()
        val (stride, lift) = when (BeastArt.kindOf(id)) {
            Beast.Kind.WOLF -> 13.0 to 9.0
            Beast.Kind.BOAR -> 9.0 to 6.0
            Beast.Kind.RAT -> 6.0 to 4.0
        }
        // the body sinks a little twice a cycle, as each pair of legs takes the weight, and the head bobs with it
        val bob = cos(t * 4 * PI)
        return PROWL.copy(
            yaw = yaw,
            hl = paw(t, stride, lift), fl = paw(t - 0.25, stride, lift),
            hr = paw(t - 0.5, stride, lift), fr = paw(t - 0.75, stride, lift),
            crouch = 0.8 + 0.8 * bob, nod = PROWL.nod - 2.0 * bob,
            tailSwing = 10.0 * sin(t * 2 * PI), turn = 3.0 * sin(t * 2 * PI),
        )
    }

    /** One picture of a walking animal, [scale] times its size (young wolves of a pack). */
    fun beast(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): PixelImage =
        Beast(BeastArt.size(id, look) * scale, BeastArt.coat(id, look), BeastArt.kindOf(id)).render(W, H, ANCHOR_X.toDouble(), GROUND.toDouble(), PX, beastRig(id, yawOf(slot), step), pitch = PITCH)

    // ---------------------------------------------------------------- foes on the doll

    /**
     * The walk of the hero, stooped in the manner of the foe's kind: a goblin hunched with its knees bent. A blade
     * or axe hangs lowered along the leg, the point down and a little forward (9b); a bow is carried on the shoulder.
     */
    fun dollRig(id: String, look: MonsterLook, yaw: Double, step: Int): HeroFigure.Rig {
        val kit = MonsterKits.of(id, look.seed)!!
        val ranged = kit.items[GearSlot.MAIN_HAND] == "shortbow"
        val walk = step * MapFigure.STEPS / STEPS
        val base = MapFigure.rig(yaw, walk, if (ranged) MapFigure.Carry.SHOULDER else MapFigure.Carry.LOW)
        val st = listOf(0.0, 11.0, 0.0, -11.0)[Math.floorMod(walk, MapFigure.STEPS)]
        val low = if (ranged) base else base.copy(rh = V(18.0, 56.0, 2.0 - st * 0.35), weapon = V(0.1, -1.0, 0.16))
        val r = when (FoeArt.creature(id)) {
            Doll.Creature.GOBLIN -> low.copy(lean = low.lean + 0.35, crouch = low.crouch + 4.0, headDown = low.headDown - 2.5)
            else -> low
        }
        // a second blade in the other hand, lowered like the first
        return if (kit.items[GearSlot.OFF_HAND] == "dagger") r.copy(lh = V(-18.0, 56.0, 2.0 + st * 0.35)) else r
    }

    /** Goblin hides on the map: the battle's tones darker and earthier, so they stand off the grass (9b). */
    private val GOBLIN_SKIN = intArrayOf(0x4C4A2A, 0x3E4426, 0x56482A, 0x363A22)

    private fun mapDoll(id: String, look: MonsterLook): Doll {
        val d = FoeArt.doll(id, look)
        return if (d.kind != Doll.Creature.GOBLIN) d
        else Doll(d.race, d.sex, d.build, d.skin, d.hairTone, d.kind, d.sizeK, skinOverride = GOBLIN_SKIN[d.skin.mod(4)])
    }

    /** One picture of a walking foe on the doll, its shield on the arm, with a dark rim round it (9b). */
    fun doll(id: String, look: MonsterLook, slot: Int, step: Int): PixelImage =
        rim(mapDoll(id, look).render(W, H, ANCHOR_X.toDouble(), GROUND.toDouble(), PX, dollRig(id, look, yawOf(slot), step), FoeArt.outfit(id, look), pitch = PITCH).img)

    /** A solid dark rim one pixel wide round everything drawn, so a small figure reads against the ground. */
    private fun rim(img: PixelImage): PixelImage {
        val src = img.copy()
        fun solid(x: Int, y: Int) = x in 0 until src.width && y in 0 until src.height && (src[x, y] ushr 24) >= 128
        for (y in 0 until img.height) for (x in 0 until img.width) {
            if (solid(x, y)) continue
            if (solid(x - 1, y) || solid(x + 1, y) || solid(x, y - 1) || solid(x, y + 1)) img.set(x, y, argb(0x0E0A08))
        }
        return img
    }

    // ---------------------------------------------------------------- both

    fun yawOf(slot: Int) = slot * 360.0 / YAWS

    /** Whether [id] is drawn as an animal ([BeastArt]) or on the doll ([FoeArt]) on the map. */
    fun drawn(id: String) = id in BeastArt.KINDS || id in FoeArt.KINDS

    /** One picture of [id] turned to [slot], at [step] of its walk. */
    fun draw(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): PixelImage =
        if (id in BeastArt.KINDS) beast(id, look, slot, step, scale) else doll(id, look, slot, step)

    // ---------------------------------------------------------------- in the game

    /** Monsters already drawn this way on the map (9c: wolf and goblin first, the scout with them). */
    val ON = setOf("wolf", "goblin", "goblin_archer")

    /** A picture cut to what is drawn, with the feet at ([ax], [ay]) in it. */
    class Pic(val img: PixelImage, val ax: Int, val ay: Int)

    private fun crop(img: PixelImage): Pic {
        var x0 = img.width; var y0 = img.height; var x1 = -1; var y1 = -1
        for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) != 0) {
            if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y
        }
        if (x1 < 0) return Pic(PixelImage(1, 1), 0, 0)
        val out = PixelImage(x1 - x0 + 1, y1 - y0 + 1)
        for (y in y0..y1) for (x in x0..x1) out.set(x - x0, y - y0, img[x, y])
        return Pic(out, ANCHOR_X - x0, GROUND - y0)
    }

    private fun key(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double) =
        "$id/${look.seed}/${look.shiny}/${look.glow}/${(scale * 100).toInt()}/${Math.floorMod(slot, YAWS)}/${Math.floorMod(step, STEPS)}"

    /** The pictures drawn, the oldest unused dropped first (each about 20 kB). */
    private val cache = object : LinkedHashMap<String, Pic>(256, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Pic>?) = size > 900
    }
    private class Job(val key: String, val id: String, val look: MonsterLook, val slot: Int, val step: Int, val scale: Double)
    private val queue = LinkedHashMap<String, Job>()
    private var worker: Thread? = null

    /** The picture asked for, or null while it is drawn in the background. */
    fun picture(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): Pic? {
        val k = key(id, look, slot, step, scale)
        synchronized(cache) {
            cache[k]?.let { return it }
            // asked for again (still on screen): to the front of the queue
            queue.remove(k)?.let { queue[k] = it; return null }
            // a walk is wanted as a whole: the other steps of this direction too, the one asked for first
            for (st in 0 until STEPS) key(id, look, slot, st, scale).let { kk ->
                if (kk != k && kk !in cache && kk !in queue) queue[kk] = Job(kk, id, look, Math.floorMod(slot, YAWS), st, scale)
            }
            queue[k] = Job(k, id, look, Math.floorMod(slot, YAWS), Math.floorMod(step, STEPS), scale)
            startWorker()
        }
        return null
    }

    /**
     * The picture to show now: the one asked for, else the standing one of that direction, else the nearest
     * direction already drawn; null only while nothing of this monster is drawn yet (then the former sprite shows).
     */
    fun pictureNow(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): Pic? {
        picture(id, look, slot, step, scale)?.let { return it }
        synchronized(cache) {
            cache[key(id, look, slot, 0, scale)]?.let { return it }
            for (d in 1..YAWS / 2) for (s in listOf(slot - d, slot + d))
                cache[key(id, look, Math.floorMod(s, YAWS), 0, scale)]?.let { return it }
        }
        return null
    }

    /** Draws every picture of [id] right away (previews and tests). */
    fun prepareNow(id: String, look: MonsterLook, scale: Double = 1.0) {
        for (slot in 0 until YAWS) for (st in 0 until STEPS) {
            val k = key(id, look, slot, st, scale)
            if (synchronized(cache) { k in cache }) continue
            val pic = crop(draw(id, look, slot, st, scale))
            synchronized(cache) { cache[k] = pic }
        }
    }

    /** Called holding the cache's lock. */
    private fun startWorker() {
        if (worker != null) return
        worker = Thread {
            while (true) {
                val job = synchronized(cache) {
                    // the newest wish first: what is on screen now
                    val last = queue.keys.lastOrNull()
                    if (last == null) { worker = null; null } else queue.remove(last)
                } ?: break
                val pic = try { crop(draw(job.id, job.look, job.slot, job.step, job.scale)) } catch (e: Exception) { null }
                if (pic != null) synchronized(cache) { cache[job.key] = pic }
            }
        }.also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY + 1; it.start() }
    }
}
