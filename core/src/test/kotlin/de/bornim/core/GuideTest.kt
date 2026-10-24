package de.bornim.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 352: the guide shows each hero the common paragraphs and the abilities of the own class only. */
class GuideTest {
    @Test
    fun eachClassReadsItsOwnAbilitiesOnly() {
        for (c in CharClass.entries) {
            val own = Guide.partsFor(c).filter { it.only != null }
            assertEquals(listOf(c), own.map { it.only }, "$c")
            assertEquals(Guide.parts.count { it.only == null } + 1, Guide.partsFor(c).size)
        }
    }

    @Test
    fun everyParagraphHasBothLanguagesAndClosesItsBold() {
        for (p in Guide.parts) {
            for (s in listOf(p.de, p.en)) {
                assertTrue(s.isNotBlank())
                assertEquals(0, Regex("\\*\\*").findAll(s).count() % 2, s)
            }
        }
        assertEquals(listOf("Kampf." to true, " Du ziehst " to false), Guide.pieces("**Kampf.** Du ziehst ").take(2))
    }
}
