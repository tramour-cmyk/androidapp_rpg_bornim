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
import kotlin.math.floor
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
    // TEMPEL68=app: the five pictures as the app's assets (JPEG, like the intro's)
    if (System.getenv("TEMPEL68") == "app") {
        val dir = File("../../app/src/main/assets/tempel").apply { mkdirs() }
        val life = StringBuilder("# 112 (7): Leben der Tempelszene, geschrieben von tools/preview TempleProbe.kt (TEMPEL68=app); de.bornim.core.TempleLife liest es\n")
        for (n in 1..5) {
            val painter = TemplePainter(n)
            val img = painter.paint()
            // only the flames still seen in the finished picture: one behind a figure or a pew must not flicker over it
            fun seen(x: Double, y: Double, s: Double): Boolean { val px = x.toInt(); val py = (y - 0.08 * s).toInt()
                if (px !in 0 until img.width || py !in 0 until img.height) return false
                val c = Color(img.getRGB(px, py)); return c.red > 215 && c.green > 140 }
            for ((x, y, s) in painter.flames.filter { (x, y, s) -> seen(x, y, s) }) life.append("flamme $n ${"%.1f".format(java.util.Locale.ROOT, x)} ${"%.1f".format(java.util.Locale.ROOT, y)} ${"%.2f".format(java.util.Locale.ROOT, s)}\n")
            if (painter.shaft.isNotEmpty()) life.append("strahl $n " + painter.shaft.joinToString(" ") { "%.1f %.1f".format(java.util.Locale.ROOT, it.x, it.y) } + "\n")
            val rgb = java.awt.image.BufferedImage(img.width, img.height, java.awt.image.BufferedImage.TYPE_INT_RGB).also { it.createGraphics().drawImage(img, 0, 0, null) }
            val writer = ImageIO.getImageWritersByFormatName("jpg").next()
            val param = writer.defaultWriteParam.apply { compressionMode = javax.imageio.ImageWriteParam.MODE_EXPLICIT; compressionQuality = 0.9f }
            javax.imageio.stream.FileImageOutputStream(File(dir, "tempel_$n.jpg")).use { out -> writer.output = out; writer.write(null, javax.imageio.IIOImage(rgb, null, null), param) }
            writer.dispose()
        }
        File(dir, "leben.txt").writeText(life.toString())
        println("wrote ${dir.path}/tempel_1..5.jpg, leben.txt")
        return
    }
    val only = System.getenv("TEMPEL68")?.toIntOrNull()
    if (only == null || only == 0) { ImageIO.write(templePlan(), "png", File("build/screens/tempel68_0_plan.png")); println("wrote build/screens/tempel68_0_plan.png") }
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
        // 112 (4): never frontal onto the altar wall. 68 (Bilder vom Zweig, 68.1): 2 to 4 stand between the first row and the altar (3
        // and 4 back by the west wall, so the altar looks the same length in all three), so
        // no pew stands empty before the eye; 4 looks from the altar's side across to the east window and over the village
        2 -> Cam(4.0, 3.3, 9.0, 560.0)       // before the first row, at the aisle: Aldric and Lyra in profile before the altar
        3 -> Cam(1.8, 2.75, 66.0, 560.0)    // by the west wall: Lyra at the altar in profile, Osric with the candle, the grey fall between
        4 -> Cam(1.9, 2.3, 99.0, 560.0)      // beside the altar, turned east: the amulet left, the shaft from the window, the village right
        else -> Cam(3.3, 3.0, 152.0, 600.0)  // before the first row, turned to the door at a slant: Lyra in it, the grey morning outside
    }
    override val hy = cam.hy; override val eye = 1.65; override val camX = 0.0; override val pan = 0.0
    /** A wider lens inside than outside: the nave is only 11 m wide and the eye stands in it (picture 1 at the door). */
    override val f = when (shot) { 1 -> 680.0; 2 -> 600.0; 4 -> 700.0; else -> 760.0 }
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
    /** 112 (2, Messung Homer 18.10.): picture 3 had no counter-light; the first grey of the morning stands in its windows. */
    val grey = shot == 3
    /** The candles that burn (tile x, height, tile y): on the altar, the two tall candlesticks, Osric's candle. */
    val candles: List<Triple<Double, Double, Double>> by lazy { buildList {
        if (!dawn) {
            for (k in 0 until 5) add(Triple(3.25 + k * 0.62, 1.22, 1.45))
            add(Triple(2.5, 1.75, 1.5)); add(Triple(6.5, 1.75, 1.5))
            if (shot == 3) add(Triple(5.05, 1.25, 2.55))
            // the village brought its own candles: some hold one before them (picture 1 and the first row)
            for (p in peopleList) if (p.holds) add(Triple(p.tx, if (p.seated) 0.95 else 1.15, p.ty - 0.18))
        } else { add(Triple(2.5, 1.75, 1.5)); add(Triple(3.85, 1.19, 3.78)) }  // picture 5: one candle left burning on the pew before the eye
    } }
    /**
     * How warm the light is at a point of the room (0 none .. about 1 beside a candle). 112 (6, 1): a candle lights a small
     * round of a metre or two and falls off fast; between the candles the room stays dark and cool, no warm veil over it all.
     */
    fun warmth(tx: Double, y: Double, ty: Double): Double = candles.sumOf { (cx0, cy, cy0) ->
        val d = hypot(hypot((tx - cx0) * T, (ty - cy0) * T), y - cy); (if (grey) 0.3 else 0.42) / (1 + d * d * (if (grey) 3.6 else 2.2)) }.coerceAtMost(1.0) * (if (dawn) 0.6 else if (sun) 0.6 else 1.0)
    /** The windows (and in picture 5 the door) on the plan: tile x, tile y, how high their middle is. */
    val windows = listOf(Triple(1.5, 1.0, 3.3), Triple(7.5, 1.0, 3.3), Triple(8.0, 3.5, 3.2), Triple(6.5, 6.0, 3.1), Triple(1.5, 6.0, 3.1))
    /** 112 (2): the cold light of the sky before the sun, falling in through the windows (and the door in picture 5). */
    fun cold(tx: Double, y: Double, ty: Double): Double {
        val k = if (dawn) 1.0 else if (grey) 0.85 else if (sun) 0.7 else 0.55
        val w = windows.sumOf { (wx, wy, wh) -> val d = hypot(hypot((tx - wx) * T, (ty - wy) * T), (y - wh) * 0.7); 0.5 / (1 + d * d * 0.18) }
        val door = if (dawn) { val d = hypot((tx - 4.5) * T, (ty - 6.0) * T); 1.0 / (1 + d * d * 0.25) } else 0.0
        return ((w + door) * k).coerceAtMost(1.0)
    }
    val coolSky = Color(0x5C6E90)

    val stoneDay = 0x8A867A; val woodDay = 0x5A4030
    fun stoneAt(tx: Double, y: Double, ty: Double, k: Double = 1.0): Color {
        val w = warmth(tx, y, ty).coerceAtMost(1.0)
        // the dark of the room is cool; the sky from the windows lays a grey-blue on what is near them
        val base = mix(mix(night(stoneDay, 0.34 * k), Color(0x181C26), 0.5), mix(night(stoneDay, 0.9 * k), coolSky, 0.45), cold(tx, y, ty) * (if (grey) 0.85 else 0.6))
        return mix(base, Color((0xA8 * k).toInt().coerceAtMost(255), (0x70 * k).toInt().coerceAtMost(255), (0x3E * k).toInt().coerceAtMost(255)), w * 0.75)
    }

    override fun scene() {
        g.color = Color(0x05060A); g.fillRect(0, 0, W * SS, H * SS)
        walls()
        floor()
        // picture 3: the grey falls onto wall and flags behind the people and pews, not over them or the flames
        if (grey) greyLight()
        // the furniture and the people, far ones first
        val items = ArrayList<Pair<Double, () -> Unit>>()
        items += depth(4.5, 1.5) to { altar() }
        items += depth(2.5, 1.5) to { candlestick(2.5, 1.5) }
        items += depth(6.5, 1.5) to { candlestick(6.5, 1.5) }
        items += depth(5.6, 2.55) to { lectern(5.6, 2.55) }
        items += depth(3.5, 5.5) to { font(3.5, 5.5) }
        if (dawn) items += depth(3.85, 3.78) - 0.01 to { candle(3.85, 3.78, 0.94, 0.25) }  // on the rail of the pew (back 0.9)
        for (ty in listOf(3.0, 4.0)) for ((a, b) in pews) items += depth((a + b) / 2, ty + 0.6) to { pew(a, b, ty) }
        for (p in peopleList) {
            // 68 Test 35.9: one sitting in a pew is drawn just before it, so its back hides him below the shoulders wherever he
            // sits along it (a long pew seen at a slant is nearer at one end than its middle)
            // seen from the altar side the back stands behind him and the seat before his knees: then he is drawn after his pew
            val pewOf = if (p.seated) pews.firstOrNull { (a, b) -> p.tx in a..b }?.let { (a, b) -> val ty = floor(p.ty)
                val d = depth((a + b) / 2, ty + 0.6); if (depth((a + b) / 2, ty + seatF) < depth((a + b) / 2, ty + backY)) d - 0.01 else d + 0.01 } else null
            items += (pewOf ?: (depth(p.tx, p.ty) - 0.05)) to { person(p) }
            // a candle held before the body: hidden by it from behind, its glow round the head and shoulders
            if (p.holds) items += depth(p.tx, p.ty - 0.18) to { val z = cz(p.tx, p.ty - 0.18); if (z > 0.4) { val c = P(p.tx, if (p.seated) 0.95 else 1.15, p.ty - 0.18)
                glow(c.x, c.y, f * 0.9 / z, Color(0xFFB060), 0.35); glow(c.x, c.y, f * 0.25 / z, Color(0xFFE0A0), 0.5) } }
        }
        for ((_, draw) in items.sortedByDescending { it.first }) draw()
        if (sun) sunBeam()
        motes()
        vignette()
    }

    // ---- life (112, 7): what the app moves over the picture

    /** Every flame painted (foot x, y, size), for `leben.txt`: the app lets them flicker. */
    val flames = ArrayList<Triple<Double, Double, Double>>()
    /** The outline of the sun shaft in picture 4: the app lets the dust drift in it. */
    var shaft: List<Point2D.Double> = emptyList()
    fun burn(x: Double, y: Double, s: Double, seed: Int) { if (x > -20 && x < W + 20 && y > -20 && y < H + 20) flames += Triple(x, y, s); flame(x, y, s, seed) }

    // ---- the room

    /**
     * 112 (3): the grain of dressed stone, fine dark and light flecks over a whole [shape], [per] flecks per square pixel of the
     * picture; [a] how strong. The intro's texture is capped for its far fields; inside, the walls fill the picture.
     */
    fun speckle(shape: java.awt.Shape, per: Double, a: Double) {
        val clip = g.clip; g.clip(shape)
        val b = shape.bounds2D.createIntersection(java.awt.geom.Rectangle2D.Double(0.0, 0.0, W.toDouble(), H.toDouble()))
        val n = (b.width * b.height * per).toInt().coerceIn(0, 700000)
        val seed = (b.x * 7 + b.y * 13).toInt()
        for (i in 0 until n) {
            val x = b.x + rnd(i, 1201 + seed) * b.width; val y = b.y + rnd(i, 1202 + seed) * b.height
            val r = 0.7 + 1.3 * rnd(i, 1203)
            g.color = if (rnd(i, 1204) < 0.55) alpha(Color(0x000000), a * (0.6 + rnd(i, 1205))) else alpha(Color(0xC8C4BC), a * 0.6 * (0.6 + rnd(i, 1205)))
            g.fill(java.awt.geom.Rectangle2D.Double(x - r / 2, y - r / 2, r, r))
        }
        g.clip = clip
    }

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
            // 112 (1, 6): the wall itself dark and cool; light lies on it only round a candle or a window
            g.color = if (dawn) Color(0x22262E) else Color(0x181C26); g.fill(shape)
            val clip = g.clip; g.clip(shape)
            for ((wx, wy, wh) in windows) {
                val onWall = abs((wx - w.ax) * (w.by - w.ay) - (wy - w.ay) * (w.bx - w.ax)) / len < 0.05
                if (!onWall) continue
                val c = P(wx, wh, wy); val z = cz(wx, wy); if (z < 0.3) continue
                glow(c.x, c.y, f * 3.2 / z, coolSky, if (dawn) 0.4 else if (grey) 0.45 else if (sun) 0.3 else 0.32) }
            if (dawn && w === list[2]) { val c = P(4.5, 1.4, 6.0); val z = cz(4.5, 6.0); if (z > 0.3) glow(c.x, c.y, f * 4.5 / z, Color(0x8A94A8), 0.55) }
            // warm light from the candles lies on the wall in pools, at the point of the wall nearest the candle
            for ((cx0, cy, cy0) in candles) {
                val t = (((cx0 - w.ax) * (w.bx - w.ax) + (cy0 - w.ay) * (w.by - w.ay)) / (len * len)).coerceIn(0.0, 1.0)
                val qx = w.ax + (w.bx - w.ax) * t; val qy = w.ay + (w.by - w.ay) * t
                val d = hypot(qx - cx0, qy - cy0) * T; if (d > 4.0) continue
                val c = P(qx, cy + 0.3, qy); val z = cz(qx, qy); if (z < 0.3) continue
                val k = 1.0 / (1 + d * d * (if (grey) 1.2 else 0.5)); val r = if (grey) 0.65 else 1.0
                glow(c.x, c.y, f * (0.9 + d * 0.5) * r / z, Color(0xD88038), (if (dawn) 0.2 else 0.34) * k)
                glow(c.x, c.y, f * (0.4 + d * 0.2) * r / z, Color(0xFFB060), (if (dawn) 0.1 else 0.18) * k)
            }
            // 112 (3): every dressed stone its own shade, a little darker at its lower edge, chipped here and there
            run { var yy = 0.0; var rr = 0
                while (yy < wallH) { val hh = 0.38 + 0.08 * rnd(rr, 641); var uu = rnd(rr, 642) * 0.9
                    while (uu < len * T) { val du = 0.55 + 0.45 * rnd((uu * 10).toInt(), rr); val u0 = uu / T; val u1 = minOf(len, (uu + du) / T)
                        val v = rnd((uu * 17).toInt() + rr * 31, 643)
                        val c = if (v < 0.5) alpha(Color(0x000000), 0.04 + 0.14 * (0.5 - v)) else alpha(Color(0xA8B0C0), 0.02 + 0.07 * (v - 0.5))
                        room(at(u0, yy), at(u1, yy), at(u1, minOf(wallH, yy + hh)), at(u0, minOf(wallH, yy + hh)))?.let { g.color = c; g.fill(it) }
                        room(at(u0, yy), at(u1, yy), at(u1, yy + hh * 0.22), at(u0, yy + hh * 0.22))?.let { g.color = alpha(Color(0x000000), 0.12); g.fill(it) }
                        uu += du }
                    yy += hh; rr++ } }
            // courses and joints
            var y = 0.0; var row = 0
            while (y < wallH) {
                val h = 0.38 + 0.08 * rnd(row, 641)
                val a = P(at(0.0, y).first, y, at(0.0, y).third); val b = P(at(len, y).first, y, at(len, y).third)
                if (cz(at(0.0, y).first, at(0.0, y).third) > 0.3 && cz(at(len, y).first, at(len, y).third) > 0.3) { line(alpha(Color(0x000000), 0.75), 1.6, a.x, a.y, b.x, b.y)
                    line(alpha(Color(0xB0B4BC), 0.07), 1.0, a.x, a.y - 1.6, b.x, b.y - 1.6) }
                else room(at(0.0, y), at(len, y), at(len, y + 0.02), at(0.0, y + 0.02))?.let { g.color = alpha(Color(0x16161A), 0.7); g.fill(it) }
                var u = rnd(row, 642) * 0.9
                while (u < len * T) { val uu = u / T
                    val p0 = at(uu, y); val p1 = at(uu, minOf(wallH, y + h))
                    if (cz(p0.first, p0.third) > 0.3) { val s0 = P(p0.first, p0.second, p0.third); val s1 = P(p1.first, p1.second, p1.third); line(alpha(Color(0x000000), 0.65), 1.3, s0.x, s0.y, s1.x, s1.y) }
                    u += 0.55 + 0.45 * rnd((u * 10).toInt(), row) }
                y += h; row++
            }
            speckle(shape, 0.3, 0.09)
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
            grey -> GradientPaint(0f, b.y.toFloat(), Color(0x4A5670), 0f, (b.y + b.height).toFloat(), Color(0x7E8698))
            else -> GradientPaint(0f, b.y.toFloat(), Color(0x23304E), 0f, (b.y + b.height).toFloat(), Color(0x4E5E7E))
        }
        // 112 (2): the grey-blue of the sky spills round the window onto the stone, the counter-light to the candles
        if (!(sun && east)) glow(b.centerX, b.centerY, b.height * (if (door) 1.6 else 1.25), coolSky, if (dawn) 0.3 else if (grey) 0.32 else 0.22)
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
        // 112 (3): grit and wear on the flags
        room(t3(x0, 0.0, y0), t3(x1, 0.0, y0), t3(x1, 0.0, y1), t3(x0, 0.0, y1))?.let { speckle(it, 0.3, 0.1) }
        // the candles' light on the floor: small warm rounds
        for ((cx0, _, cy0) in candles) { val z = cz(cx0, cy0); if (z < 0.3) continue
            groundPool(cx(cx0, cy0), z, if (grey) 0.95 else 1.4, Color(0xE08A3A), if (dawn) 0.2 else 0.28, 0.32) }
        // the grey of the sky lying on the flags below the windows
        if (!dawn) for ((wx, wy, _) in windows) { val ix = wx + (4.5 - wx) * 0.25; val iy = wy + (3.5 - wy) * 0.35; val z = cz(ix, iy); if (z < 0.3) continue
            groundPool(cx(ix, iy), z, if (grey) 2.6 else 1.8, coolSky, if (grey) 0.3 else if (sun) 0.12 else 0.16, 0.3) }
        if (grey) { val z = cz(2.7, 2.6); if (z > 0.3) groundPool(cx(2.7, 2.6), z, 1.6, Color(0x8C9AB4), 0.22, 0.3) }
        if (dawn) { val z = cz(4.5, 6.0); if (z > 0.3) groundPool(cx(4.5, 6.0), z - 1.6, 3.2, Color(0xA8B0C0), 0.35, 0.3) }
    }

    /** The altar: a long block of pale stone, a white cloth with the gold sun on its front, candles, the sun stand in the middle. */
    fun altar() {
        val a = 3.05; val b = 5.95; val n = 1.15; val s = 1.85; val h = 1.0
        val front = room(t3(a, 0.0, s), t3(b, 0.0, s), t3(b, h, s), t3(a, h, s))
        // 68.1: the end the eye stands beyond is the one seen, so the block is closed from the side
        val side = if (cam.tx < a) room(t3(a, 0.0, n), t3(a, 0.0, s), t3(a, h, s), t3(a, h, n)) else if (cam.tx > b) room(t3(b, 0.0, s), t3(b, 0.0, n), t3(b, h, n), t3(b, h, s)) else null
        val top = room(t3(a - 0.05, h, n - 0.05), t3(b + 0.05, h, n - 0.05), t3(b + 0.05, h, s + 0.05), t3(a - 0.05, h, s + 0.05))
        side?.let { g.color = stoneAt(a, 0.5, s, 0.9); g.fill(it); texture(it, maxOf(1.0, cz(a, s)), Color(0x101014), Color(0xC8BCA8), 120, 0.006) }
        front?.let { g.color = stoneAt(4.5, 0.6, s, 1.25); g.fill(it)
            // the front in three courses of blocks with joints
            for (yy in listOf(0.33, 0.66)) { val p0 = P(a, yy, s); val p1 = P(b, yy, s); line(alpha(Color(0x0A0A0E), 0.5), maxOf(1.0, 0.012 * f / cz(4.5, s)), p0.x, p0.y, p1.x, p1.y) }
            for (j in 0 until 9) { val u = a + (b - a) * (j + 0.5 + 0.3 * rnd(j, 553)) / 9; val r0 = (j % 3) / 3.0; val p0 = P(u, r0 * h, s); val p1 = P(u, r0 * h + h / 3, s)
                line(alpha(Color(0x0A0A0E), 0.45), maxOf(1.0, 0.01 * f / cz(u, s)), p0.x, p0.y, p1.x, p1.y) }
            texture(it, maxOf(1.0, cz(4.5, s)), Color(0x101014), Color(0xC8BCA8), 250, 0.006) }
        top?.let { g.color = stoneAt(4.5, h, 1.5, 1.4); g.fill(it); texture(it, maxOf(1.0, cz(4.5, s)), Color(0x101014), Color(0xC8BCA8), 150, 0.006, 0.4) }
        // the cloth over the middle of the front, with the sun in gold thread
        val cl = room(t3(3.6, 0.25, s + 0.01), t3(5.4, 0.25, s + 0.01), t3(5.4, h + 0.01, s + 0.01), t3(3.6, h + 0.01, s + 0.01))
        // 68: the cloth plainly white against the stone, its hem a little darker, so the sun sits on it and does not float
        cl?.let { g.color = mix(stoneAt(4.5, 0.6, s, 1.55), Color(0xE8E0D0), if (dawn) 0.35 else 0.25); g.fill(it)
            // 112 (3): the cloth falls in soft folds from the top edge, lighter on their ridges
            val clip = g.clip; g.clip(it)
            for (k in 0 until 26) { val u = 3.6 + 1.8 * (k + 0.5) / 26; val a0 = P(u, h, s + 0.012); val a1 = P(u + (rnd(k, 551) - 0.5) * 0.05, 0.25, s + 0.012)
                line(alpha(if (k % 2 == 0) Color(0x1A140E) else Color(0xFFF4E0), 0.1 + 0.1 * rnd(k, 552)), maxOf(1.0, 0.03 * f / cz(u, s)), a0.x, a0.y, a1.x, a1.y) }
            g.clip = clip }
        val h0 = P(3.6, 0.25, s + 0.012); val h1 = P(5.4, 0.25, s + 0.012)
        if (cl != null) line(alpha(Color(0x2A2018), 0.45), maxOf(1.0, 0.02 * f / cz(4.5, s)), h0.x, h0.y, h1.x, h1.y)
        val sc = P(4.5, 0.62, s + 0.02); val sz = cz(4.5, s); val r = 0.17 * f / sz
        if (sz > 0.3) {
            // 68 Test 32 (4): stitched, thin and dull, so it never reads as a second amulet beside the shining one
            val thread = alpha(Color(0x9A7838), 0.55)
            for (k in 0 until 12) { val ang = PI * 2 * k / 12; line(thread, maxOf(0.8, 0.007 * f / sz), sc.x + cos(ang) * r * 0.62, sc.y + sin(ang) * r * 0.62, sc.x + cos(ang) * r * 1.0, sc.y + sin(ang) * r * 1.0) }
            g.color = thread; g.stroke = java.awt.BasicStroke(maxOf(0.8, 0.007 * f / sz).toFloat()); g.draw(Ellipse2D.Double(sc.x - r * 0.45, sc.y - r * 0.45, r * 0.9, r * 0.9))
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
        if (flameOn) burn(p1.x, p1.y + 0.01 * s, s * 0.32, (tx * 37 + ty * 11).toInt())
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
        if (shine > 0.6) { glow(x, y, 0.6 * s, Color(0xFFD070), 0.4 * shine); glow(x, y, 0.22 * s, Color(0xFFF4D0), 0.8 * shine) }
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

    /**
     * The two blocks of pews (tile x from, to), each row at tile y 3 and 4, the middle aisle between them. A pew of row ty
     * (68, Bilder vom Zweig): a seat plank at knee height from [seatF] to [backY], a back of boards from the seat up to the
     * shoulders of one sitting on it, open below the seat, two legs and a foot rail; each end a plain board only as deep as seat
     * and back, so the pews read as benches with room for the knees, not as closed boxes.
     */
    val pews = listOf(1.6 to 3.95, 5.05 to 7.4)
    val seatF = 0.5; val backY = 0.78; val seatH = 0.45; val backH = 0.9
    /** Where one sits on a pew of row ty (tile y): just before the back. */
    val sitY = 0.66

    fun pew(a: Double, b: Double, ty: Double) {
        val n = ty + seatF; val sb = ty + backY
        val wood = night(woodDay, 0.85)
        fun lit(tx: Double, y: Double, t: Double, k: Double) = mix(mix(mix(wood, Color(0x000000), (1 - k).coerceIn(0.0, 1.0)), mix(wood, coolSky, 0.5), cold(tx, y, t) * 0.45), Color(0xA06A38), (warmth(tx, y, t) * 0.7).coerceAtMost(0.7))
        /** 112 (3): the grain of the wood along a board, from corner [p0] to [p1], [n] lines over the height [up]. */
        fun grain(shape: java.awt.Shape, p0: Triple<Double, Double, Double>, p1: Triple<Double, Double, Double>, up: Double, n: Int, seed: Int) {
            val clip = g.clip; g.clip(shape)
            for (i in 0 until n) { val v = (i + 0.5) / n * up + (rnd(i, seed) - 0.5) * up / n
                val a0 = P(p0.first, p0.second + v, p0.third); val a1 = P(p1.first, p1.second + v + (rnd(i, seed + 1) - 0.5) * up / n, p1.third)
                if (cz(p0.first, p0.third) > 0.3 && cz(p1.first, p1.third) > 0.3)
                    line(alpha(if (rnd(i, seed + 2) < 0.6) Color(0x0A0604) else Color(0xB08050), 0.12 + 0.14 * rnd(i, seed + 3)), maxOf(0.8, 0.006 * f / maxOf(0.5, cz(p0.first, p0.third))), a0.x, a0.y, a1.x, a1.y) }
            g.clip = clip
        }
        val m = (a + b) / 2
        val seeFront = cz(m, n) < cz(m, sb)
        val edge = alpha(Color(0x0A0806), 0.55)
        fun outline(shape: java.awt.Shape) { g.color = edge; g.stroke = java.awt.BasicStroke(1.1f); g.draw(shape) }
        // legs under the seat and a foot rail between them, drawn first: the seat and the back lie over them
        val legs = buildList { add(a + 0.06); var x = a + 0.75; while (x < b - 0.4) { add(x); x += 0.75 }; add(b - 0.06) }
        fun under() {
            room(t3(a, 0.08, (n + sb) / 2 - 0.02), t3(b, 0.08, (n + sb) / 2 - 0.02), t3(b, 0.13, (n + sb) / 2 + 0.02), t3(a, 0.13, (n + sb) / 2 + 0.02))?.let { g.color = lit(m, 0.1, n, 0.5); g.fill(it) }
            for (x in legs) for (yy in listOf(n + 0.04, sb - 0.02))
                room(t3(x - 0.03, 0.0, yy), t3(x + 0.03, 0.0, yy), t3(x + 0.03, seatH, yy), t3(x - 0.03, seatH, yy))?.let { g.color = lit(x, 0.2, yy, 0.55); g.fill(it) }
        }
        fun seat() {
            room(t3(a, seatH, n), t3(b, seatH, n), t3(b, seatH, sb), t3(a, seatH, sb))?.let { g.color = lit(m, seatH, n, 1.1); g.fill(it); grain(it, t3(a, seatH, n), t3(b, seatH, n), 0.0, 1, 3) }
            // the front edge of the plank
            room(t3(a, seatH - 0.06, n), t3(b, seatH - 0.06, n), t3(b, seatH, n), t3(a, seatH, n))?.let { g.color = lit(m, seatH, n, 0.75); g.fill(it); outline(it) }
        }
        fun back() {
            // two broad boards one above the other, a joint between them
            room(t3(a, seatH, sb), t3(b, seatH, sb), t3(b, backH, sb), t3(a, backH, sb))?.let { shape ->
                g.color = lit(m, 0.7, sb, if (seeFront) 0.95 else 0.75); g.fill(shape)
                grain(shape, t3(a, seatH, sb), t3(b, seatH, sb), backH - seatH, 10, (ty * 100).toInt() + (a * 10).toInt())
                val j0 = P(a, (seatH + backH) / 2, sb); val j1 = P(b, (seatH + backH) / 2, sb)
                if (cz(a, sb) > 0.3 && cz(b, sb) > 0.3) line(alpha(Color(0x0A0806), 0.5), maxOf(1.0, 0.01 * f / maxOf(cz(a, sb), 0.5)), j0.x, j0.y, j1.x, j1.y)
                outline(shape) }
            // the rail along the top, catching the candlelight
            fillR(lit(m, backH, sb, 1.35), t3(a, backH, sb - 0.04), t3(b, backH, sb - 0.04), t3(b, backH + 0.04, sb + 0.04), t3(a, backH + 0.04, sb + 0.04))
        }
        // the ends (68 Test 32, 2 and 35.9): a plain upright board, as deep as seat and back, its top level with the rail
        fun end(e: Double) = room(t3(e, 0.0, n - 0.02), t3(e, backH + 0.04, n - 0.02), t3(e, backH + 0.04, sb + 0.04), t3(e, 0.0, sb + 0.04))?.let { shape ->
            g.color = lit(e, 0.6, (n + sb) / 2, 0.85); g.fill(shape); grain(shape, t3(e, 0.0, n), t3(e, 0.0, sb + 0.04), backH, 12, (e * 100).toInt()); outline(shape) }
        val (farE, nearE) = if (cz(a, (n + sb) / 2) > cz(b, (n + sb) / 2)) a to b else b to a
        end(farE)
        under()
        if (seeFront) { back(); seat() } else { seat(); back() }
        end(nearE)
    }

    // ---- the people

    /** Hair of the village, by daylight (dark brown, brown, grey, fair, red, black). */
    val hairs = listOf(0x3A2A1E, 0x6A4A30, 0x8A867E, 0x9A7A48, 0x7A3A1E, 0x1E1A18, 0x5A4A3A)
    enum class Kind { MAN, WOMAN, SCARF, HOOD, CHILD, DWARF, GUARD, ALDRIC, LYRA, OSRIC, KAEL }
    /** A person at (tx, ty), [h] tall, facing [face] degrees from north, seated or standing, of [kind]. */
    data class Who(val tx: Double, val ty: Double, val kind: Kind, val face: Double, val h: Double = 1.72, val seated: Boolean = false, val tone: Int = 0x3A3028, val holds: Boolean = false)
    /** Nobody stands right in front of the lens. */
    val peopleList by lazy { people().filter { hypot(it.tx - cam.tx, it.ty - cam.ty) > (if (shot == 1 && !it.seated) 1.6 else 1.0) }
        // 68 Test 35.9: of the village nobody stands halved by the edge of the picture
        .filter { it.kind in listOf(Kind.ALDRIC, Kind.LYRA, Kind.OSRIC) || cz(it.tx, it.ty) < 0.35 || sx(cx(it.tx, it.ty), cz(it.tx, it.ty)) in W * 0.04..W * 0.96 } }

    // 68 (Bilder vom Zweig): the same village in every picture, seated in all four pews; what the camera sees of it is its own
    fun people(): List<Who> = when (shot) {
        1 -> crowd() + listOf(Who(4.15, 2.45, Kind.ALDRIC, 0.0, 1.78))
        2 -> crowd() + listOf(Who(4.25, 2.25, Kind.ALDRIC, 82.0, 1.78), Who(4.8, 2.2, Kind.LYRA, 265.0, 1.68))
        3 -> crowd() + listOf(Who(4.45, 2.3, Kind.LYRA, 0.0, 1.68), Who(5.15, 2.6, Kind.OSRIC, 320.0, 1.7))
        4 -> crowd() + listOf(Who(4.95, 2.4, Kind.LYRA, 330.0, 1.68), Who(6.1, 1.95, Kind.OSRIC, 290.0, 1.7))
        else -> listOf(Who(4.5, 5.95, Kind.LYRA, 180.0, 1.68))
    }

    /**
     * The village (`STORY-REGELN.md`: the temple holds 25 to 30; [68.tempel.1] "voll mit Dorfleuten"): shoulder to shoulder in
     * the four pews, all facing the altar, the hero's place in the first row left free; the dwarf, Kael, Jorin and a few more
     * standing behind the last row, where there is no seat left.
     */
    fun crowd(): List<Who> {
        val out = ArrayList<Who>()
        val kinds = listOf(Kind.MAN, Kind.WOMAN, Kind.SCARF, Kind.MAN, Kind.HOOD, Kind.WOMAN, Kind.CHILD, Kind.MAN, Kind.SCARF, Kind.WOMAN, Kind.MAN)
        val tones = listOf(0x4A3A2A, 0x5A4A3A, 0x6A3A30, 0x3A4030, 0x4A4A44, 0x5A4030, 0x5A6070, 0x403028, 0x6A4A3A, 0x4A3A40)
        var k = 0
        for (ty in listOf(3.0, 4.0)) for ((a, b) in pews) {
            var tx = a + 0.24
            while (tx < b - 0.18) { val kind = kinds[k % kinds.size]
                if (!(ty == 3.0 && a < 4 && tx > 3.55)) // the hero's place in the first row, by the aisle, stays free
                    out += Who(tx, ty + sitY, kind, 0.0, if (kind == Kind.CHILD) 1.45 else 1.6 + 0.15 * rnd(k, 71), seated = true, tone = tones[k % tones.size], holds = rnd(k, 75) < 0.35)
                tx += 0.3 + 0.04 * rnd(k, 72); k++ }
        }
        out += Who(4.5, 5.1, Kind.DWARF, 0.0, 1.3, tone = 0x5A3A22)  // in the aisle behind the last row
        out += Who(4.2, 5.45, Kind.KAEL, 350.0, 1.55, tone = 0x4A4038)
        out += Who(1.5, 5.2, Kind.GUARD, 15.0, 1.8, tone = 0x2A3A5A)
        for ((tx, ty) in listOf(2.5 to 5.3, 5.7 to 5.35)) { out += Who(tx, ty, kinds[k % kinds.size], 0.0, 1.62 + 0.12 * rnd(k, 73), tone = tones[k % tones.size], holds = rnd(k, 76) < 0.5); k++ }
        return out
    }

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
        val hem = if (p.seated) py - 0.35 * s else py - 0.03 * s
        body.moveTo(px - shoulder * 0.55, neck - 0.02 * s)
        body.curveTo(px - shoulder * 1.05, neck, px - shoulder * 1.1, neck + 0.12 * s, px - shoulder * 1.05, neck + 0.3 * s)
        body.lineTo(px - shoulder * 1.15, hem - 0.01 * s)
        body.quadTo(px, hem + 0.025 * s, px + shoulder * 1.15, hem - 0.01 * s)
        body.lineTo(px + shoulder * 1.05, neck + 0.3 * s)
        body.curveTo(px + shoulder * 1.1, neck + 0.12 * s, px + shoulder * 1.05, neck, px + shoulder * 0.55, neck - 0.02 * s)
        body.closePath()
        // 68 Test 35.11: one sitting, seen from the side, has thighs forward over the seat and shins down to the floor, not a
        // body that ends in the air at the height of the seat
        // (seen from behind the seat and the back hide them)
        if (p.seated && abs(side) > 0.25 && toUs > -0.3) {
            val legC = mix(robeC, Color(0x050406), 0.35); val knee = px + side * 0.42 * s; val back = px - side * shoulder * 0.9
            poly(legC, back, hem - 0.13 * s, knee + side * 0.05 * s, hem - 0.11 * s, knee + side * 0.05 * s, hem + 0.02 * s, back, hem + 0.02 * s)
            poly(legC, knee - side * 0.07 * s, hem, knee + side * 0.05 * s, hem, knee + side * 0.03 * s, py, knee - side * 0.09 * s, py)
            g.color = alpha(Color(0x050406), 0.6); g.fill(Ellipse2D.Double(knee - side * 0.1 * s - 0.06 * s, py - 0.02 * s, 0.16 * s, 0.04 * s))
        }
        // 68 Test 35.11: one standing stands on the flags: a shadow under him and the shoes under the hem
        if (!p.seated) {
            g.color = alpha(Color(0x000000), 0.5); g.fill(Ellipse2D.Double(px - shoulder * 1.7, py - 0.035 * s, shoulder * 3.4, 0.07 * s))
            for (e in listOf(-1.0, 1.0)) { g.color = Color(0x16100C); g.fill(Ellipse2D.Double(px + e * shoulder * 0.45 - 0.06 * s + side * 0.04 * s, py - 0.05 * s, 0.12 * s, 0.05 * s)) }
        }
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
            g.paint = GradientPaint(0f, neck.toFloat(), alpha(Color(0xFFB868), 0.06 + 0.6 * rimW), 0f, (neck + 0.7 * s).toFloat(), alpha(Color(0xFFB868), 0.0)); g.draw(body) }
        else { g.stroke = java.awt.BasicStroke(maxOf(1.5, 0.03 * s).toFloat()); g.color = alpha(Color(0xD8DCE4), 0.55); g.draw(body) }
        g.clip = clip
        val w = warmth(p.tx, 1.4, p.ty).coerceAtMost(1.0)
        if (!dawn) {
            line(alpha(Color(0xFFB060), 0.05 + 0.6 * w), maxOf(1.0, 0.025 * s), px + shoulder * 1.05 * lightX, neck + 0.05 * s, px + shoulder * 1.12 * lightX, neck + 0.6 * s)
            // the light from ahead catches the top of the shoulders
            line(alpha(Color(0xFFB060), 0.04 + 0.5 * w), maxOf(1.0, 0.02 * s), px - shoulder * 0.9, neck + 0.01 * s, px + shoulder * 0.9, neck + 0.01 * s)
            // 112 (2): the grey of the windows on the other shoulder
            val c = cold(p.tx, 1.4, p.ty); if (c > 0.08) line(alpha(Color(0x8A9AB8), 0.5 * c), maxOf(1.0, 0.02 * s), px - shoulder * 1.05 * lightX, neck + 0.05 * s, px - shoulder * 1.12 * lightX, neck + 0.55 * s)
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
        /**
         * 68 Test 35.10: an arm as a sleeve of the robe with a shoulder, an elbow and a hand: from the shoulder on the body's
         * outline ([ax], [ay]) down to the elbow, on to the hand; the sleeve in the robe's own shade, not lighter than the body.
         */
        fun arm(ax: Double, ay: Double, ex: Double, ey: Double, hx0: Double, hy0: Double) {
            val c = mix(robeC, Color(0x050406), 0.22)
            line(c, maxOf(2.5, 0.095 * s), ax, ay, ex, ey); line(c, maxOf(2.0, 0.075 * s), ex, ey, hx0, hy0)
            val cx0 = hx0 + (ex - hx0) * 0.12; val cy0 = hy0 + (ey - hy0) * 0.12
            line(mix(c, Color(0x050406), 0.3), maxOf(2.0, 0.08 * s), cx0, cy0, cx0 + (ex - hx0) * 0.05, cy0 + (ey - hy0) * 0.05)
            g.color = skin; g.fill(Ellipse2D.Double(hx0 - 0.04 * s, hy0 - 0.032 * s, 0.08 * s, 0.064 * s))
        }
        // 68 Test 35.10: Aldric's hair grey-white in the shade, no white cap
        val hair = when (p.kind) { Kind.ALDRIC -> mix(Color(0x7A7672), Color(0xC8B898), w * 0.3); Kind.LYRA -> night(0x6A4A30, 0.7); Kind.OSRIC -> skin; Kind.CHILD -> night(0x8A6A40, 0.9); else -> night(hairs[(rnd((p.tx * 100).toInt(), (p.ty * 100).toInt()) * hairs.size).toInt()], 1.0) }
        // 112 (5): what is on the head, so no two neighbours look alike: a felt cap for some men, a linen coif for some women
        val pick = rnd((p.tx * 37).toInt(), (p.ty * 53).toInt())
        val cap = p.kind == Kind.MAN && pick < 0.4; val coif = p.kind == Kind.WOMAN && pick < 0.55
        when (p.kind) {
            Kind.HOOD -> { g.color = robeC; g.fill(Ellipse2D.Double(hx - head * s * 1.25, top - 0.03 * s, head * s * 2.5, head * s * 2.6)) }
            Kind.SCARF -> { g.color = night(0x8A3A30, 0.7); g.fill(Ellipse2D.Double(hx - head * s * 1.1, top, head * s * 2.2, head * s * 2.3)) }
            Kind.GUARD -> { g.color = Color(0x6A6A70); g.fill(Ellipse2D.Double(hx - head * s * 1.1, top - 0.02 * s, head * s * 2.2, head * s * 2.0)) }
            else -> {
                // the neck and the nape in skin, the hair over the back of the head, its lighter strands catching the light
                g.color = mix(skin, Color(0x000000), 0.25); g.fill(java.awt.geom.Rectangle2D.Double(hx - head * s * 0.45, top + head * s * 1.6, head * s * 0.9, (neck - top) - head * s * 1.5))
                // 68 (Bilder vom Zweig): a face turned to us is framed by the hair behind it, so the head reads as a head
                if (toUs > 0.3 && p.kind != Kind.OSRIC && !coif) { g.color = hair
                    val long = p.kind == Kind.WOMAN || p.kind == Kind.LYRA
                    g.fill(Ellipse2D.Double(hx - head * s * 1.05, top - 0.012 * s, head * s * 2.1, head * s * (if (long) 2.9 else 2.15))) }
                g.color = skin
                g.fill(Ellipse2D.Double(hx - head * s * 0.92, top, head * s * 1.84, head * s * 2.2))
                if (toUs > 0.3 && p.kind != Kind.OSRIC && !coif && !cap) { val c0 = g.clip
                    g.clip(java.awt.geom.Rectangle2D.Double(hx - head * s * 1.1, top - 0.02 * s, head * s * 2.2, head * s * 0.62)); g.color = hair
                    g.fill(Ellipse2D.Double(hx - head * s * 0.98, top - 0.012 * s, head * s * 1.96, head * s * 2.2)); g.clip = c0 }
                if (toUs <= 0.3 && p.kind != Kind.OSRIC) { g.color = hair
                    val long = p.kind == Kind.WOMAN || p.kind == Kind.LYRA
                    // in profile the hair sits on the back of the head, the face side shows skin; Aldric keeps only a white fringe
                    // round the back and sides under a bald crown (68 Test 35.10: no white cap on his head)
                    g.fill(Ellipse2D.Double(hx - head * s * 0.96 - side * abs(side) * head * s * 0.3, top - 0.01 * s, head * s * 1.92, head * s * (if (long) 2.0 else 1.55)))
                    if (long && !coif) g.fill(java.awt.geom.Rectangle2D.Double(hx - head * s * 0.7, top + head * s * 1.2, head * s * 1.4, head * s * 1.6))  // hair down the back
                    for (k in 0 until 7) { val u = (rnd(k, (pick * 1000).toInt()) - 0.5) * 1.4 * head * s
                        line(alpha(mix(hair, Color(0xFFC890), 0.35), 0.08 + 0.14 * w), maxOf(0.6, 0.005 * s), hx + u * 0.7, top + head * s * (0.2 + 0.3 * rnd(k, 61)), hx + u, top + head * s * 1.3) } }
                if (cap) { g.color = night(listOf(0x4A3A28, 0x3A4030, 0x5A3020)[(pick * 30).toInt() % 3], 1.0)
                    g.fill(Ellipse2D.Double(hx - head * s * 1.05, top - 0.03 * s, head * s * 2.1, head * s * 1.15))
                    line(alpha(Color(0x000000), 0.5), maxOf(1.0, 0.012 * s), hx - head * s * 1.05, top + head * s * 0.55, hx + head * s * 1.05, top + head * s * 0.55) }
                if (coif) { val linen = if (dawn) Color(0x9A9EA8) else mix(night(0xD8D0C0, 1.3), Color(0xF0C890), w * 0.6)
                    g.color = linen; g.fill(Ellipse2D.Double(hx - head * s * 1.02, top - 0.02 * s, head * s * 2.04, head * s * 2.3))
                    for (k in -1..1) line(alpha(Color(0x000000), 0.12), maxOf(0.8, 0.01 * s), hx + k * head * s * 0.5, top + head * s * 0.6, hx + k * head * s * 0.7, top + head * s * 2.2) }
                run { // the rim of light only on the side and top towards the candles, not round the whole head
                    val hd = Ellipse2D.Double(hx - head * s, top, head * s * 2, head * s * 2.2); val c0 = g.clip; g.clip(hd)
                    g.stroke = java.awt.BasicStroke(maxOf(1.2, 0.03 * s).toFloat()); g.color = if (dawn) alpha(Color(0xD8DCE4), 0.4) else alpha(Color(0xFFC078), 0.05 + 0.55 * w)
                    g.draw(java.awt.geom.Arc2D.Double(hd.x, hd.y, hd.width, hd.height, if (lightX > 0) -30.0 else 90.0, 120.0, java.awt.geom.Arc2D.OPEN)); g.clip = c0 }
                if (abs(side) > 0.6) { // profile: the nose as a small step in the outline on the side it faces
                    val nx = hx + side * head * s * 1.0; poly(skin, nx, headY - 0.01 * s, nx + side * 0.035 * s, headY + 0.03 * s, nx, headY + 0.045 * s) }
                if (p.kind == Kind.OSRIC) g.color = alpha(Color(0xFFE0B0), 0.5 * w).also { g.fill(Ellipse2D.Double(hx - head * s * 0.6 + lightX * head * s * 0.3, top + 0.01 * s, head * s * 0.9, head * s * 0.7)) }
            }
        }
        if (p.kind == Kind.LYRA) { // the circlet: a thin band of dull metal close round the brow, never standing off the head (68 Test 35.10)
            val cy0 = top + head * s * 0.62
            val c0 = g.clip; g.clip(Ellipse2D.Double(hx - head * s * 0.98, top - 0.01 * s, head * s * 1.96, head * s * 2.25))
            g.color = if (dawn) Color(0x9A9EA6) else mix(Color(0x7A6440), Color(0xD0B070), w); g.stroke = java.awt.BasicStroke(maxOf(1.0, 0.009 * s).toFloat())
            g.draw(java.awt.geom.Arc2D.Double(hx - head * s * 1.0, cy0 - head * s * 0.12, head * s * 2.0, head * s * 0.24, 180.0, 180.0, java.awt.geom.Arc2D.OPEN))
            g.clip = c0 }
        if (p.kind == Kind.ALDRIC) {
            // the long white beard in profile, the staff across his shoulder
            if (abs(side) > 0.3 || toUs > 0.3) { val bx = hx + side * head * s * 0.5
                poly(hair, bx - side * 0.03 * s, headY + 0.04 * s, bx + side * 0.1 * s, headY + 0.05 * s, bx + side * 0.06 * s, neck + 0.34 * s, bx - side * 0.02 * s, neck + 0.16 * s) }
            // 68 Test 32 (3): the staff upright in the hand away from where he faces, its foot on the flags, its head over his own
            // 68 Test 35.10: held by an arm from the shoulder, bent at the elbow, the fist round the staff
            val sgn = if (side < 0) -1.0 else 1.0; val stx = px - sgn * shoulder * 1.4; val grip = neck + 0.4 * s
            line(mix(Color(0x3A2818), Color(0xA07040), w * 0.6), maxOf(1.5, 0.028 * s), stx, py, stx, top - 0.12 * s)
            arm(px - sgn * shoulder * 0.9, neck + 0.07 * s, px - sgn * shoulder * 1.2, neck + 0.3 * s, stx, grip)
        }
        if (p.kind == Kind.OSRIC && shot == 3) {
            // the candle in his hands before his breast, its light up into his face
            // (68 Test 35.11) seen from behind he holds it out a little to the side, so it shows beside him, not through his back
            val sgn = if (side < 0) -1.0 else 1.0
            val cxp = if (toUs < 0) px + sgn * shoulder * 1.45 else px + side * 0.2 * s; val cyp = neck + 0.35 * s
            line(Color(0xE8DCC0), maxOf(1.5, 0.04 * s), cxp, cyp, cxp, cyp - 0.18 * s)
            if (toUs < 0) arm(px + sgn * shoulder * 0.9, neck + 0.07 * s, px + sgn * shoulder * 1.2, neck + 0.32 * s, cxp, cyp)
            else { g.color = skin; g.fill(Ellipse2D.Double(cxp - 0.05 * s, cyp - 0.03 * s, 0.1 * s, 0.07 * s)) }
            burn(cxp, cyp - 0.18 * s, s * 0.55, 77)
        }
        if (p.kind == Kind.ALDRIC && shot == 2 || p.kind == Kind.LYRA && shot == 2) {
            // the hands towards each other, holding the amulet between them
            val hand = px + side * 0.36 * s; val hy0 = neck + 0.42 * s
            arm(px + side * shoulder * 0.9, neck + 0.07 * s, px + side * (shoulder + 0.05 * s), neck + 0.32 * s, hand, hy0)
            if (p.kind == Kind.LYRA) amuletAt(hand + side * 0.06 * s, hy0, s, 0.5)
        }
        if (p.kind == Kind.LYRA && shot == 3) {
            // the amulet raised in both hands before her (seen from behind: the hands and its glow above her shoulders)
            // (68 Test 35.11) both arms raised, the amulet held up over her head, so it shows above her and not on her back
            val ay = top - 0.1 * s
            for (e in listOf(-1.0, 1.0)) arm(px + e * shoulder * 0.9, neck + 0.07 * s, px + e * shoulder * 1.25, neck - 0.14 * s, px + e * 0.045 * s, ay + 0.03 * s)
            glow(px, ay, 0.5 * s, Color(0xFFD070), 0.5)
            amuletAt(px, ay - 0.03 * s, s, 0.55)
        }
        if (p.kind == Kind.LYRA && shot == 4) {
            // her hands folded before her breast, the amulet in the stand before her
            for (e in listOf(-1.0, 1.0)) arm(px + e * shoulder * 0.9, neck + 0.07 * s, px + e * shoulder * 0.95, neck + 0.36 * s, px + e * 0.02 * s + side * 0.05 * s, neck + 0.27 * s)
        }
        // [68.tempel.4] "die Gesichter werden hell": the light from the amulet on the faces of the village turned to it
        if (sun && p.seated) glow(hx + side * head * s * 0.6, headY, head * s * 2.6, Color(0xFFD890), 0.45)
        if (sun && (p.kind == Kind.LYRA || p.kind == Kind.OSRIC)) {
            // the first light on the faces turned to the amulet
            glow(hx + side * head * s * 0.6, headY, head * s * 2.2, Color(0xFFD890), 0.5)
        }
    }

    /** Picture 4: the first sun through the east window, a shaft of light through the dusty air down onto the amulet. */
    /**
     * Picture 3 (112, 2): no sun yet, only the grey before it; from the north-west window a broad, soft fall of cool light
     * slants down onto the flags and the left end of the altar, fading as it goes. Not a shaft with edges like picture 4.
     */
    fun greyLight() {
        val wx = 1.5; val wy = 1.0
        if (cz(wx, wy) < 0.3) return
        val old = g.composite
        // soft edges: the same fall laid several times, a little wider each time and fainter
        // 68 Test 32 (1): the fall starts in the glass (half width 0.2, arch from 4.05), never on the wall above or beside it
        for (k in 0 until 6) {
            val e = 0.12 * k
            val s0 = P(wx - 0.17, 3.95, wy); val s1 = P(wx + 0.17, 3.95, wy); val s3 = P(wx - 0.17, 2.3, wy)
            val f0 = P(1.9 - e, 0.0, 1.9 - e * 0.5); val f1 = P(3.5 + e, 0.0, 2.0 - e * 0.5); val f2 = P(3.7 + e, 0.0, 3.3 + e); val f3 = P(1.7 - e, 0.0, 3.1 + e)
            val fall = Path2D.Double().apply { moveTo(s0.x, s0.y); lineTo(s1.x, s1.y); lineTo(f1.x, f1.y); lineTo(f2.x, f2.y); lineTo(f3.x, f3.y); lineTo(f0.x, f0.y); lineTo(s3.x, s3.y); closePath() }
            val mid = Point2D.Double((f0.x + f1.x + f2.x + f3.x) / 4, (f0.y + f1.y + f2.y + f3.y) / 4)
            g.composite = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.075f)
            g.paint = GradientPaint(s1.x.toFloat(), s1.y.toFloat(), Color(0x8C9AB4), mid.x.toFloat(), mid.y.toFloat(), Color(0x5C6E90))
            g.fill(fall)
        }
        g.composite = old
    }

    fun sunBeam() {
        val wx = 8.0; val wy = 3.5
        // 68 Test 32 (4): the shaft starts in the glass (half width 0.2, arch from 4.05), its edges soft: the same shaft laid
        // several times, a little wider and fainter each time, brightest at the window, fading towards the amulet
        val src = listOf(P(wx, 3.95, wy - 0.17), P(wx, 3.95, wy + 0.17), P(wx, 2.25, wy + 0.17), P(wx, 2.25, wy - 0.17))
        val dst = P(4.5, 1.5, 1.45)
        val s = f / cz(4.5, 1.45)
        shaft = listOf(src[0], Point2D.Double(dst.x + 0.25 * s, dst.y - 0.3 * s), Point2D.Double(dst.x - 0.25 * s, dst.y + 0.3 * s), src[2], src[3])
        val old = g.composite
        for (k in 0 until 7) {
            val e = 0.06 * k * s
            val beam = Path2D.Double().apply {
                moveTo(src[0].x, src[0].y); lineTo(dst.x + 0.2 * s + e, dst.y - 0.26 * s - e); lineTo(dst.x - 0.2 * s - e, dst.y + 0.26 * s + e); lineTo(src[2].x, src[2].y); lineTo(src[3].x, src[3].y); closePath()
            }
            g.composite = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.07f)
            g.paint = GradientPaint(src[0].x.toFloat(), src[0].y.toFloat(), Color(0xFFE8B0), dst.x.toFloat(), dst.y.toFloat(), Color(0xC89050))
            g.fill(beam)
        }
        g.composite = old
        glow(dst.x, dst.y, 0.35 * s, Color(0xFFE090), 0.5)
    }

    /** Dust in the air: in the candlelight before the dawn, in the sun shaft in picture 4, in the grey from the door in picture 5. */
    fun motes() {
        val n = if (sun) 260 else 90
        for (i in 0 until n) {
            val x = rnd(i, 901) * W; val y = rnd(i, 902) * H * 0.8
            // the dust in the sun shaft drifts in the app (TempleLife), so it is not painted fixed here
            if (shaft.size > 2 && Path2D.Double().apply { moveTo(shaft[0].x, shaft[0].y); for (q in shaft.drop(1)) lineTo(q.x, q.y); closePath() }.contains(x, y)) continue
            val a = if (sun) 0.35 else 0.12
            g.color = alpha(if (dawn) Color(0xC8CCD8) else Color(0xFFE0B0), a * rnd(i, 903)); val r = 0.8 + 1.4 * rnd(i, 904)
            g.fill(Ellipse2D.Double(x - r, y - r, r * 2, r * 2))
        }
    }
}

/**
 * 68 (228): the temple seen from above, as the five pictures stand on it: walls, windows and door, altar, candlesticks,
 * lectern, font, the pews with the village in them, Aldric, Lyra and Osric where each picture has them, and each camera with
 * the angle it sees.
 */
internal fun templePlan(): java.awt.image.BufferedImage {
    val u = 120.0; val ox = 60.0 - u; val oy = 110.0 - u
    val img = java.awt.image.BufferedImage(1080, 800, java.awt.image.BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics()
    g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON)
    g.setRenderingHint(java.awt.RenderingHints.KEY_TEXT_ANTIALIASING, java.awt.RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    fun X(tx: Double) = ox + tx * u
    fun Y(ty: Double) = oy + ty * u
    fun rect(c: Color, x0: Double, y0: Double, x1: Double, y1: Double) { g.color = c; g.fill(java.awt.geom.Rectangle2D.Double(X(x0), Y(y0), (x1 - x0) * u, (y1 - y0) * u)) }
    fun dot(c: Color, tx: Double, ty: Double, r: Double) { g.color = c; g.fill(Ellipse2D.Double(X(tx) - r, Y(ty) - r, r * 2, r * 2)) }
    fun text(s: String, x: Double, y: Double, c: Color = Color(0xE8DCC0), size: Int = 22) { g.font = java.awt.Font(java.awt.Font.SANS_SERIF, java.awt.Font.PLAIN, size); g.color = c; g.drawString(s, x.toFloat(), y.toFloat()) }
    g.color = Color(0x101218); g.fillRect(0, 0, 1080, 800)
    text("Tempel von oben: Sitzordnung und die fünf Kameras (Norden oben)", 60.0, 50.0, Color(0xD8B868), 26)
    // walls, floor, windows, door
    rect(Color(0x4A4A50), 0.85, 0.85, 8.15, 6.15); rect(Color(0x2A2C32), 1.0, 1.0, 8.0, 6.0)
    for ((wx, wy) in listOf(1.5 to 1.0, 7.5 to 1.0, 6.5 to 6.0, 1.5 to 6.0)) rect(Color(0x7A9AD0), wx - 0.2, wy - 0.12, wx + 0.2, wy + 0.12)
    rect(Color(0xFFD080), 7.88, 3.3, 8.12, 3.7)
    rect(Color(0x101218), 4.08, 5.86, 4.92, 6.18)
    text("Ostfenster", X(8.2), Y(3.55), Color(0xFFD080), 18); text("Tür", X(4.3), Y(5.75), size = 18)
    val p = TemplePainter(1)
    // altar, candlesticks, lectern, font
    rect(Color(0xB8B0A0), 3.05, 1.15, 5.95, 1.85); text("Altar", X(4.2), Y(1.6), Color(0x202020), 20)
    dot(Color(0xD8B868), 4.5, 1.45, 7.0)
    for (cx0 in listOf(2.5, 6.5)) dot(Color(0x8A8070), cx0, 1.5, 6.0)
    rect(Color(0x8A6A40), 5.4, 2.43, 5.8, 2.67); dot(Color(0x8A8A90), 3.5, 5.5, 13.0)
    // pews: seat and back
    for (ty in listOf(3.0, 4.0)) for ((a, b) in p.pews) { rect(Color(0x6A4A30), a, ty + p.seatF, b, ty + p.backY); rect(Color(0x3A2818), a, ty + p.backY - 0.04, b, ty + p.backY + 0.02) }
    // the village
    val crowd = p.crowd()
    for (w in crowd) dot(if (w.seated) Color(0xC8A878) else Color(0x8AA0B8), w.tx, w.ty, if (w.kind == TemplePainter.Kind.CHILD) 7.0 else 9.0)
    // the three named, per picture
    val named = mapOf(TemplePainter.Kind.ALDRIC to Color(0xB05070), TemplePainter.Kind.LYRA to Color(0xF0F0F0), TemplePainter.Kind.OSRIC to Color(0xE0B040))
    for (n in 1..5) for (w in TemplePainter(n).people().filter { it.kind in named }) {
        dot(named.getValue(w.kind), w.tx, w.ty, 8.0); text("$n", X(w.tx) + 8, Y(w.ty) - 6, named.getValue(w.kind), 16) }
    // the cameras: position, the angle seen, the number
    for (n in 1..5) {
        val c = TemplePainter(n); val half = kotlin.math.atan(540.0 / c.f); val yaw = c.cam.yaw * PI / 180
        val len = 1.6
        val l = yaw - half; val r = yaw + half
        val x0 = X(c.cam.tx); val y0 = Y(c.cam.ty)
        val cone = Path2D.Double().apply { moveTo(x0, y0); lineTo(x0 + sin(l) * len * u, y0 - cos(l) * len * u); lineTo(x0 + sin(r) * len * u, y0 - cos(r) * len * u); closePath() }
        g.color = Color(0xFF, 0xC0, 0x60, 56); g.fill(cone); g.color = Color(0xFFC060); g.stroke = java.awt.BasicStroke(2f); g.draw(cone)
        dot(Color(0xFFC060), c.cam.tx, c.cam.ty, 14.0); text("$n", x0 - 7, y0 + 8, Color(0x101218), 22)
    }
    // legend
    val ly = 760.0
    dot(Color(0xC8A878), (70.0 - ox) / u, (ly - 7 - oy) / u, 9.0); text("sitzt (${crowd.count { it.seated }})", 85.0, ly)
    dot(Color(0x8AA0B8), (250.0 - ox) / u, (ly - 7 - oy) / u, 9.0); text("steht (${crowd.count { !it.seated }})", 265.0, ly)
    dot(Color(0xB05070), (420.0 - ox) / u, (ly - 7 - oy) / u, 8.0); text("Aldric", 435.0, ly)
    dot(Color(0xF0F0F0), (540.0 - ox) / u, (ly - 7 - oy) / u, 8.0); text("Lyra", 555.0, ly)
    dot(Color(0xE0B040), (640.0 - ox) / u, (ly - 7 - oy) / u, 8.0); text("Osric", 655.0, ly)
    dot(Color(0xFFC060), (760.0 - ox) / u, (ly - 7 - oy) / u, 12.0); text("Kamera n; Ziffer an der Figur = Bild", 780.0, ly, size = 18)
    g.dispose()
    return img
}
