package de.bornim.core

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.add
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject
import de.bornim.core.art.LandSheet
import de.bornim.core.art.MapSheet
import de.bornim.core.art.PixelImage
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 399.1: the drawn maps of the menu's map tab (MenuScreen.kt MapTab, 62) for the Godot game, made here once in the build
 * instead of on the device: every town and room as its inked sheet (`karte-<id>.bild`), the land map once for each set of known wild places (`land-<forest><deep_forest>.bild`, 1 known), and
 * `kartenblatt.json` with where a tile sits on a sheet, the level up (62r), the places of the land map, the houses
 * (62g/62s), the people and services (62f) and the elder's mark (62e). The wild maps need what the hero has explored
 * (62c fog); they follow once the hero walks the wood in Godot.
 * Run: `./gradlew -p core exportMapSheets -Pout=<dir>`.
 */
object MapSheetExport {
    /** The wild places of the land map, in the order of the bits in a land sheet's name. */
    val wild = listOf("forest", "deep_forest")

    /** The maps drawn as sheets: towns and rooms, known as soon as the hero is there (MapMarks.seen). */
    fun sheets(): List<MapDef> = World.maps.values.filter { it.kind != MapKind.FOREST && it.kind != MapKind.CAVE }

    fun json(sizes: Map<String, Pair<Int, Int>> = emptyMap()): JsonObject = buildJsonObject {
        put("kachel", MapSheet.C)
        put("rand", MapSheet.PAD)
        putJsonObject("karten") {
            for (m in sheets()) putJsonObject(m.id) {
                put("name", text(m.name))
                put("art", m.kind.name)
                put("breite", m.width); put("hoehe", m.height)
                sizes[m.id]?.let { (w, h) -> put("bild_breite", w); put("bild_hoehe", h) }
                // 62r: a room's level up is the area map whose door leads in; an area map's is the land map
                put("oben", parentOf(m) ?: "")
            }
        }
        putJsonObject("land") {
            put("breite", LandSheet.W); put("hoehe", LandSheet.H); put("fein", LandSheet.S)
            putJsonArray("wild") { for (w in wild) add(w) }
            putJsonArray("orte") {
                for (sp in LandSheet.spots) add(buildJsonObject {
                    put("karte", sp.map); put("x", sp.x); put("y", sp.y); put("r", sp.r); put("schrift_x", sp.labelX); put("schrift_y", sp.labelY)
                    put("name", text(World[sp.map].name))
                })
            }
        }
        // 62g/62s: a house is named once the hero has been inside ("besucht:<raum>") or met one who lives there; homes
        // without a room once the hero knocked and heard who lives there ("heard_x_y")
        putJsonArray("haeuser") {
            for (h in MapPeople.allHouses()) add(buildJsonObject {
                put("karte", h.map); put("x", h.x); put("y", h.y); put("name", text(h.name)); put("innen", h.inside ?: "")
                putJsonArray("bewohner") { for (f in MapPeople.folk) if (h.inside != null && f.inside == h.inside) add(f.id) }
            })
        }
        // 62f: the people once met ("met_<id>"), at their usual place: at the door of their house and inside it
        putJsonArray("leute") {
            for (f in MapPeople.folk) add(buildJsonObject {
                put("id", f.id); put("name", text(f.name)); put("was", text(f.what))
                val (map, x, y) = f.inside?.let { MapMarks.door(it) } ?: Triple(f.map, f.x, f.y)
                put("karte", map); put("x", x); put("y", y)
                f.inside?.let { World.maps[it] }?.npcs?.firstOrNull { it.id == f.id }?.let { n ->
                    put("innen", f.inside); put("innen_x", n.x); put("innen_y", n.y)
                }
            })
        }
        // 62f: inn, shop, temple at their doors (rooms are known at once, MapMarks.visited)
        putJsonArray("dienste") {
            for ((id, kind) in listOf("inn" to "INN", "shop" to "SHOP", "temple" to "TEMPLE")) {
                val m = World.maps[id] ?: continue
                MapMarks.door(id)?.let { (map, x, y) -> add(buildJsonObject { put("karte", map); put("x", x); put("y", y); put("art", kind); put("name", text(m.name)) }) }
            }
        }
        // 62e: the elder gives the main quest; his mark stands where he is on his map and at its door
        putJsonArray("aeltester") {
            for (m in World.maps.values) m.npcs.firstOrNull { it.id == "aldric" }?.let { n ->
                add(buildJsonObject { put("karte", m.id); put("x", n.x); put("y", n.y) })
                MapMarks.door(m.id)?.let { (map, x, y) -> add(buildJsonObject { put("karte", map); put("x", x); put("y", y) }) }
            }
        }
        putJsonObject("worte") {
            put("aeltester", text(T("Ältester Aldric", "Elder Aldric")))
            put("landkarte", text(T("Landkarte", "Map of the land")))
            put("gebietskarte_hoch", text(T("↑ Gebietskarte", "↑ Area map")))
            put("landkarte_hoch", text(T("↑ Landkarte", "↑ Land map")))
            put("auftraege", text(T("Aufträge", "Quests")))
            put("leute", text(T("Leute", "People")))
            put("dienste", text(T("Dienste", "Services")))
            put("chronik", text(T("In der Chronik", "In the chronicle")))
            put("sueden", text(T("nach Süden", "to the south")))
        }
    }

    /** 62r (MenuScreen.kt MapLook.parentOf): the area map whose way leads into a room, or null for an area map. */
    fun parentOf(m: MapDef): String? {
        if (m.kind != MapKind.INTERIOR && m.kind != MapKind.CAVE) return null
        return World.maps.values.firstOrNull { o -> o.kind != MapKind.INTERIOR && o.kind != MapKind.CAVE && o.warps.any { it.to.map == m.id } }?.id
    }

    private fun text(t: T) = buildJsonObject { put("de", t.de); put("en", t.en) }

    fun png(img: PixelImage, out: File) {
        val b = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_RGB)
        b.setRGB(0, 0, img.width, img.height, img.pixels, 0, img.width)
        ImageIO.write(b, "png", out)
    }

    @JvmStatic
    fun main(args: Array<String>) {
        val dir = File(args.firstOrNull() ?: "kartenblatt")
        dir.mkdirs()
        val sizes = HashMap<String, Pair<Int, Int>>()
        for (m in sheets()) {
            val img = MapSheet.render(m, { _, _ -> true })
            png(img, File(dir, "karte-${m.id}.bild"))
            sizes[m.id] = img.width to img.height
        }
        for (bits in 0 until (1 shl wild.size)) {
            val name = wild.indices.joinToString("") { if (bits shr it and 1 == 1) "1" else "0" }
            png(LandSheet.render(LandSheet.Look.PARCHMENT) { id -> id !in wild || (bits shr wild.indexOf(id) and 1 == 1) }, File(dir, "land-$name.bild"))
        }
        File(dir, "kartenblatt.json").writeText(Json { prettyPrint = false }.encodeToString(JsonObject.serializer(), json(sizes)))
        println("Kartenblätter: ${sizes.size} Karten, ${1 shl wild.size} Landkarten -> ${dir.path}")
    }
}
