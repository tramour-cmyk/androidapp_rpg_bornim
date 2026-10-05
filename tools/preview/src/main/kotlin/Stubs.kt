// Minimal stand-ins for the Android APIs the UI uses, so it compiles and renders on desktop.
@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package android.graphics

class Bitmap private constructor(val pixels: IntArray, val width: Int, val height: Int) {
    enum class Config { ARGB_8888 }

    companion object {
        fun createBitmap(colors: IntArray, width: Int, height: Int, config: Config) = Bitmap(colors, width, height)
    }
}
