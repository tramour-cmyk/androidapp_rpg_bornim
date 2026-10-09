package de.bornim.core

import de.bornim.core.art.HeroFigure
import de.bornim.core.art.KillArt
import de.bornim.core.art.KillPlan
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The killing blow: every foe can be cut, run through or burst, and its pieces come to rest on the ground. */
class KillBlowTest {
    @Test
    fun everyFoeComesApartAndSettles() {
        val ids = listOf("goblin", "skeleton", "zombie", "bugbear", "wolf", "boar", "giant_rat", "giant_spider", "giant_bat", "stirge", "ochre_jelly", "ghoul")
        for (id in ids) for (blood in 0..2) for (s in listOf(HeroFigure.Strike.KILL_HIGH, HeroFigure.Strike.KILL_PIERCE)) {
            val plan = KillPlan.of(id, MonsterLook(5), s, blood, 3)
            when (plan.kind) {
                KillArt.Kind.SPLIT, KillArt.Kind.HOLE, KillArt.Kind.SHATTER -> assertTrue(plan.pieces.isNotEmpty(), "$id $blood $s")
                else -> assertTrue(plan.pieces.isEmpty(), "$id $blood $s")
            }
            assertTrue(plan.settles in 0.0..3000.0, "$id settles after ${plan.settles} ms")
            // long after, every flying piece lies with its middle above the ground (or where it was, the jelly's puddle), not under it
            for (p in plan.pieces.filter { !it.topple }) {
                val pose = KillArt.pose(p, 5000.0, plan.ground)
                assertTrue(p.cy + pose.dy <= maxOf(plan.ground, p.cy) + 0.5, "$id piece under the ground")
            }
        }
        // skeletons always burst; without blood the living only sink down darkened
        assertEquals(KillArt.Kind.SHATTER, KillPlan.of("skeleton", MonsterLook(1), null, 0, 1).kind)
        assertEquals(KillArt.Kind.DARK, KillPlan.of("goblin", MonsterLook(1), HeroFigure.Strike.KILL_HIGH, 0, 1).kind)
        assertEquals(KillArt.Kind.GUSH, KillPlan.of("goblin", MonsterLook(1), HeroFigure.Strike.KILL_HIGH, 1, 1).kind)
    }

    @Test
    fun killingBlowsLandOnTheirStrikeFrame() {
        for (st in HeroFigure.Stance.entries) for (s in HeroFigure.Strike.entries.filter { it.killing }) {
            val seq = HeroFigure.sequence(HeroFigure.Act.ATTACK, s, 0, st)
            assertTrue(HeroFigure.strikeFrame(s) < seq.size - 2, "$st $s")
        }
    }
}
