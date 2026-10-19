package preview

import de.bornim.core.CharClass
import de.bornim.core.Hero
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.art.BattleScene
import de.bornim.core.art.BeastArt
import de.bornim.core.art.CaveScene
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.PixelImage
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.Graphics2D
import java.awt.RenderingHints
import java.awt.geom.Line2D
import java.awt.geom.Path2D
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.atan
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.tan

/**
 * 211.11 (Chef 19.10., 22:05): the pattern pictures in true perspective. One ground plane, one camera: the Kampfort's
 * horizon is the camera's eye height, the middle of the fight is seen from 15° above; every figure stands on that ground,
 * is drawn as large as its distance makes it and is seen from its own angle (from above and from the side). Wolves turned
 * -30° to the heroes as fixed for the wolf, the heroes turned back along the same line (150°).
 * MUSTER211=1 → build/screens/muster211.png (classic above, MARS below; heroes side by side left, one behind the other right).
 * MUSTER211PITCH= the angle from above at the middle of the fight (15).
 */
fun musterShot() {
    val pw = 412; val ph = 600
    val panels = listOf(
        Triple("Klassisch · Helden nebeneinander", false, false), Triple("Klassisch · Helden hintereinander", false, true),
        Triple("MARS · Helden nebeneinander", true, false), Triple("MARS · Helden hintereinander", true, true))
    val out = BufferedImage(pw * 2, ph * 2, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    for ((i, p) in panels.withIndex()) {
        val img = panel(pw, ph, p.second, p.third, p.first)
        g.drawImage(img, (i % 2) * pw, (i / 2) * ph, null)
    }
    g.color = Color(0x000000); g.fillRect(pw - 1, 0, 2, ph * 2); g.fillRect(0, ph - 1, pw * 2, 2)
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/muster211.png"))
    println("wrote muster211")
}

/** Where a fighter stands on the ground: [a] along the line of the fight (towards the foes), [b] across it (to the right), in metres. */
private class Stand(val a: Double, val b: Double, val hero: Hero? = null, val wolf: Int = -1)

private fun panel(w: Int, h: Int, mars: Boolean, behind: Boolean, title: String): BufferedImage {
    // the Kampfort: forest for the classic fight, the cave hall for MARS; its horizon is the camera's eye height
    val zoom = 2
    val bg: PixelImage = if (mars) CaveScene.cave(w / zoom, h / zoom, CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72)
        else BattleScene.forest(w / zoom, h / zoom, BattleScene.Spot.CLEARING, BattleScene.Light.DAY, false, 7)
    val horizonY = (h / zoom * (if (mars) 0.43 else 0.40)).toInt() * zoom.toDouble()
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until h) for (x in 0 until w) out.setRGB(x, y, bg[x / zoom, y / zoom] and 0xFFFFFF)

    // the camera: the middle of the fight 72 % down the scene, seen from [pitch] above; a hero there is 120 px tall
    val pitch = System.getenv("MUSTER211PITCH")?.toDouble() ?: 15.0
    val midY = h * 0.72
    val f = (midY - horizonY) / tan(Math.toRadians(pitch))
    val perM0 = 120.0 / 1.75
    val d0 = f / perM0
    val eye = d0 * tan(Math.toRadians(pitch))
    val cx = w / 2.0
    // the line of the fight on the ground: from the heroes away and to the right, 30° off straight ahead (wolf -30°)
    val ax = sin(Math.toRadians(30.0)); val ad = cos(Math.toRadians(30.0))
    val bx = ad; val bd = -ax
    fun ground(a: Double, b: Double) = Pair(a * ax + b * bx, d0 + a * ad + b * bd)
    fun screen(x: Double, d: Double) = Pair(cx + f * x / d, horizonY + f * eye / d)

    // who stands where: rows 1.5 m apart, the front rows 2.8 m apart, two of a row 1.8 m apart, one alone in the middle
    val hero = Hero.create("Bertram", Race.HUMAN, CharClass.FIGHTER)
    val merc = Hero.create("Ulf", Race.DWARF, CharClass.CLERIC)
    val front = 1.4; val back = 2.9; val half = 0.9
    val party = if (behind) listOf(Stand(-front, 0.0, hero), Stand(-back, 0.0, merc))
        else listOf(Stand(-front, -half, hero), Stand(-front, half, merc))
    val foes = if (mars) listOf(Stand(front, -half, wolf = 0), Stand(front, half, wolf = 1), Stand(back, 0.0, wolf = 2))
        else listOf(Stand(front, 0.0, wolf = 0), Stand(back, -1.1, wolf = 1), Stand(back + 0.4, 1.1, wolf = 2))
    val all = party + foes

    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
    // the places on the ground (MARS): circles of 0.55 m, drawn as the camera sees them
    if (mars) {
        g.color = Color(0xE8C060).let { Color(it.red, it.green, it.blue, 140) }; g.stroke = BasicStroke(1.5f)
        val spots = listOf(front, back).flatMap { r -> listOf(-r, r) }.flatMap { a -> listOf(-half, half).map { a to it } }
        for ((a, b) in spots) {
            val (x0, d0g) = ground(a, b); val path = Path2D.Double()
            for (k in 0..40) { val t = k * Math.PI / 20; val (sx, sy) = screen(x0 + 0.55 * cos(t), d0g + 0.55 * sin(t)); if (k == 0) path.moveTo(sx, sy) else path.lineTo(sx, sy) }
            g.draw(path)
        }
    }

    // the figures, far ones first; each drawn at its distance and seen from its own angle
    val wolfFacing = Pair(-ax, -ad); val heroFacing = Pair(ax, ad)
    fun yawFor(x: Double, d: Double, face: Pair<Double, Double>): Double {
        val phi = atan2(x, d)
        val s = face.first * cos(phi) - face.second * sin(phi)
        val c = -(face.first * sin(phi) + face.second * cos(phi))
        return Math.toDegrees(atan2(s, c))
    }
    for (s in all.sortedByDescending { ground(it.a, it.b).second }) {
        val (x, d) = ground(s.a, s.b)
        val (sx, sy) = screen(x, d)
        val perCm = f / d / 100.0
        val look = atan(eye / d).let { Math.toDegrees(it) }
        val fw = 300; val fh = 260; val ancX = 150.0; val gr = 230.0
        val img = if (s.hero != null) {
            val rig = HeroBattle.frames(s.hero, HeroFigure.Act.IDLE, HeroBattle.strikes(s.hero).first(), 0).first()
            HeroBattle.doll(s.hero).render(fw, fh, ancX, gr, perCm, rig.copy(yaw = yawFor(x, d, heroFacing)), HeroBattle.outfit(s.hero), look).img
        } else {
            BeastArt.beast("wolf", MonsterLook(s.wolf * 37)).render(fw, fh, ancX, gr, perCm * 0.88, BeastArt.STAND.copy(yaw = yawFor(x, d, wolfFacing)), look)
        }
        for (yy in 0 until fh) for (xx in 0 until fw) {
            val q = img[xx, yy]; if ((q ushr 24) < 128) continue
            val px = (sx - ancX + xx).toInt(); val py = (sy - gr + yy).toInt()
            if (px in 0 until w && py in 0 until h) out.setRGB(px, py, q and 0xFFFFFF)
        }
    }

    // the guides: horizon, line of the fight, the line of each row, and lines to the vanishing point of the fight's line
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    val dash = BasicStroke(1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10f, floatArrayOf(6f, 4f), 0f)
    g.color = Color(255, 255, 255, 170); g.stroke = dash
    g.draw(Line2D.Double(0.0, horizonY, w.toDouble(), horizonY))
    g.drawString("Horizont = Augenhöhe der Kamera", 6f, (horizonY - 4).toFloat())
    // vanishing point of the line of the fight: where it meets the horizon
    val vpX = cx + f * ax / ad
    fun lineTo(a0: Double, b0: Double, a1: Double, b1: Double, c: Color, width: Float) {
        val (x0, dd0) = ground(a0, b0); val (x1, dd1) = ground(a1, b1)
        val (p, q) = screen(x0, dd0); val (r, t) = screen(x1, dd1)
        g.color = c; g.stroke = BasicStroke(width); g.draw(Line2D.Double(p, q, r, t))
    }
    // lines along the fight through the outer places, running to its vanishing point
    val fl = Color(120, 200, 255, 120)
    for (b in listOf(-half, half)) lineTo(-6.0, b, 40.0, b, fl, 1f)
    // the line of the fight
    lineTo(-6.0, 0.0, 40.0, 0.0, Color(255, 120, 90, 230), 2f)
    // the line of each row, across the fight
    for (a in listOf(-back, -front, front, back)) lineTo(a, -2.2, a, 2.2, Color(255, 230, 140, 200), 1.2f)
    g.color = Color(255, 255, 255, 220)
    val vpLabel = if (vpX < w) "Fluchtpunkt der Kampfachse ◆" else "Fluchtpunkt Kampfachse: ${(vpX - w).toInt()} px rechts außerhalb →"
    if (vpX < w) g.fillOval((vpX - 4).toInt(), (horizonY - 4).toInt(), 8, 8)
    val lw = g.fontMetrics.stringWidth(vpLabel)
    g.drawString(vpLabel, (minOf(vpX, w - 4.0) - lw).toFloat(), (horizonY + 14).toFloat())
    g.drawString("Reihen laufen zum zweiten Fluchtpunkt, weit links außerhalb", 6f, h - 26f)
    // title and legend
    g.color = Color(0, 0, 0, 170); g.fillRect(0, 0, w, 20)
    g.color = Color(0xF0E0B0); g.font = Font(Font.SANS_SERIF, Font.BOLD, 13); g.drawString(title, 6f, 15f)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    g.color = Color(0, 0, 0, 170); g.fillRect(0, h - 20, w, 20)
    g.color = Color(255, 120, 90); g.drawString("— Kampfachse", 6f, h - 6f)
    g.color = Color(255, 230, 140); g.drawString("— Reihen", 100f, h - 6f)
    g.color = Color(120, 200, 255); g.drawString("— Fluchtlinien", 170f, h - 6f)
    g.color = Color(0xF0E8D8); g.drawString("Kamera ${pitch.toInt()}° · Wolf −30°", 270f, h - 6f)
    return out
}
