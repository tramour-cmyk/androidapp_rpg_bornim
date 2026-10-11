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
    private fun mapShows(hero: de.bornim.core.Hero, foe: Pair<String, MonsterLook>, busy: () -> Boolean, ms: Long, until: () -> Boolean = { false }): Boolean =
        mapShows(hero, { listOf(foe) }, busy, ms, until)

    private fun mapShows(hero: de.bornim.core.Hero, foes: () -> List<Pair<String, MonsterLook>>, busy: () -> Boolean, ms: Long, until: () -> Boolean = { false }): Boolean {
        val end = System.currentTimeMillis() + ms
        while (System.currentTimeMillis() < end) {
            BattleAhead.consider(hero, foes(), busy = busy)
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
        BattleAhead.consider(hero, listOf(foe)) { false }
        Thread.sleep(BattleAhead.STALE_MS + 600)
        val n = BattleAhead.drawn
        Thread.sleep(800)
        assertEquals(n, BattleAhead.drawn, "no drawing once the map is no longer shown")
        assertTrue(!HeroBattle.actReady(hero, HeroFigure.Act.DRINK), "not all drawn: it stopped")
    }

    /**
     * 24.18: the hero's opening first, then the foe, then the rest of the hero; and a pack whose nearest changes all the
     * time still gets the foe being drawn done. Prints when each was ready (24.17: on [BattleAhead.CORES] cores).
     */
    @Test fun openingThenFoeThenTheRestThoughThePackShifts() {
        BattleAhead.reset()
        val hero = GameState.newGame("Order", Race.DWARF, CharClass.CLERIC).hero
        val pack = listOf("wolf" to MonsterLook(21), "wolf" to MonsterLook(22), "wolf" to MonsterLook(23))
        val pick = BattleAhead.victoryPick
        val start = System.currentTimeMillis()
        var opening = -1L; var foe = -1L; var rest = -1L
        var tick = 0
        fun foeReady(f: Pair<String, MonsterLook>): Boolean { BattleAhead.noteFight(hero, f.first, f.second, false, pick); return BattleAhead.report!!.foeDone }
        val shifting = { tick++; listOf(pack[tick / 3 % 3]) + pack.filter { it != pack[tick / 3 % 3] } }
        assertTrue(mapShows(hero, shifting, { false }, 60_000) {
            val now = System.currentTimeMillis() - start
            if (opening < 0 && HeroBattle.actReady(hero, HeroFigure.Act.IDLE)) opening = now
            if (foe < 0 && pack.any { foeReady(it) }) foe = now
            if (rest < 0 && HeroBattle.planOf(hero, "wolf", false, pick).all { (a, s, v) -> HeroBattle.actReady(hero, a, s, v) }) rest = now
            rest >= 0 && foe >= 0 && opening >= 0
        }, "all drawn ahead though the nearest wolf kept changing: opening $opening, foe $foe, rest $rest ms, ${BattleAhead.drawn} drawn")
        println("24.17/24.18 drawn ahead on ${BattleAhead.CORES} cores: opening ${opening} ms, foe ${foe} ms, the rest of the hero ${rest} ms")
        assertTrue(opening <= foe, "the hero's opening before the foe")
        assertTrue(foe <= rest, "the foe before the rest of the hero")
    }

    /** 24.20: with no foe near the hero's frames are drawn too, kept on the device, and read back after a new start. */
    @Test fun theHeroIsDrawnWithNoFoeNearAndKept() {
        val dir = kotlin.io.path.createTempDirectory("battle-shelf").toFile()
        try {
            HeroShelf.dir = dir
            BattleAhead.reset()
            val hero = GameState.newGame("Kept", Race.HALFLING, CharClass.ROGUE).hero
            val pick = BattleAhead.victoryPick
            fun allReady() = HeroBattle.planOf(hero, "goblin", false, pick).all { (a, s, v) -> HeroBattle.actReady(hero, a, s, v) }
            assertTrue(mapShows(hero, { emptyList() }, { false }, 120_000) { allReady() && HeroShelf.hasFrames("battle|" + HeroBattle.look(hero)) },
                "drawn ahead with no foe near, and kept")
            // a new start: nothing in memory, the frames read from the device instead of drawn
            BattleAhead.reset(); HeroBattle.forgetAll()
            val start = System.currentTimeMillis()
            assertTrue(mapShows(hero, { emptyList() }, { false }, 20_000) { allReady() }, "read back")
            println("24.20 the hero's battle frames read back in ${System.currentTimeMillis() - start} ms")
            assertTrue(BattleAhead.fromShelf)
            assertEquals(0, HeroBattle.fresh, "none drawn again")
        } finally { HeroShelf.dir = null; dir.deleteRecursively() }
    }
}
