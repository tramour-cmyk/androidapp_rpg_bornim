package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

/**
 * Life at the forest pond (27.6): dragonflies over the water by day, frogs on the bank that leap
 * in when the hero comes close and climb back out once he has gone. Positions in map pixels; the
 * drawing is in the app (`WorldScreen`). Each place is found from the pond's own shore
 * ([MapGround.water]), so another pond gets its life without work by hand.
 */
object PondLife {
    /** On in the game since 27i (Nutzer 12.10.); the switch stays for the previews. */
    @Volatile var draft = true

    // ------------------------------------------------------------------ dragonflies

    /** Where a dragonfly is: map pixel ([x], [y]) of the water below it, [h] pixels above it, heading [dx]/[dy]. */
    class FlyAt(val x: Float, val y: Float, val h: Float, val dx: Float, val dy: Float, val wings: Float)

    /**
     * A dragonfly keeping to its stretch of water around ([cx], [cy]): it hangs in the air, then darts to a
     * new spot in a fraction of a second, and hangs again; now and then it turns on the spot.
     */
    class Fly(val cx: Float, val cy: Float, val seed: Int, val dark: Boolean, private val spots: List<Pair<Float, Float>>) {
        private val period = 2600L + seed % 1700

        private fun spot(i: Long): Pair<Float, Float> = spots[Math.floorMod(hash(i.toInt(), seed), spots.size)]

        fun at(clock: Long): FlyAt {
            val c = clock + seed * 37L
            val i = Math.floorDiv(c, period)
            val u = Math.floorMod(c, period) / period.toFloat()
            val (ax, ay) = spot(i - 1)
            val (bx, by) = spot(i)
            // the dart: a quick, eased dash in the first fifth, then hanging still with a tremble
            val dash = 0.18f
            val k = if (u < dash) (u / dash).let { it * it * (3 - 2 * it) } else 1f
            val t = clock / 1000f
            val tremble = if (u < dash) 0f else 0.6f
            val x = ax + (bx - ax) * k + sin(t * 7.3f + seed) * tremble
            val y = ay + (by - ay) * k + cos(t * 5.9f + seed) * tremble * 0.6f
            val h = 11f + 2.5f * sin(t * 1.3f + seed) + (if (u < dash) 3f * sin(u / dash * 3.14f) else 0f)
            // heading: along the dash; while hanging it keeps it, now and then swinging round a little
            var dx = bx - ax; var dy = by - ay
            if (hypot(dx, dy) < 1f) { dx = 1f; dy = 0f }
            val turn = if (u > 0.55f && hash(i.toInt(), seed, 3) % 3 == 0) 0.8f * ((u - 0.55f) / 0.45f).coerceIn(0f, 1f) else 0f
            val ca = cos(turn); val sa = sin(turn)
            val l = hypot(dx, dy)
            val hx = (dx * ca - dy * sa) / l; val hy = (dx * sa + dy * ca) / l
            return FlyAt(x, y, h, hx, hy, ((clock / 28) % 2).toFloat())
        }
    }

    // ------------------------------------------------------------------ frogs

    enum class Mood { SIT, LEAP, UNDER, SURFACE, SWIM, CLIMB }

    /** Where a frog is and what it does: on the bank, in the air, under water or swimming back. */
    class FrogAt(val x: Float, val y: Float, val lift: Float, val faceLeft: Boolean, val mood: Mood, val throat: Float, val ring: Float)

    /**
     * A frog on the bank at ([x], [y]); [wx]/[wy] is where it lands in the water. It sits and breathes,
     * swells its throat now and then (more at dusk), turns round once in a while; the hero within
     * [SHY] pixels and it leaps in. It comes back once he is [BACK] pixels off and some seconds have passed:
     * eyes at the surface, swimming to the bank, a hop out.
     */
    class Frog(val x: Float, val y: Float, val wx: Float, val wy: Float, val seed: Int) {
        private var mood = Mood.SIT
        private var since = Long.MIN_VALUE

        fun at(clock: Long, heroX: Float, heroY: Float, dusk: Boolean): FrogAt {
            if (since == Long.MIN_VALUE || clock < since) { mood = Mood.SIT; since = clock }
            val near = hypot(heroX - x, heroY - y)
            // the state moves on with time and the hero's distance; each step starts where the last one ended
            fun go(m: Mood, at: Long) { mood = m; since = at }
            when (mood) {
                Mood.SIT -> if (near < SHY) go(Mood.LEAP, clock)
                Mood.LEAP -> if (clock - since > LEAP) go(Mood.UNDER, since + LEAP)
                Mood.UNDER -> if (clock - since > 8000 && near > BACK) go(Mood.SURFACE, clock)
                Mood.SURFACE -> if (near < SHY) go(Mood.UNDER, clock) else if (clock - since > 2200) go(Mood.SWIM, since + 2200)
                Mood.SWIM -> if (near < SHY) go(Mood.UNDER, clock) else if (clock - since > SWIM) go(Mood.CLIMB, since + SWIM)
                Mood.CLIMB -> if (clock - since > LEAP) go(Mood.SIT, since + LEAP)
            }
            val dt = clock - since
            // which way it sits: towards the water mostly, turning round now and then (one of three ways a minute)
            val towardsWaterLeft = wx < x || (wx == x && wy > y)
            val turnSlot = Math.floorDiv(clock + seed * 211L, 17000L).toInt()
            val face = if (hash(turnSlot, seed, 9) % 3 == 0) !towardsWaterLeft else towardsWaterLeft
            return when (mood) {
                Mood.SIT -> {
                    // breathing: the throat pulses; now and then it swells for a croak (often at dusk)
                    val breath = 0.5f + 0.5f * sin(clock / 260f + seed)
                    val croakSlot = Math.floorDiv(clock + seed * 97L, 3100L).toInt()
                    val croak = hash(croakSlot, seed, 5) % (if (dusk) 2 else 7) == 0
                    val cu = Math.floorMod(clock + seed * 97L, 3100L) / 3100f
                    val swell = if (croak && cu < 0.35f) sin(cu / 0.35f * 3.14f) else 0f
                    FrogAt(x, y, 0f, face, Mood.SIT, 0.3f * breath + swell, 0f)
                }
                Mood.LEAP -> {
                    val u = dt / LEAP.toFloat()
                    FrogAt(x + (wx - x) * u, y + (wy - y) * u, 7f * sin(u * 3.14f), towardsWaterLeft, Mood.LEAP, 0f, 0f)
                }
                Mood.UNDER -> FrogAt(wx, wy, 0f, towardsWaterLeft, Mood.UNDER, 0f, dt / 1600f)
                Mood.SURFACE -> FrogAt(wx, wy, 0f, !towardsWaterLeft, Mood.SURFACE, 0f, dt / 1600f)
                Mood.SWIM -> {
                    val u = (dt / SWIM.toFloat()).let { it * it * (3 - 2 * it) }
                    // it swims to a spot just off the bank, then climbs out from there
                    val ex = x + (wx - x) * 0.35f; val ey = y + (wy - y) * 0.35f
                    FrogAt(wx + (ex - wx) * u, wy + (ey - wy) * u, 0f, !towardsWaterLeft, Mood.SWIM, 0f, (dt % 900) / 900f)
                }
                Mood.CLIMB -> {
                    val u = dt / LEAP.toFloat()
                    val ex = x + (wx - x) * 0.35f; val ey = y + (wy - y) * 0.35f
                    FrogAt(ex + (x - ex) * u, ey + (y - ey) * u, 4f * sin(u * 3.14f), !towardsWaterLeft, Mood.CLIMB, 0f, 0f)
                }
            }
        }
    }

    const val SHY = 44f
    const val BACK = 90f
    private const val LEAP = 380L
    private const val SWIM = 1800L

    // ------------------------------------------------------------------ the places

    class Life(val frogs: List<Frog>, val flies: List<Fly>)

    private val cache = HashMap<String, Life>()

    fun of(map: MapDef): Life = synchronized(cache) { cache.getOrPut(map.id) { find(map) } }

    private fun find(map: MapDef): Life {
        if (map.kind != MapKind.FOREST) return Life(emptyList(), emptyList())
        val T = WorldArt.T
        val water = mutableListOf<Pair<Int, Int>>()
        for (ty in 0 until map.height) for (tx in 0 until map.width) if (map.tile(tx, ty) == Tile.WATER) water += tx to ty
        if (water.isEmpty()) return Life(emptyList(), emptyList())
        val x0 = (water.minOf { it.first } - 1) * T; val x1 = (water.maxOf { it.first } + 2) * T
        val y0 = (water.minOf { it.second } - 1) * T; val y1 = (water.maxOf { it.second } + 2) * T
        fun w(x: Float, y: Float) = MapGround.water(map, x, y)
        // the bank: points on dry, walkable ground just off the water, with the water 12 pixels away
        val bank = mutableListOf<Frog>()
        val deep = mutableListOf<Pair<Float, Float>>()
        var y = y0.toFloat()
        while (y < y1) {
            var x = x0.toFloat()
            while (x < x1) {
                val here = w(x, y)
                val tile = map.tile((x / T).toInt(), (y / T).toInt())
                if (here > 0.68) deep += x to y
                if (here in 0.36..0.47 && tile != Tile.TREE && tile != Tile.WATER) {
                    // the way into the water: up the slope of the field
                    val gx = (w(x + 3, y) - w(x - 3, y)).toFloat(); val gy = (w(x, y + 3) - w(x, y - 3)).toFloat()
                    val gl = hypot(gx, gy)
                    if (gl > 1e-4f) {
                        val wx = x + gx / gl * 14f; val wy = y + gy / gl * 14f
                        if (w(wx, wy) > 0.58) bank += Frog(x, y, wx, wy, hash(x.toInt(), y.toInt(), 41))
                    }
                }
                x += 4f
            }
            y += 4f
        }
        // up to three frogs, well apart, chosen by a fixed lot
        val frogs = mutableListOf<Frog>()
        for (f in bank.sortedBy { it.seed }) {
            if (frogs.size >= 3) break
            if (frogs.all { hypot(it.x - f.x, it.y - f.y) > 40f }) frogs += f
        }
        // two dragonflies over open water, each with its own stretch to dart about in
        val flies = mutableListOf<Fly>()
        for ((n, p) in deep.sortedBy { hash(it.first.toInt(), it.second.toInt(), 43) }.withIndex()) {
            if (flies.size >= 2) break
            if (flies.any { hypot(it.cx - p.first, it.cy - p.second) < 44f }) continue
            val spots = deep.filter { hypot(it.first - p.first, it.second - p.second) < 26f }
            if (spots.size < 4) continue
            flies += Fly(p.first, p.second, hash(p.first.toInt(), p.second.toInt(), 44) % 5000, n % 2 == 1 || flies.size == 1, spots)
        }
        return Life(frogs, flies)
    }

    private fun hash(a: Int, b: Int, c: Int = 0): Int {
        var n = a * 374761393 + b * 668265263 + c * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7fffffff
    }
}
