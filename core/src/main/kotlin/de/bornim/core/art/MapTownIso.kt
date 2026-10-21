package de.bornim.core.art

import de.bornim.core.HouseFeature
import de.bornim.core.HouseStyle
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.RoofKind
import de.bornim.core.Tile
import de.bornim.core.WallKind
import de.bornim.core.World
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.min

/**
 * Bornim's houses seen diagonally (5.1, draft, only in the preview ISODINGE=dorf): a house stands on its
 * footprint of n tiles along the map's x (i, down right) and d tiles along its y (j, down left); its front
 * with the door faces +j (down left), its east side +i (down right), the roof's ridge runs along i, a gable
 * at either end. Timber frame and weathered plaster on a footing of field stones, thatch gone grey with moss
 * (or the temple's slate), a stone chimney where the hearth stands inside.
 * Same projection and heights as the rooms ([MapRoomIso]): 90 × 45 art pixels a tile, 57 to a metre upright.
 */
object MapTownIso {
    private const val TW = MapRoomIso.TW
    private const val TH = MapRoomIso.TH
    private const val ZS = MapRoomIso.ZS
    /** Upright drawing units per tile (a tile is 116 cm, 57 units to the metre). */
    private const val ZT = 66.0

    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0
    private fun frac(v: Double) = v - floor(v)
    private fun shade(c: Int, k: Double): Int {
        val r = ((c shr 16) and 0xFF) * k; val g = ((c shr 8) and 0xFF) * k; val b = (c and 0xFF) * k
        return (0xFF shl 24) or (r.toInt().coerceIn(0, 255) shl 16) or (g.toInt().coerceIn(0, 255) shl 8) or b.toInt().coerceIn(0, 255)
    }
    private fun vnoise(x: Double, y: Double, s: Int): Double {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        var u = x - ix; var v = y - iy
        u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    /** One of three looks of a plain house (the temple has its own). */
    class Look(
        val plaster: Int, val plasterDark: Int, val timber: Int, val thatch: Int, val moss: Double,
        /** the ground floor of field stone up to this height (0: only the footing) */
        val stoneTo: Double,
        /** the gables boarded instead of framed */
        val boards: Boolean,
    )
    val looks = listOf(
        Look(0x8C8270, 0x332D25, 0x3E2E22, 0x7A6C4E, 0.55, 0.0, false),
        Look(0x82745A, 0x2E271E, 0x2C2018, 0x6A5C42, 0.3, 0.0, true),
        Look(0x86807A, 0x302C28, 0x3A2C22, 0x5E5644, 0.75, 70.0, false),
    )

    /**
     * A house picture: [front] the wall along the front, one letter a tile ('#' wall, 'W' window, 'D' door); [side]
     * the east wall the same way; [d] tiles deep; [roof], [walls] and [feature] from the map's [HouseStyle];
     * [chimney] the middle of the chimney along i (null: none), standing at the back wall over the hearth inside;
     * [night] lit windows; [shut] (73a) a house one cannot enter but someone lives in: at night its shutters are
     * closed, the light only coming through the cracks. The ground under i = j = 0 lies at ([ox], [oy]) of the picture.
     */
    class Picture(val img: PixelImage, val ox: Double, val oy: Double, val chimneyTop: Triple<Double, Double, Double>? = null)

    fun house(
        front: String, side: String, d: Int, roof: RoofKind, walls: WallKind, feature: HouseFeature, seed: Int,
        chimney: Double? = null, night: Boolean = false, shut: Boolean = false,
    ): Picture {
        val n = front.length
        val lk = looks[Math.floorMod(seed, looks.size)]
        val temple = feature == HouseFeature.BELL_TOWER
        val thatch = roof == RoofKind.STRAW
        // D3.13: a herbalist's cot in the woods, low under a deep, steep thatch hanging far out
        val hut = feature == HouseFeature.HUT
        val sh = shape(d, roof, feature)
        val eave = sh.eave; val o = sh.overhang; val ridge = sh.ridge
        val run = d / 2.0 + o
        // the chimney at the back wall rises far enough to show a good part over the ridge
        val cjMid = 0.22
        val chimTop = ridge - (d / 2.0 - cjMid) * TH / 2 / ZS + 52
        val towerTop = ridge + 92
        // the picture: from the back corner (0, 0) at the top to the front corner (n, d) on the ground
        // 5.5: wide enough for the soft shadow down left too (it reaches 1.3 tiles past the front), else it ends in a
        // straight upright edge on the grass where the picture stops
        val left = d + 1.4; val right = n + o + 0.3
        val w = (floor((left + right) * TW / 2 / 4).toInt() + 2) * 4
        val topZ = maxOf(ridge, if (chimney != null) chimTop else 0.0, if (temple) towerTop + 50 else 0.0) + 8
        val h = ((n + d) * TH / 2 + topZ * ZS + 24).toInt() / 2 * 2
        val img = PixelImage(w, h)
        val ox = floor(left * TW / 2) + 2.5         // screen x of i = j = 0 (a half pixel, so strip middles are whole)
        val oy = h - 16 - (n + d) * TH / 2          // screen y of i = j = 0 on the ground
        fun sx(i: Double, j: Double) = ox + (i - j) * TW / 2
        fun sy(i: Double, j: Double, z: Double) = oy + (i + j) * TH / 2 - z * ZS

        /** Fills the plane through p0 spanned by a (u 0..1) and b (v 0..1), in (i, j, z), each pixel by [tex]. */
        fun plane(p0: DoubleArray, a: DoubleArray, b: DoubleArray, tex: (Double, Double) -> Int?) {
            val x0 = sx(p0[0], p0[1]); val y0 = sy(p0[0], p0[1], p0[2])
            val ax = (a[0] - a[1]) * TW / 2; val ay = (a[0] + a[1]) * TH / 2 - a[2] * ZS
            val bx = (b[0] - b[1]) * TW / 2; val by = (b[0] + b[1]) * TH / 2 - b[2] * ZS
            val det = ax * by - ay * bx
            if (abs(det) < 1e-6) return
            val xs = listOf(x0, x0 + ax, x0 + bx, x0 + ax + bx); val ys = listOf(y0, y0 + ay, y0 + by, y0 + ay + by)
            for (py in max(0, floor(ys.min()).toInt()) until min(h, ys.max().toInt() + 1))
                for (px in max(0, floor(xs.min()).toInt()) until min(w, xs.max().toInt() + 1)) {
                    val dx = px + 0.5 - x0; val dy = py + 0.5 - y0
                    val u = (dx * by - dy * bx) / det; val v = (ax * dy - ay * dx) / det
                    if (u < 0 || u > 1 || v < 0 || v > 1) continue
                    tex(u, v)?.let { img.set(px, py, it) }
                }
        }
        fun p(i: Double, j: Double, z: Double) = doubleArrayOf(i, j, z)


        // ---- the walls: the front (j = d, down left, in the house's own shade) and the east side (i = n, in the sun)
        val litFront = 0.72; val litSide = 1.0
        fun surface(u: Double, z: Double, face: Double, s: Int, top: Double): Int = when {
            temple -> ashlarTex(u, z, face, s)
            walls == WallKind.STONE -> stoneTex(u, z, face, s, top)
            walls == WallKind.PLANKS -> planksTex(u, z, face, s)
            else -> wallTex(u, z, face, s, lk, top)
        }
        fun wall(u: Double, z: Double, len: Int, letters: String, face: Double, s: Int): Int? {
            val tile = floor(u).toInt().coerceIn(0, len - 1); val f = u - tile
            val kind = letters.getOrElse(tile) { '#' }
            // the cot's door and windows lower, under its low eaves
            val zo = if (hut) z * 1.45 else z
            if (kind == 'D') (if (temple) archDoor(f, z, face, s) else door(f, zo, face, s))?.let { return it }
            if (kind == 'W') (if (temple) archWindow(f, z, face, night) else if (night && shut) shutWindow(f, zo, face, s + tile) else window(f, zo, face, night, s + tile))?.let { return it }
            return surface(u, z, face, s, eave)
        }
        plane(p(0.0, d.toDouble(), 0.0), p(n.toDouble(), 0.0, 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * n, v * eave, n, front, litFront, seed) }
        plane(p(n.toDouble(), 0.0, 0.0), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, eave)) { u, v -> wall(u * d, v * eave, d, side, litSide, seed + 31) }
        // the east gable: a triangle over the side wall, up to the ridge in the middle; boarded on plank and stone houses
        plane(p(n.toDouble(), 0.0, eave), p(0.0, d.toDouble(), 0.0), p(0.0, 0.0, ridge - eave)) { u, v ->
            val z = v * (ridge - eave)
            val half = 1 - z / (ridge - eave)
            if (abs(u - 0.5) > half * 0.5) null
            else if (temple) ashlarTex(u * d, eave + z, litSide, seed + 31)
            else if (lk.boards || walls != WallKind.TIMBER) boards(u * d, eave + z, litSide * 0.94, seed + 7, false)
            else wallTex(u * d, eave + z, litSide, seed + 31, lk, ridge)
        }

        // ---- the chimney at the back wall: rough stones, soot towards the top; the roof in front hides its foot
        if (chimney != null) {
            val ci0 = chimney - 0.19; val ci1 = chimney + 0.19
            val cj0 = cjMid - 0.19; val cj1 = cjMid + 0.19
            val zBase = eave - 10
            plane(p(ci0, cj1, zBase), p(ci1 - ci0, 0.0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (ci1 - ci0), zBase + v * (chimTop - zBase), litFront, seed + 41, chimTop), 0.8 - 0.3 * v) }
            plane(p(ci1, cj0, zBase), p(0.0, cj1 - cj0, 0.0), p(0.0, 0.0, chimTop - zBase)) { u, v -> shade(stoneTex(u * (cj1 - cj0) + 3, zBase + v * (chimTop - zBase), litSide, seed + 43, chimTop), 0.8 - 0.3 * v) }
            plane(p(ci0, cj0, chimTop), p(ci1 - ci0, 0.0, 0.0), p(0.0, cj1 - cj0, 0.0)) { u, v ->
                val rim = u < 0.18 || u > 0.82 || v < 0.18 || v > 0.82
                if (rim) shade(argb(0x5A544C), 0.85 + rnd(floor(u * 9).toInt(), floor(v * 9).toInt(), seed) * 0.2) else argb(0x0E0C0A)
            }
        }

        // ---- the roof: the slope towards us, from the ridge down to the eaves hanging over the front
        val ri0 = -o; val ri1 = n + o
        fun roofTex(u: Double, v: Double): Int {
            val along = u * (ri1 - ri0); val down = v * run
            return when (roof) {
                RoofKind.STRAW -> thatchTex(along, down, run, lk, seed)
                RoofKind.SHINGLE -> shingleTex(along, down, run, seed)
                RoofKind.RED -> clayTex(along, down, run, seed)
                RoofKind.BLUE -> slateTex(along, down, run, seed, 0x4E5A6E)
                RoofKind.SLATE -> slateTex(along, down, run, seed, 0x585C62)
            }
        }
        // the edge of the roof, thick thatch at the eaves and along the gable: a band under the slope
        val thick = if (hut) 20.0 else if (thatch) 16.0 else 5.0
        // ---- the cot's herbs (D3.13): bundles hung head down to dry under the eaves, along the front (the door kept
        // clear) and along the sunny side
        if (hut) {
            val herbs = intArrayOf(0x8A9A6A, 0x7A7238, 0x84709E, 0xB8AE8A, 0x9A5E34, 0x6C8448)
            /** One bundle hanging from [zTop] at (i, j), drawn in the plane along [ai], [aj]. */
            fun bundle(k: Int, i: Double, j: Double, ai: Double, aj: Double, zTop: Double, face: Double) {
                val col = argb(herbs[hash(k, seed, 71) % herbs.size])
                val len = 26.0 + rnd(k, 1, seed + 72) * 12
                val hw = 0.09 + rnd(k, 2, seed + 73) * 0.04
                val str = 4.0 + rnd(k, 5, seed + 79) * 6
                plane(p(i - ai * hw, j - aj * hw, zTop - str - len), p(ai * hw * 2, aj * hw * 2, 0.0), p(0.0, 0.0, len + str)) { u, v ->
                    val dz = (1 - v) * (len + str)                 // down from where it hangs
                    val c = abs(u - 0.5) * 2
                    when {
                        dz < str -> if (c < 0.08) argb(0x2A2016) else null
                        dz < str + 3 -> if (c < 0.24) shade(argb(0x5A4428), face) else null
                        else -> {
                            // tied stalks at the top, the heads spreading and hanging down, ragged at the tips
                            val t = (dz - str - 3) / len
                            val wv = 0.22 + 0.78 * Math.sin(Math.PI * min(1.0, t * 0.6 + 0.1))
                            if (c > wv * (0.8 + rnd(floor(u * 14).toInt(), floor(dz / 3).toInt(), seed + 75) * 0.25) || t > 0.98 - rnd(floor(u * 10).toInt(), 0, seed + 76) * 0.22) null
                            else shade(mix(argb(0x1A140C), col, (0.62 + (rnd(floor(u * 16).toInt(), floor(dz / 2).toInt(), seed + 77) - 0.5) * 0.5 - c * 0.25).coerceIn(0.0, 1.0)), face)
                        }
                    }
                }
            }
            val door = front.indexOf('D')
            var k = 0
            var hi = 0.2
            while (hi < n - 0.1) {
                if (door < 0 || floor(hi).toInt() != door) bundle(k, hi + (rnd(k, 3, seed + 74) - 0.5) * 0.06, d + o * 0.5, 1.0, 0.0, eave - thick + 4, litFront * 1.1)
                k++
                hi += 0.3 + rnd(k, 4, seed + 78) * 0.12
            }
            val sideDoor = side.indexOf('D')
            var hj = 0.3
            while (hj < d - 0.2) {
                if (sideDoor < 0 || floor(hj).toInt() != sideDoor) bundle(k, n + o * 0.45, hj, 0.0, 1.0, eave + 2, litSide * 0.95)
                k++
                hj += 0.34 + rnd(k, 4, seed + 78) * 0.12
            }
        }
        plane(p(ri0, d + o, eave - thick), p(ri1 - ri0, 0.0, 0.0), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * (ri1 - ri0), v, !thatch, lk, seed) }
        plane(p(ri1, d / 2.0, ridge - thick), p(0.0, run, eave - ridge), p(0.0, 0.0, thick)) { u, v -> edgeTex(u * run * 2, v, !thatch, lk, seed + 3) }
        plane(p(ri0, d / 2.0, ridge), p(ri1 - ri0, 0.0, 0.0), p(0.0, run, eave - ridge)) { u, v -> roofTex(u, v) }
        // the ridge itself: a rolled band of thatch (or ridge tiles) along the top
        plane(p(ri0 + 0.05, d / 2.0 - 0.06, ridge + 5), p(ri1 - ri0 - 0.1, 0.0, 0.0), p(0.0, 0.16, -10.0)) { u, v ->
            val t = 0.5 + 0.3 * (1 - v) + (rnd(floor(u * 60).toInt(), 0, seed + 9) - 0.5) * 0.15
            when (roof) {
                RoofKind.STRAW -> shade(mix(argb(0x2A2418), argb(lk.thatch), t), 0.9)
                RoofKind.RED -> shade(argb(0x4A2A1E), 0.8 + t * 0.4)
                RoofKind.SHINGLE -> shade(argb(0x3A3028), 0.8 + t * 0.4)
                else -> shade(argb(0x2A2E34), 0.8 + t * 0.4)
            }
        }

        // ---- the temple's bell tower (5g): a square stone tower rising over the east end, a belfry, a pointed cap
        if (temple) {
            // 269 (Chef, Build 51): half a tile in from the east end, so it stands on the ridge and the gable's edge does not cut its foot
            val ti0 = n + sh.towerI!! - 0.525; val ti1 = n + sh.towerI + 0.525; val tj0 = d / 2.0 - 0.52; val tj1 = d / 2.0 + 0.52
            fun roofZ(j: Double) = ridge - abs(j - d / 2.0) / run * (ridge - eave)
            // 269 (Chef 21.10.: "rechte hintere Kante hängt in der Luft"): behind the ridge the east wall is hidden by
            // the ridge in front of it (the slope is steeper than the view), so its foot follows the ridge on screen
            fun footZ(j: Double) = if (j >= d / 2.0) roofZ(j) else maxOf(roofZ(j), ridge - (d / 2.0 - j) * TH / ZS)
            fun belfry(u: Double, z: Double): Boolean {
                val c = abs(u - 0.5)
                return c < 0.24 && z > towerTop - 58 && z < towerTop - 22 + 9 * Math.sqrt((1 - (c / 0.24) * (c / 0.24)).coerceAtLeast(0.0))
            }
            val z0 = roofZ(tj1) - 6
            plane(p(ti0, tj1, z0), p(ti1 - ti0, 0.0, 0.0), p(0.0, 0.0, towerTop - z0)) { u, v ->
                val z = z0 + v * (towerTop - z0)
                if (belfry(u, z)) { if (abs(u - 0.5) < 0.1 && z > towerTop - 48 && z < towerTop - 28) shade(argb(0x5A4A2E), 0.6 + (z - towerTop + 48) / 50) else argb(0x0C0A0A) }
                else ashlarTex(u * (ti1 - ti0), z, litFront, seed + 51)
            }
            plane(p(ti1, tj0, z0 - 40), p(0.0, tj1 - tj0, 0.0), p(0.0, 0.0, towerTop - z0 + 40)) { u, v ->
                val z = z0 - 40 + v * (towerTop - z0 + 40)
                if (z < footZ(tj0 + u * (tj1 - tj0)) + (if (u > 0.5) 4 else 0)) null
                else if (belfry(u, z)) argb(0x0C0A0A)
                else ashlarTex(u * (tj1 - tj0) + 2, z, litSide, seed + 53)
            }
            // a cornice, then the pointed cap of slate
            val ci0 = ti0 - 0.06; val ci1 = ti1 + 0.06; val cj0 = tj0 - 0.06; val cj1 = tj1 + 0.06
            plane(p(ci0, cj1, towerTop - 4), p(ci1 - ci0, 0.0, 0.0), p(0.0, 0.0, 6.0)) { _, _ -> shade(argb(0x5A564E), 0.7) }
            plane(p(ci1, cj0, towerTop - 4), p(0.0, cj1 - cj0, 0.0), p(0.0, 0.0, 6.0)) { _, _ -> shade(argb(0x5A564E), 0.95) }
            val capH = 50.0
            // 269 (Chef, Build 51: "Turm wirkt falsch"): both faces rise to the one point over the middle of the tower
            plane(p(ci0, cj1, towerTop + 2), p(ci1 - ci0, 0.0, 0.0), p(0.0, -(cj1 - cj0) / 2, capH)) { u, v ->
                if (abs(u - 0.5) > 0.5 * (1 - v)) null else slateTex(u * 1.2, v * 0.8, 0.8, seed + 55, 0x585C62).let { shade(it, 0.75) }
            }
            plane(p(ci1, cj1, towerTop + 2), p(0.0, -(cj1 - cj0), 0.0), p(-(ci1 - ci0) / 2, 0.0, capH)) { u, v ->
                if (abs(u - 0.5) > 0.5 * (1 - v)) null else slateTex(u * 1.2, v * 0.8, 0.8, seed + 57, 0x585C62)
            }
        }

        // ---- the shop's awning: dull striped cloth on two poles over the front, its hem ragged
        if (feature == HouseFeature.AWNING) {
            val a0 = 0.15; val a1 = n - 0.15; val out = 0.7
            plane(p(a0, d.toDouble(), 128.0), p(a1 - a0, 0.0, 0.0), p(0.0, out, -26.0)) { u, v ->
                val stripe = floor(u * (a1 - a0) * 4).toInt() % 2 == 0
                val c = if (stripe) argb(0x5A3A2A) else argb(0x7A6E58)
                shade(mix(c, argb(0x1A140E), 0.15 + (rnd(floor(u * 80).toInt(), floor(v * 10).toInt(), seed + 61) - 0.5) * 0.2), 0.8 + 0.25 * v)
            }
            plane(p(a0, d + out, 102.0), p(a1 - a0, 0.0, 0.0), p(0.0, 0.0, 12.0)) { u, v ->
                if (v < 0.35 * rnd(floor(u * 40).toInt(), 1, seed + 62) || (u * (a1 - a0) * 8) % 1.0 < 0.08 && v < 0.5) null
                else shade(if (floor(u * (a1 - a0) * 4).toInt() % 2 == 0) argb(0x4A3022) else argb(0x665C4A), 0.7)
            }
            for (pi in listOf(a0 + 0.05, a1 - 0.05)) plane(p(pi - 0.03, d + out, 0.0), p(0.06, 0.0, 0.0), p(0.0, 0.0, 102.0)) { _, v -> shade(argb(0x2E2218), 0.7 + v * 0.3) }
        }

        // ---- the inn's sign: an iron bracket out of the front wall, a board hanging from it
        if (feature == HouseFeature.INN_SIGN) {
            val door = front.indexOf('D').coerceAtLeast(0)
            val si = door + 1.15
            plane(p(si, d.toDouble(), 128.0), p(0.0, 0.62, 0.0), p(0.0, 0.0, 3.0)) { _, _ -> argb(0x1E1C1A) }
            plane(p(si, d + 0.12, 100.0), p(0.0, 0.42, 0.0), p(0.0, 0.0, 24.0)) { u, v ->
                val edge = u < 0.06 || u > 0.94 || v < 0.1 || v > 0.9
                // a tankard burnt into the board
                val mug = abs(u - 0.45) < 0.14 && v in 0.25..0.75 || (abs(u - 0.66) < 0.06 && v in 0.35..0.6)
                if (edge) argb(0x2A1E14) else if (mug) argb(0x1A120C) else shade(argb(0x5A4430), 0.85 + rnd(floor(u * 20).toInt(), floor(v * 6).toInt(), seed + 63) * 0.2)
            }
        }
        return Picture(img, ox, oy, chimney?.let { Triple(it, cjMid, chimTop) })
    }

    // ------------------------------------------------------------------ textures

    /** Timber frame and weathered plaster, a footing of field stone (or a ground floor of it, [Look.stoneTo]). */
    private fun wallTex(u: Double, z: Double, face: Double, seed: Int, lk: Look, top: Double): Int {
        val footing = max(16.0, lk.stoneTo)
        if (z < footing) return stoneTex(u, z, face, seed, footing)
        // posts at every tile's edge and in its middle, a rail at the sill, braces in every other panel
        val pu = u * 2
        val post = abs(pu - Math.round(pu)) * 2 < 0.07
        val sill = z < footing + 6
        val rail = abs(z - 92) < 3.5
        val plate = z > 142 && z < 150
        val panel = floor(pu).toInt()
        val f = frac(pu)
        val braceUp = hash(panel, seed, 7) % 3
        val zz = (z - footing) / (92 - footing)
        val brace = braceUp != 0 && z < 92 && abs((if (braceUp == 1) f else 1 - f) - zz * 0.9 - 0.05) < 0.045
        if (post || sill || rail || plate || brace) {
            var v = 0.5 + (rnd(floor(u * 30).toInt(), floor(z / 3).toInt(), seed) - 0.5) * 0.35
            if (rail && z > 93 || plate && z > 148) v += 0.3
            return shade(mix(argb(0x150F0B), argb(lk.timber), v.coerceIn(0.0, 1.4)), face)
        }
        var v = 0.62 + (vnoise(u * 9, z / 9, seed + 1) - 0.5) * 0.28 + (rnd(floor(u * 50).toInt(), floor(z / 2).toInt(), seed + 2) - 0.5) * 0.08
        // rain runs down from the eaves, damp creeps up from the ground
        v -= 0.2 * vnoise(u * 14, 0.0, seed + 3) * ((z - 100) / 50).coerceIn(0.0, 1.0)
        v -= 0.25 * exp(-(z - footing) / 12)
        // the plaster has fallen off here and there, the wattle shows
        if (hash(panel, floor(z / 46).toInt(), seed + 4) % 5 == 0 && vnoise(u * 8, z / 7, seed + 5) > 0.68)
            return shade(if ((floor(z / 3).toInt() + floor(u * 24).toInt()) % 2 == 0) argb(0x4A3A28) else argb(0x2E2418), face)
        return shade(mix(argb(lk.plasterDark), argb(lk.plaster), v.coerceIn(0.0, 1.0)), face)
    }

    /** Field stones laid in rough courses, mortar dark in the joints, moss low down. */
    private fun stoneTex(u: Double, z: Double, face: Double, seed: Int, top: Double): Int {
        val course = floor(z / 9).toInt()
        val off = rnd(course, 1, seed) * 0.4
        val bw = 0.16 + rnd(course, 2, seed) * 0.08
        val block = floor(u / bw + off).toInt()
        var v = 0.5 + (rnd(block, course, seed + 3) - 0.5) * 0.4 + (rnd(floor(u * 60).toInt(), floor(z / 2).toInt(), seed + 4) - 0.5) * 0.1
        val jz = z % 9; val ju = frac(u / bw + off)
        if (jz < 1.4 || ju < 0.07) v -= 0.32
        else v += (1 - jz / 9) * 0.12           // the top of each stone catches light
        if (z > top - 2) v += 0.12
        val c = mix(argb(0x201E1A), argb(0x8A8478), v.coerceIn(0.0, 1.0))
        val moss = z < 10 && vnoise(u * 10, z / 4, seed + 5) > 0.55
        return shade(if (moss) mix(c, argb(0x3E4A26), 0.55) else c, face)
    }

    /** Dressed grey stone of the temple, larger blocks, soot and damp. */
    private fun ashlarTex(u: Double, z: Double, face: Double, seed: Int): Int {
        val course = floor(z / 13).toInt()
        val off = rnd(course, 3, seed) * 0.5
        val bw = 0.34 + rnd(course, 4, seed) * 0.1
        val block = floor(u / bw + off).toInt()
        var v = 0.5 + (rnd(block, course, seed + 11) - 0.5) * 0.22 + (rnd(floor(u * 50).toInt(), floor(z / 2).toInt(), seed + 12) - 0.5) * 0.08
        if (z % 13 < 1.5 || frac(u / bw + off) < 0.04) v -= 0.3
        v -= 0.2 * exp(-z / 14)
        v -= 0.15 * vnoise(u * 10, 0.0, seed + 13) * ((z - 90) / 60).coerceIn(0.0, 1.0)
        return shade(mix(argb(0x1E1C1A), argb(0x7E7A72), v.coerceIn(0.0, 1.0)), face)
    }

    /** The temple's tall window under a round arch: deep reveal, leaded panes; at night candlelight. */
    private fun archWindow(f: Double, z: Double, face: Double, night: Boolean): Int? {
        val r = 0.16; val spring = 104.0
        if (f < 0.5 - r || f > 0.5 + r || z < 46) return null
        val top = spring + 22 * Math.sqrt((1 - ((f - 0.5) / r).let { it * it }).coerceAtLeast(0.0))
        if (z > top) return null
        val inner = abs(f - 0.5) < r - 0.04 && z > 51 && z < top - 5
        if (!inner) return shade(argb(0x18161A), face)
        // the lead in diamonds big enough to read on the phone (test of 5.4: at night the fine lattice was a speckle);
        // at night each pane a little different, brightest low in the middle where the candles stand
        val a = (f - 0.5) * 9; val b = (z - 90) / 22
        if (abs(frac(a + b) - 0.5) > 0.45 || abs(frac(a - b) - 0.5) > 0.45) return argb(0x16161A)
        val pane = hash(floor(a + b).toInt(), floor(a - b).toInt(), 71) % 100 / 100.0
        return if (night) mix(argb(0x7A4418), argb(0xF0B868), (0.95 - abs(f - 0.5) / r * 0.35 - (z - 51) / 300 + (pane - 0.5) * 0.2).coerceIn(0.0, 1.0))
        else mix(argb(0x1A2028), argb(0x4A5666), ((z - 51) / 90).coerceIn(0.0, 1.0) * 0.7)
    }

    /** The temple's door: two leaves of dark oak under a round arch of stone. */
    private fun archDoor(f: Double, z: Double, face: Double, seed: Int): Int? {
        val r = 0.3
        if (abs(f - 0.5) > r || z > 128) return null
        val top = 92 + 34 * Math.sqrt((1 - ((f - 0.5) / r).let { it * it }).coerceAtLeast(0.0))
        if (z > top) return null
        if (z > top - 8 || abs(f - 0.5) > r - 0.05) return shade(argb(0x4A4640), face * (0.8 + rnd(floor(f * 14).toInt(), floor(z / 8).toInt(), seed) * 0.3))
        if (abs(f - 0.5) < 0.012) return shade(argb(0x0E0A08), face)
        val plank = floor(f * 20).toInt()
        var v = 0.45 + (rnd(plank, 0, seed + 1) - 0.5) * 0.25
        if (frac(f * 20) < 0.12) v -= 0.25
        if (abs(z - 34) < 2.5 || abs(z - 92) < 2.5) return shade(argb(0x24201C), face)
        return shade(mix(argb(0x120C08), argb(0x4A3426), v.coerceIn(0.0, 1.0)), face * 0.9)
    }

    /** Weathered boards on the gable (or the temple's stone gable). */
    private fun boards(u: Double, z: Double, face: Double, seed: Int, stone: Boolean): Int {
        if (stone) return ashlarTex(u, z, face, seed)
        val b = floor(u * 7).toInt()
        var v = 0.45 + (rnd(b, 0, seed) - 0.5) * 0.3 + (rnd(b, floor(z / 3).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(u * 7) < 0.12) v -= 0.3
        return shade(mix(argb(0x1A140E), argb(0x5E4A38), v.coerceIn(0.0, 1.0)), face)
    }

    /** A small window: deep reveal, a cross of wood, shutters folded back; at night warm light inside. */
    private fun window(f: Double, z: Double, face: Double, night: Boolean, seed: Int): Int? {
        if (z < 56 || z > 112 || f < 0.16 || f > 0.84) return null
        val shutter = f < 0.27 || f > 0.73
        if (shutter) {
            val v = 0.42 + (if (frac(f * 30) < 0.15) -0.2 else 0.0) + (rnd(floor(f * 30).toInt(), 0, seed) - 0.5) * 0.15
            return shade(mix(argb(0x14100C), argb(0x5A4636), v), face)
        }
        val frame = f < 0.31 || f > 0.69 || z < 61 || z > 107
        if (frame) return shade(if (z > 105 || f < 0.3) argb(0x18120E) else argb(0x3A2C20), face)
        if (abs(f - 0.5) < 0.018 || abs(z - 84) < 1.6) return shade(argb(0x2A2018), face)
        if (night) {
            val t = 0.7 + vnoise(f * 12, z / 6, seed) * 0.3
            return mix(argb(0x6A3A14), argb(0xF0B060), t)
        }
        // by day the glass is dark, with a little sky in its upper panes
        val t = ((z - 61) / 46).coerceIn(0.0, 1.0)
        return mix(argb(0x14181C), argb(0x4A5866), t * 0.6)
    }

    /**
     * A window with its shutters closed for the night (73a): two leaves of planks meeting in the middle, the light of
     * the room inside showing only through the gap between them, the joints of the planks and around the edges.
     */
    private fun shutWindow(f: Double, z: Double, face: Double, seed: Int): Int? {
        if (z < 56 || z > 112 || f < 0.16 || f > 0.84) return null
        if (f < 0.2 || f > 0.8 || z < 59 || z > 109) return shade(if (z > 105) argb(0x18120E) else argb(0x3A2C20), face)
        val warm = { k: Double -> mix(argb(0x5A3010), argb(0xE8A050), (k * (0.75 + vnoise(f * 10, z / 5, seed) * 0.25)).coerceIn(0.0, 1.0)) }
        // the frame's edge, a thin line where the leaves do not quite close against it, brighter towards the bottom
        if (f < 0.215 || f > 0.785 || z < 60.5 || z > 107.5) return if ((z < 62 || abs(f - 0.5) < 0.2) && rnd(floor(z / 3).toInt(), floor(f * 9).toInt(), seed) > 0.6) warm(0.5) else shade(argb(0x241A12), face)
        // the gap between the two leaves
        if (abs(f - 0.5) < 0.014) return warm(0.95)
        // planks: four to a leaf, their joints let a little through here and there
        val leaf = if (f < 0.5) (f - 0.215) / 0.285 else (f - 0.5) / 0.285
        val k = floor(leaf * 4).toInt() + if (f < 0.5) 0 else 4
        val joint = frac(leaf * 4) < 0.07
        if (joint && rnd(k, floor(z / 4).toInt(), seed + 3) > 0.8) return warm(0.6)
        // a knot hole or two
        if (rnd(k, floor(z / 4).toInt(), seed + 5) > 0.985) return warm(0.8)
        val brace = abs(z - 70) < 1.8 || abs(z - 98) < 1.8
        var v = 0.38 + (rnd(k, 0, seed) - 0.5) * 0.18 + (vnoise(f * 40, z / 9, seed + 7) - 0.5) * 0.1
        if (joint) v -= 0.18
        if (brace) v += 0.08
        return shade(mix(argb(0x120E0A), argb(0x4E3C2E), v.coerceIn(0.0, 1.0)), face)
    }

    /** A heavy plank door under a lintel, iron straps, a worn step in front. */
    private fun door(f: Double, z: Double, face: Double, seed: Int): Int? {
        if (f < 0.24 || f > 0.76 || z > 118) return null
        val lintel = z > 110
        val jamb = f < 0.29 || f > 0.71
        if (lintel || jamb) return shade(mix(argb(0x150F0B), argb(0x46342A), 0.4 + rnd(floor(f * 20).toInt(), floor(z / 4).toInt(), seed) * 0.3), face)
        val plank = floor((f - 0.29) / 0.42 * 5).toInt()
        var v = 0.5 + (rnd(plank, 0, seed + 1) - 0.5) * 0.3 + (rnd(plank, floor(z / 2).toInt(), seed + 2) - 0.5) * 0.1
        if (frac((f - 0.29) / 0.42 * 5) < 0.1) v -= 0.3
        val strap = abs(z - 30) < 2.5 || abs(z - 86) < 2.5
        if (strap) return shade(argb(0x26221E), face * (0.9 + rnd(floor(f * 40).toInt(), 0, seed) * 0.2))
        if (abs(f - 0.64) < 0.02 && abs(z - 58) < 3) return shade(argb(0x6A6050), face)
        return shade(mix(argb(0x150F0B), argb(0x5A4232), v.coerceIn(0.0, 1.0)), face * (1 - 0.25 * (z / 118)))
    }

    /** Old thatch: bundles of reed in wavy courses down the slope, grey on top, moss in the hollows, a darker eave line. */
    private fun thatchTex(along: Double, down: Double, run: Double, lk: Look, seed: Int): Int {
        // courses about every 0.3 tiles down, their edges wavy where the bundles were tied
        val wave = (vnoise(along * 3.0, 0.0, seed + 6) - 0.5) * 0.12 + (vnoise(along * 11.0, 0.0, seed + 7) - 0.5) * 0.05
        val dd = down + wave
        val course = floor(dd / 0.3).toInt()
        val fc = frac(dd / 0.3)
        // single stalks: thin streaks down the slope, each its own shade
        val sx = along * 46 + rnd(course, 0, seed) * 7
        val stalk = rnd(floor(sx).toInt(), course, seed + 1)
        val streak = vnoise(sx * 0.5, dd * 9, seed + 8)
        var v = 0.46 + (stalk - 0.5) * 0.34 + (streak - 0.5) * 0.25 - fc * 0.16
        // the slope weathered grey towards the ridge, browner and wetter at the eaves
        v += (vnoise(along * 1.4, down * 1.8, seed + 2) - 0.5) * 0.2
        var c = mix(argb(0x17130D), argb(lk.thatch), v.coerceIn(0.0, 1.0))
        c = mix(c, argb(0x6A665C), 0.25 * (1 - down / run))
        // moss: fine clumps where the courses lie in shadow and on the lower, wetter half
        val m1 = vnoise(along * 4.0, down * 5.0, seed + 4); val m2 = rnd(floor(along * 30).toInt(), floor(down * 30).toInt(), seed + 5)
        val mossy = m1 * (0.55 + 0.7 * down / run) + (m2 - 0.5) * 0.35 + (1 - fc) * 0.1
        if (mossy > 1.15 - lk.moss * 0.4) c = mix(c, if (m2 > 0.6) argb(0x56602E) else argb(0x323E1C), 0.6)
        // shadow just under each course's edge, and the eave darker where the rain drips
        if (fc > 0.9) c = shade(c, 0.8)
        if (down > run - 0.1) c = shade(c, 0.78)
        return shade(c, 0.9)
    }

    /** Slate, small grey plates in rows, a few cracked or slipped. */
    private fun slateTex(along: Double, down: Double, run: Double, seed: Int, rgb: Int = 0x585C62): Int {
        val row = floor(down / 0.16).toInt()
        val off = if (row % 2 == 0) 0.0 else 0.5
        val col = floor(along / 0.2 + off).toInt()
        var v = 0.5 + (rnd(col, row, seed) - 0.5) * 0.25 + (rnd(floor(along * 60).toInt(), floor(down * 60).toInt(), seed + 1) - 0.5) * 0.08
        if (frac(down / 0.16) > 0.86) v -= 0.3
        if (frac(along / 0.2 + off) < 0.06) v -= 0.22
        if (hash(col, row, seed + 2) % 23 == 0) v -= 0.25
        val lichen = vnoise(along * 3, down * 3, seed + 3) * 0.7 + rnd(floor(along * 45).toInt(), floor(down * 45).toInt(), seed + 4) * 0.5 > 0.95
        val c = mix(argb(0x141618), argb(rgb), v.coerceIn(0.0, 1.0))
        return if (lichen) mix(c, argb(0x7A7A5A), 0.4) else c
    }

    /** Wooden shingles, grey and split, in short overlapping rows, here and there one missing. */
    private fun shingleTex(along: Double, down: Double, run: Double, seed: Int): Int {
        val row = floor(down / 0.12).toInt()
        val off = rnd(row, 0, seed) * 0.3
        val col = floor(along / 0.11 + off).toInt()
        var v = 0.48 + (rnd(col, row, seed + 1) - 0.5) * 0.3 + (rnd(floor(along * 70).toInt(), floor(down * 30).toInt(), seed + 2) - 0.5) * 0.12
        if (frac(down / 0.12) > 0.82) v -= 0.3
        if (frac(along / 0.11 + off) < 0.08) v -= 0.25
        if (hash(col, row, seed + 3) % 31 == 0) v -= 0.35
        var c = mix(argb(0x16120E), argb(0x6A5E50), v.coerceIn(0.0, 1.0))
        if (vnoise(along * 3, down * 4, seed + 4) * (0.6 + 0.6 * down / run) > 0.8) c = mix(c, argb(0x3A4622), 0.45)
        return c
    }

    /** Old clay tiles, dark red-brown and dulled by soot and lichen, in rounded rows. */
    private fun clayTex(along: Double, down: Double, run: Double, seed: Int): Int {
        val row = floor(down / 0.14).toInt()
        val col = floor(along / 0.14).toInt()
        val fu = frac(along / 0.14)
        var v = 0.5 + (rnd(col, row, seed) - 0.5) * 0.25 + (0.5 - abs(fu - 0.5)) * 0.35 - 0.12
        if (frac(down / 0.14) > 0.84) v -= 0.3
        if (fu < 0.06) v -= 0.25
        val c = mix(argb(0x1E100C), argb(0x7A4A36), v.coerceIn(0.0, 1.0))
        val lichen = vnoise(along * 3, down * 3, seed + 3) * 0.7 + rnd(floor(along * 45).toInt(), floor(down * 45).toInt(), seed + 4) * 0.5 > 0.98
        return if (lichen) mix(c, argb(0x6E6A4A), 0.4) else c
    }

    /** Walls of vertical planks, tarred dark at the foot, a footing of stones. */
    private fun planksTex(u: Double, z: Double, face: Double, seed: Int): Int {
        if (z < 16) return stoneTex(u, z, face, seed, 16.0)
        val b = floor(u * 6).toInt()
        var v = 0.45 + (rnd(b, 0, seed) - 0.5) * 0.25 + (rnd(b, floor(z / 3).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(u * 6) < 0.1) v -= 0.3
        if (abs(z - 92) < 3) v += 0.1
        v -= 0.25 * exp(-(z - 16) / 14)
        return shade(mix(argb(0x14100C), argb(0x5E4C3A), v.coerceIn(0.0, 1.0)), face)
    }

    /** The cut edge of the thatch (or slate): ragged stalk ends in shadow. */
    private fun edgeTex(u: Double, v: Double, slate: Boolean, lk: Look, seed: Int): Int? {
        if (slate) return shade(argb(0x22262C), 0.8 + v * 0.3)
        // the stalk ends hang ragged under the edge
        val ragged = rnd(floor(u * 40).toInt(), 0, seed) * 0.35
        if (v < ragged) return null
        val t = 0.25 + (rnd(floor(u * 50).toInt(), floor(v * 6).toInt(), seed + 1) - 0.5) * 0.25 + v * 0.25
        return mix(argb(0x14100A), argb(lk.thatch), t.coerceIn(0.0, 1.0))
    }

    // ------------------------------------------------------------------ small things standing on one tile (5.2)

    /**
     * A picture of one tile's thing: the tile's front corner lies on the middle of the bottom edge; local
     * coordinates run from (−1, −1) at the tile's back corner to (0, 0) at its front corner, as in [MapRoomIso].
     */
    private class Tile1(val h: Int, val w: Int = 100) {
        val img = PixelImage(w, h)
        fun sx(i: Double, j: Double) = w / 2.0 + (i - j) * TW / 2
        fun sy(i: Double, j: Double, z: Double) = h + (i + j) * TH / 2 - z * ZS
        fun plane(p0: DoubleArray, a: DoubleArray, b: DoubleArray, tex: (Double, Double) -> Int?) {
            val x0 = sx(p0[0], p0[1]); val y0 = sy(p0[0], p0[1], p0[2])
            val ax = (a[0] - a[1]) * TW / 2; val ay = (a[0] + a[1]) * TH / 2 - a[2] * ZS
            val bx = (b[0] - b[1]) * TW / 2; val by = (b[0] + b[1]) * TH / 2 - b[2] * ZS
            val det = ax * by - ay * bx
            if (abs(det) < 1e-6) return
            val xs = listOf(x0, x0 + ax, x0 + bx, x0 + ax + bx); val ys = listOf(y0, y0 + ay, y0 + by, y0 + ay + by)
            for (py in max(0, floor(ys.min()).toInt()) until min(h, ys.max().toInt() + 1))
                for (px in max(0, floor(xs.min()).toInt()) until min(w, xs.max().toInt() + 1)) {
                    val dx = px + 0.5 - x0; val dy = py + 0.5 - y0
                    val u = (dx * by - dy * bx) / det; val v = (ax * dy - ay * dx) / det
                    if (u < 0 || u > 1 || v < 0 || v > 1) continue
                    tex(u, v)?.let { img.set(px, py, it) }
                }
        }
        /** A box: its faces towards +j (down left, in shade), +i (down right, lit) and its top. */
        fun box(i0: Double, j0: Double, i1: Double, j1: Double, z0: Double, z1: Double, tex: (face: Int, u: Double, v: Double) -> Int?) {
            plane(doubleArrayOf(i0, j1, z0), doubleArrayOf(i1 - i0, 0.0, 0.0), doubleArrayOf(0.0, 0.0, z1 - z0)) { u, v -> tex(0, u, v) }
            plane(doubleArrayOf(i1, j0, z0), doubleArrayOf(0.0, j1 - j0, 0.0), doubleArrayOf(0.0, 0.0, z1 - z0)) { u, v -> tex(1, u, v) }
            plane(doubleArrayOf(i0, j0, z1), doubleArrayOf(i1 - i0, 0.0, 0.0), doubleArrayOf(0.0, j1 - j0, 0.0)) { u, v -> tex(2, u, v) }
        }
        fun shadow(ci: Double, cj: Double, r: Double, a: Double = 0.45) {
            for (py in 0 until h) for (px in 0 until w) {
                val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h) / (TH / 2)
                val i = (aa + bb) / 2; val j = (bb - aa) / 2
                val d = Math.hypot(i - ci, j - cj) / r
                if (d >= 1) continue
                img.set(px, py, (((1 - d) * a * 255).toInt() shl 24) or 0x0A0806)
            }
        }
    }

    /** Weathered wood: [face] 0 shade, 1 lit, 2 top; [u] along the grain. */
    private fun wood(face: Int, u: Double, v: Double, seed: Int, rgb: Int = 0x5A4430): Int {
        val k = when (face) { 0 -> 0.62; 1 -> 0.95; else -> 1.05 }
        var t = 0.5 + (rnd(floor(v * 7).toInt(), floor(u * 18).toInt(), seed) - 0.5) * 0.25 + (rnd(floor(u * 60).toInt(), floor(v * 40).toInt(), seed + 1) - 0.5) * 0.12
        if (frac(v * 7) < 0.1) t -= 0.25
        return shade(mix(argb(0x140E0A), argb(rgb), t.coerceIn(0.0, 1.0)), k)
    }

    /**
     * A signpost (5.2): a weathered board on its post(s), facing the way along the map's y (seen from the front and
     * from the right), letters burnt into it as dark strokes. Three looks: one post, two posts, an arrow board.
     */
    fun signpost(v: Int, seed: Int): PixelImage {
        val c = Tile1(150)
        val j0 = -0.42; val j1 = -0.36
        // D3.7: a fourth look for the woods, a short board low on a post off its middle, as if it had sagged
        val (i0, i1) = when (v) { 1 -> -0.86 to -0.14; 3 -> -0.8 to -0.34; else -> -0.82 to -0.18 }
        val z0 = when (v) { 1 -> 54.0; 3 -> 46.0; else -> 70.0 }; val z1 = z0 + (if (v == 3) 26 else 30)
        fun post(i: Double, top: Double) = c.box(i - 0.04, j0 - 0.07, i + 0.04, j0 + 0.0, 0.0, top) { f, u, w -> wood(f, w, u, seed + 3, 0x4A3828) }
        when (v) {
            1 -> { post(i0 + 0.05, z1 + 2); post(i1 - 0.05, z1 + 2) }
            3 -> post(-0.68, z1 + 6)
            else -> post(-0.5, z1 + 10)
        }
        // the board: an arrow points along +i on the third look
        c.box(i0, j0, i1, j1, z0, z1) { f, u, w ->
            if (v == 2 && f != 1) {
                val tip = (u - 0.82) / 0.18
                if (tip > 0 && abs(w - 0.5) > 0.5 * (1 - tip)) return@box null
            }
            if (f == 0) {
                // burnt letters: two rows of short strokes
                val row = if (abs(w - 0.68) < 0.08) 0 else if (abs(w - 0.36) < 0.08) 1 else -1
                if (row >= 0 && u in 0.12..(if (v == 2) 0.74 else 0.88) && hash(floor(u * 26).toInt(), row, seed + 5) % 4 != 0 && frac(u * 26) < 0.7)
                    return@box argb(0x150E0A)
            }
            wood(f, u, w, seed + 7)
        }
        return c.img
    }

    /**
     * The notice board before the inn (29): a broad board of planks on two posts under a little roof of shingles,
     * notes of pale parchment nailed to it, dark lines of writing on each. Three looks: a gabled roof and fresh notes,
     * a flat roof and a dark stain, no roof and notes half torn away by the wind. Faces the way along the map's y.
     * [fresh] (29.3): a new note not yet read, pale and clean, nailed over the old ones, the only hint there is one.
     */
    fun noticeBoard(v: Int, seed: Int, fresh: Boolean = false): PixelImage {
        val c = Tile1(220)
        val j0 = -0.44; val j1 = -0.38
        val i0 = -0.94; val i1 = -0.06
        val z0 = 52.0; val z1 = 118.0
        val top = if (v == 2) z1 + 6 else 146.0
        for (pi in listOf(i0 + 0.06, i1 - 0.06))
            c.box(pi - 0.035, j0 - 0.05, pi + 0.035, j0 + 0.0, 0.0, top) { f, u, w -> wood(f, w, u, seed + 3, 0x3E2E22) }
        // the notes: where each lies on the board's face (u along it, w up it), torn ones keep only their top
        data class Note(val u0: Double, val u1: Double, val w0: Double, val w1: Double, val torn: Boolean, val tone: Int)
        val notes = (0 until 6).map { k ->
            val u = 0.08 + (k % 3) * 0.29 + (rnd(k, 1, seed) - 0.5) * 0.06
            val w = if (k < 3) 0.52 else 0.1
            val wide = 0.17 + rnd(k, 2, seed) * 0.06; val tall = 0.3 + rnd(k, 3, seed) * 0.08
            Note(u, u + wide, w + (rnd(k, 4, seed) - 0.5) * 0.06, w + tall, v == 2 && hash(k, 5, seed) % 2 == 0, hash(k, 6, seed) % 3)
        }.filter { v != 1 || it.u0 > 0.3 || it.w0 < 0.4 } +
            // the fresh one last, so it lies on top: a little tilted out of line, in the middle of the board
            (if (fresh) listOf(Note(0.34, 0.62, 0.26, 0.78, false, 3)) else emptyList())
        c.box(i0, j0, i1, j1, z0, z1) { f, u, w ->
            if (f == 0) for (n in notes.asReversed()) {
                if (u !in n.u0..n.u1 || w !in n.w0..n.w1) continue
                val nu = (u - n.u0) / (n.u1 - n.u0); val nw = (w - n.w0) / (n.w1 - n.w0)
                // torn: the lower part gone in a ragged edge
                if (n.torn && nw < 0.45 + 0.25 * rnd(floor(nu * 14).toInt(), 7, seed)) continue
                // the nail at the top; the fresh note sealed with a blob of dark red wax instead
                if (n.tone == 3 && abs(nu - 0.5) < 0.14 && nw > 0.8) return@box shade(argb(0x7A1E16), 0.95)
                if (abs(nu - 0.5) < 0.06 && nw > 0.86) return@box argb(0x1A1614)
                // lines of writing, short dark strokes
                if (nw in 0.12..0.78 && nu in 0.12..0.88 && frac(nw * 7) < 0.32 && hash(floor(nu * 16).toInt(), floor(nw * 7).toInt(), seed + 9) % 5 != 0)
                    return@box argb(0x2A2018)
                val paper = when (n.tone) { 0 -> 0xA89C7E; 1 -> 0x988A6A; 2 -> 0x8A7E62; else -> 0xE4DCC2 }
                return@box shade(mix(argb(paper), argb(0x3A2E22), (1 - nw) * 0.25 + rnd(floor(nu * 30).toInt(), floor(nw * 30).toInt(), seed + 8) * 0.12), 0.9)
            }
            // a dark stain running down the planks on the second look
            if (v == 1 && f == 0 && abs(u - 0.2 - (1 - w) * 0.05) < 0.05 * (0.4 + w) && w > 0.2) return@box shade(argb(0x2A1810), 0.8)
            wood(f, u, w, seed + 7)
        }
        // the roof: shingles over the board, its front edge leaning out towards the viewer
        when (v) {
            0 -> {
                c.plane(doubleArrayOf(i0 - 0.06, j0 - 0.22, top - 4), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, 0.2, 18.0)) { u, w ->
                    shade(mix(argb(0x241C16), argb(0x5A4636), rnd(floor(u * 14).toInt(), floor(w * 4).toInt(), seed + 12) * 0.6), 1.0)
                }
                c.plane(doubleArrayOf(i0 - 0.06, j0 - 0.02, top + 14), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, 0.2, -18.0)) { u, w ->
                    shade(mix(argb(0x241C16), argb(0x5A4636), rnd(floor(u * 14).toInt(), floor(w * 4).toInt(), seed + 11) * 0.6 + (if (frac(w * 4) < 0.15) -0.3 else 0.0)), 0.75 + 0.25 * w)
                }
            }
            1 -> c.box(i0 - 0.06, j0 - 0.12, i1 + 0.06, j1 + 0.1, top, top + 6) { f, u, w -> wood(f, u, w, seed + 13, 0x3A2C22) }
            else -> {}
        }
        return c.img
    }

    /** Splats a round body (cylinder) of radius [r] tiles at (ci, cj) from z0 to z1: its side towards us, then its top by [top]. */
    private fun Tile1.cylinder(ci: Double, cj: Double, r: Double, z0: Double, z1: Double, side: (ang: Double, z: Double, lit: Double) -> Int?, top: ((Double, Double) -> Int?)? = null) {
        val steps = (r * 900).toInt().coerceAtLeast(60)
        var z = z0
        while (z <= z1) {
            for (k in 0..steps) {
                // the half facing the camera (towards +i and +j), lit from the right (+i, −j)
                val ang = -Math.PI / 4 + Math.PI * k / steps
                val i = ci + r * Math.cos(ang); val j = cj + r * Math.sin(ang)
                val lit = 0.6 + 0.4 * ((Math.cos(ang) - Math.sin(ang)) / Math.sqrt(2.0) + 1) / 2
                side(ang, z, lit)?.let { img.set(floor(sx(i, j)).toInt(), floor(sy(i, j, z)).toInt(), it) }
            }
            z += 0.6
        }
        if (top != null) for (py in 0 until h) for (px in 0 until w) {
            val aa = (px + 0.5 - w / 2.0) / (TW / 2); val bb = (py + 0.5 - h + z1 * ZS) / (TH / 2)
            val i = (aa + bb) / 2 - ci; val j = (bb - aa) / 2 - cj
            val d = Math.hypot(i, j) / r
            if (d <= 1) top(d, Math.atan2(j, i))?.let { img.set(px, py, it) }
        }
    }

    private fun stoneRing(ang: Double, z: Double, lit: Double, seed: Int): Int {
        val course = floor(z / 10).toInt()
        val block = floor(ang * 4 + rnd(course, 0, seed) * 2).toInt()
        var t = 0.5 + (rnd(block, course, seed + 1) - 0.5) * 0.35
        if (z % 10 < 1.5 || frac(ang * 4 + rnd(course, 0, seed) * 2) < 0.06) t -= 0.3
        if (z < 8 && rnd(block, 9, seed) > 0.5) return shade(mix(argb(0x2A3218), argb(0x4E5A2E), t), lit)
        return shade(mix(argb(0x1E1C1A), argb(0x7E786C), t.coerceIn(0.0, 1.0)), lit)
    }

    /**
     * The village well (5.2): a ring of field stones knee high, dark water deep down, two posts and a little roof over
     * a windlass with its rope and bucket. Three looks: shingle roof, thatch roof, a plain crossbeam with a pulley.
     */
    fun well(v: Int, seed: Int): PixelImage {
        val c = Tile1(230)
        val r = 0.36
        fun post(i: Double, j: Double) = c.box(i - 0.035, j - 0.035, i + 0.035, j + 0.035, 30.0, 150.0) { f, u, w -> wood(f, w, u, seed + 2, 0x4A3828) }
        // the back post stands behind the ring, the front one before it
        post(-0.5, -0.86)
        c.cylinder(-0.5, -0.5, r, 0.0, 44.0, { a, z, lit -> stoneRing(a, z, lit, seed) }) { d, _ ->
            if (d > 0.8) shade(argb(0x6A645A), 0.9 + rnd(floor(d * 20).toInt(), 0, seed) * 0.2)
            else mix(argb(0x050607), argb(0x10161A), (1 - d) * 0.6)
        }
        post(-0.5, -0.14)
        // the windlass across, rope down to a bucket hanging a little inside the ring
        c.box(-0.53, -0.86, -0.47, -0.14, 118.0, 124.0) { f, u, w -> wood(f, u, w, seed + 3, 0x3E2E22) }
        for (z in 70 until 118) c.img.set(floor(c.sx(-0.5, -0.46)).toInt(), floor(c.sy(-0.5, -0.46, z.toDouble())).toInt(), argb(0x3A3024))
        c.cylinder(-0.5, -0.46, 0.08, 56.0, 72.0, { _, z, lit -> shade(if (abs(z - 60) < 1.5 || abs(z - 69) < 1.5) argb(0x2A2826) else argb(0x5A4430), lit) })
        when (v) {
            0, 1 -> {
                // a little gable roof along j
                val ridge = 190.0; val eave = 150.0
                c.plane(doubleArrayOf(-0.5, -0.98, ridge), doubleArrayOf(0.0, 0.96, 0.0), doubleArrayOf(0.4, 0.0, eave - ridge)) { u, w ->
                    if (v == 0) shingleTex(u * 1.2, w * 0.5, 0.5, seed + 4) else thatchTex(u * 1.2, w * 0.5, 0.5, looks[0], seed + 4)
                }
                c.plane(doubleArrayOf(-0.1, -0.98, eave - 4), doubleArrayOf(0.0, 0.96, 0.0), doubleArrayOf(0.0, 0.0, 4.0)) { _, _ -> argb(0x1A140E) }
                // the gable towards the front: boards under the roof's edge
                c.plane(doubleArrayOf(-0.9, -0.06, eave), doubleArrayOf(0.8, 0.0, 0.0), doubleArrayOf(0.0, 0.0, ridge - eave)) { u, w ->
                    if (abs(u - 0.5) > 0.5 * (1 - w)) null else wood(0, u, w, seed + 6, 0x4A3828)
                }
            }
            else -> c.box(-0.53, -0.92, -0.47, -0.08, 150.0, 158.0) { f, u, w -> wood(f, u, w, seed + 5, 0x4A3828) }
        }
        return c.img
    }

    /**
     * A market stall (5.2): a trestle table of planks under a cloth roof on four poles, wares on it. Three looks with
     * their own cloth and wares: apples and cabbages, loaves and sacks, pots and a string of onions. [withCloth] false: all
     * but the cloth roof (5.5: on the map the roof fades on its own when the hero stands behind the stall).
     */
    fun stall(v: Int, seed: Int, withCloth: Boolean = true, west: Boolean = false, east: Boolean = false, wareSeed: Int = seed): PixelImage {
        val c = Tile1(220)
        // D6.5: a stall over two tiles is one stall: towards a stall tile beside it the board and the cloth run on to the
        // edge of the tile, and the poles stand only at the stall's two ends
        val i0 = if (west) -1.0 else -0.9; val i1 = if (east) 0.0 else -0.1; val j0 = -0.72; val j1 = -0.28
        for ((pi, pj) in listOf(i0 to j0, i1 to j0, i0 to j1, i1 to j1)) if (!(pi == i0 && west) && !(pi == i1 && east))
            c.box(pi - 0.025, pj - 0.025, pi + 0.025, pj + 0.025, 0.0, if (pj == j0) 130.0 else 112.0) { f, u, w -> wood(f, w, u, seed + 1, 0x3E2E22) }
        c.box(i0, j0, i1, j1, 42.0, 48.0) { f, u, w -> wood(f, u, w, seed + 2, 0x5A4430) }
        // the wares: little round heaps on the board
        val wares = when (v) { 0 -> listOf(0x7A2A1E, 0x5A6E2E, 0x8A3A22); 1 -> listOf(0x8A6A3A, 0x9A7A46, 0x6E5E44); else -> listOf(0x6A4A34, 0x4E5A4E, 0x8A7A5E) }
        // D6.5: laid out loosely, not in a 3 × 3 grid, each tile of a long stall its own
        for (k in 0 until 9) {
            val wi = -0.8 + (k % 3) * 0.27 + (rnd(k, 1, wareSeed) - 0.5) * 0.16; val wj = j0 + 0.1 + (k / 3) * 0.12 + (rnd(k, 5, wareSeed) - 0.5) * 0.06
            if (rnd(k, 6, wareSeed) < 0.15) continue
            val rr = (if (v == 1) 0.07 else 0.05) * (0.8 + rnd(k, 7, wareSeed) * 0.4)
            val col = wares[hash(k, 2, wareSeed) % wares.size]
            c.cylinder(wi, wj, rr, 48.0, 48.0 + rr * 90, { _, z, lit -> shade(argb(col), lit * (0.7 + 0.3 * (z - 48) / (rr * 90))) })
        }
        if (!withCloth) return c.img
        // the cloth: sloping from the back poles down to the front, striped, its hem hanging ragged
        val cloth = when (v) { 0 -> 0x5A3A2A to 0x7A6E58; 1 -> 0x3E4A3A to 0x6E6A52; else -> 0x4A3A4E to 0x7A7060 }
        c.plane(doubleArrayOf(i0 - 0.06, j0 - 0.04, 132.0), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, j1 - j0 + 0.16, -26.0)) { u, w ->
            val stripe = floor(u * 6).toInt() % 2 == 0
            shade(mix(argb(if (stripe) cloth.first else cloth.second), argb(0x140E0A), 0.15 + (rnd(floor(u * 60).toInt(), floor(w * 8).toInt(), seed + 3) - 0.5) * 0.2), 0.85 + 0.2 * w)
        }
        c.plane(doubleArrayOf(i0 - 0.06, j1 + 0.12, 96.0), doubleArrayOf(i1 - i0 + 0.12, 0.0, 0.0), doubleArrayOf(0.0, 0.0, 10.0)) { u, w ->
            if (w < 0.4 * rnd(floor(u * 30).toInt(), 1, seed + 4)) null else shade(argb(if (floor(u * 6).toInt() % 2 == 0) cloth.first else cloth.second), 0.65)
        }
        return c.img
    }

    /** Only the cloth roof of a [stall]: the pixels where the whole stall differs from the one without its cloth. */
    fun stallCloth(v: Int, seed: Int, west: Boolean = false, east: Boolean = false): PixelImage =
        litWindows(stall(v, seed, false, west, east), stall(v, seed, true, west, east))

    /**
     * [img] without its empty rows at the top, an even number of them (drawn at half size); [PixelImage.oy] says how many.
     * Pictures stand on their lower edge, so it is drawn where it was; but the cloth and the rest of a stall now have
     * different places, and the see-through goes by place, so each fades on its own.
     */
    private fun cutTop(img: PixelImage): PixelImage {
        var n = 0
        while (n < img.height - 2 && (0 until img.width).none { img.opaque(it, n) }) n++
        n -= n % 2
        return PixelImage(img.width, img.height - n, img.pixels.copyOfRange(n * img.width, img.pixels.size), 0, n)
    }

    /**
     * A street lamp (5.2): a lantern of iron and horn on a post of oak or iron; three looks. [lit] (25.1): only the
     * horn panes, glowing from the flame inside, hottest in the middle and low down; the rest left clear.
     */
    fun lamp(v: Int, seed: Int, lit: Boolean = false, ci: Double = -0.5, cj: Double = -0.5): PixelImage {
        val c = Tile1(240)
        // lit, everything but the glass is drawn clear, so what stands in front of the glass still hides it
        fun dark(col: Int) = if (lit) 0 else col
        // ([ci], [cj]): where the post stands on the tile, the middle unless set (69e: the bridge lantern on the bank's corner)
        val di = ci + 0.5; val dj = cj + 0.5
        val iron = v == 2
        val (li, lj, lz) = lampHead(v, ci, cj)
        c.box(-0.54 + di, -0.54 + dj, -0.46 + di, -0.46 + dj, 0.0, 6.0) { f, _, _ -> dark(shade(argb(0x4A463E), if (f == 0) 0.6 else 0.9)) }
        c.box(-0.52 + di, -0.52 + dj, -0.48 + di, -0.48 + dj, 0.0, 170.0) { f, u, w -> dark(if (iron) shade(argb(0x262422), if (f == 0) 0.7 else 1.0) else wood(f, w, u, seed, 0x3E2E22)) }
        // an arm out towards the front, the lantern hanging from it on the first look; else sitting on top
        if (v == 0) c.box(-0.52 + di, -0.52 + dj, -0.48 + di, -0.26 + dj, 160.0, 164.0) { f, u, w -> dark(wood(f, u, w, seed + 1, 0x3E2E22)) }
        c.box(li - 0.07, lj - 0.07, li + 0.07, lj + 0.07, lz, lz + 22) { f, u, w ->
            val frame = u < 0.15 || u > 0.85 || w < 0.1 || w > 0.9
            when {
                f == 2 -> dark(argb(0x1E1C1A))
                frame -> dark(shade(argb(0x2A2826), if (f == 0) 0.7 else 1.0))
                // the flame sits low in the middle: the pane brightest there, the shaded face a little less
                lit -> shade(mix(argb(0xFFF2C8), argb(0xF0A850), Math.hypot((u - 0.5) * 1.6, (w - 0.38) * 1.2).coerceIn(0.0, 1.0)), if (f == 0) 0.9 else 1.0)
                else -> mix(argb(0x6A5030), argb(0xC09050), w * 0.5)
            }
        }
        c.plane(doubleArrayOf(li - 0.09, lj + 0.09, lz + 22), doubleArrayOf(0.18, 0.0, 0.0), doubleArrayOf(0.09, -0.09, 10.0)) { u, w -> if (abs(u - 0.5) > 0.5 * (1 - w)) null else dark(argb(0x24221F)) }
        return c.img
    }

    /** 80: old Kael's lantern stands on the ground beside his door, against the wall (his door is at 23/5). */
    val KAEL_LANTERN = 24 to 6

    /**
     * 80 (user 14.10.): old Kael's hand lantern beside his door: iron frame, horn panes gone brown and sooty, scorched
     * black up one side, a ring on the cap. 80a (user 14.10., Beschlüsse): it stands on a knee-high plinth of rough
     * stone, his family's mark cut into its front (a lozenge with a bar through it, the same mark as on his parents'
     * house in Aschfurt, chapter 2). [lit]: only what shines at night, a weak amber through the sooty horn, nothing
     * like a street lamp; everything else drawn clear.
     */
    fun kaelLantern(lit: Boolean = false): PixelImage {
        val c = Tile1(110)
        fun dark(col: Int) = if (lit) 0 else col
        // the plinth, about 50 cm high and 30 across, its stones uneven and their edges worn
        val p0 = -0.94; val p1 = -0.68; val ph = 28.0
        if (!lit) c.shadow((p0 + p1) / 2, (p0 + p1) / 2, 0.2, 0.4)
        c.box(p0, p0, p1, p1, 0.0, ph) { f, u, w ->
            val n = Math.floorMod(hash((u * 40).toInt(), (w * 30).toInt() + f * 97, 803), 100)
            // three courses of rough stone, joints a little crooked
            val course = (w * 3 + (if ((w * 3).toInt() % 2 == 0) u * 0.15 else -u * 0.1)).let { it - floor(it) }
            val joint = course < 0.07 || (f != 2 && abs(((u + (w * 3).toInt() * 0.37) * 2.2).let { it - floor(it) } - 0.5) < 0.04)
            val m = abs(u - 0.5) * 1.3 + abs(w - 0.55)
            val base = mix(argb(0x4E4A44), argb(0x3C3934), n / 120.0)
            dark(when {
                f == 2 -> shade(base, 1.08)
                // 80a: the mark cut into the front face, a groove darker than the stone
                f == 1 && m < 0.26 && abs(m - 0.18) < 0.055 -> shade(base, 0.38)
                f == 1 && abs(w - 0.55) < 0.045 && abs(u - 0.5) < 0.28 -> shade(base, 0.38)
                joint -> shade(base, if (f == 0) 0.45 else 0.62)
                else -> shade(base, if (f == 0) 0.7 else 0.95)
            })
        }
        val i0 = -0.86; val i1 = -0.76; val j0 = -0.86; val j1 = -0.76
        val iron = argb(0x24221F)
        // the foot, a little wider
        c.box(i0 - 0.01, j0 - 0.01, i1 + 0.01, j1 + 0.01, ph, ph + 2.0) { f, _, _ -> dark(shade(iron, if (f == 0) 0.7 else 0.95)) }
        c.box(i0, j0, i1, j1, ph + 2.0, ph + 18.0) { f, u, w ->
            val frame = u < 0.14 || u > 0.86 || w < 0.08 || w > 0.92
            // the soot of an old fire runs up the left face and darkens every pane towards the top
            val scorch = if (f == 0) (0.35 + w * 0.6) * (1 - u * 0.7) else w * 0.35
            when {
                f == 2 -> dark(argb(0x1A1816))
                frame -> dark(shade(argb(0x2E2A26), if (f == 0) 0.7 else 1.0))
                // a small flame low in the middle, its light dulled by the horn and darkest where the soot is
                lit -> shade(mix(mix(argb(0xA86E30), argb(0x583818), Math.hypot((u - 0.5) * 1.6, (w - 0.35) * 1.3).coerceIn(0.0, 1.0)), argb(0x140C06), scorch.coerceIn(0.0, 0.85)), if (f == 0) 0.75 else 1.0)
                else -> shade(mix(mix(argb(0x3E3020), argb(0x5E4A2C), w * 0.4), argb(0x100C0A), scorch.coerceIn(0.0, 0.9)), if (f == 0) 0.8 else 1.0)
            }
        }
        if (lit) return c.img
        // the cap, a squat pyramid, and the ring to carry it by
        c.plane(doubleArrayOf(i0 - 0.01, j1 + 0.01, ph + 18.0), doubleArrayOf(i1 - i0 + 0.02, 0.0, 0.0), doubleArrayOf((i1 - i0) / 2, -(j1 - j0) / 2, 4.0)) { u, w -> if (abs(u - 0.5) > 0.5 * (1 - w)) null else shade(iron, 0.75) }
        c.plane(doubleArrayOf(i1 + 0.01, j0 - 0.01, ph + 18.0), doubleArrayOf(0.0, j1 - j0 + 0.02, 0.0), doubleArrayOf(-(i1 - i0) / 2, (j1 - j0) / 2, 4.0)) { u, w -> if (abs(u - 0.5) > 0.5 * (1 - w)) null else iron }
        val mi = (i0 + i1) / 2; val mj = (j0 + j1) / 2
        for (k in 0 until 24) {
            val a = Math.PI * k / 23
            val x = c.sx(mi, mj) + kotlin.math.cos(a) * 2.0; val y = c.sy(mi, mj, ph + 22.0) - kotlin.math.sin(a) * 2.5
            c.img.set(x.toInt(), y.toInt(), argb(0x2A2622))
        }
        return c.img
    }

    /** 80a: what of Kael's lantern shines at night, with the middle of its light; a faint glow, not a lamp's. */
    fun kaelLanternGlow(): WorldArt.Glow {
        val c = Tile1(110)
        return WorldArt.Glow(kaelLantern(lit = true), c.sx(-0.81, -0.81).toInt(), c.sy(-0.81, -0.81, 37.0).toInt(), halo = 0.2f)
    }

    /** Where a lamp's lantern sits (i, j on the tile, height of its foot): hanging from an arm on the first look. */
    private fun lampHead(v: Int, ci: Double = -0.5, cj: Double = -0.5) = if (v == 0) Triple(ci, cj + 0.2, 136.0) else Triple(ci, cj, 170.0)

    /** The glass of lamp [v] shining at night (25.1), with the middle of its light in the picture. */
    fun lampGlow(v: Int, ci: Double = -0.5, cj: Double = -0.5): WorldArt.Glow {
        val (li, lj, lz) = lampHead(v, ci, cj)
        val c = Tile1(240)
        return WorldArt.Glow(lamp(v, 521 + v, lit = true, ci = ci, cj = cj), c.sx(li, lj).toInt(), c.sy(li, lj, lz + 11).toInt())
    }

    /**
     * 69e (user 14.10., 21:4x, as in the intro picture): a lantern on an oak post at the south end of the bridge, on the
     * bank east of it (the tile, and where on it the post stands), lighting the crossing at night on the way to the inn.
     */
    val BRIDGE_LANTERN = 19 to 27
    private const val BL_I = -0.84
    private const val BL_J = -0.14

    /** 89: where on its tile the bridge lantern's post stands (local i, j). */
    fun bridgeLanternLocal() = BL_I to BL_J

    /** The bridge lantern's light on the map: the middle of the tile point its post stands on (map pixels). */
    fun bridgeLanternAt(): Pair<Double, Double> = (BRIDGE_LANTERN.first + 1 + BL_I) * WorldArt.T to (BRIDGE_LANTERN.second + 1 + BL_J) * WorldArt.T

    /**
     * 69e: the low railing of the bridge, one piece of it along the west ([west]) or east edge of a bridge tile, for
     * the half of the tile from [j0] to [j1] (local j, −1 north to 0 south): split rails on short posts, about hip high
     * to the hero, a post at the piece's north end ([post0]) and south end ([post1]): at the ends of the bridge and halfway along each tile.
     */
    fun bridgeRail(west: Boolean, j0: Double, j1: Double, post0: Boolean, post1: Boolean, seed: Int): PixelImage {
        val c = Tile1(110)
        val i = if (west) -0.94 else -0.06
        fun post(j: Double) = c.box(i - 0.035, j - 0.035, i + 0.035, j + 0.035, 0.0, 50.0) { f, u, w -> wood(f, w, u, seed + (j * 40).toInt(), 0x3E2E20) }
        // what lies behind first: the rails run along j, the post at the far end before them, the near one after
        if (post0) post(j0 + 0.035)
        c.box(i - 0.02, j0, i + 0.02, j1, 20.0, 25.0) { f, u, w -> wood(f, u, w, seed + 3, 0x4A3828) }
        c.box(i - 0.03, j0, i + 0.03, j1, 42.0, 48.0) { f, u, w -> wood(f, u, w, seed + 5, 0x5A4632) }
        if (post1) post(j1 - 0.035)
        return c.img
    }

    /** A bench (5.2): a thick plank on two blocks or trestles, along the map's x; three looks. */
    fun bench(v: Int, seed: Int): PixelImage {
        val c = Tile1(120)
        c.shadow(-0.5, -0.5, 0.42, 0.35)
        val j0 = -0.62; val j1 = -0.4
        for (li in listOf(-0.84, -0.22)) {
            if (v == 1) c.box(li - 0.06, j0 + 0.02, li + 0.06, j1 - 0.02, 0.0, 24.0) { f, _, _ -> shade(argb(0x6A645A), if (f == 0) 0.6 else if (f == 1) 0.9 else 1.0) }
            else c.box(li - 0.03, j0 + 0.03, li + 0.03, j1 - 0.03, 0.0, 24.0) { f, u, w -> wood(f, w, u, seed, 0x3E2E22) }
        }
        c.box(-0.92, j0, -0.08, j1, 24.0, 30.0) { f, u, w -> wood(f, u, w, seed + 1, if (v == 2) 0x4A3A2E else 0x5A4430) }
        if (v == 2) c.box(-0.92, j0 - 0.04, -0.08, j0, 30.0, 62.0) { f, u, w -> wood(f, u, w, seed + 2, 0x4A3A2E) }
        return c.img
    }

    /**
     * D29.3: what a yard tile ([Tile.YARD]) holds, by what lies beside it: on the bank a net drying (3), against a
     * house a woodpile (0), by the washing line or the well buckets (2), else a handcart (1).
     */
    fun yardKind(map: MapDef, tx: Int, ty: Int): Int {
        val around = listOf(map.tile(tx - 1, ty), map.tile(tx + 1, ty), map.tile(tx, ty - 1), map.tile(tx, ty + 1))
        return when {
            Tile.WATER in around -> 3
            around.any { it == Tile.WALL || it == Tile.WINDOW || it == Tile.ROOF || it == Tile.ROOF_BLUE } -> 0
            around.any { it == Tile.WASHLINE || it == Tile.WELL } -> 2
            else -> 1
        }
    }

    /** D29.3: the thing on a yard tile, [kind] as [yardKind], three looks each. */
    fun yard(kind: Int, v: Int, seed: Int): PixelImage = when (kind) {
        0 -> woodpile(v, seed)
        1 -> handcart(v, seed)
        2 -> buckets(v, seed)
        else -> net(v, seed)
    }

    /** Split logs stacked along the map's x, their cut ends towards the viewer, the chopping block with the axe before them; three looks, a little higher each. */
    private fun woodpile(look: Int, seed: Int): PixelImage {
        val c = Tile1(150)
        c.shadow(-0.5, -0.5, 0.5, 0.35)
        // 224.1, 224.2: low and long, in the measure of a real stack against a wall: well under a metre high (40 to 48, the
        // eaves at 84), over the tile's whole width, so two yard tiles side by side along a wall make one stack
        val i0 = -0.99; val i1 = -0.01
        val j0 = -0.78; val j1 = -0.4
        val top = 40.0 + 4 * look
        // 224: every log on its own, whole, row upon row, every other row shifted by half a log; its end a little before
        // or behind its neighbours', the top row ragged; no pattern cut off at the edges of a box
        val d = 10.0; val iz = 1 / 66.0; val wide = (i1 - i0) / iz
        fun bark(face: Int, u: Double, w: Double, along: Double): Int {
            val k = if (face == 1) 0.95 else 1.05
            val row = floor(along / 0.12).toInt()
            var t = 0.45 + (rnd(row, floor(u * 9).toInt(), seed + 2) - 0.5) * 0.3
            if (frac(along / 0.12) < 0.14) t -= 0.35
            return shade(mix(argb(0x1A120C), argb(0x5E4630), t.coerceIn(0.0, 1.0)), k)
        }
        /** The cut end of a log: round, halved or quartered (split), the pale wood inside, bark round the edge. */
        fun end(u: Double, w: Double, kind: Int, tone: Double, turn: Double): Int? {
            val x = u * 2 - 1; val y = w * 2 - 1; val r = Math.hypot(x, y)
            if (r > 1) return null
            val ang = (Math.atan2(y, x) + turn + 4 * PI) % (2 * PI)
            if (kind == 1 && ang > PI) return null
            if (kind == 2 && ang > PI / 2) return null
            if (r > 0.8 && (kind == 0 || ang in 0.12..(if (kind == 1) PI - 0.12 else PI / 2 - 0.12))) return shade(argb(0x3A2A1C), 0.7)
            val ring = if (frac(r * 3 + tone) < 0.15) -0.12 else 0.0
            return shade(mix(argb(0x6E5236), argb(0xB0905E), (0.55 + (tone - 0.5) * 0.5 + ring - r * 0.2).coerceIn(0.0, 1.0)), 0.72)
        }
        data class Log(val ci: Double, val cz: Double, val r: Double, val jEnd: Double, val kind: Int, val tone: Double, val turn: Double)
        val logs = ArrayList<Log>()
        val rows = floor(top / d).toInt()
        for (row in 0 until rows) {
            val shift = if (row % 2 == 1) d / 2 else 0.0
            val n = floor((wide - shift) / d).toInt()
            for (col in 0 until n) {
                // the top row is ragged: some logs missing at its ends
                if (row == rows - 1 && (col == 0 && rnd(col, row, seed + 9) < 0.6 || col == n - 1 && rnd(col, row, seed + 10) < 0.6)) continue
                val r = d / 2 * (0.82 + 0.16 * rnd(col, row, seed + 11))
                logs += Log(i0 + (shift + (col + 0.5) * d) * iz, (row + 0.5) * d, r, j1 + (rnd(col, row, seed + 12) - 0.5) * 0.06,
                    (rnd(col, row, seed + 13) * 3).toInt(), rnd(col, row, seed), rnd(col, row, seed + 14) * 2 * PI)
            }
        }
        // the dark inside of the stack, seen in the gaps between the logs
        c.box(i0 + 0.03, j0, i1 - 0.03, j1 - 0.05, 0.0, (rows - 1.2) * d) { f, _, _ -> shade(argb(0x140E0A), if (f == 1) 0.9 else 0.7) }
        // painted back to front: the bodies first, from the bottom row up, then the ends, the far ones first
        for (l in logs.sortedWith(compareBy({ it.cz }, { it.ci }))) {
            val ri = l.r * iz * 0.72
            c.box(l.ci - ri, j0, l.ci + ri, l.jEnd - 0.004, l.cz - l.r * 0.72, l.cz + l.r * 0.72) { f, u, w -> bark(f, u, w, if (f == 1) w * top / 66.0 else u) }
        }
        for (l in logs.sortedWith(compareBy({ it.jEnd }, { it.cz }))) {
            c.plane(doubleArrayOf(l.ci - l.r * iz, l.jEnd, l.cz - l.r), doubleArrayOf(2 * l.r * iz, 0.0, 0.0), doubleArrayOf(0.0, 0.0, 2 * l.r)) { u, w -> end(u, w, l.kind, l.tone, l.turn) }
        }
        // 224.2 (Chef 19.10.): the chopping block, a short round of oak, the axe stuck in it, before the stack
        c.cylinder(-0.3, -0.2, 0.11, 0.0, 20.0, { ang, z, lit ->
            shade(mix(argb(0x2A1C12), argb(0x5A4028), 0.45 + rnd(floor(ang * 8).toInt(), floor(z / 4).toInt(), seed + 6) * 0.3), lit)
        }) { d2, _ -> if (frac(d2 * 4) < 0.18) argb(0x5A4428) else argb(0x9A7C52) }
        c.box(-0.33, -0.23, -0.27, -0.17, 20.0, 24.0) { f, _, _ -> shade(argb(0x3A3836), if (f == 0) 0.7 else 1.1) }
        c.box(-0.31, -0.21, -0.29, -0.19, 24.0, 50.0) { f, u, w -> wood(f, w, u, seed + 7, 0x7A5E3E) }
        // a few chips on the ground
        for (k in 0 until 5) {
            val ci = -0.75 + rnd(k, 1, seed) * 0.35; val cj = -0.3 + rnd(k, 2, seed) * 0.22
            c.box(ci, cj, ci + 0.04, cj + 0.02, 0.0, 1.5) { f, _, _ -> shade(argb(0xA88A5A), if (f == 2) 1.0 else 0.7) }
        }
        return c.img
    }

    /** A two-wheeled handcart, its shafts resting on the ground. Three looks: empty, sacks on it, a load of hay. */
    private fun handcart(v: Int, seed: Int): PixelImage {
        val c = Tile1(150)
        c.shadow(-0.5, -0.5, 0.48, 0.35)
        val i0 = -0.72; val i1 = -0.16; val j0 = -0.68; val j1 = -0.32
        val z0 = 30.0; val z1 = 52.0
        // a wheel standing in the plane at [j]: rim, six spokes, hub
        fun wheel(j: Double, dark: Double) {
            val ci = (i0 + i1) / 2; val r = 0.26; val zr = 26.0
            c.plane(doubleArrayOf(ci - r, j, 0.0), doubleArrayOf(2 * r, 0.0, 0.0), doubleArrayOf(0.0, 0.0, 2 * zr)) { u, w ->
                val x = u * 2 - 1; val y = w * 2 - 1; val d = Math.hypot(x, y)
                val ang = Math.atan2(y, x)
                when {
                    d > 1 -> null
                    d > 0.84 -> if (d > 0.95) shade(argb(0x2A2826), dark) else shade(argb(0x4A3624), dark)
                    d < 0.2 -> shade(argb(0x3A2C20), dark * 1.1)
                    abs(Math.sin(ang * 3)) < 0.1 / d.coerceAtLeast(0.2) -> shade(argb(0x5A4430), dark)
                    else -> null
                }
            }
        }
        wheel(j0 - 0.02, 0.55)
        // the shafts out to the back, resting on the ground
        for (j in listOf(j0 + 0.04, j1 - 0.04))
            c.plane(doubleArrayOf(-1.0, j, 4.0), doubleArrayOf(i0 + 1.0, 0.0, z0 + 4.0 - 4.0), doubleArrayOf(0.0, 0.03, 0.0)) { u, w -> wood(1, u, w, seed + 3, 0x5A4430) }
        // the bed: boards round a floor, the load (or the inside) on top
        c.box(i0, j0, i1, j1, z0, z1) { f, u, w ->
            if (f == 2) when (v) {
                0 -> shade(wood(2, u, w, seed + 4, 0x3A2C20), 0.7)
                1 -> {
                    // two sacks, pale and lumpy
                    val sx = if (u < 0.5) u * 2 else u * 2 - 1
                    val r = Math.hypot(sx - 0.5, w - 0.5)
                    if (r < 0.46) shade(argb(0x9A8A68), 1.05 - r * 0.6) else shade(wood(2, u, w, seed + 4, 0x3A2C20), 0.7)
                }
                else -> shade(mix(argb(0x6A5A2A), argb(0xC2A860), rnd(floor(u * 30).toInt(), floor(w * 12).toInt(), seed + 8)), 1.0)
            } else {
                if (frac(w * 3) < 0.1 || u < 0.03 || u > 0.97) wood(f, u, w, seed + 5, 0x2E2218) else wood(f, u, w, seed + 6, 0x5A4430)
            }
        }
        // sacks and hay rise over the boards
        if (v == 1) for (k in 0 until 2) c.cylinder(i0 + 0.16 + k * 0.26, (j0 + j1) / 2, 0.12, z1, z1 + 12.0, { _, z, lit -> shade(argb(0x8A7A5A), lit * (0.9 + (z - z1) / 60)) }) { d, _ -> shade(argb(0xA89878), 1.05 - d * 0.3) }
        if (v == 2) c.box(i0 + 0.04, j0 + 0.04, i1 - 0.04, j1 - 0.04, z1, z1 + 16.0) { f, u, w ->
            if (f != 2 && rnd(floor(u * 40).toInt(), floor(w * 8).toInt(), seed + 9) > 0.85) null
            else shade(mix(argb(0x5A4A20), argb(0xC2A860), rnd(floor(u * 30).toInt(), floor(w * 10).toInt(), seed + 8)), if (f == 0) 0.7 else 1.0)
        }
        wheel(j1 + 0.02, 0.95)
        return c.img
    }

    /** Wooden buckets with iron hoops. Three looks: a full one and one upside down, two side by side, a bucket beside a broad washtub. */
    private fun buckets(v: Int, seed: Int): PixelImage {
        val c = Tile1(110)
        c.shadow(-0.5, -0.5, 0.42, 0.3)
        fun bucket(ci: Double, cj: Double, r: Double, h: Double, full: Boolean, turned: Boolean) {
            c.cylinder(ci, cj, r, 0.0, h, { ang, z, lit ->
                val zz = z / h
                if (abs(zz - 0.18) < 0.05 || abs(zz - 0.82) < 0.05) shade(argb(0x2A2826), lit)
                else {
                    val stave = floor(ang * 5 + rnd(0, 0, seed) * 3).toInt()
                    var t = 0.5 + (rnd(stave, 1, seed) - 0.5) * 0.3
                    if (frac(ang * 5) < 0.08) t -= 0.3
                    shade(mix(argb(0x2A1C12), argb(0x7A5C3A), t.coerceIn(0.0, 1.0)), lit)
                }
            }) { d, a ->
                when {
                    turned -> shade(argb(0x5A4430), 1.05 - d * 0.2)
                    d > 0.86 -> argb(0x6A5034)
                    full -> if (d < 0.3 && a > 0.5 && a < 1.5) argb(0x8A9AA2) else argb(0x2A363C)
                    else -> argb(0x1A120C)
                }
            }
        }
        when (v) {
            0 -> { bucket(-0.66, -0.56, 0.13, 32.0, false, true); bucket(-0.34, -0.36, 0.13, 34.0, true, false) }
            1 -> { bucket(-0.7, -0.4, 0.12, 32.0, true, false); bucket(-0.38, -0.66, 0.13, 34.0, false, false) }
            else -> { bucket(-0.78, -0.72, 0.12, 32.0, true, false); bucket(-0.42, -0.42, 0.3, 24.0, true, false) }
        }
        return c.img
    }

    /**
     * A fishing net drying on the bank, hung from a bar between two poles, sagging, corks along its foot. Three looks:
     * high on its poles, low on a rack with a basket of fish beside it, gathered to one side with a coil of rope.
     */
    private fun net(v: Int, seed: Int): PixelImage {
        val c = Tile1(220)
        val i0 = -0.86; val i1 = -0.14; val j = -0.5
        val bar = if (v == 1) 64.0 else 122.0
        fun pole(i: Double) = c.box(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 0.0, bar + 6) { f, u, w -> wood(f, w, u, seed + (i * 50).toInt(), 0x4A3828) }
        // the coil of rope and the basket lie behind the net
        if (v == 2) c.cylinder(-0.3, -0.76, 0.1, 0.0, 5.0, { ang, z, lit -> shade(argb(0x8A7A56), lit * (if (frac(z / 1.6 + ang) < 0.3) 0.7 else 1.0)) }) { d, _ ->
            if (d < 0.35) argb(0x1A140E) else shade(argb(0x9A8A64), if (frac(d * 5) < 0.3) 0.75 else 1.0) }
        pole(i0); pole(i1)
        c.box(i0 - 0.04, j - 0.015, i1 + 0.04, j + 0.015, bar, bar + 3) { f, u, w -> wood(f, u, w, seed + 3, 0x5A4430) }
        val len = (i1 - i0) * 66.0
        c.plane(doubleArrayOf(i0 + 0.03, j, 0.0), doubleArrayOf(i1 - i0 - 0.06, 0.0, 0.0), doubleArrayOf(0.0, 0.0, bar)) { u, w ->
            if (v == 2 && u > 0.5 + 0.1 * w) return@plane null
            // the foot of the net sags in the middle, never down to the ground on the low rack
            val foot = (if (v == 1) 0.12 else 0.2) - 0.12 * Math.sin(Math.PI * u) + (if (v == 2) 0.1 * u else 0.0)
            if (w < foot) return@plane null
            val x = u * len; val z = w * bar
            // corks along the foot, twine in diamonds above
            if (w < foot + 0.05 && frac(x / 9) < 0.35) return@plane shade(argb(0x8A5A2A), 0.95)
            val a = frac((x + z) / 7); val b = frac((x - z) / 7)
            if (a < 0.16 || b < 0.16 || (v == 2 && a < 0.3)) shade(argb(0x7A6E52), 0.85 + 0.15 * w) else null
        }
        if (v == 1) {
            // a basket of fish at the foot of the rack
            c.cylinder(-0.3, -0.24, 0.13, 0.0, 22.0, { ang, z, lit ->
                shade(argb(if ((floor(ang * 10).toInt() + floor(z / 3).toInt()) % 2 == 0) 0x6A5232 else 0x8A6E44), lit)
            }) { d, a -> if (d > 0.85) argb(0x5A4428) else if (frac(a * 2 + d * 3) < 0.4) argb(0xA8B0B4) else argb(0x5E6A70) }
        }
        return c.img
    }

    /**
     * The barrier across the road north (5.6): a beam of oak at hip height, two tiles long, on a stout post with an
     * iron pin where it turns ([pivot], the west tile) and resting in a forked post at its east end; iron bands at
     * its ends. Opened, it stands upright at its post.
     */
    fun barrier(pivot: Boolean, open: Boolean, seed: Int): PixelImage {
        val c = Tile1(300)
        val j0 = -0.55; val j1 = -0.45
        fun iron(f: Int) = shade(argb(0x262422), if (f == 0) 0.65 else if (f == 1) 1.0 else 1.1)
        if (pivot) {
            // the post with a cap of iron, the beam on its east side
            c.box(-0.86, -0.6, -0.74, -0.48, 0.0, 84.0) { f, u, w -> wood(f, w, u, seed, 0x463424) }
            c.box(-0.87, -0.61, -0.73, -0.47, 84.0, 86.0) { f, _, _ -> iron(f) }
            if (open) {
                // standing up beside the post, its foot in the pin
                c.box(-0.73, j0, -0.65, j1, 40.0, 200.0) { f, u, w ->
                    if (w > 0.94 || w in 0.3..0.33) iron(f) else wood(f, w, u, seed + 1, 0x6A5238)
                }
                c.box(-0.74, -0.57, -0.64, -0.43, 58.0, 64.0) { f, _, _ -> iron(f) }
            } else {
                c.box(-0.73, j0, 0.0, j1, 54.0, 66.0) { f, u, w -> if (u < 0.05) iron(f) else wood(f, u, w, seed + 1, 0x6A5238) }
                c.box(-0.74, -0.57, -0.64, -0.43, 54.0, 66.0) { f, _, _ -> iron(f) }
            }
        } else {
            // the forked post the beam rests in: two prongs, the beam between them
            val rest = -0.3
            c.box(rest - 0.05, -0.62, rest + 0.05, -0.56, 0.0, 70.0) { f, u, w -> wood(f, w, u, seed + 2, 0x463424) }
            c.box(rest - 0.05, -0.58, rest + 0.05, -0.42, 0.0, 54.0) { f, u, w -> wood(f, w, u, seed + 2, 0x463424) }
            if (!open) c.box(-1.0, j0, -0.16, j1, 54.0, 66.0) { f, u, w -> if (u > 0.9 && u < 0.97) iron(f) else wood(f, u, w, seed + 1, 0x6A5238) }
            c.box(rest - 0.05, -0.44, rest + 0.05, -0.38, 0.0, 70.0) { f, u, w -> wood(f, w, u, seed + 2, 0x463424) }
        }
        return c.img
    }

    /** Which look a fence has (5.6): the same along all of it, by the first tile reached going west and north. */
    private fun fenceLook(map: MapDef, tx: Int, ty: Int): Int {
        var x = tx; var y = ty
        repeat(64) {
            when {
                map.tile(x - 1, y) == Tile.FENCE -> x--
                map.tile(x, y - 1) == Tile.FENCE -> y--
                else -> return Math.floorMod(hash(x, y, 16), 3)
            }
        }
        return Math.floorMod(hash(x, y, 16), 3)
    }

    /**
     * Where a fence stands in its tile (93): a garden's fence on the edge towards its beds, so the beds reach it with
     * no strip of grass between; any other in the middle. The offsets along i (x) and j (y) inside the tile, -1 to 0.
     * Each straight run of fence moves as a whole, so its corners still meet.
     */
    fun fenceSpot(map: MapDef, tx: Int, ty: Int): Pair<Double, Double> {
        fun f(x: Int, y: Int) = map.tile(x, y) == Tile.FENCE
        fun bed(x: Int, y: Int) = map.tile(x, y) == Tile.VEG_BED
        // the run along x through the tile, and along y
        var x0 = tx; while (f(x0 - 1, ty)) x0--
        var x1 = tx; while (f(x1 + 1, ty)) x1++
        var y0 = ty; while (f(tx, y0 - 1)) y0--
        var y1 = ty; while (f(tx, y1 + 1)) y1++
        val j = when {
            (x0..x1).any { bed(it, ty + 1) } -> -0.1
            (x0..x1).any { bed(it, ty - 1) } -> -0.9
            else -> -0.5
        }
        val i = when {
            (y0..y1).any { bed(tx + 1, it) } -> -0.1
            (y0..y1).any { bed(tx - 1, it) } -> -0.9
            else -> -0.5
        }
        return i to j
    }

    /**
     * A piece of fence (5.6) around its post at ([mi], [mj]) in the tile (the middle unless [fenceSpot] moves it), joined towards the fence tiles beside it
     * ([l] west, [r] east, [u] north, [d] south). Three looks: split rails on posts, wattle of woven hazel between
     * stakes, a row of pointed pales on two rails.
     */
    fun fence(v: Int, l: Boolean, r: Boolean, u: Boolean, d: Boolean, seed: Int, mi: Double = -0.5, mj: Double = -0.5): PixelImage {
        val c = Tile1(160)
        // a run from the post to the tile's edge, along i (di = ±1) or j (dj = ±1)
        fun run(di: Int, dj: Int) {
            val m = if (di != 0) mi else mj
            val (a0, a1) = if (di + dj < 0) -1.0 to m else m to 0.0
            fun along(lo: Double, hi: Double, w: Double, z0: Double, z1: Double, tex: (Int, Double, Double) -> Int?) =
                if (di != 0) c.box(lo, mj - w, hi, mj + w, z0, z1, tex) else c.box(mi - w, lo, mi + w, hi, z0, z1, tex)
            when (v) {
                0 -> for (z in listOf(18.0, 40.0)) along(a0, a1, 0.025, z, z + 6) { f, uu, w -> wood(f, if (di != 0) uu else w, if (di != 0) w else uu, seed + z.toInt(), 0x5A4632) }
                1 -> {
                    along(a0, a1, 0.03, 0.0, 46.0) { f, uu, w ->
                        // the hazel woven over and under the stakes: bands of rods, each a little lit at its bulge
                        val s = if (di != 0) uu else w
                        val band = frac(w * 13 + (if (frac(s * 8) < 0.5) 0.5 else 0.0))
                        val k = 0.55 + sin(band * Math.PI) * 0.45
                        if (f == 2) shade(argb(0x4A3A28), 0.9) else shade(mix(argb(0x160F09), argb(0x56442C), k), if (f == 0) 0.65 else 1.0)
                    }
                    val mid = (a0 + a1) / 2
                    along(mid - 0.02, mid + 0.02, 0.035, 0.0, 52.0) { f, uu, w -> wood(f, w, uu, seed + 5, 0x3E2E20) }
                }
                else -> {
                    for (z in listOf(14.0, 36.0)) along(a0, a1, 0.02, z, z + 4) { f, uu, w -> wood(f, uu, w, seed + 7, 0x4A3828) }
                    var p = a0 + 0.07
                    while (p < a1 - 0.03) {
                        val top = 44.0 + rnd((p * 100).toInt(), di * 3 + dj, seed) * 8
                        along(p - 0.03, p + 0.03, 0.035, 0.0, top) { f, uu, w -> wood(f, w, uu, seed + (p * 50).toInt(), 0x5A4834) }
                        p += 0.14
                    }
                }
            }
        }
        // what lies behind the post first, then the post, then what lies in front
        if (l) run(-1, 0)
        if (u) run(0, -1)
        val top = when (v) { 0 -> 56.0; 1 -> 54.0; else -> 50.0 }
        c.box(mi - 0.05, mj - 0.05, mi + 0.05, mj + 0.05, 0.0, top) { f, uu, w -> wood(f, w, uu, seed + 9, 0x3E2E20) }
        if (r) run(1, 0)
        if (d) run(0, 1)
        return c.img
    }

    /** The things on the square, three looks each (preview ISODINGE=platz). */
    fun squareSheet(): List<Pair<String, List<PixelImage>>> = listOf(
        "Marktstand" to (0 until 3).map { stall(it, 501 + it) },
        "Brunnen" to (0 until 3).map { well(it, 511 + it) },
        "Laterne" to (0 until 3).map { lamp(it, 521 + it) },
        "Bank" to (0 until 3).map { bench(it, 531 + it) },
        "Schlagbaum" to listOf(barrier(true, false, 581), barrier(false, false, 581), barrier(true, true, 581)),
        "Zaun" to (0 until 3).map { fence(it, true, true, false, true, 591 + it) },
        "Wegweiser" to (0 until 3).map { signpost(it, 541 + it) },
        "Anschlagbrett" to (0 until 3).map { noticeBoard(it, 561 + it) },
        "Anschlagbrett mit frischem Zettel" to (0 until 3).map { noticeBoard(it, 561 + it, fresh = true) },
        "Holzstapel (224.2)" to (0 until 3).map { woodpile(it, 601 + it) },
    )

    // ------------------------------------------------------------------ the houses of a town map

    private val wallTiles = setOf(Tile.WALL, Tile.WINDOW, Tile.DOOR)
    private val roofTiles = setOf(Tile.ROOF, Tile.ROOF_BLUE)

    /** Where a house stands: its front row of wall tiles at [y] from [x], [n] wide, [d] tiles deep (roof rows and the front row). */
    data class Footprint(val x: Int, val y: Int, val n: Int, val d: Int) {
        val top get() = y - d + 1
    }

    /**
     * The windows of a house as seen outside, from its room (5h.1): the room's windows in its south wall and in its
     * east wall, each put on the tile of the outer wall at the same share of its length; the door stays where the
     * map has it. Null when the house has no room.
     */
    fun windowsFromRoom(room: MapDef, n: Int, d: Int, door: Int): Pair<String, String> {
        val w = room.width; val h = room.height
        val front = CharArray(n) { '#' }
        if (door in 0 until n) front[door] = 'D'
        // the room's inner tiles (between its corner walls) laid over the outer wall's tiles
        for (x in 1 until w - 1) if (room.tile(x, h - 1) == Tile.WINDOW) {
            var k = floor((x - 0.5) / (w - 2) * n).toInt().coerceIn(0, n - 1)
            if (k == door) k = if (x + 0.5 < w / 2.0) (k - 1).coerceAtLeast(0) else (k + 1).coerceAtMost(n - 1)
            front[k] = 'W'
        }
        val side = CharArray(d) { '#' }
        for (y in 1 until h - 1) if (room.tile(w - 1, y) == Tile.WINDOW) side[floor((y - 0.5) / (h - 2) * d).toInt().coerceIn(0, d - 1)] = 'W'
        return String(front) to String(side)
    }

    /** The room a house's door leads into, if any. */
    fun roomOf(map: MapDef, f: Footprint): MapDef? {
        val warp = map.warps.firstOrNull { it.y == f.y && it.x in f.x until f.x + f.n } ?: return null
        return World.maps[warp.to.map]?.takeIf { it.kind == MapKind.INTERIOR }
    }

    /** Every house of a town map with how to draw it (by day or at night). */
    fun houses(map: MapDef): List<Pair<Footprint, (Boolean) -> Picture>> {
        val out = mutableListOf<Pair<Footprint, (Boolean) -> Picture>>()
        for (y in 0 until map.height) {
            var x = 0
            while (x < map.width) {
                if (map.tile(x, y) !in wallTiles || (x > 0 && map.tile(x - 1, y) in wallTiles)) { x++; continue }
                var n = 0; while (map.tile(x + n, y) in wallTiles) n++
                var rows = 0; while (rows < 3 && (0 until n).all { map.tile(x + it, y - rows - 1) in roofTiles }) rows++
                val f = Footprint(x, y, n, rows + 1)
                out += f to { night -> picture(map, f, night) }
                x += n
            }
        }
        return out
    }

    /**
     * The measures of a house's roof in upright units: the eaves, the ridge, how far the roof hangs over the walls
     * (tiles); for the temple also the bell tower ([towerI] along i from the back corner, its top with the cap).
     */
    class Shape(val eave: Double, val ridge: Double, val overhang: Double, val towerI: Double? = null, val towerTop: Double = 0.0)

    private fun shape(d: Int, roof: RoofKind, feature: HouseFeature): Shape {
        val temple = feature == HouseFeature.BELL_TOWER
        // D3.13: a herbalist's cot in the woods, low under a deep, steep thatch hanging far out
        val hut = feature == HouseFeature.HUT
        // (user 15.10., 12:0x: far too big; flatter and smaller): 2×2, eaves a little over the hero's head, a flatter thatch
        val eave = if (temple) 176.0 else if (hut) 84.0 else 150.0     // eaves at 2.6 m, the temple higher, the cot's lower
        val o = if (hut) 0.3 else 0.28             // the roof hangs over the walls
        val pitch = if (hut) 0.6 else if (roof == RoofKind.STRAW) 1.25 else 1.0       // rise per run: thatch steeper, the cot's flatter
        val ridge = eave + (d / 2.0 + o) * ZT * pitch
        return Shape(eave, ridge, o, if (temple) -1.125 else null, ridge + 92 + 40)
    }

    private fun styleOf(map: MapDef, f: Footprint) =
        map.houseStyles[f.x to f.top] ?: HouseStyle(if (map.tile(f.x, f.top) == Tile.ROOF_BLUE) RoofKind.SLATE else RoofKind.STRAW, WallKind.TIMBER)

    /** 89: the measures of the house on [f] for its shadow ([MapSun]); the tower's place counted from the east end. */
    fun shape(map: MapDef, f: Footprint): Shape = styleOf(map, f).let { shape(f.d, it.roof, it.feature) }

    private fun picture(map: MapDef, f: Footprint, night: Boolean): Picture {
        val style = styleOf(map, f)
        val letters = (0 until f.n).joinToString("") { when (map.tile(f.x + it, f.y)) { Tile.WINDOW -> "W"; Tile.DOOR -> "D"; else -> "#" } }
        val door = letters.indexOf('D')
        val seed = hash(f.x, f.y, 5) % 997
        val room = roomOf(map, f)
        // D3.13a: the cot's door is in its front (south), towards Morwen's fire; the map's door tile is a wall with a
        // locked warp, so the door is where the warp is
        val hutDoor = if (style.feature == HouseFeature.HUT) map.warps.firstOrNull { it.y == f.y && it.x in f.x until f.x + f.n }?.let { it.x - f.x } else null
        val (front, side) = if (style.feature == HouseFeature.HUT) letters.mapIndexed { i, c -> if (i == hutDoor) 'D' else c }.joinToString("") to "##" else room?.let { windowsFromRoom(it, f.n, f.d, door) }
            ?: (letters to (if (f.d >= 3) "#W#" else if (seed % 2 == 0) "W#" else "#W"))
        // the chimney over the hearth inside, at the same share of the length; houses without a room: towards one end
        val chimney: Double? = when {
            style.feature == HouseFeature.BELL_TOWER || style.feature == HouseFeature.HUT -> null
            room != null -> (0 until room.width).filter { room.tile(it, 0) == Tile.HEARTH }.takeIf { it.isNotEmpty() }
                ?.let { hs -> (hs.average() + 0.5) / room.width * f.n }
            else -> if (style.mirrored) f.n * 0.25 + 0.1 else f.n * 0.75 - 0.1
        }
        return house(front, side, f.d, style.roof, style.walls, style.feature, seed, chimney, night, shut = room == null && style.feature != HouseFeature.BELL_TOWER)
    }

    private val sliceCache = HashMap<String, List<WorldArt.Obj>>()
    private val smokeCache = HashMap<String, List<Triple<Double, Double, Double>>>()

    /**
     * Where smoke leaves the chimneys of a town seen diagonally (5.1, Test 0.1.501: it rose from the old places):
     * map pixels of the ground point under each chimney's mouth, and the mouth's height in map pixels above it.
     */
    fun chimneyTops(map: MapDef): List<Triple<Double, Double, Double>> = synchronized(smokeCache) {
        smokeCache.getOrPut(map.id) {
            val T = WorldArt.T
            houses(map).mapNotNull { (f, draw) ->
                draw(false).chimneyTop?.let { (ci, cj, z) -> Triple((f.x + ci) * T, (f.top + cj) * T, z * ZS / 2) }
            }
        }
    }
    private val thingCache = HashMap<String, PixelImage>()
    private val glowCache = HashMap<Int, WorldArt.Glow>()

    /**
     * The upright pictures of a town's houses seen diagonally (5.1), or null for anything else: each house cut into
     * strips one tile of the diagonal wide, each sorted by the frontmost point of the house in it, so a figure stands
     * in front of a wall it is in front of and behind one it is behind.
     */
    /** Which of the three looks a thing of the village on ([tx], [ty]) has, as [objects] picks it (D29.4: its sun shadow). */
    fun look(tx: Int, ty: Int) = Math.floorMod(hash(tx, ty, 15), 3)

    fun objects(map: MapDef, tx: Int, ty: Int, freshNote: Boolean = false, barrierOpen: Boolean = false): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        fun fenceAt(x: Int, y: Int) = map.tile(x, y) == Tile.FENCE
        // the things on the square (5.2): one picture on the tile, its front corner at the foot, sorted like a figure there
        val v = look(tx, ty)
        // 80: Kael's lantern beside his door
        if (map.id == "village" && tx == KAEL_LANTERN.first && ty == KAEL_LANTERN.second) {
            val T = WorldArt.T
            val img = synchronized(sliceCache) { thingCache.getOrPut("kael_lantern") { kaelLantern() } }
            val glow = synchronized(sliceCache) { glowCache.getOrPut(-80) { kaelLanternGlow() } }.at(tx, ty)
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2, corner = true, glow = glow))
        }
        // 69e: the bridge lantern on the bank's corner by the south end of the bridge, its glass lit at night
        if (map.id == "village" && tx == BRIDGE_LANTERN.first && ty == BRIDGE_LANTERN.second) {
            val T = WorldArt.T
            val img = synchronized(sliceCache) { thingCache.getOrPut("bridge_lantern") { lamp(1, 527, ci = BL_I, cj = BL_J) } }
            val glow = synchronized(sliceCache) { glowCache.getOrPut(-69) { lampGlow(1, BL_I, BL_J) } }.at(tx, ty)
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            val depth = ((tx + 1 + BL_I + ty + 1 + BL_J) * T + T / 2 - 1).toInt()
            return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, depth - wx, 2, corner = true, glow = glow))
        }
        // 69e: the low railing along both sides of the bridge, in half-tile pieces so the hero walks before or behind each
        if (map.id == "village" && t == Tile.BRIDGE) {
            val T = WorldArt.T
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            val out = ArrayList<WorldArt.Obj>()
            for (west in listOf(true, false)) {
                if (map.tile(if (west) tx - 1 else tx + 1, ty) == Tile.BRIDGE) continue
                val north = map.tile(tx, ty - 1) != Tile.BRIDGE; val south = map.tile(tx, ty + 1) != Tile.BRIDGE
                for ((j0, j1) in listOf(-1.0 to -0.5, -0.5 to 0.0)) {
                    val p0 = j0 == -1.0 && north; val p1 = j1 == -0.5 || south
                    val img = synchronized(sliceCache) { thingCache.getOrPut("bridge_rail/$west/$j0/$p0/$p1") { bridgeRail(west, j0, j1, p0, p1, 611) } }
                    val i = if (west) -0.94 else -0.06
                    val depth = ((tx + 1 + i + ty + 1 + (j0 + j1) / 2) * T + T / 2 - 1).toInt()
                    out += WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, depth - wx, 2, low = true, corner = true)
                }
            }
            return out
        }
        // 5.5 (test 00:40: a light see-through column at the stall): the table, wares and poles stay solid like a counter,
        // only the cloth roof fades when the hero stands behind the stall; together the same picture as before
        if (t == Tile.STALL) {
            val T = WorldArt.T
            // D6.5: a stall over several tiles takes the look of its westmost tile and joins up
            val west = map.tile(tx - 1, ty) == Tile.STALL; val east = map.tile(tx + 1, ty) == Tile.STALL
            var x0 = tx; while (map.tile(x0 - 1, ty) == Tile.STALL) x0--
            val sv = Math.floorMod(hash(x0, ty, 15), 3)
            val ws = Math.floorMod(hash(tx, ty, 16), 7)
            val base = synchronized(sliceCache) { thingCache.getOrPut("stall/$sv/base/$west/$east/$ws") { cutTop(stall(sv, 501 + sv, false, west, east, 601 + ws)) } }
            val roof = synchronized(sliceCache) { thingCache.getOrPut("stall/$sv/roof/$west/$east") { stallCloth(sv, 501 + sv, west, east) } }
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            val sortY = (tx + ty) * T + T * 3 / 2 - 1 - wx
            return listOf(WorldArt.Obj(base, wx - base.width / 4, wy - base.height / 2, sortY, 2, low = true, corner = true),
                WorldArt.Obj(roof, wx - roof.width / 4, wy - roof.height / 2, sortY, 2, corner = true))
        }
        val thing: Pair<String, () -> PixelImage>? = when (t) {
            Tile.SIGN -> "sign/$v" to { signpost(v, 71) }
            Tile.NOTICE -> "notice/$v/$freshNote" to { noticeBoard(v, 561 + v, freshNote) }
            Tile.WELL -> "well/$v" to { well(v, 511 + v) }
            Tile.LAMP -> "lamp/$v" to { lamp(v, 521 + v) }
            Tile.BENCH -> "bench/$v" to { bench(v, 531 + v) }
            Tile.BARREL -> "barrel/$v" to { MapRoomIso.barrelOutside(v, 551 + v) }
            Tile.YARD -> yardKind(map, tx, ty).let { k -> "yard/$k/$v" to { yard(k, v, 641 + k * 3 + v) } }
            Tile.BARRIER -> (map.tile(tx - 1, ty) != Tile.BARRIER).let { pivot -> "barrier/$pivot/$barrierOpen" to { barrier(pivot, barrierOpen, 581) } }
            Tile.FENCE -> {
                // one look for a whole fence: the garden's or the posts beside the barrier, by its first tile
                val l = fenceAt(tx - 1, ty); val r = fenceAt(tx + 1, ty); val u = fenceAt(tx, ty - 1); val d = fenceAt(tx, ty + 1)
                val fv = fenceLook(map, tx, ty)
                val (mi, mj) = fenceSpot(map, tx, ty)
                "fence/$fv/$l$r$u$d/$mi/$mj" to { fence(fv, l, r, u, d, 591 + fv, mi, mj) }
            }
            else -> null
        }
        if (thing != null) {
            val T = WorldArt.T
            val img = synchronized(sliceCache) { thingCache.getOrPut(thing.first) { thing.second() } }
            val glow = if (t == Tile.LAMP) synchronized(sliceCache) { glowCache.getOrPut(v) { lampGlow(v) } }.at(tx, ty) else null
            val wx = (tx + 1) * T; val wy = (ty + 1) * T
            return listOf(WorldArt.Obj(img, wx - img.width / 4, wy - img.height / 2, (tx + ty) * T + T * 3 / 2 - 1 - wx, 2,
                t == Tile.BENCH || (t == Tile.YARD && yardKind(map, tx, ty) != 3), corner = true, glow = glow))
        }
        return houseObjects(map, tx, ty)
    }

    /**
     * The upright strips of the house standing on ([tx], [ty]), or null when no house is there; also for a lone hut
     * in the woods (D3.13, Morwen's).
     */
    fun houseObjects(map: MapDef, tx: Int, ty: Int): List<WorldArt.Obj>? {
        val t = map.tile(tx, ty)
        if (t in roofTiles) return emptyList()
        if (t !in wallTiles) return null
        if (tx > 0 && map.tile(tx - 1, ty) in wallTiles) return emptyList()
        val key = "${map.id}/$tx/$ty"
        synchronized(sliceCache) { sliceCache[key] }?.let { return it }
        var n = 0; while (map.tile(tx + n, ty) in wallTiles) n++
        var rows = 0; while (rows < 3 && (0 until n).all { map.tile(tx + it, ty - rows - 1) in roofTiles }) rows++
        val f = Footprint(tx, ty, n, rows + 1)
        val day = picture(map, f, false)
        val out = slices(day, f, litWindows(day.img, picture(map, f, true).img))
        synchronized(sliceCache) { sliceCache[key] = out }
        return out
    }

    /**
     * What shines of a house at night (25b): where its night picture differs from the day one, that is the lit panes of
     * its windows; all else clear. The day picture is drawn in the game, this over it, waking with the dusk.
     */
    fun litWindows(day: PixelImage, night: PixelImage): PixelImage {
        val out = PixelImage(day.width, day.height)
        for (i in day.pixels.indices) if (night.pixels[i] != day.pixels[i] && (night.pixels[i] ushr 24) != 0) out.pixels[i] = night.pixels[i]
        return out
    }

    /** [glow]: what shines at night, the same size as [pic], cut into the same strips. */
    private fun slices(pic: Picture, f: Footprint, glow: PixelImage? = null): List<WorldArt.Obj> {
        val T = WorldArt.T
        val img = pic.img
        val n = f.n; val d = f.d
        // every strip's foot lies on the same diagonal row in front of the whole house, so all strips share their bottom
        val s = n + d + 1
        val bottom = pic.oy + s * TH / 2
        val hh = (Math.ceil(bottom).toInt() + 1) / 2 * 2
        val out = mutableListOf<WorldArt.Obj>()
        val kMin = floor((0.5 - pic.ox) / (TW / 2)).toInt(); val kMax = floor((img.width - 0.5 - pic.ox) / (TW / 2)).toInt()
        for (k in kMin..kMax) {
            val c = k + 0.5
            val mid = (pic.ox + c * TW / 2).toInt()     // a whole pixel: ox lies on a half
            val strip = PixelImage(92, hh)
            val lit = PixelImage(92, hh)
            var any = false
            for (y in 0 until img.height) for (x in max(0, mid - 46) until min(img.width, mid + 46)) {
                // each strip reaches two pixels into its neighbours (D9.1): scaled by an odd zoom its edges are
                // smoothed and rounded, and the ground below showed through as a thin upright seam
                val u = x + 0.5 - pic.ox - k * TW / 2
                if (u < -2 || u >= TW / 2 + 2) continue
                val col = img[x, y]
                if (col ushr 24 == 0) continue
                strip.set(x - (mid - 46), y + (hh - Math.round(bottom).toInt()), col); any = true
                glow?.get(x, y)?.takeIf { it ushr 24 != 0 }?.let { lit.set(x - (mid - 46), y + (hh - Math.round(bottom).toInt()), it) }
            }
            if (!any) continue
            // the clear pixels around what is drawn take the colour beside them (D9.1): smoothed without it, the edge
            // took in their black and showed as a dark seam over the neighbour strip
            val edge = strip.pixels.copyOf()
            for (y in 0 until hh) for (x in 0 until 92) {
                if (strip.opaque(x, y)) continue
                val nb = listOf(strip[x - 1, y], strip[x + 1, y], strip[x, y - 1], strip[x, y + 1]).firstOrNull { it ushr 24 != 0 } ?: continue
                edge[y * 92 + x] = nb and 0xFFFFFF
            }
            edge.copyInto(strip.pixels)
            // drop the empty rows on top, so the strip's box (see-through test) holds only what is drawn
            var top = 0
            while (top < hh - 2 && (0 until 92).none { strip.opaque(it, top) }) top++
            top -= top % 2
            fun cut(p: PixelImage) = if (top == 0) p else PixelImage(92, hh - top).also { o -> for (y in 0 until hh - top) for (x in 0 until 92) o.set(x, y, p[x, y + top]) }
            val img2 = cut(strip)
            // the strip's lit panes, if any, with the middle of their light; a window glows softer around than a lamp
            val shining = lit.pixels.indices.filter { lit.pixels[it] ushr 24 != 0 }
            val glowOf = if (shining.isEmpty()) null else WorldArt.Glow(cut(lit), shining.sumOf { it % 92 } / shining.size,
                shining.sumOf { it / 92 } / shining.size - top, f.x, f.y, halo = 0.45f)
            // the foot: on this strip's middle line, on the row in front of the house; sorted by the frontmost point of the footprint on it
            val qi = (s + c) / 2; val qj = (s - c) / 2
            val cc = c.coerceIn(-d.toDouble(), n.toDouble())
            val pi = min(n.toDouble(), d + cc); val pj = pi - cc
            val wx = Math.round((f.x + qi) * T).toInt(); val wy = Math.round((f.top + qj) * T).toInt()
            val depth = ((f.x + f.top + pi + pj) * T).toInt() + T / 2 - 1
            out += WorldArt.Obj(img2, wx - 23, wy - img2.height / 2, depth - wx, 2, false, corner = true, group = 1 + f.x * 1000 + f.y, glow = glowOf, area = f)
        }
        return out
    }

    /** The sample sheet (ISODINGE=dorf): the village's houses by day and at night. */
    fun sheet(): List<Pair<String, List<PixelImage>>> {
        val map = de.bornim.core.World["village"]
        val all = houses(map).map { it.second }
        return all.chunked(3).flatMapIndexed { k, row ->
            listOf("Häuser ${k + 1}" to row.map { it(false).img }, "nachts ${k + 1}" to row.map { it(true).img })
        }
    }
}
