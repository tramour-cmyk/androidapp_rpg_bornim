package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.Roamer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 24.5: a near foe's fight is drawn ahead on the map, so the fight finds its frames ready. */
class BattleAheadTest {

    private fun roamer(uid: Int, monster: String, x: Int, y: Int) = Roamer(uid, monster, x, y, x, y, null, false, MonsterLook(uid))

    @Test fun theNearestFoeWithinEightFields() {
        val far = roamer(1, "wolf", 10, 0)
        val near = roamer(2, "goblin", 3, 4)
        val nearer = roamer(3, "kobold", 0, 5)
        assertEquals("kobold", BattleAhead.nearest(listOf(far, near, nearer), 0, 0)?.monster)
        assertEquals("goblin", BattleAhead.nearest(listOf(far, near), 0, 0)?.monster, "7 fields walked is near")
        assertNull(BattleAhead.nearest(listOf(far, roamer(4, "wolf", 5, 4)), 0, 0), "9 fields and more are not")
    }

    /** Keeps the map "shown" (calls [BattleAhead.consider] as each frame would) while [until] is false, at most [ms]. */
    private fun mapShows(hero: de.bornim.core.Hero, foe: Pair<String, MonsterLook>, busy: () -> Boolean, ms: Long, until: () -> Boolean = { false }): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) {
            BattleAhead.consider(hero, foe, busy = busy)
            if (until()) return true
            Thread.sleep(40)
        }
        return false
    }

    @Test fun theFightIsReadyWhenItBegins() {
        BattleAhead.reset()
        val hero = GameState.newGame("Ahead", Race.HUMAN, CharClass.FIGHTER).hero
        val foe = "goblin" to MonsterLook(11)
        val pick = BattleAhead.victoryPick
        fun allReady(ambushed: Boolean) = HeroBattle.planOf(hero, foe.first, ambushed, pick).all { (act, strike, v) -> HeroBattle.actReady(hero, act, strike, v) }
        assertTrue(mapShows(hero, foe, { false }, 120_000) { allReady(false) && allReady(true) && !BattleAhead.working },
            "every frame of the fight, struck from behind or not, drawn ahead")
        // the fight beginning now ends in the pose drawn ahead
        assertEquals(pick, BattleAhead.takeVictoryPick())
    }

    @Test fun nothingWhileTheMapDrawsOrIsGone() {
        BattleAhead.reset()
        val hero = GameState.newGame("Busy", Race.ELF, CharClass.WIZARD).hero
        val foe = "wolf" to MonsterLook(5)
        mapShows(hero, foe, { true }, 600)
        assertEquals(0, BattleAhead.drawn, "the map draws first")
        // the map gone (a fight, the menu): it stops soon after
        BattleAhead.consider(hero, foe) { false }
        Thread.sleep(BattleAhead.STALE_MS + 600)
        val n = BattleAhead.drawn
        Thread.sleep(800)
        assertEquals(n, BattleAhead.drawn, "no drawing once the map is no longer shown")
        assertTrue(!HeroBattle.actReady(hero, HeroFigure.Act.DRINK), "not all drawn: it stopped")
    }
}
