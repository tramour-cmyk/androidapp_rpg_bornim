# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1241** (zuletzt 1240 Tom 13.11. 23:10:02 26e2) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 13.11., 09:46 (an Perikles, ohne Text):** Woche 66 % (Zurücksetzung Sa 14.11., 20:00), Sitzung 5 % (bis 14:10); App: „Auf Kurs … morgige Zurücksetzung … mit Spielraum“; Schnitt seit 12.11., 16:42 (48 %) ≈ 1,05 %/h, tragbar bis Sa ≈ 0,99 %/h (34 % in 34 h); bei diesem Schnitt 80 % (287, `--nur-muss`) heute ≈ 23:00, 100 % Sa ≈ 18:00; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (13.11., 18:00, `session_01Hmoj78u5NKKaaKVcUMPhcT`, Selbstneustart bei 405 Tsd.; Nachfolger: neue Stundenuhr „Ford-Lauf“ anlegen (`3 * * * *`, eigene Kennung aus `get_session`), alte `trig_01TjU64EK3639FuEHBURA6WS` abschalten (`update_trigger enabled=false`; Löschen lehnt der Klassifizierer ab), diese Sitzung archivieren (idle und 60 s ruhig, Kosten buchen, Zeile „Ford“ unter 400 Zeichen); Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` als `--wecker`; **Uhr „Ford-Lauf“ feuert, aber mit etwa 20 bis 55 Minuten Verspätung** (Slot 16:03 kam 16:58, 17:03 kam 17:23): Läufe laufen nach Sitzungsmeldungen „Neustart <Name>, <Commit>“ von Hand, Chef 16:07 und 16:59 informiert; laufend 17:58: Tom 284 `…78DPuPfsVVtyNnBuAu`, Jerry 284/1141 `…76LaTS3jY9wUdbYVmp`, Diogenes 1191 `…75jL9b9DF5Kf8a99Zk`, Perikles 1192 `…76K5AsxSSKgmX5MEC4`, Spike 1040.1 `…78tPvmFohTvuTRjozH`, Tuffy 949 `…775LSuDcmmCzsqUie1`, Sokrates 1113 `…79btn43krqv5ayLUJh`, Homer 1176 `…75UMzRVVnYKUQ5sxF5` (idle, nichts Startbares, archivieren wenn lauf.py es sagt); **Lehre 13.11.: Statuszeilen aus `list_sessions` sind oft veraltet (Spike zeigte `idle`, lief aber; Perikles, Diogenes zeigten `working`, waren fertig): vor ARCHIVIERE oder START einer Sitzung, die nicht in der Meldung „Neustart“ genannt ist, `get_session` lesen**; Neustart-Meldung: Commit auf `origin/main`, „Nachfolger:“ in der Übergabe, Startsperre ins Protokoll und pushen, `create_session`, Absender nach 60 s Ruhe archivieren (idle, `updated_at` älter als 60 s), Kosten `lauf.py --kosten <Vorgang> <$> <Kennung>` (Zeile über 400 Zeichen: anderen Vorgang des Absenders nehmen), Besetzung mit `lauf.py --besetzung` neu schreiben; Aufträge an laufende Sitzungen nur „Weiter:“ oder auf Bitte Sokrates oder Chef; Tuffy-Sitzung ohne Wecker bleibt hängen, wenn sie auf einen Lauf wartet: „Weiter:“ senden; Spike: Marke „Lauf läuft bis“ hält die Commit-Prüfung nicht mehr an (1159), `--ohne "Spike:…"` nur noch, wenn eine Marke nötig ist; Stichtag Vollzug 15.11., 20:00 bei Sokrates): Lauf nach „Jeder Lauf“ (1100 A): `list_sessions` (Seite 1 genügt, ältere sind archiviert; bei 100 Sitzungen läuft die Ausgabe in eine Datei, mit Python in Kurzzeilen wandeln), `list_triggers`, Kurzzeilen, `lauf.py --besetzung --liegt --wecker <Ids> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" <Datei>` erst ohne, dann mit `--sperre` (Zu 843); Archivieren nur ARCHIVIERE-Zeilen oder Neustart-Absender (nicht, wenn die letzte Chefnachricht jünger als 15 Minuten ist), Kosten mit `--kosten`; Aufträge an laufende Sitzungen nur „Weiter:“ nach WEITER-Zeile oder auf Bitte Sokrates oder Chef. Vor jedem Start die Zeile „Startsperre HH:MM Start <Name> (Ford, …)“ ins Protokoll und pushen (Haken). Nachfolger: Ford – Betriebsleiter
- **Ford** `session_01Hmoj772q8aDimJ7oU9STTH` (13.11., 18:22, vom Chef von Hand gestartet, Lineage-Tiefe 0 von 8), Uhr „Ford-Lauf“ `trig_01EHAn6DzrccwnUjPQpyP1z1` (`3 * * * *`, auf diese Sitzung); Vorgänger `…77sRcmN1u6VxQYWM7i` (Tiefe 8) 18:27 archiviert (0,69 $ auf 1100), davor `…78u5NKKaaKVcUMPhcT` 18:01 archiviert (8,33 $), seine Uhr `trig_01TjU64EK3639FuEHBURA6WS` abgeschaltet; davor `…79VeEbfi8Yk1Y2Eb6y` archiviert (7,78 $); seine Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` und die davor `trig_01BF6Lp6NmrCqGU6deZrg8tm` nur abgeschaltet (Löschen vom Klassifizierer abgelehnt; Chef kann sie löschen).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter:** keiner; ruht bis zur Antwort des Chefs auf 1098 (`entscheiden/1098-ford-starter.md`, Vorlage statt Vorentscheid wegen Bremse 194.1, Perikles 08:31); bis dahin Selbstneustart wie bisher, kein Starter anlegen.

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

- 22:31 13.11.: Neustart Jerry (a1a10e156): neue Sitzung `…79cBeV1g9SXzdarjgt` 22:30 (Umgebung Mittel), Vorgängerin `…76yF68cGVE8dBiecQT` archiviert (42,35 $ auf 709.1, 1072; Ford)
- 22:05 13.11.: Lauf 22:03: Diogenes (1175) `…75tnffFfTRAMHuhTAy`, Homer (1235) `…79TDPJJvAZwbQx6fLi`, Perikles (1230) `…78AKcmYZYcEtyFxx5V` gestartet; Vorgänger `…793z8s…` (1,97 $ auf 1221), `…79opda…` (6,80 $ auf 1229, 1232), `…79PfKh…` (3,40 $ auf 1221) archiviert; Listenstatus „pending“ der Sokrates-Sitzung war veraltet, get_session zeigte idle (Ford)
- 21:44 13.11.: Neustart Tom (949045da8): neue Sitzung `…78jYddD6WmJoPRmjVB` 21:43, Vorgängerin `…79V5GMGr3APPAiYHqT` archiviert (17,06 $ auf 285, 1092); PR-ABO #204 an die neue Sitzung (Ford)
- 21:39 13.11.: Neustart Tuffy (5a311f2f6): neue Sitzung `…79ZApqezAzombu1DWK` 21:40, Vorgängerin `…79CJCy8HRzLSWKT81C` archiviert (20,40 $ auf 844; nur 47 s Ruhe statt 60, Übergabe stand, nichts verloren; Ford)
- 21:38 13.11.: Neustart Sokrates (f0933cd29): neue Sitzung `…797jN7dteYW35dpYLZ` 21:37, Vorgängerin `…79ojfheg8dzo9KaZF9` archiviert (8,08 $ auf 1228, 1233, 1231, 1227; Ford)
- 21:26 13.11.: Start Homer 1229 (Jerry, c64477860): neue Sitzung `…79opdaF8aU7sFWvj1X` 21:25, alte `…75UMzRVVnYKUQ5sxF5` archiviert (1,22 $ auf 1176; Ford)
- 21:11 13.11.: Lauf 21:11: Diogenes (1221) `…793z8sMWYVXpXFxWN6` und Spike (542) `…79QJ2L8FTAiLRqDERR` gestartet; Spike-Sitzung 1073 `…75Ua972r7RW38NGDkm` archiviert (9,90 $ auf 1073, Frage liegt als entscheiden/1073.md); Auftrag Diogenes 1221 (Perikles, ef95b0418); Ausschluss 882.2 entfällt (Ford)
- 21:09 13.11.: Neustart Tom (d95c5f814): neue Sitzung `…79V5GMGr3APPAiYHqT` 21:08, Vorgängerin `…7845pb9Xd1sUtoWyjh` archiviert (38,20 $ auf 284, 1149; Ford)
- 21:07 13.11.: Lauf 21:03: Perikles (1221) `…79PfKha1ofQ8tTivdv` gestartet; sonst NICHTS (Tom, Jerry, Tuffy belegt; Diogenes, Homer nichts Startbares; Spike kein zweites Muss bei Tom; Ford)
- 21:05 13.11.: Neustart Sokrates (09def5d11): neue Sitzung `…79ojfheg8dzo9KaZF9` 21:04, Vorgängerin `…786drvmMKdc5ZKSe8v` archiviert (11,49 $ auf 1216, 1217, 1218, 1222, 1223; Ford)
- 21:01 13.11.: Neustart Jerry (0a23bf21f): neue Sitzung `…76yF68cGVE8dBiecQT` 20:59, Vorgängerin `…7972hfEsxURwGCfPMq` archiviert (36,09 $ auf 709.1, 1162, 1166; Ford)
- 20:30 13.11.: Neustart Diogenes (addcb05f9): Nachfolger „Diogenes – 1133 …“ erst ab 14.11., kein Start; Sitzung `…77QFVKxHtWXK1ztLCC` archiviert (6,30 $ auf 1199, 1208); Lauf-Ausschluss ab jetzt zusätzlich `--ohne "882.2:wartet auf 882.1"` bis 1221 behoben (Ford)
- 20:25 13.11.: Neustart Perikles (374faeafe): Nachfolger „Perikles – 1098, 1019, 1100, 1125: Stichtag 14.11. prüfen“ erst ab 14.11., kein Start; Sitzung `…79eigjcZiNVgt6FmRD` archiviert (7,51 $ auf 1217, 1213; 1220-Zeile schon über 400 Zeichen, Kostenfeld dort nicht beschreibbar; Ford)
- 20:09 13.11.: Neustart Perikles (e53c8c12b): neue Sitzung `…79eigjcZiNVgt6FmRD` 20:07, Vorgängerin `…77NmwkQgV4yHakA4mG` archiviert (5,86 $ auf 1184, 1193; Ford)
- 20:08 13.11.: Lauf 20:03: Diogenes (1199) `…77QFVKxHtWXK1ztLCC` gestartet; sonst NICHTS (Tom, Jerry, Perikles, Spike, Tuffy belegt; Homer nichts Startbares; Ford)
- 20:05 13.11.: „Neustart Jerry, 236d21ce7“ nicht ausgeführt: Chef testet t284 (Testbitte 19:21, ❤ 20:01), 284.7a–q sind Jerrys Bilder und Filme, Neustart während seines Tests nie (812, 865); Jerry bleibt und meldet nach dem Ergebnis neu (Ford)
- 19:58 13.11.: Neustart Sokrates (b8939f05e): neue Sitzung `…786drvmMKdc5ZKSe8v` 19:56, Vorgängerin `…786xhenUiyv4Q4X7rS` archiviert (5,16 $ auf 1149, 1141, 1215, 1073; Ford)
- 19:33 13.11.: „Neustart Tom, be168045a“ nicht ausgeführt: Chef testet t284 (Testbitte 19:22, kein Ergebnis), Neustart während seines Tests nie (812, 865); Tom bleibt, meldet nach dem Ergebnis neu (Ford)
- 19:30 13.11.: Neustart Sokrates (0a4b6e613): neue Sitzung `…786xhenUiyv4Q4X7rS` 19:27, Vorgängerin `…767QhDiSiUsddouRMf` archiviert (4,40 $ auf 949a, 709; Ford)
- 19:11 13.11.: Lauf 19:08: Spike (1073) `…75Ua972r7RW38NGDkm` und Tuffy (844) `…79CJCy8HRzLSWKT81C` gestartet, Vorgänger archiviert (9,37 $ auf 1040.1/1144; 9,27 $ auf 949); Wächter 1036.1 an Jerry (Ford)
- 02:04 13.11.: Marke Stellungnahme Sokrates 13.11. (lauf.py)
- 03:03 13.11.: Marke Abgleich Vorentscheid-Bremse (194.1): 6 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 04:04 13.11.: Marke Abgleich Vorentscheid-Bremse (194.1): 8 ungebilligt, 0 älter als 7 Ta (lauf.py)
- 05:31 13.11.: Nachfolger-Warnung Jerry (Übergabe 13.11., 05:29) (lauf.py)
- 07:04 13.11.: Marke Archiv-Warnung session_01Hmoj79qGhEdjuvdUYbpj3h (lauf.py)
- 08:04 13.11.: Marke Tagesbericht 13.11. (lauf.py)
- 08:04 13.11.: Marke Nachhalten 13.11. (lauf.py)
- 08:51 13.11.: Marke Stellungnahme Sokrates 13.11. (lauf.py)
- 09:40 13.11.: Marke Abgleich ganz 13.11. (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1090 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 492 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1044 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 867 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1022 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 842 ohne Datei in chefsache/billigen/ und ohne  (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1084 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 09:40 13.11.: Marke Abgleich Vorentscheid 1085 ohne Datei in chefsache/billigen/ und ohne (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj78LUomV3gY1qNRdSe2 (lauf.py)
- 15:34 13.11.: Marke Archiv session_01Hmoj77SjZb1gmYXPgTr429 (lauf.py)
- 16:33 13.11.: Marke Archiv session_01Hmoj78d3xW6CgXNSZfHUY6 (lauf.py)
- 17:22 13.11.: Startsperre 17:22 Start Sokrates (Ford, Neustart-Meldung d94b25a41, Nachfolger „Sokrates – 284: Gegenlesen Prüfliste, 1137 Vollzug (15.11.)“; Hoch, effort high)
- 16:44 13.11.: Marke Archiv session_01Hmoj78YTNmdHaUXiVES2DE (lauf.py)
- 17:22 13.11.: Startsperre 17:22 Start Diogenes, Perikles (lauf.py)
- 17:24 13.11.: Startsperre 17:24 Start Jerry (Ford, Neustart-Meldung f53d7bdbc, Nachfolger „Jerry – 709.1: Wolfsbiss in den Schild“; Hoch, effort high)
- 17:26 13.11.: Startsperre 17:26 Start Tuffy (Ford, Neustart-Meldung 30abf55a7, Nachfolger „Tuffy – 949: perfekter Ring im Lauf mit Kaufmodellen“; Hoch, effort high)
- 17:32 13.11.: Startsperre 17:32 Start Tom (Ford, Neustart-Meldung c646e772f, Nachfolger „Tom – 284: Schildbild 967, Push und Testbitte“; Hoch, effort high)
- 17:46 13.11.: Startsperre 17:46 Start Spike (Ford, Neustart-Meldung f8073aae2, Nachfolger „Spike – 1040.1: Läufe 441 und 442 prüfen, Filme an den Chef, dann 1144“; Hoch, effort high)
- 17:57 13.11.: Startsperre 17:57 Start Sokrates (Ford, Neustart-Meldung c21208b52, Nachfolger „Sokrates – 1113: Zahlen Kauf-Cache aus Lauf 284 an den Chef, 1137 Vollzug (15.11.)“; Hoch, effort high)
- 18:00 13.11.: Startsperre 18:00 Start Ford (selbst, Neustart, Nachfolger „Ford – Betriebsleiter“; Hoch, effort high)
- 17:22 13.11.: Marke Archiv session_01Hmoj79YQw7rUyf676pfGn7 (lauf.py)
- 17:22 13.11.: Marke Archiv session_01Hmoj75PSZY6iXgzp3SbFdQ (lauf.py)
- 17:22 13.11.: Marke Archiv session_01Hmoj7893iyxgChrYTygzXL (lauf.py)
- 18:25 13.11.: Startsperre 18:25 Start Tom, Perikles (lauf.py)
- 18:25 13.11.: Marke Archiv session_01Hmoj78DPuPfsVVtyNnBuAu (lauf.py)
- 18:25 13.11.: Marke Archiv session_01Hmoj76K5AsxSSKgmX5MEC4 (lauf.py)
- 18:50 13.11.: Startsperre 18:50 Start Sokrates (Neustart cbbb7af87, Nachfolger „Sokrates – 1137: Vollzug prüfen (15.11.), bis dahin Chefrunde“; Ford)
- 18:54 13.11.: Startsperre 18:54 Start Diogenes (Auftrag Diogenes 882.2 von Perikles, 471d99e2c; Ford)
- 18:57 13.11.: Startsperre 18:57 Start Jerry (Neustart 9e7dfd4a6, Nachfolger „Jerry – 284: Filme aus Lauf 444 schneiden und senden, dann 709.1“; Ford)
- 19:03 13.11.: Startsperre 19:03 Start Perikles (Neustart d889e2cf7, Nachfolger „Perikles – 1184: M? Kleinkram in der Prüfliste, dann 1193“; Ford)
- 19:06 13.11.: Startsperre 19:06 Start Spike, Tuffy (lauf.py)
- 19:06 13.11.: Marke Rückmeldung 1036.1 13.11. 18:33 (lauf.py)
- 19:06 13.11.: Marke Archiv session_01Hmoj78tPvmFohTvuTRjozH (lauf.py)
- 19:06 13.11.: Marke Archiv session_01Hmoj775LSuDcmmCzsqUie1 (lauf.py)
- 19:27 13.11.: Startsperre 19:27 Start Sokrates (Neustart 0a4b6e613; Ford)
- 19:55 13.11.: Startsperre 19:55 Start Sokrates (Neustart b8939f05e; Ford)
- 20:04 13.11.: Startsperre 20:04 Start Diogenes (lauf.py)
- 20:06 13.11.: Startsperre 20:06 Start Perikles (Neustart e53c8c12b, Nachfolger „Perikles – 1217: Testbitte unterwegs“; Ford)
- 20:59 13.11.: Startsperre 20:59 Start Jerry (Neustart 0a23bf21f nach Begründung: t284-Punkte 7a–f, k, l, p, q vom Chef beantwortet, nur 7n offen; Nachfolger „Jerry – 709.1: Bissplan an die Kapseln angleichen“; Ford)
- 21:04 13.11.: Startsperre 21:04 Start Sokrates (Neustart 09def5d11; Ford)
- 21:06 13.11.: Startsperre 21:06 Start Perikles (lauf.py)
- 21:07 13.11.: Startsperre 21:07 Start Tom (Neustart d95c5f814, Test t284 fertig 21:02, Ergebnis eingetragen; Nachfolger „Tom – 285: Build 285 und Prüfliste, dann 1092“; Ford)
- 21:11 13.11.: Startsperre 21:11 Start Diogenes, Spike (lauf.py)
- 21:11 13.11.: Marke Start-fehlt Diogenes 13.11.-20:04 (lauf.py)
- 21:11 13.11.: Marke Archiv session_01Hmoj75Ua972r7RW38NGDkm (lauf.py)
- 21:25 13.11.: Startsperre 21:25 Start Homer (lauf.py)
- 21:25 13.11.: Marke Archiv session_01Hmoj75UMzRVVnYKUQ5sxF5 (lauf.py)
- 21:36 13.11.: Startsperre 21:36 Start Sokrates (Neustart f0933cd29; Ford)
- 21:39 13.11.: Startsperre 21:39 Start Tuffy (Neustart 5a311f2f6, Nachfolger „Tuffy – 844: Film aus Lauf 458 schneiden und senden“; Ford)
- 21:42 13.11.: Startsperre 21:42 Start Tom (Neustart 949045da8, Nachfolger „Tom – 285: Bilder, Filme und Testbitte“; PR-ABO #204 geht nach dem Archivieren an die neue Sitzung; Ford)
- 22:04 13.11.: Startsperre 22:04 Start Diogenes, Homer, Perikles (lauf.py)
- 22:04 13.11.: Marke Archiv session_01Hmoj793z8sMWYVXpXFxWN6 (lauf.py)
- 22:04 13.11.: Marke Archiv session_01Hmoj79opdaF8aU7sFWvj1X (lauf.py)
- 22:04 13.11.: Marke Archiv session_01Hmoj79PfKha1ofQ8tTivdv (lauf.py)
- 22:29 13.11.: Startsperre 22:29 Start Jerry (Neustart a1a10e156, Nachfolger „Jerry – 709.1: Grimmzahn reicht nicht an den Schild“; Umgebung Mittel ohne Aufwandsfeld seit 22:04; Ford)
- 23:05 13.11.: Startsperre 23:05 Start Diogenes (lauf.py)
- 23:05 13.11.: Marke Archiv session_01Hmoj75tnffFfTRAMHuhTAy (lauf.py)
- 23:05 13.11.: Nachfolger-Warnung Jerry (Übergabe 13.11., 22:44) (lauf.py)
- 23:07 13.11.: Lauf 23:03: Diogenes (1237) `…783kjRUn2ac4Ks2Yhg` gestartet (Umgebung Mittel), Vorgängerin `…75tnffFfTRAMHuhTAy` archiviert (2,13 $ auf 1175); Starts Homer 1235 und Perikles (Parserfehler) mit --ohne verhindert, Vorgänge 1238, 1239 an Perikles; Ausschlussliste zusätzlich `--ohne "1235:…"` und `--ohne "Perikles:…"` bis dahin (Ford)
