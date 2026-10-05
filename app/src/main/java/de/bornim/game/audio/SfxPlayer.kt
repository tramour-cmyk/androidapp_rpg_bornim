package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import de.bornim.core.audio.Sfx
import de.bornim.core.audio.Sound
import de.bornim.core.audio.Synth
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ConcurrentHashMap
import kotlin.concurrent.thread

/** Plays the synthesized sound effects. They are rendered once into the cache as WAV files. */
class SfxPlayer(context: Context) {
    private val pool = SoundPool.Builder()
        .setMaxStreams(6)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()
    private val ids = ConcurrentHashMap<Sound, Int>()
    var enabled = true

    init {
        val dir = File(context.cacheDir, "sfx-$VERSION").apply { mkdirs() }
        thread(name = "sfx-render", isDaemon = true) {
            for (s in Sound.entries) {
                val f = File(dir, "${s.name.lowercase()}.wav")
                if (!f.exists()) writeWav(f, Sfx.render(s))
                ids[s] = pool.load(f.path, 1)
            }
        }
    }

    fun play(s: Sound, volume: Float = 0.8f) {
        if (!enabled) return
        val id = ids[s] ?: return
        pool.play(id, volume, volume, 1, 0, 1f)
    }

    fun release() = pool.release()

    private fun writeWav(f: File, pcm: ShortArray) {
        val data = ByteBuffer.allocate(44 + pcm.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        data.put("RIFF".toByteArray()).putInt(36 + pcm.size * 2).put("WAVE".toByteArray())
        data.put("fmt ".toByteArray()).putInt(16).putShort(1).putShort(1)
            .putInt(Synth.SAMPLE_RATE).putInt(Synth.SAMPLE_RATE * 2).putShort(2).putShort(16)
        data.put("data".toByteArray()).putInt(pcm.size * 2)
        pcm.forEach { data.putShort(it) }
        f.writeBytes(data.array())
    }

    companion object {
        /** Bump when the sounds change so the cache is rebuilt. */
        private const val VERSION = 1
    }
}
