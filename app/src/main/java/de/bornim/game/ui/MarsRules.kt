package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.CharClass
import de.bornim.core.Lang
import de.bornim.core.Skirmish.Companion.ProbeFoe
import de.bornim.core.T
import de.bornim.core.Ui
import de.bornim.game.GameViewModel

/** 201: the MARS trial fight from the system menu, for testers without the test tab; Homer's text (201T). */
object MarsRules {
    val title = T("MARS – Probekampf", "MARS – Trial fight")
    val start = T("Zum Kampf", "To battle")

    /** The paragraphs of the page: a bold heading (or none) and the text after it. */
    val paragraphs = listOf(
        null to T(
            "Ein neues Kampfsystem, noch im Bau. Dein Held und ein Söldner kämpfen gegen eine kleine Gruppe, beide auf Stufe 3. Dein Held und deine Tasche bleiben, wie sie sind: hier geht nichts verloren und nichts wird gewonnen.",
            "A new combat system, still being built. Your hero and a Söldner fight a small group, both at level 3. Your hero and your bag stay as they are: nothing is lost here, and nothing is won.",
        ),
        T("Zwei Reihen.", "Two rows.") to T(
            "Jede Seite steht in zwei Reihen. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht; Fernkampf und Zauber erreichen jeden. Wer hinten steht, ist gedeckt, solange vorn ein Freund steht: Angriffe auf ihn haben Nachteil. Wer von vorn mit Bogen oder Armbrust auf die vordere Reihe schießt, hat ebenfalls Nachteil.",
            "Each side stands in two rows. Melee reaches only the front row while anyone stands there; ranged attacks and spells reach everyone. Whoever stands at the back is covered while a friend stands in front: attacks on them have disadvantage. Shooting a bow or crossbow from the front row at the front row has disadvantage too.",
        ),
        T("Der Gegner sagt an.", "The foe announces.") to T(
            "Jeder Gegner kündigt seinen nächsten Zug an: was er vorhat, gegen wen, und ein Zeichen, woran du es erkennst. Rot heißt: das wird wehtun. Ein harter Treffer vor seinem Zug vereitelt manche Absicht. Andere verlangen eine andere Antwort: den Platz wechseln, abwarten, schnell zuschlagen. Lies die Zeichen.",
            "Every foe announces its next move: what it intends, against whom, and a sign to recognise it by. Red means: this will hurt. A hard hit before its turn foils some intents. Others ask for a different answer: change places, wait, strike fast. Read the signs.",
        ),
        T("Der Ring.", "The ring.") to T(
            "Trifft eine angekündigte Absicht deine Figur, zieht sich ein Ring um sie zusammen. Tippe, wenn er sich schließt. Gut: halber Schaden. Perfekt: ganz ausgewichen. Kleine Schläge ohne Ansage kommen ohne Ring.",
            "When an announced intent strikes one of your figures, a ring closes around it. Tap as it closes. Good: half damage. Perfect: no damage at all. Small blows without an announcement come without a ring.",
        ),
        T("Dein Zug.", "Your turn.") to T(
            "Angriff mit der Waffe. Können: Zauber und Fähigkeiten; Heilung erreicht jeden Freund. Tasche: Heiltränke aus einem gemeinsamen Vorrat, für dich oder einen Freund. Platz: mit einem Freund tauschen oder auf einen freien Platz gehen. Abwarten. Die Leiste oben zeigt, wer als Nächstes dran ist. Jeder Wurf zeigt kurz am Ziel seine Zahlen.",
            "Attack with your weapon. Skills: spells and abilities; healing reaches any friend. Bag: healing potions from a shared stock, for you or a friend. Place: swap with a friend or move to a free place. Wait. The bar at the top shows who acts next. Every roll briefly shows its numbers at the target.",
        ),
        // (72.10a.8) the half turn; the weapon switch (.11), Cover and the perfect ring by class (.9) come with their builds
        null to T(
            "Ein Platztausch kostet nur einen halben Zug, danach bleibt noch ein Schlag.",
            "A swap costs only half a turn; one blow remains after it.",
        ),
        T("Automatik.", "Autopilot.") to T(
            "Der Söldner kämpft auf Wunsch selbst, sonst steuerst du ihn. Die Automatik spielt auch deinen Helden: Waffe, Zaubertricks, Heilung, wenn ein Freund schwach ist; den Ring trifft sie immer gut, nie perfekt. Sie hält an, wenn dein Held unter ein Drittel seiner Lebenspunkte fällt oder ein Gegner etwas Starkes ansagt, und gegen Bosse läuft sie nie.",
            "The Söldner can fight on their own, or you steer them. The autopilot can play your hero too: weapon, cantrips, healing when a friend is weak; it always meets the ring with good, never perfect. It stops when your hero drops below a third of their life points or a foe announces something strong, and it never runs against bosses.",
        ),
        T("Wer fällt.", "Who falls.") to T(
            "Ein Söldner, der fällt, ist bewusstlos, nicht tot. Wer außer Atem in den Kampf geht, würfelt die Reihenfolge mit Nachteil.",
            "A Söldner who falls is unconscious, not dead. Whoever enters the fight out of breath rolls for the order with disadvantage.",
        ),
        null to T(
            "Grak, Wölfe, Spinne, Späher: jeder Gegner verlangt eine andere Antwort. Sag uns, was sich gut anfühlt und was nicht.",
            "Grak, wolves, spider, scout: each foe asks for a different answer. Tell us what feels good and what doesn't.",
        ),
    )
}

/** The foes of a trial fight, as the test tab names them. */
internal fun probeFoeName(foe: ProbeFoe, lang: Lang): String {
    fun t(de: String, en: String) = if (lang == Lang.DE) de else en
    return when (foe) {
        ProbeFoe.GRAK -> "Grak"
        ProbeFoe.WOLVES -> t("drei Wölfe", "three wolves")
        ProbeFoe.SPIDER -> t("Riesenspinne und Wolf", "giant spider and wolf")
        ProbeFoe.SCOUT -> t("Goblin-Späher und Goblin", "goblin scout and goblin")
    }
}

/** 201: the rules on a page that scrolls, then the foes and the Söldner's class, and into the fight. */
@Composable
fun MarsRulesScreen(vm: GameViewModel) {
    val lang = vm.lang
    fun t(de: String, en: String) = if (lang == Lang.DE) de else en
    BackHandler { vm.marsRules = false }
    Column(Modifier.fillMaxSize().padding(16.dp)) {
        Panel(Modifier.weight(1f).fillMaxWidth()) {
            Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Txt(MarsRules.title(lang), size = 22.sp, bold = true)
                for ((head, body) in MarsRules.paragraphs) Column {
                    head?.let { Txt(it(lang), size = 16.sp, bold = true) }
                    Txt(body(lang), size = 15.sp)
                }
                Spacer(Modifier.height(4.dp))
                Txt(t("MARS: Held und Söldner gegen ", "MARS: hero and Söldner against ") + probeFoeName(vm.probeFoe, lang), size = 14.sp, bold = true)
                PixelButton(t("Gegner wechseln  ›", "Change foes  ›"), Modifier.fillMaxWidth(), size = 14.sp) {
                    val all = ProbeFoe.entries
                    vm.probeFoe = all[(vm.probeFoe.ordinal + 1) % all.size]
                }
                Txt("Söldner", size = 14.sp, bold = true)
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    for (c in CharClass.entries) PixelButton(c.title(lang), Modifier.weight(1f), selected = vm.probeClass == c, size = 12.sp) {
                        vm.probeClass = c
                    }
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PixelButton(Ui.back(lang), Modifier.weight(1f)) { vm.marsRules = false }
            PixelButton(MarsRules.start(lang), Modifier.weight(1f)) {
                vm.marsRules = false
                vm.startProbe(vm.probeClass)
            }
        }
    }
}
