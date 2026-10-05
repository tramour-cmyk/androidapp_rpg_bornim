@file:Suppress("unused", "PackageDirectoryMismatch")

package androidx.compose.ui.text.font

import java.io.File

fun Font(resId: Int, weight: FontWeight): Font =
    androidx.compose.ui.text.platform.Font(File("../../app/src/main/res/font/jersey10.ttf"), weight)
