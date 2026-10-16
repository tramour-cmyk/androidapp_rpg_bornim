package de.bornim.game.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import de.bornim.core.audio.PlaceSound
import de.bornim.core.audio.Recorded
import de.bornim.core.audio.Room
import de.bornim.core.audio.Sfx
import de.bornim.core.audio.Sound
import de.bornim.core.audio.Synth
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import kotlin.concurrent.thread

/**
 * Plays the sound effects: the recorded ones from the app's files ([Recorded], 18), the others synthesized and rendered
 * once into the cache as WAV files; and the creatures' voices. In a room ([room], 119) the sounds that happen there are
 * played in its version (hall in the cave, close and muffled in the inn), loaded when the hero enters it.
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
    private val main = Handler(Looper.getMainLooper())
    var enabled = true

    /** The room versions of the place the hero is in (119), by [key]; only those whose loading has finished are played. */
    private val roomIds = ConcurrentHashMap<String, Int>()
    private val ready: MutableSet<Int> = ConcurrentHashMap.newKeySet()
    private val roomLoader = Executors.newSingleThreadExecutor { Thread(it, "sfx-room").apply { isDaemon = true } }
    @Volatile private var roomKind = PlaceSound.Kind.OUTSIDE
    private val dir = File(context.cacheDir, "sfx-$VERSION").apply { mkdirs() }

    /** The kind of place the hero is in: entering one, its versions load (until then the dry ones play). */
    var room: PlaceSound.Kind
        get() = roomKind
        set(k) {
            if (k == roomKind) return
            roomKind = k
            roomLoader.execute { runCatching { loadRoom(k) } }
        }

    init {
        pool.setOnLoadCompleteListener { _, id, status -> if (status == 0) ready += id }
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

    /**
     * Loads the versions for [k] and lets the last room's go two seconds later, so a sound still ringing on as the hero
     * steps through the door is not cut off. Skipped if the hero is somewhere else again by then.
     */
    private fun loadRoom(k: PlaceSound.Kind) {
        if (roomKind != k) return
        val old = HashMap(roomIds)
        roomIds.clear()
        if (Room.acoustics(k) != null) {
            for (asset in Room.recordingsFor(k)) { if (roomKind != k) break; roomIds[asset] = load(Room.file(k, asset)) }
            for (s in Room.soundsFor(k)) {
                if (roomKind != k) break
                if (Recorded.TAKES[s] != null || s in Sfx.RECORDED_ONLY) continue
                for (v in 0 until Sfx.variants(s)) roomIds[key(s, v)] = runCatching {
                    val f = File(dir, "${k.name.lowercase()}/${s.name.lowercase()}_$v.wav")
                    if (!f.exists()) { f.parentFile?.mkdirs(); writeWav(f, Room.apply(Sfx.render(s, v), Synth.SAMPLE_RATE, k)) }
                    pool.load(f.path, 1)
                }.getOrDefault(0)
            }
        }
        main.postDelayed({ for (id in old.values) if (id != 0) { ready -= id; pool.unload(id) } }, ROOM_UNLOAD_MS)
    }

    /** What a take is known by among the room versions: its file for a recording, its sound and number for the others. */
    private fun key(s: Sound, take: Int) = if (Recorded.TAKES[s] != null) Recorded.file(s, take) else "synth/${s.name}/$take"

    /** The room version of [key] if the hero is in a room and it has loaded, else [dry]. */
    private fun inRoom(key: String, dry: Int): Int = roomIds[key]?.takeIf { it in ready } ?: dry

    /** The take loaded from [asset], or 0 (silent) if it cannot be read. */
    private fun load(asset: String): Int = runCatching { context.assets.openFd(asset).use { pool.load(it, 1) } }.getOrDefault(0)

    fun play(s: Sound, volume: Float = 0.8f) {
        if (!enabled) return
        val takes = ids[s] ?: return
        val t = kotlin.random.Random.nextInt(takes.size)
        pool.play(if (Room.affects(s)) inRoom(key(s, t), takes[t]) else takes[t], volume, volume, 1, 0, 1f)
    }

    /**
     * Plays one take of [s] over and over without a seam (the fire's crackle, 18k) and returns the stream, so its
     * volume can follow the hero; 0 if silent. The take stays until [stop]; the next start picks a new one.
     */
    fun loop(s: Sound, volume: Float): Int {
        if (!enabled) return 0
        val takes = ids[s] ?: return 0
        return pool.play(takes[kotlin.random.Random.nextInt(takes.size)], volume, volume, 0, -1, 1f)
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
        val t = kotlin.random.Random.nextInt(takes.size)
        pool.play(inRoom(Recorded.voiceFile(v, cue, t), takes[t]), volume, volume, 1, 0, rate)
    }

    fun release() {
        roomLoader.shutdownNow()
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
        private const val ROOM_UNLOAD_MS = 2000L
    }
}
