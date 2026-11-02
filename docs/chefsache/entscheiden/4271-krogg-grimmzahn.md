# 427.1 · Krogg und Grimmzahn nachgemessen: Werte lassen oder ändern?
Jerry · 02.11., 19:49 · E Kampf
Kurz: Mit ihren Besonderheiten gerechnet: Grimmzahn passt, Krogg ohne Morwens Rauch zu hart.

**Frage:** Die Rechensimulation der Kämpfe (444) rechnet jetzt die Besonderheiten der beiden Bosse: Krogg überfällt den Helden (schlägt zuerst und hart zu), Grimmzahn kommt mit zwei Wölfen als Leibwache und reißt den Helden um (Einzelheiten unten). Was soll gelten: (A) beide Werte wie heute im Bestiarium (Krogg: Leben 55, Rüstung 2, Schaden 7, Angriff 20; Grimmzahn: Leben 55, Rüstung 2, Schaden 7, Angriff 22); gegen Krogg hilft der Rauch, den Morwen auf Garricks Rat mitgibt; (B) Grimmzahn wie heute, Krogg schwächer: Leben 48, Schaden 6; (C) etwas anderes.
**Votum Jerry:** A; mit Rauch gewinnen fünf der acht Herkünfte (Startgeschichten des Helden) jeden zweiten Kampf gegen Krogg oder öfter, gegen Grimmzahn auch ohne Hilfsmittel; das erfüllt das Ziel aus 427 (mindestens vier). Ohne Rauch ist Krogg hart, dafür schickt Garrick den Helden zu Morwen.
**Berührt:** 427, 481 (Herkünfte), 473 (Werte im Spiel), Aufgabe „Rauch gegen Krogg“.

**Begründung:** 427 setzte als Ziel: jeden zweiten Bosskampf gewinnen mindestens vier Herkünfte, das Jägerkind knapp darunter.

## Sachverhalt

Quelle: Simulation 444 auf `main` (ee9e5b0bb, `tools/sim444`), je Fall 1000 Kämpfe, Held auf der Stufe des Bosses (Krogg 4, Grimmzahn 5), seine Fertigkeiten aus 400 gerechneten Spielverläufen je Herkunft. „ohne“ = ohne Besonderheiten, wie in 427 gerechnet (gleiche Zahlen).

Gewonnene Kämpfe in % (ab 50 % fett):

| Herkunft | Krogg ohne | Krogg heute | Krogg heute, mit Rauch | Krogg 48/6 | Krogg 48/6, mit Rauch | Grimmzahn ohne | Grimmzahn heute |
|---|---|---|---|---|---|---|---|
| Wachsoldat | **100** | **100** | **100** | **100** | **100** | **100** | **100** |
| Jägerkind | **66** | 24 | **64** | **61** | **88** | **77** | **53** |
| Zauberlehrling | **73** | 24 | **71** | **52** | **93** | **82** | **64** |
| Klosterschüler | **96** | **90** | **96** | **100** | **100** | **98** | **68** |
| Kräutersammler | 2 | 0 | 2 | 2 | 13 | 5 | 2 |
| Schmiedelehrling | 47 | 15 | 46 | 44 | **75** | **60** | 28 |
| Herumtreiber | 46 | 16 | 45 | 44 | **77** | **66** | 37 |
| Wanderer | **72** | 36 | **73** | **72** | **93** | **84** | **59** |
| ab 50 % | 5 | 2 | 5 | 5 | 7 | 7 | 5 |

- „heute“ = Werte aus dem Bestiarium mit Besonderheiten; „48/6“ = Krogg mit Leben 48 und Schaden 6.
- Unterschiede bis etwa 3 Punkte sind Zufall (zwei Rechenläufe).
- Ohne Rauch, aber eine Stufe höher (Held 5), gewinnt das Jägerkind gegen Krogg heute 71 %.
- Kämpfe dauern 6 bis 9 Züge (Klosterschüler 16 bis 18, er heilt sich).
- Der Kräutersammler gewinnt fast nie gegen einen Boss (0 bis 13 %); das löst 481 (Tränke), nicht der Boss.

**Besonderheiten** (aus dem alten Spiel übernommen, `werte.json` „merkmale“):
- Überfall: Krogg schlägt vor dem Helden zu; sein erster Treffer zählt 1,6-fach, mit 50 % Wahrscheinlichkeit ist der Held danach einen Zug betäubt. Morwens Rauch: Kroggs erster Hieb geht fehl.
- Leibwache: zwei Wölfe hinter Grimmzahn beißen je Runde mit 55 % Wahrscheinlichkeit zu, schwächer als er (Angriff −10, Schaden ein Drittel), und fliehen, wenn er fällt.
- Umreißen: trifft Grimmzahn den Helden, liegt dieser mit 50 % Wahrscheinlichkeit am Boden; sein nächster Angriff trifft dann 25 Prozentpunkte schlechter.

## Auswertung

- **Stärkstes Gegenargument gegen A:** wer Morwen nicht findet, steht vor einer Wand (Jägerkind 24 %); „jedes Kapitel ohne Grinden schaffbar“ (Leitbild 3).
- **Zum Teil entkräftet:** der Rauch ist keine Grindarbeit, sondern ein Gang zu Morwen, auf den Garrick hinweist; eine Stufe mehr bringt das Jägerkind auch ohne Rauch auf 71 %.
- **Gegen B:** mit Rauch wird Krogg fast sicher (Jägerkind 88 %, Zauberlehrling 93 %); der Rauch verliert seinen Sinn.

## Folgerungen

- A: im Bestiarium bei Krogg und Grimmzahn das Wort „vorläufig“ streichen, die Werte gelten dann endgültig (Sokrates); sie fahren mit 473 ins Spiel; die Rauch-Aufgabe bleibt wichtig.
- B: Krogg 48/6 in Bestiarium und `werte.json` (Jerry), sonst wie A.
- Danach wird im Spiel mit dem Kampfprotokoll nachgemessen.

Antwort: „427.1 A“, „B“ oder was anders sein soll.
