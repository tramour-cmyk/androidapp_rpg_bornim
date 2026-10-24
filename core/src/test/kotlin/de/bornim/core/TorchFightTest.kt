package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 344.2: the torch thrust in both systems: 1 fire damage, beasts may back off, people and the dead never. */
class TorchFightTest {
    private fun state(torch: Boolean): GameState = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).also { s ->
        s.hero.unequip(GearSlot.OFF_HAND)
        if (torch) s.hero.equip(Gear(-90L, "torch", Rarity.COMMON, 1))
    }

    @Test
    fun withoutATorchThereIsNoThrust() {
        val b = Battle(state(false), Monsters["wolf"], Lang.DE, Dice(Random(1)))
        b.start()
        assertFalse(b.torchReady)
        val hp = b.enemyHp
        b.act(Action.Torch)
        assertEquals(hp, b.enemyHp)
    }

    @Test
    fun aThrustDoesOneFireDamageAndAWolfMayBackOff() {
        var hits = 0; var scared = 0
        for (seed in 0 until 60) {
            val b = Battle(state(true), Monsters["wolf"], Lang.DE, Dice(Random(seed)))
            b.start()
            assertTrue(b.torchReady)
            val hp = b.enemyHp
            val steps = b.act(Action.Torch).map { it.text }
            if (b.enemyHp < hp) { hits++; assertEquals(TorchFight.DAMAGE, hp - b.enemyHp) }
            if (steps.any { it == TorchFight.backsOff.f(Lang.DE, b.monster.name(Lang.DE)) || it.contains("weicht zurück") }) scared++
        }
        assertTrue(hits > 0)
        assertTrue(scared > 0)
    }

    @Test
    fun peopleAndTheDeadDoNotShyFromFire() {
        assertFalse(TorchFight.shy(Monsters["goblin"]))
        assertFalse(TorchFight.shy(Monsters["skeleton"]))
        assertTrue(TorchFight.shy(Monsters["wolf"]))
    }

    @Test
    fun inMarsABeastMayBackOffFromTheTorch() {
        var backed = 0
        for (seed in 0 until 60) {
            val b = Battle(state(true), Monsters["wolf"], Lang.DE, Dice(Random(seed)))
            val sk = Skirmish.fromBattle(b, Dice(Random(seed)))
            sk.start()
            while (sk.outcome == Outcome.ONGOING && sk.current.side != Side.PARTY) sk.proceed()
            if (sk.outcome != Outcome.ONGOING) continue
            val me = sk.byId(Skirmish.HERO)
            assertTrue(sk.torchReady(me))
            val t = sk.torchTargets(me).first()
            val events = sk.act(Order.Torch(t.id))
            // where it stands after the foes' turns tells nothing (a pounce brings it to the front again): the line does
            if (events.any { it.text.contains("weicht zurück") }) backed++
        }
        assertTrue(backed > 0)
    }
}
