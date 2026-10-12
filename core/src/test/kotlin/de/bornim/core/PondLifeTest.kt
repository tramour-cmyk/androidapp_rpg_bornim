package de.bornim.core

import de.bornim.core.art.MapGround
import de.bornim.core.art.PondLife
import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 27.6: life at the forest pond finds its places from the shore and moves without jumps. */
class PondLifeTest {
    private val life = PondLife.of(Story.forest)

    @Test
    fun frogsOnTheBankDragonfliesOverTheWater() {
        assertTrue(life.frogs.size in 2..3, "frogs: ${life.frogs.size}")
        assertEquals(2, life.flies.size)
        for (f in life.frogs) {
            assertTrue(MapGround.water(Story.forest, f.x, f.y) < 0.5, "frog on dry ground")
            assertTrue(MapGround.water(Story.forest, f.wx, f.wy) > 0.5, "frog lands in the water")
        }
        for (d in life.flies) for (t in 0L until 60_000L step 50) {
            val a = d.at(t)
            assertTrue(MapGround.water(Story.forest, a.x, a.y) > 0.5, "dragonfly over the water at $t")
        }
    }

    @Test
    fun dragonfliesDartButNeverJump() {
        for (d in life.flies) {
            var last = d.at(0)
            var hanging = 0
            for (t in 16L until 30_000L step 16) {
                val a = d.at(t)
                val step = hypot(a.x - last.x, a.y - last.y)
                // a dart covers at most ~26 px in ~0.5 s: never more than a few pixels a frame
                assertTrue(step < 4f, "step $step at $t")
                if (step < 0.3f) hanging++
                last = a
            }
            assertTrue(hanging > 800, "it hangs still most of the time: $hanging")
        }
    }

    @Test
    fun frogLeapsInAndComesBackWithoutJumps() {
        val f = life.frogs.first()
        // the hero walks up, waits, and walks away again
        var last = f.at(0, f.x + 200, f.y, false)
        val moods = mutableListOf(last.mood)
        for (t in 16L until 40_000L step 16) {
            val hx = when {
                t < 5_000 -> f.x + 200 - t / 5_000f * 180
                t < 10_000 -> f.x + 20
                else -> f.x + 20 + (t - 10_000) / 4_000f * 200
            }
            val a = f.at(t, hx.coerceAtMost(f.x + 220), f.y, false)
            val visible = a.mood != PondLife.Mood.UNDER && last.mood != PondLife.Mood.UNDER
            if (visible) assertTrue(hypot(a.x - last.x, a.y - last.y) < 3f, "frog jumps at $t (${last.mood} → ${a.mood})")
            if (a.mood != moods.last()) moods += a.mood
            last = a
        }
        assertEquals(
            listOf(PondLife.Mood.SIT, PondLife.Mood.LEAP, PondLife.Mood.UNDER, PondLife.Mood.SURFACE, PondLife.Mood.SWIM, PondLife.Mood.CLIMB, PondLife.Mood.SIT),
            moods,
        )
    }
}
