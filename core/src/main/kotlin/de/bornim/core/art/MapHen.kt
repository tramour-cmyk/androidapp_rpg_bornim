package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

/**
 * The village hens (83b, Nutzer 14.10.): small figures on the ground by the hay bales, built in the round like
 * the cat ([MapCat]), in cm (y up, z forward), a little larger than life. They peck, scratch, look up, stroll
 * to a new spot, and run off flapping when the hero comes close; three plumages (white, brown, dark).
 * Positions in map pixels; the drawing is in the app (`WorldScreen`).
 */
object MapHen {
    @Volatile var draft = true

    /** One pose as the numbers between which the moves blend. */
    data class Pose(
        /** The body: height of its middle, tipped forward (+, degrees: the breast down, the tail up). */
        val bodyY: Double, val tilt: Double,
        /** The head: height, how far forward, nodded down (+, degrees). */
        val headY: Double, val headZ: Double, val nod: Double,
        /** Walking: the left foot forward (+) and the right back, in cm; [lift] raises the foot that swings. */
        val stride: Double = 0.0, val lift: Double = 0.0,
        /** Scratching: the right foot raked back (1) along the ground. */
        val scratch: Double = 0.0,
        /** The wings: folded 0, spread and raised 1. */
        val wing: Double = 0.0,
    ) {
        fun lerp(o: Pose, t: Double): Pose {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Pose(l(bodyY, o.bodyY), l(tilt, o.tilt), l(headY, o.headY), l(headZ, o.headZ), l(nod, o.nod),
                l(stride, o.stride), l(lift, o.lift), l(scratch, o.scratch), l(wing, o.wing))
        }
    }

    val STAND = Pose(20.0, -6.0, 35.0, 9.0, 0.0)
    /** Head lowered, looking at the ground. */
    val LOW = Pose(19.0, 12.0, 20.0, 15.0, 35.0)
    /** The beak on the ground. */
    val PECK = Pose(18.0, 24.0, 8.0, 17.0, 65.0)
    /** The right foot raked back, the head low to look what came up. */
    val SCRATCH = Pose(19.0, 10.0, 24.0, 14.0, 30.0, scratch = 1.0)
    /** Neck stretched, the head up: something is coming. */
    val ALERT = Pose(22.0, -14.0, 40.0, 7.0, -8.0)
    /** Running off, low and forward, wings out. */
    val RUN = Pose(18.0, 18.0, 29.0, 15.0, 10.0, wing = 1.0)

    /** The three plumages: body, neck, tail and wing tips, legs. */
    private class Plumage(val body: Mat, val neck: Mat, val tail: Mat, val leg: Mat)
    private fun feather(rgb: Int) = Mat(Ramp.of(argb(rgb)), grain = 0.18)
    private val PLUMAGES = listOf(
        Plumage(feather(0xE2DACA), feather(0xEAE3D4), feather(0xD6CDBC), Mat(Ramp.of(argb(0xC8A048)), grain = 0.06)),
        Plumage(feather(0x8C4E26), feather(0xB06A30), feather(0x2E2622), Mat(Ramp.of(argb(0xB89040)), grain = 0.06)),
        Plumage(feather(0x3A3634), feather(0x6A6050), feather(0x22201E), Mat(Ramp.of(argb(0x5E5850)), grain = 0.06)),
    )
    const val VARIANTS = 3
    private val comb = Mat(Ramp.of(argb(0xA02A22)), grain = 0.08)
    private val beak = Mat(Ramp.of(argb(0xC8A062)), shine = 0.3)
    private val eye = Mat(Ramp.of(argb(0x1A1210)), shine = 1.0)

    private const val BODY = 0; private const val HEAD = 1; private const val LEGS = 2; private const val DETAIL = 3
    /** A little larger than life, like the cat: a hen would be a speck next to the hero. */
    const val SIZE = 1.3

    fun solids(p: Pose, variant: Int): Pair<List<Solid>, Groups> {
        val k = SIZE
        val pl = PLUMAGES[Math.floorMod(variant, VARIANTS)]
        val out = mutableListOf<Solid>()
        fun add(s: Solid, m: Mat): Solid { s.mat = m; out += s; return s }
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = Frame.IDENTITY) = add(Ellipsoid(c * k, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a * k, b * k, ra * k, rb * k, BodyPart.ARM, g), m)
        fun frameOf(r: Rot) = Frame(r.x, r.y, r.z)

        // ---- the body: an egg tipped by [tilt], the breast full, the tail fanned up behind
        val tilt = Rot.pitch(p.tilt)
        val b = P3(0.0, p.bodyY, 0.0)
        fun on(x: Double, y: Double, z: Double) = b + tilt.apply(P3(x, y, z))
        ell(b, 7.6, 8.0, 11.5, pl.body, BODY, frameOf(tilt))
        ell(on(0.0, 1.0, 6.5), 6.6, 7.2, 6.0, pl.body, BODY, frameOf(tilt))
        // the tail: two feathered blades rising back, darker at the tips
        val tailRot = tilt * Rot.pitch(-55.0)
        ell(on(0.0, 6.0, -10.0), 2.6, 6.0, 4.2, pl.body, BODY, frameOf(tailRot))
        ell(on(0.0, 10.5, -12.5), 2.0, 4.0, 3.2, pl.tail, DETAIL, frameOf(tailRot))

        // ---- the wings: folded along the side, or spread up and out, flapping
        for (s in listOf(-1.0, 1.0)) {
            val shoulder = on(s * 5.6, 3.5, 4.0)
            val folded = tilt.apply(P3(s * 0.12, -0.25, -1.0)).norm()
            val spread = P3(s * 0.95, 0.28, -0.25).norm()
            val dir = folded.lerp(spread, p.wing).norm()
            // the thin side of the wing: sideways while folded, up when spread (a flat feathered fan, not a plate on edge)
            val thinFolded = (P3.Y cross dir).let { if (it.len() < 1e-3) P3.X else it.norm() }
            val thinSpread = (dir cross P3.Z).let { if (it.len() < 1e-3) P3.Y else it.norm() }.let { if (it.y < 0) -it else it }
            val mixed = thinFolded.lerp(thinSpread, p.wing)
            val ax = (mixed - dir * (mixed dot dir)).let { if (it.len() < 1e-3) thinFolded else it.norm() }
            val ay = (dir cross ax).norm()
            val c = shoulder + dir * (6.5 + 1.5 * p.wing)
            ell(c, 1.5, 5.0 + 1.5 * p.wing, 8.0 + 1.5 * p.wing, pl.body, BODY, Frame(ax, ay, dir))
            ell(c + dir * (5.5 + p.wing), 1.2, 3.2, 3.0, pl.tail, DETAIL, Frame(ax, ay, dir))
        }

        // ---- neck and head: the hackles in the neck colour, comb and wattles, beak, eyes
        val neck = on(0.0, 5.5, 8.5)
        val head = P3(0.0, p.headY, p.headZ)
        cone(neck, head, 4.6, 3.0, pl.neck, BODY)
        val nod = Rot.pitch(p.nod)
        val hf = frameOf(nod)
        fun h(x: Double, y: Double, z: Double) = head + nod.apply(P3(x, y, z))
        ell(h(0.0, 0.0, 0.0), 3.1, 3.3, 3.7, pl.neck, HEAD, hf)
        for ((i, z) in listOf(-1.4, 0.2, 1.8).withIndex()) ell(h(0.0, 3.0 + (if (i == 1) 0.6 else 0.0), z), 0.6, 1.3, 1.0, comb, DETAIL, hf)
        ell(h(0.0, -2.6, 2.6), 0.8, 1.3, 0.8, comb, DETAIL, hf)
        cone(h(0.0, 0.2, 3.0), h(0.0, -0.5, 5.6), 1.0, 0.25, beak, DETAIL)
        for (s in listOf(-1.0, 1.0)) ell(h(s * 2.4, 0.8, 1.5), 0.45, 0.55, 0.55, eye, DETAIL, hf)

        // ---- the legs: feathered thighs, thin bare shanks, three toes forward and one back
        for (s in listOf(-1.0, 1.0)) {
            val hip = on(s * 2.8, -6.0, 0.5)
            ell(hip, 2.8, 3.4, 3.4, pl.body, BODY, frameOf(tilt))
            val step = s * p.stride
            val swing = if (step > 0) p.lift * (step / (kotlin.math.abs(p.stride) + 1e-9)) else 0.0
            val rake = if (s > 0) p.scratch else 0.0
            val foot = P3(s * 2.8, 0.7 + swing * 2.5 + rake * 1.2, 1.0 + step - rake * 7.0)
            cone(hip + P3(0.0, -2.0, 0.0), foot + P3(0.0, 0.8, 0.0), 0.75, 0.6, pl.leg, LEGS)
            for (a in listOf(-28.0, 0.0, 28.0)) {
                val d = Rot.yaw(a * s).apply(P3(0.0, 0.0, 1.0))
                cone(foot, foot + d * 3.2 + P3(0.0, -0.3, 0.0), 0.45, 0.3, pl.leg, LEGS)
            }
            cone(foot, foot + P3(0.0, 0.0, -1.6), 0.4, 0.3, pl.leg, LEGS)
        }

        val g = Groups(4)
        g.reach = 8.0 * k
        g.set(BODY, 2.0 * k)
        g.set(HEAD, 0.8 * k, BODY, head * k)
        g.set(LEGS, 0.2 * k)
        g.set(DETAIL, 0.0)
        return out to g
    }

    // ---------------------------------------------------------------- what a hen does

    /** Where a hen is and how it looks: map pixels of its feet, facing map direction [yaw], pose [key] at step [k] of 8. */
    data class At(val x: Float, val y: Float, val yaw: Double, val key: String, val k: Int, val variant: Int, val shown: Float = 1f, val seed: Int = 0)

    private fun pose(name: String) = when (name) {
        "low" -> LOW; "peck" -> PECK; "scratch" -> SCRATCH; "alert" -> ALERT; "run" -> RUN; else -> STAND
    }

    /** The pose for [key] ("low", "stand>scratch") at step [k] of 8, or a step of the walk ("walk") or the run ("run"). */
    fun poseOf(key: String, k: Int): Pose {
        val a = k / 8.0 * 2 * Math.PI
        return when {
            key == "walk" -> STAND.copy(stride = 3.2 * sin(a), lift = 1.0, headZ = STAND.headZ + 1.2 * cos(a * 2), bodyY = STAND.bodyY + 0.3 * kotlin.math.abs(cos(a)))
            key == "run" -> RUN.copy(stride = 4.5 * sin(a), lift = 1.4, wing = 0.55 + 0.45 * sin(a * 2))
            '>' in key -> key.split('>').let { (x, y) -> pose(x).lerp(pose(y), k / 8.0) }
            else -> pose(key)
        }
    }

    enum class Mood { IDLE, WALK, FLEE, WARY, SHELTER }

    /**
     * A hen at home by ([homeX], [homeY]) in map pixels. Left alone it pecks, scratches, looks up and now and
     * then strolls to a new spot within [ROAM] pixels; the hero within [SHY] pixels and it runs off flapping,
     * away from him, stops once he is [SAFE] off, stands wary a while and goes back to its business. In the rain
     * and at dusk ([at] with away) it hurries off under the trees nearest home and is gone there; when it is
     * dry and light again it comes out the same way (94, D7.1: never vanishing on the spot).
     */
    class Hen(val homeX: Float, val homeY: Float, val seed: Int, val variant: Int) {
        var x = homeX; var y = homeY
        /** Where it wants to face, and where it faces now: it turns at most [TURN] degrees a second, never snaps round. */
        private var yaw = (seed % 8) * 45.0
        private var shown = yaw
        /** The way round an obstacle it took last, kept so it does not dither left and right. */
        private var aside = 0
        private var stuck = false
        private var bout = Long.MIN_VALUE
        /** The pose it had before the present mood, so the new one starts with a blend from it, not a jump. */
        private var from = "low"
        /** The pose shown last; a stroll only sets off from the head low, not mid peck or looking up (294). */
        private var shownKey = "low"
        /** A stroll it means to take once its head is low again (294). */
        private var wantsWalk = false
        /** Back at its business after a stroll: it keeps its head low until a bout comes round to that (294). */
        private var settled = true

        // what is to be heard (83c), read by the sound loop: how often it has run off, the bout it is in and what
        // it does in it (0 pecking, 1 scratching, 2 looking up), and the rake of the foot it is at
        @Volatile var fled = 0; private set
        @Volatile var heardBout = Long.MIN_VALUE; private set
        @Volatile var heardKind = -1; private set
        @Volatile var heardRake = Long.MIN_VALUE; private set
        private var mood = Mood.IDLE
        private var since = Long.MIN_VALUE
        private var last = Long.MIN_VALUE
        private var tx = homeX; private var ty = homeY
        private var walkSlot = Long.MIN_VALUE
        /** How much of it is to be seen: 1 out in the open, 0 gone under the trees. */
        private var seen = 1f
        /** Under the trees (map pixels): the open spot before them, and the spot among them where it is gone. */
        private var shelter: Pair<Float, Float>? = null
        private var cover: Pair<Float, Float>? = null
        /** The other hens of the map: two never stand on one spot (129, Chef 16.10.: the white and the brown one on one place). */
        var flock: List<Hen> = emptyList()

        /** Whether another hen out in the open stands within [GAP] of ([px], [py]) and the step would bring the two closer. */
        private fun crowded(px: Float, py: Float): Boolean = flock.any {
            it !== this && it.seen > 0f && hypot(it.x - px, it.y - py) < GAP && hypot(it.x - px, it.y - py) < hypot(it.x - x, it.y - y)
        }

        private fun free(map: MapDef, px: Float, py: Float, apart: Boolean = true): Boolean {
            val T = WorldArt.T
            if (hypot(px - homeX, py - homeY) > LEASH) return false
            if (apart && crowded(px, py)) return false
            // keep a little off what is not walkable, so it never stands in the bale or a fence
            for ((dx, dy) in listOf(0f to 0f, 5f to 0f, -5f to 0f, 0f to 4f, 0f to -4f)) {
                val t = map.tile(Math.floorDiv((px + dx).toInt(), T), Math.floorDiv((py + dy).toInt(), T))
                if (!t.walkable) return false
            }
            return !nearWater(map, px, py)
        }

        /**
         * Where to go in the rain and at dusk: the walkable spot beside the nearest trees within a few tiles of home,
         * one it can run to straight before one behind the bale (129: the one on the far side of a bale stood stuck before it).
         */
        private fun findShelter(map: MapDef) {
            val T = WorldArt.T
            val hx = Math.floorDiv(homeX.toInt(), T); val hy = Math.floorDiv(homeY.toInt(), T)
            var best = Float.MAX_VALUE
            for (ty in hy - 4..hy + 4) for (tx in hx - 4..hx + 4) {
                if (map.tile(tx, ty) != Tile.TREE) continue
                for ((dx, dy) in listOf(0 to -1, -1 to 0, 1 to 0, 0 to 1)) {
                    val ox = (tx + dx) * T + T / 2f; val oy = (ty + dy) * T + T / 2f
                    if (!map.tile(tx + dx, ty + dy).walkable || nearWater(map, ox, oy)) continue
                    val d = hypot(ox - homeX, oy - homeY) + (if (clear(map, ox, oy)) 0f else 1_000f)
                    if (d < best) { best = d; shelter = ox to oy; cover = (ox - dx * T * 0.55f) to (oy - dy * T * 0.55f) }
                }
            }
            if (shelter == null) { shelter = homeX to homeY; cover = homeX to homeY }
            // the two of a bale share the nearest trees: each its own side of them, so they never go in on one spot (129)
            val side = if (flock.size < 2) 0f else if (flock.indexOf(this) % 2 == 0) -GAP / 2 else GAP / 2
            val (sx, sy) = shelter!!; val (cx, cy) = cover!!
            val len = hypot(cx - sx, cy - sy)
            val (ux, uy) = if (len < 0.1f) 1f to 0f else -(cy - sy) / len to (cx - sx) / len
            val ox = sx + ux * side; val oy = sy + uy * side
            if (map.tile(Math.floorDiv(ox.toInt(), T), Math.floorDiv(oy.toInt(), T)).walkable && !nearWater(map, ox, oy)) {
                shelter = ox to oy; cover = (cx + ux * side) to (cy + uy * side)
            }
        }

        /** Whether the way from home straight to ([px], [py]) is free ground. */
        private fun clear(map: MapDef, px: Float, py: Float): Boolean {
            val n = (hypot(px - homeX, py - homeY) / 4f).toInt()
            return (1..n).all { i -> free(map, homeX + (px - homeX) * i / n, homeY + (py - homeY) * i / n, apart = false) }
        }

        /** Moves towards ([gx], [gy]) at [speed] px/s for [dt] ms; false when the way is blocked. */
        private fun step(map: MapDef, gx: Float, gy: Float, speed: Float, dt: Long, through: Boolean = false, apart: Boolean = true): Boolean {
            val dx = gx - x; val dy = gy - y
            val d = hypot(dx, dy)
            if (d < 0.5f) return true
            val s = minOf(d, speed * dt / 1000f)
            val nx = x + dx / d * s; val ny = y + dy / d * s
            if (!through && !free(map, nx, ny, apart)) return false
            yaw = Math.toDegrees(atan2(dx.toDouble(), dy.toDouble()))
            x = nx; y = ny
            return true
        }

        /** Where it is and how it looks at [clock]; [away] in the rain and at dusk, when it goes under the trees. */
        fun at(clock: Long, heroX: Float, heroY: Float, map: MapDef, away: Boolean = false): At {
            if (shelter == null) findShelter(map)
            if (since == Long.MIN_VALUE || clock < last || clock - last > 5_000) {
                // back on the map after a while: it is where the weather put it, not on its way
                since = clock; mood = Mood.IDLE
                if (away) { mood = Mood.SHELTER; seen = 0f; cover!!.let { (cx, cy) -> x = cx; y = cy } }
                else if (seen < 1f) { seen = 1f; x = homeX; y = homeY }
            }
            val dt = if (last == Long.MIN_VALUE) 0L else (clock - last).coerceIn(0L, 200L)
            last = clock
            val near = hypot(heroX - x, heroY - y)
            fun go(m: Mood) {
                if (m == Mood.FLEE) fled++
                from = when (mood) { Mood.FLEE, Mood.WARY -> "alert"; Mood.WALK, Mood.SHELTER -> "stand"; Mood.IDLE -> "low" }
                if (m == Mood.IDLE) settled = false
                wantsWalk = false
                // stopped before it had quite stood up: it goes back down from where it got to, not from standing (294)
                val rising = clock - since
                if (mood == Mood.WALK && m == Mood.IDLE && rising < BLEND) { mood = m; since = clock - (BLEND - rising); return }
                mood = m; since = clock
            }
            if (away && mood != Mood.SHELTER) go(Mood.SHELTER)
            if (!away && mood == Mood.SHELTER) {
                // out again: from among the trees into the open, then home at its own pace
                if (seen < 1f) { seen = minOf(1f, seen + dt / FADE_MS); val (sx, sy) = shelter!!; step(map, sx, sy, WALK_SPEED, dt, through = true) }
                if (seen >= 1f) { tx = homeX; ty = homeY; go(Mood.WALK) }
            }
            if (near < SHY && mood != Mood.FLEE && mood != Mood.SHELTER) go(Mood.FLEE)
            when (mood) {
                Mood.SHELTER -> if (away) {
                    // hurrying to the trees, round the bale or a fence, brushing past the others; there it steps in among them and is gone
                    val (sx, sy) = shelter!!
                    if (hypot(sx - x, sy - y) > 2f && seen >= 1f) {
                        val dx = sx - x; val dy = sy - y
                        val base = atan2(dx.toDouble(), dy.toDouble())
                        var moved = false
                        for (turn in listOf(0, 45, -45, 90, -90)) {
                            val a = base + Math.toRadians(turn.toDouble())
                            val r = minOf(hypot(dx, dy), 20f)
                            if (step(map, x + sin(a).toFloat() * r, y + cos(a).toFloat() * r, HURRY_SPEED, dt, apart = false)) { moved = true; break }
                        }
                        // blocked for good (or far too long on the way): it slips in where it is
                        if (!moved || clock - since > 20_000) seen = minOf(seen, 0.999f)
                    } else {
                        val (cx, cy) = cover!!
                        if (hypot(cx - x, cy - y) < WorldArt.T) step(map, cx, cy, WALK_SPEED, dt, through = true)
                        seen = maxOf(0f, seen - dt / FADE_MS)
                    }
                }
                Mood.FLEE -> {
                    if (near > SAFE) go(Mood.WARY)
                    else {
                        // straight away from the hero, bending aside where the way is blocked
                        val ax = x - heroX; val ay = y - heroY
                        val base = atan2(ax.toDouble(), ay.toDouble())
                        val side = if (aside != 0) aside else if (seed % 2 == 0) 1 else -1
                        stuck = true
                        for (turn in listOf(0, 35, -35, 70, -70, 110, -110)) {
                            val a = base + Math.toRadians((turn * side).toDouble())
                            if (step(map, x + sin(a).toFloat() * 20f, y + cos(a).toFloat() * 20f, RUN_SPEED, dt)) {
                                stuck = false
                                if (turn != 0) aside = if (turn > 0) side else -side
                                break
                            }
                        }
                    }
                }
                Mood.WARY -> if (clock - since > 2_500) go(Mood.IDLE)
                Mood.WALK -> {
                    // round the bale or a fence: aside first, then on towards the spot; stuck a while, it stops there
                    val dx = tx - x; val dy = ty - y
                    val base = atan2(dx.toDouble(), dy.toDouble())
                    var moved = false
                    for (turn in listOf(0, 45, -45, 90, -90)) {
                        val a = base + Math.toRadians(turn.toDouble())
                        val r = minOf(hypot(dx, dy), 20f)
                        if (step(map, x + sin(a).toFloat() * r, y + cos(a).toFloat() * r, WALK_SPEED, dt)) { moved = true; break }
                    }
                    if (!moved || hypot(tx - x, ty - y) < 0.6f || clock - since > 12_000) go(Mood.IDLE)
                }
                Mood.IDLE -> {
                    // one that finds another on its spot steps aside, unhurried (129)
                    flock.firstOrNull { it !== this && it.seen > 0f && hypot(it.x - x, it.y - y) < GAP }?.let { o ->
                        val d = hypot(x - o.x, y - o.y)
                        val (ux, uy) = if (d < 0.1f) (if (seed >= o.seed) 1f else -1f) to 0f else (x - o.x) / d to (y - o.y) / d
                        step(map, x + ux * 20f, y + uy * 20f, WALK_SPEED, dt)
                    }
                    // now and then off to a new spot near home; far from home it goes back first
                    val slot = Math.floorDiv(clock + seed * 313L, SLOT)
                    if (slot != walkSlot && hash(slot.toInt(), seed, 2) % 3 == 0) {
                        walkSlot = slot
                        val back = hypot(x - homeX, y - homeY) > ROAM
                        val a = (hash(slot.toInt(), seed, 3) % 360) * Math.PI / 180
                        val r = 8f + hash(slot.toInt(), seed, 4) % (ROAM.toInt() - 8)
                        val gx = if (back) homeX else homeX + sin(a).toFloat() * r
                        val gy = if (back) homeY else homeY + cos(a).toFloat() * r * 0.7f
                        if (free(map, gx, gy)) { tx = gx; ty = gy; wantsWalk = true }
                    }
                    walkSlot = slot
                    if (wantsWalk && shownKey == "low") go(Mood.WALK)
                }
            }
            if (mood != Mood.FLEE) aside = 0
            val t = clock - since
            val a = when (mood) {
                Mood.SHELTER -> if (seen >= 1f && hypot(shelter!!.first - x, shelter!!.second - y) > 2f) At(x, y, yaw, "run", Math.floorMod((clock / 60).toInt(), 8), variant)
                    else At(x, y, yaw, "walk", Math.floorMod((clock / 80).toInt(), 8), variant)
                Mood.FLEE -> if (stuck) At(x, y, yaw, "alert", 0, variant) else At(x, y, yaw, "run", Math.floorMod((clock / 45).toInt(), 8), variant)
                Mood.WALK -> if (t < BLEND) At(x, y, yaw, "$from>stand", (t * 8 / BLEND).toInt(), variant) else At(x, y, yaw, "walk", Math.floorMod((clock / 80).toInt(), 8), variant)
                Mood.WARY -> At(x, y, yaw, if (t < 300) "run>alert" else "alert", if (t < 300) (t * 8 / 300).toInt() else 0, variant)
                Mood.IDLE -> if (t < BLEND && from != "low") At(x, y, yaw, "$from>low", (t * 8 / BLEND).toInt(), variant)
                    else idle(clock).let { i -> if (!settled && i.key != "low") i.copy(key = "low", k = 0) else { settled = true; i } }
            }
            shownKey = a.key
            // turning: towards where it wants to face, quick when running, unhurried otherwise
            val want = a.yaw
            var d = (want - shown) % 360.0
            if (d > 180) d -= 360.0 else if (d < -180) d += 360.0
            val most = (if (mood == Mood.FLEE) TURN_RUN else TURN) * dt / 1000.0
            shown += d.coerceIn(-most, most)
            return a.copy(yaw = shown, shown = seen, seed = seed)
        }

        /** What it does standing: pecking mostly, a bout of scratching, looking up; each bout a few seconds. */
        private fun idle(clock: Long): At {
            val c = clock + seed * 313L
            val slot = Math.floorDiv(c, BOUT)
            val u = Math.floorMod(c, BOUT)
            // each new bout turns it a little, and it keeps that way
            if (slot != bout) { bout = slot; yaw += (hash(slot.toInt(), seed, 6) % 3 - 1) * 35.0 }
            val face = yaw
            val kind = hash(slot.toInt(), seed, 5) % 6
            heardKind = when (kind) { 0, 1, 2 -> 0; 3, 4 -> 1; else -> 2 }
            heardBout = slot
            return when (kind) {
                0, 1, 2 -> {
                    // pecking: head low, then a quick jab to the ground, two or three times a second, now and then a pause
                    // each jab starts and ends with the head low, so a bout begins and ends without a jump
                    val jab = u % JAB
                    val pause = hash((u / JAB).toInt(), seed + slot.toInt(), 8) % 3 == 0
                    if (pause || jab > 260) At(x, y, face, "low", 0, variant)
                    else At(x, y, face, "low>peck", (if (jab < 130) jab * 8 / 130 else (260 - jab) * 8 / 130).toInt().coerceIn(0, 8), variant)
                }
                3, 4 -> {
                    // scratching: raking back with one foot, then a look at the ground
                    val r = u % RAKE
                    heardRake = slot * 16 + u / RAKE
                    if (r < 420) At(x, y, face, "low>scratch", (if (r < 210) r * 8 / 210 else (420 - r) * 8 / 210).toInt().coerceIn(0, 8), variant)
                    else At(x, y, face, "low", 0, variant)
                }
                // looking up a while, the head raised and lowered again
                else -> when {
                    u < BLEND -> At(x, y, face, "low>alert", (u * 8 / BLEND).toInt(), variant)
                    u < 1_800 -> At(x, y, face, "alert", 0, variant)
                    u < 1_800 + BLEND -> At(x, y, face, "alert>low", ((u - 1_800) * 8 / BLEND).toInt(), variant)
                    else -> At(x, y, face, "low", 0, variant)
                }
            }
        }
    }

    /** How long a change of pose between moods takes. */
    private const val BLEND = 300L
    private const val TURN = 240.0
    private const val TURN_RUN = 720.0
    /** How close two hens may come: about a hen's width, the two of a bale stand so far apart (129). */
    const val GAP = 10f
    const val SHY = 46f
    const val SAFE = 90f
    /** How far from home it strolls, and how far it may run off. */
    const val ROAM = 34f
    const val LEASH = 120f
    private const val WALK_SPEED = 16f
    private const val RUN_SPEED = 85f
    /** Off to the trees in the rain: quicker than a stroll, slower than running from the hero. */
    private const val HURRY_SPEED = 40f
    /** How long it takes to step in among the trees, or out again (ms). */
    private const val FADE_MS = 900f
    private const val SLOT = 4_200L
    /** A bout of pecking or scratching is whole jabs and rakes long. */
    private const val JAB = 440L
    private const val RAKE = 770L
    private const val BOUT = 3_080L

    // ---------------------------------------------------------------- the places

    private val cache = HashMap<String, List<Hen>>()

    /** Whether ([px], [py]) lies within about two thirds of a tile of water: the drawn bank reaches over the tile's edge (94). */
    internal fun nearWater(map: MapDef, px: Float, py: Float): Boolean {
        val T = WorldArt.T
        for ((dx, dy) in listOf(0f to -30f, 0f to 14f, -18f to 0f, 18f to 0f, -14f to -24f, 14f to -24f)) {
            if (map.tile(Math.floorDiv((px + dx).toInt(), T), Math.floorDiv((py + dy).toInt(), T)) == Tile.WATER) return true
        }
        return false
    }

    /** The hens of [map]: two by each hay bale of a village, on the open ground beside it (west or north of it). */
    fun of(map: MapDef): List<Hen> = synchronized(cache) { cache.getOrPut(map.id) { find(map) } }

    private fun find(map: MapDef): List<Hen> {
        if (map.kind != MapKind.TOWN) return emptyList()
        val T = WorldArt.T
        val out = mutableListOf<Hen>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (map.tile(tx, ty) != Tile.HAY) continue
            // beside the bale on the open side away from the edge of the map, where nothing stands in front (west, north)
            val spots = listOf(-1 to 0, 0 to -1, -1 to -1, 1 to 0, 0 to 1).filter { (dx, dy) -> map.tile(tx + dx, ty + dy).walkable && !nearWater(map, (tx + dx) * T + T / 2f, (ty + dy) * T + T / 2f) }
            // east of a bale is a pocket against the trees at the edge of the map: only where nothing else is free (94)
            val open = spots.filter { it != (1 to 0) }.ifEmpty { spots }
            // two bales side by side share their free ground: each hen a hen's length from every other (129)
            val places = (open.mapIndexed { n, s -> s to (n % 2 * 2 - 1) * 5f } + open.flatMap { s -> listOf(s to -5f, s to 5f, s to -9f, s to 9f) })
                .map { (s, off) -> ((tx + s.first) * T + T / 2f + off) to ((ty + s.second) * T + T / 2f) }
            var n = 0
            for ((px, py) in places) {
                if (n == 2) break
                if (out.any { hypot(it.homeX - px, it.homeY - py) < GAP }) continue
                out += Hen(px, py, hash(tx, ty, 50 + n) % 10_000, out.size % VARIANTS)
                n++
            }
        }
        return flocked(out)
    }

    /** Lets each of [hens] know the others, so they keep apart (129). */
    fun flocked(hens: List<Hen>): List<Hen> { for (h in hens) h.flock = hens; return hens }

    // ---------------------------------------------------------------- the pictures

    /** The hen at [a], drawn in the background when first wanted (null until then); [slot] as [MapFigure.slot]. */
    fun frame(a: At, slot: Int): PixelImage? {
        // until a picture is ready the hen's last one stays, so it never blinks out for a frame (94, test of 0.1.752:
        // the hens flickered; like the cat, 87.1)
        val img = shelf.picture(key(a, slot)) { render(poseOf(a.key, a.k), a.variant, slot * 360.0 / MapFigure.YAWS) }
        synchronized(last) { if (img != null) last[a.seed] = img else return last[a.seed] }
        return img
    }
    private val last = HashMap<Int, PixelImage>()

    /** The same, drawn now (the previews). */
    fun frameNow(a: At, slot: Int): PixelImage =
        shelf.pictureNow(key(a, slot)) { render(poseOf(a.key, a.k), a.variant, slot * 360.0 / MapFigure.YAWS) }

    /**
     * The hens' own pictures: they have many (three plumages, sixteen directions, every step of a move), and on the
     * shelf of the villagers they pushed each other out, to be drawn again and again (94). Room for what half an hour
     * among them calls for ([MapHenTest]); small pictures (48 × 48, 9 KB each).
     */
    const val SHELF = 2_400
    private val shelf = MapRest.Shelf(SHELF)

    /** Blends go in steps of two of eight: enough for so small a figure, half the pictures. */
    internal fun key(a: At, slot: Int) = "hen|${a.variant}|${a.key}|${if ('>' in a.key) a.k / 2 * 2 else a.k}|$slot"

    /** The picture's size and where the feet stand in it. */
    const val W = 48; const val H = 48; const val AX = 24; const val GY = 40

    /** The hen in pose [p] facing [yaw], in a [w] × [h] picture with the feet on [ground] at [anchorX]. */
    fun render(p: Pose, variant: Int, yaw: Double, w: Int = W, h: Int = H, anchorX: Double = AX.toDouble(), ground: Double = GY.toDouble(), px: Double = 0.55, pitch: Double = 38.0): PixelImage {
        val (so, g) = solids(p, variant)
        val img = SdfRender.render(so, g, { s, _ -> s.mat!! }, w, h, anchorX, ground, px, yaw, pitch)
        val s = Sculpt(w, h)
        for (y in 0 until h) for (x in 0 until w) s.img.set(x, y, img.img[x, y])
        s.outline(argb(0x100A0C))
        return s.img
    }

    private fun hash(a: Int, b: Int, c: Int = 0): Int {
        var n = a * 374761393 + b * 668265263 + c * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7fffffff
    }
}
