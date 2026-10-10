package de.bornim.core.art

import kotlin.math.cos
import kotlin.math.sin

/**
 * The furniture of the rooms painted with [Sculpt], the way the gear, the foes and the things of the
 * cave are made (10.10., 6.14): bodies with real curvature, wood with grain, iron with a dull sheen,
 * clay, glass and cloth, all of it used, worn, dusty and stained. Every thing in three looks
 * (preview RAUMDINGE=1). Sizes and anchors match the former pictures of [MapRoom].
 */
object RoomThings {
    private fun hash(a: Int, b: Int, s: Int): Int {
        var n = a * 374761393 + b * 668265263 + s * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7FFFFFFF
    }
    private fun rnd(a: Int, b: Int, s: Int) = (hash(a, b, s) % 10000) / 10000.0

    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0, sat: Double = 1.0, value: Double = 1.0, bias: Double = 0.0, inline: Boolean = true) =
        Mat(Ramp.of(argb(rgb), sat = sat, value = value), shine, grain, bias, inline)

    // the inn's oak: dark with smoke, paler where hands and elbows have worn it
    private val oak = m(0x5A4030, grain = 0.16, sat = 0.95, value = 0.8)
    private val oakTop = m(0x6A4A32, grain = 0.12, sat = 0.98, value = 0.8, bias = -0.3)
    private val oakDark = m(0x3A2A1E, grain = 0.16, sat = 0.9, value = 0.9)
    private val oakBack = m(0x2E241C, grain = 0.18, sat = 0.7, bias = -0.08)
    // firewood: grey-brown bark, pale cut ends with rings, fresh split faces
    private val bark = m(0x463424, grain = 0.26, sat = 0.85, value = 0.75)
    private val barkBirch = m(0x7A7466, grain = 0.3, sat = 0.35, value = 0.8, bias = -0.08)
    private val endGrain = m(0xA08058, grain = 0.16, sat = 0.85, value = 0.85)
    private val splitFace = m(0x8A6C48, grain = 0.3, sat = 0.85, value = 0.85)
    // iron, pewter, clay, glass, wax, cloth, bread
    private val iron = m(0x3E3A36, shine = 0.35, grain = 0.25, sat = 0.5)
    private val rust = m(0x5A3E2C, shine = 0.12, grain = 0.35, sat = 0.75, value = 0.85)
    private val pewter = m(0x76726A, shine = 0.5, grain = 0.15, sat = 0.3, value = 0.9)
    private val clay = m(0x7A4E34, shine = 0.1, grain = 0.18, sat = 0.78, value = 0.9)
    private val clayPale = m(0x8E7A5E, shine = 0.08, grain = 0.2, sat = 0.55, value = 0.85)
    private val clayGlaze = m(0x4E5A4E, shine = 0.45, grain = 0.12, sat = 0.6, value = 0.85)
    private val glass = m(0x34463C, shine = 0.75, grain = 0.06, sat = 0.7, value = 0.9)
    private val glassBrown = m(0x4A3222, shine = 0.7, grain = 0.06, sat = 0.75, value = 0.9)
    private val wax = m(0xC4B494, shine = 0.15, grain = 0.1, sat = 0.55, value = 0.92)
    private val linen = m(0x6E5E44, grain = 0.26, sat = 0.62, value = 0.74)
    private val linenDark = m(0x5A4C38, grain = 0.32, sat = 0.62)
    private val wool = m(0x6A3A2E, grain = 0.34, sat = 0.7, value = 0.8)
    private val herbs = m(0x4A5236, grain = 0.45, sat = 0.6, value = 0.85)
    private val bread = m(0x9A7040, grain = 0.3, sat = 0.82, value = 0.9)
    private val rope = m(0x7A6A48, grain = 0.3, sat = 0.6)

    private val hole = argb(0x140E0A)
    private val crack = argb(0x261C14)
    private val outlineColor = argb(0x0E0C0A)
    private val ale = argb(0x2A1A0E)
    private val flameHot = argb(0xFFF0B0)
    private val flame = argb(0xF0B050)
    private val cobweb = argb(0x8A8478)

    private val cache = HashMap<String, MapRoom.Sprite>()
    private fun cached(key: String, make: () -> MapRoom.Sprite): MapRoom.Sprite =
        synchronized(cache) { cache[key] } ?: make().also { synchronized(cache) { cache[key] = it } }

    /** Outline, then a soft shadow on the floor where the picture is still empty. */
    private fun done(s: Sculpt, ax: Int, ay: Int, shadow: (PixelImage) -> Unit = {}): MapRoom.Sprite {
        s.outline(outlineColor)
        shadow(s.img)
        return MapRoom.Sprite(s.img, ax, ay)
    }

    private fun floorShadow(img: PixelImage, cx: Double, cy: Double, rx: Double, ry: Double, a: Int = 0x8C) {
        for (y in (cy - ry).toInt()..(cy + ry).toInt()) for (x in (cx - rx).toInt()..(cx + rx).toInt()) {
            val nx = (x + 0.5 - cx) / rx; val ny = (y + 0.5 - cy) / ry; val d = nx * nx + ny * ny
            if (d > 1 || img.opaque(x, y) || x !in 0 until img.width || y !in 0 until img.height) continue
            img.set(x, y, (((a * (1 - d) * (1 - d * 0.5)).toInt().coerceIn(0, 255)) shl 24) or 0x0A0806)
        }
    }

    /** A flat ellipse facing ([tiltX], [tiltY]) with a rounded rim: cut ends, lids, the tops of blocks. */
    private fun disc(s: Sculpt, x: Double, y: Double, rx: Double, ry: Double, mat: Mat, tiltX: Double = 0.0, tiltY: Double = 0.0, bevel: Double = 1.0) {
        val pts = DoubleArray(32)
        for (j in 0 until 16) { val a = j * Math.PI / 8; pts[j * 2] = x + cos(a) * rx; pts[j * 2 + 1] = y + sin(a) * ry }
        s.poly(mat, *pts, tiltX = tiltX, tiltY = tiltY, bevel = bevel)
    }

    // ------------------------------------------------------------------ small things

    /** A tankard of pewter or wood with a handle, ale in it (or empty, [full] false). */
    private fun tankard(s: Sculpt, x: Double, y: Double, wood: Boolean, full: Boolean = true) {
        val mat = if (wood) oak else pewter
        s.limb(x + 3.0, y - 5.5, x + 4.6, y - 3.5, 1.0, 0.9, mat)
        s.limb(x + 4.6, y - 3.5, x + 3.0, y - 1.6, 0.9, 0.9, mat)
        s.limb(x, y - 1.2, x, y - 6.5, 2.7, 2.5, mat)
        if (wood) { s.line(x - 2.0, y - 2.2, x + 2.0, y - 2.2, crack); s.line(x - 2.0, y - 5.4, x + 2.0, y - 5.4, crack) }
        s.flat(x, y - 6.8, 2.2, 0.9, if (full) ale else hole)
    }

    /** A tankard knocked over, ale spreading from its mouth across the wood. */
    private fun tipped(s: Sculpt, x: Double, y: Double) {
        s.tint(x + 7.0, y - 0.5, 7.0, 2.2, ale, 0.75)
        s.limb(x - 3.0, y - 2.0, x + 3.0, y - 1.6, 2.4, 2.4, pewter)
        s.flat(x + 3.6, y - 1.7, 0.9, 2.0, hole)
    }

    private fun bowl(s: Sculpt, x: Double, y: Double, stew: Boolean) {
        s.blob(x, y - 1.6, 6.2, 2.8, clay, depth = 0.5)
        s.flat(x - 0.3, y - 2.6, 4.4, 1.5, if (stew) argb(0x4A2E1A) else argb(0x2E2016))
        if (stew) s.dot(x + 1.0, y - 2.8, argb(0x7A5A30))
    }

    private fun loaf(s: Sculpt, x: Double, y: Double, cut: Boolean) {
        s.blob(x, y - 2.4, 5.6, 3.2, bread, depth = 0.8)
        s.line(x - 3.0, y - 3.6, x - 1.0, y - 1.8, argb(0x6A4624))
        s.line(x, y - 4.0, x + 2.0, y - 2.0, argb(0x6A4624))
        if (cut) s.blob(x + 5.2, y - 2.2, 1.4, 2.8, m(0xC8AC7A, grain = 0.3, sat = 0.6), depth = 0.3)
    }

    private fun candle(s: Sculpt, x: Double, y: Double, tall: Double) {
        s.blob(x, y - 0.8, 3.2, 1.3, iron, depth = 0.3)
        s.limb(x, y - 1.2, x, y - tall, 1.3, 1.1, wax)
        s.line(x + 1.0, y - tall + 0.5, x + 1.2, y - tall + 3.5, argb(0xA89878))      // a run of wax
        s.flat(x, y - tall - 2.2, 0.9, 2.0, flame)
        s.dot(x, y - tall - 1.6, flameHot)
    }

    private fun jug(s: Sculpt, x: Double, y: Double) {
        s.limb(x + 4.6, y - 9.0, x + 5.4, y - 4.6, 0.9, 0.9, clay)
        s.blob(x, y - 4.8, 4.6, 4.8, clay)
        s.limb(x, y - 8.2, x, y - 11.4, 2.2, 1.9, clay)
        s.flat(x, y - 11.6, 1.6, 0.7, hole)
        s.limb(x - 2.0, y - 11.5, x - 3.2, y - 12.0, 0.7, 0.4, clay)                  // the lip
    }

    private fun knife(s: Sculpt, x: Double, y: Double) {
        s.poly(iron, x, y - 1.4, x + 9.0, y - 2.6, x + 9.6, y - 1.8, x, y - 0.4, tiltY = -0.6, bevel = 0.6)
        s.limb(x - 5.0, y - 0.6, x, y - 0.9, 1.0, 1.0, oakDark)
    }

    private fun crumbs(s: Sculpt, x: Double, y: Double, v: Int) {
        for (k in 0 until 8) s.dot(x + rnd(k, v, 57) * 12, y - rnd(k, v, 58) * 4, if (k % 3 == 0) argb(0x4A3420) else argb(0x7A5C38))
        s.blob(x + 4.0, y - 1.6, 2.6, 1.4, bread, depth = 0.5)
    }

    // ------------------------------------------------------------------ shelf

    /** One thing on a shelf board, standing on [y]; returns its width. */
    private fun shelfItem(s: Sculpt, x: Double, y: Double, kind: Int, seed: Int, lean: Double = 0.0): Double {
        val r = rnd(seed, kind, 1)
        return when (kind) {
            0 -> { // a stoneware jar with a cloth tied over its mouth
                val h = 9 + r * 4; val w = 3.4 + r
                s.limb(x + w, y - 1.5, x + w + lean, y - h, w, w * 0.85, if (seed % 2 == 0) clayPale else clayGlaze)
                s.blob(x + w + lean, y - h - 0.8, w * 0.95, 1.6, linen, depth = 0.5)
                s.line(x + 0.6 + lean, y - h + 0.6, x + w * 2 - 0.6 + lean, y - h + 0.6, argb(0x3A2E20))
                w * 2 + 1.5
            }
            1 -> { // a bottle, green or brown glass, a cork
                val h = 9 + r * 5
                s.limb(x + 2.6, y - 1.4, x + 2.6 + lean, y - h * 0.62, 2.5, 2.4, if (seed % 3 == 0) glassBrown else glass)
                s.limb(x + 2.6 + lean, y - h * 0.62, x + 2.6 + lean * 1.2, y - h, 1.0, 0.9, if (seed % 3 == 0) glassBrown else glass)
                s.dot(x + 2.6 + lean * 1.2, y - h - 0.6, argb(0x8A6A44))
                6.5
            }
            2 -> { // a squat crock with a lid
                s.blob(x + 5.0, y - 4.0, 5.0, 4.2, clay)
                s.blob(x + 5.0, y - 7.6, 3.6, 1.2, clay, depth = 0.4)
                s.dot(x + 5.0, y - 8.6, argb(0x3A2418))
                11.0
            }
            3 -> { // a bundle of dried herbs or a rolled cloth lying down
                if (seed % 2 == 0) {
                    s.limb(x + 1.5, y - 2.6, x + 11.0, y - 3.4, 2.4, 3.2, herbs)
                    s.line(x + 3.5, y - 5.0, x + 3.8, y - 0.8, rope.ramp.mid)
                } else {
                    s.limb(x + 1.5, y - 3.0, x + 11.0, y - 3.0, 3.0, 3.0, wool)
                    s.blob(x + 11.0, y - 3.0, 1.6, 3.0, wool, depth = 0.4)
                }
                13.0
            }
            4 -> { // a small sack, tied, slumped
                s.blob(x + 4.8, y - 4.4, 4.8, 4.6, linen, depth = 0.8)
                s.limb(x + 4.6, y - 8.4, x + 5.6, y - 11.0, 1.4, 1.0, linen)
                s.line(x + 3.2, y - 8.6, x + 6.4, y - 8.8, argb(0x3A2E20))
                10.5
            }
            5 -> { // a stack of wooden bowls
                for (i in 0 until 3) s.blob(x + 5.0, y - 1.6 - i * 1.8, 5.0 - i * 0.2, 1.8, oakTop, depth = 0.5)
                s.flat(x + 5.0, y - 6.4, 3.4, 0.9, hole)
                11.0
            }
            else -> { // a few candle stubs in a dish
                s.blob(x + 4.5, y - 1.0, 4.5, 1.4, pewter, depth = 0.3)
                s.limb(x + 3.0, y - 1.5, x + 3.0, y - 5.5, 1.2, 1.1, wax)
                s.limb(x + 6.0, y - 1.5, x + 6.0, y - 4.0, 1.2, 1.1, wax)
                10.0
            }
        }
    }

    /**
     * A tall shelf against the wall, taller than a man: two posts, a back of dark boards, four
     * shelf boards with jars, bottles, crocks, bundles and bowls. [v] picks the look: well stocked;
     * half emptied, dusty, a cobweb in the corner; or a board sagging in the middle under its load.
     */
    fun shelf(v: Int): MapRoom.Sprite = cached("shelf/$v") {
        val w = 60; val h = 118
        val s = Sculpt(w, h, 700 + v)
        val foot = h - 4.0
        val look = v % 3
        val boards = doubleArrayOf(31.0, 53.0, 75.0, 97.0)
        // the back: upright boards, dark with smoke, gaps between them
        s.poly(oakBack, 4.0, 6.0, w - 4.0, 6.0, w - 4.0, foot, 4.0, foot, tiltY = 0.15, bevel = 0.0)
        var bx = 4.0 + rnd(v, 0, 2) * 4
        while (bx < w - 6) { s.line(bx, 7.0, bx, foot - 1, argb(0x1A1410)); bx += 9 + rnd(v, bx.toInt(), 3) * 3 }
        // under every board the back lies in its shade
        for (by in boards) s.tint(w / 2.0, by + 5.0, w / 2.0, 5.0, argb(0x0A0806), 0.45)
        // the posts and the crown
        s.poly(oak, 0.0, 4.0, 5.5, 4.0, 5.5, foot, 0.0, foot, tiltY = 0.15, tiltX = -0.05, bevel = 1.4)
        s.poly(oak, w - 5.5, 4.0, w.toDouble(), 4.0, w.toDouble(), foot, w - 5.5, foot, tiltY = 0.15, tiltX = 0.2, bevel = 1.4)
        s.poly(oakTop, -1.0, 4.0, w + 1.0, 4.0, w + 1.0, 0.0, -1.0, 0.0, tiltY = -0.6, bevel = 0.8)
        s.poly(oak, -1.0, 4.0, w + 1.0, 4.0, w + 1.0, 8.0, -1.0, 8.0, tiltY = 0.3, bevel = 1.0)
        for (k in boards.indices) {
            val by = boards[k]
            val sag = if (look == 2 && k == 1) 3.0 else 0.0
            // the things on the board first, then the board's front edge over their feet
            var x = 6.5
            var i = 0
            val sparse = look == 1
            while (x < w - 12) {
                val seed = hash(i, k, v)
                if (sparse && rnd(i, k, v + 9) < 0.42) { x += 6 + rnd(i, k, v + 10) * 6; i++; continue }
                val t = (x - 6) / (w - 12)
                val y = by + sag * (1 - (2 * t - 1) * (2 * t - 1))
                val lean = if (sag > 0) (t - 0.5) * 3.0 else 0.0
                x += shelfItem(s, x, y, seed % 7, seed, lean) + 1 + rnd(i, k, v + 4) * 2
                i++
            }
            // the board: its top seen from above, its front edge
            if (sag > 0) {
                val pts = ArrayList<Double>()
                for (j in 0..8) { val t = j / 8.0; pts += 5.0 + t * (w - 10); pts += by + sag * (1 - (2 * t - 1) * (2 * t - 1)) }
                for (j in 8 downTo 0) { val t = j / 8.0; pts += 5.0 + t * (w - 10); pts += by + 3.5 + sag * (1 - (2 * t - 1) * (2 * t - 1)) }
                s.poly(oak, *pts.toDoubleArray(), tiltY = 0.3, bevel = 1.0)
                s.line(w / 2.0 - 2, by + sag + 1, w / 2.0 + 3, by + sag + 2.5, crack)        // the crack it sags at
            } else {
                s.poly(oakTop, 5.0, by, w - 5.0, by, w - 5.0, by - 2.0, 5.0, by - 2.0, tiltY = -0.6, bevel = 0.0)
                s.poly(oak, 5.0, by, w - 5.0, by, w - 5.0, by + 3.5, 5.0, by + 3.5, tiltY = 0.3, bevel = 1.0)
            }
        }
        // the bottom: a crate or a basket pushed under the lowest board
        if (look != 1) {
            s.poly(oakDark, 9.0, foot, 30.0, foot, 30.0, foot - 11, 9.0, foot - 11, tiltY = 0.25, bevel = 1.2)
            s.line(9.5, foot - 6, 29.5, foot - 6, crack)
        }
        if (look == 1) {
            // dust settled along the boards, a cobweb in the upper corner
            for (by in boards) s.tint(w / 2.0, by - 1.0, w / 2.0, 1.6, argb(0x8A8070), 0.18)
            for (k in 0 until 5) {
                val a = Math.toRadians(5.0 + k * 20)
                s.line(w - 5.5, 8.5, w - 5.5 - cos(a) * 16, 8.5 + sin(a) * 16, cobweb)
            }
            for (r in doubleArrayOf(6.0, 11.0)) for (k in 0 until 4) {
                val a0 = Math.toRadians(5.0 + k * 20); val a1 = Math.toRadians(25.0 + k * 20)
                s.line(w - 5.5 - cos(a0) * r, 8.5 + sin(a0) * r, w - 5.5 - cos(a1) * r, 8.5 + sin(a1) * r, cobweb)
            }
        }
        // grime low on the posts, worn pale at hand height
        s.tint(w / 2.0, foot - 3, w / 2.0 + 2, 6.0, argb(0x14100C), 0.35)
        s.tint(3.0, 60.0, 3.0, 10.0, argb(0x8A7458), 0.18)
        done(s, w / 2, h - 4) { floorShadow(it, w / 2.0, h - 4.0, w / 2.0 + 2, 4.0) }
    }

    // ------------------------------------------------------------------ firewood

    /** One log lying with its cut end towards us: bark body going back, the end with its rings. */
    private fun logEnd(s: Sculpt, x: Double, y: Double, r: Double, seed: Int, split: Int = 0) {
        val back = 2.2 + rnd(seed, 0, 1) * 1.6
        val b = if (seed % 7 == 0) barkBirch else bark
        if (split == 0) {
            s.limb(x + 2.2, y - back, x, y, r * 0.95, r, b)
            disc(s, x, y, r * 0.96, r * 0.9, endGrain, tiltX = -0.1, tiltY = -0.15)
            // the rings and a check crack from the heart
            for (k in 1..2) {
                val rr = r * 0.9 * k / 3.0
                for (j in 0 until 18) { val a = j * Math.PI / 9; if (j % 3 != 0) s.dot(x + cos(a) * rr, y + sin(a) * rr * 0.94, argb(0x6E5636)) }
            }
            s.line(x, y, x + r * 0.6, y - r * 0.5, crack)
        } else {
            // a split piece: a wedge, bark on the round side, the pale split faces
            val a0 = if (split == 1) -0.3 else 2.0
            val pts = ArrayList<Double>()
            pts += x; pts += y
            for (j in 0..6) { val a = a0 + j * (Math.PI * 0.9 / 6); pts += x + cos(a) * r; pts += y + sin(a) * r * 0.9 }
            s.limb(x + 2.0 + cos(a0 + 0.8) * r * 0.5, y - back + sin(a0 + 0.8) * r * 0.45, x + cos(a0 + 0.8) * r * 0.5, y + sin(a0 + 0.8) * r * 0.45, r * 0.6, r * 0.62, b)
            s.poly(endGrain, *pts.toDoubleArray(), bevel = 1.2)
            s.line(x, y, x + cos(a0 + 1.4) * r * 0.8, y + sin(a0 + 1.4) * r * 0.7, argb(0x7A6444))
        }
    }

    /**
     * Firewood by the hearth, low enough to step over. [v]: split logs stacked with a hatchet
     * leaning on them; a chopping block with the axe in it and logs tumbled around, chips and bark;
     * or a neat stack between two stakes and a tied bundle of kindling.
     */
    fun firewood(v: Int): MapRoom.Sprite = cached("firewood/$v") {
        val w = 64; val h = 46
        val s = Sculpt(w, h, 720 + v)
        val base = h - 6.0
        when (v % 3) {
            0 -> {
                val rows = listOf(4, 3, 2)
                for (row in rows.indices.reversed()) for (k in 0 until rows[row]) {
                    val seed = row * 7 + k + v * 31
                    val x = 13.0 + k * 10.5 + row * 5.2 + (rnd(seed, 1, 2) - 0.5) * 1.6
                    val y = base - 5.0 - row * 8.6 + (rnd(seed, 1, 3) - 0.5) * 1.2
                    logEnd(s, x, y, 5.0 + rnd(seed, 1, 4) * 0.8, seed, split = seed % 3)
                }
                // the hatchet leaning against the stack
                s.limb(56.0, base, 51.0, base - 24.0, 1.3, 1.1, oak)
                s.poly(iron, 48.0, base - 21.0, 55.0, base - 26.0, 57.0, base - 22.0, 52.0, base - 19.5, tiltX = 0.3, bevel = 1.0)
                s.line(56.5, base - 22.5, 54.5, base - 25.5, argb(0x8A8680))
            }
            1 -> {
                // the chopping block, scarred on top, the axe bitten into it
                s.limb(20.0, base - 2.0, 20.0, base - 12.0, 9.0, 8.6, bark)
                disc(s, 20.0, base - 13.0, 8.6, 3.6, endGrain, tiltY = -0.6, bevel = 0.8)
                for (k in 0 until 4) s.line(15.0 + k * 3, base - 15.0 + k * 0.5, 17.0 + k * 3, base - 11.0, crack)
                s.poly(iron, 22.0, base - 14.0, 30.0, base - 16.0, 31.0, base - 12.5, 24.0, base - 12.0, tiltX = 0.2, tiltY = -0.2, bevel = 1.0)
                s.limb(28.0, base - 14.0, 44.0, base - 30.0, 1.4, 1.2, oak)
                // logs tumbled in front and beside it, one long one lying across
                s.limb(30.0, base - 3.0, 56.0, base - 8.0, 4.0, 4.4, bark)
                disc(s, 30.0, base - 3.0, 3.6, 3.8, endGrain, tiltX = -0.3)
                logEnd(s, 47.0, base - 2.0, 5.2, 11 + v, split = 1)
                logEnd(s, 8.0, base - 1.0, 4.6, 12 + v, split = 0)
                // chips and torn bark on the floor
                for (k in 0 until 9) {
                    val cx = 4.0 + rnd(k, v, 5) * 56; val cy = base + 1 - rnd(k, v, 6) * 4
                    s.poly(if (k % 3 == 0) bark else splitFace, cx, cy, cx + 2.5, cy - 0.8, cx + 3.2, cy + 0.4, cx + 0.6, cy + 1.0, tiltY = -0.6, bevel = 0.4)
                }
            }
            else -> {
                // two stakes holding a short stack of round logs
                for (px in doubleArrayOf(8.0, 46.0)) s.limb(px, base, px + 0.6, base - 24.0, 1.6, 1.3, oakDark)
                for (row in 2 downTo 0) for (k in 0 until 4 - (row + 1) / 2) {
                    val seed = row * 5 + k + v * 17
                    logEnd(s, 14.0 + k * 9.2 + (row % 2) * 4.6, base - 4.5 - row * 7.8, 4.4, seed, split = if (row == 2) 1 + seed % 2 else 0)
                }
                // a bundle of kindling tied with cord, leaning on the stake
                for (k in 0 until 6) s.limb(52.0 + k * 1.1, base, 56.0 + k * 0.8, base - 20.0, 0.9, 0.7, if (k % 2 == 0) splitFace else bark)
                s.line(51.5, base - 9.0, 58.0, base - 10.5, rope.ramp.dark)
                s.line(52.5, base - 15.0, 59.0, base - 16.0, rope.ramp.dark)
            }
        }
        // ash and dust ground into the floor round the wood is part of the floor; here only grime low down
        s.tint(w / 2.0, base - 1.0, w / 2.0, 3.0, argb(0x14100C), 0.3)
        done(s, w / 2, base.toInt()) { floorShadow(it, w / 2.0, base, w / 2.0 - 2, 5.0) }
    }

    // ------------------------------------------------------------------ table

    /**
     * One tile of a long trestle table, joined to the next ([l], [r]), hip high: thick boards worn
     * pale, knife scars, a ring where a wet tankard stood; mugs, bowls, bread, a candle. [v] picks
     * what lies on it.
     */
    fun table(l: Boolean, r: Boolean, v: Int): MapRoom.Sprite = cached("table/$l/$r/$v") {
        val w = MapGround.S; val h = 76
        val s = Sculpt(w, h, 740 + v)
        val x0 = if (l) -6.0 else 4.0; val x1 = if (r) w + 6.0 else w - 4.0
        val top = 7.0; val edge = 32.0; val under = 37.0; val foot = h - 4.0
        // legs first: at the outer ends, a trestle in the middle of a long table
        val legs = buildList { if (!l) add(x0 + 5.5); if (!r) add(x1 - 5.5); if (l && r && v % 2 == 0) add(w / 2.0) }
        for (lx in legs) {
            s.poly(oak, lx - 2.8, under - 1, lx + 2.8, under - 1, lx + 3.3, foot, lx - 3.3, foot, tiltY = 0.15, bevel = 1.3)
            s.tint(lx, foot - 2, 4.0, 3.0, argb(0x14100C), 0.4)
        }
        if (!l || !r) {
            val a = if (!l) x0 + 5.5 else w / 2.0; val b = if (!r) x1 - 5.5 else w / 2.0
            if (b - a > 6) s.poly(oakDark, a, foot - 19, b, foot - 19, b, foot - 15.5, a, foot - 15.5, tiltY = 0.2, bevel = 0.8)
        }
        // the top seen from above, three thick boards running along, and its front edge
        s.poly(oakTop, x0, edge, x1, edge, x1, top, x0, top, tiltY = -0.72, bevel = 0.0)
        for (k in 1..2) {
            val y = top + k * (edge - top) / 3
            s.line(x0 + 1, y, x1 - 1, y + (rnd(k, v, 20) - 0.5), crack)
        }
        s.poly(oak, x0, edge, x1, edge, x1, under, x0, under, tiltY = 0.35, bevel = 1.2)
        // knots, knife scars, a wet ring; worn paler along the front where elbows rest
        s.tint(w / 2.0, edge - 4, w / 2.0 + 6, 4.0, argb(0x9A8264), 0.16)
        for (k in 0 until 2) s.flat(6 + rnd(k, v, 21) * (w - 12), top + 3 + rnd(k, v, 22) * 20, 1.6, 0.8, argb(0x3A2A1E))
        for (k in 0 until 3) {
            val sx = 6 + rnd(k, v, 23) * (w - 16); val sy = top + 4 + rnd(k, v, 24) * 18
            s.line(sx, sy, sx + 4 + rnd(k, v, 25) * 5, sy + (rnd(k, v, 26) - 0.5) * 3, argb(0x5E4A34))
        }
        if (v % 2 == 1) for (j in 0 until 16) { val a = j * Math.PI / 8; s.dot(w * 0.7 + cos(a) * 4.0, top + 11 + sin(a) * 2.0, argb(0x3A2A1C)) }
        // what lies on it
        when (v % 4) {
            0 -> { candle(s, 11.0, top + 15, 7.0); bowl(s, 36.0, top + 11, true); loaf(s, 25.0, top + 21, true); knife(s, 44.0, top + 21) }
            1 -> { tankard(s, 20.0, top + 13, wood = false); tipped(s, 10.0, top + 22); bowl(s, 44.0, top + 17, false); crumbs(s, 30.0, top + 23, v) }
            2 -> { jug(s, 14.0, top + 19); loaf(s, 34.0, top + 9, false); bowl(s, 44.0, top + 19, true); tankard(s, 25.0, top + 21, wood = true) }
            else -> { candle(s, 42.0, top + 13, 4.5); tankard(s, 16.0, top + 17, wood = true, full = false); crumbs(s, 22.0, top + 23, v); loaf(s, 31.0, top + 11, true) }
        }
        done(s, w / 2, h - 4) { img ->
            // the floor under the table lies in its shade, deepest just under the top (10.10., 6.9)
            val a = if (l) 0 else 5; val b = if (r) w else w - 5
            for (y in under.toInt() until h - 3) for (x in a until b) if (!img.opaque(x, y)) img.set(x, y, ((0x90 - (y - under.toInt()) * 2).coerceIn(0x40, 0x90) shl 24) or 0x0A0806)
        }
    }

    // ------------------------------------------------------------------ barrel

    /**
     * An oak barrel, waist high: swelling staves, three iron hoops gone rusty, a lid of boards.
     * [v]: a tap at the front with a dark run beneath it; a tankard and a rag left on the lid; or
     * the lid off, dark ale inside and a ladle hanging over the rim.
     */
    fun barrel(v: Int): MapRoom.Sprite = cached("barrel/$v") {
        val w = 42; val h = 60
        val s = Sculpt(w, h, 760 + v)
        val cx = w / 2.0; val foot = h - 5.0
        val look = v % 3
        val topY = foot - 44
        // the body: staves swelling to the middle, flat at top and bottom, rounded by the bevel
        val body = ArrayList<Double>()
        for (j in 0..10) { val t = j / 10.0; val r = 15.0 + 2.6 * sin(t * Math.PI); body += cx + r; body += topY + t * (foot - 1 - topY) }
        for (j in 10 downTo 0) { val t = j / 10.0; val r = 15.0 + 2.6 * sin(t * Math.PI); body += cx - r; body += topY + t * (foot - 1 - topY) }
        s.poly(oak, *body.toDoubleArray(), tiltY = 0.15, bevel = 9.0)
        // staves: seams following the swell, one stave a little darker
        for (k in -3..3) {
            val sw = k * 4.3
            s.line(cx + sw, topY + 3, cx + sw * 1.17, foot - 22, crack)
            s.line(cx + sw * 1.17, foot - 22, cx + sw, foot - 3, crack)
        }
        s.tint(cx - 8.0, foot - 22, 2.4, 20.0, argb(0x2A1E16), 0.35)
        // hoops, rust bleeding from them
        for ((i, hy) in doubleArrayOf(foot - 7, foot - 22, topY + 7).withIndex()) {
            val r = if (i == 1) 17.9 else 15.6
            val drop = if (look == 2 && i == 2) 2.0 else 0.0
            s.poly(iron, cx - r, hy - 1.7 + drop, cx + r, hy - 1.7 + drop, cx + r, hy + 1.7 + drop, cx - r, hy + 1.7 + drop, tiltY = 0.1, bevel = 0.8)
            s.tint(cx + (rnd(i, v, 1) - 0.5) * 18, hy + 4 + drop, 3.0, 3.5, rust.ramp.mid, 0.35)
        }
        // the lid: a rim, boards across
        s.blob(cx, topY, 14.8, 5.0, oakDark, depth = 0.2)
        if (look == 2) {
            s.flat(cx, topY + 0.6, 12.4, 3.8, ale)
            s.dot(cx - 4.0, topY - 1.0, argb(0x5A3A1E))
            // the ladle hanging over the rim
            s.limb(cx + 4.0, topY - 1.0, cx + 15.0, topY - 9.0, 1.0, 0.9, oak)
            s.blob(cx + 2.0, topY + 0.5, 3.0, 1.4, oakTop, depth = 0.3)
        } else {
            s.blob(cx, topY - 0.4, 13.0, 4.1, oakTop, depth = 0.2)
            for (k in -1..1) s.line(cx - 12.0, topY + k * 2.6 - 0.4, cx + 12.0, topY + k * 2.6 - 0.4, crack)
        }
        when (look) {
            0 -> {
                // the tap, and ale that ran down the staves and soaked in
                s.tint(cx + 1.0, foot - 9, 2.6, 10.0, ale, 0.45)
                s.limb(cx, foot - 18, cx + 1.0, foot - 13.5, 1.6, 1.2, iron)
                s.limb(cx - 1.4, foot - 19, cx + 1.4, foot - 19.5, 0.8, 0.8, iron)
                s.dot(cx + 1.0, foot - 12.5, ale)
            }
            1 -> {
                tankard(s, cx - 4.0, topY + 1.5, wood = true)
                s.blob(cx + 6.0, topY - 0.5, 5.0, 1.8, linen, depth = 0.6)
                s.line(cx + 2.5, topY - 0.5, cx + 9.0, topY + 0.2, argb(0x3A2E20))
            }
        }
        // grime and wet at the foot
        s.tint(cx, foot - 3, 16.0, 4.0, argb(0x14100C), 0.4)
        done(s, w / 2, h - 5) { floorShadow(it, cx, foot, w / 2.0 + 1, 4.5) }
    }
}
