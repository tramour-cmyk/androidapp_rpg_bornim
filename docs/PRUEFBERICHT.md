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

## Lauf 180 · 981 Aufwand Hoch in START (Perikles, Doppelpack 421, `aff3a9af1`; 11.11., 18:1x)

- **981 greift in `lauf.py`, mit Lücke außerhalb:** diese Sitzung (von Ford 18:10 gestartet) zeigt in `get_session` `effort_level` „high“. `aufwand()` im Klon: 14.11., 19:59 „ | effort high“ und Umgebung Hoch; 14.11., 20:00 leer und Umgebung Mittel. Alle vier START-Stellen und beide TAGESBERICHT-Stellen tragen das Feld; kein anderes Werkzeug zerlegt START-Zeilen nach Feldposition (`lauf.py` 683, 691, 729 suchen nur Anfang und Muster). Wortlaut 365a B (Archiv 11.11., 07:18: „starten alle Rollen mit Hoch“) und Chef 18:04 („alle auf hoch“) gedeckt.
- **D180.1 (Klasse 2, Perikles, Vorgang 982):** Starts ohne START-Zeile bekommen kein `effort`: Neustart über Ford (`LISTE-BETRIEB.md` 38 → `LISTE-RELEASE-NEUSTART.md` „Neustart“ 2), Notfall-Neustart (dort 2: „Umgebung und `model` nach Startzuordnung“) und Selbstneustart Ford (`LISTE-BETRIEB.md` 61). Startzuordnung (45) sagt „Aufwand aus der START-Zeile“, die es dort nicht gibt. Ford gibt es seit 18:07 von Hand mit, laut Protokoll aber nur, „bis lauf.py es selbst ausgibt“. Fords eigene Sitzung (Chef 09:32) läuft auf `effort_level` „medium“ bei Umgebung Hoch. 981 wartet auf 982.
- Nicht geprüft: Lauf nach 14.11., 20:00 in echt (nur im Klon); TAGESBERICHT-Start in echt (nächster 12.11., 7:30).

## Lauf 179 · 978 und 979 Wächter 870.11 (Perikles, Doppelpack 421, `8983b9977`, `a14598da6`; 11.11., 17:2x)

- **978 greift** (`greift 978 179`): Hash der kompakten Form (gleich `karten.py kanon`) beider Dateien in Spikes echtem Commit `33f22e953` gleich `BESTAND_870_9`. Probe im Klon: beide neu angelegt Exit 0; andere Einrückung, gleicher Inhalt Exit 0; neu angelegt mit Zusatzzeile hält an; nach dem Einchecken eine Zeile „RK 14“ dazu hält an (nur „RK“), Zeile ohne SRD Exit 0.
- **979 greift** (`greift 979 179`): Merge mit Konflikt in `docs/`, SRD-Zeile aus dem anderen Elternteil Exit 0; neue SRD-Zeile beim Auflösen hält an (nur „ZP“); Konflikt in der Godot-Datei selbst, Lösung nimmt die Zeilen beider Seiten, Exit 0; gewöhnlicher Commit hält wie bisher an.
- Grenze ohne Folge: ein Merge ohne Konflikt läuft über `pre-merge-commit`, den `notiz.sh` nicht anlegt; den prüfte der Wächter auch vorher nie. Kein Vorgang.

## Lauf 178 · 970 mit 965 Sperre 779 (Perikles, Doppelpack 421, `4d1486e9f`; 11.11., 16:4x)

- **970 greift** (`greift 970 178`): eigene Dateien je Zweig gegen `git branch -r --contains` je Commit nachgerechnet: 705 nur `mars.gd` (2 eigene Commits, `kampf_ui.gd` weg), 709.1 nur `figur.gd` (Commit `8bbafbcb6` liegt auch auf `jerry-709a-tiefbiss`, zählt richtig nicht), 945 `kampf_ui.gd`. Namen: „greift“, „greifen“, „Lage“ keine, „Lager“, „Wolfes“, „Aldrics“, „Greifs“ ja. `--stand` 1,7 s (vorher 8,2 s).
- **965 greift** (`greift 965 178`), Lücke 970 geschlossen. Sperre 779 jetzt: Tom 9 startbar, 2 gesperrt (814, 831 → 680 `gebiet.gd`); Jerry 18 startbar, 14 gesperrt, alle mit echtem Grund (Nummer, Wolf, Grak, `figur.gd`). Über allem steht heute ohnehin Sperre 620.1 B (Tom 10, Jerry 20 ungetestet) bis zum Sammelbuild 968.
- Grenze: der laufende Sammelbuild heißt `claude/tom-968-sammel`, nicht `claude/build-…`, und wird nicht ausgenommen. Folgen heute keine (Abgleich mit und ohne ihn: nur 532 und 935, die darauf liegen); bekommt ein schon gemergter Zweig danach Commits, zählen seine älteren nicht mehr als eigen (zu wenig gesperrt, bis der Sammelbuild auf `main` ist). Kein Vorgang.

## Lauf 177 · 965 Sperre 779 (Perikles, Doppelpack 421, `7fc03538b`; 11.11., 15:5x)

- **Startbar:** `--stand` neu Tom 8, Jerry 20 (alte Fassung `7fc03538b~1` jetzt Tom 2, Jerry 0); greift.
- **Verbliebene Sperren 779:** Tom keine; Jerry 16. Nummer 8 (844, 845 → 709; 918 → 910; 932, 930.3 → 784; 935 → 870.6; 620.2c → 945; 950 → 863), Figur 3 (760, 931 Wolf; 949 Grak), Datei 5 (709.1, 705, 946 → 945 `kampf_ui.gd`; 406.2, 595 → 900 `figur.gd`). Nachgerechnet nur mit eigenen Commits: 406.2, 595, 709.1 überschneiden sich echt mit 910 (`figur.gd`); 705 und 946 nicht, beide sperrt aber „Wolf“. Ergebnis gleich, Begründung bei 705 und 709.1 falsch.
- **D177.1 → 970 (Perikles, K):** fremde Unterlage zählt als eigene Datei (`claude/jerry-870-5-kampf` nicht in der Unterlage; mehrere merge-bases bei 709.1); Namen treffen Verben („greift“, „greifen“ → Greif; „Lage“ → Lager). **965 wartet auf 970.**
- **Laufzeit:** nicht wie vorher: alt 5,4–5,9 s, neu 8,2–8,4 s (je zweimal); Hinweis in 970.

## Lauf 176 · 961 mit 943, 929 (Perikles, Doppelpack 421, `6135ffd31`; 11.11., 14:2x)

- **961 greift** (`greift 961 176`): 15 Fälle, `cd_ziel` und Hakeneingabe (Exit) neu gegen alt (`6135ffd31~1`). Heredoc-Körper beginnt mit `"`, danach `cd $W` → hält jetzt an (alt frei); Körper nur `"` → hält an (alt frei); drei Heredocs mit `"` vorn → hält an (alt frei); Körper mit `"` vorn und cd nur im Text → frei. Die acht Fälle aus Lauf 175 unverändert (1, 6, 7, 8 halten, 2–5 frei); `'` vorn im Körper, Backslash vor dem Ende, Heredoc in `'…'` halten an.
- **943 greift** (`greift 943 176`), Lücke 961 geschlossen; **929 greift** (`greift 929 176`), Lücke 943 geschlossen.
- Nicht geprüft: echter Lauf einer Teamsitzung mit Heredoc-Commit und `cd $VAR` (keiner seit dem Bau).

## Lauf 175 · 943 (Perikles, Doppelpack 421, `330744269`; 11.11., 14:1x)

- Acht Fälle als Hakeneingabe an `probelauf.py`, neu gegen alt (`330744269~1`): Heredoc mit einzelnem `"`, danach `cd $VAR` → hält jetzt an (alt nicht); dasselbe mit cd nur im Text → frei (alt hielt an); `-m` mit cd im Text, `-F` Heredoc, `cd "$HOME/…"` frei; echtes `cd $VAR`, Heredoc ohne Zeichen und danach `cd $VAR`, zwei Heredocs → halten an.
- **D175.1 → 961 (Perikles, K):** beginnt der Heredoc-Körper mit `"` (erstes Zeichen), bricht die Suche nach dem schließenden `"` dort ab, bevor der Sprung über den Körper greift (`text_bereiche`: Schleifenbedingung `befehl[j] != c` vor der Heredoc-Prüfung). Das `"` nach `)` öffnet dann neu, `&& cd $W && git push` gilt als Text: kein Halt (`text_bereiche` gibt (15, 29), (29, 36), (43, 64); `cd_befehle` leer). Selten, aber dieselbe Art wie D171.3. **943 wartet auf 961.**

## Lauf 174 · 942, 957 mit 927, 940 (Perikles, Doppelpack 421, `1bc93e6e5`, `74b3132b3`; 11.11., 14:1x)

- **942 greift** (`greift 942 174`): Kurzzeilen in einer Kopie (`--ohne-pull`): Jerry alt working 3 h ruhig, neu idle → nur ARCHIVIERE (vorher dazu WARNUNG-LAUT „Sitzung hängt“, alter Code nachgestellt); alte Sitzung als Vorgänger eines START → nur ARCHIVIERE; Diogenes allein hängend, nichts Startbares → WARNUNG-LAUT „Sitzung hängt“ bleibt. Grenze: die Marke „Hängt <Kennung>“ wird auch für die gestrichene Zeile geschrieben (harmlos, Sitzung ist weg).
- **927 greift** (`greift 927 174`): Lücken 941 (Lauf 172) und 942 geschlossen; echter Lauf mit „Sitzung hängt“ oder „Jetzt installieren“ steht aus (Vorrat).
- **957 greift** (`greift 957 174`): frische Kopie ohne eigenen Commit → Zählercommit mit Co-Authored-By und Claude-Session (Kennung gleich der Sitzung); ohne Umgebungskennung nur Co-Authored-By. Grenze: Co-Authored-By kommt dann aus dem jüngsten Commit auf `main` und kann ein anderes Modell nennen als das der Sitzung.
- **940 greift** (`greift 940 174`).

## Lauf 173 · 903 B (2) Checkliste „Vorlage an den Chef“ (Perikles, Doppelpack 421, `6f06ed112`; 11.11., 14:0x)

- **903 greift** (`greift 903 173`): deckt, was B nennt (Bild, Film, Chefsache, Antwort ins Archiv). Alle zehn Quellen tragen: 715 `ROLLE-PROJEKT.md` 107, 302.3 Bekannte Fehler, 457 und 890 `commit-pruefung.py`, 434 Rollendatei, 364 Archiv, 799 `probelauf.py` 865, Bildmaße `chefsache/README.md` 374, 655, 783 W1, W8, 338.2, 383.3, t78 im Archiv oder in `CLAUDE.md`. `treffer`: `entscheiden/`, `billigen/`, `tun/`, `ansehen/948-…` → Vorlage; `ansehen/t276-…` → Build und Test; README, `bilder/` → nichts. Zusatztext 2582 Zeichen, ganz.
- Grenze: der Abschnitt „Zum Kopieren“ erscheint nicht mehr von selbst bei `entscheiden/` (vorher ja); Punkt 4 verweist darauf.
- 905 wartet auf 16.11. (zählen, sobald etwa zehn Vorlagen da sind).

## Lauf 172 · 940, 941 (Perikles, Doppelpack 421, `2ac1ac48b`; 11.11., 14:0x)

- **941 greift** (`greift 941 172`): `warte_chef_nummern` an 14 Fällen: Merkmal in „…“, "…", `…` still; „653 … wartet auf Chef“ → 653; „506a wartet auf den Chef; 423 wartet auf Chefsache 857“ → 506a, 857; „72s.1“, „948 (Dolch)“, „948: …, wartet auf Chefsache 948a“ richtig; Datum davor gibt „?“ mit Satzteil (meldet trotzdem). Echte Vorräte 14:02: kein Treffer, richtig (keine Übergabe wartet auf den Chef). Grenze: Mehrzahl „948 und 949 warten auf Chef“ zählt nicht (auch vorher nicht).
- **940 im Nachbau dicht:** Bare-Kopie von `main`, drei Klone, drei gleichzeitige `neu` → 957, 958, 959; nach Commit, pull, push Zähler 960, ARBEIT-BETRIEB.md ohne Konflikt, `vorgang.py pruefen` ohne Fehler. Ohne Netz (origin fehlt): alter Weg, Zähler lokal. Gleicher Besitzer gleichzeitig: Mischkonflikt in LISTE-VORGAENGE.md (Zeilen an derselben Stelle), wie vor 940, nicht Teil von 940.
- **Echt 14:03:** meine Ziehung 957 legte `daccba151` „Zähler: 957 vergeben (Perikles, 940)“ auf origin/main.
- **D172.1 → 957 (Perikles, M?):** dieser Zählercommit hat keine Systemzeilen (Co-Authored-By, Claude-Session); `zaehler_pushen` nimmt sie nur aus einem eigenen Commit im Reflog, eine frische Sitzung hat keinen (Nachbau: mit eigenem Commit vorher kommen sie mit). CLAUDE.md „Commits mit den Systemzeilen“; die Kennung steht in `CLAUDE_CODE_REMOTE_SESSION_ID`. **940 wartet auf 957.**
- Nicht geprüft: echte Doppelziehung zweier Sitzungen auf GitHub (bisher keine seit dem Bau); Abweisung durch GitHub nur im Nachbau (lokales Bare-Repo).

## Lauf 171 · 927, 928, 929 mit 276, 725 (Perikles, Doppelpack 421, `a611dc8b3`, `d3ad958d7`, `82749deb1`; 11.11., 13:1x)

- **Echter Ford-Lauf:** 13:11 `NACHHALTEN` mit Marke „Nachhalten 11.11.“, 13:13 nicht wieder (einmal am Tag greift). 13:13 Marke „Übergabe-Chef Perikles 11.11. 13:12“ = Fehlalarm (Hinweis Ford).
- **D171.1 → 941 (Perikles, M?):** `neu_fuer_chef` sucht „wartet auf (den )?Chef“ in der ganzen Übergabezeile; Perikles' Übergabe nennt das Merkmal nur (Übergabe „wartet auf Chef“) und löste laut aus. Nachgestellt mit der echten Übergabe: Treffer. Die echten Fälle seit 25.10. haben die Form „<Nr> … wartet auf Chef“ (Tom 10.11., 13:57: 653; Homer 10.11., 13:13: 857; Homer 01.11.: 423); die Ausgabe gibt nur die ersten 200 Zeichen der Zeile, keine Nummer (Schritt 9 alt: „mit Nummer“). Vorschlag: nur außerhalb „…“ zählen, die Nummer davor in die Zeile.
- **D171.2 → 942 (Perikles):** gestellte Kurzzeilen (Jerry alt `working`, 3 Stunden ruhig; Jerry neu `idle`): derselbe Lauf gibt `ARCHIVIERE` und `WARNUNG-LAUT Sitzung hängt` für die alte Sitzung. Die Schleife lässt `archiviert` nicht aus.
- **928 greift** (`greift 928 171`): „Startzuordnung“ steht in `LISTE-BETRIEB.md` Zeile 43 unter „Bei Anlass“ (ab Zeile 24); Neustart 2 verweist dorthin.
- **276 greift** (`greift 276 171`): „Jeder Lauf“ nennt den Anlass jedes Schritts 6–11 (D162.1 Teil 1); 941, 942 sind Lücken von 927, nicht von 276.
- **D171.3 → 943 (Perikles):** `text_bereiche` an sechs Fällen: `-m "… cd $VAR …"`, `-F` Heredoc, `"$(cat <<'EOF' … cd $VAR …)"` laufen durch; echtes `cd $VAR` hält an; `cd "$HOME/…"` löst auf. Aber ein einzelnes `"` im Heredoc innerhalb `"$(cat <<'EOF' …)"`, danach `&& cd $VAR && git push`: Ziel cwd, kein Halt (die Paarung der Anführungszeichen zählt den Heredoc-Körper mit). Selten (deutsche Texte nehmen „…“), dann aber lautlos im falschen Ordner wie vor 725.
- **725 greift** (`greift 725 171`): `cd $VAR` hält an, Text-`cd` hält nicht mehr an; 943 ist Lücke von 929.
- **929 wartet auf 943**, **927 auf 941, 942.**
- Nicht geprüft: echter Lauf mit „Sitzung hängt“ und „Jetzt installieren“ (keiner seit dem Bau); nachts `WARNUNG` statt `WARNUNG-LAUT` nur im Code gelesen.

## Läufe 163–170 · Kür-Stau Perikles (725, 727, 730, 731, 732, 734, 735, 924; 11.11., 12:1x–12:2x)

Je Vorgang Probe gegen den Befund des alten Laufs; nichts davon in einem echten Lauf eines Teams gesehen.

- **163 · 725 greift mit Lücke** (`warte 725 929`). `cd "$HOME/…"`, `W=…; cd $W`, `export W=… && cd "${W}/…"`, `cd ~/…`, `git -C "$W"` lösen auf; `cd $W` ohne Zuweisung, `cd "$(…)"`, Backticks, Schleifenvariable halten an. **D163.1 → 929:** steht ein cd mit Variable nur als Text vor `git commit`/`git push` (Commit-Nachricht, Vorgangstitel, JSON in printf), hält der Haken ebenso an: nachgestellt mit `probelauf.py < f725.json` (Exit 2), zweimal live an eigenen Befehlen dieser Sitzung (printf mit Probe-JSON; `vorgang.py neu` mit dem Befundtitel).
- **164 · 727 greift** (`greift 727 164`). Mit JETZT 16.11., 07:10: „ab 16.11., 8 Uhr“, „ab 16.11., 08:00“, „16.11. 18:07 Uhr“, „16.11., 20 Uhr“ geben Datum mit Uhrzeit; um 09:00 die vergangenen None; „16.11., 12 Rollen“ None; am Vortag nur das Datum. Grenze: „16.11.: 8 Uhr“ (Doppelpunkt) wird nicht gelesen; kein Nachfolger nutzt diese Form.
- **165 · 730 greift** (`greift 730 165`). Auf `claude/build-276`: ohne Eingaben, nur `bild`/`film`, `kampf` leer → frei; `kampf=ja` über `actions_run_trigger`, `gh workflow run -f kampf=656`, API mit `inputs[kampf]` und mit JSON `dorf` → gezählt. Grenze: `leute=nein`, `kamin=nein` zählen, obwohl godot.yml nur „ja“ auswertet.
- **166 · 731 greift** (`greift 731 166`). Haken ist für `push_files|create_or_update_file` eingetragen. Teamzweig mit Spielcode ohne „Alt:“ hält an (auch einzelne Datei, auch Spike); mit „Alt:“, nur `godot/tests/`, `main` frei. Wie beim Weg über git zählt nur „Alt:“ am Zeilenanfang.
- **167 · 732 greift** (`greift 732 167`). Beide `git grep` mit `-e`; „-n“ findet 36 Dateien wörtlich, „-Bühne“ 0 ohne Fehler, „Kampfort“ 32.
- **168 · 734 greift** (`greift 734 168`). In einem Klon von Hand geänderte Liste: Warnung und Zeile `275 | ? | liste-hand | Kennung | Listenhash | main` (trocken, ohne Push). Grenze: Name aus `git config user.name`, auf allen Rollen gleich; die Rolle ist aus der Zeile nicht abzulesen, gezählt wird die Woche. Im Zweig `probelaeufe` noch keine Datei (keine Warnung seit dem Bau).
- **169 · 735 greift** (`greift 735 169`). Kopf `DESIGN-KAMPF.md` nennt die Prüfung vor dem Versand (783 W1) statt „Verstoß hält den Lauf an“; `DESIGN-ABNAHME.md` 11 war schon angeglichen. Für die Zählung 461b am 16.11.: die alten Archiveinträge 461a, 511, 621.1 tragen kein „→ ersetzt durch“, und 783 W1 im Archiv nennt nur „ersetzt 511, 578“.
- **170 · 924 greift** (`greift 924 170`). Klon auf `claude/jerry-909-x`, oben „831: Probe“ (Tom): mit Push-Ziel `claude/tom-831-x` 831, aus HEAD wie vorher 909.

## Lauf 162 · 276 Fords Anleitung auf eine Seite (Perikles, `cb73d5a6a`; 11.11., 12:1x)

- **276 greift mit Lücke** (`warte 276 927, 928`). Gegen die Empfehlung Sokrates (`LISTE-ABLAUF-274.md` „Ford“, `ad8e7e16c`): Startlektüre jetzt `ROLLE-BETRIEB.md` plus „Jeder Lauf“ 4531 Bytes (vorher die ganze Datei, heute 17484; Ziel war etwa 3 KB). Jede Ausgabezeile, die `lauf.py` schreibt (18 Arten), steht im Kopf; RÜCKMELDUNG ist nur Eingabe aus `regelcheck.py`. Abgleich alt/neu: jede gestrichene Stelle steht im Kopf von `lauf.py` oder unter „Bei Anlass“; Umgebung neu nach 901 (365a B) statt des überholten „Hoch nur auf Wort“.
- **D162.1 → 927:** Nachhalten (8, täglich ab 8 Uhr), Eingang (7) und laut melden „Jetzt installieren“, „wartet auf Chef“, „Sitzung hängt“ (9) haben keinen Anlass, den „Jeder Lauf“ nennt (dort nur Morgen 10 und Meldung 12; VORRAT-LEER kommt über den Kopf von `lauf.py`). Wer nur „Jeder Lauf“ liest, tut sie nicht. Teil 2 der Empfehlung (Urteilsaufgaben in `lauf.py` oder zu Perikles) ist nicht umgesetzt, sie sind nur verschoben.
- **D162.2 → 928:** `LISTE-RELEASE-NEUSTART.md` Neustart 2 verweist auf „Startzuordnung“ in `LISTE-BETRIEB.md` Schritt 4; sie steht jetzt unter „Bei Anlass“.
- Nicht geprüft: echter Ford-Lauf nach dem Bau (Ford-Sitzung nicht gelesen).

## Lauf 161 · 921 Nachfolger „auf Abruf“, M? entscheiden, Stellungnahme Sokrates (Perikles, Doppelpack 421, `ab6ad7ad1`; 11.11., 11:1x)

- **921 greift** (`greift 921 161`). Trockenlauf in einer Kopie (`--ohne-pull`, Stand `93fb3cc0d`, echte Übergabe Perikles „Nachfolger: Perikles – auf Abruf“, gestellte Datei `999-probe.md` ohne Stellungnahme, gestellte Kurzzeilen): (1) ohne Perikles-Sitzung START „Perikles – M? entscheiden (11.11., 11:18)“, Nachricht nennt 824, 836, 844, 845, 909 (Jerry) und 190.8; Perikles ruht 30 Min. → WEITER mit demselben Auftrag; ruht 80 Min. → START M? und ARCHIVIERE der alten. (2) Sokrates working, ruht 10 oder 40 Min. → WEITER; ruht 61 Min. → START und ARCHIVIERE der alten; ruht 61 Min. mit `--wecker` → WEITER; working oder ruht 10 Min. mit 300 Tsd. Token → NICHTS; ruht 61 Min. mit 300 Tsd. → START und ARCHIVIERE; ohne Sokrates-Sitzung → START. (3) `startbar.py` zeigt „M? für Perikles … 824 (Jerry), 836 (Jerry), 844 (Jerry), 845 (Jerry), 909 (Jerry)“.
- Grenze: fehlt `used_tokens` in Fords Kurzzeile, gilt eine laufende Sokrates-Sitzung als über 200 Tsd. (NICHTS, die Zeile sagt „oder unbekannt“). Kein echter Lauf mit M? oder Stellungnahme seit dem Bau (Lauf 11:15 startete nur Diogenes).

## Lauf 160 · 920 mit 911, 912 (Perikles, `8239e20ab`; 11.11., 10:0x)

- **920, 911, 912 greifen.** Skript Lauf 158 erneut: spike-581-ausruestung über Jerrys `44dec34a2` → 581, tuffy-784-sollbild über Toms `93173963c` → 784; alle Fälle aus Lauf 158 unverändert; eigener Verlauf auf spike-680-absturz → 680, tuffy-536-tips → 536, spike-581-ausruestung → 581. Kopf von `probelauf.py` nennt die Regel jetzt. Kein echter Handlauf mit Merge oben seit dem Bau (letzte Zeile 09:52); Blick darauf im Vorrat.

## Lauf 159 · 916 `lauf.py --wecker`, `--ohne` beim Zusatzentwickler (Perikles, Doppelpack 421, `0551bdb6b`; 11.11., 10:0x)

- **916 greift** (`greift 916 159`). Trockenlauf in einer Kopie (`--ohne-pull`, gestellte Kurzzeilen: Jerry working, Tuffy – 784 ruht 41 bzw. 92 Minuten, Perikles ruht 32 Minuten): ohne `--wecker` START Tuffy 784 und ARCHIVIERE der alten Sitzung; mit `--wecker` Tuffy „NICHTS Tuffy: belegt“, kein ARCHIVIERE, keine Buchung, auch nach 92 Minuten; mit Wecker auf Perikles kein Nachfolger-START, kein ARCHIVIERE, kein WEITER. `--ohne 784:Test`: AUSGESCHLOSSEN 784, Tuffy startet auf 910 statt 784. `LISTE-BETRIEB.md` 3 und 4 nennen `list_triggers` und `--wecker`.
- Grenze: eine Sitzung mit Wecker bleibt neben einer neueren derselben Rolle stehen; nach zwei Läufen meldet die Mehrfach-Prüfung laut. Kein echter Lauf mit `--wecker` seit dem Bau.

## Lauf 158 · 913, 914 mit 911, 912 (Perikles, Doppelpack 421, `da0a446d3`; 11.11., 10:0x)

- **913, 914 greifen** (`greift 913 158`, `greift 914 158`). Nachgestellt mit Merge-Commit oben (`commit-tree`, zweite Eltern origin/main) und `nr_aus_verlauf(REPO, sha, zweig)`: tom-870-4-held über `93173963c` → 870.4 (Fall 09:19), über Jerrys `44dec34a2` → 870.4 (D156.1), über den heutigen Stand (oben Jerrys 910) → 870.4; perikles-264-runner → 264.1, jerry-348-642-wolf-abstand → 642, jerry-717-rueckwaerts → 778, jerry-709a-tiefbiss → 709a. Handweg über `vorgang_aus_ref` an allen 640 Zweigen `claude/*`: Zweige mit Merge oben geben den eigenen Verlauf, obwohl `vorgaenge()` FETCH_HEAD auf main stellt (jerry-39-schwierigkeit → 62m statt Name 39); je Aufruf etwa 1 s.
- **D158.1 → 920 (Perikles), 911 und 912 warten darauf:** die Rolle kommt aus dem ersten Wort des Zweigs; `spike`, `tuffy` stehen nicht in `BESITZER`, Besitzer in der Liste sind nur Tom und Jerry, die Prüfung „fremde Rolle“ entfällt. Nachgestellt: spike-581-ausruestung über `44dec34a2` → 864 statt 581, tuffy-784-sollbild über `93173963c` → 870.4 statt 784. Beide Zweige laufen heute.
- Klasse 3: Kopf von `probelauf.py` (Zeile 15) nennt „Name bei fremder Rolle“ nicht; Push-Weg nimmt den Zweig aus `HEAD`, nicht aus dem Push-Ziel.
- Echter Handlauf mit Merge oben seit dem Bau: keiner (letzte Zeilen 09:52 806, 910, beide mit Nummer oben; 910 ist Jerrys Commit auf B1, zählt richtig unter 910).

## Lauf 157 · 912 Vorgang aus dem Zweignamen (Perikles, Doppelpack 421, `b945f7e2b`; 11.11., 09:3x)

- **912 greift für B1:** `nr_aus_zweigname('claude/tom-870-4-held')` = 870.4.
- **D157.1 → 913 (Perikles):** `nr_aus_zweigname` liest die Liste mit `zweig_lesen(…, "main")` (`git fetch origin main`) und verbiegt FETCH_HEAD; `vorgang_aus_ref` liest danach mit `nr_aus_verlauf(REPO, "FETCH_HEAD")` main statt des Zweigs. Nachgestellt: FETCH_HEAD `8bbafbcb6` (jerry-709a-tiefbiss) → `d44d730a5` (origin/main), Ergebnis None statt 709a; ein Handlauf auf einem Zweig ohne Nummer im Namen zählt wieder unter dem Zweignamen (911 kehrt zurück). Push-Weg (HEAD) nicht betroffen.
- **D157.2 → 914 (Perikles):** Name gegen eigenen Verlauf über 34 Zweige `claude/*` (ohne Sammelbuild): abweichend `perikles-264-runner` 264 / 264.1, `jerry-348-642-wolf-abstand` 348 / 642, `jerry-717-rueckwaerts` 717 / 778; der Name trägt oft die übergeordnete Nummer. Wirkt nur bei Merge oben; dann zählt etwa ein 264.1-Lauf unter 264, „264.1, Läufe frei“ greift nicht. Mein Hinweis „Zweigname“ (Zu 912) trägt das mit.
- **Nicht geprüft:** Push-Weg mit Ziel-Zweig im Refspec, der nicht HEAD ist (Name aus `rev-parse HEAD`).

## Lauf 156 · 911 Handlauf ohne Nummer oben, 264.1 Uhrzeit im Feld „wartet auf“ (Perikles, Doppelpack 421, `025dcf1bf`, `caf221f84`, `ee20ff5a8`; 11.11., 09:2x)

- **D156.1 → 912 (Perikles), 911 wartet darauf:** nachgestellt im Modul gegen `origin/claude/tom-870-4-held`: `nr_aus_verlauf(…, 93173963c)` = 870.4 (der Fall von 09:19 greift), aber der Zweig steht schon weiter: oben Toms Merge `e0c57e573` „Merge 864 und 904 (Jerry) in B1“, erste Eltern Jerrys `44dec34a2` „864: …“. `vorgang_aus_ref` gibt 864; der nächste B1-Lauf zählt unter Jerrys 864 (stand 0, wird verbraucht), nicht unter 870.4, das Sokrates 09:12/09:19 für diesen Lauf freigab. Reihenfolge Commit oben → eigener Commit → Name in Klammern → Zweig wie im Kopf von `probelauf.py`; kein echter Merge-Lauf seit 09:22 im Zweig `probelaeufe` (letzte Zeilen 09:20).
- **264.1 greift:** Probe in einer Klonkopie mit gestellter Zeile 264.1 und Uhrzeit heute 23:50: im Feld „wartet auf“ Exit 0; im Titel, im Stand, im Bereich je Exit 1 „Uhrzeit 23:50 liegt nach jetzt“. Spaltenfolge passt zum Listenkopf (Feld 6 = „wartet auf“); ohne Befund. Kopf von `commit-pruefung.py` nennt die Ausnahme nicht, kein Befund. 264.1 selbst bleibt offen (Runnerprobe).
- **Nicht geprüft:** Push-Weg mit veraltetem `origin/main` in der Arbeitskopie und ohne eigenen Commit mit Nummer (dann zählte ein Commit von `main` statt des Zweigs; nicht nachgestellt, selten).

## Lauf 155 · 907, 908 Halbsatz 324 und Checkliste beim Entwurf (Perikles, Doppelpack 421, `559dc33c7`; 11.11., 08:1x)

- **907 greift:** Punkt 3 trägt wieder „auch wenn der getestete noch nicht auf `main` ist (324)“, gleicher Sinn wie der Wortlaut in `ad191efb8` (Chef 22.10., 23:26). Archiv 324 bleibt kurz, sein Verweis auf `LISTE-BAUEN-TESTEN.md` führt über deren Zeile 26 zur Checkliste; ohne Befund.
- **908 greift:** Probe im Worktree von `origin/main` (`ef45c989c`): neue `docs/entwurf/t999-probe.md` zeigt alle 13 Punkte, Exit 0; neue `docs/entwurf/x999-probe.md` (ohne `t<n>-`) zeigt nichts. `--no-renames` (Zeile 229) lässt auch das Verschieben nach `ansehen/` als „A“ erscheinen; Kopf der Liste nennt beide Orte.
- **Nicht geprüft:** 903 (2) zweite Liste, 905.

## Lauf 154 · 903 B Checkliste fest (Perikles, Doppelpack 421, `fa1eb5a5f`; 11.11., 08:1x)

- **Punkt 3 alt gegen neu, Satz für Satz:** alle Regeln stehen noch (alle fertigen Punkte beider Teams, mindestens 4, ohne Obergrenze, 6 Testbuilds am Tag, unter 4 nur auf Ja/„jetzt“, 2-Tage-Frage `--laut`, eigene Zweige, `claude/build-<n>`, Prüfliste als Weg nach Orten, `vorgang.py build`, offener Build nimmt auf, getesteter ist zu, Konflikt, Sperre); „je Punkt Team und Vorgang“ trägt Punkt 10 (Spalten Team, Nr.). **Verloren:** „auch wenn der getestete noch nicht auf `main` ist“ (324, Chef 22.10., 23:26); Archiv 324 hat den Halbsatz nicht → **D154.1 = 907** (Perikles). Ohne Befund: „(beider Teams)“ beim Auslöser 4 fehlt, der Satz davor sagt es.
- **Archivverweise tragen:** 317 (Archiv Zeile 211, Wortlaut 07.11.), 783 W2 (111), 324 (704), 620.1 B (197, 198), 779 (123), 903 B (7).
- **Liste erscheint bei t276:** Probe im Worktree von `origin/main`: neue `docs/entwurf/t276-probe.md` zeigt nichts (Exit 0); Verschieben nach `chefsache/ansehen/` zeigt alle 13 Punkte mit den neuen Sätzen „Umbau überall“ (8) und „Einstieg wie beim Chef“ (9); `CHECK_BIS` und „abgelaufen“ sind weg, keine weitere Stelle nennt das Enddatum. **Lücke:** seit 866 verschiebt der Gegenleser die Datei, also sieht nur er die Liste, nie das bauende Team → **D154.2 = 908** (Perikles; nicht durch 903 entstanden).
- **Nicht geprüft:** (2) zweite Liste (noch nicht gebaut), 905 (wartet auf 903).

## Lauf 153 · 901 Umgebung Hoch bis Sa, 902 Wächter (Perikles, `bdd36bbb1`, `efe942d38`; 11.11., 07:3x)

- **901 greift:** alle fünf START-Stellen in `lauf.py` nehmen `umgebung()`; Probe mit gestellter Uhr: 11.11., 07:30 und 14.11., 19:59 jede Rolle HOCH, 14.11., 20:00 jede MITTEL; sonst keine Umgebungskennung in den Werkzeugen.
- **902 greift:** der Wächter lässt Zeilen mit „gebaut“, „zu testen“ oder gefülltem „wartet auf“ aus (heute 870.6, 900, 854, 264, 264.1, 901). Hinweis ohne Befund: er liest das rohe Feld, nicht `startbar.offen_warte`; ein schon erfülltes „wartet auf“ schweigt bis zum nächsten Lauf, weil `loesen` (Zeile 748) nach dem Wächter (715) schreibt; höchstens eine Stunde später als nötig.

## Lauf 152 · 771 Probe 657 ausgewertet: Erstfunde des Chefs t272–t275 (11.11., 07:2x)

Quellen: Ergebnisse der Prüflisten `ansehen/t2xx-sammelbuild.md` in Git, Vorgangsarchiv, neue Vorgangsnummern im Testzeitraum (Commit-Zeit Berlin; Commits tragen teils UTC).

- **Grundlage aus 657 D mischt zwei Maße:** t266 11 und t268 11 sind neue Vorgänge aus dem Test ohne durchgefallene Prüfzeile (Lauf 76); 269 9 und 270 7 sind durchgefallene oder nicht prüfbare Prüfzeilen („Rückläufer“). Hier beide Maße für jeden Build:

| Build | Prüfzeilen | neue Vorgänge aus dem Test | durchgefallen oder nicht prüfbar | Wiederholfunde |
|---|---|---|---|---|
| t266 | – | 11 (Lauf 76) | – | – |
| t268 | – | 11 (Lauf 76) | – | 6 (Sokrates 620) |
| t269 | 28 | 9 oder 10 (664, 665, 668, 670, 677, 678, 679, 682, 697; 661 um 15:11 vor dem ersten Ergebnis 15:23) | 9 | 6 |
| t270 | 13 | 3 (701, 702, 709) | 7 | 7 |
| t272 | 10 | 0 | 0 | 1 (751) |
| t273 | 16 | 2 (832 Lizenzpunkt, 833 Knöpfe) | 7 (273.13; 6 nicht prüfbar) | 4 (Sokrates 620) |
| t274 | 18 | 9 (856, 857, 860, 861, 863, 864, 865, 867, 868) | 4 (274.2, .12, .14; .13 nicht prüfbar) | 3 (Sokrates 620) |
| t275 | 14 | 0 | 0 | 2 (868, 864) |

- **Ergebnis:** neue Vorgänge 0, 2, 9, 0 (zusammen 11) gegen 11, 11, 9 oder 10, 3 (34 oder 35); durchgefallene Zeilen 0, 7, 4, 0 (11) gegen 9, 7 bei 269 und 270 (16 in zwei Builds). Gegen die Zahlen aus 657 D (zusammen 38) liegt die Probe nach beiden Maßen bei 11.
- **Zugeordnet:** 867 und 868 zu t274 (Chef 13:48, nach „Test durch“ 13:34, am selben Build gesehen); 804–806 in t272 nicht gezählt (Wunsch zum Graspaket 21:12, kein Fund); 857 (Name) und 865 (Neustart im Test) gezählt, weil Lauf 76 jeden neuen Vorgang aus dem Test zählte.
- **Befund D152.1 → 903 (Perikles):** Ergebnis vorlegen; der Chef entscheidet nach 657 D über weitere Listen und die Seite.
- **Nicht geprüft:** Ursache des Rückgangs (Checkliste, Gegenlesen der Prüflisten seit 866, Umfang der Builds); ob ein Lauf die Funde hätte finden können (Z3); Prüfzeilen t266 und t268.

## Lauf 151 · 893 bedingter Nachfolger (Perikles, `65d23431b`; 11.11., 03:2x)

- `nachfolger()` an 7 Übergaben in einer Kopie: „Tom – Sammelbuild 888 (wenn 709 und 506 fertig)“ und „…, Wenn 506 fertig“ → „bedingt“, Zeilenregel gilt; „„Tom – Sammelbuild 888“ (wenn …)“ verliert die Bedingung hinter dem Anführungszeichen, die neue Nummernsuche findet aber 888 und die Sperre der Zeile greift; „Tom – 870.4: Brunnen“, „Tom – Sammelbuild 888“, „keiner“ unverändert richtig. „Tom – Wochenziel 16.11.“ liefert Nummer „16.11“, harmlos (`titel_datum` greift vorher, keine Zeile 16.11). Kein Fall seit dem Bau im Protokoll (Tom-Starts 20:07, 21:05 hatten den Nachfolger „Testbitte 888“ ohne Bedingung). **893 greift** (Lauf 151).
- Zu 853: diese von Ford gestartete Sitzung trägt „Du bist Diogenes; der Auftrag in der ersten Nachricht kommt vom Betriebsleiter Ford“, `notiz.sh` nennt Diogenes in der Zentrale-Liste, Rolle ohne Rückfrage übernommen; ohne Befund.

## Lauf 150 · 896 Wächter und TP (Perikles, `de7ccc403`; 10.11., 23:1x)

- `srd_woerter()` geladen: „TP“ nicht mehr darin, „Trefferwürfel“, „Hauptattribut“ und die Alt-Spalte von `DESIGN-BRS.md` 12 weiter; Abschnitt 12 nennt keine TP als alt („Trefferpunkte … behalten ihre Namen“), `STORY-REGELN.md` 3 („deutsch ‚TP‘“) passt. Kein anderes Werkzeug führt TP als SRD. Lücke D150.1 → 898 (Perikles): `LISTE-UMZUG-BRS.md` Schritt 8 (Zeile 144) zählt TP weiter zu den SRD-Texten. 896 wartet auf 898.
- 898 (`3930a474b`): Schritt 8 nennt TP nicht mehr unter den SRD-Texten, mit Grund (DESIGN-BRS 12); Zeile 122 beschreibt nur alten Code. **898 greift, damit auch 896** (Lauf 150).

## Lauf 149 · 892 Übersicht bei Pause (Perikles, `1fd36745f`; 10.11., 17:4x)

- `startbar.py --md`: Kopf Tom „startbar 1 … frei für 870.x, 506, 470, 888“, Jerry „startbar 2 … frei für …“; 680 „Pause, nicht frei“, 506, 854, 709.1 „startbar“, Sperren wie 492 unverändert. `--stand` Tom startbar 1, gesperrt 104; Bildschirm und `--liegt` unverändert richtig. **892 greift, damit auch 889** (Lauf 149).

## Lauf 148 · 890, 891 Commit-Prüfung tun/ und ansehen/, LIEGT; 889, 870.17 (Perikles, `2f825ab1f`, `571549338`; 10.11., 17:4x)

- 890, Probe in einer Kopie von `origin/main`: Löschen von `entscheiden/854a-kaufcache-mischen.md` (Fassung vor `84d3f4897`, „**Was du tust:** (2) …“) ohne `tun/` hält an, mit neuer `tun/854a-token.md` oder `BORNIM_GETAN=1` nicht; „Was du tust: –“ hält nicht. `ansehen/663-touch.md` (Fassung vor `9fbc81d79`) hält an; mit Frage oder `![…](….webp)` nicht; „?“ nur in einem Link zählt nicht als Frage; `t280-…` ausgenommen. **890 greift** (Lauf 148).
- 891: `startbar.py --liegt` nennt Tom 506, Jerry 709.1, 854 und Diogenes-Zeilen; `vorgang.py warte 870.2 –` und `fertig 506` (dann 888 frei) geben „LIEGT … Start <Rolle> <Nr>“, Lesen und eine Rolle in Pause ohne „frei für“ (697) nicht. `lauf.py --liegt` mit ruhender Tom-Sitzung von vor 5 Minuten: ohne Schalter „belegt“, mit Schalter WEITER (ohne Nachfolger) bzw. START und ARCHIVIERE (mit Nachfolger). Echter Fall: `neu 892` meldete sofort LIEGT. **891 greift** (Lauf 148).
- 889: Bildschirm zeigt Tom „Muss 506“, Jerry „Muss 854“, Gesperrtes als „Pause, nicht frei“; **870.17 greift** (Lauf 148).
- **D148.1 → 892 (Perikles):** `startbar.py --md` (Übersicht in `chefsache/README.md`) zeigt bei Pause mit „frei für“ gesperrte Muss als „startbar“ (Tom 680), Kopf ohne „frei für“, „startbar 10“ zählt Gesperrtes mit. 889 wartet auf 892.
- **Nicht geprüft:** `lauf.py --liegt` gegen echte `list_sessions`; andere Wörter als „Was du tust“ für Schritte des Chefs (in der Chefsache bisher nur 854a); welche Schreibung 506 um 16:43 startbar machte (in Git nicht zu finden).

## Lauf 147 · 886 Wächter TP, Trefferwürfel, Hauptattribut, Bestandslauf (Perikles, `0d54c685e`; 10.11., 17:0x)

- Probe in einer Kopie von `origin/main`, neue Zeilen in `godot/skripte/rast.gd`: Warnung nennt „Armor Class, Hauptattribut, TP, Trefferwürfel, saving throw“; „HTTP STRAND“ fällt nicht (Wortgrenze). `--srd-bestand` über `godot/` ohne `tests/`: 276 Zeilen, Exit 1 (häufigste: TP 32, DEX 32, Kleriker 28, CON 28, STR 25, d20 23); das ist der Abbaustand für 870.13. **886 greift, damit auch 870.11** (Lauf 147).

## Lauf 146 · 883 und 870.17 Pausezeilen „frei für“ (Perikles, `3e2cba877`, `4a98e3327`; 10.11., 17:0x)

- Jerrys Pausezeile nennt 506.1, Toms nicht mehr; `pause_frei()` liest beide richtig (Klammer nach der Liste stört nicht). `lauf.stand()` gibt Tom 506, Jerry 854 und 709 als startbares Muss, sonst nichts; 870.x wartet auf 888 bzw. Vorgänger. **883 greift** (Lauf 146).
- **D146.1 → 889 (Perikles):** `startbar.py` (Bildschirm, `startbar.py` 709 `if not p`) zeigt bei Pause mit „frei für“ nur „PAUSE … frei für …“ und die Sperren, nie das freie startbare Muss (Tom 506, Jerry 709, 854 fehlen); Ford und `CLAUDE.md` „Zusammenarbeit 5“ lesen `startbar.py`. Starten tut `lauf.py`, das richtig rechnet. 870.17 wartet auf 889.
- **Nicht geprüft:** `--md`-Ausgabe (`startbar.py` 683) bei „frei für“.

## Lauf 145 · 881 Entwurf der Prüfliste, nie das eigene Team (Perikles, `5bd0f16c8`; 10.11., 16:2x)

- Weg steht in `LISTE-CHECK-BUILD-TEST.md` 8 (Entwurf `docs/entwurf/t<n>-….md`, Sitzung außerhalb des Teams, Zeile, verschieben). Probe in einer Kopie von `origin/main`: „# Tom ·“ mit „Gegengelesen: Spike“ und „# Tom und Jerry ·“ mit „Gegengelesen: Tuffy“ halten an; „# Tom ·“ mit Jerry und „# Jerry ·“ mit Sokrates gehen durch; Entwurf ohne Zeile unter `docs/entwurf/` geht durch. Zeile 1 der Prüflisten t271–t274 hat genau diese Form. **881 greift** (Lauf 145); 866 wartet auf nichts mehr (Bereich Q, schließt Perikles).

## Lauf 144 · 880 doppelte Vorgangsnummer (Perikles, `5f3cd4566`; 10.11., 16:2x)

- `vorgang.py neu` holt `origin/main` und zieht nie unter dessen Zähler oder eine dort belegte Nummer; echter Fall heute: fünf Ziehungen 882–886 nach 881, jede einmal, Zähler 887. Rest: ziehen zwei Sitzungen, bevor eine pushte, hilft weiter nur die Marke (653) als Mischkonflikt; darum sofort pushen wie vorgeschrieben. **880 greift** (Lauf 144).

## Lauf 143 · 879 Nachfolger-Strich mit Zusatz (Perikles, `7a1160881`; 10.11., 16:2x)

- `lauf.nachfolger()` an 6 Übergaben: „– Auf Abruf (768 …)“ → „Diogenes – Auf Abruf (…)“, „–, auf Abruf“ → „Diogenes – auf Abruf“, „— (auf Abruf)“ → „Diogenes – (auf Abruf)“, „–“ → keiner; echte Titel unverändert. Kein „– –“ mehr; die 641-Regel (`lauf.py` 553) prüft jetzt ohne Groß-/Kleinschreibung, „Auf Abruf“ startet nur bei Startbarem. **879 greift, damit auch 871** (Lauf 143).

## Lauf 142 · 877 Kerntest-Prüfung bei Code-Commits (Perikles, `4924cb6cd`; 10.11., 16:2x)

- Probe-Commit in einer Kopie von `origin/main` mit Änderung unter `core/src/main/`: ohne Marke Warnung „Code ohne grünen Kerntest …“; Marke jünger als die Änderung: keine Warnung. Die Prüfung erreicht Code-Commits wieder. **877 greift** (Lauf 142). Hinweis: Code unter `godot/` hat keine Kerntest-Prüfung; nach dem Ausstieg aus Kotlin gehört das zu 882.

## Lauf 141 · 870.11 Wächter SRD-Begriffe (Perikles, `4924cb6cd`; 10.11., 16:2x)

- Probe-Commit in einer Kopie von `origin/main`: neue Zeile in `godot/skripte/rast.gd` mit „RK“, „Halbork“, „TP“, „Trefferwürfel“ → Warnung „Halbork, RK (hält an, sobald 870.4 erledigt ist)“, Exit 0; Datei unter `godot/tests/` bleibt außen vor. Wortliste 47 Wörter: Spalte „Alt“ aus `DESIGN-BRS.md` 12 plus `SRD_DAZU` (`commit-pruefung.py` 187), wie im Vorgangstitel verlangt.
- **D140.5 → 886 (Perikles):** „TP“, „Trefferwürfel“, „Hauptattribut“ (Plan Schritt 8 zählt sie zu den SRD-Texten; 18 Spieltextzeilen in `godot/` mit „TP“) fängt er nicht. Für die Abnahme (870.13 „Wächter über den ganzen Godot-Code ohne Fund“) gibt es keinen Lauf über den Bestand, nur über neue Zeilen. Englische Zeilen ohne deutsches Gegenstück („Armor Class“, „saving throw“) fängt er auch nicht; heute stehen sie in derselben Zeile wie das deutsche Wort (`talente.gd` 121–145). 870.11 wartet auf 886.

## Lauf 140 · 870.18 zweites Gegenlesen Umzugsplan BRS (Sokrates, `LISTE-UMZUG-BRS.md` `220120cdc`, Vorgänge 870.2–870.17; 10.11., 16:2x)

Antwort auf „niet- und nagelfest?“: der Plan trägt, zwei Lücken halten aber Arbeit an (D140.1, D140.2). Urteilen tut nur der Chef.
- **D140.1 → 882 (Perikles):** Ganz aus Kotlin (Schritt 8, 870.9, 870.10) nennt nur `android.yml`. An `core/` hängen außerdem: Kerntests `tools/t logik` = `gradlew -p core test` (Pflicht laut CLAUDE.md „Jeder Schritt“, Marke `commit-pruefung.py` 175–183), `godot-kampf.yml` 41 (`exportIntro`), `vorschau.yml` 15–38 und `tools/preview` (Bilder „alt“ für 348.9, `vgl348.py` 1), `story.sh` 13 (Spieltexte aus `core/src/main/kotlin`), `probelauf.py` 74, 582, `setup-session.sh` 13, `startbar.py` 396, CLAUDE.md erster Absatz (Module). Ohne Ersatz gibt es nach Schritt 8 keinen Kerntest, der Haken warnt bei jedem Code-Commit. 870.10 wartet auf 882.
- **D140.2 → 883 (Perikles):** Pausezeile Jerry „frei für 870.x, 709, 854“ ohne 506.1; 506.1 gehört Jerry, steht aber in Toms Zeile. `startbar.py` 16:19 zeigt Jerry ohne 506.1; damit sind 506 („wartet auf 506.1“) und 870.3 („wartet auf 506“) bis 13.11., 20:00 gesperrt. 870.17 wartet auf 883.
- **D140.3 → 884 (Sokrates):** Lücken in „wartet auf“: 870.13 nimmt Lizenzhinweis und `aboutText` heraus, wartet aber nicht auf 870.15 (neuer `aboutText`, Handbuch); 870.2 (Schritt 2, „wartet auf 0“) wartet nicht auf 870.16; 870.16 nennt nur 4 Zweige, der Plan („Zweige für Schritt 0: Liste Lauf 134 (9)“) 27 weitere; 870a 8 (Kampftränke und Wurfmittel mit Schadensart; Spalte Schwäche/Stärke in den Regelwerten) steht in keinem Vorgang außer dem Kampfteil von 870.5 (870.3 Daten, 870.6 Gegenstände ohne).
- **D140.4 → 885 (Sokrates):** Plantext widerspricht sich: „17–24 Entwicklersitzungen“, Tabelle ergibt 19–29; Schritt 8 im Einzelnen „2 Sitzungen“, Tabelle 4–6; Risiken 5 noch „120–200 $“ und „Schritt 2–3 bis 14.11. allein“ gegen Guthabenzeile (beide zugleich); Kopf „Offene Regelfragen: Chefsache 870a“ und Schritt 1 „sieben Fragen“, 870a ist beantwortet und gelöscht; „mit 7 B eher 400–600 $“ steht unter „Diogenes rechnet“, gerechnet habe ich nur 350–500 $; Store-Kennung „Chefsache“ ohne Datei (gemeint wohl 622, ruht; Godot heute `de.bornim.game.godot`, `export_presets.cfg` 28).
- **Lauf 134 erledigt:** (1) Projektplan 2.3 ohne 212, Pechsträhne als Prozent; (3) Zielschuss und Decken bleiben Fähigkeiten (`DESIGN-BRS.md` 207); (6) Schritt 4 und 5 nur zusammen als B1 (870.4, 870.5); (7) Wanderer in 870.4, Zeile „Wanderer“ schon in `werte.json` 158; (8) Dateigrenzen im Abschnitt „Nach dem Gegenlesen“; (4) Hinweis erst nach `core/` raus. 870a 7 B und 8 A stehen in Archiv, `DESIGN-BRS.md` 208 und Bestiarium 42–46. Alle 13 genannten Zweige gibt es. 653, 663 warten nur auf den Test des Chefs.
- **Nicht geprüft:** Zeilennummern im Code seit Lauf 134 (709, 506 ändern dieselben Dateien weiter); 870.11 (Wächter) und 870.17 selbst über D140.2 hinaus.

## Lauf 139 · 866 Prüfliste nur gegengelesen (Perikles, `8c9f2dc3f`; 10.11., 15:1x)

- Commit-Prüfung in einer Kopie von `origin/main`, neue `ansehen/t999-probe.md`: ohne Zeile, „Gegengelesen: Sokrates“ ohne Zeit und Zeile mitten im Satz halten an; „Gegengelesen: Sokrates 10.11., 15:09“, „**Gegengelesen:** Perikles …“, „- Gegengelesen von Sokrates (…)“ gehen durch. Umbenennen fällt nicht durch (`--no-renames`).
- **Lücke D139.1 → 881 (Perikles):** kein Weg, wie der Entwurf vor dem ersten Commit zum Gegenleser kommt (bei t274 erst angelegt, dann nachgelesen); „Gegengelesen: Spike“ in Spikes eigenem Commit geht durch. 866 wartet auf 881.

## Lauf 138 · 849, 859 Letzte Antwort beim Nachfolger (Perikles, `66cb5632f`; 10.11., 15:0x)

- CLAUDE.md Zusammenarbeit 2 nennt „Letzte Antwort“ in der Startmeldung; `lauf.py` Startnachricht ebenso. Echter Fall diese Sitzung: Fords Startnachricht 14:59 war von Hand (Neustart-Meldung) ohne den Satz von 859, die Regel kam trotzdem über CLAUDE.md an. **849 und 859 greifen.** Hinweis an Ford: Startnachricht aus `lauf.py` übernehmen, nicht aus dem Gedächtnis.

## Lauf 137 · 848, 858 Probelauf ohne vorschau.env (Perikles, `f5adfa33f`, `cae2c5659`; 10.11., 15:0x)

- `loest_aus` in einer Kopie von `origin/main`, Kotlin-Push auf Arbeitszweig: Wurzel ohne Datei 0, mit Datei 1; Aufruf aus `core/` mit Datei 1, ohne 0; Paket mit `tools/preview/vorschau.env` bei leerer Platte 1; Pfade unbekannt ohne Datei 0. D129.1 behoben. **848 und 858 greifen.**

## Lauf 136 · 865 kein Neustart mitten im Test (Perikles, `611d9f7c1`; 10.11., 15:0x)

- `neustart-haken.pruefliste()` mit offener Prüfliste `ansehen/t274-…` an 17 Fällen, darunter die fünf echten Sätze des Chefs aus „Sokrates – 620: Lagebild nach Test t274“ (12:21–12:28: „Also Nummer 15.“, „Die Frage Nummer 16 …“, „Ansonsten passt Nummer 16.“, „Nummer 17 passt.“, Fledermäuse ohne Nummer nach „Nummer 16“): alle halten den Neustart an. Ohne Build im Verlauf, ohne Punktnennung oder mit Punkt älter als fünf Nachrichten: Neustart wie bisher. `LISTE-RELEASE-NEUSTART.md` Kopf nennt 812, 865. **865 greift.**
- Hinweis, kein Befund: „Build im Verlauf“ zählt jede Zeile mit der Zahl (auch „274 $“); dann bleibt der Neustart aus, wie der Chef es will. „16: Tür klemmt“ und „bei 16 klemmt“ erkennt der Haken nicht; beide Formen kamen am 10.11. nicht vor, bei einem Fall Vorgang an Perikles. Während eines Tests gibt es keine Obergrenze der Länge.

## Lauf 135 · 871 Nachfolger-Strich (Perikles, `902b41dfb`; 10.11., 15:0x)

- 18 Probeübergaben gegen `lauf.nachfolger()` (Stand `origin/main`): bloßer Strich in jeder Form („–“, „—“, „-“, „–.“, „**–**“, „„–““, „–; …“) und leerer Rest ergeben „keiner“; „Perikles auf Abruf“, „auf Abruf“ und echte Titel unverändert. **Lücke D135.1 → 879 (Perikles):** Strich mit Zusatz („– (auf Abruf)“, „–, auf Abruf“) ergibt weiter „Diogenes – – …“. Echter Fall: meine Übergabe 10.11., 13:0x (`caadf9ad6`) „Nachfolger: – Auf Abruf (768 am 13.11., …)“ → Titel „Diogenes – – Auf Abruf (…)“, und die 641-Regel `auf (Abruf|Zuruf)` greift wegen des großen „A“ nicht: gestartet, sobald etwas startbar ist. 871 wartet auf 879.

## Lauf 134 · 870.1 Umzugsplan BRS gegenlesen (Sokrates, `LISTE-UMZUG-BRS.md`, 870a; Code `399ce2cb1`, 10.11., 14:5x)

Kurzfassung an den Chef per Telegram 14:5x; hier die Einzelheiten. Drei Helfer haben die Zeilen nachgezählt (Befund und Schritt 4; Schritte 3, 5, 6; Zweige, Wächter, Lizenzhinweis). Urteilen tut nur der Chef.
- **Widersprüche:** (1) 870a Frage 2: 212 ist schon gestrichen (626 ja, 07.11., 21:10, „gekämpft wird nur noch im MARS“); Projektplan 2.3 nennt noch „212 A“, den klassischen Kampf und die Pechsträhne. (2) `pechstraehne.gd` wird gelöscht, ohne dass der Plan einen Ersatz nennt. (3) 3A gibt Zielschuss und Decken jedem Gesellen; `DESIGN-BRS.md` 5 führt beide als Fähigkeiten von Scharfschütze und Wächter. (4) Lizenzhinweis: Das Repo ist öffentlich, `core/` bleibt nach 7A; Schritt 9 streicht den Hinweis trotzdem aus `README.md` und `CLAUDE.md`. `aboutText` (`I18n.kt` 127–130) und Handbuch (`Guide.kt` 23–24 „Die Regeln folgen … SRD 5.1“, Anzeige `menue.gd` 1463/1639) sind dieselben Texte wie in der Kotlin-App. `regelcheck.py` 217–219 meldet einen Fehler, wenn der Hinweis fehlt, solange alte Namen da sind. (5) 870a Frage 7: Hochgeladen in den Play-Kanal wird nur von Hand (`android.yml` 99), gebaut wird die App bei jedem Push ohne Notizen.
- **Reihenfolge:** (6) Schritt 4 löscht `Heldwerte`; gelesen wird es auch von `beute.gd` (6), `spielstand.gd` (7), `aufruf.gd` `blatt()` 169–188, 199–203, 262–269 (5) und `spiel.gd` 109–110, 624, 631, 650, 656, 960. Allein auf `main` ist das nicht spielbar (Grundsatz 6). (7) Für den Wanderer (keine Herkunft) gibt es keine Quelle für Startvorrat, Tracht, Kapitelschirm und Probehelden. (8) Dateigrenzen: `regeln/brs_held.gd` und `regeln/talente.gd` gibt der Plan Tom; `skripte/beute.gd`, `spiel.gd` 620–657, `streuner.gd` 80 und `testmodus.gd` 85, 304–307, 409 gibt er Jerry. `kampf/figur.gd` 438–441 ruft `HeldFigur` mit der Klasse auf und muss darum mit Schritt 4 abgestimmt werden. (9) Zweige, Schritt 0: 854 ändert nichts unter `godot/`; `jerry-653-parade` ist schon gemergt; `tom-653-halt` berührt keine Umzugsdatei; `tom-brs-held` steckt ganz in `spike-470-erschaffung`, `tom-506-skelett` ganz in `tom-506-untote`. Nicht genannt, obwohl sie Umzugsdateien berühren: `spike-506-untote`, `build-494` (= `jerry-494-gegner`), `tom-6236-welt`, `build-274`, `tom-475-leute`, `jerry-806-kampfort`, `jerry-595-kaufgegner`, `tuffy-406-2-schild`, `jerry-717-rueckwaerts`, `tom-492-durchspiel`, `tom-531-film`, `jerry-507-hoehle`, `jerry-605-anlegen`, dazu ruhend aus der Zeit vom 01. bis 05.11.: `jerry-572-effekte`, `spike-458-3-staffel`, `spike-425-testmenue`, `tom-505-rand`, `tom-514-bild`, `spike-505-nebel`, `tom-567-abstand`, `jerry-577-kennung`, `tom-495-zufallsspieler`, `tom-531-garrick`, `spike-416-9-laden`, `tom-471-fertigkeiten`, `jerry-493-kampforte-gs`.
- **Schätzung:** Der Plan rechnet 120 bis 200 $ für 17 bis 24 Sitzungen, das sind 5 bis 12 $ je Sitzung. Tom kostete am 28.10. im Mittel 20,40 $, Jerry 22,43 $ je Sitzung; die Woche 02. bis 08.11. kostete 3016 $ in 207 Sitzungen. Vergleichbare Vorgänge: 470 43 $, 709 38 $, 506 85 $, 492 82 $, 505 69 $, 475 99 $. Daraus ergeben sich etwa 350 bis 500 $. Gebucht vom 07.11., 20:00 bis 10.11., 07:00 sind rund 1150 $ bei 43 % der Woche (der laufende Tag ist zu niedrig gebucht), also rund 13 bis 19 % einer Woche.
- **Fehlende Stellen:** `mars.gd` 125, 128 (Heilung von Gebet und Sammeln), 393–398 (`ist_krit` W20), 979–984 (`_cantrip_dice`), 1133 (Elf auf Flucht), 1146–1150 (Tränke mit Würfeln), 1160–1175 (Extra-Angriff, Zweiwaffenkampf), 1222–1224 und 1242–1243 (−2), 1287–1315 (Zustandsschaden mit Würfeln, Zwerg halbes Gift), 1713 (Leben gerufener Goblins gewürfelt), 1861 (Hinterhältiger Angriff im BRS-Weg); Grak-Heilung 1385 läuft im BRS 2W10 ohne Umrechnung; im BRS haben Gegner gar keine kritischen Treffer (`brs_kampf.gd` 148), Sonderwirkungen 1339–1350 laufen mit SRD-Rettungswurf. `brs_kampf.gd` 32–37 (Brücken FEUERPFEIL_SRD, PROZENT_JE_W20). `aufruf.gd` 154–165 (`ersatzwaffe` nach Klasse), 76–77. `kampf/probe.gd` 12–18, 53–56, 252–254, 1159, 1173; `strahlprobe.gd` 56–57; `kampf_ui.gd` 703 (Decken nur FIGHTER), 3, 477; `kampfort.gd` 159 (Initiative mit Nachteil), 967, 1236–1248 („SAVE“), 1295. `talente.gd` 32, 49, 61, 73, 87, 120, 125. Anzeigenamen „Stirge“, „Ockergallerte“ in `tabellen.json`. `erschaffung_brs.gd` 76, 84, 91, 166, 191–197, 207–209, 238–240, 389–390, 404–405, 447 (hängt selbst an `alt()` und `Heldwerte`); `heldfigur.gd` 174–176; `menue.gd` 205–216, 226, 251, 281–290; `leiste.gd` 175, 183–188, 209–210; Spieltexte `geschichte.gd` 115, 130, 217, `varianten.gd` 82, 92, 416, 422 (Homer); `testmodus.gd` 214, 305–306; `README.md` 39; Export `godot.yml` 358 (Kampfklang aus `core`).
- **Kleinere Fehler:** Goldtests 4, nicht 6; `brs.gd` 98–185 rufen zwei Tests auf, nicht einer; Helfer von `erschaffung.gd` stehen in 416–450 und werden von 14 Skripten und 3 Tests gelesen, nicht von etwa 10; `figur.gd` Knickwinkel steht in 2869, nicht in 869; `mars.gd` 326, `zustaende.gd` 19 und `brs_kampf.gd` 102 sind nur Kommentare, sie lesen `tabellen.json` nicht; die Datei schreibt `MarsGoldenTest.kt` 215; weitere Leser `probe.gd` 1173, `lohn.gd` 30, 42, 57, rund 25 Tests. „Alle Zauber außer Funkenpfeil“: auch Sengender Strahl geht über `_brs_zauber`. Wächter: `commit-pruefung.py` 187 stimmt; Nebenbefund: die Kerntest-Prüfung 301–307 erreicht `core` und `app` nie mehr.
- **Stimmt:** übrige Zeilen aus Befund, Schritten 3 bis 8 und Hinweisstellen; 15 Monster, 21 Fähigkeiten, 71 Tests mit `Heldwerte`; `version` wird nie gelesen.

## Lauf 133 · 853 Rolle aus Systemmeldung (Perikles, `c71abc295`; 10.11., 13:0x)

- CLAUDE.md „Rollen“ (auch als Systemmeldung), `notiz.sh` und `regeltreue/notiz-neu.sh` (Jerry in der Liste, Systemmeldung von Ford gilt), `LISTE-BETRIEB.md` 17 (`append_system_prompt` mit „Du bist <Rolle> …“) stimmen überein; der Starthaken ruft `notiz.sh` aus dem Arbeitsbaum, Sitzungen starten auf `main`, also greift der neue Text. Kein anderer Ort druckt die alte Rollenliste. **853 greift** (Lauf 133). Wirkung erst am ersten Start nach 13:03 (Ford-Lauf 14:03) zu sehen: Wiedervorlage im Vorrat.

## Lauf 132 · 847 Menüeintrag „Lizenzen der Engine“ ausgenommen (Perikles, `00bd81d70`; 10.11., 13:0x)

- Logik der Commit-Prüfung gegen alle Prüflisten t248–t275: 269.1 und 271.1 gehen jetzt durch; 248.4 (Lizenzhinweis da?), 273.1 (Hoskins, MIT) und 255.1 halten weiter an. 255.1 prüft den Umbruch der englischen Lizenztexte selbst, nicht nur den Weg; nach 832 ist das ein Lizenz-Prüfpunkt, Anhalten richtig (meine Angabe in D128.1 war hier zu weit). **847 greift** (Lauf 132).

## Lauf 131 · 849 Letzte Antwort in der Übergabe (Perikles, `c02c25d52`; 10.11., 13:0x)

- Regel in `LISTE-RELEASE-NEUSTART.md` 1 und CLAUDE.md „Vorräte klein halten“ steht. Echter Fall Sokrates 12:46 → Nachfolger 12:50: Übergabe trägt „Letzte Antwort“, Startmeldung nennt sie nicht.
- **D130.1 → 859 (Perikles, Muss):** Pflicht des Nachfolgers fehlt dort, wo er beim Start liest (CLAUDE.md Zusammenarbeit 2, Rollendateien). Dazu ungenannte Streichung „ohne Werkzeug: vorschlagen“ (436). 849 wartet auf 859.

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
