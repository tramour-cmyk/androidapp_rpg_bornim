package de.bornim.core.art

import de.bornim.core.GearSlot
import de.bornim.core.MonsterKits
import de.bornim.core.MonsterLook
import de.bornim.core.art.HeroFigure.V
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * Monsters on the map built from their battle models (10.10., 9, draft): seen at a slant from above at the same
 * scale and angle as the hero's doll ([MapFigure]), in [YAWS] directions, each with [STEPS] pictures of a walk.
 * Four-legged animals ([BeastArt]) walk with their legs one after another, the hind leg leading the front one on
 * the same side; foes on the doll ([FoeArt]) walk stooped in their own manner with the weapon in hand.
 *
 * Pictures are [W] × [H] art pixels at density 2, the feet (for an animal: the middle of the body) at
 * ([ANCHOR_X], [GROUND]). Not yet used in the game.
 */
object MapFoe {
    const val W = 150
    const val H = 150
    const val ANCHOR_X = 75
    const val GROUND = 110

    const val YAWS = MapFigure.YAWS
    /** Pictures of a walk, one full cycle of all four legs. */
    const val STEPS = 8

    /** Art pixels per centimetre and the angle from above, as for the hero. */
    private const val PX = 0.55
    private const val PITCH = 38.0

    // ---------------------------------------------------------------- animals

    /**
     * An animal on the prowl: the head carried low and forward, ears up, the lips just off the fangs, the tail low.
     * Hungry, not yet attacking.
     */
    private val PROWL = Beast.Rig(neck = -14.0, nod = 6.0, mouth = 0.12, snarl = 0.35, ears = 0.4, tail = -0.35)

    /**
     * The walk: each paw is on the ground three quarters of the cycle, sliding back under the body, and swings
     * forward in the last quarter, lifted. The order is hind left, front left, hind right, front right, a quarter
     * apart, as a dog or wolf walks. [stride] is the reach of one paw forward and back in cm.
     */
    private fun paw(phase: Double, stride: Double, lift: Double): V {
        val p = ((phase % 1.0) + 1.0) % 1.0
        return if (p < 0.75) {
            // on the ground: from forward to back
            V(0.0, 0.0, stride * (1 - 2 * p / 0.75))
        } else {
            // in the air: back to forward, lifted in an arc
            val t = (p - 0.75) / 0.25
            V(0.0, lift * sin(t * PI), stride * (-1 + 2 * (1 - cos(t * PI)) / 2))
        }
    }

    /** The walking animal at [step] of [STEPS], facing [yaw]. */
    fun beastRig(id: String, yaw: Double, step: Int): Beast.Rig {
        val t = Math.floorMod(step, STEPS) / STEPS.toDouble()
        val (stride, lift) = when (BeastArt.kindOf(id)) {
            Beast.Kind.WOLF -> 13.0 to 9.0
            Beast.Kind.BOAR -> 9.0 to 6.0
            Beast.Kind.RAT -> 6.0 to 4.0
        }
        // the body sinks a little twice a cycle, as each pair of legs takes the weight, and the head bobs with it
        val bob = cos(t * 4 * PI)
        return PROWL.copy(
            yaw = yaw,
            hl = paw(t, stride, lift), fl = paw(t - 0.25, stride, lift),
            hr = paw(t - 0.5, stride, lift), fr = paw(t - 0.75, stride, lift),
            crouch = 0.8 + 0.8 * bob, nod = PROWL.nod - 2.0 * bob,
            tailSwing = 10.0 * sin(t * 2 * PI), turn = 3.0 * sin(t * 2 * PI),
        )
    }

    /** One picture of a walking animal. */
    fun beast(id: String, look: MonsterLook, slot: Int, step: Int): PixelImage =
        BeastArt.beast(id, look).render(W, H, ANCHOR_X.toDouble(), GROUND.toDouble(), PX, beastRig(id, yawOf(slot), step), pitch = PITCH)

    // ---------------------------------------------------------------- foes on the doll

    /** The walk of the hero, stooped in the manner of the foe's kind: a goblin hunched with its knees bent. */
    fun dollRig(id: String, look: MonsterLook, yaw: Double, step: Int): HeroFigure.Rig {
        val kit = MonsterKits.of(id, look.seed)!!
        val ranged = kit.items[GearSlot.MAIN_HAND] == "shortbow"
        val base = MapFigure.rig(yaw, step * MapFigure.STEPS / STEPS, if (ranged) MapFigure.Carry.SHOULDER else MapFigure.Carry.LOW)
        val r = when (FoeArt.creature(id)) {
            Doll.Creature.GOBLIN -> base.copy(lean = base.lean + 0.35, crouch = base.crouch + 4.0, headDown = base.headDown - 2.5)
            else -> base
        }
        // a second blade in the other hand, held low and forward like the first
        return if (kit.items[GearSlot.OFF_HAND] == "dagger") r.copy(lh = V(-18.0, 62.0, 12.0 + (r.lh.f - 3.0))) else r
    }

    /** One picture of a walking foe on the doll, its shield on the arm. */
    fun doll(id: String, look: MonsterLook, slot: Int, step: Int): PixelImage =
        FoeArt.doll(id, look).render(W, H, ANCHOR_X.toDouble(), GROUND.toDouble(), PX, dollRig(id, look, yawOf(slot), step), FoeArt.outfit(id, look), pitch = PITCH).img

    // ---------------------------------------------------------------- both

    fun yawOf(slot: Int) = slot * 360.0 / YAWS

    /** Whether [id] is drawn as an animal ([BeastArt]) or on the doll ([FoeArt]) on the map. */
    fun drawn(id: String) = id in BeastArt.KINDS || id in FoeArt.KINDS

    /** One picture of [id] turned to [slot], at [step] of its walk. */
    fun draw(id: String, look: MonsterLook, slot: Int, step: Int): PixelImage =
        if (id in BeastArt.KINDS) beast(id, look, slot, step) else doll(id, look, slot, step)
}
