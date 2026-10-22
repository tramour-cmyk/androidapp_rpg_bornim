package de.bornim.core.art

/**
 * The inn's cat (draft, `KATZE=1`; Merkliste „Lebendige Orte“, 6g): a small ginger cat that sleeps curled up by
 * the hearth, now and then sits up, stretches and lies down somewhere else. Built in the round like the dolls,
 * in cm (y up, z forward), a little larger than life so it reads at map size.
 */
object MapCat {
    @Volatile var draft = true
    /** The previews: the moment of its round shown (ms), instead of the clock. */
    @Volatile var shift = 0L

    /** One pose as the numbers between which the moves blend. */
    data class Pose(
        /** Chest and haunch: height and how far forward. */
        val chestY: Double, val chestZ: Double, val hipY: Double, val hipZ: Double,
        /** The head: height, forward, nodded down (+, degrees). */
        val headY: Double, val headZ: Double, val nod: Double,
        /** The front paws and the hind paws: how far forward on the ground, and how far tucked in (0 standing, 1 under the body). */
        val frontZ: Double, val hindZ: Double, val tuck: Double,
        /** The body bent round to its left (0 straight, 1 curled nose to tail), as when asleep. */
        val curl: Double,
        /** The tail: raised (+) or along the ground, and wrapped round to the left (+). */
        val tailUp: Double, val tailWrap: Double,
        /** The eyes, open 1 or shut 0. */
        val eyes: Double,
        /** Walking: the left paws forward (+) and the right back, front and hind crosswise, in cm. */
        val stride: Double = 0.0,
    ) {
        fun lerp(o: Pose, t: Double): Pose {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Pose(l(chestY, o.chestY), l(chestZ, o.chestZ), l(hipY, o.hipY), l(hipZ, o.hipZ), l(headY, o.headY), l(headZ, o.headZ), l(nod, o.nod),
                l(frontZ, o.frontZ), l(hindZ, o.hindZ), l(tuck, o.tuck), l(curl, o.curl), l(tailUp, o.tailUp), l(tailWrap, o.tailWrap), l(eyes, o.eyes), l(stride, o.stride))
        }
    }

    val STAND = Pose(18.0, 11.0, 18.0, -11.0, 27.0, 21.0, 10.0, 12.0, -12.0, 0.0, 0.0, 0.7, 0.0, 1.0)
    val SIT = Pose(20.0, 5.0, 9.0, -6.0, 32.0, 9.0, 5.0, 8.0, -3.0, 0.6, 0.0, -0.2, 1.0, 1.0)
    val SLEEP = Pose(7.0, 6.0, 7.0, -6.0, 6.5, 12.0, 20.0, 8.0, -4.0, 1.0, 1.0, -0.3, 1.0, 0.0)
    /** Front low with the paws reached far forward, the rump up. */
    val STRETCH = Pose(6.5, 15.0, 22.0, -10.0, 8.0, 26.0, -8.0, 30.0, -14.0, 0.0, 0.0, 0.9, 0.0, 0.5)

    private val fur = Mat(Ramp.of(argb(0xB8692E)), grain = 0.16)
    private val stripe = Mat(Ramp.of(argb(0x8A4720)), grain = 0.14)
    private val pale = Mat(Ramp.of(argb(0xE8CFA6)), grain = 0.1)
    private val nose = Mat(Ramp.of(argb(0xC07A78)), shine = 0.5)
    private val eye = Mat(Ramp.of(argb(0x9CC23C)), shine = 1.0, bias = 0.25)
    private val lid = Mat(Ramp.of(argb(0x6A3418)), grain = 0.1)
    private val pupil = Mat(Ramp.of(argb(0x0C0808)), shine = 1.0)

    private const val BODY = 0; private const val HEAD = 1; private const val TAIL = 2; private const val DETAIL = 3
    /** A little larger than life: a house cat would be a handful of pixels next to the hero. */
    const val SIZE = 1.35

    fun solids(p: Pose): Pair<List<Solid>, Groups> {
        val k = SIZE
        val out = mutableListOf<Solid>()
        fun add(s: Solid, m: Mat): Solid { s.mat = m; out += s; return s }
        // curling bends the body round a point to its left: the chest swings left and back, the hips left and forward
        fun bend(x: Double, y: Double, z: Double): P3 {
            val a = Math.toRadians(p.curl * 70.0) * (z / 12.0)
            return P3((x * kotlin.math.cos(a) - z * kotlin.math.sin(a) * 0.9) - p.curl * 3.0 * (z / 12.0).let { it * it }, y, z * kotlin.math.cos(a) + x * kotlin.math.sin(a)) * k
        }
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = Frame.IDENTITY) = add(Ellipsoid(c, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a, b, ra * k, rb * k, BodyPart.ARM, g), m)

        // ---- the body: chest and haunch, joined by the back; a pale belly
        val chest = bend(0.0, p.chestY, p.chestZ)
        val hip = bend(0.0, p.hipY, p.hipZ)
        cone(chest, hip, 7.0, 7.6, fur, BODY)
        ell(chest, 6.8, 7.4, 7.0, fur, BODY)
        ell(hip, 7.4, 7.6, 7.8, fur, BODY)
        ell(chest + P3(0.0, -3.0 * k, 3.5 * k), 4.4, 4.6, 3.2, pale, BODY)
        // three darker stripes across the back
        val along = (chest - hip).norm()
        val across = (P3.Y cross along).norm()
        for (i in 0..2) {
            val c = chest + (hip - chest) * (0.2 + i * 0.3) + P3(0.0, 6.2 * k, 0.0)
            ell(c, 6.4, 1.6, 1.3, stripe, DETAIL, Frame(across, (along cross across).norm(), along))
        }

        // ---- the legs: thin, with round paws; tucked under the body when it lies
        val t = p.tuck
        for (s in listOf(-1.0, 1.0)) {
            val sh = bend(s * 3.4, p.chestY - 3.0, p.chestZ + 1.0)
            val fpaw = bend(s * 3.0, 1.2, p.frontZ - s * p.stride) * (1.0 - t) + (sh + P3(0.0, -4.0 * k, 3.0 * k)) * t
            cone(sh, fpaw + P3(0.0, 1.0 * k, 0.0), 1.8, 1.4, fur, BODY)
            ell(fpaw + P3(0.0, 0.2 * k, 0.6 * k), 1.6, 1.2, 2.0, pale, BODY)
            val hh = bend(s * 4.2, p.hipY - 1.0, p.hipZ - 1.0)
            val hpaw = bend(s * 3.4, 1.2, p.hindZ + s * p.stride) * (1.0 - t * 0.5) + (hh + P3(s * 1.5 * k, -4.0 * k, 4.0 * k)) * (t * 0.5)
            // the thigh as a flat haunch, then the shin down to the paw
            ell(hh + P3(s * 1.4 * k, -1.0 * k, 0.0), 2.6, 5.0, 4.6, fur, BODY)
            cone(hh + P3(s * 1.6 * k, -4.0 * k, -2.5 * k), hpaw + P3(0.0, 1.0 * k, 0.0), 1.6, 1.3, fur, BODY)
            ell(hpaw + P3(0.0, 0.2 * k, 0.8 * k), 1.6, 1.2, 2.4, pale, BODY)
        }

        // ---- the head: round skull, short muzzle, big ears, eyes
        val neck = bend(0.0, p.chestY + 3.0, p.chestZ + 3.5)
        val head = bend(p.curl * -2.0, p.headY, p.headZ)
        cone(neck, head, 4.0, 3.6, fur, BODY)
        val nod = Rot.pitch(p.nod) * Rot.yaw(p.curl * -40.0)
        val hx = nod.apply(P3.X); val hy = nod.apply(P3.Y); val hz = nod.apply(P3.Z)
        val hf = Frame(hx, hy, hz)
        fun h(x: Double, y: Double, z: Double) = head + (hx * x + hy * y + hz * z) * k
        ell(h(0.0, 0.0, 0.0), 5.2, 4.6, 4.7, fur, HEAD, hf)
        ell(h(0.0, -1.4, 3.4), 2.6, 1.9, 1.8, pale, HEAD, hf)
        add(Ellipsoid(h(0.0, -0.6, 4.9), P3(0.7 * k, 0.5 * k, 0.4 * k), hf, BodyPart.HEAD, DETAIL), nose)
        for (s in listOf(-1.0, 1.0)) {
            cone(h(s * 2.6, 2.6, -0.4), h(s * 3.2, 6.6, -0.8), 1.8, 0.25, fur, HEAD)
            if (p.eyes > 0.5) {
                add(Ellipsoid(h(s * 1.8, 0.8, 3.4), P3(0.95 * k, 0.8 * k, 0.5 * k), hf, BodyPart.HEAD, DETAIL), eye)
                add(Ellipsoid(h(s * 1.8, 0.8, 3.75), P3(0.25 * k, 0.65 * k, 0.3 * k), hf, BodyPart.HEAD, DETAIL), pupil)
            } else add(Ellipsoid(h(s * 1.8, 0.7, 3.5), P3(0.95 * k, 0.22 * k, 0.4 * k), hf, BodyPart.HEAD, DETAIL), lid)
        }

        // ---- the tail: from the rump, raised or laid along the ground, wrapped round to the left
        val base = bend(0.0, p.hipY + 2.0, p.hipZ - 6.0)
        var prev = base
        var dir = P3(0.0, p.tailUp, -1.0).norm()
        for (i in 1..6) {
            // each joint turns a little more to the left (wrap) and droops to the ground when low
            // a raised tail goes up and curls over at the tip; a low one droops to the ground
            dir = Rot.yaw(p.tailWrap * 26.0).apply(dir).let { if (p.tailUp < 0.3) P3(it.x, it.y - 0.15, it.z).norm() else if (i >= 3) P3(it.x, it.y - 0.1 * p.tailUp, it.z - 0.25 * p.tailUp).norm() else it }
            var next = prev + dir * (4.2 * k)
            if (next.y < 1.4 * k) next = P3(next.x, 1.4 * k, next.z)
            cone(prev, next, 1.25 - i * 0.07, 1.15 - i * 0.07, if (i == 6) stripe else fur, TAIL)
            prev = next
        }

        val g = Groups(4)
        g.reach = 8.0 * k
        g.set(BODY, 2.6 * k)
        g.set(HEAD, 0.8 * k, BODY, head)
        g.set(TAIL, 0.6 * k, BODY, base)
        g.set(DETAIL, 0.0)
        return out to g
    }

    // ---------------------------------------------------------------- the cat's day in the inn

    /** Where it lies, in tiles of the inn: before the hearth, by the barrel, in the middle of the room (free to see, 43). */
    internal val SPOTS = listOf(5.0 to 2.0, 1.0 to 4.0, 6.0 to 3.0)
    /** The way from each spot to the next, round the bar and the tables (corners in tiles, the spot last): over the rug and
     *  past the end of the bar, never through the table in front of it (87.1, test of 0.1.740). */
    internal val WAYS = listOf(listOf(5.0 to 5.0, 2.0 to 5.0, 2.0 to 4.0, 1.0 to 4.0), listOf(2.0 to 4.0, 2.0 to 5.0, 5.0 to 5.0, 5.0 to 3.0, 6.0 to 3.0), listOf(5.0 to 3.0, 5.0 to 2.0))
    /** How long it sleeps at each spot, in ms. */
    private val NAPS = listOf(70_000L, 45_000L, 40_000L)
    /** Waking up: sit up, sit a while, get up, stretch and back, then off. */
    private val WAKE = listOf(1500L to "sleep>sit", 5000L to "sit", 1000L to "sit>stand", 1600L to "stand>stretch", 1400L to "stretch>stand", 400L to "stand")
    /** Lying down at the new spot: sit, then curl up. */
    private val LIE = listOf(1200L to "stand>sit", 3000L to "sit", 1800L to "sit>sleep")
    /** Tiles a second at a stroll. */
    private const val SPEED = 1.1

    /** Where the cat is and how it looks: [x], [y] in tiles, facing map direction [yaw], in pose [key] blended [k] of 8; walking, it heads for spot [next]. */
    data class At(val x: Double, val y: Double, val yaw: Double, val key: String, val k: Int, val next: Int = 0)

    private fun pose(name: String) = when (name) { "sleep" -> SLEEP; "sit" -> SIT; "stand" -> STAND; "stretch" -> STRETCH; else -> STAND }

    /** The pose for [key] ("sit", "sleep>sit") at step [k] of 8, or a step [k] of the walk ("walk"). */
    fun poseOf(key: String, k: Int): Pose = when {
        key == "walk" -> STAND.copy(stride = 4.0 * kotlin.math.sin(k / 8.0 * 2 * Math.PI), chestY = STAND.chestY + 0.4 * kotlin.math.abs(kotlin.math.cos(k / 8.0 * 2 * Math.PI)))
        // eased in and out, so a move starts and stops softly (294)
        '>' in key -> key.split('>').let { (a, b) -> val f = k / 8.0; pose(a).lerp(pose(b), f * f * (3 - 2 * f)) }
        else -> pose(key)
    }

    /** One picture of the walk, in ms; half a stride, after which the paws are side by side again. */
    private const val STEP = 90L
    private const val HALF = STEP * 4
    /** Turning on the spot, ms a degree: slowly off from the spot, briskly at the corners (294). */
    private const val TURN = 6.0

    private fun turn(from: Double, to: Double) = Math.floorMod((to - from).toLong() + 540L, 360L) - 180.0
    private fun turnMs(deg: Double, perDeg: Double = TURN) = maxOf(HALF, Math.round(kotlin.math.abs(deg) * perDeg / HALF) * HALF)
    /** The yaw it lies with at spot [n], facing the room. */
    private fun spotYaw(n: Int) = 20.0 + n * 40.0
    private fun dir(x: Double, y: Double, tx: Double, ty: Double) = when { tx > x -> 90.0; tx < x -> 270.0; ty > y -> 0.0; else -> 180.0 }

    /** A stretch of the walk, or a turn on the spot (from yaw, to yaw, from, to). */
    private class Move(val ms: Long, val yaw0: Double, val yaw1: Double, val x0: Double, val y0: Double, val x1: Double, val y1: Double)
    /**
     * The walk from spot [n] to the next, with a turn before each stretch and to lie at the end: before, it snapped
     * round a quarter at each corner (294). The whole walk lasts whole half strides, so it stops with the paws together.
     */
    private val MOVES: List<List<Move>> = SPOTS.indices.map { n ->
        val way = WAYS[n]
        var x = SPOTS[n].first; var y = SPOTS[n].second
        val dist = way.fold(Triple(x, y, 0.0)) { (px, py, d), (tx, ty) -> Triple(tx, ty, d + kotlin.math.abs(tx - px) + kotlin.math.abs(ty - py)) }.third
        val walkMs = maxOf(HALF, Math.round(dist / SPEED * 1000 / HALF) * HALF)
        val out = mutableListOf<Move>()
        var yaw = spotYaw(n)
        var used = 0L
        for ((i, p) in way.withIndex()) {
            val (tx, ty) = p
            val d = kotlin.math.abs(tx - x) + kotlin.math.abs(ty - y)
            val ms = if (i == way.lastIndex) walkMs - used else Math.round(walkMs * d / dist)
            used += ms
            val to = yaw + turn(yaw, dir(x, y, tx, ty))
            if (to != yaw) out += Move(turnMs(to - yaw, if (i == 0) TURN else TURN / 2), yaw, to, x, y, x, y)
            out += Move(ms, to, to, x, y, tx, ty)
            yaw = to; x = tx; y = ty
        }
        val lie = spotYaw((n + 1) % SPOTS.size)
        if (turn(yaw, lie) != 0.0) out += Move(turnMs(turn(yaw, lie)), yaw, yaw + turn(yaw, lie), x, y, x, y)
        out
    }

    /** The cat at [clockMs]: one round of all spots, again and again. */
    fun at(clockMs: Long): At {
        val legs = SPOTS.indices.map { n -> NAPS[n] + WAKE.sumOf { it.first } + MOVES[n].sumOf { it.ms } + LIE.sumOf { it.first } }
        var t = Math.floorMod(clockMs, legs.sum())
        var n = 0
        while (t >= legs[n]) { t -= legs[n]; n++ }
        val (sx, sy) = SPOTS[n]
        if (t < NAPS[n]) return At(sx, sy, spotYaw(n), "sleep", 0)
        t -= NAPS[n]
        fun steps(list: List<Pair<Long, String>>, x: Double, y: Double, yaw: Double): At? {
            for ((ms, key) in list) {
                if (t < ms) return At(x, y, yaw, key, if ('>' in key) (t * 8 / ms).toInt().coerceIn(0, 8) else 0)
                t -= ms
            }
            return null
        }
        steps(WAKE, sx, sy, spotYaw(n))?.let { return it }
        // the walk runs on through the corners and the turns, one step after the other
        var walked = 0L
        for (m in MOVES[n]) {
            if (t < m.ms) {
                val f = t.toDouble() / m.ms
                return At(m.x0 + (m.x1 - m.x0) * f, m.y0 + (m.y1 - m.y0) * f, m.yaw0 + (m.yaw1 - m.yaw0) * f, "walk", Math.floorMod(((walked + t) / STEP).toInt(), 8), (n + 1) % SPOTS.size)
            }
            t -= m.ms
            walked += m.ms
        }
        val (ex, ey) = SPOTS[(n + 1) % SPOTS.size]
        val lie = spotYaw((n + 1) % SPOTS.size)
        return steps(LIE, ex, ey, lie) ?: At(ex, ey, lie, "sleep", 0)
    }

    /** The cat at [a], drawn in the background when first wanted (null until then); [slot] as [MapFigure.slot]. */
    fun frame(a: At, slot: Int): PixelImage? {
        // the steps of the walk are drawn ahead in all directions it walks and turns through; until a picture is ready the
        // last one stays, so the cat never blinks out for a frame (87.1, test of 0.1.740: it flickered as it walked)
        if (!warmed) {
            warmed = true
            for (sl in walkSlots()) for (k in 0 until 8) draw("walk", k, sl)
        }
        // while it sleeps, the waking up is drawn; while it walks, the lying down; so no step of them comes too late (294,
        // as the dog in 293: drawn only when wanted, it lay and was all at once sitting)
        if (a.key == "sleep" && slot != wakeDrawn) { wakeDrawn = slot; ahead(WAKE, slot) }
        if (a.key == "walk") MapFigure.slot(spotYaw(a.next)).let { if (it != lieDrawn) { lieDrawn = it; ahead(LIE, it) } }
        val img = shelf.picture(key(a, slot)) { render(poseOf(a.key, a.k), slot * 360.0 / MapFigure.YAWS) }
        if (img != null) last = img
        return img ?: last
    }
    @Volatile private var warmed = false
    @Volatile private var wakeDrawn = -1
    @Volatile private var lieDrawn = -1
    @Volatile private var last: PixelImage? = null

    /** The cat's own pictures, so the others' do not push them out: the walk and, for each spot, waking and lying down (about 250). */
    const val SHELF = 400
    private val shelf = MapRest.Shelf(SHELF)
    private fun key(a: At, slot: Int) = "cat|${a.key}|${a.k}|$slot"
    private fun draw(key: String, k: Int, slot: Int) = shelf.picture("cat|$key|$k|$slot") { render(poseOf(key, k), slot * 360.0 / MapFigure.YAWS) }
    private fun ahead(list: List<Pair<Long, String>>, slot: Int) {
        for ((_, key) in list) for (k in 0..(if ('>' in key) 8 else 0)) draw(key, k, slot)
    }
    /** The directions of the walk: the four along the ways and those it turns through on the spot (294). */
    private fun walkSlots(): Set<Int> = (0 until MapFigure.YAWS step MapFigure.YAWS / 4).toSet() +
        MOVES.flatten().filter { it.yaw0 != it.yaw1 }.flatMap { m -> (0..32).map { i -> MapFigure.slot(m.yaw0 + (m.yaw1 - m.yaw0) * i / 32) } }

    /** The same, drawn now (the previews). */
    fun frameNow(a: At, slot: Int): PixelImage =
        shelf.pictureNow(key(a, slot)) { render(poseOf(a.key, a.k), slot * 360.0 / MapFigure.YAWS) }

    /** The picture's size and where the paws stand in it. */
    const val W = 48; const val H = 40; const val AX = 24; const val GY = 32

    /** The cat in pose [p] facing [yaw], in a [w] × [h] picture with the paws on [ground] at [anchorX]. */
    fun render(p: Pose, yaw: Double, w: Int = 48, h: Int = 40, anchorX: Double = 24.0, ground: Double = 32.0, px: Double = 0.55, pitch: Double = 38.0): PixelImage {
        val (so, g) = solids(p)
        val img = SdfRender.render(so, g, { s, _ -> s.mat!! }, w, h, anchorX, ground, px, yaw, pitch)
        val s = Sculpt(w, h)
        for (y in 0 until h) for (x in 0 until w) s.img.set(x, y, img.img[x, y])
        s.outline(argb(0x100A0C))
        return s.img
    }
}
