package de.bornim.core.art

import kotlin.test.Test
import kotlin.test.assertEquals

/** 249 (Chef 22.10., 07:29 „drei Wolfsklone“): in MARS each wolf of a pack wears its own coat. */
class PackLookTest {
    @Test fun threeWolvesThreeCoats() {
        val coats = (0 until 3).map { BeastArt.coat("wolf", MonsterArt.packLook("wolf", it)) }
        assertEquals(3, coats.toSet().size, "three wolves, three coats: $coats")
        assertEquals(4, (0 until 4).map { BeastArt.coat("wolf", MonsterArt.packLook("wolf", it)) }.toSet().size, "four of four")
        assertEquals(0, MonsterArt.packLook("goblin", 2).seed, "a goblin keeps its look (its gear comes with it)")
    }
}
