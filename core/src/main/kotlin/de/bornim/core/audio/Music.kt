package de.bornim.core.audio

import de.bornim.core.MapKind
import kotlin.random.Random

/** Where the player is, as far as the music cares (28). */
enum class MusicScene { TITLE, VILLAGE, FOREST, CAVE, BATTLE, BOSS, CHAPTER_END }

/** One recorded piece in `assets/music` (without the `.ogg`). [loop]: plays on until the scene changes. */
data class Track(val name: String, val loop: Boolean = false)

/** What should be heard now: a piece of music (or none), a sound bed under it (cave), and how quickly to fade to it. */
data class MusicWant(val music: Track?, val bed: String?, val fadeMs: Int)

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
        "grund_eternal_sleep", "grund_fs_38963", "grund_fs_460459", "grund_fs_516566", "grund_fs_530161", "grund_fs_540836", "grund_fs_609422",
    )
    val battle = listOf(
        "kampf_evil_approach", "kampf_determined_pursuit", "kampf_corrupted_minds", "kampf_eclipse_legion",
        "kampf_orchestral_battle", "kampf_battlefield", "kampf_devils_dome",
    )
    val boss = listOf("boss_fall_of_nightmares", "boss_fantasy_choir1", "boss_fantasy_choir2")
    /** Too stately for a fight (37a): kept for the Sun Amulet's return to the temple, not yet played anywhere. */
    val amuletReturn = Track("boss_ancient_legend")

    val all: List<String> get() = listOf(title.name, victory.name, chapterEnd.name, amuletReturn.name) + village + forest + cave + caveBeds + battle + boss

    fun pool(scene: MusicScene): List<String> = when (scene) {
        MusicScene.VILLAGE -> village
        MusicScene.FOREST -> forest
        MusicScene.CAVE -> cave
        MusicScene.BATTLE -> battle
        MusicScene.BOSS -> boss
        MusicScene.TITLE -> listOf(title.name)
        MusicScene.CHAPTER_END -> listOf(chapterEnd.name)
    }

    fun sceneOf(kind: MapKind): MusicScene = when (kind) {
        MapKind.TOWN, MapKind.INTERIOR -> MusicScene.VILLAGE
        MapKind.FOREST -> MusicScene.FOREST
        MapKind.CAVE -> MusicScene.CAVE
    }
}

/**
 * Decides which piece plays (28.1). Pure and driven by the clock, so the rules are tested in the core:
 * - never the same piece twice in a row (per scene), the next one chosen at random;
 * - out in the world a piece plays once, then 10–30 s of silence; in the cave the bed runs on and music comes only now and then;
 * - place to place a soft crossfade (~2 s), into a fight at once, after a won fight the victory piece, then the place again.
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

    /** A fight was won: the victory piece plays before the place's music comes back. */
    fun victory() { victoryPending = true }

    /** [finished]: the piece that has just played to its end, if any. */
    fun update(s: MusicScene, timeMs: Long, finished: String? = null): MusicWant {
        if (finished != null && finished == music?.name) {
            music = null
            fadeMs = PLACE_FADE_MS
            quietUntil = timeMs + if (s == MusicScene.CAVE) rnd.nextLong(CAVE_QUIET_MIN_MS, CAVE_QUIET_MAX_MS + 1) else rnd.nextLong(QUIET_MIN_MS, QUIET_MAX_MS + 1)
        }
        if (s != scene) enter(s, timeMs)
        if (music == null && timeMs >= quietUntil && s != MusicScene.CHAPTER_END) music = Track(pick(s))
        return MusicWant(music, bed, fadeMs)
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
            fight -> { music = Track(pick(s), loop = true); fadeMs = FIGHT_FADE_MS; victoryPending = false }
            s == MusicScene.TITLE -> { music = MusicLib.title; fadeMs = PLACE_FADE_MS }
            s == MusicScene.CHAPTER_END -> { music = MusicLib.chapterEnd; fadeMs = PLACE_FADE_MS }
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
            else -> { music = Track(pick(s)); fadeMs = PLACE_FADE_MS }
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
        const val QUIET_MIN_MS = 10_000L
        const val QUIET_MAX_MS = 30_000L
        const val CAVE_FIRST_MIN_MS = 20_000L
        const val CAVE_FIRST_MAX_MS = 45_000L
        const val CAVE_QUIET_MIN_MS = 45_000L
        const val CAVE_QUIET_MAX_MS = 120_000L
    }
}
