package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test

/**
 * Chapter 1 as a hero of each class experiences it: heroes built like a player would (class
 * suggestion, points into the main ability, the class's story weapon and a few potions), monster
 * levels as in the game. Prints win rate, rounds and HP lost. Only on demand: SIM=1.
 */
class ChapterSimTest {
    private fun hero(cls: CharClass, lvl: Int): GameState {
        val s = GameState.newGame("X", Race.HUMAN, cls)
        val h = s.hero
        h.gainXp(Rules.xpForLevel[lvl], Story.levelCap(s))
        for (a in listOf(cls.primary, Ability.CON)) while (h.raise(a)) {}
        if (lvl >= 3) {
            s.equipFromBag(s.addGear(Uniques.make(Story.classWeapon(cls), 0, lvl)))
            s.equipFromBag(s.addGear(Uniques.make("cloak_protection", 0, lvl)))
        }
        if (lvl >= 5) {
            // Generous chapter 1 gear: more than the caps allow, so the caps decide.
            val prim = when (cls.primary) { Ability.STR -> Affix.STR; Ability.DEX -> Affix.DEX; Ability.INT -> Affix.INT; else -> Affix.WIS }
            val off = if (cls.caster) Affix.SPELL else Affix.ATTACK
            s.equipFromBag(s.addGear(Gear(0, "amulet", Rarity.RARE, lvl, 0, listOf(Roll(prim, 1), Roll(off, 1), Roll(Affix.HP, 6)))))
            s.equipFromBag(s.addGear(Gear(0, "ring", Rarity.UNCOMMON, lvl, 0, listOf(Roll(Affix.DAMAGE, 1)))))
        }
        h.restoreFully()
        return s
    }

    private class Result(var wins: Int = 0, var rounds: Int = 0, var lost: Int = 0)

    private fun fight(s: GameState, id: String, lvl: Int, area: Int, rng: Random): Pair<Boolean, Int> {
        val def = Monsters[id]
        val monsterLevel = if (def.boss) minOf(maxOf(area, lvl), area + 2) else maxOf(area, lvl - 1 + (if (rng.nextDouble() < 0.3) 1 else 0))
        s.inventory.clear()
        s.add("potion", 2)
        val b = Battle(s, def, Lang.DE, Dice(rng), monsterLevel, false, area, look = MonsterLook(rng.nextInt()))
        b.start()
        var turns = 0
        while (b.outcome == Outcome.ONGOING && turns < 60) {
            turns++
            val h = s.hero
            val action = when {
                h.hp < h.maxHp * 0.3 && s.count("potion") > 0 -> Action.UseItem("potion")
                h.cls == CharClass.WIZARD -> when {
                    h.level >= 3 && b.blocked(Skill.MAGE_ARMOR) == null && !b.mageArmor -> Action.UseSkill(Skill.MAGE_ARMOR)
                    b.blocked(Skill.FIREBALL) == null && (b.packLeft > 0 || b.enemyHp > 12) -> Action.UseSkill(Skill.FIREBALL)
                    b.blocked(Skill.SCORCHING_RAY) == null && h.sp >= 8 -> Action.UseSkill(Skill.SCORCHING_RAY)
                    b.blocked(Skill.MAGIC_MISSILE) == null && h.sp >= 4 -> Action.UseSkill(Skill.MAGIC_MISSILE)
                    else -> Action.UseSkill(Skill.FIRE_BOLT)
                }
                h.cls == CharClass.CLERIC && h.hp < h.maxHp / 2 && b.blocked(Skill.CURE_WOUNDS) == null -> Action.UseSkill(Skill.CURE_WOUNDS)
                h.cls == CharClass.CLERIC && b.blocked(Skill.SPIRIT_GUARDIANS) == null && (def.boss || b.enemyHp > 15) -> Action.UseSkill(Skill.SPIRIT_GUARDIANS)
                h.cls == CharClass.CLERIC && b.blocked(Skill.SPIRITUAL_WEAPON) == null -> Action.UseSkill(Skill.SPIRITUAL_WEAPON)
                h.cls == CharClass.CLERIC && b.blocked(Skill.BLESS) == null && def.boss -> Action.UseSkill(Skill.BLESS)
                h.cls == CharClass.FIGHTER && b.blocked(Skill.SECOND_WIND) == null && h.hp < h.maxHp / 2 -> Action.UseSkill(Skill.SECOND_WIND)
                h.cls == CharClass.FIGHTER && b.blocked(Skill.ACTION_SURGE) == null && (def.boss || b.enemyHp > 15) -> Action.UseSkill(Skill.ACTION_SURGE)
                h.cls == CharClass.ROGUE && b.blocked(Skill.FEINT) == null -> Action.UseSkill(Skill.FEINT)
                else -> Action.Attack
            }
            b.act(action)
        }
        return (b.outcome == Outcome.WON || b.outcome == Outcome.ENEMY_FLED) to turns
    }

    @Test
    fun chapterOne() {
        if (System.getenv("SIM") == null) return
        val sb = StringBuilder()
        val setups = listOf(
            1 to listOf("wolf" to 1, "goblin" to 1, "kobold" to 1, "boar" to 1),
            3 to listOf("wolf" to 1, "goblin_shaman" to 2, "skeleton" to 2, "giant_spider" to 3, "bugbear" to 3),
            4 to listOf("wolf" to 2, "ghoul" to 3, "giant_spider" to 3, "bugbear" to 3, "hobgoblin_captain" to 3, "dire_wolf" to 2),
            5 to listOf("wolf" to 2, "kobold" to 2, "ghoul" to 3, "giant_spider" to 3, "bugbear" to 3, "hobgoblin_captain" to 3, "dire_wolf" to 2),
            6 to listOf("wolf" to 2, "kobold" to 2, "goblin" to 2, "ghoul" to 3, "giant_spider" to 3, "ochre_jelly" to 3, "bugbear" to 3, "hobgoblin_captain" to 3, "dire_wolf" to 2),
        )
        val runs = 400
        for ((lvl, foes) in setups) {
            sb.append("\n=== Stufe $lvl ===  (Sieg% / Runden / TP-Verlust)\n")
            sb.append("".padEnd(18))
            CharClass.entries.forEach { sb.append(it.name.padStart(22)) }
            sb.append("\n")
            for ((id, area) in foes) {
                sb.append("$id@$area".padEnd(18))
                for (cls in CharClass.entries) {
                    val r = Result()
                    val rng = Random(7 + cls.ordinal)
                    repeat(runs) {
                        val s = hero(cls, lvl)
                        val (won, turns) = fight(s, id, lvl, area, rng)
                        if (won) { r.wins++; r.rounds += turns }
                        r.lost += (s.hero.maxHp - s.hero.hp) * 100 / s.hero.maxHp
                    }
                    sb.append("${r.wins * 100 / runs}% ${"%.1f".format(r.rounds.toDouble() / maxOf(1, r.wins))}R -${r.lost / runs}%".padStart(22))
                }
                sb.append("\n")
            }
        }
        println(sb)
        java.io.File(System.getProperty("java.io.tmpdir"), "chapter_sim.txt").writeText(sb.toString())
    }
}
