package de.bornim.core.art

/**
 * Small movements of everyone standing about on the map, so no one stands like a statue (09.10.,
 * "lebendige Welt"): breathing, shifting the weight from one leg to the other, a glance aside, a
 * hand to the belt or the arms crossed. Every figure gets them, the hero too; folk with a loop of
 * their own (Garrick at his fire) do that on top.
 *
 * The times never keep a beat: as for Garrick, chance picks per stretch of time whether, when, what
 * and how long, from a seed of each figure's own, so two figures side by side never move together.
 * The pictures are drawn only for the way a figure is facing, in the background, when first wanted.
 */
object MapRest {
    /** A resting stance; [handsFree] ones need empty hands (folk, not the hero with a weapon). */
    enum class Rest(val handsFree: Boolean = false, val looks: Boolean = false) {
        NEUTRAL, SHIFT_L, SHIFT_R, LOOK_L(looks = true), LOOK_R(looks = true), BELT(handsFree = true)
    }

    /** Steps into and out of a stance (12b: the glance aside turned the head 38° in one picture): [LEVELS] is the stance itself. */
    const val LEVELS = 4

    /** How long going into or out of a stance takes. */
    const val EASE_MS = 420L

    /**
     * [rest] laid over a standing rig [base]; [breath] 1 is breathing in: chest and shoulders a little higher.
     * [level] of [LEVELS]: how far into the stance (the in-between pictures of going in and out).
     */
    fun rig(base: HeroFigure.Rig, rest: Rest, breath: Int, level: Int = LEVELS): HeroFigure.Rig {
        val full = stance(base, rest, breath)
        if (level >= LEVELS || rest == Rest.NEUTRAL) return full
        val from = stance(base, Rest.NEUTRAL, breath)
        val t = level.coerceAtLeast(0) / LEVELS.toDouble()
        fun m(a: Double, b: Double) = a + (b - a) * t
        fun v(a: HeroFigure.V, b: HeroFigure.V) = HeroFigure.V(m(a.r, b.r), m(a.u, b.u), m(a.f, b.f))
        return full.copy(bodyX = m(from.bodyX, full.bodyX), spread = m(from.spread, full.spread), headTurn = m(from.headTurn, full.headTurn),
            twist = m(from.twist, full.twist), rh = v(from.rh, full.rh), lh = v(from.lh, full.lh), bodyY = m(from.bodyY, full.bodyY))
    }

    private fun stance(base: HeroFigure.Rig, rest: Rest, breath: Int): HeroFigure.Rig {
        val up = if (breath == 1) 1.6 else 0.0
        var r = when (rest) {
            Rest.NEUTRAL -> base
            Rest.SHIFT_L -> base.copy(bodyX = -2.5, spread = 8.5, headTurn = 4.0)
            Rest.SHIFT_R -> base.copy(bodyX = 2.5, spread = 8.5, headTurn = -4.0)
            Rest.LOOK_L -> base.copy(headTurn = 38.0, twist = 6.0)
            Rest.LOOK_R -> base.copy(headTurn = -38.0, twist = -6.0)
            Rest.BELT -> base.copy(rh = HeroFigure.V(13.0, 60.0, 7.0), lh = HeroFigure.V(-13.0, 60.0, 7.0), spread = 8.0)
        }
        if (up > 0) r = r.copy(bodyY = r.bodyY + up, rh = r.rh.copy(u = r.rh.u + up * 0.5), lh = r.lh.copy(u = r.lh.u + up * 0.5))
        return r
    }

    /** Length of the stretches chance picks a stance for. */
    const val BLOCK_MS = 9_000L

    /**
     * The stance and breath of the figure with [seed] at [clockMs]. A breath takes 3.6 to 4.6 s (each
     * figure its own); in each stretch of [BLOCK_MS] about half the time nothing else happens, else one
     * stance is held for 2.5 to 6 s from a random moment. [handsFree]: may it use its hands;
     * [mayLook]: may it glance aside (not while it watches the hero).
     */
    fun at(seed: Int, clockMs: Long, handsFree: Boolean, mayLook: Boolean): Pair<Rest, Int> {
        val period = 3_600L + Math.floorMod(seed * 7919, 1_000)
        val breath = if (Math.floorMod(clockMs + seed * 131L, period) < period / 2) 1 else 0
        val n = Math.floorDiv(clockMs, BLOCK_MS)
        val t = clockMs - n * BLOCK_MS
        val r = java.util.Random(n * 7_919L + seed * 104_729L)
        if (r.nextDouble() < 0.45) return Rest.NEUTRAL to breath
        val start = (r.nextDouble() * 3_000).toLong()
        val length = 2_500L + (r.nextDouble() * 3_500).toLong()
        val roll = r.nextDouble()
        val pick = when {
            roll < 0.4 -> if (r.nextBoolean()) Rest.SHIFT_L else Rest.SHIFT_R
            roll < 0.7 -> if (r.nextBoolean()) Rest.LOOK_L else Rest.LOOK_R
            else -> Rest.BELT
        }
        if (t < start || t >= start + length) return Rest.NEUTRAL to breath
        val ok = (!pick.handsFree || handsFree) && (!pick.looks || mayLook)
        return (if (ok) pick else Rest.NEUTRAL) to breath
    }

    /** A moment of standing: the stance, the breath, and how far into the stance ([LEVELS]: all the way). */
    data class Pose(val rest: Rest, val breath: Int, val level: Int)

    /**
     * Like [at], with going into and out of the stance over [EASE_MS] (12b): the figure turns its
     * head, shifts its weight or puts its hands to the belt through in-between pictures.
     */
    fun pose(seed: Int, clockMs: Long, handsFree: Boolean, mayLook: Boolean): Pose {
        val (rest, breath) = at(seed, clockMs, handsFree, mayLook)
        if (rest == Rest.NEUTRAL) {
            // just after a stance it is still on its way out of it
            val (back, _) = at(seed, clockMs - EASE_MS, handsFree, mayLook)
            if (back != Rest.NEUTRAL) {
                var gone = 0L
                while (gone < EASE_MS && at(seed, clockMs - gone, handsFree, mayLook).first == Rest.NEUTRAL) gone += 20
                if (gone < EASE_MS) return Pose(back, breath, (LEVELS * (1 - gone / EASE_MS.toDouble())).toInt().coerceIn(0, LEVELS - 1))
            }
            return Pose(Rest.NEUTRAL, breath, LEVELS)
        }
        // since when it holds this stance, and when it leaves it
        var since = 0L
        while (since < EASE_MS && at(seed, clockMs - since - 20, handsFree, mayLook).first == rest) since += 20
        val level = if (since < EASE_MS) (LEVELS * since / EASE_MS.toDouble()).toInt().coerceIn(1, LEVELS) else LEVELS
        return Pose(rest, breath, level)
    }

    // ------------------------------------------------------------ pictures, drawn when first wanted

    private val cache = object : LinkedHashMap<String, PixelImage>(256, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 360
    }
    private val queued = HashSet<String>()
    private val worker = java.util.concurrent.Executors.newSingleThreadExecutor { r ->
        Thread(r, "map-rest").also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY + 1 }
    }

    /** The picture under [key], or null; when missing it is drawn in the background with [draw]. */
    fun picture(key: String, draw: () -> PixelImage): PixelImage? {
        synchronized(cache) {
            cache[key]?.let { return it }
            if (!queued.add(key)) return null
        }
        worker.execute {
            val img = runCatching(draw).getOrNull()
            synchronized(cache) { queued.remove(key); if (img != null) cache[key] = img }
        }
        return null
    }

    /** Draws the picture under [key] right away (previews and tests). */
    fun pictureNow(key: String, draw: () -> PixelImage): PixelImage =
        synchronized(cache) { cache[key] } ?: draw().also { synchronized(cache) { cache[key] = it } }
}
