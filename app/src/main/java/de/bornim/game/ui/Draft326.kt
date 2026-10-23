package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Game
import de.bornim.core.Lang
import de.bornim.game.GameViewModel
import de.bornim.game.BuildConfig

/** 326, Entwurf (nur Vorschau): Systemreiter mit Zeichen statt Textknöpfen, Aktionsknopf im Look des Hauptmenüs. */
object Draft326 {
    var on = false
    /** Index des Zeichens, dessen Erklärung (langer Druck) offen gezeigt wird. */
    var explain: String? = null
}

private enum class G { SAVE, ABOUT, RULES, MENU, BLOOD, TEMPO, TEXT, MAP, CONTROLS, STICK, RUN, HAND, BUZZ, ASK, STEPS }

@Composable
fun DraftHead(text: String) {
    Text(text.uppercase(), color = Veil.gold, style = TextStyle(fontFamily = Serif, fontSize = 14.sp * TypeLook.scale, letterSpacing = 3.sp))
}

@Composable
private fun Sign(key: String, name: String, value: String?, on: Boolean = true, letter: String? = null, glyph: G? = null, modifier: Modifier = Modifier) {
    Column(modifier.width(78.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Box(Modifier.size(48.dp).clip(CircleShape).border(if (Draft326.explain == key) 1.5.dp else 1.dp, if (Draft326.explain == key) Veil.bright else Veil.rim, CircleShape),
            contentAlignment = Alignment.Center) {
            val ink = if (on) Veil.text else Veil.dim
            if (letter != null) Text(letter, color = ink, style = TextStyle(fontFamily = Serif, fontSize = (if (letter.length == 1) 22 else 15).sp * TypeLook.scale, letterSpacing = 1.sp))
            else if (glyph != null) Canvas(Modifier.size(24.dp)) { drawGlyph(glyph, ink, on) }
        }
        Spacer(Modifier.height(4.dp))
        Text(name, color = Veil.text, textAlign = TextAlign.Center, maxLines = 1,
            style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale))
        if (value != null) Text(value, color = Veil.gold, textAlign = TextAlign.Center, maxLines = 1,
            style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, fontFeatureSettings = "lnum"))
    }
}

private fun DrawScope.drawGlyph(g: G, ink: Color, on: Boolean) {
    val u = size.minDimension / 22f
    val st = Stroke(width = 1.5f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
    fun p(x: Float, y: Float) = Offset(x * u, y * u)
    fun line(x1: Float, y1: Float, x2: Float, y2: Float) = drawLine(ink, p(x1, y1), p(x2, y2), st.width, StrokeCap.Round)
    when (g) {
        G.SAVE -> { // Buch mit Lesezeichen
            drawRect(ink, p(5f, 3f), Size(12f * u, 16f * u), style = st)
            line(8f, 3f, 8f, 19f)
            drawPath(Path().apply { moveTo(12f * u, 3f * u); lineTo(12f * u, 9f * u); lineTo(13.5f * u, 7.5f * u); lineTo(15f * u, 9f * u); lineTo(15f * u, 3f * u) }, ink, style = st)
        }
        G.ABOUT -> { drawCircle(ink, 9f * u, p(11f, 11f), style = st); drawCircle(ink, 1.1f * u, p(11f, 7f)); line(11f, 10f, 11f, 15.5f) }
        G.RULES -> { // offenes Buch
            drawPath(Path().apply { moveTo(11f * u, 6f * u); quadraticBezierTo(7f * u, 3.5f * u, 2.5f * u, 5f * u); lineTo(2.5f * u, 18f * u); quadraticBezierTo(7f * u, 16.5f * u, 11f * u, 19f * u)
                quadraticBezierTo(15f * u, 16.5f * u, 19.5f * u, 18f * u); lineTo(19.5f * u, 5f * u); quadraticBezierTo(15f * u, 3.5f * u, 11f * u, 6f * u); lineTo(11f * u, 19f * u) }, ink, style = st)
            line(5f, 9f, 8.5f, 9.5f); line(5f, 12.5f, 8.5f, 13f); line(13.5f, 9.5f, 17f, 9f); line(13.5f, 13f, 17f, 12.5f) }
        G.MENU -> {
            drawPath(Path().apply { moveTo(6f * u, 19f * u); lineTo(6f * u, 9f * u); quadraticBezierTo(11f * u, 2f * u, 16f * u, 9f * u); lineTo(16f * u, 19f * u) }, ink, style = st)
            line(3f, 19f, 19f, 19f); drawCircle(ink, 0.9f * u, p(13.5f, 13f))
        }
        G.BLOOD -> drawPath(Path().apply { moveTo(11f * u, 3f * u); cubicTo(13f * u, 8f * u, 17f * u, 11f * u, 17f * u, 14f * u)
            cubicTo(17f * u, 18f * u, 14f * u, 20f * u, 11f * u, 20f * u); cubicTo(8f * u, 20f * u, 5f * u, 18f * u, 5f * u, 14f * u)
            cubicTo(5f * u, 11f * u, 9f * u, 8f * u, 11f * u, 3f * u); close() }, ink, style = st)
        G.TEMPO -> { // Metronom
            drawPath(Path().apply { moveTo(5f * u, 19f * u); lineTo(17f * u, 19f * u); lineTo(13.5f * u, 3f * u); lineTo(8.5f * u, 3f * u); close() }, ink, style = st)
            line(11f, 16f, 16.5f, 6f); drawCircle(ink, 1.2f * u, p(14.6f, 9.5f)) }
        G.TEXT -> { line(4f, 6f, 18f, 6f); line(4f, 11f, 18f, 11f); line(4f, 16f, 11f, 16f)
            drawPath(Path().apply { moveTo(14f * u, 14f * u); lineTo(18f * u, 16.5f * u); lineTo(14f * u, 19f * u); close() }, ink) }
        G.MAP -> { drawCircle(ink, 6f * u, p(9f, 9f), style = st); line(13.5f, 13.5f, 19f, 19f); line(9f, 6.5f, 9f, 11.5f); line(6.5f, 9f, 11.5f, 9f) }
        G.CONTROLS -> { drawCircle(ink, 9f * u, p(11f, 11f), style = st); drawCircle(ink, 3.5f * u, p(13f, 9f)) }
        G.STICK -> { drawCircle(ink, 4f * u, p(11f, 11f), style = st); drawCircle(ink, 9f * u, p(11f, 11f), style = Stroke(1f * u, pathEffect = androidx.compose.ui.graphics.PathEffect.dashPathEffect(floatArrayOf(2f * u, 2f * u)))) }
        G.RUN -> { drawPath(Path().apply { moveTo(4f * u, 5f * u); lineTo(10f * u, 11f * u); lineTo(4f * u, 17f * u) }, ink, style = st)
            drawPath(Path().apply { moveTo(11f * u, 5f * u); lineTo(17f * u, 11f * u); lineTo(11f * u, 17f * u) }, ink, style = st) }
        G.HAND -> { line(4f, 11f, 17f, 11f); drawPath(Path().apply { moveTo(13f * u, 6.5f * u); lineTo(17.5f * u, 11f * u); lineTo(13f * u, 15.5f * u) }, ink, style = st); drawCircle(ink, 2f * u, p(17.5f, 11f)) }
        G.BUZZ -> { drawRoundRect(ink, p(8f, 3.5f), Size(6f * u, 15f * u), androidx.compose.ui.geometry.CornerRadius(1.2f * u), style = st)
            drawArc(ink, 120f, 120f, false, p(2.5f, 7f), Size(8f * u, 8f * u), style = st); drawArc(ink, -60f, 120f, false, p(11.5f, 7f), Size(8f * u, 8f * u), style = st) }
        G.ASK -> {}
        G.STEPS -> { // zwei Sohlen mit Absatz, versetzt
            drawOval(ink, p(4f, 8f), Size(5f * u, 7.5f * u)); drawOval(ink, p(4.6f, 16.3f), Size(3.8f * u, 3.6f * u))
            drawOval(ink, p(12.5f, 2f), Size(5f * u, 7.5f * u)); drawOval(ink, p(13.1f, 10.3f), Size(3.8f * u, 3.6f * u)) }
    }
    if (!on) line(3f, 20f, 19f, 2f)
}

@Composable
private fun SignRow(content: @Composable () -> Unit) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.Top) { content() }
}

@Composable
private fun Explain(key: String, title: String, text: String) {
    if (Draft326.explain != key) return
    Column(Modifier.fillMaxWidth().padding(horizontal = 6.dp).background(Veil.raised).border(1.dp, Veil.gold).padding(horizontal = 12.dp, vertical = 9.dp)) {
        DraftHead(title)
        Spacer(Modifier.height(4.dp))
        Text(text, color = Veil.text, style = TextStyle(fontFamily = Serif, fontSize = 14.sp * TypeLook.scale, lineHeight = 19.sp))
    }
}

/** 326: der Systemreiter als Zeichen in vier Gruppen; die Regler bleiben. */
@Composable
fun SystemTab326(vm: GameViewModel, game: Game, lang: Lang) {
    vm.tick
    val de = lang == Lang.DE
    Spacer(Modifier.height(6.dp))
    Text("Version ${BuildConfig.VERSION_NAME} (Build ${BuildConfig.VERSION_CODE})", color = Veil.dim,
        style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, fontFeatureSettings = "lnum"))
    Spacer(Modifier.height(10.dp))
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        DraftHead(if (de) "Spiel" else "Game")
        SignRow {
            Sign("save", if (de) "Speichern" else "Save", null, glyph = G.SAVE)
            Sign("lang", if (de) "Sprache" else "Language", null, letter = if (de) "DE" else "EN")
            Sign("rules", if (de) "Regeln" else "Rules", null, glyph = G.RULES)
            Sign("menu", if (de) "Hauptmenü" else "Main menu", null, glyph = G.MENU)
        }
        Spacer(Modifier.height(4.dp))
        DraftHead(if (de) "Kampf" else "Fight")
        SignRow {
            val blood = if (de) listOf("Aus", "Dezent", "Deutlich") else listOf("Off", "Subtle", "Strong")
            val tempo = if (de) listOf("Ruhig", "Normal", "Schnell") else listOf("Calm", "Normal", "Fast")
            Sign("blood", if (de) "Blut" else "Blood", blood[vm.bloodLevel], on = vm.bloodLevel > 0, glyph = G.BLOOD)
            Sign("tempo", if (de) "Tempo" else "Pace", tempo[vm.battleTempo], glyph = G.TEMPO)
            Sign("text", if (de) "Kampftext" else "Battle text", if (vm.battleAuto) (if (de) "Von selbst" else "By itself") else (if (de) "Antippen" else "Tap"), glyph = G.TEXT)
            Sign("ask", if (de) "Rückfragen" else "Confirm", if (vm.confirmations) (if (de) "An" else "On") else (if (de) "Aus" else "Off"), on = vm.confirmations, letter = "?")
        }
        Explain("tempo", if (de) "Kampftempo" else "Battle pace", if (de) "Wie schnell Züge und Zeilen im Kampf ablaufen. Antippen wechselt: Ruhig, Normal, Schnell."
            else "How fast moves and lines run in a fight. Tap to change: calm, normal, fast.")
        Spacer(Modifier.height(4.dp))
        DraftHead(if (de) "Steuerung" else "Controls")
        SignRow {
            Sign("controls", if (de) "Steuerung" else "Controls", if (vm.touchControls) (if (de) "Wischen" else "Swipe") else (if (de) "Klassisch" else "Classic"), glyph = G.CONTROLS)
            val feel = if (de) listOf("Fein", "Normal", "Ruhig") else listOf("Fine", "Normal", "Calm")
            Sign("stick", "Joystick", feel[vm.stickFeel], glyph = G.STICK)
            Sign("run", if (de) "Rennen" else "Run", if (vm.runButton) (if (de) "Taste" else "Button") else (if (de) "Ring" else "Ring"), glyph = G.RUN)
            Sign("hand", if (de) "Aktion" else "Action", if (vm.leftHanded) (if (de) "Links" else "Left") else (if (de) "Rechts" else "Right"), glyph = G.HAND)
        }
        SignRow {
            Sign("map", if (de) "Karte" else "Map", if (vm.mapNear) (if (de) "Näher" else "Nearer") else "Normal", glyph = G.MAP)
            Sign("buzz", if (de) "Rütteln" else "Haptics", if (vm.haptics) (if (de) "An" else "On") else (if (de) "Aus" else "Off"), on = vm.haptics, glyph = G.BUZZ)
            Sign("steps", if (de) "Schritte" else "Steps", if (vm.stepsOn) (if (de) "An" else "On") else (if (de) "Aus" else "Off"), on = vm.stepsOn, glyph = G.STEPS)
            Sign("about", if (de) "Über" else "About", null, glyph = G.ABOUT)
        }
        Spacer(Modifier.height(4.dp))
        SoundAndLight(vm, lang)
    }
    Spacer(Modifier.height(16.dp))
    val s = game.state
    Text((if (de) "Schritte: " else "Steps: ") + s.steps + (if (de) " · Siege: " else " · Victories: ") + s.battlesWon, color = Veil.dim,
        style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, fontFeatureSettings = "lnum"))
}

/** 326: der Aktionsknopf wie die Zeichen des Hauptmenüs: schwarz, dünner Goldrand, das Bild bleibt. */
@Composable
fun ActionButton326(icon: de.bornim.core.art.PixelImage, size: androidx.compose.ui.unit.Dp, modifier: Modifier, dim: Boolean) {
    Box(modifier.size(size).clip(CircleShape).background(Color.Black.copy(alpha = 0.62f))
        .border(1.5.dp, if (dim) Veil.dim.copy(alpha = 0.5f) else Veil.gold, CircleShape), contentAlignment = Alignment.Center) {
        PixelImageView(icon, size * 0.55f, alpha = if (dim) 0.35f else 1f)
    }
}
