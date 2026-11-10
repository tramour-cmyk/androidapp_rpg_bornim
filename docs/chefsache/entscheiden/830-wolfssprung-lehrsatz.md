# 830 · Welcher Satz erklärt im ersten Wolfskampf, wie man dem Sprung ausweicht?
Homer · 10.11., 10:30 · G Story · aus 705 B (Chef 10.11., 08:43)
Kurz: Eingebung zur ersten Ansage „Anspringen“, drei Wortlaute; Godot zeigt heute gar keine Eingebung

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/92b2f63f3/godot/regeln/mars.gd (dazu `godot/kampf/kampf_ui.gd` 697, `mars.gd` 716, 754, 1415, `marstips.gd`, alt `SkirmishScreen.kt` 581; fremd geprüft 10.11., 10:31)

**Frage:** Wer als Magier die Ansage „Anspringen“ übersieht, verliert das Rudel in vier von fünf Kämpfen; wer ausweicht, gewinnt zwei von drei (705). Beim ersten Mal, wenn ein Wolf den Sprung ansagt, soll eine Eingebung des Helden im Kampfbericht stehen, die sagt, was hilft. Welcher der drei Wortlaute?
- **A:** „Er will springen. Stehe ich nicht mehr dort, wohin er springt, schnappt er ins Leere. Wechsel, und mir bleibt noch ein halber Zug.“
- **B:** „Er duckt sich zum Sprung. Wer nicht mehr dort steht, wird nicht getroffen: Wechsel, solange er kauert.“
- **C:** „Der Wolf spannt sich, den Blick auf mich gerichtet. Ein Wechsel, ein halber Schritt nur, und er springt ins Leere.“

(Englisch je in `STORY-SPIEL.md` `[830.sprung]`.)

**Votum:** „830 A“

**Berührt:** 705 und 829 (Magier gegen Rudel; Messung Jerry), 210 B (Eingebungen), `[210T.pounce.eingebung]` (wird ersetzt), Bau Jerry

**Begründung:** Wer die Ansage nicht liest, braucht drei Dinge in einem Satz: dass der Sprung ins Leere gehen kann, welcher Knopf das tut („Wechsel“; 225: der Knopfname sagt, was er tut) und dass es nicht den ganzen Zug kostet; sonst glaubt er, Ausweichen koste den Angriff. Nur A sagt alle drei so, dass ein Neuling sie versteht.

**Sachverhalt:**
- Ansage und langer Druck gibt es in Godot (`marstips.gd` „pounce“ nach `[702T.pounce]`), die Eingebung beim ersten Auftreten (210 B, Chef 19.10., 12:22) nicht: Godot kennt keine Liste „schon gesehen“ und keine Eingebungszeile; die alte Fassung hatte sie (`SkirmishScreen.kt` 581, `insightsSeen`, dort je Gerät statt je Spielstand).
- Der Knopf heißt in Godot „Wechsel“ (`kampf_ui.gd` 697); ein Wechsel kostet einen halben Zug, der Held handelt danach im selben Zug (`mars.gd` 754). Auch allein kann er wechseln, auf den freien Platz der anderen Reihe; der Sprung geht dann ins Leere (`mars.gd` 716, 1415). Hat ein Sprung schon getroffen, kann er im nächsten Zug nicht wechseln (702 C); den ersten Sprung betrifft das nicht.
- Der bisherige Satz `[210T.pounce.eingebung]` („Er duckt sich zum Sprung. Wer nicht mehr dort steht, wird nicht getroffen.“) nennt weder Knopf noch Kosten.

**Auswertung:**
- **A (Empfehlung):** alle drei Teile; Kosten: der längste Satz (drei kurze Sätze); Bau Jerry wie bei B und C.
- **B:** hält den alten Wortlaut und nennt den Knopf; sagt nicht, dass danach noch ein halber Zug bleibt.
- **C:** am meisten Stimmung; „ein halber Schritt“ deutet die Kosten nur an.
- **Stärkstes Gegenargument gegen A:** Ein Knopfname im inneren Satz des Helden bricht die Immersion; B und C klingen mehr nach Chronik. Dagegen: 705 zeigt, dass der Satz die Niederlage abwenden muss; er steht nur einmal je Spielstand.

**Folgerungen:** Homer trägt den gewählten Wortlaut als `[830.sprung]` fest ein; Vorgang an Jerry: Eingebung beim ersten Auftreten nach 210 B in Godot bauen, zuerst der Wolfssprung (ein Satz, einmal je Spielstand). Die übrigen Eingebungen aus `STORY-SPIEL.md` folgen mit demselben Bau.

Antwort: …
