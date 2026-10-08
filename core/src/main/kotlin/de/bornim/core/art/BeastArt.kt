package de.bornim.core.art

import de.bornim.core.MonsterLook
import de.bornim.core.art.Beast.Rig
import de.bornim.core.art.HeroFigure.V
import kotlin.math.PI
import kotlin.math.cos

/**
 * Animals built in the round ([Beast]) in battle: wolves, the wild boar and the giant rat, turned towards the hero,
 * teeth or tusks bared, every act in at least three variants. Size and coat come from the foe's look; Grimfang (the
 * dire wolf) is half as big again, black and scarred. A frame is [W] × [H] with the feet at ([ANCHOR_X], [GROUND]).
 */
object BeastArt {
    // wide towards the hero on the left for the bite and the leap, high enough for a dire wolf in mid-leap
    const val W = 280
    const val H = 200
    const val ANCHOR_X = 160.0
    const val GROUND = 166.0
    /** Art pixels per centimetre, as for the foes on the doll. */
    const val PX = 0.66

    /** Animals drawn this way. */
    val KINDS = setOf("wolf", "dire_wolf", "boar", "giant_rat")

    fun kindOf(id: String): Beast.Kind = when (id) { "boar" -> Beast.Kind.BOAR; "giant_rat" -> Beast.Kind.RAT; else -> Beast.Kind.WOLF }

    /** How big this one is: a wolf 92 to 108 % of the usual, Grimfang half as big again; boars and rats vary as much. */
    fun size(id: String, look: MonsterLook): Double = when (id) {
        "dire_wolf" -> 1.45
        "boar" -> 0.88 + 0.22 * (look.seed.mod(7) / 6.0)
        // a giant rat as big as a dog, so it reads at battle size: 40 to 48 cm at the shoulder
        "giant_rat" -> 1.4 + 0.3 * (look.seed.mod(7) / 6.0)
        else -> 0.92 + 0.16 * (look.seed.mod(7) / 6.0)
    }

    // boars: near-black, grizzled with scars, rust-brown with a torn ear; all with small red eyes
    private val BOAR_COATS = listOf(
        WolfArt.Coat(0x3A302A, 0x141010, 0x2E2622, 0xD82A18),
        WolfArt.Coat(0x5E5248, 0x221C18, 0x4A3E36, 0xE84A1A, scar = true),
        WolfArt.Coat(0x5A3A26, 0x1E1410, 0x463024, 0xC81E14, scar = true, tornEar = true))
    // rats: brown, grey and mangy, black with a torn ear; the eyes glowing red
    private val RAT_COATS = listOf(
        WolfArt.Coat(0x4A3C34, 0x2A201C, 0x6A5C50, 0xE01E14),
        WolfArt.Coat(0x55504C, 0x2A2826, 0x7A726A, 0xF03A20, scar = true),
        WolfArt.Coat(0x2A2624, 0x121010, 0x4A4240, 0xF04A28, tornEar = true))

    fun coat(id: String, look: MonsterLook): WolfArt.Coat = when (kindOf(id)) {
        Beast.Kind.WOLF -> WolfArt.coatFor(look, id == "dire_wolf")
        Beast.Kind.BOAR -> BOAR_COATS[look.pick(3, 10)].let { if (look.shiny) it.shifted(0.55) else it }
        Beast.Kind.RAT -> RAT_COATS[look.pick(3, 10)].let { if (look.shiny) it.shifted(0.55) else it }
    }

    fun beast(id: String, look: MonsterLook) = Beast(size(id, look), coat(id, look), kindOf(id))

    // ---------------------------------------------------------------- key poses

    /** Facing the hero, down at the left of the picture. */
    private const val YAW = -60.0

    // the guard: head low, lips drawn off the fangs, ears half back
    val STAND = Rig(neck = -8.0, nod = 4.0, tail = -0.1, snarl = 0.6, mouth = 0.1, ears = -0.3, yaw = YAW)
    private val BREATHE = STAND.copy(breath = 1.0, crouch = 0.6, mouth = 0.2, tail = 0.0)
    // gathering for a bite: down on its haunches, head lower still, all teeth
    private val CROUCH = STAND.copy(crouch = 7.0, pitch = 4.0, neck = -18.0, nod = 8.0, mouth = 0.35, snarl = 1.0, ears = -1.0, tail = -0.3, hl = V(0.0, 0.0, 4.0), hr = V(0.0, 0.0, 6.0))
    private val BITE = STAND.copy(fwd = 22.0, crouch = 2.0, pitch = 6.0, neck = -8.0, nod = -6.0, mouth = 0.95, snarl = 1.0, ears = -1.0, tail = 0.2,
        fl = V(0.0, 0.0, 14.0), fr = V(0.0, 4.0, 30.0), hl = V(0.0, 0.0, -6.0), hr = V(0.0, 0.0, 8.0))
    private val SNAP = BITE.copy(fwd = 26.0, mouth = 0.08, nod = -2.0)
    // the leap: down deep, then flying at the hero with the forelegs out, and landing on it
    private val COIL = CROUCH.copy(crouch = 12.0, pitch = 8.0, neck = -12.0, fl = V(0.0, 0.0, -4.0), fr = V(0.0, 0.0, -2.0), hl = V(0.0, 0.0, 10.0), hr = V(0.0, 0.0, 12.0))
    private val LEAP = STAND.copy(fwd = 40.0, crouch = -38.0, pitch = -10.0, neck = 0.0, nod = -4.0, mouth = 0.95, snarl = 1.0, ears = -1.0, tail = 0.5,
        fl = V(0.0, 74.0, 52.0), fr = V(0.0, 80.0, 46.0), hl = V(0.0, 56.0, -42.0), hr = V(0.0, 62.0, -36.0))
    private val LAND = STAND.copy(fwd = 58.0, crouch = -6.0, pitch = -8.0, neck = -4.0, nod = 2.0, mouth = 0.1, snarl = 1.0, ears = -1.0, tail = 0.4,
        fl = V(0.0, 24.0, 40.0), fr = V(0.0, 30.0, 36.0), hl = V(0.0, 0.0, 10.0), hr = V(0.0, 0.0, 16.0))
    // low at the legs: the head down by the ground, then a tearing wrench of the head
    private val LOW = CROUCH.copy(crouch = 12.0, pitch = 10.0, neck = -32.0, nod = 16.0, mouth = 0.5)
    private val LOW_BITE = LOW.copy(fwd = 24.0, crouch = 9.0, neck = -28.0, nod = 18.0, mouth = 0.95, fl = V(0.0, 0.0, 18.0), fr = V(0.0, 0.0, 26.0))
    private val LOW_TEAR = LOW_BITE.copy(fwd = 22.0, mouth = 0.1, turn = 24.0, tailSwing = -15.0)

    /** A sequence with the frame at which the jaws close on the hero (or -1). */
    class Seq(val rigs: List<Rig>, val strike: Int = -1)

    /** In-between frames from one key to the next, eased in and out. */
    fun tween(vararg keys: Pair<Rig, Int>): List<Rig> {
        val out = mutableListOf<Rig>()
        for (i in 0 until keys.size - 1) {
            val (a, n) = keys[i]
            val b = keys[i + 1].first
            for (k in 0 until n) out += a.lerp(b, (1 - cos(k / n.toDouble() * PI)) / 2)
        }
        out += keys.last().first
        return out
    }

    private val ATTACKS = listOf(
        Seq(tween(STAND to 3, CROUCH to 4, BITE to 2, SNAP to 5, STAND to 1), 9),
        Seq(tween(STAND to 3, COIL to 4, LEAP to 3, LAND to 5, STAND to 1), 10),
        Seq(tween(STAND to 3, LOW to 4, LOW_BITE to 2, LOW_TEAR to 5, STAND to 1), 9),
    )

    // struck: knocked back with a yelp, wrenched round, or the legs buckling under it
    private val HURTS = listOf(
        STAND.copy(fwd = -18.0, crouch = 4.0, pitch = -12.0, neck = 14.0, nod = -18.0, mouth = 0.75, snarl = 0.3, eyes = 0.0, ears = -1.0, tail = -0.9, fl = V(0.0, 10.0, -8.0)),
        STAND.copy(fwd = -12.0, side = -16.0, crouch = 7.0, pitch = -6.0, turn = 52.0, neck = 2.0, mouth = 0.65, eyes = 0.0, ears = -1.0, tail = -0.6, tailSwing = 32.0, fr = V(0.0, 12.0, 0.0)),
        STAND.copy(fwd = -6.0, crouch = 22.0, pitch = -10.0, neck = -26.0, nod = 12.0, mouth = 0.55, eyes = 0.0, ears = -1.0, tail = -1.0, hl = V(0.0, 0.0, 16.0), hr = V(0.0, 0.0, 18.0)),
    ).map { Seq(tween(STAND to 2, it to 3, it to 2, STAND to 2)) }

    // a blow avoided: a bound aside and back, a duck under it, a spring back
    private val DODGES = listOf(
        STAND.copy(side = -34.0, fwd = -18.0, crouch = -9.0, turn = -25.0, ears = -1.0, snarl = 1.0, mouth = 0.4, fl = V(0.0, 14.0, 0.0), fr = V(0.0, 18.0, 0.0)),
        STAND.copy(crouch = 22.0, pitch = 8.0, neck = -36.0, nod = 14.0, ears = -1.0, snarl = 1.0, mouth = 0.3, tail = -0.7),
        STAND.copy(fwd = -38.0, crouch = -12.0, pitch = -14.0, neck = 8.0, ears = -1.0, snarl = 1.0, mouth = 0.5, fl = V(0.0, 22.0, -6.0), fr = V(0.0, 26.0, -4.0)),
    ).map { Seq(tween(STAND to 2, it to 3, it to 2, STAND to 2)) }

    // falling: over onto its side, the forelegs giving way first, or rearing up and toppling back
    private val DEATHS = listOf(
        Seq(tween(STAND to 1, HURTS[0].rigs[4] to 3, STAND.copy(crouch = 14.0, neck = -16.0, mouth = 0.6, eyes = 0.0, ears = -1.0, tail = -1.0, fallS = 20.0) to 4,
            STAND.copy(crouch = 4.0, neck = -12.0, nod = -10.0, mouth = 0.45, snarl = 0.4, eyes = 0.0, ears = -1.0, tail = -0.6, fallS = 84.0) to 6,
            STAND.copy(crouch = 4.0, neck = -14.0, nod = -12.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, ears = -1.0, tail = -0.6, fallS = 88.0) to 1)),
        Seq(tween(STAND to 1, STAND.copy(fwd = 8.0, crouch = 10.0, pitch = 18.0, neck = -26.0, nod = 14.0, mouth = 0.6, eyes = 0.0, ears = -1.0) to 3,
            STAND.copy(fwd = 10.0, crouch = 22.0, pitch = 22.0, neck = -30.0, nod = 16.0, mouth = 0.5, eyes = 0.0, ears = -1.0, tail = -1.0, fallS = -25.0) to 4,
            STAND.copy(fwd = 8.0, crouch = 6.0, neck = -14.0, nod = -8.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, ears = -1.0, tail = -0.5, fallS = -84.0) to 6,
            STAND.copy(fwd = 8.0, crouch = 6.0, neck = -16.0, nod = -10.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, ears = -1.0, tail = -0.5, fallS = -88.0) to 1)),
        Seq(tween(STAND to 1, STAND.copy(fwd = -10.0, crouch = -4.0, pitch = -24.0, neck = 20.0, nod = -24.0, mouth = 0.9, snarl = 0.5, eyes = 0.0, ears = -1.0, fl = V(0.0, 26.0, -4.0), fr = V(0.0, 30.0, 0.0)) to 3,
            STAND.copy(fwd = -16.0, crouch = 6.0, pitch = -10.0, neck = 10.0, nod = -14.0, mouth = 0.6, eyes = 0.0, ears = -1.0, tail = -0.8, fallS = 40.0) to 4,
            STAND.copy(fwd = -18.0, crouch = 4.0, neck = 2.0, nod = -14.0, mouth = 0.5, snarl = 0.3, eyes = 0.0, ears = -1.0, tail = -0.4, fallS = 86.0) to 6,
            STAND.copy(fwd = -18.0, crouch = 4.0, neck = 0.0, nod = -14.0, mouth = 0.5, snarl = 0.3, eyes = 0.0, ears = -1.0, tail = -0.4, fallS = 89.0) to 1)),
    )

    // the howl: the head thrown back, the jaws parted, the eyes half shut
    private val HOWL = STAND.copy(crouch = 2.0, pitch = -4.0, neck = 34.0, nod = -40.0, mouth = 0.6, snarl = 0.0, eyes = 0.3, ears = 0.6, tail = -0.3)

    const val IDLE_FRAMES = 16
    private val IDLE = Seq(List(IDLE_FRAMES) { STAND.lerp(BREATHE, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) })
    private val HOWL_SEQ = Seq(tween(STAND to 4, HOWL to 6, STAND to 1))

    /** Every act of one kind of animal, three variants of each but the rest and the howl. */
    private class Moves(val idle: Seq, val howl: Seq, val attacks: List<Seq>, val hurts: List<Seq>, val dodges: List<Seq>, val deaths: List<Seq>)

    private val WOLF_MOVES = Moves(IDLE, HOWL_SEQ, ATTACKS, HURTS, DODGES, DEATHS)

    /**
     * Being struck, dodging and falling, as the wolf's but from another [stand], every step and leap scaled by [s]
     * (a heavy boar moves less far, a rat a fraction of it).
     */
    private fun reactions(stand: Rig, s: Double): Triple<List<Seq>, List<Seq>, List<Seq>> {
        fun c(fwd: Double = 0.0, side: Double = 0.0, crouch: Double = 0.0, pitch: Double = 0.0, turn: Double = 0.0, neck: Double = 0.0, nod: Double = 0.0,
              mouth: Double = stand.mouth, snarl: Double = stand.snarl, eyes: Double = 1.0, ears: Double = -1.0, tail: Double = stand.tail, tailSwing: Double = 0.0,
              fl: V = V(0.0, 0.0, 0.0), fr: V = V(0.0, 0.0, 0.0), hl: V = V(0.0, 0.0, 0.0), hr: V = V(0.0, 0.0, 0.0), fallS: Double = 0.0) =
            stand.copy(fwd = fwd * s, side = side * s, crouch = crouch * s, pitch = pitch, turn = turn, neck = stand.neck + neck, nod = stand.nod + nod, mouth = mouth, snarl = snarl,
                eyes = eyes, ears = ears, tail = tail, tailSwing = tailSwing, fl = V(fl.r * s, fl.u * s, fl.f * s), fr = V(fr.r * s, fr.u * s, fr.f * s),
                hl = V(hl.r * s, hl.u * s, hl.f * s), hr = V(hr.r * s, hr.u * s, hr.f * s), fallS = fallS)
        val hurt = listOf(
            c(fwd = -18.0, crouch = 4.0, pitch = -12.0, neck = 18.0, nod = -22.0, mouth = 0.75, snarl = 0.3, eyes = 0.0, tail = -0.9, fl = V(0.0, 10.0, -8.0)),
            c(fwd = -12.0, side = -16.0, crouch = 7.0, pitch = -6.0, turn = 52.0, neck = 8.0, mouth = 0.65, eyes = 0.0, tail = -0.6, tailSwing = 32.0, fr = V(0.0, 12.0, 0.0)),
            c(fwd = -6.0, crouch = 22.0, pitch = -10.0, neck = -18.0, nod = 8.0, mouth = 0.55, eyes = 0.0, tail = -1.0, hl = V(0.0, 0.0, 16.0), hr = V(0.0, 0.0, 18.0)),
        )
        val hurts = hurt.map { Seq(tween(stand to 2, it to 3, it to 2, stand to 2)) }
        val dodges = listOf(
            c(side = -34.0, fwd = -18.0, crouch = -9.0, turn = -25.0, snarl = 1.0, mouth = 0.4, fl = V(0.0, 14.0, 0.0), fr = V(0.0, 18.0, 0.0)),
            c(crouch = 22.0, pitch = 8.0, neck = -28.0, nod = 10.0, snarl = 1.0, mouth = 0.3, tail = -0.7),
            c(fwd = -38.0, crouch = -12.0, pitch = -14.0, neck = 14.0, snarl = 1.0, mouth = 0.5, fl = V(0.0, 22.0, -6.0), fr = V(0.0, 26.0, -4.0)),
        ).map { Seq(tween(stand to 2, it to 3, it to 2, stand to 2)) }
        val deaths = listOf(
            Seq(tween(stand to 1, hurt[0] to 3, c(crouch = 14.0, neck = -10.0, mouth = 0.6, eyes = 0.0, tail = -1.0, fallS = 20.0) to 4,
                c(crouch = 4.0, neck = -6.0, nod = -14.0, mouth = 0.45, snarl = 0.4, eyes = 0.0, tail = -0.6, fallS = 84.0) to 6,
                c(crouch = 4.0, neck = -8.0, nod = -16.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, tail = -0.6, fallS = 88.0) to 1)),
            Seq(tween(stand to 1, c(fwd = 8.0, crouch = 10.0, pitch = 18.0, neck = -20.0, nod = 10.0, mouth = 0.6, eyes = 0.0) to 3,
                c(fwd = 10.0, crouch = 22.0, pitch = 22.0, neck = -24.0, nod = 12.0, mouth = 0.5, eyes = 0.0, tail = -1.0, fallS = -25.0) to 4,
                c(fwd = 8.0, crouch = 6.0, neck = -8.0, nod = -12.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, tail = -0.5, fallS = -84.0) to 6,
                c(fwd = 8.0, crouch = 6.0, neck = -10.0, nod = -14.0, mouth = 0.4, snarl = 0.4, eyes = 0.0, tail = -0.5, fallS = -88.0) to 1)),
            Seq(tween(stand to 1, c(fwd = -10.0, crouch = -4.0, pitch = -24.0, neck = 26.0, nod = -28.0, mouth = 0.9, snarl = 0.5, eyes = 0.0, fl = V(0.0, 26.0, -4.0), fr = V(0.0, 30.0, 0.0)) to 3,
                c(fwd = -16.0, crouch = 6.0, pitch = -10.0, neck = 16.0, nod = -18.0, mouth = 0.6, eyes = 0.0, tail = -0.8, fallS = 40.0) to 4,
                c(fwd = -18.0, crouch = 4.0, neck = 8.0, nod = -18.0, mouth = 0.5, snarl = 0.3, eyes = 0.0, tail = -0.4, fallS = 86.0) to 6,
                c(fwd = -18.0, crouch = 4.0, neck = 6.0, nod = -18.0, mouth = 0.5, snarl = 0.3, eyes = 0.0, tail = -0.4, fallS = 89.0) to 1)),
        )
        return Triple(hurts, dodges, deaths)
    }

    // ---- the wild boar: head low, the crest up; it charges and rips upward with the tusks, slashes sideways, rams
    private val B_STAND = Rig(neck = -4.0, nod = 4.0, snarl = 0.6, mouth = 0.15, ears = -0.3, tail = 0.0, yaw = YAW)
    private val B_BREATHE = B_STAND.copy(breath = 1.0, crouch = 0.8, nod = 7.0, mouth = 0.25, tailSwing = 14.0)
    private val B_LOWER = B_STAND.copy(crouch = 6.0, pitch = 6.0, neck = -14.0, nod = 14.0, ears = -1.0, snarl = 1.0, mouth = 0.3, hl = V(0.0, 0.0, -6.0), hr = V(0.0, 0.0, -4.0), fl = V(0.0, 6.0, 4.0))
    private val B_CHARGE = B_LOWER.copy(fwd = 34.0, crouch = 2.0, pitch = 4.0, nod = 16.0, fl = V(0.0, 12.0, 46.0), fr = V(0.0, 0.0, 40.0), hl = V(0.0, 8.0, 24.0), hr = V(0.0, 0.0, 30.0), tail = 0.6)
    private val B_GORE = B_CHARGE.copy(fwd = 40.0, crouch = -4.0, pitch = -10.0, neck = 10.0, nod = -26.0, mouth = 0.6, fl = V(0.0, 14.0, 42.0), fr = V(0.0, 6.0, 48.0), hl = V(0.0, 0.0, 30.0), hr = V(0.0, 0.0, 34.0))
    private val B_WIND = B_STAND.copy(turn = 30.0, side = 4.0, crouch = 3.0, neck = -8.0, nod = 10.0, snarl = 1.0, ears = -1.0, mouth = 0.3, tailSwing = -20.0)
    private val B_SLASH = B_WIND.copy(fwd = 26.0, side = 0.0, turn = -34.0, neck = -2.0, nod = 4.0, mouth = 0.5, fr = V(0.0, 8.0, 30.0), fl = V(0.0, 0.0, 22.0), hl = V(0.0, 0.0, 14.0), hr = V(0.0, 0.0, 18.0), tailSwing = 20.0)
    private val B_FOLLOW = B_SLASH.copy(fwd = 22.0, turn = -40.0, nod = 8.0, mouth = 0.25, fr = V(0.0, 0.0, 26.0))
    private val B_BACK = B_STAND.copy(fwd = -10.0, crouch = 8.0, pitch = 6.0, neck = -10.0, nod = 12.0, snarl = 1.0, ears = -1.0, hl = V(0.0, 0.0, -6.0), hr = V(0.0, 0.0, -4.0))
    private val B_RAM = B_BACK.copy(fwd = 44.0, crouch = 0.0, pitch = 2.0, neck = -12.0, nod = 10.0, mouth = 0.2, fl = V(0.0, 16.0, 52.0), fr = V(0.0, 8.0, 42.0), hl = V(0.0, 0.0, 30.0), hr = V(0.0, 6.0, 38.0), tail = 0.7)
    private val B_RECOIL = B_RAM.copy(fwd = 34.0, crouch = 4.0, pitch = -6.0, neck = 4.0, nod = -8.0, mouth = 0.7, fl = V(0.0, 0.0, 36.0), fr = V(0.0, 0.0, 40.0))
    private val BOAR_MOVES: Moves = reactions(B_STAND, 0.8).let { (h, d, f) ->
        Moves(Seq(List(IDLE_FRAMES) { B_STAND.lerp(B_BREATHE, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) }),
            Seq(tween(B_STAND to 4, B_STAND.copy(neck = 18.0, nod = -24.0, mouth = 0.8, snarl = 1.0) to 6, B_STAND to 1)),
            listOf(Seq(tween(B_STAND to 3, B_LOWER to 4, B_CHARGE to 2, B_GORE to 5, B_STAND to 1), 9),
                Seq(tween(B_STAND to 3, B_WIND to 4, B_SLASH to 2, B_FOLLOW to 5, B_STAND to 1), 9),
                Seq(tween(B_STAND to 3, B_BACK to 4, B_RAM to 2, B_RECOIL to 5, B_STAND to 1), 9)), h, d, f)
    }

    // ---- the giant rat: hunched, sniffing; it lunges and bites, leaps at the face, gnaws low at the legs
    private val R_STAND = Rig(neck = -2.0, nod = 6.0, snarl = 0.5, mouth = 0.2, ears = 0.0, tail = 0.0, yaw = YAW)
    private val R_SNIFF = R_STAND.copy(breath = 1.0, neck = 3.0, nod = 0.0, mouth = 0.3, tailSwing = 12.0, turn = 6.0)
    private val R_CROUCH = R_STAND.copy(crouch = 4.0, pitch = 4.0, neck = -10.0, nod = 8.0, mouth = 0.4, snarl = 1.0, ears = -1.0, hl = V(0.0, 0.0, 2.0), hr = V(0.0, 0.0, 3.0))
    private val R_BITE = R_CROUCH.copy(fwd = 16.0, crouch = 1.0, neck = -2.0, nod = -6.0, mouth = 1.0, fr = V(0.0, 3.0, 14.0), fl = V(0.0, 0.0, 8.0), hl = V(0.0, 0.0, -3.0))
    private val R_SNAP = R_BITE.copy(fwd = 18.0, mouth = 0.05, nod = -2.0)
    private val R_COIL = R_CROUCH.copy(crouch = 6.0, pitch = 8.0, neck = -8.0, hl = V(0.0, 0.0, 4.0), hr = V(0.0, 0.0, 5.0), fl = V(0.0, 0.0, -2.0))
    private val R_LEAP = R_STAND.copy(fwd = 26.0, crouch = -26.0, pitch = -16.0, neck = 6.0, nod = -8.0, mouth = 1.0, snarl = 1.0, ears = -1.0, tail = 0.6,
        fl = V(0.0, 30.0, 20.0), fr = V(0.0, 32.0, 18.0), hl = V(0.0, 20.0, -16.0), hr = V(0.0, 22.0, -14.0))
    private val R_LAND = R_STAND.copy(fwd = 30.0, crouch = -4.0, pitch = -6.0, mouth = 0.1, snarl = 1.0, ears = -1.0, fl = V(0.0, 10.0, 16.0), fr = V(0.0, 12.0, 14.0), hl = V(0.0, 0.0, 6.0), hr = V(0.0, 0.0, 8.0))
    private val R_LOW = R_CROUCH.copy(crouch = 6.0, pitch = 10.0, neck = -26.0, nod = 18.0, mouth = 0.5)
    private val R_LOW_BITE = R_LOW.copy(fwd = 14.0, crouch = 5.0, neck = -24.0, nod = 20.0, mouth = 1.0, fl = V(0.0, 0.0, 8.0), fr = V(0.0, 0.0, 12.0))
    private val R_LOW_TEAR = R_LOW_BITE.copy(fwd = 13.0, mouth = 0.1, turn = 30.0, tailSwing = -20.0)
    private val RAT_MOVES: Moves = reactions(R_STAND, 0.45).let { (h, d, f) ->
        Moves(Seq(List(IDLE_FRAMES) { R_STAND.lerp(R_SNIFF, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) }),
            Seq(tween(R_STAND to 4, R_STAND.copy(neck = 20.0, nod = -24.0, mouth = 0.8, snarl = 1.0) to 6, R_STAND to 1)),
            listOf(Seq(tween(R_STAND to 3, R_CROUCH to 4, R_BITE to 2, R_SNAP to 5, R_STAND to 1), 9),
                Seq(tween(R_STAND to 3, R_COIL to 4, R_LEAP to 3, R_LAND to 5, R_STAND to 1), 10),
                Seq(tween(R_STAND to 3, R_LOW to 4, R_LOW_BITE to 2, R_LOW_TEAR to 5, R_STAND to 1), 9)), h, d, f)
    }

    private fun moves(id: String) = when (kindOf(id)) { Beast.Kind.WOLF -> WOLF_MOVES; Beast.Kind.BOAR -> BOAR_MOVES; Beast.Kind.RAT -> RAT_MOVES }

    /** The frames of one act; [variant] picks among the three of each. */
    fun sequence(id: String, act: Act, variant: Int): Seq = moves(id).let { m ->
        when (act) {
            Act.IDLE -> m.idle
            Act.HOWL -> m.howl
            Act.ATTACK -> m.attacks[variant.mod(3)]
            Act.HURT -> m.hurts[variant.mod(3)]
            Act.DODGE -> m.dodges[variant.mod(3)]
            Act.DIE -> m.deaths[variant.mod(3)]
        }
    }

    /** The wolf's frames, as before. */
    fun sequence(act: Act, variant: Int): Seq = sequence("wolf", act, variant)

    fun variants(act: Act): Int = if (act == Act.IDLE || act == Act.HOWL) 1 else 3

    /**
     * A badly hurt wolf ([wound] 1 below half its hit points, 2 below a quarter) hangs its head lower, pants, lays its
     * ears back and, while standing, holds one forepaw off the ground.
     */
    fun wounded(r: Rig, wound: Int, act: Act): Rig {
        if (wound <= 0 || r.fallS != 0.0) return r
        val k = wound / 2.0
        var out = r.copy(neck = r.neck - 6.0 - 6.0 * k, nod = r.nod + 4.0 * k, mouth = maxOf(r.mouth, 0.35 + 0.2 * k), ears = minOf(r.ears, -0.5 - 0.5 * k),
            tail = r.tail - 0.3 * k, crouch = r.crouch + 2.0 * k)
        if (act == Act.IDLE) out = out.copy(fr = V(out.fr.r, out.fr.u + 8.0 + 6.0 * k, out.fr.f - 4.0))
        return out
    }

    // ---------------------------------------------------------------- the lunge

    /** How much larger the wolf is drawn at the end of its lunge: it comes nearer to us, towards the hero. */
    const val LUNGE_SCALE = 1.18

    private val tips = java.util.concurrent.ConcurrentHashMap<String, Pair<Double, Double>>()

    /** Where the jaws meet in the frame at the moment they close, in art pixels of the frame. */
    fun tip(id: String, look: MonsterLook, variant: Int): Pair<Double, Double> = tips.getOrPut("$id/${look.seed}/${variant.mod(3)}") {
        val seq = sequence(id, Act.ATTACK, variant)
        val rig = seq.rigs[seq.strike.coerceIn(0, seq.rigs.size - 1)]
        val b = beast(id, look)
        b.solids(rig)
        b.project(b.snoutTip, rig, ANCHOR_X, GROUND, PX)
    }

    /** How far along its lunge the wolf is at frame [index] of an attack (0 to 1); see [FoeArt.lungeAt]. */
    fun lungeAt(id: String, variant: Int, index: Double): Double {
        val seq = sequence(id, Act.ATTACK, variant)
        val hit = seq.strike.coerceAtLeast(1)
        val n = seq.rigs.size
        fun smooth(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
        return if (index <= hit) smooth((index - hit * 0.3) / (hit * 0.7)) else 1 - smooth((index - hit) / (n - 1 - hit).coerceAtLeast(1))
    }

    /** The step for a bite, in art pixels, so the jaws land on ([toX], [toY]); see [FoeArt.lungeOffset]. */
    fun lungeOffset(id: String, look: MonsterLook, variant: Int, feetX: Double, feetY: Double, toX: Double, toY: Double): Pair<Double, Double> {
        val (tx, ty) = tip(id, look, variant)
        // how far below the aim point the blow lands: the wolf's low bite goes for the legs, a boar's tusks for the
        // thigh and hip, a rat for the shins, but for its leap at the face
        val drop = when (kindOf(id)) {
            Beast.Kind.WOLF -> doubleArrayOf(0.0, 0.0, 52.0)
            Beast.Kind.BOAR -> doubleArrayOf(34.0, 40.0, 38.0)
            Beast.Kind.RAT -> doubleArrayOf(66.0, 12.0, 74.0)
        }[variant.mod(3)]
        val aimY = toY + drop
        return Pair(toX - feetX - (tx - ANCHOR_X) * LUNGE_SCALE, aimY - feetY - (ty - GROUND) * LUNGE_SCALE)
    }

    // ---------------------------------------------------------------- the frames, kept

    private val capacity: Int = (Runtime.getRuntime().maxMemory() / 10 / (W * H * 4L)).toInt().coerceIn(80, 400)
    private val cache = object : LinkedHashMap<String, PixelImage>(128, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > capacity
    }

    private fun key(id: String, look: MonsterLook, act: Act, variant: Int, i: Int, wound: Int) =
        "$id/${look.seed}/${look.shiny}/$act/${if (variants(act) > 1) variant.mod(3) else 0}/$i/$wound"

    fun frame(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound0: Int = 0): PixelImage {
        // a fall looks the same however hurt the wolf was: drawn once, not again for each wound
        val wound = if (act == Act.DIE) 0 else wound0
        val seq = sequence(id, act, variant).rigs
        val i = if (act == Act.IDLE) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        val k = key(id, look, act, variant, i, wound)
        synchronized(cache) { cache[k]?.let { return it } }
        val img = beast(id, look).render(W, H, ANCHOR_X, GROUND, PX, wounded(seq[i], wound, act))
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** The frame if drawn already, else the nearest earlier one, else the first of the guard: the battle never waits. */
    fun shown(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound0: Int = 0): PixelImage {
        val wound = if (act == Act.DIE) 0 else wound0
        val seq = sequence(id, act, variant).rigs
        val i = if (act == Act.IDLE) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        synchronized(cache) {
            for (j in i downTo 0) cache[key(id, look, act, variant, j, wound)]?.let { return it }
            if (act != Act.IDLE) for (j in 0 until IDLE_FRAMES) cache[key(id, look, Act.IDLE, 0, j, wound)]?.let { return it }
            for (j in 0 until IDLE_FRAMES) cache[key(id, look, Act.IDLE, 0, j, 0)]?.let { return it }
        }
        return frame(id, look, Act.IDLE, 0, 0, wound)
    }

    /** Draws every frame ahead, the guard first; off the main thread. */
    fun prepare(id: String, look: MonsterLook, wound: Int = 0, cancelled: () -> Boolean = { false }) {
        // the first frame of the guard, then this wolf's one fall (a short fight may end before the rest is drawn), then the rest
        if (!cancelled()) frame(id, look, Act.IDLE, 0, 0, wound)
        val plan = listOf(Act.DIE to listOf(dieVariant(look)), Act.IDLE to listOf(0), Act.ATTACK to (0..2).toList(), Act.HURT to (0..2).toList(),
            Act.DODGE to (0..2).toList()) + (if (kindOf(id) == Beast.Kind.WOLF) listOf(Act.HOWL to listOf(0)) else emptyList())
        for ((act, vs) in plan) for (v in vs)
            for (i in sequence(id, act, v).rigs.indices) { if (cancelled()) return; frame(id, look, act, v, i, wound) }
    }

    /** The one way this wolf falls: fixed by its look, so the killing bite and the defeat play the same fall. */
    fun dieVariant(look: MonsterLook): Int = look.seed.mod(3)

    /** How long and how tall the animal itself is in a frame, in art pixels. */
    fun bodySize(id: String, look: MonsterLook): Pair<Double, Double> {
        val s = size(id, look) * PX
        return when (kindOf(id)) {
            Beast.Kind.WOLF -> Pair(120.0 * s, 92.0 * s)
            Beast.Kind.BOAR -> Pair(150.0 * s, 100.0 * s)
            Beast.Kind.RAT -> Pair(80.0 * s, 42.0 * s)
        }
    }
}
