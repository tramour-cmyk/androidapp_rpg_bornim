package de.bornim.core.audio

import de.bornim.core.MapKind
import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 18h, 18i: the crackle swells and fades without a jump; the cave keeps its drops; every fire can be heard. */
class AmbienceTest {
    private val tick = 100L

    @Test
    fun crackleSwellsAndFadesWithoutAJump() {
        // walking up to a fire at a brisk pace (a tile every 250 ms), standing there, walking off again, then a fight
        val dists = (8 downTo 0).flatMap { d -> List(3) { d.toDouble() } } + List(20) { 0.0 } +
            (0..8).flatMap { d -> List(3) { d.toDouble() } }
        var cur = 0f
        val levels = mutableListOf<Float>()
        for (d in dists) { cur = Ambience.approach(cur, Ambience.fireTarget(d), tick); levels += cur }
        val maxStep = levels.zipWithNext { a, b -> kotlin.math.abs(b - a) }.max()
        assertTrue(maxStep <= Ambience.FIRE_MAX * tick / Ambience.FADE_MS + 1e-6, "Sprung im Knistern: $maxStep")
        assertEquals(0f, levels.first(), "setzt schon weit weg ein")
        assertEquals(Ambience.FIRE_MAX, levels[30], "am Feuer nicht voll")
        assertEquals(0f, levels.last(), "verklingt nicht")
        // and the first moment within reach is soft, not full
        val firstHeard = levels.first { it > 0f }
        assertTrue(firstHeard < 0.1f * Ambience.FIRE_MAX + 1e-6, "setzt zu laut ein: $firstHeard")
        // a fight starting: gone within the fade time
        var f = Ambience.FIRE_MAX
        repeat((Ambience.FADE_MS / tick).toInt()) { f = Ambience.approach(f, 0f, tick) }
        assertEquals(0f, f)
    }

    @Test
    fun targetFallsSteadilyWithDistance() {
        val ts = (0..70).map { Ambience.fireTarget(it / 10.0) }
        assertTrue(ts.zipWithNext().all { (a, b) -> b <= a }, "nicht stetig fallend")
        assertEquals(Ambience.FIRE_MAX, Ambience.fireTarget(0.5))
        assertEquals(0f, Ambience.fireTarget(Ambience.FIRE_FAR))
        assertEquals(0f, Ambience.fireTarget(null))
    }

    @Test
    fun everyFireOnTheMapsIsFoundAndTheCaveDrips() {
        for (m in World.maps.values) for (y in 0 until m.height) for (x in 0 until m.width) {
            if (m.tile(x, y) != Tile.CAMPFIRE && m.tile(x, y) != Tile.HEARTH) continue
            val carry = if (m.kind == MapKind.INTERIOR) Ambience.INDOOR_CARRY else 1.0
            assertEquals(1.0 / carry, Ambience.nearestFire(m, x, y + 1) ?: Ambience.nearestFire(m, x + 1, y), "Feuer ${m.id} $x,$y")
        }
        // the cave has floor far from any fire, where only the drops are heard
        val cave = World.maps.values.first { it.kind == MapKind.CAVE }
        val quiet = (0 until cave.height).sumOf { y -> (0 until cave.width).count { x -> cave.tile(x, y).walkable && Ambience.nearestFire(cave, x, y) == null } }
        assertTrue(quiet > 20, "kaum Höhle ohne Feuer: $quiet")
        assertTrue(Ambience.dripVolume(Ambience.FIRE_MAX) in 0.1f..Ambience.DRIP_VOLUME)
    }

    @Test
    fun theFireIsNotHeardThroughWalls() {
        // D1.9: in the passage at (11,15) the goblins' fire lay two walls away as the crow flies
        val cave = World.maps.values.first { it.kind == MapKind.CAVE }
        val near = (-7..7).flatMap { dy -> (-7..7).map { dx -> dx to dy } }
            .filter { (dx, dy) -> cave.tile(11 + dx, 15 + dy) == Tile.CAMPFIRE }
            .minOf { (dx, dy) -> Math.hypot(dx.toDouble(), dy.toDouble()) }
        val heard = Ambience.nearestFire(cave, 11, 15)
        assertTrue(heard == null || heard > near + 1.5, "Feuer durch die Wand: Weg $heard, Luftlinie $near")
        // on open floor the way is the straight line
        for (m in World.maps.values) for (y in 0 until m.height) for (x in 0 until m.width) {
            if (m.tile(x, y) != Tile.CAMPFIRE && m.tile(x, y) != Tile.HEARTH) continue
            val carry = if (m.kind == MapKind.INTERIOR) Ambience.INDOOR_CARRY else 1.0
            if (m.tile(x, y + 1).walkable && m.tile(x, y + 2).walkable) assertEquals(2.0 / carry, Ambience.nearestFire(m, x, y + 2), "${m.id} $x,$y")
        }
    }

    @Test
    fun theInnHearthIsHeardFromTheDoor() {
        // D3.12: the hearth stood exactly FIRE_FAR from the door, the crackle was cut off there; softly heard now
        for (m in World.maps.values.filter { it.kind == MapKind.INTERIOR }) {
            val hearth = (0 until m.height).any { y -> (0 until m.width).any { x -> m.tile(x, y) == Tile.HEARTH } }
            if (!hearth) continue
            for (w in m.warps) {
                val (x, y) = listOf(w.x to w.y - 1, w.x to w.y + 1, w.x - 1 to w.y, w.x + 1 to w.y).first { (x, y) -> m.inside(x, y) && m.tile(x, y).walkable }
                val t = Ambience.fireTarget(Ambience.nearestFire(m, x, y))
                assertTrue(t > 0.1f * Ambience.FIRE_MAX, "${m.id}: Herd an der Tür $x,$y kaum hörbar: $t")
            }
        }
    }
}
