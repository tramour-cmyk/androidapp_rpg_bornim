# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 23.11., 10:49** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 3 abgenommen, 2 gebaut, 7 in Arbeit, 29 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 0 / 400, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 0 / 189; neu 76 / 570 |
| 3 | Wo stehen wir | Oberster Block bleibt 10 Regeln (`chefsache/themenbloecke.md`); seit gestern abgenommen sind 870 „Umstellung ganz auf BRS“ (dein Votum A, 23.11., 07:40, ohne Spieltest) und das Höhlenwasser 1566 (Block 5, 23.11., 08:09 nach `main` ohne Build); damit hat Block 10 kein … (ganz unter „Eingaben“) | Themenblock oben, seit gestern abgenommen, als Nächstes (Routine Tagesbericht) |
| 4 | Wartet auf dich | nichts | ältestes: –; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **0** (Tom 0, Jerry 0); wie wirksam die Läufe sind: Zeile 10 | bei dir zum Testen: kein Build; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **10** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche unbekannt; gestern 713 $ Rechenwert, Spiel 12 %; **Bitte Bild der Nutzung** (Anteil der Woche in Prozent; solange die Niederlassung ruht, nur vom Account Max) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (22.11., 17:43) kein Fund im Spiel, weil kein Build bei dir war; im Büro einer: deine Telegram-Nachrichten ohne Bezug liest keiner, „1566 B“ von 06:40 kam erst auf Nachfrage an (23.11., 06:47, 1982). | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | gestern liefen 718 $ Rechenwert, davon 12 % fürs Spiel (Zeile 7), und vor dem Kampf (19 Muss) stehen im Werkzeug-Block 77 Muss (Überblick 10:12), während du bis 27.11. abwesend bist (1961); so beginnt das neue Kampfsystem (1589) wohl erst nach dem Reset 28.11. |  |
| 10 | Läufe | 24 h **98 % grün** (818 von 831), **9 min in roten Läufen** (1 % der Laufzeit), **– Läufe je erledigtem Spielvorgang** (weiter unter der Tabelle) | alle Bau- und Testläufe ohne abgebrochene; je Spielvorgang = Läufe geteilt durch erledigte oder abgenommene Vorgänge des Spiels, ohne verworfene (1659) |
| 11 | Fristen | Testbitten über 5 Tage **0**; Fragen an dich ohne Antwort **0**; Vorgänge ohne Auftrag über 1 Tag **352** (26.1, 30, 39, 41.2, 45 …); unter „Unveröffentlicht“ **151** Einträge; letztes Release v0.1.867 vor **36 Tagen** | Testbitte 5 Tage (A13), Vorgang ohne Auftrag 1 Tag (A3, erst nach der Umstellung), Frage an dich ohne Frist (L-O16); Release nur auf dein Wort |
| 12 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

- Zeile 10 (Läufe), weiter: 7 Tage 96 % grün (890 von 929), 1352 min in roten Läufen (36 % der Laufzeit), 4,9 Läufe je erledigtem Spielvorgang; rot 24 h nach Team: sonstige 13; Buildzweige 24 h: keine Läufe; rote Tests 48 h: keine; APK-Läufe 24 h: **3**, Ø **4 min** (min 4, max 5), vorgerendert **3 von 3**

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 0 | 0 | 0 | 0 | 65 |
| Jerry | 0 | 0 | 0 | 0 | 83 |
| Homer | 0 | 0 | 0 | 0 | 22 |
| Sokrates | 0 | 0 | 0 | 0 | 39 |
| Perikles | 0 | 0 | 0 | 0 | 87 |
| Diogenes | 0 | 0 | 0 | 0 | 7 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 21.11., 20:37; seit 19.11. unverändert, weil das Spiel stand)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | 1.1 und 1.4 abgenommen (720, 09.11., 14:49); 1.2 Fertigkeiten gebaut (471 in t274 bestanden); 1.3 gebaut |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 17 | 2.14 abgenommen; 2.13, 2.15, 2.16 als Teilhaken gebilligt (1375); Builds 298, 299, 300 gestern getestet und freigegeben (298 um 14:42, 299 um 16:22, 300 heute 07:24 ohne den Wolfsbiss 760); kein Build bei dir |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog: Waffenstaffel am Helden gebaut (458.3), Langwaffen kürzer (1621, heute 07:37 A); Figurenkatalog Teil A gebilligt (649.2), Teil B ruht mit dem Kampf; Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten); 4.8 keine SRD-Namen in Arbeit (870) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | Vorlauf: Firmennummer für das Play-Konto (D-U-N-S) beantragt, Umstellung des Kontos Wiedervorlage 24.11. (142.4); AAB des Godot-Builds ruht bis „Kampf passt“ (622) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Kampf (Block 2):** die Ruhe bis heute 20:00 (dein Wort 17.11., 1605) ist abgelaufen, aber seit 20:06 gilt dein neues Wort „nur fertigmachen, dann Werkzeuge“; das neue Kampfsystem (1589) beginnt erst danach.
- **Stufe 2:** Build 300 liegt seit 19.11., 08:14 auf `main`, ohne den Wolfsbiss 760 (1724). Garrick (1535) ist bei Tom gebaut, das Bild steht aus; dafür hast du heute 20:31 einen Lauf freigegeben.
- **Stufe 3 und 4:** kein neuer Stand seit 19.11.; Thessas Spangen (1653) und Rowenas Schürze (1654) hast du am 19.11. gebilligt.

## Wer hinkt (21.11., 20:37)

- **Das Spiel stand seit 19.11., 08:30** (dein Wort: Stillstand bis Sa 20:00 nach dem Griff 1694, Guthaben aufgebraucht): kein Build, kein Spielcode. Build 300 liegt seit 19.11., 08:14 auf `main`, ohne den Wolfsbiss 760 (1724). Die Zeit ging in den Umbau zum Büro (1727) mit Sokrates.
- **Dieser Bericht fehlte zwei Tage** (20. und 21.11.): die Warnung stand seit 20.11., 10:46 bei mir, und ich habe sie übergangen, weil keine Spielarbeit lief. Das ist derselbe Fehler wie am 19.11. (Fehler 341). Ab Montag kommt er wieder täglich, auch unter Sperre.
- **Pflege:** die Vorratsprüfung zeigt 36 Funde, alle bei anderen Besitzern: meist mögliche Doppelungen unter den Systemvorgängen von Sokrates, dazu Toms Zweig 431 (Ausrüstung), der ganz in `main` steckt und mit 125,77 $ als festgefahren gilt. Die Besitzer räumen beim Übergeben auf.
- **Vollzug fehlt** zu vier Entscheiden, darunter der Wolfsbiss 760 (Stichtag heute 20:00); melden muss der Empfehler Sokrates.

## Wo du Prioritäten setzen kannst (21.11., 20:37)

1. **Wann wieder Spielarbeit?** Seit 20:06 gilt dein Wort: Tom nur Garrick (1535), Jerry nur das Build-Werkzeug (1765), Spike nur die Büro-Werkzeuge (1727), sonst nichts. Sag, ob die Teams am Montag mit dem neuen Kampfsystem (1589) anfangen oder erst nach dem Falltest des Büros.
2. **Blender-Probe** an deinem PC (1709, Garricks Flanke) steht für morgen, So 22.11.; gilt der Termin?

*Stärkstes Gegenargument zu 1:* Spielarbeit vor dem fertigen Büro verbraucht Guthaben in den alten Abläufen. *Wie es zu entkräften ist:* die Teams fangen nur das Kampfsystem an, das ohnehin ganz neu gebaut wird. Entscheiden kannst nur du.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-BRS.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Tagesbericht-Routine, 448), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Wo stehen wir: Oberster Block bleibt 10 Regeln (`chefsache/themenbloecke.md`); seit gestern abgenommen sind 870 „Umstellung ganz auf BRS“ (dein Votum A, 23.11., 07:40, ohne Spieltest) und das Höhlenwasser 1566 (Block 5, 23.11., 08:09 nach `main` ohne Build); damit hat Block 10 kein Muss mehr, als Nächstes kommt dort 1487 „Heiler wächst in Kapitel 1 nie im Willen“, davor nach deinem Werkzeug-Eilt (09:15) die Werkzeuge 1992 und 1961 (Überblick `chefsache/README.md`, 23.11., 10:12).
- Von dir zuerst gefunden: seit dem letzten Bericht (22.11., 17:43) kein Fund im Spiel, weil kein Build bei dir war; im Büro einer: deine Telegram-Nachrichten ohne Bezug liest keiner, „1566 B“ von 06:40 kam erst auf Nachfrage an (23.11., 06:47, 1982).
- Größtes Risiko: gestern liefen 718 $ Rechenwert, davon 12 % fürs Spiel (Zeile 7), und vor dem Kampf (19 Muss) stehen im Werkzeug-Block 77 Muss (Überblick 10:12), während du bis 27.11. abwesend bist (1961); so beginnt das neue Kampfsystem (1589) wohl erst nach dem Reset 28.11.
