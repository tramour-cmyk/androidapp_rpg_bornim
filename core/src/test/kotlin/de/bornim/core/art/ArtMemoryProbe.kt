package de.bornim.core.art

import de.bornim.core.*
import java.lang.reflect.Modifier
import java.util.IdentityHashMap
import kotlin.random.Random
import kotlin.test.Test

/** 346: how much picture memory each art object holds after a walk through the village, the woods and two fights. MEMPROBE=1. */
class ArtMemoryProbe {
    @Test
    fun probe() {
        if (System.getenv("MEMPROBE") == null) return
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(4)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        fun visit(id: String) {
            val map = World[id]
            MapGround.prepare(map, map.width / 2, map.height / 2)
            MapFolk.prepareFor(map)
            for (f in 0 until 2) WorldArt.objects(map, g.state, f, 0)
            settle()
            report("nach $id")
        }
        visit("village"); visit("forest")
        val hero = g.state.hero
        for (foe in listOf("giant_rat", "wolf")) {
            MonsterArt.prepare(foe, MonsterLook())
            HeroBattle.prepare(hero, foe, false)
            report("nach Kampf $foe")
        }
        visit("deep_forest")
        val pid = ProcessHandle.current().pid().toString()
        val out = ProcessBuilder("jcmd", pid, "GC.class_histogram").redirectErrorStream(true).start().inputStream.bufferedReader().readLines()
        for (l in out.take(25)) println("MEMPROBE H $l")
    }

    private fun settle() {
        var last = -1L
        repeat(600) {
            Thread.sleep(500)
            val now = used()
            if (!MapGround.drawing() && now == last) return
            last = now
        }
    }

    private fun used(): Long { val r = Runtime.getRuntime(); return r.totalMemory() - r.freeMemory() }

    private fun report(title: String) {
        System.gc(); Thread.sleep(300); System.gc()
        val seen = IdentityHashMap<Any, Boolean>()
        val rows = ArrayList<Pair<String, Long>>()
        val dir = java.io.File(PixelImage::class.java.protectionDomain.codeSource.location.toURI()).resolve("de/bornim/core/art")
        for (f in dir.listFiles()!!.sortedBy { it.name }) {
            if (!f.name.endsWith(".class")) continue
            val c = try { Class.forName("de.bornim.core.art." + f.name.removeSuffix(".class")) } catch (e: Throwable) { continue }
            val inst = try { c.getDeclaredField("INSTANCE").get(null) } catch (e: Throwable) { null }
            for (fld in c.declaredFields) {
                val stat = Modifier.isStatic(fld.modifiers)
                if (!stat && inst == null) continue
                if (fld.type.isPrimitive) continue
                val v = try { fld.isAccessible = true; fld.get(if (stat) null else inst) } catch (e: Throwable) { continue } ?: continue
                val b = walk(v, seen, 0)
                if (b > 512 * 1024) rows += "${c.simpleName}.${fld.name}" to b
            }
        }
        val all = rows.sumOf { it.second }
        println("MEMPROBE $title: Heap belegt ${used() shr 20} MB, Bilder gesamt ${all shr 20} MB")
        for ((n, b) in rows.sortedByDescending { it.second }.take(25)) println("MEMPROBE   ${b shr 20} MB  $n")
    }

    private fun walk(v: Any, seen: IdentityHashMap<Any, Boolean>, depth: Int): Long {
        if (depth > 6 || seen.put(v, true) != null) return 0
        return when (v) {
            is PixelImage -> v.pixels.size * 4L
            is Map<*, *> -> synchronized(v) { v.values.toList() }.sumOf { if (it == null) 0L else walk(it, seen, depth + 1) } +
                synchronized(v) { v.keys.toList() }.sumOf { if (it == null || it is String) 0L else walk(it, seen, depth + 1) }
            is Collection<*> -> synchronized(v) { v.toList() }.sumOf { if (it == null) 0L else walk(it, seen, depth + 1) }
            is Array<*> -> v.sumOf { if (it == null) 0L else walk(it, seen, depth + 1) }
            is IntArray -> if (v.size > 4096) v.size * 4L else 0
            is Pair<*, *> -> (v.first?.let { walk(it, seen, depth + 1) } ?: 0) + (v.second?.let { walk(it, seen, depth + 1) } ?: 0)
            is Triple<*, *, *> -> listOfNotNull(v.first, v.second, v.third).sumOf { walk(it, seen, depth + 1) }
            else -> if (v.javaClass.name.startsWith("de.bornim")) v.javaClass.declaredFields.filter { !Modifier.isStatic(it.modifiers) && !it.type.isPrimitive }
                .sumOf { f -> try { f.isAccessible = true; f.get(v)?.let { walk(it, seen, depth + 1) } ?: 0L } catch (e: Throwable) { 0L } } else 0
        }
    }
}
