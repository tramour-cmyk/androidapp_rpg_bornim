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
class Beast(val size: Double = 1.0, val coat: WolfArt.Coat = WolfArt.GREY) {

    /** How the animal stands and moves. Angles in degrees; lengths in cm of a wolf of size 1. */
    data class Rig(
        /** The whole body forward (+) or back, and down (+) into a crouch. */
        val fwd: Double = 0.0, val crouch: Double = 0.0,
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
            return Rig(l(fwd, o.fwd), l(crouch, o.crouch), l(pitch, o.pitch), l(breath, o.breath), l(neck, o.neck), l(nod, o.nod), l(turn, o.turn),
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
    private val gum = Mat(Ramp.of(argb(0x5A1E22)), shine = 0.4)
    private val tooth = Mat(Ramp.of(argb(0xE8E0CC)), shine = 0.5)
    private val eye = Mat(Ramp.of(argb(coat.eye)), shine = 1.0, bias = 0.25)
    private val pupil = Mat(Ramp.of(argb(0x0C0808)), shine = 1.0)
    private val scar = Mat(Ramp.of(argb(0x8A5E5A)), grain = 0.1)
    private val pad = Mat(Ramp.of(argb(0x2A2422)), grain = 0.1)

    private val out = mutableListOf<Solid>()
    /** Where head, legs and tail join the trunk in the last pose built, so they melt into it there. */
    private val joints = HashMap<Int, P3>()
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
        // the body turns about the hips: forward and down by the rig, nose down by its pitch
        val hip0 = P3(0.0, 62.0, -34.0) * k
        val body = Xf(Rot.pitch(r.pitch), hip0, P3(0.0, -r.crouch * k, r.fwd * k))
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
        cone(snout, tip, 5.0, 3.3, fur, HEAD)
        add(Ellipsoid(h(0.0, 1.0, 13.0), P3(2.7 * k, 1.4 * k, 6.5 * k), hf, BodyPart.HEAD, HEAD), dark)
        add(Ellipsoid(tip + hz * (2.6 * k * HEAD_K) + hy * (0.9 * k * HEAD_K), P3(2.2 * k, 1.7 * k, 1.8 * k), hf, BodyPart.HEAD, DETAIL), nose)
        // the lower jaw, swung open about its hinge below the ear
        val hinge = h(0.0, -5.0, 2.0)
        val jawRot = headRot * Rot.pitch(-(3.0 + 36.0 * r.mouth))
        fun j(x: Double, y: Double, z: Double) = hinge + jawRot.apply(P3(x, y, z) * (k * HEAD_K))
        cone(j(0.0, 0.0, 2.0), j(0.0, -0.4, 16.0), 3.3, 2.2, cheek, JAW)
        // the dark line of the lips down each side of the muzzle, drawn back in a snarl
        for (s in listOf(-1.0, 1.0)) cone(h(s * 3.4, -4.6, 7.0 + r.snarl * 2.0), h(s * 2.6, -5.0, 20.5), 0.5, 0.4, nose, DETAIL)
        // gums and teeth show as it opens and snarls, the fangs under the lip
        val open = max(r.mouth, r.snarl * 0.5)
        if (open > 0.25) {
            add(Ellipsoid(h(0.0, -4.8, 13.0), P3(2.3 * k, 0.9 * k, 6.5 * k), hf, BodyPart.HEAD, DETAIL), gum)
            for (s in listOf(-1.0, 1.0)) {
                cone(h(s * 2.0, -4.4, 17.5), h(s * 1.8, -7.6, 17.8), 0.75, 0.15, tooth, DETAIL)
                cone(j(s * 1.6, 0.8, 13.5), j(s * 1.5, 3.6, 13.8), 0.65, 0.15, tooth, DETAIL)
                for (t in 0..2) cone(h(s * 2.3, -4.6, 15.0 - t * 2.2), h(s * 2.3, -5.9, 15.0 - t * 2.2), 0.45, 0.15, tooth, DETAIL)
            }
        }
        // eyes, almond shaped, set forward under the brow
        for (s in listOf(-1.0, 1.0)) {
            val e = h(s * 4.4, 2.4, 8.2)
            if (r.eyes > 0.5) {
                add(Ellipsoid(e, P3(1.8 * k, 1.1 * k, 1.3 * k), hf, BodyPart.HEAD, DETAIL), pupil)
                add(Ellipsoid(e + hz * (0.25 * k) + hx * (s * 0.35 * k), P3(1.4 * k, 0.85 * k, 1.1 * k), hf, BodyPart.HEAD, DETAIL), eye)
                add(Ellipsoid(e + hz * (0.6 * k) + hx * (s * 0.6 * k), P3(0.45 * k, 0.7 * k, 0.45 * k), hf, BodyPart.HEAD, DETAIL), pupil)
            } else cone(e - hx * (1.4 * k), e + hx * (1.4 * k), 0.35, 0.35, dark, DETAIL)
            // the brow ridge over it
            cone(h(s * 6.4, 4.6, 5.0), h(s * 2.4, 4.0, 9.5), 1.3, 0.9, saddle, HEAD)
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
            val foot = P3(side * 7.0 * k, ground, (36.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
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
            val foot = P3(side * 8.0 * k, ground, (-40.0 + off.f) * k + r.fwd * k) + P3(0.0, off.u * k, 0.0)
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

    /** How the parts melt into each other: the trunk smoothly, the legs and head into it near their joints. */
    fun groups(r: Rig): Groups {
        val g = Groups(COUNT)
        g.reach = 16.0 * k
        g.set(TRUNK, 5.0 * k)
        g.set(HEAD, 2.0 * k, TRUNK, joints[HEAD])
        g.set(JAW, 1.0 * k)
        g.set(EAR, 0.6 * k)
        g.set(DETAIL, 0.0)
        for (l in listOf(LEG_FL, LEG_FR, LEG_HL, LEG_HR)) g.set(l, 1.6 * k, TRUNK, joints[l])
        g.set(TAIL, 2.0 * k, TRUNK, joints[TAIL])
        return g
    }

    /** Renders pose [r] into a [w] × [h] picture with the feet on [ground] at [anchorX]. */
    fun render(w: Int, h: Int, anchorX: Double, ground: Double, px: Double, r: Rig, pitch: Double = 15.0): PixelImage {
        val so = solids(r)
        // a body on its side rests on its flank, not sunk into the ground
        val lift = (abs(sin(Math.toRadians(r.fallS))) * 13.0 + abs(sin(Math.toRadians(r.fallF))) * 10.0) * k
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
