@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.Sound

/** Silent stand-in for the Android sound effect player. */
class SfxPlayer(context: android.content.Context) {
    var enabled = true
    fun play(s: Sound, volume: Float = 0.8f) {}
    fun release() {}
}
