package de.bornim.core

import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 390 (Englisch): the Godot game gets every text of [Ui] in German and English, with the same placeholders. */
class TextExportTest {
    private val ui = TextExport.json()["ui"]!!.jsonObject

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
}
