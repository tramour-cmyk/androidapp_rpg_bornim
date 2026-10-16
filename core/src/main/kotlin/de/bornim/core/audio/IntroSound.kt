package de.bornim.core.audio

import de.bornim.core.Intro
import kotlin.random.Random

/**
 * The quiet sounds under the intro's painted pictures (69c, `docs/STORY-K1.md`: „leise Wind, Fluss, Grillen“): wind and the
 * river loop, crickets chirp now and then. Each picture has its own mix, the loops follow its crossfade; with the black
 * picture the place dies away, and only the night is left under the title music (69c.1, [bell], [night]). Pure and driven
 * by the intro's clock.
 */
object IntroSound {
    /** How loud the two loops are now, and how often (ms between chirps, from–to) and how loud the crickets. */
    data class Mix(val wind: Float, val river: Float, val chirpMinMs: Long = 0, val chirpMaxMs: Long = 0, val cricket: Float = 0f, val bell: Float = 0f)

    /** Per picture: 1 the empty road, 2 the river and the bridge, 3 the sleeping square, 4 the inn's window; 5 black, silent. */
    val pictures = listOf(
        Mix(wind = 0.22f, river = 0f, chirpMinMs = 1800, chirpMaxMs = 4200, cricket = 0.24f),
        Mix(wind = 0.12f, river = 0.22f, chirpMinMs = 2600, chirpMaxMs = 5200, cricket = 0.18f),
        Mix(wind = 0.16f, river = 0.05f, chirpMinMs = 3500, chirpMaxMs = 7000, cricket = 0.14f),
        Mix(wind = 0.12f, river = 0f, chirpMinMs = 3500, chirpMaxMs = 7000, cricket = 0.14f),
        Mix(wind = 0f, river = 0f),
    )

    /** At the start the loops swell in from silence over this time, under the first picture's fade. */
    const val START_MS = 1500L

    /** The loops' loudness [ms] into the intro: the picture's mix, blended with the one before over its crossfade. */
    fun loops(ms: Long): Mix {
        val f = Intro.at(ms)
        val now = pictures[f.picture.coerceIn(0, pictures.size - 1)]
        val before = f.under?.let { pictures[it] }
        val k = (ms.toFloat() / START_MS).coerceIn(0f, 1f)
        val out = 1f - f.gone
        fun blend(a: Float, b: Float?) = (if (b == null) a else b + (a - b) * f.mix) * out
        return Mix(blend(now.wind, before?.wind) * k, blend(now.river, before?.river) * k, bell = bell(ms))
    }

    /** The bell under the black picture, measured against the title music's quiet start (it plays at 0.6, here −45 dB). */
    const val BELL = 0.12f
    /** The bell swells in over this time from the black picture's start, as if one only slowly noticed it. */
    const val BELL_IN_MS = 2500L

    /** How loud the bell rings [ms] into the intro: only under the black picture, dying away with the end's fade. */
    fun bell(ms: Long): Float {
        val f = Intro.at(ms)
        if (f.picture != Intro.black || f.done) return 0f
        val k = ((ms - Intro.black * Intro.STEP_MS).toFloat() / BELL_IN_MS).coerceIn(0f, 1f)
        return BELL * k * k * (3 - 2 * k) * (1 - f.gone)
    }

    /** One sound of the night at [ms] into the intro, at [volume], its [take] (of three). */
    data class Cue(val ms: Long, val sound: Sound, val volume: Float, val take: Int)

    /**
     * What is heard of the raid under the black picture (`[69.intro.5]`, 69b), [seed] shifts it a little: three shouts,
     * one after the other and each a different voice, then a single far scream; all before the end's fade. Loudness measured with
     * `tools/klang/nacht.py --proben` against the title music.
     */
    fun night(seed: Long): List<Cue> {
        val rnd = Random(seed)
        val at = Intro.black * Intro.STEP_MS
        fun near(ms: Long) = at + ms + rnd.nextLong(-300, 301)
        val voices = listOf(0, 1, 2).shuffled(rnd)
        return listOf(
            Cue(near(2300), Sound.FAR_SHOUT, 0.10f, voices[0]),
            Cue(near(3600), Sound.FAR_SHOUT, 0.08f, voices[1]),
            Cue(near(4600), Sound.FAR_SHOUT, 0.09f, voices[2]),
            Cue(near(5700), Sound.FAR_SCREAM, 0.12f, rnd.nextInt(3)),
        )
    }

    /**
     * The crickets' chirps up to [toMs] (ms into the intro) as (time, volume), [seed] picks the gaps: unevenly
     * spaced as the picture asks, slightly varied in loudness, none under the black picture.
     */
    fun chirps(seed: Long, toMs: Long): List<Pair<Long, Float>> {
        val rnd = Random(seed)
        val out = mutableListOf<Pair<Long, Float>>()
        var t = 600L + rnd.nextLong(1200)
        while (t < toMs) {
            val p = pictures[Intro.at(t).picture.coerceIn(0, pictures.size - 1)]
            if (p.cricket <= 0f) break
            out += t to p.cricket * (0.8f + 0.4f * rnd.nextFloat())
            t += rnd.nextLong(p.chirpMinMs, p.chirpMaxMs + 1)
        }
        return out
    }
}
