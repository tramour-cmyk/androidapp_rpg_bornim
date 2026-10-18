@file:Suppress("unused", "PackageDirectoryMismatch")

package de.bornim.game

import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.toComposeImageBitmap
import java.io.File
import javax.imageio.ImageIO

/** Desktop stand-in for the intro's pictures: read straight from the app's assets. */
class IntroArt(private val context: Any? = null) {
    private val cache = HashMap<Int, ImageBitmap?>()
    fun get(index: Int): ImageBitmap? = cache.getOrPut(index) {
        val f = File("../../app/src/main/assets/intro/intro_${index + 1}.jpg")
        if (f.exists()) ImageIO.read(f)?.toComposeImageBitmap() else null
    }
    private val layers = HashMap<Int, ImageBitmap?>()
    fun layer(index: Int): ImageBitmap? = layers.getOrPut(index) {
        val f = File("../../app/src/main/assets/intro/intro_${index + 1}_zug.png")
        if (f.exists()) ImageIO.read(f)?.toComposeImageBitmap() else null
    }
    private val fronts = HashMap<Int, ImageBitmap?>()
    fun front(index: Int): ImageBitmap? = fronts.getOrPut(index) {
        val f = File("../../app/src/main/assets/intro/intro_${index + 1}_vorn.png")
        if (f.exists()) ImageIO.read(f)?.toComposeImageBitmap() else null
    }
    private val templePics = HashMap<Int, ImageBitmap?>()
    fun temple(index: Int): ImageBitmap? = templePics.getOrPut(index) {
        val f = File("../../app/src/main/assets/tempel/tempel_${index + 1}.jpg")
        if (f.exists()) ImageIO.read(f)?.toComposeImageBitmap() else null
    }
    val templeLife: de.bornim.core.TempleLife.Life by lazy {
        val f = File("../../app/src/main/assets/tempel/leben.txt")
        if (f.exists()) de.bornim.core.TempleLife.parse(f.readText()) else de.bornim.core.TempleLife.Life(emptyList(), emptyMap())
    }
}
