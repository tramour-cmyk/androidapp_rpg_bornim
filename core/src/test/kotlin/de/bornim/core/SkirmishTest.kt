package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/** Probe 72.10: rows, place swap, ring, autopilot, knockouts (72.11, 72.13, 72v, 72r). */
class SkirmishTest {
    private fun probe(seed: Int, cls: CharClass = CharClass.FIGHTER, merc: CharClass = CharClass.ROGUE): Skirmish {
        val s = GameState.newGame("T", Race.HUMAN, cls)
        return Skirmish.grakProbe(s, merc, Lang.DE, Dice(Random(seed)))
    }

    /** Plays the probe to its end with plain attacks on Grak and the given ring result. */
    private fun play(sk: Skirmish, ring: Reaction): Outcome {
        sk.start { _, _ -> ring }
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 500) {
            val t = sk.targets(sk.current).firstOrNull()
            sk.act(if (t != null) Order.Attack(t.id) else Order.Wait) { _, _ -> ring }
        }
        return sk.outcome
    }

    @Test
    fun meleeReachesOnlyTheFrontRowWhileSomeoneStandsThere() {
        val sk = probe(1, merc = CharClass.FIGHTER)
        val grak = sk.byId("grak")
        sk.byId("merc").place = Spot(Row.BACK, 0)
        assertEquals(listOf("hero"), sk.targets(grak).map { it.id })
        sk.byId("hero").hp = 0
        assertEquals(listOf("merc"), sk.targets(grak).map { it.id })
    }

    @Test
    fun aSwapCostsTheTurnAndTradesPlaces() {
        for (seed in 0 until 50) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.start()
            if (sk.outcome != Outcome.ONGOING) continue
            val f = sk.current
            val other = sk.fighters.first { it.side == Side.PARTY && it !== f }
            val mine = f.place
            val theirs = other.place
            sk.act(Order.Swap(theirs))
            assertEquals(theirs, f.place)
            assertEquals(mine, other.place)
            return
        }
        error("no probe got to a party turn")
    }

    @Test
    fun theRingCutsTheDamage() {
        fun lost(ring: Reaction) = (0 until 300).count { play(probe(it), ring) == Outcome.LOST }
        val none = lost(Reaction.NONE)
        val good = lost(Reaction.GOOD)
        val perfect = lost(Reaction.PERFECT)
        assertTrue(none > good, "no reaction $none, good $good")
        assertTrue(good >= perfect, "good $good, perfect $perfect")
    }

    @Test
    fun aDownedSoeldnerIsCountedNotKilled() {
        var seen = false
        for (seed in 0 until 300) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            play(sk, Reaction.NONE)
            if (sk.knockouts > 0) {
                seen = true
                assertEquals(0, sk.byId("merc").hp)
            }
        }
        assertTrue(seen)
    }

    @Test
    fun autopilotNeverStartsAgainstABoss() {
        val sk = probe(3)
        assertNotNull(sk.autopilotBlocked())
        assertFalse(sk.setAutopilot(true))
    }

    @Test
    fun autopilotStopsOnAStrongIntentOrLowLife() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val goblin = Monsters["goblin"]
        for (seed in 0 until 100) {
            val sk = Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = s.hero.maxHp),
                    Fighter("merc", Side.PARTY, Spot(Row.FRONT, 1), hero = Hero.create("M", Race.HUMAN, CharClass.FIGHTER), hp = 12),
                ),
                listOf(Fighter("gob", Side.FOES, Spot(Row.FRONT, 0), monster = goblin, hp = 40)),
                Lang.DE, Dice(Random(seed)),
            )
            sk.start()
            if (sk.outcome != Outcome.ONGOING || !sk.setAutopilot(true)) continue
            sk.act(Order.Wait)
            if (sk.outcome != Outcome.ONGOING) continue
            // the autopilot hands back only when one of its stop rules holds
            assertFalse(sk.autopilot)
            assertNotNull(sk.autopilotBlocked())
        }
    }

    @Test
    fun windedHeroRollsInitiativeWithDisadvantage() {
        fun mean(winded: Boolean) = (0 until 400).map { seed ->
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).also { it.winded = winded }
            Skirmish.grakProbe(s, CharClass.ROGUE, Lang.DE, Dice(Random(seed))).byId("hero").initiative
        }.average()
        assertTrue(mean(true) < mean(false) - 2)
    }

    @Test
    fun grakAnnouncesOnlyHisThreeIntents() {
        val seen = mutableSetOf<String>()
        for (seed in 0 until 200) {
            val sk = probe(seed)
            sk.start { _, _ -> Reaction.GOOD }
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200) {
                sk.intents["grak"]?.let { seen += it.first.id }
                val t = sk.targets(sk.current).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait) { _, _ -> Reaction.GOOD }
            }
        }
        assertEquals(setOf("heavy", "call", "gather"), seen)
    }

    @Test
    fun calledGoblinsJoinTheFoesAndTheFightStillEnds() {
        var joined = false
        for (seed in 0 until 200) {
            val sk = probe(seed)
            val out = play(sk, Reaction.GOOD)
            assertTrue(out != Outcome.ONGOING, "seed $seed did not end")
            val gobs = sk.fighters.filter { it.monster?.id == Skirmish.CALLED }
            assertTrue(gobs.size <= Skirmish.CALL_MAX)
            assertEquals(sk.fighters.size, sk.fighters.map { it.side to it.place }.toSet().size, "one figure per place")
            if (gobs.isNotEmpty()) joined = true
        }
        assertTrue(joined)
    }

    @Test
    fun aHardHitBreaksAnAnnouncedHeavyBlow() {
        var broke = false
        for (seed in 0 until 300) {
            val sk = probe(seed)
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200 && !broke) {
                val before = sk.intents["grak"]?.first
                val t = sk.targets(sk.current).firstOrNull()
                val ev = sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
                if (before?.breakable == true && ev.any { it.text.contains("vereitelt") }) broke = true
            }
        }
        assertTrue(broke)
    }

    @Test
    fun aSoeldnerOnAutoPlaysItselfEvenAgainstABoss() {
        for (seed in 0 until 50) {
            val sk = probe(seed)
            sk.byId("merc").auto = true
            sk.start()
            if (sk.outcome != Outcome.ONGOING) continue
            assertEquals("hero", sk.current.id)
            sk.act(Order.Wait)
            if (sk.outcome == Outcome.ONGOING) assertEquals("hero", sk.current.id)
        }
    }
}
