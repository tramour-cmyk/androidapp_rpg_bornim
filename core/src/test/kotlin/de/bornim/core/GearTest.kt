package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class GearTest {
    private val state = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)

    @Test
    fun affixCountMatchesRarity() {
        val dice = Dice(Random(1))
        for (r in Rarity.entries) repeat(50) {
            val g = Loot.generate(state, dice, 6, r)
            assertEquals(r.affixes, g.rolls.size, "${g.base} $r")
            assertTrue(g.name(Lang.DE).isNotBlank() && g.name(Lang.EN).isNotBlank())
        }
    }

    @Test
    fun germanNamesUseGenderEndings() {
        val g = Gear(1, "longsword", Rarity.RARE, 3, 1, listOf(Roll(Affix.FIRE, 2), Roll(Affix.STR, 1)))
        assertEquals("Flammendes Langschwert der Bärenkraft", g.name(Lang.DE))
        assertEquals("Flaming Longsword of the Bear", g.name(Lang.EN))
        val h = Gear(2, "helmet", Rarity.VERY_RARE, 3, 0, listOf(Roll(Affix.AC, 1), Roll(Affix.HP, 5), Roll(Affix.WIS, 1)))
        assertEquals("Schützender Helm des Lebens", h.name(Lang.DE))
        val p = Gear(3, "gloves", Rarity.RARE, 3, 0, listOf(Roll(Affix.DEX, 1), Roll(Affix.CRIT, 1)))
        assertEquals("Flinke Lederhandschuhe des Henkers", p.name(Lang.DE))
        val f = Gear(4, "robe", Rarity.RARE, 3, 0, listOf(Roll(Affix.SPELL, 1), Roll(Affix.SP, 1)))
        assertEquals("Arkane Robe der Sterne", f.name(Lang.DE))
    }

    @Test
    fun rarerIsLessLikely() {
        val dice = Dice(Random(7))
        val counts = Rarity.entries.associateWith { 0 }.toMutableMap()
        repeat(20_000) { counts.merge(Loot.rollRarity(dice, 10), 1, Int::plus) }
        println("rarity distribution: $counts")
        val list = Rarity.entries.map { counts.getValue(it) }
        for (i in 1 until list.size) assertTrue(list[i] < list[i - 1], "$counts")
        assertTrue(counts.getValue(Rarity.DIVINE) > 0)
        // Divine needs item level 5, epic 3.
        repeat(5_000) { assertTrue(Loot.rollRarity(dice, 2) < Rarity.EPIC) }
    }

    @Test
    fun magicFindAndFloorsWork() {
        val dice = Dice(Random(3))
        repeat(500) { assertTrue(Loot.rollRarity(dice, 5, atLeast = Rarity.RARE) >= Rarity.RARE) }
        val plain = (1..20_000).count { Loot.rollRarity(dice, 10) >= Rarity.RARE }
        val lucky = (1..20_000).count { Loot.rollRarity(dice, 10, magicFind = 100) >= Rarity.RARE }
        assertTrue(lucky > plain * 1.25, "$plain vs $lucky")
    }

    @Test
    fun classBiasMostlyFits() {
        val dice = Dice(Random(5))
        for (cls in CharClass.entries) {
            val s = GameState.newGame("X", Race.HUMAN, cls)
            val items = List(300) { Loot.generate(s, dice, 8, Rarity.RARE, cls) }
            assertTrue(items.all { Loot.suits(cls, it.def) }, "$cls")
            assertTrue(items.all { s.hero.canWear(it) }, "$cls")
        }
    }

    @Test
    fun gearChangesStats() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
        val str = s.hero.score(Ability.STR)
        val ac = s.hero.armorClass
        val hp = s.hero.maxHp
        val ring = s.addGear(Gear(0, "ring", Rarity.EPIC, 5, 0, listOf(Roll(Affix.STR, 2), Roll(Affix.AC, 1), Roll(Affix.HP, 10), Roll(Affix.CRIT, 1))))
        assertTrue(s.equipFromBag(ring))
        // Chapter 1 allows +1 from gear; from chapter 2 on the full +2 counts.
        assertEquals(str + 1, s.hero.score(Ability.STR))
        assertTrue(s.hero.gearCapped(Ability.STR))
        s.hero.chapter = 2
        assertEquals(str + 2, s.hero.score(Ability.STR))
        assertEquals(ac + 1, s.hero.armorClass)
        assertEquals(hp + 10, s.hero.maxHp)
        assertEquals(19, s.hero.critFrom)
    }

    @Test
    fun dualWieldAndTwoHanded() {
        val s = GameState.newGame("X", Race.HUMAN, CharClass.ROGUE)
        val dagger = s.addGear(Gear(0, "dagger", Rarity.COMMON, 1))
        assertTrue(s.equipFromBag(dagger, offHand = true))
        assertEquals("dagger", s.hero.offHandWeapon?.base)
        val bow = s.addGear(Gear(0, "shortbow", Rarity.COMMON, 1))
        assertTrue(s.equipFromBag(bow))
        assertEquals(null, s.hero.item(GearSlot.OFF_HAND))
        assertTrue(s.bag.any { it.base == "dagger" } && s.bag.any { it.base == "shortsword" })
    }

    @Test
    fun oldSavesAreConverted() {
        // Build a version 1 save by hand: old equipment ids and gear ids in the inventory.
        val json = kotlinx.serialization.json.Json.parseToJsonElement(GameState.newGame("Alt", Race.DWARF, CharClass.CLERIC).toJson()).let { el ->
            val o = el as kotlinx.serialization.json.JsonObject
            val hero = (o["hero"] as kotlinx.serialization.json.JsonObject).toMutableMap()
            hero["gear"] = kotlinx.serialization.json.JsonObject(emptyMap())
            hero["equipment"] = kotlinx.serialization.json.buildJsonObject {
                put("WEAPON", kotlinx.serialization.json.JsonPrimitive("mace_of_dawn"))
                put("ARMOR", kotlinx.serialization.json.JsonPrimitive("chain_shirt"))
                put("SHIELD", kotlinx.serialization.json.JsonPrimitive("shield"))
                put("TRINKET", kotlinx.serialization.json.JsonPrimitive("ring_protection"))
            }
            val root = o.toMutableMap()
            root["hero"] = kotlinx.serialization.json.JsonObject(hero)
            root["inventory"] = kotlinx.serialization.json.buildJsonObject {
                put("potion", kotlinx.serialization.json.JsonPrimitive(3))
                put("studded_leather", kotlinx.serialization.json.JsonPrimitive(1))
            }
            root.remove("bag"); root["version"] = kotlinx.serialization.json.JsonPrimitive(1)
            kotlinx.serialization.json.JsonObject(root).toString()
        }
        val s = GameState.fromJson(json)
        assertEquals("mace_of_dawn", s.hero.weapon?.unique)
        assertEquals("chain_shirt", s.hero.item(GearSlot.CHEST)?.base)
        assertEquals("round_shield", s.hero.item(GearSlot.OFF_HAND)?.base)
        assertEquals("ring_protection", s.hero.item(GearSlot.RING)?.unique)
        assertEquals(3, s.count("potion"))
        assertEquals(listOf("studded_leather"), s.bag.map { it.base })
        assertEquals(GameState.SAVE_VERSION, s.version)
    }

    @Test
    fun versatileWeaponsHitHarderInBothHands() {
        val s = GameState.newGame("V", Race.HUMAN, CharClass.FIGHTER)
        val hero = s.hero
        hero.equip(Gear(900, "longsword", Rarity.COMMON, 1))
        hero.equip(Gear(901, "shield", Rarity.COMMON, 1))
        assertEquals(8, hero.weaponDamage.sides, "with a shield: one hand")
        assertTrue(!hero.bothHands())
        hero.unequip(GearSlot.OFF_HAND)
        assertTrue(hero.bothHands())
        assertEquals(10, hero.weaponDamage.sides, "other hand empty: both hands")
        // a weapon that is not versatile stays as it is
        hero.equip(Gear(902, "mace", Rarity.COMMON, 1))
        assertEquals(6, hero.weaponDamage.sides)
        assertTrue(!hero.bothHands())
        // the list line names both dice
        assertTrue(Gear(903, "quarterstaff", Rarity.COMMON, 1).listLine(Lang.DE).contains("1W6/1W8"))
    }

    @Test
    fun comparisonShowsGainsLossesAndLimits() {
        val s = GameState.newGame("C", Race.HUMAN, CharClass.FIGHTER)
        val hero = s.hero
        hero.equip(Gear(910, "longsword", Rarity.COMMON, 1))
        hero.equip(Gear(911, "shield", Rarity.COMMON, 1))
        // a greatsword: more damage, but the shield comes off
        val c = GearCompare.of(hero, Gear(912, "greatsword", Rarity.COMMON, 1))
        assertTrue(c.replaced.any { it.base == "shield" }, "the shield comes off")
        assertEquals(0, c.verdict, "mixed: damage up, AC down")
        assertTrue(c.rows.any { it.label.de == "Rüstungsklasse" && it.better == false })
        assertTrue(c.rows.any { it.label.de == "Schaden" && it.better == true })
        // AC beyond the chapter's limit is named, not hidden
        hero.equip(Gear(913, "helmet", Rarity.RARE, 1, 0, listOf(Roll(Affix.AC, 1))))
        val more = GearCompare.of(hero, Gear(914, "gloves", Rarity.RARE, 1, 0, listOf(Roll(Affix.AC, 1))))
        assertTrue(more.rows.any { it.note != null }, "a swallowed bonus is named")
        // the hero is left as it was
        assertEquals("longsword", hero.weapon?.base)
    }
}
