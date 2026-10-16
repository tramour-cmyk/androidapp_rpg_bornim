package preview

import de.bornim.core.audio.PlaceSound.Kind
import de.bornim.core.audio.Recorded
import de.bornim.core.audio.Room
import de.bornim.core.audio.Sfx
import de.bornim.core.audio.Sound
import de.bornim.core.audio.Synth
import java.io.File

/**
 * Raumklang (119): the same row of sounds as heard outside, in the inn, a small room, the temple hall and the cave, one
 * file per place in build/screens/raumproben (env RAUMPROBEN=1). Recordings are read with ffmpeg.
 */
private const val RATE = 44100
private val ASSETS = File("../../app/src/main/assets").takeIf { it.isDirectory } ?: File("app/src/main/assets")

/** A recording from the app's files, mono at [RATE], read with ffmpeg. */
private fun ogg(path: String): DoubleArray {
    val p = ProcessBuilder("ffmpeg", "-v", "error", "-i", File(ASSETS, path).path, "-ac", "1", "-ar", "$RATE", "-f", "s16le", "-").start()
    val b = p.inputStream.readBytes(); p.waitFor()
    val bb = java.nio.ByteBuffer.wrap(b).order(java.nio.ByteOrder.LITTLE_ENDIAN)
    return DoubleArray(b.size / 2) { bb.getShort(it * 2) / 32768.0 }
}

/** Writes [x] as a WAV file. */
private fun wav(x: DoubleArray, f: File) {
    val bytes = java.nio.ByteBuffer.allocate(x.size * 2).order(java.nio.ByteOrder.LITTLE_ENDIAN)
    for (v in x) bytes.putShort((v.coerceIn(-1.0, 1.0) * 32767).toInt().toShort())
    javax.sound.sampled.AudioSystem.write(javax.sound.sampled.AudioInputStream(java.io.ByteArrayInputStream(bytes.array()),
        javax.sound.sampled.AudioFormat(RATE.toFloat(), 16, 1, true, false), x.size.toLong()), javax.sound.sampled.AudioFileFormat.Type.WAVE, f)
}

/**
 * Raumklang into the game (env RAUMKLANG=spiel): every recording heard in a room ([Room.recordingsFor]) as heard there,
 * to app/src/main/assets/raum/<ort>/. Run again whenever a recording or [Room.acoustics] changes; RoomTest checks the files.
 */
fun bakeRoomVersions() {
    val out = File(ASSETS, "raum").apply { deleteRecursively() }
    val tmp = File.createTempFile("raum", ".wav")
    for (kind in Room.ROOMS) {
        val a = Room.acoustics(kind)!!
        for (asset in Room.recordingsFor(kind)) {
            val f = File(ASSETS, Room.file(kind, asset)).apply { parentFile.mkdirs() }
            wav(Room.process(ogg(asset), RATE, a), tmp)
            ProcessBuilder("ffmpeg", "-v", "error", "-y", "-i", tmp.path, "-c:a", "libvorbis", "-q:a", "3", f.path).inheritIO().start().waitFor()
        }
        println("wrote ${kind.name.lowercase()}: ${Room.recordingsFor(kind).size}")
    }
    tmp.delete()
}

fun writeRoomProbes() {
    val rate = RATE
    val dir = File("build/screens/raumproben").apply { deleteRecursively(); mkdirs() }
    fun synth(s: Sound, v: Int): DoubleArray {
        val pcm = Sfx.render(s, v); val k = rate / Synth.SAMPLE_RATE
        return DoubleArray(pcm.size * k) { pcm[it / k] / 32768.0 }
    }
    // the row: what happens in a place, each sound with its own pause
    val row: List<Pair<DoubleArray, Boolean>> = listOf(
        ogg(Recorded.file(Sound.DOOR, 0)) to false,
        ogg(Recorded.file(Sound.COINS, 0)) to false,
        synth(Sound.SWING, 0) to false,
        synth(Sound.HIT_SLASH, 0) to false,
        synth(Sound.BLOCK, 1) to false,
        ogg(Recorded.voiceFile("goblin", Recorded.Cue.ATTACK, 0)) to false,
        ogg(Recorded.voiceFile("wolf", Recorded.Cue.HURT, 0)) to false,
        ogg(Recorded.file(Sound.MAGIC, 0)) to false,
        ogg(Recorded.file(Sound.CUP, 0)) to true,
        ogg(Recorded.file(Sound.CHAIR, 0)) to true,
    )
    val places = listOf(Kind.OUTSIDE to "1_draussen", Kind.TAVERN to "2_schaenke", Kind.ROOM to "3_kammer", Kind.HALL to "4_tempel", Kind.CAVE to "5_hoehle")
    for ((kind, name) in places) {
        val gap = (1.6 * rate).toInt()
        val out = DoubleArray(row.size * gap + 3 * rate)
        var at = (0.3 * rate).toInt()
        for ((x, indoor) in row) {
            if (indoor && kind != Kind.TAVERN && kind != Kind.ROOM) continue
            val y = Room.acoustics(kind)?.let { Room.process(x, rate, it) } ?: x
            for (i in y.indices) if (at + i < out.size) out[at + i] += y[i]
            at += maxOf(gap, x.size + rate / 2)
        }
        val n = minOf(out.size, at + rate)
        val wav = File(dir, "$name.wav")
        wav(out.copyOf(n), wav)
        ProcessBuilder("ffmpeg", "-v", "error", "-y", "-i", wav.path, "-c:a", "libmp3lame", "-q:a", "3", File(dir, "raumklang_$name.mp3").path).inheritIO().start().waitFor()
        wav.delete()
        println("wrote $name")
    }
}
