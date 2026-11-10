# Prüfbericht Diogenes

Befunde von Diogenes (`ROLLE-PRUEFUNG.md`, Aufbau in `LISTE-PRUEFUNG.md` „Prüfbericht“). Seit 722 A (Chef 09.11.) ist jeder Befund der Klasse 1 und 2 ein Vorgang beim Besitzer („D<Lauf>.<n>“ im Titel); dessen Stand in der Vorgangsliste ist der Vermerk. Hier stehen nur die Wochenzählung, Offenes für den Chef und die Läufe der laufenden Woche; abgeschlossene Läufe ins [Prüfbericht-Archiv](PRUEFBERICHT-ARCHIV.md) (Lauf 22–39, 41; Lauf 40–91 in Git, `PRUEFBERICHT.md` bis `c82e31660`).

## Wochenzählung (QM, 106.1; nur Zahlen, Bewertung Perikles)

| Kennzahl | 02.–08.11. (gezählt 09.11., 08:1x) | 25.10.–01.11. (8 Tage, gezählt 02.11., 11:2x) | 18.–24.10. (gezählt 26.10., 00:5x) | Quelle |
|---|---|---|---|---|
| Kosten je Bereich (Liste) | 2871,10 $ Zuwachs (`1896fa543` → `0de9a3646`): E +2558,63 · B +219,52 · G +208,56 · M +27,10 · Q −34,67; die alten Buchstaben D, A, C, O, F (108,04 $) und 62 Zeilen (198,59 $) hat 686 neu eingeordnet, je Bereich daher nur ungefähr | 3841,36 $: E 2571,63 · B 1085,08 (davon Zeile „Betrieb“ 181,77) · M 56,36 · G 51,44 · Q 0; ohne Bereichsbuchstaben D 38,04, A 22,10, C 16,71 (`b17da0aea` → `2c67df6`) | 1703,90 $: B 789,02 (davon Zeile „Betrieb“ 564,16) · E 607,59 · G 171,54 · Q 92,36 · M 21,45; ohne Bereichsbuchstaben der Liste: D 10,33, A 5,50, O 4,85, F 1,26 | `LISTE-VORGAENGE.md` + `-ARCHIV.md`, `62ca83ee8` → `b17da0aea`; ein Teil kann vom 17.10. stammen |
| Anteil Muss | 94 % (M +2688,91 $); „–“ +118,44, K +37,94, M? +25,81 | 95 % (3630,52 $); ohne „Betrieb“ 99 %; K 3,80, „–“ 207,04 (davon Betrieb 181,77), M? 0 | 43 % (735,66 $); ohne „Betrieb“ 65 %; M? 114,67, K 125,71, „–“ 727,86 | Spalte „Kl.“ |
| Kosten je Rolle, Anteil Spiel | 3015,85 $ (207 Sitzungen, Erstelltag MEZ; 1 ohne Kosten: Homer 659): Tom mit Spike 1316 (44 %), Jerry mit Tuffy 867 (29 %), Sokrates 423 (14 %), Perikles 176 (6 %), Ford 121 (4 %), Diogenes 68 (2 %), Homer 44 (1 %); **Anteil Spiel 74 %**. Je Tag: 649 · 667 · 560 · 233 · 78 · 202 · 627. Kosten aus `KOSTEN-GEBUCHT.tsv` (203), `get_session` (3) | 3978,41 $ (424 Sitzungen, Starttag MEZ; 26 ohne Kosten, Tom 11, Jerry 15; 7 vom 25.10. nicht einzeln abgefragt): Tom mit Spike 1547 (39 %), Jerry mit Tuffy 1376 (35 %), Sokrates 573 (14 %), Perikles 173 (4 %), Ford 123 (3 %), Diogenes 121 (3 %), Homer 65 (2 %); **Anteil Spiel 75 %**. Je Tag: 744 · 616 · 846 · 747 · 172 · 0 (30.10.) · 152 · 701. `list_sessions` ohne `cost_usd`: Quelle `KOSTEN-GEBUCHT.tsv` und `get_session` | 1813,92 $ (370 Sitzungen, 20 ohne Kosten): Jerry 543 (30 %), Sokrates 489 (27 %), Tom 383 (21 %), Ford 156 (9 %), Perikles 118 (7 %), Homer 102 (6 %), Diogenes 23 (1 %); **Anteil Spiel 57 %** (Stufe 50 %) | `kosten.py`, Starttag der Sitzung |
| Guthaben Max | Woche 36 % (02.11., 07:33) → 53 % (03.11., 07:16) → 79 % (04.11., 07:11) → 82 % (04.11., 14:33) → 90 % (05.11., 07:07) → 95 % (06.11., 06:59); 100 %: fehlt; Zurücksetzung Sa 07.11., 20:00; neue Woche 10 % (08.11., 08:44), 08.11., 20:42 `allowed_warning` | Max 20x seit 25.10., ~11:00: Woche 0 % (25.10., 11:05) → 27 % (26.10., 11:43) → 51 % (27.10., 09:47); danach kein Bild bis zur Zurücksetzung 31.10., 20:00; neue Woche 13 % (01.11., 11:25); 80/95/100 % genau: fehlt | Woche 5 % (18.10.) → 41 % (20.10.) → 77 % (22.10., 12:45) → 94 % (23.10., 07:16) → 100 % 23.10., 10:1x; danach Credits 79,38 → 54,03 $ (24.10., 17:21); 80/95 % genau: fehlt | „Guthaben:“ in `ARBEIT-BETRIEB.md` (Git); Monatsangabe 4,31 → 248,62 $ passt nicht zum Rückgang 41,66 $ (Nachkauf nicht eingetragen) |
| Wochenziel / Meilenstein | Wochenziel 03.–08.11. „Kapitel 1 durchspielbar“ nein (496 Durchspiel-Build nicht gebaut); Stufen: 41 Punkte, 0 abgenommen, 4 gebaut, 6 in Arbeit, 31 offen | Wochenziel (Umzug Woche 1) nein: erledigt 348.8 (25.10.), 348.14 (26.10.); 348.6 zu testen, 348.7 ruht (Chef 31.10.), 348.9 wartet, 142 beim Chef; Stufen 1–6 (447, ab 01.11.): 0 von 36 Punkten abgehakt | Wochenziel nein (38 offen, 39 wartet; erledigt 13e, 112/68, 26); Pflicht Block (a) 3 von 4 offen; marktreif 5 von 6 Blöcken gelb | `LISTE-ABNAHME-KAPITEL1.md` |
| Testrunden Chef, Rückläufer | 5 Builds auf `main` (146, 204, 257, 269, 270); Testergebnisse im Archiv t257, t266, t268, t269, t270; 19 neue Testbitten in `ansehen/`; Rückläufer laut Feld 16 (269: 9, 270: 7; Feld nur bei diesen zwei); 107 Löschungen in `ansehen/` | CHANGELOG 9 Einträge: mit Gerätetest Build 89 (25.10.) und Test 132 (399); ohne Gerätetest 388 (Build 90), 142.1 ×2, 444, 447.3, 389; Godot-Testbuilds in Commits 130–146; 118 Löschungen in `ansehen/`; Rückläufer laut Feld 0 (nur 2 Felder: 89, 444) | 63 Builds (19–87) im CHANGELOG; Rückläufer laut Feld „Rückläufer:“ 6 (Build 81: 1, 82: 3, 83: 1, 84: 1; Feld erst ab 81); über alle Builds der Woche aus den Einträgen gezählt 66 (Tom 23, Jerry 43, Lauf 45) | `CHANGELOG.md`; 101 Löschungen in `ansehen/` |
| Ersparte Fragen (Vorentscheid) | 2, beide gebilligt: 576 (Sokrates, 04.11., 20:54), 621.1 (Perikles, 07.11., 20:45) | 13, alle gebilligt: 9 Nachturteile 26.10. (348.6, 348.7; gebilligt 11:14), 383.1 (27.10.), 461a, 461d (23:01), 348.12k (02.11., 11:08) | 3 (59e.1, 84.1T.1, 261.5), alle gebilligt | `VORGANGSARCHIV.md` |
| Stillstand | Protokoll 0 Zeilen; aus Git Lücken über 4 h ohne Commit: 05.11. 00:13–07:04 (6,9 h), 05.11. 22:07–06.11. 07:00 (8,9 h), 06.11. 13:07–21:23 (8,3 h), 06.11. 21:23–07.11. 13:04 (15,7 h), 08.11. 01:04–06:00 (4,9 h); in die Zeit fallen die Sparregeln 468c–468e (Guthaben), als Ursache nicht eingetragen | Protokoll 0 Zeilen; aus Git: kein Commit von 29.10., 11:58 bis 31.10., 20:4x (rund 57 h), 30.10. keine Sitzung; Ursache nicht eingetragen | Fehler: Homer 8,4 h (bis 18.10., 08:24); Guthaben: 0 Zeilen (ab 23.10. über Credits) | Protokoll `ARBEIT-BETRIEB.md` |
| „von Team“ an Homer > 1 Tag | 0 (586.1 seit 08.11., 22:17; 712 seit 09.11.) | 0 | 0 | `ARBEIT-KREATIV.md` |
| Empfehlungen Sokrates (17./18.10.) noch gültig | fehlt (nicht gezählt) | fehlt (nicht gezählt) | 11 von 13, 2 teilweise abgelöst (167 durch 192.4; 99h.6 durch 261.5) | `VORGANGSARCHIV.md` |
| Verwerfquote Diogenes | 0 von 34 (D63.1–D91.1) | 0 von 62 (D43.1–D62.2) | 0 von 49 (D26.1–D41.5), 2 teilweise (D29.1, D29.4) | Prüfbericht, Archiv |
| Erst der Chef am Gerät | 16 laut Feld (269, 270); Erstfunde t266 11, t268 11 (Lauf 76); in meinem Bereich 0 (485: erwartet höchstens 1) | 0 laut Feld; Chef-Erstfund 398 (28.10., 11:15: Ruhebewegungen fehlen, 15 Lücken) 1; weitere ohne Zählquelle: fehlt | 6 laut Feld, 66 über alle Builds (Rückläufer) | `CHANGELOG.md` |
| Perikles Z3 / Z4 / Z6 | Z3 1 (03.11., 07:54 Aufteilung der Arbeit auf Jerry); Z4 6 neue Dateien von Perikles (479, 512, 620.1, 620.4, 621.1, 688): 5 ja, 1 ja, aber (620.1: Sperre erst nach dem Aufräumen); Z6 nein, Muss 94 % | Z3 2 (25.10., 00:36 Hauskürzel; 07:55 Chefsache 361 trotz 287); Z4 11 neue Dateien von Perikles, davon 9 Vorschläge: 6 ja (270, 338b, 373a, 383.1, 396a, 461a über Sokrates), 1 „wie Sokrates“ (418), 1 anders (338a: B statt A), 1 zurückgezogen (361); Z6 nein, Muss 95 % | Z3 1 (23.10., 13e); Z4 14 neue Chefsache-Dateien: 11 ja, 1 ja, aber (186), 1 anders (287), 1 unklar (234); Z6 nein, Muss 43 % | `ARBEIT-PROJEKT.md`, `git log --diff-filter=A`; Zielvereinbarung erst seit 23.10. |
| Z5 Anteil Tom, Jerry, Homer | 74 % | 75 % | 57 % | wie Kosten je Rolle |
| Nächte Teams (371; Basis 27.10.: 207 $/9 h) | Kosten (Start 21–7 Uhr) 02./03. 104 $ · 03./04. 235 · 04./05. 4 · 05./06. 0 · 06./07. 0 · 07./08. 172 · 08./09. 53; Bilder und Filme an den Chef 3 · 13 · 3 · 0 · 0 · 0 · 5 | Kosten (Start 21–7 Uhr) 25./26. 184 $ · 26./27. 267 · 27./28. 203 · 28./29. 180 · 29./30. 0 · 30./31. 0 · 31./01. 101 · 01./02. 194; Bilder und Filme an den Chef 27./28. 28 · 28./29. 22 · 31./01. 12 · 01./02. 15, vorher fehlt | – | Sitzungen; `meldungen.tsv` (ab 27.10., 19:14) |
| Rote Läufe (464) | 19 von 971 abgeschlossenen (erst ab 04.11., 21:14; davor nicht abrufbar, die Schnittstelle gibt nur 1000 Läufe); je Tag 05.: 2 · 06.: 1 · 07.: 2 · 08.: 14; 18 davon „Godot (Umzug 348)“ | 02.11. bis 11:17: 11 von 175 abgeschlossenen (01.11.: 14) | – | `actions_list` |
| Widersprüche (461b) | 9 in 213 Archiveinträgen (60 mit Bezug zu einer DESIGN-Datei; D92.4) | 3 in 38 Archiveinträgen (02.11., 02:4x) | – | `ARBEIT-PRUEFUNG.md` „Zu 461b“ |
| Wochentermine gelaufen (485, nachgezählt 02.11., 19:4x) | Rollenspiegel Fr 06.11. nein · Ideenspeicher Homer So 08.11. nein (nur Einträge von Sokrates) · Wochenziel Perikles Mo 02.11. ja (03.11. neu nach 488) · Tagesbericht 6 von 7 (06.11. fehlt) · Stichprobe 374 (täglich bis 03.11.) 1 von 2 (02.11. erst 03.11., 15:2x) · Ford-Meldung 6–10 Uhr 2 von 7 (05.11., 08:25; 08.11., 09:07; laut `meldungen.tsv`) · Wochenzählung Mo 02.11. ja; Rollenspiegel und Tagesbericht fallen in 468a (Homer, Perikles nur auf Zuruf) | Rollenspiegel Fr 30.10. nein · Ideenspeicher Homer So 25.10. und 01.11. nein, nein (nur Einträge von Sokrates) · Wochenziel Perikles Mo 26.10. ja · Tagesbericht 448 ab 01.11. ja · Stichprobe 374 um 8 Uhr 28.10.–01.11.: 3 von 5 (30. und 31.10. erst 31.10., 21:37 nachgeholt) · Ford-Meldung 6–10 Uhr 28.10.–02.11.: 1 von 6 (29.10., 09:05) · Wochenzählung Diogenes Mo 26.10. ja | – | Git `main` (Datei je Termin), `meldungen.tsv` |
| Ohne Kopf (462) | 113 von 404 Texten (28 %) in 44 Summenzeilen (207 Sitzungen); Stempel daneben 8 von 201; Haken 63: 5 gehalten, 19 „Keine Chefsache“, 5 durch | fehlt: `zug-haken.py --summe` schrieb die Spalten von 462.1 nicht nach `LISTE-REGELTREUE.md` (D63.4, behoben 11:3x, ab 09.11. zählbar) | – | `LISTE-REGELTREUE.md` |
| Vorlagen an den Chef (374, 434) | 80 neue Dateien in `ansehen/` (61 Vorlagen, 19 Testbitten); mit Fassungsblatt oder „Geprüft an“ 76 von 80; Homer-Vorgabe genannt 2 (470, 557); Zeile „Bestand geprüft“ in Datei oder Vorrat bei 10 Vorgängen (2963, 490, 491, 493, 494, 507, 513, 525, 531, 558); ohne sie bei Eigenbauten: Tom 417, 431, 463, 475, 492, 499, 514, 656, 664, 623.6; Spike 501, 506, 613; Jerry 406, 406.2, 416.6, 453a, 509 (D92.2, D92.3); Prüferrunden je Vorlage: nicht gezählt | – | – | `chefsache/ansehen/` in Git, Vorräte und Liste der Woche |
| Warnungen Handänderung Liste (275 Stufe 2) | nicht zählbar: die Warnung der Commit-Prüfung wird nirgends festgehalten (D92.1) | – | – | `commit-pruefung.py` Zeile 195–201 |
| Wirkung 340.3–340.5 (340.2) | 340.3 nein: `notiz.sh` 09.11. 4 Hinweise (2 Vorratsgrößen, 77, 108; erwartet höchstens 2); 340.4 fehlt (Runden je Aussehensfrage nicht gezählt); 340.5 nein: 8 Stempel daneben (erwartet 0) | – | – | `notiz.sh`, `LISTE-REGELTREUE.md` |

## Offen für den Chef

**149 Probewoche Ford (Lauf 45):** Entscheidung über Ford: Aufwand „Niedrig“ oder stärkeres Modell. Grundlage sind die Zahlen von Lauf 45. Dort steht auch, dass am Sa 24.10. die Morgenmeldung ausfiel (Grund: Guthaben). (D4.1 am 26.10. ins Archiv, Lauf 23.)

## Offene Befunde als Vorgänge (723, 09.11., 09:5x)

Aus Lauf 59–92 noch offen, je ein Vorgang beim Besitzer: 725 D72, 726 D73, 727 D62.2, 729 D85.1, 730 D86.1, 731 D87.1, 732 D89.1, 733 D91.1, 734 D92.1, 735 D92.4 (Perikles), 742 D78.1 (Perikles); 736 D92.4 (Homer); 737 D92.2 (Tom); 738 D92.3 (Jerry); 739 D84.1, 740 D63.7 (Sokrates); 741 D61.1 (Ford); dazu schon bestehend D75 (Perikles). Geschlossen laut Nachprüfung oder Spur: D61.2, D62.1, D63.1–D63.6, D64.1, D65.1, D67.1, D68.1, D68.2, D69.1, D70.1, D71.1, D71.2, D74, D76.1, D76.2, D77.1, D77.2, D78.2, D79, D80.1–D80.7, D81.1, D81.2 (mit 275.2), D82, D83, D84, D84.2, D85, D86.2 (Hinweis an mich), D88.1 (685), D89, D90.1–D90.3 (686), D93.

## Lauf 126 · 838 Stichprobe START gegen Sitzungen (Chef 10.11., 10:4x; 10.11., 11:1x)

Zeitraum 09.11., 19:04 bis 10.11., 11:08 (ab da trägt `--sperre` jede START-Zeile als Startsperre „(lauf.py)“ ein); Quelle Protokoll `ARBEIT-BETRIEB.md` in Git gegen `list_sessions` (created_at, Berliner Zeit).
- **`lauf.py`-Starts:** 13 Läufe, 39 START-Rollen; 25 mit Sitzung binnen 2 Minuten, **14 ohne Sitzung (36 %)**, keiner mit `--ohne NR:Grund`. Mit Grund nur im Protokoll (Ford beurteilt selbst: Pacing, Kaufrepo, „auf Abruf“, alte Sitzung wartet): 01:04 Tom, Perikles, Tuffy · 02:06 Perikles, Spike, Tuffy · 07:04 Jerry (Weiter-Nachricht an alte Sitzung statt START), Perikles, Tuffy · 08:05 Jerry, Tuffy = 11. **Ohne jeden Grund:** 09.11., 22:44 Spike (Commit `6615704a2` nennt nur „Diogenes, Tuffy“) · 10.11., 10:25 Jerry (erst 10:32 auf Zuruf des Chefs), Perikles (erst 11:08) = 3. Fehler 341 nennt davon nur Jerry 07:04, 08:05, 10:26.
- **Fords eigene Startsperren** (Neustarts, „vor dem Start“): 39, jede mit Sitzung derselben Rolle binnen 2 Minuten; ohne Befund.
- **„keine Arbeit“:** Protokoll 09:07 „Keine Entwicklersitzung (826 A)“: 826 A (08:25) erlaubt eine Entwicklersitzung, gelaufen ist von 07:25 bis 10:26 keine (Jerry 59 Muss, Tom startbar); Bericht 10:32 „keine Arbeit“ schon in 341. Fords Chatberichte selbst nicht prüfbar (`meldungen.tsv` ohne Text).
- Befund D126.1 → 843 (Ford). Werkzeugseite liegt in 837 (Perikles); 838 wiederholen, sobald 837 gebaut ist.

## Lauf 127 · 837 Startprüfung `lauf.py` (Perikles, `ad5264185`) und 838 Stichprobe ab Bau (10.11., 11:5x)

- **837 greift.** `start_angekommen` an 7 Fällen: ohne Sitzung nein; neu nach der Sperre ja; neu bis 5 Minuten davor ja; alte Sitzung danach tätig (WEITER) ja; archivierte nein; andere Rolle nein; „Jerry 2“ zählt als Jerry. Ganzer Lauf in einer Kopie (`--ohne-pull`, echte Sitzungen 11:51): ohne Zusatz keine Warnung (kein Fehlalarm); erfundene Sperre 11:40 Perikles, Spike → je einmal WARNUNG-LAUT „Start … nicht angekommen“; Sperre 11:40 Tom ohne Tom-Sitzung → Warnung und START Tom im selben Lauf (Punkt 2: belegt nicht); Sperre 11:50 Tom → „Startmarke jünger als 20 Minuten“ (Prüfung erst ab 5 Minuten). Grenze: greift nur, wenn Ford mit `--sperre` läuft (`LISTE-BETRIEB.md` 4 schreibt es vor).
- **Stichprobe 11:08 bis 11:51:** `lauf.py`-START 11:08 Diogenes, Homer, Perikles, Tuffy und 11:48 Diogenes: alle mit Sitzung binnen 1 Minute; 11:27 Spike: `--ohne` mit Grund im Protokoll 11:30 (Spike-Sitzung idle, Wecker 11:57). Fords Neustarts 11:25 Sokrates, 11:28 Ford, 11:49 Sokrates: mit Sitzung. 6 von 6 ausgeführt oder begründet (Lauf 126: 25 von 39). Kein neuer Bericht „keine Arbeit“.
- Hinweis an Ford (Zu 843): die Sperre „11:27 Start Spike“ stand, obwohl 825 ausgeschlossen wurde (`--sperre` vor dem Entschluss zu `--ohne`); sie belegte Spike 20 Minuten und hätte ohne Tätigkeit der alten Sitzung ab 11:32 Fehlalarm gegeben. Erst `--ohne`, dann `--sperre`.
- 838 erledigt; die Stichprobe läuft künftig in der Wochenzählung (Vorrat).

## Lauf 130 · 848 Probelauf-Zähler ohne vorschau.env (Perikles, `f5adfa33f`; 10.11., 13:0x)

- `vorschau.yml` überspringt ohne `tools/preview/vorschau.env` mit Exit 0; Ausnahme in `loest_aus` passt dazu. Probe Wurzel ohne Datei → 0, mit Datei → 1.
- **D129.1 → 858 (Perikles, Muss):** Prüfung im Ordner des Aufrufs statt der Wurzel (Aufruf aus `core/` mit Datei → 0) und bei Push über den GitHub-Server gegen die Platte statt das Paket (Datei im Paket → 0). Ein echter Probelauf ginge ungezählt durch. 848 wartet auf 858.

## Lauf 128 · 832 Prüfliste nur Spielbares, Lizenzzeile hält an (Perikles, `f00ceec73`; 10.11., 11:5x)

- Regeltext `LISTE-CHECK-BUILD-TEST.md` 9 trägt den Chefwortlaut 09:29, „Im Bau geprüft“, Lizenzen nie als Prüfpunkt und „jeder Weg erreichbar“ (Helfer geht ihn im Build oder in der Vorschau, sonst Rückläufer); ohne Befund.
- `commit-pruefung.py` in einer Arbeitskopie mit vorgemerkter Probedatei `t999`: Zeile mit „Urheberzeile“ → HÄLT AN, Exit 1; Zeile ohne Lizenz → nichts. Gegen die alten Prüflisten t248–t273 hielte sie 248.4, 255.1, 269.1, 271.1, 273.1 an.
- **D127.1 → 846 (Perikles):** auch Zeilen, die das Menü „Lizenzen der Engine“ nur als Weg nennen, halten an (Probe 999.2; Vorbild 271.1: geprüft wurde das Titelbild). Vorschlag: nur Spalten „richtig“/„falsch“ prüfen, nicht den Weg. 832 wartet auf 846.

## Lauf 129 · 846 Lizenz-Stopp nur Richtig/Falsch (Perikles, `bda15e52f`; 10.11., 11:5x)

- Probe `t999` in Arbeitskopie: Urheberzeile in Richtig → HÄLT AN; „MIT-Text fehlt“ in Falsch → HÄLT AN; Weg über „Lizenzen der Engine“ → geht durch; Exit 1. **846 greift, 832 greift** (Lauf 129).
- Alte Prüflisten: 273.1 hält an (richtig); 271.1, 269.1, 255.1 halten weiter an, weil Richtig/Falsch den Menüeintrag „Lizenzen der Engine“ als Bedienelement nennt (Sichtprüfungen). **D128.1 → 847 (Perikles, Kür):** Namen des Eintrags ausnehmen.

## Lauf 125 · 800 Nachprüfung 813 (Perikles, `23064823b`; 10.11., 00:0x)

**Greift.** `regelcheck.py` (Z. 177) nimmt Pfade relativ zu `docs/` und `docs/chefsache/`; die drei Fehlalarme aus D123.1 (`kapitel2/STORY-K2-ENTWURF.md`, `kapitel2/STORY-PLAN-K2.md`, `chefsache/README.md`) sind weg. Übrige Meldungen „fehlende Datei“ sind echte tote Verweise aus der Zeit vor 800 (beantwortete Chefsachen, ruhende Vorräte), nicht Teil des Auftrags. 800 erledigt; der Absatz „Zu 800“ in `ARBEIT-PROJEKT.md` steht noch (Perikles räumt).

## Lauf 124 · 796 Nachprüfung 808, 809 (Perikles, `3ff660d26`; 09.11., 22:4x)

**Greift.** W5: CLAUDE.md Zusammenarbeit 3 hängt die Ausnahme an „Abläufe und Einzelheiten von Balance und Spielgefühl“, „Code auf `main`“ steht danach ohne Ausnahme; deckt sich mit `ROLLE-BERATUNG` 51, 52, 57. W3: `LISTE-GLOSSAR` 38 „wenn es kein startbares Muss hat, vor eigener Kür“; keine weitere Stelle mit „nichts Startbares“ als Übernahmebedingung (`lauf.py` 528 meint Kür-Rollen).

## Lauf 123 · 800 Notizen nach 650.2 (Perikles, `3a26195f2`; 09.11., 21:4x)

**Greift, eine Lücke.** A: vier Dateien in `alt/`; außerhalb der Archive verweist nichts mehr auf sie als geltend (`LISTE-PRUEFUNG` 60 „alte Zielkurve“, `STORY-REGELN` 27, `STORY-HANDBUCH-1` 6, Figurenkatalog 21 mit `alt/`-Pfad); CLAUDE.md „Bekannte Fehler“ nennt den Durchspielbogen nur als Anlass. B: `kapitel2/`-Verweise in `STORY-PLAN`, `STORY-REGELN`, `ARBEIT-KREATIV` tragen. C1: kein Werkzeug, keine Notiz nennt den alten Namen als Pfad, außer Verlauf (`DESIGN-BRS` 3, 457, 461 Zitate; `DESIGN-SPIELSYSTEM-2-0.md`) und Godot-Kommentar (811 Jerry); `regelcheck.py` liest `DESIGN-BRS.md`, Wächter 446 meldet die 26 alten Namen wie vorher; `sim444/sim.py` startet. E2: Inhaltsverzeichnis „Für den Chef“ mit acht Dateien, `inhalt.py` läuft in `notiz.sh` und findet zwei echte tote Links im Tagesbericht.
**D123.1 (813, Perikles):** `regelcheck.py` Verweisprüfung (Z. 169–181) kennt Pfade relativ zu `docs/` nicht: meldet `kapitel2/STORY-K2-ENTWURF.md`, `kapitel2/STORY-PLAN-K2.md` (neu durch B) und `chefsache/README.md` (alt) als fehlend, obwohl da; Fehlalarm in Fords Morgenlauf.
**Nicht geprüft:** tote Links aus der Zeit vor 800 (`LISTE-NIEDERLASSUNG.md`, `ARBEIT-ARCHIV.md`, `STORY-K2-HANDLUNG.md`/`-WELT.md` als geplante Dateien).

## Lauf 122 · 796 Regeln nach 783 W1–W8 (Perikles, `5e1541e63`; 09.11., 21:2x)

**Hat einen Ort, ohne Gegenstelle:** W1 (`LISTE-BAUEN-TESTEN` 4, `DESIGN-ABNAHME` 11, `ROLLE-ENTWICKLUNG` 49, Glossar, CLAUDE.md 9; `probelauf.py` ohne Filmsperre, `--probebild`/`--helfer` enden mit Hinweis, Laufgrenze 621 A bleibt), W2 (`LISTE-CHECK-BUILD-TEST` 3 und 10), W4 (`LISTE-RELEASE-NEUSTART` 1a, 3; Haken), W6 (CLAUDE.md 5), W7 (Wochenplan, `LISTE-BETRIEB` 10, `ROLLE-BETRIEB`, `lauf.py --morgen`, `tagesbericht.py` mit Bitte um das Bild), W8 (CLAUDE.md, `chefsache/README`).
**D122.1 (808, Perikles), W5:** CLAUDE.md Zusammenarbeit 3 „Nie selbst: … Spielgefühl, … Balance, …, Code auf `main` (außer Vorentscheid Sokrates, 783 W5)“: die Ausnahme hängt an „Code auf `main`“; `ROLLE-BERATUNG` 52 lässt „Code auf `main`“ beim Chef, W5 (Regel A in 783, Git `e3b05addb^`) meint Abläufe, Balance und Spielgefühl. Gegeneinander stehen damit CLAUDE.md und Rollendatei, und Sokrates' Vorentscheid zu Balance und Spielgefühl bleibt nach CLAUDE.md verboten.
**D122.2 (809, Perikles), W3:** `LISTE-GLOSSAR` 37 „Übernahme … wenn es nichts Startbares hat“ gegen W3 „kein startbares Muss, vor eigener Kür“ (`ROLLE-ENTWICKLUNG` 35, `startbar.py` 654).
**Ohne Vorgang:** `DESIGN-KAMPF` 9 „ein Verstoß hält den Lauf an (461a, 511, 621.1)“ ist schon in 735 (D92.4); `tools/regeltreue/stufe2/LISTE-REGELN.md` 57 nennt die Morgenmeldung, ist aber eine eingefrorene Probe (347), keine geltende Regel.
**Nicht geprüft:** W2-Frage nach 2 Tagen hat kein Werkzeug (Regel: wer es bemerkt); kein echter Morgen ohne Ford-Zeile.

## Lauf 121 · 799 Vorlagen nach 364 (Perikles, `55d798cc8`; 09.11., 21:1x)

**Greift.** Nachgestellt in einer Kopie von `main`: unvollständige Datei in `entscheiden/` hält `git commit`, `cd … && git push`, `git -C … commit` an (Exit 2, Meldung nennt die fehlenden Teile); auf einem Teamzweig frei; 758 (`65f56ef8a`) gilt als vollständig, ebenso der Altbestand 6238; `create_or_update_file` mit Muster ohne Nummer nach `billigen/` angehalten (fehlt Zeile 1, Umgesetzt, Rückbau, Kosten); ohne „Gegenargument“ gemeldet. Übersicht (`zug-index.py`) meldet die Datei unter „Lücken“. `MUSTER.md` deckt sich mit README 364 (dazu „Geprüft an“ nach 340.4, Kurz-Zeile).
**Hinweis, ohne Vorgang:** `push_files`/`create_or_update_file` halten auch auf Teamzweigen an, Bash nur auf `main`; folgenlos, weil Notizen nur auf `main` liegen. Von sieben gelöschten `billigen/`-Dateien aus Git hätten sechs nicht bestanden: der Haken trifft eine Gewohnheit, keinen Einzelfall.
**Nicht geprüft:** echter Lauf in einer anderen Sitzung.

## Lauf 120 · 650.2 Vorlage Notizen gliedern (Chef 09.11., 20:18; `071d56421`; 09.11., 20:2x)

**Hält:** 84 Dateien (81 .md, 1 .tsv, 2 .svg); A: Sammlung 2.0 „nichts freigegeben“, Heldenbau „überholt“, Balance „Stufe 20 Obergrenze“ gegen BRS „keine feste Höchststufe“ (Z. 110), Anleitung baut auf Kotlin, Figurenkatalog 649 „bis zum Bau“; C2 CC0 in Quellen beschlossen (6501); C6 Kampftexte stehen in `godot/regeln/mars_texte.gd`; Archivgrößen stimmen; Rechnung 84 → 66 geht auf. Votum Variante 2 trägt auch ohne den Fund unten: allein `LISTE-VORGAENGE` steht in 19 Werkzeugdateien.

**D120.1 (798, Sokrates), vor der Antwort berichtigen:**
1. Hauptargument gegen Variante 1 „allein die Vorräte haben 11–33 Verweise je Datei“ nicht nachvollziehbar: die Vorräte nennen zusammen je Datei 0–4 Mal (`LISTE-VORGAENGE` 4, `LISTE-CHECK-BUILD-TEST` 0); je Vorrat 8–16 Dateiverweise. Die Pfade hängen an Werkzeugen, nicht an Vorräten.
2. „Acht Dateien ohne Inhaltsverzeichnis“, genannt und tatsächlich neun. „Schritt 1: 9 Dateien in `docs/alt/`“: es liegen 11 dort.
3. `STORY-MENUE` (Kotlin, `MenuScreen.kt`) fehlt im Inhaltsverzeichnis und kommt in A–D nicht vor. `LISTE-BESTIARIUM` „geht in 649 auf“ (D), fehlt aber in A, und `tools/sim444/sim.py` liest es noch.
4. C1 BRS umbenennen: „16 Verweise (CLAUDE.md, Werkzeuge)“; es sind 17 Dateien außerhalb der Archive, darunter `tools/regelcheck.py` (liest den Pfad, Prüfung bricht sonst) und Code in `godot/regeln/brs_kampf.gd` (Kommentar; Godot gehört den Teams, nicht Perikles).
5. B nennt `STORY-K2-LANDKARTE` „mit SVG“, die zweite Datei `STORY-K2-KARTE.svg` fehlt.
6. Auswertung „C4–C6 kein Vorgang vor Kapitel 1“ gegen Folgerung „Homer bekommt C4–C6 als Kür“.

## Lauf 119 · 791 Überholtes und Doppeltes (Bereich B; `d12fb0f02`, `08a3ac60a`, `567b51c88`; 09.11., 20:1x)

- **Greift bis auf B16:** Stichproben am Wortlaut: B1 (Sperre mit 779), B2/O4 (Ford 2 nur noch als „entfällt“), B3, B10 (Build-Auslöser nur in CHECK 3), B13, P1–P4 (722 A, 719 A, 720 A in `LISTE-PRUEFUNG.md`), P11, P12 („Blatt“ nur noch im Zitat eines Fehlers), O1 (400 Tsd. weg), O2, O3 (nur noch „zu gleichen Teilen“, Schätzen bei fehlender Zahl), O8, O10 (Rollenspiegel Fr), O14 (341 fest seit 07.11.), O17. B16 hing an 783; seit 20:12 entschieden (W1), Angleichen in 796 (Perikles), daher 791 greift (20:2x); bewusst offen laut Zeile: P10, P14–P16, O13. Am Rande: Überschrift `ROLLE-PROJEKT.md`:90 „Ford-2-Lauf“ steht noch, mit Zusatz „entfällt“.

## Lauf 118 · 793 „Halt“ mit Wortende (Bereich B; `1346b89c2`; 09.11., 20:0x)

- **Greift:** Wächterregel in Kopie: „Haltung (des Helden)“, „Haltungen“, „haltbar“, „Haltestelle“ lösen nicht aus; „Halterung“, „Halt für Waffen“, „Haltepunkt“, „Halten der Waffe“ lösen aus. Damit Lücke von 788 (Lauf 116) zu, 788 greift.

## Lauf 117 · 792 Sperre ohne Allerweltswörter (Bereich B; `0c911a979`; 09.11., 20:0x)

- **Greift:** 762 und 753 frei; 784 nicht mehr über „jeden“, gesperrt jetzt über „Wolfsrudel“ gegen 679 (derselbe Kampf, Sache im Titel); 680 und 757 bleiben über den Ort „Schenke“ gegen 543 (so gewollt, Commit). Unter 26 Sperren (Tom 11, Jerry 15) keine mehr über ein Wort wie „jeden“ oder „design“. Grenzfälle ohne Befund: 764 über „Menü“ gegen 670, 536 über „Knopf“ gegen 679, 581, 521, 756 über „Ausrüstung“ gegen 522; Menü und Knopf sind Querschnitt 785 (788), Überschneidung im Code möglich.

## Lauf 116 · 788 Wiederholungswächter ohne Allerweltswörter (Bereich B; `994cc1f5f`; 09.11., 18:2x)

- **Greift mit Lücke:** in Kopie „Menü“ verweist auf 785, „Schwert“ still. **D116.1 (793, Perikles, Kür):** „Halt“ trifft jeden Wortanfang („Haltung des Helden“ → Zeile Systemlösung); belegt am echten Anlegen von 793, das selbst 794 auslöste (794 als Fehlalarm erledigt).

## Lauf 115 · 750 A Haken vor create_session (Bereich B; `cbb745d9d`; 09.11., 18:2x)

- **Greift:** Homer ohne Sperre → Exit 2 mit Hinweis, Ford und Sokrates mit Sperre der letzten 10 Minuten frei; seit 18:06 steht vor jedem Start im Protokoll eine Sperrzeile (18:09, 18:11, 18:17, 18:23, 18:24). Am Rande: Sokrates zweimal gestartet (18:17, 18:23), das hält der Haken nicht ab (Archivregel, Ford).

## Lauf 114 · 779 Sperre nur bei Überschneidung (Bereich B; `622fc78c1`; 09.11., 18:2x)

- **Greift mit Lücke:** Tom 9 startbar (vorher 0), Jerry 8 (vorher 2). **D114.1 (792, Perikles):** 5 von 27 Sperren ohne gleiches Thema, über Allerweltswörter: 762 Heldenreiter über „schwert“ (aus „Schwertarm“ in 656), 753 Blende „design“, 784 „jeden“, 680 Absturz und 757 Tisch über „schenke“ gegen 543 Startwerte. Liste der Allerweltswörter aus 788 könnte mitgelten.

## Lauf 113 · 790 Kosten vorher (Woche 02.11. bis 09.11., 18:00; 09.11., 18:2x)

222 abgeschlossene Sitzungen, 212 mit Kosten (10 ohne Feld `usage`), zusammen 3.083 $; Stichprobe zwei Sitzungen gegen `get_session` gleich. „je Aufruf“ geschätzt: Lesen aus dem Zwischenspeicher geteilt durch mittlere Länge ((Länge + 60 Tsd.) / 2). „Neuanlegen“: Anteil der Kosten für neu angelegten Zwischenspeicher (5 $ je Mio.; Preise an einer Sitzung nachgerechnet: 0,25 $ Lesen, 5 $ Anlegen, 15 $ Ausgabe je Mio.).

| Rolle | Sitzungen | Kosten $ | Median je Sitzung $ | je Aufruf $ | Median Länge Tsd. | größte Tsd. | $ je 1000 Ausgabe | Neuanlegen % |
|---|---|---|---|---|---|---|---|---|
| Tom | 72 | 1296 | 18,00 | 0,076 | 425 | 617 | 0,142 | 16 |
| Jerry | 48 | 822 | 16,18 | 0,077 | 413 | 717 | 0,146 | 15 |
| Sokrates | 21 | 470 | 20,95 | 0,084 | 407 | 743 | 0,164 | 20 |
| Perikles | 25 | 214 | 5,67 | 0,067 | 232 | 582 | 0,128 | 17 |
| Ford | 11 | 122 | 9,57 | 0,051 | 406 | 571 | 0,195 | 43 |
| Diogenes | 21 | 106 | 3,50 | 0,061 | 184 | 433 | 0,117 | 25 |
| Homer | 13 | 53 | 3,05 | 0,064 | 158 | 333 | 0,100 | 29 |
| alle | 212 | 3083 | 13,41 | 0,074 | 391 | 743 | 0,144 | 18 |

Nachher: Woche ab 09.11., 18:07 (`6a5ef0c1b`), Zählung 16.11. nach derselben Rechnung; Vergleichsmaß „$ je 1000 Ausgabe-Token“ (Kosten je Arbeit), daneben je Aufruf und Länge.

## Lauf 112 · 383 A Neustart ab 200 Tsd. (Bereich B; `6a5ef0c1b`; 09.11., 18:1x)

- **Greift:** Haken mit Probegespräch 199 Tsd. still, 210 Tsd. Erinnerung (Gesprächslänge, nicht Zuwachs); `lauf.py` WEITER nur unter 200 Tsd. und 60 Minuten Ruhe. Wirkung auf die Kosten misst 790 (Woche ab 09.11., 18:07 gegen die Woche davor).

## Lauf 111 · 783 Widersprüche und Doppelungen (09.11., 18:1x; drei Helfer, jede Stelle am Wortlaut nachgelesen)

**Ergebnis:** acht offene Widersprüche als Chefsache `entscheiden/783-widersprueche.md` (W1 = B5–B7, W2 = B9, W3 = B14, W4 = B12, W5 = P5–P6, W6 = P7, W7 = O5, W8 = O9). Alles Übrige an Perikles als 791 (745 A2 Schritt 3): B1–B4, B8, B10, B11, B13, B16; P1–P4, P8–P21 (P14 klein); O1 (ohne README), O2, O3 (Werkzeuge buchen verschieden, kein Chefentscheid), O4, O7, O8, O10–O15, O17, O18. **Verworfen nach Nachlesen:** O6 (Ford-Wache stimmt überein), O16 („sofort“ betrifft `send_message`), B15 (Release-Rückfrage verlangt die Datei), O1-Teil README:11 (383 nicht mehr offen). **Nicht geprüft:** `DESIGN-`, `STORY-`, übrige `LISTE-`.

Rohfunde:

Bauen/Testen (CLAUDE.md, ROLLE-ENTWICKLUNG, LISTE-BAUEN-TESTEN, LISTE-CHECK-BUILD-TEST, LISTE-RELEASE-NEUSTART):
- B1 überholt: BAUEN-TESTEN:30 Sperre 620.1 B ohne 779. B2 überholt: RELEASE-NEUSTART:22 „Ford 2“ (650.1 „kein Ford 2 mehr“). B3 überholt: ENTWICKLUNG:41 „Bildserie … gern als Film“ gegen :43, CLAUDE.md:69 „Bewegung nur als Film“ (646). B4 überholt: CHECK:17, ENTWICKLUNG:25 Abgleich je Build (621 D: je Ort und Figur; Nachweis 512b fehlt).
- B5 Widerspruch: BAUEN-TESTEN:15 „ersetzt die Ausnahme 461a, 480“ gegen ENTWICKLUNG:19, :43 (461a gilt, 621.1). B6 offen: BAUEN-TESTEN:15 Helfer prüft Probebild (511a) gegen 655 „Helfer danach entfällt“. B7 offen: BAUEN-TESTEN:15 „kaputter Film nur auf sein Wort“ gegen ENTWICKLUNG:43/621.1 „immer an den Chef“. B8: BAUEN-TESTEN:13–14 Prüftreppe Standbild/Film gegen 646 „Nachstellen nur zur Ursache“. B9 offen: CHECK:9 „unter 4, wenn ältester 2 Tage wartet (dann 3)“ gegen CHECK:19 „weniger nur auf jetzt“. B10: Build-Auslöser 6 (BAUEN-TESTEN:30) gegen 4 (CHECK:9), und 657 D „nur hier“. B11: ENTWICKLUNG:29, :39 Build-Regeln doppelt zu CHECK (657 D). B12 offen: CLAUDE.md:70 „Weiter in <Titel>: <Link>“ gegen RELEASE-NEUSTART:22, :24 „nur Name“. B13 überholt: RELEASE-NEUSTART:23 Sitzungsname ohne Doppelpunkt (436). B14 offen: ENTWICKLUNG:23 Übernahme vor Kür gegen :29 Übernahme erst ohne Startbares. B15: RELEASE-NEUSTART:7 Release-Rückfrage ohne Datei gegen CLAUDE.md 8. B16 Doppelung: „selbst ansehen, kein Helfer danach“ vierfach (CLAUDE.md:69, ENTWICKLUNG:19, :43, BAUEN-TESTEN:15). Klein doppelt: Weckruf, „gebaut nur bei PR“, kein Code auf main, 60 KB, `vorgang.py build` (Zeitpunkt weicht ab), Muss vor Kür.

Beratung/Prüfung/Kreativ (ROLLE-BERATUNG, -KREATIV, -PRUEFUNG, LISTE-PRUEFUNG, -REGELTREUE, -GLOSSAR):
- P1 überholt: LISTE-PRUEFUNG:37, :38, :44–45 Befunde als Vorratszeile, Vermerk im Prüfbericht (722 A). P2 überholt/offen: ROLLE-PRUEFUNG:26, :27, :33 Befund- und Abweichungszeilen in fremden Vorräten. P3 überholt: LISTE-PRUEFUNG:7 Wochenzählung als Vorratszeile (719 A). P4 überholt: LISTE-PRUEFUNG:13 ohne Teilhaken (720 A).
- P5 offen: BERATUNG:45 „Abläufe jeder Größe“ selbst entscheiden gegen :51 „Abläufe nicht (Perikles)“. P6 offen: BERATUNG:45 Vorentscheid Balance/Spielgefühl gegen CLAUDE.md:61, KREATIV:35 „nie selbst“. P7 offen: CLAUDE.md:16, :63 Chefwort sofort als Auftrag gegen BERATUNG:79, :82, :106, :113 erst Votum/Antwort, dann eintragen. P8: BERATUNG:8 und Rollentabelle „nur auf Zuruf“ gegen Systemrunde montags (654), nicht in 719. P9: BERATUNG:56, :103, PRUEFUNG:23 „Zeile in den Vorrat“ gegen CLAUDE.md 5 (Vorgang). P10 offen: KREATIV:15, LISTE-PRUEFUNG:17 Kennzahl aus Vorratszeilen statt Vorgangsliste. P11: BERATUNG:100 Uhrzeit mit `date` gegen CLAUDE.md:24 Zeile „Uhr:“.
- Begriffe: P12 „Blatt“ in PRUEFUNG:23, :27, :33, BERATUNG:41 (CLAUDE.md:90 verbietet; Ersatzwort fehlt). P13 offen: GLOSSAR:24 „Vorgang: ein Thema …, nicht: Thema“ gegen „<Vorgang>: <Thema>“ im Sitzungsnamen (113, 436). P14 offen: GLOSSAR:5 „Homer legt Begriffe fest“ gegen KREATIV:31.
- Doppelungen: P15 Telegram-Bildpflicht dreifach (277). P16 „fremd prüfen“ in drei Umfängen (CLAUDE.md:69, KREATIV:50, BERATUNG:92). P17 „kein Urteil über Aussehen“ vierfach, BERATUNG:41 ohne Ausnahme 373a. P18 „Notizen nur mit Edit“ in BERATUNG:105 ohne Ausnahmen. P19 Sitzungsname vierfach, PRUEFUNG:3 anderer Platzhalter. P20 Kennzahlen Perikles Z3–Z6 in PRUEFUNG:29 und LISTE-PRUEFUNG:11–19 ungleich. P21 D21.1 dreifach.

Betrieb/Projekt (ROLLE-BETRIEB, -PROJEKT, LISTE-BETRIEB, -WOCHENPLAN, -KOSTEN, chefsache/README):
- Überholt: O1 BETRIEB:51 WEITER bis 400 Tsd. (383 A, 18:05: 200 Tsd.); README:11 führt 383 noch offen. O2 PROJEKT:50 rote Läufe „Protokoll“ (776). O4 Ford 2: BETRIEB:15, :23, LISTE-BETRIEB:18, :20, :26, :36, PROJEKT:90 (650.1). O10 WOCHENPLAN:23–24 ohne 719 (Rollenspiegel Fr fehlt). O11 PROJEKT:4 Sitzungsname „338.1: Wochenziel“ (719). O12 WOCHENPLAN:11 Tagesbericht „Probe“ (448). O14 offen: PROJEKT:15 Zielvereinbarung 341, Probe bis 06.11. abgelaufen, keine Auswertung.
- Widerspruch: O3 offen: Kosten mehrerer Vorgänge „zu gleichen Teilen“ (LISTE-BETRIEB:26, LISTE-KOSTEN:103) gegen „ganze Summe auf den Hauptvorgang“ (BETRIEB:50); fehlende Zahl „fehlt“ gegen schätzen (Chef 03.11.). O5 offen: Morgenmeldung-Inhalt LISTE-BETRIEB:42, :32 gegen WOCHENPLAN:9 „eine Zeile“ (247, 448). O6 offen: Ford-Wache an Tom/Perikles (CLAUDE.md:91, WOCHENPLAN:10) gegen 166.2/81r. O7: BETRIEB:23 „Sokrates nie aus dem Vorrat“ gegen 194.2 (lauf.py startet ihn). O8 offen: LISTE-BETRIEB:39 Eingang „wartet auf Chef“ ohne Datei gegen CLAUDE.md:66, README:334. O9 offen: wer Chefsache löscht (CLAUDE.md:89 „jeder nur seine“ gegen README:333 „auch die eines anderen“). O13: PROJEKT:19 Tagesbericht „über Sonntag 50 h“ gegen täglich (448). O15 offen: „Anteil Spiel“ nach Rolle (PROJEKT:43) gegen nach Bereich E+G (LISTE-KOSTEN:36). O16: LISTE-BETRIEB:26 „sofort archivieren“ gegen BETRIEB:50 „idle und 60 s“.
- Doppelung: O17 Startregel dreifach (BETRIEB:23, :54, LISTE-BETRIEB:21) trotz „eine Startregel“ (167.8). O18 Ford-Mechanik zweifach (create_session-Felder, archiviert sich nie selbst, Routinen, ÜBERTRAGE/WEITER, Tagesbericht fehlt 10 Uhr, Abos 10.11.). Am Rande: LISTE-BETRIEB:38 Stand „im Vorrat und PROJEKTPLAN“ gegen CLAUDE.md (Vorgangsliste).

## Lauf 110 · Nachprüfung 775, 776, 777 (Bereich B; `fa6d61d82`, `3ad18ce80`; 09.11., 17:1x)

- **Greifen:** Prüflisten t269 28/28 Zeilen (37 Nummern), t270 13/13, t271 12/12; Ford-Regel 464 ohne Zeile je Lauf; Spike/Tuffy zählen bei Tom/Jerry (Sonst 0). 774, 749 damit geschlossen; 464 wartet auf die Wochenzählung 16.11.

## Lauf 109 · 755 Zustand nach „greift“ (Bereich B; `85e739f62`; 09.11., 16:1x)

- **Greift:** `vorgang.py greift` schloss 755, 748, 754 („erledigt, greift Lauf N“), lehnt 736 (Bereich E) ab; 774 wartet auf 775, 749 auf 776.

## Lauf 108 · 749 Tagesbericht rote Läufe (Bereich B; `8a4abf110`; 09.11., 16:0x)

- **Greift** (45 von 183 in 7 Tagen). **D108.1 (776):** Ford-Regel 464 nicht nachgezogen. **D108.2 (777, Kür):** Spike-Zweige als „Sonst“.

## Lauf 107 · 748 Push nach rotem Lauf (Bereich B; `e74948f61`; 09.11., 16:0x)

- **Greift** in der Kopie (sechs Fälle); fängt nur Wiederholungen; Wirkung noch nicht messbar.

## Lauf 106 · 754 auf Abruf mit `--ohne` (Bereich B; `dd3baf1ba`; 09.11., 16:0x)

- **Greift** (Kopie: mit `--ohne` kein Start, ohne Start).

## Lauf 105 · 774 Sammelbuild nie verwaist (Bereich B; `ecebfb0c0`, `f9abe7cab`; 09.11., 16:0x)

- **Sammelbuild greift** (Kopie: einmal angelegt, trotz Sperre gestartet).
- **D105.1 (775, Perikles):** Prüflisten-Haken übersieht Zeilen mit mehreren Nummern oder Haken in der ersten Spalte (t269: 2 von 28 erkannt).

## Lauf 104 · 657 Checkliste Build und Test (Bereich B; `35e71a7c4`; 09.11., 14:1x)

- **Werkzeug greift** (t273 zeigt die Liste, t276 meldet Ablauf; Regeln nur an einem Ort). Auswertung der Probe (Erstfunde t272–t275) folgt nach Build 275.

## Lauf 103 · 719 Wochentermine als Muss (Bereich B; `7adf1cd1e`; 09.11., 14:1x)

- **Greift** (sieben gestellte Zeitpunkte wie erwartet); im Betrieb nur mit `lauf.py --sperre` (750).

## Lauf 102 · 718 Probe mit Enddatum (Bereich B; `798e70750`; 09.11., 14:1x)

- **Greift** in der Kopie (Rückfall, Warnung einmal am Tag). Im Betrieb nie ausgelöst, weil Ford ohne `lauf.py` startete (750).

## Lauf 101 · 724 Werkzeugvorgänge nach „greift“ (Bereich B; `83635415d`; 09.11., 14:1x)

- **Greift** (Zeilen kommen zu mir, frühere sechs erledigt).
- **D101.1 (755, Perikles):** kein Zustand nach „greift“, Zeile bleibt bei mir, Weiter-Haken läuft im Kreis.

## Lauf 100 · 654.1 Systemfrage und Wiederholungswächter (Bereich B; `36cff7b9d`; 09.11., 14:1x)

- **Greift.** 14 echte Zeilen „Systemlösung?“, je Stichwort eine; Regel in `ROLLE-ENTWICKLUNG.md`. „Prüfliste“ aus dem Titel fehlt (Chefentscheid verlangt sie nicht).

## Lauf 99 · 641 Nachfolger auf Abruf (Bereich B; `af1a4da5a`; 09.11., 14:1x)

- **Greift** (Kopie, Homer ohne Startbares: neu NICHTS, alt START).
- **D99.1 (754, Perikles, Kür):** mit `--ohne` ausgeschlossene Zeilen zählen für „auf Abruf“ weiter als startbar.

## Lauf 98 · 627 Push mit `commit -F -` (Bereich B; `4bcd30e87`; 09.11., 14:1x)

- **Greift.** Fünf Fälle in Wegwerf-Kopie, alle wie erwartet (Heredoc-Nachricht zählt, neuer Zweig gegen Abzweig von `origin/main`).
- Nicht geprüft: am echten Push eines Teams.

## Lauf 97 · 696 Bilder derselben Minute (Bereich B; `d5e584b7a`; 09.11., 14:1x)

- **Greift.** 656 (08.11., 20:57) und 492 (21:16): je zwei Dateien mit `-2`, Inhalt verschieden, je zwei eigene Links in `ansehen/`.

## Lauf 96 · 275 Vorgangsliste (Bereich B, 724; `e23a4ccb2`; 09.11., 14:1x)

- **Greift.** 507 Commits an der Liste nachgespielt: 4 neue Zeilen ohne Zähler (632–634, 641), alle vor 08.11., 09:18; Form, Prüfung und Nummern sauber. Lücke bleibt 734 (Warnungen nicht festgehalten).
- Nicht geprüft: Handänderungen am Stand (aus Git nicht unterscheidbar), Kopien außerhalb dieser Arbeitskopie.

## Lauf 95 · 464 Rote Läufe (Bereich B, 724; `fcf9ab215`; 09.11., 13:1x)

- **D95.1 (748, Perikles):** greift nicht. Woche 02.–08.11. 52 von 185 Bauläufen rot (28 %; 01.11. vor dem Haken 14 von 21), 08.11. 14 von 46. Ursache am 08.11.: Tests im CI-Schritt „Skripte pruefen“ (12) und „REEBOO-Gratisproben“ (2), keine Parsefehler (nachgestellt an `b243b8c52`); der Haken prüft nur Parsefehler.
- **D95.2 (749, Perikles):** Zählung fehlt: `tagesbericht.py` ohne rote Läufe, keine Zeile „von Ford (464)“ seit 02.11.; Zeile „Rot“ im Protokoll bei Ford (741).
- Nicht geprüft: welcher Test je Lauf scheiterte (volle Protokolle brauchen Anmeldung, Haken 621 A erlaubt einen Probelauf); Läufe vor 01.11.

## Lauf 94 · Nachprüfung 721 D93 (Doppelpack 421; `40265bd2d`; 09.11., 09:5x; Kopie mit gestellter Uhr 09.–20.11.)

- **Bestanden:** Mo–Do immer vergangener Freitag, belegt → Abbruch mit Hinweis auf den nächsten Freitag; Fr–So laufender Freitag; `pflegehinweis.py` deckungsgleich. Offen bleibt nur die Woche 06.11. (Daten, bei Perikles und dem Chef).

## Lauf 93 · Auftrag 721 Rollenspiegel-Woche (Doppelpack 421; `ef964402c`; 09.11., 09:1x; Kopie mit gestellter Uhr)

- **D93.1, D93.2 (an Perikles):** Titel nicht erfüllt (Antwort Mo–Do bei vollständiger Vorwoche weiter unter dem kommenden Freitag); Probe „Sokrates ohne Antwort in 06.11.“ nicht nachstellbar. Behoben `40265bd2d`, Lauf 94.

## Lauf 92 · Wochenzählung 02.–08.11. (QM; `main` `0de9a3646`; 09.11., 08:1x)

- **Gezählt:** Tabelle oben, dazu 374 und 434 der Woche, 461b, Nächte 371, rote Läufe 464, Wochentermine 485, 275 Stufe 2, Wirkung 340.3–340.5.
- **Befunde:** D92.1 → 734, D92.2 → 737, D92.3 → 738, D92.4 → 735 und 736 (Wortlaut im Titel; Einzelheiten in Git, `c82e31660`).
- **Wochentermine (485):** Ausfälle als Zeile an Homer (Ideenspeicher 08.11.), Perikles (Rollenspiegel 06.11., Tagesbericht 06.11., beide in 468a) und Ford (Meldung 6–10 Uhr an 5 von 7 Tagen nicht in `meldungen.tsv`).
- **Nicht geprüft:** Empfehlungen von Sokrates (Aufwand); Prüferrunden je Vorlage (374); Runden je Aussehensfrage (340.4); rote Läufe 02.–04.11. (Schnittstelle).

## Kosten

Je Lauf eine Zeile, neueste oben; ältere im Archiv.
