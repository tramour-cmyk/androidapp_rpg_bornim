package de.bornim.core

import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals

/** 399.1: what Godot plays as the intro is the old intro, word for word, with every picture of the procession. */
class IntroExportTest {
    @Test
    fun introAsOfOld() {
        val j = IntroExport.json()
        val intro = j["intro"]!!.jsonObject
        assertEquals(Intro.lines.map { it.de }, intro["saetze"]!!.jsonArray.map { it.jsonObject["de"]!!.jsonPrimitive.content })
        assertEquals(Intro.black, intro["schwarz"]!!.jsonPrimitive.int)
        assertEquals(TempleScene.lines.map { it.en }, j["tempel"]!!.jsonObject["saetze"]!!.jsonArray.map { it.jsonObject["en"]!!.jsonPrimitive.content })
        val leben = j["leben"]!!.jsonObject
        val bahn = leben["bahn"]!!.jsonArray
        // the procession as long as picture 3 shows (its own time and the fade of picture 4 over it), five bearers each
        assertEquals(true, (bahn.size - 1) * IntroExport.STEP_MS >= Reel.STEP_MS + Reel.FADE_MS)
        assertEquals(IntroLife.bearers.size, bahn[0].jsonArray.size)
        val (x, z) = IntroLife.at(1, 40 * IntroExport.STEP_MS)
        assertEquals(IntroLife.sx(x, z).toDouble(), bahn[40].jsonArray[1].jsonArray[0].jsonPrimitive.content.toDouble(), 0.01)
        assertEquals(4, j["klang"]!!.jsonObject["nacht"]!!.jsonArray.size)
        val orte = j["blende"]!!.jsonObject["orte"]!!.jsonObject
        assertEquals(Interlude.places.keys, orte.keys)
        assertEquals(Interlude.places.getValue("village").map { it.text.de }, orte["village"]!!.jsonArray.map { it.jsonObject["de"]!!.jsonPrimitive.content })
        val v = j["vorspann"]!!.jsonObject
        assertEquals(Prelude.nameStart, v["name_ms"]!!.jsonPrimitive.content.toLong())
        assertEquals(Prelude.end, v["ende_ms"]!!.jsonPrimitive.content.toLong())
    }
}
