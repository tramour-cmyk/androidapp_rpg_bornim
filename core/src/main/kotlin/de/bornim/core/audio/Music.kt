package de.bornim.core.audio

import de.bornim.core.MapKind
import kotlin.random.Random

/** Where the player is, as far as the music cares (28). */
/** [INTRO]: the intro's pictures before its black one: the title music, quietly under the sounds (69c, 69f). */
/** [PRELUDE]: silence under the firm's logo and its sound at a cold start, before the title music (292.1). */
enum class MusicScene { TITLE, VILLAGE, FOREST, CAVE, BATTLE, BOSS, CHAPTER_END, INTRO, TEMPLE, PRELUDE }

/** One recorded piece in `assets/music` (without the `.ogg`). [loop]: plays on until the scene changes. */
data class Track(val name: String, val loop: Boolean = false)

/**
 * What should be heard now: a piece of music (or none), a sound bed under it (cave), and how quickly to fade to it;
 * [level]: the music's loudness against its usual one (quieter under the intro's pictures, 69f; fainter as a hunter
 * comes near, silent once it has noticed the hero, 120).
 * 120: [layer] is the dark layer over it (looped, [layerLevel] 1 at its full loudness), [dark] how much the music is
 * muffled (0 open, 1 only its low part); [shadeMs]: how quickly the same piece, the layer and the muffling follow.
 */
data class MusicWant(
    val music: Track?, val bed: String?, val fadeMs: Int, val level: Float = 1f,
    val layer: String? = null, val layerLevel: Float = 0f, val dark: Float = 0f, val shadeMs: Int = fadeMs,
)

/**
 * 120: the nearest hunter, as far as the music cares. [near]: 0 at [FAR_TILES] or farther, 1 where it would notice the
 * hero; [noticed]: one hunts the hero now (the fight is only steps away).
 */
data class Threat(val near: Float = 0f, val noticed: Boolean = false) {
    companion object {
        val NONE = Threat()
        /** From how far away a hunter starts to darken the music, in tiles (Beschluss 120: about 8). */
        const val FAR_TILES = 8
    }
}

/** The recorded music (28, all CC0; sources in `tools/klang/QUELLEN.md`), named after the scene it plays in. */
object MusicLib {
    val title = Track("titel_adventure_intro", loop = true)
    val victory = Track("sieg_heros_reprise")
    val chapterEnd = Track("ende_new_sunrise")
    val village = listOf("dorf_minstrel_dance", "dorf_lament", "dorf_small_fire")
    val forest = listOf("wald_beautiful_forest", "wald_dark_forest", "wald_dark_woods", "wald_adventurers_path", "wald_eternal_light")
    val cave = listOf(
        "hoehle_mysterious", "hoehle_night_of_the_streets", "hoehle_mysterious_orchestral", "hoehle_dark_theme",
        "hoehle_graveyard", "hoehle_dark_castle", "hoehle_arcanum",
    )
    /** Sound beds for the cave: always under everything there, looped. */
    val caveBeds = listOf(
        "grund_dark_cavern", "grund_deep_humidity", "grund_dungeon_ambience", "grund_forgotten_tombs", "grund_loopable_dungeon",
        "grund_eternal_sleep", "grund_fs_38963", "grund_fs_460459", "grund_fs_516566", "grund_fs_530161",
    )
    val battle = listOf(
        "kampf_evil_approach", "kampf_determined_pursuit", "kampf_corrupted_minds", "kampf_eclipse_legion",
        "kampf_battlefield", "kampf_devils_dome", // 281: kampf_orchestral_battle out, it has electric guitars
    )
    val boss = listOf("boss_fall_of_nightmares", "boss_fantasy_choir1", "boss_fantasy_choir2")
    /** 120: the dark layers that creep in as a hunter comes near (cello, stretched celli, low strings), in turn. */
    val layers = listOf("spur_cello", "spur_gedehnt", "spur_tief")
    /** Too stately for a fight (37a): kept for the Sun Amulet's return to the temple, not yet played anywhere. */
    val amuletReturn = Track("boss_ancient_legend")

    val all: List<String> get() = listOf(title.name, victory.name, chapterEnd.name, amuletReturn.name) + village + forest + cave + caveBeds + battle + boss + layers

    fun pool(scene: MusicScene): List<String> = when (scene) {
        MusicScene.VILLAGE -> village
        MusicScene.FOREST -> forest
        MusicScene.CAVE -> cave
        MusicScene.BATTLE -> battle
        MusicScene.BOSS -> boss
        MusicScene.TITLE, MusicScene.INTRO -> listOf(title.name)
        MusicScene.CHAPTER_END -> listOf(chapterEnd.name)
        MusicScene.TEMPLE -> listOf(amuletReturn.name)
        MusicScene.PRELUDE -> emptyList()
    }

    fun sceneOf(kind: MapKind): MusicScene = when (kind) {
        MapKind.TOWN, MapKind.INTERIOR -> MusicScene.VILLAGE
        MapKind.FOREST -> MusicScene.FOREST
        MapKind.CAVE -> MusicScene.CAVE
    }
}

/**
 * 319 (Chef 22.10., 22:00 „Effektgeräusche in der Blende machen für mich auch keinen Sinn“): what a black screen lets
 * through. While it stands no new music and no effects; once it is gone, the effects come up over [EFFECTS_RISE_MS],
 * new music only after [MusicDirector.PAUSE_MS] more. Told every tick whether a screen stands.
 */
class VeilGate {
    private var veiled = false
    /** When the last screen went; long ago before the first. */
    private var endedAt = Long.MIN_VALUE / 2

    fun update(veiledNow: Boolean, timeMs: Long) {
        if (veiled && !veiledNow) endedAt = timeMs
        veiled = veiledNow
    }

    /** A screen stands. */
    val closed: Boolean get() = veiled

    /** A new piece of music may begin. */
    fun musicMay(timeMs: Long): Boolean = !veiled && timeMs - endedAt >= MusicDirector.PAUSE_MS

    /** How loud the effects may be, 0 in the screen to 1. */
    fun effects(timeMs: Long): Float = if (veiled) 0f else ((timeMs - endedAt).toFloat() / EFFECTS_RISE_MS).coerceIn(0f, 1f)

    companion object {
        const val EFFECTS_RISE_MS = 400L
        /** Heard even in the screen: they answer the tap that brought it (the door one goes through, a button). */
        val THROUGH = setOf(Sound.CLICK, Sound.DOOR)
    }
}

/**
 * Decides which piece plays (28.1). Pure and driven by the clock, so the rules are tested in the core:
 * - never the same piece twice in a row (per scene), the next one chosen at random;
 * - out in the world a piece plays once, then 10–30 s of silence; in the cave the bed runs on and music comes only now and then;
 * - 319 (Chef 22.10., 22:00): place to place and into a fight the old piece dies away (~2 s, into a fight quickly), then a
 *   short pause ([PAUSE_MS]); the new one starts only once the black screen is gone ([update]'s `veiled`) and the pause
 *   after it is over; the cave's bed waits for the screen as well. After a won fight the victory piece, then the place;
 * - the title music carries the intro (69f): quietly under its pictures, fuller with the black one; it goes on if it is
 *   already playing, else starts quietly from the top; in the game it dies away over [TITLE_OUT_MS] before the place's music.
 * - 120, music in layers: out in the world a hunter coming near darkens and quietens the music while a dark layer creeps in
 *   (each approach the next of [MusicLib.layers]); turning away, it all eases back; once it notices the hero, silence
 *   until the fight's music cuts in.
 * The player asks [update] a few times a second and tells it which piece has run out.
 */
class MusicDirector(seed: Long = System.nanoTime()) {
    private val rnd = Random(seed)
    private val last = HashMap<MusicScene, String>()
    private var scene: MusicScene? = null
    private var music: Track? = null
    private var bed: String? = null
    private var lastBed: String? = null
    /** No music before this time (silence between pieces). */
    private var quietUntil = 0L
    private var fadeMs = PLACE_FADE_MS
    private var victoryPending = false
    private var layer: String? = null
    private var lastLayer: String? = null
    /** When the layer last had something to do: it is let go a while later, once it has faded out. */
    private var layerSeen = 0L
    /** 319: the black screens between places and before fights. */
    private val gate = VeilGate()
    /** 319: the bed last handed out: a new one waits for the end of the black screen, the same one plays on. */
    private var heardBed: String? = null

    /** A fight was won: the victory piece plays before the place's music comes back. */
    fun victory() { victoryPending = true }

    /** [finished]: the piece that has just played to its end, if any; [veiled]: a black screen stands (319). */
    fun update(s: MusicScene, timeMs: Long, finished: String? = null, threat: Threat = Threat.NONE, veiled: Boolean = false): MusicWant {
        gate.update(veiled, timeMs)
        if (finished != null && finished == music?.name) {
            music = null
            fadeMs = PLACE_FADE_MS
            quietUntil = timeMs + if (s == MusicScene.CAVE) rnd.nextLong(CAVE_QUIET_MIN_MS, CAVE_QUIET_MAX_MS + 1) else rnd.nextLong(QUIET_MIN_MS, QUIET_MAX_MS + 1)
        }
        if (s != scene) enter(s, timeMs)
        if (music == null && timeMs >= quietUntil && gate.musicMay(timeMs) && s != MusicScene.CHAPTER_END && s != MusicScene.INTRO && s != MusicScene.TEMPLE && s != MusicScene.PRELUDE) {
            val fight = s == MusicScene.BATTLE || s == MusicScene.BOSS
            music = Track(pick(s), loop = fight); fadeMs = if (fight) FIGHT_FADE_MS else PLACE_FADE_MS
        }
        val level = if (s == MusicScene.INTRO) INTRO_LEVEL else 1f
        // 319: a new bed only after the black screen (a place's sound, as the effects)
        val b = if (bed == heardBed || !gate.closed) bed else null
        heardBed = b
        // 120: out in the world and in the cave, not in the village
        if (s != MusicScene.FOREST && s != MusicScene.CAVE) {
            layer = null
            return MusicWant(music, b, fadeMs, level)
        }
        return shade(MusicWant(music, b, fadeMs, level), timeMs, threat)
    }

    /** 120: the nearest hunter's shadow over the place's music (form of sample 1, 16.10.). */
    private fun shade(w: MusicWant, timeMs: Long, t: Threat): MusicWant {
        val near = t.near.coerceIn(0f, 1f)
        if (near > 0f || t.noticed) {
            if (layer == null) layer = MusicLib.layers.filter { it != lastLayer }.let { it[rnd.nextInt(it.size)] }.also { lastLayer = it }
            layerSeen = timeMs
        } else if (timeMs - layerSeen > LAYER_HOLD_MS) layer = null
        return w.copy(
            level = if (t.noticed) 0f else w.level * (1f - DIM * near),
            layer = layer,
            layerLevel = if (t.noticed) 0f else near,
            dark = DARK * near,
            shadeMs = if (t.noticed) NOTICE_FADE_MS else PLACE_FADE_MS,
        )
    }

    private fun enter(s: MusicScene, timeMs: Long) {
        val from = scene
        scene = s
        val fight = s == MusicScene.BATTLE || s == MusicScene.BOSS
        // the cave keeps its bed through a fight; a new visit gets another one
        bed = when {
            s == MusicScene.CAVE -> if (from == MusicScene.BATTLE || from == MusicScene.BOSS) lastBed ?: pickBed() else pickBed()
            else -> null
        }
        when {
            // 319: the old piece goes quickly, the fight's after the black screen and a short pause
            fight -> { music = null; fadeMs = FIGHT_FADE_MS; quietUntil = timeMs + FIGHT_FADE_MS + PAUSE_MS; victoryPending = false }
            // the same piece: the player lets it run on and only changes its loudness
            s == MusicScene.TITLE || s == MusicScene.INTRO -> { music = MusicLib.title; fadeMs = PLACE_FADE_MS }
            // 292.1: the firm's sound alone, then a heard pause; the title music only with the game's name
            s == MusicScene.PRELUDE -> { music = null; fadeMs = FIGHT_FADE_MS }
            s == MusicScene.CHAPTER_END -> { music = MusicLib.chapterEnd; fadeMs = PLACE_FADE_MS }
            // 68: the temple scene has its own piece, „Ancient Legend“, once
            s == MusicScene.TEMPLE -> { music = MusicLib.amuletReturn; fadeMs = PLACE_FADE_MS }
            // from the title or the intro into the game: the title music dies away, then the place's music (69f)
            from == MusicScene.TITLE || from == MusicScene.INTRO -> {
                music = null; fadeMs = TITLE_OUT_MS
                quietUntil = timeMs + if (s == MusicScene.CAVE) rnd.nextLong(CAVE_FIRST_MIN_MS, CAVE_FIRST_MAX_MS + 1) else TITLE_OUT_MS + PAUSE_MS
            }
            victoryPending && (from == MusicScene.BATTLE || from == MusicScene.BOSS) -> {
                victoryPending = false
                music = MusicLib.victory; fadeMs = FIGHT_FADE_MS
            }
            // back from a fight without a win: the place again after a short pause
            from == MusicScene.BATTLE || from == MusicScene.BOSS -> {
                music = null; fadeMs = PLACE_FADE_MS; quietUntil = timeMs + QUIET_MIN_MS
            }
            // into the cave: first only the bed, the music joins after a while
            s == MusicScene.CAVE -> { music = null; fadeMs = PLACE_FADE_MS; quietUntil = timeMs + rnd.nextLong(CAVE_FIRST_MIN_MS, CAVE_FIRST_MAX_MS + 1) }
            // 319: place to place no longer across each other: the old piece dies away, a short pause, then the new one
            // (nothing before it: at once)
            else -> { music = null; fadeMs = PLACE_FADE_MS; quietUntil = timeMs + if (from == null) 0L else PLACE_FADE_MS + PAUSE_MS }
        }
    }

    private fun pick(s: MusicScene): String {
        val pool = MusicLib.pool(s)
        val choices = pool.filter { it != last[s] }.ifEmpty { pool }
        return choices[rnd.nextInt(choices.size)].also { last[s] = it }
    }

    private fun pickBed(): String {
        val choices = MusicLib.caveBeds.filter { it != lastBed }
        return choices[rnd.nextInt(choices.size)].also { lastBed = it }
    }

    companion object {
        const val PLACE_FADE_MS = 2000
        const val FIGHT_FADE_MS = 300
        /** How long the title music takes to die away in the game (69f, „etwa 6 s“). */
        const val TITLE_OUT_MS = 6000
        /** 319: the short silence between the old piece and the new one, and after a black screen (Chef: „kurze Pause“). */
        const val PAUSE_MS = 1000L
        /** The title music under the intro's pictures, against its usual loudness (69f: leaves room for its sounds, 69c). */
        const val INTRO_LEVEL = 0.4f
        const val QUIET_MIN_MS = 10_000L
        const val QUIET_MAX_MS = 30_000L
        const val CAVE_FIRST_MIN_MS = 20_000L
        const val CAVE_FIRST_MAX_MS = 45_000L
        const val CAVE_QUIET_MIN_MS = 45_000L
        const val CAVE_QUIET_MAX_MS = 120_000L
        /** 120: how much quieter the music gets with the hunter at hand (sample 1: to 45 %), and how muffled. */
        const val DIM = 0.55f
        const val DARK = 0.8f
        /** 120: noticed, the music and the layer fall silent this quickly (sample 1: 0.4 s). */
        const val NOTICE_FADE_MS = 400
        /** 120: the layer is kept this long after the hunter has gone, so it fades out instead of changing. */
        const val LAYER_HOLD_MS = 4000L
    }
}
