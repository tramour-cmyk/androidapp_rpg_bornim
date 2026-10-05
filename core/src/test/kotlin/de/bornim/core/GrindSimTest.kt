package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test

class GrindSimTest {
    @Test
    fun grindAtHigherLevels() {
        // Slow Monte-Carlo run; only on demand: SIM=1 ./gradlew -p core test
        if (System.getenv("SIM") == null) return
        val rng = Random(99)
        val sb = StringBuilder()
        for (cls in CharClass.entries) for (lvl in listOf(5, 10, 15)) {
            for (elite in listOf(false, true)) {
                var wins = 0
                val runs = 300
                repeat(runs) {
                    val s = GameState.newGame("X", Race.HUMAN, cls)
                    s.hero.gainXp(Rules.xpForLevel[lvl])
                    // spend points on the primary ability, then CON
                    for (a in listOf(cls.primary, Ability.CON, Ability.DEX, Ability.STR, Ability.WIS)) while (s.hero.raise(a)) {}
                    val dice = Dice(rng)
                    // typical gear: one uncommon-to-rare piece per slot of the hero's level
                    for (slot in GearSlot.entries) {
                        if (slot == GearSlot.OFF_HAND && s.hero.weapon?.def?.twoHanded == true) continue
                        val r = if (dice.chance(0.5)) Rarity.UNCOMMON else Rarity.RARE
                        val g = Loot.generate(s, dice, lvl, r, cls, slot)
                        if (s.hero.canWear(g)) s.equipFromBag(s.addGear(g))
                    }
                    s.add("greater_potion", 2)
                    s.hero.restoreFully()
                    val b = Battle(s, Monsters[listOf("goblin", "skeleton", "giant_spider", "zombie").random(rng)], Lang.EN, dice, lvl - 1, elite, 3)
                    b.start()
                    var turns = 0
                    while (b.outcome == Outcome.ONGOING && turns++ < 60) {
                        val h = s.hero
                        val action = when {
                            h.hp < h.maxHp * 0.3 && s.count("greater_potion") > 0 -> Action.UseItem("greater_potion")
                            cls == CharClass.WIZARD && b.blocked(Skill.MAGIC_MISSILE) == null && h.sp > 6 -> Action.UseSkill(Skill.MAGIC_MISSILE)
                            cls == CharClass.WIZARD -> Action.UseSkill(Skill.FIRE_BOLT)
                            cls == CharClass.CLERIC && h.hp < h.maxHp / 2 && b.blocked(Skill.CURE_WOUNDS) == null -> Action.UseSkill(Skill.CURE_WOUNDS)
                            else -> Action.Attack
                        }
                        b.act(action)
                    }
                    if (b.outcome == Outcome.WON) wins++
                }
                sb.append("${cls.name.padEnd(8)} L$lvl ${if (elite) "elite " else "normal"} ${wins * 100 / runs}%\n")
            }
        }
        println(sb)
    }
}
