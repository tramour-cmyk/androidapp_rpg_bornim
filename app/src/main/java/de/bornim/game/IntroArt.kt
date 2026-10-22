package de.bornim.game

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import de.bornim.core.TempleLife

/**
 * The intro's pictures (69), rendered ahead on the computer (`tools/preview` `IntroProbe.kt`, `BridgeProbe.kt`) and shipped
 * as `assets/intro/intro_<n>.jpg`, n = 1..4; picture 5 is black. A picture with life (70.3) also has the layer that moves,
 * `intro_<n>_zug.png` (70.6: cut-outs, slot by slot) and what stands in front of it, `intro_<n>_vorn.png`. Loaded once, on demand.
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
    private val fronts = HashMap<Int, ImageBitmap?>()
    /** What stands in front of the moving layer of picture [index] (70.6: the temple), or null if nothing does. */
    fun front(index: Int): ImageBitmap? = fronts.getOrPut(index) {
        runCatching { context.assets.open("intro/intro_${index + 1}_vorn.png").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }
    /** 292.3: the main menu's four in the cone of light, `assets/menu/hauptmenue.jpg` (`tools/preview` TITLESCENE=1 SCALE=1.25). */
    val menu: ImageBitmap? by lazy {
        runCatching { context.assets.open("menu/hauptmenue.jpg").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }
    private val templePics = HashMap<Int, ImageBitmap?>()
    /** Picture [index] (0-based) of the temple scene (68), `assets/tempel/tempel_<n>.jpg` (`tools/preview` `TempleProbe.kt`). */
    fun temple(index: Int): ImageBitmap? = templePics.getOrPut(index) {
        runCatching { context.assets.open("tempel/tempel_${index + 1}.jpg").use { BitmapFactory.decodeStream(it)?.asImageBitmap() } }.getOrNull()
    }
    /** What moves over the temple pictures (112, 7): `assets/tempel/leben.txt`, empty if it cannot be read. */
    val templeLife: TempleLife.Life by lazy {
        runCatching { context.assets.open("tempel/leben.txt").use { TempleLife.parse(it.bufferedReader().readText()) } }.getOrNull() ?: TempleLife.Life(emptyList(), emptyMap())
    }
}
