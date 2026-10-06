package de.bornim.core

import de.bornim.core.audio.Songs
import de.bornim.core.audio.Synth
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MusicTest {
    @Test
    fun voicesHaveWholeBars() {
        for (song in Songs.all) for (v in song.voices) {
            val steps = Synth.stepsOf(v.notes)
            assertEquals(0, steps % 16, "${song.name}: voice ${v.wave} has $steps steps")
        }
        // All voices of a song have the same length so the loop lines up.
        for (song in Songs.all) assertEquals(1, song.voices.map { Synth.stepsOf(it.notes) }.toSet().size, song.name)
    }

    @Test
    fun rendersWithoutClippingAndExportsWav() {
        val out = File("build/music").apply { mkdirs() }
        for (song in Songs.all) {
            val pcm = Synth.render(song)
            val seconds = pcm.size.toDouble() / Synth.SAMPLE_RATE
            val peak = pcm.maxOf { abs(it.toInt()) }
            val rms = Math.sqrt(pcm.sumOf { it.toDouble() * it } / pcm.size)
            println("${song.name}: %.1fs peak=$peak rms=%.0f".format(seconds, rms))
            assertTrue(seconds in 10.0..60.0)
            assertTrue(peak < Short.MAX_VALUE * 0.95, "${song.name} clips")
            assertTrue(rms > 1500, "${song.name} too quiet")
            // Loop seam: first and last samples close together.
            assertTrue(abs(pcm.first() - pcm.last()) < 6000, "${song.name} clicks at the loop point")
            writeWav(File(out, "${song.name}.wav"), pcm)
        }
    }

    @Test
    fun soundEffectsRender() {
        val out = File("build/music/sfx").apply { mkdirs() }
        for (s in de.bornim.core.audio.Sound.entries) {
            val pcm = de.bornim.core.audio.Sfx.render(s)
            assertTrue(pcm.size in 500..(3 * Synth.SAMPLE_RATE), "$s length ${pcm.size}")
            assertTrue(pcm.maxOf { abs(it.toInt()) } > 10000, "$s silent")
            writeWav(File(out, "${s.name.lowercase()}.wav"), pcm)
        }
    }

    private fun writeWav(f: File, pcm: ShortArray) {
        val data = ByteBuffer.allocate(pcm.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        pcm.forEach { data.putShort(it) }
        val h = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)
        h.put("RIFF".toByteArray()).putInt(36 + pcm.size * 2).put("WAVE".toByteArray())
        h.put("fmt ".toByteArray()).putInt(16).putShort(1).putShort(1).putInt(Synth.SAMPLE_RATE).putInt(Synth.SAMPLE_RATE * 2).putShort(2).putShort(16)
        h.put("data".toByteArray()).putInt(pcm.size * 2)
        f.writeBytes(h.array() + data.array())
    }
}
