package de.bornim.core.art

import de.bornim.core.Icon

/** 16×16 item icons. */
object IconArt {
    private val cache = HashMap<Icon, PixelImage>()

    fun get(icon: Icon): PixelImage = cache.getOrPut(icon) {
        draw(16, 16, k = 2) {
            when (icon) {
                Icon.SWORD -> {
                    line(4, 11, 12, 3, Pal.STONE_LIGHT); line(5, 11, 13, 3, Pal.STONE)
                    line(2, 10, 6, 14, Pal.GOLD_DARK); rect(2, 13, 3, 14, Pal.WOOD_DARK)
                }
                Icon.DAGGER -> {
                    line(6, 10, 11, 5, Pal.STONE_LIGHT); line(7, 10, 12, 5, Pal.STONE)
                    line(4, 9, 8, 13, Pal.GOLD_DARK); rect(3, 12, 4, 13, Pal.WOOD_DARK)
                }
                Icon.AXE -> {
                    line(4, 14, 11, 3, Pal.WOOD); line(5, 14, 12, 3, Pal.WOOD_DARK)
                    tri(9, 2, 15, 3, 13, 9, Pal.STONE_LIGHT)
                }
                Icon.MACE -> {
                    line(4, 14, 9, 7, Pal.WOOD); line(5, 14, 10, 7, Pal.WOOD_DARK)
                    ball(11.0, 5.0, 3.5, 3.5, Pal.IRON_LIGHT, Pal.WHITE, Pal.IRON)
                }
                Icon.STAFF -> {
                    line(3, 14, 12, 3, Pal.WOOD); line(4, 14, 13, 3, Pal.WOOD_DARK)
                    ball(12.5, 3.0, 2.5, 2.5, Pal.FIRE, Pal.FIRE_LIGHT, Pal.FIRE_DARK)
                }
                Icon.BOW -> {
                    for (i in 0..11) px(4 + if (i in 3..8) 0 else 1, 2 + i, Pal.WOOD)
                    line(5, 2, 12, 2, Pal.WOOD_DARK); line(5, 13, 12, 13, Pal.WOOD_DARK)
                    line(12, 2, 12, 13, Pal.WHITE)
                }
                Icon.ARMOR -> {
                    rect(4, 4, 11, 13, Pal.STONE); rect(4, 4, 6, 13, Pal.STONE_LIGHT)
                    rect(2, 4, 3, 8, Pal.STONE_DARK); rect(12, 4, 13, 8, Pal.STONE_DARK)
                    rect(6, 3, 9, 4, Pal.IRON)
                }
                Icon.SHIELD -> {
                    ball(8.0, 7.0, 5.5, 6.0, Pal.WOOD, Pal.WOOD_LIGHT, Pal.WOOD_DARK)
                    line(8, 1, 8, 13, Pal.GOLD); line(3, 7, 13, 7, Pal.GOLD)
                }
                Icon.RING -> {
                    ellipse(8.0, 9.0, 4.5, 4.5, Pal.GOLD); ellipse(8.0, 9.0, 2.5, 2.5, 0)
                    ball(8.0, 4.0, 2.0, 2.0, argb(0x5AA8FF), Pal.WHITE, argb(0x3070D0))
                }
                Icon.AMULET -> {
                    line(3, 2, 8, 9, Pal.GOLD_DARK); line(13, 2, 8, 9, Pal.GOLD_DARK)
                    ball(8.0, 10.0, 3.0, 3.0, Pal.RED, Pal.PINK, argb(0x902020))
                }
                Icon.CLOAK -> {
                    tri(8, 2, 2, 14, 14, 14, argb(0x7048A0))
                    tri(8, 2, 6, 14, 10, 14, argb(0x9068C0))
                    rect(6, 2, 10, 3, Pal.GOLD)
                }
                Icon.GLOVES -> {
                    rect(4, 5, 11, 13, argb(0x8A5A30)); rect(4, 5, 11, 6, Pal.WOOD_LIGHT)
                    for (x in 4..10 step 2) rect(x, 2, x, 5, argb(0x8A5A30))
                    rect(12, 7, 13, 10, argb(0x8A5A30))
                }
                Icon.HAMMER -> {
                    line(4, 14, 9, 7, Pal.WOOD); line(5, 14, 10, 7, Pal.WOOD_DARK)
                    tri(7, 4, 13, 2, 14, 7, Pal.IRON_LIGHT); rect(8, 3, 13, 7, Pal.IRON_LIGHT); rect(8, 6, 13, 7, Pal.IRON)
                }
                Icon.SPEAR -> {
                    line(3, 14, 11, 5, Pal.WOOD); line(4, 14, 12, 5, Pal.WOOD_DARK)
                    tri(10, 6, 14, 1, 13, 7, Pal.STONE_LIGHT)
                }
                Icon.WAND -> {
                    line(4, 13, 11, 5, Pal.WOOD_DARK); line(5, 13, 12, 5, Pal.WOOD)
                    ball(12.5, 4.0, 1.8, 1.8, argb(0x7AD0FF), Pal.WHITE, argb(0x3070D0))
                    px(14, 2, Pal.WHITE); px(10, 2, argb(0x7AD0FF))
                }
                Icon.CROSSBOW -> {
                    rect(7, 4, 8, 14, Pal.WOOD); line(2, 6, 13, 6, Pal.WOOD_DARK); line(2, 6, 7, 10, Pal.WHITE); line(13, 6, 8, 10, Pal.WHITE)
                    rect(7, 2, 8, 4, Pal.IRON_LIGHT)
                }
                Icon.ROBE -> {
                    tri(8, 2, 2, 14, 14, 14, argb(0x3858C0)); rect(5, 3, 10, 6, argb(0x3858C0))
                    line(8, 4, 8, 14, argb(0x203888)); rect(4, 9, 11, 9, Pal.GOLD)
                }
                Icon.ORB -> {
                    rect(5, 12, 10, 14, Pal.WOOD_DARK)
                    ball(8.0, 7.0, 5.0, 5.0, argb(0x9A6AE0), Pal.WHITE, argb(0x5A30A0))
                }
                Icon.TOME -> {
                    rect(3, 3, 12, 13, argb(0x7A2A2A)); rect(4, 3, 12, 12, argb(0xA03838)); rect(11, 4, 12, 13, Pal.WHITE)
                    rect(6, 6, 9, 9, Pal.GOLD); px(7, 7, Pal.GOLD_DARK)
                }
                Icon.SYMBOL -> {
                    ball(8.0, 8.0, 5.5, 5.5, Pal.GOLD, Pal.FIRE_LIGHT, Pal.GOLD_DARK)
                    rect(7, 4, 8, 12, Pal.WHITE); rect(5, 7, 10, 8, Pal.WHITE)
                }
                Icon.HELMET -> {
                    ball(8.0, 8.0, 6.0, 6.0, Pal.STONE, Pal.STONE_LIGHT, Pal.STONE_DARK)
                    rect(2, 8, 13, 13, 0); rect(2, 8, 13, 9, Pal.IRON); rect(7, 9, 8, 12, Pal.IRON)
                }
                Icon.HOOD -> {
                    ball(8.0, 8.0, 6.0, 6.5, argb(0x3E7040), argb(0x5E9A5A), argb(0x284A2C))
                    ellipse(8.0, 10.0, 3.0, 3.5, Pal.BLACK)
                }
                Icon.CIRCLET -> {
                    ellipse(8.0, 9.0, 6.5, 3.5, Pal.GOLD); ellipse(8.0, 9.0, 5.0, 2.2, 0)
                    ball(8.0, 6.0, 1.8, 1.8, Pal.RED, Pal.PINK, argb(0x902020))
                }
                Icon.BRACERS -> {
                    rect(3, 4, 7, 12, Pal.WOOD); rect(9, 4, 13, 12, Pal.WOOD)
                    rect(3, 5, 7, 5, Pal.IRON_LIGHT); rect(9, 5, 13, 5, Pal.IRON_LIGHT); rect(3, 10, 7, 10, Pal.IRON_LIGHT); rect(9, 10, 13, 10, Pal.IRON_LIGHT)
                }
                Icon.LEGS -> {
                    rect(4, 2, 11, 5, argb(0x5A4A3A)); rect(4, 5, 7, 14, argb(0x6A5A48)); rect(9, 5, 12, 14, argb(0x5A4A3A))
                }
                Icon.BOOTS -> {
                    rect(3, 3, 6, 11, Pal.WOOD); rect(3, 11, 8, 13, Pal.WOOD_DARK)
                    rect(9, 3, 12, 11, Pal.WOOD); rect(9, 11, 14, 13, Pal.WOOD_DARK)
                    rect(3, 3, 6, 4, Pal.WOOD_LIGHT); rect(9, 3, 12, 4, Pal.WOOD_LIGHT)
                }
                Icon.POTION -> potion(Pal.RED, argb(0xF07070))
                Icon.BIG_POTION -> potion(argb(0xC03090), argb(0xF070C0))
                Icon.FLASK -> potion(Pal.FIRE, Pal.FIRE_LIGHT)
                Icon.KEY -> {
                    ellipse(5.0, 6.0, 3.0, 3.0, Pal.GOLD_DARK); ellipse(5.0, 6.0, 1.3, 1.3, 0)
                    rect(7, 6, 14, 7, Pal.GOLD_DARK); rect(11, 8, 11, 9, Pal.GOLD_DARK); rect(13, 8, 13, 10, Pal.GOLD_DARK)
                }
                Icon.SUN -> {
                    for (i in 0 until 8) {
                        val dx = listOf(0, 1, 1, 1, 0, -1, -1, -1)[i]
                        val dy = listOf(-1, -1, 0, 1, 1, 1, 0, -1)[i]
                        line(8, 8, 8 + dx * 7, 8 + dy * 7, Pal.FIRE_LIGHT)
                    }
                    ball(8.0, 8.0, 4.5, 4.5, Pal.GOLD, Pal.FIRE_LIGHT, Pal.GOLD_DARK)
                }
                Icon.NOTE -> {
                    rect(3, 2, 12, 13, argb(0xF0E8D0))
                    for (y in 4..10 step 2) line(5, y, 10, y, Pal.STONE_DARK)
                    ellipse(8.0, 12.0, 2.0, 2.0, argb(0x707080))
                }
            }
            outline(Pal.OUTLINE)
        }
    }

    private fun Pen.potion(c: Int, light: Int) {
        rect(7, 1, 9, 2, Pal.WOOD)
        rect(7, 3, 9, 5, Pal.GLASS)
        ball(8.0, 10.0, 5.0, 4.5, c, light, c)
        px(6, 8, Pal.WHITE)
    }
}
