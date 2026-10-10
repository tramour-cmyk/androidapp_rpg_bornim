package preview

import de.bornim.core.art.MapRoom
import de.bornim.core.art.RoomThings
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * The room furniture painted with Sculpt next to the former pictures (RAUMDINGE=1): each look as
 * its own picture under build/screens/raum_dinge/ (alt_* and neu_*), anchors in anker.txt.
 */
fun renderRoomThings() {
    val dir = File("build/screens/raum_dinge").apply { mkdirs() }
    val anchors = StringBuilder()
    fun save(name: String, sp: MapRoom.Sprite) {
        val img = BufferedImage(sp.img.width, sp.img.height, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until sp.img.height) for (x in 0 until sp.img.width) img.setRGB(x, y, sp.img[x, y])
        ImageIO.write(img, "png", File(dir, "$name.png"))
        anchors.append("$name ${sp.ax} ${sp.ay}\n")
    }
    for (v in 0..2) {
        save("neu_regal_$v", RoomThings.shelf(v)); save("alt_regal_$v", MapRoom.shelf(v))
        save("neu_holz_$v", RoomThings.firewood(v)); save("alt_holz_$v", MapRoom.clutter(0, v))
        save("neu_fass_$v", RoomThings.barrel(v)); save("alt_fass_$v", MapRoom.barrel(v % 2))
        save("neu_tisch_$v", RoomThings.table(false, false, v)); save("alt_tisch_$v", MapRoom.table(false, false, v))
    }
    for (v in 0..3) { save("neu_tafel_${v}_l", RoomThings.table(false, true, v)); save("neu_tafel_${v}_r", RoomThings.table(true, false, (v + 1) % 4)) }
    File(dir, "anker.txt").writeText(anchors.toString())
    println("wrote room things")
}
