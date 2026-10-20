package preview

import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sin

/**
 * 211.12 (Chef 19.10., 22:48): the wood drawn for the pattern camera. Everything stands on the one ground plane and is
 * seen by the one camera: the clearing's grass and the path are worked out per pixel from where that pixel meets the
 * ground (so the path runs to its own vanishing point on the horizon), the edge of the wood stands at [wall] metres and is
 * drawn for that distance: big trunks, undergrowth at their feet, the crowns cut by the top of the picture; behind it the
 * dark inside of the wood, the light only through gaps. Drawn at half size and doubled, like the game's Kampforte.
 * The camera here: x across (m, right), d straight ahead (m), y up (m); [f], [cx], [hy] in half-size pixels.
 */
internal class WaldCam(val w: Int, val h: Int, val f: Double, val cx: Double, val hy: Double, val eye: Double) {
    fun sx(x: Double, d: Double) = cx + f * x / d
    fun sy(y: Double, d: Double) = hy + f * (eye - y) / d
    /** the height in metres a screen row shows at distance [d] */
    fun yAt(py: Double, d: Double) = eye - (py - hy) * d / f
}

/** A figure's foot on the ground, for its shadow. */
internal class Foot(val x: Double, val d: Double, val r: Double)

private fun hash(i: Int, j: Int, s: Int): Double {
    var n = i * 374761393 + j * 668265263 + s * 1442695041
    n = (n xor (n ushr 13)) * 1274126177
    n = n xor (n ushr 16)
    return (n and 0xFFFFFF) / 16777215.0
}

private fun noise(x: Double, y: Double, s: Int): Double {
    val xi = floor(x).toInt(); val yi = floor(y).toInt()
    val fx = x - xi; val fy = y - yi
    val u = fx * fx * (3 - 2 * fx); val v = fy * fy * (3 - 2 * fy)
    val a = hash(xi, yi, s); val b = hash(xi + 1, yi, s); val c = hash(xi, yi + 1, s); val e = hash(xi + 1, yi + 1, s)
    return a + (b - a) * u + (c - a) * v + (a - b - c + e) * u * v
}

private fun fbm(x: Double, y: Double, s: Int) = 0.5 * noise(x, y, s) + 0.3 * noise(x * 2.1, y * 2.1, s + 7) + 0.2 * noise(x * 4.3, y * 4.3, s + 13)

private val BAYER = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)

/** One of [tones] for brightness [v] (0..1), ordered dither between neighbours, as the game's pixel art does. */
private fun tone(tones: IntArray, v: Double, px: Int, py: Int): Int {
    val t = v.coerceIn(0.0, 1.0) * (tones.size - 1) + (BAYER[(py and 3) * 4 + (px and 3)] / 16.0 - 0.47)
    return tones[t.toInt().coerceIn(0, tones.size - 1)]
}

private fun mix(a: Int, b: Int, t: Double): Int {
    val k = t.coerceIn(0.0, 1.0)
    fun ch(s: Int) = (((a shr s) and 255) * (1 - k) + ((b shr s) and 255) * k).toInt()
    return (ch(16) shl 16) or (ch(8) shl 8) or ch(0)
}

private fun dark(c: Int, k: Double) = mix(0, c, k)

// day palette of the wood (BattleScene.forest, Light.DAY), with steps between for the dither
private val GRASS = intArrayOf(0x2A4C22, 0x3A6A2C, 0x4E7E38, 0x5E8C40, 0x76A04C, 0x92AE6C, 0xB4C886)
private val PATH = intArrayOf(0x5E4A36, 0x765E44, 0x8C7254, 0xA08664, 0xB49A76, 0xC8B28E)
private val FLOOR = intArrayOf(0x141C12, 0x1E2A1A, 0x2A3622, 0x38442A, 0x4C5634, 0x6A7044)
private val BARK = intArrayOf(0x241A14, 0x34281E, 0x463428, 0x5E4636, 0x76604A, 0x8E7A60)
private val BEECH = intArrayOf(0x2A2A24, 0x3C3A32, 0x524E42, 0x6A6454, 0x827A66, 0x9A9078)
private val LEAF = intArrayOf(0x14260F, 0x1E3618, 0x2A4A20, 0x3A6A34, 0x528A42, 0x74A852, 0x9CC468)
private val NEEDLE = intArrayOf(0x0A160E, 0x122416, 0x1A321E, 0x24442A, 0x325A36, 0x46723E)
private val FERN = intArrayOf(0x1A3016, 0x26401C, 0x3A5C28, 0x547A32, 0x76983E)
private val STONE = intArrayOf(0x4A4844, 0x6A6862, 0x8C8A82, 0xACAAA0, 0xCAC8BC)
private const val INSIDE = 0x14221A
private const val GLADE = 0xD8E4A0

/**
 * The wood seen by [cam]: the edge of the wood about [wall] metres ahead, a path through the clearing along [pathDeg]
 * (degrees to the right of straight ahead) through the point ([px0], [pd0]) on the ground, soft shadows under [feet].
 */
internal fun waldBild(cam: WaldCam, wall: Double, pathDeg: Double, px0: Double, pd0: Double, feet: List<Foot>, seed: Int): IntArray {
    val w = cam.w; val h = cam.h
    val img = IntArray(w * h)
    val pa = Math.toRadians(pathDeg); val ps = sin(pa); val pc = cos(pa)
    /** across the path (m), 0 on its middle, which winds a little */
    fun across(x: Double, d: Double): Double {
        val along = (x - px0) * ps + (d - pd0) * pc
        return (x - px0) * pc - (d - pd0) * ps - 0.35 * sin(along / 4.5)
    }
    fun along(x: Double, d: Double) = (x - px0) * ps + (d - pd0) * pc
    fun pathHalf(x: Double, d: Double) = 0.85 + 0.18 * (noise(along(x, d) * 0.6, 3.0, seed + 5) - 0.5)
    /** where the clearing ends at [x]: the edge winds, and opens a little where the path goes in */
    fun edge(x: Double): Double {
        var e = wall + 0.9 * sin(x * 0.7 + seed) + 1.2 * (noise(x * 0.45, 1.0, seed + 1) - 0.5)
        if (abs(x - (px0 + (e - pd0) * ps / pc)) < 2.4) e += 1.2
        return e
    }

    // the ground: every pixel finds where it meets the ground plane
    for (py in 0 until h) for (px in 0 until w) {
        val dy = py + 0.5 - cam.hy
        if (dy <= 0) { img[py * w + px] = INSIDE; continue }
        val d = cam.f * cam.eye / dy
        val x = (px + 0.5 - cam.cx) * d / cam.f
        val e = edge(x)
        val s = across(x, d)
        val onPath = abs(s) < pathHalf(x, d) + 0.22 * (noise(x * 3.0, d * 3.0, seed + 9) - 0.5)
        var c: Int
        if (d > e) {
            // inside the wood: needles, old leaves and moss, darker the deeper; light falls through gaps far back
            val deep = ((d - e) / 18.0).coerceIn(0.0, 1.0)
            var v = 0.55 + 0.5 * (fbm(x * 0.8, d * 0.8, seed + 20) - 0.5) - 0.35 * deep
            if (onPath) v += 0.12
            c = tone(FLOOR, v, px, py)
            val gap = noise(x * 0.18, d * 0.12, seed + 30)
            if (d > e + 12 && gap > 0.62) c = mix(c, GLADE, ((gap - 0.62) * 4).coerceIn(0.0, 0.5))
            if (onPath && d > e + 10) c = mix(c, GLADE, ((d - e - 10) / 14).coerceIn(0.0, 0.3) * (0.6 + 0.8 * noise(x * 2.0, d * 0.7, seed + 31)))
        } else {
            // the clearing: grass in broad patches, sun-dappled, in the shade of the edge near it
            var v = 0.52 + 0.55 * (fbm(x * 0.55, d * 0.55, seed + 2) - 0.5) + 0.22 * (noise(x * 5.0, d * 5.0, seed + 3) - 0.5)
            val shade = ((2.8 - (e - d)) / 2.8).coerceIn(0.0, 1.0)
            val dapple = noise(x * 1.3, d * 1.3, seed + 4)
            v -= 0.42 * shade * (if (dapple > 0.55) 0.45 else 1.0)
            if (onPath) {
                // the path: trodden earth, a lighter middle, grass creeping in at the edges
                val mid = 1 - (abs(s) / pathHalf(x, d)).coerceIn(0.0, 1.0)
                var pv = 0.45 + 0.25 * mid + 0.3 * (fbm(x * 1.6, d * 1.6, seed + 6) - 0.5) - 0.4 * shade
                if (noise(x * 9.0, d * 9.0, seed + 7) > 0.8) pv -= 0.25
                c = tone(PATH, pv, px, py)
            } else c = tone(GRASS, v, px, py)
        }
        // shadows of the figures, soft, a little to the right as the sun stands left
        for (ft in feet) {
            val q = ((x - ft.x - 0.12) / (ft.r * 1.25)).pow(2) + ((d - ft.d) / ft.r).pow(2)
            if (q < 1) c = dark(c, 0.55 + 0.4 * q)
        }
        img[py * w + px] = c
    }

    // things that stand on the ground, far ones first
    class Thing(val d: Double, val draw: () -> Unit)
    val things = mutableListOf<Thing>()
    fun put(px: Int, py: Int, c: Int) { if (px in 0 until w && py in 0 until h) img[py * w + px] = c }
    /** how much a thing at [d] fades into the dark inside of the wood */
    fun fade(d: Double, c: Int, x: Double): Int {
        val t = ((d - edge(x) - 0.5) / 16.0).coerceIn(0.0, 1.0).pow(0.7) * 0.8
        return mix(c, INSIDE, t)
    }
    val top = { d: Double -> cam.yAt(0.0, d) }

    /** a trunk of radius [r] at (x, d), lit from the left; [beech] smooth and grey, else brown furrowed bark */
    fun trunk(x: Double, d: Double, r: Double, beech: Boolean, k: Int) = Thing(d) {
        val ylim = top(d) + 0.2
        val pal = if (beech) BEECH else BARK
        val y0 = cam.sy(0.0, d).toInt(); val y1 = max(0, cam.sy(ylim, d).toInt())
        for (py in y1..y0 + 1) {
            val yy = cam.yAt(py + 0.5, d)
            if (yy < -0.05) continue
            // roots flare at the foot
            val rr = r * (1 + 0.7 * ((0.45 - yy) / 0.45).coerceIn(0.0, 1.0).pow(2)) * (1 + 0.04 * sin(yy * 3 + k))
            val hw = cam.f * rr / d
            val cxp = cam.sx(x, d)
            for (px in (cxp - hw).toInt()..(cxp + hw).toInt()) {
                val u = (px + 0.5 - cxp) / hw
                if (abs(u) > 1) continue
                val bark = if (beech) 0.12 * (noise(u * 2.0, yy * 1.5, k) - 0.5)
                    else 0.32 * (noise(u * 5.0 + k, yy * 0.9, k) - 0.5) + 0.12 * (noise(u * 9.0, yy * 6.0, k + 1) - 0.5)
                var v = 0.62 - 0.42 * u - 0.25 * u * u + bark
                var c = tone(pal, v, px, py)
                // moss on the shady foot
                if (yy < 0.6 && u > -0.2 && noise(u * 4.0, yy * 6.0, k + 2) > 0.5) c = tone(FERN, 0.55 - 0.3 * u, px, py)
                put(px, py, fade(d, c, x))
            }
        }
    }

    /** a round mass of leaves, centre (x, y, d), radius [r], lit from upper left */
    fun leaves(x: Double, y: Double, d: Double, r: Double, pal: IntArray, k: Int, fx: Double) = Thing(d) {
        val cxp = cam.sx(x, d); val cyp = cam.sy(y, d); val rp = cam.f * r / d
        for (py in (cyp - rp * 1.1).toInt()..(cyp + rp * 1.1).toInt()) for (px in (cxp - rp * 1.1).toInt()..(cxp + rp * 1.1).toInt()) {
            val u = (px + 0.5 - cxp) / rp; val v = (py + 0.5 - cyp) / rp
            val q = u * u + v * v
            // ragged edge: leaves stand out in clumps
            val clump = noise(u * 4.0 + k, v * 4.0, k)
            if (q > 0.72 + 0.45 * clump) continue
            val lit = 0.5 - 0.35 * u - 0.45 * v + 0.35 * (clump - 0.5) + 0.2 * (noise(u * 9.0, v * 9.0, k + 3) - 0.5)
            put(px, py, fade(d + fx, tone(pal, lit, px, py), x))
        }
    }

    /** a spruce: boughs in tiers, drooping, from just above the ground up past the top of the picture */
    fun spruce(x: Double, d: Double, k: Int) = Thing(d) {
        val ylim = top(d) + 0.6
        val tiers = mutableListOf<Double>()
        var yt = 0.7 + 0.3 * hash(k, 1, 9)
        while (yt < ylim + 0.6) { tiers += yt; yt += 0.42 + 0.1 * hash(k, tiers.size, 8) }
        // the stem shows between the lowest boughs
        val cxp = cam.sx(x, d)
        for (py in cam.sy(0.9, d).toInt()..cam.sy(0.0, d).toInt()) for (px in (cxp - cam.f * 0.12 / d).toInt()..(cxp + cam.f * 0.12 / d).toInt())
            put(px, py, fade(d, tone(BARK, 0.35, px, py), x))
        for ((i, t) in tiers.withIndex()) {
            val R = (2.1 * (1 - t / 16.0) + 0.3 * (hash(k, i, 3) - 0.5)).coerceAtLeast(0.4)
            val y0 = cam.sy(t + 0.2, d).toInt(); val y1 = cam.sy(t - 0.75, d).toInt()
            val x0 = (cxp - cam.f * R / d).toInt(); val x1 = (cxp + cam.f * R / d).toInt()
            for (py in y0..y1) for (px in x0..x1) {
                val dx = (px + 0.5 - cxp) * d / cam.f; val yy = cam.yAt(py + 0.5, d)
                val a = abs(dx) / R
                if (a > 1) continue
                // the bough slopes down to its tip; its lower edge hangs ragged
                val upper = t + 0.15 - 0.55 * a + 0.12 * (noise(dx * 3.0, t, k + 11) - 0.5)
                val lower = upper - 0.3 - 0.3 * noise(dx * 5.0, t * 3.0, k + i)
                if (yy > upper || yy < lower) continue
                val lit = 0.5 - 0.35 * (dx / R) - 0.5 * ((upper - yy) / 0.46) + 0.45 * (noise(dx * 5.0, yy * 7.0, k + 5) - 0.5)
                put(px, py, fade(d, tone(NEEDLE, lit, px, py), x))
            }
        }
    }

    /** ferns: fronds fanning out from one root */
    fun fern(x: Double, d: Double, size: Double, k: Int) = Thing(d) {
        val n = 7
        for (i in 0 until n) {
            val ang = Math.toRadians(-70.0 + 140.0 * i / (n - 1) + 10 * (hash(k, i, 4) - 0.5))
            val len = size * (0.75 + 0.35 * hash(k, i, 5))
            val steps = (cam.f * len / d * 1.4).toInt().coerceAtLeast(3)
            for (j in 0..steps) {
                val t = j.toDouble() / steps
                val bx = x + sin(ang) * len * t
                val by = cos(ang) * len * t * 0.9 - len * 0.35 * t * t
                val px = cam.sx(bx, d).toInt(); val py = cam.sy(max(0.0, by), d).toInt()
                val c = tone(FERN, 0.75 - 0.4 * t + 0.25 * sin(ang), px, py)
                put(px, py, fade(d, c, x))
                // leaflets either side of the frond
                if (j % 2 == 0 && t > 0.15) { put(px, py - 1, fade(d, tone(FERN, 0.9 - 0.4 * t, px, py), x)); put(px + 1, py + 1, fade(d, tone(FERN, 0.4, px, py), x)) }
            }
        }
    }

    /** a tuft of grass in the clearing */
    fun tuft(x: Double, d: Double, k: Int) = Thing(d) {
        val hgt = 0.14 + 0.16 * hash(k, 1, 1)
        val blades = 3 + (hash(k, 2, 1) * 3).toInt()
        for (i in 0 until blades) {
            val lean = (hash(k, i, 2) - 0.5) * 0.18
            val bx = x + (i - blades / 2.0) * 0.035
            val steps = (cam.f * hgt / d).toInt().coerceAtLeast(2)
            for (j in 0..steps) {
                val t = j.toDouble() / steps
                val px = cam.sx(bx + lean * t * t, d).toInt(); val py = cam.sy(hgt * t, d).toInt()
                put(px, py, tone(GRASS, 0.35 + 0.6 * t, px, py))
            }
        }
    }

    fun stone(x: Double, d: Double, r: Double, k: Int) = Thing(d) {
        val cxp = cam.sx(x, d); val cyp = cam.sy(0.0, d); val rp = cam.f * r / d
        for (py in (cyp - rp * 0.75).toInt()..cyp.toInt()) for (px in (cxp - rp).toInt()..(cxp + rp).toInt()) {
            val u = (px + 0.5 - cxp) / rp; val v = (py + 0.5 - cyp) / (rp * 0.75)
            if (u * u + v * v > 1 + 0.2 * (noise(u * 3.0, v * 3.0, k) - 0.5)) continue
            put(px, py, tone(STONE, 0.45 - 0.35 * u - 0.5 * (v + 0.5), px, py))
        }
    }

    fun flower(x: Double, d: Double, c: Int) = Thing(d) {
        val px = cam.sx(x, d).toInt(); val py = cam.sy(0.12, d).toInt()
        put(px, py + 1, 0x3A6A2C); put(px, py, c)
    }

    // what is in view at a distance, across
    fun span(d: Double) = Pair(-cam.cx * d / cam.f - 1.5, (w - cam.cx) * d / cam.f + 1.5)
    var k = seed * 100
    fun rnd() = hash(k++, 17, seed)

    // the trees: a close row along the edge, the inside of the wood behind it, two near ones framing the clearing
    val trees = mutableListOf<Pair<Double, Double>>()
    fun free(x: Double, d: Double, gap: Double) = trees.none { (tx, td) -> (tx - x).pow(2) + (td - d).pow(2) < gap * gap }
    fun plant(x: Double, d: Double, front: Boolean, crownFrom: Double = 2.5, oak: Boolean = false) {
        trees += x to d
        val kind = if (oak) 0.9 else rnd()
        val kk = (rnd() * 1e6).toInt()
        if (kind < 0.3) things += spruce(x, d, kk)
        else {
            val beech = kind < 0.42
            val r = if (front) 0.26 + 0.2 * rnd() else 0.16 + 0.18 * rnd()
            things += trunk(x, d, r, beech, kk)
            // the crown: big masses of leaves from about 3 m up, cut by the top of the picture
            val nLeaves = 6
            for (i in 0 until nLeaves) {
                val r = 0.7 + 0.5 * rnd()
                val ly = crownFrom + r + 2.5 * rnd(); val lx = x + (rnd() - 0.5) * 3.6; val ld = d + (rnd() - 0.5) * 1.2
                things += leaves(lx, ly, ld - 0.01, r, LEAF, kk + i, 0.0)
            }
            // a low branch with leaves now and then
            if (crownFrom < 4 && rnd() < 0.5) things += leaves(x + (rnd() - 0.5) * 1.6, 1.9 + rnd(), d - 0.05, 0.45 + 0.3 * rnd(), LEAF, kk + 9, 0.0)
        }
    }
    run {
        var x = span(wall).first
        while (x < span(wall).second) {
            val d = edge(x) + 0.3 + 1.2 * rnd()
            if (abs(across(x, d)) > 1.9 && free(x, d, 1.4)) plant(x, d, true)
            x += 1.3 + 1.1 * rnd()
        }
        for (i in 0 until 260) {
            val d = wall + 2.0 + 30.0 * rnd().pow(1.2)
            val (a, b) = span(d); val x = a + (b - a) * rnd()
            if (d < edge(x) + 1.2 || abs(across(x, d)) < 1.7 || !free(x, d, 1.5)) continue
            plant(x, d, false)
        }
        // framing the clearing near the camera on the left, clear of the fight: an oak, its crown high up
        val nearL = 12.6
        plant(span(nearL).first + 1.25, nearL, true, 5.2, oak = true)
    }
    // undergrowth along the edge: bushes and ferns, lower where the path goes in
    run {
        var x = span(wall).first
        while (x < span(wall).second) {
            val d = edge(x) - 0.3 + 0.9 * rnd()
            val onPath = abs(across(x, d)) < 1.4
            if (!onPath) {
                if (rnd() < 0.55) things += leaves(x, 0.35 + 0.3 * rnd(), d, 0.35 + 0.35 * rnd(), LEAF, (rnd() * 1e6).toInt(), 0.0)
                else things += fern(x, d, 0.55 + 0.35 * rnd(), (rnd() * 1e6).toInt())
            } else if (rnd() < 0.5) things += fern(x, d, 0.35, (rnd() * 1e6).toInt())
            x += 0.3 + 0.35 * rnd()
        }
        // ferns at the feet of the two framing trees
        for ((tx, td) in trees.takeLast(1)) for (i in 0 until 4) things += fern(tx + (rnd() - 0.5) * 1.6, td - 0.4 + rnd() * 0.6, 0.6, (rnd() * 1e6).toInt())
    }
    // the clearing: tufts, a few stones and flowers; none on the middle of the path
    run {
        for (i in 0 until 900) {
            val d = 9.5 + (wall + 1 - 9.5) * rnd(); val (a, b) = span(d); val x = a + (b - a) * rnd()
            if (d > edge(x)) continue
            val s = abs(across(x, d))
            if (s < pathHalf(x, d) - 0.1) continue
            when {
                rnd() < 0.02 -> things += stone(x, d, 0.08 + 0.12 * rnd(), i)
                rnd() < 0.05 -> things += flower(x, d, listOf(0xF4F0E0, 0xF0D860, 0xB8A0E0)[(rnd() * 3).toInt()])
                else -> things += tuft(x, d, i)
            }
        }
        for (i in 0 until 6) {
            val t = 2.0 + 14.0 * rnd(); val sx = (rnd() - 0.5) * 1.6
            val x = px0 + ps * t + pc * sx; val d = pd0 + pc * t - ps * sx
            if (d > 9.5 && d < edge(x) - 0.5) things += stone(x, d, 0.06 + 0.07 * rnd(), 50 + i)
        }
    }
    for (t in things.sortedByDescending { it.d }) t.draw()

    return img
}
