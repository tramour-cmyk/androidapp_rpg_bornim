package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.art.HeroArt
import de.bornim.core.art.Mat
import de.bornim.core.art.Pal
import de.bornim.core.art.PixelImage
import de.bornim.core.art.Pose
import de.bornim.core.art.Ramp
import de.bornim.core.art.Sculpt
import de.bornim.core.art.argb
import de.bornim.core.art.mix
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Prototype of a more mature battle look (not part of the game yet): a forest scene with depth
 * instead of platforms, and a wolf redrawn at a higher resolution with several poses.
 */
object BattleProto {
    const val W = 270
    const val H = 370
    const val HORIZON = 148

    enum class Light { DAY, DUSK }

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    /** Smooth value noise for organic shapes. */
    private fun vnoise(x: Double, s: Int): Double {
        val i = kotlin.math.floor(x).toInt(); val f = x - i
        val u = f * f * (3 - 2 * f)
        return rnd(i, 0, s) * (1 - u) + rnd(i + 1, 0, s) * u
    }

    private val bayer = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)
    private fun dith(x: Int, y: Int) = bayer[(y and 3) * 4 + (x and 3)] / 16.0

    /** Picks from a ramp by brightness 0..1 with ordered dithering. */
    private fun shade(r: Ramp, t: Double, x: Int, y: Int): Int {
        val steps = r.size - 1
        return r[kotlin.math.floor(t * steps + dith(x, y) * 0.9 - 0.45 + 0.5).toInt().coerceIn(0, steps)]
    }

    fun scene(light: Light): PixelImage {
        val img = PixelImage(W, H)
        fun set(x: Int, y: Int, c: Int) = img.set(x, y, c)
        fun blend(x: Int, y: Int, c: Int, a: Double) { if (x in 0 until W && y in 0 until H) img.set(x, y, mix(img[x, y], c, a.coerceIn(0.0, 1.0))) }
        val dusk = light == Light.DUSK
        // ---------------------------------------------------------------- sky
        val skyTop = if (dusk) argb(0x2A2A52) else argb(0x4A7CBC)
        val skyMid = if (dusk) argb(0x9A5A72) else argb(0x9CC0DE)
        val skyLow = if (dusk) argb(0xF4AE6A) else argb(0xE8EAD8)
        for (y in 0 until HORIZON) for (x in 0 until W) {
            val t = y / HORIZON.toDouble() + (dith(x, y) - 0.5) * 0.04
            set(x, y, if (t < 0.55) mix(skyTop, skyMid, t / 0.55) else mix(skyMid, skyLow, (t - 0.55) / 0.45))
        }
        val sunX = if (dusk) 96.0 else 70.0; val sunY = if (dusk) 104.0 else 52.0
        for (y in 0 until HORIZON) for (x in 0 until W) {
            val d = sqrt((x - sunX).pow(2) + ((y - sunY) * 1.3).pow(2))
            blend(x, y, if (dusk) argb(0xFFD49A) else argb(0xFFF8E4), exp(-d / (if (dusk) 42.0 else 34.0)) * (if (dusk) 0.8 else 0.55))
            if (dusk && d < 8) set(x, y, argb(0xFFEAC0))
        }
        // soft cumulus clouds: overlapping puffs, lit from the sun side
        val cloudLit = if (dusk) argb(0xFFC89A) else argb(0xFFFFFF)
        val cloudShade = if (dusk) argb(0x7A5070) else argb(0xB8C6DA)
        for ((cx, cy, size) in listOf(Triple(175.0, 40.0, 1.0), Triple(236.0, 70.0, 0.7), Triple(118.0, 78.0, 0.55))) {
            for (k in 0 until 7) {
                val px = cx + (k - 3) * 9 * size + (rnd(k, 1, cy.toInt()) - 0.5) * 6
                val py = cy - sin(k / 6.0 * PI) * 7 * size
                val r = (7 + 5 * sin(k / 6.0 * PI)) * size
                for (y in (py - r).toInt()..(py + r * 0.7).toInt()) for (x in (px - r).toInt()..(px + r).toInt()) {
                    val q = ((x - px) / r).pow(2) + ((y - py) / r).pow(2)
                    if (q > 1 || y !in 0 until HORIZON || x !in 0 until W) continue
                    val l = 0.5 - (y - py) / r * 0.5 + (if (dusk) -(x - px) else (sunX - px).coerceIn(-1.0, 1.0)) / r * 0.1
                    val c = mix(cloudShade, cloudLit, (l + dith(x, y) * 0.25).coerceIn(0.0, 1.0))
                    set(x, y, mix(img[x, y], c, if (q > 0.85) 0.5 else 0.95))
                }
                // flat cloud base
            }
        }
        // ---------------------------------------------------------------- distant mountains in the haze
        val haze = if (dusk) argb(0xB07080) else argb(0xB2C4D6)
        val mtn = if (dusk) argb(0x6A4A6A) else argb(0x7A92AE)
        for (x in 0 until W) {
            val top = 98 + 16 * vnoise(x / 30.0, 5) + 6 * vnoise(x / 9.0, 6) - 14 * exp(-((x - 200) / 22.0).pow(2))
            for (y in top.toInt() until HORIZON) set(x, y, mix(mtn, haze, ((y - top) / 34.0).coerceIn(0.0, 1.0) * 0.8))
            set(x, top.toInt(), mix(mtn, if (dusk) argb(0xF4A878) else argb(0xD8E4F0), 0.55))
        }
        // ---------------------------------------------------------------- forest edge: three rows of trees getting darker and bigger
        fun pine(cx: Double, baseY: Double, h: Double, col: Int, lit: Int, dark: Int) {
            val tiers = 4
            for (t in 0 until tiers) {
                val top = baseY - h + t * h * 0.2
                val bot = top + h * 0.38
                for (y in top.toInt()..bot.toInt()) {
                    val u = (y - top) / (bot - top)
                    val half = (1 + t * 0.5) * h * 0.13 * u + 0.5
                    for (x in (cx - half).toInt()..(cx + half).toInt()) {
                        if (x !in 0 until W || y !in 0 until H) continue
                        val side = (x - cx) / half
                        val c = when {
                            u > 0.85 && rnd(x, y, 5) < 0.5 -> dark
                            side < -0.35 -> lit
                            side > 0.45 -> dark
                            else -> col
                        }
                        set(x, y, c)
                    }
                }
            }
        }
        fun broadleaf(cx: Double, baseY: Double, r: Double, col: Int, lit: Int, dark: Int, seed: Int) {
            for (k in 0 until 9) {
                val px = cx + (rnd(k, 1, seed) - 0.5) * r * 1.3
                val py = baseY - r * 1.1 - rnd(k, 2, seed) * r * 0.9
                val rr = r * (0.45 + rnd(k, 3, seed) * 0.3)
                for (y in (py - rr).toInt()..(py + rr).toInt()) for (x in (px - rr).toInt()..(px + rr).toInt()) {
                    val dx = (x - px) / rr; val dy = (y - py) / rr
                    if (dx * dx + dy * dy > 1 || x !in 0 until W || y !in 0 until H) continue
                    val l = 0.55 - (dx * 0.6 + dy * 0.8) * 0.45 + (rnd(x / 2, y / 2, seed) - 0.5) * 0.35
                    set(x, y, if (l > 0.72) lit else if (l < 0.32) dark else col)
                }
            }
        }
        val rows = if (dusk) listOf(
            Triple(argb(0x4A3C5A), argb(0x6A4E62), argb(0x382E48)),
            Triple(argb(0x2E2A3C), argb(0x52404E), argb(0x201C2C)),
        ) else listOf(
            Triple(argb(0x5E8278), argb(0x7A9E8A), argb(0x4A6A66)),
            Triple(argb(0x37604A), argb(0x5A8458), argb(0x284638)),
        )
        // dark undergrowth along the forest floor, so no sky shows between the trunks
        for (x in 0 until W) {
            val top = HORIZON - 10 + 5 * vnoise(x / 6.0, 44)
            for (y in top.toInt()..HORIZON + 5) set(x, y, mix(rows[1].third, rows[0].first, ((HORIZON + 5 - y) / 16.0).coerceIn(0.0, 0.5)))
        }
        for ((ri, row) in rows.withIndex()) {
            var x = -10.0
            var k = 0
            while (x < W + 10) {
                val h = (if (ri == 0) 22.0 else 34.0) * (0.75 + rnd(k, ri, 40) * 0.5)
                val baseY = HORIZON + (if (ri == 0) -2.0 else 4.0)
                if (rnd(k, ri, 41) < 0.35) broadleaf(x, baseY, h * 0.42, row.first, row.second, row.third, k * 7 + ri)
                else pine(x, baseY, h, row.first, row.second, row.third)
                x += (if (ri == 0) 6.0 else 9.0) + rnd(k, ri, 42) * 5
                k++
            }
        }
        // ---------------------------------------------------------------- ground: grass in perspective
        val grassFar = if (dusk) argb(0x6E6A50) else argb(0x92AE6C)
        val grassMid = if (dusk) argb(0x4E5636) else argb(0x5E8C40)
        val grassNear = if (dusk) argb(0x232C1A) else argb(0x2A4C22)
        for (y in HORIZON + 4 until H) {
            val d = (y - HORIZON) / (H - HORIZON).toDouble()
            for (x in 0 until W) {
                var c = if (d < 0.45) mix(grassFar, grassMid, d / 0.45) else mix(grassMid, grassNear, (d - 0.45) / 0.55)
                // large soft patches of darker and lighter grass
                val patch = vnoise(x / (18.0 + d * 30), (y / (4.0 + d * 10)).toInt() + 70)
                c = mix(c, if (patch > 0.5) mix(c, Pal.WHITE, 0.15) else mix(c, Pal.BLACK, 0.2), abs(patch - 0.5) * 1.2)
                // fine blades: vertical streaks that get longer up close
                val streak = rnd(x, (y / (1 + d * 4)).toInt(), 7)
                if (streak < 0.14) c = mix(c, Pal.BLACK, 0.22) else if (streak > 0.9) c = mix(c, if (dusk) argb(0xC8A878) else argb(0xD0E890), 0.3)
                set(x, y, c)
            }
        }
        // shadow of the forest edge on the grass
        for (y in HORIZON until HORIZON + 14) for (x in 0 until W) blend(x, y, argb(0x0C1810), 0.4 * (1 - (y - HORIZON) / 14.0))
        // warm light pool where the foe stands
        for (y in HORIZON until H) for (x in 0 until W) {
            val d = ((x - 172) / 105.0).pow(2) + ((y - 218) / 40.0).pow(2)
            blend(x, y, if (dusk) argb(0xF4A462) else argb(0xF6F0A8), exp(-d) * (if (dusk) 0.34 else 0.2))
        }
        // dirt path, winding towards the hero
        for (y in HORIZON + 4 until H) {
            val d = (y - HORIZON) / (H - HORIZON).toDouble()
            val cx = 160 - d * 66 + 9 * sin(d * 5.0)
            val half = 2.5 + d * d * 42 + 3 * vnoise(y / 6.0, 9)
            for (x in (cx - half - 2).toInt()..(cx + half + 2).toInt()) {
                if (x !in 0 until W) continue
                val e = 1 - abs(x - cx) / half
                if (e < -0.05) continue
                var c = mix(if (dusk) argb(0x8C6C56) else argb(0xBCA27C), if (dusk) argb(0x4A382E) else argb(0x846A4C), d * 0.85)
                val n = rnd(x, (y / (1 + d * 2)).toInt(), 13)
                if (n < 0.1) c = mix(c, Pal.BLACK, 0.25) else if (n > 0.93) c = mix(c, Pal.WHITE, 0.2)
                // wheel ruts
                if (d > 0.3 && abs(abs(x - cx) - half * 0.45) < 0.6 + d) c = mix(c, Pal.BLACK, 0.15)
                blend(x, y, c, if (e < 0.08) 0.55 else 1.0)
            }
        }
        // stones and grass tufts, larger up close
        for (i in 0 until 220) {
            val y = HORIZON + 8 + ((H - HORIZON - 10) * rnd(i, 1, 30).pow(0.75)).toInt()
            val x = (W * rnd(i, 2, 30)).toInt()
            val d = (y - HORIZON) / (H - HORIZON).toDouble()
            val size = 1 + d * 5
            if (i % 11 == 0) {
                val r = size * 0.9
                for (yy in -r.toInt()..0) for (xx in (-r * 1.4).toInt()..(r * 1.4).toInt()) {
                    if ((xx / (r * 1.4)).pow(2) + (yy / r).pow(2) > 1) continue
                    set(x + xx, y + yy, if (yy < -r * 0.5 && xx < 0) argb(0xC4C0B2) else if (yy > -1) argb(0x4E4A44) else argb(0x8A867C))
                }
            } else {
                val col = mix(if (dusk) argb(0x3A4828) else argb(0x3A6A2A), grassNear, d * 0.5)
                val hi = if (dusk) argb(0x9A9058) else argb(0xB2D468)
                for (b in -3..3) {
                    val len = size * (1.3 + rnd(i, b, 31) * 1.2)
                    val lean = b * 0.3 + (rnd(i, 9, 32) - 0.5)
                    for (k in 0 until len.toInt()) {
                        set(x + b + (k * lean * 0.3).toInt(), y - k, if (k > len * 0.55 && b < 0) hi else col)
                    }
                }
            }
        }
        // ---------------------------------------------------------------- framing trunks with round shading and bark
        fun trunk(cx: Double, r: Double, seed: Int) {
            val bark = Ramp.of(if (dusk) argb(0x463632) else argb(0x5E4636))
            for (y in 0 until H - 6) {
                val flare = if (y > H - 40) (y - (H - 40)) * 0.35 else 0.0
                val rr = r + flare
                for (x in (cx - rr).toInt()..(cx + rr).toInt()) {
                    if (x !in 0 until W) continue
                    val u = (x - cx) / rr
                    val nz = sqrt((1 - u * u).coerceAtLeast(0.0))
                    var l = 0.2 + 0.65 * (nz * 0.7 - u * 0.5).coerceAtLeast(0.0)
                    // vertical bark furrows
                    val furrow = vnoise(x * 0.9 + vnoise(y / 14.0, seed) * 3, seed + 3)
                    if (furrow < 0.3) l -= 0.25
                    if (rnd(x, y / 2, seed) < 0.08) l += 0.15
                    // moss on the shaded side low down
                    val moss = u > 0.2 && y > H - 120 && rnd(x / 2, y / 3, seed + 5) < 0.45
                    set(x, y, if (moss) mix(shade(bark, l.coerceIn(0.0, 1.0), x, y), if (dusk) argb(0x3A4A2A) else argb(0x5A7A30), 0.6) else shade(bark, l.coerceIn(0.0, 1.0), x, y))
                }
            }
        }
        trunk(4.0, 13.0, 41)
        trunk(W - 3.0, 14.0, 42)
        // canopy overhang: many small leaf clusters
        val leafR = Ramp.of(if (dusk) argb(0x34442E) else argb(0x3A6A34))
        for (i in 0 until 420) {
            val left = i % 2 == 0
            val spread = rnd(i, 1, 50)
            val cx = if (left) spread * 105 - 6 else W + 6 - spread * 105
            val cy = (rnd(i, 2, 50).pow(1.6)) * (52 - spread * 30) - 6 + spread * 4
            val r = 2.0 + rnd(i, 3, 50) * 3.0
            for (y in (cy - r).toInt()..(cy + r).toInt()) for (x in (cx - r).toInt()..(cx + r).toInt()) {
                val dx = (x - cx) / r; val dy = (y - cy) / r
                if (dx * dx + dy * dy > 1 || x !in 0 until W || y !in 0 until H) continue
                val depth = 1 - cy / 60.0
                val l = (0.62 - (dx + dy) * 0.3) * (0.6 + depth * 0.4)
                set(x, y, shade(leafR, l.coerceIn(0.0, 1.0), x, y))
            }
        }
        // ---------------------------------------------------------------- light shafts through the trees
        for (y in 0 until H) for (x in 0 until W) {
            val sv = x * 0.5 - y * 0.8 + 40
            val band = (sin(sv / 10.0) * 0.5 + 0.5).pow(8) * (sin(sv / 27.0 + 2) * 0.5 + 0.5)
            blend(x, y, if (dusk) argb(0xFFC488) else argb(0xFFFCE4), band * (1 - y / H.toDouble()) * (if (dusk) 0.2 else 0.15))
        }
        // dust motes in the light
        for (i in 0 until 40) {
            val x = (rnd(i, 1, 90) * W).toInt(); val y = (40 + rnd(i, 2, 90) * 200).toInt()
            blend(x, y, if (dusk) argb(0xFFE0B0) else argb(0xFFFFF0), 0.7)
        }
        // ---------------------------------------------------------------- foreground ferns at the bottom corners
        val fern = if (dusk) argb(0x121810) else argb(0x1A3016)
        val fernLit = if (dusk) argb(0x2C3820) else argb(0x3A5C28)
        for ((bx, side) in listOf(14.0 to 1, 34.0 to 1, W - 16.0 to -1, W - 40.0 to -1, W - 70.0 to -1)) {
            for (f in 0 until 6) {
                val ang = -PI / 2 + side * (f - 1.5) * 0.32
                val len = 30.0 + rnd(bx.toInt(), f, 62) * 26
                for (k in 0 until len.toInt()) {
                    val t = k / len
                    val px = bx + cos(ang) * k + side * t * t * 12
                    val py = H + 6 + sin(ang) * k + t * t * 18
                    val lw = (1 - t) * 6 + 1
                    for (sgn in listOf(-1, 1)) for (q in 0 until lw.toInt()) {
                        if ((k + q) % 3 == 2) continue
                        set((px + sgn * q).toInt(), (py + q * 0.7).toInt(), if (sgn < 0) fernLit else fern)
                    }
                }
            }
        }
        // ---------------------------------------------------------------- vignette
        for (y in 0 until H) for (x in 0 until W) {
            val dx = (x - W / 2.0) / (W / 2.0); val dy = (y - H * 0.55) / (H * 0.62)
            val v = ((dx * dx + dy * dy) - 0.5).coerceAtLeast(0.0) * 0.5
            if (v > 0) blend(x, y, if (dusk) argb(0x100818) else argb(0x08120A), v.coerceAtMost(0.55))
        }
        return img
    }

    // ==================================================================== the wolf at 96 × 72

    enum class WolfPose { IDLE_A, IDLE_B, CROUCH, LEAP, BITE, HURT, DOWN }

    fun wolf(pose: WolfPose): PixelImage {
        if (pose == WolfPose.DOWN) return wolfDown()
        val s = Sculpt(96, 72, 7)
        val fur = Mat(Ramp.of(argb(0x8A8278)), grain = 0.05)
        val furSoft = fur.copy(inline = false)
        val farFur = fur.copy(bias = -0.25)
        val paw = Mat(Ramp.of(argb(0x4A423E)), grain = 0.05)
        val dark = argb(0x1A1416)
        val breath = if (pose == WolfPose.IDLE_B) 0.8 else 0.0
        var bodyY = 0.0; var bodyX = 0.0; var headDx = 0.0; var headDy = 0.0; var mouth = 0.3; var tilt = 0.0
        when (pose) {
            WolfPose.IDLE_A, WolfPose.IDLE_B -> { headDy = breath * 0.5 }
            WolfPose.CROUCH -> { bodyY = 4.0; headDy = 6.0; headDx = 1.0; mouth = 0.7 }
            WolfPose.LEAP -> { bodyY = -9.0; bodyX = -8.0; headDy = -3.0; headDx = -3.0; mouth = 1.3; tilt = -0.16 }
            WolfPose.BITE -> { bodyX = -5.0; headDx = -6.0; headDy = 4.0; mouth = 1.4 }
            WolfPose.HURT -> { bodyX = 4.0; headDx = 6.0; headDy = -5.0; mouth = 0.9 }
            WolfPose.DOWN -> {}
        }
        fun bx(x: Double) = x + bodyX
        fun by(x: Double, y: Double) = y + bodyY + (x - 48) * tilt
        val bend = if (pose == WolfPose.CROUCH) 4.0 else 0.0
        val leap = pose == WolfPose.LEAP

        /** Front leg: shoulder muscle, slightly forward forearm, wrist, paw. */
        fun frontLeg(m: Mat, x: Double, reach: Double) {
            val lower = m.copy(inline = false)
            if (leap) {
                s.limb(bx(x), by(x, 44.0), bx(x - 10), by(x - 10, 51.0), 3.8, 2.0, m)
                s.limb(bx(x - 10), by(x - 10, 51.0), bx(x - 19), by(x - 19, 55.0), 1.9, 1.4, lower)
                s.blob(bx(x - 20), by(x - 20, 55.6), 2.2, 1.3, paw)
                return
            }
            val ex = x + 1.2 + reach * 0.3; val ey = 53.0 - bend
            val wx = x - 0.8 + reach * 0.8; val wy = 63.0 - bend * 0.3
            s.limb(bx(x), by(x, 42.0), bx(ex), by(ex, ey), 4.2, 2.1, m)
            s.limb(bx(ex), by(ex, ey), bx(wx), wy, 2.0, 1.5, lower)
            s.limb(bx(wx), wy, bx(wx - 1.2), 67.0, 1.5, 1.6, lower)
            s.blob(bx(wx - 2.2), 68.4, 2.6, 1.3, paw)
        }
        /** Hind leg: big thigh, knee forward, shank back to the hock, then down to the paw. */
        fun hindLeg(m: Mat, x: Double) {
            val lower = m.copy(inline = false)
            if (leap) {
                s.limb(bx(x), by(x, 40.0), bx(x + 9), by(x + 9, 50.0), 6.4, 2.6, m)
                s.limb(bx(x + 9), by(x + 9, 50.0), bx(x + 19), by(x + 19, 55.0), 2.0, 1.4, lower)
                s.blob(bx(x + 20), by(x + 20, 55.5), 2.2, 1.3, paw)
                return
            }
            val kx = x - 1.0; val ky = 50.0 - bend
            val hx = x + 6.0; val hy = 58.5 - bend * 0.6
            s.limb(bx(x + 1), by(x, 38.0), bx(kx), by(kx, ky), 7.2, 3.0, m) // thigh
            s.limb(bx(kx), by(kx, ky), bx(hx), by(hx, hy), 2.8, 1.6, lower) // shank back to the hock
            s.limb(bx(hx), by(hx, hy), bx(hx - 1.5), 67.0, 1.6, 1.5, lower)
            s.blob(bx(hx - 2.6), 68.4, 2.6, 1.3, paw)
        }
        // ---- far side
        frontLeg(farFur, 33.0, 0.0)
        hindLeg(farFur, 69.0)
        // ---- tail: low and bushy
        val sw = if (pose == WolfPose.IDLE_B) 1.4 else 0.0
        s.chain(fur, bx(78.0), by(78.0, 35.0), 3.4, bx(85.0), by(85.0, 39.0), 4.6, bx(89.0 + sw), by(89.0, 47.0), 4.4, bx(89.0 + sw * 1.6), by(89.0, 55.0), 3.0, bx(88.0 + sw * 2), by(88.0, 60.0), 1.4)
        // ---- body
        s.blob(bx(70.0), by(70.0, 39.5), 10.5, 9.5, fur)
        s.blob(bx(54.0), by(54.0, 38.5 - breath * 0.3), 19.0, 8.2, fur)
        s.blob(bx(39.0), by(39.0, 40.0 - breath * 0.5), 11.5, 11.5 + breath * 0.4, fur)
        // ---- neck ruff and head
        val hx = 18.0 + headDx + bodyX; val hy = 33.0 + headDy + bodyY
        s.blob(bx(29.0), by(29.0, 35.0), 9.0, 11.0, fur, rot = 0.4)
        for (i in 0..7) {
            val a = -2.4 + i * 0.36
            val rx = bx(29.0) + cos(a) * 8.5; val ry = by(29.0, 35.0) + sin(a) * 10.5
            s.poly(fur, rx - 1.4, ry, rx + cos(a) * 3.0, ry + sin(a) * 3.0, rx + 1.4, ry + 0.6, bevel = 0.8)
        }
        s.poly(fur.copy(bias = -0.2), hx + 2.5, hy - 5.0, hx + 3.5, hy - 14.0, hx + 7.5, hy - 5.5, bevel = 1.0)
        s.blob(hx + 2.5, hy - 1.0, 7.6, 6.6, fur)
        // cheek fur
        s.poly(fur, hx + 5.0, hy + 1.0, hx + 9.5, hy + 6.0, hx + 3.5, hy + 4.5, bevel = 0.8)
        s.poly(fur, hx + 5.5, hy - 5.5, hx + 9.5, hy - 15.0, hx + 11.0, hy - 4.5, tiltX = -0.3, bevel = 1.2)
        s.poly(Mat(Ramp.of(argb(0x5A403C)), inline = false), hx + 7.2, hy - 6.0, hx + 9.2, hy - 12.5, hx + 9.8, hy - 5.5, bevel = 0.5)
        val open = mouth * 2.0
        s.limb(hx - 2.0, hy + 3.0 + open * 0.5, hx - 11.5, hy + 5.5 + open, 2.4, 1.4, fur.copy(bias = -0.12))
        if (mouth > 0.6) {
            s.flat(hx - 7.0, hy + 4.2 + open * 0.5, 4.6, 1.0 + open * 0.35, argb(0x4A141A))
            s.dot(hx - 11.0, hy + 3.4, Pal.WHITE); s.dot(hx - 11.0, hy + 4.2, Pal.WHITE) // upper fang
            s.dot(hx - 10.0, hy + 4.6 + open, argb(0xE8E0D0)); s.dot(hx - 10.0, hy + 3.8 + open, argb(0xE8E0D0)) // lower fang
            for (i in 0..2) s.dot(hx - 8.5 + i * 1.6, hy + 3.4, argb(0xE8E0D0))
        }
        s.limb(hx + 1.0, hy + 0.5, hx - 12.0, hy + 2.6, 4.0, 2.2, fur)
        s.blob(hx - 13.0, hy + 2.2, 1.7, 1.5, Mat(Ramp.of(argb(0x1C1818)), shine = 1.0))
        if (pose == WolfPose.HURT) {
            s.line(hx - 1.6, hy - 1.6, hx + 1.4, hy - 0.8, dark)
        } else {
            s.flat(hx - 0.3, hy - 1.2, 1.9, 1.1, argb(0x1E1410))
            s.flat(hx - 0.5, hy - 1.2, 1.2, 0.8, argb(0xF2B830))
            s.dot(hx - 0.3, hy - 1.2, dark)
            s.line(hx - 2.8, hy - 3.0, hx + 2.0, hy - 2.0, dark)
        }
        // ---- near legs
        frontLeg(fur, 38.0, if (pose == WolfPose.BITE) -5.0 else 0.0)
        hindLeg(fur, 66.0)
        // ---- coat markings, painted over the shading: dark saddle on the back, pale underside, mask
        s.transform()
        s.tint(bx(56.0), by(56.0, 31.0), 22.0, 6.0, argb(0x2A2422), 0.55)
        s.tint(bx(38.0), by(38.0, 30.5), 9.0, 6.0, argb(0x2A2422), 0.45)
        s.tint(bx(78.0), by(78.0, 33.0), 6.0, 4.0, argb(0x2A2422), 0.4)
        s.tint(bx(54.0), by(54.0, 46.5), 15.0, 3.5, argb(0xE6DCC6), 0.4)
        s.tint(bx(35.0), by(35.0, 47.0), 6.0, 6.0, argb(0xE6DCC6), 0.45)
        s.tint(hx - 7.0, hy + 4.0, 5.0, 2.0, argb(0xE6DCC6), 0.5)
        s.tint(hx + 4.0, hy - 3.5, 5.0, 2.5, argb(0x2A2422), 0.35)
        s.tint(bx(89.0 + sw * 2), by(89.0, 58.0), 3.0, 3.5, argb(0x1A1414), 0.6)
        // fur strands: short diagonal strokes, darker in the shadow, lighter on top
        val src = s.img.copy()
        for (y in 1 until 71) for (x in 1 until 95) {
            if (!src.opaque(x, y) || !src.opaque(x + 2, y + 2) || !src.opaque(x - 1, y - 1)) continue
            val n = rnd(x / 2, y / 3, 77)
            if (n < 0.10) {
                s.img.set(x, y, mix(src[x, y], argb(0x18141C), 0.35))
                s.img.set(x + 1, y + 1, mix(src[x + 1, y + 1], argb(0x18141C), 0.25))
            } else if (n > 0.94) s.img.set(x, y, mix(src[x, y], argb(0xF4EAD8), 0.25))
        }
        s.rim(if (pose == WolfPose.HURT) argb(0xFFB0A0) else argb(0xFFE0A8), 0.45)
        s.outline(argb(0x140E14))
        return s.img
    }

    /** Defeated: lying on its side. */
    private fun wolfDown(): PixelImage {
        val s = Sculpt(96, 72, 9)
        val fur = Mat(Ramp.of(argb(0x7E766C)), grain = 0.2, bias = -0.1)
        val pale = Mat(Ramp.of(argb(0xC4B8A2)), grain = 0.14, inline = false, bias = -0.1)
        s.chain(fur, 74.0, 58.0, 4.0, 86.0, 62.0, 4.4, 92.0, 66.0, 2.4)
        s.blob(52.0, 59.0, 26.0, 9.0, fur)
        s.blob(50.0, 64.0, 18.0, 3.6, pale)
        s.limb(40.0, 64.0, 26.0, 68.0, 3.0, 2.0, fur)
        s.limb(66.0, 64.0, 80.0, 68.0, 4.0, 2.2, fur)
        s.blob(24.0, 60.0, 9.0, 6.0, fur)
        s.limb(20.0, 61.0, 9.0, 64.0, 3.8, 2.2, fur)
        s.blob(11.0, 64.5, 4.0, 1.2, pale)
        s.line(19.0, 58.5, 22.0, 59.0, argb(0x1A1416))
        s.transform(); s.outline(argb(0x140E14))
        return s.img
    }

    // ==================================================================== composition and output

    /** Multiplies a color with a light tint (dusk makes sprites warmer and darker). */
    fun lit(c: Int, tint: Int?): Int {
        if (tint == null) return c
        fun ch(v: Int, s: Int) = ((v shr s) and 0xFF)
        val r = ch(c, 16) * ch(tint, 16) / 255; val g = ch(c, 8) * ch(tint, 8) / 255; val b = ch(c, 0) * ch(tint, 0) / 255
        return (c and (0xFF shl 24)) or (r shl 16) or (g shl 8) or b
    }

    private fun blit(dst: PixelImage, src: PixelImage, ox: Int, oy: Int, scale: Int = 1, tint: Int? = null) {
        for (y in 0 until src.height * scale) for (x in 0 until src.width * scale) {
            val c = src[x / scale, y / scale]
            if ((c ushr 24) < 128) continue
            dst.set(ox + x, oy + y, lit(c, tint))
        }
    }

    fun tintFor(light: Light): Int? = if (light == Light.DUSK) argb(0xE8B4A8) else null

    private fun shadow(dst: PixelImage, cx: Double, cy: Double, rx: Double, ry: Double, a: Double) {
        for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
            val q = ((x - cx) / rx).pow(2) + ((y - cy) / ry).pow(2)
            if (q > 1) continue
            dst.set(x, y, mix(dst[x, y], argb(0x10141A), a * (1 - q * 0.6)))
        }
    }

    /** The full scene: backdrop, wolf in the middle ground and the hero (from behind) in front. */
    fun compose(light: Light, pose: WolfPose = WolfPose.IDLE_A): PixelImage {
        val img = scene(light)
        val wolf = wolf(pose)
        // the wolf stands in the light pool
        shadow(img, 170.0, 222.0, 34.0, 5.0, 0.5)
        blit(img, wolf, 122, 222 - 70, tint = tintFor(light))
        return img
    }

    /** Writes [img] scaled up, then draws the hero on top at its own scale. */
    fun write(name: String, img: PixelImage, scale: Int, hero: PixelImage? = null, heroScale: Int = 7, tint: Int? = null) {
        val out = BufferedImage(img.width * scale, img.height * scale, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until out.height) for (x in 0 until out.width) out.setRGB(x, y, img[x / scale, y / scale])
        if (hero != null) {
            // hero shadow, then the sprite, feet near the bottom left like today
            val hx = 300; val hy = out.height - 40
            for (y in -16..16) for (x in -150..150) {
                val q = (x / 150.0).pow(2) + (y / 16.0).pow(2)
                if (q > 1) continue
                val px = hx + x; val py = hy + y
                if (px !in 0 until out.width || py !in 0 until out.height) continue
                out.setRGB(px, py, mix(out.getRGB(px, py), argb(0x10141A), 0.5 * (1 - q * 0.6)))
            }
            val ox = hx - hero.width * heroScale / 2; val oy = hy - hero.height * heroScale + 10
            for (y in 0 until hero.height * heroScale) for (x in 0 until hero.width * heroScale) {
                val c = hero[x / heroScale, y / heroScale]
                if ((c ushr 24) < 128) continue
                val px = ox + x; val py = oy + y
                if (px in 0 until out.width && py in 0 until out.height) out.setRGB(px, py, lit(c, tint))
            }
        }
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/$name.png"))
    }

    fun run() {
        val hero = GameState.newGame("Borin", Race.DWARF, CharClass.FIGHTER).hero
        val heroImg = HeroArt.battle(hero, Pose.IDLE)
        write("proto_day", compose(Light.DAY), 4, heroImg)
        write("proto_dusk", compose(Light.DUSK), 4, heroImg, tint = tintFor(Light.DUSK))
        // pose sheet of the new wolf
        val poses = WolfPose.entries
        val sheet = PixelImage(96 * 4, 72 * 2)
        for ((i, p) in poses.withIndex()) {
            val bg = if ((i + i / 4) % 2 == 0) argb(0x5E7A52) else argb(0x56704C)
            for (y in 0 until 72) for (x in 0 until 96) sheet.set((i % 4) * 96 + x, (i / 4) * 72 + y, bg)
            blit(sheet, wolf(p), (i % 4) * 96, (i / 4) * 72)
        }
        write("proto_wolf_poses", sheet, 3)
        println("wrote prototype")
    }
}
