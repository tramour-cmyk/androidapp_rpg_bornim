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
