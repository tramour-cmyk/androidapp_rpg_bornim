package de.bornim.core

import de.bornim.core.audio.Sfx
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertTrue

/** The proposed sounds (not in the game yet) render: not silent, not cut off at the start, three different takes. */
class SoundProposalTest {
    @Test
    fun everyProposalRenders() {
        for (s in Sfx.PROPOSED + Sfx.PROPOSED_2) {
            val takes = (0..2).map { Sfx.proposal(s, it) }
            for ((v, pcm) in takes.withIndex()) {
                assertTrue(pcm.size > 1000, "$s take ${v + 1} too short")
                val peak = pcm.maxOf { abs(it.toInt()) }
                assertTrue(peak > 20000, "$s take ${v + 1} silent or broken (peak $peak)")
                // the end must have died away, so the sound does not click when it stops
                val tail = pcm.takeLast(200).maxOf { abs(it.toInt()) }
                assertTrue(tail < peak / 3, "$s take ${v + 1} cut off at the end (tail $tail of $peak)")
            }
            assertTrue(takes[0].toList() != takes[1].toList() && takes[1].toList() != takes[2].toList(), "$s takes are the same")
        }
    }

    @Test
    fun everyMonsterVoiceRenders() {
        for (id in Sfx.MONSTER_PROPOSED) for (cue in Sfx.MONSTER_CUES) for (v in 0..2) {
            val pcm = Sfx.monsterProposal(id, cue, v)
            assertTrue(pcm.size > 5000, "$id $cue ${v + 1} missing")
            assertTrue(pcm.maxOf { abs(it.toInt()) } > 20000, "$id $cue ${v + 1} silent")
        }
    }
}
