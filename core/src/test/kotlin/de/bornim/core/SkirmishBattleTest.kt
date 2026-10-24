package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/** 296.2: a fight of the game played in MARS: the real hero and foe, the potions from the bag, the end carried back. */
class SkirmishBattleTest {
    private fun battle(monster: String, opening: Opening = Opening.NORMAL, seed: Int = 1): Battle {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        return Battle(s, Monsters[monster], Lang.DE, Dice(Random(seed)), opening = opening)
    }

    @Test
    fun theRealHeroAndFoeWithItsPackAndThePotionsOfTheBag() {
        val b = battle("wolf")
        b.state.hero.hp = b.state.hero.maxHp - 3
        val sk = Skirmish.fromBattle(b, Dice(Random(2)))
        val me = sk.byId(Skirmish.HERO)
        assertTrue(me.hero === b.state.hero)
        assertEquals(b.state.hero.hp, me.hp)
        assertEquals(b.enemyMaxHp, sk.byId("foe").hp)
        assertEquals(minOf(b.packSize, Skirmish.PACK_MAX), sk.fighters.count { it.side == Side.FOES } - 1)
        assertEquals(b.state.count("potion"), sk.potions["potion"])
        assertTrue(sk.fighters.none { it.side == Side.PARTY && it.id != Skirmish.HERO })
    }

    @Test
    fun atLevelOneTheFoesHitWorseInMarsToo() {
        val b = battle("wolf")
        assertEquals(1, b.state.hero.level)
        val sk = Skirmish.fromBattle(b, Dice(Random(2)))
        // 38: leader and pack carry the same level-1 ease as the old fight
        assertEquals(b.enemyAttack - b.monster.attackBonus, sk.byId("foe").attackShift)
        assertTrue(b.firstLevelEase > 0)
        sk.fighters.filter { it.side == Side.FOES && it.id != "foe" }.forEach { assertEquals(-b.firstLevelEase, it.attackShift) }
    }

    @Test
    fun aWinBringsExperienceAndThePotionsDrunkLeaveTheBag() {
        val b = battle("boar")
        val s = b.state
        val potions = s.count("potion")
        assertTrue(potions > 0)
        s.hero.hp = 1
        val sk = Skirmish.fromBattle(b, Dice(Random(3)))
        sk.start()
        // the hero drinks on his first turn, then the test button ends the fight
        while (sk.outcome == Outcome.ONGOING && sk.current.side != Side.PARTY) sk.proceed()
        sk.act(Order.Drink("potion", Skirmish.HERO))
        if (sk.outcome == Outcome.ONGOING) sk.testEnd(true)
        if (sk.outcome != Outcome.WON) return
        val xp = s.hero.xp
        val lines = b.closeMars(sk)
        assertEquals(Outcome.WON, b.outcome)
        assertNotNull(b.rewards)
        assertTrue(s.hero.xp > xp || b.rewards!!.xp == 0)
        assertEquals(potions - 1, s.count("potion"))
        assertEquals(sk.byId(Skirmish.HERO).hp, s.hero.hp)
        assertTrue(lines.isNotEmpty())
    }

    @Test
    fun fleeingEndsTheFightButNeverFromABoss() {
        val boss = Skirmish.fromBattle(battle(Skirmish.GRAK), Dice(Random(1)))
        assertFalse(boss.canFlee(boss.byId(Skirmish.HERO)))
        var fled = false
        for (seed in 0 until 30) {
            val b = battle("boar", seed = seed)
            val sk = Skirmish.fromBattle(b, Dice(Random(seed)))
            sk.start()
            if (sk.outcome != Outcome.ONGOING || sk.current.side != Side.PARTY) continue
            assertTrue(sk.canFlee(sk.current))
            sk.act(Order.Flee)
            if (sk.outcome == Outcome.FLED) {
                fled = true
                b.closeMars(sk)
                assertEquals(Outcome.FLED, b.outcome)
                assertEquals(null, b.rewards)
            }
        }
        assertTrue(fled)
    }

    @Test
    fun ambushedTheFoesActFirstFromBehindTheyLoseTheirFirstTurn() {
        for (seed in 0 until 10) {
            val ambushed = Skirmish.fromBattle(battle("boar", Opening.AMBUSHED, seed), Dice(Random(seed)))
            val first = ambushed.start()
            assertTrue(first.any { it.actor == "foe" && it.cue == SkirmishCue.FOE_STRIKES }, "seed $seed")

            val behind = Skirmish.fromBattle(battle("boar", Opening.HERO_FIRST, seed), Dice(Random(seed)))
            val opened = behind.start()
            assertTrue(opened.none { it.actor == "foe" && it.cue == SkirmishCue.FOE_STRIKES }, "seed $seed")
            assertEquals(Skirmish.HERO, behind.current.id)
            val next = behind.act(Order.Wait)
            assertTrue(next.any { it.actor == "foe" && it.text.contains("überrascht") }, "seed $seed")
        }
    }

    @Test
    fun aStatusBroughtAlongHurtsAtTheTurnsStartAndGoesBackIntoTheGame() {
        val b = battle("boar", Opening.HERO_FIRST)
        b.state.ailments[Status.POISON.name] = 3
        val sk = Skirmish.fromBattle(Battle(b.state, Monsters["boar"], Lang.DE, Dice(Random(4)), opening = Opening.HERO_FIRST), Dice(Random(4)))
        val me = sk.byId(Skirmish.HERO)
        assertEquals(3, me.status[Status.POISON])
        val hp = me.hp
        val lines = sk.start()
        assertTrue(me.hp < hp, "the poison hurts before the first order")
        assertTrue(lines.any { it.status[Skirmish.HERO]?.get(Status.POISON) == 2 })
        assertEquals(2, me.status[Status.POISON])
    }

    @Test
    fun aCentipedesBitePoisonsAndTheStatusGoesBackIntoTheGame() {
        var poisoned = false
        for (seed in 0 until 40) {
            val b = battle("giant_centipede", seed = seed)
            val sk = Skirmish.fromBattle(b, Dice(Random(seed)))
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 30) {
                val e = sk.act(Order.Wait)
                if (e.any { it.text.contains("vergiftet") }) poisoned = true
            }
            if (sk.outcome != Outcome.ONGOING) {
                b.closeMars(sk)
                assertEquals(sk.byId(Skirmish.HERO).status.keys, b.heroStatus.keys)
            }
        }
        assertTrue(poisoned)
    }
}
