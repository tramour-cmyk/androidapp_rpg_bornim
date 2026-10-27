package de.bornim.core

/**
 * 62f/62g: who and what the map knows besides the quests. The people the hero has met
 * stand at their usual place, never where they are right now; tapping one names their habits, each only once the
 * hero has come upon them there. Services (inn, shop, temple, every campfire) once seen. Houses get a name in
 * handwriting once the hero has been inside or has heard who lives there. The map reminds, it does not lead (62c).
 */
object MapPeople {
    /**
     * A habit: a place one may find someone, with its key for the flag that the hero has met them there; met there
     * means near them while their day ([VillageDay.plans]) has them at one of the [stops], or at night for [night].
     */
    data class Haunt(val key: String, val where: T, val stops: List<Int> = emptyList(), val night: Boolean = false)

    /** A person on the map: their usual place ([map] at [x], [y], or the door of [inside]), what they do there, their habits. */
    data class Folk(val id: String, val name: T, val what: T, val map: String = "village", val x: Int = 0, val y: Int = 0,
                    val inside: String? = null, val haunts: List<Haunt> = emptyList())

    /** The flag set once the hero has come upon [id] at the habit [key]. */
    fun seenAt(id: String, key: String) = "seenat_${id}_$key"

    // where they are in their day follows the plans of [VillageDay]
    val folk = listOf(
        Folk("aldric", T("Ältester Aldric", "Elder Aldric"), T("Haus des Ältesten", "the Elder's house"), inside = "elder"),
        Folk("rowena", T("Rowena", "Rowena"), T("Wirtin im Schlafenden Greif", "innkeeper at the Sleeping Griffin"), inside = "inn"),
        Folk("borin", T("Borin", "Borin"), T("sitzt meist in der Schänke", "mostly sits in the inn"), inside = "inn"),
        Folk("thessa", T("Thessa", "Thessa"), T("Kramladen", "the general store"), inside = "shop"),
        Folk("osric", T("Bruder Osric", "Brother Osric"), T("Tempel", "the temple"), inside = "temple"),
        Folk("lyra_temple", T("Schwester Lyra", "Sister Lyra"), T("Tempel", "the temple"), inside = "temple"),
        Folk("jorin", T("Wache Jorin", "Guard Jorin"), T("Wache am Schlagbaum", "guards the barrier"), x = 15, y = 3,
            haunts = listOf(Haunt("night", T("nachts am Wachfeuer", "at the watch fire at night"), night = true))),
        Folk("bram", T("Bauer Bram", "Farmer Bram"), T("Feld im Süden", "the field in the south"), x = 20, y = 29,
            haunts = listOf(Haunt("noon", T("mittags auf dem Dorfplatz", "on the square at noon"), listOf(1)), Haunt("evening", T("abends oft in der Schänke", "often at the inn in the evening"), listOf(3)))),
        Folk("gwenna", T("Gwenna", "Gwenna"), T("wohnt hier mit ihrer Familie", "lives here with her family"), x = 5, y = 14,
            haunts = listOf(Haunt("well", T("morgens am Brunnen", "at the well in the morning"), listOf(0)), Haunt("river", T("wäscht am Fluss", "washes at the river"), listOf(1)))),
        Folk("pim", T("Pim", "Pim"), T("wohnt hier mit seinen Eltern", "lives here with his parents"), x = 13, y = 22,
            haunts = listOf(Haunt("square", T("spielt auf dem Dorfplatz", "plays on the square"), listOf(0, 3)), Haunt("river", T("nachmittags am Fluss", "at the river in the afternoon"), listOf(2)))),
        Folk("liska", T("Liska", "Liska"), T("Magd im Schlafenden Greif", "maid at the Sleeping Griffin"), x = 8, y = 7,
            haunts = listOf(Haunt("shop", T("vormittags bei Thessa", "at Thessa's in the morning"), listOf(1)), Haunt("wash", T("hängt Wäsche auf", "hangs out the washing"), listOf(3)))),
        Folk("garrick", T("Jäger Garrick", "Hunter Garrick"), T("Lager im Flüsterwald", "camp in the Whisperwood"), map = "forest", x = 10, y = 9),
        Folk("morwen", T("Kräuterfrau Morwen", "Morwen the Herbalist"), T("Hütte im Tiefen Wald", "hut in the Deep Whisperwood"), map = "deep_forest", x = 25, y = 30),
    )

    /**
     * The habit at which the hero comes upon [id] at ([x], [y]) at [minutes] of the day, or null: they must be at
     * their place of the hour (within its strolling ground), or for a night habit simply out at night.
     */
    fun habitNow(id: String, minutes: Int, night: Boolean, x: Int, y: Int): String? {
        val f = folk.firstOrNull { it.id == id } ?: return null
        val plan = VillageDay.plans[id]
        val stop = VillageDay.stopAt(id, minutes)
        val i = if (plan != null && stop != null && VillageDay.near(stop, x, y)) plan.indexOf(stop) else -1
        return f.haunts.firstOrNull { (it.night && night) || i in it.stops }?.key
    }

    /** A house name on the map at the door ([x], [y]) of [map]. */
    data class House(val map: String, val x: Int, val y: Int, val name: T, val inside: String? = null)

    /** The flag set once the hero has knocked at a locked door and learned who lives there. */
    fun heard(x: Int, y: Int) = "heard_${x}_$y"

    /** The flag set once the hero has been inside [interior]. */
    fun been(interior: String) = "been_$interior"

    // short, as one would write them on a map by hand
    private val homes = mapOf(
        (12 to 5) to T("Bäcker", "Baker"),
        (23 to 5) to T("Kael", "Kael"),
        (5 to 14) to T("Gwenna", "Gwenna"),
        (30 to 13) to T("Schmied", "Smith"),
        (13 to 22) to T("Pim", "Pim"),
    )
    private val shortNames = mapOf(
        "inn" to T("Schänke", "Inn"), "shop" to T("Kramladen", "Store"),
        "elder" to T("Ältester", "Elder"), "temple" to T("Tempel", "Temple"),
    )

    /** The houses whose names the hero knows, on every map. */
    fun houses(s: GameState): List<House> {
        val out = ArrayList<House>()
        for (m in World.maps.values) for (w in m.warps) {
            val inside = World.maps[w.to.map]
            if (inside != null && inside.kind == MapKind.INTERIOR && m.kind != MapKind.INTERIOR) {
                // older heroes who met someone living there have been inside too
                if (s.has(been(inside.id)) || folk.any { it.inside == inside.id && s.has(MapMarks.met(it.id)) }) out += House(m.id, w.x, w.y, shortNames[inside.id] ?: inside.name, inside.id)
            } else homes[w.x to w.y]?.let { if (m.id == "village" && s.has(heard(w.x, w.y))) out += House(m.id, w.x, w.y, it) }
        }
        return out
    }

    /** The people the hero has met, each at their usual place; several at one door make one mark. */
    fun marks(s: GameState): List<MapMarks.Mark> {
        val out = ArrayList<MapMarks.Mark>()
        for (f in folk) {
            if (!s.has(MapMarks.met(f.id))) continue
            val (map, x, y) = f.inside?.let { MapMarks.door(it) } ?: Triple(f.map, f.x, f.y)
            val known = f.haunts.filter { s.has(seenAt(f.id, it.key)) }
            val de = (listOf("${f.name.de} – ${f.what.de}") + known.map { it.where.de }).joinToString("; ")
            val en = (listOf("${f.name.en} – ${f.what.en}") + known.map { it.where.en }).joinToString("; ")
            out += MapMarks.Mark(map, x, y, MapMarks.Kind.PERSON, false, T(de, en), f.id)
            // 62h (Meldung 13.10., 19:3x): the ground plan of their house shows them where they stand inside
            f.inside?.let { World.maps[it] }?.npcs?.firstOrNull { it.id == f.id }
                ?.let { n -> out += MapMarks.Mark(f.inside, n.x, n.y, MapMarks.Kind.PERSON, false, T(de, en), f.id) }
        }
        return out.groupBy { Triple(it.map, it.x, it.y) }
            .map { (_, ms) -> ms.first().copy(label = T(ms.joinToString("\n") { it.label.de }, ms.joinToString("\n") { it.label.en })) }
    }

    /** Inn, shop, temple at their doors once known, and every campfire once seen. */
    fun services(s: GameState): List<MapMarks.Mark> {
        val out = ArrayList<MapMarks.Mark>()
        val kinds = mapOf("inn" to MapMarks.Kind.INN, "shop" to MapMarks.Kind.SHOP, "temple" to MapMarks.Kind.TEMPLE)
        for ((id, kind) in kinds) {
            val m = World.maps[id] ?: continue
            if (!MapMarks.visited(s, m)) continue
            MapMarks.door(id)?.let { (map, x, y) -> out += MapMarks.Mark(map, x, y, kind, false, m.name) }
        }
        for (m in World.maps.values) for (y in 0 until m.height) for (x in 0 until m.width)
            if (m.tile(x, y) == Tile.CAMPFIRE && MapMarks.seen(s, m, x, y)) out += MapMarks.Mark(m.id, x, y, MapMarks.Kind.FIRE, false, T("Lagerfeuer", "Campfire"))
        return out
    }
}
