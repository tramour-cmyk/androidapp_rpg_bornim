package preview

import de.bornim.core.World
import de.bornim.core.art.LandSheet
import de.bornim.core.art.MapSheet
import de.bornim.core.art.PixelImage
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 145 Kartenmappe (`KARTENMAPPE=1`): every map of a chapter fully known, as in the game's map tab but without the
 * hero, for the printable folio: the land map, the area maps, the ground plans. Writes `build/screens/mappe_<id>.png`.
 */
fun renderMapFolio() {
    fun write(name: String, img: PixelImage, z: Int) {
        val out = BufferedImage(img.width * z, img.height * z, BufferedImage.TYPE_INT_RGB)
        for (y in 0 until out.height) for (x in 0 until out.width) out.setRGB(x, y, img[x / z, y / z] and 0xFFFFFF)
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/mappe_$name.png"))
        println("wrote mappe_$name ${out.width}x${out.height}")
    }
    write("land", LandSheet.render(LandSheet.Look.PARCHMENT) { true }, 1)
    for (id in listOf("village", "forest", "deep_forest", "cave", "inn", "elder", "shop", "temple"))
        write(id, MapSheet.render(World[id], { _, _ -> true }, gateOpen = true), 2)
}
