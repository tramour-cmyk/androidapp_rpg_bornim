# 702 · Wölfe: Wie oft darf das Anspringen den Helden umwerfen?
Tuffy (Team Jerry) · 08.11., 21:52 · E Kampf · Balance

Kurz: Anspringen nimmt dem Helden heute rund 70 % seiner Züge. Welche Regel soll gelten (Empfehlung C)?

**Frage:** Dein Bericht von 21:27 stimmt. Jeder Sprung eines Wolfs, der trifft, wirft den Helden um, und das Aufstehen kostet seinen ganzen Zug. Wolf und Jungwölfe springen abwechselnd, der Held liegt also meist schon wieder, wenn er dran ist. Nach dem BRS verliert er so rund 70 % seiner Züge. Drei oder mehr Züge hintereinander verliert er beim Kämpfer in drei von vier Kämpfen, beim Kleriker in mehr als vier von fünf, bei Magier und Schurke in vier von zehn. Welche Regel soll gelten?

- **A heute:** Es bleibt, wie es ist.
- **B fest:** Wer gerade aufgestanden ist, steht eine Runde fest. Bis zum Ende seines nächsten Zugs wirft ihn kein Sprung um; Schaden nimmt er trotzdem. Er verliert höchstens jeden zweiten Zug.
- **C handeln:** Aufstehen kostet nur den Platzwechsel. Der Held steht auf und greift im selben Zug an, er kann dann aber nicht ausweichen. Der Sprung trifft weiter, macht Schaden und hält ihn an seinem Platz.
- **D Glück:** Ein Sprung wirft nur mit 50 % Wahrscheinlichkeit um.

**Votum (Tuffy): C.** Der Spieler sieht nie mehr nur zu, und der Sprung bleibt gefährlich, weil er dem Helden das Ausweichen nimmt. Bei B verliert der Held immer noch fast jeden zweiten Zug (40 %), auch das ist viel Zusehen.

**Berührt:** 702; Texte für „steht auf“ ohne „Zug verloren“ (C) oder „hält stand“ (B) kommen von Homer.

**Sachverhalt** (am Rechner nachgestellt, `godot/tests/anspringen_702.gd`, Commit 07f2840a8 auf `claude/tuffy-702-anspringen`): je Klasse ein neuer Held der Stufe 1, 300 Kämpfe gegen das Rudel (Wolf mit 1 bis 2 Jungwölfen), nach dem BRS. Der Spieler greift in jedem Zug den ersten Gegner an, wie in deinem Bericht.

| Regel | Siege Kämpfer · Magier · Schurke · Kleriker | Züge verloren | Kämpfe mit 3+ verlorenen Zügen am Stück |
|---|---|---|---|
| A heute | 66 · 2 · 35 · 36 % | 66–71 % | 41–85 % |
| B fest | 96 · 4 · 50 · 77 % | 38–43 % | 0 % |
| C handeln | 99 · 21 · 72 · 97 % | 0 % | 0 % |
| D Glück | 95 · 8 · 47 · 79 % | 33–39 % | 7–29 % |

<details><summary>Auswertung</summary>

- **Stärkstes Gegenargument gegen C:** Das Rudel wird für Kämpfer und Kleriker leicht (97 bis 99 % Siege). Das Anspringen ist dann keine Sonderfähigkeit mehr, nur noch ein Angriff, der festhält. Wenn das zu leicht ist, kann man es über die Werte des Wolfs ausgleichen, ohne dem Spieler wieder Züge zu nehmen.
- **Gegen B:** Der Sprung bleibt besonders, aber fast jeder zweite Zug geht weiter verloren.
- **Gegen D:** Der Zufall entscheidet, ob man zusieht. Ketten von drei und mehr verlorenen Zügen gibt es weiter (bis 29 %).
- **Ausweichen:** Wer bei einem angekündigten Sprung den Platz wechselt, lässt ihn ins Leere gehen. Das hilft nur, solange der Held steht. Gegen einen einzelnen Wolf gewinnt er so heute alle 300 Kämpfe, weil der Wolf nichts anderes kann als springen. Das gehört nicht zu 702, liegt aber als Befund bei Team Jerry (Vorgang 704).
- **Nach dem alten SRD** verliert der Held 33 bis 66 % seiner Züge; Ketten von drei und mehr sind seltener (5 bis 27 %). Dein Bericht (eine Minute nur zusehen) passt eher zu den Zahlen nach dem BRS.
- **Magier:** Ein Magier der Stufe 1 gewinnt gegen das Rudel bei jeder Regel selten (2 bis 21 %). Das ist eine eigene Frage; sie liegt als Befund bei Team Jerry (Vorgang 705), nicht bei 702.
</details>

**Folgerungen:** Nach deiner Antwort baut Team Jerry die gewählte Regel fest ein (mit Homers Texten); sie kommt in den nächsten Sammelbuild.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/07f2840a8 (Messung `godot/tests/anspringen_702.gd` am Rechner, 08.11., 21:49)

Antwort: „702 A“, „702 B“, „702 C“ oder „702 D“.
