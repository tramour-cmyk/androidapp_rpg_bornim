package de.bornim.core.audio

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.tanh

enum class Wave { PULSE12, PULSE25, PULSE50, TRIANGLE, SAW, DRUMS }

/**
 * One voice of a song. [notes] uses a small text notation:
 * `c5:4` = C in octave 5 for 4 sixteenth steps, `a#4:2`, `r:4` = rest, `-:4` = hold the previous note.
 * Drum voices use `k` (kick), `s` (snare), `h` (hi-hat), `t` (taiko), `f` (soft frame drum),
 * `c` (cymbal crash) and `w` (cymbal swell) instead of pitches.
 * A duration may be left out to reuse the previous one.
 */
class Voice(
    val wave: Wave,
    val volume: Double,
    val notes: String,
    val vibrato: Boolean = false,
    val echo: Boolean = false,
    /** Seconds to fade in; long values give swelling strings. */
    val attack: Double = 0.004,
    /** Seconds a note rings on after it ends. */
    val release: Double = 0.03,
    /** Three slightly detuned oscillators, like a section of players. */
    val ensemble: Boolean = false,
    /** One-pole low-pass coefficient (1 = off); lower is darker. */
    val tone: Double = 1.0,
    /** Multi-tap delay that imitates a large hall. */
    val hall: Boolean = false,
    /** Seconds for a plucked note to fade to about a third (harp, pizzicato); 0 = sustained. */
    val pluck: Double = 0.0,
)

class Song(val name: String, val bpm: Int, val voices: List<Voice>)

/** A tiny chiptune synthesizer: renders a [Song] to looping 16-bit mono PCM. */
object Synth {
    const val SAMPLE_RATE = 22050

    private class Event(val start: Int, val length: Int, val midi: Int, val drum: Char?)

    private fun midiOf(token: String): Int {
        val name = token[0]
        var i = 1
        var semi = when (name) {
            'c' -> 0; 'd' -> 2; 'e' -> 4; 'f' -> 5; 'g' -> 7; 'a' -> 9; 'b' -> 11
            else -> error("Bad note $token")
        }
        if (i < token.length && token[i] == '#') { semi++; i++ }
        if (i < token.length && token[i] == 'b' && token.length > i + 1) { semi--; i++ }
        val octave = token.substring(i).toInt()
        return 12 * (octave + 1) + semi
    }

    /** Parses a voice into events, measured in sixteenth steps. Returns events and total steps. */
    private fun parse(notes: String): Pair<List<Event>, Int> {
        val events = mutableListOf<Event>()
        var pos = 0
        var dur = 4
        for (raw in notes.trim().split(Regex("\\s+"))) {
            if (raw.isEmpty() || raw == "|") continue
            val parts = raw.split(":")
            if (parts.size > 1) dur = parts[1].toInt()
            val tok = parts[0]
            when {
                tok == "r" -> {}
                tok == "-" -> {
                    val last = events.removeLastOrNull()
                    if (last != null) events += Event(last.start, last.length + dur, last.midi, last.drum)
                }
                tok.length == 1 && tok[0] in "kshtfcw" -> events += Event(pos, dur, 0, tok[0])
                else -> events += Event(pos, dur, midiOf(tok), null)
            }
            pos += dur
        }
        return events to pos
    }

    fun stepsOf(notes: String): Int = parse(notes).second

    fun render(song: Song): ShortArray {
        val stepSamples = SAMPLE_RATE * 60.0 / song.bpm / 4.0
        val parsed = song.voices.map { parse(it.notes) }
        val totalSteps = parsed.maxOf { it.second }
        val total = (totalSteps * stepSamples).toInt()
        val mix = DoubleArray(total)
        var noise = 0x1234

        song.voices.zip(parsed).forEach { (voice, p) ->
            val (events, steps) = p
            val buf = DoubleArray(total)
            // Shorter voices repeat until the song ends.
            var offset = 0
            while (offset < totalSteps) {
                for (e in events) {
                    val start = ((offset + e.start) * stepSamples).toInt()
                    if (start >= total) continue
                    val len = (e.length * stepSamples).toInt()
                    if (e.drum != null) {
                        val dlen = when (e.drum) { 'k' -> 0.16; 's' -> 0.14; 't' -> 0.9; 'f' -> 0.35; 'c' -> 1.6; 'w' -> (e.length * stepSamples / SAMPLE_RATE); else -> 0.05 }.times(SAMPLE_RATE).toInt()
                        for (i in 0 until minOf(dlen, total - start)) {
                            val t = i.toDouble() / SAMPLE_RATE
                            val env = (1.0 - i.toDouble() / dlen).pow(2)
                            noise = (noise shl 1) or (((noise shr 14) xor (noise shr 13)) and 1)
                            val n = if (noise and 1 == 1) 1.0 else -1.0
                            val v = when (e.drum) {
                                'k' -> sin(2 * PI * (110.0 * (1 - t * 4).coerceAtLeast(0.25)) * t) * 1.2
                                's' -> n * 0.7 + sin(2 * PI * 190 * t) * 0.3
                                't' -> sin(2 * PI * (62.0 + 40 * kotlin.math.exp(-t * 18)) * t) * 1.4 + n * 0.25 * kotlin.math.exp(-t * 30)
                                'f' -> sin(2 * PI * (120.0 + 60 * kotlin.math.exp(-t * 25)) * t) * 0.9 + n * 0.12 * kotlin.math.exp(-t * 40)
                                'c' -> n * 0.5 * kotlin.math.exp(-t * 2.2)
                                'w' -> n * 0.35 * (i.toDouble() / dlen).pow(2) / maxOf(env, 1e-3)
                                else -> n * 0.35
                            }
                            buf[start + i] += v * env
                        }
                        continue
                    }
                    val freq = 440.0 * 2.0.pow((e.midi - 69) / 12.0)
                    val detunes = if (voice.ensemble) doubleArrayOf(1.0, 1.0059, 0.9943) else doubleArrayOf(1.0)
                    val phases = DoubleArray(detunes.size) { it * 0.31 }
                    val release = maxOf((voice.release * SAMPLE_RATE).toInt(), 1)
                    val attackLen = voice.attack * SAMPLE_RATE
                    val noteLen = len + release
                    for (i in 0 until noteLen) {
                        val idx = (start + i) % total // tails wrap around so the loop stays seamless
                        val t = i.toDouble() / SAMPLE_RATE
                        val vib = if (voice.vibrato && t > 0.18) 1.0 + 0.006 * sin(2 * PI * 5.5 * t) else 1.0
                        var v = 0.0
                        for (d in detunes.indices) {
                            phases[d] += freq * vib * detunes[d] / SAMPLE_RATE
                            phases[d] -= phases[d].toInt()
                            val ph = phases[d]
                            v += when (voice.wave) {
                                Wave.PULSE12 -> if (ph < 0.125) 1.0 else -1.0
                                Wave.PULSE25 -> if (ph < 0.25) 1.0 else -1.0
                                Wave.PULSE50 -> if (ph < 0.5) 1.0 else -1.0
                                Wave.TRIANGLE -> 4 * abs(ph - 0.5) - 1
                                Wave.SAW -> 2 * ph - 1
                                Wave.DRUMS -> 0.0
                            }
                        }
                        v /= detunes.size
                        val attack = minOf(1.0, i / attackLen)
                        val decay = when {
                            voice.pluck > 0 -> kotlin.math.exp(-t / voice.pluck)
                            voice.wave == Wave.TRIANGLE || voice.wave == Wave.SAW -> 1.0
                            else -> 0.65 + 0.35 * (1.0 / (1.0 + t * 3))
                        }
                        val rel = if (i >= len) (noteLen - i).toDouble() / release else 1.0
                        buf[idx] += v * attack * decay * rel
                    }
                }
                offset += steps
            }
            if (voice.tone < 1.0) {
                var lp = 0.0
                for (pass in 0..1) for (i in 0 until total) {
                    lp += (buf[i] - lp) * voice.tone
                    if (pass == 1) buf[i] = lp
                }
            }
            if (voice.hall) {
                val dry = buf.copyOf()
                for ((delaySec, gain) in listOf(0.089 to 0.32, 0.137 to 0.26, 0.211 to 0.2, 0.293 to 0.15, 0.41 to 0.1)) {
                    val delay = (delaySec * SAMPLE_RATE).toInt()
                    for (i in 0 until total) buf[i] += dry[(i - delay + total) % total] * gain
                }
            }
            if (voice.echo) {
                val delay = (stepSamples * 3).toInt()
                for (i in total - 1 downTo 0) {
                    val src = (i - delay + total) % total // wraps so the loop stays seamless
                    buf[i] += buf[src] * 0.28
                }
            }
            for (i in 0 until total) mix[i] += buf[i] * voice.volume
        }

        // Gentle low-pass to take the edge off the square waves, then soft clipping.
        val out = ShortArray(total)
        var lp = 0.0
        for (pass in 0..1) for (i in 0 until total) {
            lp += (mix[i] - lp) * 0.55
            if (pass == 1) out[i] = (tanh(lp * 0.9) * 0.85 * Short.MAX_VALUE).toInt().toShort()
        }
        return out
    }
}
