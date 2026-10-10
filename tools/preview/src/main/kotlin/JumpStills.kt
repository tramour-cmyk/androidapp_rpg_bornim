package preview

import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import de.bornim.core.art.HeroFigure as HF

/**
 * Stills of the places the battle Sprungtest (12a) reports: each case one row, the pictures around the jump side by side.
 * SPRUNGBILD=held:CROSSBOW:BLOCK:SLASH:0:-1..4,wolf:DIE:0:0..3 (-1 or past the end: standing ready)  (hero: stance, act, strike, variant, pictures; foe: id, act, variant, pictures)
 */
fun renderJumpStills() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 3)
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val F = de.bornim.core.art.HeroFigure
    fun outfit(st: de.bornim.core.art.HeroFigure.Stance) = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, when (st) {
        HF.Stance.MELEE -> mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield"))
        HF.Stance.BOW -> mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("longbow"))
        HF.Stance.CROSSBOW -> mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("light_crossbow"))
        HF.Stance.STAFF -> mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("quarterstaff"))
        HF.Stance.SPEAR -> mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("spear"))
    } + (de.bornim.core.GearSlot.CHEST to g("chain_shirt")))
    val cases = System.getenv("SPRUNGBILD").split(",")
    val cw = 260; val ch = 280
    val rows = cases.map { c ->
        val p = c.split(":")
        val (a, b) = p.last().split("..").map { it.toInt() }
        if (p[0] == "held") {
            val st = HF.Stance.valueOf(p[1]); val act = HF.Act.valueOf(p[2]); val s = HF.Strike.valueOf(p[3]); val v = p[4].toInt()
            val rigs = F.sequence(act, s, v, st); val o = outfit(st)
            val idle = F.sequence(HF.Act.IDLE, s, 0, st).first()
            c to (a..b).map { i -> (if (i < 0 || i >= rigs.size) "Bereit" else "Bild $i") to doll.render(cw, ch, cw / 2.0, ch - 12.0, 1.6, if (i < 0 || i >= rigs.size) idle else rigs[i], o).img }
        } else {
            val act = de.bornim.core.art.Act.valueOf(p[1]); val v = p[2].toInt(); val look = de.bornim.core.MonsterLook(0)
            val n = de.bornim.core.art.MonsterArt.frameCount(p[0], look, act, v)
            c to (a..b).map { i -> (if (i < 0 || i >= n) "Bereit" else "Bild $i") to (if (i < 0 || i >= n) de.bornim.core.art.MonsterArt.battleFrame(p[0], look, de.bornim.core.art.Act.IDLE, 0, 0)
                else de.bornim.core.art.MonsterArt.battleFrame(p[0], look, act, v, i)) }
        }
    }
    val cols = rows.maxOf { it.second.size }
    val out = BufferedImage(cw * cols, (ch + 18) * rows.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x4A4C48); gg.fillRect(0, 0, out.width, out.height)
    for ((r, row) in rows.withIndex()) {
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString(row.first, 6, r * (ch + 18) + 13)
        for ((c, pic) in row.second.withIndex()) {
            val im = pic.second; val oy = r * (ch + 18) + 18
            val sx = if (im.width > cw) (im.width - cw) / 2 else 0; val sy = if (im.height > ch) im.height - ch else 0
            for (y in 0 until minOf(ch, im.height)) for (x in 0 until minOf(cw, im.width)) { val q = im[x + sx, y + sy]; if ((q ushr 24) >= 128) out.setRGB(c * cw + x, oy + y, q and 0xFFFFFF) }
            gg.color = java.awt.Color(0xD8D0C0); gg.drawString(pic.first, c * cw + 6, oy + 14)
        }
    }
    val name = System.getenv("NAME") ?: "sprung"
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/$name.png"))
    println("wrote build/screens/$name.png")
}
