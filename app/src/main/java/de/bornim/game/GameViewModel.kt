package de.bornim.game

import android.app.Application
import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import de.bornim.core.CharClass
import de.bornim.core.Game
import de.bornim.core.GameState
import de.bornim.core.Lang
import de.bornim.core.Race
import de.bornim.core.audio.Sound
import de.bornim.game.audio.MusicPlayer
import de.bornim.game.audio.SfxPlayer
import java.util.Locale

enum class Screen { TITLE, CREATE, PLAYING, ABOUT }

class GameViewModel(app: Application) : AndroidViewModel(app) {
    private val prefs = app.getSharedPreferences("bornim", Context.MODE_PRIVATE)

    var lang by mutableStateOf(
        when (prefs.getString(KEY_LANG, null)) {
            "DE" -> Lang.DE
            "EN" -> Lang.EN
            else -> if (Locale.getDefault().language == "de") Lang.DE else Lang.EN
        }
    )
        private set

    var screen by mutableStateOf(Screen.TITLE)
    var game by mutableStateOf<Game?>(null)
        private set

    /** Incremented whenever the (mutable) game changed, so Compose redraws. */
    var tick by mutableIntStateOf(0)
        private set

    val music = MusicPlayer()
    val sfx = SfxPlayer(app)

    var sfxOn by mutableStateOf(prefs.getString(KEY_SFX, "on") != "off")
        private set

    init {
        sfx.enabled = sfxOn
    }

    fun toggleSfx() {
        sfxOn = !sfxOn
        sfx.enabled = sfxOn
        prefs.edit().putString(KEY_SFX, if (sfxOn) "on" else "off").apply()
    }

    fun play(s: Sound, volume: Float = 0.8f) = sfx.play(s, volume)

    /** Touch controls (drag and tap) or the classic D-pad. */
    var touchControls by mutableStateOf(prefs.getString(KEY_CONTROLS, "touch") != "classic")
        private set

    fun toggleControls() {
        touchControls = !touchControls
        prefs.edit().putString(KEY_CONTROLS, if (touchControls) "touch" else "classic").apply()
    }

    /** Action button on the left for left-handed players. */
    var leftHanded by mutableStateOf(prefs.getBoolean(KEY_LEFT, false))
        private set

    fun toggleLeftHanded() {
        leftHanded = !leftHanded
        prefs.edit().putBoolean(KEY_LEFT, leftHanded).apply()
    }

    var haptics by mutableStateOf(prefs.getBoolean(KEY_HAPTICS, true))
        private set

    fun toggleHaptics() {
        haptics = !haptics
        prefs.edit().putBoolean(KEY_HAPTICS, haptics).apply()
    }

    /** Hidden test mode with a cheat tab in the menu; toggled by tapping the copyright 7 times. */
    var testMode by mutableStateOf(prefs.getBoolean(KEY_TEST, false))
        private set

    fun toggleTestMode() {
        testMode = !testMode
        prefs.edit().putBoolean(KEY_TEST, testMode).apply()
    }

    var musicOn by mutableStateOf(prefs.getString(KEY_MUSIC, "on") != "off")
        private set

    fun toggleMusic() {
        musicOn = !musicOn
        prefs.edit().putString(KEY_MUSIC, if (musicOn) "on" else "off").apply()
        music.setEnabled(musicOn)
    }

    override fun onCleared() {
        music.release()
        sfx.release()
    }

    var menuOpen by mutableStateOf(false)
    var toast by mutableStateOf<String?>(null)

    val hasSave: Boolean get() = prefs.contains(KEY_SAVE)

    fun toggleLang() {
        lang = if (lang == Lang.DE) Lang.EN else Lang.DE
        prefs.edit().putString(KEY_LANG, lang.name).apply()
        game?.let {
            it.lang = lang
            (it.mode as? de.bornim.core.Mode.Fight)?.battle?.lang = lang
        }
        refresh()
    }

    fun newGame(name: String, race: Race, cls: CharClass, bought: Map<de.bornim.core.Ability, Int>? = null) {
        val g = Game(GameState.newGame(name.ifBlank { "Held" }, race, cls, bought), lang)
        game = g
        menuOpen = false
        screen = Screen.PLAYING
        g.begin()
        save()
        refresh()
    }

    fun continueGame() {
        val json = prefs.getString(KEY_SAVE, null) ?: return
        val state = runCatching { GameState.fromJson(json) }.getOrNull() ?: return
        val g = Game(state, lang)
        game = g
        menuOpen = false
        screen = Screen.PLAYING
        g.begin()
        refresh()
    }

    fun save() {
        val g = game ?: return
        if (screen != Screen.PLAYING) return
        prefs.edit().putString(KEY_SAVE, g.state.toJson()).apply()
    }

    fun refresh() {
        game?.sounds?.let { q -> while (q.isNotEmpty()) sfx.play(q.removeFirst()) }
        val g = game
        if (g != null && g.mapChanged) {
            g.mapChanged = false
            save()
        }
        tick++
    }

    fun toTitle() {
        save()
        menuOpen = false
        screen = Screen.TITLE
    }

    companion object {
        private const val KEY_SAVE = "save"
        private const val KEY_LANG = "lang"
        private const val KEY_MUSIC = "music"
        private const val KEY_SFX = "sfx"
        private const val KEY_TEST = "test_mode"
        private const val KEY_CONTROLS = "controls"
        private const val KEY_LEFT = "left_handed"
        private const val KEY_HAPTICS = "haptics"
    }
}
