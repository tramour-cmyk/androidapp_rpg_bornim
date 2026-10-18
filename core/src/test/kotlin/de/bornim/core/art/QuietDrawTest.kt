package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 175: the map's figures drawn in the background share only a few quiet cores, unless the black screen waits for them. */
class QuietDrawTest {

    private fun poolOn(quiet: Boolean, hurry: Boolean): java.util.concurrent.ForkJoinPool? {
        var p: java.util.concurrent.ForkJoinPool? = null
        SdfRender.hurry = hurry
        try {
            Thread { SdfRender.quiet.set(quiet); p = SdfRender.ownPool() }.also { it.start(); it.join() }
        } finally { SdfRender.hurry = false }
        return p
    }

    @Test fun backgroundDrawingStaysOnTheQuietCores() {
        val p = assertNotNull(poolOn(quiet = true, hurry = false), "a quiet thread draws on cores of its own")
        assertTrue(p.parallelism <= SdfRender.QUIET, "only a few cores")
        // the pool's threads start when first asked: they draw at the lowest priority
        var prio = 0
        p.submit { prio = Thread.currentThread().priority }.get()
        assertEquals(Thread.MIN_PRIORITY, prio)
    }

    @Test fun behindTheBlackScreenEveryCoreHelps() {
        assertNull(poolOn(quiet = true, hurry = true), "while the black screen waits, every core")
        assertNull(poolOn(quiet = false, hurry = false), "other drawing as before")
    }

    @Test fun theHeroLeavesTheHurryWithTheScreen() {
        MapFigure.urgent = true
        assertTrue(SdfRender.hurry)
        MapFigure.urgent = false
        assertTrue(!SdfRender.hurry)
    }
}
