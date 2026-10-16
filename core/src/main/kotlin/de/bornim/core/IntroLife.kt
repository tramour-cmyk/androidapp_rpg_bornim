package de.bornim.core

import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

/**
 * 70.3 B (Nutzer 15.10.): quiet life over the intro's painted pictures. The picture stays painted; only what is light or air
 * moves (torch flames flicker, the light they throw breathes), plus at most one slow event per picture, once and never in a
 * loop. On picture 3 (`[69.intro.3]`) that event is the torch procession: it goes along the lower street to the temple path
 * and disappears behind the temple's corner on its way to the door (70.6 A, Nutzer 15.10., 12:4x). Figures never move by
 * themselves: every bearer is one painted cut-out carried along the way.
 *
 * Pure, so the preview's painter (`IntroProbe.kt` `SquarePainter`, which paints the bearers as cut-outs on a sheet and the
 * temple as the layer in front of them) and the app (which carries the cut-outs, draws flames and light, then lays the temple
 * over them) read the same numbers.
 */
object IntroLife {
    /** The picture that has life so far (0-based: picture 3). */
    const val SQUARE = 2

    /** The camera of picture 3: screen x = W/2 + f·x/z − pan, y = hy + f·(eye − y)/z, on a 1080 × 1200 picture. */
    const val W = 1080f
    const val H = 1200f
    const val F = 1080f
    const val HY = 560f
    const val EYE = 1.7f
    const val PAN = 0f
    fun sx(x: Float, z: Float) = W / 2 + F * x / z - PAN
    fun sy(y: Float, z: Float) = HY + F * (EYE - y) / z

    /**
     * 70.6 A: the hero stands on the village square (map tile [HERO_TX], [HERO_TY]; three tiles south of the stall that would
     * block the view) and looks east-south-east, [YAW_DEG] from north: the well in front on the left, far beyond it the
     * temple's west and north sides, the procession on the right. The picture is laid out on the village map
     * (`Story.village`, one tile = [TILE] metres), turned into the camera.
     */
    const val YAW_DEG = 110f
    const val TILE = 2f
    const val HERO_TX = 14.5f
    const val HERO_TY = 14.5f
    private val yaw = YAW_DEG * PI.toFloat() / 180f
    /** World metres east and north of the hero's feet for a point of the map (tile coordinates, x east, y south). */
    fun wx(tx: Float) = (tx - HERO_TX) * TILE
    fun wn(ty: Float) = -(ty - HERO_TY) * TILE
    fun camX(wx: Float, wn: Float) = wx * cos(yaw) - wn * sin(yaw)
    fun camZ(wx: Float, wn: Float) = wx * sin(yaw) + wn * cos(yaw)
    /** A map point (tile coordinates) in the camera. */
    fun mapX(tx: Float, ty: Float) = camX(wx(tx), wn(ty))
    fun mapZ(tx: Float, ty: Float) = camZ(wx(tx), wn(ty))

    /** The temple on the map: walls from tile [TEMPLE_TX0] to [TEMPLE_TX1] (east), [TEMPLE_TY0] to [TEMPLE_TY1] (south). */
    const val TEMPLE_TX0 = 26f
    const val TEMPLE_TX1 = 32f
    const val TEMPLE_TY0 = 18f
    const val TEMPLE_TY1 = 21f

    /** The procession's way on the map: the lower street (row 23) from the west to the temple path (column 28), up to the door. */
    val way = listOf(19f to 23.5f, 27.7f to 23.5f) + (1..5).map { k ->
        // the turn into the path, a quarter circle of 0.8 tiles, so nobody steps sideways at the corner
        val a = PI.toFloat() / 2 * k / 6
        27.7f + 0.8f * sin(a) to 22.7f + 0.8f * cos(a)
    } + listOf(28.5f to 22.7f, 28.5f to 21f)
    private val legs = way.zipWithNext().map { (a, b) -> hypot(b.first - a.first, b.second - a.second) * TILE }
    val wayLength get() = legs.sum()

    /** A map point [s] metres along the way, and the way's direction there (unit, in tiles). */
    fun along(s: Float): Pair<Pair<Float, Float>, Pair<Float, Float>> {
        var rest = s.coerceIn(0f, wayLength)
        for ((k, len) in legs.withIndex()) {
            val (a, b) = way[k] to way[k + 1]
            val d = (b.first - a.first) / (len / TILE) to (b.second - a.second) / (len / TILE)
            if (rest <= len || k == legs.size - 1) {
                val t = (rest / TILE).coerceAtMost(len / TILE)
                return (a.first + d.first * t to a.second + d.second * t) to d
            }
            rest -= len
        }
        error("unreachable")
    }

    /**
     * One torch bearer: [lag] metres behind the first along the way, [side] metres to the right of it (looking along the way),
     * [h] hood height, [lean] of the hood, carries a [torch]. Painted once as a cut-out on the sheet (slot = index).
     */
    data class Bearer(val lag: Float, val side: Float, val torch: Boolean, val h: Float, val lean: Float)

    /** The first walks in front; one without a torch in the middle. */
    val bearers = listOf(
        Bearer(0.0f, -0.35f, true, 1.637f, -0.016f),
        Bearer(1.1f, 0.40f, true, 1.659f, -0.004f),
        Bearer(2.3f, -0.30f, false, 1.614f, 0.037f),
        Bearer(3.3f, 0.35f, true, 1.655f, 0.005f),
        Bearer(4.4f, -0.10f, true, 1.654f, 0.014f),
    )

    /** How far the first bearer is along the way at [u] ms into the picture: already walking when it fades in, at [SPEED]. */
    const val SPEED = 1.5f
    const val LEAD_START = 16.4f
    fun lead(u: Long) = LEAD_START + SPEED * u / 1000f

    /** Bearer [i] at [u] ms: its feet in the camera (x, z). */
    fun at(i: Int, u: Long): Pair<Float, Float> {
        val b = bearers[i]
        val (p, d) = along(lead(u) - b.lag)
        // right of the way, looking along it: (−dy, dx) in map tiles (x east, y south)
        val tx = p.first - d.second * b.side / TILE; val ty = p.second + d.first * b.side / TILE
        return mapX(tx, ty) to mapZ(tx, ty)
    }

    /**
     * Whether the temple's south-west corner hides the point (x, z) of the camera: it lies behind the corner and on its far
     * side, as seen from the hero. The temple layer drawn last hides it in the app; this only tells the light when to go.
     */
    fun behindTemple(x: Float, z: Float): Boolean {
        val cx = mapX(TEMPLE_TX0, TEMPLE_TY1); val cz = mapZ(TEMPLE_TX0, TEMPLE_TY1)
        return z > cz && atan2(x, z) < atan2(cx, cz)
    }

    /** The cut-outs on the sheet (the layer `intro_3_zug.png`): each bearer painted standing at depth [SHEET_Z], slot by slot. */
    const val SHEET_Z = 24f
    const val SLOT_W = 180f
    fun slotX(i: Int) = 120f + SLOT_W * i
    val slotY get() = sy(0f, SHEET_Z)
    /** The camera x a cut-out is painted at, so its feet stand at [slotX]. */
    fun slotCamX(i: Int) = (slotX(i) - W / 2 + PAN) * SHEET_Z / F
    /** The box round a cut-out's feet on the sheet (left, top, right, bottom, in sheet pixels): cloak, torch, shadow. */
    val BOX = floatArrayOf(-80f, -120f, 80f, 40f)

    /** Where the torch burns, relative to the feet: right of the hood, above it (metres). */
    fun tipX(b: Bearer) = 0.3f + b.lean
    fun tipY(b: Bearer) = b.h + 0.25f

    /** A flame's breath at [ms] (any clock), seeded per flame: about 0.8 .. 1.2, never in step with another flame. */
    fun flicker(seed: Int, ms: Long): Float {
        val t = ms / 1000f
        return 1f + 0.12f * sin(t * 9.3f + seed * 1.7f) + 0.06f * sin(t * 17.9f + seed * 4.1f) + 0.03f * sin(t * 31.3f + seed * 2.3f)
    }

    /** A puddle on the cobbles near the square's south edge (camera x, z, half width): the torches mirror in it as warm streaks. */
    val PUDDLE_X get() = mapX(19.4f, 17.2f)
    val PUDDLE_Z get() = mapZ(19.4f, 17.2f)
    const val PUDDLE_W = 0.8f
    /** Its outline on the screen, as the painter draws it. */
    fun puddle(): List<Pair<Float, Float>> = (0..28).map { j ->
        val a = 2 * PI.toFloat() * j / 28
        val wx = PUDDLE_X + cos(a) * PUDDLE_W * (0.85f + 0.2f * sin(a * 3 + 1))
        val wz = PUDDLE_Z + sin(a) * PUDDLE_W * 0.6f * (0.9f + 0.2f * cos(a * 2))
        sx(wx, wz) to sy(0f, wz)
    }
}
