package preview

import de.bornim.core.World
import de.bornim.core.art.MapSheet
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * Kartenansicht (Vorrat 8, draft, `KARTENBLATT=1`): the drawn map of each place, enlarged three times; the wild
 * places once fully known and once only partly (as after a first walk along the way), the hero where it enters.
 */
fun renderMapSheets() {
    val z = 3
    fun write(name: String, img: de.bornim.core.art.PixelImage) {
        val out = BufferedImage(img.width * z, img.height * z, BufferedImage.TYPE_INT_RGB)
        for (y in 0 until out.height) for (x in 0 until out.width) out.setRGB(x, y, img[x / z, y / z] and 0xFFFFFF)
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/karte_$name.png"))
        println("wrote karte_$name")
    }
    val heroAt = mapOf("forest" to (9 to 29), "village" to (17 to 2), "cave" to (10 to 17), "deep_forest" to (3 to 5),
        "inn" to (4 to 6), "shop" to (4 to 5), "temple" to (4 to 4), "elder" to (4 to 4))
    for (id in listOf("village", "forest", "deep_forest", "cave", "inn", "shop", "temple", "elder")) {
        val m = World[id]
        val (hx, hy) = heroAt.getValue(id)
        write(id, MapSheet.render(m, { _, _ -> true }, hx, hy))
        if (m.kind == de.bornim.core.MapKind.FOREST || m.kind == de.bornim.core.MapKind.CAVE) {
            // partly known: within five tiles of the hero's way from where it entered to the middle of the map
            val way = (0..20).map { k -> hx + (m.width / 2 - hx) * k / 20 to hy + (m.height / 2 - hy) * k / 20 }
            write("${id}_teil", MapSheet.render(m, { x, y -> way.any { (wx, wy) -> (x - wx) * (x - wx) + (y - wy) * (y - wy) <= 22 } }, hx, hy))
        }
    }
}
