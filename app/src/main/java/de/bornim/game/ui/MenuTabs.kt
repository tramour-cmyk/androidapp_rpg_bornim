package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp

/**
 * 60j (A ja, 13.10.): the menu tabs as a drawn sign with a small word under it, gold lines on black like the
 * frame of the text box. The signs are drawn on a grid of 24 by 24, in lines, never filled.
 */
enum class TabSign { HERO, BAG, GEAR, MAP, CHRONICLE, SYSTEM, TEST }

@Composable
fun TabButton(sign: TabSign, label: String, modifier: Modifier = Modifier, selected: Boolean, badge: Boolean = false, onClick: () -> Unit) {
    val click = LocalClick.current
    // 326: only the sign; the name of the chosen tab stands large above the row (MenuBody)
    Box(
        modifier
            .height(46.dp)
            .background(if (selected) Veil.raised else Color.Black)
            .border(if (selected) 1.5.dp else 1.dp, if (selected) Veil.bright else Veil.line)
            .clickable { click(); onClick() }
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) {
        Canvas(Modifier.size(30.dp)) { glyph(sign, if (selected) Veil.bright else Veil.gold, badge) }
    }
}

/** [sign] in lines of [c]; [badge]: a small star at the top right (points to spend). */
fun DrawScope.glyph(sign: TabSign, c: Color, badge: Boolean = false) {
    val u = size.minDimension / 24f
    fun o(x: Float, y: Float) = Offset(x * u, y * u)
    val line = Stroke(width = 1.6f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
    val thin = Stroke(width = 1.1f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
    fun path(vararg p: Pair<Float, Float>, close: Boolean = false) = Path().apply {
        moveTo(p[0].first * u, p[0].second * u); for (q in p.drop(1)) lineTo(q.first * u, q.second * u); if (close) close()
    }
    when (sign) {
        TabSign.HERO -> {
            // a helmed head over the shoulders
            drawArc(c, 180f, 180f, false, o(7.5f, 3f), Size(9f * u, 9.5f * u), style = line)
            drawLine(c, o(7.5f, 7.8f), o(7.5f, 11.5f), line.width, StrokeCap.Round)
            drawLine(c, o(16.5f, 7.8f), o(16.5f, 11.5f), line.width, StrokeCap.Round)
            drawLine(c, o(7.5f, 8.2f), o(16.5f, 8.2f), thin.width, StrokeCap.Round)
            drawLine(c, o(12f, 8.2f), o(12f, 12f), thin.width, StrokeCap.Round)
            drawPath(path(3f to 22f, 4f to 17f, 8.5f to 14.5f, 15.5f to 14.5f, 20f to 17f, 21f to 22f), c, style = line)
        }
        TabSign.BAG -> {
            // a satchel: the body, its flap with a buckle, the strap
            drawRoundRect(c, o(4f, 9f), Size(16f * u, 12f * u), androidx.compose.ui.geometry.CornerRadius(2.5f * u), style = line)
            drawPath(path(4.5f to 10f, 12f to 15f, 19.5f to 10f), c, style = line)
            drawRect(c, o(11f, 14.5f), Size(2f * u, 2.5f * u), style = thin)
            drawArc(c, 180f, 180f, false, o(7f, 2.5f), Size(10f * u, 12f * u), style = thin)
        }
        TabSign.GEAR -> {
            // a heater shield, a sword across it
            drawPath(path(5f to 5f, 15f to 5f, 15f to 11f, 14f to 15f, 10f to 19f, 6f to 15f, 5f to 11f, close = true), c, style = line)
            drawLine(c, o(8f, 21.5f), o(20.5f, 3f), line.width, StrokeCap.Round)
            drawLine(c, o(9.2f, 15.5f), o(14.5f, 19f), line.width, StrokeCap.Round)
            drawLine(c, o(10.2f, 20.6f), o(7.6f, 22.5f), thin.width, StrokeCap.Round)
        }
        TabSign.MAP -> {
            // a map folded in three, a dotted way and a cross
            drawPath(path(3f to 6f, 9f to 4f, 15f to 6f, 21f to 4f, 21f to 18f, 15f to 20f, 9f to 18f, 3f to 20f, close = true), c, style = line)
            drawLine(c, o(9f, 4f), o(9f, 18f), thin.width)
            drawLine(c, o(15f, 6f), o(15f, 20f), thin.width)
            for ((x, y) in listOf(5.5f to 15.5f, 7.5f to 13.5f, 10.5f to 12.8f, 13f to 11.5f, 15.5f to 10.5f))
                drawCircle(c, 0.7f * u, o(x, y))
            drawLine(c, o(17f, 7.5f), o(19.5f, 10f), thin.width, StrokeCap.Round)
            drawLine(c, o(19.5f, 7.5f), o(17f, 10f), thin.width, StrokeCap.Round)
        }
        TabSign.CHRONICLE -> {
            // 64: a scroll, rolled at both ends, three lines of writing
            drawRoundRect(c, o(4f, 3.5f), Size(16f * u, 3.5f * u), androidx.compose.ui.geometry.CornerRadius(1.7f * u), style = line)
            drawRoundRect(c, o(4f, 17f), Size(16f * u, 3.5f * u), androidx.compose.ui.geometry.CornerRadius(1.7f * u), style = line)
            drawLine(c, o(6f, 7f), o(6f, 17f), line.width, StrokeCap.Round)
            drawLine(c, o(18f, 7f), o(18f, 17f), line.width, StrokeCap.Round)
            for (y in listOf(9.5f, 12f, 14.5f)) drawLine(c, o(8.5f, y), o(if (y == 14.5f) 12.5f else 15.5f, y), thin.width, StrokeCap.Round)
        }
        TabSign.SYSTEM -> {
            // an hourglass: the game's time, saving and loading
            drawLine(c, o(5f, 3.5f), o(19f, 3.5f), line.width, StrokeCap.Round)
            drawLine(c, o(5f, 20.5f), o(19f, 20.5f), line.width, StrokeCap.Round)
            drawPath(path(7f to 3.5f, 7f to 6f, 11f to 12f, 7f to 18f, 7f to 20.5f), c, style = line)
            drawPath(path(17f to 3.5f, 17f to 6f, 13f to 12f, 17f to 18f, 17f to 20.5f), c, style = line)
            drawPath(path(9f to 19.5f, 12f to 16f, 15f to 19.5f, close = true), c)
        }
        TabSign.TEST -> {
            // a flask with a narrow neck
            drawPath(path(10f to 3.5f, 10f to 9.5f, 4.5f to 19f, 5.5f to 21f, 18.5f to 21f, 19.5f to 19f, 14f to 9.5f, 14f to 3.5f), c, style = line)
            drawLine(c, o(8.5f, 3.5f), o(15.5f, 3.5f), line.width, StrokeCap.Round)
            drawLine(c, o(7f, 15f), o(17f, 15f), thin.width, StrokeCap.Round)
        }
    }
    if (badge) {
        // points to spend: a small star, as the ★ after the word was
        val s = Path().apply {
            for (i in 0 until 10) {
                val a = Math.PI / 2 + i * Math.PI / 5; val r = if (i % 2 == 0) 3.2f else 1.3f
                val x = (21f + r * Math.cos(a).toFloat()) * u; val y = (3.5f - r * Math.sin(a).toFloat()) * u
                if (i == 0) moveTo(x, y) else lineTo(x, y)
            }
            close()
        }
        drawPath(s, Veil.bright)
    }
}
