# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1275** (zuletzt 1274 Jerry 15.11. 10:58:39 a617) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Chef 15.11., 10:11 (an Sokrates, Chat):** „Wöchentlicher Verbrauch steht bei 9 Prozent“; seit Zurücksetzung Sa 14.11., 20:00 (angenommen wie bisher, nächste Sa 21.11., 20:00) 14 h ≈ 0,63 %/h, tragbar ≈ 0,60 %/h; bei diesem Schnitt 80 % (287) Fr 20.11. ≈ 02:00, 100 % Sa 21.11. ≈ 14:00, also knapp über Kurs; vorher (13.11.) Woche 66 %, ältere Bilder in Git; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (15.11., 01:06, `session_01Hmoj793a6GGZhUhAzGSphs`, Selbstneustart nach Haken 1019 Erinnerung 1, Tiefe 3 → Nachfolger liegt auf Tiefe 4; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_014BcfzRMLG6Fa8bDwFVGeaY` abschalten; (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten 1019 <Zahl> <Kennung>`. Lauf wie „Jeder Lauf“ mit `--wecker <Ford-Wache …01EjSztWBEfCSuvh2gg2pRrC und jede Sitzung mit eigenem Weckruf aus list_triggers (Kurzzeile ohne Kosten für laufende Sitzungen, sonst bucht lauf.py zu früh)>` und den `--ohne`-Zeilen der alten Übergabe unten; Kurzzeilen aller Sitzungen aus `list_sessions` mit Seite 1 und 2 (Spike und Perikles liegen auf Seite 2, nie veraltete Zeilen wiederverwenden). Stand 01:06: Läuft: Jerry `…78SJHxHKh5akPaP15y` (Läufe 479, 480, 482, 1215 Film), Tuffy `…76d3QcJwbDH1YGUuPR` (930.7 Film Lauf 481, Weckruf), Sokrates `…75rZTuiGj1QA448MLH` (930.7, Weckruf 01:09), Diogenes `…78jTfdpL8avRWiFR1x` (1133). Idle: Tom `…78AmAJeR5X7Ghv9VBH` (Build 286 wartet auf Test des Chefs, nicht archivieren, kein Neustart ohne Meldung), Homer `…794ME3Gg3ydHeNmxum` (1260 wartet auf Chef), Spike `…7A7BuC683wt2MBEacm` (1040.1 wartet auf Lauf), Perikles `…75sJsPiamKXFvCq7Bf` (auf Abruf). Offen: Wächter 1036.1 (Jerry informiert, Stand nachziehen). Lehren 15.11.: Neustart-Meldung zuerst `get_session` (idle?), bei „working“ per `send_later` in 3 bis 4 Minuten erneut; Archivieren nie bei Chefnachricht unter 15 Minuten; Neustart Tuffy, Sokrates, Homer, Jerry, Tom von Hand mit Startsperre-Zeile, weil lauf.py sie nicht plant; Tom 286 nicht ohne Weckruf in `--wecker` lassen (sonst ARCHIVIERE). Zeiten nur aus `date`.
- **Alte Übergabe Ford (erledigt, nur noch für die `--ohne`-Zeilen; 14.11., 10:36, `session_01Hmoj7AAPsuvPwPbE7HCYeV`, Selbstneustart nach Haken 1019, Tiefe 1; die älteren Übergaben darüber gelten nicht mehr; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte 1–3 erledigt 10:37 (Selbstneustart abgeschlossen, Ford `…76dYAn9Jmk5yYyU3HQ`); Schritte des Nachfolgers: (1) Uhr „Ford-Lauf“ `3 * * * *` mit `create_trigger` auf die eigene Kennung anlegen, mit `list_triggers` prüfen; (2) alte Uhr `trig_01GFLziADVCTDvXcdVsK1YTL` abschalten (`update_trigger enabled=false`); (3) diese Sitzung archivieren (idle, 60 s ruhig, keine Chef-Nachricht der letzten 15 Minuten), Kosten mit `lauf.py --kosten`. Lauf wie „Jeder Lauf“: Kurzzeilen aus `list_sessions` (Status „pending“ und „running“ sind oft veraltet, vor START oder ARCHIVIERE `get_session`), `lauf.py --besetzung --liegt --wecker <Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` und jede Sitzung mit eigenem Weckruf aus `list_triggers`> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" --ohne "1235:Homer nicht baubar vor dem Meilenstein (Vorgang 1238)" <Datei>`, erst ohne, dann mit `--sperre`. Offen: (a) **Neustart Perikles** (Meldung 10:31, Commit `b7275a65f`, Nachfolger „Perikles – 1246: Stillstand nachts verhindern“): erst starten, wenn die Tagesbericht-Sitzung `…79x9S7PcZtZSXrN3we` ruht; dann deren Archivierung; (b) alte Sokrates-Sitzung `…79rZagJLmbFEy4HZhU` archivieren (Neustart 10:34, Nachfolger `…775ze3dz5eLhqTBs67`; ab 10:41 und idle, Kosten auf 930); (c) Diogenes `…7935pyQLrQDwBaDdQ9` (1098.1 nicht prüfbar vor 16.11.) idle, archivieren, wenn lauf.py es sagt; (d) Tom `…77znPDfxf4G6yvCC6Q` bleibt (Chef testet t285 dort; Neustart Tom erst nach Auswertung, Meldung „Neustart Tom“ abwarten); Spike 1092 `…7A4LFiFy7nygExKGnU`, Jerry 1227 `…77Q6K2jkHmLkqGiwNz` laufen; Jerry-Halt des Chefs 23:35 nur noch für 1072, 709, 709.1, 760, 1068, 1043, 1032, 931, 1224 (Chef 10:28). Lehren 14.11.: kein Neustart einer Sitzung, in der der Chef gerade testet oder antwortet; **ohne `--wecker` für Sitzungen mit eigenem Weckruf (Spike 04:06) plant lauf.py START und ARCHIVIERE falsch**: list_triggers jeden Lauf lesen und alle `persistent_session_id` außer Fords Uhr übergeben; vor START Tom prüfen, dass nicht schon eine Tom-Sitzung läuft (eine Sitzung je Rolle: „Weiter:“ statt zweiter); Startsperre schreibt `--sperre` nur für die erste START-Zeile, für weitere von Hand „Startsperre HH:MM Start <Name> (lauf.py)“ nachtragen; `reaktionen.py` am Morgen lesen (Chef 14.11. 10:27: 👍 auf 844 war angekommen, Eintrag mit „Nachricht <Kennung>“ je Nachricht, Hook sperrt Doppeltes). Werkzeugfehler: 1239 (Parser liest Beispielsatz „Aufwand hoch, weil“ als Nachfolger), 1243 (Commit-Prüfung hält an Terminen von heute mit späterer Uhrzeit). Kurzzeilen aus `list_sessions` (Seite 1 mit limit 8–10 genügt für laufende; ältere archiviert), `--ohne` wie im Befehl oben. Stand 10:36: Morgen und Tagesbericht 14.11. erledigt (kosten.py nicht gelaufen). Zeiten nur aus `date`.
- **Ford** `session_01Hmoj76BCecXxLdXLfnEzk9` (15.11., 01:06, Selbstneustart, Tiefe 4 von 8), Uhr „Ford-Lauf“ `trig_01BpBNHHosCmPVkVh7ZdEqz5` (`3 * * * *`, auf diese Sitzung); Vorgänger `…793a6GGZhUhAzGSphs` 01:06 archiviert (8,33 $ auf 1019), seine Uhr `trig_014BcfzRMLG6Fa8bDwFVGeaY` abgeschaltet. Ältere Kennungen: Protokoll und Git.
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

- 10:51 15.11.: Homer neu `…75SXMEBRLJdiSsv5Xd` (1267), Homer 1264 archiviert (4,18 $); Perikles neu `…77RmWp9S7BfJZLPzKq` (1271 auf Meldung Sokrates), Perikles Tagesbericht archiviert (4,76 $)
- 10:47 15.11.: Sokrates neu `…77APonFpNDWGs4JfMc` (Chefrunde Berg abbauen, Chef wartet), alt archiviert (3,92 $ auf 1186)
- 10:17 15.11.: Sokrates neu `…78RskfRt4STVuE8msj` (Neustart e0527fb49), alt archiviert (6,72 $ auf 1260); Tuffy 1266 ausgenommen (Jerry nimmt es)
- 10:09 15.11.: Jerry neu `…79c2xTDZMPma5iiDXB` (1266 Kerbe, auf Meldung Sokrates 10:08), Jerry alt archiviert (1,07 $); Homer 1264 bekommt Weiter 1265
- 10:06 15.11.: Homer neu `…7A9BD9js7ioHpGovGR` (1264 Ideenspeicher), Homer 1260 archiviert; Perikles Tagesbericht `…79UDfkXFpM3zk1WmjM`, Perikles 1262 archiviert (1,36 $); Nachhalten ohne Befund; Wächter 1260 nicht gesendet (Sokrates führt Gespräch mit dem Chef)
- 07:05 15.11.: Morgen 15.11.: regelcheck: Verweise auf fehlende Dateien in ARBEIT-KREATIV, -PRUEFUNG, -TEAM-JERRY, -TEAM-TOM (Pfade ohne Ordner, vermutlich Fehlalarm); kosten.py nicht gelaufen (Sitzungsseiten zu groß), Ford ab 01:06 neu, Jerry 8,45 $, Tom 4,33 $, Sokrates 3,73 $
- 04:04 15.11.: Lauf ohne Start: Jerry (nichts startbar, Sitzung wartet auf Entscheidung 956) und Diogenes (1123 greift erst im nächsten Build) bewusst ausgenommen, sonst Kreis
- 03:12 15.11.: Jerry neu `…79uukZoJ96FG4zHcRv` (1123 Doku), Jerry alt archiviert (8,45 $ auf 806); Tom bleibt (286 wartet auf Chef-Test), „Weiter: 1263“ per Nachricht statt Neustart
- 03:04 15.11.: Diogenes neu `…78w1wTxyTuS8uf2tzM` (1123), Diogenes 1261 archiviert (1,07 $); GELÖST 1123 an Jerry
- 02:06 15.11.: Sokrates neu `…77SZdtkUPt9EJTJgwP` (1260 Stellungnahme), alt archiviert (3,73 $ auf 930.7); Perikles neu `…78JaxFDfPJBEPZts1z` (1262 Zirkel 1261/1123), alt archiviert; Diogenes 1133 archiviert (1,10 $); `--ohne` Jerry (806 wartet), Diogenes (1261 wartet auf Lauf Tom)
- 01:31 15.11.: Jerry neu `…76MSnYWiTvsA1DfTZG` (Lauf 482), Jerry alt archiviert (8,86 $ auf 479); Diogenes neu `…795CKQ5Pf7crAxZoTU` (1261); Wächter 1036.1 von Jerry beantwortet
- 01:08 15.11.: Tom neu `…762Xztj8QLqEa23Rjp` (286 Ergebnis des Tests), Tom alt archiviert (4,33 $ auf 286)
- 01:07 15.11.: Ford-Selbstneustart abgeschlossen: neue Uhr `trig_01BpBNHHosCmPVkVh7ZdEqz5` (:03), alte `trig_014BcfzRMLG6Fa8bDwFVGeaY` aus, alter Ford `…793a6GGZhUhAzGSphs` archiviert (1019, 8,33 $); Tom neu (286, Prüfliste 👍), Tom alt `…78AmAJeR5X7Ghv9VBH` wird archiviert
- 01:01 15.11.: Jerry neu `…78SJHxHKh5akPaP15y` (Läufe 479, 480, 482, 1215 Film), Jerry `…78yH84MdzrJ74grhR6` archiviert (25,96 $ auf 1215)
- 00:05 15.11.: Diogenes neu `…75edsFFzfEQPxCoWxq` (1019), Diogenes 1079 `…78sXbc6SZHTKCgXXZ3` archiviert (1,60 $)
- 00:01 15.11.: Sokrates `…76zXUTypnQhewTvAHH` (1259) archiviert (4,13 $ auf 1259)
- 23:50 14.11.: Tuffy neu `…76d3QcJwbDH1YGUuPR` (930.7 Film), Tuffy `…79v4vLh86CTewmRzZ9` archiviert (12,95 $ auf 930.7); Sokrates neu `…75rZTuiGj1QA448MLH` (930.7), alter `…76zXUTypnQhewTvAHH` Archivierung 00:00
- 23:45 14.11.: Homer neu `…794ME3Gg3ydHeNmxum` (1260), Homer `…76baqPiDLHo7r3hvWz` archiviert (4,22 $ auf 1260)
- 23:37 14.11.: Jerry neu `…78yH84MdzrJ74grhR6` (1215 Film), Jerry `…77eC8wuMDzUxc2ekY9` archiviert (10,02 $ auf 1215)
- 23:03 14.11.: Tom neu `…78AmAJeR5X7Ghv9VBH` (286), Jerry neu `…77eC8wuMDzUxc2ekY9` (1215); Tom `…77L1zKAAbcvm31GJBc` (5,62 $ auf 286) und Jerry `…75ZWJGSXdqrpx7xyzH` (29,98 $ auf 1222, Hinweis: Jerry-Kosten gehören auch zu 601 und 1215) archiviert
- 00:04 15.11.: Marke Archiv session_01Hmoj78sXbc6SZHTKCgXXZ3 (lauf.py)
- 01:03 15.11.: Marke Rückmeldung 1036.1 13.11. 18:33 (lauf.py)
- 01:03 15.11.: Marke Archiv session_01Hmoj75edsFFzfEQPxCoWxq (lauf.py)
- 01:06 15.11.: Diogenes neu `…78jTfdpL8avRWiFR1x` (1133), Diogenes 1019 `…75edsFFzfEQPxCoWxq` archiviert (2,14 $); Startsperre 01:06 Start Ford (selbst, Tiefe 3, Selbstneustart nach Haken 1019 Erinnerung 1)
- 01:06 15.11.: Marke Wächter 1133 13.11. 12:53 (lauf.py)
- 01:06 15.11.: Marke Archiv session_01Hmoj78AmAJeR5X7Ghv9VBH (lauf.py)
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
- 10:55 15.11.: Diogenes neu `…78yhg3iMnC4caCkmRB` (1272); 1270.1 per Weiter an Spike `…7A7BuC683wt2MBEacm` (Chef: nicht Tom und Jerry), Tom 286 bleibt (wartet auf Chef-Test)
- 10:56 15.11.: Startsperre 10:56 Start Spike (Neustart, 1a316e011)
- 10:57 15.11.: Spike neu `…77N7FwEA8GY6oPzSUA` (1270.1, Neustart 1a316e011), alt archiviert (10,98 $)
