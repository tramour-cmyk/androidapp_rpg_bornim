package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Icon
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Weight

enum class Headgear { NONE, HAT, HELMET, HOOD, CIRCLET, BALD, BEARD_HOOD }

private val SHORT_WEAPONS = setOf(HandItem.BLADE, HandItem.DAGGER, HandItem.AXE, HandItem.MACE, HandItem.WAND)

/** What a character carries in the weapon hand on the map. */
enum class HandItem { NONE, BLADE, DAGGER, AXE, MACE, STAFF, WAND, BOW, SPEAR }

data class Look(
    val skin: Int,
    val hair: Int,
    val cloth: Int,
    val clothDark: Int,
    val accent: Int,
    val pants: Int,
    val headgear: Headgear = Headgear.NONE,
    val gear: Int = Pal.STONE,
    val robe: Boolean = false,
    val beard: Boolean = false,
    val small: Boolean = false,
    /** Cloak colour, or null for none. */
    val cloak: Int? = null,
    val weapon: HandItem = HandItem.NONE,
    val weaponColor: Int = Pal.IRON_LIGHT,
    /** Shield colour, or null for none. */
    val shield: Int? = null,
    /** The shield is a round one, pale with a golden sun (the cleric's), rather than the long wooden one. */
    val roundShield: Boolean = false,
    /** A glint in the colour of an epic or divine item, or null. */
    val sparkle: Int? = null,
)

/** 16×16 overworld characters drawn from simple shapes plus an automatic outline. */
object CharacterArt {
    private val cache = HashMap<String, PixelImage>()

    private val SKIN_LIGHT = argb(0xF8D0A8)
    private val SKIN = argb(0xE8B488)
    private val SKIN_TAN = argb(0xC8905C)
    private val SKIN_ORC = argb(0x8CB070)

    fun heroLook(race: Race, cls: CharClass): Look {
        val skin = when (race) {
            Race.HUMAN -> SKIN
            Race.ELF -> SKIN_LIGHT
            Race.DWARF -> SKIN_TAN
            Race.HALFLING -> SKIN
            Race.HALF_ORC -> SKIN_ORC
        }
        val hair = when (race) {
            Race.HUMAN -> argb(0x6A4028)
            Race.ELF -> argb(0xF0D878)
            Race.DWARF -> argb(0xB84A20)
            Race.HALFLING -> argb(0x8A5A30)
            Race.HALF_ORC -> argb(0x282830)
        }
        val base = when (cls) {
            CharClass.FIGHTER -> Look(skin, hair, argb(0xC03838), argb(0x802428), argb(0xA8B0B8), argb(0x484858), Headgear.HELMET, gear = argb(0xB8C0C8))
            CharClass.WIZARD -> Look(skin, hair, argb(0x3858C0), argb(0x203888), Pal.GOLD, argb(0x283070), Headgear.HAT, gear = argb(0x3050B0), robe = true)
            CharClass.ROGUE -> Look(skin, hair, argb(0x3E7040), argb(0x284A2C), argb(0x8A5A30), argb(0x383838), Headgear.HOOD, gear = argb(0x3E7040))
            CharClass.CLERIC -> Look(skin, hair, argb(0xF0F0F0), argb(0xC0C0D0), Pal.GOLD, argb(0xA0A0B8), Headgear.CIRCLET, gear = Pal.GOLD, robe = true)
        }
        return base.copy(beard = race == Race.DWARF, small = race == Race.HALFLING || race == Race.DWARF)
    }

    val npcLooks: Map<String, Look> = mapOf(
        "innkeeper" to Look(SKIN, argb(0xC05828), argb(0x8A6A4A), argb(0x5A4030), Pal.WHITE, argb(0x5A4030), robe = true),
        "elder" to Look(SKIN, argb(0xE8E8F0), argb(0x7048A0), argb(0x4A2C70), Pal.GOLD, argb(0x4A2C70), robe = true, beard = true),
        "merchant" to Look(SKIN_LIGHT, argb(0x302018), argb(0xE09030), argb(0xA86018), Pal.WHITE, argb(0x604020)),
        "priest" to Look(SKIN, argb(0xA07850), argb(0xF0E8D0), argb(0xC8B898), Pal.GOLD, argb(0xC8B898), Headgear.BALD, robe = true),
        "guard" to Look(SKIN, argb(0x403020), argb(0x3858A8), argb(0x203878), argb(0xB8C0C8), argb(0x404050), Headgear.HELMET, gear = argb(0xB8C0C8)),
        "child" to Look(SKIN_LIGHT, argb(0xE8B040), argb(0x60A0E0), argb(0x3870B0), Pal.WHITE, argb(0x704828), small = true),
        "villager" to Look(SKIN, argb(0x804020), argb(0x80A050), argb(0x587038), Pal.WHITE, argb(0x604828), robe = true),
        "hunter" to Look(SKIN_TAN, argb(0x503018), argb(0x6A5030), argb(0x4A3820), argb(0x3E7040), argb(0x3E3020), Headgear.HOOD, gear = argb(0x3E7040), beard = true),
        "lyra" to Look(SKIN_LIGHT, argb(0xD0A040), Pal.WHITE, argb(0xC8C8D8), Pal.GOLD, argb(0xC8C8D8), Headgear.CIRCLET, gear = Pal.GOLD, robe = true),
        "herbalist" to Look(SKIN_TAN, argb(0xC8C8C8), argb(0x5A7A3A), argb(0x3A5A2A), argb(0xC09040), argb(0x3A5A2A), Headgear.HOOD, gear = argb(0x5A7A3A), robe = true),
        "farmer" to Look(SKIN_TAN, argb(0x8A5A30), argb(0xD8C890), argb(0x6A5A3A), argb(0x8A5A30), argb(0x4A3820), beard = true),
        "maid" to Look(SKIN_LIGHT, argb(0xD8A040), argb(0xC85A6A), argb(0x9A3A4A), Pal.WHITE, argb(0x5A3A2A), robe = true),
        "dwarf" to Look(SKIN_TAN, argb(0x904020), argb(0x707888), argb(0x4A5060), argb(0x8A5A30), argb(0x403830), beard = true, small = true),
    )

    /** Metal tinted towards the rarity: rare weapons and helmets take on its colour. */
    private fun metal(r: Rarity): Int = mix(argb(0xC0CAD6), r.color.toInt(), when (r) {
        Rarity.COMMON, Rarity.UNCOMMON -> 0.0
        Rarity.RARE -> 0.3
        Rarity.VERY_RARE -> 0.4
        Rarity.EPIC, Rarity.DIVINE -> 0.5
    })

    private fun cloakColor(r: Rarity): Int = when (r) {
        Rarity.COMMON -> argb(0x6A4A3A)
        Rarity.UNCOMMON -> argb(0x3E7A44)
        Rarity.RARE -> argb(0x3A5AB0)
        Rarity.VERY_RARE -> argb(0x7A3AB0)
        Rarity.EPIC -> argb(0xC0602A)
        Rarity.DIVINE -> argb(0xD8A830)
    }

    /**
     * The hero as equipped: head, armor, cloak, weapon and shield show on the map. Empty slots keep
     * the class look (e.g. the wizard's hat), so the class stays recognisable.
     */
    fun heroLook(hero: Hero): Look {
        var l = heroLook(hero.race, hero.cls)
        hero.item(GearSlot.HEAD)?.let { g ->
            l = when (g.def.icon) {
                Icon.HELMET -> l.copy(headgear = Headgear.HELMET, gear = metal(g.rarity))
                Icon.HOOD -> l.copy(headgear = Headgear.HOOD, gear = cloakColor(g.rarity))
                Icon.CIRCLET -> l.copy(headgear = Headgear.CIRCLET, accent = if (g.rarity >= Rarity.RARE) g.rarity.color.toInt() else Pal.GOLD)
                else -> l
            }
        }
        hero.item(GearSlot.CHEST)?.let { g ->
            val trim = if (g.rarity >= Rarity.UNCOMMON) g.rarity.color.toInt() else l.accent
            l = when (g.def.weight) {
                Weight.LIGHT -> l.copy(cloth = argb(0x8A5A34), clothDark = argb(0x5E3C22), accent = trim, robe = false)
                Weight.MEDIUM -> l.copy(cloth = argb(0x9AA4B0), clothDark = argb(0x6A7480), accent = trim, robe = false)
                Weight.HEAVY -> l.copy(cloth = metal(g.rarity), clothDark = mix(metal(g.rarity), Pal.OUTLINE, 0.3), accent = trim, robe = false)
                else -> l.copy(cloth = mix(l.cloth, g.rarity.color.toInt(), if (g.rarity >= Rarity.RARE) 0.35 else 0.0), accent = trim, robe = true)
            }
        }
        hero.item(GearSlot.CLOAK)?.let { l = l.copy(cloak = cloakColor(it.rarity)) }
        hero.weapon?.let { g ->
            val hand = when (g.def.icon) {
                Icon.SWORD -> HandItem.BLADE
                Icon.DAGGER -> HandItem.DAGGER
                Icon.AXE -> HandItem.AXE
                Icon.MACE, Icon.HAMMER -> HandItem.MACE
                Icon.STAFF -> HandItem.STAFF
                Icon.WAND -> HandItem.WAND
                Icon.BOW, Icon.CROSSBOW -> HandItem.BOW
                Icon.SPEAR -> HandItem.SPEAR
                else -> HandItem.NONE
            }
            l = l.copy(weapon = hand, weaponColor = metal(g.rarity))
        }
        hero.item(GearSlot.OFF_HAND)?.takeIf { it.def.kind == BaseKind.SHIELD }?.let {
            val round = it.base == "round_shield"
            l = l.copy(shield = mix(argb(if (round) 0xE4DCC4 else 0x8A5A30), it.rarity.color.toInt(), if (it.rarity >= Rarity.RARE) 0.5 else 0.0), roundShield = round)
        }
        val best = hero.gear.values.maxByOrNull { it.rarity }
        if (best != null && best.rarity >= Rarity.EPIC) l = l.copy(sparkle = best.rarity.color.toInt())
        return l
    }

    /** The hero on the map as equipped. */
    fun hero(hero: Hero, facing: Facing, step: Int = 0): PixelImage {
        val look = heroLook(hero)
        return sprite(look, facing, step, "hero:$look")
    }

    fun npc(look: String, facing: Facing, step: Int = 0): PixelImage =
        sprite(npcLooks[look] ?: npcLooks.getValue("villager"), facing, step, "npc:$look")

    fun hero(race: Race, cls: CharClass, facing: Facing, step: Int = 0): PixelImage =
        sprite(heroLook(race, cls), facing, step, "hero:$race:$cls")

    private fun sprite(look: Look, facing: Facing, step: Int, key: String): PixelImage =
        cache.getOrPut("$key/$facing/$step") {
            when (facing) {
                Facing.RIGHT -> draw(32, 32) { body(look, Facing.LEFT, step) }.mirrored()
                else -> draw(32, 32) { body(look, facing, step) }
            }
        }

    private val BOOT = argb(0x3A2A22)

    private fun shade(c: Int) = mix(c, Pal.OUTLINE, 0.32)
    private fun light(c: Int) = mix(c, Pal.WHITE, 0.3)

    /** 32×32 character, feet at the bottom row. Drawn for DOWN, UP and LEFT; RIGHT is mirrored. */
    private fun Pen.body(l: Look, facing: Facing, step: Int) {
        val dy = if (l.small) 2 else 0
        val side = facing == Facing.LEFT
        val up = facing == Facing.UP
        val top0 = 17 + dy
        // A cloak hangs behind the body: seen from the front only at the sides.
        l.cloak?.let { c ->
            if (facing == Facing.DOWN) { rect(8, top0, 23, 27, c); rect(20, top0, 23, 27, shade(c)) }
            if (side) { rect(17, top0, 22, 27, c); rect(20, top0 + 2, 22, 27, shade(c)) }
        }
        // A shield on the far arm is partly hidden behind the body when seen from the side.
        if (side) l.shield?.let { c -> if (l.roundShield) ellipse(20.0, top0 + 5.0, 2.6, 4.0, shade(c)) else ellipse(20.0, top0 + 5.0, 3.0, 4.5, shade(c)) }

        // ---- legs and boots (two walk frames lift one foot)
        val liftL = if (step == 1) 1 else 0
        val liftR = if (step == 2) 1 else 0
        if (side) {
            val a = if (step == 0) 0 else 2
            rect(12 - a, 25, 15 - a, 28 - (if (step == 1) 1 else 0), l.pants)
            rect(16 + a, 25, 19 + a, 28 - (if (step == 2) 1 else 0), shade(l.pants))
            rect(11 - a, 29 - liftL, 15 - a, 30 - liftL, BOOT)
            rect(16 + a, 29 - liftR, 20 + a, 30 - liftR, BOOT)
        } else {
            rect(11, 25, 14, 28 - liftL, l.pants)
            rect(17, 25, 20, 28 - liftR, shade(l.pants))
            rect(11, 29 - liftL, 14, 30 - liftL, BOOT)
            rect(17, 29 - liftR, 20, 30 - liftR, BOOT)
        }

        // ---- torso
        val top = 17 + dy
        if (side) {
            rect(11, top, 20, 25, l.cloth)
            rect(18, top, 20, 25, shade(l.cloth))
            if (l.robe) { rect(10, 24, 21, 27, l.cloth); rect(18, 24, 21, 27, shade(l.cloth)) }
            rect(11, 23, 20, 23, l.accent)
            // arm in front
            rect(14, top + 1, 16, top + 6, shade(l.cloth))
            rect(14, top + 7, 16, top + 8, l.skin)
        } else {
            rect(10, top, 21, 25, l.cloth)
            rect(19, top, 21, 25, shade(l.cloth))
            rect(10, top, 21, top, light(l.cloth))
            if (l.robe) { rect(9, 24, 22, 27, l.cloth); rect(19, 24, 22, 27, shade(l.cloth)) }
            rect(10, 23, 21, 23, l.accent)
            if (!up) { rect(15, 22, 16, 24, l.accent); px(15, 23, light(l.accent)) }
            if (!up && !l.robe) rect(15, top + 1, 16, 21, shade(l.cloth)) // tunic opening
            // arms
            rect(7, top + 1, 9, top + 6, l.cloth); rect(7, top + 7, 9, top + 8, l.skin)
            rect(22, top + 1, 24, top + 6, shade(l.cloth)); rect(22, top + 7, 24, top + 8, shade(l.skin))
        }

        // ---- head
        val cy = 10.5 + dy
        val hx = if (side) 15.0 else 16.0
        ellipse(hx, cy, 7.6, 7.2, l.skin)
        // cheek shading on the far side
        for (y in 0 until 32) for (x in 0 until 32) {
            if (at(x, y) == l.skin && y <= top && x >= (if (side) 18 else 21)) px(x, y, shade(l.skin))
        }

        fun isHead(x: Int, y: Int) = y < top && (at(x, y) == l.skin || at(x, y) == shade(l.skin))
        val hairTop = (cy - 2).toInt()
        when (facing) {
            Facing.DOWN -> {
                for (y in 0 until top) for (x in 0 until 32) if (isHead(x, y)) {
                    val fringe = y <= hairTop + (if ((x / 2) % 2 == 0) 0 else 1)
                    val sides = (x <= 9 || x >= 22) && y <= cy + 3
                    if (fringe || sides) px(x, y, l.hair)
                }
                // eyes with a glint
                val ey = (cy + 1).toInt()
                for (ex in listOf(12, 18)) {
                    rect(ex, ey, ex + 1, ey + 2, Pal.EYE)
                    px(ex, ey, Pal.WHITE)
                }
                px(15, ey + 4, shade(l.skin)); px(16, ey + 4, shade(l.skin))
                if (l.beard) for (y in ey + 3 until top) for (x in 10..21) if (isHead(x, y)) px(x, y, l.hair)
            }
            Facing.UP -> {
                for (y in 0 until top) for (x in 0 until 32) if (isHead(x, y)) px(x, y, l.hair)
            }
            else -> {
                for (y in 0 until top) for (x in 0 until 32) if (isHead(x, y)) {
                    if (y <= hairTop || (x >= 16 && y <= cy + 4)) px(x, y, l.hair)
                }
                val ey = (cy + 1).toInt()
                rect(11, ey, 12, ey + 2, Pal.EYE)
                px(11, ey, Pal.WHITE)
                px(8, ey + 2, shade(l.skin))
                if (l.beard) for (y in ey + 3 until top) for (x in 8..15) if (isHead(x, y)) px(x, y, l.hair)
            }
        }
        // hair shine
        if (l.headgear == Headgear.NONE || l.headgear == Headgear.CIRCLET) {
            for (x in 12..15) if (at(x, hairTop - 3) == l.hair) px(x, hairTop - 3, light(l.hair))
        }
        headgear(l, facing, cy, top)
        // From behind, the cloak covers the back like a cape.
        if (up) l.cloak?.let { c ->
            rect(9, top, 22, 27, c); rect(19, top, 22, 27, shade(c)); rect(9, top, 22, top, light(c))
            for (y in top + 3..26 step 4) px(12, y, shade(c))
        }
        weapon(l, facing, top)
        if (!side) l.shield?.let { c ->
            val sx = if (up) 23.0 else 8.0
            if (l.roundShield) {
                // the round shield: an iron rim, the pale face and a golden sun in the middle (from behind, the wood)
                ellipse(sx, top + 5.0, 4.5, 4.5, Pal.IRON_LIGHT)
                ellipse(sx, top + 5.0, 3.6, 3.6, if (up) argb(0x8A5A30) else c)
                if (!up) {
                    val x = sx.toInt(); val y = top + 5
                    val ray = argb(0xC07A20)
                    for (dx in -1..1) for (dy in -1..1) px(x + dx, y + dy, ray)
                    px(x - 2, y, ray); px(x + 2, y, ray); px(x, y - 2, ray); px(x, y + 2, ray)
                    px(x, y, Pal.GOLD)
                }
            } else {
                // the long wooden shield on the left arm, with a metal boss
                ellipse(sx, top + 5.0, 4.0, 5.0, shade(c)); ellipse(sx - 0.5, top + 4.5, 3.2, 4.2, c)
                if (!up) { px(sx.toInt(), top + 5, Pal.IRON_LIGHT); px(sx.toInt() - 1, top + 4, Pal.WHITE) }
            }
        }
        outline(Pal.OUTLINE)
        l.sparkle?.let { c ->
            // drawn after the outline so it glows: a small four-pointed star beside the head and a glint at the hip
            px(4, top - 7, Pal.WHITE); px(3, top - 7, c); px(5, top - 7, c); px(4, top - 8, c); px(4, top - 6, c)
            px(27, top + 3, light(c))
        }
    }

    /** The weapon held upright in the weapon hand (right hand; in front when seen from the side). */
    private fun Pen.weapon(l: Look, facing: Facing, top: Int) {
        if (l.weapon == HandItem.NONE) return
        val side = facing == Facing.LEFT
        // From the front the right hand is on the right of the picture, from behind on the left.
        val x = when (facing) { Facing.LEFT -> 7; Facing.UP -> 6; else -> 24 }
        val hand = top + 7
        val wood = argb(0x8A5A30); val woodD = argb(0x5E3A1E)
        val m = l.weaponColor; val mL = light(m); val mD = shade(m)
        if (side && l.weapon in SHORT_WEAPONS) {
            // Seen from the side, one-handed weapons point forward and up, clear of the face.
            val hx = 10; val hy = top + 8
            val len = when (l.weapon) { HandItem.DAGGER -> 4; HandItem.WAND -> 5; HandItem.BLADE -> 9; else -> 8 }
            val tx = hx - len; val ty = hy - len
            when (l.weapon) {
                HandItem.BLADE, HandItem.DAGGER -> {
                    line(hx - 1, hy - 1, tx, ty, m); line(hx - 1, hy - 2, tx, ty - 1, mL)
                    line(hx - 2, hy + 1, hx + 1, hy - 2, Pal.GOLD_DARK); px(hx, hy, woodD); px(hx + 1, hy + 1, woodD)
                }
                HandItem.WAND -> {
                    line(hx, hy, tx, ty, woodD)
                    px(tx - 1, ty - 1, if (m == argb(0xC0CAD6)) argb(0x7AD0FF) else m); px(tx - 2, ty - 2, Pal.WHITE)
                }
                HandItem.AXE -> {
                    line(hx + 1, hy + 1, tx, ty, wood)
                    for (k in 0..3) line(tx + k, ty - 1 + k, tx - 3 + k, ty + 2 + k, if (k == 0) mL else m)
                }
                else -> {
                    line(hx + 1, hy + 1, tx + 1, ty + 1, wood)
                    ellipse(tx.toDouble(), ty.toDouble(), 2.2, 2.2, m); px(tx - 1, ty - 1, mL)
                }
            }
            return
        }
        when (l.weapon) {
            HandItem.BLADE -> {
                rect(x, hand - 12, x + 1, hand - 1, m); rect(x, hand - 12, x, hand - 1, mL); px(x, hand - 13, mL)
                rect(x - 2, hand, x + 3, hand, Pal.GOLD_DARK); rect(x, hand + 1, x + 1, hand + 2, woodD)
            }
            HandItem.DAGGER -> {
                rect(x, hand - 6, x + 1, hand - 1, m); px(x, hand - 7, mL)
                rect(x - 1, hand, x + 2, hand, Pal.GOLD_DARK); rect(x, hand + 1, x + 1, hand + 1, woodD)
            }
            HandItem.AXE -> {
                rect(x, hand - 11, x, hand + 3, wood)
                val dir = if (side) -1 else 1
                for (k in 0..3) rect(minOf(x + dir, x + dir * (2 + k / 2)), hand - 11 + k, maxOf(x + dir, x + dir * (2 + k / 2)), hand - 11 + k, if (k == 0) mL else m)
                rect(minOf(x + dir, x + dir * 3), hand - 7, maxOf(x + dir, x + dir * 3), hand - 7, mD)
            }
            HandItem.MACE -> {
                rect(x, hand - 8, x, hand + 3, wood)
                ellipse(x + 0.5, hand - 9.5, 2.2, 2.2, m); px(x, hand - 11, mL)
            }
            HandItem.STAFF -> {
                rect(x, hand - 14, x, hand + 9, wood); rect(x + 1, hand - 14, x + 1, hand + 9, woodD)
                ellipse(x + 0.5, hand - 15.0, 1.8, 1.8, if (m == argb(0xC0CAD6)) argb(0x7AD0FF) else m); px(x, hand - 16, Pal.WHITE)
            }
            HandItem.WAND -> {
                rect(x, hand - 6, x, hand + 2, woodD)
                px(x, hand - 7, if (m == argb(0xC0CAD6)) argb(0x7AD0FF) else m); px(x, hand - 8, Pal.WHITE)
            }
            HandItem.BOW -> {
                val dir = if (side) -1 else 1
                for (k in -9..9) {
                    val bx = x + dir * (2 - kotlin.math.abs(k) / 4)
                    px(bx, hand + k - 2, wood)
                }
                rect(x, hand - 11, x, hand + 7, argb(0xE8E0D0))
            }
            HandItem.SPEAR -> {
                rect(x, hand - 13, x, hand + 9, wood)
                tri(x - 1, hand - 13, x + 2, hand - 13, x, hand - 18, m); px(x, hand - 16, mL)
            }
            HandItem.NONE -> {}
        }
    }

    private fun Pen.headgear(l: Look, facing: Facing, cy: Double, top: Int) {
        val side = facing == Facing.LEFT
        val headTop = (cy - 7).toInt()
        fun isHead(x: Int, y: Int) = y < top && isSet(x, y) && y <= cy + 8
        when (l.headgear) {
            Headgear.NONE, Headgear.BEARD_HOOD -> {}
            Headgear.BALD -> {
                for (y in 0..headTop + 4) for (x in 0 until 32) if (isHead(x, y)) px(x, y, l.skin)
                px(13, headTop + 2, light(l.skin)); px(14, headTop + 2, light(l.skin))
            }
            Headgear.HAT -> {
                val brimY = headTop + 5
                ellipse(16.0, brimY + 0.5, 12.0, 2.6, shade(l.gear))
                ellipse(16.0, brimY.toDouble(), 11.0, 2.0, l.gear)
                val tipX = if (side) 11 else 21
                tri(9, brimY, 23, brimY, tipX, 0, l.gear)
                tri(16, brimY, 23, brimY, tipX, 0, shade(l.gear))
                rect(10, brimY - 2, 22, brimY - 1, l.accent)
                px(14, brimY - 6, Pal.FIRE_LIGHT); px(13, brimY - 5, Pal.FIRE_LIGHT); px(15, brimY - 5, Pal.FIRE_LIGHT); px(14, brimY - 4, Pal.FIRE_LIGHT)
            }
            Headgear.HELMET -> {
                for (y in 0..headTop + 6) for (x in 0 until 32) if (isHead(x, y)) px(x, y, if (x >= 19) shade(l.gear) else l.gear)
                rect(8, headTop + 6, 23, headTop + 7, shade(l.gear))
                for (x in 9..22 step 4) px(x, headTop + 6, light(l.gear))
                px(12, headTop + 2, Pal.WHITE); px(13, headTop + 1, Pal.WHITE)
                if (facing == Facing.DOWN) rect(15, headTop + 7, 16, headTop + 10, shade(l.gear))
                if (side) rect(9, headTop + 7, 10, headTop + 9, shade(l.gear))
            }
            Headgear.HOOD -> {
                val faceTop = headTop + 6
                for (y in 0 until top) for (x in 0 until 32) {
                    if (!isHead(x, y)) continue
                    val face = when (facing) {
                        Facing.DOWN -> x in 11..20 && y >= faceTop
                        Facing.LEFT -> x in 9..14 && y >= faceTop
                        else -> false
                    }
                    if (!face) px(x, y, if (x >= 20) shade(l.gear) else l.gear)
                }
                // hood rim and drape over the shoulders
                if (facing == Facing.DOWN) {
                    rect(10, faceTop - 1, 21, faceTop - 1, shade(l.gear))
                    rect(8, top, 23, top + 2, l.gear); rect(20, top, 23, top + 2, shade(l.gear))
                } else {
                    rect(9, top, 22, top + 2, l.gear)
                }
            }
            Headgear.CIRCLET -> {
                val y = headTop + 4
                for (x in 0 until 32) if (isHead(x, y)) px(x, y, l.accent)
                if (facing == Facing.DOWN) { px(15, y, Pal.RED); px(16, y, Pal.RED); px(15, y - 1, light(l.accent)) }
            }
        }
    }
}
