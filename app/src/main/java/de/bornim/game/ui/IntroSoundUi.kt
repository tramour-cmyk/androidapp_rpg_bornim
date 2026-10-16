package de.bornim.game.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.withFrameMillis
import de.bornim.core.Intro
import de.bornim.core.audio.IntroSound
import de.bornim.core.audio.Sound
import de.bornim.game.GameViewModel
import kotlinx.coroutines.isActive

/**
 * The quiet sounds under the intro (69c): wind and river loop at [IntroSound.loops], crickets chirp at [IntroSound.chirps],
 * on the same clock as the pictures. Skipped or over, the loops die away (24.8.5) instead of breaking off.
 */
@Composable
fun IntroSounds(vm: GameViewModel) {
    val streams = remember { IntArray(2) }
    val levels = remember { FloatArray(2) }
    LaunchedEffect(Unit) {
        val start = IntroLook.fromMs
        val chirps = IntroSound.chirps(System.nanoTime(), Intro.totalMs).filter { it.first >= start }
        var next = 0
        val t0 = withFrameMillis { it }
        while (isActive) withFrameMillis { now ->
            val ms = start + now - t0
            val m = IntroSound.loops(ms)
            for ((i, pair) in listOf(Sound.WIND to m.wind, Sound.RIVER to m.river).withIndex()) {
                val (s, v) = pair
                levels[i] = v
                when {
                    v > 0f && streams[i] == 0 -> streams[i] = vm.sfx.loop(s, v)
                    v == 0f && streams[i] != 0 -> { vm.sfx.stop(streams[i]); streams[i] = 0 }
                    else -> vm.sfx.volume(streams[i], v)
                }
            }
            while (next < chirps.size && chirps[next].first <= ms) { vm.play(Sound.CRICKET, chirps[next].second); next++ }
        }
    }
    DisposableEffect(Unit) {
        onDispose { for (i in streams.indices) vm.sfx.fadeOut(streams[i], levels[i]) }
    }
}
