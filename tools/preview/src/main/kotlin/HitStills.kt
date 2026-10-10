package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import de.bornim.core.art.HeroFigure as HF
import de.bornim.core.art.HeroBattle as HB

/**
 * Stills of the hero's blows as the battle places them (19): the foe standing, the hero stepped in by the lunge and drawn
 * smaller, as in the app; one row per blow, the pictures around the one the blow lands on (marked *).
 * TREFFERBILD=SLASH,THRUST,SMASH,KILL_HIGH,KILL_PIERCE,KILL_SPIN (FOE=goblin, WEAPON=longsword, SCENEH=434: scene height in
 * art pixels, 434 on the film screen of 540 x 1170, BEFORE=4 AFTER=3 pictures around the hit, ZOOM=2)
 */
fun renderHitStills() {
    val strikes = System.getenv("TREFFERBILD").split(",").map { HF.Strike.valueOf(it.trim()) }
    val foeId = System.getenv("FOE") ?: "goblin"
    val g = de.bornim.core.GameState.newGame("Test", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER)
    val hero = g.hero
    System.getenv("WEAPON")?.let { hero.equip(de.bornim.core.Gear(9_999L, it, de.bornim.core.Rarity.COMMON, 1)) }
    val sceneW = de.bornim.core.art.BattleScene.DESIGN_W.toDouble(); val sceneH = System.getenv("SCENEH")?.toDouble() ?: 434.0
    val before = System.getenv("BEFORE")?.toInt() ?: 4; val after = System.getenv("AFTER")?.toInt() ?: 3
    val z = System.getenv("ZOOM")?.toInt() ?: 2
    val look = de.bornim.core.MonsterLook(0)
    val foe = de.bornim.core.art.MonsterArt.battleFrame(foeId, look, de.bornim.core.art.Act.IDLE, 0, 0)
    val (foeW, foeTall) = de.bornim.core.art.MonsterArt.bodySize(foeId, look, foe.width, foe.height)
    val fx = sceneW * de.bornim.core.art.BattleScene.FOE_X; val fy = sceneH * de.bornim.core.art.BattleScene.FOE_Y
    val hx = sceneW * de.bornim.core.art.BattleScene.HERO_X; val hy = sceneH * de.bornim.core.art.BattleScene.HERO_Y
    val aim = HB.aimAt(fx, fy, foeW, foeTall)
    // the part of the scene the two stand in
    val x0 = 30.0; val y0 = fy - foeTall - 30; val cw = 200; val ch = (hy + 6 - y0).toInt()
    val cols = before + after + 1
    val out = BufferedImage(cw * z * cols, (ch * z + 18) * strikes.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics()
    gg.color = java.awt.Color(0x4A4C48); gg.fillRect(0, 0, out.width, out.height)
    fun put(img: de.bornim.core.art.PixelImage, left: Double, top: Double, scale: Double, ox: Int, oy: Int, ax: Double, ay: Double) {
        // drawn scaled round (ax, ay) of the picture, as graphicsLayer does round the feet
        for (py in 0 until ch * z) for (px in 0 until cw * z) {
            val sx = x0 + px.toDouble() / z; val sy = y0 + py.toDouble() / z
            val ix = ((sx - left - ax) / scale + ax).toInt(); val iy = ((sy - top - ay) / scale + ay).toInt()
            val q = img[ix, iy]
            if ((q ushr 24) >= 128) out.setRGB(ox + px, oy + py, q and 0xFFFFFF)
        }
    }
    for ((r, s) in strikes.withIndex()) {
        val hit = HB.strikeFrame(s); val n = HB.frameCount(hero, HF.Act.ATTACK, s, 0)
        val (ox, oy) = HB.lungeOffset(hero, s, hx, hy, aim.first, aim.second)
        val top = r * (ch * z + 18)
        gg.color = java.awt.Color(0xF0E8D8)
        gg.drawString("$s  (${hero.item(de.bornim.core.GearSlot.MAIN_HAND)?.base}, $n Bilder, Treffer Bild $hit; rot = Zielpunkt)", 6, top + 13)
        for (c in 0 until cols) {
            val i = hit - before + c
            if (i < 0 || i >= n) continue
            val oxp = c * cw * z; val oyp = top + 18
            put(foe, fx - de.bornim.core.art.MonsterArt.anchorX(foeId, foe.width), fy - de.bornim.core.art.MonsterArt.groundLine(foeId), 1.0, oxp, oyp, 0.0, 0.0)
            val l = HB.lungeAt(hero, s, i)
            val sc = 1.0 - (1.0 - HB.LUNGE_SCALE) * l
            put(HB.frame(hero, HF.Act.ATTACK, s, 0, i), hx - HB.ANCHOR_X + ox * l, hy - HB.GROUND + oy * l, sc, oxp, oyp, HB.ANCHOR_X, HB.GROUND)
            gg.color = java.awt.Color(0xE02020)
            gg.fillOval(oxp + ((aim.first - x0) * z).toInt() - 4, oyp + ((aim.second - y0) * z).toInt() - 4, 9, 9)
            gg.color = java.awt.Color(0xF0E8D8)
            gg.drawString("Bild $i" + (if (i == hit) " *" else ""), oxp + 6, oyp + 14)
        }
    }
    val name = System.getenv("NAME") ?: "treffer"
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/$name.png"))
    println("wrote build/screens/$name.png")
}
