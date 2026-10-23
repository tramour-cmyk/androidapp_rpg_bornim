package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.test.Test
import kotlin.test.assertTrue

/** 320 (2) (Chef 23.10., 09:17 „Axtblatt gedreht … eine Hand nicht an der Axt“): Grak's heavy blow keeps both hands on the haft and lands edge first. */
class GrakGripTest {
    @Test
    fun heavyBlowKeepsBothHandsOnTheHaftAndLandsEdgeFirst() {
        val id = "hobgoblin_captain"
        for (seed in 0..2) {
            val look = MonsterLook(seed)
            val doll = FoeArt.doll(id, look); val o = FoeArt.outfit(id, look)
            val seq = FoeArt.sequence(id, look, Act.ATTACK, 1)
            var prev: P3? = null
            for ((i, rig) in seq.rigs.withIndex()) {
                val sk = doll.fit(rig, o).first
                val w = sk.weapon
                val d = sk.hand(0) - sk.hand(1)
                val off = (d - w * (d dot w)).len()
                // the free hand's middle sits a little off the haft, as at rest (about 7); 12 was a hand beside it
                assertTrue(off < 7.5, "seed $seed frame $i: the free hand ${"%.1f".format(off)} cm off the haft")
                if (i == seq.strike) {
                    val lead = (w - prev!!).let { (it - w * (it dot w)).norm() }
                    assertTrue(sk.edge dot lead > 0.8, "seed $seed: the edge does not lead the blow (${"%.2f".format(sk.edge dot lead)})")
                }
                prev = w
            }
        }
    }
}
