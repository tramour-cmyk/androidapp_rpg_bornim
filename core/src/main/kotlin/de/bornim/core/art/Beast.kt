package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.acos
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * A four-legged animal built in the round, like the hero's doll: a deep chest, a narrow waist and strong haunches on
 * a spine that bends, a head with a jaw that opens, legs jointed as an animal's are (the hind foot long, the heel high)
 * and a tail. Everything is measured in cm with the animal facing +z, its feet on y = 0. [size] scales the whole
 * animal (a dire wolf is about half as big again); the [coat] colours it.
 */
class Beast(val size: Double = 1.0, val coat: WolfArt.Coat = WolfArt.GREY, val kind: Kind = Kind.WOLF) {

    /** Which animal: the wolf, the wild boar (heavy, bristled, tusked) or the giant rat (low, mangy, naked tail). */
    enum class Kind { WOLF, BOAR, RAT }

    /** How the animal stands and moves. Angles in degrees; lengths in cm of a wolf of size 1. */
    data class Rig(
        /** The whole body forward (+) or back, and down (+) into a crouch. */
        val fwd: Double = 0.0, val crouch: Double = 0.0,
        /** The whole body to its right (+) or left, as in a leap aside. */
        val side: Double = 0.0,
        /** The body tipped nose down (+) or up, about the hips. */
        val pitch: Double = 0.0,
        /** The breath: the chest a little fuller. */
        val breath: Double = 0.0,
        /** The neck raised (+) or lowered from its usual slant; the head nodded down (+) at its end; turned to its right (+). */
        val neck: Double = 0.0, val nod: Double = 0.0, val turn: Double = 0.0,
        /** The jaw open, 0 to 1; the lips drawn back in a snarl, 0 to 1. */
        val mouth: Double = 0.15, val snarl: Double = 0.0,
        /** Ears pricked (+1) or laid flat back (-1). */
        val ears: Double = 0.0,
        /** The tail raised (+) or tucked; swung to the side. */
        val tail: Double = 0.0, val tailSwing: Double = 0.0,
        /** Each paw moved from where it stands: forward (dz) and up (dy); front left, front right, hind left, hind right. */
        val fl: HeroFigure.V = HeroFigure.V(0.0, 0.0, 0.0), val fr: HeroFigure.V = HeroFigure.V(0.0, 0.0, 0.0),
        val hl: HeroFigure.V = HeroFigure.V(0.0, 0.0, 0.0), val hr: HeroFigure.V = HeroFigure.V(0.0, 0.0, 0.0),
        /** The eyes, open 1 or shut 0. */
        val eyes: Double = 1.0,
        /** Falling over: forward and to its right side, in degrees, as the doll's falls. */
        val fallF: Double = 0.0, val fallS: Double = 0.0,
        /** Which way it faces in the picture. */
        val yaw: Double = -60.0,
    ) {
        fun lerp(o: Rig, t: Double): Rig {
            fun l(a: Double, b: Double) = a + (b - a) * t
            fun v(a: HeroFigure.V, b: HeroFigure.V) = HeroFigure.V(l(a.r, b.r), l(a.u, b.u), l(a.f, b.f))
            return Rig(l(fwd, o.fwd), l(crouch, o.crouch), l(side, o.side), l(pitch, o.pitch), l(breath, o.breath), l(neck, o.neck), l(nod, o.nod), l(turn, o.turn),
                l(mouth, o.mouth), l(snarl, o.snarl), l(ears, o.ears), l(tail, o.tail), l(tailSwing, o.tailSwing),
                v(fl, o.fl), v(fr, o.fr), v(hl, o.hl), v(hr, o.hr), l(eyes, o.eyes), l(fallF, o.fallF), l(fallS, o.fallS), l(yaw, o.yaw))
        }
    }

    private val k = size

    // the coat: the main fur, a dark saddle down the back, a pale throat and belly
    private val fur = Mat(Ramp.of(argb(coat.fur)), grain = 0.12)
    private val saddle = Mat(Ramp.of(argb(coat.saddle)), grain = 0.12)
    private val belly = Mat(Ramp.of(argb(coat.belly)), grain = 0.1)
    private val cheek = Mat(Ramp.of(argb(mix(argb(coat.fur), argb(coat.belly), 0.5))), grain = 0.1)
    private val dark = Mat(Ramp.of(argb(mix(argb(coat.fur), argb(0x181414), 0.55))), grain = 0.1)
    private val nose = Mat(Ramp.of(argb(0x1A1616)), shine = 0.9)
    private val maw = Mat(Ramp.of(argb(0x1E0A0C)), shine = 0.3)
    private val gum = Mat(Ramp.of(argb(0x5A1E22)), shine = 0.4)
    private val tooth = Mat(Ramp.of(argb(0xE8E0CC)), shine = 0.5)
    private val eye = Mat(Ramp.of(argb(coat.eye)), shine = 1.0, bias = 0.25)
    private val pupil = Mat(Ramp.of(argb(0x0C0808)), shine = 1.0)
    private val scar = Mat(Ramp.of(argb(0x8A5E5A)), grain = 0.1)
    private val pad = Mat(Ramp.of(argb(0x2A2422)), grain = 0.1)

    private val out = mutableListOf<Solid>()
    /** Where head, legs and tail join the trunk in the last pose built, so they melt into it there. */
    private val joints = HashMap<Int, P3>()
    /** Where the jaws meet at the front, in the last pose built: what lands on the prey. */
    var snoutTip: P3 = P3.O
        private set
    private fun add(s: Solid, m: Mat): Solid { s.mat = m; out += s; return s }

    /** A surface roughened into tufts of fur: strands that run along [flow], [depth] cm deep. */
    private class Shag(val inner: Solid, val flow: P3, val depth: Double, val seed: Double) : Solid(inner.part, inner.group) {
        override val center = inner.center
        override val bound = inner.bound + depth
        private val u = (if (abs(flow.y) > 0.9) P3.X else (P3.Y cross flow)).norm()
        private val v = (flow cross u).norm()
        override fun raw(p: P3): Double {
            val d = inner.dist(p)
            if (d > depth * 2 + 2) return d - depth
            // irregular strands: coarse across the flow, stretched out along it
            val q = p - center
            val n = noise((q dot u) * 0.9 + seed * 7.1, (q dot v) * 0.9 - seed * 3.3, (q dot flow) * 0.22 + seed) * 0.7 +
                noise((q dot u) * 2.1 - seed, (q dot v) * 2.1 + seed * 1.7, (q dot flow) * 0.5) * 0.3
            return (d - depth * n) * 0.8
        }
    }

    /** Two-bone reach from [a] to [c], the middle joint bending towards [pole]. */
    private fun ik(a: P3, c: P3, l1: Double, l2: Double, pole: P3): P3 {
        val d = c - a
        val dist = d.len().coerceIn(abs(l1 - l2) + 0.01, l1 + l2 - 0.01)
        val dir = d.norm()
        val cosA = ((l1 * l1 + dist * dist - l2 * l2) / (2 * l1 * dist)).coerceIn(-1.0, 1.0)
        val side = (pole - dir * (pole dot dir)).norm()
        val ang = acos(cosA)
        return a + (dir * cos(ang) + side * sin(ang)) * l1
    }

    /** Builds the animal in pose [r]: every solid with its material. */
    fun solids(r: Rig): List<Solid> {
        out.clear()
        when (kind) {
            Kind.BOAR -> { boar(r); return out.toList() }
            Kind.RAT -> { rat(r); return out.toList() }
            Kind.WOLF -> {}
        }
        // the body turns about the hips: forward and down by the rig, nose down by its pitch
        val hip0 = P3(0.0, 62.0, -34.0) * k
        val body = Xf(Rot.pitch(r.pitch), hip0, P3(r.side * k, -r.crouch * k, r.fwd * k))
        fun b(x: Double, y: Double, z: Double) = body.apply(P3(x, y, z) * k)
        val fwdB = body.dir(P3.Z); val upB = body.dir(P3.Y)
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = Frame(body.dir(P3.X), upB, fwdB)) =
            add(Ellipsoid(c, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, c: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a, c, ra * k, rb * k, BodyPart.ARM, g), m)
        fun shag(s: Solid, flow: P3, depth: Double, seed: Double) { out.remove(s); add(Shag(s, flow.norm(), depth * k, seed), s.mat!!) }

        // ---- the trunk: chest, waist and haunches melt into one long body
        val chest = b(0.0, 58.0, 30.0); val waist = b(0.0, 60.0, -2.0); val haunch = b(0.0, 61.0, -32.0)
        shag(ell(chest, 14.5 + r.breath * 0.6, 19.0 + r.breath * 0.8, 21.0, fur, TRUNK), fwdB, 1.6, 0.0)
        shag(ell(waist, 11.5, 13.0, 22.0, fur, TRUNK), fwdB, 1.3, 1.0)
        shag(ell(haunch, 13.0, 15.0, 15.0, fur, TRUNK), fwdB, 1.4, 2.0)
        // the dark saddle along the back, the pale belly and chest under it
        shag(ell(b(0.0, 71.0, 8.0), 11.5, 7.5, 44.0, saddle, TRUNK), fwdB, 2.2, 3.0)
        ell(b(0.0, 47.0, 4.0), 9.0, 6.0, 22.0, belly, TRUNK)
        ell(b(0.0, 50.0, 38.0), 10.0, 12.0, 10.0, belly, TRUNK)

        // ---- neck and ruff, then the head on the end of it
        val neckBase = b(0.0, 70.0, 44.0)
        val neckDir = (body.dir(Rot.pitch(-(38.0 + r.neck)).apply(P3.Z))).norm()
        val headAt = neckBase + Rot.yaw(r.turn * 0.4).apply(neckDir) * (24.0 * k)
        joints[HEAD] = headAt
        cone(neckBase, headAt, 11.0, 8.0, fur, TRUNK)
        // the ruff: thick fur round the throat and over the shoulders
        val ruff = ell(neckBase + neckDir * (6.0 * k) - upB * (1.0 * k), 17.0, 18.5, 15.0, fur, TRUNK)
        shag(ruff, neckDir, 3.4, 4.0)
        // the head frame: forward along the muzzle, turned and nodded
        val headRot = Rot.yaw(r.turn) * Rot.pitch(r.nod + r.pitch * 0.5 + 8.0 - r.neck * 0.3)
        fun h(x: Double, y: Double, z: Double) = headAt + headRot.apply(P3(x, y, z) * (k * HEAD_K))
        val hf = Frame(headRot.apply(P3.X), headRot.apply(P3.Y), headRot.apply(P3.Z))
        val hz = headRot.apply(P3.Z); val hy = headRot.apply(P3.Y); val hx = headRot.apply(P3.X)
        // a broad skull with a clear step down to the muzzle under heavy brows
        shag(ell(h(0.0, 1.5, 1.0), 9.5, 8.0, 9.5, fur, HEAD, hf), hz, 1.0, 5.0)
        ell(h(0.0, 5.5, -0.5), 7.0, 3.5, 7.5, saddle, HEAD, hf)
        for (s in listOf(-1.0, 1.0)) ell(h(s * 4.6, -4.0, 4.0), 3.4, 3.0, 5.0, cheek, HEAD, hf)
        // the muzzle sets on low and narrows to a black nose
        val snout = h(0.0, -2.2, 8.5); val tip = h(0.0, -2.8, 20.0)
        snoutTip = h(0.0, -4.5, 21.0)
        cone(snout, tip, 5.0, 3.3, fur, HEAD)
        add(Ellipsoid(h(0.0, 1.0, 13.0), P3(2.7 * k, 1.4 * k, 6.5 * k), hf, BodyPart.HEAD, HEAD), dark)
        // the nose lifts and the muzzle wrinkles behind it as the lips draw back
        val sn = r.snarl.coerceIn(0.0, 1.0)
        add(Ellipsoid(tip + hz * (2.6 * k * HEAD_K) + hy * ((0.9 + 0.7 * sn) * k * HEAD_K), P3(2.2 * k, 1.7 * k, 1.8 * k), hf, BodyPart.HEAD, DETAIL), nose)
        if (sn > 0.25) for (w in 0..2) cone(h(-1.8, 1.9 + 0.25 * w, 10.0 + w * 2.0), h(1.8, 1.9 + 0.25 * w, 10.0 + w * 2.0), 0.3 * sn, 0.3 * sn, dark, HEAD)
        // the lower jaw, swung open about its hinge below the ear
        val hinge = h(0.0, -5.0, 2.0)
        val jawRot = headRot * Rot.pitch(3.0 + 36.0 * r.mouth)
        fun j(x: Double, y: Double, z: Double) = hinge + jawRot.apply(P3(x, y, z) * (k * HEAD_K))
        cone(j(0.0, 0.0, 2.0), j(0.0, -0.4, 16.0), 3.3, 2.2, cheek, JAW)
        // the lips: a dark line down each side, curled up and back off the fangs in a snarl
        for (s in listOf(-1.0, 1.0)) {
            cone(h(s * 3.4, -4.6, 6.5 + sn * 2.5), h(s * 3.0, -4.4 + sn * 1.4, 14.0), 0.55, 0.5, nose, DETAIL)
            cone(h(s * 3.0, -4.4 + sn * 1.4, 14.0), h(s * 2.6, -5.0 + sn * 0.6, 20.5), 0.5, 0.4, nose, DETAIL)
        }
        // the dark maw and the tongue between the jaws as they part
        if (r.mouth > 0.3) {
            add(Ellipsoid(h(0.0, -5.6, 10.0).lerp(j(0.0, 0.5, 10.0), 0.5), P3(2.4 * k, (0.8 + 2.4 * r.mouth) * k, 6.5 * k), hf, BodyPart.HEAD, DETAIL), maw)
            cone(j(0.0, 1.4, 4.0), j(0.0, 1.6, 13.0), 1.8, 1.4, gum, DETAIL)
        }
        // gums and teeth: long fangs over the lower jaw, bared as soon as it snarls
        val open = max(r.mouth, sn * 0.6)
        if (open > 0.2) {
            add(Ellipsoid(h(0.0, -4.4 + sn * 0.6, 13.5), P3(2.6 * k, 1.0 * k + sn * 0.6 * k, 6.5 * k), hf, BodyPart.HEAD, DETAIL), gum)
            for (s in listOf(-1.0, 1.0)) {
                cone(h(s * 2.3, -4.0, 17.6), h(s * 2.0, -8.6, 18.2), 1.15, 0.12, tooth, DETAIL)
                cone(j(s * 1.8, 0.4, 13.6), j(s * 1.7, 3.8, 14.0), 0.95, 0.12, tooth, DETAIL)
                for (t in 0..2) cone(h(s * 2.5, -4.4, 15.2 - t * 2.3), h(s * 2.5, -6.3, 15.0 - t * 2.3), 0.6, 0.15, tooth, DETAIL)
                cone(h(s * 0.9, -4.6, 19.6), h(s * 0.9, -5.9, 19.8), 0.5, 0.2, tooth, DETAIL)
            }
        }
        // eyes, narrowed under brows drawn down towards the nose
        for (s in listOf(-1.0, 1.0)) {
            val e = h(s * 4.4, 2.3, 8.2)
            val slit = 1.0 - 0.35 * sn
            if (r.eyes > 0.5) {
                add(Ellipsoid(e, P3(1.9 * k, 1.1 * slit * k, 1.3 * k), hf, BodyPart.HEAD, DETAIL), pupil)
                add(Ellipsoid(e + hz * (0.25 * k) + hx * (s * 0.35 * k), P3(1.5 * k, 0.8 * slit * k, 1.1 * k), hf, BodyPart.HEAD, DETAIL), eye)
                add(Ellipsoid(e + hz * (0.6 * k) + hx * (s * 0.6 * k), P3(0.4 * k, 0.65 * slit * k, 0.45 * k), hf, BodyPart.HEAD, DETAIL), pupil)
            } else cone(e - hx * (1.4 * k), e + hx * (1.4 * k), 0.35, 0.35, dark, DETAIL)
            // the brow ridge, slanting down to the nose: the scowl
            cone(h(s * 6.6, 5.2 + 0.4 * sn, 4.6), h(s * 2.0, 3.3 - 0.6 * sn, 9.8), 1.5, 1.1, saddle, HEAD)
        }
        if (coat.scar) cone(h(4.0, 6.0, 3.0), h(5.6, -1.5, 9.0), 0.45, 0.35, scar, DETAIL)
        // ears: soft, cupped triangles, pricked up or laid back flat on the skull
        for (s in listOf(-1.0, 1.0)) {
            val back = (-r.ears).coerceIn(-1.0, 1.0)
            val up = (hy * (1.0 - 0.75 * max(back, 0.0)) - hz * (0.25 + 0.85 * max(back, 0.0)) + hx * (s * 0.3)).norm()
            val len = if (coat.tornEar && s > 0) 7.0 else 11.0
            val base = h(s * 4.6, 5.0, -1.5)
            val face = (hz + hx * (s * 0.9)).norm().let { (it - up * (it dot up)).norm() }
            val cone = RoundCone(base, base + up * (len * k * HEAD_K), 4.0 * k, 0.5 * k, BodyPart.HEAD, EAR)
            add(Squash(cone, base, Frame((up cross face).norm(), up, face), P3(1.0, 1.0, 0.45), BodyPart.HEAD, EAR), dark)
        }

        // ---- legs: front ones from the shoulder blade, hind ones from the hip, each foot where the rig puts it
        val ground = 0.0
        fun paw(at: P3, dir: P3) {
            val flat = P3(dir.x, 0.0, dir.z).let { if (it.len() < 0.3) P3.Z else it.norm() }
            add(Ellipsoid(at + P3(0.0, 2.0 * k, 1.5 * k), P3(3.6 * k, 2.4 * k, 4.8 * k), Frame.along(P3.Y, flat), BodyPart.FOOT, DETAIL), dark)
            add(Ellipsoid(at + P3(0.0, 0.7 * k, 2.4 * k), P3(2.6 * k, 0.8 * k, 2.6 * k), Frame.IDENTITY, BodyPart.FOOT, DETAIL), pad)
        }
        fun frontLeg(side: Double, off: HeroFigure.V, g: Int) {
            val shoulder = b(side * 8.0, 62.0, 34.0)
            joints[g] = shoulder
            val foot = P3((side * 7.0 + r.side + off.r) * k, ground, (36.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            val wrist = foot + P3(0.0, 8.0 * k, -1.0 * k)
            val elbow = ik(shoulder, wrist, 24.0 * k, 26.0 * k, -fwdB)
            shag(cone(shoulder, elbow, 7.5, 5.0, fur, g), elbow - shoulder, 1.2, side)
            cone(elbow, wrist, 4.3, 3.1, fur, g)
            cone(wrist, foot + P3(0.0, 2.0 * k, 1.0 * k), 3.0, 2.9, fur, g)
            paw(foot, fwdB)
        }
        fun hindLeg(side: Double, off: HeroFigure.V, g: Int) {
            val hip = b(side * 9.0, 60.0, -34.0)
            joints[g] = hip
            val foot = P3((side * 8.0 + r.side + off.r) * k, ground, (-40.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            // the long hind foot from the paw up to the high heel, tipped back
            val hock = foot + P3(0.0, 17.0 * k, -5.0 * k)
            val knee = ik(hip, hock, 26.0 * k, 26.0 * k, fwdB)
            // the heavy thigh, the lean shank, the long foot
            shag(cone(hip + upB * (2.0 * k), knee, 10.5, 5.4, fur, g), knee - hip, 1.4, side + 2.0)
            cone(knee, hock, 4.4, 3.0, fur, g)
            cone(hock, foot + P3(0.0, 2.0 * k, 0.5 * k), 3.0, 2.7, fur, g)
            paw(foot, fwdB)
        }
        frontLeg(-1.0, r.fl, LEG_FL); frontLeg(1.0, r.fr, LEG_FR)
        hindLeg(-1.0, r.hl, LEG_HL); hindLeg(1.0, r.hr, LEG_HR)

        // ---- the tail: bushy, hanging in a curve from the rump
        var p = b(0.0, 64.0, -46.0)
        joints[TAIL] = p
        var d = body.dir(Rot.yaw(r.tailSwing).apply(Rot.pitch(-(62.0 - r.tail * 45.0)).apply(P3(0.0, 0.0, -1.0)))).norm()
        val radii = doubleArrayOf(4.0, 5.6, 6.2, 5.4, 3.4)
        for (i in 0 until 5) {
            val n = p + d * (9.0 * k)
            val s = cone(p, n, radii[i], radii.getOrElse(i + 1) { 1.6 }, if (i == 4) saddle else fur, TAIL)
            shag(s, d, 1.8, 7.0 + i)
            p = n
            // it hangs more steeply towards the tip
            d = (d + P3(0.0, -0.22, 0.0)).norm()
        }
        return out.toList()
    }

    // ---------------------------------------------------------------- the wild boar

    private val hoof = Mat(Ramp.of(argb(0x1C1614)), shine = 0.35, grain = 0.05)
    private val tusk = Mat(Ramp.of(argb(0xEAE0C4)), shine = 0.55, grain = 0.06)
    private val tuskRoot = Mat(Ramp.of(argb(0x8A7A58)), grain = 0.1)
    private val disc = Mat(Ramp.of(argb(0x4A3034)), shine = 0.5, grain = 0.06)
    private val coarse = Mat(Ramp.of(argb(coat.fur)), grain = 0.26)
    private val bristle = Mat(Ramp.of(argb(mix(argb(coat.saddle), argb(0x080606), 0.3))), grain = 0.2)

    /**
     * A wild boar of about 85 cm at the shoulder: a deep, high front under a crest of bristles that rises when it is
     * angry, a long wedge of a head with a flat snout disc, curved tusks out of both jaws, small red eyes, slim legs on
     * cloven hooves and a thin tail with a tuft.
     */
    private fun boar(r: Rig) {
        val hip0 = P3(0.0, 62.0, -40.0) * k
        val body = Xf(Rot.pitch(r.pitch), hip0, P3(r.side * k, -r.crouch * k, r.fwd * k))
        fun b(x: Double, y: Double, z: Double) = body.apply(P3(x, y, z) * k)
        val fwdB = body.dir(P3.Z); val upB = body.dir(P3.Y)
        val bf = Frame(body.dir(P3.X), upB, fwdB)
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = bf) = add(Ellipsoid(c, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, c: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a, c, ra * k, rb * k, BodyPart.ARM, g), m)
        fun shag(s: Solid, flow: P3, depth: Double, seed: Double) { out.remove(s); add(Shag(s, flow.norm(), depth * k, seed), s.mat!!) }

        // ---- the trunk: the heavy front, the barrel, the narrower rump
        shag(ell(b(0.0, 66.0, 24.0), 19.0 + r.breath * 0.6, 28.0 + r.breath * 0.8, 28.0, coarse, TRUNK), fwdB, 2.6, 0.0)
        shag(ell(b(0.0, 59.0, -10.0), 17.5, 21.0, 28.0, coarse, TRUNK), fwdB, 2.4, 1.0)
        shag(ell(b(0.0, 58.0, -38.0), 14.0, 17.0, 14.0, coarse, TRUNK), fwdB, 2.0, 2.0)
        ell(b(0.0, 42.0, 0.0), 14.0, 9.0, 34.0, belly, TRUNK)
        // the dark crest down the spine, and its bristles, raised high when it is angry
        shag(ell(b(0.0, 86.0, 18.0), 7.5, 9.0, 32.0, saddle, TRUNK), fwdB, 4.0, 3.0)
        val rage = (0.5 + 0.5 * r.snarl).coerceIn(0.0, 1.0)
        for (i in 0..16) {
            val z = 50.0 - i * 5.5
            val top = 92.0 - 0.0075 * (z - 24.0) * (z - 24.0)
            val len = (8.0 + 9.0 * rage) * (1.0 - kotlin.math.abs(z - 24.0) / 64.0).coerceAtLeast(0.15)
            for (sx in listOf(-2.0, 0.0, 2.0)) {
                val base = b(sx, top - 4.0, z + sx)
                cone(base, base + (upB * 1.0 - fwdB * 0.5 + body.dir(P3.X) * (sx * 0.1)).norm() * (len * k * (if (sx == 0.0) 1.0 else 0.8)), 1.8, 0.15, bristle, EAR)
            }
        }

        // ---- the short, thick neck and the long head on its end, held low
        val neckBase = b(0.0, 70.0, 44.0)
        val neckDir = body.dir(Rot.pitch(2.0 - r.neck).apply(P3.Z)).norm()
        val headAt = neckBase + Rot.yaw(r.turn * 0.4).apply(neckDir) * (12.0 * k)
        joints[HEAD] = headAt
        shag(cone(neckBase, headAt, 19.0, 15.5, coarse, TRUNK), neckDir, 2.4, 4.0)
        val hk = k * 1.25
        val headRot = Rot.yaw(r.turn) * Rot.pitch(r.nod + r.pitch * 0.5 + 9.0 - r.neck * 0.3)
        fun h(x: Double, y: Double, z: Double) = headAt + headRot.apply(P3(x, y, z) * hk)
        val hf = Frame(headRot.apply(P3.X), headRot.apply(P3.Y), headRot.apply(P3.Z))
        val hz = headRot.apply(P3.Z); val hy = headRot.apply(P3.Y); val hx = headRot.apply(P3.X)
        // a high skull falling away in a long straight wedge to the snout
        shag(ell(h(0.0, 3.0, 0.0), 11.5, 12.5, 13.0, coarse, HEAD, hf), hz, 1.6, 5.0)
        shag(cone(h(0.0, 1.0, 6.0), h(0.0, -4.0, 30.0), 10.5, 5.6, coarse, HEAD), hz, 1.0, 5.5)
        ell(h(0.0, 7.0, 4.0), 6.0, 4.0, 12.0, saddle, HEAD, hf)
        // the bearded jowls along the jaw
        for (sx in listOf(-1.0, 1.0)) shag(ell(h(sx * 7.6, -5.5, 8.0), 3.6, 5.0, 8.0, coarse, HEAD, hf), -hy, 2.2, 6.0 + sx)
        // the snout disc with its two nostrils, wrinkled back when it snarls
        val sn = r.snarl.coerceIn(0.0, 1.0)
        add(Ellipsoid(h(0.0, -4.4 + sn * 0.6, 31.0), P3(5.8 * hk, 4.8 * hk, 1.8 * hk), hf, BodyPart.HEAD, DETAIL), disc)
        for (sx in listOf(-1.0, 1.0)) add(Ellipsoid(h(sx * 1.9, -4.6 + sn * 0.6, 32.4), P3(1.1 * hk, 1.5 * hk, 0.8 * hk), hf, BodyPart.HEAD, DETAIL), pupil)
        if (sn > 0.25) for (w in 0..2) cone(h(-4.5, 1.2 + 0.3 * w, 20.0 + w * 2.6), h(4.5, 1.2 + 0.3 * w, 20.0 + w * 2.6), 0.45 * sn, 0.45 * sn, dark, HEAD)
        // the lower jaw, swung open about its hinge
        val hinge = h(0.0, -8.0, 6.0)
        val jawRot = headRot * Rot.pitch(3.0 + 30.0 * r.mouth)
        fun j(x: Double, y: Double, z: Double) = hinge + jawRot.apply(P3(x, y, z) * hk)
        cone(j(0.0, 0.0, 2.0), j(0.0, -0.5, 22.0), 5.2, 3.2, cheek, JAW)
        if (r.mouth > 0.25) {
            add(Ellipsoid(h(0.0, -7.6, 15.0).lerp(j(0.0, 0.8, 15.0), 0.5), P3(3.4 * hk, (0.8 + 3.0 * r.mouth) * hk, 8.0 * hk), hf, BodyPart.HEAD, DETAIL), maw)
            cone(j(0.0, 1.6, 6.0), j(0.0, 1.8, 17.0), 2.4, 1.8, gum, DETAIL)
            for (sx in listOf(-1.0, 1.0)) for (t in 0..2) cone(h(sx * 3.4, -7.0, 22.0 - t * 3.0), h(sx * 3.4, -8.6, 22.0 - t * 3.0), 0.7, 0.2, tooth, DETAIL)
        }
        // the tusks: long ones curving up and back out of the lower jaw, short whetters out of the upper one
        for (sx in listOf(-1.0, 1.0)) {
            val p0 = j(sx * 3.8, 0.8, 16.5); val p1 = j(sx * 6.4, 6.0, 19.5); val p2 = j(sx * 7.8, 11.5, 17.6); val p3 = j(sx * 7.2, 14.6, 12.6)
            cone(p0, p1, 2.3, 1.9, tuskRoot, DETAIL); cone(p1, p2, 1.9, 1.3, tusk, DETAIL); cone(p2, p3, 1.3, 0.2, tusk, DETAIL)
            val q0 = h(sx * 4.0, -6.0, 21.5); val q1 = h(sx * 5.8, -3.0, 22.6); val q2 = h(sx * 6.4, -0.4, 20.2)
            cone(q0, q1, 1.5, 1.0, tusk, DETAIL); cone(q1, q2, 1.0, 0.15, tusk, DETAIL)
        }
        // small eyes, deep under a heavy brow, glowing red
        for (sx in listOf(-1.0, 1.0)) {
            val e = h(sx * 7.6, 4.0, 11.0)
            val slit = 1.0 - 0.3 * sn
            if (r.eyes > 0.5) {
                add(Ellipsoid(e, P3(1.7 * hk, 1.2 * slit * hk, 1.3 * hk), hf, BodyPart.HEAD, DETAIL), pupil)
                add(Ellipsoid(e + hz * (0.3 * hk) + hx * (sx * 0.4 * hk), P3(1.3 * hk, 0.85 * slit * hk, 1.0 * hk), hf, BodyPart.HEAD, DETAIL), eye)
            } else cone(e - hx * (1.4 * hk), e + hx * (1.4 * hk), 0.4, 0.4, dark, DETAIL)
            cone(h(sx * 9.5, 7.4 + 0.3 * sn, 6.0), h(sx * 4.5, 5.6 - 0.6 * sn, 13.5), 1.8, 1.3, saddle, HEAD)
        }
        if (coat.scar) { cone(h(3.0, 2.0, 18.0), h(6.6, -4.0, 25.0), 0.55, 0.45, scar, DETAIL); cone(h(-8.0, 5.0, 2.0), h(-9.5, -2.0, 8.0), 0.5, 0.4, scar, DETAIL) }
        // small, hairy, pointed ears, laid back when it charges
        for (sx in listOf(-1.0, 1.0)) {
            val back = (-r.ears).coerceIn(-1.0, 1.0)
            val up = (hy * (1.0 - 0.6 * max(back, 0.0)) - hz * (0.35 + 0.8 * max(back, 0.0)) + hx * (sx * 0.55)).norm()
            val len = if (coat.tornEar && sx > 0) 6.0 else 11.0
            val base = h(sx * 7.0, 10.0, -1.0)
            val face = (hz + hx * (sx * 0.9)).norm().let { (it - up * (it dot up)).norm() }
            val c = RoundCone(base, base + up * (len * hk), 3.6 * k, 0.6 * k, BodyPart.HEAD, EAR)
            add(Squash(c, base, Frame((up cross face).norm(), up, face), P3(1.0, 1.0, 0.5), BodyPart.HEAD, EAR), saddle)
        }
        snoutTip = h(0.0, -2.0, 32.0)

        // ---- legs: slim for so heavy a body, on cloven hooves
        fun hooves(at: P3, dir: P3) {
            val flat = P3(dir.x, 0.0, dir.z).let { if (it.len() < 0.3) P3.Z else it.norm() }
            val side = (P3.Y cross flat).norm()
            for (sx in listOf(-1.0, 1.0)) add(Ellipsoid(at + side * (sx * 1.5 * k) + P3(0.0, 2.4 * k, 0.0) + flat * (1.6 * k), P3(1.6 * k, 2.6 * k, 3.0 * k), Frame.along(P3.Y, flat), BodyPart.FOOT, DETAIL), hoof)
            for (sx in listOf(-1.0, 1.0)) add(Ellipsoid(at + side * (sx * 2.0 * k) + P3(0.0, 5.0 * k, -2.4 * k), P3(0.9 * k, 1.3 * k, 1.1 * k), Frame.IDENTITY, BodyPart.FOOT, DETAIL), hoof)
        }
        fun frontLeg(side: Double, off: HeroFigure.V, g: Int) {
            val shoulder = b(side * 11.0, 58.0, 34.0)
            joints[g] = shoulder
            val foot = P3((side * 9.0 + r.side + off.r) * k, 0.0, (44.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            val wrist = foot + P3(0.0, 11.0 * k, -0.5 * k)
            val elbow = ik(shoulder, wrist, 25.0 * k, 25.0 * k, -fwdB)
            shag(cone(shoulder, elbow, 9.0, 5.2, coarse, g), elbow - shoulder, 1.6, side)
            cone(elbow, wrist, 4.6, 3.4, dark, g)
            cone(wrist, foot + P3(0.0, 4.0 * k, 0.6 * k), 3.2, 2.8, dark, g)
            hooves(foot, fwdB)
        }
        fun hindLeg(side: Double, off: HeroFigure.V, g: Int) {
            val hip = b(side * 10.5, 60.0, -38.0)
            joints[g] = hip
            val foot = P3((side * 9.0 + r.side + off.r) * k, 0.0, (-46.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            val hock = foot + P3(0.0, 17.0 * k, -4.0 * k)
            val knee = ik(hip, hock, 26.0 * k, 24.0 * k, fwdB)
            shag(cone(hip + upB * (2.0 * k), knee, 12.0, 5.6, coarse, g), knee - hip, 1.8, side + 2.0)
            cone(knee, hock, 4.8, 3.4, dark, g)
            cone(hock, foot + P3(0.0, 4.0 * k, 0.4 * k), 3.2, 2.8, dark, g)
            hooves(foot, fwdB)
        }
        frontLeg(-1.0, r.fl, LEG_FL); frontLeg(1.0, r.fr, LEG_FR)
        hindLeg(-1.0, r.hl, LEG_HL); hindLeg(1.0, r.hr, LEG_HR)

        // ---- the thin tail with its tuft, swishing
        var p = b(0.0, 70.0, -54.0)
        joints[TAIL] = p
        var d = body.dir(Rot.yaw(r.tailSwing).apply(Rot.pitch(-(70.0 - r.tail * 40.0)).apply(P3(0.0, 0.0, -1.0)))).norm()
        for (i in 0 until 4) {
            val n = p + d * (6.0 * k)
            cone(p, n, 1.7 - i * 0.25, 1.45 - i * 0.25, fur, TAIL)
            p = n
            d = (d + P3(0.0, -0.18, 0.0) + body.dir(P3.X) * (0.08 * kotlin.math.sin(i + r.tailSwing * 0.05))).norm()
        }
        shag(ell(p + d * (3.0 * k), 2.2, 2.2, 4.5, saddle, TAIL, Frame.along(d)), d, 1.6, 9.0)
    }

    // ---------------------------------------------------------------- the giant rat

    private val skin = Mat(Ramp.of(argb(0xA27268)), grain = 0.14)
    private val tailSkin = Mat(Ramp.of(argb(0x7E625E)), shine = 0.2, grain = 0.3)
    private val earSkin = Mat(Ramp.of(argb(0x86605C)), grain = 0.1)
    private val scab = Mat(Ramp.of(argb(0x5A2622)), shine = 0.3, grain = 0.2)
    private val incisor = Mat(Ramp.of(argb(0xD89A38)), shine = 0.5, grain = 0.05)
    private val claw = Mat(Ramp.of(argb(0x2A2220)), shine = 0.3)

    /**
     * A giant rat (SRD small, about 30 cm at the shoulder and 70 cm long without the tail): a hunched back of mangy
     * fur with raw bald patches, a long pointed head with orange gnawing teeth, beady red eyes, round naked ears, pink
     * clawed hands and a long, naked, ringed tail trailing on the ground.
     */
    private fun rat(r: Rig) {
        val hip0 = P3(0.0, 26.0, -22.0) * k
        val body = Xf(Rot.pitch(r.pitch), hip0, P3(r.side * k, -r.crouch * k, r.fwd * k))
        fun b(x: Double, y: Double, z: Double) = body.apply(P3(x, y, z) * k)
        val fwdB = body.dir(P3.Z); val upB = body.dir(P3.Y)
        val bf = Frame(body.dir(P3.X), upB, fwdB)
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = bf) = add(Ellipsoid(c, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, c: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a, c, ra * k, rb * k, BodyPart.ARM, g), m)
        fun shag(s: Solid, flow: P3, depth: Double, seed: Double) { out.remove(s); add(Shag(s, flow.norm(), depth * k, seed), s.mat!!) }

        // ---- the hunched trunk: narrow chest, the back arched highest over the loins, the round rump
        shag(ell(b(0.0, 22.0, 12.0), 8.5 + r.breath * 0.4, 9.5 + r.breath * 0.5, 12.0, fur, TRUNK), fwdB, 1.4, 0.0)
        shag(ell(b(0.0, 27.0, -6.0), 10.0, 12.0, 14.0, fur, TRUNK), fwdB, 1.6, 1.0)
        shag(ell(b(0.0, 24.0, -23.0), 9.5, 11.0, 10.0, fur, TRUNK), fwdB, 1.4, 2.0)
        shag(ell(b(0.0, 34.0, -8.0), 6.0, 4.0, 20.0, saddle, TRUNK), fwdB, 1.2, 3.0)
        ell(b(0.0, 16.0, -4.0), 8.0, 5.0, 18.0, belly, TRUNK)
        // the mange: raw, scabbed patches where the fur has fallen out
        val patches = if (coat.scar) listOf(V3(9.8, 27.0, -10.0, 4.2), V3(-9.0, 30.0, 0.0, 3.2), V3(7.0, 33.0, -22.0, 3.0), V3(6.6, 21.0, 13.0, 2.6))
            else listOf(V3(10.0, 26.0, -8.0, 3.4), V3(-8.4, 28.0, -20.0, 2.8))
        for (q in patches) {
            ell(b(q.x * 0.97, q.y, q.z), q.r * 0.5, q.r, q.r * 1.3, skin, DETAIL)
            ell(b(q.x * 1.02, q.y + q.r * 0.2, q.z + q.r * 0.3), q.r * 0.35, q.r * 0.5, q.r * 0.6, scab, DETAIL)
        }

        // ---- neck and the long pointed head
        val neckBase = b(0.0, 25.0, 22.0)
        val neckDir = body.dir(Rot.pitch(-(8.0 + r.neck)).apply(P3.Z)).norm()
        val headAt = neckBase + Rot.yaw(r.turn * 0.4).apply(neckDir) * (6.0 * k)
        joints[HEAD] = headAt
        shag(cone(neckBase, headAt, 7.5, 6.0, fur, TRUNK), neckDir, 1.2, 4.0)
        val hk = k * 1.45
        val headRot = Rot.yaw(r.turn) * Rot.pitch(r.nod + r.pitch * 0.5 + 10.0 - r.neck * 0.3)
        fun h(x: Double, y: Double, z: Double) = headAt + headRot.apply(P3(x, y, z) * hk)
        val hf = Frame(headRot.apply(P3.X), headRot.apply(P3.Y), headRot.apply(P3.Z))
        val hz = headRot.apply(P3.Z); val hy = headRot.apply(P3.Y); val hx = headRot.apply(P3.X)
        shag(ell(h(0.0, 1.0, 1.0), 5.2, 4.8, 6.0, fur, HEAD, hf), hz, 0.8, 5.0)
        shag(cone(h(0.0, 0.4, 4.0), h(0.0, -1.0, 13.0), 4.2, 1.7, fur, HEAD), hz, 0.5, 5.5)
        ell(h(0.0, 3.6, 2.0), 3.0, 1.6, 5.0, saddle, HEAD, hf)
        // the twitching pink nose
        val sn = r.snarl.coerceIn(0.0, 1.0)
        add(Ellipsoid(h(0.0, -0.9 + sn * 0.3, 13.9), P3(1.2 * hk, 1.0 * hk, 0.9 * hk), hf, BodyPart.HEAD, DETAIL), skin)
        // the lower jaw
        val hinge = h(0.0, -2.6, 2.5)
        val jawRot = headRot * Rot.pitch(3.0 + 34.0 * r.mouth)
        fun j(x: Double, y: Double, z: Double) = hinge + jawRot.apply(P3(x, y, z) * hk)
        cone(j(0.0, 0.0, 1.0), j(0.0, -0.2, 9.0), 2.3, 1.1, belly, JAW)
        if (r.mouth > 0.25) {
            add(Ellipsoid(h(0.0, -2.6, 7.0).lerp(j(0.0, 0.4, 7.0), 0.5), P3(1.6 * hk, (0.4 + 1.6 * r.mouth) * hk, 4.0 * hk), hf, BodyPart.HEAD, DETAIL), maw)
            for (sx in listOf(-1.0, 1.0)) for (t in 0..2) cone(h(sx * 1.4, -2.4, 9.0 - t * 1.6), h(sx * 1.4, -3.2, 9.0 - t * 1.6), 0.35, 0.12, tooth, DETAIL)
        }
        // the gnawing teeth: long, chisel-edged and orange, always showing
        for (sx in listOf(-1.0, 1.0)) {
            cone(h(sx * 0.55, -1.8, 12.4), h(sx * 0.55, -4.6 - sn * 0.4, 12.9), 0.62, 0.42, incisor, DETAIL)
            cone(j(sx * 0.5, 0.2, 9.2), j(sx * 0.5, 2.9, 10.1), 0.55, 0.38, incisor, DETAIL)
        }
        // beady, bulging eyes, glowing red
        for (sx in listOf(-1.0, 1.0)) {
            val e = h(sx * 3.1, 2.0, 5.2)
            if (r.eyes > 0.5) {
                add(Ellipsoid(e, P3(1.35 * hk, 1.25 * hk, 1.3 * hk), hf, BodyPart.HEAD, DETAIL), pupil)
                add(Ellipsoid(e + hz * (0.35 * hk) + hx * (sx * 0.4 * hk), P3(1.0 * hk, 0.95 * hk, 0.95 * hk), hf, BodyPart.HEAD, DETAIL), eye)
            } else cone(e - hx * (1.1 * hk), e + hx * (1.1 * hk), 0.3, 0.3, dark, DETAIL)
        }
        // round, thin, naked ears: one torn to a ragged half
        for (sx in listOf(-1.0, 1.0)) {
            val back = (-r.ears).coerceIn(-1.0, 1.0)
            val up = (hy * (1.0 - 0.5 * max(back, 0.0)) - hz * (0.2 + 0.7 * max(back, 0.0)) + hx * (sx * 0.6)).norm()
            val face = (hz + hx * (sx * 0.5)).norm().let { (it - up * (it dot up)).norm() }
            val torn = coat.tornEar && sx > 0
            val c = h(sx * 3.4, 4.4, -0.5) + up * ((if (torn) 1.6 else 2.6) * hk)
            add(Ellipsoid(c, P3(3.0 * hk, (if (torn) 1.9 else 3.2) * hk, 0.5 * hk), Frame((up cross face).norm(), up, face), BodyPart.HEAD, EAR), earSkin)
            add(Ellipsoid(c + face * (0.35 * hk), P3(2.0 * hk, (if (torn) 1.2 else 2.2) * hk, 0.3 * hk), Frame((up cross face).norm(), up, face), BodyPart.HEAD, DETAIL), scab)
        }
        if (coat.scar) cone(h(-2.0, 3.4, 1.0), h(-4.4, -1.0, 6.0), 0.35, 0.28, scab, DETAIL)
        snoutTip = h(0.0, -3.4, 13.0)

        // ---- short legs on pink, clawed hands and long hind feet
        fun hand(at: P3, dir: P3, long: Boolean) {
            val flat = P3(dir.x, 0.0, dir.z).let { if (it.len() < 0.3) P3.Z else it.norm() }
            val side = (P3.Y cross flat).norm()
            val len = if (long) 3.6 else 2.2
            add(Ellipsoid(at + P3(0.0, 0.9 * k, 0.0) + flat * (len * 0.4 * k), P3(1.7 * k, 0.9 * k, len * k), Frame.along(P3.Y, flat), BodyPart.FOOT, DETAIL), skin)
            for (t in -1..1) { val tp = at + flat * ((len * 0.9 + 0.6) * k) + side * (t * 0.9 * k) + P3(0.0, 0.6 * k, 0.0); cone(tp, tp + flat * (1.4 * k) - P3(0.0, 0.5 * k, 0.0), 0.32, 0.08, claw, DETAIL) }
        }
        fun frontLeg(side: Double, off: HeroFigure.V, g: Int) {
            val shoulder = b(side * 6.5, 20.0, 14.0)
            joints[g] = shoulder
            val foot = P3((side * 5.5 + r.side + off.r) * k, 0.0, (17.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            val wrist = foot + P3(0.0, 3.0 * k, -0.4 * k)
            val elbow = ik(shoulder, wrist, 9.5 * k, 9.5 * k, -fwdB)
            shag(cone(shoulder, elbow, 4.4, 2.6, fur, g), elbow - shoulder, 0.8, side)
            cone(elbow, wrist, 2.2, 1.4, fur, g)
            cone(wrist, foot + P3(0.0, 1.0 * k, 0.6 * k), 1.3, 1.1, skin, g)
            hand(foot, fwdB, false)
        }
        fun hindLeg(side: Double, off: HeroFigure.V, g: Int) {
            val hip = b(side * 7.5, 24.0, -22.0)
            joints[g] = hip
            val foot = P3((side * 7.0 + r.side + off.r) * k, 0.0, (-22.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
            val hock = foot + P3(0.0, 5.0 * k, -4.0 * k)
            val knee = ik(hip, hock, 11.0 * k, 9.0 * k, fwdB)
            shag(cone(hip + upB * (1.0 * k), knee, 5.4, 2.8, fur, g), knee - hip, 1.0, side + 2.0)
            cone(knee, hock, 2.4, 1.4, fur, g)
            cone(hock, foot + P3(0.0, 0.8 * k, 1.0 * k), 1.3, 1.1, skin, g)
            hand(foot, fwdB, true)
        }
        frontLeg(-1.0, r.fl, LEG_FL); frontLeg(1.0, r.fr, LEG_FR)
        hindLeg(-1.0, r.hl, LEG_HL); hindLeg(1.0, r.hr, LEG_HR)

        // ---- the naked, ringed tail: down from the rump, then trailing along the ground in a curve
        var p = b(0.0, 22.0, -33.0)
        joints[TAIL] = p
        var d = body.dir(Rot.yaw(r.tailSwing).apply(Rot.pitch(-(40.0 - r.tail * 30.0)).apply(P3(0.0, 0.0, -1.0)))).norm()
        val side = body.dir(P3.X)
        // fallen over, the ground is no longer below the tail: it trails straight on from the rump instead
        val fallen = (abs(r.fallS) + abs(r.fallF)) > 25.0
        if (fallen) d = body.dir(P3(0.0, -0.15, -1.0)).norm()
        for (i in 0 until 11) {
            var n = p + d * (5.6 * k)
            // it lies on the ground once it gets there
            if (!fallen && n.y < 1.2 * k) n = P3(n.x, 1.2 * k, n.z)
            val ra = 2.3 - i * 0.18; val rb = 2.3 - (i + 1) * 0.18
            cone(p, n, ra, rb, tailSkin, TAIL)
            // the rings of scales
            if (i % 2 == 1) cone(p.lerp(n, 0.45), p.lerp(n, 0.55), ra + 0.12, rb + 0.12, scab, DETAIL)
            p = n
            // swinging from side to side; on its side that would be up and down, so then it lies still
            d = (d + (if (fallen) P3.O else P3(0.0, -0.16, 0.0)) + side * ((if (fallen) 0.0 else 0.14) * kotlin.math.sin(i * 0.7 + r.tailSwing * 0.04))).norm()
            if (!fallen && p.y <= 1.25 * k) d = P3(d.x, maxOf(d.y, 0.0), d.z).norm()
        }
    }

    /** A spot on the body with its size, for the rat's mange. */
    private class V3(val x: Double, val y: Double, val z: Double, val r: Double)

    /** How the parts melt into each other: the trunk smoothly, the legs and head into it near their joints. */
    fun groups(r: Rig): Groups {
        val g = Groups(COUNT)
        val q = when (kind) { Kind.WOLF -> 1.0; Kind.BOAR -> 1.2; Kind.RAT -> 0.45 }
        g.reach = 16.0 * k * q
        g.set(TRUNK, 5.0 * k * q)
        g.set(HEAD, 2.0 * k * q, TRUNK, joints[HEAD])
        g.set(JAW, 1.0 * k * q)
        g.set(EAR, 0.6 * k * q)
        g.set(DETAIL, 0.0)
        for (l in listOf(LEG_FL, LEG_FR, LEG_HL, LEG_HR)) g.set(l, 1.6 * k * q, TRUNK, joints[l])
        g.set(TAIL, 2.0 * k * q, TRUNK, joints[TAIL])
        return g
    }

    /** Where point [p] of pose [r] lands in a picture rendered with these numbers, in pixels. */
    fun project(p: P3, r: Rig, anchorX: Double, ground: Double, px: Double, pitch: Double = 15.0): Pair<Double, Double> {
        val v = SdfView(r.yaw, pitch, r.fallF, r.fallS).toView(p)
        return Pair(anchorX + v.x * px, ground - v.y * px)
    }

    /** Renders pose [r] into a [w] × [h] picture with the feet on [ground] at [anchorX]. */
    fun render(w: Int, h: Int, anchorX: Double, ground: Double, px: Double, r: Rig, pitch: Double = 15.0): PixelImage {
        val so = solids(r)
        // a body on its side rests on its flank, not sunk into the ground
        val flank = when (kind) { Kind.WOLF -> 13.0; Kind.BOAR -> 19.0; Kind.RAT -> 9.0 }
        val lift = (abs(sin(Math.toRadians(r.fallS))) * flank + abs(sin(Math.toRadians(r.fallF))) * flank * 0.75) * k
        val img = SdfRender.render(so, groups(r), { s, _ -> s.mat!! }, w, h, anchorX, ground - lift * px * cos(Math.toRadians(pitch)), px, r.yaw, pitch, fallF = r.fallF, fallS = r.fallS)
        val s = Sculpt(w, h)
        for (y in 0 until h) for (x in 0 until w) s.img.set(x, y, img.img[x, y])
        s.outline(argb(0x100A0C))
        return s.img
    }

    companion object {
        private fun hash(x: Int, y: Int, z: Int): Double {
            var n = x * 374761393 + y * 668265263 + z * 1274126177
            n = (n xor (n ushr 13)) * 1103515245
            return ((n xor (n ushr 16)) and 0xFFFF) / 65535.0
        }
        /** Smooth value noise, 0 to 1. */
        fun noise(x: Double, y: Double, z: Double): Double {
            val xi = kotlin.math.floor(x).toInt(); val yi = kotlin.math.floor(y).toInt(); val zi = kotlin.math.floor(z).toInt()
            fun f(t: Double) = t * t * (3 - 2 * t)
            val fx = f(x - xi); val fy = f(y - yi); val fz = f(z - zi)
            fun l(a: Double, b: Double, t: Double) = a + (b - a) * t
            return l(l(l(hash(xi, yi, zi), hash(xi + 1, yi, zi), fx), l(hash(xi, yi + 1, zi), hash(xi + 1, yi + 1, zi), fx), fy),
                l(l(hash(xi, yi, zi + 1), hash(xi + 1, yi, zi + 1), fx), l(hash(xi, yi + 1, zi + 1), hash(xi + 1, yi + 1, zi + 1), fx), fy), fz)
        }
        const val TRUNK = 0; const val HEAD = 1; const val JAW = 2; const val EAR = 3; const val DETAIL = 4
        const val LEG_FL = 5; const val LEG_FR = 6; const val LEG_HL = 7; const val LEG_HR = 8; const val TAIL = 9
        const val COUNT = 10
        /** The head a little larger than life, so the face reads at battle size. */
        private const val HEAD_K = 1.15
    }
}
