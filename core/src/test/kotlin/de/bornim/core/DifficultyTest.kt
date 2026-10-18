package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 39: the difficulty scales the foe's hit points and its damage, and stays in the save. */
class DifficultyTest {
    private fun battle(d: Difficulty, seed: Int): Battle {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        s.difficulty = d
        return Battle(s, Monsters["bugbear"], Lang.DE, Dice(Random(seed)), 3)
    }

    @Test
    fun foeHitPointsFollowTheDifficulty() {
        for (seed in 1..20) {
            val normal = battle(Difficulty.NORMAL, seed).enemyMaxHp
            assertEquals((normal * Difficulty.EASY.hp).toInt(), battle(Difficulty.EASY, seed).enemyMaxHp, "Leicht, Wurf $seed")
            assertEquals((normal * Difficulty.HARD.hp).toInt(), battle(Difficulty.HARD, seed).enemyMaxHp, "Schwer, Wurf $seed")
        }
    }

    /** The hero's HP lost over the foe's first turns, for many seeds. */
    private fun lost(d: Difficulty): Int = (1..200).sumOf { seed ->
        val b = battle(d, seed)
        b.start()
        if (b.outcome == Outcome.ONGOING) b.act(Action.Defend)
        b.state.hero.maxHp - b.state.hero.hp
    }

    @Test
    fun foeDamageFollowsTheDifficulty() {
        val easy = lost(Difficulty.EASY); val normal = lost(Difficulty.NORMAL); val hard = lost(Difficulty.HARD)
        assertTrue(easy < normal && normal < hard, "Leicht $easy, Normal $normal, Schwer $hard")
    }

    @Test
    fun difficultyStaysInTheSave() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.WIZARD)
        assertEquals(Difficulty.NORMAL, s.difficulty)
        s.difficulty = Difficulty.HARD
        assertEquals(Difficulty.HARD, GameState.fromJson(s.toJson()).difficulty)
        // a save from before 39 has no field: Normal
        assertEquals(Difficulty.NORMAL, GameState.fromJson(s.toJson().replace("\"difficulty\":\"HARD\",", "").replace(",\"difficulty\":\"HARD\"", "")).difficulty)
    }
}
