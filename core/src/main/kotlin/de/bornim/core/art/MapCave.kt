package de.bornim.core.art

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

/**
 * The things lying and standing about in the Bloodfang Cave in the new style, painted with [Sculpt] like the hero's
 * gear and the foes: real shapes lit from the upper left, the materials' ramps (drip-stone, old wood, bone, fur,
 * straw, sacking), grain and dirt. At double resolution like [MapGround]; seen at a slant from above.
 *
 * Draft stage (09.10.): every kind in three looks, for the preview sheet (HOEHLEDINGE=1); not used on the map yet.
 */
object MapCave {
    class Sprite(val img: PixelImage, val ax: Int, val ay: Int)

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, sat: Double = 1.0, value: Double = 1.0, bias: Double = 0.0) =
        Mat(Ramp.of(argb(rgb), sat = sat, value = value), shine, grain, bias)

    // drip-stone: pale and wet above, darker and dirtier at the foot
    private val sinter = m(0x7A7062, shine = 0.18, grain = 0.22, sat = 0.8, value = 0.82)
    private val sinterLow = m(0x5E564A, shine = 0.1, grain = 0.26, sat = 0.8, value = 0.85)
    private val sinterBreak = m(0x948A76, grain = 0.32, sat = 0.6, value = 0.85)
    // the goblins' timber: grey, weathered, dark where hands and soot have been
    private val plank = m(0x5E4C3A, grain = 0.22, sat = 0.75, value = 0.82)
    private val plankDark = m(0x40322A, grain = 0.2, sat = 0.75, value = 0.85)
    private val plankLid = m(0x524236, grain = 0.22, sat = 0.75, value = 0.7)
    private val iron = m(0x4A4440, shine = 0.35, grain = 0.25, sat = 0.6)
    private val rust = m(0x5A3E2C, shine = 0.15, grain = 0.35, sat = 0.8, value = 0.85)
    // cave rock, lichen; the things that glow; fire
    private val rock = m(0x5E564C, grain = 0.26, sat = 0.7, value = 0.85)
    private val rockDark = m(0x3E3832, grain = 0.26, sat = 0.7)
    private val stem = m(0x8C9A90, grain = 0.15, sat = 0.5)
    private val cap = m(0x2E8C88, shine = 0.4, grain = 0.12, value = 0.95)
    private val crystal = m(0x6A5296, shine = 0.7, grain = 0.12, sat = 0.75, value = 0.82)
    private val crystalDark = m(0x3E2E5E, shine = 0.45, grain = 0.12, sat = 0.75)
    private val charred = m(0x2A2220, grain = 0.3, sat = 0.5)
    private val root = m(0x4A3A2A, grain = 0.25, sat = 0.75)
    private val moss = m(0x3E4A2A, grain = 0.4, sat = 0.7, value = 0.8)
    private val meat = m(0x6A2E24, shine = 0.3, grain = 0.25, value = 0.8)
    // old bone, yellowed and stained
    private val bone = m(0xA89A7C, shine = 0.08, grain = 0.22, sat = 0.75)
    private val boneDark = m(0x7A6C54, grain = 0.25, sat = 0.75)
    // a wolf's hide, straw, sacking
    private val hide = m(0x5A5046, grain = 0.32, sat = 0.7)
    private val hideDark = m(0x3A322C, grain = 0.3, sat = 0.7)
    private val straw = m(0x9A8452, grain = 0.35, sat = 0.75)
    private val strawDark = m(0x5E4E30, grain = 0.3, sat = 0.75)
    private val sacking = m(0x6E5E44, grain = 0.34, sat = 0.7, value = 0.75)

    private val holeColor = argb(0x120E0C)
    private val crackColor = argb(0x2A241E)
    private val outlineColor = argb(0x0E0C0A)

    private fun done(s: Sculpt, ax: Int, ay: Int): Sprite {
        s.outline(outlineColor)
        return Sprite(s.img, ax, ay)
    }

    // ------------------------------------------------------------------ drip-stone

    /** A column of drip-stone from its foot upwards: rings of sinter, a blunt wet crown. */
    private fun column(s: Sculpt, x: Double, foot: Double, height: Double, r: Double, seed: Int, broken: Boolean = false) {
        val n = 9
        val top = if (broken) 0.55 else 1.0
        val pts = ArrayList<Double>()
        var lean = 0.0
        for (i in 0..n) {
            val t = i.toDouble() / n * top
            lean += (rnd(seed, i, 3) - 0.5) * 2.2
            val ring = 1 + 0.12 * sin(i * 2.1 + seed) + (rnd(seed, i, 4) - 0.5) * 0.14
            val rr = r * (1 - 0.62 * t) * ring
            pts += x + lean; pts += foot - height * t; pts += rr
        }
        s.chain(sinterLow, *pts.subList(0, 12).toDoubleArray())
        s.chain(sinter, *pts.subList(9, pts.size).toDoubleArray())
        val tx = pts[pts.size - 3]; val ty = pts[pts.size - 2]; val tr = pts[pts.size - 1]
        if (broken) {
            // the break: an uneven, pale face looking up, one side torn off higher than the other,
            // with a few faint rings of the stone the column grew from
            val b = ArrayList<Double>()
            val nb = 7
            for (i in 0..nb) {
                val f = i.toDouble() / nb
                b += tx - tr * 1.02 + f * tr * 2.04; b += ty - tr * (0.25 + 0.3 * rnd(seed, i, 6)) - tr * 0.45 * f
            }
            b += tx + tr * 1.02; b += ty + tr * 0.35
            b += tx - tr * 1.02; b += ty + tr * 0.35
            s.poly(sinterBreak, *b.toDoubleArray(), tiltY = -0.7, tiltX = 0.15, bevel = 2.5)
            s.line(tx - tr * 0.7, ty - tr * 0.1, tx - tr * 0.1, ty - tr * 0.3, argb(0x6E6656))
            s.line(tx - tr * 0.2, ty + tr * 0.1, tx + tr * 0.6, ty - tr * 0.35, argb(0x6E6656))
            s.line(tx - tr * 0.4, ty + tr * 0.15, tx + tr * 0.1, ty, crackColor)
        } else {
            s.blob(tx, ty - tr * 0.2, tr * 0.95, tr * 0.8, sinter)
            s.flat(tx + 0.5, ty - tr * 0.45, 1.2, 0.7, crackColor)       // where the drop falls
        }
        // flow lines running down the lit side
        for (k in 0 until 3) {
            val fx = x + lean * 0.5 - r * 0.3 + k * r * 0.25
            s.line(fx, foot - height * top * (0.2 + 0.25 * rnd(seed, k, 5)), fx + 1, foot - 3, argb(0x5A5244))
        }
    }

    fun stalagmite(variant: Int): Sprite {
        val w = 110; val h = 150
        val s = Sculpt(w, h, 500 + variant)
        val cx = w / 2.0; val foot = h - 14.0
        // flowstone spreading over the floor at the foot
        s.blob(cx, foot - 2, 34.0, 9.0, sinterLow, depth = 0.4)
        when (variant % 3) {
            0 -> {
                column(s, cx + 18, foot, 46.0, 11.0, 11)
                column(s, cx, foot, 96.0, 20.0, 12)
                column(s, cx - 20, foot + 2, 36.0, 10.0, 13)
            }
            1 -> {
                // an old column snapped off at knee height: a wide, low stump with a jagged break,
                // the rest lying shattered in pieces around it
                column(s, cx - 2, foot, 70.0, 26.0, 21, broken = true)
                for ((i, p) in listOf(Triple(30.0, 2.0, 8.0), Triple(42.0, -4.0, 6.0), Triple(-34.0, 3.0, 7.0), Triple(22.0, 8.0, 4.0)).withIndex()) {
                    val (ox, oy, r) = p
                    val x = cx + ox; val y = foot + oy
                    s.poly(sinter, x - r, y + r * 0.3, x - r * 0.4, y - r * 0.8, x + r * 0.6, y - r * 0.6, x + r, y + r * 0.2, x + r * 0.1, y + r * 0.6, tiltY = -0.3, bevel = 2.0)
                    s.line(x - r * 0.3, y - r * 0.5, x + r * 0.2, y + r * 0.2, crackColor)
                    if (i == 0) s.poly(sinterBreak, x - r * 0.4, y - r * 0.8, x + r * 0.6, y - r * 0.6, x + r * 0.2, y - r * 0.2, tiltY = -0.7, bevel = 0.8)
                }
            }
            else -> {
                // two columns grown into one over a wide skirt of flowstone, a thin straw between them
                s.blob(cx, foot - 4, 40.0, 11.0, sinterLow, depth = 0.5)
                column(s, cx - 13, foot, 88.0, 17.0, 31)
                column(s, cx + 12, foot, 70.0, 16.0, 32)
                s.blob(cx, foot - 30, 13.0, 16.0, sinter)
                s.blob(cx - 1, foot - 52, 9.0, 11.0, sinter)
                column(s, cx + 30, foot + 3, 22.0, 6.0, 33)
            }
        }
        return done(s, w / 2, h - 14)
    }

    // ------------------------------------------------------------------ a goblin crate

    /** A crate of rough planks: front face and lid, corner posts, battens, nails; [smashed] has a plank kicked in. */
    private fun crate(s: Sculpt, cx: Double, by: Double, half: Double, seed: Int, smashed: Boolean = false) {
        val fh = half * 1.3; val th = half * 1.0
        val skew = (rnd(seed, 0, 1) - 0.5) * 4
        val l = cx - half; val r = cx + half
        // front, facing us; lid, facing up
        s.poly(plank, l, by, r, by, r + skew, by - fh, l + skew, by - fh, tiltY = 0.25, bevel = 1.6)
        s.poly(plankLid, l + skew, by - fh, r + skew, by - fh, r + skew * 1.4, by - fh - th, l + skew * 1.4, by - fh - th, tiltY = -0.55, bevel = 1.2)
        // planks: gaps across the front, along the lid
        var y = by
        var k = 0
        while (true) {
            y -= 6 + rnd(seed, k, 2) * 4
            if (y <= by - fh + 2) break
            val sk = skew * (by - y) / fh
            s.line(l + sk + 1, y, r + sk - 1, y + (rnd(seed, k, 3) - 0.5), crackColor)
            k++
        }
        var x = l + 2
        while (true) {
            x += 7 + rnd(seed, k++, 4) * 4
            if (x >= r - 2) break
            s.line(x + skew, by - fh - 1, x + skew * 1.4, by - fh - th + 1, crackColor)
        }
        // corner posts and two battens across the lid, nailed with rusty nails
        for (px in doubleArrayOf(l + 3, r - 3)) {
            s.poly(plankDark, px - 3, by, px + 3, by, px + 3 + skew, by - fh, px - 3 + skew, by - fh, tiltY = 0.2, bevel = 1.2)
            for (j in 0 until 3) s.dot(px + skew * (j / 3.0), by - 4 - j * fh / 2.6, argb(0x2A1A12))
        }
        for (f in doubleArrayOf(0.25, 0.75)) {
            val yy = by - fh - th * f
            val sx = skew * (1 + 0.4 * f)
            s.poly(plankDark, l + sx, yy - 2.4, r + sx, yy - 2.4, r + sx, yy + 2.4, l + sx, yy + 2.4, tiltY = -0.6, bevel = 1.0)
            s.dot(l + sx + 3, yy, argb(0x2A1A12)); s.dot(r + sx - 3, yy, argb(0x2A1A12))
        }
        if (smashed) {
            // one plank kicked in: dark inside, splintered ends standing out
            val y0 = by - fh * 0.62; val y1 = by - fh * 0.36
            s.poly(Mat(Ramp.of(holeColor), inline = false), cx - half * 0.55, y1, cx + half * 0.35, y1 + 1, cx + half * 0.45, y0, cx - half * 0.45, y0 - 1, bevel = 0.0)
            for (j in 0 until 4) {
                val sx = cx - half * 0.5 + j * half * 0.3
                s.limb(sx, y0, sx + 1.5, y0 + 3 + rnd(seed, j, 6) * 3, 1.0, 0.4, plank)
            }
        }
        // grime and soot low on the front
        s.tint(cx, by - 3, half * 1.1, fh * 0.35, argb(0x1E1812), 0.35)
    }

    fun crates(variant: Int): Sprite {
        val w = 100; val h = 110
        val s = Sculpt(w, h, 600 + variant)
        val cx = w / 2.0; val foot = h - 12.0
        if (variant % 3 == 2) {
            // a barrel, its staves swelling, iron hoops, the lid knocked askew
            s.chain(plank, cx, foot - 2, 15.0, cx, foot - 20, 18.0, cx, foot - 40, 15.0)
            for (k in -3..3) s.line(cx + k * 4.6, foot - 38, cx + k * 5.2, foot - 3, crackColor)
            for (hy in doubleArrayOf(foot - 7, foot - 21, foot - 35)) {
                val r = if (hy == foot - 21) 18.2 else 16.0
                s.poly(iron, cx - r, hy - 1.6, cx + r, hy - 1.6, cx + r, hy + 1.6, cx - r, hy + 1.6, tiltY = 0.1, bevel = 0.8)
            }
            s.blob(cx, foot - 42, 14.5, 5.0, plankDark, depth = 0.2)
            s.flat(cx + 2, foot - 42, 10.0, 3.0, holeColor)
            s.poly(plankLid, cx - 6, foot - 46, cx + 18, foot - 52, cx + 21, foot - 47, cx - 3, foot - 41, tiltY = -0.6, bevel = 1.0)
            s.tint(cx, foot - 4, 18.0, 8.0, argb(0x1E1812), 0.35)
        } else if (variant % 3 == 0) {
            crate(s, cx - 3, foot, 22.0, 31)
            crate(s, cx + 4, foot - 36, 16.0, 32)
        } else {
            crate(s, cx + 6, foot, 18.0, 41, smashed = true)
            // a sack slumped against it
            s.blob(cx - 18, foot - 9, 12.0, 10.0, sacking, depth = 0.8)
            s.blob(cx - 17, foot - 17, 9.0, 7.0, sacking, depth = 0.8)
            s.blob(cx - 19, foot - 24, 6.0, 4.0, sacking)
            s.limb(cx - 21, foot - 27, cx - 18, foot - 33, 2.0, 1.4, sacking)
            s.line(cx - 24, foot - 25, cx - 14, foot - 26, argb(0x2A2016))
        }
        return done(s, w / 2, h - 12)
    }

    // ------------------------------------------------------------------ bones

    private fun boneAt(s: Sculpt, x: Double, y: Double, deg: Double, len: Double, r: Double, mat: Mat = bone) {
        val a = deg * PI / 180
        val x1 = x + cos(a) * len; val y1 = y + sin(a) * len * 0.55
        s.limb(x, y, x1, y1, r, r * 0.85, mat)
        s.blob(x, y, r * 1.7, r * 1.4, mat)
        s.blob(x1, y1, r * 1.6, r * 1.3, mat)
    }

    private fun skull(s: Sculpt, x: Double, y: Double, k: Double = 1.0, beast: Boolean = false) {
        if (beast) {
            s.blob(x, y, 7 * k, 6 * k, bone)
            s.limb(x + 3 * k, y + 1, x + 16 * k, y + 3, 4.5 * k, 2.6 * k, bone)
            s.flat(x - 1, y - 1, 2.2 * k, 1.6 * k, holeColor)
            for (j in 0 until 4) s.dot(x + (6 + j * 2.6) * k, y + 4.5 * k, argb(0x3A2E22))
            return
        }
        s.blob(x, y + 4 * k, 5.0 * k, 3.5 * k, boneDark)            // the jaw
        s.blob(x, y, 7.5 * k, 6.8 * k, bone)
        s.flat(x - 2.8 * k, y + 0.5, 2.3 * k, 2.0 * k, holeColor)
        s.flat(x + 2.8 * k, y + 0.5, 2.3 * k, 2.0 * k, holeColor)
        s.flat(x, y + 3.4 * k, 1.0 * k, 1.3 * k, holeColor)
        for (j in -3..3 step 2) s.dot(x + j * k, y + 5.6 * k, argb(0x3A2E22))
        s.line(x - 3 * k, y - 4 * k, x - 1 * k, y - 2 * k, crackColor)
    }

    fun bones(variant: Int): Sprite {
        val w = 120; val h = 80
        val s = Sculpt(w, h, 700 + variant)
        val cx = w / 2.0; val foot = h - 16.0
        if (variant % 3 == 2) {
            // what is left of a goblin: scattered bones, the small skull, a dented iron cap, a broken blade
            for (i in 0 until 7) boneAt(s, cx - 34 + rnd(i, 1, 72) * 64, foot - 2 - rnd(i, 2, 72) * 14, rnd(i, 3, 72) * 180, 8 + rnd(i, 4, 72) * 9, 1.3, if (i % 2 == 0) bone else boneDark)
            for (k in 0 until 4) s.chain(boneDark, cx - 4 + k * 4.0, foot - 12.0, 1.0, cx - 1 + k * 4.0, foot - 6.0, 1.0, cx - 3 + k * 4.0, foot - 1.0, 0.8)
            skull(s, cx + 14, foot - 10, 0.8)
            s.blob(cx - 18, foot - 12, 9.0, 6.5, rust)
            s.poly(rust, cx - 28, foot - 10, cx - 8, foot - 10, cx - 9, foot - 7, cx - 27, foot - 7, tiltY = 0.3, bevel = 1.0)
            s.line(cx - 22, foot - 16, cx - 17, foot - 13, holeColor)
            s.poly(iron, cx + 4, foot + 2, cx + 26, foot - 4, cx + 27, foot - 1, cx + 6, foot + 5, tiltY = -0.4, bevel = 0.8)
            s.poly(iron, cx + 27, foot - 4, cx + 31, foot - 6, cx + 30, foot - 1, cx + 27, foot - 1, tiltY = -0.4, bevel = 0.6)
            s.limb(cx - 2, foot + 5, cx + 4, foot + 3, 1.6, 1.6, plankDark)
        } else if (variant % 3 == 0) {
            // a heap pushed together: long bones crossing, three skulls on top
            for (i in 0 until 14) {
                boneAt(s, cx - 26 + rnd(i, 1, 70) * 52, foot - 4 - rnd(i, 2, 70) * 14, rnd(i, 3, 70) * 180, 10 + rnd(i, 4, 70) * 12, 1.4 + rnd(i, 5, 70) * 0.8, if (i % 3 == 0) boneDark else bone)
            }
            skull(s, cx - 9, foot - 16)
            skull(s, cx + 8, foot - 14, 0.9)
            skull(s, cx - 1, foot - 25)
        } else {
            // what scavengers left of a beast: a crooked spine pulled apart, broken ribs, the skull twisted away
            var x = cx - 36; var y = foot - 10; var a = -0.1
            val spine = ArrayList<Pair<Double, Double>>()
            for (k in 0 until 13) {
                a += (rnd(k, 1, 80) - 0.5) * 0.4
                x += cos(a) * (5.0 + if (k == 5 || k == 9) 4 else 0); y += sin(a) * 3.5
                spine += x to y
            }
            for (k in 2 until 10) {
                val (sx, sy) = spine[k]
                for (side in intArrayOf(-1, 1)) {
                    if (rnd(k, side, 81) < 0.25) continue
                    val len = (7 + rnd(k, side, 82) * 8) * if (rnd(k, side, 83) < 0.3) 0.55 else 1.0
                    val bend = 2 + rnd(k, side, 84) * 3
                    s.chain(if (side < 0) bone else boneDark, sx, sy, 1.3, sx + bend, sy + side * len * 0.55, 1.2, sx + bend * 0.6, sy + side * len, 0.9)
                }
            }
            for ((k, p) in spine.withIndex()) s.blob(p.first, p.second, 3.0 - k * 0.08, 2.4, bone)
            boneAt(s, cx - 34, foot + 3, 20.0, 18.0, 1.8)
            boneAt(s, cx + 22, foot + 2, 160.0, 12.0, 1.4, boneDark)
            skull(s, spine.last().first + 8, spine.last().second + 4, 0.85, beast = true)
            // tufts of hide still stuck to the bones
            for (i in 0 until 3) {
                val (tx, ty) = spine[1 + (rnd(i, 1, 85) * 9).toInt()]
                s.blob(tx + (rnd(i, 2, 85) - 0.5) * 6, ty + (rnd(i, 3, 85) - 0.5) * 6, 2.6, 1.6, hideDark)
            }
        }
        return done(s, w / 2, h - 16)
    }

    // ------------------------------------------------------------------ a sleeping place

    fun bedroll(variant: Int): Sprite {
        val w = 120; val h = 70
        val s = Sculpt(w, h, 800 + variant)
        val cx = w / 2.0; val cy = h - 26.0
        if (variant % 3 == 2) {
            // a blanket half unrolled on the stone: the flat part with folds and a frayed edge, the rest still
            // rolled up and tied at the head end; a bundle beside it
            s.poly(sacking, cx - 30, cy - 9, cx + 10, cy - 10, cx + 12, cy + 12, cx - 28, cy + 13, cx - 32, cy + 2, tiltY = -0.6, bevel = 2.0)
            for (k in 0 until 4) s.line(cx - 24 + k * 9.0, cy - 8, cx - 22 + k * 9.0, cy + 11, argb(0x3E3428))
            for (k in 0 until 6) s.dot(cx - 28 + k * 7.0, cy + 13.5, argb(0x5E5040))
            s.chain(sacking, cx + 16, cy - 10, 7.0, cx + 16, cy + 12, 7.0)
            s.blob(cx + 16, cy - 11, 7.0, 3.0, sacking, depth = 0.3)
            s.flat(cx + 16, cy - 11, 4.6, 1.8, argb(0x3A3024))
            s.flat(cx + 16, cy - 11, 2.0, 0.8, argb(0x5E4E3A))
            s.poly(plankDark, cx + 8, cy, cx + 24, cy, cx + 24, cy + 3, cx + 8, cy + 3, tiltY = -0.2, bevel = 0.8)
            s.blob(cx + 38, cy + 5, 9.0, 7.0, hideDark)
            s.limb(cx + 38, cy - 1, cx + 40, cy - 6, 2.2, 1.4, hideDark)
            s.line(cx + 33, cy, cx + 43, cy, argb(0x2A2016))
        } else if (variant % 3 == 0) {
            // a wolf hide, flat on the stone: head with ears and empty eyes, legs spread, tail
            // the legs lie flat and splayed, ragged at the paws
            for ((lx, sy) in listOf(-20.0 to -1.0, -20.0 to 1.0, 20.0 to -1.0, 20.0 to 1.0)) {
                val ox = if (lx > 0) 6.0 else -6.0
                s.blob(cx + lx + ox * 0.5, cy + sy * 13, 5.5, 4.0, hide, rot = sy * (if (lx > 0) 0.5 else -0.5), depth = 0.3)
                s.blob(cx + lx + ox, cy + sy * 17, 3.6, 2.6, hideDark, depth = 0.3)
            }
            s.chain(hide, cx + 28, cy, 5.0, cx + 40, cy + 2, 4.0, cx + 52, cy - 1, 1.8)
            s.blob(cx, cy, 32.0, 12.0, hide, depth = 0.35)
            s.blob(cx, cy, 30.0, 3.5, hideDark, depth = 0.3)       // the darker line of the back
            s.blob(cx - 37, cy, 10.0, 7.5, hide, depth = 0.5)
            s.limb(cx - 42, cy, cx - 53, cy + 1, 5.0, 2.8, hide)
            s.poly(hide, cx - 38, cy - 6, cx - 33, cy - 7, cx - 37, cy - 13, tiltY = -0.5)
            s.poly(hide, cx - 38, cy + 6, cx - 33, cy + 7, cx - 37, cy + 13, tiltY = 0.3)
            s.flat(cx - 40, cy - 2.6, 2.4, 1.2, holeColor)
            s.flat(cx - 40, cy + 2.6, 2.4, 1.2, holeColor)
            s.flat(cx - 54, cy + 1, 1.8, 1.6, holeColor)
            // a ragged rim: the edge of the hide frayed and uneven
            for (i in 0 until 40) {
                val a = i * 2 * PI / 40
                s.blob(cx + cos(a) * (31 + rnd(i, 2, 90) * 2), cy + sin(a) * (11 + rnd(i, 3, 90)), 2.4 + rnd(i, 1, 90) * 1.4, 1.6, hide, depth = 0.12)
            }
            // a stained rag thrown over the hind part
            s.blob(cx + 14, cy + 1, 14.0, 9.0, sacking, depth = 0.4)
            s.line(cx + 6, cy - 6, cx + 10, cy + 8, argb(0x3A3024))
            s.line(cx + 16, cy - 7, cx + 19, cy + 8, argb(0x3A3024))
        } else {
            // old straw, trampled flat, and a torn sack laid on it
            s.blob(cx, cy + 1, 42.0, 14.0, strawDark, depth = 0.25)
            val colors = intArrayOf(argb(0xA48C56), argb(0x7E6A40), argb(0xB89E62), argb(0x5E4E30))
            for (i in 0 until 520) {
                val u = rnd(i, 1, 91) * 2 - 1; val v = rnd(i, 2, 91) * 2 - 1
                if (u * u + v * v > 1) continue
                val x0 = cx + u * 40; val y0 = cy + 1 + v * 13
                val a = (rnd(i, 3, 91) - 0.5) * 1.2 + if (rnd(i, 4, 91) < 0.3) PI / 2 else 0.0
                val len = 4 + rnd(i, 5, 91) * 6
                s.line(x0, y0, x0 + cos(a) * len, y0 + sin(a) * len * 0.5, colors[i % 4])
            }
            // a torn sack laid flat over one end, rumpled
            s.poly(hideDark, cx + 2, cy - 9, cx + 22, cy - 11, cx + 34, cy - 4, cx + 30, cy + 8, cx + 12, cy + 10, cx + 4, cy + 4, tiltY = -0.3, bevel = 2.5)
            for (j in 0 until 3) s.line(cx + 8 + j * 8, cy - 9, cx + 6 + j * 8, cy + 8, argb(0x3A3024))
            s.poly(Mat(Ramp.of(argb(0x2A2016)), inline = false), cx + 18, cy + 1, cx + 24, cy - 1, cx + 22, cy + 4, bevel = 0.0)
            // a few straws lying over its edge
            for (i in 0 until 14) {
                val x0 = cx + rnd(i, 7, 92) * 34; val y0 = cy - 10 + rnd(i, 8, 92) * 20
                s.line(x0, y0, x0 + 5, y0 + (rnd(i, 9, 92) - 0.5) * 3, colors[i % 4])
            }
        }
        return done(s, w / 2, h - 14)
    }

    // ------------------------------------------------------------------ rock

    /** An irregular stone: a faceted outline, rounded at the edges, with a lit top face. */
    private fun stone(s: Sculpt, x: Double, y: Double, r: Double, seed: Int, mat: Mat = rock, squash: Double = 0.7) {
        val n = 8
        val pts = DoubleArray(n * 2)
        for (i in 0 until n) {
            val a = i * 2 * PI / n + rnd(seed, i, 1) * 0.5
            val rr = r * (0.78 + rnd(seed, i, 2) * 0.4)
            pts[i * 2] = x + cos(a) * rr; pts[i * 2 + 1] = y + sin(a) * rr * squash
        }
        s.poly(mat, *pts, tiltY = -0.15, bevel = r * 0.55)
        // the top: a flatter face catching the light
        s.poly(mat, x - r * 0.55, y - r * squash * 0.35, x + r * 0.1, y - r * squash * 0.8, x + r * 0.6, y - r * squash * 0.45, x + r * 0.2, y - r * squash * 0.05, tiltY = -0.7, bevel = r * 0.2)
    }

    fun boulder(variant: Int): Sprite {
        val w = 110; val h = 90
        val s = Sculpt(w, h, 900 + variant)
        val cx = w / 2.0; val foot = h - 14.0
        when (variant % 3) {
            0 -> {
                stone(s, cx + 22, foot - 6, 12.0, 91, rockDark)
                stone(s, cx - 4, foot - 20, 30.0, 92)
                stone(s, cx - 30, foot - 4, 9.0, 93)
            }
            1 -> {
                // split in two by frost and water, the halves leaning apart; a dark cleft with grit in it
                s.poly(Mat(Ramp.of(argb(0x14100E)), inline = false), cx - 5, foot - 30, cx + 7, foot - 29, cx + 3, foot - 2, cx - 1, foot - 2, bevel = 0.0)
                stone(s, cx - 17, foot - 20, 22.0, 94)
                stone(s, cx + 18, foot - 17, 20.0, 95, rockDark)
                for (i in 0 until 4) stone(s, cx - 1 + rnd(i, 1, 99) * 4, foot - 4 - i * 2.5, 2.4, 940 + i, rockDark)
                s.line(cx - 22, foot - 30, cx - 12, foot - 24, crackColor)
            }
            else -> {
                // a thick slab broken off the roof, lying tilted on a smaller stone: a top face, a thick front edge
                stone(s, cx + 20, foot - 8, 11.0, 96, rockDark)
                val top = doubleArrayOf(cx - 38, foot - 10, cx - 20, foot - 22, cx + 6, foot - 30, cx + 30, foot - 30, cx + 34, foot - 22, cx + 12, foot - 12, cx - 16, foot - 6)
                s.poly(rock, *top, tiltY = -0.6, bevel = 3.5)
                s.poly(rockDark, cx - 38, foot - 10, cx - 16, foot - 6, cx + 12, foot - 12, cx + 34, foot - 22, cx + 34, foot - 13, cx + 12, foot - 3, cx - 16, foot + 3, cx - 37, foot - 2, tiltY = 0.45, bevel = 2.0)
                s.line(cx - 6, foot - 24, cx + 4, foot - 14, crackColor)
                s.line(cx + 4, foot - 14, cx + 2, foot - 7, crackColor)
            }
        }
        // lichen and grime
        for (i in 0 until 4) s.tint(cx - 20 + rnd(i, variant, 97) * 40, foot - 30 + rnd(i, variant, 98) * 22, 5.0, 3.0, argb(0x4A5236), 0.35)
        return done(s, w / 2, h - 14)
    }

    fun rubble(variant: Int): Sprite {
        val w = 120; val h = 80
        val s = Sculpt(w, h, 1000 + variant)
        val cx = w / 2.0; val foot = h - 14.0
        val count = when (variant % 3) { 0 -> 22; 1 -> 14; else -> 12 }
        val spread = when (variant % 3) { 0 -> 26.0; 1 -> 44.0; else -> 36.0 }
        val pile = (0 until count).map { i ->
            val big = 1 - rnd(i, variant, 2) * 0.8
            Triple(cx + (rnd(i, variant, 3) - 0.5) * spread * 2 * (1.2 - big * 0.5), foot - 4 - rnd(i, variant, 4) * (if (variant % 3 == 0) 16.0 else 8.0) * big, 3 + big * big * 10)
        }.sortedBy { it.second }
        for ((i, p) in pile.withIndex()) stone(s, p.first, p.second, p.third, 1000 + i + variant * 50, if (i % 3 == 0) rockDark else rock)
        if (variant % 3 == 2) {
            // a broken prop of timber in the fall of stones
            s.poly(plankDark, cx - 34, foot - 2, cx + 18, foot - 16, cx + 21, foot - 11, cx - 31, foot + 3, tiltY = -0.3, bevel = 1.5)
            for (j in 0 until 4) s.limb(cx + 19, foot - 13, cx + 24 + j, foot - 18 + j * 3, 1.0, 0.4, plank)
            stone(s, cx - 6, foot - 8, 7.0, 1099)
        }
        return done(s, w / 2, h - 14)
    }

    // ------------------------------------------------------------------ things that glow

    fun mushrooms(variant: Int): Sprite {
        val w = 90; val h = 70
        val s = Sculpt(w, h, 1100 + variant)
        val cx = w / 2.0; val foot = h - 14.0
        if (variant % 3 == 1) {
            // shelf fungi on a rotting stump
            s.chain(root, cx, foot, 10.0, cx + 1, foot - 18, 9.0)
            s.blob(cx + 1, foot - 26, 9.0, 3.5, charred, depth = 0.3)
            for (k in 0 until 5) {
                val y = foot - 4 - k * 4.5; val side = if (k % 2 == 0) -1 else 1
                s.blob(cx + side * 11, y, 8.0 - k * 0.6, 2.6, cap, depth = 0.5)
            }
        } else {
            val n = if (variant % 3 == 0) 9 else 4
            val items = (0 until n).map { i -> Triple(cx + (rnd(i, variant, 1) - 0.5) * 50, foot - rnd(i, variant, 2) * 12, (if (variant % 3 == 0) 3.5 else 6.5) + rnd(i, variant, 3) * 4) }.sortedBy { it.second }
            for ((i, it) in items.withIndex()) {
                val (x, y, r) = it
                val hgt = r * (1.6 + rnd(i, variant, 4))
                s.limb(x, y, x + (rnd(i, variant, 5) - 0.5) * 3, y - hgt, r * 0.28, r * 0.22, stem)
                s.blob(x, y - hgt, r, r * 0.55, cap)
                s.flat(x - r * 0.3, y - hgt - r * 0.2, r * 0.25, r * 0.12, argb(0xB8FFF4))
            }
        }
        return done(s, w / 2, h - 14)
    }

    fun crystals(variant: Int): Sprite {
        val w = 100; val h = 110
        val s = Sculpt(w, h, 1200 + variant)
        val cx = w / 2.0; val foot = h - 14.0
        s.blob(cx, foot - 4, 26.0, 8.0, rockDark, depth = 0.5)
        val shards = when (variant % 3) {
            0 -> listOf(Triple(-14.0, 40.0, -20.0), Triple(2.0, 66.0, -4.0), Triple(14.0, 46.0, 14.0), Triple(-4.0, 30.0, 30.0), Triple(22.0, 26.0, 34.0))
            1 -> listOf(Triple(0.0, 82.0, 6.0), Triple(-12.0, 24.0, -30.0))
            else -> listOf(Triple(-18.0, 30.0, -40.0), Triple(-6.0, 44.0, -16.0), Triple(8.0, 22.0, 10.0), Triple(16.0, 18.0, 52.0), Triple(-24.0, 16.0, -70.0))
        }
        for ((i, sh) in shards.withIndex()) {
            val (dx, len, deg) = sh
            val a = deg * PI / 180
            val bx = cx + dx; val by = foot - 4
            val tx = bx + sin(a) * len; val ty = by - cos(a) * len
            val wd = 4.0 + len * 0.08
            val nx = cos(a) * wd; val ny = sin(a) * wd
            // two faces: the one towards the light and the one away; a tip
            s.poly(crystal, bx - nx, by - ny, bx, by, tx, ty, tx - nx * 0.6 + sin(a) * -5, ty - ny * 0.6 + cos(a) * 5, tiltX = -0.5, bevel = 0.8)
            s.poly(crystalDark, bx, by, bx + nx, by + ny, tx + nx * 0.6 - sin(a) * 5, ty + ny * 0.6 + cos(a) * 5, tx, ty, tiltX = 0.5, bevel = 0.8)
            s.line(bx + (tx - bx) * 0.35, by + (ty - by) * 0.35, tx, ty, argb(0x9A86C4))
            if (variant % 3 == 2 && i == 1) s.line(bx + (tx - bx) * 0.5 - 3, by + (ty - by) * 0.5, bx + (tx - bx) * 0.5 + 3, by + (ty - by) * 0.5 - 2, holeColor)
        }
        // the crystals grow out of rock: broken stone and grit round their feet, dust on the lower parts
        s.tint(cx, foot - 10, 30.0, 10.0, argb(0x3A342C), 0.45)
        for (i in 0 until 6) stone(s, cx - 24 + i * 9.5 + (rnd(i, variant, 20) - 0.5) * 4, foot - 2 + (rnd(i, variant, 21) - 0.5) * 4, 4.0 + rnd(i, variant, 22) * 4, 1250 + i + variant * 10, if (i % 2 == 0) rock else rockDark)
        return done(s, w / 2, h - 14)
    }

    // ------------------------------------------------------------------ timber and iron in the passages

    /** Two old posts at the sides of a passage two tiles wide, with a beam over it. */
    fun support(variant: Int): Sprite {
        val w = 2 * 64 + 40; val h = 160
        val s = Sculpt(w, h, 1300 + variant)
        val foot = h - 18.0
        val lx = 26.0; val rx = w - 26.0; val top = foot - 112
        val lean = doubleArrayOf((rnd(variant, 1, 13) - 0.5) * 8, (rnd(variant, 2, 13) - 0.5) * 8)
        for ((i, x) in doubleArrayOf(lx, rx).withIndex()) {
            val tx = x + lean[i]
            s.poly(plankDark, x - 7, foot, x + 7, foot, tx + 7, top, tx - 7, top, tiltX = -0.2, bevel = 3.0)
            for (k in 0 until 4) {
                val y0 = foot - 10 - rnd(variant, i * 10 + k, 14) * 90
                val xx = x + (tx - x) * (foot - y0) / 112 + (rnd(variant, i * 10 + k, 15) - 0.5) * 6
                s.line(xx, y0, xx + (tx - x) * 0.15, y0 - 12 - rnd(variant, k, 16) * 12, holeColor)
            }
            // a rotten foot, dark with damp
            s.tint(x, foot - 4, 8.0, 6.0, argb(0x1A1410), 0.5)
        }
        val sag = 4 + rnd(variant, 3, 17) * 6
        val ax = lx + lean[0]; val bx = rx + lean[1]; val mx = (ax + bx) / 2
        if (variant % 3 == 2) {
            // the beam has cracked in the middle; a crooked prop holds it up
            s.poly(plankDark, ax - 14, top - 14, mx - 2, top - 14 + sag * 1.6, mx - 2, top + 2 + sag * 1.6, ax - 14, top + 2, tiltY = -0.4, bevel = 2.0)
            s.poly(plankDark, mx + 2, top - 13 + sag * 1.6, bx + 14, top - 14, bx + 14, top + 2, mx + 2, top + 3 + sag * 1.6, tiltY = -0.4, bevel = 2.0)
            for (j in 0 until 5) s.limb(mx - 2, top - 6 + sag * 1.6 + j * 2, mx + 1 + j * 0.6, top - 1 + sag * 1.6 + j * 2, 1.0, 0.4, plank)
            s.poly(plank, mx - 4, foot, mx + 4, foot, mx + 9, top + 3 + sag * 1.6, mx + 1, top + 3 + sag * 1.6, tiltX = -0.2, bevel = 2.0)
        } else {
            s.poly(plankDark, ax - 14, top - 14, mx, top - 14 + sag, bx + 14, top - 14, bx + 14, top + 2, mx, top + 2 + sag, ax - 14, top + 2, tiltY = -0.4, bevel = 2.5)
            s.line(ax + 6, top - 6, mx - 10, top - 6 + sag, holeColor)
        }
        // wedges driven in above the beam, stones resting on it
        for (f in doubleArrayOf(0.15, 0.5, 0.85)) {
            val x = ax + (bx - ax) * f; val y = top - 14 + sag * (1 - abs(f - 0.5) * 2)
            s.poly(plank, x - 6, y, x + 6, y, x + 2, y - 9, x - 3, y - 9, tiltY = -0.3, bevel = 1.2)
        }
        for (k in 0 until 6) stone(s, ax + 10 + rnd(variant, k, 18) * (bx - ax - 20), top - 15 + sag * 0.6, 3 + rnd(variant, k, 19) * 3, 1300 + k, rockDark)
        if (variant % 3 == 1) {
            // an iron cramp and a rope of offerings: a goblin's charm of small bones
            s.poly(iron, ax - 6, top - 4, ax + 10, top - 4, ax + 10, top + 1, ax - 6, top + 1, tiltY = 0.2, bevel = 0.8)
            s.line(mx - 6, top + 2 + sag, mx - 8, top + 22 + sag, argb(0x3A3024))
            for (j in 0 until 3) boneAt(s, mx - 8, top + 10 + sag + j * 6, 80.0 + j * 20, 4.0, 0.9)
        }
        return done(s, w / 2, h - 18)
    }

    /** The iron gate across the passage before Grak's hall. */
    fun gate(variant: Int): Sprite {
        val w = 2 * 64 + 20; val h = 150
        val s = Sculpt(w, h, 1400 + variant)
        val foot = h - 20.0
        val n = 9
        for (i in 0 until n) {
            val x = 10 + i * (w - 20.0) / (n - 1)
            val bend = if (variant % 3 == 1 && (i == 4 || i == 5)) (if (i == 4) -7.0 else 7.0) else 0.0
            s.chain(iron, x, foot, 2.4, x + bend, foot - 60, 2.4, x, foot - 116, 2.2)
            s.poly(iron, x - 4, foot - 116, x + 4, foot - 116, x, foot - 128, tiltX = -0.3, bevel = 1.0)
            for (k in 0 until 2) s.tint(x, foot - 20 - rnd(i, k, 14) * 90, 2.6, 5.0, argb(0x6A3A1E), 0.55)
        }
        for (y in doubleArrayOf(foot - 26, foot - 90)) s.poly(iron, 6.0, y - 3, w - 6.0, y - 3, w - 6.0, y + 3, 6.0, y + 3, tiltY = -0.2, bevel = 1.5)
        if (variant % 3 == 2) {
            // a chain wound through the bars, a heavy padlock
            for (k in 0 until 10) s.blob(w / 2.0 - 22 + k * 4.6, foot - 58 + sin(k * 0.9) * 2, 2.8, 1.8, rust, rot = if (k % 2 == 0) 0.0 else PI / 2)
            s.blob(w / 2.0 + 4, foot - 48, 7.0, 8.0, iron)
            s.flat(w / 2.0 + 4, foot - 47, 1.4, 2.4, holeColor)
        } else {
            s.poly(iron, w / 2.0 - 9, foot - 64, w / 2.0 + 9, foot - 64, w / 2.0 + 9, foot - 48, w / 2.0 - 9, foot - 48, bevel = 2.0)
            s.flat(w / 2.0, foot - 57, 1.6, 3.0, holeColor)
        }
        return done(s, w / 2, h - 20)
    }

    // ------------------------------------------------------------------ fire and chest

    fun campfire(variant: Int): Sprite {
        val w = 110; val h = 110
        val s = Sculpt(w, h, 1500 + variant)
        val cx = w / 2.0; val by = h - 34.0
        // soot on the ground, a ring of stones, charred logs
        s.blob(cx, by, 34.0, 14.0, Mat(Ramp.of(argb(0x1E1A16)), grain = 0.3, inline = false), depth = 0.1)
        for (i in 0 until 11) {
            val a = i * 2 * PI / 11
            stone(s, cx + cos(a) * 26, by + sin(a) * 12, 5.5 + rnd(i, variant, 1) * 2, 1500 + i, if (i % 2 == 0) rock else rockDark)
        }
        for (a in doubleArrayOf(0.3, 1.9, 3.3)) s.limb(cx - cos(a) * 17, by - sin(a) * 7, cx + cos(a) * 17, by + sin(a) * 7, 3.0, 2.4, charred)
        val flame = when (variant % 3) { 0 -> 1.0; 1 -> 0.35; else -> 0.8 }
        s.flat(cx, by, 11.0, 5.0, argb(0x8A2A10))
        s.flat(cx, by, 6.0, 3.0, argb(0xE06A20))
        if (flame > 0.5) {
            for ((k, c) in listOf(argb(0xB8401A), argb(0xE88A2A), argb(0xFFD890)).withIndex()) {
                val r = (14 - k * 4) * flame
                s.poly(Mat(Ramp.of(c), inline = false), cx - r, by + 2, cx - r * 0.3, by - r * 2.2, cx, by - r * 1.3, cx + r * 0.4, by - r * 2.6, cx + r, by + 2, bevel = 0.0)
            }
        } else {
            for (i in 0 until 8) s.dot(cx - 8 + rnd(i, 1, 15) * 16, by - 2 + rnd(i, 2, 15) * 4, argb(0xFFB040))
        }
        if (variant % 3 == 2) {
            // a spit over the fire with a skinned rat turning on it, forked sticks either side
            for (x in doubleArrayOf(cx - 30, cx + 30)) {
                s.limb(x, by + 2, x, by - 34, 1.6, 1.4, plankDark)
                s.limb(x, by - 34, x - 4, by - 40, 1.2, 0.8, plankDark); s.limb(x, by - 34, x + 4, by - 40, 1.2, 0.8, plankDark)
            }
            s.limb(cx - 34, by - 36, cx + 34, by - 36, 1.2, 1.2, plankDark)
            s.blob(cx, by - 36, 11.0, 5.5, meat)
            s.limb(cx + 10, by - 36, cx + 22, by - 33, 1.2, 0.6, meat)
            s.blob(cx - 12, by - 36, 4.0, 3.5, meat)
        }
        return done(s, w / 2, h - 30)
    }

    fun chest(variant: Int): Sprite {
        val w = 90; val h = 90
        val s = Sculpt(w, h, 1600 + variant)
        val cx = w / 2.0; val by = h - 14.0
        val wood = if (variant % 3 == 1) plankDark else plank
        // box and rounded lid, iron bands, a lock
        s.poly(wood, cx - 24, by, cx + 24, by, cx + 24, by - 24, cx - 24, by - 24, tiltY = 0.25, bevel = 1.6)
        s.chain(plankLid, cx - 24, by - 30, 9.0, cx + 24, by - 30, 9.0)
        for (k in -1..1) s.line(cx - 22, by - 8 + k * 8, cx + 22, by - 8 + k * 8, crackColor)
        for (bx in doubleArrayOf(cx - 15, cx + 15)) {
            s.poly(iron, bx - 2.5, by, bx + 2.5, by, bx + 2.5, by - 24, bx - 2.5, by - 24, tiltY = 0.2, bevel = 0.8)
            s.limb(bx, by - 24, bx, by - 36, 2.6, 2.6, iron)
        }
        s.poly(iron, cx - 5, by - 27, cx + 5, by - 27, cx + 5, by - 16, cx - 5, by - 16, bevel = 1.2)
        s.flat(cx, by - 21, 1.2, 2.4, holeColor)
        if (variant % 3 == 1) {
            // studded, a crude skull scratched into the lid
            for (k in 0 until 6) s.dot(cx - 22 + k * 8.8, by - 3, argb(0x8A8278))
            s.line(cx - 8, by - 36, cx - 4, by - 33, crackColor); s.line(cx + 4, by - 33, cx + 8, by - 36, crackColor)
            s.line(cx - 5, by - 31, cx + 5, by - 31, crackColor)
        }
        if (variant % 3 == 2) {
            // a rusty chain thrown round it
            for (k in 0 until 12) s.blob(cx - 26 + k * 4.7, by - 12 + sin(k * 0.7) * 1.5, 2.6, 1.7, rust, rot = if (k % 2 == 0) 0.0 else PI / 2)
        }
        s.tint(cx, by - 3, 26.0, 8.0, argb(0x1E1812), 0.35)
        return done(s, w / 2, h - 14)
    }

    // ------------------------------------------------------------------ roots where daylight falls in

    fun roots(variant: Int): Sprite {
        val w = 140; val h = 120
        val s = Sculpt(w, h, 1700 + variant)
        val n = when (variant % 3) { 0 -> 12; 1 -> 6; else -> 9 }
        for (i in 0 until n) {
            val x = 12 + rnd(i, variant, 1) * (w - 24)
            val thick = rnd(i, variant, 3) < 0.3
            val len = (if (variant % 3 == 1) 55.0 else 22.0) + rnd(i, variant, 2) * (if (thick) 60 else 40)
            val r0 = if (thick) 3.6 else 1.4 + rnd(i, variant, 4)
            val pts = ArrayList<Double>()
            var px = x; var a = (rnd(i, variant, 5) - 0.5) * 0.6
            for (k in 0..7) {
                val t = k / 7.0
                a = a * 0.6 + (rnd(i, k, 6 + variant) - 0.5) * 0.35
                px += sin(a) * len / 7 * 0.6
                pts += px; pts += 2 + t * len; pts += (r0 * (1 - t * 0.85)).coerceAtLeast(0.5)
            }
            s.chain(root, *pts.toDoubleArray())
            // side rootlets and hair at the end
            for (k in 2..6 step 2) if (rnd(i, k, 7) < 0.6) {
                val bx = pts[k * 3]; val by = pts[k * 3 + 1]; val side = if (rnd(i, k, 8) < 0.5) -1 else 1
                s.line(bx, by, bx + side * (4 + rnd(i, k, 9) * 6), by + 5 + rnd(i, k, 10) * 8, argb(0x3A2E22))
            }
            val ex = pts[pts.size - 3]; val ey = pts[pts.size - 2]
            for (j in -1..1) s.line(ex, ey, ex + j * 2 + (rnd(i, j, 11) - 0.5) * 2, ey + 3 + rnd(i, j, 12) * 4, argb(0x5A4A36))
        }
        if (variant % 3 != 1) {
            // moss hanging in beards between the roots
            for (i in 0 until (if (variant % 3 == 2) 7 else 4)) {
                val x = 20 + rnd(i, variant, 5) * (w - 40); val len = 10 + rnd(i, variant, 6) * 18
                s.chain(moss, x, 2.0, 4.0, x + 1, 2 + len * 0.6, 3.0, x - 1, 2 + len, 1.0)
            }
        }
        return done(s, w / 2, 0)
    }
}
