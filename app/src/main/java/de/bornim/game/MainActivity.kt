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

    override fun onStart() {
        super.onStart()
        vm.music.resume()
    }

    override fun onStop() {
        super.onStop()
        vm.music.pause()
        vm.save()
    }
}
