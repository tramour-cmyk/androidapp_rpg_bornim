package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * The battle screen lets a killing blow run straight on into the fall without words: so the step before a fall must
 * be the blow itself (or the lead-in it resolves), never a plain line of words in between.
 */
class KillFlowTest {
    @Test
    fun theFallFollowsTheBlow() {
        val odd = sortedMapOf<String, String>()
        val foes = Monsters.all.map { it.id } + listOf("bugbear", "hobgoblin_captain")
        for (id in foes.distinct()) for (cls in CharClass.entries) for (seed in 0 until 20) {
            val st = GameState.newGame("T", Race.entries[seed % Race.entries.size], cls)
            st.hero.gainXp(Rules.xpForLevel[if (seed % 2 == 0) 2 else 5]); st.hero.restoreFully()
            listOf("potion", "remedy", "alchemist_fire", "holy_water").forEach { st.add(it, 3) }
            val rnd = Random(seed * 37 + id.hashCode())
            val b = Battle(st, Monsters[id], Lang.DE, Dice(rnd), 3, false, 3)
            val steps = b.start().toMutableList()
            var turns = 0
            while (b.outcome == Outcome.ONGOING && turns++ < 30) {
                val skills = cls.skills().filter { it.level <= st.hero.level && b.blocked(it) == null }
                val action = when (rnd.nextInt(6)) {
                    0 -> Action.Defend
                    1, 2 -> skills.randomOrNull(rnd)?.let { Action.UseSkill(it) } ?: Action.Attack
                    3 -> Action.UseItem(listOf("potion", "remedy", "alchemist_fire", "holy_water").random(rnd))
                    else -> Action.Attack
                }
                steps += runCatching { b.act(action) }.getOrDefault(emptyList())
            }
            val f = steps.indexOfFirst { it.anim == Anim.ENEMY_FAINT || it.anim == Anim.HERO_FAINT }
            if (f <= 0) continue
            val before = steps[f - 1]
            val ok = before.lead || before.anim != Anim.NONE || before.fx != null
            if (!ok) odd.putIfAbsent("$id $cls", before.text + " | " + steps[f].text)
        }
        assertTrue(odd.isEmpty(), "words between the blow and the fall:\n" + odd.entries.joinToString("\n") { "${it.key}: ${it.value}" })
    }
}
