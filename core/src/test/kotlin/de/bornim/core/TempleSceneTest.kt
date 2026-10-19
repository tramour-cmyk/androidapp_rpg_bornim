package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * 68: after the amulet comes home Aldric invites the hero, the chapter's end card follows, then the night (a rest), the
 * temple scene at sunrise, the hero in the temple's first row, Lyra speaking of the camp in the south, and the chronicle
 * carrying it as a task.
 */
class TempleSceneTest {
    private fun ready(): Bot {
        val state = GameState.newGame("Tester", Race.HUMAN, CharClass.FIGHTER)
        state.flags += listOf(Story.INTRO_DONE, Story.QUEST_STARTED, Story.BARRIER_OPEN, Story.GRAK_DEFEATED, Story.LYRA_RESCUED)
        state.add("sun_amulet", 1)
        state.minutes = 20 * 60
        val bot = Bot(Game(state, Lang.DE, Dice(Random(7))))
        bot.game.begin(); bot.settle()
        return bot
    }

    @Test
    fun theMorningFollowsAldricsInvitation() {
        val bot = ready(); val g = bot.game; val s = g.state
        val day = s.day
        bot.enterMap("elder")
        val npc = g.map.npcs.first { it.id == "aldric" }
        bot.approach(npc.x, npc.y)
        s.hero.hp = 1
        g.interact()
        // walk through by hand and note what comes in which order
        val seen = ArrayList<String>()
        var guard = 0
        while (g.mode != Mode.Explore) {
            check(++guard < 200)
            when (val m = g.mode) {
                is Mode.Dialog -> seen += m.text.take(30)
                Mode.ChapterEnd -> seen += "KAPITELENDE"
                Mode.TempleScene -> { seen += "TEMPEL"; assertEquals("elder", s.place.map, "the scene comes before the morning") }
                else -> seen += m::class.simpleName ?: ""
            }
            g.advance()
        }
        val invite = seen.indexOfFirst { it.startsWith("Morgen bei Sonnenaufgang") }
        val end = seen.indexOf("KAPITELENDE"); val scene = seen.indexOf("TEMPEL")
        val lyra = seen.indexOfFirst { it.startsWith("Ich verdanke dir mein Leben") }
        assertTrue(invite in 0 until end && end < scene && scene < lyra, "order: $seen")
        assertTrue(seen.drop(lyra).any { it.startsWith("Graks Leute sprachen") } && seen.drop(lyra).any { it.startsWith("Ich weiß nicht, was er") })
        // the hero stands in the temple's first row at sunrise of the next day, rested
        assertEquals(Place("temple", 4, 3, Facing.UP), s.place)
        assertTrue(World["temple"].tile(4, 3).walkable)
        assertEquals(day + 1, s.day)
        assertEquals(Game.SUNRISE_MIN, s.minutes)
        assertEquals(s.hero.maxHp, s.hero.hp)
        assertTrue(s.has(Story.CHAPTER1_DONE) && s.has(Story.TEMPLE_SEEN) && s.has(Story.CAMP_TOLD))
        assertTrue(Chronicle.openTasks(s).any { it.id == "lager" }, "the camp in the south is a task now")
    }

    /** 84.1T.1: the morning counts as a rest, so a burning spark is gone, said as the first line after waking, before Lyra. */
    @Test
    fun aBurningSparkFadesOverTheNight() {
        for (sparked in listOf(true, false)) {
            val bot = ready(); val g = bot.game; val s = g.state
            s.spark = sparked
            bot.enterMap("elder")
            val npc = g.map.npcs.first { it.id == "aldric" }
            bot.approach(npc.x, npc.y)
            g.interact()
            val seen = ArrayList<String>()
            var guard = 0
            while (g.mode != Mode.Explore) {
                check(++guard < 200)
                when (val m = g.mode) {
                    is Mode.Dialog -> seen += m.text
                    Mode.TempleScene -> seen += "TEMPEL"
                    else -> {}
                }
                g.advance()
            }
            val faded = seen.indexOf(Light.sparkFaded.de)
            if (sparked) assertEquals(seen.indexOf("TEMPEL") + 1, faded, "first line after waking: $seen")
            else assertEquals(-1, faded, "no spark, no line: $seen")
            assertTrue(!s.spark)
        }
    }

    @Test
    fun rowenaAndAldricSpeakOfTheCampAfterwards() {
        val bot = ready(); val g = bot.game; val s = g.state
        s.flags += listOf(Story.CHAPTER1_DONE, Story.TEMPLE_SEEN, Story.CAMP_TOLD)
        for ((map, who, line) in listOf(Triple("inn", "rowena", "Ein Lager im Süden?"), Triple("elder", "aldric", "Lyra hat mir vom Lager erzählt."))) {
            bot.enterMap(map)
            val npc = g.map.npcs.first { it.id == who }
            bot.approach(npc.x, npc.y)
            g.interact()
            val m = g.mode
            assertTrue(m is Mode.Dialog && m.text.startsWith(line), "$who says: $m")
            bot.settle()
        }
    }

    @Test
    fun lyraTellsItLaterIfTheMorningWasLost() {
        // the game closed during the scene (the queue is not saved) or the chapter ended before 68
        val bot = ready(); val g = bot.game; val s = g.state
        s.flags += Story.CHAPTER1_DONE
        bot.talkTo("temple", "lyra_temple")
        assertTrue(s.has(Story.CAMP_TOLD))
        assertTrue(Chronicle.openTasks(s).any { it.id == "lager" })
    }

    @Test
    fun theSceneIsAReelOfFivePaintedPictures() {
        assertEquals(5, TempleScene.pictures)
        assertEquals(-1, TempleScene.black)
        assertTrue(TempleScene.totalMs in 30_000L..40_000L)
        for (l in TempleScene.lines) assertTrue(l.de.isNotBlank() && l.en.isNotBlank())
        assertTrue(TempleScene.at(TempleScene.totalMs).done)
    }

    /** 100: the test switch puts a fresh game just before the chapter's end; talking to Aldric starts it. */
    @Test
    fun theTestSwitchLeadsToTheChaptersEnd() {
        val state = GameState.newGame("Tester", Race.HUMAN, CharClass.FIGHTER)
        val bot = Bot(Game(state, Lang.DE, Dice(Random(7))))
        val g = bot.game
        g.begin(); bot.settle()
        g.cheatChapterEnd()
        assertEquals("elder", state.place.map)
        val npc = g.map.npcs.first { it.id == "aldric" }
        bot.approach(npc.x, npc.y)
        g.interact()
        var guard = 0
        var end = false
        while (g.mode != Mode.Explore && ++guard < 200) { if (g.mode == Mode.ChapterEnd) end = true; g.advance() }
        assertTrue(end && state.has(Story.TEMPLE_SEEN), "chapter end and temple scene follow")
    }
}
