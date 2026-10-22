package de.bornim.core.art

/**
 * The village dog (draft, `HUND=1`; D29.3, Prüfbericht Lauf 30): a shaggy brown dog that dozes in the east of
 * Bornim, on the grass by the square, before the shop and by the village road, now and then sits up wagging,
 * stretches and trots to the next spot. Built in the round like the inn's cat ([MapCat]), in cm (y up, z forward).
 */
object MapDog {
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
        /** The tail swung to the left (+) or right, in degrees: wagging. */
        val wag: Double = 0.0,
    ) {
        fun lerp(o: Pose, t: Double): Pose {
            fun l(a: Double, b: Double) = a + (b - a) * t
            return Pose(l(chestY, o.chestY), l(chestZ, o.chestZ), l(hipY, o.hipY), l(hipZ, o.hipZ), l(headY, o.headY), l(headZ, o.headZ), l(nod, o.nod),
                l(frontZ, o.frontZ), l(hindZ, o.hindZ), l(tuck, o.tuck), l(curl, o.curl), l(tailUp, o.tailUp), l(tailWrap, o.tailWrap), l(eyes, o.eyes),
                l(stride, o.stride), l(wag, o.wag))
        }
    }

    val STAND = Pose(34.0, 14.0, 34.0, -14.0, 48.0, 27.0, 12.0, 15.0, -15.0, 0.0, 0.0, 0.25, 0.0, 1.0)
    val SIT = Pose(33.0, 8.0, 12.0, -8.0, 50.0, 15.0, 6.0, 12.0, -2.0, 0.6, 0.0, -0.3, 0.6, 1.0)
    /** Lying flat, the head on the front paws, the tail round the side. */
    val SLEEP = Pose(10.0, 8.0, 10.0, -11.0, 8.0, 22.0, 18.0, 24.0, -6.0, 0.4, 0.5, -0.3, 1.0, 0.0)
    /** Lying like a sphinx, the head up and the eyes open: between sleeping and sitting, so it never pops up (293). */
    val REST = Pose(12.0, 9.0, 10.0, -11.0, 26.0, 21.0, 4.0, 24.0, -6.0, 0.4, 0.15, -0.3, 0.8, 1.0)
    /** The bow: front low with the paws reached far forward, the rump up. */
    val STRETCH = Pose(13.0, 17.0, 36.0, -13.0, 18.0, 31.0, -8.0, 36.0, -16.0, 0.0, 0.0, 0.45, 0.0, 0.6)

    private val fur = Mat(Ramp.of(argb(0x8A5E36)), grain = 0.2)
    private val dark = Mat(Ramp.of(argb(0x4E3220)), grain = 0.18)
    private val pale = Mat(Ramp.of(argb(0xD8C29C)), grain = 0.12)
    private val nose = Mat(Ramp.of(argb(0x1C1412)), shine = 0.7)
    private val eye = Mat(Ramp.of(argb(0x2E1C10)), shine = 1.0, bias = 0.2)
    private val lid = Mat(Ramp.of(argb(0x3E2818)), grain = 0.1)

    private const val BODY = 0; private const val HEAD = 1; private const val TAIL = 2; private const val DETAIL = 3
    /** Life size: a dog knee-high to the hero reads well at map size. */
    const val SIZE = 1.0

    fun solids(p: Pose): Pair<List<Solid>, Groups> {
        val k = SIZE
        val out = mutableListOf<Solid>()
        fun add(s: Solid, m: Mat): Solid { s.mat = m; out += s; return s }
        // curling bends the body round a point to its left: the chest swings left and back, the hips left and forward
        fun bend(x: Double, y: Double, z: Double): P3 {
            val a = Math.toRadians(p.curl * 60.0) * (z / 15.0)
            return P3((x * kotlin.math.cos(a) - z * kotlin.math.sin(a) * 0.9) - p.curl * 4.0 * (z / 15.0).let { it * it }, y, z * kotlin.math.cos(a) + x * kotlin.math.sin(a)) * k
        }
        fun ell(c: P3, rx: Double, ry: Double, rz: Double, m: Mat, g: Int, f: Frame = Frame.IDENTITY) = add(Ellipsoid(c, P3(rx * k, ry * k, rz * k), f, BodyPart.TORSO, g), m)
        fun cone(a: P3, b: P3, ra: Double, rb: Double, m: Mat, g: Int) = add(RoundCone(a, b, ra * k, rb * k, BodyPart.ARM, g), m)

        // ---- the body: deep chest, lean haunch, joined by the back; a pale breast and a darker saddle
        val chest = bend(0.0, p.chestY, p.chestZ)
        val hip = bend(0.0, p.hipY, p.hipZ)
        cone(chest, hip, 9.5, 8.6, fur, BODY)
        ell(chest, 9.2, 10.6, 9.6, fur, BODY)
        ell(hip, 8.6, 9.0, 9.4, fur, BODY)
        ell(chest + P3(0.0, -2.0 * k, 6.0 * k), 6.0, 7.4, 4.2, pale, BODY)
        val along = (chest - hip).norm()
        val across = (P3.Y cross along).norm()
        ell(chest + (hip - chest) * 0.5 + P3(0.0, 7.6 * k, 0.0), 6.8, 2.4, 13.0, dark, DETAIL, Frame(across, (along cross across).norm(), along))

        // ---- the legs: long, with pale paws; tucked under the body when it lies
        val t = p.tuck
        for (s in listOf(-1.0, 1.0)) {
            val sh = bend(s * 5.0, p.chestY - 4.0, p.chestZ + 2.0)
            val fpaw = bend(s * 4.2, 1.8, p.frontZ - s * p.stride) * (1.0 - t * 0.4) + (sh + P3(0.0, -6.0 * k, 6.0 * k)) * (t * 0.4)
            cone(sh, fpaw + P3(0.0, 1.6 * k, 0.0), 3.0, 2.0, fur, BODY)
            ell(fpaw + P3(0.0, 0.4 * k, 1.0 * k), 2.3, 1.7, 3.0, pale, BODY)
            val hh = bend(s * 5.4, p.hipY - 2.0, p.hipZ - 1.0)
            val hpaw = bend(s * 4.6, 1.8, p.hindZ + s * p.stride) * (1.0 - t * 0.5) + (hh + P3(s * 2.0 * k, -6.0 * k, 7.0 * k)) * (t * 0.5)
            // the thigh as a flat haunch, the hock bent back, then down to the paw
            ell(hh + P3(s * 1.8 * k, -2.0 * k, 0.0), 3.6, 7.6, 6.4, fur, BODY)
            val hock = hh + (hpaw - hh) * 0.6 + P3(0.0, 0.0, -4.0 * k * (1.0 - t))
            cone(hh + P3(s * 2.0 * k, -6.0 * k, 0.0), hock, 2.8, 1.9, fur, BODY)
            cone(hock, hpaw + P3(0.0, 1.6 * k, 0.0), 1.9, 1.8, fur, BODY)
            ell(hpaw + P3(0.0, 0.4 * k, 1.2 * k), 2.3, 1.7, 3.2, pale, BODY)
        }

        // ---- the head: broad skull, long muzzle with a black nose, ears hanging at the sides
        val neck = bend(0.0, p.chestY + 4.0, p.chestZ + 5.0)
        val head = bend(p.curl * -3.0, p.headY, p.headZ)
        cone(neck, head, 6.4, 5.0, fur, BODY)
        val nod = Rot.pitch(p.nod) * Rot.yaw(p.curl * -40.0)
        val hx = nod.apply(P3.X); val hy = nod.apply(P3.Y); val hz = nod.apply(P3.Z)
        val hf = Frame(hx, hy, hz)
        fun h(x: Double, y: Double, z: Double) = head + (hx * x + hy * y + hz * z) * k
        ell(h(0.0, 0.0, 0.0), 6.8, 6.2, 6.8, fur, HEAD, hf)
        cone(h(0.0, -1.6, 3.0), h(0.0, -2.4, 10.0), 3.6, 2.4, fur, HEAD)
        ell(h(0.0, -3.6, 7.6), 2.6, 1.4, 3.0, pale, HEAD, hf)
        add(Ellipsoid(h(0.0, -1.6, 12.2), P3(1.3 * k, 1.0 * k, 0.9 * k), hf, BodyPart.HEAD, DETAIL), nose)
        for (s in listOf(-1.0, 1.0)) {
            // the ears: flat flaps from the top of the skull, hanging down beside the cheeks
            ell(h(s * 6.2, -0.6, -0.6), 1.3, 5.4, 3.4, dark, HEAD, Frame((hx * 1.0 + hy * (s * 0.25)).norm(), (hy - hx * (s * 0.25)).norm(), hz))
            if (p.eyes > 0.5) add(Ellipsoid(h(s * 2.6, 1.6, 4.8), P3(0.9 * k, 0.8 * k, 0.5 * k), hf, BodyPart.HEAD, DETAIL), eye)
            else add(Ellipsoid(h(s * 2.6, 1.5, 4.9), P3(0.9 * k, 0.22 * k, 0.4 * k), hf, BodyPart.HEAD, DETAIL), lid)
        }

        // ---- the tail: from the rump, carried up in a curve or laid along the ground, wagging from side to side
        val base = bend(0.0, p.hipY + 3.0, p.hipZ - 8.0)
        var prev = base
        var dir = Rot.yaw(p.wag).apply(P3(0.0, p.tailUp, -1.0).norm())
        for (i in 1..5) {
            // a raised tail goes up and curves over at the tip; a low one droops to the ground
            dir = Rot.yaw(p.tailWrap * 24.0 + p.wag * 0.15).apply(dir).let { if (p.tailUp < 0.3) P3(it.x, it.y - 0.15, it.z).norm() else if (i >= 3) P3(it.x, it.y - 0.12, it.z).norm() else it }
            var next = prev + dir * (3.8 * k)
            if (next.y < 1.8 * k) next = P3(next.x, 1.8 * k, next.z)
            cone(prev, next, 2.4 - i * 0.2, 2.2 - i * 0.2, if (i == 5) pale else fur, TAIL)
            prev = next
        }

        val g = Groups(4)
        g.reach = 10.0 * k
        g.set(BODY, 3.4 * k)
        g.set(HEAD, 1.2 * k, BODY, head)
        g.set(TAIL, 0.8 * k, BODY, base)
        g.set(DETAIL, 0.0)
        return out to g
    }

    // ---------------------------------------------------------------- the dog's day in the village

    /** Where it lies, in tiles of the village: on the grass north-east of the square, before the shop, by the road north of the square (in the open, not under the crowns at the edge). */
    internal val SPOTS = listOf(24.0 to 10.0, 30.0 to 7.0, 19.0 to 9.0)
    /** The way from each spot to the next (corners in tiles, the spot last), over open ground and the road. */
    internal val WAYS = listOf(listOf(24.0 to 8.0, 30.0 to 8.0, 30.0 to 7.0), listOf(30.0 to 8.0, 19.0 to 8.0, 19.0 to 9.0), listOf(24.0 to 9.0, 24.0 to 10.0))
    /** How long it dozes at each spot, in ms. */
    private val NAPS = listOf(60_000L, 35_000L, 45_000L)
    /**
     * Waking up: lift the head and look about, sit up, sit wagging a while, get up, bow and back, then off. The wagging
     * lasts whole sweeps, so the tail is straight again when it gets up (293: before, it lay and was all at once sitting).
     */
    private val WAKE = listOf(900L to "sleep>rest", 700L to "rest", 1100L to "rest>sit", 3920L to "wag", 900L to "sit>stand", 1200L to "stand>stretch", 1000L to "stretch>stand", 300L to "stand")
    /** Lying down at the new spot: sit, wag, lie down with the head up, then lay it on the paws. */
    private val LIE = listOf(1000L to "stand>sit", 2240L to "wag", 1100L to "sit>rest", 900L to "rest", 1300L to "rest>sleep")
    /** Tiles a second at an easy trot. */
    private const val SPEED = 1.6
    /** One picture of the trot or the wagging, in ms; a half stride, after which the paws are side by side again. */
    private const val STEP = 70L
    private const val HALF = STEP * MapFigure.STEPS / 2
    /** Blends go in this many steps, eased in and out. */
    const val BLEND = 16
    /** Turning on the spot, ms a degree. */
    private const val TURN = 6.0

    /** Where the dog is and how it looks: [x], [y] in tiles, facing map direction [yaw], in pose [key] blended [k] of [BLEND] (of 8 in the trot and the wagging); trotting, it heads for spot [next]. */
    data class At(val x: Double, val y: Double, val yaw: Double, val key: String, val k: Int, val next: Int = 0)

    private fun pose(name: String) = when (name) { "sleep" -> SLEEP; "rest" -> REST; "sit" -> SIT; "stand" -> STAND; "stretch" -> STRETCH; else -> STAND }

    /** The pose for [key] ("sit", "sleep>sit") at step [k] of [BLEND], or a step [k] of 8 of the trot ("walk") or the wagging ("wag"). */
    fun poseOf(key: String, k: Int): Pose {
        val a = k / 8.0 * 2 * Math.PI
        return when {
            key == "walk" -> STAND.copy(stride = 6.0 * kotlin.math.sin(a), chestY = STAND.chestY + 0.8 * kotlin.math.abs(kotlin.math.cos(a)), wag = 14.0 * kotlin.math.sin(a))
            key == "wag" -> SIT.copy(wag = 32.0 * kotlin.math.sin(a))
            '>' in key -> key.split('>').let { (x, y) -> val f = k.toDouble() / BLEND; pose(x).lerp(pose(y), f * f * (3 - 2 * f)) }
            else -> pose(key)
        }
    }

    /** The turn from [from] to [to] the short way round, in degrees. */
    private fun turn(from: Double, to: Double) = Math.floorMod((to - from).toLong() + 540L, 360L) - 180.0
    /** How long a turn of [deg] takes: whole half strides, so it ends with the paws together. */
    private fun turnMs(deg: Double, perDeg: Double = TURN) = maxOf(HALF, Math.round(kotlin.math.abs(deg) * perDeg / HALF) * HALF)

    /** The yaw it lies with at spot [n], looking out over the road. */
    private fun spotYaw(n: Int) = 300.0 - n * 50.0
    private fun dir(x: Double, y: Double, tx: Double, ty: Double) = when { tx > x -> 90.0; tx < x -> 270.0; ty > y -> 0.0; else -> 180.0 }

    /** The trot from spot [n] to the next: turning off, the straight stretches with a turn at each corner, turning to lie; each (ms, from yaw, to yaw, from, to). */
    private class Move(val ms: Long, val yaw0: Double, val yaw1: Double, val x0: Double, val y0: Double, val x1: Double, val y1: Double)
    private val MOVES: List<List<Move>> = SPOTS.indices.map { n ->
        val way = WAYS[n]
        var x = SPOTS[n].first; var y = SPOTS[n].second
        val dist = way.fold(Triple(x, y, 0.0)) { (px, py, d), (tx, ty) -> Triple(tx, ty, d + kotlin.math.abs(tx - px) + kotlin.math.abs(ty - py)) }.third
        // the whole trot lasts whole half strides, so it stops with the paws together
        val walkMs = maxOf(HALF, Math.round(dist / SPEED * 1000 / HALF) * HALF)
        val out = mutableListOf<Move>()
        var yaw = spotYaw(n)
        var used = 0L
        for ((i, p) in way.withIndex()) {
            val (tx, ty) = p
            val d = kotlin.math.abs(tx - x) + kotlin.math.abs(ty - y)
            val ms = if (i == way.lastIndex) walkMs - used else Math.round(walkMs * d / dist)
            used += ms
            // turning off from the spot slowly, at the corners briskly
            val to = yaw + turn(yaw, dir(x, y, tx, ty))
            if (to != yaw) out += Move(turnMs(to - yaw, if (i == 0) TURN else TURN / 2), yaw, to, x, y, x, y)
            out += Move(ms, to, to, x, y, tx, ty)
            yaw = to; x = tx; y = ty
        }
        val lie = spotYaw((n + 1) % SPOTS.size)
        if (turn(yaw, lie) != 0.0) out += Move(turnMs(turn(yaw, lie)), yaw, yaw + turn(yaw, lie), x, y, x, y)
        out
    }

    /** The dog at [clockMs]: one round of all spots, again and again. */
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
                if (t < ms) return At(x, y, yaw, key, when { '>' in key -> (t * BLEND / ms).toInt().coerceIn(0, BLEND); key == "wag" -> Math.floorMod((t / STEP).toInt(), 8); else -> 0 })
                t -= ms
            }
            return null
        }
        steps(WAKE, sx, sy, spotYaw(n))?.let { return it }
        // the trot runs on through the corners and the turns, one step after the other
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

    /**
     * The dog's own pictures, so the villagers' breathing does not push them out: the trot in four directions and,
     * for each spot, every step of waking and lying down (about 550 of 64 × 56, 14 KB each).
     */
    const val SHELF = 700
    private val shelf = MapRest.Shelf(SHELF)
    private fun key(a: At, slot: Int) = "dog|${a.key}|${a.k}|$slot"
    private fun draw(key: String, k: Int, slot: Int) = shelf.picture("dog|$key|$k|$slot") { render(poseOf(key, k), slot * 360.0 / MapFigure.YAWS) }
    /** The directions of the trot: the four along the ways and those it turns through on the spot (294). */
    private fun walkSlots(): Set<Int> = (0 until MapFigure.YAWS step MapFigure.YAWS / 4).toSet() +
        MOVES.flatten().filter { it.yaw0 != it.yaw1 }.flatMap { m -> (0..32).map { i -> MapFigure.slot(m.yaw0 + (m.yaw1 - m.yaw0) * i / 32) } }
    /** All the pictures of [list] facing [slot]. */
    private fun ahead(list: List<Pair<Long, String>>, slot: Int) {
        for ((_, key) in list) for (k in 0..(when { '>' in key -> BLEND; key == "wag" -> 7; else -> 0 })) draw(key, k, slot)
    }

    /** The dog at [a], drawn in the background when first wanted (null until then); [slot] as [MapFigure.slot]. */
    fun frame(a: At, slot: Int): PixelImage? {
        // the steps of the trot are drawn ahead in all four directions and every direction it turns through; until a picture is ready the last one stays,
        // so the dog never blinks out for a frame (as the cat, 87.1)
        if (!warmed) {
            warmed = true
            for (sl in walkSlots()) for (k in 0 until 8) draw("walk", k, sl)
        }
        // while it dozes, the waking up is drawn; while it trots, the lying down; so no step of them is missed (293:
        // drawn only when wanted, they came too late and the dog sat up at one go)
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

    /** The same, drawn now (the previews). */
    fun frameNow(a: At, slot: Int): PixelImage =
        shelf.pictureNow(key(a, slot)) { render(poseOf(a.key, a.k), slot * 360.0 / MapFigure.YAWS) }

    /** The picture's size and where the paws stand in it. */
    const val W = 64; const val H = 56; const val AX = 32; const val GY = 44

    /** The dog in pose [p] facing [yaw], in a [w] × [h] picture with the paws on [ground] at [anchorX]. */
    fun render(p: Pose, yaw: Double, w: Int = W, h: Int = H, anchorX: Double = AX.toDouble(), ground: Double = GY.toDouble(), px: Double = 0.55, pitch: Double = 38.0): PixelImage {
        val (so, g) = solids(p)
        val img = SdfRender.render(so, g, { s, _ -> s.mat!! }, w, h, anchorX, ground, px, yaw, pitch)
        val s = Sculpt(w, h)
        for (y in 0 until h) for (x in 0 until w) s.img.set(x, y, img.img[x, y])
        s.outline(argb(0x100A0C))
        return s.img
    }
}
