package de.bornim.core.art

import de.bornim.core.Appearance
import de.bornim.core.Build
import de.bornim.core.Race
import de.bornim.core.Sex
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sign
import kotlin.math.sin
import kotlin.math.sqrt

/** A point or direction in the hero's own space, in centimetres: x to the hero's right, y up, z forward. */
data class P3(val x: Double, val y: Double, val z: Double) {
    operator fun plus(o: P3) = P3(x + o.x, y + o.y, z + o.z)
    operator fun minus(o: P3) = P3(x - o.x, y - o.y, z - o.z)
    operator fun times(k: Double) = P3(x * k, y * k, z * k)
    operator fun unaryMinus() = P3(-x, -y, -z)
    infix fun dot(o: P3) = x * o.x + y * o.y + z * o.z
    infix fun cross(o: P3) = P3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x)
    fun len() = sqrt(this dot this)
    fun norm() = this * (1.0 / len().coerceAtLeast(1e-9))
    fun lerp(o: P3, t: Double) = this + (o - this) * t
    fun mirror() = P3(-x, y, z)

    companion object {
        val X = P3(1.0, 0.0, 0.0)
        val Y = P3(0.0, 1.0, 0.0)
        val Z = P3(0.0, 0.0, 1.0)
    }
}

/** Three axes of a body part, for oriented shapes. */
class Frame(val x: P3, val y: P3, val z: P3) {
    companion object {
        val IDENTITY = Frame(P3.X, P3.Y, P3.Z)

        /** A frame whose y axis runs along [along], with z leaning towards [hint]. */
        fun along(along: P3, hint: P3 = P3.Z): Frame {
            val y = along.norm()
            var x = (y cross hint)
            if (x.len() < 1e-6) x = y cross P3.X
            x = x.norm()
            return Frame(x, y, x cross y)
        }
    }
}

/** What a piece of the body is, so the painter knows its material. */
enum class BodyPart { HEAD, NECK, TORSO, PELVIS, ARM, HAND, THIGH, SHIN, FOOT, HAIR, TUSK }

/** A solid of the doll, measured by its signed distance: negative inside. */
abstract class Solid(val part: BodyPart, val group: Int) {
    abstract val center: P3
    abstract val bound: Double
    protected abstract fun raw(p: P3): Double
    /** Half spaces the solid is cut by: kept where n·p ≤ d. */
    val cuts = mutableListOf<Pair<P3, Double>>()
    fun cut(n: P3, through: P3): Solid { val nn = n.norm(); cuts += nn to (nn dot through); return this }
    fun dist(p: P3): Double {
        var d = raw(p)
        for ((n, k) in cuts) d = max(d, (n dot p) - k)
        return d
    }
}

class Ellipsoid(override val center: P3, private val r: P3, private val f: Frame = Frame.IDENTITY, part: BodyPart, group: Int) : Solid(part, group) {
    override val bound = max(r.x, max(r.y, r.z))
    override fun raw(p: P3): Double {
        val q = p - center
        val lx = (q dot f.x) / r.x; val ly = (q dot f.y) / r.y; val lz = (q dot f.z) / r.z
        val k0 = sqrt(lx * lx + ly * ly + lz * lz)
        val k1 = sqrt((lx / r.x) * (lx / r.x) + (ly / r.y) * (ly / r.y) + (lz / r.z) * (lz / r.z))
        return if (k1 < 1e-9) -min(r.x, min(r.y, r.z)) else k0 * (k0 - 1) / k1
    }
}

/** A cone with rounded ends: radius [ra] at [a], [rb] at [b]. Limbs, neck, tusks. */
class RoundCone(private val a: P3, private val b: P3, private val ra: Double, private val rb: Double, part: BodyPart, group: Int) : Solid(part, group) {
    override val center = a.lerp(b, 0.5)
    override val bound = (b - a).len() / 2 + max(ra, rb)
    private val ba = b - a
    private val l2 = ba dot ba
    private val rr = ra - rb
    private val a2 = l2 - rr * rr
    override fun raw(p: P3): Double {
        if (a2 <= 1e-6) return min((p - a).len() - ra, (p - b).len() - rb)
        val il2 = 1.0 / l2
        val pa = p - a
        val y = pa dot ba
        val z = y - l2
        val w = pa * l2 - ba * y
        val x2 = w dot w
        val y2 = y * y * l2
        val z2 = z * z * l2
        val k = sign(rr) * rr * rr * x2
        if (sign(z) * a2 * z2 > k) return sqrt(x2 + z2) * il2 - rb
        if (sign(y) * a2 * y2 < k) return sqrt(x2 + y2) * il2 - ra
        return (sqrt(x2 * a2 * il2) + y * rr) * il2 - ra
    }
}

/** A finished picture of the doll: colours in [img], and per pixel the depth, for weapons and decals drawn later. */
class DollImage(val img: PixelImage, val depth: DoubleArray)

/**
 * The hero as a doll in three dimensions, rendered pixel by pixel. Every people has its own measures
 * from the SRD (height, build), every hero a sex, a build and a skin tone. Solids of one group melt
 * into each other, so shoulders grow out of the chest rather than being glued on.
 */
class Doll(val race: Race, val sex: Sex, val build: Build, val skin: Int = 0, val hairTone: Int = 0) {

    // ---------------------------------------------------------------- measures (cm)

    private val female = sex == Sex.FEMALE
    /** Standing height. SRD: dwarves 4–5 ft, halflings about 3 ft (raised to 60 % of a human so their gear reads), half-orcs larger than humans. */
    val height = when (race) {
        Race.HUMAN -> 175.0; Race.ELF -> 172.0; Race.DWARF -> 135.0; Race.HALFLING -> 105.0; Race.HALF_ORC -> 185.0
    } * (if (female) 0.93 else 1.0)
    private val heads = when (race) { Race.HUMAN -> 7.5; Race.ELF -> 7.9; Race.DWARF -> 5.3; Race.HALFLING -> 5.9; Race.HALF_ORC -> 7.3 }
    /** Height of the head, chin to crown. */
    val hh = height / heads
    private val legF = when (race) { Race.HUMAN -> 0.51; Race.ELF -> 0.535; Race.DWARF -> 0.39; Race.HALFLING -> 0.46; Race.HALF_ORC -> 0.5 }
    private val buildK = when (build) { Build.SLIM -> 0.86; Build.AVERAGE -> 1.0; Build.STRONG -> 1.17 }
    /** Thickness of trunk and limbs relative to a human: dwarves are as heavy as a human two feet taller. */
    private val girth = when (race) { Race.HUMAN -> 1.0; Race.ELF -> 0.86; Race.DWARF -> 1.5; Race.HALFLING -> 1.08; Race.HALF_ORC -> 1.22 } * buildK
    private val limbK = girth * (if (female) 0.9 else 1.0) * (if (build == Build.STRONG) 1.05 else 1.0)
    private val shoulderK = when (race) { Race.HUMAN -> 1.0; Race.ELF -> 0.92; Race.DWARF -> 1.55; Race.HALFLING -> 1.0; Race.HALF_ORC -> 1.12 } *
        (if (female) 0.87 else 1.0) * (if (build == Build.STRONG) 1.05 else if (build == Build.SLIM) 0.96 else 1.0)
    private val hipK = (if (female) 1.16 else 1.0) * (if (race == Race.DWARF) 1.15 else 1.0) * (if (build == Build.STRONG) 1.04 else 1.0)
    private val handK = when (race) { Race.DWARF -> 1.2; Race.HALF_ORC -> 1.15; Race.HALFLING -> 1.05; Race.ELF -> 0.95; else -> 1.0 }
    private val footK = when (race) { Race.HALFLING -> 1.25; Race.DWARF -> 1.05; Race.HALF_ORC -> 1.05; Race.ELF -> 0.92; else -> 0.95 } * (if (female) 0.92 else 1.0)

    val ankleY = 0.045 * height
    val hipY = legF * height
    val kneeY = ankleY + (hipY - ankleY) * 0.52
    val chinY = height - hh * 0.98
    val shoulderY = chinY - 0.055 * height * (if (race == Race.DWARF) 0.72 else if (race == Race.HALF_ORC) 0.85 else 1.0)
    val shoulderX = 0.105 * height * shoulderK
    val hipX = 0.052 * height * hipK
    private val trunk = shoulderY - hipY
    private val upperArm = 0.172 * height * (if (race == Race.DWARF) 1.05 else 1.0)
    private val foreArm = 0.155 * height * (if (race == Race.DWARF) 1.05 else 1.0)
    val headC = P3(0.0, height - hh * 0.5, 0.0)
    private val neckTop = P3(0.0, chinY + 0.01 * height, 0.0)
    private val shoulderL = P3(-shoulderX, shoulderY, 0.0)
    private val shoulderR = P3(shoulderX, shoulderY, 0.0)

    val skinRgb = Appearance.skins(race)[skin.mod(4)].rgb
    val hairRgb = Appearance.hairs(race)[hairTone.mod(4)].rgb

    // ---------------------------------------------------------------- materials

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain)
    private val skinMat = Mat(Ramp.of(argb(skinRgb), sat = 0.8), shine = 0.05, grain = 0.02)
    private val hairMat = m(hairRgb, shine = 0.15, grain = 0.22)
    private val shirtMat = m(0xC9BDA2, grain = 0.06)
    private val shortsMat = m(0x7E6E58, grain = 0.06)
    private val tuskMat = m(0xE8E0C8, shine = 0.3)

    // ---------------------------------------------------------------- the body

    /** A simple standing pose: where hands and feet are, as offsets from their rest. */
    class Pose(val armOut: Double = 0.16, val elbowBend: Double = 0.18, val footOut: Double = 0.0)

    fun solids(pose: Pose = Pose()): List<Solid> {
        val out = mutableListOf<Solid>()
        val h = height
        val g = girth
        val l = limbK
        // groups: 0 trunk and legs, 1 head, 2/3 the arms, 4 hair, 5 tusks
        fun ell(c: P3, r: P3, part: BodyPart, group: Int = 0, f: Frame = Frame.IDENTITY) = Ellipsoid(c, r, f, part, group).also { out += it }
        fun cone(a: P3, b: P3, ra: Double, rb: Double, part: BodyPart, group: Int = 0) = RoundCone(a, b, ra, rb, part, group).also { out += it }

        // trunk
        ell(P3(0.0, shoulderY - 0.30 * trunk, 0.0), P3(0.79 * shoulderX, 0.40 * trunk, 0.066 * h * g), BodyPart.TORSO)
        if (female) for (s in listOf(-1.0, 1.0)) ell(P3(s * 0.36 * shoulderX, shoulderY - 0.32 * trunk, 0.038 * h * g), P3(0.27 * shoulderX, 0.13 * trunk, 0.036 * h * g), BodyPart.TORSO)
        else ell(P3(0.0, shoulderY - 0.21 * trunk, 0.022 * h * g), P3(0.72 * shoulderX, 0.17 * trunk, 0.05 * h * g), BodyPart.TORSO)
        val waistK = if (female) 0.84 else 1.0
        ell(P3(0.0, hipY + 0.45 * trunk, 0.004 * h), P3(0.63 * shoulderX * waistK * (if (race == Race.DWARF) 1.15 else 1.0), 0.30 * trunk, 0.058 * h * g), BodyPart.TORSO)
        ell(P3(0.0, hipY + 0.10 * trunk, -0.004 * h), P3(1.75 * hipX, 0.22 * trunk, 0.064 * h * g), BodyPart.PELVIS)
        for (s in listOf(-1.0, 1.0)) ell(P3(s * 0.75 * hipX, hipY + 0.03 * trunk, -0.024 * h * g), P3(0.9 * hipX, 0.13 * trunk, 0.036 * h * g), BodyPart.PELVIS)
        val neckBase = P3(0.0, shoulderY + 0.012 * h, -0.006 * h)
        for (s in listOf(-1.0, 1.0)) {
            // trapezius from the neck down to the shoulder, the shoulder's round cap
            cone(neckBase, P3(s * shoulderX * 0.82, shoulderY + 0.012 * h, -0.008 * h), 0.03 * h * g, 0.024 * h * g, BodyPart.TORSO)
            ell(P3(s * shoulderX, shoulderY - 0.008 * h, 0.0), P3(0.033 * h * l, 0.042 * h * l, 0.035 * h * l), BodyPart.ARM)
        }
        cone(neckBase, P3(0.0, chinY + 0.025 * h, 0.004 * h), 0.034 * h * sqrt(g), 0.029 * h * sqrt(g) * (if (female) 0.88 else 1.0), BodyPart.NECK)

        // arms hanging relaxed, a little away from the body
        for (s in listOf(-1.0, 1.0)) {
            val sh = P3(s * shoulderX, shoulderY - 0.01 * h, 0.0)
            val el = sh + P3(s * pose.armOut, -1.0, 0.02).norm() * upperArm
            val wr = el + P3(s * pose.armOut * 0.6, -1.0, pose.elbowBend).norm() * foreArm
            val grp = if (s < 0) 2 else 3
            cone(sh, el, 0.029 * h * l, 0.02 * h * l, BodyPart.ARM, grp)
            cone(el, wr, 0.022 * h * l, 0.015 * h * l, BodyPart.ARM, grp)
            // the forearm's muscle below the elbow
            ell(el.lerp(wr, 0.28), P3(0.022 * h * l, 0.06 * h, 0.02 * h * l), BodyPart.ARM, grp, Frame.along(wr - el))
            val dir = (wr - el).norm()
            val hf = Frame.along(dir, P3(s, 0.0, 0.0))
            ell(wr + dir * (0.045 * h * handK), P3(0.029 * h * handK, 0.054 * h * handK, 0.014 * h * handK), BodyPart.HAND, grp, hf)
        }

        // legs
        for (s in listOf(-1.0, 1.0)) {
            val hip = P3(s * hipX, hipY, 0.0)
            val ankle = P3(s * (hipX * 0.85 + pose.footOut), ankleY, 0.0)
            val knee = P3(s * hipX * 0.9, kneeY, 0.008 * h)
            cone(hip, knee, 0.048 * h * l * (if (female) 1.06 else 1.0), 0.029 * h * l, BodyPart.THIGH)
            ell(knee + P3(0.0, 0.0, 0.006 * h), P3(0.028 * h * l, 0.03 * h, 0.026 * h * l), BodyPart.SHIN)
            cone(knee, ankle, 0.026 * h * l, 0.016 * h * l, BodyPart.SHIN)
            ell(knee.lerp(ankle, 0.3) + P3(0.0, 0.0, -0.012 * h * l), P3(0.03 * h * l, 0.075 * h, 0.03 * h * l), BodyPart.SHIN)
            val heel = ankle + P3(0.0, -0.022 * h, -0.022 * h)
            val toe = ankle + P3(s * 0.01 * h, -0.033 * h, 0.115 * h * footK)
            cone(heel, toe, 0.021 * h * footK, 0.018 * h * footK, BodyPart.FOOT)
            ell(ankle.lerp(toe, 0.4) + P3(0.0, -0.01 * h, 0.0), P3(0.025 * h * footK, 0.022 * h, 0.05 * h * footK), BodyPart.FOOT)
        }

        head(out)
        return out
    }

    private fun head(out: MutableList<Solid>) {
        val c = headC
        val k = hh
        fun ell(at: P3, r: P3, part: BodyPart = BodyPart.HEAD, group: Int = 1, f: Frame = Frame.IDENTITY) = Ellipsoid(c + at, r, f, part, group).also { out += it }
        fun cone(a: P3, b: P3, ra: Double, rb: Double, part: BodyPart = BodyPart.HEAD, group: Int = 1) = RoundCone(c + a, c + b, ra, rb, part, group).also { out += it }
        val wide = when (race) { Race.DWARF -> 1.08; Race.HALF_ORC -> 1.06; Race.ELF -> 0.93; else -> 1.0 } * (if (female) 0.96 else 1.0)
        val jaw = when (race) { Race.HALF_ORC -> 1.25; Race.DWARF -> 1.12; Race.ELF -> 0.9; else -> 1.0 } * (if (female) 0.9 else 1.0)
        val skull = P3(0.34 * k * wide, 0.46 * k, 0.43 * k)
        val skullC = P3(0.0, 0.06 * k, -0.03 * k)
        ell(skullC, skull)
        ell(P3(0.0, -0.2 * k, 0.08 * k), P3(0.27 * k * jaw, 0.27 * k, 0.32 * k))
        val nose = when (race) { Race.DWARF -> P3(0.075, 0.14, 0.1); Race.HALF_ORC -> P3(0.085, 0.11, 0.075); Race.ELF -> P3(0.045, 0.11, 0.07); else -> P3(0.055, 0.12, 0.08) }
        ell(P3(0.0, -0.08 * k, 0.37 * k), nose * k)
        val brow = if (race == Race.HALF_ORC) 1.35 else if (race == Race.DWARF) 1.15 else 1.0
        ell(P3(0.0, 0.1 * k, 0.29 * k), P3(0.27 * k, 0.06 * k * brow, 0.1 * k * brow))
        for (s in listOf(-1.0, 1.0)) when (race) {
            Race.ELF -> cone(P3(s * 0.32 * k, -0.04 * k, -0.03 * k), P3(s * 0.54 * k, 0.34 * k, -0.17 * k), 0.07 * k, 0.014 * k)
            Race.HALFLING -> cone(P3(s * 0.32 * k, -0.04 * k, -0.03 * k), P3(s * 0.44 * k, 0.17 * k, -0.08 * k), 0.07 * k, 0.022 * k)
            Race.HALF_ORC -> cone(P3(s * 0.33 * k, -0.04 * k, -0.03 * k), P3(s * 0.43 * k, 0.1 * k, -0.06 * k), 0.065 * k, 0.025 * k)
            else -> ell(P3(s * 0.34 * k, -0.03 * k, -0.02 * k), P3(0.05 * k, 0.12 * k, 0.08 * k))
        }
        if (race == Race.HALF_ORC) for (s in listOf(-1.0, 1.0)) cone(P3(s * 0.12 * k, -0.3 * k, 0.3 * k), P3(s * 0.15 * k, -0.15 * k, 0.37 * k), 0.035 * k, 0.012 * k, BodyPart.TUSK, 5)

        // hair: a cap over the skull, cut away from the face and, when short, above the ears
        val cap = Ellipsoid(c + skullC, skull + P3(0.05 * k, 0.05 * k, 0.05 * k), Frame.IDENTITY, BodyPart.HAIR, 4)
        cap.cut(P3(0.0, -0.45, 0.89), c + P3(0.0, -0.45, 0.89).norm() * (0.17 * k))
        val long = female || race == Race.ELF
        if (!long) cap.cut(P3(0.0, -1.0, 1.2), c)
        out += cap
        val backZ = -(0.066 * height * girth + 0.01 * height)
        if (female) {
            // hair falling over the back to the shoulder blades
            out += RoundCone(c + P3(0.0, -0.05 * k, -0.28 * k), P3(0.0, shoulderY - 0.07 * height, backZ * 0.9), 0.31 * k, 0.2 * k, BodyPart.HAIR, 4)
                .cut(P3(0.0, 0.0, 1.0), c + P3(0.0, 0.0, 0.05 * k))
        } else if (race == Race.ELF) {
            out += RoundCone(c + P3(0.0, -0.05 * k, -0.28 * k), P3(0.0, chinY - 0.02 * height, backZ * 0.6), 0.31 * k, 0.24 * k, BodyPart.HAIR, 4)
                .cut(P3(0.0, 0.0, 1.0), c + P3(0.0, 0.0, 0.0))
        }
        if (race == Race.DWARF && !female) {
            // a full beard over jaw and chest, with a moustache
            out += Ellipsoid(c + P3(0.0, -0.34 * k, 0.2 * k), P3(0.32 * k, 0.3 * k, 0.24 * k), Frame.IDENTITY, BodyPart.HAIR, 4)
                .cut(P3(0.0, 1.0, 0.0), c + P3(0.0, -0.24 * k, 0.0))
            out += RoundCone(c + P3(0.0, -0.5 * k, 0.24 * k), c + P3(0.0, -1.3 * k, 0.34 * k), 0.27 * k, 0.11 * k, BodyPart.HAIR, 4)
            out += Ellipsoid(c + P3(0.0, -0.21 * k, 0.37 * k), P3(0.17 * k, 0.05 * k, 0.07 * k), Frame.IDENTITY, BodyPart.HAIR, 4)
        }
        if (race == Race.DWARF && female) for (s in listOf(-1.0, 1.0))
            out += RoundCone(c + P3(s * 0.3 * k, -0.2 * k, 0.0), P3(s * shoulderX * 0.55, shoulderY - 0.12 * height, 0.06 * height * girth), 0.09 * k, 0.06 * k, BodyPart.HAIR, 4)
    }

    /** Material at a point on the body: skin, hair, or the plain linen underclothes. */
    private fun material(s: Solid, p: P3): Mat {
        val shirtHem = hipY + 0.22 * trunk
        val shortsHem = hipY - 0.3 * (hipY - kneeY)
        return when (s.part) {
            BodyPart.HAIR -> hairMat
            BodyPart.TUSK -> tuskMat
            BodyPart.PELVIS -> shortsMat
            BodyPart.THIGH -> if (p.y > shortsHem) shortsMat else skinMat
            BodyPart.TORSO -> when {
                p.y < shirtHem -> shortsMat
                // a sleeveless shirt: bare shoulders, a round neckline at the front
                p.y > shoulderY - 0.12 * trunk && abs(p.x) > 0.6 * shoulderX -> skinMat
                p.y > shoulderY - 0.08 * trunk && p.z > 0 && abs(p.x) < 0.32 * shoulderX -> skinMat
                else -> shirtMat
            }
            else -> skinMat
        }
    }

    // ---------------------------------------------------------------- rendering

    /**
     * Renders the doll turned by [yaw] degrees (0 faces us, 90 shows its right side, 180 its back) into a
     * picture of [w]×[h] pixels, standing with its feet at ([anchorX], [ground]) and [px] pixels per centimetre.
     */
    fun render(w: Int, h: Int, anchorX: Double, ground: Double, px: Double, yaw: Double, pose: Pose = Pose(), pitchDeg: Double = 15.0): DollImage {
        val solids = solids(pose)
        val s = Sculpt(w, h, 23)
        val view = View(yaw, pitchDeg)
        val depth = DoubleArray(w * h) { Double.NEGATIVE_INFINITY }
        val idx = IntArray(w * h) { -1 }
        val mats = arrayOfNulls<Mat>(w * h)
        val owner = IntArray(w * h) { -1 }
        // where each solid lands on screen, for quick culling
        val cx = DoubleArray(solids.size); val cy = DoubleArray(solids.size); val cz = DoubleArray(solids.size); val cr = DoubleArray(solids.size)
        for ((i, so) in solids.withIndex()) {
            val v = view.toView(so.center)
            cx[i] = anchorX + v.x * px; cy[i] = ground - v.y * px; cz[i] = v.z; cr[i] = (so.bound + SMOOTH) * px + 1
        }
        val dirL = view.toLocalDir(P3.Z)
        val cand = IntArray(solids.size)
        val groupD = DoubleArray(8)
        fun field(p: P3, n: Int): Double {
            java.util.Arrays.fill(groupD, Double.MAX_VALUE)
            for (j in 0 until n) {
                val so = solids[cand[j]]
                val d = so.dist(p)
                val g = so.group
                groupD[g] = if (groupD[g] == Double.MAX_VALUE) d else smin(groupD[g], d, if (g <= 1) SMOOTH else SMOOTH * 0.6)
            }
            // arms melt into the shoulders and the head onto the neck, but nowhere else
            var trunkD = groupD[0]
            if (trunkD != Double.MAX_VALUE) {
                for (g in 1..3) {
                    val d = groupD[g]
                    if (d == Double.MAX_VALUE) continue
                    val joint = if (g == 1) neckTop else if (g == 2) shoulderL else shoulderR
                    val w = (1 - (p - joint).len() / (0.07 * height)).coerceIn(0.0, 1.0)
                    trunkD = if (w > 0.05) smin(trunkD, d, SMOOTH * 1.4 * w) else min(trunkD, d)
                    groupD[g] = Double.MAX_VALUE
                }
                groupD[0] = trunkD
            }
            var best = Double.MAX_VALUE
            for (d in groupD) if (d < best) best = d
            return best
        }
        for (y in 0 until h) for (x in 0 until w) {
            val sx = x + 0.5; val sy = y + 0.5
            var n = 0
            var zTop = Double.NEGATIVE_INFINITY; var zBot = Double.POSITIVE_INFINITY
            for (i in solids.indices) {
                val dx = sx - cx[i]; val dy = sy - cy[i]
                if (dx * dx + dy * dy <= cr[i] * cr[i]) {
                    cand[n++] = i
                    val rr = solids[i].bound + SMOOTH
                    zTop = max(zTop, cz[i] + rr); zBot = min(zBot, cz[i] - rr)
                }
            }
            if (n == 0) continue
            val o = view.toLocal(P3((sx - anchorX) / px, (ground - sy) / px, 0.0))
            var z = zTop
            var hit = false
            var steps = 0
            while (z > zBot && steps < 90) {
                val d = field(o + dirL * z, n)
                if (d < 0.12) { hit = true; break }
                z -= max(d * 0.9, 0.08)
                steps++
            }
            if (!hit) continue
            val p = o + dirL * z
            // the surface normal from the field's slope, then turned into the picture's axes
            val e = 0.25
            val k1 = field(p + P3(e, -e, -e), n); val k2 = field(p + P3(-e, -e, e), n)
            val k3 = field(p + P3(-e, e, -e), n); val k4 = field(p + P3(e, e, e), n)
            val nl = P3(k1 - k2 - k3 + k4, -k1 - k2 + k3 + k4, -k1 + k2 - k3 + k4).norm()
            val nv = view.toViewDir(nl)
            // which solid this is: the nearest one
            var bi = cand[0]; var bd = Double.MAX_VALUE
            for (j in 0 until n) { val d = solids[cand[j]].dist(p); if (d < bd) { bd = d; bi = cand[j] } }
            val mat = material(solids[bi], p)
            val at = y * w + x
            depth[at] = z; mats[at] = mat; owner[at] = solids[bi].group
            idx[at] = s.litIndex(x, y, nv.x, -nv.y, nv.z, mat)
        }
        // a soft inner line where a nearer part overlaps a farther one
        for (y in 0 until h) for (x in 0 until w) {
            val at = y * w + x
            val m = mats[at] ?: continue
            var i = idx[at]
            for ((ox, oy) in NEIGH) {
                val xx = x + ox; val yy = y + oy
                if (xx !in 0 until w || yy !in 0 until h) continue
                val b = yy * w + xx
                if (mats[b] != null && depth[at] - depth[b] > 3.5) { i = min(i, 1); break }
            }
            s.img.set(x, y, m.ramp[i])
        }
        decals(s, view, depth, anchorX, ground, px, w)
        s.outline(argb(0x14100E))
        return DollImage(s.img, depth)
    }

    /** Eyes, brows and mouth, painted where the face is visible. */
    private fun decals(s: Sculpt, view: View, depth: DoubleArray, ax: Double, ground: Double, px: Double, w: Int) {
        fun at(p: P3): Pair<Int, Int>? {
            val v = view.toView(p)
            val x = (ax + v.x * px).toInt(); val y = (ground - v.y * px).toInt()
            if (x !in 0 until w || y !in 0 until s.h) return null
            val d = depth[y * w + x]
            return if (d.isFinite() && d <= v.z + 0.06 * hh + 1.0) x to y else null
        }
        val k = hh
        val c = headC
        val eye = argb(0x1C1612)
        val browC = mix(argb(hairRgb), argb(0x1C1612), 0.4)
        for (sd in listOf(-1.0, 1.0)) {
            at(c + P3(sd * 0.13 * k, -0.01 * k, 0.4 * k))?.let { (x, y) -> s.img.set(x, y, eye) }
            val b0 = at(c + P3(sd * 0.07 * k, 0.07 * k, 0.43 * k)); val b1 = at(c + P3(sd * 0.21 * k, 0.08 * k, 0.37 * k))
            if (b0 != null && b1 != null) { s.img.set(b0.first, b0.second, browC); s.img.set(b1.first, b1.second, browC) }
        }
        if (!(race == Race.DWARF && sex == Sex.MALE)) {
            val m0 = at(c + P3(-0.07 * k, -0.27 * k, 0.4 * k)); val m1 = at(c + P3(0.07 * k, -0.27 * k, 0.4 * k))
            val lip = mix(argb(skinRgb), argb(0x3A1C18), 0.55)
            if (m0 != null) s.img.set(m0.first, m0.second, lip)
            if (m1 != null) s.img.set(m1.first, m1.second, lip)
        }
    }

    /** The camera: the doll turned by its yaw, seen from slightly above. */
    class View(yawDeg: Double, pitchDeg: Double) {
        private val yaw = Math.toRadians(yawDeg)
        private val rX = -cos(yaw); private val rZ = sin(yaw)
        private val fX = sin(yaw); private val fZ = cos(yaw)
        private val c = cos(Math.toRadians(pitchDeg)); private val s = sin(Math.toRadians(pitchDeg))

        /** Hero space to view space: x right, y up on screen, z towards us. */
        fun toView(p: P3): P3 {
            val wx = p.x * rX + p.z * fX; val wz = p.x * rZ + p.z * fZ; val wy = p.y
            return P3(wx, wy * c - wz * s, wz * c + wy * s)
        }
        fun toViewDir(d: P3) = toView(d)
        fun toLocal(v: P3): P3 {
            val wx = v.x; val wy = v.y * c + v.z * s; val wz = -v.y * s + v.z * c
            return P3(wx * rX + wz * rZ, wy, wx * fX + wz * fZ)
        }
        fun toLocalDir(v: P3) = toLocal(v)
    }

    companion object {
        /** How far solids of one group melt into each other, in cm. */
        const val SMOOTH = 2.6
        private val NEIGH = listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1)
        fun smin(a: Double, b: Double, k: Double): Double {
            val h = max(k - abs(a - b), 0.0) / k
            return min(a, b) - h * h * k * 0.25
        }
    }
}
