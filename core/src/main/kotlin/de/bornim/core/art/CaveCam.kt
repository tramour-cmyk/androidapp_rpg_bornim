package de.bornim.core.art

import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * 211.13 (Chef 19.10., 23:13: „der Wald ist Vorlage, dann Höhle“): the cave drawn for the one camera ([FightCamera]), as
 * the wood is ([ForestCam]). The rock floor is worked out per pixel from where that pixel meets the ground; the back wall
 * of the cave stands [wall] metres ahead and rises past the top of the picture. The lights are points in the room (torches
 * on the wall, glowing fungus, a shaft of daylight from above, an embers' fire, the opening of the cave): each lights floor
 * and wall by how far it is and how the surface faces it, so the one camera sees one lit room.
 * Five places ([CaveScene.Spot]) and four lights ([CaveScene.Light]), like the old cave scenes.
 */
object CaveCam {
    private fun hash(i: Int, j: Int, s: Int): Double {
        var n = i * 374761393 + j * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        n = n xor (n ushr 16)
        return (n and 0xFFFFFF) / 16777215.0
    }

    private fun noise(x: Double, y: Double, s: Int): Double {
        val xi = floor(x).toInt(); val yi = floor(y).toInt()
        val fx = x - xi; val fy = y - yi
        val u = fx * fx * (3 - 2 * fx); val v = fy * fy * (3 - 2 * fy)
        val a = hash(xi, yi, s); val b = hash(xi + 1, yi, s); val c = hash(xi, yi + 1, s); val e = hash(xi + 1, yi + 1, s)
        return a + (b - a) * u + (c - a) * v + (a - b - c + e) * u * v
    }

    private fun fbm(x: Double, y: Double, s: Int) = 0.5 * noise(x, y, s) + 0.3 * noise(x * 2.1, y * 2.1, s + 7) + 0.2 * noise(x * 4.3, y * 4.3, s + 13)

    private val BAYER = intArrayOf(0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)

    /** A light in the room: where (across, up, ahead; metres), its colour, how far it reaches, how strong. */
    private class Lamp(val x: Double, val y: Double, val d: Double, val color: Int, val reach: Double, val power: Double)

    // the rock: cool grey-brown, the floor a little warmer, wet places darker
    private const val ROCK = 0x6E645A
    private const val FLOOR = 0x5E5248
    private const val WATER = 0x1E2A34

    /**
     * The cave seen by [cam]; [far] the furthest foe ([FightCamera]), the wall [wall] metres from the camera, [midX] and
     * [midD] the middle of the fight on the ground.
     */
    fun draw(cam: GroundCam, wall: Double, far: Double, midX: Double, midD: Double, spot: CaveScene.Spot, light: CaveScene.Light, seed: Int, night: Boolean = false): IntArray {
        val w = cam.w; val h = cam.h
        val img = IntArray(w * h)
        val flip = if (seed % 2 == 1) -1.0 else 1.0
        // the back wall winds and bulges; where the passage goes on (tunnel) or the opening is (entrance), it is open
        fun wallAt(x: Double) = wall + 0.8 * kotlin.math.sin(x * 0.6 + seed) + 1.1 * (noise(x * 0.4, 2.0, seed + 1) - 0.5)
        val holeX = midX + 1.6 * flip
        val holeW = if (spot == CaveScene.Spot.ENTRANCE) 2.2 else 1.2
        val holeH = if (spot == CaveScene.Spot.ENTRANCE) 3.2 else 2.2
        fun inHole(x: Double, y: Double): Boolean {
            if (spot != CaveScene.Spot.ENTRANCE && spot != CaveScene.Spot.TUNNEL) return false
            val u = (x - holeX) / holeW; val v = y / holeH
            return v < 1 && u * u + (max(0.0, v - 0.45) / 0.55).pow(2) < 1 + 0.12 * (noise(x * 3.0, y * 3.0, seed + 2) - 0.5)
        }
        val poolX = midX - 2.6 * flip; val poolD = far + 2.4
        fun inPool(x: Double, d: Double) = spot == CaveScene.Spot.POOL &&
            ((x - poolX) / 2.3).pow(2) + ((d - poolD) / 1.6).pow(2) + 0.2 * (noise(x * 1.5, d * 1.5, seed + 3) - 0.5) < 1

        // the lights
        val lamps = mutableListOf<Lamp>()
        var ambient = 0.22
        var ambientC = 0x3A3C4A
        val fireX = midX + 2.7 * flip; val fireD = far + 1.6
        when (light) {
            CaveScene.Light.TORCH -> {
                lamps += Lamp(midX - 2.6, 2.0, wallAt(midX - 2.6) - 0.25, 0xFFB060, 6.5, 1.25)
                lamps += Lamp(midX + 2.9, 2.1, wallAt(midX + 2.9) - 0.25, 0xFFB060, 6.5, 1.25)
                // the light the party carries, low and weak, near the camera
                lamps += Lamp(midX - 1.0, 1.6, midD - 4.5, 0xFFC890, 7.0, 0.45)
            }
            CaveScene.Light.GLOW -> {
                for (i in 0 until 4) lamps += Lamp(midX + (i - 1.5) * 2.4 + hash(i, 1, seed) - 0.5, 0.5 + 1.6 * hash(i, 2, seed), wallAt(midX + (i - 1.5) * 2.4) - 0.3, 0x5ADCC8, 4.5, 0.8)
                ambientC = 0x24404A; ambient = 0.24
            }
            CaveScene.Light.SHAFT -> {
                lamps += Lamp(midX + 0.6 * flip, 6.0, far + 1.0, 0xE8F0FF, 7.5, 1.7)
                ambientC = 0x46505E; ambient = 0.26
            }
            CaveScene.Light.DARK -> {
                lamps += Lamp(midX - 1.0, 1.6, midD - 4.5, 0xC8A880, 6.0, 0.55)
                ambient = 0.12
            }
        }
        if (spot == CaveScene.Spot.CAMP) lamps += Lamp(fireX, 0.4, fireD, 0xFF8A40, 5.0, 1.3)
        if (spot == CaveScene.Spot.ENTRANCE && !night) {
            lamps += Lamp(holeX, 1.8, wallAt(holeX) + 1.5, 0xF4F0E4, 10.0, 1.6)
            ambient += 0.06
        }

        /** the light falling on a point with its facing (nx, ny, nd), as a colour factor per channel */
        fun lit(x: Double, y: Double, d: Double, nx: Double, ny: Double, nd: Double): Triple<Double, Double, Double> {
            var r = ambient * (ambientC shr 16 and 255) / 64.0; var g = ambient * (ambientC shr 8 and 255) / 64.0; var b = ambient * (ambientC and 255) / 64.0
            for (l in lamps) {
                val lx = l.x - x; val ly = l.y - y; val ld = l.d - d
                val dist = sqrt(lx * lx + ly * ly + ld * ld).coerceAtLeast(0.2)
                val facing = ((lx * nx + ly * ny + ld * nd) / dist).coerceAtLeast(0.0) * 0.8 + 0.2
                val k = l.power * facing / (1 + (dist / l.reach).pow(2))
                r += k * (l.color shr 16 and 255) / 255.0; g += k * (l.color shr 8 and 255) / 255.0; b += k * (l.color and 255) / 255.0
            }
            return Triple(r, g, b)
        }
        fun shade(base: Int, l: Triple<Double, Double, Double>, v: Double, px: Int, py: Int): Int {
            // a few steps of light, dithered between, as the game's pixel art does
            val t = BAYER[(py and 3) * 4 + (px and 3)] / 16.0 - 0.5
            fun ch(c: Int, k: Double): Int {
                val q = c * k * v / 255.0 * 24
                return (floor(q + t * 0.9).coerceIn(0.0, 24.0) / 24 * 255).toInt().coerceIn(0, 255)
            }
            return (ch(base shr 16 and 255, l.first) shl 16) or (ch(base shr 8 and 255, l.second) shl 8) or ch(base and 255, l.third)
        }

        // floor and back wall: every pixel finds which it meets first
        for (py in 0 until h) for (px in 0 until w) {
            val dy = py + 0.5 - cam.hy
            val dFloor = if (dy > 0) cam.f * cam.eye / dy else Double.MAX_VALUE
            // the wall: two steps to where the ray meets it
            var dw = wall
            repeat(2) { dw = wallAt((px + 0.5 - cam.cx) * dw / cam.f) }
            val c: Int
            if (dFloor < dw) {
                val d = dFloor; val x = (px + 0.5 - cam.cx) * d / cam.f
                if (inPool(x, d)) {
                    // still black water, the lights in it as smeared streaks
                    var v = 0.6 + 0.25 * noise(x * 0.8, d * 5.0, seed + 4)
                    val l = lit(x, 0.0, d, 0.0, 1.0, 0.0)
                    c = shade(WATER, Triple(l.first * 1.4, l.second * 1.4, l.third * 1.6), v, px, py).let { cc ->
                        if (noise(x * 2.0, d * 12.0, seed + 5) > 0.82) mix(cc, 0x8AA0B0, 0.4 * l.first.coerceAtMost(1.0)) else cc
                    }
                } else {
                    // rock floor: slabs and grit, darker hollows, a few pebbles
                    var v = 0.75 + 0.4 * (fbm(x * 0.7, d * 0.7, seed + 6) - 0.5) + 0.2 * (noise(x * 6.0, d * 6.0, seed + 7) - 0.5)
                    if (noise(x * 1.9, d * 1.9, seed + 8) > 0.72) v -= 0.18
                    if (noise(x * 14.0, d * 14.0, seed + 9) > 0.86) v += 0.25
                    // the floor darkens towards the foot of the wall
                    v -= 0.25 * ((1.2 - (wallAt(x) - d)) / 1.2).coerceIn(0.0, 1.0)
                    var cc = shade(FLOOR, lit(x, 0.0, d, 0.0, 1.0, 0.0), v, px, py)
                    // a shaft of daylight from above falls on the floor in a bright patch
                    if (light == CaveScene.Light.SHAFT) {
                        val q = ((x - (midX + 0.6 * flip)) / 1.4).pow(2) + ((d - far - 1.0) / 1.1).pow(2)
                        if (q < 1) cc = mix(cc, 0xD8E0E8, 0.35 * (1 - q))
                    }
                    if (spot == CaveScene.Spot.CAMP) {
                        // the fire pit: a ring of stones round the embers
                        val q = ((x - fireX) / 0.55).pow(2) + ((d - fireD) / 0.45).pow(2)
                        if (q < 0.55) cc = mix(0x2A1A10, 0xFF7A20, (noise(x * 9.0, d * 9.0, seed + 10) * 1.3 - 0.2).coerceIn(0.0, 1.0))
                        else if (q < 1) cc = shade(0x8A8070, lit(x, 0.1, d, 0.0, 1.0, -0.5), 1.1 - 0.5 * noise(x * 8.0, d * 8.0, seed + 11), px, py)
                    }
                    c = cc
                }
            } else {
                val d = dw; val x = (px + 0.5 - cam.cx) * d / cam.f; val y = cam.yAt(py + 0.5, d)
                if (inHole(x, y)) {
                    c = if (spot == CaveScene.Spot.ENTRANCE && !night) {
                        // the opening: bright day outside, hazy green and sky
                        val v = (y / holeH).coerceIn(0.0, 1.0)
                        mix(mix(0x9AB070, 0xE8EEE4, v * 1.4), 0xF8F4E8, 0.3 * noise(x * 3.0, y * 3.0, seed + 12))
                    } else if (spot == CaveScene.Spot.ENTRANCE) mix(0x10182C, 0x2A3A5A, (y / holeH).coerceIn(0.0, 1.0))
                    else {
                        // the passage on: dark, the rim catches a little light
                        val u = abs(x - holeX) / holeW
                        mix(0x040406, shade(ROCK, lit(x, y, d, 0.0, 0.0, -1.0), 0.5, px, py), (u - 0.7).coerceIn(0.0, 0.3) * 2)
                    }
                } else {
                    // the wall: rough, in strata, its bumps lit from the side the light comes from
                    val n1 = fbm(x * 0.9, y * 0.9, seed + 13)
                    val e = 0.05
                    val gx = (fbm((x + e) * 0.9, y * 0.9, seed + 13) - n1) / e
                    val gy = (fbm(x * 0.9, (y + e) * 0.9, seed + 13) - n1) / e
                    val strata = 0.12 * kotlin.math.sin(y * 5.5 + 2.0 * noise(x * 0.5, y * 0.3, seed + 14))
                    val v = 0.8 + 0.45 * (n1 - 0.5) + strata + 0.15 * (noise(x * 7.0, y * 7.0, seed + 15) - 0.5)
                    var cc = shade(ROCK, lit(x, y, d, -gx * 0.6, -gy * 0.6, -1.0), v, px, py)
                    // glowing fungus in clusters on the wall
                    if (light == CaveScene.Light.GLOW && noise(x * 2.2, y * 2.2, seed + 16) > 0.78 && y < 2.5) cc = mix(cc, 0x7AF0DC, 0.7)
                    // wet streaks down the wall
                    if (noise(x * 4.0, 1.0, seed + 17) > 0.8) cc = mix(cc, 0x101418, 0.25)
                    c = cc
                }
            }
            img[py * w + px] = c
        }

        // what stands on the floor, far first: stalagmites, rocks; at the camp crates and a bedroll; torches on the wall
        class Thing(val d: Double, val draw: () -> Unit)
        val things = mutableListOf<Thing>()
        fun put(px: Int, py: Int, c: Int) { if (px in 0 until w && py in 0 until h) img[py * w + px] = c }
        fun cone(x: Double, d: Double, r: Double, hgt: Double, k: Int) = Thing(d) {
            val y0 = max(0, cam.sy(hgt, d).toInt()); val y1 = cam.sy(0.0, d).toInt()
            for (py in y0..y1) {
                val yy = cam.yAt(py + 0.5, d)
                val rr = r * (1 - yy / hgt).pow(0.8) * (1 + 0.08 * kotlin.math.sin(yy * 9 + k))
                val cxp = cam.sx(x, d); val hw = cam.f * rr / d
                for (px in (cxp - hw).toInt()..(cxp + hw).toInt()) {
                    val u = (px + 0.5 - cxp) / hw.coerceAtLeast(0.5)
                    if (abs(u) > 1) continue
                    // round, lit from the side its light comes from, with wet streaks running down and a darker foot
                    val streak = 0.18 * (noise(u * 6.0 + k, yy * 0.8, k + 3) - 0.5)
                    val v = 0.62 - 0.22 * u * u + streak + 0.12 * (noise(u * 3.0, yy * 4.0, k) - 0.5) - 0.15 * ((0.3 - yy) / 0.3).coerceIn(0.0, 1.0)
                    put(px, py, shade(ROCK, lit(x + u * rr, yy, d - rr, u, 0.0, -kotlin.math.sqrt((1 - u * u).coerceAtLeast(0.0))), v, px, py))
                }
            }
        }
        fun rock(x: Double, d: Double, r: Double, k: Int) = Thing(d) {
            val cxp = cam.sx(x, d); val cyp = cam.sy(r * 0.5, d); val rp = cam.f * r / d
            for (py in (cyp - rp * 0.7).toInt()..cam.sy(0.0, d).toInt()) for (px in (cxp - rp * 1.1).toInt()..(cxp + rp * 1.1).toInt()) {
                val u = (px + 0.5 - cxp) / rp; val v = (py + 0.5 - cyp) / (rp * 0.7)
                if (u * u + v * v * 0.8 > 1 + 0.25 * (noise(u * 2.5, v * 2.5, k) - 0.5)) continue
                put(px, py, shade(ROCK, lit(x + u * r, r * (0.5 - v * 0.5), d - 0.3, u, -v, -0.6), 0.8 + 0.2 * (noise(u * 5.0, v * 5.0, k + 1) - 0.5), px, py))
            }
        }
        fun crate(x: Double, d: Double, s: Double) = Thing(d) {
            val x0 = cam.sx(x - s / 2, d).toInt(); val x1 = cam.sx(x + s / 2, d).toInt()
            val y0 = cam.sy(s, d).toInt(); val y1 = cam.sy(0.0, d).toInt()
            val top = (cam.f * s * 0.35 / d).toInt()
            val l = lit(x, s / 2, d - s / 2, 0.0, 0.3, -1.0)
            for (py in y0 - top..y1) for (px in x0..x1) {
                val face = py >= y0
                val plank = if (face) ((py - y0) * 4 / (y1 - y0 + 1)) % 2 == 0 else true
                put(px, py, shade(if (face) 0x7A5A38 else 0x9A7A50, l, if (plank) 0.9 else 0.7, px, py))
            }
        }
        fun torch(x: Double, y: Double, d: Double) = Thing(d) {
            val cxp = cam.sx(x, d).toInt(); val cyp = cam.sy(y, d).toInt(); val s = (cam.f * 0.12 / d).toInt().coerceAtLeast(2)
            for (py in cyp..cyp + 3 * s) put(cxp, py, 0x3A2A1C)
            for (py in cyp - 2 * s..cyp) for (px in cxp - s / 2 - 1..cxp + s / 2 + 1) {
                val t = (cyp - py).toDouble() / (2 * s)
                if (abs(px - cxp) > (1 - t) * (s / 2 + 1)) continue
                put(px, py, mix(0xFFF0A0, 0xE85A18, t))
            }
        }

        var k = seed * 31
        fun rnd() = hash(k++, 23, seed)
        // stalagmites at the sides and behind, never on the places of the fight
        for (i in 0 until 14) {
            val d = far + 0.8 + (wall - far - 0.8) * rnd()
            val side = if (rnd() < 0.5) -1 else 1
            val x = midX + side * (2.6 + 3.0 * rnd()) + (d - midD) * 0.5
            if (d > wallAt(x) - 0.3) continue
            things += cone(x, d, 0.18 + 0.25 * rnd(), 0.6 + 1.6 * rnd(), i)
        }
        // in the hall two great columns, from floor to roof, framing the fight
        if (spot == CaveScene.Spot.HALL) for (sx in listOf(-1, 1)) {
            val x = midX + sx * 3.4; val d = far + 1.4 + rnd()
            things += cone(x, d, 0.55, 30.0, 90 + sx)
        }
        for (i in 0 until 7) {
            val d = far + 0.5 + (wall - far) * rnd()
            val x = midX + (if (rnd() < 0.5) -1 else 1) * (2.4 + 3.5 * rnd())
            if (d < wallAt(x) - 0.4) things += rock(x, d, 0.15 + 0.35 * rnd(), 40 + i)
        }
        if (spot == CaveScene.Spot.CAMP) {
            things += crate(fireX + 1.3 * flip, fireD + 1.2, 0.6); things += crate(fireX + 1.8 * flip, fireD + 0.4, 0.5)
            things += rock(fireX - 0.9 * flip, fireD + 1.4, 0.3, 70)
        }
        if (light == CaveScene.Light.TORCH) for (l in lamps.take(2)) things += torch(l.x, l.y, l.d)
        for (t in things.sortedByDescending { it.d }) t.draw()
        // a shaft of daylight: a pale veil from the top of the picture to the patch on the floor
        if (light == CaveScene.Light.SHAFT) {
            val (bx, bd) = (midX + 0.6 * flip) to (far + 1.0)
            val footX = cam.sx(bx, bd); val footY = cam.sy(0.0, bd); val rw = cam.f * 1.3 / bd
            for (py in 0 until footY.toInt().coerceAtMost(h)) {
                val t = py / footY
                val cxp = footX + (1 - t) * rw * 0.8
                for (px in (cxp - rw).toInt()..(cxp + rw).toInt()) if (px in 0 until w) {
                    val u = abs(px - cxp) / rw
                    if (u < 1) img[py * w + px] = mix(img[py * w + px], 0xE8F0FF, 0.16 * (1 - u * u) * (0.6 + 0.4 * noise(px * 0.15, py * 0.02, seed + 18)))
                }
            }
        }
        // at night the opening shows no day, and the whole cave lies a little darker
        if (night) for (i in img.indices) img[i] = mix(0, img[i], 0.8)
        return img
    }
}
