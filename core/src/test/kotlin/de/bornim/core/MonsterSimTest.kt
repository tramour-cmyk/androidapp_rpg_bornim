package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test

/** Win rate and HP lost of fresh heroes against each monster of an area. Only on demand: SIM=1. */
class MonsterSimTest {
    @Test
    fun monsters() {
        if (System.getenv("SIM") == null) return
        val rng = Random(7)
        val sb = StringBuilder()
        val setups = listOf(
            Triple(1, 1, listOf("giant_rat", "wolf", "goblin", "goblin_archer", "boar", "kobold", "giant_centipede", "stirge")),
            Triple(2, 1, listOf("wolf", "goblin", "kobold")),
            Triple(2, 2, listOf("wolf", "goblin", "kobold")),
            Triple(3, 3, listOf("goblin", "goblin_archer", "goblin_shaman", "skeleton", "zombie", "giant_bat", "ghoul", "giant_spider", "ochre_jelly")),
            Triple(4, 2, listOf("dire_wolf")),
            Triple(5, 2, listOf("dire_wolf")),
            Triple(6, 2, listOf("dire_wolf")),
            Triple(4, 3, listOf("bugbear", "hobgoblin_captain")),
            Triple(5, 3, listOf("bugbear", "hobgoblin_captain")),
        )
        for ((lvl, area, ids) in setups) for (id in ids) {
            val line = StringBuilder("L$lvl ${id.padEnd(16)}")
            for (cls in CharClass.entries) {
                var wins = 0; var lost = 0
                val runs = 400
                repeat(runs) {
                    val s = GameState.newGame("X", Race.HUMAN, cls)
                    s.hero.gainXp(Rules.xpForLevel[lvl])
                    for (a in listOf(cls.primary, Ability.CON)) while (s.hero.raise(a)) {}
                    s.hero.restoreFully()
                    val dice = Dice(rng)
                    // like the game: bosses grow at most two levels above their area
                    val monsterLevel = if (Monsters[id].boss) minOf(lvl, area + 2) else lvl
                    s.add("potion", 2)
                    val b = Battle(s, Monsters[id], Lang.EN, dice, monsterLevel, false, area, look = MonsterLook(rng.nextInt()))
                    b.start()
                    var turns = 0
                    while (b.outcome == Outcome.ONGOING && turns++ < 60) {
                        val h = s.hero
                        val action = when {
                            h.hp < h.maxHp * 0.3 && s.count("potion") > 0 -> Action.UseItem("potion")
                            cls == CharClass.WIZARD && b.packLeft > 0 && b.blocked(Skill.FIREBALL) == null -> Action.UseSkill(Skill.FIREBALL)
                            cls == CharClass.WIZARD && b.blocked(Skill.MAGIC_MISSILE) == null && h.sp > 2 -> Action.UseSkill(Skill.MAGIC_MISSILE)
                            cls == CharClass.WIZARD -> Action.UseSkill(Skill.FIRE_BOLT)
                            cls == CharClass.CLERIC && h.hp < h.maxHp / 2 && b.blocked(Skill.CURE_WOUNDS) == null -> Action.UseSkill(Skill.CURE_WOUNDS)
                            else -> Action.Attack
                        }
                        b.act(action)
                    }
                    if (b.outcome == Outcome.WON) wins++
                    lost += (s.hero.maxHp - s.hero.hp) * 100 / s.hero.maxHp
                }
                line.append("  ${cls.name.take(4)} ${(wins * 100 / runs).toString().padStart(3)}% -${(lost / runs).toString().padStart(3)}%")
            }
            sb.append(line).append('\n')
        }
        println(sb)
    }
}

/** Win rates against elites of every trait and against shimmering monsters. Only on demand: SIM=1. */
class EliteSimTest {
    @Test
    fun elites() {
        if (System.getenv("SIM") == null) return
        val rng = Random(11)
        val sb = StringBuilder()
        // label, elite trait, shiny
        val variants = listOf(Triple("normal", null as EliteTrait?, false)) +
            EliteTrait.entries.map { Triple(it.name.lowercase(), it, false) } +
            listOf(Triple("shiny", null, true))
        for ((lvl, ids) in listOf(1 to listOf("wolf", "goblin", "kobold"), 2 to listOf("wolf", "goblin", "kobold"), 3 to listOf("skeleton", "giant_bat", "goblin_shaman"))) {
            for ((label, trait, shiny) in variants) {
                val line = StringBuilder("L$lvl ${label.padEnd(9)}")
                for (cls in CharClass.entries) {
                    var wins = 0
                    val runs = 300
                    repeat(runs) {
                        val s = GameState.newGame("X", Race.HUMAN, cls)
                        s.hero.gainXp(Rules.xpForLevel[lvl])
                        for (a in listOf(cls.primary, Ability.CON)) while (s.hero.raise(a)) {}
                        s.add("potion", 2)
                        s.hero.restoreFully()
                        val b = Battle(s, Monsters[ids[it % ids.size]], Lang.DE, Dice(rng), lvl, trait != null, lvl, trait, shiny)
                        b.start()
                        var turns = 0
                        while (b.outcome == Outcome.ONGOING && turns++ < 60) {
                            val h = s.hero
                            b.act(when {
                                h.hp < h.maxHp * 0.3 && s.count("potion") > 0 -> Action.UseItem("potion")
                                cls == CharClass.WIZARD && b.blocked(Skill.MAGIC_MISSILE) == null && h.sp > 2 -> Action.UseSkill(Skill.MAGIC_MISSILE)
                                cls == CharClass.WIZARD -> Action.UseSkill(Skill.FIRE_BOLT)
                                cls == CharClass.CLERIC && h.hp < h.maxHp / 2 && b.blocked(Skill.CURE_WOUNDS) == null -> Action.UseSkill(Skill.CURE_WOUNDS)
                                else -> Action.Attack
                            })
                        }
                        if (b.outcome == Outcome.WON) wins++
                    }
                    line.append("  ${cls.name.take(4)} ${(wins * 100 / runs).toString().padStart(3)}%")
                }
                sb.append(line).append('\n')
            }
        }
        println(sb)
    }
}
