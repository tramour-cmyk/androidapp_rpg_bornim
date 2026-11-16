# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1456** (zuletzt 1455 Jerry 16.11. 16:05:58 9f3c) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Chef 16.11., 12:13 (an Sokrates, Chat):** „Wir sind aktuell auf 37% Verbrauch.“; seit Zurücksetzung Sa 14.11., 20:00 (angenommen, nächste Sa 21.11., 20:00) 40 h ≈ 0,92 %/h, tragbar für den Rest ≈ 0,49 %/h; bei diesem Schnitt 80 % (287) Mi 18.11. ≈ 11:00, 100 % Do 19.11. ≈ 09:00, deutlich über Kurs (15.11., 10:11: 9 %, 0,63 %/h); vorher (13.11.) Woche 66 %, ältere Bilder in Git; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (15.11., 14:30, `session_01Hmoj775wuCaHstkrQQKKTC`, Selbstneustart nach 406 Tsd. Token, Tiefe 5 → Nachfolger auf Tiefe 6; Tiefe 6 meldet laut `--laut` „Chef: Ford bitte von Hand starten (Tiefe 6)“ und legt Datei `docs/chefsache/entscheiden/110-…` an, einmal; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` auf die eigene Kennung (`create_trigger`, `list_triggers` prüfen); (2) alte Uhr `trig_01Bxa9TW7bvnV8cSVBQdf7AU` abschalten; (3) alte Sitzung archivieren (idle, 60 s ruhig), Kosten `lauf.py --kosten 1019 <Zahl> <Kennung>`; (4) die einmaligen Erinnerungen `trig_018oE2xufz25k12EawTcqjsP` (Start Jerry 1289, hängt an der alten Sitzung) abschalten und selbst neu per `send_later` auf 15:34 setzen; (5) Lauf wie „Jeder Lauf“: `--wecker` für Sitzungen mit eigenem Weckruf aus `list_triggers` (Jerry 760/1000, Tom, Sokrates), `--ohne "Tuffy:Jerry nimmt 1266"`, `--ohne "Homer:1235 nicht baubar vor Meilenstein"`; Kurzzeilen aus `list_sessions` Seite 1. Stand 14:30: Läuft: Jerry 760/1000 stärkstes Modell `…78vVh9TarMqMiBZ1pM` (Ende 15:30, pusht, dann drückt der Chef die Limit-Zurücksetzung), Spike 1268.1 `…75sX1mjBfUobAcrzXh`, Tom neu `…76EuPC3nA5MCHtgZWa` (Build 288, 431 Schild). Idle: Sokrates `…79enQhUTdgTcHDC329` (Weckruf 15:35 `trig_015fPVKTbEBVXWP8uNFZhhTP`), Perikles `…75QZ37mBNTLgGWbYsd` (1289 vorgezogen), Diogenes `…75f6u3gFfiQ22M2H7J` (Vorrat leer bis Wochenzählung 16.11., 08:00), Homer `…787mL9tKD6xvJpNakw` (leer). Offen: **Start Jerry 1289 „Jerry – 1289: Höhle im Renderer mobile“ erst, wenn die Block-Sitzung 760/1000 idle ist (Perikles 13:47: keine zweite Jerry-Sitzung), Nachfolge laut Übergabe Jerry (Commit 19a870f2e), neue Sitzung schaltet das Kaufrepo selbst mit `add_repo` frei; danach der Folgeauftrag 1215 (Physik einschalten, Build) „Zu 1215“ bei Jerry**; Tom-Wecker `trig_01NkWZgaeGi5kCTYKY4LsPvo` (Build 288) gehört der archivierten alten Sitzung, der neue Tom legt ihn neu an. Lehren 15.11.: lauf.py plant `--liegt` die Rolle Perikles/Diogenes/Homer oft neu, obwohl ihre Sitzung steht: dann „Weiter:“ per `send_message` statt Start (Sitzung bleibt, Kosten sparen); eine alte Sitzung mit hängendem Rebase pusht ihre Notizen selbst per `git pull --no-rebase`, erst dann archivieren; Kosten je Sitzung nur einmal buchbar, mehrere Vorgänge als Kommaliste in einem Aufruf (`--kosten a,b,c <Zahl> <Kennung>`). Zeiten nur aus `date`. Alte Übergabe (erledigt 15.11., 11:07; 11:06, `session_01Hmoj76BCecXxLdXLfnEzk9`): Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` auf die eigene Kennung (`create_trigger`, `list_triggers` prüfen); (2) alte Uhr `trig_01BpBNHHosCmPVkVh7ZdEqz5` abschalten; (3) diese Sitzung archivieren (idle, 60 s ruhig), Kosten `lauf.py --kosten 1019 <Zahl> <Kennung>`; (4) Lauf wie „Jeder Lauf“: `--liegt --ohne`-Zeilen der Alten Übergabe unten plus `--ohne "Tuffy:Jerry nimmt 1266"` und `--ohne "Tom:Tom 286 wartet auf Test des Chefs, nur Weiter"`; Kurzzeilen aus `list_sessions` (Seite 1 genügt). Stand 11:06: Läuft: Jerry `…7AB8nKRTEe1G152XSQ` (1266 Film, Lauf 486 bis ca. 11:30), Spike `…77N7FwEA8GY6oPzSUA` (1270.1). Idle: Diogenes `…78yhg3iMnC4caCkmRB` (1272, 1123 abgenommen), Perikles `…77RmWp9S7BfJZLPzKq` (1271 nichts startbar, Wochenziel 16.11.), Homer `…75SXMEBRLJdiSsv5Xd` (1267, blockiert auf `git rebase --continue` in `bornim-main`, der Chef muss es freigeben), Sokrates `…77APonFpNDWGs4JfMc` (Chefrunde, wartet auf Antworten des Chefs), Tom `…762Xztj8QLqEa23Rjp` (Build 286 wartet auf Test des Chefs; lauf.py will ihn für Kür 1214 neu starten und 286 archivieren, nicht tun). Lehren 15.11.: Sokrates sendet „Start <Rolle> <Nr>“, dann lauf.py prüfen und die Zeile ausführen; meldet Sokrates ausdrücklich Spike, kein Tom/Jerry (Weiter statt Start); ein START ohne Sperre lehnt der Haken ab, Sperrzeile von Hand nachtragen. Zeiten nur aus `date`. Offen 11:07: Auftrag Sokrates 11:05 (Tom soll 882.1 `claude/tom-882-1-ohne-gradle` auf main mischen, danach Perikles 870.10) ging als „Weiter“ an Tom; auf „Start Perikles 870.10“ warten. Alte Übergabe (erledigt, 15.11., 01:06): Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_014BcfzRMLG6Fa8bDwFVGeaY` abschalten; (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten 1019 <Zahl> <Kennung>`. Lauf wie „Jeder Lauf“ mit `--wecker <Ford-Wache …01EjSztWBEfCSuvh2gg2pRrC und jede Sitzung mit eigenem Weckruf aus list_triggers (Kurzzeile ohne Kosten für laufende Sitzungen, sonst bucht lauf.py zu früh)>` und den `--ohne`-Zeilen der alten Übergabe unten; Kurzzeilen aller Sitzungen aus `list_sessions` mit Seite 1 und 2 (Spike und Perikles liegen auf Seite 2, nie veraltete Zeilen wiederverwenden). Stand 01:06: Läuft: Jerry `…78SJHxHKh5akPaP15y` (Läufe 479, 480, 482, 1215 Film), Tuffy `…76d3QcJwbDH1YGUuPR` (930.7 Film Lauf 481, Weckruf), Sokrates `…75rZTuiGj1QA448MLH` (930.7, Weckruf 01:09), Diogenes `…78jTfdpL8avRWiFR1x` (1133). Idle: Tom `…78AmAJeR5X7Ghv9VBH` (Build 286 wartet auf Test des Chefs, nicht archivieren, kein Neustart ohne Meldung), Homer `…794ME3Gg3ydHeNmxum` (1260 wartet auf Chef), Spike `…7A7BuC683wt2MBEacm` (1040.1 wartet auf Lauf), Perikles `…75sJsPiamKXFvCq7Bf` (auf Abruf). Offen: Wächter 1036.1 (Jerry informiert, Stand nachziehen). Lehren 15.11.: Neustart-Meldung zuerst `get_session` (idle?), bei „working“ per `send_later` in 3 bis 4 Minuten erneut; Archivieren nie bei Chefnachricht unter 15 Minuten; Neustart Tuffy, Sokrates, Homer, Jerry, Tom von Hand mit Startsperre-Zeile, weil lauf.py sie nicht plant; Tom 286 nicht ohne Weckruf in `--wecker` lassen (sonst ARCHIVIERE). Zeiten nur aus `date`.
- **Alte Übergabe Ford (erledigt, nur noch für die `--ohne`-Zeilen; 14.11., 10:36, `session_01Hmoj7AAPsuvPwPbE7HCYeV`, Selbstneustart nach Haken 1019, Tiefe 1; die älteren Übergaben darüber gelten nicht mehr; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte 1–3 erledigt 10:37 (Selbstneustart abgeschlossen, Ford `…76dYAn9Jmk5yYyU3HQ`); Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_01GFLziADVCTDvXcdVsK1YTL` abschalten (`update_trigger enabled=false`); (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten`. Lauf wie „Jeder Lauf“: Kurzzeilen aus `list_sessions` (Status „pending“ und „running“ sind oft veraltet, vor START oder ARCHIVIERE `get_session`), `lauf.py --besetzung --liegt --wecker <Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` und jede Sitzung mit eigenem Weckruf aus `list_triggers`> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" --ohne "1235:Homer nicht baubar vor dem Meilenstein (Vorgang 1238)" <Datei>`, erst ohne, dann mit `--sperre`. Offen: (a) **Neustart Perikles** (Meldung 10:31, Commit `b7275a65f`, Nachfolger „Perikles – 1246: Stillstand nachts verhindern“): erst starten, wenn die Tagesbericht-Sitzung `…79x9S7PcZtZSXrN3we` ruht; dann deren Archivierung; (b) alte Sokrates-Sitzung `…79rZagJLmbFEy4HZhU` archivieren (Neustart 10:34, Nachfolger `…775ze3dz5eLhqTBs67`; ab 10:41 und idle, Kosten auf 930); (c) Diogenes `…7935pyQLrQDwBaDdQ9` (1098.1 nicht prüfbar vor 16.11.) idle, archivieren, wenn lauf.py es sagt; (d) Tom `…77znPDfxf4G6yvCC6Q` bleibt (Chef testet t285 dort; Neustart Tom erst nach Auswertung, Meldung „Neustart Tom“ abwarten); Spike 1092 `…7A4LFiFy7nygExKGnU`, Jerry 1227 `…77Q6K2jkHmLkqGiwNz` laufen; Jerry-Halt des Chefs 23:35 nur noch für 1072, 709, 709.1, 760, 1068, 1043, 1032, 931, 1224 (Chef 10:28). Lehren 14.11.: kein Neustart einer Sitzung, in der der Chef gerade testet oder antwortet; **ohne `--wecker` für Sitzungen mit eigenem Weckruf (Spike 04:06) plant lauf.py START und ARCHIVIERE falsch**: list_triggers jeden Lauf lesen und alle `persistent_session_id` außer Fords Uhr übergeben; vor START Tom prüfen, dass nicht schon eine Tom-Sitzung läuft (eine Sitzung je Rolle: „Weiter:“ statt zweiter); Startsperre schreibt `--sperre` nur für die erste START-Zeile, für weitere von Hand „Startsperre HH:MM Start <Name> (lauf.py)“ nachtragen; `reaktionen.py` am Morgen lesen (Chef 14.11. 10:27: 👍 auf 844 war angekommen, Eintrag mit „Nachricht <Kennung>“ je Nachricht, Hook sperrt Doppeltes). Werkzeugfehler: 1239 (Parser liest Beispielsatz „Aufwand hoch, weil“ als Nachfolger), 1243 (Commit-Prüfung hält an Terminen von heute mit späterer Uhrzeit). Kurzzeilen aus `list_sessions` (Seite 1 mit limit 8–10 genügt für laufende; ältere archiviert), `--ohne` wie im Befehl oben. Stand 10:36: Morgen und Tagesbericht 14.11. erledigt (kosten.py nicht gelaufen). Zeiten nur aus `date`.
- **Ford** `session_01Hmoj77ipw2pXLtZ7APj4LE` (16.11., 14:19, Handstart-Nachfolger, 1429), Uhr „Ford-Lauf“ `trig_01F9cw92P51YgZM8o1Pwhb3v` (`3 * * * *`, angelegt 14:22). Alter Ford `…76awPjHi5batouXHgC` archiviert 14:23, Kosten 51,98 $ auf 1019, 1366 gebucht; alte Uhr `trig_01PJTr2gPNqwT35yGNqDM5XC` aus. Ältere Kennungen: Protokoll und Git.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter** `session_01Hmoj78K3Ut6YQSgPLqZEvX` (15.11., 16:11, vom Handstart-Ford angelegt, 1098 A; Tiefe 1, Ford danach 2, Teams 3; nie archivieren).

## Eingang


- **Von Sokrates (16.11., 13:56):** sechs alte offene PRs ohne Besitzer: 193 (Build 274, laut Archiv getestet), 173 (Build 89, Kotlin), 107 (39 Schwierigkeit), 69 (72u Vorschau), 10, 5 (Oktober). Prüfen, ob enthalten oder überholt, dann mit Begründung schließen; der Chef fragte 13:50, wie viele offen sind.

- **Zu 1328.1, von Perikles (15.11., 21:16, 01ebdbde0):** Spike ist eigene Rolle: `lauf.py` führt ihn in START_REIHE wie Tom (Vorrat `ARBEIT-TEAM-SPIKE.md`, Zeilen 1268.x, 1270.x mit Besitzer Spike), keine Zusatzentwickler-Zeile mehr; Tuffy bleibt Aushilfe bei Jerry. Neu in `startbar.py --stand` (1332): Zeile „LEICHE …“, dann dem Besitzer in den Vorrat eintragen. Zeilen „zu testen, ohne Rückmeldung“ sind startbar (Tom 6, Jerry 21).


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

- 14:24 16.11.: Selbstneustart Ford abgeschlossen (Neue Uhr 14:22 nach Chef-Freigabe, Auto-Prüfung hatte create_trigger zuerst abgelehnt); Offen vom alten Ford: Perikles-Neustart gemeldet, Nachfolger „1440: Themenblöcke im Überblick nummerieren“ (nächster Lauf 15:03)
- 14:10 16.11.: Start Perikles 1424, alte Perikles-Sitzung archiviert (7,32 $ auf 1414,1217,870.12 gebucht)
- 14:08 16.11.: Lauf 14:04 (volle Seite 100 per Skript): Start Tom 1044, Spike 1416, Diogenes 1098.1; archiviert Tom 431 (22,23 $), Spike 1303/1270.4 (8,73 $), Diogenes 1410 (0,78 $), gebucht; Urteil 1303 gebilligt (4386); GELÖST an Jerry 481.2, Perikles 1217/870.12, Sokrates 870/1270, Spike 1385; Neustart Perikles d14aa8904 gemeldet (Sitzung arbeitet noch)
- 14:02 16.11.: alte Sokrates-Sitzung Testbegleitung archiviert (5,67 $ auf 291,1303,1423,1424,290); Neustart Tom 06bbd8ec7 gemeldet, Start im Lauf 14:06
- 13:45 16.11.: Start Sokrates „t291 verbuchen, PR 210 zusammenführen“ (session_01Hmoj7793wGk5UdWrQR5kMM, Neustart wegen Rechteprüfung/Rebase in alter Sitzung); alte Sitzung 77yp Archiv um 14:00, Kosten 291,1303,1423,1424,290
- 13:40 16.11.: Altlasten archiviert nach Chef-Frage 13:26 (zwei Diogenes-Sitzungen): Diogenes 1301 (1,19 $), Homer 1267 (15.11., 0,62 $ auf 1267), Tuffy 930.7 (14.11., 5,02 $ auf 930.7), alle gebucht; Ursache: Kurzform-Dateien mit „# has_more: nein“ aus nur der ersten Seite (12 Sitzungen) geschrieben, ältere nicht archivierte Sitzungen fehlten, lauf.py konnte sie nicht sehen; Fehler von Ford. Ab jetzt je Lauf list_sessions limit 100 (volle Seite, in Datei), Kurzform aus allen nicht archivierten daraus per Skript, bis zum Stichtag 08.11. geprüft: sonst keine Altlast
- 13:30 16.11.: Chef fragt nach 2 Diogenes-Sitzungen: Altlast „Diogenes – 1301“ (15.11., 17:00, ruhte seit 17:03 auf 'pausiert bis 16.11. 08:00') war nie archiviert; jetzt archiviert (1,19 $ auf 1301); lauf.py hat sie nicht gemeldet, weil beim Start 08:11 Diogenes als belegt galt (Seite 2 der Sitzungsliste nie geholt)
- 13:22 16.11.: Sokrates Chefrunde Rest archiviert (14,41 $ auf 1303,1235,1412 gebucht); Sokrates Testbegleitung t291/t292 läuft
- 13:10 16.11.: Chef 13:05 direkt: „Du darfst alles archivieren, was zum Archivieren ist, gemäß den Regeln“ (Autoprüfung lehnt Archivieren trotzdem ab, Chef will sie weg); Lauf 13:05: Start Homer 1419, archiviert Sokrates 75oX (11,06 $ auf 431,1382,1386) und Homer 1401 (2,57 $); Urteile 517 und 698 (4343/4344) im Archiv; GELÖST an Jerry 1331/1284b, Spike 1307; Sokrates 77oL bleibt bis 13:21, dann Archiv
- 13:04 16.11.: Start Sokrates Testbegleitung t291, t292 (session_01Hmoj77ypbCDEo7UTNPZiXo, Neustart 4f2dbba24); Sokrates-Sitzungen 75oX und 77oL offen: Archivierung von 75oX (Sokrates-Weitergabe „Chef 13:02: Schließe diese Sitzung“) von der Berechtigungsprüfung abgelehnt, wartet auf direktes Wort des Chefs; Kosten 75oX auf 431,1382,1386 danach
- 12:22 16.11.: **Lauf nur Muss** (Chef 12:19 bei 37 % Woche: „Muss primär ja, in Einzelfällen, weil Zusammenhang im Gespräch entscheiden“, Sokrates 12:21): ab sofort bis Sa 21.11., 20:00 lauf.py immer mit --nur-muss; Kür nur mit „jetzt“ des Chefs; weiter --ohne Tuffy und --ohne "1235:Gespräch 1236"; Sokrates Chefrunde Rest beendet ohne Neustart, Archiv 12:37
- 12:17 16.11.: Zwischenlauf: Start Spike 1303 (Chef 12:12 👍), Perikles 1414 (Chef 12:09); archiviert Spike 1386 (5,19 $) und Perikles 1398/1351/1413 (6,76 $), gebucht
- 12:07 16.11.: Lauf 12:04: Start Diogenes 1410, alte Diogenes-Sitzung archiviert (3,02 $ auf 1392 gebucht); GELÖST 1044 an Tom; Perikles-Nachfolger nicht gestartet (Vorrat leer, 1413 erledigt, alte Sitzung session_01Hmoj7752bUqezjjHom7vdR bleibt, kein Start ohne Arbeit)
- 11:08 16.11.: Lauf 11:04: Start Tom 431 Stufe 1, Jerry (Testbitte 292, dann 1284a A), Perikles (1398, dann 1351); archiviert Tom (18,09 $ auf 531,1383), Jerry (15,28 $ auf 292,1072), Perikles (5,46 $ auf 1392,654.2,1384,1390), gebucht
- 10:59 16.11.: alte Sokrates-Chefrunde-Sitzung archiviert (5,44 $ auf 1292, 654.2); Nachfolger Chefrunde Rest läuft; ältere Sitzung 75oX bleibt offen (Chef 09:20)
- 10:48 16.11.: Lauf 10:45: Start Homer 1352, alte Homer-Sitzung archiviert (2,63 $ auf 1370 gebucht); Weiter Diogenes 1399/1396; Wächter 1072 an Jerry und laut gemeldet; GELÖST an Tom 431h, Jerry 709/709.1/1291a; Neustart Perikles 07c2cf5ac und Neustart Tom 77404ff33 gemeldet, Sitzungen arbeiten noch; neuer Sokrates Chefrunde Rest session_01Hmoj77oLo8quAixJ2CvysQ (Archiv der alten Chefrunde-Sitzung um 10:58)
- 10:09 16.11.: Ford-Lauf 10:06: Start Jerry (Testbitte 292, dann 1072 Messung), alte Jerry-Sitzung archiviert (7,05 $, auf 292,1285,1333,1366,1072 gebucht); Tuffy-Warnung: keine Tuffy-Arbeit startbar, --ohne Tuffy; Chefrunde Sokrates wartet auf Entscheide 1–9 (Chef)
- 10:05 16.11.: Lauf 10:02: Start Spike 1386, Weiter Perikles 1396; archiviert Spike 698/292/1145/1286 (3,73 $) und Tuffy 1393 (0,72 $, gebucht); Jerry Neustart 58da31e24 (Sitzung läuft noch, Nachfolger Testbitte 292 folgt)
- 09:59 16.11.: Start Diogenes 1392, Tuffy 1393; archiviert Tuffy 1292 (3,14 $, gebucht); GELÖST 1393 an Jerry; Spike Neustart 41a7651b4 gemeldet (Sitzung läuft noch, Start im nächsten Lauf)
- 09:59 16.11.: Start Sokrates Chefrunde (Chef 09:57 „frischen Sokrates aufmachen“) session_01Hmoj782W54b9Me9QQgkHZa; alte Sokrates-Sitzung bleibt offen (Chef 09:20); lauf.py weiter mit --ohne Sokrates, zwei Sitzungen gewollt
- 01:03 16.11.: Marke Wächter 1186 13.11. 16:28 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj791pfnSs82NQrnpLnf 2026-11-15T23:45 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj79JCQRKsCCgciyGpnJ 2026-11-15T23:11 (lauf.py)
- 02:04 16.11.: Marke Hängt session_01Hmoj79NReuhLMU6cqsp6GW 2026-11-15T23:17 (lauf.py)
- 03:03 16.11.: Marke Übergabe-Chef Homer 16.11. 02:07 (lauf.py)
- 03:03 16.11.: Marke Hängt session_01Hmoj76VdQxk8E6re5azHWe 2026-11-16T00:54 (lauf.py)
- 04:07 16.11.: Nachfolger-Warnung Tom (Übergabe 16.11., 03:05) (lauf.py)
- 07:04 16.11.: Marke Übergabe-Chef Homer 16.11. 06:58 (lauf.py)
- 07:09 16.11.: Startsperre 07:09 Start Sokrates (Neustart, 4f3b3e668; Chef im Gespräch mit alter Sitzung …784LCeBpTzytFVVak6, nicht archivieren vor 15 min Ruhe nach letzter Chefnachricht)
- 08:11 16.11.: Marke Nachhalten 16.11. (lauf.py)
- 08:11 16.11.: Marke Stellungnahme Sokrates 16.11. (lauf.py)
- 08:11 16.11.: Marke Abgleich ganz 16.11. (lauf.py)
- 08:11 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 07:54) (lauf.py)
- 08:25 16.11.: Marke Übergabe-Chef Homer 16.11. 08:18 (lauf.py)
- 08:25 16.11.: Nachfolger-Warnung Jerry (Übergabe 16.11., 08:23) (lauf.py)
- 09:01 16.11.: Startsperre 09:01 Start Tom, Jerry, Spike, Diogenes, Homer, Perikles, Tuffy (lauf.py)
- 09:01 16.11.: Marke Tagesbericht 16.11. (lauf.py)
- 09:01 16.11.: Marke Stellungnahme Sokrates 16.11. (lauf.py)
- 09:01 16.11.: Marke Start-fehlt Tuffy 16.11.-08:25 (lauf.py)
- 09:01 16.11.: Marke Archiv session_01Hmoj78PsCC1nMKPN3KaUsi (lauf.py)
- 09:06 16.11.: Marke Wächter 1129 13.11. 12:53 (lauf.py)
- 09:08 16.11.: Start Sokrates 1129.4 (Wächter 1129 gemeldet laut); alte Sokrates-Sitzung nach Chefantwort 09:05 wieder geöffnet, Archiv 09:22 (15-Minuten-Regel); Neustart Spike 5d95e3442, Start folgt im nächsten Lauf (Marke 09:01); 1235 mit --ohne ausgeschlossen
- 09:14 16.11.: Marke Archiv session_01Hmoj75oXevBbggtoW6gYgE (lauf.py)
- 09:24 16.11.: Startsperre 09:24 Start Jerry, Spike, Diogenes (lauf.py)
- 09:24 16.11.: Marke Archiv session_01Hmoj7894iHwdcb9yds8JGU (lauf.py)
- 09:24 16.11.: Marke Archiv session_01Hmoj76h2mPbr2GReddWYJP (lauf.py)
- 09:25 16.11.: Startsperre 09:25 Start Perikles (lauf.py)
- 09:56 16.11.: Startsperre 09:56 Start Diogenes, Tuffy (lauf.py)
- 09:56 16.11.: Marke Start-fehlt Diogenes 16.11.-09:24 (lauf.py)
- 09:56 16.11.: Marke Archiv session_01Hmoj77xtHZzu5Fw9RsExRN (lauf.py)
- 10:02 16.11.: Startsperre 10:02 Start Spike, Perikles (lauf.py)
- 10:02 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 10:02 16.11.: Marke Archiv session_01Hmoj78VY1XDNZ234tjPMAL (lauf.py)
- 10:02 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 09:56) (lauf.py)
- 10:06 16.11.: Startsperre 10:06 Start Jerry (lauf.py)
- 10:06 16.11.: Marke Start-fehlt Tuffy 16.11.-09:56 (lauf.py)
- 10:06 16.11.: Marke Archiv session_01Hmoj7A5KnBfiqx8t69Q9MV (lauf.py)
- 10:45 16.11.: Startsperre 10:45 Start Diogenes, Homer (lauf.py)
- 10:45 16.11.: Marke Rückmeldung 1072 16.11. 10:11 (lauf.py)
- 10:45 16.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj75oXevBbggtoW6gYgE (lauf.py)
- 10:45 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 10:45 16.11.: Marke Archiv session_01Hmoj76es2uZMd5a4yrjmHt (lauf.py)
- 11:04 16.11.: Startsperre 11:04 Start Tom, Jerry, Perikles (lauf.py)
- 11:04 16.11.: Marke Archiv session_01Hmoj77NHg6rh9A1ECfhq7j (lauf.py)
- 11:04 16.11.: Marke Archiv session_01Hmoj76kpECV2hfEy8nEtVM (lauf.py)
- 11:04 16.11.: Marke Archiv session_01Hmoj76nAqQeLfP36ajZFbD (lauf.py)
- 11:04 16.11.: Nachfolger-Warnung Spike (Übergabe 16.11., 10:20) (lauf.py)
- 12:04 16.11.: Startsperre 12:04 Start Diogenes, Perikles (lauf.py)
- 12:04 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 12:04 16.11.: Marke Archiv session_01Hmoj76tYoe7PjfkrZzLrzh (lauf.py)
- 12:04 16.11.: Marke Archiv session_01Hmoj7752bUqezjjHom7vdR (lauf.py)
- 12:13 16.11.: Startsperre 12:13 Start Spike, Perikles (lauf.py)
- 12:13 16.11.: Marke Start-fehlt Perikles 16.11.-12:04 (lauf.py)
- 12:13 16.11.: Marke Archiv session_01Hmoj76FHiAXURGW1T4CW6m (lauf.py)
- 13:05 16.11.: Startsperre 13:05 Start Homer, Perikles (lauf.py)
- 13:05 16.11.: Marke Mehrfach-Warnung Sokrates session_01Hmoj77oLo8quAixJ2CvysQ (lauf.py)
- 13:05 16.11.: Marke Mehrfach Sokrates (lauf.py)
- 13:05 16.11.: Marke Archiv session_01Hmoj75kAWFUnHAs39ZVQcD (lauf.py)
- 13:05 16.11.: Marke Archiv session_01Hmoj78Qdamz672BcJVgmBj (lauf.py)
- 14:04 16.11.: Startsperre 14:04 Start Tom, Spike, Diogenes (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj76YJPkVYfUvNuvp1rW (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj7A9PrmiGn3Lx1jJSbz (lauf.py)
- 14:04 16.11.: Marke Archiv session_01Hmoj76GCWwLsp884GDFyfx (lauf.py)
- 14:07 16.11.: Startsperre 14:07 Start Perikles (lauf.py)
- 14:23 16.11.: Startsperre 14:23 Start Ford (Starter), Selbstneustart bei 563 Tsd. used_tokens (Zu 1429); Uhr Ford-Lauf trig_01PJTr2gPNqwT35yGNqDM5XC, alter Ford session_01Hmoj76awPjHi5batouXHgC
- 14:27 16.11.: Startsperre 14:27 Start Diogenes, Perikles (lauf.py)
- 14:27 16.11.: Marke Archiv session_01Hmoj77B6ik7MtVMjSKPLaK (lauf.py)
- 14:30 16.11.: Startsperre 14:30 Start Sokrates (selbst), Neustart-Meldung 14:26 (0bdca6936), Nachfolger Sokrates – 1424: PR 210 zusammenführen
- 14:31 16.11.: Start Perikles 1440 (session_01Hmoj764gyxqABGbpc7CtTg), Sokrates Neustart (session_01Hmoj78k58JUgc6hYURRcTg); alte Perikles 1424 und Sokrates 7793 archiviert, Kosten 4,53 $ und 7,50 $ gebucht; Weiter 1424 an Diogenes; Titel Ford auf 14:19 korrigiert
- 14:33 16.11.: Startsperre 14:33 Start Jerry (selbst), Neustart-Meldung 14:31 (f606a7ccc), Nachfolger Jerry – Testbitte 293
- 14:34 16.11.: Start Jerry Testbitte 293 (session_01Hmoj79Fja9zG9MubrAsDUS), alte Jerry-Sitzung archiviert, 41,28 $ auf 1393 gebucht
- 14:39 16.11.: Startsperre 14:39 Start Diogenes (selbst), Neustart-Meldung 14:32 (0a6f5f865), Muss 1427, 1440 bereit; alte Diogenes-Sitzung archiviert, 7,56 $ auf 1424, 1098, 1098.1 gebucht
- 15:07 16.11.: Lauf 15:03; START/ARCHIVIERE Perikles zurückgestellt (Perikles 14:45: Neustart erst nach Chef-Antwort zu 1441a); Stillstand Jerry 1340 nicht gezählt (Sitzung 293 läuft, Lauf bis 15:20); Rotbuch angelegt; Ford-Starter-Uhr (1444) nicht ausgeführt, Chef bezweifelt Befund
- 15:19 16.11.: Startsperre 15:19 Start Perikles (selbst), Neustart-Meldung 14:42/15:08 (ca6816ddf), Nachfolger Perikles – Vorratsprüfung L und O
- 15:21 16.11.: Start Perikles Vorratsprüfung L und O (session_01Hmoj75VUiHfboe6mxez3hv), alte Perikles-Sitzung archiviert, 9,67 $ auf 1440, 1441 gebucht
- 16:05 16.11.: Startsperre 16:05 Start Sokrates (selbst), Neustart-Meldung 16:00 (c419a34f3), Nachfolger Sokrates – 870: BRS-Umstellung nachhalten, Vorrat kürzen
