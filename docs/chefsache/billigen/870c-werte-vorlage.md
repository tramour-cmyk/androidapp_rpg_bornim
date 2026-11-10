# 870c · Vorentscheid Regeln im echten Bosskampf (Grak, Fernkampf allein vorn, Jungwölfe und Feuer) billigen?
Sokrates (Vorentscheid, Vorlage Jerry 22:10) · 10.11., 22:27 · E Kampf · aus 870.5 (Umzug BRS Schritt 5: „Simulation 444 neu je Herkunft, Ergebnis zum Chef vor B1“)
Kurz: Im echten Kampf ist Grak außer für den Wachsoldaten kaum zu schlagen, Grimmzahn für Jägerkind und Klosterschüler viel schwerer, Krogg für fünf Herkünfte leichter als in 444; Hauptgrund sind drei Regeln des alten Kampfs.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/730117e73 (`godot/tests/sim444_870.gd`, je Zelle 300 Kämpfe)

**Frage:** Bisher stammten alle BRS-Zahlen aus der Simulation 444, einem vereinfachten Zweikampf. Jetzt habe ich dieselben Helden (Mensch, jede Herkunft, Fertigkeiten wie nach 444 auf dieser Stufe) im echten Kampf des Spiels gegen Rudel, Krogg, Grimmzahn und Grak antreten lassen: der Held spielt wie der Autopilot, ohne Tränke, ohne Söldner. Die Ergebnisse weichen stark ab. Welche Regeln sollen gelten?

**Votum:** Entschieden (Vorentscheid Sokrates, 10.11., 22:25; Chef 22:24: „Du bist Chef. Sorg dafür, dass der Umzug über Nacht über die Bühne geht“): 1 A, 2 A, 3 A. Bitte „gebilligt“ oder „zurück“.

**Abgleich (783 W5):** Leitbild „Kampf nie langweilig, echte Wahl; Grinden darf man, muss man nie“: 1 A lässt die Wahl Goblin oder Grak, 2 A nimmt dem einsamen Schützen eine Strafe ohne Wahl, 3 A macht Feuer zum Mittel statt zum Sofortsieg. 870a 8 A (Gegenwirkung) bleibt, nur der Zeitpunkt des Vertreibens wird an den Leitwolf gebunden. Zielwerte (Wachsoldat ohne Ring etwa 85 % gegen Grak, Wanderer etwa 70 % gegen das Rudel) sind Einzelheiten nach 444. Verworfen: jeweils B (Grak ohne Verstärkung langweiliger; Jägerkind 11 % gegen Grimmzahn; Feuer als Sofortsieg ohne Lohn).

**Umgesetzt:** folgt auf dem Umzugszweig (Jerry, 870.5).

**Rückbau:** „zurück“ = Werte und Regeln je Punkt auf den Stand `730117e73`.

**Kosten:** etwa 2–3 Stunden Jerry.

**Berührt:** 870.5 (Kampf, Jerry), 870.3 (Werte), 709c (Wolfsangriff), Wochenziel B1

**Begründung:** Der Umzugsplan verlangt vor B1 eine Messung je Herkunft gegen Rudel, Krogg und Grak, Ergebnis an dich (`LISTE-UMZUG-BRS.md` 5, Risiko „Die Zahlen ändern sich spürbar“). Leitbild: Kampf nie langweilig, echte Wahl; Grinden darf man, muss man nie.

**Sachverhalt:** Siegquote in % auf der Stufe des Bosses; in Klammern 444.

| Herkunft | Rudel (Stufe 1) | Krogg (4) | Grimmzahn (5) | Grak (6), Ring gut |
|---|---|---|---|---|
| Wachsoldat | 100 (100) | 100 (100) | 100 (100) | 94 (100) |
| Jägerkind | 25 (91) | 40 (39) | 11 (59) | 13 (57) |
| Zauberlehrling | 93 (96) | 55 (35) | 60 (76) | 45 (66) |
| Klosterschüler | 78 (100) | 88 (97) | 22 (84) | 6 (95) |
| Kräutersammler | 8 (53) | 20 (6) | 15 (12) | 0 (8) |
| Schmiedelehrling | 36 (82) | 63 (25) | 44 (41) | 20 (37) |
| Herumtreiber | 51 (85) | 70 (28) | 52 (45) | 23 (44) |
| Wanderer | 17 (90) | 31 (45) | 22 (62) | 1 (63) |

Grak kündigt fast jeden Zug einen starken Schlag an; der Spieler kann ihn am Ring zur Hälfte abwehren. Die Spalte gilt, wenn er den Ring immer gut trifft; trifft er ihn nie: Wachsoldat 47, Zauberlehrling 14, Herumtreiber 6, Schmiedelehrling 5, Jägerkind 1, übrige 0. Die Ursachen habe ich in einzelnen Kämpfen nachgesehen:
- **Grak ruft Verstärkung** (alte Ankündigung „Rudel rufen“, bis zwei Goblins) und holt fast jeden Zug zum „Schweren Hieb“ aus; 444 kennt beides nicht.
- **Fernkampf allein in der vorderen Reihe mit Nachteil** (−25 Prozentpunkte, alte Regel des Kampfs): der Held steht allein immer vorn, also schießt ein Jägerkind immer mit Nachteil.
- **Rudel:** 444 rechnet den Wolf allein; im Spiel kommen 1–2 Jungwölfe und das Anspringen dazu. Feuer vertreibt die Wölfe mit dem ersten Treffer (Gegenwirkung, 870a 8 A): der Zauberlehrling „siegt“ nach 1,4 Zügen, ohne Fell und Erfahrung.
- **Grimmzahns Leibwache** kann man im Spiel schlagen (je 25 Leben); der Held verschießt sich an ihr. Laut Regelwerten ist sie nicht angreifbar: das ist ein Fehler von mir, ich behebe ihn ohne deine Entscheidung (danach wird Grimmzahn für Fernkämpfer leichter, vor allem zusammen mit Punkt 2).
- **Krogg leichter:** teils durch „Kraft schöpfen“ (einmal je Kampf Leben +25 %, kennt 444 nicht; ohne es Schmiedelehrling 49 statt 63), teils durch den Punkt des Volks Mensch; der Rest (beim Schmiedelehrling etwa 24 Punkte, beim Herumtreiber etwa 33) ist noch ungeklärt, ich suche ihn vor B1.

**Auswertung:**
1. **Grak**
   - **A (Empfehlung):** Er ruft weiter Verstärkung (eine Wahl für den Spieler: erst der Goblin oder gleich Grak), aber höchstens einen Goblin; dazu schwächere Werte für Grak, bis ein Wachsoldat auf Stufe 6 ohne Ring etwa 85 % gewinnt. Etwa 1–2 Stunden.
   - **B:** Ohne Verstärkung, so wie 444 gerechnet hat. Langweiliger, einfache Zahlen.
2. **Fernkampf allein vorn**
   - **A (Empfehlung):** Ohne Nachteil, solange kein Gefährte neben ihm steht; mit Gefährten bleibt die Regel. Wenige Minuten.
   - **B:** Regel bleibt; Jägerkind gegen Grimmzahn 11 %.
3. **Jungwölfe und Feuer**
   - **A (Empfehlung):** Jungwölfe bleiben; ich nehme sie in 444 auf und lege ihre Werte neu fest, bis ein Wanderer auf Stufe 1 das Rudel zu etwa 70 % schlägt. Feuer vertreibt die Wölfe erst, wenn der Leitwolf unter halbem Leben ist.
   - **B:** Wie es ist.
- **Stärkstes Gegenargument gegen A:** Gemessen wurde mit dem Autopiloten ohne Tränke und ohne Ausweichen; ein guter Spieler gewinnt öfter. Die Zahlen sind eine Untergrenze, keine Vorhersage.

**Vorläufige Zahlen ohne Simulation** (gelten bis zu deinem Wort, Quelle `tools/sim444/werte.json`): Proben 50 % ± 5 je Punkt Grundwert und je Stufe (5 bis 95); Gegenwirkung ×1,5 Schaden oder halbes Leben; Schadensart je Waffe (Dolch, Speer, Bogen stechen; Schwert schneidet; Stumpfes schlägt); Wehrhaltung nicht frei (444 Teil 7: ohne Wirkung); Lohn: jeder Gegner zählt einzeln (drei Fledermäuse für Stufe 3: 270 statt 50); Begleiter erhalten Erfahrung wie im alten Spiel (Jungwolf 0,3, Leibwache 0,25); Grimmzahn-Kampf härter als im alten Spiel, weil seine Leibwache so stark beißt wie in 444.

**Folgerungen:** Nach deiner Antwort baue ich die Punkte auf dem Umzugszweig, messe neu und nehme das Ergebnis mit in B1.

Antwort: … (gebilligt / zurück)
