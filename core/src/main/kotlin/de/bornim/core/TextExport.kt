package de.bornim.core

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import java.io.File

/**
 * 390 (Englisch): the texts of [Ui] in both languages as JSON for the Godot game (`godot/daten/texte.json`), keyed by
 * the field name (`newGame`, `chestEmpty` …), placeholders stay {0}, {1}; names of the items ([Items], by id, with what they do)
 * and of the story's unique gear ([Uniques], with its rarity) for "Erhalten: …". Texts of maps and people come with `karten.json`.
 * Run: `./gradlew -p core exportTexts -Pout=<file>`.
 */
object TextExport {
    const val VERSION = 1

    /** Every [T] field of [Ui], in declaration order. */
    fun ui(): Map<String, T> = Ui::class.java.declaredFields
        .filter { it.type == T::class.java }
        .associate { f -> f.isAccessible = true; f.name to f.get(Ui) as T }

    fun json(): JsonObject = buildJsonObject {
        put("version", VERSION)
        putJsonObject("ui") { for ((k, t) in ui()) put(k, text(t)) }
        putJsonObject("dinge") { for (i in Items.all) putJsonObject(i.id) { put("name", text(i.name)); put("info", text(i.desc)) } }
        putJsonObject("einzelstuecke") {
            for (id in Uniques.ids) putJsonObject(id) { put("name", text(Uniques.name(id))); put("seltenheit", text(Uniques.rarity(id).title)) }
        }
    }

    private fun text(t: T) = buildJsonObject { put("de", t.de); put("en", t.en) }

    @JvmStatic
    fun main(args: Array<String>) {
        val out = File(args.firstOrNull() ?: "texte.json")
        out.absoluteFile.parentFile.mkdirs()
        out.writeText(Json { prettyPrint = false }.encodeToString(JsonObject.serializer(), json()))
        println("Texte: ${ui().size} -> ${out.path} (${out.length()} Bytes)")
    }
}
