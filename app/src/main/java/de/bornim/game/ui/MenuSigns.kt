package de.bornim.game.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import de.bornim.core.Guide
import de.bornim.core.Lang
import de.bornim.core.T
import de.bornim.core.Ui
import de.bornim.game.BuildConfig
import de.bornim.game.GameViewModel
import de.bornim.game.Screen

/**
 * 326 (Chef 23.10., 09:05 „ja, jetzt“; Entwurf Homer): the player's menu in the look of the main menu. The system tab
 * as signs in four groups instead of fifteen wide buttons: a tap goes on to the next setting, a long press explains it
 * in a window laid over the menu, so nothing below moves.
 */
object MenuExplain {
    /** The heading and the sentence of the window; null: closed. */
    var shown by mutableStateOf<Pair<String, String?>?>(null)
    /** The previews: the sign whose explanation is open from the start. */
    var preview: String? = null
}

private enum class G { SAVE, ABOUT, RULES, MENU, BLOOD, TEMPO, TEXT, MAP, CONTROLS, STICK, HAND, BUZZ, STEPS }

/** 326: a heading on black, gold spaced capitals as the title of the main menu, smaller. */
@Composable
fun MenuHead(text: String, modifier: Modifier = Modifier) {
    Text(text.uppercase(), modifier, color = Veil.gold, style = TextStyle(fontFamily = Serif, fontSize = 14.sp * TypeLook.scale, letterSpacing = 3.sp))
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun Sign(name: String, value: String?, explain: String?, on: Boolean = true, letter: String? = null, glyph: G? = null, run: Boolean = false, onClick: () -> Unit) {
    val click = LocalClick.current
    val source = remember { MutableInteractionSource() }
    if (MenuExplain.preview == name) androidx.compose.runtime.LaunchedEffect(Unit) { MenuExplain.shown = name to explain }
    val open = MenuExplain.shown?.first == name
    Column(
        Modifier.width(80.dp).combinedClickable(source, null, onLongClick = { MenuExplain.shown = name to explain }) { click(); onClick() },
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // 326 (Homer 10:18): gold as the given signs, the chosen one bright; „off“ is the gold dimmed, not grey, so it reads
        // „not now“ rather than „locked“
        Box(Modifier.size(48.dp).clip(CircleShape).border(if (open) 1.5.dp else 1.dp, if (open) Veil.bright else if (on) Veil.gold else Veil.rim, CircleShape),
            contentAlignment = Alignment.Center) {
            val ink = if (open) Veil.bright else if (on) Veil.gold else Veil.gold.copy(alpha = 0.45f)
            if (letter != null) Text(letter, color = ink, style = TextStyle(fontFamily = Serif, fontSize = (if (letter.length == 1) 22 else 15).sp * TypeLook.scale, letterSpacing = 1.sp))
            else if (glyph != null) Canvas(Modifier.size(24.dp)) { drawGlyph(glyph, ink, on) }
            // the same boot as the run button on the map, not a sign of its own
            else if (run) Canvas(Modifier.size(24.dp)) { actionGlyph(ActionSign.RUN, ink) }
        }
        Spacer(Modifier.height(4.dp))
        // 326 (Homer 10:18): the name in mixed case at full size, capitals only for headings; it fits the width as it is
        Text(name, color = Veil.text, textAlign = TextAlign.Center, maxLines = 1, softWrap = false,
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
        G.SAVE -> { // a book with a bookmark
            drawRect(ink, p(5f, 3f), Size(12f * u, 16f * u), style = st)
            line(8f, 3f, 8f, 19f)
            drawPath(Path().apply { moveTo(12f * u, 3f * u); lineTo(12f * u, 9f * u); lineTo(13.5f * u, 7.5f * u); lineTo(15f * u, 9f * u); lineTo(15f * u, 3f * u) }, ink, style = st)
        }
        G.ABOUT -> { drawCircle(ink, 9f * u, p(11f, 11f), style = st); drawCircle(ink, 1.1f * u, p(11f, 7f)); line(11f, 10f, 11f, 15.5f) }
        G.RULES -> { // an open book
            drawPath(Path().apply { moveTo(11f * u, 6f * u); quadraticBezierTo(7f * u, 3.5f * u, 2.5f * u, 5f * u); lineTo(2.5f * u, 18f * u); quadraticBezierTo(7f * u, 16.5f * u, 11f * u, 19f * u)
                quadraticBezierTo(15f * u, 16.5f * u, 19.5f * u, 18f * u); lineTo(19.5f * u, 5f * u); quadraticBezierTo(15f * u, 3.5f * u, 11f * u, 6f * u); lineTo(11f * u, 19f * u) }, ink, style = st)
            line(5f, 9f, 8.5f, 9.5f); line(5f, 12.5f, 8.5f, 13f); line(13.5f, 9.5f, 17f, 9f); line(13.5f, 13f, 17f, 12.5f) }
        G.MENU -> { // a tower with three merlons (Homer 10:18: not a gate, that is „enter“); the battlement juts out and the
            // notches are deep, or at 24 dp they close up (helper 10:28: read as a post)
            val k = 22f / 24f
            drawPath(Path().apply {
                fun to(x: Float, y: Float) = lineTo(x * k * u, y * k * u)
                moveTo(8.5f * k * u, 21f * k * u); to(8.5f, 10f); to(6f, 8f); to(6f, 2.5f); to(8.8f, 2.5f); to(8.8f, 6f); to(10.6f, 6f); to(10.6f, 2.5f)
                to(13.4f, 2.5f); to(13.4f, 6f); to(15.2f, 6f); to(15.2f, 2.5f); to(18f, 2.5f); to(18f, 8f); to(15.5f, 10f); to(15.5f, 21f)
            }, ink, style = st)
            line(4f * k, 21f * k, 20f * k, 21f * k)
        }
        G.BLOOD -> drawPath(Path().apply { moveTo(11f * u, 3f * u); cubicTo(13f * u, 8f * u, 17f * u, 11f * u, 17f * u, 14f * u)
            cubicTo(17f * u, 18f * u, 14f * u, 20f * u, 11f * u, 20f * u); cubicTo(8f * u, 20f * u, 5f * u, 18f * u, 5f * u, 14f * u)
            cubicTo(5f * u, 11f * u, 9f * u, 8f * u, 11f * u, 3f * u); close() }, ink, style = st)
        G.TEMPO -> { // a metronome
            drawPath(Path().apply { moveTo(5f * u, 19f * u); lineTo(17f * u, 19f * u); lineTo(13.5f * u, 3f * u); lineTo(8.5f * u, 3f * u); close() }, ink, style = st)
            line(11f, 16f, 16.5f, 6f); drawCircle(ink, 1.2f * u, p(14.6f, 9.5f)) }
        G.TEXT -> { line(4f, 6f, 18f, 6f); line(4f, 11f, 18f, 11f); line(4f, 16f, 11f, 16f)
            drawPath(Path().apply { moveTo(14f * u, 14f * u); lineTo(18f * u, 16.5f * u); lineTo(14f * u, 19f * u); close() }, ink) }
        G.MAP -> { drawCircle(ink, 6f * u, p(9f, 9f), style = st); line(13.5f, 13.5f, 19f, 19f); line(9f, 6.5f, 9f, 11.5f); line(6.5f, 9f, 11.5f, 9f) }
        G.CONTROLS -> { drawCircle(ink, 9f * u, p(11f, 11f), style = st); drawCircle(ink, 3.5f * u, p(13f, 9f)) }
        G.STICK -> { drawCircle(ink, 4f * u, p(11f, 11f), style = st); drawCircle(ink, 9f * u, p(11f, 11f), style = Stroke(1f * u, pathEffect = androidx.compose.ui.graphics.PathEffect.dashPathEffect(floatArrayOf(2f * u, 2f * u)))) }
        G.HAND -> { line(4f, 11f, 17f, 11f); drawPath(Path().apply { moveTo(13f * u, 6.5f * u); lineTo(17.5f * u, 11f * u); lineTo(13f * u, 15.5f * u) }, ink, style = st); drawCircle(ink, 2f * u, p(17.5f, 11f)) }
        G.BUZZ -> { drawRoundRect(ink, p(8f, 3.5f), Size(6f * u, 15f * u), androidx.compose.ui.geometry.CornerRadius(1.2f * u), style = st)
            drawArc(ink, 120f, 120f, false, p(2.5f, 7f), Size(8f * u, 8f * u), style = st); drawArc(ink, -60f, 120f, false, p(11.5f, 7f), Size(8f * u, 8f * u), style = st) }
        G.STEPS -> { // two soles with heels, staggered
            drawOval(ink, p(4f, 8f), Size(5f * u, 7.5f * u)); drawOval(ink, p(4.6f, 16.3f), Size(3.8f * u, 3.6f * u))
            drawOval(ink, p(12.5f, 2f), Size(5f * u, 7.5f * u)); drawOval(ink, p(13.1f, 10.3f), Size(3.8f * u, 3.6f * u)) }
    }
    if (!on) line(3f, 20f, 19f, 2f)
}

@Composable
private fun SignRow(content: @Composable () -> Unit) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.Top) { content() }
}

/** The window of a long press, laid over the lower part of the menu; a tap closes it. */
@Composable
fun MenuExplainWindow(modifier: Modifier = Modifier) {
    val (title, text) = MenuExplain.shown ?: return
    Column(modifier.fillMaxWidth()) {
    // a shadow above, so the window does not seem to cut through the lines behind it
    Box(Modifier.fillMaxWidth().height(28.dp).background(androidx.compose.ui.graphics.Brush.verticalGradient(0f to Color.Transparent, 0.6f to Color.Black)))
    Column(Modifier.fillMaxWidth().background(Color.Black).padding(start = 6.dp, end = 6.dp, bottom = 6.dp).background(Veil.raised).border(1.dp, Veil.gold)
        .tap { MenuExplain.shown = null }.padding(horizontal = 12.dp, vertical = 9.dp)) {
        MenuHead(title)
        if (text != null) {
            Spacer(Modifier.height(4.dp))
            Text(text, color = Veil.text, style = TextStyle(fontFamily = Serif, fontSize = 14.sp * TypeLook.scale, lineHeight = 19.sp))
        }
    }
    }
}

/** 326: the system tab as signs in four groups; the sliders for sound and light stay. Sentences: STORY-MENUE.md [326.sys.…]. */
@Composable
fun SystemSigns(vm: GameViewModel, game: Game, lang: Lang) {
    vm.tick
    val de = lang == Lang.DE
    fun t(x: T) = x(lang)
    Spacer(Modifier.height(6.dp))
    Text("Version ${BuildConfig.VERSION_NAME} (Build ${BuildConfig.VERSION_CODE})", color = Veil.dim,
        style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, fontFeatureSettings = "lnum"))
    Spacer(Modifier.height(10.dp))
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        MenuHead(if (de) "Spiel" else "Game")
        SignRow {
            Sign(if (de) "Speichern" else "Save", null, if (de) "Hält deinen Stand jetzt fest. Beim Verlassen des Spiels und auf dem Weg ins Hauptmenü speichert es ohnehin."
                else "Saves your progress now. The game also saves when you leave it or go to the main menu.", glyph = G.SAVE) { vm.save(); vm.toast = Ui.saved(lang) }
            Sign(if (de) "Sprache" else "Language", null, if (de) "Wechselt zwischen Deutsch und Englisch." else "Switches between German and English.", letter = if (de) "DE" else "EN") { vm.toggleLang() }
            Sign(if (de) "Hauptmenü" else "Main menu", null, if (de) "Speichert und kehrt zum Hauptmenü zurück." else "Saves and returns to the main menu.", glyph = G.MENU) { vm.toMenu() }
        }
        // 352: five signs and „Über“ do not fit in one row of four: what to read in a row of its own
        SignRow {
            // 352: the guide to the game; the MARS trial fight a sign of its own (Homer, [352.zeichen])
            Sign(t(Guide.sign), null, t(Guide.signHint), glyph = G.RULES) { vm.menuOpen = false; vm.guide = true }
            Sign(t(Guide.marsSign), null, t(Guide.marsHint), letter = "M") { vm.menuOpen = false; vm.marsRules = true }
            Sign(if (de) "Über" else "About", null, if (de) "Wer das Spiel macht und worauf seine Regeln beruhen." else "Who makes the game and what its rules are based on.", glyph = G.ABOUT) { vm.toMenu(); vm.screen = Screen.ABOUT }
        }
        Spacer(Modifier.height(4.dp))
        MenuHead(if (de) "Kampf" else "Fight")
        SignRow {
            val blood = if (de) listOf("Aus", "Dezent", "Deutlich") else listOf("Off", "Subtle", "Strong")
            val tempo = if (de) listOf("Ruhig", "Normal", "Schnell") else listOf("Calm", "Normal", "Fast")
            val text = if (de) listOf("Antippen", "Von selbst") else listOf("Tap", "By itself")
            Sign(if (de) "Blut" else "Blood", blood[vm.bloodLevel],
                if (de) "Wie viel Blut Treffer zeigen. Antippen wechselt: Aus, Dezent, Deutlich." else "How much blood hits show. Tap to change: off, subtle, strong.", on = vm.bloodLevel > 0, glyph = G.BLOOD) { vm.changeBlood((vm.bloodLevel + 1) % 3) }
            Sign(if (de) "Tempo" else "Pace", tempo[vm.battleTempo],
                if (de) "Wie schnell Züge und Zeilen im Kampf ablaufen. Antippen wechselt: Ruhig, Normal, Schnell."
                else "How fast moves and lines run in a fight. Tap to change: calm, normal, fast.", glyph = G.TEMPO) { vm.changeTempo((vm.battleTempo + 1) % 3) }
            Sign(if (de) "Kampftext" else "Battle text", text[if (vm.battleAuto) 1 else 0],
                if (de) "Ob die Zeilen im Kampf auf dein Antippen warten oder nach einer Lesepause von selbst weiterlaufen."
                else "Whether the lines in a fight wait for your tap or run on by themselves after a pause to read.", glyph = G.TEXT) { vm.toggleBattleAuto() }
            Sign(if (de) "Rückfragen" else "Confirm", if (vm.confirmations) (if (de) "An" else "On") else (if (de) "Aus" else "Off"), t(Ui.confirmHint),
                on = vm.confirmations, letter = "?") { vm.toggleConfirmations() }
        }
        Spacer(Modifier.height(4.dp))
        // „Bedienung“, so „Steuerung“ is not twice (Homer, [326.abschnitt.bedienung])
        MenuHead(if (de) "Bedienung" else "Handling")
        SignRow {
            val feel = if (de) listOf("Fein", "Normal", "Ruhig") else listOf("Fine", "Normal", "Calm")
            Sign(if (de) "Steuerung" else "Controls", if (vm.touchControls) (if (de) "Wischen" else "Swipe") else (if (de) "Klassisch" else "Classic"),
                if (de) "Wischen: Finger ziehen zum Laufen, weit ziehen zum Rennen, tippen zum Hinlaufen. Klassisch: Steuerkreuz und ein großer Knopf zum Handeln."
                else "Swipe: drag to walk, drag far to run, tap to walk there. Classic: a D-pad and a big button to act.", glyph = G.CONTROLS) { vm.toggleControls() }
            // 86.4, 131: the stick and the run button only with the swiping controls
            if (vm.touchControls) {
                Sign("Joystick", feel[vm.stickFeel], if (de) "Im Kreis geht man, über den Ring hinaus rennt man. Fein: kleiner Ring. Ruhig: großer Ring."
                    else "Inside the circle you walk, past the ring you run. Fine: a small ring. Calm: a large ring.", glyph = G.STICK) { vm.changeStickFeel((vm.stickFeel + 1) % 3) }
                Sign(if (de) "Rennen" else "Run", if (vm.runButton) (if (de) "Taste" else "Button") else (if (de) "Ring" else "Ring"),
                    if (de) "Wie du rennst. Ring: über den Ring des Joysticks hinausziehen. Taste: dazu ein eigener Knopf zum Rennen."
                    else "How you run. Ring: push past the joystick's ring. Button: adds a button of its own to run with.", run = true) { vm.toggleRunButton() }
            }
            Sign(if (de) "Aktion" else "Action", if (vm.leftHanded) (if (de) "Links" else "Left") else (if (de) "Rechts" else "Right"),
                if (de) "Auf welcher Seite der Aktionsknopf steht: rechts, oder links für Linkshänder." else "Which side the action button sits on: right, or left for left-handed players.", glyph = G.HAND) { vm.toggleLeftHanded() }
        }
        SignRow {
            Sign(if (de) "Karte" else "Map", if (vm.mapNear) (if (de) "Näher" else "Nearer") else "Normal",
                if (de) "Wie nah die Karte ist. Näher zeigt weniger Umgebung, dafür größer." else "How close the map is. Nearer shows less around you, but larger.", glyph = G.MAP) { vm.changeMapNear(!vm.mapNear) }
            Sign(if (de) "Rütteln" else "Haptics", if (vm.haptics) (if (de) "An" else "On") else (if (de) "Aus" else "Off"),
                if (de) "Das Handy zittert kurz, wenn vor dir etwas zu tun ist oder ein Weg nicht geht." else "The phone buzzes briefly when there is something to do ahead of you or a way is blocked.", on = vm.haptics, glyph = G.BUZZ) { vm.toggleHaptics() }
            Sign(if (de) "Schritte" else "Steps", if (vm.stepsOn) (if (de) "An" else "On") else (if (de) "Aus" else "Off"),
                if (de) "Die Schritte deines Helden hörbar oder still; alle anderen Geräusche bleiben." else "Your hero's footsteps audible or silent; all other sounds stay.", on = vm.stepsOn, glyph = G.STEPS) { vm.toggleSteps() }
        }
        Spacer(Modifier.height(4.dp))
        SoundAndLight(vm, lang)
    }
    Spacer(Modifier.height(16.dp))
    val s = game.state
    Text((if (de) "Schritte: " else "Steps: ") + s.steps + (if (de) " · Siege: " else " · Victories: ") + s.battlesWon, color = Veil.dim,
        style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, fontFeatureSettings = "lnum"))
    Box(Modifier.size(1.dp))
}
