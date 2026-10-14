package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.MapKind
import de.bornim.core.Tile

/**
 * The colour mood of a place and an hour (idea 11): laid over the finished map like the grade
 * of a film. The cave cold and greenish, a room with a fire warm, the dusk outdoors violet, the night
 * a little colder still; and everywhere the edges of the picture a little darker, so the eye stays
 * with the hero. The light of the place itself stays with [MapLight]; this only tints it.
 */
object MapGrade {
    /**
     * The grade: [tint] (rgb, 0xRRGGBB) multiplied over the picture with weight [amount] (0 … 1),
     * and [vignette], how dark the corners get (0 … 1).
     */
    data class Grade(val tint: Int, val amount: Float, val vignette: Float) {
        val red get() = (tint shr 16) and 0xFF
        val green get() = (tint shr 8) and 0xFF
        val blue get() = tint and 0xFF
    }

    /** No grade at all. */
    val none = Grade(0xFFFFFF, 0f, 0f)

    /** The grade of [map] at [daylight] (0 night … 1 day). */
    fun of(map: MapDef, daylight: Float): Grade {
        val d = daylight.coerceIn(0f, 1f)
        return when (map.kind) {
            // rock, damp and moss: cold and a little green; the light tints, it does not darken (dark places are dark already)
            MapKind.CAVE -> Grade(0xD0ECDC, 0.5f, 0.26f)
            // a room with a fire: warm, the corners dark about the hearth; without a fire (the temple) cooler, stiller
            MapKind.INTERIOR -> if (hasHearth(map)) Grade(0xFFE8C8, 0.45f, 0.2f) else Grade(0xF0EAE0, 0.35f, 0.2f)
            else -> {
                val deep = map.id == "deep_forest"
                // dusk peaks halfway between day and night; the night is already blue from the light of the place
                val dusk = bell(d, 0.5f, 0.28f)
                val night = ((0.35f - d) / 0.35f).coerceIn(0f, 1f)
                val day = if (deep) 0xECF6E4 else if (map.kind == MapKind.FOREST) 0xF8FCF0 else 0xFFFCF4
                val tint = mix(mix(day, 0xE4CCF0, dusk), 0xD8DCF4, night)
                val amount = (if (deep) 0.35f else 0.25f) + 0.35f * dusk + 0.2f * night
                val vignette = (if (deep) 0.22f else if (map.kind == MapKind.FOREST) 0.2f else 0.18f) + 0.1f * dusk + 0.14f * night
                Grade(tint, amount.coerceAtMost(1f), vignette.coerceAtMost(1f))
            }
        }
    }

    /** [img] graded, the vignette included: the same as the map draws on the device (for the tests and the preview). */
    fun apply(img: PixelImage, g: Grade): PixelImage {
        val out = PixelImage(img.width, img.height)
        val cx = img.width / 2.0; val cy = img.height / 2.0
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val c = img.pixels[y * img.width + x]
            // the corners darken from about half way out, softly
            val dx = (x - cx) / cx; val dy = (y - cy) / cy
            val r2 = ((dx * dx + dy * dy) / 2.0).coerceIn(0.0, 1.0)
            val v = 1.0 - g.vignette * smooth(((r2 - 0.25) / 0.75).coerceIn(0.0, 1.0))
            fun ch(s: Int, t: Int): Int = ((s * (1 - g.amount + g.amount * t / 255.0)) * v).toInt().coerceIn(0, 255)
            out.pixels[y * img.width + x] = (c and 0xFF000000.toInt()) or
                (ch((c shr 16) and 0xFF, g.red) shl 16) or (ch((c shr 8) and 0xFF, g.green) shl 8) or ch(c and 0xFF, g.blue)
        }
        return out
    }

    private fun smooth(t: Double) = t * t * (3 - 2 * t)

    private fun bell(x: Float, mid: Float, width: Float): Float {
        val t = ((x - mid) / width).coerceIn(-1f, 1f)
        return (1 - t * t).let { it * it }
    }

    private fun mix(a: Int, b: Int, t: Float): Int {
        fun ch(s: Int) = (((a shr s) and 0xFF) + (((b shr s) and 0xFF) - ((a shr s) and 0xFF)) * t).toInt().coerceIn(0, 255)
        return (ch(16) shl 16) or (ch(8) shl 8) or ch(0)
    }

    private fun hasHearth(map: MapDef) = (0 until map.height).any { y -> (0 until map.width).any { x -> map.tile(x, y) == Tile.HEARTH } }
}
