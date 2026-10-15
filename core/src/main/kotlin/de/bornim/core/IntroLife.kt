package de.bornim.core

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * 70.3 B (Nutzer 15.10.): quiet life over the intro's painted pictures. The picture stays painted; only what is light or air
 * moves (torch flames flicker, the light they throw breathes, chimney smoke rises), plus at most one slow event per picture,
 * once and never in a loop. Probe on picture 3 (`[69.intro.3]`, the square): the torch bearers walk their last steps up to
 * the temple door as one group; figures never move by themselves, only their way as a whole.
 *
 * Pure, so the preview's painter (`IntroProbe.kt` `SquarePainter`, which paints the group as its own layer) and the app
 * (which moves that layer and draws flames, light and smoke over it) read the same numbers.
 */
object IntroLife {
    /** The picture that has life so far (0-based: picture 3). */
    const val SQUARE = 2

    /** The camera of picture 3: screen x = W/2 + f·(x − camX)/z − pan, y = hy + f·(eye − y)/z, on a 1080 × 1200 picture. */
    const val W = 1080f
    const val H = 1200f
    const val F = 1080f
    const val HY = 560f
    const val EYE = 1.7f
    const val PAN = -20f
    fun sx(x: Float, z: Float) = W / 2 + F * x / z - PAN
    fun sy(y: Float, z: Float) = HY + F * (EYE - y) / z

    /** One torch bearer where the walk ends: (x, z) on the square, [h] hood height, [lean] of the hood, carries a [torch]. */
    data class Bearer(val x: Float, val z: Float, val torch: Boolean, val h: Float, val lean: Float) {
        /** Where the torch burns, relative to (x, 0, z): right of the hood, above it. */
        val tipX get() = x + 0.3f + lean
        val tipY get() = h + 0.25f
    }

    /** Back to front, as they are painted. */
    val bearers = listOf(
        Bearer(2.2f, 24.4f, true, 1.637f, -0.016f),
        Bearer(1.6f, 23.4f, false, 1.659f, -0.004f),
        Bearer(4.4f, 22.6f, true, 1.614f, 0.037f),
        Bearer(0.6f, 22.2f, true, 1.655f, 0.005f),
        Bearer(2.7f, 21.4f, true, 1.654f, 0.014f),
    )
    /** The group's middle depth: the painted layer is moved as if all stood there. */
    val groupZ get() = bearers.map { it.z }.average().toFloat()

    /** Where the group starts, relative to where it ends: a little to the left and nearer, so it walks up to the door. */
    const val WALK_DX = -2.4f
    const val WALK_DZ = -1.2f
    /** The walk, in ms after the picture starts to fade in: once, slowly, and it stands at the door before the next picture. */
    const val WALK_FROM = 600L
    const val WALK_TO = 6400L

    /** How far the walk has got at [u] ms into the picture (0..1, eased at both ends). */
    fun walk(u: Long): Float {
        val t = ((u - WALK_FROM).toFloat() / (WALK_TO - WALK_FROM)).coerceIn(0f, 1f)
        return t * t * (3 - 2 * t)
    }
    /** The group's offset in the world at [u]: (dx, dz), zero at the end of the walk. */
    fun offset(u: Long): Pair<Float, Float> { val r = 1 - walk(u); return WALK_DX * r to WALK_DZ * r }

    /**
     * The painted layer at [u] as a scale about the vanishing point (W/2 − PAN, HY) and then a shift to the right
     * (exact for a figure standing at [groupZ]): (scale, shiftX).
     */
    fun layer(u: Long): Pair<Float, Float> {
        val (dx, dz) = offset(u)
        val z = groupZ
        return z / (z + dz) to F * dx / (z + dz)
    }

    /** A flame's breath at [ms] (any clock), seeded per flame: about 0.8 .. 1.2, never in step with another flame. */
    fun flicker(seed: Int, ms: Long): Float {
        val t = ms / 1000f
        return 1f + 0.12f * sin(t * 9.3f + seed * 1.7f) + 0.06f * sin(t * 17.9f + seed * 4.1f) + 0.03f * sin(t * 31.3f + seed * 2.3f)
    }

    /** Where the chimney smoke of the left house leaves the pot (screen, picture 3). */
    val smokeX get() = sx(-7.89f, 16f)
    val smokeY get() = sy(8.0f, 16f)
    /** A puff of smoke needs this long to rise and thin out; puffs leave one after the other. */
    const val SMOKE_MS = 7000L
    const val SMOKE_PUFFS = 14

    /**
     * Puff [k] at [ms]: how far it has risen (0..1). The puffs keep coming (smoke is air, so it may run on); each starts at a
     * different moment.
     */
    fun puff(k: Int, ms: Long): Float = (((ms + k * SMOKE_MS / SMOKE_PUFFS) % SMOKE_MS).toFloat() / SMOKE_MS)

    /** The sideways drift of a puff that has risen [t] (0..1), in screen pixels: it bends off to the right and wavers. */
    fun drift(t: Float, k: Int) = t * t * 160f + sin(t * 9f + k) * 10f * t

    /** The puddle in the square (world x, z, half width): the torches mirror in it as warm streaks. */
    const val PUDDLE_X = 1.6f
    const val PUDDLE_Z = 5.6f
    const val PUDDLE_W = 1.1f
    /** Its outline on the screen, as the painter draws it. */
    fun puddle(): List<Pair<Float, Float>> = (0..28).map { j ->
        val a = 2 * PI.toFloat() * j / 28
        val wx = PUDDLE_X + cos(a) * PUDDLE_W * (0.85f + 0.2f * sin(a * 3 + 1))
        val wz = PUDDLE_Z + sin(a) * PUDDLE_W * 0.6f * (0.9f + 0.2f * cos(a * 2))
        sx(wx, wz) to sy(0f, wz)
    }

    /** A slow sway of the whole smoke, so it does not look like a conveyor belt. */
    fun sway(ms: Long) = sin(ms / 1000f * 2f * PI.toFloat() / 9f) * 6f
}
