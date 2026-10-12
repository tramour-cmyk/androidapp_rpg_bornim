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

    /** 36.3: the kept pictures of one foe's fight alone, e.g. `ARTMEM_FOE=bugbear:0` (Krogg); one line per store, frame size. */
    @Test fun oneFoe() {
        val spec = System.getenv("ARTMEM_FOE") ?: return
        val (id, n) = spec.split(":").let { it[0] to (it.getOrNull(1)?.toInt() ?: 0) }
        val t0 = System.currentTimeMillis()
        MonsterArt.prepare(id, MonsterLook(n))
        val rows = report().filter { it.third > 0 }
        val f = MonsterArt.battleFrame(id, MonsterLook(n), de.bornim.core.art.Act.IDLE, 0, 0)
        println("ARTMEM $spec nach ${(System.currentTimeMillis() - t0) / 1000} s, Bild ${f.width}×${f.height}")
        for ((name, count, bytes) in rows.sortedByDescending { it.third }) println("ARTMEM %-28s %6d Bilder %8.1f MB".format(name, count, bytes / 1048576.0))
        // how much of the frames is used: the box round every drawn pixel, and its share of the frame
        var used = 0L; var all = 0L; var n2 = 0
        for (act in de.bornim.core.art.Act.entries) for (v in 0 until 3) for (i in 0 until runCatching { MonsterArt.frameCount(id, MonsterLook(n), act, v) }.getOrDefault(0)) {
            val img = MonsterArt.battleFrame(id, MonsterLook(n), act, v, i)
            var x0 = img.width; var y0 = img.height; var x1 = -1; var y1 = -1
            for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) != 0) { if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y }
            if (x1 >= 0) used += (x1 - x0 + 1).toLong() * (y1 - y0 + 1); all += img.width.toLong() * img.height; n2++
        }
        println("ARTMEM %d Bilder, genutzte Fläche %.0f %%: zugeschnitten %.1f MB, 1,5× zugeschnitten %.1f MB".format(n2, 100.0 * used / all, used * 4 / 1048576.0, used * 4 * 2.25 / 1048576.0))
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
