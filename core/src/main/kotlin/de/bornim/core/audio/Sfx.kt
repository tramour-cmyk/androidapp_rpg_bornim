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
}

/** Synthesized sound effects, rendered once to 16-bit mono PCM. */
object Sfx {
    private const val SR = Synth.SAMPLE_RATE

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

    private fun Buf.pcm(): ShortArray {
        val peak = d.maxOf { abs(it) }.coerceAtLeast(1e-6)
        val gain = 0.7 / peak
        return ShortArray(size) { (d[it] * gain * Short.MAX_VALUE).toInt().coerceIn(-32767, 32767).toShort() }
    }

    fun render(s: Sound): ShortArray = when (s) {
        Sound.CLICK -> Buf(0.06).apply { tone(0.0, 0.05, 1400.0, 1700.0, 0.4, Wave.PULSE25, 0.015) }
        Sound.HIT_SLASH -> Buf(0.3).apply {
            noise(0.0, 0.16, 0.9, 0.35, 3, sweep = 0.5)
            tone(0.03, 0.15, 160.0, 70.0, 0.6, Wave.TRIANGLE, 0.05)
        }
        Sound.HIT_PIERCE -> Buf(0.25).apply {
            noise(0.0, 0.05, 0.8, 0.8, 5)
            tone(0.01, 0.14, 900.0, 600.0, 0.3, Wave.TRIANGLE, 0.04)
            tone(0.02, 0.1, 140.0, 80.0, 0.5, Wave.TRIANGLE, 0.04)
        }
        Sound.HIT_SMASH -> Buf(0.4).apply {
            tone(0.0, 0.3, 120.0, 45.0, 0.9, Wave.TRIANGLE, 0.09)
            noise(0.0, 0.12, 0.6, 0.15, 7)
        }
        Sound.MISS -> Buf(0.3).apply { noise(0.0, 0.26, 0.7, 0.12, 9, swell = true, sweep = 0.5) }
        Sound.CRIT -> Buf(0.7).apply {
            tone(0.0, 0.25, 140.0, 50.0, 0.8, Wave.TRIANGLE, 0.08)
            noise(0.0, 0.1, 0.6, 0.6, 11)
            bell(0.02, 0.6, 880.0, 0.35, metal = true)
        }
        Sound.BLOCK -> Buf(0.4).apply {
            bell(0.0, 0.35, 620.0, 0.4, metal = true)
            noise(0.0, 0.06, 0.5, 0.7, 13)
        }
        Sound.BITE -> Buf(0.3).apply {
            noise(0.0, 0.07, 0.8, 0.25, 15)
            noise(0.1, 0.08, 0.8, 0.22, 16)
            tone(0.0, 0.18, 220.0, 90.0, 0.3, Wave.SAW, 0.05)
        }
        Sound.ARROW -> Buf(0.35).apply {
            tone(0.0, 0.12, 330.0, 300.0, 0.4, Wave.SAW, 0.04)
            noise(0.05, 0.25, 0.5, 0.3, 17, swell = true, sweep = 0.4)
        }
        Sound.FIRE -> Buf(0.7).apply {
            noise(0.0, 0.65, 0.9, 0.08, 19, swell = true, sweep = 0.25)
            for (i in 0 until 8) noise(0.05 + i * 0.07, 0.02, 0.5, 0.9, 20 + i)
            tone(0.0, 0.5, 90.0, 140.0, 0.3, Wave.SAW, 0.2)
        }
        Sound.MAGIC -> Buf(0.6).apply {
            listOf(76, 79, 83, 88).forEachIndexed { i, n -> bell(i * 0.05, 0.35, midi(n), 0.3) }
            tone(0.0, 0.5, 600.0, 1800.0, 0.12, Wave.PULSE12, 0.2)
        }
        Sound.HOLY -> Buf(1.0).apply {
            listOf(72, 76, 79, 84).forEach { n -> bell(0.0, 0.95, midi(n), 0.25) }
            noise(0.0, 0.8, 0.15, 0.9, 23, swell = true)
        }
        Sound.HEAL -> Buf(0.7).apply {
            listOf(72, 76, 79, 84).forEachIndexed { i, n -> tone(i * 0.08, 0.35, midi(n), midi(n), 0.35, Wave.TRIANGLE, 0.12) }
        }
        Sound.BUFF -> Buf(0.6).apply {
            tone(0.0, 0.55, 420.0, 1300.0, 0.35, Wave.TRIANGLE, 0.3)
            tone(0.0, 0.55, 630.0, 1950.0, 0.15, Wave.TRIANGLE, 0.3)
        }
        Sound.POISON -> Buf(0.5).apply {
            val rng = Random(3)
            for (i in 0 until 6) {
                val f = 200 + rng.nextDouble() * 300
                tone(i * 0.07, 0.06, f, f * 1.6, 0.35, Wave.TRIANGLE, 0.03)
            }
        }
        Sound.THROW -> Buf(0.5).apply {
            noise(0.0, 0.2, 0.5, 0.2, 29, swell = true, sweep = 0.4)
            noise(0.22, 0.2, 0.8, 0.95, 30)
            bell(0.22, 0.25, 2400.0, 0.15, metal = true)
        }
        Sound.POTION -> Buf(0.5).apply {
            for (i in 0 until 3) tone(i * 0.13, 0.1, 260.0, 180.0, 0.5, Wave.TRIANGLE, 0.04)
            tone(0.4, 0.1, 700.0, 900.0, 0.2, Wave.TRIANGLE, 0.04)
        }
        Sound.ENEMY_DOWN -> Buf(0.6).apply { tone(0.0, 0.55, 520.0, 70.0, 0.4, Wave.PULSE25, 0.25) }
        Sound.HERO_DOWN -> Buf(1.2).apply {
            listOf(69, 65, 62, 57).forEachIndexed { i, n -> tone(i * 0.22, 0.4, midi(n), midi(n), 0.4, Wave.PULSE25, 0.2) }
        }
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
        Sound.ENCOUNTER -> Buf(0.9).apply {
            noise(0.0, 0.45, 0.6, 0.05, 35, swell = true, sweep = 0.8)
            tone(0.42, 0.45, 80.0, 40.0, 0.9, Wave.TRIANGLE, 0.15)
            noise(0.42, 0.4, 0.4, 0.5, 36)
            listOf(57, 63).forEach { n -> tone(0.42, 0.4, midi(n), midi(n), 0.2, Wave.SAW, 0.2) }
        }
    }.pcm()
}
