package de.bornim.game.ui

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import de.bornim.core.Game
import de.bornim.core.MapDef
import de.bornim.core.art.MapLight
import de.bornim.core.art.WaterLife
import de.bornim.core.art.WorldArt

/*
 * 221: life on the water ([WaterLife]), drawn flat under the turned mapping like the ground: the glints with the ground,
 * under everything standing; the rain's rings and the night's streaks of light after the light of the place, so they
 * shine, and not where something standing in front covers the spot ([covered], map pixels).
 */

private fun tiles(camX: Int, camY: Int, viewW: Float, viewH: Float): IntArray {
    val T = WorldArt.T
    return intArrayOf(Math.floorDiv(camX, T) - 1, Math.floorDiv(camY, T) - 1, ((camX + viewW) / T).toInt() + 1, ((camY + viewH) / T).toInt() + 1)
}

private fun DrawScope.line(l: WaterLife.Line, camX: Int, camY: Int, scale: Int, width: Float) {
    val c = Color(0xFF000000.toInt() or l.color).copy(alpha = l.alpha.coerceIn(0f, 1f))
    drawLine(
        c,
        Offset((l.x - l.ux * l.half - camX) * scale, (l.y - l.uy * l.half - camY) * scale),
        Offset((l.x + l.ux * l.half - camX) * scale, (l.y + l.uy * l.half - camY) * scale),
        width * scale,
    )
}

/** The glints drifting on the water, with the ground. */
internal fun DrawScope.drawWaterGlints(game: Game, map: MapDef, clock: Long, camX: Int, camY: Int, scale: Int, viewW: Float, viewH: Float) {
    val (x0, y0, x1, y1) = tiles(camX, camY, viewW, viewH).let { listOf(it[0], it[1], it[2], it[3]) }
    for (l in WaterLife.glints(map, clock, x0, y0, x1, y1, game.daylight)) line(l, camX, camY, scale, 0.8f)
}

/** Rings in the rain and, at night, the streaks of the lights and the moon on the water. */
internal fun DrawScope.drawWaterOver(
    game: Game, map: MapDef, clock: Long, camX: Int, camY: Int, scale: Int, heroX: Int, heroY: Int, viewW: Float, viewH: Float,
    covered: (Float, Float) -> Boolean,
) {
    val (x0, y0, x1, y1) = tiles(camX, camY, viewW, viewH).let { listOf(it[0], it[1], it[2], it[3]) }
    for (r in WaterLife.rings(map, game.rainLevel, clock, x0, y0, x1, y1)) {
        if (covered(r.x, r.y)) continue
        val rr = r.r * scale
        drawOval(Color(0xFFC8D8E8).copy(alpha = r.alpha), Offset((r.x - camX) * scale - rr, (r.y - camY) * scale - rr), Size(rr * 2, rr * 2), style = Stroke(0.6f * scale))
    }
    if (game.daylight >= 0.6f) return
    val T = WorldArt.T
    val carried = when {
        de.bornim.core.Light.torch(game.state) -> MapLight.Carried.TORCH
        game.state.spark -> MapLight.Carried.SPARK
        else -> MapLight.Carried.NONE
    }
    val lights = MapLight.sources(map) + listOfNotNull(MapLight.carriedSource(carried, heroX + T / 2.0, heroY + T / 2.0))
    // the moon's column moves across the view in the course of the night, from the left at dusk to the right at dawn
    val moon = if (game.rainLevel < 0.05f) {
        val m = game.state.minutes
        val night = (((m - 20 * 60 + 24 * 60) % (24 * 60)) / (10 * 60f)).coerceIn(0f, 1f)
        val off = (night - 0.5f) * viewW * 0.5f
        (camX + viewW / 2.0 + off / 2) to (camY + viewH / 2.0 - off / 2)
    } else null
    for (l in WaterLife.streaks(map, lights, game.daylight, clock, x0, y0, x1, y1, moon?.first, moon?.second)) {
        if (!covered(l.x, l.y)) line(l, camX, camY, scale, 1.1f)
    }
}
