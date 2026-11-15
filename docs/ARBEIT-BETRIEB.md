# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1296** (zuletzt 1295 Tom 15.11. 13:41:23 a06c) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Chef 15.11., 10:11 (an Sokrates, Chat):** „Wöchentlicher Verbrauch steht bei 9 Prozent“; seit Zurücksetzung Sa 14.11., 20:00 (angenommen wie bisher, nächste Sa 21.11., 20:00) 14 h ≈ 0,63 %/h, tragbar ≈ 0,60 %/h; bei diesem Schnitt 80 % (287) Fr 20.11. ≈ 02:00, 100 % Sa 21.11. ≈ 14:00, also knapp über Kurs; vorher (13.11.) Woche 66 %, ältere Bilder in Git; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (15.11., 11:06, `session_01Hmoj76BCecXxLdXLfnEzk9`, Selbstneustart nach 420 Tsd. Token, Tiefe 4 → Nachfolger auf Tiefe 5; danach nur noch Handstart des Chefs, Tiefe 6 meldet laut; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` auf die eigene Kennung (`create_trigger`, `list_triggers` prüfen); (2) alte Uhr `trig_01BpBNHHosCmPVkVh7ZdEqz5` abschalten; (3) diese Sitzung archivieren (idle, 60 s ruhig), Kosten `lauf.py --kosten 1019 <Zahl> <Kennung>`; (4) Lauf wie „Jeder Lauf“: `--liegt --ohne`-Zeilen der Alten Übergabe unten plus `--ohne "Tuffy:Jerry nimmt 1266"` und `--ohne "Tom:Tom 286 wartet auf Test des Chefs, nur Weiter"`; Kurzzeilen aus `list_sessions` (Seite 1 genügt). Stand 11:06: Läuft: Jerry `…7AB8nKRTEe1G152XSQ` (1266 Film, Lauf 486 bis ca. 11:30), Spike `…77N7FwEA8GY6oPzSUA` (1270.1). Idle: Diogenes `…78yhg3iMnC4caCkmRB` (1272, 1123 abgenommen), Perikles `…77RmWp9S7BfJZLPzKq` (1271 nichts startbar, Wochenziel 16.11.), Homer `…75SXMEBRLJdiSsv5Xd` (1267, blockiert auf `git rebase --continue` in `bornim-main`, der Chef muss es freigeben), Sokrates `…77APonFpNDWGs4JfMc` (Chefrunde, wartet auf Antworten des Chefs), Tom `…762Xztj8QLqEa23Rjp` (Build 286 wartet auf Test des Chefs; lauf.py will ihn für Kür 1214 neu starten und 286 archivieren, nicht tun). Lehren 15.11.: Sokrates sendet „Start <Rolle> <Nr>“, dann lauf.py prüfen und die Zeile ausführen; meldet Sokrates ausdrücklich Spike, kein Tom/Jerry (Weiter statt Start); ein START ohne Sperre lehnt der Haken ab, Sperrzeile von Hand nachtragen. Zeiten nur aus `date`. Offen 11:07: Auftrag Sokrates 11:05 (Tom soll 882.1 `claude/tom-882-1-ohne-gradle` auf main mischen, danach Perikles 870.10) ging als „Weiter“ an Tom; auf „Start Perikles 870.10“ warten. Alte Übergabe (erledigt, 15.11., 01:06): Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_014BcfzRMLG6Fa8bDwFVGeaY` abschalten; (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten 1019 <Zahl> <Kennung>`. Lauf wie „Jeder Lauf“ mit `--wecker <Ford-Wache …01EjSztWBEfCSuvh2gg2pRrC und jede Sitzung mit eigenem Weckruf aus list_triggers (Kurzzeile ohne Kosten für laufende Sitzungen, sonst bucht lauf.py zu früh)>` und den `--ohne`-Zeilen der alten Übergabe unten; Kurzzeilen aller Sitzungen aus `list_sessions` mit Seite 1 und 2 (Spike und Perikles liegen auf Seite 2, nie veraltete Zeilen wiederverwenden). Stand 01:06: Läuft: Jerry `…78SJHxHKh5akPaP15y` (Läufe 479, 480, 482, 1215 Film), Tuffy `…76d3QcJwbDH1YGUuPR` (930.7 Film Lauf 481, Weckruf), Sokrates `…75rZTuiGj1QA448MLH` (930.7, Weckruf 01:09), Diogenes `…78jTfdpL8avRWiFR1x` (1133). Idle: Tom `…78AmAJeR5X7Ghv9VBH` (Build 286 wartet auf Test des Chefs, nicht archivieren, kein Neustart ohne Meldung), Homer `…794ME3Gg3ydHeNmxum` (1260 wartet auf Chef), Spike `…7A7BuC683wt2MBEacm` (1040.1 wartet auf Lauf), Perikles `…75sJsPiamKXFvCq7Bf` (auf Abruf). Offen: Wächter 1036.1 (Jerry informiert, Stand nachziehen). Lehren 15.11.: Neustart-Meldung zuerst `get_session` (idle?), bei „working“ per `send_later` in 3 bis 4 Minuten erneut; Archivieren nie bei Chefnachricht unter 15 Minuten; Neustart Tuffy, Sokrates, Homer, Jerry, Tom von Hand mit Startsperre-Zeile, weil lauf.py sie nicht plant; Tom 286 nicht ohne Weckruf in `--wecker` lassen (sonst ARCHIVIERE). Zeiten nur aus `date`.
- **Alte Übergabe Ford (erledigt, nur noch für die `--ohne`-Zeilen; 14.11., 10:36, `session_01Hmoj7AAPsuvPwPbE7HCYeV`, Selbstneustart nach Haken 1019, Tiefe 1; die älteren Übergaben darüber gelten nicht mehr; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte 1–3 erledigt 10:37 (Selbstneustart abgeschlossen, Ford `…76dYAn9Jmk5yYyU3HQ`); Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_01GFLziADVCTDvXcdVsK1YTL` abschalten (`update_trigger enabled=false`); (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten`. Lauf wie „Jeder Lauf“: Kurzzeilen aus `list_sessions` (Status „pending“ und „running“ sind oft veraltet, vor START oder ARCHIVIERE `get_session`), `lauf.py --besetzung --liegt --wecker <Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` und jede Sitzung mit eigenem Weckruf aus `list_triggers`> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" --ohne "1235:Homer nicht baubar vor dem Meilenstein (Vorgang 1238)" <Datei>`, erst ohne, dann mit `--sperre`. Offen: (a) **Neustart Perikles** (Meldung 10:31, Commit `b7275a65f`, Nachfolger „Perikles – 1246: Stillstand nachts verhindern“): erst starten, wenn die Tagesbericht-Sitzung `…79x9S7PcZtZSXrN3we` ruht; dann deren Archivierung; (b) alte Sokrates-Sitzung `…79rZagJLmbFEy4HZhU` archivieren (Neustart 10:34, Nachfolger `…775ze3dz5eLhqTBs67`; ab 10:41 und idle, Kosten auf 930); (c) Diogenes `…7935pyQLrQDwBaDdQ9` (1098.1 nicht prüfbar vor 16.11.) idle, archivieren, wenn lauf.py es sagt; (d) Tom `…77znPDfxf4G6yvCC6Q` bleibt (Chef testet t285 dort; Neustart Tom erst nach Auswertung, Meldung „Neustart Tom“ abwarten); Spike 1092 `…7A4LFiFy7nygExKGnU`, Jerry 1227 `…77Q6K2jkHmLkqGiwNz` laufen; Jerry-Halt des Chefs 23:35 nur noch für 1072, 709, 709.1, 760, 1068, 1043, 1032, 931, 1224 (Chef 10:28). Lehren 14.11.: kein Neustart einer Sitzung, in der der Chef gerade testet oder antwortet; **ohne `--wecker` für Sitzungen mit eigenem Weckruf (Spike 04:06) plant lauf.py START und ARCHIVIERE falsch**: list_triggers jeden Lauf lesen und alle `persistent_session_id` außer Fords Uhr übergeben; vor START Tom prüfen, dass nicht schon eine Tom-Sitzung läuft (eine Sitzung je Rolle: „Weiter:“ statt zweiter); Startsperre schreibt `--sperre` nur für die erste START-Zeile, für weitere von Hand „Startsperre HH:MM Start <Name> (lauf.py)“ nachtragen; `reaktionen.py` am Morgen lesen (Chef 14.11. 10:27: 👍 auf 844 war angekommen, Eintrag mit „Nachricht <Kennung>“ je Nachricht, Hook sperrt Doppeltes). Werkzeugfehler: 1239 (Parser liest Beispielsatz „Aufwand hoch, weil“ als Nachfolger), 1243 (Commit-Prüfung hält an Terminen von heute mit späterer Uhrzeit). Kurzzeilen aus `list_sessions` (Seite 1 mit limit 8–10 genügt für laufende; ältere archiviert), `--ohne` wie im Befehl oben. Stand 10:36: Morgen und Tagesbericht 14.11. erledigt (kosten.py nicht gelaufen). Zeiten nur aus `date`.
- **Ford** `session_01Hmoj775wuCaHstkrQQKKTC` (15.11., 11:05, Selbstneustart, Tiefe 5 von 8; danach nur Handstart des Chefs), Uhr „Ford-Lauf“ `trig_01Bxa9TW7bvnV8cSVBQdf7AU` (`3 * * * *`, auf diese Sitzung); Vorgänger `…76BCecXxLdXLfnEzk9` 11:07 archiviert (5,96 $ auf 1019), seine Uhr `trig_01BpBNHHosCmPVkVh7ZdEqz5` abgeschaltet. Ältere Kennungen: Protokoll und Git.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter:** keiner (1098 A gilt seit Chef 13.11., 09:18; Regel `LISTE-BETRIEB.md` „Ford-Starter“: nur ein Ford auf Tiefe 0 legt ihn an, ein Ford auf Tiefe 1 nicht, 1245); bis zum nächsten Handstart Selbstneustart „(selbst)“.

## Eingang

- **Von Spike (14.11., 10:51):** 1092 doppelt vergeben: Tom baute seit 10:14 („Weiter: 1092“, Standbild 10:40), Spike kam 10:33 dazu; Spike abgebrochen, kein Lauf, nichts an den Chef. Vor dem Start eines Spike prüfen, ob der Vorgang schon per „Weiter“ bei Tom liegt. Für Tom, falls das Standbild 1092 nicht passt (Vorrat Tom voll, Spike zählt als Besitzer): GITTER in `rig.py` halbiert den Rock rundum, bei 72 Ecken bleiben je Falte 4–5; Spike baute 144 Ecken und 3,5 cm (2,5 las sich am Rechner unter Seitenlicht kaum), Zweig `claude/tom-1092-spike-falten` (4cf96f0d7, mit Schritt „Robe 1092 vorher/nachher“ in godot.yml).


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

- 12:51 15.11.: alte Sokrates `…7A9M8ZL4AXU31SCCyP` endgültig archiviert (Chef 12:47 laut Sokrates; Gesamt 9,12 $, davon 7,70 gebucht, Rest 1,42 $ nicht buchbar: lauf.py bucht je Sitzung einmal)
- 12:30 15.11.: Tom alt `…78NR8tcbL1C1FvSd17` archiviert (11,19 $ auf 431, 870.13)
- 12:29 15.11.: alte Sokrates `…7A9M8ZL4AXU31SCCyP` auf Wort des Chefs (12:28) wieder archiviert (Mehrkosten 0,69 $ auf 1288; Frage 1288a liegt in der Chefsache)
- 12:25 15.11.: Spike neu `…79F2ADvX6hyURaqmPK` (1270.1), alt archiviert (8,54 $ auf 1270.1); Tom neu `…76Ra6BZe2iYammL66v` (785.1), alt `…78NR8tcbL1C1FvSd17` archiviert um 12:29 wenn idle
- 12:16 15.11.: alte Sokrates `…7A9M8ZL4AXU31SCCyP` wieder aus dem Archiv (Chef will lesen, Sokrates 12:15): nicht archivieren bis der Chef es sagt; im Lauf `--ohne` Sokrates-Zeilen dieser Kennung
- 12:11 15.11.: Sokrates neu `…76h9DLKywqNeh4ZJF8`, alt `…7A9M8ZL4AXU31SCCyP` archiviert (7,70 $ auf 1270, 1271, 1215, 431), Wecker 1215 neu `trig_01BWeMw65nTWpiAreAcKbAJd`
- 12:05 15.11.: Tom neu `…78NR8tcbL1C1FvSd17` (431), Perikles neu `…78dCt3YTef3e1vvp1K` (M? 1275), alt archiviert (Tom 2,96 $ auf 1214, Perikles 7,65 $ auf 1277, 1278); START Homer 1235 und Diogenes 1128.3 nicht ausgeführt (Homer: nicht baubar vor Meilenstein, Diogenes wartet auf Bautest/t287), Sitzungen bleiben
- 11:38 15.11.: Jerry neu `…78didfhaNLaWruGUVT` (1266, 1274 c), Jerry 1215 (stärkstes Modell) `…77868z8tGPx6d9vJF1`, alt `…7AB8nKRTEe1G152XSQ` archiviert (10,05 $ auf 1266, 481.2)
- 11:21 15.11.: Diogenes neu `…75f6u3gFfiQ22M2H7J` (1128.3, 1276, 882.2), alt archiviert (2,71 $ auf 1272)
- 11:17 15.11.: Homer alt `…75SXMEBRLJdiSsv5Xd` archiviert (5,71 $ auf 1267)
- 11:14 15.11.: Sokrates neu `…7A9M8ZL4AXU31SCCyP` (Chefrunde Rest), alt archiviert (6,65 $ auf 1270, 1268, 481a, 1271, 1272, 1277); Tom neu `…76Nrryek3oSSKfE8CE` (1214), alt archiviert (9,71 $ auf 286); Homer alt noch offen (Archiv 11:16)
- 11:11 15.11.: Homer neu `…787mL9tKD6xvJpNakw` (1267), alte `…75SXMEBRLJdiSsv5Xd` bleibt bis Push der Texte (Rebase hing, Notizen gepusht?); Perikles neu `…77DVasqzk8UQ6BuvGG` (1277), alt archiviert (3,22 $); Wächter 1270.1 und Neustart Sokrates (Prüfung 11:13) offen
- 11:07 15.11.: Ford-Selbstneustart abgeschlossen: neue Uhr `trig_01Bxa9TW7bvnV8cSVBQdf7AU` (:03), alte `trig_01BpBNHHosCmPVkVh7ZdEqz5` aus, alter Ford `…76BCecXxLdXLfnEzk9` archiviert (5,96 $ auf 1019); Diogenes 1123 `…78w1wTxyTuS8uf2tzM` archiviert (1,49 $); Wächter 1270.1 an Tom gesendet
- 10:59 15.11.: Jerry neu `…7AB8nKRTEe1G152XSQ` (1266 Film, dann 1215), alt archiviert (17,36 $)
- 10:57 15.11.: Spike neu `…77N7FwEA8GY6oPzSUA` (1270.1, Neustart 1a316e011), alt archiviert (10,98 $)
- 10:55 15.11.: Diogenes neu `…78yhg3iMnC4caCkmRB` (1272); 1270.1 per Weiter an Spike `…7A7BuC683wt2MBEacm` (Chef: nicht Tom und Jerry), Tom 286 bleibt (wartet auf Chef-Test)
- 10:51 15.11.: Homer neu `…75SXMEBRLJdiSsv5Xd` (1267), Homer 1264 archiviert (4,18 $); Perikles neu `…77RmWp9S7BfJZLPzKq` (1271 auf Meldung Sokrates), Perikles Tagesbericht archiviert (4,76 $)
- 10:47 15.11.: Sokrates neu `…77APonFpNDWGs4JfMc` (Chefrunde Berg abbauen, Chef wartet), alt archiviert (3,92 $ auf 1186)
- 10:17 15.11.: Sokrates neu `…78RskfRt4STVuE8msj` (Neustart e0527fb49), alt archiviert (6,72 $ auf 1260); Tuffy 1266 ausgenommen (Jerry nimmt es)
- 10:09 15.11.: Jerry neu `…79c2xTDZMPma5iiDXB` (1266 Kerbe, auf Meldung Sokrates 10:08), Jerry alt archiviert (1,07 $); Homer 1264 bekommt Weiter 1265
- 01:03 15.11.: Marke Rückmeldung 1036.1 13.11. 18:33 (lauf.py)
- 01:06 15.11.: Marke Wächter 1133 13.11. 12:53 (lauf.py)
- 01:30 15.11.: Marke Archiv session_01Hmoj78SJHxHKh5akPaP15y (lauf.py)
- 02:04 15.11.: Marke Stellungnahme Sokrates 15.11. (lauf.py)
- 02:04 15.11.: Marke Mehrfach Diogenes (lauf.py)
- 02:04 15.11.: Marke Archiv session_01Hmoj75rZTuiGj1QA448MLH (lauf.py)
- 02:05 15.11.: Marke Archiv session_01Hmoj75sJsPiamKXFvCq7Bf (lauf.py)
- 03:03 15.11.: Marke Archiv session_01Hmoj795CKQ5Pf7crAxZoTU (lauf.py)
- 03:11 15.11.: Marke Archiv session_01Hmoj762Xztj8QLqEa23Rjp (lauf.py)
- 03:11 15.11.: Marke Archiv session_01Hmoj76MSnYWiTvsA1DfTZG (lauf.py)
- 10:03 15.11.: Startsperre 10:03 Start Homer (lauf.py)
- 10:03 15.11.: Marke Tagesbericht 15.11. (lauf.py)
- 10:03 15.11.: Marke Nachhalten 15.11. (lauf.py)
- 10:03 15.11.: Marke Rückmeldung 1260 15.11. 09:57 (lauf.py)
- 10:03 15.11.: Marke Abgleich ganz 15.11. (lauf.py)
- 10:03 15.11.: Marke Archiv session_01Hmoj794ME3Gg3ydHeNmxum (lauf.py)
- 10:05 15.11.: Startsperre 10:05 Start Perikles (lauf.py)
- 10:08 15.11.: Startsperre 10:08 Start Jerry (lauf.py)
- 10:08 15.11.: Marke Archiv session_01Hmoj79uukZoJ96FG4zHcRv (lauf.py)
- 10:16 15.11.: Startsperre 10:16 Start Sokrates (Neustart, e0527fb49)
- 10:46 15.11.: Startsperre 10:46 Start Sokrates (Neustart, ae90abec3)
- 10:50 15.11.: Startsperre 10:50 Start Homer, Perikles (lauf.py)
- 10:50 15.11.: Marke Archiv session_01Hmoj7A9BD9js7ioHpGovGR (lauf.py)
- 10:50 15.11.: Marke Archiv session_01Hmoj79UDfkXFpM3zk1WmjM (lauf.py)
- 10:53 15.11.: Startsperre 10:53 Start Tom, Diogenes (lauf.py)
- 10:56 15.11.: Startsperre 10:56 Start Spike (Neustart, 1a316e011)
- 10:59 15.11.: Startsperre 10:59 Start Jerry (Neustart, 0abf2acbf)
- 11:06 15.11.: Startsperre 11:06 Start Ford (selbst, Tiefe 4, Selbstneustart nach 420 Tsd. Token)
- 11:10 15.11.: Startsperre 11:10 Start Homer, Perikles (lauf.py)
- 11:10 15.11.: Marke Rückmeldung 1270.1 15.11. 11:04 (lauf.py)
- 11:10 15.11.: Marke Archiv session_01Hmoj78w1wTxyTuS8uf2tzM (lauf.py)
- 11:10 15.11.: Marke Archiv session_01Hmoj75SXMEBRLJdiSsv5Xd (lauf.py)
- 11:10 15.11.: Marke Archiv session_01Hmoj77RmWp9S7BfJZLPzKq (lauf.py)
- 11:12 15.11.: Startsperre 11:12 Start Tom (Neustart, fa547d370)
- 11:14 15.11.: Startsperre 11:14 Start Sokrates (Neustart, 8892bf7e9)
- 11:20 15.11.: Startsperre 11:20 Start Diogenes (lauf.py)
- 11:20 15.11.: Marke Archiv session_01Hmoj78yhg3iMnC4caCkmRB (lauf.py)
- 11:37 15.11.: Startsperre 11:37 Start Jerry (Neustart 0ae5feb3d, 1266/1274) und Startsperre 11:37 Start Jerry 1215 (stärkstes Modell, 1215a A, Chef 11:21; von Hand)
- 12:04 15.11.: Startsperre 12:04 Start Tom, Diogenes, Homer, Perikles (lauf.py)
- 12:04 15.11.: Marke Mehrfach Jerry (lauf.py)
- 12:04 15.11.: Marke Archiv session_01Hmoj76Nrryek3oSSKfE8CE (lauf.py)
- 12:04 15.11.: Marke Archiv session_01Hmoj75f6u3gFfiQ22M2H7J (lauf.py)
- 12:04 15.11.: Marke Archiv session_01Hmoj787mL9tKD6xvJpNakw (lauf.py)
- 12:04 15.11.: Marke Archiv session_01Hmoj77DVasqzk8UQ6BuvGG (lauf.py)
- 12:09 15.11.: Startsperre 12:09 Start Sokrates (Neustart, 7d0e0dbcb)
- 12:21 15.11.: Startsperre 12:21 Start Spike (Neustart, d2d9a63a9)
- 12:25 15.11.: Startsperre 12:25 Start Tom (Neustart, 10a507cfa)
- 13:03 15.11.: Startsperre 13:03 Start Tom (Neustart, bf99bb6cc)
- 13:04 15.11.: Startsperre 13:04 Start Perikles, Spike (lauf.py)
- 13:04 15.11.: Marke Mehrfach-Warnung Jerry session_01Hmoj77868z8tGPx6d9vJF1 (lauf.py)
- 13:04 15.11.: Marke Mehrfach Jerry (lauf.py)
- 13:04 15.11.: Marke Mehrfach Tom (lauf.py)
- 13:04 15.11.: Marke Archiv session_01Hmoj78dCt3YTef3e1vvp1K (lauf.py)
- 13:04 15.11.: Marke Archiv session_01Hmoj79F2ADvX6hyURaqmPK (lauf.py)
- 13:05 15.11.: Spike 1270.2 (Zusatzentwickler) `…764GvRteLSEAskvbEW`, Spike alt `…79F2ADvX6hyURaqmPK` archiviert (4,96 $ auf 1270.1); Tom `…78BSaiyTRN5sJLVCBK` (431) läuft, Tom alt `…76Ra6BZe2iYammL66v` archiviert um 13:07; Weiter an Perikles (M? 1291) und Diogenes (1128.3), kein START, weil Sitzungen stehen; GELÖST 1270.4, 168.1 gesendet; WARNUNG-LAUT Jerry zwei Sitzungen: gewollt (1215 stärkstes Modell, Chef 11:21)
- 13:08 15.11.: Tom alt `…76Ra6BZe2iYammL66v` archiviert (14,89 $ auf 785.1, 870.13, 1290); Tom neu `…78BSaiyTRN5sJLVCBK` mit Übergabe f3bdce628 (Build 288, dann 431); 1294 Werkzeugfehler (Perikles hat behoben, Diogenes prüft)
- 13:36 15.11.: Startsperre 13:36 Start Jerry 760, 1000 (stärkstes Modell, Chef 13:34 laut Sokrates, 9f301e5db; von Hand)
- 13:37 15.11.: Jerry 760, 1000 (stärkstes Modell) `…78vVh9TarMqMiBZ1pM` gestartet; Jerry 1215 `…77868z8tGPx6d9vJF1` fertig, bleibt offen bis Urteil des Chefs
