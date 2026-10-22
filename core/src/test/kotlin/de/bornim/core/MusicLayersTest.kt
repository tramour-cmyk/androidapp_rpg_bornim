package de.bornim.core

import de.bornim.core.audio.MusicDirector
import de.bornim.core.audio.MusicLib
import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.Threat
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** 120, music in layers: a hunter coming near darkens the music and lets a dark layer creep in; noticed, silence. */
class MusicLayersTest {
    private fun forestGame(): Game {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val g = Game(s, Lang.DE, Dice(Random(1)))
        var guard = 0
        while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
        s.flags += Story.QUEST_STARTED
        s.place = Place("forest", 10, 20, Facing.UP)
        return g
    }

    private fun only(g: Game, monster: String, x: Int, y: Int): Roamer {
        val herd = g.roamers as MutableList<Roamer>
        herd.clear()
        return Roamer(99, monster, x, y, x, y, null, false, MonsterLook()).also { herd += it }
    }

    @Test
    fun nearestHunterSetsTheThreat() {
        val g = forestGame()
        val p = g.state.place
        val range = Perks.noticeRange(g.hero)
        val wolf = only(g, "wolf", p.x, p.y + Threat.FAR_TILES)
        assertEquals(0f, g.threat().near)
        wolf.y = p.y + range + 2
        val mid = g.threat().near
        assertTrue(mid > 0f && mid < 1f, "near $mid")
        wolf.y = p.y + range
        assertEquals(1f, g.threat().near)
        assertTrue(!g.threat().noticed)
        wolf.hunting = true
        assertTrue(g.threat().noticed)
        // lurkers in hiding and wanderers do not darken the music; on its way home a hunter neither
        only(g, "giant_spider", p.x, p.y + range)
        assertEquals(Threat.NONE, g.threat())
        only(g, "wolf", p.x, p.y + range).returning = true
        assertEquals(Threat.NONE, g.threat())
        // monsters that ignore the hero (test switch) neither
        only(g, "wolf", p.x, p.y + range)
        Game.monstersIgnoreHero = true
        try { assertEquals(Threat.NONE, g.threat()) } finally { Game.monstersIgnoreHero = false }
    }

    @Test
    fun layerCreepsInDarkensAndFallsSilentWhenNoticed() {
        val d = MusicDirector(3)
        val calm = d.update(MusicScene.FOREST, 0)
        val piece = assertNotNull(calm.music)
        assertNull(calm.layer)
        assertEquals(1f, calm.level)
        assertEquals(0f, calm.dark)
        // closer and closer: quieter, more muffled, the layer louder; the piece plays on
        val half = d.update(MusicScene.FOREST, 1000, threat = Threat(0.5f))
        val close = d.update(MusicScene.FOREST, 2000, threat = Threat(1f))
        assertEquals(piece, close.music)
        val layer = assertNotNull(half.layer)
        assertTrue(layer in MusicLib.layers)
        assertEquals(layer, close.layer)
        assertTrue(close.level < half.level && half.level < 1f)
        assertTrue(close.dark > half.dark && half.dark > 0f)
        assertTrue(close.layerLevel > half.layerLevel && half.layerLevel > 0f)
        assertEquals(MusicDirector.PLACE_FADE_MS, close.shadeMs)
        // noticed: silence, quickly, until the fight's piece (319: after its black screen and a short pause)
        val noticed = d.update(MusicScene.FOREST, 3000, threat = Threat(1f, noticed = true))
        assertEquals(0f, noticed.level)
        assertEquals(0f, noticed.layerLevel)
        assertEquals(MusicDirector.NOTICE_FADE_MS, noticed.shadeMs)
        assertNull(d.update(MusicScene.BATTLE, 4000, threat = Threat(1f, noticed = true)).music)
        val fight = d.update(MusicScene.BATTLE, 6000, threat = Threat(1f, noticed = true))
        assertNull(fight.layer)
        assertEquals(1f, fight.level)
        assertTrue(fight.music!!.name in MusicLib.battle)
    }

    @Test
    fun turningAwayEasesBackAndTheNextApproachBringsAnotherLayer() {
        val d = MusicDirector(5)
        d.update(MusicScene.FOREST, 0)
        val first = assertNotNull(d.update(MusicScene.FOREST, 1000, threat = Threat(0.8f)).layer)
        // it turns away: all back, the layer fades out under its own name for a while, then goes
        val away = d.update(MusicScene.FOREST, 2000)
        assertEquals(1f, away.level)
        assertEquals(0f, away.dark)
        assertEquals(0f, away.layerLevel)
        assertEquals(first, away.layer)
        assertNull(d.update(MusicScene.FOREST, 2000 + MusicDirector.LAYER_HOLD_MS + 1).layer)
        val second = assertNotNull(d.update(MusicScene.FOREST, 10_000, threat = Threat(0.3f)).layer)
        assertNotEquals(first, second, "the layers take turns")
    }

    @Test
    fun noLayerInTheVillageNorOutsideTheWorld() {
        val d = MusicDirector(1)
        for (s in listOf(MusicScene.VILLAGE, MusicScene.TITLE, MusicScene.INTRO, MusicScene.TEMPLE, MusicScene.CHAPTER_END)) {
            val w = d.update(s, 0, threat = Threat(1f, noticed = true))
            assertNull(w.layer)
            assertEquals(0f, w.dark)
        }
    }
}
