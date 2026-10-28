package de.bornim.core

import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 399.1: the sheets of the map tab for Godot: every town and room, its level up, houses, people and services at doors. */
class MapSheetExportTest {
    private val j = MapSheetExport.json()

    @Test
    fun townsAndRoomsWithTheirLevelUp() {
        val karten = j["karten"]!!.jsonObject
        assertTrue("village" in karten && "inn" in karten && "forest" !in karten)
        assertEquals("village", karten["inn"]!!.jsonObject["oben"]!!.jsonPrimitive.content)
        assertEquals("", karten["village"]!!.jsonObject["oben"]!!.jsonPrimitive.content)
    }

    @Test
    fun housesPeopleServices() {
        val inn = j["haeuser"]!!.jsonArray.map { it.jsonObject }.single { it["innen"]!!.jsonPrimitive.content == "inn" }
        assertEquals(6, inn["x"]!!.jsonPrimitive.int); assertEquals(5, inn["y"]!!.jsonPrimitive.int)
        assertTrue(inn["bewohner"]!!.jsonArray.any { it.jsonPrimitive.content == "rowena" })
        val rowena = j["leute"]!!.jsonArray.map { it.jsonObject }.single { it["id"]!!.jsonPrimitive.content == "rowena" }
        assertEquals("village", rowena["karte"]!!.jsonPrimitive.content)
        assertEquals("inn", rowena["innen"]!!.jsonPrimitive.content)
        assertEquals(setOf("INN", "SHOP", "TEMPLE"), j["dienste"]!!.jsonArray.map { it.jsonObject["art"]!!.jsonPrimitive.content }.toSet())
        assertEquals(setOf("elder", "village"), j["aeltester"]!!.jsonArray.map { it.jsonObject["karte"]!!.jsonPrimitive.content }.toSet())
    }
}
