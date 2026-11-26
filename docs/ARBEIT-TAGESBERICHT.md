# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 26.11., 09:00** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 3 abgenommen, 2 gebaut, 7 in Arbeit, 29 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 124 / 189, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 14 / 24; neu 22 / 279 |
| 3 | Wo stehen wir | Oberster Block 10 Regeln hat kein Muss, der erste Block mit Muss ist 2 Kampf (19 Muss), dort liegt 1589.4 (Arena) „Stufe 3 Gegnerverhalten, Figuren in die Arena“ seit heute 08:50 bei dir zum Ansehen (Wege der Arena); seit dem letzten Bericht (24.11., 07:54) ist nichts … (ganz unter „Eingaben“) | Themenblock oben, seit gestern abgenommen, als Nächstes (Routine Tagesbericht) |
| 4 | Wartet auf dich | **1 anzusehen** | ältestes: 1589.4 seit 26.11., 08:50; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **0** (Tom 0, Jerry 0); wie wirksam die Läufe sind: Zeile 10 | bei dir zum Testen: kein Build; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **6** offen, davon 2 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche unbekannt; gestern 687 $ Rechenwert, Spiel 34 %; **Bitte Bild der Nutzung** (Anteil der Woche in Prozent; solange die Niederlassung ruht, nur vom Account Max) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | 2024, 25.11., 16:03: „Blut muss am Trefferpunkt entstehen, nicht im Raum“ (Krogg); 1708 (Wolfsbiss), 25.11., 19:22: „irgendein Wolfsbiss sah mal wieder aus, als ob er ins Schild geht und dann Blut spritzt“ (Blut bei Schildabwehr, Nebenfund zu B) (Vorgangsarchiv). | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | 1694 Griff hat die Frist Sa 28.11. und seit 25.11., 20:36 einen Auftrag (Deckel 20 $, bisher 89,17 $), steht aber nicht unter den nächsten 20, Figur nimmt zuerst 1785 (Weg aus einem alten Commit, ohne Frist); der Griff gilt für alle gehaltenen Dinge (Vorgangsliste, Überblick 26.11., 08:46). |  |
| 10 | Läufe | 24 h **98 % grün** (763 von 777), **103 min in roten Läufen** (6 % der Laufzeit), **55,5 Läufe je erledigtem Spielvorgang** (weiter unter der Tabelle) | alle Bau- und Testläufe ohne abgebrochene; je Spielvorgang = Läufe geteilt durch erledigte oder abgenommene Vorgänge des Spiels, ohne verworfene (1659) |
| 11 | Fristen | Testbitten über 5 Tage **0**; Fragen an dich ohne Antwort **0**; Vorgänge ohne Auftrag über 1 Tag **324** (26.1, 30, 39, 41.2, 45 …); unter „Unveröffentlicht“ **151** Einträge; letztes Release v0.1.867 vor **39 Tagen** | Testbitte 5 Tage (A13), Vorgang ohne Auftrag 1 Tag (A3, erst nach der Umstellung), Frage an dich ohne Frist (L-O16); Release nur auf dein Wort |
| 12 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

- Zeile 10 (Läufe), weiter: 7 Tage 97 % grün (975 von 1010), 230 min in roten Läufen (4 % der Laufzeit), 42,1 Läufe je erledigtem Spielvorgang; rot 24 h nach Team: sonstige 14; Buildzweige 24 h: keine Läufe; rote Tests 48 h: wolf_mess_438 1×, tausch_1041 1×, stehen_973 1×, biss_1284 1×, reihe_1305 1×, halt_653 1×; APK-Läufe 24 h: **3**, Ø **27 min** (min 4, max 39), vorgerendert **3 von 3**

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 0 | 0 | 0 | 0 | 1 |
| Jerry | 0 | 0 | 0 | 0 | 11 |
| Homer | 0 | 0 | 0 | 0 | 11 |
| Sokrates | 0 | 0 | 0 | 0 | 11 |
| Perikles | 0 | 0 | 0 | 0 | 1 |
| Diogenes | 0 | 0 | 0 | 0 | 0 |
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
- **Fehler 341 (Altbestand):** im Lehrenbuch R39–R42 (24.11., Sokrates); Wortlaut in Git.
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

- Wo stehen wir: Oberster Block 10 Regeln hat kein Muss, der erste Block mit Muss ist 2 Kampf (19 Muss), dort liegt 1589.4 (Arena) „Stufe 3 Gegnerverhalten, Figuren in die Arena“ seit heute 08:50 bei dir zum Ansehen (Wege der Arena); seit dem letzten Bericht (24.11., 07:54) ist nichts abgenommen, gebilligt hast du zwei Aufträge in Block 3: 1694 Griff „A beheben“ (25.11., 19:55, Nachricht 5015) und die Kutte für Klosterschüler 2045 (26.11., 00:06, Nachricht 5027) (Überblick `chefsache/README.md`, 26.11., 08:46; Vorgangsarchiv).
- Von dir zuerst gefunden: 2024, 25.11., 16:03: „Blut muss am Trefferpunkt entstehen, nicht im Raum“ (Krogg); 1708 (Wolfsbiss), 25.11., 19:22: „irgendein Wolfsbiss sah mal wieder aus, als ob er ins Schild geht und dann Blut spritzt“ (Blut bei Schildabwehr, Nebenfund zu B) (Vorgangsarchiv).
- Größtes Risiko: 1694 Griff hat die Frist Sa 28.11. und seit 25.11., 20:36 einen Auftrag (Deckel 20 $, bisher 89,17 $), steht aber nicht unter den nächsten 20, Figur nimmt zuerst 1785 (Weg aus einem alten Commit, ohne Frist); der Griff gilt für alle gehaltenen Dinge (Vorgangsliste, Überblick 26.11., 08:46).
