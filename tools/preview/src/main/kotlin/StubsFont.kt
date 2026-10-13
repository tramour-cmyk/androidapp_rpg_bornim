@file:Suppress("unused", "PackageDirectoryMismatch")

package androidx.compose.ui.text.font

import java.io.File

private val files = listOf("", "jersey10", "ebgaramond_regular", "ebgaramond_semibold", "alegreya_regular", "alegreya_semibold",
    "alegreya_sc_medium", "cinzel_semibold", "imfell_regular", "fondamento_regular")

fun Font(resId: Int, weight: FontWeight): Font =
    androidx.compose.ui.text.platform.Font(File("../../app/src/main/res/font/${files[resId]}.ttf"), weight)
