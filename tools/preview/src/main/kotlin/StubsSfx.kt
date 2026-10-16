@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.Sound

/** Silent stand-in for the Android sound effect player. */
class SfxPlayer(context: android.content.Context) {
    var enabled = true
    fun play(s: Sound, volume: Float = 0.8f) {}
    fun play(s: Sound, left: Float, right: Float) {}
    fun voice(id: String, cue: de.bornim.core.audio.Recorded.Cue, volume: Float = 0.8f) {}
    fun loop(s: Sound, volume: Float): Int = 0
    fun stop(stream: Int) {}
    fun fadeOut(stream: Int, from: Float) {}
    fun volume(stream: Int, volume: Float) {}
    fun release() {}
}
