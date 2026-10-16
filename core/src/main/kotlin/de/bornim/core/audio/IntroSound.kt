package de.bornim.core.audio

import de.bornim.core.Intro
import kotlin.random.Random

/**
 * The quiet sounds under the intro's painted pictures (69c, `docs/STORY-K1.md`: „leise Wind, Fluss, Grillen“): wind and the
 * river loop, crickets chirp now and then. Each picture has its own mix, the loops follow its crossfade; with the black
 * picture everything dies away, so the title music carries it alone (69f). Pure and driven by the intro's clock.
 */
object IntroSound {
    /** How loud the two loops are now, and how often (ms between chirps, from–to) and how loud the crickets. */
    data class Mix(val wind: Float, val river: Float, val chirpMinMs: Long = 0, val chirpMaxMs: Long = 0, val cricket: Float = 0f)

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
        return Mix(blend(now.wind, before?.wind) * k, blend(now.river, before?.river) * k)
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
