@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.Threat

/** Silent stand-in for the Android music player. */
class MusicPlayer(context: Any? = null) {
    var threat: () -> Threat = { Threat.NONE }
    fun play(now: MusicScene) {}
    fun victory() {}
    fun setEnabled(on: Boolean) {}
    fun pause() {}
    fun resume() {}
    fun release() {}
}
