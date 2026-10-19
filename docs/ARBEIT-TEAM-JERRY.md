# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 8 KB (156.1).

**Übergabe (19.10., 08:2x, Jerry – 86):** 86 geprüft, nicht startbar: einziger Rest 86.11 hängt laut Beschluss an 38 (ruht bis Kapitel 1 durchgespielt); Stand auf „wartet auf 38“ gesetzt, kein Code; das Werkzeug las „38:“ nicht als Sperre, jetzt „wartet auf 38 (…)“. Davor (18.10.): 72.10a.11 auf `claude/jerry-72-10a-11-zweitwaffe` gebaut, kommt mit .9 in den Sammelbuild nach Test 31. Nachfolger: Jerry D3 Regen im Kampf (9.2) prüfen (nächste startbare Kür).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 172 | M | Kampf zu langwierig: Klicks bis zur ersten Aktion | wartet auf Test: Build 31 (PR #120), (a)+(b); (c) Meldungen überspringen offen | `claude/jerry-build-172-72-10a-8` |
| 130.2 | M | **von Sokrates (18.10., 22:3x):** Prüfpunkt „Gefühl“ erneut in die Prüfliste des Sammelbuilds mit 172: „Zwei Kämpfe, einer mit Söldner: Hat der Söldner deine Entscheidung verändert? Ist der Kampf jetzt schnell genug?“ Antwort an Sokrates | wartet auf Test: Build 31, Zeile 31.7 | – |
| 72.10a.8 | K | MARS: Absichten gegen die Aufstellung, Platztausch halber Zug | wartet auf Test: Build 31 (PR #120); Texte vorläufig (72.10a.8T bei Homer) | `claude/jerry-build-172-72-10a-8` |
| 72.10a.9 | K | MARS: Rolle und Reaktion je Klasse | gebaut: kommt in den Sammelbuild nach Test 31; Texte vorläufig (72.10a.9T bei Homer) | `claude/jerry-72-10a-9-klassen` |
| 72.10a.11 | K | MARS: Zweitwaffe ohne Zugverlust | gebaut: kommt mit .9 in den Sammelbuild nach Test 31; Texte vorläufig (72.10a.11T bei Homer) | `claude/jerry-72-10a-11-zweitwaffe` |
| 190.9 | K | von Perikles (190): Sammelbuild Jerry: 72.10a.9 und .11 (Zweige `claude/jerry-72-10a-9-klassen`, `-11-zweitwaffe`) in einen Build nach Test 31 | wartet auf Test: Build 31 (172, 72.10a.8) | – |
| 168.1 | K | Umsetzung 168: Kapitel 2 Garrick fest an der Seite, Söldner ab Kapitel 3 | nach dem Meilenstein Kapitel 1 (Bau Kapitel 2); Texte Homer (41) | – |
| D23.3 | K | Diogenes Lauf 23: Magier und Kleriker sterben oft | ruht bis 38h (erst spielt der Chef, 13.5); D23.1 entschieden (nichts ändern) | `claude/diogenes-d41-messung` |
| 24.6 | K | Kampferöffnung wartet + Herzschlag in der Blende | wartet auf 72 (24e: bis die Kampfbilder fertig sind) | – |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte (Grak im Wald) | nach dem Meilenstein (190.5: Wochenziel schließt Kampfort 72u aus); offen: zweites Standbild mit Nacht und Söldner, dann Bau (erstes Standbild fertig) | `claude/jerry-72u-standbild-grak` |
| 86 | K | Bewegung und Übersicht: Keuchen, Initiative, Rennen | wartet auf 38 (Rest 86.11 wird laut Beschluss mit 72b/38 gebaut) (sonst auf `main`, PR #111) | – |
| 38 | M | Balance: Kapitel 1 gemessen | ruht bis Kapitel 1 durchgespielt (13.5); Eichung 38h danach | – |
| 39 | M | Schwierigkeitsgrad im Menü | wartet auf 38 (Build nach 38, 39.1); PR #107 (Entwurf) aktuell mit main, nachgemessen 18.10. (passt), Prüfliste im PR | `claude/jerry-39-schwierigkeit` |
| D3 | K | Diogenes Lauf 3: Klänge, Monster, Regen, Wölfe | Rest 9.2 offen (sonst auf `main`) | – |
| 59e | K | Händler: Vorrat je Laden | hängt an 39 | `claude/jerry-59e-haendlervorrat` |
| 19e | K | Beispiel für „Bewegungen unrund“ | ruht, bis dem Chef eines auffällt | – |
| 134.3 | K | Kurzer Ruf zum Zeichen 134.1 | nach 134.1 (Tom) | – |
| 140 | K | Monster-Geräusche Rest | nach der Pause; Hörproben zuerst | – |
| 141 | K | Klänge Rest | vorher nachsehen, was mit 18, D3, 119 erledigt ist; dann Hörproben | – |
| 27o | K | Höhlenschacht nachts als Mondlicht (D3.14, von Team Tom) | offen; Lichtfleck `MapLight` (SKYLIGHT, CAVE_EXIT) und Säule `drawCaveShaft`/Leuchtkreis in `WorldScreen.kt` sind fest tagweiß | – |
| D29.1 | K | **von Diogenes (Lauf 30):** Ortsklang: Vögel, Grillen, Eule, Wolf, Wind ohne Entfernung und Baumbezug; Dorf stumm (Brunnen, Tor, Fackeln, Wäscheleine); Schritte ohne Wasser, Laub (D29.1, D29.2, Prüfbericht Lauf 30) | offen, Vorschlagsliste | – |

## Einzelheiten

- **Zu `WorldScreen.kt` (von Team Tom, 19.10., 02:4x, Absprache nach `CLAUDE.md` 6):** Tom setzt auf `claude/tom-d29-3-kleinleben` einen Block von 12 Zeilen direkt vor die Hühner (83b) für den Dorfhund (D29.3, Muster der Gasthauskatze); sonst nichts in der Datei. Kein offener Jerry-Zweig berührt die Datei. Einwand bitte als Zeile in Toms Vorrat; keine Arbeit für Jerry.
- **Zu 172** (Chef 18.10., Tester, sinngemäß): „Das Kampfsystem ist sehr langwierig. Wenn ich auf ein Monster zulaufe, will ich es angreifen: klick, klick, klick, klick, klick, und dann muss das erledigt sein. Wenn mich das Monster überrascht, will ich entweder weglaufen oder abwehren. Aber das sind ungefähr 2–3 Klicks, bevor ich überhaupt etwas machen kann.“ Stellungnahme Jerry: heute 2 Tipps je Schlag (Hauptmenü → Kämpfen → Angreifen). Vorschlag (a) „Angreifen“ direkt im Hauptmenü, (b) bei Überraschung sofort „Abwehren“/„Fliehen“, (c) Meldungen überspringbar. Gegenargument: weniger Wahl je Zug; darum (a) nur Abkürzung. Aufwand (a)+(b) ein Build.
- **Zu 130.2** (Vorgangsarchiv 130): Prüfpunkt „Gefühl“ (zwischen Absichten überlegt? Takt? Söldner?) an Sokrates. Chef zu Build 19: „meist dasselbe getippt, Takt okay“.
- **Zu 72.10a.8** (gebaut 18.10.): Grak „Durchbrechen“ (nur wenn hinten jemand gedeckt steht): stößt die vordere Figur nach hinten, trifft das Ziel vorn mit +1W6 und Ring; hart treffen vereitelt; Ziel selbst nach vorn → gewöhnlicher Schlag ohne Ring. Goblin „Flanke“: trifft die hintere Figur ohne Deckung; jeder Treffer vereitelt, Platzwechsel des Ziels lässt sie ins Leere laufen. Platztausch einmal je Zug, halber Zug. Nebenbefund: reines Angreifen gegen Grak (Kämpfer + Magier) 162 → 211 Siege von 400, weil Durchbrechen manchmal den Schweren Hieb ersetzt; Balance beim Chef (Prüfliste).
- **Zu 72.10a.9** (gebaut 18.10., nach Ideenpapier Homer): Kämpfer vorn: Taste „Decken“ (ganzer Zug) zieht alle angekündigten Schläge auf Freunde auf sich; Ring perfekt = Gegenschlag. Schurke: Finte aus der hinteren Reihe (vorn steht ein Freund) erreicht jeden Gegner ohne Deckung; perfekt = Schritt in den Rücken, nächster Schlag mit Vorteil (löst Hinterhältigen Angriff aus). Kleriker: Heilen über Reihen gab es schon; perfekt = Gebet, Heilung 1W6 (vorläufig). Magier: Fläche von hinten gab es schon (.3); Schild bleibt .2 „noch nicht“. Söldner auf Automatik bleibt bei „gut“, nie perfekt. **„Helfen“** (Ideenspeicher, mit abzuwägen): nicht gebaut; Decken gibt dem Söldner-Kämpfer schon eine eigene Wahl, eine fünfte Taste wäre die Gefahr „jede Klasse nur ein Knopf“ in breiter; nach Test 32 neu fragen.
- **Zu 72.10a.11** (gebaut 18.10., Ideenpapier Homer: „Wechseln geht zusammen mit einem Platztausch oder statt eines Angriffs“): jede Figur hat eine Zweitwaffe der anderen Art (Nahkampf/Fern): die beste passende aus der Tasche des Helden, sonst Armbrust oder Kurzbogen bzw. Kurzschwert, Dolch, Streitkolben, Kampfstab, was die Klasse kann. Wechsel = halber Zug wie der Platztausch (danach noch ein Schlag, also ohne Zugverlust) oder im selben halben Zug mit dem Tausch („hinten + Armbrust“); gewählt unter „Platz“. Bogen vorn hat schon Nachteil (.7), darum lohnt der Wechsel. Söldner auf Automatik, den Grak mit dem Bogen nach vorn stößt, greift zur Nahkampfwaffe. Offen: Schild bleibt am Arm, auch mit Zweihand-Bogen (Rüstung wechseln bleibt aus).
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
