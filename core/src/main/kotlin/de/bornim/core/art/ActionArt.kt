package de.bornim.core.art

import de.bornim.core.ActionKind

/** Pixel icons for the touch controls: the action button, the menu bag and running. */
object ActionArt {
    enum class Extra { NEXT, MENU, RUN, ACT }

    private val cache = HashMap<String, PixelImage>()

    fun icon(kind: ActionKind): PixelImage = cache.getOrPut(kind.name) {
        draw(16, 16) {
            when (kind) {
                ActionKind.TALK -> talk()
                ActionKind.OPEN -> chest()
                ActionKind.READ -> scroll()
                ActionKind.REST -> fire()
                ActionKind.UNLOCK -> key()
                ActionKind.LOOK -> eye()
                ActionKind.FIGHT -> swords()
            }
            outline(Pal.OUTLINE)
        }
    }

    fun icon(extra: Extra): PixelImage = cache.getOrPut(extra.name) {
        draw(16, 16) {
            when (extra) {
                Extra.NEXT -> next()
                Extra.MENU -> bag()
                Extra.RUN -> boot()
                Extra.ACT -> spark()
            }
            outline(Pal.OUTLINE)
        }
    }

    private val PAPER = argb(0xF4E8C8)
    private val PAPER_DARK = argb(0xD0B888)
    private val INK = argb(0x3A3040)

    private fun Pen.talk() {
        rect(2, 3, 13, 10, Pal.WHITE)
        rect(1, 4, 14, 9, Pal.WHITE)
        rect(3, 10, 13, 10, argb(0xD8D8E8))
        tri(4, 10, 8, 10, 3, 14, Pal.WHITE)
        for (x in listOf(4, 7, 10)) rect(x, 6, x + 1, 7, INK)
    }

    private fun Pen.chest() {
        rect(2, 7, 13, 13, Pal.WOOD)
        rect(2, 11, 13, 13, Pal.WOOD_DARK)
        rect(2, 4, 13, 6, Pal.WOOD_LIGHT)
        rect(3, 3, 12, 3, Pal.WOOD_LIGHT)
        rect(2, 7, 13, 7, Pal.GOLD_DARK)
        rect(7, 6, 8, 9, Pal.GOLD)
        px(7, 8, INK)
    }

    private fun Pen.scroll() {
        rect(3, 2, 12, 13, PAPER)
        rect(2, 1, 13, 2, PAPER_DARK)
        rect(2, 13, 13, 14, PAPER_DARK)
        for (y in listOf(5, 7, 9, 11)) rect(5, y, if (y == 11) 8 else 10, y, INK)
    }

    private fun Pen.fire() {
        line(2, 13, 13, 11, Pal.WOOD_DARK)
        line(2, 11, 13, 13, Pal.WOOD)
        ellipse(7.5, 8.0, 4.0, 5.0, Pal.FIRE_DARK)
        ellipse(7.5, 8.5, 3.0, 3.8, Pal.FIRE)
        ellipse(7.5, 9.5, 1.6, 2.2, Pal.FIRE_LIGHT)
        tri(6, 4, 8, 0, 9, 4, Pal.FIRE)
    }

    private fun Pen.key() {
        ellipse(4.5, 5.5, 3.5, 3.5, Pal.GOLD)
        ellipse(4.5, 5.5, 1.5, 1.5, 0)
        rect(7, 5, 14, 6, Pal.GOLD)
        rect(11, 7, 12, 9, Pal.GOLD_DARK)
        rect(13, 7, 14, 8, Pal.GOLD_DARK)
        px(3, 4, Pal.WHITE)
    }

    private fun Pen.eye() {
        ellipse(8.0, 8.0, 7.0, 4.0, Pal.WHITE)
        ellipse(8.0, 8.0, 3.0, 3.0, argb(0x4878D0))
        ellipse(8.0, 8.0, 1.5, 1.5, INK)
        px(7, 6, Pal.WHITE)
    }

    private fun Pen.swords() {
        // two crossed blades
        for (i in 0..9) {
            px(2 + i, 2 + i, Pal.STONE_LIGHT); px(3 + i, 2 + i, Pal.STONE)
            px(13 - i, 2 + i, Pal.STONE_LIGHT); px(12 - i, 2 + i, Pal.STONE)
        }
        rect(1, 10, 4, 11, Pal.GOLD); rect(11, 10, 14, 11, Pal.GOLD)
        rect(2, 12, 3, 14, Pal.WOOD_DARK); rect(12, 12, 13, 14, Pal.WOOD_DARK)
    }

    private fun Pen.next() {
        tri(4, 2, 4, 13, 12, 7, Pal.WHITE)
        rect(4, 11, 5, 13, argb(0xD8D8E8))
    }

    private fun Pen.bag() {
        rect(3, 5, 12, 14, Pal.WOOD)
        rect(3, 12, 12, 14, Pal.WOOD_DARK)
        rect(2, 6, 2, 13, Pal.WOOD_DARK)
        rect(13, 6, 13, 13, Pal.WOOD_DARK)
        rect(3, 4, 12, 8, Pal.WOOD_LIGHT)
        rect(6, 1, 9, 1, Pal.WOOD_DARK)
        px(5, 2, Pal.WOOD_DARK); px(10, 2, Pal.WOOD_DARK); px(5, 3, Pal.WOOD_DARK); px(10, 3, Pal.WOOD_DARK)
        rect(7, 8, 8, 10, Pal.GOLD)
    }

    private fun Pen.boot() {
        rect(5, 2, 9, 10, Pal.WOOD)
        rect(5, 10, 13, 13, Pal.WOOD)
        rect(5, 13, 13, 13, Pal.WOOD_DARK)
        rect(5, 2, 9, 3, Pal.WOOD_LIGHT)
        for (y in listOf(5, 8, 11)) rect(0, y, 2, y, Pal.WHITE)
    }

    private fun Pen.spark() {
        rect(7, 1, 8, 14, Pal.GOLD)
        rect(1, 7, 14, 8, Pal.GOLD)
        rect(5, 5, 10, 10, Pal.GOLD)
        rect(7, 6, 8, 9, Pal.WHITE)
    }
}
