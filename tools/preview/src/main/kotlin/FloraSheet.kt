package preview

import de.bornim.core.World
import de.bornim.core.art.MapFlora
import de.bornim.core.art.MapGround
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * A part of a wood at full art resolution, straight from the map art (no screen around it):
 * the new ground, the shadows and the trees, rocks and undergrowth. FLORA=map:x0:y0:w:h (tiles).
 */
fun renderFloraSheet(spec: String) {
    val p = spec.split(":")
    val map = World[p[0]]
    val x0 = p.getOrElse(1) { "0" }.toInt(); val y0 = p.getOrElse(2) { "0" }.toInt()
    val tw = p.getOrElse(3) { "${map.width}" }.toInt(); val th = p.getOrElse(4) { "${map.height}" }.toInt()
    val S = MapGround.S; val D = MapGround.D; val T = WorldArt.T
    MapGround.prepareNow(map)
    val w = tw * S; val h = th * S
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    fun blend(img: PixelImage, ax: Int, ay: Int, k: Int) {
        // [k]: how many art pixels each image pixel covers (1 for the new pictures, 2 for old ones)
        for (y in 0 until img.height * k) for (x in 0 until img.width * k) {
            val px = ax + x - x0 * S; val py = ay + y - y0 * S
            if (px !in 0 until w || py !in 0 until h) continue
            val c = img[x / k, y / k]; val a = (c ushr 24) and 0xFF
            if (a == 0) continue
            val d = out.getRGB(px, py)
            fun ch(s: Int) = (((c shr s) and 0xFF) * a + ((d shr s) and 0xFF) * (255 - a)) / 255
            out.setRGB(px, py, (0xFF shl 24) or (ch(16) shl 16) or (ch(8) shl 8) or ch(0))
        }
    }
    val state = de.bornim.core.GameState.newGame("X", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER)
    val ch = MapGround.CH
    for (cy in 0..(map.height / ch)) for (cx in 0..(map.width / ch)) MapGround.chunk(map, cx, cy)?.let { blend(it, cx * ch * S, cy * ch * S, 1) }
    for (o in MapFlora.shadows(map)) blend(o.img, o.x * D, o.y * D, D / o.density)
    // SCHATTENNUR=1: only the shadows on the ground, the houses' footprints outlined red (89, to check the fall)
    if (System.getenv("SCHATTENNUR") != null) for ((f, _) in de.bornim.core.art.MapTownIso.houses(map)) {
        for (x in f.x * S until (f.x + f.n) * S) for (y in listOf(f.top * S, (f.y + 1) * S - 1)) if (x - x0 * S in 0 until w && y - y0 * S in 0 until h) out.setRGB(x - x0 * S, y - y0 * S, 0xFF0000)
        for (y in f.top * S until (f.y + 1) * S) for (x in listOf(f.x * S, (f.x + f.n) * S - 1)) if (x - x0 * S in 0 until w && y - y0 * S in 0 until h) out.setRGB(x - x0 * S, y - y0 * S, 0xFF0000)
    } else for (o in WorldArt.objects(map, state, 0).sortedBy { it.sortY }) blend(o.img, o.x * D, o.y * D, D / o.density)
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/flora_${p[0]}_$x0-$y0.png"))
    println("wrote flora")
}
