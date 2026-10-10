package de.bornim.core.art

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Gear
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.Rarity
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * Every blow of the hero lands in the foe (19): placed as the battle places them, the weapon's point and the blade a
 * little back from it lie inside the foe's body in the picture the blow lands on, for every weapon, foe size and scene
 * height (a blow rising from below may come up out of the ground in front of a flat foe: 3 pixels below its feet
 * still count), and the hero stands on the near side of it, not inside it.
 */
class HitReachTest {
    @Test
    fun everyBlowLandsInTheFoe() {
        val weapons = listOf("longsword", "greataxe", "mace", "dagger", "spear", "quarterstaff", "warhammer", "scimitar")
        val foes = listOf("goblin", "skeleton", "bugbear", "wolf", "giant_rat", "giant_spider")
        val sceneW = BattleScene.DESIGN_W.toDouble()
        val bad = mutableListOf<String>()
        for (w in weapons) {
            val hero = GameState.newGame("Test", Race.HUMAN, CharClass.FIGHTER).hero
            hero.equip(Gear(9_999L, w, Rarity.COMMON, 1))
            val strikes = (HeroBattle.strikes(hero) + HeroBattle.killStrikes(hero)).filter { it != HeroFigure.Strike.SHOOT }
            for (id in foes) {
                val look = MonsterLook(0)
                val pic = MonsterArt.battleFrame(id, look, Act.IDLE, 0, 0)
                val (foeW, tall) = MonsterArt.bodySize(id, look, pic.width, pic.height)
                for (sceneH in listOf(380.0, 434.0, 520.0)) {
                    val fx = sceneW * BattleScene.FOE_X; val fy = sceneH * BattleScene.FOE_Y
                    val hx = sceneW * BattleScene.HERO_X; val hy = sceneH * BattleScene.HERO_Y
                    for (s in strikes) {
                        val aim = HeroBattle.aimAt(fx, fy, foeW, tall)
                        val (ox, oy) = HeroBattle.lungeOffset(hero, s, hx, hy, aim.first, aim.second)
                        val hit = HeroBattle.strikeFrame(s)
                        // at the hit the hero has stepped all the way in and is drawn LUNGE_SCALE as large round the feet
                        fun scene(p: Pair<Double, Double>) = Pair(hx + ox + (p.first - HeroBattle.ANCHOR_X) * HeroBattle.LUNGE_SCALE,
                            hy + oy + (p.second - HeroBattle.GROUND) * HeroBattle.LUNGE_SCALE)
                        val tip = scene(HeroBattle.tipAt(hero, s, hit)); val grip = scene(HeroBattle.gripAt(hero, s, hit))
                        val back = Pair(tip.first + (grip.first - tip.first) * 0.25, tip.second + (grip.second - tip.second) * 0.25)
                        fun inside(p: Pair<Double, Double>) = p.first in fx - foeW * 0.5..fx + foeW * 0.5 && p.second in fy - tall..fy + 3.0
                        val points = listOf(tip, back)
                        // the hero stands before the foe, not in it: its feet on the near side of the foe's body
                        if (hx + ox > fx - foeW * 0.3) bad += "$w $id h$sceneH $s: Held steht im Gegner (Füße x ${(hx + ox).toInt()}, Gegner ab ${(fx - foeW * 0.3).toInt()})"
                        if (!points.all(::inside)) bad += "$w $id h$sceneH $s: Spitze ${tip.fmt()} Klinge ${back.fmt()} Körper x ${(fx - foeW / 2).toInt()}..${(fx + foeW / 2).toInt()} y ${(fy - tall).toInt()}..${fy.toInt()}"
                    }
                }
            }
        }
        assertTrue(bad.isEmpty(), "${bad.size} Schläge treffen nicht in den Körper:\n" + bad.joinToString("\n"))
    }

    /** All a hero's frames of a fight are kept at once, so none is gone again when it comes to be shown (19.5). */
    @Test
    fun allFramesOfAFightAreKept() {
        val bad = mutableListOf<String>()
        for (cls in CharClass.entries) for (w in listOf(null, "longsword", "greataxe", "mace", "dagger", "spear", "quarterstaff", "longbow", "light_crossbow")) {
            val hero = GameState.newGame("Test", Race.HUMAN, cls).hero
            w?.let { hero.equip(Gear(9_999L, it, Rarity.COMMON, 1)) }
            for (foe in listOf("goblin", "wolf", "skeleton")) {
                val n = HeroBattle.planFrames(hero, foe)
                if (n > HeroBattle.MOST_FRAMES) bad += "$cls $w $foe: $n Bilder"
            }
        }
        assertTrue(bad.isEmpty(), "mehr als ${HeroBattle.MOST_FRAMES} Bilder:\n" + bad.joinToString("\n"))
    }

    private fun Pair<Double, Double>.fmt() = "(${first.toInt()}, ${second.toInt()})"
}
