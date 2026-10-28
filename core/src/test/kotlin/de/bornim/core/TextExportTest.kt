package de.bornim.core

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
    fun everyStoryGiftHasAName() {
        val dinge = j["dinge"]!!.jsonObject
        val einzel = j["einzelstuecke"]!!.jsonObject
        assertEquals("Heiltrank", dinge["potion"]!!.jsonObject["name"]!!.jsonObject["de"]!!.jsonPrimitive.content)
        assertEquals("Elder's Ring", einzel["ring_protection"]!!.jsonObject["name"]!!.jsonObject["en"]!!.jsonPrimitive.content)
        // was Story.kt gibt oder nimmt, steht in dinge oder einzelstuecke
        val story = java.io.File("src/main/kotlin/de/bornim/core/Story.kt").readText()
        for (m in Regex("""(?:give|take)\("(\w+)"""").findAll(story)) assertTrue(m.groupValues[1] in dinge || m.groupValues[1] in einzel, m.groupValues[1])
    }
}
