package de.bornim.game.ui

import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.Skill
import de.bornim.core.T

/** 204: what a long press on a button of the MARS fight says (Homer's text, 204T). */
object MarsTips {
    /** 223T.angriff (replaces 204T.angriff): melee from the back row has disadvantage, reach not. */
    val attack = T("Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht, und hat von hinten Nachteil, außer mit Speer oder Hellebarde. Bogen und Armbrust haben Nachteil, wenn du vorn stehst und auf die vordere Reihe schießt.",
        "One blow or shot with your weapon. Melee reaches only the front row while anyone stands there, and from the back it has disadvantage, except with a spear or halberd. Bows and crossbows have disadvantage when you stand in front and shoot at the front row.")
    /** 223T.eingebung: the hero's insight in the log before the first melee blow from the back row. */
    val backInsight = T("Von hier hinten reiche ich kaum hin. Vorn, mit einem Speer oder aus der Ferne träfe ich besser.",
        "From back here I can barely reach. Up front, with a spear or from afar, I would strike better.")

    val skills = T("Zauber und Fähigkeiten deiner Klasse. Zauber kosten Zauberpunkte, manches geht nur einmal pro Kampf oder bis zur Rast.",
        "Your class's spells and abilities. Spells cost spell points; some things work only once per battle or until you rest.")
    val bag = T("Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.",
        "A healing potion from the shared stock, for you or a friend. Costs your turn.")
    // 72.10a.8: half a turn; 72.10a.11: the weapon switch
    val place = T("Mit einem Freund tauschen oder auf einen freien Platz gehen. Hinten bist du gedeckt, solange vorn ein Freund steht. Ein halber Zug: danach bleibt noch ein Schlag. Hier wechselst du auch die Waffe.",
        "Swap with a friend or move to a free place. At the back you are covered while a friend stands in front. Half a turn: one blow remains after it. This is also where you switch weapons.")
    val defend = T("Bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil, Rettungswürfe auf Geschicklichkeit Vorteil. Manchmal ist das die richtige Antwort.",
        "Until your next turn, attacks on you have disadvantage and Dexterity saves have advantage. Sometimes that is the right answer.")
    val cover = T("Einen Zug lang zieht der Kämpfer jeden angekündigten Schlag auf Freunde auf sich. Ring perfekt: Gegenschlag.",
        "For one turn the fighter draws every announced blow aimed at friends. Perfect ring: a counterblow.")
    val merc = T("Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.", "Auto: the Söldner fights on their own. Manual: you give every order.")
    val autopilot = T("Spielt deinen Helden: Waffe, Zaubertricks, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel der Lebenspunkte und bei einer starken Absicht; nie gegen Bosse.",
        "Plays your hero: weapon, cantrips, healing for a weak friend. Always meets the ring with good, never perfect. Stops below a third of life points and on a strong intent; never against bosses.")
    private val wounds = T("Auch für einen Freund, über alle Reihen.", "Also for a friend, across all rows.")
    private val potion = T("Heilt 2W4+2 TP.", "Heals 2d4+2 HP.")
    private val feint = T("Aus der hinteren Reihe, wenn vorn ein Freund steht: erreicht jeden Gegner ohne Deckung.", "From the back row, with a friend in front: reaches any foe without cover.")
    private val fireball = T("Trifft die ganze Reihe des Ziels.", "Strikes the target's whole row.")

    /** 210: what a long press on a foe's intent says (Homer's text, 210T). */
    private val intents: Map<String, T> = mapOf(
        "heavy" to T("Schwerer Hieb: die Keule mit voller Wucht, 2W6 mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seiner Lebenspunkte abnehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr, Decken oder den Ring treffen.",
            "Heavy blow: the club at full force, 2d6 extra damage, against one figure. Helps: take a fifth of his life points first and he staggers, his turn lost; otherwise Defend, Guard or meet the ring."),
        "call" to T("Rudel rufen: ein Goblin kommt, beim zweiten Mal ein Späher, mehr nicht. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen.",
            "Call the pack: a goblin comes, the second time a scout, no more. Helps: it cannot be stopped; use the turn to wear Grak down or to set your line."),
        "gather" to T("Kraft sammeln: er heilt sich um 2W10 Lebenspunkte. Hilft: ein Fünftel seiner Lebenspunkte vorher abnehmen, dann bleibt die Heilung aus.",
            "Gather strength: he heals 2d10 life points. Helps: take a fifth of his life points first and the healing fails."),
        "breakthrough" to T("Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, mit 1W6 mehr Schaden. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder ein Fünftel seiner Lebenspunkte vorher.",
            "Break through: he shoves the front figure back and strikes the one behind, now in front, with 1d6 extra damage. Helps: the threatened one steps forward, leaving a plain blow; or a fifth of his life points first."),
        "stab" to T("Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Nachteil; meist lohnt der eigene Angriff mehr.",
            "Stab: a plain blow, without a ring. Helps: Defend gives it disadvantage; usually your own attack is worth more."),
        "flank" to T("Flanke: er läuft um die Reihe und sticht eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt den Platz, dann sticht er ins Leere; oder jeder Treffer auf ihn, auch ein leichter.",
            "Flank: he runs round the line and stabs a figure at the back, without cover. Helps: that figure changes places and he stabs at nothing; or any hit on him, however light."),
        "pounce" to T("Anspringen: trifft er, verliert die Figur ihren nächsten Zug. Hilft: die Figur wechselt den Platz, dann springt er ins Leere; ein Platztausch kostet nur einen halben Zug.",
            "Pounce: if it hits, the figure loses its next turn. Helps: that figure changes places and it leaps at nothing; a swap costs only half a turn."),
        "circle" to T("Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, zerstreut das Rudel.",
            "Circle: every wolf bites the same figure at once. Helps: any hit on the wolf that calls it, however light, scatters the pack."),
        "venom" to T("Gift sammeln: der nächste Biss hat 2W6 mehr Schaden, ohne Ring. Hilft: ein Fünftel ihrer Lebenspunkte vorher, dann versiegt das Gift; sonst Abwehr.",
            "Gather venom: the next bite deals 2d6 extra damage, without a ring. Helps: a fifth of her life points first and the venom dries up; otherwise Defend."),
        "web" to T("Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Nachteil.",
            "Cast web: if it hits, the figure loses its next turn. Helps: meet the ring perfectly; Defend gives her disadvantage."),
        "aim" to T("Anlegen: ein Schuss mit 1W6 mehr Schaden, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei.",
            "Take aim: a shot with 1d6 extra damage, without a ring. Helps: that figure goes on the defensive, ducks, and the arrow misses."),
        "shadow" to T("In den Schatten: er verschwindet, bis zu seinem nächsten Zug haben Angriffe auf ihn Nachteil. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht.",
            "Into the shadows: he vanishes; until his next turn, attacks on him have disadvantage. Helps: any hit before, however light, keeps him in the light."),
    )

    /** 210: the hero's insight in the log at an intent's first sight (210T). */
    private val insights: Map<String, T> = mapOf(
        "heavy" to T("Er holt zu weit aus. Treffe ich ihn jetzt hart, kommt er aus dem Tritt.", "He winds up too far. If I hit him hard now, he loses his footing."),
        "call" to T("Er ruft Hilfe. Die halte ich nicht auf, aber ihn kann ich treffen, solange er brüllt.", "He calls for help. That I cannot stop, but I can hit him while he roars."),
        "gather" to T("Er holt Luft. Jetzt nachsetzen, sonst steht er gleich wieder voll da.", "He is catching his breath. Press now, or he stands whole again."),
        "breakthrough" to T("Er will durch die Reihe. Steht der Bedrohte schon vorn, läuft er ins Leere.", "He means to break the line. If the threatened one already stands in front, he charges into nothing."),
        "stab" to T("Nur ein Stich. Dafür lohnt kein Ausweichen.", "Just a stab. Not worth dodging."),
        "flank" to T("Er will hintenrum. Ein Kratzer hält ihn auf, ein Platzwechsel auch.", "He means to go round. A scratch stops him, and so does a change of place."),
        "pounce" to T("Er duckt sich zum Sprung. Wer nicht mehr dort steht, wird nicht getroffen.", "It crouches to leap. Whoever no longer stands there is not struck."),
        "circle" to T("Der eine führt das Rudel. Den treffen, egal wie leicht.", "That one leads the pack. Hit it, however lightly."),
        "venom" to T("Das Gift kommt ohne Warnung. Ich muss sie treffen, bevor sie beißt.", "The venom comes without warning. I must hit her before she bites."),
        "web" to T("Das Netz fliegt langsam. Wer den Moment trifft, ist frei.", "The web flies slowly. Catch the moment and you are free."),
        "aim" to T("Er zielt auf mich. Ducke ich mich, verfehlt er.", "He is aiming at me. If I duck, he misses."),
        "shadow" to T("Er sucht das Dunkel. Ein Kratzer jetzt, und er bleibt sichtbar.", "He seeks the dark. A scratch now, and he stays in sight."),
    )

    /** 219: the first intent with a ring, in the log (219T.erster), and the word over the first ring (219T.jetzt). */
    private val firstRingText = T("Das Zeichen ◯ heißt: dieser Schlag kommt mit Ring; tippe, wenn er sich um deine Figur schließt, dann nimmst du halben Schaden, im genauen Moment gar keinen.",
        "The sign ◯ means: this blow comes with a ring; tap as it closes around your figure and you take half damage, at the exact moment none at all.")
    private val tapNowText = T("Jetzt tippen, wenn er sich schließt!", "Tap as it closes!")
    fun firstRing(lang: Lang): String = firstRingText(lang)
    fun tapNow(lang: Lang): String = tapNowText(lang)

    fun intent(id: String, lang: Lang): String? = intents[id]?.invoke(lang)
    fun insight(id: String, lang: Lang): String? = insights[id]?.invoke(lang)

    /** A skill: its description, and for some a word on how it works in MARS. */
    fun skill(s: Skill, lang: Lang): String = s.desc(lang) + when (s) {
        Skill.CURE_WOUNDS -> "\n" + wounds(lang)
        Skill.FEINT -> "\n" + feint(lang)
        Skill.FIREBALL -> "\n" + fireball(lang)
        else -> ""
    }

    /** A potion: its description, and the healing where the description does not name it. */
    fun item(id: String, lang: Lang): String = Items[id].desc(lang) + if (id == "potion") "\n" + potion(lang) else ""
}
