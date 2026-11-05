# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 05.11., 07:11** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 4 gebaut, 0 in Arbeit | 36 Punkte in 6 Stufen: 0 abgenommen, 4 gebaut, 4 in Arbeit, 28 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 20 / 133, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 8 / 64; neu 35 / 278 |
| 3 | Rest geschätzt | Bis zum Durchspiel-Build fast unverändert seit gestern; vom Wochenziel liefen nur Höhle (492, Einzelstücke und Mängelliste gebaut, 15:43–18:55) und Nebel (505, Lauf 2 bei dir 19:02): Spike offen Untote etwa 8 Sitzungen (506, wartet auf Jerrys Ursache der unsichtbaren Netze); Jerry offen je ein Probebild und ein Lauf für Gegner und Kampforte Höhle (494, 507; neue Schätzung fehlt, Montag); Tom Blutzahnhöhle neu nach Signatur mit eigener Vorlage (492, Schätzung etwa 8 vom 03.11. gilt weiter) und Zufallsspieler (495, wartet auf 494) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **2 entscheiden**, **1 ansehen**, **1 tun** | ältestes: 142 seit 27.10., 20:07; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **70** (Tom 45, Jerry 25) | bei dir zum Testen: kein Build; höchstens 6 je Build (317) |
| 6 | Fehler | **20** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **82 %** (dein Bild 04.11., 14:33); gestern 384 $ Rechenwert, Spiel 46 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit gestern 14 Uhr 14 neue Vorgänge, fast alle beim Test von Build 257: im Kampf Zugkreis verdeckt (16:56, 561), Helden laufen zu langsam zum Angriff (17:02, 562), Zustandsschilder überlagern Ansage (17:02, 563), Godot-Meldung „Lambda capture“ (17:06, 564), Held am Zug im Gruppenkasten nicht zu sehen (17:10, 565), „In den Schatten“ unsichtbar (17:15, 566), Gegner fast übereinander (17:15, 567), gefallener Gegner wird verschoben (20:33, 573), jedes Tier braucht eine eigene Kennung (21:00, 577; alle Jerry); Baumkronen „ein einziger Brei“ (19:44, 569), Wischen rollt Listen nicht (20:13, 571), Laufprotokoll mit Fehlermeldungen (20:40, 574; alle Tom); dazu Monster drehen sich nicht zum Helden (16:22, 560) und unsicher Knurren im Rattenkampf (20:42, 575; beide Jerry). Nachträge zu älteren Vorgängen: erstes Erklärfenster riesig (16:56, erneut 20:31, 536), Nacht im Testmenü wirkt nicht (17:20, 555), Morwens Hütte zu klein (20:11, 491), Grimmzahn (20:06–20:31, 533), Unerbittlichkeit greift nicht (20:44, 534); Woche zählt Diogenes | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Guthaben zuletzt 82 % (dein Bild 04.11., 14:33, etwa 0,4 % je Stunde, so leer am Fr 06.11. gegen 10:45); seitdem kein Ablesen, das 18-Uhr-Bild fehlt im Protokoll. Gegner (494) und Kampforte Höhle (507) liefen auch gestern nicht, es gab nur Notizen an Jerry; ohne Krogg und Grak ist Kapitel 1 nicht durchspielbar (Zufallsspieler Lauf 261) |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 100 | 78 | 12 | 5 | 15 |
| Jerry | 86 | 73 | 18 | 3 | 29 |
| Homer | 5 | 0 | 1 | 0 | 16 |
| Sokrates | 38 | 29 | 17 | 9 | 28 |
| Perikles | 30 | 24 | 4 | 3 | 33 |
| Diogenes | 12 | 9 | 1 | 0 | 11 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 05.11., 07:0x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | gebaut; Build 204 von dir freigegeben (03.11., 07:45, 487); Fertigkeiten kommen mit 2.3; abhaken erst nach deiner Abnahme der Simulation 444 (Prüfung der Stufe), dazu liegt dir noch keine Vorlage vor (Stand 05.11., 07:0x) |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | Build 257 von dir freigegeben und auf `main` (04.11., 20:45, mit dem Wald aus Build 249); im Kampf (2.3) liegen aus deinem Test elf neue Vorgänge bei Jerry, sechs davon schon gebaut (564, 573, 575, 577 von Jerry; 566, 567 von Tom übernommen); Blutzahnhöhle neu nach Signatur mit eigener Vorlage (492, dein Wort 04.11., 19:20); Gegner und Kampforte Höhle weiter vor dem Probebild (494, 507); Untote warten (506); der Zufallsspieler bleibt ohne Krogg und Grak in der Höhle stehen (495, Lauf 261) |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | Figuren in Arbeit: Leute des Dorfs mit Gesicht (475, Lauf 1 von dir abgelehnt 20:47, Lauf 2 vor dem Versand angehalten 22:25), Roben von dir abgeschlossen (558, 22:21; in der Vorgangsliste noch „gebaut“); Klang: Tierlaute, Herzschlag, Waldklang gebaut, Rattenstimme gebaut (575); Effekte: Film 572 liegt bei dir |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | wartet auf Gewerbeschein (du, 142) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

## Wer hinkt (05.11., 07:0x)

- **Wochenziel:** seit gestern 14 Uhr arbeitete Tom an der Höhle (492, Einzelstücke und Mängelliste nach altem Code gebaut, 15:43–18:55) und am Nebel (505, Lauf 2 bei dir 19:02); Gegner (494), Kampforte Höhle (507), Untote (506) und Zufallsspieler (495) liefen nicht. Die übrigen Entwicklersitzungen gingen an 475 (Leute mit Gesicht), 557 und 558 (Spielstände, Roben), 555 (Testmenü), 569 (Baumkronen), 531 (Garrick, Film vorbereitet), 572 (Effektfilm, dein „jetzt“ 20:27) und die Rückläufer aus Build 257. Das entspricht dem Vorrang nach 468c, kostet aber den Durchspiel-Build dieser Woche.
- **Start heute 07:05:** Ford startete Tom auf 512b (Nachweis des Abgleichs, im Vorrat „vor der nächsten Testbitte“), nicht auf 475; nach dem Vorrat steht 512b oben, und 475 hat bis zur Freigabe von Lauf 3 durch Sokrates nur Messungen am Rechner (einen Grund nennt Ford nicht). Jerry wäre ebenfalls auf 512b gestartet worden, Ford ließ ihn wegen 468c (eine Entwicklersitzung zugleich) aus.
- **Guthaben:** letztes Bild 04.11., 14:33 mit 82 %; das Ablesen um 18 Uhr fehlt im Protokoll von Ford, darum ist offen, ob die Nachtpause 468d wirkt. Gestern 384 $ Rechenwert, davon Spiel nur 46 % (Ziel 70 %, 341 Z5); Sokrates erledigte in den Chefrunden 9 Vorgänge, mehr als jede andere Rolle.
- **Rote Läufe** (464): die Tageszahl fehlt weiter im Protokoll (D61.1 bei Ford seit 02.11.).

## Wo du Prioritäten setzen kannst (05.11., 07:0x)

1. **Film 572 ansehen** ([572](chefsache/ansehen/572-effektfilm.md), Telegram 2:18 min), danach den Kauf der drei Effektpakete für etwa 21 $ entscheiden ([415d.1](chefsache/entscheiden/415d1-effekte-jetzt.md)); Jerrys Nachfolger („572 Urteil, Kampf-Build“) wartet darauf.
2. **Ein neues Bild vom Guthaben** an Sokrates oder mich: ohne Zahl seit gestern 14:33 kann keiner sagen, ob bis Sa 19:59 noch ein Durchspiel-Build drin ist oder ob die Nachtpause aufgehoben werden kann.
3. **Reihenfolge unter 468c (unverändert seit gestern):** 475 vor dem Wochenziel. Sagst du „494 vor 475“, kommen Krogg und Grak zuerst; ohne sie bleibt der Zufallsspieler in der Höhle stehen.

*Stärkstes Gegenargument zu 3:* 475 hast du zweimal angemahnt (02.11., 03.11.) und am 04.11., 00:53 „jetzt“ gesagt; die Leute sieht man bei jedem Test, die Gegner erst beim Durchspielen. *Wie es zu entkräften ist:* gar nicht ganz; es ist deine Wahl zwischen Aussehen jetzt und Durchspielen früher.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Bis zum Durchspiel-Build fast unverändert seit gestern; vom Wochenziel liefen nur Höhle (492, Einzelstücke und Mängelliste gebaut, 15:43–18:55) und Nebel (505, Lauf 2 bei dir 19:02): Spike offen Untote etwa 8 Sitzungen (506, wartet auf Jerrys Ursache der unsichtbaren Netze); Jerry offen je ein Probebild und ein Lauf für Gegner und Kampforte Höhle (494, 507; neue Schätzung fehlt, Montag); Tom Blutzahnhöhle neu nach Signatur mit eigener Vorlage (492, Schätzung etwa 8 vom 03.11. gilt weiter) und Zufallsspieler (495, wartet auf 494)
- Von dir zuerst gefunden: seit gestern 14 Uhr 14 neue Vorgänge, fast alle beim Test von Build 257: im Kampf Zugkreis verdeckt (16:56, 561), Helden laufen zu langsam zum Angriff (17:02, 562), Zustandsschilder überlagern Ansage (17:02, 563), Godot-Meldung „Lambda capture“ (17:06, 564), Held am Zug im Gruppenkasten nicht zu sehen (17:10, 565), „In den Schatten“ unsichtbar (17:15, 566), Gegner fast übereinander (17:15, 567), gefallener Gegner wird verschoben (20:33, 573), jedes Tier braucht eine eigene Kennung (21:00, 577; alle Jerry); Baumkronen „ein einziger Brei“ (19:44, 569), Wischen rollt Listen nicht (20:13, 571), Laufprotokoll mit Fehlermeldungen (20:40, 574; alle Tom); dazu Monster drehen sich nicht zum Helden (16:22, 560) und unsicher Knurren im Rattenkampf (20:42, 575; beide Jerry). Nachträge zu älteren Vorgängen: erstes Erklärfenster riesig (16:56, erneut 20:31, 536), Nacht im Testmenü wirkt nicht (17:20, 555), Morwens Hütte zu klein (20:11, 491), Grimmzahn (20:06–20:31, 533), Unerbittlichkeit greift nicht (20:44, 534); Woche zählt Diogenes
- Größtes Risiko: Guthaben zuletzt 82 % (dein Bild 04.11., 14:33, etwa 0,4 % je Stunde, so leer am Fr 06.11. gegen 10:45); seitdem kein Ablesen, das 18-Uhr-Bild fehlt im Protokoll. Gegner (494) und Kampforte Höhle (507) liefen auch gestern nicht, es gab nur Notizen an Jerry; ohne Krogg und Grak ist Kapitel 1 nicht durchspielbar (Zufallsspieler Lauf 261)
