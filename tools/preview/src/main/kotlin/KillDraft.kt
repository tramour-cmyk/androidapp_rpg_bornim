package preview

import java.awt.BasicStroke
import java.awt.Color
import java.awt.RenderingHints
import java.awt.geom.AffineTransform
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.cos
import kotlin.math.sin

/** KILLDRAFT=1: drafts of the killing blow, the hero's three blows and what becomes of the foe at each blood level. */
fun renderKillDrafts() {
    renderKillHero()
    renderKillFoe()
}

private fun toImage(p: de.bornim.core.art.PixelImage): BufferedImage {
    val b = BufferedImage(p.width, p.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until p.height) for (x in 0 until p.width) { val q = p[x, y]; if ((q ushr 24) >= 128) b.setRGB(x, y, q or (0xFF shl 24)) }
    return b
}

private fun renderKillHero() {
    val F = de.bornim.core.art.HeroFigure
    val B = de.bornim.core.art.HeroBattle
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 3)
    val kits = listOf(listOf("longsword", "shield"), listOf("greataxe"))
    val moves = listOf(
        "Überkopfhieb" to listOf(F.KILL_HIGH_RAISE, F.KILL_HIGH_HIT, F.KILL_HIGH_DOWN),
        "Durchbohren" to listOf(F.KILL_IMPALE_WIND, F.KILL_IMPALE_HIT, F.KILL_IMPALE_TEAR),
        "Drehhieb" to listOf(F.KILL_SPIN_WIND, F.KILL_SPIN_TURN, F.KILL_SPIN_HIT, F.KILL_SPIN_END),
    )
    val cw = B.W * 2; val ch = B.H * 2
    val out = BufferedImage(cw * 4, ch * moves.size * kits.size, BufferedImage.TYPE_INT_RGB)
    val g2 = out.createGraphics(); g2.color = Color(0x46583A); g2.fillRect(0, 0, out.width, out.height)
    var row = 0
    for (kit in kits) {
        val items = mutableMapOf(de.bornim.core.GearSlot.MAIN_HAND to g(kit[0]))
        if (kit.size > 1) items[de.bornim.core.GearSlot.OFF_HAND] = g(kit[1])
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, items)
        val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        for ((name0, keys0) in moves) {
            // axes and maces are not thrust in: they rise up through the foe instead
            val (name, keys) = if (name0 == "Durchbohren" && kit[0] in setOf("greataxe", "mace", "handaxe", "warhammer", "battleaxe"))
                "Aufwärtshieb" to listOf(F.KILL_RISE_WIND, F.KILL_RISE_HIT, F.KILL_RISE_END) else name0 to keys0
            for ((c, rig) in keys.withIndex()) {
                val im = toImage(doll.render(B.W, B.H, B.ANCHOR_X, B.GROUND, B.PX, rig, outfit).img)
                g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR)
                g2.drawImage(im, c * cw, row * ch, cw, ch, null)
            }
            g2.color = Color(0xF0E8D8); g2.drawString("$name – ${kit.joinToString(" + ")}", 6, row * ch + 14)
            row++
        }
    }
    ImageIO.write(out, "png", File("build/screens/killerschlag_held.png"))
    println("wrote kill hero")
}

/** Splits [img] along the line through ([cx], [cy]) at [deg]: the part above it and the part below it. */
private fun split(img: BufferedImage, cx: Double, cy: Double, deg: Double): Pair<BufferedImage, BufferedImage> {
    val a = Math.toRadians(deg); val nx = -sin(a); val ny = cos(a)
    val up = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB)
    val dn = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until img.height) for (x in 0 until img.width) {
        val q = img.getRGB(x, y); if ((q ushr 24) == 0) continue
        val side = (x - cx) * nx + (y - cy) * ny
        if (side < 0) up.setRGB(x, y, q) else dn.setRGB(x, y, q)
        // the raw edge of the cut, dark red on both pieces
        if (kotlin.math.abs(side) < 2.2) { up.setRGB(x, y, if (side < 0) 0xFF5A0A0E.toInt() else 0); dn.setRGB(x, y, if (side >= 0) 0xFF7A0E12.toInt() else 0) }
    }
    return up to dn
}

private fun bbox(img: BufferedImage): IntArray {
    var x0 = img.width; var x1 = 0; var y0 = img.height; var y1 = 0
    for (y in 0 until img.height) for (x in 0 until img.width) if ((img.getRGB(x, y) ushr 24) != 0) { x0 = minOf(x0, x); x1 = maxOf(x1, x); y0 = minOf(y0, y); y1 = maxOf(y1, y) }
    return intArrayOf(x0, y0, x1, y1)
}

private fun darken(img: BufferedImage, k: Double): BufferedImage {
    val o = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until img.height) for (x in 0 until img.width) {
        val q = img.getRGB(x, y); if ((q ushr 24) == 0) continue
        val r = ((q shr 16 and 0xFF) * k).toInt(); val gg = ((q shr 8 and 0xFF) * k).toInt(); val b = ((q and 0xFF) * k).toInt()
        o.setRGB(x, y, (0xFF shl 24) or (r shl 16) or (gg shl 8) or b)
    }
    return o
}

private fun blood(g: java.awt.Graphics2D, x: Double, y: Double, ground: Double, rnd: java.util.Random, n: Int, spread: Double, dir: Double, c1: Int, c2: Int) {
    for (i in 0 until n) {
        val a = Math.toRadians(dir + (rnd.nextDouble() - 0.5) * spread)
        val d = 6 + rnd.nextDouble() * 34
        val px = x + cos(a) * d; val py = minOf(ground, y + sin(a) * d + d * d * 0.012)
        val s = 1.5 + rnd.nextDouble() * 2.5
        g.color = Color(if (rnd.nextInt(3) == 0) c2 else c1); g.fill(java.awt.geom.Ellipse2D.Double(px - s / 2, py - s / 2, s, s))
    }
}

private fun pool(g: java.awt.Graphics2D, x: Double, ground: Double, w: Double, c: Int) {
    g.color = Color(c); g.fill(java.awt.geom.Ellipse2D.Double(x - w / 2, ground - w * 0.1, w, w * 0.22))
}

private fun renderKillFoe() {
    val M = de.bornim.core.art.MonsterArt
    val cols = listOf("Aus", "Dezent", "Deutlich (Hieb)", "Deutlich (gefallen)")
    val cw = 240; val ch = 200
    val rows = listOf("goblin" to 0, "skeleton" to 2)
    val out = BufferedImage(cw * cols.size, ch * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = Color(0x46583A); g.fillRect(0, 0, out.width, out.height)
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF)
    for ((r, ab) in rows.withIndex()) {
        val (id, seed) = ab
        val look = de.bornim.core.MonsterLook(seed)
        val ground = M.groundLine(id); val ax = M.anchorX(id, 0)
        val dieV = M.dieVariant(id, look)
        val stand = toImage(M.battleFrame(id, look, de.bornim.core.art.Act.HURT, 0, 3))
        val reel = toImage(M.battleFrame(id, look, de.bornim.core.art.Act.DIE, dieV, 4))
        val n = M.frameCount(id, look, de.bornim.core.art.Act.DIE, dieV)
        val down = toImage(M.battleFrame(id, look, de.bornim.core.art.Act.DIE, dieV, n - 1))
        val bb = bbox(stand)
        val cx = (bb[0] + bb[2]) / 2.0; val cy = bb[1] + (bb[3] - bb[1]) * 0.45
        val ox = (cw / 2 - ax).toInt(); val oy = (ch - 20 - ground).toInt()
        fun cell(c: Int, body: (java.awt.Graphics2D) -> Unit) {
            val sub = g.create(c * cw, r * ch, cw, ch) as java.awt.Graphics2D
            sub.translate(ox, oy); body(sub); sub.dispose()
        }
        val rnd = java.util.Random(7L + r)
        if (id == "skeleton") {
            // bones: the frame broken into pieces that burst apart and fall, at every blood level
            val pieces = shards(stand, 30, rnd)
            val jit = pieces.map { Pair((rnd.nextDouble() - 0.5) * 12, (rnd.nextDouble() - 0.5) * 2.4) }
            fun burst(sub: java.awt.Graphics2D, t: Double) {
                for ((k, pa) in pieces.withIndex()) {
                    val (img, at) = pa
                    val (px, py) = at
                    // burst out from the blow, then down to the ground, where they lie scattered
                    val dx = (px - cx) * 1.6 * t + jit[k].first * 3 * t
                    val fall = (ground - 3 - py) * minOf(1.0, t * t * 1.4) + (py - cy) * 0.3 * t * (1 - t)
                    val tr = AffineTransform(); tr.translate(dx, fall); tr.rotate(jit[k].second * t, px, py)
                    sub.drawImage(img, tr, null)
                }
            }
            cell(0) { burst(it, 0.35) }
            cell(1) { burst(it, 0.6) }
            cell(2) { burst(it, 0.8) }
            cell(3) { burst(it, 1.0) }
        } else {
            cell(0) { it.drawImage(darken(reel, 0.62), 0, 0, null) }
            cell(1) { s -> pool(s, ax, ground, 70.0, 0xC85A0A10.toInt()); s.drawImage(reel, 0, 0, null); blood(s, cx, cy, ground, rnd, 26, 70.0, -20.0, 0xFF7A0C12.toInt(), 0xFFA8161E.toInt()) }
            val (up, dn) = split(stand, cx, cy, -32.0)
            cell(2) { s ->
                s.drawImage(dn, 0, 0, null)
                val tr = AffineTransform(); tr.translate(18.0, -12.0); tr.rotate(Math.toRadians(-22.0), cx, cy); s.drawImage(up, tr, null)
                blood(s, cx, cy, ground, rnd, 46, 160.0, -40.0, 0xFF7A0C12.toInt(), 0xFFA8161E.toInt())
            }
            cell(3) { s ->
                pool(s, ax + 10, ground, 110.0, 0xD0600A10.toInt())
                val t1 = AffineTransform(); t1.translate(-4.0, (ground - bb[3]) + 6.0); t1.rotate(Math.toRadians(-70.0), cx, bb[3].toDouble()); s.drawImage(dn, t1, null)
                val t2 = AffineTransform(); t2.translate(46.0, ground - cy - 2.0); t2.rotate(Math.toRadians(-100.0), cx, cy); s.drawImage(up, t2, null)
                blood(s, cx + 20, ground - 6, ground, rnd, 30, 200.0, -90.0, 0xFF6A0A10.toInt(), 0xFF8E1218.toInt())
            }
        }
        g.color = Color(0xF0E8D8)
        for ((c, name) in cols.withIndex()) g.drawString(if (id == "skeleton") listOf("Knochen 1", "Knochen 2", "Knochen 3", "liegen")[c] else name, c * cw + 6, r * ch + 14)
    }
    val big = BufferedImage(out.width * 2, out.height * 2, BufferedImage.TYPE_INT_RGB)
    big.createGraphics().apply { setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR); drawImage(out, 0, 0, big.width, big.height, null) }
    ImageIO.write(big, "png", File("build/screens/killerschlag_gegner.png"))
    println("wrote kill foe")
}

/** The frame broken into [n] pieces around random points: each piece and its middle. */
private fun shards(img: BufferedImage, n: Int, rnd: java.util.Random): List<Pair<BufferedImage, Pair<Double, Double>>> {
    val bb = bbox(img)
    // the break points on the body itself, not in the empty air round it
    val solid = mutableListOf<Pair<Double, Double>>()
    for (y in bb[1]..bb[3]) for (x in bb[0]..bb[2]) if ((img.getRGB(x, y) ushr 24) != 0) solid += Pair(x.toDouble(), y.toDouble())
    val seeds = List(n) { solid[rnd.nextInt(solid.size)] }
    val parts = List(n) { BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB) }
    val sums = Array(n) { doubleArrayOf(0.0, 0.0, 0.0) }
    for (y in bb[1]..bb[3]) for (x in bb[0]..bb[2]) {
        val q = img.getRGB(x, y); if ((q ushr 24) == 0) continue
        var best = 0; var bd = Double.MAX_VALUE
        for ((i, s) in seeds.withIndex()) { val d = (s.first - x) * (s.first - x) + (s.second - y) * (s.second - y); if (d < bd) { bd = d; best = i } }
        parts[best].setRGB(x, y, q); sums[best][0] += x.toDouble(); sums[best][1] += y.toDouble(); sums[best][2] += 1.0
    }
    return parts.indices.filter { sums[it][2] > 0 }.map { parts[it] to Pair(sums[it][0] / sums[it][2], sums[it][1] / sums[it][2]) }
}

/** KILLSHEET=1: what the killing blow does to each kind of foe, the pieces at six moments after it lands. */
fun renderKillSheet() {
    val cases = listOf(
        Triple("goblin", de.bornim.core.art.HeroFigure.Strike.KILL_HIGH, 2), Triple("goblin", de.bornim.core.art.HeroFigure.Strike.KILL_PIERCE, 2), Triple("bugbear", de.bornim.core.art.HeroFigure.Strike.KILL_SPIN, 2), Triple("skeleton", de.bornim.core.art.HeroFigure.Strike.KILL_HIGH, 0),
        Triple("ochre_jelly", de.bornim.core.art.HeroFigure.Strike.KILL_RISE, 2), Triple("wolf", de.bornim.core.art.HeroFigure.Strike.KILL_RISE, 2), Triple("giant_bat", de.bornim.core.art.HeroFigure.Strike.KILL_SPIN, 2), Triple("giant_spider", de.bornim.core.art.HeroFigure.Strike.KILL_HIGH, 2),
        Triple("ghoul", de.bornim.core.art.HeroFigure.Strike.KILL_SPIN, 2), Triple("giant_centipede", de.bornim.core.art.HeroFigure.Strike.KILL_PIERCE, 2))
    val times = listOf(0, 150, 300, 500, 800, 1600)
    val cw = 240; val ch = 170
    val out = BufferedImage(cw * times.size, ch * cases.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = Color(0x46583A); g.fillRect(0, 0, out.width, out.height)
    for ((r, c) in cases.withIndex()) {
        val (id, strike, blood) = c
        val look = de.bornim.core.MonsterLook(3)
        val plan = de.bornim.core.art.KillPlan.of(id, look, strike, blood, 11)
        val ax = de.bornim.core.art.MonsterArt.anchorX(id, 0)
        for ((k, t) in times.withIndex()) {
            val sub = g.create(k * cw, r * ch, cw, ch) as java.awt.Graphics2D
            sub.translate((cw / 2 - ax).toInt(), (ch - 12 - plan.ground).toInt())
            for (p in plan.pieces) {
                val pose = de.bornim.core.art.KillArt.pose(p, t.toDouble(), plan.ground)
                val tr = AffineTransform()
                if (p.topple) tr.rotate(Math.toRadians(pose.angle), p.px, p.py)
                else { tr.translate(pose.dx, pose.dy); tr.rotate(Math.toRadians(pose.angle), p.cx, p.cy) }
                tr.translate(p.ox.toDouble(), p.oy.toDouble())
                sub.drawImage(toImage(p.img), tr, null)
            }
            sub.dispose()
            g.color = Color(0xF0E8D8); g.drawString("$id ${plan.kind} $t ms", k * cw + 4, r * ch + 12)
        }
    }
    ImageIO.write(out, "png", File("build/screens/killerschlag_stuecke.png"))
    println("wrote kill sheet")
}
