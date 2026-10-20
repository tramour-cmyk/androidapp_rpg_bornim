package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

/** 257 (Chef 20.10.: "die Fackel … wenn man einfach steht, hat keine Animation"): standing, the flame keeps changing its shape. */
class TorchFlameTest {
    @Test
    fun theFlameChangesUnevenlyWhileTheHeroStands() {
        var was = MapFigure.flame(0)
        var since = 0L
        val holds = mutableListOf<Long>()
        val shapes = mutableSetOf(was)
        for (t in 1L until 60_000L) {
            val f = MapFigure.flame(t)
            assertTrue(f in 0..2, "flame $f at $t")
            if (f != was) { holds += t - since; since = t; was = f; shapes += f }
        }
        assertTrue(shapes.size == 3, "shapes: $shapes")
        val inner = holds.drop(1)
        assertTrue(inner.all { it in 120..220 }, "holds: ${inner.min()}–${inner.max()} ms")
        assertTrue(inner.toSet().size > 20, "holds too even")
    }
}
