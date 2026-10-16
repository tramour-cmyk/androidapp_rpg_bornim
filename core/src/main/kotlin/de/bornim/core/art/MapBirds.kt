package de.bornim.core.art

import de.bornim.core.MapDef
import de.bornim.core.Tile
import kotlin.math.hypot

/**
 * The small birds pecking on the grass and the paths by day: where they sit, when they hop, how far they have flown
 * off from the hero. The map draws them from here and the ear hears them from here (84), so a bird is heard flying up
 * when it is seen to. None in the deep forest (D3.2, D3.15): too dark and close under the old oaks.
 */
object MapBirds {
    /** A bird sits on one tile in [ONE_IN]. */
    private const val ONE_IN = 23
    /** The hero this close (map pixels, from his middle) starts it up; [FLEE_SPAN] further in it is gone. */
    const val FLEE_FROM = 80.0
    const val FLEE_SPAN = 30.0
    /** It hops every [HOP_EVERY] steps of [HOP_STEP_MS], one step long. */
    const val HOP_STEP_MS = 140L
    const val HOP_EVERY = 9L

    /** Whether birds are out at all: by day, not in the rain, not in the deep forest. */
    fun out(map: MapDef, daylight: Float, raining: Boolean) = daylight > 0.4f && !raining && map.id != "deep_forest"

    /** Whether a bird sits on tile ([tx], [ty]). */
    fun at(map: MapDef, tx: Int, ty: Int): Boolean {
        val t = map.tile(tx, ty)
        return (t == Tile.GRASS || t == Tile.PATH) && hash(tx, ty, 3) % ONE_IN == 0
    }

    /** Where the bird of tile ([tx], [ty]) sits, in map pixels. */
    fun x(tx: Int, ty: Int) = tx * WorldArt.T + 10f + hash(tx, ty, 4) % 12
    fun y(@Suppress("UNUSED_PARAMETER") tx: Int, ty: Int) = ty * WorldArt.T + 18f

    /** How far it has flown off, 0 sitting to 1 gone, with the hero's corner at map pixel ([heroX], [heroY]). */
    fun flee(tx: Int, ty: Int, heroX: Int, heroY: Int): Float {
        val d = hypot((x(tx, ty) - heroX - 16).toDouble(), (y(tx, ty) - heroY - 16).toDouble())
        return ((FLEE_FROM - d) / FLEE_SPAN).coerceIn(0.0, 1.0).toFloat()
    }

    /** Which hop it is at, at [clock] ms: a new number each time it hops. */
    fun hop(tx: Int, ty: Int, clock: Long) = (clock / HOP_STEP_MS + hash(tx, ty)) / HOP_EVERY

    /** Whether it is in the air of a hop at [clock] ms. */
    fun hopping(tx: Int, ty: Int, clock: Long) = (clock / HOP_STEP_MS + hash(tx, ty)) % HOP_EVERY == 0L

    fun hash(a: Int, b: Int, c: Int = 0): Int {
        var n = a * 374761393 + b * 668265263 + c * 1442695041
        n = (n xor (n ushr 13)) * 1274126177
        return (n xor (n ushr 16)) and 0x7fffffff
    }
}
