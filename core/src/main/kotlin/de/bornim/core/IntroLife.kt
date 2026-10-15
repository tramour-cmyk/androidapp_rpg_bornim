package de.bornim.core

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * 70.3 B (Nutzer 15.10.): quiet life over the intro's painted pictures. The picture stays painted; only what is light or air
 * moves (torch flames flicker, the light they throw breathes, chimney smoke rises), plus at most one slow event per picture,
 * once and never in a loop. Probe on picture 3 (`[69.intro.3]`, the temple by the square): the torch bearers walk their last steps up to
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

    /**
     * Picture 3 re-staged (Sokrates 15.10., 12:0x): the hero stands on the north road a few steps past the bridge and looks
     * up it to the square, turned a little to the right; the temple stands right, seen at a slant, its door towards the lower
     * street as on the village map. The picture is laid out in the world (X east, N north, metres from the hero's feet) and
     * turned by [YAW_DEG] into the camera's (x, z).
     */
    const val YAW_DEG = 18f
    private val yaw = YAW_DEG * PI.toFloat() / 180f
    fun camX(wx: Float, wn: Float) = wx * cos(yaw) - wn * sin(yaw)
    fun camZ(wx: Float, wn: Float) = wx * sin(yaw) + wn * cos(yaw)

    /** The temple's front (south side): its west corner at ([TEMPLE_X], [TEMPLE_N]), [TEMPLE_W] wide, the door [DOOR_A] along it. */
    const val TEMPLE_X = 3f
    const val TEMPLE_N = 16f
    const val TEMPLE_W = 12f
    const val DOOR_A = 5f
    /** The open door in the camera's coordinates: its warm light breathes with the torches. */
    val doorX get() = camX(TEMPLE_X + DOOR_A, TEMPLE_N)
    val doorZ get() = camZ(TEMPLE_X + DOOR_A, TEMPLE_N)

    /** One torch bearer where the walk ends: (x, z) in the camera, [h] hood height, [lean] of the hood, carries a [torch]. */
    data class Bearer(val x: Float, val z: Float, val torch: Boolean, val h: Float, val lean: Float) {
        /** Where the torch burns, relative to (x, 0, z): right of the hood, above it. */
        val tipX get() = x + 0.3f + lean
        val tipY get() = h + 0.25f
    }

    /** A bearer standing at (wx, wn) in the world. */
    private fun at(wx: Float, wn: Float, torch: Boolean, h: Float, lean: Float) = Bearer(camX(wx, wn), camZ(wx, wn), torch, h, lean)

    /** Back to front, as they are painted: on the path before the temple steps. */
    val bearers = listOf(
        at(4.6f, 12.6f, true, 1.637f, -0.016f),
        at(6.6f, 13.4f, false, 1.659f, -0.004f),
        at(8.0f, 12.2f, true, 1.614f, 0.037f),
        at(10.4f, 13.0f, true, 1.655f, 0.005f),
        at(6.2f, 11.2f, true, 1.654f, 0.014f),
    ).sortedByDescending { it.z }
    /** The group's middle depth: the painted layer is moved as if all stood there. */
    val groupZ get() = bearers.map { it.z }.average().toFloat()

    /** Where the group starts, relative to where it ends: back on the lower street, coming from the west up the path. */
    private const val WALK_WX = -1.4f
    private const val WALK_WN = -2.8f
    val WALK_DX get() = camX(WALK_WX, WALK_WN)
    val WALK_DZ get() = camZ(WALK_WX, WALK_WN)
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

    /** Where the chimney smoke of the house left beyond the square leaves the pot (screen, picture 3; the painter's house). */
    val smokeX get() = sx(-9.89f, 29.5f)
    val smokeY get() = sy(7.6f, 29.5f)
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

    /** The puddle in a rut of the lower street (camera x, z, half width): the torches mirror in it as warm streaks. */
    val PUDDLE_X get() = camX(3.0f, 4.4f)
    val PUDDLE_Z get() = camZ(3.0f, 4.4f)
    const val PUDDLE_W = 0.9f
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
