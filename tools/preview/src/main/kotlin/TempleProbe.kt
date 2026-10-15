package preview

import java.awt.AlphaComposite
import java.awt.Color
import java.awt.GradientPaint
import java.awt.MultipleGradientPaint
import java.awt.RadialGradientPaint
import java.awt.geom.Ellipse2D
import java.awt.geom.Path2D
import java.awt.geom.Point2D
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.hypot
import kotlin.math.sin

/**
 * 68 (draft): the temple scene at the end of chapter 1 in five pictures, in the style of the intro (70): eye level, light only
 * from candles, windows and the first sun, figures known by outline and mark (`LISTE-FIGUREN.md`), the hero never in the picture.
 * The temple is the one of the game (`Story.temple`: altar between two candlesticks at the north wall, two blocks of pews with an
 * aisle, lectern, font, door in the south wall, windows north, east and south), one tile = [TemplePainter.T] metres.
 * TEMPEL68=1..5 (or anything else: all) writes `build/screens/tempel68_<n>.png` and `_text.png`.
 */
fun renderTempleProbe() {
    File("build/screens").mkdirs()
    val texts = mapOf(
        1 to "Der Tempel ist voll. Tagelang war er kalt und leer.",
        2 to "Aldric gibt Lyra das Amulett. Sie hält es lange, als könnte es zerbrechen.",
        3 to "Osric hält die Kerze ruhig. Lyra betet in Worten, die älter sind als der Tempel selbst.",
        4 to "Das erste Licht des Tages fällt durchs Fenster. Das Amulett fängt es auf.",
        5 to "Bornim atmet auf. Nur Lyra sieht noch lange ins Grau hinaus.",
    )
    val only = System.getenv("TEMPEL68")?.toIntOrNull()
    for (n in 1..5) {
        if (only != null && only != n) continue
        val img = TemplePainter(n).paint()
        ImageIO.write(img, "png", File("build/screens/tempel68_$n.png"))
        ImageIO.write(withText(img, texts.getValue(n)), "png", File("build/screens/tempel68_${n}_text.png"))
        println("wrote build/screens/tempel68_${n}_text.png")
    }
}

/**
 * One picture of the temple scene. The room is laid out on the temple's floor plan (tile x east, y south; inner floor from
 * x 1 to 8 and y 1 to 6) and seen through the camera of picture [shot].
 */
internal class TemplePainter(val shot: Int) : IntroPainter() {
    /** Where the eye stands (tile), where it looks (degrees from north), how high the horizon sits in the picture. */
    data class Cam(val tx: Double, val ty: Double, val yaw: Double, val hy: Double)
    val cam = when (shot) {
        1 -> Cam(7.45, 5.8, 328.0, 600.0)    // the back corner by the door: the full pews at a slant, the empty altar beyond
        2 -> Cam(4.15, 3.75, 8.0, 560.0)     // first row, by the aisle: Aldric and Lyra before the altar
        3 -> Cam(4.55, 3.8, 6.0, 560.0)      // first row: Lyra at the altar, Osric with the candle
        4 -> Cam(3.65, 3.8, 14.0, 560.0)     // first row, left: the sun through the east window onto the amulet
        else -> Cam(4.5, 3.2, 180.0, 600.0)  // the nave, turned to the door: Lyra in it, the grey morning outside
    }
    override val hy = cam.hy; override val eye = 1.65; override val camX = 0.0; override val pan = 0.0
    /** A wider lens inside than outside: the nave is only 11 m wide and the eye stands in it (picture 1 at the door). */
    override val f = when (shot) { 1 -> 680.0; 4 -> 720.0; 5 -> 760.0; else -> 760.0 }
    override val moonX = -999.0; override val moonY = -999.0
    val T = 1.6
    val wallH = 6.0
    private val yawR = cam.yaw * PI / 180
    fun ex(tx: Double, ty: Double) = (tx - cam.tx) * T
    fun en(tx: Double, ty: Double) = -(ty - cam.ty) * T
    fun cx(tx: Double, ty: Double) = ex(tx, ty) * cos(yawR) - en(tx, ty) * sin(yawR)
    fun cz(tx: Double, ty: Double) = ex(tx, ty) * sin(yawR) + en(tx, ty) * cos(yawR)
    fun P(tx: Double, y: Double, ty: Double) = Point2D.Double(sx(cx(tx, ty), cz(tx, ty)), sy(y, cz(tx, ty)))

    /** A polygon of the room (tile x, height, tile y), cut off before the eye so nothing behind it folds over. */
    fun room(vararg q: Triple<Double, Double, Double>): Path2D.Double? {
        val pts = q.map { (tx, y, ty) -> Triple(cx(tx, ty), y, cz(tx, ty)) }
        val zMin = 0.25
        val out = ArrayList<Triple<Double, Double, Double>>()
        for (i in pts.indices) {
            val a = pts[i]; val b = pts[(i + 1) % pts.size]
            if (a.third >= zMin) out += a
            if ((a.third >= zMin) != (b.third >= zMin)) { val t = (zMin - a.third) / (b.third - a.third)
                out += Triple(a.first + (b.first - a.first) * t, a.second + (b.second - a.second) * t, zMin) }
        }
        if (out.size < 3) return null
        return Path2D.Double().apply { out.forEachIndexed { i, (x, y, z) -> if (i == 0) moveTo(sx(x, z), sy(y, z)) else lineTo(sx(x, z), sy(y, z)) }; closePath() }
    }
    fun fillR(c: Color, vararg q: Triple<Double, Double, Double>) { room(*q)?.let { g.color = c; g.fill(it) } }
    fun t3(tx: Double, y: Double, ty: Double) = Triple(tx, y, ty)
    fun depth(tx: Double, ty: Double) = cz(tx, ty)

    // ---- the light of each picture
    val dawn = shot == 5
    val sun = shot == 4
    /** The candles that burn (tile x, height, tile y): on the altar, the two tall candlesticks, Osric's candle. */
    val candles: List<Triple<Double, Double, Double>> by lazy { buildList {
        if (!dawn) {
            for (k in 0 until 5) add(Triple(3.25 + k * 0.62, 1.22, 1.45))
            add(Triple(2.5, 1.75, 1.5)); add(Triple(6.5, 1.75, 1.5))
            if (shot == 3) add(Triple(5.05, 1.25, 2.55))
            // the village brought its own candles: some hold one before them (picture 1 and the first row)
            for (p in peopleList) if (p.holds) add(Triple(p.tx, if (p.seated) 0.95 else 1.15, p.ty - 0.18))
        } else { add(Triple(2.5, 1.75, 1.5)) }
    } }
    /** How warm the light is at a point of the room (0 none .. about 1 beside a candle). */
    fun warmth(tx: Double, y: Double, ty: Double): Double = candles.sumOf { (cx0, cy, cy0) ->
        val d = hypot(hypot((tx - cx0) * T, (ty - cy0) * T), y - cy); 0.3 / (1 + d * d * 0.6) }.coerceAtMost(1.0) * (if (dawn) 0.5 else if (sun) 0.6 else 1.0)

    val stoneDay = 0x8A867A; val woodDay = 0x5A4030
    fun stoneAt(tx: Double, y: Double, ty: Double, k: Double = 1.0): Color {
        val w = warmth(tx, y, ty).coerceAtMost(1.2)
        val base = if (dawn) mix(night(stoneDay, 0.85 * k), Color(0x6A7080), 0.25) else night(stoneDay, 0.38 * k)
        return mix(base, Color((0xA0 * k).toInt().coerceAtMost(255), (0x6E * k).toInt().coerceAtMost(255), (0x40 * k).toInt().coerceAtMost(255)), w * 0.6)
    }

    override fun scene() {
        g.color = Color(0x05060A); g.fillRect(0, 0, W * SS, H * SS)
        walls()
        floor()
        // the furniture and the people, far ones first
        val items = ArrayList<Pair<Double, () -> Unit>>()
        items += depth(4.5, 1.5) to { altar() }
        items += depth(2.5, 1.5) to { candlestick(2.5, 1.5) }
        items += depth(6.5, 1.5) to { candlestick(6.5, 1.5) }
        items += depth(5.6, 2.55) to { lectern(5.6, 2.55) }
        items += depth(3.5, 5.5) to { font(3.5, 5.5) }
        for (ty in listOf(3.0, 4.0)) for ((a, b) in listOf(1.15 to 3.95, 5.05 to 7.85)) items += depth((a + b) / 2, ty + 0.6) to { pew(a, b, ty) }
        for (p in peopleList) {
            items += depth(p.tx, p.ty) - 0.05 to { person(p) }
            // a candle held before the body: hidden by it from behind, its glow round the head and shoulders
            if (p.holds) items += depth(p.tx, p.ty - 0.18) to { val z = cz(p.tx, p.ty - 0.18); if (z > 0.4) { val c = P(p.tx, if (p.seated) 0.95 else 1.15, p.ty - 0.18)
                glow(c.x, c.y, f * 0.9 / z, Color(0xFFB060), 0.35); glow(c.x, c.y, f * 0.25 / z, Color(0xFFE0A0), 0.5) } }
        }
        for ((_, draw) in items.sortedByDescending { it.first }) draw()
        if (sun) sunBeam()
        motes()
        vignette()
    }

    // ---- the room

    /** The four walls of dressed stone in courses, the windows in them, the dark roof timbers above. */
    fun walls() {
        val x0 = 1.0; val x1 = 8.0; val y0 = 1.0; val y1 = 6.0
        // the ceiling: dark boards and beams across
        fillR(Color(0x0A0907), t3(x0, wallH, y0), t3(x1, wallH, y0), t3(x1, wallH, y1), t3(x0, wallH, y1))
        for (k in 0..6) { val ty = y0 + (y1 - y0) * k / 6.0
            room(t3(x0, wallH - 0.05, ty - 0.08), t3(x1, wallH - 0.05, ty - 0.08), t3(x1, wallH - 0.05, ty + 0.08), t3(x0, wallH - 0.05, ty + 0.08))?.let { g.color = mix(Color(0x16100A), Color(0x5A3A1E), warmth(4.5, wallH, ty) * 0.6); g.fill(it) } }
        // each wall: (corner a, corner b) along it, the windows and the door on it
        data class Wall(val ax: Double, val ay: Double, val bx: Double, val by: Double, val openings: List<Triple<Double, Double, Double>>)
        val list = listOf(
            Wall(x0, y0, x1, y0, listOf(Triple(0.5, 2.2, 4.4), Triple(6.5, 2.2, 4.4))),   // north: windows at tiles 1 and 7, flanking the altar
            Wall(x1, y0, x1, y1, listOf(Triple(2.5, 2.0, 4.4))),                          // east: the window at tile row 3
            Wall(x1, y1, x0, y1, listOf(Triple(1.5, 2.0, 4.2), Triple(6.5, 2.0, 4.2), Triple(3.5, 0.0, 2.7))), // south: windows at 6 and 1, the door at 4
            Wall(x0, y1, x0, y0, emptyList()),                                             // west: no window (as the map has it)
        )
        for (w in list) {
            val len = hypot(w.bx - w.ax, w.by - w.ay)
            fun at(u: Double, y: Double) = t3(w.ax + (w.bx - w.ax) * u / len, y, w.ay + (w.by - w.ay) * u / len)
            val shape = room(at(0.0, 0.0), at(len, 0.0), at(len, wallH), at(0.0, wallH)) ?: continue
            val mid = at(len / 2, 2.0)
            g.color = stoneAt(mid.first, 2.0, mid.third, 0.9); g.fill(shape)
            val clip = g.clip; g.clip(shape)
            // warm light from the candles lies on the wall in soft pools
            for ((cx0, cy, cy0) in candles) {
                val c = P(cx0, cy, cy0); val z = cz(cx0, cy0); if (z < 0.3) continue
                glow(c.x, c.y, f * 2.4 / z, Color(0xE08A3A), if (dawn) 0.06 else 0.16)
            }
            // courses and joints
            var y = 0.0; var row = 0
            while (y < wallH) {
                val h = 0.38 + 0.08 * rnd(row, 641)
                val a = P(at(0.0, y).first, y, at(0.0, y).third); val b = P(at(len, y).first, y, at(len, y).third)
                if (cz(at(0.0, y).first, at(0.0, y).third) > 0.3 && cz(at(len, y).first, at(len, y).third) > 0.3) line(alpha(Color(0x16161A), 0.7), 1.2, a.x, a.y, b.x, b.y)
                else room(at(0.0, y), at(len, y), at(len, y + 0.02), at(0.0, y + 0.02))?.let { g.color = alpha(Color(0x16161A), 0.7); g.fill(it) }
                var u = rnd(row, 642) * 0.9
                while (u < len * T) { val uu = u / T
                    val p0 = at(uu, y); val p1 = at(uu, minOf(wallH, y + h))
                    if (cz(p0.first, p0.third) > 0.3) { val s0 = P(p0.first, p0.second, p0.third); val s1 = P(p1.first, p1.second, p1.third); line(alpha(Color(0x16161A), 0.6), 1.0, s0.x, s0.y, s1.x, s1.y) }
                    u += 0.55 + 0.45 * rnd((u * 10).toInt(), row) }
                y += h; row++
            }
            texture(shape, maxOf(1.0, cz(mid.first, mid.third)), Color(0x1A1A20), night(0x9A968A, 0.9), 160, 0.012)
            // high up the wall goes into the dark of the roof
            val top = P(mid.first, wallH, mid.third); val low = P(mid.first, 3.0, mid.third)
            g.paint = GradientPaint(0f, top.y.toFloat(), alpha(Color(0x05060A), 0.85), 0f, low.y.toFloat(), alpha(Color(0x05060A), 0.0)); g.fill(shape)
            g.clip = clip
            for ((u, v0, v1) in w.openings) opening(::at, u, v0, v1, w === list[2] && v0 == 0.0, w === list[1])
        }
    }

    /**
     * A window (or the door, [door]) in a wall: a pointed arch with a deep stone reveal, lead in diamonds, the sky behind:
     * night-blue before the dawn, grey in the morning, the sun itself in the east window of picture 4 ([east]).
     */
    fun opening(at: (Double, Double) -> Triple<Double, Double, Double>, u: Double, v0: Double, v1: Double, door: Boolean, east: Boolean) {
        val hw = if (door) 0.42 else 0.2
        fun arch(r: Double, top: Double): Path2D.Double? {
            // a pointed arch: two arcs of radius 2r from the springing line, meeting at [top]
            val spring = top - r * 1.73
            val pts = ArrayList<Triple<Double, Double, Double>>()
            pts += at(u - r, v0); pts += at(u - r, spring)
            for (j in 1..8) { val ang = PI / 3 * j / 8; pts += at(u + r - 2 * r * cos(ang), spring + 2 * r * sin(ang)) }
            for (j in 7 downTo 0) { val ang = PI / 3 * j / 8; pts += at(u - r + 2 * r * cos(ang), spring + 2 * r * sin(ang)) }
            pts += at(u + r, v0)
            return room(*pts.toTypedArray())
        }
        val frame = arch(hw + 0.12, v1 + 0.12) ?: return
        val mid = at(u, (v0 + v1) / 2)
        g.color = stoneAt(mid.first, mid.second, mid.third, 1.15); g.fill(frame)
        val glass = arch(hw, v1) ?: return
        val b = glass.bounds2D
        val sky = when {
            sun && east -> GradientPaint(0f, b.y.toFloat(), Color(0xFFE8B0), 0f, (b.y + b.height).toFloat(), Color(0xF0A050))
            sun -> GradientPaint(0f, b.y.toFloat(), Color(0x5A6A8A), 0f, (b.y + b.height).toFloat(), Color(0x8A7A70))
            dawn -> GradientPaint(0f, b.y.toFloat(), Color(0x8A909A), 0f, (b.y + b.height).toFloat(), Color(0xA8A8A6))
            else -> GradientPaint(0f, b.y.toFloat(), Color(0x0E1428), 0f, (b.y + b.height).toFloat(), Color(0x1E2A48))
        }
        g.paint = sky; g.fill(glass)
        if (door) { if (dawn) outside(glass); return }
        val clip = g.clip; g.clip(glass)
        // the lead: diamonds
        val n = 7
        for (k in -n..n) {
            val a0 = at(u + k * hw / 3.0 - hw * 2, v0); val a1 = at(u + k * hw / 3.0 + hw * 2, v1 + 0.5)
            val b0 = at(u + k * hw / 3.0 + hw * 2, v0); val b1 = at(u + k * hw / 3.0 - hw * 2, v1 + 0.5)
            val p0 = P(a0.first, a0.second, a0.third); val p1 = P(a1.first, a1.second, a1.third); val q0 = P(b0.first, b0.second, b0.third); val q1 = P(b1.first, b1.second, b1.third)
            line(alpha(Color(0x0A0A0C), 0.8), 1.2, p0.x, p0.y, p1.x, p1.y); line(alpha(Color(0x0A0A0C), 0.8), 1.2, q0.x, q0.y, q1.x, q1.y)
        }
        g.clip = clip
        if (sun && east) glow(b.centerX, b.centerY, b.height * 1.4, Color(0xFFD080), 0.5)
    }

    /**
     * Picture 5: the grey morning through the open door, as the village map has it south of the temple: the path down to the
     * lower street, the river beyond as a pale line, the fields of the south bank and the trees at the edge in the mist.
     */
    fun outside(door: Path2D.Double) {
        val clip = g.clip; g.clip(door)
        val b = door.bounds2D
        val h0 = hy
        // the sky: grey, lighter low down where the sun will come
        g.paint = GradientPaint(0f, b.y.toFloat(), Color(0x7A808C), 0f, h0.toFloat(), Color(0xB8B4AC)); g.fill(b)
        // the trees at the edge of the village, soft in the mist
        val tree = Path2D.Double(); tree.moveTo(b.x, h0 + 2)
        var x = b.x; var k = 0
        while (x <= b.x + b.width) { tree.lineTo(x, h0 - 10 - 14 * (0.5 + 0.5 * sin(x * 0.11 + 1.7)) - 6 * rnd(k++, 941)); x += 4 }
        tree.lineTo(b.x + b.width, h0 + 2); tree.closePath()
        g.color = Color(0x6A6E70); g.fill(tree)
        // the ground beyond the threshold: grass grey-green, the fields, the river line
        g.paint = GradientPaint(0f, h0.toFloat(), Color(0x8A8C84), 0f, (b.y + b.height).toFloat(), Color(0x4A5048)); g.fill(java.awt.geom.Rectangle2D.Double(b.x, h0, b.width, b.height))
        g.color = Color(0x9A9478); g.fill(java.awt.geom.Rectangle2D.Double(b.x, h0 + 3, b.width, 4.0))
        line(Color(0xC8CCD0), 2.0, b.x, h0 + 10, b.x + b.width, h0 + 10)
        // the path from the door down to the lower street, narrowing into the distance
        val cxp = b.centerX
        g.color = Color(0x8A7E6A); g.fill(Path2D.Double().apply { moveTo(cxp - b.width * 0.42, b.y + b.height); lineTo(cxp - 3, h0 + 16); lineTo(cxp + 3, h0 + 16); lineTo(cxp + b.width * 0.42, b.y + b.height); closePath() })
        g.color = Color(0x7A705E); g.fill(java.awt.geom.Rectangle2D.Double(b.x, h0 + 15, b.width, 3.0))
        // mist lying over it all
        g.paint = GradientPaint(0f, (h0 - 30).toFloat(), alpha(Color(0xC8C8C4), 0.0), 0f, (h0 + 8).toFloat(), alpha(Color(0xC8C8C4), 0.6)); g.fill(java.awt.geom.Rectangle2D.Double(b.x, h0 - 30, b.width, 38.0))
        g.paint = GradientPaint(0f, (h0 + 8).toFloat(), alpha(Color(0xC8C8C4), 0.6), 0f, (h0 + 60).toFloat(), alpha(Color(0xC8C8C4), 0.0)); g.fill(java.awt.geom.Rectangle2D.Double(b.x, h0 + 8, b.width, 52.0))
        g.clip = clip
    }

    /** The floor of big stone flags in loose courses, worn in the aisle, warm round the candles. */
    fun floor() {
        val x0 = 1.0; val x1 = 8.0; val y0 = 1.0; val y1 = 6.0
        fillR(stoneAt(4.5, 0.0, 3.5, 0.75), t3(x0, 0.0, y0), t3(x1, 0.0, y0), t3(x1, 0.0, y1), t3(x0, 0.0, y1))
        var ty = y0; var row = 0
        while (ty < y1) {
            val d = 0.42 + 0.18 * rnd(row, 501)
            var tx = x0 - rnd(row, 502) * 0.5
            while (tx < x1) {
                val w = 0.5 + 0.4 * rnd((tx * 10).toInt(), row + 3)
                val a = maxOf(x0, tx); val b = minOf(x1, tx + w); val c = minOf(y1, ty + d)
                val v = rnd((tx * 13).toInt(), row + 7)
                val k = 0.68 + 0.22 * v - (if (abs((a + b) / 2 - 4.5) < 0.5) 0.04 else 0.0)
                fillR(stoneAt((a + b) / 2, 0.0, (ty + c) / 2, k), t3(a + 0.02, 0.0, ty + 0.02), t3(b - 0.02, 0.0, ty + 0.02), t3(b - 0.02, 0.0, c - 0.02), t3(a + 0.02, 0.0, c - 0.02))
                tx += w
            }
            ty += d; row++
        }
        // the candles' light on the floor
        for ((cx0, _, cy0) in candles) { val z = cz(cx0, cy0); if (z < 0.3) continue
            groundPool(cx(cx0, cy0), z, 3.0, Color(0xE08A3A), if (dawn) 0.12 else 0.3, 0.32) }
        if (dawn) { val z = cz(4.5, 6.0); if (z > 0.3) groundPool(cx(4.5, 6.0), z - 1.6, 3.2, Color(0xA8B0C0), 0.35, 0.3) }
    }

    /** The altar: a long block of pale stone, a white cloth with the gold sun on its front, candles, the sun stand in the middle. */
    fun altar() {
        val a = 3.05; val b = 5.95; val n = 1.15; val s = 1.85; val h = 1.0
        val front = room(t3(a, 0.0, s), t3(b, 0.0, s), t3(b, h, s), t3(a, h, s))
        val side = if (cx(a, s) > 0) room(t3(a, 0.0, n), t3(a, 0.0, s), t3(a, h, s), t3(a, h, n)) else room(t3(b, 0.0, s), t3(b, 0.0, n), t3(b, h, n), t3(b, h, s))
        val top = room(t3(a - 0.05, h, n - 0.05), t3(b + 0.05, h, n - 0.05), t3(b + 0.05, h, s + 0.05), t3(a - 0.05, h, s + 0.05))
        side?.let { g.color = stoneAt(a, 0.5, s, 1.05); g.fill(it) }
        front?.let { g.color = stoneAt(4.5, 0.6, s, 1.25); g.fill(it) }
        top?.let { g.color = stoneAt(4.5, h, 1.5, 1.4); g.fill(it) }
        // the cloth over the middle of the front, with the sun in gold thread
        val cl = room(t3(3.6, 0.25, s + 0.01), t3(5.4, 0.25, s + 0.01), t3(5.4, h + 0.01, s + 0.01), t3(3.6, h + 0.01, s + 0.01))
        cl?.let { g.color = mix(stoneAt(4.5, 0.6, s, 1.55), Color(0xE8E0D0), if (dawn) 0.2 else 0.05); g.fill(it) }
        val sc = P(4.5, 0.62, s + 0.02); val sz = cz(4.5, s); val r = 0.17 * f / sz
        if (sz > 0.3) {
            for (k in 0 until 12) { val ang = PI * 2 * k / 12; line(Color(0xB08A3A), maxOf(1.0, 0.012 * f / sz), sc.x + cos(ang) * r * 0.6, sc.y + sin(ang) * r * 0.6, sc.x + cos(ang) * r * 1.2, sc.y + sin(ang) * r * 1.2) }
            g.color = Color(0xC09A48); g.fill(Ellipse2D.Double(sc.x - r * 0.5, sc.y - r * 0.5, r, r))
        }
        // the candles on the altar, the sun stand between them
        for ((tx, y, ty) in candles.filter { it.second < 1.5 && it.third < 2 }) candle(tx, ty, h, y - h)
        sunStand()
    }

    /** A candle standing on [base] at (tx, ty), [len] tall, burning. */
    fun candle(tx: Double, ty: Double, base: Double, len: Double, flameOn: Boolean = true) {
        val z = cz(tx, ty); if (z < 0.3) return
        val s = f / z
        val p0 = P(tx, base, ty); val p1 = P(tx, base + len, ty)
        line(Color(0xE8DCC0), maxOf(1.5, 0.05 * s), p0.x, p0.y, p1.x, p1.y)
        line(alpha(Color(0xFFF0D0), 0.6), maxOf(0.8, 0.015 * s), p0.x - 0.012 * s, p0.y, p1.x - 0.012 * s, p1.y)
        if (flameOn) flame(p1.x, p1.y + 0.01 * s, s * 0.55, (tx * 37 + ty * 11).toInt())
    }

    /** The sun stand in the middle of the altar: a gold ring of rays on a short post; the amulet hangs in it from picture 4. */
    fun sunStand() {
        val tx = 4.5; val ty = 1.45; val z = cz(tx, ty); if (z < 0.3) return
        val s = f / z
        val base = P(tx, 1.0, ty); val c = P(tx, 1.5, ty)
        line(Color(0x8A6A2A), maxOf(1.5, 0.035 * s), base.x, base.y, c.x, c.y + 0.12 * s)
        g.color = Color(0x6A5020); g.fill(Ellipse2D.Double(base.x - 0.09 * s, base.y - 0.025 * s, 0.18 * s, 0.05 * s))
        val r = 0.13 * s
        for (k in 0 until 16) { val ang = PI * 2 * k / 16; val l = if (k % 2 == 0) 1.9 else 1.5
            line(if (sun) Color(0xFFD070) else Color(0xA8823A), maxOf(1.0, 0.012 * s), c.x + cos(ang) * r, c.y + sin(ang) * r, c.x + cos(ang) * r * l, c.y + sin(ang) * r * l) }
        g.color = if (sun) Color(0xE0B050) else Color(0x9A7832); g.stroke = java.awt.BasicStroke(maxOf(1.5, 0.02 * s).toFloat()); g.draw(Ellipse2D.Double(c.x - r, c.y - r, r * 2, r * 2))
        if (shot >= 4) amuletAt(c.x, c.y, s, if (sun) 1.0 else 0.4)
    }

    /** The sun amulet: a gold disc with a pale stone in it; [shine] 0..1 how much light it catches. */
    fun amuletAt(x: Double, y: Double, s: Double, shine: Double) {
        if (shine > 0.6) { glow(x, y, 1.6 * s, Color(0xFFD070), 0.55 * shine); glow(x, y, 0.5 * s, Color(0xFFF4D0), 0.9 * shine) }
        else glow(x, y, 0.4 * s, Color(0xFFC060), 0.4)
        val r = 0.07 * s
        g.color = mix(Color(0xB08A3A), Color(0xFFE6A0), shine); g.fill(Ellipse2D.Double(x - r, y - r, r * 2, r * 2))
        g.color = mix(Color(0xD8D0B8), Color(0xFFFFF0), shine); g.fill(Ellipse2D.Double(x - r * 0.45, y - r * 0.45, r * 0.9, r * 0.9))
    }

    /** One of the two tall iron candlesticks beside the altar: three feet, a long shaft, a dish, the candle. */
    fun candlestick(tx: Double, ty: Double) {
        val z = cz(tx, ty); if (z < 0.3) return
        val s = f / z
        val top = 1.55
        for (k in 0 until 3) { val ang = PI * 2 * k / 3 + 0.4
            val fx = tx + cos(ang) * 0.14; val fy = ty + sin(ang) * 0.14
            val a = P(fx, 0.0, fy); val b = P(tx, 0.22, ty); line(Color(0x141210), maxOf(1.0, 0.03 * s), a.x, a.y, b.x, b.y) }
        val a = P(tx, 0.2, ty); val b = P(tx, top, ty)
        line(Color(0x18151A), maxOf(1.2, 0.035 * s), a.x, a.y, b.x, b.y)
        line(alpha(Color(0xC08A50), 0.5 * warmth(tx, 1.0, ty).coerceAtMost(1.0)), maxOf(0.8, 0.01 * s), a.x + 0.012 * s, a.y, b.x + 0.012 * s, b.y)
        g.color = Color(0x18151A); g.fill(Ellipse2D.Double(b.x - 0.08 * s, b.y - 0.02 * s, 0.16 * s, 0.04 * s))
        candle(tx, ty, top, 0.2, flameOn = candles.any { abs(it.first - tx) < 0.01 && abs(it.third - ty) < 0.01 })
    }

    /** The lectern beside the altar: a post on a foot, the slanted board with the open book. */
    fun lectern(tx: Double, ty: Double) {
        val z = cz(tx, ty); if (z < 0.3) return
        val s = f / z; val wood = mix(night(woodDay, 0.7), Color(0xA06A38), warmth(tx, 1.0, ty) * 0.5)
        val a = P(tx, 0.0, ty); val b = P(tx, 1.0, ty)
        line(wood, maxOf(1.5, 0.08 * s), a.x, a.y, b.x, b.y)
        fillR(wood, t3(tx - 0.2, 0.0, ty - 0.12), t3(tx + 0.2, 0.0, ty - 0.12), t3(tx + 0.2, 0.06, ty + 0.12), t3(tx - 0.2, 0.06, ty + 0.12))
        fillR(mix(wood, Color(0x000000), 0.2), t3(tx - 0.24, 1.0, ty + 0.12), t3(tx + 0.24, 1.0, ty + 0.12), t3(tx + 0.24, 1.18, ty - 0.12), t3(tx - 0.24, 1.18, ty - 0.12))
        fillR(mix(Color(0xD8CCB0), Color(0xFFD8A0), warmth(tx, 1.1, ty) * 0.4), t3(tx - 0.2, 1.03, ty + 0.1), t3(tx + 0.2, 1.03, ty + 0.1), t3(tx + 0.2, 1.19, ty - 0.1), t3(tx - 0.2, 1.19, ty - 0.1))
    }

    /** The font near the door: a stone basin on a short column. */
    fun font(tx: Double, ty: Double) {
        val z = cz(tx, ty); if (z < 0.3) return
        val s = f / z; val c = P(tx, 0.85, ty); val b = P(tx, 0.0, ty)
        line(stoneAt(tx, 0.4, ty, 1.0), maxOf(2.0, 0.16 * s), b.x, b.y, c.x, c.y)
        g.color = stoneAt(tx, 0.9, ty, 1.15); g.fill(Ellipse2D.Double(c.x - 0.28 * s, c.y - 0.07 * s, 0.56 * s, 0.2 * s))
        g.color = if (dawn) Color(0x4A5060) else Color(0x10141C); g.fill(Ellipse2D.Double(c.x - 0.22 * s, c.y - 0.05 * s, 0.44 * s, 0.11 * s))
    }

    /** A pew of dark wood from tile [a] to [b] in row [ty]: the seat, the high back of boards with a rail on top, shaped ends. */
    fun pew(a: Double, b: Double, ty: Double) {
        val n = ty + 0.25; val sb = ty + 0.75; val seat = 0.45; val back = 1.0
        val wood = night(woodDay, 0.85)
        fun lit(tx: Double, y: Double, t: Double, k: Double) = mix(mix(wood, Color(0x000000), (1 - k).coerceIn(0.0, 1.0)), Color(0xA06A38), (warmth(tx, y, t) * 0.55).coerceAtMost(0.6))
        val m = (a + b) / 2
        val seeFront = cz(m, n) > cz(m, sb)
        // the seat and its front board
        fillR(lit(m, 0.5, n, 1.05), t3(a, seat, n), t3(b, seat, n), t3(b, seat, sb), t3(a, seat, sb))
        fillR(lit(m, 0.3, n, 0.6), t3(a, 0.0, n + 0.04), t3(b, 0.0, n + 0.04), t3(b, seat, n), t3(a, seat, n))
        // the back of upright boards, a darker joint between them
        room(t3(a, 0.0, sb), t3(b, 0.0, sb), t3(b, back, sb), t3(a, back, sb))?.let { shape ->
            g.color = lit(m, 0.7, sb, if (seeFront) 0.85 else 0.7); g.fill(shape)
            val clip = g.clip; g.clip(shape)
            var tx = a; var k = 0
            while (tx < b) { val p0 = P(tx, 0.0, sb); val p1 = P(tx, back, sb)
                if (cz(tx, sb) > 0.3) line(alpha(Color(0x0A0806), 0.55), maxOf(1.0, 0.012 * f / cz(tx, sb)), p0.x, p0.y, p1.x, p1.y)
                tx += 0.16 + 0.04 * rnd(k++, (ty * 10).toInt()) }
            g.paint = GradientPaint(0f, P(m, back, sb).y.toFloat(), alpha(Color(0x000000), 0.0), 0f, P(m, 0.0, sb).y.toFloat(), alpha(Color(0x000000), 0.45)); g.fill(shape)
            g.clip = clip
        }
        // the rail along the top, catching the candlelight
        fillR(lit(m, back, sb, 1.35), t3(a - 0.03, back, sb - 0.06), t3(b + 0.03, back, sb - 0.06), t3(b + 0.03, back + 0.05, sb + 0.06), t3(a - 0.03, back + 0.05, sb + 0.06))
        // the ends: a board with a rounded top, higher at the back
        for (e in listOf(a, b)) {
            val pts = ArrayList<Triple<Double, Double, Double>>()
            pts += t3(e, 0.0, n); pts += t3(e, seat + 0.18, n)
            for (j in 1..6) { val t = j / 6.0; pts += t3(e, seat + 0.18 + (back + 0.1 - seat - 0.18) * sin(t * PI / 2), n + (sb + 0.06 - n) * (1 - cos(t * PI / 2))) }
            pts += t3(e, 0.0, sb + 0.06)
            room(*pts.toTypedArray())?.let { g.color = lit(e, 0.6, (n + sb) / 2, 0.95); g.fill(it) }
        }
    }

    // ---- the people

    enum class Kind { MAN, WOMAN, SCARF, HOOD, CHILD, DWARF, GUARD, ALDRIC, LYRA, OSRIC, KAEL }
    /** A person at (tx, ty), [h] tall, facing [face] degrees from north, seated or standing, of [kind]. */
    data class Who(val tx: Double, val ty: Double, val kind: Kind, val face: Double, val h: Double = 1.72, val seated: Boolean = false, val tone: Int = 0x3A3028, val holds: Boolean = false)
    /** Nobody stands right in front of the lens. */
    val peopleList by lazy { people().filter { hypot(it.tx - cam.tx, it.ty - cam.ty) > 1.1 } }

    fun people(): List<Who> = when (shot) {
        1 -> crowd() + listOf(Who(4.15, 2.45, Kind.ALDRIC, 0.0, 1.78))
        2 -> crowdFront() + listOf(Who(4.32, 2.5, Kind.ALDRIC, 82.0, 1.78), Who(4.86, 2.45, Kind.LYRA, 265.0, 1.68))
        3 -> crowdFront() + listOf(Who(4.45, 2.3, Kind.LYRA, 0.0, 1.68), Who(5.15, 2.6, Kind.OSRIC, 320.0, 1.7))
        4 -> crowdFront() + listOf(Who(3.75, 2.35, Kind.LYRA, 40.0, 1.68), Who(5.0, 2.45, Kind.OSRIC, 300.0, 1.7))
        else -> listOf(Who(4.5, 5.95, Kind.LYRA, 180.0, 1.68))
    }

    /** The village in the pews and along the walls (picture 1): seated in the pews, standing at the walls and in the back. */
    fun crowd(): List<Who> {
        val out = ArrayList<Who>()
        val kinds = listOf(Kind.MAN, Kind.WOMAN, Kind.SCARF, Kind.MAN, Kind.HOOD, Kind.WOMAN, Kind.CHILD, Kind.MAN, Kind.SCARF, Kind.WOMAN)
        val tones = listOf(0x4A3A2A, 0x5A4A3A, 0x6A3A30, 0x3A4030, 0x4A4A44, 0x5A4030, 0x5A6070, 0x403028, 0x6A4A3A, 0x4A3A40)
        var k = 0
        for (ty in listOf(3.0, 4.0)) for ((a, b) in listOf(1.2 to 3.9, 5.1 to 7.8)) {
            var tx = a + 0.3
            while (tx < b - 0.2) { val kind = kinds[k % kinds.size]
                if (!(ty == 3.0 && a < 4 && tx > 3.3)) // the hero's place in the first row stays free
                    out += Who(tx, ty + 0.45, kind, 0.0, if (kind == Kind.CHILD) 1.2 else 1.6 + 0.15 * rnd(k, 71), seated = true, tone = tones[k % tones.size], holds = rnd(k, 75) < 0.4)
                tx += 0.48 + 0.1 * rnd(k, 72); k++ }
        }
        out += Who(5.35, 4.55, Kind.DWARF, 0.0, 1.3, seated = false, tone = 0x5A3A22)
        // standing along the side walls and at the back
        for (ty in listOf(2.6, 3.3, 4.0, 4.7, 5.3)) { out += Who(1.35, ty, kinds[k++ % kinds.size], 20.0, 1.62 + 0.12 * rnd(k, 73), tone = tones[k % tones.size], holds = rnd(k, 76) < 0.5)
            out += Who(7.65, ty, kinds[k++ % kinds.size], 340.0, 1.62 + 0.12 * rnd(k, 74), tone = tones[k % tones.size], holds = rnd(k, 77) < 0.5) }
        out += Who(1.5, 4.95, Kind.GUARD, 20.0, 1.8, tone = 0x2A3A5A)
        out += Who(4.25, 5.4, Kind.KAEL, 350.0, 1.55, tone = 0x4A4038)
        return out
    }

    /** The first row only, for the pictures at the altar: heads and shoulders at the lower edge. */
    fun crowdFront(): List<Who> = crowd().filter { it.ty < 4.0 && abs(it.tx - cam.tx) > 0.45 && cz(it.tx, it.ty) > 0.5 }

    /**
     * One person as a silhouette with volume (70.2: outline and mark, never a face): body and head from behind or in profile,
     * the warm rim of the candles on the side towards them, the marks of `LISTE-FIGUREN.md`: Aldric's white beard and the staff
     * across his shoulder, Lyra's white robe and circlet, Osric's bald head and the sun on his breast with the candle, Jorin's
     * helmet and spear, Kael's blanket, the dwarf's breadth, the child's size, scarves and hoods.
     */
    fun person(p: Who) {
        val z = cz(p.tx, p.ty); if (z < 0.35) return
        val s = f / z
        val x = cx(p.tx, p.ty)
        val px = sx(x, z); val py = sy(0.0, z)
        // how the person turns against the eye: 0 = back to us, 90 = facing right in the picture, 180 = facing us
        val rel = ((p.face - cam.yaw) % 360 + 360) % 360
        val side = sin(rel * PI / 180)        // + facing right, − facing left
        val toUs = -cos(rel * PI / 180)       // + facing us
        val h = if (p.seated) p.h * 0.8 else p.h
        val wide = when (p.kind) { Kind.DWARF -> 0.36; Kind.CHILD -> 0.17; Kind.LYRA -> 0.2; Kind.ALDRIC -> 0.21; else -> 0.24 }
        val robeC = when (p.kind) {
            Kind.LYRA -> if (dawn) Color(0xB8BCC4) else mix(Color(0xD8D2C4), Color(0xFFD8A0), warmth(p.tx, 1.2, p.ty).coerceAtMost(1.0) * 0.4)
            Kind.ALDRIC -> mix(Color(0x3A1E30), Color(0x8A4A50), warmth(p.tx, 1.2, p.ty) * 0.6)
            Kind.OSRIC -> mix(night(0xB8A888, 0.75), Color(0xD8A060), warmth(p.tx, 1.2, p.ty).coerceAtMost(1.0) * 0.4)
            else -> mix(night(p.tone, 1.0), Color(0xB07A48), warmth(p.tx, 1.2, p.ty) * 0.35)
        }
        val head = if (p.kind == Kind.CHILD) 0.11 else if (p.kind == Kind.DWARF) 0.13 else 0.115
        val top = py - h * s
        val headY = top + head * s * 1.1
        val neck = top + head * s * 2.3
        val shoulder = wide * s * (1.0 - 0.35 * abs(side))
        // the body: shoulders, then the robe widening a little to the hem
        val body = Path2D.Double()
        val hem = if (p.seated) py - 0.35 * s else py
        body.moveTo(px - shoulder * 0.55, neck - 0.02 * s)
        body.curveTo(px - shoulder * 1.05, neck, px - shoulder * 1.1, neck + 0.12 * s, px - shoulder * 1.05, neck + 0.3 * s)
        body.lineTo(px - shoulder * 1.15, hem)
        body.lineTo(px + shoulder * 1.15, hem)
        body.lineTo(px + shoulder * 1.05, neck + 0.3 * s)
        body.curveTo(px + shoulder * 1.1, neck + 0.12 * s, px + shoulder * 1.05, neck, px + shoulder * 0.55, neck - 0.02 * s)
        body.closePath()
        g.color = robeC; g.fill(body)
        // light: the candles are ahead (north), so the rim sits on the side and the top; the rest lies in shade
        val clip = g.clip; g.clip(body)
        val lightX = if (p.tx < 4.5) 1.0 else -1.0
        g.paint = GradientPaint((px - shoulder * lightX).toFloat(), 0f, alpha(Color(0x050406), 0.55), (px + shoulder * lightX).toFloat(), 0f, alpha(Color(0x050406), 0.0)); g.fill(body)
        g.paint = GradientPaint(0f, neck.toFloat(), alpha(Color(0x050406), 0.0), 0f, hem.toFloat(), alpha(Color(0x050406), 0.5)); g.fill(body)
        // folds of the cloth falling from the shoulders, and the arms hanging at the sides
        for (k in -2..2) { val fx = px + k * shoulder * 0.38 + side * 0.02 * s
            line(alpha(Color(0x050406), 0.28), maxOf(1.0, 0.012 * s), fx, neck + 0.25 * s, fx + k * 0.02 * s, hem) }
        for (e in listOf(-1.0, 1.0)) line(alpha(Color(0x050406), 0.4), maxOf(1.0, 0.016 * s), px + e * shoulder * 0.72, neck + 0.12 * s, px + e * shoulder * 0.78, neck + 0.62 * s)
        // the inner rim: the candlelight round the edge of the cloth, strongest at the shoulders
        val rimW = warmth(p.tx, 1.5, p.ty).coerceAtMost(1.0)
        if (!dawn) { g.stroke = java.awt.BasicStroke(maxOf(1.5, 0.035 * s).toFloat())
            g.paint = GradientPaint(0f, neck.toFloat(), alpha(Color(0xFFB868), 0.25 + 0.5 * rimW), 0f, (neck + 0.7 * s).toFloat(), alpha(Color(0xFFB868), 0.0)); g.draw(body) }
        else { g.stroke = java.awt.BasicStroke(maxOf(1.5, 0.03 * s).toFloat()); g.color = alpha(Color(0xD8DCE4), 0.55); g.draw(body) }
        g.clip = clip
        val w = warmth(p.tx, 1.4, p.ty).coerceAtMost(1.0)
        if (!dawn) {
            line(alpha(Color(0xFFB060), 0.25 + 0.45 * w), maxOf(1.0, 0.025 * s), px + shoulder * 1.05 * lightX, neck + 0.05 * s, px + shoulder * 1.12 * lightX, neck + 0.6 * s)
            // the light from ahead catches the top of the shoulders
            line(alpha(Color(0xFFB060), 0.15 + 0.4 * w), maxOf(1.0, 0.02 * s), px - shoulder * 0.9, neck + 0.01 * s, px + shoulder * 0.9, neck + 0.01 * s)
        }
        // marks on the body
        when (p.kind) {
            Kind.KAEL -> { g.color = night(0x6A5A44, 0.8); g.fill(Ellipse2D.Double(px - shoulder * 1.2, neck - 0.05 * s, shoulder * 2.4, 0.42 * s)) }
            Kind.GUARD -> { g.color = night(0x2A4A8A, 0.85); g.fill(java.awt.geom.Rectangle2D.Double(px - shoulder * 0.8, neck + 0.12 * s, shoulder * 1.6, 0.7 * s))
                line(Color(0x2A2420), maxOf(1.0, 0.03 * s), px + shoulder * 0.9, py, px + shoulder * 1.1, top - 0.45 * s)
                poly(Color(0x8A8A90), px + shoulder * 1.1 - 0.03 * s, top - 0.45 * s, px + shoulder * 1.1 + 0.03 * s, top - 0.45 * s, px + shoulder * 1.12, top - 0.62 * s) }
            Kind.OSRIC -> if (toUs > -0.4) { val sx0 = px + side * shoulder * 0.3; val sy0 = neck + 0.25 * s
                for (k in 0 until 8) { val a = PI * 2 * k / 8; line(Color(0xC8A050), maxOf(1.0, 0.01 * s), sx0 + cos(a) * 0.03 * s, sy0 + sin(a) * 0.03 * s, sx0 + cos(a) * 0.06 * s, sy0 + sin(a) * 0.06 * s) }
                g.color = Color(0xD0A850); g.fill(Ellipse2D.Double(sx0 - 0.028 * s, sy0 - 0.028 * s, 0.056 * s, 0.056 * s)) }
            else -> {}
        }
        // the head: hair or hood or scarf; a profile shows nose and chin only as an outline, no face
        val hx = px + side * 0.03 * s
        val skin = mix(night(0xC09070, 0.55), Color(0xE0A070), w * 0.6)
        val hair = when (p.kind) { Kind.ALDRIC -> mix(Color(0xB8B2A8), Color(0xF0D8B0), w * 0.5); Kind.LYRA -> night(0x6A4A30, 0.7); Kind.OSRIC -> skin; Kind.CHILD -> night(0x8A6A40, 0.6); else -> night(0x3A2A1E, 0.7) }
        when (p.kind) {
            Kind.HOOD -> { g.color = robeC; g.fill(Ellipse2D.Double(hx - head * s * 1.25, top - 0.03 * s, head * s * 2.5, head * s * 2.6)) }
            Kind.SCARF -> { g.color = night(0x8A3A30, 0.7); g.fill(Ellipse2D.Double(hx - head * s * 1.1, top, head * s * 2.2, head * s * 2.3)) }
            Kind.GUARD -> { g.color = Color(0x6A6A70); g.fill(Ellipse2D.Double(hx - head * s * 1.1, top - 0.02 * s, head * s * 2.2, head * s * 2.0)) }
            else -> {
                g.color = if (toUs > 0.3 || abs(side) > 0.6) skin else hair
                g.fill(Ellipse2D.Double(hx - head * s, top, head * s * 2, head * s * 2.2))
                if (toUs <= 0.3 && p.kind != Kind.OSRIC) { g.color = hair; g.fill(Ellipse2D.Double(hx - head * s * 1.02 - side * 0.03 * s, top - 0.01 * s, head * s * 2.04, head * s * 1.6)) }
                run { val hd = Ellipse2D.Double(hx - head * s, top, head * s * 2, head * s * 2.2); val c0 = g.clip; g.clip(hd)
                    g.stroke = java.awt.BasicStroke(maxOf(1.2, 0.03 * s).toFloat()); g.color = if (dawn) alpha(Color(0xD8DCE4), 0.5) else alpha(Color(0xFFC078), 0.2 + 0.5 * w); g.draw(hd); g.clip = c0 }
                if (abs(side) > 0.6) { // profile: the nose as a small step in the outline on the side it faces
                    val nx = hx + side * head * s * 1.0; poly(skin, nx, headY - 0.01 * s, nx + side * 0.035 * s, headY + 0.03 * s, nx, headY + 0.045 * s) }
                if (p.kind == Kind.OSRIC) g.color = alpha(Color(0xFFE0B0), 0.5 * w).also { g.fill(Ellipse2D.Double(hx - head * s * 0.6 + lightX * head * s * 0.3, top + 0.01 * s, head * s * 0.9, head * s * 0.7)) }
            }
        }
        if (p.kind == Kind.LYRA) { // the circlet: a thin bright line round the brow
            val cy0 = top + head * s * 0.65
            g.color = if (dawn) Color(0xC8CCD4) else Color(0xF0D8A0); g.stroke = java.awt.BasicStroke(maxOf(1.0, 0.012 * s).toFloat())
            g.draw(java.awt.geom.Arc2D.Double(hx - head * s * 1.02, cy0 - head * s * 0.25, head * s * 2.04, head * s * 0.5, 180.0, 180.0, java.awt.geom.Arc2D.OPEN)) }
        if (p.kind == Kind.ALDRIC) {
            // the long white beard in profile, the staff across his shoulder
            if (abs(side) > 0.3 || toUs > 0.3) { val bx = hx + side * head * s * 0.5
                poly(hair, bx - side * 0.03 * s, headY + 0.04 * s, bx + side * 0.1 * s, headY + 0.05 * s, bx + side * 0.06 * s, neck + 0.34 * s, bx - side * 0.02 * s, neck + 0.16 * s) }
            // the staff across his shoulder: its far end low behind him, the near end up past his head
            line(mix(Color(0x3A2818), Color(0xA07040), w * 0.6), maxOf(1.5, 0.028 * s), px - side * 0.75 * s, neck + 0.3 * s, px + side * 0.55 * s, neck - 0.22 * s)
        }
        if (p.kind == Kind.OSRIC && shot == 3) {
            // the candle in his hands before his breast, its light up into his face
            val cxp = px + side * 0.2 * s; val cyp = neck + 0.35 * s
            line(Color(0xE8DCC0), maxOf(1.5, 0.04 * s), cxp, cyp, cxp, cyp - 0.18 * s)
            g.color = skin; g.fill(Ellipse2D.Double(cxp - 0.05 * s, cyp - 0.03 * s, 0.1 * s, 0.07 * s))
            flame(cxp, cyp - 0.18 * s, s * 0.55, 77)
        }
        if (p.kind == Kind.ALDRIC && shot == 2 || p.kind == Kind.LYRA && shot == 2) {
            // the hands towards each other, holding the amulet between them
            val hand = px + side * 0.36 * s; val hy0 = neck + 0.42 * s
            line(robeC, maxOf(2.0, 0.07 * s), px + side * shoulder * 0.6, neck + 0.2 * s, hand, hy0)
            g.color = skin; g.fill(Ellipse2D.Double(hand - 0.04 * s, hy0 - 0.03 * s, 0.08 * s, 0.06 * s))
            if (p.kind == Kind.LYRA) amuletAt(hand + side * 0.06 * s, hy0, s, 0.5)
        }
        if (p.kind == Kind.LYRA && shot == 3) {
            // the amulet raised in both hands before her (seen from behind: the hands and its glow above her shoulders)
            val ay = neck + 0.05 * s; glow(px, ay, 0.5 * s, Color(0xFFD070), 0.5)
            amuletAt(px, ay - 0.02 * s, s, 0.55)
        }
        if (sun && (p.kind == Kind.LYRA || p.kind == Kind.OSRIC)) {
            // the first light on the faces turned to the amulet
            glow(hx + side * head * s * 0.6, headY, head * s * 2.2, Color(0xFFD890), 0.5)
        }
    }

    /** Picture 4: the first sun through the east window, a shaft of light through the dusty air down onto the amulet. */
    fun sunBeam() {
        val wx = 8.0; val wy = 3.5
        val src = listOf(P(wx, 4.2, wy - 0.25), P(wx, 4.2, wy + 0.25), P(wx, 2.2, wy + 0.25), P(wx, 2.2, wy - 0.25))
        val dst = P(4.5, 1.5, 1.45)
        val s = f / cz(4.5, 1.45)
        val beam = Path2D.Double().apply {
            moveTo(src[0].x, src[0].y); lineTo(dst.x + 0.25 * s, dst.y - 0.3 * s); lineTo(dst.x - 0.25 * s, dst.y + 0.3 * s); lineTo(src[2].x, src[2].y); lineTo(src[3].x, src[3].y); closePath()
        }
        val old = g.composite
        g.composite = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.32f)
        g.paint = GradientPaint(src[0].x.toFloat(), src[0].y.toFloat(), Color(0xFFE0A0), dst.x.toFloat(), dst.y.toFloat(), Color(0xFFC060))
        g.fill(beam)
        g.composite = old
        glow(dst.x, dst.y, 1.4 * s, Color(0xFFD070), 0.45)
        amuletAt(dst.x, dst.y, s, 1.0)
    }

    /** Dust in the air: in the candlelight before the dawn, in the sun shaft in picture 4, in the grey from the door in picture 5. */
    fun motes() {
        val n = if (sun) 260 else 90
        for (i in 0 until n) {
            val x = rnd(i, 901) * W; val y = rnd(i, 902) * H * 0.8
            val a = if (sun) 0.35 else 0.12
            g.color = alpha(if (dawn) Color(0xC8CCD8) else Color(0xFFE0B0), a * rnd(i, 903)); val r = 0.8 + 1.4 * rnd(i, 904)
            g.fill(Ellipse2D.Double(x - r, y - r, r * 2, r * 2))
        }
    }
}
