package de.bornim.core

import de.bornim.core.audio.MarsSound
import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.Recorded
import de.bornim.core.audio.Sound
import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 256: MARS sounds as the old fight: blows by weapon or bite, spells, heal, falls, voices; the boss piece only against a boss. */
class MarsSoundTest {
    private fun fight(foe: Skirmish.Companion.ProbeFoe, merc: CharClass, seed: Int): Pair<Skirmish, List<SkirmishEvent>> {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val sk = Skirmish.probe(s, merc, Lang.DE, foe, Dice(Random(seed)))
        sk.byId("merc").auto = true
        val seen = mutableListOf<SkirmishEvent>()
        sk.listener = { seen += it }
        sk.start()
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 500) {
            while (sk.pilotNext) sk.proceed()
            if (sk.outcome != Outcome.ONGOING) break
            val t = sk.targets(sk.current).firstOrNull()
            sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
        }
        return sk to seen
    }

    @Test
    fun wolvesBiteHeroesStrikeAndTheFallenSound() {
        val heard = mutableSetOf<Sound>()
        val voices = mutableSetOf<Recorded.Cue>()
        for (seed in 0 until 15) {
            val (sk, seen) = fight(Skirmish.Companion.ProbeFoe.WOLVES, CharClass.WIZARD, seed)
            assertEquals(MusicScene.BATTLE, MarsSound.music(sk))
            for (e in seen) {
                val cues = MarsSound.of(e, sk)
                heard += cues.mapNotNull { it.sound }
                voices += cues.mapNotNull { it.voice }
                // a wolf's blow that lands is a bite, as in the old fight
                if (e.damage > 0 && e.actor?.startsWith("wolf") == true && e.roll?.d20 != 20) assertTrue(cues.any { it.sound == Sound.BITE }, e.text)
                if (e.cue == SkirmishCue.FOE_FALLS) assertEquals(listOf(Sound.ENEMY_DOWN), cues.mapNotNull { it.sound })
            }
        }
        for (s in listOf(Sound.BITE, Sound.SWING, Sound.ENEMY_DOWN, Sound.FIRE, Sound.MISS)) assertTrue(s in heard, "$s in $heard")
        assertTrue(Recorded.Cue.HURT in voices && Recorded.Cue.DIE in voices && Recorded.Cue.ATTACK in voices, "$voices")
    }

    @Test
    fun grakIsTheBossPieceAndTheClericHeals() {
        val heard = mutableSetOf<Sound>()
        for (seed in 0 until 15) {
            val (sk, seen) = fight(Skirmish.Companion.ProbeFoe.GRAK, CharClass.CLERIC, seed)
            assertEquals(MusicScene.BOSS, MarsSound.music(sk))
            for (e in seen) heard += MarsSound.of(e, sk).mapNotNull { it.sound }
        }
        assertTrue(Sound.HEAL in heard || Sound.HOLY in heard, "$heard")
        assertTrue(Sound.HIT_SMASH in heard || Sound.CRIT in heard, "$heard")
    }

    @Test
    fun theSpiderPoisons() {
        val heard = mutableSetOf<Sound>()
        for (seed in 0 until 30) {
            val (sk, seen) = fight(Skirmish.Companion.ProbeFoe.SPIDER, CharClass.ROGUE, seed)
            for (e in seen) heard += MarsSound.of(e, sk).mapNotNull { it.sound }
        }
        assertTrue(Sound.POISON in heard || Sound.THROW in heard, "$heard")
    }
}
