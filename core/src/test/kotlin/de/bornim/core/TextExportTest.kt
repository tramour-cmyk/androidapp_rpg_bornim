package de.bornim.core

import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 390 (Englisch): the Godot game gets every text of [Ui] in German and English, with the same placeholders. */
class TextExportTest {
    private val j = TextExport.json()
    private val ui = j["ui"]!!.jsonObject

    @Test
    fun everyUiTextBothLanguages() {
        assertTrue(ui.size > 80, "nur ${ui.size} Texte")
        assertEquals("Neues Spiel", ui["newGame"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals("New Game", ui["newGame"]!!.jsonObject["en"]!!.jsonPrimitive.content)
        val stelle = Regex("\\{\\d}")
        for ((k, v) in ui) {
            val de = v.jsonObject["de"]!!.jsonPrimitive.content
            val en = v.jsonObject["en"]!!.jsonPrimitive.content
            assertTrue(de.isNotEmpty() && en.isNotEmpty(), k)
            assertEquals(stelle.findAll(de).map { it.value }.toSet(), stelle.findAll(en).map { it.value }.toSet(), k)
        }
    }

    @Test
    fun restTextsForGodot() {
        val rast = j["rast"]!!.jsonObject
        assertEquals("Rasten?", rast["ask"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals("Your spark has faded.", rast["sparkFaded"]!!.jsonObject["en"]!!.jsonPrimitive.content)
        assertTrue(rast["roasted"]!!.jsonObject["de"]!!.jsonPrimitive.content.contains("{0}"))
        assertTrue(rast.size >= 25, "nur ${rast.size} Texte")
    }

    @Test
    fun useTextsAndHealForGodot() {
        val b = j["benutzen"]!!.jsonObject
        for (k in listOf("ate", "alreadyFed", "cured", "sparkDrunk", "sparkAlready", "healed")) assertTrue(b.containsKey(k), k)
        val dinge = j["dinge"]!!.jsonObject
        assertEquals(listOf("2", "4", "2"), dinge["potion"]!!.jsonObject["heilt"]!!.jsonArray.map { it.jsonPrimitive.content })
        assertEquals("true", dinge["remedy"]!!.jsonObject["heilt_leiden"]!!.jsonPrimitive.content)
    }

    @Test
    fun chronicleForGodot() {
        val c = j["chronik"]!!.jsonArray
        assertEquals(Chronicle.entries.map { it.id }, c.map { it.jsonObject["id"]!!.jsonPrimitive.content })
        assertEquals("Der Auftrag", c[1].jsonObject["titel"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals(listOf("rauch", "lager"), j["chronik_auftraege"]!!.jsonArray.map { it.jsonObject["id"]!!.jsonPrimitive.content })
    }

    @Test
    fun shopDataForGodot() {
        val dinge = j["dinge"]!!.jsonObject
        assertEquals("25", dinge["potion"]!!.jsonObject["preis"]!!.jsonPrimitive.content)
        assertEquals("KEY", dinge.values.first { it.jsonObject["art"]!!.jsonPrimitive.content == "KEY" }.jsonObject["art"]!!.jsonPrimitive.content)
        val rezepte = j["rezepte"]!!.jsonArray
        assertEquals(Recipes.all.size, rezepte.size)
        assertEquals("2", rezepte[0].jsonObject["zutaten"]!!.jsonObject["herbs"]!!.jsonPrimitive.content)
        assertEquals(setOf("brewed", "brewedTwo", "missing"), j["laden"]!!.jsonObject.keys)
    }

    @Test
    fun everyStoryGiftHasAName() {
        val dinge = j["dinge"]!!.jsonObject
        val einzel = j["einzelstuecke"]!!.jsonObject
        assertEquals("Heiltrank", dinge["potion"]!!.jsonObject["name"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals("Elder's Ring", einzel["ring_protection"]!!.jsonObject["name"]!!.jsonObject["en"]!!.jsonPrimitive.content)
        // was Story.kt gibt oder nimmt, steht in dinge oder einzelstuecke
        val story = java.io.File("src/main/kotlin/de/bornim/core/Story.kt").readText()
        for (m in Regex("""(?:give|take)\("(\w+)"""").findAll(story)) assertTrue(m.groupValues[1] in dinge || m.groupValues[1] in einzel, m.groupValues[1])
    }

    @Test
    fun theNoticesAreWordForWord() {
        val a = j["auftraege"]!!.jsonArray.map { it.jsonObject }
        assertEquals(Jobs.all.map { it.id }, a.map { it["id"]!!.jsonPrimitive.content })
        val stones = a.first { it["id"]!!.jsonPrimitive.content == "stones" }
        assertEquals(Jobs["stones"].note.de, stones["aushang"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals(Story.KROGG_DEFEATED, stones["nach"]!!.jsonPrimitive.content)
        assertEquals("@gear:UNCOMMON:HEAD", stones["gaben"]!!.jsonArray[0].jsonObject["ding"]!!.jsonPrimitive.content)
        assertTrue("nach" !in a.first { it["id"]!!.jsonPrimitive.content == "pelts" })
    }

    @Test
    fun theGuideIsWordForWord() {
        val a = j["anleitung"]!!.jsonObject
        val teile = a["teile"]!!.jsonArray
        assertEquals(Guide.parts.size, teile.size)
        assertEquals(Guide.parts[1].de, teile[1].jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals("Guide", a["titel"]!!.jsonObject["en"]!!.jsonPrimitive.content)
        // Absaetze nur fuer eine Klasse tragen deren Namen
        assertEquals(Guide.parts.count { it.only != null }, teile.count { "nur" in it.jsonObject })
    }
}
