package de.bornim.core.art

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * The things lying and standing about in the Bloodfang Cave in the new style, painted with [Sculpt] like the hero's
 * gear and the foes: real shapes lit from the upper left, the materials' ramps (drip-stone, old wood, bone, fur,
 * straw, sacking), grain and dirt. At double resolution like [MapGround]; seen at a slant from above.
 *
 * Draft stage (09.10.): a sample of four kinds with two looks each, for the preview sheet (HOEHLEDINGE=1).
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
    private val iron = m(0x4A4440, shine = 0.35, grain = 0.25, sat = 0.6)
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
            // the break: a rough, pale face looking up
            s.blob(tx, ty, tr * 1.05, tr * 0.45, sinterBreak, depth = 0.35)
            s.line(tx - tr * 0.5, ty, tx + tr * 0.3, ty - 1, crackColor)
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
        when (variant % 2) {
            0 -> {
                column(s, cx + 18, foot, 46.0, 11.0, 11)
                column(s, cx, foot, 96.0, 20.0, 12)
                column(s, cx - 20, foot + 2, 36.0, 10.0, 13)
            }
            else -> {
                // an old column snapped off at knee height: a wide, low stump with a jagged break,
                // the rest lying shattered in pieces around it
                column(s, cx - 2, foot, 64.0, 26.0, 21, broken = true)
                val bx = cx - 2; val by = foot - 64 * 0.55 + 2
                s.poly(sinterBreak, bx - 21, by + 3, bx - 12, by - 7, bx - 3, by - 1, bx + 5, by - 11, bx + 13, by - 3, bx + 21, by + 2, bx + 12, by + 8, bx - 10, by + 8, tiltY = -0.6, bevel = 1.5)
                s.line(bx - 8, by - 1, bx + 6, by - 3, crackColor)
                for ((i, p) in listOf(Triple(30.0, 2.0, 8.0), Triple(42.0, -4.0, 6.0), Triple(-34.0, 3.0, 7.0), Triple(22.0, 8.0, 4.0)).withIndex()) {
                    val (ox, oy, r) = p
                    val x = cx + ox; val y = foot + oy
                    s.poly(sinter, x - r, y + r * 0.3, x - r * 0.4, y - r * 0.8, x + r * 0.6, y - r * 0.6, x + r, y + r * 0.2, x + r * 0.1, y + r * 0.6, tiltY = -0.3, bevel = 2.0)
                    s.line(x - r * 0.3, y - r * 0.5, x + r * 0.2, y + r * 0.2, crackColor)
                    if (i == 0) s.poly(sinterBreak, x - r * 0.4, y - r * 0.8, x + r * 0.6, y - r * 0.6, x + r * 0.2, y - r * 0.2, tiltY = -0.7, bevel = 0.8)
                }
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
        s.poly(plank, l + skew, by - fh, r + skew, by - fh, r + skew * 1.4, by - fh - th, l + skew * 1.4, by - fh - th, tiltY = -0.75, bevel = 1.2)
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
        if (variant % 2 == 0) {
            crate(s, cx - 3, foot, 22.0, 31)
            crate(s, cx + 4, foot - 36, 16.0, 32)
        } else {
            crate(s, cx + 6, foot, 18.0, 41, smashed = true)
            // a sack slumped against it
            s.blob(cx - 18, foot - 11, 11.0, 12.0, sacking, depth = 0.8)
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
        if (variant % 2 == 0) {
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
        if (variant % 2 == 0) {
            // a wolf hide, flat on the stone: head with ears and empty eyes, legs spread, tail
            for ((lx, sy) in listOf(-20.0 to -1.0, -20.0 to 1.0, 20.0 to -1.0, 20.0 to 1.0)) {
                val ox = if (lx > 0) 7.0 else -7.0
                s.limb(cx + lx, cy + sy * 8, cx + lx + ox, cy + sy * 18, 4.0, 2.4, hide)
                for (j in -1..1) s.dot(cx + lx + ox + j, cy + sy * 19.5, argb(0x18120E))
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
            // the fur lies outwards from the back: dark roots, light tips
            val furDark = argb(0x2E2620); val furTip = argb(0x8A7E6E)
            for (i in 0 until 260) {
                val u = rnd(i, 1, 90) * 2 - 1; val side = if (rnd(i, 2, 90) < 0.5) -1 else 1
                val fx = cx + u * 28; val fy = cy + side * (2 + rnd(i, 3, 90) * 9)
                val len = 3 + rnd(i, 4, 90) * 3
                s.line(fx, fy, fx + 1, fy + side * len * 0.5, furDark)
                s.dot(fx + 1, fy + side * len * 0.6, furTip)
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
            s.poly(sacking, cx + 2, cy - 9, cx + 22, cy - 11, cx + 34, cy - 4, cx + 30, cy + 8, cx + 12, cy + 10, cx + 4, cy + 4, tiltY = -0.45, bevel = 2.5)
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
}
