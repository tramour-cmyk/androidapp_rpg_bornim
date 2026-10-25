package de.bornim.core

import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.boolean
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 348.6: the export the Godot game reads holds every map, tile for tile, with its ways out. */
class MapExportTest {
    private val j = MapExport.json()

    @Test
    fun everyMapTileForTile() {
        val karten = j["karten"]!!.jsonObject
        assertEquals(World.maps.keys, karten.keys)
        for (m in World.maps.values) {
            val k = karten[m.id]!!.jsonObject
            val rows = k["zeilen"]!!.jsonArray.map { it.jsonPrimitive.content }
            assertEquals(m.height, rows.size)
            for (y in 0 until m.height) for (x in 0 until m.width) assertEquals(m.tiles[y][x], Tile.of(rows[y][x]), "${m.id} $x,$y")
            assertEquals(m.warps.size, k["ausgaenge"]!!.jsonArray.size)
            assertEquals(m.bushes.size, k["buesche"]!!.jsonArray.size)
        }
    }

    @Test
    fun villageWaysOut() {
        val v = j["karten"]!!.jsonObject["village"]!!.jsonObject
        val out = v["ausgaenge"]!!.jsonArray.map { it.jsonObject }
        val inn = out.single { it["x"]!!.jsonPrimitive.int == 6 && it["y"]!!.jsonPrimitive.int == 5 }
        assertEquals("inn", inn["ziel"]!!.jsonObject["karte"]!!.jsonPrimitive.content)
        assertTrue(!inn["verschlossen"]!!.jsonPrimitive.boolean)
        val north = out.first { it["y"]!!.jsonPrimitive.int == 0 }
        assertEquals("forest", north["ziel"]!!.jsonObject["karte"]!!.jsonPrimitive.content)
        assertTrue(north["abgewiesen"]!!.jsonArray.isNotEmpty())
        assertTrue(out.filter { it["verschlossen"]!!.jsonPrimitive.boolean }.size >= 5)
        for (t in Tile.entries) assertEquals(t.walkable, j["kacheln"]!!.jsonObject[t.ch.toString()]!!.jsonObject["begehbar"]!!.jsonPrimitive.boolean)
    }

    @Test
    fun villageRingKeepsRiverOpen() {
        // 348.6 (Befund 4): wie MapEdge.trees keine Baeume im Ring vor dem Fluss am Ostrand (Zeilen 25-27), vor Feldern nur niedriger Bewuchs
        val v = j["karten"]!!.jsonObject["village"]!!.jsonObject
        val ring = v["ring"]!!.jsonArray.map { it.jsonArray }
        assertTrue(ring.none { val x = it[0].jsonPrimitive.int; val y = it[1].jsonPrimitive.int; x in 36..39 && y in 25..27 })
        assertTrue(ring.isNotEmpty() && ring.any { it[2].jsonPrimitive.content == "busch" })
        assertTrue(v["bewuchs"]!!.jsonArray.isNotEmpty())
    }
}
