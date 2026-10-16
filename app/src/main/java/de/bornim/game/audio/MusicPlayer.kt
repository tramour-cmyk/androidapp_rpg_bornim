package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import de.bornim.core.audio.MusicDirector
import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.MusicWant

/**
 * Plays the recorded music from `assets/music` (28.1): [MusicDirector] decides what plays, this fades between pieces
 * (a new piece fades in while the old one fades out) and lays the cave's sound bed underneath. Runs on the main thread.
 */
class MusicPlayer(private val context: Context) {
    private val director = MusicDirector()
    private val handler = Handler(Looper.getMainLooper())
    private var scene = MusicScene.TITLE
    private var enabled = true
    private var paused = false
    /** The sliders' factor for the music (40). */
    var gain = 1f
    /** For the cave's sound bed: a place's sound, so under the effects (40a). */
    var bedGain = 1f
    private var ticking = false
    private var finished: String? = null
    private var music: Voice? = null
    private var bed: Voice? = null
    /** Voices fading out, released at silence. */
    private val leaving = ArrayList<Voice>()
    /** Players stopped by [pause], started again by [resume]. */
    private val held = ArrayList<MediaPlayer>()

    private inner class Voice(val name: String, looped: Boolean, var level: Float, val isBed: Boolean = false) {
        val mp: MediaPlayer? = runCatching {
            context.assets.openFd("music/$name.ogg").use { fd ->
                MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()
                    )
                    setDataSource(fd.fileDescriptor, fd.startOffset, fd.length)
                    isLooping = looped
                    setOnCompletionListener { if (!looped) finished = name }
                    prepare()
                    setVolume(0f, 0f)
                    start()
                }
            }
        }.getOrNull()
        var vol = 0f
        var step = 1f
        private var aim = Float.NaN

        /** Towards [target] in about [ms], whatever the distance (asked again every tick: only a new target sets the pace). */
        fun fadeTo(target: Float, ms: Int) {
            if (target == aim) return
            aim = target
            level = target
            step = if (ms <= 0) 1f else maxOf(kotlin.math.abs(target - vol), 0.01f) * TICK_MS / ms
        }

        /** One fade step; true once it has gone silent. */
        fun tick(): Boolean {
            vol = if (vol < level) minOf(level, vol + step) else maxOf(level, vol - step)
            val g = vol * (if (isBed) bedGain else gain)
            mp?.runCatching { setVolume(g, g) }
            return vol <= 0f && level <= 0f
        }

        fun release() { mp?.runCatching { stop(); release() } }
    }

    private val loop = object : Runnable {
        override fun run() {
            if (!enabled || paused) { ticking = false; return }
            apply(director.update(scene, SystemClock.elapsedRealtime(), finished.also { finished = null }))
            music?.tick(); bed?.tick()
            leaving.removeAll { v -> v.tick().also { if (it) v.release() } }
            handler.postDelayed(this, TICK_MS)
        }
    }

    private fun apply(w: MusicWant) {
        val musicLevel = (if (scene == MusicScene.CAVE) CAVE_MUSIC_LEVEL else MUSIC_LEVEL) * w.level
        if (w.music?.name != music?.name) {
            music?.let { it.fadeTo(0f, w.fadeMs); leaving += it }
            music = w.music?.let { t -> Voice(t.name, t.loop, musicLevel).also { it.fadeTo(musicLevel, w.fadeMs) } }
        } else music?.fadeTo(musicLevel, w.fadeMs)
        if (w.bed != bed?.name) {
            bed?.let { it.fadeTo(0f, w.fadeMs); leaving += it }
            bed = w.bed?.let { n -> Voice(n, true, BED_LEVEL, isBed = true).also { it.fadeTo(BED_LEVEL, maxOf(w.fadeMs, MusicDirector.PLACE_FADE_MS)) } }
        }
    }

    private fun startLoop() {
        if (ticking || !enabled || paused) return
        ticking = true
        handler.post(loop)
    }

    /** What is on screen now. */
    fun play(now: MusicScene) {
        scene = now
        startLoop()
    }

    /** A fight was won: the victory piece comes before the place's music. */
    fun victory() = director.victory()

    fun setEnabled(on: Boolean) {
        enabled = on
        if (on) startLoop() else stopAll()
    }

    fun pause() {
        paused = true
        held.clear()
        (listOfNotNull(music, bed) + leaving).forEach { v -> v.mp?.runCatching { if (isPlaying) { pause(); held += this } } }
    }

    fun resume() {
        paused = false
        if (enabled) held.forEach { it.runCatching { start() } }
        held.clear()
        startLoop()
    }

    fun release() {
        enabled = false
        stopAll()
    }

    private fun stopAll() {
        handler.removeCallbacks(loop)
        ticking = false
        (listOfNotNull(music, bed) + leaving).forEach { it.release() }
        leaving.clear()
        held.clear()
        music = null
        bed = null
    }

    private companion object {
        const val TICK_MS = 50L
        const val MUSIC_LEVEL = 0.6f
        const val CAVE_MUSIC_LEVEL = 0.45f
        const val BED_LEVEL = 0.8f
    }
}
