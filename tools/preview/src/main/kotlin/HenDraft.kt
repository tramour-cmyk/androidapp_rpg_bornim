package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Hühner im Dorf (83b, `HUEHNER=1`): the hens' poses in three plumages and four directions, enlarged. */
fun renderHenDraft() {
    val C = de.bornim.core.art.MapHen
    val poses = listOf("steht" to C.STAND, "schaut" to C.LOW, "pickt" to C.PECK, "scharrt" to C.SCRATCH, "wachsam" to C.ALERT,
        "geht" to C.poseOf("walk", 2), "flieht" to C.poseOf("run", 1), "flattert" to C.poseOf("run", 3))
    val rows = listOf(0 to -60.0, 0 to 30.0, 0 to 120.0, 0 to 210.0, 1 to -60.0, 1 to 120.0, 2 to -60.0, 2 to 120.0)
    val z = 4
    val w = C.W; val h = C.H
    val img = BufferedImage(w * z * poses.size, (h * z + 16) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x5A5838); g.fillRect(0, 0, img.width, img.height)
    for ((r, vy) in rows.withIndex()) for ((c, np) in poses.withIndex()) {
        val (variant, yaw) = vy
        val p = C.render(np.second, variant, yaw)
        val y0 = r * (h * z + 16)
        for (y in 0 until h * z) for (x in 0 until w * z) {
            val q = p[x / z, y / z]
            if ((q ushr 24) >= 128) img.setRGB(c * w * z + x, y0 + 16 + y, q and 0xFFFFFF)
        }
        g.color = java.awt.Color(0xF0E8D8); g.drawString("${np.first}  ${yaw.toInt()}°  ${listOf("weiß", "braun", "dunkel")[variant]}", c * w * z + 4, y0 + 13)
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_huehner.png"))
    println("wrote hen draft")
}
