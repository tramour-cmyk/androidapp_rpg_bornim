# 1270a · Soll Spike die Godot-Verbesserungen für Tempo (1270) schon bauen, bevor der Umzug auf unser Regelsystem fertig ist?
Sokrates · 15.11., 11:10 · E Technik · aus deinem „1270 A“ 10:51 und deiner Frage 10:55 („wenn wir dann erst wieder mit Folgeaufträgen anfangen, wenn das erledigt ist …“)
Kurz: 1270 berührt andere Dateien als der Rest des Umzugs; darum nicht auf ihn warten, nur 1268 wartet.
Beim Chef, weil: Code auf `main` (Prüfart nach 1128 A: Messung am Handy) und es ändert die Reihenfolge, die du mit „1270 A“ gebilligt hast

Geprüft an: [Stand `8892bf7e9`](https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/8892bf7e9/docs) (Vorgangsliste 870.13, 870.10, 882.1; Botschaft Perikles 10:58; `LISTE-UMZUG-BRS.md` 4)

**Frage:** Du hast um 10:51 „1270 A“ gesagt. Darin stand: Bau erst, wenn der Umzug auf das Bornimer Rollenspielsystem fertig ist (Vorgang 870.13, das Aufräumen am Schluss). Spike misst jetzt schon (1270.1, Ladezeit eines Kampfs und Bildrate am A22 und an deinem Handy). Die drei Bauteile danach warten auf 870.13:
- 1270.2: Figuren und Kampfort-Wald einmal je Spielstart laden und im Speicher halten statt bei jedem Kampf neu (größter Gewinn auf schwachen Handys),
- 1270.3: Shader beim Export vorbauen (kein Hänger beim ersten Zauber),
- 1270.4: Vergleichsbild Glühen und Höhlenlicht für dich.
Sollen diese drei gleich nach der Messung starten, statt auf 870.13 zu warten?

**Votum:** „1270a A“: 1270.2 bis 1270.4 warten nur auf die Messung 1270.1, nicht auf 870.13; die Verbesserungen am Code (1268) warten weiter auf 870.13.

**Berührt:** 1270.2–1270.4 (Spike über Tom), 870.13 (Tom), 1268.1–1268.5, Perikles (Vorrang).

**Begründung:** Du (10:40): „dass das auf … etwas schlechteren Handys dann auch wieder besser läuft“. Das Warten war nur Vorsicht, damit zwei Arbeiten nicht dieselben Dateien ändern.

**Sachverhalt:**
- 870.13 (Tom) räumt am Schluss auf: Lizenzhinweis der fremden Grundregeln raus, alte Regeln `klassisch.gd` (1377 Zeilen) löschen, Wächter über den ganzen Code, Reste der fremden Grundregeln heute in 19 Dateien (Regeln, Hauptmenü, Erschaffung, Tests).
- 870.13 wartet auf 870.10 (Perikles: Kotlin-Bau abschalten), das auf 882.1 (Werkzeuge ohne Kotlin). 882.1 ist am Lauf abgenommen (1272), liegt aber noch nicht auf `main`; Tom mischt den Zweig allein (Bitte an Ford 11:05). Dauer danach geschätzt 1 bis 2 Tage.
- 1270.2 und 1270.3 ändern `figur.gd`, `kampfort.gd` und `export_presets.cfg`; 870.13 ändert Regeldateien, Tests, Bauablauf. Keine gemeinsame Datei nach heutigem Plan.
- 1268 (Tests in einem Prozess, Typwarnungen) ändert genau die Tests und Regeldateien, die 870.13 aufräumt.

**Auswertung:**
- **A (Empfehlung):** 1270 ohne 870.13, 1268 mit. Gewinn: die Handy-Verbesserung kommt 1 bis 2 Tage oder mehr früher. Kosten gleich.
- **B:** wie entschieden, alles nach 870.13.
- **Stärkstes Gegenargument gegen A:** zwei Baustellen zugleich auf `main`; findest du einen Fehler, ist schwerer zu sagen, woher er kommt. Dagegen: Spike baut getrennt, jeder Punkt geht einzeln in deinen Test.

**Folgerungen:** A: Sokrates setzt bei 1270.2–1270.4 „wartet auf“ nur noch 1270.1; Spike baut nach der Messung. B: nichts ändert sich.

Antwort: …
