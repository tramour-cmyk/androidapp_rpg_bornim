# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 8 KB (156.1).

**Übergabe (18.10., 23:21, Jerry – 72.10a.8):** 72.10a.8 gebaut (Durchbrechen, Flanke, Platztausch halber Zug; Texte vorläufig, 72.10a.8T bei Homer); Sammelbuild 31 mit 172 und Prüfpunkt 130.2: PR #120, Zweig `claude/jerry-build-172-72-10a-8`, Prüfliste `ansehen/t31-…`. Build 0.1.869 lief beim Übergeben noch: Nachfolger prüft zuerst PR #120 (grün → Testbitte melden; rot → beheben). Nachfolger: Jerry – 72.10a.9 Rolle und Reaktion je Klasse.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 172 | M | Kampf zu langwierig: Klicks bis zur ersten Aktion | wartet auf Test: Build 31 (PR #120), (a)+(b); (c) Meldungen überspringen offen | `claude/jerry-build-172-72-10a-8` |
| 130.2 | M | **von Sokrates (18.10., 22:3x):** Prüfpunkt „Gefühl“ erneut in die Prüfliste des Sammelbuilds mit 172: „Zwei Kämpfe, einer mit Söldner: Hat der Söldner deine Entscheidung verändert? Ist der Kampf jetzt schnell genug?“ Antwort an Sokrates | wartet auf Test: Build 31, Zeile 31.7 | – |
| 72.10a.8 | K | MARS: Absichten gegen die Aufstellung, Platztausch halber Zug | wartet auf Test: Build 31 (PR #120); Texte vorläufig (72.10a.8T bei Homer) | `claude/jerry-build-172-72-10a-8` |
| 72.10a.9 | K | MARS: Rolle und Reaktion je Klasse | offen | – |
| 72.10a.11 | K | MARS: Zweitwaffe ohne Zugverlust | offen | – |
| 168.1 | K | Umsetzung 168: Kapitel 2 Garrick fest an der Seite, Söldner ab Kapitel 3 | nach dem Meilenstein Kapitel 1 (Bau Kapitel 2); Texte Homer (41) | – |
| D23.3 | K | Diogenes Lauf 23: Magier und Kleriker sterben oft | ruht bis 38h (erst spielt der Chef, 13.5); D23.1 entschieden (nichts ändern) | `claude/diogenes-d41-messung` |
| 24.6 | K | Kampferöffnung wartet + Herzschlag in der Blende | wartet auf 72 (24e: bis die Kampfbilder fertig sind) | – |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte (Grak im Wald) | offen: zweites Standbild mit Nacht und Söldner, dann Bau (erstes Standbild fertig) | `claude/jerry-72u-standbild-grak` |
| 86 | K | Bewegung und Übersicht: Keuchen, Initiative, Rennen | Rest 86.11 mit 72b/38 offen (sonst auf `main`, PR #111) | – |
| 38 | M | Balance: Kapitel 1 gemessen | ruht bis Kapitel 1 durchgespielt (13.5); Eichung 38h danach | – |
| 39 | M | Schwierigkeitsgrad im Menü | wartet auf 38 (Build nach 38, 39.1); PR #107 (Entwurf) aktuell mit main, nachgemessen 18.10. (passt), Prüfliste im PR | `claude/jerry-39-schwierigkeit` |
| D3 | K | Diogenes Lauf 3: Klänge, Monster, Regen, Wölfe | Rest 9.2 offen (sonst auf `main`) | – |
| 59e | K | Händler: Vorrat je Laden | hängt an 39 | `claude/jerry-59e-haendlervorrat` |
| 19e | K | Beispiel für „Bewegungen unrund“ | ruht, bis dem Chef eines auffällt | – |
| 134.3 | K | Kurzer Ruf zum Zeichen 134.1 | nach 134.1 (Tom) | – |
| 140 | K | Monster-Geräusche Rest | nach der Pause; Hörproben zuerst | – |
| 141 | K | Klänge Rest | vorher nachsehen, was mit 18, D3, 119 erledigt ist; dann Hörproben | – |
| 27o | K | Höhlenschacht nachts als Mondlicht (D3.14, von Team Tom) | offen; Lichtfleck `MapLight` (SKYLIGHT, CAVE_EXIT) und Säule `drawCaveShaft`/Leuchtkreis in `WorldScreen.kt` sind fest tagweiß | – |

## Einzelheiten

- **Zu 172** (Chef 18.10., Tester, sinngemäß): „Das Kampfsystem ist sehr langwierig. Wenn ich auf ein Monster zulaufe, will ich es angreifen: klick, klick, klick, klick, klick, und dann muss das erledigt sein. Wenn mich das Monster überrascht, will ich entweder weglaufen oder abwehren. Aber das sind ungefähr 2–3 Klicks, bevor ich überhaupt etwas machen kann.“ Stellungnahme Jerry: heute 2 Tipps je Schlag (Hauptmenü → Kämpfen → Angreifen). Vorschlag (a) „Angreifen“ direkt im Hauptmenü, (b) bei Überraschung sofort „Abwehren“/„Fliehen“, (c) Meldungen überspringbar. Gegenargument: weniger Wahl je Zug; darum (a) nur Abkürzung. Aufwand (a)+(b) ein Build.
- **Zu 130.2** (Vorgangsarchiv 130): Prüfpunkt „Gefühl“ (zwischen Absichten überlegt? Takt? Söldner?) an Sokrates. Chef zu Build 19: „meist dasselbe getippt, Takt okay“.
- **Zu 72.10a.8** (gebaut 18.10.): Grak „Durchbrechen“ (nur wenn hinten jemand gedeckt steht): stößt die vordere Figur nach hinten, trifft das Ziel vorn mit +1W6 und Ring; hart treffen vereitelt; Ziel selbst nach vorn → gewöhnlicher Schlag ohne Ring. Goblin „Flanke“: trifft die hintere Figur ohne Deckung; jeder Treffer vereitelt, Platzwechsel des Ziels lässt sie ins Leere laufen. Platztausch einmal je Zug, halber Zug. Nebenbefund: reines Angreifen gegen Grak (Kämpfer + Magier) 162 → 211 Siege von 400, weil Durchbrechen manchmal den Schweren Hieb ersetzt; Balance beim Chef (Prüfliste).
- **Zu 72.10a.8, .9, .11** (aus 72.10a.7, geteilt 18.10.; .7 erledigt, Build 20 auf `main`): .8 Absichten gegen die Aufstellung, Platztausch halber Zug; .9 Rolle und Reaktion je Klasse; .11 Zweitwaffe ohne Zugverlust. Texte bei Homer.
- **Zu 168.1** (Entscheidung 168 im Vorgangsarchiv; geteilt Chef 18.10., 22:49: „teile 168 auf in Entscheidung und Umsetzung“): Kapitel 2 Garrick fest (kein Ablehnen, kein Anheuern), Söldner ab Kapitel 3; fällt Garrick, nur kurzer Ausfall statt 72.8; MARS-Probe behält den Söldner.
- **Zu D23.3:** Magier und Kleriker sterben oft; ruht bis 38h.
- **Zu 72u.1** (Entscheidung 72u B im Vorgangsarchiv): Kampfort aus der Karte, Zoom 8 (`KAMPFORT=forest:7:14:8,12`); vor dem Bau zweites Standbild mit Menü, Absicht, Ring, Nacht, Söldner (Chefsache ansehen).
- **Zu 86:** 86.11 mit 72b/38; Rennen-Abstand `Stamina.RUN_NOISE` im Test eichen; Kampfzeile „außer Atem“ bräuchte Text von Kreativ.
- **Zu 38:** Ziel zielstrebig Stufe 2–3, Median höchstens 3 Tode (`ChapterSimTest.chapterOneGold`).
- **Zu 39:** Faktor Leicht ×0,8, Schwer ×1,2 (39.1 A); Wortlaut `STORY-BLENDE.md` „Einstellungen“, Marken `[39.2.…]`, eingebaut. Nachmessung 18.10. (Kämpfe unter 90 % auf Normal): Normal 78, Leicht +14, Schwer −18 Sieg-Punkte, im Ziel. Nach 38: main einmischen, einmal neu messen, Build, Prüfliste aus PR #107 in die Chefsache.
- **Zu D3:** 9.2 Regen im Kampf still: prüfen und dem Chef begründen (Chef 16.10.).
- **Zu 59e:** Menge nach Schwierigkeitsgrad (Beschluss 59e); Thessas Ausrüstung wechselt heute alle 8 Siege; 59e.1/59e.2 bei Kreativ.
- **Zu 134.3** (Chef 17.10.): kurzer Ruf (Pfiff, „He!“; CC0) bei Leuten mit Neuem.
- **Zu 140:** Knurren, Schmerz- und Todeslaute, Klappern, Stöhnen, Schmatzen, Kreischen, Kampfrufe, Brüllen; Elite und Grimmzahn tiefer.
- **Zu 141:** Menü-Klick, Belohnungen, Welt (Tür, Begegnung, Alarm, Hinterhalt), Zauber, Tränke, Kampfende, Umgebung.
