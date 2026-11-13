# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1187** (zuletzt 1186 Sokrates 13.11. 16:29:23 c64f) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Bild Chef 13.11., 09:46 (an Perikles, ohne Text):** Woche 66 % (Zurücksetzung Sa 14.11., 20:00), Sitzung 5 % (bis 14:10); App: „Auf Kurs … morgige Zurücksetzung … mit Spielraum“; Schnitt seit 12.11., 16:42 (48 %) ≈ 1,05 %/h, tragbar bis Sa ≈ 0,99 %/h (34 % in 34 h); bei diesem Schnitt 80 % (287, `--nur-muss`) heute ≈ 23:00, 100 % Sa ≈ 18:00; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (13.11., 15:37, `session_01Hmoj79VeEbfi8Yk1Y2Eb6y`, Selbstneustart bei 423 Tsd.; Nachfolger: neue Stundenuhr „Ford-Lauf“ anlegen (`3 * * * *`, eigene Kennung), alte `trig_01V6NKSG889Hx9Pc4keu9PxX` abschalten (`update_trigger enabled=false`; Löschen lehnt der Klassifizierer ab), diese Sitzung archivieren (Kosten buchen); Ford-Wache `…01EjSztWBEfCSuvh2gg2pRrC` als `--wecker`; Lauf 15:35 gebucht; laufend: Sokrates `…769t2FmdXy5uubf2Av`, Jerry 1141 `…76yx1KYooNscLWY7La`, Tuffy `…7ACcqVEn2QirS2rZnX`, Tom 284 `…75dNijrJwAQz5aq5ov`, Perikles 1159 `…77fPoxLXgfScAHs4n4` (dazu 1161, 1163), Diogenes 1153 `…76Wu4naWNKev84VFup`; **Spike `…78LUomV3gY1qNRdSe2` nicht archivieren und nicht neu starten: Render-Lauf 882.1 läuft bis etwa 18:30, 98 Bilder fertig, Neustart verlöre sie** (Spike 15:29; die Marke „Lauf läuft bis“ hält die Commit-Prüfung an, Vorgang 1159 an Perikles; bis dahin `--ohne "Spike:Render-Lauf läuft bis 18:30"` in jedem Lauf, wirkt seit 1148); Diogenes 1114 Bauserver-Check 15:38 holt `lauf.py` nach; Tom 1129.3 und 1137.2 gebaut; Stichtag Vollzug 15.11., 20:00 bei Sokrates; **Uhr „Ford-Lauf“ hat 14:03 und 15:03 nicht gefeuert: Läufe nach Meldungen von Hand, Chef 15:30 gefragt**): Lauf nach „Jeder Lauf“ (1100 A): `list_sessions` (Seite 1 genügt, ältere sind archiviert), `list_triggers`, Kurzzeilen, `lauf.py --besetzung --liegt --wecker <Ids> --ohne "506.2:Tuffy nur auf Chef-Wort" --ohne "M?:Planfehler Klasse als Vorgang (893)" --ohne "Spiegel:Rolle beantwortet ihn selbst" --ohne "1068:Überschneidung mit Jerry 1094" --ohne "Pflege:nur Kür" --ohne "Spike:Render-Lauf läuft bis 18:30" <Datei>` erst ohne, dann mit `--sperre` (Zu 843); Zeile OHNE-ÜBERHOLT: das `--ohne` streichen. Archivieren nur ARCHIVIERE-Zeilen oder Neustart-Absender (nicht, wenn die letzte Chefnachricht jünger als 15 Minuten ist), Kosten mit `--kosten` (Zeile über 400 Zeichen: auf anderen Vorgang des Absenders buchen); Aufträge an laufende Sitzungen nur „Weiter:“ nach WEITER-Zeile oder auf Bitte Sokrates oder Chef. Vor jedem Neustart-Start die Zeile „Startsperre HH:MM Start <Name> (Ford, …)“ ins Protokoll und pushen (Haken). Nachfolger: Ford – Betriebsleiter
- **Ford** `session_01Hmoj78u5NKKaaKVcUMPhcT` (13.11., 15:37), Stundenuhr „Ford-Lauf“ `trig_01TjU64EK3639FuEHBURA6WS` (`3 * * * *`, nächster Lauf 16:03); Vorgänger `…79VeEbfi8Yk1Y2Eb6y` 15:38 archiviert (7,78 $); seine Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` und die davor `trig_01BF6Lp6NmrCqGU6deZrg8tm` nur abgeschaltet (Löschen vom Klassifizierer abgelehnt; Chef kann sie löschen).
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Ford-Starter:** keiner; ruht bis zur Antwort des Chefs auf 1098 (`entscheiden/1098-ford-starter.md`, Vorlage statt Vorentscheid wegen Bremse 194.1, Perikles 08:31); bis dahin Selbstneustart wie bisher, kein Starter anlegen.

## Eingang

- Aufgeräumt 13.11., 15:35 (Ford, auf Hinweis Perikles 1147 und Sokrates 00:33): alte Chefworte, Nachtpläne, Befunde und Regeln bis 11.11. gestrichen, Verlauf in Git (`git log -p docs/ARBEIT-BETRIEB.md`). Weiter gelten: je Rolle eine Sitzung; idle Sitzung (>60 s) archivieren und Kosten buchen (516a); `lauf.py` startet mit `--sperre` erst nach dem Lauf ohne; Startnachricht wie in `LISTE-BETRIEB.md` Schritt 4; nach jedem Start `get_session` auf Aufwand und Umgebung prüfen (Fehler 341).

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 13.11., 15:30 Ford: Läufe 13:39, 13:46, 14:09, 14:29, 14:50, 14:57, 15:28 von Hand nach Meldungen (Uhr „Ford-Lauf“ feuert seit 14:03 nicht); gestartet/Neustart Perikles, Diogenes, Tuffy, Sokrates, Jerry, Tom; alte Sitzungen archiviert und gebucht; Vorgänge 1148 und 1159 an Perikles (Hintergrundlauf Spike 882.1).
- 13.11., 13:23 Ford (neue Sitzung `…79VeEbfi8Yk1Y2Eb6y`): Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` neu, alte abgeschaltet (Löschen abgelehnt), Vorgänger archiviert (9,65 $, gebucht), Perikles 1134 gestartet `…79AYXzXxbEysheXSSM`; sonst alle belegt.
- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` und ignorierte die Warnung „Seite abgeschnitten“; künftig alle Seiten über `after_id` lesen, Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry aus eigener Beurteilung aus, ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch). Lehre: START ausführen oder `--ohne NR:Grund` und lautlos an Perikles

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
- 13:22 13.11.: Startsperre 13:22 Start Perikles (lauf.py)
- 13:39 13.11.: Startsperre 13:39 Start Diogenes (lauf.py)
- 13:46 13.11.: Startsperre 13:46 Start Perikles (lauf.py)
- 13:51 13.11.: Startsperre 13:51 Start Sokrates (Ford, Neustart-Meldung 5b10649b9, Nachfolger „Sokrates – 1129: Chefrunde blinde Flecken“; Hoch, effort high)
- 13:55 13.11.: Startsperre 13:55 Start Jerry (lauf.py)
- 13:57 13.11.: Startsperre 13:57 Start Spike (Ford, Neustart-Meldung bf4222f84, Nachfolger „Spike – 882.1: Vergleichsbilder alt rendern“; Hoch, effort high)
- 13:58 13.11.: Startsperre 13:58 Start Tom (Ford, Neustart-Meldung f966d7dcb, Nachfolger „Tom – 284: Prüfliste und Testbitte nach Test 283“; Hoch, effort high)
- 14:10 13.11.: Startsperre 14:10 Start Diogenes, Perikles, Tuffy (lauf.py)
- 14:10 13.11.: Marke Archiv session_01Hmoj78LUomV3gY1qNRdSe2 (lauf.py)
- 14:30 13.11.: Startsperre 14:30 Start Sokrates (Ford, Neustart-Meldung b0e5869af, Nachfolger „Sokrates – 1137: Vollzug nachhalten“; Hoch, effort high)
- 14:51 13.11.: Startsperre 14:51 Start Diogenes, Spike (lauf.py)
- 14:59 13.11.: Startsperre 14:59 Start Jerry (Ford, Neustart-Meldung 1f8c83598, Nachfolger „Jerry – 1141: Sterbebewegung je Körper“; Hoch, effort high)
- 14:59 13.11.: Startsperre 14:59 Start Tuffy (Ford, Neustart-Meldung 1ba5bca10, Nachfolger „Tuffy – nächstes startbares Muss“; Hoch, effort high)
- 15:28 13.11.: Startsperre 15:28 Start Tom (Ford, Neustart-Meldung 84db38211, Nachfolger „Tom – 284: Bilder, Film und Testbitte nach Test 283“; Hoch, effort high)
- 15:28 13.11.: Startsperre 15:28 Start Diogenes (lauf.py)
- 15:34 13.11.: Startsperre 15:34 Start Perikles (lauf.py)
- 15:41 13.11.: Startsperre 15:41 Start Tuffy (Ford, Neustart-Meldung d1cca12c2, Nachfolger „Tuffy – 949 Film an den Chef, dann nächstes startbares Muss“; Hoch, effort high)
- 15:44 13.11.: Startsperre 15:44 Start Diogenes (Ford, Neustart-Meldung 5297518b1, Nachfolger „Diogenes – 1159: Marke „Lauf läuft bis“ an der Commit-Prüfung (1148)“; Hoch, effort high)
- 15:34 13.11.: Marke Archiv session_01Hmoj77SjZb1gmYXPgTr429 (lauf.py)
- 15:37 13.11.: Startsperre 15:37 Start Ford (selbst, Neustart-Haken 423 Tsd., kein Starter; Hoch)
- 15:35 13.11.: Startsperre 15:35 Start Diogenes (Ford, Neustart-Meldung 49f93a1b7, Nachfolger „Diogenes – 1153: Wächter Rest auf allen Wegen zum Schließen“; Hoch, effort high)
- 15:49 13.11.: Startsperre 15:49 Start Homer (lauf.py)
- 15:51 13.11.: Startsperre 15:51 Start Diogenes (Ford, Neustart-Meldung 2bdea001a, Nachfolger „Diogenes – 1156: Lage herstellen in der Prüfliste (Spike 14070d8ca)“; Hoch, effort high)
- 15:54 13.11.: Startsperre 15:54 Start Perikles (lauf.py)
- 16:02 13.11.: Startsperre 16:02 Start Sokrates (Ford, Neustart-Meldung 30e6b800f, Nachfolger „Sokrates – 1137: Vollzug nachhalten“; Hoch, effort high)
- 16:33 13.11.: Startsperre 16:33 Start Spike (Ford, Neustart-Meldung e3a88c1b4, Nachfolger „Spike – 1040.1: Probeläufe 1040.1 und 1086 prüfen, dann 882.1 Render fortsetzen“; Hoch, effort high)
- 15:54 13.11.: Marke Start-fehlt Perikles 13.11.-15:34 (lauf.py)
- 16:33 13.11.: Startsperre 16:33 Start Diogenes (lauf.py)
- 16:33 13.11.: Marke Archiv session_01Hmoj78d3xW6CgXNSZfHUY6 (lauf.py)
