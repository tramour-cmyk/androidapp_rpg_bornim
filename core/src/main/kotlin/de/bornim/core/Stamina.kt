package de.bornim.core

/**
 * 86.3 (Beschluss 14.10., 21:3x), 131 (17.10.): breath for running on the map. Running is short: the store lasts
 * about 6 s at Constitution 10, 2 s more or less for each point of the bonus and 1 s more for each two levels, and
 * is halved by heavy armor the hero is not strong enough for ([heavy]). It fills again in 40 s while walking and
 * 20 s while standing, at once with a rest. Run empty, the hero walks until a quarter is back. It is kept in
 * [GameState.stamina], so it counts across changes of map. The numbers are to be tuned in the test.
 */
object Stamina {
    const val WALK_REFILL_MS = 40_000.0
    const val STAND_REFILL_MS = 20_000.0
    /** 84.4: running is loud; monsters notice the hero this many tiles sooner (to be tuned in the test). */
    const val RUN_NOISE = 2
    /** Out of breath, the hero may run again from this much on. */
    const val AGAIN = 0.25

    /** How long a full store lasts while running, in ms; a stamina draught ([boost], 86.6) doubles it. */
    fun lastsMs(hero: Hero, boost: Boolean = false): Double {
        val s = (6.0 + 2.0 * hero.mod(Ability.CON) + hero.level / 2).coerceAtLeast(2.0)
        return s * 1000.0 * (if (heavy(hero)) 0.5 else 1.0) * (if (boost) 2.0 else 1.0)
    }

    /** Heavy armor on the body without the strength for it (Strength under 13, as chain mail in the SRD). */
    fun heavy(hero: Hero): Boolean = hero.item(GearSlot.CHEST)?.def?.weight == Weight.HEAVY && hero.score(Ability.STR) < 13

    /**
     * One frame of [dt] ms: the hero [moving], wanting to [run]. Returns whether he does run: not while out of
     * breath ([GameState.winded]), until a quarter of the store is back.
     */
    fun step(state: GameState, dt: Long, moving: Boolean, run: Boolean): Boolean {
        val runs = moving && run && !state.winded
        state.stamina = when {
            runs -> state.stamina - dt / lastsMs(state.hero, state.staminaBoost)
            moving -> state.stamina + dt / WALK_REFILL_MS
            else -> state.stamina + dt / STAND_REFILL_MS
        }.coerceIn(0.0, 1.0)
        if (state.stamina <= 0.0) state.winded = true
        else if (state.winded && state.stamina >= AGAIN) state.winded = false
        state.running = runs && !state.winded
        return state.running
    }

    /** A rest fills the store. */
    fun refill(state: GameState) {
        state.stamina = 1.0
        state.winded = false
    }
}
