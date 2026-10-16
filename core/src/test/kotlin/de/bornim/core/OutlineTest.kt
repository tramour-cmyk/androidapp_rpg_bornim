package de.bornim.core

import de.bornim.core.art.Act
import de.bornim.core.art.FoeArt
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.Outline
import de.bornim.core.art.PixelImage
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** Lasting statuses sit on the figure's own outline (53): the outline is read in the whole frame's pixels. */
class OutlineTest {
    @Test fun edgesOfACutOut() {
        val img = PixelImage(4, 3, ox = 10, oy = 20)
        img.set(1, 0, -1); img.set(3, 0, -1); img.set(2, 2, -1)
        val o = assertNotNull(Outline.of(img))
        assertEquals(20, o.top); assertEquals(22, o.bottom)
        assertEquals(Pair(11, 13), o.span(20))
        assertNull(o.span(21))
        assertEquals(Pair(11, 13), o.near(21), "the row above first, as near as the one below")
        assertEquals(Pair(12, 12), o.near(23))
        assertNull(o.span(19))
        assertNull(Outline.of(PixelImage(3, 3)))
    }

    /** Krogg stands left of the mark of his feet: the middle of his body at the chest is the outline's, not the mark's. */
    @Test fun kroggsBodyIsWhereItIsDrawn() {
        val look = MonsterLook(1)
        val f = MonsterArt.keptFrame("bugbear", look, Act.IDLE, 0, 0)
        val o = assertNotNull(Outline.of(f))
        val fine = MonsterArt.fine("bugbear")
        val tall = MonsterArt.bodySize("bugbear", look, FoeArt.W, FoeArt.height("bugbear")).second
        val chestY = ((MonsterArt.groundLine("bugbear") - tall * 0.55) * fine).toInt()
        val (l, r) = assertNotNull(o.span(chestY))
        val anchor = FoeArt.ANCHOR_X * fine
        assertTrue(l < anchor && anchor < r, "the chest spans the feet's mark: $l..$r round $anchor")
        assertTrue((l + r) / 2.0 < anchor, "Krogg leans left of the mark: middle ${(l + r) / 2.0}, mark $anchor")
    }
}
