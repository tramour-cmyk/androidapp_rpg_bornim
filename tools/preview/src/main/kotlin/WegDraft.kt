package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.Tile
import de.bornim.core.World
import de.bornim.core.art.BattleScene
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.PixelImage
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.GradientPaint
import java.awt.Graphics2D
import java.awt.RenderingHints
import java.awt.geom.Path2D
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin
import kotlin.math.sqrt

/*
 * Drafts for the basic question of how the hero moves through the world (09.10.):
 *  B  side view like the battles: the hero walks through connected scenes (here: the forest path
 *     and the clearing with Garrick's fire), exits at the edges;
 *  C  a drawn travel map of the Whisperwood (ink on parchment), made from the map data;
 *  D  both together: the travel map for the way, the side view for the places.
 * Pictures only, nothing of this is in the game.
 */

private const val SW = 270
private const val SH = 370
private const val K = 2

private fun hash(x: Int, y: Int, s: Int): Int {
    var n = x * 374761393 + y * 668265263 + s * 1442695041
    n = (n xor (n ushr 13)) * 1274126177
    return (n xor (n ushr 16)) and 0x7FFFFFFF
}

private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

/** Smooth value noise, about one bump per [size] pixels. */
private fun smoothNoise(x: Int, y: Int, size: Double, s: Int): Double {
    val fx = x / size; val fy = y / size
    val ix = kotlin.math.floor(fx).toInt(); val iy = kotlin.math.floor(fy).toInt()
    val u = (fx - ix).let { it * it * (3 - 2 * it) }; val v = (fy - iy).let { it * it * (3 - 2 * it) }
    val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
    val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
    return a * (1 - v) + b * v
}

private fun toImage(p: PixelImage): BufferedImage {
    val out = BufferedImage(p.width, p.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until p.height) for (x in 0 until p.width) out.setRGB(x, y, p[x, y])
    return out
}

/** Pastes a figure (alpha cut at half) into a 1x scene image. */
private fun paste(dst: BufferedImage, src: PixelImage, ox: Int, oy: Int) {
    for (y in 0 until src.height) for (x in 0 until src.width) {
        val p = src[x, y]
        if ((p ushr 24) < 128) continue
        val px = ox + x; val py = oy + y
        if (px in 0 until dst.width && py in 0 until dst.height) dst.setRGB(px, py, p or (0xFF shl 24))
    }
}

private fun ch(c: Int, s: Int) = (c shr s) and 0xFF

/** Warm light of a fire: brightens and tints everything around ([cx], [cy]) in a 1x image. */
private fun fireLight(img: BufferedImage, cx: Double, cy: Double, reach: Double, power: Double, flicker: Int) {
    for (y in 0 until img.height) for (x in 0 until img.width) {
        // the ground is seen at a slant, so the light pool is wide and flat
        val dx = (x - cx) / reach; val dy = (y - cy) / (reach * 0.55)
        val d2 = dx * dx + dy * dy
        if (d2 > 4) continue
        val k = power * exp(-d2 * 1.6)
        val c = img.getRGB(x, y)
        fun m(v: Int, tint: Double) = (v + (255 - v) * k * 0.35 * tint + v * k * 0.9 * tint).toInt().coerceIn(0, 255)
        img.setRGB(x, y, (0xFF shl 24) or (m(ch(c, 16), 1.0) shl 16) or (m(ch(c, 8), 0.62) shl 8) or m(ch(c, 0), 0.28))
    }
}

/** A small camp fire in a ring of stones, foot at ([fx], [fy]), in a 1x image. */
private fun campfire(img: BufferedImage, fx: Int, fy: Int, night: Boolean) {
    fun set(x: Int, y: Int, c: Int) { if (x in 0 until img.width && y in 0 until img.height) img.setRGB(x, y, c or (0xFF shl 24)) }
    // ash bed
    for (y in -4..2) for (x in -18..18) if ((x / 18.0) * (x / 18.0) + (y / 4.5) * (y / 4.5) < 1) set(fx + x, fy + y, if (rnd(x, y, 3) < 0.5) 0x2A2420 else 0x1C1816)
    // stones
    for (i in 0 until 9) {
        val a = PI + i * PI / 8 - 0.2
        val sx = fx + (cos(a) * 19).toInt(); val sy = fy + (sin(a) * 4.5).toInt() + 1
        for (y in -3..2) for (x in -4..4) if ((x / 4.2) * (x / 4.2) + (y / 3.0) * (y / 3.0) < 1) {
            val lit = y < 0 && x < 2
            set(sx + x, sy + y, if (lit) 0x8A7E70 else if (y > 0) 0x3A3430 else 0x5E554C)
        }
    }
    // crossed logs, charred at the ends
    for (t in -12..12) {
        for (w in -1..1) {
            set(fx + t, fy - 2 + t / 4 + w, if (kotlin.math.abs(t) < 5) 0x241612 else if (w < 0) 0x6A4A32 else 0x4A3222)
            set(fx + t, fy - 2 - t / 4 + w, if (kotlin.math.abs(t) < 5) 0x241612 else if (w < 0) 0x5E4230 else 0x3E2A1E)
        }
    }
    // flames: tongues from deep red through orange to a pale core
    val tongues = listOf(-6 to 15, -2 to 22, 3 to 19, 7 to 12, 0 to 26)
    for ((ox, hgt) in tongues) for (y in 0 until hgt) {
        val f = y / hgt.toDouble()
        val half = ((1 - f) * (4.5 - kotlin.math.abs(ox) * 0.25) + 0.5).coerceAtLeast(0.5)
        val sway = sin(f * 3.2 + ox) * 2.2 * f
        for (x in (-half).toInt()..half.toInt()) {
            val e = kotlin.math.abs(x) / half
            val c = when {
                f < 0.45 && e < 0.45 -> 0xFFF0B8
                f < 0.7 && e < 0.7 -> 0xFFB648
                f < 0.9 -> 0xF07028
                else -> 0xB83818
            }
            set(fx + ox + x + sway.toInt(), fy - 4 - y, c)
        }
    }
    // sparks
    for (i in 0 until (if (night) 9 else 5)) set(fx - 8 + hash(i, 1, 7) % 18, fy - 30 - hash(i, 2, 7) % 34, if (i % 2 == 0) 0xFFD27A else 0xFF8A3A)
}

/** Darkens the edges a little more, like the battle scenes do, so the light reads. */
private fun vignette(img: BufferedImage, a: Double) {
    val cx = img.width / 2.0; val cy = img.height * 0.55
    for (y in 0 until img.height) for (x in 0 until img.width) {
        val d = sqrt(((x - cx) / cx).let { it * it } + ((y - cy) / cy).let { it * it }) / 1.25
        val k = 1 - a * (d * d).coerceIn(0.0, 1.0)
        val c = img.getRGB(x, y)
        img.setRGB(x, y, (0xFF shl 24) or ((ch(c, 16) * k).toInt() shl 16) or ((ch(c, 8) * k).toInt() shl 8) or (ch(c, 0) * k).toInt())
    }
}

private fun scaled(src: BufferedImage, k: Int): BufferedImage {
    val out = BufferedImage(src.width * k, src.height * k, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until out.height) for (x in 0 until out.width) out.setRGB(x, y, src.getRGB(x / k, y / k))
    return out
}

private fun Graphics2D.smooth() {
    setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
    setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE)
}

private val serif = Font("DejaVu Serif", Font.PLAIN, 22)
private val sans = Font("DejaVu Sans", Font.PLAIN, 18)

/** A dark plate with a line of text, for the scene overlays. */
private fun Graphics2D.plate(text: String, x: Int, y: Int, font: Font, center: Boolean = false, alpha: Int = 170) {
    this.font = font
    val fm = fontMetrics
    val w = fm.stringWidth(text) + 24; val h = fm.height + 10
    val left = if (center) x - w / 2 else x
    color = Color(10, 8, 8, alpha)
    fillRoundRect(left, y, w, h, 10, 10)
    color = Color(150, 120, 80, 150)
    stroke = BasicStroke(1.5f)
    drawRoundRect(left, y, w, h, 10, 10)
    color = Color(232, 222, 200)
    drawString(text, left + 12, y + 5 + fm.ascent)
}

/** An arrow pointing into the picture along the path, with the place it leads to. */
private fun Graphics2D.ahead(x: Int, y: Int, label: String) {
    stroke = BasicStroke(3.5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
    color = Color(232, 222, 200, 220)
    for (i in 0..1) { val oy = y + i * 12; drawPolyline(intArrayOf(x - 13, x, x + 13), intArrayOf(oy + 8, oy - 4, oy + 8), 3) }
    plate(label, x, y + 28, sans, center = true, alpha = 150)
}

/** The way back, at the bottom edge. */
private fun Graphics2D.back(x: Int, y: Int, label: String) {
    plate("zurück: $label", x, y, sans, center = true, alpha = 150)
}

private fun Graphics2D.chevron(x: Int, y: Int, left: Boolean, label: String) {
    font = sans
    val fm = fontMetrics
    color = Color(232, 222, 200, 220)
    stroke = BasicStroke(3.5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
    val d = if (left) -1 else 1
    for (i in 0..1) {
        val ox = x + d * i * 12
        drawPolyline(intArrayOf(ox - d * 6, ox + d * 6, ox - d * 6), intArrayOf(y - 12, y, y + 12), 3)
    }
    color = Color(10, 8, 8, 160)
    val tw = fm.stringWidth(label)
    val tx = if (left) x + 30 else x - 30 - tw
    fillRoundRect(tx - 8, y - fm.ascent / 2 - 6, tw + 16, fm.height + 4, 8, 8)
    color = Color(232, 222, 200)
    drawString(label, tx, y + fm.ascent / 2 - 2)
}

/** Scene B: one place in side view, as the phone would show it. */
private fun sideScene(spot: BattleScene.Spot, light: BattleScene.Light, fire: Boolean, title: String, back: String, ahead: String, buttons: List<String>, seed: Int, branch: String? = null, aheadX: Double = 0.58): BufferedImage {
    val scene = toImage(BattleScene.forest(SW, SH, spot, light, false, seed))
    val night = light == BattleScene.Light.NIGHT
    val dusk = light == BattleScene.Light.DUSK
    val hero = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    val fx = (SW * 0.53).toInt(); val fy = (SH * 0.80).toInt()
    if (fire) {
        // the fire lights the place before the figures stand in it
        fireLight(scene, fx.toDouble(), fy.toDouble() - 6, if (night) 120.0 else 95.0, if (night) 1.25 else if (dusk) 0.85 else 0.35, seed)
        campfire(scene, fx, fy, night)
        val garrick = GameState.newGame("Garrick", Race.HUMAN, CharClass.ROGUE).hero
        // the same doll as the hero in battle, turned to face the fire and the hero
        val g = HeroBattle.frame(garrick, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 2).mirrored()
        paste(scene, g, (SW * 0.80 - (g.width - HeroBattle.ANCHOR_X)).toInt(), (SH * 0.93 - HeroBattle.GROUND).toInt())
    }
    // the hero exactly as the battle shows it
    val h = HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 3)
    paste(scene, h, (SW * (if (fire) 0.22 else 0.40) - HeroBattle.ANCHOR_X).toInt(), (SH * 0.985 - HeroBattle.GROUND).toInt())
    if (fire) fireLight(scene, fx.toDouble(), fy.toDouble() - 30, 60.0, if (night) 0.35 else 0.2, seed + 1)
    vignette(scene, if (night) 0.35 else 0.2)
    val big = scaled(scene, K)
    val g = big.createGraphics(); g.smooth()
    g.plate(title, big.width / 2, 18, serif, center = true)
    g.ahead((big.width * aheadX).toInt(), (big.height * 0.43).toInt(), ahead)
    g.back(big.width - 150, big.height - 60, back)
    branch?.let { g.chevron(big.width - 26, (big.height * 0.6).toInt(), false, it) }
    var bx = 18
    for (b in buttons) {
        g.font = sans
        val w = g.fontMetrics.stringWidth(b) + 36
        g.color = Color(28, 20, 16, 215); g.fillRoundRect(bx, big.height - 64, w, 46, 12, 12)
        g.color = Color(176, 140, 90, 200); g.stroke = BasicStroke(2f); g.drawRoundRect(bx, big.height - 64, w, 46, 12, 12)
        g.color = Color(236, 226, 204); g.drawString(b, bx + 18, big.height - 34)
        bx += w + 12
    }
    g.dispose()
    return big
}

// ------------------------------------------------------------------ C: travel map

private val INK = Color(46, 34, 26)
private val INK_SOFT = Color(46, 34, 26, 110)
private val SEPIA = Color(120, 82, 46)

/** The Whisperwood as a drawn map: ink on old parchment, made from the map's tiles. */
private fun travelMap(cell: Int, heroX: Int, heroY: Int, explored: Boolean): BufferedImage {
    val map = World["forest"]
    val mw = map.width; val mh = map.height
    val pad = cell * 2
    val w = mw * cell + pad * 2; val h = mh * cell + pad * 2 + cell * 2
    val img = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    // parchment: warm, blotchy, darker at the edges, a few stains
    for (y in 0 until h) for (x in 0 until w) {
        val n = smoothNoise(x, y, 9.0, 1) * 0.45 + smoothNoise(x, y, 41.0, 2) * 0.4 + rnd(x, y, 3) * 0.15
        val ex = (x - w / 2.0) / (w / 2.0); val ey = (y - h / 2.0) / (h / 2.0)
        val edge = (ex * ex + ey * ey).coerceIn(0.0, 1.6)
        val k = 1 - 0.1 * n - 0.32 * edge * edge
        img.setRGB(x, y, Color((222 * k).toInt().coerceIn(0, 255), (200 * k).toInt().coerceIn(0, 255), (156 * k).toInt().coerceIn(0, 255)).rgb)
    }
    val g = img.createGraphics(); g.smooth()
    for (i in 0 until 5) {
        val sx = hash(i, 9, 4) % w; val sy = hash(i, 8, 4) % h; val r = 30 + hash(i, 7, 4) % 70
        g.color = Color(120, 84, 40, 22); g.fillOval(sx - r, sy - r, r * 2, (r * 1.6).toInt())
    }
    fun cx(tx: Int) = pad + tx * cell + cell / 2.0
    fun cy(ty: Int) = pad + cell * 2 + ty * cell + cell / 2.0
    fun t(x: Int, y: Int) = map.tile(x, y)
    // what the hero has seen: in the explored draft only the south half and the clearing
    fun seen(x: Int, y: Int) = !explored || y >= 13 || (x in 4..17 && y in 5..13)

    // water: a pale wash, shore line, ripples
    for (y in 0 until mh) for (x in 0 until mw) if (t(x, y) == Tile.WATER && seen(x, y)) {
        g.color = Color(96, 120, 128, 70)
        g.fillRect((cx(x) - cell / 2).toInt(), (cy(y) - cell / 2).toInt(), cell, cell)
        g.color = Color(60, 80, 92, 120); g.stroke = BasicStroke(1.2f)
        for (k in 0..1) {
            val yy = cy(y) - cell * 0.2 + k * cell * 0.4
            val p = Path2D.Double(); p.moveTo(cx(x) - cell * 0.3, yy)
            p.quadTo(cx(x) - cell * 0.1, yy - 3, cx(x), yy); p.quadTo(cx(x) + cell * 0.1, yy + 3, cx(x) + cell * 0.3, yy)
            g.draw(p)
        }
    }
    g.color = INK; g.stroke = BasicStroke(1.8f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
    for (y in 0 until mh) for (x in 0 until mw) if (t(x, y) == Tile.WATER && seen(x, y)) {
        val l = cx(x) - cell / 2.0; val r = cx(x) + cell / 2.0; val tp = cy(y) - cell / 2.0; val b = cy(y) + cell / 2.0
        fun wob(i: Int) = (rnd(x, y, i) - 0.5) * 3
        if (t(x, y - 1) != Tile.WATER) g.draw(java.awt.geom.Line2D.Double(l, tp + wob(1), r, tp + wob(2)))
        if (t(x, y + 1) != Tile.WATER) g.draw(java.awt.geom.Line2D.Double(l, b + wob(3), r, b + wob(4)))
        if (t(x - 1, y) != Tile.WATER) g.draw(java.awt.geom.Line2D.Double(l + wob(5), tp, l + wob(6), b))
        if (t(x + 1, y) != Tile.WATER) g.draw(java.awt.geom.Line2D.Double(r + wob(7), tp, r + wob(8), b))
    }

    // the path: one point per row in the middle of the trodden strip, joined into smooth curves;
    // long runs across a row are a side way of their own
    fun isPath(x: Int, y: Int) = t(x, y) == Tile.PATH || t(x, y) == Tile.CAVE_ENTRANCE
    val chains = mutableListOf<MutableList<Pair<Double, Double>>>()
    var open = mutableListOf<Pair<MutableList<Pair<Double, Double>>, IntRange>>()
    for (y in 0 until mh) {
        val runs = mutableListOf<IntRange>()
        var x = 0
        while (x < mw) { if (isPath(x, y)) { val a = x; while (x < mw && isPath(x, y)) x++; runs += a until x } else x++ }
        val next = mutableListOf<Pair<MutableList<Pair<Double, Double>>, IntRange>>()
        for (r in runs) {
            if (r.count() >= 4) {
                // a way off to the side: from its inner end to the map edge (and beyond)
                val ends = if (r.last == mw - 1) mw + 1 else r.last
                chains += mutableListOf(cx(r.first) to cy(y), cx(ends) to cy(y))
                continue
            }
            val mid = (cx(r.first) + cx(r.last)) / 2 to cy(y)
            val prev = open.firstOrNull { (_, pr) -> r.first <= pr.last + 1 && r.last >= pr.first - 1 }
            val chain = prev?.first ?: mutableListOf<Pair<Double, Double>>().also { chains += it }
            chain += mid
            next += chain to r
        }
        open = next
    }
    // the way goes on off the map at the bottom (to Bornim)
    for (c in chains) if (c.last().second >= cy(mh - 1)) c += c.last().first to cy(mh) + cell
    fun curve(c: List<Pair<Double, Double>>): Path2D.Double {
        val p = Path2D.Double()
        p.moveTo(c[0].first, c[0].second)
        for (i in 0 until c.size - 1) {
            val p0 = c[maxOf(i - 1, 0)]; val p1 = c[i]; val p2 = c[i + 1]; val p3 = c[minOf(i + 2, c.size - 1)]
            p.curveTo(p1.first + (p2.first - p0.first) / 6, p1.second + (p2.second - p0.second) / 6,
                p2.first - (p3.first - p1.first) / 6, p2.second - (p3.second - p1.second) / 6, p2.first, p2.second)
        }
        return p
    }
    // average a little, so a staircase of tiles becomes a gentle bend
    val smoothChains = chains.filter { it.size >= 2 }.map { c ->
        if (c.size < 4) c else c.indices.map { i -> val a = c[maxOf(i - 1, 0)]; val b = c[minOf(i + 1, c.size - 1)]; (a.first + c[i].first * 2 + b.first) / 4 to c[i].second }
    }
    for (c in smoothChains) {
        fun seenAt(q: Pair<Double, Double>) = seen(((q.first - pad) / cell).toInt().coerceIn(0, mw - 1), ((q.second - pad - cell * 2) / cell).toInt().coerceIn(0, mh - 1))
        if (c.none { seenAt(it) }) continue
        val p = curve(c)
        g.stroke = BasicStroke(cell * 0.7f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.color = Color(150, 112, 70, 60); g.draw(p)
        g.stroke = BasicStroke(1.7f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND, 1f, floatArrayOf(6f, 5f), 0f); g.color = SEPIA; g.draw(p)
    }

    // tall grass: little strokes; flowers: dots
    g.stroke = BasicStroke(1.1f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
    for (y in 0 until mh) for (x in 0 until mw) if (seen(x, y)) when (t(x, y)) {
        Tile.TALL_GRASS -> {
            g.color = INK_SOFT
            for (k in 0 until 3) {
                val bx = cx(x) + (rnd(x, y, k) - 0.5) * cell * 0.8; val by = cy(y) + (rnd(x, y, k + 9) - 0.5) * cell * 0.7
                g.draw(java.awt.geom.Line2D.Double(bx, by, bx - 2, by - 6)); g.draw(java.awt.geom.Line2D.Double(bx, by, bx + 1, by - 7)); g.draw(java.awt.geom.Line2D.Double(bx, by, bx + 3, by - 5))
            }
        }
        Tile.FLOWERS -> {
            g.color = Color(130, 60, 50, 140)
            for (k in 0 until 4) g.fillOval((cx(x) + (rnd(x, y, k) - 0.5) * cell * 0.8).toInt(), (cy(y) + (rnd(x, y, k + 5) - 0.5) * cell * 0.7).toInt(), 3, 3)
        }
        else -> {}
    }

    // things on the map: rocks, logs, standing stones, chests, signs
    for (y in 0 until mh) for (x in 0 until mw) if (seen(x, y)) {
        val px = cx(x); val py = cy(y)
        when (t(x, y)) {
            Tile.ROCK -> { g.color = Color(150, 130, 100); g.fillOval((px - 7).toInt(), (py - 4).toInt(), 14, 10); g.color = INK; g.stroke = BasicStroke(1.5f); g.drawOval((px - 7).toInt(), (py - 4).toInt(), 14, 10) }
            Tile.LOG -> { g.color = INK; g.stroke = BasicStroke(5f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(java.awt.geom.Line2D.Double(px - cell * 0.45, py, px + cell * 0.45, py)) }
            Tile.MENHIR -> {
                val p = Path2D.Double(); p.moveTo(px - 5, py + 6); p.lineTo(px - 4, py - 10); p.lineTo(px + 1, py - 13); p.lineTo(px + 5, py - 8); p.lineTo(px + 5, py + 6); p.closePath()
                g.color = Color(170, 150, 120); g.fill(p); g.color = INK; g.stroke = BasicStroke(1.6f); g.draw(p)
            }
            else -> {}
        }
    }

    // trees: crowns drawn back to front, each covering the one behind it, shaded on the lower right
    for (y in 0 until mh) for (x in 0 until mw) if (t(x, y) == Tile.TREE && seen(x, y)) {
        val px = cx(x) + (rnd(x, y, 1) - 0.5) * cell * 0.4; val py = cy(y) + (rnd(x, y, 2) - 0.5) * cell * 0.4
        val pine = hash(x, y, 5) % 4 == 0
        val r = cell * (0.55 + rnd(x, y, 3) * 0.2)
        val crown = Path2D.Double()
        if (pine) {
            crown.moveTo(px, py - r * 1.3); crown.lineTo(px + r * 0.7, py + r * 0.5); crown.lineTo(px - r * 0.7, py + r * 0.5); crown.closePath()
        } else {
            val n = 9
            for (i in 0..n) {
                val a = i * 2 * PI / n
                val rr = r * (0.82 + 0.25 * rnd(x * 7 + i, y, 4))
                val qx = px + cos(a) * rr; val qy = py + sin(a) * rr * 0.9
                if (i == 0) crown.moveTo(qx, qy) else crown.quadTo(px + cos(a - PI / n) * rr * 1.18, py + sin(a - PI / n) * rr * 1.06, qx, qy)
            }
            crown.closePath()
        }
        g.color = INK; g.stroke = BasicStroke(2f); g.draw(java.awt.geom.Line2D.Double(px, py + r * 0.5, px, py + r * 0.95))
        g.color = Color(214, 192, 148); g.fill(crown)
        // hatching in the shadow side
        val clip = g.clip; g.clip(crown)
        g.color = INK_SOFT; g.stroke = BasicStroke(1f)
        var s = -r
        while (s < r * 2) { g.draw(java.awt.geom.Line2D.Double(px + s, py + r, px + s + r, py)); s += 3.2 }
        g.clip = clip
        g.color = Color(214, 192, 148); g.fill(java.awt.geom.Ellipse2D.Double(px - r * 0.85, py - r * 0.95, r * 1.1, r * 1.0))
        g.color = INK; g.stroke = BasicStroke(1.7f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND); g.draw(crown)
    }

    // the fog of the unexplored: a faint wash, ragged edge
    if (explored) {
        // soft, cloudy patches over everything not yet seen, thicker the deeper into the unknown
        for (y in 0 until mh) for (x in 0 until mw) if (!seen(x, y)) {
            val r = cell * (1.05 + rnd(x, y, 11) * 0.5)
            val px = cx(x) + (rnd(x, y, 12) - 0.5) * cell * 0.6; val py = cy(y) + (rnd(x, y, 13) - 0.5) * cell * 0.6
            g.paint = java.awt.RadialGradientPaint(px.toFloat(), py.toFloat(), r.toFloat(), floatArrayOf(0f, 0.55f, 1f),
                arrayOf(Color(206, 186, 146, 235), Color(206, 186, 146, 170), Color(206, 186, 146, 0)))
            g.fill(java.awt.geom.Ellipse2D.Double(px - r, py - r, r * 2, r * 2))
        }
        g.paint = null
    }

    // places: the fire, the cave mouth, chests; labels in a hand
    fun label(text: String, x: Double, y: Double, size: Float = 21f, italic: Boolean = true) {
        g.font = serif.deriveFont(if (italic) Font.ITALIC else Font.PLAIN, size)
        val fm = g.fontMetrics; val tw = fm.stringWidth(text)
        g.color = Color(222, 200, 156, 200); g.fillRect((x - tw / 2 - 4).toInt(), (y - fm.ascent + 2).toInt(), tw + 8, fm.ascent + 2)
        g.color = INK; g.drawString(text, (x - tw / 2).toFloat(), y.toFloat())
    }
    for (y in 0 until mh) for (x in 0 until mw) if (seen(x, y)) when (t(x, y)) {
        Tile.CAMPFIRE -> {
            val px = cx(x); val py = cy(y)
            g.color = Color(190, 70, 30); val p = Path2D.Double()
            p.moveTo(px, py - 12); p.quadTo(px + 8, py - 2, px + 4, py + 5); p.lineTo(px - 4, py + 5); p.quadTo(px - 8, py - 2, px, py - 12); g.fill(p)
            g.color = INK; g.stroke = BasicStroke(1.5f); g.draw(p)
        }
        Tile.CHEST -> {
            val px = cx(x); val py = cy(y)
            g.color = Color(140, 96, 52); g.fillRect((px - 6).toInt(), (py - 4).toInt(), 12, 9)
            g.color = INK; g.stroke = BasicStroke(1.4f); g.drawRect((px - 6).toInt(), (py - 4).toInt(), 12, 9)
        }
        else -> {}
    }
    if (seen(10, 1)) {
        // the cave: a dark arch in the rock line at the top
        val px = cx(10); val py = cy(0) + cell * 0.2
        g.color = Color(40, 30, 24); g.fill(java.awt.geom.Arc2D.Double(px - 14, py - 14, 28.0, 28.0, 0.0, 180.0, java.awt.geom.Arc2D.CHORD))
        label("Blutzahn-Höhle", px + cell * 3.6, py + 4)
    }
    label("Garricks Feuer", cx(11), cy(9) + cell * 1.4)
    label("Weiher", cx(3), cy(14) + 6)
    label("Steinkreis", cx(15), cy(26) + cell * 1.5)
    label("nach Bornim", cx(10), h - cell * 0.6, 19f)
    if (!explored || seen(19, 10)) {
        g.font = serif.deriveFont(Font.ITALIC, 19f)
        val fm = g.fontMetrics
        val text = "Tiefer Wald"
        g.color = INK
        val at = g.transform
        g.rotate(-PI / 2, w - cell * 0.75, cy(10).toDouble())
        g.drawString(text, (w - cell * 0.75 - fm.stringWidth(text) / 2).toFloat(), (cy(10)).toFloat())
        g.transform = at
    }
    // title and frame
    g.font = serif.deriveFont(Font.BOLD, 34f)
    val title = "Flüsterwald"
    g.color = INK; g.drawString(title, (w - g.fontMetrics.stringWidth(title)) / 2f, pad + cell * 0.55f)
    g.stroke = BasicStroke(2.2f); g.drawRect(pad / 2, pad / 2, w - pad, h - pad)
    g.stroke = BasicStroke(1f); g.drawRect(pad / 2 + 5, pad / 2 + 5, w - pad - 10, h - pad - 10)
    // compass rose
    val rx = w - pad - cell * 1.6; val ry = h - pad - cell * 1.6
    g.stroke = BasicStroke(1.4f)
    for (i in 0 until 4) {
        val a = i * PI / 2 - PI / 2
        val p = Path2D.Double(); p.moveTo(rx, ry); p.lineTo(rx + cos(a - 0.3) * 8, ry + sin(a - 0.3) * 8); p.lineTo(rx + cos(a) * 26, ry + sin(a) * 26); p.closePath()
        g.color = if (i == 0) INK else Color(222, 200, 156); g.fill(p); g.color = INK; g.draw(p)
    }
    g.font = serif.deriveFont(Font.BOLD, 16f); g.drawString("N", (rx - 5).toFloat(), (ry - 30).toFloat())
    // the hero: a red pin
    val hx = cx(heroX); val hy = cy(heroY)
    g.color = Color(0, 0, 0, 60); g.fillOval((hx - 6).toInt(), (hy + 2).toInt(), 12, 5)
    g.color = Color(150, 30, 26); g.fillOval((hx - 7).toInt(), (hy - 22).toInt(), 14, 14)
    g.stroke = BasicStroke(2.5f); g.draw(java.awt.geom.Line2D.Double(hx, hy - 9, hx, hy + 3))
    g.color = INK; g.stroke = BasicStroke(1.3f); g.drawOval((hx - 7).toInt(), (hy - 22).toInt(), 14, 14)
    g.dispose()
    return img
}

private fun stamp(img: BufferedImage, text: String): BufferedImage {
    val out = BufferedImage(img.width, img.height + 30, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.smooth()
    g.color = Color(18, 16, 20); g.fillRect(0, 0, out.width, out.height)
    g.drawImage(img, 0, 0, null)
    g.font = Font("DejaVu Sans", Font.PLAIN, 15); g.color = Color(170, 162, 148)
    g.drawString(text, 8, img.height + 21)
    g.dispose()
    return out
}

private fun row(vararg imgs: BufferedImage, gap: Int = 14): BufferedImage {
    val w = imgs.sumOf { it.width } + gap * (imgs.size - 1); val h = imgs.maxOf { it.height }
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = Color(18, 16, 20); g.fillRect(0, 0, w, h)
    var x = 0
    for (i in imgs) { g.drawImage(i, x, 0, null); x += i.width + gap }
    g.dispose()
    return out
}

fun renderWayDrafts() {
    val dir = File("build/screens"); dir.mkdirs()
    val when_ = java.time.ZonedDateTime.now(java.time.ZoneId.of("Europe/Berlin")).format(java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy, HH:mm"))
    val lights = listOf(BattleScene.Light.DAY to "Tag", BattleScene.Light.DUSK to "Dämmerung", BattleScene.Light.NIGHT to "Nacht")
    // B: the clearing with the fire at three times of day, and the forest path
    val clearing = lights.map { (l, _) -> sideScene(BattleScene.Spot.CLEARING, l, true, "Garricks Feuer", "Waldweg", "Blutzahn-Höhle", listOf("Reden", "Rasten"), 21, branch = "Tiefer Wald", aheadX = 0.62) }
    ImageIO.write(stamp(row(*clearing.toTypedArray()), "Entwurf B: Blick hinter dem Helden wie im Kampf · Lichtung mit Feuer bei Tag, Dämmerung, Nacht · erstellt $when_ (Berliner Zeit)"), "png", File(dir, "weg_b_lichtung.png"))
    val path = sideScene(BattleScene.Spot.EDGE, BattleScene.Light.DUSK, false, "Flüsterwald · Waldweg", "Bornim", "Garricks Feuer", listOf("Umsehen"), 13, branch = "Weiher", aheadX = 0.6)
    val pond = sideScene(BattleScene.Spot.POND, BattleScene.Light.DUSK, false, "Flüsterwald · Weiher", "Waldweg", "Steinkreis", listOf("Kräuter sammeln"), 17, aheadX = 0.54)
    ImageIO.write(stamp(row(path, clearing[1], pond), "Entwurf B: Orte hintereinander am Weg (voraus, zurück, abbiegen) · Waldweg, Lichtung, Weiher in der Dämmerung · erstellt $when_ (Berliner Zeit)"), "png", File(dir, "weg_b_szenen.png"))
    // C: the drawn travel map, fully and as far as explored
    val full = travelMap(24, 10, 10, false)
    val part = travelMap(24, 10, 10, true)
    ImageIO.write(stamp(row(full, part), "Entwurf C: gezeichnete Reisekarte des Flüsterwalds aus den Kartendaten · links ganz, rechts so weit erkundet · erstellt $when_ (Berliner Zeit)"), "png", File(dir, "weg_c_karte.png"))
    // D: the map for the way, the scene for the place
    val small = travelMap(17, 10, 10, true)
    ImageIO.write(stamp(row(small, clearing[1]), "Entwurf D: Reisekarte für den Weg, Ansicht wie im Kampf am Ort (Tippen auf „Garricks Feuer“ öffnet die Szene) · erstellt $when_ (Berliner Zeit)"), "png", File(dir, "weg_d_beides.png"))
    println("wrote way drafts")
}
