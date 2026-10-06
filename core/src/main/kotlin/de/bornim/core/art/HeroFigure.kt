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
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The hero in the new battle style: a heroic figure built as a small 3D rig. Joints, weapon and
 * shield have a real place in space and are projected for any facing, so the same figure is seen
 * from the front, from the side or from behind, and turns smoothly between them. Whatever is nearer
 * to us is drawn over what is farther away, so blows always land forward, at the foe.
 *
 * A fight starts now and then with the hero facing us, gear on show, who then turns towards the
 * foe; in an ambush the foe strikes first from behind. The fight itself is seen from behind and the
 * side (three-quarter view): the weapon arm and the blade are in full view and every blow goes to
 * the upper right. After a victory the hero turns back to us in one of several earnest poses.
 */
object HeroFigure {
    const val W = 168
    const val H = 180

    /** Where the feet stand, from the top. */
    const val GROUND = 174

    /** Where the feet stand, from the left. */
    const val ANCHOR_X = 70

    /** How much larger than its layout units the figure is drawn. */
    private const val SIZE = 1.25

    /** Facing in degrees: 0 looks at us, 180 away from us; the foe stands at about 140 (behind and to the right). */
    const val FIGHT_YAW = 138.0

    enum class Act { IDLE, ATTACK, CAST, BLOCK, HURT, INTRO, TURN, AMBUSHED, VICTORY }

    /** How a weapon strikes. */
    enum class Strike { SLASH, THRUST, SMASH, SHOOT, CAST }

    /** A point in the hero's own space: r to the hero's right, u up from the ground, f forward. */
    data class V(val r: Double, val u: Double, val f: Double) {
        operator fun plus(o: V) = V(r + o.r, u + o.u, f + o.f)
        operator fun minus(o: V) = V(r - o.r, u - o.u, f - o.f)
        operator fun times(k: Double) = V(r * k, u * k, f * k)
        fun len() = sqrt(r * r + u * u + f * f)
        fun norm() = this * (1.0 / len().coerceAtLeast(1e-6))
        fun lerp(o: V, t: Double) = V(r + (o.r - r) * t, u + (o.u - u) * t, f + (o.f - f) * t)
    }

    /**
     * Everything that moves. Hands are targets in the hero's own space; [weapon] is the direction
     * the weapon points; [shieldFace] the direction the shield's face looks. [lean] bends the upper
     * body forward (negative: back). [stride] puts the right foot forward.
     */
    data class Rig(
        val yaw: Double = FIGHT_YAW,
        val bodyX: Double = 0.0, val bodyY: Double = 0.0,
        val lean: Double = 0.0, val crouch: Double = 0.0, val stride: Double = 2.0, val spread: Double = 6.0,
        val rh: V = V(10.0, 70.0, 12.0), val weapon: V = V(0.25, 0.8, 0.55),
        val lh: V = V(-9.0, 68.0, 16.0), val shieldFace: V = V(-0.5, 0.0, 1.0),
        val headTurn: Double = 0.0, val headDown: Double = 0.0,
        val cloak: Double = 0.0, val glow: Double = 0.0, val draw: Double = 0.0,
        /** 0..1: a bright arc behind the blade on the fastest frames of a blow. */
        val trail: Double = 0.0,
        /** 0..1: how far the right elbow is lifted to [elbowAt] instead of hanging where the reach puts it. */
        val elbowUp: Double = 0.0,
        val elbowAt: V = V(27.0, 86.0, -4.0),
        /** Degrees the chest turns against the hips, positive to the hero's right (the left shoulder comes forward). */
        val twist: Double = 0.0,
    ) {
        fun lerp(o: Rig, t: Double): Rig {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Rig(
                l(yaw, o.yaw), l(bodyX, o.bodyX), l(bodyY, o.bodyY), l(lean, o.lean), l(crouch, o.crouch), l(stride, o.stride), l(spread, o.spread),
                rh.lerp(o.rh, t), weapon.lerp(o.weapon, t).norm(), lh.lerp(o.lh, t), shieldFace.lerp(o.shieldFace, t).norm(),
                l(headTurn, o.headTurn), l(headDown, o.headDown), l(cloak, o.cloak), l(glow, o.glow), l(draw, o.draw), l(trail, o.trail),
                l(elbowUp, o.elbowUp), elbowAt.lerp(o.elbowAt, t), l(twist, o.twist),
            )
        }
    }

    // ---------------------------------------------------------------- key poses

    val STAND = Rig()
    val BREATHE = STAND.copy(bodyY = 0.7, rh = V(10.0, 69.4, 12.0), lh = V(-9.0, 67.4, 16.0), cloak = 1.0)

    /** Facing us, ready: weapon across the body, shield face towards us. */
    val READY = Rig(yaw = 16.0, stride = 1.0, spread = 8.0, rh = V(13.0, 70.0, 11.0), weapon = V(0.2, 0.85, 0.45), lh = V(-8.0, 68.0, 14.0), shieldFace = V(-0.2, 0.0, 1.0), headTurn = -8.0)
    val READY_B = READY.copy(bodyY = 0.7, rh = V(11.0, 69.4, 11.0), lh = V(-8.0, 67.4, 14.0), cloak = 1.0)
    /** Half way round, seen from the side. */
    val TURNING = Rig(yaw = 80.0, bodyY = 1.0, stride = 4.0, spread = 5.0, rh = V(13.0, 70.0, 10.0), weapon = V(0.3, 0.85, 0.4), lh = V(-10.0, 72.0, 17.0), shieldFace = V(-0.7, 0.0, 0.8), cloak = -2.0)

    /** Struck from behind while still facing us: thrown forward, then turning round. */
    val STAGGER = Rig(yaw = 10.0, bodyY = 2.0, lean = 0.6, crouch = 2.0, stride = -3.0, rh = V(14.0, 64.0, 6.0), weapon = V(0.6, -0.3, 0.7), lh = V(-15.0, 66.0, 5.0), headDown = 4.0, cloak = 3.0)

    // a diagonal cut from high over the right shoulder down across, forward into the foe
    val SLASH_WIND = Rig(lean = -0.15, rh = V(15.0, 98.0, 2.0), weapon = V(0.25, 0.9, -0.3), lh = V(-6.0, 70.0, 14.0), cloak = -1.0)
    val SLASH_HIT = Rig(lean = 0.35, crouch = 1.5, stride = 7.0, rh = V(7.0, 68.0, 21.0), weapon = V(0.45, -0.35, 0.8), lh = V(-13.0, 68.0, 10.0), cloak = 2.0, trail = 1.0)

    // a lunge straight at the foe
    val THRUST_WIND = Rig(lean = -0.2, rh = V(17.0, 72.0, -2.0), weapon = V(0.18, 0.15, 1.0), lh = V(-11.0, 69.0, 13.0))
    val THRUST_HIT = Rig(lean = 0.45, crouch = 2.0, stride = 10.0, rh = V(5.0, 80.0, 27.0), weapon = V(-0.05, 0.12, 1.0), lh = V(-14.0, 68.0, 8.0), cloak = 2.5, trail = 0.6)

    // overhead and down onto the foe
    val SMASH_WIND = Rig(lean = -0.25, bodyY = -1.5, rh = V(5.0, 110.0, 0.0), weapon = V(0.0, 0.75, -0.65), lh = V(-9.0, 72.0, 12.0), cloak = -1.5)
    val SMASH_HIT = Rig(lean = 0.5, crouch = 4.0, stride = 8.0, rh = V(3.0, 70.0, 22.0), weapon = V(0.0, -0.55, 0.85), lh = V(-11.0, 68.0, 10.0), cloak = 2.5, trail = 1.0)

    // the bow held out at the foe, the string drawn to the cheek
    val BOW_AIM = Rig(rh = V(5.0, 92.0, 3.0), lh = V(-3.0, 90.0, 27.0), draw = 1.0, headTurn = 6.0)
    val BOW_RELEASE = Rig(rh = V(11.0, 93.0, -6.0), lh = V(-3.0, 90.0, 27.0), draw = 0.0, headTurn = 6.0, cloak = -0.5)

    val CAST_RAISE = Rig(lean = -0.15, rh = V(12.0, 104.0, 8.0), weapon = V(0.0, 1.0, 0.25), lh = V(-10.0, 86.0, 16.0), glow = 0.6)
    val CAST_RELEASE = Rig(lean = 0.4, stride = 6.0, rh = V(6.0, 88.0, 25.0), weapon = V(0.0, 0.3, 1.0), lh = V(-8.0, 86.0, 21.0), glow = 1.0, cloak = 1.5)

    // the shield goes up in front of the face
    // the chest turns so the shield shoulder leads into the blow; the weapon arm comes up in front, upper arm about level,
    // forearm upright with the hand beside the head, the wrist cocked so the blade lies back over the shoulder, ready to strike back
    val BLOCK = Rig(lean = -0.05, crouch = 2.5, stride = 3.0, rh = V(14.0, 101.0, 9.0), weapon = V(0.3, 0.25, -0.92), lh = V(1.0, 90.0, 25.0), shieldFace = V(0.0, 0.15, 1.0), headDown = 2.0,
        elbowUp = 1.0, elbowAt = V(15.0, 84.0, 10.0), twist = 30.0)
    val HURT = Rig(lean = -0.45, crouch = 2.0, stride = -2.0, rh = V(15.0, 66.0, 4.0), weapon = V(0.6, 0.5, 0.3), lh = V(-15.0, 68.0, 4.0), headDown = -3.0, cloak = -2.0)

    /** Earnest victory poses, facing us again. */
    val VICTORY_POSES = listOf(
        // the blade raised upright before the face: a salute to the fallen
        Rig(yaw = 14.0, stride = 1.0, spread = 7.0, rh = V(2.0, 90.0, 9.0), weapon = V(0.0, 1.0, 0.06), lh = V(-17.0, 64.0, 3.0), shieldFace = V(-1.0, 0.0, 0.35), headDown = 1.5),
        // resting on the weapon, point to the ground, both hands on the hilt
        Rig(yaw = 20.0, stride = 0.0, spread = 8.0, rh = V(0.5, 66.0, 10.0), weapon = V(0.0, -1.0, 0.05), lh = V(-1.5, 64.0, 10.0), shieldFace = V(-0.6, 0.0, 0.8), headDown = 3.0),
        // the weapon lowered at the side, looking back at the fallen foe
        Rig(yaw = 28.0, stride = 3.0, spread = 7.0, rh = V(14.0, 60.0, 5.0), weapon = V(0.3, -0.85, 0.35), lh = V(-17.0, 64.0, 4.0), shieldFace = V(-1.0, 0.0, 0.35), headTurn = 30.0, headDown = 1.0),
        // the weapon held high, calm and upright
        Rig(yaw = 12.0, stride = 1.0, spread = 8.0, rh = V(18.0, 104.0, 6.0), weapon = V(0.4, 1.0, 0.1), lh = V(-17.0, 64.0, 4.0), shieldFace = V(-1.0, 0.0, 0.35), headTurn = 6.0),
    )

    fun tween(vararg keys: Pair<Rig, Int>): List<Rig> {
        val out = mutableListOf<Rig>()
        for (i in 0 until keys.size - 1) {
            val (a, n) = keys[i]
            val b = keys[i + 1].first
            for (k in 0 until n) out += a.lerp(b, (1 - cos(k / n.toDouble() * PI)) / 2)
        }
        out += keys.last().first
        return out
    }

    const val IDLE_FRAMES = 16
    private fun breathe(a: Rig, b: Rig) = List(IDLE_FRAMES) { a.lerp(b, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) }
    private val IDLE = breathe(STAND, BREATHE)
    private val READY_IDLE = breathe(READY, READY_B)

    private val SEQ = mapOf(
        Strike.SLASH to tween(STAND to 3, SLASH_WIND to 6, SLASH_HIT to 3, SLASH_HIT.copy(trail = 0.0) to 5, STAND to 1),
        Strike.THRUST to tween(STAND to 3, THRUST_WIND to 5, THRUST_HIT to 3, THRUST_HIT.copy(trail = 0.0) to 5, STAND to 1),
        Strike.SMASH to tween(STAND to 3, SMASH_WIND to 7, SMASH_HIT to 3, SMASH_HIT.copy(trail = 0.0) to 5, STAND to 1),
        Strike.SHOOT to tween(STAND to 3, BOW_AIM to 7, BOW_RELEASE to 2, BOW_RELEASE to 5, STAND to 1),
        Strike.CAST to tween(STAND to 3, CAST_RAISE to 7, CAST_RELEASE to 3, CAST_RELEASE to 5, STAND to 1),
    )

    /** The frame of each strike at which the blow lands (or the arrow and spell fly). */
    fun strikeFrame(s: Strike): Int = when (s) {
        Strike.SLASH -> 9
        Strike.THRUST -> 8
        Strike.SMASH -> 10
        Strike.SHOOT -> 10
        Strike.CAST -> 10
    }

    private val BLOCK_SEQ = tween(STAND to 3, BLOCK to 4, BLOCK to 5, STAND to 1)
    private val HURT_SEQ = tween(STAND to 2, HURT to 4, STAND to 1)
    /** Facing us, then a smooth turn of the whole body to the foe, with a step. */
    private val TURN_SEQ = tween(READY to 2, TURNING to 7, STAND to 7)
    private val AMBUSH_SEQ = tween(READY to 1, STAGGER to 3, STAGGER.copy(bodyY = 1.0, lean = 0.3) to 4, TURNING to 6, STAND to 7)
    private fun victory(v: Int) = tween(STAND to 3, TURNING.copy(yaw = 70.0) to 7, VICTORY_POSES[v % VICTORY_POSES.size] to 10)

    /** How many victory poses there are to choose from. */
    val victoryVariants: Int get() = VICTORY_POSES.size

    /** The victory poses that suit what the hero holds: a two-handed weapon is not raised over the head. */
    fun victoryPoses(hero: Hero): List<Int> {
        val w = hero.item(GearSlot.MAIN_HAND)?.def
        val shield = hero.item(GearSlot.OFF_HAND)?.def?.kind == de.bornim.core.BaseKind.SHIELD
        return when {
            w != null && w.twoHanded && !w.ranged -> listOf(0, 1, 2)
            // both hands on the hilt does not go with a shield on the arm
            shield -> listOf(0, 2, 3)
            else -> VICTORY_POSES.indices.toList()
        }
    }

    /** The ways this hero can strike with what is in hand: two variants for melee weapons. */
    fun strikes(hero: Hero): List<Strike> {
        val w = hero.item(GearSlot.MAIN_HAND)?.def
        return when {
            w == null -> if (hero.cls == CharClass.WIZARD || hero.cls == CharClass.CLERIC) listOf(Strike.SMASH) else listOf(Strike.SMASH, Strike.THRUST)
            w.ranged -> listOf(Strike.SHOOT)
            w.icon == Icon.DAGGER || w.icon == Icon.SPEAR -> listOf(Strike.THRUST, Strike.SLASH)
            w.icon == Icon.MACE || w.icon == Icon.HAMMER || w.icon == Icon.STAFF -> listOf(Strike.SMASH, Strike.SLASH)
            w.twoHanded -> listOf(Strike.SMASH, Strike.SLASH)
            else -> listOf(Strike.SLASH, Strike.THRUST)
        }
    }

    fun sequence(act: Act, strike: Strike, variant: Int): List<Rig> = when (act) {
        Act.IDLE -> IDLE
        Act.ATTACK -> SEQ.getValue(strike)
        Act.CAST -> SEQ.getValue(Strike.CAST)
        Act.BLOCK -> BLOCK_SEQ
        Act.HURT -> HURT_SEQ
        Act.INTRO -> READY_IDLE
        Act.TURN -> TURN_SEQ
        Act.AMBUSHED -> AMBUSH_SEQ
        Act.VICTORY -> victory(variant)
    }

    fun frameCount(act: Act, strike: Strike = Strike.SLASH, variant: Int = 0): Int = sequence(act, strike, variant).size

    private val cache = object : LinkedHashMap<String, PixelImage>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 220
    }

    private data class Part(val icon: Icon, val rarity: Rarity, val weight: Weight, val kind: BaseKind, val twoHanded: Boolean, val ranged: Boolean, val base: String)

    private fun part(g: Gear?) = g?.def?.let { Part(it.icon, g.rarity, it.weight, it.kind, it.twoHanded, it.ranged, g.base) }

    /** Frame [index] of [act]; attacks use [strike], victories [variant]. Idle and intro loop. */
    fun frame(hero: Hero, act: Act, index: Int = 0, strike: Strike = strikes(hero).first(), variant: Int = 0): PixelImage {
        val seq = sequence(act, strike, variant)
        val i = if (act == Act.IDLE || act == Act.INTRO) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        var rig = seq[i]
        // two-handed weapons: both hands on the haft
        val w = hero.item(GearSlot.MAIN_HAND)?.def
        if (w != null && w.twoHanded && !w.ranged) rig = rig.copy(lh = rig.rh + rig.weapon * (-5.0) + V(-1.5, 0.0, 0.0))
        return draw(hero, rig, "$act/$strike/$variant/$i")
    }

    fun draw(hero: Hero, rig: Rig, tag: String = rig.toString()): PixelImage {
        val parts = GearSlot.entries.associateWith { part(hero.item(it)) }
        val key = "${hero.race}/${hero.cls}/$tag/" + parts.values.joinToString(",")
        synchronized(cache) { cache[key]?.let { return it } }
        val s = Sculpt(W, H, 17)
        Painter(s, hero.race, hero.cls, parts, rig).draw()
        s.transform()
        s.rim(argb(0xF4D8B0), 0.28)
        s.outline(argb(0x14100E))
        synchronized(cache) { cache[key] = s.img }
        return s.img
    }

    /** Draws every frame ahead, e.g. in the background before a fight. */
    fun prepare(hero: Hero) {
        for (i in 0 until IDLE_FRAMES) { frame(hero, Act.IDLE, i); frame(hero, Act.INTRO, i) }
        for (st in strikes(hero)) for (i in 0 until frameCount(Act.ATTACK, st)) frame(hero, Act.ATTACK, i, st)
        for (a in listOf(Act.CAST, Act.BLOCK, Act.HURT, Act.TURN, Act.AMBUSHED)) for (i in 0 until frameCount(a)) frame(hero, a, i)
    }

    // ---------------------------------------------------------------- the painter

    private class Painter(val s: Sculpt, val race: Race, val cls: CharClass, val parts: Map<GearSlot, Part?>, val r: Rig) {
        val look = CharacterArt.heroLook(race, cls)

        fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(rgb), shine, grain)
        fun worn(rgb: Int, k: Double = 0.38) = mix(rgb, argb(0x3A3632), k)

        val skin = m(look.skin)
        val hair = m(worn(look.hair, 0.15), grain = 0.15)
        val leather = m(argb(0x6A4A32), grain = 0.07)
        val darkLeather = m(argb(0x3E2C22), grain = 0.05)
        val darkSteel = m(argb(0x6E7680), shine = 0.6)
        val gold = m(argb(0xB8904A), shine = 0.7)
        val wood = m(argb(0x6E4A2C), grain = 0.12)
        val cloth = m(worn(look.cloth), grain = 0.05)
        val clothDark = m(worn(look.clothDark, 0.45), grain = 0.05)
        val pantsMat = m(worn(look.pants, 0.3), grain = 0.05)

        fun metal(rar: Rarity) = m(mix(argb(0x9AA2AC), rar.color.toInt(), if (rar >= Rarity.RARE) 0.14 else 0.0), shine = 0.85)
        fun cloakColor(rar: Rarity) = worn(argb(
            when (rar) {
                Rarity.COMMON -> 0x5A4636; Rarity.UNCOMMON -> 0x34603A; Rarity.RARE -> 0x34508A
                Rarity.VERY_RARE -> 0x56347E; Rarity.EPIC -> 0x8A3E22; Rarity.DIVINE -> 0xC8B888
            },
        ), 0.2)

        val scale = when (race) { Race.HALFLING -> 0.72; Race.DWARF -> 0.8; Race.ELF -> 1.03; else -> 1.0 }
        val wide = when (race) { Race.DWARF -> 1.25; Race.HALF_ORC -> 1.14; Race.ELF -> 0.97; Race.HALFLING -> 1.08; else -> 1.04 }
        val headK = when (race) { Race.HALFLING -> 1.2; Race.DWARF -> 1.12; else -> 0.96 }

        val chest = parts[GearSlot.CHEST]
        val weight = chest?.weight
        val robe = (chest == null && look.robe) || weight == Weight.CLOTH
        val heavy = weight == Weight.HEAVY
        val medium = weight == Weight.MEDIUM
        val main = parts[GearSlot.MAIN_HAND]
        val off = parts[GearSlot.OFF_HAND]
        val twoHands = main?.twoHanded == true && !main.ranged
        val gloves = parts[GearSlot.ARMS]
        val torsoMat = when { heavy -> metal(chest!!.rarity); medium -> m(argb(0x8A9098), shine = 0.45, grain = 0.45); weight == Weight.LIGHT -> leather; else -> cloth }
        val sleeve = if (robe) clothDark else torsoMat
        val hand = when { gloves == null -> skin; gloves.weight == Weight.HEAVY || gloves.weight == Weight.MEDIUM -> darkSteel; else -> leather }
        val arms = WeaponArt(s)

        // ---- the view: the hero's own axes in the picture
        val yaw = Math.toRadians(r.yaw)
        /** Forward and right in the picture plane (x right, z towards us). */
        val fX = sin(yaw); val fZ = cos(yaw)
        val rX = -cos(yaw); val rZ = sin(yaw)
        /** Seen from the front (1), the side (0) or behind (-1). */
        val facing = fZ

        /** Where a point of the hero's space lands: layout x, layout y and depth (bigger is nearer). */
        fun p(v: V): Triple<Double, Double, Double> {
            val x = v.r * rX + v.f * fX
            val z = v.r * rZ + v.f * fZ
            return Triple(48.0 + r.bodyX + x, 124.0 + r.bodyY - v.u + z * 0.3, z)
        }

        /** The upper body bends forward at the hips. */
        fun upper(v: V): V = if (v.u <= 52) v else V(v.r, v.u - abs(r.lean) * (v.u - 52) * 0.12, v.f + r.lean * (v.u - 52) * 0.35)

        val hip = 52.0 - r.crouch
        val shL = upper(V(-15.5, 84.0 - r.crouch, 0.0))
        val shR = upper(V(15.5, 84.0 - r.crouch, 0.0))
        val neck = upper(V(0.0, 90.0 - r.crouch, 0.0))
        val headC = upper(V(0.0, 98.5 - r.crouch - r.headDown * 0.3, r.headDown * 0.4))

        /** Two-bone reach in space: the elbow bends out, down and back. */
        fun elbow(a: V, t: V, out: Double, l1: Double = 16.0, l2: Double = 15.0, pole: V = V(out * 0.6, -1.0, -0.5)): Pair<V, V> {
            var d = t - a
            var dist = d.len()
            if (dist > l1 + l2 - 0.5) { d = d * ((l1 + l2 - 0.5) / dist); dist = l1 + l2 - 0.5 }
            val h = a + d
            val dn = d.norm()
            val aa = (l1 * l1 - l2 * l2 + dist * dist) / (2 * dist.coerceAtLeast(0.01))
            val hh = sqrt((l1 * l1 - aa * aa).coerceAtLeast(0.0))
            val perp = (pole - dn * (pole.r * dn.r + pole.u * dn.u + pole.f * dn.f)).norm()
            return Pair(a + dn * aa + perp * hh, h)
        }

        // a shield arm bends its elbow out to the side, so the forearm lies across the body behind the shield
        val lArm = if (off?.kind == BaseKind.SHIELD && !twoHands) elbow(shL, r.lh, -1.0, pole = V(-1.0, -0.5, 0.35)) else elbow(shL, r.lh, -1.0)
        val rArm = elbow(shR, r.rh, 1.0)

        // ---- drawing, sorted from far to near
        val jobs = mutableListOf<Pair<Double, () -> Unit>>()
        fun at(depth: Double, f: () -> Unit) { jobs += depth to f }

        fun limb(a: V, b: V, ra: Double, rb: Double, mat: Mat) {
            val pa = p(a); val pb = p(b)
            s.limb(pa.first, pa.second, pb.first, pb.second, ra, rb, mat)
        }

        fun blob(c: V, rx: Double, ry: Double, mat: Mat) { val pc = p(c); s.blob(pc.first, pc.second, rx, ry, mat) }

        fun draw() {
            s.transform(ANCHOR_X - 48.0, GROUND - 124.0, SIZE * scale * wide, SIZE * scale, ANCHOR_X.toDouble(), GROUND.toDouble())
            legs()
            at(p(V(0.0, 70.0, 0.0)).third) { torso() }
            // the skirt wraps the hips: over both thighs whatever the facing
            at(maxOf(p(knee(-1.0)).third, p(knee(1.0)).third, p(V(0.0, 70.0, 0.0)).third) + 0.05) { skirt() }
            cloak()
            at(p(headC).third + 0.5) { head() }
            arm(shL, lArm, 0.0)
            arm(shR, rArm, -0.04)
            heldLeft()
            heldRight()
            jobs.sortBy { it.first }
            jobs.forEach { it.second() }
            if (r.trail > 0.05 && main != null && !main.ranged) trail()
        }

        fun hipJoint(side: Double) = V(side * 5.8, hip, 0.0)
        fun footAt(side: Double) = V(side * r.spread, 0.0, if (side > 0) r.stride else -r.stride * 0.3)
        fun knee(side: Double): V {
            val h = hipJoint(side); val ft = footAt(side)
            return V((h.r + ft.r) / 2 + side * 0.5, hip / 2 + 1.0, (h.f + ft.f) / 2 + 3.0 + r.crouch * 0.8)
        }

        /** Points on the body's surface, drawn as a flat patch: foreshortens and slides round as the body turns. */
        fun patch(mat: Mat, vararg pts: V, bevel: Double = 1.0) {
            s.poly(mat, *pts.flatMap { val q = p(it); listOf(q.first, q.second) }.toDoubleArray(), bevel = bevel)
        }

        fun legs() {
            val legsPart = parts[GearSlot.LEGS]
            val shin = if (legsPart?.icon == Icon.LEGS && legsPart.weight == Weight.HEAVY) metal(legsPart.rarity) else pantsMat
            val boot = if (legsPart?.icon == Icon.BOOTS && legsPart.weight == Weight.HEAVY) darkSteel else darkLeather
            for (side in listOf(-1.0, 1.0)) {
                val hipJ = hipJoint(side)
                val foot = footAt(side)
                val knee = knee(side)
                at(p(knee).third) {
                    limb(hipJ, knee, 7.0, 5.6, pantsMat)
                    limb(knee, foot + V(0.0, 4.0, 0.0), 5.6, 4.2, shin)
                    if (shin != pantsMat) blob(knee, 3.8, 3.4, shin)
                    limb(foot + V(0.0, 12.0, 0.0), foot + V(0.0, 1.0, 0.0), 4.2, 4.0, boot)
                    // the foot points forward
                    limb(foot + V(0.0, 1.5, -1.0), foot + V(0.0, 1.0, 4.5), 3.6, 2.6, boot)
                    limb(foot + V(-3.9, 12.0, 0.0), foot + V(3.9, 12.0, 0.0), 1.0, 1.0, leather)
                }
            }
        }

        fun torso() {
            val pl = p(shL); val pr = p(shR)
            val lx = pl.first; val ly = pl.second; val rx = pr.first; val ry = pr.second
            val hl = p(upper(V(-11.5, hip + 12, 0.0))); val hr = p(upper(V(11.5, hip + 12, 0.0)))
            val c = p(upper(V(0.0, 72.0 - r.crouch, 0.0)))
            val span = abs(rx - lx) / 2
            // the body has depth: seen from the side it is still about as wide as a chest is deep
            val half = maxOf(span, 9.0)
            s.poly(torsoMat, lx, ly - 2, rx, ry - 2, hr.first, hr.second, hl.first, hl.second, tiltY = -0.1, bevel = 3.0)
            s.blob(c.first, c.second, half * 0.95, 13.0, torsoMat)
            val b0 = p(V(0.0, hip + 10, 0.0))
            val cu = 72.0 - r.crouch
            if (facing > 0.08) {
                // the front: a tabard with the house colour for the armoured, laces on leather; all on the chest's surface
                if (heavy || medium) {
                    patch(m(worn(look.cloth)), upper(V(-4.5, cu + 8, 7.5)), upper(V(4.5, cu + 8, 7.5)), upper(V(4.0, hip + 10, 6.8)), upper(V(-4.0, hip + 10, 6.8)))
                    if (facing > 0.3) { val g = p(upper(V(0.0, cu + 1, 8.2))); s.blob(g.first, g.second, 2.4 * facing.coerceAtLeast(0.5), 2.4, gold) }
                }
                if (weight == Weight.LIGHT) for (k in 0..3) {
                    val a = p(upper(V(-2.0, cu + 6 - k * 3.5, 7.8))); val b = p(upper(V(2.0, cu + 4 - k * 3.5, 7.8)))
                    s.line(a.first, a.second, b.first, b.second, argb(0x2A1C14))
                }
            } else if (facing < -0.08) {
                val a = p(upper(V(0.0, cu + 10, -7.5))); val b = p(upper(V(0.0, cu - 10, -7.0)))
                s.line(a.first, a.second, b.first, b.second, torsoMat.ramp[1])
                if (heavy) for (du in listOf(6.0, -2.0)) for (sd in listOf(-7.0, 7.0)) { val q = p(upper(V(sd, cu + du, -6.0))); s.dot(q.first, q.second, argb(0xD0D4D8)) }
            }
            // pouch on the right hip
            val pouch = p(V(10.5, hip + 7, -1.0))
            s.blob(pouch.first, pouch.second, 3.4, 4.0, leather)
            // shoulders: pauldrons for the armoured
            val pm = if (heavy) metal(chest!!.rarity) else if (medium) leather else torsoMat
            val big = if (heavy) 1.2 else 0.0
            s.blob(lx, ly, 5.6 + big, 4.6 + big, pm)
            s.blob(rx, ry, 5.6 + big, 4.6 + big, pm)
            // a collar closes the neck
            val n = p(neck)
            s.blob(n.first, n.second + 2, 7.5, 3.6, if (heavy || medium) m(argb(0x8A9098), shine = 0.4, grain = 0.45) else torsoMat)
        }

        /** Tunic, mail skirt or robe hanging from the belt over the thighs: always over the legs. */
        fun skirt() {
            val c = p(upper(V(0.0, 72.0 - r.crouch, 0.0)))
            val pl = p(shL); val pr = p(shR)
            val half = maxOf(abs(pr.first - pl.first) / 2, 9.0)
            val b0 = p(V(0.0, hip + 10, 0.0))
            val hem = p(V(0.0, 34.0, 0.0)).second
            when {
                robe -> s.poly(cloth, b0.first - half * 0.9, b0.second - 2, b0.first + half * 0.9, b0.second - 2, b0.first + half * 1.3 + r.cloak, b0.second + 52, b0.first - half * 1.3 + r.cloak, b0.second + 52, tiltY = -0.12)
                heavy || medium -> {
                    val mail = if (heavy) metal(chest!!.rarity) else m(argb(0x8A9098), shine = 0.4, grain = 0.4)
                    s.poly(mail, b0.first - half * 0.85, b0.second - 3, b0.first + half * 0.85, b0.second - 3, b0.first + half * 1.0, hem, b0.first - half * 1.0, hem, tiltY = -0.2)
                    if (heavy) for (k in 0..2) { val y = b0.second + 2 + k * 5; s.limb(b0.first - half * 0.86, y, b0.first + half * 0.86, y, 1.3, 1.3, mail) }
                }
                else -> s.poly(clothDark, b0.first - half * 0.85, b0.second - 3, b0.first + half * 0.85, b0.second - 3, b0.first + half * 0.98, hem - 2, b0.first - half * 0.98, hem - 2, tiltY = -0.2)
            }
            // the tabard falls over it at the front
            if (facing > 0.08 && (heavy || medium)) {
                val cu = 72.0 - r.crouch
                patch(m(worn(look.cloth)), upper(V(-4.5, cu + 8, 7.5)), upper(V(4.5, cu + 8, 7.5)), V(3.8, 31.0, 8.0 + r.stride * 0.3), V(-3.8, 31.0, 8.0 + r.stride * 0.3))
            }
            s.limb(b0.first - half * 0.85, b0.second - 4, b0.first + half * 0.85, b0.second - 4, 2.2, 2.2, darkLeather)
            if (facing > 0.2) { val bk = p(V(0.0, hip + 14, 7.5)); s.blob(bk.first, bk.second, 2.0 * facing.coerceAtLeast(0.6), 2.0, gold) }
        }

        fun cloak() {
            val cl = parts[GearSlot.CLOAK] ?: return
            val col = cloakColor(cl.rarity)
            // hangs from the shoulders down the back
            val back = -4.5
            val tl = upper(V(-12.0, 85.0 - r.crouch, back)); val tr = upper(V(12.0, 85.0 - r.crouch, back))
            val bl = V(-14.0, 30.0, back - 4 - r.cloak); val br = V(14.0, 30.0, back - 4 - r.cloak)
            at(p(V(0.0, 60.0, back - 3)).third) {
                val a = p(tl); val b = p(tr); val c = p(br); val d = p(bl)
                val folds = 6
                for (k in 0 until folds) {
                    val t = k / (folds - 1.0)
                    val x0 = a.first + (b.first - a.first) * t; val y0 = a.second + (b.second - a.second) * t
                    val x1 = d.first + (c.first - d.first) * t; val y1 = d.second + (c.second - d.second) * t + (if (k % 2 == 0) 2.0 else 0.0)
                    s.limb(x0, y0, x1, y1, 3.6, 4.4, m(col, grain = 0.03).copy(bias = if (k % 2 == 0) 0.03 else -0.06, inline = k == 0))
                }
                if (cl.rarity >= Rarity.EPIC) s.limb(a.first, a.second, b.first, b.second, 0.9, 0.9, gold)
            }
        }

        fun head() {
            val hc = p(headC)
            val hx = hc.first; val hy = hc.second
            val k = headK
            // the face looks where the body faces, turned a little more by headTurn
            val fy = Math.toRadians(r.yaw + r.headTurn)
            val ffx = sin(fy); val ffz = cos(fy)
            val pn = p(neck)
            s.limb(pn.first, pn.second, hx, hy + 5, 3.4 * k, 3.4 * k, skin.copy(bias = -0.15))
            s.blob(hx, hy, 7.0 * k, 7.8 * k, if (ffz > -0.2) skin else hair)
            if (ffz > -0.2) {
                // the face, as much of it as turns towards us
                val ox = ffx * 3.0
                s.blob(hx - ffx * 2.5, hy - 3.5, 7.0 * k, 4.8 * k, hair)
                val eye = argb(0x22180F)
                for (side in listOf(-1.0, 1.0)) {
                    if (side * ffx > 0.6) continue
                    val ex = hx + ox * 0.6 + side * 2.6 * k * maxOf(0.25, ffz)
                    s.dot(ex, hy - 0.5, eye)
                    s.line(ex - 1.0, hy - 2.0, ex + 1.0, hy - 2.2, worn(look.hair, 0.2))
                }
                s.line(hx + ox * 0.9, hy + 0.5, hx + ox * 1.05, hy + 2.5, skin.ramp[1])
                s.line(hx + ox * 0.7 - 1.2, hy + 4.2, hx + ox * 0.7 + 1.2, hy + 4.2, skin.ramp[0])
                if (look.beard) s.poly(hair, hx + ox - 5.5, hy + 2, hx + ox + 5.5, hy + 2, hx + ox + 3.5, hy + 10, hx + ox, hy + 13, hx + ox - 3.5, hy + 10)
                if (race == Race.HALF_ORC) { s.dot(hx + ox - 2, hy + 4.5, argb(0xF0ECDC)); s.dot(hx + ox + 2, hy + 4.5, argb(0xF0ECDC)) }
            } else {
                // from behind: hair over the head, an ear peeking out where the face turns
                s.blob(hx + ffx * 6.0, hy + 1.5, 1.6, 2.4, skin)
            }
            if (race == Race.ELF) for (side in listOf(-1.0, 1.0)) { val ex = hx + side * 6.5 * k; s.poly(skin, ex, hy, ex + side * 6, hy - 6, ex + side * 0.5, hy + 3) }
            when (race) {
                Race.ELF -> if (ffz < 0.5) s.chain(hair, hx - ffx * 2, hy + 2, 6.0, hx - ffx * 3, hy + 10, 4.6, hx - ffx * 3.5, hy + 18, 2.6)
                Race.HALF_ORC -> s.limb(hx, hy - 7, hx - ffx, hy - 12, 2.4, 1.6, hair)
                else -> {}
            }
            headgear(hx, hy, ffx, ffz)
        }

        fun headgear(hx: Double, hy: Double, ffx: Double, ffz: Double) {
            val head = parts[GearSlot.HEAD]
            val gear = when (head?.icon) { Icon.HELMET -> Headgear.HELMET; Icon.HOOD -> Headgear.HOOD; Icon.CIRCLET -> Headgear.CIRCLET; else -> look.headgear }
            val rar = head?.rarity ?: Rarity.COMMON
            val k = headK
            when (gear) {
                Headgear.HELMET -> {
                    val hm = if (head?.weight == Weight.LIGHT) leather else metal(rar)
                    if (head?.base == "great_helm") {
                        s.blob(hx, hy, 8.2 * k, 9.2 * k, hm)
                        if (ffz > -0.2) {
                            // the eye slit and breathing holes of a great helm
                            s.line(hx + ffx * 3 - 4.5, hy - 1, hx + ffx * 3 + 4.5, hy - 1, argb(0x14100E))
                            for (j in 0..2) s.dot(hx + ffx * 3 + 2 - j * 1.5, hy + 4, argb(0x14100E))
                        }
                    } else {
                        s.blob(hx, hy - 4.0, 7.8 * k, 5.6 * k, hm)
                        s.limb(hx - 7.6 * k, hy - 1.2, hx + 7.6 * k, hy - 1.2, 1.2, 1.2, hm)
                        // the nasal guard over the nose
                        if (ffz > 0.0) s.limb(hx + ffx * 3, hy - 2, hx + ffx * 3.2, hy + 2.5, 0.8, 0.6, hm)
                        else s.line(hx, hy - 9, hx, hy + 1, hm.ramp[1])
                    }
                }
                Headgear.HOOD -> {
                    val hm = m(if (head == null) worn(look.cloth) else cloakColor(rar), grain = 0.04)
                    if (ffz > -0.2) {
                        s.poly(hm, hx - 8.5, hy - 7, hx + 8.5, hy - 7, hx + 9.5, hy + 10, hx + 6 + ffx * 3, hy + 9, hx + 6 + ffx * 3, hy - 3, hx - 6 + ffx * 3, hy - 3, hx - 6 + ffx * 3, hy + 9, hx - 9.5, hy + 10)
                    } else {
                        s.blob(hx, hy, 8.6 * k, 9.2 * k, hm)
                        s.poly(hm, hx - 8.5, hy + 3, hx + 8.5, hy + 3, hx + 9.5, hy + 14, hx - 9.5, hy + 14)
                    }
                }
                Headgear.CIRCLET -> s.limb(hx - 7.4, hy - 2.5, hx + 7.4, hy - 2.5, 0.9, 0.9, if (rar >= Rarity.RARE) metal(rar) else gold)
                Headgear.HAT -> {
                    val hm = m(worn(look.cloth), grain = 0.03)
                    s.blob(hx, hy - 4, 14.0, 4.0, hm)
                    s.poly(hm, hx - 7.5, hy - 5, hx + 7.5, hy - 5, hx + 5.5 + r.cloak * 0.5, hy - 19, hx + 1.5 + r.cloak, hy - 26, hx - 2.5 + r.cloak * 0.5, hy - 21)
                    s.limb(hx - 7, hy - 5.5, hx + 7, hy - 5.5, 1.0, 1.0, gold)
                }
                else -> {}
            }
        }

        fun arm(sh: V, j: Pair<V, V>, bias: Double) {
            val el = j.first; val h = j.second
            at((p(sh).third + p(el).third) / 2) { limb(sh, el, 5.0, 4.3, sleeve.copy(bias = bias)) }
            at((p(el).third + p(h).third) / 2 + 0.01) {
                limb(el, h, 4.3, 3.4, (if (gloves != null) hand else sleeve).copy(bias = bias))
                if (gloves != null) limb(el.lerp(h, 0.5), h, 4.3, 3.8, hand)
            }
            at(p(h).third + 0.02) { blob(h, 3.2, 3.2, hand) }
        }

        /** Draws a weapon from hand [h] pointing along [dir] in space, shortened as it points towards or away from us. */
        fun weaponAt(base: String, rar: Rarity, h: V, dir: V) {
            val a = p(h); val b = p(h + dir * 20.0)
            val dx = b.first - a.first; val dy = b.second - a.second
            val len = sqrt(dx * dx + dy * dy)
            arms.draw(base, rar, a.first, a.second, Math.toDegrees(atan2(dy, dx)), r.glow, (len / 20.0).coerceIn(0.2, 1.15))
        }

        fun heldRight() {
            val h = rArm.second
            if (main != null && !main.ranged) {
                val tipDepth = p(h + r.weapon * 15.0).third
                // a blade pointing away is behind the hand, one pointing at us in front of it
                at(if (tipDepth < p(h).third) p(h).third - 0.5 else p(h).third + 0.5) { weaponAt(main.base, main.rarity, h, r.weapon) }
            }
            if (main?.ranged == true && r.draw > 0.05) at(p(h).third + 0.6) { bowString() }
        }

        fun heldLeft() {
            val h = lArm.second
            when {
                main?.ranged == true -> at(p(h).third - 0.3) { bow(h) }
                off == null || twoHands -> {}
                // strapped to the forearm: in front of the arm when its face looks at us, behind it otherwise
                off.kind == BaseKind.SHIELD -> {
                    val near = maxOf(p(h).third, p(lArm.first).third); val far = minOf(p(h).third, p(lArm.first).third)
                    at(if (shieldFront()) near + 0.6 else far - 0.6) { shield(off, lArm.first, h) }
                }
                off.icon == Icon.ORB -> at(p(h).third + 0.3) {
                    val g = mix(argb(0x80C8FF), off.rarity.color.toInt(), 0.4)
                    val c = p(h + V(0.0, 6.0, 1.0)); val rr = 4.0 + r.glow * 1.5
                    s.flat(c.first, c.second, rr + 3, rr + 3, alpha(g, (70 + r.glow * 90).toInt()))
                    s.blob(c.first, c.second, rr, rr, m(g, shine = 1.0).copy(inline = false))
                }
                off.icon == Icon.TOME -> at(p(h).third + 0.3) {
                    val c = p(h)
                    s.poly(m(worn(mix(argb(0x6A2A22), off.rarity.color.toInt(), 0.3), 0.2)), c.first - 7, c.second - 8, c.first + 4, c.second - 8, c.first + 4, c.second + 4, c.first - 7, c.second + 4)
                    s.line(c.first - 1.5, c.second - 8, c.first - 1.5, c.second + 4, argb(0xB8904A))
                }
                off.icon == Icon.SYMBOL -> at(p(h).third + 0.3) {
                    val c = p(h + V(0.0, 6.0, 1.0))
                    s.blob(c.first, c.second, 2.8, 2.8, gold)
                    s.flat(c.first, c.second, 1.0 + r.glow, 1.0 + r.glow, argb(0xF8F0D8))
                }
                off.kind == BaseKind.WEAPON -> at(p(h).third + 0.2) { weaponAt(off.base, off.rarity, h, V(r.weapon.r * -0.5, r.weapon.u, r.weapon.f)) }
                else -> {}
            }
        }

        /**
         * The shield is strapped to the left forearm: its face looks along [Rig.shieldFace] but stays
         * square to the forearm, which runs across the back of the shield through its middle.
         */
        fun shieldNormal(): V {
            val a = (lArm.second - lArm.first).norm()
            val f = r.shieldFace
            val d = f.r * a.r + f.u * a.u + f.f * a.f
            return (f - a * d).norm()
        }

        /** The shield's face looks towards us. */
        fun shieldFront(): Boolean {
            val n = shieldNormal()
            return n.r * rZ + n.f * fZ > 0
        }

        /** A shield on the left forearm: the painted face with boss when it looks at us (hiding the arm), else the inside with the arm in its straps. */
        fun shield(p0: Part, el: V, h: V) {
            val tower = p0.base == "tower_shield"
            val n = shieldNormal()
            // axes in the shield's plane: across runs along the forearm, up is square to it and the face
            val fore = (h - el).norm()
            var up = V(n.u * fore.f - n.f * fore.u, n.f * fore.r - n.r * fore.f, n.r * fore.u - n.u * fore.r).norm()
            if (up.u < 0) up = up * -1.0
            // keep the shield upright: lean "up" towards the sky, "across" follows
            up = (up + V(0.0, 1.2, 0.0) - n * (n.u * 1.2)).norm()
            val ax = V(up.u * n.f - up.f * n.u, up.f * n.r - up.r * n.f, up.r * n.u - up.u * n.r).norm()
            // centred on the forearm, standing off it by the thickness of the straps
            val c = el.lerp(h, 0.55) + n * 2.0
            val hw = if (tower) 13.0 else 11.0; val hh = if (tower) 21.0 else 15.0
            fun q(a: Double, b: Double) = p(c + ax * a + up * b)
            fun pts(list: List<Triple<Double, Double, Double>>) = list.flatMap { listOf(it.first, it.second) }.toDoubleArray()
            val outline = listOf(q(-hw, hh), q(hw, hh), q(hw, -hh * 0.35), q(0.0, -hh - 2), q(-hw, -hh * 0.35))
            val rim = metal(p0.rarity)
            // the board has thickness: its back edge shows as a slab when seen side on
            val back = listOf(-hw to hh, hw to hh, hw to -hh * 0.35, 0.0 to -hh - 2, -hw to -hh * 0.35).map { (a, b) -> p(c + ax * a + up * b - n * 2.2) }
            s.poly(wood.copy(bias = -0.2), *pts(back), tiltX = -0.2, bevel = 0.6)
            s.poly(rim, *pts(outline), tiltX = -0.2, bevel = 1.8)
            // how squarely the face looks at us; nearly side on there is no room for paint and boss
            val square = abs(n.r * rZ + n.f * fZ)
            val inner = listOf(q(-hw + 1.6, hh - 1.6), q(hw - 1.6, hh - 1.6), q(hw - 1.6, -hh * 0.35 + 0.5), q(0.0, -hh + 0.5), q(-hw + 1.6, -hh * 0.35 + 0.5))
            if (square < 0.22) return
            if (shieldFront()) {
                // the face: paint, a pale stripe, the iron boss
                val paint = m(worn(if (p0.rarity >= Rarity.RARE) mix(argb(0x7A2A22), p0.rarity.color.toInt(), 0.45) else argb(0x6E2E24), 0.15))
                s.poly(paint, *pts(inner), tiltX = -0.2, bevel = 1.0)
                val s1 = q(-hw + 2, hh * 0.25); val s2 = q(hw - 2, hh * 0.25)
                s.limb(s1.first, s1.second, s2.first, s2.second, 1.3, 1.3, m(argb(0xC8BCA0)))
                val b = q(0.0, hh * 0.05)
                s.blob(b.first, b.second, 2.8, 2.8, rim)
                if (p0.rarity >= Rarity.EPIC) { val g = q(0.0, hh * 0.6); s.blob(g.first, g.second, 1.6, 1.6, gold) }
            } else {
                s.poly(wood.copy(bias = -0.08), *pts(inner), tiltX = -0.2, bevel = 0.8)
                for (a in listOf(-hw * 0.5, 0.0, hw * 0.5)) { val t = q(a, hh - 2); val bt = q(a, -hh * 0.6); s.line(t.first, t.second, bt.first, bt.second, wood.ramp[0]) }
                for (b in listOf(4.0, -3.0)) { val l = q(-hw + 3, b); val rr = q(hw - 3, b); s.limb(l.first, l.second, rr.first, rr.second, 1.3, 1.3, darkLeather) }
            }
        }

        val bowLen = if (main?.base == "longbow") 30.0 else 23.0

        /** The bow upright in the left hand, its belly bent towards the foe. */
        fun bowPoints(h: V) = listOf(-1.0, -0.75, -0.4, 0.0, 0.4, 0.75, 1.0).map { t -> p(h + V(0.0, t * bowLen, 2.5 - (1 - t * t) * 3.5 + (if (abs(t) > 0.9) 1.5 else 0.0))) }

        fun bow(h: V) {
            if (main?.base == "light_crossbow") { weaponAt("light_crossbow", main.rarity, h, V(0.0, 0.1, 1.0)); return }
            val bw = m(mix(argb(0x5E3E24), main!!.rarity.color.toInt(), if (main.rarity >= Rarity.RARE) 0.3 else 0.0), grain = 0.05)
            val pts = bowPoints(h)
            val radii = listOf(1.1, 1.7, 2.2, 2.5, 2.2, 1.7, 1.1)
            s.chain(bw, *pts.flatMapIndexed { i, q -> listOf(q.first, q.second, radii[i]) }.toDoubleArray())
            val g = p(h)
            s.limb(g.first, g.second - 3, g.first, g.second + 3, 2.6, 2.6, darkLeather)
            if (r.draw <= 0.05) s.line(pts[0].first, pts[0].second, pts[6].first, pts[6].second, argb(0xD8D0C0))
        }

        fun bowString() {
            if (main?.base == "light_crossbow") return
            val pts = bowPoints(lArm.second)
            val hnd = p(rArm.second)
            val mid = p(lArm.second)
            val px = mid.first + (hnd.first - mid.first) * r.draw; val py = mid.second + (hnd.second - mid.second) * r.draw
            s.line(pts[0].first, pts[0].second, px, py, argb(0xD8D0C0)); s.line(px, py, pts[6].first, pts[6].second, argb(0xD8D0C0))
            if (r.draw > 0.3) {
                val tip = p(lArm.second + V(0.0, 0.0, 6.0))
                s.limb(px, py, tip.first, tip.second, 0.7, 0.7, wood)
                s.limb(tip.first, tip.second, tip.first + (tip.first - px) * 0.12, tip.second + (tip.second - py) * 0.12, 1.1, 0.3, darkSteel)
            }
        }

        /** A pale arc behind the blade on the fastest frames of a blow, so its direction reads at a glance. */
        fun trail() {
            val h = rArm.second
            val tip = p(h + r.weapon * 26.0)
            val wind = if (r.rh.u > 90 || r.weapon.u < 0) V(15.0, 98.0, 2.0) + V(0.25, 0.9, -0.3) * 26.0 else V(13.0, 72.0, -3.0) + V(0.05, 0.15, 1.0) * 26.0
            val w0 = p(wind)
            for (k in 0..6) {
                val t = k / 6.0
                val x = w0.first + (tip.first - w0.first) * t + sin(t * PI) * 6
                val y = w0.second + (tip.second - w0.second) * t - sin(t * PI) * 4
                s.flat(x, y, 1.6 + t * 1.6, 1.6 + t * 1.6, alpha(argb(0xF4F0E8), (r.trail * (40 + t * 90)).toInt()))
            }
        }
    }
}
