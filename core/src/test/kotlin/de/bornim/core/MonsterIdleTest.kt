package de.bornim.core

import de.bornim.core.audio.MonsterIdle
import de.bornim.core.audio.Sound
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** D3.9: monsters on the map are heard while they are not hunting, close by only and softer further off. */
class MonsterIdleTest {
    private fun forestGame(): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = Place("forest", 10, 20, Facing.UP)
        return g
    }

    /** Lets a calm wolf stand [dist] tiles below the hero for [ms] and returns what was heard of it. */
    private fun heard(dist: Int, ms: Long = 60_000): List<Float> {
        val g = forestGame()
        val p = g.state.place
        val herd = g.roamers as MutableList<Roamer>
        herd.clear()
        herd += Roamer(99, "wolf", p.x, p.y + dist, p.x, p.y + dist, null, false, MonsterLook()).also { it.nextMoveAt = Long.MAX_VALUE }
        Game.monstersIgnoreHero = true
        val out = ArrayList<Float>()
        try {
            var t = 0L
            while (t < ms) {
                t += 100; g.update(t)
                while (g.placedSounds.isNotEmpty()) g.placedSounds.removeFirst().let { (s, v) -> if (s == Sound.IDLE_WOLF) out += v }
            }
        } finally {
            Game.monstersIgnoreHero = false
        }
        return out
    }

    @Test
    fun aWolfNearbyIsHeardNowAndThen() {
        val near = heard(3)
        // one minute: a pause of 7 to 16 s between sounds, and none at the very start
        assertTrue(near.size in 3..8, "heard ${near.size} times")
        assertTrue(near.all { it == MonsterIdle.volume(3) })
        assertTrue(MonsterIdle.volume(2) > MonsterIdle.volume(3) && MonsterIdle.volume(3) > MonsterIdle.volume(6))
        assertEquals(MonsterIdle.LOUD, MonsterIdle.volume(1))
    }

    @Test
    fun aWolfFarOffIsNotHeard() {
        assertTrue(heard(MonsterIdle.FAR).isEmpty())
        assertTrue(heard(MonsterIdle.FAR + 4).isEmpty())
    }

    @Test
    fun everyMonsterThatRoamsHasASoundAtRest() {
        val ids = World.maps.values.mapNotNull { it.encounters }.flatMap { e -> e.table.map { it.first } + e.night.orEmpty().map { it.first } }.toSet()
        assertTrue(ids.isNotEmpty())
        val missing = ids.filter { MonsterIdle.of(it) == null }
        assertTrue(missing.isEmpty(), "ohne Laut auf der Karte: $missing")
        val unused = MonsterIdle.SOUNDS.filter { s -> ids.none { MonsterIdle.of(it) == s } }
        assertTrue(unused.isEmpty(), "Laute ohne Monster: $unused")
    }
}
