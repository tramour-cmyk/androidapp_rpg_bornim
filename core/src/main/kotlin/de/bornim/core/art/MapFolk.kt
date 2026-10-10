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
    /** One of the folk: [carry] how the hands go walking about (a guard's spear or an elder's staff on the shoulder). */
    class Folk(val id: String, val doll: Doll, val outfit: Outfit, val carry: MapFigure.Carry = MapFigure.Carry.FREE)

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

    // ------------------------------------------------------------ the village, drafts (night of 09.10.), not yet on the map

    private fun human(sex: Sex, build: Build, skin: Int, hair: Int, beard: Boolean = false, grey: Int? = null, small: Double = 1.0) =
        Doll(Race.HUMAN, sex, build, skin = skin, hairTone = hair, beard = beard, hairOverride = grey, sizeK = small)
    private fun clothes(cloth: Int, dark: Int, pants: Int) = Triple(cloth, dark, pants)

    /** Rowena, who keeps the inn: sturdy, sleeves rolled, a long dress of brown wool, an apron's pale. */
    val rowena = Folk("rowena", human(Sex.FEMALE, Build.STRONG, 1, 3),
        Outfit(CharClass.FIGHTER, kit("robe", "boots"), clothes = clothes(0x6A4A34, 0x9A8A70, 0x3E2E22)))
    /** Elder Aldric: old and thin, white beard, a long robe of faded plum, a staff on his shoulder. */
    val aldric = Folk("aldric", human(Sex.MALE, Build.SLIM, 0, 0, beard = true, grey = 0xC8C4BC),
        Outfit(CharClass.FIGHTER, kit("robe", "mantle", "quarterstaff"), cloakRgb = 0x3A3040, clothes = clothes(0x5A4A5E, 0x3E3242, 0x2E2630)), MapFigure.Carry.SHOULDER)
    /** Thessa the trader: well-to-do, a dyed tunic of rust and ochre, good boots, a cloak against the road. */
    val thessa = Folk("thessa", human(Sex.FEMALE, Build.AVERAGE, 0, 2),
        Outfit(CharClass.ROGUE, kit("leather", "boots", "gloves", "cloak"), cloakRgb = 0x5A3A26, clothes = clothes(0x8A5A2A, 0x6A3E20, 0x3A2E26)))
    /** Brother Osric: shaven head, a robe of undyed wool, the sun on his breast. */
    val osric = Folk("osric", human(Sex.MALE, Build.AVERAGE, 1, 0),
        Outfit(CharClass.CLERIC, kit("robe", "holy_symbol"), clothes = clothes(0xB8AC90, 0x8A806A, 0x5A5244), bald = true))
    /** Sister Lyra: a priestess of the sun, white robe and the circlet. */
    val lyra = Folk("lyra", human(Sex.FEMALE, Build.SLIM, 0, 1),
        Outfit(CharClass.CLERIC, kit("robe", "circlet"), clothes = clothes(0xD8D0C0, 0xA8A090, 0x7A7468)))
    /** Guard Jorin: mail shirt, a helmet, the village's blue on his tabard, a spear on his shoulder. */
    val jorin = Folk("jorin", human(Sex.MALE, Build.STRONG, 2, 0),
        Outfit(CharClass.FIGHTER, kit("chain_shirt", "helmet", "boots", "gloves", "spear"), clothes = clothes(0x34486A, 0x223250, 0x3A3630)), MapFigure.Carry.SHOULDER)
    /** Pim, a child of the village: small, a tunic too big for him. */
    val pim = Folk("pim", human(Sex.MALE, Build.SLIM, 0, 1, small = 0.62),
        Outfit(CharClass.FIGHTER, kit(), clothes = clothes(0x5A6A7A, 0x3E4A56, 0x4A3A2A)))
    /** Farmer Bram: broad, sunburnt, a beard, a coarse linen shirt and earth-brown breeches. */
    val bram = Folk("bram", human(Sex.MALE, Build.STRONG, 2, 0, beard = true),
        Outfit(CharClass.FIGHTER, kit("boots"), clothes = clothes(0xA89A78, 0x7A6A50, 0x4A3A28)))
    /** Liska, a maid: a dress of faded red, a kerchief's pale. */
    val liska = Folk("liska", human(Sex.FEMALE, Build.SLIM, 0, 1),
        Outfit(CharClass.FIGHTER, kit("robe"), clothes = clothes(0x7A3A3A, 0xA89A84, 0x4A2E2A)))
    /** Gwenna, a fisherwoman: a dress of muddy green, a shawl. */
    val gwenna = Folk("gwenna", human(Sex.FEMALE, Build.AVERAGE, 1, 0),
        Outfit(CharClass.FIGHTER, kit("robe", "cloak"), cloakRgb = 0x4A4434, clothes = clothes(0x4E5A3A, 0x3A4430, 0x3A3428)))
    /** Borin the dwarf: smith's leather and gloves, a hammer on his shoulder. */
    val borin = Folk("borin", Doll(Race.DWARF, Sex.MALE, Build.STRONG, skin = 1, hairTone = 0),
        Outfit(CharClass.FIGHTER, kit("leather", "gloves", "boots", "maul"), leatherRgb = 0x4A3424, clothes = clothes(0x5A4A3A, 0x3E3228, 0x3A3028)), MapFigure.Carry.SHOULDER)
    /** Morwen the herbalist: old, grey hair under a hood, a robe of moss green. */
    val morwen = Folk("morwen", human(Sex.FEMALE, Build.SLIM, 1, 0, grey = 0x9C9890),
        Outfit(CharClass.ROGUE, kit("robe", "hood"), cloakRgb = 0x3E4A30, clothes = clothes(0x4A5A36, 0x34402A, 0x2E2A22)))

    /** The village folk drawn as dolls so far only as drafts: shown on a sheet, not yet on the map. */
    val drafts = listOf(rowena, aldric, thessa, osric, lyra, jorin, pim, bram, liska, gwenna, borin, morwen)

    private val all = listOf(garrick).associateBy { it.id }

    /** The doll for the person [npcId], or null when that one is still drawn the former way. */
    fun of(npcId: String): Folk? = all[npcId]

    /** Standing still or walking: [step] as in [MapFigure.STEPS]. */
    fun draw(f: Folk, slot: Int, step: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, MapFigure.rig(slot * 360.0 / MapFigure.YAWS, step, f.carry))

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

    /** What the warding one does [tMs] after the beast came: the stance, the flame's shape, and whether it faces the beast (else its fire). */
    class Warding(val ward: Ward, val flicker: Int, val faceBeast: Boolean)

    /** How long the whole scene takes: torch out of the fire, swung at the beast, put back. */
    const val WARD_MS = 3_700L

    /**
     * The scene in time: bent over the fire taking the brand (0.45 s), raising it while turning to
     * the beast, swinging it left and right (about 2.2 s, a swing every 0.28 s), turning back and
     * putting it into the fire again. Null before and after.
     */
    fun wardAt(tMs: Long): Warding? = when {
        tMs < 0 || tMs >= WARD_MS -> null
        tMs < 450 -> Warding(Ward.GRAB, ((tMs / 150) % FLICKERS).toInt(), faceBeast = false)
        tMs < 700 -> Warding(Ward.HOLD, 0, faceBeast = true)
        tMs < 2_900 -> {
            val i = ((tMs - 700) / 280).toInt()
            if (i % 2 == 0) Warding(Ward.LEFT, if (i % 4 == 0) 0 else 2, true) else Warding(Ward.RIGHT, 1, true)
        }
        tMs < 3_250 -> Warding(Ward.HOLD, 0, faceBeast = false)
        else -> Warding(Ward.GRAB, ((tMs / 150) % FLICKERS).toInt(), faceBeast = false)
    }

    /** The warding picture, drawn in the background when first wanted, null until then. */
    fun wardFrame(f: Folk, slot: Int, ward: Ward, flicker: Int): PixelImage? =
        MapRest.picture("ward|${f.id}|$slot|$ward|$flicker") { drawWard(f, slot, ward, flicker) }

    /** Draws ahead the warding pictures of [f]: taking the brand towards its fire at [homeSlot], swinging it every way. */
    fun prepareWard(f: Folk, homeSlot: Int) {
        for (fl in 0 until FLICKERS) wardFrame(f, homeSlot, Ward.GRAB, fl)
        for (s in 0 until MapFigure.YAWS) {
            wardFrame(f, s, Ward.HOLD, 0); wardFrame(f, s, Ward.LEFT, 0); wardFrame(f, s, Ward.RIGHT, 1); wardFrame(f, s, Ward.LEFT, 2)
        }
    }

    /** Draws all warding pictures of [f] right away (previews and films). */
    fun prepareWardNow(f: Folk) {
        for (s in 0 until MapFigure.YAWS) for (w in Ward.entries) for (fl in 0 until FLICKERS)
            MapRest.pictureNow("ward|${f.id}|$s|$w|$fl") { drawWard(f, s, w, fl) }
    }

    /** One warding picture of [f] turned to [slot]. */
    fun drawWard(f: Folk, slot: Int, ward: Ward, flicker: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, wardRig(slot * 360.0 / MapFigure.YAWS, ward, flicker), WARD_W, WARD_H)

    /** Warding pictures are wider and taller: the torch reaches far out and up. */
    const val WARD_W = 152
    const val WARD_H = 150

    /**
     * Draft (night of 09.10.): Garrick down at his fire. [SQUAT] hunkered on his heels, forearms on
     * the knees; [STOKE] leaning in, stirring the embers with a stick (two pictures); [DOZE] at night,
     * the head sunk on the chest.
     */
    enum class Squat { SQUAT, STOKE_A, STOKE_B, DOZE }

    fun squatRig(yaw: Double, pose: Squat): HeroFigure.Rig {
        val base = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE).copy(crouch = 40.0, spread = 11.0, stride = 4.0)
        return when (pose) {
            Squat.SQUAT -> base.copy(lean = 0.3, headDown = 1.0, rh = HeroFigure.V(9.0, 42.0, 24.0), lh = HeroFigure.V(-9.0, 42.0, 24.0))
            Squat.STOKE_A -> base.copy(lean = 0.45, headDown = 3.0, torch = 1.0, flicker = -1, aim = 1.0, grip = 10.0,
                rh = HeroFigure.V(8.0, 40.0, 30.0), weapon = HeroFigure.V(0.1, -0.8, 0.6), lh = HeroFigure.V(-9.0, 40.0, 22.0))
            Squat.STOKE_B -> base.copy(lean = 0.48, headDown = 3.0, torch = 1.0, flicker = -1, aim = 1.0, grip = 10.0,
                rh = HeroFigure.V(10.0, 37.0, 34.0), weapon = HeroFigure.V(0.25, -0.85, 0.46), lh = HeroFigure.V(-9.0, 40.0, 22.0))
            // asleep: the head sunk deep on the chest, the back rounded, the hands slack on the knees (10.10., 3.3)
            Squat.DOZE -> base.copy(lean = 0.48, headDown = 17.0, rh = HeroFigure.V(5.0, 40.0, 21.0), lh = HeroFigure.V(-5.0, 41.0, 20.0))
        }
    }

    fun drawSquat(f: Folk, slot: Int, pose: Squat): PixelImage =
        MapFigure.render(f.doll, f.outfit, squatRig(slot * 360.0 / MapFigure.YAWS, pose))

    /** The squatting picture, drawn in the background when first wanted, null until then. */
    fun squatFrame(f: Folk, slot: Int, pose: Squat): PixelImage? =
        MapRest.picture("squat|${f.id}|$slot|$pose") { drawSquat(f, slot, pose) }

    /** Whether [f] sits down at its fire now and then: the one who keeps a fire (Garrick). */
    fun squats(f: Folk) = f.id == "garrick"

    /** Squatting is decided by chance in blocks of this length, apart from the idle loops. */
    const val SQUAT_BLOCK_MS = 45_000L

    /**
     * Garrick down at his fire (10.10., 3): now and then he hunkers down on his heels facing the
     * fire. By day for 9 to 19 s, stirring the embers once or twice; at night more often and for up
     * to 40 s, stirring them once and then nodding off. Chance decides in blocks of
     * [SQUAT_BLOCK_MS], so it never comes on a beat. Null while he stands. When the hero comes near or
     * a beast turns up, the caller lets him stand at once (he starts up).
     */
    fun squatAt(f: Folk, clockMs: Long, night: Boolean): Squat? {
        if (forceDoze) return dozing(f, clockMs)
        val n = Math.floorDiv(clockMs, SQUAT_BLOCK_MS)
        val t = clockMs - n * SQUAT_BLOCK_MS
        val r = java.util.Random(n * 7_000_003L + f.id.hashCode() * 31L + 5)
        // every draw is made in the same order each time, so the block plays out the same at every moment
        val sits = r.nextDouble() < (if (night) 0.7 else 0.35)
        val start = 3_000L + (r.nextDouble() * 12_000).toLong()
        val length = if (night) 18_000L + (r.nextDouble() * 22_000).toLong() else 9_000L + (r.nextDouble() * 10_000).toLong()
        val stokes = if (night) 1 else 1 + r.nextInt(2)
        val stokeAt = LongArray(2) { k -> 1_500L + k * (3_500L + (r.nextDouble() * 3_000).toLong()) }
        val stokeLen = LongArray(2) { 1_400L + (r.nextDouble() * 1_200).toLong() }
        val dozeAt = 6_500L + (r.nextDouble() * 4_000).toLong()
        val end = minOf(start + length, SQUAT_BLOCK_MS - 1_500)
        if (!sits || t < start || t >= end) return null
        val s = t - start
        for (k in 0 until stokes) if (s >= stokeAt[k] && s < stokeAt[k] + stokeLen[k])
            return if (((s - stokeAt[k]) / 340) % 2 == 0L) Squat.STOKE_A else Squat.STOKE_B
        return if (night && s >= dozeAt) dozing(f, s - dozeAt) else Squat.SQUAT
    }

    /**
     * Nodding off [ms] after falling asleep: the head sunk, and every few seconds (never on a beat)
     * it jerks up for a moment and sinks again.
     */
    private fun dozing(f: Folk, ms: Long): Squat {
        val n = Math.floorDiv(ms, 6_000L)
        val r = java.util.Random(n * 1_000_033L + f.id.hashCode())
        val jerkAt = 1_500L + (r.nextDouble() * 3_500).toLong()
        val jerks = r.nextDouble() < 0.55
        val t = ms - n * 6_000L
        return if (jerks && t in jerkAt until jerkAt + 450) Squat.SQUAT else Squat.DOZE
    }

    /** Test switch: Garrick sits and dozes all the time (10.10., 3a; to be removed again). */
    @Volatile var forceDoze = false

    /** Draws ahead the squatting pictures of [f] facing its fire at [homeSlot]. */
    fun prepareSquat(f: Folk, homeSlot: Int) {
        for (p in Squat.entries) squatFrame(f, homeSlot, p)
    }

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

    /** Starts drawing the folk standing on [map] in the background, each facing its own way first, then their idle loops; those at a safe place also their torch. */
    fun prepareFor(map: de.bornim.core.MapDef) {
        for (npc in map.npcs) of(npc.id)?.let {
            val home = MapFigure.slot(MapFigure.yawOf(npc.facing))
            prepare(it, home)
            if (map.safeZones.any { z -> z.x == npc.x && z.y == npc.y }) prepareWard(it, home)
            if (squats(it)) prepareSquat(it, home)
        }
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
