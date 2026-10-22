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
        NEUTRAL, SHIFT_L, SHIFT_R, LOOK_L(looks = true), LOOK_R(looks = true), BELT(handsFree = true),
        /** Draft (55.1): the arms crossed over the chest; the hands behind the back. Only with [draft]. */
        ARMS(handsFree = true), BACK(handsFree = true),
        /** Draft (55.1b): a guard grounds his spear beside him, butt on the ground, and leans on it. Only for spear bearers, only with [draft]. */
        SPEAR
    }

    /** The test switch (55.1, draft): more stances for the arms, held longer. */
    @Volatile var draft = true

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
        return full.copy(ground = m(from.ground, full.ground), weapon = from.weapon.turnTo(full.weapon, t), bodyX = m(from.bodyX, full.bodyX), spread = m(from.spread, full.spread), headTurn = m(from.headTurn, full.headTurn),
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
            // each hand on the other arm just above the elbow, the forearms one over the other before the chest
            Rest.ARMS -> base.copy(rh = HeroFigure.V(-7.0, 71.0, 7.5), lh = HeroFigure.V(7.0, 74.0, 6.5), spread = 7.5, headDown = -1.0)
            // the hands clasped behind, at the small of the back, the chest a little forward
            Rest.BACK -> base.copy(rh = HeroFigure.V(3.0, 60.0, -9.0), lh = HeroFigure.V(-3.0, 60.0, -9.0), spread = 7.5, lean = -0.04)
            // the spear upright beside the right foot, the right hand on the shaft at the chest, the weight over to that side
            Rest.SPEAR -> {
                // turned so his right side faces away the spear was gone behind him (test of 0.1.670): in those few
                // turns the hand holds it where it shows (tried out with SPEERRF), in profile the shaft leans a little ahead
                val (r, f, lean) = when (Math.floorMod(Math.round(base.yaw / (360.0 / MapFigure.YAWS)).toInt(), MapFigure.YAWS)) {
                    1 -> Triple(SPEAR_R + 6, SPEAR_F, 0.04)
                    2 -> Triple(SPEAR_R, SPEAR_F - 10, 0.04)
                    3 -> Triple(SPEAR_R - 5, SPEAR_F + 8, 0.13)
                    4 -> Triple(SPEAR_R - 3, SPEAR_F + 6, 0.11)
                    else -> Triple(SPEAR_R, SPEAR_F, 0.04)
                }
                base.copy(rh = HeroFigure.V(r, SPEAR_U, f), weapon = HeroFigure.V(0.0, 1.0, lean), aim = 1.0, ground = 1.0,
                    bodyX = 1.5, spread = 8.0, headTurn = -6.0, twist = -4.0)
            }
        }
        if (up > 0) r = r.copy(bodyY = r.bodyY + up, rh = r.rh.copy(u = r.rh.u + up * 0.5), lh = r.lh.copy(u = r.lh.u + up * 0.5))
        return r
    }

    /** Where the hand holds the grounded spear (55.1b): beside the hip, not before it (seen from above a spear in front looks short). */
    private const val SPEAR_R = 19.0
    private const val SPEAR_U = 62.0
    private const val SPEAR_F = 3.0

    /** Length of the stretches chance picks a stance for. */
    const val BLOCK_MS = 9_000L

    /**
     * The stance and breath of the figure with [seed] at [clockMs]. A breath takes 3.6 to 4.6 s (each
     * figure its own); in each stretch of [BLOCK_MS] about half the time nothing else happens, else one
     * stance is held for 2.5 to 6 s from a random moment. [handsFree]: may it use its hands;
     * [mayLook]: may it glance aside (not while it watches the hero); [spear]: it bears a spear it can ground (55.1b);
     * [cut]: where a stance planned from and to on the clock ends instead, null for not at all (297, [MapFolk.Calm]).
     */
    fun at(seed: Int, clockMs: Long, handsFree: Boolean, mayLook: Boolean, spear: Boolean = false, cut: ((Long, Long) -> Long?)? = null): Pair<Rest, Int> {
        val period = 3_600L + Math.floorMod(seed * 7919, 1_000)
        val breath = if (Math.floorMod(clockMs + seed * 131L, period) < period / 2) 1 else 0
        val n = Math.floorDiv(clockMs, BLOCK_MS)
        val t = clockMs - n * BLOCK_MS
        val r = java.util.Random(n * 7_919L + seed * 104_729L)
        if (r.nextDouble() < 0.45) return Rest.NEUTRAL to breath
        val start = (r.nextDouble() * 3_000).toLong()
        val planned = 2_500L + (r.nextDouble() * 3_500).toLong()
        val length = if (cut == null) planned else (cut(n * BLOCK_MS + start, n * BLOCK_MS + start + planned) ?: return Rest.NEUTRAL to breath) - n * BLOCK_MS - start
        val roll = r.nextDouble()
        val pick = when {
            roll < 0.4 -> if (r.nextBoolean()) Rest.SHIFT_L else Rest.SHIFT_R
            roll < 0.7 -> if (r.nextBoolean()) Rest.LOOK_L else Rest.LOOK_R
            // draft (55.1b): a spear bearer grounds his spear instead (a guard on his round: at his longer watches, see [spearWatch])
            draft && spear -> Rest.SPEAR
            // draft (55.1): the hands now and then crossed or behind the back instead of at the belt
            draft -> r.nextDouble().let { a -> if (a < 0.35) Rest.ARMS else if (a < 0.6) Rest.BACK else Rest.BELT }
            else -> Rest.BELT
        }
        if (t < start || t >= start + length) return Rest.NEUTRAL to breath
        val ok = (!pick.handsFree || handsFree) && (!pick.looks || mayLook) && (pick != Rest.SPEAR || spear)
        return (if (ok) pick else Rest.NEUTRAL) to breath
    }

    /** A moment of standing: the stance, the breath, and how far into the stance ([LEVELS]: all the way). */
    data class Pose(val rest: Rest, val breath: Int, val level: Int)

    /**
     * Like [at], with going into and out of the stance over [EASE_MS] (12b): the figure turns its
     * head, shifts its weight or puts its hands to the belt through in-between pictures.
     */
    fun pose(seed: Int, clockMs: Long, handsFree: Boolean, mayLook: Boolean, spear: Boolean = false, cut: ((Long, Long) -> Long?)? = null): Pose {
        val (rest, breath) = at(seed, clockMs, handsFree, mayLook, spear, cut)
        if (rest == Rest.NEUTRAL) {
            // just after a stance it is still on its way out of it, from as far as it had come (297: a stance cut short
            // while still going into it)
            var gone = 0L
            while (gone < EASE_MS && at(seed, clockMs - gone, handsFree, mayLook, spear, cut).first == Rest.NEUTRAL) gone += 20
            if (gone < EASE_MS) {
                val was = pose(seed, clockMs - gone, handsFree, mayLook, spear, cut)
                val level = (was.level - LEVELS * gone / EASE_MS.toDouble()).toInt().coerceIn(0, was.level - 1)
                if (level > 0) return Pose(was.rest, breath, level)
            }
            return Pose(Rest.NEUTRAL, breath, LEVELS)
        }
        // since when it holds this stance, and when it leaves it
        var since = 0L
        while (since < EASE_MS && at(seed, clockMs - since - 20, handsFree, mayLook, spear, cut).first == rest) since += 20
        val level = if (since < EASE_MS) (LEVELS * since / EASE_MS.toDouble()).toInt().coerceIn(1, LEVELS) else LEVELS
        return Pose(rest, breath, level)
    }

    /**
     * 55.1b (test of 0.1.662: in five minutes Jorin never grounded his spear, the chance stretches missed his short
     * stops): a guard on his round grounds his spear at each longer watch, from [SPEAR_AFTER_MS] after he stopped
     * until [SPEAR_BEFORE_MS] before he walks on, easing in and out. [stoodMs]: since he stopped; [leftMs]: until he
     * goes on; [watchMs]: the whole stop. Null outside a long watch; plain standing in it before and after the spear.
     */
    fun spearWatch(stoodMs: Long, leftMs: Long, watchMs: Long, breath: Int): Pose? {
        if (watchMs < SPEAR_WATCH_MS) return null
        val inMs = stoodMs - SPEAR_AFTER_MS; val outMs = leftMs - SPEAR_BEFORE_MS
        val k = minOf(inMs, outMs)
        // just before and after: standing plain, so no glance aside cuts into the spear
        if (k <= 0) return Pose(Rest.NEUTRAL, breath, LEVELS)
        return Pose(Rest.SPEAR, breath, if (k >= SPEAR_EASE_MS) LEVELS else (LEVELS * k / SPEAR_EASE_MS.toDouble()).toInt().coerceIn(1, LEVELS))
    }

    /** Grounding the spear and taking it up again is a bigger move than a glance: slower than [EASE_MS] (test of 0.1.670). */
    const val SPEAR_EASE_MS = 800L

    /** A stop at least this long is a watch with the spear grounded. */
    const val SPEAR_WATCH_MS = 8_000L
    const val SPEAR_AFTER_MS = 1_200L
    const val SPEAR_BEFORE_MS = 900L

    // ------------------------------------------------------------ pictures, drawn when first wanted

    private val shelf = Shelf(360)

    /** The picture under [key] if it is drawn already, without asking for it. */
    fun cached(key: String): PixelImage? = shelf.cached(key)

    /** The picture under [key], or null; when missing it is drawn in the background with [draw]. */
    fun picture(key: String, draw: () -> PixelImage): PixelImage? = shelf.picture(key, draw)

    /** Draws the picture under [key] right away (previews and tests). */
    fun pictureNow(key: String, draw: () -> PixelImage): PixelImage = shelf.pictureNow(key, draw)

    private val worker = java.util.concurrent.Executors.newSingleThreadExecutor { r ->
        Thread({ SdfRender.quiet.set(true); r.run() }, "map-rest").also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY + 1 }
    }

    /**
     * Pictures drawn when first wanted, at most [size] kept (the least used go first), drawn one after the other in
     * the background. A figure with many pictures keeps its own shelf, so it does not push the others' out (94).
     */
    class Shelf(private val size: Int) {
        private val cache = object : LinkedHashMap<String, PixelImage>(256, 0.75f, true) {
            override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > this@Shelf.size
        }
        private val queued = HashSet<String>()

        fun cached(key: String): PixelImage? = synchronized(cache) { cache[key] }

        fun picture(key: String, draw: () -> PixelImage): PixelImage? {
            synchronized(cache) {
                cache[key]?.let { return it }
                if (!queued.add(key)) return null
            }
            worker.execute {
                var img: PixelImage? = null
                de.bornim.core.Guard.run("Atmen") { img = DrawBusy.during(DrawBusy.Kind.REST, draw) }
                synchronized(cache) { queued.remove(key); if (img != null) cache[key] = img }
            }
            return null
        }

        fun pictureNow(key: String, draw: () -> PixelImage): PixelImage =
            synchronized(cache) { cache[key] } ?: draw().also { synchronized(cache) { cache[key] = it } }
    }
}
