package preview

import de.bornim.core.GearBases
import de.bornim.core.Rarity
import de.bornim.core.art.IconArt
import de.bornim.core.art.ItemArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike
import java.awt.Color
import java.awt.Font
import java.awt.Graphics2D
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

private fun Graphics2D.put(p: PixelImage, ox: Int, oy: Int, cell: Int) {
    color = Color(0xE9E3D3); fillRect(ox, oy, cell - 6, cell - 6)
    val s = (cell - 18) / p.width
    for (y in 0 until p.height) for (x in 0 until p.width) {
        val v = p[x, y]; val a = v ushr 24; if (a == 0) continue
        val bg = 0xE9E3D3
        fun ch(sh: Int) = (((v shr sh) and 0xFF) * a + ((bg shr sh) and 0xFF) * (255 - a)) / 255
        color = Color(ch(16), ch(8), ch(0)); fillRect(ox + 6 + x * s, oy + 6 + y * s, s, s)
    }
}

/** Every piece of gear: its old drawn icon beside its picture built from the solids, common and rare; and the rarity marks. */
fun renderItemSheet() {
    val cell = 32 * 4 + 12
    run {
        val cols = 4
        val bases = GearBases.all
        val rows = (bases.size + cols - 1) / cols
        val colW = cell * 3 + 20
        val rowH = cell + 22
        val img = BufferedImage(colW * cols, rowH * rows, BufferedImage.TYPE_INT_ARGB)
        val g = img.createGraphics()
        g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
        g.font = Font("SansSerif", Font.PLAIN, 14)
        for ((i, b) in bases.withIndex()) {
            val ox = (i % cols) * colW; val oy = (i / cols) * rowH
            g.put(IconArt.get(b.icon), ox + 4, oy + 4, cell)
            g.put(ItemArt.get(b.id, Rarity.COMMON), ox + 4 + cell, oy + 4, cell)
            g.put(ItemArt.get(b.id, Rarity.RARE), ox + 4 + cell * 2, oy + 4, cell)
            g.color = Color(0xE9E3D3); g.drawString(b.de, ox + 6, oy + cell + 14)
        }
        File("build/screens").mkdirs()
        ImageIO.write(img, "png", File("build/screens/item_sheet.png"))
    }
    run {
        val items = listOf("longsword", "round_shield", "quarterstaff", "chain_shirt", "light_crossbow", "ring")
        val marks = ItemArt.Mark.entries
        val small = 32 * 3 + 12
        val blockW = small * Rarity.entries.size + 24
        val img = BufferedImage(130 + blockW * marks.size, 56 + small * items.size, BufferedImage.TYPE_INT_ARGB)
        val g = img.createGraphics()
        g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
        for ((mi, _) in marks.withIndex()) {
            val ox = 130 + mi * blockW
            g.font = Font("SansSerif", Font.BOLD, 16); g.color = Color(0xE9E3D3); g.drawString("Variante ${"ABC"[mi]}", ox + 4, 18)
            g.font = Font("SansSerif", Font.PLAIN, 11)
            for ((ri, r) in Rarity.entries.withIndex()) { g.color = Color(r.color.toInt()); g.drawString(r.title.de, ox + ri * small + 4, 44) }
            for ((ii, id) in items.withIndex()) for ((ri, r) in Rarity.entries.withIndex())
                g.put(ItemArt.get(id, r, marks[mi]), ox + ri * small, 52 + ii * small, small)
        }
        g.font = Font("SansSerif", Font.PLAIN, 14)
        for ((ii, id) in items.withIndex()) { g.color = Color(0xE9E3D3); g.drawString(GearBases[id].de, 6, 52 + ii * small + small / 2) }
        ImageIO.write(img, "png", File("build/screens/item_rarity.png"))
    }
    println("wrote item sheets")
}

/** The crossbow held up in many ways, to find the one that reads best. */
fun renderCrossbowProbe() {
    val small = 32 * 4 + 12
    val V = de.bornim.core.art.HeroFigure::V
    val dirs = listOf(V(-1.0, 0.0, -1.0), V(-1.0, 0.0, 1.0), V(-1.0, 0.2, -1.0), V(-1.0, 0.2, 1.0))
    val views = listOf(0.0 to 60.0, 0.0 to 72.0, 0.0 to 82.0, 15.0 to 72.0, -15.0 to 72.0)
    val img = BufferedImage(small * views.size, small * dirs.size, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics()
    for ((di, d) in dirs.withIndex()) for ((vi, v) in views.withIndex()) {
        val rig = de.bornim.core.art.HeroFigure.Rig(rh = de.bornim.core.art.HeroFigure.V(-4.0, 95.0, 25.0), weapon = d, aim = 1.0, grip = 10.0, draw = if (vi % 2 == 0) 1.0 else 0.0)
        g.put(ItemArt.probe("light_crossbow", rig, v.first, v.second), vi * small, di * small, small)
    }
    ImageIO.write(img, "png", File("build/screens/crossbow_probe.png"))
    println("wrote crossbow probe")
}

/** Versatile weapons held in both hands: every act of every folk checked for the weapon going into the body. */
fun checkVersatile() {
    val F = de.bornim.core.art.HeroFigure
    var bad = 0; var total = 0
    val strikes = mapOf("spear" to listOf(Strike.THRUST, Strike.SMASH), "quarterstaff" to listOf(Strike.SMASH, Strike.SLASH), "warhammer" to listOf(Strike.SMASH, Strike.SLASH),
        "longsword" to listOf(Strike.SLASH, Strike.THRUST), "battleaxe" to listOf(Strike.SLASH, Strike.THRUST))
    for (race in de.bornim.core.Race.entries) for ((base, st) in strikes) {
        val doll = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to de.bornim.core.Gear(1, base, de.bornim.core.Rarity.COMMON, 3)), bothHands = true)
        val stance = F.stance(de.bornim.core.GearBases[base])
        val runs = mutableListOf<Triple<Act, Strike, Int>>()
        for (a in listOf(Act.IDLE, Act.INTRO, Act.TURN, Act.AMBUSHED, Act.HURT)) runs += Triple(a, Strike.SLASH, 0)
        for (v in listOf(1, 3)) runs += Triple(Act.BLOCK, Strike.SLASH, v)
        for (s in st) runs += Triple(Act.ATTACK, s, 0)
        for (v in listOf(0, 1, 2)) runs += Triple(Act.VICTORY, Strike.SLASH, v)
        for ((act, s, v) in runs) for ((i, rig) in F.sequence(act, s, v, stance).withIndex()) {
            total++
            val dress = doll.fit(rig, outfit).second!!.first
            dress.weaponThroughBody()?.let { t -> bad++; if (bad <= 80) println("KÖRPER: ${race.name} $base $act/$s/$v Bild $i bei ${(t * 100).toInt()} % ${dress.lastClash}") }
        }
    }
    println("VIELSEITIG: $bad von $total Bildern mit der Waffe im Körper")
}

/** Versatile weapons in both hands: rest, the blows at wind-up and strike, the parry and a victory, for a look. */
fun renderVersatile() {
    val F = de.bornim.core.art.HeroFigure
    val strikes = mapOf("longsword" to listOf(Strike.SLASH, Strike.THRUST), "battleaxe" to listOf(Strike.SLASH, Strike.THRUST), "warhammer" to listOf(Strike.SMASH, Strike.SLASH),
        "spear" to listOf(Strike.THRUST, Strike.SMASH), "quarterstaff" to listOf(Strike.SMASH, Strike.SLASH))
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
    val W = 190; val H = 230; val sc = 2
    val cols = 8
    val img = BufferedImage(W * sc * cols, H * sc * strikes.size, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics(); g.color = Color(0x3A4A36); g.fillRect(0, 0, img.width, img.height)
    for ((ri, e) in strikes.entries.withIndex()) {
        val (base, st) = e
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to de.bornim.core.Gear(1, base, de.bornim.core.Rarity.COMMON, 3)), bothHands = true)
        val stance = F.stance(de.bornim.core.GearBases[base])
        val rigs = mutableListOf(F.sequence(Act.IDLE, Strike.SLASH, 0, stance)[0])
        for (s in st) { val q = F.sequence(Act.ATTACK, s, 0, stance); val k = F.strikeFrame(s); rigs += q[k - 3]; rigs += q[k] }
        rigs += F.sequence(Act.BLOCK, Strike.SLASH, 1, stance)[7]
        rigs += F.sequence(Act.BLOCK, Strike.SLASH, 3, stance)[7]
        rigs += F.sequence(Act.VICTORY, Strike.SLASH, 1, stance).last()
        for ((ci, rig) in rigs.take(cols).withIndex()) {
            val p = doll.render(W, H, W / 2.0, H - 12.0, 0.95, rig, outfit).img
            for (y in 0 until H) for (x in 0 until W) { val v = p[x, y]; if ((v ushr 24) < 128) continue
                g.color = Color(v, true); g.fillRect(ci * W * sc + x * sc, ri * H * sc + y * sc, sc, sc) }
        }
    }
    ImageIO.write(img, "png", File("build/screens/versatile.png"))
    println("wrote versatile")
}

/** The cleric's rest with the round shield, turned all the way round: does the shield go into the belly? */
fun checkShieldTurn() {
    val P = de.bornim.core.art.HeroPortrait
    for (race in de.bornim.core.Race.entries) for (sex in de.bornim.core.Sex.entries) {
        val h = de.bornim.core.Hero.create("K", race, de.bornim.core.CharClass.CLERIC).also { it.sex = sex }
        val rest = de.bornim.core.art.HeroFigure.sequence(Act.IDLE, Strike.SLASH, 0, de.bornim.core.art.HeroFigure.stance(h))[0]
        val doll = de.bornim.core.art.HeroBattle.doll(h)
        val (sk, fitted) = doll.fit(rest, de.bornim.core.art.HeroBattle.outfit(h))
        val dress = fitted!!.first; val body = fitted.second
        val board = dress.shieldBoard ?: continue
        var worst = 0.0; var where = ""
        for (b in body) { if (b.part == de.bornim.core.art.BodyPart.HAIR) continue
            val c = b.center; val r = b.bound * 0.6
            for (dx in -2..2) for (dy in -2..2) for (dz in -2..2) {
                val p = c + de.bornim.core.art.P3(dx * r / 2, dy * r / 2, dz * r / 2)
                if (b.dist(p) > -0.3) continue
                val d = board.dist(p); if (d < worst) { worst = d; where = b.key } } }
        println("SCHILD ${race.name} ${sex.name}: tiefste Stelle im Körper ${"%.1f".format(-worst)} cm in $where")
    }
    val h = de.bornim.core.Hero.create("K", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.CLERIC).also { it.sex = de.bornim.core.Sex.FEMALE }
    val out = BufferedImage(P.W * 8, P.H * 3, BufferedImage.TYPE_INT_RGB)
    for ((i, y) in P.YAWS.withIndex()) { val im = P.render(h, y)
        for (yy in 0 until P.H) for (x in 0 until P.W) { val q = im[x, yy]; out.setRGB((i % 8) * P.W + x, (i / 8) * P.H + yy, if ((q ushr 24) >= 128) q else 0xE9E3D3) } }
    ImageIO.write(out, "png", File("build/screens/shield_turn.png"))
}

/** Every supply: its old drawn icon beside its new picture built in the round. */
fun renderSupplySheet() {
    val cell = 32 * 4 + 12
    val items = de.bornim.core.Items.all
    val cols = 4; val rows = (items.size + cols - 1) / cols
    val colW = cell * 2 + 20; val rowH = cell + 22
    val img = BufferedImage(colW * cols, rowH * rows, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics(); g.color = Color(0x1B1A2A); g.fillRect(0, 0, img.width, img.height)
    g.font = Font("SansSerif", Font.PLAIN, 14)
    for ((i, it) in items.withIndex()) {
        val ox = (i % cols) * colW; val oy = (i / cols) * rowH
        g.put(IconArt.get(it.icon), ox + 4, oy + 4, cell)
        g.put(de.bornim.core.art.SupplyArt.get(it.id), ox + 4 + cell, oy + 4, cell)
        g.color = Color(0xE9E3D3); g.drawString(it.name.de, ox + 6, oy + cell + 14)
    }
    ImageIO.write(img, "png", File("build/screens/supply_sheet.png"))
    println("wrote supply sheet")
}
