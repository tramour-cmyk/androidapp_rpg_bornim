package de.bornim.core.art

import de.bornim.core.GearBases
import de.bornim.core.GearSlot
import de.bornim.core.MonsterKits
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.Sex
import de.bornim.core.art.HeroFigure.Rig
import de.bornim.core.art.HeroFigure.V

/**
 * Foes on the hero's doll: goblins and skeletons in battle. They move as the hero does (the same keys, blows, blocks
 * and hits) but turned round to face the hero, each kind in its own manner: a goblin stooped and springing, the dead
 * upright and stiff. Every act comes in at least three variants. A frame is [W] × [H] with the feet at ([ANCHOR_X],
 * [GROUND]).
 */
object FoeArt {
    // wide towards the hero on the left, so a spear or a lunge is not cut off
    const val W = 290
    // room below the feet too: a body falling forward comes towards us and lies lower in the picture than its feet
    const val H = 215
    const val ANCHOR_X = 160.0
    const val GROUND = 170.0
    /** Art pixels per centimetre: the foe stands further off than the hero. */
    const val PX = 0.66

    /** Foes drawn this way. */
    val KINDS = setOf("goblin", "goblin_archer", "skeleton")

    private fun creature(id: String) = if (id == "skeleton") Doll.Creature.SKELETON else Doll.Creature.GOBLIN

    fun doll(id: String, look: MonsterLook) =
        Doll(Race.HUMAN, Sex.MALE, MonsterKits.build(look.seed), MonsterKits.tone(look.seed), 0, creature(id), MonsterKits.size(id, look.seed))

    fun outfit(id: String, look: MonsterLook) = Outfit.of(MonsterKits.of(id, look.seed)!!)

    /** How the foe fights: with a bow, a spear, two blades, or one blade (with or without a shield). */
    private enum class Style { BLADE, SPEAR, TWO_BLADES, BOW }

    private fun style(id: String, look: MonsterLook): Style {
        val kit = MonsterKits.of(id, look.seed)!!
        val main = kit.items[GearSlot.MAIN_HAND]?.let { GearBases[it] }
        val off = kit.items[GearSlot.OFF_HAND]?.let { GearBases[it] }
        return when {
            main?.ranged == true -> Style.BOW
            kit.items[GearSlot.MAIN_HAND] == "spear" -> Style.SPEAR
            off?.isWeapon == true -> Style.TWO_BLADES
            else -> Style.BLADE
        }
    }

    private fun hasShield(id: String, look: MonsterLook) = outfit(id, look).hasShield

    // ---------------------------------------------------------------- the moves

    /** The hero's keys turned round to face the hero. */
    private fun facing(r: Rig) = r.copy(yaw = r.yaw - 180.0)

    /** Each kind's manner over every key: a goblin stoops low with its knees bent, the dead stand stiff and upright. */
    private fun manner(kind: Doll.Creature, r: Rig): Rig = when (kind) {
        Doll.Creature.GOBLIN -> r.copy(lean = r.lean + 0.35, crouch = r.crouch + 4.0, headDown = r.headDown - 2.5)
        Doll.Creature.SKELETON -> r.copy(lean = r.lean * 0.7, headTurn = r.headTurn + 6.0)
    }

    /** A sequence with the strike frame at which the blow lands, the arrow flies, or nothing (-1). */
    class Seq(val rigs: List<Rig>, val strike: Int = -1)

    private fun tween(vararg keys: Pair<Rig, Int>) = HeroFigure.tween(*keys)

    /** The guard every act starts from and comes back to. */
    private fun rest(s: Style): Rig = when (s) {
        Style.BOW -> HeroFigure.BOW_REST
        // the off-hand blade held low and forward, apart from the main one
        Style.TWO_BLADES -> HeroFigure.STAND.copy(lh = V(-16.0, 66.0, 18.0), spread = 8.0)
        Style.SPEAR -> HeroFigure.STAND.copy(rh = V(12.0, 74.0, 10.0), weapon = V(0.25, 0.65, 0.7), aim = 1.0, grip = 15.0)
        Style.BLADE -> HeroFigure.STAND
    }

    // the hero's lunge, the point driven on and down at the hero, coming out of the picture
    private val THRUST_W = HeroFigure.THRUST_WIND.copy(weapon = V(0.1, 0.02, 0.99), aim = 1.0)
    private val THRUST_H = HeroFigure.THRUST_HIT.copy(weapon = V(0.12, -0.2, 0.97), aim = 1.0)

    private fun attacks(s: Style): List<Seq> {
        val r = rest(s)
        return when (s) {
            Style.BOW -> listOf(
                Seq(tween(r to 3, HeroFigure.BOW_NOCK to 3, HeroFigure.BOW_AIM to 4, HeroFigure.BOW_AIM to 1, HeroFigure.BOW_RELEASE to 2, HeroFigure.BOW_RELEASE to 4, r to 2), 11),
                // down on one knee for a steadier shot
                Seq(tween(r to 3, HeroFigure.BOW_NOCK.copy(crouch = 9.0) to 3, HeroFigure.BOW_AIM.copy(crouch = 9.0) to 4, HeroFigure.BOW_AIM.copy(crouch = 9.0) to 1,
                    HeroFigure.BOW_RELEASE.copy(crouch = 9.0) to 2, HeroFigure.BOW_RELEASE.copy(crouch = 9.0) to 4, r to 2), 11),
                // a quick snap shot, barely drawn
                Seq(tween(r to 2, HeroFigure.BOW_NOCK to 2, HeroFigure.BOW_AIM.copy(rh = V(8.0, 92.0, 8.0)) to 3, HeroFigure.BOW_RELEASE to 2, HeroFigure.BOW_RELEASE to 3, r to 2), 7),
            )
            Style.SPEAR -> {
                val lowW = HeroFigure.SPEAR_LOW_WIND; val lowH = HeroFigure.SPEAR_LOW_HIT
                // at the legs: from a crouch, the point a little down
                val legsH = lowH.copy(crouch = 8.0, rh = V(7.0, 58.0, 40.0), weapon = V(-0.03, -0.18, 0.98))
                val highH = HeroFigure.SPEAR_HIGH_HIT
                listOf(
                    // from below, level at the body
                    Seq(tween(r to 3, lowW to 5, lowH to 3, lowH.copy(trail = 0.0) to 5, r to 1), 8),
                    Seq(tween(r to 3, lowW.copy(crouch = 5.0) to 5, legsH to 3, legsH.copy(trail = 0.0) to 5, r to 1), 8),
                    // over the shoulder like a javelin, forward and a little down
                    Seq(tween(r to 2, HeroFigure.SPEAR_HIGH_RAISE to 2, HeroFigure.SPEAR_HIGH_WIND to 4, HeroFigure.SPEAR_HIGH_DRIVE to 2, highH to 3, highH.copy(trail = 0.0) to 5, r to 1), 10),
                )
            }
            Style.TWO_BLADES -> {
                // the off-hand blade stabs in under the main one
                // the main blade held out to its side, clear of the head, while the dagger goes in
                val stab = HeroFigure.THRUST_HIT.copy(lh = V(-6.0, 74.0, 38.0), rh = V(24.0, 78.0, 18.0), weapon = V(0.55, 0.35, 0.75), aim = 1.0, foreLevel = 0.0, twist = 25.0)
                listOf(
                    Seq(tween(r to 3, HeroFigure.SLASH_WIND to 4, HeroFigure.SLASH_OVER to 2, HeroFigure.SLASH_HIT to 3, HeroFigure.SLASH_FOLLOW to 5, r to 1), 9),
                    Seq(tween(r to 3, HeroFigure.THRUST_WIND.copy(lh = V(-20.0, 70.0, 12.0)) to 5, stab to 3, stab.copy(trail = 0.0) to 5, r to 1), 8),
                    // a cut with the main blade, then the dagger in behind it
                    Seq(tween(r to 3, HeroFigure.SLASH_WIND to 4, HeroFigure.SLASH_HIT to 3, stab to 3, stab to 4, r to 1), 7),
                )
            }
            Style.BLADE -> listOf(
                Seq(tween(r to 3, HeroFigure.SLASH_WIND to 4, HeroFigure.SLASH_OVER to 2, HeroFigure.SLASH_HIT to 3, HeroFigure.SLASH_FOLLOW to 5, r to 1), 9),
                // the blade raised wide of the big head
                Seq(tween(r to 2, HeroFigure.SMASH_RAISE.copy(rh = V(24.0, 96.0, 9.0)) to 2, HeroFigure.SMASH_WIND to 4, HeroFigure.SMASH_OVER to 2, HeroFigure.SMASH_HIT to 3, HeroFigure.SMASH_HIT.copy(trail = 0.0) to 5, r to 1), 10),
                Seq(tween(r to 3, THRUST_W to 5, THRUST_H to 3, THRUST_H.copy(trail = 0.0) to 5, r to 1), 8),
            )
        }
    }

    private fun hurts(s: Style): List<Seq> {
        val r = rest(s)
        // the weapon stays as it is held: only the body reels
        val h = HeroFigure.HURT.copy(rh = r.rh + V(4.0, -4.0, -6.0), weapon = r.weapon, aim = r.aim, grip = r.grip, lh = r.lh)
        // knocked back away from the hero: up and to the right in the picture
        return listOf(
            Seq(tween(r to 2, h.copy(bodyX = 6.0, bodyY = -1.0) to 4, r to 2)),
            // thrown back a long step, the head snapping back
            Seq(tween(r to 2, h.copy(lean = -0.7, stride = -8.0, headDown = -6.0, bodyX = 11.0, bodyY = -1.5) to 4, r to 3)),
            // wrenched round by the blow, doubling over
            Seq(tween(r to 2, h.copy(lean = 0.35, crouch = 5.0, twist = 40.0, headTurn = 30.0, headDown = 6.0, bodyX = 5.0) to 4, r to 2)),
        )
    }

    private fun dodges(s: Style, shield: Boolean): List<Seq> {
        val r = rest(s)
        val duck = r.copy(crouch = r.crouch + 8.0, lean = r.lean + 0.5, headDown = 5.0)
        // a real step: back and away from the hero, or ducking off to the side under the blow
        val back = r.copy(lean = -0.35, stride = -7.0, bodyX = 10.0, bodyY = -1.0, headDown = -2.0)
        val aside = r.copy(twist = 32.0, spread = 12.0, crouch = r.crouch + 5.0, lean = 0.35, bodyX = -9.0, bodyY = 1.5, headTurn = -12.0)
        // with a shield the blow is caught on it; the blade is held out forward, not laid back over a goblin's big head
        val first = if (shield) HeroFigure.BLOCK.copy(rh = V(22.0, 84.0, 16.0), weapon = V(0.4, 0.55, 0.75), elbowUp = 0.0, aim = 1.0, grip = 40.0) else duck
        return listOf(first, back, aside).map { Seq(tween(r to 2, it to 3, it to 2, r to 2)) }
    }

    private fun deaths(s: Style): List<Seq> {
        val r = rest(s)
        val reel = HeroFigure.HURT.copy(rh = r.rh, weapon = r.weapon, aim = r.aim, grip = r.grip, lh = r.lh)
        // the weapon hand goes slack, the blade hanging down
        val limp = V(0.2, -1.0, 0.25)
        val slack = r.copy(weapon = limp, aim = 1.0, grip = 30.0)
        return listOf(
            // the knees give, then it pitches forward onto its face, the arms thrown out before it
            Seq(tween(r to 1, reel to 3, slack.copy(crouch = 12.0, lean = 0.6, headDown = 6.0, rh = V(14.0, 50.0, 14.0), lh = V(-22.0, 50.0, 14.0), fallF = 8.0) to 4,
                // the arms reach out over the head as it goes down, so they lie flat before it on the ground
                slack.copy(crouch = 4.0, lean = 0.1, headDown = 2.0, rh = V(16.0, 112.0, 16.0), lh = V(-24.0, 112.0, 16.0), fallF = 82.0) to 6,
                slack.copy(crouch = 4.0, lean = 0.1, headDown = 2.0, rh = V(16.0, 114.0, 14.0), lh = V(-24.0, 114.0, 14.0), fallF = 86.0) to 1)),
            // thrown back by the blow: it staggers, then falls flat on its back, arms flung wide
            Seq(tween(r to 1, reel.copy(lean = -0.6, stride = -6.0) to 3, slack.copy(crouch = 6.0, lean = -0.5, stride = -7.0, headDown = -6.0, rh = V(26.0, 80.0, -4.0), lh = V(-26.0, 80.0, -4.0), fallF = -20.0) to 4,
                slack.copy(crouch = 3.0, lean = -0.2, stride = -4.0, headDown = -4.0, rh = V(30.0, 96.0, -2.0), lh = V(-30.0, 96.0, -2.0), fallF = -84.0) to 6,
                slack.copy(crouch = 3.0, lean = -0.2, stride = -4.0, headDown = -4.0, rh = V(30.0, 96.0, -2.0), lh = V(-30.0, 96.0, -2.0), fallF = -88.0) to 1)),
            // spun round, it sinks to one knee and topples over sideways
            Seq(tween(r to 1, reel.copy(twist = 30.0) to 3, slack.copy(crouch = 14.0, lean = 0.4, twist = 35.0, headTurn = 30.0, headDown = 6.0, rh = V(20.0, 46.0, 4.0), lh = V(-24.0, 46.0, 10.0), fallS = -10.0) to 4,
                slack.copy(crouch = 8.0, lean = 0.3, twist = 30.0, headTurn = 25.0, headDown = 4.0, rh = V(22.0, 56.0, 6.0), lh = V(-26.0, 56.0, 10.0), fallS = -80.0) to 6,
                slack.copy(crouch = 8.0, lean = 0.3, twist = 30.0, headTurn = 25.0, headDown = 4.0, rh = V(22.0, 56.0, 6.0), lh = V(-26.0, 56.0, 10.0), fallS = -84.0) to 1)),
        )
    }

    private fun idle(s: Style): Seq {
        val r = rest(s)
        val b = r.copy(bodyY = r.bodyY + 0.7, rh = r.rh + V(0.0, -0.6, 0.0), lh = r.lh + V(0.0, -0.6, 0.0))
        return Seq(List(HeroFigure.IDLE_FRAMES) { r.lerp(b, (1 - kotlin.math.cos(it / HeroFigure.IDLE_FRAMES.toDouble() * 2 * Math.PI)) / 2) })
    }

    private val seqs = java.util.concurrent.ConcurrentHashMap<String, Seq>()

    /** The frames of one act, turned to face the hero and in the kind's manner. */
    fun sequence(id: String, look: MonsterLook, act: Act, variant: Int): Seq {
        val s = style(id, look)
        val shield = hasShield(id, look)
        val kind = creature(id)
        val k = "$id/$s/$shield/$act/${variant.mod(3)}"
        return seqs.getOrPut(k) {
            val raw = when (act) {
                Act.IDLE, Act.HOWL -> idle(s)
                Act.ATTACK -> attacks(s)[variant.mod(3)]
                Act.HURT -> hurts(s)[variant.mod(3)]
                Act.DODGE -> dodges(s, shield)[variant.mod(3)]
                Act.DIE -> deaths(s)[variant.mod(3)]
            }
            Seq(raw.rigs.map { manner(kind, facing(it)) }, raw.strike)
        }
    }

    fun variants(act: Act): Int = if (act == Act.IDLE || act == Act.HOWL) 1 else 3

    // ---------------------------------------------------------------- the lunge

    /** Whether the foe steps in to strike: all but the archers, who shoot from where they stand. */
    fun lunges(id: String, look: MonsterLook) = style(id, look) != Style.BOW

    /** How much larger the foe is drawn at the end of its lunge: it comes nearer to us, towards the hero. */
    const val LUNGE_SCALE = 1.18

    private val tips = java.util.concurrent.ConcurrentHashMap<String, Pair<Double, Double>>()

    /** Where the weapon's point is in the frame at the moment the blow lands, in art pixels of the frame. */
    fun tip(id: String, look: MonsterLook, variant: Int): Pair<Double, Double> = tips.getOrPut("$id/${look.seed}/${variant.mod(3)}") {
        val seq = sequence(id, look, Act.ATTACK, variant)
        val rig = seq.rigs[seq.strike.coerceIn(0, seq.rigs.size - 1)]
        val doll = doll(id, look); val o = outfit(id, look)
        val img = doll.render(W, H, ANCHOR_X, GROUND, PX, rig, o)
        val sk = doll.fit(rig, o).first
        val base = o.base(GearSlot.MAIN_HAND)
        val reach = if (base == null) 0.0 else Dress.reach(base) * (if (base in Dress.ROUND) doll.height / 175.0 * 0.95 else 1.0)
        val (x, y, _) = img.project(sk.hand(1) + sk.weapon * reach)
        Pair(x, y)
    }

    /**
     * How far along its lunge the foe is at frame [index] of an attack: still at the start of the wind-up, stepping in
     * through it, all the way when the blow lands, and back through the follow-through.
     */
    fun lungeAt(id: String, look: MonsterLook, variant: Int, index: Int): Double {
        if (!lunges(id, look)) return 0.0
        val seq = sequence(id, look, Act.ATTACK, variant)
        val hit = seq.strike.coerceAtLeast(1)
        val n = seq.rigs.size
        fun smooth(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
        return if (index <= hit) smooth((index - hit * 0.3) / (hit * 0.7)) else 1 - smooth((index - hit).toDouble() / (n - 1 - hit).coerceAtLeast(1))
    }

    /**
     * The step for a blow, in art pixels: how far the feet move so that, drawn [LUNGE_SCALE] times as large, the weapon's
     * point lands on ([toX], [toY]) while the feet stood at ([feetX], [feetY]).
     */
    fun lungeOffset(id: String, look: MonsterLook, variant: Int, feetX: Double, feetY: Double, toX: Double, toY: Double): Pair<Double, Double> {
        val (tx, ty) = tip(id, look, variant)
        return Pair(toX - feetX - (tx - ANCHOR_X) * LUNGE_SCALE, toY - feetY - (ty - GROUND) * LUNGE_SCALE)
    }

    // ---------------------------------------------------------------- the frames, kept

    private val capacity: Int = (Runtime.getRuntime().maxMemory() / 10 / (W * H * 4L)).toInt().coerceIn(80, 400)
    private val cache = object : LinkedHashMap<String, PixelImage>(128, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > capacity
    }

    fun frame(id: String, look: MonsterLook, act: Act, variant: Int, index: Int): PixelImage {
        val seq = sequence(id, look, act, variant).rigs
        val i = if (act == Act.IDLE) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        val k = "$id/${look.seed}/${look.glow}/$act/${variant.mod(3)}/$i"
        synchronized(cache) { cache[k]?.let { return it } }
        val img = doll(id, look).render(W, H, ANCHOR_X, GROUND, PX, seq[i], outfit(id, look)).img
        synchronized(cache) { cache[k] = img }
        return img
    }

    /**
     * The frame if it is drawn already, else the nearest earlier one of the same act that is, else the first frame of
     * the guard (drawn now if need be, once): the battle never waits while frames are drawn in the background.
     */
    fun shown(id: String, look: MonsterLook, act: Act, variant: Int, index: Int): PixelImage {
        val seq = sequence(id, look, act, variant).rigs
        val i = if (act == Act.IDLE) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        synchronized(cache) {
            for (j in i downTo 0) cache["$id/${look.seed}/${look.glow}/$act/${variant.mod(3)}/$j"]?.let { return it }
            if (act != Act.IDLE) for (j in 0 until 16) cache["$id/${look.seed}/${look.glow}/${Act.IDLE}/0/$j"]?.let { return it }
        }
        return frame(id, look, Act.IDLE, 0, 0)
    }

    /** Draws every frame ahead, the rest first; off the main thread. */
    fun prepare(id: String, look: MonsterLook, cancelled: () -> Boolean = { false }) {
        for (act in listOf(Act.IDLE, Act.ATTACK, Act.HURT, Act.DODGE, Act.DIE)) for (v in 0 until variants(act))
            for (i in sequence(id, look, act, v).rigs.indices) { if (cancelled()) return; frame(id, look, act, v, i) }
    }
}
