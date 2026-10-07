package de.bornim.core.audio

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.pow
import kotlin.math.sin
import kotlin.random.Random

enum class Sound {
    CLICK, HIT_SLASH, HIT_PIERCE, HIT_SMASH, MISS, CRIT, BLOCK, BITE, ARROW,
    FIRE, MAGIC, HOLY, HEAL, BUFF, POISON, THROW, POTION,
    ENEMY_DOWN, HERO_DOWN, LEVEL_UP, LOOT, LOOT_EPIC, COINS, CHEST, DOOR, ENCOUNTER,
    ALERT, AMBUSH,
    BIRD, CRICKET, OWL, DRIP, CRACKLE,
    SWING, SWING_HEAVY,
    HOWL_1, HOWL_2, HOWL_3,
}

/** Synthesized sound effects, rendered once to 16-bit mono PCM. */
object Sfx {
    private const val SR = Synth.SAMPLE_RATE

    /** The variant being rendered: its pitch factor, seed offset and index, so each take sounds a little different. */
    private var vp = 1.0
    private var vs = 0
    private var vi = 0

    /** Battle sounds come in several takes, picked at random, so fights do not get monotonous. */
    private val VARIED = setOf(
        Sound.HIT_SLASH, Sound.HIT_PIERCE, Sound.HIT_SMASH, Sound.MISS, Sound.CRIT, Sound.BLOCK, Sound.BITE, Sound.ARROW,
        Sound.FIRE, Sound.MAGIC, Sound.HOLY, Sound.HEAL, Sound.BUFF, Sound.POISON, Sound.THROW, Sound.POTION,
        Sound.ENEMY_DOWN, Sound.HERO_DOWN, Sound.ENCOUNTER, Sound.ALERT, Sound.AMBUSH, Sound.SWING, Sound.SWING_HEAVY,
    )

    fun variants(s: Sound): Int = if (s in VARIED) 3 else 1

    /** Renders take [variant] of [s]. */
    @Synchronized
    fun render(s: Sound, variant: Int): ShortArray {
        vi = variant
        vp = listOf(1.0, 0.89, 1.12)[variant % 3]
        vs = variant * 1009
        try {
            return render(s)
        } finally {
            vi = 0; vp = 1.0; vs = 0
        }
    }

    private class Buf(seconds: Double) {
        val d = DoubleArray((seconds * SR).toInt())
        val size get() = d.size
    }

    private fun midi(n: Int) = 440.0 * 2.0.pow((n - 69) / 12.0)

    /** A tone with a pitch sweep from [f0] to [f1] and an exponential decay. */
    private fun Buf.tone(at: Double, dur: Double, f0: Double, f1: Double = f0, vol: Double = 0.5, wave: Wave = Wave.TRIANGLE, decay: Double = dur / 3) {
        val start = (at * SR).toInt()
        val n = (dur * SR).toInt()
        var phase = 0.0
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val t = i.toDouble() / SR
            val f = f0 + (f1 - f0) * (i.toDouble() / n)
            phase += f / SR
            phase -= phase.toInt()
            val v = when (wave) {
                Wave.PULSE12 -> if (phase < 0.125) 1.0 else -1.0
                Wave.PULSE25 -> if (phase < 0.25) 1.0 else -1.0
                Wave.PULSE50 -> if (phase < 0.5) 1.0 else -1.0
                Wave.SAW -> 2 * phase - 1
                else -> 4 * abs(phase - 0.5) - 1
            }
            val attack = minOf(1.0, i / (0.003 * SR))
            d[idx] += v * vol * attack * exp(-t / decay)
        }
    }

    /** Sine bell with a few inharmonic partials (clangs, chimes). */
    private fun Buf.bell(at: Double, dur: Double, f: Double, vol: Double = 0.4, metal: Boolean = false) {
        val partials = if (metal) listOf(1.0 to 1.0, 1.48 to 0.6, 2.23 to 0.45, 3.1 to 0.3) else listOf(1.0 to 1.0, 2.0 to 0.35, 3.0 to 0.15)
        val start = (at * SR).toInt()
        for (i in 0 until (dur * SR).toInt()) {
            val idx = start + i
            if (idx >= size) break
            val t = i.toDouble() / SR
            var v = 0.0
            for ((m, a) in partials) v += sin(2 * PI * f * m * t) * a
            d[idx] += v * vol * exp(-t / (dur / 4)) * minOf(1.0, i / (0.002 * SR))
        }
    }

    /** Filtered noise; [bright] 0..1 sets the tone, [swell] fades in instead of starting hard. */
    private fun Buf.noise(at: Double, dur: Double, vol: Double, bright: Double, seed: Int = 1, swell: Boolean = false, sweep: Double = 0.0) {
        val rng = Random(seed)
        val start = (at * SR).toInt()
        val n = (dur * SR).toInt()
        var lp = 0.0
        var prev = 0.0
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val x = i.toDouble() / n
            val raw = rng.nextDouble() * 2 - 1
            val b = (bright + sweep * x).coerceIn(0.02, 1.0)
            lp += (raw - lp) * b
            val hp = lp - prev * 0.6
            prev = lp
            val env = if (swell) sin(PI * x).pow(1.5) else (1 - x).pow(2)
            d[idx] += hp * vol * env
        }
    }

    /**
     * A howling voice: an almost pure, soft "oo" tone whose pitch follows [curve] (pairs of 0..1
     * position and frequency). It gets louder and a little brighter the higher it climbs, wavers
     * slowly and unevenly, and fades out as the pitch sinks at the end.
     */
    private fun Buf.howl(at: Double, dur: Double, curve: List<Pair<Double, Double>>, vol: Double, wobble: Double = 0.012, seed: Int = 1) {
        val start = (at * SR).toInt()
        val n = (dur * SR).toInt()
        val rng = Random(seed)
        val lo = curve.minOf { it.second }
        val hi = curve.maxOf { it.second }
        var phase = 0.0
        var drift = 0.0
        var driftTarget = 0.0
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val x = i.toDouble() / n
            val t = i.toDouble() / SR
            val k = curve.indexOfLast { it.first <= x }.coerceIn(0, curve.size - 2)
            val (x0, f0) = curve[k]; val (x1, f1) = curve[k + 1]
            val u = ((x - x0) / (x1 - x0)).coerceIn(0.0, 1.0)
            val base = f0 + (f1 - f0) * u * u * (3 - 2 * u)
            // an uneven waver: a slow wobble plus a drifting pitch that wanders a little
            if (i % (SR / 12) == 0) driftTarget = (rng.nextDouble() * 2 - 1) * wobble
            drift += (driftTarget - drift) * 0.0008
            val f = base * (1 + wobble * (0.3 + 0.7 * x) * sin(2 * PI * 4.3 * t + sin(2 * PI * 0.7 * t)) + drift)
            phase += f / SR
            phase -= phase.toInt()
            val p = ((base - lo) / (hi - lo).coerceAtLeast(1.0)).coerceIn(0.0, 1.0)
            val bright = 0.06 + 0.22 * p
            val v = sin(2 * PI * phase) + bright * sin(4 * PI * phase) + bright * 0.25 * sin(6 * PI * phase)
            val attack = sin(PI / 2 * minOf(1.0, t / 0.12))
            val release = if (x < 0.72) 1.0 else 0.5 + 0.5 * kotlin.math.cos(PI * (x - 0.72) / 0.28)
            d[idx] += v * vol * attack * release * (0.35 + 0.65 * p)
        }
    }

    /**
     * Forest reverb over the whole buffer: a few damped echo loops and two diffusers
     * (a small Schroeder reverb). [wet] is how much of the echo is mixed in.
     */
    private fun Buf.reverb(wet: Double, feedback: Double = 0.78) {
        val dry = d.copyOf()
        val out = DoubleArray(size)
        for (ms in listOf(59.3, 71.7, 83.1, 97.9)) {
            val len = (ms / 1000 * SR).toInt()
            val line = DoubleArray(len)
            var pos = 0
            var damp = 0.0
            for (i in 0 until size) {
                val y = line[pos]
                damp += (y - damp) * 0.35
                line[pos] = dry[i] + damp * feedback
                out[i] += y
                pos = (pos + 1) % len
            }
        }
        for (ms in listOf(5.0, 1.7)) {
            val len = (ms / 1000 * SR).toInt()
            val line = DoubleArray(len)
            var pos = 0
            for (i in 0 until size) {
                val buf = line[pos]
                val y = -0.6 * out[i] + buf
                line[pos] = out[i] + 0.6 * y
                out[i] = y
                pos = (pos + 1) % len
            }
        }
        for (i in 0 until size) d[i] = dry[i] + out[i] * wet / 4
    }

    // ---------------------------------------------------------------- realistic battle sounds

    /**
     * Noise through a resonant band-pass whose centre glides from [f0] to [f1] (Hz): whooshes,
     * crunches, the rush of fire. [q] sets how narrow the band is; the envelope rises over
     * [attack] seconds and decays with [decay], or swells and fades when [swell].
     */
    private fun Buf.band(at: Double, dur: Double, vol: Double, f0In: Double, f1In: Double, q: Double = 2.0, seed: Int = 1, attack: Double = 0.004, decay: Double = dur / 3, swell: Boolean = false) {
        val rng = Random(seed + vs)
        val f0 = f0In * vp; val f1 = f1In * vp
        val start = (at * SR).toInt(); val n = (dur * SR).toInt()
        var x1 = 0.0; var x2 = 0.0; var y1 = 0.0; var y2 = 0.0
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val x = i.toDouble() / n
            val f = f0 * (f1 / f0).pow(x)
            val w0 = 2 * PI * f / SR
            val alpha = sin(w0) / (2 * q)
            val a0 = 1 + alpha
            val b0 = alpha / a0; val b2 = -alpha / a0; val a1 = -2 * kotlin.math.cos(w0) / a0; val a2 = (1 - alpha) / a0
            val xin = rng.nextDouble() * 2 - 1
            val y = b0 * xin + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1; x1 = xin; y2 = y1; y1 = y
            val t = i.toDouble() / SR
            val env = if (swell) sin(PI * x).pow(1.3) else minOf(1.0, t / attack) * exp(-(t - attack).coerceAtLeast(0.0) / decay)
            d[idx] += y * vol * env * 3
        }
    }

    /** A body blow: a sine whose pitch drops from [f0] to [f1], dying away quickly. */
    private fun Buf.thud(at: Double, dur: Double, f0In: Double, f1In: Double, vol: Double) {
        val f0 = f0In * vp; val f1 = f1In * vp
        val start = (at * SR).toInt(); val n = (dur * SR).toInt()
        var ph = 0.0
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val x = i.toDouble() / n
            ph += f0 * (f1 / f0).pow(x) / SR
            val t = i.toDouble() / SR
            d[idx] += sin(2 * PI * ph) * vol * minOf(1.0, t / 0.002) * exp(-t / (dur / 3.5))
        }
    }

    /** Struck metal: a few inharmonic partials that ring and fade at different speeds. */
    private fun Buf.ring(at: Double, dur: Double, fIn: Double, vol: Double) {
        val f = fIn * vp
        val partials = listOf(1.0 to 1.0, 2.76 to 0.55, 5.4 to 0.35, 8.93 to 0.2, 13.3 to 0.1)
        val start = (at * SR).toInt()
        for (i in 0 until (dur * SR).toInt()) {
            val idx = start + i
            if (idx >= size) break
            val t = i.toDouble() / SR
            var v = 0.0
            for ((k, pair) in partials.withIndex()) v += sin(2 * PI * f * pair.first * t + k) * pair.second * exp(-t / (dur / (2.5 + k * 1.5)))
            d[idx] += v * vol * minOf(1.0, t / 0.001)
        }
    }

    /** A plucked string (Karplus–Strong): the bowstring. */
    private fun Buf.pluck(at: Double, dur: Double, fIn: Double, vol: Double, seed: Int = 1) {
        val rng = Random(seed + vs)
        val f = fIn * vp
        val len = (SR / f).toInt().coerceAtLeast(2)
        val line = DoubleArray(len) { rng.nextDouble() * 2 - 1 }
        val start = (at * SR).toInt()
        var pos = 0
        for (i in 0 until (dur * SR).toInt()) {
            val idx = start + i
            if (idx >= size) break
            val nx = (pos + 1) % len
            val v = line[pos]
            line[pos] = (line[pos] + line[nx]) * 0.5 * 0.996
            d[idx] += v * vol
            pos = nx
        }
    }

    /** Bowed or blown tone: a sawtooth softened by a low-pass, swelling in and out (strings, horns, drones). */
    private fun Buf.pad(at: Double, dur: Double, fIn: Double, vol: Double, cutoff: Double = 900.0, attack: Double = 0.15, vibrato: Double = 0.004) {
        val f = fIn * Math.sqrt(vp)
        val start = (at * SR).toInt(); val n = (dur * SR).toInt()
        var ph = 0.0; var lp = 0.0; var lp2 = 0.0
        val k = 1 - exp(-2 * PI * cutoff / SR)
        for (i in 0 until n) {
            val idx = start + i
            if (idx >= size) break
            val t = i.toDouble() / SR
            ph += f * (1 + vibrato * sin(2 * PI * 5.2 * t)) / SR
            ph -= ph.toInt()
            val saw = 2 * ph - 1
            lp += (saw - lp) * k; lp2 += (lp - lp2) * k
            val env = minOf(1.0, t / attack) * minOf(1.0, (dur - t) / (dur * 0.4))
            d[idx] += lp2 * vol * env
        }
    }

    /** A short room or forest reverb over everything drawn so far. */
    private fun Buf.room(wet: Double) = reverb(wet, 0.62)

    private fun Buf.pcm(): ShortArray {
        val peak = d.maxOf { abs(it) }.coerceAtLeast(1e-6)
        val gain = 0.7 / peak
        return ShortArray(size) { (d[it] * gain * Short.MAX_VALUE).toInt().coerceIn(-32767, 32767).toShort() }
    }

    /**
     * A creak of old wood or iron: the stick and slip of a hinge, quick ticks whose rate glides from [rate0] to
     * [rate1] per second, each ringing a narrow band round [f] Hz.
     */
    private fun Buf.creak(at: Double, dur: Double, rate0: Double, rate1: Double, f: Double, vol: Double, seed: Int) {
        val rng = Random(seed + vs)
        var t = 0.0
        var k = 0
        while (t < dur) {
            val x = t / dur
            val rate = rate0 + (rate1 - rate0) * x
            val env = kotlin.math.sin(PI * x).pow(0.6)
            band(at + t, 0.02, vol * env * (0.7 + 0.6 * rng.nextDouble()), f * (0.95 + 0.1 * rng.nextDouble()), f * 0.9, 9.0, seed + k, decay = 0.006)
            t += 1.0 / rate * (0.8 + 0.4 * rng.nextDouble())
            k++
        }
    }

    /** Sounds proposed for the overhaul, to be heard side by side with the ones in the game; not used in the game yet. */
    val PROPOSED = listOf(Sound.CLICK, Sound.LOOT, Sound.LOOT_EPIC, Sound.COINS, Sound.CHEST, Sound.DOOR, Sound.LEVEL_UP, Sound.ENEMY_DOWN)

    /** Take [variant] (0 to 2) of the proposed new [s]. */
    @Synchronized
    fun proposal(s: Sound, variant: Int): ShortArray {
        vi = variant; vp = 1.0; vs = variant * 1009
        try {
            return proposed(s, variant).pcm()
        } finally { vi = 0; vp = 1.0; vs = 0 }
    }

    private fun proposed(s: Sound, v: Int): Buf = when (s) {
        // a tap on the page: leather, wood, a dry knock of bone
        Sound.CLICK -> when (v) {
            0 -> Buf(0.08).apply { band(0.0, 0.03, 0.6, 900.0, 700.0, 3.0, 301, decay = 0.006); thud(0.0, 0.05, 260.0, 180.0, 0.25) }
            1 -> Buf(0.08).apply { band(0.0, 0.025, 0.7, 1600.0, 1300.0, 6.0, 302, decay = 0.004); thud(0.0, 0.04, 420.0, 300.0, 0.18) }
            else -> Buf(0.08).apply { band(0.0, 0.02, 0.5, 2400.0, 2000.0, 8.0, 303, decay = 0.003); band(0.004, 0.02, 0.3, 700.0, 600.0, 4.0, 304, decay = 0.004) }
        }
        // a find picked up: a leather pouch shut on it, a buckle; a bundle dropped in the pack; a blade slid into a sheath
        Sound.LOOT -> when (v) {
            0 -> Buf(0.5).apply { band(0.0, 0.18, 0.35, 900.0, 600.0, 1.2, 311, swell = true); thud(0.16, 0.12, 180.0, 110.0, 0.4); ring(0.2, 0.18, 1450.0, 0.06); room(0.12) }
            1 -> Buf(0.5).apply { band(0.0, 0.12, 0.3, 1400.0, 700.0, 1.0, 312, swell = true); thud(0.1, 0.18, 120.0, 70.0, 0.6); band(0.1, 0.08, 0.3, 500.0, 300.0, 2.0, 313, decay = 0.02); room(0.1) }
            else -> Buf(0.6).apply { band(0.0, 0.32, 0.45, 2600.0, 4200.0, 3.0, 314, swell = true); ring(0.3, 0.25, 980.0, 0.08); thud(0.3, 0.1, 220.0, 140.0, 0.3); room(0.15) }
        }
        // a rare find: no glitter, but something old and heavy; a deep bell in a vault, a low horn, a dark choir
        Sound.LOOT_EPIC -> when (v) {
            0 -> Buf(2.2).apply { ring(0.0, 2.0, 98.0, 0.5); bell(0.0, 1.6, 196.0, 0.15); pad(0.1, 1.8, 98.0, 0.18, 500.0, 0.4); reverb(0.6) }
            1 -> Buf(2.2).apply { thud(0.0, 0.8, 55.0, 36.0, 0.9); for (f in listOf(110.0, 130.8, 164.8)) pad(0.05, 1.8, f, 0.2, 800.0, 0.5, 0.004); reverb(0.55) }
            else -> Buf(2.2).apply { for ((k, f) in listOf(146.8, 174.6, 220.0, 261.6).withIndex()) { pad(k * 0.12, 1.7, f, 0.13, 1100.0, 0.45, 0.006); pad(k * 0.12, 1.7, f * 1.005, 0.1, 1100.0, 0.5, 0.007) }; ring(0.5, 1.4, 293.6, 0.12); reverb(0.6) }
        }
        // coins: a few struck and clinking together, then the purse; more of them; a single heavy coin spinning out
        Sound.COINS -> when (v) {
            0 -> Buf(0.6).apply { val rng = Random(321); for (i in 0 until 6) ring(i * 0.035 + rng.nextDouble() * 0.02, 0.18, 2600.0 + rng.nextDouble() * 1400, 0.12); thud(0.24, 0.1, 160.0, 100.0, 0.35); room(0.12) }
            1 -> Buf(0.9).apply { val rng = Random(322); for (i in 0 until 12) ring(i * 0.03 + rng.nextDouble() * 0.03, 0.15, 2200.0 + rng.nextDouble() * 1800, 0.09); band(0.0, 0.45, 0.2, 1200.0, 800.0, 1.0, 323, swell = true); room(0.15) }
            else -> Buf(1.0).apply { for (i in 0 until 9) { val t = 0.6 * (1 - 0.88.pow(i.toDouble())); ring(t, 0.12, 3100.0 - i * 40, 0.12 * (1 - i / 12.0)) }; room(0.15) }
        }
        // a chest opened: an iron hasp, a creaking lid, the lid falling back against the hinges
        Sound.CHEST -> when (v) {
            0 -> Buf(1.3).apply { ring(0.0, 0.12, 820.0, 0.12); band(0.0, 0.04, 0.5, 1800.0, 1200.0, 5.0, 331, decay = 0.01); creak(0.12, 0.75, 22.0, 45.0, 640.0, 0.5, 332); thud(0.9, 0.3, 110.0, 60.0, 0.7); room(0.25) }
            1 -> Buf(1.2).apply { creak(0.0, 0.6, 35.0, 18.0, 420.0, 0.55, 333); thud(0.62, 0.35, 95.0, 50.0, 0.8); band(0.62, 0.15, 0.4, 400.0, 250.0, 1.5, 334, decay = 0.05); room(0.25) }
            else -> Buf(1.3).apply { ring(0.0, 0.2, 520.0, 0.15); ring(0.05, 0.25, 660.0, 0.1); creak(0.2, 0.55, 30.0, 60.0, 900.0, 0.4, 335); thud(0.8, 0.3, 120.0, 70.0, 0.6); room(0.3) }
        }
        // a door: a heavy creak and the slam; a latch lifted and a quick push; an iron-bound door grinding over stone
        Sound.DOOR -> when (v) {
            0 -> Buf(1.2).apply { creak(0.0, 0.7, 18.0, 30.0, 360.0, 0.55, 341); thud(0.72, 0.4, 85.0, 45.0, 0.9); band(0.72, 0.2, 0.4, 500.0, 250.0, 1.3, 342, decay = 0.06); room(0.35) }
            1 -> Buf(0.7).apply { ring(0.0, 0.08, 1100.0, 0.12); band(0.0, 0.03, 0.4, 2200.0, 1600.0, 5.0, 343, decay = 0.008); creak(0.08, 0.3, 40.0, 25.0, 520.0, 0.35, 344); thud(0.4, 0.2, 140.0, 80.0, 0.5); room(0.25) }
            else -> Buf(1.4).apply { band(0.0, 1.0, 0.5, 180.0, 260.0, 1.5, 345, swell = true); creak(0.05, 0.9, 12.0, 20.0, 260.0, 0.4, 346); thud(1.05, 0.35, 70.0, 40.0, 0.8); ring(1.05, 0.3, 310.0, 0.08); room(0.4) }
        }
        // growing stronger: a war drum and a low horn call; a deep bell over a swelling chord; a choir rising in a minor key
        Sound.LEVEL_UP -> when (v) {
            0 -> Buf(2.2).apply { thud(0.0, 0.6, 60.0, 40.0, 1.0); thud(0.3, 0.6, 60.0, 40.0, 0.9); pad(0.3, 1.6, 98.0, 0.3, 700.0, 0.2, 0.003); pad(0.7, 1.2, 146.8, 0.25, 800.0, 0.2, 0.003); room(0.45) }
            1 -> Buf(2.4).apply { ring(0.0, 2.2, 130.8, 0.35); for (f in listOf(65.4, 98.0, 130.8, 155.6)) pad(0.1, 2.0, f, 0.14, 900.0, 0.8, 0.004); reverb(0.55) }
            else -> Buf(2.4).apply { for ((k, f) in listOf(110.0, 130.8, 164.8, 220.0).withIndex()) { pad(k * 0.2, 2.0 - k * 0.2, f, 0.13, 1200.0, 0.4, 0.006); pad(k * 0.2, 2.0 - k * 0.2, f * 1.005, 0.1, 1200.0, 0.45, 0.007) }; thud(0.0, 0.7, 55.0, 38.0, 0.6); reverb(0.6) }
        }
        // a foe goes down: a gasp and the body hitting the ground; armour clattering with it; a heavy body on wet earth
        Sound.ENEMY_DOWN -> when (v) {
            0 -> Buf(1.1).apply { band(0.0, 0.35, 0.35, 500.0, 250.0, 2.0, 351, swell = true); thud(0.34, 0.5, 75.0, 38.0, 1.0); band(0.34, 0.2, 0.5, 350.0, 180.0, 1.3, 352, decay = 0.07); room(0.3) }
            1 -> Buf(1.2).apply { thud(0.2, 0.45, 80.0, 40.0, 0.9); for (k in 0 until 5) ring(0.2 + k * 0.05, 0.15, 900.0 + k * 230, 0.06); band(0.2, 0.25, 0.4, 1500.0, 800.0, 2.0, 353, decay = 0.06); room(0.3) }
            else -> Buf(1.2).apply { thud(0.1, 0.6, 60.0, 32.0, 1.0); band(0.1, 0.4, 0.6, 300.0, 140.0, 1.0, 354, decay = 0.12); band(0.14, 0.3, 0.25, 900.0, 500.0, 1.5, 355, decay = 0.05); room(0.3) }
        }
        else -> Buf(0.1)
    }

    fun render(s: Sound): ShortArray = when (s) {
        // A soft, low wooden tick rather than a bright beep.
        Sound.CLICK -> Buf(0.05).apply { tone(0.0, 0.04, 820.0, 640.0, 0.26, Wave.TRIANGLE, 0.01) }
        Sound.LEVEL_UP -> Buf(1.3).apply {
            listOf(67, 72, 76, 79).forEachIndexed { i, n -> tone(i * 0.09, 0.15, midi(n), midi(n), 0.35, Wave.PULSE25, 0.1) }
            tone(0.38, 0.85, midi(84), midi(84), 0.35, Wave.PULSE25, 0.4)
            tone(0.38, 0.85, midi(79), midi(79), 0.2, Wave.TRIANGLE, 0.4)
            tone(0.38, 0.85, midi(76), midi(76), 0.2, Wave.TRIANGLE, 0.4)
        }
        Sound.LOOT -> Buf(0.5).apply {
            bell(0.0, 0.3, midi(88), 0.35)
            bell(0.09, 0.4, midi(95), 0.35)
        }
        Sound.LOOT_EPIC -> Buf(1.5).apply {
            listOf(76, 79, 83, 86, 88, 91, 95).forEachIndexed { i, n -> bell(i * 0.06, 0.6, midi(n), 0.25) }
            listOf(64, 68, 71, 76).forEach { n -> tone(0.3, 1.1, midi(n), midi(n), 0.12, Wave.SAW, 0.6) }
            noise(0.3, 1.0, 0.1, 0.95, 31, swell = true)
        }
        Sound.COINS -> Buf(0.5).apply {
            val rng = Random(8)
            for (i in 0 until 5) bell(i * 0.06 + rng.nextDouble() * 0.02, 0.2, 2000.0 + rng.nextDouble() * 900, 0.25, metal = true)
        }
        Sound.CHEST -> Buf(0.9).apply {
            tone(0.0, 0.3, 90.0, 140.0, 0.4, Wave.SAW, 0.2)
            noise(0.0, 0.25, 0.2, 0.1, 33, swell = true)
            bell(0.3, 0.5, midi(84), 0.3)
            bell(0.38, 0.5, midi(88), 0.3)
            bell(0.46, 0.5, midi(91), 0.3)
        }
        Sound.DOOR -> Buf(0.5).apply {
            tone(0.0, 0.2, 110.0, 60.0, 0.6, Wave.TRIANGLE, 0.06)
            tone(0.05, 0.3, 300.0, 220.0, 0.15, Wave.SAW, 0.12)
        }
        // Ambient sounds, played quietly now and then.
        Sound.BIRD -> Buf(0.7).apply {
            listOf(0.0 to 96, 0.12 to 99, 0.22 to 94, 0.42 to 100).forEach { (at, n) ->
                tone(at, 0.09, midi(n), midi(n + 3), 0.22, Wave.TRIANGLE, 0.03)
            }
        }
        // Two crickets: each chirp is a burst of very short, soft ticks with a little air in them.
        Sound.CRICKET -> Buf(1.3).apply {
            val chirps = listOf(0.0 to 4650.0, 0.31 to 4650.0, 0.55 to 5150.0, 0.83 to 4650.0, 1.02 to 5150.0)
            for ((at, f) in chirps) for (j in 0 until 4) {
                tone(at + j * 0.012, 0.009, f, f * 0.985, 0.035, Wave.TRIANGLE, 0.003)
            }
            for ((at, _) in chirps) noise(at, 0.05, 0.006, 0.9, 41)
        }
        Sound.OWL -> Buf(1.4).apply {
            tone(0.0, 0.35, midi(64), midi(62), 0.3, Wave.TRIANGLE, 0.2)
            tone(0.55, 0.6, midi(64), midi(61), 0.28, Wave.TRIANGLE, 0.3)
        }
        // A fire crackling: soft rushing with a few sharp pops of wood.
        Sound.CRACKLE -> Buf(1.6).apply {
            noise(0.0, 1.6, 0.25, 0.05, 61, swell = true)
            val rng = Random(62)
            for (k in 0 until 11) {
                val at = rng.nextDouble() * 1.45
                noise(at, 0.012 + rng.nextDouble() * 0.02, 0.5 + rng.nextDouble() * 0.5, 0.75, 63 + k)
            }
        }
        Sound.DRIP -> Buf(0.5).apply {
            tone(0.0, 0.12, midi(91), midi(79), 0.3, Wave.TRIANGLE, 0.03)
            tone(0.14, 0.3, midi(84), midi(81), 0.08, Wave.TRIANGLE, 0.1)
        }
        // Three wolf howls, each with the echo of the forest: a long one that swells and sinks,
        // a short call answered by a longer, higher one, and a deep mournful one that breaks upward.
        Sound.HOWL_1 -> Buf(2.6).apply {
            howl(0.0, 1.9, listOf(0.0 to 330.0, 0.18 to 560.0, 0.55 to 610.0, 0.85 to 520.0, 1.0 to 360.0), 0.6, seed = 51)
            reverb(0.55)
        }
        Sound.HOWL_2 -> Buf(2.6).apply {
            howl(0.0, 0.6, listOf(0.0 to 380.0, 0.35 to 590.0, 1.0 to 470.0), 0.5, wobble = 0.008, seed = 53)
            howl(0.62, 1.4, listOf(0.0 to 470.0, 0.2 to 680.0, 0.6 to 660.0, 1.0 to 430.0), 0.6, seed = 54)
            reverb(0.55)
        }
        Sound.HOWL_3 -> Buf(2.6).apply {
            howl(0.0, 2.0, listOf(0.0 to 230.0, 0.25 to 400.0, 0.42 to 410.0, 0.47 to 520.0, 0.75 to 500.0, 1.0 to 280.0), 0.6, wobble = 0.018, seed = 55)
            reverb(0.6)
        }
        // ---- battle: hits and misses, layered from swish, body blow and crunch, in a small room
        Sound.HIT_SLASH -> Buf(0.7).apply {
            band(0.0, 0.14, 0.5, 4200.0, 1300.0, 1.4, 101, decay = 0.05)
            thud(0.05, 0.22, 150.0, 70.0, 0.75)
            band(0.05, 0.12, 0.45, 900.0, 600.0, 3.0, 102, decay = 0.03)
            room(0.25)
        }
        Sound.HIT_PIERCE -> Buf(0.6).apply {
            band(0.0, 0.08, 0.35, 3000.0, 5200.0, 2.0, 103, decay = 0.03)
            band(0.06, 0.05, 0.6, 1700.0, 1200.0, 6.0, 104, decay = 0.012)
            thud(0.06, 0.18, 190.0, 95.0, 0.6)
            room(0.22)
        }
        Sound.HIT_SMASH -> Buf(0.8).apply {
            thud(0.0, 0.45, 95.0, 38.0, 1.0)
            band(0.0, 0.2, 0.7, 420.0, 220.0, 1.5, 105, decay = 0.06)
            for (k in 0 until 2 + vi) band(0.02 + k * 0.025, 0.04, 0.3, 2600.0, 1800.0, 4.0, 106 + k, decay = 0.01)
            room(0.3)
        }
        // a miss, in three kinds: a full whoosh, a quick hiss of a light blade, the heavy rush of a big swing
        Sound.MISS -> when (vi) {
            1 -> Buf(0.3).apply {
                band(0.0, 0.15, 0.7, 700.0, 2600.0, 1.4, 151, swell = true)
                band(0.08, 0.1, 0.25, 2600.0, 1100.0, 1.4, 152, swell = true)
                room(0.08)
            }
            2 -> Buf(0.6).apply {
                band(0.0, 0.36, 0.85, 160.0, 820.0, 0.9, 153, swell = true)
                band(0.16, 0.28, 0.4, 820.0, 260.0, 0.9, 154, swell = true)
                thud(0.0, 0.3, 70.0, 55.0, 0.18)
                room(0.15)
            }
            else -> Buf(0.45).apply {
                band(0.0, 0.24, 0.75, 260.0, 1250.0, 1.2, 109, swell = true)
                band(0.1, 0.2, 0.35, 1250.0, 420.0, 1.2, 110, swell = true)
                room(0.12)
            }
        }
        Sound.CRIT -> Buf(1.1).apply {
            band(0.0, 0.12, 0.55, 4800.0, 1200.0, 1.3, 111, decay = 0.05)
            thud(0.04, 0.55, 120.0, 40.0, 1.0)
            band(0.04, 0.25, 0.6, 700.0, 300.0, 1.4, 112, decay = 0.08)
            ring(0.04, 0.7, 610.0, 0.18)
            room(0.4)
        }
        // a blow caught, in three kinds: a dull klonk of wood and iron; a deep knock on a wooden shield with a short
        // rattle; a blade turned by a blade, a short hard clash. None of them rings on.
        Sound.BLOCK -> when (vi) {
            1 -> Buf(0.5).apply {
                thud(0.0, 0.26, 175.0, 85.0, 1.0)
                band(0.0, 0.09, 0.8, 480.0, 300.0, 2.5, 155, decay = 0.03)
                band(0.07, 0.05, 0.3, 380.0, 260.0, 3.0, 156, decay = 0.015)
                band(0.12, 0.04, 0.18, 360.0, 240.0, 3.0, 157, decay = 0.012)
                room(0.14)
            }
            2 -> Buf(0.45).apply {
                band(0.0, 0.05, 0.75, 1700.0, 1150.0, 5.0, 158, decay = 0.012)
                thud(0.0, 0.14, 270.0, 150.0, 0.55)
                ring(0.0, 0.09, 540.0, 0.1)
                band(0.02, 0.06, 0.25, 3200.0, 2400.0, 3.0, 159, decay = 0.015)
                room(0.16)
            }
            else -> Buf(0.5).apply {
                thud(0.0, 0.22, 230.0, 115.0, 0.95)
                band(0.0, 0.07, 0.9, 720.0, 440.0, 3.0, 113, decay = 0.02)
                band(0.0, 0.025, 0.16, 2100.0, 1600.0, 2.5, 114, decay = 0.008)
                ring(0.0, 0.11, 360.0, 0.07)
                room(0.15)
            }
        }
        // snarl, the snap of jaws and the bite going in
        Sound.BITE -> Buf(0.7).apply {
            val rng = Random(114 + vs)
            for (k in 0 until 4 + vi * 2) band(k * 0.03, 0.035, 0.35 + rng.nextDouble() * 0.2, 320.0, 260.0, 3.0, 115 + k, decay = 0.015)
            band(0.2, 0.03, 0.8, 2800.0, 2000.0, 5.0, 122, decay = 0.008)
            band(0.24, 0.03, 0.7, 2500.0, 1800.0, 5.0, 123, decay = 0.008)
            thud(0.21, 0.18, 160.0, 80.0, 0.5)
            room(0.25)
        }
        // the bowstring, the arrow hissing through the air, the impact
        Sound.ARROW -> Buf(0.9).apply {
            pluck(0.0, 0.35, 98.0, 0.6, 124)
            band(0.04, 0.3, 0.4, 1800.0, 3800.0, 2.5, 125, swell = true)
            band(0.33, 0.05, 0.6, 1500.0, 1000.0, 5.0, 126, decay = 0.012)
            thud(0.33, 0.15, 180.0, 90.0, 0.4)
            room(0.25)
        }
        // a roaring burst of flame and crackling
        Sound.FIRE -> Buf(1.2).apply {
            thud(0.0, 0.4, 70.0, 45.0, 0.6)
            band(0.0, 0.9, 0.9, 180.0, 1400.0, 0.8, 127, swell = true)
            band(0.1, 0.8, 0.4, 2500.0, 1200.0, 1.2, 128, swell = true)
            val rng = Random(129 + vs)
            for (k in 0 until 6 + vi * 3) band(0.2 + rng.nextDouble() * 0.8, 0.02, 0.5, 3000.0, 2200.0, 5.0, 130 + k, decay = 0.005)
            room(0.25)
        }
        // arcane force: an airy rising rush over a low hum, glassy overtones
        Sound.MAGIC -> Buf(1.2).apply {
            pad(0.0, 0.9, 110.0, 0.35, 500.0, 0.08, 0.01)
            band(0.0, 0.7, 0.6, 400.0, 3200.0, 4.0, 140, swell = true)
            for ((k, f) in listOf(1318.0, 1975.0, 2637.0).withIndex()) tone(0.25 + k * 0.06, 0.5, f, f * 1.01, 0.05, Wave.TRIANGLE, 0.25)
            room(0.45)
        }
        // holy light: a soft choir chord swelling in, a bell on top
        Sound.HOLY -> Buf(1.8).apply {
            for (f in listOf(220.0, 277.2, 329.6, 440.0)) { pad(0.0, 1.4, f, 0.14, 1400.0, 0.35, 0.006); pad(0.0, 1.4, f * 1.004, 0.1, 1400.0, 0.4, 0.007) }
            bell(0.3, 1.2, 880.0, 0.2)
            room(0.5)
        }
        Sound.HEAL -> Buf(1.6).apply {
            for ((k, f) in listOf(392.0, 493.9, 587.3, 784.0).withIndex()) pad(k * 0.08, 1.0, f, 0.1, 1800.0, 0.2, 0.008)
            band(0.0, 1.1, 0.2, 2000.0, 5000.0, 3.0, 141, swell = true)
            room(0.5)
        }
        Sound.BUFF -> Buf(1.4).apply {
            pad(0.0, 1.0, 98.0, 0.35, 600.0, 0.25)
            pad(0.0, 1.0, 147.0, 0.25, 700.0, 0.25)
            bell(0.35, 0.9, 587.0, 0.18)
            room(0.4)
        }
        // poison: wet bubbling and a sickly hiss
        Sound.POISON -> Buf(1.0).apply {
            val rng = Random(142 + vs)
            for (k in 0 until 10) { val f = 180.0 + rng.nextDouble() * 240; thud(k * 0.07 + rng.nextDouble() * 0.03, 0.07, f, f * 1.6, 0.3) }
            band(0.0, 0.9, 0.25, 3000.0, 1800.0, 1.5, 143, swell = true)
            room(0.2)
        }
        // a flask thrown: whoosh, glass shattering
        Sound.THROW -> Buf(0.9).apply {
            band(0.0, 0.3, 0.4, 600.0, 1800.0, 1.5, 144, swell = true)
            for (k in 0 until 7) ring(0.3 + k * 0.012, 0.18, 2400.0 + k * 530, 0.05)
            band(0.3, 0.2, 0.6, 5000.0, 3000.0, 1.0, 145, decay = 0.05)
            room(0.25)
        }
        // a cork pulled, a few swallows
        Sound.POTION -> Buf(0.8).apply {
            thud(0.0, 0.05, 700.0, 300.0, 0.4)
            band(0.0, 0.04, 0.4, 1800.0, 1200.0, 4.0, 146, decay = 0.01)
            for (k in 0 until 3) thud(0.18 + k * 0.17, 0.12, 160.0, 220.0, 0.35)
            room(0.15)
        }
        // a body falling, a last breath
        Sound.ENEMY_DOWN -> Buf(1.1).apply {
            band(0.0, 0.4, 0.3, 700.0, 300.0, 1.2, 147, swell = true)
            thud(0.32, 0.5, 80.0, 40.0, 1.0)
            band(0.32, 0.25, 0.5, 400.0, 200.0, 1.3, 148, decay = 0.08)
            room(0.3)
        }
        Sound.HERO_DOWN -> Buf(2.6).apply {
            thud(0.0, 0.6, 70.0, 35.0, 1.0)
            band(0.0, 0.3, 0.5, 400.0, 200.0, 1.3, 149, decay = 0.1)
            for ((k, f) in listOf(110.0, 130.8, 164.8).withIndex()) pad(0.3 + k * 0.05, 2.0, f, 0.2, 700.0, 0.4, 0.003)
            room(0.5)
        }
        // battle begins: a deep drum hit and a tense swell of low strings
        Sound.ENCOUNTER -> Buf(2.0).apply {
            thud(0.0, 0.7, 60.0, 38.0, 1.0)
            band(0.0, 0.25, 0.4, 300.0, 150.0, 1.2, 150, decay = 0.08)
            for (f in listOf(73.4, 77.8, 110.0)) pad(0.05, 1.5, f, 0.22, 650.0, 0.5, 0.004)
            room(0.45)
        }
        // a monster has seen the hero: two quick low drum taps
        Sound.ALERT -> Buf(0.6).apply {
            thud(0.0, 0.18, 110.0, 70.0, 0.7)
            thud(0.12, 0.22, 120.0, 72.0, 0.8)
            room(0.25)
        }
        // ambushed: a sharp crack and a dissonant brass stab
        Sound.AMBUSH -> Buf(1.6).apply {
            band(0.0, 0.08, 1.0, 2500.0, 900.0, 1.0, 151, decay = 0.02)
            thud(0.0, 0.5, 80.0, 40.0, 1.0)
            for (f in listOf(92.5, 98.0, 138.6)) pad(0.02, 1.0, f, 0.3, 1400.0, 0.02, 0.003)
            room(0.4)
        }
        // the hero swings: a weapon cutting the air, light and heavy
        Sound.SWING -> Buf(0.5).apply { band(0.0, 0.25, 0.6, 700.0, 2600.0, 1.8, 152, swell = true); room(0.15) }
        Sound.SWING_HEAVY -> Buf(0.7).apply { band(0.0, 0.4, 0.8, 250.0, 900.0, 1.4, 153, swell = true); room(0.2) }
    }.pcm()
}
