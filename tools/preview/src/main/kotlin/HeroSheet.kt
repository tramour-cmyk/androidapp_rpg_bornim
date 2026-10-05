package preview

import de.bornim.core.CharClass
import de.bornim.core.Dice
import de.bornim.core.Facing
import de.bornim.core.GameState
import de.bornim.core.GearSlot
import de.bornim.core.Loot
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.Rules
import de.bornim.core.art.CharacterArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Map sprites of every class: start gear, then two looted sets of rising rarity, in all four directions. */
fun renderHeroSheet() {
    val scale = 5
    val facings = listOf(Facing.DOWN, Facing.LEFT, Facing.RIGHT, Facing.UP)
    val rows = mutableListOf<List<de.bornim.core.art.PixelImage>>()
    for (cls in CharClass.entries) for ((tier, rarities) in listOf(emptyList(), listOf(Rarity.UNCOMMON, Rarity.RARE), listOf(Rarity.EPIC, Rarity.DIVINE)).withIndex()) {
        val s = GameState.newGame("T", if (tier == 2) Race.ELF else Race.HUMAN, cls)
        s.hero.gainXp(Rules.xpForLevel[9])
        val dice = Dice(kotlin.random.Random(7 + tier + cls.ordinal * 3))
        if (rarities.isNotEmpty()) for ((i, slot) in GearSlot.entries.withIndex()) {
            repeat(6) {
                val item = Loot.generate(s, dice, 9, rarities[i % rarities.size], cls, slot)
                if (s.hero.canWear(item) && s.hero.item(slot)?.rarity.let { it == null || it == Rarity.COMMON }) s.equipFromBag(s.addGear(item))
            }
        }
        rows += facings.flatMap { f -> listOf(CharacterArt.hero(s.hero, f, 0), CharacterArt.hero(s.hero, f, 1)) }
    }
    val cw = 32 * scale + 8
    val img = BufferedImage(cw * 8, cw * rows.size, BufferedImage.TYPE_INT_ARGB)
    for ((r, row) in rows.withIndex()) for ((c, p) in row.withIndex()) {
        for (y in 0 until cw) for (x in 0 until cw) img.setRGB(c * cw + x, r * cw + y, if ((r / 3) % 2 == 0) 0xFF4A7A3A.toInt() else 0xFF557F44.toInt())
        for (y in 0 until p.height) for (x in 0 until p.width) {
            val v = p[x, y]
            if ((v ushr 24) == 0) continue
            for (dy in 0 until scale) for (dx in 0 until scale) img.setRGB(c * cw + 4 + x * scale + dx, r * cw + 4 + y * scale + dy, v)
        }
    }
    ImageIO.write(img, "png", File("build/screens/hero_sheet.png"))
    println("wrote hero_sheet")
}
