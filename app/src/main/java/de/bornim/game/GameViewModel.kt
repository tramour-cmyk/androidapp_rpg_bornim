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
import de.bornim.core.audio.Mix
import de.bornim.game.audio.MusicPlayer
import de.bornim.game.audio.SfxPlayer
import de.bornim.game.ui.MapZoom
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
    /** 132: real time played, in milliseconds. */
    val playedMs: Long,
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

    val music = MusicPlayer(app).also { m ->
        // 120: the nearest hunter darkens the music while the hero is out in the world
        m.threat = { game?.takeIf { screen == Screen.PLAYING }?.threat() ?: de.bornim.core.audio.Threat.NONE }
    }
    val sfx = SfxPlayer(app)
    val introArt = IntroArt(app)

    /** The intro is on screen (69): at the first start of a new hero, or again from the chronicle. */
    var intro by mutableStateOf(false)
        private set
    /** Which of its pictures shows, for the music (the title music only with the black one, 69c). */
    var introPicture by mutableIntStateOf(0)

    fun watchIntro() { introPicture = 0; menuOpen = false; intro = true }
    fun endIntro() { intro = false; introPicture = 0 }

    /** The temple scene (68) watched again from the chronicle; the first time the game's mode shows it. */
    var templeAgain by mutableStateOf(false)
        private set
    fun watchTemple() { menuOpen = false; templeAgain = true }
    /** The temple scene is over or skipped: back to the chronicle's game, or on with the morning the first time. */
    fun endTemple() {
        if (templeAgain) templeAgain = false
        else game?.let { if (it.mode == de.bornim.core.Mode.TempleScene) { it.advance(); refresh() } }
    }

    var sfxOn by mutableStateOf(prefs.getString(KEY_SFX, "on") != "off")
        private set

    init {
        sfx.enabled = sfxOn
    }

    // 267.1T: the saying of the last long black screen survives a restart, so Aldric's comes only on the very first
    init {
        de.bornim.game.ui.VeilMemory.lastQuote = prefs.getString(KEY_QUOTE, null)
        de.bornim.game.ui.VeilMemory.keepQuote = { prefs.edit().putString(KEY_QUOTE, it).apply() }
    }

    fun toggleSfx() {
        sfxOn = !sfxOn
        sfx.enabled = sfxOn
        prefs.edit().putString(KEY_SFX, if (sfxOn) "on" else "off").apply()
    }

    /** 91: the hero's footsteps on their own switch, besides the effects (user 15.10.: they can grate in the long run). */
    var stepsOn by mutableStateOf(prefs.getString(KEY_STEPS, "on") != "off")
        private set

    fun toggleSteps() {
        stepsOn = !stepsOn
        prefs.edit().putString(KEY_STEPS, if (stepsOn) "on" else "off").apply()
    }

    fun play(s: Sound, volume: Float = 0.8f) = sfx.play(s, volume)

    /** Plays [s] from [side] (-1 left to 1 right; 84). */
    fun playFrom(s: Sound, volume: Float, side: Float) = de.bornim.core.audio.WildSound.speakers(volume, side).let { (l, r) -> sfx.play(s, l, r) }
    fun voice(id: String, cue: de.bornim.core.audio.Recorded.Cue, volume: Float = 0.8f, elite: Boolean = false) = sfx.voice(id, cue, volume, elite)

    /** Touch controls (drag and tap) or the classic D-pad. */
    var touchControls by mutableStateOf(prefs.getString(KEY_CONTROLS, "touch") != "classic")
        private set

    init { de.bornim.core.Story.classicControls = !touchControls }

    fun toggleControls() {
        touchControls = !touchControls
        de.bornim.core.Story.classicControls = !touchControls
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

    /** 86.4: how far a drag goes before the hero walks and runs: 0 fine, 1 normal (default), 2 calm (`StickFeel`). */
    var stickFeel by mutableStateOf(prefs.getInt(KEY_STICK, 1).coerceIn(0, 2))
        private set

    fun changeStickFeel(level: Int) {
        stickFeel = level.coerceIn(0, 2)
        prefs.edit().putInt(KEY_STICK, stickFeel).apply()
    }

    /** 131: a button to run with beside the joystick, besides pushing past its ring; off by default. */
    var runButton by mutableStateOf(prefs.getBoolean(KEY_RUN_BUTTON, false))
        private set

    fun toggleRunButton() {
        runButton = !runButton
        prefs.edit().putBoolean(KEY_RUN_BUTTON, runButton).apply()
    }

    /** 6l: the map one step nearer (5.6 tiles across) instead of the default 6.75; kept across starts (`MapZoom`). */
    var mapNear by mutableStateOf(prefs.getBoolean(KEY_MAP_NEAR, false))
        private set

    init {
        MapZoom.level = if (mapNear) 0 else 1
    }

    fun changeMapNear(near: Boolean) {
        mapNear = near
        MapZoom.level = if (near) 0 else 1
        prefs.edit().putBoolean(KEY_MAP_NEAR, near).apply()
        refresh()
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

    /** 40a: the three sliders, 0–100 %; the place's sounds go with the effects. The switches above stay as mutes. */
    var volumeAll by mutableIntStateOf(Mix.clamp(prefs.getInt(KEY_VOL_ALL, Mix.FULL)))
        private set
    var volumeMusic by mutableIntStateOf(Mix.clamp(prefs.getInt(KEY_VOL_MUSIC, Mix.FULL)))
        private set
    var volumeFx by mutableIntStateOf(Mix.clamp(prefs.getInt(KEY_VOL_FX, Mix.FULL)))
        private set

    init { applyVolume() }

    private fun applyVolume() {
        music.gain = Mix.gain(volumeAll, volumeMusic)
        Mix.gain(volumeAll, volumeFx).let { sfx.gain = it; music.bedGain = it }
    }

    fun changeVolumeAll(v: Int) {
        volumeAll = Mix.clamp(v)
        prefs.edit().putInt(KEY_VOL_ALL, volumeAll).apply()
        applyVolume()
    }

    /** Moving the slider of a muted part switches it on: a slider set but silent would only puzzle. */
    fun changeVolumeMusic(v: Int) {
        volumeMusic = Mix.clamp(v)
        prefs.edit().putInt(KEY_VOL_MUSIC, volumeMusic).apply()
        if (!musicOn && volumeMusic > 0) toggleMusic()
        applyVolume()
    }

    fun changeVolumeFx(v: Int) {
        volumeFx = Mix.clamp(v)
        prefs.edit().putInt(KEY_VOL_FX, volumeFx).apply()
        if (!sfxOn && volumeFx > 0) toggleSfx()
        applyVolume()
    }

    /** 13e.6: lifts the black for dark screens, 0 % (nothing) to 100 % ([Mix.LIFT_MAX]); for all heroes, not per save. */
    var brightness by mutableIntStateOf(Mix.clamp(prefs.getInt(KEY_BRIGHT, 0)))
        private set

    fun changeBrightness(v: Int) {
        brightness = Mix.clamp(v)
        prefs.edit().putInt(KEY_BRIGHT, brightness).apply()
    }

    override fun onCleared() {
        music.release()
        sfx.release()
    }

    var menuOpen by mutableStateOf(false)

    /** 86.2: the menu was opened by the map sign in the bar: it shows the map, and the sign or Back leads straight back into the game. */
    var mapDirect by mutableStateOf(false)

    fun openMap() {
        mapDirect = true
        menuOpen = true
    }
    var toast by mutableStateOf<String?>(null)

    /** 72.10: the probe of the new fight against Grak, from the test menu; null when none runs. */
    var probe by mutableStateOf<de.bornim.core.Skirmish?>(null)
    var probeClass by mutableStateOf(CharClass.FIGHTER)

    /** 201: the MARS rules page before a trial fight started from the system menu. */
    var marsRules by mutableStateOf(false)

    /** 72.10a.10: the roll with its numbers shows briefly over its target; can be switched off. */
    var showRolls by mutableStateOf(prefs.getBoolean(KEY_ROLLS, true))
        private set

    fun toggleRolls() {
        showRolls = !showRolls
        prefs.edit().putBoolean(KEY_ROLLS, showRolls).apply()
    }

    /** 229.1: the places of both sides as outlines on the ground in MARS, switched by the grid sign; off at first. */
    var showGrid by mutableStateOf(prefs.getBoolean(KEY_GRID, false))
        private set

    fun toggleGrid() {
        showGrid = !showGrid
        prefs.edit().putBoolean(KEY_GRID, showGrid).apply()
    }

    /** 72.10a.6: the one sentence on the rows was shown in the first new fight. */
    var rowHintSeen by mutableStateOf(prefs.getBoolean(KEY_ROW_HINT, false))
        private set

    fun markRowHintSeen() {
        rowHintSeen = true
        prefs.edit().putBoolean(KEY_ROW_HINT, true).apply()
    }

    /** 210: the intents whose "insight" line the hero already had; MARS runs only as the probe, so kept for the device, not the save. */
    var insightsSeen by mutableStateOf(prefs.getString(KEY_INSIGHTS, "").orEmpty().split(',').filter { it.isNotEmpty() }.toSet())
        private set

    fun markInsightSeen(id: String) {
        insightsSeen = insightsSeen + id
        prefs.edit().putString(KEY_INSIGHTS, insightsSeen.joinToString(",")).apply()
    }

    /** 130.3: the foes of the next probe, chosen in the test tab. */
    var probeFoe by mutableStateOf(de.bornim.core.Skirmish.Companion.ProbeFoe.GRAK)

    /** 259: the level of hero and Söldner in the next probe, chosen in the test tab, to try light fights; level 3 otherwise. */
    var probeLevel by mutableIntStateOf(de.bornim.core.Skirmish.PROBE_LEVEL)

    fun startProbe(merc: CharClass) {
        val g = game ?: return
        probeClass = merc
        probe = de.bornim.core.Skirmish.probe(g.state, merc, lang, probeFoe, level = probeLevel)
    }

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
        return SlotInfo(n, h.name, h.race, h.cls, h.level, s.place.map, s.day, s.minutes, prefs.getLong(slotKey(n) + "_at", 0L), s.playedMs, h)
    }

    fun slots(): List<SlotInfo?> = (1..SLOTS).map { slotInfo(it) }

    val hasSave: Boolean get() = (1..SLOTS).any { prefs.contains(slotKey(it)) }

    /** The hero played last, for "Continue" on the title screen. */
    val lastSave: SlotInfo? get() = slotInfo(prefs.getInt(KEY_LAST_SLOT, 1)) ?: slots().filterNotNull().maxByOrNull { it.savedAt }

    /** First empty slot, or null if all are taken. */
    val freeSlot: Int? get() = (1..SLOTS).firstOrNull { !prefs.contains(slotKey(it)) }

    /** 132: counts the time played while the game shows and the app is in front. */
    private val playClock = de.bornim.core.PlayClock()
    private fun now() = System.nanoTime() / 1_000_000

    /** 132: the app comes to the front; the count goes on if a hero is played. */
    fun resumePlayClock() {
        if (game != null && screen == Screen.PLAYING) playClock.start(now())
    }

    /** 132: the app goes to the back; call after [save], which booked the time. */
    fun pausePlayClock() = playClock.drop()

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
        playClock.drop()
        playClock.start(now())
        // 69: the arrival by night, once, before Rowena wakes the hero
        introPicture = 0
        intro = de.bornim.game.ui.IntroLook.auto
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
        playClock.drop()
        playClock.start(now())
        g.begin()
        prepareFigures(g)
        refresh()
    }

    /** Starts drawing the ground of this map, the hero and its folk as dolls in the background, so they are ready when the map shows. */
    private fun prepareFigures(g: Game) {
        val map = de.bornim.core.World[g.state.place.map]
        de.bornim.core.art.MapGround.prepare(map, g.state.place.x, g.state.place.y)
        de.bornim.core.art.MapSun.prepare(map)
        de.bornim.core.art.MapFigure.out = !g.torchBurns
        de.bornim.core.art.MapFigure.prepare(g.state.hero, de.bornim.core.art.MapFigure.yawOf(g.state.place.facing))
        bagSeen = null
        de.bornim.core.art.MapFolk.prepareFor(map)
    }

    /** The loot in the bag already seen, so only new loot is drawn ahead (24.15); null until the game has begun. */
    private var bagSeen: MutableSet<Long>? = null

    /** 24.15: new loot the hero could wear is drawn ahead in the background, so putting it on is at once. */
    private fun drawLootAhead(g: Game) {
        val bag = g.state.bag
        val seen = bagSeen ?: bag.mapTo(HashSet()) { it.uid }.also { bagSeen = it }
        if (bag.size == seen.size && bag.all { it.uid in seen }) return
        for (it in bag) if (seen.add(it.uid)) de.bornim.core.art.MapFigure.ahead(g.state.hero, it)
    }

    fun save() {
        val g = game ?: return
        if (screen != Screen.PLAYING) return
        playClock.book(g.state, now())
        prefs.edit().putString(slotKey(slot), g.state.toJson()).putLong(slotKey(slot) + "_at", System.currentTimeMillis()).apply()
        slotsVersion++
    }

    fun refresh() {
        // 119: the sounds take on the room the hero is in (also in a fight there)
        game?.let { g -> de.bornim.core.World.maps[g.state.place.map]?.let { sfx.room = de.bornim.core.audio.PlaceSound.kindOf(it) } }
        game?.sounds?.let { q -> while (q.isNotEmpty()) sfx.play(q.removeFirst()) }
        game?.placedSounds?.let { q -> while (q.isNotEmpty()) q.removeFirst().let { (s, v) -> sfx.play(s, v) } }
        val g = game
        if (g != null && g.mapChanged) {
            g.mapChanged = false
            de.bornim.core.World[g.state.place.map].let { m ->
                de.bornim.core.art.MapGround.prepare(m, g.state.place.x, g.state.place.y)
                de.bornim.core.art.MapSun.prepare(m)
                de.bornim.core.art.MapFolk.prepareFor(m)
            }
            save()
        }
        if (g != null) drawLootAhead(g)
        tick++
    }

    fun toTitle() {
        save()
        playClock.drop()
        menuOpen = false
        screen = Screen.TITLE
    }

    companion object {
        /** Number of save slots. */
        const val SLOTS = 4
        /** The single save of versions before slots; moved to slot 1. */
        private const val KEY_SAVE = "save"
        private const val KEY_LAST_SLOT = "last_slot"
        private const val KEY_LANG = "lang"
        private const val KEY_MUSIC = "music"
        private const val KEY_SFX = "sfx"
        private const val KEY_STEPS = "steps"
        private const val KEY_TEST = "test_mode"
        private const val KEY_QUOTE = "veil_quote"
        private const val KEY_CONTROLS = "controls"
        private const val KEY_LEFT = "left_handed"
        private const val KEY_HAPTICS = "haptics"
        private const val KEY_ROLLS = "show_rolls"
        private const val KEY_GRID = "mars_grid"
        private const val KEY_ROW_HINT = "row_hint_seen"
        private const val KEY_INSIGHTS = "insights_seen"
        private const val KEY_CONFIRM = "confirmations"
        private const val KEY_BLOOD = "blood"
        private const val KEY_TEMPO = "battle_tempo"
        private const val KEY_AUTO = "battle_auto"
        private const val KEY_STICK = "stick_feel"
        private const val KEY_RUN_BUTTON = "run_button"
        private const val KEY_MAP_NEAR = "map_near"
        private const val KEY_VOL_ALL = "volume_all"
        private const val KEY_VOL_MUSIC = "volume_music"
        private const val KEY_VOL_FX = "volume_fx"
        private const val KEY_BRIGHT = "brightness"
    }
}


/** How a new hero looks, as chosen at creation. */
data class Look(val sex: de.bornim.core.Sex, val build: de.bornim.core.Build, val skin: Int, val hair: Int)
