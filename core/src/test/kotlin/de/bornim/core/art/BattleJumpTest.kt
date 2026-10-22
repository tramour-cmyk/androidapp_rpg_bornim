package de.bornim.core.art

import de.bornim.core.MonsterLook
import de.bornim.core.art.HeroFigure.Strike.*
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * Sprungtest im Kampf (12a). A battle move may be fast: a blow carries the hand far from one picture to the next, and
 * that is right. What jumps is something else, and three things are looked for:
 *
 * - a jolt inside a move: one picture changes a field far more than the pictures on either side of it do (the blow
 *   itself, the picture it lands on and the one after, is let be);
 * - too far in one picture, however fast the move: [CAP] times the limit on the map;
 * - the way in and out: from standing ready into the first picture of a move, and from its last picture back to
 *   standing ready (the battle goes straight from one to the other, without pictures between).
 *
 * For every foe in battle (the animals, the vermin, the foes on the doll) and the hero in every stance. Held to 0 since
 * 12a (10.10.). Let be on purpose (12c): the killing blow tearing at the body as a fall begins (the step into its
 * second picture, as the blow itself), and an animal leaping or a flyer dropping, which may carry the whole body up to
 * [LEAP] times the limit on the map in one picture.
 */
class BattleJumpTest {
    companion object {
        /** How many times the limit on the map one picture of a battle move may change a field. */
        const val CAP = 3.0
        /** A jolt: a change this many times larger than the larger one beside it... */
        const val JOLT = 2.5
        /** ...and larger than the limit on the map. */
        const val JOLT_MIN = 1.0
        /** Into a move and out of it: this many times the limit on the map. */
        const val EDGE = 1.5
        /** An animal's or a flyer's whole body in a leap or a drop: this many times the limit on the map. */
        const val LEAP = 4.5
        /** The fields that carry an animal's or a vermin's whole body. */
        private val BODY = setOf("fwd", "side", "hover")
        /** 19e: the fields of breathing while standing, let be on the way into a move from a later standing picture. */
        private val BREATH = setOf("breath", "hover")

        /** Fields that turn round and round, 0 to 1 (a leg's step). */
        private val PHASES = setOf("step")
        /** Fields of the battle rigs the map does not know: in degrees, in centimetres. */
        private val DEGREES = setOf("rear")
        private val CMS = setOf("hover", "cloak")

        private fun limit(name: String) = when (name) {
            in DEGREES -> JumpTest.DEG
            in CMS -> JumpTest.CM
            else -> JumpTest.limitOf(name)
        }

        /** Each field of [a] and [b] with how far it changed and the limit on the map ([JumpTest.compare] with no limit). */
        fun deltas(a: Any, b: Any): Map<String, Pair<Double, Double>> =
            JumpTest.measure(a, b).mapValues { (name, d) ->
                (if (name in PHASES) kotlin.math.min(d, 1.0 - d) else d) to limit(name)
            }
    }

    /**
     * One move: its pictures, the picture the blow lands on, the standing ready shown before it (not for
     * the opening of a battle, [noBefore]) and after it (not for a fall or a victory, which stay: [held]).
     */
    data class Move(val case: String, val rigs: List<Any>, val strike: Int = -1, val rest: List<Any> = emptyList(), val held: Boolean = false,
        val noBefore: Boolean = false, val leaps: Boolean = false, val falls: Boolean = false)

    private val look = MonsterLook(0)

    private fun foes(): List<Move> {
        val out = mutableListOf<Move>()
        for (id in BeastArt.KINDS.sorted()) {
            val idle = BeastArt.sequence(id, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until BeastArt.variants(act)) {
                if (act == Act.IDLE || act == Act.TROT || act == Act.COIL) continue
                val s = runCatching { BeastArt.sequence(id, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE, leaps = true, falls = act == Act.DIE)
            }
            out += Move("$id IDLE", idle + idle.first())
            // 249: the trot goes round like the guard, and sets out from it on its frame nearest the guard
            val trot = BeastArt.sequence(id, Act.TROT, 0).rigs
            out += Move("$id TROT", trot + trot.first())
            out += Move("$id TROT start", listOf(idle.first(), trot[BeastArt.TROT_START]))
            // Rückläufer t58: the coil breathes round, entered from the leap's coil frame and left into the leap
            val coil = BeastArt.sequence(id, Act.COIL, 0).rigs
            val leap = BeastArt.sequence(id, Act.ATTACK, 1).rigs
            out += Move("$id COIL", coil + coil.first())
            out += Move("$id COIL in/out", leap.take(BeastArt.COIL_FRAME + 1) + coil + coil.first() + leap.drop(BeastArt.COIL_FRAME + 1), leaps = true)
        }
        for (id in VerminArt.KINDS.sorted()) {
            val idle = VerminArt.sequence(id, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until VerminArt.variants(act)) {
                if (act == Act.IDLE || act == Act.TROT) continue
                val s = runCatching { VerminArt.sequence(id, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE, leaps = true, falls = act == Act.DIE)
            }
            out += Move("$id IDLE", idle + idle.first())
        }
        for (id in FoeArt.KINDS.sorted()) {
            val idle = FoeArt.sequence(id, look, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until FoeArt.variants(act)) {
                if (act == Act.IDLE || act == Act.TROT || act == Act.COIL && id in FoeArt.WIND_HOLDERS) continue
                val s = runCatching { FoeArt.sequence(id, look, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE, falls = act == Act.DIE)
            }
            // 310: up into the wind-up, held there breathing, then the blow from it or the axe lowered again
            if (id in FoeArt.WIND_HOLDERS) {
                val held = FoeArt.sequence(id, look, Act.COIL, 0).rigs
                val blow = FoeArt.sequence(id, look, Act.ATTACK, 1)
                val up = blow.rigs.take(FoeArt.WIND_HOLD + 1)
                out += Move("$id COIL", held + held.first(), rest = held)
                out += Move("$id COIL Hieb", up + held + held.first() + blow.rigs.drop(FoeArt.WIND_HOLD + 1), blow.strike + held.size + 1, idle)
                out += Move("$id COIL vereitelt", up + held + held.first() + up.reversed(), rest = idle)
            }
            out += Move("$id IDLE", idle + idle.first())
        }
        return out
    }

    /** The blows struck in each stance ([HeroFigure.strikes], [HeroFigure.killStrikes]). */
    private fun used(st: HeroFigure.Stance): List<HeroFigure.Strike> =
        when (st) {
            HeroFigure.Stance.BOW, HeroFigure.Stance.CROSSBOW -> listOf(SHOOT)
            HeroFigure.Stance.STAFF -> listOf(SMASH, SLASH, THRUST, KILL_HIGH, KILL_PIERCE)
            HeroFigure.Stance.SPEAR -> listOf(THRUST, SMASH, KILL_PIERCE, KILL_HIGH)
            HeroFigure.Stance.MELEE -> listOf(SLASH, THRUST, SMASH, KILL_HIGH, KILL_PIERCE, KILL_RISE, KILL_SPIN)
        }

    private fun hero(): List<Move> {
        val out = mutableListOf<Move>()
        for (st in HeroFigure.Stance.entries) {
            val idle = HeroFigure.sequence(HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, st)
            for (act in HeroFigure.Act.entries) {
                if (act == HeroFigure.Act.IDLE) continue
                val strikes = if (act == HeroFigure.Act.ATTACK) used(st) else listOf(HeroFigure.Strike.SLASH)
                for (s in strikes) {
                    val seen = mutableListOf<List<HeroFigure.Rig>>()
                    for (v in 0 until 8) {
                        val rigs = runCatching { HeroFigure.sequence(act, s, v, st) }.getOrNull() ?: continue
                        if (rigs.isEmpty() || seen.any { it === rigs || it == rigs }) continue
                        seen += rigs
                        val name = "Held $st $act" + (if (act == HeroFigure.Act.ATTACK) " $s" else "") + " $v"
                        val strike = if (act == HeroFigure.Act.ATTACK) HeroFigure.strikeFrame(s) else -1
                        // the battle opens with the hero facing us and turning to the foe (or set upon from behind):
                        // nothing comes before it (the walk in is not played)
                        // 249: getting up begins from kneeling, not from the stance; kneeling stays down until then
                        val opens = act == HeroFigure.Act.TURN || act == HeroFigure.Act.INTRO || act == HeroFigure.Act.AMBUSHED || act == HeroFigure.Act.RISE
                        out += Move(name, rigs, strike, idle, held = act == HeroFigure.Act.DIE || act == HeroFigure.Act.VICTORY || act == HeroFigure.Act.INTRO || act == HeroFigure.Act.KNEEL,
                            noBefore = opens, falls = act == HeroFigure.Act.DIE)
                    }
                }
            }
            out += Move("Held $st IDLE", idle + idle.first())
        }
        return out
    }

    /** Every jump of one move: [JumpTest.Jump] with the kind of jump in front of the field. */
    fun check(m: Move): List<JumpTest.Jump> {
        val out = mutableListOf<JumpTest.Jump>()
        val steps = (1 until m.rigs.size).map { deltas(m.rigs[it - 1], m.rigs[it]) }
        for ((i, d) in steps.withIndex()) {
            val at = "Bild $i → ${i + 1}"
            for ((f, p) in d) {
                val (delta, lim) = p
                val cap = if (m.leaps && f in BODY) LEAP else CAP
                if (delta > cap * lim + 1e-9) { out += JumpTest.Jump(m.case, at, "zu weit $f", delta, cap * lim); continue }
                // the blow: the picture it lands on and the one after may snap; and the killing blow tearing at a body
                if (m.strike >= 0 && i + 1 in m.strike..m.strike + 1) continue
                if (m.falls && i == 0) continue
                val beside = listOfNotNull(steps.getOrNull(i - 1)?.get(f)?.first, steps.getOrNull(i + 1)?.get(f)?.first).maxOrNull() ?: continue
                if (delta > JOLT_MIN * lim + 1e-9 && delta > JOLT * beside + 1e-9) out += JumpTest.Jump(m.case, at, "Ruck $f", delta, JOLT * beside)
            }
        }
        if (m.rest.isNotEmpty()) {
            fun edge(at: String, a: Any, b: Any, skip: Set<String> = emptySet()) {
                for ((f, p) in deltas(a, b)) if (f !in skip && p.first > EDGE * p.second + 1e-9) out += JumpTest.Jump(m.case, at, "Übergang $f", p.first, EDGE * p.second)
            }
            // 19e (Chef 20.10., 16:22 „1 und 3“): the breathing runs on until a move begins, so a move may begin at any
            // standing picture; after it the breathing begins again at the first (way out from there only). The breath
            // itself (an animal's chest, a flyer's rise and fall) is let be on the way in: no breathing back first (2: no)
            if (!m.noBefore) for ((k, r) in m.rest.withIndex()) edge("Bereit $k → Bild 0", r, m.rigs.first(), if (k == 0) emptySet() else BREATH)
            if (!m.held) edge("Bild ${m.rigs.size - 1} → Bereit", m.rigs.last(), m.rest.first())
        }
        return out
    }

    /** 249: getting up begins where kneeling ends, and the breath while kneeling runs round without a jump. */
    @Test
    fun kneelingFlowsIntoItsBreathAndUp() {
        for (st in HeroFigure.Stance.entries) for (v in 0..2) {
            val kn = HeroFigure.sequence(HeroFigure.Act.KNEEL, HeroFigure.Strike.SLASH, v, st)
            val up = HeroFigure.sequence(HeroFigure.Act.RISE, HeroFigure.Strike.SLASH, v, st)
            val from = deltas(kn.last(), up.first()).filter { (_, p) -> p.first > 1e-6 * maxOf(1.0, p.second) && p.first > 0.01 }
            assertTrue(from.isEmpty(), "$st $v: up from where it knelt $from")
            val loop = kn.takeLast(HeroFigure.KNEEL_BREATH)
            val jumps = deltas(loop.last(), loop.first()).filter { (_, p) -> p.first > EDGE * p.second + 1e-9 }
            assertTrue(jumps.isEmpty(), "$st $v: breath round $jumps")
        }
    }

    @Test
    fun battleMovesNeverJump() {
        val moves = foes() + hero()
        val all = moves.flatMap { check(it) }
        val byKind = all.groupingBy { it.field.substringBefore(' ') }.eachCount()
        println("KAMPF-SPRÜNGE: ${all.size} in ${moves.size} Bewegungen ($byKind)")
        all.groupingBy { it.case.substringBeforeLast(' ') }.eachCount().entries.sortedByDescending { it.value }.take(40)
            .forEach { (k, v) -> println("  $k: $v") }
        all.take(30).forEach { println("  $it") }
        System.getenv("SPRUNGLISTE")?.let { java.io.File(it).writeText(all.joinToString("\n")) }
        assertTrue(all.isEmpty(), "${all.size} Sprünge in Kampfbewegungen, zuerst: ${all.firstOrNull()}")
    }
}
