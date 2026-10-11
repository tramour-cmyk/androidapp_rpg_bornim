@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.MusicScene

/** Silent stand-in for the Android music player. */
class MusicPlayer(context: Any? = null) {
    fun play(now: MusicScene) {}
    fun victory() {}
    fun setEnabled(on: Boolean) {}
    fun pause() {}
    fun resume() {}
    fun release() {}
}
