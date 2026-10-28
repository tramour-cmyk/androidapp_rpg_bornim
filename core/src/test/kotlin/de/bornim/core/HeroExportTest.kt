package de.bornim.core

import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 390: the Godot game gets the hero's rules and sample heroes with the numbers [Hero] gives (godot/tests/held_golden.gd). */
class HeroExportTest {
    private val j = HeroExport.json()

    @Test
    fun tablesAndSamples() {
        assertEquals(GearBases.all.size, j["grundformen"]!!.jsonObject.size)
        assertEquals(CharClass.entries.size, j["klassen"]!!.jsonObject.size)
        val proben = j["proben"]!!.jsonArray
        assertEquals(Race.entries.size * CharClass.entries.size * 4 * 4, proben.size)
        // eine Probe mit allem: Stufe 20 traegt das Kapitel 2, der Ring liegt ueber den Deckeln
        val voll = proben.map { it.jsonObject }.first { it["held"]!!.jsonObject["stufe"]!!.jsonPrimitive.int == 20 && it["held"]!!.jsonObject["ausruestung"]!!.jsonObject.containsKey("RING") }
        val soll = voll["soll"]!!.jsonObject
        assertTrue(soll["krit_ab"]!!.jsonPrimitive.int in 17..20)
        assertEquals(30, soll["lebensraub"]!!.jsonPrimitive.int)
    }
}
