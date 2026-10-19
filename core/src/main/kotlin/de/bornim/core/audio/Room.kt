package de.bornim.core.audio

import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.roundToInt

/**
 * The room a sound is heard in (119, Idee 8): the same sword stroke rings on in the cave, stays close and muffled in the
 * inn and is dry under the open sky. Computed from the dry sound (a small Freeverb: early echoes off the walls, eight
 * damped feedback combs, four allpasses), so every take keeps its own character and nothing new is recorded.
 * Ambience and steps carry their place already; system sounds stay one and the same everywhere ([affects]).
 */
object Room {
    /**
     * How a kind of place answers: [predelayMs] until the first echo, [echoes] off near walls (ms, gain), the tail's
     * reverberation time [rt60] (seconds to fall by 60 dB), [damp] (0..1, how fast the highs die in it), [wet] the
     * tail's level, [muffle] a gentle low pass on the whole sound (soft walls, cloth and wood), 0 for none.
     */
    class Acoustics(
        val predelayMs: Double,
        val echoes: List<Pair<Double, Double>>,
        val rt60: Double,
        val damp: Double,
        val wet: Double,
        val muffle: Double = 0.0,
    )

    /** The answer of each kind of place; null = dry (outside: nothing to throw the sound back). */
    fun acoustics(kind: PlaceSound.Kind): Acoustics? = when (kind) {
        PlaceSound.Kind.OUTSIDE -> null
        // rock all around: late, distinct echoes, a long dark tail
        PlaceSound.Kind.CAVE -> Acoustics(28.0, listOf(43.0 to 0.32, 71.0 to 0.24, 109.0 to 0.18, 151.0 to 0.12), 2.2, 0.55, 0.42)
        // the temple's stone hall: bright and long, but no cave
        PlaceSound.Kind.HALL -> Acoustics(18.0, listOf(23.0 to 0.2, 37.0 to 0.15), 1.5, 0.3, 0.3)
        // the inn: low beams, wood, cloth and people: close, short, muffled
        PlaceSound.Kind.TAVERN -> Acoustics(4.0, listOf(7.0 to 0.18, 13.0 to 0.12), 0.38, 0.75, 0.2, muffle = 0.25)
        // a small room in a house
        PlaceSound.Kind.ROOM -> Acoustics(3.0, listOf(5.0 to 0.15, 9.0 to 0.1), 0.3, 0.7, 0.16, muffle = 0.15)
    }

    /**
     * Whether [s] takes on the room: what happens there (blows, spells, coins, a door, the people's cups). Not the system
     * sounds (one take, the same everywhere), not ambience and loops (recorded in their own space: wind, hall, drops,
     * birds, the fire's crackle), not the steps (cut with their room already, 74) nor the heartbeat (inside the hero).
     */
    fun affects(s: Sound): Boolean = s !in Sfx.SYSTEM && s !in UNTOUCHED

    private val UNTOUCHED = setOf(
        Sound.WIND, Sound.HALL, Sound.DRIP, Sound.CRACKLE, Sound.BIRD, Sound.CRICKET, Sound.OWL, Sound.THUNDER, Sound.HEARTBEAT,
        Sound.FROG, Sound.FROG_CHORUS, Sound.DRAGONFLY, Sound.HEN_CLUCK, Sound.HEN_SCRATCH, Sound.HEN_ALARM, Sound.HEN_FLAP,
        Sound.STEP_GRASS, Sound.STEP_EARTH, Sound.STEP_COBBLE, Sound.STEP_WOOD, Sound.STEP_STONE,
        Sound.HOWL,
        // the rain's loop (D3.10) and the monsters' idle sounds on the map (D3.9): dry, as tested in builds 9 and 10
        Sound.RAIN,
        // the call of someone with news (134.3): close by, dry like the hens
        Sound.HAIL_MAN, Sound.HAIL_WOMAN, Sound.HAIL_CHILD,
    ) + MonsterIdle.SOUNDS

    /** Only in houses: the people's cups and chairs, the wood of the room. */
    val INDOOR_ONLY = setOf(Sound.CUP, Sound.POUR, Sound.WIPE, Sound.CHAIR, Sound.COUGH, Sound.CREAK)

    /** The sounds that need a version for [kind]: none outside; the inn's own only in houses. */
    fun soundsFor(kind: PlaceSound.Kind): List<Sound> = if (acoustics(kind) == null) emptyList() else
        Sound.entries.filter { affects(it) && (it !in INDOOR_ONLY || kind == PlaceSound.Kind.TAVERN || kind == PlaceSound.Kind.ROOM) }

    /** The places that answer: one version of the sounds each. */
    val ROOMS = PlaceSound.Kind.entries.filter { acoustics(it) != null }

    /**
     * The recordings heard in [kind], as asset paths of the dry files: the recorded sounds of [soundsFor] and the
     * creatures' voices. Their room versions lie at [file].
     */
    fun recordingsFor(kind: PlaceSound.Kind): List<String> = if (acoustics(kind) == null) emptyList() else
        soundsFor(kind).flatMap { s -> (0 until (Recorded.TAKES[s] ?: 0)).map { Recorded.file(s, it) } } +
            Recorded.VOICES.flatMap { v -> Recorded.Cue.entries.flatMap { c -> (0 until Recorded.VOICE_TAKES).map { Recorded.voiceFile(v, c, it) } } }

    /** Where the version of the recording [asset] (sfx/…) for [kind] lies, made by the preview (RAUMKLANG=spiel). */
    fun file(kind: PlaceSound.Kind, asset: String) = "raum/${kind.name.lowercase()}/${asset.substringAfterLast('/')}"

    /** The longest the tail is kept (it is below hearing long before its full [Acoustics.rt60]). */
    private const val MAX_TAIL = 1.8

    /** The highest peak (just under full scale). */
    const val LIMIT = 0.99

    /** [pcm] (16-bit mono at [rate] Hz) as heard in [kind]: longer by its tail, never past full scale. */
    fun apply(pcm: ShortArray, rate: Int, kind: PlaceSound.Kind): ShortArray {
        val a = acoustics(kind) ?: return pcm
        val x = DoubleArray(pcm.size) { pcm[it] / 32768.0 }
        return toPcm(process(x, rate, a))
    }

    /** The same on samples in -1..1. */
    fun process(dryIn: DoubleArray, rate: Int, a: Acoustics): DoubleArray {
        val tail = (minOf(a.rt60 * 0.8, MAX_TAIL) * rate).toInt()
        val n = dryIn.size + tail
        val dry = DoubleArray(n).also { dryIn.copyInto(it) }
        if (a.muffle > 0) onePoleLow(dry, a.muffle)
        val s = rate / 44100.0
        val pre = (a.predelayMs * rate / 1000).roundToInt()
        // what reaches the walls: the dry sound, delayed, a little darker
        val send = DoubleArray(n)
        for (i in pre until n) send[i] = dry[i - pre]
        onePoleLow(send, 0.2 + 0.5 * a.damp)
        val out = DoubleArray(n)
        // early echoes off the near walls
        for ((ms, g) in a.echoes) {
            val d = (ms * rate / 1000).roundToInt()
            for (i in d until n) out[i] += g * send[i - d]
        }
        // the late tail: eight damped combs in parallel, then four allpasses to smear it
        val late = DoubleArray(n)
        for (len in COMBS) {
            val d = maxOf(1, (len * s).roundToInt())
            val g = 10.0.pow(-3.0 * d / rate / a.rt60)
            val buf = DoubleArray(d); var k = 0; var lp = 0.0
            for (i in 0 until n) {
                val y = buf[k]
                lp = y * (1 - a.damp) + lp * a.damp
                buf[k] = send[i] + lp * g
                late[i] += y
                if (++k == d) k = 0
            }
        }
        for (len in ALLPASSES) {
            val d = maxOf(1, (len * s).roundToInt())
            val buf = DoubleArray(d); var k = 0
            for (i in 0 until n) {
                val b = buf[k]
                val y = -late[i] + b
                buf[k] = late[i] + b * 0.5
                late[i] = y
                if (++k == d) k = 0
            }
        }
        val lateGain = a.wet / COMBS.size * 1.6
        for (i in 0 until n) out[i] = dry[i] + a.wet * out[i] + lateGain * late[i]
        // the end of the kept tail fades out instead of breaking off
        val fade = minOf(tail, (0.25 * rate).toInt())
        for (j in 0 until fade) out[n - 1 - j] *= j.toDouble() / fade
        // never past full scale: where the echoes pile up on the sound, all of it comes down a little
        val peakOut = out.maxOfOrNull { abs(it) } ?: 0.0
        if (peakOut > LIMIT) { val k = LIMIT / peakOut; for (i in 0 until n) out[i] *= k }
        return out
    }

    /** One-pole low pass in place: [amount] 0 = untouched, towards 1 = darker. */
    private fun onePoleLow(x: DoubleArray, amount: Double) {
        var z = 0.0
        for (i in x.indices) { z = x[i] * (1 - amount) + z * amount; x[i] = z }
    }

    private fun toPcm(x: DoubleArray) = ShortArray(x.size) { (x[it] * 32767).roundToInt().coerceIn(-32768, 32767).toShort() }

    /** Freeverb's tunings at 44.1 kHz: lengths without a common divisor, so the tail does not ring. */
    private val COMBS = intArrayOf(1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617)
    private val ALLPASSES = intArrayOf(556, 441, 341, 225)

    /** The level in dB of [x] from [from] s on (RMS), for the tests. */
    fun levelDb(x: DoubleArray, rate: Int, from: Double, len: Double): Double {
        val a = (from * rate).toInt().coerceIn(0, x.size); val b = ((from + len) * rate).toInt().coerceIn(a, x.size)
        if (b <= a) return -200.0
        var e = 0.0; for (i in a until b) e += x[i] * x[i]
        return 10 * kotlin.math.log10(e / (b - a) + 1e-20)
    }
}
