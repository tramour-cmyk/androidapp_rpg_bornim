package de.bornim.core.art

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin

/**
 * The vermin of the caves and the deep wood, built in the round like the wolf: the giant spider, the giant centipede,
 * the giant bat, the stirge and the ochre jelly. None of them is anything like a beast on four legs, so each has a
 * body of its own here. Measured in cm, facing +z, the ground at y = 0. Each kind comes in three looks ([variant]):
 * colours and markings, scars, a torn wing, a bloated belly; [size] scales the whole animal.
 */
class Vermin(val kind: Kind, val variant: Int = 0, val size: Double = 1.0) {

    enum class Kind { SPIDER, CENTIPEDE, BAT, STIRGE, JELLY }

    /** How it stands or hangs in the air. Angles in degrees, lengths in cm of an animal of size 1. */
    data class Rig(
        /** The whole body forward (+) or back, down (+) into a crouch, to its right (+). */
        val fwd: Double = 0.0, val crouch: Double = 0.0, val side: Double = 0.0,
        /** The front of it reared up (+): a spider's forelegs raised, a centipede's head lifted high, a jelly swelling up. */
        val rear: Double = 0.0,
        /** Jaws, fangs or pincers open, 0 to 1; a bat's mouth gaping. */
        val jaw: Double = 0.3,
        /** Wings: spread 0 (folded) to 1 (wide), and the beat: down (+) or up (-). */
        val spread: Double = 1.0, val beat: Double = 0.0,
        /** How high a flyer hangs in the air, in cm. */
        val hover: Double = 0.0,
        /** Legs (or segments) stepping: a phase, 0 to 1. */
        val step: Double = 0.0,
        /** A jelly's surge: squat and wide (-) or tall and reaching (+). */
        val surge: Double = 0.0,
        /** Falling over: forward and to its right side, in degrees. */
        val fallF: Double = 0.0, val fallS: Double = 0.0,
        /** Dying: a spider's legs drawn in under it, a centipede coiling up, a jelly melting away, 0 to 1. */
        val curl: Double = 0.0,
        /** Which way it faces in the picture. */
        val yaw: Double = -60.0,
    ) {
        fun lerp(o: Rig, t: Double): Rig {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Rig(l(fwd, o.fwd), l(crouch, o.crouch), l(side, o.side), l(rear, o.rear), l(jaw, o.jaw), l(spread, o.spread), l(beat, o.beat),
                l(hover, o.hover), l(step, o.step), l(surge, o.surge), l(fallF, o.fallF), l(fallS, o.fallS), l(curl, o.curl), l(yaw, o.yaw))
        }
    }

    private val k = size
    private val v = variant.mod(3)
    private val out = mutableListOf<Solid>()

    /** Where the bite, sting or touch lands, in the last pose built. */
    var tip: P3 = P3.O
        private set

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, bias: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain, bias)
    private fun add(s: Solid, mat: Mat): Solid { s.mat = mat; out += s; return s }
    private fun ell(c: P3, rx: Double, ry: Double, rz: Double, mat: Mat, g: Int, f: Frame = Frame.IDENTITY) =
        add(Ellipsoid(c, P3(rx, ry, rz) * k, f, BodyPart.TORSO, g), mat)
    private fun cone(a: P3, b: P3, ra: Double, rb: Double, mat: Mat, g: Int) = add(RoundCone(a, b, ra * k, rb * k, BodyPart.ARM, g), mat)
    private fun p(x: Double, y: Double, z: Double) = P3(x, y, z) * k

    /** Hair or bristles: the surface roughened into short tufts. */
    private class Fuzz(val inner: Solid, val depth: Double, val seed: Double, val scale: Double) : Solid(inner.part, inner.group) {
        override val center = inner.center
        override val bound = inner.bound + depth
        override fun raw(p: P3): Double {
            val d = inner.dist(p)
            if (d > depth * 2 + 2) return d - depth
            val q = (p - center) * (1.0 / scale)
            val n = Beast.noise(q.x * 1.7 + seed, q.y * 1.7 - seed, q.z * 1.7) * 0.65 + Beast.noise(q.x * 4.1, q.y * 4.1 + seed, q.z * 4.1 - seed) * 0.35
            return (d - depth * n) * 0.8
        }
    }
    private fun fuzz(s: Solid, depth: Double, seed: Double) { out.remove(s); val f = Fuzz(s, depth * k, seed, k); f.mat = s.mat; f.paint = s.paint; out += f }

    /** Builds the animal in pose [r]: every solid with its material. */
    fun solids(r: Rig): List<Solid> {
        out.clear()
        when (kind) {
            Kind.SPIDER -> spider(r)
            Kind.CENTIPEDE -> centipede(r)
            Kind.BAT -> bat(r, stirge = false)
            Kind.STIRGE -> bat(r, stirge = true)
            Kind.JELLY -> jelly(r)
        }
        return out.toList()
    }

    // ---------------------------------------------------------------- the giant spider

    /**
     * SRD giant spider, Large: a body about 1.5 m long on legs that span three metres. A hairy cephalothorax with a
     * cluster of eight glinting eyes over the jaws, curved fangs wet with venom, a swollen abdomen with its markings,
     * eight jointed legs. Looks: black with a blood-red mark; a striped brown hunter; a pale cave spider, scarred.
     */
    private fun spider(r: Rig) {
        val coat = intArrayOf(0x1A1616, 0x4A3626, 0x6A6660)[v]
        val dark = intArrayOf(0x0C0A0A, 0x2A1E16, 0x3A3836)[v]
        val mark = intArrayOf(0xC81A14, 0xC8A868, 0xD8D2C4)[v]
        val hair = m(coat, grain = 0.35)
        val shell = m(dark, shine = 0.35, grain = 0.15)
        val leg = m(coat, shine = 0.15, grain = 0.3)
        val joint = m(dark, shine = 0.3)
        val fang = m(if (v == 2) 0x3A3430 else 0x0A0808, shine = 0.8)
        val eye = m(intArrayOf(0xE02018, 0x281410, 0xD8C848)[v], shine = 1.0, bias = 0.35)
        val venom = m(0x9CC83A, shine = 1.0, bias = 0.2)
        val markMat = m(mark, grain = 0.25)
        val lift = -r.crouch
        // the body: the cephalothorax over the front legs, the abdomen behind it, tipped up a little
        val thorax = P3(0.0, 40.0 + lift, 20.0 + r.fwd) * k
        val belly = P3(0.0, 52.0 + lift, -40.0 + r.fwd) * k
        val ct = ell(thorax, 24.0, 14.0, 28.0, shell, BODY)
        fuzz(ct, 1.6, 1.0)
        val ab = add(Ellipsoid(belly, P3(34.0, 30.0, 44.0) * k, Frame(P3.X, P3(0.0, 0.94, -0.34), P3(0.0, 0.34, 0.94)), BodyPart.TORSO, BODY), hair)
        // the marking on its back: an hourglass, a stripe down the middle, pale chevrons
        ab.paint = { q ->
            val l = q - belly
            val x = abs(l.x) / k; val y = l.y / k; val z = l.z / k
            val on = y > 12 && when (v) {
                0 -> x < 5 + abs(z) * 0.45 && abs(z) < 26
                1 -> x < 7 || (x in 15.0..21.0)
                else -> (z + x * 1.4).mod(15.0) < 5.5
            }
            if (on) markMat else hair
        }
        fuzz(ab, 2.4, 3.0)
        // a waist between the two parts
        cone(thorax - p(0.0, 0.0, 20.0), belly + p(0.0, -6.0, 34.0), 9.0, 11.0, shell, BODY)
        // scars: pale old gashes across the abdomen of the cave spider
        if (v == 2) for (i in 0..2) cone(belly + p(-20.0 + i * 12.0, 24.0, 10.0 - i * 6.0), belly + p(-8.0 + i * 12.0, 27.0, -16.0 - i * 6.0), 1.2, 1.2, m(0x5A4A44), DETAIL)

        // the head end: eight eyes, two big ones in front
        val face = thorax + p(0.0, 6.0, 26.0)
        for ((ex, ey, er) in listOf(Triple(4.2, 4.0, 2.8), Triple(-4.2, 4.0, 2.8), Triple(9.0, 6.0, 1.8), Triple(-9.0, 6.0, 1.8),
            Triple(3.0, 9.0, 1.6), Triple(-3.0, 9.0, 1.6), Triple(11.5, 2.0, 1.4), Triple(-11.5, 2.0, 1.4)))
            ell(face + p(ex, ey, -abs(ex) * 0.25), er * 1.3, er * 1.3, er * 1.3, eye, EYE)
        // the jaws: two thick chelicerae hanging down in front, the fangs curved in under them, a drop of venom on each
        val open = r.jaw
        for (s in listOf(-1.0, 1.0)) {
            val root = thorax + p(s * 6.0, -2.0, 28.0)
            val end = root + p(s * (3.0 + 4.0 * open), -16.0, 6.0 + 4.0 * open)
            cone(root, end, 7.0, 5.0, hair, JAW)
            val fTip = end + p(-s * (5.0 + 3.0 * open), -11.0, -1.0)
            cone(end, fTip, 3.2, 0.5, fang, DETAIL)
            ell(fTip + p(0.0, -1.8, 0.0), 1.5, 2.2, 1.5, venom, DETAIL)
            // the palps beside the jaws, short and feeler-like
            val palp = thorax + p(s * 12.0, -1.0, 24.0)
            val pk = palp + p(s * 10.0, 6.0 + 6.0 * r.rear / 30.0, 12.0)
            cone(palp, pk, 3.0, 2.4, leg, LEG); cone(pk, pk + p(s * 2.0, -12.0, 8.0), 2.4, 1.4, leg, LEG)
        }
        tip = thorax + p(0.0, -24.0, 36.0)

        // the legs: four on each side, each up to a high knee and down to the ground well out from the body
        val angles = doubleArrayOf(62.0, 22.0, -18.0, -58.0)
        for (s in listOf(-1.0, 1.0)) for ((i, a) in angles.withIndex()) {
            val ar = Math.toRadians(a)
            val d = P3(s * cos(ar), 0.0, sin(ar))
            val hip = thorax + p(s * 16.0, -4.0, 12.0 - i * 9.0)
            // walking: the legs in turn lifted and set forward
            val ph = (r.step + i * 0.25 + (if (s > 0) 0.5 else 0.0)).mod(1.0)
            val stepLift = max(0.0, sin(ph * 2 * PI)) * 10.0
            var foot = P3(hip.x, 0.0, hip.z) + d * (118.0 * k) + p(0.0, stepLift, 0.0)
            var knee = hip + d * (46.0 * k) + p(0.0, 40.0, 0.0)
            var ankle = hip + d * (96.0 * k) + p(0.0, 22.0, 0.0)
            // the front pair raised high before it, threatening
            if (i == 0 && r.rear > 0) {
                val up = r.rear / 30.0
                knee = knee.lerp(hip + d * (36.0 * k) + p(0.0, 66.0, 18.0), up)
                ankle = ankle.lerp(hip + d * (60.0 * k) + p(0.0, 92.0, 46.0), up)
                foot = foot.lerp(hip + d * (70.0 * k) + p(0.0, 70.0, 82.0), up)
            }
            // dying, the legs draw in under the body like a dead spider's
            if (r.curl > 0) {
                val c = r.curl
                knee = knee.lerp(hip + d * (26.0 * k) + p(0.0, 14.0, 6.0), c)
                ankle = ankle.lerp(hip + d * (16.0 * k) + p(0.0, -4.0, 10.0 - i * 4.0), c)
                foot = foot.lerp(hip + d * (6.0 * k) + p(0.0, -10.0, 4.0 - i * 2.0), c)
            }
            // thick, hairy thighs, thinner shanks, the foot a hooked point
            fuzz(cone(hip, knee, 7.5, 5.8, leg, LEG), 1.3, i + s * 3)
            ell(knee, 6.0, 6.0, 6.0, joint, LEG)
            fuzz(cone(knee, ankle, 5.6, 3.8, leg, LEG), 1.0, i - s * 2)
            ell(ankle, 4.0, 4.0, 4.0, joint, LEG)
            cone(ankle, foot, 3.8, 1.0, leg, LEG)
            // pale bands at the joints of the striped hunter
            if (v == 1) for (at in listOf(knee, ankle)) ell(at, 5.6, 2.0, 5.6, markMat, DETAIL, Frame(P3.X, P3.Y, P3.Z))
        }
    }

    // ---------------------------------------------------------------- the giant centipede

    /**
     * SRD giant centipede, Small: about 1.5 m long. A flat armoured body of many segments, a pair of legs on each, the
     * head with long feelers and a pair of venom claws curved like sickles. It rears its front end to strike. Looks:
     * rust red with yellow legs; blue-black with red legs; banded ochre and black.
     */
    private fun centipede(r: Rig) {
        val plate = intArrayOf(0x6A2414, 0x161A26, 0x8A6420)[v]
        val band = intArrayOf(0x3A120A, 0x0A0C12, 0x1A140C)[v]
        val legC = intArrayOf(0xC89A30, 0x8A1A14, 0x2A2016)[v]
        val armour = m(plate, shine = 0.55, grain = 0.12)
        val bandM = m(band, shine = 0.45, grain = 0.1)
        val legM = m(legC, shine = 0.4, grain = 0.1)
        val claw = m(0x0C0808, shine = 0.8)
        val eye = m(0x0A0A0A, shine = 1.0)
        val n = 26
        // the body lies along the ground in a slow S; when it rears, the front part curves up off the ground on an arc,
        // measured along its length so the segments stay close
        val len = 150.0
        val raised = 34.0 + r.rear * 0.6
        val bend = Math.toRadians(r.rear / 30.0 * 75.0)
        fun at(t: Double): P3 {
            // dying, it coils up: the body drawn into a tight curve
            val sl = t * len * (1 - 0.35 * r.curl)
            val wig = sin(t * PI * 2.2 + r.step * 2 * PI) * 9.0 * (1 - t) * (1 - t * 0.5) + r.curl * 46.0 * sin(t * PI)
            val flat = len - raised
            if (sl <= flat || bend < 1e-3) return p(wig, 7.0 - r.crouch, -90.0 + sl + r.fwd)
            val th = (sl - flat) / raised * bend
            val rr = raised / bend
            return p(wig, 7.0 - r.crouch + rr * (1 - cos(th)), -90.0 + flat + rr * sin(th) + r.fwd)
        }
        for (i in 0 until n) {
            val t = i / (n - 1.0)
            val c = at(t); val nx = at((t + 0.02).coerceAtMost(1.0)); val pv = at((t - 0.02).coerceAtLeast(0.0))
            val along = (nx - pv).norm()
            val side = (P3.Y cross along).let { if (it.len() < 0.1) P3.X else it.norm() }
            val up = (along cross side).norm()
            val w = 11.5 * (0.7 + 0.3 * sin(t * PI))
            // a hard plate over each segment, overlapping the next like armour, a softer band between them
            add(Ellipsoid(c, P3(w, 4.2, 6.4) * k, Frame(side, up, along), BodyPart.TORSO, BODY), if (i % 2 == 0) armour else bandM)
            if (i in 1 until n - 1 && i % 2 == 1) for (s in listOf(-1.0, 1.0)) {
                val ph = (r.step * 3 + i * 0.18 + (if (s > 0) 0.5 else 0.0)).mod(1.0)
                val root = c + side * (s * w * 0.85 * k)
                val kneeP = root + side * (s * 8.0 * k) + up * (4.0 * k) + along * ((sin(ph * 2 * PI) * 3.0) * k)
                // on the ground the legs reach down to it; on the reared part they hang and claw at the air
                val ground = P3(kneeP.x, 0.0, kneeP.z) + side * (s * 5.0 * k) + along * ((-2.0 + sin(ph * 2 * PI) * 4.0) * k)
                val foot = if (c.y < 16.0 * k) ground else kneeP + side * (s * 5.0 * k) - up * (2.0 * k) - along * (7.0 * k)
                cone(root, kneeP, 1.7, 1.3, legM, LEG)
                cone(kneeP, foot, 1.3, 0.5, legM, LEG)
            }
        }
        // the head: a flat shield with two dark eyes, the long feelers swept back, the venom claws ready under it
        val head = at(1.0)
        val ahead = (at(1.0) - at(0.96)).norm()
        val hs = (P3.Y cross ahead).norm(); val hu = (ahead cross hs).norm()
        val h = head + ahead * (5.0 * k)
        add(Ellipsoid(h, P3(12.5, 5.6, 9.5) * k, Frame(hs, hu, ahead), BodyPart.HEAD, BODY), armour)
        for (s in listOf(-1.0, 1.0)) {
            ell(h + hs * (s * 5.0 * k) + hu * (2.4 * k) + ahead * (4.0 * k), 1.4, 1.4, 1.4, eye, EYE)
            // feelers
            val a0 = h + hs * (s * 3.0 * k) + ahead * (6.0 * k) + hu * (2.0 * k)
            val a1 = a0 + hs * (s * 10.0 * k) + hu * (6.0 * k) + ahead * (14.0 * k)
            val a2 = a1 + hs * (s * 10.0 * k) - hu * (2.0 * k) + ahead * (10.0 * k)
            cone(a0, a1, 1.1, 0.7, legM, DETAIL); cone(a1, a2, 0.7, 0.3, legM, DETAIL)
            // the venom claws: curved in from the sides under the head, opening wide to strike
            val c0 = h + hs * (s * 6.0 * k) - hu * (2.0 * k) + ahead * (2.0 * k)
            val c1 = c0 + hs * (s * (7.0 + 7.0 * r.jaw) * k) + ahead * (11.0 * k) - hu * (1.0 * k)
            val c2 = c1 - hs * (s * (10.0 + 3.0 * r.jaw) * k) + ahead * (8.0 * k)
            cone(c0, c1, 3.4, 2.4, bandM, JAW); cone(c1, c2, 2.4, 0.4, claw, DETAIL)
        }
        // the hind legs drawn out long behind like a second pair of feelers
        val tail = at(0.0); val back = (at(0.0) - at(0.05)).norm(); val ts = (P3.Y cross back).norm()
        for (s in listOf(-1.0, 1.0)) cone(tail, tail + back * (16.0 * k) + ts * (s * 7.0 * k) + P3(0.0, 2.0 * k, 0.0), 1.4, 0.4, legM, DETAIL)
        tip = h + ahead * (12.0 * k)
    }

    // ---------------------------------------------------------------- the giant bat and the stirge

    /**
     * SRD giant bat, Large: a wingspan of about 4.5 m, hanging in the air on leathery wings stretched between long finger
     * bones; a furred body, great ears, a creased snout and a mouth full of needle teeth. The stirge, Tiny, is built on
     * the same plan: a body like a bat's with a long piercing proboscis, four hooked legs and a belly that swells with
     * blood. Looks: brown; black with torn wings; grey and scarred (the stirge: rust red, grey, swollen with blood).
     */
    private fun bat(r: Rig, stirge: Boolean) {
        val furC = if (stirge) intArrayOf(0x5A2418, 0x4A4442, 0x6A2A20)[v] else intArrayOf(0x3E2E24, 0x161214, 0x5A5450)[v]
        val skinC = if (stirge) intArrayOf(0x3A1A14, 0x2E2A2A, 0x4A1C16)[v] else intArrayOf(0x2A1E18, 0x0E0C0E, 0x3A3634)[v]
        val fur = m(furC, grain = 0.4)
        val skin = m(skinC, shine = 0.25, grain = 0.2)
        val bone = m(mix(argb(skinC), argb(0x000000), 0.3), shine = 0.3)
        val tooth = m(0xE0D8C4, shine = 0.6)
        val maw = m(0x2A0A0C, shine = 0.4)
        val eye = m(0xD02018, shine = 1.0, bias = 0.3)
        val body0 = P3(0.0, (if (stirge) 46.0 else 92.0) + r.hover - r.crouch, r.fwd) * k
        val beat = r.beat
        // the body hangs upright, a little forward
        val tilt = Frame(P3.X, P3(0.0, 0.92, 0.38), P3(0.0, -0.38, 0.92))
        if (stirge) stirgeBody(r, body0, tilt, skin, bone) else batBody(r, body0, tilt, fur, skin, bone, tooth, maw, eye)
        // the wings: the arm out from the shoulder, the long fingers fanning out, the skin stretched between them
        val span = (if (stirge) 46.0 else 108.0) * (0.35 + 0.65 * r.spread)
        for (s in listOf(-1.0, 1.0)) {
            val sh = body0 + if (stirge) p(s * 6.0, 6.0, 0.0) else p(s * 12.0, 14.0, 2.0)
            val lift = -beat * 0.5
            val elbow = sh + p(s * span * 0.32, span * (0.12 + lift * 0.4), -span * 0.08)
            val wrist = elbow + p(s * span * 0.3, span * (0.06 + lift * 0.5), span * 0.06)
            cone(sh, elbow, 4.0, 2.8, skin, WING)
            cone(elbow, wrist, 2.8, 2.0, skin, WING)
            // a hooked thumb at the wrist
            cone(wrist, wrist + p(s * 2.0, 6.0, 4.0), 1.4, 0.3, bone, DETAIL)
            val fingers = listOf(P3(s * 0.62, 0.36 + lift * 0.6, 0.05), P3(s * 0.66, -0.06 + lift * 0.4, -0.04), P3(s * 0.46, -0.42 + lift * 0.2, -0.08), P3(s * 0.2, -0.62, -0.06))
            val tips = fingers.map { f -> wrist + P3(f.x, f.y, f.z) * (span * k) }
            for (t in tips) cone(wrist, t, 1.6, 0.5, bone, WING)
            // the membrane, thin and dark, between body, arm and fingers, hanging slack in scallops between the tips
            val anchors = listOf(sh) + listOf(elbow, wrist) + tips + listOf(body0 + p(s * 6.0, -16.0, -2.0))
            val skinM = m(mix(argb(skinC), argb(0x000000), 0.15), shine = 0.2, grain = 0.25)
            for (i in 0 until tips.size) {
                val a = wrist; val b = tips[i]; val c = if (i + 1 < tips.size) tips[i + 1] else body0 + p(s * 6.0, -16.0, -2.0)
                membrane(a, b, c, skinM, torn = (stirge && i != 0 && (i + v) % 2 == 1) || (!stirge && v == 1 && i == 1))
            }
            membrane(sh, elbow, wrist, skinM, torn = false)
            membrane(sh, wrist, tips.last(), skinM, torn = false)
            membrane(sh, tips.last(), anchors.last(), skinM, torn = false)
        }
        // old scars on the grey bat's body
        if (!stirge && v == 2) cone(body0 + p(-8.0, 8.0, 9.0), body0 + p(4.0, -6.0, 11.0), 0.9, 0.9, m(0x8A7A74), DETAIL)
    }

    /**
     * The giant bat: a lean, shaggy body, a long head with a creased, wrinkled snout and a spiked nose leaf, the jaws
     * gaping on long fangs and rows of needle teeth, drool hanging from them, small red eyes sunk deep, tall ragged ears.
     */
    private fun batBody(r: Rig, body0: P3, tilt: Frame, fur: Mat, skin: Mat, bone: Mat, tooth: Mat, maw: Mat, eye: Mat) {
        val torso = add(Ellipsoid(body0, P3(15.0, 26.0, 13.0) * k, tilt, BodyPart.TORSO, BODY), fur)
        fuzz(torso, 2.6, 2.0)
        val head = body0 + p(0.0, 32.0, 8.0)
        val hd = add(Ellipsoid(head, P3(13.0, 12.0, 15.0) * k, Frame.IDENTITY, BodyPart.HEAD, HEAD), fur)
        fuzz(hd, 1.6, 5.0)
        val tongue = m(0x6A1E24, shine = 0.6)
        for (s in listOf(-1.0, 1.0)) {
            // tall ears, notched and ragged at the edge
            // a thin leaf of skin, broad at the root and drawn out to a sharp point, a ragged notch in its rim, the
            // inside dark
            val e0 = head + p(s * 8.0, 8.0, -2.0)
            val up = P3(s * 0.62, 0.78, -0.1).norm()
            val face = P3(s * 0.25, 0.0, 1.0).norm()
            val across = (up cross face).norm()
            val earF = Frame(across, up, (across cross up).norm())
            val hgt = 30.0 * k; val half = 8.0 * k
            fun earShape(scale: Double, notch: Boolean): (Double, Double) -> Double = { x, y ->
                val t = ((y + hgt * 0.5) / hgt).coerceIn(0.0, 1.0)
                val w = half * scale * Math.pow(1 - t, 0.75) * (0.75 + 0.5 * kotlin.math.sqrt(t * (1 - t)) * 2)
                var d = max(abs(x) - w, max(-(y + hgt * 0.5), y - hgt * 0.5))
                if (notch) d = max(d, 2.2 * k - kotlin.math.sqrt((x - s * w * 0.9) * (x - s * w * 0.9) + (y - hgt * 0.05) * (y - hgt * 0.05)))
                d
            }
            add(Board(e0 + up * (hgt * 0.5), earF, hgt, 1.6 * k, 0.6 * k, earShape(1.0, true), BodyPart.HEAD, EAR), skin)
            add(Board(e0 + up * (hgt * 0.45) + earF.z * (0.9 * k), earF, hgt, 0.6 * k, 0.6 * k, earShape(0.6, false), BodyPart.HEAD, DETAIL), maw)
            // the eyes, small and red, deep under a heavy brow
            ell(head + p(s * 5.6, 4.0, 11.6), 2.4, 2.0, 2.0, eye, EYE)
            ell(head + p(s * 5.6, 6.6, 11.0), 3.6, 1.6, 2.6, skin, DETAIL)
        }
        // the snout: pushed forward, creased in folds, the nose leaf standing up from it like a spike
        val snout = head + p(0.0, -3.0, 15.0)
        ell(snout, 7.0, 5.6, 6.0, skin, HEAD)
        for (i in 0..2) ell(snout + p(0.0, 3.0 - i * 1.4, -1.0 + i * 2.2), 6.0 - i, 1.0, 1.4, skin, DETAIL)
        cone(snout + p(0.0, 4.0, 4.0), snout + p(0.0, 13.0, 3.0), 3.4, 0.6, skin, DETAIL)
        // the jaws gaping wide: the mouth dark red, a tongue, two long fangs above and below and needle teeth between
        val gape = 0.4 + 0.6 * r.jaw
        val lowJaw = snout + p(0.0, -6.0 - 8.0 * gape, -1.0)
        ell(snout + p(0.0, -4.0 - 4.0 * gape, 2.0), 6.0, 2.0 + 4.0 * gape, 5.0, maw, JAW)
        add(Ellipsoid(lowJaw, P3(6.0, 2.2, 6.0) * k, Frame.IDENTITY, BodyPart.HEAD, JAW), skin)
        ell(lowJaw + p(0.0, 2.2, 1.0), 3.0, 1.2, 3.6, tongue, DETAIL)
        for (s in listOf(-1.0, 1.0)) {
            cone(snout + p(s * 3.6, -2.0, 4.6), snout + p(s * 3.2, -9.0 - 3.0 * gape, 5.0), 1.5, 0.2, tooth, DETAIL)
            cone(lowJaw + p(s * 3.2, 1.0, 4.4), lowJaw + p(s * 3.0, 7.0 + 2.0 * gape, 4.8), 1.3, 0.2, tooth, DETAIL)
            for (t in 1..2) {
                cone(snout + p(s * (3.6 - t * 1.3), -2.4, 5.4), snout + p(s * (3.4 - t * 1.3), -5.0, 5.6), 0.6, 0.15, tooth, DETAIL)
                cone(lowJaw + p(s * (3.2 - t * 1.2), 1.6, 5.0), lowJaw + p(s * (3.0 - t * 1.2), 4.0, 5.2), 0.55, 0.15, tooth, DETAIL)
            }
        }
        // a string of drool from the lower lip
        cone(lowJaw + p(1.6, -1.0, 5.0), lowJaw + p(2.0, -9.0, 5.4), 0.5, 0.3, m(0xC8C0B0, shine = 1.0), DETAIL)
        tip = snout + p(0.0, -6.0, 8.0)
        // hind feet with hooked claws hanging under it
        for (s in listOf(-1.0, 1.0)) {
            val l0 = body0 + p(s * 8.0, -22.0, -4.0)
            val l1 = l0 + p(s * 3.0, -16.0, 2.0)
            cone(l0, l1, 2.8, 1.8, skin, LEG); cone(l1, l1 + p(0.0, -7.0, 5.0), 1.6, 0.3, bone, LEG)
        }
        // old scars on the grey bat
        if (v == 2) cone(body0 + p(-9.0, 12.0, 11.0), body0 + p(5.0, -8.0, 13.0), 1.0, 1.0, m(0x8A7A74), DETAIL)
    }

    /**
     * The stirge: half bat, half gnat and nothing soft about it. A hard, wrinkled hide with spines down the back, a
     * belly in ringed segments that swells with blood, a small head with two bulging red insect eyes and a long barbed
     * proboscis with blood at its point, four long jointed legs reaching forward with hooked claws.
     */
    private fun stirgeBody(r: Rig, body0: P3, tilt: Frame, skin: Mat, bone: Mat) {
        val hideC = intArrayOf(0x4A3026, 0x4A4846, 0x2E2220)[v]
        val hide = m(hideC, shine = 0.35, grain = 0.45)
        val chitin = m(mix(argb(hideC), argb(0x000000), 0.45), shine = 0.6, grain = 0.1)
        val blood = m(0x7A0E16, shine = 0.85, grain = 0.05)
        val eyeM = m(0xC0140E, shine = 0.9, grain = 0.5, bias = 0.15)
        // the thorax: lean and hard, wrinkled
        val th = add(Ellipsoid(body0, P3(7.5, 10.0, 8.0) * k, tilt, BodyPart.TORSO, BODY), hide)
        fuzz(th, 0.5, 4.0)
        // spines down its back
        for (i in 0..3) cone(body0 + p(0.0, 8.0 - i * 5.0, -6.0), body0 + p(0.0, 11.0 - i * 5.0, -12.0), 1.4, 0.2, chitin, DETAIL)
        // the belly: ringed segments hanging down and back, swelling dark red with blood (bloated on the third)
        val full = when (v) { 2 -> 1.5; 0 -> 1.0; else -> 0.85 }
        for (i in 0..3) {
            val c = body0 + p(0.0, -9.0 - i * 3.8 * full, -4.0 - i * 2.6)
            val rr = (6.5 - i * 1.2) * full
            add(Ellipsoid(c, P3(rr, 3.6 * full, rr) * k, tilt, BodyPart.TORSO, BODY), if (i % 2 == 0) blood else chitin)
        }
        // the head: small, two great bulging eyes, the proboscis long and barbed, wet with blood at its point
        val head = body0 + p(0.0, 13.0, 6.0)
        add(Ellipsoid(head, P3(5.0, 4.6, 5.4) * k, Frame.IDENTITY, BodyPart.HEAD, HEAD), chitin)
        for (s in listOf(-1.0, 1.0)) ell(head + p(s * 4.2, 1.2, 2.6), 3.4, 3.8, 3.4, eyeM, EYE)
        val pr0 = head + p(0.0, -1.5, 5.0)
        val pr1 = pr0 + p(0.0, -12.0 - 6.0 * r.jaw, 34.0)
        cone(pr0, pr1, 1.8, 0.35, m(0x140A08, shine = 0.8), DETAIL)
        for (b in 1..3) {
            val at = pr0.lerp(pr1, 0.45 + b * 0.13)
            cone(at, at + p(0.0, 1.6, -2.4), 0.6, 0.1, chitin, DETAIL)
        }
        ell(pr1 + p(0.0, -1.0, 0.0), 1.2, 1.8, 1.2, blood, DETAIL)
        tip = pr1
        // feelers swept back from the head
        for (s in listOf(-1.0, 1.0)) cone(head + p(s * 2.0, 4.0, 3.0), head + p(s * 8.0, 14.0, -6.0), 0.6, 0.2, chitin, DETAIL)
        // four long legs, jointed like an insect's, reaching forward and down with hooked claws to seize
        for (s in listOf(-1.0, 1.0)) for (i in 0..1) {
            val l0 = body0 + p(s * 5.0, -4.0, 4.0 - i * 6.0)
            val l1 = l0 + p(s * 12.0, 4.0, 10.0 - i * 4.0)
            val l2 = l1 + p(s * 2.0, -18.0, 10.0)
            val l3 = l2 + p(-s * 1.0, -2.0, 5.0)
            cone(l0, l1, 1.5, 1.1, chitin, LEG); ell(l1, 1.3, 1.3, 1.3, chitin, LEG)
            cone(l1, l2, 1.1, 0.7, chitin, LEG); cone(l2, l3, 0.7, 0.15, bone, LEG)
        }
    }

    /** A thin sheet of skin over the triangle [a] [b] [c], its free edge sagging; [torn] leaves a ragged hole in it. */
    private fun membrane(a: P3, b: P3, c: P3, mat: Mat, torn: Boolean) {
        val u = b - a; val w = c - a
        val n = (u cross w).norm()
        val ex = u.norm(); val ey = (n cross ex).norm()
        val bx = u dot ex; val cx = w dot ex; val cy = w dot ey
        val center = a + (u + w) * (1.0 / 3.0)
        val c0x = (bx + cx) / 3.0; val c0y = cy / 3.0
        // the outline in the sheet's own plane: the triangle a b c (counter-clockwise), the free edge from b to c scooped in
        val pts = listOf(0.0 to 0.0, bx to 0.0, cx to cy)
        val bcLen = kotlin.math.sqrt((cx - bx) * (cx - bx) + cy * cy)
        val out = { x0: Double, y0: Double ->
            val x = x0 + c0x; val y = y0 + c0y
            var d = -Double.MAX_VALUE
            for (i in 0..2) {
                val (px, py) = pts[i]; val (qx, qy) = pts[(i + 1) % 3]
                val ex2 = qx - px; val ey2 = qy - py; val l = kotlin.math.sqrt(ex2 * ex2 + ey2 * ey2).coerceAtLeast(1e-6)
                var e = -((ex2 * (y - py) - ey2 * (x - px)) / l)
                if (i == 1) {
                    // along b to c: how far along it, and the scallop there
                    val t = (((x - px) * ex2 + (y - py) * ey2) / (l * l)).coerceIn(0.0, 1.0)
                    e += 0.14 * bcLen * 4 * t * (1 - t)
                }
                d = max(d, e)
            }
            if (torn) {
                val hx = (bx + cx) * 0.45; val hy = cy * 0.4
                val hr = 0.16 * bx * (0.8 + 0.3 * sin(x * 0.7) * cos(y * 0.9))
                d = max(d, hr - kotlin.math.sqrt((x - hx) * (x - hx) + (y - hy) * (y - hy)))
            }
            d
        }
        val f = Frame(ex, ey, n)
        add(Board(center, f, max(bx, kotlin.math.sqrt(cx * cx + cy * cy)), 0.7 * k, 0.0, out, BodyPart.GEAR, WING), mat)
    }

    // ---------------------------------------------------------------- the ochre jelly

    /**
     * SRD ochre jelly, Large: a heap of yellow-brown ooze about as wide as a man is tall, that flows and reaches out in
     * pseudopods and eats what it engulfs. Here: a glistening mound, lumpy, with bubbles on its skin and the bones of
     * its last meal half out of it. Looks: ochre with a skull; sickly yellow-green with ribs; dark amber with a helm.
     */
    private fun jelly(r: Rig) {
        val c = intArrayOf(0x8A5E1A, 0x7A8A2A, 0x5E3410)[v]
        // one wet mass: no dark seams where its lumps meet
        val ooze = Mat(Ramp.of(argb(c)), 0.75, 0.08, inline = false)
        val dark = Mat(Ramp.of(mix(argb(c), argb(0x140A02), 0.28)), 0.65, 0.1, inline = false)
        val pale = Mat(Ramp.of(mix(argb(c), argb(0xF0E0A0), 0.16)), 0.9, 0.05, inline = false)
        val bone = m(0xBEB094, shine = 0.25, grain = 0.35)
        // bubbles and the remains in it stand out with their own edge
        val rust = m(0x4E3424, shine = 0.35, grain = 0.5)
        // dying, it runs out flat over the ground
        val tall = (1.0 + r.surge * 0.35 + r.rear / 60.0) * (1 - 0.7 * r.curl)
        val wide = (1.0 - r.surge * 0.2) * (1 + 0.35 * r.curl)
        val base = P3(r.side, 0.0, r.fwd) * k
        // its skin mottled darker where the ooze is thick, paler in streaks where it runs thin
        val mottle: (P3) -> Mat = { q ->
            val n = Beast.noise(q.x / (8.0 * k), q.y / (8.0 * k) + 3.1, q.z / (8.0 * k)) * 0.6 + Beast.noise(q.x / (3.0 * k), q.y / (3.0 * k), q.z / (3.0 * k) + 1.7) * 0.4
            when { n < 0.3 -> dark; n > 0.72 -> pale; else -> ooze }
        }
        fun lump(at: P3, rx: Double, ry: Double, rz: Double, seed: Double) {
            val e = Ellipsoid(at, P3(rx, ry, rz) * k, Frame.IDENTITY, BodyPart.TORSO, BODY)
            e.mat = ooze; e.paint = mottle
            val l = Lumps(e, 5.0 * k, seed, 22.0 * k); l.mat = ooze; l.paint = mottle; out += l
        }
        // the heap: a big mound and smaller ones melting into it, uneven, sagging
        val mound = base + P3(0.0, 24.0 * tall, 0.0) * k
        val mr = P3(58.0 * wide, 26.0 * tall, 50.0 * wide) * k
        lump(mound, 58.0 * wide, 26.0 * tall, 50.0 * wide, 0.0)
        /** The point of the mound's skin in direction ([dx], [dy], [dz]) from its middle, [out] of the way out to it. */
        fun skin(dx: Double, dy: Double, dz: Double, out: Double = 1.0): P3 {
            val d = P3(dx, dy, dz).norm()
            val t = 1.0 / kotlin.math.sqrt((d.x / mr.x) * (d.x / mr.x) + (d.y / mr.y) * (d.y / mr.y) + (d.z / mr.z) * (d.z / mr.z))
            return mound + d * (t * out)
        }
        for ((i, q) in listOf(P3(-34.0, 14.0, 16.0), P3(30.0, 18.0, -20.0), P3(4.0, 36.0, -4.0), P3(-24.0, 12.0, -32.0), P3(30.0, 10.0, 22.0)).withIndex())
            lump(base + P3(q.x * wide, q.y * tall, q.z * wide) * k, 22.0 - i * 2.0, 16.0 * tall, 20.0 - i, i * 1.7 + 1.0)
        // a puddle of it spreading round its foot
        add(Ellipsoid(base + p(0.0, 1.0, 4.0), P3(66.0 * wide, 3.0, 56.0 * wide) * k, Frame.IDENTITY, BodyPart.TORSO, BODY), dark).also { it.paint = mottle }
        // pseudopods: one reaching for the hero, lifted as it strikes, two smaller ones groping at the ground
        val reach = 0.4 + r.rear / 40.0
        // no front to it, nothing like a head: humps of different heights all over, and at its foot the ooze runs out
        // over the ground in flat tongues, the nearest ones creeping towards the hero (further as it strikes)
        for ((i, q) in listOf(P3(-24.0, 44.0, -18.0), P3(20.0, 38.0, 6.0), P3(-6.0, 32.0, 28.0), P3(38.0, 24.0, -12.0)).withIndex()) {
            val e = Ellipsoid(base + P3(q.x * wide, q.y * tall, q.z * wide) * k, P3(17.0 - i * 2.0, (18.0 - i * 2.0) * tall, 16.0 - i) * k, Frame.IDENTITY, BodyPart.TORSO, BODY)
            e.mat = ooze; e.paint = mottle; val l = Lumps(e, 4.0 * k, i * 2.3 + 5.0, 18.0 * k); l.mat = ooze; l.paint = mottle; out += l
        }
        for ((i, a0) in listOf(-0.9, -0.35, 0.15, 0.6, 1.1, 2.4, 3.3).withIndex()) {
            val dir = P3(sin(a0), 0.0, cos(a0))
            val creep = if (i in 1..3) 1.0 + 0.6 * reach else 0.8
            // a flat lobe of ooze spreading over the ground, not a limb
            val at = base + dir * ((58.0 + 8.0 * (i % 2)) * creep * k) + p(0.0, 2.5, 0.0)
            val across = P3(dir.z, 0.0, -dir.x)
            add(Ellipsoid(at, P3(14.0 + 4.0 * (i % 3), 3.2, 12.0 * creep) * k, Frame(across, P3.Y, dir), BodyPart.TORSO, BODY), ooze).also { it.paint = mottle }
        }
        // it drips: long strings hanging from the overhang of its humps
        for ((i, q) in listOf(P3(-30.0, 22.0, 14.0), P3(26.0, 14.0, 24.0), P3(4.0, 16.0, 34.0), P3(-40.0, 14.0, -8.0)).withIndex()) {
            val at = base + P3(q.x * wide, q.y * tall, q.z * wide) * k
            cone(at, at + p(0.0, -6.0 - i * 2.0, 1.0), 1.8, 0.6, ooze, BODY).paint = mottle
        }
        tip = base + p(0.0, 20.0, 60.0 + 20.0 * reach)
        // bubbles swelling on its skin
        for ((i, q) in listOf(P3(-18.0, 46.0, 22.0), P3(24.0, 38.0, 30.0), P3(-40.0, 26.0, -4.0), P3(10.0, 54.0, -6.0), P3(30.0, 20.0, 40.0)).withIndex())
            ell(base + P3(q.x * wide, q.y * tall, q.z * wide) * k, 2.6 + i % 3, 2.6 + i % 3, 2.6 + i % 3, pale, DETAIL)
        // what it has eaten, half dissolved, pushing out of the ooze
        when (v) {
            0 -> {
                // a skull half out of its flank, grinning, its sockets and nose hole black, and an arm bone with its
                // hand reaching out on the other side
                val sk = skin(-0.8, 0.55, 0.55, 1.0)
                val hole = m(0x0C0604)
                ell(sk, 9.0, 10.0, 10.0, bone, DETAIL)
                ell(sk + p(0.0, -6.0, 6.0), 6.5, 4.0, 5.0, bone, DETAIL)
                for (s in listOf(-1.0, 1.0)) {
                    ell(sk + p(s * 3.6, 1.0, 8.6), 2.8, 2.6, 1.8, hole, DETAIL)
                    ell(sk + p(s * 5.6, -3.0, 6.8), 2.2, 1.8, 2.2, bone, DETAIL)
                }
                ell(sk + p(0.0, -3.0, 10.0), 1.2, 1.8, 1.0, hole, DETAIL)
                for (t in -3..3) cone(sk + p(t * 1.4, -7.0, 9.2 - abs(t) * 0.3), sk + p(t * 1.4, -9.6, 9.0 - abs(t) * 0.3), 0.6, 0.5, bone, DETAIL)
                val arm = skin(0.9, 0.3, 0.2, 0.95)
                cone(arm, arm + p(14.0, 16.0, 10.0), 2.4, 2.0, bone, DETAIL)
                for (f in 0..3) cone(arm + p(14.0, 16.0, 10.0), arm + p(16.0 + f * 2.5, 24.0 - f, 14.0 + f), 0.9, 0.5, bone, DETAIL)
            }
            1 -> {
                // a rib cage arching out of its side, and a jaw bone
                for (i in 0..4) {
                    val r0 = skin(-1.0, 0.25, -0.3 + i * 0.22, 0.85)
                    val r1 = r0 + p(-10.0, 12.0, 3.0)
                    val r2 = r1 + p(4.0, 12.0, 4.0)
                    cone(r0, r1, 1.9, 1.6, bone, DETAIL); cone(r1, r2, 1.6, 1.2, bone, DETAIL)
                }
                cone(skin(-1.0, 0.25, -0.3, 0.85) + p(-6.0, 24.0, 7.0), skin(-1.0, 0.25, 0.58, 0.85) + p(-6.0, 24.0, 7.0), 2.0, 2.0, bone, DETAIL)
            }
            else -> {
                // a dented iron helm and the hilt and blade of a sword sticking out of it, eaten brown
                // a helm: the dome, a rim round it, a nose guard and the dark eye slits, tilted half out of the ooze
                val helm = skin(-0.6, 0.6, 0.55, 1.02)
                val hf = Frame(P3(0.9, -0.3, 0.3).norm(), P3(0.35, 0.93, 0.0).norm(), P3(-0.25, 0.1, 0.96).norm())
                add(Ellipsoid(helm, P3(10.5, 9.0, 11.5) * k, hf, BodyPart.GEAR, DETAIL), rust).cut(hf.y * -1.0, helm - hf.y * (3.0 * k))
                add(Ellipsoid(helm - hf.y * (3.0 * k), P3(12.5, 1.6, 13.5) * k, hf, BodyPart.GEAR, DETAIL), rust)
                cone(helm + hf.z * (11.0 * k) + hf.y * (2.0 * k), helm + hf.z * (11.8 * k) - hf.y * (9.0 * k), 1.4, 1.2, rust, DETAIL)
                for (sd in listOf(-1.0, 1.0)) ell(helm + hf.z * (10.6 * k) + hf.x * (sd * 4.4 * k) - hf.y * (1.0 * k), 3.0, 1.0, 1.0, m(0x0C0806), DETAIL)
                // a sword thrust into it at a slant: a broad blade, the crossguard, the grip and pommel
                val hilt = skin(0.5, 0.8, -0.3, 0.92)
                val dir = P3(0.45, 0.85, -0.25).norm()
                val crossD = (dir cross P3.Z).norm()
                add(Ellipsoid(hilt - dir * (6.0 * k), P3(2.4, 16.0, 0.6) * k, Frame(crossD, dir, (crossD cross dir).norm()), BodyPart.GEAR, DETAIL), rust)
                val guard = hilt + dir * (10.0 * k)
                cone(guard - crossD * (7.0 * k), guard + crossD * (7.0 * k), 1.3, 1.3, rust, DETAIL)
                cone(guard, guard + dir * (10.0 * k), 1.2, 1.2, m(0x2A1A10, grain = 0.4), DETAIL)
                ell(guard + dir * (11.5 * k), 2.0, 2.0, 2.0, rust, DETAIL)
            }
        }
    }

    /** Ooze: the surface swollen and sunk in broad lumps. */
    private class Lumps(val inner: Solid, val depth: Double, val seed: Double, val scale: Double) : Solid(inner.part, inner.group) {
        override val center = inner.center
        override val bound = inner.bound + depth
        override fun raw(p: P3): Double {
            val d = inner.dist(p)
            // far off, a safe underestimate that meets the near one without a step (a step leaves seams in the picture)
            if (d > depth * 3 + 2) return (d - depth * 0.65) * 0.8
            val q = (p - center) * (1.0 / scale)
            val n = Beast.noise(q.x + seed, q.y - seed, q.z) * 0.7 + Beast.noise(q.x * 2.3, q.y * 2.3 + seed, q.z * 2.3) * 0.3
            return (d - depth * (n - 0.35)) * 0.8
        }
    }

    // ---------------------------------------------------------------- rendering

    /** Where the point [q] of pose [r] lands in a picture rendered with these numbers. */
    fun project(q: P3, r: Rig, anchorX: Double, ground: Double, px: Double, pitch: Double = 15.0): Pair<Double, Double> {
        val vw = SdfView(r.yaw, pitch, r.fallF, r.fallS).toView(q)
        return Pair(anchorX + vw.x * px, ground - vw.y * px)
    }

    /** How the parts melt into each other. */
    fun groups(): Groups {
        val g = Groups(COUNT)
        val q = when (kind) { Kind.JELLY -> 4.0; Kind.SPIDER -> 1.0; Kind.CENTIPEDE -> 0.6; Kind.BAT -> 0.8; Kind.STIRGE -> 0.4 }
        g.reach = 14.0 * k * q
        g.set(BODY, (if (kind == Kind.JELLY) 3.0 else 3.0) * k * q)
        g.set(HEAD, 1.5 * k * q)
        g.set(JAW, 0.8 * k * q)
        g.set(EAR, 0.6 * k * q)
        g.set(LEG, (if (kind == Kind.JELLY) 6.0 else 0.6) * k * q)
        g.set(WING, 0.3 * k * q)
        g.set(EYE, 0.0)
        g.set(DETAIL, 0.0)
        return g
    }

    /** Renders pose [r] into a [w] × [h] picture with its feet (or the ground under it) on [ground] at [anchorX]. */
    fun render(w: Int, h: Int, anchorX: Double, ground: Double, px: Double, r: Rig, pitch: Double = 15.0): PixelImage {
        val so = solids(r)
        // a body on its side rests on its flank, not sunk into the ground
        val flank = when (kind) { Kind.SPIDER -> 16.0; Kind.CENTIPEDE -> 8.0; Kind.BAT -> 14.0; Kind.STIRGE -> 8.0; Kind.JELLY -> 0.0 }
        val lift = (abs(sin(Math.toRadians(r.fallS))) * flank + abs(sin(Math.toRadians(r.fallF))) * flank * 0.75) * k
        val img = SdfRender.render(so, groups(), { s, q -> s.paint?.invoke(q) ?: s.mat!! }, w, h, anchorX, ground - lift * px * cos(Math.toRadians(pitch)), px, r.yaw, pitch,
            fallF = r.fallF, fallS = r.fallS, maxSteps = 320, innerLines = kind != Kind.JELLY)
        val s = Sculpt(w, h)
        for (y in 0 until h) for (x in 0 until w) s.img.set(x, y, img.img[x, y])
        s.outline(argb(0x100A0C))
        return s.img
    }

    companion object {
        const val BODY = 0; const val HEAD = 1; const val JAW = 2; const val EAR = 3; const val LEG = 4; const val WING = 5; const val EYE = 6; const val DETAIL = 7
        const val COUNT = 8
    }
}
