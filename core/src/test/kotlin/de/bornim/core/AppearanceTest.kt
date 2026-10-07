package de.bornim.core

import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AppearanceTest {
    @Test
    fun lookIsSavedAndOldSavesGetASteadyOne() {
        val st = GameState.newGame("Ilse", Race.ELF, CharClass.WIZARD)
        st.hero.sex = Sex.FEMALE; st.hero.build = Build.SLIM; st.hero.skin = 2; st.hero.hair = 3
        val back = GameState.fromJson(st.toJson()).hero
        assertEquals(Sex.FEMALE, back.sex); assertEquals(Build.SLIM, back.build); assertEquals(2, back.skinTone); assertEquals(3, back.hairTone)
        // a save from before: the four fields missing
        val old = st.toJson().replace(Regex(",\"(sex|build|skin|hair)\":(\"[A-Z]+\"|-?\\d+)"), "")
        val hero = GameState.fromJson(old).hero
        assertEquals(Sex.MALE, hero.sex); assertEquals(Build.AVERAGE, hero.build)
        assertTrue(hero.skinTone in 0..3 && hero.hairTone in 0..3)
        assertEquals(hero.skinTone, GameState.fromJson(old).hero.skinTone)
    }

    @Test
    fun blockHeightFollowsTheFoe() {
        val fighter = GameState.newGame("A", Race.HUMAN, CharClass.FIGHTER).hero
        assertEquals(2, HeroBattle.blockVariant(fighter, "wolf"))
        assertEquals(0, HeroBattle.blockVariant(fighter, "goblin"))
        val n = HeroBattle.frameCount(fighter, HeroFigure.Act.BLOCK, HeroFigure.Strike.SLASH, 2)
        assertTrue(n > 5)
    }
}
