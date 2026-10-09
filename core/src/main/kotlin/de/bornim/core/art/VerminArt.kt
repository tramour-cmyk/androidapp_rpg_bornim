package de.bornim.core.art

import de.bornim.core.MonsterLook
import de.bornim.core.art.Vermin.Rig
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * The vermin in battle ([Vermin]): the giant spider, the giant centipede, the giant bat, the stirge and the ochre jelly,
 * turned towards the hero, every act in three variants, like the animals of [BeastArt]. A frame is [W] × [H] with the
 * feet (or the ground under a flyer) at ([ANCHOR_X], [GROUND]).
 */
object VerminArt {
    const val W = 280
    const val H = 200
    const val ANCHOR_X = 160.0
    const val GROUND = 166.0
    /** Art pixels per centimetre, as for the other foes. */
    const val PX = 0.66

    val KINDS = setOf("giant_spider", "giant_centipede", "giant_bat", "stirge", "ochre_jelly")

    fun kindOf(id: String): Vermin.Kind = when (id) {
        "giant_spider" -> Vermin.Kind.SPIDER
        "giant_centipede" -> Vermin.Kind.CENTIPEDE
        "giant_bat" -> Vermin.Kind.BAT
        "stirge" -> Vermin.Kind.STIRGE
        else -> Vermin.Kind.JELLY
    }

    /**
     * How big this one is drawn, beside the wolf: the spider, the bat and the jelly smaller than their SRD size, so they
     * stay in the picture and leave room for the hero; the stirge larger than life, so it reads at battle size (as the
     * giant rat); a little different from one to the next.
     */
    fun size(id: String, look: MonsterLook): Double {
        val f = 0.92 + 0.16 * (look.seed.mod(7) / 6.0)
        return f * when (kindOf(id)) {
            Vermin.Kind.SPIDER -> 0.62
            Vermin.Kind.CENTIPEDE -> 1.0
            Vermin.Kind.BAT -> 0.55
            Vermin.Kind.STIRGE -> 0.95
            Vermin.Kind.JELLY -> 0.65
        }
    }

    /** One of the three looks of the kind, fixed by the foe's look. */
    fun vermin(id: String, look: MonsterLook) = Vermin(kindOf(id), look.pick(3, 10), size(id, look))

    // ---------------------------------------------------------------- the moves

    /** A sequence with the frame at which the bite, sting or blow lands on the hero (or -1). */
    class Seq(val rigs: List<Rig>, val strike: Int = -1)

    /** In-between frames from one key to the next, eased in and out. */
    private fun tween(vararg keys: Pair<Rig, Int>): List<Rig> {
        val out = mutableListOf<Rig>()
        for (i in 0 until keys.size - 1) {
            val (a, n) = keys[i]
            val b = keys[i + 1].first
            for (k in 0 until n) out += a.lerp(b, (1 - cos(k / n.toDouble() * PI)) / 2)
        }
        out += keys.last().first
        return out
    }

    const val IDLE_FRAMES = 16

    /** A loop of [IDLE_FRAMES] frames: [at] gets the phase, 0 to 1. */
    private fun loop(at: (Double) -> Rig) = Seq(List(IDLE_FRAMES) { at(it / IDLE_FRAMES.toDouble()) })

    /** Struck, dodging or falling: from the guard to [key], held a moment, and back. */
    private fun react(stand: Rig, key: Rig) = Seq(tween(stand to 2, key to 3, key to 2, stand to 2))

    private class Moves(val idle: Seq, val attacks: List<Seq>, val hurts: List<Seq>, val dodges: List<Seq>, val deaths: List<Seq>)

    // ---- the giant spider: the forelegs raised, the fangs bared; it lunges and bites, pounces, stabs with the forelegs
    private val S_STAND = Rig(rear = 10.0, jaw = 0.45, yaw = -55.0)
    private val SPIDER = run {
        val st = S_STAND
        val rearUp = st.copy(rear = 32.0, jaw = 1.0, fwd = -8.0, crouch = -4.0)
        val lunge = st.copy(fwd = 42.0, rear = 10.0, crouch = 6.0, jaw = 1.0, step = 0.3)
        val bite = lunge.copy(fwd = 46.0, jaw = 0.05, rear = 4.0)
        val coil = st.copy(crouch = 14.0, rear = 4.0, fwd = -10.0, jaw = 0.7)
        val jump = st.copy(fwd = 52.0, crouch = -30.0, rear = 26.0, jaw = 1.0, step = 0.5)
        val land = st.copy(fwd = 62.0, crouch = 4.0, rear = 18.0, jaw = 0.1, step = 0.6)
        val high = st.copy(rear = 44.0, crouch = -8.0, jaw = 0.8, fwd = -4.0)
        val stab = st.copy(fwd = 36.0, rear = 6.0, crouch = 8.0, jaw = 1.0, step = 0.25)
        val grip = stab.copy(fwd = 40.0, rear = 2.0, jaw = 0.0, crouch = 10.0)
        Moves(
            loop { t -> st.copy(rear = 10.0 + 6.0 * sin(t * 2 * PI), crouch = 1.5 + 1.5 * sin(t * 4 * PI), jaw = 0.45 + 0.25 * sin(t * 2 * PI + 1.0), step = 0.04 * sin(t * 2 * PI)) },
            listOf(Seq(tween(st to 3, rearUp to 4, lunge to 2, bite to 5, st to 1), 9),
                Seq(tween(st to 3, coil to 4, jump to 3, land to 5, st to 1), 10),
                Seq(tween(st to 3, high to 4, stab to 2, grip to 5, st to 1), 9)),
            listOf(react(st, st.copy(fwd = -18.0, rear = 26.0, jaw = 1.0, crouch = -2.0)),
                react(st, st.copy(fwd = -10.0, side = -14.0, crouch = 10.0, jaw = 0.9, yaw = -32.0, step = 0.5)),
                react(st, st.copy(crouch = 18.0, rear = -6.0, jaw = 0.8, fwd = -6.0))),
            listOf(react(st, st.copy(side = -36.0, fwd = -14.0, crouch = -6.0, step = 0.5, yaw = -70.0)),
                react(st, st.copy(crouch = 20.0, rear = -8.0, jaw = 0.6)),
                react(st, st.copy(fwd = -38.0, crouch = -10.0, rear = 22.0, step = 0.5))),
            listOf(
                // the legs give way and draw in under it
                Seq(tween(st to 1, st.copy(rear = 34.0, jaw = 1.0, fwd = -6.0) to 3, st.copy(crouch = 16.0, rear = 10.0, jaw = 0.8, curl = 0.45) to 4,
                    st.copy(crouch = 28.0, rear = 0.0, jaw = 0.6, curl = 1.0) to 6, st.copy(crouch = 29.0, rear = 0.0, jaw = 0.6, curl = 1.0) to 1)),
                // over onto its side, the legs curling
                Seq(tween(st to 1, st.copy(fwd = -10.0, side = -10.0, rear = 20.0, jaw = 1.0) to 3, st.copy(crouch = 10.0, curl = 0.4, fallS = 30.0, jaw = 0.8) to 4,
                    st.copy(crouch = 14.0, curl = 0.85, fallS = 78.0, jaw = 0.6) to 6, st.copy(crouch = 14.0, curl = 0.9, fallS = 82.0, jaw = 0.6) to 1)),
                // rearing up high in its pain, then crumpling forward
                Seq(tween(st to 1, st.copy(rear = 48.0, crouch = -10.0, jaw = 1.0, fwd = -10.0) to 3, st.copy(rear = 20.0, crouch = 12.0, curl = 0.3, jaw = 0.9, fallF = 8.0) to 4,
                    st.copy(crouch = 26.0, curl = 0.9, jaw = 0.7, fallF = 14.0) to 6, st.copy(crouch = 27.0, curl = 0.95, jaw = 0.7, fallF = 15.0) to 1)),
            ))
    }

    // ---- the giant centipede: the front reared, the venom claws open; it strikes down, darts low at the legs, lashes
    private val C_STAND = Rig(rear = 20.0, jaw = 0.45, yaw = -58.0)
    private val CENTIPEDE = run {
        val st = C_STAND
        val rearUp = st.copy(rear = 40.0, jaw = 1.0, fwd = -10.0, step = 0.15)
        val strike = st.copy(rear = 10.0, fwd = 42.0, jaw = 1.0, step = 0.3)
        val bite = strike.copy(rear = 8.0, fwd = 44.0, jaw = 0.0)
        val low = st.copy(rear = 0.0, fwd = -8.0, jaw = 1.0, step = 0.2)
        val dart = low.copy(fwd = 50.0, step = 0.55)
        val clamp = dart.copy(fwd = 52.0, jaw = 0.0, step = 0.6)
        val coil = st.copy(rear = 32.0, fwd = -20.0, step = 0.3, jaw = 0.8)
        val lash = st.copy(rear = 22.0, fwd = 46.0, jaw = 1.0, step = 0.65)
        val grip = lash.copy(rear = 16.0, fwd = 50.0, jaw = 0.0, step = 0.75)
        Moves(
            // it never keeps still: the body ripples, the front rises and sinks
            loop { t -> st.copy(step = t, rear = 20.0 + 5.0 * sin(t * 2 * PI), jaw = 0.45 + 0.3 * sin(t * 4 * PI)) },
            listOf(Seq(tween(st to 3, rearUp to 4, strike to 2, bite to 5, st to 1), 9),
                Seq(tween(st to 3, low to 4, dart to 2, clamp to 5, st to 1), 9),
                Seq(tween(st to 3, coil to 4, lash to 3, grip to 5, st to 1), 10)),
            listOf(react(st, st.copy(fwd = -16.0, rear = 36.0, jaw = 1.0, step = 0.2)),
                react(st, st.copy(side = -14.0, rear = 10.0, step = 0.5, jaw = 0.9, curl = 0.25)),
                react(st, st.copy(rear = 0.0, fwd = -8.0, curl = 0.35, jaw = 0.8, step = 0.35))),
            listOf(react(st, st.copy(side = -30.0, fwd = -10.0, step = 0.5, rear = 14.0)),
                react(st, st.copy(rear = 0.0, fwd = -30.0, step = 0.6)),
                react(st, st.copy(rear = 46.0, fwd = -16.0, step = 0.3))),
            listOf(
                // it coils up tight
                Seq(tween(st to 1, st.copy(rear = 38.0, jaw = 1.0, step = 0.2) to 3, st.copy(rear = 8.0, curl = 0.55, jaw = 0.8, step = 0.4) to 4,
                    st.copy(rear = 0.0, curl = 1.0, jaw = 0.5, step = 0.5) to 6, st.copy(rear = 0.0, curl = 1.0, jaw = 0.5, step = 0.5) to 1)),
                // over onto its back, the legs up
                Seq(tween(st to 1, st.copy(rear = 34.0, jaw = 1.0, fwd = -8.0) to 3, st.copy(rear = 6.0, curl = 0.3, fallS = 40.0, jaw = 0.8, step = 0.4) to 4,
                    st.copy(rear = 0.0, curl = 0.45, fallS = 88.0, jaw = 0.5, step = 0.6) to 6, st.copy(rear = 0.0, curl = 0.45, fallS = 90.0, jaw = 0.5, step = 0.6) to 1)),
                // thrashing, then still
                Seq(tween(st to 1, st.copy(rear = 46.0, fwd = -12.0, jaw = 1.0, step = 0.3) to 3, st.copy(rear = 0.0, fwd = -6.0, curl = 0.6, step = 0.8, jaw = 0.9) to 4,
                    st.copy(rear = 0.0, fwd = -10.0, curl = 0.8, step = 1.1, jaw = 0.5) to 6, st.copy(rear = 0.0, fwd = -10.0, curl = 0.8, step = 1.1, jaw = 0.5) to 1)),
            ))
    }

    /**
     * The bat and the stirge share their way of moving: hanging in the air on beating wings, swooping on the hero; [s]
     * scales every move, [drop] is how far down the body comes to lie on the ground when it falls.
     */
    private fun flyer(st: Rig, s: Double, drop: Double): Moves {
        fun c(fwd: Double = 0.0, side: Double = 0.0, hover: Double = 0.0, beat: Double = 0.0, spread: Double = 1.0, jaw: Double = st.jaw,
              yaw: Double = st.yaw, fallF: Double = 0.0, crouch: Double = 0.0) =
            st.copy(fwd = fwd * s, side = side * s, hover = st.hover + hover * s, beat = beat, spread = spread, jaw = jaw, yaw = yaw, fallF = fallF, crouch = crouch * s)
        val up = c(fwd = -10.0, hover = 22.0, beat = -0.9, jaw = 0.8)
        val dive = c(fwd = 42.0, hover = -8.0, beat = 0.9, spread = 0.7, jaw = 1.0)
        val bite = c(fwd = 46.0, hover = -6.0, beat = 0.3, spread = 0.8, jaw = 0.05)
        val back = c(fwd = -14.0, hover = 10.0, beat = -1.0, jaw = 1.0)
        val buffet = c(fwd = 38.0, hover = 4.0, beat = 1.0, jaw = 1.0)
        val snap = c(fwd = 42.0, hover = 2.0, beat = -0.4, jaw = 0.0)
        val high = c(hover = 40.0, beat = -0.8, jaw = 1.0, fwd = -6.0)
        val stoop = c(fwd = 44.0, hover = 16.0, beat = 0.6, spread = 0.5, jaw = 1.0)
        val strike = stoop.copy(jaw = 0.0, beat = 0.2, spread = 0.7)
        // falling: the wings crumple, it drops and lies on the ground
        val ground = -(st.hover + drop)
        return Moves(
            loop { t -> st.copy(beat = 0.85 * sin(t * 4 * PI), hover = st.hover + (5.0 * cos(t * 4 * PI)) * s, jaw = st.jaw + 0.2 * sin(t * 2 * PI)) },
            listOf(Seq(tween(st to 3, up to 4, dive to 2, bite to 5, st to 1), 9),
                Seq(tween(st to 3, back to 4, buffet to 3, snap to 5, st to 1), 10),
                Seq(tween(st to 3, high to 4, stoop to 2, strike to 5, st to 1), 9)),
            listOf(react(st, c(fwd = -18.0, hover = 10.0, beat = -1.0, spread = 0.8, jaw = 1.0)),
                react(st, c(side = -16.0, hover = -8.0, beat = 1.0, jaw = 0.9, yaw = st.yaw + 14.0)),
                react(st, c(hover = -16.0, beat = 0.8, spread = 0.5, jaw = 0.8))),
            listOf(react(st, c(side = -34.0, hover = 18.0, beat = -1.0)),
                react(st, c(hover = 36.0, beat = -1.0, fwd = -6.0)),
                react(st, c(fwd = -30.0, hover = 6.0, beat = 0.8))),
            // falling: the wings crumple, it drops and lies on the ground face down, the wings spread or half folded
            listOf(
                Seq(tween(st to 1, c(hover = 12.0, beat = -1.0, jaw = 1.0) to 3, c(hover = ground * 0.55 / s, beat = 0.9, spread = 0.5, jaw = 1.0, fallF = 30.0) to 4,
                    c(hover = ground / s, spread = 0.75, beat = 0.2, jaw = 0.7, fallF = 78.0) to 6, c(hover = ground / s, spread = 0.75, beat = 0.25, jaw = 0.7, fallF = 82.0) to 1)),
                Seq(tween(st to 1, c(side = -14.0, hover = -4.0, beat = 1.0, jaw = 1.0, yaw = st.yaw + 14.0) to 3, c(side = -12.0, hover = ground * 0.6 / s, beat = -0.6, spread = 0.6, jaw = 0.9, fallF = 24.0, yaw = st.yaw + 20.0) to 4,
                    c(side = -10.0, hover = ground / s, spread = 0.55, beat = 0.3, jaw = 0.6, fallF = 76.0, yaw = st.yaw + 24.0) to 6,
                    c(side = -10.0, hover = ground / s, spread = 0.55, beat = 0.3, jaw = 0.6, fallF = 80.0, yaw = st.yaw + 24.0) to 1)),
                Seq(tween(st to 1, c(fwd = -16.0, hover = 18.0, beat = -1.0, jaw = 1.0) to 3, c(fwd = -10.0, hover = ground * 0.5 / s, beat = 1.0, spread = 0.3, jaw = 0.8, fallF = 20.0) to 4,
                    c(fwd = -8.0, side = 8.0, hover = ground / s, spread = 0.45, beat = 0.7, jaw = 0.6, fallF = 70.0, yaw = st.yaw - 20.0) to 6,
                    c(fwd = -8.0, side = 8.0, hover = ground / s, spread = 0.45, beat = 0.7, jaw = 0.6, fallF = 74.0, yaw = st.yaw - 20.0) to 1)),
            ))
    }

    private val BAT = flyer(Rig(jaw = 0.6, spread = 1.0, yaw = -40.0), 1.0, 66.0)
    private val STIRGE = flyer(Rig(jaw = 0.5, spread = 1.0, hover = 6.0, yaw = -42.0), 0.55, 28.0)

    // ---- the ochre jelly: a heap that heaves; it reaches out and slams down, surges over the hero, spreads at the legs
    private val J_STAND = Rig(rear = 4.0, jaw = 0.0, yaw = -45.0)
    private val JELLY = run {
        val st = J_STAND
        val gather = st.copy(surge = 0.5, rear = 20.0, fwd = -6.0)
        val reach = st.copy(surge = 0.3, rear = 40.0, fwd = 30.0)
        val slam = st.copy(surge = -0.4, rear = 10.0, fwd = 34.0)
        val swell = st.copy(surge = 1.0, rear = 10.0, fwd = -4.0)
        val flow = st.copy(surge = -0.5, rear = 30.0, fwd = 40.0)
        val engulf = st.copy(surge = -0.6, rear = 20.0, fwd = 44.0)
        val squat = st.copy(surge = -0.6, rear = 0.0, fwd = -4.0)
        val spread = st.copy(surge = -0.8, rear = 30.0, fwd = 36.0)
        val creep = st.copy(surge = -0.3, rear = 6.0, fwd = 38.0)
        Moves(
            // it heaves slowly, swelling and sinking
            loop { t -> st.copy(surge = 0.15 * sin(t * 2 * PI), rear = 4.0 + 3.0 * sin(t * 2 * PI + 1.2)) },
            listOf(Seq(tween(st to 3, gather to 4, reach to 2, slam to 5, st to 1), 9),
                Seq(tween(st to 3, swell to 4, flow to 3, engulf to 5, st to 1), 10),
                Seq(tween(st to 3, squat to 4, spread to 2, creep to 5, st to 1), 9)),
            listOf(react(st, st.copy(surge = -0.5, fwd = -10.0)),
                react(st, st.copy(side = -10.0, surge = 0.4, rear = 10.0)),
                react(st, st.copy(surge = -0.8, rear = 0.0))),
            listOf(react(st, st.copy(side = -28.0, surge = -0.3)),
                react(st, st.copy(fwd = -24.0, surge = 0.3)),
                react(st, st.copy(surge = -1.0, rear = 0.0))),
            listOf(
                // it melts away into a spreading pool
                Seq(tween(st to 1, st.copy(surge = 0.8, rear = 16.0) to 3, st.copy(surge = -0.4, curl = 0.5) to 4, st.copy(surge = -0.9, curl = 0.95) to 6, st.copy(surge = -1.0, curl = 1.0) to 1)),
                Seq(tween(st to 1, st.copy(surge = -0.6, side = -8.0) to 3, st.copy(surge = 0.4, rear = 20.0, curl = 0.3) to 4, st.copy(surge = -0.8, side = 6.0, curl = 0.9) to 6, st.copy(surge = -0.9, side = 6.0, curl = 1.0) to 1)),
                Seq(tween(st to 1, st.copy(surge = 1.0, rear = 30.0, fwd = 6.0) to 3, st.copy(surge = -0.2, fwd = 10.0, curl = 0.6) to 4, st.copy(surge = -0.9, fwd = 12.0, curl = 0.95) to 6, st.copy(surge = -1.0, fwd = 12.0, curl = 1.0) to 1)),
            ))
    }

    private fun moves(id: String) = when (kindOf(id)) {
        Vermin.Kind.SPIDER -> SPIDER
        Vermin.Kind.CENTIPEDE -> CENTIPEDE
        Vermin.Kind.BAT -> BAT
        Vermin.Kind.STIRGE -> STIRGE
        Vermin.Kind.JELLY -> JELLY
    }

    /** The frames of one act; [variant] picks among the three of each. A howl it has not: it stands. */
    fun sequence(id: String, act: Act, variant: Int): Seq = moves(id).let { m ->
        when (act) {
            Act.IDLE, Act.HOWL -> m.idle
            Act.ATTACK -> m.attacks[variant.mod(3)]
            Act.HURT -> m.hurts[variant.mod(3)]
            Act.DODGE -> m.dodges[variant.mod(3)]
            Act.DIE -> m.deaths[variant.mod(3)]
        }
    }

    fun variants(act: Act): Int = if (act == Act.IDLE || act == Act.HOWL) 1 else 3

    // ---------------------------------------------------------------- the lunge

    const val LUNGE_SCALE = 1.18

    private val tips = java.util.concurrent.ConcurrentHashMap<String, Pair<Double, Double>>()

    /** Where the bite, sting or blow lands in the frame at the moment it strikes, in art pixels of the frame. */
    fun tip(id: String, look: MonsterLook, variant: Int): Pair<Double, Double> = tips.getOrPut("$id/${look.seed}/${variant.mod(3)}") {
        val seq = sequence(id, Act.ATTACK, variant)
        val rig = seq.rigs[seq.strike.coerceIn(0, seq.rigs.size - 1)]
        val v = vermin(id, look)
        v.solids(rig)
        v.project(v.tip, rig, ANCHOR_X, GROUND, PX)
    }

    /** How far along its lunge it is at frame [index] of an attack (0 to 1); see [FoeArt.lungeAt]. */
    fun lungeAt(id: String, variant: Int, index: Double): Double {
        val seq = sequence(id, Act.ATTACK, variant)
        val hit = seq.strike.coerceAtLeast(1)
        val n = seq.rigs.size
        fun smooth(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
        return if (index <= hit) smooth((index - hit * 0.3) / (hit * 0.7)) else 1 - smooth((index - hit) / (n - 1 - hit).coerceAtLeast(1))
    }

    /** The step for a strike, in art pixels, so it lands on ([toX], [toY]); see [FoeArt.lungeOffset]. */
    fun lungeOffset(id: String, look: MonsterLook, variant: Int, feetX: Double, feetY: Double, toX: Double, toY: Double): Pair<Double, Double> {
        val (tx, ty) = tip(id, look, variant)
        // how far below the aim point (the chest) it lands: the spider's bite at the belly, the centipede at the legs but
        // for its strike from above, the flyers at the face and throat, the jelly low
        val drop = when (kindOf(id)) {
            Vermin.Kind.SPIDER -> doubleArrayOf(20.0, 0.0, 26.0)
            Vermin.Kind.CENTIPEDE -> doubleArrayOf(30.0, 66.0, 44.0)
            Vermin.Kind.BAT -> doubleArrayOf(-12.0, 0.0, -18.0)
            Vermin.Kind.STIRGE -> doubleArrayOf(0.0, 8.0, -10.0)
            Vermin.Kind.JELLY -> doubleArrayOf(30.0, 20.0, 60.0)
        }[variant.mod(3)]
        return Pair(toX - feetX - (tx - ANCHOR_X) * LUNGE_SCALE, toY + drop - feetY - (ty - GROUND) * LUNGE_SCALE)
    }

    // ---------------------------------------------------------------- the frames, kept

    private val capacity: Int = (Runtime.getRuntime().maxMemory() / 10 / (W * H * 4L)).toInt().coerceIn(80, 400)
    private val cache = object : LinkedHashMap<String, PixelImage>(128, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > capacity
    }

    /** Only the jelly shows its wounds in its shape (see [wounded]); the others look the same however hurt. */
    private fun woundOf(id: String, act: Act, wound: Int) = if (kindOf(id) == Vermin.Kind.JELLY && act != Act.DIE) wound.coerceIn(0, 2) else 0

    private fun key(id: String, look: MonsterLook, act: Act, variant: Int, i: Int, wound: Int) =
        "$id/${look.seed}/${look.shiny}/${if (act == Act.HOWL) Act.IDLE else act}/${if (variants(act) > 1) variant.mod(3) else 0}/$i/${woundOf(id, act, wound)}"

    /**
     * A badly hurt jelly ([wound] 1 below half its hit points, 2 below a quarter) runs: lower and wider, its puddle
     * spreading, more of it dripping off.
     */
    private fun wounded(r: Rig, wound: Int): Rig = if (wound <= 0) r else r.copy(curl = r.curl + 0.25 * wound, surge = r.surge - 0.12 * wound)

    /** One frame; [wound] changes only how the jelly stands. */
    fun frame(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound0: Int = 0): PixelImage {
        val wound = woundOf(id, act, wound0)
        val seq = sequence(id, act, variant).rigs
        val i = if (act == Act.IDLE || act == Act.HOWL) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        val k = key(id, look, act, variant, i, wound)
        synchronized(cache) { cache[k]?.let { return it } }
        val img = vermin(id, look).render(W, H, ANCHOR_X, GROUND, PX, wounded(seq[i], wound))
        if (look.shiny) shimmer(img)
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** A shimmering one: its colours drawn a little towards a pale, cold silver. */
    private fun shimmer(img: PixelImage) {
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val p = img[x, y]
            if ((p ushr 24) < 128) continue
            img.set(x, y, mix(p, argb(0xB8C8DC), 0.3))
        }
    }

    /** The frame if drawn already, else the nearest earlier one, else the first of the guard: the battle never waits. */
    fun shown(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound: Int = 0): PixelImage {
        val seq = sequence(id, act, variant).rigs
        val i = if (act == Act.IDLE || act == Act.HOWL) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        synchronized(cache) {
            for (j in i downTo 0) cache[key(id, look, act, variant, j, wound)]?.let { return it }
            for (j in 0 until IDLE_FRAMES) cache[key(id, look, Act.IDLE, 0, j, wound)]?.let { return it }
            for (j in 0 until IDLE_FRAMES) cache[key(id, look, Act.IDLE, 0, j, 0)]?.let { return it }
        }
        return frame(id, look, Act.IDLE, 0, 0, wound)
    }

    /** Draws every frame ahead, the guard first and its one fall next; off the main thread. */
    fun prepare(id: String, look: MonsterLook, wound: Int = 0, cancelled: () -> Boolean = { false }) {
        if (!cancelled()) frame(id, look, Act.IDLE, 0, 0, wound)
        val plan = listOf(Act.DIE to listOf(dieVariant(look)), Act.IDLE to listOf(0), Act.ATTACK to (0..2).toList(), Act.HURT to (0..2).toList(),
            Act.DODGE to (0..2).toList())
        for ((act, vs) in plan) for (v in vs)
            for (i in sequence(id, act, v).rigs.indices) { if (cancelled()) return; frame(id, look, act, v, i, wound) }
    }

    /** The one way this one falls: fixed by its look. */
    fun dieVariant(look: MonsterLook): Int = look.seed.mod(3)

    /** How wide and how tall the animal itself is in a frame, in art pixels (the flyers counted from the ground). */
    fun bodySize(id: String, look: MonsterLook): Pair<Double, Double> {
        val s = size(id, look) * PX
        return when (kindOf(id)) {
            Vermin.Kind.SPIDER -> Pair(170.0 * s, 70.0 * s)
            Vermin.Kind.CENTIPEDE -> Pair(110.0 * s, 46.0 * s)
            Vermin.Kind.BAT -> Pair(150.0 * s, 150.0 * s)
            Vermin.Kind.STIRGE -> Pair(70.0 * s, 72.0 * s)
            Vermin.Kind.JELLY -> Pair(130.0 * s, 64.0 * s)
        }
    }
}
