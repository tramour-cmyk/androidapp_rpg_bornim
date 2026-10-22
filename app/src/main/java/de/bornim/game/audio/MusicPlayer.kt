package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.audiofx.Equalizer
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import de.bornim.core.audio.MusicDirector
import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.MusicWant
import de.bornim.core.audio.Threat

/**
 * Plays the recorded music from `assets/music` (28.1): [MusicDirector] decides what plays, this fades between pieces
 * (a new piece fades in while the old one fades out) and lays the cave's sound bed underneath. Runs on the main thread.
 * 120: [threat] tells how near the nearest hunter is; the dark layer plays over the music, which an equalizer muffles.
 */
class MusicPlayer(private val context: Context) {
    /** 120: asked every tick, on the main thread. */
    var threat: () -> Threat = { Threat.NONE }
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
    /** When the last tick ran ([SystemClock.elapsedRealtime]), 0 before the first. */
    private var lastTick = 0L
    private var finished: String? = null
    private var music: Voice? = null
    private var bed: Voice? = null
    private var layer: Voice? = null
    /** Voices fading out, released at silence. */
    private val leaving = ArrayList<Voice>()
    /** Players stopped by [pause], started again by [resume]. */
    private val held = ArrayList<MediaPlayer>()

    private inner class Voice(val name: String, looped: Boolean, var level: Float, muffle: Boolean = false, val isBed: Boolean = false) {
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
        private var fresh = true
        private var aim = Float.NaN
        /** 120: cuts the bands above about 700 Hz (sample 1: low-passed at 700 Hz); none where the device has none. */
        private val eq: Equalizer? = if (!muffle) null else mp?.let { p -> runCatching { Equalizer(0, p.audioSessionId).apply { enabled = true } }.getOrNull() }
        private var dark = 0f
        private var darkAim = 0f
        private var darkStep = 0f
        private var darkSet = -1f

        /** Muffled by [d] (0 open, 1 fully) in about [ms]. */
        fun darkTo(d: Float, ms: Int) {
            if (d == darkAim) return
            darkAim = d
            darkStep = if (ms <= 0) 1f else maxOf(kotlin.math.abs(d - dark), 0.01f) * TICK_MS / ms
        }

        private fun applyDark(k: Float) {
            val d = darkStep * k
            dark = if (dark < darkAim) minOf(darkAim, dark + d) else maxOf(darkAim, dark - d)
            val e = eq ?: return
            // a new setting only every 2 % on the way, and the last one exactly
            if (dark == darkSet || (kotlin.math.abs(dark - darkSet) < 0.02f && dark != darkAim)) return
            darkSet = dark
            runCatching {
                val floor = e.bandLevelRange[0].toInt() // millibel, e.g. -1500
                for (b in 0 until e.numberOfBands) {
                    val hz = e.getCenterFreq(b.toShort()) / 1000f
                    // about 24 dB per octave above 700 Hz, as far as the band goes
                    val cut = (2400f * kotlin.math.log2(hz / 700f)).coerceIn(0f, -floor.toFloat())
                    e.setBandLevel(b.toShort(), (-cut * dark).toInt().toShort())
                }
            }
        }

        /** Towards [target] in about [ms], whatever the distance (asked again every tick: only a new target sets the pace). */
        fun fadeTo(target: Float, ms: Int) {
            if (target == aim) return
            aim = target
            level = target
            step = if (ms <= 0) 1f else maxOf(kotlin.math.abs(target - vol), 0.01f) * TICK_MS / ms
        }

        /** One fade step for [k] ticks' time (299: more after a late tick); true once it has gone silent. */
        fun tick(k: Float): Boolean {
            // a voice begun in this tick starts from its first step, not from the hold-up before it
            val s = step * if (fresh) 1f else k
            fresh = false
            vol = if (vol < level) minOf(level, vol + s) else maxOf(level, vol - s)
            val g = vol * (if (isBed) bedGain else gain)
            mp?.runCatching { setVolume(g, g) }
            applyDark(k)
            return vol <= 0f && level <= 0f
        }

        fun release() {
            eq?.runCatching { release() }
            mp?.runCatching { stop(); release() }
        }
    }

    private val loop = object : Runnable {
        override fun run() {
            if (!enabled || paused) { ticking = false; lastTick = 0L; return }
            val now = SystemClock.elapsedRealtime()
            // 299: the fades go by the clock, not by the ticks: while the main thread is held up (pictures drawn behind
            // the black screen), the title music still dies away in its time instead of playing on under the place's
            val k = if (lastTick == 0L) 1f else ((now - lastTick).toFloat() / TICK_MS).coerceIn(1f, MAX_CATCH_UP)
            lastTick = now
            apply(director.update(scene, now, finished.also { finished = null }, threat()))
            music?.tick(k); bed?.tick(k); layer?.tick(k)
            leaving.removeAll { v -> v.tick(k).also { if (it) v.release() } }
            handler.postDelayed(this, TICK_MS)
        }
    }

    private fun apply(w: MusicWant) {
        val musicLevel = (if (scene == MusicScene.CAVE) CAVE_MUSIC_LEVEL else MUSIC_LEVEL) * w.level
        if (w.music?.name != music?.name) {
            music?.let { it.fadeTo(0f, w.fadeMs); leaving += it }
            music = w.music?.let { t -> Voice(t.name, t.loop, musicLevel, muffle = true).also { it.fadeTo(musicLevel, w.fadeMs) } }
        } else music?.fadeTo(musicLevel, w.shadeMs)
        music?.darkTo(w.dark, w.shadeMs)
        // 120: the layer as loud against the music as in sample 1, in the cave as much quieter as the music there
        val layerLevel = (w.layerLevel * musicLevel / MUSIC_LEVEL).coerceIn(0f, 1f)
        if (w.layer != layer?.name) {
            layer?.let { it.fadeTo(0f, w.shadeMs); leaving += it }
            layer = w.layer?.let { n -> Voice(n, true, 0f).also { it.fadeTo(layerLevel, w.shadeMs) } }
        } else layer?.fadeTo(layerLevel, w.shadeMs)
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
        (listOfNotNull(music, bed, layer) + leaving).forEach { v -> v.mp?.runCatching { if (isPlaying) { pause(); held += this } } }
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
        lastTick = 0L
        (listOfNotNull(music, bed, layer) + leaving).forEach { it.release() }
        leaving.clear()
        held.clear()
        music = null
        bed = null
        layer = null
    }

    private companion object {
        const val TICK_MS = 50L
        /** 299: at most this many ticks made up at once (a pause of 2 s), so a long hold-up ends in a quick fade, not a jump. */
        const val MAX_CATCH_UP = 40f
        const val MUSIC_LEVEL = 0.6f
        const val CAVE_MUSIC_LEVEL = 0.45f
        const val BED_LEVEL = 0.8f
    }
}
