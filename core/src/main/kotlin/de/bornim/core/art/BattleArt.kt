package de.bornim.core.art

import de.bornim.core.MapKind

/** Battle backdrops in the same pixel style as the world. */
object BattleArt {
    /** Where the platforms sit, as fractions of the backdrop size. */
    const val ENEMY_X = 0.72f
    const val ENEMY_Y = 0.42f
    const val HERO_X = 0.28f
    const val HERO_Y = 0.95f

    private val cache = HashMap<String, PixelImage>()

    fun background(kind: MapKind, w: Int, h: Int): PixelImage = cache.getOrPut("$kind/$w/$h") {
        draw(w, h) { if (kind == MapKind.CAVE) cave() else outdoors(kind == MapKind.TOWN) }
    }

    private fun Pen.copy(src: PixelImage, ox: Int, oy: Int) {
        for (y in 0 until src.height) for (x in 0 until src.width) {
            val c = src[x, y]
            val a = c ushr 24
            if (a == 0) continue
            val tx = ox + x; val ty = oy + y
            if (tx !in 0 until img.width || ty !in 0 until img.height) continue
            raw(tx, ty, if (a == 255) c else mix(img[tx, ty], c or (0xFF shl 24), a / 255.0))
        }
    }

    private fun Pen.platform(fx: Float, fy: Float, rx: Double, ry: Double, top: Int, rim: Int, edge: Int) {
        val cx = img.width * fx.toDouble()
        val cy = img.height * fy.toDouble()
        ellipse(cx, cy + 2, rx + 1, ry + 1.5, mix(edge, Pal.OUTLINE, 0.5))
        ellipse(cx, cy + 1, rx, ry, edge)
        ellipse(cx, cy, rx, ry, rim)
        ellipse(cx, cy - 1, rx - 3, ry - 2, top)
    }

    private fun Pen.outdoors(town: Boolean) {
        val w = img.width; val h = img.height
        val horizon = (h * 0.30).toInt()
        // sky
        val skyTop = if (town) argb(0x8CC8F4) else argb(0x7EBEE8)
        val skyLow = argb(0xDCEFF4)
        for (y in 0 until horizon) {
            val c = mix(skyTop, skyLow, y.toDouble() / horizon)
            for (x in 0 until w) raw(x, y, c)
        }
        for ((cx, cy) in listOf(0.2 to 0.08, 0.62 to 0.05, 0.9 to 0.13)) {
            ellipse(w * cx, h * cy, 14.0, 4.5, Pal.WHITE)
            ellipse(w * cx + 8, h * cy - 3, 9.0, 4.0, Pal.WHITE)
        }
        // distant hills
        for (x in 0 until w) {
            val hill = (horizon - 10 + 6 * kotlin.math.sin(x / 17.0) + 3 * kotlin.math.sin(x / 7.0)).toInt()
            for (y in hill until horizon + 4) raw(x, y, argb(0x6AAE7C))
        }
        // ground: grass tiles
        val grass = (0 until 4).map { s -> draw(32, 32) { fill(argb(0x7CC85A)); for (y in 0 until 32) for (x in 0 until 32) { val n = noise(x, y, 11 + s) % 100; if (n < 6) raw(x, y, argb(0x5EAA44)) else if (n < 9) raw(x, y, argb(0x9ADC72)) } } }
        for (ty in horizon until h step 32) for (tx in 0 until w step 32) copy(grass[(tx / 32 + ty / 32) % 4], tx, ty)
        // tree line on the horizon
        var x = -10
        var i = 0
        while (x < w) {
            copy(WorldArt.tree(i % 4, i % 3 == 2), x, horizon - 38 + (i % 2) * 4)
            x += 20
            i++
        }
        val top = argb(0x8ED46A); val rim = argb(0x6AB050); val edge = argb(0x4A8838)
        platform(ENEMY_X, ENEMY_Y, w * 0.25, h * 0.055, top, rim, edge)
        platform(HERO_X, HERO_Y, w * 0.32, h * 0.075, top, rim, edge)
    }

    private fun Pen.cave() {
        val w = img.width; val h = img.height
        val wallBottom = (h * 0.30).toInt()
        // rock wall with strata and a few torches
        for (y in 0 until wallBottom) for (x in 0 until w) {
            val n = noise(x, y, 5) % 100
            raw(x, y, when {
                y % 13 == 0 && n < 70 -> argb(0x3A3028)
                n < 8 -> argb(0x4A3E34)
                n < 12 -> argb(0x7A6856)
                else -> argb(0x5E5044)
            })
        }
        for (y in 0 until wallBottom / 2) for (x in 0 until w) {
            val c = img[x, y]
            raw(x, y, mix(c, Pal.BLACK, 0.55 * (1 - y / (wallBottom / 2.0))))
        }
        for (x in 0 until w) { raw(x, wallBottom, argb(0x2A221C)); raw(x, wallBottom + 1, argb(0x2A221C)) }
        for (tx in listOf(w / 5, w * 4 / 5)) {
            rect(tx, wallBottom - 18, tx + 2, wallBottom - 8, Pal.WOOD_DARK)
            ellipse(tx + 1.5, wallBottom - 22.0, 3.0, 5.0, Pal.FIRE)
            ellipse(tx + 1.5, wallBottom - 21.0, 1.5, 2.5, Pal.FIRE_LIGHT)
        }
        // floor
        for (y in wallBottom + 2 until h) for (x in 0 until w) {
            val n = noise(x, y, 57) % 100
            raw(x, y, if (n < 6) argb(0x6E604C) else if (n < 9) argb(0x9A8A76) else argb(0x84745F))
        }
        for (y in wallBottom + 2 until wallBottom + 14) for (x in 0 until w) raw(x, y, mix(img[x, y], Pal.BLACK, 0.4 * (1 - (y - wallBottom) / 14.0)))
        val top = argb(0xA49482); val rim = argb(0x8A7A66); val edge = argb(0x5E5044)
        platform(ENEMY_X, ENEMY_Y, w * 0.25, h * 0.055, top, rim, edge)
        platform(HERO_X, HERO_Y, w * 0.32, h * 0.075, top, rim, edge)
    }
}
