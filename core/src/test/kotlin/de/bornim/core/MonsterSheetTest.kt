package de.bornim.core

import de.bornim.core.art.MonsterArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.Pose
import de.bornim.core.art.mix
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.test.Test
import kotlin.test.assertTrue

/** Renders every monster in all poses and a few variants into build/preview/monsters.png. */
class MonsterSheetTest {
    private fun BufferedImage.blit(img: PixelImage, ox: Int, oy: Int, scale: Int) {
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val c = img[x, y]
            val a = c ushr 24
            if (a == 0) continue
            for (sy in 0 until scale) for (sx in 0 until scale) {
                val px = ox + x * scale + sx; val py = oy + y * scale + sy
                if (px in 0 until width && py in 0 until height) setRGB(px, py, if (a == 255) c else mix(getRGB(px, py), c or (0xFF shl 24), a / 255.0))
            }
        }
    }

    @Test
    fun sheet() {
        val ids = (System.getenv("MONSTERS")?.split(",") ?: (Monsters.all.map { it.id } + listOf(
            "boar", "stirge", "giant_centipede", "kobold", "ghoul", "giant_bat", "ochre_jelly", "goblin_shaman",
        )).distinct())
        val scale = (System.getenv("SCALE") ?: "3").toInt()
        val cell = 64 * scale + 6
        val looks = listOf(MonsterLook(0), MonsterLook(1), MonsterLook(2), MonsterLook(3), MonsterLook(7, shiny = true), MonsterLook(5, glow = 0xFFFF4040.toInt()))
        val cols = 4 + 2 + looks.size - 1
        val img = BufferedImage(cols * cell, ids.size * cell, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until img.height) for (x in 0 until img.width) img.setRGB(x, y, if ((x / cell + y / cell) % 2 == 0) 0xFF7CB060.toInt() else 0xFF6A6A78.toInt())
        ids.forEachIndexed { r, id ->
            for (f in 0 until 4) img.blit(MonsterArt.frame(id, looks[0], Pose.IDLE, f), f * cell, r * cell, scale)
            img.blit(MonsterArt.frame(id, looks[0], Pose.ATTACK), 4 * cell, r * cell, scale)
            img.blit(MonsterArt.frame(id, looks[0], Pose.HURT), 5 * cell, r * cell, scale)
            for (i in 1 until looks.size) img.blit(MonsterArt.frame(id, looks[i], Pose.IDLE, 0), (5 + i) * cell, r * cell, scale)
        }
        val out = File("build/preview").apply { mkdirs() }
        ImageIO.write(img, "png", File(out, System.getenv("SHEET") ?: "monsters.png"))
        assertTrue(true)
    }

    @Test
    fun heroSheet() {
        val scale = 3
        val cell = 64 * scale + 6
        val rows = mutableListOf<List<PixelImage>>()
        val races = Race.entries
        CharClass.entries.forEachIndexed { ci, cls ->
            for (geared in listOf(0, 1, 2)) {
                val s = GameState.newGame("X", races[(ci + geared) % races.size], cls)
                if (geared > 0) {
                    s.hero.gainXp(Rules.xpForLevel[12])
                    val dice = Dice(kotlin.random.Random(ci * 7 + geared))
                    for (slot in GearSlot.entries) {
                        if (slot == GearSlot.OFF_HAND && s.hero.weapon?.def?.twoHanded == true) continue
                        val r = Rarity.entries[(slot.ordinal + geared * 2 + ci) % Rarity.entries.size]
                        repeat(20) {
                            val g = Loot.generate(s, dice, 12, r, cls, slot)
                            if (s.hero.item(slot) == null && s.hero.canWear(g)) s.equipFromBag(s.addGear(g))
                        }
                    }
                }
                rows += listOf(
                    de.bornim.core.art.HeroArt.battle(s.hero, Pose.IDLE, 0),
                    de.bornim.core.art.HeroArt.battle(s.hero, Pose.IDLE, 1),
                    de.bornim.core.art.HeroArt.battle(s.hero, Pose.ATTACK),
                    de.bornim.core.art.HeroArt.battle(s.hero, Pose.HURT),
                )
            }
        }
        val img = BufferedImage(3 * 4 * cell, 4 * cell, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until img.height) for (x in 0 until img.width) img.setRGB(x, y, if ((x / cell + y / cell) % 2 == 0) 0xFF7CB060.toInt() else 0xFF6A6A78.toInt())
        rows.forEachIndexed { i, r -> r.forEachIndexed { j, p -> img.blit(p, ((i % 3) * 4 + j) * cell, (i / 3) * cell, scale) } }
        ImageIO.write(img, "png", File(File("build/preview").apply { mkdirs() }, "heroes.png"))
    }
}
