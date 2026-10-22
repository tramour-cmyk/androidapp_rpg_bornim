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
 * Held to 0 (fails the build): the monsters on the map (9: walk, standing about with every stance going in and out,
 * walk to stand and back, the mates of a pack following a turning leader) and, since 12b, the hero and the folk on the
 * map. The moves of the battle are fast and checked with limits of their own in [BattleJumpTest] (12a; 12.3c).
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
            "twist", "grip", "roll", "bowTilt", "flaskTilt", "rear")
        private val LENGTHS = setOf("fwd", "crouch", "side", "bodyX", "bodyY", "stride", "spread", "hover")
        /** A phase going round, 0 to 1 (the vermin's legs stepping): from 0.9 to 0 is a tenth, not nine. */
        private val PHASES = setOf("step")
        private val LIMBS = setOf("fl", "fr", "hl", "hr", "rh", "lh", "elbowAt", "footL", "footR")
        private val DIRS = setOf("weapon", "shieldFace", "rPole")
        /** Not a pose: which flame shape is drawn. */
        private val SKIP = setOf("flicker")

        /** The limit on the map of one field, by its name. */
        fun limitOf(name: String): Double = when (name) {
            in ANGLES -> DEG
            in LENGTHS -> CM
            in LIMBS -> LIMB_CM
            in DIRS -> DIR
            // a lean is a share of the body's tilt: 1 is a lot
            "lean" -> 0.35
            // a breath fills the chest by a few millimetres: half of it in one picture is still a soft rise
            "breath" -> 0.55
            // a wing beats fast, as a paw swings in a walk: down to level in one picture
            "beat" -> 0.65
            // 245.1: whether the feet follow footL/footR; where they are is checked there, so the switch itself is no jump
            "gait" -> 1.0
            else -> SHARE
        }

        /** How far each field of two rigs of one kind (a data class: [Beast.Rig], [HeroFigure.Rig]) moved. */
        fun measure(a: Any, b: Any): Map<String, Double> {
            val out = linkedMapOf<String, Double>()
            for (f in a.javaClass.declaredFields) {
                if (java.lang.reflect.Modifier.isStatic(f.modifiers) || f.name in SKIP) continue
                f.isAccessible = true
                val va = f.get(a); val vb = f.get(b)
                out[f.name] = when {
                    va is Double && vb is Double -> when (f.name) {
                        in ANGLES -> angle(va, vb)
                        in PHASES -> kotlin.math.abs(va - vb).mod(1.0).let { minOf(it, 1 - it) }
                        else -> kotlin.math.abs(va - vb)
                    }
                    va is HeroFigure.V && vb is HeroFigure.V -> kotlin.math.sqrt((va.r - vb.r).let { it * it } + (va.u - vb.u).let { it * it } + (va.f - vb.f).let { it * it })
                    else -> continue
                }
            }
            return out
        }

        /** Every field of two rigs of one kind that moved too far. */
        fun compare(case: String, at: String, a: Any, b: Any): List<Jump> =
            measure(a, b).mapNotNull { (name, d) -> limitOf(name).let { lim -> if (d > lim + 1e-9) Jump(case, at, name, d, lim) else null } }

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

    private val beasts = listOf("wolf", "dire_wolf", "boar", "giant_rat")
    private val dolls = listOf("goblin", "goblin_archer", "kobold", "skeleton", "zombie", "ghoul", "goblin_shaman", "bugbear", "hobgoblin_captain")
    private val look = MonsterLook(0)

    private val vermin = VerminArt.KINDS.sorted()

    /** The rig of the picture shown for [st] (as [MapFoe.idleNow] picks it; a flyer's standing is its wingbeat). */
    private fun shown(id: String, yaw: Double, st: MapFoe.Stance): Any =
        if (MapFoe.flies(id)) MapFoe.verminRig(id, yaw, st.breath)
        else if (id in VerminArt.KINDS) MapFoe.verminIdleRig(id, yaw, st.idle, st.breath, if (st.idle == MapFoe.Idle.STAND) MapFoe.LEVELS else st.level)
        else if (id in BeastArt.KINDS) MapFoe.beastIdleRig(id, yaw, st.idle, st.breath, if (st.idle == MapFoe.Idle.STAND) MapFoe.LEVELS else st.level)
        else MapFoe.dollIdleRig(id, look, yaw, st.idle, st.breath, if (st.idle == MapFoe.Idle.STAND) MapFoe.LEVELS else st.level)

    private fun walk(id: String, yaw: Double, step: Int): Any =
        if (id in VerminArt.KINDS) MapFoe.verminRig(id, yaw, step)
        else if (id in BeastArt.KINDS) MapFoe.beastRig(id, yaw, step) else MapFoe.dollRig(id, look, yaw, step)

    /** All jumps of the monsters on the map. */
    fun monsters(): List<Jump> {
        val out = mutableListOf<Jump>()
        for (id in beasts + dolls + vermin) {
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
        // 55.1 (draft): with the arms crossed and the hands behind the back as well
        val was = MapRest.draft
        MapRest.draft = true
        try {
            for (seed in listOf(7, 42, 1234, 99)) {
                val rigs = (0L until 120_000L step 20L).map { t -> MapRest.pose(seed, t, handsFree = true, mayLook = true).let { p -> "${t}ms ${p.rest}/${p.breath}/${p.level}" to MapRest.rig(base, p.rest, p.breath, p.level) } }
                out += stream("Leute Stehen 55.1 (seed $seed)", rigs)
            }
            // 55.1b (draft): a spear on the shoulder grounded and leaned on, and shouldered again
            val shoulder = MapFigure.rig(0.0, 0, MapFigure.Carry.SHOULDER)
            for (seed in listOf(7, 42, 1234, 99)) {
                val rigs = (0L until 120_000L step 20L).map { t -> MapRest.pose(seed, t, handsFree = false, mayLook = true, spear = true).let { p -> "${t}ms ${p.rest}/${p.breath}/${p.level}" to MapRest.rig(shoulder, p.rest, p.breath, p.level) } }
                out += stream("Wache Speer 55.1b (seed $seed)", rigs)
            }
        } finally { MapRest.draft = was }
        // Borin at his table (55.2): ten minutes in steps of 20 ms, the poses gone into and out of through in-between pictures
        out += stream("Borin Sitzen", (0L until 600_000L step 20L).map { t -> MapFolk.seatPoseAt(MapFolk.borin, t).let { p -> "${t}ms $p" to MapFolk.seatRig(0.0, p) } })
        // 239 (Chef 20.10.: "Animationsübergang bei Garrick sitzen/stehen sehr unrund"): Garrick down at his fire and up
        // again, by day and by night, ten minutes in steps of 20 ms
        val garrick = MapFolk.of("garrick")!!
        // the stick for the embers is picked up and laid down between two pictures: not a jump of the body
        val stick = setOf("torch", "grip", "weapon", "aim")
        fun squatting(case: String, poses: List<Pair<Long, MapFolk.SquatPose?>>) = stream(case, poses.map { (t, p) ->
            (p ?: MapFolk.SquatPose(null, null, 0)).let { q -> "${t}ms $q" to MapFolk.squatRig(0.0, q) } }).filter { it.field !in stick }
        for (night in listOf(false, true)) {
            out += squatting("Garrick Hocken ${if (night) "nachts" else "tags"}", (0L until 600_000L step 20L).map { t -> t to MapFolk.squatPoseAt(garrick, t, night) })
            // the hero comes and goes at all kinds of moments: he starts up from where he is and does not drop back into it
            for (period in listOf(7_300L, 13_100L, 29_700L)) {
                val gate = MapFolk.SquatGate()
                out += squatting("Garrick aufgeschreckt ${if (night) "nachts" else "tags"} ($period)", (0L until 600_000L step 20L).map { t ->
                    t to gate.at(garrick, t, night, roused = t % period < period / 3) })
            }
        }
        // 239: the loops of Garrick (warming his hands, peering) and Rowena (wiping, pouring), from standing into them and out
        for (f in listOf("garrick", "rowena").map { MapFolk.of(it)!! }) {
            val stand = MapFigure.rig(0.0, 0, f.carry)
            out += stream("Schleifen ${f.id}", (0L until 600_000L step 20L).map { t ->
                MapFolk.doing(f, t).let { d -> "${t}ms ${d?.idle}/${d?.frame}/${d?.level}" to (d?.let { MapFolk.idleInRig(f, 0.0, it.idle, it.frame, it.level) } ?: stand) } })
                .filter { it.field !in setOf("flask", "cork") } // the jug taken up and put down: not a jump of the body
        }
        // 134.2: each one's gesture with the golden sign, in steps of 20 ms, from standing (or sitting) to standing again;
        // Rowena's jug comes into her hand with it, as in her pouring
        for (f in listOf("aldric", "rowena", "borin", "osric", "gwenna", "pim", "thessa", "jorin", "morwen", "lyra", "garrick", "liska", "bram").map { MapFolk.of(it)!! }) {
            val still = if (MapFolk.sits(f)) MapFolk.seatRig(0.0, MapFolk.Seat.REST) else MapFigure.rig(0.0, 0, f.carry)
            val rest = MapFolk.GesturePose(MapFolk.GPose.REST, MapFolk.GPose.REST, 0)
            val moves = (0L..MapFolk.gestureMs(MapFolk.gesture(f)) step 20L).map { t -> (MapFolk.gestureAt(f, t) ?: rest).let { p -> "${t}ms $p" to MapFolk.gestureRig(f, 0.0, p) } }
            out += stream("Geste ${f.id}", (if (MapFolk.gesture(f) == MapFolk.Gesture.JUG) emptyList() else listOf("davor" to still)) + moves + listOf("danach" to (if (MapFolk.gesture(f) == MapFolk.Gesture.JUG) moves.first().second else still)))
        }
        // 17 (draft): the cloak swinging on after a stop, in steps of 20 ms, from the standing picture to the standing picture
        for (c in MapFigure.Carry.entries)
            out += stream("Held Nachschwingen $c", (0L..MapFigure.SWING_MS step 20L).map { t -> MapFigure.swingLevel(t).let { "${t}ms $it" to MapFigure.swingRig(4, it, c) } })
        // the hero and the folk walking on the map, in every way of carrying
        for (c in MapFigure.Carry.entries)
            out += stream("Held Gehen $c", (0..MapFigure.STEPS).map { "Schritt ${it % MapFigure.STEPS}" to MapFigure.rig(90.0, it % MapFigure.STEPS, c, moving = true) })
        // 245: running, in its own pictures, and from standing into a walk
        for (c in MapFigure.Carry.entries)
            out += stream("Held Rennen $c", (0..MapFigure.RUN_STEPS).map { "Schritt ${it % MapFigure.RUN_STEPS}" to MapFigure.rig(90.0, it % MapFigure.RUN_STEPS, c, moving = true, run = 1.0) })
        for (c in MapFigure.Carry.entries)
            out += stream("Held los $c", listOf("steht" to MapFigure.rig(90.0, 0, c), "geht" to MapFigure.rig(90.0, 0, c, moving = true), "rennt" to MapFigure.rig(90.0, 0, c, moving = true, run = 1.0)))
        return out
    }

    @Test
    fun folkOnTheMapNeverJump() {
        val all = folk()
        all.distinctBy { "${it.case.substringBefore(" (")} ${it.field}" }.take(20).forEach { println("SPRUNG  $it") }
        assertTrue(all.isEmpty(), "${all.size} Sprünge bei Held und Leuten auf der Karte, zuerst: ${all.firstOrNull()}")
    }

    /**
     * 294 (Chef 22.10.: "dass bitte alle Animationen weich sein sollen"): the animals living on the map, the dog and the
     * hens in the village and the cat in the inn, as they are shown, in steps of 20 ms: their poses, their turning and their place.
     * A pose's lengths are in cm ([CM]), its angles in degrees ([DEG]), the rest shares ([SHARE]).
     */
    fun animals(): List<Jump> {
        val out = mutableListOf<Jump>()
        val angles = setOf("nod", "wag", "tilt")
        val shares = setOf("tuck", "curl", "tailUp", "tailWrap", "eyes", "scratch", "wing")
        fun poses(case: String, rigs: List<Triple<String, Any, Triple<Double, Double, Double>>>) {
            for (i in 1 until rigs.size) {
                val (na, a, pa) = rigs[i - 1]; val (nb, b, pb) = rigs[i]
                val at = "$na → $nb"
                for (f in a.javaClass.declaredFields) {
                    if (java.lang.reflect.Modifier.isStatic(f.modifiers)) continue
                    f.isAccessible = true
                    val va = f.get(a) as? Double ?: continue; val vb = f.get(b) as Double
                    val lim = when (f.name) { in angles -> DEG; in shares -> SHARE; else -> CM }
                    val d = if (f.name in angles) angle(va, vb) else kotlin.math.abs(va - vb)
                    if (d > lim + 1e-9) out += Jump(case, at, f.name, d, lim)
                }
                if (angle(pa.third, pb.third) > DEG) out += Jump(case, at, "yaw", angle(pa.third, pb.third), DEG)
                // a trot of 1.6 tiles a second goes 0.03 tiles in 20 ms
                val moved = kotlin.math.hypot(pb.first - pa.first, pb.second - pa.second)
                if (moved > 0.1) out += Jump(case, at, "Weg (Felder)", moved, 0.1)
            }
        }
        poses("Hund", (0L until 400_000L step 20L).map { t -> MapDog.at(t).let { a -> Triple("${t}ms ${a.key} ${a.k}", MapDog.poseOf(a.key, a.k), Triple(a.x, a.y, a.yaw)) } })
        poses("Katze", (0L until 400_000L step 20L).map { t -> MapCat.at(t).let { a -> Triple("${t}ms ${a.key} ${a.k}", MapCat.poseOf(a.key, a.k), Triple(a.x, a.y, a.yaw)) } })
        // the hens by the bales, alone for ten minutes (running off from the hero: [MapHenTest])
        val village = de.bornim.core.World["village"]
        for ((i, h) in MapHen.of(village).map { MapHen.Hen(it.homeX, it.homeY, it.seed, it.variant) }.withIndex())
            poses("Huhn $i", (0L until 600_000L step 20L).map { t -> h.at(t, 0f, 0f, village).let { a ->
                Triple("${t}ms ${a.key} ${a.k}", MapHen.poseOf(a.key, a.k), Triple(a.x.toDouble() / WorldArt.T, a.y.toDouble() / WorldArt.T, a.yaw)) } })
        return out
    }

    @Test
    fun animalsOnTheMapNeverJump() {
        val all = animals()
        all.distinctBy { "${it.case} ${it.field}" }.take(20).forEach { println("SPRUNG  $it") }
        assertTrue(all.isEmpty(), "${all.size} Sprünge bei den Tieren auf der Karte, zuerst: ${all.firstOrNull()}")
    }

    /**
     * 294: every figure that moves through poses or rigs is in a Sprungtest. A new figure with its own `Pose` or `Rig`
     * and no line here makes this fail, so nothing gets onto the map unchecked.
     */
    @Test
    fun everyFigureIsInASprungtest() {
        val checked = mapOf(
            "Beast" to "monstersOnTheMapNeverJump, BattleJumpTest",
            "Vermin" to "monstersOnTheMapNeverJump, BattleJumpTest",
            "WolfArt" to "BattleJumpTest (die Tiere im Kampf über BeastArt)",
            "HeroFigure" to "folkOnTheMapNeverJump, BattleJumpTest",
            "MapRest" to "folkOnTheMapNeverJump",
            "MapDog" to "animalsOnTheMapNeverJump",
            "MapCat" to "animalsOnTheMapNeverJump",
            "MapHen" to "animalsOnTheMapNeverJump, MapHenTest",
            // not a figure: the pieces a killing blow throws, and a drawing helper of the old monster pictures
            "KillArt" to "-", "MonsterArt" to "-",
        )
        val dir = java.io.File(MapDog::class.java.protectionDomain.codeSource.location.toURI()).resolve("de/bornim/core/art")
        val found = dir.list()!!.mapNotNull { Regex("""^(\w+)\$(Pose|Rig)\.class$""").find(it)?.groupValues?.get(1) }.toSet()
        assertTrue(found.isNotEmpty(), "keine Figuren gefunden in $dir")
        val missing = found - checked.keys
        assertTrue(missing.isEmpty(), "Figuren ohne Sprungtest: $missing (in JumpTest aufnehmen, 294)")
    }
}
