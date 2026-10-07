package de.bornim.core.art

import de.bornim.core.BaseKind
import de.bornim.core.CharClass
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Icon
import de.bornim.core.Rarity
import de.bornim.core.Weight
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * What a hero wears and holds, slot by slot. A foe's gear can be [rusty] (old iron, flaking brown) or [crude]
 * (a shield of bare nailed planks): a look only, not a kind of item.
 */
class Outfit(val cls: CharClass, val items: Map<GearSlot, Gear>, val rusty: Boolean = false, val crude: Boolean = false, val pelt: Boolean = false) {
    fun base(slot: GearSlot): String? = items[slot]?.base
    fun rarity(slot: GearSlot): Rarity = items[slot]?.rarity ?: Rarity.COMMON
    val twoHands: Boolean get() = items[GearSlot.MAIN_HAND]?.def?.let { it.twoHanded && !it.ranged } == true
    val hasShield: Boolean get() = items[GearSlot.OFF_HAND]?.def?.kind == BaseKind.SHIELD && !twoHands

    companion object {
        fun of(hero: Hero) = Outfit(hero.cls, GearSlot.entries.mapNotNull { s -> hero.item(s)?.let { s to it } }.toMap())

        /** A foe's kit as an outfit to dress its doll in. */
        fun of(kit: de.bornim.core.MonsterKit) = Outfit(CharClass.FIGHTER,
            kit.items.mapValues { (_, base) -> Gear(0, base, Rarity.COMMON, 1) }, kit.rusty, kit.crude, kit.pelt)
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
    private fun metal(r: Rarity, bias: Double = 0.0) = if (o.rusty) m(argb(0x6A5444), shine = 0.25, grain = 0.55, bias = bias - 0.04)
        else m(mix(argb(0x868E98), r.color.toInt(), if (r >= Rarity.RARE) 0.16 else 0.0), shine = 0.9, bias = bias - 0.04)
    private val darkSteel = m(argb(0x6E7680), shine = 0.6)
    private val leather = m(argb(0x6A4A32), grain = 0.07)
    private val darkLeather = m(argb(0x3E2C22), grain = 0.05)
    private val gold = m(argb(0xB8904A), shine = 0.7)
    private val wood = m(argb(0x6E4A2C), grain = 0.12)
    private val cloth = m(worn(look.cloth), grain = 0.05)
    private val clothDark = m(worn(look.clothDark, 0.45), grain = 0.05)
    private val pants = m(worn(look.pants, 0.3), grain = 0.05)
    private fun chain(r: Rarity) = if (o.rusty) m(argb(0x5E4A3C), shine = 0.2, grain = 0.6) else m(mix(argb(0x8A9098), r.color.toInt(), if (r >= Rarity.RARE) 0.12 else 0.0), shine = 0.4, grain = 0.45)
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
        // creatures bring their own: a goblin's rag, a skeleton's bare bones
        if (d.kind == null) clothes()
        armour()
        if (o.pelt) furMantle()
        arms()
        // a creature goes barefoot and beltless unless it wears something there
        if (d.kind == null || o.items[GearSlot.LEGS] != null) legs()
        if (d.kind == null || chest != null) belt()
        cloak()
        headgear()
        offHand()
        bow()
        crossbow()
        staff()
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
        if (d.kind == null && (heavy || medium) && chestBase != "scale_mail" && (o.cls == CharClass.FIGHTER || o.cls == CharClass.CLERIC)) tabard(if (plated) 2.8 else 1.6)
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
        // a cleric's tabard bears the golden sun of the shield on breast and back: a disc, a ring and eight rays
        val sunY = beltY + (d.shoulderY - beltY) * 0.58
        val sun: ((P3) -> Mat)? = if (o.cls != CharClass.CLERIC) null else { p ->
            val rr = sqrt(p.x * p.x + (p.y - sunY) * (p.y - sunY))
            val ray = abs(frac(atan2(p.y - sunY, p.x) / (2 * PI) * 8 + 0.5) - 0.5) * rr
            if ((rr < 0.012 * h || abs(rr - 0.021 * h) < 0.0045 * h || (rr in 0.021 * h..0.034 * h && ray < 0.005 * h))) gold else col
        }
        for (b in bones("torso", "waist")) {
            val s = add(Shell(b, over + 0.5, BodyPart.GEAR, Doll.TRIM), col, sun, b.rest)
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

    /** A goblin's mangy pelt over the shoulders, tied at the chest, its lower edge ragged. */
    private fun furMantle() {
        val fur = m(argb(0x2E2620), grain = 0.7)
        val furLight = m(argb(0x4A3C30), grain = 0.7)
        val edge = d.shoulderY - 0.42 * d.trunk
        val paint: (P3) -> Mat = { p -> if (frac(p.x * 0.7 + p.y * 0.3) < 0.35) furLight else fur }
        for (b in bones("torso")) add(Shell(b, 2.6, BodyPart.GEAR, Doll.CLOAK), fur, paint, b.rest).also {
            // ragged: the cut tilts a little each way round the body
            it.cut(-upN, upY(edge))
        }
        for (i in 0..1) shell(2.2, armGroup(i, Doll.CLOTH), fur, "delt$i", paint = paint)
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
        // the cloth lies over the back and the seat, then falls free; the hem spreads with the stride and lags behind a move
        val seat = sk.lower.apply(P3(0.0, d.hipY + 0.1 * h, -d.chestDepth * 0.9 - 0.012 * h - sway * 0.35))
        val stride = abs(sk.rig.stride) * sk.s * 0.4
        val rTop = d.shoulderX * 1.08 + 0.03 * h
        val cape = RoundCone(neck, shoulders, d.shoulderX * 0.45, rTop, BodyPart.GEAR, Doll.CLOAK)
        val back = RoundCone(shoulders, seat, rTop, d.shoulderX * 1.12 + 0.034 * h, BodyPart.GEAR, Doll.CLOAK)
        val fall = RoundCone(seat, bottom, d.shoulderX * 1.12 + 0.034 * h, d.shoulderX * 1.22 + 0.045 * h + stride, BodyPart.GEAR, Doll.CLOAK)
        val shape = Union(listOf(cape, back, fall), 3.0, BodyPart.GEAR, Doll.CLOAK)
        val oval = Squash(shape, shoulders, f, P3(1.0, 1.0, 0.6), BodyPart.GEAR, Doll.CLOAK)
        // the folds ripple as the cloth swings
        val folds = Folds(oval, shoulders, (shoulders - bottom).norm(), 11.0, 0.75, BodyPart.GEAR, Doll.CLOAK, sk.rig.cloak * 0.5)
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

    // ---------------------------------------------------------------- bow, arrow and quiver

    /** A bow in the left hand, standing upright and canted a little, bending further as it is drawn; the string runs to the drawing hand. */
    private fun bow() {
        val main = o.items[GearSlot.MAIN_HAND] ?: return
        if (main.def.icon != Icon.BOW) return
        val r = main.rarity
        val long = main.base == "longbow"
        val len = (if (long) 0.8 else 0.58) * h
        val draw = sk.rig.draw.coerceIn(0.0, 1.0)
        val grip = sk.hand(0)
        val nock = sk.hand(1)
        val aim = (if (draw > 0.05) grip - nock else sk.upper.dir(P3.Z)).norm()
        var up = (P3.Y - aim * (P3.Y dot aim)).norm()
        up = (up + (aim cross up) * 0.15).norm()
        // carried undrawn, the bow leans its upper limb towards the foe
        val tilt = Math.toRadians(sk.rig.bowTilt * (1 - draw.coerceIn(0.0, 1.0)))
        if (abs(tilt) > 1e-3) up = (up * kotlin.math.cos(tilt) + aim * kotlin.math.sin(tilt)).norm()
        val bend = len * (0.09 + 0.1 * draw)
        fun at(t: Double) = grip + up * (t * len / 2) + aim * (-bend * t * t + bend * 0.15)
        fun thick(t: Double) = (0.012 - 0.0065 * abs(t)) * h
        val woodMat = m(mix(argb(0x5E3E24), r.color.toInt(), if (r >= Rarity.RARE) 0.3 else 0.0), grain = 0.05)
        val n = 10
        for (k in 0 until n) {
            val t0 = -1.0 + 2.0 * k / n; val t1 = -1.0 + 2.0 * (k + 1) / n
            add(RoundCone(at(t0), at(t1), thick(t0), thick(t1), BodyPart.GEAR, Doll.ITEM), woodMat)
        }
        add(RoundCone(at(-0.12), at(0.12), 0.014 * h, 0.014 * h, BodyPart.GEAR, Doll.ITEM), darkLeather)
        // the string, straight when slack, to the drawing fingers when drawn
        val str = m(argb(0xD8D0C0))
        val tipA = at(-1.0); val tipB = at(1.0)
        val mid = if (draw > 0.05) nock + aim * (0.01 * h) else tipA.lerp(tipB, 0.5)
        add(RoundCone(tipA, mid, 0.25, 0.25, BodyPart.GEAR, Doll.ITEM), str)
        add(RoundCone(mid, tipB, 0.25, 0.25, BodyPart.GEAR, Doll.ITEM), str)
        // the arrow on the string
        if (draw > 0.2) {
            val shaft = m(argb(0x8A6A44), grain = 0.05)
            val tip = mid + aim * (0.44 * h)
            add(RoundCone(mid, tip, 0.35, 0.35, BodyPart.GEAR, Doll.ITEM), shaft)
            add(RoundCone(tip, tip + aim * (0.025 * h), 0.9, 0.1, BodyPart.GEAR, Doll.ITEM), metal(r))
            add(Ellipsoid(mid + aim * (0.03 * h), P3(0.006 * h, 0.03 * h, 0.006 * h), Frame.along(aim), BodyPart.GEAR, Doll.ITEM), m(argb(0xB8B0A0)))
        }
        // the quiver on the back, its fletchings showing over the shoulder
        val top = sk.upper.apply(P3(d.shoulderX * 0.45, d.shoulderY - 0.01 * h, -d.chestDepth - 0.035 * h))
        val bottom = sk.upper.apply(P3(-d.shoulderX * 0.15, d.hipY + 0.15 * d.trunk, -d.chestDepth - 0.035 * h))
        add(RoundCone(bottom, top, 0.03 * h, 0.034 * h, BodyPart.GEAR, Doll.ITEM), leather)
        val dirQ = (top - bottom).norm()
        for (k in 0..2) add(Ellipsoid(top + dirQ * (0.03 * h) + sk.upper.dir(P3((k - 1) * 0.012 * h, 0.0, 0.0)), P3(0.006 * h, 0.022 * h, 0.006 * h), Frame.along(dirQ), BodyPart.GEAR, Doll.TRIM), m(argb(0xC8BCA0)))
    }

    /** A light crossbow, built in the round so it reads from every side: stock, butt, steel prod, string, bolt and stirrup. */
    private fun crossbow() {
        val main = o.items[GearSlot.MAIN_HAND] ?: return
        if (main.base != "light_crossbow") return
        val r = main.rarity
        val aim = sk.weapon.norm()
        val up = (P3.Y - aim * (P3.Y dot aim)).norm()
        val side = (up cross aim).norm()
        val s0 = sk.hand(1) + up * (Doll.STOCK_ABOVE_HAND * h)
        val wood = m(mix(argb(0x5A3A22), r.color.toInt(), if (r >= Rarity.RARE) 0.3 else 0.0), grain = 0.06)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, mat: Mat, group: Int = Doll.ITEM) = add(RoundCone(a, b, ra, rb, BodyPart.GEAR, group), mat)
        // the stock, level along the aim, to the butt plate that sits square against the front of the shoulder
        val rear = s0 - aim * (Doll.STOCK_BACK * h)
        val plate = rear - up * (Doll.BUTT_DROP * h)
        cone(rear + aim * (0.02 * h), s0 + aim * (0.29 * h), 0.011 * h, 0.009 * h, wood)
        cone(rear + aim * (0.07 * h), plate + up * (0.012 * h) + aim * (0.008 * h), 0.009 * h, 0.012 * h, wood)
        cone(plate + up * (0.024 * h), plate - up * (0.03 * h), Doll.BUTT_HALF * h, Doll.BUTT_HALF * h * 0.85, wood)
        cone(s0 - up * (0.012 * h) + aim * (0.012 * h), s0 - up * (0.032 * h) - aim * (0.012 * h), 0.003 * h, 0.0025 * h, metal(r), Doll.TRIM)
        // the prod across the front, bent back by the string while spanned
        val draw = sk.rig.draw.coerceIn(0.0, 1.0)
        val prod = s0 + aim * (0.26 * h) + up * (0.004 * h)
        val bend = (0.018 + 0.03 * draw) * h
        fun at(t: Double) = prod + side * (t * 0.17 * h) - aim * (bend * t * t)
        val n = 6
        for (k in 0 until 2 * n) {
            val t0 = -1.0 + k.toDouble() / n; val t1 = -1.0 + (k + 1).toDouble() / n
            cone(at(t0), at(t1), (0.0085 - 0.004 * abs(t0)) * h, (0.0085 - 0.004 * abs(t1)) * h, metal(r))
        }
        // the string, to the nut when spanned, straight across when loosed
        val nut = s0 + aim * (0.08 * h) + up * (0.011 * h)
        val mid = at(1.0).lerp(at(-1.0), 0.5).lerp(nut, draw)
        val str = m(argb(0xD8D0C0))
        cone(at(-1.0), mid, 0.25, 0.25, str); cone(mid, at(1.0), 0.25, 0.25, str)
        // the bolt in its groove
        if (draw > 0.5) {
            val tip = prod + aim * (0.05 * h) + up * (0.008 * h)
            cone(nut + up * (0.002 * h), tip, 0.4, 0.4, m(argb(0x8A6A44), grain = 0.05))
            cone(tip, tip + aim * (0.018 * h), 0.9, 0.1, metal(r))
        }
        // the stirrup at the front, for the foot when spanning
        val front = s0 + aim * (0.295 * h)
        cone(front + side * (0.022 * h), front + aim * (0.05 * h), 0.0028 * h, 0.0028 * h, metal(r), Doll.TRIM)
        cone(front - side * (0.022 * h), front + aim * (0.05 * h), 0.0028 * h, 0.0028 * h, metal(r), Doll.TRIM)
    }

    /** Staves and wands, built in the round: a long shaft held below its middle, or a short rod in line with the hand. */
    private fun staff() {
        val main = o.items[GearSlot.MAIN_HAND] ?: return
        if (main.base !in ROUND) return
        val r = main.rarity
        val dir = sk.weapon.norm()
        val hand = sk.hand(1)
        // staves are cut to the bearer: a halfling's staff is as tall as a halfling
        val k = h / 175.0
        val side = (if (abs(dir.y) > 0.9) P3.X else (P3.Y cross dir)).norm()
        val glowRgb = glowColour()
        fun cone(a: P3, b: P3, ra: Double, rb: Double, mat: Mat, group: Int = Doll.ITEM) = add(RoundCone(a, b, ra, rb, BodyPart.GEAR, group), mat)
        val shine = m(glowRgb, shine = 1.0, bias = 0.12 + 0.3 * sk.rig.glow)
        when (main.base) {
            "wand" -> {
                val tip = hand + dir * (0.1 * h * k)
                cone(hand - dir * (0.015 * h), tip, 0.0055 * h, 0.0035 * h, m(argb(0x3A2618), grain = 0.05))
                cone(tip - dir * (0.012 * h), tip - dir * (0.006 * h), 0.0048 * h, 0.0048 * h, gold, Doll.TRIM)
                add(Ellipsoid(tip + dir * (0.004 * h), P3(0.0055 * h, 0.0055 * h, 0.0055 * h), Frame.IDENTITY, BodyPart.GEAR, Doll.TRIM), shine)
            }
            else -> {
                val len = reach(main.base) * k * 0.95
                val top = hand + dir * len
                val butt = hand - dir * (len * buttPart(main.base))
                val wood = m(mix(argb(if (main.base == "staff") 0x3E2A1C else 0x6A5034), r.color.toInt(), if (r >= Rarity.RARE) 0.25 else 0.0), grain = 0.08)
                if (main.base == "staff") {
                    // a gnarled shaft, thickening to a knot under three carved claws that hold the crystal
                    val n = 7
                    val up2 = (dir cross side).norm()
                    fun at(t: Double) = butt.lerp(top, t) + side * (0.004 * h * kotlin.math.sin(t * 17.0)) + up2 * (0.003 * h * kotlin.math.cos(t * 11.0))
                    for (i in 0 until n) { val t0 = i / n.toDouble() * 0.96; val t1 = (i + 1) / n.toDouble() * 0.96; cone(at(t0), at(t1), (0.0085 + 0.002 * t0) * h, (0.0085 + 0.002 * t1) * h, wood) }
                    add(Ellipsoid(at(0.93), P3(0.014 * h, 0.018 * h, 0.014 * h), Frame.along(dir), BodyPart.GEAR, Doll.ITEM), wood)
                    val crystal = top + dir * (0.012 * h)
                    for (c in 0..2) {
                        val a = c * 2.0 * Math.PI / 3
                        val out = side * kotlin.math.cos(a) + up2 * kotlin.math.sin(a)
                        cone(at(0.95), crystal + out * (0.013 * h) + dir * (0.012 * h), 0.004 * h, 0.0018 * h, wood, Doll.TRIM)
                    }
                    add(Ellipsoid(crystal, P3(0.011 * h, 0.019 * h, 0.011 * h), Frame.along(dir), BodyPart.GEAR, Doll.TRIM), shine)
                } else {
                    // a plain fighting staff, shod with iron at both ends and wrapped where the hands go
                    cone(butt, top, 0.0095 * h, 0.0095 * h, wood)
                    cone(butt, butt + dir * (0.04 * h), 0.0105 * h, 0.0105 * h, metal(r), Doll.TRIM)
                    cone(top - dir * (0.04 * h), top, 0.0105 * h, 0.0105 * h, metal(r), Doll.TRIM)
                    cone(hand - dir * (0.1 * h), hand + dir * (0.03 * h), 0.0105 * h, 0.0105 * h, darkLeather, Doll.TRIM)
                }
            }
        }
    }

    /** The colour a spell glows in: holy gold with a symbol, otherwise arcane blue, tinted by the focus's rarity. */
    fun glowColour(): Int {
        val off = o.items[GearSlot.OFF_HAND]
        val main = o.items[GearSlot.MAIN_HAND]
        val holy = off?.def?.icon == Icon.SYMBOL || (o.cls == CharClass.CLERIC && off?.def?.icon != Icon.ORB)
        val r = (if (sk.rig.glowAt > 0.5) off?.rarity else main?.rarity) ?: Rarity.COMMON
        return mix(argb(if (holy) 0xFFD87A else 0x80C8FF), r.color.toInt(), if (r >= Rarity.UNCOMMON) 0.35 else 0.0)
    }

    /** Where the spell gathers: the staff's crystal, the wand's tip, the weapon's head, or the free hand and its focus. */
    fun glowPoint(): P3 {
        val main = o.items[GearSlot.MAIN_HAND]
        if (sk.rig.glowAt > 0.5) return sk.hand(0) + P3(0.0, 0.035 * h, 0.01 * h)
        val k = h / 175.0
        return when (main?.base) {
            null -> sk.hand(1) + P3(0.0, 0.02 * h, 0.0)
            "wand" -> sk.hand(1) + sk.weapon * (0.1 * h * k + 0.004 * h)
            "staff" -> sk.hand(1) + sk.weapon * (reach("staff") * k * 0.95 + 0.012 * h)
            else -> sk.hand(1) + sk.weapon * (reach(main.base) * k * 0.85)
        }
    }

    /** The light of a spell: a soft halo over everything near where it gathers, brighter as it is let go. */
    fun glowHalo(img: DepthImage) {
        val g = sk.rig.glow
        if (g < 0.02) return
        val (cx, cy, _) = img.project(glowPoint())
        val rad = (0.03 + 0.05 * g) * h * img.px
        val c = glowColour()
        val w = img.img.width; val hgt = img.img.height
        val x0 = max(0, (cx - rad).toInt()); val x1 = min(w - 1, (cx + rad).toInt())
        val y0 = max(0, (cy - rad).toInt()); val y1 = min(hgt - 1, (cy + rad).toInt())
        for (y in y0..y1) for (x in x0..x1) {
            val d = sqrt((x + 0.5 - cx) * (x + 0.5 - cx) + (y + 0.5 - cy) * (y + 0.5 - cy)) / rad
            if (d >= 1) continue
            val a = (1 - d) * (1 - d) * (0.35 + 0.55 * g)
            val p = img.img[x, y]
            // over the figure the light tints it; in the air around it, it is the light alone, see-through at its edge
            val solid = (p ushr 24) >= 128
            val base = if (solid) p else c
            val outA = if (solid) 0xFF else max(p ushr 24, (a * 255).toInt().coerceIn(0, 255))
            val rr = ((base shr 16 and 0xFF) * (1 - a) + (c shr 16 and 0xFF) * a).toInt()
            val gg = ((base shr 8 and 0xFF) * (1 - a) + (c shr 8 and 0xFF) * a).toInt()
            val bb = ((base and 0xFF) * (1 - a) + (c and 0xFF) * a).toInt()
            img.img.set(x, y, (outA shl 24) or (rr shl 16) or (gg shl 8) or bb)
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
            off.def.kind == BaseKind.SHIELD -> shield(off.base, r)
            off.def.icon == Icon.ORB -> {
                val glow = mix(argb(0x80C8FF), r.color.toInt(), 0.4)
                add(Ellipsoid(hand + P3(0.0, 0.05 * h, 0.01 * h), P3(0.04 * h, 0.04 * h, 0.04 * h), Frame.IDENTITY, BodyPart.GEAR, Doll.ITEM), m(glow, shine = 1.0, bias = 0.15))
            }
            off.def.icon == Icon.TOME -> add(Box(hand + P3(0.0, 0.0, 0.02 * h), P3(0.05 * h, 0.065 * h, 0.018 * h), Frame.along((sk.wrist[0] - sk.elbow[0]).norm()), 0.5, BodyPart.GEAR, Doll.ITEM),
                m(worn(mix(argb(0x6A2A22), r.color.toInt(), 0.3), 0.2)))
            off.def.icon == Icon.SYMBOL -> add(Ellipsoid(hand + P3(0.0, 0.03 * h, 0.012 * h), P3(0.025 * h, 0.025 * h, 0.008 * h), Frame.IDENTITY, BodyPart.GEAR, Doll.ITEM), gold)
        }
    }

    private fun shield(base: String, r: Rarity) {
        val tower = base == "tower_shield"
        val round = base == "round_shield"
        val el = sk.elbow[0]; val wr = sk.wrist[0]
        val n = shieldNormal()
        val fore = (wr - el).norm()
        var up = (n cross fore).let { if (it.y < 0) -it else it }
        // held upright, however the forearm lies
        up = (up + P3(0.0, 4.0, 0.0) - n * (n.y * 4.0)).norm()
        val ax = (up cross n).norm()
        val f = Frame(ax, up, n)
        // strapped to the forearm in its upper third: the arm runs across the back there, the board hangs below;
        // a round shield is held by the middle, the fist behind the boss
        val hw = (if (tower) 0.2 else if (round) 0.175 else 0.165) * h
        val ht = (if (tower) 0.6 else if (round) 0.35 else 0.41) * h
        // big hands need the board further off the forearm, or the fist comes through it
        val center = el.lerp(wr, if (round) 0.75 else 0.55) + n * (0.02 * h + (if (d.kind != null) (d.handK - 1).coerceAtLeast(0.0) * 0.06 * h else 0.0))
        val strapY = if (tower) ht / 6 else if (round) 0.0 else ht * 0.42 - ht / 3
        val outline: (Double, Double) -> Double = when {
            tower -> { x, y -> roundRect(x, y + 0.0, hw, ht / 2, 0.03 * h) }
            round -> { x, y -> sqrt(x * x + y * y) - hw }
            else -> heater(hw, ht)
        }
        val c0 = center - up * strapY
        val paintRgb = when {
            // a crude shield is bare planks, grey with age
            o.crude -> argb(0x5A4632)
            r >= Rarity.RARE -> worn(mix(argb(if (round) 0xE8E0C8 else 0x7A2A22), r.color.toInt(), 0.45), 0.15)
            // the round shield of a servant of the gods: pale, with a golden sun on it
            round -> worn(argb(0xE4DCC4), 0.15)
            else -> worn(argb(0x6E2E24), 0.15)
        }
        val face = m(paintRgb)
        val stripe = if (round) gold else m(argb(0xC8BCA0))
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
                // nailed planks on both faces, a crack here and there, an iron band across
                l.z > 0 && o.crude -> when {
                    abs(l.y - 0.02 * h) < 0.012 * h -> rim
                    frac(l.x / (0.055 * h)) < 0.1 -> planks.copy(bias = -0.25)
                    else -> face.copy(grain = 0.3)
                }
                l.z > 0 && round -> {
                    // a ring round the boss and rays running out from it
                    val rr = sqrt(l.x * l.x + l.y * l.y)
                    val ray = abs(frac(atan2(l.y, l.x) / (2 * PI) * 8 + 0.5) - 0.5) * rr
                    if (abs(rr - 0.07 * h) < 0.012 * h || (rr in 0.07 * h..0.13 * h && ray < 0.012 * h)) stripe else face
                }
                l.z > 0 -> if (abs(l.y - ht * 0.08) < 0.016 * h) stripe else face
                abs(l.y - strapY + 0.03 * h) < 0.011 * h || abs(l.y - strapY - 0.03 * h) < 0.011 * h -> strap
                frac(l.x / (0.05 * h)) < 0.08 -> planks.copy(bias = -0.15)
                else -> planks
            }
        }
        // the iron boss in the middle of the face, gilt on the round shield
        add(Ellipsoid(c0 + up * (ht * 0.0) + n * (0.012 * h), P3(0.035 * h, 0.035 * h, 0.022 * h), f, BodyPart.GEAR, Doll.ITEM), if (round && r < Rarity.RARE && !o.crude) gold else rim)
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
        // staves and wands are built to the body's size, as they are drawn
        val len = if (main.base in ROUND) reach(main.base) * (h / 175.0) * 0.95 else reach(main.base)
        val hand = sk.hand(1)
        // the hands holding it are not in its way; with two hands or a bracing forearm, neither is the free arm
        val holding = if (o.twoHands) setOf("hand1", "fore1", "upper1", "delt1", "hand0", "fore0") else setOf("hand1", "fore1", "upper1", "delt1")
        val solid = body.filter { it.key !in holding && it.part != BodyPart.HAIR }
        // the grip is inside the fist; check from just beyond it
        for (i in 4..40) { val t = i / 40.0; val p = hand + sk.weapon * (len * t); if (solid.any { it.dist(p) < -0.5 }) return t }
        // a staff reaches back past the hand as well
        val back = buttPart(main.base)
        if (back > 0) for (i in 3..(40 * back).toInt()) { val t = i / 40.0; val p = hand - sk.weapon * (len * t); if (solid.any { it.dist(p) < -0.5 }) return -t }
        return null
    }

    /**
     * Which way a blade in the off hand points. A hero's mirrors the main weapon; a foe's goes on from its own forearm,
     * the point forward and a little up, so it never swings round into the body with the main blade.
     */
    private fun offDir(): P3 {
        if (d.kind == null) return P3(sk.weapon.x * -0.5, sk.weapon.y, sk.weapon.z).norm()
        val fore = (sk.wrist[0] - sk.elbow[0]).norm()
        return (fore * 0.55 + sk.upper.dir(P3.Z) * 0.65 + sk.upper.dir(P3.Y) * 0.35 - sk.upper.dir(P3.X) * 0.15).norm()
    }

    /** Where along a blade in the off hand (0 at the hand, 1 at the tip) it would pass into the body, or null. */
    fun offWeaponThroughBody(): Double? {
        val off = o.items[GearSlot.OFF_HAND] ?: return null
        if (!off.def.isWeapon || o.twoHands) return null
        val len = reach(off.base)
        val hand = sk.hand(0)
        val dir = offDir()
        val solid = body.filter { it.key !in setOf("hand0", "fore0", "upper0", "delt0") && it.part != BodyPart.HAIR }
        for (i in 4..40) { val t = i / 40.0; if (solid.any { it.dist(hand + dir * (len * t)) < -0.5 }) return t }
        return null
    }

    private fun reach(base: String) = Dress.reach(base)

    // ---------------------------------------------------------------- weapons, drawn over the doll

    /** Draws the weapons into [img], pixel by pixel in front of or behind the doll. */
    fun overlay(img: DepthImage) {
        val main = o.items[GearSlot.MAIN_HAND]
        if (main != null && !main.def.ranged && main.base !in ROUND) weapon(img, main.base, main.rarity, sk.hand(1), sk.weapon)
        val off = o.items[GearSlot.OFF_HAND]
        if (off != null && off.def.isWeapon && !o.twoHands) weapon(img, off.base, off.rarity, sk.hand(0), offDir())
    }

    private fun weapon(img: DepthImage, base: String, r: Rarity, hand: P3, dir: P3) {
        val w = img.img.width; val hgt = img.img.height
        val layer = Sculpt(w, hgt, 31)
        val (hx, hy, hz) = img.project(hand)
        val (tx, ty, tz) = img.project(hand + dir * 20.0)
        val dx = tx - hx; val dy = ty - hy
        val len = sqrt(dx * dx + dy * dy)
        // weapon drawings are in units of the old figure; small folk carry somewhat smaller arms
        val (along, across) = proportion(base)
        val k = img.px * 1.636 * sqrt(h / 175.0) * across
        layer.transform(0.0, 0.0, k, k, hx, hy)
        WeaponArt(layer).draw(base, r, hx, hy, Math.toDegrees(atan2(dy, dx)), 0.0, (len / (20.0 * img.px)).coerceIn(0.2, 1.15) * along / across)
        val l2 = (dx * dx + dy * dy).coerceAtLeast(1e-6)
        for (y in 0 until hgt) for (x in 0 until w) {
            val p = layer.img[x, y]
            if ((p ushr 24) < 128) continue
            val t = ((x + 0.5 - hx) * dx + (y + 0.5 - hy) * dy) / l2
            val z = hz + (tz - hz) * t
            val at = y * w + x
            if (img.depth[at] > z + 0.8) continue
            img.img.set(x, y, if (o.rusty) rusted(p) else p)
            img.depth[at] = z
        }
    }

    /** Old iron: grey and bright steel turned to flaking brown, wood and leather left as they are. */
    private fun rusted(p: Int): Int {
        val r = (p shr 16) and 255; val g = (p shr 8) and 255; val b = p and 255
        val mx = maxOf(r, g, b); val mn = minOf(r, g, b)
        if (mx - mn > 40 || mx < 60) return p
        val k = 0.55 + 0.25 * (((r * 7 + g * 13 + b) % 5) / 4.0)
        return mix(p, argb(0x7A4E30), k * 0.6).let { mix(it, argb(0x2A2018), 0.12) }
    }

    companion object {
        /** Staves and wands, built in the round rather than drawn over the doll. */
        val ROUND = setOf("staff", "quarterstaff", "wand")
        /** How far a staff reaches back past the hand, as a part of its reach: a wizard's staff is held high, a fighting staff in the middle. */
        fun buttPart(base: String) = when (base) { "staff" -> 1.45; "quarterstaff" -> 1.0; else -> 0.0 }
        /**
         * How a weapon drawing is stretched along its length and across it to true size on a human: swords and pole arms
         * were drawn short, the heads of axes, maces and hammers far too broad. Lengths after it: dagger 38 cm, short sword
         * 68, scimitar 85, longsword and rapier 105, greatsword 145, hand axe 48, battleaxe 85, greataxe 130, mace 65,
         * war hammer 70, maul 120, spear 175, halberd 185.
         */
        fun proportion(base: String): Pair<Double, Double> = when (base) {
            "dagger" -> 1.0 to 0.8; "shortsword" -> 1.3 to 1.0; "scimitar" -> 1.27 to 1.0; "rapier" -> 1.4 to 1.0
            "longsword" -> 1.33 to 1.0; "greatsword" -> 1.37 to 1.0; "handaxe" -> 1.05 to 0.8; "battleaxe" -> 1.3 to 0.8
            "greataxe" -> 1.33 to 0.5; "mace" -> 1.1 to 0.65; "warhammer" -> 1.15 to 0.65; "maul" -> 1.3 to 0.8
            "spear" -> 1.5 to 1.0; "halberd" -> 1.6 to 0.9
            else -> 1.0 to 1.0
        }

        /** About how far a weapon reaches beyond the hand, in cm: the front of its drawing at true size. */
        fun reach(base: String) = when (base) {
            "dagger" -> 28.0; "shortsword" -> 47.0; "scimitar" -> 65.0; "rapier" -> 80.0; "longsword" -> 75.0; "greatsword" -> 103.0
            "handaxe" -> 36.0; "battleaxe" -> 64.0; "greataxe" -> 96.0; "mace" -> 54.0; "warhammer" -> 53.0; "maul" -> 85.0
            "spear" -> 123.0; "halberd" -> 131.0; "wand" -> 60.0; "quarterstaff" -> 85.0; "staff" -> 70.0; else -> 100.0
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
