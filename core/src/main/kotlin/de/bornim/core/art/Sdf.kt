package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.atan2
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

    companion object {
        val O = P3(0.0, 0.0, 0.0)
        val X = P3(1.0, 0.0, 0.0)
        val Y = P3(0.0, 1.0, 0.0)
        val Z = P3(0.0, 0.0, 1.0)
    }
}

/** A rotation, as the images of the three axes. */
class Rot(val x: P3, val y: P3, val z: P3) {
    fun apply(p: P3) = x * p.x + y * p.y + z * p.z
    fun inverse(p: P3) = P3(p dot x, p dot y, p dot z)
    operator fun times(o: Rot) = Rot(apply(o.x), apply(o.y), apply(o.z))

    companion object {
        val I = Rot(P3.X, P3.Y, P3.Z)
        /** Turning about the up axis; positive turns forward towards the hero's right. */
        fun yaw(deg: Double): Rot { val a = Math.toRadians(deg); val c = cos(a); val s = sin(a); return Rot(P3(c, 0.0, -s), P3.Y, P3(s, 0.0, c)) }
        /** Tipping about the sideways axis; positive bends forward (the top moves forward). */
        fun pitch(deg: Double): Rot { val a = Math.toRadians(deg); val c = cos(a); val s = sin(a); return Rot(P3.X, P3(0.0, c, s), P3(0.0, -s, c)) }
        /** Tilting about the forward axis; positive lowers the hero's right side. */
        fun roll(deg: Double): Rot { val a = Math.toRadians(deg); val c = cos(a); val s = sin(a); return Rot(P3(c, -s, 0.0), P3(s, c, 0.0), P3.Z) }
    }
}

/** A rigid move: rotate about [pivot], then shift by [shift]. */
class Xf(val rot: Rot = Rot.I, val pivot: P3 = P3.O, val shift: P3 = P3.O) {
    fun apply(p: P3) = pivot + rot.apply(p - pivot) + shift
    fun dir(d: P3) = rot.apply(d)
    fun inverse(p: P3) = pivot + rot.inverse(p - shift - pivot)
    fun frame(f: Frame) = Frame(rot.apply(f.x), rot.apply(f.y), rot.apply(f.z))
    /** This move applied after [inner]. */
    fun then(outer: Xf) = Xf2(this, outer)

    companion object { val I = Xf() }
}

/** Two moves one after the other, so a head can turn on a body that bends. */
class Xf2(private val a: Xf, private val b: Xf) {
    fun apply(p: P3) = b.apply(a.apply(p))
    fun dir(d: P3) = b.dir(a.dir(d))
    fun inverse(p: P3) = a.inverse(b.inverse(p))
    fun frame(f: Frame) = b.frame(a.frame(f))
}

/** Three axes of a part, for oriented shapes. */
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
enum class BodyPart { HEAD, NECK, TORSO, PELVIS, ARM, HAND, THIGH, SHIN, FOOT, HAIR, TUSK, GEAR }

/** A solid, measured by its signed distance: negative inside. */
abstract class Solid(val part: BodyPart, var group: Int) {
    abstract val center: P3
    abstract val bound: Double
    protected abstract fun raw(p: P3): Double
    /** Names the bone it belongs to, so clothes can be shaped as shells over it. */
    var key: String = ""
    /** A fixed material, else the body's material at that spot. */
    var mat: Mat? = null
    /** A material that changes over the surface: studs, plates, stripes. Gets the point in [rest] space. */
    var paint: ((P3) -> Mat)? = null
    /** Maps a point back to how the body stands at rest, for materials laid out on the body. */
    var rest: ((P3) -> P3)? = null
    /** Half spaces the solid is cut by: kept where n·p ≤ d. */
    val cuts = mutableListOf<Pair<P3, Double>>()
    /** Solids carved out of it. */
    val holes = mutableListOf<Solid>()

    fun cut(n: P3, through: P3): Solid { val nn = n.norm(); cuts += nn to (nn dot through); return this }
    fun dist(p: P3): Double {
        var d = raw(p)
        for ((n, k) in cuts) d = max(d, (n dot p) - k)
        for (h in holes) d = max(d, -h.dist(p))
        return d
    }
    fun restOf(p: P3) = rest?.invoke(p) ?: p
}

class Ellipsoid(override val center: P3, val r: P3, val f: Frame = Frame.IDENTITY, part: BodyPart, group: Int) : Solid(part, group) {
    override val bound = max(r.x, max(r.y, r.z))
    override fun raw(p: P3): Double {
        val q = p - center
        val lx = (q dot f.x) / r.x; val ly = (q dot f.y) / r.y; val lz = (q dot f.z) / r.z
        val k0 = sqrt(lx * lx + ly * ly + lz * lz)
        val k1 = sqrt((lx / r.x) * (lx / r.x) + (ly / r.y) * (ly / r.y) + (lz / r.z) * (lz / r.z))
        return if (k1 < 1e-9) -min(r.x, min(r.y, r.z)) else k0 * (k0 - 1) / k1
    }
}

/**
 * A flat blade, diamond in section: from [a] along [f]'s y for [len] cm, [w0] cm half wide across x at the base and [w1]
 * near the point, [t0] to [t1] cm half thick along z. Over the last [tip] cm it narrows to a point ([round] above 1 for an
 * ogive, 1 for straight sides, 0 for a square end). [curve] cm bends its middle line towards x by the point, as a sabre's.
 */
class Blade(
    val a: P3, val f: Frame, val len: Double, val w0: Double, val w1: Double, val t0: Double, val t1: Double,
    val tip: Double, val round: Double = 1.0, val curve: Double = 0.0, part: BodyPart = BodyPart.GEAR, group: Int,
) : Solid(part, group) {
    override val center = a + f.y * (len / 2) + f.x * (curve / 2)
    private val wMax = max(w0, w1) + abs(curve) / 2 + 0.2
    override val bound = sqrt((len / 2) * (len / 2) + wMax * wMax)
    private val box = Box(center, P3(wMax, len / 2, max(t0, t1)), f, 0.0, part, group)
    override fun raw(p: P3): Double {
        val q = p - a
        val y = q dot f.y
        val yc = y.coerceIn(0.0, len)
        val k = yc / len
        val x = (q dot f.x) - curve * k * k
        val z = q dot f.z
        var w = w0 + (w1 - w0) * k
        var t = t0 + (t1 - t0) * k
        val inTip = yc - (len - tip)
        if (tip > 0 && inTip > 0) {
            val r = (1 - inTip / tip).coerceIn(0.0, 1.0)
            val shape = if (round <= 0) 1.0 else Math.pow(r, 1.0 / round)
            w *= shape; t *= 0.35 + 0.65 * shape
        }
        w = max(w, 0.05); t = max(t, 0.05)
        val dd = (abs(x) / w + abs(z) / t - 1) * (w * t) / sqrt(w * w + t * t)
        val dy = max(-y, y - len)
        return max(max(dd * 0.8, dy), box.dist(p))
    }
}

/** A cone with rounded ends: radius [ra] at [a], [rb] at [b]. Limbs, necks, tusks, grips. */
class RoundCone(val a: P3, val b: P3, val ra: Double, val rb: Double, part: BodyPart, group: Int) : Solid(part, group) {
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

/** A box with rounded edges: half sizes [half] along the frame's axes. Plates, buckles, books. */
class Box(override val center: P3, val half: P3, val f: Frame = Frame.IDENTITY, val round: Double = 0.4, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val bound = half.len() + round
    override fun raw(p: P3): Double {
        val q = p - center
        val qx = abs(q dot f.x) - half.x; val qy = abs(q dot f.y) - half.y; val qz = abs(q dot f.z) - half.z
        val ox = max(qx, 0.0); val oy = max(qy, 0.0); val oz = max(qz, 0.0)
        return sqrt(ox * ox + oy * oy + oz * oz) + min(max(qx, max(qy, qz)), 0.0) - round
    }
}

/** A layer laid over another solid: armour and cloth follow the body under them. */
class Shell(val inner: Solid, val t: Double, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val center = inner.center
    override val bound = inner.bound + t
    override fun raw(p: P3) = inner.dist(p) - t
}

/** Only the skin of another solid, [t] thick: cloth hanging free, a cloak, a hood. */
class Hollow(val inner: Solid, val t: Double, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val center = inner.center
    override val bound = inner.bound + t
    override fun raw(p: P3) = abs(inner.dist(p)) - t
}

/** Folds pressed into another solid: ripples around the axis through [axis] along [up]. */
class Folds(val inner: Solid, val axis: P3, val up: P3, val count: Double, val depth: Double, part: BodyPart = BodyPart.GEAR, group: Int, val phase: Double = 0.0) : Solid(part, group) {
    override val center = inner.center
    override val bound = inner.bound + depth
    private val f = Frame.along(up)
    override fun raw(p: P3): Double {
        val q = p - axis
        val a = atan2(q dot f.x, q dot f.z)
        return inner.dist(p) + sin(a * count + phase) * depth
    }
}

/** Another solid squeezed along the axes of [f] by [k] around [pivot]: round shapes made oval, like a cloak around a flat back. */
class Squash(val inner: Solid, val pivot: P3, val f: Frame, val k: P3, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val center = inner.center
    override val bound = inner.bound
    private val m = min(k.x, min(k.y, k.z))
    override fun raw(p: P3): Double {
        val q = p - pivot
        val back = pivot + f.x * ((q dot f.x) / k.x) + f.y * ((q dot f.y) / k.y) + f.z * ((q dot f.z) / k.z)
        return inner.dist(back) * m
    }
}

/**
 * A flat board with an outline given in its own plane ([outline]: signed distance in cm for a point x right, y up),
 * [thick] cm thick and bowed by [bow] (a shield's curve). Its face looks along the frame's z.
 */
class Board(override val center: P3, val f: Frame, val size: Double, val thick: Double, val bow: Double, val outline: (Double, Double) -> Double, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val bound = size
    fun local(p: P3): P3 { val q = p - center; val x = q dot f.x; val y = q dot f.y; return P3(x, y, (q dot f.z) + bow * (x * x) / (size * size)) }
    override fun raw(p: P3): Double {
        val l = local(p)
        val d2 = outline(l.x, l.y)
        val dz = abs(l.z) - thick / 2
        val ox = max(d2, 0.0); val oz = max(dz, 0.0)
        return sqrt(ox * ox + oz * oz) + min(max(d2, dz), 0.0)
    }
}

/** Several solids as one, melted together by [k]: shapes built from pieces, like a cloak over the shoulders. */
class Union(val parts: List<Solid>, val k: Double, part: BodyPart = BodyPart.GEAR, group: Int) : Solid(part, group) {
    override val center = parts.fold(P3.O) { a, p -> a + p.center } * (1.0 / parts.size)
    override val bound = parts.maxOf { (it.center - center).len() + it.bound }
    override fun raw(p: P3): Double {
        var d = Double.MAX_VALUE
        for (q in parts) { val e = q.dist(p); d = if (d == Double.MAX_VALUE) e else SdfRender.smin(d, e, k) }
        return d
    }
}

/** How solids melt together: per group a smoothness, and optionally a parent group it melts into near a joint. */
class Groups(val count: Int) {
    val smooth = DoubleArray(count) { 1.5 }
    val parent = IntArray(count) { -1 }
    val joint = arrayOfNulls<P3>(count)
    var reach = 10.0
    fun set(g: Int, k: Double, parent: Int = -1, joint: P3? = null) { smooth[g] = k; this.parent[g] = parent; this.joint[g] = joint }
}

/** A finished picture: colours in [img], and per pixel the depth (towards us is bigger), for things drawn later. */
class DepthImage(val img: PixelImage, val depth: DoubleArray, val view: SdfView, val anchorX: Double, val ground: Double, val px: Double) {
    /** Where a point of hero space lands: pixel x, y and its depth. */
    fun project(p: P3): Triple<Double, Double, Double> { val v = view.toView(p); return Triple(anchorX + v.x * px, ground - v.y * px, v.z) }
    /** Whether the point would be seen, not hidden behind something nearer. */
    fun visible(p: P3, tolerance: Double = 1.0): Boolean {
        val (x, y, z) = project(p)
        val ix = x.toInt(); val iy = y.toInt()
        if (ix !in 0 until img.width || iy !in 0 until img.height) return false
        val d = depth[iy * img.width + ix]
        return d.isFinite() && d <= z + tolerance
    }
}

/** The camera: the hero turned by its yaw, seen from slightly above. */
/**
 * The camera on the figure. [fallF] and [fallS] tip the whole figure over about its feet, in degrees: forward (the head
 * going where it faces) and to its right side. 0 for everyone standing.
 */
class SdfView(yawDeg: Double, pitchDeg: Double = 15.0, fallF: Double = 0.0, fallS: Double = 0.0) {
    private val yaw = Math.toRadians(yawDeg)
    private val rX = -cos(yaw); private val rZ = sin(yaw)
    private val fX = sin(yaw); private val fZ = cos(yaw)
    private val c = cos(Math.toRadians(pitchDeg)); private val s = sin(Math.toRadians(pitchDeg))
    private val tipped = fallF != 0.0 || fallS != 0.0
    private val cf = cos(Math.toRadians(fallF)); private val sf = sin(Math.toRadians(fallF))
    private val cs = cos(Math.toRadians(fallS)); private val ss = sin(Math.toRadians(fallS))

    /** Tips a point of the figure over about its feet. */
    private fun tip(p: P3): P3 {
        if (!tipped) return p
        // forward: up turns towards the front
        val y1 = p.y * cf - p.z * sf; val z1 = p.y * sf + p.z * cf
        // sideways: up turns towards the right
        val x2 = p.x * cs + y1 * ss; val y2 = -p.x * ss + y1 * cs
        return P3(x2, y2, z1)
    }
    private fun untip(p: P3): P3 {
        if (!tipped) return p
        val x1 = p.x * cs - p.y * ss; val y1 = p.x * ss + p.y * cs
        val y2 = y1 * cf + p.z * sf; val z2 = -y1 * sf + p.z * cf
        return P3(x1, y2, z2)
    }

    /** Hero space to view space: x right, y up on screen, z towards us. */
    fun toView(p0: P3): P3 {
        val p = tip(p0)
        val wx = p.x * rX + p.z * fX; val wz = p.x * rZ + p.z * fZ; val wy = p.y
        return P3(wx, wy * c - wz * s, wz * c + wy * s)
    }
    fun toLocal(v: P3): P3 {
        val wx = v.x; val wy = v.y * c + v.z * s; val wz = -v.y * s + v.z * c
        return untip(P3(wx * rX + wz * rZ, wy, wx * fX + wz * fZ))
    }
}

/**
 * Renders solids pixel by pixel: a ray from each pixel marches into the scene until it meets a surface,
 * which is then lit and dithered like every other sprite, given soft inner lines and an outline.
 */
object SdfRender {
    /** Rows are shared out among the processor's cores; off for tests that compare pictures bit for bit. */
    @Volatile var PARALLEL = true
    private val NEIGH = intArrayOf(1, 0, -1, 0, 0, 1, 0, -1)

    fun smin(a: Double, b: Double, k: Double): Double {
        if (k <= 1e-6) return min(a, b)
        val h = max(k - abs(a - b), 0.0) / k
        return min(a, b) - h * h * k * 0.25
    }

    fun render(
        solids: List<Solid>, groups: Groups, material: (Solid, P3) -> Mat,
        w: Int, h: Int, anchorX: Double, ground: Double, px: Double, yaw: Double, pitch: Double = 15.0, seed: Int = 23,
        sculpt: Sculpt = Sculpt(w, h, seed), fallF: Double = 0.0, fallS: Double = 0.0,
        /** How many steps a ray may take: more for big soft shapes the rays graze along (an ooze). */
        maxSteps: Int = 110,
        /** Whether a dark line marks where a nearer part overlaps a farther one: off for one soft mass (an ooze). */
        innerLines: Boolean = true,
    ): DepthImage {
        val s = sculpt
        val view = SdfView(yaw, pitch, fallF, fallS)
        val depth = DoubleArray(w * h) { Double.NEGATIVE_INFINITY }
        val idx = IntArray(w * h)
        val mats = arrayOfNulls<Mat>(w * h)
        val pad = groups.smooth.max()
        val n0 = solids.size
        val cx = DoubleArray(n0); val cy = DoubleArray(n0); val cz = DoubleArray(n0); val cr = DoubleArray(n0)
        for ((i, so) in solids.withIndex()) {
            val v = view.toView(so.center)
            cx[i] = anchorX + v.x * px; cy[i] = ground - v.y * px; cz[i] = v.z; cr[i] = (so.bound + pad) * px + 1
        }
        val dirL = view.toLocal(P3.Z)
        // which solids can touch which 8×8 tile of the picture, so a pixel tests only its own tile's few
        val tile = 8
        val tw = (w + tile - 1) / tile; val th = (h + tile - 1) / tile
        val bins = Array(tw * th) { IntArray(8) }
        val binN = IntArray(tw * th)
        for (i in 0 until n0) {
            val tx0 = ((cx[i] - cr[i]) / tile).toInt().coerceIn(0, tw - 1); val tx1 = ((cx[i] + cr[i]) / tile).toInt().coerceIn(0, tw - 1)
            val ty0 = ((cy[i] - cr[i]) / tile).toInt().coerceIn(0, th - 1); val ty1 = ((cy[i] + cr[i]) / tile).toInt().coerceIn(0, th - 1)
            if (cx[i] + cr[i] < 0 || cx[i] - cr[i] > w || cy[i] + cr[i] < 0 || cy[i] - cr[i] > h) continue
            for (ty in ty0..ty1) for (tx in tx0..tx1) {
                val b = ty * tw + tx
                if (binN[b] == bins[b].size) bins[b] = bins[b].copyOf(bins[b].size * 2)
                bins[b][binN[b]++] = i
            }
        }
        val boundPad = DoubleArray(n0) { solids[it].bound + pad }
        /** One worker's scratch space; the rows are shared out among the processor's cores. */
        class Row {
            val cand = IntArray(n0)
            val gd = DoubleArray(groups.count)
            fun field(p: P3, n: Int): Double {
                java.util.Arrays.fill(gd, Double.MAX_VALUE)
                for (j in 0 until n) {
                    val so = solids[cand[j]]
                    val g = so.group
                    val cur = gd[g]
                    val d = so.dist(p)
                    gd[g] = if (cur == Double.MAX_VALUE) d else smin(cur, d, groups.smooth[g])
                }
                // children melt into their parent near the joint only
                for (g in groups.count - 1 downTo 0) {
                    val par = groups.parent[g]
                    if (par < 0 || gd[g] == Double.MAX_VALUE || gd[par] == Double.MAX_VALUE) continue
                    val wgt = (1 - (p - groups.joint[g]!!).len() / groups.reach).coerceIn(0.0, 1.0)
                    gd[par] = if (wgt > 0.05) smin(gd[par], gd[g], groups.smooth[par] * 1.4 * wgt) else min(gd[par], gd[g])
                    gd[g] = Double.MAX_VALUE
                }
                var best = Double.MAX_VALUE
                for (d in gd) if (d < best) best = d
                return best
            }
            fun line(y: Int) {
                for (x in 0 until w) {
                    val sx = x + 0.5; val sy = y + 0.5
                    var n = 0
                    var zTop = Double.NEGATIVE_INFINITY; var zBot = Double.POSITIVE_INFINITY
                    val b = (y / tile) * tw + x / tile
                    val list = bins[b]
                    for (k in 0 until binN[b]) {
                        val i = list[k]
                        val dx = sx - cx[i]; val dy = sy - cy[i]
                        if (dx * dx + dy * dy <= cr[i] * cr[i]) {
                            cand[n++] = i
                            val rr = boundPad[i]
                            zTop = max(zTop, cz[i] + rr); zBot = min(zBot, cz[i] - rr)
                        }
                    }
                    if (n == 0) continue
                    // keep the solids in their original order, as the melting of a group depends on it
                    java.util.Arrays.sort(cand, 0, n)
                    val o = view.toLocal(P3((sx - anchorX) / px, (ground - sy) / px, 0.0))
                    var z = zTop
                    var hit = false
                    var steps = 0
                    while (z > zBot && steps < maxSteps) {
                        val d = field(o + dirL * z, n)
                        if (d < 0.1) { hit = true; break }
                        z -= max(d * 0.85, 0.07)
                        steps++
                    }
                    if (!hit) continue
                    val p = o + dirL * z
                    val e = 0.22
                    val k1 = field(p + P3(e, -e, -e), n); val k2 = field(p + P3(-e, -e, e), n)
                    val k3 = field(p + P3(-e, e, -e), n); val k4 = field(p + P3(e, e, e), n)
                    val nl = P3(k1 - k2 - k3 + k4, -k1 - k2 + k3 + k4, -k1 + k2 - k3 + k4).norm()
                    val nv = view.toView(nl)
                    var bi = cand[0]; var bd = Double.MAX_VALUE
                    for (j in 0 until n) { val d = solids[cand[j]].dist(p); if (d < bd) { bd = d; bi = cand[j] } }
                    val mat = material(solids[bi], p)
                    val at = y * w + x
                    depth[at] = z; mats[at] = mat
                    idx[at] = s.litIndex(x, y, nv.x, -nv.y, nv.z, mat)
                }
            }
        }
        val workers = ThreadLocal.withInitial { Row() }
        if (PARALLEL) java.util.stream.IntStream.range(0, h).parallel().forEach { workers.get().line(it) }
        else { val r = Row(); for (y in 0 until h) r.line(y) }
        // a soft inner line where a nearer part overlaps a farther one
        for (y in 0 until h) for (x in 0 until w) {
            val at = y * w + x
            val m = mats[at] ?: continue
            var i = idx[at]
            var k = 0
            while (k < 8) {
                val xx = x + NEIGH[k]; val yy = y + NEIGH[k + 1]
                k += 2
                if (xx !in 0 until w || yy !in 0 until h) continue
                val b = yy * w + xx
                if (innerLines && mats[b] != null && depth[at] - depth[b] > 3.0) { i = min(i, 1); break }
            }
            s.img.set(x, y, m.ramp[i])
        }
        return DepthImage(s.img, depth, view, anchorX, ground, px)
    }
}
