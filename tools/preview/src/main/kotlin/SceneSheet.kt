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
