package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class LevelUpMessageTest {
    /** Wins a fight that takes the hero from [from] to the next level and returns all battle texts. */
    private fun levelUpTexts(from: Int): List<String> {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.state(from)
        val texts = mutableListOf<String>()
        val b = Battle(s, Monsters["giant_rat"], Lang.DE, Dice(Random(1)), 1, false, 1)
        texts += b.start().map { it.text }
        var n = 0
        while (b.outcome == Outcome.ONGOING && n++ < 60) {
            s.hero.hp = s.hero.maxHp
            texts += b.act(Action.Attack).map { it.text }
        }
        assertEquals(Outcome.WON, b.outcome)
        assertEquals(from + 1, s.hero.level, "fight should bring exactly one level")
        return texts
    }

    private fun GameState.state(level: Int) {
        hero.gainXp(Rules.xpForLevel[level + 1] - 1 - hero.xp)
        assertEquals(level, hero.level)
    }

    @Test
    fun abilityPointHintOnlyAtSrdLevels() {
        for (from in 1..5) {
            val texts = levelUpTexts(from)
            val hint = texts.filter { "Attributspunkt" in it }
            if (from + 1 in Rules.abilityLevels) assertEquals(listOf("+2 Attributspunkt(e) – verteile sie im Menü."), hint, "level ${from + 1}")
            else assertTrue(hint.isEmpty(), "level ${from + 1}: $hint")
        }
    }
}
