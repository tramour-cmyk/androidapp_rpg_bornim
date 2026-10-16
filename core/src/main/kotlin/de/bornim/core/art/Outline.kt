package de.bornim.core.art

/**
 * Where a figure stands in a picture, row by row: the leftmost and rightmost pixel drawn in each row, in the pixels of
 * the whole frame (the cut-out's [PixelImage.ox], [PixelImage.oy] added). Lasting statuses (53) sit on it, so flames
 * cling to the body's own edge and a veil lies over the body, not round the feet's mark beside it.
 */
class Outline(val top: Int, private val left: IntArray, private val right: IntArray) {
    val bottom get() = top + left.size - 1

    /** The edges in row [y] of the frame, or null where nothing is drawn. */
    fun span(y: Int): Pair<Int, Int>? {
        val i = y - top
        if (i !in left.indices || right[i] < 0) return null
        return Pair(left[i], right[i])
    }

    /** The edges at [y], or failing that in the nearest row with something drawn (at most [reach] rows off). */
    fun near(y: Int, reach: Int = 6): Pair<Int, Int>? {
        for (d in 0..reach) { span(y - d)?.let { return it }; span(y + d)?.let { return it } }
        return null
    }

    companion object {
        fun of(img: PixelImage): Outline? {
            var y0 = -1; var y1 = -1
            val l = IntArray(img.height) { -1 }; val r = IntArray(img.height) { -1 }
            for (y in 0 until img.height) {
                var a = -1; var b = -1
                for (x in 0 until img.width) if ((img.pixels[y * img.width + x] ushr 24) != 0) { if (a < 0) a = x; b = x }
                if (a < 0) continue
                l[y] = img.ox + a; r[y] = img.ox + b
                if (y0 < 0) y0 = y; y1 = y
            }
            if (y0 < 0) return null
            return Outline(img.oy + y0, l.copyOfRange(y0, y1 + 1), r.copyOfRange(y0, y1 + 1))
        }
    }
}
