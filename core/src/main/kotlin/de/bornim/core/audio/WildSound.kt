package de.bornim.core.audio

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.art.MapBirds
import de.bornim.core.art.WorldArt
import kotlin.math.hypot
import kotlin.random.Random

/**
 * What lives at a place but is not in sight (84, D3.15; DESIGN-STIL.md, Klang, „Ausnahme Umweltklang“): the small life
 * heard now and then (birds by day, crickets and owls at night), and far off, rarely, from one side: a wolf in the deep
 * forest (they howl on after Grimmzahn's death, looking for a new leader), a rumble deep in the mountain in the cave.
 * No birds in the deep forest (D3.2): there by day only the wind, and now and then a wolf.
 */
object WildSound {
    enum class Kind { NONE, VILLAGE, WOOD, DEEP_WOOD, CAVE }

    fun kindOf(map: MapDef): Kind = when {
        map.id == "deep_forest" -> Kind.DEEP_WOOD
        map.kind == MapKind.FOREST -> Kind.WOOD
        map.kind == MapKind.TOWN -> Kind.VILLAGE
        map.kind == MapKind.CAVE -> Kind.CAVE
        else -> Kind.NONE
    }

    /** The small life: a pause of 5–13 s between, quiet. */
    const val LIFE_MIN_MS = 5000L
    const val LIFE_SPAN_MS = 8000L
    const val LIFE_VOLUME = 0.3f

    /** The sound of small life to play now, if any. */
    fun life(kind: Kind, night: Boolean, raining: Boolean, rnd: Random): Sound? = when (kind) {
        Kind.VILLAGE, Kind.WOOD -> when {
            raining -> null
            night -> if (kind == Kind.WOOD && rnd.nextInt(3) == 0) Sound.OWL else Sound.CRICKET
            else -> Sound.BIRD
        }
        // no birds under the old oaks, no owl either; crickets at night
        Kind.DEEP_WOOD -> if (!raining && night) Sound.CRICKET else null
        else -> null
    }

    /**
     * D29.1: the small life is not in sight, so it has no distance, but like every sound of a place it comes from one
     * side (DESIGN-STIL.md, „aus einer Richtung“) and is never twice the same loudness.
     */
    fun lifeVolume(rnd: Random): Float = LIFE_VOLUME * (0.75f + rnd.nextFloat() * 0.5f)

    /** The far sound of a place: a wolf in the deep forest, the mountain rumbling in the cave; none elsewhere. */
    fun far(kind: Kind): Sound? = when (kind) {
        Kind.DEEP_WOOD -> Sound.WOLF_FAR
        Kind.CAVE -> Sound.RUMBLE
        else -> null
    }

    /** The first far sound comes 20–60 s after arriving, so it is never the first thing heard. */
    fun firstFarMs(rnd: Random) = 20_000L + rnd.nextLong(40_000L)

    /** Rare: a wolf every 1–2½ minutes at night, half as often by day; the mountain every 1–3 minutes. */
    fun farGapMs(kind: Kind, night: Boolean, rnd: Random): Long = when (kind) {
        Kind.DEEP_WOOD -> if (night) 60_000L + rnd.nextLong(90_000L) else 120_000L + rnd.nextLong(180_000L)
        else -> 60_000L + rnd.nextLong(120_000L)
    }

    /** Quiet: far off, each a little different. */
    fun farVolume(s: Sound, rnd: Random): Float = when (s) {
        Sound.WOLF_FAR -> 0.22f + rnd.nextFloat() * 0.1f
        else -> 0.3f + rnd.nextFloat() * 0.1f
    }

    /** From one side: where it comes from, -1 left to 1 right, never straight ahead. */
    fun side(rnd: Random): Float = (0.35f + rnd.nextFloat() * 0.5f) * (if (rnd.nextBoolean()) 1 else -1)

    /** The volumes of the left and right speaker for [volume] from [side]: the far one quieter, never silent. */
    fun speakers(volume: Float, side: Float): Pair<Float, Float> {
        val s = side.coerceIn(-1f, 1f)
        return volume * (1f - 0.8f * maxOf(0f, s)) to volume * (1f - 0.8f * maxOf(0f, -s))
    }

    /** The pecking birds (84): beyond this many tiles one is not heard; within [BIRD_NEAR] at its loudest. */
    const val BIRD_FAR = 5.0
    const val BIRD_NEAR = 1.5
    const val FLAP_MAX = 0.3f
    const val SCRATCH_MAX = 0.1f

    private fun smooth(dist: Double, max: Float): Float {
        if (dist >= BIRD_FAR) return 0f
        val t = ((BIRD_FAR - dist) / (BIRD_FAR - BIRD_NEAR)).coerceIn(0.0, 1.0)
        return (max * t * t * (3 - 2 * t)).toFloat()
    }

    /**
     * Listens to the pecking birds round the hero: wings when one is seen to fly up, now and then a scratch in the
     * grass as it hops (one hop in four), never two of the same bird at once.
     */
    class BirdEar(private val map: MapDef) {
        private val up = HashSet<Long>()
        private val hops = HashMap<Long, Long>()
        /** The first hearing only notes what the birds are doing: a bird already up as the hero comes is not heard. */
        private var primed = false

        /** What to play at [clock] ms with the hero's corner at map pixel ([heroX], [heroY]); birds [out] or not. */
        fun hear(clock: Long, heroX: Int, heroY: Int, out: Boolean): List<Pair<Sound, Float>> {
            if (!out) { up.clear(); hops.clear(); primed = false; return emptyList() }
            val quiet = !primed; primed = true
            val r = BIRD_FAR.toInt() + 1
            val cx = (heroX + 16) / WorldArt.T; val cy = (heroY + 16) / WorldArt.T
            val sounds = ArrayList<Pair<Sound, Float>>(2)
            for (ty in cy - r..cy + r) for (tx in cx - r..cx + r) {
                if (!MapBirds.at(map, tx, ty)) continue
                val key = tx.toLong() shl 32 or (ty.toLong() and 0xffffffffL)
                val d = hypot((MapBirds.x(tx, ty) - heroX - 16).toDouble(), (MapBirds.y(tx, ty) - heroY - 16).toDouble()) / WorldArt.T
                val flying = MapBirds.flee(tx, ty, heroX, heroY) > 0f
                if (flying) {
                    if (up.add(key) && !quiet) smooth(d, FLAP_MAX).let { if (it > 0.01f) sounds += Sound.BIRD_FLAP to it }
                    continue
                }
                up.remove(key)
                val hop = MapBirds.hop(tx, ty, clock)
                val was = hops.put(key, hop)
                if (!quiet && was != null && was != hop && MapBirds.hash(tx, ty, hop.toInt()) % 4 == 0)
                    smooth(d, SCRATCH_MAX).let { if (it > 0.01f) sounds += Sound.BIRD_SCRATCH to it }
            }
            return sounds.take(2)
        }
    }
}
