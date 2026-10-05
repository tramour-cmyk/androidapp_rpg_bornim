package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.World
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Renders a whole map (ground and objects, no characters) at 1:1 pixel size for an overview. */
fun renderMapOverview(mapId: String, file: String) {
    val map = World[mapId]
    val state = GameState.newGame("X", Race.HUMAN, CharClass.FIGHTER)
    val T = WorldArt.T
    val out = BufferedImage(map.width * T, map.height * T, BufferedImage.TYPE_INT_ARGB)
    fun put(img: PixelImage, ox: Int, oy: Int) {
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val px = ox + x; val py = oy + y
            if (px !in 0 until out.width || py !in 0 until out.height) continue
            val c = img[x, y]
            val a = (c ushr 24) and 0xFF
            if (a == 0) continue
            if (a == 255) { out.setRGB(px, py, c); continue }
            val d = out.getRGB(px, py)
            fun ch(s: Int) = (((c shr s) and 0xFF) * a + ((d shr s) and 0xFF) * (255 - a)) / 255
            out.setRGB(px, py, (0xFF shl 24) or (ch(16) shl 16) or (ch(8) shl 8) or ch(0))
        }
    }
    for (ty in 0 until map.height) for (tx in 0 until map.width) put(WorldArt.ground(map, tx, ty, state, 0), tx * T, ty * T)
    for (o in WorldArt.objects(map, state, 0).sortedBy { it.sortY }) put(o.img, o.x, o.y)
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/$file.png"))
    println("wrote $file")
}
