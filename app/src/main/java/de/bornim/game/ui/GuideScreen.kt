package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.CharClass
import de.bornim.core.Guide
import de.bornim.core.Ui
import de.bornim.game.GameViewModel

/** 352: the guide from the system menu, a page that scrolls, black and gold like the MARS page (Homer's text). */
@Composable
fun GuideScreen(vm: GameViewModel) {
    CompositionLocalProvider(LocalVeil provides true) { GuideBody(vm) }
}

@Composable
private fun GuideBody(vm: GameViewModel) {
    val lang = vm.lang
    BackHandler { vm.guide = false }
    val cls = vm.game?.state?.hero?.cls ?: CharClass.FIGHTER
    Column(Modifier.fillMaxSize().background(Color.Black).padding(16.dp)) {
        Panel(Modifier.weight(1f).fillMaxWidth()) {
            Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                VeilHead(Guide.title(lang))
                for (part in Guide.partsFor(cls)) Column {
                    var pieces = Guide.pieces(part(lang))
                    // the bold opening is the paragraph's heading, as on the MARS page
                    if (pieces.firstOrNull()?.second == true) {
                        Txt(pieces.first().first.trim(), size = 16.sp, color = Veil.gold, bold = true)
                        pieces = pieces.drop(1)
                    }
                    Text(
                        buildAnnotatedString {
                            pieces.forEachIndexed { i, (s, bold) ->
                                val t = if (i == 0) s.trimStart() else s
                                if (bold) withStyle(SpanStyle(fontWeight = FontWeight.SemiBold, color = Veil.gold)) { append(t) } else append(t)
                            }
                        },
                        style = TextStyle(fontFamily = Serif, fontFeatureSettings = "lnum", fontSize = 15.sp * 0.95f * TypeLook.scale,
                            lineHeight = 15.sp * 1.35f, letterSpacing = 0.2.sp, color = Veil.of(Colors.text)),
                    )
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        PixelButton(Ui.back(lang), Modifier.fillMaxWidth()) { vm.guide = false }
    }
}
