# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 01.11., 11:31** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **K1 Kern spielbar**: 0 von 4 abgenommen, 0 gebaut, 0 in Arbeit (Stufen nach Vorschlag 447, noch nicht gebilligt) | 27 Punkte: 0 abgenommen, 0 gebaut, 0 in Arbeit, 27 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 34 / 81, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 13 / 24; neu 60 / 153 |
| 3 | Rest geschätzt | noch keine Schätzung; Tom und Jerry schätzen je Stufe mit Wochenziel 2 (Mo 02.11.) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **5 entscheiden**, **3 ansehen**, **1 tun** | ältestes: 142 seit 27.10., 20:07; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **23** (Tom 12, Jerry 11) | höchstens 6 je Build (317) |
| 6 | Fehler | **2** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler, Befund oder Build im Titel |
| 7 | Geld | Woche **13 %** (dein Bild 01.11., 11:25); gestern 309 $ Rechenwert, Spiel 45 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | zählt Diogenes Mo 02.11. | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | für den Kern der Regeln 2.0 (K1) hat niemand einen Bauauftrag; Gegenmittel: Vorgang „Bau Regeln 2.0“ für Tom und Jerry mit Wochenziel 2 (Perikles, Mo 02.11.) |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](LISTE-ABNAHME-KAPITEL1.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 39 | 29 | 6 | 1 | 9 |
| Jerry | 47 | 34 | 7 | 1 | 4 |
| Homer | 5 | 1 | 0 | 4 | 5 |
| Sokrates | 32 | 24 | 11 | 9 | 18 |
| Perikles | 19 | 17 | 1 | 10 | 36 |
| Diogenes | 6 | 4 | 0 | 8 | 9 |
<!-- /zahlen -->

## Roadmap (Vorschlag 447, ohne Datum; jede Stufe ein Build, den du spielst)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **K1 Kern spielbar** | Erschaffung nach 2.0, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | Rechensimulation der neuen Regeln am Rechner gelaufen (444), Bau nicht begonnen |
| **K2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | Dorf, Läden, Kampf gegen das Wolfsrudel spielbar (dein Test von Build 143 am 31.10.); Rest offen |
| **K3 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | Figuren und Bewegungen in Arbeit, Klang: erst Tierlaute und Herzschlag gebaut |
| **K4 marktreif** | Kapitel 1 im Play Store | 1 | wartet auf Gewerbeschein (du, 142) |
| W1–W3 danach | Ruf und Chronik; Handwerk; SRD ganz abgelöst | – | auf dein Wort |

## Wer hinkt (01.11., 11:05)

- **Entwicklung beim Abschließen:** Tom und Jerry bauen, aber Entwicklung wird erst „erledigt“, wenn du getestet hast; die Änderungen aus Zeile 5 stehen bei dir.
- **Jerry:** in 7 Tagen 4 Vorgänge erledigt bei 47 offenen.
- **Sokrates:** 11 startbare Zeilen liegen.
- **Abläufe statt Spiel:** in 7 Tagen über zwei Drittel der erledigten Vorgänge Abläufe, Werkzeuge, Prüfung.

## Wo du Prioritäten setzen kannst (01.11., 11:05)

1. **Testen**, danach der nächste gemeinsame Build: das gibt Tom und Jerry wieder Arbeit.
2. **447 entscheiden** (Meilensteine, Gespräch mit Sokrates): erst dann zählt Zeile 1 nach gebilligten Stufen, und Mo 02.11. setze ich Wochenziel 2 auf K1.
3. **Rückfragen von Jerry zu den Wölfen** (438a, 438c): sonst hängt seine Kampfarbeit.

*Stärkstes Gegenargument:* noch mehr Tests und Entscheidungen bei dir sind genau der Engpass. *Wie es zu entkräften ist:* mit 447 nimmst du je Stufe einen Build ab statt Einzelblätter; bis dahin bündeln wir (höchstens 6 Änderungen je Build).

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach Spielsystem 2.0 (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: noch keine Schätzung; Tom und Jerry schätzen je Stufe mit Wochenziel 2 (Mo 02.11.)
- Von dir zuerst gefunden: zählt Diogenes Mo 02.11.
- Größtes Risiko: für den Kern der Regeln 2.0 (K1) hat niemand einen Bauauftrag; Gegenmittel: Vorgang „Bau Regeln 2.0“ für Tom und Jerry mit Wochenziel 2 (Perikles, Mo 02.11.)
