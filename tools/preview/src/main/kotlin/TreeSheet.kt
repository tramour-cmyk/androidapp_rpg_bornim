package preview

import de.bornim.core.art.MapFlora
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * The trees side by side on grass (27.4): the upper row as they are, the lower one with volume.
 * TREESHEET=1, scaled ×2, written to build/screens/baeume.png.
 */
fun renderTreeSheet() {
    fun row(): List<MapFlora.Sprite> = listOf(
        MapFlora.oak(0, 2, false), MapFlora.oak(1, 1, false), MapFlora.oak(3, 2, false), MapFlora.oak(5, 0, true),
        MapFlora.spruce(0, 2), MapFlora.spruce(3, 1), MapFlora.spruce(1, 0, young = true), MapFlora.deadTree(0), MapFlora.deadTree(2),
    )
    MapFlora.treeDraft = false; val old = row()
    MapFlora.treeDraft = true; val new = row()
    val k = 2
    val cellW = old.zip(new).sumOf { (a, b) -> maxOf(a.img.width, b.img.width) } + 8 * old.size
    val rowH = maxOf(old.maxOf { it.img.height }, new.maxOf { it.img.height }) + 24
    val out = BufferedImage(cellW * k, rowH * 2 * k, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until out.height) for (x in 0 until out.width) out.setRGB(x, y, if ((x / 7 + y / 5) % 9 == 0) 0x2E4224 else 0x34492A)
    for ((r, list) in listOf(old, new).withIndex()) {
        var ox = 4
        for ((i, s) in list.withIndex()) {
            val cw = maxOf(old[i].img.width, new[i].img.width)
            val bx = ox + cw / 2 - s.ax; val by = rowH * (r + 1) - 16 - s.ay
            for (y in 0 until s.img.height) for (x in 0 until s.img.width) {
                val c = s.img[x, y]; val a = (c ushr 24) and 0xFF
                if (a < 128) continue
                for (dy in 0 until k) for (dx in 0 until k) {
                    val px = (bx + x) * k + dx; val py = (by + y) * k + dy
                    if (px in 0 until out.width && py in 0 until out.height) out.setRGB(px, py, c and 0xFFFFFF)
                }
            }
            ox += cw + 8
        }
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/baeume.png"))
    println("build/screens/baeume.png")
}
