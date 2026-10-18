# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 8 KB (156.1).

**Übergabe (18.10., 21:36, Jerry):** 39: `main` in PR #107 eingemischt, Kerntests grün, nachgemessen (passt), Prüfliste im PR; wartet auf 38. 172 wartet weiter auf einen zweiten Punkt für den Sammelbuild. Nachfolger: Jerry, nächster startbarer Punkt, mit 172 in einen Build.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 172 | M | Kampf zu langwierig: Klicks bis zur ersten Aktion | gebaut (a)+(b): ein Tipp bis zum Schlag, Abwehr/Flucht sofort; wartet auf Sammelbuild; (c) Meldungen überspringen offen | `claude/jerry-172-kampf-schneller` |
| 130.2 | M | Prüfpunkt „Gefühl“ im Build mit 72.10a | wartet auf Sokrates (Antwort Söldner-Frage); in t20 gebaut, Test bestanden | – |
| 72.10a.7 | K | Reihe, Deckung, Platztausch, Rolle je Klasse, Zweitwaffe | .7 erledigt (Build 20 auf `main`); .8 .9 .11 offen | – |
| 168 | K | Kapitel 2: Garrick fest an der Seite, Söldner ab Kapitel 3 | bei Bau Kapitel 2 | – |
| 130.3 | K | MARS mit drei bis vier Gegnern, die verschiedene Antworten verlangen | gebaut im Kern (Wolf, Spinne, Späher), PR #112 mit 130.2a; offen: Zeichen-Zeile, Ringtext Spinne, Balance | `claude/jerry-130-3` |
| 72.10b | K | Grak-Probe: Stufe festlegen oder wählbar, Treffer sichtbar | offen; Balance entscheidet der Chef (130) | – |
| D23 | K | Diogenes Lauf 23: Tode Krogg, Magier und Kleriker | D23.1 entschieden: nichts ändern; D23.3 ruht, erst spielt der Chef (13.5/38h) | `claude/diogenes-d41-messung` |
| 24.6 | K | Kampferöffnung wartet + Herzschlag in der Blende | wartet auf 72 (24e: bis die Kampfbilder fertig sind) | – |
| 72u | K | Standbild Grak im Wald | Standbild fertig; offen: Nacht, Söldner | `claude/jerry-72u-standbild-grak` |
| 86 | K | Bewegung und Übersicht: Keuchen, Initiative, Rennen | Rest 86.11 mit 72b/38 offen (sonst auf `main`) | `claude/jerry-86-atem-rennen` |
| 38 | M | Balance: Kapitel 1 gemessen | ruht bis Kapitel 1 durchgespielt (13.5); Eichung 38h danach | – |
| 39 | M | Schwierigkeitsgrad im Menü | wartet auf 38 (Build nach 38, 39.1); PR #107 (Entwurf) aktuell mit main, nachgemessen 18.10. (passt), Prüfliste im PR | `claude/jerry-39-schwierigkeit` |
| D3 | K | Diogenes Lauf 3: Klänge, Monster, Regen, Wölfe | Rest 9.2 offen (sonst auf `main`) | `claude/jerry-d3-kampfgeheul` |
| 72.14 | K | Gefährte/Söldner/Begleiter in Spieltexten | Feuerball-Wortlaut bei Kreativ angefragt (16.10.); dann übernehmen | – |
| 59e | K | Händler: Vorrat je Laden | hängt an 39 | `claude/jerry-59e-haendlervorrat` |
| 19e | K | Beispiel für „Bewegungen unrund“ | ruht, bis dem Chef eines auffällt | – |
| 134.3 | K | Kurzer Ruf zum Zeichen 134.1 | nach 134.1 (Tom) | – |
| 140 | K | Monster-Geräusche Rest | nach der Pause; Hörproben zuerst | – |
| 141 | K | Klänge Rest | vorher nachsehen, was mit 18, D3, 119 erledigt ist; dann Hörproben | – |
| 27o | K | Höhlenschacht nachts als Mondlicht (D3.14, von Team Tom) | offen; Lichtfleck `MapLight` (SKYLIGHT, CAVE_EXIT) und Säule `drawCaveShaft`/Leuchtkreis in `WorldScreen.kt` sind fest tagweiß | – |

## Einzelheiten

- **Zu 172** (Chef 18.10., Tester, sinngemäß): „Das Kampfsystem ist sehr langwierig. Wenn ich auf ein Monster zulaufe, will ich es angreifen: klick, klick, klick, klick, klick, und dann muss das erledigt sein. Wenn mich das Monster überrascht, will ich entweder weglaufen oder abwehren. Aber das sind ungefähr 2–3 Klicks, bevor ich überhaupt etwas machen kann.“ Stellungnahme Jerry: heute 2 Tipps je Schlag (Hauptmenü → Kämpfen → Angreifen). Vorschlag (a) „Angreifen“ direkt im Hauptmenü, (b) bei Überraschung sofort „Abwehren“/„Fliehen“, (c) Meldungen überspringbar. Gegenargument: weniger Wahl je Zug; darum (a) nur Abkürzung. Aufwand (a)+(b) ein Build.
- **Zu 130.2** (Vorgangsarchiv 130): Prüfpunkt „Gefühl“ (zwischen Absichten überlegt? Takt? Söldner?) an Sokrates. Chef zu Build 19: „meist dasselbe getippt, Takt okay“.
- **Zu 72.10a.7** (Homer): .8 Absichten gegen die Aufstellung, Platztausch halber Zug; .9 Rolle und Reaktion je Klasse; .11 Zweitwaffe ohne Zugverlust. Texte bei Homer.
- **Zu 168** (Vorgangsarchiv 168): Kapitel 2 Garrick fest (kein Ablehnen, kein Anheuern), Söldner ab Kapitel 3; fällt Garrick, nur kurzer Ausfall statt 72.8; MARS-Probe behält den Söldner.
- **Zu 130.3** (Vorgangsarchiv 130): keine Absicht immer richtig (Grak: Abwarten; Wölfe: Platz; Spinne: Angreifen). Texte `STORY-SPIEL.md` „Gegner mit Absichten“, Marken `[130.3.…]`; Name bleibt „Goblin-Späher“; Platztausch „{0} tauscht den Platz.“
- **Zu 72.10b** (Chef 17.10., 15:1x, an Sokrates): „… dass das nicht immer Probe heißt … irgendwer sollte ja dazu noch eine kleine Anleitung schreiben, wie das überhaupt funktioniert. Aber wir sind da deutlich zu wenig Optionen. Und ich habe bis jetzt jeden Kampf verloren, egal welchen, weil ich nie treffe.“ Befund: `grakProbe` nimmt den Helden jeder Stufe gegen Grak (RK 16); Stufe 1 trifft nur mit 11+.
- **Zu D23:** D23.3 Magier und Kleriker sterben oft; ruht bis 38h.
- **Zu 72u** (Chef „72u B“): Kampfort aus der Karte, Zoom 8 (`KAMPFORT=forest:7:14:8,12`); vor dem Bau zweites Standbild mit Menü, Absicht, Ring, Nacht, Söldner (Chefsache ansehen).
- **Zu 86:** 86.11 mit 72b/38; Rennen-Abstand `Stamina.RUN_NOISE` im Test eichen; Kampfzeile „außer Atem“ bräuchte Text von Kreativ.
- **Zu 38:** Ziel zielstrebig Stufe 2–3, Median höchstens 3 Tode (`ChapterSimTest.chapterOneGold`).
- **Zu 39:** Faktor Leicht ×0,8, Schwer ×1,2 (39.1 A); Wortlaut `STORY-BLENDE.md` „Einstellungen“, Marken `[39.2.…]`, eingebaut. Nachmessung 18.10. (Kämpfe unter 90 % auf Normal): Normal 78, Leicht +14, Schwer −18 Sieg-Punkte, im Ziel. Nach 38: main einmischen, einmal neu messen, Build, Prüfliste aus PR #107 in die Chefsache.
- **Zu D3:** 9.2 Regen im Kampf still: prüfen und dem Chef begründen (Chef 16.10.).
- **Zu 59e:** Menge nach Schwierigkeitsgrad (Beschluss 59e); Thessas Ausrüstung wechselt heute alle 8 Siege; 59e.1/59e.2 bei Kreativ.
- **Zu 134.3** (Chef 17.10.): kurzer Ruf (Pfiff, „He!“; CC0) bei Leuten mit Neuem.
- **Zu 140:** Knurren, Schmerz- und Todeslaute, Klappern, Stöhnen, Schmatzen, Kreischen, Kampfrufe, Brüllen; Elite und Grimmzahn tiefer.
- **Zu 141:** Menü-Klick, Belohnungen, Welt (Tür, Begegnung, Alarm, Hinterhalt), Zauber, Tränke, Kampfende, Umgebung.
