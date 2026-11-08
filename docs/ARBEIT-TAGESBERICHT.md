# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 08.11., 09:18** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 4 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 0 abgenommen, 4 gebaut, 6 in Arbeit, 31 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 102 / 240, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 50 / 121; neu 60 / 318 |
| 3 | Rest geschätzt | Das Wochenziel 03.–08.11. (Kapitel 1 durchspielbar) endet heute unerreicht. (ganz unter „Eingaben“) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **2 entscheiden**, **2 ansehen**, **1 Build**, **2 tun** | ältestes: 623 seit 07.11., 20:13; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **40** (Tom 36, Jerry 4) | bei dir zum Testen: Build 269; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **8** offen, davon 7 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **10 %** (dein Bild 08.11., 08:44); gestern 255 $ Rechenwert, Spiel 48 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (07.11., 20:13) keine neuen; Build 269 liegt seit 08:24 bei dir. Davor seit 05.11., 07 Uhr 29 Funde aus Build 266 (589–601, 05.11.), Schenke und Ausrüstung (604, 605, 06.11.) und Build 268 (606–619, 07.11.); die Woche zählt Diogenes montags | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Das Guthaben der neuen Woche reicht beim jetzigen Tempo nur bis Donnerstagnacht (dein Bild 08.11., 08:44: 10 % nach etwa 12,7 Stunden, etwa 0,8 % je Stunde; tragbar wären etwa 0,58 %, also ein Viertel weniger). (ganz unter „Eingaben“) |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 101 | 75 | 23 | 37 | 63 |
| Jerry | 59 | 48 | 27 | 34 | 72 |
| Homer | 5 | 1 | 0 | 3 | 16 |
| Sokrates | 36 | 27 | 18 | 9 | 36 |
| Perikles | 18 | 14 | 1 | 25 | 54 |
| Diogenes | 11 | 9 | 0 | 1 | 5 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 08.11., 09:1x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | gebaut (Einzelheiten unten) |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | in Arbeit, Build 269 bei dir, Höhle fehlt (unten) |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | in Arbeit: Gewerbeschein da (bescheinigt 05.11.); 142.4 von dir entschieden (07.11., 21:3x), D-U-N-S beantragen und Konto umstellen liegt bei dir (tun); AAB des Godot-Builds für Play bei Tom (622, startbar) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Stufe 1:** Build 204 von dir freigegeben (03.11., 07:45, 487); Fertigkeiten kommen mit 2.3; abhaken erst nach deiner Abnahme der Simulation 444 (Prüfung der Stufe), dazu liegt dir noch keine Vorlage vor; der Rechenkern nach dem BRS (478) ist in Build 269 bei dir zum Test.
- **Stufe 2:** Builds 266 (Gegner, 05.11., 19:2x) und 268 (Sammelbuild, 07.11., 14:2x) von dir freigegeben und auf `main`; Wildschwein, Hundertfüßer, Riesenegel, Säureschnecke, Spinne und Krogg im Probekampf gesehen (t266.1), Karte nachts und Höhle nicht prüfbar; Build 269 (08.11., 08:24) liegt bei dir: 28 Prüfzeilen, Tom 21, Jerry 7; Blutzahnhöhle (492) seit heute Nacht in Arbeit, Kampforte Höhle (507) wird nachgezeichnet, Untote (506) nicht begonnen.
- **Stufe 4:** Leute des Dorfs mit Gesicht (475, Läufe 1 und 2 von dir abgelehnt, 04.11.; seitdem nicht weiter, startbar); Robe im Build 269 (558, Zeile 269.13); Klang: Tierlaute, Herzschlag, Waldklang, Rattenstimme gebaut (575), Dorftiere hörbar in 269 (591); Effekte: Kauf der Pakete 623 A bei dir (tun); restliche Schirme ohne Kasten (630) startbar.

## Wer hinkt (08.11., 09:1x)

- **Wochenziel 03.–08.11. (Kapitel 1 durchspielbar) nicht erreicht:** die Höhle (492) ruhte bis zur Zurücksetzung am 07.11., 20:00 und ist erst seit heute Nacht wieder in Arbeit; Untote (506) wurden die ganze Woche nicht begonnen. Das neue Wochenziel setze ich am Montag 09.11. nach der Zählung von Diogenes.
- **Bildlauf ohne Ergebnis:** die Bilder der Kampforte Höhle (507, Lauf 287, 07:39) zog Jerry um 09:04 zurück, weil der Prüfer Stellen ohne Signatur fand (Tusche fehlt draußen und am Wasser); der Lauf kostete Guthaben, ohne dass du etwas sehen konntest.
- **Anteil Spiel an den Kosten:** gestern 255 $ Rechenwert, davon nur 48 % Tom, Jerry und Homer (Ziel 70 %, Z5); den Tag trugen die Aufräumung von Sokrates und die Umstellung auf die eine Vorgangsliste (275.2, Perikles und Diogenes). Heute laufen wieder vor allem Entwickler.
- **Zeile 2 und die Tabelle je Rolle** zählen die Umstellung 275.2 (07.11., 23:4x) mit: 102 erledigte Vorgänge in 24 Stunden sind zum großen Teil übertragene alte Zeilen, keine neue Arbeit; ab morgen ist die Zahl wieder echt.
- **Rote Läufe** (464): die Tageszahl fehlt weiter im Protokoll (D61.1 bei Ford seit 02.11.).

## Wo du Prioritäten setzen kannst (08.11., 09:1x)

1. **Build 269 testen** ([t269](chefsache/ansehen/t269-sammelbuild.md)): 28 Prüfzeilen als ein Weg durchs Spiel, darin der Kampf nach dem BRS (478) und Fehler aus deinen Tests bis Build 268; 37 Vorgänge der beiden Teams fahren darin mit (Tom 29, Jerry 8); bis zu deinem Test bleibt jede Rückmeldung an die Teams offen.
2. **565 und 563 ansehen** ([565](chefsache/ansehen/565-am-zug.md), [563](chefsache/ansehen/563-zustaende.md)): Anzeige, wer am Zug ist, und Zustandsschilder über Gegnern; beide warten seit 07:00 nur auf dein Urteil. Dazu **406.1 entscheiden** ([406.1](chefsache/entscheiden/4061-schildring-simulation.md)): Schildring bauen oder warten, Votum Jerry und Sokrates C, noch nicht bauen.
3. **623 A kaufen** ([623](chefsache/tun/623-kauf.md)): bis die Effektpakete im privaten Repo liegen, baut Jerry den Kampf ohne Effekte; 142.4 (D-U-N-S, [142.4](chefsache/tun/1424-duns-umstellung.md)) drängt nicht fürs Spiel, aber die Vergabe dauert bis etwa 30 Tage, und die Suche nach Testern (142.3 A) ruht bis zur Umstellung.

*Stärkstes Gegenargument zu 1:* ein Test von 28 Zeilen kostet dich viel Zeit, und die Höhle fehlt ohnehin. *Wie es zu entkräften ist:* ohne deinen Test wachsen die ungetesteten Änderungen weiter, und jeder spätere Fund ist schwerer einem Zweig zuzuordnen; die Höhle kommt in den nächsten Build.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Das Wochenziel 03.–08.11. (Kapitel 1 durchspielbar) endet heute unerreicht. Build 269 (08:24) bringt Fehlerbehebungen aus deinen Tests und den BRS-Rechenkern (478), aber keine Höhle. Die Blutzahnhöhle (492) ist seit heute Nacht wieder in Arbeit (Zweig mit `main` gemischt, Tests laufen); die Bilder der Kampforte Höhle (507) hat der Prüfer zurückgezogen, Jerry zeichnet nach; Untote (506) startbar, nicht begonnen; Gegner in der Höhle (494) und Zufallsspieler (495) warten auf 492. Schätzungen vom 03.11. (Höhle etwa 8 Sitzungen, Untote etwa 8) sind überholt; neue Schätzung von Tom und Jerry mit dem Wochenziel am Montag 09.11.
- Von dir zuerst gefunden: seit dem letzten Bericht (07.11., 20:13) keine neuen; Build 269 liegt seit 08:24 bei dir. Davor seit 05.11., 07 Uhr 29 Funde aus Build 266 (589–601, 05.11.), Schenke und Ausrüstung (604, 605, 06.11.) und Build 268 (606–619, 07.11.); die Woche zählt Diogenes montags
- Größtes Risiko: Das Guthaben der neuen Woche reicht beim jetzigen Tempo nur bis Donnerstagnacht (dein Bild 08.11., 08:44: 10 % nach etwa 12,7 Stunden, etwa 0,8 % je Stunde; tragbar wären etwa 0,58 %, also ein Viertel weniger). Es laufen je eine Sitzung Tom und Jerry; Spike und Tuffy sind seit der Zurücksetzung am 07.11., 20:00 wieder vorgesehen (dein Wort 16:3x) und würden das Tempo erhöhen. Ohne die Höhle mit Krogg und Grak (492) bleibt Kapitel 1 nicht durchspielbar
