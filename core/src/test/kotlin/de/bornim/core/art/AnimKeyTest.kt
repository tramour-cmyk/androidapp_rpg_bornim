package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * 333 (Chef 23.10., 10:34): the test line names each animation so that the Chef can read it off and pass it on, and
 * we know where it is: one name stands for one list of frames, and the frames drawn carry it.
 */
class AnimKeyTest {
    private val acts = Act.entries

    @Test fun oneHeroNameOneList() {
        for (st in HeroFigure.Stance.entries) {
            val lists = HashMap<String, MutableSet<Any>>()
            for (act in HeroFigure.Act.entries) for (strike in HeroFigure.Strike.entries) for (v in 0 until 9) {
                if (act != HeroFigure.Act.ATTACK && strike != HeroFigure.Strike.SLASH) continue
                if (act == HeroFigure.Act.ATTACK && v > 1) continue
                lists.getOrPut(HeroFigure.key(act, strike, v, st)) { mutableSetOf() }.add(HeroFigure.sequence(act, strike, v, st))
            }
            val twice = lists.filterValues { it.size > 1 }.keys
            assertTrue(twice.isEmpty(), "$st: one name for different frames: $twice")
        }
        assertEquals("H-DIE-2", HeroFigure.key(HeroFigure.Act.DIE, HeroFigure.Strike.SLASH, 5))
        assertEquals("H-ATTACK-THRUST/SPEAR", HeroFigure.key(HeroFigure.Act.ATTACK, HeroFigure.Strike.THRUST, 0, HeroFigure.Stance.SPEAR))
    }

    @Test fun oneFoeNameOneList() {
        for (id in FoeArt.KINDS) for (seed in 0 until 4) {
            val look = MonsterLook(seed)
            val lists = HashMap<String, MutableSet<Any>>()
            for (act in acts) for (v in 0 until 3) lists.getOrPut(FoeArt.key(id, look, act, v)) { mutableSetOf() }.add(FoeArt.sequence(id, look, act, v).rigs)
            val twice = lists.filterValues { it.size > 1 }.keys
            assertTrue(twice.isEmpty(), "$id/$seed: one name for different frames: $twice")
        }
        for (id in listOf("wolf", "boar", "giant_rat")) {
            val lists = HashMap<String, MutableSet<Any>>()
            for (act in acts) for (v in 0 until 3) lists.getOrPut(BeastArt.key(id, act, v)) { mutableSetOf() }.add(BeastArt.sequence(id, act, v).rigs)
            assertTrue(lists.filterValues { it.size > 1 }.isEmpty(), "$id: one name for different frames")
        }
        for (id in listOf("giant_spider", "giant_centipede", "giant_bat", "stirge", "ochre_jelly")) {
            val lists = HashMap<String, MutableSet<Any>>()
            for (act in acts) for (v in 0 until 3) lists.getOrPut(VerminArt.key(id, act, v)) { mutableSetOf() }.add(VerminArt.sequence(id, act, v).rigs)
            assertTrue(lists.filterValues { it.size > 1 }.isEmpty(), "$id: one name for different frames")
        }
        assertEquals("F-GRAK-ATTACK-1", FoeArt.key("hobgoblin_captain", MonsterLook(0), Act.ATTACK, 1))
    }

    @Test fun framesCarryTheirName() {
        assertEquals("F-GRAK-ATTACK-1:7", FoeArt.cut("hobgoblin_captain", MonsterLook(0), Act.ATTACK, 1, 7).anim)
        assertEquals("B-WOLF-DIE-2:3", BeastArt.frame("wolf", MonsterLook(0), Act.DIE, 2, 3).anim)
    }
}
