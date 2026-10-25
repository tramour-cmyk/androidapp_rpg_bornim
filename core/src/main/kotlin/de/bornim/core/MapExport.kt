package de.bornim.core

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject
import de.bornim.core.art.MapEdge
import de.bornim.core.art.MapFlora
import de.bornim.core.art.MapTownIso
import java.io.File

/**
 * 348.6: the maps of [World] as JSON for the Godot game (`godot/daten/karten.json`) and the Blender scripts
 * (`tools/blender348/`): rows, tiles with their walkability, bushes, ways out, people, chests, signs, house looks.
 * Scripts (talk, triggers) stay in the rules; a way out says whether it is locked and what is said then (knocking: as at the start of the story).
 * Run: `./gradlew -p core exportMaps -Pout=<file>`.
 */
object MapExport {
    const val VERSION = 1
    private val start by lazy { GameState.newGame("Held", Race.HUMAN, CharClass.FIGHTER) }

    fun json(maps: Collection<MapDef> = World.maps.values): JsonObject = buildJsonObject {
        put("version", VERSION)
        putJsonObject("kacheln") {
            for (t in Tile.entries) putJsonObject(t.ch.toString()) { put("name", t.name); put("begehbar", t.walkable); put("schritt", Terrain.stepFactor(t)) }
        }
        put("busch_schritt", Terrain.BUSH)
        put("schlagbaum", text(Game.BARRIER_DOWN))   // Anstossen am Schlagbaum (Game.barrier), zu Beginn der Geschichte
        put("gehen", FreeWalk.WALK)   // Kacheln je Sekunde auf Gras
        put("laufen", FreeWalk.RUN)
        putJsonObject("karten") { for (m in maps) put(m.id, map(m)) }
    }

    fun map(m: MapDef): JsonObject = buildJsonObject {
        put("id", m.id)
        put("name", text(m.name))
        put("art", m.kind.name)
        put("breite", m.width)
        put("hoehe", m.height)
        put("rand", m.defaultTile.ch.toString())
        put("stufe", m.areaLevel)
        put("zeilen", JsonArray((0 until m.height).map { y -> JsonPrimitive(String(CharArray(m.width) { x -> m.tiles[y][x].ch })) }))
        put("buesche", buildJsonArray { for ((x, y) in m.bushes.sortedWith(compareBy({ it.second }, { it.first }))) add(xy(x, y)) })
        // 348.6: wo das alte Spiel statt einer hohen Krone niedrigen Bewuchs setzt (MapFlora.shades, 43/83), und der Waldring
        // jenseits des Randes (MapEdge.spot: frei vor Wegen und Wasser, Hecke vor Feldern, sonst dicht)
        put("bewuchs", buildJsonArray {
            for (y in 0 until m.height) for (x in 0 until m.width)
                if (m.tile(x, y) == Tile.TREE && MapFlora.shades(m, x, y)) add(spot(x, y, low(MapFlora.lowKind(m, x, y))))
        })
        if (MapEdge.applies(m) && m.kind != MapKind.CAVE) put("ring", buildJsonArray {
            for (y in -MapEdge.RING until m.height + MapEdge.RING) for (x in -MapEdge.RING until m.width + MapEdge.RING) {
                val art = when (MapEdge.spot(m, x, y)) {
                    MapEdge.Spot.NONE -> null
                    MapEdge.Spot.LOW -> low(MapFlora.lowKind(m, x, y))
                    MapEdge.Spot.TALL_OPEN -> "baum_offen"
                    MapEdge.Spot.TALL -> "baum"
                    MapEdge.Spot.TALL2 -> "baum2"
                }
                if (art != null) add(spot(x, y, art))
            }
        })
        putJsonArray("ausgaenge") {
            for (w in m.warps) add(buildJsonObject {
                put("x", w.x); put("y", w.y)
                putJsonObject("ziel") { put("karte", w.to.map); put("x", w.to.x); put("y", w.to.y); put("blick", w.to.facing.name) }
                w.requires?.let { put("braucht", it) }
                put("verschlossen", w.requires == Story.LOCKED)
                put("umkehren", w.turnBack)
                // 73b: what is said from inside, as at the start of the story, by day and by night
                w.knock?.let { k -> putJsonObject("klopfen") { put("tag", lines(k(start, false))); put("nacht", lines(k(start, true))) } }
                if (w.denied.isNotEmpty()) put("abgewiesen", lines(w.denied))
                // 67: what the hero thinks at the edge, first and short, as at the start of the story
                if (w.turnBack) {
                    val s = GameState.newGame("Held", Race.HUMAN, CharClass.FIGHTER)
                    Story.southEdge(s)?.let { put("gedanke", text(it.first)) }
                    Story.southEdge(s)?.let { put("gedanke_kurz", text(it.first)) }
                }
            })
        }
        putJsonArray("leute") {
            for (n in m.npcs) add(buildJsonObject {
                put("id", n.id); put("x", n.x); put("y", n.y); put("aussehen", n.look); put("blick", n.facing.name)
                put("streifen", n.wander)
                if (n.patrol.isNotEmpty()) put("runde", buildJsonArray { for ((x, y) in n.patrol) add(xy(x, y)) })
            })
        }
        putJsonArray("kisten") {
            for (c in m.chests) add(buildJsonObject {
                put("id", c.id); put("x", c.x); put("y", c.y)
                c.item?.let { put("ding", it) }
                put("anzahl", c.count); put("gold", c.gold)
            })
        }
        putJsonArray("schilder") {
            for ((p, t) in m.signs) add(buildJsonObject { put("x", p.first); put("y", p.second); put("text", text(t)) })
        }
        putJsonArray("haeuser") {
            for ((p, s) in m.houseStyles) add(buildJsonObject {
                put("x", p.first); put("y", p.second)
                put("dach", s.roof.name); put("wand", s.walls.name); put("gespiegelt", s.mirrored); put("merkmal", s.feature.name)
            })
        }
        // 348.6 Runde 6 (Chef 25.10., 09:06: Fenster an der Ostseite fehlen): Tueren und Fenster je Haus wie das alte Bild,
        // vorn (Sued) und Ostseite, aus dem Innenraum, wo es einen gibt (MapTownIso.facades)
        if (m.kind != MapKind.INTERIOR && m.kind != MapKind.CAVE) putJsonArray("fassaden") {
            for ((f, _) in MapTownIso.houses(m)) {
                val (vorn, seite) = MapTownIso.facades(m, f)
                add(buildJsonObject { put("x", f.x); put("y", f.y); put("n", f.n); put("d", f.d); put("vorn", vorn); put("seite", seite) })
            }
        }
        putJsonArray("schutz") {
            for (z in m.safeZones) add(buildJsonObject { put("x", z.x); put("y", z.y); put("radius", z.radius) })
        }
    }

    private fun low(l: MapFlora.Low) = when (l) { MapFlora.Low.BUSH -> "busch"; MapFlora.Low.YOUNG -> "jung"; MapFlora.Low.YOUNG2 -> "jung2" }
    private fun spot(x: Int, y: Int, art: String) = buildJsonArray { add(JsonPrimitive(x)); add(JsonPrimitive(y)); add(JsonPrimitive(art)) }
    private fun xy(x: Int, y: Int) = buildJsonArray { add(JsonPrimitive(x)); add(JsonPrimitive(y)) }
    private fun text(t: T) = buildJsonObject { put("de", t.de); put("en", t.en) }
    private fun lines(cmds: List<Cmd>) = buildJsonArray {
        for (c in cmds) if (c is Cmd.Say) add(buildJsonObject { c.speaker?.let { put("wer", text(it)) }; put("text", text(c.text)) })
    }

    @JvmStatic
    fun main(args: Array<String>) {
        val out = File(args.firstOrNull() ?: "karten.json")
        out.absoluteFile.parentFile.mkdirs()
        out.writeText(Json { prettyPrint = false }.encodeToString(JsonObject.serializer(), json()))
        println("Karten: ${World.maps.size} -> ${out.path} (${out.length()} Bytes)")
    }
}
