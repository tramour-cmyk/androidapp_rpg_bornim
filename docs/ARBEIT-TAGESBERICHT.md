# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 04.11., 14:04** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 4 gebaut, 0 in Arbeit | 36 Punkte in 6 Stufen: 0 abgenommen, 4 gebaut, 2 in Arbeit, 30 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 18 / 124, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 13 / 64; neu 61 / 265 |
| 3 | Rest geschätzt | Bis zum Durchspiel-Build: Spike hat Wald, Tiefen Wald und Kampforte Wald fertig (etwa 10 der 18 Sitzungen), offen Untote etwa 8 (506, wartet auf Jerrys Ursache der unsichtbaren Netze); Jerry hat alle Gegner außer der Fledermaus und die Kampforte Höhle gebaut, offen je ein Probebild und ein Lauf (494, 507; neue Schätzung fehlt, Montag); Tom Blutzahnhöhle mit neuer Vorlage (492, Schätzung etwa 8 vom 03.11. gilt weiter) und Zufallsspieler (495, wartet auf 494) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **1 entscheiden**, **4 ansehen**, **1 Build**, **1 tun** | ältestes: 142 seit 27.10., 20:07; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **71** (Tom 48, Jerry 23) | bei dir zum Testen: Build 257; höchstens 6 je Build (317) |
| 6 | Fehler | **19** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **79 %** (dein Bild 04.11., 07:11); gestern 752 $ Rechenwert, Spiel 60 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | heute 6: Rattenkampf läuft ohne Eingabe ab (00:03, erneut 13:20, 548, Jerry); Robe des Magiers zu glatt (11:31, 558, Tom); beim Test von Build 257 Testmenü unvollständig (11:52, 555), Waffenwechsel erst nach Kartenwechsel (11:55, 522), Tasche und Gegenstandsfenster durchgefallen (12:01, 521, 524; alle Tom); Höhle zeigt Räume, die der Held nicht sieht (13:54, 492, Tom); Woche zählt Diogenes | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Guthaben 79 % am Mittwochmorgen, 21 % bis Sa 19:59 bei nur einer Entwicklersitzung zugleich (468c); Krogg und Grak fehlen ohne 494 im Spiel, ohne sie ist Kapitel 1 nicht durchspielbar (Zufallsspieler Lauf 261); Perikles prüft täglich, ob 494 vor Sa startet |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 98 | 78 | 6 | 2 | 13 |
| Jerry | 73 | 61 | 7 | 7 | 29 |
| Homer | 7 | 2 | 3 | 3 | 17 |
| Sokrates | 37 | 28 | 16 | 4 | 22 |
| Perikles | 31 | 26 | 2 | 1 | 31 |
| Diogenes | 10 | 8 | 1 | 1 | 11 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 04.11., 14:0x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | gebaut; Build 204 von dir freigegeben (03.11., 07:45, 487); Fertigkeiten kommen mit 2.3; abhaken erst nach deiner Abnahme der Simulation 444 (Prüfung der Stufe), dazu liegt dir noch keine Vorlage vor (Stand 04.11., 14:0x) |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | Flüsterwald, Tiefer Flüsterwald und Kampforte Wald von dir bestanden (t249, 04.11., 00:41), noch nicht auf `main`; Blutzahnhöhle braucht eine neue Vorlage mit Sicht wie alt (492, dein Wort 13:58); Gegner und Kampforte Höhle vor dem Probebild (494, 507); Untote warten (506); der Zufallsspieler kommt bis in die Höhle und bleibt ohne Krogg und Grak stehen (495, Lauf 261) |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | Figuren und Bewegungen in Arbeit, Klang: erst Tierlaute und Herzschlag gebaut |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | wartet auf Gewerbeschein (du, 142) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

## Wer hinkt (04.11., 14:0x)

- **Perikles selbst:** Jerry bat am 03.11., 14:3x um einen Weg für Probebilder auf dem Bauserver; die Bitte stand bei mir nur unter den Einzelheiten, ohne Zeile, und 494 (Gegner) und 507 (Kampforte Höhle) standen seitdem auf „wartet auf Perikles“. Tom hatte den Weg schon um 02:20 gebaut (Eingabe `film=nein`, 416.8). Seit 14:0x stehen beide wieder startbar mit Hinweis an Jerry. Der Tagesbericht kam 6,5 Stunden zu spät, weil Ford ihn erst um 13:59 startete, im ersten Lauf nach dem Neustart von Ford von Hand (110).
- **Guthaben:** dein Bild 04.11., 07:11: 79 % der Woche, plus 26 % in 24 Stunden statt höchstens 10 % (468a). Gestern 752 $ Rechenwert, davon Spiel 60 % (Ziel 70 %, 341 Z5). Bis Sa 07.11., 19:59 bleiben 21 %, also etwa 6 % je Tag; seit 13:38 gilt 468c: nur eine Entwicklersitzung zugleich.
- **Vorrang frisst das Wochenziel:** nach 468c laufen zuerst 475 (Leute mit Gesicht), dann die Rückläufer aus Build 257 (532, 548, 557 mit 524.1), erst dann das Wochenziel. Im Wochenziel seit gestern: Wald bestanden (t249), Höhle zurück zur neuen Vorlage (492).
- **Rote Läufe** (464): die Tageszahl fehlt weiter im Protokoll (D61.1 bei Ford seit 02.11.).

## Wo du Prioritäten setzen kannst (04.11., 14:0x)

1. **Build 257 fertig testen** ([t257](chefsache/ansehen/t257-kampf-klang.md), ab Bereich C, Sokrates begleitet): die Kampfrückläufer 532 und 548 hängen daran.
2. **Nebel im Wald ansehen** ([505](chefsache/ansehen/505-nebel-stufen.md), seit 03.11., 22:3x): der letzte offene Teil des Walds; die Höhle (492) nimmt denselben Nebel.
3. **Reihenfolge unter 468c:** heute 475 vor dem Wochenziel. Sagst du „494 vor 475“, kommen Krogg und Grak zuerst; ohne sie bleibt der Zufallsspieler in der Höhle stehen und der Durchspiel-Build kann nicht entstehen. Mit 6 % je Tag und einer Sitzung zugleich ist der Durchspiel-Build vor Sa 19:59 unwahrscheinlich, so oder so.

*Stärkstes Gegenargument zu 3:* 475 hast du zweimal angemahnt (02.11., 03.11.) und um 00:53 „jetzt“ gesagt; die Leute sieht man bei jedem Test, die Gegner erst beim Durchspielen. *Wie es zu entkräften ist:* gar nicht ganz; es ist deine Wahl zwischen Aussehen jetzt und Durchspielen früher.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Bis zum Durchspiel-Build: Spike hat Wald, Tiefen Wald und Kampforte Wald fertig (etwa 10 der 18 Sitzungen), offen Untote etwa 8 (506, wartet auf Jerrys Ursache der unsichtbaren Netze); Jerry hat alle Gegner außer der Fledermaus und die Kampforte Höhle gebaut, offen je ein Probebild und ein Lauf (494, 507; neue Schätzung fehlt, Montag); Tom Blutzahnhöhle mit neuer Vorlage (492, Schätzung etwa 8 vom 03.11. gilt weiter) und Zufallsspieler (495, wartet auf 494)
- Von dir zuerst gefunden: heute 6: Rattenkampf läuft ohne Eingabe ab (00:03, erneut 13:20, 548, Jerry); Robe des Magiers zu glatt (11:31, 558, Tom); beim Test von Build 257 Testmenü unvollständig (11:52, 555), Waffenwechsel erst nach Kartenwechsel (11:55, 522), Tasche und Gegenstandsfenster durchgefallen (12:01, 521, 524; alle Tom); Höhle zeigt Räume, die der Held nicht sieht (13:54, 492, Tom); Woche zählt Diogenes
- Größtes Risiko: Guthaben 79 % am Mittwochmorgen, 21 % bis Sa 19:59 bei nur einer Entwicklersitzung zugleich (468c); Krogg und Grak fehlen ohne 494 im Spiel, ohne sie ist Kapitel 1 nicht durchspielbar (Zufallsspieler Lauf 261); Perikles prüft täglich, ob 494 vor Sa startet
