package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Cave battle scenes in the new style. Unlike the forest, a cave lives from its light: every
 * surface is drawn as a colour plus a facing (normal), and lamps — torches, glowing fungi, a crack
 * of daylight, a camp fire, the hero's lantern — light it afterwards. Shades are stepped with a
 * dither so it stays pixel art. Coordinates are art pixels; laid out by fractions like the forest.
 */
object CaveScene {
    /** Kinds of places underground. */
    enum class Spot { ENTRANCE, TUNNEL, HALL, POOL, CAMP }

    /** What lights the place. */
    enum class Light { TORCH, GLOW, SHAFT, DARK }

    private val cache = object : LinkedHashMap<String, PixelImage>(8, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 6
    }

    /**
     * The kind of place for a fight at ([x], [y]) on [map]: near the way out the cave mouth, near
     * a fire a camp, near water a pool, in narrow passages a tunnel, otherwise a hall or a pool.
     */
    fun spotFor(map: MapDef, x: Int, y: Int): Spot {
        fun near(r: Int, test: (Tile) -> Boolean) = (-r..r).any { dy -> (-r..r).any { dx -> test(map.tile(x + dx, y + dy)) } }
        if (near(3) { it == Tile.CAVE_EXIT || it == Tile.CAVE_ENTRANCE }) return Spot.ENTRANCE
        if (near(3) { it == Tile.CAMPFIRE }) return Spot.CAMP
        if (near(3) { it == Tile.WATER }) return Spot.POOL
        var open = 0
        for (dy in -2..2) for (dx in -2..2) if (map.tile(x + dx, y + dy).walkable) open++
        if (open < 13) return Spot.TUNNEL
        return if (hash(x / 4, y / 4, map.id.hashCode()) % 100 < 70) Spot.HALL else Spot.POOL
    }

    /** What lights the place: torches on the walls nearby, a fire in a camp, otherwise it varies by area. */
    fun lightFor(map: MapDef, x: Int, y: Int, spot: Spot): Light {
        if (spot == Spot.CAMP) return Light.DARK
        if ((-4..4).any { dy -> (-4..4).any { dx -> map.tile(x + dx, y + dy) == Tile.TORCH } }) return Light.TORCH
        val h = hash(x / 3, y / 3, map.id.hashCode() + 7) % 100
        return when {
            spot == Spot.ENTRANCE -> if (h < 60) Light.TORCH else Light.SHAFT
            h < 45 -> Light.TORCH
            h < 72 -> Light.GLOW
            h < 90 -> Light.SHAFT
            else -> Light.DARK
        }
    }

    /** The colour monsters and the hero are multiplied with, so they stand in the same light as the place. */
    fun tint(spot: Spot, light: Light, night: Boolean = false): Int = when {
        spot == Spot.ENTRANCE && light != Light.DARK && !night -> 0xFFF0E8DC.toInt()
        spot == Spot.CAMP && light == Light.DARK -> 0xFFE0A880.toInt()
        light == Light.TORCH -> 0xFFF4CCA8.toInt()
        light == Light.GLOW -> 0xFFA8D8D4.toInt()
        light == Light.SHAFT -> 0xFFD8E0EC.toInt()
        else -> 0xFFB09884.toInt()
    }

    fun cave(w: Int, h: Int, spot: Spot, light: Light, seed: Int, night: Boolean = false): PixelImage {
        val key = "$w/$h/$spot/$light/$seed/$night"
        synchronized(cache) { cache[key]?.let { return it } }
        val img = Painter(w, h, spot, light, seed, night).paint()
        synchronized(cache) { cache[key] = img }
        return img
    }

    // ---------------------------------------------------------------- noise helpers

    private fun hash(x: Int, y: Int, s: Int): Int {
        var n = x * 374761393 + y * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }

    private fun rnd(x: Int, y: Int, s: Int) = (hash(x, y, s) % 10000) / 10000.0

    private fun noise(x: Double, y: Double, s: Int): Double {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        val fx = x - ix; val fy = y - iy
        val u = fx * fx * (3 - 2 * fx); val v = fy * fy * (3 - 2 * fy)
        val a = rnd(ix, iy, s) * (1 - u) + rnd(ix + 1, iy, s) * u
        val b = rnd(ix, iy + 1, s) * (1 - u) + rnd(ix + 1, iy + 1, s) * u
        return a * (1 - v) + b * v
    }

    private fun fbm(x: Double, y: Double, s: Int) = noise(x, y, s) * 0.55 + noise(x * 2.1, y * 2.1, s + 1) * 0.3 + noise(x * 4.3, y * 4.3, s + 2) * 0.15

    private val bayer = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)
    private fun dith(x: Int, y: Int) = bayer[(y and 3) * 4 + (x and 3)] / 16.0

    private fun r(c: Int) = (c shr 16) and 0xFF
    private fun g(c: Int) = (c shr 8) and 0xFF
    private fun b(c: Int) = c and 0xFF

    /** A light: where it is, its colour, how far it reaches and how strong it is; [lift] is its height above the surface. */
    private class Lamp(val x: Double, val y: Double, val color: Int, val reach: Double, val power: Double, val lift: Double = 26.0)

    private class Painter(val w: Int, val h: Int, val spot: Spot, val light: Light, val seed: Int, val night: Boolean) {
        val horizon = (h * if (spot == Spot.HALL) 0.43 else 0.42).toInt()
        val flip = seed % 2 == 1

        // surface buffers: colour, facing, how hidden from light (crevices), mirror for wet floors
        val alb = IntArray(w * h)
        val nx = DoubleArray(w * h)
        val ny = DoubleArray(w * h)
        val ao = DoubleArray(w * h) { 1.0 }
        val wet = DoubleArray(w * h)
        val emis = IntArray(w * h)
        val emisA = DoubleArray(w * h)
        val lamps = mutableListOf<Lamp>()
        var ambient = argb(0x1A1C26)
        val mirror = BooleanArray(w * h)
        var shoreY = 0

        fun fx(f: Double) = (if (flip) 1 - f else f) * w
        fun gy(d: Double) = horizon + (h - horizon) * d
        fun depth(y: Int) = ((y - horizon) / (h - horizon).toDouble()).coerceIn(0.0, 1.0)
        fun inside(x: Int, y: Int) = x in 0 until w && y in 0 until h

        fun put(x: Int, y: Int, c: Int, nX: Double = 0.0, nY: Double = 0.0, occl: Double = 1.0) {
            if (!inside(x, y)) return
            val i = y * w + x
            alb[i] = c; nx[i] = nX; ny[i] = nY; ao[i] = occl; wet[i] = 0.0
        }

        fun glow(x: Int, y: Int, c: Int, a: Double) {
            if (!inside(x, y)) return
            val i = y * w + x
            if (a > emisA[i]) { emis[i] = c; emisA[i] = a.coerceIn(0.0, 1.0) }
        }

        // palette: cold grey-brown stone, darker below
        val rockLit = argb(0x8A8278)
        val rockMid = argb(0x5E574F)
        val rockDark = argb(0x3A342F)
        val floorFar = argb(0x6A6258)
        val floorNear = argb(0x4A433C)
        val moss = argb(0x4E6A34)

        fun paint(): PixelImage {
            setLights()
            backWall()
            when (spot) {
                Spot.ENTRANCE -> mouth(daylight = true)
                Spot.HALL -> mouth(daylight = false, big = true)
                Spot.TUNNEL, Spot.CAMP, Spot.POOL -> mouth(daylight = false)
            }
            ceiling()
            floor()
            when (spot) {
                Spot.POOL -> lake()
                Spot.HALL -> pillars()
                Spot.TUNNEL -> beams()
                Spot.CAMP -> camp()
                Spot.ENTRANCE -> mossAndLeaves()
            }
            stalagmites()
            boulders()
            when (light) {
                Light.TORCH -> torches()
                Light.GLOW -> fungi()
                Light.SHAFT -> crack()
                Light.DARK -> {}
            }
            frameRocks()
            val img = shade()
            reflect(img)
            if (light == Light.SHAFT) beam(img)
            if (spot == Spot.ENTRANCE && !night) spill(img)
            dust(img)
            vignette(img)
            return img
        }

        // ------------------------------------------------------------ lights

        fun setLights() {
            ambient = when (light) {
                Light.DARK -> argb(0x0E1018)
                Light.GLOW -> argb(0x0A1218)
                Light.SHAFT -> argb(0x161A22)
                Light.TORCH -> argb(0x15131A)
            }
            // a soft light where the fight happens, so foe and hero are never in the black
            val fightLight = when (light) {
                Light.TORCH -> argb(0xFFB070)
                Light.GLOW -> argb(0x60C8D0)
                Light.SHAFT -> argb(0xD8E4FF)
                Light.DARK -> argb(0xFFC890)
            }
            lamps += Lamp(w * 0.63, h * 0.60, fightLight, w * 0.3, if (light == Light.DARK) 0.35 else 0.45, 40.0)
            when (light) {
                Light.TORCH -> {
                    lamps += Lamp(fx(0.13), h * 0.36, argb(0xFFA050), w * 0.42, 1.25)
                    lamps += Lamp(fx(0.84), h * 0.27, argb(0xFF9C48), w * 0.34, 1.0)
                }
                Light.GLOW -> {}
                Light.SHAFT -> lamps += Lamp(w * 0.6, h * 0.58, argb(0xE8F0FF), w * 0.36, 1.25, 70.0)
                // the hero's lantern
                Light.DARK -> lamps += Lamp(w * 0.28, h * 0.9, argb(0xFFB868), w * 0.5, 1.2, 30.0)
            }
            if (spot == Spot.ENTRANCE) lamps += if (night) Lamp(fx(0.42), horizon - h * 0.08, argb(0x8A9CC8), w * 0.5, 0.7, 50.0) else Lamp(fx(0.42), horizon - h * 0.08, argb(0xF0F4E8), w * 0.62, 1.15, 50.0)
            if (spot == Spot.CAMP) lamps += Lamp(w * 0.17, gy(0.1) - 6, argb(0xFF9440), w * 0.4, 1.35, 16.0)
        }

        /** Brightness at a surface point from all lamps, as an RGB multiplier (1.0 = full colour). */
        fun lightAt(x: Int, y: Int, i: Int): DoubleArray {
            val out = doubleArrayOf(r(ambient) / 64.0, g(ambient) / 64.0, b(ambient) / 64.0)
            val n1 = nx[i]; val n2 = ny[i]
            val nz = sqrt((1 - n1 * n1 - n2 * n2).coerceAtLeast(0.05))
            val onFloor = y > horizon
            for (l in lamps) {
                val dx = l.x - x
                val dy = (l.y - y) * (if (onFloor) 1.9 else 1.0)
                val dist = sqrt(dx * dx + dy * dy)
                val fall = exp(-(dist / l.reach).pow(1.7)) * l.power
                if (fall < 0.004) continue
                val len = sqrt(dx * dx + (l.y - y) * (l.y - y) + l.lift * l.lift)
                val lambert = ((n1 * dx + n2 * (l.y - y) + nz * l.lift) / len)
                val wrap = ((lambert + 0.25) / 1.25).coerceAtLeast(0.0)
                val k = fall * wrap
                out[0] += r(l.color) / 255.0 * k; out[1] += g(l.color) / 255.0 * k; out[2] += b(l.color) / 255.0 * k
            }
            return out
        }

        fun shade(): PixelImage {
            val img = PixelImage(w, h)
            for (y in 0 until h) for (x in 0 until w) {
                val i = y * w + x
                val l = lightAt(x, y, i)
                val occl = ao[i]
                var lr = l[0] * occl; var lg = l[1] * occl; var lb = l[2] * occl
                // stepped brightness: keep the hue, snap the strength to a few levels with a dither
                val peak = max(lr, max(lg, lb)).coerceAtLeast(1e-4)
                val steps = 9.0
                val q = floor(peak.coerceAtMost(1.6) * steps + dith(x, y) - 0.25).coerceAtLeast(0.0) / steps
                val k = if (wet[i] > 0) 1.0 else q / peak
                lr *= k; lg *= k; lb *= k
                val c = alb[i]
                var cr = r(c) * lr; var cg = g(c) * lg; var cb = b(c) * lb
                // wet stone and water mirror the lamps
                if (wet[i] > 0) {
                    val m = wet[i] * 0.55
                    cr += 255 * l[0] * m * 0.6; cg += 255 * l[1] * m * 0.6; cb += 255 * l[2] * m * 0.6
                }
                // overbright light washes towards white
                val over = (max(cr, max(cg, cb)) - 255).coerceAtLeast(0.0) * 0.5
                var out = (0xFF shl 24) or ((cr + over).toInt().coerceIn(0, 255) shl 16) or ((cg + over).toInt().coerceIn(0, 255) shl 8) or (cb + over).toInt().coerceIn(0, 255)
                if (emisA[i] > 0) out = mix(out, emis[i], emisA[i])
                img.set(x, y, out)
            }
            return img
        }

        // ------------------------------------------------------------ rock

        /** Bumpy rock with layers: colour and facing from a height field. */
        fun rockAt(x: Int, y: Int, s: Int, scale: Double = 1.0, base: Int = rockMid): Triple<Int, Double, Double> {
            fun height(xx: Double, yy: Double) = fbm(xx / (13 * scale), yy / (8 * scale), s) + 0.5 * sin(yy / (6.5 * scale) + fbm(xx / 40.0, yy / 30.0, s + 5) * 7).let { it * it * it }
            val hx = height(x + 1.0, y.toDouble()) - height(x - 1.0, y.toDouble())
            val hy = height(x.toDouble(), y + 1.0) - height(x.toDouble(), y - 1.0)
            val k = 2.4 / scale
            var n1 = -hx * k; var n2 = -hy * k
            val len = sqrt(n1 * n1 + n2 * n2 + 1)
            n1 /= len; n2 /= len
            val band = fbm(x / 60.0, y / 7.0, s + 9)
            var c = if (band > 0.55) mix(base, rockLit, (band - 0.55) * 1.4) else mix(base, rockDark, (0.55 - band) * 1.2)
            if (rnd(x / 2, y / 2, s + 3) < 0.05) c = mix(c, rockDark, 0.5)
            return Triple(c, n1, n2)
        }

        /** 0..1: how deep in a crack a point is, for thin dark fissures. */
        fun crackAt(x: Int, y: Int, s: Int): Double {
            val v = abs(noise(x / 34.0 + noise(y / 20.0, x / 40.0, s) * 2.5, y / 38.0, s + 7) - 0.5)
            return (1 - v / 0.012).coerceIn(0.0, 1.0)
        }

        fun backWall() {
            for (y in 0 until horizon + 6) for (x in 0 until w) {
                val (c, n1, n2) = rockAt(x, y, 11 + seed)
                // the wall bends away near the top, into the ceiling
                val up = (1 - y / (horizon * 0.55)).coerceIn(0.0, 1.0)
                val cr = crackAt(x, y, 13 + seed)
                put(x, y, mix(c, rockDark, up * 0.5), n1, n2 + up * 0.6, (1 - cr * 0.85) * (1 - up * 0.45))
            }
        }

        /** The way on: a dark opening in the back wall, or the bright mouth of the cave. */
        fun mouth(daylight: Boolean, big: Boolean = false) {
            val cx = fx(if (spot == Spot.TUNNEL) 0.5 else 0.38)
            val rx = w * (if (big) 0.17 else if (daylight) 0.2 else 0.11)
            val ry = h * (if (big) 0.17 else if (daylight) 0.19 else 0.1)
            val baseY = horizon + 2.0
            val cy = baseY - ry * 0.55
            for (y in (cy - ry - 4).toInt()..baseY.toInt() + 2) for (x in (cx - rx - 6).toInt()..(cx + rx + 6).toInt()) {
                if (!inside(x, y)) continue
                val wob = 1 + 0.12 * (fbm(x / 9.0, y / 9.0, 31 + seed) - 0.5) * 2
                val dx = (x - cx) / rx; val dy = (y - cy) / ry
                val q = (dx * dx + dy * dy) / (wob * wob)
                if (y > baseY) continue
                if (q < 1) {
                    val i = y * w + x
                    if (daylight) {
                        // outside: pale sky over a green treeline, a strip of meadow
                        val t = (y - (cy - ry)) / (ry * 1.55)
                        val treeTop = cy - ry * 0.1 + 6 * noise(x / 6.0, 0.0, 33 + seed) + 4 * noise(x / 2.5, 1.0, 34)
                        val col = when {
                            night && y > baseY - 5 -> argb(0x1A2A2C)
                            night && y > treeTop -> mix(argb(0x0C141E), argb(0x162232), noise(x / 3.0, y / 3.0, 35))
                            night -> if (rnd(x, y, 36) < 0.025) argb(0xC8D0F0) else mix(argb(0x2E3A5A), argb(0x0A1024), (1 - t).coerceIn(0.0, 1.0))
                            y > baseY - 5 -> mix(argb(0x8CB060), argb(0x5E8A44), (baseY - y) / 5.0)
                            y > treeTop -> mix(argb(0x3E6A44), argb(0x5E8C58), noise(x / 3.0, y / 3.0, 35))
                            else -> mix(argb(0xE8F0F0), argb(0xB8D0E4), (1 - t).coerceIn(0.0, 1.0))
                        }
                        glow(x, y, col, 1.0)
                        alb[i] = col
                    } else {
                        // the passage recedes: darker towards the middle
                        val d = sqrt(q)
                        val (c, n1, n2) = rockAt(x, y, 61 + seed, 0.6)
                        put(x, y, mix(c, rockDark, 0.4), -n1 * 0.6 - dx * 0.5, n2 * 0.6 - dy * 0.4, (d - 0.15).coerceIn(0.0, 1.0).pow(1.8) * 0.7)
                    }
                } else if (q < 1.35) {
                    // a rim of rock catching the light around the opening
                    val (c, _, _) = rockAt(x, y, 62 + seed)
                    put(x, y, mix(c, rockLit, 0.25), dx * 0.55, dy * 0.45, 1.0)
                }
            }
        }

        fun ceiling() {
            val count = if (spot == Spot.HALL) 26 else 16
            for (i in 0 until count) {
                val cx = rnd(i, 1, 21 + seed) * w
                val len = (if (spot == Spot.HALL) 12.0 else 8.0) + rnd(i, 2, 21 + seed).pow(2) * (if (spot == Spot.HALL) 70.0 else 48.0)
                val top = -2.0 + rnd(i, 4, 21 + seed) * 10
                val half = 2.0 + len * 0.13
                cone(cx, top, len, half, down = true, s = 22 + i + seed)
            }
        }

        /** A stalactite (pointing down) or a stalagmite (pointing up), rounded and wet at the tip. */
        fun cone(cx: Double, base: Double, len: Double, half: Double, down: Boolean, s: Int, color: Int = rockMid) {
            for (k in 0..len.toInt()) {
                val t = k / len
                val y = (if (down) base + k else base - k).toInt()
                val wdt = half * (1 - t).pow(0.8) + 0.4
                val sway = sin(t * 3 + s) * 1.2
                for (x in (cx + sway - wdt).toInt()..(cx + sway + wdt).toInt()) {
                    val u = ((x - cx - sway) / wdt).coerceIn(-1.0, 1.0)
                    val ring = if (sin(k * 1.3 + s) > 0.6) 0.1 else 0.0
                    val c = mix(mix(color, rockLit, ring + (rnd(x, y, s) - 0.5) * 0.2), rockDark, t * 0.2)
                    put(x, y, c, u * 0.85, if (down) 0.2 else -0.25, 1.0)
                    if (t > 0.8 && inside(x, y)) wet[y * w + x] = 0.5
                }
            }
        }

        // ------------------------------------------------------------ floor

        /** Distance to the nearest and second nearest of jittered points: flat stone plates with seams. */
        fun plates(u: Double, v: Double, sd: Int): Triple<Double, Double, Int> {
            val iu = floor(u).toInt(); val iv = floor(v).toInt()
            var d1 = 9.0; var d2 = 9.0; var id = 0
            for (j in -1..1) for (i in -1..1) {
                val px = iu + i + rnd(iu + i, iv + j, sd); val py = iv + j + rnd(iu + i, iv + j, sd + 1)
                val d = sqrt((u - px).pow(2) + (v - py).pow(2))
                if (d < d1) { d2 = d1; d1 = d; id = hash(iu + i, iv + j, sd) } else if (d < d2) d2 = d
            }
            return Triple(d1, d2, id)
        }

        fun floor() {
            for (y in horizon + 1 until h) {
                val d = depth(y)
                for (x in 0 until w) {
                    // plates get bigger towards the viewer and are squashed by the perspective
                    val u = x / (10.0 + d * 44) + noise(x / 9.0, y / 5.0, 47) * 0.25
                    val v = (y - horizon) / (2.6 + d * 15.0)
                    val (d1, d2, id) = plates(u, v, 41 + seed)
                    val seam = ((d2 - d1) / 0.09).coerceIn(0.0, 1.0)
                    var c = mix(floorFar, floorNear, d)
                    c = mix(c, if (id % 3 == 0) rockLit else rockDark, (id % 7) / 7.0 * 0.35)
                    val grain = noise(x / 2.0, y / 2.0, 46)
                    c = mix(c, if (grain > 0.5) rockLit else rockDark, abs(grain - 0.5) * 0.4)
                    // each plate tilts a little; its edges round off into the seam
                    val tilt = (id % 11 - 5) / 18.0
                    val n2 = -0.75 + (1 - seam) * 0.35
                    put(x, y, c, tilt, n2, 0.62 + 0.38 * seam)
                }
            }
            // where the wall meets the floor: a dark seam and a ledge of rubble
            for (y in horizon - 6 until horizon + 12) for (x in 0 until w) if (inside(x, y)) ao[y * w + x] *= 0.5 + 0.5 * (abs(y - horizon - 1) / 11.0).coerceAtMost(1.0)
            for (i in 0 until w / 5) {
                val x = rnd(i, 1, 57 + seed) * w; val y = horizon + 1 + rnd(i, 2, 57 + seed) * 4
                val rr = 2.0 + rnd(i, 3, 57 + seed) * 4.5
                for (yy in (-rr).toInt()..0) for (xx in (-rr * 1.3).toInt()..(rr * 1.3).toInt()) {
                    val uu = xx / (rr * 1.3); val vv = yy / rr
                    if (uu * uu + vv * vv > 1) continue
                    put((x + xx).toInt(), (y + yy).toInt(), mix(rockMid, rockLit, 0.15 + rnd(i, 4, 57) * 0.3), uu * 0.8, vv * 0.8 - 0.2, 1.0)
                }
            }
            puddles()
            gravel()
        }

        fun puddles() {
            val spots = listOf(0.2 to 0.5, 0.8 to 0.72, 0.45 to 0.2, 0.9 to 0.32)
            for ((k, s) in spots.withIndex()) {
                if (rnd(k, 1, 51 + seed) < 0.3) continue
                val cx = fx(s.first); val cy = gy(s.second)
                val d = s.second
                // keep the space where foe and hero stand clear
                if (abs(cx - w * 0.63) < w * 0.16 && abs(cy - h * 0.6) < 14) continue
                val rx = 10 + d * 32; val ry = 2 + d * 6
                for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
                    val q = ((x - cx) / rx).pow(2) + ((y - cy) / ry).pow(2) * (1 + 0.3 * sin(x / 4.0))
                    if (q > 1 || !inside(x, y)) continue
                    put(x, y, argb(0x141A22), 0.0, -0.9, 1.0)
                    wet[y * w + x] = if (noise(x / 8.0, y * 1.5, 52) > 0.65) 1.2 else 0.5
                }
            }
        }

        fun gravel() {
            for (i in 0 until w * h / 650) {
                val y = horizon + 3 + ((h - horizon - 4) * rnd(i, 1, 55 + seed).pow(0.8)).toInt()
                val x = (rnd(i, 2, 55 + seed) * w).toInt()
                val d = depth(y)
                val rr = 0.6 + d * 3.6 * (0.3 + rnd(i, 3, 55).pow(2) * 1.2)
                if (abs(x - w * 0.63) < w * 0.12 && abs(y - h * 0.6) < 6) continue
                for (yy in (-rr).toInt()..1) for (xx in (-rr * 1.4).toInt()..(rr * 1.4).toInt()) {
                    val u = xx / (rr * 1.4); val v = yy / rr
                    if (u * u + v * v > 1) continue
                    put(x + xx, y + yy, mix(rockMid, rockLit, 0.3 + rnd(i, 4, 55) * 0.4), u * 0.8, v * 0.7 - 0.3, 1.0)
                }
                // contact shadow
                for (xx in (-rr * 1.4).toInt()..(rr * 1.4).toInt()) if (inside(x + xx, y + 2)) ao[(y + 2) * w + x + xx] *= 0.6
            }
        }

        /** Fallen rocks along the sides, away from where foe and hero stand. */
        fun boulders() {
            for (k in 0 until 7) {
                val left = k % 2 == 0
                val d = 0.08 + rnd(k, 1, 211 + seed) * 0.55
                val x = if (left) w * (0.04 + rnd(k, 2, 211 + seed) * 0.14) else w * (0.86 + rnd(k, 2, 211 + seed) * 0.12)
                val by = gy(d); val rr = 4 + d * 14 * (0.6 + rnd(k, 3, 211 + seed) * 0.6)
                for (y in (by - rr * 1.3).toInt()..by.toInt()) for (xx in (x - rr * 1.3).toInt()..(x + rr * 1.3).toInt()) {
                    val u = (xx - x) / (rr * 1.3); val v = (y - (by - rr * 0.6)) / (rr * 0.75)
                    val wob = 1 + 0.18 * sin(kotlin.math.atan2(v, u) * 3 + k)
                    if (u * u + v * v > wob) continue
                    val (c, n1, n2) = rockAt(xx, y, 212 + k, 0.8)
                    put(xx, y, c, u * 0.7 + n1 * 0.3, v * 0.6 - 0.25 + n2 * 0.3, 1.0)
                }
                for (xx in (x - rr * 1.3).toInt()..(x + rr * 1.3).toInt()) if (inside(xx, by.toInt() + 1)) ao[(by.toInt() + 1) * w + xx] *= 0.5
            }
        }

        fun stalagmites() {
            val list = listOf(0.06 to 0.06, 0.16 to 0.12, 0.92 to 0.08, 0.83 to 0.03, 0.3 to 0.02, 0.97 to 0.2)
            for ((k, s) in list.withIndex()) {
                if (rnd(k, 1, 71 + seed) < 0.25) continue
                val d = s.second
                val len = (14 + rnd(k, 2, 71 + seed) * 22) * (0.8 + d * 3)
                cone(fx(s.first), gy(d), len, 3 + len * 0.22, down = false, s = 72 + k + seed)
            }
        }

        // ------------------------------------------------------------ places

        fun lake() {
            val cx = fx(0.27); val cy = gy(0.06)
            val rx = w * 0.36; val ry = (h - horizon) * 0.1
            shoreY = (cy - ry).toInt()
            for (y in (cy - ry).toInt()..(cy + ry + 2).toInt()) for (x in (cx - rx - 4).toInt()..(cx + rx + 4).toInt()) {
                val q = ((x - cx) / (rx * (1 + 0.1 * sin(x / 7.0 + seed)))).pow(2) + ((y - cy) / ry).pow(2)
                if (q > 1.2 || !inside(x, y)) continue
                if (q > 1) { put(x, y, mix(floorFar, rockDark, 0.4), 0.0, -0.8, 0.9); wet[y * w + x] = 0.4; continue }
                put(x, y, argb(0x0E1A22), 0.0, -0.95, 1.0)
                mirror[y * w + x] = true
                // ripples catch more light
                if (noise(x / 10.0, y * 1.7, 83 + seed) > 0.68) wet[y * w + x] = 1.5 else wet[y * w + x] = 0.7
            }
            cone(cx - rx * 0.4, cy + 2, 26.0, 5.0, down = false, s = 81 + seed)
            cone(cx + rx * 0.3, cy + 1, 16.0, 3.5, down = false, s = 82 + seed)
        }

        fun pillars() {
            for ((k, f) in listOf(0.12, 0.88, 0.62).withIndex()) {
                val cx = fx(f)
                val baseY = gy(if (k == 2) 0.0 else 0.03)
                val half = if (k == 2) 7.0 else 11.0
                for (y in 0..baseY.toInt()) {
                    val t = y / baseY
                    // narrow waist where stalactite and stalagmite met
                    val waist = 1 - 0.45 * exp(-((t - 0.55) / 0.18).pow(2))
                    val flare = 1 + 0.9 * (t - 0.8).coerceAtLeast(0.0) * 5 + 0.6 * (0.15 - t).coerceAtLeast(0.0) * 6
                    val half2 = half * waist * flare
                    for (x in (cx - half2).toInt()..(cx + half2).toInt()) {
                        val u = ((x - cx) / half2).coerceIn(-1.0, 1.0)
                        val ring = if (sin(y / 3.0 + k) > 0.7) 0.12 else 0.0
                        val (c, _, _) = rockAt(x, y, 91 + k + seed, 0.7)
                        put(x, y, mix(c, rockLit, ring), u * 0.9, 0.0, if (k == 2) 0.75 else 1.0)
                    }
                }
            }
        }

        /** Old wooden supports: somebody dug here once. */
        fun beams() {
            val wood = argb(0x6A4A30)
            val l = fx(0.31); val rr = fx(0.69)
            val top = horizon - h * 0.19
            val base = gy(0.02)
            for (x0 in listOf(l, rr)) for (y in top.toInt()..base.toInt()) for (x in (x0 - 3).toInt()..(x0 + 3).toInt()) {
                val u = (x - x0) / 3.0
                val grain = if (rnd(x, y / 4, 101) < 0.15) 0.25 else 0.0
                put(x, y, mix(wood, Pal.BLACK, grain), u * 0.8, 0.0, 1.0)
            }
            for (y in (top - 4).toInt()..top.toInt() + 2) for (x in (min(l, rr) - 6).toInt()..(max(l, rr) + 6).toInt()) {
                val v = (y - top + 1) / 3.0
                put(x, y, mix(wood, Pal.BLACK, if (rnd(x / 5, y, 102) < 0.12) 0.3 else 0.0), 0.0, v.coerceIn(-1.0, 1.0) * 0.8, 1.0)
            }
        }

        fun camp() {
            // fire ring with logs and the glow of embers
            val cx = w * 0.17; val cy = gy(0.1)
            for (k in 0 until 9) {
                val a = k / 9.0 * 2 * PI
                val sx = cx + cos(a) * 11; val sy = cy + sin(a) * 3.2
                for (yy in -2..1) for (xx in -2..2) if (xx * xx + yy * yy * 2 <= 5) put((sx + xx).toInt(), (sy + yy).toInt(), rockMid, xx * 0.4, yy * 0.4 - 0.3, 1.0)
            }
            for ((k, a) in listOf(-0.5, 0.45, -0.15, 0.2).withIndex()) for (t in -6..6) {
                val x = (cx + t * 0.9).toInt(); val y = (cy - 1 + t * a - k * 0.5).toInt()
                put(x, y, argb(0x3A2418), 0.0, -0.5, 1.0); put(x, y - 1, argb(0x5A3A26), 0.0, -0.9, 1.0)
            }
            // glowing embers under the flames
            for (t in -6..6) for (yy in -1..1) glow((cx + t).toInt(), (cy + yy).toInt(), if (rnd(t, yy, 116) < 0.4) argb(0xFFC040) else argb(0xC83A10), 0.8)
            flame(cx, cy - 2, 14.0, 1.0)
            // crates and a sack on the other side, a bedroll and some bones
            crate(w * 0.86, gy(0.04), 11.0)
            crate(w * 0.92, gy(0.07), 9.0)
            crate(w * 0.87, gy(0.04) - 11, 8.0)
            val bx = w * 0.34; val by = gy(0.03)
            for (y in (by - 2).toInt()..(by + 2).toInt()) for (x in (bx - 12).toInt()..(bx + 12).toInt()) put(x, y, argb(0x6A5038), 0.0, -0.8 + (y - by) * 0.1, 1.0)
            for (k in 0 until 4) {
                val x0 = w * (0.08 + k * 0.05); val y0 = gy(0.3 + rnd(k, 1, 111) * 0.08)
                for (t in -3..3) put((x0 + t).toInt(), (y0 + t * (if (k % 2 == 0) 0.4 else -0.4)).toInt(), argb(0xD8D0BC), 0.0, -0.7, 1.0)
            }
        }

        fun crate(cx: Double, by: Double, s: Double) {
            val wood = argb(0x7A5634)
            for (y in (by - s).toInt()..by.toInt()) for (x in (cx - s * 0.6).toInt()..(cx + s * 0.6).toInt()) {
                val front = x < cx + s * 0.25
                val edge = abs(x - cx) > s * 0.5 || y < by - s + 2 || y > by - 2 || abs(x - (cx - s * 0.6) - (by - y)) < 1.2
                put(x, y, mix(wood, Pal.BLACK, if (edge) 0.35 else 0.0), if (front) 0.0 else 0.8, 0.0, 1.0)
            }
            for (y in (by - s - 3).toInt()..(by - s).toInt()) for (x in (cx - s * 0.6 + 2).toInt()..(cx + s * 0.6 + 2).toInt()) put(x, y, mix(wood, Pal.WHITE, 0.1), 0.0, -0.9, 1.0)
        }

        fun mossAndLeaves() {
            for (y in 0 until h) for (x in 0 until w) {
                val i = y * w + x
                val near = exp(-((x - fx(0.38)) / (w * 0.32)).pow(2) - ((y - horizon) / (h * 0.25)).pow(2))
                if (near > 0.25 && noise(x / 5.0, y / 4.0, 121 + seed) < near * 0.7 && ny[i] < 0.1) alb[i] = mix(alb[i], moss, 0.7)
            }
            for (k in 0 until 40) {
                val x = (rnd(k, 1, 123 + seed) * w).toInt(); val y = (horizon + 6 + rnd(k, 2, 123 + seed).pow(1.5) * (h - horizon) * 0.6).toInt()
                val c = listOf(argb(0x8A5A26), argb(0xA87A30), argb(0x6A4A22))[k % 3]
                for (xx in 0..1 + (depth(y) * 2).toInt()) put(x + xx, y, c, 0.0, -0.8, 1.0)
            }
        }

        // ------------------------------------------------------------ light sources

        fun flame(cx: Double, by: Double, size: Double, power: Double) {
            for (y in (by - size * 1.8).toInt()..by.toInt()) for (x in (cx - size).toInt()..(cx + size).toInt()) {
                val t = (by - y) / (size * 1.8)
                val half = size * 0.55 * (1 - t).pow(0.7) * (0.8 + 0.4 * noise(y / 2.0, x / 3.0, 131))
                val u = abs(x - cx - sin(t * 5) * size * 0.15) / half.coerceAtLeast(0.1)
                if (u > 1) continue
                val c = when {
                    u < 0.35 && t < 0.55 -> argb(0xFFF4C8)
                    u < 0.7 && t < 0.75 -> argb(0xFFB040)
                    else -> argb(0xE0581C)
                }
                glow(x, y, c, power)
            }
            // a warm haze around the flame
            for (y in (by - size * 3).toInt()..(by + size).toInt()) for (x in (cx - size * 2.5).toInt()..(cx + size * 2.5).toInt()) {
                val d = sqrt(((x - cx) / (size * 2.5)).pow(2) + ((y - by + size) / (size * 2.4)).pow(2))
                if (d < 1) glow(x, y, argb(0xFF9A40), (1 - d) * 0.35 * power)
            }
        }

        fun torches() {
            for ((f, y) in listOf(0.13 to 0.36, 0.84 to 0.27)) {
                val cx = fx(f); val ty = h * y
                // iron bracket and a wooden handle
                for (k in 0 until 14) for (t in 0..1) put(cx.toInt() + t, (ty + 4 + k).toInt(), argb(0x5A3E26), t * 0.6, 0.0, 1.0)
                for (k in -3..4) for (t in 0..1) put((cx + k).toInt(), (ty + 9 + t).toInt(), argb(0x4A4A52), 0.0, -0.6 + t, 1.0)
                flame(cx, ty + 4, 7.5, 1.0)
            }
        }

        fun fungi() {
            val spots = listOf(0.06 to 0.1, 0.12 to 0.38, 0.9 to 0.2, 0.95 to 0.55, 0.38 to 0.04, 0.78 to 0.06, 0.25 to 0.78)
            for ((k, s) in spots.withIndex()) {
                val cx = fx(s.first); val cy = gy(s.second)
                val cyan = k % 3 != 2
                val col = if (cyan) argb(0x7AF0E0) else argb(0xB890FF)
                lamps += Lamp(cx, cy - 4, col, w * 0.13, 0.95, 12.0)
                if (cyan) for (m in 0 until 6) {
                    val x = cx + (rnd(k, m, 141) - 0.5) * 18; val y = cy - rnd(k, m + 9, 141) * 4
                    val sz = 1.5 + rnd(k, m + 20, 141) * (2 + s.second * 4)
                    for (q in 0 until (sz * 1.3).toInt()) glow(x.toInt(), (y - q).toInt(), argb(0xC8F4E8), 0.6)
                    for (yy in -sz.toInt()..0) for (xx in (-sz).toInt()..sz.toInt()) if (xx * xx + yy * yy * 3 <= sz * sz)
                        glow((x + xx).toInt(), (y - sz * 1.3 + yy).toInt(), if (yy < -sz * 0.4) argb(0xE8FFF8) else col, 0.95)
                } else for (m in 0 until 5) {
                    // crystals: shards fanning out of the rock, a lit face and a dark one
                    val ang = -PI / 2 + (m - 2) * 0.38 + (rnd(k, m, 144) - 0.5) * 0.2
                    val len = 6 + rnd(k, m, 142) * (6 + s.second * 18) * (if (m == 2) 1.5 else 1.0)
                    val wd = 1.5 + len * 0.12
                    val x0 = cx + (m - 2) * 2.5
                    for (q in 0 until len.toInt()) {
                        val t = q / len
                        val half = wd * (if (t > 0.7) (1 - t) / 0.3 else 1.0)
                        for (o in (-half).toInt()..half.toInt()) {
                            val x = x0 + cos(ang) * q - sin(ang) * o
                            val y = cy + sin(ang) * q + cos(ang) * o
                            glow(x.toInt(), y.toInt(), if (o < 0) argb(0xF4ECFF) else if (o == 0) col else mix(col, argb(0x3A2060), 0.45), 0.97)
                        }
                    }
                }
            }
            // spores drifting in the cold light
            for (k in 0 until 30) glow((rnd(k, 1, 143) * w).toInt(), (h * 0.15 + rnd(k, 2, 143) * h * 0.7).toInt(), argb(0xA8FFF0), 0.75)
        }

        /** A crack in the ceiling with a sliver of sky. */
        fun crack() {
            var x = w * 0.53
            for (y in 0 until 22) {
                x += (rnd(y, 1, 201) - 0.45) * 2.4
                val half = 2.6 * (1 - y / 22.0) + 0.5
                for (xx in (x - half).toInt()..(x + half).toInt()) glow(xx, y, if (abs(xx - x) < half * 0.5) argb(0xFFFFFF) else argb(0xC8D8F0), 1.0)
                // the rim of the crack catches the light
                for (xx in listOf((x - half - 1).toInt(), (x + half + 1).toInt())) glow(xx, y, argb(0x8A9AB0), 0.6)
            }
        }

        // ------------------------------------------------------------ framing

        fun frameRocks() {
            for (side in listOf(-1, 1)) {
                val sd = 151 + side + seed
                for (y in 0 until h) {
                    val bulge = 6 + 22 * noise(y / 34.0, 0.0, sd).pow(1.5) + 8 * noise(y / 9.0, 3.0, sd) + 14 * exp(-((y - h * (if (side < 0) 0.12 else 0.3)) / 40.0).pow(2)) + (if (y > h * 0.82) (y - h * 0.82) * 0.4 else 0.0)
                    for (dx in 0 until bulge.toInt() + 1) {
                        val x = if (side < 0) dx else w - 1 - dx
                        val edge = dx / bulge
                        val (c, n1, n2) = rockAt(x, y, sd, 1.4, rockDark)
                        // the rock faces the middle of the cave towards its edge
                        put(x, y, c, -side * edge.pow(2) * 0.85 + n1 * 0.5, n2 * 0.5, 0.85)
                    }
                }
            }
            // big stalactites hanging into the picture from above
            for ((k, f) in listOf(0.2, 0.47, 0.78).withIndex()) {
                val len = 24.0 + rnd(k, 1, 161 + seed) * 30
                cone(w * f + (rnd(k, 2, 161 + seed) - 0.5) * 20, -4.0, len, 6.0 + len * 0.15, down = true, s = 162 + k, color = rockDark)
            }
            // rubble at the bottom corners
            for ((k, f) in listOf(0.04, 0.14, 0.9, 0.98).withIndex()) {
                val cx = w * f; val by = h + 6.0; val rr = 14.0 + rnd(k, 1, 171) * 10
                for (y in (by - rr * 1.2).toInt()..by.toInt()) for (x in (cx - rr * 1.3).toInt()..(cx + rr * 1.3).toInt()) {
                    val u = (x - cx) / (rr * 1.3); val v = (y - (by - rr * 0.5)) / (rr * 0.8)
                    if (u * u + v * v > 1) continue
                    val (c, _, _) = rockAt(x, y, 172 + k, 1.2, rockDark)
                    put(x, y, c, u * 0.7, v * 0.6 - 0.2, 0.85)
                }
            }
        }

        // ------------------------------------------------------------ effects over the shaded picture

        /** Still water mirrors the cave above it, broken by ripples. */
        fun reflect(img: PixelImage) {
            for (y in 0 until h) for (x in 0 until w) {
                if (!mirror[y * w + x]) continue
                val wave = (sin(y * 1.9 + noise(x / 6.0, y.toDouble(), 85) * 4) * 1.5).toInt()
                val my = 2 * shoreY - y - 1
                val above = img[x + wave, my.coerceIn(0, h - 1)]
                img.set(x, y, mix(img[x, y], mix(above, argb(0x10303A), 0.35), 0.6))
            }
        }

        fun beam(img: PixelImage) {
            // a slanted shaft of light from the crack down to the fight
            val x0 = w * 0.54; val x1 = w * 0.62
            val y1 = h * 0.6
            for (y in 0 until y1.toInt() + 8) {
                val t = y / y1
                val cx = x0 + (x1 - x0) * t
                val half = 5 + t * w * 0.11
                for (x in (cx - half).toInt()..(cx + half).toInt()) {
                    if (!inside(x, y)) continue
                    val u = abs(x - cx) / half
                    if (u >= 1) continue
                    val a = (1 - u).pow(1.3) * 0.22 * (0.6 + 0.4 * noise(x / 6.0 - y / 9.0, 0.0, 181))
                    img.set(x, y, mix(img[x, y], argb(0xE8F0FF), a))
                }
            }
            // dust dancing in the shaft
            for (k in 0 until 26) {
                val t = rnd(k, 1, 182)
                val x = (x0 + (x1 - x0) * t + (rnd(k, 2, 182) - 0.5) * (8 + t * w * 0.18)).toInt()
                val y = (t * y1).toInt()
                if (inside(x, y)) img.set(x, y, mix(img[x, y], Pal.WHITE, 0.7))
            }
        }

        fun spill(img: PixelImage) {
            // daylight falls in through the mouth and lies on the floor before it
            val cx = fx(0.38)
            for (y in horizon until h) for (x in 0 until w) {
                val d = depth(y)
                val half = w * (0.2 + d * 0.35)
                val u = abs(x - cx - (if (flip) -1 else 1) * d * w * 0.18) / half
                if (u < 1) img.set(x, y, mix(img[x, y], argb(0xF4F0D8), (1 - u).pow(1.5) * 0.18 * (1 - d * 0.6)))
            }
        }

        fun dust(img: PixelImage) {
            if (light == Light.DARK) return
            // drops falling from the ceiling, caught by the light
            for (k in 0 until 6) {
                val x = (rnd(k, 1, 191 + seed) * w).toInt(); val y = (rnd(k, 2, 191 + seed) * horizon).toInt()
                for (q in 0..1) if (inside(x, y + q)) img.set(x, y + q, mix(img[x, y + q], argb(0xC8D8E8), 0.55 - q * 0.2))
            }
        }

        fun vignette(img: PixelImage) {
            val strength = if (light == Light.DARK) 0.85 else 0.6
            for (y in 0 until h) for (x in 0 until w) {
                val dx = (x - w / 2.0) / (w / 2.0); val dy = (y - h * 0.58) / (h * 0.6)
                val v = ((dx * dx + dy * dy) - 0.45).coerceAtLeast(0.0) * 0.55
                if (v > 0) img.set(x, y, mix(img[x, y], argb(0x05060A), v.coerceAtMost(strength)))
            }
        }
    }
}
