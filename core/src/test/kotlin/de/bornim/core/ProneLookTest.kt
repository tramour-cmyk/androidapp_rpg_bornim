package de.bornim.core

import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 295 (Chef 22.10., 07:43): thrown down in the old fight, the hero goes down on its knees as in MARS. */
class ProneLookTest {
    @Test
    fun aWolfThatThrowsTheHeroDownSaysSoWithItsOwnMove() {
        var seen = false
        for (seed in 1..60) {
            val s = GameState.newGame("P", Race.HALFLING, CharClass.WIZARD)
            s.hero.restoreFully()
            val b = Battle(s, Monsters["wolf"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            val steps = b.start().toMutableList()
            repeat(6) { if (b.outcome == Outcome.ONGOING) steps += b.act(Action.Attack) }
            val prone = steps.filter { "in die Knie gezwungen" in it.text }
            prone.forEach { assertEquals(Anim.HERO_PRONE, it.anim, it.text) }
            if (prone.isNotEmpty()) seen = true
        }
        assertTrue(seen, "in 60 Kämpfen kein Wolf, der den Helden umwirft")
    }

    /** 309: the blow from the knee shows its disadvantage on the roll, and every hit or miss carries its roll. */
    @Test
    fun theBlowFromTheKneeShowsItsDisadvantageOnTheRoll() {
        var seen = false
        for (seed in 1..60) {
            val s = GameState.newGame("P", Race.HUMAN, CharClass.FIGHTER)
            s.hero.restoreFully()
            val b = Battle(s, Monsters["wolf"], Lang.DE, Dice(Random(seed)), 1, false, 1)
            val steps = b.start().toMutableList()
            repeat(6) { if (b.outcome == Outcome.ONGOING) steps += b.act(Action.Attack) }
            steps.filter { it.anim == Anim.MISS || (it.anim == Anim.ENEMY_HIT && it.fx?.kind != FxKind.BLEED) }.forEach { assertTrue(it.roll != null, it.text) }
            val at = steps.indexOfFirst { it.anim == Anim.HERO_PRONE }
            if (at < 0) continue
            val blow = steps.drop(at + 1).firstOrNull { it.roll != null && it.fx?.onHero == false } ?: continue
            assertEquals(-1, blow.roll!!.mode, blow.text)
            seen = true
        }
        assertTrue(seen, "in 60 Kämpfen kein Hieb aus dem Knien")
    }

    @Test
    fun theKneelingIsDrawnAheadOnlyForFoesThatThrowDown() {
        val hero = GameState.newGame("P", Race.HUMAN, CharClass.FIGHTER).hero
        val wolf = HeroBattle.planOf(hero, "wolf", false, 0).map { it.first }
        assertTrue(HeroFigure.Act.KNEEL in wolf && HeroFigure.Act.RISE in wolf)
        val goblin = HeroBattle.planOf(hero, "goblin", false, 0).map { it.first }
        assertTrue(HeroFigure.Act.KNEEL !in goblin)
        assertEquals(setOf(0, 1, 2), (0..7).map { HeroBattle.kneelPick(it) }.toSet())
    }
}
