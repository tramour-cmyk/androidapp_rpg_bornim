package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 154: a lost fight costs time, not gold. 155: the cave fire stays, resting there is refused. */
class DeathTest {
    private fun skip(g: Game) {
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    }

    @Test
    fun aLostFightKeepsTheGoldAndCostsFourHours() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.WIZARD)
        s.gold = 100
        val g = Game(s, Lang.DE, Dice(Random(7)))
        skip(g)
        val before = s.clock
        val b = Battle(s, Monsters["goblin"], Lang.DE, Dice(Random(7)), 1, false, 1)
        b.start()
        g.fight(b)
        var turns = 0
        while (b.outcome == Outcome.ONGOING && turns++ < 200) b.act(Action.EndTurn)
        assertEquals(Outcome.LOST, b.outcome)
        g.endBattle()
        assertEquals(100, s.gold, "no gold lost")
        assertTrue(s.clock - before >= Game.DEATH_HOURS * 60L, "the way home takes time")
        assertEquals(s.hero.maxHp, s.hero.hp)
    }

    @Test
    fun theCaveFireOffersNoRest() {
        val cave = World.maps.values.filter { it.kind == MapKind.CAVE }
            .mapNotNull { m -> (0 until m.height).flatMap { y -> (0 until m.width).map { x -> Triple(m, x, y) } }.firstOrNull { (mm, x, y) -> mm.tile(x, y) == Tile.CAMPFIRE } }
        assertTrue(cave.isNotEmpty(), "the goblins' fire is still in the cave")
        val (m, x, y) = cave.first()
        val g = Game(GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER), Lang.DE, Dice(Random(4)))
        skip(g)
        assertEquals(ActionKind.LOOK, g.run { state.place = Place(m.id, x, y + 1, Facing.UP); actionAt(x, y) })
        g.interact()
        assertTrue(g.mode !is Mode.Rest, "no rest in the cave")
    }
}
