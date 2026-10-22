package de.bornim.game.audio

/**
 * 319: whether a black screen stands, between places ([map]) or before a fight ([fight]), set by the screens
 * themselves; the music and the effects ask it every time they would sound ([de.bornim.core.audio.VeilGate]).
 */
object Hush {
    @Volatile var map = false
    @Volatile var fight = false
    val veiled: Boolean get() = map || fight
}
