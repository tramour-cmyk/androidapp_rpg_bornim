@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package de.bornim.game.audio

import de.bornim.core.audio.Sound

/** Silent stand-in for the Android sound effect player. */
class SfxPlayer(context: android.content.Context) {
    var enabled = true
    var gain = 1f
    fun play(s: Sound, volume: Float = 0.8f, take: Int = -1) {}
    fun play(s: Sound, left: Float, right: Float, take: Int = -1) {}
    var room = de.bornim.core.audio.PlaceSound.Kind.OUTSIDE
    fun voice(id: String, cue: de.bornim.core.audio.Recorded.Cue, volume: Float = 0.8f, elite: Boolean = false) {}
    fun loop(s: Sound, volume: Float): Int = 0
    fun stop(stream: Int) {}
    fun fadeOut(stream: Int, from: Float) {}
    fun volume(stream: Int, volume: Float) {}
    fun release() {}
}
