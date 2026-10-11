package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import de.bornim.core.audio.Recorded
import de.bornim.core.audio.Sfx
import de.bornim.core.audio.Sound
import de.bornim.core.audio.Synth
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ConcurrentHashMap
import kotlin.concurrent.thread

/**
 * Plays the sound effects: the recorded ones from the app's files ([Recorded], 18), the others synthesized and rendered
 * once into the cache as WAV files; and the creatures' voices.
 */
class SfxPlayer(private val context: Context) {
    private val pool = SoundPool.Builder()
        .setMaxStreams(6)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()
    private val ids = ConcurrentHashMap<Sound, IntArray>()
    private val voices = ConcurrentHashMap<String, IntArray>()
    var enabled = true

    init {
        val dir = File(context.cacheDir, "sfx-$VERSION").apply { mkdirs() }
        thread(name = "sfx-render", isDaemon = true) {
            for (v in Recorded.VOICES) for (c in Recorded.Cue.entries)
                voices["$v/${c.name}"] = IntArray(Recorded.VOICE_TAKES) { load(Recorded.voiceFile(v, c, it)) }
            for (s in Sound.entries) {
                // a recording where there is one
                val recorded = Recorded.TAKES[s]
                if (recorded != null) { ids[s] = IntArray(recorded) { load(Recorded.file(s, it)) }; continue }
                // several takes of battle sounds, one picked at random each time
                ids[s] = IntArray(Sfx.variants(s)) { v ->
                    val f = File(dir, "${s.name.lowercase()}_$v.wav")
                    if (!f.exists()) writeWav(f, Sfx.render(s, v))
                    pool.load(f.path, 1)
                }
            }
        }
    }

    private fun load(asset: String): Int = context.assets.openFd(asset).use { pool.load(it, 1) }

    fun play(s: Sound, volume: Float = 0.8f) {
        if (!enabled) return
        val takes = ids[s] ?: return
        pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, 1, 0, 1f)
    }

    /** The voice of the monster [id] for [cue] (a growl as it attacks, a yelp when struck, its death), if it has one. */
    fun voice(id: String, cue: Recorded.Cue, volume: Float = 0.8f) {
        if (!enabled) return
        val (v, rate) = Recorded.voiceOf(id) ?: return
        val takes = voices["$v/${cue.name}"] ?: return
        pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, 1, 0, rate)
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
        private const val VERSION = 4
    }
}
