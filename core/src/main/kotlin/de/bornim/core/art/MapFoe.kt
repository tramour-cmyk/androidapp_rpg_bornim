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
 * Standing, they are never still (9d, "lebendige Welt", but dark): a wolf breathes, turns its head, sniffs the
 * ground, lifts its nose to the wind or draws its lips off the fangs; a goblin breathes, shifts its weight, peers
 * about, crouches lower or hefts its weapon. Chance picks when and what from a seed of each one's own ([idleAt]).
 *
 * Pictures are [W] × [H] art pixels at density 2 (larger for the big ones, [frame]), the feet (for an animal: the
 * middle of the body) at ([ANCHOR_X], [GROUND]).
 */
object MapFoe {
    const val W = 150
    const val H = 150
    const val ANCHOR_X = 75
    const val GROUND = 110

    /** The picture's size and where the feet are in it: Grimfang, half as big again as a wolf, needs more room. */
    class Frame(val w: Int, val h: Int, val ax: Int, val gy: Int)
    private val SMALL = Frame(W, H, ANCHOR_X, GROUND)
    private val BIG = Frame(220, 200, 110, 140)
    fun frame(id: String) = if (id == "dire_wolf") BIG else SMALL

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
        renderBeast(id, look, scale, beastRig(id, yawOf(slot), step))

    /** An animal standing in [idle], breathing in ([breath] 1) or out, facing [yaw]. */
    fun beastIdleRig(id: String, yaw: Double, idle: Idle, breath: Int, level: Int = LEVELS): Beast.Rig {
        val br = breath / BREATHS.toDouble()
        val b = PROWL.copy(yaw = yaw, breath = br, crouch = 0.6 * br)
        // 9h: into and out of a stance through in-between pictures, never in one jump
        return b.lerp(beastStance(b, idle), level / LEVELS.toDouble())
    }

    private fun beastStance(b: Beast.Rig, idle: Idle): Beast.Rig {
        return when (idle) {
            // turning the head to listen or look, the ears after it
            Idle.LOOK_L -> b.copy(turn = 34.0, neck = -6.0, ears = 0.8, tailSwing = -8.0)
            Idle.LOOK_R -> b.copy(turn = -34.0, neck = -6.0, ears = 0.8, tailSwing = 8.0)
            // nose down at the ground, following a trail
            Idle.SNIFF -> b.copy(neck = -40.0, nod = 22.0, mouth = 0.04, snarl = 0.0, ears = 0.6, tail = -0.2, crouch = b.crouch + 2.0)
            // head raised, nose into the wind
            Idle.SCENT -> b.copy(neck = 16.0, nod = -14.0, mouth = 0.08, snarl = 0.1, ears = 1.0, tail = -0.1)
            // head low, lips off the fangs, ears flat: something it does not like
            Idle.SNARL -> b.copy(neck = -22.0, nod = 10.0, mouth = 0.35, snarl = 1.0, ears = -1.0, tail = -0.5, crouch = b.crouch + 4.0)
            else -> b
        }
    }

    private fun renderBeast(id: String, look: MonsterLook, scale: Double, rig: Beast.Rig): PixelImage {
        val f = frame(id)
        return Beast(BeastArt.size(id, look) * scale, BeastArt.coat(id, look), BeastArt.kindOf(id))
            .render(f.w, f.h, f.ax.toDouble(), f.gy.toDouble(), PX, rig, pitch = PITCH)
    }

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

    /** A foe on the doll standing in [idle], breathing in ([breath] 1) or out, facing [yaw]. */
    fun dollIdleRig(id: String, look: MonsterLook, yaw: Double, idle: Idle, breath: Int, level: Int = LEVELS): HeroFigure.Rig {
        val b = dollRig(id, look, yaw, 0)
        val up = 1.6 * breath / BREATHS
        // 9h: into and out of a stance through in-between pictures, never in one jump
        val r = b.lerp(dollStance(id, look, b, idle), level / LEVELS.toDouble())
        return if (up > 0) r.copy(bodyY = r.bodyY + up, rh = r.rh.copy(u = r.rh.u + up * 0.5), lh = r.lh.copy(u = r.lh.u + up * 0.5)) else r
    }

    private fun dollStance(id: String, look: MonsterLook, b: HeroFigure.Rig, idle: Idle): HeroFigure.Rig {
        return when (idle) {
            Idle.LOOK_L -> b.copy(headTurn = b.headTurn + 40.0, twist = 8.0)
            Idle.LOOK_R -> b.copy(headTurn = b.headTurn - 40.0, twist = -8.0)
            Idle.SHIFT_L -> b.copy(bodyX = -2.5, spread = 8.5, headTurn = b.headTurn + 6.0)
            Idle.SHIFT_R -> b.copy(bodyX = 2.5, spread = 8.5, headTurn = b.headTurn - 6.0)
            // lower still, the head thrust forward, peering
            Idle.CROUCH -> b.copy(crouch = b.crouch + 7.0, lean = b.lean + 0.25, headDown = b.headDown - 5.0)
            // the weapon brought up before it, ready
            Idle.HEFT -> if (MonsterKits.of(id, look.seed)!!.items[GearSlot.MAIN_HAND] == "shortbow") b
                else b.copy(rh = V(16.0, 72.0, 20.0), weapon = V(0.25, 0.75, 0.6), crouch = b.crouch + 2.0, headDown = b.headDown - 2.0)
            else -> b
        }
    }

    /** Goblin hides on the map: the battle's tones darker and earthier, so they stand off the grass (9b). */
    private val GOBLIN_SKIN = intArrayOf(0x4C4A2A, 0x3E4426, 0x56482A, 0x363A22)

    private fun mapDoll(id: String, look: MonsterLook): Doll {
        val d = FoeArt.doll(id, look)
        return if (d.kind != Doll.Creature.GOBLIN) d
        else Doll(d.race, d.sex, d.build, d.skin, d.hairTone, d.kind, d.sizeK, skinOverride = GOBLIN_SKIN[d.skin.mod(4)])
    }

    /** One picture of a walking foe on the doll, its shield on the arm, with a dark rim round it (9b). */
    fun doll(id: String, look: MonsterLook, slot: Int, step: Int): PixelImage = renderDoll(id, look, dollRig(id, look, yawOf(slot), step))

    private fun renderDoll(id: String, look: MonsterLook, rig: HeroFigure.Rig): PixelImage {
        val f = frame(id)
        return rim(mapDoll(id, look).render(f.w, f.h, f.ax.toDouble(), f.gy.toDouble(), PX, rig, FoeArt.outfit(id, look), pitch = PITCH).img)
    }

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

    /** One picture of [id] turned to [slot], standing in [idle], breathing in ([breath] 1) or out. */
    fun drawIdle(id: String, look: MonsterLook, slot: Int, idle: Idle, breath: Int, scale: Double = 1.0, level: Int = LEVELS): PixelImage =
        if (id in BeastArt.KINDS) renderBeast(id, look, scale, beastIdleRig(id, yawOf(slot), idle, breath, level))
        else renderDoll(id, look, dollIdleRig(id, look, yawOf(slot), idle, breath, level))

    // ---------------------------------------------------------------- standing about

    /** What a monster does while it stands: animals the first six, foes on the doll the rest and the looks. */
    enum class Idle { STAND, LOOK_L, LOOK_R, SNIFF, SCENT, SNARL, SHIFT_L, SHIFT_R, CROUCH, HEFT }

    /** Length of the stretches chance picks a stance for. */
    private const val BLOCK_MS = 7_000L

    /** Steps of going into or out of a stance (9h): [LEVELS] is fully in it, the ones between are in-between pictures. */
    const val LEVELS = 4
    /** How long going into or out of a stance takes. */
    const val EASE_MS = 420L
    /** Steps of a breath, out (0) to in ([BREATHS]), so the chest rises and falls rather than jumps. */
    const val BREATHS = 2

    /** What a monster does at a moment: the stance, how far into it ([level] of [LEVELS]) and its breath (of [BREATHS]). */
    data class Stance(val idle: Idle, val breath: Int, val level: Int = LEVELS)

    /**
     * The stance of the monster [id] with [seed] at [clockMs], as [MapRest.at] for folk: a breath of 2.4 to 3.2 s
     * (an animal pants a little faster than a man), and in each stretch about a third of the time nothing else, else
     * one stance held for 1.8 to 4.5 s from a random moment, eased in and out over [EASE_MS]. Never in a beat.
     */
    fun idleAt(id: String, seed: Int, clockMs: Long): Stance {
        val period = 2_400L + Math.floorMod(seed * 7919, 800)
        // the breath as a smooth wave, in [BREATHS] + 1 steps
        val phase = Math.floorMod(clockMs + seed * 131L, period) / period.toDouble()
        val breath = Math.round((1 - cos(phase * 2 * PI)) / 2 * BREATHS).toInt()
        val n = Math.floorDiv(clockMs + Math.floorMod(seed * 977, BLOCK_MS.toInt()), BLOCK_MS)
        val t = clockMs + Math.floorMod(seed * 977, BLOCK_MS.toInt()) - n * BLOCK_MS
        val r = java.util.Random(n * 7_919L + seed * 104_729L)
        if (r.nextDouble() < 0.35) return Stance(Idle.STAND, breath)
        val start = (r.nextDouble() * 2_500).toLong()
        val length = 1_800L + (r.nextDouble() * 2_700).toLong()
        if (t < start || t >= start + length) return Stance(Idle.STAND, breath)
        val roll = r.nextDouble()
        val side = r.nextBoolean()
        val pick = if (id in BeastArt.KINDS) when {
            roll < 0.35 -> if (side) Idle.LOOK_L else Idle.LOOK_R
            roll < 0.65 -> Idle.SNIFF
            roll < 0.85 -> Idle.SCENT
            else -> Idle.SNARL
        } else when {
            roll < 0.35 -> if (side) Idle.LOOK_L else Idle.LOOK_R
            roll < 0.7 -> if (side) Idle.SHIFT_L else Idle.SHIFT_R
            roll < 0.85 -> Idle.CROUCH
            else -> Idle.HEFT
        }
        // eased: the share of the way in, smoothed, in steps
        val w = minOf(1.0, (t - start) / EASE_MS.toDouble(), (start + length - t) / EASE_MS.toDouble())
        val eased = w * w * (3 - 2 * w)
        val level = Math.round(eased * LEVELS).toInt().coerceIn(0, LEVELS)
        return if (level == 0) Stance(Idle.STAND, breath) else Stance(pick, breath, level)
    }

    // ---------------------------------------------------------------- in the game

    /** Monsters already drawn this way on the map (9c: wolf and goblin first, the scout with them; 9e: Grimfang). */
    val ON = setOf("wolf", "goblin", "goblin_archer", "dire_wolf")

    /** A picture cut to what is drawn, with the feet at ([ax], [ay]) in it. */
    class Pic(val img: PixelImage, val ax: Int, val ay: Int)

    private fun crop(img: PixelImage, f: Frame): Pic {
        var x0 = img.width; var y0 = img.height; var x1 = -1; var y1 = -1
        for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) != 0) {
            if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y
        }
        if (x1 < 0) return Pic(PixelImage(1, 1), 0, 0)
        val out = PixelImage(x1 - x0 + 1, y1 - y0 + 1)
        for (y in y0..y1) for (x in x0..x1) out.set(x - x0, y - y0, img[x, y])
        return Pic(out, f.ax - x0, f.gy - y0)
    }

    private fun key(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double) =
        "$id/${look.seed}/${look.shiny}/${look.glow}/${(scale * 100).toInt()}/${Math.floorMod(slot, YAWS)}/${Math.floorMod(step, STEPS)}"

    /** The pictures drawn, the oldest unused dropped first (each about 20 kB). */
    private val cache = object : LinkedHashMap<String, Pic>(256, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Pic>?) = size > 900
    }
    private class Job(val key: String, val draw: () -> Pic)
    private val queue = LinkedHashMap<String, Job>()
    private var worker: Thread? = null

    /** The picture under [k] if drawn; else it is queued to the front (drawn with [draw]) and null. Holding the lock. */
    private fun wish(k: String, draw: () -> Pic): Pic? {
        cache[k]?.let { return it }
        queue.remove(k)?.let { queue[k] = it; return null }
        queue[k] = Job(k, draw)
        startWorker()
        return null
    }

    private fun walkJob(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double): () -> Pic =
        { crop(draw(id, look, Math.floorMod(slot, YAWS), Math.floorMod(step, STEPS), scale), frame(id)) }

    /** The picture asked for, or null while it is drawn in the background. */
    fun picture(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): Pic? {
        val k = key(id, look, slot, step, scale)
        synchronized(cache) {
            cache[k]?.let { return it }
            if (k !in queue) {
                // a walk is wanted as a whole: the other steps of this direction too, the one asked for first
                for (st in 0 until STEPS) key(id, look, slot, st, scale).let { kk ->
                    if (kk != k && kk !in cache && kk !in queue) queue[kk] = Job(kk, walkJob(id, look, slot, st, scale))
                }
            }
            return wish(k, walkJob(id, look, slot, step, scale))
        }
    }

    /**
     * The picture to show now: the one asked for, else the standing one of that direction, else the nearest
     * direction already drawn; null only while nothing of this monster is drawn yet (then the former sprite shows).
     */
    fun pictureNow(id: String, look: MonsterLook, slot: Int, step: Int, scale: Double = 1.0): Pic? {
        picture(id, look, slot, step, scale)?.let { return it }
        return nearest(id, look, slot, scale)
    }

    private fun nearest(id: String, look: MonsterLook, slot: Int, scale: Double): Pic? = synchronized(cache) {
        cache[key(id, look, slot, 0, scale)]?.let { return it }
        for (d in 1..YAWS / 2) for (s in listOf(slot - d, slot + d))
            cache[key(id, look, Math.floorMod(s, YAWS), 0, scale)]?.let { return it }
        null
    }

    /** Standing in [idle] with [breath]: the picture, else the plain standing one, else as [pictureNow]. */
    fun idleNow(id: String, look: MonsterLook, slot: Int, idle: Idle, breath: Int, scale: Double = 1.0, level: Int = LEVELS): Pic? {
        val sl = Math.floorMod(slot, YAWS)
        val lv = if (idle == Idle.STAND) LEVELS else level.coerceIn(0, LEVELS)
        // the plain standing picture without breath is the first step of the walk
        if ((idle == Idle.STAND || lv == 0) && breath == 0) return pictureNow(id, look, sl, 0, scale)
        val st = if (lv == 0) Idle.STAND else idle
        val k = "${key(id, look, sl, 0, scale)}/$st/$breath/$lv"
        synchronized(cache) {
            wish(k) { crop(drawIdle(id, look, sl, st, breath, scale, if (st == Idle.STAND) LEVELS else lv), frame(id)) }?.let { return it }
            // while it is drawn: the nearest step of the same stance already there, else standing with this breath
            for (l in (lv - 1) downTo 1) cache["${key(id, look, sl, 0, scale)}/$st/$breath/$l"]?.let { return it }
            cache["${key(id, look, sl, 0, scale)}/${Idle.STAND}/$breath/$LEVELS"]?.let { return it }
        }
        return pictureNow(id, look, sl, 0, scale)
    }

    /** Draws every picture of [id] right away (previews and tests). */
    fun prepareNow(id: String, look: MonsterLook, scale: Double = 1.0) {
        for (slot in 0 until YAWS) for (st in 0 until STEPS) {
            val k = key(id, look, slot, st, scale)
            if (synchronized(cache) { k in cache }) continue
            val pic = walkJob(id, look, slot, st, scale)()
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
                val pic = try { job.draw() } catch (e: Exception) { null }
                if (pic != null) synchronized(cache) { cache[job.key] = pic }
            }
        }.also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY + 1; it.start() }
    }
}
