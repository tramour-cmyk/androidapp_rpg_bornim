package preview

import de.bornim.core.Build
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.GameState
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapGround
import de.bornim.core.art.PixelImage
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Draft (09.10.): the villagers as dolls on the map, starting with Garrick the hunter. NPCDRAFT=1 */
fun renderNpcDraft() {
    var uid = 5000L
    fun dressed(name: String, race: Race, cls: CharClass, build: Build, skin: Int, hair: Int, vararg items: String): Hero {
        val h = GameState.newGame(name, race, cls).hero
        h.build = build; h.skin = skin; h.hair = hair
        h.gear.clear()
        for (b in items) { val g = Gear(uid++, b, Rarity.COMMON, 1); h.gear[g.def.slot] = g }
        return h
    }
    val folk = de.bornim.core.art.MapFolk
    val variants = listOf(
        "vorher: Variante A (18:53)" to { sl: Int, st: Int -> MapFigure.draw(dressed("Garrick", Race.HUMAN, CharClass.ROGUE, Build.STRONG, 2, 1, "hood", "leather", "gloves", "boots", "cloak", "longbow"), sl, st) },
        "neu: Kapuze olivbraun, Bart, dunkles Leder, Bogen und Köcher auf dem Rücken" to { sl: Int, st: Int -> folk.draw(folk.garrick, sl, st) },
    )
    val F = MapFigure
    val slots = listOf(0, 2, 4, 6, 8, 10, 12, 14)
    val lab = 22
    val sheetW = F.W * (slots.size + 1); val rowH = F.H + lab
    val sheet = BufferedImage(sheetW, rowH * variants.size, BufferedImage.TYPE_INT_RGB)
    val g = sheet.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, sheet.width, sheet.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 13)
    fun paste(img: PixelImage, ox: Int, oy: Int, k: Int = 1) {
        for (y in 0 until img.height * k) for (x in 0 until img.width * k) {
            val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
            if (ox + x in 0 until sheet.width && oy + y in 0 until sheet.height) sheet.setRGB(ox + x, oy + y, q)
        }
    }
    val old = CharacterArt.npc("hunter", Facing.DOWN)
    variants.forEachIndexed { r, (title, draw) ->
        g.color = Color(0xE8DCC0); g.drawString(title, 6, r * rowH + 16)
        slots.forEachIndexed { i, s -> paste(draw(s, 0), i * F.W, r * rowH + lab) }
    }
    // the former Garrick at the same scale, for comparison
    g.color = Color(0xE8DCC0); g.drawString("bisher", slots.size * F.W + 6, 16)
    paste(old, slots.size * F.W + (F.W - old.width * 2) / 2, lab + F.GROUND - old.height * 2 + 4, 2)
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(sheet, "png", File("build/screens/npc_garrick_ansichten.png"))

    // in place: Garrick at his fire (12,9) facing left, the hero coming up the path to him
    val x0 = 7; val y0 = 5; val tw = 9; val th = 7
    renderFloraSheet("forest:$x0:$y0:$tw:$th")
    val scene = ImageIO.read(File("build/screens/flora_forest_$x0-$y0.png"))
    val S = MapGround.S
    fun place(img: PixelImage, tx: Int, ty: Int) {
        val ox = (tx - x0) * S + S / 2 - F.ANCHOR_X; val oy = (ty - y0) * S + (S * 0.8).toInt() - F.GROUND
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val q = img[x, y]; if ((q ushr 24) < 128) continue
            if (ox + x in 0 until scene.width && oy + y in 0 until scene.height) scene.setRGB(ox + x, oy + y, q)
        }
    }
    val hero = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    place(folk.draw(folk.garrick, F.slot(F.yawOf(Facing.LEFT)), 0), 12, 9)
    place(F.draw(hero, F.slot(F.yawOf(Facing.RIGHT)), 1), 10, 9)
    ImageIO.write(scene, "png", File("build/screens/npc_garrick_feuer.png"))
    println("wrote npc draft")
}
