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

/** 293 (`HUND=folge`): waking up and lying down as the village shows them, moment by moment, in the direction it lies. */
fun renderDogSeries() {
    val C = de.bornim.core.art.MapDog
    // spot 0: dozes 60 s, then wakes; lying down at spot 1 after the trot
    fun firstAt(from: Long, until: (de.bornim.core.art.MapDog.At) -> Boolean): Long { var t = from; while (!until(C.at(t))) t += 20; return t }
    val wake = 60_000L
    val lie = firstAt(wake + 9_000L) { it.key == "stand>sit" }
    val rows = listOf(
        "Aufwachen" to listOf(0L, 300L, 600L, 900L, 1300L, 1700L, 2000L, 2300L, 2800L, 3300L).map { wake + it },
        "Hinlegen" to listOf(-300L, 0L, 500L, 1000L, 3240L, 3700L, 4340L, 5240L, 5800L, 6540L).map { lie + it },
    )
    val z = 2
    val w = C.W; val h = C.H
    // five moments a row, so the picture stays small enough for the Chefsache (800 px)
    val cols = 5
    val lines = rows.flatMap { (name, ts) -> ts.chunked(cols).map { name to it } }
    val img = BufferedImage(w * z * cols, (h * z + 16) * lines.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x5E7A3A); g.fillRect(0, 0, img.width, img.height)
    for ((r, line) in lines.withIndex()) for ((c, t) in line.second.withIndex()) {
        val row = rows.first { it.first == line.first }
        val a = C.at(t)
        val p = C.render(C.poseOf(a.key, a.k), de.bornim.core.art.MapFigure.slot(a.yaw) * 360.0 / de.bornim.core.art.MapFigure.YAWS)
        val y0 = r * (h * z + 16)
        for (y in 0 until h * z) for (x in 0 until w * z) {
            val q = p[x / z, y / z]
            if ((q ushr 24) >= 128) img.setRGB(c * w * z + x, y0 + 16 + y, q and 0xFFFFFF)
        }
        g.color = java.awt.Color(0xF0E8D8)
        g.drawString(if (t == row.second[0]) "${row.first}" else "${(t - row.second[0]) / 100 / 10.0} s", c * w * z + 4, y0 + 13)
    }
    ImageIO.write(img, "png", File("build/screens/hund_folge.png"))
    println("wrote dog series")
}
