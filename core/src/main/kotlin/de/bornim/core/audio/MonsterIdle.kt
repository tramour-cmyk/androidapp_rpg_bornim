package de.bornim.core.audio

import kotlin.random.Random

/**
 * What a monster on the map sounds like while it is not hunting (D3.9): now and then a sniff, a grunt, rattling bones,
 * a moan. Only close by and softer the further off; never two at once, so a herd does not chatter (DESIGN-STIL.md,
 * Klang: what one sees, sounds itself). Recordings cut with tools/klang/ruhe.py.
 */
object MonsterIdle {
    /** Beyond this many tiles (steps) a monster is not heard; within [NEAR] at its loudest. */
    const val FAR = 7
    const val NEAR = 2
    const val LOUD = 0.55f
    /** Each monster is heard again after this long, at random within the span. */
    const val PAUSE_MIN_MS = 7_000L
    const val PAUSE_SPAN_MS = 9_000L
    /** At least this long between two monsters being heard. */
    const val GAP_MS = 1_800L

    val SOUNDS = listOf(
        Sound.IDLE_WOLF, Sound.IDLE_BOAR, Sound.IDLE_GOBLIN, Sound.IDLE_KOBOLD, Sound.IDLE_GIANT_RAT, Sound.IDLE_GIANT_BAT, Sound.IDLE_STIRGE,
        Sound.IDLE_GIANT_SPIDER, Sound.IDLE_GIANT_CENTIPEDE, Sound.IDLE_SKELETON, Sound.IDLE_ZOMBIE, Sound.IDLE_GHOUL, Sound.IDLE_OCHRE_JELLY,
    )

    /** The sound of the monster [id] at rest; null for one that has none. */
    fun of(id: String): Sound? = when (id) {
        "wolf", "dire_wolf" -> Sound.IDLE_WOLF
        "boar" -> Sound.IDLE_BOAR
        "goblin", "goblin_archer", "goblin_shaman" -> Sound.IDLE_GOBLIN
        "kobold" -> Sound.IDLE_KOBOLD
        "giant_rat" -> Sound.IDLE_GIANT_RAT
        "giant_bat" -> Sound.IDLE_GIANT_BAT
        "stirge" -> Sound.IDLE_STIRGE
        "giant_spider" -> Sound.IDLE_GIANT_SPIDER
        "giant_centipede" -> Sound.IDLE_GIANT_CENTIPEDE
        "skeleton" -> Sound.IDLE_SKELETON
        "zombie" -> Sound.IDLE_ZOMBIE
        "ghoul" -> Sound.IDLE_GHOUL
        "ochre_jelly" -> Sound.IDLE_OCHRE_JELLY
        else -> null
    }

    /** How loud a monster [dist] tiles off is heard: full within [NEAR], fading to nothing at [FAR]. */
    fun volume(dist: Int): Float =
        if (dist >= FAR) 0f else LOUD * ((FAR - maxOf(dist, NEAR)).toFloat() / (FAR - NEAR))

    /** The pause until a monster is heard again. */
    fun pause(rnd: Random): Long = PAUSE_MIN_MS + rnd.nextLong(PAUSE_SPAN_MS)
}
