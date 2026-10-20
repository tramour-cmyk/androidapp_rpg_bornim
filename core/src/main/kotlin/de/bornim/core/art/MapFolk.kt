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
        Outfit(CharClass.FIGHTER, kit("robe", "boots"), clothes = clothes(0x6A4A34, 0x9A8A70, 0x3E2E22), flaskRgb = 0x7A4A2A))
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

    /**
     * How far [npc] stands off the middle of its tile, in map pixels: whoever stands
     * at a counter facing it close up to it, so the cloth and the jug reach the board (87.2, test of 0.1.740: Rowena
     * wiped the air half a tile behind her counter).
     */
    fun nudge(npc: de.bornim.core.Npc, map: de.bornim.core.MapDef): Pair<Int, Int> {
        val T = WorldArt.T
        // 152 (Chef, Build 17: "aus westlicher Richtung definitiv größerer Abstand"): the hero never enters someone's
        // tile, so anyone drawn off its middle is farther off from one side; Garrick now stands in the middle of his
        // tile, beside the fire
        val f = npc.facing
        if (map.tile(npc.x + f.dx, npc.y + f.dy) == de.bornim.core.Tile.COUNTER) return f.dx * T * 2 / 5 to f.dy * T * 2 / 5
        return 0 to 0
    }

    /** Borin's poses at his table (55.2): hands on the table, a drink from his flask, a bite, a look round. */
    enum class Seat { REST, DRINK, EAT, LOOK, BREATHE }

    /** A moment at the table: between [from] and [to], [k] of [BLEND] steps (like [SquatPose]). */
    data class SeatPose(val from: Seat, val to: Seat, val k: Int) {
        val main: Seat get() = if (k * 2 >= BLEND) to else from
    }

    /** Who sits at a table instead of standing (55.2): Borin in the inn. */
    fun sits(f: Folk) = f.id == "borin"

    /** What he does at the table is decided by chance in blocks of this length, never on a beat. */
    const val SEAT_BLOCK_MS = 20_000L
    /** Moving from one pose at the table into another takes this long. */
    const val SEAT_MOVE_MS = 700L

    private fun seat(a: Seat, b: Seat, t: Double) =
        SeatPose(a, b, Math.round(t.coerceIn(0.0, 1.0) * BLEND).toInt()).let { if (it.k == 0) SeatPose(a, a, 0) else if (it.k == BLEND) SeatPose(b, b, 0) else it }

    /**
     * What [f] does at the table at [clockMs] (55.2): mostly hands on the table and breathing; within each block of
     * [SEAT_BLOCK_MS] once or twice, at chance moments and for chance lengths, a drink, a bite or a look round, moving
     * into it and back over [SEAT_MOVE_MS]. Each block starts and ends at rest, so blocks join without a jump.
     */
    fun seatPoseAt(f: Folk, clockMs: Long): SeatPose {
        val n = Math.floorDiv(clockMs, SEAT_BLOCK_MS)
        val t = clockMs - n * SEAT_BLOCK_MS
        for (s in seatActs(f, n)) if (t in s.at until s.end) {
            val u = t - s.at
            return when {
                u < SEAT_MOVE_MS -> seat(Seat.REST, s.what, ease(u / SEAT_MOVE_MS.toDouble()))
                u < SEAT_MOVE_MS + s.hold -> SeatPose(s.what, s.what, 0)
                else -> seat(s.what, Seat.REST, ease((u - SEAT_MOVE_MS - s.hold) / SEAT_MOVE_MS.toDouble()))
            }
        }
        return breathing(clockMs)
    }

    /** One action at the table, from [at] to [end] ms into its block, held [hold] ms between moving in and out. */
    private class SeatAct(val what: Seat, val at: Long, val hold: Long, val end: Long)

    /** The actions of [f] at the table in block [n] of [SEAT_BLOCK_MS], fixed by chance (so picture and sound agree). */
    private fun seatActs(f: Folk, n: Long): List<SeatAct> {
        val r = java.util.Random(n * 9_000_011L + f.id.hashCode() * 17L + 3)
        val acts = r.nextInt(3)
        var at = 1_500L + (r.nextDouble() * 5_000).toLong()
        val out = mutableListOf<SeatAct>()
        for (k in 0 until acts) {
            val what = listOf(Seat.DRINK, Seat.EAT, Seat.LOOK)[r.nextInt(3)]
            val hold = 1_400L + (r.nextDouble() * (if (what == Seat.LOOK) 2_600 else 1_800)).toLong()
            val end = at + SEAT_MOVE_MS + hold + SEAT_MOVE_MS
            if (end > SEAT_BLOCK_MS - 500) break
            out += SeatAct(what, at, hold, end)
            at = end + 2_000L + (r.nextDouble() * 4_000).toLong()
        }
        return out
    }

    /**
     * At rest he breathes: the chest rising and falling about every four seconds, the pace drifting a little so it never
     * keeps time; a breath is so small that going into an action from any point of it does not jump.
     */
    private fun breathing(clockMs: Long): SeatPose {
        val ph = clockMs / 4_000.0 * 2 * Math.PI + 0.7 * kotlin.math.sin(clockMs / 9_300.0)
        return seat(Seat.REST, Seat.BREATHE, 0.5 - 0.5 * kotlin.math.cos(ph))
    }

    /** The outfit Borin sits in: the hammer is put by at the table, a tankard in his hand (87.3). */
    private val seatedOutfit by lazy {
        val o = borin.outfit
        Outfit(o.cls, o.items.filterValues { it.base != "maul" }, leatherRgb = o.leatherRgb, clothes = o.clothes, flaskRgb = 0x8A6A2A, tankard = true)
    }

    /** The rig of one pose at the table, facing [yaw]. */
    fun seatRig(yaw: Double, pose: Seat): HeroFigure.Rig {
        // the open flask stays in his left hand, standing on the table while he rests: it never pops in or out
        val base = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE).copy(sit = 1.0, stride = 0.0, spread = 7.0,
            rh = HeroFigure.V(12.0, 60.0, 22.0), lh = HeroFigure.V(-12.0, 60.0, 22.0), flask = 1.0, cork = 0.0)
        return when (pose) {
            Seat.DRINK -> base.copy(lh = HeroFigure.V(-5.0, 74.0, 11.0), flaskTilt = 70.0, headDown = -4.0)
            Seat.EAT -> base.copy(rh = HeroFigure.V(4.0, 72.0, 11.0), headDown = 4.0)
            Seat.LOOK -> base.copy(lh = HeroFigure.V(-12.0, 36.0, 16.0), headTurn = 45.0, twist = 10.0)
            Seat.REST -> base
            // a breath in: the chest and shoulders lift a little, the hands on the table stay
            Seat.BREATHE -> base.copy(bodyY = 0.5, cloak = 0.45)
        }
    }

    /** The rig of a [SeatPose]: the two poses mixed. */
    fun seatRig(yaw: Double, p: SeatPose): HeroFigure.Rig {
        val a = seatRig(yaw, p.from)
        return if (p.k == 0) a else a.lerp(seatRig(yaw, p.to), p.k / BLEND.toDouble())
    }

    /** The picture of [f] at a [SeatPose] facing [slot]: drawn in the background, until then the nearer pose's or resting picture. */
    fun seatFrame(f: Folk, slot: Int, p: SeatPose): PixelImage? {
        fun one(q: SeatPose) = MapRest.picture("seat|${f.id}|$slot|${q.from}>${q.to}|${q.k}") { MapFigure.render(f.doll, seatedOutfit, seatRig(slot * 360.0 / MapFigure.YAWS, q)) }
        return one(p) ?: one(SeatPose(p.main, p.main, 0)) ?: one(SeatPose(Seat.REST, Seat.REST, 0))
    }

    /** Draws ahead every picture of [f] at the table facing [slot]: the poses and the steps between rest and each. */
    fun prepareSeat(f: Folk, slot: Int) {
        for (s in Seat.entries) {
            seatFrame(f, slot, SeatPose(s, s, 0))
            if (s != Seat.REST) for (k in 1 until BLEND) { seatFrame(f, slot, SeatPose(Seat.REST, s, k)); seatFrame(f, slot, SeatPose(s, Seat.REST, k)) }
        }
    }

    /** One pose of Borin at the table for the preview sheet: [pose] 0 rest, 1 drinking, 2 eating, 3 looking round. */
    fun borinSits(slot: Int, pose: Int): PixelImage =
        MapFigure.render(borin.doll, seatedOutfit, seatRig(slot * 360.0 / MapFigure.YAWS, Seat.entries[pose]))

    // ------------------------------------------------------------ 134.2: a gesture with the golden sign

    /**
     * How someone hails the hero along with the golden sign (134.2, Homer 18.10., `LISTE-FIGUREN.md`): a hand raised
     * ([HAND], open as in blessing, hesitant, or waved to and fro), beckoning twice ([BECKON], short or slow), a nod
     * twice ([NOD]), or lifting what they already hold ([STAFF], [JUG], [CUP]). About a second, only what the outline shows.
     */
    enum class Gesture { HAND, BLESS, SHY, WAVE, BECKON, BECKON_SHORT, BECKON_SLOW, NOD, STAFF, JUG, CUP }

    /** The gesture of [f] (Homer's table): everyone not named raises a hand. */
    fun gesture(f: Folk): Gesture = when (f.id) {
        "aldric" -> Gesture.STAFF
        "rowena" -> Gesture.JUG
        "borin" -> Gesture.CUP
        "osric" -> Gesture.BLESS
        "gwenna" -> Gesture.SHY
        "pim" -> Gesture.WAVE
        "thessa" -> Gesture.BECKON
        "jorin" -> Gesture.BECKON_SHORT
        "morwen" -> Gesture.BECKON_SLOW
        "lyra", "garrick", "liska" -> Gesture.NOD
        else -> Gesture.HAND
    }

    /** The poses a gesture moves between: [REST] standing (or sitting) still, [UP] the hand or the thing raised, [SIDE] and [IN] the other end of a wave or a beckon, [DOWN] the head bowed. */
    enum class GPose { REST, UP, SIDE, IN, DOWN }

    /** Steps between two poses of a gesture: a hand goes far up, so more than [BLEND]. */
    const val GBLEND = 6

    /** A moment of a gesture: between [from] and [to], [k] of [GBLEND] steps (like [SquatPose]). */
    data class GesturePose(val from: GPose, val to: GPose, val k: Int) {
        val main: GPose get() = if (k * 2 >= GBLEND) to else from
    }

    /** The course of [g]: poses at moments in ms from its start, moved between smoothly; it ends at rest. */
    private fun course(g: Gesture): List<Pair<Long, GPose>> = when (g) {
        Gesture.HAND -> listOf(0L to GPose.REST, 260L to GPose.UP, 760L to GPose.UP, 1_060L to GPose.REST)
        Gesture.BLESS -> listOf(0L to GPose.REST, 320L to GPose.UP, 820L to GPose.UP, 1_120L to GPose.REST)
        Gesture.SHY -> listOf(0L to GPose.REST, 440L to GPose.UP, 820L to GPose.UP, 1_220L to GPose.REST)
        Gesture.WAVE -> listOf(0L to GPose.REST, 200L to GPose.UP, 330L to GPose.SIDE, 460L to GPose.UP, 590L to GPose.SIDE, 720L to GPose.UP, 960L to GPose.REST)
        Gesture.BECKON -> listOf(0L to GPose.REST, 220L to GPose.UP, 380L to GPose.IN, 540L to GPose.UP, 700L to GPose.IN, 980L to GPose.REST)
        Gesture.BECKON_SHORT -> listOf(0L to GPose.REST, 180L to GPose.UP, 320L to GPose.IN, 460L to GPose.UP, 600L to GPose.IN, 820L to GPose.REST)
        Gesture.BECKON_SLOW -> listOf(0L to GPose.REST, 320L to GPose.UP, 560L to GPose.IN, 800L to GPose.UP, 1_040L to GPose.IN, 1_340L to GPose.REST)
        Gesture.NOD -> listOf(0L to GPose.REST, 200L to GPose.DOWN, 400L to GPose.REST, 600L to GPose.DOWN, 840L to GPose.REST)
        Gesture.STAFF, Gesture.JUG, Gesture.CUP -> listOf(0L to GPose.REST, 300L to GPose.UP, 700L to GPose.UP, 1_000L to GPose.REST)
    }

    /** How long [g] takes. */
    fun gestureMs(g: Gesture): Long = course(g).last().first

    /** Where [f] is in its gesture [tMs] after it began, null before and after. */
    fun gestureAt(f: Folk, tMs: Long): GesturePose? {
        val c = course(gesture(f))
        if (tMs < 0 || tMs >= c.last().first) return null
        val i = c.indexOfLast { it.first <= tMs }
        val (t0, a) = c[i]; val (t1, b) = c[i + 1]
        val k = Math.round(ease((tMs - t0) / (t1 - t0).toDouble()) * GBLEND).toInt()
        return if (a == b || k == 0) GesturePose(a, a, 0) else if (k == GBLEND) GesturePose(b, b, 0) else GesturePose(a, b, k)
    }

    /** The rig of [f] in [pose] of its gesture, the body turned to [yaw]. */
    fun gestureRig(f: Folk, yaw: Double, pose: GPose): HeroFigure.Rig {
        val g = gesture(f)
        // the one sitting at his table lifts his tankard from there; a jug comes into the hand that lifts it, low behind the counter
        val base = when (g) {
            Gesture.CUP -> seatRig(yaw, Seat.REST)
            Gesture.JUG -> MapFigure.rig(yaw, 0, f.carry).copy(flask = 1.0, cork = 0.0, lh = HeroFigure.V(-15.0, 58.0, 12.0))
            else -> MapFigure.rig(yaw, 0, f.carry)
        }
        if (pose == GPose.REST) return base
        return when (g) {
            // the right hand up beside the head, the elbow lifted; waved: out to the side and back
            Gesture.HAND, Gesture.WAVE -> base.copy(
                rh = if (pose == GPose.SIDE) HeroFigure.V(38.0, 114.0, 6.0) else HeroFigure.V(26.0, 122.0, 6.0), rPole = DOWN_POLE, headDown = -1.0)
            // the open hand forward at the height of the face, as in blessing
            Gesture.BLESS -> base.copy(rh = HeroFigure.V(22.0, 104.0, 22.0), rPole = DOWN_POLE)
            // only to the shoulder, the head a little bowed
            Gesture.SHY -> base.copy(rh = HeroFigure.V(24.0, 96.0, 12.0), rPole = DOWN_POLE, headDown = 3.0)
            // the hand up and out at the height of the head, then drawn in towards it, seen from every side; the guard
            // beckons with his free left hand
            Gesture.BECKON, Gesture.BECKON_SLOW -> base.copy(
                rh = if (pose == GPose.IN) HeroFigure.V(16.0, 108.0, 8.0) else HeroFigure.V(32.0, 100.0, 20.0), rPole = DOWN_POLE, twist = -6.0)
            Gesture.BECKON_SHORT -> base.copy(
                lh = if (pose == GPose.IN) HeroFigure.V(-16.0, 108.0, 8.0) else HeroFigure.V(-32.0, 100.0, 20.0), twist = 6.0)
            // the head bowed well down, the shoulders following a little
            Gesture.NOD -> base.copy(headDown = 16.0, lean = 0.06)
            // the staff off the shoulder, raised upright before him
            Gesture.STAFF -> base.copy(rh = HeroFigure.V(22.0, 120.0, 14.0), weapon = HeroFigure.V(0.1, 1.0, 0.1), rPole = DOWN_POLE)
            // the jug raised as in a toast
            Gesture.JUG -> base.copy(lh = HeroFigure.V(-20.0, 116.0, 12.0), headDown = -1.5)
            Gesture.CUP -> base.copy(lh = HeroFigure.V(-18.0, 106.0, 12.0), headDown = -2.0)
        }
    }

    /** The rig of a [GesturePose]: the two poses mixed. */
    fun gestureRig(f: Folk, yaw: Double, p: GesturePose): HeroFigure.Rig {
        val a = gestureRig(f, yaw, p.from)
        return if (p.k == 0) a else a.lerp(gestureRig(f, yaw, p.to), p.k / GBLEND.toDouble())
    }

    /** A raised arm bends its elbow down and a little forward, not out to the side (a straight arm stuck out between). */
    private val DOWN_POLE = HeroFigure.V(0.35, -1.0, 0.25)

    /** The gesture pictures, on a shelf of their own so they do not push out the standing ones. */
    private val gestures = MapRest.Shelf(160)

    private fun gestureKey(f: Folk, slot: Int, p: GesturePose) = "gest|${f.id}|$slot|${p.from}>${p.to}|${p.k}"

    /** One gesture picture of [f] turned to [slot], drawn now: taller and wider, a staff or hand reaches high. */
    fun drawGesture(f: Folk, slot: Int, p: GesturePose): PixelImage =
        MapFigure.render(f.doll, if (gesture(f) == Gesture.CUP) seatedOutfit else f.outfit, gestureRig(f, slot * 360.0 / MapFigure.YAWS, p), WARD_W, WARD_H)

    /** The picture of [f] at [p] facing [slot]: drawn in the background, until then the nearer pose's, or null. */
    fun gestureFrame(f: Folk, slot: Int, p: GesturePose): PixelImage? {
        fun one(q: GesturePose) = gestures.picture(gestureKey(f, slot, q)) { drawGesture(f, slot, q) }
        return one(p) ?: if (p.k != 0) gestures.cached(gestureKey(f, slot, GesturePose(p.main, p.main, 0))) else null
    }

    /** Every moment of the gesture of [f], in order. */
    fun gesturePoses(f: Folk): List<GesturePose> {
        val c = course(gesture(f))
        return buildList {
            for (i in 0 until c.size - 1) {
                val a = c[i].second; val b = c[i + 1].second
                add(GesturePose(a, a, 0))
                if (a != b) for (k in 1 until GBLEND) add(GesturePose(a, b, k))
            }
        }.distinct()
    }

    /** Draws ahead the gesture of [f] facing [slot] (134.2: before it hails the hero). */
    fun prepareGesture(f: Folk, slot: Int) {
        for (p in gesturePoses(f)) gestures.picture(gestureKey(f, slot, p)) { drawGesture(f, slot, p) }
    }

    /** The village folk drawn as dolls so far only as drafts: shown on a sheet, not yet on the map. */
    val drafts = listOf(rowena, aldric, thessa, osric, lyra, jorin, pim, bram, liska, gwenna, borin, morwen)

    // 5.3: everyone who stands about in the village, its houses and the woods (Bram, Liska, Gwenna: test of 0.1.590)
    private val all = listOf(garrick, morwen, rowena, aldric, thessa, osric, jorin, pim, borin, bram, liska, gwenna).associateBy { it.id }

    /** The doll for the person [npcId], or null when that one is still drawn the former way (Lyra in the temple and in the cave is one). */
    fun of(npcId: String): Folk? = all[npcId] ?: if (npcId.startsWith("lyra")) lyra else null

    /**
     * Who has idle loops of their own: Garrick (warming his hands at his fire, peering into the woods) and Rowena behind
     * her counter (wiping it, pouring a jug; D1.10: her sounds come with these movements); the others rest ([MapRest]).
     */
    private fun loops(f: Folk) = f.id == "garrick" || f.id == "rowena"

    /** Standing still or walking: [step] as in [MapFigure.STEPS]. */
    fun draw(f: Folk, slot: Int, step: Int): PixelImage =
        MapFigure.render(f.doll, f.outfit, MapFigure.rig(slot * 360.0 / MapFigure.YAWS, step, f.carry))

    /**
     * What one of the folk does while standing about (09.10.): [WARM] holds both hands out to the fire
     * and rubs them, [PEER] shades the eyes with the right hand and looks slowly from side to side.
     * Each is a short loop of [frames] key poses, [frameMs] apart; 239 (Chef 20.10.: "dass sie weich ineinander
     * übergehen"): [SUB] pictures between two key poses, [pictures] in all, so the hands and the head glide.
     */
    enum class Idle(val frames: Int, val frameMs: Long, private val cyclic: Boolean) {
        WARM(4, 260, true), PEER(5, 420, false), WIPE(4, 230, true), POUR(3, 380, false);
        /** The pictures of the loop: round for a cycle, from the first key pose to the last for a sweep or a pour. */
        val pictures: Int get() = if (cyclic) frames * SUB else (frames - 1) * SUB + 1
    }

    /** Pictures from one key pose of an [Idle] to the next (239). */
    const val SUB = 3

    /** The pose of [idle] at picture [i] of [Idle.pictures], the body turned to [yaw]. */
    fun idleRig(yaw: Double, idle: Idle, i: Int): HeroFigure.Rig {
        val base = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE)
        // where between the key poses: 1.0 is the second key pose
        val x = i.coerceIn(0, idle.pictures - 1) / SUB.toDouble()
        fun keys(vararg k: Double): Double { val a = x.toInt().coerceAtMost(k.size - 1); val b = (a + 1).coerceAtMost(k.size - 1); return k[a] + (k[b] - k[a]) * (x - a) }
        return when (idle) {
            Idle.WARM -> {
                // palms to the flames at belly height, the elbows bent; rubbing: the hands slide past each other
                val k = kotlin.math.sin(x * Math.PI / 2)
                base.copy(
                    lean = 0.1, headDown = 2.5, spread = 7.0,
                    rh = HeroFigure.V(7.0 + k * 1.2, 64.0 + k * 1.2, 19.0),
                    lh = HeroFigure.V(-7.0 + k * 1.2, 64.0 - k * 1.2, 19.0),
                )
            }
            Idle.PEER -> {
                // the right hand flat over the brow, the head sweeping slowly left and right
                val turn = keys(-28.0, -12.0, 4.0, 18.0, 30.0)
                base.copy(
                    headDown = -1.5, headTurn = turn, twist = turn * 0.2,
                    rh = HeroFigure.V(2.0, 95.0, 9.0), elbowUp = 0.7, elbowAt = HeroFigure.V(24.0, 86.0, 6.0),
                    lh = HeroFigure.V(-16.0, 54.0, 6.0),
                )
            }
            Idle.WIPE -> {
                // bent a little over the counter, the right hand with the cloth going round on the board, the left resting on it
                val cx = kotlin.math.sin(x * Math.PI / 2); val cz = kotlin.math.cos(x * Math.PI / 2)
                base.copy(
                    lean = 0.3, headDown = 4.5, spread = 7.0, twist = cx * 4.0,
                    rh = HeroFigure.V(8.0 + cx * 9.0, 68.0, 30.0 + cz * 7.0),
                    lh = HeroFigure.V(-13.0, 66.0, 26.0),
                )
            }
            Idle.POUR -> {
                // a jug in the left hand over the counter: lifted (0), tipped (1), poured out (2); the right hand holds the cup below
                val tilt = keys(0.0, 55.0, 95.0)
                base.copy(
                    lean = 0.12, headDown = 3.5, flask = 1.0, cork = 0.0, flaskTilt = tilt,
                    lh = HeroFigure.V(-3.0, 80.0 - tilt * 0.04, 28.0),
                    rh = HeroFigure.V(5.0, 70.0, 30.0),
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
        val jerkAt = 1_500L + (r.nextDouble() * 2_900).toLong()
        val jerks = r.nextDouble() < 0.55
        val t = ms - n * 6_000L
        return if (jerks && t in jerkAt until jerkAt + 450) Squat.SQUAT else Squat.DOZE
    }

    /**
     * A moment between two squatting poses (10.10., 3a: the poses had snapped into each other, which
     * looked stiff): [from] and [to] (null: standing) and how far along, [k] of [BLEND] steps.
     */
    data class SquatPose(val from: Squat?, val to: Squat?, val k: Int) {
        /** The pose this moment is nearest to (null: standing). */
        val main: Squat? get() = if (k * 2 >= BLEND) to else from
    }

    /**
     * Steps between two poses: 0 is [SquatPose.from], [BLEND] is [SquatPose.to]. 239 (Chef 20.10.: "sitzen/stehen sehr
     * unrund"): 4 steps let Garrick drop 10 cm a picture on his way down; with 8 it is 5, below the jump limit.
     */
    const val BLEND = 8

    private fun pose(a: Squat?, b: Squat?, t: Double) =
        SquatPose(a, b, Math.round(t.coerceIn(0.0, 1.0) * BLEND).toInt()).let { if (it.k == 0) SquatPose(a, a, 0) else if (it.k == BLEND) SquatPose(b, b, 0) else it }

    private fun ease(t: Double) = t.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }

    /**
     * Like [squatAt], but with the movement between the poses: he lowers himself onto his heels and
     * rises again over [SIT_MS], leans into the embers and back, stirs them in an even sweep, lets the
     * head sink slowly as he nods off, and when it jerks up it sinks back again slowly. Null while he
     * stands.
     */
    fun squatPoseAt(f: Folk, clockMs: Long, night: Boolean): SquatPose? {
        val n = Math.floorDiv(clockMs, SQUAT_BLOCK_MS)
        val t = clockMs - n * SQUAT_BLOCK_MS
        val r = java.util.Random(n * 7_000_003L + f.id.hashCode() * 31L + 5)
        // the same draws in the same order as squatAt, so both agree
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
        val left = end - t
        // he rises at [rise] (in ms since he sat down); a stirring that would run into it is left out, and
        // before rising from sleep he wakes and lifts his head, so no pose snaps into the rising
        val rise = end - start - SIT_MS
        val wake = rise - 1_200
        // what he does at this moment while down
        val down: SquatPose = run {
            for (k in 0 until stokes) {
                val a = stokeAt[k]; val len = stokeLen[k]
                if (a + len + LEAN_MS > rise) continue
                if (s in (a - LEAN_MS) until (a + len + LEAN_MS)) {
                    val u = s - a
                    return@run when {
                        u < 0 -> pose(Squat.SQUAT, Squat.STOKE_A, ease((u + LEAN_MS) / LEAN_MS.toDouble()))
                        u >= len -> pose(Squat.STOKE_A, Squat.SQUAT, ease((u - len) / LEAN_MS.toDouble()))
                        // the stick sweeps to and fro through the embers, about once in 0.7 s
                        else -> pose(Squat.STOKE_A, Squat.STOKE_B, 0.5 - 0.5 * kotlin.math.cos(u / 680.0 * 2 * Math.PI))
                    }
                }
            }
            if (night && s >= dozeAt && wake > dozeAt + 1_600) {
                if (s >= wake) pose(Squat.DOZE, Squat.SQUAT, ease((s - wake) / 600.0))
                else dozePose(f, s - dozeAt, quietFrom = wake - 1_600 - dozeAt)
            } else SquatPose(Squat.SQUAT, Squat.SQUAT, 0)
        }
        // lowering himself at the start, rising at the end
        if (s < SIT_MS) return pose(null, Squat.SQUAT, ease(s / SIT_MS.toDouble()))
        if (left < SIT_MS) return pose(down.main, null, ease(1 - left / SIT_MS.toDouble()))
        return down
    }

    /** Starting up from the fire when the hero comes (239): quicker than [SIT_MS], but never in one picture. */
    const val STARTLE_MS = 550L

    /**
     * What Garrick is seen doing at his fire, from [squatPoseAt] (239, Chef 20.10.: "Animationsübergang bei Garrick
     * sitzen/stehen sehr unrund"). Before, he stood up in one picture when the hero came near and dropped back into the
     * middle of his squat in one picture when the hero went. Now: [roused] (the hero near, a beast to ward off) makes
     * him rise from the pose he is in over [STARTLE_MS]; and having risen he stays up until that squat is over and only
     * sits down again with the next one, from standing. One per figure ([of]).
     */
    class SquatGate {
        private var shown: SquatPose? = null
        private var riseAt = Long.MIN_VALUE
        private var riseFrom: Squat? = null
        private var riseFrom0 = 0.0
        private var riseMs = 0L
        private var keptUp = Long.MIN_VALUE

        fun at(f: Folk, clockMs: Long, night: Boolean, roused: Boolean): SquatPose? {
            val planned = squatPoseAt(f, clockMs, night)
            val block = Math.floorDiv(clockMs, SQUAT_BLOCK_MS)
            // one squat to a block: once it is over, the next may come; while roused, he will not drop back into this one
            if (planned == null) keptUp = Long.MIN_VALUE
            if (roused && planned != null) keptUp = block
            var rising = riseFrom != null && clockMs >= riseAt && clockMs - riseAt < riseMs
            val now = shown
            if (roused && !rising && now != null) {
                // rise from just where he is: down, on the way down, or already on the way up
                val (from, t0) = when {
                    now.to == null -> now.from to now.k / BLEND.toDouble()
                    now.from == null -> now.to to 1 - now.k / BLEND.toDouble()
                    else -> now.main to 0.0
                }
                riseFrom = from; riseFrom0 = t0; riseAt = clockMs; riseMs = (STARTLE_MS * (1 - t0)).toLong()
                rising = from != null && riseMs > 0
            }
            val out = when {
                rising -> pose(riseFrom, null, riseFrom0 + (1 - riseFrom0) * ease((clockMs - riseAt) / riseMs.toDouble()))
                roused || keptUp == block -> null
                else -> planned
            }
            if (!rising) riseFrom = null
            shown = out?.takeUnless { it.from == null && it.to == null }
            return shown
        }

        companion object {
            private val all = java.util.concurrent.ConcurrentHashMap<String, SquatGate>()
            fun of(id: String): SquatGate = all.getOrPut(id) { SquatGate() }
        }
    }

    /** Lowering onto the heels and rising again take this long. */
    const val SIT_MS = 900L
    private const val LEAN_MS = 350L

    /** Nodding off [ms] after falling asleep: the head sinks over 1.6 s; when it jerks up it sinks back over a second. */
    private fun dozePose(f: Folk, ms: Long, quietFrom: Long = Long.MAX_VALUE): SquatPose {
        if (ms < 1_600) return pose(Squat.SQUAT, Squat.DOZE, ease(ms / 1_600.0))
        val n = Math.floorDiv(ms, 6_000L)
        val r = java.util.Random(n * 1_000_033L + f.id.hashCode())
        val jerkAt = 1_500L + (r.nextDouble() * 2_900).toLong()
        val jerks = r.nextDouble() < 0.55
        val t = ms - n * 6_000L
        // no jerk that would still be going on when he wakes
        if (!jerks || t < jerkAt || n * 6_000L + jerkAt >= quietFrom) return SquatPose(Squat.DOZE, Squat.DOZE, 0)
        val u = t - jerkAt
        return when {
            u < 180 -> pose(Squat.DOZE, Squat.SQUAT, u / 180.0)                          // a jerk: up fast
            u < 450 -> SquatPose(Squat.SQUAT, Squat.SQUAT, 0)
            else -> pose(Squat.SQUAT, Squat.DOZE, ease((u - 450) / 1_100.0))            // and down slowly
        }
    }

    /** The rig of a [SquatPose]: the two poses mixed. */
    fun squatRig(yaw: Double, p: SquatPose): HeroFigure.Rig {
        val stand = MapFigure.rig(yaw, 0, MapFigure.Carry.FREE)
        val a = p.from?.let { squatRig(yaw, it) } ?: stand
        if (p.k == 0) return a
        val b = p.to?.let { squatRig(yaw, it) } ?: stand
        return mixRig(a, b, p.k / BLEND.toDouble())
    }

    private fun mixRig(a: HeroFigure.Rig, b: HeroFigure.Rig, t: Double): HeroFigure.Rig {
        fun m(x: Double, y: Double) = x + (y - x) * t
        fun v(x: HeroFigure.V, y: HeroFigure.V) = HeroFigure.V(m(x.r, y.r), m(x.u, y.u), m(x.f, y.f))
        // the stick is in the hand for the whole stirring; it is picked up and laid down mid-way
        val near = if (t < 0.5) a else b
        return b.copy(
            lean = m(a.lean, b.lean), crouch = m(a.crouch, b.crouch), stride = m(a.stride, b.stride), spread = m(a.spread, b.spread),
            headDown = m(a.headDown, b.headDown), rh = v(a.rh, b.rh), lh = v(a.lh, b.lh), bodyY = m(a.bodyY, b.bodyY),
            weapon = if (a.torch > 0 && b.torch > 0) v(a.weapon, b.weapon) else near.weapon,
            torch = near.torch, flicker = near.flicker, aim = near.aim, grip = near.grip,
        )
    }

    /** The picture of [f] at a [SquatPose] facing [slot]: drawn in the background, until then the nearer pose's picture if that is ready. */
    fun squatFrame(f: Folk, slot: Int, p: SquatPose): PixelImage? {
        if (p.k == 0) return p.from?.let { squatFrame(f, slot, it) } ?: frame(f, slot, 0)
        return MapRest.picture("squat|${f.id}|$slot|${p.from}>${p.to}|${p.k}") { MapFigure.render(f.doll, f.outfit, squatRig(slot * 360.0 / MapFigure.YAWS, p)) }
            ?: (p.main?.let { squatFrame(f, slot, it) } ?: frame(f, slot, 0))
    }


    /** Draws ahead the squatting pictures of [f] facing its fire at [homeSlot]. */
    fun prepareSquat(f: Folk, homeSlot: Int) {
        for (p in Squat.entries) squatFrame(f, homeSlot, p)
        val pairs = listOf(null to Squat.SQUAT, Squat.SQUAT to Squat.STOKE_A, Squat.STOKE_A to Squat.STOKE_B, Squat.STOKE_A to Squat.SQUAT,
            Squat.SQUAT to Squat.DOZE, Squat.DOZE to Squat.SQUAT, Squat.SQUAT to null, Squat.DOZE to null, Squat.STOKE_A to null, Squat.STOKE_B to null)
        for ((a, b) in pairs) for (k in 1 until BLEND) squatFrame(f, homeSlot, SquatPose(a, b, k))
    }

    /** How near (in tiles each way) the hero must be for the folk to look at it (5la.3, 13.10.: 3, was 4). */
    const val WATCH_TILES = 3.0

    /** After the hero has stood this long on one spot, the folk lose interest and go back to what they did (5la.3: 10 s, was 20). */
    const val BORED_MS = 10_000L

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

    /**
     * What the folk do at [clockMs]: null while standing still, else the loop, its picture, which way the body turns, and
     * [level] of [IDLE_LEVELS] how far from standing into the loop (239: going in and out over [IDLE_EASE_MS]).
     */
    class Doing(val idle: Idle, val frame: Int, val slotOffset: Int, val level: Int = IDLE_LEVELS)

    /** Going from standing into a loop and out again (239: the hands had jumped to the fire in one picture). */
    const val IDLE_EASE_MS = 450L
    const val IDLE_LEVELS = 6

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
        val a = act(f, n) ?: return null
        val t = clockMs - n * BLOCK_MS - a.start
        if (t < 0 || t >= a.length) return null
        // the loop runs between going in and coming out; meanwhile it holds its first and its last picture
        val loopMs = a.length - 2 * IDLE_EASE_MS
        val u = (t - IDLE_EASE_MS).coerceIn(0, loopMs)
        val each = a.idle.frameMs * a.pace / SUB
        val step = (u / each).toInt()
        val pics = a.idle.pictures
        val frame = when (a.idle) {
            // peering sweeps there and back
            Idle.PEER -> { val m = 2 * (pics - 1); val q = Math.floorMod(step, m); if (q < pics) q else m - q }
            // pouring: the jug lifted, tipped and held while it runs, then lowered again
            Idle.POUR -> { val back = ((loopMs - u) / each).toInt(); minOf(step, back, pics - 1) }
            // warming and wiping loop
            else -> Math.floorMod(step, pics)
        }
        val edge = minOf(t, a.length - 1 - t)
        val level = if (edge >= IDLE_EASE_MS) IDLE_LEVELS else (ease(edge / IDLE_EASE_MS.toDouble()) * IDLE_LEVELS).toInt().coerceIn(1, IDLE_LEVELS)
        return Doing(a.idle, frame, if (a.idle == Idle.PEER) a.off else 0, level)
    }

    /** One loop in block [n]: it starts [start] ms into the block and lasts [length] ms. */
    private class Act(val idle: Idle, val start: Long, val length: Long, val pace: Double, val off: Int)

    /** What [f] does in block [n] of [BLOCK_MS], or null for nothing: fixed by chance, so picture and sound agree. */
    private fun act(f: Folk, n: Long): Act? {
        if (!loops(f)) return null
        val r = java.util.Random(n * 1_000_003L + f.id.hashCode())
        if (r.nextDouble() < 0.2) return null
        val start = 2_000L + (r.nextDouble() * 7_000).toLong()
        if (f.id == "rowena") {
            // as long as the sound of it (wiping about 3 s, pouring about 4 s), so neither runs on without the other
            val pour = r.nextDouble() < 0.4
            // with going in and out (239) on top, so the loop itself still lasts as long as its sound
            return if (pour) Act(Idle.POUR, start, POUR_MS + 2 * IDLE_EASE_MS, 1.0, 0) else Act(Idle.WIPE, start, WIPE_MS + 2 * IDLE_EASE_MS, 0.85 + r.nextDouble() * 0.3, 0)
        }
        val length = 3_500L + (r.nextDouble() * 3_000).toLong()
        val idle = if (r.nextDouble() < 0.35) Idle.PEER else Idle.WARM
        val pace = 0.8 + r.nextDouble() * 0.45
        val off = PEER_OFFSETS[r.nextInt(PEER_OFFSETS.size)]
        return Act(idle, start, length, pace, off)
    }

    const val WIPE_MS = 3_000L
    const val POUR_MS = 4_600L
    /** The pour is heard from when the jug is tipped, after it is lifted. */
    const val POUR_SOUND_MS = 380L

    /**
     * The sounds [f]'s own movements make between [fromMs] (excluded) and [toMs] on the clock (D1.10): Rowena's cloth
     * as she starts wiping and her jug as she tips it; Borin's flask set down on the table after a drink and his chair
     * as he turns to look round.
     */
    fun sounds(f: Folk, fromMs: Long, toMs: Long): List<de.bornim.core.audio.Sound> {
        if (toMs <= fromMs) return emptyList()
        val out = mutableListOf<de.bornim.core.audio.Sound>()
        fun hit(at: Long) = at > fromMs && at <= toMs
        if (loops(f)) for (n in Math.floorDiv(fromMs, BLOCK_MS)..Math.floorDiv(toMs, BLOCK_MS)) {
            val a = act(f, n) ?: continue
            // the hands are at the counter once she has gone into the loop (239)
            val at = n * BLOCK_MS + a.start + IDLE_EASE_MS
            when (a.idle) {
                Idle.WIPE -> if (hit(at)) out += de.bornim.core.audio.Sound.WIPE
                Idle.POUR -> if (hit(at + POUR_SOUND_MS)) out += de.bornim.core.audio.Sound.POUR
                else -> {}
            }
        }
        if (sits(f)) for (n in Math.floorDiv(fromMs, SEAT_BLOCK_MS)..Math.floorDiv(toMs, SEAT_BLOCK_MS)) {
            for (s in seatActs(f, n)) when (s.what) {
                Seat.DRINK -> if (hit(n * SEAT_BLOCK_MS + s.end)) out += de.bornim.core.audio.Sound.CUP
                Seat.LOOK -> if (hit(n * SEAT_BLOCK_MS + s.at)) out += de.bornim.core.audio.Sound.CHAIR
                else -> {}
            }
        }
        return out
    }

    const val BLOCK_MS = 16_000L

    /** [f] standing in [rest], breathing in or out: drawn in the background when first wanted, null until then. */
    fun restFrame(f: Folk, slot: Int, rest: MapRest.Rest, breath: Int, level: Int = MapRest.LEVELS): PixelImage? {
        if ((rest == MapRest.Rest.NEUTRAL || level <= 0) && breath == 0) return frame(f, slot, 0)
        MapRest.picture(restKey(f, slot, rest, breath, level)) { drawRest(f, slot, rest, breath, level) }?.let { return it }
        // not drawn yet (test of 0.1.670: the figure fell back to plain standing for a moment and twitched):
        // the nearest step of the same stance that is ready, the other breath before plain standing
        for (d in 1..MapRest.LEVELS) for (lv in listOf(level - d, level + d)) {
            if (lv !in 1..MapRest.LEVELS) continue
            MapRest.cached(restKey(f, slot, rest, breath, lv))?.let { return it }
        }
        return MapRest.cached(restKey(f, slot, rest, 1 - breath, level))
    }

    private fun restKey(f: Folk, slot: Int, rest: MapRest.Rest, breath: Int, level: Int) = "folk|${f.id}|$slot|$rest|$breath|$level"

    /** Asks for every step of [rest] in both breaths ahead of time, so going into it has all its pictures (55.1b). */
    fun prepareRest(f: Folk, slot: Int, rest: MapRest.Rest) {
        for (b in 0..1) for (lv in 1..MapRest.LEVELS) MapRest.picture(restKey(f, slot, rest, b, lv)) { drawRest(f, slot, rest, b, lv) }
    }

    /** One resting picture of [f], drawn now. */
    fun drawRest(f: Folk, slot: Int, rest: MapRest.Rest, breath: Int, level: Int = MapRest.LEVELS): PixelImage =
        MapFigure.render(f.doll, f.outfit, MapRest.rig(MapFigure.rig(slot * 360.0 / MapFigure.YAWS, 0, f.carry), rest, breath, level))

    /** The idle picture, or null while it is not drawn yet; below [IDLE_LEVELS] on the way between standing and the loop (239). */
    fun idleFrame(f: Folk, slot: Int, idle: Idle, i: Int, level: Int = IDLE_LEVELS): PixelImage? {
        val full = synchronized(cache) { cache["${f.id}|$slot|$idle|$i"] }
        if (level >= IDLE_LEVELS) return full
        return MapRest.picture("idlein|${f.id}|$slot|$idle|$i|$level") { MapFigure.render(f.doll, f.outfit, idleInRig(f, slot * 360.0 / MapFigure.YAWS, idle, i, level)) }
            ?: if (level * 2 >= IDLE_LEVELS) full else frame(f, slot, 0)
    }

    /** Between standing and picture [i] of [idle]: [level] of [IDLE_LEVELS]. */
    fun idleInRig(f: Folk, yaw: Double, idle: Idle, i: Int, level: Int): HeroFigure.Rig {
        val loop = idleRig(yaw, idle, i)
        // Rowena's jug is in her hand from the moment she reaches for it
        return MapFigure.rig(yaw, 0, f.carry).lerp(loop, level.coerceIn(0, IDLE_LEVELS) / IDLE_LEVELS.toDouble()).copy(flask = loop.flask, cork = loop.cork)
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

    /** Whether everyone on [map] is drawn standing, in every direction (24.1). */
    fun standing(map: de.bornim.core.MapDef): Boolean = map.npcs.all { npc ->
        val f = of(npc.id) ?: return@all true
        (0 until MapFigure.YAWS).all { s -> frame(f, s, 0) != null }
    }

    /** Starts drawing the folk standing on [map] in the background, each facing its own way first, then their idle loops; those at a safe place also their torch. */
    fun prepareFor(map: de.bornim.core.MapDef) {
        shown = map
        for (npc in map.npcs) of(npc.id)?.let {
            val home = MapFigure.slot(MapFigure.yawOf(npc.facing))
            prepare(it, home)
            if (map.safeZones.any { z -> z.x == npc.x && z.y == npc.y }) prepareWard(it, home)
            if (squats(it)) prepareSquat(it, home)
            if (sits(it)) prepareSeat(it, home)
        }
    }

    /** Draws the idle loops of [f] about its home direction [homeSlot] in the background (after its walk). */
    private fun prepareIdle(f: Folk, homeSlot: Int) {
        if (!loops(f)) return
        val n = MapFigure.YAWS
        val jobs = buildList {
            if (f.id == "rowena") {
                for (idle in listOf(Idle.WIPE, Idle.POUR)) for (i in 0 until idle.pictures) add(Triple(homeSlot, idle, i))
            } else {
                for (i in 0 until Idle.WARM.pictures) add(Triple(homeSlot, Idle.WARM, i))
                for (o in PEER_OFFSETS) for (i in 0 until Idle.PEER.pictures) add(Triple(Math.floorMod(homeSlot + o, n), Idle.PEER, i))
            }
        }
        for ((s, idle, i) in jobs) {
            val k = "${f.id}|$s|$idle|$i"
            if (synchronized(cache) { k in cache }) continue
            val img = drawIdle(f, s, idle, i)
            synchronized(cache) { cache[k] = img }
        }
        // going into each loop and coming out of a pour start and end at its first picture (239)
        for ((s, idle, i) in jobs) if (i == 0) for (lv in 1 until IDLE_LEVELS) idleFrame(f, s, idle, 0, lv)
    }

    /** Draws every picture of [f] in the background, the directions nearest to [nearSlot] first. */
    fun prepare(f: Folk, nearSlot: Int = 0) {
        synchronized(cache) { if (!preparing.add(f.id)) return }
        val n = MapFigure.YAWS
        val order = (0 until n).sortedBy { minOf(Math.floorMod(it - nearSlot, n), Math.floorMod(nearSlot - it, n)) }
        fun steps(sts: List<Int>) {
            for (st in sts) for (s in order) {
                val k = "${f.id}|$s|$st"
                if (synchronized(cache) { k in cache }) continue
                val img = draw(f, s, st)
                synchronized(cache) { cache[k] = img }
            }
        }
        // 30.2: everyone standing all round first, then everyone's walk, then the idle loops; on two threads in all,
        // not one each (twelve at once after a change of map took too much memory)
        workers.execute(Job(0) { steps(listOf(0)) })
        workers.execute(Job(1) { steps(listOf(1, 2, 3)) })
        workers.execute(Job(2) { prepareIdle(f, nearSlot) })
    }

    /** One part of drawing someone, the lower [phase] first, in order of asking within a phase. */
    private class Job(val phase: Int, val body: () -> Unit) : Runnable, Comparable<Job> {
        val seq = order.incrementAndGet()
        override fun run() { de.bornim.core.Guard.run("Leute") { body() } }
        override fun compareTo(other: Job) = compareValuesBy(this, other, { it.phase }, { it.seq })
        companion object { val order = java.util.concurrent.atomic.AtomicLong() }
    }

    private val workers = java.util.concurrent.ThreadPoolExecutor(2, 2, 0L, java.util.concurrent.TimeUnit.MILLISECONDS,
        java.util.concurrent.PriorityBlockingQueue<Runnable>()) { r -> Thread({ SdfRender.quiet.set(true); r.run() }, "map-folk").also { it.isDaemon = true; it.priority = Thread.MIN_PRIORITY + 1 } }

    /** 30.2: lets go of the pictures of everyone not in [keep] (memory short); they are drawn again when met. */
    fun keepOnly(keep: Set<String>) = synchronized(cache) {
        cache.keys.removeAll { it.substringBefore('|') !in keep }
        preparing.retainAll(keep)
    }

    /** The map whose folk were asked for last. */
    @Volatile var shown: de.bornim.core.MapDef? = null
        private set

    /** The folk standing on [map], by id. */
    fun idsOn(map: de.bornim.core.MapDef): Set<String> = map.npcs.mapNotNull { of(it.id)?.id }.toSet()

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
