package de.bornim.core

import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 112 (7): the temple scene's life file is read, flames flicker within bounds, the dust stays in the shaft and moves. */
class TempleLifeTest {
    private val sample = """
        # comment
        flamme 1 100.0 200.0 30.5
        flamme 4 500 600 12
        flamme x 1 2 3
        strahl 4 100 100 400 300 380 340 80 140
        unbekannt 1 2
    """.trimIndent()

    @Test
    fun readsFlamesAndShaftAndLeavesOutWhatItDoesNotKnow() {
        val life = TempleLife.parse(sample)
        assertEquals(2, life.flames.size)
        assertEquals(TempleLife.Flame(1, 100f, 200f, 30.5f), life.flames(1).single())
        assertEquals(4, life.shafts.getValue(4).size)
    }

    @Test
    fun flickerStaysInBounds() {
        for (i in 0 until 20) for (ms in 0L until 10_000L step 37) assertTrue(TempleLife.flicker(i, ms) in 0.75f..1.25f)
    }

    @Test
    fun dustStaysInTheShaftAndDrifts() {
        val shaft = TempleLife.parse(sample).shafts.getValue(4)
        val a = TempleLife.motes(shaft, 1000L); val b = TempleLife.motes(shaft, 3000L)
        assertTrue(a.size > 20, "enough motes: ${a.size}")
        assertTrue(a.all { TempleLife.inside(shaft, it.x, it.y) && it.a in 0f..1f })
        assertTrue(a.take(10).map { it.x to it.y } != b.take(10).map { it.x to it.y }, "the dust moves")
    }

    /** The file the painter wrote: pictures 1–4 have candles burning, picture 5 the one before the eye, picture 4 the shaft. */
    @Test
    fun theShippedFileHasLifeInEveryPicture() {
        val f = File("../app/src/main/assets/tempel/leben.txt")
        if (!f.exists()) return
        val life = TempleLife.parse(f.readText())
        for (pic in 1..5) assertTrue(life.flames(pic).isNotEmpty(), "picture $pic has flames")
        assertTrue(life.flames.all { it.x in -20f..TempleLife.W + 20 && it.y in -20f..TempleLife.H + 20 && it.s > 0 })
        assertTrue(life.shafts.containsKey(4), "picture 4 has the sun shaft")
    }
}
