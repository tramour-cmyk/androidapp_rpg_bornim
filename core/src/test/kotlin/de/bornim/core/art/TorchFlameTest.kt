package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Loot
import de.bornim.core.Race
import kotlin.test.Test
import kotlin.test.assertEquals
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

    /** 343 (Chef 23.10., 14:08): by day the torch stays out while the cloak swings on after turning and letting go. */
    @Test
    fun theTorchStaysOutWhileTheCloakSwingsOn() {
        val hero = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).hero
        hero.equip(Loot.torch(1))
        val stand = MapFigure.lit(hero, MapFigure.rig(4 * 360.0 / MapFigure.YAWS, 0, MapFigure.Carry.LOW), 0, true)
        for (level in listOf(-6, -1, 1, 5)) {
            val swing = MapFigure.swingLit(hero, 4, level, held = true)
            assertTrue(swing.out, "out at swing $level")
            assertEquals(stand.lh.r to stand.lh.u, swing.lh.r to swing.lh.u, "held up as standing at swing $level")
            assertTrue(!MapFigure.swingLit(hero, 4, level, held = false).out, "burns in the dark at swing $level")
        }
    }
}
