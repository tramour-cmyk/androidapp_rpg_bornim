package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Sex
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin

/**
 * 292.3, Entwurf A (Chef 15:12, 16:39): the main menu's four on black in a warm cone of light from above, with a warm
 * core in the middle and a glow on the ground at their feet; the outer two turned to the middle, spaced evenly, weapons
 * at rest, the dwarf smaller. In the title look: no dither, ink, no eye dots, no highlight; drawn twice as large and
 * taken down by half, so the edges are smooth. One picture, drawn once (about a second or two), then kept.
 */
object TitleScene {
    /** The picture's size at [scale] 1, in pixels. */
    const val W = 800
    const val H = 500
    private const val GROUND = 470.0
    private const val PX = 2.2
    private const val SLOT = 194.0
    private const val PITCH = 15.0
    private val YAWS = listOf(42.0, 14.0, -14.0, -42.0)
    private const val DWARF_CM = 150.0
    private val LIGHT = P3(0.0, 230.0, 300.0)

    @Volatile private var kept: PixelImage? = null

    /** The picture if it is drawn already. */
    fun ready(): PixelImage? = kept

    /** The four, as in the menu: one of each class, of different peoples and looks. */
    fun heroes(): List<Hero> {
        val races = listOf(Race.HUMAN, Race.ELF, Race.DWARF, Race.HALF_ORC)
        return CharClass.entries.mapIndexed { i, cls ->
            Hero.create("Held $i", races[i % races.size], cls).also {
                it.sex = if (i % 2 == 1) Sex.FEMALE else Sex.MALE; it.skin = (i * 3 + 1) % 4; it.hair = i % 4
            }
        }
    }

    /** Draws the picture (off the main thread) and keeps it; [scale] makes it larger or smaller. */
    fun render(scale: Double = 1.0): PixelImage {
        if (scale == 1.0) kept?.let { return it }
        val w = (W * scale).toInt(); val h = (H * scale).toInt()
        val ground = GROUND * scale; val px = PX * scale; val slot = SLOT * scale
        val out = PixelImage(w, h)
        // the light worked out per pixel, in fractions, so it runs without steps
        val warm = doubleArrayOf(0xE8 / 255.0, 0xB0 / 255.0, 0x70 / 255.0)
        for (y in 0 until h) for (x in 0 until w) {
            val u = (x - w / 2.0) / w; val t = (y + h * 0.15) / (h * 1.13)
            val half = 0.1 + 0.5 * t
            val side = (1 - abs(u) / half).coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
            val fall = (if (t < 0.35) t / 0.35 else if (t < 0.8) 1.0 else (1 - (t - 0.8) / 0.2)).coerceIn(0.0, 1.0)
            val cone = 0.20 * side * fall
            val cx = (x - w / 2.0) / (w * 0.42); val cy = (y - h * 0.45) / (h * 0.45)
            val core = 0.10 * exp(-2.5 * (cx * cx + cy * cy))
            val gx = (x - w / 2.0) / (w * 0.62); val gy = (y - ground) / (w * 0.62 * 0.14)
            val glow = 0.42 * exp(-2.2 * (gx * gx + gy * gy))
            // the edges of the picture black, so it sits in the black menu without a seam
            val edge = (minOf(x, w - 1 - x) / (w * 0.06)).coerceIn(0.0, 1.0) * (minOf(y, h - 1 - y) / (h * 0.06)).coerceIn(0.0, 1.0)
            val l = (cone + core + glow) * edge
            out.pixels[y * w + x] = argb(((255 * warm[0] * l).toInt().coerceIn(0, 255) shl 16) or ((255 * warm[1] * l).toInt().coerceIn(0, 255) shl 8) or (255 * warm[2] * l).toInt().coerceIn(0, 255))
        }
        val c = cos(Math.toRadians(PITCH)); val s = sin(Math.toRadians(PITCH))
        fun v(r: Double, u: Double, f: Double) = HeroFigure.V(r, u, f)
        heroes().forEachIndexed { i, h0 ->
            val cls = h0.cls
            if (cls == CharClass.FIGHTER) h0.unequip(GearSlot.OFF_HAND)
            if (cls == CharClass.CLERIC && h0.item(GearSlot.MAIN_HAND) == null) h0.equip(Gear(9100, "mace", Rarity.COMMON, 1))
            val idle = HeroFigure.sequence(HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, HeroFigure.stance(h0))[0]
            val rig = when (cls) {
                // both hands on the pommel, the point on the ground before him
                CharClass.FIGHTER -> idle.copy(rh = v(2.0, 60.0, 18.0), lh = v(-3.0, 62.0, 17.0), weapon = v(0.0, -1.0, 0.12), aim = 1.0, grip = 80.0, headTurn = 0.0)
                // the blade hanging at the side, point down
                CharClass.ROGUE -> idle.copy(rh = v(15.0, 58.0, 2.0), weapon = v(0.15, -1.0, -0.1), aim = 1.0, headTurn = 0.0)
                // the weapon hanging, the shield held on the arm as it is (a hand set by us poked through it)
                CharClass.CLERIC -> idle.copy(rh = v(15.0, 58.0, 4.0), weapon = v(0.05, -1.0, 0.15), aim = 1.0, headTurn = 0.0)
                // the staff upright beside her
                else -> HeroFigure.STAFF_REST
            }.copy(yaw = YAWS[i])
            val d = HeroBattle.doll(h0)
            val k = px * (if (h0.race == Race.DWARF) DWARF_CM else 185.0) / d.height
            val ax = slot * (i + 0.5) + (w - slot * 4) / 2.0
            val sx = (ax - w / 2.0) / px
            val lx = LIGHT.x - sx; val ly = LIGHT.y; val lz = LIGHT.z
            val tl = TitleLight(P3(lx, ly * c - lz * s, lz * c + ly * s), fireRgb = 0xFFC078, fireK = 1.25, reach = 420.0, rimRgb = 0xFFC890, rimK = 1.5,
                ambientRgb = 0x3A3438, ambientK = 0.9, ink = 2.0 * scale * SS, eyeDots = false, shineK = 0.0, inkJump = 6.0, inkDark = 0.7)
            val fw = (420 * scale).toInt()
            val big = d.render(fw * SS, h * SS, fw * SS / 2.0, ground * SS, k * SS, rig, HeroBattle.outfit(h0), pitch = PITCH, title = tl).img
            // spaced evenly by where each figure's mass stands, not by its anchor: a staff or a turn shifts the body
            var mx = 0.0; var ms = 0.0
            for (y in 0 until big.height) for (x in 0 until big.width) { val qa = (big[x, y] ushr 24).toDouble(); mx += qa * x; ms += qa }
            val ox = (ax - mx / ms / SS).toInt()
            for (y in 0 until h) for (x in 0 until fw) {
                val tx = ox + x
                if (tx !in 0 until w) continue
                var r = 0.0; var g = 0.0; var b = 0.0; var a = 0.0
                for (j in 0 until SS) for (i2 in 0 until SS) {
                    val q = big[x * SS + i2, y * SS + j]; val qa = (q ushr 24) / 255.0
                    r += ((q shr 16) and 0xFF) * qa; g += ((q shr 8) and 0xFF) * qa; b += (q and 0xFF) * qa; a += qa
                }
                if (a <= 0) continue
                val q = argb(((r / a).toInt() shl 16) or ((g / a).toInt() shl 8) or (b / a).toInt())
                out.pixels[y * w + tx] = mix(out.pixels[y * w + tx], q, a / (SS * SS))
            }
        }
        if (scale == 1.0) kept = out
        return out
    }

    private const val SS = 2
}
