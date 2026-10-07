package de.bornim.core.art

import de.bornim.core.Appearance
import de.bornim.core.Build
import de.bornim.core.Race
import de.bornim.core.Sex
import kotlin.math.abs
import kotlin.math.atan
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * The hero as a doll in three dimensions, rendered pixel by pixel. Every people has its own measures
 * from the SRD (height, build), every hero a sex, a build and a skin tone. Solids of one group melt
 * into each other, so shoulders grow out of the chest rather than being glued on.
 *
 * Poses are the [HeroFigure.Rig]s of the hand-drawn figure: its numbers are mapped onto this body's
 * landmarks, so every pose fits every people.
 */
class Doll(val race: Race, val sex: Sex, val build: Build, val skin: Int = 0, val hairTone: Int = 0, val kind: Creature? = null) {

    /** Foes built on the same doll: their own measures, head and skin, or a body of bare bones. */
    enum class Creature { GOBLIN, SKELETON }
    private val goblin = kind == Creature.GOBLIN
    private val bones = kind == Creature.SKELETON

    // ---------------------------------------------------------------- measures (cm)

    val female = sex == Sex.FEMALE
    /** Standing height. SRD: dwarves 4–5 ft, halflings about 3 ft (raised to 60 % of a human so their gear reads), half-orcs larger than humans. */
    val height = when {
        goblin -> 108.0; bones -> 172.0
        else -> when (race) { Race.HUMAN -> 175.0; Race.ELF -> 172.0; Race.DWARF -> 135.0; Race.HALFLING -> 105.0; Race.HALF_ORC -> 185.0 }
    } * (if (female) 0.93 else 1.0)
    // goblins: a big head on a small wiry body, long arms and big hands and feet
    private val heads = if (goblin) 4.2 else if (bones) 7.6 else when (race) { Race.HUMAN -> 7.5; Race.ELF -> 7.9; Race.DWARF -> 5.3; Race.HALFLING -> 5.9; Race.HALF_ORC -> 7.3 }
    /** Height of the head, chin to crown. */
    val hh = height / heads
    private val legF = if (goblin) 0.42 else if (bones) 0.51 else when (race) { Race.HUMAN -> 0.51; Race.ELF -> 0.535; Race.DWARF -> 0.39; Race.HALFLING -> 0.46; Race.HALF_ORC -> 0.5 }
    private val buildK = when (build) { Build.SLIM -> 0.86; Build.AVERAGE -> 1.0; Build.STRONG -> 1.17 }
    /** Thickness of trunk and limbs relative to a human: dwarves are as heavy as a human two feet taller. */
    val girth = (if (goblin) 0.84 else if (bones) 0.7 else when (race) { Race.HUMAN -> 1.0; Race.ELF -> 0.86; Race.DWARF -> 1.5; Race.HALFLING -> 1.08; Race.HALF_ORC -> 1.22 }) * buildK
    val limbK = girth * (if (female) 0.9 else 1.0) * (if (build == Build.STRONG) 1.05 else 1.0)
    private val shoulderK = (if (goblin) 1.0 else if (bones) 0.95 else when (race) { Race.HUMAN -> 1.0; Race.ELF -> 0.92; Race.DWARF -> 1.55; Race.HALFLING -> 1.0; Race.HALF_ORC -> 1.12 }) *
        (if (female) 0.87 else 1.0) * (if (build == Build.STRONG) 1.05 else if (build == Build.SLIM) 0.96 else 1.0)
    private val hipK = (if (female) 1.16 else 1.0) * (if (race == Race.DWARF && kind == null) 1.15 else 1.0) * (if (build == Build.STRONG) 1.04 else 1.0)
    val handK = if (goblin) 1.3 else if (kind != null) 1.0 else when (race) { Race.DWARF -> 1.2; Race.HALF_ORC -> 1.15; Race.HALFLING -> 1.05; Race.ELF -> 0.95; else -> 1.0 }
    val footK = (if (goblin) 1.3 else if (kind != null) 0.95 else when (race) { Race.HALFLING -> 1.25; Race.DWARF -> 1.05; Race.HALF_ORC -> 1.05; Race.ELF -> 0.92; else -> 0.95 }) * (if (female) 0.92 else 1.0)

    val ankleY = 0.045 * height
    val hipY = legF * height
    val kneeY = ankleY + (hipY - ankleY) * 0.52
    val chinY = height - hh * 0.98
    val shoulderY = chinY - 0.055 * height * (if (goblin) 0.6 else if (kind != null) 1.0 else if (race == Race.DWARF) 0.72 else if (race == Race.HALF_ORC) 0.85 else 1.0)
    val shoulderX = 0.105 * height * shoulderK
    val hipX = 0.052 * height * hipK
    val trunk = shoulderY - hipY
    private val armK = if (goblin) 1.16 else if (kind == null && race == Race.DWARF) 1.05 else 1.0
    val upperArm = 0.172 * height * armK
    val foreArm = 0.155 * height * armK
    val headC = P3(0.0, height - hh * 0.5, 0.0)
    val neckTop = P3(0.0, chinY + 0.01 * height, 0.0)
    /** Depth of the chest from the spine to the front, for clothes laid over it. */
    val chestDepth = 0.066 * height * girth

    val skinRgb = when (kind) {
        // goblins: olive, mossy, sallow and dark green hides
        Creature.GOBLIN -> intArrayOf(0x5E6838, 0x4E5C32, 0x6C683C, 0x445030)[skin.mod(4)]
        // old bone, yellowed and stained
        Creature.SKELETON -> intArrayOf(0xB4A684, 0xA49674, 0xBEB294, 0x968866)[skin.mod(4)]
        null -> Appearance.skins(race)[skin.mod(4)].rgb
    }
    val hairRgb = if (kind != null) 0x24201C else Appearance.hairs(race)[hairTone.mod(4)].rgb

    // ---------------------------------------------------------------- materials

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain)
    val skinMat = Mat(Ramp.of(argb(skinRgb), sat = 0.8), shine = 0.05, grain = if (kind == Creature.GOBLIN) 0.14 else 0.02)
    private val footMat = skinMat.copy(bias = -0.1)
    val hairMat = m(hairRgb, shine = 0.15, grain = 0.22)
    private val shirtMat = m(0xC9BDA2, grain = 0.06)
    /** Short trousers; a goblin's loincloth is a grimy rag. */
    private val shortsMat = if (goblin) m(0x4E4232, grain = 0.25) else m(0x7E6E58, grain = 0.06)
    private val boneMat = Mat(Ramp.of(argb(skinRgb), sat = 0.7), shine = 0.1, grain = 0.32)
    private val socketMat = m(0x1A1410)
    private val tuskMat = m(0xE8E0C8, shine = 0.3)

    // ---------------------------------------------------------------- the skeleton in a pose

    /** Where every joint is in one pose. Index 0 is the left side, 1 the right. */
    inner class Skeleton(val rig: HeroFigure.Rig, shieldArm: Boolean = false, val fists: Boolean = true, val twoHands: Boolean = false, val weaponReach: Double = 90.0) {
        /** Centimetres per unit of the old figure, which stood about 107 units tall. */
        val s = height / 107.0
        private val reachK = (upperArm + foreArm) / 31.0
        val crouch = rig.crouch * s
        val lower = Xf(shift = P3(0.0, -crouch, 0.0))
        val lean = Math.toDegrees(atan(rig.lean * 0.35))
        /** The chest turns against the hips, then the whole upper body bends. */
        val upper = Xf(Rot.pitch(lean) * Rot.yaw(rig.twist), P3(0.0, hipY, 0.0), P3(0.0, -crouch, 0.0))
        /** The head turns back against the chest, to keep its eyes on the foe. */
        val head = Xf(Rot.yaw(-rig.headTurn - rig.twist * 0.85) * Rot.pitch(rig.headDown * 3.0), neckTop).then(upper)

        /** Old figure units to centimetres on this body: heights by landmarks, widths by the shoulders, reach by the arms. */
        fun map(v: HeroFigure.V): P3 = P3(v.r * shoulderX / 15.5, mapU(v.u), v.f * reachK)
        private fun mapU(u: Double): Double {
            val from = doubleArrayOf(0.0, 52.0, 84.0, 98.5, 107.0)
            val to = doubleArrayOf(0.0, hipY, shoulderY, headC.y, height)
            if (u <= 0) return u * s
            for (i in 1 until from.size) if (u <= from[i]) return to[i - 1] + (u - from[i - 1]) / (from[i] - from[i - 1]) * (to[i] - to[i - 1])
            return height + (u - 107.0) * s
        }
        fun dir(v: HeroFigure.V) = P3(v.r, v.u, v.f).norm()

        /** Where the shoulder joints sit at rest, before the arms move them. */
        val shoulderRest = Array(2) { i -> upper.apply(P3(side(i) * shoulderX, shoulderY - 0.022 * height, 0.0)) }
        /**
         * The shoulder rides on the shoulder blade: when the arm is raised it lifts, when it reaches forward it
         * comes forward round the ribs. Without this a raised arm seems to grow out of the neck.
         */
        /**
         * Where the wrists go for a shouldered crossbow: the stock runs level from the hollow of the shoulder, the trigger
         * hand on the grip under it, the free hand under its fore end.
         */
        private val stockWrists: Pair<P3, P3>? = if (rig.stock < 0.01) null else {
            val aimD = dir(rig.weapon)
            val up = (P3.Y - aimD * (P3.Y dot aimD)).norm()
            // the butt plate presses into the hollow in front of the shoulder joint, against chest and shoulder, so the
            // kick is taken straight back into the body; the stock runs level forward from its top
            val plate = shoulderRest[1] + upper.dir(P3.Z) * (chestDepth * 0.75 + BUTT_HALF * height) - upper.dir(P3.X) * (0.05 * height) - up * (0.012 * height)
            val handLen = 0.035 * height * handK
            // the hands where they hold; the wrists back from them along the way each forearm will about lie
            val rHand = plate + up * (BUTT_DROP * height) + aimD * (STOCK_BACK * height) - up * (STOCK_ABOVE_HAND * height)
            val lHand = rHand + aimD * (0.16 * height) - up * (0.012 * height)
            val r = rHand - (rHand - shoulderRest[1] + up * (0.1 * height)).norm() * handLen
            val l = lHand - (lHand - shoulderRest[0] + up * (0.1 * height)).norm() * handLen
            Pair(map(rig.rh).lerp(r, rig.stock), map(rig.lh).lerp(l, rig.stock))
        }
        private val rAt = stockWrists?.first ?: map(rig.rh)
        private val lAt = stockWrists?.second ?: map(rig.lh)
        /** 0..1: how high each arm is raised; the shoulder blade turns up with it. */
        val lift = DoubleArray(2)
        val shoulder = Array(2) { i ->
            val aim = if (i == 1 && rig.elbowUp > 0.01) map(rig.elbowAt) else if (i == 0) lAt else rAt
            val d = (aim - shoulderRest[i]).norm()
            val up = upper.dir(P3.Y); val fwd = upper.dir(P3.Z)
            lift[i] = ((d dot up) + 0.3).coerceIn(0.0, 1.0)
            val reach = (d dot fwd).coerceAtLeast(0.0)
            shoulderRest[i] + up * (0.01 * height * lift[i]) + fwd * (0.012 * height * reach)
        }
        val hip = Array(2) { i -> lower.apply(P3(side(i) * hipX, hipY, 0.0)) }
        val ankle = Array(2) { i ->
            val sd = side(i)
            P3(sd * hipX * 0.85 * (rig.spread / 6.0), ankleY, (if (sd > 0) rig.stride else -rig.stride * 0.3) * s)
        }
        val knee: Array<P3>
        val elbow: Array<P3>
        val wrist: Array<P3>
        /** The weapon hand's thumb side, after any turn of the forearm. */
        private val thumbR: P3
        /** The weapon sits fixed in the fist: forearm direction, leaned towards the thumb by the grip angle. */
        val weapon: P3
        init {
            val k = Array(2) { P3.O }; val e = Array(2) { P3.O }; val w = Array(2) { P3.O }
            for (i in 0..1) {
                val sd = side(i)
                val (kn, an) = ik(hip[i], ankle[i], hipY - kneeY, kneeY - ankleY, P3(sd * 0.15, 0.0, 1.0))
                k[i] = kn; ankle[i] = an
            }
            // the weapon arm first: the free hand may need to know where the weapon is
            run {
                val i = 1
                val target = rAt
                var (el, wr) = ik(shoulder[i], target, upperArm, foreArm, P3(rig.rPole.r, rig.rPole.u, rig.rPole.f))
                if (rig.foreLevel > 0.01) {
                    // the forearm held level, pointing at the foe: the elbow sits behind the hand, the upper arm reaches it
                    val d = upper.dir(P3.Z).let { P3(it.x, 0.0, it.z).norm() }
                    val e2 = shoulder[i] + (target - d * foreArm - shoulder[i]).norm() * upperArm
                    el = el.lerp(e2, rig.foreLevel)
                    wr = el + ((e2 + d * foreArm - el).norm().lerp((target - el).norm(), 1 - rig.foreLevel)).norm() * foreArm
                }
                if (rig.elbowUp > 0.01) {
                    // the elbow lifted to where the pose wants it, the forearm reaching from there to the hand
                    val lifted = (map(rig.elbowAt) - shoulder[i]).norm()
                    val d = (el - shoulder[i]).norm().lerp(lifted, rig.elbowUp).norm()
                    el = shoulder[i] + d * upperArm
                    wr = el + (target - el).norm() * foreArm
                }
                e[i] = el; w[i] = wr
            }
            val fore = (w[1] - e[1]).norm()
            var t = thumbOf(e[1], w[1], shoulder[1], 1)
            if (rig.aim > 0.01) {
                // the forearm turns so the weapon lies where the pose wants it; the grip angle stays the same
                val want = dir(rig.weapon).let { it - fore * (it dot fore) }
                if (want.len() > 1e-6) t = t.lerp(want.norm(), rig.aim).norm()
            }
            thumbR = t
            val ga = Math.toRadians(rig.grip)
            val held = (fore * kotlin.math.cos(ga) + t * kotlin.math.sin(ga)).norm()
            weapon = if (rig.aim > 0.01) held.lerp(dir(rig.weapon), rig.aim).norm() else held
            run {
                val i = 0
                val handR = w[1] + fore * (0.035 * height * handK)
                var target = lAt
                var pole = if (shieldArm) P3(-1.0, -0.5, 0.35) else if (rig.stock > 0.01) P3(-0.3, -1.0, -0.2) else P3(-0.6, -1.0, -0.5)
                if (twoHands) {
                    // both hands on the grip, the free one below the weapon hand, unless it lets go to cast
                    target = (handR - weapon * (0.06 * height)).lerp(target, rig.freeHand)
                }
                var (el, wr) = ik(shoulder[i], target, upperArm, foreArm, pole)
                if (twoHands && rig.brace > 0.01) {
                    // the free forearm braced against the back of the weapon, a good shoulder's width from the grip
                    // towards its head: it crosses the weapon from behind, so the blow or the bite is taken on both arms
                    val toFoe = upper.dir(P3.Z).let { it - weapon * (it dot weapon) }.norm()
                    val upright = upper.dir(P3.Y).let { it - weapon * (it dot weapon) }.norm()
                    val contact = handR + weapon * (min(weaponReach * 0.48, upperArm + foreArm * 0.9)) - toFoe * (0.01 * height)
                    val (e2, w2) = ik(shoulder[i], contact + upright * (foreArm * 0.3), upperArm, foreArm, P3(-1.0, -0.7, -0.3))
                    el = el.lerp(e2, rig.brace); wr = wr.lerp(w2, rig.brace)
                }
                e[i] = el; w[i] = wr
            }
            knee = k; elbow = e; wrist = w
        }
        private fun thumbOf(el: P3, wr: P3, sh: P3, i: Int): P3 {
            val fore = (wr - el).norm()
            fun perp(v: P3) = v - fore * (v dot fore)
            val back = perp(sh - el)
            val up = perp(upper.dir(P3.Y))
            val bent = back.len() / (sh - el).len().coerceAtLeast(1e-6)
            var t = (back.norm() * bent + up.norm() * (1 - bent)).let { if (it.len() < 1e-6) up.norm() else it.norm() }
            // the forearm may turn about itself without the grip changing; outwards is away from the body's middle
            val roll = if (i == 1) rig.roll else 0.0
            if (abs(roll) > 0.01) {
                val side = fore cross t
                val out = if ((side dot upper.dir(P3(side(i), 0.0, 0.0))) >= 0) 1.0 else -1.0
                val a = Math.toRadians(roll) * out
                t = (t * kotlin.math.cos(a) + side * kotlin.math.sin(a)).norm()
            }
            return t
        }
        /** The hand's thumb side, for how the fist is turned. */
        fun thumb(i: Int): P3 = if (i == 1) thumbR else thumbOf(elbow[i], wrist[i], shoulder[i], i)
        val shieldFace = dir(rig.shieldFace)
        fun side(i: Int) = if (i == 0) -1.0 else 1.0
        fun hand(i: Int): P3 = wrist[i] + (wrist[i] - elbow[i]).norm() * (0.035 * height * handK)
    }

    /** Two-bone reach: where the middle joint bends towards [pole], and the end, pulled in if out of reach. */
    fun ik(a: P3, t: P3, l1: Double, l2: Double, pole: P3): Pair<P3, P3> {
        var d = t - a
        var dist = d.len()
        val max = l1 + l2 - 0.3
        if (dist > max) { d = d * (max / dist); dist = max }
        if (dist < 1e-3) return Pair(a + pole.norm() * l1, a)
        val end = a + d
        val dn = d.norm()
        val aa = (l1 * l1 - l2 * l2 + dist * dist) / (2 * dist)
        val hh = sqrt((l1 * l1 - aa * aa).coerceAtLeast(0.0))
        val perp = (pole - dn * (pole dot dn)).norm()
        return Pair(a + dn * aa + perp * hh, end)
    }

    // ---------------------------------------------------------------- the body

    fun body(sk: Skeleton): List<Solid> {
        if (bones) return boneBody(sk)
        val out = mutableListOf<Solid>()
        val h = height
        val g = girth
        val l = limbK
        fun up(c: P3, r: P3, part: BodyPart, key: String, f: Frame = Frame.IDENTITY) =
            Ellipsoid(sk.upper.apply(c), r, sk.upper.frame(f), part, TRUNK).also { it.key = key; it.rest = sk.upper::inverse; out += it }
        fun low(c: P3, r: P3, part: BodyPart, key: String) =
            Ellipsoid(sk.lower.apply(c), r, Frame.IDENTITY, part, TRUNK).also { it.key = key; it.rest = sk.lower::inverse; out += it }
        fun cone(a: P3, b: P3, ra: Double, rb: Double, part: BodyPart, group: Int, key: String) = RoundCone(a, b, ra, rb, part, group).also { it.key = key; out += it }
        fun ell(c: P3, r: P3, part: BodyPart, group: Int, key: String, f: Frame = Frame.IDENTITY) = Ellipsoid(c, r, f, part, group).also { it.key = key; out += it }

        // trunk
        up(P3(0.0, shoulderY - 0.33 * trunk, 0.0), P3(0.78 * shoulderX, 0.37 * trunk, chestDepth), BodyPart.TORSO, "torso")
        if (female) for (s in listOf(-1.0, 1.0)) up(P3(s * 0.36 * shoulderX, shoulderY - 0.32 * trunk, 0.038 * h * g), P3(0.27 * shoulderX, 0.13 * trunk, 0.036 * h * g), BodyPart.TORSO, "torso")
        else up(P3(0.0, shoulderY - 0.21 * trunk, 0.022 * h * g), P3(0.72 * shoulderX, 0.17 * trunk, 0.05 * h * g), BodyPart.TORSO, "torso")
        val waistK = (if (female) 0.84 else 1.0) * (if (race == Race.DWARF) 1.15 else 1.0)
        up(P3(0.0, hipY + 0.45 * trunk, 0.004 * h), P3(0.63 * shoulderX * waistK, 0.30 * trunk, 0.058 * h * g), BodyPart.TORSO, "waist")
        low(P3(0.0, hipY + 0.10 * trunk, -0.004 * h), P3(1.75 * hipX, 0.22 * trunk, 0.064 * h * g), BodyPart.PELVIS, "pelvis")
        for (s in listOf(-1.0, 1.0)) low(P3(s * 0.75 * hipX, hipY + 0.03 * trunk, -0.022 * h * g), P3(0.82 * hipX, 0.12 * trunk, 0.032 * h * g), BodyPart.PELVIS, "pelvis")
        for (i in 0..1) {
            val s = sk.side(i)
            // the deltoid: rounded over the top of the arm, tapering down along it
            // collarbone and shoulder cap: a bridge from the trunk to wherever the shoulder joint has moved, so the arm
            // never comes loose from the body
            cone(sk.shoulderRest[i] + sk.upper.dir(P3(-s * 0.02 * h, 0.014 * h, 0.0)), sk.shoulder[i] + sk.upper.dir(P3(0.0, 0.01 * h, 0.0)), 0.03 * h * g, 0.028 * h * l, BodyPart.TORSO, TRUNK, "torso")
                .also { it.rest = sk.upper::inverse }
            // the deltoid: a cap over the shoulder joint, tapering down to where it grips the upper arm a third of the way
            // along; it hugs the arm instead of bulging past it
            val armDir = (sk.elbow[i] - sk.shoulder[i]).norm()
            val cap = sk.shoulder[i] + sk.upper.dir(P3(s * 0.004 * h, 0.012 * h, 0.0))
            val insertion = sk.shoulder[i] + armDir * (upperArm * 0.42)
            cone(cap, insertion, 0.03 * h * l, 0.021 * h * l, BodyPart.ARM, if (i == 0) ARM_L else ARM_R, "delt$i")
        }
        // the upper back: a broad flat trapezius from the neck out to the shoulders, and the shoulder blades under it,
        // so the back is wide up top and the arms come out of muscle, not out of a bare tube
        for (i in 0..1) {
            val s = sk.side(i); val lf = sk.lift[i]
            // each half of the trapezius reaches out to the shoulder; when the arm rises the deltoid takes over the outline
            val reachOut = 0.82 - 0.2 * lf
            up(P3(s * reachOut * shoulderX * 0.45, shoulderY + 0.002 * h, -0.016 * h * g), P3(reachOut * shoulderX * 0.55, 0.032 * h, 0.04 * h * g), BodyPart.TORSO, "torso")
            // the shoulder blade swings up and out as the arm rises; its outer corner rides on the shoulder
            up(P3(s * (0.45 + 0.08 * lf) * shoulderX, shoulderY - (0.16 - 0.08 * lf) * trunk, -0.034 * h * g), P3(0.34 * shoulderX, 0.22 * trunk, 0.03 * h * g), BodyPart.TORSO, "torso",
                Frame(P3(1.0, s * 0.45 * lf, 0.0).norm(), P3(-s * 0.45 * lf, 1.0, 0.0).norm(), P3.Z))
        }
        cone(sk.upper.apply(P3(0.0, shoulderY + 0.012 * h, -0.006 * h)), sk.upper.apply(P3(0.0, chinY + 0.025 * h, 0.004 * h)),
            0.034 * h * sqrt(g), 0.029 * h * sqrt(g) * (if (female) 0.88 else 1.0), BodyPart.NECK, TRUNK, "neck")

        // arms
        for (i in 0..1) {
            val s = sk.side(i)
            val grp = if (i == 0) ARM_L else ARM_R
            val sh = sk.shoulder[i]; val el = sk.elbow[i]; val wr = sk.wrist[i]
            cone(sh, el, 0.029 * h * l, 0.02 * h * l, BodyPart.ARM, grp, "upper$i")
            // biceps in front, swelling as the elbow bends, and the triceps behind: the upper arm reads as muscle
            val ua = (el - sh).norm()
            val fa = (wr - el).norm()
            val flex = (1 - (ua dot fa)).coerceIn(0.0, 1.0)
            val front = (fa - ua * (fa dot ua)).let { if (it.len() < 0.15) sk.upper.dir(P3.Z).let { z -> z - ua * (z dot ua) } else it }.norm()
            val uLen = (el - sh).len()
            ell(sh + ua * (uLen * 0.56) + front * (0.011 * h * l), P3(0.019 * h * l * (1 + 0.18 * flex), uLen * 0.27, 0.017 * h * l * (1 + 0.25 * flex)), BodyPart.ARM, grp, "upper$i", Frame.along(ua, front))
            ell(sh + ua * (uLen * 0.42) - front * (0.008 * h * l), P3(0.018 * h * l, uLen * 0.3, 0.016 * h * l), BodyPart.ARM, grp, "upper$i", Frame.along(ua, front))
            cone(el, wr, 0.022 * h * l, 0.015 * h * l, BodyPart.ARM, grp, "fore$i")
            ell(el.lerp(wr, 0.28), P3(0.022 * h * l, 0.06 * h, 0.02 * h * l), BodyPart.ARM, grp, "fore$i", Frame.along(wr - el))
            val dir = (wr - el).norm()
            val hf = Frame.along(dir, sk.thumb(i))
            if (sk.fists) ell(wr + dir * (0.03 * h * handK), P3(0.026 * h * handK, 0.034 * h * handK, 0.022 * h * handK), BodyPart.HAND, grp, "hand$i", hf)
            else ell(wr + dir * (0.045 * h * handK), P3(0.029 * h * handK, 0.054 * h * handK, 0.014 * h * handK), BodyPart.HAND, grp, "hand$i", hf)
        }

        // legs
        for (i in 0..1) {
            val s = sk.side(i)
            val hip = sk.hip[i]; val knee = sk.knee[i]; val ankle = sk.ankle[i]
            val thighLen = (knee - hip).len()
            val thighDir = (knee - hip).norm()
            val lg = if (i == 0) LEG_L else LEG_R
            cone(hip, knee, 0.048 * h * l * (if (female) 1.06 else 1.0), 0.029 * h * l, BodyPart.THIGH, lg, "thigh$i")
                .also { it.paint = { p -> if (((p - hip) dot thighDir) < 0.3 * thighLen) shortsMat else skinMat } }
            val shinDir = (ankle - knee).norm()
            val front = (shinDir cross P3.X).let { if (it.z < 0) -it else it }.norm()
            ell(knee + front * (0.006 * h), P3(0.028 * h * l, 0.03 * h, 0.026 * h * l), BodyPart.SHIN, lg, "knee$i", Frame.along(shinDir))
            cone(knee, ankle, 0.026 * h * l, 0.016 * h * l, BodyPart.SHIN, lg, "shin$i")
            ell(knee.lerp(ankle, 0.3) - front * (0.012 * h * l), P3(0.03 * h * l, 0.075 * h, 0.03 * h * l), BodyPart.SHIN, lg, "shin$i", Frame.along(shinDir))
            // heel, arch and toes: narrow at the heel, wider over the ball, low at the front
            val fw = P3(s * 0.08, 0.0, 1.0).norm()
            val heel = ankle + P3(0.0, -0.026 * h, 0.0) - fw * (0.016 * h)
            val ball = ankle + P3(0.0, -0.034 * h, 0.0) + fw * (0.07 * h * footK)
            val toe = ankle + P3(0.0, -0.038 * h, 0.0) + fw * (0.1 * h * footK)
            cone(heel, ball, 0.016 * h * footK, 0.017 * h * footK, BodyPart.FOOT, lg, "foot$i")
            cone(ball, toe, 0.016 * h * footK, 0.011 * h * footK, BodyPart.FOOT, lg, "foot$i")
            ell(ankle.lerp(ball, 0.45) + P3(0.0, -0.008 * h, 0.0), P3(0.019 * h * footK, 0.017 * h, 0.04 * h * footK), BodyPart.FOOT, lg, "foot$i", Frame.along(fw, P3.Y).let { Frame(it.x, it.z, it.y) })
            for (side in listOf(-1.0, 1.0)) ell(ankle + P3(side * 0.012 * h, 0.0, 0.0), P3(0.008 * h, 0.01 * h, 0.009 * h), BodyPart.FOOT, lg, "ankle$i")
        }

        head(sk, out)
        return out
    }

    private fun head(sk: Skeleton, out: MutableList<Solid>) {
        if (goblin) { goblinHead(sk, out); return }
        val c = headC
        val k = hh
        val hx = sk.head
        fun place(s: Solid, key: String) { s.key = key; s.rest = hx::inverse; out += s }
        fun ell(at: P3, r: P3, part: BodyPart = BodyPart.HEAD, group: Int = HEAD, key: String = "head") =
            place(Ellipsoid(hx.apply(c + at), r, hx.frame(Frame.IDENTITY), part, group), key)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, part: BodyPart = BodyPart.HEAD, group: Int = HEAD, key: String = "head") =
            place(RoundCone(hx.apply(c + a), hx.apply(c + b), ra, rb, part, group), key)
        val wide = when (race) { Race.DWARF -> 1.08; Race.HALF_ORC -> 1.06; Race.ELF -> 0.93; else -> 1.0 } * (if (female) 0.96 else 1.0)
        val jaw = when (race) { Race.HALF_ORC -> 1.25; Race.DWARF -> 1.12; Race.ELF -> 0.9; else -> 1.0 } * (if (female) 0.9 else 1.0)
        val skull = P3(0.34 * k * wide, 0.46 * k, 0.43 * k)
        val skullC = P3(0.0, 0.06 * k, -0.03 * k)
        ell(skullC, skull, key = "skull")
        ell(P3(0.0, -0.2 * k, 0.08 * k), P3(0.27 * k * jaw, 0.27 * k, 0.32 * k), key = "jaw")
        val nose = when (race) { Race.DWARF -> P3(0.075, 0.14, 0.1); Race.HALF_ORC -> P3(0.085, 0.11, 0.075); Race.ELF -> P3(0.045, 0.11, 0.07); else -> P3(0.055, 0.12, 0.08) }
        ell(P3(0.0, -0.08 * k, 0.37 * k), nose * k)
        val brow = if (race == Race.HALF_ORC) 1.35 else if (race == Race.DWARF) 1.15 else 1.0
        ell(P3(0.0, 0.1 * k, 0.29 * k), P3(0.27 * k, 0.06 * k * brow, 0.1 * k * brow))
        for (s in listOf(-1.0, 1.0)) when (race) {
            Race.ELF -> cone(P3(s * 0.32 * k, -0.04 * k, -0.03 * k), P3(s * 0.54 * k, 0.34 * k, -0.17 * k), 0.07 * k, 0.014 * k, key = "ear")
            Race.HALFLING -> cone(P3(s * 0.32 * k, -0.04 * k, -0.03 * k), P3(s * 0.44 * k, 0.17 * k, -0.08 * k), 0.07 * k, 0.022 * k, key = "ear")
            Race.HALF_ORC -> cone(P3(s * 0.33 * k, -0.04 * k, -0.03 * k), P3(s * 0.43 * k, 0.1 * k, -0.06 * k), 0.065 * k, 0.025 * k, key = "ear")
            else -> ell(P3(s * 0.34 * k, -0.03 * k, -0.02 * k), P3(0.05 * k, 0.12 * k, 0.08 * k), key = "ear")
        }
        if (race == Race.HALF_ORC) for (s in listOf(-1.0, 1.0)) cone(P3(s * 0.12 * k, -0.3 * k, 0.3 * k), P3(s * 0.15 * k, -0.15 * k, 0.37 * k), 0.035 * k, 0.012 * k, BodyPart.TUSK, TUSK, "tusk")

        // hair: a cap over the skull, cut away from the face and, when short, above the ears
        val cap = Ellipsoid(hx.apply(c + skullC), skull + P3(0.05 * k, 0.05 * k, 0.05 * k), hx.frame(Frame.IDENTITY), BodyPart.HAIR, HAIR)
        val n1 = P3(0.0, -0.45, 0.89).norm()
        cap.cut(hx.dir(n1), hx.apply(c + n1 * (0.17 * k)))
        val long = female || race == Race.ELF
        if (!long) cap.cut(hx.dir(P3(0.0, -1.0, 1.2)), hx.apply(c))
        place(cap, "hair")
        val backZ = -(chestDepth + 0.01 * height)
        if (female) {
            // hair falling over the back to the shoulder blades
            place(RoundCone(hx.apply(c + P3(0.0, -0.05 * k, -0.28 * k)), sk.upper.apply(P3(0.0, shoulderY - 0.07 * height, backZ * 0.9)), 0.31 * k, 0.2 * k, BodyPart.HAIR, HAIR)
                .cut(sk.upper.dir(P3.Z), sk.upper.apply(c + P3(0.0, 0.0, 0.05 * k))), "hair")
        } else if (race == Race.ELF) {
            place(RoundCone(hx.apply(c + P3(0.0, -0.05 * k, -0.28 * k)), sk.upper.apply(P3(0.0, chinY - 0.02 * height, backZ * 0.6)), 0.31 * k, 0.24 * k, BodyPart.HAIR, HAIR)
                .cut(sk.upper.dir(P3.Z), sk.upper.apply(c)), "hair")
        }
        if (race == Race.DWARF && !female) {
            // a full beard over jaw and chest, with a moustache
            place(Ellipsoid(hx.apply(c + P3(0.0, -0.34 * k, 0.2 * k)), P3(0.32 * k, 0.3 * k, 0.24 * k), hx.frame(Frame.IDENTITY), BodyPart.HAIR, HAIR)
                .cut(hx.dir(P3.Y), hx.apply(c + P3(0.0, -0.24 * k, 0.0))), "beard")
            place(RoundCone(hx.apply(c + P3(0.0, -0.5 * k, 0.24 * k)), hx.apply(c + P3(0.0, -1.3 * k, 0.34 * k)), 0.27 * k, 0.11 * k, BodyPart.HAIR, HAIR), "beard")
            place(Ellipsoid(hx.apply(c + P3(0.0, -0.21 * k, 0.37 * k)), P3(0.17 * k, 0.05 * k, 0.07 * k), hx.frame(Frame.IDENTITY), BodyPart.HAIR, HAIR), "beard")
        }
        if (race == Race.DWARF && female) for (s in listOf(-1.0, 1.0))
            place(RoundCone(hx.apply(c + P3(s * 0.3 * k, -0.2 * k, 0.0)), sk.upper.apply(P3(s * shoulderX * 0.55, shoulderY - 0.12 * height, chestDepth * 0.9)), 0.09 * k, 0.06 * k, BodyPart.HAIR, HAIR), "hair")
    }

    /** Material at a point on the body: skin, hair, or the plain linen underclothes. */
    fun material(s: Solid, p: P3): Mat {
        s.paint?.let { return it(s.restOf(p)) }
        s.mat?.let { return it }
        val q = s.restOf(p)
        val shirtHem = hipY + 0.22 * trunk
        if (bones) return boneMat
        // a goblin goes bare-chested and barefoot, a rag round its loins
        if (goblin) return when (s.part) {
            BodyPart.HAIR -> hairMat
            BodyPart.TUSK -> tuskMat
            BodyPart.PELVIS -> shortsMat
            else -> skinMat
        }
        return when (s.part) {
            BodyPart.HAIR -> hairMat
            BodyPart.TUSK -> tuskMat
            BodyPart.PELVIS -> shortsMat
            BodyPart.FOOT -> footMat
            BodyPart.TORSO -> when {
                q.y < shirtHem -> shortsMat
                // a plain shirt with a round neckline at the front
                q.y > shoulderY - 0.08 * trunk && q.z > 0 && abs(q.x) < 0.3 * shoulderX -> skinMat
                else -> shirtMat
            }
            else -> skinMat
        }
    }

    /** How the groups melt into each other in this pose. */
    fun groups(sk: Skeleton): Groups {
        val g = Groups(GROUPS)
        if (bones) {
            // bones do not melt into each other: only a slight rounding where they meet
            g.reach = 0.02 * height
            for (i in 0 until GROUPS) g.set(i, 0.25)
            g.set(TRUNK, 0.35); g.set(HEAD, 0.3)
            return g
        }
        g.reach = 0.09 * height
        g.set(TRUNK, 4.5); g.set(HEAD, 2.6, TRUNK, sk.head.apply(neckTop))
        g.set(LEG_L, 2.6, TRUNK, sk.hip[0]); g.set(LEG_R, 2.6, TRUNK, sk.hip[1])
        g.set(ARM_L, 1.6, TRUNK, sk.shoulder[0]); g.set(ARM_R, 1.6, TRUNK, sk.shoulder[1])
        g.set(HAIR, 1.6); g.set(TUSK, 0.0)
        g.set(CLOTH, 2.2); g.set(CLOTH_L, 1.4, CLOTH, sk.shoulder[0]); g.set(CLOTH_R, 1.4, CLOTH, sk.shoulder[1])
        g.set(ARMOR, 1.0); g.set(ARMOR_L, 0.8, ARMOR, sk.shoulder[0]); g.set(ARMOR_R, 0.8, ARMOR, sk.shoulder[1])
        g.set(BELT, 0.4); g.set(SKIRT, 7.0); g.set(CLOAK, 1.2); g.set(HELM, 0.8); g.set(SHIELD, 0.0); g.set(ITEM, 0.0); g.set(BOOTS, 1.2); g.set(TRIM, 0.3)
        return g
    }

    // ---------------------------------------------------------------- the face

    /** Eyes, brows and mouth, painted where the face is visible. */
    fun face(img: DepthImage, sk: Skeleton) {
        if (bones) { skullFace(img, sk); return }
        if (goblin) { goblinFace(img, sk); return }
        val hx = sk.head
        fun put(p: P3, c: Int) {
            val q = hx.apply(p)
            if (!img.visible(q, 0.05 * hh + 0.8)) return
            val (x, y, _) = img.project(q)
            img.img.set(x.toInt(), y.toInt(), c)
        }
        fun line(a: P3, b: P3, c: Int) { val n = 2 + (img.px * (b - a).len()).toInt() * 2; for (i in 0..n) put(a.lerp(b, i.toDouble() / n), c) }
        val k = hh
        val c = headC
        val dark = argb(0x18120E)
        val shade = mix(argb(skinRgb), argb(0x3A2418), 0.45)
        val browC = mix(argb(hairRgb), argb(0x18120E), 0.35)
        val white = mix(argb(0xE6DED0), argb(skinRgb), 0.25)
        val eyeY = -0.02 * k
        for (sd in listOf(-1.0, 1.0)) {
            // the socket's shadow under the brow, the eye's white towards the outside, the pupil
            line(c + P3(sd * 0.07 * k, eyeY + 0.035 * k, 0.405 * k), c + P3(sd * 0.21 * k, eyeY + 0.03 * k, 0.35 * k), shade)
            put(c + P3(sd * 0.2 * k, eyeY, 0.36 * k), white)
            put(c + P3(sd * 0.13 * k, eyeY, 0.395 * k), dark)
            line(c + P3(sd * 0.06 * k, 0.085 * k, 0.43 * k), c + P3(sd * 0.23 * k, 0.07 * k, 0.36 * k), browC)
        }
        if (!(race == Race.DWARF && sex == Sex.MALE)) {
            val lip = if (female) mix(argb(skinRgb), argb(0x7A2E2A), 0.5) else mix(argb(skinRgb), argb(0x3A1C18), 0.5)
            line(c + P3(-0.08 * k, -0.27 * k, 0.385 * k), c + P3(0.08 * k, -0.27 * k, 0.385 * k), lip)
        }
        put(c + P3(0.05 * k, -0.15 * k, 0.43 * k), shade)
    }

    // ---------------------------------------------------------------- goblin

    /**
     * A goblin's head: a broad low skull, ears standing far out to the sides and up, a long hooked nose, a heavy brow,
     * a wide jaw with an underbite and two small fangs. No hair but a few strands.
     */
    private fun goblinHead(sk: Skeleton, out: MutableList<Solid>) {
        val c = headC
        val k = hh
        val hx = sk.head
        fun place(s: Solid, key: String) { s.key = key; s.rest = hx::inverse; out += s }
        fun ell(at: P3, r: P3, part: BodyPart = BodyPart.HEAD, key: String = "head") =
            place(Ellipsoid(hx.apply(c + at), r, hx.frame(Frame.IDENTITY), part, HEAD), key)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, part: BodyPart = BodyPart.HEAD, group: Int = HEAD, key: String = "head") =
            place(RoundCone(hx.apply(c + a), hx.apply(c + b), ra, rb, part, group), key)
        val skullC = P3(0.0, 0.08 * k, -0.06 * k)
        ell(skullC, P3(0.4 * k, 0.4 * k, 0.44 * k), key = "skull")
        // cheeks and the wide jaw, pushed forward
        ell(P3(0.0, -0.2 * k, 0.1 * k), P3(0.33 * k, 0.25 * k, 0.33 * k), key = "jaw")
        ell(P3(0.0, -0.3 * k, 0.2 * k), P3(0.25 * k, 0.12 * k, 0.22 * k), key = "jaw")
        // the brow ridge, low over the eyes
        ell(P3(0.0, 0.07 * k, 0.32 * k), P3(0.3 * k, 0.07 * k, 0.11 * k))
        // a long nose hooked down at the tip
        cone(P3(0.0, 0.03 * k, 0.38 * k), P3(0.0, -0.12 * k, 0.66 * k), 0.085 * k, 0.065 * k)
        cone(P3(0.0, -0.12 * k, 0.66 * k), P3(0.0, -0.22 * k, 0.6 * k), 0.065 * k, 0.035 * k)
        for (s in listOf(-1.0, 1.0)) {
            // the ears: wide at the head, out to the side and up and back to a point
            cone(P3(s * 0.36 * k, -0.02 * k, -0.04 * k), P3(s * 0.62 * k, 0.12 * k, -0.12 * k), 0.12 * k, 0.07 * k, key = "ear")
            cone(P3(s * 0.62 * k, 0.12 * k, -0.12 * k), P3(s * 0.98 * k, 0.32 * k, -0.22 * k), 0.07 * k, 0.012 * k, key = "ear")
            // two lower fangs over the upper lip
            cone(P3(s * 0.13 * k, -0.36 * k, 0.33 * k), P3(s * 0.14 * k, -0.24 * k, 0.37 * k), 0.028 * k, 0.008 * k, BodyPart.TUSK, TUSK, "tusk")
        }
        // a few lank strands on top of the skull
        place(RoundCone(hx.apply(c + P3(0.0, 0.42 * k, -0.1 * k)), hx.apply(c + P3(0.06 * k, 0.3 * k, -0.42 * k)), 0.1 * k, 0.03 * k, BodyPart.HAIR, HAIR), "hair")
    }

    /** Small yellow eyes under the brow, a wide grim mouth. */
    private fun goblinFace(img: DepthImage, sk: Skeleton) {
        val hx = sk.head
        fun put(p: P3, col: Int) {
            val q = hx.apply(p)
            if (!img.visible(q, 0.05 * hh + 0.8)) return
            val (x, y, _) = img.project(q)
            img.img.set(x.toInt(), y.toInt(), col)
        }
        fun line(a: P3, b: P3, col: Int) { val n = 2 + (img.px * (b - a).len()).toInt() * 2; for (i in 0..n) put(a.lerp(b, i.toDouble() / n), col) }
        val k = hh; val c = headC
        val shade = mix(argb(skinRgb), argb(0x1A1A0E), 0.55)
        for (sd in listOf(-1.0, 1.0)) {
            // deep-set under the brow: a shadow, then a narrow yellow eye with a dark slit
            line(c + P3(sd * 0.07 * k, 0.03 * k, 0.4 * k), c + P3(sd * 0.27 * k, 0.04 * k, 0.32 * k), shade)
            line(c + P3(sd * 0.1 * k, -0.01 * k, 0.39 * k), c + P3(sd * 0.22 * k, 0.0, 0.35 * k), argb(0xE8B828))
            put(c + P3(sd * 0.15 * k, -0.01 * k, 0.38 * k), argb(0x1A0C04))
        }
        // a snarl: the mouth pulled open, a row of crooked yellow teeth, the fangs at its corners
        line(c + P3(-0.2 * k, -0.28 * k, 0.37 * k), c + P3(0.2 * k, -0.28 * k, 0.37 * k), argb(0x1E0E0A))
        line(c + P3(-0.17 * k, -0.33 * k, 0.36 * k), c + P3(0.17 * k, -0.33 * k, 0.36 * k), argb(0x3A1410))
        for (t in -3..3) put(c + P3(t * 0.045 * k, -0.3 * k, 0.375 * k), if (t % 2 == 0) argb(0xC8B880) else argb(0x9A8A58))
        // an old scar down over the left eye
        line(c + P3(-0.2 * k, 0.16 * k, 0.33 * k), c + P3(-0.1 * k, -0.12 * k, 0.4 * k), mix(argb(skinRgb), argb(0xC09A80), 0.5))
    }

    // ---------------------------------------------------------------- skeleton

    /**
     * Bare bones on the same joints: a skull with its jaw, the spine, a cage of ribs bowed round from the spine to
     * the breastbone, collarbones and shoulder blades, the pelvis, and the long bones of arms and legs with knobs at
     * their ends. Bones are drawn somewhat thicker than real ones, so they read at a few pixels.
     */
    private fun boneBody(sk: Skeleton): List<Solid> {
        val out = mutableListOf<Solid>()
        val h = height
        val b = 0.009 * h
        fun cone(a: P3, e: P3, ra: Double, rb: Double, part: BodyPart, group: Int, key: String) = RoundCone(a, e, ra, rb, part, group).also { it.key = key; out += it }
        fun ell(c: P3, r: P3, part: BodyPart, group: Int, key: String, f: Frame = Frame.IDENTITY) = Ellipsoid(c, r, f, part, group).also { it.key = key; out += it }
        fun up(c: P3) = sk.upper.apply(c)
        fun low(c: P3) = sk.lower.apply(c)
        fun upEll(c: P3, r: P3, key: String, part: BodyPart = BodyPart.TORSO) =
            Ellipsoid(up(c), r, sk.upper.frame(Frame.IDENTITY), part, TRUNK).also { it.key = key; it.rest = sk.upper::inverse; out += it }
        val depth = 0.06 * h
        val ribX = 0.72 * shoulderX
        // the spine, from the pelvis up to the skull: a row of knobs
        val spineN = 12
        for (i in 0..spineN) {
            val t = i.toDouble() / spineN
            val y = hipY + 0.05 * trunk + t * (chinY + 0.02 * h - hipY - 0.05 * trunk)
            val z = -depth * (0.55 + 0.25 * kotlin.math.sin(t * Math.PI))
            upEll(P3(0.0, y, z), P3(b * 1.25, b * 0.8, b * 1.15), if (t > 0.85) "neck" else "torso", if (t > 0.85) BodyPart.NECK else BodyPart.TORSO)
        }
        // the ribs: each bowed round from the spine, out to the side and in to the breastbone, the lower ones shorter
        val ribs = 7
        for (j in 0 until ribs) {
            val t = j.toDouble() / (ribs - 1)
            val y = shoulderY - 0.1 * trunk - t * 0.42 * trunk
            val wide = ribX * (0.78 + 0.3 * kotlin.math.sin((t * 0.8 + 0.15) * Math.PI))
            val front = depth * (0.95 - 0.25 * t)
            for (s in listOf(-1.0, 1.0)) {
                val pts = listOf(
                    P3(s * 0.02 * h, y + 0.012 * h, -depth * 0.7), P3(s * wide * 0.75, y + 0.01 * h, -depth * 0.6),
                    P3(s * wide, y - 0.005 * h, 0.0), P3(s * wide * 0.8, y - 0.025 * h, front * 0.7),
                    P3(s * wide * 0.3 * (1 - t * 0.5), y - 0.035 * h, front),
                )
                for (q in 0 until pts.size - 1) cone(up(pts[q]), up(pts[q + 1]), b * 0.75, b * 0.7, BodyPart.TORSO, TRUNK, "torso").also { it.rest = sk.upper::inverse }
            }
        }
        // the breastbone, the collarbones and the shoulder blades
        cone(up(P3(0.0, shoulderY - 0.07 * trunk, depth * 0.98)), up(P3(0.0, shoulderY - 0.52 * trunk, depth * 0.85)), b * 1.2, b * 0.9, BodyPart.TORSO, TRUNK, "torso").also { it.rest = sk.upper::inverse }
        for (i in 0..1) {
            val s = sk.side(i)
            cone(up(P3(s * 0.02 * h, shoulderY - 0.04 * trunk, depth * 0.95)), sk.shoulder[i] + sk.upper.dir(P3(0.0, 0.006 * h, 0.01 * h)), b, b * 0.9, BodyPart.TORSO, TRUNK, "torso")
            upEll(P3(s * 0.5 * shoulderX, shoulderY - 0.17 * trunk, -depth * 0.85), P3(0.22 * shoulderX, 0.17 * trunk, b * 0.7), "torso")
        }
        // the pelvis: two wings of the hip bones and the sacrum, the hip joints below them
        for (s in listOf(-1.0, 1.0))
            Ellipsoid(low(P3(s * 0.85 * hipX, hipY + 0.11 * trunk, -0.01 * h)), P3(0.75 * hipX, 0.12 * trunk, b * 1.4), Frame(P3(1.0, 0.0, s * 0.5).norm(), P3.Y, P3(-s * 0.5, 0.0, 1.0).norm()), BodyPart.PELVIS, TRUNK)
                .also { it.key = "pelvis"; it.rest = sk.lower::inverse; out += it }
        Ellipsoid(low(P3(0.0, hipY + 0.06 * trunk, -0.03 * h)), P3(0.5 * hipX, 0.11 * trunk, b * 1.6), Frame.IDENTITY, BodyPart.PELVIS, TRUNK).also { it.key = "pelvis"; it.rest = sk.lower::inverse; out += it }
        Ellipsoid(low(P3(0.0, hipY - 0.01 * trunk, 0.025 * h)), P3(0.7 * hipX, 0.035 * trunk, b * 1.2), Frame.IDENTITY, BodyPart.PELVIS, TRUNK).also { it.key = "pelvis"; it.rest = sk.lower::inverse; out += it }
        // arms: the upper arm bone, the two of the forearm side by side, a small hand of bones
        for (i in 0..1) {
            val grp = if (i == 0) ARM_L else ARM_R
            val sh = sk.shoulder[i]; val el = sk.elbow[i]; val wr = sk.wrist[i]
            ell(sh, P3(b * 1.9, b * 1.9, b * 1.9), BodyPart.ARM, grp, "delt$i")
            cone(sh, el, b * 1.2, b * 1.05, BodyPart.ARM, grp, "upper$i")
            ell(el, P3(b * 1.5, b * 1.5, b * 1.5), BodyPart.ARM, grp, "upper$i")
            val dir = (wr - el).norm()
            val across = (dir cross sk.thumb(i)).norm()
            for (q in listOf(-1.0, 1.0)) cone(el + across * (q * b * 0.6), wr + across * (q * b * 0.9), b * 0.75, b * 0.7, BodyPart.ARM, grp, "fore$i")
            val hf = Frame.along(dir, sk.thumb(i))
            ell(wr + dir * (0.022 * h), P3(0.02 * h, 0.024 * h, b * 0.9), BodyPart.HAND, grp, "hand$i", hf)
            for (f in -1..2) cone(wr + dir * (0.035 * h) + across * (f * b * 0.9), wr + dir * (0.07 * h) + across * (f * b * 0.8) + sk.thumb(i) * (-0.01 * h), b * 0.45, b * 0.35, BodyPart.HAND, grp, "hand$i")
        }
        // legs: thigh bone, kneecap, the two shin bones, the bones of the foot
        for (i in 0..1) {
            val s = sk.side(i)
            val lg = if (i == 0) LEG_L else LEG_R
            val hip = sk.hip[i]; val knee = sk.knee[i]; val ankle = sk.ankle[i]
            ell(hip, P3(b * 1.8, b * 1.8, b * 1.8), BodyPart.THIGH, lg, "thigh$i")
            cone(hip, knee, b * 1.4, b * 1.2, BodyPart.THIGH, lg, "thigh$i")
            val shinDir = (ankle - knee).norm()
            val front = (shinDir cross P3.X).let { if (it.z < 0) -it else it }.norm()
            ell(knee + front * (b * 1.2), P3(b * 1.5, b * 1.6, b * 1.1), BodyPart.SHIN, lg, "knee$i", Frame.along(shinDir))
            ell(knee, P3(b * 1.7, b * 1.4, b * 1.6), BodyPart.SHIN, lg, "knee$i")
            cone(knee, ankle, b * 1.15, b * 0.95, BodyPart.SHIN, lg, "shin$i")
            cone(knee + P3(s * b * 1.4, 0.0, -b), ankle + P3(s * b * 1.2, 0.0, -b * 0.5), b * 0.6, b * 0.55, BodyPart.SHIN, lg, "shin$i")
            val fw = P3(s * 0.08, 0.0, 1.0).norm()
            val heel = ankle + P3(0.0, -0.026 * h, 0.0) - fw * (0.012 * h)
            ell(ankle, P3(b * 1.4, b * 1.3, b * 1.4), BodyPart.FOOT, lg, "foot$i")
            cone(heel, ankle + P3(0.0, -0.03 * h, 0.0) + fw * (0.05 * h), b * 1.2, b, BodyPart.FOOT, lg, "foot$i")
            for (f in -1..1) cone(ankle + P3(f * b * 1.1, -0.03 * h, 0.0) + fw * (0.05 * h), ankle + P3(f * b * 1.6, -0.038 * h, 0.0) + fw * (0.1 * h), b * 0.55, b * 0.45, BodyPart.FOOT, lg, "foot$i")
        }
        skull(sk, out)
        return out
    }

    /** The skull: the brain case, cheekbones, the upper jaw and the lower one hanging a little open. */
    private fun skull(sk: Skeleton, out: MutableList<Solid>) {
        val c = headC
        val k = hh
        val hx = sk.head
        fun place(s: Solid, key: String) { s.key = key; s.rest = hx::inverse; out += s }
        fun ell(at: P3, r: P3, key: String = "head") = place(Ellipsoid(hx.apply(c + at), r, hx.frame(Frame.IDENTITY), BodyPart.HEAD, HEAD), key)
        ell(P3(0.0, 0.08 * k, -0.04 * k), P3(0.33 * k, 0.42 * k, 0.43 * k), "skull")
        // the face narrows below the eyes: cheekbones, the upper jaw with its teeth
        for (s in listOf(-1.0, 1.0)) ell(P3(s * 0.22 * k, -0.1 * k, 0.22 * k), P3(0.1 * k, 0.08 * k, 0.12 * k))
        ell(P3(0.0, -0.2 * k, 0.24 * k), P3(0.2 * k, 0.12 * k, 0.16 * k))
        // the lower jaw, a little open
        place(RoundCone(hx.apply(c + P3(0.0, -0.38 * k, 0.24 * k)), hx.apply(c + P3(0.0, -0.3 * k, 0.05 * k)), 0.12 * k, 0.17 * k, BodyPart.HEAD, HEAD), "jaw")
        for (s in listOf(-1.0, 1.0)) place(RoundCone(hx.apply(c + P3(s * 0.22 * k, -0.28 * k, 0.02 * k)), hx.apply(c + P3(s * 0.24 * k, -0.05 * k, -0.04 * k)), 0.05 * k, 0.04 * k, BodyPart.HEAD, HEAD), "jaw")
    }

    /** Deep dark sockets, the hole of the nose, and the teeth in both jaws. */
    private fun skullFace(img: DepthImage, sk: Skeleton) {
        val hx = sk.head
        fun put(p: P3, col: Int) {
            val q = hx.apply(p)
            if (!img.visible(q, 0.06 * hh + 0.8)) return
            val (x, y, _) = img.project(q)
            img.img.set(x.toInt(), y.toInt(), col)
        }
        val k = hh; val c = headC
        val dark = argb(0x140E0A)
        // the sockets: a disc of darkness each, a faint ember deep inside
        for (sd in listOf(-1.0, 1.0)) {
            val e = c + P3(sd * 0.14 * k, 0.0, 0.38 * k)
            val n = 6
            for (yy in -n..n) for (xx in -n..n) {
                val dx = xx / n.toDouble(); val dy = yy / n.toDouble()
                if (dx * dx + dy * dy <= 1.0) put(e + P3(dx * 0.1 * k, dy * 0.09 * k, -0.02 * k * (1 - dx * dx - dy * dy)), dark)
            }
            put(e + P3(0.0, 0.0, -0.02 * k), argb(0x8A2A14))
        }
        // the nose: a dark notch
        for (t in 0..4) put(c + P3((t % 2 - 0.5) * 0.03 * k, -0.11 * k - t * 0.012 * k, 0.4 * k), dark)
        // teeth: a row of light and dark between the jaws
        for (t in -4..4) {
            val x = t * 0.035 * k
            put(c + P3(x, -0.29 * k, 0.37 * k), if (t % 2 == 0) argb(0x3A3026) else argb(0xE6DCC2))
            put(c + P3(x, -0.33 * k, 0.35 * k), if (t % 2 != 0) argb(0x3A3026) else argb(0xDCD2B8))
        }
    }

    // ---------------------------------------------------------------- rendering

    /**
     * Renders the doll in [rig] (its yaw: 0 faces us, 90 shows its right side, 180 its back) into a picture of
     * [w]×[h] pixels, feet at ([anchorX], [ground]), [px] pixels per centimetre, dressed in [outfit].
     */
    // ---------------------------------------------------------------- wounds

    private val bloodMat = Mat(Ramp.of(argb(0xB4231A), sat = 1.0), shine = 0.35, grain = 0.12, bias = 0.05)
    private val bloodDark = Mat(Ramp.of(argb(0x6E140E), sat = 1.0), shine = 0.4, grain = 0.1)

    /** Where the wounds sit on the trunk, in its rest space: side (fraction of the shoulders), height up the trunk, front or back. */
    private class Wound(val x: Double, val y: Double, val front: Boolean, val r: Double)
    private val WOUNDS = listOf(
        Wound(0.35, 0.74, true, 1.0), Wound(-0.5, 0.42, true, 0.8), Wound(0.3, 0.6, false, 0.9),
        Wound(0.05, 0.28, true, 0.9), Wound(-0.32, 0.82, true, 0.7), Wound(-0.4, 0.34, false, 1.0), Wound(0.62, 0.4, true, 0.7),
    )

    /**
     * Blood on the trunk and what is worn over it, at fixed places so it moves with the body: three stains when hurt
     * ([level] 1), seven and darker when badly hurt (2). Arms and legs stay clean, so stains never slide over a limb.
     */
    private fun woundAt(sk: Skeleton, s: Solid, p: P3, level: Int): Mat? {
        if (level <= 0 || s.group !in WOUNDABLE) return null
        val q = sk.upper.inverse(p)
        val fy = (q.y - hipY) / trunk
        if (fy < 0.1 || fy > 1.0) return null
        val n = if (level >= 2) WOUNDS.size else 3
        for (i in 0 until n) {
            val wd = WOUNDS[i]
            if ((q.z > 0) != wd.front) continue
            val dx = q.x - wd.x * shoulderX; val dy = (fy - wd.y) * trunk
            val d = kotlin.math.sqrt(dx * dx + dy * dy)
            // a ragged edge, darker at the heart of it
            val a = kotlin.math.atan2(dy, dx)
            val r = 0.036 * height * wd.r * (if (level >= 2) 1.25 else 1.0) * (0.8 + 0.25 * kotlin.math.sin(a * 3 + i * 1.7) + 0.1 * kotlin.math.sin(a * 7 + i))
            if (d < r) return if (d < r * 0.45 || level >= 2 && d < r * 0.7) bloodDark else bloodMat
        }
        return null
    }

    fun render(w: Int, h: Int, anchorX: Double, ground: Double, px: Double, rig: HeroFigure.Rig = REST, outfit: Outfit? = null, pitch: Double = 15.0, wounds: Int = 0): DepthImage {
        val (sk, fitted) = fit(rig, outfit)
        var body = fitted?.second ?: body(sk)
        val dress = fitted?.first ?: outfit?.let { Dress(this, sk, body, it) }
        val clothes = fitted?.third ?: dress?.solids() ?: emptyList()
        dress?.hidden?.let { hide -> body = body.filter { it.key !in hide } }
        val ax = anchorX + rig.bodyX * sk.s * px
        val gr = ground + rig.bodyY * sk.s * px
        val mat: (Solid, P3) -> Mat = if (wounds > 0) { so, p -> woundAt(sk, so, p, wounds) ?: material(so, p) } else ::material
        val img = SdfRender.render(body + clothes, groups(sk), mat, w, h, ax, gr, px, rig.yaw, pitch)
        face(img, sk)
        dress?.overlay(img)
        outline(img.img)
        dress?.glowHalo(img)
        return img
    }

    /**
     * The pose made to work with what the hero holds: when a blade would pass through the shield, the shield
     * arm is taken further out to its own side until the blade is free.
     */
    fun fit(rig: HeroFigure.Rig, outfit: Outfit?): Pair<Skeleton, Triple<Dress, List<Solid>, List<Solid>>?> {
        val shield = outfit?.hasShield == true
        if (outfit == null) return Skeleton(rig, shieldArm = false, fists = false) to null
        var first: Pair<Skeleton, Triple<Dress, List<Solid>, List<Solid>>>? = null
        // the grip never changes; the forearm turns as little as it must, then the shield arm gives way
        for (nudge in 0..6) {
            val base = if (nudge == 0) rig else rig.copy(lh = rig.lh + HeroFigure.V(-2.5 * nudge, 0.0, -1.0 * nudge), shieldFace = rig.shieldFace + HeroFigure.V(-0.15 * nudge, 0.0, 0.0))
            for (turn in ROLLS) {
                val r = if (turn == 0.0) base else base.copy(roll = base.roll + turn)
                val sk = Skeleton(r, shieldArm = shield, fists = true, twoHands = outfit.twoHands, weaponReach = outfit.base(de.bornim.core.GearSlot.MAIN_HAND)?.let(Dress::reach) ?: 90.0)
                val body = body(sk)
                val dress = Dress(this, sk, body, outfit)
                val clothes = dress.solids()
                val result = sk to Triple(dress, body, clothes)
                if (first == null) first = result
                if ((!shield || dress.weaponThroughShield() == null) && dress.weaponThroughBody() == null) return result
            }
        }
        return first!!
    }

    private fun outline(img: PixelImage) {
        val s = Sculpt(img.width, img.height)
        for (y in 0 until img.height) for (x in 0 until img.width) s.img.set(x, y, img[x, y])
        s.outline(argb(0x14100E))
        for (y in 0 until img.height) for (x in 0 until img.width) img.set(x, y, s.img[x, y])
    }

    companion object {
        const val TRUNK = 0; const val HEAD = 1; const val ARM_L = 2; const val ARM_R = 3; const val HAIR = 4; const val TUSK = 5
        const val CLOTH = 6; const val CLOTH_L = 7; const val CLOTH_R = 8; const val ARMOR = 9; const val ARMOR_L = 10; const val ARMOR_R = 11
        const val BELT = 12; const val SKIRT = 13; const val CLOAK = 14; const val HELM = 15; const val SHIELD = 16; const val ITEM = 17; const val BOOTS = 18; const val TRIM = 19
        const val LEG_L = 20; const val LEG_R = 21
        const val GROUPS = 22
        /** The groups a wound shows on: the trunk and what is worn over it. */
        private val WOUNDABLE = setOf(TRUNK, CLOTH, ARMOR, BELT, CLOAK)
        /** How far, in body heights, a crossbow's stock lies above the middle of the trigger hand. */
        const val STOCK_ABOVE_HAND = 0.03
        /** How far, in body heights, the butt plate lies behind the trigger hand along the stock. */
        const val STOCK_BACK = 0.13
        /** How far, in body heights, the stock's line lies above the middle of the butt plate. */
        const val BUTT_DROP = 0.075
        /** Half the butt plate's thickness, in body heights. */
        const val BUTT_HALF = 0.012
        /** Forearm turns tried, smallest first, to keep a blade clear of head, body and shield. */
        private val ROLLS = doubleArrayOf(0.0, 15.0, -15.0, 30.0, -30.0, 45.0, -45.0, 60.0, -60.0, 75.0, -75.0, 90.0, -90.0)

        /** Standing at ease, facing us, arms hanging. */
        val REST = HeroFigure.Rig(yaw = 20.0, stride = 0.0, spread = 6.0, rh = HeroFigure.V(17.0, 52.0, 3.0), lh = HeroFigure.V(-17.0, 52.0, 3.0), weapon = HeroFigure.V(0.0, -1.0, 0.0))

        fun max3(a: Double, b: Double, c: Double) = max(a, max(b, c))
    }
}
