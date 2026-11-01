package de.bornim.core.audio

import de.bornim.core.FxKind
import de.bornim.core.Monsters
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * 399.3 (398, user 28.10., 11:38: reuse the sound, do not invent it anew): for the Godot game, the sounds the old game
 * synthesizes ([Sfx], everything without recordings in [Recorded.TAKES]) rendered once as WAV, take by take as
 * SfxPlayer does (`<sound>_<n>.wav`), and `kampfklang.json` with what [MarsSound] needs: each monster's attack effect
 * and voice ([Recorded.voiceOf]), the sound of each effect ([FxSound]).
 * Run: `./gradlew -p core exportKlang -Pout=<dir>`.
 */
object KlangExport {
    /** The sounds that are synthesized in the game: no recording, not recorded-only. */
    fun synthesized(): List<Sound> = Sound.entries.filter { it !in Recorded.TAKES && it !in Sfx.RECORDED_ONLY }

    /** The synthesized sounds that take on the room [k] (Room.soundsFor). */
    fun roomSynthesized(k: PlaceSound.Kind): List<Sound> = Room.soundsFor(k).filter { it in synthesized() }

    fun wav(pcm: ShortArray): ByteArray {
        val data = ByteBuffer.allocate(44 + pcm.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        data.put("RIFF".toByteArray()).putInt(36 + pcm.size * 2).put("WAVE".toByteArray())
        data.put("fmt ".toByteArray()).putInt(16).putShort(1).putShort(1)
            .putInt(Synth.SAMPLE_RATE).putInt(Synth.SAMPLE_RATE * 2).putShort(2).putShort(16)
        data.put("data".toByteArray()).putInt(pcm.size * 2)
        pcm.forEach { data.putShort(it) }
        return data.array()
    }

    fun table() = buildJsonObject {
        putJsonObject("monster_fx") { for (m in Monsters.all) put(m.id, m.attackFx.name) }
        putJsonObject("stimme") {
            for (m in Monsters.all) Recorded.voiceOf(m.id)?.let { (v, rate) ->
                putJsonObject(m.id) { put("stimme", v); put("tempo", rate) }
            }
        }
        putJsonObject("fx_klang") { for (k in FxKind.entries) put(k.name, FxSound.of(k, false).name.lowercase()) }
        put("elite_tempo", JsonPrimitive(Recorded.ELITE_RATE))
    }

    @JvmStatic
    fun main(args: Array<String>) {
        val dir = File(args.firstOrNull() ?: "build/klang").also { it.mkdirs() }
        var n = 0
        for (s in synthesized()) for (v in 0 until Sfx.variants(s)) {
            File(dir, "${s.name.lowercase()}_${v + 1}.wav").writeBytes(wav(Sfx.render(s, v)))
            n++
        }
        // the room versions of the same (Room.kt, as SfxPlayer.loadRoom renders them), next to the recorded ones in raum/<kind>/
        var r = 0
        for (k in Room.ROOMS) {
            val rd = File(dir.parentFile, "raum/${k.name.lowercase()}").also { it.mkdirs() }
            for (s in roomSynthesized(k)) for (v in 0 until Sfx.variants(s)) {
                File(rd, "${s.name.lowercase()}_${v + 1}.wav").writeBytes(wav(Room.apply(Sfx.render(s, v), Synth.SAMPLE_RATE, k)))
                r++
            }
        }
        File(dir, "kampfklang.json").writeText(table().toString())
        println("KlangExport: $n Aufnahmen aus ${synthesized().size} synthetischen Klängen, $r Raumfassungen, kampfklang.json")
    }
}
