package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.Build
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearBases
import de.bornim.core.GearSlot
import de.bornim.core.Icon
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Sex
import de.bornim.core.art.HeroFigure.Rig
import de.bornim.core.art.HeroFigure.V
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Pictures of the things that can be worn and carried, built from the very solids the hero wears them as: a weapon
 * held up across the picture, a shield face on, armour and clothes standing empty as on an unseen body; rings and
 * amulets are built here in the round. How rare a piece is shows round it ([Mark]). Whatever is not worn (potions,
 * keys, herbs) keeps its drawn [IconArt].
 */
object ItemArt {
    const val SIZE = 32
    private const val MARGIN = 3

    /** How a piece's rarity shows: always one stone per step above the common, with a glow behind it, its outline in the rarity's colour, or alone. */
    enum class Mark { GLOW, EDGE, PIPS }
    @Volatile var mark = Mark.PIPS

    /** A millimetre at ten times life size, the unit rings and amulets are built in. */
    private const val U = 1.0

    private val HEADED = setOf("mace", "warhammer", "handaxe")
    private val LONG = setOf("spear", "halberd", "quarterstaff", "staff")

    private val cache = HashMap<String, PixelImage>()
    private val plain = HashMap<String, PixelImage>()

    /** The picture of [base] in [rarity], marked as rare as it is. */
    fun get(base: String, rarity: Rarity = Rarity.COMMON, how: Mark = mark): PixelImage {
        val k = "$base/$rarity/$how"
        synchronized(cache) { cache[k]?.let { return it } }
        val img = marked(bare(base, rarity), rarity, how)
        synchronized(cache) { cache[k] = img }
        return img
    }

    fun get(g: Gear): PixelImage = get(g.base, g.rarity)

    /** The picture if it is drawn already: drawing one takes a few hundredths of a second, so lists draw them aside. */
    fun ready(base: String, rarity: Rarity = Rarity.COMMON, how: Mark = mark): PixelImage? = synchronized(cache) { cache["$base/$rarity/$how"] }

    /** The piece alone, unmarked. */
    private fun bare(base: String, rarity: Rarity): PixelImage {
        val k = "$base/$rarity"
        synchronized(plain) { plain[k]?.let { return it } }
        val img = render(base, rarity)
        synchronized(plain) { plain[k] = img }
        return img
    }

    private val doll by lazy { Doll(Race.HUMAN, Sex.MALE, Build.AVERAGE) }

    /** How a thing is held up to be seen: the pose, the side it is seen from and how far from above. */
    private class View(val rig: Rig, val yaw: Double, val pitch: Double = 15.0)

    private fun view(base: String, slot: GearSlot): View {
        val def = GearBases[base]
        return when {
            // a bow seen from the side, so its curve shows
            slot == GearSlot.MAIN_HAND && def.icon == Icon.BOW -> View(Rig(lh = V(0.0, 100.0, 20.0), rh = V(14.0, 64.0, 4.0), bowTilt = 40.0), 90.0)
            // a crossbow spanned and loaded, seen almost from above, so the bent prod, the string and the bolt all show
            slot == GearSlot.MAIN_HAND && def.icon == Icon.CROSSBOW -> View(Rig(rh = V(-4.0, 95.0, 25.0), weapon = V(-1.0, 0.2, -1.0), aim = 1.0, grip = 10.0, draw = 1.0), 0.0, 80.0)
            // across the picture from lower left to upper right, the flat to the onlooker
            slot == GearSlot.MAIN_HAND -> View(Rig(rh = V(-4.0, 95.0, 25.0), weapon = V(-1.0, 1.0, 0.0), aim = 1.0, grip = 45.0), 0.0)
            slot == GearSlot.OFF_HAND && def.kind == BaseKind.SHIELD -> View(Rig(lh = V(-6.0, 100.0, 22.0), shieldFace = V(-0.25, 0.0, 1.0)), 0.0)
            slot == GearSlot.OFF_HAND -> View(Rig(lh = V(-6.0, 100.0, 22.0), weapon = V(-1.0, 1.0, 0.0)), 0.0, 25.0)
            base == "holy_symbol" || slot == GearSlot.AMULET -> View(Doll.REST, 0.0, 10.0)
            slot == GearSlot.RING || base == "circlet" -> View(Doll.REST, 0.0, 35.0)
            else -> View(Doll.REST, 20.0)
        }
    }

    /** [base] seen as [rig], from [yaw] and [pitch]: for trying out how a piece is best held up. */
    fun probe(base: String, rig: Rig, yaw: Double, pitch: Double): PixelImage = render(base, Rarity.COMMON, View(rig, yaw, pitch))

    private fun render(base: String, rarity: Rarity, given: View? = null): PixelImage {
        val def = GearBases[base]
        val slot = def.slot
        val v = given ?: view(base, slot)
        // a rogue's armour, so no tabard of a fighter or a cleric hides it
        val cls = if (base == "robe") CharClass.WIZARD else CharClass.ROGUE
        val gear = Gear(0, base, rarity, 1)
        val sk = doll.Skeleton(v.rig.copy(yaw = v.yaw), shieldArm = def.kind == BaseKind.SHIELD, fists = true,
            twoHands = def.twoHanded && !def.ranged, weaponReach = Dress.reach(base))
        val jewel = slot == GearSlot.RING || slot == GearSlot.AMULET || base == "circlet" || base == "holy_symbol"
        val solids = when {
            jewel -> jewel(base, rarity)
            // of a pair of gloves or bracers one is enough, and larger
            else -> Dress(doll, sk, doll.body(sk), Outfit(cls, mapOf(slot to gear))).only(slot).filter { slot != GearSlot.ARMS || it.group != Doll.ARMOR_L }
        }
        if (solids.isEmpty()) return IconArt.get(def.icon)
        val groups = doll.groups(sk)
        // drawn once large to find its extent, then again to fill the picture
        val big = 160
        val g0 = 145.0
        val px0 = 0.5
        val a = SdfRender.render(solids, groups, doll::material, big, big, big / 2.0, g0, px0, v.yaw, v.pitch).img
        var x0 = big; var y0 = big; var x1 = -1; var y1 = -1
        for (y in 0 until big) for (x in 0 until big) if ((a[x, y] ushr 24) > 0) { x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y) }
        if (x1 < 0) return IconArt.get(def.icon)
        val fit = SIZE - 2 * MARGIN
        // a long shaft would be a hairline: drawn larger, its head in the corner and its foot running out of the picture
        // a long shaft would be a hairline, a mace's or hammer's head a dot: drawn larger, the head in the corner and
        // the shaft running out of the picture
        val zoom = if (base in LONG) 2.2 else if (base in HEADED) 1.45 else 1.0
        val k = fit / maxOf(x1 - x0 + 1, y1 - y0 + 1).toDouble() * zoom
        val cx = if (zoom > 1) x1 + 1 - fit / k / 2 else (x0 + x1 + 1) / 2.0
        val cy = if (zoom > 1) y0 + fit / k / 2 else (y0 + y1 + 1) / 2.0
        val ax = SIZE / 2.0 - (cx - big / 2.0) * k
        val gr = SIZE / 2.0 + (g0 - cy) * k
        val img = SdfRender.render(solids, groups, doll::material, SIZE, SIZE, ax, gr, px0 * k, v.yaw, v.pitch).img
        val s = Sculpt(SIZE, SIZE)
        for (y in 0 until SIZE) for (x in 0 until SIZE) s.img.set(x, y, img[x, y])
        s.outline(argb(0x14100E))
        return s.img
    }

    // ---------------------------------------------------------------- rings and amulets, in the round

    private fun mat(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, bias: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain, bias)

    /**
     * Rings, amulets, the circlet and the holy symbol, built here. They are built ten times their size, in units [U]
     * of a millimetre each, so the renderer's soft joins (a centimetre or so) do not melt their fine parts together.
     */
    private fun jewel(base: String, r: Rarity): List<Solid> {
        val out = mutableListOf<Solid>()
        fun put(s: Solid, m: Mat) { s.mat = m; out += s }
        val gold = mat(0xD8A838, shine = 0.8, bias = 0.05)
        val silver = mat(0xB8BCC4, shine = 0.8)
        // the stone in the rarity's colour, a plain blue for the common
        val stone = mat(if (r == Rarity.COMMON) 0x3C6CC8 else (r.color.toInt() and 0xFFFFFF), shine = 1.0, bias = 0.1)
        val c = P3(0.0, 40.0, 0.0)
        fun p(x: Double, y: Double, z: Double = 0.0) = c + P3(x * U, y * U, z * U)
        fun ball(at: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int = Doll.TRIM) = put(Ellipsoid(at, P3(rx * U, ry * U, rz * U), Frame.IDENTITY, BodyPart.GEAR, g), m)
        fun rod(a: P3, b: P3, ra: Double, rb: Double, m: Mat) = put(RoundCone(a, b, ra * U, rb * U, BodyPart.GEAR, Doll.ITEM), m)
        /** A band round [mid]: [rx] across, [ry] up, tipped back by [tilt]; from [from] to [to] of the way round. */
        fun hoop(mid: P3, rx: Double, ry: Double, thick: Double, m: Mat, tilt: Double = 0.0, n: Int = 20, from: Double = 0.0, to: Double = 2 * PI) {
            fun at(t: Double) = mid + P3(rx * cos(t) * U, ry * sin(t) * cos(tilt) * U, ry * sin(t) * sin(tilt) * U)
            for (i in 0 until n) { val t0 = from + (to - from) * i / n; val t1 = from + (to - from) * (i + 1) / n; rod(at(t0), at(t1), thick, thick, m) }
        }
        when (base) {
            // a gold band, a little tipped, with a stone held by four claws on top
            "ring" -> {
                hoop(c, 9.0, 9.0, 1.8, gold, tilt = -0.55)
                for (k in 0..3) { val a = k * PI / 2 + PI / 4; rod(p(0.0, 7.5), p(2.6 * cos(a), 11.5, 2.6 * sin(a)), 0.8, 0.5, gold) }
                ball(p(0.0, 11.5), 3.6, 3.0, 3.6, stone)
            }
            // a heavy band with a flat gold seal on top, a small stone set in it
            "signet" -> {
                hoop(c, 9.0, 9.0, 2.2, gold, tilt = -0.55)
                put(Box(p(0.0, 9.5), P3(5.0 * U, 1.4 * U, 4.0 * U), Frame.IDENTITY, 0.5 * U, BodyPart.GEAR, Doll.ITEM), gold)
                ball(p(0.0, 11.0), 2.4, 0.8, 2.0, stone)
            }
            // a fine chain hanging in a U, a stone in a gold setting at its foot
            "amulet" -> {
                hoop(p(0.0, 14.0), 10.0, 18.0, 0.8, gold, n = 18, from = PI, to = 2 * PI)
                ball(p(0.0, -8.0), 6.0, 7.5, 2.4, gold, Doll.ITEM)
                ball(p(0.0, -8.0, 1.6), 4.2, 5.4, 2.0, stone)
            }
            // a leather cord in a U, a disc of old silver at its foot with a ring cut in it and a stone in the middle
            "talisman" -> {
                hoop(p(0.0, 14.0), 10.0, 18.0, 0.9, mat(0x5A4030, grain = 0.2), n = 18, from = PI, to = 2 * PI)
                ball(p(0.0, -9.0), 8.0, 8.0, 1.6, silver, Doll.ITEM)
                hoop(p(0.0, -9.0, 1.5), 5.6, 5.6, 0.6, mat(0x6A6C72, shine = 0.4), n = 20)
                ball(p(0.0, -9.0, 1.6), 2.6, 2.6, 1.6, stone)
            }
            // a thin band to go round the brow, seen from above and in front, a stone over the forehead
            "circlet" -> {
                hoop(c, 30.0, 30.0, 1.4, silver, tilt = 1.4, n = 32)
                ball(p(0.0, 30.0 * cos(1.4), 30.0 * sin(1.4) + 1.0), 4.0, 5.0, 3.0, stone)
                for (sd in listOf(-1.0, 1.0)) ball(p(sd * 6.0, 30.0 * cos(1.4) * 0.98, 30.0 * sin(1.4) * 0.98 + 0.5), 1.6, 1.6, 1.4, silver)
            }
            // the holy symbol: a golden sun, a disc with rays all round
            "holy_symbol" -> {
                ball(c, 9.0, 9.0, 2.4, gold, Doll.ITEM)
                for (k in 0 until 12) { val a = k * PI / 6; val long = if (k % 2 == 0) 17.0 else 13.5
                    rod(p(8.0 * cos(a), 8.0 * sin(a)), p(long * cos(a), long * sin(a)), 1.6, 0.4, gold) }
                hoop(p(0.0, 0.0, 2.0), 5.5, 5.5, 0.7, mat(0xA87820, shine = 0.6), n = 20)
            }
            else -> hoop(c, 9.0, 9.0, 1.8, gold, tilt = -0.55)
        }
        return out
    }

    // ---------------------------------------------------------------- rarity

    private fun marked(src: PixelImage, r: Rarity, how: Mark): PixelImage {
        if (r == Rarity.COMMON) return src
        val col = r.color.toInt() and 0xFFFFFF
        val out = PixelImage(SIZE, SIZE)
        when (how) {
            Mark.GLOW -> {
                // a soft light behind the piece, stronger the rarer it is
                val k = 0.55 + 0.09 * r.ordinal
                for (y in 0 until SIZE) for (x in 0 until SIZE) {
                    if (src.opaque(x, y)) continue
                    var d = 9.0
                    for (dy in -3..3) for (dx in -3..3) if (src.opaque(x + dx, y + dy)) d = minOf(d, sqrt((dx * dx + dy * dy).toDouble()))
                    if (d > 3.0) continue
                    val a = ((1 - (d - 1) / 3.0).coerceIn(0.0, 1.0) * k * 255).toInt()
                    if (a > 0) out.set(x, y, alpha(argb(if (d < 1.5) mix(argb(col), argb(0xFFFFFF), 0.3) else col), a))
                }
                for (y in 0 until SIZE) for (x in 0 until SIZE) if (src.opaque(x, y)) out.set(x, y, src[x, y])
                pips(out, r, col, 4.0)
            }
            Mark.EDGE -> {
                // the dark outline drawn in the rarity's colour instead, a fainter ring of it outside
                for (y in 0 until SIZE) for (x in 0 until SIZE) {
                    if (src.opaque(x, y)) {
                        val edge = !src.opaque(x - 1, y) || !src.opaque(x + 1, y) || !src.opaque(x, y - 1) || !src.opaque(x, y + 1)
                        out.set(x, y, if (edge) mix(argb(col), argb(0x000000), 0.15) else src[x, y])
                    } else if (src.opaque(x - 1, y) || src.opaque(x + 1, y) || src.opaque(x, y - 1) || src.opaque(x, y + 1)) out.set(x, y, alpha(argb(col), 110))
                }
                pips(out, r, col, 4.0)
            }
            Mark.PIPS -> {
                // the piece as it is; only larger stones tell how rare it is
                for (y in 0 until SIZE) for (x in 0 until SIZE) out.set(x, y, src[x, y])
                pips(out, r, col, 4.0)
            }
        }
        return out
    }

    /**
     * One small cut stone in the rarity's colour for each step above the common, in a row at the foot of the picture
     * from the right, so the step can be told by the count as well as by the colour.
     */
    private fun pips(img: PixelImage, r: Rarity, col: Int, size: Double) {
        val n = r.ordinal
        val rad = size / 2
        val gap = size + 1.0
        for (k in 0 until n) {
            val cx = SIZE - 1.5 - rad - k * gap; val cy = SIZE - 1.5 - rad
            for (y in (cy - rad - 1).toInt()..(cy + rad + 1).toInt()) for (x in (cx - rad - 1).toInt()..(cx + rad + 1).toInt()) {
                if (x !in 0 until SIZE || y !in 0 until SIZE) continue
                val dx = x + 0.5 - cx; val dy = y + 0.5 - cy
                val d = kotlin.math.abs(dx) + kotlin.math.abs(dy)
                when {
                    d <= rad -> img.set(x, y, if (dx <= 0 && dy <= 0) mix(argb(col), argb(0xFFFFFF), 0.5) else if (dx > 0 && dy > 0) mix(argb(col), argb(0x000000), 0.25) else argb(col))
                    d <= rad + 1.1 -> img.set(x, y, argb(0x14100E))
                }
            }
        }
    }
}
