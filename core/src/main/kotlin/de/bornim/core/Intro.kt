package de.bornim.core

/**
 * The intro (69): the traveller arrives at Bornim by night, five still pictures joined by soft crossfades, one short
 * sentence each (texts `[69.intro.1]` … `[69.intro.5]` in `docs/STORY-K1.md`, form in `docs/DESIGN-STIL.md`
 * „Zwischensequenzen“). Picture 5 is black. Shown once at the first start of a new hero, again from the chronicle.
 * The clock is pure, so the timing is tested in the core; the app only draws what [at] says.
 */
object Intro {
    val lines = listOf(
        T("Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.",
            "Three days north. The road is empty; only the moon walks with you."),
        T("Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht.",
            "Beyond the bridge, a few lights. Bornim. A bed for one night, nothing more."),
        T("Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.",
            "The square is asleep. Only at the temple do torches wander. A late prayer, you think."),
        T("Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.",
            "A light still burns in the »Sleeping Griffin«. The innkeeper does not ask much."),
        T("Irgendwo schlägt eine Glocke. Du hörst sie nicht.",
            "Somewhere a bell is ringing. You do not hear it."),
    )
    val pictures get() = lines.size
    /** The last picture is black: no image, only its sentence (and the title music, 69c). */
    val black get() = pictures - 1

    /** How long one picture fades in over the one before. */
    const val FADE_MS = 1400L
    /** How long a picture stays after its fade. */
    const val HOLD_MS = 5800L
    const val STEP_MS = FADE_MS + HOLD_MS
    /** The sentence comes in after the picture and goes before the next one. */
    const val TEXT_IN_MS = 700L
    const val TEXT_OUT_MS = 500L
    /** At the end the black screen fades into the game. */
    const val END_MS = 1200L
    val totalMs get() = pictures * STEP_MS + END_MS

    /**
     * What the screen shows [ms] after the start: [picture] fading in at [mix] (0..1) over [under] (the one before, or
     * null), its sentence at [text] (0..1); [gone] (0..1) how far the whole screen has faded out at the end; [done] when over.
     */
    data class Frame(val picture: Int, val under: Int?, val mix: Float, val text: Float, val gone: Float, val done: Boolean)

    fun at(ms: Long): Frame {
        val t = ms.coerceAtLeast(0L)
        if (t >= totalMs) return Frame(black, null, 1f, 0f, 1f, true)
        val end = pictures * STEP_MS
        if (t >= end) return Frame(black, null, 1f, 0f, ((t - end).toFloat() / END_MS).coerceIn(0f, 1f), false)
        val i = (t / STEP_MS).toInt()
        val u = t - i * STEP_MS
        val mix = (u.toFloat() / FADE_MS).coerceIn(0f, 1f).let { it * it * (3 - 2 * it) }
        val inT = ((u - FADE_MS).toFloat() / TEXT_IN_MS).coerceIn(0f, 1f)
        val outT = ((STEP_MS - u).toFloat() / TEXT_OUT_MS).coerceIn(0f, 1f)
        return Frame(i, if (i > 0 && mix < 1f) i - 1 else null, mix, minOf(inT, outT), 0f, false)
    }
}
