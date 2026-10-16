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
    fun kroggComesApartInHisFinePicture() {
        // 36.6: Krogg is drawn 1.5 times finer in battle, and so are the halves of the killing blow, in the same place
        val fine = de.bornim.core.art.MonsterArt.fine("bugbear")
        assertTrue(fine > 1.0)
        for (s in listOf(HeroFigure.Strike.KILL_HIGH, HeroFigure.Strike.KILL_PIERCE)) {
            val plan = KillPlan.of("bugbear", MonsterLook(5), s, 2, 3)
            val coarse = KillPlan.of("goblin", MonsterLook(5), s, 2, 3)
            assertTrue(plan.pieces.isNotEmpty() && plan.pieces.all { it.fine == fine }, "$s")
            assertTrue(coarse.pieces.all { it.fine == 1.0 }, "$s goblin")
            // the pieces together cover what the whole coarse frame covers, in art pixels
            val img = de.bornim.core.art.MonsterArt.battleFrame("bugbear", MonsterLook(5), de.bornim.core.art.Act.DIE, de.bornim.core.art.MonsterArt.dieVariant("bugbear", MonsterLook(5)), 0)
            var x0 = img.width; var x1 = 0; var y0 = img.height; var y1 = 0
            for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) >= 128) { x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y) }
            val px0 = plan.pieces.minOf { it.ox / fine }; val py0 = plan.pieces.minOf { it.oy / fine }
            val px1 = plan.pieces.maxOf { (it.ox + it.img.width) / fine }; val py1 = plan.pieces.maxOf { (it.oy + it.img.height) / fine }
            assertTrue(kotlin.math.abs(px0 - x0) < 2 && kotlin.math.abs(py0 - y0) < 2 && kotlin.math.abs(px1 - x1) < 3 && kotlin.math.abs(py1 - y1) < 3,
                "$s: pieces $px0,$py0–$px1,$py1, frame $x0,$y0–$x1,$y1")
        }
    }

    @Test
    fun killingBlowsLandOnTheirStrikeFrame() {
        for (st in HeroFigure.Stance.entries) for (s in HeroFigure.Strike.entries.filter { it.killing }) {
            val seq = HeroFigure.sequence(HeroFigure.Act.ATTACK, s, 0, st)
            assertTrue(HeroFigure.strikeFrame(s) < seq.size - 2, "$st $s")
        }
    }
}
