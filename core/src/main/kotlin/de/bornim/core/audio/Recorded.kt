package de.bornim.core.audio

/**
 * Sounds played from recordings (18): CC0 recordings cut with tools/klang, as app/src/main/assets/sfx/<name>_<n>.ogg.
 * A sound listed here is played from its files instead of being synthesized. The sounds that announce something (the
 * system sounds) come in one take only, so they are known at once; all others come in at least three (STIL.md, Klang).
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
    )

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
