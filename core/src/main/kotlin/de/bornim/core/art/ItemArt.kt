package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.Build
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Icon
import de.bornim.core.GearBases
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Sex
import de.bornim.core.art.HeroFigure.Rig
import de.bornim.core.art.HeroFigure.V

/**
 * Pictures of the things that can be worn and carried, built from the very solids the hero wears them as: a weapon
 * held up across the picture, a shield face on, armour and clothes standing empty as on an unseen body. Whatever has
 * no body (potions, keys, herbs) keeps its drawn [IconArt].
 */
object ItemArt {
    const val SIZE = 32
    private const val MARGIN = 2

    private val LONG = setOf("spear", "halberd", "quarterstaff", "staff")

    private val cache = HashMap<String, PixelImage>()

    /** Whether [base] is drawn from its solids. */
    fun built(base: String): Boolean {
        val def = GearBases[base]
        return def.slot != GearSlot.RING && def.slot != GearSlot.AMULET
    }

    /** The picture of [base] in [rarity]: built if it can be, else its drawn icon. */
    fun get(base: String, rarity: Rarity = Rarity.COMMON): PixelImage {
        if (!built(base)) return IconArt.get(GearBases[base].icon)
        val k = "$base/$rarity"
        synchronized(cache) { cache[k]?.let { return it } }
        val img = render(base, rarity)
        synchronized(cache) { cache[k] = img }
        return img
    }

    fun get(g: Gear): PixelImage = get(g.base, g.rarity)

    private val doll by lazy { Doll(Race.HUMAN, Sex.MALE, Build.AVERAGE) }

    /** How each kind of thing is held up to be seen, and from which side. */
    private fun pose(base: String, slot: GearSlot): Pair<Rig, Double> {
        val def = GearBases[base]
        return when {
            // across the picture from lower left to upper right, the flat to the onlooker
            // a bow seen from the side, so its curve shows
            slot == GearSlot.MAIN_HAND && def.icon == Icon.BOW -> Rig(lh = V(0.0, 100.0, 20.0), rh = V(14.0, 64.0, 4.0), bowTilt = 40.0) to 90.0
            slot == GearSlot.MAIN_HAND && def.icon == Icon.CROSSBOW -> Rig(yaw = 0.0, rh = V(-4.0, 95.0, 25.0), weapon = V(-1.0, 0.7, 0.0), aim = 1.0, grip = 10.0) to 0.0
            slot == GearSlot.MAIN_HAND -> Rig(yaw = 0.0, rh = V(-4.0, 95.0, 25.0), weapon = V(-1.0, 1.0, 0.0), aim = 1.0, grip = 45.0) to 0.0
            slot == GearSlot.OFF_HAND && def.kind == BaseKind.SHIELD -> Rig(yaw = 0.0, lh = V(-6.0, 100.0, 22.0), shieldFace = V(-0.25, 0.0, 1.0)) to 0.0
            slot == GearSlot.OFF_HAND -> Rig(yaw = 0.0, lh = V(-6.0, 100.0, 22.0), weapon = V(-1.0, 1.0, 0.0)) to 0.0
            else -> Doll.REST to 20.0
        }
    }

    private fun render(base: String, rarity: Rarity): PixelImage {
        val def = GearBases[base]
        val slot = def.slot
        val (rig, yaw) = pose(base, slot)
        // a rogue's armour, so no tabard of a fighter or a cleric hides it
        val cls = if (base == "robe") CharClass.WIZARD else CharClass.ROGUE
        val gear = Gear(0, base, rarity, 1)
        val sk = doll.Skeleton(rig.copy(yaw = yaw), shieldArm = def.kind == BaseKind.SHIELD, fists = true,
            twoHands = def.twoHanded && !def.ranged, weaponReach = Dress.reach(base))
        val body = doll.body(sk)
        // of a pair of gloves or bracers one is enough, and larger
        val solids = Dress(doll, sk, body, Outfit(cls, mapOf(slot to gear))).only(slot).filter { slot != GearSlot.ARMS || it.group != Doll.ARMOR_L }
        if (solids.isEmpty()) return IconArt.get(def.icon)
        val groups = doll.groups(sk)
        // drawn once large to find its extent, then again to fill the picture
        val big = 320
        val g0 = 290.0
        val a = SdfRender.render(solids, groups, doll::material, big, big, big / 2.0, g0, 1.0, yaw).img
        var x0 = big; var y0 = big; var x1 = -1; var y1 = -1
        for (y in 0 until big) for (x in 0 until big) if ((a[x, y] ushr 24) > 0) { x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y) }
        if (x1 < 0) return IconArt.get(def.icon)
        val fit = SIZE - 2 * MARGIN
        // a long shaft would be a hairline: drawn larger, its head in the corner and its foot running out of the picture
        val zoom = if (base in LONG) 1.7 else 1.0
        val px = fit / maxOf(x1 - x0 + 1, y1 - y0 + 1).toDouble() * zoom
        val cx = if (zoom > 1) x1 + 1 - fit / px / 2 else (x0 + x1 + 1) / 2.0
        val cy = if (zoom > 1) y0 + fit / px / 2 else (y0 + y1 + 1) / 2.0
        val ax = SIZE / 2.0 - (cx - big / 2.0) * px
        val gr = SIZE / 2.0 + (g0 - cy) * px
        val img = SdfRender.render(solids, groups, doll::material, SIZE, SIZE, ax, gr, px, yaw).img
        val s = Sculpt(SIZE, SIZE)
        for (y in 0 until SIZE) for (x in 0 until SIZE) s.img.set(x, y, img[x, y])
        s.outline(argb(0x14100E))
        return s.img
    }
}
