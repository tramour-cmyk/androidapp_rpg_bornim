# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 19.11., 08:12** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 3 abgenommen, 2 gebaut, 7 in Arbeit, 29 offen |
| 2 | Seit gestern | abgenommen **0**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 77 / 899, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 34 / 531; neu 108 / 799 |
| 3 | Rest geschätzt | Wochenziel 16.–22.11. „Kampf passt, mit festen Plätzen“ wird nicht erreicht: der Kampf ruht nach deinem Wort bis Sa 21.11., 20:00, weil das neue Kampfsystem (1589) den alten Kampfweg ersetzt. Bis dahin läuft nur Muss mit deinem Bezug (Guthaben 91 %). Schätzungen von Tom und Jerry liegen nicht vor; Montag neu. | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **3 anzusehen** | ältestes: 1653 seit 18.11., 00:00; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **2** (Tom 0, Jerry 2); wie wirksam die Läufe sind: Zeile 10 | bei dir zum Testen: kein Build; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **15** offen, davon 4 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche unbekannt; gestern 439 $ Rechenwert, Spiel 54 %; **Bitte Bild der Nutzung** (Anteil der Woche in Prozent; solange die Niederlassung ruht, nur vom Account Max) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (18.11., 07:51): die Goblins gleiten im Kampf ohne Gehbewegung (14:19, 1664); der Streitkolben in der Haupthand ist am Helden nicht zu sehen (14:34, 1665, wohl Wiederholung von 522); Garrick und der Bewohner im Kittel stimmen nicht (15:57, 1535 Rückläufer); der Umhang deckt den … (ganz unter „Eingaben“) | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | das Guthaben (91 %) reicht bei 0,3 % je Stunde bis Freitag Mittag, bei durchgehender Arbeit wie gestern (1 % je Stunde) nur bis heute gegen 16:00; danach steht alles bis Sa 19:59. Darum läuft nur eine Sitzung, und Build 300 auf `main` (1724) geht vor, damit die freigegebene App sicher dort liegt. |  |
| 10 | Läufe | 24 h **46 % grün** (6 von 13), **528 min in roten Läufen** (65 % der Laufzeit), **0,4 Läufe je erledigtem Spielvorgang** (weiter unter der Tabelle) | alle Bau- und Testläufe ohne abgebrochene; je Spielvorgang = Läufe geteilt durch erledigte oder abgenommene Vorgänge des Spiels, ohne verworfene (1659) |
| 11 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

- Zeile 10 (Läufe), weiter: 7 Tage 48 % grün (81 von 169), 4782 min in roten Läufen (54 % der Laufzeit), 0,3 Läufe je erledigtem Spielvorgang; rot 24 h nach Team: Tom 1, Spike 2, beim Bau eines Test-Builds 4; Buildzweige 24 h: **3 grün, 4 rot, 3 abgebrochen** (70 min Bauzeit verloren) → **Systemfrage an Spike** (rot über grün, Vorgang anlegen); rote Tests 48 h: durchstich_1631 6×, wende_4168 3×, rand_1022 2×, erklaerung_954 1×, schneidern_1460 1×, arkan_993 1×; APK-Läufe 24 h: **13**, Ø **63 min** (min 28, max 100), vorgerendert **6 von 13** (Ø 33 min, mit Neubau 88 min)

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 52 | 16 | 11 | 13 | 219 |
| Jerry | 73 | 24 | 4 | 12 | 229 |
| Homer | 8 | 0 | 7 | 0 | 49 |
| Sokrates | 43 | 8 | 7 | 9 | 104 |
| Perikles | 25 | 19 | 2 | 17 | 195 |
| Diogenes | 9 | 8 | 1 | 1 | 20 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 19.11., 08:12)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | 1.1 und 1.4 abgenommen (720, 09.11., 14:49); 1.2 Fertigkeiten gebaut (471 in t274 bestanden); 1.3 gebaut |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 17 | 2.14 abgenommen; 2.13, 2.15, 2.16 als Teilhaken gebilligt (1375); Builds 298, 299, 300 gestern getestet und freigegeben (298 um 14:42, 299 um 16:22, 300 heute 07:24 ohne den Wolfsbiss 760); kein Build bei dir |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog: Waffenstaffel am Helden gebaut (458.3), Langwaffen kürzer (1621, heute 07:37 A); Figurenkatalog Teil A gebilligt (649.2), Teil B ruht mit dem Kampf; Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten); 4.8 keine SRD-Namen in Arbeit (870) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | Vorlauf: Firmennummer für das Play-Konto (D-U-N-S) beantragt, Umstellung des Kontos Wiedervorlage 24.11. (142.4); AAB des Godot-Builds ruht bis „Kampf passt“ (622) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Kampf (Block 2) ruht bis Sa 21.11., 20:00** (dein Wort 17.11., 23:21, 1605): keine Arbeit am alten Kampfweg, weil das neue Kampfsystem (Arena, Stellung, Beinarbeit, 1589) ihn ersetzt; 47 Zeilen warten auf diesen Termin, auch Gegenstandskatalog 458.3 und Welt in Zellen 1484a, die in den Sammelbuild danach gehen. Das Wochenziel „Kampf passt“ wird damit in dieser Woche nicht erreicht; ich setze es am Montag neu.
- **Stufe 2:** Gestern hast du drei Builds getestet und freigegeben: 298 (14:42, ohne Wiesen 1205, Höhlenwasser 1566 und Wolfsbiss 760), 299 (16:22; Garrick und der Bewohner im Kittel gingen an Tom zurück, 1535) und 300 (heute 07:24, ohne den Wolfsbiss 760, der bei dir durchfiel). Spike nimmt den Wolfsbiss aus Build 300 heraus und führt ihn auf `main` zusammen (1724, gebaut). Die Einmessung wählte auf deinem Handy „Niedrig“ (300.1); das ist zurück bei Spike (1270.6).
- **Stufe 3:** Kein neuer Stand seit gestern; die Vorentscheide der Nacht zum 18.11. sind gebilligt oder eingebaut.
- **Stufe 4:** Drei Figurenbilder liegen bei dir zum Ansehen: Thessas Spangen (1653), Rowenas Schürze (1654), Morwens Kapuze (1655).

## Wer hinkt (19.11., 08:12)

- **Guthaben:** 91 % heute 07:10 (dein Bild), zurückgesetzt Sa 19:59. Seitdem läuft höchstens eine Arbeitssitzung gleichzeitig, nur Muss mit deinem Bezug: Build 300 auf `main` (1724, Spike), danach der Griff für alle gehaltenen Dinge (1694, Spike) und Garrick (1535, Tom). Über Nacht stieg der Verbrauch um 0,3 % je Stunde (87 % gestern 18:21, 91 % heute 07:10); bleibt es so, reicht es bis Freitag Mittag, nicht bis Samstag; läuft die eine Sitzung durch (gestern etwa 1 % je Stunde), ist schon heute gegen 16:00 Schluss.
- **Dieser Bericht kam zu spät:** fällig war er um 07:30, du hast ihn um 08:06 vermisst. Die Nachtpause und die Regel „eine Sitzung“ haben verdeckt, dass er auch unter der Sperre Pflicht ist; Ford prüft ihn jetzt um 07:30 (Fehler 341).
- **Rote Läufe:** in 24 Stunden waren nur 6 von 13 Läufen grün, 528 Minuten (65 % der Laufzeit) liefen in rote Ergebnisse. Am häufigsten rot war der Durchstich-Test (durchstich_1631, 6×). Auf den Buildzweigen stehen 3 grün gegen 4 rot und 3 abgebrochen (70 Minuten verloren); die Systemfrage dazu liegt bei Spike (1719, gebaut); ob sie wirkt, zeigt die Laufzahl in den nächsten Tagen.
- **Pflege:** die Vorratsprüfung fand 39 Stellen; ich habe die Zeilen aus Build 300 nachgezogen und erledigte Notizen gestrichen. Offen bei den Besitzern: neun mögliche Doppelungen, ein Zweig von Tom (431), der schon ganz in `main` steckt, und dein Urteil 1423a (Held im Dunkeln bei Krogg) ohne Folgezeile.

## Wo du Prioritäten setzen kannst (19.11., 08:12)

1. **Drei Figurenbilder ansehen** (Thessa 1653, Rowena 1654, Morwen 1655, in `chefsache/ansehen/`): das sind Bilder, du brauchst dafür kein Guthaben und keinen Build.
2. **Reihenfolge unter der Sperre bestätigen oder ändern:** Build 300 auf `main` (1724), dann Griff (1694), dann Garrick (1535). Alles andere wartet bis Sa 19:59.
3. **Bild der Nutzung am Abend:** damit prüfe ich, ob das Guthaben bis Samstag reicht oder ob wir 1535 auf nach dem Reset schieben.

*Stärkstes Gegenargument zu 2:* Garrick (1535) ist ein Figurenumbau mit vielen Läufen und könnte allein den Rest des Guthabens kosten. *Wie es zu entkräften ist:* es ist dein Rückläufer aus Build 299; schieben wir ihn, bleibt dein Fund bis Montag liegen. Entscheiden kannst nur du.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-BRS.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Wochenziel 16.–22.11. „Kampf passt, mit festen Plätzen“ wird nicht erreicht: der Kampf ruht nach deinem Wort bis Sa 21.11., 20:00, weil das neue Kampfsystem (1589) den alten Kampfweg ersetzt. Bis dahin läuft nur Muss mit deinem Bezug (Guthaben 91 %). Schätzungen von Tom und Jerry liegen nicht vor; Montag neu.
- Von dir zuerst gefunden: seit dem letzten Bericht (18.11., 07:51): die Goblins gleiten im Kampf ohne Gehbewegung (14:19, 1664); der Streitkolben in der Haupthand ist am Helden nicht zu sehen (14:34, 1665, wohl Wiederholung von 522); Garrick und der Bewohner im Kittel stimmen nicht (15:57, 1535 Rückläufer); der Umhang deckt den rechten Unterarm (15:56, 1676); das Schild der Wachsoldatin im Hauptmenü schwebt (15:57, 1675); der Wolfsbiss trifft nicht sicher und Blut spritzt ohne Treffer (22:12, 760, gegen unsere Messung 5 von 5); die Einmessung wählt Niedrig (23:11, 1270.6); „Build 300 freigegeben“ hätten wir dir in deiner Sprache sagen sollen (07:24); dieser Bericht fehlte (08:06, Fehler 341). Wiederholt statt neu: 1665 (wie 522), 1535 und 760 (Rückläufer). Die Woche zählt Diogenes am 23.11.
- Größtes Risiko: das Guthaben (91 %) reicht bei 0,3 % je Stunde bis Freitag Mittag, bei durchgehender Arbeit wie gestern (1 % je Stunde) nur bis heute gegen 16:00; danach steht alles bis Sa 19:59. Darum läuft nur eine Sitzung, und Build 300 auf `main` (1724) geht vor, damit die freigegebene App sicher dort liegt.
