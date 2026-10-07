package preview

import de.bornim.core.GearBases
import de.bornim.core.Rarity
import de.bornim.core.art.IconArt
import de.bornim.core.art.ItemArt
import de.bornim.core.art.PixelImage
import java.awt.Color
import java.awt.Font
import java.awt.Graphics2D
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

private fun Graphics2D.put(p: PixelImage, ox: Int, oy: Int, cell: Int) {
    color = Color(0xE9E3D3); fillRect(ox, oy, cell - 6, cell - 6)
    val s = (cell - 18) / p.width
    for (y in 0 until p.height) for (x in 0 until p.width) {
        val v = p[x, y]; val a = v ushr 24; if (a == 0) continue
        val bg = 0xE9E3D3
        fun ch(sh: Int) = (((v shr sh) and 0xFF) * a + ((bg shr sh) and 0xFF) * (255 - a)) / 255
        color = Color(ch(16), ch(8), ch(0)); fillRect(ox + 6 + x * s, oy + 6 + y * s, s, s)
    }
}

/** Every piece of gear: its old drawn icon beside its picture built from the solids, common and rare; and the rarity marks. */
fun renderItemSheet() {
    val cell = 32 * 4 + 12
    run {
        val cols = 4
        val bases = GearBases.all
        val rows = (bases.size + cols - 1) / cols
        val colW = cell * 3 + 20
        val rowH = cell + 22
        val img = BufferedImage(colW * cols, rowH * rows, BufferedImage.TYPE_INT_ARGB)
        val g = img.createGraphics()
        g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
        g.font = Font("SansSerif", Font.PLAIN, 14)
        for ((i, b) in bases.withIndex()) {
            val ox = (i % cols) * colW; val oy = (i / cols) * rowH
            g.put(IconArt.get(b.icon), ox + 4, oy + 4, cell)
            g.put(ItemArt.get(b.id, Rarity.COMMON), ox + 4 + cell, oy + 4, cell)
            g.put(ItemArt.get(b.id, Rarity.RARE), ox + 4 + cell * 2, oy + 4, cell)
            g.color = Color(0xE9E3D3); g.drawString(b.de, ox + 6, oy + cell + 14)
        }
        File("build/screens").mkdirs()
        ImageIO.write(img, "png", File("build/screens/item_sheet.png"))
    }
    run {
        val items = listOf("longsword", "round_shield", "quarterstaff", "chain_shirt", "light_crossbow", "ring")
        val marks = ItemArt.Mark.entries
        val small = 32 * 3 + 12
        val blockW = small * Rarity.entries.size + 24
        val img = BufferedImage(130 + blockW * marks.size, 56 + small * items.size, BufferedImage.TYPE_INT_ARGB)
        val g = img.createGraphics()
        g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
        for ((mi, _) in marks.withIndex()) {
            val ox = 130 + mi * blockW
            g.font = Font("SansSerif", Font.BOLD, 16); g.color = Color(0xE9E3D3); g.drawString("Variante ${"ABC"[mi]}", ox + 4, 18)
            g.font = Font("SansSerif", Font.PLAIN, 11)
            for ((ri, r) in Rarity.entries.withIndex()) { g.color = Color(r.color.toInt()); g.drawString(r.title.de, ox + ri * small + 4, 44) }
            for ((ii, id) in items.withIndex()) for ((ri, r) in Rarity.entries.withIndex())
                g.put(ItemArt.get(id, r, marks[mi]), ox + ri * small, 52 + ii * small, small)
        }
        g.font = Font("SansSerif", Font.PLAIN, 14)
        for ((ii, id) in items.withIndex()) { g.color = Color(0xE9E3D3); g.drawString(GearBases[id].de, 6, 52 + ii * small + small / 2) }
        ImageIO.write(img, "png", File("build/screens/item_rarity.png"))
    }
    println("wrote item sheets")
}

/** The crossbow held up in many ways, to find the one that reads best. */
fun renderCrossbowProbe() {
    val small = 32 * 4 + 12
    val V = de.bornim.core.art.HeroFigure::V
    val dirs = listOf(V(-1.0, 0.0, -1.0), V(-1.0, 0.0, 1.0), V(-1.0, 0.2, -1.0), V(-1.0, 0.2, 1.0))
    val views = listOf(0.0 to 60.0, 0.0 to 72.0, 0.0 to 82.0, 15.0 to 72.0, -15.0 to 72.0)
    val img = BufferedImage(small * views.size, small * dirs.size, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics()
    for ((di, d) in dirs.withIndex()) for ((vi, v) in views.withIndex()) {
        val rig = de.bornim.core.art.HeroFigure.Rig(rh = de.bornim.core.art.HeroFigure.V(-4.0, 95.0, 25.0), weapon = d, aim = 1.0, grip = 10.0, draw = if (vi % 2 == 0) 1.0 else 0.0)
        g.put(ItemArt.probe("light_crossbow", rig, v.first, v.second), vi * small, di * small, small)
    }
    ImageIO.write(img, "png", File("build/screens/crossbow_probe.png"))
    println("wrote crossbow probe")
}
