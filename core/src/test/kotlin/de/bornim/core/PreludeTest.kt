package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PreludeTest {
    @Test
    fun firmThenNameThenMenuInAboutFourSeconds() {
        assertEquals(0f, Prelude.firm(0))
        assertEquals(1f, Prelude.firm(1000))
        assertEquals(0f, Prelude.firm(Prelude.firmEnd))
        // the name only once the firm is gone, never both at once
        assertEquals(0f, Prelude.name(Prelude.firmEnd))
        assertEquals(1f, Prelude.name(Prelude.firmEnd + Prelude.fadeIn))
        // the name stays while the menu comes in
        assertEquals(1f, Prelude.name(Prelude.end + 5000))
        assertEquals(0f, Prelude.menu(Prelude.menuStart))
        assertEquals(1f, Prelude.menu(Prelude.end))
        assertTrue(Prelude.end in 3800L..4400L, "about 4 s: ${Prelude.end}")
    }
}
