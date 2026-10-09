package preview

import de.bornim.core.art.MapCave
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * The things of the cave painted with Sculpt (HOEHLEDINGE=1): each look as its own picture under
 * build/screens/hoehle_dinge/, with its anchor (the point that stands on the ground) in anker.txt.
 */
fun renderCaveThings() {
    val dir = File("build/screens/hoehle_dinge").apply { mkdirs() }
    val anchors = StringBuilder()
    val kinds = listOf<Pair<String, (Int) -> MapCave.Sprite>>(
        "stalagmit" to MapCave::stalagmite, "kisten" to MapCave::crates, "knochen" to MapCave::bones, "schlafplatz" to MapCave::bedroll,
        "felsblock" to MapCave::boulder, "geroell" to MapCave::rubble, "leuchtpilze" to MapCave::mushrooms, "kristalle" to MapCave::crystals,
        "stuetzbalken" to MapCave::support, "gitter" to MapCave::gate, "lagerfeuer" to MapCave::campfire, "truhe" to MapCave::chest,
        "wurzeln" to MapCave::roots,
    )
    for ((name, make) in kinds) for (v in 0..2) {
        val sp = make(v)
        val img = BufferedImage(sp.img.width, sp.img.height, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until sp.img.height) for (x in 0 until sp.img.width) img.setRGB(x, y, sp.img[x, y])
        ImageIO.write(img, "png", File(dir, "${name}_$v.png"))
        anchors.append("${name}_$v ${sp.ax} ${sp.ay}\n")
    }
    File(dir, "anker.txt").writeText(anchors.toString())
    println("wrote cave things")
}
