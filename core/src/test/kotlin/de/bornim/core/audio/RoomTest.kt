package de.bornim.core.audio

import de.bornim.core.audio.PlaceSound.Kind
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertSame
import kotlin.test.assertTrue

/** Raumklang (119): the cave rings on longest, the inn stays short and muffled, outside is dry; nothing clips. */
class RoomTest {
    private val rate = 44100

    /** A short knock: a decaying noise burst of 50 ms, like a blow. */
    private fun knock(): DoubleArray {
        val r = kotlin.random.Random(7)
        return DoubleArray(rate / 2) { i -> if (i < rate / 20) (r.nextDouble() * 2 - 1) * 0.8 * (1 - i / (rate / 20.0)) else 0.0 }
    }

    private fun heard(kind: Kind) = Room.process(knock(), rate, Room.acoustics(kind)!!)

    @Test
    fun outsideIsDry() {
        val pcm = ShortArray(100) { (it * 300).toShort() }
        assertSame(pcm, Room.apply(pcm, rate, Kind.OUTSIDE))
        assertTrue(Room.soundsFor(Kind.OUTSIDE).isEmpty())
    }

    @Test
    fun caveRingsLongerThanHallThanInn() {
        // level 0.4 s after the knock is over
        val at = 0.45
        val cave = Room.levelDb(heard(Kind.CAVE), rate, at, 0.1)
        val hall = Room.levelDb(heard(Kind.HALL), rate, at, 0.1)
        val inn = Room.levelDb(heard(Kind.TAVERN), rate, at, 0.1)
        assertTrue(cave > hall && hall > inn, "Höhle $cave, Halle $hall, Schänke $inn dB")
        // the inn's tail is gone (below -60 dB) after half a second, the cave's still heard (above -45 dB)
        assertTrue(inn < -60, "Schänke klingt noch: $inn dB")
        assertTrue(cave > -45, "Höhle zu kurz: $cave dB")
    }

    @Test
    fun innIsMuffled() {
        // the share of the highs (difference between neighbours) is smaller in the inn than in the dry sound
        fun bright(x: DoubleArray, n: Int): Double { var d = 0.0; var e = 0.0; for (i in 1 until n) { d += abs(x[i] - x[i - 1]); e += abs(x[i]) }; return d / e }
        val n = rate / 20
        assertTrue(bright(heard(Kind.TAVERN), n) < bright(knock(), n) * 0.9)
    }

    @Test
    fun neverClipsNorDrownsTheSound() {
        for (k in Kind.entries) {
            val a = Room.acoustics(k) ?: continue
            val out = Room.process(knock(), rate, a)
            assertTrue(out.maxOf { abs(it) } <= Room.LIMIT + 1e-9, "$k übersteuert")
            // the blow itself stays about as loud as dry (within 3 dB; the inn takes off some highs): the room adds space, it does not push the sound back
            val dry = Room.levelDb(knock(), rate, 0.0, 0.03); val wet = Room.levelDb(out, rate, 0.0, 0.03)
            assertTrue(wet > dry - 3, "$k: Schlag $wet dB statt $dry dB")
        }
        // and a sound at full scale does not clip
        val loud = ShortArray(4000) { if (it % 40 < 20) 32767 else -32768 }
        val out = Room.apply(loud, rate, Kind.CAVE)
        assertTrue(out.size > loud.size)
        assertTrue(out.all { it in -32440..32440 })
    }

    @Test
    fun whatTakesOnTheRoom() {
        // what happens there: blows, spells, coins, the door, the people's cups in the inn
        for (s in listOf(Sound.HIT_SLASH, Sound.BLOCK, Sound.MAGIC, Sound.COINS, Sound.DOOR, Sound.CHEST)) assertTrue(Room.affects(s), "$s")
        // system sounds once and the same everywhere; ambience and steps carry their place already
        for (s in Sfx.SYSTEM + listOf(Sound.WIND, Sound.DRIP, Sound.CRACKLE, Sound.STEP_STONE, Sound.STEP_WOOD, Sound.HEARTBEAT)) assertTrue(!Room.affects(s), "$s")
        // cups and chairs only in houses
        assertTrue(Sound.CUP in Room.soundsFor(Kind.TAVERN))
        assertTrue(Sound.CUP !in Room.soundsFor(Kind.CAVE))
        assertEquals(Room.soundsFor(Kind.CAVE).toSet(), Room.soundsFor(Kind.HALL).toSet())
    }

    @Test
    fun everyRoomVersionIsThere() {
        val assets = java.io.File("../app/src/main/assets")
        val want = Room.ROOMS.flatMap { k -> Room.recordingsFor(k).map { Room.file(k, it) } }.toSet()
        val missing = want.filterNot { java.io.File(assets, it).isFile }
        assertTrue(missing.isEmpty(), "fehlende Raumfassungen (RAUMKLANG=spiel): $missing")
        val have = java.io.File(assets, "raum").walk().filter { it.isFile }.map { it.relativeTo(assets).path }.toSet()
        assertTrue((have - want).isEmpty(), "Raumfassungen ohne Verwendung: ${have - want}")
    }
}
