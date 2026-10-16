package de.bornim.core.audio

/**
 * Sounds played from recordings (18): CC0 recordings cut with tools/klang, as app/src/main/assets/sfx/<name>_<n>.ogg.
 * A sound listed here is played from its files instead of being synthesized. The sounds that announce something (the
 * system sounds) come in one take only, so they are known at once; all others come in at least three (DESIGN-STIL.md, Klang).
 */
object Recorded {
    /** How many takes of each recorded sound there are. */
    val TAKES: Map<Sound, Int> = mapOf(
        Sound.CLICK to 1, Sound.LEVEL_UP to 1, Sound.LOOT_EPIC to 1,
        Sound.LOOT to 3, Sound.COINS to 3, Sound.CHEST to 3, Sound.DOOR to 3, Sound.ENEMY_DOWN to 3,
        // second round (18f): the world, the fight, spells and draughts, the ambience
        Sound.ENCOUNTER to 1, Sound.ALERT to 3, Sound.AMBUSH to 3, Sound.HERO_DOWN to 3,
        Sound.FIRE to 3, Sound.MAGIC to 3, Sound.HOLY to 3, Sound.BUFF to 3, Sound.HEAL to 3, Sound.POISON to 3, Sound.POTION to 3, Sound.THROW to 3,
        Sound.BIRD to 3, Sound.CRICKET to 3, Sound.OWL to 3, Sound.DRIP to 3, Sound.CRACKLE to 3,
        // the sound of a place (24.8)
        Sound.WIND to 3, Sound.HALL to 3, Sound.CREAK to 3, Sound.HEARTBEAT to 3,
        Sound.CUP to 3, Sound.POUR to 3, Sound.WIPE to 3, Sound.CHAIR to 3, Sound.COUGH to 3,
        // the forest pond (27k, chosen by the user: three calls, one chorus, two dragonflies)
        Sound.FROG to 3, Sound.FROG_CHORUS to 1, Sound.DRAGONFLY to 2,
        // the village hens (83c; scratching: the straw broom, chosen by the user)
        Sound.HEN_CLUCK to 3, Sound.HEN_SCRATCH to 4, Sound.HEN_ALARM to 4, Sound.HEN_FLAP to 3,
        // the hero's steps (74, all five chosen by the user)
        Sound.STEP_GRASS to 3, Sound.STEP_EARTH to 3, Sound.STEP_COBBLE to 3, Sound.STEP_WOOD to 3, Sound.STEP_STONE to 3,
        // what lives at a place but is not in sight (84, D3.15)
        Sound.WOLF_FAR to 3, Sound.RUMBLE to 3, Sound.BIRD_FLAP to 3, Sound.BIRD_SCRATCH to 3,
    )

    /** Fewer than three takes by the user's choice (27k): the pond's one chorus loop, its two dragonflies. */
    val FEWER = setOf(Sound.FROG_CHORUS, Sound.DRAGONFLY)

    /** The asset path of take [take] (from 0) of [s]. */
    fun file(s: Sound, take: Int) = "sfx/${s.name.lowercase()}_${take + 1}.ogg"

    /** What a creature's voice is for. */
    enum class Cue(val file: String) { ATTACK("angriff"), HURT("schmerz"), DIE("tod") }

    /** The voices there are, three takes of each cue. */
    val VOICES = listOf("wolf", "goblin", "skeleton")
    const val VOICE_TAKES = 3

    fun voiceFile(voice: String, cue: Cue, take: Int) = "sfx/${voice}_${cue.file}_${take + 1}.ogg"

    /**
     * The voice of the monster [id] and how fast it is played (below 1: deeper and slower, for a bigger beast);
     * null for a monster without a voice yet.
     */
    fun voiceOf(id: String): Pair<String, Float>? = when (id) {
        "wolf" -> "wolf" to 1f
        "dire_wolf" -> "wolf" to 0.82f
        "goblin", "goblin_archer", "goblin_shaman" -> "goblin" to 1f
        "skeleton" -> "skeleton" to 1f
        else -> null
    }
}
