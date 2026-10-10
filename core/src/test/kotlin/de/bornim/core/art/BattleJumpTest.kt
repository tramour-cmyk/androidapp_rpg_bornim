package de.bornim.core.art

import de.bornim.core.MonsterLook
import de.bornim.core.art.HeroFigure.Strike.*
import kotlin.test.Test

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
 * For every foe in battle (the animals, the vermin, the foes on the doll) and the hero in every stance.
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
        val noBefore: Boolean = false)

    private val look = MonsterLook(0)

    private fun foes(): List<Move> {
        val out = mutableListOf<Move>()
        for (id in BeastArt.KINDS.sorted()) {
            val idle = BeastArt.sequence(id, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until BeastArt.variants(act)) {
                if (act == Act.IDLE) continue
                val s = runCatching { BeastArt.sequence(id, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE)
            }
            out += Move("$id IDLE", idle + idle.first())
        }
        for (id in VerminArt.KINDS.sorted()) {
            val idle = VerminArt.sequence(id, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until VerminArt.variants(act)) {
                if (act == Act.IDLE) continue
                val s = runCatching { VerminArt.sequence(id, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE)
            }
            out += Move("$id IDLE", idle + idle.first())
        }
        for (id in FoeArt.KINDS.sorted()) {
            val idle = FoeArt.sequence(id, look, Act.IDLE, 0).rigs
            for (act in Act.entries) for (v in 0 until FoeArt.variants(act)) {
                if (act == Act.IDLE) continue
                val s = runCatching { FoeArt.sequence(id, look, act, v) }.getOrNull() ?: continue
                out += Move("$id $act $v", s.rigs, if (act == Act.ATTACK) s.strike else -1, idle, held = act == Act.DIE)
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
                        val opens = act == HeroFigure.Act.TURN || act == HeroFigure.Act.INTRO || act == HeroFigure.Act.AMBUSHED
                        out += Move(name, rigs, strike, idle, held = act == HeroFigure.Act.DIE || act == HeroFigure.Act.VICTORY || act == HeroFigure.Act.INTRO,
                            noBefore = opens)
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
                if (delta > CAP * lim + 1e-9) { out += JumpTest.Jump(m.case, at, "zu weit $f", delta, CAP * lim); continue }
                // the blow: the picture it lands on and the one after may snap
                if (m.strike >= 0 && i + 1 in m.strike..m.strike + 1) continue
                val beside = listOfNotNull(steps.getOrNull(i - 1)?.get(f)?.first, steps.getOrNull(i + 1)?.get(f)?.first).maxOrNull() ?: continue
                if (delta > JOLT_MIN * lim + 1e-9 && delta > JOLT * beside + 1e-9) out += JumpTest.Jump(m.case, at, "Ruck $f", delta, JOLT * beside)
            }
        }
        if (m.rest.isNotEmpty()) {
            fun edge(at: String, a: Any, b: Any) {
                for ((f, p) in deltas(a, b)) if (p.first > EDGE * p.second + 1e-9) out += JumpTest.Jump(m.case, at, "Übergang $f", p.first, EDGE * p.second)
            }
            if (!m.noBefore) edge("Bereit → Bild 0", m.rest.first(), m.rigs.first())
            if (!m.held) edge("Bild ${m.rigs.size - 1} → Bereit", m.rigs.last(), m.rest.first())
        }
        return out
    }

    @Test
    fun listBattle() {
        val moves = foes() + hero()
        val all = moves.flatMap { check(it) }
        val byKind = all.groupingBy { it.field.substringBefore(' ') }.eachCount()
        println("KAMPF-SPRÜNGE: ${all.size} in ${moves.size} Bewegungen ($byKind)")
        all.groupingBy { it.case.substringBeforeLast(' ') }.eachCount().entries.sortedByDescending { it.value }.take(40)
            .forEach { (k, v) -> println("  $k: $v") }
        System.getenv("SPRUNGLISTE")?.let { java.io.File(it).writeText(all.joinToString("\n")) }
    }
}
