package de.bornim.core

import de.bornim.core.audio.IntroSound
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.add
import kotlinx.serialization.json.addJsonArray
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject
import java.io.File

/**
 * 399.1 (Intro wie alt): the opening ([Prelude]), the intro and the temple scene for the Godot game (`godot/daten/intro.json`): the clock of [Reel],
 * the sentences of [Intro] and [TempleScene] word for word, the sounds under the intro ([IntroSound]) and the torch procession
 * over picture 3 ([IntroLife]) sampled every [STEP_MS] ms in the picture's own pixels, so Godot only draws what the old screen drew.
 * Run: `./gradlew -p core exportIntro -Pout=<file>`.
 */
object IntroExport {
    const val VERSION = 1
    /** The procession is sampled this often; Godot blends between two samples. */
    const val STEP_MS = 40L

    private fun text(t: T) = buildJsonObject { put("de", t.de); put("en", t.en) }

    private fun reel(r: Reel) = buildJsonObject {
        putJsonArray("saetze") { for (l in r.lines) add(text(l)) }
        put("schwarz", r.black)
    }

    fun json(): JsonObject = buildJsonObject {
        put("version", VERSION)
        putJsonObject("uhr") {
            put("blende_ms", Reel.FADE_MS); put("halten_ms", Reel.HOLD_MS); put("schritt_ms", Reel.STEP_MS)
            put("text_ein_ms", Reel.TEXT_IN_MS); put("text_aus_ms", Reel.TEXT_OUT_MS); put("ende_ms", Reel.END_MS)
        }
        // 292: der Vorspann beim Kaltstart (Prelude.kt): Firma, Pause, Name, dann das Menue
        putJsonObject("vorspann") {
            put("ein_ms", Prelude.fadeIn); put("firma_ms", Prelude.firmHold); put("aus_ms", Prelude.fadeOut)
            put("firma_ende_ms", Prelude.firmEnd); put("name_ms", Prelude.nameStart); put("menue_ms", Prelude.menuStart); put("ende_ms", Prelude.end)
            put("praesentiert", text(Ui.presents))
        }
        put("intro", reel(Intro))
        put("tempel", reel(TempleScene))
        putJsonObject("klang") {
            putJsonArray("bilder") {
                for (m in IntroSound.pictures) addJsonObject {
                    put("wind", m.wind); put("fluss", m.river); put("zirp_von", m.chirpMinMs); put("zirp_bis", m.chirpMaxMs); put("grille", m.cricket)
                }
            }
            put("start_ms", IntroSound.START_MS)
            put("glocke", IntroSound.BELL)
            put("glocke_ein_ms", IntroSound.BELL_IN_MS)
            put("musik", de.bornim.core.audio.MusicDirector.INTRO_LEVEL)
            // die Nacht unter dem schwarzen Bild (IntroSound.night, ab dessen Beginn); die Stimmen mischt Godot je Lauf neu
            putJsonArray("nacht") {
                for (c in IntroSound.night(1L)) addJsonObject {
                    put("ms", c.ms - Intro.black * Intro.STEP_MS); put("klang", c.sound.name.lowercase()); put("pegel", c.volume)
                }
            }
        }
        putJsonObject("leben") {
            val b = IntroLife.bearers
            put("bild", IntroLife.SQUARE)
            put("w", IntroLife.W); put("h", IntroLife.H); put("f", IntroLife.F)
            put("takt_ms", STEP_MS)
            putJsonArray("fackel") { for (x in b) add(x.torch) }
            putJsonArray("box") { for (v in IntroLife.BOX) add(v) }
            putJsonArray("slot_x") { for (i in b.indices) add(IntroLife.slotX(i)) }
            put("slot_y", IntroLife.slotY)
            putJsonArray("pfuetze") { for ((x, y) in IntroLife.puddle()) addJsonArray { add(x); add(y) } }
            put("pfuetze_y0", IntroLife.sy(0f, IntroLife.PUDDLE_Z + IntroLife.PUDDLE_W * 0.6f))
            put("pfuetze_y1", IntroLife.sy(0f, IntroLife.PUDDLE_Z - IntroLife.PUDDLE_W * 0.6f))
            // je Takt und Traeger: Fuesse (x, y), Massstab k, hinter dem Tempel (0/1), Flamme (x, y, Groesse s),
            // Lichtfleck auf der Strasse (x, y, r), Spiegelung in der Pfuetze (x)
            putJsonArray("bahn") {
                var u = 0L
                while (u <= Reel.STEP_MS + Reel.FADE_MS + STEP_MS) {
                    addJsonArray {
                        for (i in b.indices) addJsonArray {
                            val (x, z) = IntroLife.at(i, u)
                            add(IntroLife.sx(x, z)); add(IntroLife.sy(0f, z)); add(IntroLife.SHEET_Z / z)
                            add(if (IntroLife.behindTemple(x, z)) 1 else 0)
                            add(IntroLife.sx(x + IntroLife.tipX(b[i]), z)); add(IntroLife.sy(IntroLife.tipY(b[i]), z)); add(IntroLife.F / z * 1.5f)
                            add(IntroLife.sx(x, z)); add(IntroLife.sy(0f, z)); add(IntroLife.F * 3.6f / z)
                            add(IntroLife.sx(x + IntroLife.tipX(b[i]), z))
                        }
                    }
                    u += STEP_MS
                }
            }
        }
    }

    @JvmStatic
    fun main(args: Array<String>) {
        val out = File(args.firstOrNull() ?: "intro.json")
        out.absoluteFile.parentFile.mkdirs()
        out.writeText(Json { prettyPrint = false }.encodeToString(JsonObject.serializer(), json()))
        println("Intro: ${Intro.pictures} + ${TempleScene.pictures} Bilder -> ${out.path} (${out.length()} Bytes)")
    }
}
