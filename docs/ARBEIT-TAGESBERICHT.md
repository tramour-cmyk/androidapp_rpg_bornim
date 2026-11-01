# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 01.11., 13:37** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 0 gebaut, 0 in Arbeit | 36 Punkte in 6 Stufen: 0 abgenommen, 0 gebaut, 0 in Arbeit, 36 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 46 / 91, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 19 / 29; neu 74 / 165 |
| 3 | Rest geschätzt | noch keine Schätzung; Tom und Jerry schätzen je Stufe mit Wochenziel 2 (Mo 02.11.) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **1 ansehen**, **1 tun** | ältestes: 142 seit 27.10., 20:07; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **27** (Tom 15, Jerry 12) | höchstens 6 je Build (317) |
| 6 | Fehler | **2** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler, Befund oder Build im Titel |
| 7 | Geld | Woche **13 %** (dein Bild 01.11., 11:25); gestern 410 $ Rechenwert, Spiel 50 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | zählt Diogenes Mo 02.11. | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | für den Kern der Regeln 2.0 (K1) hat niemand einen Bauauftrag; Gegenmittel: Vorgang „Bau Regeln 2.0“ für Tom und Jerry mit Wochenziel 2 (Perikles, Mo 02.11.) |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](LISTE-ABNAHME-KAPITEL1.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 42 | 32 | 8 | 2 | 10 |
| Jerry | 48 | 35 | 9 | 2 | 5 |
| Homer | 7 | 3 | 3 | 6 | 7 |
| Sokrates | 29 | 21 | 11 | 13 | 20 |
| Perikles | 21 | 18 | 3 | 13 | 39 |
| Diogenes | 6 | 4 | 0 | 9 | 10 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 01.11., 13:5x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | Rechensimulation der neuen Regeln am Rechner gelaufen (444), Bau nicht begonnen |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | Dorf, Läden, Kampf gegen das Wolfsrudel spielbar (dein Test von Build 143 am 31.10.); Rest offen |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | Figuren und Bewegungen in Arbeit, Klang: erst Tierlaute und Herzschlag gebaut |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | wartet auf Gewerbeschein (du, 142) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

## Wer hinkt (01.11., 11:05)

- **Entwicklung beim Abschließen:** Tom und Jerry bauen, aber Entwicklung wird erst „erledigt“, wenn du getestet hast; die Änderungen aus Zeile 5 stehen bei dir.
- **Jerry:** in 7 Tagen 4 Vorgänge erledigt bei 47 offenen.
- **Sokrates:** 11 startbare Zeilen liegen.
- **Abläufe statt Spiel:** in 7 Tagen über zwei Drittel der erledigten Vorgänge Abläufe, Werkzeuge, Prüfung.

## Wo du Prioritäten setzen kannst (01.11., 11:05)

1. **Testen**, danach der nächste gemeinsame Build: das gibt Tom und Jerry wieder Arbeit.
2. **447 entschieden** (01.11.): Zeile 1 zählt jetzt nach den Stufen; Mo 02.11. setze ich das Wochenziel auf Stufe 1, mit den Schätzungen von Tom und Jerry.
3. **Rückfragen von Jerry zu den Wölfen** (438a, 438c): sonst hängt seine Kampfarbeit.

*Stärkstes Gegenargument:* noch mehr Tests und Entscheidungen bei dir sind genau der Engpass. *Wie es zu entkräften ist:* mit 447 nimmst du je Stufe einen Build ab statt Einzelblätter; bis dahin bündeln wir (höchstens 6 Änderungen je Build).

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: noch keine Schätzung; Tom und Jerry schätzen je Stufe mit Wochenziel 2 (Mo 02.11.)
- Von dir zuerst gefunden: zählt Diogenes Mo 02.11.
- Größtes Risiko: für den Kern des BRS (Stufe 1) hat niemand einen Bauauftrag; Gegenmittel: Vorgang „Bau BRS“ je Stufe für Tom und Jerry mit dem Wochenziel (Perikles, Mo 02.11.)
