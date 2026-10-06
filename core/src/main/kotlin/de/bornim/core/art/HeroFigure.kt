package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Icon
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Weight
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * The hero in the new battle style: drawn at the pixel size of the battle scenes, with adult
 * proportions, seen from behind and a little from the side, facing the foe at the upper right.
 * Everything equipped shows: helmet or hood, the weight of the armor, cloak, gloves, boots, shield
 * (from behind: planks, straps and rim) and the weapon. Muted colours, rarer pieces carry the tint
 * of their rarity.
 */
object HeroFigure {
    const val W = 128
    const val H = 166

    /** Where the feet stand, from the top. */
    const val GROUND = 162

    enum class Act { IDLE, ATTACK, HURT }

    /** How much larger than its 96 × 128 layout the figure is drawn. */
    private const val SIZE = 1.28

    private val cache = object : LinkedHashMap<String, PixelImage>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 60
    }

    private data class Part(val icon: Icon, val rarity: Rarity, val weight: Weight, val kind: BaseKind, val twoHanded: Boolean, val ranged: Boolean, val base: String)

    private fun part(g: Gear?) = g?.def?.let { Part(it.icon, g.rarity, it.weight, it.kind, it.twoHanded, it.ranged, g.base) }

    const val IDLE_FRAMES = 16

    fun frame(hero: Hero, act: Act, index: Int = 0): PixelImage {
        val parts = GearSlot.entries.associateWith { part(hero.item(it)) }
        val f = if (act == Act.IDLE) index.mod(IDLE_FRAMES) else index
        val key = "${hero.race}/${hero.cls}/$act/$f/" + parts.values.joinToString(",")
        synchronized(cache) { cache[key]?.let { return it } }
        val s = Sculpt(W, H, 17)
        Painter(s, hero.race, hero.cls, parts, act, f).draw()
        s.transform()
        s.rim(argb(0xF4D8B0), 0.28)
        s.outline(argb(0x14100E))
        synchronized(cache) { cache[key] = s.img }
        return s.img
    }

    private class Painter(val s: Sculpt, val race: Race, val cls: CharClass, val parts: Map<GearSlot, Part?>, val act: Act, frame: Int) {
        val look = CharacterArt.heroLook(race, cls)
        val ph = frame / IDLE_FRAMES.toDouble() * 2 * PI
        val b = if (act == Act.IDLE) sin(ph) else 0.0
        val c = if (act == Act.IDLE) cos(ph) else 0.0
        val atk = act == Act.ATTACK
        val hurt = act == Act.HURT

        fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(rgb), shine, grain)

        /** Muted version of a look colour: the bright class colours become worn cloth. */
        fun worn(rgb: Int, k: Double = 0.38) = mix(rgb, argb(0x3A3632), k)

        val skin = m(look.skin)
        val hair = m(worn(look.hair, 0.15), grain = 0.15)
        val leather = m(argb(0x6A4A32), grain = 0.07)
        val darkLeather = m(argb(0x3E2C22), grain = 0.05)
        val steel = m(argb(0x9AA2AC), shine = 0.75)
        val darkSteel = m(argb(0x6E7680), shine = 0.6)
        val gold = m(argb(0xB8904A), shine = 0.7)
        val wood = m(argb(0x6E4A2C), grain = 0.12)
        val cloth = m(worn(look.cloth), grain = 0.05)
        val clothDark = m(worn(look.clothDark, 0.45), grain = 0.05)
        val pantsMat = m(worn(look.pants, 0.3), grain = 0.05)

        fun metal(r: Rarity): Mat {
            val tint = when (r) {
                Rarity.COMMON, Rarity.UNCOMMON -> 0.0
                Rarity.RARE -> 0.25
                Rarity.VERY_RARE -> 0.35
                Rarity.EPIC, Rarity.DIVINE -> 0.45
            }
            return m(mix(argb(0xA0A8B2), r.color.toInt(), tint), shine = 0.85)
        }

        fun cloakColor(r: Rarity) = worn(argb(
            when (r) {
                Rarity.COMMON -> 0x5A4636
                Rarity.UNCOMMON -> 0x34603A
                Rarity.RARE -> 0x34508A
                Rarity.VERY_RARE -> 0x56347E
                Rarity.EPIC -> 0x8A3E22
                Rarity.DIVINE -> 0xC8B888
            },
        ), 0.2)

        // body layout (human), adjusted per race below
        val scale = when (race) { Race.HALFLING -> 0.72; Race.DWARF -> 0.8; Race.ELF -> 1.03; else -> 1.0 }
        val wide = when (race) { Race.DWARF -> 1.3; Race.HALF_ORC -> 1.2; Race.ELF -> 1.02; Race.HALFLING -> 1.12; else -> 1.1 }
        val headBig = when (race) { Race.HALFLING -> 1.22; Race.DWARF -> 1.14; else -> 1.0 }

        fun draw() {
            val lean = if (atk) 3.0 else if (hurt) -3.0 else 0.0
            // drawn on a 96 × 128 layout with the feet at (48, 124), enlarged into the figure: the hero stands in the foreground
            s.transform(16.0 + lean, 38.0 + (if (hurt) 1.0 else 0.0), SIZE * scale * wide, SIZE * scale * (1 + b * 0.008), 64.0, GROUND.toDouble())
            val chest = parts[GearSlot.CHEST]
            val weight = chest?.weight
            val robe = (chest == null && look.robe) || weight == Weight.CLOTH
            val legs = parts[GearSlot.LEGS]
            val heavy = weight == Weight.HEAVY
            val medium = weight == Weight.MEDIUM

            // ---- legs, stance slightly apart, the right foot forward towards the foe
            val shin = if (legs?.icon == Icon.LEGS && legs.weight == Weight.HEAVY) metal(legs.rarity) else pantsMat
            val boot = when {
                legs?.icon == Icon.BOOTS && legs.weight == Weight.HEAVY -> darkSteel
                else -> darkLeather
            }
            s.limb(44.0, 74.0, 39.0, 97.0, 5.8, 4.5, pantsMat)
            s.limb(40.0, 97.0, 38.5, 117.0, 4.2, 3.2, shin)
            s.limb(55.0, 74.0, 60.0, 95.0, 5.8, 4.5, pantsMat.copy(bias = -0.08))
            s.limb(59.0, 96.0, 61.5, 116.0, 4.2, 3.2, shin.copy(bias = -0.08))
            for ((x, y) in listOf(38.5 to 117.0, 61.5 to 116.0)) {
                s.limb(x, y - 9, x, y + 2, 3.9, 3.7, boot)
                s.blob(x + 1.0, y + 4.5, 4.8, 3.0, boot)
                s.limb(x - 3.8, y - 9, x + 3.8, y - 9, 0.9, 0.9, leather) // boot cuff
            }

            // ---- robe or tunic skirt
            if (robe) {
                s.poly(cloth, 35.0, 60.0, 63.0, 60.0, 68.0 + c, 118.0, 58.0 + c, 120.0, 49.0 + c, 117.0, 40.0 + c, 120.0, 30.0 + c, 118.0, tiltY = -0.12)
                for (x in listOf(42.0, 50.0, 57.0)) s.line(x, 70.0, x + (x - 49) * 0.4 + c, 116.0, Ramp.of(worn(look.cloth))[1])
            } else if (medium || heavy) {
                // mail skirt under the belt
                val mail = if (heavy) metal(chest!!.rarity) else m(argb(0x8A9098), shine = 0.4, grain = 0.4)
                s.poly(mail, 37.0, 66.0, 61.0, 66.0, 63.0, 84.0, 35.0, 84.0, tiltY = -0.2)
                if (heavy) for (k in 0..2) s.limb(37.5, 70.0 + k * 5, 60.5, 70.0 + k * 5, 1.3, 1.3, metal(chest!!.rarity))
            } else {
                s.poly(m(worn(look.clothDark, 0.4), grain = 0.05), 37.0, 64.0, 61.0, 64.0, 62.0, 80.0, 36.0, 80.0, tiltY = -0.2)
            }

            // ---- torso (the back)
            val torso = when {
                heavy -> metal(chest!!.rarity)
                medium -> m(argb(0x8A9098), shine = 0.45, grain = 0.45)
                weight == Weight.LIGHT -> leather
                else -> cloth
            }
            s.blob(49.0, 50.0 + b * 0.3, 14.5, 17.0, torso)
            s.blob(49.0, 64.0, 11.5, 6.0, torso)
            if (heavy) {
                // back plate seam and rivets
                s.line(49.0, 38.0, 49.0, 62.0, Ramp.of(argb(0x6E7680))[1])
                for (y in listOf(42.0, 50.0, 58.0)) { s.dot(41.0, y, argb(0xD0D4D8)); s.dot(57.0, y, argb(0xD0D4D8)) }
            }
            if (weight == Weight.LIGHT) {
                // laces and a seam down the leather jerkin
                s.line(49.0, 38.0, 49.0, 64.0, Ramp.of(argb(0x6A4A32))[0])
                for (k in 0..4) s.line(47.0, 42.0 + k * 4, 51.0, 44.0 + k * 4, argb(0x2A1C14))
            }
            // belt with buckle, a pouch on the right hip and a knife at the back
            s.limb(36.0, 67.0, 62.0, 67.0, 2.1, 2.1, darkLeather)
            s.blob(58.5, 71.0, 3.6, 4.2, leather)
            s.line(56.0, 69.0, 61.0, 69.0, argb(0x2A1C14))
            if (cls == CharClass.ROGUE) {
                s.limb(43.0, 66.0, 52.0, 72.0, 1.2, 1.0, darkLeather)
                s.limb(52.0, 72.0, 56.0, 74.5, 0.8, 0.5, steel)
            }

            // ---- cloak
            parts[GearSlot.CLOAK]?.let { cl ->
                val col = cloakColor(cl.rarity)
                val sway = c * 1.4 + (if (atk) -4.0 else 0.0)
                // rounded folds side by side: each catches the light like a tube of cloth
                val folds = 6
                for (k in 0 until folds) {
                    val t = k / (folds - 1.0)
                    val topX = 39.0 + t * 20.0
                    val botX = 33.0 + t * 32.0 + sway * (0.5 + t)
                    val hem = 98.0 + (if (k % 2 == 0) 2.5 else 0.0) + sway * 0.3
                    val bias = if (k % 2 == 0) 0.04 else -0.1
                    s.limb(topX, 40.0, botX, hem, 3.6, 4.4, m(col, grain = 0.03).copy(bias = bias))
                }
                // the cloak hangs from a collar over the shoulders
                s.blob(49.0, 38.0, 12.0, 5.0, m(col, grain = 0.03))
                s.limb(43.0, 37.0, 55.0, 37.0, 1.0, 1.0, if (cl.rarity >= Rarity.EPIC) gold else darkLeather)
            }

            // ---- shoulders
            val pauldron = when {
                heavy -> metal(chest!!.rarity)
                medium -> leather
                else -> torso
            }
            s.blob(35.5, 39.0, if (heavy) 7.5 else 5.5, if (heavy) 6.0 else 4.8, pauldron)
            s.blob(62.5, 39.0, if (heavy) 7.5 else 5.5, if (heavy) 6.0 else 4.8, pauldron)

            head()
            arms(torso, heavy || medium)
        }

        fun head() {
            val hy = 25.0 + b * 0.35
            val k = headBig
            s.limb(49.0, 31.0, 49.0, 35.0, 3.4 * k, 3.8, skin)
            // a glimpse of the cheek and jaw: the hero looks to the upper right
            s.blob(54.5, hy + 3.5, 3.0 * k, 4.0 * k, skin)
            when (race) {
                Race.ELF -> s.poly(skin, 56.0, hy + 1, 64.0, hy - 6, 56.5, hy + 4)
                else -> s.blob(56.8, hy + 1.5, 1.8, 2.6, skin)
            }
            s.blob(41.2, hy + 1.5, 1.6, 2.4, skin)
            // hair from behind
            s.blob(48.5, hy, 7.2 * k, 8.0 * k, hair)
            when (race) {
                Race.ELF -> s.chain(hair, 48.5, hy + 2, 6.0, 48.0, hy + 10, 4.6, 47.5, hy + 17, 3.0, 47.0, hy + 22, 1.2)
                Race.DWARF -> {
                    // braids and the beard showing on both sides
                    s.limb(41.0, hy + 6, 39.0, hy + 16, 2.2, 1.6, hair); s.limb(57.0, hy + 6, 59.5, hy + 16, 2.2, 1.6, hair)
                    s.blob(39.0, hy + 17, 1.4, 1.4, gold); s.blob(59.5, hy + 17, 1.4, 1.4, gold)
                }
                Race.HALF_ORC -> s.limb(48.5, hy - 7, 48.0, hy - 13, 2.4, 1.6, hair)
                Race.HALFLING -> for ((dx, dy) in listOf(-5.0 to -3.0, 0.0 to -6.0, 5.0 to -3.0, -6.0 to 2.0, 6.0 to 2.0)) s.blob(48.5 + dx, hy + dy, 2.8, 2.8, hair)
                else -> {}
            }
            val head = parts[GearSlot.HEAD]
            val headgear = when (head?.icon) {
                Icon.HELMET -> Headgear.HELMET
                Icon.HOOD -> Headgear.HOOD
                Icon.CIRCLET -> Headgear.CIRCLET
                else -> look.headgear
            }
            val r = head?.rarity ?: Rarity.COMMON
            when (headgear) {
                Headgear.HELMET -> {
                    val great = head?.base == "great_helm"
                    val hm = if (head?.weight == Weight.LIGHT) leather else metal(r)
                    if (great) {
                        s.blob(48.5, hy, 8.6 * k, 9.4 * k, hm)
                        s.limb(40.5, hy + 6, 57.0, hy + 6, 1.4, 1.4, hm)
                    } else {
                        s.blob(48.5, hy - 2, 8.2 * k, 7.6 * k, hm)
                        s.limb(40.8, hy + 2.5, 56.5, hy + 2.5, 1.2, 1.2, hm)
                        s.line(48.5, hy - 9, 48.5, hy + 2, Ramp.of(argb(0x6E7680))[1])
                    }
                }
                Headgear.HOOD -> {
                    val hm = m(if (head == null) worn(look.cloth) else cloakColor(r), grain = 0.04)
                    s.blob(48.5, hy, 8.8 * k, 9.2 * k, hm)
                    s.poly(hm, 40.0, hy + 3, 57.0, hy + 3, 58.0, hy + 14, 39.0, hy + 14)
                    s.line(48.5, hy - 6, 48.5, hy + 12, Ramp.of(worn(look.cloth))[1])
                }
                Headgear.CIRCLET -> s.limb(41.0, hy - 1, 56.0, hy - 1, 0.9, 0.9, if (r >= Rarity.RARE) metal(r) else gold)
                Headgear.HAT -> {
                    val hm = m(worn(look.cloth), grain = 0.03)
                    s.blob(48.5, hy - 3, 14.0, 4.0, hm)
                    s.poly(hm, 41.0, hy - 4, 56.0, hy - 4, 54.0 + c, hy - 18, 50.0 + c * 1.5, hy - 25, 46.0 + c, hy - 20)
                    s.limb(41.5, hy - 4.5, 55.5, hy - 4.5, 1.0, 1.0, gold)
                }
                else -> {}
            }
        }

        fun arms(torso: Mat, armored: Boolean) {
            val gloves = parts[GearSlot.ARMS]
            val hand = when {
                gloves == null -> skin
                gloves.weight == Weight.HEAVY || gloves.weight == Weight.MEDIUM -> darkSteel
                else -> leather
            }
            val sleeve = if (look.robe && parts[GearSlot.CHEST]?.weight in listOf(null, Weight.CLOTH)) clothDark else torso
            // left arm: holds the shield, the bow or the focus
            val lh = if (atk) Pair(25.0, 60.0) else Pair(31.5, 74.0 + b * 0.4)
            val le = if (atk) Pair(28.0, 53.0) else Pair(30.0, 57.0)
            s.limb(35.0, 41.0, le.first, le.second, 5.0, 4.0, sleeve)
            s.limb(le.first, le.second, lh.first, lh.second, 4.0, 3.2, if (gloves != null) hand else sleeve)
            offHand(lh, hand)
            // right arm: the weapon, raised against the foe when striking
            val re = when (act) { Act.ATTACK -> Pair(71.0, 33.0); Act.HURT -> Pair(67.0, 56.0); Act.IDLE -> Pair(69.0, 55.0 + b * 0.3) }
            val rh = when (act) { Act.ATTACK -> Pair(81.0, 21.0); Act.HURT -> Pair(69.0, 70.0); Act.IDLE -> Pair(70.0, 69.0 + b * 0.4) }
            mainHand(rh)
            s.limb(63.0, 41.0, re.first, re.second, 5.0, 4.0, sleeve.copy(bias = -0.05))
            s.limb(re.first, re.second, rh.first, rh.second, 4.0, 3.2, if (gloves != null) hand else sleeve)
            s.blob(rh.first, rh.second, 3.0, 3.0, hand)
            if (armored && gloves != null) s.limb(re.first, re.second, (re.first + rh.first) / 2, (re.second + rh.second) / 2, 3.9, 3.6, hand)
        }

        fun offHand(lh: Pair<Double, Double>, hand: Mat) {
            val p = parts[GearSlot.OFF_HAND]
            val main = parts[GearSlot.MAIN_HAND]
            if (main?.ranged == true) bow(lh.first - 2, lh.second - 8, main.rarity)
            s.blob(lh.first, lh.second, 3.0, 3.0, hand)
            when {
                p == null -> {}
                p.kind == BaseKind.SHIELD -> {
                    // seen from behind: the inside of the shield, planks, straps and the metal rim
                    val tower = p.base == "tower_shield"
                    val x0 = lh.first - (if (tower) 16.0 else 13.0); val x1 = lh.first + (if (tower) 7.0 else 6.0)
                    val y0 = lh.second - (if (tower) 26.0 else 18.0); val y1 = lh.second + (if (tower) 16.0 else 10.0)
                    val rim = metal(p.rarity)
                    s.poly(rim, x0, y0, x1, y0 + 2, x1, y1 - 6, (x0 + x1) / 2, y1 + 4, x0, y1 - 6, tiltX = -0.4, bevel = 1.5)
                    s.poly(wood, x0 + 1.8, y0 + 2, x1 - 1.8, y0 + 3.8, x1 - 1.8, y1 - 6.5, (x0 + x1) / 2, y1 + 1.5, x0 + 1.8, y1 - 6.5, tiltX = -0.4, bevel = 0.8)
                    var x = x0 + 5.0
                    while (x < x1 - 2) { s.line(x, y0 + 3, x, y1 - 2, Ramp.of(argb(0x6E4A2C))[0]); x += 4.5 }
                    s.limb(x0 + 3, lh.second - 6, x1 - 3, lh.second - 5, 1.2, 1.2, darkLeather)
                    s.limb(x0 + 3, lh.second + 1, x1 - 3, lh.second + 2, 1.2, 1.2, darkLeather)
                    s.blob(lh.first, lh.second, 3.0, 3.0, hand)
                }
                p.icon == Icon.ORB -> {
                    val g = mix(argb(0x80C8FF), p.rarity.color.toInt(), 0.4)
                    s.flat(lh.first - 1, lh.second - 6, 6.0 + b * 0.4, 6.0 + b * 0.4, alpha(g, 80))
                    s.blob(lh.first - 1, lh.second - 6, 4.0, 4.0, m(g, shine = 1.0).copy(inline = false))
                }
                p.icon == Icon.TOME -> {
                    s.poly(m(worn(mix(argb(0x6A2A22), p.rarity.color.toInt(), 0.3), 0.2)), lh.first - 7, lh.second - 8, lh.first + 4, lh.second - 8, lh.first + 4, lh.second + 4, lh.first - 7, lh.second + 4)
                    s.line(lh.first - 1.5, lh.second - 8, lh.first - 1.5, lh.second + 4, argb(0xB8904A))
                }
                p.icon == Icon.SYMBOL -> {
                    s.limb(lh.first, lh.second, lh.first, lh.second + 6, 0.5, 0.5, darkLeather)
                    s.blob(lh.first, lh.second + 7, 2.6, 2.6, gold)
                    s.flat(lh.first, lh.second + 7, 1.0, 1.0, argb(0xF8F0D8))
                }
                p.kind == BaseKind.WEAPON -> weapon(p, lh.first, lh.second, if (atk) -110.0 else -130.0)
                else -> {}
            }
        }

        fun mainHand(rh: Pair<Double, Double>) {
            val p = parts[GearSlot.MAIN_HAND] ?: return
            if (p.ranged) {
                if (atk) s.limb(rh.first - 8, rh.second + 8, rh.first - 40, rh.second + 20, 0.6, 0.6, wood)
                return
            }
            val deg = when (act) { Act.ATTACK -> -35.0; Act.HURT -> -100.0; Act.IDLE -> -58.0 + c * 2 }
            weapon(p, rh.first, rh.second, deg)
        }

        fun bow(x: Double, y: Double, r: Rarity) {
            val bw = m(mix(argb(0x5E3E24), r.color.toInt(), if (r >= Rarity.RARE) 0.3 else 0.0), grain = 0.05)
            s.chain(bw, x + 4, y - 22, 1.2, x, y - 11, 1.9, x - 1.5, y, 2.2, x, y + 11, 1.9, x + 4, y + 22, 1.2)
            val pull = if (atk) 14.0 else 3.0
            s.line(x + 4, y - 22, x + 4 + pull, y, argb(0xD8D0C0)); s.line(x + 4 + pull, y, x + 4, y + 22, argb(0xD8D0C0))
        }

        fun weapon(p: Part, hx: Double, hy: Double, deg: Double) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a)
            val met = metal(p.rarity)
            val long = if (p.twoHanded) 1.35 else 1.0
            fun along(d: Double) = Pair(hx + dx * d, hy + dy * d)
            when (p.icon) {
                Icon.SWORD, Icon.DAGGER -> {
                    val len = (if (p.icon == Icon.DAGGER) 14.0 else 28.0) * long
                    s.limb(hx - dx * 6, hy - dy * 6, hx + dx, hy + dy, 1.4, 1.4, darkLeather)
                    s.blob(hx - dx * 7, hy - dy * 7, 1.8, 1.8, gold)
                    s.limb(hx + dy * 5, hy - dx * 5, hx - dy * 5, hy + dx * 5, 1.2, 1.2, darkSteel)
                    blade(hx + dx * 2, hy + dy * 2, deg, len, if (p.twoHanded) 3.2 else 2.5, met)
                }
                Icon.AXE -> {
                    val (ex, ey) = along(24.0 * long)
                    s.limb(hx - dx * 8, hy - dy * 8, ex, ey, 1.5, 1.4, wood)
                    val px = -dy; val py = dx
                    val w = if (p.twoHanded) 1.6 else 1.15
                    s.poly(met, ex - dx * 3, ey - dy * 3, ex + px * 12 * w - dx * 7 * w, ey + py * 12 * w - dy * 7 * w,
                        ex + px * 13 * w + dx * 6 * w, ey + py * 13 * w + dy * 6 * w, ex + dx * 3, ey + dy * 3, bevel = 1.6)
                }
                Icon.MACE, Icon.HAMMER -> {
                    val (ex, ey) = along(22.0 * long)
                    s.limb(hx - dx * 6, hy - dy * 6, ex, ey, 1.5, 1.4, wood)
                    if (p.icon == Icon.MACE) {
                        s.blob(ex, ey, 5.0 * long, 5.0 * long, met)
                        for (k in 0 until 6) {
                            val sa = k * 60.0 + deg
                            s.limb(ex, ey, Sculpt.polarX(ex, 7.5 * long, sa), Sculpt.polarY(ey, 7.5 * long, sa), 1.3, 0.5, met)
                        }
                    } else {
                        val px = -dy; val py = dx
                        val w = 4.5 * long; val h = 9.0 * long
                        s.poly(met, ex + px * h - dx * w, ey + py * h - dy * w, ex + px * h + dx * w, ey + py * h + dy * w,
                            ex - px * h + dx * w, ey - py * h + dy * w, ex - px * h - dx * w, ey - py * h - dy * w, bevel = 1.8)
                    }
                }
                Icon.SPEAR -> {
                    val (ex, ey) = along(38.0)
                    s.limb(hx - dx * 16, hy - dy * 16, ex, ey, 1.3, 1.3, wood)
                    blade(ex, ey, deg, 10.0, 2.6, met)
                }
                Icon.STAFF, Icon.WAND -> {
                    val len = if (p.icon == Icon.STAFF) 38.0 else 15.0
                    val (ex, ey) = along(len)
                    s.limb(hx - dx * (if (p.icon == Icon.STAFF) 22.0 else 3.0), hy - dy * (if (p.icon == Icon.STAFF) 22.0 else 3.0), ex, ey,
                        if (p.icon == Icon.STAFF) 1.7 else 1.1, if (p.icon == Icon.STAFF) 2.0 else 0.9, wood)
                    val g = mix(argb(0x80E0FF), p.rarity.color.toInt(), 0.5)
                    val r = (if (p.icon == Icon.STAFF) 3.4 else 2.0) + (if (atk) 1.5 else b * 0.4)
                    s.flat(ex, ey, r + 3, r + 3, alpha(g, 80))
                    s.blob(ex, ey, r, r, m(g, shine = 1.0).copy(inline = false))
                }
                else -> s.limb(hx - dx * 6, hy - dy * 6, hx + dx * 18, hy + dy * 18, 1.5, 1.5, wood)
            }
        }

        fun blade(hx: Double, hy: Double, deg: Double, len: Double, wid: Double, mat: Mat) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a); val px = -dy; val py = dx
            s.poly(mat,
                hx + px * wid, hy + py * wid,
                hx + dx * len * 0.86 + px * wid * 0.8, hy + dy * len * 0.86 + py * wid * 0.8,
                hx + dx * len, hy + dy * len,
                hx + dx * len * 0.86 - px * wid * 0.8, hy + dy * len * 0.86 - py * wid * 0.8,
                hx - px * wid, hy - py * wid,
                tiltX = 0.25, tiltY = -0.4, bevel = 1.0)
            s.line(hx + dx * 1, hy + dy * 1, hx + dx * len * 0.82, hy + dy * len * 0.82, mat.ramp.light)
        }
    }
}
