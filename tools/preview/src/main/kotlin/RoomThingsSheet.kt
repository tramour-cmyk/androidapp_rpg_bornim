package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Garrick lowering himself, stirring, nodding off and jerking up, in the in-between pictures (SQUATBLEND=1, 10.10., 3a). */
fun renderSquatBlend() {
    val f = de.bornim.core.art.MapFolk.garrick
    val P = { a: de.bornim.core.art.MapFolk.Squat?, b: de.bornim.core.art.MapFolk.Squat?, k: Int -> de.bornim.core.art.MapFolk.SquatPose(a, b, k) }
    val rows = listOf(
        (0..de.bornim.core.art.MapFolk.BLEND).map { P(null, de.bornim.core.art.MapFolk.Squat.SQUAT, it) },
        (0..de.bornim.core.art.MapFolk.BLEND).map { P(de.bornim.core.art.MapFolk.Squat.SQUAT, de.bornim.core.art.MapFolk.Squat.STOKE_A, it) },
        (0..de.bornim.core.art.MapFolk.BLEND).map { P(de.bornim.core.art.MapFolk.Squat.STOKE_A, de.bornim.core.art.MapFolk.Squat.STOKE_B, it) },
        (0..de.bornim.core.art.MapFolk.BLEND).map { P(de.bornim.core.art.MapFolk.Squat.SQUAT, de.bornim.core.art.MapFolk.Squat.DOZE, it) },
    )
    val slot = 3
    val w = de.bornim.core.art.MapFigure.W; val h = de.bornim.core.art.MapFigure.H
    val img = BufferedImage(w * (de.bornim.core.art.MapFolk.BLEND + 1), h * rows.size, BufferedImage.TYPE_INT_ARGB)
    for ((r, row) in rows.withIndex()) for ((c, p) in row.withIndex()) {
        val pic = de.bornim.core.art.MapFigure.render(f.doll, f.outfit, de.bornim.core.art.MapFolk.squatRig(slot * 360.0 / de.bornim.core.art.MapFigure.YAWS, p))
        for (y in 0 until minOf(h, pic.height)) for (x in 0 until minOf(w, pic.width)) img.setRGB(c * w + x, r * h + y, pic[x, y])
    }
    ImageIO.write(img, "png", File("build/screens/squat_blend.png"))
    println("wrote squat blend")
}
