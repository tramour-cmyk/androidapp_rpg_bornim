package de.bornim.game

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import de.bornim.game.ui.BornimApp

class MainActivity : ComponentActivity() {
    private val vm: GameViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 30.1: a crash is written down before the app ends, and shown in the test tab at the next start
        CrashLog.install(applicationContext)
        DeviceInfo.install(applicationContext)
        // 30.2: a background thread out of memory lets go of the pictures not needed now
        val main = android.os.Handler(mainLooper)
        de.bornim.core.Guard.onOutOfMemory = { de.bornim.core.art.ArtMemory.trim(); main.post { de.bornim.game.ui.Bitmaps.clear() } }
        CrashLog.where = {
            val g = vm.game
            val mode = when (val m = g?.mode) {
                is de.bornim.core.Mode.Fight -> "Kampf gegen ${m.battle.monster.id}"
                null -> "–"
                else -> m::class.simpleName ?: "?"
            }
            "${vm.screen}, $mode, Karte ${g?.state?.place?.map ?: "–"}" + if (vm.menuOpen) ", Menü offen" else ""
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowCompat.getInsetsController(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
        // 24.4: the hero's map pictures are kept on the device, in a folder of this build only
        val shelf = "hero-${BuildConfig.VERSION_CODE}"
        cacheDir.listFiles { f: java.io.File -> f.name.startsWith("hero-") && f.name != shelf }?.forEach { it.deleteRecursively() }
        de.bornim.core.art.HeroShelf.dir = java.io.File(cacheDir, shelf)
        vm.music.setEnabled(vm.musicOn)
        setContent { BornimApp(vm) }
    }

    /** 30.2: the system says memory runs short: let go of the pictures not needed on the map shown. */
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        @Suppress("DEPRECATION")
        if (level >= android.content.ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW) {
            de.bornim.core.art.ArtMemory.trim()
            de.bornim.game.ui.Bitmaps.clear()
        }
    }

    override fun onStart() {
        super.onStart()
        vm.resumePlayClock()
    }

    /** 237: in front again: music and the place's sounds go on. */
    override fun onResume() {
        super.onResume()
        vm.music.resume()
        vm.sfx.resume()
    }

    /** 237: out of front (another app, the recent apps, a call, the other half of a split screen): all sound holds. */
    override fun onPause() {
        super.onPause()
        vm.music.pause()
        vm.sfx.pause()
    }

    override fun onStop() {
        super.onStop()
        vm.save()
        vm.pausePlayClock()
    }
}
