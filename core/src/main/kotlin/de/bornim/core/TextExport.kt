package de.bornim.core

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.add
import java.io.File

/**
 * 390 (Englisch): the texts of [Ui] in both languages as JSON for the Godot game (`godot/daten/texte.json`), keyed by
 * the field name (`newGame`, `chestEmpty` …), placeholders stay {0}, {1}; names of the items ([Items], by id, with what they do)
 * and of the story's unique gear ([Uniques], with its rarity) for "Erhalten: …"; the rest's texts ([rast]). Texts of maps and people come with `karten.json`.
 * Run: `./gradlew -p core exportTexts -Pout=<file>`.
 */
object TextExport {
    const val VERSION = 1

    /** Every [T] field of [Ui], in declaration order. */
    fun ui(): Map<String, T> = felder(Ui)

    /** Every [T] field of an object, in declaration order. */
    fun felder(o: Any): Map<String, T> = o.javaClass.declaredFields
        .filter { it.type == T::class.java }
        .associate { f -> f.isAccessible = true; f.name to f.get(o) as T }

    /** 390 (Rast): the texts of [Resting], the spark that fades with a rest ([Light.sparkFaded]) and the meat roasted at the fire (Game's Msgs.roasted). */
    fun rast(): Map<String, T> {
        val msgs = Class.forName("de.bornim.core.Game\$Msgs").getDeclaredField("INSTANCE").apply { isAccessible = true }.get(null)
        return felder(Resting) + ("sparkFaded" to Light.sparkFaded) + ("roasted" to felder(msgs).getValue("roasted"))
    }

    /** 390 (Laden): Morwen's brewing lines (Game's Msgs: brewed, brewedTwo, missing). */
    fun laden(): Map<String, T> {
        val msgs = Class.forName("de.bornim.core.Game\$Msgs").getDeclaredField("INSTANCE").apply { isAccessible = true }.get(null)
        return felder(msgs).filterKeys { it in setOf("brewed", "brewedTwo", "missing") }
    }

    /** 399.1 (Tasche, Game.useItemOutside): eating, curing and healing outside battle, and the spark (Game's Msgs, [Light]). */
    fun benutzen(): Map<String, T> {
        val msgs = Class.forName("de.bornim.core.Game\$Msgs").getDeclaredField("INSTANCE").apply { isAccessible = true }.get(null)
        return felder(msgs).filterKeys { it in setOf("ate", "alreadyFed", "cured") } +
            ("sparkDrunk" to Light.sparkDrunk) + ("sparkAlready" to Light.sparkAlready) +
            ("healed" to T("{0} heilt {1} TP.", "{0} recovers {1} HP."))
    }

    fun json(): JsonObject = buildJsonObject {
        put("version", VERSION)
        putJsonObject("ui") { for ((k, t) in ui()) put(k, text(t)) }
        putJsonObject("rast") { for ((k, t) in rast()) put(k, text(t)) }
        putJsonObject("laden") { for ((k, t) in laden()) put(k, text(t)) }
        putJsonObject("benutzen") { for ((k, t) in benutzen()) put(k, text(t)) }
        // 399.1 (Chronik): die Eintraege „Bisher geschehen“ und die Auftraege neben dem Hauptauftrag, wortgleich aus [Chronicle];
        // wann sie gelten, sagt Godot je Kennung (chronik.gd)
        putJsonArray("chronik") {
            for (e in Chronicle.entries) addJsonObject { put("id", e.id); put("neben", e.side); put("titel", text(e.title)); put("text", text(e.text)) }
        }
        putJsonArray("chronik_auftraege") {
            for (t in Chronicle.tasks) addJsonObject { put("id", t.id); put("titel", text(t.title)); put("text", text(t.text)) }
        }
        // 390 (Laden): dazu Preis und Art je Ding, und Morwens Rezepte (Recipes)
        putJsonObject("dinge") {
            for (i in Items.all) putJsonObject(i.id) { put("name", text(i.name)); put("info", text(i.desc)); put("preis", i.price); put("art", i.kind.name)
                // 399.1: was das Ding heilt (Wuerfel, Wurf, Bonus) und ob es Leiden heilt, fuer Benutzen in der Tasche
                i.heal?.let { h -> putJsonArray("heilt") { add(h.count); add(h.sides); add(h.bonus) } }
                if (i.cures) put("heilt_leiden", true)
            }
        }
        putJsonArray("rezepte") {
            for (r in Recipes.all) addJsonObject {
                put("ergebnis", r.output); put("gold", r.gold)
                putJsonObject("zutaten") { for ((id, n) in r.ingredients) put(id, n) }
            }
        }
        putJsonObject("einzelstuecke") {
            for (id in Uniques.ids) putJsonObject(id) { put("name", text(Uniques.name(id))); put("seltenheit", text(Uniques.rarity(id).title)) }
        }
        // 399.1 Anschlagbrett (29): die Aushaenge wortgleich aus [Jobs], mit Lohn, Wunsch, Abgabe und Welle; die Regeln in auftraege.gd
        putJsonArray("auftraege") {
            for (j in Jobs.all) addJsonObject {
                put("id", j.id); put("geber", j.giver); put("geber_name", text(j.giverName)); put("titel", text(j.title))
                put("aushang", text(j.note)); put("lohn", text(j.reward)); put("ding", j.item); put("anzahl", j.count); put("gold", j.gold)
                putJsonArray("gaben") { for ((id, n) in j.gifts) addJsonObject { put("ding", id); put("anzahl", n) } }
                put("bringen", text(j.bring)); put("dank", text(j.thanks)); j.after?.let { put("nach", it) }
            }
        }
        // 399.1 Menue System: die Anleitung wortgleich aus [Guide] (Homer [352.…]); „nur“ = die Klasse, die den Absatz allein liest
        putJsonObject("anleitung") {
            put("titel", text(Guide.title)); put("zeichen", text(Guide.sign)); put("hinweis", text(Guide.signHint))
            putJsonArray("teile") {
                for (p in Guide.parts) addJsonObject { put("de", p.de); put("en", p.en); p.only?.let { put("nur", it.name) } }
            }
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
