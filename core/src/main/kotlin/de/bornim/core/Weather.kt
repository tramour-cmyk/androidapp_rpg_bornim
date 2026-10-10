package de.bornim.core

/**
 * The weather switch in the test tab (10.10., 1a): rain comes and goes by chance as in the game,
 * or it always rains, or it never does.
 */
object Weather {
    enum class Mode { RANDOM, ALWAYS, NEVER }

    @Volatile var mode = Mode.RANDOM

    /** How long rain takes to set in or to stop, in ms of play: it thickens and thins, never just switches. */
    const val FADE_MS = 9000f

    /** Each minute of game time in heavy rain out of doors, the chance of distant sheet lightning (1c: very rarely). */
    const val FLASH_CHANCE = 1.0 / 300

    /** How long after a flash the thunder rolls in, in ms: the storm is far off. */
    val THUNDER_DELAY = 1800L..4200L
}
