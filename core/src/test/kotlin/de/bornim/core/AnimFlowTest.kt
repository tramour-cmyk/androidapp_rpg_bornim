package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test

/**
 * The battle screen holds a wind-up (a blow, a spell, a throw, the foe's attack) until the message that resolves it,
 * and holds it through plain words in between. This plays many fights against every foe with every class and every
 * action and lists each opener whose resolution is not what the screen waits for.
 */
class AnimFlowTest {
    private val openers = setOf(Anim.ENEMY_ACT, Anim.PACK_ACT, Anim.HERO_ACT, Anim.SPELL, Anim.THROW)

    private fun resolves(open: Step, s: Step): Boolean = when (open.anim) {
        Anim.ENEMY_ACT -> (s.anim == Anim.HERO_HIT || s.anim == Anim.HERO_FAINT || s.anim == Anim.MISS || s.anim == Anim.NONE) && s.fx?.onHero == true
        Anim.PACK_ACT -> (s.anim == Anim.HERO_HIT || s.anim == Anim.HERO_FAINT || s.anim == Anim.MISS) && s.fx?.onHero == true
        Anim.HERO_ACT -> (s.anim == Anim.ENEMY_HIT || s.anim == Anim.ENEMY_FAINT || s.anim == Anim.MISS) && s.fx?.onHero == false
        else -> s.fx != null || s.anim != Anim.NONE
    }

    /** Signatures of flows the screen does not expect, with an example each. */
    fun survey(): Map<String, String> {
        val odd = sortedMapOf<String, String>()
        val foes = Monsters.all.map { it.id } + listOf("bugbear", "hobgoblin_captain")
        for (id in foes.distinct()) for (cls in CharClass.entries) for (seed in 0 until 12) {
            val st = GameState.newGame("T", Race.entries[seed % Race.entries.size], cls)
            st.hero.gainXp(Rules.xpForLevel[if (seed % 2 == 0) 2 else 5]); st.hero.restoreFully()
            listOf("potion", "remedy", "alchemist_fire", "holy_water").forEach { st.add(it, 3) }
            val rnd = Random(seed * 31 + id.hashCode())
            val b = Battle(st, Monsters[id], Lang.DE, Dice(rnd), 3, seed % 5 == 0, 3, if (seed % 5 == 0) EliteTrait.entries[seed % EliteTrait.entries.size] else null)
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
            var i = 0
            while (i < steps.size) {
                val open = steps[i]
                if (open.anim !in openers) { i++; continue }
                var j = i + 1
                val between = mutableListOf<Step>()
                while (j < steps.size && !resolves(open, steps[j]) && steps[j].anim == Anim.NONE && steps[j].fx == null) { between += steps[j]; j++ }
                val end = steps.getOrNull(j)
                val ok = end != null && resolves(open, end)
                if (!ok) {
                    val sig = "${open.anim} -> " + (between.map { "NONE" } + listOf(end?.let { "${it.anim}/${it.fx?.kind}/${it.fx?.onHero}" } ?: "END")).joinToString(" ")
                    odd.putIfAbsent(sig, "$id $cls: " + (listOf(open) + between + listOfNotNull(end)).joinToString(" | ") { it.text })
                }
                i++
            }
        }
        return odd
    }

    @Test
    fun everyWindUpIsResolved() {
        val odd = survey()
        kotlin.test.assertTrue(odd.isEmpty(), "wind-ups the screen would hold in vain:\n" + odd.entries.joinToString("\n") { (k, v) -> "$k\n   e.g. $v" })
    }
}
