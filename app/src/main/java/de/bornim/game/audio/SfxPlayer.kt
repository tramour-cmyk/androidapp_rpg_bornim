package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import de.bornim.core.audio.PlaceSound
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
        .setMaxStreams(MAX_STREAMS)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()
    private val ids = ConcurrentHashMap<Sound, IntArray>()
    private val voices = ConcurrentHashMap<String, IntArray>()
    private val main = Handler(Looper.getMainLooper())
    var enabled = true

    init {
        val dir = File(context.cacheDir, "sfx-$VERSION").apply { mkdirs() }
        // 30.6: a file that will not load (missing, a full disk for the cache) only stays silent, it never ends the app
        thread(name = "sfx-render", isDaemon = true) { runCatching {
            for (v in Recorded.VOICES) for (c in Recorded.Cue.entries)
                voices["$v/${c.name}"] = IntArray(Recorded.VOICE_TAKES) { load(Recorded.voiceFile(v, c, it)) }
            for (s in Sound.entries) {
                // a recording where there is one
                val recorded = Recorded.TAKES[s]
                if (recorded != null) { ids[s] = IntArray(recorded) { load(Recorded.file(s, it)) }; continue }
                // several takes of battle sounds, one picked at random each time
                ids[s] = IntArray(Sfx.variants(s)) { v ->
                    runCatching {
                        val f = File(dir, "${s.name.lowercase()}_$v.wav")
                        if (!f.exists()) writeWav(f, Sfx.render(s, v))
                        pool.load(f.path, 1)
                    }.getOrDefault(0)
                }
            }
        } }
    }

    /** The take loaded from [asset], or 0 (silent) if it cannot be read. */
    private fun load(asset: String): Int = runCatching { context.assets.openFd(asset).use { pool.load(it, 1) } }.getOrDefault(0)

    fun play(s: Sound, volume: Float = 0.8f) {
        if (!enabled) return
        val takes = ids[s] ?: return
        pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, 1, 0, 1f)
    }

    /**
     * Plays one take of [s] over and over without a seam (the fire's crackle, 18k) and returns the stream, so its
     * volume can follow the hero; 0 if silent. The take stays until [stop]; the next start picks a new one.
     */
    fun loop(s: Sound, volume: Float): Int {
        if (!enabled) return 0
        val takes = ids[s] ?: return 0
        // D3.4: a loop ranks above the one-shots, so a burst of steps and calls takes the oldest one-shot, never the
        // fire or the wind (a stolen loop stayed silent until the place changed)
        return pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, LOOP_PRIORITY, -1, 1f)
    }

    fun volume(stream: Int, volume: Float) { if (stream != 0) pool.setVolume(stream, volume, volume) }

    fun stop(stream: Int) { if (stream != 0) pool.stop(stream) }

    /** Lets a loop that was at [from] die away and then stops it (24.8.5: leaving a place, its sound does not break off). */
    fun fadeOut(stream: Int, from: Float) {
        if (stream == 0) return
        if (from <= 0f) { pool.stop(stream); return }
        val start = SystemClock.uptimeMillis()
        main.post(object : Runnable {
            override fun run() {
                val v = PlaceSound.leaving(from, SystemClock.uptimeMillis() - start)
                if (v <= 0f) { pool.stop(stream); return }
                pool.setVolume(stream, v, v)
                main.postDelayed(this, FADE_TICK_MS)
            }
        })
    }

    /** The voice of the monster [id] for [cue] (a growl as it attacks, a yelp when struck, its death), if it has one. */
    fun voice(id: String, cue: Recorded.Cue, volume: Float = 0.8f) {
        if (!enabled) return
        val (v, rate) = Recorded.voiceOf(id) ?: return
        val takes = voices["$v/${cue.name}"] ?: return
        pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, 1, 0, rate)
    }

    fun release() {
        main.removeCallbacksAndMessages(null)
        pool.release()
    }

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
        private const val FADE_TICK_MS = 40L
        /** Three loops at most (fire, place bed, frog chorus) plus room for the one-shots. */
        private const val MAX_STREAMS = 8
        /** Above the one-shots (1); SoundPool stops the lowest-ranked stream when all are busy. */
        private const val LOOP_PRIORITY = 2
    }
}
