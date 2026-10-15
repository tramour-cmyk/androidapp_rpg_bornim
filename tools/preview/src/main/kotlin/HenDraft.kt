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

/** 83b: one hen over time (`HUEHNERFILM=1`): pecking, the hero coming from the west at 4 s, running off, wary, back; a picture every 100 ms. */
fun renderHenFilm() {
    val C = de.bornim.core.art.MapHen
    val map = de.bornim.core.World["village"]
    val src = C.of(map).first()
    val hen = de.bornim.core.art.MapHen.Hen(src.homeX, src.homeY, src.seed, src.variant)
    val frames = mutableListOf<Pair<String, java.awt.image.BufferedImage>>()
    val z = 3; val w = C.W; val h = C.H
    var heroX = src.homeX - 200f
    for (t in 0L..14_000L step 20L) {
        // the hero walks up from the west between 3 and 5 s, then goes away again from 7 s
        heroX = when { t < 3_000 -> src.homeX - 200f; t < 5_000 -> src.homeX - 200f + (t - 3_000) / 2_000f * 175f; t < 7_000 -> heroX; else -> heroX - 0.6f * 20 }
        val a = hen.at(t, heroX, src.homeY, map)
        if (System.getenv("HUEHNERLOG") != null && (t in 4_700L..5_900L || t in 8_200L..8_500L) && t % 40 == 0L) println("$t ${a.key} yaw=${"%.0f".format(a.yaw)} slot=${de.bornim.core.art.MapFigure.slot(a.yaw)} x=${"%.1f".format(a.x)} y=${"%.1f".format(a.y)} hero=${"%.0f".format(heroX)}")
        if (t % 100 != 0L || t < 2_500 || t > 9_000) continue
        val slot = de.bornim.core.art.MapFigure.slot(a.yaw)
        val p = C.frameNow(a, slot)
        val img = java.awt.image.BufferedImage(w * z, h * z + 14, java.awt.image.BufferedImage.TYPE_INT_RGB)
        val g = img.createGraphics(); g.color = java.awt.Color(0x5A5838); g.fillRect(0, 0, img.width, img.height)
        for (y in 0 until h * z) for (x in 0 until w * z) { val q = p[x / z, y / z]; if ((q ushr 24) >= 128) img.setRGB(x, 14 + y, q and 0xFFFFFF) }
        g.color = java.awt.Color(0xF0E8D8); g.drawString("${t}ms ${a.key} ${a.k}", 2, 11)
        frames += "" to img
    }
    val cols = 13
    val sheet = java.awt.image.BufferedImage(cols * w * z, ((frames.size + cols - 1) / cols) * (h * z + 14), java.awt.image.BufferedImage.TYPE_INT_RGB)
    val g = sheet.createGraphics()
    for ((i, f) in frames.withIndex()) g.drawImage(f.second, (i % cols) * w * z, (i / cols) * (h * z + 14), null)
    ImageIO.write(sheet, "png", File("build/screens/film_huehner.png"))
    println("wrote hen film, ${frames.size} pictures")
}
