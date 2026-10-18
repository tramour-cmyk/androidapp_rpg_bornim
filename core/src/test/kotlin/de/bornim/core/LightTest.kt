package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 84.1, 84.5: the torch in the off hand and the spark of light. */
class LightTest {
    private fun game(): Game {
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(4)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        return g
    }

    @Test
    fun theSparkLastsUntilTheNextRestAndCanBePutOut() {
        val g = game()
        g.state.add(Light.SPARK_ITEM, 2)
        g.useItemOutside(Light.SPARK_ITEM)
        assertTrue(g.state.spark)
        g.useItemOutside(Light.SPARK_ITEM)
        assertEquals(1, g.state.count(Light.SPARK_ITEM), "a second one does not stack")
        g.state.place = Place("forest", 10, 9, Facing.RIGHT)
        g.interact()
        g.rest(Resting.Kind.SHORT, Resting.Spot.FIRE)
        assertFalse(g.state.spark, "a short rest ends it")
        g.useItemOutside(Light.SPARK_ITEM)
        assertTrue(g.state.spark)
        g.putOutSpark()
        assertFalse(g.state.spark, "out is out")
        assertEquals(0, g.state.count(Light.SPARK_ITEM))
        val back = GameState.fromJson(g.state.apply { spark = true }.toJson())
        assertTrue(back.spark, "kept in the save")
    }

    @Test
    fun theSparkIsSoldByThessaLikeTheStaminaDraughtAndNotInBattle() {
        val def = Items[Light.SPARK_ITEM]
        assertEquals(ItemKind.TONIC, def.kind)
        assertEquals(25, def.price)
        assertTrue(Light.SPARK_ITEM in Story.shopStock)
    }

    @Test
    fun torchSeesFurtherThanTheSparkAndOnlyInTheDark() {
        val g = game()
        val s = g.state
        assertEquals(Light.DARK_SIGHT, Light.sight(s, true))
        s.spark = true
        assertEquals(Light.SPARK_SIGHT, Light.sight(s, true))
        assertEquals(Light.DAY_SIGHT, Light.sight(s, false), "by day the spark changes nothing")
        assertEquals(Light.SPARK_NOTICE, Light.noticeExtra(s, true))
        assertEquals(0, Light.noticeExtra(s, false))
        s.spark = false
        g.hero.equip(Loot.torch(1))
        assertTrue(Light.torch(s))
        assertEquals(Light.TORCH_SIGHT, Light.sight(s, true))
        assertTrue(Light.TORCH_SIGHT > Light.SPARK_SIGHT, "the spark stays weaker than the torch")
        assertEquals(0, Light.noticeExtra(s, true), "the torch does not give the hero away (84.5)")
    }

    @Test
    fun theTorchTakesTheShieldsPlaceAndIsAlwaysInTheShopButNeverDropped() {
        val g = game()
        g.hero.equip(Loot.roll(2, GearBases["shield"], 1, Rarity.COMMON, Dice(Random(1))))
        assertEquals(BaseKind.SHIELD, g.hero.item(GearSlot.OFF_HAND)?.def?.kind)
        g.hero.equip(Loot.torch(3))
        assertEquals(BaseKind.LIGHT, g.hero.item(GearSlot.OFF_HAND)?.def?.kind)
        assertTrue(Loot.shopGear(g.state).any { it.base == "torch" && it.rolls.isEmpty() })
        val dice = Dice(Random(7))
        repeat(400) { assertFalse(Loot.generate(g.state, dice, 3, Rarity.RARE).base == "torch") }
        assertTrue(GearBases.affixesFor(GearBases["torch"]).isEmpty())
        assertNull(g.hero.offHandWeapon)
    }

    @Test
    fun theCarriedLightReachesAboutAsFarAsTheHeroSees() {
        // 176 (Chef 18.10.: "leuchtet nicht richtig aus"): light at a distance in tiles, as MapLight lays it on the ground
        fun at(c: de.bornim.core.art.MapLight.Carried, tiles: Double): Double {
            val s = de.bornim.core.art.MapLight.carriedSource(c, 0.0, 0.0)!!
            val d = tiles * de.bornim.core.art.WorldArt.T
            return s.power * kotlin.math.exp(-(d / s.reach) * (d / s.reach) * 2.0)
        }
        val torch = de.bornim.core.art.MapLight.Carried.TORCH; val spark = de.bornim.core.art.MapLight.Carried.SPARK
        assertTrue(at(torch, 5.0) >= 0.3, "the torch still lights the ground 5 tiles off: ${at(torch, 5.0)}")
        assertTrue(at(torch, Light.TORCH_SIGHT) >= 0.12, "and a little at the edge of the sight")
        assertTrue(at(spark, Light.SPARK_SIGHT - 1) >= 0.2, "the spark lights most of what the hero sees with it")
        for (d in listOf(1.0, 3.0, 5.0)) assertTrue(at(spark, d) < at(torch, d), "the spark stays weaker than the torch")
        assertNull(de.bornim.core.art.MapLight.carriedSource(de.bornim.core.art.MapLight.Carried.NONE, 0.0, 0.0))
    }

    @Test
    fun lightingAndSnuffingTheTorchIsSaidOnlyInTheDark() {
        // 84.1T: [84.1.an], [84.1.aus]
        val g = game()
        val t = Loot.torch(991)
        g.state.bag += t
        assertTrue(g.state.equipFromBag(t))
        assertEquals(Light.torchLit, Light.torchChange(g.state, true, false))
        assertNull(Light.torchChange(g.state, false, false), "by day nothing to say")
        assertNull(Light.torchChange(g.state, true, true), "still lit")
        g.state.unequipToBag(GearSlot.OFF_HAND)
        assertEquals(Light.torchSnuffed, Light.torchChange(g.state, true, true))
    }

    /** 176a (Chef 18.10., Build 25): before the cave the rock of its mouth threw a sharp wedge of shadow from the torch and the spark. */
    @Test
    fun theRockOfTheCaveMouthCastsNoShadowFromTheHerosLight() {
        val map = World["forest"]
        val t = de.bornim.core.art.WorldArt.T.toDouble()
        for (c in listOf(de.bornim.core.art.MapLight.Carried.TORCH, de.bornim.core.art.MapLight.Carried.SPARK)) for (hx in 4..15) for (hy in 1..3) {
            val src = de.bornim.core.art.MapLight.carriedSource(c, hx * t + t / 2, hy * t + t / 2)!!
            val dark = mutableListOf<String>()
            for (ty in 0..4) for (tx in hx - 5..hx + 5) for ((fx, fy) in listOf(0.25 to 0.25, 0.75 to 0.25, 0.25 to 0.75, 0.75 to 0.75)) {
                if (!de.bornim.core.art.MapLight.reaches(map, src, (tx + fx) * t, (ty + fy) * t)) dark += "$tx,$ty"
            }
            assertTrue(dark.isEmpty(), "$c at $hx,$hy: in shadow ${dark.distinct()}")
        }
    }

    /** 180 (Chef 18.10., Build 25): with a torch bought, the store still sells another. */
    @Test
    fun theStoreSellsASecondTorch() {
        val g = game()
        g.state.gold = 500
        repeat(2) {
            val torch = g.shopGear().first { it.base == "torch" }
            g.buyGear(torch)
        }
        assertEquals(2, g.state.bag.count { it.base == "torch" } + (if (Light.torch(g.state)) 1 else 0))
        assertTrue(g.shopGear().any { it.base == "torch" }, "still on offer")
    }

    /** 180 (Chef 18.10., Build 27): a save from Build 25 marked the bought torch as sold; it is on offer anyway. */
    @Test
    fun anOldSaleDoesNotHideTheTorch() {
        val g = game()
        val torch = g.shopGear().first { it.base == "torch" }
        g.state.shopSold += "${g.state.battlesWon / 8}:${torch.uid}"
        assertTrue(g.shopGear().any { it.base == "torch" }, "torch hidden by an old sale")
    }
}
