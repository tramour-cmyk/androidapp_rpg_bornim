package de.bornim.core.audio

/** Original compositions for the game. All bars are 4/4 = 16 sixteenth steps. */
object Songs {
    private val names = listOf("c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b")

    private fun note(midi: Int) = names[midi % 12] + (midi / 12 - 1)

    /** Chord symbol like "G", "Em", "A#" to root (MIDI, octave 3) and triad intervals. */
    private fun chord(sym: String): Pair<Int, List<Int>> {
        val minor = sym.endsWith("m")
        val rootName = sym.removeSuffix("m").lowercase()
        val root = 48 + names.indexOf(rootName)
        return root to if (minor) listOf(0, 3, 7) else listOf(0, 4, 7)
    }

    /** Eighth-note bass: root, octave, fifth, octave – twice per bar. */
    private fun bass(chords: List<String>, octaveShift: Int = -12): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        val b = r + octaveShift
        listOf(b, b + 12, b + iv[2], b + 12, b, b + 12, b + iv[2], b + 12).joinToString(" ") { note(it) + ":2" }
    }

    /** Driving bass for fights: repeated root eighths with a fifth at the end of the bar. */
    private fun drivingBass(chords: List<String>): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        val b = r - 12
        listOf(b, b, b + 12, b, b, b + 12, b + iv[2], b + 12).joinToString(" ") { note(it) + ":2" }
    }

    /** Sixteenth arpeggios over the chord tones. */
    private fun arp(chords: List<String>, octave: Int = 12): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        val tones = listOf(r + iv[0], r + iv[1], r + iv[2], r + 12 + iv[0]).map { it + octave }
        (0 until 16).joinToString(" ") { i -> note(tones[listOf(0, 1, 2, 3, 2, 1)[i % 6]]) + ":1" }
    }

    /** Sustained chord tones in quarter notes, a softer accompaniment. */
    private fun pads(chords: List<String>): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        listOf(r + 12 + iv[1], r + 12 + iv[2], r + 12 + iv[1], r + 12 + iv[0]).joinToString(" ") { note(it) + ":4" }
    }

    private fun drums(bar: String, bars: Int) = List(bars) { bar }.joinToString(" ")

    // ------------------------------------------------------------------ Overworld: "Bornim", G major

    private val townChords = listOf("G", "D", "Em", "C", "G", "C", "D", "D", "Em", "C", "G", "D", "C", "D", "G", "G")

    /** One drum pattern per bar; bars marked with a crash get a cymbal on top. */
    private fun drumBars(bars: Int, pattern: String, crashBars: Set<Int> = emptySet(), last: String? = null): String =
        (0 until bars).joinToString(" | ") { b ->
            val p = if (b == bars - 1 && last != null) last else pattern
            if (b in crashBars) "c:0 $p" else p
        }

    val overworld = Song(
        "overworld", 104,
        listOf(
            // flute melody
            Voice(
                Wave.TRIANGLE, 0.34, vibrato = true, attack = 0.04, release = 0.25, hall = true, notes = """
                d5:4 b4:2 d5:2 g5:6 f#5:2 | e5:4 d5:4 a4:8 | b4:4 c5:2 d5:2 e5:4 g5:4 | e5:6 d5:2 c5:8
                d5:4 b4:2 d5:2 g5:6 a5:2 | b5:4 a5:2 g5:2 e5:8 | f#5:4 g5:2 a5:2 f#5:4 d5:4 | e5:4 f#5:4 d5:8
                g5:6 f#5:2 e5:4 b4:4 | c5:4 e5:4 g5:8 | d5:6 c5:2 b4:4 d5:4 | a4:4 b4:2 c5:2 d5:8
                e5:4 g5:4 c6:4 b5:2 a5:2 | b5:4 a5:2 f#5:2 f#5:8 | g5:4 d5:2 b4:2 g4:4 b4:4 | d5:4 b4:4 g4:8
                """,
            ),
            // warm string pad
            Voice(Wave.SAW, 0.09, sustained(townChords, 12, 1), attack = 0.6, release = 0.6, ensemble = true, tone = 0.07, hall = true),
            Voice(Wave.SAW, 0.07, sustained(townChords, 0, 2), attack = 0.7, release = 0.6, ensemble = true, tone = 0.06, hall = true),
            // harp
            Voice(Wave.TRIANGLE, 0.13, arp(townChords, 12), pluck = 0.16, release = 0.2, hall = true),
            // pizzicato bass
            Voice(Wave.SAW, 0.22, bass(townChords), pluck = 0.12, tone = 0.15, release = 0.1),
            Voice(Wave.DRUMS, 0.13, drumBars(16, "f:4 h:2 h:2 f:2 f:2 h:4", crashBars = setOf(0, 8))),
        ),
    )

    // ------------------------------------------------------------------ Battle, A minor

    private val battleChords = listOf("Am", "F", "G", "E", "Am", "F", "Dm", "E", "F", "G", "Am", "Am", "F", "G", "E", "E")

    val battle = Song(
        "battle", 150,
        listOf(
            // horn melody
            Voice(
                Wave.SAW, 0.20, vibrato = true, attack = 0.03, release = 0.15, ensemble = true, tone = 0.14, hall = true, notes = """
                a4:2 c5:2 e5:2 a5:4 g5:2 e5:2 c5:2 | f5:4 e5:2 d5:2 c5:4 a4:4 | b4:2 d5:2 g5:2 b5:4 a5:2 g5:2 d5:2 | g#5:6 a5:2 b5:4 g#5:4
                a5:4 e5:2 a5:2 c6:4 b5:2 a5:2 | a5:4 f5:4 c5:4 f5:4 | d5:2 f5:2 a5:2 d6:4 c6:2 a5:2 f5:2 | e5:4 g#5:4 b5:6 r:2
                c6:4 a5:2 f5:2 c5:4 f5:4 | d6:4 b5:2 g5:2 d5:4 g5:4 | e6:6 d6:2 c6:4 a5:4 | b5:2 c6:2 b5:2 a5:2 e5:8
                a5:4 c6:4 f5:4 a5:4 | b5:4 d6:4 g5:4 b5:4 | g#5:2 a5:2 b5:2 c6:2 d6:4 b5:4 | e6:8 e5:8
                """,
            ),
            // driving string ostinato and low strings
            Voice(Wave.SAW, 0.12, arp(battleChords, 0), pluck = 0.09, tone = 0.12, release = 0.05),
            Voice(Wave.SAW, 0.20, drivingBass(battleChords), pluck = 0.2, tone = 0.08, release = 0.05),
            Voice(Wave.TRIANGLE, 0.30, drivingBass(battleChords)),
            // sustained pad
            Voice(Wave.SAW, 0.06, sustained(battleChords, 12, 1), attack = 0.3, release = 0.4, ensemble = true, tone = 0.06, hall = true),
            Voice(Wave.DRUMS, 0.24, drumBars(16, "t:2 h:1 h:1 s:2 h:2 t:1 t:1 h:2 s:2 h:2", crashBars = setOf(0, 8))),
        ),
    )

    // ------------------------------------------------------------------ Boss, D minor

    private val bossChords = listOf("Dm", "A#", "C", "A", "Dm", "Gm", "A#", "A", "Gm", "Dm", "A#", "C", "Gm", "A", "A", "A")

    val boss = Song(
        "boss", 160,
        listOf(
            // brass theme
            Voice(
                Wave.SAW, 0.20, vibrato = true, attack = 0.04, release = 0.2, ensemble = true, tone = 0.16, hall = true, notes = """
                d5:6 a4:2 d5:2 e5:2 f5:4 | g5:4 f5:2 d5:2 a#4:8 | c5:2 e5:2 g5:2 c6:6 a#5:2 a5:2 | a5:8 g5:2 f5:2 e5:2 c#5:2
                d6:4 a5:2 f5:2 d5:4 f5:2 a5:2 | a#5:4 a5:2 g5:2 d5:4 g5:4 | f5:4 d5:2 a#4:2 f5:4 a#5:4 | a5:4 g5:2 f5:2 e5:2 d5:2 c#5:4
                g5:4 a#5:4 d6:6 c6:2 | a5:4 f5:4 d5:8 | f5:2 a#5:2 d6:2 f6:6 d6:2 a#5:2 | c6:4 g5:4 e5:4 c5:4
                d5:2 g5:2 a#5:2 d6:2 g6:4 f6:2 d6:2 | c#6:4 e6:4 a5:8 | a5:2 a#5:2 a5:2 g5:2 f5:2 e5:2 d5:2 c#5:2 | e5:4 a4:4 c#5:4 e5:4
                """,
            ),
            // dark choir-like pad
            Voice(Wave.SAW, 0.11, sustained(bossChords, 0, 1), attack = 0.5, release = 0.5, ensemble = true, tone = 0.05, hall = true),
            Voice(Wave.SAW, 0.09, sustained(bossChords, -12, 2), attack = 0.5, release = 0.5, ensemble = true, tone = 0.05, hall = true),
            // string ostinato
            Voice(Wave.SAW, 0.11, arp(bossChords, 0), pluck = 0.08, tone = 0.12, release = 0.05),
            // low end
            Voice(Wave.TRIANGLE, 0.38, drivingBass(bossChords)),
            Voice(Wave.SAW, 0.12, drivingBass(bossChords), pluck = 0.25, tone = 0.06),
            Voice(Wave.DRUMS, 0.26, drumBars(16, "t:2 t:2 s:2 t:2 t:2 t:2 s:2 s:1 s:1", crashBars = setOf(0, 8), last = "t:2 t:2 t:2 t:2 w:8")),
        ),
    )

    // ------------------------------------------------------------------ Title: epic, cinematic, D minor

    private val titleChords = listOf(
        "Dm", "A#", "F", "C", "Dm", "A#", "F", "A",
        "Dm", "Gm", "A#", "C", "Dm", "A#", "C", "A",
    )

    /** Whole-bar chord tones for the string ensemble. */
    private fun sustained(chords: List<String>, octave: Int, tone: Int): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        note(r + octave + iv[tone]) + ":16"
    }

    /** Cello ostinato: pulsing eighths, root – fifth – octave – fifth. */
    private fun ostinato(chords: List<String>): String = chords.joinToString(" ") { sym ->
        val (r, iv) = chord(sym)
        val b = r - 12
        listOf(b, b + iv[2], b + 12, b + iv[2], b, b + iv[2], b + 12, b + iv[2]).joinToString(" ") { note(it) + ":2" }
    }

    val title = Song(
        "title", 76,
        listOf(
            // horn theme: silent in the intro, then a rising heroic line and a climax an octave up
            Voice(
                Wave.SAW, 0.20, vibrato = true, attack = 0.12, release = 0.5, ensemble = true, tone = 0.12, hall = true, notes = """
                r:16 r:16 r:16 r:16
                a4:8 d5:4 e5:4 | f5:12 e5:2 d5:2 | c5:8 a4:4 c5:4 | e5:8 c#5:4 e5:4
                f5:8 e5:4 d5:4 | g5:8 f5:4 d5:4 | f5:12 g5:2 f5:2 | e5:8 g5:8
                a5:8 d6:8 | d6:4 c6:4 a#5:4 a5:4 | g5:8 e5:4 g5:4 | a5:16
                """,
            ),
            // high strings, swelling chords
            Voice(Wave.SAW, 0.11, sustained(titleChords, 12, 1), attack = 1.2, release = 1.0, ensemble = true, tone = 0.08, hall = true),
            Voice(Wave.SAW, 0.08, sustained(titleChords, 0, 2), attack = 1.5, release = 1.0, ensemble = true, tone = 0.06, hall = true),
            // low strings ostinato
            Voice(Wave.SAW, 0.16, ostinato(titleChords), attack = 0.02, release = 0.08, tone = 0.1),
            // deep drone on the chord roots
            Voice(Wave.TRIANGLE, 0.40, titleChords.joinToString(" ") { note(chord(it).first - 24) + ":16" }, attack = 0.3, release = 0.6),
            // war drums, building up
            Voice(
                Wave.DRUMS, 0.30, """
                t:8 t:8 | t:8 t:8 | t:8 t:8 | t:8 t:4 t:4
                t:4 t:2 t:2 t:4 t:4 | t:4 t:2 t:2 t:4 t:4 | t:4 t:2 t:2 t:4 t:4 | t:4 t:2 t:2 t:2 t:2 t:2 t:2
                t:4 t:2 t:2 t:4 t:2 t:2 | t:4 t:2 t:2 t:4 t:2 t:2 | t:4 t:2 t:2 t:4 t:2 t:2 | t:2 t:2 t:2 t:2 t:2 t:2 t:1 t:1 t:1 t:1
                t:2 t:2 t:4 t:2 t:2 t:4 | t:2 t:2 t:4 t:2 t:2 t:4 | t:2 t:2 t:4 t:2 t:2 t:2 t:2 | t:8 s:8
                """,
            ),
        ),
    )

    val all = listOf(title, overworld, battle, boss)
}
