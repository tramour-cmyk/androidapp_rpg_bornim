package preview

import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapFolk
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * HALTUNG239=1 (239, Chef 20.10.: "Animationsübergang bei Garrick sitzen/stehen sehr unrund"): Garrick going down at
 * his fire, starting up when the hero comes and going into warming his hands, a picture every 80 ms, each before
 * (4 steps, up in one picture, into the loop in one picture) and after.
 */
fun renderHaltung239() {
    val f = MapFolk.garrick
    val slot = (System.getenv("HALTUNG239SLOT") ?: "2").toInt()
    val yaw = slot * 360.0 / MapFigure.YAWS
    val step = 80L
    val cols = 14
    val stand = MapFigure.rig(yaw, 0, f.carry)
    fun ease(t: Double) = t.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
    fun squat(p: MapFolk.SquatPose?) = MapFolk.squatRig(yaw, p ?: MapFolk.SquatPose(null, null, 0))

    // a day block in which he goes down: the moment he starts
    var start = 0L
    while (MapFolk.squatPoseAt(f, start, false) == null) start += 20
    val sitFrom = start - 2 * step
    val sitOld = (0 until cols).map { i ->
        val s = sitFrom + i * step - start
        if (s < 0) stand else squat(MapFolk.SquatPose(null, MapFolk.Squat.SQUAT, (Math.round(ease(s / MapFolk.SIT_MS.toDouble()) * 4) * 2).toInt().coerceAtMost(8))
            .let { if (it.k >= 8) MapFolk.SquatPose(MapFolk.Squat.SQUAT, MapFolk.Squat.SQUAT, 0) else it })
    }
    val sitNew = (0 until cols).map { i -> squat(MapFolk.squatPoseAt(f, sitFrom + i * step, false)) }

    // the hero comes 3 s after he went down
    val come = start + 3_000
    val upFrom = come - 2 * step
    val upOld = (0 until cols).map { i -> val t = upFrom + i * step; if (t < come) squat(MapFolk.squatPoseAt(f, t, false)) else stand }
    val gate = MapFolk.SquatGate()
    var t0 = start
    while (t0 < upFrom) { gate.at(f, t0, false, roused = false); t0 += 20 }
    val upNew = mutableListOf<HeroFigure.Rig>()
    while (upNew.size < cols) {
        val p = gate.at(f, t0, false, roused = t0 >= come)
        if ((t0 - upFrom) % step == 0L) upNew += squat(p)
        t0 += 20
    }

    // a block in which he warms his hands
    var w = 0L
    while (MapFolk.doing(f, w)?.idle != MapFolk.Idle.WARM) w += 20
    val warmFrom = w - 2 * step
    val warmOld = (0 until cols).map { i ->
        val d = MapFolk.doing(f, warmFrom + i * step)
        if (d == null) stand else MapFolk.idleRig(yaw, d.idle, (i - 2) % 4 * MapFolk.SUB)
    }
    val warmNew = (0 until cols).map { i ->
        MapFolk.doing(f, warmFrom + i * step)?.let { MapFolk.idleInRig(f, yaw, it.idle, it.frame, it.level) } ?: stand
    }

    val rows = listOf("Hinhocken vorher" to sitOld, "Hinhocken jetzt" to sitNew, "Held kommt: vorher" to upOld, "Held kommt: jetzt" to upNew,
        "Hände wärmen vorher" to warmOld, "Hände wärmen jetzt" to warmNew)
    // only the part of the picture with the figure
    val cx0 = 22; val cx1 = 74; val cy0 = 30; val cy1 = 132
    val cw = cx1 - cx0; val ch = cy1 - cy0
    val label = 128
    val img = BufferedImage(label + cw * cols, (ch + 4) * rows.size + 16, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.color = Color(0x2a2a26); g.fillRect(0, 0, img.width, img.height)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    g.color = Color(0xd8c48a)
    for (c in 0 until cols) g.drawString("${c * step} ms", label + c * cw + 8, 12)
    for ((r, row) in rows.withIndex()) {
        val y0 = 16 + r * (ch + 4)
        g.color = if (r % 2 == 0) Color(0x9a9080) else Color(0xd8c48a)
        g.drawString(row.first, 6, y0 + ch / 2)
        for ((c, rig) in row.second.withIndex()) {
            val pic = MapFigure.render(f.doll, f.outfit, rig)
            for (y in cy0 until minOf(cy1, pic.height)) for (x in cx0 until minOf(cx1, pic.width)) {
                val px = pic[x, y]
                if ((px ushr 24) > 0) img.setRGB(label + c * cw + x - cx0, y0 + y - cy0, px or (0xff shl 24))
            }
        }
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(img, "png", File("build/screens/haltung239.png"))
    println("wrote build/screens/haltung239.png")
}
