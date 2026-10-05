package de.bornim.game.audio

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import de.bornim.core.audio.Song
import de.bornim.core.audio.Songs
import de.bornim.core.audio.Synth
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

/** Plays the synthesized songs as seamless loops. Songs are rendered once in the background. */
class MusicPlayer {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val cache = ConcurrentHashMap<String, ShortArray>()
    private var track: AudioTrack? = null
    private var current: Song? = null
    private var enabled = true
    private var paused = false

    init {
        scope.launch { Songs.all.forEach { pcm(it) } }
    }

    private fun pcm(song: Song): ShortArray = cache.getOrPut(song.name) { Synth.render(song) }

    @Synchronized
    fun play(song: Song?) {
        if (song == current && track != null) return
        current = song
        restart()
    }

    @Synchronized
    fun setEnabled(on: Boolean) {
        enabled = on
        restart()
    }

    @Synchronized
    fun pause() {
        paused = true
        stopTrack()
    }

    @Synchronized
    fun resume() {
        paused = false
        restart()
    }

    fun release() {
        synchronized(this) { stopTrack() }
        scope.cancel()
    }

    private fun restart() {
        stopTrack()
        val song = current ?: return
        if (!enabled || paused) return
        scope.launch {
            val data = pcm(song)
            synchronized(this@MusicPlayer) {
                if (current != song || !enabled || paused || track != null) return@launch
                track = runCatching { build(data) }.getOrNull()?.also { it.play() }
            }
        }
    }

    private fun build(data: ShortArray): AudioTrack {
        val t = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(Synth.SAMPLE_RATE)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setTransferMode(AudioTrack.MODE_STATIC)
            .setBufferSizeInBytes(data.size * 2)
            .build()
        t.write(data, 0, data.size)
        t.setLoopPoints(0, data.size, -1)
        t.setVolume(0.6f)
        return t
    }

    private fun stopTrack() {
        track?.let {
            runCatching { it.stop() }
            it.release()
        }
        track = null
    }
}
