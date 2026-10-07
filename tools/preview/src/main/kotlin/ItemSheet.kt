package preview

import de.bornim.core.GearBases
import de.bornim.core.Rarity
import de.bornim.core.art.IconArt
import de.bornim.core.art.ItemArt
import de.bornim.core.art.PixelImage
import java.awt.Color
import java.awt.Font
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Every piece of gear: its old drawn icon beside its picture built from the solids, common and rare. */
fun renderItemSheet() {
    val scale = 4
    val cell = 32 * scale + 12
    val cols = 4
    val bases = GearBases.all
    val rows = (bases.size + cols - 1) / cols
    val colW = cell * 3 + 20
    val rowH = cell + 22
    val img = BufferedImage(colW * cols, rowH * rows, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics()
    g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
    g.font = Font("SansSerif", Font.PLAIN, 14)
    fun put(p: PixelImage, ox: Int, oy: Int) {
        g.color = Color(0xE9E3D3); g.fillRect(ox, oy, cell - 6, cell - 6)
        val s = (cell - 18) / p.width
        for (y in 0 until p.height) for (x in 0 until p.width) {
            val v = p[x, y]; if ((v ushr 24) < 128) continue
            g.color = Color(v, true); g.fillRect(ox + 6 + x * s, oy + 6 + y * s, s, s)
        }
    }
    for ((i, b) in bases.withIndex()) {
        val ox = (i % cols) * colW; val oy = (i / cols) * rowH
        put(IconArt.get(b.icon), ox + 4, oy + 4)
        put(ItemArt.get(b.id, Rarity.COMMON), ox + 4 + cell, oy + 4)
        put(ItemArt.get(b.id, Rarity.RARE), ox + 4 + cell * 2, oy + 4)
        g.color = Color(0xE9E3D3); g.drawString(b.de, ox + 6, oy + cell + 14)
    }
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/item_sheet.png"))
    println("wrote item_sheet")
}
