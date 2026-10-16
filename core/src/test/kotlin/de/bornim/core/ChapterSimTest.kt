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
        // SIM_MA=1: the wizard cast Mage Armor before this fight; it lasts 8 hours (26.1)
        if (cls == CharClass.WIZARD && System.getenv("SIM_MA") != null) s.mageArmorUntil = s.clock + Battle.MAGE_ARMOR_MINUTES
        return s
    }

    private class Result(var wins: Int = 0, var rounds: Int = 0, var lost: Int = 0)

    /** [fresh]: the hero starts with exactly two potions; otherwise with what is in the bag. */
    private fun fight(s: GameState, id: String, lvl: Int, area: Int, rng: Random, fresh: Boolean = true): Pair<Boolean, Int> {
        val def = Monsters[id]
        val monsterLevel = if (def.boss) minOf(maxOf(area, lvl), area + 2) else maxOf(area, lvl - 1 + (if (rng.nextDouble() < 0.3) 1 else 0))
        if (fresh) {
            s.inventory.clear()
            s.add("potion", 2)
        }
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

    /** One stretch of chapter 1 in story order (38e/38f). */
    private class Section(
        val name: String,
        val map: MapDef,
        /** Fights on the way: the purposeful player meets about half the roamers, the thorough one all. */
        val fightsQuick: Int,
        val fightsThorough: Int,
        /** Gold from chests and story on the way, and the bosses at its end. */
        val gold: Int,
        val gear: List<Rarity>,
        val bosses: List<String>,
        /** Bosses only the thorough player takes on, and the gold of notices done here. */
        val sideBosses: List<String> = emptyList(),
        val jobGold: Int = 0,
    )

    private val sections = listOf(
        // Aldric 50 at the start, forest_3 40; forest_1 uncommon
        Section("Wald", Story.forest, 4, 7, 50 + 40, listOf(Rarity.UNCOMMON), emptyList(), jobGold = 60 + 50),
        // deep_3 120; deep_1 rare, deep_4 very rare; Grimfang is a side quest
        Section("Tiefer Wald", Story.deepForest, 7, 13, 120, listOf(Rarity.RARE, Rarity.VERY_RARE), emptyList(), listOf("dire_wolf"), jobGold = 40 + 50),
        // cave_2 rare, cave_3 the class weapon; Aldric 200 after Grak
        Section("Höhle", Story.cave, 3, 6, 200, listOf(Rarity.RARE), listOf("bugbear", "hobgoblin_captain")),
    )

    private class Tally {
        var fightGold = 0; var otherGold = 0; var sales = 0; var potions = 0; var gear = 0; var lostGold = 0; var deaths = 0
        var level = 0; var left = 0; var bossTries = 0
    }

    /** Equips what is better than what is worn, by price; the rest stays in the bag for selling. */
    private fun equipBest(s: GameState) {
        for (g in s.bag.toList().sortedByDescending { it.price }) {
            if (!s.hero.canWear(g)) continue
            val worn = s.hero.gear[g.slot]
            if (worn == null || g.price > worn.price) s.equipFromBag(g)
        }
    }

    private fun raiseAll(s: GameState, cls: CharClass) {
        for (a in listOf(cls.primary, Ability.CON)) while (s.hero.raise(a)) {}
    }

    /** A visit to Thessa: sell the bag, top potions up to three, then the best piece in reach. */
    private fun shop(s: GameState, t: Tally, buy: Boolean) {
        val h = s.hero
        for (g in s.bag.toList()) { val p = Perks.sellPrice(h, maxOf(1, g.price / 4)); s.bag.remove(g); s.gold += p; t.sales += p }
        if (!buy) return
        val potion = Perks.buyPrice(h, Items["potion"].price)
        while (s.count("potion") < 3 && s.gold >= potion) { s.gold -= potion; s.add("potion"); t.potions += potion }
        val best = Loot.shopGear(s).filter { h.canWear(it) && Perks.buyPrice(h, it.price) <= s.gold }
            .maxByOrNull { it.price - (h.gear[it.slot]?.price ?: 0) }
        if (best != null && best.price > (h.gear[best.slot]?.price ?: 0)) {
            val p = Perks.buyPrice(h, best.price)
            s.gold -= p; t.gear += p
            s.equipFromBag(s.addGear(best.copy(uid = 0)))
        }
    }

    /** Fights [id] like the player would; a defeat costs half the gold and wakes the hero at full health. */
    private fun play(s: GameState, cls: CharClass, id: String, area: Int, rng: Random, t: Tally): Boolean {
        val before = s.gold
        val (won, _) = fight(s, id, s.hero.level, area, rng, fresh = false)
        if (won) {
            t.fightGold += s.gold - before
            equipBest(s)
            raiseAll(s, cls)
        } else {
            val lost = s.gold / 2
            s.gold -= lost; t.lostGold += lost; t.deaths++
            s.hero.restoreFully()
        }
        // the campfire is free and always at hand: rest when below half
        if (s.hero.hp < s.hero.maxHp / 2) s.hero.restoreFully()
        return won
    }

    private fun run(cls: CharClass, seed: Int, thorough: Boolean, buy: Boolean): List<Tally> {
        val rng = Random(seed)
        val s = GameState.newGame("X", Race.HUMAN, cls)
        raiseAll(s, cls)
        s.inventory.clear()
        s.add("potion", 2)
        val out = mutableListOf<Tally>()
        for (sec in sections) {
            val t = Tally()
            shop(s, t, buy)
            val enc = sec.map.encounters!!
            val area = sec.map.areaLevel
            repeat(if (thorough) sec.fightsThorough else sec.fightsQuick) {
                val total = enc.table.sumOf { it.second }
                var r = rng.nextInt(total)
                val id = enc.table.first { r -= it.second; r < 0 }.first
                play(s, cls, id, area, rng, t)
            }
            s.gold += sec.gold; t.otherGold += sec.gold
            if (thorough) { s.gold += sec.jobGold; t.otherGold += sec.jobGold }
            sec.gear.forEach { s.addGear(Loot.generate(s, Dice(rng), s.hero.level, it, cls)) }
            if (sec.name == "Höhle") s.addGear(Uniques.make(Story.classWeapon(cls), 0, s.hero.level))
            equipBest(s)
            for (boss in sec.bosses + if (thorough) sec.sideBosses else emptyList()) {
                // before a boss: rest, and back to Thessa
                s.hero.restoreFully(); shop(s, t, buy)
                var tries = 0
                while (tries++ < 20) { t.bossTries++; s.hero.restoreFully(); if (play(s, cls, boss, area, rng, t)) break; shop(s, t, buy) }
            }
            t.level = s.hero.level; t.left = s.gold
            out += t
        }
        return out
    }

    /** 38e/38f: gold in, out and left per stretch of chapter 1, by class. Only on demand: SIM=1. */
    @Test
    fun chapterOneGold() {
        if (System.getenv("SIM") == null) return
        val runs = 200
        val sb = StringBuilder()
        for (thorough in listOf(false, true)) for (buy in listOf(false, true)) {
            sb.append("\n=== ${if (thorough) "gründlich" else "zielstrebig"}, ${if (buy) "mit Einkauf" else "ohne Einkauf"} ===  (Mittel aus $runs Läufen)\n")
            sb.append("Abschnitt".padEnd(12) + "Klasse".padEnd(9) + "Stufe".padStart(6) + "Kampf".padStart(7) + "Truhe+".padStart(8) +
                "Verkauf".padStart(8) + "Tränke".padStart(8) + "Ausr.".padStart(7) + "Tod-G".padStart(7) + "Tode".padStart(6) + "übrig".padStart(7) + "\n")
            val all = CharClass.entries.associateWith { cls -> (0 until runs).map { run(cls, 1000 * cls.ordinal + it, thorough, buy) } }
            for ((i, sec) in sections.withIndex()) for (cls in CharClass.entries) {
                val ts = all.getValue(cls).map { it[i] }
                fun avg(f: (Tally) -> Int) = ts.sumOf(f).toDouble() / runs
                sb.append(sec.name.padEnd(12) + cls.name.padEnd(9) + "%.1f".format(avg { it.level }).padStart(6) + "%.0f".format(avg { it.fightGold }).padStart(7) +
                    "%.0f".format(avg { it.otherGold }).padStart(8) + "%.0f".format(avg { it.sales }).padStart(8) + "%.0f".format(avg { it.potions }).padStart(8) +
                    "%.0f".format(avg { it.gear }).padStart(7) + "%.0f".format(avg { it.lostGold }).padStart(7) + "%.1f".format(avg { it.deaths }).padStart(6) +
                    "%.0f".format(avg { it.left }).padStart(7) + "\n")
            }
        }
        println(sb)
        java.io.File(System.getProperty("java.io.tmpdir"), "chapter_gold.txt").writeText(sb.toString())
    }
}
