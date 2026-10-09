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

    /** A wolf whose home is right where it is put. */
    private fun wolfAt(g: Game, x: Int, y: Int): Roamer {
        val herd = g.roamers as MutableList<Roamer>
        herd.clear()
        return Roamer(99, "wolf", x, y, x, y, null, false, MonsterLook()).also { herd += it }
    }

    @Test
    fun hunterFromBehindAmbushes() {
        val g = forestGame()
        val p = g.state.place // hero looks up
        wolfAt(g, p.x, p.y + 3)
        var t = 0L
        while (g.mode == Mode.Explore && t < 20_000) {
            t += 100
            g.update(t)
        }
        val b = (g.mode as Mode.Fight).battle
        assertEquals(Opening.AMBUSHED, b.opening)
    }

    @Test
    fun huntersGiveUpInSafeZonesAndGoHome() {
        val g = forestGame()
        // hero stands at the hunter's camp; a wolf nearby must not attack
        g.state.place = Place("forest", 12, 11, Facing.UP)
        assertTrue(g.map.safe(12, 11))
        val wolf = wolfAt(g, 12, 16)
        wolf.hunting = true
        var t = 0L
        repeat(300) {
            t += 100
            g.update(t)
            assertEquals(Mode.Explore, g.mode, "attacked in a safe zone")
            assertTrue(!g.map.safe(wolf.x, wolf.y), "wolf entered the safe zone")
        }
        assertTrue(!wolf.hunting)
        assertTrue(kotlin.math.abs(wolf.x - wolf.homeX) + kotlin.math.abs(wolf.y - wolf.homeY) <= 3, "wolf did not go home")
        assertTrue(g.notices.isNotEmpty(), "no notice from the hunter")
        // Garrick at the camp wards it off with a torch (09.10.)
        val w = g.lastWardOff
        assertTrue(w != null && w.x == 12 && w.y == 9, "no torch scene at the camp")
        assertTrue(kotlin.math.abs(w!!.beastX - 12) + kotlin.math.abs(w.beastY - 9) <= 8)
    }

    @Test
    fun huntersLeftBehindReturnHome() {
        val g = forestGame()
        val wolf = wolfAt(g, 6, 22)
        // the wolf was lured far away, then loses the hero
        wolf.x = 6; wolf.y = 12
        wolf.hunting = true
        g.state.place = Place("forest", 17, 4, Facing.UP)
        var t = 0L
        repeat(400) {
            t += 100
            g.update(t)
        }
        assertTrue(kotlin.math.abs(wolf.x - 6) + kotlin.math.abs(wolf.y - 22) <= 3, "wolf stayed at ${wolf.x},${wolf.y}")
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
        // the first strike is only named: the hero does not move before the player chooses
        assertTrue(steps.none { it.anim == Anim.HERO_ACT || it.anim == Anim.SPELL || it.anim == Anim.THROW })
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
