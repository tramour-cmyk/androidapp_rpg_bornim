package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The things lying and standing about in the Bloodfang Cave in the new style, painted with [Sculpt] like the hero's
 * gear and the foes: real shapes lit from the upper left, the materials' ramps (drip-stone, old wood, bone, fur,
 * straw, sacking), grain and dirt. At double resolution like [MapGround]; seen at a slant from above.
 *
 * Also the ground of the cave ([ground]): rock floor with ledges, cracks, grit and damp, walls with a dark top and a
 * lit face so one reads the rooms, the pool, and the forest coming in at the mouth; drawn in chunks like [MapGround].
 * Every kind of thing comes in three looks (preview HOEHLEDINGE=1).
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
            // a heap of rags and old blankets, pushed together into a bed: grubby linen, brown wool,
            // a faded red cloth, all creased and frayed, a rolled rag as a pillow
            val cloths = listOf(
                Triple(m(0x5E5040, grain = 0.3, sat = 0.6, value = 0.8), -6.0, 0.0),
                Triple(m(0x6A5E4C, grain = 0.32, sat = 0.5, value = 0.85), 10.0, -3.0),
                Triple(m(0x5A3428, grain = 0.3, sat = 0.55, value = 0.75), -14.0, 4.0),
                Triple(m(0x4E4438, grain = 0.3, sat = 0.5, value = 0.8), 14.0, 5.0),
            )
            for ((i, c) in cloths.withIndex()) {
                val (mat, dx, dy) = c
                val pts = ArrayList<Double>()
                val n = 9
                for (k in 0 until n) {
                    val a = k * 2 * PI / n + rnd(i, k, 94) * 0.4
                    val r = 1 + (rnd(i, k, 95) - 0.5) * 0.35
                    pts += cx + dx + cos(a) * (22 - i * 2) * r; pts += cy + dy + sin(a) * (10 - i * 0.5) * r
                }
                s.poly(mat, *pts.toDoubleArray(), tiltY = -0.55, bevel = 3.0)
                // creases and frayed threads
                for (k in 0 until 3) s.line(cx + dx - 12 + k * 9 + rnd(i, k, 96) * 4, cy + dy - 6, cx + dx - 9 + k * 9, cy + dy + 6, argb(0x2E261E))
                for (k in 0 until 4) {
                    val a = rnd(i, k, 97) * 2 * PI
                    val ex = cx + dx + cos(a) * (22 - i * 2); val ey = cy + dy + sin(a) * (10 - i * 0.5)
                    s.line(ex, ey, ex + cos(a) * 3, ey + sin(a) * 2, argb(0x6E6250))
                }
            }
            s.limb(cx - 30, cy - 4, cx - 16, cy - 6, 5.0, 4.5, m(0x6A5E4C, grain = 0.32, sat = 0.5, value = 0.85))
            s.line(cx - 26, cy - 9, cx - 25, cy, argb(0x2E261E))
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

    fun campfire(variant: Int, frame: Int = 0): Sprite {
        val w = 110; val h = 110
        val s = Sculpt(w, h, 1500 + variant)
        val flick = if (frame % 2 == 0) 1.0 else 0.86
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
                val sway = if (frame % 2 == 0) 0.0 else r * 0.25
                s.poly(Mat(Ramp.of(c), inline = false), cx - r, by + 2, cx - r * 0.3 + sway, by - r * 2.2 * flick, cx, by - r * 1.3, cx + r * 0.4 - sway, by - r * 2.6 / flick, cx + r, by + 2, bevel = 0.0)
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

    fun chest(variant: Int, open: Boolean = false): Sprite {
        val w = 90; val h = 90
        val s = Sculpt(w, h, 1600 + variant)
        val cx = w / 2.0; val by = h - 14.0
        val wood = if (variant % 3 == 1) plankDark else plank
        if (open) {
            // the lid thrown back, standing up behind the box; the box empty and dark inside
            s.poly(plankLid, cx - 24, by - 26, cx + 24, by - 26, cx + 22, by - 52, cx - 22, by - 52, tiltY = 0.1, bevel = 2.0)
            for (bx in doubleArrayOf(cx - 15, cx + 15)) s.poly(iron, bx - 2.5, by - 27, bx + 2.5, by - 27, bx + 2.3, by - 51, bx - 2.3, by - 51, bevel = 0.8)
            s.poly(wood, cx - 24, by, cx + 24, by, cx + 24, by - 24, cx - 24, by - 24, tiltY = 0.25, bevel = 1.6)
            s.poly(Mat(Ramp.of(holeColor), inline = false), cx - 22, by - 24, cx + 22, by - 24, cx + 22, by - 30, cx - 22, by - 30, bevel = 0.0)
            for (k in -1..1) s.line(cx - 22, by - 8 + k * 8, cx + 22, by - 8 + k * 8, crackColor)
            for (bx in doubleArrayOf(cx - 15, cx + 15)) s.poly(iron, bx - 2.5, by, bx + 2.5, by, bx + 2.5, by - 24, bx - 2.5, by - 24, tiltY = 0.2, bevel = 0.8)
            s.tint(cx, by - 3, 26.0, 8.0, argb(0x1E1812), 0.35)
            return done(s, w / 2, h - 14)
        }
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

    /** A torch in an iron bracket on the rock face, flame flickering between two [frame]s. */
    fun torch(frame: Int): Sprite {
        val w = 40; val h = 80
        val s = Sculpt(w, h, 1650 + frame)
        val cx = w / 2.0; val by = h - 10.0
        s.poly(iron, cx - 6, by - 26, cx + 6, by - 26, cx + 6, by - 20, cx - 6, by - 20, tiltY = 0.2, bevel = 1.0)
        s.limb(cx, by - 22, cx, by - 10, 1.4, 1.4, iron)
        s.limb(cx + 1, by - 22, cx - 1, by - 44, 2.4, 3.0, plankDark)
        s.blob(cx - 1, by - 46, 4.0, 3.0, charred)
        val f = if (frame % 2 == 0) 1.0 else 0.85; val sw = if (frame % 2 == 0) 0.0 else 1.5
        for ((k, c) in listOf(argb(0xB8401A), argb(0xE88A2A), argb(0xFFD890)).withIndex()) {
            val r = (7 - k * 2).toDouble()
            s.poly(Mat(Ramp.of(c), inline = false), cx - 1 - r, by - 46, cx - 1 - r * 0.2 + sw, by - 46 - r * 3.2 * f, cx - 1 + r, by - 46, bevel = 0.0)
        }
        return done(s, w / 2, h - 10)
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

    // ================================================================== on the map

    private const val D = MapGround.D
    private const val S = MapGround.S

    private val spriteCache = HashMap<String, Sprite>()

    private fun cached(key: String, make: () -> Sprite): Sprite = synchronized(spriteCache) { spriteCache[key] } ?: make().also { synchronized(spriteCache) { spriteCache[key] = it } }

    /** A thing standing with its anchor at art pixel ([artX], [artY]); it sorts by [sortY] (art pixels, its foot by default). */
    private fun obj(sp: Sprite, artX: Double, artY: Double, sortY: Double = artY): WorldArt.Obj {
        val x = Math.floorDiv(artX.toInt() - sp.ax, D); val y = Math.floorDiv(artY.toInt() - sp.ay, D)
        return WorldArt.Obj(sp.img, x, y, (sortY / D).toInt(), D)
    }

    /** The new pictures for one tile of a cave, or null if the tile keeps its old picture. */
    fun objects(map: MapDef, tx: Int, ty: Int, frame: Int = 0, chestOpen: Boolean = false, gateOpen: Boolean = false): List<WorldArt.Obj>? {
        val v = hash(tx, ty, 77) % 3
        val cx = (tx + 0.5) * S; val top = ty * S.toDouble()
        return when (map.tile(tx, ty)) {
            Tile.CAVE_FLOOR, Tile.CAVE_WALL, Tile.CAVE_EXIT, Tile.WATER -> emptyList()
            Tile.STALAGMITE -> listOf(obj(cached("stalagmite/$v") { stalagmite(v) }, cx, top + S * 0.82))
            Tile.ROCK -> listOf(obj(cached("boulder/$v") { boulder(v) }, cx, top + S * 0.8))
            Tile.CRATE -> listOf(obj(cached("crates/$v") { crates(v) }, cx, top + S * 0.85))
            Tile.CHEST -> listOf(obj(cached("chest/$v/$chestOpen") { chest(v, chestOpen) }, cx, top + S * 0.82))
            Tile.CAMPFIRE -> listOf(obj(cached("fire/$v/${frame % 2}") { campfire(v, frame) }, cx, top + S * 0.55))
            // what lies flat or low on the floor: the hero walks over it, so it sorts behind
            Tile.GLOWSHROOM -> listOf(obj(cached("shrooms/$v") { mushrooms(v) }, cx, top + S * 0.7, top))
            Tile.BONES -> listOf(obj(cached("bones/$v") { bones(v) }, cx, top + S * 0.75, top))
            Tile.BEDROLL -> listOf(obj(cached("bed/$v") { bedroll(v) }, cx, top + S * 0.75, top))
            Tile.RUBBLE -> listOf(obj(cached("rubble/$v") { rubble(v) }, cx, top + S * 0.8, top))
            // crystals grow out of the foot of the rock face, into the room below
            Tile.CRYSTAL -> listOf(obj(cached("crystals/$v") { crystals(v) }, cx, top + S * 1.08))
            Tile.TORCH -> listOf(obj(cached("torch/${frame % 2}") { torch(frame) }, cx, top + S * 0.95))
            // roots hang from the crack in the roof where daylight falls in
            Tile.SKYLIGHT -> listOf(obj(cached("roots/$v") { roots(v) }, cx, top - S * 0.4, top))
            // supports and the gate span the passage: drawn once, at the left one of each pair
            // (right behind the gate the gate's own frame is enough)
            Tile.SUPPORT -> if (map.tile(tx - 1, ty) == Tile.SUPPORT || map.tile(tx, ty - 1) == Tile.GATE) emptyList() else listOf(obj(cached("support/$v") { support(v) }, (tx + 1.0) * S, top + S * 0.6))
            Tile.GATE -> if (gateOpen || map.tile(tx - 1, ty) == Tile.GATE) emptyList() else listOf(obj(cached("gate/0") { gate(0) }, (tx + 1.0) * S, top + S * 0.62))
            else -> null
        }
    }

    // ================================================================== the ground

    private fun vnoise(x: Double, y: Double, cell: Double, sd: Int): Double {
        val fx = x / cell; val fy = y / cell
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var w = fy - iy
        u = u * u * (3 - 2 * u); w = w * w * (3 - 2 * w)
        val a = rnd(ix, iy, sd) * (1 - u) + rnd(ix + 1, iy, sd) * u
        val b = rnd(ix, iy + 1, sd) * (1 - u) + rnd(ix + 1, iy + 1, sd) * u
        return a * (1 - w) + b * w
    }

    private fun fbm(x: Double, y: Double, cell: Double, sd: Int, octaves: Int = 3): Double {
        var sum = 0.0; var amp = 1.0; var tot = 0.0; var c = cell
        for (o in 0 until octaves) { sum += vnoise(x, y, c, sd + o * 17) * amp; tot += amp; amp *= 0.5; c = maxOf(2.0, c / 2) }
        return sum / tot
    }

    /** How much of the tiles that pass [test] lies at art pixel ([x], [y]), blended between tile centres (0..1). */
    private fun field(map: MapDef, x: Double, y: Double, test: (Tile) -> Boolean): Double {
        val fx = x / S - 0.5; val fy = y / S - 0.5
        val ix = floor(fx).toInt(); val iy = floor(fy).toInt()
        var u = fx - ix; var w = fy - iy
        u = u * u * (3 - 2 * u); w = w * w * (3 - 2 * w)
        fun at(tx: Int, ty: Int) = if (test(map.tile(tx, ty))) 1.0 else 0.0
        return (at(ix, iy) * (1 - u) + at(ix + 1, iy) * u) * (1 - w) + (at(ix, iy + 1) * (1 - u) + at(ix + 1, iy + 1) * u) * w
    }

    /** The same, smoothed over a wider area (about two tiles): for damp near water and the like. */
    private fun wide(map: MapDef, x: Double, y: Double, test: (Tile) -> Boolean): Double {
        var t = 0.0
        for (dy in -1..1) for (dx in -1..1) t += field(map, x + dx * S * 0.8, y + dy * S * 0.8, test) * (if (dx == 0 && dy == 0) 2.0 else 0.75)
        return t / 8.0
    }

    private val rockTiles: (Tile) -> Boolean = { it == Tile.CAVE_WALL || it == Tile.CRYSTAL || it == Tile.TORCH }
    private val waterTiles: (Tile) -> Boolean = { it == Tile.WATER }
    private val skyTiles: (Tile) -> Boolean = { it == Tile.SKYLIGHT }

    /** Height of a rock face in art pixels. */
    private const val FACE = 84

    private fun c3(c: Int) = doubleArrayOf(((c shr 16) and 0xFF).toDouble(), ((c shr 8) and 0xFF).toDouble(), (c and 0xFF).toDouble())
    private val FLOOR_D = c3(0x3A342F); private val FLOOR_L = c3(0x665E54); private val FLOOR_M = c3(0x4A4038); private val DUST = c3(0x5A4E40)
    private val MOSS_G = c3(0x3A4A2C); private val POOL_RIM = c3(0x22201C); private val POOL_S = c3(0x1E2A2C); private val POOL_D = c3(0x06090A)
    private val PUD = c3(0x1E262A); private val SHEEN = c3(0x7A8890); private val EARTH = c3(0x3A2E22); private val MOSS_OUT = c3(0x3A4A26)
    private val FACE_L = c3(0x6E665C); private val FACE_D = c3(0x3A342F); private val STREAK = c3(0x2A3034)
    private val TOP_D = c3(0x2A2624); private val TOP_L = c3(0x4A423A); private val LIP = c3(0x6A6258); private val EDGE = c3(0x7A7268)

    private fun mixIn(col: DoubleArray, c: DoubleArray, t: Double) {
        val k = t.coerceIn(0.0, 1.0)
        for (i in 0..2) col[i] += (c[i] - col[i]) * k
    }

    /** The ground of chunk ([cx], [cy]) of a cave, [MapGround.CH] tiles square. */
    fun ground(map: MapDef, cx: Int, cy: Int): PixelImage {
        val size = MapGround.CH * S
        val ox = cx * size; val oy = cy * size
        // the rock as drawn, with a margin round the chunk: faces need to know the floor below them
        val m = FACE + 12
        val ew = size + 2 * m
        val wall = BooleanArray(ew * ew)
        for (yy in 0 until ew) for (xx in 0 until ew) {
            val x = (ox - m + xx).toDouble(); val y = (oy - m + yy).toDouble()
            val f = field(map, x, y, rockTiles) + (fbm(x, y, 120.0, 4) - 0.5) * 0.5 + (fbm(x, y, 44.0, 5) - 0.5) * 0.3 + (vnoise(x, y, 12.0, 6) - 0.5) * 0.12
            wall[yy * ew + xx] = f > 0.5
        }
        // how far below each rock pixel the floor begins (0 on the floor)
        val below = IntArray(ew * ew)
        for (xx in 0 until ew) {
            var d = 999
            for (yy in ew - 1 downTo 0) {
                val i = yy * ew + xx
                d = if (!wall[i]) 0 else minOf(d + 1, 999)
                below[i] = d
            }
        }
        // distance (roughly, in pixels) of floor pixels to the rock and of rock pixels to the floor
        val big = 999
        val dist = IntArray(ew * ew) { big }
        for (i in 0 until ew * ew) if (wall[i]) dist[i] = 0
        val toFloor = IntArray(ew * ew) { big }
        for (i in 0 until ew * ew) if (!wall[i]) toFloor[i] = 0
        for (arr in listOf(dist, toFloor)) {
            for (yy in 0 until ew) for (xx in 0 until ew) {
                val i = yy * ew + xx
                if (xx > 0) arr[i] = minOf(arr[i], arr[i - 1] + 2)
                if (yy > 0) arr[i] = minOf(arr[i], arr[i - ew] + 2)
                if (xx > 0 && yy > 0) arr[i] = minOf(arr[i], arr[i - ew - 1] + 3)
                if (xx < ew - 1 && yy > 0) arr[i] = minOf(arr[i], arr[i - ew + 1] + 3)
            }
            for (yy in ew - 1 downTo 0) for (xx in ew - 1 downTo 0) {
                val i = yy * ew + xx
                if (xx < ew - 1) arr[i] = minOf(arr[i], arr[i + 1] + 2)
                if (yy < ew - 1) arr[i] = minOf(arr[i], arr[i + ew] + 2)
                if (xx < ew - 1 && yy < ew - 1) arr[i] = minOf(arr[i], arr[i + ew + 1] + 3)
                if (xx > 0 && yy < ew - 1) arr[i] = minOf(arr[i], arr[i + ew - 1] + 3)
            }
        }
        // the mouth of the cave: daylight and the forest come in from there
        val exits = ArrayList<DoubleArray>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) if (map.tile(tx, ty) == Tile.CAVE_EXIT) exits += doubleArrayOf((tx + 0.5) * S, (ty + 1.0) * S)
        // soft shadows under the things that stand on the floor
        val standing = setOf(Tile.STALAGMITE, Tile.CRATE, Tile.ROCK, Tile.CHEST, Tile.CAMPFIRE, Tile.BEDROLL, Tile.BONES, Tile.RUBBLE)
        val shadows = ArrayList<DoubleArray>()
        for (ty in cy * MapGround.CH - 1..(cy + 1) * MapGround.CH) for (tx in cx * MapGround.CH - 1..(cx + 1) * MapGround.CH) {
            if (map.tile(tx, ty) in standing) shadows += doubleArrayOf((tx + 0.58) * S, (ty + 0.8) * S, S * 0.5, S * 0.17)
        }

        val img = PixelImage(size, size)
        val col = DoubleArray(3)
        fun wallAt(xx: Int, yy: Int) = wall[(yy + m) * ew + xx + m]
        fun level(x: Double, y: Double) = floor((fbm(x, y, 150.0, 30) + (fbm(x, y, 30.0, 31) - 0.5) * 0.3) * 6)
        for (yy in 0 until size) for (xx in 0 until size) {
            val x = (ox + xx).toDouble(); val y = (oy + yy).toDouble()
            val i = (yy + m) * ew + xx + m
            val grain = rnd(ox + xx, oy + yy, 41)
            val n2 = fbm(x, y, 32.0, 2); val n3 = vnoise(x, y, 8.0, 3) * 0.6 + vnoise(x, y, 4.0, 43) * 0.4
            if (!wall[i]) {
                // ---- rock floor, painted grainy, in low uneven steps
                val n1 = fbm(x, y, 128.0, 1)
                val t0 = (n2 * 0.85 + n3 * 0.35 - 0.1).coerceIn(0.0, 1.0)
                for (k in 0..2) col[k] = FLOOR_D[k] + (FLOOR_L[k] - FLOOR_D[k]) * t0
                mixIn(col, FLOOR_M, ((n1 - 0.5) * 3).coerceIn(0.0, 1.0) * 0.55)
                var mul = (0.9 + 0.2 * vnoise(x, y, 3.0, 31)) * (0.94 + 0.12 * grain)
                val sp = rnd(ox + xx, oy + yy, 42)
                if (sp > 0.985) mul *= 1.35 else if (sp < 0.012) mul *= 0.6
                val lv = level(x, y)
                mul *= 0.88 + 0.04 * lv
                val step = level(x + 1.5, y + 1.5) - level(x - 1.5, y - 1.5)
                mul *= (1 - step * 0.16).coerceIn(0.75, 1.25)
                mul *= (1 + (vnoise(x - 1, y - 1, 12.0, 32) - vnoise(x + 1, y + 1, 12.0, 32)) * 1.8).coerceIn(0.8, 1.2)
                for (k in 0..2) col[k] *= mul
                // dust and trodden earth where there is room to walk, away from the rock
                val dw = dist[i] / 2.0
                val trod = ((dw - 22) / 30).coerceIn(0.0, 1.0) * (0.55 + 0.45 * fbm(x, y, 20.0, 33))
                if (trod > 0) { val dc = 0.88 + 0.24 * grain; for (k in 0..2) col[k] += (DUST[k] * dc - col[k]) * (trod * 0.6).coerceAtMost(0.55) }
                // damp: by the pool and under the crack of daylight, and in patches
                val pool = wide(map, x, y, waterTiles); val sky = wide(map, x, y, skyTiles)
                val wet = (((fbm(x, y, 56.0, 7) - 0.52) * 3.2).coerceIn(0.0, 1.0) * 0.7 + pool * 2.2 + sky * 1.6).coerceIn(0.0, 1.0)
                col[0] *= 1 - wet * 0.85 * 0.38; col[1] *= 1 - wet * 0.85 * 0.32; col[2] *= 1 - wet * 0.85 * 0.3
                val mossK = ((fbm(x, y, 18.0, 8) - 0.45) * 3).coerceIn(0.0, 1.0) * (pool * 2.4 + sky * 3.0).coerceIn(0.0, 1.0)
                if (mossK > 0) mixIn(col, MOSS_G, mossK * 0.75)
                // puddles: shallow, the stone showing at the rim, a sheen at the near edge
                fun puddle(px: Double, py: Double) = fbm(px, py, 44.0, 9) * 0.8 + vnoise(px, py, 12.0, 10) * 0.2 + wet * 0.28
                val pz = puddle(x, y)
                if (pz > 0.78 && dw > 10 && trod < 0.3) {
                    val depth = ((pz - 0.78) * 25).coerceIn(0.0, 1.0)
                    for (k in 0..2) col[k] = col[k] * 0.6 + (PUD[k] - col[k] * 0.6) * depth
                    if (puddle(x, y + 4) <= 0.78) mixIn(col, SHEEN, 0.5)
                } else if (pz > 0.75 && dw > 10 && trod < 0.3) for (k in 0..2) col[k] *= 0.72
                // near the mouth: dark earth and moss blown in from the forest
                var out = 0.0
                for (e in exits) out = maxOf(out, exp(-sqrt((x - e[0]) * (x - e[0]) + ((y - e[1]) * 0.8) * ((y - e[1]) * 0.8)) / (2.2 * S)))
                if (out > 0.01) {
                    mixIn(col, EARTH, (out * 1.4 * (0.6 + 0.6 * n2)).coerceAtMost(0.85))
                    val mo = ((fbm(x, y, 16.0, 34) - 0.48) * 4).coerceIn(0.0, 1.0) * (out * 1.6).coerceAtMost(1.0)
                    if (mo > 0) mixIn(col, MOSS_OUT, mo * 0.8)
                }
                // the pool: deep and black in a stone basin
                val wv = field(map, x, y, waterTiles) + (fbm(x, y, 48.0, 21) - 0.5) * 0.5
                if (wv > 0.5) {
                    val t1 = ((wv - 0.5) * 3).coerceIn(0.0, 1.0)
                    for (k in 0..2) col[k] = POOL_S[k] + (POOL_D[k] - POOL_S[k]) * t1
                    if (abs(sin(y * 0.3 + fbm(x, y, 30.0, 12) * 6)) > 0.995 && vnoise(x, y, 16.0, 13) > 0.7 && t1 < 0.6) mixIn(col, SHEEN, 0.2)
                } else if (wv > 0.36) mixIn(col, POOL_RIM, 0.65)
                // dark towards the rock, and under the things that stand
                for (k in 0..2) col[k] *= 0.5 + 0.5 * (dw / 26).coerceIn(0.0, 1.0)
                for (sh in shadows) {
                    val ux = (x - sh[0]) / sh[2]; val uy = (y - sh[1]) / sh[3]
                    val q = ux * ux + uy * uy
                    if (q < 1) { val a = 0.55 * (1 - q) * (1 - q); for (k in 0..2) col[k] *= 1 - a }
                }
            } else {
                val b = below[i]
                val faceH = FACE + (fbm(x, y, 20.0, 15) - 0.5) * 14
                if (b <= faceH) {
                    // ---- a rock face: layers, cracks, wet streaks, darkest where it meets the floor
                    val v = (b / FACE.toDouble()).coerceIn(0.0, 1.0)
                    val t0 = (v * 0.8 + n3 * 0.25).coerceIn(0.0, 1.0)
                    for (k in 0..2) col[k] = FACE_L[k] + (FACE_D[k] - FACE_L[k]) * t0
                    var mul = (0.9 + 0.2 * grain) * (1 + (vnoise(x - 1, y - 1, 16.0, 22) - vnoise(x + 1, y + 1, 16.0, 22)) * 2.2).coerceIn(0.7, 1.3)
                    val strata = sin(y * 0.55 + n2 * 9 + x * 0.04) * 0.5 + 0.5
                    if (strata > 0.84) mul *= 0.82 else if (strata > 0.62 && strata < 0.68) mul *= 1.12
                    if (abs(fbm(x, y, 14.0, 16) - 0.5) < 0.012) mul *= 0.55
                    for (k in 0..2) col[k] *= mul
                    if (vnoise(x, 0.0, 3.0, 17) > 0.86 && fbm(x, y, 30.0, 18) > 0.5) mixIn(col, STREAK, 0.5)
                    if (b <= 3) for (k in 0..2) col[k] *= 0.4
                } else {
                    // ---- the top of the rock mass: dark, lumpy, a pale lip where it breaks off
                    val lumps = fbm(x, y, 36.0, 19) * 0.75 + vnoise(x, y, 8.0, 20) * 0.25
                    val t0 = (n2 * 0.7 + n3 * 0.4).coerceIn(0.0, 1.0)
                    for (k in 0..2) col[k] = TOP_D[k] + (TOP_L[k] - TOP_D[k]) * t0
                    val bump = 1 + ((fbm(x - 1.5, y - 1.5, 36.0, 19) - fbm(x + 1.5, y + 1.5, 36.0, 19)) * 9).coerceIn(-0.45, 0.5)
                    val mul = (0.9 + 0.2 * grain) * (0.8 + 0.4 * lumps) * bump
                    for (k in 0..2) col[k] *= mul
                    val tf = toFloor[i] / 2.0
                    if (tf < 3.5) mixIn(col, LIP, 0.55)
                    else if (b <= faceH + 3) mixIn(col, EDGE, 0.5)
                }
            }
            img.pixels[yy * size + xx] = (0xFF shl 24) or (col[0].toInt().coerceIn(0, 255) shl 16) or (col[1].toInt().coerceIn(0, 255) shl 8) or col[2].toInt().coerceIn(0, 255)
        }
        // long cracks, grit, old leaves near the mouth and roots down the faces: from every tile near the chunk,
        // so they cross its edges
        fun plot(px: Int, py: Int, c: Int, a: Double = 1.0) {
            if (px !in 0 until size || py !in 0 until size || wallAt(px, py)) return
            val o = img.pixels[py * size + px]
            img.pixels[py * size + px] = if (a >= 1.0) c else mix(o, c, a)
        }
        val crackC = argb(0x100E0C); val lipC = argb(0x82786A)
        for (ty in cy * MapGround.CH - 2..(cy + 1) * MapGround.CH + 1) for (tx in cx * MapGround.CH - 2..(cx + 1) * MapGround.CH + 1) {
            if (rockTiles(map.tile(tx, ty))) continue
            if (rnd(tx, ty, 50) < 0.45) {
                var x = (tx + rnd(tx, ty, 51)) * S - ox; var y = (ty + rnd(tx, ty, 52)) * S - oy
                var a = rnd(tx, ty, 53) * 2 * PI
                val n = 8 + hash(tx, ty, 54) % 14
                val thick = rnd(tx, ty, 55) < 0.4
                for (k in 0 until n) {
                    a += (rnd(tx, ty, 60 + k) - 0.5) * 0.9
                    val step = 6 + rnd(tx, ty, 80 + k) * 8
                    val sx = x; val sy = y
                    x += cos(a) * step; y += sin(a) * step
                    val st = maxOf(abs(x - sx), abs(y - sy)).toInt().coerceAtLeast(1)
                    for (q in 0..st) {
                        val px = (sx + (x - sx) * q / st).toInt(); val py = (sy + (y - sy) * q / st).toInt()
                        plot(px + 1, py + 1, lipC, 0.25)
                        plot(px, py, crackC, 0.8)
                        if (thick) plot(px + 1, py, crackC, 0.6)
                    }
                }
            }
            // grit: little stones with a shadow
            for (k in 0 until 22) {
                val px = ((tx + rnd(tx, ty, 100 + k)) * S - ox).toInt(); val py = ((ty + rnd(tx, ty, 130 + k)) * S - oy).toInt()
                val r = 1 + hash(tx, ty, 160 + k) % 3 / 2
                val c = (70 + hash(tx, ty, 190 + k) % 60)
                plot(px + 1, py + 1, argb(0x0A0908), 0.45)
                for (dy in 0 until r) for (dx in 0..r) plot(px + dx, py + dy, argb((c shl 16) or ((c - 6) shl 8) or (c - 12)))
            }
            // old leaves blown in at the mouth
            var near = 0.0
            for (e in exits) near = maxOf(near, exp(-sqrt(((tx + 0.5) * S - e[0]).let { it * it } + ((ty + 0.5) * S - e[1]).let { it * it }) / (2.2 * S)))
            if (near > 0.1) for (k in 0 until (near * 40).toInt()) {
                val px = ((tx + rnd(tx, ty, 220 + k)) * S - ox).toInt(); val py = ((ty + rnd(tx, ty, 260 + k)) * S - oy).toInt()
                val c = argb(listOf(0x6A4A26, 0x8A5A2A, 0x4A3A22, 0x786434)[k % 4])
                val dx = if (rnd(tx, ty, 300 + k) < 0.5) 1 else 0
                plot(px, py, c); plot(px + 1, py + dx, c); plot(px + 2, py + dx, c)
            }
        }
        // roots hanging down the faces near the mouth (on the rock, so drawn without the floor test)
        for ((ex, ey) in exits.map { it[0] to it[1] }) for (k in 0 until 60) {
            val rx = (ex + (rnd(k, 1, 310) - 0.5) * 6 * S).toInt() - ox; val ry0 = (ey - (1 + rnd(k, 2, 310) * 3) * S).toInt() - oy
            var x = rx.toDouble(); var y = ry0.toDouble()
            // start at the top of a face
            var tries = 0
            while (tries < 120 && !(y.toInt() in 0 until size && x.toInt() in 0 until size && wallAt(x.toInt(), y.toInt()) && below[(y.toInt() + m) * ew + x.toInt() + m] in (FACE - 14)..FACE)) { y += 1; tries++ }
            if (tries >= 120) continue
            val len = 16 + rnd(k, 3, 310) * 40
            for (q in 0 until len.toInt()) {
                val px = (x + sin(q * 0.25 + k) * 2.5).toInt(); val py = (y + q).toInt()
                if (px !in 0 until size || py !in 0 until size) break
                img.pixels[py * size + px] = argb(0x2C2218)
                if (px - 1 >= 0) img.pixels[py * size + px - 1] = mix(img.pixels[py * size + px - 1], argb(0x54442E), 0.7)
            }
        }
        return img
    }
}
