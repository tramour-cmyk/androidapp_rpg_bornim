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

    /** 328 (Chef 23.10., 00:16): no fall of any hero is cut off at the edge of its frame, in any frame. */
    @Test fun noFallIsCutOff() {
        for (cls in de.bornim.core.CharClass.values()) for (race in listOf(de.bornim.core.Race.HUMAN, de.bornim.core.Race.ELF, de.bornim.core.Race.DWARF, de.bornim.core.Race.HALFLING)) {
            val hero = de.bornim.core.GameState.newGame("Alrik", race, cls).hero
            for (v in 0..2) {
                val n = HeroBattle.frameCount(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, v)
                for (i in 0 until n) {
                    val img = HeroBattle.frame(hero, HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, v, i)
                    fun on(x: Int, y: Int) = (img[x, y] ushr 24) >= 128
                    val edge = (0 until img.width).any { on(it, 0) || on(it, img.height - 1) } || (0 until img.height).any { on(0, it) || on(img.width - 1, it) }
                    assertTrue(!edge, "$cls $race fall $v frame $i is cut off at the edge (${img.width}×${img.height}: top ${(0 until img.width).count { on(it, 0) }}, bottom ${(0 until img.width).count { on(it, img.height - 1) }}, left ${(0 until img.height).count { on(0, it) }}, right ${(0 until img.height).count { on(img.width - 1, it) }})")
                }
            }
        }
    }
}
