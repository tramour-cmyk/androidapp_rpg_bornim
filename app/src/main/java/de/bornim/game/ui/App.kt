package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.LocalTextStyle
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.material3.Text
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.withFrameMillis
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.Lang
import de.bornim.core.Race
import de.bornim.core.Mode
import de.bornim.core.Ui
import de.bornim.core.Outcome
import de.bornim.core.Prelude
import de.bornim.core.audio.MusicLib
import de.bornim.core.audio.MusicScene
import de.bornim.core.audio.Sound
import de.bornim.core.art.CharacterArt
import de.bornim.game.GameViewModel
import de.bornim.game.Screen
import kotlinx.coroutines.delay

@Composable
fun BornimApp(vm: GameViewModel) {
    // Pick the music for what is on screen.
    vm.tick
    val fight = (vm.game?.mode as? Mode.Fight)?.takeIf { vm.screen == Screen.PLAYING }
    val musicScene = when {
        vm.screen != Screen.PLAYING || vm.game == null -> MusicScene.TITLE
        // 69f: the title music quietly under the intro's pictures, fuller with the black one
        vm.intro -> if (vm.introPicture >= de.bornim.core.Intro.black) MusicScene.TITLE else MusicScene.INTRO
        vm.game?.mode is Mode.ChapterEnd -> MusicScene.CHAPTER_END
        // 68: „Ancient Legend“ under the temple scene
        vm.templeAgain || vm.game?.mode is Mode.TempleScene -> MusicScene.TEMPLE
        // 72.10: the probe against Grak
        // 256: as in the old fight, the boss piece only against a boss
        vm.probe != null -> de.bornim.core.audio.MarsSound.music(vm.probe!!)
        fight == null -> MusicLib.sceneOf(vm.game!!.map.kind)
        fight.battle.monster.boss -> MusicScene.BOSS
        else -> MusicScene.BATTLE
    }
    LaunchedEffect(musicScene) { vm.music.play(musicScene) }
    // a won fight: the victory piece before the place's music (28.1)
    val won = fight?.battle?.outcome == Outcome.WON
    LaunchedEffect(won) { if (won) vm.music.victory() }
    // the pictures of the supplies and of what the hero carries, drawn ahead in the background so lists open at once
    val heroKey = vm.game?.hero
    LaunchedEffect(heroKey) {
        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
            de.bornim.core.Items.all.forEach { de.bornim.core.art.SupplyArt.get(it.id) }
            val g = vm.game ?: return@withContext
            (g.hero.gear.values + g.state.bag).forEach { de.bornim.core.art.ItemArt.get(it) }
        }
    }

    CompositionLocalProvider(LocalTextStyle provides BaseText, LocalClick provides { vm.play(Sound.CLICK, 0.35f) }) {
        Box(
            Modifier
                .fillMaxSize()
                .background(Colors.night)
                .safeDrawingPadding()
        ) {
            when (vm.screen) {
                Screen.MENU -> MainMenuScreen(vm)
                Screen.CREATE -> CreateScreen(vm)
                // 60k (test 0.1.650): the saved games and the about page in the title's look too
                Screen.ABOUT -> MenuVeil { AboutScreen(vm) }
                Screen.SLOTS -> MenuVeil { SlotsScreen(vm) }
                // 13e.6: the brightness lifts the black of the game's picture, menus included (the test sign is there)
                Screen.PLAYING -> Box(Modifier.fillMaxSize().liftBlack(de.bornim.core.audio.Mix.lift(vm.brightness))) {
                    when {
                        // 69c: the quiet sounds under the pictures go with them
                        vm.intro -> { IntroScreen(vm); IntroSounds(vm) }
                        vm.templeAgain || vm.game?.mode == Mode.TempleScene -> TempleSceneScreen(vm)
                        vm.probe != null -> SkirmishScreen(vm, vm.probe!!)
                        vm.marsRules -> MarsRulesScreen(vm)
                        else -> PlayScreen(vm)
                    }
                }
            }
            vm.toast?.let { msg ->
                LaunchedEffect(msg) {
                    delay(1800)
                    vm.toast = null
                }
                // 60k: the short notes (test mode on, …) black with the gold rim as well
                Box(Modifier.align(Alignment.TopCenter).padding(16.dp)) {
                    MenuVeil(fill = false) { Panel { Txt(msg, size = 16.sp) } }
                }
            }
        }
    }
}

/** Milliseconds since composition, for simple frame animations. */
@Composable
fun rememberTime(): Long {
    val t by produceState(0L) {
        val start = withFrameMillis { it }
        while (true) withFrameMillis { value = it - start }
    }
    return t
}

/** The look of the text box (60) for the pages round the main menu, on black. */
@Composable
private fun MenuVeil(fill: Boolean = true, content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalVeil provides true) {
        if (fill) Box(Modifier.fillMaxSize().background(Color.Black)) { content() } else content()
    }
}

@Composable
fun MainMenuScreen(vm: GameViewModel) {
    // 60.4: the main menu in the look of the text box: black, the title large in gold capitals, the buttons as in the shop
    CompositionLocalProvider(LocalVeil provides true) {
        if (!vm.prelude) MainMenuColumn(vm)
        else {
            // 292: the opening at a cold start: the firm, then the game's name, out of which the menu grows; a tap skips it
            val t = rememberTime()
            LaunchedEffect(t >= Prelude.end) { if (t >= Prelude.end) vm.prelude = false }
            Box(Modifier.fillMaxSize()) {
                MainMenuColumn(vm, Prelude.name(t), Prelude.menu(t))
                val firm = Prelude.firm(t)
                if (firm > 0f) Column(Modifier.fillMaxSize().alpha(firm), horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center) {
                    BornWireLogo(240.dp)
                    Spacer(Modifier.height(18.dp))
                    Text(Ui.presents(vm.lang), color = Veil.dim, style = TextStyle(fontFamily = Serif, fontSize = 15.sp * TypeLook.scale, letterSpacing = 1.2.sp))
                }
                // the menu below takes no taps until it is there
                Box(Modifier.fillMaxSize().tap { vm.prelude = false })
            }
        }
    }
}

/** [nameShows] and [restShows]: how far the title and the rest are faded in, during the opening (292). */
@Composable
private fun MainMenuColumn(vm: GameViewModel, nameShows: Float = 1f, restShows: Float = 1f) {
    val lang = vm.lang
    // t69: on a tall phone the menu ran past the bottom and cut the last line in half; now it is centred while it
    // fits and scrolls when it does not, with room below the last line
    BoxWithConstraints(Modifier.fillMaxSize().background(Color.Black)) {
    Column(
        Modifier
            .verticalScroll(rememberScrollState())
            .fillMaxWidth()
            .heightIn(min = maxHeight)
            .padding(horizontal = 24.dp, vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Column(Modifier.alpha(nameShows), horizontalAlignment = Alignment.CenterHorizontally) {
            // 292.3: the title in the serif of the black screens, spaced capitals, as everywhere else in the game
            Text(Ui.title(lang).uppercase(), color = Veil.bright, textAlign = TextAlign.Center, style = TextStyle(fontFamily = Serif,
                fontSize = 33.sp * TypeLook.scale, lineHeight = 44.sp, letterSpacing = 6.sp, fontWeight = FontWeight.Normal))
            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.width(80.dp).height(1.dp).background(Brush.horizontalGradient(listOf(Color.Transparent, Veil.rim))))
                Box(Modifier.padding(horizontal = 8.dp).size(7.dp).rotate(45f).border(1.dp, Veil.gold))
                Box(Modifier.width(80.dp).height(1.dp).background(Brush.horizontalGradient(listOf(Veil.rim, Color.Transparent))))
            }
            Spacer(Modifier.height(12.dp))
            Text(Ui.subtitle(lang).replace(": ", " · "), color = Veil.dim, textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = Serif, fontSize = 15.sp * TypeLook.scale, letterSpacing = 1.sp)) // D2.7: upright, italics read badly
        }
        Column(Modifier.alpha(restShows), horizontalAlignment = Alignment.CenterHorizontally) {
            Spacer(Modifier.height(18.dp))
            // 292.3 (Chef 15:10, draft A): the four in a warm cone of light from above, a glow on the ground at their feet
            Row(Modifier.drawBehind { lightCone() }) {
                // one of each class as the doll, in its starting gear, of different peoples and looks
                val races = listOf(Race.HUMAN, Race.ELF, Race.DWARF, Race.HALF_ORC)
                val heroes = remember {
                    CharClass.entries.mapIndexed { i, cls ->
                        de.bornim.core.Hero.create("Held $i", races[i % races.size], cls).also {
                            it.sex = if (i % 2 == 1) de.bornim.core.Sex.FEMALE else de.bornim.core.Sex.MALE
                            it.skin = (i * 3 + 1) % 4; it.hair = i % 4
                        }
                    }
                }
                // standing still at rest, each class with what it carries; 292.2: half as large again and twice as fine, drawn
                // during the opening; each picture wider than its place, the figures themselves are narrow
                heroes.forEachIndexed { i, h ->
                    Box(Modifier.width(76.dp), contentAlignment = Alignment.Center) {
                        HeroStill(h, "title/$i", 0.69.dp, Modifier.wrapContentWidth(unbounded = true), fine = 2)
                    }
                }
            }
            Spacer(Modifier.height(22.dp))
            val w = Modifier.width(280.dp)
            vm.slotsVersion
            val last = vm.lastSave
            if (last != null) {
                // 292.3: the main way on, golden, with who, how far and where, so it is clear which hero goes on
                val place = runCatching { de.bornim.core.World[last.place].name(lang) }.getOrDefault(last.place)
                MainButton(if (lang == Lang.DE) "Weiter" else "Continue", last.name + " · " + Ui.level(lang) + " " + last.level + " · " + place, w) { vm.continueGame(last.slot) }
                Spacer(Modifier.height(12.dp))
            }
            Row(w, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                PixelButton(Ui.newGame(lang), Modifier.weight(1f), size = 18.sp) {
                    vm.pendingSlot = null
                    vm.screen = Screen.CREATE
                }
                if (last != null) PixelButton(if (lang == Lang.DE) "Spielstände" else "Saved games", Modifier.weight(1f), size = 18.sp) { vm.screen = Screen.SLOTS }
            }
            Spacer(Modifier.height(12.dp))
            PixelButton(Ui.about(lang), w, size = 18.sp) { vm.screen = Screen.ABOUT }
            Spacer(Modifier.height(18.dp))
            // language, music and sounds as three small signs instead of three large buttons
            Row(horizontalArrangement = Arrangement.spacedBy(22.dp)) {
                RoundSign(onClick = { vm.toggleLang() }) {
                    Text(if (lang == Lang.DE) "DE" else "EN", color = Veil.text, style = TextStyle(fontFamily = Serif, fontSize = 14.sp * TypeLook.scale, letterSpacing = 1.sp))
                }
                RoundSign(onClick = { vm.toggleMusic() }) { SignGlyph(Glyph.MUSIC, vm.musicOn) }
                RoundSign(onClick = { vm.toggleSfx() }) { SignGlyph(Glyph.SOUND, vm.sfxOn) }
            }
            Spacer(Modifier.height(22.dp))
            var secretTaps by remember { mutableIntStateOf(0) }
            // 292: the firm's logo instead of the copyright; tapping it or the line below 7 times switches the test mode
            Column(Modifier.tap {
                secretTaps++
                if (secretTaps >= 7) {
                    secretTaps = 0
                    vm.toggleTestMode()
                    vm.toast = if (vm.testMode) (if (lang == Lang.DE) "Testmodus aktiviert" else "Test mode enabled")
                    else (if (lang == Lang.DE) "Testmodus deaktiviert" else "Test mode disabled")
                }
            }, horizontalAlignment = Alignment.CenterHorizontally) {
                BornWireLogo(130.dp)
                Spacer(Modifier.height(6.dp))
                Text("v${de.bornim.game.BuildConfig.VERSION_NAME} · SRD 5.1 · CC BY 4.0", color = Veil.dim.copy(alpha = 0.75f),
                    style = TextStyle(fontFamily = Serif, fontSize = 12.sp * TypeLook.scale, letterSpacing = 0.5.sp, fontFeatureSettings = "lnum"))
            }
            if (vm.testMode) Txt(if (lang == Lang.DE) "Testmodus aktiv" else "Test mode on", size = 12.sp, color = Colors.accent)
            Spacer(Modifier.height(8.dp))
        }
    }
    }
}

/** 292.3: the main way on: gold rim, the word in spaced capitals, below it in small letters who goes on, and where. */
@Composable
private fun MainButton(label: String, line: String, modifier: Modifier, onClick: () -> Unit) {
    val click = LocalClick.current
    Column(
        modifier
            .background(Veil.raised)
            .border(1.5.dp, Veil.bright)
            .tap { click(); onClick() }
            .padding(vertical = 9.dp, horizontal = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(label.uppercase(), color = Veil.bright, style = TextStyle(fontFamily = Serif, fontSize = 17.sp * TypeLook.scale, letterSpacing = 3.sp))
        Spacer(Modifier.height(2.dp))
        Text(line, color = Veil.dim, maxLines = 1, style = TextStyle(fontFamily = Serif, fontSize = 13.sp * TypeLook.scale, letterSpacing = 0.8.sp, fontFeatureSettings = "lnum"))
    }
}

/** 292.3: a small round sign with a thin gold rim, for a setting. */
@Composable
private fun RoundSign(onClick: () -> Unit, content: @Composable () -> Unit) {
    val click = LocalClick.current
    Box(Modifier.size(46.dp).clip(CircleShape).border(1.dp, Veil.rim, CircleShape).tap { click(); onClick() },
        contentAlignment = Alignment.Center) { content() }
}

private enum class Glyph { MUSIC, SOUND }

/** A note or a loudspeaker drawn in thin gold lines; struck through when [on] is false. */
@Composable
private fun SignGlyph(g: Glyph, on: Boolean) {
    val ink = if (on) Veil.text else Veil.dim
    Canvas(Modifier.size(22.dp)) {
        val u = size.minDimension / 22f
        val st = Stroke(width = 1.5f * u, cap = StrokeCap.Round, join = StrokeJoin.Round)
        when (g) {
            Glyph.MUSIC -> {
                // two notes joined by a beam
                drawOval(ink, Offset(3f * u, 14.5f * u), Size(5.5f * u, 4.2f * u))
                drawOval(ink, Offset(12.5f * u, 12.5f * u), Size(5.5f * u, 4.2f * u))
                drawLine(ink, Offset(8.2f * u, 16.5f * u), Offset(8.2f * u, 4.5f * u), st.width, StrokeCap.Round)
                drawLine(ink, Offset(17.7f * u, 14.5f * u), Offset(17.7f * u, 2.5f * u), st.width, StrokeCap.Round)
                drawLine(ink, Offset(8.2f * u, 4.5f * u), Offset(17.7f * u, 2.5f * u), 2.2f * u, StrokeCap.Round)
            }
            Glyph.SOUND -> {
                val body = Path().apply {
                    moveTo(3f * u, 8.5f * u); lineTo(7f * u, 8.5f * u); lineTo(11.5f * u, 4.5f * u); lineTo(11.5f * u, 17.5f * u)
                    lineTo(7f * u, 13.5f * u); lineTo(3f * u, 13.5f * u); close()
                }
                drawPath(body, ink, style = st)
                if (on) {
                    drawArc(ink, -45f, 90f, false, Offset(9f * u, 7f * u), Size(8f * u, 8f * u), style = st)
                    drawArc(ink, -50f, 100f, false, Offset(7.5f * u, 3.5f * u), Size(13f * u, 15f * u), style = st)
                }
            }
        }
        if (!on) drawLine(ink, Offset(3f * u, 19f * u), Offset(19f * u, 3f * u), st.width, StrokeCap.Round)
    }
}

/** 292.3, draft A: a warm cone of light falling from above onto the heroes, and its glow on the ground at their feet. */
private fun androidx.compose.ui.graphics.drawscope.DrawScope.lightCone() {
    val w = size.width; val h = size.height
    val warm = Color(0xFFE8B070)
    // many thin cones one over the other, each a little wider: bright in the middle, the sides fading out softly;
    // each faded in from nothing at the top and out again at the feet, where the glow on the ground takes over
    val fade = Brush.verticalGradient(0f to warm.copy(alpha = 0f), 0.35f to warm.copy(alpha = 0.013f), 0.8f to warm.copy(alpha = 0.019f), 1f to warm.copy(alpha = 0f),
        startY = -h * 0.15f, endY = h * 0.98f)
    for (k in 0 until 24) {
        val top = 0.05f + k * 0.0045f; val foot = 0.2f + k * 0.017f
        val cone = Path().apply {
            moveTo(w * (0.5f - top), -h * 0.15f); lineTo(w * (0.5f + top), -h * 0.15f)
            lineTo(w * (0.5f + foot), h * 0.98f); lineTo(w * (0.5f - foot), h * 0.98f); close()
        }
        drawPath(cone, fade)
    }
    val gy = h * 0.95f
    // a circle of soft light squashed flat onto the ground, so its edge fades all round
    scale(1f, 0.18f, Offset(w / 2f, gy)) {
        drawCircle(Brush.radialGradient(listOf(warm.copy(alpha = 0.45f), warm.copy(alpha = 0.16f), Color.Transparent), center = Offset(w / 2f, gy), radius = w * 0.55f),
            radius = w * 0.55f, center = Offset(w / 2f, gy))
    }
}

@Composable
fun AboutScreen(vm: GameViewModel) {
    BackHandler { vm.screen = Screen.MENU }
    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                // 312: the heading spaced in capitals as on every page, the firm's logo instead of the old copyright
                VeilHead(Ui.title(vm.lang), color = Veil.bright)
                Spacer(Modifier.height(12.dp))
                Txt(Ui.aboutText(vm.lang), size = 16.sp)
                Spacer(Modifier.height(12.dp))
                // every face the game carries, each under the SIL Open Font License
                Txt((if (vm.lang == Lang.DE) "Schriften" else "Fonts") + ": Alegreya, Alegreya SC, Cinzel, EB Garamond, Fondamento, IM Fell English, Jersey 10 – SIL Open Font License 1.1",
                    size = 14.sp, color = Colors.textDim)
                Spacer(Modifier.height(18.dp))
                Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                    BornWireLogo(130.dp)
                    Spacer(Modifier.height(6.dp))
                    Txt("${Ui.year} · v${de.bornim.game.BuildConfig.VERSION_NAME} · SRD 5.1 · CC BY 4.0", size = 12.sp, color = Colors.textDim)
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        PixelButton(Ui.back(vm.lang), Modifier.fillMaxWidth()) { vm.screen = Screen.MENU }
    }
}
