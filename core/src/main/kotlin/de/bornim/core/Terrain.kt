package de.bornim.core

/**
 * How the ground slows you down on the map: on a trodden path or paving you walk briskly, through
 * tall grass and rubble you wade (in the spirit of difficult terrain in the SRD). Applies to the
 * hero and to monsters roaming the map alike. Only the time a step takes changes, not the rules.
 */
object Terrain {
    /**
     * Overall pace on the map: how much longer a step takes than it used to (since the map was
     * zoomed in, 09.10., the former pace looked hectic). Applies to the hero and roaming monsters.
     */
    const val PACE = 1.6

    /** How long a step onto [tile] takes, relative to a step on open grass. */
    fun stepFactor(tile: Tile): Double = when (tile) {
        Tile.PATH, Tile.COBBLE, Tile.BRIDGE -> 0.85
        Tile.FLOWERS, Tile.BONES, Tile.GLOWSHROOM -> 1.1
        Tile.RUBBLE, Tile.CLUTTER -> 1.3
        Tile.TALL_GRASS -> 1.5
        else -> 1.0
    }
}
