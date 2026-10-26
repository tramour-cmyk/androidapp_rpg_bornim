package de.bornim.core

/**
 * A cutscene (70, form in `docs/DESIGN-STIL.md` „Zwischensequenzen“): still pictures joined by soft crossfades, one short
 * sentence each; with [blackLast] the last picture is black (only its sentence). The clock is pure, so the timing is tested
 * in the core; the app only draws what [at] says.
 */
open class Reel(val lines: List<T>, val blackLast: Boolean) {
    val pictures get() = lines.size
    /** The black picture, or −1 when every picture is painted. */
    val black get() = if (blackLast) pictures - 1 else -1
    val totalMs get() = pictures * STEP_MS + END_MS

    companion object {
        /** How long one picture fades in over the one before. */
        const val FADE_MS = 1400L
        /** How long a picture stays after its fade. */
        const val HOLD_MS = 5800L
        const val STEP_MS = FADE_MS + HOLD_MS
        /** The sentence comes in after the picture and goes before the next one. */
        const val TEXT_IN_MS = 700L
        const val TEXT_OUT_MS = 500L
        /** At the end the screen fades into the game. */
        const val END_MS = 1200L
    }

    /**
     * What the screen shows [ms] after the start: [picture] fading in at [mix] (0..1) over [under] (the one before, or
     * null), its sentence at [text] (0..1); [gone] (0..1) how far the whole screen has faded out at the end; [done] when over.
     */
    data class Frame(val picture: Int, val under: Int?, val mix: Float, val text: Float, val gone: Float, val done: Boolean)

    fun at(ms: Long): Frame {
        val t = ms.coerceAtLeast(0L)
        val last = pictures - 1
        if (t >= totalMs) return Frame(last, null, 1f, 0f, 1f, true)
        val end = pictures * STEP_MS
        if (t >= end) return Frame(last, null, 1f, 0f, ((t - end).toFloat() / END_MS).coerceIn(0f, 1f), false)
        val i = (t / STEP_MS).toInt()
        val u = t - i * STEP_MS
        val mix = (u.toFloat() / FADE_MS).coerceIn(0f, 1f).let { it * it * (3 - 2 * it) }
        val inT = ((u - FADE_MS).toFloat() / TEXT_IN_MS).coerceIn(0f, 1f)
        val outT = ((STEP_MS - u).toFloat() / TEXT_OUT_MS).coerceIn(0f, 1f)
        return Frame(i, if (i > 0 && mix < 1f) i - 1 else null, mix, minOf(inT, outT), 0f, false)
    }
}

/**
 * The intro (69): the traveller arrives at Bornim by night, five still pictures (texts `[69.intro.1]` … `[69.intro.5]` in
 * `docs/STORY-K1-HANDLUNG.md`). Picture 5 is black. Shown once at the first start of a new hero, again from the chronicle.
 */
object Intro : Reel(
    listOf(
        T("Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.",
            "Three days north. The road is empty; only the moon walks with you."),
        T("Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht.",
            "Beyond the bridge, a few lights. Bornim. A bed for one night, that's all you want."),
        T("Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.",
            "The square is asleep. Only at the temple do torches wander. A late service, you think."),
        T("Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.",
            "A light still burns at the Sleeping Griffin. The innkeeper doesn't ask many questions."),
        T("Irgendwo schlägt eine Glocke. Du hörst sie nicht.",
            "Somewhere a bell is ringing. You do not hear it."),
    ),
    blackLast = true,
) {
    const val FADE_MS = Reel.FADE_MS
    const val HOLD_MS = Reel.HOLD_MS
    const val STEP_MS = Reel.STEP_MS
    const val TEXT_IN_MS = Reel.TEXT_IN_MS
    const val TEXT_OUT_MS = Reel.TEXT_OUT_MS
    const val END_MS = Reel.END_MS
}

/**
 * The temple scene at the end of chapter 1 (68): the sun amulet comes home at the morning service, five painted pictures
 * (texts `[68.tempel.1]` … `[68.tempel.5]` in `docs/STORY-K1-HANDLUNG.md`), the music „Ancient Legend“. Shown once after Aldric's
 * invitation and the night, again from the chronicle.
 */
object TempleScene : Reel(
    listOf(
        T("Der Tempel ist voll. Tagelang war er kalt und leer.",
            "The temple is full. For days it stood cold and empty."),
        T("Aldric gibt Lyra das Amulett. Sie hält es lange, als könnte es zerbrechen.",
            "Aldric gives Lyra the amulet. She holds it for a long time, as if it might break."),
        T("Osric hält die Kerze ruhig. Lyra betet in Worten, die älter sind als der Tempel selbst.",
            "Osric holds the candle steady. Lyra prays in words older than the temple itself."),
        T("Das erste Licht des Tages fällt durchs Fenster. Das Amulett fängt es auf.",
            "The first light of day falls through the window. The amulet catches it."),
        T("Bornim atmet auf. Nur Lyra sieht noch lange ins Grau hinaus.",
            "Bornim breathes again. Only Lyra keeps looking out into the gray for a long time."),
    ),
    blackLast = false,
)
