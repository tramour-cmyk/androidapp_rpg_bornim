# 705 · Magier Stufe 1 allein gegen Wölfe: ohne Ausweichen 17–30 % Siege, so lassen?
Jerry · 09.11., 23:00 · E Kampf · aus Befund Tuffy zu 702 (08.11.)
Kurz: Mit 702 C gewinnt der Magier deutlich öfter als im alten Befund (2–30 %); wer ausweicht, gewinnt 41–84 %

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/6d8512b16/godot/tests/anspringen_702.gd (Lauf am Rechner 09.11., 23:00)

**Frage:** Der Magier (Zauberlehrling) Stufe 1 gewinnt allein gegen Wolf oder Rudel nur 17–30 %, wenn er stur angreift. Weicht er dem angekündigten Sprung aus, sind es 41–84 %. Soll das so bleiben?

**Votum:** „705 A“: so lassen, 705 schließen.

**Berührt:** 702 C (Archiv 09.11., 06:56), 704 (Ausweichen kostet nichts), 438 (Wolfsrudel), `DESIGN-LEITBILD.md` „echte Wahl“

**Begründung:** Im Spiel kämpft der Magier nie allein: der Söldner steht neben ihm, die Messung lässt ihn weg. Der Magier ist die schwache Klasse im Nahkampf; dass er die Ansage lesen muss, ist das Spiel, kein Fehler.

**Sachverhalt:** 300 Kämpfe je Zeile, nur Regeln (`mars.gd`, Regel 702 C „handeln“), Held Stufe 1, 2 Heiltränke, ohne Söldner; „weicht“ wechselt den Platz, wenn ein Sprung auf ihn angesagt ist, und greift dann an.

| Rechnung | Klasse | Rudel, haut nur | Rudel, weicht aus | Wolf, haut nur | Wolf, weicht aus |
|---|---|---|---|---|---|
| SRD | Magier | 18 % | 41 % | 17 % | 75 % |
| BRS | Magier | 21 % | 67 % | 30 % | 84 % |
| BRS | Schurke | 72 % | 89 % | 81 % | 95 % |
| BRS | Kämpfer, Kleriker | 97–99 % | 100 % | 99–100 % | 100 % |

Vor 702 C (Regel „heute“, BRS): Magier 2 % und 7 % ohne Ausweichen, das war der Befund in 705. Verlorene Züge mit 702 C: 0 in allen Zeilen.

**Auswertung:**
- **A (Empfehlung):** so lassen. Kosten: keine. Der Abstand der Klassen bleibt sichtbar, der Magier hat mit Ausweichen und Söldner gute Aussichten.
- **B:** den Magier Stufe 1 gegen Wölfe stärken (Werte oder Zauber nach BRS; Homer und Sokrates schlagen vor, dann neue Messung mit Söldner). Kosten: ein Regelvorschlag, eine Messung, ein Build.
- **Stärkstes Gegenargument gegen A:** Wer als Magier anfängt und die Ansage übersieht, verliert die ersten Kämpfe fast immer; das kann den Einstieg verderben. Weg: zuerst die Messung mit Söldner nachholen (kleiner Umbau des Tests); liegt der Magier dann unter etwa 60 %, B.

**Folgerungen:** A: 705 erledigt. B: Vorgang an Sokrates (Regelvorschlag), danach Jerry (Messung mit Söldner, Bau).

**Stellungnahme Sokrates (10.11., 00:06):** Stärkstes Gegenargument: Die Begründung von A stimmt nicht. Im Spiel kämpft der Held im Wald ohne Söldner: `godot/skripte/spiel.gd` 557 (`kampf_im_wald`) setzt den Söldner nur im Probekampf, sonst `null`; nach 72.9 (14.10.) kommt ein Begleiter erst ab Kapitel 2. Die Messung ohne Söldner ist also genau der Fall in Kapitel 1, und der Magier verliert das Rudel, dem jeder Wolf im Spiel angehört, ohne Ausweichen in vier von fünf Kämpfen (18 % SRD, 21 % BRS). Damit fällt auch der Weg im Gegenargument der Datei („erst mit Söldner messen“): er misst einen Fall, den es in Kapitel 1 nicht gibt. Widerspruch zu Entschiedenem: Leitbild „Grinden darf man, muss man nie“ und „echte Wahl“; wer als Magier die Ansage nicht liest, hat keine Wahl, sondern eine Niederlage. Der Maßstab aus 72.11 („Magier-Schild erst, wenn Magier plus Söldner gegen Grak unter 50 %“) setzt einen Söldner voraus und passt auf Kapitel 1 nicht. Gegen B spricht: mit Ausweichen gewinnt der Magier nach BRS schon 67 % gegen das Rudel; vielleicht reicht ein Lehrsatz zur Ansage im ersten Kampf (72.10a .6) statt neuer Werte. Kosten: B ein Regelvorschlag von mir (BRS), eine Messung Rudel ohne Söldner, ein Build; der Lehrsatz allein eine Zeile Text über Homer. Empfehlung: nicht „705 A“, sondern B mit Ziel „Magier Stufe 1, BRS, Rudel, ohne Söldner, ohne Ausweichen etwa 40 %“, gemessen ohne Söldner, dazu der Lehrsatz zur Ansage im ersten Wolfskampf.

Antwort: …
