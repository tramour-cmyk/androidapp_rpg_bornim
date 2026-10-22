package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.Facing
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Icon
import de.bornim.core.Race
import de.bornim.core.Sex

/**
 * The hero on the map as the same doll as in battle (09.10.): seen at a slant from above, at true
 * size, walking about with the weapon lowered and the shield slung on the back, the hands free.
 *
 * Drawn in [YAWS] directions so the hero can turn smoothly instead of snapping between the four
 * ways, each with [STEPS] pictures of a walk. Pictures are [W] × [H] art pixels at density 2 (two
 * art pixels per map pixel), the feet at ([ANCHOR_X], [GROUND]). They are drawn ahead in the
 * background ([prepare]); until a picture is ready the map shows the former figure.
 */
object MapFigure {
    const val W = 96
    const val H = 132
    const val ANCHOR_X = 48
    const val GROUND = 124
    const val DENSITY = 2

    /** Directions drawn, evenly round. */
    const val YAWS = 16

    /** Pictures of a walk, the legs swinging smoothly (12b: four pictures jumped 11 cm a picture). */
    const val STEPS = 8

    /** Art pixels per centimetre: a man of 1.80 m stands about 1½ tiles tall. */
    private const val PX = 0.55

    /** How steeply the map is seen from above, in degrees. */
    private const val PITCH = 38.0

    /** The doll's yaw for looking down, right, up, left on the screen. */
    fun yawOf(f: Facing): Double = when (f) {
        Facing.DOWN -> 0.0
        Facing.RIGHT -> 90.0
        Facing.UP -> 180.0
        Facing.LEFT -> 270.0
    }

    /**
     * How the map is turned on the screen, in degrees: 0 seen straight, −45 seen diagonally (13). A
     * direction in the map then shows turned by this much, so every picture is chosen through [slot].
     */
    @Volatile var viewYaw = 0.0

    /** The drawn direction nearest to [yaw] (a direction in the map), as seen on the screen. */
    fun slot(yaw: Double): Int = Math.floorMod(Math.round((yaw + viewYaw) / (360.0 / YAWS)).toInt(), YAWS)

    /** Long weapons (two-handed, spears, staves, bows) go on the shoulder; short ones are carried low. */
    private val LONG = setOf("spear", "quarterstaff", "staff", "halberd")

    private fun shouldered(hero: Hero): Boolean {
        val d = hero.weapon?.def ?: return false
        return d.twoHanded || d.ranged || d.id in LONG || hero.bothHands()
    }

    /** Whether the hero's weapon is put away at the hip or belt while walking about (10.10., 2: every class). */
    private fun stows(hero: Hero) = hero.weapon?.let { Dress.stows(it) } == true

    /** The hero's outfit on the map: shield on the back, a sword or axe put away. */
    private fun outfit(hero: Hero) = HeroBattle.outfit(hero).withShieldOnBack().let { if (stows(hero)) it.withWeaponStowed() else it }

    /** What the hands are doing while walking about. */
    enum class Carry { LOW, SHOULDER, FREE }

    /** Pictures of a run (245; 245.1: 16, the feet go faster than in a walk): no picture moves a leg further than the jump test allows. */
    const val RUN_STEPS = 16

    /**
     * Walking about: the left arm swings a little with the step, the shield is on the back. A long
     * weapon rests on the right shoulder, pointing up and back; a short one (sword, mace, axe,
     * dagger) is carried low in the right hand, its point forward and down, clear of the ground and
     * of the head from every side. With nothing in hand ([Carry.FREE], folk with the bow slung) both
     * arms hang a little forward of the body, clear of a cloak, and swing with the step.
     *
     * 245 (Chef 20.10.: "robotermäßig"): [moving] the chest turns against the hips with each step, the shoulder
     * opposite the forward foot coming forward, and the body leans a little into the walk; the head keeps looking
     * ahead. [run] (0..1, in [RUN_STEPS] pictures) leans further in, lengthens the stride, bends the knees and the
     * arms, and swings them wider. Standing ([moving] false) the pose is as before.
     */
    fun rig(yaw: Double, step: Int, carry: Carry, moving: Boolean = false, run: Double = 0.0): HeroFigure.Rig {
        val n = if (run > 0) RUN_STEPS else STEPS
        val ph = Math.floorMod(step, n) / n.toDouble()
        val sw = kotlin.math.sin(ph * 2 * Math.PI)
        // a stride a little shorter than the former 11 cm, so no picture moves a leg more than the jump test allows
        val walkSt = 8.4 * sw
        // 245.1 (Chef 20.10.: "wie ein falscher Moonwalk"): running, each foot bears in turn and swings forward lifted
        val fr = runFoot(ph, 0.25); val fl = runFoot(ph, 0.75)
        val st = walkSt + ((fr.f - fl.f) / 2 - walkSt) * run
        val m = if (moving) 1.0 else 0.0
        // arms: a walk swings them along the stride; running bends them, the hands higher and swinging further
        val arm = 0.6 + 0.2 * run
        val lift = 9.0 * run
        val r = Doll.REST.copy(
            yaw = yaw, stride = st, spread = 5.0 - run,
            rh = when (carry) {
                Carry.SHOULDER -> HeroFigure.V(19.0, 78.0, 8.0)
                Carry.LOW -> HeroFigure.V(18.0, 64.0 + lift * 0.5, 10.0 - st * (0.3 + 0.2 * run))
                Carry.FREE -> HeroFigure.V(16.0 - 3.0 * run, 53.0 + lift, 8.0 + 4.0 * run - st * arm)
            },
            lh = if (carry == Carry.FREE) HeroFigure.V(-16.0 + 3.0 * run, 53.0 + lift, 8.0 + 4.0 * run + st * arm)
                else HeroFigure.V(-17.0 + 3.0 * run, 54.0 + lift, 3.0 + 4.0 * run + st * arm),
            weapon = when (carry) {
                Carry.SHOULDER -> HeroFigure.V(0.2, 0.96, -0.2)
                Carry.LOW -> HeroFigure.V(0.12, -0.6, 0.79)
                Carry.FREE -> HeroFigure.V(0.0, -1.0, 0.0)
            },
            aim = 1.0,
            shieldFace = HeroFigure.V(-1.0, 0.0, 0.25),
            // a walk: up as a foot passes beneath, twice a stride
            bodyY = (1 - kotlin.math.cos(ph * 4 * Math.PI)) / 2 * (1 - run) -
                // 245.1: running, the whole body up off the ground while both feet are (bodyY down is positive)
                RUN_BOB * (1 - kotlin.math.cos((ph - 0.45) * 4 * Math.PI)) / 2 * run,
        )
        return if (!moving) r else r.copy(
            // the left shoulder forward as the right foot is: degrees, the head turning back against it (Doll)
            twist = (0.9 - 0.2 * run) * st,
            lean = 0.12 + 0.34 * run,
            // the knees give as a foot bears, mid-stance
            crouch = 2.5 * run * (1 + kotlin.math.cos((ph - 0.45) * 4 * Math.PI)) / 2,
            // 245.2 (Chef 15:27: "als ob er mit den Flügeln schlägt"): the elbows swing back along the body, not out to the side
            elbowsBack = 0.45 + 0.45 * run,
            rPole = if (carry == Carry.SHOULDER) r.rPole else r.rPole.lerp(HeroFigure.V(0.12, -0.4, -1.0), 0.45 + 0.45 * run),
            gait = if (run > 0) 1.0 else 0.0, footR = fr.lerp(HeroFigure.V(0.0, 0.0, 0.0), 1 - run), footL = fl.lerp(HeroFigure.V(0.0, 0.0, 0.0), 1 - run),
        )
    }

    /** Share of a run a foot bears (245.1): less than half, so both feet are off the ground twice a stride. */
    const val RUN_STANCE = 0.4
    /** How far (rig units) a running foot sets down before the hip, leaves the ground behind it, and lifts as it swings. */
    const val RUN_FRONT = 14.0
    const val RUN_BACK = 20.0
    const val RUN_LIFT = 16.0
    /** How far the body rises (rig units) while both feet are off the ground. */
    const val RUN_BOB = 3.5

    /**
     * Where a running foot is at [ph] of the stride (245.1), set down at [down]: on the ground, going back under the hip
     * from [RUN_FRONT] to [RUN_BACK] behind it; then off it, the heel kicking up behind and the foot swinging forward lifted.
     * [HeroFigure.V.f] forward of the hip, [HeroFigure.V.u] up.
     */
    fun runFoot(ph: Double, down: Double): HeroFigure.V {
        val q = (ph - down).mod(1.0)
        if (q < RUN_STANCE) return HeroFigure.V(0.0, 0.0, RUN_FRONT - (RUN_FRONT + RUN_BACK) * q / RUN_STANCE)
        val u = (q - RUN_STANCE) / (1 - RUN_STANCE)
        val e = u * u * (3 - 2 * u)
        return HeroFigure.V(0.0, RUN_LIFT * kotlin.math.sin(Math.PI * Math.pow(u, 0.8)), -RUN_BACK + (RUN_FRONT + RUN_BACK) * e)
    }

    /** Tiles a whole walk ([STEPS] pictures) and a whole run ([RUN_STEPS] pictures) cover (245: running, the legs reach further). */
    const val WALK_TILES = 2.0
    const val RUN_TILES = 3.0

    /** All pictures of one direction: [STEPS] of a walk (0 standing), then [RUN_STEPS] of a run. */
    const val PICS = STEPS + RUN_STEPS

    /**
     * Which picture a walking or running figure shows (245): the stride goes on where it was when the hero
     * starts or stops running, so the legs never jump; a walk covers [WALK_TILES], a run [RUN_TILES].
     */
    class Stride {
        /** 0..1 round a whole stride: the feet stride furthest, setting down, at a quarter and three quarters. */
        var phase = 0.0
            private set
        private var last = Double.NaN
        fun at(walked: Double, run: Boolean): Int {
            if (!last.isNaN()) phase = (phase + (walked - last).coerceIn(0.0, 1.0) / (if (run) RUN_TILES else WALK_TILES)).mod(1.0)
            last = walked
            return if (run) STEPS + (phase * RUN_STEPS).toInt().coerceAtMost(RUN_STEPS - 1) else (phase * STEPS).toInt().coerceAtMost(STEPS - 1)
        }
    }

    /** Picture [pic] of [hero] in direction [slot]: a walk below [STEPS], a run from there. */
    fun drawPic(hero: Hero, slot: Int, pic: Int): PixelImage =
        if (pic >= STEPS) draw(hero, slot, pic - STEPS, run = 1.0) else draw(hero, slot, pic)

    /**
     * A figure turning from [yaw] towards [target] (degrees) by the shortest way over [dtMs] (245: "Drehungen hart"):
     * at most [TURN_MAX] degrees a millisecond, and slowing down as it comes round, so it settles instead of stopping
     * dead. Half a turn takes about a third of a second (before: a quarter, at an even pace).
     */
    fun turnStep(yaw: Double, target: Double, dtMs: Long, maxPerMs: Double = TURN_MAX): Double {
        val d = ((target - yaw) % 360.0 + 540.0) % 360.0 - 180.0
        val ease = d * (1 - kotlin.math.exp(-dtMs / TURN_EASE_MS))
        val max = dtMs * maxPerMs
        val step = if (kotlin.math.abs(ease) > max) kotlin.math.sign(d) * max else if (kotlin.math.abs(d) < 0.5) d else ease
        return ((yaw + step) % 360.0 + 360.0) % 360.0
    }
    const val TURN_MAX = 0.75
    const val TURN_EASE_MS = 70.0

    /** Draws [doll] in [outfit] in [rig] as a map picture. */
    fun render(doll: Doll, outfit: Outfit, rig: HeroFigure.Rig, w: Int = W, h: Int = H): PixelImage =
        doll.render(w, h, w / 2.0, h - (H - GROUND).toDouble(), PX, rig, outfit, pitch = PITCH).img

    /** Pictures are drawn with the feet in the middle, [H] − [GROUND] pixels above the bottom; a wider one (a raised torch) keeps that. */
    const val FOOT_BELOW = H - GROUND

    /** Who the hero is, without the gear: a change of gear keeps it, another save game's hero does not (24.9). */
    private fun who(hero: Hero) = "${hero.name}/${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}"

    private fun look(hero: Hero) = "${who(hero)}/${hero.bothHands()}/" +
        GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" } +
        // 255: a torch held out is drawn without its flame, so its pictures are others
        (if (out && torch(hero)) "/out" else "") +
        // 17 (draft): hair and quiver swinging on are drawn into the pictures, so they are drawn anew when it is switched
        (if (Dress.SWING_MORE) "/17" else "")

    private val cache = HashMap<String, PixelImage>()
    private var preparing: String? = null
    /**
     * The look before the last change of gear: its pictures stay until the new ones are all drawn (24.3), but
     * only for the same hero (24.9); another hero's pictures go at once.
     */
    private var previous: String? = null
    /** Pictures of the [preparing] look still missing before the hero can stand and walk in every direction ([ready]). */
    @Volatile private var missing = java.util.concurrent.atomic.AtomicInteger(0)
    private val workers = ArrayList<Thread>()

    /**
     * True while the black screen between places waits for the pictures (24.1): the drawing threads then run
     * at normal priority, else low, so the game never stutters for them.
     */
    /** 24.13: how long the last [prepare] took until every picture was there, and whether they came from the device. */
    @Volatile var lastFullMs: Long? = null
    @Volatile var lastFromShelf = false

    /** Tests only: the drawing threads wait while this is set. */
    @Volatile internal var hold = false

    @Volatile var urgent = false
        set(v) { field = v; SdfRender.hurry = v; synchronized(workers) { for (t in workers) t.priority = priority() } }

    private fun priority() = if (urgent) Thread.NORM_PRIORITY else Thread.MIN_PRIORITY + 1

    /** Draws one picture now. */
    fun draw(hero: Hero, slot: Int, step: Int, run: Double = 0.0, moving: Boolean = true): PixelImage =
        render(HeroBattle.doll(hero), outfit(hero), lit(hero, rig(slot * 360.0 / YAWS, step, carry(hero), moving, run), step))

    /**
     * 255: whether the hero's torch is held out (in a room, outdoors by day; [de.bornim.core.Game.torchBurns]). Set by the
     * map before [prepare]; a change draws the hero anew as a change of gear does.
     */
    @Volatile var out = false

    /** 84.1: a torch in the off hand is held up before the shoulder; its flame takes another shape with each [beat] (step or breath), or none when [out]. */
    fun lit(hero: Hero, r: HeroFigure.Rig, beat: Int, held: Boolean = out): HeroFigure.Rig =
        if (!torch(hero)) r
        else r.copy(lh = HeroFigure.V(-28.0, 60.0, 4.0 + (r.lh.f - 3.0) * 0.4), flicker = Math.floorMod(beat, 3), out = held)

    private fun carry(hero: Hero) = if (stows(hero)) Carry.FREE else if (shouldered(hero)) Carry.SHOULDER else Carry.LOW

    /** 17 Nachschwingen (17a, in the game since 12.10.): the cloak swings on when the hero stops. */
    @Volatile var swingDraft = true

    /** Only a hero with a cloak or mantle swings on; in the draft (17, `SWINGMORE=1`) also long hair and a quiver. */
    fun cloaked(hero: Hero): Boolean = hero.item(GearSlot.CLOAK) != null ||
        Dress.SWING_MORE && (hero.sex == Sex.FEMALE || hero.race == Race.ELF || hero.item(GearSlot.MAIN_HAND)?.def?.icon == Icon.BOW)

    /** How long the cloak swings on after a stop. */
    const val SWING_MS = 1400L

    /**
     * The cloak [ms] after the hero stopped, as [HeroFigure.Rig.cloak] (positive trails behind): the body
     * stops, the cloth goes on forward, falls back a little past hanging straight and settles.
     */
    fun swingAt(ms: Long): Double =
        if (ms < 0 || ms >= SWING_MS) 0.0 else -1.4 * kotlin.math.sin(Math.PI * ms / 450.0) * kotlin.math.exp(-ms / 500.0)

    /** The swing in steps of a tenth, one picture each. */
    fun swingLevel(ms: Long): Int = Math.round(swingAt(ms) * 10).toInt()

    /** The rig of [hero]'s cloak swung to [level] tenths, standing in direction [slot]. */
    fun swingRig(slot: Int, level: Int, carry: Carry): HeroFigure.Rig = rig(slot * 360.0 / YAWS, 0, carry).let { r ->
        // swung forward the cloth would only go into the body: it flares out to the sides instead
        if (level >= 0) r.copy(cloak = level / 10.0) else r.copy(cloak = level / 20.0, flare = -level / 10.0)
    }

    /** [hero] standing in direction [slot], the cloak swung to [level]: drawn in the background when first wanted. */
    fun swingFrame(hero: Hero, slot: Int, level: Int): PixelImage? =
        if (level == 0) frame(hero, slot, 0)
        else MapRest.picture("swing|${look(hero)}|$slot|$level") { render(HeroBattle.doll(hero), outfit(hero), swingRig(slot, level, carry(hero))) }

    /** The same, drawn now (the previews). */
    fun swingFrameNow(hero: Hero, slot: Int, level: Int): PixelImage =
        MapRest.pictureNow("swing|${look(hero)}|$slot|$level") { render(HeroBattle.doll(hero), outfit(hero), swingRig(slot, level, carry(hero))) }

    /**
     * [hero] standing in [rest], breathing in or out: drawn in the background when first wanted, null until then. With a
     * torch, [flame] (0–2, from [flame]) is the shape of its flame (257); -1 lets it go with the breath as before.
     */
    fun restFrame(hero: Hero, slot: Int, rest: MapRest.Rest, breath: Int, level: Int = MapRest.LEVELS, flame: Int = -1): PixelImage? {
        // 255: a torch held out has no flame to change; drawn later, the picture keeps the state it was asked in
        val held = out
        val f = if (flame >= 0 && torch(hero) && !held) flame else -1
        if ((rest == MapRest.Rest.NEUTRAL || level <= 0) && breath == 0 && f <= 0) return frame(hero, slot, 0)
        if (f < 0) return MapRest.picture("hero|${look(hero)}|$slot|$rest|$breath|$level") { drawRest(hero, slot, rest, breath, level, held = held) }
        return torchShelf.picture("hero|${look(hero)}|$slot|$rest|$breath|$level|$f") { drawRest(hero, slot, rest, breath, level, f) }
    }

    /** One resting picture of [hero], drawn now. */
    fun drawRest(hero: Hero, slot: Int, rest: MapRest.Rest, breath: Int, level: Int = MapRest.LEVELS, flame: Int = -1, held: Boolean = out): PixelImage =
        render(HeroBattle.doll(hero), outfit(hero), lit(hero, MapRest.rig(rig(slot * 360.0 / YAWS, 0, carry(hero)), rest, breath, level), if (flame >= 0) flame else breath + 1, held))

    /** Whether [hero] holds a torch up ([lit]). */
    fun torch(hero: Hero) = hero.item(GearSlot.OFF_HAND)?.def?.kind == BaseKind.LIGHT

    /**
     * 257 (Chef 20.10.: "die Fackel in der Hand des Helden, wenn man einfach steht, hat keine Animation … das sieht ein
     * bisschen tot aus"): the shape of the torch's flame at [clockMs] while the hero stands, each held an uneven
     * 120–220 ms and never the same twice in a row.
     */
    fun flame(clockMs: Long): Int {
        // the n-th change comes [FLAME_MS] × n plus up to 50 ms late
        fun change(n: Long): Long {
            var z = n * -7_046_029_254_386_353_131L
            z = (z xor (z ushr 30)) * -4_658_895_280_553_007_687L; z = (z xor (z ushr 27)) * -7_723_592_293_110_705_685L
            return n * FLAME_MS + Math.floorMod(z xor (z ushr 31), 50L)
        }
        val n = Math.floorDiv(clockMs, FLAME_MS)
        return Math.floorMod(if (clockMs >= change(n)) n else n - 1, 3L).toInt()
    }
    private const val FLAME_MS = 170L

    /** The hero's standing pictures with the torch's other flames, kept apart so the folk's breathing never pushes them out (257). */
    private val torchShelf = MapRest.Shelf(160)

    /** The picture of [hero] turned to direction [slot] at picture [step] of a walk (or a run, [PICS]), or null while it is not drawn yet. */
    fun frame(hero: Hero, slot: Int, step: Int): PixelImage? = synchronized(cache) { cache["${look(hero)}|$slot|${Math.floorMod(step, PICS)}"] }

    /**
     * The picture to show now, never nothing: the one asked for, else the same in the gear worn before
     * (while the new pictures are drawn), else the standing picture of that direction, else the nearest direction already drawn, else that one picture drawn right away (a
     * brief pause, once). So the former little figure no longer shows while the doll is being drawn.
     */
    fun frameNow(hero: Hero, slot: Int, step: Int): PixelImage {
        val l = look(hero)
        val st = Math.floorMod(step, PICS)
        // 245: a run not drawn yet shows the walk at the same point of the stride
        val walkSt = if (st < STEPS) st else (st - STEPS) * STEPS / RUN_STEPS
        synchronized(cache) {
            // 24.3/24.11: after a change of gear every direction walks on in the old gear until the new is drawn
            // in all of them, then all change at once
            previous?.let { p -> cache["$p|$slot|$st"] }?.let { return it }
            cache["$l|$slot|$st"]?.let { return it }
            if (st != walkSt) {
                previous?.let { p -> cache["$p|$slot|$walkSt"] }?.let { return it }
                cache["$l|$slot|$walkSt"]?.let { return it }
            }
        }
        frame(hero, slot, 0)?.let { return it }
        for (d in 1..2) for (s in listOf(slot - d, slot + d)) frame(hero, Math.floorMod(s, YAWS), 0)?.let { return it }
        val img = draw(hero, slot, 0)
        synchronized(cache) { cache["${look(hero)}|$slot|0"] = img }
        return img
    }

    /** How many directions either side of where the hero faces are drawn walking first ([order]). */
    const val FIRST_SIDE = 2

    /**
     * The order the pictures are drawn in (24.2): standing in every direction (nearest to [first] first), so
     * turning never shows a missing picture; then the walk where the hero faces and [FIRST_SIDE] directions
     * either side; then all the rest of the walk; last the runs (245), nearest first. Returns the order and how many of it come first.
     */
    fun order(first: Int): Pair<List<Pair<Int, Int>>, Int> {
        fun dist(s: Int) = minOf(Math.floorMod(s - first, YAWS), Math.floorMod(first - s, YAWS))
        val slots = (0 until YAWS).sortedBy { dist(it) }
        val stand = slots.map { it to 0 }
        val walkNear = slots.filter { dist(it) <= FIRST_SIDE }.flatMap { s -> (1 until STEPS).map { s to it } }
        val rest = slots.filter { dist(it) > FIRST_SIDE }.flatMap { s -> (1 until STEPS).map { s to it } }
        val run = slots.flatMap { s -> (STEPS until PICS).map { s to it } }
        return Pair(stand + walkNear + rest + run, stand.size + walkNear.size)
    }

    /** True when [hero] can stand and walk in every direction (24.1 waits for this, 24.10: not only where it faces; not for the runs, 245). */
    fun ready(hero: Hero): Boolean = synchronized(cache) { preparing == look(hero) } && missing.get() <= 0

    /** t60: every picture of [hero] there, the breathing too; only then may a fight be drawn ahead without slowing the map. */
    fun full(hero: Hero): Boolean = synchronized(cache) { preparing == look(hero) } && lastFullMs != null

    /** 267.1: the look whose pictures were looked for on the device ([HeroShelf]); until then nobody knows how long [prepare] takes. */
    @Volatile private var shelfLooked: String? = null

    /**
     * 267.1: of the pictures [ready] waits for, how many are there and how many in all; null while it is not yet known
     * whether they come from the device (fast) or must be drawn (long: 26–50 s for all on the phones measured, 267).
     */
    fun parts(hero: Hero): Pair<Int, Int>? {
        val l = look(hero)
        if (shelfLooked != l || synchronized(cache) { preparing != l }) return null
        val all = YAWS * STEPS
        return (all - missing.get().coerceIn(0, all)) to all
    }

    /**
     * Draws every picture of [hero] in the background in [order], on two threads (each picture is itself
     * drawn on all cores, row by row, so more threads gain little). After a change of gear the old pictures
     * stay until the new ones are complete (24.3); pictures of any older look are dropped. Pictures kept on the
     * device ([HeroShelf], 24.4) are read instead of drawn, and a look drawn in full is kept there.
     */
    fun prepare(hero: Hero, nearYaw: Double = 0.0) {
        val l = look(hero)
        val (jobs, _) = order(slot(nearYaw))
        val left = java.util.concurrent.atomic.AtomicInteger(jobs.count { it.second < STEPS })
        synchronized(cache) {
            if (preparing == l) return
            if (preparing != null && previous == null) previous = preparing
            // 24.9: only the same hero in other gear walks on in the old pictures
            if (previous == l || previous?.startsWith("${who(hero)}/") == false) previous = null
            preparing = l
            cache.keys.removeAll { !it.startsWith("$l|") && (previous == null || !it.startsWith("$previous|")) }
            missing = left
            lastFullMs = null
        }
        val start = System.currentTimeMillis()
        val next = java.util.concurrent.atomic.AtomicInteger(0)
        val done = java.util.concurrent.atomic.AtomicInteger(0)
        // the worker that draws the last picture: the old look may go, the new one is kept on the device
        fun complete(fromShelf: Boolean) {
            val keep = synchronized(cache) {
                if (preparing != l) return
                previous?.let { p -> cache.keys.removeAll { it.startsWith("$p|") }; previous = null }
                if (fromShelf) null else cache.filterKeys { it.startsWith("$l|") }.mapKeys { (k, _) ->
                    k.substringAfterLast("|").let { st -> k.removeSuffix("|$st").substringAfterLast("|").toInt() to st.toInt() }
                }
            }
            lastFromShelf = fromShelf
            lastFullMs = System.currentTimeMillis() - start
            keep?.let { HeroShelf.save(l, it) }
        }
        val shelf = java.util.concurrent.atomic.AtomicBoolean(false)
        repeat(2) { w ->
            val t = Thread {
              SdfRender.quiet.set(true)
              try { de.bornim.core.Guard.run("Held Karte") {
                // 24.4: kept on the device? Then nothing to draw (the other worker waits for this)
                if (w == 0) {
                    DrawBusy.during(DrawBusy.Kind.HERO) { HeroShelf.load(l) }?.takeIf { it.size == jobs.size }?.let { pics ->
                        synchronized(cache) { if (preparing == l) for ((k, img) in pics) cache["$l|${k.first}|${k.second}"] = img }
                        next.set(jobs.size); left.set(0)
                        complete(true)
                    }
                    shelfLooked = l
                    shelf.set(true)
                } else while (!shelf.get()) Thread.sleep(2)
                while (true) {
                    while (hold) Thread.sleep(5)
                    val i = next.getAndIncrement()
                    if (i >= jobs.size || synchronized(cache) { preparing != l }) break
                    val (s, st) = jobs[i]
                    val k = "$l|$s|$st"
                    if (synchronized(cache) { k !in cache }) {
                        val img = DrawBusy.during(DrawBusy.Kind.HERO) { drawPic(hero, s, st) }
                        synchronized(cache) { if (preparing == l) cache[k] = img }
                    }
                    if (st < STEPS) left.decrementAndGet()
                    if (done.incrementAndGet() == jobs.size) complete(false)
                }
              } } finally {
                // the other worker must not wait for a shelf that failed (30)
                shelf.set(true)
                synchronized(workers) { workers.remove(Thread.currentThread()) }
              }
            }
            t.isDaemon = true
            t.priority = priority()
            synchronized(workers) { workers += t }
            t.start()
        }
    }

    /** How many looks of new loot wait to be drawn ahead at most; older wishes give way to newer ones. */
    const val AHEAD = 4

    private val aheadQueue = ArrayDeque<Hero>()
    private var aheadThread: Thread? = null

    /** [hero] as it would look wearing [g]: a copy, the hero itself is not changed. */
    private fun wearing(hero: Hero, g: de.bornim.core.Gear): Hero =
        Hero(hero.name, hero.race, hero.cls, hero.level, hero.xp, hero.base.toMutableMap(), gear = hero.gear.toMutableMap(),
            sex = hero.sex, build = hero.build, skin = hero.skin, hair = hero.hair).also { it.equip(g) }

    /**
     * 24.15: new loot in the bag is drawn ahead, as the hero would look wearing it, and kept on the device
     * ([HeroShelf]), so putting it on needs no drawing. One quiet thread, each picture on it alone, and only while
     * the hero's own pictures are complete; nothing kept in memory.
     */
    fun ahead(hero: Hero, g: de.bornim.core.Gear) {
        if (HeroShelf.dir == null || !hero.canWear(g)) return
        val trial = wearing(hero, g)
        val l = look(trial)
        if (l == look(hero) || HeroShelf.has(l)) return
        synchronized(aheadQueue) {
            if (aheadQueue.any { look(it) == l }) return
            aheadQueue.addLast(trial)
            while (aheadQueue.size > AHEAD) aheadQueue.removeFirst()
            if (aheadThread != null) return
            aheadThread = Thread {
                SdfRender.alone.set(true)
                while (true) {
                    val h = synchronized(aheadQueue) { aheadQueue.removeLastOrNull() ?: run { aheadThread = null; null } } ?: break
                    de.bornim.core.Guard.run("Beute vorab") { drawAhead(h) }
                }
            }.also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY; it.start() }
        }
    }

    /** Draws every picture of [hero] for the device, pausing while the hero's own pictures are being drawn. */
    private fun drawAhead(hero: Hero) {
        val l = look(hero)
        if (HeroShelf.has(l)) return
        val pics = HashMap<Pair<Int, Int>, PixelImage>()
        for ((s, st) in order(0).first) {
            while (hold || missing.get() > 0 || synchronized(workers) { workers.isNotEmpty() }) Thread.sleep(50)
            // drawn by the hero's own threads meanwhile (it was put on): nothing left to do
            if (synchronized(cache) { preparing == l }) return
            pics[s to st] = DrawBusy.during(DrawBusy.Kind.LOOT) { drawPic(hero, s, st) }
        }
        HeroShelf.save(l, pics)
    }

    /** Tests only: draws one picture of [hero] into the store, as the drawing threads would. */
    internal fun drawOne(hero: Hero, slot: Int, step: Int) {
        val img = drawPic(hero, slot, step)
        synchronized(cache) { cache["${look(hero)}|$slot|$step"] = img }
    }

    /** Draws every picture right away (previews and tests). */
    fun prepareNow(hero: Hero) {
        val l = look(hero)
        synchronized(cache) { preparing = l; previous = null }
        for (s in 0 until YAWS) for (st in 0 until PICS) {
            val k = "$l|$s|$st"
            if (synchronized(cache) { k in cache }) continue
            val img = drawPic(hero, s, st)
            synchronized(cache) { cache[k] = img }
        }
    }
}
