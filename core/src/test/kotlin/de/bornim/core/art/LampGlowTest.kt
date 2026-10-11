package de.bornim.core.art

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertTrue

/** 25.1, 25b: a street lamp's glass shines at night: brighter than its glass by day, only where the glass is, light in the middle. */
class LampGlowTest {
    private fun lum(c: Int) = 0.3 * ((c shr 16) and 0xFF) + 0.59 * ((c shr 8) and 0xFF) + 0.11 * (c and 0xFF)

    @Test
    fun theGlassShinesAtNight() {
        for (v in 0 until 3) {
            val day = MapTownIso.lamp(v, 521 + v)
            val glow = MapTownIso.lampGlow(v)
            val lit = glow.img.pixels.indices.filter { (glow.img.pixels[it] ushr 24) > 0 }
            assertTrue(lit.size in 20..600, "look $v: ${lit.size} shining pixels")
            // every shining pixel lies on the lamp, and is brighter than the lamp there by day
            for (i in lit) {
                assertTrue((day.pixels[i] ushr 24) > 0, "look $v: shines where there is no lamp")
                assertTrue(lum(glow.img.pixels[i]) > lum(day.pixels[i]) + 30, "look $v: glass at night not brighter than by day")
            }
            val gain = lit.sumOf { lum(glow.img.pixels[it]) - lum(day.pixels[it]) } / lit.size
            assertTrue(gain > 70, "look $v: glass at night only $gain brighter on average")
            // the middle of the light lies within the shining glass
            val xs = lit.map { it % glow.img.width }; val ys = lit.map { it / glow.img.width }
            assertTrue(glow.cx in xs.min()..xs.max() && glow.cy in ys.min()..ys.max(), "look $v: middle of the light off the glass")
        }
    }

    @Test
    fun litWindowsShineOnTheHouses() {
        val village = World["village"]
        var houses = 0
        for (y in 0 until village.height) for (x in 0 until village.width) {
            val strips = MapTownIso.objects(village, x, y) ?: continue
            if (village.tile(x, y) == Tile.LAMP || strips.isEmpty()) continue
            val glows = strips.mapNotNull { o -> o.glow?.let { o to it } }
            if (glows.isEmpty()) continue
            houses++
            for ((o, g) in glows) {
                val lit = g.img.pixels.indices.filter { (g.img.pixels[it] ushr 24) != 0 }
                assertTrue(lit.isNotEmpty() && g.img.width == o.img.width && g.img.height == o.img.height, "house at $x,$y: glow fits its strip")
                // only on the house, on the window glass, which is brighter at night than by day
                for (i in lit) assertTrue((o.img.pixels[i] ushr 24) != 0, "house at $x,$y: shines off the house")
                assertTrue(lit.sumOf { lum(g.img.pixels[it]) - lum(o.img.pixels[it]) } / lit.size > 40, "house at $x,$y: windows not brighter at night")
            }
        }
        assertTrue(houses >= 4, "lit windows on only $houses houses")
    }
}
