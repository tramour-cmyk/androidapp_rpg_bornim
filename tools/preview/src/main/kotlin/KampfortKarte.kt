package preview

import de.bornim.core.CharClass
import de.bornim.core.Hero
import de.bornim.core.MonsterLook
import de.bornim.core.Race
import de.bornim.core.art.FoeArt
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapSun
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/*
 * 72u (draft, preview only): the place of a fight as the map draws it. The map is shot without the hero (his pictures
 * and shadows made empty, [hideMapHero]); [composeKampfort] then sets hero, mercenary and Grak on it the way the map sets
 * people (same pitch, centimetres per pixel, density, foot shadow and sun shadow), but in their battle stance: two rows,
 * the front row nearer Grak, Grak to the right.
 */

private var footShadow: PixelImage? = null
private var sunShadow: MapSun.Figure? = null

@Suppress("UNCHECKED_CAST")
private fun <T> field(owner: Any, name: String) = owner.javaClass.getDeclaredField(name).apply { isAccessible = true }.get(owner) as T

/** Makes the hero's map pictures and the people's shadows empty, keeping the shadows for [composeKampfort]. */
fun hideMapHero() {
    val pics = field<HashMap<String, PixelImage>>(MapFigure, "cache")
    synchronized(pics) { for (k in pics.keys.toList()) pics[k]!!.let { pics[k] = PixelImage(it.width, it.height) } }
    footShadow = WorldArt.shadow()
    sunShadow = MapSun.figure()
    val art = field<HashMap<String, PixelImage>>(WorldArt, "cache")
    synchronized(art) { art["char-shadow"] = PixelImage(footShadow!!.width, footShadow!!.height) }
    val sun = field<HashMap<MapSun.Stand, MapSun.Figure>>(MapSun, "figures")
    synchronized(sun) { sun[MapSun.stand] = MapSun.Figure(PixelImage(1, 1), 0, 0) }
}

/** Sets the party and Grak on the map shot [file] taken at [zoom] screen pixels per map pixel; writes `<name>_mit.png`. */
fun composeKampfort(file: File, zoom: Int, w: Int, h: Int) {
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB).also { it.graphics.drawImage(ImageIO.read(file), 0, 0, null) }
    val K = 0.703125
    val T = WorldArt.T
    // the camera point (WorldScreen camera) lands here; map pixels are counted from it
    val cx = w / 2.0; val cy = h * 0.55
    fun sx(mx: Double, my: Double) = cx + K * zoom * (mx - my)
    fun sy(mx: Double, my: Double) = cy + K / 2 * zoom * (mx + my)
    fun blend(X: Int, Y: Int, c: Int, k: Double) {
        val a = ((c ushr 24) and 0xFF) * k
        if (a <= 0 || X !in 0 until w || Y !in 0 until h) return
        val d = out.getRGB(X, Y)
        fun ch(s: Int) = ((((c shr s) and 0xFF) * a + ((d shr s) and 0xFF) * (255 - a)) / 255).toInt()
        out.setRGB(X, Y, (ch(16) shl 16) or (ch(8) shl 8) or ch(0))
    }
    /** A picture lying on the ground, its top left at map pixel ([mx], [my]), under the turned mapping. */
    fun ground(img: PixelImage, mx: Double, my: Double, k: Double) {
        val xs = listOf(sx(mx, my), sx(mx + img.width, my), sx(mx, my + img.height), sx(mx + img.width, my + img.height))
        val ys = listOf(sy(mx, my), sy(mx + img.width, my), sy(mx, my + img.height), sy(mx + img.width, my + img.height))
        for (Y in ys.min().toInt()..ys.max().toInt()) for (X in xs.min().toInt()..xs.max().toInt()) {
            val u = (X - cx) / (K * zoom); val v = (Y - cy) * 2 / (K * zoom)
            val px = (u + v) / 2 - mx; val py = (v - u) / 2 - my
            if (px < 0 || py < 0) continue
            blend(X, Y, img[px.toInt(), py.toInt()], k)
        }
    }
    val yawParty = (System.getenv("KAMPFYAW") ?: "100").toDouble()
    val yawFoe = (System.getenv("FOEYAW") ?: "260").toDouble()
    fun heroPic(hr: Hero): PixelImage {
        val rig = HeroBattle.frames(hr, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0)[0]
        return MapFigure.render(HeroBattle.doll(hr), HeroBattle.outfit(hr), rig.copy(yaw = yawParty), 160, 190)
    }
    val look = MonsterLook(1)
    val grakRig = FoeArt.sequence("hobgoblin_captain", look, de.bornim.core.art.Act.IDLE, 0).rigs[0]
    val grak = MapFigure.render(FoeArt.doll("hobgoblin_captain", look), FoeArt.outfit("hobgoblin_captain", look), grakRig.copy(yaw = yawFoe), 220, 240)
    // places in tiles from the camera's tile: Grak to the right on the screen (map +x, −y), the front row nearer him,
    // the back row to the left and a little lower
    val put = listOf(
        Triple(grak, 0.5 to -0.5, 240),
        Triple(heroPic(Hero.create("Borin", Race.HUMAN, CharClass.FIGHTER)), -0.3 to 0.3, 190),
        Triple(heroPic(Hero.create("Söldner", Race.HUMAN, CharClass.ROGUE)), -0.6 to 1.0, 190),
    )
    val sun = sunShadow!!; val foot = footShadow!!
    for ((_, at, _) in put) {
        val ox = at.first * T; val oy = at.second * T
        // as the map: the sun shadow from 15 map pixels behind the feet, the dark patch under them
        ground(sun.img, ox - sun.fx, oy + 4.4 - sun.fy, 1.0)
        ground(foot, ox - 12, oy + 16.4, 1.0)
    }
    val s = zoom / MapFigure.DENSITY.toDouble()
    for ((pic, at, ph) in put.sortedBy { it.second.first + it.second.second }) {
        val mx = at.first * T; val my = at.second * T + 19.4
        val fx = sx(mx, my); val fy = sy(mx, my)
        val footY = ph - (MapFigure.H - MapFigure.GROUND)
        val ox = fx - pic.width / 2.0 * s; val oy = fy - footY * s
        for (y in 0 until (pic.height * s).toInt()) for (x in 0 until (pic.width * s).toInt())
            blend((ox + x).toInt(), (oy + y).toInt(), pic[(x / s).toInt(), (y / s).toInt()], 1.0)
    }
    ImageIO.write(out, "png", File(file.parentFile, file.nameWithoutExtension + "_mit.png"))
    println("wrote ${file.nameWithoutExtension}_mit")
}
