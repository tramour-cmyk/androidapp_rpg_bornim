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
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * The hero in the new battle style: a strong, heroic figure at the pixel size of the battle
 * scenes, seen from behind and a little from the side, facing the foe at the upper right. Like the
 * wolf it is a jointed rig: hands, weapon, shield, lean and stance are continuous values, so every
 * attack can be drawn with as many in-between frames as needed. Weapons point at the foe; a shield
 * hangs on the left arm with its painted face turned outwards and is raised against the foe to block.
 * Everything equipped shows, in muted colours; rarer pieces carry the tint of their rarity.
 */
object HeroFigure {
    const val W = 168
    const val H = 180

    /** Where the feet stand, from the top. */
    const val GROUND = 174

    /** Where the feet stand, from the left (the canvas has room on the right for long weapons). */
    const val ANCHOR_X = 66

    /** How much larger than its 96 × 128 layout the figure is drawn. */
    private const val SIZE = 1.28

    /** What the hero does. */
    enum class Act { IDLE, ATTACK, CAST, BLOCK, HURT }

    /** How a weapon strikes. */
    enum class Strike { SLASH, THRUST, SMASH, SHOOT, CAST }

    /**
     * Everything that moves, in layout coordinates (96 × 128, feet at y 124). Hands are targets the
     * arms reach for; [weapon] is the weapon's angle in degrees (0 right, 90 down, -90 up).
     * [shield] 0 hangs at the side, 1 is raised against the foe. [glow] lights up a focus or staff.
     */
    data class Rig(
        val bodyX: Double = 0.0, val bodyY: Double = 0.0, val lean: Double = 0.0, val twist: Double = 0.0,
        val rx: Double = 72.0, val ry: Double = 64.0, val weapon: Double = -42.0,
        val lx: Double = 31.0, val ly: Double = 69.0,
        val shield: Double = 0.0, val stride: Double = 0.0, val head: Double = 0.0, val cloak: Double = 0.0, val glow: Double = 0.0,
        /** The bowstring pulled back (0 slack, 1 fully drawn). */
        val draw: Double = 0.0,
    ) {
        fun lerp(o: Rig, t: Double): Rig {
            fun l(a: Double, b: Double) = a + (b - a) * t
            // the weapon turns the short way round
            var dw = o.weapon - weapon
            while (dw > 180) dw -= 360
            while (dw < -180) dw += 360
            return Rig(
                l(bodyX, o.bodyX), l(bodyY, o.bodyY), l(lean, o.lean), l(twist, o.twist),
                l(rx, o.rx), l(ry, o.ry), weapon + dw * t, l(lx, o.lx), l(ly, o.ly),
                l(shield, o.shield), l(stride, o.stride), l(head, o.head), l(cloak, o.cloak), l(glow, o.glow), l(draw, o.draw),
            )
        }
    }

    // ---------------------------------------------------------------- key poses

    val STAND = Rig()
    val BREATHE = Rig(bodyY = 0.8, ry = 64.8, ly = 69.6, cloak = 1.0)

    val SLASH_WIND = Rig(bodyX = -2.0, lean = -3.0, twist = 0.7, rx = 60.0, ry = 20.0, weapon = -150.0, lx = 34.0, ly = 62.0, head = 0.3, cloak = -1.0)
    val SLASH_HIT = Rig(bodyX = 5.0, bodyY = 1.5, lean = 7.0, twist = -0.5, rx = 84.0, ry = 58.0, weapon = 40.0, lx = 30.0, ly = 64.0, stride = 6.0, cloak = 2.0)

    val THRUST_WIND = Rig(bodyX = -3.0, lean = -4.0, twist = 0.5, rx = 60.0, ry = 56.0, weapon = -32.0, lx = 33.0, ly = 66.0)
    val THRUST_HIT = Rig(bodyX = 7.0, bodyY = 1.0, lean = 9.0, twist = -0.6, rx = 90.0, ry = 34.0, weapon = -36.0, lx = 28.0, ly = 66.0, stride = 9.0, cloak = 2.5)

    val SMASH_WIND = Rig(bodyX = -1.0, bodyY = -2.0, lean = -2.0, twist = 0.3, rx = 52.0, ry = 12.0, weapon = -112.0, lx = 47.0, ly = 16.0, head = 0.2, cloak = -1.5)
    val SMASH_HIT = Rig(bodyX = 5.0, bodyY = 5.0, lean = 8.0, twist = -0.3, rx = 78.0, ry = 70.0, weapon = 72.0, lx = 70.0, ly = 70.0, stride = 7.0, cloak = 2.5)

    val BOW_AIM = Rig(lean = 1.0, twist = 0.4, rx = 54.0, ry = 30.0, lx = 84.0, ly = 36.0, draw = 1.0, head = 0.6)
    val BOW_RELEASE = Rig(lean = -1.0, twist = 0.2, rx = 44.0, ry = 34.0, lx = 85.0, ly = 35.0, draw = 0.0, head = 0.6, cloak = -0.5)

    val CAST_RAISE = Rig(bodyY = -1.0, lean = -2.0, rx = 66.0, ry = 16.0, weapon = -84.0, lx = 38.0, ly = 50.0, glow = 0.6, head = 0.2)
    val CAST_RELEASE = Rig(bodyX = 4.0, lean = 6.0, rx = 86.0, ry = 30.0, weapon = -40.0, lx = 44.0, ly = 46.0, glow = 1.0, stride = 5.0, cloak = 1.5)

    val BLOCK = Rig(bodyX = -2.0, bodyY = 2.0, lean = -2.0, twist = 0.3, rx = 70.0, ry = 68.0, weapon = -20.0, lx = 64.0, ly = 38.0, shield = 1.0, head = -0.2)
    val HURT = Rig(bodyX = -6.0, bodyY = 2.0, lean = -7.0, twist = 0.3, rx = 66.0, ry = 70.0, weapon = -80.0, lx = 28.0, ly = 66.0, head = -0.4, cloak = -2.0)

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
    private val IDLE = List(IDLE_FRAMES) { STAND.lerp(BREATHE, (1 - cos(it / IDLE_FRAMES.toDouble() * 2 * PI)) / 2) }

    /** Two-handed weapons are held in front with both hands, the head of the weapon up towards the foe. */
    private fun twoHand(r: Rig) = if (r == STAND || r == BREATHE) r.copy(rx = 61.0, ry = r.ry - 1, weapon = -55.0) else r

    private val SEQ = mapOf(
        Strike.SLASH to tween(STAND to 3, SLASH_WIND to 6, SLASH_HIT to 4, SLASH_HIT to 4, STAND to 1),
        Strike.THRUST to tween(STAND to 3, THRUST_WIND to 5, THRUST_HIT to 3, THRUST_HIT to 5, STAND to 1),
        Strike.SMASH to tween(STAND to 3, SMASH_WIND to 7, SMASH_HIT to 3, SMASH_HIT to 5, STAND to 1),
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

    fun frameCount(act: Act, strike: Strike = Strike.SLASH): Int = sequence(act, strike).size

    private fun sequence(act: Act, strike: Strike, twoHanded: Boolean = false): List<Rig> = when (act) {
        Act.IDLE -> if (twoHanded) IDLE_2H else IDLE
        Act.ATTACK -> if (twoHanded) SEQ_2H.getValue(strike) else SEQ.getValue(strike)
        Act.CAST -> SEQ.getValue(Strike.CAST)
        Act.BLOCK -> BLOCK_SEQ
        Act.HURT -> HURT_SEQ
    }

    private val IDLE_2H = IDLE.map { r -> r.copy(rx = r.rx - 11, weapon = -55.0) }
    private val SEQ_2H by lazy {
        mapOf(
            Strike.SLASH to tween(twoHand(STAND) to 3, SLASH_WIND to 6, SLASH_HIT to 4, SLASH_HIT to 4, twoHand(STAND) to 1),
            Strike.THRUST to tween(twoHand(STAND) to 3, THRUST_WIND to 5, THRUST_HIT to 3, THRUST_HIT to 5, twoHand(STAND) to 1),
            Strike.SMASH to tween(twoHand(STAND) to 3, SMASH_WIND to 7, SMASH_HIT to 3, SMASH_HIT to 5, twoHand(STAND) to 1),
            Strike.SHOOT to SEQ.getValue(Strike.SHOOT),
            Strike.CAST to SEQ.getValue(Strike.CAST),
        )
    }

    private fun twoHanded(hero: Hero) = hero.item(GearSlot.MAIN_HAND)?.def?.let { it.twoHanded && !it.ranged } == true

    private val cache = object : LinkedHashMap<String, PixelImage>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 160
    }

    private data class Part(val icon: Icon, val rarity: Rarity, val weight: Weight, val kind: BaseKind, val twoHanded: Boolean, val ranged: Boolean, val base: String)

    private fun part(g: Gear?) = g?.def?.let { Part(it.icon, g.rarity, it.weight, it.kind, it.twoHanded, it.ranged, g.base) }

    /** Frame [index] of [act]; attacks use [strike]. */
    fun frame(hero: Hero, act: Act, index: Int = 0, strike: Strike = strikes(hero).first()): PixelImage {
        val seq = sequence(act, strike, twoHanded(hero))
        val i = if (act == Act.IDLE) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        return draw(hero, seq[i], "$act/$strike/$i")
    }

    fun draw(hero: Hero, rig: Rig, tag: String = rig.toString()): PixelImage {
        val parts = GearSlot.entries.associateWith { part(hero.item(it)) }
        val key = "${hero.race}/${hero.cls}/$tag/" + parts.values.joinToString(",")
        synchronized(cache) { cache[key]?.let { return it } }
        val s = Sculpt(W, H, 17)
        Painter(s, hero.race, hero.cls, parts, rig).draw()
        s.transform()
        s.rim(argb(0xF4D8B0), 0.3)
        s.outline(argb(0x14100E))
        synchronized(cache) { cache[key] = s.img }
        return s.img
    }

    /** Draws every frame ahead, e.g. in the background before a fight. */
    fun prepare(hero: Hero) {
        for (i in 0 until IDLE_FRAMES) frame(hero, Act.IDLE, i)
        for (st in strikes(hero)) for (i in 0 until frameCount(Act.ATTACK, st)) frame(hero, Act.ATTACK, i, st)
        for (a in listOf(Act.CAST, Act.BLOCK, Act.HURT)) for (i in 0 until frameCount(a)) frame(hero, a, i)
    }

    private class Painter(val s: Sculpt, val race: Race, val cls: CharClass, val parts: Map<GearSlot, Part?>, val r: Rig) {
        val look = CharacterArt.heroLook(race, cls)

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

        fun metal(rar: Rarity): Mat {
            val tint = when (rar) {
                Rarity.COMMON, Rarity.UNCOMMON -> 0.0
                Rarity.RARE -> 0.25
                Rarity.VERY_RARE -> 0.35
                Rarity.EPIC, Rarity.DIVINE -> 0.45
            }
            return m(mix(argb(0xA0A8B2), rar.color.toInt(), tint), shine = 0.85)
        }

        fun cloakColor(rar: Rarity) = worn(argb(
            when (rar) {
                Rarity.COMMON -> 0x5A4636
                Rarity.UNCOMMON -> 0x34603A
                Rarity.RARE -> 0x34508A
                Rarity.VERY_RARE -> 0x56347E
                Rarity.EPIC -> 0x8A3E22
                Rarity.DIVINE -> 0xC8B888
            },
        ), 0.2)

        val scale = when (race) { Race.HALFLING -> 0.72; Race.DWARF -> 0.8; Race.ELF -> 1.03; else -> 1.0 }
        val wide = when (race) { Race.DWARF -> 1.28; Race.HALF_ORC -> 1.16; Race.ELF -> 0.98; Race.HALFLING -> 1.1; else -> 1.06 }
        val headBig = when (race) { Race.HALFLING -> 1.2; Race.DWARF -> 1.12; else -> 0.95 }

        // the upper body moves with lean and twist; hips stay over the feet
        val sx = r.bodyX + r.lean * 0.45
        val sy = r.bodyY
        val shL = Pair(33.0 + sx + r.twist * 2.5, 41.0 + sy + r.twist * 0.5)
        val shR = Pair(65.0 + sx - r.twist * 1.5, 41.0 + sy - r.twist * 1.5)
        val hipX = 49.0 + r.bodyX * 0.5

        val chest = parts[GearSlot.CHEST]
        val weight = chest?.weight
        val robe = (chest == null && look.robe) || weight == Weight.CLOTH
        val heavy = weight == Weight.HEAVY
        val medium = weight == Weight.MEDIUM
        val main = parts[GearSlot.MAIN_HAND]
        val off = parts[GearSlot.OFF_HAND]
        val twoHands = main?.twoHanded == true && main.ranged.not()

        /** Two-bone reach: the elbow for a hand at [t] from shoulder [a], bending outwards to [side]. */
        fun elbow(a: Pair<Double, Double>, t: Pair<Double, Double>, side: Double, l1: Double = 16.5, l2: Double = 15.5): Pair<Pair<Double, Double>, Pair<Double, Double>> {
            var dx = t.first - a.first; var dy = t.second - a.second
            var d = sqrt(dx * dx + dy * dy)
            val max = l1 + l2 - 0.5
            if (d > max) { dx *= max / d; dy *= max / d; d = max }
            val hand = Pair(a.first + dx, a.second + dy)
            val cosA = ((l1 * l1 + d * d - l2 * l2) / (2 * l1 * d.coerceAtLeast(0.01))).coerceIn(-1.0, 1.0)
            val base = atan2(dy, dx)
            val ang = base + side * Math.acos(cosA)
            return Pair(Pair(a.first + cos(ang) * l1, a.second + sin(ang) * l1), hand)
        }

        fun draw() {
            s.transform(ANCHOR_X - 48.0, GROUND - 124.0, SIZE * scale * wide, SIZE * scale, ANCHOR_X.toDouble(), GROUND.toDouble())
            // a raised shield is in front of the body, so behind it for us
            if (r.shield > 0.5 && off?.kind == BaseKind.SHIELD) shieldRaised(off)
            // a weapon pointed far forward is partly behind the body
            legs()
            skirt()
            torso()
            cloak()
            shoulders()
            head()
            leftArm()
            rightArm()
        }

        fun legs() {
            val legsPart = parts[GearSlot.LEGS]
            val shin = if (legsPart?.icon == Icon.LEGS && legsPart.weight == Weight.HEAVY) metal(legsPart.rarity) else pantsMat
            val boot = if (legsPart?.icon == Icon.BOOTS && legsPart.weight == Weight.HEAVY) darkSteel else darkLeather
            val crouch = r.bodyY.coerceAtLeast(0.0)
            // back leg left, front leg right towards the foe; knees bend when crouching
            val lHip = Pair(hipX - 6.5, 73.0 + r.bodyY * 0.6); val rHip = Pair(hipX + 6.5, 73.0 + r.bodyY * 0.6)
            val lFoot = Pair(35.0 - r.stride * 0.3, 121.0); val rFoot = Pair(64.0 + r.stride, 120.0 - r.stride * 0.35)
            val lKnee = Pair((lHip.first + lFoot.first) / 2 - 1.5 - crouch * 0.6, (lHip.second + lFoot.second) / 2)
            val rKnee = Pair((rHip.first + rFoot.first) / 2 + 1.5 + crouch * 0.8, (rHip.second + rFoot.second) / 2 - crouch * 0.3)
            fun leg(hip: Pair<Double, Double>, knee: Pair<Double, Double>, foot: Pair<Double, Double>, far: Boolean) {
                val bias = if (far) -0.08 else 0.0
                s.limb(hip.first, hip.second, knee.first, knee.second, 6.4, 5.0, pantsMat.copy(bias = bias))
                s.limb(knee.first, knee.second, foot.first, foot.second - 4, 5.0, 3.8, shin.copy(bias = bias))
                s.limb(foot.first, foot.second - 12, foot.first, foot.second, 4.3, 4.1, boot.copy(bias = bias))
                s.blob(foot.first + 1.2, foot.second + 1.5, 5.2, 3.0, boot.copy(bias = bias))
                s.limb(foot.first - 4.2, foot.second - 12, foot.first + 4.2, foot.second - 12, 1.0, 1.0, leather)
                if (shin != pantsMat) s.blob(knee.first, knee.second, 4.0, 3.4, shin)
            }
            leg(lHip, lKnee, lFoot, false)
            leg(rHip, rKnee, rFoot, true)
        }

        fun skirt() {
            if (robe) {
                val sw = r.cloak
                s.poly(cloth, hipX - 14, 60.0 + sy, hipX + 14, 60.0 + sy, hipX + 20 + sw, 118.0, hipX + 9 + sw, 120.0, hipX + sw, 117.0, hipX - 9 + sw, 120.0, hipX - 19 + sw, 118.0, tiltY = -0.12)
                for (x in listOf(-7.0, 1.0, 8.0)) s.line(hipX + x, 70.0, hipX + x * 1.4 + sw, 116.0, Ramp.of(worn(look.cloth))[1])
            } else if (medium || heavy) {
                val mail = if (heavy) metal(chest!!.rarity) else m(argb(0x8A9098), shine = 0.4, grain = 0.4)
                s.poly(mail, hipX - 13, 66.0 + sy, hipX + 13, 66.0 + sy, hipX + 15, 86.0, hipX - 15, 86.0, tiltY = -0.2)
                if (heavy) for (k in 0..2) s.limb(hipX - 12.5, 70.0 + k * 5 + sy * 0.5, hipX + 12.5, 70.0 + k * 5 + sy * 0.5, 1.4, 1.4, metal(chest!!.rarity))
            } else {
                s.poly(m(worn(look.clothDark, 0.4), grain = 0.05), hipX - 13, 64.0 + sy, hipX + 13, 64.0 + sy, hipX + 14, 82.0, hipX - 14, 82.0, tiltY = -0.2)
            }
        }

        val torsoMat: Mat get() = when {
            heavy -> metal(chest!!.rarity)
            medium -> m(argb(0x8A9098), shine = 0.45, grain = 0.45)
            weight == Weight.LIGHT -> leather
            else -> cloth
        }

        fun torso() {
            val t = torsoMat
            val cx = (shL.first + shR.first) / 2
            // a broad back narrowing to the waist: the heroic V
            s.poly(t, shL.first - 1, shL.second - 2, shR.first + 1, shR.second - 2, shR.first - 2, shR.second + 14, hipX + 11.5, 66.0 + sy, hipX - 11.5, 66.0 + sy, shL.first + 2, shL.second + 14, tiltY = -0.1, bevel = 3.0)
            s.blob(cx - 7, 50.0 + sy, 8.5, 11.0, t)
            s.blob(cx + 7, 50.0 + sy, 8.5, 11.0, t)
            // the spine between the shoulder blades
            s.line(cx, 40.0 + sy, (cx + hipX) / 2, 64.0 + sy, t.ramp[1])
            if (heavy) for (y in listOf(44.0, 52.0, 60.0)) { s.dot(cx - 9, y + sy, argb(0xD0D4D8)); s.dot(cx + 9, y + sy, argb(0xD0D4D8)) }
            if (weight == Weight.LIGHT) for (k in 0..4) s.line(cx - 2, 43.0 + k * 4 + sy, cx + 2, 45.0 + k * 4 + sy, argb(0x2A1C14))
            // belt, buckle at the back, pouch on the right hip, knife for rogues
            s.limb(hipX - 13, 67.0 + sy * 0.6, hipX + 13, 67.0 + sy * 0.6, 2.3, 2.3, darkLeather)
            s.blob(hipX + 10, 71.0, 3.8, 4.4, leather)
            if (cls == CharClass.ROGUE) { s.limb(hipX - 6, 66.0, hipX + 3, 72.0, 1.3, 1.1, darkLeather); s.limb(hipX + 3, 72.0, hipX + 7, 74.5, 0.9, 0.5, steel) }
        }

        fun cloak() {
            val cl = parts[GearSlot.CLOAK] ?: return
            val col = cloakColor(cl.rarity)
            val folds = 6
            for (k in 0 until folds) {
                val t = k / (folds - 1.0)
                val topX = shL.first + 6 + t * (shR.first - shL.first - 12)
                val botX = hipX - 17 + t * 34 + r.cloak * (0.4 + t)
                val hem = 99.0 + (if (k % 2 == 0) 2.5 else 0.0)
                s.limb(topX, shL.second + 0.5, botX, hem, 3.8, 4.6, m(col, grain = 0.03).copy(bias = if (k % 2 == 0) 0.03 else -0.05, inline = k == 0))
            }
            s.blob((shL.first + shR.first) / 2, shL.second - 2.5, 13.0, 5.0, m(col, grain = 0.03))
            s.limb(shL.first + 9, shL.second - 3, shR.first - 9, shR.second - 3, 1.0, 1.0, if (cl.rarity >= Rarity.EPIC) gold else darkLeather)
        }

        fun shoulders() {
            val p = when { heavy -> metal(chest!!.rarity); medium -> leather; else -> torsoMat }
            val big = if (heavy) 1.0 else 0.0
            s.blob(shL.first + 0.5, shL.second, 5.6 + big * 1.4, 4.6 + big, p)
            s.blob(shR.first - 0.5, shR.second, 5.6 + big * 1.4, 4.6 + big, p)
            if (heavy) { s.limb(shL.first - 5, shL.second + 3, shL.first + 4, shL.second + 4, 1.2, 1.2, p); s.limb(shR.first - 4, shR.second + 4, shR.first + 5, shR.second + 3, 1.2, 1.2, p) }
        }

        fun head() {
            val k = headBig
            val hx = (shL.first + shR.first) / 2 + r.head * 1.5
            val hy = 28.0 + sy
            s.limb(hx, 33.0 + sy, (shL.first + shR.first) / 2, 36.0 + sy, 3.4 * k, 4.2, skin.copy(bias = -0.2))
            // a collar closes the neck: mail coif, padded collar or the cloak's
            val collar = when {
                heavy || medium -> m(argb(0x8A9098), shine = 0.4, grain = 0.45)
                parts[GearSlot.CLOAK] != null -> m(cloakColor(parts[GearSlot.CLOAK]!!.rarity), grain = 0.03)
                else -> torsoMat
            }
            s.blob((shL.first + shR.first) / 2, 37.0 + sy, 8.5, 4.2, collar)
            // a sliver of cheek and jaw behind the ear: the hero looks at the foe
            val turn = 0.6 + r.head * 0.4
            s.blob(hx + 4.5 * turn, hy + 2.5, 2.4 * k, 3.4 * k, skin)
            if (race == Race.ELF) s.poly(skin, hx + 7, hy + 1, hx + 15, hy - 6, hx + 7.5, hy + 4) else s.blob(hx + 7.5, hy + 1.5, 1.9, 2.6, skin)
            s.blob(hx - 7.3, hy + 1.5, 1.6, 2.4, skin)
            s.blob(hx, hy, 7.0 * k, 7.8 * k, hair)
            when (race) {
                Race.ELF -> s.chain(hair, hx, hy + 2, 6.0, hx - 0.5, hy + 10, 4.6, hx - 1.0, hy + 17, 3.0, hx - 1.5, hy + 22, 1.2)
                Race.DWARF -> {
                    s.limb(hx - 7.5, hy + 6, hx - 9.5, hy + 16, 2.3, 1.7, hair); s.limb(hx + 8.5, hy + 6, hx + 11, hy + 16, 2.3, 1.7, hair)
                    s.blob(hx - 9.5, hy + 17, 1.4, 1.4, gold); s.blob(hx + 11, hy + 17, 1.4, 1.4, gold)
                }
                Race.HALF_ORC -> s.limb(hx, hy - 7, hx - 0.5, hy - 13, 2.5, 1.7, hair)
                Race.HALFLING -> for ((dx, dy) in listOf(-5.0 to -3.0, 0.0 to -6.0, 5.0 to -3.0, -6.0 to 2.0, 6.0 to 2.0)) s.blob(hx + dx, hy + dy, 2.8, 2.8, hair)
                else -> {}
            }
            val head = parts[GearSlot.HEAD]
            val gear = when (head?.icon) { Icon.HELMET -> Headgear.HELMET; Icon.HOOD -> Headgear.HOOD; Icon.CIRCLET -> Headgear.CIRCLET; else -> look.headgear }
            val rar = head?.rarity ?: Rarity.COMMON
            when (gear) {
                Headgear.HELMET -> {
                    val hm = if (head?.weight == Weight.LIGHT) leather else metal(rar)
                    if (head?.base == "great_helm") {
                        s.blob(hx, hy, 8.4 * k, 9.4 * k, hm)
                        s.limb(hx - 8, hy + 6, hx + 8.5, hy + 6, 1.4, 1.4, hm)
                    } else {
                        s.blob(hx, hy - 2, 8.0 * k, 7.6 * k, hm)
                        s.limb(hx - 7.8, hy + 2.5, hx + 8, hy + 2.5, 1.3, 1.3, hm)
                        s.line(hx, hy - 9, hx, hy + 2, hm.ramp[1])
                    }
                }
                Headgear.HOOD -> {
                    val hm = m(if (head == null) worn(look.cloth) else cloakColor(rar), grain = 0.04)
                    s.blob(hx, hy, 8.6 * k, 9.2 * k, hm)
                    s.poly(hm, hx - 8.5, hy + 3, hx + 8.5, hy + 3, hx + 9.5, hy + 14, hx - 9.5, hy + 14)
                    s.line(hx, hy - 6, hx, hy + 12, hm.ramp[1])
                }
                Headgear.CIRCLET -> s.limb(hx - 7.5, hy - 1, hx + 7.5, hy - 1, 0.9, 0.9, if (rar >= Rarity.RARE) metal(rar) else gold)
                Headgear.HAT -> {
                    val hm = m(worn(look.cloth), grain = 0.03)
                    s.blob(hx, hy - 3, 14.0, 4.0, hm)
                    s.poly(hm, hx - 7.5, hy - 4, hx + 7.5, hy - 4, hx + 5.5 + r.cloak * 0.5, hy - 18, hx + 1.5 + r.cloak, hy - 25, hx - 2.5 + r.cloak * 0.5, hy - 20)
                    s.limb(hx - 7, hy - 4.5, hx + 7, hy - 4.5, 1.0, 1.0, gold)
                }
                else -> {}
            }
        }

        val gloves = parts[GearSlot.ARMS]
        val hand: Mat get() = when {
            gloves == null -> skin
            gloves.weight == Weight.HEAVY || gloves.weight == Weight.MEDIUM -> darkSteel
            else -> leather
        }
        val sleeve: Mat get() = if (robe) clothDark else if (heavy) metal(chest!!.rarity) else torsoMat

        fun arm(sh: Pair<Double, Double>, target: Pair<Double, Double>, side: Double, bias: Double): Pair<Double, Double> {
            val (el, h) = elbow(sh, target, side)
            // a strong upper arm, then the forearm; gloves or bracers over the lower half
            s.limb(sh.first, sh.second, el.first, el.second, 5.0, 4.2, sleeve.copy(bias = bias))
            s.limb(el.first, el.second, h.first, h.second, 4.2, 3.4, (if (gloves != null) hand else sleeve).copy(bias = bias))
            if (gloves != null) s.limb((el.first + h.first) / 2, (el.second + h.second) / 2, h.first, h.second, 4.3, 3.8, hand)
            return h
        }

        fun leftArm() {
            val target = if (twoHands && r.shield < 0.5) Pair(r.rx - 4, r.ry + 3) else Pair(r.lx, r.ly)
            val h = arm(shL, target, -1.0, 0.0)
            if (main?.ranged == true) bow(h, main.rarity)
            s.blob(h.first, h.second, 3.4, 3.4, hand)
            when {
                off == null || twoHands -> {}
                off.kind == BaseKind.SHIELD -> if (r.shield <= 0.5) shieldAtSide(off, h)
                off.icon == Icon.ORB -> {
                    val g = mix(argb(0x80C8FF), off.rarity.color.toInt(), 0.4)
                    val rr = 4.2 + r.glow * 1.5
                    s.flat(h.first, h.second - 6, rr + 3, rr + 3, alpha(g, (70 + r.glow * 90).toInt()))
                    s.blob(h.first, h.second - 6, rr, rr, m(g, shine = 1.0).copy(inline = false))
                }
                off.icon == Icon.TOME -> {
                    s.poly(m(worn(mix(argb(0x6A2A22), off.rarity.color.toInt(), 0.3), 0.2)), h.first - 8, h.second - 9, h.first + 4, h.second - 9, h.first + 4, h.second + 4, h.first - 8, h.second + 4)
                    s.line(h.first - 2, h.second - 9, h.first - 2, h.second + 4, argb(0xB8904A))
                }
                off.icon == Icon.SYMBOL -> {
                    s.limb(h.first, h.second, h.first, h.second + 6, 0.5, 0.5, darkLeather)
                    s.blob(h.first, h.second + 7, 2.8, 2.8, gold)
                    s.flat(h.first, h.second + 7, 1.0 + r.glow, 1.0 + r.glow, argb(0xF8F0D8))
                }
                off.kind == BaseKind.WEAPON -> weapon(off, h.first, h.second, r.weapon - 70)
                else -> {}
            }
        }

        fun rightArm() {
            if (main != null && !main.ranged) weapon(main, r.rx, r.ry, r.weapon)
            val h = arm(shR, Pair(r.rx, r.ry), 1.0, -0.04)
            if (main?.ranged == true && r.draw > 0.3) {
                // the arrow nocked and drawn back towards the cheek
                val bowHand = Pair(r.lx, r.ly)
                s.limb(h.first, h.second, bowHand.first + 3, bowHand.second - 1, 0.6, 0.6, wood)
                s.limb(bowHand.first + 2, bowHand.second - 1, bowHand.first + 6, bowHand.second - 2.5, 1.0, 0.3, steel)
            }
            s.blob(h.first, h.second, 3.4, 3.4, hand)
        }

        /** The shield hangs on the arm, its painted face turned outwards, so we see paint and boss at a slant. */
        fun shieldAtSide(p: Part, h: Pair<Double, Double>) {
            val tower = p.base == "tower_shield"
            val hw = if (tower) 8.0 else 6.5; val hh = if (tower) 20.0 else 14.0
            val cx = h.first - 5; val cy = h.second - 2
            val rim = metal(p.rarity)
            val face = m(worn(if (p.rarity >= Rarity.RARE) mix(argb(0x7A2A22), p.rarity.color.toInt(), 0.45) else argb(0x6E2E24), 0.15))
            s.poly(rim, cx - hw, cy - hh, cx + hw, cy - hh + 3, cx + hw, cy + hh * 0.45, cx, cy + hh + 3, cx - hw, cy + hh * 0.4, tiltX = -0.7, bevel = 1.8)
            s.poly(face, cx - hw + 1.6, cy - hh + 1.8, cx + hw - 1.6, cy - hh + 4.5, cx + hw - 1.6, cy + hh * 0.42, cx, cy + hh + 0.5, cx - hw + 1.6, cy + hh * 0.38, tiltX = -0.7, bevel = 1.0)
            // a pale stripe and the iron boss
            s.limb(cx - hw + 2, cy - hh * 0.1, cx + hw - 2, cy - hh * 0.1 + 2.5, 1.2, 1.2, m(argb(0xC8BCA0)))
            s.blob(cx, cy - 1, 2.6, 3.0, rim)
        }

        /** Raised against the foe: in front of the body, so we see its inside, with straps, and its rim. */
        fun shieldRaised(p: Part) {
            val tower = p.base == "tower_shield"
            val (_, h) = elbow(shL, Pair(r.lx, r.ly), -1.0)
            val cx = h.first + 5; val cy = h.second - 2
            val hw = if (tower) 12.0 else 10.0; val hh = if (tower) 22.0 else 15.0
            val rim = metal(p.rarity)
            s.poly(rim, cx - hw, cy - hh, cx + hw, cy - hh + 2, cx + hw, cy + hh * 0.45, cx, cy + hh + 3, cx - hw, cy + hh * 0.45, tiltX = 0.4, bevel = 1.8)
            s.poly(wood, cx - hw + 2, cy - hh + 2, cx + hw - 2, cy - hh + 4, cx + hw - 2, cy + hh * 0.42, cx, cy + hh, cx - hw + 2, cy + hh * 0.42, tiltX = 0.4, bevel = 0.8)
            var x = cx - hw + 5
            while (x < cx + hw - 2) { s.line(x, cy - hh + 3, x, cy + hh * 0.6, wood.ramp[0]); x += 4.5 }
            s.limb(cx - hw + 3, cy - 4, cx + hw - 3, cy - 3, 1.3, 1.3, darkLeather)
            s.limb(cx - hw + 3, cy + 4, cx + hw - 3, cy + 5, 1.3, 1.3, darkLeather)
        }

        fun bow(h: Pair<Double, Double>, rar: Rarity) {
            val bw = m(mix(argb(0x5E3E24), rar.color.toInt(), if (rar >= Rarity.RARE) 0.3 else 0.0), grain = 0.05)
            // the bow stands upright in the left hand, pointing at the foe; the string pulled towards us
            val x = h.first; val y = h.second
            s.chain(bw, x - 3, y - 24, 1.3, x + 1, y - 12, 2.0, x + 2.5, y, 2.4, x + 1, y + 12, 2.0, x - 3, y + 24, 1.3)
            val pull = 3.0 + r.draw * 16
            val sx2 = x - 3 - pull; val sy2 = y - r.draw * 3
            s.line(x - 3, y - 24, sx2, sy2, argb(0xD8D0C0)); s.line(sx2, sy2, x - 3, y + 24, argb(0xD8D0C0))
        }

        fun weapon(p: Part, hx: Double, hy: Double, deg: Double) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a)
            val met = metal(p.rarity)
            val long = if (p.twoHanded) 1.35 else 1.0
            fun along(d: Double) = Pair(hx + dx * d, hy + dy * d)
            when (p.icon) {
                Icon.SWORD, Icon.DAGGER -> {
                    val len = (if (p.icon == Icon.DAGGER) (if (p.base == "shortsword") 22.0 else 15.0) else 32.0) * long
                    s.limb(hx - dx * 7, hy - dy * 7, hx + dx, hy + dy, 1.6, 1.6, darkLeather)
                    s.blob(hx - dx * 8, hy - dy * 8, 2.0, 2.0, gold)
                    s.limb(hx + dy * 6, hy - dx * 6, hx - dy * 6, hy + dx * 6, 1.4, 1.4, darkSteel)
                    blade(hx + dx * 2, hy + dy * 2, deg, len, if (p.twoHanded) 3.6 else 2.9, met)
                }
                Icon.AXE -> {
                    val (ex, ey) = along(26.0 * long)
                    s.limb(hx - dx * 9, hy - dy * 9, ex, ey, 1.8, 1.6, wood)
                    val px = -dy; val py = dx
                    val w = if (p.twoHanded) 1.7 else 1.25
                    s.poly(met, ex - dx * 4, ey - dy * 4, ex + px * 12 * w - dx * 7 * w, ey + py * 12 * w - dy * 7 * w,
                        ex + px * 13 * w + dx * 6 * w, ey + py * 13 * w + dy * 6 * w, ex + dx * 4, ey + dy * 4, bevel = 1.8)
                    if (p.twoHanded) s.poly(met, ex - dx * 3, ey - dy * 3, ex - px * 8 * w - dx * 5, ey - py * 8 * w - dy * 5,
                        ex - px * 9 * w + dx * 4, ey - py * 9 * w + dy * 4, ex + dx * 3, ey + dy * 3, bevel = 1.6)
                }
                Icon.MACE, Icon.HAMMER -> {
                    val (ex, ey) = along(24.0 * long)
                    s.limb(hx - dx * 7, hy - dy * 7, ex, ey, 1.8, 1.6, wood)
                    if (p.icon == Icon.MACE) {
                        s.blob(ex, ey, 5.5 * long, 5.5 * long, met)
                        for (k in 0 until 6) {
                            val sa = k * 60.0 + deg
                            s.limb(ex, ey, Sculpt.polarX(ex, 8.0 * long, sa), Sculpt.polarY(ey, 8.0 * long, sa), 1.4, 0.5, met)
                        }
                    } else {
                        val px = -dy; val py = dx
                        val w = 5.0 * long; val h = 10.0 * long
                        s.poly(met, ex + px * h - dx * w, ey + py * h - dy * w, ex + px * h + dx * w, ey + py * h + dy * w,
                            ex - px * h + dx * w, ey - py * h + dy * w, ex - px * h - dx * w, ey - py * h - dy * w, bevel = 2.0)
                    }
                }
                Icon.SPEAR -> {
                    val (ex, ey) = along(42.0)
                    s.limb(hx - dx * 18, hy - dy * 18, ex, ey, 1.5, 1.5, wood)
                    if (p.twoHanded) {
                        val px = -dy; val py = dx
                        s.poly(met, ex, ey, ex + px * 7 - dx * 3, ey + py * 7 - dy * 3, ex + px * 6 + dx * 4, ey + py * 6 + dy * 4, bevel = 1.4)
                    }
                    blade(ex, ey, deg, 12.0, 3.0, met)
                }
                Icon.STAFF, Icon.WAND -> {
                    val len = if (p.icon == Icon.STAFF) 42.0 else 16.0
                    val (ex, ey) = along(len)
                    s.limb(hx - dx * (if (p.icon == Icon.STAFF) 24.0 else 3.0), hy - dy * (if (p.icon == Icon.STAFF) 24.0 else 3.0), ex, ey,
                        if (p.icon == Icon.STAFF) 1.9 else 1.2, if (p.icon == Icon.STAFF) 2.2 else 1.0, wood)
                    val g = mix(argb(0x80E0FF), p.rarity.color.toInt(), 0.5)
                    val rr = (if (p.icon == Icon.STAFF) 3.6 else 2.2) + r.glow * 2.2
                    s.flat(ex, ey, rr + 3 + r.glow * 3, rr + 3 + r.glow * 3, alpha(g, (70 + r.glow * 100).toInt()))
                    s.blob(ex, ey, rr, rr, m(g, shine = 1.0).copy(inline = false))
                }
                Icon.CROSSBOW -> {
                    val (ex, ey) = along(18.0)
                    s.limb(hx - dx * 6, hy - dy * 6, ex, ey, 2.0, 1.8, wood)
                    s.limb(ex - dy * 9, ey + dx * 9, ex + dy * 9, ey - dx * 9, 1.4, 1.4, darkSteel)
                }
                else -> s.limb(hx - dx * 6, hy - dy * 6, hx + dx * 20, hy + dy * 20, 1.8, 1.8, wood)
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
            // the fuller down the middle catches the light
            s.line(hx + dx * 1, hy + dy * 1, hx + dx * len * 0.8, hy + dy * len * 0.8, mat.ramp.light)
        }
    }

}
