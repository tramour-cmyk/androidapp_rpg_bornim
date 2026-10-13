package de.bornim.core

import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.test.Test

/** Renders preview sheets of all art into build/preview so it can be inspected without a device. */
class ArtPreviewTest {
    private val out = File("build/preview").apply { mkdirs() }

    private fun BufferedImage.blit(img: PixelImage, ox: Int, oy: Int, scale: Int) {
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val c = img[x, y]
            if ((c ushr 24) == 0) continue
            for (sy in 0 until scale) for (sx in 0 until scale) {
                val px = ox + x * scale + sx; val py = oy + y * scale + sy
                if (px in 0 until width && py in 0 until height) {
                    val a = c ushr 24
                    setRGB(px, py, if (a == 255) c else de.bornim.core.art.mix(getRGB(px, py), c or (0xFF shl 24), a / 255.0))
                }
            }
        }
    }

    private fun canvas(w: Int, h: Int) = BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB).apply {
        for (y in 0 until h) for (x in 0 until w) setRGB(x, y, 0xFF303040.toInt())
    }

    @Test
    fun sheet() {
        val s = 3
        val img = canvas(1500, 760)
        var y = 0
        CharClass.entries.forEachIndexed { ci, cls ->
            Race.entries.forEachIndexed { ri, race ->
                Facing.entries.forEachIndexed { fi, f ->
                    img.blit(CharacterArt.hero(race, cls, f, 0), (ri * 4 + fi) * 68, y + ci * 68, 2)
                }
            }
        }
        y += 4 * 68 + 10
        CharacterArt.npcLooks.keys.forEachIndexed { i, look ->
            img.blit(CharacterArt.npc(look, Facing.DOWN), i * 34 * 2, y, 2)
        }
        y += 80
        Icon.entries.forEachIndexed { i, icon -> img.blit(IconArt.get(icon), i * 34 * 2, y, 2) }
        ImageIO.write(img, "png", File(out, "sheet.png"))

        val m = canvas(9 * 66 * 3, 66 * 3)
        Monsters.all.forEachIndexed { i, mon -> m.blit(MonsterArt.get(mon.id), i * 66 * 3, 3, 3) }
        ImageIO.write(m, "png", File(out, "monsters.png"))
    }

    @Test
    fun battleBackdrops() {
        for (kind in listOf(MapKind.FOREST, MapKind.CAVE)) {
            val bg = de.bornim.core.art.BattleArt.background(kind, 180, 200)
            val img = canvas(180 * 3, 200 * 3)
            img.blit(bg, 0, 0, 3)
            ImageIO.write(img, "png", File(out, "battle_${kind}.png"))
        }
    }
}
