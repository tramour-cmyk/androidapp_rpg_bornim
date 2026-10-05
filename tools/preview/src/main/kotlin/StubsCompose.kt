@file:Suppress("unused", "PackageDirectoryMismatch")

package androidx.compose.ui.graphics

import java.awt.image.BufferedImage

fun android.graphics.Bitmap.asImageBitmap(): ImageBitmap {
    val img = BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB)
    img.setRGB(0, 0, width, height, pixels, 0, width)
    return img.toComposeImageBitmap()
}
