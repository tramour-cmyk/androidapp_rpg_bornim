package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
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
    val veil = LocalVeil.current
    Column(
        Modifier
            .fillMaxSize()
            .background(if (veil) Brush.verticalGradient(listOf(Color.Black, Color(0xFF0E0C09), Color.Black))
                else Brush.verticalGradient(listOf(Colors.night, Colors.nightLight, Colors.night)))
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Column(Modifier.alpha(nameShows), horizontalAlignment = Alignment.CenterHorizontally) {
            if (veil) {
                // capitals and small capitals: the serif's own small capitals where it has them, Cinzel and Alegreya SC are made so
                Text(Ui.title(lang), color = Veil.bright, textAlign = TextAlign.Center, style = TextStyle(fontFamily = TypeLook.titleFace,
                    fontSize = 36.sp, lineHeight = 42.sp, letterSpacing = 2.sp, fontWeight = FontWeight.SemiBold, fontFeatureSettings = "smcp"))
                Spacer(Modifier.height(10.dp))
                Box(Modifier.width(140.dp).height(1.dp).background(Veil.rim))
                Spacer(Modifier.height(10.dp))
                Text(Ui.subtitle(lang), color = Veil.dim, textAlign = TextAlign.Center,
                    style = TextStyle(fontFamily = Serif, fontSize = 15.sp * TypeLook.scale, letterSpacing = 0.6.sp)) // D2.7: upright, italics read badly
            } else {
                Txt(Ui.title(lang), size = 34.sp, color = Colors.gold, bold = true, align = TextAlign.Center)
                Spacer(Modifier.height(6.dp))
                Txt(Ui.subtitle(lang), size = 18.sp, color = Colors.textLight, align = TextAlign.Center)
            }
        }
        Column(Modifier.alpha(restShows), horizontalAlignment = Alignment.CenterHorizontally) {
            Spacer(Modifier.height(14.dp))
            Row {
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
            val w = Modifier.width(260.dp)
            vm.slotsVersion
            vm.lastSave?.let { last ->
                // Continue with the hero played last, named so it is clear which one.
                PixelButton(Ui.continueGame(lang) + ": " + last.name + " · " + Ui.level(lang) + " " + last.level, w, size = 15.sp) { vm.continueGame(last.slot) }
                Spacer(Modifier.height(12.dp))
                PixelButton(if (lang == de.bornim.core.Lang.DE) "Spielstände" else "Saved games", w) { vm.screen = Screen.SLOTS }
                Spacer(Modifier.height(12.dp))
            }
            PixelButton(Ui.newGame(lang), w) {
                vm.pendingSlot = null
                vm.screen = Screen.CREATE
            }
            Spacer(Modifier.height(12.dp))
            PixelButton(Ui.language(lang), w) { vm.toggleLang() }
            Spacer(Modifier.height(12.dp))
            Row(w, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton((if (vm.musicOn) Ui.musicOn else Ui.musicOff)(lang), Modifier.weight(1f), size = 14.sp) { vm.toggleMusic() }
                PixelButton((if (vm.sfxOn) Ui.sfxOn else Ui.sfxOff)(lang), Modifier.weight(1f), size = 14.sp) { vm.toggleSfx() }
            }
            Spacer(Modifier.height(12.dp))
            PixelButton(Ui.about(lang), w) { vm.screen = Screen.ABOUT }
            Spacer(Modifier.height(30.dp))
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
                Txt("${Ui.year} · v${de.bornim.game.BuildConfig.VERSION_NAME} · SRD 5.1 · CC BY 4.0", size = 12.sp, color = Colors.textDim)
            }
            if (vm.testMode) Txt(if (lang == Lang.DE) "Testmodus aktiv" else "Test mode on", size = 12.sp, color = Colors.accent)
        }
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
                Txt(Ui.title(vm.lang), size = 24.sp, bold = true)
                Txt(Ui.copyright, size = 15.sp, color = Colors.textDim)
                Spacer(Modifier.height(10.dp))
                Txt(Ui.aboutText(vm.lang), size = 16.sp)
                Spacer(Modifier.height(10.dp))
                Txt("Fonts: Jersey 10, Alegreya, Cinzel, EB Garamond, IM Fell English – SIL Open Font License 1.1", size = 14.sp, color = Colors.textDim)
            }
        }
        Spacer(Modifier.height(12.dp))
        PixelButton(Ui.back(vm.lang), Modifier.fillMaxWidth()) { vm.screen = Screen.MENU }
    }
}
