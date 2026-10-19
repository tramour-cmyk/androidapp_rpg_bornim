package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Hund im Dorf (draft, `HUND=1`): the dog's poses and the moves between them, in four directions, enlarged. */
fun renderDogDraft() {
    val C = de.bornim.core.art.MapDog
    val poses = listOf("schläft" to C.SLEEP, "halb" to C.SLEEP.lerp(C.SIT, 0.5), "sitzt" to C.SIT, "steht" to C.STAND,
        "halb" to C.STAND.lerp(C.STRETCH, 0.5), "verbeugt" to C.STRETCH)
    val yaws = listOf(-60.0, 30.0, 120.0, 210.0)
    val z = 4
    val w = C.W; val h = C.H
    val img = BufferedImage(w * z * poses.size, (h * z + 16) * yaws.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x3A2C22); g.fillRect(0, 0, img.width, img.height)
    for ((r, yaw) in yaws.withIndex()) for ((c, np) in poses.withIndex()) {
        val p = C.render(np.second, yaw)
        val y0 = r * (h * z + 16)
        for (y in 0 until h * z) for (x in 0 until w * z) {
            val q = p[x / z, y / z]
            if ((q ushr 24) >= 128) img.setRGB(c * w * z + x, y0 + 16 + y, q and 0xFFFFFF)
        }
        g.color = java.awt.Color(0xF0E8D8); g.drawString("${np.first}  ${yaw.toInt()}°", c * w * z + 4, y0 + 13)
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_hund.png"))
    println("wrote dog draft")
}
