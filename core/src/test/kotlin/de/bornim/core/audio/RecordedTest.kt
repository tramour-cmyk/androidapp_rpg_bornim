package de.bornim.core.audio

import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The recorded sounds (18): every file is there, system sounds come once, all others at least three times. */
class RecordedTest {
    private val assets = File("../app/src/main/assets")

    private fun all(): List<String> =
        Recorded.TAKES.flatMap { (s, n) -> (0 until n).map { Recorded.file(s, it) } } +
            Recorded.VOICES.flatMap { v -> Recorded.Cue.entries.flatMap { c -> (0 until Recorded.VOICE_TAKES).map { Recorded.voiceFile(v, c, it) } } }

    @Test
    fun everyRecordedSoundHasItsFiles() {
        val missing = all().filterNot { File(assets, it).isFile }
        assertTrue(missing.isEmpty(), "fehlende Klangdateien: $missing")
        // and no file lies there unused
        val extra = File(assets, "sfx").listFiles().orEmpty().map { "sfx/${it.name}" } - all().toSet()
        assertTrue(extra.isEmpty(), "Klangdateien ohne Verwendung: $extra")
    }

    @Test
    fun systemSoundsOnceAllOthersThrice() {
        for (s in Sfx.SYSTEM) assertEquals(1, Recorded.TAKES[s] ?: Sfx.variants(s), "$s ist ein Systemklang")
        for ((s, n) in Recorded.TAKES) if (s !in Sfx.SYSTEM && s !in Recorded.FEWER) assertTrue(n >= 3, "$s braucht mindestens drei Fassungen")
        assertEquals(3, Recorded.VOICE_TAKES)
    }

    @Test
    fun voicesForTheThreeKinds() {
        assertEquals("wolf", Recorded.voiceOf("dire_wolf")?.first)
        assertEquals("goblin", Recorded.voiceOf("goblin_archer")?.first)
        assertEquals("skeleton", Recorded.voiceOf("skeleton")?.first)
        assertEquals("ochre_jelly", Recorded.voiceOf("ochre_jelly")?.first)
        assertEquals("bugbear", Recorded.voiceOf("bugbear")?.first)
        assertEquals(null, Recorded.voiceOf("nobody"))
    }

    @Test
    fun eliteSoundsDeeperButNotAsDeepAsGrimfang() {
        val wolf = Recorded.voiceOf("wolf")!!.second
        val elite = Recorded.voiceOf("wolf", elite = true)!!.second
        assertTrue(elite < wolf, "Elite tiefer (140)")
        assertTrue(elite > Recorded.voiceOf("dire_wolf")!!.second, "Grimmzahn bleibt am tiefsten")
        assertEquals("goblin", Recorded.voiceOf("goblin_shaman", elite = true)?.first)
    }

    @Test
    fun everyMonsterHasAVoice() {
        val mute = de.bornim.core.Monsters.all.map { it.id }.filter { Recorded.voiceOf(it) == null }
        assertTrue(mute.isEmpty(), "Gegner ohne Stimme (18.11): $mute")
    }
}
