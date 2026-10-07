package de.bornim.core.art

import de.bornim.core.Items
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

/**
 * Pictures of the supplies (draughts, food, what is cut from beasts, keys and letters), built in the round like the
 * gear ([ItemArt]): every one its own, so a potion of healing, a herbal draught and alchemist's fire no longer share
 * one flask. Built at about ten times life size, so fine parts keep apart.
 */
object SupplyArt {
    private val cache = HashMap<String, PixelImage>()

    /** The picture of the supply [id], or its old drawn icon if it has none. */
    fun get(id: String): PixelImage {
        synchronized(cache) { cache[id]?.let { return it } }
        val img = render(id) ?: IconArt.get(Items[id].icon)
        synchronized(cache) { cache[id] = img }
        return img
    }

    /** The picture if it is drawn already. */
    fun ready(id: String): PixelImage? = synchronized(cache) { cache[id] }

    /** Hard edges for glass, metal and bone; soft joins for flesh, fur and leaves. */
    private val groups by lazy {
        Groups(Doll.GROUPS).apply { set(Doll.ITEM, 0.0); set(Doll.TRIM, 0.3); set(Doll.CLOTH, 2.5) }
    }

    private fun mat(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, bias: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain, bias)

    private fun render(id: String): PixelImage? {
        val out = mutableListOf<Solid>()
        val c = P3(0.0, 40.0, 0.0)
        fun p(x: Double, y: Double, z: Double = 0.0) = c + P3(x, y, z)
        fun put(s: Solid, m: Mat, paint: ((P3) -> Mat)? = null) { s.mat = m; s.paint = paint; out += s }
        fun ball(at: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int = Doll.ITEM, f: Frame = Frame.IDENTITY, paint: ((P3) -> Mat)? = null) =
            put(Ellipsoid(at, P3(rx, ry, rz), f, BodyPart.GEAR, g), m, paint)
        fun rod(a: P3, b: P3, ra: Double, rb: Double, m: Mat, g: Int = Doll.ITEM) = put(RoundCone(a, b, ra, rb, BodyPart.GEAR, g), m)
        fun box(at: P3, hx: Double, hy: Double, hz: Double, m: Mat, f: Frame = Frame.IDENTITY, round: Double = 0.3, paint: ((P3) -> Mat)? = null) =
            put(Box(at, P3(hx, hy, hz), f, round, BodyPart.GEAR, Doll.ITEM), m, paint)
        val gold = mat(0xD8A838, shine = 0.8, bias = 0.05)
        val cork = mat(0x9A7A50, grain = 0.4)
        val glass = mat(0xA8B8C4, shine = 1.0, bias = 0.06)

        /**
         * A flask of glass: [liquid] up to [level] of its body, clear glass above it, a light caught on its shoulder.
         * The body is [rx] wide and [ry] tall; the neck [neck] long.
         */
        fun flask(liquid: Int, rx: Double, ry: Double, neck: Double, level: Double = 0.55, glow: Double = 0.0) {
            val fill = mat(liquid, shine = 0.9, bias = 0.05 + glow)
            val top = c.y - ry + 2 * ry * level
            ball(c, rx, ry, rx * 0.95, fill, paint = { q -> if (q.y > top) glass else fill })
            rod(p(0.0, ry * 0.8), p(0.0, ry * 0.8 + neck), rx * 0.32, rx * 0.3, glass)
            rod(p(0.0, ry * 0.8 + neck - 0.6), p(0.0, ry * 0.8 + neck + 0.6), rx * 0.38, rx * 0.38, glass, Doll.TRIM)
            rod(p(0.0, ry * 0.8 + neck + 0.4), p(0.0, ry * 0.8 + neck + 4.0), rx * 0.27, rx * 0.25, cork, Doll.TRIM)
            // the light caught on the glass
            ball(p(-rx * 0.42, ry * 0.35, rx * 0.72), rx * 0.13, ry * 0.2, rx * 0.06, mat(0xFFFFFF, shine = 1.0, bias = 0.35), Doll.TRIM)
        }

        val pitch: Double
        val yaw: Double
        when (id) {
            // the plain healing draught: a round flask of red
            "potion" -> { flask(0xB02028, 11.0, 11.0, 7.0); pitch = 15.0; yaw = 10.0 }
            // the greater one: larger, deep rose, a gold band round the neck
            "greater_potion" -> {
                flask(0xC0306A, 13.0, 13.0, 7.0, 0.62)
                rod(p(0.0, 13.0 * 0.8 + 2.0), p(0.0, 13.0 * 0.8 + 3.2), 13.0 * 0.36, 13.0 * 0.36, gold, Doll.TRIM)
                pitch = 15.0; yaw = 10.0
            }
            // the superior one: tall, violet and gold, a gilt cap over the cork
            "superior_potion" -> {
                flask(0x7A2AB0, 10.0, 15.0, 6.0, 0.7, glow = 0.1)
                rod(p(0.0, 15.0 * 0.8 + 6.0), p(0.0, 15.0 * 0.8 + 10.5), 3.3, 2.8, gold, Doll.TRIM)
                ball(p(0.0, 15.0 * 0.8 + 11.0), 2.2, 2.2, 2.2, gold, Doll.TRIM)
                rod(p(0.0, -11.0), p(0.0, -9.0), 9.0, 9.4, gold, Doll.TRIM)
                pitch = 15.0; yaw = 10.0
            }
            // the herbal draught: a squat green bottle with a sprig tied at its neck
            "remedy" -> {
                flask(0x3A8A3A, 12.0, 9.0, 6.0, 0.6)
                val leaf = mat(0x4E9A3A, grain = 0.2)
                ball(p(4.0, 10.5, 3.5), 1.6, 4.0, 0.6, leaf, Doll.TRIM, Frame.along(P3(0.6, 1.0, 0.2).norm()))
                ball(p(-3.0, 11.0, 3.8), 1.5, 3.6, 0.6, leaf, Doll.TRIM, Frame.along(P3(-0.7, 1.0, 0.2).norm()))
                rod(p(-4.0, 8.4, 0.0), p(4.0, 8.4, 0.0), 0.7, 0.7, mat(0xB89A6A), Doll.TRIM)
                pitch = 15.0; yaw = 10.0
            }
            // alchemist's fire: glowing orange, a rag stuffed in the neck for a wick
            "alchemist_fire" -> {
                flask(0xF07A18, 10.0, 11.0, 6.0, 0.8, glow = 0.3)
                val rag = mat(0xC8B48A, grain = 0.5)
                ball(p(0.0, 15.5, 0.0), 2.6, 3.0, 2.4, rag, Doll.TRIM)
                ball(p(1.8, 18.5, 0.3), 1.6, 2.6, 1.2, rag, Doll.TRIM, Frame.along(P3(0.5, 1.0, 0.0).norm()))
                ball(p(2.6, 21.0, 0.3), 1.0, 1.4, 0.8, mat(0xFFB030, shine = 0.6, bias = 0.4), Doll.TRIM)
                pitch = 15.0; yaw = 10.0
            }
            // holy water: a slim vial of pale blue, a gold sun pressed on its face
            "holy_water" -> {
                flask(0x8AC8F0, 7.0, 13.0, 5.0, 0.75, glow = 0.15)
                ball(p(0.0, -1.0, 6.4), 3.2, 3.2, 0.6, gold, Doll.TRIM)
                for (k in 0 until 8) { val a = k * PI / 4
                    rod(p(3.0 * cos(a), -1.0 + 3.0 * sin(a), 6.3), p(5.0 * cos(a), -1.0 + 5.0 * sin(a), 6.0), 0.6, 0.2, gold, Doll.TRIM) }
                pitch = 15.0; yaw = 10.0
            }
            // a raw cut: dark red flesh marbled with fat, a white bone end
            "raw_meat" -> {
                val flesh = mat(0x9A2A2A, shine = 0.35, grain = 0.3)
                val fat = mat(0xE8D2C0, shine = 0.2)
                ball(c, 16.0, 7.0, 11.0, flesh, Doll.CLOTH, paint = { q -> if (sin(q.x * 0.55 + q.z * 0.35) * sin(q.z * 0.7 - q.x * 0.2) > 0.72) fat else flesh })
                ball(p(-13.0, 1.0, -3.0), 5.0, 5.5, 7.0, fat, Doll.CLOTH)
                rod(p(10.0, 1.0, 0.0), p(20.0, 2.0, 1.0), 2.4, 2.2, fat)
                ball(p(21.0, 2.0, 1.0), 3.0, 2.8, 2.8, mat(0xF0E8DA), Doll.TRIM)
                pitch = 45.0; yaw = 15.0
            }
            // a roast leg: browned and glistening, crisp at the edges, a bone to hold it by
            "roast_meat" -> {
                val crust = mat(0x8A4A1E, shine = 0.55, grain = 0.35)
                val dark = mat(0x5A2E12, shine = 0.4, grain = 0.4)
                val dir = P3(0.75, 0.66, 0.0).norm()
                ball(c, 11.0, 15.0, 10.0, crust, Doll.CLOTH, Frame.along(dir), paint = { q -> if (sin(q.x * 0.9) + sin(q.y * 1.1 + q.z) > 1.3) dark else crust })
                rod(c - dir * 13.0, c - dir * 24.0, 2.6, 2.4, mat(0xF0E8DA))
                ball(c - dir * 25.0 + P3(1.5, -1.5, 0.0), 2.8, 2.8, 2.6, mat(0xF0E8DA), Doll.TRIM)
                ball(c - dir * 25.0 + P3(-1.5, 1.5, 0.0), 2.8, 2.8, 2.6, mat(0xF0E8DA), Doll.TRIM)
                pitch = 25.0; yaw = 10.0
            }
            // a bunch of herbs: leaves on thin stems, tied with twine, a few pale flowers
            "herbs" -> {
                val stem = mat(0x5A7A2A)
                val leaves = listOf(mat(0x3E8A30, grain = 0.25), mat(0x5AA040, grain = 0.25), mat(0x2E6E28, grain = 0.25))
                for (k in 0 until 7) {
                    val a = -0.75 + k * 0.25
                    val tip = p(18.0 * sin(a), 18.0 + 4.0 * cos(k * 1.7), 2.0 * sin(k * 2.3))
                    rod(p(0.0, -10.0), tip, 0.5, 0.35, stem, Doll.TRIM)
                    val d = (tip - p(0.0, -10.0)).norm()
                    ball(tip - d * 3.0, 2.6, 5.5, 0.7, leaves[k % 3], Doll.TRIM, Frame.along(d))
                    ball(tip - d * 11.0 + P3(if (k % 2 == 0) 2.5 else -2.5, 0.0, 0.0), 2.0, 4.2, 0.6, leaves[(k + 1) % 3], Doll.TRIM,
                        Frame.along((d + P3(if (k % 2 == 0) 0.6 else -0.6, 0.0, 0.0)).norm()))
                }
                for (k in listOf(1, 4, 6)) ball(p(18.0 * sin(-0.75 + k * 0.25) * 1.05, 19.5 + 4.0 * cos(k * 1.7), 1.0), 1.4, 1.4, 1.4, mat(0xE8C8E8, bias = 0.15), Doll.TRIM)
                rod(p(-2.2, -5.0), p(2.2, -5.0), 1.0, 1.0, mat(0xB89A6A), Doll.TRIM)
                pitch = 15.0; yaw = 0.0
            }
            // a wolf's pelt laid out flat: grey fur, a darker saddle, legs and tail spread
            "wolf_pelt" -> {
                val fur = mat(0x8A8680, grain = 0.7)
                val saddle = mat(0x4A4642, grain = 0.7)
                val paint: (P3) -> Mat = { q -> if (abs(q.x - c.x) < 6.0 + 2.0 * sin(q.y * 0.5) && q.y > c.y - 14.0) saddle else fur }
                ball(c, 13.0, 20.0, 1.6, fur, Doll.CLOTH, paint = paint)
                for ((sx, sy) in listOf(-1.0 to 1.0, 1.0 to 1.0, -1.0 to -1.0, 1.0 to -1.0)) {
                    val a = p(sx * 9.0, sy * 12.0); val b = p(sx * 22.0, sy * 20.0)
                    ball(a.lerp(b, 0.5), 3.5, 8.5, 1.3, fur, Doll.CLOTH, Frame.along((b - a).norm()), paint)
                }
                ball(p(0.0, -26.0), 3.4, 9.0, 1.4, saddle, Doll.CLOTH)
                ball(p(0.0, 22.0), 6.5, 5.0, 1.6, fur, Doll.CLOTH, paint = paint)
                for (sx in listOf(-1.0, 1.0)) ball(p(sx * 4.5, 27.0), 1.8, 3.0, 1.0, saddle, Doll.CLOTH)
                pitch = 10.0; yaw = 0.0
            }
            // a boar's tusk: curved ivory, yellowed and darker at the root
            "boar_tusk" -> {
                val ivory = mat(0xEDE2C6, shine = 0.4)
                val root = mat(0x9A7A50, grain = 0.3)
                val n = 10
                fun at(t: Double) = p(-14.0 + 28.0 * t, -10.0 + 26.0 * sin(t * 1.9), 0.0)
                for (k in 0 until n) {
                    val t0 = k / n.toDouble(); val t1 = (k + 1) / n.toDouble()
                    rod(at(t0), at(t1), 4.2 * (1 - t0) + 0.4, 4.2 * (1 - t1) + 0.4, if (k < 2) root else ivory)
                }
                pitch = 15.0; yaw = 0.0
            }
            // a poison gland: a glossy sac, sickly green, dark veins, a torn duct
            "spider_gland" -> {
                val sac = mat(0x6A9A3A, shine = 0.9, bias = 0.05)
                val vein = mat(0x3A2A4A, shine = 0.6)
                ball(c, 12.0, 14.0, 11.0, sac, paint = { q -> if (abs(sin(q.x * 0.5 + sin(q.y * 0.4) * 1.5)) < 0.12) vein else sac })
                rod(p(0.0, 13.0), p(3.0, 20.0), 3.0, 1.8, mat(0x8A6A5A, shine = 0.5))
                ball(p(-4.0, 5.0, 9.0), 2.0, 3.0, 1.0, mat(0xFFFFFF, shine = 1.0, bias = 0.3), Doll.TRIM)
                pitch = 15.0; yaw = 10.0
            }
            // a bat's wing: thin finger bones spread from the wrist, leathery skin stretched between them
            "bat_wing" -> {
                val bone = mat(0xC0A488, shine = 0.2)
                val skin = mat(0x5A403C, shine = 0.25)
                val wrist = p(-14.0, -6.0)
                val tips = listOf(p(18.0, 20.0), p(22.0, 4.0), p(16.0, -12.0), p(2.0, -18.0))
                rod(p(-24.0, -14.0), wrist, 2.2, 1.8, bone, Doll.TRIM)
                rod(wrist, p(-10.0, 4.0), 1.4, 0.8, bone, Doll.TRIM)
                for (t in tips) rod(wrist + P3(0.0, 0.0, 0.8), t + P3(0.0, 0.0, 0.8), 1.3, 0.6, bone, Doll.TRIM)
                for (k in 0 until tips.size - 1) {
                    val a = tips[k]; val b = tips[k + 1]
                    val mid = wrist.lerp(a.lerp(b, 0.5), 0.55)
                    val along = (a.lerp(b, 0.5) - wrist).norm()
                    ball(mid, ((a - b).len() * 0.32), ((a.lerp(b, 0.5) - wrist).len() * 0.5), 0.4, skin, Doll.ITEM, Frame.along(along))
                }
                ball(wrist.lerp(tips[0], 0.45) + P3(-4.0, 3.0, 0.0), 6.0, 10.0, 0.4, skin, Doll.ITEM, Frame.along((tips[0] - wrist).norm()))
                pitch = 20.0; yaw = 0.0
            }
            // a rusty iron key: a ring for a bow, a long shank, a toothed bit
            "rusty_key" -> {
                val iron = mat(0x6A6460, shine = 0.4, grain = 0.4)
                val rust = mat(0x8A4A26, grain = 0.6)
                val paint: (P3) -> Mat = { q -> if (sin(q.x * 0.8 + 1.0) * sin(q.y * 0.9) > 0.45) rust else iron }
                val dir = P3(0.7, 0.7, 0.0).norm(); val side = P3(0.7, -0.7, 0.0)
                val bow = c - dir * 14.0
                for (k in 0 until 14) { val a0 = k * 2 * PI / 14; val a1 = (k + 1) * 2 * PI / 14
                    val q0 = bow + dir * (6.0 * cos(a0)) + side * (6.0 * sin(a0)); val q1 = bow + dir * (6.0 * cos(a1)) + side * (6.0 * sin(a1))
                    put(RoundCone(q0, q1, 1.5, 1.5, BodyPart.GEAR, Doll.ITEM), iron, paint) }
                put(RoundCone(bow + dir * 6.0, c + dir * 18.0, 1.6, 1.4, BodyPart.GEAR, Doll.ITEM), iron, paint)
                box(c + dir * 14.5 + side * 3.5, 1.2, 3.2, 1.2, iron, Frame.along(dir, P3.Z), 0.3, paint)
                box(c + dir * 9.5 + side * 2.8, 1.2, 2.5, 1.2, iron, Frame.along(dir, P3.Z), 0.3, paint)
                pitch = 20.0; yaw = 0.0
            }
            // the sun amulet: a golden sun with rays on a chain hung in a U
            "sun_amulet" -> {
                for (k in 0 until 18) { val a0 = PI + k * PI / 18; val a1 = PI + (k + 1) * PI / 18
                    rod(p(10.0 * cos(a0), 16.0 + 18.0 * sin(a0)), p(10.0 * cos(a1), 16.0 + 18.0 * sin(a1)), 0.8, 0.8, gold) }
                ball(p(0.0, -8.0), 8.0, 8.0, 2.2, gold)
                for (k in 0 until 12) { val a = k * PI / 6; val long = if (k % 2 == 0) 15.5 else 12.5
                    rod(p(7.5 * cos(a), -8.0 + 7.5 * sin(a)), p(long * cos(a), -8.0 + long * sin(a)), 1.5, 0.4, gold) }
                ball(p(0.0, -8.0, 1.8), 3.4, 3.4, 1.2, mat(0xFFE070, shine = 1.0, bias = 0.25), Doll.TRIM)
                pitch = 10.0; yaw = 0.0
            }
            // the sealed letter: folded parchment, a ribbon round it and a red wax seal
            "prophet_letter" -> {
                val paper = mat(0xE6D8B4, grain = 0.25)
                box(c, 18.0, 12.0, 0.8, paper, paint = { q -> if (abs(q.y - c.y + (q.x - c.x) * 0.35) < 0.5) mat(0xB8A882) else paper })
                rod(p(-18.5, 1.0, 1.0), p(18.5, 1.0, 1.0), 0.8, 0.8, mat(0x6A2A2A), Doll.TRIM)
                ball(p(0.0, 1.0, 1.4), 4.5, 4.5, 1.4, mat(0xA01E1E, shine = 0.6), Doll.TRIM)
                ball(p(0.0, 1.0, 2.6), 2.6, 2.6, 0.5, mat(0x7A1414, shine = 0.4), Doll.TRIM)
                pitch = 12.0; yaw = 12.0
            }
            else -> return null
        }
        return ItemArt.picture(out, groups, yaw, pitch)
    }
}
