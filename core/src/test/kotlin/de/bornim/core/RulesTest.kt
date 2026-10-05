package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class RulesTest {
    @Test
    fun abilityModifiersFollowSrd() {
        assertEquals(-1, Rules.mod(8))
        assertEquals(-1, Rules.mod(9))
        assertEquals(0, Rules.mod(10))
        assertEquals(0, Rules.mod(11))
        assertEquals(2, Rules.mod(15))
        assertEquals(5, Rules.mod(20))
    }

    @Test
    fun proficiencyAndLevels() {
        assertEquals(2, Rules.proficiency(1))
        assertEquals(2, Rules.proficiency(4))
        assertEquals(3, Rules.proficiency(5))
        assertEquals(1, Rules.levelForXp(0))
        assertEquals(1, Rules.levelForXp(149))
        assertEquals(2, Rules.levelForXp(150))
        assertEquals(4, Rules.levelForXp(1400))
        assertEquals(Rules.MAX_LEVEL, Rules.levelForXp(1_000_000))
    }

    @Test
    fun heroCreationAppliesStandardArrayAndRace() {
        val h = Hero.create("Test", Race.DWARF, CharClass.FIGHTER)
        assertEquals(16, h.score(Ability.STR)) // 15 + 1
        assertEquals(16, h.score(Ability.CON)) // 14 + 2
        assertEquals(13, h.score(Ability.DEX))
        // Chain shirt 13 + min(DEX 1, 2) + shield 2 + defense style 1
        assertEquals(17, h.armorClass)
        assertEquals(10 + 3 + 4, h.maxHp)
        assertEquals(h.maxHp, h.hp)
        assertEquals("longsword", h.weapon?.base)
        assertEquals(3 + 2, h.attackBonus)
    }

    @Test
    fun everyCombinationCanBeCreated() {
        for (race in Race.entries) for (cls in CharClass.entries) {
            val s = GameState.newGame("X", race, cls)
            assertTrue(s.hero.maxHp > 0)
            assertTrue(s.hero.armorClass >= 10)
            assertTrue(s.hero.weapon != null, "$race $cls has no weapon")
            if (cls.caster) assertTrue(s.hero.maxSp > 0)
            for ((_, g) in s.hero.gear) assertTrue(s.hero.canWear(g), "$cls can't wear ${g.base}")
        }
    }

    @Test
    fun twoHandedWeaponRemovesShield() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        val gs = s.addGear(Gear(0, "greatsword", Rarity.COMMON, 1))
        assertTrue(s.equipFromBag(gs))
        assertNull(s.hero.item(GearSlot.OFF_HAND))
        assertEquals(setOf("shield", "longsword"), s.bag.map { it.base }.toSet())
    }

    @Test
    fun compareDoesNotChangeHero() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        val before = s.hero.gear.toMap()
        val c = s.hero.compare(Gear(1000, "chain_mail", Rarity.COMMON, 1))
        assertEquals(s.hero.armorClass, c.acBefore)
        assertTrue(c.acAfter > c.acBefore)
        val g = s.hero.compare(Gear(1001, "greatsword", Rarity.COMMON, 1))
        assertEquals(c.acBefore - 2, g.acAfter) // the shield comes off
        assertEquals(before, s.hero.gear)
    }

    @Test
    fun wizardCannotWearArmor() {
        val s = GameState.newGame("X", Race.ELF, CharClass.WIZARD)
        val mail = s.addGear(Gear(0, "chain_mail", Rarity.COMMON, 1))
        assertFalse(s.equipFromBag(mail))
        assertTrue(mail in s.bag)
    }

    @Test
    fun levelUpGrantsPointsAndHp() {
        val h = Hero.create("X", Race.HUMAN, CharClass.CLERIC)
        val hp = h.maxHp
        h.hp = 1
        h.sp = 0
        assertEquals(2, h.gainXp(450))
        assertEquals(h.maxHp, h.hp)
        assertEquals(h.maxSp, h.sp)
        assertEquals(3, h.level)
        assertEquals(2, h.unspentPoints)
        assertTrue(h.maxHp > hp)
        assertFalse(h.applyPoints(mapOf(Ability.WIS to 3)))
        val wis = h.base.getValue(Ability.WIS)
        val con = h.base.getValue(Ability.CON)
        assertTrue(h.applyPoints(mapOf(Ability.WIS to 1, Ability.CON to 1)))
        assertEquals(0, h.unspentPoints)
        assertEquals(wis + 1, h.base.getValue(Ability.WIS))
        assertEquals(con + 1, h.base.getValue(Ability.CON))
    }

    @Test
    fun saveRoundTrip() {
        val s = GameState.newGame("Mira", Race.HALFLING, CharClass.ROGUE)
        s.flags += Story.QUEST_STARTED
        s.add("alchemist_fire", 3)
        s.hero.gainXp(200)
        val copy = GameState.fromJson(s.toJson())
        assertEquals("Mira", copy.hero.name)
        assertEquals(Race.HALFLING, copy.hero.race)
        assertEquals(2, copy.hero.level)
        assertEquals(3, copy.count("alchemist_fire"))
        assertTrue(copy.has(Story.QUEST_STARTED))
        assertEquals(s.hero.gear, copy.hero.gear)
        assertEquals(s.place, copy.place)
    }

    @Test
    fun textsExistInBothLanguages() {
        val texts = Items.all.flatMap { listOf(it.name, it.desc) } +
            GearBases.all.map { it.name } + Affix.entries.map { it.title } + Rarity.entries.map { it.title } +
            Monsters.all.flatMap { listOf(it.name, it.attackName) } +
            Skill.entries.flatMap { listOf(it.title, it.desc) } +
            Race.entries.flatMap { listOf(it.title, it.desc, it.trait) } +
            CharClass.entries.flatMap { listOf(it.title, it.desc) } +
            World.maps.values.map { it.name }
        texts.forEach {
            assertTrue(it.de.isNotBlank() && it.en.isNotBlank(), "Missing translation: $it")
        }
    }

    @Test
    fun lootAndShopItemsExist() {
        Monsters.all.flatMap { it.loot }.forEach { assertTrue(Items.exists(it.item) || Uniques.exists(it.item), it.item) }
        Story.shopStock.forEach { assertTrue(Items.exists(it), it) }
        CharClass.entries.forEach { assertTrue(Uniques.exists(Story.classWeapon(it))) }
        CharClass.entries.flatMap { it.weapons ?: emptySet() }.forEach { assertTrue(GearBases.exists(it), it) }
        CharClass.entries.flatMap { it.startItems }.forEach { assertTrue(GearBases.exists(it) || Items.exists(it), it) }
        Legacy.gear.values.forEach { assertTrue(GearBases.exists(it.base)); it.unique?.let { u -> assertTrue(Uniques.exists(u)) } }
    }

    @Test
    fun battleIsDeterministicWithSeed() {
        fun run(seed: Int): List<String> {
            val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
            val b = Battle(s, Monsters["goblin"], Lang.EN, Dice(Random(seed)))
            val log = b.start().map { it.text }.toMutableList()
            while (b.outcome == Outcome.ONGOING) log += b.act(Action.Attack).map { it.text }
            return log
        }
        assertEquals(run(7), run(7))
    }

    @Test
    fun skillsWork() {
        for (cls in CharClass.entries) {
            val s = GameState.newGame("X", Race.HUMAN, cls)
            s.hero.gainXp(10_000)
            s.hero.restoreFully()
            for (skill in cls.skills().filter { !it.passive }) {
                val b = Battle(s, Monsters[if (skill == Skill.TURN_UNDEAD) "zombie" else "giant_spider"], Lang.DE, Dice(Random(1)))
                b.start()
                if (b.outcome != Outcome.ONGOING) continue
                assertNull(b.blocked(skill), "$skill blocked")
                val steps = b.act(Action.UseSkill(skill))
                assertTrue(steps.isNotEmpty())
                s.hero.restoreFully()
            }
        }
    }

    @Test
    fun undeadVulnerability() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.CLERIC)
        val b = Battle(s, Monsters["skeleton"], Lang.EN, Dice(Random(3)))
        b.start()
        assertNotNull(Monsters["skeleton"].vulnerable.firstOrNull { it == DamageType.BLUDGEONING })
        assertEquals(DamageType.BLUDGEONING, s.hero.weapon?.def?.damageType)
    }
}
