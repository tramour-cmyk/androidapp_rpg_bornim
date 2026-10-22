package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** 134.1: the golden sign only over people met before, who have news, and only briefly when the hero comes near. */
class HailTest {
    private fun state() = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
    private fun npc(map: String, id: String) = World[map].npcs.first { it.id == id }

    @Test
    fun `strangers never, old saves not until the next talk`() {
        val s = state()
        val jorin = npc("village", "jorin")
        assertFalse(Hail.news(s, jorin), "never spoken to")
        s.flags += MapMarks.met("jorin")
        assertFalse(Hail.news(s, jorin), "a save from before 134.1: nothing heard is known")
        Hail.heard(s, jorin, after = false)
        assertFalse(Hail.news(s, jorin), "just heard")
    }

    @Test
    fun `news when the talk changes, none for what follows from the talk itself`() {
        val s = state()
        val jorin = npc("village", "jorin")
        s.flags += MapMarks.met("jorin")
        Hail.heard(s, jorin, after = false)
        s.flags += Story.QUEST_STARTED
        assertTrue(Hail.news(s, jorin), "the elder sent the hero: Jorin opens the barrier")
        // the talk: heard as it starts, the barrier opens in it, then the talk is over
        Hail.heard(s, jorin, after = false)
        s.flags += Story.BARRIER_OPEN
        Hail.heard(s, jorin, after = true)
        assertFalse(Hail.news(s, jorin), "his short word after the barrier is no news")
        val rowena = npc("inn", "rowena")
        s.flags += MapMarks.met("rowena")
        Hail.heard(s, rowena, after = false)
        Hail.heard(s, rowena, after = true)
        s.flags += Story.CHAPTER1_DONE
        s.flags += Story.CAMP_TOLD
        assertTrue(Hail.news(s, rowena), "Rowena on the camp in the south")
    }

    @Test
    fun `a job to hand in is news`() {
        val s = state()
        val j = Jobs["tusks"]
        val giver = World.maps.values.flatMap { it.npcs }.first { it.id == j.giver }
        s.flags += MapMarks.met(giver.id)
        Hail.heard(s, giver, after = false)
        Jobs.take(s, j)
        assertFalse(Hail.news(s, giver), "taken, nothing brought yet")
        s.add(j.item, j.count)
        assertTrue(Hail.news(s, giver))
    }

    @Test
    fun `what was heard is saved, talks depend only on the save`() {
        val s = state()
        val jorin = npc("village", "jorin")
        Hail.heard(s, jorin, after = false)
        assertEquals(s.heard, GameState.fromJson(s.toJson()).heard)
        // a talk with chance or the hour in it would hail anew each time
        for (m in World.maps.values) for (n in m.npcs) if (!n.look.startsWith("monster:"))
            assertEquals(Hail.fingerprint(n.talk(s)), Hail.fingerprint(n.talk(GameState.fromJson(s.toJson()))), n.id)
    }

    @Test
    fun `briefly on coming near, once again, then only after going off`() {
        val s = state()
        s.place = Place("elder", 7, 4, Facing.UP)
        val aldric = npc("elder", "aldric")
        s.flags += MapMarks.met("aldric")
        Hail.heard(s, aldric, after = false)
        s.flags += Story.QUEST_STARTED
        assertTrue(Hail.news(s, aldric))
        val g = Game(s, Lang.DE)
        g.update(10_000)
        assertTrue(g.hailing(aldric))
        g.update(10_000 + Hail.SHOW_MS + 100)
        assertFalse(g.hailing(aldric))
        g.update(10_000 + Hail.AGAIN_MS + 100)
        assertTrue(g.hailing(aldric), "once again")
        g.update(10_000 + Hail.AGAIN_MS + Hail.SHOW_MS + 100)
        assertFalse(g.hailing(aldric))
        g.update(30_000)
        assertFalse(g.hailing(aldric), "not again while the hero stays")
    }

    @Test
    fun `306 keeps still for the hail only until the second sign is over`() {
        val s = state()
        s.place = Place("elder", 7, 4, Facing.UP)
        val aldric = npc("elder", "aldric")
        s.flags += MapMarks.met("aldric")
        Hail.heard(s, aldric, after = false)
        s.flags += Story.QUEST_STARTED
        val g = Game(s, Lang.DE)
        g.update(10_000)
        assertTrue(g.hailCalms(aldric))
        g.update(10_000 + Hail.AGAIN_MS + Hail.SHOW_MS - 100)
        assertTrue(g.hailCalms(aldric), "still with the second sign")
        g.update(10_000 + Hail.AGAIN_MS + Hail.SHOW_MS + 100)
        assertFalse(g.hailCalms(aldric), "back to the work while the hero stays")
        assertTrue(g.hailAge(aldric) != null, "the hail stays known: no third sign")
        g.update(10_000 + de.bornim.core.art.MapFolk.BORED_MS + 100)
        assertFalse(g.hailCalms(aldric), "a hero standing still is ignored after 10 s, as by everyone")
    }

    @Test
    fun `134_2 the gesture plays with the sign, both times, and ends at rest`() {
        val s = state()
        s.place = Place("elder", 7, 4, Facing.UP)
        val aldric = npc("elder", "aldric")
        s.flags += MapMarks.met("aldric")
        Hail.heard(s, aldric, after = false)
        s.flags += Story.QUEST_STARTED
        val g = Game(s, Lang.DE)
        g.update(10_000)
        val f = de.bornim.core.art.MapFolk.of("aldric")!!
        fun gesture() = g.hailAge(aldric)?.let { Hail.gestureMs(it) }?.let { de.bornim.core.art.MapFolk.gestureAt(f, it) }
        g.update(10_000 + 400)
        assertEquals(de.bornim.core.art.MapFolk.GPose.UP, gesture()?.main, "staff raised with the sign")
        g.update(10_000 + Hail.SHOW_MS + 100)
        assertEquals(null, gesture())
        g.update(10_000 + Hail.AGAIN_MS + 400)
        assertEquals(de.bornim.core.art.MapFolk.GPose.UP, gesture()?.main, "once again")
        g.update(30_000)
        assertEquals(null, gesture())
        // everyone on the maps: a gesture of their own, over before the sign goes, from rest back to rest
        for (m in World.maps.values) for (n in m.npcs) {
            val who = de.bornim.core.art.MapFolk.of(n.id) ?: continue
            val len = de.bornim.core.art.MapFolk.gestureMs(de.bornim.core.art.MapFolk.gesture(who))
            assertTrue(len in 600 until Hail.SHOW_MS, "${n.id}: $len ms")
            assertEquals(de.bornim.core.art.MapFolk.GPose.REST, de.bornim.core.art.MapFolk.gestureAt(who, 0)?.main, n.id)
            assertEquals(null, de.bornim.core.art.MapFolk.gestureAt(who, len), n.id)
        }
    }
    @Test
    fun `134_3 a short call with the sign, once, in a voice of their own`() {
        val s = state()
        s.place = Place("elder", 7, 4, Facing.UP)
        val aldric = npc("elder", "aldric")
        s.flags += MapMarks.met("aldric")
        Hail.heard(s, aldric, after = false)
        s.flags += Story.QUEST_STARTED
        val g = Game(s, Lang.DE)
        fun calls() = g.placedSounds.count { it.first == de.bornim.core.audio.Sound.HAIL_MAN }.also { g.placedSounds.clear() }
        g.update(10_000)
        assertTrue(g.hailing(aldric))
        assertEquals(1, calls(), "one call with the sign")
        g.update(10_000 + Hail.AGAIN_MS + 400)
        assertTrue(g.hailing(aldric))
        assertEquals(0, calls(), "the sign again, but no second call")
        assertEquals(de.bornim.core.audio.Sound.HAIL_WOMAN, Hail.voice("rowena"))
        assertEquals(de.bornim.core.audio.Sound.HAIL_CHILD, Hail.voice("pim"))
        assertEquals(de.bornim.core.audio.Sound.HAIL_MAN, Hail.voice("borin"))
        assertEquals(null, Hail.voice("grak"))
        // everyone who can hail has a voice
        for (m in World.maps.values) for (n in m.npcs) if (!n.look.startsWith("monster:")) assertTrue(Hail.voice(n.id) != null, n.id)
    }
}
