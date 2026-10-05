@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.Song

/** Silent stand-in for the Android music player. */
class MusicPlayer {
    fun play(song: Song?) {}
    fun setEnabled(on: Boolean) {}
    fun pause() {}
    fun resume() {}
    fun release() {}
}
