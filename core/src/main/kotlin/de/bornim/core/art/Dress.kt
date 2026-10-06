package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Icon
import de.bornim.core.Rarity
import de.bornim.core.Weight
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/** What a hero wears and holds, slot by slot. */
class Outfit(val cls: CharClass, val items: Map<GearSlot, Gear>) {
    fun base(slot: GearSlot): String? = items[slot]?.base
    fun rarity(slot: GearSlot): Rarity = items[slot]?.rarity ?: Rarity.COMMON
    val twoHands: Boolean get() = items[GearSlot.MAIN_HAND]?.def?.let { it.twoHanded && !it.ranged } == true
    val hasShield: Boolean get() = items[GearSlot.OFF_HAND]?.def?.kind == BaseKind.SHIELD && !twoHands

    companion object {
        fun of(hero: Hero) = Outfit(hero.cls, GearSlot.entries.mapNotNull { s -> hero.item(s)?.let { s to it } }.toMap())
    }
}

/**
 * Dresses a [Doll] in an [Outfit]: every garment is a layer over the bones under it (a shell a little
 * thicker than the body), so it moves with every pose. Plain clothes go on first, then armour, belt and
 * tabard, cloak and headgear; the shield is a curved board strapped to the forearm. Weapons are drawn
 * afterwards in [overlay], each pixel tested against the doll's depth.
 */
class Dress(private val d: Doll, private val sk: Doll.Skeleton, private val body: List<Solid>, private val o: Outfit) {
    private val h = d.height
    private val look = CharacterArt.heroLook(d.race, o.cls)
    private fun worn(rgb: Int, k: Double = 0.38) = mix(rgb, argb(0x3A3632), k)
    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, bias: Double = 0.0) = Mat(Ramp.of(rgb), shine, grain, bias)
    private fun metal(r: Rarity, bias: Double = 0.0) = m(mix(argb(0x868E98), r.color.toInt(), if (r >= Rarity.RARE) 0.16 else 0.0), shine = 0.9, bias = bias - 0.04)
    private val darkSteel = m(argb(0x6E7680), shine = 0.6)
    private val leather = m(argb(0x6A4A32), grain = 0.07)
    private val darkLeather = m(argb(0x3E2C22), grain = 0.05)
    private val gold = m(argb(0xB8904A), shine = 0.7)
    private val wood = m(argb(0x6E4A2C), grain = 0.12)
    private val cloth = m(worn(look.cloth), grain = 0.05)
    private val clothDark = m(worn(look.clothDark, 0.45), grain = 0.05)
    private val pants = m(worn(look.pants, 0.3), grain = 0.05)
    private fun chain(r: Rarity) = m(mix(argb(0x8A9098), r.color.toInt(), if (r >= Rarity.RARE) 0.12 else 0.0), shine = 0.4, grain = 0.45)
    private fun cloakColor(r: Rarity) = worn(argb(when (r) {
        Rarity.COMMON -> 0x5A4A3A; Rarity.UNCOMMON -> 0x3E5A3A; Rarity.RARE -> 0x34486E; Rarity.VERY_RARE -> 0x5A3A6E; Rarity.EPIC -> 0x7A4A22; Rarity.DIVINE -> 0x8A7A3A
    }), 0.3)

    private val chest = o.items[GearSlot.CHEST]?.def
    private val chestBase = o.base(GearSlot.CHEST)
    private val chestR = o.rarity(GearSlot.CHEST)
    private val robe = chest?.icon == Icon.ROBE || (chest == null && (o.cls == CharClass.WIZARD || o.cls == CharClass.CLERIC))
    private val heavy = chest?.weight == Weight.HEAVY
    private val medium = chest?.weight == Weight.MEDIUM
    private val plated = chestBase in setOf("breastplate", "half_plate", "plate")

    private val out = mutableListOf<Solid>()
    private fun bones(vararg keys: String) = body.filter { it.key in keys }
    private fun add(s: Solid, mat: Mat? = null, paint: ((P3) -> Mat)? = null, rest: ((P3) -> P3)? = null): Solid {
        s.mat = mat; s.paint = paint; s.rest = rest; out += s; return s
    }
    /** A layer [t] cm over the named bones. */
    private fun shell(t: Double, group: Int, mat: Mat, vararg keys: String, paint: ((P3) -> Mat)? = null, cut: (Solid) -> Unit = {}): List<Solid> =
        bones(*keys).map { b -> add(Shell(b, t, BodyPart.GEAR, group), mat, paint, b.rest).also(cut) }
    private fun armGroup(i: Int, base: Int) = base + 1 + i

    /** Keeps the part of a limb between fractions [from] and [to] of the way from joint [a] to joint [b]. */
    private fun between(s: Solid, a: P3, b: P3, from: Double, to: Double) {
        val n = (b - a).norm(); val len = (b - a).len()
        if (from > 0) s.cut(-n, a + n * (len * from))
        if (to < 1) s.cut(n, a + n * (len * to))
    }

    // the body's own levels, in rest space of the trunk
    private val beltY = d.hipY + 0.22 * d.trunk
    private fun upY(y: Double) = sk.upper.apply(P3(0.0, y, 0.0))
    private val upN = sk.upper.dir(P3.Y)

    /** Body parts covered and therefore not drawn. */
    val hidden: Set<String> = buildSet {
        val head = o.base(GearSlot.HEAD)
        if (head != null && head != "circlet") { add("hair"); if (head == "great_helm") { add("ear"); add("tusk") } }
        if (head == null && o.cls == CharClass.WIZARD) add("hair")
    }

    fun solids(): List<Solid> {
        clothes()
        armour()
        arms()
        legs()
        belt()
        cloak()
        headgear()
        offHand()
        return out
    }

    // ---------------------------------------------------------------- plain clothes

    private fun clothes() {
        val sleeve = if (robe) cloth else clothDark
        // shirt or tunic over trunk and hips, sleeves to the wrist
        shell(0.6, Doll.CLOTH, if (robe) cloth else cloth, "torso", "waist", "neck")
        shell(0.7, Doll.CLOTH, if (robe) cloth else clothDark, "pelvis")
        for (i in 0..1) shell(0.55, armGroup(i, Doll.CLOTH), sleeve, "delt$i", "upper$i", "fore$i")
        // trousers
        for (i in 0..1) shell(0.5, Doll.CLOTH, pants, "thigh$i", "knee$i", "shin$i")
        if (robe) {
            // a long robe falling from the hips to the ankles, a bell of cloth around both legs
            val hem = d.ankleY + 0.02 * h
            val waist = sk.lower.apply(P3(0.0, d.hipY + 0.12 * d.trunk, 0.0))
            val stride = sk.rig.stride * sk.s
            val foot = P3(0.0, hem, stride * 0.35)
            val bell = RoundCone(waist, foot, d.hipX * 1.9, d.hipX * 2.7 + 0.02 * h, BodyPart.GEAR, Doll.SKIRT)
            add(Squash(bell, waist, Frame.IDENTITY, P3(1.0, 1.0, 0.72), BodyPart.GEAR, Doll.SKIRT), cloth).also {
                it.cut(P3(0.0, -1.0, 0.0), P3(0.0, hem, 0.0)); it.cut(P3.Y, waist)
            }
            // wide sleeves, opening towards the wrist
            for (i in 0..1) {
                val el = sk.elbow[i]; val wr = sk.wrist[i]; val dir = (wr - el).norm()
                add(RoundCone(el, wr + dir * (0.01 * h), 0.03 * h, 0.05 * h, BodyPart.GEAR, armGroup(i, Doll.CLOTH)), cloth).cut(dir, wr + dir * (0.012 * h))
            }
        }
    }

    // ---------------------------------------------------------------- body armour

    private fun armour() {
        if (chest == null || robe) return
        val r = chestR
        val hipCut = { s: Solid -> s.cut(P3(0.0, -1.0, 0.0), P3(0.0, d.hipY - sk.crouch - 0.05 * h, 0.0)); Unit }
        when (chestBase) {
            "leather", "studded_leather" -> {
                val studs = chestBase == "studded_leather"
                val stud = m(argb(0xB8B0A0), shine = 0.8)
                val paint: (P3) -> Mat = { p -> if (studs && frac(p.x / 3.2 + 0.25) < 0.22 && frac(p.y / 3.2) < 0.22) stud else leather }
                shell(1.4, Doll.ARMOR, leather, "torso", "waist", paint = paint)
                shell(1.6, Doll.ARMOR, leather, "pelvis", paint = paint, cut = hipCut)
                for (i in 0..1) shell(1.2, armGroup(i, Doll.ARMOR), darkLeather, "delt$i")
            }
            "chain_shirt", "scale_mail" -> {
                val scales = chestBase == "scale_mail"
                val ch = chain(r)
                val sc = m(mix(argb(0x8C8A80), r.color.toInt(), if (r >= Rarity.RARE) 0.15 else 0.0), shine = 0.6, grain = 0.1)
                val scDark = sc.copy(bias = -0.12)
                val paint: (P3) -> Mat = { p -> if (!scales) ch else if (frac(p.y / 2.6) < 0.35 || frac((p.x + floor(p.y / 2.6) * 1.3) / 2.6) < 0.18) scDark else sc }
                shell(1.0, Doll.ARMOR, ch, "torso", "waist", paint = paint)
                shell(1.2, Doll.ARMOR, ch, "pelvis", paint = paint)
                if (scales) for (i in 0..1) shell(1.6, Doll.ARMOR, ch, "thigh$i", paint = paint) { between(it, sk.hip[i], sk.knee[i], 0.0, 0.45) }
                for (i in 0..1) {
                    shell(0.9, armGroup(i, Doll.ARMOR), ch, "delt$i", paint = paint)
                    shell(0.9, armGroup(i, Doll.ARMOR), ch, "upper$i", paint = paint) { between(it, sk.shoulder[i], sk.elbow[i], 0.0, 0.55) }
                }
            }
            "breastplate", "half_plate" -> {
                val ch = chain(r)
                // a mail shirt under the plate shows at the hips and arms
                shell(1.0, Doll.ARMOR, ch, "pelvis")
                for (i in 0..1) shell(0.9, armGroup(i, Doll.ARMOR), ch, "upper$i") { between(it, sk.shoulder[i], sk.elbow[i], 0.0, 0.6) }
                plate(r, pauldrons = chestBase == "half_plate", tassets = chestBase == "half_plate")
            }
            "chain_mail", "splint", "plate" -> {
                val ch = chain(r)
                val splints = chestBase == "splint"
                val strip = metal(r); val gap = darkLeather
                val paint: (P3) -> Mat = { p -> if (!splints) ch else if (frac(p.x / 3.0) < 0.2) gap else strip }
                // a hauberk to the knees with long sleeves
                shell(1.0, Doll.ARMOR, ch, "torso", "waist", paint = paint)
                shell(1.3, Doll.ARMOR, ch, "pelvis", paint = paint)
                for (i in 0..1) shell(1.5, Doll.SKIRT, ch, "thigh$i", paint = paint) { between(it, sk.hip[i], sk.knee[i], 0.0, 0.8) }
                for (i in 0..1) shell(0.9, armGroup(i, Doll.ARMOR), ch, "delt$i", "upper$i", "fore$i", paint = paint)
                if (chestBase == "plate") {
                    plate(r, pauldrons = true, tassets = true)
                    for (i in 0..1) {
                        shell(1.8, armGroup(i, Doll.ARMOR), metal(r), "upper$i") { between(it, sk.shoulder[i], sk.elbow[i], 0.3, 0.92) }
                        add(Ellipsoid(sk.elbow[i], P3(0.03 * h, 0.03 * h, 0.03 * h), Frame.IDENTITY, BodyPart.GEAR, armGroup(i, Doll.ARMOR)), metal(r))
                        shell(1.8, Doll.ARMOR, metal(r), "thigh$i") { between(it, sk.hip[i], sk.knee[i], 0.35, 0.95) }
                        shell(2.2, Doll.ARMOR, metal(r), "knee$i")
                    }
                }
            }
        }
        // a tabard in the house colour over mail and plate of fighters and clerics
        if ((heavy || medium) && chestBase != "scale_mail" && (o.cls == CharClass.FIGHTER || o.cls == CharClass.CLERIC)) tabard(if (plated) 2.8 else 1.6)
    }

    /** Breast and back plate, pauldrons and tassets. */
    private fun plate(r: Rarity, pauldrons: Boolean, tassets: Boolean) {
        val pl = metal(r)
        val edge = metal(r, bias = -0.15)
        val paint: (P3) -> Mat = { p -> if (abs(p.y - (beltY + 0.02 * h)) < 0.9) edge else pl }
        shell(2.2, Doll.ARMOR, pl, "torso", "waist", paint = paint).forEach { it.cut(P3(0.0, -1.0, 0.0), sk.upper.apply(P3(0.0, beltY - 0.01 * h, 0.0))) }
        if (pauldrons) for (i in 0..1) {
            val a = sk.shoulder[i]; val dn = (sk.elbow[i] - a).norm()
            shell(2.6, armGroup(i, Doll.ARMOR), pl, "delt$i").forEach { it.cut(dn, a + dn * (0.07 * h)) }
        }
        if (tassets) for (i in 0..1) {
            // a plate hanging from the belt over each thigh
            val top = sk.lower.apply(P3(sk.side(i) * d.hipX * 1.0, d.hipY + 0.06 * h, d.chestDepth * 0.75))
            val dn = (sk.knee[i] - sk.hip[i]).norm()
            val c = top + dn * (0.07 * h)
            add(Box(c, P3(0.06 * h, 0.07 * h, 0.4), Frame.along(dn, P3(0.0, 0.0, 1.0)), 0.5, BodyPart.GEAR, Doll.TRIM), pl)
        }
    }

    /** A cloth panel front and back in the house colour, falling from the shoulders to the knees. */
    private fun tabard(over: Double) {
        val col = m(worn(look.cloth, 0.2), grain = 0.05)
        val half = d.shoulderX * 0.34
        for (b in bones("torso", "waist")) {
            val s = add(Shell(b, over + 0.5, BodyPart.GEAR, Doll.TRIM), col, null, b.rest)
            s.cut(sk.upper.dir(P3.X), sk.upper.apply(P3(half, 0.0, 0.0)))
            s.cut(sk.upper.dir(-P3.X), sk.upper.apply(P3(-half, 0.0, 0.0)))
            s.cut(sk.upper.dir(P3.Y), sk.upper.apply(P3(0.0, d.shoulderY - 0.02 * h, 0.0)))
        }
        // the hanging part, front and back, from the belt to above the knee
        val top = d.hipY + 0.2 * d.trunk - sk.crouch
        val bot = d.kneeY + 0.06 * h
        for (sd in listOf(1.0, -1.0)) {
            val z = sd * (d.chestDepth * 0.95 + over + 0.6)
            val c = P3(0.0, (top + bot) / 2, z + sd * (sk.rig.stride * sk.s * 0.15))
            add(Box(c, P3(half, (top - bot) / 2, 0.35), Frame.IDENTITY, 0.4, BodyPart.GEAR, Doll.TRIM), col)
        }
    }

    // ---------------------------------------------------------------- belt

    private fun belt() {
        val t = when { plated -> 3.2; heavy || medium -> 2.2; chest != null && !robe -> 2.2; else -> 1.4 }
        val y = beltY
        for (b in bones("waist")) {
            val s = add(Shell(b, t, BodyPart.GEAR, Doll.BELT), darkLeather, null, b.rest)
            s.cut(upN, upY(y + 0.012 * h)); s.cut(-upN, upY(y - 0.012 * h))
        }
        val front = sk.upper.apply(P3(0.0, y, d.chestDepth * 0.82 + t))
        add(Box(front, P3(0.018 * h, 0.014 * h, 0.5), sk.upper.frame(Frame.IDENTITY), 0.3, BodyPart.GEAR, Doll.TRIM), gold)
        // a pouch on the right hip
        // the hips do not turn with the chest, so the pouch stays on the side
        add(Box(sk.lower.apply(P3(d.hipX * 1.85, d.hipY + 0.06 * h, 0.0)), P3(0.012 * h, 0.03 * h, 0.022 * h), Frame.IDENTITY, 1.0, BodyPart.GEAR, Doll.TRIM), leather)
    }

    // ---------------------------------------------------------------- arms and legs

    private fun arms() {
        val a = o.items[GearSlot.ARMS] ?: return
        val r = a.rarity
        for (i in 0..1) {
            val g = armGroup(i, Doll.ARMOR)
            val el = sk.elbow[i]; val wr = sk.wrist[i]
            when (a.base) {
                "wraps" -> shell(0.8, g, m(argb(0xB8AC90), grain = 0.15), "fore$i") { between(it, el, wr, 0.3, 1.0) }
                "gloves" -> { shell(0.7, g, leather, "hand$i"); shell(1.2, g, leather, "fore$i") { between(it, el, wr, 0.7, 1.0) } }
                "bracers" -> shell(1.4, g, metal(r, -0.05), "fore$i") { between(it, el, wr, 0.25, 0.92) }
                "gauntlets" -> { shell(1.0, g, metal(r), "hand$i"); shell(1.8, g, metal(r), "fore$i") { between(it, el, wr, 0.55, 1.0) } }
            }
        }
    }

    private fun legs() {
        val l = o.items[GearSlot.LEGS]
        val r = l?.rarity ?: Rarity.COMMON
        if (l?.base == "chain_leggings") for (i in 0..1) shell(0.9, Doll.ARMOR, chain(r), "thigh$i", "knee$i", "shin$i")
        val greaves = l?.base == "greaves"
        // boots: shoes for the plain, riding boots below the knee for the booted
        val high = when (l?.base) { "boots", "greaves", "chain_leggings" -> 0.8; else -> 0.35 }
        val bootMat = if (greaves) metal(r) else if (l?.base == "boots") leather else darkLeather
        for (i in 0..1) {
            val kn = sk.knee[i]; val an = sk.ankle[i]
            shell(if (greaves) 1.4 else 1.0, Doll.BOOTS, bootMat, "foot$i", "ankle$i")
            shell(if (greaves) 1.7 else 1.1, Doll.BOOTS, bootMat, "shin$i") { between(it, kn, an, 1 - high, 1.0) }
            if (greaves) shell(2.0, Doll.BOOTS, metal(r), "knee$i")
            else if (high > 0.5) {
                // the boot's turned-down cuff
                shell(1.8, Doll.BOOTS, darkLeather, "shin$i") { between(it, kn, an, 1 - high, 1 - high + 0.08) }
            }
        }
    }

    // ---------------------------------------------------------------- cloak

    private fun cloak() {
        val c = o.items[GearSlot.CLOAK] ?: return
        val col = m(cloakColor(c.rarity), grain = 0.05)
        val long = c.base == "mantle"
        val hem = (if (long) d.ankleY + 0.04 * h else d.kneeY - 0.05 * h)
        val f = sk.upper.frame(Frame.IDENTITY)
        val top = sk.upper.apply(P3(0.0, d.shoulderY + 0.01 * h, -d.chestDepth * 0.15))
        // the hem trails behind when the hero lunges
        val sway = sk.rig.cloak * sk.s * 1.6
        val bottom = P3(0.0, hem, -d.chestDepth * 0.35 - sway)
        // a short cape over the shoulders, falling into the long cloth behind
        val neck = sk.upper.apply(P3(0.0, d.shoulderY + 0.035 * h, -d.chestDepth * 0.1))
        val shoulders = sk.upper.apply(P3(0.0, d.shoulderY - 0.03 * h, -d.chestDepth * 0.15))
        val cape = RoundCone(neck, shoulders, d.shoulderX * 0.45, d.shoulderX * 1.08 + 0.03 * h, BodyPart.GEAR, Doll.CLOAK)
        val fall = RoundCone(shoulders, bottom, d.shoulderX * 1.08 + 0.03 * h, d.shoulderX * 1.2 + 0.04 * h, BodyPart.GEAR, Doll.CLOAK)
        val shape = Union(listOf(cape, fall), 3.0, BodyPart.GEAR, Doll.CLOAK)
        val oval = Squash(shape, shoulders, f, P3(1.0, 1.0, 0.6), BodyPart.GEAR, Doll.CLOAK)
        val folds = Folds(oval, shoulders, (shoulders - bottom).norm(), 11.0, 0.6, BodyPart.GEAR, Doll.CLOAK)
        val s = add(Hollow(folds, 0.55, BodyPart.GEAR, Doll.CLOAK), col)
        // open at the front, ending at the shoulders and the hem
        s.cut(f.z, shoulders + f.z * (d.chestDepth * 0.35))
        s.cut(f.y, neck)
        s.cut(P3(0.0, -1.0, 0.0), P3(0.0, hem, 0.0))
        // a clasp at each shoulder, a fur collar on the mantle
        for (i in 0..1) add(Ellipsoid(sk.upper.apply(P3(sk.side(i) * d.shoulderX * 0.62, d.shoulderY + 0.006 * h, d.chestDepth * 0.35)), P3(0.012 * h, 0.012 * h, 0.008 * h), f, BodyPart.GEAR, Doll.TRIM), gold)
        if (long) {
            val fur = m(argb(0x7A6450), grain = 0.35)
            add(Ellipsoid(sk.upper.apply(P3(0.0, d.shoulderY + 0.012 * h, -d.chestDepth * 0.25)), P3(d.shoulderX * 0.95, 0.03 * h, d.chestDepth * 0.95), f, BodyPart.GEAR, Doll.TRIM), fur)
                .cut(f.z, top + f.z * (d.chestDepth * 0.25))
        }
    }

    // ---------------------------------------------------------------- headgear

    private fun headgear() {
        val hx = sk.head
        val k = d.hh
        val c = d.headC
        val g = o.items[GearSlot.HEAD]
        val skull = bones("skull")
        val r = g?.rarity ?: Rarity.COMMON
        fun hp(p: P3) = hx.apply(c + p)
        fun hn(n: P3) = hx.dir(n.norm())
        when (g?.base) {
            "hood" -> {
                val col = m(cloakColor(r), grain = 0.05)
                val face = Ellipsoid(hp(P3(0.0, -0.1 * k, 0.5 * k)), P3(0.27 * k, 0.4 * k, 0.4 * k), hx.frame(Frame.IDENTITY), BodyPart.GEAR, Doll.HELM)
                for (s in skull) add(Shell(s, 0.09 * k, BodyPart.GEAR, Doll.HELM), col, null, s.rest).holes += face
                // the cowl lying on the shoulders
                val cowl = RoundCone(hp(P3(0.0, -0.4 * k, -0.05 * k)), sk.upper.apply(P3(0.0, d.shoulderY - 0.01 * h, -0.02 * h)), 0.4 * k, d.shoulderX * 0.85, BodyPart.GEAR, Doll.HELM)
                add(Hollow(cowl, 0.6, BodyPart.GEAR, Doll.HELM), col).also { it.holes += face; it.cut(-upN, upY(d.shoulderY - 0.05 * h)) }
            }
            "leather_cap" -> for (s in skull) add(Shell(s, 0.05 * k, BodyPart.GEAR, Doll.HELM), leather, null, s.rest).cut(hn(P3(0.0, -1.0, 0.45)), hp(P3(0.0, 0.12 * k, 0.0)))
            "helmet" -> {
                val st = metal(r)
                for (s in skull) add(Shell(s, 0.07 * k, BodyPart.GEAR, Doll.HELM), st, null, s.rest).cut(hn(P3(0.0, -1.0, 0.55)), hp(P3(0.0, 0.1 * k, 0.0)))
                // a nasal and a rim
                add(Box(hp(P3(0.0, -0.02 * k, 0.48 * k)), P3(0.035 * k, 0.12 * k, 0.02 * k), hx.frame(Frame.IDENTITY), 0.3, BodyPart.GEAR, Doll.TRIM), st)
                for (s in skull) add(Shell(s, 0.1 * k, BodyPart.GEAR, Doll.TRIM), metal(r, -0.12), null, s.rest).also {
                    it.cut(hn(P3(0.0, -1.0, 0.55)), hp(P3(0.0, 0.1 * k, 0.0)))
                    it.cut(hn(P3(0.0, 1.0, -0.55)), hp(P3(0.0, 0.16 * k, 0.0)))
                }
            }
            "great_helm" -> {
                val st = metal(r)
                val slit = m(argb(0x14100E))
                val cross = metal(r, 0.1)
                val helm = RoundCone(hp(P3(0.0, -0.45 * k, 0.04 * k)), hp(P3(0.0, 0.3 * k, -0.02 * k)), 0.5 * k, 0.48 * k, BodyPart.GEAR, Doll.HELM)
                add(helm, st, { p ->
                    val q = p - c
                    when {
                        q.z > 0.15 * k && abs(q.y - 0.0) < 0.035 * k && abs(q.x) > 0.04 * k -> slit
                        q.z > 0.15 * k && abs(q.x) < 0.04 * k && q.y < 0.0 -> cross
                        else -> st
                    }
                }, hx::inverse)
            }
            "circlet" -> {
                for (s in skull) add(Shell(s, 0.03 * k, BodyPart.GEAR, Doll.HELM), gold, null, s.rest).also {
                    it.cut(hn(P3(0.0, 1.0, 0.3)), hp(P3(0.0, 0.2 * k, 0.0)))
                    it.cut(hn(P3(0.0, -1.0, -0.3)), hp(P3(0.0, 0.13 * k, 0.0)))
                }
                add(Ellipsoid(hp(P3(0.0, 0.2 * k, 0.43 * k)), P3(0.05 * k, 0.05 * k, 0.03 * k), hx.frame(Frame.IDENTITY), BodyPart.GEAR, Doll.TRIM), m(r.color.toInt(), shine = 1.0))
            }
            null -> if (o.cls == CharClass.WIZARD) {
                // the wizard's hat: a brim and a crown bending back at the tip
                val hat = m(worn(look.cloth, 0.3), grain = 0.05)
                add(Ellipsoid(hp(P3(0.0, 0.18 * k, -0.02 * k)), P3(0.75 * k, 0.05 * k, 0.75 * k), hx.frame(Frame.IDENTITY), BodyPart.GEAR, Doll.HELM), hat)
                add(RoundCone(hp(P3(0.0, 0.2 * k, -0.02 * k)), hp(P3(0.0, 0.85 * k, -0.25 * k)), 0.4 * k, 0.12 * k, BodyPart.GEAR, Doll.HELM), hat)
                add(RoundCone(hp(P3(0.0, 0.85 * k, -0.25 * k)), hp(P3(0.0, 1.05 * k, -0.6 * k)), 0.12 * k, 0.04 * k, BodyPart.GEAR, Doll.HELM), hat)
                for (s in skull) add(Shell(s, 0.06 * k, BodyPart.GEAR, Doll.HELM), m(argb(0x8A6A3A)), null, s.rest).also {
                    it.cut(hn(P3(0.0, 1.0, 0.0)), hp(P3(0.0, 0.26 * k, 0.0)))
                    it.cut(hn(P3(0.0, -1.0, 0.0)), hp(P3(0.0, 0.19 * k, 0.0)))
                }
            }
        }
    }

    // ---------------------------------------------------------------- off hand: shield and foci

    /** The shield's face, square to the forearm it is strapped to. */
    private fun shieldNormal(): P3 {
        val a = (sk.wrist[0] - sk.elbow[0]).norm()
        val f = sk.shieldFace
        return (f - a * (f dot a)).norm()
    }

    private fun offHand() {
        val off = o.items[GearSlot.OFF_HAND] ?: return
        if (o.twoHands) return
        val r = off.rarity
        val hand = sk.hand(0)
        when {
            off.def.kind == BaseKind.SHIELD -> shield(off.base == "tower_shield", r)
            off.def.icon == Icon.ORB -> {
                val glow = mix(argb(0x80C8FF), r.color.toInt(), 0.4)
                add(Ellipsoid(hand + P3(0.0, 0.05 * h, 0.01 * h), P3(0.04 * h, 0.04 * h, 0.04 * h), Frame.IDENTITY, BodyPart.GEAR, Doll.ITEM), m(glow, shine = 1.0, bias = 0.15))
            }
            off.def.icon == Icon.TOME -> add(Box(hand + P3(0.0, 0.0, 0.02 * h), P3(0.05 * h, 0.065 * h, 0.018 * h), Frame.along((sk.wrist[0] - sk.elbow[0]).norm()), 0.5, BodyPart.GEAR, Doll.ITEM),
                m(worn(mix(argb(0x6A2A22), r.color.toInt(), 0.3), 0.2)))
            off.def.icon == Icon.SYMBOL -> add(Ellipsoid(hand + P3(0.0, 0.03 * h, 0.012 * h), P3(0.025 * h, 0.025 * h, 0.008 * h), Frame.IDENTITY, BodyPart.GEAR, Doll.ITEM), gold)
        }
    }

    private fun shield(tower: Boolean, r: Rarity) {
        val el = sk.elbow[0]; val wr = sk.wrist[0]
        val n = shieldNormal()
        val fore = (wr - el).norm()
        var up = (n cross fore).let { if (it.y < 0) -it else it }
        // held upright, however the forearm lies
        up = (up + P3(0.0, 4.0, 0.0) - n * (n.y * 4.0)).norm()
        val ax = (up cross n).norm()
        val f = Frame(ax, up, n)
        // strapped to the forearm in its upper third: the arm runs across the back there, the board hangs below
        val hw = (if (tower) 0.2 else 0.165) * h
        val ht = (if (tower) 0.6 else 0.41) * h
        val center = el.lerp(wr, 0.55) + n * (0.02 * h)
        val strapY = if (tower) ht / 6 else ht * 0.42 - ht / 3
        val outline: (Double, Double) -> Double = if (tower) { x, y -> roundRect(x, y + 0.0, hw, ht / 2, 0.03 * h) } else heater(hw, ht)
        val c0 = center - up * strapY
        val paintRgb = worn(if (r >= Rarity.RARE) mix(argb(0x7A2A22), r.color.toInt(), 0.45) else argb(0x6E2E24), 0.15)
        val face = m(paintRgb)
        val stripe = m(argb(0xC8BCA0))
        val rim = metal(r)
        val planks = wood
        val strap = darkLeather
        val board = Board(c0, f, max(hw, ht / 2) * 1.2, 0.022 * h, 0.08 * h, outline, BodyPart.GEAR, Doll.SHIELD)
        shieldBoard = board
        add(board, face, { _ -> face }, null)
        board.paint = { p ->
            val l = board.local(p)
            val edge = outline(l.x, l.y)
            when {
                edge > -0.02 * h -> rim
                l.z > 0 -> if (abs(l.y - ht * 0.08) < 0.016 * h) stripe else face
                abs(l.y - strapY + 0.03 * h) < 0.011 * h || abs(l.y - strapY - 0.03 * h) < 0.011 * h -> strap
                frac(l.x / (0.05 * h)) < 0.08 -> planks.copy(bias = -0.15)
                else -> planks
            }
        }
        // the iron boss in the middle of the face
        add(Ellipsoid(c0 + up * (ht * 0.0) + n * (0.012 * h), P3(0.035 * h, 0.035 * h, 0.022 * h), f, BodyPart.GEAR, Doll.ITEM), rim)
    }

    /** The shield's board once [solids] has run, for checks. */
    var shieldBoard: Board? = null
        private set

    /** Where along the main weapon (0 at the hand, 1 at the tip) it would pass through the shield, or null. */
    fun weaponThroughShield(): Double? {
        val b = shieldBoard ?: return null
        val main = o.items[GearSlot.MAIN_HAND] ?: return null
        val len = reach(main.base)
        val hand = sk.hand(1)
        for (i in 0..40) { val t = i / 40.0; if (b.dist(hand + sk.weapon * (len * t)) < 0.6) return t }
        return null
    }

    /** Where along the main weapon it would pass through the hero's own head or body (not the hand holding it), or null. */
    fun weaponThroughBody(): Double? {
        val main = o.items[GearSlot.MAIN_HAND] ?: return null
        if (main.def.ranged) return null
        val len = reach(main.base)
        val hand = sk.hand(1)
        // the hands holding it are not in its way; with two hands or a bracing forearm, neither is the free arm
        val holding = if (o.twoHands) setOf("hand1", "fore1", "upper1", "delt1", "hand0", "fore0") else setOf("hand1", "fore1", "upper1", "delt1")
        val solid = body.filter { it.key !in holding && it.part != BodyPart.HAIR }
        // the grip is inside the fist; check from just beyond it
        for (i in 4..40) { val t = i / 40.0; val p = hand + sk.weapon * (len * t); if (solid.any { it.dist(p) < -0.5 }) return t }
        return null
    }

    private fun reach(base: String) = Dress.reach(base)

    // ---------------------------------------------------------------- weapons, drawn over the doll

    /** Draws the weapons into [img], pixel by pixel in front of or behind the doll. */
    fun overlay(img: DepthImage) {
        val main = o.items[GearSlot.MAIN_HAND]
        if (main != null && !main.def.ranged) weapon(img, main.base, main.rarity, sk.hand(1), sk.weapon)
        val off = o.items[GearSlot.OFF_HAND]
        if (off != null && off.def.isWeapon && !o.twoHands) weapon(img, off.base, off.rarity, sk.hand(0), P3(sk.weapon.x * -0.5, sk.weapon.y, sk.weapon.z).norm())
    }

    private fun weapon(img: DepthImage, base: String, r: Rarity, hand: P3, dir: P3) {
        val w = img.img.width; val hgt = img.img.height
        val layer = Sculpt(w, hgt, 31)
        val (hx, hy, hz) = img.project(hand)
        val (tx, ty, tz) = img.project(hand + dir * 20.0)
        val dx = tx - hx; val dy = ty - hy
        val len = sqrt(dx * dx + dy * dy)
        // weapon drawings are in units of the old figure; small folk carry somewhat smaller arms
        val k = img.px * 1.636 * sqrt(h / 175.0)
        layer.transform(0.0, 0.0, k, k, hx, hy)
        WeaponArt(layer).draw(base, r, hx, hy, Math.toDegrees(atan2(dy, dx)), 0.0, (len / (20.0 * img.px)).coerceIn(0.2, 1.15))
        val l2 = (dx * dx + dy * dy).coerceAtLeast(1e-6)
        for (y in 0 until hgt) for (x in 0 until w) {
            val p = layer.img[x, y]
            if ((p ushr 24) < 128) continue
            val t = ((x + 0.5 - hx) * dx + (y + 0.5 - hy) * dy) / l2
            val z = hz + (tz - hz) * t
            val at = y * w + x
            if (img.depth[at] > z + 0.8) continue
            img.img.set(x, y, p)
            img.depth[at] = z
        }
    }

    companion object {
        /** About how far a weapon reaches beyond the hand, in cm. */
        fun reach(base: String) = when (base) {
            "dagger" -> 30.0; "shortsword", "handaxe", "wand" -> 60.0; "mace", "scimitar" -> 75.0
            "longsword", "rapier", "battleaxe", "warhammer" -> 90.0; "greatsword" -> 125.0; "greataxe", "maul" -> 105.0; "quarterstaff", "staff" -> 120.0; else -> 100.0
        }

        fun frac(v: Double) = v - floor(v)

        fun roundRect(x: Double, y: Double, hw: Double, hh: Double, r: Double): Double {
            val qx = abs(x) - hw + r; val qy = abs(y) - hh + r
            return sqrt(max(qx, 0.0) * max(qx, 0.0) + max(qy, 0.0) * max(qy, 0.0)) + min(max(qx, qy), 0.0) - r
        }

        /** A heater shield: flat top, sides curving down to a point. Its top edge at y = 0.5·height·0.6. */
        fun heater(hw: Double, ht: Double): (Double, Double) -> Double {
            val top = ht * 0.42
            val bottom = top - ht
            // two arcs through the top corners meeting at the point below
            val rr = (hw * hw + (top - bottom) * (top - bottom)) / (2 * hw)
            return { x, y ->
                val dl = sqrt((x - (hw - rr)) * (x - (hw - rr)) + (y - top) * (y - top)) - rr
                val dr = sqrt((x + (hw - rr)) * (x + (hw - rr)) + (y - top) * (y - top)) - rr
                max(max(dl, dr), y - top)
            }
        }
    }
}
