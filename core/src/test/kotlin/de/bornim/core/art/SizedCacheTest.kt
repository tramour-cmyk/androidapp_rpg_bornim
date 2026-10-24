package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 346: the bitmaps of the pictures shown are kept by their size, so new light images while walking cannot fill the heap. */
class SizedCacheTest {
    @Test
    fun walkingThroughTheDeepForestStaysWithinTheBudget() {
        val budget = SizedCache.pictureBudget(512L shl 20)
        assertEquals(32L shl 20, budget)
        val cache = SizedCache<PixelImage, Long>(budget, SizedCache.Companion::bytesOf)
        // 0.1.1008: a light image of about 400 x 200 made anew every few steps, a thousand steps
        repeat(1000) { cache.getOrPut(PixelImage(400, 200)) { 0L } }
        assertTrue(cache.held <= budget, "held ${cache.held shr 20} MB")
        assertEquals(cache.held, cache.size * 400L * 200 * 4)
    }

    @Test
    fun whatIsShownOftenStays() {
        val cache = SizedCache<PixelImage, Int>(10L * 100 * 100 * 4, SizedCache.Companion::bytesOf)
        val tree = PixelImage(100, 100)
        var made = 0
        repeat(50) { cache.getOrPut(tree) { ++made }; cache.getOrPut(PixelImage(100, 100)) { 0 } }
        assertEquals(1, made)
    }

    @Test
    fun aPictureOverTheBudgetIsStillShown() {
        val cache = SizedCache<PixelImage, Int>(1000, SizedCache.Companion::bytesOf)
        val big = PixelImage(100, 100)
        assertEquals(7, cache.getOrPut(big) { 7 })
        assertEquals(7, cache.getOrPut(big) { 8 })
        cache.getOrPut(PixelImage(100, 100)) { 9 }
        assertEquals(1, cache.size)
    }

    @Test
    fun aNearlyFullHeapLetsGoOfThePicturesNotNeeded() {
        val max = 512L shl 20
        var freed = 0
        assertTrue(!ArtMemory.checkHeap(300L shl 20, max, now = 0) { freed++ })
        assertTrue(ArtMemory.checkHeap(450L shl 20, max, now = 1_000_000) { freed++ })
        // not again at once: a fight needs much, and making every bitmap anew each frame would only slow it
        assertTrue(!ArtMemory.checkHeap(500L shl 20, max, now = 1_005_000) { freed++ })
        // 358: nor while the heap stays as high as it was: letting go again would free nothing (Build 85: six times)
        for (i in 1..6) assertTrue(!ArtMemory.checkHeap(460L shl 20, max, now = 1_005_000 + i * ArtMemory.PAUSE_MS) { freed++ })
        // grown by a tenth of the heap since: something new to let go
        assertTrue(ArtMemory.checkHeap(510L shl 20, max, now = 1_200_000) { freed++ })
        // fallen below and up again: as at first
        assertTrue(!ArtMemory.checkHeap(300L shl 20, max, now = 1_300_000) { freed++ })
        assertTrue(ArtMemory.checkHeap(420L shl 20, max, now = 1_400_000) { freed++ })
        assertEquals(3, freed)
    }

    @Test
    fun theFoeFoughtKeepsItsFrames() {
        val look = de.bornim.core.MonsterLook()
        val wolf = BeastArt.frame("wolf", look, Act.IDLE, 0, 0)
        val boar = BeastArt.frame("boar", look, Act.IDLE, 0, 0)
        BeastArt.forgetBut(setOf("wolf"))
        assertTrue(wolf === BeastArt.frame("wolf", look, Act.IDLE, 0, 0))
        assertTrue(boar !== BeastArt.frame("boar", look, Act.IDLE, 0, 0))
    }
}
