package de.bornim.core

import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class IntroTest {
    @Test
    fun fivePicturesInThirtyToFortySeconds() {
        // 70: about five pictures, together about 30–40 s
        assertEquals(5, Intro.pictures)
        assertTrue(Intro.totalMs in 30_000L..40_000L, "intro lasts ${Intro.totalMs} ms")
        for (l in Intro.lines) assertTrue(l.de.isNotBlank() && l.en.isNotBlank())
    }

    @Test
    fun neverJumpsAndTextOnlyOnAFullPicture() {
        var last = Intro.at(0)
        assertEquals(0, last.picture)
        var t = 0L
        while (t <= Intro.totalMs + 100) {
            val f = Intro.at(t)
            assertTrue(f.picture >= last.picture, "pictures only go forward")
            // the same picture changes its fade smoothly; a new picture starts from (almost) nothing
            if (f.picture == last.picture) {
                assertTrue(abs(f.mix - last.mix) < 0.05f, "no jump in the fade at $t")
                assertTrue(abs(f.text - last.text) < 0.05f, "no jump in the sentence at $t")
            } else {
                assertTrue(f.mix < 0.05f, "a new picture fades in at $t")
                assertTrue(last.text < 0.05f, "the sentence has gone before the next picture at $t")
            }
            // a sentence never shows while its picture is still fading in
            if (f.text > 0f) assertEquals(1f, f.mix, "sentence over a half-faded picture at $t")
            assertTrue(abs(f.gone - last.gone) < 0.05f)
            last = f
            t += 16
        }
        assertTrue(Intro.at(Intro.totalMs).done)
        assertEquals(Intro.black, Intro.at(Intro.totalMs - 1).picture)
    }
}
