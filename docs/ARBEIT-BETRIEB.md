# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll.

**Nie archivieren:** (keine; Sokrates `session_01Hmoj76gTnkQt77JpdpoGF3` freigegeben, Chef 17.11., 09:08 „Dann Neustart“)

**Regeln für Ford bis Sa 14.11., 20:00 (Chef 07:09/07:18/07:19, Ford 08:13):** Archivieren und Kosten dauerhaft in `ROLLE-BETRIEB.md` (1110); alle Rollen in Hoch (`lauf.py` kann es seit 901, Umgebung `env_017fgL1YDcVTYTkJsU3APEfR`; Prüfen im START); ohne `--nur-muss`; Teampausen aufgehoben. `lauf.py` immer aus `/home/user/bornim-main/tools` rufen, nie aus dem Arbeitskopf ohne `git pull` (rechnet mit altem Stand). Dauerausschluss siehe Übergabe unten. Nachfolger: Ford – Betriebsleiter

**Nächste freie Vorgangsnummer: 1545** (zuletzt 1544 Perikles 17.11. 10:54:15 4cb3) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. **Jerry läuft in der Zentrale** (`LISTE-BETRIEB.md` „Ruht die Niederlassung“). Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g)

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Guthaben:** **Chef 16.11., 21:30 (an Perikles, Chat):** „Aktuell 50 Prozent Wochemverbrauch. Wir machen weiter ohne Einschränkungen.“; seit 12:13 (37 %) 1,4 %/h, seit Zurücksetzung Sa 14.11., 20:00 (angenommen, nächste Sa 21.11., 20:00) 49,5 h ≈ 1,0 %/h, tragbar für den Rest ≈ 0,42 %/h; bei 1,4 %/h 80 % (287) Di 17.11. ≈ 19:00, 100 % Mi 18.11. ≈ 09:00; 287 bleibt, bis der Chef anderes sagt; vorher (13.11.) Woche 66 %, ältere Bilder in Git; Limit-Reset „Kostenlos zurücksetzen“ (läuft ab 9. März) verfügbar, Reserve; Nutzungsguthaben an, 0 Credits · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen); Monat bis 25.10. 303,02 $ · ältere Bilder (bis 06.11.): Git · 13.11., 15:00: Sitzungsdaten zeigen `seven_day allowed_warning` (Chef 15:01 gemeldet)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Übergabe Ford (17.11., 07:42, `session_01Hmoj76ER7oUkkBFVsDDeqy`, Selbstneustart bei 401 Tsd. Token, Haken 1019, Erinnerung 1; Nachfolger: Ford – Betriebsleiter (TT.MM., HH:MM), Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Modell sonnet, Repo `main`):** Schritte des Nachfolgers (1444, Perikles 23:52: kein `create_trigger` je Neustart, die Auto-Prüfung lehnt ihn ab): (1) oben „Ford (aktuell)“ auf die eigene Kennung setzen; (2) der Uhr-Sitzung `session_01Hmoj76cLUxDoHGcPjixiTE` (nie archivieren, startet nie neu, gibt jeden Weckruf „Ford-Lauf“ der Uhr `trig_014gxLmndi38XvoQWufDEs98` per `send_message` an den aktuellen Ford weiter) `send_message` „Aktueller Ford: <eigene Kennung>“ schicken, Antwort abwarten; (3) alte Sitzung `…76ER7oUkkBFVsDDeqy` archivieren (idle, 60 s ruhig), Kosten buchen (`lauf.py --kosten <Vorgänge> <Zahl> <Kennung>`); Protokoll, pushen. Kein Chat-Bericht; Probe: der Lauf um 08:03 muss bei dir ankommen. Daumenzeile (1507): Satz „Fertiges lautlos … 👍/👎-Zeile“ nur in Starts und „Weiter“ an Tom, Jerry, Spike, Tuffy, nicht an Diogenes, Perikles, Homer, Sokrates. `lauf.py` startet Kür-Zeilen, die die Teams selbst zurückstellen (966.2, 168.1: Kapitel 2) und Perikles' Tagesbericht vor 07:30: mit `--ohne "<Nr>:<Grund>"` ausschließen, nicht starten, Befund kurz im Chat. Lauf: `list_sessions` (limit 12), Kurzform nur nicht archivierte Sitzungen, `python3 tools/lauf.py --sperre --besetzung --wecker <Sitzungen mit eigenem Weckruf aus list_triggers> --ohne "1235:Gespräch 1236" --ohne "Tuffy:keine Arbeit" <Datei>` ohne `--nur-muss` (Chef 21:30 „ohne Einschränkungen“; Nacht 16./17.11. Sokrates „Chef im Ring“: jede Rolle mit Startbarem läuft, nach jeder Übergabe sofort der Nachfolger, siehe Eingang); erst ohne, dann mit `--sperre`; Startsperre vor jedem `create_session` pushen; erste Nachricht jedes Starts mit dem Kaufrepo-Satz aus `lauf.py` Zeile 100 und dem Chefwort „Fertiges lautlos als Bild oder Film auf Telegram mit 👍/👎-Zeile“; Archivieren nur nach Regel (idle, 60 s ruhig; nie die Starter-Sitzung `session_01Hmoj78K3Ut6YQSgPLqZEvX`), Kosten sofort buchen. Neustart-Meldungen anderer („Neustart <Rolle>, <Commit>“): `get_session`, bei working per `send_later` 4 Minuten später erneut, dann Startsperre, `create_session` (Titel = Nachfolger der Übergabe), alte archivieren, `lauf.py --kosten <Vorgänge> <Zahl> <Kennung>`; „Start <Rolle> <Nr>“: laufende Sitzung der Rolle per `send_message` „Weiter: <Nr>“ (eine Sitzung je Rolle), nur ohne Sitzung `create_session`; M? startet nicht (Perikles stuft ein). Stand 07:42: läuft: Tom `…77fajJhDxipD6QrP42` (785.10, danach 1516 „jetzt“ und 1417; Sammelbuild 296 lokal, wartet auf Lauf 295 und Jerrys Gegenlesen 1511), Jerry `…799mexZFzyA7jnwrsJ` (785.12; 1305, 1505, 649.2 neu startbar), Spike `…75bizrHjtD8tG3F1De` (Lauf 546/Build 295, Testbitte t295, 1483 für 296), Homer `…76NcjeerwtT8PnpvfR` (Weiter 1513, [259T.frage] auf BRS), Perikles `…78gV596wg1KgLhojwt` (448 Tagesbericht 17.11. ab 07:31), Sokrates `…781BCNQwnEbXqwzD3u` (idle, Neustart d211b369c; Nachfolger „Chefgespräch Kosten A/B und 293“ ist ein Gespräch, nicht startbar; bei 08:03 archivieren, Kosten auf Betrieb); Tuffy `…76u1LvRMqGWHketsig` idle (ausgeschlossen, keine Arbeit); Diogenes keine Sitzung (Nachfolger „1246 um 08:00, dann 1425 (10:00)“, `lauf.py` startet ihn). Wecker: send_later `trig_…` ggf. offen, mit `list_triggers` prüfen. Mit `--ohne`: 1235:Gespräch 1236, Tuffy:keine Arbeit, 168.1:Kapitel 2, Pflege:erledigt. Warnung „Start <Rolle> nicht angekommen“ ist irrig, wenn die Rolle nach der Startsperre lief und archiviert ist. Zeiten nur aus `date`.
- **Ford (aktuell)** `session_01Hmoj75aJAz5Whuj3YyDLJw` (17.11., 07:43). **Uhr-Sitzung** `session_01Hmoj76cLUxDoHGcPjixiTE` (18:48, nie archivieren, 1444): hält Uhr „Ford-Lauf“ `trig_014gxLmndi38XvoQWufDEs98` (`3 * * * *`, angelegt 19:23 auf Chefwort „freigegeben“) und gibt „Ford-Lauf“ an den aktuellen Ford weiter; Kosten bis 23:50: 8,13 $ (gebucht erst beim Ende der Sitzung). Alter Ford `…77ipw2pXLtZ7APj4LE` archiviert 19:23, Kosten 10,65 $ auf 1019, 1366; alte Uhr `trig_01F9cw92P51YgZM8o1Pwhb3v` aus. Ältere Kennungen: Protokoll und Git.
- **Ford-Wache** `session_01EjSztWBEfCSuvh2gg2pRrC`, Uhren „Ford-Wache 07:08 Mo–Fr“ `trig_01Phk9eXekP5yY9M6L3bgS1c` und „Ford-Wache 09:08 Sa/So“ `trig_015znjB9NqE23LzgEG4qn5vE` (D13.2).
- **Sokrates (Chef 17.11., 08:52: „definitiv nicht archivieren oder schließen“)** `session_01Hmoj76gTnkQt77JpdpoGF3`: nie archivieren, kein zweiter Sokrates.
- **Ford-Starter** `session_01Hmoj78K3Ut6YQSgPLqZEvX` (15.11., 16:11, vom Handstart-Ford angelegt, 1098 A; Tiefe 1, Ford danach 2, Teams 3; nie archivieren).

## Eingang

- **Nacht 16./17.11., von Sokrates (Chef 22:41, geht schlafen):** „du bist Chef im Ring. Schau, dass halbwegs was abgearbeitet wird. Und bevor völliger Stillstand herrscht, weil wieder der eine auf den anderen wartet, bitte, bitte, bitte, dann lass irgendjemanden was machen. Wir haben genug Vorgänge.“ Ford: jede Rolle mit startbarem Muss oder Kür läuft (Tom 16, Jerry 44, Tuffy, Diogenes 1485 laut `startbar.py` 22:41); Wartende nicht abwarten lassen, Nächstes starten. Keine Testbitten mit `--laut` bis 7:00. Sokrates sieht stündlich nach. Chef 22:42: „immer schön dran denken, Bilder vorlegen, Filme vorlegen, kann ich relativ gut mit Däumchen drauf runter dann abarbeiten.“ → jedes Team legt Fertiges nachts als Bild oder Film auf Telegram vor (lautlos), mit 👍/👎-Zeile.

- **Von Sokrates (16.11., 13:56):** sechs alte offene PRs ohne Besitzer: 193 (Build 274, laut Archiv getestet), 173 (Build 89, Kotlin), 107 (39 Schwierigkeit), 69 (72u Vorschau), 10, 5 (Oktober). Prüfen, ob enthalten oder überholt, dann mit Begründung schließen; der Chef fragte 13:50, wie viele offen sind.

- **Zu 1328.1, von Perikles (15.11., 21:16, 01ebdbde0):** Spike ist eigene Rolle: `lauf.py` führt ihn in START_REIHE wie Tom (Vorrat `ARBEIT-TEAM-SPIKE.md`, Zeilen 1268.x, 1270.x mit Besitzer Spike), keine Zusatzentwickler-Zeile mehr; Tuffy bleibt Aushilfe bei Jerry. Neu in `startbar.py --stand` (1332): Zeile „LEICHE …“, dann dem Besitzer in den Vorrat eintragen. Zeilen „zu testen, ohne Rückmeldung“ sind startbar (Tom 6, Jerry 21).


- **Von Spike (14.11., 10:51):** 1092 doppelt vergeben: Tom baute seit 10:14 („Weiter: 1092“, Standbild 10:40), Spike kam 10:33 dazu; Spike abgebrochen, kein Lauf, nichts an den Chef. Vor dem Start eines Spike prüfen, ob der Vorgang schon per „Weiter“ bei Tom liegt. Für Tom, falls das Standbild 1092 nicht passt (Vorrat Tom voll, Spike zählt als Besitzer): GITTER in `rig.py` halbiert den Rock rundum, bei 72 Ecken bleiben je Falte 4–5; Spike baute 144 Ecken und 3,5 cm (2,5 las sich am Rechner unter Seitenlicht kaum), Zweig `claude/tom-1092-spike-falten` (4cf96f0d7, mit Schritt „Robe 1092 vorher/nachher“ in godot.yml).


- Aufgeräumt 13.11., 15:35 (Ford, auf Hinweis Perikles 1147 und Sokrates 00:33): alte Chefworte, Nachtpläne, Befunde und Regeln bis 11.11. gestrichen, Verlauf in Git (`git log -p docs/ARBEIT-BETRIEB.md`). Weiter gelten: je Rolle eine Sitzung; idle Sitzung (>60 s) archivieren und Kosten buchen (516a); `lauf.py` startet mit `--sperre` erst nach dem Lauf ohne; Startnachricht wie in `LISTE-BETRIEB.md` Schritt 4; nach jedem Start `get_session` auf Aufwand und Umgebung prüfen (Fehler 341).
- **Zu 1186, von Sokrates (Chef 13.11., 16:44, offene Vorgänge auf Leichen):** 843 erledigt (Diogenes Lauf 127, c6b02aa54: jeder START ausgeführt oder begründet); 741 überholt (Diogenes 09.11., fb8fd867e: durch 749, 776); 906 überholt (Sperre betraf 870.2–870.8, alle erledigt). Bitte schließen. Oben steht noch „Ford-Starter … ruht bis zur Antwort des Chefs auf 1098“; der Chef hat 13.11., 09:18 entschieden (Perikles 11:42: A gilt), bitte nachziehen.

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

- 13.11., 16:52 (Spike): `weiter-haken.py` schickt Spike auf Toms Zeilen, die Tom gerade selbst hat (756.1: Bild 16:34 gesendet, Stand noch „startbar“; 1044: „in Arbeit, Messlauf Osric“ seit 16:34). Vorschlag: für Spike/Tuffy Zeilen „in Arbeit“ ohne „bei Spike/Tuffy“ überspringen.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug.

- 17.11., 09:16 Ford: Sokrates-Neustart auf Chefwort 09:08: `…79XLgTfEVz9NoYYJ7m` („Chefrunde“), alter `…76gTnkQt77JpdpoGF3` archiviert (Schutzzeile war geleert), 7,53 $ auf 1520, 870; Tom „Weiter: 1528“ („jetzt“).
- 17.11., 10:52 Ford: Lauf 10:50: Jerry-Neustart `…77xEazSvYLsbY2twWp` (297), Tom über neue Jerry-Kennung informiert; Start Diogenes `…76GuSR3ZmBd53Pew6R` (1539), Perikles `…75Zz5WUmAyUmi4Uym5` (M? 1541, 1543); archiviert Jerry alt (3,86 $ auf 785.11, 785.15, 785.17, 785.12, 297), Diogenes alt (2,78 $ auf 1425, 1538), Perikles alt (5,04 $ auf 1535, 1538, 1537; Chefrückfrage beantwortet 10:27, kein Werkzeug gebaut). GELÖST 1520, 1137 an Sokrates.
- 17.11., 10:33 Ford: Tom-Neustart `…77SRiAi6pEtMKx6z7N` (431h Stufe 2), alter archiviert, 19,25 $ auf 296, 1516, 1417, 1515, 1535, 785.10.
- 17.11., 10:28 Ford: Jerry-Neustart `…75aoSZgtM2AQoGfirC` (Sammelbuild 785.11/785.15/785.17/785.12), alter archiviert, 14,21 $ auf 1505, 1340, 785.11, 785.15, 785.17, 1275, 1527. Tom Neustart-Meldung 10:25 (92be1c9df), Sitzung working, Prüfung 10:30.
- 17.11., 10:24 Ford: Sokrates-Neustart `…78qEvbcgDXCfWfsxLn` (1529), alter archiviert, 9,02 $ auf 1529, 1520; Link Build 296 nicht gesendet (Chef 10:03 „296 warten“). Diogenes 1425 läuft, „Weiter: 1538“. Perikles `…777UC4mRXgFsJi1T9s` nicht archiviert: offene Frage „Soll ich das bauen?“ (Fehlerhäufung Übergabe/Nachtragen) an den Chef, Neustart-Nachfolger erst 18.11. Jerry Neustart-Meldung 10:19 wartet (Sitzung working), Prüfung 10:25.
- 17.11., 10:04 Ford: Lauf 10:03 (vorgezogen 10:01): Start Diogenes `…79xM5rV6bTs6ZDkmXE` (1425), Perikles `…777UC4mRXgFsJi1T9s` (M? 1535, 1538); Spike „Weiter: 1537“; alte Diogenes (1,87 $ auf 1531) und Perikles (5,42 $ auf Betrieb) archiviert. URTEIL 785.10 ins Archiv.
- 17.11., 09:06 Ford: Lauf 09:03 (angekommen): Start Spike `…79iEGkbHvG4SheXezL` (295), Diogenes `…77PU7ZUzbAcvLEQ8S5` (1531), Homer `…79rLgkQVZ7GEDAFVcw` (1525); archiviert Spike, Diogenes, Homer alt, Kosten 10,73 $ auf 295, 2,17 $ auf 295, 601.1, 1488, 1275, 1340, 1284b, 1,76 $ auf Betrieb. WÄCHTER 785.10 an Tom (ohne Chefmeldung, Chef hat selbst geantwortet 08:44); GELÖST 385.2 an Jerry, 1270 an Sokrates; URTEIL 1516, 1515 ins Archiv, Chefsache-Dateien weg. Abgleich-Warnung 1 Zeile (ganz erst ab nächstem Tag).
- 17.11., 08:54 Ford: Chef 08:52 (über Sokrates): Sokrates-Sitzung `…76gTnkQt77JpdpoGF3` nie archivieren, kein zweiter Sokrates; Marke „Lauf läuft bis 17.11., 20:45“ gesetzt, Dauerregel 1531 bei Perikles („Weiter: 1531“ gesendet).
- 17.11., 08:53 Ford: Jerry-Neustart `…76TUvncWrgAWbXDgzh` (1505), alter archiviert, 20,17 $ auf 785.12, 1505, 1514; Sokrates auf Zuruf des Chefs 08:33 `…76gTnkQt77JpdpoGF3`; 1528 (.uid grundstand_1044) an Tom.
- 17.11., 08:16 Ford: Sokrates `…77G4ce7ghB2Dwu4oTC` archiviert (Übergabe 6ab0126f8, nichts startbar), 5,24 $ auf 870, 1520; Nachfolger „Sokrates – 1520 nach Antwort des Chefs, 870 nach 1523“ erst bei Lösung.
- 17.11., 08:15 Ford: Diogenes-Neustart: `…79bbfZMzZXyLy1U8G6` (Bautests t295: 601.1, 1488, 1275, 1340, 1284b), alter archiviert, 1,95 $ auf 1246. Perikles `…75iwL4zXVJo28mnSiW` „Weiter: 1524“ (Chef-Fund Build 295, Sokrates 08:11).
- 17.11., 08:06 Ford: Lauf 08:03 (über Uhr-Sitzung angekommen, 1444 Probe bestanden): Start Diogenes `…78hmxyQHB9Ac1r7eRu` (1246) und Perikles `…75iwL4zXVJo28mnSiW` (M? 1515), alter Perikles archiviert, Kosten 4,43 $ auf 448; 1305 Build 292 eingetragen (Abgleich). NACHHALTEN 17.11. offen (Schritt 8). Jerry bereitet Übergabe vor, Neustart-Meldung steht aus.
- 17.11., 07:59 Ford: Sokrates-Neustart: `…77G4ce7ghB2Dwu4oTC` gestartet, alter `…781BCNQwnEbXqwzD3u` archiviert, Kosten 9,46 $ auf 1503, 1506, 1507, 1508, 1519.
- 17.11., 07:54 Ford: Tom-Neustart: `…77SRDgqsBSpjHkd9Wt` gestartet, alter Tom archiviert. Lauf 07:52: 1068, 1224, 1415 an Jerry und 870 an Sokrates als GELÖST gesendet; Diogenes-Nachfolger 1246 erst 08:00 (zweiter Lauf prüft); Sokrates `…781BCNQwnEbXqwzD3u` idle, bei 08:03 archivieren.
- 17.11., 07:45 Ford (Nachfolger `…75aJAz5Whuj3YyDLJw`): Übergabe 1 bis 3 ausgeführt, Uhr-Sitzung bestätigt 07:44, alter Ford `…76ER7oUkkBFVsDDeqy` archiviert, Kosten 7,68 $ auf 1019, 1366. Lauf 08:03 ist die Probe.
- 17.11., 06:20 Ford: 1507 gilt ab jetzt: Satz „Fertiges lautlos … 👍/👎-Zeile“ nur in Starts und „Weiter“ an Tom, Jerry, Spike, Tuffy, nicht Diogenes, Perikles, Homer, Sokrates. Weiter an Jerry (1284b, 601.1, 1340, 623.2 Szene 3) und Tom (1448, 531, 1423 in den Sammelbuild) nach Chefdaumen der Nacht (Sokrates 06:18); 966.2 und 168.1 ausgelassen (Kür, Kapitel 2 bzw. Vorrangregel).
- 17.11., 00:06 Ford: Lauf 00:03 über Uhr-Sitzung angekommen, 1444 erledigt. Start Diogenes 1425 (`…78eYFVHDkQHymU7Jt7`); 1485 ausgeschlossen bis Jerrys 1501; Spike-Übergabe wartet auf Chef 1484 (bekannt).
- 16.11., 23:53 Ford (Nachfolger `…76ER7oUkkBFVsDDeqy`, Übergabe 23:50): `create_trigger` „Ford-Lauf“ auf eigene Kennung vom Auto-Modus-Klassifikator abgelehnt (Wortlaut an Perikles, 1441a A); nichts umgangen. Alte Uhr `trig_014gxLmndi38XvoQWufDEs98` wieder an, alter Ford `…76cLUxDoHGcPjixiTE` nicht archiviert (8,13 $ offen), läuft mit alter Uhr weiter. Offen: Erlaubnisregel für create_trigger, dann Uhr neu, alte aus, alten Ford archivieren.

- 13.11., 15:30 Ford: Läufe 13:39, 13:46, 14:09, 14:29, 14:50, 14:57, 15:28 von Hand nach Meldungen (Uhr „Ford-Lauf“ feuert seit 14:03 nicht); gestartet/Neustart Perikles, Diogenes, Tuffy, Sokrates, Jerry, Tom; alte Sitzungen archiviert und gebucht; Vorgänge 1148 und 1159 an Perikles (Hintergrundlauf Spike 882.1).
- 13.11., 13:23 Ford (neue Sitzung `…79VeEbfi8Yk1Y2Eb6y`): Uhr `trig_01V6NKSG889Hx9Pc4keu9PxX` neu, alte abgeschaltet (Löschen abgelehnt), Vorgänger archiviert (9,65 $, gebucht), Perikles 1134 gestartet `…79AYXzXxbEysheXSSM`; sonst alle belegt.
- Fehler 341 11.11., 09:30 (Chef fand ihn): Spike …76eB7 „Spike – 470 (10.11., 16:19)“ idle seit 10.11., 18:51 nicht archiviert. Ursache: ab 07:48 las ich nur die erste Seite von `list_sessions` und ignorierte die Warnung „Seite abgeschnitten“; künftig alle Seiten über `after_id` lesen, Warnung „abgeschnitten“ gilt als Abbruch
- Fehler 341 10.11., 10:3x (Chef fand ihn): Ford ließ START Jerry aus eigener Beurteilung aus, ohne --ohne, und nannte im Bericht „keine Arbeit“ (falsch). Lehre: START ausführen oder `--ohne NR:Grund` und lautlos an Perikles

- 23:21 16.11.: Diogenes (…75vVcD77XixJkEaw7D) nach Neustart-Meldung 120f7ecac archiviert, 6,02 $ auf 1485, 1498, 1500, 1499 gebucht; Nachfolger „1485 APK-Dateiname am Build-Zweig“ startet lauf.py, sobald 1485 startbar (Jerry 1501)
- 23:05 16.11.: Lauf 23:03: Start Spike 1499 (session_01Hmoj77pzGpWBZo1H1FppQo, Übernahme von Jerry), Start Perikles M? 1500 (session_01Hmoj76CDuBaNGRkJoRGqaj), alte Spike …76zAeRQxR3Re8uoBTU archiviert, 13,37 $ auf 1385, 1445, 1476, 1481, 1490, 1491 gebucht; beide Starts mit Kaufrepo-Satz und Telegram-Chefwort; Diogenes wartet auf Build 294 (1485 mit --ohne ausgeschlossen); Tom, Jerry, Tuffy, Sokrates laufen
- 22:50 16.11.: Tom Neustart (session_01Hmoj78CY54jy3o4vF8uRur, Kaufrepo-Satz, Telegram-Chefwort), alte …76RwQwh6oCCpcPppGf archiviert, 32,28 $ auf 1420, 431h, 531, 1044 gebucht; Weiter 1501 an Jerry (Diogenes 22:47)
- 22:43 16.11.: Lauf 22:42 (Chef 21:30 „ohne Einschränkungen“, Sokrates 22:41 Nacht ohne Stillstand): ohne --nur-muss; lauf.py plante Diogenes 1485 neu, ausgelassen (Diogenes-Sitzung …75vVcD77XixJkEaw7D: 1485 seit 21:47 auf main, Prüfung beim nächsten Build); Weiter 1044 an Tom (Kontext 568 Tsd., Neustart bei Übergabe); Tuffy 1415, Jerry Build 294, Sokrates laufen; Warnung „Start Perikles nicht angekommen“ irrig (archiviert 22:27, Nachfolger 17.11. 7:30)
- 22:27 16.11.: Perikles (…75bTNPcFHKN9gDnnxw) nach Neustart-Meldung 211546200 archiviert, 5,47 $ auf 1493, 1495, 1484, 1485 gebucht; Nachfolger „448: Tagesbericht 17.11.“ startet lauf.py um 7:30
- 22:05 16.11.: Lauf 22:03: Start Diogenes 1485 (session_01Hmoj75vVcD77XixJkEaw7D, Kaufrepo-Satz), alte …76ZXZhJrxTbHvQ4FiN archiviert, 5,63 $ auf 1385 gebucht; Tom, Spike, Perikles, Sokrates, Tuffy, Jerry belegt (Tom/Spike/Sokrates idle, eigene Arbeit offen)
- 22:04 16.11.: Warnung „Start Homer nicht angekommen“ (21:01) irrig: Homer lief 21:01–21:57 und ist archiviert (Wächter prüft nur lebende Sitzungen)
- 22:03 16.11.: Homer (…75eC5wiQijRtfjKuQd) nach Neustart-Meldung 683a3b62a archiviert, Vorrat leer, 5,84 $ auf 1489 gebucht
- 21:30 16.11.: Sokrates Neustart (session_01Hmoj77pgBEnvqA1NaaNeJP), alte …794brfP9KD4QDfzDUh archiviert, 6,59 $ auf 1411 gebucht (Link-Rückmeldung an die alte Sitzung entfiel: archiviert); Tuffy 1415 läuft
- 21:27 16.11.: Start Tuffy 1415 (session_01Hmoj76u1LvRMqGWHketsig, Kaufrepo-Satz), Perikles 21:26; 1488, 1439, 601.1 folgen als Tuffy-Zeilen danach
- 21:21 16.11.: Jerry Neustart (session_01Hmoj79PVQe2i9Ke3oaW9fH), alte …76XQ54YtEhfAGyiZ3Y archiviert, 21,18 $ auf 1453, 1072, 1275 gebucht; alte Sitzung hatte das Kaufrepo (bornim-kaufmodelle) als Quelle eingebunden, add_repo-Probe der neuen offen
- 21:03 16.11.: Lauf 21:01: Start Homer 1489 (session_01Hmoj75eC5wiQijRtfjKuQd), Start Perikles M? 1484–1487 (session_01Hmoj75bTNPcFHKN9gDnnxw); archiviert und gebucht: Homer alt 5,27 $ auf 1459, Perikles alt 2,57 $ auf 1474, Tuffy 2,67 $ auf 1411.1; 1488 (Jerry, Bau Merkmale) nicht gestartet: Jerry läuft (1453/Build 294), Vorrang Perikles; Spike 1484/1485 warten auf M
- 20:39 16.11.: Sokrates Neustart (session_01Hmoj794brfP9KD4QDfzDUh), alte …7A8bEWynsHcFDiq9Qy archiviert, 5,84 $ auf 1411 gebucht
- 20:22 16.11.: Start Tuffy 1411.1 (session_01Hmoj79xmtbHYvY4HJgquQC, erste Nachricht mit Kaufrepo-Satz)
- 20:21 16.11.: Planabweichung: lauf.py plante Tuffy 1408, Start stattdessen auf 1411.1 (Sokrates 20:20, Chef 20:19 „kann das ein freier Entwickler machen“; 1411.1 laut Vorgangsliste „startbar, Tuffy“)
- 19:43 16.11.: Sokrates Neustart (session_01Hmoj7A8bEWynsHcFDiq9Qy), alte …78yKr84GyQjcDaM636 archiviert, 5,39 $ auf 1411, 1478 gebucht
- 19:37 16.11.: Lauf 19:35: Start Diogenes 1385 (session_01Hmoj76ZXZhJrxTbHvQ4FiN), Start Perikles M? 1478 (session_01Hmoj7A9JQitciHyQxAs6gq, erste Nachricht mit Kaufrepo-Satz); alte Perikles archiviert, 4,55 $ auf 1474; Neustart Sokrates (cb4a0255a) offen: alte …78yKr84GyQjcDaM636 arbeitet noch, Start nach ihrem Ende; Tom bleibt (Weckrufe 1417/1420)
- 19:24 16.11.: Chef „freigegeben“ (19:22): Uhr trig_014gxLmndi38XvoQWufDEs98 angelegt, alte Uhr aus, alter Ford archiviert, 10,65 $ auf 1019, 1366 gebucht; Sokrates 1411 (…78yKr84GyQjcDaM636), Jerry (…76XQ54YtEhfAGyiZ3Y) schon 19:04/19:05 vom alten Ford gestartet, Diogenes 1477 erledigt
- 19:11 16.11.: Diogenes archiviert (Neustart 7c27178be, Nachfolger erst 18.11.), 12,24 $ auf 1463, 1477, 1445
- 19:05 16.11.: Sokrates Neustart (session_01Hmoj78yKr84GyQjcDaM636), alte archiviert, 3,72 $ auf 1403, 1472, 1475
- 10:50 17.11.: Startsperre 10:50 Start Jerry (selbst) – Neustart auf Meldung 10:43 (97c0dae38).
- 10:31 17.11.: Startsperre 10:31 Start Tom (selbst) – Neustart auf Meldung 10:25 (92be1c9df).
- 10:27 17.11.: Startsperre 10:27 Start Jerry (selbst) – Neustart auf Meldung 10:19 (720cfaf9c).
- 10:22 17.11.: Startsperre 10:22 Start Sokrates (selbst) – Neustart auf Meldung 10:18 (a8ec14a1e).
- 09:15 17.11.: Startsperre 09:15 Start Sokrates (selbst) – Neustart auf Meldung 09:09 (9b2199a20, Chef 09:08 „Dann Neustart“).
- 08:52 17.11.: Startsperre 08:52 Start Jerry (selbst) – Neustart auf Meldung 08:46 (6a3dcfaef).
- 08:32 17.11.: Startsperre 08:32 Start Sokrates (selbst) – auf Zuruf des Chefs („Bitte hol mal Sokrates“, 08:32).
- 08:14 17.11.: Startsperre 08:14 Start Diogenes (selbst) – Neustart 6a4619a53, danach Bautests t295 (601.1, 1488, 1275, 1340, 1284b).
- 07:57 17.11.: Startsperre 07:57 Start Sokrates (selbst) – Neustart auf Meldung 07:53 (d3399827c).
- 07:53 17.11.: Startsperre 07:53 Start Tom (selbst) – Neustart auf Meldung 07:51, Kosten 32,06 $ auf 1423 gebucht.
- 00:05 17.11.: Marke Übergabe-Chef Spike 16.11. 23:14 (lauf.py)
- 01:04 17.11.: Marke Archiv session_01Hmoj78eYFVHDkQHymU7Jt7 (lauf.py)
- 01:04 17.11.: Marke Archiv session_01Hmoj76CDuBaNGRkJoRGqaj (lauf.py)
- 01:04 17.11.: Nachfolger-Warnung Diogenes (Übergabe 17.11., 00:08) (lauf.py)
- 02:04 17.11.: Marke Archiv session_01Hmoj79sb6Z4qbo43YiQ32Q (lauf.py)
- 02:04 17.11.: Nachfolger-Warnung Diogenes (Übergabe 17.11., 01:19) (lauf.py)
- 03:04 17.11.: Marke Archiv session_01Hmoj79W9kdjryXGMR6Avbb (lauf.py)
- 04:04 17.11.: Marke Archiv session_01Hmoj78CY54jy3o4vF8uRur (lauf.py)
- 04:04 17.11.: Nachfolger-Warnung Diogenes (Übergabe 17.11., 03:39) (lauf.py)
- 05:04 17.11.: Startsperre 05:04 Start Jerry (lauf.py)
- 05:04 17.11.: Marke Start-fehlt Diogenes 17.11.-03:31 (lauf.py)
- 05:04 17.11.: Marke Archiv session_01Hmoj764SLoCvCFwQShPLJT (lauf.py)
- 05:04 17.11.: Nachfolger-Warnung Spike (Übergabe 17.11., 02:53) (lauf.py)
- 06:38 17.11.: Startsperre 06:38 Start Jerry (Ford von Hand), Neustart-Meldung 06:33 (d29a69780)
- 07:31 17.11.: Startsperre 07:31 Start Perikles (Ford von Hand), Tagesbericht 17.11. ab 07:30
- 07:43 17.11.: Startsperre 07:43 Start Ford (selbst), Selbstneustart bei 401 Tsd. Token (Haken 1019, Erinnerung 1), alter Ford session_01Hmoj76ER7oUkkBFVsDDeqy; Uhr-Sitzung …76cLUxDoHGcPjixiTE bleibt (1444)
- 08:04 17.11.: Startsperre 08:04 Start Diogenes, Perikles (lauf.py)
- 08:04 17.11.: Marke Nachhalten 17.11. (lauf.py)
- 08:04 17.11.: Marke Abgleich ganz 17.11. (lauf.py)
- 08:04 17.11.: Marke Archiv session_01Hmoj78gV596wg1KgLhojwt (lauf.py)
- 09:04 17.11.: Startsperre 09:04 Start Spike, Diogenes, Homer (lauf.py)
- 09:04 17.11.: Marke Rückmeldung 785.10 17.11. 08:44 (lauf.py)
- 09:04 17.11.: Marke Archiv session_01Hmoj75bizrHjtD8tG3F1De (lauf.py)
- 09:04 17.11.: Marke Archiv session_01Hmoj79bbfZMzZXyLy1U8G6 (lauf.py)
- 09:04 17.11.: Marke Archiv session_01Hmoj76NcjeerwtT8PnpvfR (lauf.py)
- 09:04 17.11.: Nachfolger-Warnung Diogenes (Übergabe 17.11., 08:29) (lauf.py)
- 10:01 17.11.: Startsperre 10:01 Start Diogenes, Perikles (lauf.py)
- 10:01 17.11.: Marke Archiv session_01Hmoj77PU7ZUzbAcvLEQ8S5 (lauf.py)
- 10:01 17.11.: Marke Archiv session_01Hmoj75iwL4zXVJo28mnSiW (lauf.py)
- 10:50 17.11.: Startsperre 10:50 Start Diogenes, Perikles (lauf.py)
- 10:50 17.11.: Marke Archiv session_01Hmoj79xM5rV6bTs6ZDkmXE (lauf.py)
- 10:50 17.11.: Marke Archiv session_01Hmoj777UC4mRXgFsJi1T9s (lauf.py)
