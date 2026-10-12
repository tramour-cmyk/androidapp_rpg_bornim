package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.World
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike
import java.io.File
import kotlin.test.Test

/**
 * 30: how much memory the kept pictures take after a usual start (hero on the map, the village's folk, ground of
 * three maps, a fight drawn ahead). Only with `ARTMEM=1` (takes a while); prints one line per store.
 */
class ArtMemoryTest {
    @Test fun measure() {
        if (System.getenv("ARTMEM") != "1") return
        val hero = GameState.newGame("Speicher", Race.HUMAN, CharClass.FIGHTER).hero
        val t0 = System.currentTimeMillis()
        MapFigure.prepareNow(hero)
        for (m in listOf("village", "forest", "cave")) { MapGround.prepareNow(World[m]); MapFolk.prepareFor(World[m]) }
        HeroBattle.prepare(hero, "goblin", false)
        HeroBattle.prepareAct(hero, Act.AMBUSHED, Strike.SLASH, 0)
        for ((id, n) in listOf("goblin" to 3, "wolf" to 2, "skeleton" to 2)) for (i in 0 until n) {
            MonsterArt.prepare(id, MonsterLook(i)); MapFoe.prepareNow(id, MonsterLook(i))
        }
        // the folk are drawn on their own threads: wait until nothing grows any more
        var last = -1L
        while (true) { Thread.sleep(3000); val now = report().sumOf { it.third }; if (now == last) break; last = now }
        val rows = report()
        println("ARTMEM nach ${(System.currentTimeMillis() - t0) / 1000} s")
        for ((name, count, bytes) in rows.sortedByDescending { it.third }) if (bytes > 0) println("ARTMEM %-28s %6d Bilder %8.1f MB".format(name, count, bytes / 1048576.0))
        println("ARTMEM %-28s %6d Bilder %8.1f MB".format("SUMME", rows.sumOf { it.second }, rows.sumOf { it.third } / 1048576.0))
        System.gc(); val r = Runtime.getRuntime()
        println("ARTMEM Heap belegt %.1f MB".format((r.totalMemory() - r.freeMemory()) / 1048576.0))
    }

    companion object {
        /** Every object in this package holding maps of pictures: name and field, how many, how many bytes. */
        fun report(): List<Triple<String, Int, Long>> {
            val classes = File("build/classes/kotlin/main/de/bornim/core/art").listFiles().orEmpty().map { it.name }
                .filter { it.endsWith(".class") && '$' !in it }.map { it.removeSuffix(".class") }
            val out = ArrayList<Triple<String, Int, Long>>()
            for (c in classes) {
                val k = runCatching { Class.forName("de.bornim.core.art.$c") }.getOrNull() ?: continue
                val inst = runCatching { k.getDeclaredField("INSTANCE").get(null) }.getOrNull() ?: continue
                for (f in k.declaredFields) {
                    if (!Map::class.java.isAssignableFrom(f.type)) continue
                    f.isAccessible = true
                    val m = f.get(inst) as? Map<*, *> ?: continue
                    var n = 0; var b = 0L
                    synchronized(m) { for (v in m.values.toList()) bytes(v)?.let { n++; b += it } }
                    if (n > 0) out += Triple("$c.${f.name}", n, b)
                }
            }
            return out
        }

        private fun bytes(v: Any?): Long? = when (v) {
            is PixelImage -> v.width.toLong() * v.height * 4
            null -> null
            else -> v.javaClass.declaredFields.firstOrNull { it.type == PixelImage::class.java }?.let { f ->
                f.isAccessible = true; (f.get(v) as PixelImage).let { it.width.toLong() * it.height * 4 }
            }
        }
    }
}
