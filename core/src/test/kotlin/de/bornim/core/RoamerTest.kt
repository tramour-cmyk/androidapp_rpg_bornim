package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class RoamerTest {
    private fun forestGame(seed: Int = 1): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(seed)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = Place("forest", 10, 20, Facing.UP)
        return g
    }

    @Test
    fun forestIsPopulatedAwayFromTheHero() {
        val g = forestGame()
        assertEquals(7, g.roamers.size)
        for (r in g.roamers) {
            assertTrue(kotlin.math.abs(r.x - 10) + kotlin.math.abs(r.y - 20) >= 7, "spawned too close")
            assertEquals(Tile.TALL_GRASS, g.map.tile(r.x, r.y))
        }
    }

    @Test
    fun hunterFromBehindAmbushes() {
        var ambushes = 0
        for (seed in 1..10) {
            val g = forestGame(seed)
            val p = g.state.place
            // a wolf right behind the hero, who looks up
            val wolf = g.roamers.first()
            g.roamers.drop(1).forEach { it.x = 0; it.y = 0 }
            wolf.x = p.x; wolf.y = p.y + 2
            val hunter = Roamer(99, "wolf", p.x, p.y + 1, p.x, p.y + 1, null, false, MonsterLook())
            // drive the clock until something happens
            var t = 0L
            val start = g.roamers.first()
            start.x = hunter.x; start.y = hunter.y
            while (g.mode == Mode.Explore && t < 20_000) {
                t += 100
                g.updateRoamers(t)
            }
            val b = (g.mode as? Mode.Fight)?.battle ?: continue
            if (b.opening == Opening.AMBUSHED) ambushes++
        }
        assertTrue(ambushes > 0, "never ambushed from behind")
    }

    @Test
    fun walkingIntoAMonsterFromBehindGivesFirstStrike() {
        val g = forestGame()
        val p = g.state.place
        val r = g.roamers.first()
        g.roamers.drop(1).forEach { it.x = 0; it.y = 0 }
        r.x = p.x + 1; r.y = p.y
        r.facing = Facing.RIGHT // looking away from the hero
        assertEquals(ActionKind.FIGHT, g.actionAt(r.x, r.y))
        g.move(Facing.RIGHT)
        val b = (g.mode as Mode.Fight).battle
        assertEquals(Opening.HERO_FIRST, b.opening)
        val steps = b.start()
        assertTrue(steps.any { it.text.contains("Erstschlag") })
        // the hero acts, the surprised monster cannot answer in the first round
        val round = b.act(Action.Attack)
        assertTrue(round.any { it.text.contains("noch überrascht") } || b.outcome != Outcome.ONGOING)
    }

    @Test
    fun defeatedMonstersComeBackAfterAWalk() {
        val g = forestGame()
        val p = g.state.place
        val r = g.roamers.first()
        r.x = p.x; r.y = p.y - 1
        g.state.hero.gainXp(Rules.xpForLevel[10])
        g.move(Facing.UP)
        val b = (g.mode as Mode.Fight).battle
        b.start()
        while (b.outcome == Outcome.ONGOING) {
            g.state.hero.restoreFully()
            b.act(Action.Attack)
        }
        g.endBattle()
        assertEquals(6, g.roamers.size)
        g.state.steps += 61
        g.afterStep()
        assertEquals(7, g.roamers.size)
    }

    @Test
    fun ambushesInTheGrassAreRare() {
        val g = forestGame()
        assertTrue(g.map.encounters!!.rate <= 0.005)
    }
}
