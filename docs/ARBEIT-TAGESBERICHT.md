# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 03.11., 07:56** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 0 von 4 abgenommen, 4 gebaut, 0 in Arbeit | 36 Punkte in 6 Stufen: 0 abgenommen, 4 gebaut, 0 in Arbeit, 32 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **4**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 36 / 129, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 18 / 50; neu 66 / 241 |
| 3 | Rest geschätzt | Stufe 1 gebaut, liegt dir in Build 204 vor (471 kommt mit 2.3). Bis zum Durchspiel-Build (Wochenziel 03.11.): neu aufgeteilt (Chef 07:54): Spike Wald, Tiefer Wald, Kampforte Wald, Untote etwa 18 Sitzungen; Jerry übrige Gegner und Kampforte Höhle etwa 18,5; Tom Blutzahnhöhle etwa 8 und Zufallsspieler (348.14 vom 26.10., dort mit Bilderrunden; ohne Feinarbeit weniger) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **1 entscheiden**, **1 ansehen**, **2 tun** | ältestes: 142 seit 27.10., 20:07; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **30** (Tom 13, Jerry 17) | bei dir zum Testen: kein Build; höchstens 6 je Build (317) |
| 6 | Fehler | **10** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **53 %** (dein Bild 03.11., 07:16); gestern 644 $ Rechenwert, Spiel 67 % | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | heute 2, beide beim Test von Build 204: Schalter für Musik und Effekte im Hauptmenü fehlen gegenüber der alten Fassung (07:07, 489, Jerry); Lizenzhinweis der Godot Engine fehlt unter „Über das Spiel“ (07:09, 497, Tom); Woche zählt Diogenes | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | Tom hat neben der Höhle die Befunde aus Build 204 (497, 500, 501, 503); hinkt er, übernimmt Spike nach dem Wald einen Teil der Höhle; Perikles prüft die Verteilung täglich im Tagesbericht |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 65 | 47 | 16 | 5 | 15 |
| Jerry | 61 | 49 | 8 | 15 | 21 |
| Homer | 10 | 4 | 5 | 1 | 10 |
| Sokrates | 36 | 26 | 16 | 3 | 24 |
| Perikles | 32 | 29 | 2 | 12 | 48 |
| Diogenes | 10 | 8 | 3 | 0 | 11 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 03.11., 07:1x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | gebaut; Erschaffung, Heldenstufe, Monsterwerte in Build 204 bei dir, Fertigkeiten kommen mit 2.3 |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 12 | Dorf, Läden, Wolfskampf spielbar, Geschichte gebaut (390); Wald, Tiefer Wald, Höhle starten ab heute (Wochenziel 03.11., 490–496) |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458: 88 Gegenstände, Texte von Homer); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | Figuren und Bewegungen in Arbeit, Klang: erst Tierlaute und Herzschlag gebaut |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | wartet auf Gewerbeschein (du, 142) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

## Wer hinkt (03.11., 07:1x)

- **Feinarbeit statt Spiel, nachts noch einmal:** Jerry ließ zu 438a (Hinfallen und Aufstehen) und 406 (Schild) von 23:13 bis 05:1x elf Läufe laufen (200–211 ohne 204, den Build; laut Jerrys Commits), dann griff 488. Seit 06:44 ist Feinarbeit am Aussehen eingefroren; 463 und 417 hast du heute früh mit „passt“ abgeschlossen, 406 mit „passt“ zusammen mit dem letzten Lauf 406.2.
- **Rote Läufe** (464): seit 02.11., 22:2x 9 von 100 Läufen rot, alle auf Jerrys Zweig zu 438a (eingefroren). Ford schreibt die Tageszahl noch nicht ins Protokoll (D61.1).
- **Guthaben:** dein Bild 03.11., 07:16: 53 % der Woche, das Konto sagt „am Donnerstagmorgen aufgebraucht“. Gestern 17 % statt 10 %, also heute eine Sitzung weniger (468a): Tom macht nur 417, 463 und 497 fertig, der Zufallsspieler (495) wartet; Spike und Jerry arbeiten weiter. Bis Sa 20:00 bleiben etwa 10 % je Tag.
- **Flüsterwald hatte keinen Besitzer:** deine Antwort 479 A (Spike ab 03.11.) stand seit 20:14 ohne Zeile in einem Vorrat; seit 07:1x Vorgang 490 bei Team Tom (Spike), Ford hat den Start.

## Wo du Prioritäten setzen kannst (03.11., 07:1x)

1. **Build 204 fertig testen** (t204): Stufe 1 (Erschaffung, Heldenstufe, Monsterwerte) wird erst mit deinem Test abnehmbar.
2. **Wochenziel 03.11. „Kapitel 1 durchspielbar“** ([Projektplan](PROJEKTPLAN.md)): erst Flüsterwald, Tiefer Flüsterwald, Kampforte, Gegner, Blutzahnhöhle, dann der Durchspiel-Build; der Kampf darin rechnet noch alt, das BRS (2.3) folgt gleich danach. Sagst du „2.3 vorher“, kommen etwa 3–4 Sitzungen vor dein erstes Durchspielen.
3. **Guthaben (dein Bild 07:16, 53 %):** kein Termin, das Guthaben setzt nur das Tempo: höchstens etwa 10 % je Tag, damit es bis Sa 20:00 ohne Stillstand reicht. Der Durchspiel-Build (etwa 45 Sitzungen) kommt, wenn er fertig ist; Flüsterwald und Waldgegner zuerst.

*Stärkstes Gegenargument:* Befunde zum Kampf aus dem ersten Durchspielen gelten nur bedingt, weil 2.3 die Zahlen ändert. *Wie es zu entkräften ist:* Orte, Wege, Geschichte und Gegner hängen nicht an den Regeln, und Stufe 4 verlangt ohnehin ein zweites Durchspielen.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Stufe 1 gebaut, liegt dir in Build 204 vor (471 kommt mit 2.3). Bis zum Durchspiel-Build (Wochenziel 03.11.): neu aufgeteilt (Chef 07:54): Spike Wald, Tiefer Wald, Kampforte Wald, Untote etwa 18 Sitzungen; Jerry übrige Gegner und Kampforte Höhle etwa 18,5; Tom Blutzahnhöhle etwa 8 und Zufallsspieler (348.14 vom 26.10., dort mit Bilderrunden; ohne Feinarbeit weniger)
- Von dir zuerst gefunden: heute 2, beide beim Test von Build 204: Schalter für Musik und Effekte im Hauptmenü fehlen gegenüber der alten Fassung (07:07, 489, Jerry); Lizenzhinweis der Godot Engine fehlt unter „Über das Spiel“ (07:09, 497, Tom); Woche zählt Diogenes
- Größtes Risiko: Tom hat neben der Höhle die Befunde aus Build 204 (497, 500, 501, 503); hinkt er, übernimmt Spike nach dem Wald einen Teil der Höhle; Perikles prüft die Verteilung täglich im Tagesbericht
