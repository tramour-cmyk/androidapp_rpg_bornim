package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * 249 (Chef 21.10., 18:09 „wo ist der Anfangspunkt des Angriffes … und dann wo ist der Treffer“): in MARS a figure is
 * not drawn larger in its lunge, so the step [HeroBattle.reach] and [MonsterArt.reach] give puts the weapon's point, the
 * teeth or the claws, drawn at their own size, right on the point aimed at (an animal's below it, as in the classic fight).
 */
class MarsReachTest {
    private fun near(a: Double, b: Double) = abs(a - b) < 1e-6

    @Test
    fun theHerosPointLandsOnTheAim() {
        val hero = GameState.newGame("Test", Race.HUMAN, CharClass.FIGHTER).hero
        for (s in HeroBattle.strikes(hero)) {
            val (tx, ty) = HeroBattle.tip(hero, s)
            val (rx, ry) = HeroBattle.reach(hero, s, 120.0, -90.0)
            assertTrue(near(rx + tx - HeroBattle.ANCHOR_X, 120.0) && near(ry + ty - HeroBattle.GROUND, -90.0), "$s")
        }
    }

    @Test
    fun aFoesBlowLandsOnTheAim() {
        val look = MonsterLook(0)
        for (id in listOf("goblin", "hobgoblin_captain", "skeleton")) {
            val (tx, ty) = FoeArt.tip(id, look, 0)
            val (rx, ry) = MonsterArt.reach(id, look, 0, -150.0, -60.0)!!
            assertTrue(near(rx + tx - MonsterArt.anchorX(id, 0), -150.0) && near(ry + ty - MonsterArt.groundLine(id), -60.0), id)
        }
    }

    @Test
    fun aWolfBitesAtTheAimOrBelowIt() {
        val look = MonsterLook(0)
        for (v in 0..1) {
            val (tx, ty) = BeastArt.tip("wolf", look, v)
            val (rx, ry) = MonsterArt.reach("wolf", look, v, -150.0, 20.0)!!
            assertTrue(near(rx + tx - BeastArt.ANCHOR_X, -150.0) && ry + ty - BeastArt.GROUND >= 20.0 - 1e-6, "wolf $v")
        }
        assertNull(MonsterArt.reach("ochre_jelly_old_style_none", look, 0, 0.0, 0.0))
    }
}
