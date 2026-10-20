package de.bornim.core.art

import kotlin.math.atan
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.tan

/**
 * 211.13 (Chef 19.10., 23:13; Muster geprüft von Sokrates 23:31): the one camera of a Kampfort. One ground plane, one
 * camera: the middle of the fight [MID] down the scene, seen from [PITCH]° above through a lens [LENS] times longer than
 * the old one; the line of the fight runs from the heroes away and to the right, [AXIS]° off straight ahead. Every figure
 * stands on that ground, is drawn as large as its distance makes it and is seen from its own angle; the backdrop is drawn
 * for the same camera (wood: [ForestCam], cave: [CaveCam]).
 *
 * Places on the ground: [a] metres along the line of the fight (towards the foes), [b] metres across it (to the right);
 * the middle of the fight is a = b = 0. Screen: [w] × [h] pixels, [x] across, [d] straight ahead in metres.
 */
class FightCamera(val w: Int, val h: Int) {
    /** pixels for each pixel of the 412-wide pattern */
    val u = w / 412.0
    /** the focal length in pixels: the old lens put the backdrop's horizon (40 % down) at 15° above the middle (72 %) */
    val f = (h * 0.72 - h * 0.40) / tan(Math.toRadians(15.0)) * LENS
    val midY = h * MID
    val horizonY = midY - f * tan(Math.toRadians(PITCH))
    /** a hero at the middle is 120 pattern pixels tall */
    private val perM0 = 120.0 * u / 1.75
    /** how far the middle of the fight is from the camera (m) and how high the camera is (m) */
    val d0 = f / perM0
    val eye = d0 * tan(Math.toRadians(PITCH))
    val cx = w / 2.0
    private val ax = sin(Math.toRadians(AXIS)); private val ad = cos(Math.toRadians(AXIS))

    /** Where (a, b) lies on the ground: across and ahead of the camera, metres. */
    fun ground(a: Double, b: Double) = Pair(a * ax + b * ad, d0 + a * ad - b * ax)
    fun screen(x: Double, d: Double) = Pair(cx + f * x / d, horizonY + f * eye / d)
    /** Where the feet of one standing at (a, b) are, pixels. */
    fun feet(a: Double, b: Double) = ground(a, b).let { (x, d) -> screen(x, d) }
    /** Screen pixels per centimetre at (a, b). */
    fun perCm(a: Double, b: Double) = f / ground(a, b).second / 100.0
    /** The angle from above one standing at (a, b) is seen at, degrees. */
    fun look(a: Double, b: Double) = Math.toDegrees(atan(eye / ground(a, b).second))
    /** The turn of a figure at (a, b) facing the other side, as the camera sees it (degrees, 0 = facing us). */
    fun yaw(a: Double, b: Double, foe: Boolean): Double {
        val (x, d) = ground(a, b)
        val face = if (foe) Pair(-ax, -ad) else Pair(ax, ad)
        val phi = atan2(x, d)
        val s = face.first * cos(phi) - face.second * sin(phi)
        val c = -(face.first * sin(phi) + face.second * cos(phi))
        return Math.toDegrees(atan2(s, c))
    }
    /** The zoom the backdrop is drawn at: half size and doubled, like the game's Kampforte. */
    val zoom = max(1, (2 * u).roundToInt())

    companion object {
        const val PITCH = 25.0
        const val LENS = 1.5
        const val MID = 0.68
        const val AXIS = 30.0
        /** rows, metres from the middle of the fight; two of a row [HALF_M] either side of the line */
        const val FRONT_M = 1.4
        const val BACK_M = 2.9
        const val HALF_M = 0.9
        /** the heroes this much nearer the camera than the foes stand from the middle (211.13) */
        const val NEAR_M = 1.0
        /** foes drawn this much larger than true to life (211.13), wolves on top of their own 0.88 */
        const val FOE_SIZE = 1.5
        /** how far behind the furthest foe the back of the Kampfort stands (211.11) */
        const val WALL_M = 7.0

        /**
         * Where a fighter stands: [foe] or hero, [back] row or front, [slot] 0 or 1, [alone] in its row (then on the line).
         * 211.13 (Sokrates 23:31, 3): one behind the other the heroes stand a little right of the line, clear of the left edge.
         */
        fun stand(foe: Boolean, back: Boolean, slot: Int, alone: Boolean): Pair<Double, Double> {
            val row = if (back) BACK_M else FRONT_M
            // two heroes in the back row: the left one would stand outside the picture, the right one under its lower
            // edge; so that row stands a little nearer the front and right of the line, the two a little closer
            if (!foe && back && !alone) return Pair(-row - NEAR_M + 0.6, 0.6 + (if (slot == 0) -0.7 else 0.7))
            val b = if (alone) (if (foe) 0.0 else ALONE_HERO_B) else if (slot == 0) -HALF_M else HALF_M
            return if (foe) Pair(row, b) else Pair(-row - NEAR_M, b)
        }
        const val ALONE_HERO_B = 0.35

        /**
         * How the camera sees the figures, for every fight alike: turned and from above as at the middle of their front
         * row of a 412 × 560 scene (the A56's); on other phones the angles differ by a degree. Fixed, so the frames drawn
         * ahead on the map are the ones the fight shows.
         */
        private val REF by lazy { FightCamera(412, 560) }
        val heroView: HeroBattle.View by lazy {
            val (a, b) = stand(false, false, 0, true)
            HeroBattle.View(REF.yaw(a, b, false) - HeroFigure.FIGHT_YAW, REF.look(a, b))
        }
        val foePitch: Double by lazy { REF.look(FRONT_M, 0.0) }
        val foeYaw: Double by lazy { REF.yaw(FRONT_M, 0.0, true) }

        /** The figures as the camera sees them ([on]), or as before the camera (for the comparison pictures). */
        fun see(on: Boolean) {
            HeroBattle.view = if (on) heroView else null
            BeastArt.pitch = if (on) foePitch else 15.0
            BeastArt.yaw = if (on) foeYaw else null
        }
    }
}

/**
 * 211.13: the Kampforte drawn for the one camera, once a fight (off the main thread), kept for the next few. The wood with
 * its six places and three lights ([ForestCam]), the cave with its five places and four lights ([CaveCam]).
 */
object Kampfort {
    private val cache = object : LinkedHashMap<String, PixelImage>(4, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 2
    }

    /** The path through the wood (211.12), degrees to the right of straight ahead. */
    const val PATH_DEG = 18.0

    /** How far from the camera the furthest place of the foes is, metres. */
    fun furthest(cam: FightCamera) = cam.ground(FightCamera.BACK_M, -FightCamera.HALF_M).second

    fun forest(w: Int, h: Int, spot: BattleScene.Spot, light: BattleScene.Light, deep: Boolean, seed: Int): PixelImage =
        kept("forest/$w/$h/$spot/$light/$deep/$seed") {
            val cam = FightCamera(w, h); val z = cam.zoom
            val g = GroundCam(w / z, h / z, cam.f / z, cam.cx / z, cam.horizonY / z, cam.eye)
            // at the edge of the wood and deep in it the trees stand nearer
            val gap = if (spot == BattleScene.Spot.EDGE || deep) 3.8 else FightCamera.WALL_M
            val wall = furthest(cam) + gap
            val (p0x, p0d) = cam.ground(-FightCamera.FRONT_M - FightCamera.NEAR_M, 0.0)
            val (mx, md) = cam.ground(0.0, 0.0)
            val px = ForestCam.draw(g, wall, PATH_DEG, p0x, p0d, emptyList(), 7 + seed, spot, light, mx, md, furthest(cam))
            upscale(px, g.w, g.h, w, h, z)
        }

    fun cave(w: Int, h: Int, spot: CaveScene.Spot, light: CaveScene.Light, seed: Int, night: Boolean = false): PixelImage =
        kept("cave/$w/$h/$spot/$light/$seed/$night") {
            val cam = FightCamera(w, h); val z = cam.zoom
            val g = GroundCam(w / z, h / z, cam.f / z, cam.cx / z, cam.horizonY / z, cam.eye)
            // in a tunnel the rock stands nearer
            val gap = if (spot == CaveScene.Spot.TUNNEL) 4.0 else FightCamera.WALL_M
            val (mx, md) = cam.ground(0.0, 0.0)
            upscale(CaveCam.draw(g, furthest(cam) + gap, furthest(cam), mx, md, spot, light, seed, night), g.w, g.h, w, h, z)
        }

    private fun upscale(px: IntArray, sw: Int, sh: Int, w: Int, h: Int, z: Int): PixelImage {
        val out = IntArray(w * h)
        for (y in 0 until h) {
            val row = (y / z).coerceAtMost(sh - 1) * sw
            for (x in 0 until w) out[y * w + x] = px[row + (x / z).coerceAtMost(sw - 1)] or (0xFF shl 24)
        }
        return PixelImage(w, h, out)
    }

    private fun kept(key: String, make: () -> PixelImage): PixelImage {
        synchronized(cache) { cache[key]?.let { return it } }
        val img = make()
        synchronized(cache) { cache[key] = img }
        return img
    }
}
