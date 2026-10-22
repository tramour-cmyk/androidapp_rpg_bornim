package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertTrue

/** 311: under the fight camera every fall ends with the hero lying across the picture, not foreshortened into it. */
class HeroFallTest {
    @Test fun everyFallLiesAcross() {
        val hero = de.bornim.core.GameState.newGame("Alrik", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero
        for (v in 0..2) {
            val n = HeroBattle.frameCount(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, v)
            val img = HeroBattle.frame(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, v, n - 1)
            var x0 = Int.MAX_VALUE; var x1 = Int.MIN_VALUE
            for (y in 0 until img.height) for (x in 0 until img.width) if ((img[x, y] ushr 24) >= 128) { x0 = minOf(x0, x); x1 = maxOf(x1, x) }
            // a fighter stretched out is about 150 px long; lying into the picture it was 88 (Chef 22.10., 22:06)
            assertTrue(x1 - x0 >= 120, "fall $v lies only ${x1 - x0} px wide")
        }
    }
}
