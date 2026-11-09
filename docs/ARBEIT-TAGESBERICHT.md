# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 09.11., 10:12** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 4 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 0 abgenommen, 4 gebaut, 6 in Arbeit, 31 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 64 / 268, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 40 / 184; neu 120 / 377 |
| 3 | Rest geschätzt | Wochenziel 09.–15.11. „Der Kampf funktioniert“: Jerry hat 20 Kampfzeilen (717 in Arbeit), Tom 4 zum Helden, 2 übernommene, dazu 506 und das Lager der Höhle (492). (ganz unter „Eingaben“) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **5 entscheiden**, **1 Build**, **1 tun** | ältestes: 623 seit 07.11., 20:13; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **20** (Tom 13, Jerry 7) | bei dir zum Testen: Build 271; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **15** offen, davon 5 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **10 %** (dein Bild 08.11., 08:44); gestern 691 $ Rechenwert, Spiel 74 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (08.11., 09:18) aus Build 269 und 270 unter anderem 670, 679, 680 (Absturz), 681, 682, 683, 701, 702, 703, dazu heute 717 (08:51); die Woche 02.–08.11. zählt Diogenes im Prüfbericht | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Guthaben; seit 08.11., 20:42 steht die Woche auf Warnung (`allowed_warning`), Kür startet nicht mehr; dein letztes Bild (08.11., 08:44) sagte „Donnerstagnacht aufgebraucht“. Darum ruhen 54 Zeilen ohne Kampfbezug. Ein neues Bild der Nutzung zeigt, ob das reicht |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 101 | 78 | 1 | 28 | 89 |
| Jerry | 73 | 65 | 3 | 6 | 76 |
| Homer | 6 | 1 | 1 | 6 | 18 |
| Sokrates | 62 | 37 | 38 | 6 | 29 |
| Perikles | 37 | 19 | 1 | 11 | 53 |
| Diogenes | 7 | 5 | 0 | 5 | 7 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 09.11., 10:1x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | gebaut (Einzelheiten unten) |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | in Arbeit; diese Woche nur der Kampf (Wochenziel 09.11.), Build 271 bei dir, Höhle fehlt (unten) |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | in Arbeit: Gewerbeschein da (bescheinigt 05.11.); 142.4 von dir entschieden (07.11., 21:3x), D-U-N-S beantragen und Konto umstellen liegt bei dir (tun); AAB des Godot-Builds für Play bei Tom (622, startbar) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Stufe 1:** Build 204 von dir freigegeben (03.11., 07:45, 487); Fertigkeiten kommen mit 2.3; abhaken erst nach deiner Abnahme der Simulation 444 (Prüfung der Stufe), dazu liegt dir noch keine Vorlage vor; der Rechenkern nach dem BRS (478) ist in Build 269 bei dir zum Test.
- **Stufe 2:** Builds 269 und 270 hast du am 08.11. getestet (Funde t269, t270, darunter 680 Absturz und die Kampffunde 682, 702, 703); Build 271 (09.11., 00:14) liegt bei dir, darin 656 Umhang (von dir „passt“, 06:57) und 703 Ausweichen. Seit deinem „Kampf zuerst“ (08.11., 21:36) ordnet das Wochenziel 09.11. beide Teams auf den Kampf; Höhle (492) nur noch bis zum Lager, Kampforte Höhle (507), Durchspiel-Build (496) und Nebel (505) ruhen bis zu deinem „Kampf passt“.
- **Stufe 4:** Leute des Dorfs mit Gesicht (475, Läufe 1 und 2 von dir abgelehnt, 04.11.; seitdem nicht weiter, startbar); Robe im Build 269 (558, Zeile 269.13); Klang: Tierlaute, Herzschlag, Waldklang, Rattenstimme gebaut (575), Dorftiere hörbar in 269 (591); Effekte: Kauf der Pakete 623 A bei dir (tun); restliche Schirme ohne Kasten (630) startbar.

## Wer hinkt (09.11., 10:1x)

- **Wochenziel 03.–08.11. (Kapitel 1 durchspielbar) nicht erreicht** (Diogenes, Wochenzählung 09.11.): der Durchspiel-Build (496) wurde nicht gebaut, die Höhle (492) ist nicht fertig, Untote (506) sind in Arbeit. Das neue Wochenziel stellt den Kampf vor alles (dein Wort 08.11., 21:36).
- **Tom sitzt fest:** 10 ungetestete Muss sperren ihn (620.1 B), seine Sitzung wartet seit 07:35 auf deinen Test von Build 271; Jerry darf nur seine „jetzt“ (717) bauen.
- **Jerry trug den Kampf allein:** von den Kampfzeilen des Wochenziels lagen fast alle bei ihm; 560 (Monster drehen sich) und 680 (Absturz) gehen an Tom.
- **Rote Läufe** (464): die Tageszahl fehlt weiter im Protokoll (D61.1, jetzt Vorgang 741 bei Ford, Kür).

## Wo du Prioritäten setzen kannst (09.11., 10:1x)

1. **Build 271 testen** ([t271](chefsache/ansehen/t271-sammelbuild.md)): ein Weg durch Hauptmenü, Dorf, Laden, Tiefen Wald und Probekämpfe; darin 656 Umhang und 703 Ausweichen; erst dein Test löst die Sperre 620.1 B, vorher baut Tom nichts.
2. **623 A kaufen** ([623](chefsache/tun/623-kauf.md)): Effekte im Kampf (Treffer, Blut, Zauber) warten auf die Pakete; passt zu „Kampf zuerst“.
3. **743 entscheiden** ([743](chefsache/entscheiden/743-verwerfen-ideen.md)): 15 Ideen verwerfen, kostet dich eine Minute und hält den Ideenspeicher klein; drängt nicht.

*Stärkstes Gegenargument zu 1:* Build 271 enthält viele Kleinigkeiten ohne Kampf (Menüs, Brett, Laden), deine Zeit ginge lieber in den Kampf. *Wie es zu entkräften ist:* ohne den Test bleibt Tom gesperrt, und die Kampfzeilen 656 und 703 liegen nur in diesem Build.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Wochenziel 09.–15.11. „Der Kampf funktioniert“: Jerry hat 20 Kampfzeilen (717 in Arbeit), Tom 4 zum Helden, 2 übernommene, dazu 506 und das Lager der Höhle (492). Schätzungen in Sitzungen bringen Tom und Jerry mit der ersten Sitzung nach deinem Test von Build 271; die Schätzungen vom 03.11. (Höhle etwa 8, Untote etwa 8 Sitzungen) sind überholt.
- Von dir zuerst gefunden: seit dem letzten Bericht (08.11., 09:18) aus Build 269 und 270 unter anderem 670, 679, 680 (Absturz), 681, 682, 683, 701, 702, 703, dazu heute 717 (08:51); die Woche 02.–08.11. zählt Diogenes im Prüfbericht
- Größtes Risiko: Guthaben; seit 08.11., 20:42 steht die Woche auf Warnung (`allowed_warning`), Kür startet nicht mehr; dein letztes Bild (08.11., 08:44) sagte „Donnerstagnacht aufgebraucht“. Darum ruhen 54 Zeilen ohne Kampfbezug. Ein neues Bild der Nutzung zeigt, ob das reicht
