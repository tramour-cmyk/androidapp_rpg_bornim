# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1247** (zuletzt 1246 Perikles 14.11. 10:30:19 df93) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 13.11., 09:46 (an Perikles, ohne Text):** Woche 66 % (Zurücksetzung Sa 14.11., 20:00), Sitzung 5 % (bis 14:10); App: „Auf Kurs … morgige Zurücksetzung … mit Spielraum“; Schnitt seit 12.11., 16:42 (48 %) ≈ 1,05 %/h, tragbar bis Sa ≈ 0,99 %/h (34 % in 34 h); bei diesem Schnitt 80 % (287, `--nur-muss`) heute ≈ 23:00, 100 % Sa ≈ 18:00; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (14.11., 10:36, `session_01Hmoj7AAPsuvPwPbE7HCYeV`, Selbstneustart nach Haken 1019, Tiefe 1; die älteren Übergaben darüber gelten nicht mehr; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte 1–3 erledigt 10:37 (Selbstneustart abgeschlossen, Ford `…76dYAn9Jmk5yYyU3HQ`); Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_01GFLziADVCTDvXcdVsK1YTL` abschalten (`update_trigger enabled=false`); (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten`. Lauf wie „Jeder Lauf“: Kurzzeilen aus `list_sessions` (Status „pending“ und „running“ sind oft veraltet, vor START oder ARCHIVIERE `get_session`), `lauf.py --besetzung --liegt --wecker <Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` und jede Sitzung mit eigenem Weckruf aus `list_triggers`> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" --ohne "1235:Homer nicht baubar vor dem Meilenstein (Vorgang 1238)" <Datei>`, erst ohne, dann mit `--sperre`. Offen: (a) **Neustart Perikles** (Meldung 10:31, Commit `b7275a65f`, Nachfolger „Perikles – 1246: Stillstand nachts verhindern“): erst starten, wenn die Tagesbericht-Sitzung `…79x9S7PcZtZSXrN3we` ruht; dann deren Archivierung; (b) alte Sokrates-Sitzung `…79rZagJLmbFEy4HZhU` archivieren (Neustart 10:34, Nachfolger `…775ze3dz5eLhqTBs67`; ab 10:41 und idle, Kosten auf 930); (c) Diogenes `…7935pyQLrQDwBaDdQ9` (1098.1 nicht prüfbar vor 16.11.) idle, archivieren, wenn lauf.py es sagt; (d) Tom `…77znPDfxf4G6yvCC6Q` bleibt (Chef testet t285 dort; Neustart Tom erst nach Auswertung, Meldung „Neustart Tom“ abwarten); Spike 1092 `…7A4LFiFy7nygExKGnU`, Jerry 1227 `…77Q6K2jkHmLkqGiwNz` laufen; Jerry-Halt des Chefs 23:35 nur noch für 1072, 709, 709.1, 760, 1068, 1043, 1032, 931, 1224 (Chef 10:28). Lehren 14.11.: kein Neustart einer Sitzung, in der der Chef gerade testet oder antwortet; **ohne `--wecker` für Sitzungen mit eigenem Weckruf (Spike 04:06) plant lauf.py START und ARCHIVIERE falsch**: list_triggers jeden Lauf lesen und alle `persistent_session_id` außer Fords Uhr übergeben; vor START Tom prüfen, dass nicht schon eine Tom-Sitzung läuft (eine Sitzung je Rolle: „Weiter:“ statt zweiter); Startsperre schreibt `--sperre` nur für die erste START-Zeile, für weitere von Hand „Startsperre HH:MM Start <Name> (lauf.py)“ nachtragen; `reaktionen.py` am Morgen lesen (Chef 14.11. 10:27: 👍 auf 844 war angekommen, Eintrag mit „Nachricht <Kennung>“ je Nachricht, Hook sperrt Doppeltes). Werkzeugfehler: 1239 (Parser liest Beispielsatz „Aufwand hoch, weil“ als Nachfolger), 1243 (Commit-Prüfung hält an Terminen von heute mit späterer Uhrzeit). Kurzzeilen aus `list_sessions` (Seite 1 mit limit 8–10 genügt für laufende; ältere archiviert), `--ohne` wie im Befehl oben. Stand 10:36: Morgen und Tagesbericht 14.11. erledigt (kosten.py nicht gelaufen). Zeiten nur aus `date`.
- **Ford** `session_01Hmoj76dYAn9Jmk5yYyU3HQ` (14.11., 10:35, Selbstneustart, Tiefe 2 von 8), Uhr „Ford-Lauf“ `trig_01LkfXvhcQ873nArQjFWNhGh` (`3 * * * *`, auf diese Sitzung); Vorgänger `…7AAPsuvPwPbE7HCYeV` 10:36 archiviert (7,73 $ auf 1019), seine Uhr `trig_01GFLziADVCTDvXcdVsK1YTL` abgeschaltet; davor `…772q8aDimJ7oU9STTH` 00:17 archiviert (18,48 $ auf 1019), seine Uhr `trig_01EHAn6DzrccwnUjPQpyP1z1` abgeschaltet; davor `…77sRcmN1u6VxQYWM7i` (Tiefe 8) archiviert, davor `…78u5NKKaaKVcUMPhcT` 18:01 archiviert (8,33 $), seine Uhr `trig_01TjU64EK3639FuEHBURA6WS` abgeschaltet; davor `…79VeEbfi8Yk1Y2Eb6y` archiviert (7,78 $); seine Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` und die davor `trig_01BF6Lp6NmrCqGU6deZrg8tm` nur abgeschaltet (Löschen vom Klassifizierer abgelehnt; Chef kann sie löschen).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter:** keiner (1098 A gilt seit Chef 13.11., 09:18; Regel `LISTE-BETRIEB.md` „Ford-Starter“: nur ein Ford auf Tiefe 0 legt ihn an, ein Ford auf Tiefe 1 nicht, 1245); bis zum nächsten Handstart Selbstneustart „(selbst)“.

## Eingang


- Aufgeräumt 13.11., 15:35 (Ford, auf Hinweis Perikles 1147 und Sokrates 00:33): alte Chefworte, Nachtpläne, Befunde und Regeln bis 11.11. gestrichen, Verlauf in Git (`git log -p docs/ARBEIT-BETRIEB.md`). Weiter gelten: je Rolle eine Sitzung; idle Sitzung (>60 s) archivieren und Kosten buchen (516a); `lauf.py` startet mit `--sperre` erst nach dem Lauf ohne; Startnachricht wie in `LISTE-BETRIEB.md` Schritt 4; nach jedem Start `get_session` auf Aufwand und Umgebung prüfen (Fehler 341).
- **Zu 1186, von Sokrates (Chef 13.11., 16:44, offene Vorgänge auf Leichen):** 843 erledigt (Diogenes Lauf 127, c6b02aa54: jeder START ausgeführt oder begründet); 741 überholt (Diogenes 09.11., fb8fd867e: durch 749, 776); 906 überholt (Sperre betraf 870.2–870.8, alle erledigt). Bitte schließen. Oben steht noch „Ford-Starter … ruht bis zur Antwort des Chefs auf 1098“; der Chef hat 13.11., 09:18 entschieden (Perikles 11:42: A gilt), bitte nachziehen.

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 13.11., 16:52 (Spike): `weiter-haken.py` schickt Spike auf Toms Zeilen, die Tom gerade selbst hat (756.1: Bild 16:34 gesendet, Stand noch „startbar“; 1044: „in Arbeit, Messlauf Osric“ seit 16:34). Vorschlag: für Spike/Tuffy Zeilen „in Arbeit“ ohne „bei Spike/Tuffy“ überspringen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 13.11., 15:30 Ford: Läufe 13:39, 13:46, 14:09, 14:29, 14:50, 14:57, 15:28 von Hand nach Meldungen (Uhr „Ford-Lauf“ feuert seit 14:03 nicht); gestartet/Neustart Perikles, Diogenes, Tuffy, Sokrates, Jerry, Tom; alte Sitzungen archiviert und gebucht; Vorgänge 1148 und 1159 an Perikles (Hintergrundlauf Spike 882.1).
- 13.11., 13:23 Ford (neue Sitzung `…79VeEbfi8Yk1Y2Eb6y`): Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` neu, alte abgeschaltet (Löschen abgelehnt), Vorgänger archiviert (9,65 $, gebucht), Perikles 1134 gestartet `…79AYXzXxbEysheXSSM`; sonst alle belegt.
- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` und ignorierte die Warnung „Seite abgeschnitten“; künftig alle Seiten über `after_id` lesen, Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry aus eigener Beurteilung aus, ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch). Lehre: START ausführen oder `--ohne NR:Grund` und lautlos an Perikles

- 10:14 14.11.: Chef 10:11 zu 1092: „a. mit den Ergänzungen“ (Sokrates: A mit Deckel) eingetragen (Archiv, Zu 1092 Tom, Datei weg); Tom `…77znPDfxf4G6yvCC6Q` per „Weiter: 1092“ angestoßen (kein zweiter Tom, Chef testet t285 dort; lauf.py plante START Tom + ARCHIVIERE Tom, nicht ausgeführt); Perikles 1244 archiviert (1,19 $).
- 10:05 14.11.: Tagesbericht: Perikles `…79x9S7PcZtZSXrN3we` gestartet.
- 09:05 14.11.: Lauf 09:03: nichts zu starten (Diogenes 1098.1 vorerst nicht prüfbar, Sokrates wartet auf Chef). Morgen 14.11.: regelcheck --kurz: 2 Pflegehinweise (Pause-Felder Jerry und Sokrates ohne lesbares Datum, Besitzer setzen); kosten.py nicht gelaufen (Seiten nicht geholt, Guthaben tragbar laut Zeile oben), Zählung nachholen im nächsten Lauf mit Zeit.
- 08:06 14.11.: 1245 erledigt: Zeile Ford-Starter oben richtiggestellt (Geprüft an: Commit nach Push).
- 08:05 14.11.: Lauf 08:03: Tom alt archiviert (21,01 $ auf 285), Spike 1240 (1,41 $), Diogenes 1240 (1,06 $) archiviert; nichts zu starten; Nachhalten: Eingang leer, 6 Abgleich-Zeilen Jerry (811, 876, 923, 971, 644a.1, 1060) ohne Build, lautlos.
- 07:49 14.11.: Neustart Tom: `…77znPDfxf4G6yvCC6Q` gestartet (Commit 919bb6cb0); alter Tom `…78jYddD6WmJoPRmjVB` (20,74 $ auf 285 zu buchen) noch aktiv, archivieren im nächsten Lauf, sobald idle und 60 s ruhig. Diogenes/Spike 1240 fertig.
- 07:12 14.11.: Lauf nach Spike-Meldung: Diogenes 1240 `…77ehu4FbYQdvND3s1N` gestartet; Diogenes 1133 archiviert (0,69 $). Spike 1240 fertig, endet selbst.
- 07:05 14.11.: Lauf 07:04: Spike 1240 `…77uoFJEbXdzXu8YKzd` gestartet; Spike 1234 archiviert (1,66 $, fertig).
- 06:05 14.11.: Lauf 06:04: Spike 1234 `…7AC9YkKwtpBTa4hv6G` gestartet; Spike 1149 archiviert (5,74 $; Bildurteil in chefsache/ansehen/1149-scheide.md).
- 04:05 14.11.: Lauf 04:03: nichts gestartet; Spike 1149 `…75RUbW5ZmdoiqPRgSc` bleibt (eigener Weckruf 04:06, Probelauf), Hinweis: ohne --wecker Spike plant lauf.py START/ARCHIVIERE.
- 03:05 14.11.: Lauf 03:03: Spike 1149 `…75RUbW5ZmdoiqPRgSc` gestartet; Spike 1119 archiviert (1,27 $).
- 02:06 14.11.: Lauf 02:03: Spike 1119 `…7A5LHhpS9zYpLe4fcH`, Sokrates Stellungnahme 1092 `…79rZagJLmbFEy4HZhU` gestartet (erste Sperre fehlte für Sokrates, nachgetragen); archiviert Spike 1092 (2,92 $), Sokrates 930 (1,51 $; Frage 7 zu 930 wartet beim Chef).
- 01:05 14.11.: Lauf 01:03 (Uhr 00:03 feuerte erst 01:03): Diogenes 1133 `…76bc5kiW8nS95txbzS` gestartet, alte Diogenes archiviert (2,46 $); Jerry Nachfolger nicht startbar (wartet auf Sokrates/Chef-Entscheid).
- 00:48 14.11.: Gestartet Perikles 1244 `…75S17HaS9xkgwwowAA`, Spike 1092 `…781eUCpQ5SKa8cCpQV`, Sokrates 930 `…75kLBATHVTa9eEViaE` (Neustart); archiviert Spike 1040.1 (5,71 $), Sokrates alt (6,08 $). Ford-Lauf-Uhr 00:03 und 00:46 nicht gefeuert (Uhr verspätet); Läufe nach Meldungen.
- 00:18 14.11.: Selbstneustart Ford abgeschlossen: neue Uhr trig_01GFLziADVCTDvXcdVsK1YTL, alte abgeschaltet, alter Ford archiviert (18,48 $ auf 1019); Diogenes 1133 gestartet `…79Lqfbd3HfnYzQhK8H`; Diogenes 1237 archiviert (3,67 $); Warnung Abgleich 6 Zeilen ohne Build; Wächter 1036.1 (Jerry, Stand nachziehen).
- 00:05 14.11.: Lauf 00:03: Spike (1040.1) `…76xVCXk2y824rYD6Rk` und Perikles (echter Nachfolger 1098, 1019, 1100, 1125, von Hand wegen Parserfehler 1239, Mittel) `…76yL3LGXZZZ4orHsL5` gestartet; Vorgängerinnen `…78AKcm…` (8,47 $ auf 1230) und `…79QJ2L…` (7,48 $ auf 542) archiviert; Commit-Prüfung hielt an Zeile 827 (Termin heute 20 Uhr), Zeile von Hand auf HEAD zurückgesetzt, danach neuer Vorgang an Perikles (Ford)
- 23:52 13.11.: Neustart Sokrates (1dc3da5d9): neue Sitzung `…794Zd84otPipZDDhLx` 23:50 (Mittel), Vorgängerin `…7A5LHnTB8QgSgxTD8M` archiviert (4,35 $ auf 1072, 709); Jerry ruht auf Wort des Chefs 23:35, kein Start dafür bis zur Entscheidung zu 930 (Ford)
- 23:39 13.11.: Neustart Jerry (207af913c): neue Sitzung `…76T6cjjcpvFiQSkmub` (Mittel), Vorgängerin `…78sHDY7SBKAQW8Re2t` archiviert (6,03 $ auf 709.1); Halt 23:35 über Sokrates (709, 709.1, 1072 u. a.) steht in Jerrys Vorrat; Beobachtung: Jerry-Neustarts 22:30, 23:21, 23:34 binnen einer Stunde, Haken feuert früh (Ford)
- 23:32 13.11.: „Neustart Tom, 919bb6cb0“ nicht ausgeführt: Chef testet t285 (Testbitte 906a81451), Neustart während seines Tests nie (812, 865); Tom bleibt, meldet nach dem Ergebnis neu (Ford)
- 23:31 13.11.: Neustart Sokrates (28d978c49): neue Sitzung `…7A5LHnTB8QgSgxTD8M` 23:30 (Mittel), Vorgängerin `…797jN7dteYW35dpYLZ` archiviert (10,28 $ auf 1236, 1072, 827; Ford)
- 00:04 14.11.: Marke Archiv session_01Hmoj78AKcmYZYcEtyFxx5V (lauf.py)
- 00:04 14.11.: Marke Archiv session_01Hmoj79QJ2L8FTAiLRqDERR (lauf.py)
- 00:04 14.11.: Nachfolger-Warnung Diogenes (Übergabe 13.11., 23:19) (lauf.py)
- 00:15 14.11.: Startsperre 00:15 Start Ford (selbst, Tiefe 0, Selbstneustart nach Haken 1019, Neustart Perikles 3c83e9ce6 ohne Start, Nachfolger erst 15.11., Sitzung `…76yL3LGXZZZ4orHsL5` archiviert, 3,32 $ auf 1019, 1098; Ford)
- 00:17 14.11.: Marke Rückmeldung 1036.1 13.11. 18:33 (lauf.py)
- 00:17 14.11.: Marke Archiv session_01Hmoj783kjRUn2ac4Ks2Yhg (lauf.py)
- 00:46 14.11.: Marke Archiv session_01Hmoj76xVCXk2y824rYD6Rk (lauf.py)
- 00:46 14.11.: Nachfolger-Warnung Jerry (Übergabe 14.11., 00:42) (lauf.py)
- 01:04 14.11.: Marke Archiv session_01Hmoj79Lqfbd3HfnYzQhK8H (lauf.py)
- 02:04 14.11.: Marke Stellungnahme Sokrates 14.11. (lauf.py)
- 02:04 14.11.: Marke Archiv session_01Hmoj781eUCpQ5SKa8cCpQV (lauf.py)
- 02:04 14.11.: Marke Archiv session_01Hmoj75kLBATHVTa9eEViaE (lauf.py)
- 02:05 14.11.: Startsperre 02:05 Start Sokrates (lauf.py, Stellungnahme 1092)
- 03:04 14.11.: Marke Archiv session_01Hmoj7A5LHhpS9zYpLe4fcH (lauf.py)
- 06:04 14.11.: Startsperre 06:04 Start Spike (lauf.py)
- 06:04 14.11.: Marke Archiv session_01Hmoj75RUbW5ZmdoiqPRgSc (lauf.py)
- 07:04 14.11.: Startsperre 07:04 Start Spike (lauf.py)
- 07:04 14.11.: Marke Archiv session_01Hmoj7AC9YkKwtpBTa4hv6G (lauf.py)
- 07:11 14.11.: Startsperre 07:11 Start Diogenes (lauf.py)
- 07:11 14.11.: Marke Archiv session_01Hmoj76bc5kiW8nS95txbzS (lauf.py)
- 07:48 14.11.: Startsperre 07:48 Start Tom (Neustart 919bb6cb0, Tom 07:46, Chef seit 23:30 ohne Rückmeldung zu t285; Nachfolger übernimmt PR-Abo #204)
- 08:04 14.11.: Marke Nachhalten 14.11. (lauf.py)
- 08:04 14.11.: Marke Abgleich ganz 14.11. (lauf.py)
- 08:05 14.11.: Startsperre 08:05 Start Diogenes (lauf.py)
- 10:04 14.11.: Marke Tagesbericht 14.11. (lauf.py)
- 10:04 14.11.: Startsperre 10:04 Start Perikles (Tagesbericht 14.11., lauf.py)
- 10:31 14.11.: Startsperre 10:31 Start Jerry, Spike (lauf.py)
- 10:31 14.11.: Marke Archiv session_01Hmoj76T6cjjcpvFiQSkmub (lauf.py)
- 10:33 14.11.: Lauf nach Perikles-Meldung: Jerry 1227 `…77Q6K2jkHmLkqGiwNz` (Chef 10:28: Jerry soll arbeiten; Halt nur noch für 1072, 709, 709.1, 760, 1068, 1043, 1032, 931, 1224), Spike 1092 `…7A4LFiFy7nygExKGnU` gestartet (Tom bleibt 1091/t285); Jerry alt archiviert (2,40 $); Perikles-Neustart (b7275a65f, Nachfolger 1246) folgt, sobald Tagesbericht-Sitzung ruht; Chef 👍 Telegram 844 eingetragen.
- 10:35 14.11.: Startsperre 10:35 Start Sokrates (Neustart ad8d42ded, Sokrates 10:34)
- 10:35 14.11.: Startsperre 10:35 Start Ford (selbst, Tiefe 1, Selbstneustart nach Haken 1019 Erinnerung 1; Sokrates-Neustart ad8d42ded ausgeführt)
- 10:35 14.11.: Startsperre 10:35 Start Ford (selbst)
- 10:37 14.11.: Selbstneustart Ford abgeschlossen: neue Uhr trig_01LkfXvhcQ873nArQjFWNhGh, alte abgeschaltet, alter Ford archiviert (7,73 $ auf 1019)
