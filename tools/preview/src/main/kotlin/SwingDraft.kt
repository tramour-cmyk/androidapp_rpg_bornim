package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 17 (draft): the hero's cloak swinging on after a stop, in a few directions, picture by picture (`SWINGBILD=1`).
 * `SWINGMORE=1`: long hair and the quiver swing on too (17 Rest); the sheet also shows a woman and an archer without a cloak.
 */
fun renderSwingDraft() {
    val F = de.bornim.core.art.MapFigure
    val more = System.getenv("SWINGMORE") != null
    de.bornim.core.art.Dress.SWING_MORE = more
    val times = listOf(0L, 120L, 225L, 400L, 675L, 900L, 1400L)
    // a fighter starts without a cloak: one in a short cloak, one in a long mantle
    // and an elf woman, her long hair swinging on too
    // and (17 Rest) a woman and two archers, one without a cloak
    val heroes = System.getenv("SWINGWHO")?.split(",") ?: listOf("cloak", "mantle", "elf", "woman", "archer", "archer-cloak")
    // seen diagonally the pictures are turned by 45°: slots as the screen shows them
    val slots = listOf(4, 12)
    val z = 4
    val cw = F.W / 2 * z; val ch = F.H / 2 * z
    val img = BufferedImage(cw * times.size, (ch + 16) * slots.size * heroes.size, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x2E3A2C); g.fillRect(0, 0, img.width, img.height)
    var row = 0
    for ((n, base) in heroes.withIndex()) {
        val elf = base == "elf"
        val hero = de.bornim.core.GameState.newGame(if (elf) "Liriel" else "Alrik", if (elf) de.bornim.core.Race.ELF else de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero
        if (elf || base == "woman") hero.sex = de.bornim.core.Sex.FEMALE
        if (base.startsWith("archer")) hero.equip(de.bornim.core.Gear(950L + n, "longbow", de.bornim.core.Rarity.COMMON, 3))
        when (base) {
            "woman", "archer" -> {}
            "archer-cloak" -> hero.equip(de.bornim.core.Gear(900L + n, "cloak", de.bornim.core.Rarity.UNCOMMON, 3))
            else -> hero.equip(de.bornim.core.Gear(900L + n, if (elf) "cloak" else base, de.bornim.core.Rarity.UNCOMMON, 3))
        }
        for (slot in slots) {
            val y0 = row * (ch + 16)
            for ((c, t) in times.withIndex()) {
                val lv = F.swingLevel(t)
                val p = F.swingFrameNow(hero, slot, lv)
                // the picture is at density 2: every second art pixel, enlarged z times
                for (y in 0 until ch) for (x in 0 until cw) {
                    val q = p[(x * 2 / z).coerceAtMost(p.width - 1), (y * 2 / z).coerceAtMost(p.height - 1)]
                    if ((q ushr 24) >= 128) img.setRGB(c * cw + x, y0 + 16 + y, q and 0xFFFFFF)
                }
                g.color = java.awt.Color(0xF0E8D8); g.drawString("${t} ms  Stufe $lv", c * cw + 4, y0 + 13)
            }
            row++
        }
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_nachschwingen" + (if (more) "_neu" else "") + ".png"))
    println("wrote swing draft")
}
