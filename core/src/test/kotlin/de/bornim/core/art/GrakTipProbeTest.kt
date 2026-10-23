package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.test.Test

class GrakTipProbeTest {
    @Test
    fun tips() {
        for (id in listOf("hobgoblin_captain", "goblin", "skeleton")) for (v in 0..2) {
            val (tx, ty) = FoeArt.tip(id, MonsterLook(0), v)
            val (ox, oy) = FoeArt.lungeOffset(id, MonsterLook(0), v, 0.0, 0.0, -150.0, -60.0)
            println("TIP $id v$v tipAboveFeet=${"%.1f".format(FoeArt.ground(id) - ty)} tipX=${"%.1f".format(tx - FoeArt.ANCHOR_X)} oy=${"%.1f".format(oy)} height=${FoeArt.height(id)}")
        }
    }
}
