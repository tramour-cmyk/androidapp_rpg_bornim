package preview

import de.bornim.core.MonsterLook
import de.bornim.core.art.Act
import de.bornim.core.art.BattleScene
import de.bornim.core.art.MonsterArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** All forest spots by time of day, with the wolf standing where it would in a fight. */
fun renderSceneSheet() {
    val w = 270; val h = 370
    val spots = BattleScene.Spot.entries
    for ((name, deep) in listOf("forest" to false, "deep" to true)) {
        val lights = BattleScene.Light.entries
        val out = BufferedImage(w * spots.size, h * lights.size, BufferedImage.TYPE_INT_RGB)
        for ((r, light) in lights.withIndex()) for ((c, spot) in spots.withIndex()) {
            val img = BattleScene.forest(w, h, spot, light, deep, 11 + c * 7 + r)
            val wolf = MonsterArt.battleFrame("wolf", MonsterLook(c), Act.IDLE, 0, 0)
            val fx = (w * BattleScene.FOE_X - wolf.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
            for (y in 0 until h) for (x in 0 until w) out.setRGB(c * w + x, r * h + y, img[x, y])
            for (y in 0 until wolf.height) for (x in 0 until wolf.width) {
                val p = wolf[x, y]
                if ((p ushr 24) > 128) out.setRGB(c * w + fx + x, r * h + fy + y, p)
            }
        }
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/scenes_$name.png"))
    }
    println("wrote scenes")
}

/** Frames of the wolf on a dusk scene for an animated preview: idle, bite, idle, pounce, hurt. */
fun renderWolfAnim() {
    val w = 270; val h = 370
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 11)
    val look = MonsterLook(4)
    val seq = mutableListOf<Pair<de.bornim.core.art.PixelImage, Int>>()
    fun idle(n: Int) = repeat(n) { seq += MonsterArt.battleFrame("wolf", look, Act.IDLE, 0, it % 16) to 86 }
    fun act(a: Act, v: Int, ms: Int) = repeat(MonsterArt.frameCount("wolf", a, v)) { seq += MonsterArt.battleFrame("wolf", look, a, v, it) to ms }
    if (System.getenv("HOWL") != null) { idle(16); act(Act.HOWL, 0, 110); repeat(8) { seq += seq.last() }; idle(16) }
    else { idle(32); act(Act.ATTACK, 0, 45); idle(16); act(Act.ATTACK, 1, 45); idle(16); act(Act.HURT, 0, 60); idle(16) }
    File("build/screens/anim2").mkdirs()
    val durations = StringBuilder()
    for ((i, fr) in seq.withIndex()) {
        val (img, ms) = fr
        val out = BufferedImage(200 * 3, 120 * 3, BufferedImage.TYPE_INT_RGB)
        val fx = (w * BattleScene.FOE_X - img.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
        for (y in 0 until 360) for (x in 0 until 600) {
            val sx = 70 + x / 3; val sy = 125 + y / 3
            val p = img[sx - fx, sy - fy]
            out.setRGB(x, y, if ((p ushr 24) > 128) de.bornim.core.art.mix(p, de.bornim.core.art.argb(0xE8B4A8), 0.0).let { c ->
                // dusk light on the sprite
                val r = ((c shr 16) and 0xFF) * 0xE8 / 255; val g = ((c shr 8) and 0xFF) * 0xB4 / 255; val b = (c and 0xFF) * 0xA8 / 255
                (0xFF shl 24) or (r shl 16) or (g shl 8) or b
            } else bg[sx, sy])
        }
        ImageIO.write(out, "png", File("build/screens/anim2/f%03d.png".format(i)))
        durations.append(ms).append('\n')
    }
    File("build/screens/anim2/durations.txt").writeText(durations.toString())
    println("wrote anim")
}

/** All cave spots by light, with the wolf standing where it would in a fight. */
fun renderCaveSheet() {
    val w = 270; val h = 370
    val spots = de.bornim.core.art.CaveScene.Spot.entries
    val lights = de.bornim.core.art.CaveScene.Light.entries
    val out = BufferedImage(w * spots.size, h * lights.size, BufferedImage.TYPE_INT_RGB)
    File("build/screens/caves").mkdirs()
    for ((r, light) in lights.withIndex()) for ((c, spot) in spots.withIndex()) {
        val img = de.bornim.core.art.CaveScene.cave(w, h, spot, light, 11 + c * 7 + r)
        val wolf = MonsterArt.battleFrame("wolf", MonsterLook(c), Act.IDLE, 0, 0)
        val fx = (w * BattleScene.FOE_X - wolf.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
        val one = BufferedImage(w * 2, h * 2, BufferedImage.TYPE_INT_RGB)
        for (y in 0 until h) for (x in 0 until w) {
            val wp = wolf[x - fx, y - fy]
            val p = if ((wp ushr 24) > 128) wp else img[x, y]
            out.setRGB(c * w + x, r * h + y, p)
            for (q in 0 until 4) one.setRGB(x * 2 + q % 2, y * 2 + q / 2, p)
        }
        ImageIO.write(one, "png", File("build/screens/caves/${spot.name.lowercase()}_${light.name.lowercase()}.png"))
    }
    ImageIO.write(out, "png", File("build/screens/scenes_cave.png"))
    println("wrote caves")
}
