package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The halt as a blow lands (16): graded by how hard it is, at every pace, and a jolt that goes out and back once. */
class HitWeightTest {
    /** One frame of a blow at normal pace (BattleScreen, ATTACK_FRAME_MS). */
    private val frame = 92L

    @Test
    fun weights() {
        assertEquals(HitWeight.NORMAL, HitWeight.of(crit = false, damage = 3, maxHp = 20))
        assertEquals(HitWeight.NORMAL, HitWeight.of(crit = false, damage = 6, maxHp = 20))
        assertEquals(HitWeight.HARD, HitWeight.of(crit = false, damage = 7, maxHp = 20))
        assertEquals(HitWeight.HARD, HitWeight.of(crit = false, damage = 4, maxHp = 12))
        assertEquals(HitWeight.CRIT, HitWeight.of(crit = true, damage = 1, maxHp = 20))
        assertEquals(HitWeight.KILL, HitWeight.of(crit = true, damage = 20, maxHp = 20, kill = true))
        assertEquals(HitWeight.NORMAL, HitWeight.of(crit = false, damage = 0, maxHp = 0))
    }

    @Test
    fun haltsRiseAndKeepToFrames() {
        for (pace in listOf(0.7, 1.0, 1.35)) {
            val ms = HitWeight.entries.map { it.stopMs(pace) }
            assertEquals(ms.sorted(), ms, "pace $pace: $ms")
            assertTrue(ms.zipWithNext().all { (a, b) -> b > a }, "pace $pace: $ms")
        }
        // a plain hit only catches (under a frame), a hard one stands two frames, a critical one three
        assertTrue(HitWeight.NORMAL.stopMs < frame)
        assertTrue(HitWeight.HARD.stopMs in (frame * 2 - 10)..(frame * 2 + 10))
        assertTrue(HitWeight.CRIT.stopMs in (frame * 3 - 10)..(frame * 3 + 10))
        // a turn grows by a third of a second at most
        assertTrue(HitWeight.CRIT.stopMs - HitWeight.NORMAL.stopMs <= 300L)
        // only a critical hit draws in by itself; plain and hard hits do not jolt
        assertEquals(listOf(0f, 0f, 0.06f, 0f), HitWeight.entries.map { it.zoom })
        assertEquals(0f, HitWeight.NORMAL.joltDp); assertEquals(0f, HitWeight.HARD.joltDp)
        assertTrue(HitWeight.CRIT.joltMs in 100L..200L)
    }

    @Test
    fun joltGoesOutAndBackOnce() {
        val n = 60
        val v = (0..n).map { HitWeight.jolt(it / n.toFloat()) }
        assertEquals(0f, v.first()); assertEquals(0f, v.last())
        assertTrue(v.all { it in 0f..1f }, "never past the rest")
        // rises to its height, then falls, no shaking to and fro
        val top = v.indexOf(v.max())
        assertTrue(v.take(top + 1).zipWithNext().all { (a, b) -> b >= a })
        assertTrue(v.drop(top).zipWithNext().all { (a, b) -> b <= a })
        // no frame moves more than a tenth of the way at 60 frames
        assertTrue(v.zipWithNext().all { (a, b) -> kotlin.math.abs(b - a) <= 0.1f })
    }
}
