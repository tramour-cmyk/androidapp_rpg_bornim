package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Race
import de.bornim.core.art.Mat
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapRoom
import de.bornim.core.art.PixelImage
import de.bornim.core.art.Ramp
import de.bornim.core.art.RoomThings
import de.bornim.core.art.Sculpt
import de.bornim.core.art.argb
import de.bornim.core.art.mix
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.sqrt

/**
 * Draft for topic 13 (10.10.): a corner of the inn seen diagonally (the camera turned by 45°,
 * tiles as diamonds 2:1) next to the hero walking towards us and away from us, straight on (as now)
 * and diagonal. Only a picture (ISODRAFT=1), nothing of it is in the game.
 */
private const val TW = 90.0      // a tile's diamond, art pixels wide
private const val TH = 45.0      // and high
private const val WH = 112.0     // walls, art pixels high
private const val NI = 6.0       // the room: tiles along i (the right-hand back wall)
private const val NJ = 5.0       // and along j (the left-hand back wall)

private class Iso(val w: Int, val h: Int) {
    val img = PixelImage(w, h)
    val ox = w / 2.0 + (NI - NJ) * TW / 4 - 10
    val oy = 150.0
    fun sx(i: Double, j: Double) = ox + (i - j) * TW / 2
    fun sy(i: Double, j: Double, z: Double = 0.0) = oy + (i + j) * TH / 2 - z

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0

    // the hearth in the right-hand wall, the window in the left-hand wall: where the light comes from
    val fireI = 2.8; val fireJ = 0.15
    /** Warm firelight and a little cool window light on a point of the room. */
    fun light(i: Double, j: Double, z: Double): Pair<Double, Double> {
        val d2 = (i - fireI) * (i - fireI) + (j - fireJ) * (j - fireJ) + (z / 64.0 - 0.4).let { it * it } * 0.6
        val warm = 1.25 * exp(-d2 / 5.5)
        val wd = (i - 0.2) * (i - 0.2) + (j - 3.0) * (j - 3.0)
        val cool = 0.35 * exp(-wd / 2.2)
        return warm to cool
    }
    fun lit(c: Int, i: Double, j: Double, z: Double, ambient: Double = 0.38): Int {
        val (warm, cool) = light(i, j, z)
        val r = ((c shr 16) and 0xFF) * (ambient + warm * 1.05 + cool * 0.7)
        val g = ((c shr 8) and 0xFF) * (ambient + warm * 0.78 + cool * 0.8)
        val b = (c and 0xFF) * (ambient + warm * 0.5 + cool * 1.0)
        return argb(((r.toInt().coerceIn(0, 255)) shl 16) or ((g.toInt().coerceIn(0, 255)) shl 8) or b.toInt().coerceIn(0, 255))
    }

    /** Floor of oak boards running along i, worn paler where feet go. */
    fun floor() {
        for (y in 0 until h) for (x in 0 until w) {
            val a = (x - ox) / (TW / 2); val b = (y - oy) / (TH / 2)
            val i = (a + b) / 2; val j = (b - a) / 2
            if (i < 0 || j < 0 || i > NI || j > NJ) continue
            val plank = floor(j * 4).toInt()
            val joint = floor(i * 1.2 + rnd(plank, 0, 3) * 3).toInt()
            var v = 0.55 + (rnd(plank, joint, 4) - 0.5) * 0.25 + (rnd(x / 2, y, 5) - 0.5) * 0.12
            val fj = j * 4 - plank
            if (fj < 0.07) v -= 0.3
            val fi = i * 1.2 + rnd(plank, 0, 3) * 3 - joint
            if (fi < 0.025) v -= 0.25
            // worn paler on the path from the door to the counter
            v += 0.08 * exp(-((j - 3.4) * (j - 3.4)) / 1.2)
            // in the walls' shade
            v -= 0.18 * exp(-i * 2.5) + 0.18 * exp(-j * 2.5)
            val base = mix(argb(0x22180F), argb(0x6A5038), v.coerceIn(0.0, 1.0))
            img.set(x, y, lit(base, i, j, 0.0))
        }
    }

    /** The two back walls: smoke-stained plaster between dark beams, the hearth, a window. */
    fun walls() {
        for (y in 0 until h) for (x in 0 until w) {
            // right-hand wall, the plane j = 0
            run {
                val i = (x - ox) / (TW / 2)
                val z = oy + i * TH / 2 - y
                if (i in 0.0..NI && z in 0.0..WH) { img.set(x, y, wallPixel(i, 0.0, z, i, true)); return@run }
            }
            // left-hand wall, the plane i = 0
            val j = (ox - x) / (TW / 2)
            val z = oy + j * TH / 2 - y
            if (j in 0.0..NJ && z in 0.0..WH && !img.opaque(x, y)) img.set(x, y, wallPixel(0.0, j, z, j, false))
        }
        // the walls' thick dark tops
        for (k in 0..((NI * TW / 2).toInt())) for (t in 0..5) img.set((ox + k).toInt(), (oy + k * TH / TW - WH - t).toInt(), argb(0x161210))
        for (k in 0..((NJ * TW / 2).toInt())) for (t in 0..5) img.set((ox - k).toInt(), (oy + k * TH / TW - WH - t).toInt(), argb(0x1A1512))
    }

    private fun wallPixel(i: Double, j: Double, z: Double, u: Double, right: Boolean): Int {
        val seed = if (right) 11 else 12
        // the hearth: a stone surround with an arched mouth, i 2.1..3.5 on the right-hand wall
        if (right && u in 2.1..3.5 && z < 96) {
            val m = (u - 2.8) / 0.52
            val arch = 50 + 12 * sqrt((1 - m * m).coerceAtLeast(0.0))
            if (u in 2.28..3.32 && z < arch) {
                val glow = (1 - z / arch).coerceIn(0.0, 1.0)
                return mix(argb(0x140C08), argb(0xB0501C), glow * glow * (1 - m * m).coerceAtLeast(0.0))
            }
            val row = floor(z / 11).toInt(); val col = floor(u * 9 + row % 2 * 0.5).toInt()
            var v = 0.5 + (rnd(row, col, seed) - 0.5) * 0.35
            if (z % 11 < 1.4 || (u * 9 + row % 2 * 0.5) % 1.0 < 0.08) v -= 0.3
            return lit(mix(argb(0x2A2622), argb(0x8A8070), v.coerceIn(0.0, 1.0)), i, j, z, 0.45)
        }
        // a window on the left-hand wall
        if (!right && u in 2.6..3.4 && z in 42.0..86.0) {
            if (u in 2.97..3.03 || z in 63.0..65.0 || u < 2.66 || u > 3.34 || z < 46 || z > 82) return argb(0x241A12)
            return mix(argb(0x40506A), argb(0x8A9AB0), (z - 46) / 40)
        }
        val post = (u % 2.0) < 0.12 || u > (if (right) NI else NJ) - 0.1
        val beam = z in 78.0..86.0 || z < 7
        val c = if (post || beam) mix(argb(0x1E1612), argb(0x4A382A), 0.45 + (rnd(floor(u * 20).toInt(), floor(z / 3).toInt(), seed) - 0.5) * 0.3)
        else {
            var v = 0.55 + (rnd(floor(u * 30).toInt(), floor(z / 2).toInt(), seed + 1) - 0.5) * 0.12
            v -= 0.25 * ((z - 40) / 70).coerceIn(0.0, 1.0)                      // smoke, darker up high
            if (right && u in 1.8..3.8) v -= 0.25 * ((z - 90) / 20).coerceIn(0.0, 1.0)
            mix(argb(0x2E2820), argb(0x8E8068), v.coerceIn(0.0, 1.0))
        }
        return lit(mix(c, argb(0x2A2018), 0.25), i, j, z, if (right) 0.3 else 0.28)
    }

    /** Lays a sprite with its anchor at (i, j), darkened by the room's light at that point. */
    fun place(src: PixelImage, ax: Int, ay: Int, i: Double, j: Double, light: Boolean = true) {
        val x0 = sx(i, j).toInt() - ax; val y0 = sy(i, j).toInt() - ay
        for (y in 0 until src.height) for (x in 0 until src.width) {
            val c = src[x, y]; val a = c ushr 24
            if (a == 0) continue
            val z = (src.height - y).toDouble()
            val cc = if (light && a == 255) lit(c, i, j, z, 0.42) else c
            val tx = x0 + x; val ty = y0 + y
            if (tx !in 0 until w || ty !in 0 until h) continue
            img.set(tx, ty, if (a == 255) cc else mix(img[tx, ty], cc or (0xFF shl 24), a / 255.0))
        }
    }
}

private fun mat(rgb: Int, grain: Double = 0.16, sat: Double = 0.9, value: Double = 0.85, bias: Double = 0.0, shine: Double = 0.0) =
    Mat(Ramp.of(argb(rgb), sat = sat, value = value), shine, grain, bias)

private val oak = mat(0x5A4030)
private val oakTop = mat(0x6A4A32, grain = 0.12, value = 0.8, bias = -0.3)
private val oakBack = mat(0x2E241C, bias = -0.08)
private val clay = mat(0x7A4E34, sat = 0.78, value = 0.9, shine = 0.1)
private val glass = mat(0x34463C, grain = 0.06, sat = 0.7, value = 0.9, shine = 0.75)
private val linen = mat(0x6E5E44, grain = 0.26, sat = 0.62, value = 0.74)
private val pewter = mat(0x76726A, grain = 0.15, sat = 0.3, value = 0.9, shine = 0.5)

/** A box between (i0, j0) and (i1, j1), from z0 up to z1: its top, its face towards +j (down left) and towards +i (down right). */
private fun Iso.box(s: Sculpt, i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, top: Mat, left: Mat, right: Mat) {
    // face j = j1 looks down left on the screen, face i = i1 looks down right
    s.poly(left, sx(i0, j1), sy(i0, j1, z0), sx(i1, j1), sy(i1, j1, z0), sx(i1, j1), sy(i1, j1, z1), sx(i0, j1), sy(i0, j1, z1), tiltX = -0.55, tiltY = 0.3, bevel = 1.0)
    s.poly(right, sx(i1, j0), sy(i1, j0, z0), sx(i1, j1), sy(i1, j1, z0), sx(i1, j1), sy(i1, j1, z1), sx(i1, j0), sy(i1, j0, z1), tiltX = 0.55, tiltY = 0.3, bevel = 1.0)
    s.poly(top, sx(i0, j0), sy(i0, j0, z1), sx(i1, j0), sy(i1, j0, z1), sx(i1, j1), sy(i1, j1, z1), sx(i0, j1), sy(i0, j1, z1), tiltY = -0.72, bevel = 0.6)
}

/** Lays one Sculpt layer onto the room, outlined, its colors in the room's light near (i, j). */
private fun Iso.layer(i: Double, j: Double, draw: (Sculpt) -> Unit) {
    val s = Sculpt(w, h, (i * 100 + j * 10).toInt())
    draw(s)
    s.outline(argb(0x0E0C0A))
    for (y in 0 until h) for (x in 0 until w) {
        val c = s.img[x, y]; if (c ushr 24 == 0) continue
        img.set(x, y, lit(c, i, j, (sy(i, j) - y).coerceAtLeast(0.0), 0.42))
    }
}

/** The tall shelf against the left-hand wall, its open front facing down right. */
private fun Iso.shelf() = layer(0.3, 1.3) { s ->
    val i0 = 0.02; val i1 = 0.48; val j0 = 0.7; val j1 = 1.9; val zt = 112.0
    // the back
    s.poly(oakBack, sx(i0, j0), sy(i0, j0), sx(i0, j1), sy(i0, j1), sx(i0, j1), sy(i0, j1, zt), sx(i0, j0), sy(i0, j0, zt), tiltX = 0.5, tiltY = 0.3, bevel = 0.0)
    for (k in 0 until 4) s.tint(sx(i0, (j0 + j1) / 2), sy(i0, (j0 + j1) / 2, 26.0 + k * 22 - 4), 30.0, 6.0, argb(0x0A0806), 0.45)
    // the far side
    box(s, i0, j0 - 0.08, i1, j0, 0.0, zt, oakTop, oak, oak)
    val heights = doubleArrayOf(4.0, 28.0, 50.0, 72.0, 94.0)
    for ((k, z) in heights.withIndex()) {
        // the board, then what stands on it, lined up along j
        box(s, i0, j0, i1, j1, z, z + 3, oakTop, oak, oak)
        if (k == heights.size - 1) break
        var j = j0 + 0.1
        var n = 0
        while (j < j1 - 0.12) {
            val ci = 0.22
            val x = sx(ci, j); val y = sy(ci, j, z + 3)
            when ((k * 7 + n * 3) % 5) {
                0 -> { s.limb(x, y - 1, x, y - 10, 3.4, 3.0, clay); s.blob(x, y - 11, 3.2, 1.5, linen, depth = 0.5) }
                1 -> { s.limb(x, y - 1, x, y - 7, 2.4, 2.3, glass); s.limb(x, y - 7, x, y - 11, 1.0, 0.9, glass) }
                2 -> { s.blob(x, y - 4, 5.0, 4.2, clay) ; s.blob(x, y - 7.6, 3.4, 1.2, clay, depth = 0.4) }
                3 -> { s.blob(x, y - 4, 4.6, 4.4, linen, depth = 0.8); s.limb(x, y - 8, x + 1, y - 10.5, 1.3, 0.9, linen) }
                else -> { s.limb(x, y - 1, x, y - 6, 2.6, 2.4, pewter) }
            }
            j += 0.2 + (n % 3) * 0.04
            n++
        }
    }
    // the near side and the front posts
    box(s, i0, j1, i1, j1 + 0.08, 0.0, zt, oakTop, oak, oak)
    box(s, i1 - 0.06, j0 - 0.08, i1, j0, 0.0, zt, oakTop, oak, oak)
    box(s, i0, j0 - 0.08, i1, j1 + 0.08, zt, zt + 4, oakTop, oak, oak)
}

/** A trestle table turned with the room: legs, a thick top, a few things on it. */
private fun Iso.table(i0: Double, j0: Double, i1: Double, j1: Double) = layer((i0 + i1) / 2, (j0 + j1) / 2) { s ->
    val zt = 40.0
    for ((li, lj) in listOf(i0 + 0.1 to j0 + 0.12, i1 - 0.1 to j0 + 0.12, i0 + 0.1 to j1 - 0.12, i1 - 0.1 to j1 - 0.12))
        box(s, li - 0.05, lj - 0.05, li + 0.05, lj + 0.05, 0.0, zt - 5, oak, oak, oak)
    box(s, i0, j0, i1, j1, zt - 5, zt, oakTop, oak, oak)
    // seams of the boards along i
    for (k in 1..2) { val jj = j0 + (j1 - j0) * k / 3; s.line(sx(i0, jj), sy(i0, jj, zt), sx(i1, jj), sy(i1, jj, zt), argb(0x261C14)) }
    fun at(i: Double, j: Double) = sx(i, j) to sy(i, j, zt)
    at(i0 + 0.3, j0 + 0.3).let { (x, y) -> s.limb(x, y - 1, x, y - 7, 2.6, 2.4, pewter); s.flat(x, y - 7.2, 2.0, 0.8, argb(0x2A1A0E)) }
    at(i0 + 0.9, j0 + 0.55).let { (x, y) -> s.blob(x, y - 1.6, 6.0, 2.8, clay, depth = 0.5); s.flat(x, y - 2.6, 4.2, 1.4, argb(0x4A2E1A)) }
    at(i1 - 0.35, j0 + 0.25).let { (x, y) -> s.limb(x, y - 1, x, y - 8, 1.3, 1.1, mat(0xC4B494, grain = 0.1, sat = 0.55)); s.flat(x, y - 10, 0.9, 2.0, argb(0xF0B050)) }
    at(i0 + 0.6, j1 - 0.3).let { (x, y) -> s.blob(x, y - 2.4, 5.6, 3.2, mat(0x9A7040, grain = 0.3), depth = 0.8) }
}

fun renderIsoDraft() {
    val dir = File("build/screens/iso").apply { mkdirs() }
    val room = Iso(720, 520)
    room.floor()
    room.walls()
    // things, back to front; the fire in the hearth's mouth
    MapRoom.fire(0, 58).let { room.place(it.img, it.ax, it.ay, 2.95, 0.12, light = false) }
    room.place(RoomThings.firewood(0).img, RoomThings.firewood(0).ax, RoomThings.firewood(0).ay, 1.5, 0.55)
    room.shelf()
    room.place(RoomThings.barrel(0).img, RoomThings.barrel(0).ax, RoomThings.barrel(0).ay, 4.6, 0.55)
    room.place(RoomThings.barrel(1).img, RoomThings.barrel(1).ax, RoomThings.barrel(1).ay, 5.25, 0.75)
    room.table(2.4, 1.9, 4.0, 2.75)
    // the hero in the room, walking along the boards towards the door, seen at three-quarters
    val hero = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    val walk = MapFigure.draw(hero, 2, 1)          // yaw 45°: along +i on the diamond grid, towards us
    room.place(walk, MapFigure.ANCHOR_X, MapFigure.GROUND, 3.3, 3.7)
    save(room.img, File(dir, "iso_schaenke.png"))

    // the hero alone: straight on (as now) and diagonal, towards us and away from us, two steps each
    val strip = PixelImage(MapFigure.W * 8, MapFigure.H)
    val shots = listOf(0 to 1, 0 to 3, 8 to 1, 8 to 3, 2 to 1, 2 to 3, 10 to 1, 10 to 3)
    for ((k, p) in shots.withIndex()) {
        val pic = MapFigure.draw(hero, p.first, p.second)
        for (y in 0 until pic.height) for (x in 0 until pic.width) if (pic.opaque(x, y)) strip.set(k * MapFigure.W + x, y, pic[x, y])
    }
    save(strip, File(dir, "iso_held.png"))
    println("wrote iso draft")
}

private fun save(p: PixelImage, f: File) {
    val img = BufferedImage(p.width, p.height, BufferedImage.TYPE_INT_ARGB)
    for (y in 0 until p.height) for (x in 0 until p.width) img.setRGB(x, y, p[x, y])
    ImageIO.write(img, "png", f)
}

/** Every look of the room's things seen diagonally (13, step 2), three per row, on a patch of boards (ISODINGE=1). */
fun renderIsoThings() {
    val dir = File("build/screens/iso").apply { mkdirs() }
    val elder = System.getenv("ISODINGE") == "aeltester"
    val rows = if (elder) de.bornim.core.art.MapRoomIso.elderSheet() else de.bornim.core.art.MapRoomIso.sheet()
    val cw = 150; val ch = 210
    val img = PixelImage(cw * 3, ch * rows.size)
    for (y in 0 until img.height) for (x in 0 until img.width) img.set(x, y, argb(0x2A2018))
    for ((r, row) in rows.withIndex()) for ((k, p) in row.second.withIndex()) {
        val ox = k * cw + (cw - p.width) / 2; val oy = r * ch + ch - 18 - p.height
        // the tile's diamond on the floor under it
        for (y in 0 until 46) for (x in 0 until 90) {
            val a = (x + 0.5 - 45) / 45.0; val b = (y + 0.5 - 45) / 22.5
            val i = (a + b) / 2; val j = (b - a) / 2
            if (i in -1.0..0.0 && j in -1.0..0.0) img.set(ox + p.width / 2 - 45 + x, oy + p.height - 45 + y, if ((x + y) % 7 == 0) argb(0x3A2C20) else argb(0x4A3826))
        }
        // things that hang on or lean against the back wall: a strip of it behind them
        if (elder && row.first in setOf("Wandbehang", "Stock")) {
            val cx = ox + p.width / 2; val by = oy + p.height
            for (x in 0..45) { val yb = by - 45 + x / 2; for (y in yb - 103..yb) img.set(cx + x, y, if (x == 0 || x == 45 || y == yb - 103) argb(0x221A14) else argb(0x3A3028)) }
        }
        for (y in 0 until p.height) for (x in 0 until p.width) {
            val c = p[x, y]; val a = c ushr 24
            if (a == 0) continue
            img.set(ox + x, oy + y, if (a == 255) c else mix(img[ox + x, oy + y], c or (0xFF shl 24), a / 255.0))
        }
    }
    // twice the size, each art pixel a block, to look at closely
    val big = PixelImage(img.width * 2, img.height * 2)
    for (y in 0 until big.height) for (x in 0 until big.width) big.set(x, y, img[x / 2, y / 2])
    save(big, File(dir, if (elder) "iso_aeltester.png" else "iso_dinge.png"))
    println("wrote iso things")
}

/**
 * The inn's hearth seen diagonally, the fire in each of its pictures (FEUER=1), to look at the flickering
 * picture by picture (13n). Without the game's light: the pictures as they are painted.
 */
fun renderIsoFire() {
    val dir = File("build/screens/iso").apply { mkdirs() }
    val map = de.bornim.core.World["inn"]
    val t = de.bornim.core.art.WorldArt.T
    for (f in 0 until de.bornim.core.art.MapRoomIso.FIRE_FRAMES) {
        val img = PixelImage(300, 240)
        for (y in 0 until img.height) for (x in 0 until img.width) img.set(x, y, argb(0x1A140F))
        // where a map pixel lands, in art pixels of this picture
        val ox = 150 - 45.0 * (4 - 1); val oy = 150 - 22.5 * (4 + 1)
        fun sx(wx: Double, wy: Double) = ox + (wx - wy) / t * 45.0
        fun sy(wx: Double, wy: Double) = oy + (wx + wy) / t * 22.5
        // the floor of the first rows, plain boards
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val a = (x - ox) / 45.0; val b = (y - oy) / 22.5
            val i = (a + b) / 2; val j = (b - a) / 2
            if (i in 1.0..8.0 && j in 1.0..3.0) img.set(x, y, if ((x + 2 * y) % 9 == 0) argb(0x3A2C20) else argb(0x5A4430))
        }
        val objs = (0 until 3).flatMap { ty -> (0 until map.width).flatMap { tx -> de.bornim.core.art.MapRoomIso.objects(map, tx, ty, f) ?: emptyList() } }
        for (o in objs.sortedBy { it.sortY + it.x + it.img.width / it.density / 2 }) {
            val wx = (o.x + o.img.width / o.density / 2).toDouble(); val wy = (o.y + o.img.height / o.density).toDouble()
            val x0 = (sx(wx, wy) - o.img.width / 2).toInt(); val y0 = (sy(wx, wy) - o.img.height).toInt()
            for (y in 0 until o.img.height) for (x in 0 until o.img.width) {
                val c = o.img[x, y]; val a = c ushr 24
                if (a == 0) continue
                img.set(x0 + x, y0 + y, if (a == 255) c else mix(img[x0 + x, y0 + y], c or (0xFF shl 24), a / 255.0))
            }
        }
        val big = PixelImage(img.width * 3, img.height * 3)
        for (y in 0 until big.height) for (x in 0 until big.width) big.set(x, y, img[x / 3, y / 3])
        save(big, File(dir, "feuer_$f.png"))
    }
    println("wrote fire pictures")
}
