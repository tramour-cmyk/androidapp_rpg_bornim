# Tagesbericht

Ein Bericht am Morgen (448, Chef 01.11., 11:09: „448 mach es so“), ersetzt den Stand zum Marktstart und das Dashboard. Die zehn Zeilen und die Tabelle je Rolle zählt `tools/tagesbericht.py`; Roadmap, Wer hinkt und Prioritäten schreibt Perikles. Täglich 7:30 (Sa, So 9:30); fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford.

## Zehn Zeilen

<!-- zahlen -->
**Stand 14.11., 10:11** (Werkzeug `tools/tagesbericht.py`)

| # | Kennzahl | heute | Bemerkung |
|---|---|---|---|
| 1 | Stufe | **Stufe 1 Kern spielbar**: 2 von 4 abgenommen, 2 gebaut, 0 in Arbeit | 41 Punkte in 6 Stufen: 3 abgenommen, 2 gebaut, 7 in Arbeit, 29 offen |
| 2 | Seit gestern | abgenommen **1**, gebaut **0**, von dir zurück **0** | Vorgänge erledigt 24 h / 7 Tage: 156 / 746, davon Spiel (Entwicklung, Gestaltung, Texte, Design) 78 / 437; neu 142 / 802 |
| 3 | Rest geschätzt | Wochenziel 09.–15.11. „Der Kampf funktioniert“, Stand Samstag: die Schritte 1 und 2 sind erledigt (Build 280 und Build 281 auf `main`, 281 seit 13.11., 10:55). (ganz unter „Eingaben“) | Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu |
| 4 | Wartet auf dich | **1 entscheiden**, **3 ansehen**, **1 Build** | ältestes: 1036.1 seit 13.11., 13:34; [Chefsache](chefsache/README.md) |
| 5 | Builds | Änderungen warten auf deinen Test: **62** (Tom 27, Jerry 35); rote Läufe 24 h **17 von 25** (Tom 5, Jerry 11, Build 1), 7 Tage 94 von 182 | bei dir zum Testen: Build 285; ein Build nimmt alle fertigen Zweige (317) |
| 6 | Fehler | **17** offen, davon 6 älter als drei Tage | offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3) |
| 7 | Geld | Woche **66 %** (dein Bild 13.11., 09:46); gestern 1062 $ Rechenwert, Spiel 39 %; **Bitte Bild der Nutzung** (Woche %; ruht die Niederlassung: nur Max; 783 W7) | Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal) |
| 8 | Von dir zuerst gefunden | seit dem letzten Bericht (13.11., 08:15) in Build 281 1102 Kampfbericht deckt den Schirm nicht ganz; in Build 282 505 Nebel, 764 Zustände im Heldenreiter ohne Erklärung, 1086 Pim rennt nicht heim, 1142 nach Grak derselbe Kampf noch einmal, 1144 Ketten fallen ohne Klang und Lyra bleibt gefesselt; in Build … (ganz unter „Eingaben“) | Woche, zählt Diogenes montags |
| 9 | Größtes Risiko | keine Rolle hat Startbares. Jerry ruht bis zur Entscheidung über die Aktionspunkte (930), Sokrates wartet auf deine Antwort, Tom auf die Freigabe 1242, die Sokrates erteilt; vier Builds (282 bis 285) hängen aneinander und kommen erst mit einem grünen Lauf auf `main` |  |
| 10 | Ausführlich | [Abnahmeliste und Stand](PROJEKTPLAN.md) |  |

| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |
|---|---|---|---|---|---|
| Tom | 122 | 30 | 0 | 40 | 186 |
| Jerry | 114 | 49 | 0 | 42 | 170 |
| Homer | 2 | 0 | 0 | 4 | 61 |
| Sokrates | 48 | 14 | 0 | 18 | 93 |
| Perikles | 24 | 18 | 0 | 46 | 219 |
| Diogenes | 10 | 6 | 0 | 5 | 18 |
<!-- /zahlen -->

## Roadmap (447, von dir gebilligt 01.11. mit Stufe „Alle Systeme angelegt“; ohne Datum; jede Stufe ein Build, den du spielst; Stand 14.11., 10:1x)

| Stufe | Was du spielen kannst | Punkte | Stand |
|---|---|---|---|
| **1 Kern spielbar** | Erschaffung nach dem BRS, Dorf und Wald, Kampf nach neuem Rechenmodell, Fertigkeiten durch Tun, Heldenstufe | 4 | 1.1 und 1.4 abgenommen (720, 09.11., 14:49); 1.2 Fertigkeiten gebaut (471 in t274 bestanden); 1.3 gebaut |
| **2 Kapitel 1 durchspielbar** | alle Orte bis Blutzahnhöhle, alle Quests, Bosse, Schleichen, Spähen, Rasten, je Herkunft eine Handlung | 17 | 2.14 abgenommen (alle Orte begehbar, Höhle in t282); Build 281 (Kampf) seit 13.11., 10:55 auf `main`; Builds 282 bis 284 getestet, aber noch nicht auf `main`; Build 285 bei dir |
| **3 Alle Systeme angelegt** | Lehrmeister, Meisterschaften, Ruf, Herstellen und Sammeln, Abnutzung, Tiere beruhigen, Chronik, Gegenstandskatalog | 8 | Gegenstandskatalog angelegt (458); entschieden: 807 A, 976a, 975a, 1051 A, 1038 A (unten); Rest offen |
| **4 Kapitel 1 fertig** | Aussehen, Musik und Klang je Ort, Englisch, keine SRD-Namen, keine offenen Fehler | 10 | in Arbeit (unten); 4.8 keine SRD-Namen in Arbeit (870) |
| **5 marktreif** | Kapitel 1 im Play Store | 1 | Vorlauf: D-U-N-S beantragt, wartet auf die Bearbeitung bis etwa 08.12. (142.4); AAB des Godot-Builds ruht bis „Kampf passt“ (622) |
| **6 SRD im Code abgelöst** | nach dem Marktstart, für dich unsichtbar | 1 | – |

- **Stufe 1:** 1.2 und 1.3 sind gebaut; der Held nach dem BRS (870.4) ist seit Build 277 auf `main`; abhaken, wenn du beide im Spiel mit diesem Helden gesehen hast.
- **Stufe 2:** Build 281 (Kampf: Zielring, ein Probekampf für alles, fünf Zustände, Grimmzahn tritt beim Wenden) hast du am 13.11. um 09:12 freigegeben; seit 10:55 ist er auf `main` (PR #200). Die Blutzahnhöhle hast du in Build 282 begangen (282.19–.21 bestanden, 14:51); damit ist 2.14 „alle Orte begehbar“ abgenommen. Die Builds 282, 283 und 284 bauen aufeinander auf (PR #201 bis #203) und gehen gemeinsam auf `main`, sobald ein Lauf grün ist; 284 war rot (`ziege_4162`, 1212), Build 285 (PR #204) baut darauf und liegt seit 13.11., 23:30 bei dir. Durchspiel-Build (496) und Kampforte Höhle (507) ruhen bis „Kampf passt“.
- **Stufe 3:** entschieden sind Fertigkeiten ohne Kampf (807 A), Güte in vier Stufen und Schneidern statt Lederarbeit (976a, 975a, 11.11.), Proben mit Fertigkeit ohne Grundwert (1051 A) und Verband stillt Blutung (1038 A, 12.11.).
- **Stufe 4:** der Umhang ruht nach deinem Stopp (12.11., 07:10, 862). Von dir gebilligt seit dem letzten Bericht: vier Helden im Hauptmenü (867), Lyra (1090), Steinkreis im Kampfort (1162), Atmen aller Tiere (1166), Goblins sterben verschieden (1141), Bilder aller 82 Dinge (1073, heute 10:00, Wolfszähne einzeln). Zurück, zum zweiten Mal: Kartenrand (1022), Standpose der Frauen (1044), Röcke wie gestreift (1092, jetzt Frage an dich), Drehen der Leute auf der Stelle (1040.1).

## Wer hinkt (14.11., 10:1x)

- **Stillstand:** keine Rolle hat einen startbaren Vorgang (`startbar.py --stand`, 10:05). Jerry hat seit deinem Halt (13.11., 23:35) Pause: 1072, 709 und 709.1 ruhen, bis die Aktionspunkte (930) entschieden sind, und die Kampfbewegungen 760, 1068, 1043, 1032, 931, 1224 hängen daran. Sokrates hat Pause bis zu deiner Antwort auf seine Frage von 00:44 („Stimmt die Liste der Wunschzüge?“). Tom wartet mit 1091 (Höhlenausgang), 1119 (Fußstaub) und 1040.1 (Drehen) auf 1242, die Freigabe eines Laufs für neue Aufnahmen; die erteilt Sokrates, der in Pause ist. Seit 01:00 hat nur Team Tom gebaut: 785.7 Höhle als Kartenblatt, 785.8 Lagerfeuer auf der Karte, 1073 alle Dinge, dazu Spike die Scheide des Dolchs (1149).
- **Vier Builds nicht auf `main`:** 282 bis 285 hängen aneinander; der Test von 282 (Höhle) ist seit 13.11., 14:51 bestanden, auf `main` kommt er erst mit Build 285, wenn du ihn getestet hast und sein Lauf grün ist (284 war rot).
- **Wiederholte Rückläufer:** 1040.1 Drehen (t281, t282, t283), 1092 Röcke (t283, t284), 1022 Kartenrand (t282, t284), 1044 Standpose (t282, t283), 1086 Pim (t282, t283). Zwei davon (1040.1, 1092) zählt `startbar.py` als festgefahren.
- **Rote Läufe:** 17 von 25 in 24 Stunden (Jerry 11, Tom 5, Build 1), gestern 24 von 40; Trennung Vorlagenlauf gegen Build bleibt in 464 (16.11.).
- **Geld fürs Spiel:** gestern 1062 $ Rechenwert, davon nur 39 % Tom, Jerry, Homer (Ziel Z5: 70 %); am Vortag 80 %. Den Grund prüfe ich mit der Wochenzählung am 16.11.
- **Festgefahren** (827.1): 882.1 (81 $), 431 (50 $), 415 (49 $), 806 (47 $), 756 (37 $), 1114 (35 $); 1040.1 und 1092 mit zwei Rückläufern.

## Wo du Prioritäten setzen kannst (14.11., 10:1x)

1. **Build 285 testen** ([t285](chefsache/ansehen/t285-gang-messen.md), Testbitte seit 13.11., 23:30, über Build 284 installieren): Bild 285.2 und Randwege 285.4a, 285.4b auf Telegram, dann im Reiter „Test“ 285.7 bis 285.11. Danach können 282 bis 285 gemeinsam auf `main`, und Jerrys Sperre (11 ungetestete Muss, 620.1 B) sinkt um die Punkte, die 285 trägt.
2. **Sokrates zu den Aktionspunkten antworten** (930, seine Frage 00:44: „Stimmt die Liste der Wunschzüge?“): davon hängen Jerrys ganzer Kampfteil und, über Sokrates' Pause, Toms Lauf 1242 ab. Willst du die Aktionspunkte erst später besprechen, sag Ford, dass er Sokrates nur für 1242 startet.
3. **Vorlagen ansehen:** [1092 Röcke](chefsache/entscheiden/1092.md) (entscheiden, Votum A: Falten in die Form), [1149 Scheide](chefsache/ansehen/1149-scheide.md), [844 Goblins schlagen](chefsache/ansehen/844-schlagen.md), [1036.1 Zustände](chefsache/ansehen/10361-zustaende.md) (seit 13.11., 13:34).

*Stärkstes Gegenargument zu 1:* die Aktionspunkte (2) entscheiden, ob Jerrys liegende Kampfarbeit überhaupt so gebaut wird; ohne sie bleibt „Kampf passt“ unerreichbar, egal wie viele Builds auf `main` sind. *Wie es zu entkräften ist:* 930 ist ein Gespräch, das du jederzeit führen kannst; der Test von 285 löst vier Builds auf einmal und gibt beiden Teams wieder Arbeit, sobald 930 steht.

## Wie das Projekt aufgebaut ist

- **Spiel:** Godot-Fassung (Ordner `godot/`), Regeln nach dem Bornimer Rollenspielsystem, BRS (`DESIGN-BRS.md`); alte Kotlin-Fassung ruht.
- **Leute:** Chef entscheidet und testet; Sokrates (Stab), Homer (Story), Perikles (Abläufe, dieser Bericht), Diogenes (Prüfer), Ford (startet Sitzungen); Tom und Jerry bauen, Spike und Tuffy helfen ihnen.
- **Ablauf:** jede Aufgabe ein Vorgang mit Nummer im Vorrat ihres Besitzers; was dich braucht, liegt in der Chefsache; Code kommt erst nach deinem Test auf `main`.

## Eingaben

Von Hand (Perikles), das Werkzeug übernimmt sie in die Zeilen 3, 8, 9.

- Rest geschätzt: Wochenziel 09.–15.11. „Der Kampf funktioniert“, Stand Samstag: die Schritte 1 und 2 sind erledigt (Build 280 und Build 281 auf `main`, 281 seit 13.11., 10:55). Aus Schritt 3 sind Ring (1039), Bericht in Farbe (1031) und Zustände (1036) in 281, Angriff mit Bewegung (1025) fährt in 285; Ausweichen (1043) wartet auf den sichtbaren Sprung (760). Schritt 4: Grimmzahn (1040) ist in 281, das Drehen der Leute (1040.1) kam zweimal zurück und wartet auf neue Aufnahmen (1242). Schritt 5: der Probekampf für alles (1034) ist in 281, den Platztausch (1072) hast du am 13.11. um 23:35 angehalten, bis die Aktionspunkte (930) entschieden sind. Schritt 6: 984.1 ist in 281, Kartenrand (1022) und Standpose (1044) kamen zweimal zurück. „Kampf passt“ wird bis Sonntag nicht erreicht; das Wochenziel ab 16.11. setze ich am Montag nach der Wochenzählung neu. Schätzungen in Sitzungen fehlen weiter.
- Von dir zuerst gefunden: seit dem letzten Bericht (13.11., 08:15) in Build 281 1102 Kampfbericht deckt den Schirm nicht ganz; in Build 282 505 Nebel, 764 Zustände im Heldenreiter ohne Erklärung, 1086 Pim rennt nicht heim, 1142 nach Grak derselbe Kampf noch einmal, 1144 Ketten fallen ohne Klang und Lyra bleibt gefesselt; in Build 283 1091 Höhleneingang mit harter Kante; in Build 284 1218 Brücke schwebt, 1222 Rauchbündel ohne sichtbare Wirkung; an Vorlagen 1141 Sterben (dreimal neu), 1120 Text nicht am Pfeil, 1190 Gütewort in der Übersicht, 1073 Wolfszähne und fünf unkenntliche Dinge (59, 60, 77, 78, 82); im Betrieb 1199 Chefsache vor dem Test, 1217 Testliste unterwegs nicht abzuarbeiten, 1225 Prüfpunkt doppelt, 1233 Projektplan ohne Kapitel 2 bis 7, 1072 Halt („erst Hausaufgaben“). Wiederholt statt neu: 1040.1 Drehen (t281, t282, t283), 1092 Röcke (t283, t284), 1022 Kartenrand (t282, t284), 1044 Standpose (t282, t283), 1086 Pim (t282, t283), 949 Kampftext passt nicht zur Bewegung (t282)
- Größtes Risiko: keine Rolle hat Startbares. Jerry ruht bis zur Entscheidung über die Aktionspunkte (930), Sokrates wartet auf deine Antwort, Tom auf die Freigabe 1242, die Sokrates erteilt; vier Builds (282 bis 285) hängen aneinander und kommen erst mit einem grünen Lauf auf `main`
