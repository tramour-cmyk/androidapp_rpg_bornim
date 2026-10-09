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
import de.bornim.core.Hero
import de.bornim.core.Lang
import de.bornim.core.Race
import de.bornim.core.audio.Sound
import de.bornim.game.audio.MusicPlayer
import de.bornim.game.audio.SfxPlayer
import java.util.Locale

enum class Screen { TITLE, CREATE, PLAYING, ABOUT, SLOTS }

/** What the slot list shows about a saved hero. */
data class SlotInfo(
    val slot: Int,
    val name: String,
    val race: Race,
    val cls: CharClass,
    val level: Int,
    val place: String,
    val day: Int,
    val minutes: Int,
    /** When it was last saved, in milliseconds since 1970, or 0 if unknown. */
    val savedAt: Long,
    /** The saved hero itself, to draw it as equipped. */
    val hero: Hero,
)

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

    /** Ask before actions that cannot be undone (discarding, selling in bulk). */
    var confirmations by mutableStateOf(prefs.getBoolean(KEY_CONFIRM, true))
        private set

    /** How much blood hits show: 0 none, 1 subtle (default), 2 more. For all heroes, not per save. */
    var bloodLevel by mutableStateOf(prefs.getInt(KEY_BLOOD, 1).coerceIn(0, 2))
        private set

    /** How fast a fight runs on by itself: 0 calm, 1 normal (default), 2 fast. For all heroes, not per save. */
    var battleTempo by mutableStateOf(prefs.getInt(KEY_TEMPO, 1).coerceIn(0, 2))
        private set

    /** For the preview's battle films only: an action the battle screen takes as soon as the hero may act. */
    var testAction by mutableStateOf<de.bornim.core.Action?>(null)

    /** Whether a fight goes on by itself after each line (after a pause to read), or each line waits for a tap (default). */
    var battleAuto by mutableStateOf(prefs.getBoolean(KEY_AUTO, false))
        private set

    fun toggleBattleAuto() {
        battleAuto = !battleAuto
        prefs.edit().putBoolean(KEY_AUTO, battleAuto).apply()
    }

    fun changeTempo(level: Int) {
        battleTempo = level.coerceIn(0, 2)
        prefs.edit().putInt(KEY_TEMPO, battleTempo).apply()
    }

    fun changeBlood(level: Int) {
        bloodLevel = level.coerceIn(0, 2)
        prefs.edit().putInt(KEY_BLOOD, bloodLevel).apply()
    }

    fun toggleConfirmations() {
        confirmations = !confirmations
        prefs.edit().putBoolean(KEY_CONFIRM, confirmations).apply()
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

    // ------------------------------------------------------------ save slots

    init {
        // Saves from before slots existed move to slot 1.
        prefs.getString(KEY_SAVE, null)?.let { old ->
            if (!prefs.contains(slotKey(1))) prefs.edit().putString(slotKey(1), old).putInt(KEY_LAST_SLOT, 1).apply()
            prefs.edit().remove(KEY_SAVE).apply()
        }
    }

    /** The slot the running game is saved to. */
    var slot by mutableIntStateOf(prefs.getInt(KEY_LAST_SLOT, 1))
        private set

    /** Bumped when slots change, so the title and slot screens redraw. */
    var slotsVersion by mutableIntStateOf(0)
        private set

    private fun slotKey(n: Int) = "save_$n"

    fun slotInfo(n: Int): SlotInfo? {
        val json = prefs.getString(slotKey(n), null) ?: return null
        val s = runCatching { GameState.fromJson(json) }.getOrNull() ?: return null
        val h = s.hero
        return SlotInfo(n, h.name, h.race, h.cls, h.level, s.place.map, s.day, s.minutes, prefs.getLong(slotKey(n) + "_at", 0L), h)
    }

    fun slots(): List<SlotInfo?> = (1..SLOTS).map { slotInfo(it) }

    val hasSave: Boolean get() = (1..SLOTS).any { prefs.contains(slotKey(it)) }

    /** The hero played last, for "Continue" on the title screen. */
    val lastSave: SlotInfo? get() = slotInfo(prefs.getInt(KEY_LAST_SLOT, 1)) ?: slots().filterNotNull().maxByOrNull { it.savedAt }

    /** First empty slot, or null if all are taken. */
    val freeSlot: Int? get() = (1..SLOTS).firstOrNull { !prefs.contains(slotKey(it)) }

    /** Slot chosen on the slot screen for the next new game. */
    var pendingSlot by mutableStateOf<Int?>(null)

    fun deleteSlot(n: Int) {
        prefs.edit().remove(slotKey(n)).remove(slotKey(n) + "_at").apply()
        slotsVersion++
    }

    fun toggleLang() {
        lang = if (lang == Lang.DE) Lang.EN else Lang.DE
        prefs.edit().putString(KEY_LANG, lang.name).apply()
        game?.let {
            it.lang = lang
            (it.mode as? de.bornim.core.Mode.Fight)?.battle?.lang = lang
        }
        refresh()
    }

    /** Starts a new hero in slot [into] (default: the first free one, else slot 1). */
    fun newGame(name: String, race: Race, cls: CharClass, bought: Map<de.bornim.core.Ability, Int>? = null, into: Int? = null, look: Look? = null) {
        slot = into ?: pendingSlot ?: freeSlot ?: 1
        pendingSlot = null
        prefs.edit().putInt(KEY_LAST_SLOT, slot).apply()
        val g = Game(GameState.newGame(name.ifBlank { "Held" }, race, cls, bought).also { st ->
            look?.let { st.hero.sex = it.sex; st.hero.build = it.build; st.hero.skin = it.skin; st.hero.hair = it.hair }
        }, lang)
        game = g
        menuOpen = false
        screen = Screen.PLAYING
        g.begin()
        prepareFigures(g)
        save()
        refresh()
    }

    /** Loads slot [n] (default: the hero played last). */
    fun continueGame(n: Int = lastSave?.slot ?: 1) {
        val json = prefs.getString(slotKey(n), null) ?: return
        slot = n
        prefs.edit().putInt(KEY_LAST_SLOT, n).apply()
        val state = runCatching { GameState.fromJson(json) }.getOrNull() ?: return
        val g = Game(state, lang)
        game = g
        menuOpen = false
        screen = Screen.PLAYING
        g.begin()
        prepareFigures(g)
        refresh()
    }

    /** Starts drawing the hero and the folk of this map as dolls in the background, so they are ready when the map shows. */
    private fun prepareFigures(g: Game) {
        de.bornim.core.art.MapFigure.prepare(g.state.hero, de.bornim.core.art.MapFigure.yawOf(g.state.place.facing))
        de.bornim.core.art.MapFolk.prepareFor(de.bornim.core.World[g.state.place.map])
    }

    fun save() {
        val g = game ?: return
        if (screen != Screen.PLAYING) return
        prefs.edit().putString(slotKey(slot), g.state.toJson()).putLong(slotKey(slot) + "_at", System.currentTimeMillis()).apply()
        slotsVersion++
    }

    fun refresh() {
        game?.sounds?.let { q -> while (q.isNotEmpty()) sfx.play(q.removeFirst()) }
        val g = game
        if (g != null && g.mapChanged) {
            g.mapChanged = false
            de.bornim.core.art.MapFolk.prepareFor(de.bornim.core.World[g.state.place.map])
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
        /** Number of save slots. */
        const val SLOTS = 3
        /** The single save of versions before slots; moved to slot 1. */
        private const val KEY_SAVE = "save"
        private const val KEY_LAST_SLOT = "last_slot"
        private const val KEY_LANG = "lang"
        private const val KEY_MUSIC = "music"
        private const val KEY_SFX = "sfx"
        private const val KEY_TEST = "test_mode"
        private const val KEY_CONTROLS = "controls"
        private const val KEY_LEFT = "left_handed"
        private const val KEY_HAPTICS = "haptics"
        private const val KEY_CONFIRM = "confirmations"
        private const val KEY_BLOOD = "blood"
        private const val KEY_TEMPO = "battle_tempo"
        private const val KEY_AUTO = "battle_auto"
    }
}


/** How a new hero looks, as chosen at creation. */
data class Look(val sex: de.bornim.core.Sex, val build: de.bornim.core.Build, val skin: Int, val hair: Int)
