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
 * The hero in battle, 64×64 and seen from behind, wearing what is actually equipped: helmet,
 * armor, cloak, gloves, boots and both hands. Rare weapons take on the color of their rarity.
 */
object HeroArt {
    const val SIZE = 64

    private val cache = object : LinkedHashMap<String, PixelImage>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 40
    }

    /** What is drawn for one slot. */
    private data class Part(val icon: Icon, val rarity: Rarity, val weight: Weight, val kind: BaseKind, val twoHanded: Boolean, val ranged: Boolean)

    private fun part(g: Gear?) = g?.def?.let { Part(it.icon, g.rarity, it.weight, it.kind, it.twoHanded, it.ranged) }

    fun battle(hero: Hero, pose: Pose, idleFrame: Int = 0): PixelImage {
        val parts = GearSlot.entries.associateWith { part(hero.item(it)) }
        val f = if (pose == Pose.IDLE) idleFrame.mod(MonsterArt.IDLE_FRAMES) else 0
        val key = "${hero.race}/${hero.cls}/$pose/$f/" + parts.values.joinToString(",")
        synchronized(cache) { cache[key]?.let { return it } }
        val s = Sculpt(SIZE, SIZE, 11)
        Painter(s, hero.race, hero.cls, parts, pose, f).draw()
        s.transform()
        s.rim(argb(0xFFF0C8), 0.3)
        s.outline()
        synchronized(cache) { cache[key] = s.img }
        return s.img
    }

    private class Painter(val s: Sculpt, val race: Race, val cls: CharClass, val parts: Map<GearSlot, Part?>, val pose: Pose, frame: Int) {
        val look = CharacterArt.heroLook(race, cls)
        val ph = frame / MonsterArt.IDLE_FRAMES.toDouble() * 2 * PI
        val b = if (pose == Pose.IDLE) sin(ph) else 0.0
        val c = if (pose == Pose.IDLE) cos(ph) else 0.0
        val atk = pose == Pose.ATTACK
        val hurt = pose == Pose.HURT

        fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(rgb), shine, grain)

        val skin = m(look.skin)
        val hair = m(look.hair, grain = 0.12)
        val leather = m(argb(0x7A5030), grain = 0.06)
        val darkLeather = m(argb(0x4A3226), grain = 0.05)
        val steel = m(argb(0xB8C2CE), shine = 0.8)
        val gold = m(argb(0xE0B040), shine = 0.8)
        val wood = m(argb(0x8A5A30), grain = 0.1)

        fun armorMat(p: Part?, cloth: Int): Mat = when (p?.weight) {
            Weight.LIGHT -> m(argb(0x8A5A34), grain = 0.08)
            Weight.MEDIUM -> m(argb(0x9AA4B0), shine = 0.5, grain = 0.3)
            Weight.HEAVY -> m(argb(0xB8C2CE), shine = 0.85)
            else -> m(cloth, grain = 0.04)
        }

        /** Metal tinted towards the item's rarity, so a divine sword glows golden. */
        fun metal(r: Rarity): Mat {
            val tint = when (r) {
                Rarity.COMMON, Rarity.UNCOMMON -> 0.0
                Rarity.RARE -> 0.3
                Rarity.VERY_RARE -> 0.4
                Rarity.EPIC, Rarity.DIVINE -> 0.5
            }
            return m(mix(argb(0xC0CAD6), r.color.toInt(), tint), shine = 0.9)
        }

        fun cloakColor(r: Rarity) = argb(
            when (r) {
                Rarity.COMMON -> 0x6A5040
                Rarity.UNCOMMON -> 0x3A7A44
                Rarity.RARE -> 0x3A5AB0
                Rarity.VERY_RARE -> 0x6A3AA0
                Rarity.EPIC -> 0xB04A20
                Rarity.DIVINE -> 0xE8D8A0
            },
        )

        fun draw() {
            val scale = when (race) {
                Race.HALFLING -> 0.84
                Race.DWARF -> 0.9
                else -> 1.0
            }
            val wide = if (race == Race.DWARF || race == Race.HALF_ORC) 1.08 else 1.0
            val lean = if (atk) 2.0 else if (hurt) -2.0 else 0.0
            s.transform(lean, if (hurt) 1.0 else 0.0, scale * wide, scale * (1 + b * 0.012), 32.0, 62.0)

            val chest = parts[GearSlot.CHEST]
            val robe = (chest == null && look.robe) || chest?.weight == Weight.CLOTH
            val body = armorMat(chest, look.cloth)
            val legsPart = parts[GearSlot.LEGS]
            val pants = if (legsPart != null && legsPart.icon == Icon.LEGS) armorMat(legsPart, look.pants) else m(look.pants, grain = 0.04)
            val boots = when {
                legsPart?.icon == Icon.BOOTS && legsPart.weight == Weight.HEAVY -> steel
                legsPart?.icon == Icon.BOOTS -> leather
                else -> darkLeather
            }

            // legs and boots
            s.limb(27.0, 45.0, 26.0, 58.0, 3.6, 3.0, pants)
            s.limb(37.0, 45.0, 38.0, 58.0, 3.6, 3.0, pants)
            s.blob(26.0, 59.5, 3.8, 2.4, boots)
            s.blob(38.0, 59.5, 3.8, 2.4, boots)
            // torso
            s.blob(32.0, 35.0 + b * 0.3, 10.5, 11.0, body)
            if (robe) s.poly(m(look.cloth, grain = 0.04), 22.0, 40.0, 42.0, 40.0, 45.0, 58.0, 19.0, 58.0, tiltY = -0.1)
            s.limb(22.0, 44.0, 42.0, 44.0, 1.4, 1.4, leather)
            // cloak over the back
            parts[GearSlot.CLOAK]?.let { cl ->
                val cm = m(cloakColor(cl.rarity), grain = 0.03)
                val sway = c * 1.2
                s.poly(cm, 23.0, 25.0, 41.0, 25.0, 46.0 + sway, 57.0, 39.0 + sway, 58.5, 32.0 + sway, 57.0, 25.0 + sway, 58.5, 18.0 + sway, 57.0, tiltY = -0.15)
                s.line(29.0, 30.0, 27.0 + sway, 56.0, Ramp.of(cloakColor(cl.rarity))[1])
                s.line(36.0, 30.0, 38.0 + sway, 56.0, Ramp.of(cloakColor(cl.rarity))[1])
                if (cl.rarity >= Rarity.EPIC) s.limb(23.0, 26.0, 41.0, 26.0, 1.0, 1.0, gold)
            }
            // shoulders
            val heavy = chest?.weight == Weight.HEAVY || chest?.weight == Weight.MEDIUM
            s.blob(22.5, 28.0, 4.6, 4.0, if (heavy) steel else body)
            s.blob(41.5, 28.0, 4.6, 4.0, if (heavy) steel else body)

            // head
            s.limb(32.0, 24.0, 32.0, 27.0, 2.8, 3.0, skin)
            val hy = 17.0 + b * 0.4
            when (race) {
                Race.ELF -> {
                    s.poly(skin, 25.0, hy, 19.0, hy - 6, 25.5, hy + 3)
                    s.poly(skin, 39.0, hy, 45.0, hy - 6, 38.5, hy + 3)
                }
                else -> {
                    s.blob(24.6, hy + 1, 1.8, 2.4, skin)
                    s.blob(39.4, hy + 1, 1.8, 2.4, skin)
                }
            }
            s.blob(32.0, hy, 7.5, 7.8, hair)
            if (race == Race.DWARF) {
                s.blob(26.0, hy + 7, 2.2, 2.8, hair)
                s.blob(38.0, hy + 7, 2.2, 2.8, hair)
            }
            if (race == Race.HALF_ORC) s.limb(32.0, hy - 7, 32.0, hy - 11, 2.0, 1.4, hair)
            val head = parts[GearSlot.HEAD]?.icon
            val headgear = when (head) {
                Icon.HELMET -> Headgear.HELMET
                Icon.HOOD -> Headgear.HOOD
                Icon.CIRCLET -> Headgear.CIRCLET
                else -> look.headgear
            }
            val headRarity = parts[GearSlot.HEAD]?.rarity ?: Rarity.COMMON
            when (headgear) {
                Headgear.HELMET -> {
                    val hm = if (parts[GearSlot.HEAD]?.weight == Weight.LIGHT) leather else metal(headRarity)
                    s.blob(32.0, hy - 1.5, 8.6, 7.5, hm)
                    s.limb(23.5, hy + 2.5, 40.5, hy + 2.5, 1.2, 1.2, hm)
                    if (head == null || parts[GearSlot.HEAD]?.weight == Weight.HEAVY) s.limb(32.0, hy - 9, 32.0, hy + 1, 1.0, 1.0, gold)
                }
                Headgear.HOOD -> {
                    val hm = m(if (head == null) look.cloth else cloakColor(headRarity), grain = 0.04)
                    s.blob(32.0, hy, 8.8, 8.8, hm)
                    s.poly(hm, 24.0, hy + 3, 40.0, hy + 3, 38.0, hy + 11, 26.0, hy + 11)
                }
                Headgear.CIRCLET -> s.limb(24.5, hy - 1, 39.5, hy - 1, 1.0, 1.0, if (headRarity >= Rarity.RARE) metal(headRarity).copy(ramp = Ramp.of(mix(argb(0xE0B040), headRarity.color.toInt(), 0.3))) else gold)
                Headgear.HAT -> {
                    val hm = m(look.cloth, grain = 0.03)
                    s.blob(32.0, hy - 2, 13.0, 3.5, hm)
                    s.poly(hm, 25.0, hy - 3, 39.0, hy - 3, 36.0 + c, hy - 17, 33.0 + c * 1.5, hy - 21)
                    s.limb(25.5, hy - 3.5, 38.5, hy - 3.5, 1.0, 1.0, gold)
                }
                else -> {}
            }

            // arms and hands
            val arms = parts[GearSlot.ARMS]
            val hand = when {
                arms == null -> skin
                arms.weight == Weight.HEAVY || arms.weight == Weight.MEDIUM -> steel
                else -> leather
            }
            val sleeve = if (heavy) steel else body
            val lh = if (atk) Pair(17.0, 38.0) else Pair(18.5, 41.0 + b * 0.4)
            val rh = when (pose) {
                Pose.ATTACK -> Pair(50.0, 22.0)
                Pose.HURT -> Pair(45.0, 43.0)
                Pose.IDLE -> Pair(46.5, 41.0 + b * 0.4)
            }
            offHand(lh, sleeve, hand)
            s.limb(42.0, 29.0, rh.first, rh.second, 3.0, 2.6, sleeve)
            mainHand(rh)
            s.blob(rh.first, rh.second, 2.5, 2.4, hand)
            if (arms != null) s.limb(rh.first - (rh.first - 42) * 0.25, rh.second - (rh.second - 29) * 0.25, rh.first, rh.second, 2.9, 2.6, hand)
        }

        fun offHand(lh: Pair<Double, Double>, sleeve: Mat, hand: Mat) {
            val p = parts[GearSlot.OFF_HAND]
            val main = parts[GearSlot.MAIN_HAND]
            s.limb(22.0, 29.0, lh.first, lh.second, 3.0, 2.6, sleeve)
            if (main?.ranged == true) {
                // the bow is held out in the left hand
                bow(lh.first - 1, lh.second - 4, main.rarity)
            }
            s.blob(lh.first, lh.second, 2.5, 2.4, hand)
            when {
                p == null -> {}
                p.kind == BaseKind.SHIELD -> {
                    val rim = metal(p.rarity)
                    s.poly(rim, 9.0, 33.0, 22.0, 33.0, 22.0, 43.0, 15.5, 51.0, 9.0, 43.0, tiltX = -0.3, bevel = 1.5)
                    s.poly(if (p.rarity >= Rarity.RARE) m(mix(argb(0x8A3A2A), p.rarity.color.toInt(), 0.5)) else wood,
                        10.5, 34.5, 20.5, 34.5, 20.5, 42.5, 15.5, 49.0, 10.5, 42.5, tiltX = -0.3, bevel = 1.0)
                    s.blob(15.5, 40.0, 1.6, 1.6, gold)
                }
                p.icon == Icon.ORB -> {
                    val g = mix(argb(0x80C8FF), p.rarity.color.toInt(), 0.4)
                    s.flat(lh.first - 1, lh.second - 5, 4.5 + b * 0.3, 4.5 + b * 0.3, alpha(g, 90))
                    s.blob(lh.first - 1, lh.second - 5, 3.0, 3.0, m(g, shine = 1.0).copy(inline = false))
                }
                p.icon == Icon.TOME || p.icon == Icon.SYMBOL -> {
                    if (p.icon == Icon.TOME) {
                        s.poly(m(mix(argb(0x7A2A2A), p.rarity.color.toInt(), 0.3)), lh.first - 5, lh.second - 6, lh.first + 3, lh.second - 6, lh.first + 3, lh.second + 3, lh.first - 5, lh.second + 3)
                        s.line(lh.first - 1, lh.second - 6, lh.first - 1, lh.second + 3, Pal.GOLD)
                    } else {
                        s.blob(lh.first - 1, lh.second - 4, 3.0, 3.0, gold)
                        s.flat(lh.first - 1, lh.second - 4, 1.2, 1.2, Pal.WHITE)
                    }
                }
                p.kind == BaseKind.WEAPON -> weapon(p, lh.first, lh.second, if (atk) -110.0 else -125.0)
                else -> {}
            }
        }

        fun mainHand(rh: Pair<Double, Double>) {
            val p = parts[GearSlot.MAIN_HAND] ?: return
            if (p.ranged) {
                if (atk) {
                    // drawing an arrow
                    s.limb(rh.first - 6, rh.second + 6, rh.first - 30, rh.second + 14, 0.5, 0.5, wood)
                }
                return
            }
            val deg = when (pose) {
                Pose.ATTACK -> -25.0
                Pose.HURT -> -95.0
                Pose.IDLE -> -62.0 + c * 2
            }
            weapon(p, rh.first, rh.second, deg)
        }

        fun bow(x: Double, y: Double, r: Rarity) {
            val bw = m(mix(argb(0x7A4A28), r.color.toInt(), if (r >= Rarity.RARE) 0.35 else 0.0), grain = 0.05)
            s.chain(bw, x + 3, y - 14, 1.0, x, y - 7, 1.5, x - 1, y, 1.7, x, y + 7, 1.5, x + 3, y + 14, 1.0)
            val pull = if (atk) 9.0 else 2.0
            s.line(x + 3, y - 14, x + 3 + pull, y, argb(0xE8E0D0)); s.line(x + 3 + pull, y, x + 3, y + 14, argb(0xE8E0D0))
        }

        fun weapon(p: Part, hx: Double, hy: Double, deg: Double) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a)
            val met = metal(p.rarity)
            val long = if (p.twoHanded) 1.35 else 1.0
            fun along(d: Double) = Pair(hx + dx * d, hy + dy * d)
            when (p.icon) {
                Icon.SWORD, Icon.DAGGER -> {
                    val len = (if (p.icon == Icon.DAGGER) 9.0 else 17.0) * long
                    s.limb(hx - dx * 4, hy - dy * 4, hx + dx, hy + dy, 1.1, 1.1, darkLeather)
                    s.limb(hx + dy * 3.5, hy - dx * 3.5, hx - dy * 3.5, hy + dx * 3.5, 1.0, 1.0, gold)
                    blade(hx + dx * 1.5, hy + dy * 1.5, deg, len, if (p.twoHanded) 2.4 else 1.9, met)
                }
                Icon.AXE -> {
                    val (ex, ey) = along(15.0 * long)
                    s.limb(hx - dx * 5, hy - dy * 5, ex, ey, 1.1, 1.1, wood)
                    val px = -dy; val py = dx
                    val w = if (p.twoHanded) 1.4 else 1.0
                    s.poly(met, ex - dx * 2, ey - dy * 2, ex + px * 8 * w - dx * 5 * w, ey + py * 8 * w - dy * 5 * w,
                        ex + px * 9 * w + dx * 4 * w, ey + py * 9 * w + dy * 4 * w, ex + dx * 2, ey + dy * 2, bevel = 1.4)
                }
                Icon.MACE, Icon.HAMMER -> {
                    val (ex, ey) = along(14.0 * long)
                    s.limb(hx - dx * 4, hy - dy * 4, ex, ey, 1.1, 1.1, wood)
                    if (p.icon == Icon.MACE) {
                        s.blob(ex, ey, 3.6 * long, 3.6 * long, met)
                        for (k in 0 until 6) {
                            val sa = k * 60.0 + deg
                            s.limb(ex, ey, Sculpt.polarX(ex, 5.0 * long, sa), Sculpt.polarY(ey, 5.0 * long, sa), 1.0, 0.4, met)
                        }
                    } else {
                        val px = -dy; val py = dx
                        val w = 3.0 * long; val h = 6.0 * long
                        s.poly(met, ex + px * h - dx * w, ey + py * h - dy * w, ex + px * h + dx * w, ey + py * h + dy * w,
                            ex - px * h + dx * w, ey - py * h + dy * w, ex - px * h - dx * w, ey - py * h - dy * w, bevel = 1.6)
                    }
                }
                Icon.SPEAR -> {
                    val (ex, ey) = along(24.0)
                    s.limb(hx - dx * 10, hy - dy * 10, ex, ey, 1.0, 1.0, wood)
                    blade(ex, ey, deg, 7.0, 2.0, met)
                }
                Icon.STAFF, Icon.WAND -> {
                    val len = if (p.icon == Icon.STAFF) 24.0 else 10.0
                    val (ex, ey) = along(len)
                    s.limb(hx - dx * (if (p.icon == Icon.STAFF) 12.0 else 2.0), hy - dy * (if (p.icon == Icon.STAFF) 12.0 else 2.0), ex, ey,
                        if (p.icon == Icon.STAFF) 1.3 else 0.9, if (p.icon == Icon.STAFF) 1.5 else 0.7, wood)
                    val g = mix(argb(0x80E0FF), p.rarity.color.toInt(), 0.5)
                    val r = (if (p.icon == Icon.STAFF) 2.6 else 1.6) + (if (atk) 1.2 else b * 0.3)
                    s.flat(ex, ey, r + 2, r + 2, alpha(g, 90))
                    s.blob(ex, ey, r, r, m(g, shine = 1.0).copy(inline = false))
                }
                else -> {
                    s.limb(hx - dx * 4, hy - dy * 4, hx + dx * 12, hy + dy * 12, 1.2, 1.2, wood)
                }
            }
        }

        fun blade(hx: Double, hy: Double, deg: Double, len: Double, wid: Double, mat: Mat) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a); val px = -dy; val py = dx
            s.poly(mat,
                hx + px * wid, hy + py * wid,
                hx + dx * len * 0.85 + px * wid * 0.8, hy + dy * len * 0.85 + py * wid * 0.8,
                hx + dx * len, hy + dy * len,
                hx + dx * len * 0.85 - px * wid * 0.8, hy + dy * len * 0.85 - py * wid * 0.8,
                hx - px * wid, hy - py * wid,
                tiltX = 0.25, tiltY = -0.4, bevel = 1.0)
            s.line(hx + dx * 1, hy + dy * 1, hx + dx * len * 0.8, hy + dy * len * 0.8, mat.ramp.light)
        }
    }
}
