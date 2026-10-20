package de.bornim.core.art

import de.bornim.core.MonsterLook
import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * 211.17 (Chef 20.10., 07:34: wolves and boar did not reach the hero in the classic fight): the snout the bite's lunge
 * is reckoned for lies on the animal in the frame the bite lands on, seen by the fight's camera as well as without it.
 */
class BeastBiteTest {
    @Test
    fun theLungeIsReckonedForTheSnoutInThePicture() {
        val bad = mutableListOf<String>()
        try {
            for (on in listOf(true, false)) {
                FightCamera.see(on)
                for (id in BeastArt.KINDS) for (variant in 0..2) for (seed in listOf(0, 3)) {
                    val look = MonsterLook(seed)
                    val (tx, ty) = BeastArt.tip(id, look, variant)
                    val img = BeastArt.frame(id, look, Act.ATTACK, variant, BeastArt.sequence(id, Act.ATTACK, variant).strike)
                    var near = Double.MAX_VALUE
                    for (y in 0 until img.height) for (x in 0 until img.width) if (img.opaque(x, y)) near = minOf(near, hypot(x + img.ox - tx, y + img.oy - ty))
                    if (near > 4.0) bad += "${if (on) "Kamera" else "alt"} $id Variante $variant Muster $seed: Schnauze ${tx.toInt()},${ty.toInt()} ${near.toInt()} Pixel neben dem Tier"
                }
            }
        } finally { FightCamera.see(true) }
        assertTrue(bad.isEmpty(), bad.joinToString("\n"))
    }
}
