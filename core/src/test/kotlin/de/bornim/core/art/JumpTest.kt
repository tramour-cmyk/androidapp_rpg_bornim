package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * Sprungtest (12): finds jumps in movements and their changes, without drawing a picture. Every picture a figure shows
 * comes from a rig; this walks the rigs one shown picture after the next, in fine steps of time, and reports where a
 * joint, the look or the place moves further from one picture to the next than a limit allows. The goal is 0 reports,
 * as for the clashes.
 *
 * What is held to 0 (fails the build): the monsters on the map (9: walk, standing about with every stance going in and
 * out, walk to stand and back, the mates of a pack following a turning leader). What is only listed (printed, for the
 * one whose area it is): the folk standing on the map ([MapRest]) and the moves of the battle ([BeastArt], [FoeArt]).
 */
class JumpTest {
    /** One report: where, between which pictures, what moved and by how much against what limit. */
    data class Jump(val case: String, val at: String, val field: String, val delta: Double, val limit: Double) {
        override fun toString() = "$case  $at  $field: ${"%.1f".format(delta)} > ${"%.1f".format(limit)}"
    }

    companion object {
        /** Degrees an angle may turn from one picture to the next (a turn of the map figures goes in 22.5° steps). */
        const val DEG = 23.0
        /** Centimetres a body may move from one picture to the next. */
        const val CM = 6.0
        /** Centimetres a hand or a paw may move: a paw swinging forward in a walk is fast. */
        const val LIMB_CM = 16.0
        /** A share (0 to 1: jaw, lips, ears, a glow) may change by this much. */
        const val SHARE = 0.45
        /** A direction (a unit vector: where the weapon points) may change by this much. */
        const val DIR = 0.45

        private val ANGLES = setOf("yaw", "pitch", "neck", "nod", "turn", "tailSwing", "fallF", "fallS", "headTurn", "headDown",
            "twist", "grip", "roll", "bowTilt", "flaskTilt")
        private val LENGTHS = setOf("fwd", "crouch", "side", "bodyX", "bodyY", "stride", "spread")
        private val LIMBS = setOf("fl", "fr", "hl", "hr", "rh", "lh", "elbowAt")
        private val DIRS = setOf("weapon", "shieldFace", "rPole")
        /** Not a pose: which flame shape is drawn. */
        private val SKIP = setOf("flicker")

        private fun limit(name: String): Double = when (name) {
            in ANGLES -> DEG
            in LENGTHS -> CM
            in LIMBS -> LIMB_CM
            in DIRS -> DIR
            // a lean is a share of the body's tilt: 1 is a lot
            "lean" -> 0.35
            // a breath fills the chest by a few millimetres: half of it in one picture is still a soft rise
            "breath" -> 0.55
            else -> SHARE
        }

        /** Every field of two rigs of one kind (a data class: [Beast.Rig], [HeroFigure.Rig]) that moved too far. */
        fun compare(case: String, at: String, a: Any, b: Any): List<Jump> {
            val out = mutableListOf<Jump>()
            for (f in a.javaClass.declaredFields) {
                if (java.lang.reflect.Modifier.isStatic(f.modifiers) || f.name in SKIP) continue
                f.isAccessible = true
                val va = f.get(a); val vb = f.get(b)
                val d = when {
                    va is Double && vb is Double -> if (f.name in ANGLES) angle(va, vb) else kotlin.math.abs(va - vb)
                    va is HeroFigure.V && vb is HeroFigure.V -> kotlin.math.sqrt((va.r - vb.r).let { it * it } + (va.u - vb.u).let { it * it } + (va.f - vb.f).let { it * it })
                    else -> continue
                }
                val lim = limit(f.name)
                if (d > lim + 1e-9) out += Jump(case, at, f.name, d, lim)
            }
            return out
        }

        private fun angle(a: Double, b: Double) = kotlin.math.abs(((b - a) % 360.0 + 540.0) % 360.0 - 180.0)

        /** Compares each rig with the next one shown; [names] label the pictures. */
        fun <R : Any> stream(case: String, rigs: List<Pair<String, R>>): List<Jump> {
            val out = mutableListOf<Jump>()
            for (i in 1 until rigs.size) {
                val (na, a) = rigs[i - 1]; val (nb, b) = rigs[i]
                if (a == b) continue
                out += compare(case, "$na → $nb", a, b)
            }
            return out
        }
    }

    private val beasts = listOf("wolf", "dire_wolf")
    private val dolls = listOf("goblin", "goblin_archer")
    private val look = MonsterLook(0)

    /** The rig of the picture shown for [st] (as [MapFoe.idleNow] picks it). */
    private fun shown(id: String, yaw: Double, st: MapFoe.Stance): Any =
        if (id in BeastArt.KINDS) MapFoe.beastIdleRig(id, yaw, st.idle, st.breath, if (st.idle == MapFoe.Idle.STAND) MapFoe.LEVELS else st.level)
        else MapFoe.dollIdleRig(id, look, yaw, st.idle, st.breath, if (st.idle == MapFoe.Idle.STAND) MapFoe.LEVELS else st.level)

    private fun walk(id: String, yaw: Double, step: Int): Any =
        if (id in BeastArt.KINDS) MapFoe.beastRig(id, yaw, step) else MapFoe.dollRig(id, look, yaw, step)

    /** All jumps of the monsters on the map. */
    fun monsters(): List<Jump> {
        val out = mutableListOf<Jump>()
        for (id in beasts + dolls) {
            // the walk, round and round
            out += stream("$id Gehen", (0..MapFoe.STEPS).map { "Schritt ${it % MapFoe.STEPS}" to walk(id, 90.0, it % MapFoe.STEPS) })
            // standing about, a minute in steps of 20 ms, for a few of them
            for (seed in listOf(1, 7, 42, 99, 1234)) {
                val rigs = (0L until 60_000L step 20L).map { t -> MapFoe.idleAt(id, seed, t).let { "${t}ms ${it.idle}/${it.level}/${it.breath}" to shown(id, 90.0, it) } }
                out += stream("$id Stehen (seed $seed)", rigs)
            }
            // every stance going in and out
            for (idle in MapFoe.Idle.entries) {
                val levels = (0..MapFoe.LEVELS) + (MapFoe.LEVELS - 1 downTo 0)
                out += stream("$id $idle hinein und heraus", levels.map { "Stufe $it" to shown(id, 90.0, MapFoe.Stance(if (it == 0) MapFoe.Idle.STAND else idle, 0, it)) })
            }
            // a walk ends on its last step and the monster stands; it sets off again from standing
            val stand = shown(id, 90.0, MapFoe.Stance(MapFoe.Idle.STAND, 0))
            out += compare("$id Gehen → Stehen", "Schritt ${MapFoe.STEPS - 1} → Stehen", walk(id, 90.0, MapFoe.STEPS - 1), stand)
            out += compare("$id Stehen → Gehen", "Stehen → Schritt 0", stand, walk(id, 90.0, 0))
        }
        return out
    }

    /**
     * A pack following its leader (9g): the leader walks, turns about and walks back; each frame of 16 ms the mate
     * may move no further than its pace allows and turn no faster than the others; no swinging round the leader.
     */
    fun pack(): List<Jump> {
        MapFollow.reset()
        val out = mutableListOf<Jump>()
        val t = WorldArt.T
        val speed = t * 1.4 / 480.0
        var lx = 10.0 * t; val ly = 10.0 * t
        var yaw = 90.0
        var px = 0.0; var py = 0.0; var pyaw = 0.0
        for (frame in 0 until 600) {
            val now = 1_000L + frame * 16L
            // walks right for 3 s, turns about in a quarter second, walks back
            if (frame in 190..205) yaw = 90.0 + (frame - 190) * 12.0
            lx += (if (yaw < 180) 1 else -1) * t / 480.0 * 16
            for (i in 0 until 2) {
                val (tx, ty) = MapFollow.place(lx.toInt(), ly.toInt(), yaw, 24.0, 10.0, if (i == 0) -1 else 1)
                val f = MapFollow.update("test:$i", tx, ty, speed, now, yaw)
                if (frame > 0 && i == 0) {
                    val moved = kotlin.math.hypot(f.x - px, f.y - py)
                    if (moved > speed * 16 + 0.01) out += Jump("Rudel folgt", "Bild $frame", "Weg (Pixel)", moved, speed * 16)
                    val turned = kotlin.math.abs(((f.yaw - pyaw) % 360.0 + 540.0) % 360.0 - 180.0)
                    if (turned > MapFollow.TURN_PER_MS * 16 + 0.01) out += Jump("Rudel folgt", "Bild $frame", "Drehung (Grad)", turned, MapFollow.TURN_PER_MS * 16)
                }
                if (i == 0) { px = f.x; py = f.y; pyaw = f.yaw }
            }
        }
        return out
    }

    @Test
    fun monstersOnTheMapNeverJump() {
        val all = monsters() + pack()
        all.groupingBy { "${it.case.substringBefore(" (")} ${it.field}" }.eachCount().forEach { (k, v) -> println("SPRUNG  $k: $v") }
        all.distinctBy { "${it.case.substringBefore(" (")} ${it.field}" }.take(40).forEach { println("SPRUNG  $it") }
        assertTrue(all.isEmpty(), "${all.size} Sprünge bei den Monstern auf der Karte, zuerst: ${all.firstOrNull()}")
    }

    /** Strict since 12b (Tom, 10.10.): the hero and the folk on the map, standing ([MapRest]) and walking ([MapFigure]). */
    fun folk(): List<Jump> {
        val out = mutableListOf<Jump>()
        // folk standing about: a minute in steps of 20 ms, the stances gone into and out of through in-between pictures
        val base = MapFigure.rig(0.0, 0, MapFigure.Carry.FREE)
        for (seed in listOf(7, 42, 1234)) {
            val rigs = (0L until 60_000L step 20L).map { t -> MapRest.pose(seed, t, handsFree = true, mayLook = true).let { p -> "${t}ms ${p.rest}/${p.breath}/${p.level}" to MapRest.rig(base, p.rest, p.breath, p.level) } }
            out += stream("Leute Stehen (seed $seed)", rigs)
        }
        // the hero and the folk walking on the map, in every way of carrying
        for (c in MapFigure.Carry.entries)
            out += stream("Held Gehen $c", (0..MapFigure.STEPS).map { "Schritt ${it % MapFigure.STEPS}" to MapFigure.rig(90.0, it % MapFigure.STEPS, c) })
        return out
    }

    @Test
    fun folkOnTheMapNeverJump() {
        val all = folk()
        all.distinctBy { "${it.case.substringBefore(" (")} ${it.field}" }.take(20).forEach { println("SPRUNG  $it") }
        assertTrue(all.isEmpty(), "${all.size} Sprünge bei Held und Leuten auf der Karte, zuerst: ${all.firstOrNull()}")
    }

    /** Listed only: the battle moves; for the one whose area it is. */
    @Test
    fun listOthers() {
        val out = mutableListOf<Jump>()
        // the battle moves, picture by picture, of the animals and the foes on the doll
        for (id in listOf("wolf", "boar", "giant_rat")) for (act in Act.entries) for (v in 0 until BeastArt.variants(act)) {
            val seq = runCatching { BeastArt.sequence(id, act, v) }.getOrNull() ?: continue
            out += stream("Kampf $id $act $v", seq.rigs.mapIndexed { i, r -> "Bild $i" to r })
        }
        val counts = out.groupingBy { it.case.substringBefore(" (") }.eachCount()
        println("SPRUNG-LISTE (nur gemeldet): ${out.size} Sprünge")
        counts.forEach { (k, v) -> println("  $k: $v") }
        out.take(30).forEach { println("  $it") }
        System.getenv("SPRUNGLISTE")?.let { java.io.File(it).writeText(out.joinToString("\n")) }
    }
}
