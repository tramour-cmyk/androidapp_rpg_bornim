package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PreludeTest {
    @Test
    fun firmThenPauseThenNameThenMenuInAboutSixSeconds() {
        assertEquals(0f, Prelude.firm(0))
        assertEquals(1f, Prelude.firm(1000))
        assertEquals(0f, Prelude.firm(Prelude.firmEnd))
        // the name only once the firm is gone and a pause has passed, never both at once (292.1)
        assertEquals(0f, Prelude.name(Prelude.firmEnd))
        assertEquals(0f, Prelude.name(Prelude.nameStart))
        assertTrue(Prelude.nameStart - Prelude.firmEnd >= 500, "a heard pause")
        // the logo stands until the firm's sound (2.1 s) is over
        assertEquals(1f, Prelude.firm(2100))
        assertEquals(1f, Prelude.name(Prelude.nameStart + Prelude.fadeIn))
        // the name stays while the menu comes in
        assertEquals(1f, Prelude.name(Prelude.end + 5000))
        assertEquals(0f, Prelude.menu(Prelude.menuStart))
        assertEquals(1f, Prelude.menu(Prelude.end))
        assertTrue(Prelude.end in 5400L..6000L, "about 6 s: ${Prelude.end}")
    }
}
