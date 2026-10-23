package de.bornim.game.ui

import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathOperation
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import de.bornim.core.ActionKind
import kotlin.math.cos
import kotlin.math.sin

/**
 * 326 B, C (Homer, docs/DESIGN-STIL.md „Zeichen (326)“): the signs of the action buttons and the bar, in the art of the
 * menu tabs ([glyph]): gold lines on a grid of 24, never filled but for dots, no pixels. They replace the pixel icons.
 */
enum class ActionSign { TALK, OPEN, READ, REST, UNLOCK, LOOK, FIGHT, ENTER, NEXT, MENU, RUN, ACT, SUN, MOON;
    companion object { fun of(kind: ActionKind) = valueOf(kind.name) }
}

fun DrawScope.actionGlyph(sign: ActionSign, c: Color) {
    val u = size.minDimension / 24f
    fun o(x: Float, y: Float) = Offset(x * u, y * u)
    val line = Stroke(width = 1.6f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
    val thin = Stroke(width = 1.1f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
    fun l(x1: Float, y1: Float, x2: Float, y2: Float, s: Stroke = line) = drawLine(c, o(x1, y1), o(x2, y2), s.width, StrokeCap.Round)
    fun dot(x: Float, y: Float, r: Float) = drawCircle(c, r * u, o(x, y))
    fun path(vararg p: Pair<Float, Float>, close: Boolean = false) = Path().apply {
        moveTo(p[0].first * u, p[0].second * u); for (q in p.drop(1)) lineTo(q.first * u, q.second * u); if (close) close()
    }
    when (sign) {
        ActionSign.TALK -> {
            // a speech bubble, its tail down left, three dots
            drawPath(Path().apply {
                addRoundRect(androidx.compose.ui.geometry.RoundRect(3f * u, 4f * u, 21f * u, 16f * u, CornerRadius(3f * u)))
            }, c, style = line)
            drawPath(path(11f to 16f, 7f to 20.5f, 8f to 16f), c, style = line)
            for (x in listOf(8f, 12f, 16f)) dot(x, 10f, 0.9f)
        }
        ActionSign.OPEN -> {
            // a chest: the box, the arched lid, its bands, the lock
            drawRect(c, o(3f, 11.5f), Size(18f * u, 9f * u), style = line)
            drawArc(c, 180f, 180f, false, o(3f, 4.5f), Size(18f * u, 14f * u), style = line)
            l(7.5f, 5.6f, 7.5f, 11.5f, thin); l(16.5f, 5.6f, 16.5f, 11.5f, thin)
            drawRect(c, o(10f, 10f), Size(4f * u, 5f * u), style = line)
            dot(12f, 12.6f, 0.9f)
        }
        ActionSign.READ -> {
            // a notice board with a roof on two posts, two lines of writing
            drawRect(c, o(3.5f, 4f), Size(17f * u, 10f * u), style = line)
            drawPath(path(2.5f to 4f, 12f to 1.5f, 21.5f to 4f), c, style = line)
            l(8f, 14f, 8f, 21f); l(16f, 14f, 16f, 21f)
            l(7f, 7.5f, 17f, 7.5f); l(7f, 10.5f, 14f, 10.5f)
        }
        ActionSign.REST -> {
            // a flame over two crossed logs
            drawPath(Path().apply {
                moveTo(12f * u, 3f * u); quadraticBezierTo(18f * u, 10f * u, 12f * u, 15.5f * u)
                quadraticBezierTo(6f * u, 10f * u, 12f * u, 3f * u); close()
            }, c, style = line)
            drawPath(Path().apply {
                moveTo(12f * u, 8.5f * u); quadraticBezierTo(14.5f * u, 12f * u, 12f * u, 14f * u)
                quadraticBezierTo(9.5f * u, 12f * u, 12f * u, 8.5f * u)
            }, c, style = thin)
            l(5f, 20.5f, 19f, 16.5f); l(5f, 16.5f, 19f, 20.5f)
        }
        ActionSign.UNLOCK -> {
            // a key: the ring, the shank, two wards
            drawCircle(c, 3.5f * u, o(7f, 12f), style = line)
            l(10.5f, 12f, 21f, 12f); l(17f, 12f, 17f, 15.5f); l(20f, 12f, 20f, 15f)
        }
        ActionSign.LOOK -> {
            // an eye: the lids, the iris, the pupil
            drawPath(Path().apply {
                moveTo(3f * u, 12f * u); quadraticBezierTo(12f * u, -5f * u, 21f * u, 12f * u) // through 12,3.5
                quadraticBezierTo(12f * u, 29f * u, 3f * u, 12f * u) // through 12,20.5; close()
            }, c, style = line)
            drawCircle(c, 3.2f * u, o(12f, 12f), style = line)
            dot(12f, 12f, 1.2f)
        }
        ActionSign.FIGHT -> {
            // two crossed swords (Homer 10:18: read as staves or „#“ before): each blade a narrow outline, pointed, crossing in
            // the upper third; a short guard across the blade, clear of the crossing; a short grip, a dot for the pommel
            for (side in listOf(1f, -1f)) {
                fun x(v: Float) = if (side > 0) v else 24f - v
                val px = x(3.5f); val py = 21f; val tx = x(17.5f); val ty = 2.5f // pommel, tip: crossing at about 40 % of the height, the points well apart
                val len = kotlin.math.hypot(tx - px, ty - py); val dx = (tx - px) / len; val dy = (ty - py) / len
                val nx = -dy; val ny = dx
                val gx = px + dx * 4.5f; val gy = py + dy * 4.5f // the guard
                val sx = tx - dx * 2.8f; val sy = ty - dy * 2.8f // where the edges begin to meet in the point
                val half = 1.25f
                // the blade an outline with parallel edges and a mitred point (a long thin wedge filled in to a bar near the tip)
                drawPath(path(gx + nx * half to gy + ny * half, sx + nx * half to sy + ny * half, tx to ty,
                    sx - nx * half to sy - ny * half, gx - nx * half to gy - ny * half), c,
                    style = Stroke(width = 0.95f * u, cap = StrokeCap.Butt, join = StrokeJoin.Miter, miter = 6f))
                l(gx + nx * 2.5f, gy + ny * 2.5f, gx - nx * 2.5f, gy - ny * 2.5f)
                l(px + dx * 1.4f, py + dy * 1.4f, gx, gy)
                dot(px, py, 1.3f)
            }
        }
        ActionSign.ENTER -> {
            // an arched doorway, its door wide open
            drawPath(Path().apply {
                moveTo(5f * u, 21f * u); lineTo(5f * u, 10f * u)
                arcTo(Rect(5f * u, 3f * u, 19f * u, 17f * u), 180f, 180f, false)
                lineTo(19f * u, 21f * u)
            }, c, style = line)
            l(3f, 21f, 21f, 21f)
            drawPath(path(5f to 10.5f, 13f to 14f, 13f to 21f), c, style = line) // ends on the sill, not below it
            dot(10.5f, 17f, 0.9f)
        }
        ActionSign.NEXT -> {
            drawPath(path(6f to 6f, 12f to 12f, 6f to 18f), c, style = line)
            drawPath(path(12f to 6f, 18f to 12f, 12f to 18f), c, style = line)
        }
        ActionSign.MENU -> glyph(TabSign.BAG, c)
        ActionSign.RUN -> {
            // a boot, its cuff and sole, three strokes of speed behind it
            drawPath(Path().apply {
                moveTo(10f * u, 3f * u); lineTo(16f * u, 3f * u); lineTo(16f * u, 11.5f * u)
                quadraticBezierTo(21f * u, 12.5f * u, 21.5f * u, 17f * u); lineTo(21.5f * u, 19.5f * u); lineTo(10f * u, 19.5f * u)
                quadraticBezierTo(8.5f * u, 19f * u, 9f * u, 16.5f * u); close()
            }, c, style = line)
            l(10f, 6.5f, 16f, 6.5f, thin); l(9.5f, 17f, 21.5f, 17f, thin)
            l(2.5f, 8f, 6.5f, 8f); l(1.5f, 12f, 6.5f, 12f); l(2.5f, 16f, 6f, 16f)
        }
        ActionSign.ACT -> {
            // a spark, four points
            drawPath(path(12f to 3f, 14f to 10f, 21f to 12f, 14f to 14f, 12f to 21f, 10f to 14f, 3f to 12f, 10f to 10f, close = true), c, style = line)
        }
        ActionSign.SUN -> {
            drawCircle(c, 4.5f * u, o(12f, 12f), style = line)
            for (i in 0 until 8) {
                val a = i * Math.PI / 4
                l(12f + 7.5f * cos(a).toFloat(), 12f + 7.5f * sin(a).toFloat(), 12f + 10f * cos(a).toFloat(), 12f + 10f * sin(a).toFloat())
            }
        }
        ActionSign.MOON -> {
            val full = Path().apply { addOval(Rect(o(12f, 12f), 8f * u)) }
            val cut = Path().apply { addOval(Rect(o(15.5f, 9.5f), 6.5f * u)) }
            drawPath(Path().apply { op(full, cut, PathOperation.Difference) }, c, style = line)
        }
    }
}
