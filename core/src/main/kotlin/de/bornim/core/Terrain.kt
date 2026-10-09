package de.bornim.core

/**
 * How the ground slows you down on the map: on a trodden path or paving you walk briskly, through
 * tall grass and rubble you wade (in the spirit of difficult terrain in the SRD). Applies to the
 * hero and to monsters roaming the map alike. Only the time a step takes changes, not the rules.
 */
object Terrain {
    /** How long a step onto [tile] takes, relative to a step on open grass. */
    fun stepFactor(tile: Tile): Double = when (tile) {
        Tile.PATH, Tile.COBBLE, Tile.BRIDGE -> 0.85
        Tile.FLOWERS, Tile.BONES, Tile.GLOWSHROOM -> 1.1
        Tile.RUBBLE -> 1.3
        Tile.TALL_GRASS -> 1.5
        else -> 1.0
    }
}
