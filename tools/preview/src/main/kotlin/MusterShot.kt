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
 * MUSTER211PITCH= the angle from above at the middle of the fight (15), with the same lens.
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

/** The path through the wood (211.12), degrees to the right of straight ahead. */
private const val PATH_DEG = 18.0

/** Where a fighter stands on the ground: [a] along the line of the fight (towards the foes), [b] across it (to the right), in metres. */
private class Stand(val a: Double, val b: Double, val hero: Hero? = null, val wolf: Int = -1)

private fun panel(w: Int, h: Int, mars: Boolean, behind: Boolean, title: String): BufferedImage {
    // the Kampfort: forest for the classic fight, the cave hall for MARS; its horizon is the camera's eye height
    // the camera: the middle of the fight 72 % down the scene, seen from [pitch] above; a hero there is 120 px tall.
    // The lens is the one that puts the Kampfort's horizon right at 15°; a higher camera tilts further down with the same
    // lens, so the horizon climbs and the backdrop is drawn taller and cut lower, as the camera would see it.
    val zoom = 2
    val share = if (mars && System.getenv("MUSTER211WALD") == null) 0.43 else 0.40
    val pitch = System.getenv("MUSTER211PITCH")?.toDouble() ?: 15.0
    // MUSTER211MITTE= where the middle of the fight sits, as a share of the height (0.72): only aims the camera, the lens stays
    val midY = h * (System.getenv("MUSTER211MITTE")?.toDouble() ?: 0.72)
    // MUSTER211LINSE= a longer lens by that much, the camera as much further back, so the heroes stay as large (211.11 a)
    val lens = System.getenv("MUSTER211LINSE")?.toDouble() ?: 1.0
    val f = (h * 0.72 - (h / zoom * share).toInt() * zoom) / tan(Math.toRadians(15.0)) * lens
    val horizonY = midY - f * tan(Math.toRadians(pitch))
    // the backdrop's own horizon sits at [share] of its height: make it so tall that the part below shows down to our bottom
    val bh = maxOf(h / zoom, ((h - horizonY) / zoom / (1 - share)).toInt() + 1)
    val top = (bh * share).toInt() - (horizonY / zoom).toInt()
    val bg: PixelImage = if (mars && System.getenv("MUSTER211WALD") == null) CaveScene.cave(w / zoom, bh, CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72)
        else BattleScene.forest(w / zoom, bh, BattleScene.Spot.CLEARING, BattleScene.Light.DAY, false, 7)
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until h) for (x in 0 until w) out.setRGB(x, y, bg[x / zoom, (y / zoom + top).coerceIn(0, bh - 1)] and 0xFFFFFF)

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
    val foeSize0 = System.getenv("MUSTER211GEGNER")?.toDouble() ?: 1.0

    // MUSTER211WALD=1: the wood drawn for this camera (211.12): ground, path and the edge of the wood [MUSTER211WAND] metres
    // (7) behind the furthest foe, all on the one ground plane; both fights in the wood
    val wald = System.getenv("MUSTER211WALD") != null
    if (wald) {
        val wall = all.maxOf { ground(it.a, it.b).second } + (System.getenv("MUSTER211WAND")?.toDouble() ?: 7.0)
        val cam = WaldCam(w / zoom, h / zoom, f / zoom, cx / zoom, horizonY / zoom, eye)
        val feet = all.map { s -> val (x, d) = ground(s.a, s.b); Foot(x, d, if (s.hero != null) 0.42 else 0.55 * foeSize0) }
        // the path comes from behind the heroes and runs into the wood, its middle between the two heroes of a row (Chef 23:03: beide gleich weit von der Achse)
        val (p0x, p0d) = ground(-1.4, 0.0)
        val bgw = waldBild(cam, wall, PATH_DEG, p0x, p0d, feet, 7)
        for (y in 0 until h) for (x in 0 until w) out.setRGB(x, y, bgw[(y / zoom).coerceAtMost(cam.h - 1) * cam.w + (x / zoom).coerceAtMost(cam.w - 1)])
    }
    // MUSTER211WAND= metres behind the furthest foe: the Kampfort's back (cave wall with its way on, the edge of the wood with
    // its sky) stands there on the same ground, its foot in the picture, as large as that distance makes it (211.11, Rückwand)
    if (!wald) System.getenv("MUSTER211WAND")?.toDouble()?.let { behindM ->
        val dw = all.maxOf { ground(it.a, it.b).second } + behindM
        val footY = horizonY + f * eye / dw
        val nh = h / zoom; val nw = w / zoom
        val native: PixelImage = if (mars) CaveScene.cave(nw, nh, CaveScene.Spot.HALL, CaveScene.Light.TORCH, 72)
            else BattleScene.forest(nw, nh, BattleScene.Spot.CLEARING, BattleScene.Light.DAY, false, 7)
        val hz = (nh * share).toInt() + (if (mars) 4 else 3)
        // the part above its horizon stands for 7 m: drawn for a far view, so nearer it is cut, not redrawn
        val sc = 7.0 * f / dw / hz
        for (y in 0 until minOf(h, footY.toInt())) for (x in 0 until w) {
            val sy = (hz - (footY - y) / sc).toInt().coerceIn(0, nh - 1)
            val sx = ((x - w / 2.0) / sc + nw / 2.0).toInt().coerceIn(0, nw - 1)
            out.setRGB(x, y, native[sx, sy] and 0xFFFFFF)
        }
        // where the wall meets the ground: a dark seam
        for (y in footY.toInt() - 2..footY.toInt() + 3) if (y in 0 until h) for (x in 0 until w) {
            val c = out.getRGB(x, y); val k = 0.6
            out.setRGB(x, y, (((c shr 16 and 255) * k).toInt() shl 16) or (((c shr 8 and 255) * k).toInt() shl 8) or ((c and 255) * k).toInt())
        }
    }

    // MUSTER211GEGNER= the foes that much larger than true to life, as the game draws them (211.11 b)
    val foeSize = System.getenv("MUSTER211GEGNER")?.toDouble() ?: 1.0
    val g = out.createGraphics()
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
    // MUSTER211LINIEN=0: no guides, places or labels, only the picture (211.12, „für einen guten Eindruck“)
    val lines = System.getenv("MUSTER211LINIEN") != "0"
    // the places on the ground (MARS): circles of 0.55 m, drawn as the camera sees them
    if (mars && lines) {
        g.color = Color(0xE8C060).let { Color(it.red, it.green, it.blue, 140) }; g.stroke = BasicStroke(1.5f)
        val spots = listOf(front, back).flatMap { r -> listOf(-r, r) }.flatMap { a -> listOf(-half, half).map { a to it } }
        for ((a, b) in spots) {
            val (x0, d0g) = ground(a, b); val path = Path2D.Double()
            for (k in 0..40) { val t = k * Math.PI / 20; val (sx, sy) = screen(x0 + 0.55 * cos(t), d0g + 0.55 * sin(t)); if (k == 0) path.moveTo(sx, sy) else path.lineTo(sx, sy) }
            g.draw(path)
        }
    }

    // the guides on the ground (211.12, Chef 23:03): drawn under the figures, so a line on the ground runs behind a
    // standing figure, not across it; the axis then shows between the two of a row, as it lies on the ground
    // vanishing point of the line of the fight: where it meets the horizon
    val vpX = cx + f * ax / ad
    fun lineTo(a0: Double, b0: Double, a1: Double, b1: Double, c: Color, width: Float) {
        val (x0, dd0) = ground(a0, b0); val (x1, dd1) = ground(a1, b1)
        val (p, q) = screen(x0, dd0); val (r, t) = screen(x1, dd1)
        g.color = c; g.stroke = BasicStroke(width); g.draw(Line2D.Double(p, q, r, t))
    }
    if (lines) {
        // lines along the fight through the outer places, running to its vanishing point
        val fl = Color(120, 200, 255, 120)
        for (b in listOf(-half, half)) lineTo(-6.0, b, 40.0, b, fl, 1f)
        // the path's middle (straight, without its small bends): it runs to its own vanishing point on the same horizon
        if (wald) {
            val (p0x, p0d) = ground(-1.4, 0.0)
            val ps = sin(Math.toRadians(PATH_DEG)); val pc = cos(Math.toRadians(PATH_DEG))
            val (q0, r0) = screen(p0x - 6 * ps, p0d - 6 * pc); val (q1, r1) = screen(p0x + 60 * ps, p0d + 60 * pc)
            g.color = Color(150, 255, 130, 210); g.stroke = BasicStroke(1.5f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10f, floatArrayOf(8f, 5f), 0f)
            g.draw(Line2D.Double(q0, r0, q1, r1))
        }
        // the line of the fight
        lineTo(-6.0, 0.0, 40.0, 0.0, Color(255, 120, 90, 230), 2f)
        // the line of each row, across the fight
        for (a in listOf(-back, -front, front, back)) lineTo(a, -2.2, a, 2.2, Color(255, 230, 140, 200), 1.2f)
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
            BeastArt.beast("wolf", MonsterLook(s.wolf * 37)).render(fw, fh, ancX, gr, perCm * 0.88 * foeSize, BeastArt.STAND.copy(yaw = yawFor(x, d, wolfFacing)), look)
        }
        for (yy in 0 until fh) for (xx in 0 until fw) {
            val q = img[xx, yy]; if ((q ushr 24) < 128) continue
            val px = (sx - ancX + xx).toInt(); val py = (sy - gr + yy).toInt()
            if (px in 0 until w && py in 0 until h) out.setRGB(px, py, q and 0xFFFFFF)
        }
    }

    if (!lines) return out
    // the guides: horizon, line of the fight, the line of each row, and lines to the vanishing point of the fight's line
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    val dash = BasicStroke(1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER, 10f, floatArrayOf(6f, 4f), 0f)
    g.color = Color(255, 255, 255, 170); g.stroke = dash
    g.draw(Line2D.Double(0.0, horizonY, w.toDouble(), horizonY))
    if (horizonY > 30) g.drawString("Horizont = Augenhöhe der Kamera", 6f, (horizonY - 4).toFloat())
    else g.drawString("Horizont ${(-horizonY).toInt()} px über dem Bild", 6f, 34f)
    g.color = Color(255, 255, 255, 220)
    val vpLabel = if (vpX < w) "Fluchtpunkt der Kampfachse ◆" else "Fluchtpunkt Kampfachse: ${(vpX - w).toInt()} px rechts außerhalb →"
    if (vpX < w) g.fillOval((vpX - 4).toInt(), (horizonY - 4).toInt(), 8, 8)
    val lw = g.fontMetrics.stringWidth(vpLabel)
    if (horizonY > 30) g.drawString(vpLabel, (minOf(vpX, w - 4.0) - lw).toFloat(), (horizonY + 14).toFloat())
    g.drawString("Reihen laufen zum zweiten Fluchtpunkt, weit links außerhalb", 6f, h - 26f)
    // title and legend
    g.color = Color(0, 0, 0, 170); g.fillRect(0, 0, w, 20)
    g.color = Color(0xF0E0B0); g.font = Font(Font.SANS_SERIF, Font.BOLD, 13); g.drawString(title, 6f, 15f)
    g.font = Font(Font.SANS_SERIF, Font.PLAIN, 11)
    g.color = Color(0, 0, 0, 170); g.fillRect(0, h - 20, w, 20)
    g.color = Color(255, 120, 90); g.drawString("— Kampfachse", 6f, h - 6f)
    g.color = Color(255, 230, 140); g.drawString("— Reihen", 100f, h - 6f)
    g.color = Color(120, 200, 255); g.drawString("— Fluchtlinien", 170f, h - 6f)
    if (wald) { g.color = Color(150, 255, 130); g.drawString("– – Weg", 262f, h - 6f) }
    val cam = "${pitch.toInt()}°" + (if (lens != 1.0) " · Linse ×$lens" else "") + (if (foeSize != 1.0) " · Gegner ×$foeSize" else "") + (System.getenv("MUSTER211WAND")?.let { " · Wand +$it m" } ?: "")
    g.color = Color(0xF0E8D8); g.drawString(cam, w - 6f - g.fontMetrics.stringWidth(cam), 34f)
    return out
}
