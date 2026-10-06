package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * The wolf in the new battle style: a jointed rig driven by continuous values, so any number of
 * in-between frames can be drawn, dark fur coats with variants, and fur strands. The alpha wolf
 * (Grimfang) is the same animal, bigger, black and scarred.
 */
object WolfArt {
    /** Everything that moves. Angles are radians from straight down; negative points forward (left). */
    data class Rig(
        val bodyX: Double = 0.0,
        val bodyY: Double = 0.0,
        val tilt: Double = 0.0,
        val breath: Double = 0.0,
        val headX: Double = 0.0,
        val headY: Double = 0.0,
        val headTurn: Double = 0.0,
        val mouth: Double = 0.2,
        val eyes: Double = 1.0,
        val ears: Double = 0.0,
        val tail: Double = 0.0,
        // near/far front legs: upper and lower angle
        val fnU: Double = 0.08, val fnL: Double = -0.04,
        val ffU: Double = 0.14, val ffL: Double = 0.0,
        // near/far hind legs: thigh, shank, foot angle
        val hnT: Double = -0.42, val hnS: Double = 0.72, val hnF: Double = -0.08,
        val hfT: Double = -0.36, val hfS: Double = 0.66, val hfF: Double = -0.04,
    ) {
        fun lerp(o: Rig, t: Double): Rig {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Rig(
                l(bodyX, o.bodyX), l(bodyY, o.bodyY), l(tilt, o.tilt), l(breath, o.breath), l(headX, o.headX), l(headY, o.headY),
                l(headTurn, o.headTurn), l(mouth, o.mouth), l(eyes, o.eyes), l(ears, o.ears), l(tail, o.tail),
                l(fnU, o.fnU), l(fnL, o.fnL), l(ffU, o.ffU), l(ffL, o.ffL),
                l(hnT, o.hnT), l(hnS, o.hnS), l(hnF, o.hnF), l(hfT, o.hfT), l(hfS, o.hfS), l(hfF, o.hfF),
            )
        }
    }

    /** Coat variants on a dark base. */
    data class Coat(val fur: Int, val saddle: Int, val belly: Int, val eye: Int, val scar: Boolean = false, val tornEar: Boolean = false) {
        /** The shimmering variant: the same coat in another hue. */
        fun shifted(hue: Double) = Coat(shift(fur, hue), shift(saddle, hue), shift(belly, hue), eye, scar, tornEar)
        private fun shift(rgb: Int, hue: Double) = Ramp.hueShift(argb(rgb), hue, sat = 1.6) and 0xFFFFFF
    }

    val GREY = Coat(0x6A645E, 0x24201E, 0xB4AA98, 0xF2B428)
    val DARK = Coat(0x3E3A3C, 0x161214, 0x7A726C, 0xF0C840, tornEar = true)
    val RUST = Coat(0x74563E, 0x2A1C16, 0xB8A088, 0xF0A020, scar = true)
    val ASH = Coat(0x8E8A84, 0x3A3634, 0xCAC4B8, 0xE88A20, scar = true, tornEar = true)
    /** Grimfang, the alpha wolf. */
    val ALPHA = Coat(0x343034, 0x0E0A0C, 0x5A5250, 0xF03A2A, scar = true, tornEar = true)

    /** The rare shimmering wolf: silver-blue fur and pale blue eyes; the alpha keeps its darker saddle. */
    val SHIMMER = Coat(0x8C9CB8, 0x2C3654, 0xDCE8F4, 0x7AD8FF)
    val SHIMMER_ALPHA = Coat(0x5A6A8E, 0x141A30, 0xA8B8D4, 0x9AE4FF, scar = true, tornEar = true)

    fun coatFor(look: MonsterLook, alpha: Boolean): Coat = when {
        look.shiny -> if (alpha) SHIMMER_ALPHA else SHIMMER.copy(scar = look.pick(3, 11) == 0)
        alpha -> ALPHA
        else -> listOf(GREY, DARK, RUST, ASH)[look.pick(4, 10)]
    }

    // ---------------------------------------------------------------- key poses
    val STAND = Rig()
    val BREATHE = Rig(breath = 1.0, headY = 0.6, tail = 1.0, ears = 0.4)
    val CROUCH = Rig(bodyY = 5.0, bodyX = 2.0, headY = 6.0, headX = 1.0, mouth = 0.8, ears = -1.0, tail = -0.6,
        fnU = 0.45, fnL = -0.55, ffU = 0.5, ffL = -0.5, hnT = -0.95, hnS = 1.35, hnF = -0.2, hfT = -0.9, hfS = 1.3, hfF = -0.15)
    val SPRING = Rig(bodyY = -10.0, bodyX = -10.0, tilt = -0.14, headY = -4.0, headX = -4.0, mouth = 1.4, ears = -1.0, tail = 0.8,
        fnU = -1.25, fnL = -1.35, ffU = -1.05, ffL = -1.2, hnT = 0.75, hnS = 1.35, hnF = 1.55, hfT = 0.6, hfS = 1.2, hfF = 1.45)
    val LAND = Rig(bodyY = 2.0, bodyX = -14.0, tilt = 0.06, headY = 5.0, headX = -6.0, mouth = 1.5, ears = -1.0, tail = 0.2,
        fnU = -0.35, fnL = 0.2, ffU = -0.2, ffL = 0.25, hnT = -0.1, hnS = 1.0, hnF = 0.3, hfT = -0.2, hfS = 0.9, hfF = 0.2)
    val LUNGE = Rig(bodyX = -6.0, bodyY = 1.0, headX = -9.0, headY = 1.5, mouth = 1.6, ears = -1.0, tail = 0.3,
        fnU = -0.4, fnL = -0.2, ffU = 0.3, ffL = 0.1, hnT = -0.2, hnS = 0.9, hnF = 0.2)
    val SNAP = Rig(bodyX = -7.0, bodyY = 1.0, headX = -10.0, headY = 2.5, headTurn = 0.1, mouth = 0.1, ears = -1.0, tail = 0.3,
        fnU = -0.4, fnL = -0.2, ffU = 0.3, ffL = 0.1, hnT = -0.2, hnS = 0.9, hnF = 0.2)
    val HURT = Rig(bodyX = 5.0, bodyY = -1.0, tilt = 0.08, headX = 7.0, headY = -6.0, headTurn = -0.2, mouth = 1.0, eyes = 0.0, ears = -1.0, tail = -1.0,
        fnU = 0.35, fnL = 0.2, ffU = 0.4, ffL = 0.25, hnT = -0.5, hnS = 0.5, hnF = -0.2)
    val HOWL = Rig(bodyY = 1.0, tilt = 0.05, headX = 3.0, headY = -9.0, headTurn = -0.55, mouth = 1.1, eyes = 0.3, ears = 0.6, tail = -0.3,
        fnU = 0.0, fnL = -0.05, hnT = -0.6, hnS = 0.95, hnF = -0.1)

    /** In-between frames from one key to the next, with ease in and out. */
    fun tween(vararg keys: Pair<Rig, Int>): List<Rig> {
        val out = mutableListOf<Rig>()
        for (i in 0 until keys.size - 1) {
            val (a, n) = keys[i]
            val b = keys[i + 1].first
            for (k in 0 until n) {
                val t = k / n.toDouble()
                out += a.lerp(b, (1 - cos(t * PI)) / 2)
            }
        }
        out += keys.last().first
        return out
    }

    /** Frames of one breath; the battle screen shows about twelve per second. */
    const val IDLE_FRAMES = 16
    val IDLE_LOOP = (0 until IDLE_FRAMES).map { STAND.lerp(BREATHE, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) }
    val BITE = tween(STAND to 4, CROUCH to 4, LUNGE to 2, SNAP to 6, STAND to 1)
    val POUNCE = tween(STAND to 4, CROUCH to 4, SPRING to 4, LAND to 4, STAND to 1)
    val HOWL_SEQ = tween(STAND to 4, HOWL to 6, STAND to 1)
    val HURT_SEQ = tween(STAND to 2, HURT to 5, STAND to 1)
    /** Index of the key frame where the jaws close (bite) or the wolf lands (pounce). */
    private const val BITE_STRIKE = 10
    private const val POUNCE_STRIKE = 12

    // ---------------------------------------------------------------- drawing

    // ---------------------------------------------------------------- frames for the battle screen

    /** The key frames of one action; [variant] picks among the attack styles (bite, pounce). */
    fun sequence(act: Act, variant: Int): List<Rig> = when (act) {
        Act.IDLE -> IDLE_LOOP
        Act.HURT -> HURT_SEQ
        Act.HOWL -> HOWL_SEQ
        Act.ATTACK -> if (variant.mod(2) == 0) BITE else POUNCE
    }

    /** The frame in which an attack lands: the jaws close, or the wolf lands on its prey. */
    fun strikeFrame(variant: Int): Int = if (variant.mod(2) == 0) BITE_STRIKE else POUNCE_STRIKE

    private val cache = object : LinkedHashMap<String, PixelImage>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 480
    }

    /**
     * A badly hurt wolf ([wound] 1 below half its hit points, 2 below a quarter) hangs its head,
     * pants and, while standing, keeps one front paw off the ground.
     */
    fun wounded(r: Rig, wound: Int, act: Act): Rig {
        if (wound <= 0) return r
        val k = wound / 2.0
        var out = r.copy(headY = r.headY + 2.0 + 2.5 * k, mouth = maxOf(r.mouth, 0.45 + 0.25 * k), tilt = r.tilt + 0.015 * wound, ears = minOf(r.ears, -0.4 * wound))
        if (act == Act.IDLE) out = out.copy(fnU = r.fnU - 0.12 - 0.12 * k, fnL = r.fnL + 0.45 + 0.35 * k)
        return out
    }

    fun frame(look: MonsterLook, alpha: Boolean, act: Act, variant: Int, index: Int, wound: Int = 0): PixelImage {
        val seq = sequence(act, variant)
        val i = index.coerceIn(0, seq.size - 1)
        val key = "${look.seed}/${look.shiny}/$alpha/$act/${if (act == Act.ATTACK) variant.mod(2) else 0}/$i/$wound"
        synchronized(cache) { cache[key]?.let { return it } }
        val size = if (alpha) 1.22 else 1.0 + look.range(2) * 0.05
        val img = draw(wounded(seq[i], wound, act), coatFor(look, alpha), 7 + look.seed.mod(5), size)
        synchronized(cache) { cache[key] = img }
        return img
    }

    const val W = 104
    const val H = 76
    /** Where the feet touch the ground, in sprite pixels from the top. */
    const val GROUND = 73

    /** Draws one frame; [scale] enlarges the whole animal (bigger wolves, the alpha). */
    fun draw(r: Rig, coat: Coat = GREY, seed: Int = 7, scale: Double = 1.0): PixelImage {
        val s = Sculpt(kotlin.math.ceil(W * scale).toInt(), kotlin.math.ceil(H * scale).toInt(), seed)
        s.transform(scaleX = scale, scaleY = scale, pivotX = 0.0, pivotY = 0.0)
        val fur = Mat(Ramp.of(argb(coat.fur)), grain = 0.04)
        val far = fur.copy(bias = -0.28)
        val paw = Mat(Ramp.of(argb(0x2E2826)), grain = 0.04)
        val dark = argb(0x120E10)
        fun bx(x: Double) = x + r.bodyX
        fun by(x: Double, y: Double) = y + r.bodyY + (x - 50) * r.tilt

        /** Two- or three-segment leg from (x, y) by angles; returns nothing, paints on the way. */
        fun leg(m: Mat, x: Double, y: Double, segs: List<Triple<Double, Double, Double>>, pawSize: Double) {
            var cx = x; var cy = y
            val lower = m.copy(inline = false)
            for ((i, sg) in segs.withIndex()) {
                val (ang, len, rad) = sg
                val nx = cx + sin(ang) * len; val ny = cy + cos(ang) * len
                val r0 = rad; val r1 = if (i + 1 < segs.size) segs[i + 1].third else rad * 0.85
                s.limb(cx, cy, nx, ny, r0, r1, if (i == 0) m else lower)
                cx = nx; cy = ny
            }
            s.blob(cx - 1.2, cy + 0.6, pawSize, pawSize * 0.55, paw)
        }
        fun front(m: Mat, x: Double, u: Double, l: Double) =
            leg(m, bx(x), by(x, 45.0), listOf(Triple(u, 11.0, 3.6), Triple(l, 10.0, 1.9), Triple(l - 0.15, 4.0, 1.5)), 2.6)
        fun hind(m: Mat, x: Double, t: Double, sh: Double, f: Double) =
            leg(m, bx(x), by(x, 42.0), listOf(Triple(t, 11.0, 6.4), Triple(sh, 9.0, 2.6), Triple(f, 9.0, 1.7)), 2.6)

        // ---- far side
        front(far, 36.0, r.ffU, r.ffL)
        hind(far, 73.0, r.hfT, r.hfS, r.hfF)
        // ---- tail: low and bushy, swings with r.tail
        val tw = r.tail
        s.chain(fur, bx(82.0), by(82.0, 37.0), 3.4, bx(89.0 + tw), by(89.0, 41.0 - tw), 4.8, bx(94.0 + tw * 2), by(94.0, 49.0 - tw * 3), 4.6,
            bx(95.0 + tw * 3), by(95.0, 57.0 - tw * 4), 3.2, bx(94.0 + tw * 3.5), by(94.0, 62.0 - tw * 4), 1.4)
        // ---- body
        s.blob(bx(74.0), by(74.0, 41.0), 10.5, 9.8, fur)
        s.blob(bx(58.0), by(58.0, 40.5 - r.breath * 0.3), 19.5, 8.4, fur)
        s.blob(bx(42.0), by(42.0, 42.0 - r.breath * 0.5), 12.0, 12.0 + r.breath * 0.5, fur)
        // ---- neck ruff and head
        val hx = 21.0 + r.headX + r.bodyX; val hy = 34.0 + r.headY + r.bodyY
        // the ruff follows the head halfway, so the neck stretches instead of swallowing the head
        val nX = bx(32.0) + r.headX * 0.5; val nY = by(32.0, 36.0) + r.headY * 0.4
        s.blob((bx(36.0) + nX) / 2, (by(36.0, 38.0) + nY) / 2, 9.0, 10.0, fur, rot = 0.4)
        s.blob(nX, nY, 9.5, 11.5, fur, rot = 0.4 + r.headTurn * 0.5)
        for (i in 0..8) {
            val a = -2.5 + i * 0.34
            val rx = nX + cos(a) * 9.0; val ry = nY + sin(a) * 11.0
            s.poly(fur, rx - 1.3, ry, rx + cos(a) * 3.2, ry + sin(a) * 3.2, rx + 1.3, ry + 0.7, bevel = 0.8)
        }
        // head: rotate the facial features around the skull for howling and hurt
        val turn = r.headTurn
        fun hpx(dx: Double, dy: Double) = hx + dx * cos(turn) - dy * sin(turn)
        fun hpy(dx: Double, dy: Double) = hy + dx * sin(turn) + dy * cos(turn)
        val earBack = -r.ears.coerceAtMost(0.0) * 3.0
        s.poly(fur.copy(bias = -0.22), hpx(2.5, -5.0), hpy(2.5, -5.0), hpx(4.0 + earBack, -13.5 + earBack * 0.8), hpy(4.0 + earBack, -13.5 + earBack * 0.8), hpx(7.5, -5.5), hpy(7.5, -5.5), bevel = 1.0)
        s.blob(hpx(2.5, -1.0), hpy(2.5, -1.0), 7.8, 6.8, fur, rot = turn)
        s.poly(fur, hpx(5.0, 1.0), hpy(5.0, 1.0), hpx(10.0, 6.0), hpy(10.0, 6.0), hpx(3.5, 4.5), hpy(3.5, 4.5), bevel = 0.8)
        val tipX = 10.0 + earBack * 1.4; val tipY = -14.5 + earBack
        s.poly(fur, hpx(5.5, -5.5), hpy(5.5, -5.5), hpx(tipX, tipY), hpy(tipX, tipY), hpx(11.0, -4.5), hpy(11.0, -4.5), tiltX = -0.3, bevel = 1.2)
        if (!coat.tornEar) s.poly(Mat(Ramp.of(argb(0x4A3430)), inline = false), hpx(7.4, -6.0), hpy(7.4, -6.0), hpx(tipX - 0.6, tipY + 2.0), hpy(tipX - 0.6, tipY + 2.0), hpx(9.8, -5.5), hpy(9.8, -5.5), bevel = 0.5)
        val open = r.mouth * 2.2
        s.limb(hpx(-2.0, 3.0 + open * 0.5), hpy(-2.0, 3.0 + open * 0.5), hpx(-12.0, 5.5 + open), hpy(-12.0, 5.5 + open), 2.4, 1.4, fur.copy(bias = -0.14))
        if (r.mouth > 0.5) {
            s.flat(hpx(-7.0, 4.2 + open * 0.5), hpy(-7.0, 4.2 + open * 0.5), 4.8, 0.9 + open * 0.35, argb(0x3A0E14))
            s.dot(hpx(-11.5, 3.4), hpy(-11.5, 3.4), Pal.WHITE); s.dot(hpx(-11.5, 4.3), hpy(-11.5, 4.3), Pal.WHITE)
            s.dot(hpx(-10.5, 3.6 + open), hpy(-10.5, 3.6 + open), argb(0xE0D8C8)); s.dot(hpx(-10.5, 4.5 + open), hpy(-10.5, 4.5 + open), argb(0xE0D8C8))
            for (i in 0..2) s.dot(hpx(-9.0 + i * 1.6, 3.4), hpy(-9.0 + i * 1.6, 3.4), argb(0xE0D8C8))
        }
        s.limb(hpx(1.0, 0.5), hpy(1.0, 0.5), hpx(-12.5, 2.6), hpy(-12.5, 2.6), 4.0, 2.2, fur)
        // wrinkled snarl on the muzzle
        if (r.mouth > 0.5) for (i in 0..2) s.dot(hpx(-6.0 + i * 1.5, -0.6), hpy(-6.0 + i * 1.5, -0.6), mix(argb(coat.fur), dark, 0.6))
        s.blob(hpx(-13.5, 2.2), hpy(-13.5, 2.2), 1.7, 1.5, Mat(Ramp.of(argb(0x181414)), shine = 1.0))
        val ex = hpx(-0.3, -1.2); val ey = hpy(-0.3, -1.2)
        if (r.eyes < 0.5) {
            s.line(ex - 1.6, ey - 0.3, ex + 1.4, ey + 0.4, dark)
        } else {
            s.flat(ex, ey, 1.9, 1.1, argb(0x140C08))
            s.flat(ex - 0.2, ey, 1.25, 0.8, argb(coat.eye))
            s.dot(ex, ey, dark)
            s.line(ex - 2.6, ey - 1.9, ex + 2.2, ey - 1.0, dark) // heavy brow
        }
        // ---- near legs
        front(fur, 41.0, r.fnU, r.fnL)
        hind(fur, 70.0, r.hnT, r.hnS, r.hnF)

        // ---- coat markings over the shading
        val sad = argb(coat.saddle)
        s.tint(bx(60.0), by(60.0, 33.0), 23.0, 6.2, sad, 0.62)
        s.tint(bx(41.0), by(41.0, 32.0), 9.5, 6.5, sad, 0.5)
        s.tint(bx(82.0), by(82.0, 35.0), 6.0, 4.0, sad, 0.45)
        s.tint(hpx(4.0, -3.5), hpy(4.0, -3.5), 5.0, 2.6, sad, 0.4)
        s.tint(bx(58.0), by(58.0, 48.0), 15.0, 3.4, argb(coat.belly), 0.42)
        s.tint(bx(38.0), by(38.0, 49.0), 6.0, 6.5, argb(coat.belly), 0.45)
        s.tint(hpx(-7.0, 4.0), hpy(-7.0, 4.0), 5.0, 2.0, argb(coat.belly), 0.45)
        s.tint(bx(95.0 + tw * 3.5), by(95.0, 60.0 - tw * 4), 3.0, 3.5, argb(0x100C0C), 0.65)
        if (coat.scar) s.line(hpx(-3.5, -4.5), hpy(-3.5, -4.5), hpx(1.5, 2.0), hpy(1.5, 2.0), argb(0xA87878))

        // ---- fur strands: short strokes flowing back and down along the body
        s.transform()
        val iw = s.img.width; val ih = s.img.height
        val src = s.img.copy()
        fun hash(x: Int, y: Int, k: Int): Double {
            var n = x * 374761393 + y * 668265263 + k * 1442695041
            n = (n xor (n ushr 13)) * 1274126177
            return ((n xor (n ushr 16)) and 0xFFFF) / 65535.0
        }
        for (y in 1 until ih - 1) for (x in 1 until iw - 1) {
            if (!src.opaque(x, y) || !src.opaque(x + 2, y + 1) || !src.opaque(x - 1, y - 1) || !src.opaque(x, y + 2)) continue
            val n = hash(x, y, 77 + seed)
            when {
                n < 0.075 -> for (k in 0..2) {
                    val px = x + k; val py = y + (k + 1) / 2
                    if (src.opaque(px, py)) s.img.set(px, py, mix(src[px, py], argb(0x0E0A0E), 0.32 - k * 0.07))
                }
                n > 0.955 -> for (k in 0..1) s.img.set(x + k, y + k / 2, mix(src[x + k, y + k / 2], argb(0xF2E6D2), 0.22))
            }
        }
        // eye glow: a faint halo so the eyes read in the dark
        if (r.eyes >= 0.5) for (dy in -2..2) for (dx in -3..3) {
            val px = (ex * scale + dx).toInt(); val py = (ey * scale + dy).toInt()
            if (s.img.opaque(px, py) && dx * dx + dy * dy * 2 > 3) s.img.set(px, py, mix(s.img[px, py], argb(coat.eye), 0.12))
        }
        s.rim(argb(0xF0D0A0), 0.4)
        s.outline(argb(0x100A10))
        return s.img
    }
}
