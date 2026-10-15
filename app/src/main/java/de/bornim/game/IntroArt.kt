package de.bornim.game

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap

/**
 * The intro's pictures (69), rendered ahead on the computer (`tools/preview` `IntroProbe.kt`, `BridgeProbe.kt`) and shipped
 * as `assets/intro/intro_<n>.jpg`, n = 1..4; picture 5 is black. Loaded once, on demand.
 */
class IntroArt(private val context: Context) {
    private val cache = HashMap<Int, ImageBitmap?>()

    /** Picture [index] (0-based), or null if it is the black one or cannot be read. */
    fun get(index: Int): ImageBitmap? = cache.getOrPut(index) {
        runCatching { context.assets.open("intro/intro_${index + 1}.jpg").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }
}
