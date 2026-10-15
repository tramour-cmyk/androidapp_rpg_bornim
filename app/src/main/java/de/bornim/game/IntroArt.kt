package de.bornim.game

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap

/**
 * The intro's pictures (69), rendered ahead on the computer (`tools/preview` `IntroProbe.kt`, `BridgeProbe.kt`) and shipped
 * as `assets/intro/intro_<n>.jpg`, n = 1..4; picture 5 is black. A picture with life (70.3) also has the layer that moves,
 * `intro_<n>_zug.png`. Loaded once, on demand.
 */
class IntroArt(private val context: Context) {
    private val cache = HashMap<Int, ImageBitmap?>()
    private val layers = HashMap<Int, ImageBitmap?>()

    /** Picture [index] (0-based), or null if it is the black one or cannot be read. */
    fun get(index: Int): ImageBitmap? = cache.getOrPut(index) {
        runCatching { context.assets.open("intro/intro_${index + 1}.jpg").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }

    /** The moving layer of picture [index] (0-based), or null if it has none. */
    fun layer(index: Int): ImageBitmap? = layers.getOrPut(index) {
        runCatching { context.assets.open("intro/intro_${index + 1}_zug.png").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }
}
