package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The killing blow on the foe: its picture cut in two along the blow, run through, or burst into pieces (bones, ooze),
 * and how each piece then flies and falls to the ground. Everything in art pixels of the foe's frame, times in ms.
 */
object KillArt {

    /** What becomes of the foe. */
    enum class Kind {
        /** Without blood: it sags down in its own fall, darkened. */
        DARK,
        /** A gush of blood and a pool; it falls in its own way. */
        GUSH,
        /** Cut in two along the blow; the halves fall apart. */
        SPLIT,
        /** Run through: a hole torn in it; it topples. */
        HOLE,
        /** Burst into pieces that scatter and fall: bones, ooze. */
        SHATTER,
    }

    /**
     * One piece of the foe: its picture (the whole frame's size, empty but for the piece), where its middle is, and how
     * it moves: flying off with ([vx], [vy]) px/ms and turning [spin] °/ms until it lies on the ground, or, [topple],
     * tipping over [toAngle]° about ([px], [py]) where it stands, after [delay] ms.
     */
    class Piece(img0: PixelImage, val cx: Double, val cy: Double, val vx: Double, val vy: Double, val spin: Double,
        val topple: Boolean = false, val px: Double = 0.0, val py: Double = 0.0, val toAngle: Double = 0.0, val delay: Double = 0.0, val rest: Double = 3.0) {
        /** Only as much of the picture as the piece covers, and where that lies in the foe's frame. */
        val img: PixelImage
        val ox: Int
        val oy: Int
        init {
            val b = bbox(img0)
            if (b[2] < 0) { img = PixelImage(1, 1); ox = 0; oy = 0 }
            else {
                ox = b[0]; oy = b[1]
                img = PixelImage(b[2] - b[0] + 1, b[3] - b[1] + 1)
                for (y in 0 until img.height) for (x in 0 until img.width) img.set(x, y, img0[ox + x, oy + y])
            }
        }
    }

    /** Where a piece is [t] ms after the blow: how far it has moved and how far it has turned (degrees, about [Piece.cx], [Piece.cy] or the topple point). */
    class Pose(val dx: Double, val dy: Double, val angle: Double)

    /** The fall's pull, px/ms². */
    private const val G = 0.0009

    fun pose(p: Piece, t0: Double, ground: Double): Pose {
        val t = (t0 - p.delay).coerceAtLeast(0.0)
        if (p.topple) {
            val k = (t / 650.0).coerceIn(0.0, 1.0)
            // slow to start, then all at once, with a little bounce as it hits the ground
            val e = k * k * (3 - 2 * k) * k
            return Pose(0.0, 0.0, p.toAngle * e)
        }
        // flying until its middle comes down to where it lies
        val land = ground - p.rest
        val tLand = solveLand(p.cy, p.vy, land)
        val tt = minOf(t, tLand)
        return Pose(p.vx * tt, p.vy * tt + 0.5 * G * tt * tt, p.spin * tt)
    }

    private fun solveLand(y0: Double, vy: Double, land: Double): Double {
        // y0 + vy t + G t²/2 = land
        val a = 0.5 * G; val b = vy; val c = y0 - land
        if (c >= 0) return 0.0
        val d = b * b - 4 * a * c
        return (-b + sqrt(d.coerceAtLeast(0.0))) / (2 * a)
    }

    /** How long until every piece lies still. */
    fun settled(pieces: List<Piece>, ground: Double): Double = pieces.maxOfOrNull { p ->
        p.delay + if (p.topple) 650.0 else solveLand(p.cy, p.vy, ground - p.rest)
    } ?: 0.0

    internal fun bbox(img: PixelImage): IntArray {
        var x0 = img.width; var x1 = -1; var y0 = img.height; var y1 = -1
        for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) >= 128) { x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y) }
        return intArrayOf(x0, y0, x1, y1)
    }

    /** Where the blow strikes the body: the middle of it, a little above half its height. */
    fun heart(img: PixelImage): Pair<Double, Double> {
        val b = bbox(img)
        if (b[2] < 0) return Pair(img.width / 2.0, img.height / 2.0)
        return Pair((b[0] + b[2]) / 2.0, b[1] + (b[3] - b[1]) * 0.45)
    }

    /**
     * Cut in two along a line through ([cx], [cy]) at [deg]° (0 level, positive turning down to the right): the upper
     * part slides off along the cut away from the hero and falls, the lower part topples over backwards where it stands.
     * The raw faces of the cut are painted [wound] (dark blood, ichor, ooze).
     */
    fun split(img: PixelImage, cx: Double, cy: Double, deg: Double, anchorX: Double, ground: Double, wound: Int, fall: Double = 82.0): List<Piece> {
        val a = Math.toRadians(deg); val nx = -sin(a); val ny = cos(a)
        val up = PixelImage(img.width, img.height); val dn = PixelImage(img.width, img.height)
        var ux = 0.0; var uy = 0.0; var un = 0
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val q = img[x, y]; if ((q ushr 24) < 128) continue
            val side = (x - cx) * nx + (y - cy) * ny
            val edge = abs(side) < 2.0
            if (side < 0) { up.set(x, y, if (edge) wound else q); ux += x; uy += y; un++ } else dn.set(x, y, if (edge) mix(wound, argb(0x000000), 0.25) else q)
        }
        val ucx = if (un > 0) ux / un else cx; val ucy = if (un > 0) uy / un else cy
        // along the cut, away from the hero (to the right of the picture)
        val along = if (cos(a) >= 0) 1.0 else -1.0
        return listOf(
            Piece(dn, cx, cy, 0.0, 0.0, 0.0, topple = true, px = anchorX + 4, py = ground, toAngle = fall, delay = 160.0),
            // (a beast's back half slides off without turning over)
            Piece(up, ucx, ucy, along * cos(a) * 0.07 + 0.02, sin(a) * along * 0.07 - 0.07, if (fall > 45) 0.22 else 0.03, rest = 4.0),
        )
    }

    /** Run through: a hole torn through the middle of it, its rim [wound]; then the whole of it topples over backwards. */
    fun hole(img: PixelImage, cx: Double, cy: Double, anchorX: Double, ground: Double, wound: Int, fall: Double = 84.0): List<Piece> {
        val b = bbox(img)
        val rx = ((b[2] - b[0]) * 0.17).coerceIn(4.0, 14.0); val ry = rx * 1.3
        val out = PixelImage(img.width, img.height)
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val q = img[x, y]; if ((q ushr 24) < 128) continue
            val d = sqrt(((x - cx) / rx) * ((x - cx) / rx) + ((y - cy) / ry) * ((y - cy) / ry))
            if (d < 1.0) continue
            out.set(x, y, if (d < 1.35) mix(wound, q, ((d - 1.0) / 0.35) * 0.4) else q)
        }
        return listOf(Piece(out, cx, cy, 0.0, 0.0, 0.0, topple = true, px = anchorX + 4, py = ground, toAngle = fall, delay = 380.0))
    }

    /**
     * Burst into [n] pieces around points on the body, flying out from ([cx], [cy]) and falling to lie scattered on the
     * ground. [keep] (the weapon, say) stays one piece and falls as a whole; [img] is then the picture without it.
     */
    fun shatter(img: PixelImage, cx: Double, cy: Double, n: Int, seed: Int, keep: PixelImage? = null, force: Double = 1.0): List<Piece> {
        val r = java.util.Random(seed.toLong())
        val solid = ArrayList<Int>()
        for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) >= 128) solid += y * img.width + x
        if (solid.isEmpty()) return emptyList()
        val sx = DoubleArray(n); val sy = DoubleArray(n)
        for (i in 0 until n) { val p = solid[r.nextInt(solid.size)]; sx[i] = (p % img.width).toDouble(); sy[i] = (p / img.width).toDouble() }
        val parts = Array(n) { PixelImage(img.width, img.height) }
        val sum = Array(n) { DoubleArray(3) }
        for (p in solid) {
            val x = p % img.width; val y = p / img.width
            var best = 0; var bd = Double.MAX_VALUE
            for (i in 0 until n) { val d = (sx[i] - x) * (sx[i] - x) + (sy[i] - y) * (sy[i] - y); if (d < bd) { bd = d; best = i } }
            parts[best].set(x, y, img[x, y]); sum[best][0] += x; sum[best][1] += y; sum[best][2] += 1.0
        }
        val out = ArrayList<Piece>()
        for (i in 0 until n) {
            if (sum[i][2] < 1) continue
            val mx = sum[i][0] / sum[i][2]; val my = sum[i][1] / sum[i][2]
            val dx = mx - cx; val dy = my - cy; val len = sqrt(dx * dx + dy * dy).coerceAtLeast(1.0)
            val speed = (0.04 + r.nextDouble() * 0.08) * force
            // they come to lie in a heap: the bigger ones lower, the small ones on top of them
            val pb = bbox(parts[i])
            val h = (pb[3] - pb[1] + 1).toDouble()
            out += Piece(parts[i], mx, my, dx / len * speed + (r.nextDouble() - 0.3) * 0.03 * force, dy / len * speed - (0.05 + r.nextDouble() * 0.06) * force,
                (r.nextDouble() - 0.5) * 0.9, rest = 1.0 + minOf(h, 10.0) * 0.3 + r.nextDouble() * 5.0 * (1 - minOf(dx * dx, 900.0) / 900.0))
        }
        if (keep != null) {
            var kx = 0.0; var ky = 0.0; var kn = 0
            for (y in 0 until keep.height) for (x in 0 until keep.width) if ((keep[x, y] ushr 24) >= 128) { kx += x; ky += y; kn++ }
            if (kn > 0) out += Piece(keep, kx / kn, ky / kn, 0.03, -0.05, 0.35, rest = 2.0)
        }
        return out
    }

    /** The piece's picture back in the size of the whole frame. */
    fun Piece.full(): PixelImage {
        val o = PixelImage(img.width + ox, img.height + oy)
        for (y in 0 until img.height) for (x in 0 until img.width) o.set(ox + x, oy + y, img[x, y])
        return o
    }

    /** What is in [armed] but not in [unarmed]: the weapon a foe holds, cut out of its picture. */
    fun difference(armed: PixelImage, unarmed: PixelImage): PixelImage {
        val out = PixelImage(armed.width, armed.height)
        for (y in 0 until armed.height) for (x in 0 until armed.width) {
            val a = armed[x, y]
            if ((a ushr 24) >= 128 && ((unarmed[x, y] ushr 24) < 128 || unarmed[x, y] != a)) out.set(x, y, a)
        }
        return out
    }
}

/** What a killing blow does to one foe: the [kind], its pieces (empty for [KillArt.Kind.DARK] and [KillArt.Kind.GUSH]) and where the blow struck. */
class KillPlan(val kind: KillArt.Kind, val pieces: List<KillArt.Piece>, val cx: Double, val cy: Double, val ground: Double) {
    /** How long until every piece lies still, in ms. */
    val settles: Double = KillArt.settled(pieces, ground)

    companion object {
        /**
         * Decides and cuts: skeletons always burst into bones; the ochre jelly bursts unless the blood is off; any other
         * foe darkens with the blood off ([blood] 0), bleeds in a gush ([blood] 1), and at full blood ([blood] 2) is cut
         * in two along the blow of [strike] (run through for [HeroFigure.Strike.KILL_PIERCE]).
         */
        fun of(id: String, look: de.bornim.core.MonsterLook, strike: HeroFigure.Strike?, blood: Int, seed: Int): KillPlan {
            val ground = MonsterArt.groundLine(id)
            val dieV = MonsterArt.dieVariant(id, look)
            val img = MonsterArt.battleFrame(id, look, Act.DIE, dieV, 0)
            val (cx, cy) = KillArt.heart(img)
            val wound = argb(if (id == "zombie" || id == "ghoul") 0x2A2014 else 0x5E0A0E)
            val anchor = MonsterArt.anchorX(id, img.width)
            // one standing upright falls over backwards; a beast low on its legs only sags where it stands
            val fall = if (MonsterArt.isDoll(id)) 82.0 else 10.0
            val kind = when {
                id == "skeleton" -> KillArt.Kind.SHATTER
                id == "ochre_jelly" -> if (blood >= 1) KillArt.Kind.SHATTER else KillArt.Kind.DARK
                blood <= 0 -> KillArt.Kind.DARK
                blood == 1 -> KillArt.Kind.GUSH
                strike == HeroFigure.Strike.KILL_PIERCE && MonsterArt.isDoll(id) -> KillArt.Kind.HOLE
                else -> KillArt.Kind.SPLIT
            }
            var pieces = when (kind) {
                KillArt.Kind.SHATTER -> if (MonsterArt.isDoll(id)) {
                    val bare = FoeArt.unarmedFrame(id, look, Act.DIE, dieV, 0)
                    KillArt.shatter(bare, cx, cy, 28, seed, KillArt.difference(img, bare))
                } else KillArt.shatter(img, cx, cy, 22, seed, force = 1.25)
                KillArt.Kind.SPLIT -> KillArt.split(img, cx, cy, when (strike) {
                    HeroFigure.Strike.KILL_HIGH -> 68.0
                    HeroFigure.Strike.KILL_RISE -> -40.0
                    HeroFigure.Strike.KILL_SPIN -> 8.0
                    else -> 30.0
                }, anchor, ground, wound, fall)
                KillArt.Kind.HOLE -> KillArt.hole(img, cx, cy, anchor, ground, wound, fall)
                else -> emptyList()
            }
            // a flyer has no ground under it to topple over on: its pieces drop out of the air
            if (pieces.any { it.topple } && bottomOf(img) < ground - 8) pieces = pieces.map {
                if (it.topple) KillArt.Piece(with(KillArt) { it.full() }, it.cx, it.cy, 0.01, -0.01, 0.25, rest = 3.0) else it
            }
            return KillPlan(kind, pieces, cx, cy, ground)
        }

        private fun bottomOf(img: PixelImage): Double {
            for (y in img.height - 1 downTo 0) for (x in 0 until img.width) if ((img[x, y] ushr 24) >= 128) return y.toDouble()
            return img.height.toDouble()
        }
    }
}
