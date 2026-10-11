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

/** Garrick lowering himself, stirring, nodding off and jerking up, in the in-between pictures (SQUATBLEND=1, 10.10., 3a). */
fun renderSquatBlend() {
    val f = de.bornim.core.art.MapFolk.garrick
    val P = { a: de.bornim.core.art.MapFolk.Squat?, b: de.bornim.core.art.MapFolk.Squat?, k: Int -> de.bornim.core.art.MapFolk.SquatPose(a, b, k) }
    val rows = listOf(
        (0..4).map { P(null, de.bornim.core.art.MapFolk.Squat.SQUAT, it) },
        (0..4).map { P(de.bornim.core.art.MapFolk.Squat.SQUAT, de.bornim.core.art.MapFolk.Squat.STOKE_A, it) },
        (0..4).map { P(de.bornim.core.art.MapFolk.Squat.STOKE_A, de.bornim.core.art.MapFolk.Squat.STOKE_B, it) },
        (0..4).map { P(de.bornim.core.art.MapFolk.Squat.SQUAT, de.bornim.core.art.MapFolk.Squat.DOZE, it) },
    )
    val slot = 3
    val w = de.bornim.core.art.MapFigure.W; val h = de.bornim.core.art.MapFigure.H
    val img = BufferedImage(w * 5, h * rows.size, BufferedImage.TYPE_INT_ARGB)
    for ((r, row) in rows.withIndex()) for ((c, p) in row.withIndex()) {
        val pic = de.bornim.core.art.MapFigure.render(f.doll, f.outfit, de.bornim.core.art.MapFolk.squatRig(slot * 360.0 / de.bornim.core.art.MapFigure.YAWS, p))
        for (y in 0 until minOf(h, pic.height)) for (x in 0 until minOf(w, pic.width)) img.setRGB(c * w + x, r * h + y, pic[x, y])
    }
    ImageIO.write(img, "png", File("build/screens/squat_blend.png"))
    println("wrote squat blend")
}
