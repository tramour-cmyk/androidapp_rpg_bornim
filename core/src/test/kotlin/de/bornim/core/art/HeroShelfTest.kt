package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Gear
import de.bornim.core.Rarity
import de.bornim.core.Race
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 24.4: the hero's map pictures kept on the device come back exactly as drawn, and make the hero ready at once. */
class HeroShelfTest {

    @Test fun keptPicturesComeBackTheSame() {
        val dir = kotlin.io.path.createTempDirectory("shelf").toFile()
        try {
            HeroShelf.dir = dir
            val a = PixelImage(3, 2, intArrayOf(0, -1, 0x12345678, 7, 0x7f000000, 1))
            val b = PixelImage(2, 1, intArrayOf(5, 6))
            HeroShelf.save("look/a", mapOf((0 to 0) to a, (15 to 7) to b))
            val back = HeroShelf.load("look/a")!!
            assertEquals(2, back.size)
            assertContentEquals(a.pixels, back[0 to 0]!!.pixels)
            assertEquals(2, back[15 to 7]!!.width)
            assertNull(HeroShelf.load("look/b"), "nothing kept for another look")
            for (i in 0 until HeroShelf.KEEP + 3) HeroShelf.save("other$i", mapOf((0 to 0) to b))
            assertEquals(HeroShelf.KEEP, dir.listFiles { f -> f.name.endsWith(".pix") }!!.size, "only the newest looks stay")
        } finally { HeroShelf.dir = null; dir.deleteRecursively() }
    }

    @Test fun aKeptHeroIsReadyWithoutDrawing() {
        val dir = kotlin.io.path.createTempDirectory("shelf").toFile()
        try {
            HeroShelf.dir = dir
            val hero = GameState.newGame("Shelf", Race.HALFLING, CharClass.ROGUE).hero
            MapFigure.prepare(hero, 0.0)
            assertTrue(waitFor { MapFigure.lastFullMs != null }, "drawn in full")
            assertTrue(!MapFigure.lastFromShelf)
            assertTrue(MapFigure.full(hero), "full once drawn in full (t60: fights drawn ahead only then)")
            val drawn = MapFigure.frame(hero, 9, 5)!!
            assertTrue(waitFor { dir.listFiles { f -> f.name.endsWith(".pix") }!!.isNotEmpty() }, "kept on the device")
            // another hero in between, then back: read from the device, not drawn
            MapFigure.prepare(GameState.newGame("Other", Race.HUMAN, CharClass.WIZARD).hero, 0.0)
            assertTrue(!MapFigure.full(hero), "another hero: not full")
            try {
                MapFigure.hold = true // the drawing threads stand still; only reading can make it ready
                MapFigure.prepare(hero, 0.0)
                assertTrue(waitFor(10_000) { MapFigure.ready(hero) }, "ready from the device")
                // ready comes before the worker marks where the pictures came from (wobbly under load, 23.10.)
                assertTrue(waitFor(10_000) { MapFigure.full(hero) }, "marked done")
                assertTrue(MapFigure.lastFromShelf)
                assertContentEquals(drawn.pixels, MapFigure.frame(hero, 9, 5)!!.pixels)
            } finally { MapFigure.hold = false }
        } finally { HeroShelf.dir = null; dir.deleteRecursively() }
    }

    @Test fun newLootIsDrawnAheadAndWornAtOnce() {
        val dir = kotlin.io.path.createTempDirectory("shelf").toFile()
        try {
            HeroShelf.dir = dir
            val hero = GameState.newGame("Ahead", Race.DWARF, CharClass.FIGHTER).hero
            MapFigure.prepare(hero, 0.0)
            assertTrue(waitFor { dir.listFiles { f -> f.name.endsWith(".pix") }!!.size == 1 }, "own pictures drawn and kept first")
            val files = 1
            val loot = Gear(9_001, "warhammer", Rarity.COMMON, 1)
            MapFigure.ahead(hero, loot)
            assertTrue(waitFor { dir.listFiles { f -> f.name.endsWith(".pix") }!!.size == files + 1 }, "drawn ahead and kept")
            assertTrue(hero.weapon?.base != "warhammer", "the hero itself is not changed")
            // putting it on: read from the device, nothing drawn
            hero.equip(loot)
            try {
                MapFigure.hold = true
                MapFigure.prepare(hero, 0.0)
                assertTrue(waitFor(10_000) { MapFigure.ready(hero) }, "ready from the device")
                // ready comes before the worker marks where the pictures came from (wobbly under load, 23.10.)
                assertTrue(waitFor(10_000) { MapFigure.full(hero) }, "marked done")
                assertTrue(MapFigure.lastFromShelf)
            } finally { MapFigure.hold = false }
        } finally { HeroShelf.dir = null; dir.deleteRecursively() }
    }

    @Test fun theHeroWithoutTheTorchIsDrawnAheadFirstAndNeverPushedOut() {
        // 345 (Chef 23.10., B84): torch laid down, gone only 2–3 s later; the hero without it waited behind the loot
        val dir = kotlin.io.path.createTempDirectory("shelf").toFile()
        try {
            HeroShelf.dir = dir
            val hero = GameState.newGame("Unlit", Race.HUMAN, CharClass.FIGHTER).hero
            hero.equip(de.bornim.core.Loot.torch(9_100))
            MapFigure.hold = true // nothing is drawn: only the order of the wishes counts
            try {
                MapFigure.aheadUnlit(hero)
                val unlit = MapFigure.aheadWaiting().single()
                for (i in 1..MapFigure.AHEAD + 2) MapFigure.ahead(hero, Gear(9_200L + i, listOf("warhammer", "mace", "spear", "handaxe", "longsword", "shortsword")[i - 1], Rarity.COMMON, 1))
                val waiting = MapFigure.aheadWaiting()
                assertEquals(unlit, waiting.first(), "drawn first: $waiting")
                assertEquals(MapFigure.AHEAD + 1, waiting.size, "the loot is still held to ${MapFigure.AHEAD}, the hero without the torch on top")
            } finally { MapFigure.hold = false }
        } finally { HeroShelf.dir = null; dir.deleteRecursively() }
    }

    /** 299.1: the folk standing are read from the device like the hero, so the black screen need not wait for drawing them. */
    @Test fun theFolkStandingComeFromTheDevice() {
        val dir = kotlin.io.path.createTempDirectory("shelf").toFile()
        try {
            HeroShelf.dir = dir
            val pim = MapFolk.of("pim")!!
            MapFolk.keepOnly(emptySet())
            MapFolk.prepare(pim, 0)
            assertTrue(waitFor { (0 until MapFigure.YAWS).all { MapFolk.frame(pim, it, 0) != null } }, "drawn standing")
            assertTrue(waitFor { HeroShelf.loadFolk(MapFolk.shelfName(pim, listOf(0)))?.size == MapFigure.YAWS }, "kept on the device")
            // kept pictures stand in for drawing: a marked set on the device is what shows after memory was let go
            val mark = PixelImage(1, 1, intArrayOf(0x12345678))
            HeroShelf.saveFolk(MapFolk.shelfName(pim, listOf(0)), (0 until MapFigure.YAWS).associate { (it to 0) to mark })
            MapFolk.keepOnly(emptySet())
            MapFolk.prepare(pim, 0)
            assertTrue(waitFor(10_000) { (0 until MapFigure.YAWS).all { MapFolk.frame(pim, it, 0) != null } }, "standing from the device")
            assertContentEquals(mark.pixels, MapFolk.frame(pim, 5, 0)!!.pixels)
            assertTrue(dir.listFiles { f -> f.name.endsWith(".pix") }!!.isEmpty(), "the folk never push out the hero's looks")
        } finally { MapFolk.keepOnly(emptySet()); HeroShelf.dir = null; dir.deleteRecursively() }
    }

    private fun waitFor(ms: Long = 60_000, ok: () -> Boolean): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) { if (ok()) return true; Thread.sleep(20) }
        return ok()
    }
}
